#!/usr/bin/env bash
# skill-maintenance.sh - Unified skill maintenance script
#
# This script provides a unified interface for skill maintenance operations
# including restore, optimize, and auto modes.
#
# Usage: ./scripts/skill-maintenance.sh <mode> <skill_file> [options]
#
# Modes:
#   --restore   Restore a broken skill file
#   --optimize Optimize/evolve a skill file
#   --auto     Automatically determine and run appropriate maintenance
#
# Examples:
#   ./scripts/skill-maintenance.sh --restore ./broken-skill.md
#   ./scripts/skill-maintenance.sh --optimize ./SKILL.md
#   ./scripts/skill-maintenance.sh --optimize ./SKILL.md --rounds 20
#   ./scripts/skill-maintenance.sh --auto ./SKILL.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

show_usage() {
    cat <<EOF
Usage: $(basename "$0") <mode> <skill_file> [options]

Modes:
  --restore   Restore a broken skill file
  --optimize Optimize/evolve a skill file
  --auto     Automatically determine and run appropriate maintenance

Options:
  -r, --rounds  Maximum optimization rounds (default: 20, for --optimize/--auto only)
  -h, --help   Show this help

Examples:
  $(basename "$0") --restore ./broken-skill.md
  $(basename "$0") --optimize ./SKILL.md
  $(basename "$0") --optimize ./SKILL.md --rounds 20
  $(basename "$0") --auto ./SKILL.md
EOF
}

validate_skill_file() {
    local skill_file="$1"
    if [[ ! -f "$skill_file" ]]; then
        echo "Error: Skill file not found: $skill_file" >&2
        exit 1
    fi
}

mode_restore() {
    local skill_file="$1"
    validate_skill_file "$skill_file"
    source "${PROJECT_ROOT}/tools/lib/bootstrap.sh"
    "${PROJECT_ROOT}/tools/agents/restore.sh" "$skill_file"
}

mode_optimize() {
    local skill_file="$1"
    local max_rounds="$2"
    validate_skill_file "$skill_file"
    source "${PROJECT_ROOT}/tools/lib/bootstrap.sh"
    require concurrency
    acquire_lock "optimize" 60 || {
        echo "Error: Failed to acquire lock. Another optimization may be running." >&2
        exit 1
    }
    trap "release_lock 'optimize'" EXIT
    "${PROJECT_ROOT}/engine/evolution/engine.sh" "$skill_file" "$max_rounds"
}

mode_auto() {
    local skill_file="$1"
    local max_rounds="$2"
    validate_skill_file "$skill_file"
    echo "Auto mode: checking skill health..." >&2
    source "${PROJECT_ROOT}/tools/lib/bootstrap.sh"
    if "${PROJECT_ROOT}/tools/agents/check-health.sh" "$skill_file" 2>/dev/null; then
        echo "Skill is healthy, running optimization..." >&2
        mode_optimize "$skill_file" "$max_rounds"
    else
        echo "Skill needs restoration..." >&2
        mode_restore "$skill_file"
        echo "Restoration complete, running optimization..." >&2
        mode_optimize "$skill_file" "$max_rounds"
    fi
}

main() {
    local mode=""
    local skill_file=""
    local max_rounds="20"

    if [[ $# -lt 2 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_usage
        exit 0
    fi

    mode="$1"
    shift

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|--rounds)
                [[ -z "${2:-}" ]] && { echo "Error: --rounds requires a value" >&2; exit 1; }
                max_rounds="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                echo "Error: Unknown option: $1" >&2
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$skill_file" ]]; then
                    skill_file="$1"
                else
                    echo "Error: Unexpected argument: $1" >&2
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$skill_file" ]]; then
        echo "Error: skill_file is required" >&2
        show_usage
        exit 1
    fi

    case "$mode" in
        --restore)
            mode_restore "$skill_file"
            ;;
        --optimize)
            mode_optimize "$skill_file" "$max_rounds"
            ;;
        --auto)
            mode_auto "$skill_file" "$max_rounds"
            ;;
        *)
            echo "Error: Invalid mode: $mode" >&2
            echo "Valid modes: --restore, --optimize, --auto" >&2
            show_usage
            exit 1
            ;;
    esac
}

main "$@"