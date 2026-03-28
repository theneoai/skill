#!/usr/bin/env bash
# quick-score.sh - Quick text scoring without LLM
#
# Usage: ./scripts/quick-score.sh <skill_file>
#
# Examples:
#   ./scripts/quick-score.sh ./SKILL.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

show_usage() {
    cat <<EOF
Usage: $(basename "$0") <skill_file>

Options:
    skill_file    Path to SKILL.md file (required)

Examples:
    $(basename "$0") ./SKILL.md
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

    skill_file="$(cd "$(dirname "$skill_file")" && pwd)/$(basename "$skill_file")"

    cd "${PROJECT_ROOT}/eval"
    ./scorer/text_scorer.sh "$skill_file"
}

main "$@"
