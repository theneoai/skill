# Skill Engineering

AI Skill Lifecycle Management: Create, Evaluate, Optimize Skills.

## Installation

### OpenCode

```
Fetch and follow instructions from https://raw.githubusercontent.com/theneoai/skill/main/.opencode/INSTALL.md
```

### Codex

```
Fetch and follow instructions from https://raw.githubusercontent.com/theneoai/skill/main/.codex/INSTALL.md
```

### Claude Code

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

### Cursor

```
/add-plugin superpowers
```

### Gemini CLI

```
gemini extensions install https://github.com/theneoai/skill
```

## Quick Start

```bash
# Fast evaluation (~$0, ~0s)
./scripts/lean-orchestrator.sh ./SKILL.md

# Full evaluation (~$0.50, ~2min)
./scripts/evaluate-skill.sh ./SKILL.md

# Create skill
./scripts/create-skill.sh "Create a code review skill"

# Create with inheritance
./scripts/create-skill.sh "Create a code review skill" --extends skill
```

## Core Features

| Feature | Description |
|---------|-------------|
| **6 Modes** | CREATE, EVALUATE, LEAN, RESTORE, SECURITY, OPTIMIZE |
| **9-Step Loop** | READ → ANALYZE → CURATION → PLAN → IMPLEMENT → VERIFY → HUMAN_REVIEW → LOG → COMMIT |
| **Multi-LLM** | Cross-validation with kimi-code, minimax, openai |
| **Lean Eval** | ~0s, ~$0 (heuristic-based) |
| **4-Tier Cert** | GOLD ≥ 900, SILVER ≥ 800, BRONZE ≥ 700 (1000pts) |

## Documentation

- [SKILL.md](SKILL.md) - Skill format specification
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - System architecture
- [docs/WORKFLOWS.md](docs/WORKFLOWS.md) - Workflow documentation

## License

MIT
