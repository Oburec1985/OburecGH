# Ошибочные зависимости исходной циклограммы

- Симптом: Delphi 2010 F1026 File not found: PlgClass.dcu, plgControlCyclogram.dpr(265).
- Факты: DPR и DPROJ ссылались на отсутствующие plgCalibratorPascal/units/PlgClass.pas и uCompMng.pas. Нужный TExtRecorderPack объявлен в SharedRUnits/PluginClass.pas; общий uCompMng также находится в SharedRUnits.
- Отвергнуто: подключение uCalibratorPluginClass — это другой плагин с TCalPascalPlg, не замена класса циклограммы. Пользователь подтвердил: оригинал был образцом для отдельного проекта.
- Исправление: две ссылки в DPR и две в DPROJ направлены на общие модули. Поведение процедур не менялось; DPR сохранён в Windows-1251.
- Проверка: полный Rebuild Debug/Win32 Delphi 2010, exit code 0, DLL 16924953 байта; build-codex/debug-build.log. Установленный плагин не заменялся. Runtime не проверен.
- Среда: для локальной сборки переопределены DCC_ExeOutput, DCC_DcuOutput и DCC_DependencyCheckOutputName, иначе Clean обращается к установленной DLL. Дубликаты Path/PATH устранены только в окружении дочернего процесса. Запись DRC потребовала сборки вне песочницы.
- Предотвращение: см. ../development-rules.md; оригинальный пример должен оставаться независимым от производного проекта.
