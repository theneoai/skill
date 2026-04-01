# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-04-01

### ✨ Added

- **LEAN Fast-Eval Mode** — 500-point heuristic evaluator (~1 s, no LLM calls); 8-check rubric with PASS/UNCERTAIN/FAIL decision gates
- **UTE (Use-to-Evolve)** — self-improvement protocol; every skill gains a `§UTE` section and `use_to_evolve:` YAML block; post-invocation hook records usage, detects feedback signals, runs cadence-gated trigger checks (lightweight/full-recompute/tier-drift)
- **LoongFlow Orchestration** — Plan-Execute-Summarize replaces rigid state machines; supports multi-LLM deliberation with consensus check
- **Variance gating** — certification tier requires both score AND variance check: PLATINUM <10, GOLD <15, SILVER <20, BRONZE <30
- **install-claude.sh** — new install script that copies `skill-framework.md` AND companion directories (`refs/`, `templates/`, `eval/`, `optimize/`) to `~/.claude/` so all `claude/` path references resolve at runtime

### 🔄 Changed

- **Canonical rubric**: Phase 1=100 / Phase 2=300 / Phase 3=400 / Phase 4=200 (total 1000)
- **Certification thresholds**: PLATINUM ≥950, GOLD ≥900, SILVER ≥800, BRONZE ≥700, FAIL <700
- **Example skill scores** re-evaluated with v2.0.0 rubric (see table below)
- **`install:claude`** now invokes `install-claude.sh` instead of a single `cp` command
- **`builder/templates/claude.md`**: version bumped to 2.0.0; added LEAN mode triggers; added ZH triggers for all four modes; scoring rubric corrected to 4-phase structure; `interface:` frontmatter field added
- **`builder/src/commands/inspect.js`**: `getBuiltSkillPath` now checks flat `skill-writer-<platform>-dev.md` pattern first, fixing inspect for all platforms
- **`builder/src/commands/build.js`**: adds `p0_count`, `p1_count`, `p2_count`, `p3_count`, `generated_at` to `skillMetadata` so security stats render correctly
- `package.json` version bumped 1.0.0 → 2.0.0; `yourusername` placeholders replaced with `theneoai`
- CONTRIBUTING.md, README.md: `yourusername` placeholders replaced with `theneoai`

### 🔧 Fixed

- All three example skills: injected complete `§UTE` body section and `use_to_evolve:` YAML with all 11 fields
- `code-reviewer/skill.md`: all section headers converted to `## §N` format; Red Lines (§3) added; `created`/`updated` dates added
- `doc-generator/skill.md`: LEAN, evaluate, optimize, 快评, 评测, 优化 triggers added to trigger line
- `api-tester/skill.md`: `{{API_BASE_URL}}` placeholder replaced; `certified_lean_score` corrected 470 → 390; UTE YAML completed with all 11 fields
- All three `eval-report.md` files: rewritten to use canonical 100/300/400/200 rubric and correct certification thresholds (GOLD ≥900, SILVER ≥800)
- `skill-framework.md`: PATH CONVENTION comment block added; `updated` date refreshed

### 📊 Updated Certification Stats

| Skill | Type | Tier | Score (v2.0.0) |
|-------|------|------|----------------|
| api-tester | api-integration | 🥇 GOLD | 920/1000 |
| code-reviewer | workflow-automation | 🥈 SILVER | 820/1000 |
| doc-generator | data-pipeline | 🥇 GOLD | 895/1000 |

**Average Score: 878.3/1000**

---

## [1.0.0] - 2026-03-31

### 🎉 Initial Release

Skill Framework MVP - Production Ready

### ✨ Added

- **Core Framework**
  - 1000-point evaluation system with 4-phase pipeline
  - Multi-LLM deliberation mechanism (Generator/Reviewer/Arbiter)
  - Self-evolution system with 3 triggers (Threshold/Time/Usage)
  - Native bilingual support (Chinese & English)

- **Example Skills** (3 certified skills, average score: 938.3/1000)
  - `api-tester` - HTTP API testing automation (GOLD 920/1000)
  - `code-reviewer` - Code review with security scanning (PLATINUM 960/1000)
  - `doc-generator` - Documentation generation pipeline (GOLD 935/1000)

- **GitHub Community**
  - Issue templates (skill submission, bug report, feature request)
  - GitHub Actions workflow for stale issue management
  - Code of Conduct based on Contributor Covenant
  - Contributing guidelines
  - Security policy with CWE scanning

- **Documentation**
  - Comprehensive README with badges and Mermaid architecture diagram
  - Project summary with certification details
  - This changelog

### 🏆 Certification Stats

| Skill | Type | Tier | Score |
|-------|------|------|-------|
| api-tester | api-integration | 🥇 GOLD | 920/1000 |
| code-reviewer | workflow-automation | 🏆 PLATINUM | 960/1000 |
| doc-generator | data-pipeline | 🥇 GOLD | 935/1000 |

**Average Score: 938.3/1000**

### 📊 Project Metrics

- Total Files: 17
- Total Lines: 3,250+
- Example Skills: 3
- GitHub Templates: 3
- CI/CD Workflows: 1

### 🔗 Links

- [Repository](https://github.com/theneoai/skill-writer)
- [Documentation](https://github.com/theneoai/skill-writer#readme)
- [Examples](https://github.com/theneoai/skill-writer/tree/main/examples)
- [Contributing](https://github.com/theneoai/skill-writer/blob/main/.github/CONTRIBUTING.md)

---

## Release Template

### [Unreleased]

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Now removed features

### Fixed
- Bug fixes

### Security
- Security improvements

[2.0.0]: https://github.com/theneoai/skill-writer/releases/tag/v2.0.0
[1.0.0]: https://github.com/theneoai/skill-writer/releases/tag/v1.0.0
