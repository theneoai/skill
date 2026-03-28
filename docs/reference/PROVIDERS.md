# LLM Providers Reference

## Provider Strength Ranking

| Rank | Provider | Strength | Default Model |
|------|----------|----------|---------------|
| 1 | anthropic | 100 | claude-sonnet-4-20250514 |
| 2 | openai | 90 | gpt-4o-mini |
| 3 | kimi-code | 85 | kimi-for-coding |
| 4 | minimax | 80 | MiniMax-M2.7-highspeed |
| 5 | kimi | 75 | moonshot-v1-8k |

**Selection Logic:**
- `select_top_providers()` picks top 2 providers by strength from available ones
- `check_llm_available()` detects providers with valid API keys

## Environment Variables

```bash
# Required for each provider
ANTHROPIC_API_KEY=sk-...
OPENAI_API_KEY=sk-...
KIMI_API_KEY=sk-...
KIMI_CODE_API_KEY=sk-...  # Preferred over KIMI_API_KEY
MINIMAX_API_KEY=sk-...
MINIMAX_GROUP_ID=...

# Optional endpoints
KIMI_CODE_ENDPOINT=https://api.kimi.com/coding/v1

# Defaults
DEFAULT_LLM_PROVIDER=kimi-code
MAX_LLM_RETRIES=3
LLM_TIMEOUT=15
```

## Auto-Selection Logic

```bash
# 1. Check available providers
check_llm_available() {
    local providers=""
    [[ -n "$KIMI_CODE_API_KEY" ]] && providers="${providers}kimi-code "
    [[ -n "$KIMI_API_KEY" ]] && providers="${providers}kimi "
    [[ -n "$MINIMAX_API_KEY" ]] && providers="${providers}minimax "
    [[ -n "$OPENAI_API_KEY" ]] && providers="${providers}openai "
    [[ -n "$ANTHROPIC_API_KEY" ]] && providers="${providers}anthropic "
    
    if [[ -z "$providers" ]]; then
        echo "none"
    else
        echo "$providers" | sed 's/ $//'
    fi
}

# 2. Select top 2 by strength
select_top_providers() {
    available=$(check_llm_available)
    # Sort by strength and take top 2
}
```

## API Endpoints

| Provider | Endpoint | Protocol |
|----------|----------|----------|
| Anthropic | https://api.anthropic.com/v1/messages | HTTP |
| OpenAI | https://api.openai.com/v1/chat/completions | HTTP |
| Kimi | https://api.moonshot.cn/v1/chat/completions | HTTP |
| Kimi Code | https://api.kimi.com/coding/v1/messages | HTTP (Anthropic-compatible) |
| MiniMax | https://api.minimaxi.com/v1/text/chatcompletion_v2 | HTTP |

## Cross-Evaluation

```bash
# Enable multi-agent cross-evaluation
CROSS_EVAL_ENABLED=false

# Variance threshold for cross-validation (20%)
CROSS_EVAL_THRESHOLD=0.2
```

**Cross-Eval Behavior:**
- When enabled, uses multiple providers to cross-validate results
- If variance between providers exceeds threshold, flags for review
- Currently uses single provider (first available by strength) for actual evaluation
