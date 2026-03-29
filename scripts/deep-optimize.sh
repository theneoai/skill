#!/usr/bin/env bash
# deep-optimize.sh - 100轮深度优化循环
#
# 使用两个 LLM agent (minimax 和 kimi-code) 在每轮后评估
# 持续优化直到两个 agent 都给出 10/10 评分

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source ~/.bashrc 2>/dev/null || true

export MINIMAX_API_KEY="${MINIMAX_API_KEY:-}"
export KIMI_CODE_API_KEY="${KIMI_CODE_API_KEY:-}"

MAX_ROUNDS=100
SKILL_FILE="${PROJECT_ROOT}/SKILL.md"
EVAL_SCRIPT="${PROJECT_ROOT}/tools/eval/main.sh"
SNAPSHOT_DIR="${PROJECT_ROOT}/snapshots"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

log_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

mkdir -p "$SNAPSHOT_DIR"

evaluate_with_llm() {
    local provider="$1"
    local prompt="$2"
    
    local result
    case "$provider" in
        minimax)
            if [[ -z "$MINIMAX_API_KEY" ]]; then
                echo "0"
                return
            fi
            result=$(curl -s --max-time 30 "https://api.minimaxi.com/v1/text/chatcompletion_v2" \
                -H "Authorization: Bearer $MINIMAX_API_KEY" \
                -H "Content-Type: application/json" \
                -d "$(jq -n \
                    --arg model "MiniMax-M2.7-highspeed" \
                    --arg system "You are an expert skill evaluator. Rate from 1-10. Respond with ONLY a single number." \
                    --arg user "$prompt" \
                    '{model: $model, messages: [{role: "system", content: $system}, {role: "user", content: $user}], temperature: 0.3, stream: false}')" 2>/dev/null)
            ;;
        kimi-code)
            if [[ -z "$KIMI_CODE_API_KEY" ]]; then
                echo "0"
                return
            fi
            result=$(curl -s --max-time 30 "https://api.kimi.com/coding/v1/messages" \
                -H "x-api-key: $KIMI_CODE_API_KEY" \
                -H "anthropic-version: 2023-06-01" \
                -H "Content-Type: application/json" \
                -d "$(jq -n \
                    --arg model "kimi-for-coding" \
                    --arg system "You are an expert skill evaluator. Rate from 1-10. Respond with ONLY a single number." \
                    --arg user "$prompt" \
                    '{"model": $model, "max_tokens": 1024, "system": $system, "messages": [{"role": "user", "content": $user}]}')" 2>/dev/null)
            ;;
    esac
    
    if [[ -z "$result" ]]; then
        echo "0"
        return
    fi
    
    if echo "$result" | jq -e '.error // empty' >/dev/null 2>&1; then
        echo "0"
        return
    fi
    
    local text
    text=$(echo "$result" | jq -r '.choices[0].message.content // .content[0].text // empty' 2>/dev/null)
    
    if [[ -z "$text" ]]; then
        echo "0"
        return
    fi
    
    local score
    score=$(echo "$text" | grep -oE '^[0-9]+\.?[0-9]*' | head -1 || echo "0")
    
    if [[ -z "$score" ]] || [[ "$score" == "null" ]]; then
        score="0"
    fi
    
    echo "$score"
}

evaluate_skill_quality() {
    local skill_content="$1"
    local provider="$2"
    
    local truncated_content="${skill_content:0:8000}"
    
    local prompt="Evaluate this SKILL.md file and give it a rating from 1-10.

SKILL.md content:
---
$truncated_content
---

Consider:
1. Is the skill well-structured with clear sections (§1.1, §1.2, §1.3)?
2. Are the workflows actionable and complete?
3. Are there good examples?
4. Is error handling included?
5. Is the documentation clear?

Provide ONLY a single number (1-10) as your response."

    evaluate_with_llm "$provider" "$prompt"
}

get_eval_score() {
    local skill_file="$1"
    local eval_dir="$(dirname "$EVAL_SCRIPT")"
    
    cd "$eval_dir" || return 1
    
    local result
    result=$(bash ./main.sh --skill "$skill_file" --fast --ci 2>/dev/null)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        echo "0"
        return
    fi
    
    local json
    json=$(echo "$result" | sed -n '/^{/,/^}/p')
    
    if [[ -z "$json" ]]; then
        echo "0"
        return
    fi
    
    local score
    score=$(echo "$json" | jq -r '.total_score // 0' 2>/dev/null)
    
    echo "${score:-0}"
}

get_llm_suggestions() {
    local skill_content="$1"
    local provider="$2"
    local current_rating="$3"
    
    local truncated_content="${skill_content:0:8000}"
    
    local prompt="You are a skill optimization expert. The current skill has a rating of $current_rating/10.

SKILL.md content:
---
$truncated_content
---

Suggest 3 specific improvements to bring it closer to 10/10. Focus on:
1. Missing or vague sections
2. Incomplete workflows
3. Lack of examples
4. Poor error handling
5. Unclear instructions

Respond with JSON:
{\"suggestions\": [\"suggestion 1\", \"suggestion 2\", \"suggestion 3\"]}"

    local result
    case "$provider" in
        minimax)
            if [[ -z "$MINIMAX_API_KEY" ]]; then
                echo '{"suggestions": []}'
                return
            fi
            result=$(curl -s --max-time 30 "https://api.minimaxi.com/v1/text/chatcompletion_v2" \
                -H "Authorization: Bearer $MINIMAX_API_KEY" \
                -H "Content-Type: application/json" \
                -d "$(jq -n \
                    --arg model "MiniMax-M2.7-highspeed" \
                    --arg system "You are a skill optimization expert. Provide suggestions in JSON format." \
                    --arg user "$prompt" \
                    '{model: $model, messages: [{role: "system", content: $system}, {role: "user", content: $user}], temperature: 0.3, stream: false}')" 2>/dev/null)
            ;;
        kimi-code)
            if [[ -z "$KIMI_CODE_API_KEY" ]]; then
                echo '{"suggestions": []}'
                return
            fi
            result=$(curl -s --max-time 30 "https://api.kimi.com/coding/v1/messages" \
                -H "x-api-key: $KIMI_CODE_API_KEY" \
                -H "anthropic-version: 2023-06-01" \
                -H "Content-Type: application/json" \
                -d "$(jq -n \
                    --arg model "kimi-for-coding" \
                    --arg system "You are a skill optimization expert. Provide suggestions in JSON format." \
                    --arg user "$prompt" \
                    '{"model": $model, "max_tokens": 1024, "system": $system, "messages": [{"role": "user", "content": $user}]}')" 2>/dev/null)
            ;;
    esac
    
    if [[ -z "$result" ]] || echo "$result" | jq -e '.error // empty' >/dev/null 2>&1; then
        echo '{"suggestions": []}'
        return
    fi
    
    local text
    text=$(echo "$result" | jq -r '.choices[0].message.content // .content[0].text // empty' 2>/dev/null)
    
    if [[ -z "$text" ]]; then
        echo '{"suggestions": []}'
        return
    fi
    
    text=$(echo "$text" | sed -E 's/```json//g' | sed -E 's/```//g' | tr -d '\n')
    
    if ! echo "$text" | jq -e '.' >/dev/null 2>&1; then
        echo '{"suggestions": []}'
        return
    fi
    
    echo "$text"
}

apply_suggestions_with_quality_gate() {
    local skill_file="$1"
    local skill_content="$2"
    local suggestions="$3"
    local provider="${4:-kimi-code}"
    
    local suggestion_count
    suggestion_count=$(echo "$suggestions" | jq '.suggestions | length' 2>/dev/null || echo "0")
    
    if [[ "$suggestion_count" == "0" ]] || [[ "$suggestion_count" == "null" ]]; then
        log_info "No suggestions to apply"
        return 0
    fi
    
    log_info "Applying suggestions to SKILL.md (provider: $provider)..."
    
    local suggestions_text=""
    for i in $(seq 0 $((suggestion_count - 1))); do
        local suggestion
        suggestion=$(echo "$suggestions" | jq -r ".suggestions[$i]" 2>/dev/null)
        if [[ -n "$suggestion" ]] && [[ "$suggestion" != "null" ]]; then
            suggestions_text="${suggestions_text}${suggestion}\n"
            log_info "  Suggestion $((i+1)): ${suggestion:0:80}..."
        fi
    done
    
    local truncated_content="${skill_content:0:8000}"
    
    log_info "Generating improved SKILL.md..."
    
    local temp_request="/tmp/skill_optimize_request_$$.json"
    
    case "$provider" in
        minimax)
            if [[ -z "$MINIMAX_API_KEY" ]]; then
                log_error "MINIMAX_API_KEY not set"
                return 1
            fi
            jq -n \
                --arg model "MiniMax-M2.7-highspeed" \
                --arg system "You are a skill optimization expert. Return ONLY the improved SKILL.md content, no explanations." \
                --arg user "You are a skill optimization expert. Apply the following suggestions to improve this SKILL.md file.

Current SKILL.md content:
---
${truncated_content}
---

Suggestions to apply:
${suggestions_text}

Rewrite the complete SKILL.md file with these improvements applied. Keep the same structure and format. Return ONLY the improved SKILL.md content, no markdown code blocks." \
                '{"model": $model, "messages": [{"role": "system", "content": $system}, {"role": "user", "content": $user}], "temperature": 0.5, "stream": false}' > "$temp_request"
            
            result=$(curl -s --max-time 90 "https://api.minimaxi.com/v1/text/chatcompletion_v2" \
                -H "Authorization: Bearer $MINIMAX_API_KEY" \
                -H "Content-Type: application/json" \
                -d @"$temp_request" 2>/dev/null)
            ;;
        kimi-code)
            if [[ -z "$KIMI_CODE_API_KEY" ]]; then
                log_error "KIMI_CODE_API_KEY not set"
                return 1
            fi
            jq -n \
                --arg model "kimi-for-coding" \
                --arg system "You are a skill optimization expert. Return ONLY the improved SKILL.md content, no explanations." \
                --arg user "Improve SKILL.md with suggestions:

${suggestions_text}

SKILL.md content:
---
${truncated_content}
---

Return ONLY improved SKILL.md, no markdown blocks." \
                '{"model": $model, "max_tokens": 8192, "system": $system, "messages": [{"role": "user", "content": $user}]}' > "$temp_request"
            
            result=$(curl -s --max-time 90 "https://api.kimi.com/coding/v1/messages" \
                -H "x-api-key: $KIMI_CODE_API_KEY" \
                -H "anthropic-version: 2023-06-01" \
                -H "Content-Type: application/json" \
                -d @"$temp_request" 2>/dev/null)
            ;;
    esac
    
    rm -f "$temp_request" 2>/dev/null
    
    if [[ -z "$result" ]] || echo "$result" | jq -e '.error // empty' >/dev/null 2>&1; then
        log_error "Failed to get improved content from LLM"
        echo "Debug: result=$result" >> /tmp/apply_debug.log 2>/dev/null
        return 1
    fi
    
    local improved_content
    improved_content=$(echo "$result" | jq -r '.choices[0].message.content // .content[0].text // empty' 2>/dev/null)
    
    if [[ -z "$improved_content" ]] || [[ "$improved_content" == "null" ]]; then
        log_error "Empty improved content from LLM"
        return 1
    fi
    
    improved_content=$(echo "$improved_content" | sed -E 's/```markdown//g' | sed -E 's/```json//g' | sed -E 's/```//g')
    
    local temp_file="/tmp/skill_temp_$$.md"
    echo "$improved_content" > "$temp_file"
    
    log_info "Running eval on proposed changes..."
    local new_eval_score
    new_eval_score=$(get_eval_score "$temp_file")
    
    local current_score
    current_score=$(get_eval_score "$skill_file")
    
    log "Proposed eval score: $new_eval_score (current: $current_score, delta: $((new_eval_score - current_score)))"
    
    if [[ $new_eval_score -gt $current_score ]]; then
        log_info "Quality gate PASSED - applying changes"
        echo "$improved_content" > "$skill_file"
        rm -f "$temp_file"
        log_info "SKILL.md updated successfully"
        return 0
    else
        log_info "Quality gate FAILED - rolling back changes"
        rm -f "$temp_file"
        return 1
    fi
}

main() {
    log "=========================================="
    log "  深度优化启动 - 100轮优化循环"
    log "  目标: 两个 LLM agent 都达到 10/10"
    log "=========================================="
    
    if [[ ! -f "$SKILL_FILE" ]]; then
        log_error "SKILL.md not found: $SKILL_FILE"
        exit 1
    fi
    
    if [[ ! -f "$EVAL_SCRIPT" ]]; then
        log_error "Evaluation script not found: $EVAL_SCRIPT"
        exit 1
    fi
    
    log_info "API keys loaded:"
    [[ -n "$MINIMAX_API_KEY" ]] && log_info "  - Minimax: ✓" || log_info "  - Minimax: ✗"
    [[ -n "$KIMI_CODE_API_KEY" ]] && log_info "  - Kimi-code: ✓" || log_info "  - Kimi-code: ✗"
    
    log_info "Initial evaluation..."
    local initial_score
    initial_score=$(get_eval_score "$SKILL_FILE")
    log "Initial eval score: $initial_score"
    
    local minimax_rating=0
    local kimi_rating=0
    local round=0
    
    while [[ $round -lt $MAX_ROUNDS ]]; do
        round=$((round + 1))
        
        log ""
        log "=========================================="
        log "  Round $round / $MAX_ROUNDS"
        log "=========================================="
        
        local skill_content
        skill_content=$(cat "$SKILL_FILE" 2>/dev/null || echo "")
        
        log_info "Getting LLM ratings..."
        
        minimax_rating=$(evaluate_skill_quality "$skill_content" "minimax")
        kimi_rating=$(evaluate_skill_quality "$skill_content" "kimi-code")
        
        log "Minimax rating: $minimax_rating / 10"
        log "Kimi-code rating: $kimi_rating / 10"
        
        local both_ten=0
        if [[ $(echo "$minimax_rating >= 10" | bc -l 2>/dev/null || echo 0)" == "1" ]] && \
           [[ $(echo "$kimi_rating >= 10" | bc -l 2>/dev/null || echo 0)" == "1" ]]; then
            both_ten=1
        fi
        
        if [[ $both_ten -eq 1 ]]; then
            log ""
            log "=========================================="
            log "  🎉 优化完成！两个 agent 都达到 10/10！"
            log "  Minimax: $minimax_rating / 10"
            log "  Kimi-code: $kimi_rating / 10"
            log "  总轮数: $round"
            log "=========================================="
            break
        fi
        
        log_info "Running eval score check..."
        local eval_score
        eval_score=$(get_eval_score "$SKILL_FILE")
        log "Eval score: $eval_score"
        
        local avg_rating=$(( (minimax_rating + kimi_rating) / 2 ))
        
        log_info "Getting improvement suggestions (kimi-code)..."
        local suggestions
        suggestions=$(get_llm_suggestions "$skill_content" "kimi-code" "$kimi_rating")
        
        apply_suggestions_with_quality_gate "$SKILL_FILE" "$skill_content" "$suggestions" "kimi-code"
        
        log_info "Re-evaluating..."
        local new_eval_score
        new_eval_score=$(get_eval_score "$SKILL_FILE")
        
        log "New eval score: $new_eval_score (delta: $((new_eval_score - eval_score)))"
        
        if [[ $((round % 10)) -eq 0 ]]; then
            log_info "10-round checkpoint - Saving snapshot..."
            cp "$SKILL_FILE" "${SNAPSHOT_DIR}/skill_round_${round}.md"
        fi
    done
    
    if [[ $round -ge $MAX_ROUNDS ]]; then
        log ""
        log "=========================================="
        log "  达到最大轮数 $MAX_ROUNDS"
        log "  Final Minimax rating: $minimax_rating / 10"
        log "  Final Kimi-code rating: $kimi_rating / 10"
        log "  Final eval score: $(get_eval_score "$SKILL_FILE")"
        log "=========================================="
    fi
    
    log ""
    log "优化循环完成!"
}

main "$@"