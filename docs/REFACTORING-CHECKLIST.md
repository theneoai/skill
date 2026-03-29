# Skill 项目重构检查清单

**版本**: 2.3.0  
**日期**: 2026-03-29  
**状态**: ✅ 完成

---

## 一、修复问题总览

| 优先级 | 问题数 | 已修复 | 状态 |
|--------|--------|--------|------|
| P0 (必须修复) | 4+3 | 7 | ✅ |
| P1 (高优先级) | 9 | 9 | ✅ |
| P2 (中优先级) | 4 | 4 | ✅ |
| P3 (建议改进) | 4 | 4 | ✅ |
| Bug (关键Bug) | 14 | 14 | ✅ |
| **总计** | **38** | **38** | **✅** |

---

## 二、P0 问题修复清单

### 2.1 变量作用域错误
- [x] `engine/orchestrator.sh` - export 顺序修复
- [x] `_workflow.sh` - workflow_init 调用前 export

### 2.2 评分体系不统一
- [x] 创建 `eval/lib/unified_scoring.sh` 统一评分常量
- [x] SKILL.md 更新为 1000分制阈值
- [x] 添加 `LEAN_TIER_*_NORM` 转换常量

### 2.3 F1/MRR 硬编码
- [x] `eval/scorer/runtime_tester.sh` - 使用 trigger_analyzer.sh 实际计算
- [x] `eval/analyzer/trigger_analyzer.sh` - 实现真正的 F1/MRR 计算

### 2.4 路径依赖假设错误
- [x] `engine/lib/bootstrap.sh` - 多路径 fallback
- [x] `_BOOTSTRAP_SOURCED` guard 防止重复加载

### 2.5 impl_verified 未使用 (双LLM复盘发现)
- [x] `engine/evolution/engine.sh` - 增强错误检查
- [x] 检查 `== "false" || == ERROR:*`
- [x] 添加成功日志 `✓ Implementation verified`

### 2.6 LEAN_TO_STANDARD 未定义 (双LLM复盘发现)
- [x] `eval/lib/unified_scoring.sh` - 正确定义并导出
- [x] 添加 `LEAN_TIER_*_NORM` 常量

### 2.7 评分阈值文档不一致 (双LLM复盘发现)
- [x] SKILL.md 更新为 1000分制 (PLATINUM≥950, GOLD≥900, SILVER≥800, BRONZE≥700)
- [x] 与 unified_scoring.sh 一致

---

## 三、P1 问题修复清单

### 3.1 macOS 专用 sed 语法
- [x] `engine/evolution/engine.sh` - `sed_i` 函数跨平台实现
- [x] 检测 Darwin/Linux 自动选择正确语法

### 3.2 Creator 退出码未检查
- [x] `engine/orchestrator/_workflow.sh` - 添加错误检查
- [x] `engine/agents/creator.sh` - 错误传播

### 3.3 MRR 计算错误
- [x] `eval/analyzer/trigger_analyzer.sh` - 修复 MRR 计算
- [x] 未命中查询正确处理为 0

### 3.4 CWE 检测不完整
- [x] OWASP AST10 重命名为 CWE-based Security
- [x] `engine/agents/security.sh` - 更新文档

### 3.5 快照格式不一致
- [x] `engine/evolution/rollback.sh` - 修复格式匹配
- [x] 统一使用 `.tar.gz` 格式

### 3.6 CREATE 模式单 LLM (双LLM复盘发现)
- [x] `engine/agents/creator.sh` - 实现双 LLM deliberation
- [x] 并行调用 kimi-code + minimax
- [x] 交叉验证逻辑：一致/分歧/单边成功

### 3.7 继承失败不传播错误
- [x] `engine/agents/creator.sh` - 添加错误传播
- [x] 父 skill 不存在时终止

### 3.8 stuck_count 误判
- [x] `engine/evolution/engine.sh` - 添加阈值判断
- [x] 小幅下降不再累加

### 3.9 HUMAN_REVIEW 不阻塞
- [x] `engine/evolution/engine.sh` - 修复确认逻辑
- [x] 阻塞直到收到确认

### 3.10 并发写入竞争
- [x] `scripts/parallel-evolution.sh` - 添加文件锁
- [x] `acquire_file_lock/release_file_lock`

---

## 四、P2 问题修复清单

### 4.1 apply_improvement rewrite
- [x] 使用 `replace_section_content()` 函数
- [x] 正确处理 section 替换

### 4.2 evaluator_generate_suggestions scale
- [x] 添加 normalization
- [x] 防止分数溢出

### 4.3 State management
- [x] 所有变量 `export`
- [x] `_STATE_SOURCED` guard

### 4.4 Module loading
- [x] 统一 `require()` 带 `agent:`/`evolution:` 前缀
- [x] 避免循环依赖

### 4.5 integration.sh cd
- [x] 保存 `original_dir`
- [x] 函数返回前恢复目录

### 4.6 Creator content
- [x] `replace_section_content()` 函数

### 4.7 Circular dependency
- [x] 所有模块添加 re-source guards

---

## 五、P3 改进实现清单

### 5.1 Lean vs Eval 架构明确定义
- [x] `lean-orchestrator.sh` 添加架构文档
- [x] 明确 Lean 用于快速预评估
- [x] 明确 Eval 用于最终认证

### 5.2 收敛判定算法
- [x] 创建 `engine/evolution/convergence.sh`
- [x] 3层检测: volatility, plateau, trend
- [x] `should_continue_evolution()` 函数

### 5.3 正向学习机制
- [x] `engine/evolution/learner.sh` v2.0
- [x] 新增 `strong_triggers`
- [x] 新增 `successful_tasks`

### 5.4 资源清理机制
- [x] 创建 `engine/evolution/resource_manager.sh`
- [x] 快照: 保留最近 N 个版本
- [x] Usage 文件: 保留最近 N 天
- [x] 日志: 保留最近 N 天 + 自动压缩

---

## 六、关键 Bug 修复清单

| Bug # | 描述 | 文件 | 修复 |
|-------|------|------|------|
| #1 | multi_llm_error_handling 括号错误 | security.sh | ✅ |
| #2 | float 比较使用字符串 | 多个文件 | ✅ |
| #3 | bc 返回 "1.0000" | 多个文件 | ✅ |
| #4 | sed -i '' macOS 专用 | engine.sh | ✅ |
| #5 | git commit 不检查变更 | engine.sh | ✅ |
| #6 | rollback_to_snapshot 格式不匹配 | rollback.sh | ✅ |
| #7 | jq $recommendations 未传递 | learner.sh | ✅ |
| #8 | hints=[] 无效语法 | engine.sh | ✅ |
| #9 | handle_error retry 解析错误 | errors.sh | ✅ |
| #10 | BRONZE 条件 >=800 | _workflow.sh | ✅ |
| #11 | with_lock trap 覆盖 | concurrency.sh | ✅ |
| #12 | cross_validate_issues 按位置比较 | 多个文件 | ✅ |
| #13 | parallel_execute eval 注入风险 | 多个文件 | ✅ |
| #14 | evolve_decider.sh 硬编码路径 | evolve_decider.sh | ✅ |

---

## 七、架构改进清单

### 7.1 统一评分系统
- [x] 创建 `eval/lib/unified_scoring.sh`
- [x] 1000 分制阈值 (PLATINUM≥950, GOLD≥900, SILVER≥800, BRONZE≥700)
- [x] 600 分制转换常量 (LEAN_TO_STANDARD=1.667)

### 7.2 模块化结构
- [x] `engine/lib/` - 核心库 (bootstrap, constants, errors, concurrency, integration)
- [x] `engine/orchestrator/` - 协调器模块 (_state, _workflow, _actions, _parallel)
- [x] `engine/agents/` - Agent 模块 (creator, evaluator, restorer, security)
- [x] `engine/evolution/` - 进化模块 (engine, learner, rollback, convergence, resource_manager)

### 7.3 Re-source Guards
- [x] `_BOOTSTRAP_SOURCED`
- [x] `_CONSTANTS_SOURCED`
- [x] `_AGENT_EXECUTOR_SOURCED`
- [x] `_STATE_SOURCED`

### 7.4 错误处理
- [x] `handle_error()` 函数带 retry
- [x] `with_lock()` 文件锁
- [x] 错误日志记录

---

## 八、新增功能清单

| 文件 | 功能 | 用途 |
|------|------|------|
| `eval/lib/unified_scoring.sh` | 统一评分常量 | 消除评分歧义 |
| `eval/lib/agent_executor.sh` | Agent 执行器 | 多 LLM 调用 |
| `engine/evolution/convergence.sh` | 收敛检测 | 判断进化是否完成 |
| `engine/evolution/resource_manager.sh` | 资源清理 | TTL 自动清理 |
| `engine/evolution/learner.sh` v2.0 | 正向学习 | 记录成功模式 |
| `scripts/sync_version.sh` | 版本同步 | manifest.json 同步 |
| `scripts/lean-orchestrator.sh` | Lean 评估 | ~0秒快速评估 |
| `scripts/parallel-evolution.sh` | 并行进化 | 多 worker 并行 |
| `tests/test_business_logic.sh` | 业务测试 | 快速验证 |

---

## 九、测试验证清单

### 9.1 单元测试
- [x] `tests/test_business_logic.sh` - 8/8 通过
- [x] trigger_analyzer F1 计算
- [x] parse_validate.sh 语法检查
- [x] unified_scoring.sh 阈值
- [x] sed_i 跨平台
- [x] re-source guards

### 9.2 集成测试
- [x] `./eval/main.sh --skill ./SKILL.md --fast --no-agent`
- [x] 得分: 777/1000 BRONZE

### 9.3 回归测试
- [x] 所有 P0/P1/P2 修复无回归

---

## 十、文档更新清单

| 文档 | 更新内容 |
|------|----------|
| `SKILL.md` | 1000分制阈值、Google 5 Patterns、CWE-based Security |
| `docs/CRITICAL_ISSUES.md` | 所有问题状态更新为已修复 |
| `engine/evolution/engine.sh` | 架构注释、9步循环注释 |
| `scripts/lean-orchestrator.sh` | Lean vs Eval 架构文档 |
| `eval/lib/unified_scoring.sh` | 评分常量注释 |

---

## 十一、Git 提交记录

```
204b76b fix: cross-LLM review fixes (2026-03-29)
eb61a4e docs: mark P3 improvements as completed
fc2cbc7 feat: add P3 improvements - convergence detection, resource cleanup, positive learning
65dcde9 docs: update CRITICAL_ISSUES.md - all P0/P1/P2 issues fixed
0df51d8 docs: add CRITICAL_ISSUES.md documenting all fixed issues
973fea3 fix(parse_validate): add || true to grep pipelines
def6c54 feat: improve skill quality - score 580→590
6198ab6 fix: rewrite parallel-evolution with fast lean-based evaluation
```

---

## 十二、待观察项 (非阻塞)

| 项 | 描述 | 建议 |
|----|------|------|
| 1 | Lean Runtime max=50 vs Eval Runtime max=450 | 明确两者比例关系 |
| 2 | 无长期收敛检测 | 可添加分数波动平滑检测 |
| 3 | strong_triggers 尚未积累数据 | 需要运行一段时间后验证 |
| 4 | resource_manager TTL 未验证 | 需要实际运行验证清理效果 |

---

## 十三、签字确认

- [x] 所有 P0 问题已修复
- [x] 所有 P1 问题已修复
- [x] 所有 P2 问题已修复
- [x] 所有 P3 改进已实现
- [x] 所有关键 Bug 已修复
- [x] 业务逻辑测试通过
- [x] 集成测试通过 (777/1000 BRONZE)
- [x] 文档已更新
- [x] 代码已推送

**项目状态**: ✅ 重构完成，可进入下一阶段
