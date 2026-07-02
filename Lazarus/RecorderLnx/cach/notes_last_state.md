# MIC-140 debug stand — последнее состояние (2026-07-01)

## Codex continuation 2026-07-02: MIC140 IRecorderDevice stub

**Prompt:** in `Tests\Mic140ProtocolDebug_Codex\device\MIC140`, create a MIC-140
module with `IRecorderDevice` support; for now it should be a class skeleton
with empty programming methods.

**Follow-up:** user intentionally keeps `m_MIC140` on the form as an explicit
MIC-140 debug handle, but wants it obtained through the standard device
interface. Added `IRecorderDevice.GetNativeObject: TObject`; the MIC-140 object
returns `Self`. `FindAndConnect` searches through
`RecorderDeviceManager.Search('MIC140')`, checks that `GetNativeObject` is
`TRecorderMic140Device`, stores the object in `m_MIC140`, then explicitly calls
`m_MIC140.AddRef`. The form destructor calls `m_MIC140.Release`. Removed both
the extra MIC-specific interface and the extra retaining interface field on the
form.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; only existing hints/notes.

**Commenting update:** user asked to walk through all classes in the example and
mark interface-method blocks. Added comments in `TRecorderMic140Device` for the
`IRecorderDevice` implementation blocks and object-only methods; added comments
in `TMic140DebugForm`, `TRecorderDeviceManager`, and
`TMic140DiscoveryThread` showing that their methods are object/LCL/TThread
methods rather than implemented interface methods.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; only existing hints/notes.

## Codex continuation 2026-07-02: device manager decoupling

**Prompt:** the interface form must not depend on a concrete device
implementation. Build a universal manager where devices are registered, and the
form searches through that manager. Keep comments with original Recorder method
names.

## Codex continuation 2026-07-02: connection/search split

**Prompt:** MIC-140 must not be created already bound to a known IP. Move
connection parameters into universal search logic; device parameters should be
read from the device; user/software parameters should be written in a test
configuration function in MainForm.

**Update:** `uMic140Registration.pas` now has a local discovery layer mirroring
RecorderLnx `RecorderMic140Discover`: it probes `192.168.14.*` with short
parallel TCP checks, returns the first found host through
`TRecorderDeviceSearchResult`, and only then the manager applies `rdpHost` /
`rdpPort` to `IRecorderDevice`. The known stand `192.168.14.155` is kept as a
last search candidate when the legacy TCP probe is silent; it is no longer a
constructor default. The form still uses only `IRecorderDevice` and
`RecorderDeviceManager`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0. `rg` confirms `uMic140DebugForm.pas` has no
`uMic140Device`, `CreateMic140Device`, or `TRecorderMic140Device` dependency.

**Buildability fix:** user requested project buildability. The first rebuild
failed because `uMic140Registration.pas` expected search callback types while
`uRecorderDeviceManager.pas` still had the older registration shape. Restored
`TRecorderDeviceSearchResult`, `TRecorderDeviceSearch`, the `Search` field, and
host/port application in `TRecorderDeviceManager.Search`. A second rebuild
compiled but could not overwrite `Mic140ProtocolDebug_Codex.exe` because a
running test process held it; stopped PID `22548` and rebuilt again.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; compiler emitted only hints/notes.

**Annotation update:** user asked to annotate `uMic140Registration.pas` and
describe each function's logic. Added an ASCII module header explaining the
registration/search workflow and comments for `RegisterMIC140_48`,
`Mic140TcpProbe`, `TMic140DiscoveryThread.Create`, `Execute`,
`DiscoverMIC140OnSubnet14`, `FindMIC140OnSubnet14`, and `FindMIC140_48`.
Later user asked to make comments Russian. Converted the module/function
comments in `uMic140Registration.pas` to Russian while keeping code identifiers,
Recorder method names, and behavior unchanged.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; only hints/notes.

**Done:** `TRecorderMic140Device.Create` no longer sets `192.168.14.155` or port.
The manager now supports `TRecorderDeviceSearchResult` and a registered search
function. `RecorderDeviceManager.Search` creates the device and applies found
`rdpHost/rdpPort` through `IRecorderDevice.TrySetDeviceProperty`. MIC-140
registration has `FindMIC140OnSubnet14` as the future broadcast/subnet probing
point. `TRecorderMic140Device.Connect` calls `ReadDeviceParameters`, currently a
stub for hardware-read parameters. The form has `ConfigureTestDevice`, which
writes test/user parameters only through `IRecorderDevice`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; no compiler errors or warnings.

**Done:** added `device\uRecorderDeviceManager.pas` with a small
`TRecorderDeviceManager` registry. MIC-140 registration moved to
`device\MIC140\uMic140Registration.pas`; it mirrors original names
`RegisterMIC140_48`, `RegisterDeviceClass`, and `RegisterDevice`. The project
entry includes the registration unit as bootstrap, while `uMic140DebugForm.pas`
uses only `uRecorderDeviceInterfaces` and `uRecorderDeviceManager`.
`FindAndConnect` now calls `RecorderDeviceManager.Search('MIC140')` and then
works only through `IRecorderDevice`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0. `rg` confirms the form has no dependency on
`uMic140Device`, `CreateMic140Device`, or `TRecorderMic140Device`.

**Done:** added `device\MIC140\uMic140Device.pas` with
`TRecorderMic140Device = class(TInterfacedObject, IRecorderDevice)` and factory
`CreateMic140Device`. The class exposes basic identity/properties/channels,
state transitions for `Connect/Disconnect/ProgramDevice/Start/Stop`, and a stub
`ReadBlock` that returns `False`. The form now can create/connect this stub via
`FindAndConnect`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; no compiler errors or warnings, only hints/notes.

## Codex continuation 2026-07-02: Mic140ProtocolDebug_Codex cleanup

**Prompt:** clean `Tests\Mic140ProtocolDebug_Codex` so only the visual form
project remains. Remove extra code and leave only `CheckRow(i: Integer)` in the
form module as the row-green decision point.

**Done:** the folder was reduced to four source files only:
`Mic140ProtocolDebug_Codex.lpi`, `Mic140ProtocolDebug_Codex.lpr`,
`uMic140DebugForm.pas`, and `uMic140DebugForm.lfm`. All protocol, CLI, sniffer,
driver, docs/data, stubs, logs, executable, backup, and build-output artifacts
were removed from this folder. The project is now a minimal LCL GUI with a grid;
`TMic140DebugForm.CheckRow(i: Integer): Boolean` decides whether a row is painted
green.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0 before generated `exe/lib` artifacts were removed
again to keep the folder clean.

## Codex continuation 2026-07-01: single-project GUI/CLI merge

**Prompt:** make `Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebug_Codex.lpr`
work like the original GUI stand, keep green rows for codes matching the
reference, remove separate CLI projects, embed CLI/proxy modes into the same
GUI project, and fix the 51-channel Recorder-wire mode (48 AIn + 3 TIn).

**Done:**
- folder now has one Lazarus project only: `Mic140ProtocolDebug_Codex.lpi/.lpr`;
  old `Mic140ProtocolDebugCli_Codex.*` and `Mic140Example_Codex.*` were removed;
- `Mic140ProtocolDebug_Codex.exe` now dispatches GUI, `--auto`, numeric CLI
  duration mode, and `--proxy` sniffer mode from one executable;
- GUI config parser accepts the same protocol flags as headless mode;
- defaults are Recorder-wire: `tin=3`, auto FIFO stride resolves to 51, visible
  AIn remains 48;
- stream row recovery now accepts shifted rows only when the full 51-word row is
  present, so TIn words are not silently truncated;
- GUI table still marks reference-matching rows green through
  `Mic140AdcTablePrepareCanvas`;
- capture docs and scripts now point to `Mic140ProtocolDebug_Codex.exe`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0. Headless checks
`Mic140ProtocolDebug_Codex.exe --auto 1 --no-settle` and
`Mic140ProtocolDebug_Codex.exe 1` both used the unified executable and logged
`ch=48 tin=3 fifo=-1`, then stopped at `TCP probe failed` because the device at
`192.168.14.155:4000` is currently not accepting TCP.

## Codex continuation 2026-07-01: protocol rewritten from live dump

**Prompt:** пользователь попросил на основе снятого дампа переписать протокол
как в задании и править до рабочего состояния без остановок.

**Confirmed facts from live Recorder dump `20260701_153018`:**
- stream profile: `PORT=0 size=163`, `msgWords=163`, `dataWords=153`;
- payload row: `stride=51`, `samples=3`;
- row layout: 48 AIn words, then TIn slots `48..50`;
- original Recorder programming keeps `m_ChanDump[2]=channels.Size()=48`.

**Code/doc changes in `Tests\Mic140ProtocolDebug_Codex`:**
- `--recorder-wire` / `MIC140_DEBUG_RECORDER_PROFILE=1` now mean
  `fifoStride=51`, `chanDump[2]=48`, `fifoSamples=3`;
- `VisibleChanDumpCount` no longer returns 51 for env recorder profile;
- `ADDCHANNELMODULE` argument 3 is now `Length(chanDump)`, matching original
  `Size=count_chan_bios+SIZE_START_DESC_CHAN_BIOS`; passing only `ptrCnt`
  produced stream payload with a visible offset/garbage at the row start;
- CLI/help/config comments corrected from the old wrong `chanDump=51`;
- acceptance reference loader prefers
  `Data\mic140_adc_reference_recorder_wire_live_20260701_153018.txt`;
- protocol and capture docs now explicitly describe the `chanDump=48` vs
  `stride=51` distinction.

**Verification:** all three Codex `.lpi` rebuild with exit code 0. Live CLI
before the `Length(chanDump)` fix reached the device and showed correct
programming headline (`slots=51`, `fifoStride=51`, `fifoReady=153`,
`msgWords=163`, `ptrHead=[48,323,48,...]`), but payload rows were offset and
second-bank codes saturated. After the fix, live retest was blocked by device
network state: `192.168.14.155` stopped accepting TCP `4000`; final check also
timed out ping while Recorder was open. Recorder process started by Codex was
closed. Next step after hardware reset/link recovery: rerun
`Mic140ProtocolDebugCli_Codex.exe --auto 20 --recorder-wire --tin-slots 3`.

## Live Recorder capture 2026-07-01 15:30

**Промпт:** пользователь остановил live-захват оригинального Recorder и попросил разобрать дампы и обновить протокол.

**Сделано:**
- Разобран свежий ETL `Tests\Mic140ProtocolDebug_Codex\Data\captures\netsh_192.168.14.155_20260701_153018.etl`.
- Parser: `Tools\parse_mdp_from_etl.py`.
- Найден рабочий Recorder wire profile просмотра: `total_valid_mdp=142`, `PORT=0=133`, `PORT=1=9`, `PORT=0 size=163 count=133`, `msgWords=163`, `dataWords=153`, `stride=51`, `samples=3`, TIn в слотах `48..50`.
- Созданы/обновлены:
  - `Data\captures\recorder_mdp_reference.txt`;
  - `Data\captures\recorder_mdp_control_examples.txt`;
  - `Data\mic140_adc_reference_recorder_wire_live_20260701_153018.txt`.
- Исправлен parser: теперь реально пишет `recorder_mdp_control_examples.txt`, а не только печатает путь.
- Обновлены `Docs\mic140_protocol.md`, `Docs\capture_workflow.md`, `Data\captures\README.md`.

**Вывод:** старый Cursor ETL `netsh_192.168.14.155_20260701_135935.etl` — валидный MDP-дамп, но не эталон Recorder-просмотра (`msgWords=106`, `stride=48`, `samples=2`). Для дальнейшей сверки использовать live Recorder dump `20260701_153018` и режим стенда `--recorder-wire --tin-slots 3`.

## Codex-стенд `Tests/Mic140ProtocolDebug_Codex`

**Промпт:** создать в `Tests\Mic140ProtocolDebug_Codex` автономный Lazarus-тест для отладки протокола MIC140, без unit-ов из других папок, с документацией протокола, сниффером, контрольными дампами и понятной точкой входа `DevMng.Search -> Connect -> Setup -> Start -> OnGetBlock -> Stop`.

**Сделано:**
- Создан автономный набор проектов:
  - `Mic140Example_Codex.lpi` — минимальный event-based пример API.
  - `Mic140ProtocolDebugCli_Codex.lpi` — CLI авто-прогон и proxy/sniffer.
  - `Mic140ProtocolDebug_Codex.lpi` — LCL-интерфейс стенда.
- Все `.lpi` используют только локальные пути `stubs;Driver;Driver\utils`; production units из `Device/` и соседний `Mic140ProtocolDebug` не подключаются.
- В `Docs` добавлены:
  - `task.md` — сохраненное задание и критерии готовности.
  - `mic140_protocol.md` — краткое описание MIC-140/MDP, источники, профили, приемка.
  - `capture_workflow.md` — как запускать proxy/netsh, Recorder и parser.
- Локальный parser `Tools\parse_mdp_from_etl.py` исправлен: при переданном ETL пишет результат рядом с этим ETL, а не в старый `Mic140ProtocolDebug`.
- Дамп `Data\captures\netsh_192.168.14.155_20260701_135935.etl` разобран: `total_valid_mdp=200`, `PORT=0=63`, `PORT=1=137`, `PORT=0 size=106`, `stride=48`. Это валидный MDP-дамп MIC-140, но не Recorder wire profile `msgWords=163/stride=51`.
- Созданы `Data\captures\recorder_mdp_reference.txt`, `Data\mic140_adc_reference_recorder_wire_exported.txt`, `Data\captures\README.md`.

**Проверка:** все три проекта собраны через `C:\lazarus\lazbuild.exe -B`, exit code 0. Финальные сборки без warnings, только hints/notes.

## Промпт
Продолжить стенд MIC-140 (`Tests/Mic140ProtocolDebug`): приёмка AIn 1–48 ±50, сверка с Recorder, использовать навык RecorderLnx.

## Сделано

### Эталоны
- `Data/mic140_adc_reference.txt` — production scan (fifo=48), stand steady-state 01.07
- `Data/mic140_adc_reference_recorder_wire.txt` — Recorder MDP wire (stride=51, TIn)

### Код стенда
- При `tin-slots=0` strict-приёмка **только AIn 1–48** (TIn пропускается)
- `stand-good` и ADC-таблица в логе: M/48 без TIn при tin=0
- Дефолты: production scan, settle=10s, bank2-delay=1, fifo=48

### Сборка
`lazbuild -B Mic140ProtocolDebugCli.lpi` — **OK** (exit 0)

## Live-тесты (192.168.14.155 rev14.1)

| Команда | read | published | stand-good | Примечание |
|---------|------|-----------|------------|------------|
| `--auto 25` | 124 | 0 | 24/48 @blk49 | CH01–24 OK; CH25 Δ≈388→109 к концу прогрева |
| `--auto 40 --settle-sec 20` | 199 | 0 | 24/48 @blk99 | CH25 Δ≈109; CH28+ тысячи кодов |

Поток стабилен (`readGaps=0`, `corrupt=0`, ~5 blk/s).

## Выводы (D26–D28)

- **D26:** production `tin=0`, 48 slots — правильный путь; `tin=3` ломает 2-й банк
- **D27:** wire-эталон (stride 51) ≠ stand fifo=48 — два файла эталона
- **D28:** CH25–26 ещё прогреваются после 10–20 s; CH28+ — programming/ME048, не только settle

## Открыто

1. PASS AIn 25–48 ±50 к stand-эталону
2. TIn 1–3: гибрид (48 scan + READMEMDM 114) или wire-профиль
3. Захват programming PORT=1 через proxy для сравнения с Recorder
4. Сверка shadow `Driver/` с production `Device/MIC140v2/` после PASS стенда

## Команды

```powershell
cd D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug
.\Mic140ProtocolDebugCli.exe --auto 25
.\Mic140ProtocolDebugCli.exe --auto 40 --settle-sec 20
.\Mic140ProtocolDebugCli.exe --auto 10 --recorder-wire --tin-slots 3
```
