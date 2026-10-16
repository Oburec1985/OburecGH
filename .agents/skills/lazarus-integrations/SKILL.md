---
name: lazarus-integrations
description: Add or review native Lazarus/FPC integrations including ZeosLib database access, SQL transactions, RESTRequest4Delphi API clients, JSON/HTTP workflows, CEF4Delphi embedded Chromium/WebView, external DLL/native libraries, configuration, secrets, logging, and integration error handling.
---

# Lazarus Integrations

## Selection Guide

Use proven Pascal libraries instead of hand-rolling integration layers:
- ZeosLib for SQL database access through Lazarus visual/nonvisual components or DBC interfaces.
- RESTRequest4Delphi for readable REST API clients when the project accepts that dependency.
- CEF4Delphi for embedded Chromium/WebView features in Lazarus/FPC apps.

Before implementation, query Context7 for the chosen library:
- `/marsupilami79/zeoslib`
- `/viniciussanchez/restrequest4delphi`
- `/salvadordf/cef4delphi`

## Database With ZeosLib

Use `TZConnection` as the central connection component. Configure protocol, host, port, database, user, password, and native client library location where needed.

Prefer parameterized SQL with `TZQuery`:

```pascal
Qry.SQL.Text := 'select id, name from items where kind = :kind';
Qry.Params.ParamByName('kind').AsString := AKind;
Qry.Open;
```

For changes, make transaction boundaries explicit:
- Set `AutoCommit := False` when grouped changes must commit together.
- `StartTransaction`, execute all changes, `Commit`.
- On exception, `Rollback` and re-raise or show a precise error.

Keep database calls out of UI handlers; call a data/service unit and return typed results or datasets.

## REST APIs With RESTRequest4Delphi

Use the fluent request API for simple clients:

```pascal
LResponse := TRequest.New
  .BaseURL(API_URL + '/users')
  .Accept('application/json')
  .Get;
```

For POST/PUT, set `ContentType('application/json')` and pass a serialized body. Keep base URLs in a central config unit, not scattered in forms.

Handle:
- HTTP status code ranges.
- Timeouts and network exceptions.
- JSON parsing errors.
- Retry rules only when the operation is idempotent or explicitly safe.

## Embedded Browser With CEF4Delphi

Initialize `GlobalCEFApp` in the project entry point before `Application.Initialize`. Only start the Lazarus application when `GlobalCEFApp.StartMainProcess` returns true.

Typical pattern:

```pascal
begin
  CreateGlobalCEFApp;
  if GlobalCEFApp.StartMainProcess then
  begin
    Application.Initialize;
    Application.CreateForm(TMainForm, MainForm);
    Application.Run;
  end;
  GlobalCEFApp.Free;
end.
```

Create browser instances from the form only after the CEF context is ready. Retry with a timer if needed, and update UI state from CEF callbacks through the main thread/message mechanism.

## Native Libraries And Secrets

Keep DLL/shared library paths configurable. Do not hard-code credentials. Put secrets in environment variables, local config files excluded from version control, or the project's established secret store.

## Logging

Every integration boundary needs useful logs:
- endpoint/database/protocol name without secrets
- elapsed time
- status code or database error class
- transaction start/commit/rollback for multi-step DB writes
- thread ID for background integrations