# Metrics Reference

## Trigger F1

```
Trigger F1 = correct_triggers / total_triggers

Where:
- correct_triggers = number of times expected_mode == actual_mode
- total_triggers = total number of trigger events
```

**Example:**
```
Total triggers: 10
Correct triggers: 9
Trigger F1 = 9/10 = 0.9
```

## Task Completion Rate

```
Task Completion Rate = completed_tasks / total_tasks
```

## MRR (Mean Reciprocal Rank)

```
MRR = (1/rank1 + 1/rank2 + ... + 1/rankN) / N

Where rank is the position of the correct answer in the candidate list
```

## Score Calculation

### Lean Score (500 pts max)

```
total = parse_score + text_score + runtime_score
```

### Full Score (1000 pts max)

```
total = parse_score + text_score + runtime_score + certify_score
```

**Score Components:**

| Component | Max Points | Description |
|-----------|------------|-------------|
| parse_score | 100 | YAML front matter, section structure, trigger list, no placeholders |
| text_score | 350 | System prompt, domain knowledge, workflow, error handling, examples, metadata |
| runtime_score | 450 | Identity, framework, actionability, knowledge, conversation, trace, long doc, multi-agent, trigger |
| certify_score | 100 | Variance control, tier determination, report completeness, security gates |

### Variance Calculation

```
variance = Σ(score_i - mean)^2 / N
```

**Variance Thresholds:**

| Tier | Variance Max |
|------|--------------|
| PLATINUM | < 10 |
| GOLD | < 15 |
| SILVER | < 20 |
| BRONZE | < 30 |

## Core Metrics Thresholds

| Metric | Threshold |
|--------|-----------|
| F1 Score | ≥ 0.90 |
| MRR | ≥ 0.85 |
| Trigger Accuracy | ≥ 0.99 |
| Text Score Min | 280 |
| Runtime Score Min | 360 |
