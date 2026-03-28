# Workflows

Workflow reference for the Skill System.

---

## Create

Create a new skill from description.

```bash
./scripts/create-skill.sh "skill description" [output_path] [tier]
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| description | Skill description | (required) |
| output_path | Output file path | ./[derived-name].md |
| tier | Target tier | BRONZE |

**Available tiers**: GOLD, SILVER, BRONZE (default: BRONZE)

---

## Evaluate

Evaluate a skill's quality through text-based scoring and optional runtime testing.

```bash
./scripts/evaluate-skill.sh <skill_file> [mode]
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| skill_file | Path to SKILL.md | (required) |
| mode | fast or full | fast |

**Modes**:
- `fast` / `lean`: ~0 seconds, $0, heuristic-based
- `full`: ~2 minutes, ~$0.50, LLM-based

---

## Optimize

Improve a skill through the 9-step iterative optimization loop.

```bash
./scripts/optimize-skill.sh <skill_file> [max_rounds]
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| skill_file | Path to SKILL.md | (required) |
| max_rounds | Max optimization rounds | 20 |

**9-Step Loop**: READ → ANALYZE → CURATION → PLAN → IMPLEMENT → VERIFY → HUMAN_REVIEW → LOG → COMMIT

---

## Restore

Diagnose broken skills and restore from snapshots.

```bash
./scripts/restore-skill.sh <skill_file> [--list|--snapshot ID]
```

| Option | Description |
|--------|-------------|
| (none) | Interactive restore |
| `--list` | List available snapshots |
| `--snapshot ID` | Restore specific snapshot |

---

## Security Audit

Run OWASP AST10 security audit.

```bash
./scripts/security-audit.sh <skill_file> [level]
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| skill_file | Path to SKILL.md | (required) |
| level | BASIC or FULL | FULL |

**OWASP AST10 Categories**:
1. Broken Access Control
2. Cryptographic Failures
3. Injection
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable Components
7. Auth Failures
8. Data Integrity Failures
9. Logging Failures
10. SSRF

---

## Auto-Evolution

Continuously improve skills based on usage data.

### Trigger Conditions

| Trigger | Condition |
|---------|-----------|
| Manual | `force=true` |
| Threshold | Score < 475 |
| Scheduled | 24h since last check |
| Usage | F1 < 0.85 or Rate < 0.80 |

### Usage Tracking

```bash
source engine/evolution/usage_tracker.sh

# Track trigger accuracy
track_trigger "skill" "EXPECTED" "ACTUAL"

# Track task completion
track_task "skill" "task_type" "true" 3

# Track feedback
track_feedback "skill" 5 "Great skill!"

# Get summary
get_usage_summary "skill" 7
```

### Run Auto-Evolution

```bash
# Auto mode with usage data
./scripts/optimize-skill.sh SKILL.md auto

# Force evolution
./scripts/optimize-skill.sh SKILL.md auto force
```

---

## CLI Reference

| Command | Purpose |
|---------|---------|
| `./scripts/create-skill.sh` | Create new skills |
| `./scripts/evaluate-skill.sh` | Full evaluation |
| `./scripts/lean-orchestrator.sh` | Fast evaluation (~0s) |
| `./scripts/optimize-skill.sh` | Self-optimization |
| `./scripts/security-audit.sh` | OWASP AST10 audit |
| `./scripts/restore-skill.sh` | Skill restoration |
| `./scripts/quick-score.sh` | Quick text scoring |

---

**Last Updated**: 2026-03-28
