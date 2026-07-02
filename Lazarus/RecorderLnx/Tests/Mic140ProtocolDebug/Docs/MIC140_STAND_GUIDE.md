# MIC-140: стенд, протокол и приёмка

Руководство для `Tests/Mic140ProtocolDebug` — автономный стенд сверки с Windows Recorder.

## 1. Оборудование и сеть

| Параметр | Значение стенда |
|----------|-----------------|
| IP | `192.168.14.155` |
| TCP порт | `4000` |
| Модуль | MIC-140 rev **14.1**, 48 AIn + 3 TIn |
| Частота | **10 Гц** |
| Период блока | **200 мс** |
| Диапазон | **80 мВ** (`range=0`) |

## 2. Профили протокола (подтверждено экспериментами 2026-07-01)

### A. Стабильный стенд (по умолчанию `--auto`)

| Параметр | Значение |
|----------|----------|
| fifoStride | **48** (авто) |
| chanDump[2] | **48** |
| msgWords | **106** |
| TIn | READMEMDM 114 (throttle 200 ms) |
| CH01–24 | PASS ±50 |
| CH25–48 | FAIL (ME048/прогрев; Δ CH25≈100 после 20s settle) |
| TIn | не в strict-приёмке при `tin=0` (DM); wire-эталон — отдельный файл |
| Поток | ~120 блоков / 25 с, `readGaps=0` |

```powershell
.\Mic140ProtocolDebugCli.exe --auto 10
```

### B. Recorder wire (дамп netsh 2026-07-01)

| Параметр | Recorder | Стенд `--recorder-wire` |
|----------|----------|-------------------------|
| msgWords | **163** | **163** |
| stride | **51** | **51** |
| samples/packet | **3** | **3** |
| chanDump[2] | **51** | **51** |
| TIn в FIFO | слоты 48..50 | слоты 48..50 |

```powershell
.\Mic140ProtocolDebugCli.exe --auto 10 --recorder-wire --tin-slots 3
# или: $env:MIC140_DEBUG_RECORDER_PROFILE='1'
```

**Статус (D23–D25):** формат кадра совпадает (`ptrHead=[48,323,51,...]`, `size=163`), но поток нестабилен (много `reject all sample rows`, 3–6 блоков/10 с). Для приёмки пока использовать профиль A.

Контрольные примеры: `Data/captures/recorder_mdp_control_examples.txt`.

## 3. Сборка

```powershell
cd D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug
C:\lazarus\lazbuild.exe Mic140ProtocolDebugCli.lpi
```

## 4. Сниффинг Recorder

```powershell
cd Tools
.\mic140_capture_start.ps1
# Recorder → Просмотр MIC-140
.\mic140_capture_stop.ps1
python .\parse_mdp_from_etl.py
```

Для текстового `mdp_proxy_*.log` — в Recorder указать `127.0.0.1:4001` и запустить прокси:

```powershell
.\Mic140ProtocolDebugCli.exe --proxy 4001 192.168.14.155 4000
```

## 5. Эталоны

| Файл | Профиль |
|------|---------|
| `Data/mic140_adc_reference.txt` | production fifo=48, stand steady-state |
| `Data/mic140_adc_reference_recorder_wire.txt` | Recorder wire stride=51 + TIn |

Экспорт wire-эталона из ETL:

```powershell
python Tools\parse_mdp_from_etl.py --export-reference Data\captures\netsh_*.etl Data\mic140_adc_reference_recorder_wire.txt
```

## 6. Ключевые модули

| Файл | Роль |
|------|------|
| `Driver/uRecorderMic140v2Scan.pas` | BIOS scan, `--recorder-wire` |
| `Driver/uRecorderMic140v2Device.pas` | TIn: FIFO при stride>48, иначе DM |
| `Tools/parse_mdp_from_etl.py` | Разбор ETL |
| `Data/mic140_adc_reference.txt` | Эталон ADC |

Эталон C++: `MIC140_48mod.cpp`. Журнал гипотез: `errors/2026-06-30-ui-stand-ref-match.md`.
