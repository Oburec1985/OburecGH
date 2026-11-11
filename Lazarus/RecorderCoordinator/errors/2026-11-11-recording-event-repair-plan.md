# Prepared repair — event D8BFD07C-21DB-498D-87DF-6529ADE7728B

**Prepared only. No real database mutation has been executed.**

## Authoritative cohorts

Coordinator lifecycle logs and `/api/v1/events` identify these exact recording IDs:

| Take | Host | Recording ID | Actual source entry |
| --- | --- | --- | --- |
| First | KIP4 | 003EEC51-5301-4A19-883D-B6356CA9E1CF | smb://KIP-4/USML/0009/0009.mera |
| First | KIP3 | EDDE7E11-DA45-45A6-B2F9-3182DCCF4A06 | smb://KIP-3/USML/0001/0001.mera |
| First | KIP1 | 0EA211B0-E902-4144-8993-FC2857835CCB | smb://KIP-1/USML/0006/0006.mera |
| First | KIP2 | 7D54DFE0-5812-4186-B548-35B957920AA7 | smb://KIP-2/USML/0009/0009.mera |
| First | ARM | 89AB2B2D-2E2D-4E89-9830-22CE5EA76467 | smb://ARM/USML/0001/0001.mera |
| Second | KIP2 | E273EE1E-5966-4497-B87F-FA79BCE7ACBC | smb://KIP-2/USML/0010/0010.mera |
| Second | KIP4 | 63A9EA37-962E-4C67-9BDA-3F5AA56FAC8F | smb://KIP-4/USML/0010/0010.mera |
| Second | ARM | 5F5C2212-D2D4-4FB2-8389-44B2550F8C1C | smb://ARM/USML/0002/0002.mera |
| Second | KIP3 | 7EEC246A-1D69-4D61-87B6-1D6C0070E641 | smb://KIP-3/USML/0002/0002.mera |
| Second | KIP1 | 1071AEEB-AD6F-4B40-9B29-7713372483D5 | smb://KIP-1/USML/0007/0007.mera |

First event start is `2026-11-11T06:27:22.416Z`. The first take was fully completed at 09:27:30–31 local time before the second cohort started at 09:27:45 local. Use the **persisted minimum `started_at_utc` of the second five IDs** for the new event timestamp, rather than approximating a timestamp from log receipt time. Preserve each recording's original start/finish values.

## Preconditions and exact backup

1. Verify all ten `mera_recordings` rows still exist, belong to the old event, are terminal, have the expected distinct recorder owners, and that there are exactly ten package rows in that event. Abort on any discrepancy or active recording.
2. Export a dated JSON snapshot of the old `events` row, the ten complete `mera_recordings` rows, their `mera_recording_files`, corresponding `data_files`, and all corresponding `data_file_locations`. Preserve column names, SQL NULLs, types and values. Also save the read-only API event JSON and the lifecycle log lines. Store under a task-specific backup directory outside the active configuration. Do not include credentials.
3. Record SHA-256 of the JSON snapshot and read-back counts. The rollback preimage is the exact exported event row plus the ten original event associations; nothing should be inferred from filenames.

## Transaction to review

Use one transaction with explicit rollback on any failed assertion. Allocate one new event ID and assert it is absent. Copy the old event's event type/severity/payload/description/registration fields into a new event row, setting its timestamp to the persisted minimum start time of the second cohort and its display name to the first second-cohort package display name in start-time order. Update **only `mera_recordings.event_id` for the five exact second-cohort IDs**, guarded by `event_id = old_event_id`. Require five affected rows. Keep the old event and all ten recording IDs. Do not alter recording times, owner IDs, correlation IDs, file IDs, paths, or physical files.

Before commit, read back exactly five packages per event, check the complete set of ten recording IDs is unchanged, and compare all file/location rows against the backup. Commit only after all checks pass. Refresh/restart the fixed Coordinator after deployment so its old in-memory grouping does not conflict with repaired historical SQL associations.

## Rollback

In one transaction, move the same five second-cohort IDs back to the old event, guarded by their new event association. Require five updates. Delete only the newly created event row after asserting it has no remaining recordings. Restore the original event fields if any were intentionally changed (the plan changes none). File and recording records remain intact throughout.

The original SQL paths were logged correctly as host-qualified SMB URIs. Do not replace them with the erroneous KIP4 paths displayed by the old resolver. Any previously operator-saved incorrect location path must be repaired only after comparing its file owner and the authoritative source lifecycle path.
