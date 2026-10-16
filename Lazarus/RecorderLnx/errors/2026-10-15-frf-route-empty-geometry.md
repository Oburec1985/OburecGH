# Empty geometry selector in FRF route

The route dialog called FindRecorderModelPointTarget only with the model's
saved Target3dComponentId. An empty or stale scene assignment left cbObject
empty and the dialog offered no way to select a live scene.

Added designer-owned cbScene/lblScene to the route LFM. It enumerates the
registered geometry catalogs, restores the saved scene, and automatically
selects a scene only when exactly one is available. Scene selection writes
the stable component ID and reloads objects. Opening the scene/object dropdown
refreshes the live catalogs; object selection is restored by node ID.

Verification: route unit compiles in forced RecorderLnx build. Full build
currently blocked by five unsolved forward declarations in the independently
edited Device/Modbus/UI/uRecorderModbusSourceEditor.pas; no EXE was produced.
