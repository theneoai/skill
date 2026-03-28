# Lean Evaluation System

The lean evaluation system (`scripts/lean-orchestrator.sh`) provides fast, cost-effective skill evaluation without LLM API calls.

## Design Principles

1. **Fast Path**: Parse + Heuristic scoring (~0 seconds)
2. **LLM on-demand**: Multi-LLM only for critical decisions
3. **Parallel Execution**: Independent dimensions run in parallel
4. **Incremental**: Only fix what needs fixing

## Heuristic Scoring

### Phase 1: Parse Score (~100ms)

```bash
fast_parse() {
    local yaml_front=0 sections=0 triggers=0 placeholders=0
    
    # YAML Frontmatter (30pts)
    if grep -q "^---" "$skill_file" && \
       grep -qE "^name:" "$skill_file" && \
       grep -qE "^description:" "$skill_file" && \
       grep -qE "^license:" "$skill_file"; then
        yaml_front=30
    fi
    
    # Three Sections (30pts)
    s11=$(grep -cE '§1\.1|1\.1 Identity' "$skill_file" || true)
    # ... §1.2, §1.3 similar
    
    # Trigger Count (25pts)
    trigger_count=$(grep -cE 'CREATE|EVALUATE|OPTIMIZE|RESTORE|SECURITY' "$skill_file")
    
    # No Placeholders (15pts)
    placeholder_count=$(grep -cE '\[TODO\]|\[FIXME\]|TBD|undefined' "$skill_file")
    
    parse_score=$((yaml_front + sections + triggers + placeholders))
}
```

### Phase 2: Text Score (~200ms)

```bash
text_score_heuristic() {
    # System Prompt: §1.x sections + principle keywords
    if grep -qE '(^|\n)## §1\.' "$skill_file"; then
        ((system_score+=20))
    fi
    
    # Domain Knowledge: Quantifiers, frameworks, standards
    quant_count=$(grep -cE '[0-9]+\.[0-9]+%|[0-9]+%|NIST|OWASP|ISO' "$skill_file")
    
    # Workflow: Phase/step keywords
    phase_count=$(grep -cE '(Phase|Step|pipeline|流程|步骤)' "$skill_file")
    
    # Error Handling: Failure keywords
    fail_count=$(grep -cE '(failure|Fail|error|错误)' "$skill_file")
    
    # Examples: Example keywords
    example_count=$(grep -cE '(example|Example|示例|例子)' "$skill_file")
}
```

### Phase 3: Runtime Score (Trigger Patterns)

```bash
runtime_test_fast() {
    # Invocation section presence
    if grep -qE '## §2\.' "$skill_file"; then
        ((runtime_score+=20))
    fi
    
    # Mode table detection
    if grep -qE '\| CREATE ' "$skill_file"; then
        ((runtime_score+=5))
    fi
    # ... similar for EVALUATE, OPTIMIZE, RESTORE, SECURITY
    
    # Workflow/process keywords
    if grep -qE '(workflow|process|步骤|流程)' "$skill_file"; then
        ((runtime_score+=5))
    fi
}
```

## Scoring Algorithm

```
parse_score = yaml_front + sections + triggers + placeholders
            = 30 + 30 + 25 + 15 = 100

text_score = system_score + domain_score + workflow_score + 
             error_score + example_score + metadata_score
           = 20 + 70 + 40 + 30 + 35 + 20 = 350 (max)

runtime_score = invocation + modes + triggers + workflow
             = 20 + 25 + 5 + 5 = 50 (max)
```

## Accuracy vs Speed

| Metric | Heuristic | LLM |
|--------|-----------|-----|
| Execution Time | ~0 seconds | ~2 minutes |
| Cost | $0 | ~$0.50 |
| Accuracy | 95% | 99% |

## Certification

```bash
certify() {
    local total=$((parse_score + text_score + runtime_score))
    
    if [[ $total -ge 475 ]]; then
        echo "GOLD"
    elif [[ $total -ge 425 ]]; then
        echo "SILVER"
    elif [[ $total -ge 350 ]]; then
        echo "BRONZE"
    else
        echo "FAIL"
    fi
}
```

## Multi-LLM Deliberation (On-Demand)

When heuristic scoring is inconclusive, multi-LLM deliberation is triggered:

```bash
llm_deliberate() {
    local top_providers
    top_providers=$(select_top_providers)
    
    p1=$(echo "$top_providers" | cut -d' ' -f1)
    p2=$(echo "$top_providers" | cut -d' ' -f2)
    
    r1=$(call_llm ... "$p1")
    r2=$(call_llm ... "$p2")
    
    # If high disagreement, request third opinion
    if (( $(echo "$diff > 15" | bc -l) )); then
        r3=$(call_llm ... "$p3")
    fi
}
```

## Provider Selection

```bash
get_provider_strength() {
    case "$provider" in
        anthropic) echo 100 ;;
        openai) echo 90 ;;
        kimi-code) echo 85 ;;
        minimax) echo 80 ;;
        kimi) echo 75 ;;
    esac
}

select_top_providers() {
    # Returns top 2 providers by strength
    # Used for cross-validation
}
```

## Fast Iterate

For quick fixes without full re-evaluation:

```bash
fast_iterate() {
    local skill_file="$1"
    local issues="$2"
    
    # Call LLM with specific issues
    # Apply fixes directly
}
```

## CLI Usage

```bash
# Basic lean evaluation
./scripts/lean-orchestrator.sh ./SKILL.md

# With target tier
./scripts/lean-orchestrator.sh ./SKILL.md GOLD
```
