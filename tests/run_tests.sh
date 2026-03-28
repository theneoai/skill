#!/usr/bin/env bash
# run_tests.sh - Run all tests
#
# Usage: ./tests/run_tests.sh [test_type]
#
# Examples:
#   ./tests/run_tests.sh           # Run all tests
#   ./tests/run_tests.sh unit      # Run unit tests only
#   ./tests/run_tests.sh integration  # Run integration tests only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

show_usage() {
    cat <<EOF
Usage: $(basename "$0") [test_type]

Options:
    test_type    Type of tests: unit, integration, all (default: all)

Examples:
    $(basename "$0")         # Run all tests
    $(basename "$0") unit    # Run unit tests only
EOF
}

run_unit_tests() {
    echo "=== Running Unit Tests ==="
    if [[ -f "${SCRIPT_DIR}/unit/run_tests.sh" ]]; then
        bash "${SCRIPT_DIR}/unit/run_tests.sh"
    else
        echo "No unit tests found"
    fi
}

run_integration_tests() {
    echo "=== Running Integration Tests ==="
    
    echo "--- Testing Create Workflow ---"
    if [[ -f "${PROJECT_ROOT}/SKILL.md" ]]; then
        bash "${PROJECT_ROOT}/scripts/evaluate-skill.sh" "${PROJECT_ROOT}/SKILL.md" fast || true
    fi

    echo "--- Testing Quick Score ---"
    if [[ -f "${PROJECT_ROOT}/SKILL.md" ]]; then
        bash "${PROJECT_ROOT}/scripts/quick-score.sh" "${PROJECT_ROOT}/SKILL.md" || true
    fi

    echo "--- Testing Parse Validation ---"
    if [[ -f "${PROJECT_ROOT}/SKILL.md" ]]; then
        bash "${PROJECT_ROOT}/eval/parse/parse_validate.sh" "${PROJECT_ROOT}/SKILL.md" || true
    fi

    echo "=== Integration Tests Complete ==="
}

main() {
    local test_type="${1:-all}"

    cd "$PROJECT_ROOT"

    case "$test_type" in
        unit)
            run_unit_tests
            ;;
        integration)
            run_integration_tests
            ;;
        all)
            run_unit_tests
            echo ""
            run_integration_tests
            ;;
        *)
            echo "Unknown test type: $test_type"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
