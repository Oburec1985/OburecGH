# План разработки plgCalibratorPascal

- [x] Изучить примеры plgControlCyclogram и elmetraPascal_пример
- [x] Спроектировать архитектуру плагина и алгоритм CRC Elmetra
- [x] Создать скелет DLL plgCalibratorPascal.dpr
- [x] Реализовать модуль uCreateComponents.pas
- [x] Реализовать фоновый поток uCalibratorThread.pas
- [x] Реализовать форму настройки uFrmSettings.pas/.dfm
- [x] Написать и запустить тесты TestPascalProtocol.dpr
- [x] Скомпилировать итоговую DLL с помощью Delphi 2010
- [x] Обеспечить собираемость проекта в IDE CodeGear 2010 (настроить dproj)
- [x] Локализовать PluginClass и uCompMng, переименовать в uCalibratorPluginClass/uCalibratorCompMng и очистить от лишнего
- [x] Полностью убрать cCompMng и отвязаться от зависимостей
