# Agent-Skills-Creator 自我优化能力设计

本文档定义 agent-skills-creator 如何实现自我优化，包括自我优化循环、多智能体协调机制，以及与现有 skill-manager 脚本的集成方式。

---

## 一、自我优化循环 (Self-Optimization Loop)

### 1.1 循环架构

```
┌─────────────────────────────────────────────────────────────────┐
│                      SELF-OPTIMIZATION LOOP                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐    ┌──────────────┐    ┌────────────────────┐    │
│  │  READ    │───▶│  IDENTIFY    │───▶│  MAKE IMPROVEMENT  │    │
│  │  State   │    │  Weakest     │    │  Targeted Fix      │    │
│  └──────────┘    └──────────────┘    └─────────┬──────────┘    │
│                                                │                 │
│                                                ▼                 │
│  ┌──────────┐    ┌──────────────┐    ┌────────────────────┐    │
│  │  LOG &   │◀───│  VERIFY      │◀───│  APPLY & TEST      │    │
│  │  REPEAT  │    │  Improvement │    │  Change            │    │
│  └──────────┘    └──────────────┘    └────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 六维度评分体系

继承自 skill-manager 的评分体系：

| 维度 | 权重 | 评分范围 | 核心指标 |
|------|------|----------|----------|
| System Prompt | 20% | 0-10 | §1.1 Identity, §1.2 Framework, §1.3 Constraints |
| Domain Knowledge | 20% | 0-10 | 量化数据、案例、基准、框架引用 |
| Workflow | 20% | 0-10 | 阶段定义、Done/Fail 标准、决策点 |
| Error Handling | 15% | 0-10 | 错误场景、反模式、恢复策略、边缘用例 |
| Examples | 15% | 0-10 | 示例数量、Input/Output、验证步骤 |
| Metadata | 10% | 0-10 | name, description, license, version, author |

### 1.3 循环执行流程

#### 步骤 1: READ — 读取当前状态

```bash
# 使用 score.sh 读取当前评分
./scripts/skill-manager/score.sh SKILL.md

# 输出示例:
#   System Prompt        8/10  (×0.20)
#   Domain Knowledge     6/10  (×0.20)  ⚠generic-content
#   Workflow            7/10  (×0.20)
#   Error Handling      5/10  (×0.15)  ⚠no-recovery
#   Examples            4/10  (×0.15)  ⚠no-examples
#   Metadata           10/10  (×0.10)
#
#   Text Score (heuristic):  6.5/10
```

#### 步骤 2: IDENTIFY — 识别最弱维度

```bash
# 识别低于阈值的维度
WEAKEST=$(echo "$SCORE_OUTPUT" | grep -E "^  [A-Za-z].* [0-9]+\.[0-9]/10" | \
  awk '{print $1, $2}' | sort -k2 -n | head -1 | awk '{print $1}')
```

优先级规则:
1. 分数 < 6.0 的维度优先处理
2. 权重高的维度优先 (System Prompt > Domain > Workflow)
3. 多维度并列时，按循环轮次轮询

#### 步骤 3: MAKE IMPROVEMENT — 针对性改进

根据最弱维度调用对应的改进函数:

```bash
improve_dimension() {
  local weakest="$1"
  case "$weakest" in
    "System")
      improve_system_prompt
      ;;
    "Domain")
      improve_domain_knowledge
      ;;
    "Workflow")
      improve_workflow
      ;;
    "Error")
      improve_error_handling
      ;;
    "Examples")
      improve_examples
      ;;
    "Metadata")
      improve_metadata
      ;;
  esac
}
```

具体改进策略:

**System Prompt 改进:**
- 添加 §1.1 Identity (Role, Expertise, Boundary)
- 添加 §1.2 Framework (Architecture, Tools, Memory)
- 添加 §1.3 Constraints (Never, Always 规则)

**Domain Knowledge 改进:**
- 添加量化指标 (e.g., >95% accuracy, <200ms latency)
- 添加行业基准和 KPI
- 添加框架引用 (ReAct, CoT, ToT)

**Workflow 改进:**
- 添加 Done/Fail 标准
- 添加决策点 (if-then-else)
- 结构化阶段定义

**Error Handling 改进:**
- 添加错误恢复策略
- 添加反模式警示
- 添加边缘用例分析

**Examples 改进:**
- 添加 Input/Output 示例
- 添加验证步骤
- 添加真实场景案例

**Metadata 改进:**
- 补全缺失字段
- 规范化版本格式
- 清理占位符

#### 步骤 4: VERIFY — 验证改进

```bash
# 验证改进效果
NEW_SCORE=$(./scripts/skill-manager/score.sh SKILL.md | grep "Text Score" | awk '{print $4}')

if compare "$NEW_SCORE" ">" "$OLD_SCORE"; then
  STATUS="keep"
else
  STATUS="discard"  # 回滚
fi
```

#### 步骤 5: LOG & REPEAT — 记录并重复

```bash
# 记录到 results.tsv
echo -e "$round\t$NEW_SCORE\t$DELTA\t$STATUS\t$WEAKEST\t$IMPROVEMENT" >> results.tsv

# 继续下一轮或终止
if compare "$NEW_SCORE" ">=" "9.5"; then
  echo "★★★ 达到 EXEMPLARY 标准"
  break
fi
```

### 1.4 终止条件

循环在以下条件之一满足时终止:

| 条件 | 说明 |
|------|------|
| 分数 ≥ 9.5 | 达到 EXEMPLARY 级别 |
| 连续 5 轮无改善 | 陷入局部最优 |
| 达到最大轮次 (默认 100) | 资源限制 |
| 维度全达到 ≥ 8.0 | 达到 CERTIFIED 标准 |

---

## 二、多智能体协调 (Multi-Agent Coordination)

### 2.1 智能体类型

| 智能体 | 职责 | 关注维度 | 输出 |
|--------|------|----------|------|
| **Security Agent** | 安全审查 | 反模式、注入风险、数据泄露 | 安全报告 |
| **Trigger Agent** | 触发词分析 | 模式识别准确率 | 触发词覆盖度 |
| **Runtime Agent** | 运行时验证 | 实际执行效果 | 运行时评分 |
| **Quality Agent** | 质量评估 | 六维度综合评分 | 质量报告 |
| **EdgeCase Agent** | 边缘用例 | 边界条件、异常处理 | 边缘用例清单 |

### 2.2 并行执行架构

```
                    ┌─────────────────┐
                    │  Orchestrator   │
                    │  (协调器)        │
                    └────────┬────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
          ▼                  ▼                  ▼
   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
   │  Security  │    │   Trigger   │    │   Runtime   │
   │   Agent    │    │    Agent    │    │    Agent    │
   └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
          │                  │                  │
          ▼                  ▼                  ▼
   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
   │   Quality   │    │  EdgeCase   │    │  (结果汇总)  │
   │    Agent   │    │    Agent    │    │            │
   └──────┬──────┘    └──────┬──────┘    └─────────────┘
          │                  │
          └────────┬─────────┘
                   ▼
            ┌─────────────┐
            │ Aggregator  │
            │  (聚合器)    │
            └─────────────┘
```

### 2.3 智能体执行协议

#### 2.3.1 Security Agent

```bash
# 安全审查协议
security_check() {
  local skill_file="$1"
  
  # 检查注入风险
  check_injection_risks "$skill_file"
  
  # 检查数据泄露
  check_data_exposure "$skill_file"
  
  # 检查权限提升
  check_privilege_escalation "$skill_file"
  
  # 检查路径遍历
  check_path_traversal "$skill_file"
  
  # 输出安全评分 (0-10)
  echo "SECURITY_SCORE: $score"
}
```

#### 2.3.2 Trigger Agent

```bash
# 触发词分析协议
trigger_analysis() {
  local skill_file="$1"
  
  # 提取四模式触发词
  parse_triggers "CREATE" "$skill_file"
  parse_triggers "EVALUATE" "$skill_file"
  parse_triggers "RESTORE" "$skill_file"
  parse_triggers "TUNE" "$skill_file"
  
  # 测试触发准确率
  test_trigger_accuracy "$skill_file"
  
  # 输出覆盖度报告
  echo "TRIGGER_COVERAGE: $coverage%"
}
```

#### 2.3.3 Runtime Agent

```bash
# 运行时验证协议
runtime_validation() {
  local skill_file="$1"
  
  # 身份一致性检查
  check_identity_immersion
  
  # 框架执行测试
  test_framework_execution
  
  # 输出可操作性
  measure_output_actionability
  
  # 知识准确性验证
  verify_knowledge_accuracy
  
  # 长对话稳定性
  test_conversation_stability
  
  # 输出运行时评分
  echo "RUNTIME_SCORE: $score"
}
```

#### 2.3.4 Quality Agent

```bash
# 质量评估协议
quality_assessment() {
  local skill_file="$1"
  
  # 运行文本评分
  run_text_scoring
  
  # 运行运行时评分
  run_runtime_scoring
  
  # 计算方差
  calculate_variance
  
  # 输出综合评分
  echo "QUALITY_SCORE: $score"
  echo "VARIANCE: $variance"
}
```

#### 2.3.5 EdgeCase Agent

```bash
# 边缘用例分析协议
edge_case_analysis() {
  local skill_file="$1"
  
  # 空输入测试
  test_empty_input
  
  # 极端值测试
  test_extreme_values
  
  # 矛盾输入测试
  test_contradictory_input
  
  # 角色混淆测试
  test_role_confusion
  
  # 资源限制测试 ($0 预算, 1 天时间线)
  test_resource_limits
  
  # 输出边缘用例清单
  echo "EDGE_CASES: $count"
  echo "RESILIENCE_SCORE: $score"
}
```

### 2.4 结果聚合机制

#### 2.4.1 聚合算法

```bash
aggregate_findings() {
  local security_report="$1"
  local trigger_report="$2"
  local runtime_report="$3"
  local quality_report="$4"
  local edgecase_report="$5"
  
  # 加权汇总
  FINAL_SCORE=$(python3 - << PYTHON
security = float("$security_report"['score']) * 0.15
trigger = float("$trigger_report"['coverage']) * 0.15
runtime = float("$runtime_report"['score']) * 0.25
quality = float("$quality_report"['score']) * 0.30
edgecase = float("$edgecase_report"['resilience']) * 0.15
total = security + trigger + runtime + quality + edgecase
print(f"{total:.2f}")
PYTHON
)
  
  echo "AGGREGATED_SCORE: $FINAL_SCORE"
}
```

#### 2.4.2 优先级矩阵

| 问题类型 | 优先级 | 处理时限 |
|----------|--------|----------|
| 安全漏洞 | P0 | 立即修复 |
| 运行时崩溃 | P1 | 24 小时内 |
| 触发失准 > 20% | P2 | 48 小时内 |
| 质量评分 < 7.0 | P3 | 72 小时内 |
| 边缘用例失败 | P4 | 下一迭代 |

### 2.5 冲突解决机制

#### 2.5.1 冲突类型

| 冲突类型 | 描述 | 解决策略 |
|----------|------|----------|
| 评分冲突 | 多智能体对同一维度评分不一致 | 取平均值，高权重智能体优先 |
| 优先级冲突 | 多个问题争夺同一资源 | 按 P0>P1>P2>P3>P4 排序 |
| 改进建议冲突 | 不同智能体建议相互矛盾 | Security > Runtime > Quality |

#### 2.5.2 冲突解决算法

```bash
resolve_conflict() {
  local agent_a="$1"
  local agent_b="$2"
  local dimension="$3"
  
  # 获取两个智能体的评分和建议
  score_a=$(get_agent_score "$agent_a" "$dimension")
  score_b=$(get_agent_score "$agent_b" "$dimension")
  advice_a=$(get_agent_advice "$agent_a" "$dimension")
  advice_b=$(get_agent_advice "$agent_b" "$dimension")
  
  # 高权重智能体优先
  if [[ "$agent_a" == "Security" ]] || [[ "$agent_b" == "Security" ]]; then
    echo "$advice_a"  # Security 建议优先
    return
  fi
  
  # 取保守建议 (不引入新风险的方案)
  if [[ ${#advice_a} -lt ${#advice_b} ]]; then
    echo "$advice_a"
  else
    echo "$advice_b"
  fi
}
```

---

## 三、与现有脚本集成

### 3.1 脚本映射表

| 脚本路径 | 功能 | 自我优化中的用途 |
|----------|------|------------------|
| `scripts/skill-manager/score.sh` | 六维度文本评分 | 循环步骤 1, 4: 读取/验证状态 |
| `scripts/skill-manager/score-v2.sh` | 改进版评分 | 备用评分引擎 |
| `scripts/skill-manager/validate.sh` | 格式验证 | 确保改进不破坏格式 |
| `scripts/skill-manager/tune.sh` | AI 驱动优化 | 直接执行优化循环 |
| `scripts/skill-manager/feedback.sh` | 生产反馈收集 | 收集真实使用数据 |
| `scripts/skill-manager/runtime-validate.sh` | 运行时验证 | Runtime Agent 实现 |
| `scripts/skill-manager/edge-case-check.sh` | 边缘用例测试 | EdgeCase Agent 实现 |
| `scripts/skill-manager/certify.sh` | 完整认证 | 优化后的最终认证 |
| `scripts/skill-manager/eval.sh` | 双轨评估 | Quality Agent 实现 |
| `scripts/skill-manager/lib/weights.sh` | 权重常量 | 统一权重体系 |

### 3.2 集成工作流

#### 3.2.1 快速优化模式 (Quick Tune)

```bash
# 使用 tune.sh 进行快速优化
./scripts/skill-manager/tune.sh agent-skills-creator/SKILL.md 20

# 输出示例:
#   Initial: 7.5
#   Round 5: 8.1 (Δ+0.6) [keep] | weakest: Examples
#   Round 10: 8.4 (Δ+0.3) [keep] | weakest: Error Handling
#   ...
#   Final: 9.2
```

#### 3.2.2 完整优化模式 (Full Optimization)

```bash
# 1. 验证当前状态
./scripts/skill-manager/validate.sh agent-skills-creator/SKILL.md

# 2. 评分当前质量
./scripts/skill-manager/score.sh agent-skills-creator/SKILL.md

# 3. 运行时验证
./scripts/skill-manager/runtime-validate.sh agent-skills-creator/SKILL.md

# 4. 运行优化循环 (最多 100 轮)
./scripts/skill-manager/tune.sh agent-skills-creator/SKILL.md 100

# 5. 边缘用例检查
./scripts/skill-manager/edge-case-check.sh

# 6. 收集反馈
./scripts/skill-manager/feedback.sh

# 7. 最终认证
./scripts/skill-manager/certify.sh agent-skills-creator/SKILL.md
```

#### 3.2.3 多智能体并行模式 (Multi-Agent Mode)

```bash
# 启动多智能体并行优化
./scripts/skill-manager/score-multi.sh agent-skills-creator/SKILL.md

# 该脚本会:
# 1. 并行启动多个评分实例
# 2. 聚合结果
# 3. 识别共识弱点
# 4. 生成改进建议
```

### 3.3 自我优化调用接口

```bash
# 自我优化入口函数
self_optimize() {
  local skill_file="$1"
  local mode="${2:-standard}"  # quick | standard | deep
  
  echo "开始自我优化: $skill_file (模式: $mode)"
  
  # 读取当前状态
  CURRENT_SCORE=$(bash "$SCRIPT_DIR/score.sh" "$skill_file" | grep "Text Score" | awk '{print $4}')
  echo "当前分数: $CURRENT_SCORE"
  
  case "$mode" in
    "quick")
      ROUNDS=10
      ;;
    "standard")
      ROUNDS=50
      ;;
    "deep")
      ROUNDS=100
      ;;
  esac
  
  # 执行优化循环
  bash "$SCRIPT_DIR/tune.sh" "$skill_file" "$ROUNDS"
  
  # 验证结果
  NEW_SCORE=$(bash "$SCRIPT_DIR/score.sh" "$skill_file" | grep "Text Score" | awk '{print $4}')
  echo "优化后分数: $NEW_SCORE"
  
  # 方差检查
  bash "$SCRIPT_DIR/runtime-validate.sh" "$skill_file"
}
```

### 3.4 自动化调度

```bash
# cron 调度示例 (每日凌晨 3 点运行)
# 0 3 * * * /path/to/scripts/skill-manager/tune.sh /Users/lucas/.agents/skills/agent-skills-creator/SKILL.md 20 >> /var/log/self-optimize.log 2>&1

# 或者使用 launchd (macOS)
# ~/Library/LaunchAgents/com.agent-skills-creator.optimize.plist
```

---

## 四、关键文件路径

```
agent-skills-creator/
├── SKILL.md                          # 主技能文件
├── scripts/
│   └── skill-manager/
│       ├── score.sh                  # 文本评分
│       ├── score-v2.sh               # 改进评分
│       ├── score-multi.sh            # 多智能体评分
│       ├── tune.sh                   # AI 优化循环
│       ├── validate.sh               # 格式验证
│       ├── feedback.sh               # 反馈收集
│       ├── runtime-validate.sh        # 运行时验证
│       ├── edge-case-check.sh        # 边缘用例检查
│       ├── certify.sh                # 完整认证
│       ├── eval.sh                   # 双轨评估
│       └── lib/
│           ├── weights.sh            # 权重常量
│           └── trigger_patterns.sh   # 触发词模式
└── references/
    └── SELF_OPTIMIZATION.md          # 本文档
```

---

## 五、评分与认证标准

### 5.1 评分等级

| 等级 | 分数范围 | 说明 |
|------|----------|------|
| EXEMPLARY ★★★ | ≥ 9.5 | 卓越，可作为标杆 |
| EXEMPLARY ✓ | ≥ 9.0 | 优秀，接近标杆 |
| CERTIFIED ✓ | ≥ 8.0 | 合格，可用于生产 |
| GOOD | ≥ 7.0 | 良好，需小幅改进 |
| ACCEPTABLE | ≥ 6.0 | 可接受，需要改进 |
| BELOW STANDARD | < 6.0 | 不达标，需大幅修复 |

### 5.2 认证条件

```
CERTIFIED = Text ≥ 8.0 AND Runtime ≥ 8.0 AND Variance < 1.0
```

### 5.3 优化目标

| 阶段 | 目标分数 | 说明 |
|------|----------|------|
| 初始 | 6.0 - 7.0 | 基础可用 |
| 第一轮优化 | 8.0 | 达到 CERTIFIED |
| 第二轮优化 | 9.0 | 达到 EXEMPLARY |
| 最终目标 | 9.5 | 达到标杆级别 |

---

## 版本历史

| 版本 | 日期 | 修改内容 |
|------|------|----------|
| 1.0.0 | 2026-03-27 | 初始版本 |
