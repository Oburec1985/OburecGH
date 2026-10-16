---
name: memorydb
description: Work with the local MemoryDB semantic memory and its MCP tools. Use when Codex needs to save, list, search, or delete durable development facts; semantically search or synchronize the AGrav Obsidian vault; search or index original Recorder sources; diagnose the local_memory_db MCP server; or when the user mentions MemoryDB, project memory, Qdrant memory, search_vault_notes, or search_original_recorder_sources.
---

# MemoryDB

Use the stdio MCP server `local_memory_db` as the preferred interface. Search the active tool list before attempting a CLI fallback, and do not start a second server when its tools are already present.

## Tool selection

- Use `search_memory_facts` for durable decisions, rules, and previously confirmed project facts.
- Use `list_memory_facts` to inspect recent records.
- Use `save_memory_fact` only for concise, durable, verified knowledge. Include useful tags and `project_context`; include `source_file` when evidence comes from a file.
- Use `delete_memory_fact` only when the user explicitly requests deletion and the UUID has been verified.
- Use `search_vault_notes` for semantic navigation across AGrav. Open the returned note and verify the relevant text before treating it as evidence.
- Use `sync_vault_notes` when the user requests synchronization or stale indexing is established. Prefer `dry_run: true` before a mutating synchronization.
- Use `search_original_recorder_sources` for semantic navigation in the read-only original Recorder sources. Open the returned absolute file and verify the cited range.
- Use `sync_original_recorder_sources` only to update the index. Prefer `dry_run: true` first and never modify the original source tree.

Keep semantic result limits small, normally 5-12. Use semantic search for navigation and `rg` for exact symbols, callers, constants, and completeness checks. Embeddings are not primary evidence.

## MCP registration

The expected Codex configuration is:

```toml
[mcp_servers.local_memory_db]
command = 'C:\Users\User\AppData\Local\Programs\Python\Python314\python.exe'
args = ['D:\LLMWorkplace\MemoryDB\src\main.py']
startup_timeout_sec = 120

[mcp_servers.local_memory_db.env]
PYTHONPATH = 'D:\LLMWorkplace\MemoryDB'
AGRAV_ROOT = 'D:\works\AGrav'
ORIGINAL_RECORDER_ROOT = 'D:\works\windev-v3.9'
```

The default MemoryDB project path is `D:\LLMWorkplace\MemoryDB`.

## Availability and fallback

At the start of work that depends on original Recorder semantic search:

1. Look for `search_original_recorder_sources` in the active tools.
2. If present, call it before an exact `rg` search.
3. If absent, run the read-only helper `scripts/search_original_recorder.py --health` from the `rlm-search` skill with the configured Python environment.
4. Continue with the helper only when health reports a non-zero `indexed_files` count; query with `scripts/search_original_recorder.py "<query>" --limit 8`.
5. If MCP and CLI both fail, report the failure once and continue with narrow `rg` searches.

The local Qdrant client creates a service `.lock` file even for read-only
queries. If the CLI helper returns `reason: sandbox_write_denied`, rerun that
same helper with narrowly scoped sandbox escalation. Do not diagnose this case
as a database lock held by another process. Treat it as a real competing-client
lock only when the escalated helper still reports a lock/access conflict.

If the escalated helper reports `already accessed by another instance`, rerun
it with `--takeover`. The helper may stop a process only after its command line
has been verified as Python running this exact MemoryDB project's `src/main.py`;
never terminate an arbitrary Python process or remove Qdrant's `.lock` file.

The CLI fallback directly opens the same local Qdrant storage. Do not run it concurrently with another process that may write to that storage. If MCP registration is added or repaired, note that the current Codex session may need to be restarted before tools appear.

## Evidence and safety

- Verify retrieved claims against primary files, notes, tests, logs, or captures.
- Do not store guesses, temporary hypotheses, secrets, credentials, or large raw excerpts as facts.
- Write one fact per durable decision or rule so future semantic retrieval remains precise.
- Treat `D:\works\windev-v3.9` as immutable; indexing must not mutate it.
