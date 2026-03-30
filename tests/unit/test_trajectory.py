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

    def test_end_collection_invalid_session_id(self):
        collector = TrajectoryCollector()
        with pytest.raises(ValueError):
            collector.end_collection("invalid-session-id", "success")

    def test_record_action_invalid_session_id(self):
        collector = TrajectoryCollector()
        with pytest.raises(ValueError):
            collector.record_action("invalid-session-id", {"step": 1})

    def test_multiple_concurrent_sessions(self):
        collector = TrajectoryCollector()
        sid1 = collector.start_collection("CREATE", {"task": "test1"})
        sid2 = collector.start_collection("UPDATE", {"task": "test2"})
        collector.record_action(sid1, {"step": 1})
        collector.record_action(sid2, {"step": 1})
        collector.record_action(sid2, {"step": 2})
        entry1 = collector.end_collection(sid1, "success")
        entry2 = collector.end_collection(sid2, "success")
        assert len(entry1.actions) == 1
        assert len(entry2.actions) == 2
        assert len(collector.get_completed()) == 2
