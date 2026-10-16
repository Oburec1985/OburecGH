---
name: agrav-knowledge-base
description: Work with the AGrav Obsidian knowledge base at D:\works\AGrav. Use when the user mentions AGrav, the knowledge base, Obsidian vault, system skills, project memory, AGrav documentation, project standards, Relationships.md, history changes, or asks to work on projects whose context may live in AGrav.
---

# AGrav Knowledge Base

## Core Workflow

Treat `D:\works\AGrav` as the user's living external memory and primary source of project context.

At the start of an AGrav-related task, read only the relevant entry points:
- `D:\works\AGrav\README_AI.md`
- `D:\works\AGrav\00_Система\Оглавление.md`
- `D:\works\AGrav\00_Система\Глобальный_индекс_работ.md` when the task refers to prior work, another project, folder, or chat
- `D:\works\AGrav\00_Система\Скиллы_ИИ.md`
- `D:\works\AGrav\00_Система\Код_Стандарты.md` when code standards matter
- `D:\works\AGrav\00_Система\skills\rlm-search\SKILL.md` for long-context / recursive research (RLM)
- `D:\works\AGrav\00_Система\Relationships.md` when architecture, project links, or new knowledge items matter
- `D:\works\AGrav\20_Проекты\Цех_Проектов.md` when choosing or locating an active project

Then search the specific domain folders before acting:
- `10_Работа` for work and engineering context
- `15_Дом` for home/network/infrastructure context
- `20_Проекты` for active project context
- `30_Библиотека` for books and reference material

## Knowledge Base Rules

Keep AGrav current when the task changes durable knowledge:
- Record important results, architectural decisions, and nontrivial fixes in the relevant AGrav note.
- Add or update globally reusable work topics in `D:\works\AGrav\00_Система\Глобальный_индекс_работ.md`; keep details in project logs and documentation.
- Add significant session/change entries to `D:\works\AGrav\90_Архив\История_изменений.md`, newest entry near the top under the title.
- Update `Relationships.md` when adding a significant project, technology, dependency, or knowledge item.
- Preserve the existing folder logic instead of placing scripts or notes in the vault root.
- For repeated tools, use the pattern `00_Система\Инструменты\ToolName.md` plus `00_Система\Инструменты\ToolName\` for scripts.
- New documents should include a backlink to the system index or the relevant section index.

If AGrav and the current code disagree, inspect both. Correct stale AGrav notes when the fix is obvious; ask the user for genuinely architectural conflicts.

## Coding Standards From AGrav

When applicable:
- Use UTF-8 for files containing Russian text.
- For Delphi/Object Pascal, follow local conventions: local variables `lName`, globals `g_Name`, private/protected fields `fName`, class/access members `m_Name`.
- Prefer clearing and reusing objects over recreating them in hot paths.
- Avoid runtime allocation inside performance-critical or threaded loops where feasible.
- Add focused tests for new features when the project has a test pattern.
- Keep per-project plans and technical notes under `cach\plan.md` and `cach\notes_*.md` when that convention exists.
- For code projects, maintain `CHANGELOG.md` with rephrased task prompts and links to detailed docs — see personal skill `project-change-log` (`~/.cursor/skills/project-change-log/SKILL.md`).

## Debugging Standard

For hard bugs, use temporary high-resolution logging only around suspicious code:
`[TIME: HH:mm:ss.SSS] [TID: 0x000] [TYPE: ENTER|LOG|EXIT|ERROR] [CONTEXT: ProcName, Line: NN] [DATA: var=value]`

Use thread-safe writes, enter/exit markers for crash localization, forced flush before risky operations, and remove temporary logging after the bug is confirmed fixed.

## Response Style

Answer the user in Russian unless they ask otherwise. Be brief, practical, and include parameter explanations when giving technical instructions.
## Error Investigation Memory

When resolving any nontrivial error in an AGrav-related project or document workflow, use a project-local `errors/` folder as persistent debugging memory.

- At the start of debugging, search and read relevant `errors/*.md` files before making new hypotheses.
- Keep one Markdown file per distinct error: `YYYY-MM-DD-short-error-slug.md`.
- Record symptoms, confirmed facts, checked hypotheses, verification commands/logs/tests/code references, actions taken, behavior changes, final root cause, and remaining risk.
- Keep rejected hypotheses so later sessions do not repeat the same checks.
- For RecorderLnx, use `D:\works\OburecGH\Lazarus\RecorderLnx\errors\`. For AGrav-only issues, use the relevant project/document folder's `errors/` directory instead of the vault root.
