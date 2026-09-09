# Документация проекта MIC-140

Основной обзор архитектуры и точек расширения:

- [Архитектура проекта](architecture-overview.md) — слои, владение, потоки,
  жизненный цикл и масштабирование на новые устройства, обработки и виды
  отображения.

Подробные документы отдельных подсистем:

- [Протокол MIC-140](devices/mic140-protocol.md) — Search, Connect, Initialize,
  Configure, Play, Stop и Disconnect;
- [Поддержка MIC-183/185](devices/mic185.md);
- [Модель обновления визуальных компонентов](architecture/visual-update-model.md);
- [Архитектура блочного хранилища](architecture/block-manager-task-card.md);
- [ТЗ: источники данных и единая временная база](architecture/data-source-timebase-task-card.md)
  — короткий пример, общий блок, UTS/Start, lifecycle, runtime и критерии
  совместимости с Recorder/WinПОС;
- [Правила команды разработки](architecture/development-team.md).

Журнал выполненных итераций находится в корне проекта:
[iteration-log.md](../iteration-log.md).
