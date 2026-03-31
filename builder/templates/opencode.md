---
name: skill-writer
version: 1.0.0
description: Meta-skill for creating, evaluating, and optimizing skills through natural language
author: skill-writer-builder
license: MIT
tags:
  - meta-skill
  - skill-creation
  - skill-evaluation
  - skill-optimization
  - automation
interface:
  mode:
    type: enum
    values:
      - create
      - evaluate
      - optimize
    default: create
    description: Operating mode for the skill
---

# Skill Writer

> **Type**: Meta-Skill  
> **Platform**: OpenCode  
> **Version**: 1.0.0

A meta-skill that enables AI assistants to create, evaluate, and optimize other skills through natural language interaction. No CLI commands required - just describe what you need.

---

## Overview

Skill Writer provides three powerful modes:

- **CREATE**: Generate new skills from scratch using structured templates
- **EVALUATE**: Assess skill quality with 1000-point scoring and certification
- **OPTIMIZE**: Continuously improve skills through iterative refinement

### Key Features

- **Zero CLI**: Natural language interface - no commands to memorize
- **Cross-Platform**: Works on OpenCode, OpenClaw, Claude, Cursor, OpenAI, and Gemini
- **Template-Based**: 4 built-in templates for common skill patterns
- **Quality Assurance**: Automated evaluation with certification tiers
- **Security Built-In**: CWE-based security pattern detection

---

## Quick Start

### Installation

```bash
# Read the skill file and install
read https://raw.githubusercontent.com/yourusername/skill-writer/main/platforms/skill-writer-opencode.md
```

### Usage Examples

**Create a new skill:**
```
"Create a weather API skill that fetches current conditions"
```

**Evaluate an existing skill:**
```
"Evaluate this skill and give me a quality score"
```

**Optimize a skill:**
```
"Optimize this skill to make it more concise"
```

---

## Triggers

### CREATE Mode Triggers

**Intent Patterns:**
- "create a [type] skill"
- "help me write a skill for [purpose]"
- "I need a skill that [description]"
- "generate a skill to [action]"
- "build a skill for [task]"
- "make a skill that [functionality]"

**Examples:**
- "create a data processing skill"
- "help me write a skill for API integration"
- "I need a skill that analyzes code quality"
- "generate a skill to automate deployments"

### EVALUATE Mode Triggers

**Intent Patterns:**
- "evaluate this skill"
- "check the quality of my skill"
- "certify my skill"
- "score this skill"
- "assess this skill"
- "review this skill"

**Examples:**
- "evaluate this skill and tell me what's wrong"
- "check the quality of my API skill"
- "certify my workflow automation skill"
- "score this skill out of 1000 points"

### OPTIMIZE Mode Triggers

**Intent Patterns:**
- "optimize this skill"
- "improve my skill"
- "make this skill better"
- "refine this skill"
- "enhance this skill"
- "upgrade this skill"

**Examples:**
- "optimize this skill for better performance"
- "improve my skill's error handling"
- "make this skill more user-friendly"
- "refine this skill to be more concise"

---

## CREATE Mode

### 7-Step Workflow

1. **Parse Request**: Analyze intent and extract requirements
2. **Select Template**: Choose from 4 built-in templates
3. **Elicit Requirements**: Ask clarifying questions
4. **Generate Output**: Create skill using template
5. **Security Scan**: Check for CWE vulnerabilities
6. **Quality Check**: Validate structure and completeness
7. **Deliver**: Output final skill file

### Available Templates

**Base Template**: Generic skill structure
- Use for: Simple skills, proof of concepts
- Features: Standard sections, minimal boilerplate

**API Integration**: Skills for external APIs
- Use for: REST API clients, webhooks, integrations
- Features: Endpoint handling, authentication patterns

**Data Pipeline**: Data processing skills
- Use for: ETL, data transformation, analysis
- Features: Input validation, processing steps, output formatting

**Workflow Automation**: Task automation skills
- Use for: CI/CD, repetitive tasks, orchestration
- Features: Step sequencing, error recovery, notifications

### Elicitation Questions

When creating a skill, the system will ask:

1. **Purpose**: What is the primary goal?
2. **Audience**: Who are the target users?
3. **Features**: What capabilities must it have?
4. **Constraints**: Any standards or requirements?
5. **Scale**: Expected usage volume?
6. **References**: Examples to emulate or avoid?

---

## EVALUATE Mode

### 4-Phase Evaluation Pipeline

1. **Structural Analysis**: Check format, sections, completeness
2. **Content Quality**: Assess clarity, examples, instructions
3. **Security Audit**: Scan for CWE patterns
4. **Scoring**: Calculate 1000-point score

### Scoring Rubric (1000 Points Total)

**Completeness (250 points)**
- Required sections present
- All placeholders filled
- Examples provided

**Clarity (250 points)**
- Instructions are clear
- Language is precise
- No ambiguity

**Security (200 points)**
- No CWE violations
- Safe patterns used
- Input validation

**Usability (200 points)**
- Easy to understand
- Good examples
- Clear triggers

**Maintainability (100 points)**
- Well structured
- Documented
- Version controlled

### Certification Tiers

- **PLATINUM (950-1000)**: Exceptional quality
- **GOLD (850-949)**: Production-ready
- **SILVER (750-849)**: Good quality
- **BRONZE (650-749)**: Acceptable
- **FAIL (<650)**: Needs improvement

---

## OPTIMIZE Mode

### 7-Dimension Analysis

1. **Conciseness**: Remove redundancy
2. **Clarity**: Improve understanding
3. **Completeness**: Add missing elements
4. **Security**: Fix vulnerabilities
5. **Performance**: Optimize execution
6. **Maintainability**: Improve structure
7. **Usability**: Enhance user experience

### 9-Step Optimization Loop

1. **Parse**: Understand current skill
2. **Analyze**: Identify improvement areas
3. **Generate**: Create optimized version
4. **Evaluate**: Score the new version
5. **Compare**: Check against previous
6. **Converge**: Detect improvement plateau
7. **Validate**: Ensure correctness
8. **Report**: Show changes
9. **Iterate**: Repeat if needed

### Convergence Detection

Optimization stops when:
- Score improvement < 5 points
- 3 iterations without significant gain
- User requests stop
- Maximum iterations reached (10)

---

## Security Features

### CWE Pattern Detection

Automatically checks for:
- **CWE-78**: OS Command Injection
- **CWE-79**: Cross-Site Scripting (XSS)
- **CWE-89**: SQL Injection
- **CWE-22**: Path Traversal
- And more...

### Security Report Format

```
Security Scan Report
====================
P0: {{p0_count}} violations (Critical)
P1: {{p1_count}} violations (High)
P2: {{p2_count}} violations (Medium)
P3: {{p3_count}} violations (Low)

Recommendations:
- [Specific fixes]
```

---

## Usage Patterns

### Pattern 1: Rapid Skill Creation

```
User: "Create a skill for GitHub issue management"
AI: [Asks 6 elicitation questions]
User: [Answers questions]
AI: [Generates skill using API Integration template]
```

### Pattern 2: Quality Assurance

```
User: "Evaluate this skill"
AI: [Runs 4-phase evaluation]
AI: "Score: 847/1000 (GOLD tier). Issues found:..."
```

### Pattern 3: Continuous Improvement

```
User: "Optimize this skill"
AI: [Runs optimization loop]
AI: "Improved from 720 to 890 points. Changes:..."
```

---

## Configuration

### Environment Variables

```bash
SKILL_WRITER_MODE=create    # Default mode
SKILL_WRITER_VERBOSE=true   # Detailed output
SKILL_WRITER_SAFE_MODE=true # Extra security checks
```

### Custom Templates

Place custom templates in:
```
~/.config/opencode/skills/skill-writer/templates/
```

---

## Troubleshooting

### Common Issues

**Issue**: Skill not triggering
- **Solution**: Check trigger phrases match exactly

**Issue**: Low evaluation score
- **Solution**: Run OPTIMIZE mode for specific improvements

**Issue**: Security warnings
- **Solution**: Review CWE patterns and fix violations

### Debug Mode

Enable debug output:
```
"Enable debug mode for skill writer"
```

---

## Platform-Specific Notes

### OpenCode
- Standard SKILL.md format
- YAML frontmatter required
- Install to: `~/.config/opencode/skills/`

### OpenClaw
- AgentSkills format compatible
- Same structure as OpenCode
- Install to: `~/.openclaw/skills/`

### Claude
- Standard Markdown with YAML frontmatter
- Single H1 header preferred
- Install to: `~/.claude/skills/`

### Cursor
- Uses `${...}` placeholders instead of `{{...}}`
- JSON metadata block instead of YAML frontmatter
- Install to: `~/.cursor/skills/`

### OpenAI
- JSON format with instructions field
- No YAML frontmatter in final output
- Install to platform's skill system

### Gemini
- Standard Markdown with YAML frontmatter
- Similar to OpenCode format
- Install to: `~/.gemini/skills/`

---

## Contributing

### Adding New Templates

1. Create template in `core/create/templates/`
2. Add metadata header
3. Include placeholder documentation
4. Test with CREATE mode

### Adding Platform Support

1. Create adapter in `builder/src/platforms/`
2. Implement required functions
3. Add to platform registry
4. Test build command

---

## License

MIT License - See LICENSE file for details

---

## Support

- **Issues**: https://github.com/yourusername/skill-writer/issues
- **Documentation**: https://github.com/yourusername/skill-writer/docs
- **Examples**: https://github.com/yourusername/skill-writer/examples

---

*Generated by skill-writer-builder v1.0.0*  
*For platform: OpenCode*  
*Last updated: {{generated_at}}*
