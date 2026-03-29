#!/usr/bin/env bash
# security-audit.sh - Security audit for a skill
#
# Usage: ./scripts/security-audit.sh <skill_file> [level]
#
# Examples:
#   ./scripts/security-audit.sh ./SKILL.md
#   ./scripts/security-audit.sh ./SKILL.md FULL

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "${PROJECT_ROOT}/tools/lib/bootstrap.sh"

show_usage() {
    cat <<EOF
Usage: $(basename "$0") <skill_file> [options]

Options:
    skill_file    Path to SKILL.md file (required)
    -l, --level  Audit level: BASIC, FULL (default: FULL)
    -h, --help   Show this help

Examples:
    $(basename "$0") ./SKILL.md
    $(basename "$0") ./SKILL.md FULL
    $(basename "$0") ./SKILL.md --level BASIC
EOF
}

main() {
    if [[ $# -lt 1 ]] || [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_usage
        exit 0
    fi

    local skill_file=""
    local level="FULL"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--level)
                [[ -z "${2:-}" ]] && { echo "Error: --level requires a value"; exit 1; }
                level="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$skill_file" ]]; then
                    skill_file="$1"
                else
                    level="$1"
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$skill_file" ]]; then
        echo "Error: skill_file required"
        show_usage
        exit 1
    fi

    if [[ ! -f "$skill_file" ]]; then
        echo "Error: Skill file not found: $skill_file" >&2
        exit 1
    fi

    "${PROJECT_ROOT}/engine/agents/security.sh" "$skill_file" "$level"
}

main "$@"
