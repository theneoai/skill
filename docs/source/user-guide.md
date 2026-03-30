# User Guide

This guide covers operational workflows for end users of Skill Engineering.

## Modes Overview

Skill Engineering supports five operational modes:

| Mode | Use Case | Keywords |
|------|----------|----------|
| CREATE | Build new skills | create, build, new |
| EVALUATE | Test quality | evaluate, test, score |
| RESTORE | Fix broken skills | restore, repair, fix |
| SECURITY | Scan for vulnerabilities | security, audit, scan |
| OPTIMIZE | Improve performance | optimize, improve |

## CREATE Mode

Create a new skill from requirements.

### Syntax

```bash
skill create "<description>"
```

### Example

```bash
skill create "Create a skill that queries GitHub API for repo stats"
```

### Output

```
Mode: CREATE | Confidence: 0.87 | Language: EN
Creating skill...
✓ Skill created: github-stats | v1.0.0 | TIER: GOLD
Quality: F1=0.94, MRR=0.91
```

## EVALUATE Mode

Evaluate an existing skill's quality.

### Syntax

```bash
skill evaluate <skill-path>
```

### Example

```bash
skill evaluate ./skills/weather-query/SKILL.md
```

### Quality Thresholds

| Metric | Threshold | Description |
|--------|-----------|-------------|
| F1 | ≥ 0.90 | Trigger accuracy |
| MRR | ≥ 0.85 | Mean reciprocal rank |

### Certification Tiers

| Tier | Score | Badge |
|------|-------|-------|
| PLATINUM | ≥950 | 💎 |
| GOLD | ≥900 | 🥇 |
| SILVER | ≥800 | 🥈 |
| BRONZE | ≥700 | 🥉 |

## RESTORE Mode

Restore a broken or degraded skill.

### Syntax

```bash
skill restore <skill-path>
```

### Example

```bash
skill restore ./skills/broken-skill/SKILL.md
```

### When to Use

- Skill fails validation
- Quality metrics below threshold
- Security scan failures
- Corrupted files

## SECURITY Mode

Run CWE-based security audit.

### Syntax

```bash
skill security <skill-path>
```

### Example

```bash
skill security ./skills/api-skill/SKILL.md
```

### Checks Performed

- Hardcoded credentials (CWE-798)
- SQL injection (CWE-89)
- XSS vulnerabilities (CWE-79)
- Code injection (CWE-94)
- Path traversal
- Command injection

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed |
| 1 | Security issues found |
| 2 | Scan error |

## OPTIMIZE Mode

Autonomously improve skill performance.

### Syntax

```bash
skill optimize <skill-path>
```

### Example

```bash
skill optimize ./skills/legacy-skill/SKILL.md
```

### Triggers

| Trigger | Condition | Action |
|---------|------------|--------|
| F1 | < 0.90 | Auto-flag for refactor |
| MRR | < 0.85 | Auto-flag for refactor |
| Time | 30 days stale | Schedule review |
| Usage | < 5 invocations/90 days | Deprecate or refresh |

## Troubleshooting

### Skill Validation Fails

1. Run skill validate <path> to see errors
2. Check required fields in SKILL.md
3. Ensure description is ≥10 characters
4. Verify YAML syntax

### Quality Below Threshold

1. Run skill evaluate <path> for detailed metrics
2. Use skill optimize <path> to improve
3. Review trigger patterns in refs/triggers.md

### Security Scan Fails

1. Run skill security <path> for detailed findings
2. Fix reported CWE violations
3. Re-run security scan
4. Do not deploy until all P0 issues resolved
