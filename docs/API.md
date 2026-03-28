# Skill System API Reference

> Complete API reference for the skill lifecycle management system

---

## Quick Start

```bash
# Create a new skill
./scripts/create-skill.sh "Create a code review skill"

# Evaluate a skill
./scripts/evaluate-skill.sh ./my-skill.md

# Optimize a skill
./scripts/optimize-skill.sh ./my-skill.md

# Security audit
./scripts/security-audit.sh ./my-skill.md

# Restore a broken skill
./scripts/restore-skill.sh ./broken-skill.md
```

---

## Scripts

### create-skill.sh

Create a new skill from description.

```bash
./scripts/create-skill.sh "description" [output_path] [tier]
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| description | Skill description | (required) |
| output_path | Output file path | ./[derived-name].md |
| tier | Target tier | BRONZE |

### evaluate-skill.sh

Evaluate a skill using the full eval framework.

```bash
./scripts/evaluate-skill.sh <skill_file> [mode]
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| skill_file | Path to SKILL.md | (required) |
| mode | fast or full | fast |

### optimize-skill.sh

Optimize a skill using the 9-step evolution loop.

```bash
./scripts/optimize-skill.sh <skill_file> [max_rounds]
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| skill_file | Path to SKILL.md | (required) |
| max_rounds | Max optimization rounds | 20 |

### security-audit.sh

Run OWASP AST10 security audit.

```bash
./scripts/security-audit.sh <skill_file> [level]
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| skill_file | Path to SKILL.md | (required) |
| level | BASIC or FULL | FULL |

### restore-skill.sh

Restore a broken skill.

```bash
./scripts/restore-skill.sh <skill_file>
```

### quick-score.sh

Quick text scoring without LLM.

```bash
./scripts/quick-score.sh <skill_file>
```

---

## Engine API

### engine/orchestrator.sh

Main workflow coordinator for skill creation.

```bash
engine/orchestrator.sh <prompt> <output_file> [tier]
```

### engine/agents/creator.sh

Generate SKILL.md sections.

```bash
source engine/agents/creator.sh
creator_generate <context_file>
```

### engine/agents/evaluator.sh

Evaluate a skill file.

```bash
engine/agents/evaluator.sh <skill_file> [section_num]
```

### engine/agents/restorer.sh

Restore a broken skill.

```bash
engine/agents/restorer.sh <skill_file>
```

### engine/agents/security.sh

OWASP AST10 security audit.

```bash
engine/agents/security.sh <skill_file> [FULL|BASIC]
```

### engine/evolution/engine.sh

9-step optimization loop.

```bash
engine/evolution/engine.sh <skill_file> [max_rounds]
```

---

## Eval API

### eval/main.sh

Main evaluation engine.

```bash
eval/main.sh --skill <path> [options]

Options:
    --skill PATH         Skill file path (required)
    --fast              Fast mode (20 rounds)
    --full              Full mode (100 rounds)
    --corpus PATH       Custom corpus
    --output DIR        Output directory
    --ci                CI mode
    --agent             Force agent evaluation
    --no-agent          Skip agent evaluation
```

### eval/scorer/text_scorer.sh

Text quality scoring (Phase 2).

```bash
eval/scorer/text_scorer.sh <skill_file>
```

### eval/scorer/runtime_tester.sh

Runtime behavior testing (Phase 3).

```bash
eval/scorer/runtime_tester.sh <skill_file> <corpus_file>
```

### eval/parse/parse_validate.sh

Parse and validate skill structure (Phase 1).

```bash
eval/parse/parse_validate.sh <skill_file>
```

### eval/certifier.sh

Determine certification tier (Phase 4).

```bash
eval/certifier.sh <skill_file> <text_score> <runtime_score> <variance> <f1> <mrr>
```

### eval/analyzer/trigger_analyzer.sh

Calculate F1/MRR/trigger accuracy.

```bash
eval/analyzer/trigger_analyzer.sh <corpus.json>
```

### eval/analyzer/variance_analyzer.sh

Calculate text-runtime variance.

```bash
eval/analyzer/variance_analyzer.sh <text_score> <runtime_score>
```

---

## Library API

### engine/lib/bootstrap.sh

Initialize paths and load modules.

```bash
source engine/lib/bootstrap.sh

require <module1> [module2] ...
require_agent <agent_name>
load_prompt <prompt_name>
```

### engine/lib/concurrency.sh

Lock management.

```bash
acquire_lock <name> [timeout]
release_lock <name>
with_lock <name> [timeout] <command>
is_lock_available <name> [timeout]
```

### engine/lib/constants.sh

Configuration constants.

| Constant | Default | Description |
|---------|---------|-------------|
| EVOLUTION_THRESHOLD_NEW | 10 | Eval count threshold for new skills |
| EVOLUTION_THRESHOLD_GROWING | 50 | Eval count threshold for growing skills |
| EVOLUTION_THRESHOLD_STABLE | 100 | Eval count threshold for stable skills |
| PASSING_SCORE | 800 | Minimum passing score |
| MAX_SNAPSHOTS | 10 | Maximum snapshots to keep |

### engine/evolution/rollback.sh

Snapshot and rollback.

```bash
create_snapshot <skill_file> [reason]
rollback_to <snapshot_file> <skill_file>
rollback_to_latest [skill_file]
check_auto_rollback <current_score> <previous_score> [valid] [skill_file]
```

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | OpenAI API key |
| `ANTHROPIC_API_KEY` | Anthropic API key |
| `KIMI_API_KEY` | Kimi API key |
| `KIMI_CODE_API_KEY` | Kimi Code API key |
| `MINIMAX_API_KEY` | MiniMax API key |
| `MINIMAX_GROUP_ID` | MiniMax group ID |
| `EVAL_DIR` | Override eval directory |
| `EVAL_DIR_FROM_ENGINE` | Override engine directory |
| `TARGET_TIER` | Default target tier |
| `DRY_RUN` | Dry run mode (1) |

---

## Exit Codes

| Code | Description |
|------|-------------|
| 0 | Success |
| 1 | General error |
| 10 | Invalid format |
| 20 | Evaluation failure |
| 30 | LLM timeout |
| 31 | LLM error |
| 40 | Lock failed |
| 50 | Snapshot error |
