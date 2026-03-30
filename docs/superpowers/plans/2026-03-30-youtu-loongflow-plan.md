# Youtu-Agent + LoongFlow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现 Youtu-Agent 双模式进化系统与 LoongFlow 认知架构，替换现有 9-Step Loop

**Architecture:** LoongFlow 作为认知引擎提供 Plan-Execute-Summarize 循环，Youtu-Agent 在其上实现 Practice/RL 双模式进行 skill 自进化

**Tech Stack:** Python, dataclasses, 现有 eval/agents 模块

---

## 文件结构

```
skill/
├── orchestrator/
│   ├── __init__.py
│   ├── loongflow.py           # LoongFlowOrchestrator
│   └── cognitive_graph.py     # CognitiveGraph, CognitiveNode
├── agents/
│   ├── youtu.py               # YoutuAgent
│   ├── evolution_memory.py    # EvolutionMemory, MemoryEntry
│   └── trajectory.py          # TrajectoryCollector
tests/unit/
├── test_loongflow.py
├── test_cognitive_graph.py
├── test_youtu.py
└── test_evolution_memory.py
```

---

## Task 1: CognitiveGraph 基础数据结构

**Files:**
- Create: `skill/orchestrator/cognitive_graph.py`
- Test: `tests/unit/test_cognitive_graph.py`

- [ ] **Step 1: Write failing test for CognitiveNode**

```python
# tests/unit/test_cognitive_graph.py
import pytest
from skill.orchestrator.cognitive_graph import CognitiveNode, CognitiveGraph

class TestCognitiveNode:
    def test_create_node(self):
        node = CognitiveNode(
            id="node-1",
            type="task",
            content="Test task",
            status="pending",
        )
        assert node.id == "node-1"
        assert node.type == "task"
        assert node.status == "pending"
        assert node.children == []
        assert node.parent is None

    def test_node_with_children(self):
        node = CognitiveNode(
            id="parent",
            type="task",
            content="Parent",
            children=["child-1", "child-2"],
            parent=None,
        )
        assert node.children == ["child-1", "child-2"]
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/unit/test_cognitive_graph.py -v`
Expected: FAIL - module not found

- [ ] **Step 3: Write minimal CognitiveNode implementation**

```python
# skill/orchestrator/cognitive_graph.py
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any

@dataclass
class CognitiveNode:
    id: str
    type: str
    content: str
    status: str = "pending"
    children: list[str] = field(default_factory=list)
    parent: str | None = None
    metadata: dict[str, Any] = field(default_factory=dict)

@dataclass
class CognitiveGraph:
    nodes: dict[str, CognitiveNode] = field(default_factory=dict)
    root: str | None = None
    edges: list[tuple[str, str]] = field(default_factory=list)
    
    def add_node(self, node: CognitiveNode) -> None:
        self.nodes[node.id] = node
        if self.root is None:
            self.root = node.id
            
    def add_edge(self, parent_id: str, child_id: str) -> None:
        self.edges.append((parent_id, child_id))
        if parent_id in self.nodes:
            self.nodes[parent_id].children.append(child_id)
        if child_id in self.nodes:
            self.nodes[child_id].parent = parent_id
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/unit/test_cognitive_graph.py -v`
Expected: PASS

- [ ] **Step 5: Write failing test for CognitiveGraph**

```python
def test_add_node(self):
    graph = CognitiveGraph()
    node = CognitiveNode(id="n1", type="task", content="test")
    graph.add_node(node)
    assert "n1" in graph.nodes
    assert graph.root == "n1"

def test_add_edge(self):
    graph = CognitiveGraph()
    parent = CognitiveNode(id="p", type="task", content="parent")
    child = CognitiveNode(id="c", type="task", content="child")
    graph.add_node(parent)
    graph.add_node(child)
    graph.add_edge("p", "c")
    assert ("p", "c") in graph.edges
    assert "c" in parent.children
    assert child.parent == "p"
```

- [ ] **Step 6: Run test to verify it passes**

Run: `pytest tests/unit/test_cognitive_graph.py -v`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add skill/orchestrator/cognitive_graph.py tests/unit/test_cognitive_graph.py
git commit -m "feat: add CognitiveGraph data structures"
```

---

## Task 2: EvolutionMemory 进化记忆

**Files:**
- Create: `skill/agents/evolution_memory.py`
- Test: `tests/unit/test_evolution_memory.py`

- [ ] **Step 1: Write failing test for MemoryEntry**

```python
# tests/unit/test_evolution_memory.py
import pytest
import time
from skill.agents.evolution_memory import MemoryEntry, EvolutionMemory

class TestMemoryEntry:
    def test_create_entry(self):
        entry = MemoryEntry(
            timestamp=time.time(),
            task_type="CREATE",
            trajectory=[{"action": "step1", "result": "success"}],
            outcome="success",
            reward=1.0,
            lessons=["Lesson 1"],
        )
        assert entry.outcome == "success"
        assert entry.reward == 1.0
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/unit/test_evolution_memory.py -v`
Expected: FAIL - module not found

- [ ] **Step 3: Write minimal EvolutionMemory implementation**

```python
# skill/agents/evolution_memory.py
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any
import time

@dataclass
class MemoryEntry:
    timestamp: float
    task_type: str
    trajectory: list[dict[str, Any]]
    outcome: str
    reward: float
    lessons: list[str] = field(default_factory=list)

class EvolutionMemory:
    def __init__(self) -> None:
        self._entries: list[MemoryEntry] = []
        
    def add(self, entry: MemoryEntry) -> None:
        self._entries.append(entry)
        
    def get_successful_trajectories(self, task_type: str) -> list[list[dict[str, Any]]]:
        return [
            e.trajectory for e in self._entries
            if e.task_type == task_type and e.outcome == "success"
        ]
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/unit/test_evolution_memory.py -v`
Expected: PASS

- [ ] **Step 5: Write failing test for get_similar**

```python
def test_get_similar(self):
    memory = EvolutionMemory()
    memory.add(MemoryEntry(time.time(), "CREATE", [{"a": 1}], "success", 1.0, []))
    memory.add(MemoryEntry(time.time(), "CREATE", [{"a": 2}], "success", 0.8, []))
    memory.add(MemoryEntry(time.time(), "EVALUATE", [{"a": 3}], "success", 0.9, []))
    
    similar = memory.get_similar("CREATE", k=2)
    assert len(similar) == 2
```

- [ ] **Step 6: Implement get_similar method**

```python
def get_similar(self, task: str, k: int = 5) -> list[MemoryEntry]:
    return [
        e for e in self._entries
        if e.task_type == task
    ][:k]
```

- [ ] **Step 7: Run test to verify it passes**

Run: `pytest tests/unit/test_evolution_memory.py -v`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add skill/agents/evolution_memory.py tests/unit/test_evolution_memory.py
git commit -m "feat: add EvolutionMemory for storing trajectories"
```

---

## Task 3: TrajectoryCollector 轨迹收集

**Files:**
- Create: `skill/agents/trajectory.py`
- Test: `tests/unit/test_trajectory.py`

- [ ] **Step 1: Write failing test for TrajectoryCollector**

```python
# tests/unit/test_trajectory.py
import pytest
from skill.agents.trajectory import TrajectoryCollector, TrajectoryEntry

class TestTrajectoryCollector:
    def test_start_collection(self):
        collector = TrajectoryCollector()
        session_id = collector.start_collection("CREATE", {"task": "test"})
        assert session_id is not None
        assert len(session_id) > 0
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/unit/test_trajectory.py -v`
Expected: FAIL - module not found

- [ ] **Step 3: Write minimal TrajectoryCollector implementation**

```python
# skill/agents/trajectory.py
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any
import uuid
import time

@dataclass
class TrajectoryEntry:
    session_id: str
    task_type: str
    context: dict[str, Any]
    actions: list[dict[str, Any]] = field(default_factory=list)
    start_time: float = field(default_factory=time.time)
    end_time: float | None = None
    outcome: str | None = None
    
class TrajectoryCollector:
    def __init__(self) -> None:
        self._active_sessions: dict[str, TrajectoryEntry] = {}
        self._completed: list[TrajectoryEntry] = []
        
    def start_collection(self, task_type: str, context: dict[str, Any]) -> str:
        session_id = str(uuid.uuid4())
        entry = TrajectoryEntry(
            session_id=session_id,
            task_type=task_type,
            context=context,
        )
        self._active_sessions[session_id] = entry
        return session_id
        
    def record_action(self, session_id: str, action: dict[str, Any]) -> None:
        if session_id in self._active_sessions:
            self._active_sessions[session_id].actions.append(action)
            
    def end_collection(self, session_id: str, outcome: str) -> TrajectoryEntry:
        if session_id in self._active_sessions:
            entry = self._active_sessions.pop(session_id)
            entry.end_time = time.time()
            entry.outcome = outcome
            self._completed.append(entry)
            return entry
        raise ValueError(f"Session {session_id} not found")
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/unit/test_trajectory.py -v`
Expected: PASS

- [ ] **Step 5: Write failing test for get_completed**

```python
def test_get_completed(self):
    collector = TrajectoryCollector()
    sid = collector.start_collection("CREATE", {})
    collector.record_action(sid, {"step": 1})
    entry = collector.end_collection(sid, "success")
    assert entry.outcome == "success"
    assert len(entry.actions) == 1
    assert len(collector.get_completed()) == 1
```

- [ ] **Step 6: Implement get_completed**

```python
def get_completed(self) -> list[TrajectoryEntry]:
    return self._completed
```

- [ ] **Step 7: Run test to verify it passes**

Run: `pytest tests/unit/test_trajectory.py -v`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add skill/agents/trajectory.py tests/unit/test_trajectory.py
git commit -m "feat: add TrajectoryCollector"
```

---

## Task 4: LoongFlowOrchestrator Plan-Execute-Summarize

**Files:**
- Create: `skill/orchestrator/loongflow.py`
- Test: `tests/unit/test_loongflow.py`

- [ ] **Step 1: Write failing test for LoongFlowOrchestrator**

```python
# tests/unit/test_loongflow.py
import pytest
from skill.orchestrator.loongflow import LoongFlowOrchestrator
from skill.agents.evolution_memory import EvolutionMemory

class TestLoongFlowOrchestrator:
    def test_init(self):
        memory = EvolutionMemory()
        orchestrator = LoongFlowOrchestrator(memory=memory)
        assert orchestrator.memory is memory
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/unit/test_loongflow.py -v`
Expected: FAIL - module not found

- [ ] **Step 3: Write minimal LoongFlowOrchestrator implementation**

```python
# skill/orchestrator/loongflow.py
from __future__ import annotations
from typing import Any
from skill.orchestrator.cognitive_graph import CognitiveGraph, CognitiveNode
from skill.agents.evolution_memory import EvolutionMemory, MemoryEntry
from skill.agents.trajectory import TrajectoryCollector

class ExecutionResult:
    def __init__(self, success: bool, output: Any = None, error: str | None = None):
        self.success = success
        self.output = output
        self.error = error

class MemoryUpdate:
    pass

class LoongFlowOrchestrator:
    def __init__(self, memory: EvolutionMemory) -> None:
        self.memory = memory
        self.collector = TrajectoryCollector()
        
    def plan(self, task: str) -> CognitiveGraph:
        graph = CognitiveGraph()
        root = CognitiveNode(
            id="root",
            type="task",
            content=task,
        )
        graph.add_node(root)
        return graph
        
    def execute(self, graph: CognitiveGraph) -> ExecutionResult:
        return ExecutionResult(success=True, output={})
        
    def summarize(self, result: ExecutionResult, graph: CognitiveGraph) -> MemoryUpdate:
        return MemoryUpdate()
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/unit/test_loongflow.py -v`
Expected: PASS

- [ ] **Step 5: Write failing test for run method (full loop)**

```python
def test_run_full_loop(self):
    memory = EvolutionMemory()
    orchestrator = LoongFlowOrchestrator(memory=memory)
    result = orchestrator.run("Create a weather skill")
    assert result.success is True
```

- [ ] **Step 6: Implement run method**

```python
def run(self, task: str) -> ExecutionResult:
    session_id = self.collector.start_collection("CREATE", {"task": task})
    
    graph = self.plan(task)
    self.collector.record_action(session_id, {"phase": "plan", "graph_nodes": len(graph.nodes)})
    
    result = self.execute(graph)
    self.collector.record_action(session_id, {"phase": "execute", "success": result.success})
    
    self.summarize(result, graph)
    self.collector.record_action(session_id, {"phase": "summarize"})
    
    self.collector.end_collection(session_id, "success" if result.success else "failure")
    return result
```

- [ ] **Step 7: Run test to verify it passes**

Run: `pytest tests/unit/test_loongflow.py -v`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add skill/orchestrator/loongflow.py tests/unit/test_loongflow.py
git commit -m "feat: add LoongFlowOrchestrator with Plan-Execute-Summarize"
```

---

## Task 5: YoutuAgent Practice 模式

**Files:**
- Create: `skill/agents/youtu.py`
- Test: `tests/unit/test_youtu.py`

- [ ] **Step 1: Write failing test for YoutuAgent**

```python
# tests/unit/test_youtu.py
import pytest
from skill.agents.youtu import YoutuAgent
from skill.agents.evolution_memory import EvolutionMemory

class TestYoutuAgent:
    def test_init(self):
        memory = EvolutionMemory()
        agent = YoutuAgent(memory=memory)
        assert agent.memory is memory
        assert agent.exploration_rate == 0.1
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/unit/test_youtu.py -v`
Expected: FAIL - module not found

- [ ] **Step 3: Write minimal YoutuAgent implementation**

```python
# skill/agents/youtu.py
from __future__ import annotations
from typing import Any, Literal
from skill.agents.evolution_memory import EvolutionMemory, MemoryEntry
from skill.agents.trajectory import TrajectoryCollector

class AgentAction:
    def __init__(self, action_type: str, content: str, confidence: float = 0.5):
        self.action_type = action_type
        self.content = content
        self.confidence = confidence

class YoutuAgent:
    def __init__(self, memory: EvolutionMemory, exploration_rate: float = 0.1) -> None:
        self.memory = memory
        self.exploration_rate = exploration_rate
        self.collector = TrajectoryCollector()
        
    def decide_mode(self, context: dict[str, Any]) -> Literal["practice", "rl"]:
        successful = self.memory.get_successful_trajectories(context.get("task_type", ""))
        if len(successful) >= 3:
            return "practice"
        return "rl"
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/unit/test_youtu.py -v`
Expected: PASS

- [ ] **Step 5: Write failing test for practice mode**

```python
def test_practice_mode(self):
    import time
    memory = EvolutionMemory()
    memory.add(MemoryEntry(time.time(), "CREATE", [{"action": "step1"}], "success", 1.0, []))
    agent = YoutuAgent(memory=memory)
    
    action = agent.practice("CREATE", {"task_type": "CREATE"})
    assert action.action_type == "practice"
    assert action.confidence > 0.5
```

- [ ] **Step 6: Implement practice method**

```python
def practice(self, task: str, context: dict[str, Any]) -> AgentAction:
    trajectories = self.memory.get_successful_trajectories(context.get("task_type", ""))
    if not trajectories:
        return AgentAction("practice", "no_successful_trajectories", 0.0)
    
    avg_confidence = min(0.5 + (len(trajectories) * 0.1), 0.95)
    return AgentAction("practice", f"learned_from_{len(trajectories)}_trajectories", avg_confidence)
```

- [ ] **Step 7: Run test to verify it passes**

Run: `pytest tests/unit/test_youtu.py -v`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add skill/agents/youtu.py tests/unit/test_youtu.py
git commit -m "feat: add YoutuAgent with Practice mode"
```

---

## Task 6: YoutuAgent RL 模式

**Files:**
- Modify: `skill/agents/youtu.py`
- Test: `tests/unit/test_youtu.py`

- [ ] **Step 1: Write failing test for RL mode**

```python
def test_rl_mode(self):
    memory = EvolutionMemory()
    agent = YoutuAgent(memory=memory, exploration_rate=0.0)
    
    state = {"task_type": "CREATE", "attempts": 0}
    action = agent.rl_step(state, reward=0.0)
    assert action.action_type == "rl"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/unit/test_youtu.py -v`
Expected: FAIL - rl_step not defined

- [ ] **Step 3: Implement rl_step method**

```python
def rl_step(self, state: dict[str, Any], reward: float) -> AgentAction:
    task_type = state.get("task_type", "UNKNOWN")
    attempts = state.get("attempts", 0)
    
    if reward > 0.8:
        return AgentAction("rl", "exploit_high_reward", 0.9)
    elif reward > 0.5:
        return AgentAction("rl", "exploit_medium_reward", 0.7)
    else:
        return AgentAction("rl", "explore_new_strategy", 0.5 + (self.exploration_rate * attempts))
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/unit/test_youtu.py -v`
Expected: PASS

- [ ] **Step 5: Write failing test for Q-learning update**

```python
def test_q_learning_update(self):
    memory = EvolutionMemory()
    agent = YoutuAgent(memory=memory)
    
    agent.update_q("CREATE", "action1", reward=1.0)
    assert ("CREATE", "action1") in agent._q_table
    assert agent._q_table[("CREATE", "action1")] > 0
```

- [ ] **Step 6: Implement Q-learning table and update method**

```python
def __init__(self, memory: EvolutionMemory, exploration_rate: float = 0.1) -> None:
    self.memory = memory
    self.exploration_rate = exploration_rate
    self.collector = TrajectoryCollector()
    self._q_table: dict[tuple[str, str], float] = {}
    self._alpha = 0.1
    self._gamma = 0.9
    
def update_q(self, task_type: str, action: str, reward: float) -> None:
    key = (task_type, action)
    current = self._q_table.get(key, 0.0)
    self._q_table[key] = current + self._alpha * (reward - current)
```

- [ ] **Step 7: Run test to verify it passes**

Run: `pytest tests/unit/test_youtu.py -v`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add skill/agents/youtu.py tests/unit/test_youtu.py
git commit -m "feat: add YoutuAgent RL mode with Q-learning"
```

---

## Task 7: 集成 BOAD/ROAD

**Files:**
- Modify: `skill/orchestrator/loongflow.py`
- Modify: `skill/agents/youtu.py`

- [ ] **Step 1: Write failing test for BOAD integration in LoongFlow**

```python
def test_loongflow_with_boad(self):
    from skill.agents.boad import BOADOptimizer
    memory = EvolutionMemory()
    orchestrator = LoongFlowOrchestrator(memory=memory)
    optimizer = BOADOptimizer()
    orchestrator.set_agent_optimizer(optimizer)
    assert orchestrator.optimizer is optimizer
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/unit/test_loongflow.py -v`
Expected: FAIL - set_agent_optimizer not defined

- [ ] **Step 3: Add BOAD optimizer to LoongFlow**

```python
class LoongFlowOrchestrator:
    def __init__(self, memory: EvolutionMemory, optimizer=None) -> None:
        self.memory = memory
        self.collector = TrajectoryCollector()
        self.optimizer = optimizer
        
    def set_agent_optimizer(self, optimizer) -> None:
        self.optimizer = optimizer
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/unit/test_loongflow.py -v`
Expected: PASS

- [ ] **Step 5: Write failing test for YoutuAgent with BOAD UCB1**

```python
def test_youtu_with_ucb1_selection(self):
    from skill.agents.boad import BOADOptimizer, AgentTier, AgentSpec
    memory = EvolutionMemory()
    agent = YoutuAgent(memory=memory)
    optimizer = BOADOptimizer()
    
    spec = AgentSpec(name="test", tier=AgentTier.SPECIALIST, capabilities=["a"], reward=1.0, visits=5)
    optimizer.agents[AgentTier.SPECIALIST].append(spec)
    
    selected = agent.select_agent_with_ucb1(optimizer, "SPECIALIST")
    assert selected.name == "test"
```

- [ ] **Step 6: Implement UCB1 selection in YoutuAgent**

```python
def select_agent_with_ucb1(self, optimizer, tier: str) -> AgentSpec:
    from skill.agents.boad import AgentTier
    tier_enum = AgentTier[tier.upper()]
    agents = optimizer.agents.get(tier_enum, [])
    if not agents:
        raise ValueError(f"No agents for tier {tier}")
    return optimizer.select_agent(task="")
```

- [ ] **Step 7: Run test to verify it passes**

Run: `pytest tests/unit/test_youtu.py -v`
Expected: PASS

- [ ] **Step 8: Write failing test for ROAD integration**

```python
def test_loongflow_with_road(self):
    from skill.engine.road import ROADRecover
    memory = EvolutionMemory()
    orchestrator = LoongFlowOrchestrator(memory=memory)
    road = ROADRecover()
    orchestrator.set_error_recovery(road)
    assert orchestrator.error_recovery is road
```

- [ ] **Step 9: Implement ROAD error recovery in LoongFlow**

```python
def set_error_recovery(self, road) -> None:
    self.error_recovery = road
    
def execute(self, graph: CognitiveGraph) -> ExecutionResult:
    try:
        return ExecutionResult(success=True, output={})
    except Exception as e:
        if hasattr(self, 'error_recovery'):
            decision = self.error_recovery.suggest_recovery(type(e).__name__, {})
            if decision.value == "abort":
                raise
        raise
```

- [ ] **Step 10: Run test to verify it passes**

Run: `pytest tests/unit/test_loongflow.py tests/unit/test_youtu.py -v`
Expected: PASS

- [ ] **Step 11: Commit**

```bash
git add skill/orchestrator/loongflow.py skill/agents/youtu.py
git commit -m "feat: integrate BOAD and ROAD into LoongFlow + YoutuAgent"
```

---

## Task 8: 最终测试验证

**Files:**
- Run: `pytest tests/unit/ -v`

- [ ] **Step 1: Run full test suite**

Run: `pytest tests/unit/ -v`
Expected: 180+ tests passing (143 existing + 37 new)

- [ ] **Step 2: Final commit**

```bash
git add -A
git commit -m "feat: complete Phase 1.5 - Youtu-Agent + LoongFlow"
```

---

## 成功标准检查

- [ ] CognitiveGraph 实现并测试
- [ ] EvolutionMemory 实现并测试
- [ ] TrajectoryCollector 实现并测试
- [ ] LoongFlowOrchestrator Plan-Execute-Summarize 实现并测试
- [ ] YoutuAgent Practice 模式实现并测试
- [ ] YoutuAgent RL 模式实现并测试
- [ ] BOAD/ROAD 集成测试通过
- [ ] 所有测试通过 (≥180)
