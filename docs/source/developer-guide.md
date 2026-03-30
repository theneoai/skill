# Developer Guide

This guide is for developers building AI agents and integrations that consume or produce skills.

## SKILL.md Format

The SKILL.md file is the universal skill definition format.

### Frontmatter Schema

```yaml
---
name: skill-name
version: 1.0.0
description:
  en: "English description"
  zh: "中文描述"
license: MIT
author:
  name: Author Name
  email: author@example.com
tags: [lifecycle, quality-assurance]
interface:
  input: user-natural-language
  output: structured-skill
  modes: [create, evaluate, restore, security, optimize]
extends:
  evaluation:
    metrics: [f1, mrr]
    thresholds: {f1: 0.90, mrr: 0.85}
    external:
      - id: openai-evals
        name: OpenAI Evals API
        url: https://platform.openai.com/docs/guides/evals
        metrics: [accuracy]
---
```

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| name | string | Unique skill identifier |
| description | string|dict | Human-readable description |
| version | string | Semver format (x.y.z) |

### Optional Fields

| Field | Type | Default |
|-------|------|---------|
| license | string | MIT |
| author | string|dict | null |
| tags | list[string] | [] |
| interface.input | string | user-natural-language |
| interface.output | string | structured-skill |
| interface.modes | list[string] | all modes |
| extends.evaluation.metrics | list[string] | [f1, mrr] |
| extends.evaluation.thresholds | dict | {f1: 0.90, mrr: 0.85} |

## Python API

### Parse SKILL.md

```python
from skill.yaml_parser import parse_skill_file
from pathlib import Path

metadata = parse_skill_file(Path("SKILL.md"))
print(f"Name: {metadata.name}")
print(f"Version: {metadata.version}")
```

### Generate SKILL.md

```python
from skill.md_generator import generate_frontmatter, generate_skill_md
from skill.schema import SkillMetadata, Mode, Tier

metadata = SkillMetadata(
    name="my-skill",
    description="A useful skill",
    version="1.0.0",
    modes=[Mode.CREATE, Mode.EVALUATE],
    tier=Tier.GOLD,
)

frontmatter = generate_frontmatter(metadata)
print(frontmatter)
```

### Validate Metadata

```python
from skill.schema import SkillMetadata

metadata = SkillMetadata(
    name="test",
    description="Test skill",
    version="1.0.0",
)
errors = metadata.validate()
if errors:
    print(f"Validation errors: {errors}")
```

## CLI Development

### Add New Command

1. Add command function in skill/cli/commands.py:

```python
def new_command(args):
    """New command implementation."""
    pass
```

2. Register in skill/cli/main.py:

```python
subparsers.add_parser("new-command", help="New command")
```

3. Add tests in tests/unit/test_cli.py

## Integrating with MCP

Skills can be exposed via MCP (Model Context Protocol):

```json
{
  "mcpServers": {
    "skill-engine": {
      "type": "stdio",
      "command": "skill",
      "args": ["mcp", "serve"]
    }
  }
}
```

## Cross-Vendor Compatibility

### MCP Compatibility

Skills follow MCP tool definition format:
- name: Tool identifier
- description: Human-readable description
- inputSchema: JSON Schema for parameters

### Microsoft Copilot Compatibility

SKILL.md maps to declarative agent manifest:
- name → agent name
- description → agent description
- author → author info
- interface.modes → capabilities

### OpenAI Agents Compatibility

SKILL.md interface section maps to agent tools:
- Tools defined in capabilities
- Authentication in security

## Testing

```bash
# Run all tests
python -m pytest tests/unit/ -v

# Run specific test file
python -m pytest tests/unit/test_yaml_parser.py -v

# Run with coverage
python -m pytest tests/unit/ --cov=skill --cov-report=html
```

## Further Reading

- [Architecture](architecture.md) - System design
- [API Reference](api-reference.md) - Complete API docs
- [SKILL.md](../SKILL.md) - Full format specification
