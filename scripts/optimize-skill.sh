#!/usr/bin/env bash
# optimize-skill.sh - Optimize/evolve a skill
#
# Usage: ./scripts/optimize-skill.sh <skill_file> [max_rounds]
#
# Examples:
#   ./scripts/optimize-skill.sh ./SKILL.md
#   ./scripts/optimize-skill.sh ./SKILL.md 20

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

show_usage() {
    cat <<EOF
Usage: $(basename "$0") <skill_file> [max_rounds]

Options:
    skill_file    Path to SKILL.md file (required)
    max_rounds   Maximum optimization rounds (default: 20)

Examples:
    $(basename "$0") ./SKILL.md
    $(basename "$0") ./SKILL.md 20
EOF
}

main() {
    if [[ $# -lt 1 ]]; then
        show_usage
        exit 1
    fi

    local skill_file="$1"
    local max_rounds="${2:-20}"

    if [[ ! -f "$skill_file" ]]; then
        echo "Error: Skill file not found: $skill_file" >&2
        exit 1
    fi

    source "${PROJECT_ROOT}/engine/lib/bootstrap.sh"
    acquire_lock "optimize" 60 || {
        echo "Error: Failed to acquire lock. Another optimization may be running."
        exit 1
    }

    trap "release_lock 'optimize'" EXIT

    "${PROJECT_ROOT}/engine/evolution/engine.sh" "$skill_file" "$max_rounds"
}

main "$@"
