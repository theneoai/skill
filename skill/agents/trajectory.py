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

    def get_completed(self) -> list[TrajectoryEntry]:
        return self._completed
