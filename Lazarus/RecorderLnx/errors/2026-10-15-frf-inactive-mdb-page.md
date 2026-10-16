# FRF cannot find MDB object on another mnemonic page

Cause: active MDB directory was owned by a view's manager. Switching mnemonic
pages destroys views, clears the active manager and leaves the persistent MDB
component model alive. Therefore global-manager lookup still failed.
Fix: resolve selected ObjectId/BasePath from live MDB component models across
all pages. Register models at construction, remove at destruction; skip undo
snapshots without ParentPage. FRF consults the persistent model first.
Rule: cross-page configuration consumers must resolve persistent component
models, never depend solely on currently materialized controls/managers.
Verification: UI smoke --mdb-model-path-only creates an object and a model on
another page without a view, resolves its directory and checks cleanup.
Forced app/UI smoke builds passed.
