# Evaluation Framework

The unified skill evaluation framework (`eval/`) provides comprehensive quality assurance for agent skills.

## Framework Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                    unified-skill-eval v2.0                           │
│                    Agent Skill 统一评估框架                             │
├──────────────────────────────────────────────────────────────────────┤
│  INPUT                                                              │
│    └─ SKILL.md or skill-directory or remote git URL                 │
├──────────────────────────────────────────────────────────────────────┤
│  PIPELINE (4 phases)                                                │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  ┌──────────┐ │
│  │   PARSE &    │→ │    TEXT       │→ │   RUNTIME     │→ │  CERTIFY  │ │
│  │   VALIDATE   │  │    SCORE      │  │    SCORE      │  │  & REPORT │ │
│  │   100pts     │  │   350pts      │  │   450pts      │  │  100pts   │ │
│  └───────────────┘  └───────────────┘  └───────────────┘  └──────────┘ │
├──────────────────────────────────────────────────────────────────────┤
│  OUTPUT                                                             │
│    ├─ report.json     # Machine-readable (LLM consumption)           │
│    └─ report.html     # Human-readable (browser, bilingual zh/en)    │
└──────────────────────────────────────────────────────────────────────┘
```

## 4-Phase Evaluation

### Phase 1: Parse & Validate (100pts)

| Check | Points | Pass Criteria |
|-------|--------|---------------|
| YAML Frontmatter | 30pts | name + description + license complete |
| Three Sections | 30pts | §1.1 + §1.2 + §1.3 all present |
| Trigger List | 25pts | CREATE/EVALUATE/RESTORE/TUNE ≥1 each |
| No Placeholders | 15pts | 0 [TODO]/[FIXME]/TBD |

### Phase 2: Text Score (350pts)

| Dimension | Points | Weight | Excellence Standard |
|-----------|--------|--------|-------------------|
| System Prompt | 70pts | 20% | §1.1 + §1.2 + §1.3 + constraints |
| Domain Knowledge | 70pts | 20% | Specific data ≥10 occurrences |
| Workflow | 70pts | 20% | 4-6 phases + Done/Fail criteria |
| Error Handling | 55pts | 15% | ≥5 named failures + recovery |
| Examples | 55pts | 15% | ≥5 scenarios + input/output/verification |
| Metadata | 30pts | 10% | agentskills-spec compliance |

### Phase 3: Runtime Score (450pts)

| Check | Points | Weight | Measurement |
|-------|--------|--------|-------------|
| Identity Consistency | 80pts | 18% | Role confusion testing (20+ rounds) |
| Framework Execution | 70pts | 16% | Tool calling / memory access |
| Output Actionability | 70pts | 16% | Parameter completeness |
| Knowledge Accuracy | 50pts | 11% | Hallucination detection |
| Conversation Stability | 50pts | 11% | MultiTurnPassRate (≥85%) |
| Trace Compliance | 50pts | 11% | AgentPex behavior rules |
| Long-Document | 30pts | 7% | 100K token stability |
| Multi-Agent | 25pts | 5% | Collaboration mode testing |
| Trigger Accuracy | 25pts | 5% | F1/MRR composite |

### Phase 4: Certify & Report (100pts)

| Check | Points | Standard |
|-------|--------|----------|
| Variance Control | 40pts | \|Text - Runtime\| < threshold |
| Certification Tier | 30pts | Correct tier determination |
| Report Completeness | 20pts | JSON + HTML dual output |
| Security Gates | 10pts | CWE-798/89/78/22 all pass |

## Scoring Dimensions

### Multi-LLM Scoring

```bash
multi_llm_locate_weakest() {
    # 3 providers score each dimension
    r1=$(llm_score_dimensions "anthropic" "$skill_file")
    r2=$(llm_score_dimensions "openai" "$skill_file")
    r3=$(llm_score_dimensions "kimi" "$skill_file")
    
    # Cross-validation: 2/3 agreement required
    # Third opinion on disagreement
}
```

### Confidence Scoring

```bash
if [[ "$dim1" == "$dim2" ]] || [[ "$dim1" == "$dim3" ]]; then
    confidence=0.9
elif [[ "$dim2" == "$dim3" ]]; then
    confidence=0.85
else
    confidence=0.6  # Low confidence, request human review
fi
```

## Certification Tiers (1000pts)

| Tier | Total | Text | Runtime | Variance |
|------|-------|------|---------|----------|
| PLATINUM | ≥950 | ≥330 | ≥430 | <20 |
| GOLD | ≥900 | ≥315 | ≥405 | <50 |
| SILVER | ≥800 | ≥280 | ≥360 | <80 |
| BRONZE | ≥700 | ≥245 | ≥315 | <150 |

## CLI Usage

```bash
# Fast evaluation (3min, 100 rounds)
eval/main.sh --skill ./SKILL.md --fast

# Full evaluation (10min, 1000 rounds)
eval/main.sh --skill ./SKILL.md --full

# With agent-based testing
eval/main.sh --skill ./SKILL.md --agent
```
