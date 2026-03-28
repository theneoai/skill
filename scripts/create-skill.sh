#!/usr/bin/env bash
# create-skill.sh - Create a new skill
#
# Usage: ./scripts/create-skill.sh "skill description" [output_path] [tier]
#
# Examples:
#   ./scripts/create-skill.sh "Create a code review skill"
#   ./scripts/create-skill.sh "Create a code review skill" ./my-skill.md GOLD
#   ./scripts/create-skill.sh "Create a code review skill" "" SILVER

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "${PROJECT_ROOT}/engine/lib/bootstrap.sh"

show_usage() {
    cat <<EOF
Usage: $(basename "$0") "skill description" [output_path] [tier]

Options:
    description    Skill description (required)
    output_path   Output file path (default: ./[derived-name].md)
    tier          Target tier: GOLD, SILVER, BRONZE (default: BRONZE)

Examples:
    $(basename "$0") "Create a code review skill"
    $(basename "$0") "Create a code review skill" ./my-skill.md GOLD
EOF
}

main() {
    if [[ $# -lt 1 ]]; then
        show_usage
        exit 1
    fi

    local description="$1"
    local output_path="${2:-}"
    local tier="${3:-BRONZE}"

    local skill_name
    skill_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]+/-/g' | sed 's/^-//;s/-$//')

    if [[ -z "$output_path" ]]; then
        output_path="${PROJECT_ROOT}/${skill_name}.md"
    fi

    echo "Creating skill: $skill_name"
    echo "Target tier: $tier"
    echo "Output: $output_path"
    echo ""

    TARGET_TIER="$tier" "${PROJECT_ROOT}/engine/orchestrator.sh" "$description" "$output_path"

    echo ""
    echo "Skill created: $output_path"
}

main "$@"
