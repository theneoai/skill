#!/usr/bin/env bash
# reference-loader.sh - 按需加载 SKILL.md 详细参考文档
#
# 用法:
#   source reference-loader.sh
#   load_reference triggers    # 加载触发模式详情
#   load_reference workflows  # 加载工作流详情
#   load_reference tools      # 加载工具文档

REFERENCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_REF="${REFERENCE_DIR}/skill_reference.sh"

load_reference() {
    local ref_name="$1"
    case "$ref_name" in
        triggers)
            cat "${REFERENCE_DIR}/triggers.md"
            ;;
        workflows)
            cat "${REFERENCE_DIR}/workflows.md"
            ;;
        tools)
            cat "${REFERENCE_DIR}/tools.md"
            ;;
        all)
            echo "=== TRIGGERS ===" && cat "${REFERENCE_DIR}/triggers.md"
            echo ""
            echo "=== WORKFLOWS ===" && cat "${REFERENCE_DIR}/workflows.md"
            echo ""
            echo "=== TOOLS ===" && cat "${REFERENCE_DIR}/tools.md"
            ;;
        *)
            echo "Unknown reference: $ref_name" >&2
            echo "Available: triggers, workflows, tools, all" >&2
            return 1
            ;;
    esac
}

get_reference_path() {
    local ref_name="$1"
    case "$ref_name" in
        triggers) echo "${REFERENCE_DIR}/triggers.md" ;;
        workflows) echo "${REFERENCE_DIR}/workflows.md" ;;
        tools) echo "${REFERENCE_DIR}/tools.md" ;;
        *) return 1 ;;
    esac
}

list_references() {
    echo "Available references:"
    for f in "${REFERENCE_DIR}"/*.md; do
        local name
        name=$(basename "$f" .md)
        local lines
        lines=$(wc -l < "$f")
        echo "  - $name ($lines lines)"
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Reference Loader v1.0"
    echo ""
    echo "Usage: source reference-loader.sh && load_reference <name>"
    echo ""
    list_references
fi
