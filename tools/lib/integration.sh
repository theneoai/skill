#!/usr/bin/env bash
# integration.sh - 集成 eval 框架

source "$(dirname "${BASH_SOURCE[0]}")/bootstrap.sh"
source "${EVAL_DIR_FROM_ENGINE}/lib/agent_executor.sh"

# ============================================================================
# 评估函数
# ============================================================================

evaluate_skill() {
    local skill_file="$1"
    local mode="${2:-fast}"
    
    if [[ ! -f "$skill_file" ]]; then
        echo "Error: Skill file not found: $skill_file" >&2
        return 1
    fi
    
    local original_dir="$(pwd)"
    local abs_skill_file
    if [[ "$skill_file" != /* ]]; then
        abs_skill_file="$(cd "$(dirname "$skill_file")" && pwd)/$(basename "$skill_file")"
    else
        abs_skill_file="$skill_file"
    fi
    cd "$EVAL_DIR" || return 1
    
    local result
    local tmpfile="/tmp/eval_result_$$"
    echo "DEBUG integration: pwd=$(pwd), EVAL_DIR=$EVAL_DIR, \$-=${-}, PATH=$PATH" >&2
    echo "DEBUG integration: Running main.sh with skill=$abs_skill_file" >&2
    echo "DEBUG integration: which main.sh: $(which main.sh 2>/dev/null || echo 'not in PATH')" >&2
    echo "DEBUG integration: main.sh exists: $(test -f ./main.sh && echo 'yes' || echo 'no')" >&2
    bash ./main.sh --skill "$abs_skill_file" --${mode} --ci >"$tmpfile" 2>&1
    local exit_code=$?
    result=$(cat "$tmpfile")
    rm -f "$tmpfile"
    echo "DEBUG integration: main.sh exit_code=$exit_code, result_len=${#result}" >&2
    echo "DEBUG integration: result_first_100=${result:0:100}" >&2
    
    cd "$original_dir" || return 1
    
    if [[ $exit_code -ne 0 ]]; then
        echo "DEBUG integration: main.sh failed, returning 1" >&2
        return 1
    fi
    
    local json
    json=$(echo "$result" | sed -n '/^{/,/^}/p')
    if [[ -z "$json" ]]; then
        return 1
    fi
    echo "$json"
}

evaluate_partial() {
    local partial_content="$1"
    local temp_file=$(mktemp /tmp/partial_skill_XXXXXX.md)
    
    echo "$partial_content" > "$temp_file"
    
    local result
    result=$(evaluate_skill "$temp_file" "fast")
    
    rm -f "$temp_file"
    
    echo "$result"
}

parse_evaluation_result() {
    local result="$1"
    
    local score tier p1 p2 p3 p4
    score=$(echo "$result" | jq -r '.total_score' 2>/dev/null || echo 0)
    tier=$(echo "$result" | jq -r '.tier' 2>/dev/null || echo "UNKNOWN")
    p1=$(echo "$result" | jq -r '.phases.parse_validate' 2>/dev/null || echo 0)
    p2=$(echo "$result" | jq -r '.phases.text_score' 2>/dev/null || echo 0)
    p3=$(echo "$result" | jq -r '.phases.runtime_score' 2>/dev/null || echo 0)
    p4=$(echo "$result" | jq -r '.phases.certification' 2>/dev/null || echo 0)
    
    jq -n \
        --arg score "$score" \
        --arg tier "$tier" \
        --arg p1 "$p1" \
        --arg p2 "$p2" \
        --arg p3 "$p3" \
        --arg p4 "$p4" \
        '{
            score: ($score | tonumber),
            tier: $tier,
            phases: {
                parse: ($p1 | tonumber),
                text: ($p2 | tonumber),
                runtime: ($p3 | tonumber),
                cert: ($p4 | tonumber)
            }
        }'
}