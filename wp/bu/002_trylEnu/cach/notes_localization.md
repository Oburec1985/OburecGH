# Заметки по локализации WPExtPack

## Почему dxgettext (gnugettext.pas)?
- Стандартный Resource DLL Wizard в Delphi часто глючит в COM DLL, если хост-приложение (Winpos) не умеет правильно переключать `HInstance`.
- `dxgettext` переводит компоненты "на лету" (в `OnCreate`), что не зависит от ресурсов Windows так сильно.
- Легко править переводы в `.po` файлах без перекомпиляции ресурсов.

## Особенности DLL
- `ExecutableFilename` в `gnugettext.pas` по умолчанию `ParamStr(0)` (это `.exe`). Для DLL нужно принудительно выставить путь к `.dll`, чтобы он искал `.mo` файлы рядом с ней.
- Инициализация должна быть в секции `begin...end` проекта `WPExtPack.dpr`.

## План по принудительному английскому
- Если нужно форсировать English, вызовем `UseLanguage('en')` сразу после `bindtextdomain`.
