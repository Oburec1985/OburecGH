# RecorderLnx Modbus Master

The datasource follows the prototype and Delphi MIC-140 composition model:

`configured datasource -> bus/transport -> device (Unit ID) -> tag`

The bus owns one TCP or RTU transport and one serialized request scheduler.
Devices own Unit IDs and tags own protocol region, zero-based address, data
type and byte order. RecorderLnx only sees the published leaf tags. Their
public address is `<datasource alias>/<tag alias>`; device aliases, Unit IDs,
register areas and wire addresses stay inside the versioned JSON config.

Lifecycle is explicit: `Connect -> Initialize -> Configure -> Start`, with
`Stop` retaining the configured session and `Disconnect` releasing it.
Reconnect uses bounded backoff and repeats the complete lifecycle. Runtime
polling uses prebuilt plans and fixed ADU buffers.

Supported reads: FC01, FC02, FC03 and FC04. Supported writes: FC05, FC06,
FC15 and FC16. Values support Bool, UInt16, Int16, UInt32, Int32, Float32 and
Float64 with ABCD, BADC, CDAB and DCBA byte orders. UI addresses are stored
zero-based and also shown in conventional 0xxxx/1xxxx/3xxxx/4xxxx notation.

Run `Scripts/run-modbus-checks.ps1` on Windows or
`Scripts/run-modbus-checks.sh` on Linux for core, fake TCP/RTU runtime, UI
resource smoke and a forced RecorderLnx build. The Linux runner uses system
`lazbuild`/`fpc` by default and accepts `LAZBUILD`/`FPC` overrides. Physical
TCP/RTU acceptance remains a
separate step until the stand endpoint/register map is supplied.
