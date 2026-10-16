# RLM Reference

RLM (Recursive Language Models) is a practical pattern for tasks where the full context is too large or too noisy to fit into one prompt.

## Principle

Keep the broad context in the execution environment and repeatedly narrow it:

1. Search for candidates.
2. Read only the relevant fragment.
3. Extract facts.
4. Update state.
5. Recurse only into isolated subtasks.

This avoids "context rot": losing important details because too much unrelated material was loaded at once.

## Pseudo-API

| Name | Purpose |
| --- | --- |
| `context` | Source material: paths, logs, captures, notes, source files |
| `answer` | Current answer state and readiness flag |
| `llm_query(prompt, chunk)` | Analyze a small fragment |
| `rlm_query(prompt)` | Delegate a narrow subtask |
| `SHOW_VARS()` | Inspect current investigation state |

## Recommended State

Track these lists while investigating:

- `facts`: confirmed observations with source references.
- `hypotheses`: active explanations to test.
- `rejected`: checked explanations that did not match evidence.
- `artifacts`: files produced or consumed, such as logs and packet captures.
- `next_steps`: the next 1-3 searches or tests.

## Example: MIC140 Protocol Comparison

1. Capture original Recorder traffic for the exact user action.
2. Decode frames by endpoint, command id, payload, checksum, and response length.
3. Capture RecorderLnx traffic for the same action.
4. Compare the sequences before changing protocol code.
5. Save notes and captures together so future sessions can reproduce the comparison.
