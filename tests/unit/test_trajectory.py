import pytest
from skill.agents.trajectory import TrajectoryCollector, TrajectoryEntry


class TestTrajectoryCollector:
    def test_start_collection(self):
        collector = TrajectoryCollector()
        session_id = collector.start_collection("CREATE", {"task": "test"})
        assert session_id is not None
        assert len(session_id) > 0

    def test_get_completed(self):
        collector = TrajectoryCollector()
        sid = collector.start_collection("CREATE", {})
        collector.record_action(sid, {"step": 1})
        entry = collector.end_collection(sid, "success")
        assert entry.outcome == "success"
        assert len(entry.actions) == 1
        assert len(collector.get_completed()) == 1
