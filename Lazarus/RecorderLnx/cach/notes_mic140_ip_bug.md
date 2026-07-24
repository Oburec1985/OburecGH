# Заметки: ошибка при смене IP-адреса MIC-140

## Промпт:
при попытке поменять ip у mic-140 в настройках узла сбора данных происходит ошибка

## Анализ:
При переименовании источника данных в `TRecorderSettingsDialog.ApplyConfiguredSourceChange` (файл `uRecorderSettingsDialog.pas`) отсутствует перенос тегов и конфигурации для прибора MIC-140 (хотя для MIC-185 и MC-032 такой перенос есть).
В результате:
- Конфигурация `TRecorderMic140SourceConfig` для нового IP-адреса возвращает `nil`.
- Программа пытается обратиться к методам `EnsureChannelCapacity` или `SetChannelSettings` на `nil`-объекте конфигурации, что приводит к Access Violation.
- Старые теги остаются привязанными к старому IP-адресу.

## Решение:
В `TRecorderSettingsDialog.ApplyConfiguredSourceChange` для случая MIC-140 добавить логику:
- Поиск старой конфигурации в `fRecorder.TagRegistry.SourceSpecificConfigs` и изменение её ключа на новое имя `ANewSourceId`.
- Перенос привязанных тегов: `lTag.SourceId := ANewSourceId`.
- Регистрация нового источника в качестве активного и разрегистрация старого.
- Удаление старого `SourceId` из общего списка источников и гарантирование наличия нового.
