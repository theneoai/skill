# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.0.0] - 2026-03-28

### Added
- **RESTORE mode**: Skill restoration for broken/degraded skills
- **SECURITY mode**: OWASP AST10 10-item security audit
- **HUMAN_REVIEW step**: Manual review when score < 8.0 after 10 rounds
- **CURATION step**: Knowledge consolidation every 10 optimization rounds
- **Long-Context Handling**: New 10% weight dimension for chunking strategy
- **EdgeCase Agent**: Multi-LLM boundary condition testing
- **F1/MRR metrics**: Trigger accuracy and mean reciprocal rank tracking
- **Multi-LLM deliberation**: Cross-validation with Anthropic, OpenAI, Kimi
- **9-step optimization loop**: Complete self-evolution cycle
- **docs/API.md**: Complete API reference documentation
- **docs/ARCHITECTURE.md**: Technical architecture overview
- **scripts/**: User-facing CLI tools (create, evaluate, optimize, etc.)
- **tests/**: Organized test structure with unit and integration tests
- **examples/**: Usage examples and workflows

### Changed
- **SKILL.md**: Extended from 283 lines to 793 lines with complete tool documentation
- **engine/evolution/engine.sh**: Rewritten with 9-step loop and multi-LLM deliberation
- **engine/agents/restorer.sh**: New agent for skill restoration
- **engine/agents/security.sh**: New agent for OWASP AST10 security audit
- **eval/**: Separated into proper directory structure

### Removed
- **deprecated/**: Legacy files removed
- **scripts/**: Old scattered scripts removed in favor of organized structure

### Security
- All security checks now use multi-LLM cross-validation
- P0 violations block deployment
- Comprehensive credential, injection, and path traversal checks

## [1.0.0] - 2026-03-27

### Added
- Initial skill creation with orchestrator
- Creator and Evaluator agents
- Basic evaluation framework (4 phases)
- Evolution engine for self-optimization
- Snapshot and rollback mechanism
- Multi-provider LLM support (OpenAI, Anthropic, Kimi, MiniMax)

---

## Migration Guide

### v1.0 → v2.0

**Old workflow:**
```bash
# Create
engine/orchestrator.sh "prompt" output.md BRONZE

# Evaluate
eval/main.sh --skill output.md --fast
```

**New workflow:**
```bash
# Create
./scripts/create-skill.sh "prompt" output.md BRONZE

# Evaluate
./scripts/evaluate-skill.sh output.md

# Security Audit
./scripts/security-audit.sh output.md

# Optimize
./scripts/optimize-skill.sh output.md

# Restore if broken
./scripts/restore-skill.sh broken.md
```
