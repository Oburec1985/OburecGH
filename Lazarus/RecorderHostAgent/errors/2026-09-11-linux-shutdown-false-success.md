# Linux shutdown reported success but did nothing

## Symptom

RCPanel logged that shutdown of a Linux host was accepted, while the computer
remained powered on.

## Confirmed cause

`HostAgentShutdown` started `/sbin/shutdown` from the unprivileged desktop
process and immediately returned success. It did not wait for the command's
exit status or read its permission error. The DEB installed no narrow privilege
rule for this operation.

## Fix

- Linux HostAgent calls `sudo -n` for one root-owned, argument-free helper.
- The DEB grants the selected desktop user only that exact helper via sudoers.
- `allow_shutdown=1` is set only after the narrow sudoers rule is installed and
  validated; otherwise shutdown remains disabled.
- The helper schedules power-off after three seconds through systemd, allowing
  the HTTP response to be sent first; non-systemd fallback schedules shutdown.
- HostAgent checks exit status and returns the actual diagnostic on failure.
- No `WaitFor` or event wait was introduced.

## Verification

- RecorderHostAgent forced Win64 build: passed.
- `build_deb.py` compilation and generated `postinst` assertions: passed.
- `git diff --check`: passed.
- Actual shutdown was intentionally not executed.

## Remaining deployment step

Rebuild RecorderHostAgent on Linux, build/install DEB 0.1.1, then verify with
`sudo -n -l /usr/local/sbin/recorder-host-agent-shutdown` before the controlled
power-off test.

## 2026-09-11 — field check on 192.168.9.85

- Installed package is `recorderlnx 0.1.1`; config contains
  `allow_shutdown=1`.
- The helper and `/etc/sudoers.d/recorder-host-agent` exist; `sudo -n -l` grants
  the exact helper command.
- No `RecorderHostAgent` process was running. TCP 8766 was owned by the launched
  `RecorderLnx` process, and `GET /api/v1/status` timed out with zero bytes.
- The installed HostAgent SHA256 matched the staged 0.1.1 ELF. The trapped
  socket can therefore have come from an old in-memory agent which survived
  executable replacement during upgrade.
- Descriptor protection is strengthened for 0.1.2: open descriptors are
  marked `FD_CLOEXEC` before launching RecorderLnx; the child-side close
  callback remains as a fallback.
- Actual shutdown was not invoked. Recover by closing the RecorderLnx instance
  which owns 8766 and restarting HostAgent (or by logging out and back in).
