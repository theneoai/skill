# Skill Engineering

[![PLATINUM Tier](https://img.shields.io/badge/Tier-PLATINUM-4CAF50)](SKILL.md)
[![F1 Score](https://img.shields.io/badge/F1%20Score-0.923-2196F3)](eval/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

**Authors**: theneoai <lucas_hsueh@hotmail.com> | **Version**: 2.0.0 | **Standard**: agentskills.io v2.1.0

---

## Abstract

Agent Skill Engineering is a comprehensive methodology for managing the complete lifecycle of AI agent skills—from specification through autonomous optimization to production certification. We address four fundamental challenges: standardized skill representation, reliable dual-track evaluation, autonomous optimization, and long-context document handling.

Our **multi-agent optimization architecture** employs parallel evaluation across specialized agents (Security, Trigger, Runtime, Quality, EdgeCase) under deterministic improvement selection. The **9-step autonomous loop** achieves continuous improvement with measurable quality targets.

**Key Metrics**: Text Score ≥ 9.5, Runtime Score ≥ 9.5, Variance < 1.0, F1 ≥ 0.90

---

## Key Features

- **5 Modes**: CREATE, EVALUATE, RESTORE, SECURITY, OPTIMIZE
- **9-Step Autonomous Optimization Loop**: READ → ANALYZE → CURATION → PLAN → IMPLEMENT → VERIFY → HUMAN_REVIEW → LOG → COMMIT
- **Multi-LLM Deliberation**: Cross-validation with Anthropic, OpenAI, Kimi
- **Dual-Track Validation**: Text quality + Runtime effectiveness
- **4-Tier Certification**: PLATINUM ≥ 950 | GOLD ≥ 900 | SILVER ≥ 800 | BRONZE ≥ 700
- **OWASP AST10 Security**: 10-item security checklist

---

## Quick Start

```bash
# Create a new skill
./scripts/create-skill.sh "Create a code review skill"

# Evaluate a skill
./scripts/evaluate-skill.sh ./code-review.md

# Optimize a skill
./scripts/optimize-skill.sh ./code-review.md

# Security audit
./scripts/security-audit.sh ./code-review.md

# Restore broken skill
./scripts/restore-skill.sh ./broken-skill.md
```

---

## Directory Structure

```
skill-system/
├── SKILL.md                    # Self-describing skill manifest
├── README.md                   # This file
├── CHANGELOG.md               # Version history
│
├── scripts/                   # User-facing CLI tools
│   ├── create-skill.sh
│   ├── evaluate-skill.sh
│   ├── optimize-skill.sh
│   ├── security-audit.sh
│   ├── restore-skill.sh
│   └── quick-score.sh
│
├── engine/                    # Skill lifecycle management
│   ├── agents/               # Creator, Evaluator, Restorer, Security
│   ├── evolution/            # 9-step optimization loop
│   ├── orchestrator/         # Workflow components
│   ├── lib/                  # Shared libraries
│   └── prompts/              # Agent prompts
│
├── eval/                     # Quality assurance framework
│   ├── scorer/              # Text & runtime scoring
│   ├── analyzer/            # F1/MRR/variance
│   ├── corpus/              # Test data
│   └── report/              # Output formatters
│
├── tests/                    # Test suite
│   ├── run_tests.sh          # Test runner
│   ├── unit/                # Unit tests
│   └── integration/          # Integration tests
│
├── docs/                     # Documentation
│   ├── API.md               # API reference
│   └── ARCHITECTURE.md      # Technical architecture
│
├── examples/                # Usage examples
│
└── .github/workflows/        # CI/CD
```

---

## BibTeX

```
@article{neoai2026agent,
  author  = {neo.ai},
  title   = {Agent Skill Engineering: A Systematic Approach to AI Skill Lifecycle Management},
  journal = {arXiv preprint},
  year    = {2026},
  eprint  = {arXiv:XXXX.XXXXX},
  primaryClass = {cs.AI}
}
```

---

**Last Updated**: 2026-03-28
