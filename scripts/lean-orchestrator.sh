#!/usr/bin/env bash
# lean-orchestrator.sh - Fast Skill Evaluation (~0s, ~0 tokens)
#
# Heuristic-based validation without LLM calls for rapid feedback

set -euo pipefail

LEAN_VERSION="1.0"
SKILL_FILE=""
OUTPUT_MODE="json"

show_usage() {
    cat <<EOF
Usage: $(basename "$0") <skill_file> [options]

Options:
    --json       JSON output (default)
    --text       Text output
    --certify    Include tier certification
    -h, --help   Show this help

Examples:
    $(basename "$0") ./SKILL.md
    $(basename "$0") ./SKILL.md --json --certify

Lean Evaluation (~0s):
    - Parse: YAML frontmatter + section structure (100pts max)
    - Text:  Heuristic quality scoring (350pts max)
    - Runtime: Trigger pattern validation (50pts max)
    - Total: 500pts -> normalized to 1000pts

Thresholds (1000pts normalized):
    PLATINUM >= 950
    GOLD     >= 900
    SILVER   >= 800
    BRONZE   >= 700
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --json) OUTPUT_MODE="json"; shift ;;
            --text) OUTPUT_MODE="text"; shift ;;
            --certify) CERTIFY="true"; shift ;;
            -h|--help) show_usage; exit 0 ;;
            *) SKILL_FILE="$1"; shift ;;
        esac
    done
    
    if [[ -z "$SKILL_FILE" ]]; then
        show_usage
        exit 1
    fi
}

lean_parse_score() {
    local file="$1"
    local score=0
    local max=100
    
    if [[ ! -f "$file" ]]; then
        echo "0:$max"
        return 1
    fi
    
    local content=$(cat "$file")
    
    if echo "$content" | grep -qE '^---'; then
        score=$((score + 30))
    fi
    
    if echo "$content" | grep -qE '(^|\n)#+\s+§1\.1'; then
        score=$((score + 10))
    fi
    if echo "$content" | grep -qE '(^|\n)#+\s+§1\.2'; then
        score=$((score + 10))
    fi
    if echo "$content" | grep -qE '(^|\n)#+\s+§1\.3'; then
        score=$((score + 10))
    fi
    
    if echo "$content" | grep -qE '(^|\n)#+\s+§2\.1'; then
        score=$((score + 10))
    fi
    if echo "$content" | grep -qE '(^|\n)#+\s+§3\.1'; then
        score=$((score + 15))
    fi
    if echo "$content" | grep -qE '(^|\n)#+\s+§[4-6]'; then
        score=$((score + 15))
    fi
    
    echo "$score:$max"
}

lean_text_score() {
    local file="$1"
    local score=0
    local max=350
    
    if [[ ! -f "$file" ]]; then
        echo "0:$max"
        return 1
    fi
    
    local content=$(cat "$file")
    
    local system_count=$(echo "$content" | grep -cE '(Identity|Framework|Thinking|Red Lines|Core Principles)')
    if [[ $system_count -ge 3 ]]; then
        score=$((score + 70))
    elif [[ $system_count -ge 1 ]]; then
        score=$((score + 35))
    fi
    
    local quant_count=$(echo "$content" | grep -cE '[0-9]+\.[0-9]+%|[0-9]+%|[Ff]1|[Mm][Rr][Rr]|[Tt]hreshold')
    if [[ $quant_count -ge 5 ]]; then
        score=$((score + 70))
    elif [[ $quant_count -ge 2 ]]; then
        score=$((score + 35))
    fi
    
    local workflow_count=$(echo "$content" | grep -cE '(Step|Phase|Pipeline|Done|Fail|Workflow|Process)')
    if [[ $workflow_count -ge 5 ]]; then
        score=$((score + 70))
    elif [[ $workflow_count -ge 2 ]]; then
        score=$((score + 35))
    fi
    
    local error_count=$(echo "$content" | grep -cE '(error|Error|fail|Fail|exception|retry|fallback)')
    if [[ $error_count -ge 5 ]]; then
        score=$((score + 55))
    elif [[ $error_count -ge 2 ]]; then
        score=$((score + 25))
    fi
    
    local example_count=$(echo "$content" | grep -cE '(Example|example|例如|例如|case|case)')
    if [[ $example_count -ge 3 ]]; then
        score=$((score + 55))
    elif [[ $example_count -ge 1 ]]; then
        score=$((score + 25))
    fi
    
    local meta_count=$(echo "$content" | grep -cE '^name:|^description:|^version:|^author:|^license:')
    if [[ $meta_count -ge 4 ]]; then
        score=$((score + 30))
    elif [[ $meta_count -ge 2 ]]; then
        score=$((score + 15))
    fi
    
    if [[ $score -gt $max ]]; then
        score=$max
    fi
    
    echo "$score:$max"
}

lean_runtime_score() {
    local file="$1"
    local score=0
    local max=50
    
    if [[ ! -f "$file" ]]; then
        echo "0:$max"
        return 1
    fi
    
    local content=$(cat "$file")
    
    local trigger_count=$(echo "$content" | grep -cE '(CREATE|EVALUATE|RESTORE|SECURITY|OPTIMIZE|create|evaluate|restore|security|optimize)')
    if [[ $trigger_count -ge 3 ]]; then
        score=$((score + 25))
    elif [[ $trigger_count -ge 1 ]]; then
        score=$((score + 10))
    fi
    
    local tool_count=$(echo "$content" | grep -cE '(Tool|tool|function|Function|action|Action)')
    if [[ $tool_count -ge 3 ]]; then
        score=$((score + 25))
    elif [[ $tool_count -ge 1 ]]; then
        score=$((score + 10))
    fi
    
    echo "$score:$max"
}

lean_certify() {
    local total="$1"
    local normalized=$(echo "scale=0; $total * 2" | bc)
    
    local tier="REJECTED"
    if [[ $(echo "$normalized >= 950" | bc) -eq 1 ]]; then
        tier="PLATINUM"
    elif [[ $(echo "$normalized >= 900" | bc) -eq 1 ]]; then
        tier="GOLD"
    elif [[ $(echo "$normalized >= 800" | bc) -eq 1 ]]; then
        tier="SILVER"
    elif [[ $(echo "$normalized >= 700" | bc) -eq 1 ]]; then
        tier="BRONZE"
    fi
    
    echo "$tier:$normalized"
}

run_lean_eval() {
    local file="$1"
    
    local parse_result=$(lean_parse_score "$file")
    local parse_score="${parse_result%%:*}"
    
    local text_result=$(lean_text_score "$file")
    local text_score="${text_result%%:*}"
    
    local runtime_result=$(lean_runtime_score "$file")
    local runtime_score="${runtime_result%%:*}"
    
    local total=$((parse_score + text_score + runtime_score))
    
    if [[ "${CERTIFY:-false}" == "true" ]]; then
        local certify_result=$(lean_certify $total)
        local tier="${certify_result%%:*}"
        local normalized="${certify_result#*:}"
        
        if [[ "$OUTPUT_MODE" == "json" ]]; then
            jq -n \
                --arg file "$file" \
                --argjson parse "$parse_score" \
                --argjson text "$text_score" \
                --argjson runtime "$runtime_score" \
                --argjson total "$total" \
                --argjson normalized "$normalized" \
                --arg tier "$tier" \
                '{
                    skill: $file,
                    parse_score: $parse,
                    text_score: $text,
                    runtime_score: $runtime,
                    total_score: $total,
                    normalized_score: $normalized,
                    tier: $tier,
                    mode: "lean"
                }'
        else
            echo "=== Lean Evaluation Results ==="
            echo "Skill: $file"
            echo "Parse: $parse_score/100"
            echo "Text: $text_score/350"
            echo "Runtime: $runtime_score/50"
            echo "---------------------------"
            echo "Total: $total/500 (normalized: $normalized/1000)"
            echo "Tier: $tier"
        fi
    else
        if [[ "$OUTPUT_MODE" == "json" ]]; then
            jq -n \
                --arg file "$file" \
                --argjson parse "$parse_score" \
                --argjson text "$text_score" \
                --argjson runtime "$runtime_score" \
                --argjson total "$total" \
                '{
                    skill: $file,
                    parse_score: $parse,
                    text_score: $text,
                    runtime_score: $runtime,
                    total_score: $total,
                    normalized_score: ($total * 2),
                    mode: "lean"
                }'
        else
            echo "=== Lean Evaluation Results ==="
            echo "Skill: $file"
            echo "Parse: $parse_score/100"
            echo "Text: $text_score/350"
            echo "Runtime: $runtime_score/50"
            echo "---------------------------"
            echo "Total: $total/500 (normalized: $((total * 2))/1000)"
        fi
    fi
}

main() {
    parse_args "$@"
    run_lean_eval "$SKILL_FILE"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
