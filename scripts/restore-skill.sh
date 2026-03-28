#!/usr/bin/env bash
# restore-skill.sh - Restore a broken skill
#
# Usage: ./scripts/restore-skill.sh <skill_file>
#
# Examples:
#   ./scripts/restore-skill.sh ./broken-skill.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

show_usage() {
    cat <<EOF
Usage: $(basename "$0") <skill_file>

Options:
    skill_file    Path to SKILL.md file (required)

Examples:
    $(basename "$0") ./broken-skill.md
EOF
}

main() {
    if [[ $# -lt 1 ]]; then
        show_usage
        exit 1
    fi

    local skill_file="$1"

    if [[ ! -f "$skill_file" ]]; then
        echo "Error: Skill file not found: $skill_file" >&2
        exit 1
    fi

    "${PROJECT_ROOT}/engine/agents/restorer.sh" "$skill_file"
}

main "$@"
