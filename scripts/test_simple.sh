#!/usr/bin/env bash
# real_user_simulation.sh - 真实用户模拟测试 (修复版)

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EVAL_DIR="$PROJECT_ROOT"

source "$PROJECT_ROOT/tools/lib/bootstrap.sh" || true
require constants 2>/dev/null || true

echo "========================================"
echo "  真实用户模拟测试"
echo "========================================"

declare -a BUGS_FOUND=()
BUG_COUNT=0

record_bug() {
    local workflow="${1:-UNKNOWN}"
    local test_name="${2:-UNKNOWN}"
    local description="${3:-UNKNOWN}"
    local severity="${4:-UNKNOWN}"
    local evidence="${5:-NONE}"
    
    BUG_COUNT=$((BUG_COUNT + 1))
    BUGS_FOUND+=("【$severity】[$workflow] $test_name: $description")
    
    echo ""
    echo "🐛 BUG #$BUG_COUNT 发现!"
    echo "   工作流: $workflow"
    echo "   测试: $test_name"
    echo "   严重性: $severity"
    echo "   描述: $description"
    if [[ "$evidence" != "NONE" ]]; then
        echo "   证据: $evidence"
    fi
    echo ""
}

echo "[测试 1] cli/skill --help..."
output=$(bash "$PROJECT_ROOT/cli/skill" --help 2>&1 || true)
exit_code=$?
echo "   输出: $output"
echo "   退出码: $exit_code"

if echo "$output" | grep -qi "Usage\|用法"; then
    echo "   结果: PASS - 显示了帮助信息"
else
    record_bug "CLI" "cli_help" "cli/skill --help未显示帮助" "HIGH" "$output"
fi

echo ""
echo "[测试 2] lean-orchestrator.sh --help..."
output=$(bash "$PROJECT_ROOT/scripts/lean-orchestrator.sh" --help 2>&1 || true)
echo "   输出: $output"

if echo "$output" | grep -qi "Usage\|用法"; then
    echo "   结果: PASS - 显示了帮助信息"
else
    record_bug "LEAN" "help_flag" "--help未显示帮助" "HIGH" "$output"
fi

echo ""
echo "========================================"
echo "  测试汇总"
echo "========================================"
echo ""
echo "总共发现 $BUG_COUNT 个问题:"
for bug in "${BUGS_FOUND[@]}"; do
    echo "$bug"
done

if [[ $BUG_COUNT -eq 0 ]]; then
    echo "✅ 所有测试通过!"
    exit 0
else
    echo "❌ 发现 $BUG_COUNT 个问题"
    exit 1
fi