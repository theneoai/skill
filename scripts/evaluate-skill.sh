#!/usr/bin/env bash
# evaluate-skill.sh - Evaluate a skill
#
# Usage: ./scripts/evaluate-skill.sh <skill_file> [mode]
#
# Examples:
#   ./scripts/evaluate-skill.sh ./SKILL.md
#   ./scripts/evaluate-skill.sh ./SKILL.md fast
#   ./scripts/evaluate-skill.sh ./SKILL.md full

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

show_usage() {
    cat <<EOF
Usage: $(basename "$0") <skill_file> [mode]

Options:
    skill_file    Path to SKILL.md file (required)
    mode         Evaluation mode: fast, full (default: fast)

Examples:
    $(basename "$0") ./SKILL.md
    $(basename "$0") ./SKILL.md fast
    $(basename "$0") ./SKILL.md full
EOF
}

main() {
    if [[ $# -lt 1 ]]; then
        show_usage
        exit 1
    fi

    local skill_file="$1"
    local mode="${2:-fast}"

    if [[ ! -f "$skill_file" ]]; then
        echo "Error: Skill file not found: $skill_file" >&2
        exit 1
    fi

    skill_file="$(cd "$(dirname "$skill_file")" && pwd)/$(basename "$skill_file")"

    cd "${PROJECT_ROOT}/eval"
    ./main.sh --skill "$skill_file" --${mode}
}

main "$@"
