# 代码逻辑与文档一致性审查报告

**生成日期:** 2026-03-31
**审查方法:** 逐条对照 `skill-framework.md`（主文档）与各实现文件
**文件范围:** `skill-framework.md` / `core/create/workflow.yaml` / `core/create/elicitation.yaml` / `core/evaluate/rubrics.yaml` / `core/evaluate/certification.yaml` / `core/optimize/dimensions.yaml` / `core/optimize/convergence.yaml` / `refs/convergence.md` / `refs/security-patterns.md`

---

## 总览

| 严重级别 | 数量 | 类别 |
|----------|------|------|
| 🔴 严重 (Critical) | 4 | 数值不一致，会导致认证结果错误 |
| 🟠 高 (High) | 3 | 功能缺失，流程不完整 |
| 🟡 中 (Medium) | 2 | 实现与设计不符 |
| 🟢 正确 (OK) | 4 | 与文档一致 |

---

## 🔴 严重问题

### [C1] 认证等级最低分阈值冲突

`skill-framework.md §8` 与 `core/evaluate/rubrics.yaml` 对 BRONZE/SILVER/GOLD 的最低分定义完全不同：

| 等级 | skill-framework.md（主文档） | rubrics.yaml（实现） | certification.yaml（实现） | 结论 |
|------|------|------|------|------|
| PLATINUM | ≥ 950 | ≥ 950 ✓ | ≥ 950 ✓ | 一致 |
| GOLD | **≥ 900** | **≥ 850** ❌ | ≥ 900 ✓ | rubrics.yaml 偏低 50分 |
| SILVER | **≥ 800** | **≥ 750** ❌ | ≥ 800 ✓ | rubrics.yaml 偏低 50分 |
| BRONZE | **≥ 700** | **≥ 600** ❌ | ≥ 700 ✓ | rubrics.yaml 偏低 100分 |
| FAIL | < 700 | < 600 ❌ | < 700 ✓ | rubrics.yaml 偏宽 |

**影响**：`core/evaluate/rubrics.yaml` 是 EVALUATE 模式的核心评分文件，其阈值偏低会导致本应为 FAIL 的技能被错误认证为 BRONZE，本应 BRONZE 的被认证为 SILVER/GOLD。

**位置**：
- `core/evaluate/rubrics.yaml:336-384` (certification_tiers)
- `skill-framework.md §8` (Certification Tiers 表)

---

### [C2] certification.yaml 阶段最低分值超出上限（不可能达到）

`core/evaluate/certification.yaml` 中定义的 `phase2_min` 和 `phase3_min` 值超出了对应阶段的满分：

| 等级 | phase2_min（实现值） | Phase 2 满分 | phase3_min（实现值） | Phase 3 满分 |
|------|------|------|------|------|
| PLATINUM | **475** ❌ | 300 | **475** ❌ | 400 |
| GOLD | **450** ❌ | 300 | **450** ❌ | 400 |
| SILVER | **400** ❌ | 300 | **400** ❌ | 400 |
| BRONZE | 350 ❌ | 300 | **350** ❌ | 400 |

所有 phase2_min 都超过了 Phase 2 的满分（300分），所有 phase3_min（除 BRONZE 外）都超过 Phase 3 满分（400分）。该文件的值来源于一套以每阶段500分为满分的不同评分体系，与实际 1000分系统不兼容。

**对比：** `skill-framework.md §8` 正确定义了 PLATINUM: Phase2 ≥ 270, Phase3 ≥ 360（均在满分范围内）。

**位置**：`core/evaluate/certification.yaml:7-68`

---

### [C3] 方差公式不一致

`skill-framework.md` 与 `rubrics.yaml`/`certification.yaml` 使用了两套完全不同的方差计算公式：

**skill-framework.md §8（主文档）**：
```
variance = | (phase2_score / 3) - (phase3_score / 4) |
```
仅比较 Phase2 和 Phase3 的归一化分数之差（绝对值）。

**core/evaluate/rubrics.yaml 和 core/evaluate/certification.yaml（实现）**：
```
variance = sqrt(sum((phase_score - mean_score)²) / n)
```
使用全部4个阶段的标准差。

两个公式的量纲和含义完全不同，用同一套阈值（如 PLATINUM < 10）评判会得到完全不同的结论。

---

### [C4] 方差阈值尺度冲突

`rubrics.yaml` 的方差最大值与 `skill-framework.md`/`certification.yaml` 不在同一数量级：

| 等级 | skill-framework.md | certification.yaml | rubrics.yaml | 状态 |
|------|------|------|------|------|
| PLATINUM | < 10 | ≤ 10 ✓ | **≤ 50** ❌ | rubrics.yaml 宽松5倍 |
| GOLD | < 15 | ≤ 15 ✓ | **≤ 75** ❌ | rubrics.yaml 宽松5倍 |
| SILVER | < 20 | ≤ 20 ✓ | **≤ 100** ❌ | rubrics.yaml 宽松5倍 |
| BRONZE | < 30 | ≤ 30 ✓ | **≤ 150** ❌ | rubrics.yaml 宽松5倍 |

方差阈值恰好相差5倍，与 [C3] 的公式不统一直接相关。rubrics.yaml 的方差阈值是基于标准差公式设计的，但即使与标准差公式配合，这套阈值也与文档标准不兼容。

---

## 🟠 高优先级问题

### [H1] CREATE 工作流缺少 3 个关键步骤

`skill-framework.md §5` 定义了 9 个阶段，而 `core/create/workflow.yaml` 只实现了 7 个步骤，且顺序不同：

| # | skill-framework.md（主文档） | workflow.yaml（实现） | 状态 |
|---|------|------|------|
| 1 | **ELICIT** | parse | ❌ 顺序不同 |
| 2 | **SELECT TEMPLATE** | select_template | 🟡 顺序不同 |
| 3 | **PLAN**（多LLM协商） | elicit | ❌ PLAN 缺失 |
| 4 | **GENERATE** | generate | ✓ |
| 5 | **SECURITY SCAN** | security_scan | ✓ |
| 6 | **LEAN EVAL** | lean_eval | 🟡 实现不同 |
| 7 | **FULL EVALUATE** | deliver | ❌ FULL EVALUATE 缺失 |
| 8 | **INJECT UTE** | — | ❌ 完全缺失 |
| 9 | **DELIVER** | — | ❌ 覆盖位置错误 |

缺失步骤：
1. **PLAN**（LoongFlow 多LLM协商）— workflow.yaml 无对应步骤
2. **FULL EVALUATE**（第7步，LEAN 不确定时触发完整评测）— 完全未实现
3. **INJECT UTE**（第8步，注入 Use-to-Evolve 片段）— 完全未实现

另外，`skill-framework.md` 明确规定 ELICIT（引导）必须在 SELECT TEMPLATE（选模板）**之前**，但 `workflow.yaml` 的顺序是先选模板再引导，违反了 Inversion Pattern 的设计原则。

**位置**：`core/create/workflow.yaml:1-207`，`skill-framework.md §5`

---

### [H2] 引导问题（Elicitation）三套定义互相冲突

项目中存在三套引导问题，互相不一致：

**skill-framework.md §7**（主文档，双语，技能专用）：
1. 这个skill要解决什么核心问题？ / What core problem does this skill solve?
2. 主要用户是谁，技术水平如何？ / Who are the target users?
3. 输入是什么形式？ / What form does the input take?
4. 期望的输出是什么？ / What is the expected output?
5. 有哪些安全或技术约束？/ What security or technical constraints apply?
6. 验收标准是什么？/ What are the acceptance criteria?

**core/create/elicitation.yaml**（独立文件，内容与主文档基本一致）✓

**core/create/workflow.yaml elicit 步骤**（通用代码生成问题，完全不同）❌：
1. What is the primary purpose or goal of what you're creating?
2. Who are the target users or consumers of this creation?
3. **What are the key features or capabilities it must have?** ← 与文档不同
4. Are there any specific constraints, standards, or requirements? ← 范围更宽
5. **What is the expected scale or scope?** ← 与文档不同
6. **Are there any examples or references?** ← 与文档不同

workflow.yaml 的问题3/5/6 与主文档和 elicitation.yaml 均不符，使用的是通用代码生成框架的问题，而非技能定义专用问题，会导致收集的需求信息不完整。

---

### [H3] LEAN 评估实现完全不同

`core/create/workflow.yaml` 的 `lean_eval` 步骤与 `skill-framework.md §6` 定义的 LEAN 模式是两套不同的系统：

**skill-framework.md §6**（500分制，检查技能文档完整性）：
- YAML frontmatter 完整性：60分
- ≥3 个 `## §N` 模式段落：60分
- "Red Lines/严禁" 文本：50分
- 带数值阈值的 Quality Gates 表：60分
- ≥2 个代码块用例：50分
- 触发关键词（双语）：最多120分
- Security Baseline 段落：50分
- 无 `{{PLACEHOLDER}}` 残留：50分
- **决策逻辑**：≥350分通过，300-349分升级为完整评测，<300分路由到 OPTIMIZE

**core/create/workflow.yaml lean_eval 步骤**（0-10分制，软件质量评估）：
- Legible（可读性）：最低7分
- Efficient（高效性）：最低7分
- Accurate（准确性）：最低8分
- Non-fragile（健壮性）：最低7分
- overall_threshold: 7.5

两套系统使用不同的评分维度、不同的尺度（500分 vs 10分）、不同的通过标准，无法互相替代。

---

## 🟡 中等问题

### [M1] 收敛检测规则存在差异

`skill-framework.md §9` 与 `core/optimize/convergence.yaml` 的收敛条件不一致：

| 参数 | skill-framework.md | refs/convergence.md | convergence.yaml |
|------|------|------|------|
| 最大轮次 | **20** | 20 ✓ | **1000** ❌ |
| 无改善停止窗口 | "3次无增益" | plateau: window=10 | **50次** ❌ |
| 停止阈值描述 | "< 5分改善" | delta < 0.5 | delta_threshold=0.5 ✓ |
| plateau窗口大小 | — | **10** | **20** 不同 |

`convergence.yaml` 的 `max_iterations=1000` 和 `no_improvement window=50` 远比文档规定（max 20轮，窗口10）宽松。`convergence.yaml` 疑似为数值优化算法设计，而非技能优化场景。

`refs/convergence.md` 与 `skill-framework.md` 高度一致，是正确的参考实现。

---

### [M2] LEAN 通过标准说明与使用文档不符

`USAGE.md §EVALUATE` 中的评分分解结构（Completeness 240, Clarity 235, Security 190, Usability 182, Maintainability 100）与 `rubrics.yaml` 定义的 Phase 2 实际维度（clarity 50, completeness 50, accuracy 60, safety 60, maintainability 40, usability 40）不对应：

- USAGE.md 用了 5 个维度，每维度配了不同的分值区间（250, 200等），与实际满分（50, 60等）不匹配
- USAGE.md 中提到的 "GOLD (850+)" 认证等级，与 `skill-framework.md` 中 GOLD 定义为 ≥ 900 冲突

---

## 🟢 正确实现（文档一致）

### [OK1] 安全模式（CWE Patterns）

`skill-framework.md §11` 与 `refs/security-patterns.md` 完全一致：
- P0: CWE-798 (ABORT), CWE-89 (ABORT), CWE-78 (ABORT) ✓
- P1: CWE-22 (-50分), CWE-306 (-30分), CWE-862 (-30分) ✓
- ABORT 协议5步流程一致 ✓

### [OK2] OPTIMIZE 7维度与权重

`skill-framework.md §9` 与 `core/optimize/dimensions.yaml` 完全一致：
- System Design 20%, Domain Knowledge 20%, Workflow Definition 20% ✓
- Error Handling 15%, Examples 15% ✓
- Metadata 10%, Long-Context 10% ✓

### [OK3] refs/convergence.md 收敛算法

`refs/convergence.md` 的三信号算法与 `skill-framework.md §9` 的描述一致：
- 最大轮次 20 ✓
- 收敛信号：volatility / plateau / trend ✓
- DIVERGING → HALT → HUMAN_REVIEW ✓

### [OK4] 评估阶段分值分配

`skill-framework.md §8` 与 `core/evaluate/rubrics.yaml` 阶段分值一致：
- Phase 1: 100分, Phase 2: 300分, Phase 3: 400分, Phase 4: 200分 = 1000分 ✓

---

## 问题汇总与修复建议

| 编号 | 问题 | 受影响文件 | 建议修复 |
|------|------|-----------|---------|
| C1 | rubrics.yaml 认证分数偏低 | `core/evaluate/rubrics.yaml` | 将 BRONZE≥600→700, SILVER≥750→800, GOLD≥850→900 |
| C2 | certification.yaml 阶段分值超限 | `core/evaluate/certification.yaml` | 将 phase2/3_min 改为与 skill-framework.md §8 一致的值 |
| C3 | 方差公式不统一 | `core/evaluate/rubrics.yaml` | 统一为 `skill-framework.md` 定义的简化公式，或在文档中明确采用标准差 |
| C4 | 方差阈值尺度不兼容 | `core/evaluate/rubrics.yaml` | 与 C3 一起修正，统一阈值为 10/15/20/30 |
| H1 | workflow.yaml 缺少 PLAN/FULL EVALUATE/INJECT UTE | `core/create/workflow.yaml` | 补充3个缺失步骤；调整 ELICIT 到 SELECT TEMPLATE 之前 |
| H2 | 引导问题三套不一致 | `core/create/workflow.yaml` | 替换 workflow.yaml 中的 elicit 问题，改用 elicitation.yaml 定义的 6 个问题 |
| H3 | LEAN 实现完全不同 | `core/create/workflow.yaml` | 用 skill-framework.md §6 的500分体系替换 workflow.yaml 的 lean_eval 步骤 |
| M1 | convergence.yaml 轮次上限过宽 | `core/optimize/convergence.yaml` | 将 max_iterations=1000 改为 20，no_improvement window 改为 10 |
| M2 | USAGE.md 评分示例不准确 | `USAGE.md` | 修正评分维度名称和分值，统一 GOLD 定义为 ≥900 |

---

## 根本原因分析

通过审查，可以识别出以下两个根本原因：

1. **文件来源不统一**：`core/evaluate/rubrics.yaml`、`core/evaluate/certification.yaml` 和 `core/create/workflow.yaml` 疑似来自通用模板库，创建时未针对本项目的 1000分评估体系进行适配，导致分数阈值、公式、评估维度与主文档 `skill-framework.md` 不一致。

2. **主文档版本迭代未同步**：`skill-framework.md` 已升级至 v2.0.0，新增了 LEAN 模式、INJECT UTE、LoongFlow 编排等功能，但 `core/create/workflow.yaml` 仍反映较早的设计（v1.0.0），未同步最新的9步工作流。

---

*本报告由 Claude Code 自动生成于 2026-03-31，基于对文档与代码的逐条对比分析。*
