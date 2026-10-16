#!/usr/bin/env python3
"""Read-only semantic search fallback for the original Recorder index."""

from __future__ import annotations

import argparse
import json
import os
import signal
import subprocess
import sys
import time
from pathlib import Path


DEFAULT_MEMORY_DB = Path(r"D:\works\AGrav\20_Проекты\MemoryDB")


def _memory_server_pids(project: Path) -> list[int]:
    """Return only Python processes running this project's MCP main.py."""
    if os.name != "nt":
        return []
    command = (
        "[Console]::OutputEncoding=[Text.UTF8Encoding]::new(); "
        "@(Get-CimInstance Win32_Process | "
        "Where-Object {$_.Name -eq 'python.exe'} | "
        "Select-Object ProcessId,CommandLine) | ConvertTo-Json -Compress"
    )
    completed = subprocess.run(
        ["powershell.exe", "-NoProfile", "-Command", command],
        capture_output=True, text=True, encoding="utf-8", timeout=10,
        check=False)
    if completed.returncode != 0 or not completed.stdout.strip():
        return []
    data = json.loads(completed.stdout)
    rows = data if isinstance(data, list) else [data]
    server_path = str((project / "src" / "main.py").resolve()).casefold()
    result = []
    for row in rows:
        command_line = str(row.get("CommandLine") or "").casefold()
        if server_path in command_line:
            result.append(int(row["ProcessId"]))
    return result


def _take_over_memory_server(project: Path) -> list[int]:
    """Stop verified stale MemoryDB MCP owners and wait for Qdrant unlock."""
    stopped = []
    for pid in _memory_server_pids(project):
        if pid == os.getpid():
            continue
        os.kill(pid, signal.SIGTERM)
        stopped.append(pid)
    deadline = time.monotonic() + 5.0
    while stopped and time.monotonic() < deadline:
        if not any(pid in _memory_server_pids(project) for pid in stopped):
            break
        time.sleep(0.1)
    return stopped


def _run_query(project: Path, args: argparse.Namespace) -> int:
    from src.database import MemoryDatabase

    db = MemoryDatabase()
    indexed = db.get_all_indexed_source_ids("original-recorder")
    if args.health:
        print(json.dumps({"ok": True, "indexed_files": len(indexed),
                          "project": str(project)}, ensure_ascii=False))
        return 0
    if not args.query:
        raise ValueError("query is required unless --health is used")
    results = db.search_source_code(
        query=args.query,
        limit=max(1, min(args.limit, 50)),
        project_context="original-recorder",
        source_kind="original-recorder",
    )
    print(json.dumps(results, ensure_ascii=False, indent=2))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("query", nargs="?", help="semantic source-code query")
    parser.add_argument("--limit", type=int, default=8)
    parser.add_argument("--health", action="store_true")
    parser.add_argument(
        "--takeover", action="store_true",
        help="stop another verified MemoryDB MCP process and retry")
    args = parser.parse_args()

    project = Path(os.environ.get("MEMORYDB_PROJECT", DEFAULT_MEMORY_DB))
    if not project.is_dir():
        print(json.dumps({"ok": False, "error": f"MemoryDB not found: {project}"},
                         ensure_ascii=False))
        return 2
    sys.path.insert(0, str(project))

    try:
        return _run_query(project, args)
    except PermissionError as exc:
        # Local Qdrant creates a service .lock even for read-only queries. In a
        # workspace sandbox, opening an index outside writable roots therefore
        # fails with EACCES although the database itself is healthy and idle.
        print(json.dumps({
            "ok": False,
            "error": str(exc),
            "reason": "sandbox_write_denied",
            "hint": (
                "Retry this helper with sandbox escalation. Local Qdrant must "
                "create its .lock file in the MemoryDB data directory."
            ),
        }, ensure_ascii=False))
        return 3
    except Exception as exc:  # CLI must provide a useful fallback diagnostic.
        if args.takeover and "already accessed by another instance" in str(exc):
            stopped = _take_over_memory_server(project)
            if not stopped:
                print(json.dumps({
                    "ok": False,
                    "error": str(exc),
                    "reason": "owner_not_verified",
                    "hint": "No verified MemoryDB src/main.py process was stopped.",
                }, ensure_ascii=False))
                return 4
            try:
                return _run_query(project, args)
            except Exception as retry_exc:
                print(json.dumps({
                    "ok": False,
                    "error": str(retry_exc),
                    "stopped_pids": stopped,
                }, ensure_ascii=False))
                return 1
        print(json.dumps({"ok": False, "error": str(exc)}, ensure_ascii=False))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
