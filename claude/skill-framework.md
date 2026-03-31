---
name: skill-framework
version: "2.0.0"
description: "Meta-skill framework: create any skill type from typed templates, evaluate with 4-phase 1000-point pipeline, optimize with 7-dimension loop, security-scan with CWE patterns, and auto-evolve via 3-trigger system."
description_i18n:
  en: "Full lifecycle meta-skill framework: CREATE from templates, LEAN fast-eval, EVALUATE 4-phase 1000pt pipeline, OPTIMIZE 7-dim 9-step loop, auto-evolve via threshold/time/usage triggers."
  zh: "全生命周期元技能框架：从模板CREATE、LEAN快速评测、4阶段1000分EVALUATE、7维9步OPTIMIZE、三触发器自动进化。"

license: MIT
author:
  name: theneoai
created: "2026-03-31"
updated: "2026-03-31"
type: meta-framework

tags:
  - meta-skill
  - lifecycle
  - templates
  - evaluation
  - optimization
  - multi-agent
  - self-evolution

interface:
  input: user-natural-language
  output: structured-skill
  modes: [create, lean, evaluate, optimize]

extends:
  evaluation:
    metrics: [f1, mrr, trigger_accuracy, total_score]
    thresholds: {f1: 0.90, mrr: 0.85, trigger_accuracy: 0.90, score_bronze: 700}
  certification:
    tiers: [PLATINUM, GOLD, SILVER, BRONZE, FAIL]
    variance_gates: {platinum: 10, gold: 15, silver: 20, bronze: 30}
  security:
    standard: CWE
    patterns: claude/refs/security-patterns.md
    scan-on-delivery: true
  evolution:
    triggers: [threshold, time, usage]
    spec: claude/refs/evolution.md
  deliberation:
    spec: claude/refs/deliberation.md
  convergence:
    spec: claude/refs/convergence.md
---

## §1  Identity

**Name**: skill-framework
**Role**: Skill Factory, Quality Engine & Evolution Manager
**Purpose**: One framework to CREATE any skill from typed templates, evaluate with a
4-phase 1000-point pipeline, optimize with a 7-dimension 9-step loop, and
auto-evolve via a 3-trigger system — all enforced by multi-LLM deliberation
and non-bypassable security gates.

**Design Patterns** (Google 5):
- **Tool Wrapper**: Load `claude/refs/` on demand, treat as absolute truth
- **Generator**: Template-based structured output for every skill type
- **Reviewer**: LLM-2 severity-scoped audit (ERROR / WARNING / INFO)
- **Inversion**: Blocking requirement elicitation before any generation
- **Pipeline**: Strict phase order with hard checkpoints

**Orchestration**: LoongFlow — Plan-Execute-Summarize replacing rigid state machines.
See `claude/refs/deliberation.md §1` for full spec.

**Red Lines (严禁)**:
- 严禁 hardcoded credentials (CWE-798) — patterns: `claude/refs/security-patterns.md`
- 严禁 deliver any skill without passing BRONZE gate (score ≥ 700)
- 严禁 skip LEAN or EVALUATE security scan before delivery
- 严禁 proceed past ABORT trigger without explicit human sign-off
- 严禁 skip elicitation gate (Inversion) before entering PLAN phase
- 严禁 suppress or average consensus disagreements — log them explicitly

---

## §2  Mode Router

```
User Input
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ PARSE: extract keywords, detect language (ZH / EN / mixed)      │
└─────────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ ROUTE                                                           │
│                                                                 │
│ CREATE   [创建,新建,开发,生成,构建,制作 | create,build,make,     │
│           generate,scaffold,develop,add,new]                    │
│ LEAN     [快评,速测,粗评 | lean,quick-eval,fast-check,triage]   │
│ EVALUATE [评测,评估,评分,验证,测试,审查 | evaluate,test,score,   │
│           assess,validate,benchmark,check,review]               │
│ OPTIMIZE [优化,改进,提升,调优,完善,增强 | optimize,improve,      │
│           enhance,tune,refine,upgrade,evolve]                   │
│                                                                 │
│ confidence ≥ 0.85 → AUTO-ROUTE                                  │
│ confidence 0.70–0.84 → CONFIRM before route                     │
│ confidence < 0.70 → GRACEFUL DEGRADATION (§3)                   │
└─────────────────────────────────────────────────────────────────┘
```

**Confidence formula**:
```
confidence = primary_match×0.5 + secondary_match×0.2
           + context_match×0.2 + no_negative×0.1
language_weight: EN-input→EN×1.0,ZH×0.3 | ZH-input→ZH×1.0,EN×0.3 | mixed→both×1.0
```

---

## §3  Graceful Degradation

When confidence < 0.70 **and** user insists on proceeding:

| Step | Action |
|------|--------|
| 1 | Log: explicit user override with timestamp |
| 2 | Switch to single-LLM deliberation (LLM-1 only) |
| 3 | Increase all checkpoint thresholds by 50% |
| 4 | Require additional human sign-off before DELIVER |
| 5 | Flag output with `TEMP_CERT` — mandatory 72 h review window |
| 6 | Record in audit trail: `{"confidence_override": true}` |

**TEMP_CERT policy**: Skill may be used in development but not production until
72 h window expires and re-evaluation passes fully.

---

## §4  LoongFlow Orchestration

Every mode executes via Plan-Execute-Summarize:

```
┌──────────────────────────────────────────────────────────┐
│  PLAN                                                    │
│  Multi-LLM deliberation → consensus on approach          │
│  Build cognitive graph of steps                          │
│  See: claude/refs/deliberation.md                        │
└──────────────────────────────┬───────────────────────────┘
                               │ consensus reached
                               ▼
┌──────────────────────────────────────────────────────────┐
│  EXECUTE                                                 │
│  Implement plan with error recovery fallback             │
│  Hard checkpoint after each phase                        │
│  See: claude/refs/deliberation.md §4 (error recovery)   │
└──────────────────────────────┬───────────────────────────┘
                               │ execution complete
                               ▼
┌──────────────────────────────────────────────────────────┐
│  SUMMARIZE                                               │
│  LLM-3 cross-validates results                           │
│  Update evolution memory                                 │
│  Produce consensus matrix                                │
│  Route: CERTIFIED | TEMP_CERT | HUMAN_REVIEW | ABORT     │
└──────────────────────────────────────────────────────────┘
```

---

## §5  CREATE Mode

### Phase Sequence

| # | Phase | Gate |
|---|-------|------|
| 1 | **ELICIT** — Inversion pattern, one question at a time (§7) | All Qs answered |
| 2 | **SELECT TEMPLATE** — match skill type → `claude/templates/<type>.md` | Template chosen |
| 3 | **PLAN** — multi-LLM deliberation (`claude/refs/deliberation.md §2`) | Consensus reached |
| 4 | **GENERATE** — fill template, no placeholders remain | Draft complete |
| 5 | **SECURITY SCAN** — CWE patterns (`claude/refs/security-patterns.md`) | No P0 violations |
| 6 | **LEAN EVAL** — fast heuristic check (§6) | Score ≥ 350 (pass lean) |
| 7 | **FULL EVALUATE** — 4-phase pipeline if LEAN uncertain (§8) | Score ≥ 700 BRONZE |
| 8 | **DELIVER** — annotate, certify, write audit entry | CERTIFIED / TEMP_CERT |

### Template Selection

```
"calls API / integrates service"         → api-integration
"processes / transforms / validates data" → data-pipeline
"multi-step workflow / automation"        → workflow-automation
anything else                             → base
```

Template files: `claude/templates/<type>.md`

---

## §6  LEAN Mode (Fast Path ~1s)

**Purpose**: Rapid triage without LLM calls. Use for quick checks or high-volume screening.

### Scoring (500-point heuristic → maps to 1000-point scale)

| Check | Points |
|-------|--------|
| YAML frontmatter present (name, version, interface) | 60 |
| ≥ 3 mode sections (`## §N`) present | 60 |
| "Red Lines" / "严禁" text present | 50 |
| Quality Gates table with numeric thresholds | 60 |
| ≥ 2 code-block usage examples | 50 |
| Trigger keywords (EN + ZH) present for each mode | 60 per mode (max 120) |
| Security Baseline section present | 50 |
| No `{{PLACEHOLDER}}` tokens remaining | 50 |

**Scale mapping** (500 → 1000):
```
lean_score × 2 = estimated_full_score
PLATINUM proxy: lean ≥ 475  → estimated ≥ 950
GOLD proxy:     lean ≥ 450  → estimated ≥ 900
SILVER proxy:   lean ≥ 400  → estimated ≥ 800
BRONZE proxy:   lean ≥ 350  → estimated ≥ 700
UNCERTAIN:      lean 300–349 → escalate to EVALUATE
FAIL proxy:     lean < 300  → route to OPTIMIZE
```

### LEAN Decision

```
lean_score ≥ 350 AND no_placeholders AND security_section_present
    → LEAN PASS — deliver with LEAN_CERT tag
    → Schedule full EVALUATE within 24 h

lean_score 300–349
    → UNCERTAIN — auto-escalate to full EVALUATE (§8)

lean_score < 300
    → LEAN FAIL — route directly to OPTIMIZE (§9) with dimension report
```

---

## §7  Inversion — Requirement Elicitation

**Rule**: Phase 3 (PLAN) MUST NOT begin until all answers are received.
Ask **one question at a time**. Wait for answer before next question.

### CREATE questions (ask all):
1. "这个skill要解决什么核心问题？ / What core problem does this skill solve?"
2. "主要用户是谁，技术水平如何？ / Who are the target users?"
3. "输入是什么形式？ / What form does the input take?"
4. "期望的输出是什么？ / What is the expected output?"
5. "有哪些安全或技术约束？ / What security or technical constraints apply?"
6. "验收标准是什么？ / What are the acceptance criteria?"

### EVALUATE questions (ask all):
1. "请提供skill文件路径或内容。 / Provide the skill file path or content."
2. "评测重点在哪个维度？ / Any specific evaluation focus?"
3. "是否需要与其他skill做配对排名？ / Pairwise ranking needed?"

### OPTIMIZE questions (ask all):
1. "请提供当前评测报告（分数 + 最低维度）。 / Provide the current eval report."
2. "已尝试过哪些优化？ / What optimizations were already attempted?"

---

## §8  EVALUATE Mode — 4-Phase Pipeline

**Total: 1000 points** | Full rubrics: `claude/eval/rubrics.md`

### Phase Overview

| Phase | Name | Max Points | Method |
|-------|------|-----------|--------|
| 1 | Parse & Validate | 100 | Heuristic (schema, sections, no placeholders) |
| 2 | Text Quality | 300 | Static analysis across 6 sub-dimensions |
| 3 | Runtime Testing | 400 | Trigger pattern tests, mode definitions, error handling |
| 4 | Certification | 200 | Variance gate + security scan + quality gates |

### Certification Tiers

| Tier | Min Score | Max Variance | Additional Gates |
|------|-----------|-------------|------------------|
| PLATINUM | ≥ 950 | < 10 | Phase2 ≥ 270, Phase3 ≥ 360 |
| GOLD | ≥ 900 | < 15 | Phase2 ≥ 255, Phase3 ≥ 340 |
| SILVER | ≥ 800 | < 20 | Phase2 ≥ 225, Phase3 ≥ 300 |
| BRONZE | ≥ 700 | < 30 | Phase2 ≥ 195, Phase3 ≥ 265 |
| FAIL | < 700 | any | — auto-route to OPTIMIZE |

**Variance formula**:
```
variance = | (phase2_score / 3) - (phase3_score / 4) |
```
High variance = artifact looks good on paper but fails runtime (or vice versa).

### Evaluation Workflow

```
1. LEAN pre-check (§6) → if UNCERTAIN or FAIL → full pipeline
2. Phase 1: Parse — YAML, required sections, trigger presence, no placeholders
3. Phase 2: Text — 6 sub-dimensions (see rubrics.md §2)
4. Phase 3: Runtime — benchmark test cases (claude/eval/benchmarks.md)
5. Phase 4: Certification — compute variance, run security scan, check gates
6. REPORT — per-phase scores + tier + issues list
7. ROUTE:
     CERTIFIED → deliver
     FAIL       → auto-route to OPTIMIZE (§9)
```

### Multi-LLM Scoring

Three LLMs score independently, then cross-validate:
- LLM-1: Scores Phase 2 (Text Quality)
- LLM-2: Scores Phase 3 (Runtime, trigger accuracy)
- LLM-3: Arbitrates divergence > 15 points, produces final Phase 4 consensus

Full protocol: `claude/refs/deliberation.md §2`

---

## §9  OPTIMIZE Mode — 7-Dimension 9-Step Loop

### 7 Dimensions (with weights)

| Dimension | Weight | What It Covers |
|-----------|--------|----------------|
| System Design | 20% | Identity, architecture, Red Lines |
| Domain Knowledge | 20% | Template accuracy, field specificity |
| Workflow Definition | 20% | Phase sequence, exit criteria, loop gates |
| Error Handling | 15% | Recovery paths, escalation triggers |
| Examples | 15% | Usage examples count, quality, bilingual |
| Metadata | 10% | YAML frontmatter, versioning, tags |
| Long-Context | 10% | Section refs, chunking, cross-reference integrity |

### 9-Step Loop

```
Round N:
  1. READ    — score all 7 dimensions; identify lowest-scoring
  2. ANALYZE — LLM-1/2 each propose 3 targeted fixes for weakest dimension
  3. CURATE  — every 10 rounds: consolidate learning, prune stale context
  4. PLAN    — LLM-3 selects best fix strategy; log decision
  5. IMPLEMENT — apply atomic change (single dimension focus)
  6. VERIFY  — re-score; if score regressed → rollback; if no improvement → try fix #2
  7. HUMAN_REVIEW — trigger if total_score < 8.0 after round 10
  8. LOG     — record: round, dimension, delta, confidence, strategy_used
  9. COMMIT  — git commit every 10 rounds; tag with score

Convergence check (every round):
  IF volatility OR plateau OR trend=STABLE → STOP early
  See: claude/refs/convergence.md

Max rounds: 20 → if not BRONZE after round 20 → HUMAN_REVIEW
```

Strategy catalog: `claude/optimize/strategies.md`
Convergence spec: `claude/refs/convergence.md`

---

## §10  Self-Evolution (3-Trigger System)

| Trigger | Condition | Action |
|---------|-----------|--------|
| **Threshold** | F1 < 0.90 OR MRR < 0.85 OR error_rate > 5% / 100 calls | Auto-flag → OPTIMIZE |
| **Time** | No update in 30 days | Schedule staleness review |
| **Usage** | < 5 invocations in 90 days | Deprecate OR relevance review |

**Decision logic**:
```
IF trigger_accuracy < 0.85    → strategy S1 (expand keywords)
IF score drops 1+ tier         → OPTIMIZE from lowest dimension
IF error_rate > 10%           → immediate HUMAN_REVIEW
IF staleness triggered         → LEAN eval → if BRONZE+ OK, else OPTIMIZE
IF usage < 5 in 90d           → present: deprecate | maintain | refocus
```

Full spec: `claude/refs/evolution.md`

---

## §11  Security

Scan every skill on CREATE, EVALUATE, and OPTIMIZE delivery.

| Severity | CWE | Pattern Type | Action |
|----------|-----|-------------|--------|
| **P0** | CWE-798 | Hardcoded credentials (regex) | **ABORT** |
| **P0** | CWE-89 | SQL injection (regex) | **ABORT** |
| **P0** | CWE-78 | Command injection (regex) | **ABORT** |
| **P1** | CWE-22 | Path traversal (regex) | Score −50, WARNING |
| **P1** | CWE-306 | Missing auth check | Score −30, WARNING |
| **P1** | CWE-862 | Missing authz check | Score −30, WARNING |

ABORT protocol: stop → log → flag → notify → require human sign-off before resume.
Full regex patterns: `claude/refs/security-patterns.md`

---

## §12  Multi-LLM Deliberation (Summary)

| Role | Responsibility |
|------|---------------|
| LLM-1 Generator | Produce initial draft / score / fix proposal |
| LLM-2 Reviewer | Security + quality audit; severity-tagged issue list |
| LLM-3 Arbiter | Cross-validate; override if safety/quality critical; consensus matrix |

Timeouts: 30 s per LLM, 60 s per phase, 180 s total (6 turns max).
Consensus: UNANIMOUS → proceed; MAJORITY → proceed with notes;
SPLIT → one revision; UNRESOLVED → HUMAN_REVIEW.

Full spec: `claude/refs/deliberation.md`

---

## §13  Audit Trail

Every operation appends to `.skill-audit/framework.jsonl` (365-day retention):

```json
{
  "timestamp": "<ISO-8601>",
  "duration_ms": 0,
  "mode": "CREATE|LEAN|EVALUATE|OPTIMIZE",
  "skill_name": "<name>",
  "skill_version": "<semver>",
  "template_used": "<type|null>",
  "confidence": 0.00,
  "confidence_override": false,
  "lean_score": 0,
  "phase1": 0, "phase2": 0, "phase3": 0, "phase4": 0,
  "total_score": 0,
  "variance": 0.0,
  "tier": "PLATINUM|GOLD|SILVER|BRONZE|FAIL",
  "f1": 0.00,
  "mrr": 0.00,
  "trigger_accuracy": 0.00,
  "security_p0_clear": true,
  "security_p1_warnings": 0,
  "deliberation_consensus": "UNANIMOUS|MAJORITY|SPLIT|UNRESOLVED",
  "evolution_trigger": "<threshold|time|usage|null>",
  "error_recovery_invoked": false,
  "error_recovery_actions": [],
  "outcome": "CERTIFIED|TEMP_CERT|LEAN_CERT|HUMAN_REVIEW|ABORT",
  "optimize_cycles": 0
}
```

---

## §14  Usage Examples

### Create an API integration skill

```
Input: "创建一个调用OpenWeather API返回摄氏温度的skill"
Mode: CREATE | Template: api-integration | Language: ZH

→ Elicit (6 questions answered)
→ Generate from api-integration template
→ Security scan: CWE-798 CLEAR, CWE-89 CLEAR
→ LEAN eval: 460/500 → estimated 920 → GOLD proxy → escalate to full EVALUATE
→ Full eval: Phase1=95 Phase2=285 Phase3=385 Phase4=175 Total=940
→ Variance = |285/3 - 385/4| = |95 - 96.25| = 1.25 < 15 → GOLD ✓
→ CERTIFIED GOLD: weather-query v1.0.0
```

### LEAN fast check

```
Input: "lean eval my-skill.md"
Mode: LEAN | Duration: ~1s

→ YAML present ✓ (60), §modes ✓ (60), 严禁 ✓ (50), thresholds ✓ (60),
  examples ✓ (50), triggers ✓ (120), security section ✓ (50), no placeholders ✓ (50)
→ lean_score = 500 → estimated 1000 → PLATINUM proxy
→ LEAN PASS | LEAN_CERT | Schedule full EVALUATE within 24 h
```

### Evaluate and optimize a failing skill

```
Input: "evaluate skill, F1 is 0.82"
Mode: EVALUATE → auto-route to OPTIMIZE on FAIL

→ Phase1=88 Phase2=201 Phase3=285 Phase4=110 Total=684 → FAIL (< 700)
→ Variance = |201/3 - 285/4| = |67 - 71.25| = 4.25 → low, consistent failure
→ Lowest dimension: Workflow Definition (55/100)
→ OPTIMIZE cycle 1: Strategy S2 (fill missing sections) → +38pts
→ OPTIMIZE cycle 2: Strategy S1 (expand keywords) → +22pts
→ Re-evaluate: Total=744 → BRONZE ✓
→ CERTIFIED BRONZE: skill v1.1.0
```

---

**Triggers**:
**CREATE** | **LEAN** | **EVALUATE** | **OPTIMIZE**
**创建** | **快评** | **评测** | **优化**

(Templates: `claude/templates/` · Eval rubrics: `claude/eval/rubrics.md` ·
Pairwise: `claude/eval/pairwise.md` · Deliberation: `claude/refs/deliberation.md` ·
Security: `claude/refs/security-patterns.md` · Evolution: `claude/refs/evolution.md` ·
Convergence: `claude/refs/convergence.md` · Optimize strategies: `claude/optimize/strategies.md`)
