# Examples

> Usage examples for the skill system

---

## Basic Usage

### Create Your First Skill

```bash
# Create a simple skill
./scripts/create-skill.sh "Create a code review skill"

# With specific output and tier
./scripts/create-skill.sh "Create a code review skill" ./code-review.md GOLD
```

### Evaluate a Skill

```bash
# Fast evaluation (~2 minutes)
./scripts/evaluate-skill.sh ./code-review.md

# Full evaluation (~10 minutes)
./scripts/evaluate-skill.sh ./code-review.md full
```

### Optimize a Skill

```bash
# Run up to 20 optimization rounds
./scripts/optimize-skill.sh ./code-review.md

# Custom round limit
./scripts/optimize-skill.sh ./code-review.md 10
```

---

## Advanced Usage

### Security Audit

```bash
# Full OWASP AST10 audit
./scripts/security-audit.sh ./code-review.md

# Basic scan only
./scripts/security-audit.sh ./code-review.md BASIC
```

### Restore a Broken Skill

```bash
./scripts/restore-skill.sh ./broken-skill.md
```

### Quick Score (No LLM)

```bash
# Fast text quality check
./scripts/quick-score.sh ./code-review.md
```

---

## Programmatic Usage

### Using Engine Directly

```bash
# Create with orchestrator
engine/orchestrator.sh "Create a code review skill" ./code-review.md BRONZE

# Evaluate directly
eval/main.sh --skill ./code-review.md --fast
```

### Using Library Functions

```bash
source engine/lib/bootstrap.sh

# Load modules
require constants concurrency errors

# Acquire lock
acquire_lock "my_lock" 30 || exit 1
trap "release_lock 'my_lock'" EXIT

# Create snapshot
snapshot=$(create_snapshot "./code-review.md" "pre-change")

# Do work...

# Cleanup on failure
rollback_to "$snapshot" "./code-review.md"
```

---

## Workflow Examples

### Complete Skill Lifecycle

```bash
# 1. Create skill
./scripts/create-skill.sh "Create a code review skill" ./code-review.md

# 2. Evaluate initial quality
./scripts/evaluate-skill.sh ./code-review.md

# 3. Run security audit
./scripts/security-audit.sh ./code-review.md

# 4. Optimize if needed
./scripts/optimize-skill.sh ./code-review.md

# 5. Final evaluation
./scripts/evaluate-skill.sh ./code-review.md full
```

### Fixing a Broken Skill

```bash
# Try to restore
./scripts/restore-skill.sh ./broken-skill.md

# If restoration fails, try manual fix then evaluate
./scripts/evaluate-skill.sh ./broken-skill.md

# Optimize to improve
./scripts/optimize-skill.sh ./broken-skill.md
```

---

## CI/CD Integration

### GitHub Actions

```yaml
- name: Evaluate Skill
  run: |
    ./scripts/evaluate-skill.sh ./SKILL.md

- name: Check Results
  run: |
    if [[ -f eval_results/summary.json ]]; then
      score=$(jq '.total_score' eval_results/summary.json)
      if (( $(echo "$score < 600" | bc -l) )); then
        echo "Score $score below BRONZE threshold"
        exit 1
      fi
    fi
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running pre-commit checks..."

# Fast evaluation
./scripts/evaluate-skill.sh ./SKILL.md fast

# Check score
if (( $(jq '.total_score' eval_results/summary.json) < 600 )); then
    echo "SKILL.md failed quality gate"
    exit 1
fi
```
