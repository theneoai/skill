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
Usage: $(basename "$0") "skill description" [options] [output_path] [tier]

Options:
    -e, --extends PARENT   Inherit from parent skill (optional)
    -t, --tier TIER        Target tier: GOLD, SILVER, BRONZE (default: BRONZE)
    -h, --help             Show this help

Examples:
    $(basename "$0") "Create a code review skill"
    $(basename "$0") "Create a code review skill" --extends skill
    $(basename "$0") "Create a code review skill" -e skill ./my-skill.md GOLD
EOF
}

main() {
    if [[ $# -lt 1 ]]; then
        show_usage
        exit 1
    fi
    
    local description=""
    local output_path=""
    local tier="BRONZE"
    local parent_skill=""
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --extends|-e)
                [[ -z "${2:-}" ]] && { echo "Error: --extends requires a value"; exit 1; }
                [[ "$2" =~ ^- ]] && { echo "Error: --extends requires a value, got $2"; exit 1; }
                parent_skill="$2"
                shift 2
                ;;
            --tier|-t)
                [[ -z "${2:-}" ]] && { echo "Error: --tier requires a value"; exit 1; }
                [[ "$2" =~ ^- ]] && { echo "Error: --tier requires a value, got $2"; exit 1; }
                tier="$2"
                shift 2
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            -*)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$description" ]]; then
                    description="$1"
                elif [[ -z "$output_path" ]]; then
                    output_path="$1"
                else
                    tier="$1"
                fi
                shift
                ;;
        esac
    done
    
    if [[ -z "$description" ]]; then
        echo "Error: description required"
        show_usage
        exit 1
    fi
    
    local skill_name
    skill_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]+/-/g' | sed 's/^-//;s/-$//')
    
    if [[ -z "$skill_name" ]]; then
        echo "Error: Could not generate valid skill name from description"
        exit 1
    fi
    
    if [[ -z "$output_path" ]]; then
        output_path="${PROJECT_ROOT}/${skill_name}.md"
    fi
    
    echo "Creating skill: $skill_name"
    echo "Target tier: $tier"
    echo "Output: $output_path"
    [[ -n "$parent_skill" ]] && echo "Parent skill: $parent_skill"
    echo ""
    
    # 传递 parent_skill 给 orchestrator
    export PROJECT_ROOT
    PARENT_SKILL="$parent_skill" TARGET_TIER="$tier" "${PROJECT_ROOT}/engine/orchestrator.sh" "$description" "$output_path"
    
    echo ""
    echo "Skill created: $output_path"
}

main "$@"
