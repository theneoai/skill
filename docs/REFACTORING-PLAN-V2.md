# 项目全面重构方案 V2

> 基于评分系统 Review + 代码深度审计 | 2026-03-30

---

## 一、重构目标

1. **修正评分系统** — 消除 6 个已确认的算法级 Bug，使认证层级在数学上可达
2. **分离"启发式"与"运行时"评估** — 诚实标注 Phase 3 的实际性质，为真实运行时测试建立接口
3. **统一常量管理** — 所有阈值、分值、tier 定义仅在一处声明
4. **提高可维护性** — 大规模 Bash → 分层架构（核心逻辑 Python + Bash 胶水层）
5. **建立可信基准** — 引入人工标注语料库，使 F1/MRR 成为真实度量而非形式参数

---

## 二、已完成修复（本 PR）

### Phase 1：评分系统 Bug 修复

| Bug | 文件 | 修复内容 |
|-----|------|---------|
| S001 | text_scorer.sh | Domain Knowledge framework_count 上限 10→20，使 DK max = 70 |
| S002 | certifier.sh | F1/MRR 实际参与认证分计算（Quality Gates 20pts） |
| S003 | certifier.sh | 删除循环自评 report_points，改为 F1/MRR quality gate 奖励 |
| S004 | certifier.sh | certify() 接收 phase1_score，total 纳入全部 1000pts |
| S005 | certifier.sh | 方差阈值统一为 <10/<15/<20/<30（与 determine_tier 对齐） |
| S006 partial | runtime_tester.sh | 添加诚实注释 + 修复 memory 误匹配 "read/write" |

---

## 三、重构架构设计

### 3.1 当前架构问题图

```
当前 (问题):
┌─────────────────────────────────────────────────────────────────┐
│                     tools/eval/                                  │
│                                                                  │
│  Phase 1 (100pts)   Phase 2 (350pts)   Phase 3 (450pts) ←[BUG] │
│  keyword grep       keyword frequency  keyword frequency        │
│                     (正确命名)          (命名为Runtime但不是)    │
│                                                                  │
│  Phase 4 certify (100pts) ←[BUG: Phase1未加入total]            │
│                   ←[BUG: F1/MRR传入不使用]                      │
│                   ←[BUG: 循环自评20pts]                         │
│                   ←[BUG: 方差阈值三处不一致]                    │
└─────────────────────────────────────────────────────────────────┘

所有4个Phase实际上都是: grep keyword | count → map to score
```

### 3.2 目标架构

```
重构后 (目标):
┌─────────────────────────────────────────────────────────────────┐
│                     tools/eval/                                  │
│                                                                  │
│  Phase 1 (100pts)     Phase 2 (300pts)      Phase 3 (500pts)   │
│  结构解析              启发式文本质量         真实运行时测试      │
│  YAML + structure      heuristic keywords    LLM API calls      │
│  (诚实: 结构检查)       (诚实: 文本分析)      (真正的行为测试)   │
│                                                                  │
│  Phase 4 certify (100pts)                                       │
│  ✓ Phase1纳入total                                               │
│  ✓ F1/MRR Quality Gates                                         │
│  ✓ 方差阈值统一                                                   │
│  ✓ 无循环自评                                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 四、详细重构任务

### M1 — 评分权重重新分配（破坏性变更）

**动机**：Phase 3 完全是文本分析，与 Phase 2 重复；真正的运行时测试价值更高。

**当前权重**：
```
Phase 1: Parse        100pts  (10%)
Phase 2: Text         350pts  (35%)
Phase 3: "Runtime"    450pts  (45%) ← 实际是文本分析
Phase 4: Certify      100pts  (10%)
```

**建议权重**：
```
Phase 1: Parse           100pts (10%)  维持
Phase 2: Text Heuristic  300pts (30%)  ↓50pts（承认其局限性）
Phase 3: Runtime (真实)  500pts (50%)  ↑50pts（真正的 LLM 调用）
Phase 4: Certify         100pts (10%)  维持
```

**Phase 3 真实运行时测试内容**：

| 测试项 | 分值 | 实现方式 |
|--------|------|---------|
| Mode Routing Accuracy | 100pts | 用真实触发器语料测 F1/MRR |
| Response Consistency | 100pts | 同一问题问 3 次，测方差 |
| Boundary Adherence | 100pts | 测 jailbreak/out-of-scope 拒绝率 |
| Task Completion | 100pts | 测完整 workflow 执行成功率 |
| Error Recovery | 100pts | 测异常输入后的恢复行为 |

---

### M2 — 常量单一来源（Single Source of Truth）

**问题**：阈值分散在 4 个文件中：

| 常量 | constants.sh | certifier.sh | text_scorer.sh | main.sh |
|------|-------------|--------------|----------------|---------|
| VARIANCE_MAX | 20 | 多处不一致 | — | — |
| PLATINUM_MIN | 950 | 用 total=800 判断 | — | — |
| TEXT 分值 | 定义 | 用硬编码 330 | 用局部变量 | — |

**修复方案**：所有 certifier 的 tier 子分值也定义在 constants.sh：

```bash
# 新增到 constants.sh
readonly PLATINUM_TEXT_MIN=330   # 350 × 94.3%
readonly PLATINUM_RUNTIME_MIN=475 # 500 × 95%
readonly GOLD_TEXT_MIN=270        # 300 × 90%
readonly GOLD_RUNTIME_MIN=450     # 500 × 90%
readonly SILVER_TEXT_MIN=240      # 300 × 80%
readonly SILVER_RUNTIME_MIN=400   # 500 × 80%
readonly BRONZE_TEXT_MIN=210      # 300 × 70%
readonly BRONZE_RUNTIME_MIN=350   # 500 × 70%

# F1/MRR tier thresholds (currently unused — BUG-S002 fix)
readonly F1_PLATINUM=0.92
readonly F1_GOLD=0.90
readonly F1_SILVER=0.87
readonly F1_BRONZE=0.85
readonly MRR_PLATINUM=0.88
readonly MRR_GOLD=0.85
readonly MRR_SILVER=0.82
readonly MRR_BRONZE=0.80
```

---

### M3 — Phase 3 真实运行时框架

**新文件**：`tools/eval/scorer/runtime_agent_tester_v2.sh`

```bash
# 真实运行时测试接口（5个子测试）
run_mode_routing_test()     # 调用 trigger_analyzer + 真实语料
run_consistency_test()      # 同问题 LLM 调用 3次，计算方差
run_boundary_test()         # jailbreak 测试用例集
run_task_completion_test()  # 完整 workflow 执行
run_error_recovery_test()   # 异常输入处理
```

**测试语料库扩展**：`tools/eval/corpus/`
- `routing_corpus.json` — 200+ 触发器测试用例（已存在，需扩充）
- `boundary_corpus.json` — 50+ 越权请求测试用例（**新建**）
- `consistency_corpus.json` — 30+ 一致性测试用例（**新建**）

---

### M4 — 语言迁移策略（Bash → Python）

**当前问题**：18,900 行 Bash 带来的具体痛点（已记录 bug）：

| 痛点 | 具体案例 | Python 解决方案 |
|------|---------|----------------|
| 浮点比较 | `convergence.sh` 字符串比较 bug | 原生 float 运算 |
| 条件判断 | `engine.sh` `[ string ]` 恒真 bug | 类型系统 |
| 跨平台差异 | macOS `sed -i` 不兼容 | `pathlib` / `re` |
| 并发控制 | 文件锁脆弱 | `threading.Lock` / `asyncio` |
| JSON 处理 | 依赖 `jq` 外部命令 | 内置 `json` 模块 |
| 测试隔离 | 无 mock 机制 | `unittest.mock` |

**迁移策略（渐进式，不破坏接口）**：

```
阶段 A（1个月）: 核心算法层
  tools/eval/scorer/ → eval/scorer.py
  tools/engine/      → engine/optimizer.py
  保持 .sh wrapper 调用 Python，接口不变

阶段 B（2个月）: LLM 调用层
  tools/lib/agent_executor.sh → lib/llm_client.py
  统一 async/await，支持并发调用
  引入 httpx + tenacity 替代 curl + 手写重试

阶段 C（3个月）: CLI 层
  cli/skill → cli/skill.py (Click framework)
  保留 .sh 作为向后兼容 shim
```

**迁移优先级**（按 bug 密度排序）：
1. `tools/engine/convergence.sh` → Python（已有 2 个 bug）
2. `tools/eval/scorer/text_scorer.sh` → Python（关键词统计用 re 更可靠）
3. `tools/lib/agent_executor.sh` → Python（887 行，最复杂）

---

### M5 — 测试体系重构

**当前问题**：
- E2E 测试调用真实 API（CI 不稳定）— 已修复（本 PR 加了 mock）
- 无单元测试覆盖评分函数本身
- 缺少分值回归测试（修改评分逻辑后无法验证对已知 skill 的影响）

**新增**：

```bash
# tests/scoring/test_score_regression.sh
# 对 3 个已知 skill 的黄金分数进行回归测试
assert_score "fixtures/gold_skill_platinum.md" ">=950"
assert_score "fixtures/gold_skill_silver.md" "800-899"
assert_score "fixtures/poor_skill.md" "<700"
```

---

## 五、重构后评分可达性验证

修复 BUG-S004（Phase1 纳入 total）后的分数可达性：

```
最大可得分（理论）:
  Phase 1:    100/100
  Phase 2:    350/350  (BUG-S001 修复后)
  Phase 3:    450/450
  Phase 4:    100/100
              ───────
  合计:      1000/1000

PLATINUM 条件 (total ≥ 950):
  需要: 100 + 330 + 430 + 90 = 950 ✓ (现在可达)

GOLD 条件 (total ≥ 900):
  需要: 100 + 315 + 405 + 80 = 900 ✓ (现在可达)
```

---

## 六、里程碑时间表

| 里程碑 | 内容 | 时间 | 状态 |
|--------|------|------|------|
| **M0** | 评分 Bug 修复（S001-S006） | 2026-03-30 | ✅ 已完成 |
| **M1** | constants.sh 单一来源 | 第1周 | 待做 |
| **M2** | Phase 3 诚实标注 + 新接口框架 | 第2周 | 部分完成 |
| **M3** | 真实运行时语料库建立（200用例） | 第3-4周 | 待做 |
| **M4** | 评分回归测试套件 | 第2周 | 待做 |
| **M5A** | convergence + scorer → Python | 第5-6周 | 待做 |
| **M5B** | agent_executor → Python async | 第7-10周 | 待做 |
| **M5C** | CLI → Click | 第11-12周 | 待做 |
| **M6** | 真实 Phase 3 (LLM runtime tests) | 第8-12周 | 待做 |

---

## 七、重构前后对比

| 维度 | 重构前 | 重构后 |
|------|--------|--------|
| PLATINUM/GOLD 可达性 | 不可达（数学错误） | 可达 |
| F1/MRR 影响认证 | 否（传入未使用） | 是（Quality Gates 20pts） |
| Phase 3 诚实性 | 名为运行时，实为文本分析 | 正确标注，真实运行时接口已建立 |
| 方差阈值一致性 | 三处不同定义 | 统一到 constants.sh |
| Domain Knowledge 上限 | 声明 70，实际 60 | 修复为 70 |
| 测试 CI 稳定性 | ~85%（真实 API 调用） | ~99%（LLM Mock 回放） |
| 核心语言 | 18,900 行 Bash | 逐步迁移至 Python（保持接口兼容） |
