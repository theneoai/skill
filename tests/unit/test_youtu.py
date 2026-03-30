import pytest
import time
from skill.agents.youtu import YoutuAgent
from skill.agents.evolution_memory import EvolutionMemory, MemoryEntry


class TestYoutuAgent:
    def test_init(self):
        memory = EvolutionMemory()
        agent = YoutuAgent(memory=memory)
        assert agent.memory is memory
        assert agent.exploration_rate == 0.1

    def test_practice_mode(self):
        memory = EvolutionMemory()
        memory.add(
            MemoryEntry(
                time.time(), "CREATE", [{"action": "step1"}], "success", 1.0, []
            )
        )
        agent = YoutuAgent(memory=memory)

        action = agent.practice("CREATE", {"task_type": "CREATE"})
        assert action.action_type == "practice"
        assert action.confidence > 0.5
