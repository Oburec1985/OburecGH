# MDB checkbox stops in debugger

Confirmed from screenshot: explicit Exception at MdbChange, line 102, for an
unavailable selected database object. Lazarus stops on raised exceptions even
when an enclosing handler catches them.
Correction: expected missing-context validation uses an informational dialog
and exits without raise. Reset checkbox/read-only/browse state on failure and
preserve the previous manual directory. Load/save use the same validation path.
Prevention: ordinary user input/context absence is not an exceptional failure;
do not use raise for this branch in LCL handlers.
