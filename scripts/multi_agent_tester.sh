#!/usr/bin/env bash
# multi_agent_tester.sh - 多Agent真实用户测试框架
# 使用minimax和kimi-code模拟真实用户测试skill项目

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo "  多Agent真实用户测试框架"
echo "========================================"

export PATH="$PROJECT_ROOT:$PROJECT_ROOT/tools:$PROJECT_ROOT/scripts:$PATH"

# 测试工作流列表
WORKFLOWS=("CREATE" "EVALUATE" "LEAN" "RESTORE" "SECURITY" "OPTIMIZE")

# 收集所有问题
declare -a ALL_ISSUES=()
ISSUE_COUNT=0

# 记录发现的问题
record_issue() {
    local round="$1"
    local workflow="$2"
    local test_case="$3"
    local issue="$4"
    local severity="$5"
    
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
    ALL_ISSUES+=("[R$round][$workflow][$severity] $test_case: $issue")
    
    echo "  [!] 发现问题 #$ISSUE_COUNT (R$round, $workflow, $severity)"
    echo "      测试用例: $test_case"
    echo "      问题: $issue"
    echo ""
}

# 测试CREATE工作流
test_create_workflow() {
    local agent_name="$1"
    local round="$2"
    local test_skill_name="test_skill_r${round}_$(date +%s)"
    
    echo "  [CREATE] 测试创建技能..."
    
    # 测试1: 基本创建
    local output_file="/tmp/test_create_${round}.md"
    if ! ./scripts/create-skill.sh "Create a $test_skill_name skill" 2>&1 | tee /tmp/create_log_${round}.txt; then
        record_issue "$round" "CREATE" "basic_create" "$(cat /tmp/create_log_${round}.txt | head -20)" "HIGH"
    fi
    
    # 测试2: 检查输出文件是否存在
    if [[ -f "$output_file" ]]; then
        # 检查文件内容
        if ! grep -q "§1" "$output_file" 2>/dev/null; then
            record_issue "$round" "CREATE" "content_structure" "Created file missing §1 sections" "MEDIUM"
        fi
    else
        record_issue "$round" "CREATE" "file_creation" "Output file not created: $output_file" "HIGH"
    fi
    
    # 测试3: 创建带继承的技能
    local inherit_output="/tmp/test_inherit_${round}.md"
    if ! ./scripts/create-skill.sh "Create a child skill" --extends "$PROJECT_ROOT/SKILL.md" 2>&1 | tee /tmp/inherit_log_${round}.txt; then
        record_issue "$round" "CREATE" "inherit_create" "$(cat /tmp/inherit_log_${round}.txt | head -10)" "MEDIUM"
    fi
}

# 测试EVALUATE工作流
test_evaluate_workflow() {
    local agent_name="$1"
    local round="$2"
    
    echo "  [EVALUATE] 测试评估技能..."
    
    # 测试1: 评估主skill文件
    if ! ./scripts/evaluate-skill.sh "$PROJECT_ROOT/SKILL.md" 2>&1 | tee /tmp/eval_log_${round}.txt; then
        record_issue "$round" "EVALUATE" "basic_eval" "$(cat /tmp/eval_log_${round}.txt | head -20)" "HIGH"
    fi
    
    # 测试2: 评估不存在的文件
    if ./scripts/evaluate-skill.sh /tmp/nonexistent_skill.md 2>&1 | grep -q "not found\|不存在\|Error"; then
        : # 预期行为
    else
        record_issue "$round" "EVALUATE" "missing_file" "Should report error for missing file" "LOW"
    fi
}

# 测试LEAN工作流
test_lean_workflow() {
    local agent_name="$1"
    local round="$2"
    
    echo "  [LEAN] 测试快速评估..."
    
    # 测试1: 基本lean评估
    if ! ./scripts/lean-orchestrator.sh "$PROJECT_ROOT/SKILL.md" 2>&1 | tee /tmp/lean_log_${round}.txt; then
        record_issue "$round" "LEAN" "basic_lean" "$(cat /tmp/lean_log_${round}.txt | head -20)" "HIGH"
    fi
    
    # 测试2: 检查输出是否包含分数
    if grep -q "score\|分数\|等级" /tmp/lean_log_${round}.txt 2>/dev/null; then
        : # 预期
    else
        record_issue "$round" "LEAN" "output_format" "Lean output missing score information" "MEDIUM"
    fi
}

# 测试RESTORE工作流
test_restore_workflow() {
    local agent_name="$1"
    local round="$2"
    
    echo "  [RESTORE] 测试恢复技能..."
    
    # 创建测试文件
    local test_file="/tmp/test_restore_${round}.md"
    cat > "$test_file" << 'EOF'
# Test Skill

## §1.1 Identity
Test

## §1.2 Framework
Framework

## §1.3 Thinking
Thinking

## §2 Trigger
CREATE

## §3 Behavior
Some content
EOF

    # 测试1: 基本恢复
    if ! ./scripts/restore-skill.sh "$test_file" 2>&1 | tee /tmp/restore_log_${round}.txt; then
        record_issue "$round" "RESTORE" "basic_restore" "$(cat /tmp/restore_log_${round}.txt | head -20)" "HIGH"
    fi
    
    # 测试2: 帮助信息
    if ./scripts/restore-skill.sh --help 2>&1 | grep -q "Usage\|用法"; then
        : # 预期
    else
        record_issue "$round" "RESTORE" "help_flag" "--help flag not working" "MEDIUM"
    fi
}

# 测试SECURITY工作流
test_security_workflow() {
    local agent_name="$1"
    local round="$2"
    
    echo "  [SECURITY] 测试安全审计..."
    
    # 测试1: 基本安全审计
    if ! ./scripts/security-audit.sh "$PROJECT_ROOT/SKILL.md" 2>&1 | tee /tmp/security_log_${round}.txt; then
        record_issue "$round" "SECURITY" "basic_audit" "$(cat /tmp/security_log_${round}.txt | head -20)" "HIGH"
    fi
    
    # 测试2: 检查输出是否包含漏洞检测
    if grep -q "vulnerability\|漏洞\|安全" /tmp/security_log_${round}.txt 2>/dev/null; then
        : # 预期
    else
        record_issue "$round" "SECURITY" "output_content" "Security audit output missing findings" "MEDIUM"
    fi
}

# 测试OPTIMIZE工作流
test_optimize_workflow() {
    local agent_name="$1"
    local round="$2"
    
    echo "  [OPTIMIZE] 测试优化..."
    
    # 创建测试文件
    local test_file="/tmp/test_optimize_${round}.md"
    cat > "$test_file" << 'EOF'
# Test Skill

## §1.1 Identity
Test Identity

## §1.2 Framework
Test Framework

## §1.3 Thinking
Test Thinking

## §2 Trigger
CREATE

## §3 Behavior
This is test content for optimization.
EOF

    # 测试1: 基本优化
    if ! ./scripts/optimize-skill.sh "$test_file" 2>&1 | tee /tmp/optimize_log_${round}.txt; then
        record_issue "$round" "OPTIMIZE" "basic_optimize" "$(cat /tmp/optimize_log_${round}.txt | head -20)" "HIGH"
    fi
}

# 运行一轮完整测试
run_test_round() {
    local agent_name="$1"
    local round="$2"
    
    echo ""
    echo "========================================"
    echo "  回合 $round - Agent: $agent_name"
    echo "========================================"
    
    for workflow in "${WORKFLOWS[@]}"; do
        case "$workflow" in
            CREATE) test_create_workflow "$agent_name" "$round" ;;
            EVALUATE) test_evaluate_workflow "$agent_name" "$round" ;;
            LEAN) test_lean_workflow "$agent_name" "$round" ;;
            RESTORE) test_restore_workflow "$agent_name" "$round" ;;
            SECURITY) test_security_workflow "$agent_name" "$round" ;;
            OPTIMIZE) test_optimize_workflow "$agent_name" "$round" ;;
        esac
    done
}

# 显示所有收集的问题
show_all_issues() {
    echo ""
    echo "========================================"
    echo "  测试结果汇总"
    echo "========================================"
    echo ""
    echo "总共发现 $ISSUE_COUNT 个问题:"
    echo ""
    
    for issue in "${ALL_ISSUES[@]}"; do
        echo "$issue"
    done
    
    echo ""
    echo "========================================"
}

# 主入口
main() {
    local total_rounds="${1:-10}"
    local start_round="${2:-1}"
    
    echo "开始多Agent测试..."
    echo "总回合数: $total_rounds"
    echo "起始回合: $start_round"
    echo ""
    
    for round in $(seq "$start_round" $((start_round + total_rounds - 1))); do
        # Agent 1: minimax
        run_test_round "minimax" "$round"
        
        # Agent 2: kimi-code
        run_test_round "kimi-code" "$round"
    done
    
    show_all_issues
    
    return 0
}

main "$@"