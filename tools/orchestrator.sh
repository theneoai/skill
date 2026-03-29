#!/usr/bin/env bash
# orchestrator.sh - 双Agent协调器
#
# 使用模块化结构:
#   _state.sh     - 状态管理
#   _workflow.sh  - 工作流控制
#   _actions.sh  - 操作决策
#   _parallel.sh  - 并行执行

# Resolve symlinks to get actual script directory
resolve_script_dir() {
    local source="${BASH_SOURCE[0]}"
    local target_dir="$(dirname "$source")"
    while [[ -L "$source" ]]; do
        local link="$(readlink "$source")"
        if [[ "$link" = /* ]]; then
            source="$link"
        else
            source="$target_dir/$link"
        fi
        target_dir="$(dirname "$source")"
    done
    dirname "$source"
}

SCRIPT_DIR="$(resolve_script_dir)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/lib/bootstrap.sh"
source "$SCRIPT_DIR/orchestrator/state.sh"
source "$SCRIPT_DIR/orchestrator/workflow.sh"
source "$SCRIPT_DIR/orchestrator/actions.sh"
source "$SCRIPT_DIR/orchestrator/parallel.sh"

# ============================================================================
# 主入口
# ============================================================================

orchestrate() {
    local user_prompt="$1"
    local output_file="$2"
    local parent_skill="${PARENT_SKILL:-}"
    
    local parent_skill_path=""
    
    if [[ -n "$parent_skill" ]]; then
        if [[ -z "$PROJECT_ROOT" ]]; then
            echo "ERROR: PROJECT_ROOT must be set" >&2
            return 1
        fi

        if [[ "$PARENT_SKILL" == *".md"* ]]; then
            parent_skill_path="$PARENT_SKILL"
        else
            parent_skill_path="${PROJECT_ROOT}/${PARENT_SKILL}.md"
        fi

        if [[ ! -f "$parent_skill_path" ]]; then
            echo "ERROR: Parent skill not found: $parent_skill_path" >&2
            return 1
        fi

        echo "Using parent skill: $parent_skill_path"
    fi
    
    workflow_init "$user_prompt" "$output_file" "$parent_skill_path" || return 1
    workflow_run || return 1
}

# ============================================================================
# CLI 接口
# ============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <user_prompt> <output_file> [target_tier]"
        echo "  user_prompt   - Description of the skill to create"
        echo "  output_file   - Path to output SKILL.md file"
        echo "  target_tier   - Target tier (GOLD/SILVER/BRONZE, default: BRONZE)"
        exit 1
    fi
    
    if [[ -n "${3:-}" ]]; then
        TARGET_TIER="$3"
    fi
    
    orchestrate "$1" "$2"
fi