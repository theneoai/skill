# Skill Writer 端到端测试报告

> **⚠️ 历史档案** — 本报告记录了 v1.0.0 基线（2026-03-31）的问题。
> 所有 P1–P12 问题已在 v2.0.0（2026-04-01）中修复。
> 当前评估结果请参考各技能的 `examples/*/eval-report.md`。

**测试日期:** 2026-03-31
**测试依据:** USAGE.md / skill-framework.md v2.0.0
**测试环境:** Node.js 16+ / Linux

---

## 总览

| 测试区域 | 结果 | 严重问题数 |
|----------|------|-----------|
| T1 安装与触发验证 | ⚠️ 部分通过 | 2 |
| T2 CREATE 模式正确性 | ✅ 通过 | 0 |
| T3 EVALUATE 模式正确性 | ⚠️ 部分通过 | 3 |
| T4 OPTIMIZE 模式正确性 | ✅ 通过 | 0 |
| T5 UTE 继承能力 | ❌ 未通过 | 2 |
| T6 构建系统质量 | ⚠️ 部分通过 | 3 |

---

## T1：安装与触发验证

### 构建流水线

```
npm run validate  → ✅ 0 errors, 4 warnings (template placeholders — 预期)
npm run build     → ✅ 6 platforms × success, 131ms
```

### LEAN 评分 — 已安装技能（platforms/skill-writer-claude-dev.md）

| 检查项 | 分值 | 结果 | 说明 |
|--------|------|------|------|
| YAML frontmatter (name/version/interface) | 60 | ✅ | 正常 |
| ≥3 个 `## §N` 模式段落 | 60 | ❌ | **0 个 §N 段落** |
| "Red Lines" / "严禁" 文本 | 50 | ✅ | 存在 |
| Quality Gates 数值阈值表 | 60 | ✅ | 存在 |
| ≥2 个代码块示例 | 50 | ✅ | 1755个（远超） |
| 触发关键词 EN+ZH 四模式 | 120 | ✅ | 全部120分 |
| Security Baseline 段落 | 50 | ✅ | 存在 |
| 无 `{{PLACEHOLDER}}` 残留 | 50 | ❌ | **208 个未填充占位符** |
| **LEAN 总分** | **500** | **390/500** | BRONZE proxy（≥350）|

**LEAN 决策：BRONZE PASS → LEAN_CERT（但有两项失败需关注）**

### 触发关键词覆盖

| 模式 | EN 关键词 | ZH 关键词 | 状态 |
|------|----------|----------|------|
| CREATE | create, build, make, generate ✅ | 创建, 生成 ✅ | ✅ |
| LEAN | lean, quick-eval ✅ | 快评 ✅ | ✅ |
| EVALUATE | evaluate, assess, score ✅ | 评测, 评估 ✅ | ✅ |
| OPTIMIZE | optimize, improve, enhance ✅ | 优化, 改进 ✅ | ✅ |

### 重要发现

**[B1] ❌ 严重：构建输出不包含 skill-framework.md §1-§15 核心规范**

`builder/src/core/reader.js` 仅读取 `core/` 目录下的 YAML 文件，**未读取 `skill-framework.md`**。
安装到 `~/.claude/skills/skill-writer.md` 的文件是通用模板包装器，缺少：
- §1 Identity（角色定义）
- §2 Mode Router（模式路由与置信度公式）
- §3 Graceful Degradation（优雅降级）
- §4 LoongFlow Orchestration（Plan-Execute-Summarize）
- §5-§15 所有操作规范

**影响**：安装后的技能**无法按照文档描述运行**，因为行为规范未被部署。

**[B2] ❌ 高：208 个未填充占位符**

来源：skill 创建模板（workflow-automation.md 44个、data-pipeline.md 42个、base.md 41个、api-integration.md 33个）被原文嵌入构建输出，其中的 `{{PLACEHOLDER}}` 作为技能文档内容保留，但触发 LEAN 检查失败。

**[B3] ⚠️ 中：5 个占位符未在数据中定义**

构建时报 warning：`p0_count`, `p1_count`, `p2_count`, `p3_count`, `generated_at` 在 `skillMetadata` 中缺失，导致 `templates/claude.md:265-268,404` 的对应内容未填充。

**[B4] ❌ 高：inspect 命令路径不匹配**

`inspect` 命令在 `platforms/<platform>/skill-writer.md` 查找构建输出，但 `build` 实际输出到 `platforms/skill-writer-<platform>-dev.md`（平面结构）。
导致 `node bin/skill-writer-builder.js inspect --platform claude` 永远失败。

---

## T2：CREATE 模式正确性

**结论：✅ 完全通过**

| 验证项 | 结果 |
|--------|------|
| 9步骤顺序（ELICIT→SELECT→PLAN→GENERATE→SCAN→LEAN→EVALUATE→UTE→DELIVER）| ✅ |
| ELICIT 在 SELECT TEMPLATE 之前（Inversion 门控）| ✅ |
| PLAN 步骤（LoongFlow 多LLM协商）已实现 | ✅ |
| FULL EVALUATE 步骤（条件 lean_decision==UNCERTAIN）已实现 | ✅ |
| INJECT UTE 步骤已实现 | ✅ |
| 6个引导问题双语（ZH+EN）完全匹配 skill-framework.md §7 | ✅ |
| LEAN 500分制（8项检查）正确实现 | ✅ |
| LEAN 决策阈值（≥350=PASS, 300-349=UNCERTAIN, <300=FAIL）| ✅ |
| CWE P0/P1 安全扫描门控正确 | ✅ |
| INJECT UTE 5个占位符定义正确 | ✅ |
| 所有硬门控（hard gates）已定义 | ✅ |

---

## T3：EVALUATE 模式正确性

**结论：⚠️ 框架正确，示例技能评测结果与文档存在差异**

### 框架配置验证

| 检查项 | 结果 |
|--------|------|
| Phase 1=100 + Phase 2=300 + Phase 3=400 + Phase 4=200 = 1000 | ✅ |
| Phase 2 子维度总和：50+50+60+60+40+40=300 | ✅ |
| 认证等级：PLATINUM≥950 / GOLD≥900 / SILVER≥800 / BRONZE≥700 | ✅ |
| 方差公式：`\|(phase2/3) - (phase3/4)\|` | ✅ |
| 方差阈值：PLATINUM<10 / GOLD<15 / SILVER<20 / BRONZE<30 | ✅ |
| 阶段最低分：PLATINUM(270/360) / GOLD(255/340) / SILVER(225/300) / BRONZE(195/265) | ✅ |

### 示例技能 LEAN 评分 vs 认证声明

| 技能 | 声明得分/等级 | LEAN实测 | 实测决策 | 差异 |
|------|-------------|---------|---------|------|
| code-reviewer | 960 / PLATINUM | 340/500 | **UNCERTAIN→升级评测** | ❌ 严重 |
| doc-generator | 935 / GOLD | 340/500 | **UNCERTAIN→升级评测** | ❌ 严重 |
| api-tester | 920 / GOLD | 390/500 | BRONZE/LEAN PASS | ⚠️ 低于GOLD proxy |

**[E1] ❌ code-reviewer：LEAN=340，应为 UNCERTAIN，但声称 PLATINUM 960**

失分原因：
- 无 `## §N` 格式段落（-60分）：该技能用 `## REVIEW Mode` 而非 `## §1`
- 无 Red Lines / 严禁 文本（-50分）：未包含明确的 Red Lines 段落

**[E2] ❌ doc-generator：eval-report 使用旧版等级阈值**

`eval-report.md` 显示 `SILVER: 700-849 / GOLD: 850-999`，与修正后规范（SILVER≥800, GOLD≥900）不符。该报告基于修正前的旧阈值生成。

**[E3] ⚠️ doc-generator：LEAN 触发词不完整**

仅覆盖 60/120 分触发词：缺少 LEAN 模式（快评/lean）和 OPTIMIZE 模式触发词，文档只提供了2个模式的触发词。

**[E4] ⚠️ api-tester：1 个占位符未填充**

`base_url: "{{API_BASE_URL}}"` 残留于 skill.md（来源：api-integration 模板未正确填写）。

---

## T4：OPTIMIZE 模式正确性

**结论：✅ 完全通过**

| 验证项 | 结果 |
|--------|------|
| 7个维度权重合计：20+20+20+15+15+10+10=100% | ✅ |
| System Design 20% / Domain Knowledge 20% / Workflow Definition 20% | ✅ |
| Error Handling 15% / Examples 15% / Metadata 10% / Long-Context 10% | ✅ |
| max_iterations = 20（已修正） | ✅ |
| plateau window_size = 10（已修正） | ✅ |
| delta_threshold = 0.5 | ✅ |
| refs/convergence.md 三信号算法（volatility/plateau/trend）| ✅ |
| convergence.yaml 与 refs/convergence.md 阈值一致 | ✅ |
| HUMAN_REVIEW：round 10 后 total_score < 560 触发 | ✅ |
| max 20轮后 score≥700 → BRONZE，否则 HUMAN_REVIEW | ✅ |

---

## T5：UTE（使用即进化）继承能力

**结论：❌ 未通过**

### 示例技能 UTE 状态

| 技能 | §UTE 段落 | use_to_evolve: YAML | 5个占位符填充 | 状态 |
|------|----------|---------------------|-------------|------|
| code-reviewer | ❌ | ❌ | — | **完全缺失** |
| doc-generator | ❌ | ❌ | — | **完全缺失** |
| api-tester | ⚠️ | ✅ 部分 | 仅2/5 | **不完整** |

**[U1] ❌ 严重：code-reviewer 和 doc-generator 完全缺少 UTE**

这两个技能没有：
- `§UTE` 段落（技能自我进化行为定义）
- `use_to_evolve:` YAML 前置元数据块

按 skill-framework.md §5 Phase 8 和 §15 规定，所有由框架创建/优化的技能都应在交付前注入 UTE。

**[U2] ⚠️ api-tester：UTE 不完整**

仅有2个字段：
```yaml
use_to_evolve:
  certified_lean_score: 470
  last_ute_check: "2026-03-31"
```

缺少 UTE 规范要求的：
- `framework_version:` (应为 "2.0.0")
- `injection_date:`（重复了 last_ute_check）
- `§UTE` 正文段落（per-call 记录、隐式反馈检测、微补丁机制等）

**[U3] ⚠️ api-tester：certified_lean_score=470 超出实测值**

实测 LEAN=390/500，但 `certified_lean_score: 470`。表明该值是手动填写而非实际评测结果。

---

## T6：构建系统质量（补充）

### 构建警告分析

```
警告1-4: Template contains unmodified example placeholder
  → templates/workflow-automation.md, data-pipeline.md, base.md, api-integration.md
  → 这是预期行为（技能创建模板保留占位符供用户填写）
  → 但会导致 LEAN "无占位符" 检查失败

警告5-9: Placeholder p0_count/p1_count/p2_count/p3_count/generated_at not found in data
  → builder/src/commands/build.js skillMetadata 缺少这5个字段
  → 导致 templates/claude.md:265-268,404 输出内容不完整
```

### inspect 命令路径 Bug

```
期望路径: platforms/<platform>/skill-writer.md (子目录结构)
实际输出: platforms/skill-writer-<platform>-dev.md (平面文件)
结果: inspect 命令对所有平台均失败
```

---

## 完整问题清单

| 编号 | 严重级别 | 区域 | 描述 | 影响 |
|------|---------|------|------|------|
| **P1** | 🔴 严重 | 构建/安装 | **skill-framework.md §1-§15 未嵌入构建输出**；安装的技能缺少所有行为规范（Mode Router、LoongFlow、引导问题等） | 安装后技能无法按文档运行 |
| **P2** | 🔴 严重 | 示例技能 | **code-reviewer 和 doc-generator 完全缺少 UTE 段落**；违反 §15 injection 规范 | 这两个技能无法自进化 |
| **P3** | 🟠 高 | 构建 | **inspect 命令路径结构不匹配**（期望子目录，实际平面文件），所有平台均失败 | 无法使用 inspect 工具 |
| **P4** | 🟠 高 | 示例技能 | **code-reviewer LEAN=340**（UNCERTAIN），但声称 PLATINUM 960；缺少 `## §N` 和 Red Lines | 认证报告不可信 |
| **P5** | 🟠 高 | 示例技能 | **doc-generator eval-report 使用旧阈值**（SILVER=700-849, GOLD=850-999），已与修正后规范不符 | 认证结论无效 |
| **P6** | 🟠 高 | 构建 | **208 个未填充占位符**在已安装技能中（来自嵌入的技能模板），触发 LEAN 检查失败（-50分） | LEAN 评分失真 |
| **P7** | 🟡 中 | 构建 | **5个占位符未定义**（p0_count, p1_count, p2_count, p3_count, generated_at）导致安全统计和时间戳无法显示 | 输出内容不完整 |
| **P8** | 🟡 中 | 示例技能 | **api-tester UTE 不完整**：缺少 `framework_version`、`injection_date` 字段和 §UTE 正文段落 | UTE 功能不完整 |
| **P9** | 🟡 中 | 示例技能 | **api-tester `certified_lean_score: 470` 与实测 LEAN=390 不符**（误差80分） | LEAN 基线不准 |
| **P10** | 🟡 中 | 示例技能 | **api-tester 残留 1 个 `{{API_BASE_URL}}` 占位符**（来自 api-integration 模板未填写）| 技能不完整 |
| **P11** | 🟡 中 | 示例技能 | **doc-generator 触发词不足**：仅覆盖2/4模式（60/120分），缺少 LEAN 和 OPTIMIZE 触发词 | 模式触发不完整 |
| **P12** | 🟢 低 | 示例技能 | **code-reviewer 无 `## §N` 格式段落**：使用 `## REVIEW Mode` 而非 `## §1`，影响 LEAN 模式段落检查 | 格式不符规范 |

---

## 根本原因分析

### 问题集群一：构建系统未部署实际规范（P1, P3, P6, P7）

`builder/src/core/reader.js` 仅读取 `core/` 目录下的 YAML 文件，**完全没有读取 `skill-framework.md`**。这导致：
1. 安装的技能文件是通用模板（`builder/templates/claude.md`）+ 原始 YAML 数据，而非 skill-framework.md 定义的行为规范
2. `skill-framework.md` 本身才应该成为 Claude 平台的安装文件，但它被绕过了
3. 嵌入的技能模板（workflow-automation等）带来大量占位符

### 问题集群二：示例技能在规范升级前已生成（P2, P4, P5, P8, P9, P10, P11, P12）

三个示例技能均基于 v1.0.0 旧规范生成（`created: 2026-03-31`），在 skill-framework.md 升级到 v2.0.0 之前：
- 旧规范下无 UTE 要求 → code-reviewer/doc-generator 缺少 UTE
- 旧规范下认证阈值不同 → doc-generator eval-report 使用旧阈值
- api-tester 虽有部分 UTE 但不完整，且 LEAN 评分未重新计算

---

## 建议修复优先级

### 立即修复（P1）

**核心问题**：将 `skill-framework.md` 直接作为 Claude 平台的安装来源，或确保构建流水线正确嵌入其内容。

最简修复方案：
```json
"install:claude": "cp skill-framework.md ~/.claude/skills/skill-writer.md"
```

或在 `reader.js` 中增加读取 `skill-framework.md` 的逻辑，并在 Claude 平台构建模板中引用其内容。

### 高优先级（P2-P6）

1. **P2** — 为 code-reviewer 和 doc-generator 注入 UTE（运行 INJECT UTE 步骤）
2. **P3** — 修复 inspect 命令，使其支持平面文件路径（或修改 build 输出为子目录结构）
3. **P4/P5** — 重新评测并更新 code-reviewer、doc-generator 的 eval-report
4. **P6** — 在 LEAN 评分时豁免已嵌入技能模板中的占位符

### 中优先级（P7-P12）

5. **P7** — 在 `build.js:skillMetadata` 中增加 p0_count/p1_count/p2_count/p3_count/generated_at 字段
6. **P8** — 补全 api-tester 的 UTE 段落和 YAML 字段
7. **P9** — 重新计算 api-tester 的 certified_lean_score
8. **P10** — 填写 api-tester 中的 `{{API_BASE_URL}}` 占位符
9. **P11** — 为 doc-generator 添加 LEAN 和 OPTIMIZE 触发词
10. **P12** — 将 code-reviewer 段落标题改为 `## §N` 格式

---

*本报告由 Claude Code 基于用户手册端到端测试生成，2026-03-31*
