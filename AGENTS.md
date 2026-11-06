# Project agent rules

- When a task contains independent, bounded subtasks that can proceed safely at
  the same time, delegate those subtasks to additional agents and continue useful
  local work in parallel.
- Keep ownership boundaries explicit so agents do not edit the same files
  concurrently. The primary agent integrates and verifies the final result.

## Workplace entry points (installed 2026-10-13)

- External knowledge base (AGrav vault): `D:\works\AGrav` — start with
  `README_AI.md`, then the state page `00_Система\Состояние_работ.md` ("what was
  last": fresh work, statuses, next steps, journal links), then
  `00_Система\Оглавление.md`; the skill router is
  `00_Система\Скиллы_ИИ.md`; project registry is `20_Проекты\Цех_Проектов.md`.
- Three-trace contract for every iteration (owner:
  `project-iteration-log` skill): (1) an entry in the single project journal,
  (2) a row in `00_Система\Состояние_работ.md`, (3) a MemoryDB fact tagged
  `project:<name>` + `iteration` with `source_file` pointing at the journal.
  Do not skip a trace; report the layer as unavailable if it is. Run
  `D:\LLMWorkplace\scripts\check-context.ps1` to prove the chain is intact.
- Skill catalog: 24 skills in `C:\Users\User\.agents\skills` (global) and
  `D:\works\OburecGH\.agents\skills` (this project). Read the matching `SKILL.md`
  before acting; `memorydb` covers the local semantic memory,
  `agrav-knowledge-base` covers vault work.
- Local semantic memory: MCP stdio server `local_memory_db`
  (tools named `mcp__local_memory_db__*`), runtime in `D:\LLMWorkplace\MemoryDB`.
  Prefer `search_memory_facts` / `search_vault_notes` for navigation, then verify
  against the primary file. Do not start a second MemoryDB process. For the
  original Windows Recorder use `search_original_recorder_sources`: sources live
  in `D:\works\windev-v3.9` (cp1251, read-only) and the index already holds
  ~1900 chunks; its returned line range is a chunk window, so confirm the exact
  symbol text before relying on it.
- Installation, paths and limitations: `00_Система\Инструменты\Рабочее_место_LLM.md`
  in the vault.
- Answer in Russian unless the user explicitly asks for another language; the
  owning rule lives in `README_AI.md` in the vault.
- Never store passwords, tokens, personal data or private source excerpts in
  prompts, skills, logs or MemoryDB.
- If semantic search is blocked by another MemoryDB process, automatically use
  `search_original_recorder.py --takeover` to recover access. Stop only a process
  verified as this exact MemoryDB MCP server; never kill unrelated Python
  processes or delete the storage lock file. Explicit user authorization:
  2026-10-26.
