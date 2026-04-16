# План локализации WPExtPack (dxgettext)

- [x] Исследование `gnugettext.pas` и его совместимости с D2010 (DLL режим)
- [/] Настройка `WPExtPack.dpr`: инициализация `DefaultInstance`, `bindtextdomain`, `UseLanguage('en')` (проверено, требует уточнения пути)
- [x] Создание `uLocalizationHelper.pas` для автоматизации `TranslateComponent`
- [x] Обновление основных форм проекта для вызова локализации (в процессе)
- [x] Исправление ошибок инъекции конструкторов в не-форменные классы (uFFTInverseFrm, uCorrectUTS, uEditSelsinFrm, uKBHMFrm)
- [x] Исправление синтаксических ошибок в uses-секциях (uTrigLvlEditFrm, uCyclogramRepFrm, uCounterFrm)
- [ ] Подготовка структуры каталогов `locale\en\LC_MESSAGES\` и компиляция `.mo`
- [ ] Тестирование с тестовым `.mo` файлом (English)
