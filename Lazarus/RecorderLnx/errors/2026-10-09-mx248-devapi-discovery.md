# MX-248: DevAPI возвращал пустой список

## Симптом

На MIC-315 (`192.168.15.84`) Windows и оригинальный Recorder видели MX-248,
но RecorderLnx получал от x86 bridge успешный код DevAPI и ноль устройств.

## Исходная информация

- Оригинальный сценарий UI: `D:\works\windev-v3.9\rc_guisrv\setup\HardwareConfigPP.cpp`,
  `SearchAndLinkDevices` — `SystemConfigChanged`, `SearchDevices`, затем
  `GetAllDevices`/`GetAllSearchDevices`.
- Загрузка device DLL без передачи ошибки наружу:
  `D:\works\windev-v3.9\devapi\DevAPI.cpp`, `InitDLLs` и `SearchDevices`.
- Поиск современных PCI-плат и чтение subsystem ID:
  `D:\works\windev-v3.9\mdprotocol\PciTools.cpp`, `SearchDeviceExt`.
- Регистрация MX-248 и её `pFinder`:
  `D:\works\windev-v3.9\mx224v14\mx224v14app.cpp`.

## Диагностика

Windows PnP подтверждал исправную плату `VEN_1945&DEV_6200`, subsystem
`614D`, драйвер `WinDriver1411` 14.1.1.0, PCI 2/14/0. DevAPI регистрировал
тип `0x614D`, но не находил экземпляр.

Причина — неполный и смешанный private DLL stack. `MDProtocol.dll` имеет
неявные обязательные импорты `FTD2XX.dll`, `mfc90.dll`, `msvcp90.dll` и
`msvcr90.dll`. При их отсутствии Windows не загружала MDProtocol/mx224v14,
а `DevAPI.InitDLLs` молча продолжал работу. Поэтому наружу возвращались
`search_rc=0` и `total=0`, что ошибочно выглядело как отсутствие платы.

## Исправление и ограничения

- В `Device/PXI/MX248/Vendor/Win32` хранится единый проверенный x86 stack;
  его нельзя смешивать с DLL другого Recorder.
- `manifest.sha256` обязателен при сборке installer payload.
- Discovery имеет отдельный таймаут 30 секунд: реальный PCI scan занимает
  больше обычного IPC timeout 5 секунд.
- Bridge следует оригинальной последовательности и логирует регистрацию,
  найденные экземпляры, аппаратные `Reset`, identity и `Test` через
  `RECORDER_MX248_LOG`.
- PnP fallback используется только для диагностики/видимости платы, если
  legacy DevAPI скрыл ошибку. Рабочим результатом считается только успешный
  DevAPI `Reset` и `Test`; один PnP-узел не доказывает готовность сбора.
- Инициализация выполняется на стадии `Initialize`, а не при discovery.

## Проверка

На установленном RecorderLnx 0.1.157 из приватной папки приложения выполнены:

```text
SearchDevices:  code 0, count 1
MX-248:         s/n 3253, revision 1, PCI 2/14
CreateDeviceH:  code 0
Reset:          code 0
Get identity:   s/n 3253, revision 1
DevAPI.Test:    code 0
```

Аппаратный лог: `C:\Mera Files\screens\mx248-installed-0157.log` на MIC-315.

