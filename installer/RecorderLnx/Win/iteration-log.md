# Журнал итераций Windows-инсталлятора RecorderLnx

## 2026-10-09 — целостный MX-248 vendor payload

- `collect-files.bat` теперь кладёт в структурированный payload полный
  аппаратно проверенный closure DevAPI/MDProtocol/mx224v14 и private VC90.
- `build-installer.ps1` по умолчанию берёт vendor stack из репозитория и
  проверяет SHA-256/PE x86; внешний каталог остаётся явным override.
- Собран и установлен `RecorderLnx-Setup-0.1.157.exe`; installed-layout
  hardware smoke на MIC-315 прошёл discovery/reset/identity/test.
- Для случая открытого CHM добавлен явный `-SkipLuaHelpBuild`; существующий
  проверенный CHM всё равно обязателен и попадает в payload.

## 2026-10-09 — MX-248 discovery/link, установщик 0.1.151

**Запрос:** включить завершённый автопоиск MX-248 и диалог привязки ручного
узла в переносимый Windows installer.

**Сделано:** полный `build-installer.ps1` пересобрал RecorderLnx, Win32 bridge,
HostAgent, плагины и CHM; `collect-files.bat` заново сформировал структурный
`files`, включая BIOS, ресурсы, x86 DevAPI DLL и VC++ runtime. Inno Setup собрал
`Output/RecorderLnx-Setup-0.1.151.exe`.

**Проверено:** bridge protocol/ABI/process smoke, Win64 forced build, transport
discovery test и settings-link smoke прошли. Размер installer 23 578 877 байт,
SHA-256 `4CDF032B63B61562F1684366769D675674C2E300499CA95620302085795B4763`.

**Документация:**
`Lazarus/RecorderLnx/Device/PXI/MX248/Docs/README.md`.

## 2026-10-09 — единый staging-каталог files

**Запрос:** Inno Setup должен брать весь payload из `Win\files`, а отдельный
батник — автоматически собирать туда EXE, ресурсы, DLL, BIOS и конфигурации с
сохранением структуры каталогов.

**Сделано:** добавлен `collect-files.bat` с полным пересозданием дерева
`files\{app,mera-files,redist,setup}`. `RecorderLnx.iss` больше не обращается к
Lazarus tree, Program Files или Package Cache. `build-installer.ps1` вызывает
сборщик и запускает installed-layout MX-248 smoke непосредственно из `files`.

**Проверка:** батник сформировал 29 файлов с ожидаемой структурой; все `Source`
в `.iss` ссылаются на `files`; MX-248 process smoke из staged bridge прошёл.
Inno Setup собрал `Output/RecorderLnx-Setup-0.1.149-mx248final4.exe`. Полный
build script дошёл до CHM и остановился, потому что открытый Windows Help держал
готовый файл; для упаковки использован существующий проверенный CHM.

**Статус:** готово; staging и установщик собраны.

## 2026-10-09 — перенос MX-248 в Device/PXI/MX248 и финальная упаковка

**Запрос:** привести каталог драйвера к иерархии `Device/PXI/MX248`, обновить
инсталлятор и подготовить переносимый установочный файл.

**Сделано:** пути bridge, manifest и process-smoke переведены на новую
иерархию. Исправлены относительные пути тестовых проектов. Structured DevAPI
error больше не разрушает здоровую IPC-сессию; ошибка framing оставляет сессию
потерянной до явного `Disconnect`/`Connect`. Inno Setup упаковывает x86 bridge,
десять private vendor DLL и VC++ x86 runtime.

**Проверка:** core/runtime/UI/codec/Windows transport tests, чистая сборка
RecorderLnx, bridge protocol/ABI/process smoke и полный
`build-installer.ps1 -Version 0.1.149-mx248final3` — успешно.

**Результат:** `Output/RecorderLnx-Setup-0.1.149-mx248final3.exe` готов для
переноса на флешке. Аппаратный smoke MX-248 на целевой станции ещё требуется.

## 2026-10-09 — MX-248 bridge включён в установщик

**Запрос:** Доставлять готовый x86 bridge вместе с DevAPI runtime и проверять
его до упаковки.

**Сделано:** bridge принудительно собирается DCC32, проходит protocol и ABI
smoke, проверяется как PE x86 и устанавливается рядом с десятью private DLL в
`{app}\mx248\vendor`. При upgrade/uninstall останавливается exact image bridge.
Архитектура: `Lazarus/RecorderLnx/Device/PXI/MX248/Docs/README.md`.

**Проверка:** bounded installed-layout process smoke и
`build-installer.ps1 -Version 0.1.149-mx248final2` — успешно; создан
`Output/RecorderLnx-Setup-0.1.149-mx248final2.exe`.

**Статус:** software packaging готов; фактическая установка и hardware smoke
не выполнялись.

## 2026-10-09 — x86 DevAPI-комплект PXI MX-248

**Запрос:** Включить необходимые DLL будущей Windows-обёртки MX-248 в Inno
Setup и подготовить воспроизводимую проверку комплекта.

**Сделано:** `build-installer.ps1` принимает единый `VendorDevApiDir`, проверяет
полный комплект из десяти vendor DLL, их PE x86 и SHA-256 по закреплённому
manifest. Скрипт принимает или автоматически находит официальный
`VC_redist.x86.exe` и также проверяет его архитектуру и SHA-256. Inno Setup
устанавливает DLL изолированно в `{app}\mx248\vendor`, а redistributable
запускает в quiet/norestart режиме. Архитектура и первоисточники:
`Lazarus/RecorderLnx/Device/PXI/MX248/Docs/README.md`.

**Проверка:** `build-installer.ps1 -Version 0.1.149-mx248doc2` завершён успешно;
forced-сборки RecorderLnx, RecorderHostAgent и plugins прошли, Inno Setup 7
создал `Output/RecorderLnx-Setup-0.1.149-mx248doc2.exe` и включил десять DLL и
`VC_redist.x86.exe`. Фактическая установка не запускалась, чтобы не менять
автозапуск, firewall и системный VC runtime рабочей машины.

**Статус:** упаковка vendor runtime готова; x86 bridge ещё не реализован.

## 2026-09-11 11:23 — agent рядом с RecorderLnx.exe

**Запрос:** Синхронизировать Windows launcher в output RecorderLnx и брать его оттуда при упаковке.

**Сделано:** после сборки agent installer-build запускает общий sync-script; Inno Setup source изменён на `RecorderLnx/lib/x86_64-win64/RecorderHostAgent.exe`.

**Проверка:** копирование выполнено, SHA-256 исходного и соседнего EXE совпадает.

**Статус:** готово.

## 2026-09-11 — RecorderHostAgent в составе установки

**Запрос:** включить Windows-агент управления хостом в установщик RecorderLnx и обеспечить его фоновый автозапуск, безопасное обновление и удаление.

**Сделано:** установщик включает RecorderHostAgent, создаёт сохраняемый INI рядом с EXE, регистрирует HKLM Run и правило TCP 8766; upgrade/uninstall останавливают только процесс агента. Сборочный скрипт теперь пересобирает оба проекта.

**Проверка:** forced-сборки RecorderLnx и RecorderHostAgent — OK; Inno Setup 7 — successful compile без предупреждений, агент включён в архив.

**Статус:** готово; фактическая установка не запускалась, чтобы не менять автозапуск и firewall рабочей системы.
