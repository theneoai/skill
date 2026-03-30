"""Base Agent infrastructure for skill framework."""

from __future__ import annotations

import json
import os
import tempfile
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Optional

PROMPT_DIR = Path(__file__).parent.parent / "prompts"

# Environment variable names for configuration
_ENV_API_KEY = "SKILL_API_KEY"
_ENV_OPENAI_API_KEY = "OPENAI_API_KEY"
_ENV_BASE_URL = "SKILL_API_BASE_URL"
_ENV_OPENAI_BASE_URL = "OPENAI_BASE_URL"
_ENV_MODEL = "SKILL_MODEL"
_ENV_OPENAI_MODEL = "OPENAI_MODEL"
_DEFAULT_BASE_URL = "https://api.openai.com"
_DEFAULT_MODEL = "gpt-4o-mini"
_REQUEST_TIMEOUT = 30  # seconds
_MAX_RETRIES = 3

# Provider → default model mapping
_PROVIDER_MODELS: dict[str, str] = {
    "kimi": "moonshot-v1-8k",
    "minimax": "abab6.5s-chat",
    "openai": "gpt-4o-mini",
    "anthropic": "claude-haiku-4-5-20251001",
}


@dataclass
class AgentConfig:
    """Configuration for agent behavior."""

    model: str = "auto"
    provider: str = "auto"


class AgentBase:
    """Base class for all agents providing common infrastructure."""

    def __init__(self, config: Optional[AgentConfig] = None) -> None:
        """Initialize agent with configuration.

        Args:
            config: Optional agent configuration. Uses defaults if not provided.
        """
        self.config = config or AgentConfig()


def get_prompt_path(prompt_name: str) -> Path:
    """Get the file path for a prompt.

    Args:
        prompt_name: Name of the prompt file without extension.

    Returns:
        Path to the prompt file.
    """
    return PROMPT_DIR / f"{prompt_name}.txt"


def load_prompt(prompt_name: str) -> str:
    """Load a prompt template by name.

    Args:
        prompt_name: Name of the prompt to load.

    Returns:
        The prompt content as a string.
    """
    prompt_path = get_prompt_path(prompt_name)
    if prompt_path.exists():
        return prompt_path.read_text()
    return ""


def _resolve_model(model: str, provider: str) -> str:
    """Resolve the effective model name from model/provider hints and env vars."""
    if model not in ("auto", ""):
        return model
    env_model = os.environ.get(_ENV_MODEL) or os.environ.get(_ENV_OPENAI_MODEL)
    if env_model:
        return env_model
    if provider not in ("auto", "") and provider in _PROVIDER_MODELS:
        return _PROVIDER_MODELS[provider]
    return _DEFAULT_MODEL


def get_llm_response(system_prompt: str, user_prompt: str, model: str, provider: str) -> dict:
    """Get response from LLM via an OpenAI-compatible chat completions endpoint.

    Configuration via environment variables:
      SKILL_API_KEY / OPENAI_API_KEY   — API key (required)
      SKILL_API_BASE_URL / OPENAI_BASE_URL — base URL (default: https://api.openai.com)
      SKILL_MODEL / OPENAI_MODEL       — model override

    Args:
        system_prompt: System prompt for the LLM.
        user_prompt: User prompt for the LLM.
        model: Model name, or ``"auto"`` to resolve from env/provider.
        provider: Provider hint (``"openai"``, ``"kimi"``, ``"minimax"``, …).

    Returns:
        ``{"status": "success", "content": str}`` on success,
        ``{"status": "error", "content": "", "error": str}`` on failure.
    """
    api_key = os.environ.get(_ENV_API_KEY) or os.environ.get(_ENV_OPENAI_API_KEY, "")
    if not api_key:
        return {
            "status": "error",
            "content": "",
            "error": (
                f"No API key configured. Set {_ENV_API_KEY} or {_ENV_OPENAI_API_KEY}."
            ),
        }

    base_url = (
        os.environ.get(_ENV_BASE_URL)
        or os.environ.get(_ENV_OPENAI_BASE_URL)
        or _DEFAULT_BASE_URL
    ).rstrip("/")
    endpoint = f"{base_url}/v1/chat/completions"
    resolved_model = _resolve_model(model, provider)

    payload = json.dumps(
        {
            "model": resolved_model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            "temperature": 0.7,
            "max_tokens": 4096,
        }
    ).encode("utf-8")

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }

    for attempt in range(_MAX_RETRIES):
        try:
            req = urllib.request.Request(
                endpoint, data=payload, headers=headers, method="POST"
            )
            with urllib.request.urlopen(req, timeout=_REQUEST_TIMEOUT) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                content: str = data["choices"][0]["message"]["content"]
                return {"status": "success", "content": content}

        except urllib.error.HTTPError as exc:
            # Retry on transient server/rate-limit errors
            if exc.code in (429, 500, 502, 503, 504) and attempt < _MAX_RETRIES - 1:
                time.sleep(2 ** attempt)
                continue
            body = exc.read().decode("utf-8", errors="replace")
            return {
                "status": "error",
                "content": "",
                "error": f"HTTP {exc.code}: {body}",
            }

        except (urllib.error.URLError, TimeoutError, OSError) as exc:
            if attempt < _MAX_RETRIES - 1:
                time.sleep(2 ** attempt)
                continue
            return {"status": "error", "content": "", "error": str(exc)}

        except (KeyError, IndexError, json.JSONDecodeError) as exc:
            return {"status": "error", "content": "", "error": f"Parse error: {exc}"}

    return {"status": "error", "content": "", "error": "Max retries exceeded"}


def call_llm(
    system_prompt: str, user_prompt: str, model: str = "auto", provider: str = "auto"
) -> dict:
    """Call LLM and return response.

    Args:
        system_prompt: System prompt.
        user_prompt: User prompt.
        model: Model to use (default: auto).
        provider: Provider to use (default: auto).

    Returns:
        Dictionary with status and content.
    """
    return get_llm_response(system_prompt, user_prompt, model, provider)


def call_llm_json(
    system_prompt: str, user_prompt: str, model: str = "auto", provider: str = "auto"
) -> dict:
    """Call LLM and parse JSON response.

    Args:
        system_prompt: System prompt.
        user_prompt: User prompt.
        model: Model to use.
        provider: Provider to use.

    Returns:
        Parsed JSON as dictionary.
    """
    response = call_llm(system_prompt, user_prompt, model, provider)
    if response.get("status") == "success" and response.get("content"):
        try:
            return json.loads(response["content"])
        except json.JSONDecodeError:
            return {}
    return {}


def parse_json(json_str: str, key: str) -> str:
    """Parse JSON string and extract value by key.

    Args:
        json_str: JSON string to parse.
        key: Key to extract.

    Returns:
        Value for key or empty string if not found.
    """
    try:
        data = json.loads(json_str)
        return str(data.get(key, ""))
    except (json.JSONDecodeError, TypeError):
        return ""


def validate_json(json_str: str) -> bool:
    """Validate if string is valid JSON.

    Args:
        json_str: String to validate.

    Returns:
        True if valid JSON, False otherwise.
    """
    try:
        json.loads(json_str)
        return True
    except (json.JSONDecodeError, TypeError):
        return False


def temp_file() -> str:
    """Create a temporary file for agent use.

    Returns:
        Path to the created temporary file.
    """
    fd, path = tempfile.mkstemp(suffix=".json")
    os.close(fd)
    return path


def agent_init() -> None:
    """Initialize agent infrastructure."""
    pass
