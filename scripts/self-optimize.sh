#!/usr/bin/env bash
# self-optimize.sh — Trigger script for AI-driven skill optimization
# Usage: echo "自优化 SKILL.md" | self-optimize.sh
#        echo "self-optimize skill" | self-optimize.sh
#
# Note: This script is deprecated. Use engine/evolution/engine.sh for optimization.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVAL_DIR="$(cd "$SCRIPT_DIR/../eval" && pwd)"

read -r input

if [[ "$input" =~ ^(自优化|self-optimize)\s+(.+)$ ]]; then
    target="${BASH_REMATCH[2]}"
    target="${target%"${target##*[![:space:]]}"}"

    if [[ "$target" == */SKILL.md || "$target" == SKILL.md ]]; then
        skill_path="$target"
    else
        skill_path="$target/SKILL.md"
    fi

    if [[ ! -f "$skill_path" ]]; then
        echo "Error: Skill file not found: $skill_path"
        exit 1
    fi

    echo "Triggering evaluation: $skill_path"
    echo "Run './eval/main.sh --skill $skill_path --fast' for quick evaluation"
    echo "Run './eval/main.sh --skill $skill_path --full' for full evaluation"
    
    "$EVAL_DIR/main.sh" --skill "$skill_path" --fast
else
    echo "Usage: echo \"自优化 SKILL.md\" | $0"
    echo "       echo \"self-optimize skill\" | $0"
    exit 1
fi
