# Getting Started

This guide helps you install Skill Engineering and create your first skill.

## Installation

### From PyPI (Recommended)

```bash
pip install skill-engineering
```

### From Source

```bash
git clone https://github.com/theneoai/skill.git
cd skill
pip install -e .
```

### Verify Installation

```bash
skill --version
# or
python -m skill.cli.main --version
```

## Quick Start

### Evaluate an Existing Skill

```bash
skill evaluate ./SKILL.md
```

### Create a New Skill

```bash
skill create "Create a skill that fetches weather data from OpenWeather API"
```

### Parse and Validate

```bash
# Parse SKILL.md and show metadata
skill parse ./SKILL.md

# Validate skill structure
skill validate ./SKILL.md
```

## Configuration

Skill Engineering uses sensible defaults. Configuration is optional.

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| SKILL_DATA_DIR | ~/.skill | Data directory for skills |
| SKILL_LLM_PROVIDER | openai | Default LLM provider |
| SKILL_EVAL_THRESHOLD | 0.90 | F1 score threshold |

### Skill Search Paths

Skills are searched in:
1. Current directory
2. ~/.skill/skills/
3. Paths in SKILL_PATH environment variable

## Next Steps

- Read the [User Guide](user-guide.md) for detailed workflow instructions
- See the [Architecture](architecture.md) to understand the system design
- Check the [API Reference](api-reference.md) for CLI and Python API details
