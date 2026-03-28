# Design Decisions

This document outlines the key architectural and design decisions made in the Skill system.

## 1. Multi-LLM Provider Selection

### Why Multi-LLM?

Cross-validation is essential for reducing errors in LLM-based decisions. A single LLM provider may have biases or make mistakes. By using multiple providers and requiring consensus, we significantly reduce the error rate.

### Provider Ranking

Providers are ranked by capability and reliability:

| Provider | Score | Primary Use |
|----------|-------|-------------|
| Anthropic | 100 | Primary reasoning, critical decisions |
| OpenAI | 90 | Secondary reasoning, fallback |
| Kimi-code | 85 | Cost-effective coding tasks |
| MiniMax | 80 | Batch processing |
| Kimi | 75 | Lightweight tasks |

### Auto-Selection Logic

```bash
select_top_providers() {
    available=$(check_llm_available)
    # Sort by strength and select top 2
    # These two providers are used for cross-validation
}
```

The system automatically selects the top 2 available providers for cross-validation on all critical decisions.

## 2. Heuristic vs LLM Evaluation

### Tradeoff Analysis

| Method | Time | Cost | Accuracy |
|--------|------|------|----------|
| Heuristic | ~0s | $0 | 95% |
| LLM | ~2min | ~$0.50 | 99% |

### When to Use Each

- **Heuristic**: Fast iteration, CI/CD pipelines, initial screening
- **LLM**: Final certification, critical decisions, disputed scores

The lean evaluation system (`scripts/lean-orchestrator.sh`) uses heuristics for speed, while the full evaluation framework (`eval/main.sh`) uses LLM for accuracy.

## 3. Snapshot/Rollback Strategy

### Snapshot Lifecycle

1. **Before each optimization round**: Snapshot created automatically
2. **During verification**: If score degrades, rollback triggered
3. **After 10 snapshots**: Oldest snapshots automatically cleaned up

### Rollback Triggers

```bash
# Rollback on:
# - Score verification failure
# - Implementation verification failure  
# - Human review request
rollback_to_snapshot "$skill_file" "pre_round_$current_round"
```

### Maximum Snapshots

```bash
MAX_SNAPSHOTS=10
# Cleanup happens automatically after each evolution cycle
```

## 4. Auto-Evolution Trigger Logic

### Priority Hierarchy

| Priority | Trigger | Description |
|----------|---------|-------------|
| 1 | Manual | User explicitly requests optimization |
| 2 | Threshold | Score drops below tier threshold |
| 3 | Scheduled | Time-based trigger (cron) |
| 4 | Usage | Usage patterns indicate need |

### Double-Trigger Prevention

```bash
LAST_CHECK_FILE="${STATE_DIR}/last_evolution_check"
update_last_check() {
    echo "$(date +%s)" > "$LAST_CHECK_FILE"
}
should_evolve() {
    local last_check=$(cat "$LAST_CHECK_FILE" 2>/dev/null || echo "0")
    local elapsed=$(($(date +%s) - last_check))
    # Prevent re-triggering within cooldown period
}
```

### Usage Data Decay

```bash
USAGE_WINDOW=7  # 7-day window for usage analysis
learn_from_usage() {
    local skill_file="$1"
    local days="${2:-7}"
    # Only analyze usage data from the last 7 days
}
```

Usage patterns older than 7 days are decayed to give more weight to recent behavior.
