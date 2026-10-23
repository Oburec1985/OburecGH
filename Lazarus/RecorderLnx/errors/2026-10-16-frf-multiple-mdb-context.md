# FRF context with multiple MDB components

MIC315 has two persistent MDB models on different pages. The global object
resolver returned the first model, regardless of the most recently applied
context. Added explicit model ActivateContext on Apply, accepted settings and
branch creation; the resolver prefers that live model across page changes.
Destroy clears the pointer. Undo snapshots cannot activate without ParentPage.

Verification: forced app build exit 0; forced ImpactHammerUiSmoke build and
--mdb-model-path-only PASS, extended to two models and explicit activation.
FRF storage remains object/frf/track; MDB selected-path field may show the
deeper registration directory, which is a different path by design.
Remote executable staged; running remote application/configuration unchanged.
