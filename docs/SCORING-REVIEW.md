# 评分系统全面 Review 报告

> 审计日期：2026-03-30 | 审计范围：全部 eval/ 评分代码

---

## 一、评分系统总体架构

```
Phase 1: Parse & Validate   100pts  (tools/eval/main.sh)
Phase 2: Text Quality       350pts  (tools/eval/scorer/text_scorer.sh)
Phase 3: Runtime Score      450pts  (tools/eval/scorer/runtime_tester.sh)
Phase 4: Certify            100pts  (tools/eval/certifier.sh)
                          ──────
总计声明值                 1000pts
```

---

## 二、发现的评分错误（精确数值审计）

### BUG-S001 ★★★★★ — Domain Knowledge 最高分声明 70pts，实际可达 60pts

**位置**：`text_scorer.sh` 的 `score_domain_knowledge()`

**精确计算**：
```
Quantitative data:   最高 20pts  (≥10 次)
Framework mentions:  最高 10pts  (≥4 次)
Benchmark/standard:  最高 15pts  (≥3 次)
Case study:          最高 15pts  (≥3 次)
反模式惩罚:          最低 -10pts
────────────────────────────────
理论最高:  20+10+15+15 = 60pts
声明最高:  70pts
差额:      10pts (永久系统性偏差)
```

**影响**：每次评估均有 10pts 的系统性差距，导致：
- 最高可得总分实为 990pts，而非 1000pts
- Phase 2 实际上限为 340pts，而非 350pts
- 凡是 Domain Knowledge 满分的 skill 都被虚假扣分 10pts
- 若目标是 PLATINUM(≥950)，实际需要 940 分即可，但系统永远无法判断为 PLATINUM

**修复**：将 Framework mentions 上限从 10pts 提升至 20pts（修复方案见下）

---

### BUG-S002 ★★★★★ — certifier.sh 中 F1/MRR 传入但从未使用

**位置**：`certifier.sh:certify()` 第 70-97 行

**问题**：
```bash
# certify() 函数签名接收 6 个参数
certify() {
    local skill_file="$1"
    local text_score="$2"
    local runtime_score="$3"
    local variance="$4"
    local f1_score="$5"     # ← 接收了
    local mrr_score="$6"    # ← 接收了
    local trigger_acc="$7"  # ← 接收了

    # ...但后续计算中 f1_score / mrr_score / trigger_acc 从未被引用
    local certify_total=$((variance_points + tier_points + report_points + security_points))
}
```

**影响**：认证分数完全不反映 F1/MRR 指标，这与文档中「F1≥0.90 是 PLATINUM 必要条件」的描述严重矛盾。一个 F1=0.1 的 skill 和 F1=0.99 的 skill 得到完全相同的认证分数。

**修复**：在 certify_total 中加入 F1/MRR 分量（见修复方案）

---

### BUG-S003 ★★★★ — certifier.sh 的"报告完整性"是循环自评

**位置**：`certifier.sh:certify()` 第 114-127 行

**问题**：
```bash
# 检查评估本轮产生的输出文件是否存在，作为 certify 分数的依据
if [[ -f "report.json" ]] || [[ -f "eval_results/report.json" ]]; then
    json_report_exists=1
fi
report_points=$((json_report_exists * 10 + html_report_exists * 10))
```

**影响**：这 20pts 奖励的是「评估工具自己输出了文件」，而非 skill 本身的质量。完全由运行环境决定，与 skill 内容无关。这是**自举偏差**（circular rewarding）。

**修复**：将 20pts 重新分配到 F1/MRR 门槛奖励

---

### BUG-S004 ★★★★ — Phase 1、3、4 共同组成的总分计算遗漏 Phase 1

**位置**：`certifier.sh:certify()` 第 83 行

**问题**：
```bash
# certifier 的 total 只加了 Phase 2 + Phase 3
local total
total=$(echo "scale=2; $text_score + $runtime_score" | bc)
# Phase 1 的 100pts 完全没有纳入 total
```

然后：
```bash
# determine_tier() 基于这个 total 判断 tier
tier=$(determine_tier "$total" "$text_score" "$runtime_score" "$variance")
```

**影响**：tier 判断基于 800pts 而非 1000pts，所有 tier 阈值实际都是在 800pts 体系下的阈值。文档描述的「GOLD ≥ 900pts」与实际判断逻辑不一致（因为传入的 total 最高 800，永远无法达到 900）。

> **注意**：`determine_tier()` 中 `$GOLD_MIN=900` 将永远无法被满足，因为 total 最高只有 800。这意味着当前系统中 **PLATINUM 和 GOLD 层级在数学上是不可达的**。

**修复**：certifier 接收 phase1_score 参数并加入 total

---

### BUG-S005 ★★★ — 方差阈值定义三处不一致

**三处不同定义**：
```
constants.sh:        VARIANCE_MAX=20（用于 SILVER 档）
certifier.sh certify():  lt_30 < lt_50 < lt_70 < lt_100 < lt_150（分数档）
certifier.sh determine_tier(): lt_10 / lt_15 / lt_20 / lt_30（tier 档）
```

**影响**：
- 同样的方差值，在「分数计算」和「tier 判断」中使用不同阈值
- `constants.sh` 中的 `VARIANCE_MAX=20` 被导入但在 certifier 的分数计算中完全没有使用（certifier 用 <30 作为满分线）

---

### BUG-S006 ★★★ — runtime_tester.sh 完全不是"运行时测试"

**位置**：`tools/eval/scorer/runtime_tester.sh`

**问题**：Phase 3 名为"Runtime Score"，但所有子指标均通过**关键词计数**实现，无任何真实 LLM 调用或执行：

| 指标 | 声称测试内容 | 实际实现 |
|------|------------|---------|
| Identity Consistency (80pts) | 角色一致性 | 检查 "SECURITY" 关键词是否同时有 "reject" |
| Knowledge Accuracy (50pts) | 知识准确性 | 计数 "fact"、"actual"、"specific" 词频 |
| Conversation Stability (50pts) | 多轮对话稳定性 | 计数 "multi-turn"、"conversation" 词频 |
| Trace Compliance (50pts) | 行为追踪合规 | 计数 "rule"、"constraint" 词频 |
| Framework Execution (70pts) | 框架执行 | 计数 "tool"、"memory"、"workflow" 词频 |

**结论**：Phase 3 实质上是 Phase 2 的关键词变体，并非运行时测试。两个阶段合并实际测量的都是同一件事——文本关键词密度。

**最严重问题**：`check_memory_access()` 使用 `grep -cE "read|write|store|retrieve"` — "read" 和 "write" 是英文中最常见的单词之一，任何包含这些词的文档都会得满分，与内容无关。

---

### BUG-S007 ★★ — determine_tier() 的 text_score/runtime_score 子条件与 tier 层级不一致

**certifier.sh** 中的 PLATINUM 条件：
```bash
[[ $(echo "$text_score >= 330" | bc -l) -eq 1 ]]   # 330/350 = 94.3%
[[ $(echo "$runtime_score >= 430" | bc -l) -eq 1 ]] # 430/450 = 95.6%
```

但 **constants.sh** 的 PLATINUM 描述对应：
```bash
F1≥0.92, MRR≥0.88
```

而 F1/MRR 在 certify() 中根本未被使用（见 BUG-S002）。

---

## 三、评分系统总体评价

### 3.1 各 Phase 实际有效性

| Phase | 声称测量内容 | 实际测量内容 | 有效性 |
|-------|------------|------------|--------|
| Phase 1 (100pts) | 结构解析 | YAML + 关键词 grep | ★★★☆☆ 合理 |
| Phase 2 (350pts) | 文本质量 | 关键词频率统计 | ★★☆☆☆ 低效 |
| Phase 3 (450pts) | 运行时行为 | **关键词频率统计** | ★☆☆☆☆ 名实不符 |
| Phase 4 (100pts) | 认证综合 | 部分循环自评 | ★★☆☆☆ 有缺陷 |

### 3.2 分数可达性分析（当前版本）

| Tier | 声称条件 | 数学可达性 |
|------|---------|----------|
| PLATINUM (≥950) | total≥950 | **不可达**（total最高800，certify最高100，合计900） |
| GOLD (≥900) | total≥900 | **不可达**（同上） |
| SILVER (≥800) | total≥800 | **不可达**（certifier total = text+runtime ≤ 800，加certify后≤900，但tier判断用的是不含phase1的total） |
| BRONZE (≥700) | total≥700 | 可达 |

> **结论**：除 BRONZE 外，所有高级认证层级在当前代码中数学上均不可达。这解释了为什么系统自评得分为 777/BRONZE——这不是内容质量问题，而是评分系统的根本性缺陷。

---

## 四、修复优先级矩阵

| ID | 缺陷 | 严重度 | 修复难度 | 优先级 |
|----|------|--------|---------|--------|
| S004 | Phase1 未纳入 total | P0 | 低 | 立即 |
| S002 | F1/MRR 未使用 | P0 | 低 | 立即 |
| S001 | DK max 60≠70 | P1 | 低 | 立即 |
| S003 | 循环自评 20pts | P1 | 低 | 立即 |
| S005 | 方差阈值三处不一致 | P1 | 中 | 本周 |
| S006 | Runtime 非运行时 | P2 | 高 | 下一版本 |
| S007 | Tier 子条件不一致 | P2 | 低 | 本周 |
