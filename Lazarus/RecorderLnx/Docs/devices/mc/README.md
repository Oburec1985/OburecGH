# MC Crate Controllers and Modules

This directory collects notes for MC crate controllers and MC modules used by
RecorderLnx protocol/debug work.

## Documents

| File | Contents |
| --- | --- |
| [mc201.md](mc201.md) | MC-201 module identification, channel settings, frequency grid, and current test-stand assumptions |
| [recorderlnx-integration.md](recorderlnx-integration.md) | Рабочая архитектура MCbus в RecorderLnx: конфигурация, дерево, Preview, формат потока, тесты и осциллограмма |

## Current Test Stand

The active debug stand is an Ethernet MC crate controller with four MC-201
modules. RecorderLnx has a standalone test project:

```powershell
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi
```

Run without parameters to open GUI. Use `--cli` for the console scanner.
