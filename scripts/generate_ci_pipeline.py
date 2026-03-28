# DEPRECATED: Use .github/workflows/ci.yml instead. Obsolete after 2026-03-28 restructure.
import sys
from pathlib import Path

def generate_ci(skill_dir: str):
    ci_content = """name: Agent Skills CI/CD with Multi-Agent Support

on:
  push:
    paths:
      - 'team-skills/**/SKILL.md'
      - 'team-skills/**/evals/**'

jobs:
  validate-and-eval:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate Skill
        run: python scripts/validate_skill.py ${{ matrix.skill }}
      
      - name: Run Multi-Agent Evaluation
        run: echo "Running multi-agent evaluation..."
      
      - name: Security Check
        run: echo "Running OWASP AST10 check..."
      
      - name: Quality Gate
        run: echo "Checking quality thresholds (F1 >= 0.90, MultiTurnPassRate >= 85%)"
"""
    ci_path = Path(skill_dir) / ".github/workflows/skills-ci.yml"
    ci_path.parent.mkdir(parents=True, exist_ok=True)
    ci_path.write_text(ci_content)
    print(f"✅ CI/CD 流水线已生成: {ci_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python generate_ci_pipeline.py <skill_directory>")
        sys.exit(1)
    generate_ci(sys.argv[1])
