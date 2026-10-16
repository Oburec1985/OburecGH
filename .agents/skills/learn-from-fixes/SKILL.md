---
name: learn-from-fixes
description: Convert confirmed bug fixes, regressions, failed assumptions, and recurring implementation mistakes into durable prevention rules. Use after an error has been diagnosed and fixed in code, configuration, UI, protocols, tests, builds, documentation, or agent workflows, especially when the same class of error could recur in this or another project.
---

# Learn From Fixes

Turn a verified fix into reusable engineering memory instead of recording only the symptom.

## Workflow

1. Confirm the root cause and verify the fix before deriving a rule. Do not promote an untested hypothesis.
2. State the failure pattern independently of the affected filename, device, or one-off value.
3. Formulate an actionable rule with:
   - trigger: when the rule applies;
   - required action or invariant;
   - verification that proves compliance.
4. Search existing system and project rules. Extend the closest rule instead of creating a duplicate.
5. Choose the narrowest sufficient scope:
   - system skill or global standards when the rule applies across projects;
   - project documentation when it depends on that project's architecture, tools, formats, or lifecycle;
   - error journal for investigation evidence and rejected hypotheses.
6. Record the rule during the same task as the fix. Link it to the detailed error journal when one exists.
7. Re-check the implemented fix against the new rule. Add or update a regression test when the project has an agreed test pattern.

## Rule quality

A useful rule prevents a class of failures. Prefer:

`When parsing UTF-8 AnsiString text, derive offsets with Length/Pos; never use character-count literals as byte offsets. Verify with non-ASCII input.`

Avoid:

`Use 10 instead of 6 in the MC-201 parser.`

Keep rules short, imperative, and testable. Include the rationale only when the constraint would otherwise appear arbitrary.

## Promotion criteria

Promote a fix into a durable rule when at least one condition is true:

- the cause is non-obvious or crossed subsystem boundaries;
- the error could silently lose configuration or data;
- a build could succeed while runtime behavior remains wrong;
- the same pattern exists in more than one location or project;
- future agents are likely to repeat the failed approach;
- the user explicitly requests permanent learning.

Do not create permanent rules for simple typos, transient external failures, or rejected hypotheses unless they reveal a reusable verification step.

## Documentation placement

- Preserve evidence in the project's `errors/` note: symptom, facts, hypotheses, root cause, fix, verification, remaining risk.
- Put project-specific prevention rules in its development rules, architecture notes, or equivalent authoritative document.
- Put cross-project rules in the relevant Codex skill and mirror them into AGrav system documentation when AGrav is in scope.
- Update indexes, relationship maps, and change history required by the knowledge base.

Never claim learning is complete merely because an error note was written. Completion requires an actionable prevention rule in an authoritative location or an explicit decision that the fix does not meet promotion criteria.
