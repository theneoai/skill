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

show_usage() {
    cat <<EOF
Usage: $(basename "$0") <skill_file> [level]

Options:
    skill_file    Path to SKILL.md file (required)
    level        Audit level: BASIC, FULL (default: FULL)

Examples:
    $(basename "$0") ./SKILL.md
    $(basename "$0") ./SKILL.md FULL
EOF
}

main() {
    if [[ $# -lt 1 ]]; then
        show_usage
        exit 1
    fi

    local skill_file="$1"
    local level="${2:-FULL}"

    if [[ ! -f "$skill_file" ]]; then
        echo "Error: Skill file not found: $skill_file" >&2
        exit 1
    fi

    "${PROJECT_ROOT}/engine/agents/security.sh" "$skill_file" "$level"
}

main "$@"
