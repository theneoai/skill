# Thresholds Reference

## Certification Thresholds

| Tier | Score | Text Min | Runtime Min | Variance Max |
|------|-------|----------|-------------|--------------|
| PLATINUM | ≥950 | ≥330 | ≥430 | < 10 |
| GOLD | ≥900 | ≥315 | ≥405 | < 15 |
| SILVER | ≥800 | ≥280 | ≥360 | < 20 |
| BRONZE | ≥700 | ≥245 | ≥315 | < 30 |

**Notes:**
- Score is on a 1000 pts max scale (text_score + runtime_score)
- All conditions must be met simultaneously for tier certification

## Evolution Triggers

| Trigger | Condition | Priority |
|---------|-----------|----------|
| Threshold | Score < 475 | High |
| Scheduled | 24 hours | Medium |
| Usage F1 | < 0.85 | High |
| Usage Rate | < 0.80 | High |
| Manual | force=true | Highest |

**Evolution Thresholds by Skill State:**

| State | Evaluation Count Threshold |
|-------|---------------------------|
| NEW | Every 10 evaluations |
| GROWING | Every 50 evaluations |
| STABLE | Every 100 evaluations |

## Timeouts (seconds)

| Setting | Value |
|---------|-------|
| CREATOR_TIMEOUT | 60 |
| EVALUATOR_TIMEOUT | 30 |
| EVOLUTION_TIMEOUT | 120 |
| SKILL_FILE_TIMEOUT | 10 |
| LLM_TIMEOUT | 15 |
| ERROR_LLM_TIMEOUT | 30 |

## Lean Evaluation Weights

| Dimension | Weight | Max Points |
|-----------|--------|------------|
| PARSE_YAML_FRONT | 30 | 100 |
| TEXT_SYSTEM_PROMPT | 70 | 350 |
| RUNTIME_IDENTITY | 80 | 450 |

## Configuration Variables

```bash
# Evolution
EVOLUTION_THRESHOLD_NEW=10
EVOLUTION_THRESHOLD_GROWING=50
EVOLUTION_THRESHOLD_STABLE=100
MAX_SNAPSHOTS=10

# Lean Eval
LEAN_PARSE_WEIGHT=100
LEAN_TEXT_WEIGHT=350
LEAN_RUNTIME_WEIGHT=50

# Cross-Eval
CROSS_EVAL_THRESHOLD=0.2
```

## Certification Scores (100 pts total)

| Component | Max Points |
|-----------|------------|
| Variance Control | 40 |
| Tier Determination | 30 |
| Report Completeness | 20 |
| Security Gates | 10 |

**Minimum to certify:** 50 pts + no P0 violations + not NOT_CERTIFIED tier
