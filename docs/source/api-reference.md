# API Reference

Complete reference for Skill Engineering CLI and Python API.

## CLI Commands

### skill create

Create a new skill from description.

```bash
skill create [OPTIONS] DESCRIPTION
```

**Options:**
| Option | Description |
|--------|-------------|
| -o, --output PATH | Output path for skill |
| -t, --tier TIER | Initial tier (bronze/silver/gold/platinum) |

**Examples:**
```bash
skill create "Weather skill"
skill create "API skill" -o ./skills/weather
```

### skill evaluate

Evaluate skill quality.

```bash
skill evaluate [OPTIONS] SKILL_PATH
```

**Options:**
| Option | Description |
|--------|-------------|
| --fast | Skip deep evaluation |
| --output FORMAT | Output format (text/json) |

**Examples:**
```bash
skill evaluate ./SKILL.md
skill evaluate ./SKILL.md --fast --output json
```

### skill parse

Parse and display SKILL.md metadata.

```bash
skill parse SKILL_PATH
```

**Example Output:**
```
Name: weather-query
Version: 1.0.0
Description: Fetches weather data from OpenWeather API
Author: theneoai
Modes: CREATE, EVALUATE, OPTIMIZE
Tier: GOLD
```

### skill validate

Validate SKILL.md structure.

```bash
skill validate SKILL_PATH
```

**Exit Codes:**
| Code | Meaning |
|------|---------|
| 0 | Valid |
| 1 | Invalid |

### skill security

Run security audit.

```bash
skill security [OPTIONS] SKILL_PATH
```

**Options:**
| Option | Description |
|--------|-------------|
| --standard STANDARD | Security standard (CWE/OWASP) |
| --level LEVEL | Minimum severity (low/medium/high/critical) |

### skill optimize

Optimize skill performance.

```bash
skill optimize [OPTIONS] SKILL_PATH
```

**Options:**
| Option | Description |
|--------|-------------|
| --rounds N | Maximum optimization rounds |
| --target F1 | Target F1 score |

### skill restore

Restore a broken skill.

```bash
skill restore SKILL_PATH
```

## Python API

### skill.schema

```python
from skill.schema import (
    SkillMetadata,
    Mode,
    Tier,
    AuthorInfo,
    InterfaceContract,
    ExternalEvaluator,
)
```

#### SkillMetadata

```python
metadata = SkillMetadata(
    name="my-skill",
    description="A skill description",
    version="1.0.0",
    license="MIT",
    author="author-name",
    tags=["tag1", "tag2"],
    modes=[Mode.CREATE, Mode.EVALUATE],
    tier=Tier.GOLD,
)
```

#### Methods

| Method | Description |
|--------|-------------|
| validate() | Returns list of validation errors |
| to_dict() | Convert to dictionary |
| from_dict(dict) | Create from dictionary |
| from_yaml(str) | Parse from YAML string |

### skill.yaml_parser

```python
from skill.yaml_parser import parse_skill_file, extract_frontmatter
```

#### Functions

| Function | Description |
|----------|-------------|
| parse_skill_file(Path) | Parse entire SKILL.md file |
| extract_frontmatter(str) | Extract YAML frontmatter |
| validate_metadata(dict) | Validate frontmatter dict |

### skill.md_generator

```python
from skill.md_generator import generate_frontmatter, generate_skill_md
```

#### Functions

| Function | Description |
|----------|-------------|
| generate_frontmatter(SkillMetadata) | Generate YAML frontmatter |
| generate_skill_md(SkillMetadata, dict) | Generate full SKILL.md |
| render_table(list, list) | Render markdown table |
| render_decision_tree(dict) | Render ASCII tree |

### skill.cli.main

```python
from skill.cli.main import main
```

Entry point for CLI. Use via skill command or python -m skill.cli.main.

## Error Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Validation error |
| 2 | File not found |
| 3 | Permission denied |
| 4 | Security violation |
| 5 | Optimization failed |

## Exit Conditions

| Condition | Description |
|-----------|-------------|
| SUCCESS | All phases complete, quality gates passed |
| TEMP_CERT | Delivered with 72hr review flag |
| HUMAN_REVIEW | Escalated for manual review |
| ABORT | Security red line violation |
