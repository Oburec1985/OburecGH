# HostAgent returned HTTP 403 after package upgrade

## Symptom

RCPanel logged `выключение ПК ... отказ launcher (HTTP 403)` for all four KIP
hosts in the evening of 2026-09-16. Some responses explicitly contained
`Shutdown is disabled by allow_shutdown=false`; others had no response body
in the RCPanel log.

## Confirmed facts and cause

- The generated DEB `postinst` restarted HostAgent before calling
  `configure_host_agent_shutdown`, which changes `allow_shutdown` to `1`.
- HostAgent loads its INI once at startup. A later INI edit does not change
  the running process's `AllowShutdown` value.
- KIP-3/2 config mtimes were 21:52, after the agent restart at about 21:44.
  The 403 responses at 22:04 included the disabled-shutdown message.
- On 2026-09-17 all four hosts had a live agent, empty API token,
  `allow_shutdown=1`, and `/api/v1/status` returned HTTP 200 with
  `shutdown_enabled=true`. The morning restart loaded the corrected config.

The timing, not a connection timeout, explains the observed 403. No remote
shutdown command was sent during diagnosis.

## Fix and verification

Move `start_host_agent_for_logged_in_users` after the final
`configure_host_agent_shutdown` call in `build_deb.py`. The generated control
tar was inspected and confirms this order. `python -m py_compile` and
`git diff --check` passed. The installed packages have not yet been replaced;
the new postinst ordering will take effect with the next DEB deployment.

## Remaining risk

RCPanel reads only the first TCP response chunk, so some HTTP 403 logs omit
the JSON body. That is a separate diagnostic defect, not the cause of the
shutdown refusal. An actual power-off test remains intentionally unperformed.
