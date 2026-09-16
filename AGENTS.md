# Project agent rules

- When a task contains independent, bounded subtasks that can proceed safely at
  the same time, delegate those subtasks to additional agents and continue useful
  local work in parallel.
- Keep ownership boundaries explicit so agents do not edit the same files
  concurrently. The primary agent integrates and verifies the final result.
