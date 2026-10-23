# Исходники OPC UA для RecorderLnx

Это копия исходников из `RecorderLnx`, собранная для просмотра и передачи.
Рабочие файлы проекта не перемещались.

- `Device/OPC` — клиент OPC UA, UA Binary, модели, datasource, factory и форма редактора (`.pas` + `.lfm`).
- `Integration/Device` и `Integration/UI` — полные модули RecorderLnx с точками подключения OPC UA; они используют остальные модули основного приложения и отдельно не компилируются.
- `Integration/Core` и `Integration/SharedUtils` — общие сетевые и журналирующие зависимости OPC UA-клиента.
- `Integration/Project` — снимки `.lpi` и `.lpr` с регистрацией OPC UA в основном приложении; это не автономный проект.
- `Tests/OpcUaProtocolDebug_Codex` — исходник сетевой probe-программы. Для отдельной сборки нужны FPC/Lazarus и соответствующие вспомогательные units RecorderLnx.
- `Docs` — архитектура OPC UA, список незавершённых возможностей и схема datasource.

Основной обзор: `Device/OPC/README.md`. Архитектура и список того, чего пока не хватает: `Docs/ARCHITECTURE.md` и `Docs/MISSING.md`.

Скомпилированные `.o`/`.ppu`, старые резервные копии и пустой каталог `native/third_party/open62541` не копировались: приложение их не использует как исходники OPC UA. Основные модули и формы взяты из актуального `RecorderLnx/Device/OPC`.
