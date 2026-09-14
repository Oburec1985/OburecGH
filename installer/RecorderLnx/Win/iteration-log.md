# Журнал итераций Windows-инсталлятора RecorderLnx

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
