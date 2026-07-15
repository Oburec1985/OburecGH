# Selected Mera channels appeared as available and disappeared

## Симптом

Каналы виртуального Mera-источника одновременно отображались в выбранных и доступных,
а после `OK` виртуальные теги исчезали.

## Причина

`RecorderSignalConfiguredSourceId` считал любой непустой `TMeraSignalInfo.FileName` аппаратным
`SourceId`. Для сигналов, загруженных из Mera-дескриптора, это не является признаком
владельца. Поиск тега по паре `SourceId + Address` выполнялся с неверным `SourceId`.

## Исправление

- Для сигналов группы Mera владелец выбирается по фактической группе, а не по `FileName`.
- Добавлена единая адресация по индексу источника в аппаратном дереве.
- Mera playback сопоставляет сырой адрес файла с его tree-indexed адресом тега.

## Проверка

`lazbuild -B RecorderLnx.lpi`: OK, exit code 0.
