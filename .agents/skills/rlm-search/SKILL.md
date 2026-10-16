---
name: rlm-search
description: Recursive Language Models (RLM) workflow for long-context programming, code archaeology, iterative search, log/protocol analysis, and debugging tasks that cannot be solved by one grep/read pass. Use when working with large repositories, AGrav knowledge-base research, Delphi-to-Lazarus comparisons, RecorderLnx/MIC140 investigations, network device protocol debugging, original-vs-port behavior comparison, or any task requiring hypothesis-driven recursive search with durable findings.
---

# RLM Search

Use this skill to keep long investigations sharp: do not load everything into the prompt. Work in small cycles of hypothesis, narrow search, confirmed facts, and state update.

## Core Loop

1. Define the goal and readiness criterion in one paragraph.
2. Split the task into 3-7 concrete subquestions.
3. For each subquestion, run a narrow search first (`rg`, file names, symbols, logs, packet markers), then read only the relevant files.
4. Record confirmed facts with `file:line`, command output, log fragment, packet timestamp, or exact artifact path.
5. Update the working state: accepted facts, rejected hypotheses, open questions, next search.
6. Use a subagent only for isolated branches with a narrow prompt and limited depth.
7. Finish by comparing the result with the original user request and the readiness criterion.

When Qdrant MCP search is available, make semantic retrieval the first narrow
search for AGrav and original Recorder archaeology:

- use `search_vault_notes` for AGrav knowledge;
- use `search_original_recorder_sources` for `windev-v3.9` code;
- keep result limits small (normally 5-12 chunks);
- follow every result with a primary-file read at the returned line range;
- use `rg` for exact symbols, callers, constants, and completeness checks;
- fall back to narrow `rg` if MCP is unavailable, never to bulk file loading.

For original Recorder work, do not silently assume that MemoryDB is available:

1. Search the active tool list for `search_original_recorder_sources`.
2. If present, call it before `rg`.
3. If absent, run `scripts/search_original_recorder.py --health`, then use
   `scripts/search_original_recorder.py "<semantic query>" --limit 8`.
4. If both MCP and CLI fail, report the failure once and use narrow `rg`.
5. Always open the returned absolute file and verify the cited line range;
   embeddings are navigation, not primary evidence.

## MemoryDB

For MemoryDB tool selection, MCP registration, startup diagnostics, fallback,
indexing, and safety rules, read and follow the separate
[$memorydb skill](../memorydb/SKILL.md). Keep this RLM workflow focused on the
investigation loop and use MemoryDB as its semantic-retrieval layer.

## Use For

- Large repositories, logs, generated files, or knowledge bases where full-context reading causes context rot.
- Programming tasks involving legacy-to-new comparisons, especially Delphi/Windows Recorder to Lazarus/RecorderLnx.
- Protocol, device, or MIC140 work where behavior must be matched against an original implementation.
- Debugging with repeated hypotheses, failed attempts, or existing `errors/*.md` investigation memory.
- Questions that need recursive search across AGrav, source code, tests, documentation, and runtime traces.

## Rules

- Read existing relevant `errors/*.md` before forming new debugging hypotheses.
- Keep a small findings table or notes list during the investigation.
- Do not repeat rejected hypotheses without new evidence.
- Prefer primary artifacts: source code, tests, original Recorder behavior, logs, packet captures, and generated dumps.
- Avoid destructive commands unless explicitly requested and approved.
- For durable project knowledge, update the relevant AGrav note or project documentation when the result is significant.

## Network Device Debugging

When debugging a network-connected device or protocol, create a capture plan before changing code:

1. Identify device-specific traffic markers: IP, port, command bytes, frame header, payload length, CRC/checksum, channel number, module id, or known MIC140 command pattern.
2. Start a sniffer/capture with a restrictive filter for those markers. Prefer saving raw captures as `.pcapng` plus a decoded text/CSV dump.
3. Capture a control trace from the known-good original program when possible. For MIC140, run the original Windows Recorder, let the user press "view"/polling actions several times, and save that exchange as the reference dump.
4. Capture the new implementation under the same action sequence.
5. Compare packet order, timing, request/response sizes, command ids, payload bytes, checksums, retries, and connection lifecycle.
6. Store captures under a project-local diagnostic folder such as `captures/`, `dumps/`, `cach/`, or `errors/` with timestamped names and a short `README`/note describing scenario, filter, device address, and app version.

Suggested naming:

```text
captures/YYYY-MM-DD_mic140_original_recorder_view_01.pcapng
captures/YYYY-MM-DD_mic140_original_recorder_view_01.txt
captures/YYYY-MM-DD_mic140_recorderlnx_view_01.pcapng
captures/YYYY-MM-DD_mic140_compare_notes.md
```

If no packet sniffer is available yet, first build or script the smallest useful one: capture timestamp, direction, endpoint, length, hex payload, and decoded device-specific fields. Keep the parser separate from production code unless it is intentionally becoming a reusable diagnostic tool.

## RLM Tools Mapping

| RLM concept | Codex practice |
| --- | --- |
| `context` | Workspace paths, logs, captures, AGrav notes; load selectively |
| REPL loop | `rg`, targeted file reads, tests, scripts, packet decoders |
| `llm_query` | Analyze one fragment or packet sequence |
| `rlm_query` | Subagent with a narrow subtask |
| `answer["ready"]` | Final self-check against readiness criterion |

## References

- Read `references/reference.md` when theory, pseudo-API, or the Python RLM sandbox pattern is useful.
- In AGrav, the source copy is `D:\works\AGrav\00_Система\skills\rlm-search\SKILL.md`.
