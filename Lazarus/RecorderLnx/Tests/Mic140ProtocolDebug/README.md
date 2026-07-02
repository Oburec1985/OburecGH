# Mic140ProtocolDebug

Стенд отладки протокола MIC-140 (автономный от RecorderLnx: `stubs/`, `Driver/`).

## Проекты

| Файл | Назначение |
|------|------------|
| **Mic140Example.lpi** | CLI: минимальный API (`uMic140Api`) |
| **Mic140ProtocolDebugCli.lpi** | CLI: полный разбор флагов (`--auto`, `--bank2-delay-mul`, …) |
| **Mic140ProtocolDebug.lpi** | GUI: таблица ADC с зелёной подсветкой ±50, лог приёмки |

## Сборка

```powershell
cd D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug
C:\lazarus\lazbuild.exe Mic140Example.lpi
C:\lazarus\lazbuild.exe Mic140ProtocolDebugCli.lpi
C:\lazarus\lazbuild.exe Mic140ProtocolDebug.lpi
```

## Приёмка (CLI)

```powershell
.\Mic140ProtocolDebugCli.exe --auto 10
# профиль стенда по умолчанию: tin=3, fifo=auto(51), bank2-delay-mul=6
```

Подробное руководство: `Docs/MIC140_STAND_GUIDE.md`.

Сниффинг Recorder:

```powershell
.\Mic140ProtocolDebugCli.exe --proxy 4001
# Recorder → 127.0.0.1:4001, лог в Data/captures/
```

Эталон: `Data/mic140_adc_reference.txt` (дамп Recorder 2026-06-22, допуск **±50**).

## API (Mic140Example)

```pascal
Cfg := Mic140ConfigFromDebug(Mic140DebugDefaultConfig);
Dev := TMic140Device.Create(Cfg);
Dev.Connect; Dev.Setup(Cfg); Dev.Start;
```

GUI и CLI используют `TMic140Device` + `Mic140ConfigFromDebug` для единого конфига.

## Каталоги

| Каталог | Содержание |
|---------|------------|
| `stubs/` | заглушки Recorder-интерфейсов |
| `Driver/` | shadow MIC140v2 + `utils/` |
| `Data/` | эталон ADC |
| `old/` | устаревшие копии (backup) |

Документация: `Docs/devices/mic140/protocol/`.
