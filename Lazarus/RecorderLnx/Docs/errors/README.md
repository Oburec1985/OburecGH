# RecorderLnx Error Investigation Journal

Use this folder for persistent bug investigations. Keep one Markdown file per distinct error so future sessions can resume from known facts instead of rechecking the same guesses.

## File Naming

Use `YYYY-MM-DD-short-error-slug.md`, for example:

```text
2026-06-29-mic140-start-timeout.md
```

## Entry Template

```markdown
# Error: short title

## Symptom
- What the user sees:
- Exact error text/log line:
- First observed:

## Context
- Branch/build:
- Relevant files:
- Relevant logs/screenshots:

## Facts
- Confirmed fact:
- Confirmed fact:

## Hypotheses
- [ ] Hypothesis:
  - Check:
  - Result:
  - Status: unchecked / rejected / confirmed

## Actions
- Change or command:
  - Verification:
  - Effect:

## Current Conclusion
- Root cause:
- Fix status:
- Remaining risk:
```

## Rules

- Read relevant files in this folder before debugging a recurring or similar error.
- Record every nontrivial hypothesis that was checked, including rejected ones.
- Record what command, log, build, test, screenshot, or code inspection proved each fact.
- After each meaningful change, note how behavior changed.
- When fixed, keep the final root cause and verification result in the same file.
