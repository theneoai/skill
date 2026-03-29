#!/usr/bin/env bash
# triggers.sh - Intent detection based on trigger patterns
#
# Implements mode detection per refs/triggers.md:
#   - Primary keyword matching with scores
#   - Secondary (context) pattern matching
#   - Negative pattern filtering
#   - Confidence scoring formula
#   - Language detection (EN/ZH)

source "$(dirname "${BASH_SOURCE[0]}")/constants.sh"

readonly TRIGGER_VERSION="1.0"

detect_language() {
    local input="$1"
    local zh_pattern='[一-龥]'
    local en_pattern='[a-zA-Z]'

    local has_zh=$(echo "$input" | grep -o "$zh_pattern" | wc -l)
    local has_en=$(echo "$input" | grep -o "$en_pattern" | wc -l)

    if [[ $has_zh -gt 0 ]] && [[ $has_en -eq 0 ]]; then
        echo "ZH"
    elif [[ $has_en -gt 0 ]] && [[ $has_zh -eq 0 ]]; then
        echo "EN"
    else
        echo "MIXED"
    fi
}

score_primary_keywords() {
    local input="$1"
    local lang="$2"
    local mode="$3"

    input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    local score=0

    case "$mode" in
        CREATE)
            case "$lang" in
                EN|MIXED)
                    if echo "$input_lower" | grep -qE 'create.*skill|build.*skill|make.*skill'; then
                        ((score += 3))
                    elif echo "$input_lower" | grep -qE 'new.*skill|develop.*skill|add.*skill'; then
                        ((score += 2))
                    elif echo "$input_lower" | grep -qE 'generate.*skill|scaffold.*skill'; then
                        ((score += 1))
                    fi
                    ;;
            esac
            case "$lang" in
                ZH|MIXED)
                    if echo "$input_lower" | grep -qE '创建|新建'; then
                        ((score += 3))
                    elif echo "$input_lower" | grep -qE '开发|制作|生成'; then
                        ((score += 2))
                    elif echo "$input_lower" | grep -qE '脚手架'; then
                        ((score += 1))
                    fi
                    ;;
            esac
            ;;
        EVALUATE)
            case "$lang" in
                EN|MIXED)
                    if echo "$input_lower" | grep -qE 'evaluate.*skill|test.*skill|score.*skill'; then
                        ((score += 3))
                    elif echo "$input_lower" | grep -qE 'review.*skill|assess.*skill|check.*skill'; then
                        ((score += 2))
                    elif echo "$input_lower" | grep -qE 'validate.*skill|benchmark.*skill'; then
                        ((score += 1))
                    fi
                    ;;
            esac
            case "$lang" in
                ZH|MIXED)
                    if echo "$input_lower" | grep -qE '评估|测试|打分'; then
                        ((score += 3))
                    elif echo "$input_lower" | grep -qE '审查|验证|检查'; then
                        ((score += 2))
                    elif echo "$input_lower" | grep -qE '评分|基准'; then
                        ((score += 1))
                    fi
                    ;;
            esac
            ;;
        RESTORE)
            case "$lang" in
                EN|MIXED)
                    if echo "$input_lower" | grep -qE 'restore.*skill|fix.*skill|repair.*skill'; then
                        ((score += 3))
                    elif echo "$input_lower" | grep -qE 'recover.*skill|undo|rollback.*skill'; then
                        ((score += 2))
                    elif echo "$input_lower" | grep -qE 'broken.*skill|corrupt.*skill'; then
                        ((score += 1))
                    fi
                    ;;
            esac
            case "$lang" in
                ZH|MIXED)
                    if echo "$input_lower" | grep -qE '恢复|修复|还原'; then
                        ((score += 3))
                    elif echo "$input_lower" | grep -qE '补救|撤销|回滚'; then
                        ((score += 2))
                    elif echo "$input_lower" | grep -qE '损坏|失效|破坏'; then
                        ((score += 1))
                    fi
                    ;;
            esac
            ;;
        SECURITY)
            case "$lang" in
                EN|MIXED)
                    if echo "$input_lower" | grep -qE 'security audit|owasp|vulnerability'; then
                        ((score += 3))
                    elif echo "$input_lower" | grep -qE 'cwe|security check|penetration test'; then
                        ((score += 2))
                    elif echo "$input_lower" | grep -qE 'security scan|exploit check'; then
                        ((score += 1))
                    fi
                    ;;
            esac
            case "$lang" in
                ZH|MIXED)
                    if echo "$input_lower" | grep -qE '安全审计|漏洞扫描|owasp'; then
                        ((score += 3))
                    elif echo "$input_lower" | grep -qE '安全检查|渗透测试'; then
                        ((score += 2))
                    elif echo "$input_lower" | grep -qE '入侵|攻击'; then
                        ((score += 1))
                    fi
                    ;;
            esac
            ;;
        OPTIMIZE)
            case "$lang" in
                EN|MIXED)
                    if echo "$input_lower" | grep -qE 'optimize.*skill|improve.*skill|evolve.*skill'; then
                        ((score += 3))
                    elif echo "$input_lower" | grep -qE 'enhance.*skill|tune.*skill|refine.*skill'; then
                        ((score += 2))
                    elif echo "$input_lower" | grep -qE 'upgrade.*skill|performance'; then
                        ((score += 1))
                    fi
                    ;;
            esac
            case "$lang" in
                ZH|MIXED)
                    if echo "$input_lower" | grep -qE '优化|改进|进化'; then
                        ((score += 3))
                    elif echo "$input_lower" | grep -qE '提升|调优|完善'; then
                        ((score += 2))
                    elif echo "$input_lower" | grep -qE '增强|性能'; then
                        ((score += 1))
                    fi
                    ;;
            esac
            ;;
    esac

    echo "$score"
}

score_secondary_keywords() {
    local input="$1"
    local lang="$2"
    local mode="$3"

    input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    local score=0

    case "$mode" in
        CREATE)
            if echo "$input_lower" | grep -qE '"generate"|"template"|"starter"|"boilerplate"'; then
                ((score += 1))
            fi
            if echo "$input_lower" | grep -qE '模板|起始框架|脚手架'; then
                ((score += 1))
            fi
            ;;
        EVALUATE)
            if echo "$input_lower" | grep -qE '"compare"|"grade"|"rate"|"measure"'; then
                ((score += 1))
            fi
            if echo "$input_lower" | grep -qE '比较|评级|打分'; then
                ((score += 1))
            fi
            ;;
        RESTORE)
            if echo "$input_lower" | grep -qE '"broken"|"corrupt"|"invalid"|"damage"'; then
                ((score += 1))
            fi
            if echo "$input_lower" | grep -qE '损坏|破坏|崩溃'; then
                ((score += 1))
            fi
            ;;
        SECURITY)
            if echo "$input_lower" | grep -qE '"injection"|"xss"|"csrf"|"breach"'; then
                ((score += 1))
            fi
            if echo "$input_lower" | grep -qE '注入|跨站|攻击'; then
                ((score += 1))
            fi
            ;;
        OPTIMIZE)
            if echo "$input_lower" | grep -qE '"speed"|"efficiency"|"refactor"|"dry"'; then
                ((score += 1))
            fi
            if echo "$input_lower" | grep -qE '速度|效率|重构'; then
                ((score += 1))
            fi
            ;;
    esac

    echo "$score"
}

check_negative_patterns() {
    local input="$1"
    local mode="$3"

    input_lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    local is_negative=0

    case "$mode" in
        CREATE)
            if echo "$input_lower" | grep -qE '"don'"'"'t create"|"skill exists"|"check if exists"'; then
                is_negative=1
            fi
            if echo "$input_lower" | grep -qE '不要创建|技能已存在'; then
                is_negative=1
            fi
            ;;
        EVALUATE)
            if echo "$input_lower" | grep -qE '"evaluate code"|"test function"|"lint"'; then
                is_negative=1
            fi
            if echo "$input_lower" | grep -qE '评估代码|测试函数'; then
                is_negative=1
            fi
            ;;
        RESTORE)
            if echo "$input_lower" | grep -qE '"restore file"|"recover data"'; then
                is_negative=1
            fi
            if echo "$input_lower" | grep -qE '恢复文件|恢复数据'; then
                is_negative=1
            fi
            ;;
        SECURITY)
            if echo "$input_lower" | grep -qE '"secure password"|"encrypt data"'; then
                is_negative=1
            fi
            if echo "$input_lower" | grep -qE '加密密码|保护数据'; then
                is_negative=1
            fi
            ;;
        OPTIMIZE)
            if echo "$input_lower" | grep -qE '"optimize algorithm"|"speed up"'; then
                is_negative=1
            fi
            if echo "$input_lower" | grep -qE '优化算法|加速'; then
                is_negative=1
            fi
            ;;
    esac

    echo "$is_negative"
}

calculate_confidence() {
    local primary="$1"
    local secondary="$2"
    local context="$3"
    local no_negative="$4"

    local confidence
    confidence=$(echo "scale=4; $primary * 0.5 + $secondary * 0.2 + $context * 0.2 + $no_negative * 0.1" | bc)
    echo "$confidence"
}

detect_intent() {
    local input="$1"

    if [[ -z "$input" ]]; then
        echo "EVALUATE:0.30"
        return 0
    fi

    local lang
    lang=$(detect_language "$input")

    local modes="CREATE EVALUATE RESTORE SECURITY OPTIMIZE"
    local best_mode="EVALUATE"
    local best_score=0
    local best_confidence="0.30"

    for mode in $modes; do
        local primary secondary context negative confidence

        primary=$(score_primary_keywords "$input" "$lang" "$mode")
        secondary=$(score_secondary_keywords "$input" "$lang" "$mode")
        context=$(score_secondary_keywords "$input" "$lang" "$mode")
        negative=$(check_negative_patterns "$input" "$lang" "$mode")

        if [[ $negative -eq 1 ]]; then
            confidence="0.00"
        else
            local no_negative_weight=1
            confidence=$(calculate_confidence "$primary" "$secondary" "$context" "$no_negative_weight")
        fi

        local current_score
        current_score=$(echo "$confidence * 10 + ${primary} > $best_score" | bc -l)
        if [[ $current_score -eq 1 ]]; then
            best_mode="$mode"
            best_score=$(echo "$confidence * 10 + ${primary}" | bc)
            best_confidence="$confidence"
        fi
    done

    local threshold_check
    threshold_check=$(echo "$best_confidence >= 0.80" | bc -l)
    if [[ $threshold_check -eq 1 ]]; then
        echo "${best_mode}:${best_confidence}"
        return 0
    fi

    threshold_check=$(echo "$best_confidence >= 0.60" | bc -l)
    if [[ $threshold_check -eq 1 ]]; then
        echo "${best_mode}:${best_confidence}"
        return 0
    fi

    threshold_check=$(echo "$best_confidence < 0.60" | bc -l)
    if [[ $threshold_check -eq 1 ]]; then
        if [[ $(echo "$best_confidence <= 0.30" | bc -l) -eq 1 ]]; then
            echo "EVALUATE:0.30"
            return 0
        fi
        echo "ASK:${best_mode}:${best_confidence}"
        return 0
    fi

    echo "EVALUATE:0.30"
    return 0
}

get_detected_mode() {
    local result="$1"
    echo "$result" | cut -d: -f1
}

get_confidence() {
    local result="$1"
    echo "$result" | cut -d: -f2
}

is_ambiguous() {
    local result="$1"
    local mode
    mode=$(echo "$result" | cut -d: -f1)
    [[ "$mode" == "ASK" ]]
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <user_prompt>"
        echo "Detects intent mode from user prompt"
        exit 1
    fi

    detect_intent "$1"
fi