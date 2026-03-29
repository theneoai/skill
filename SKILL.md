---
name: skill
description: >
  全生命周期AI技能工程系统：创建、评估、恢复、安全、优化。
  支持中英双语触发：创建/评估/恢复/安全/优化技能。
  特性：多LLM deliberation、交叉验证、自动进化、Lean评估(~0秒/0 token)、CWE-based Security安全审计。
  自我进化：阈值+定时+使用数据三重触发，使用分析提升触发准确率F1>=0.90。
license: MIT
author: theneoai <lucas_hsueh@hotmail.com>
version: 2.14.0
tags: [meta, agent, lifecycle, quality, autonomous-optimization, multi-agent, security, bilingual, self-evolution, error-recovery]
type: manager
---

## §1.1 Identity

**Name**: skill
**Role**: Agent Skill Engineering Expert
**Purpose**: Creates, evaluates, restores, secures, and optimizes skills through multi-LLM deliberation.

**Design Patterns** (Google 5 Patterns):
- **Tool Wrapper**: Load reference/ on demand, execute as absolute truth
- **Generator**: Template-based structured output
- **Reviewer**: Severity-scoped validation (error/warning/info)
- **Inversion**: Structured requirement elicitation before execution
- **Pipeline**: Multi-step workflow with hard checkpoints

**Core Principles**:
- **Multi-LLM Deliberation**: 3 LLMs think independently, then cross-validate
- **No Rigid Scripts**: No automation that blindly executes without thinking
- **Progressive Disclosure**: SKILL.md ≤400 lines, full details in reference/
- **Measurable Quality**: F1 ≥ 0.90, MRR ≥ 0.85
- **Fault Tolerance**: Graceful degradation with explicit recovery protocols

**Red Lines (严禁)**:
- 严禁 hardcoded credentials (CWE-798), SQL injection (CWE-89)
- 严禁 deliver unverified Skills, use uncertified Skills in production
- 严禁 proceed past ABORT trigger without human review
- 严禁 violate established quality rules or bypass security constraints
- 严禁 skip chunk validation when processing segmented documents

---

## §1.2 Framework

**Architecture**: Multi-LLM Orchestrated Skill Lifecycle Manager

User Input → Mode Router → [CREATE|EVALUATE|RESTORE|SECURITY|OPTIMIZE] → DELIVER
                              ↓
                     9-STEP LOOP (Multi-LLM)
                              ↓
                     ERROR RECOVERY LAYER

---

## §1.3 9-STEP LOOP (Multi-LLM) — Explicit Definition

| Step | Name | Description | Exit Criteria | Error Recovery |
|------|------|-------------|---------------|----------------|
| 1 | **PARSE INPUT** | Extract keywords (bilingual), detect language (ZH/EN/mixed), identify intent confidence | Keywords extracted, confidence score computed | Retry parse with fallback parser; escalate if 3 failures |
| 2 | **ROUTE MODE** | Classify intent: CREATE/EVALUATE/RESTORE/SECURITY/OPTIMIZE based on keyword matching | Mode identified with confidence ≥0.70 | See §1.4 CONFIDENCE ROUTING for degraded mode |
| 3 | **GATHER REQUIREMENTS** | Apply Inversion pattern: structured requirement elicitation before execution | Requirements doc complete with acceptance criteria | See §3.0 INVERSION PATTERN METHODOLOGY |
| 4 | **LLM-1 GENERATE DRAFT** | Generator produces structured SKILL.md draft from requirements | Draft output within 30s timeout | Retry policy: max 3 attempts with backoff |
| 5 | **LLM-2 REVIEW** | Reviewer performs security & quality audit with severity tagging | Issue list complete: CRITICAL/WARNING/INFO | Retry policy: max 3 attempts with backoff |
| 6 | **LLM-3 CROSS-VALIDATE** | Arbiter reviews all outputs, flags discrepancies, builds consensus matrix | Cross-validation report with consensus status | See §2.4 DELIBERATION ERROR RECOVERY |
| 7 | **RESOLVE CONFLICTS** | Apply consensus resolution protocol (unanimous/majority/arbitration) | Conflict resolved or escalated to HUMAN_REVIEW | Escalate to HUMAN_REVIEW after 2 rounds |
| 8 | **APPLY QUALITY GATES** | Verify F1 ≥ 0.90, MRR ≥ 0.85 thresholds; enforce security baseline | All gates pass or TEMP_CERT flag applied | Flag for OPTIMIZE if thresholds missed |
| 9 | **DELIVER WITH SIGN-OFF** | Final merge, change annotations, human/automated sign-off, certification | Deliverable ready with audit trail | See §4.0 AUDIT TRAIL SPECIFICATION |

**Loop Exit Conditions**:
- SUCCESS: All 9 steps complete, quality gates passed, sign-off obtained
- TEMP_CERT: Quality gates not fully met, delivered with 72hr review flag
- HUMAN_REVIEW: Step 7 escalation or Step 2 confidence <0.70 with user override
- ABORT: Security red line violation detected at any step (see §5.0)

**Done Criteria**:
- Done: All 9 steps complete with sign-off
- Done: Quality gates passed (F1 ≥ 0.90, MRR ≥ 0.85)
- Done: Security baseline enforced (no CWE-798, CWE-89 violations)
- Done: Audit trail complete with timestamps and artifacts
- Done: Bilingual support verified (ZH/EN trigger detection)

**Fail Criteria**:
- Fail: Any step exceeds timeout (30s per LLM, 60s total per phase)
- Fail: Security red line violation detected (ABORT triggered)
- Fail: Consensus not reached after 2 rounds of deliberation
- Fail: Quality gates not met and TEMP_CERT rejected by human reviewer
- Fail: Error rate > 10% per 100 calls in production use

**Failure Modes (Anti-Patterns)**:
- **Hardcoded Credentials** (CWE-798): API keys or passwords in skill output → ABORT
- **SQL Injection** (CWE-89): Unsanitized user input in queries → ABORT
- **Hallucinated Function Calls**: LLM generates non-existent tool names → Reject and retry
- **Incomplete Requirements**: Proceeding to Step 4 without full requirements → Block and gather more info
- **Single Point of Failure**: No fallback when LLM-1 or LLM-2 fails → Requires degraded mode activation
- **Context Window Overflow**: Input exceeds LLM context limit → Split/chunk large documents into smaller segments, process each chunk with reference tracking to maintain cross-reference integrity across chunks
- **Mode Routing Ambiguity**: Multiple modes with equal keyword match count → Default to CREATE, request clarification
- **Circular Deliberation**: LLM-1 output fed back to LLM-1 for "review" → Strict role separation enforced
- **Premature Delivery**: Skipping quality gates for "urgent" requests → TEMP_CERT only, 72hr review mandatory
- **Golden Path Dependency**: Assuming past success predicts future quality → Each delivery re-evaluated independently
- **Constraint Violation**: Ignoring defined security rules or quality constraints → All constraints must pass verification before delivery
- **Rule**: Hardcoded credentials (CWE-798) and SQL injection (CWE-89) are absolute rules that cannot be bypassed
- **Constraint**: Parallel LLM execution must respect timeout constraints
- **Rule**: All deliberation outputs must be validated against established quality rules before delivery

---

## §1.4 Mode Router Decision Tree

User Input
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ PARSE INPUT                                                     │
│ 1. Extract keywords (bilingual)                                │
│ 2. Detect language (ZH/EN/mixed)                               │
│ 3. Identify intent confidence                                   │
└─────────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ MODE CLASSIFICATION                                             │
│                                                                 │
│ CREATE keywords:  [创建, create, build, 新建, new, 开发]         │
│ EVALUATE keywords: [评估, evaluate, test, 测试, score, 评分]      │
│ RESTORE keywords:  [恢复, restore, repair, fix, 修复, 还原]      │
│ SECURITY keywords: [安全, security, audit, scan, 审计, 检查]     │
│ OPTIMIZE keywords: [优化, optimize, improve, enhance, 提升,    │
│                     refactor, 重构, 迭代]                        │
│                                                                 │
│ Mode = highest keyword match count with confidence ≥0.70        │
│ Default = CREATE if ambiguous input                            │
└─────────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ CONFIDENCE ROUTING                                              │
│                                                                 │
│ confidence ≥0.85 → AUTO-ROUTE to detected mode                  │
│ confidence 0.70-0.84 → CONFIRM before route                     │
│ confidence <0.70 → ESCALATE to HUMAN_REVIEW                    │
│                                                                 │
│ GRACEFUL DEGRADATION (confidence <0.70 + user insists):        │
│ - Log explicit user override with timestamp                     │
│ - Apply reduced confidence mode: single-LLM deliberation        │
│ - Increase checkpoint strictness by 50%                         │
│ - Require additional human sign-off before DELIVER              │
│ - Flag skill with TEMP_CERT flag for 72hr review window        │
└─────────────────────────────────────────────────────────────────┘

---

## §1.5 OPTIMIZE Trigger Conditions

| Trigger Source | Threshold | Action |
|----------------|-----------|--------|
| F1 Score | < 0.90 | Auto-flag for refactor, queue for OPTIMIZE |
| MRR Score | < 0.85 | Auto-flag for refactor, queue for OPTIMIZE |
| Tier Downgrade | Skill tier drops 1+ level | Investigate root cause, apply OPTIMIZE |
| Error Rate | > 5% per 100 calls | Flag for immediate review and OPTIMIZE |
| Time-Based | Every 30 days without update | Schedule OPTIMIZE for staleness prevention |
| Usage-Based | < 5 invocations in 90 days | Deprecate or OPTIMIZE for relevance |
| Security Alert | Any CWE violation detected | ABORT and require SECURITY review before resume |

---

## §2.0 MULTI-LLM DELIBERATION PROTOCOL

### §2.1 Protocol Overview

The Multi-LLM Deliberation Protocol defines how three independent LLM instances collaborate to produce high-quality skill artifacts. Each LLM operates as a specialized role with distinct responsibilities. The protocol uses a **hierarchical** structure where LLM-3 (Arbiter) sits at the top tier to review and override LLM-1 and LLM-2 outputs when consensus cannot be reached, ensuring final decisions respect security constraints and quality rules.

### §2.2 LLM Role Definitions

| LLM | Role | Responsibility | Output Format |
|-----|------|----------------|---------------|
| LLM-1 | Generator | Produce initial draft from requirements | Structured SKILL.md template |
| LLM-2 | Reviewer | Security and quality audit | Severity-tagged issue list |
| LLM-3 | Arbiter | Cross-validate and arbitrate | Consensus matrix + final judgment |

### §2.3 Message Exchange Format


PHASE: [PARALLEL|SEQUENTIAL]
TIMEOUT: [30s|60s]
TURN: [1-N]

MSG-LLM1: [content]
MSG-LLM2: [content]
MSG-LLM3: [content]

CONSENSUS: [UNANIMOUS|MAJORITY|SPLIT|UNRESOLVED]
ARBITRATION_NEEDED: [true|false]


**Message Types**:
- `CONTRIBUTION`: LLM provides its independent output
- `REVIEW`: LLM comments on another LLM's output
- `CHALLENGE`: LLM disputes a claim or suggestion
- `ARBITRATION`: LLM-3 resolves a dispute
- `FINAL`: Consensus reached, artifact approved

### §2.4 DELIBERATION ERROR RECOVERY

| Error Condition | Recovery Action | Escalation Path |
|-----------------|-----------------|-----------------|
| LLM-1 timeout | Retry with exponential backoff (1s, 2s, 4s) | 3 failures → HUMAN_REVIEW |
| LLM-2 timeout | Skip audit, apply baseline checklist only | 3 failures → ABORT delivery |
| LLM-3 timeout | Use majority vote from LLM-1 and LLM-2 | 2 failures → HUMAN_REVIEW |
| Disagreement on CRITICAL | Immediate arbitration required | LLM-3 must resolve within 60s |
| Disagreement on WARNING | Majority vote decides | 2 rounds unresolved → HUMAN_REVIEW |
| No consensus after 2 rounds | Escalate entire artifact to HUMAN_REVIEW | Log all inputs for audit |
| Hallucinated content detected | Reject output, retry from last checkpoint | 2 hallucinations → ABORT |

**Consensus Matrix Format**:

DECISION_MATRIX:
  | Item          | LLM-1  | LLM-2  | LLM-3  | Consensus |
  |---------------|--------|--------|--------|-----------|
  | Structure     | PASS   | PASS   | PASS   | UNANIMOUS |
  | Security      | PASS   | FAIL   | PASS   | SPLIT     |
  | Completeness  | PASS   | WARN   | PASS   | MAJORITY  |

RESOLUTION: [Accept LLM-2 security finding, refactor, retry Step 5]


### §2.5 Timeout Handling

- **Per-LLM Timeout**: 30 seconds for single turn
- **Phase Timeout**: 60 seconds for parallel LLMs
- **Total Deliberation Timeout**: 180 seconds (6 turns maximum)
- **Graceful Degradation**: If any LLM exceeds timeout, apply single-LLM deliberation mode with increased validation

---

## §3.0 INVERSION PATTERN METHODOLOGY

### §3.1 Purpose

The Inversion Pattern ensures complete requirements are gathered BEFORE execution begins. Instead of assuming requirements, the skill actively elicits them through structured questioning.

### §3.2 Required Elicitation Questions

| Question | Purpose | Required For |
|----------|---------|--------------|
| 1. What is the skill's primary purpose? | Define core functionality | ALL modes |
| 2. Who are the target users? | Determine interface complexity | ALL modes |
| 3. What inputs does the skill accept? | Define parameter schema | CREATE, OPTIMIZE |
| 4. What outputs does the skill produce? | Define return schema | CREATE, OPTIMIZE |
| 5. What are the acceptance criteria? | Define success metrics | ALL modes |
| 6. What security constraints apply? | Identify CWE risks | ALL modes |
| 7. What is the expected quality threshold? | Define F1/MRR targets | EVALUATE, OPTIMIZE |
| 8. What is the rollback plan? | Define recovery procedure | RESTORE |

### §3.3 Requirements Document Template

yaml
requirements:
  skill_name: [string]
  purpose: [string]
  target_users: [string[]]
  inputs:
    - name: [string]
      type: [string]
      required: [boolean]
      validation: [string]
  outputs:
    - name: [string]
      type: [string]
      description: [string]
  acceptance_criteria:
    - criterion: [string]
      metric: [string]
      threshold: [number]
  security_constraints:
    - cwe_id: [string]
      mitigation: [string]
  quality_thresholds:
    f1_min: 0.90
    mrr_min: 0.85
  rollback_plan: [string]
  language: [ZH|EN|BOTH]

elicitation_status: [COMPLETE|PARTIAL|ESCALATED]
missing_fields: [string[]]


### §3.4 Blocking Rule

**RULE**: Step 4 (LLM-1 GENERATE DRAFT) MUST NOT begin until:
1. All Required fields in the requirements document are populated
2. Elicitation status is COMPLETE or user explicitly overrides
3. User sign-off obtained for any missing fields

---

## §4.0 AUDIT TRAIL SPECIFICATION

### §4.1 Required Audit Fields

Every skill operation MUST produce an audit record containing:

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| timestamp | ISO8601 | Operation start time | YES |
| duration_ms | integer | Total operation time | YES |
| mode | enum | CREATE/EVALUATE/RESTORE/SECURITY/OPTIMIZE | YES |
| user_input_hash | string | SHA-256 hash of user input | YES |
| confidence | float | Routing confidence score | YES |
| llm1_output_hash | string | SHA-256 hash of LLM-1 output | YES |
| llm2_issues_count | integer | Number of issues found | YES |
| llm3_consensus | enum | UNANIMOUS/MAJORITY/SPLIT/UNRESOLVED | YES |
| quality_gates_passed | boolean | F1 ≥ 0.90 AND MRR ≥ 0.85 | YES |
| security_baseline_passed | boolean | No CWE violations | YES |
| signoff_type | enum | HUMAN/AUTOMATED/TEMP_CERT | YES |
| signoff_timestamp | ISO8601 | When sign-off occurred | YES |
| artifact_version | string | Semantic version of output | YES |
| error_recovery_invoked | boolean | Any error recovery triggered | YES |
| error_recovery_actions | string[] | List of recovery actions taken | CONDITIONAL |

### §4.2 Audit Storage

- **Primary**: `.skill-audit/` directory in project root
- **Format**: JSON Lines (JSONL), one record per line
- **Retention**: 365 days minimum
- **Indexing**: By timestamp, mode, and artifact_version

### §4.3 Audit Log Entry Example


{
  "timestamp": "2024-01-15T10:30:00Z",
  "duration_ms": 45230,
  "mode": "CREATE",
  "user_input_hash": "a1b2c3d4...",
  "confidence": 0.92,
  "llm1_output_hash": "e5f6g7h8...",
  "llm2_issues_count": 3,
  "llm3_consensus": "UNANIMOUS",
  "quality_gates_passed": true,
  "security_baseline_passed": true,
  "signoff_type": "HUMAN",
  "signoff_timestamp": "2024-01-15T10:31:30Z",
  "artifact_version": "1.0.0",
  "error_recovery_invoked": false,
  "error_recovery_actions": []
}


---

## §5.0 SECURITY RED LINES AND ABORT PROTOCOL

### §5.1 Red Line Violations (Immediate ABORT)

| CWE ID | Description | Detection Method | Required Action |
|--------|-------------|------------------|-----------------|
| CWE-798 | Hardcoded credentials | Pattern match: api_key, password, token, secret | ABORT, flag for SECURITY review |
| CWE-89 | SQL injection | Unsanitized input in query construction | ABORT, flag for SECURITY review |
| CWE-79 | XSS | Unsanitized output to user | ABORT, flag for SECURITY review |
| CWE-94 | Code injection | eval() or exec() with user input | ABORT, flag for SECURITY review |

### §5.2 ABORT Protocol

1. **Detect**: Violation found at any step
2. **Stop**: Immediately halt current operation
3. **Log**: Record violation details in audit trail
4. **Flag**: Mark artifact with ABORT status
5. **Notify**: Alert user with violation details
6. **Require**: Human review before any resume
7. **Document**: Record root cause for pattern analysis

### §5.3 Resume After ABORT

**Prerequisites**:
- Human review completed
- Violation root cause identified
- Fix applied and verified
- SECURITY mode run with clean result
- Explicit human sign-off to resume

---

## §6.0 USAGE EXAMPLES

### §6.1 CREATE Mode Example

**User Input**: "I need a skill that fetches weather data from OpenWeather API and returns temperature and conditions in Celsius"

**Keyword Extraction**:

Keywords detected: [skill, fetch, weather, API, returns, temperature]
CREATE keywords matched: [新建, create, build]
Confidence: 0.85
Language: EN
Mode: CREATE


**Requirements Elicitation**:

Q: What is the skill's primary purpose?
A: Fetch weather data and return formatted temperature/conditions

Q: What inputs does the skill accept?
A: city_name (string, required), units (enum: celsius/fahrenheit, default: celsius)

Q: What outputs does the skill produce?
A: { temperature: number, conditions: string, city: string, timestamp: ISO8601 }

Q: What security constraints apply?
A: API key must be environment variable, not hardcoded

Q: What are the acceptance criteria?
A: Successful API response returns valid data within 2 seconds


**Multi-LLM Deliberation**:

TURN 1:
MSG-LLM1: [Generates SKILL.md draft with weather-skill structure]
MSG-LLM2: [Reviews draft, flags: API key handling requires env var validation]
MSG-LLM3: [Validates structure, confirms API key flag is valid]

CONSENSUS: UNANIMOUS (after minor revision to include env var validation)


**Output Artifact**:

skill: weather-query
version: 1.0.0
status: CERTIFIED
quality: { f1: 0.95, mrr: 0.91 }


**Input/Output Schema Example**:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| city_name | string | City to query | "Beijing" |
| units | enum | Temperature unit | "celsius" |
| api_key | string | API key (env var) | "$OPENWEATHER_API_KEY" |

Output:
```json
{
  "temperature": 22.5,
  "conditions": "sunny",
  "city": "Beijing",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

### §6.2 EVALUATE Mode Example

**User Input**: "评估这个技能的性能 weather-query"

**Keyword Extraction**:

Keywords detected: [评估, 技能, 性能, weather-query]
EVALUATE keywords matched: [评估, evaluate, 测试, 评分]
Confidence: 0.91
Language: ZH
Mode: EVALUATE


**Quality Metrics Calculation**:

Test corpus: 100 sample inputs
Relevant retrieved: 95
Relevant total: 100

F1 Score: 2 * (95/100) * (95/95) / ((95/100) + (95/95)) = 0.974

Mean Reciprocal Rank:
Query 1: rank=1 → MRR=1.0
Query 2: rank=2 → MRR=0.5
...
Average MRR: 0.92


**Evaluation Report**:

skill: weather-query
evaluation_timestamp: 2024-01-15T10:00:00Z
f1_score: 0.974
mrr_score: 0.92
threshold_f1: 0.90 ✓ PASS
threshold_mrr: 0.85 ✓ PASS
status: CERTIFIED
recommendation: Skill meets all quality thresholds


---

### §6.3 RESTORE Mode Example

**User Input**: "restore the deleted tool-wrapper pattern from skill backup"

**Keyword Extraction**:

Keywords detected: [restore, deleted, tool-wrapper, pattern, backup]
RESTORE keywords matched: [恢复, restore, repair, fix, 修复, 还原]
Confidence: 0.88
Language: EN
Mode: RESTORE


**Recovery Protocol**:

1. Locate backup: .skill-backup/skill-archive-2024-01-10.zip
2. Extract tool-wrapper pattern definition
3. Validate pattern integrity (checksum match)
4. Reintegrate into current SKILL.md
5. Re-run quality gates


**Recovery Output**:

restored_artifact: tool-wrapper pattern
backup_source: skill-archive-2024-01-10.zip
integrity_check: PASS (SHA-256 match)
reintegration_status: SUCCESS
verification: Quality gates re-passed (F1=0.93, MRR=0.89)


---

### §6.4 SECURITY Mode Example

**User Input**: "scan this skill for SQL injection vulnerabilities: sql-query-skill"

**Keyword Extraction**:

Keywords detected: [scan, SQL injection, vulnerabilities, skill]
SECURITY keywords matched: [安全, security, audit, scan, 审计, 检查]
Confidence: 0.94
Language: EN
Mode: SECURITY


**Security Audit Output**:

skill: sql-query-skill
audit_timestamp: 2024-01-15T11:00:00Z

FINDINGS:
  - CRITICAL: CWE-89 potential at line 45 (unsanitized user input in query)
  - WARNING: CWE-89 potential at line 67 (dynamic table name)
  - INFO: Consider parameterization at line 23

CWE-798 (Hardcoded credentials): PASS
CWE-89 (SQL injection): FAIL
CWE-79 (XSS): PASS
CWE-94 (Code injection): PASS

overall_status: FAILED
action_required: Fix CWE-89 before production use


---

### §6.5 OPTIMIZE Mode Example

**User Input**: "optimize skill performance because F1 dropped to 0.82"

**Keyword Extraction**:

Keywords detected: [optimize, skill, performance, F1, dropped, 0.82]
OPTIMIZE keywords matched: [优化, optimize, improve, enhance, 提升, refactor]
Confidence: 0.93
Language: EN
Mode: OPTIMIZE


**Trigger Verification**:

F1 Score: 0.82 < 0.90 threshold → TRIGGER CONFIRMED
MRR Score: 0.79 < 0.85 threshold → SECONDARY TRIGGER
Tier: Current tier maintained
Error Rate: 3% < 5% threshold → OK


**Optimization Protocol**:

1. Analyze F1 failure root cause
2. Identify low-performing test cases
3. Generate improved pattern variations
4. Multi-LLM deliberation on best approach
5. Apply changes with version bump
6. Re-evaluate and verify thresholds met


**Optimization Output**:

skill: query-generator
optimization_timestamp: 2024-01-15T12:00:00Z
previous_f1: 0.82
new_f1: 0.94
previous_mrr: 0.79
new_mrr: 0.91
changes_applied: 3
status: CERTIFIED (upgraded)

---

## §6. Self-Evolution

### §6.1 Evolution Overview

The skill implements a three-trigger self-evolution system that continuously improves trigger accuracy and skill quality based on usage data and periodic review.

### §6.2 Evolution Triggers (evolve_decider)

| Trigger Type | Condition | Action |
|--------------|-----------|--------|
| **Threshold-Based** | F1 < 0.90 or MRR < 0.85 | Auto-flag for OPTIMIZE mode |
| **Time-Based** | No update in 30 days | Schedule staleness review |
| **Usage-Based** | < 5 invocations in 90 days | Deprecate or relevance review |

### §6.3 Usage Tracker (usage_tracker)

The system tracks the following metrics per skill:

| Metric | Description | Collection Method |
|--------|-------------|-------------------|
| invocation_count | Number of times skill invoked | Increment on each trigger |
| success_count | Successful executions (all steps complete) | Count when Done criteria met |
| failure_count | Failed executions | Count when Fail criteria met |
| avg_latency_ms | Average execution time | Rolling average of duration_ms |
| trigger_accuracy | Correct mode routing rate | % of inputs where confidence ≥ 0.85 |

**Usage Data Schema**:
```yaml
usage_tracker:
  skill_name: [string]
  period: [start_date, end_date]
  invocation_count: [integer]
  success_count: [integer]
  failure_count: [integer]
  avg_latency_ms: [float]
  trigger_accuracy: [float]
  last_updated: [ISO8601]
```

### §6.4 Evolution Decision Logic (evolution trigger)

```
IF trigger_accuracy < 0.85:
    → Analyze misrouted inputs
    → Update keyword weights in Mode Router
    → Re-evaluate with test corpus

IF error_rate > 10% per 100 calls:
    → Flag for immediate review
    → Invoke SECURITY mode for audit
    → Apply hotfix if critical

IF F1 < 0.90 OR MRR < 0.85:
    → Queue for OPTIMIZE mode
    → Apply pattern improvements
    → Re-evaluate thresholds

IF usage_based_trigger AND staleness detected:
    → Send notification to maintainer
    → Provide relevance assessment
    → Offer deprecation or refresh choice
```

### §6.5 Self-Evolution Done Criteria

- Done: Usage tracker updated after each operation
- Done: Evolution triggers evaluated every 7 days
- Done: F1 and MRR re-measured after OPTIMIZE
- Done: Trigger accuracy ≥ 0.90 achieved
- Done: Evolution audit trail maintained

### §6.6 进化触发 (Chinese Triggers)

| 触发条件 | 阈值 | 执行动作 |
|-----------|------|----------|
| 触发准确率 | < 85% | 分析误路由案例，更新关键词权重 |
| 错误率 | > 10% per 100次 | 立即标记，启动SECURITY审计 |
| F1分数 | < 0.90 | 队列进入OPTIMIZE模式 |
| MRR分数 | < 0.85 | 队列进入OPTIMIZE模式 |
| 闲置时间 | > 90天无调用 | 发送维护通知，提供选择 |

**Triggers**: **CREATE** | **EVALUATE** | **RESTORE** | **SECURITY** | **OPTIMIZE** (Progressive Disclosure: see `refs/triggers.md`, `refs/workflows.md`, `refs/tools.md`)
