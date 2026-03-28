#!/usr/bin/env bash
# skill_reference.sh - SKILL.md 参考文档索引
#
# 提供函数获取特定章节的详细内容

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REF_DIR="$(dirname "$SCRIPT_DIR")"

get_section_content() {
    local section="$1"
    case "$section" in
        triggers|trigger-patterns)
            cat "${REF_DIR}/reference/triggers.md"
            ;;
        workflows|process-modes)
            cat "${REF_DIR}/reference/workflows.md"
            ;;
        tools|tool-set)
            cat "${REF_DIR}/reference/tools.md"
            ;;
        all)
            echo "SKILL.md Progressive Disclosure Index"
            echo "======================================"
            echo ""
            list_sections
            ;;
        *)
            echo "Unknown section: $section" >&2
            list_sections >&2
            return 1
            ;;
    esac
}

list_sections() {
    echo "Available sections:"
    echo "  - triggers (reference/triggers.md)"
    echo "  - workflows (reference/workflows.md)"
    echo "  - tools (reference/tools.md)"
    echo ""
    echo "Usage: get_section_content <section_name>"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    get_section_content "${1:-all}"
fi
