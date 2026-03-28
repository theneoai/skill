# Architecture

> Technical architecture of the skill lifecycle management system

## Overview

The skill system enables creating, evaluating, restoring, securing, and optimizing AI skills through a multi-LLM deliberation system.

```
┌─────────────────────────────────────────────────────────────────────┐
│                         User Interface                               │
│                    (scripts/ + SKILL.md)                           │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    ENGINE - Lifecycle Management                     │
│                                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │ CREATE   │  │ EVALUATE │  │ RESTORE  │  │ SECURITY │           │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘           │
│                              │                                      │
│                    ┌─────────▼─────────┐                           │
│                    │   EVOLUTION       │                            │
│                    │   (9-step loop)    │                           │
│                    └───────────────────┘                            │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    EVAL - Quality Assurance                         │
│                                                                      │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐               │
│  │ Parse   │  │  Text   │  │ Runtime │  │ Certify │               │
│  │ Phase 1 │  │ Phase 2 │  │ Phase 3 │  │ Phase 4 │               │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘               │
└─────────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
skill-system/
├── SKILL.md                    # Skill manifest
├── README.md                   # Quick start
├── CHANGELOG.md                # Version history
│
├── scripts/                    # User-facing CLI
│   ├── create-skill.sh        # Skill creation
│   ├── evaluate-skill.sh      # Full evaluation
│   ├── optimize-skill.sh      # Self-optimization
│   ├── security-audit.sh       # Security audit
│   ├── restore-skill.sh       # Skill restoration
│   └── lean-orchestrator.sh   # Fast evaluation (~0s)
│
├── engine/                     # Lifecycle management
│   ├── agents/                # Creator, Evaluator, Restorer, Security
│   ├── evolution/             # 9-step optimization loop
│   ├── orchestrator/          # Workflow components
│   └── lib/                   # Shared libraries
│
├── eval/                       # Quality assurance
│   ├── scorer/                # Text & runtime scoring
│   ├── analyzer/             # F1/MRR/variance
│   └── corpus/               # Test data
│
└── docs/                      # Documentation
    ├── ARCHITECTURE.md        # This file
    ├── WORKFLOWS.md          # Workflow reference
    └── technical/
        └── DESIGN.md         # Design decisions
```

## 9-Step Optimization Loop

```
READ → ANALYZE → CURATION → PLAN → IMPLEMENT → VERIFY → HUMAN_REVIEW → LOG → COMMIT
```

- **READ**: Locate weakest dimension (Multi-LLM)
- **ANALYZE**: Prioritize improvement strategy
- **CURATION**: Consolidate knowledge (every 10 rounds)
- **PLAN**: Select specific improvement approach
- **IMPLEMENT**: Apply atomic change
- **VERIFY**: Multi-LLM verification
- **HUMAN_REVIEW**: Expert review if score < 8.0
- **LOG**: Record to results.tsv
- **COMMIT**: Git commit every 10 rounds

## 4-Phase Evaluation

| Phase | Focus | Score |
|-------|-------|-------|
| 1. Parse | Structure, YAML, triggers | 100pts |
| 2. Text | Quality, completeness | 350pts |
| 3. Runtime | Behavior, consistency | 450pts |
| 4. Certify | Tier, variance, security | 100pts |

**Total: 1000pts**

## Lean Evaluation (~0 seconds, $0)

For fast feedback during development:

| Phase | Focus | Max |
|-------|-------|-----|
| Parse | YAML, §1.x, triggers | 100 |
| Text | §1.x quality | 350 |
| Runtime | §2 trigger patterns | 50 |

**Thresholds**: GOLD ≥475 | SILVER ≥425 | BRONZE ≥350

## Certification Tiers

| Tier | Score | F1 | MRR | Variance |
|------|-------|-----|-----|----------|
| PLATINUM | ≥950 | ≥0.95 | ≥0.90 | <10 |
| GOLD | ≥900 | ≥0.95 | ≥0.90 | <15 |
| SILVER | ≥800 | ≥0.92 | ≥0.87 | <20 |
| BRONZE | ≥700 | ≥0.90 | ≥0.85 | <30 |

## Multi-LLM Deliberation

All critical decisions use multiple LLM providers (Anthropic, OpenAI, Kimi) for cross-validation:
1. Independent Analysis
2. Result Comparison
3. Conflict Resolution
4. Confidence Scoring

## Auto-Evolution Triggers

| Priority | Trigger | Condition |
|----------|---------|-----------|
| 1 | Manual | `force=true` |
| 2 | Threshold | Score < 475 |
| 3 | Scheduled | 24h since last check |
| 4 | Usage | F1 < 0.85 or Rate < 0.80 |

## Security (OWASP AST10)

1. Credential Scan
2. Input Validation
3. Path Traversal
4. Trigger Sanitization
5. YAML Parsing Safety
6. Command Injection Prevention
7. SQL Injection Prevention
8. Data Exposure Prevention
9. Log Security
10. Error Handling Security

---

**Last Updated**: 2026-03-28
