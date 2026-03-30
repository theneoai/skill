# Architecture

This document describes the technical architecture of Skill Engineering.

## System Overview

Skill Engineering implements a multi-layer architecture:

```
User Input → Mode Router → [CREATE|EVALUATE|RESTORE|SECURITY|OPTIMIZE]
                                ↓
                         LOONGFLOW ENGINE
                                ↓
                    Multi-LLM Deliberation Layer
                                ↓
                         Quality Certification
```

## Core Components

### CLI Layer (skill/cli/)

Command-line interface for all operations. Entry point for user interactions.

### Orchestrator Layer (skill/orchestrator/)

**LoongFlow**: Plan-Execute-Summarize cognitive orchestration replacing traditional loop.

- loongflow.py: Main orchestration engine
- workflow.py: Workflow state machine
- parallel.py: Parallel execution utilities
- actions.py: Action definitions
- state.py: State management

### Agent Layer (skill/agents/)

Domain-specific agents for each lifecycle mode:

| Agent | Responsibility |
|-------|---------------|
| CreatorAgent | Generate new skills from requirements |
| EvaluatorAgent | Measure skill quality metrics |
| RestorerAgent | Repair broken skills |
| SecurityAgent | Perform CWE-based security audits |
| OptimizerAgent | Autonomous skill improvement |

### Engine Layer (skill/engine/)

Self-evolution and operational components:

- analyzer.py: Log analysis
- convergence.py: Convergence detection
- decider.py: Evolution trigger decisions
- learner.py: Pattern learning
- improver.py: LLM-based improvement
- rollback.py: Snapshot and rollback
- storage.py: Persistent storage
- usage_tracker.py: Usage analytics

### Evaluation Layer (skill/eval/)

Enterprise-grade evaluation framework:

- gepa.py: GEPA trajectory scoring
- sae.py: SAE survivability evaluation
- ground_truth.py: Ground truth benchmarks (GPQA, IFEval)
- multi_dimensional.py: Multi-dimensional quality scoring
- certifier.py: 4-tier certification (PLATINUM/GOLD/SILVER/BRONZE)

## Multi-LLM Deliberation

Three LLMs operate in parallel:

1. **Generator (LLM-1)**: Produces initial draft
2. **Reviewer (LLM-2)**: Security and quality audit
3. **Arbiter (LLM-3)**: Cross-validation and consensus

### Supported Providers

- OpenAI (GPT-4, GPT-3.5)
- Anthropic (Claude)
- Kimi (Moonshot)
- MiniMax

## Self-Evolution

BOAD (Bandit-Based Optimizer with Adaptive Discovery):
- UCB1 exploration for configuration optimization
- Usage-weighted improvement decisions

ROAD (Recovery-Oriented Autonomous Director):
- Error detection and recovery
- Graceful degradation

## Security Architecture

CWE-based security scanning with OWASP AST10:

| CWE | Description |
|-----|-------------|
| CWE-798 | Hardcoded credentials |
| CWE-89 | SQL injection |
| CWE-79 | XSS |
| CWE-94 | Code injection |

## Data Flow

1. **Input**: User natural language or structured request
2. **Parse**: Extract keywords, detect language, identify intent
3. **Route**: Classify to appropriate mode
4. **Execute**: Run mode-specific workflow
5. **Validate**: Quality gates and security checks
6. **Deliver**: Signed artifact with audit trail

## Further Reading

- [User Guide](user-guide.md) - Operational workflows
- [Developer Guide](developer-guide.md) - Integration and customization
- [SKILL.md](../SKILL.md) - Skill format specification
