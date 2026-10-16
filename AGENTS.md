# Project agent rules

- When a task contains independent, bounded subtasks that can proceed safely at
  the same time, delegate those subtasks to additional agents and continue useful
  local work in parallel.
- Keep ownership boundaries explicit so agents do not edit the same files
  concurrently. The primary agent integrates and verifies the final result.

## Workplace entry points (installed 2026-10-13)

- External knowledge base (AGrav vault): `D:\works\AGrav` — start with
  `README_AI.md`, then `00_Система\Оглавление.md`; the skill router is
  `00_Система\Скиллы_ИИ.md`; project registry is `20_Проекты\Цех_Проектов.md`.
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
