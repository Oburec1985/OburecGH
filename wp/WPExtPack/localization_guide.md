# Руководство по локализации (dxgettext) в Delphi

## 1. Необходимые утилиты

Для работы требуется комбинация двух систем утилит:

### A) dxgettext (Оригинальная)
**Зачем нужна:** Умеет правильно парсить исходники Delphi (`.pas`, `.dpr`, `.dfm`) и извлекать из них строки, свойство `Caption`, `Hint` и т.д.
**Где взять:** Оригинальный установщик версии 1.2.2.
**Критически важно:** При запуске сканирования **обязательно** использовать флаг `--nonascii`, иначе кириллические строки будут проигнорированы.

### B) Современный GNU Gettext (msgfmt и msgcat)
**Зачем нужны:**
*   `msgfmt.exe` — для компиляции текстовых переводов (`.po`) в бинарный формат (`.mo`).
*   `msgcat.exe` — для консолидации (объединения) нескольких `.po` файлов в один. Это критически важно, если вы собираете строки из разных источников (например, PAS и DFM) разными инструментами.
**Зачем менять:** Старые версии из комплекта dxgettext часто зависают или работают некорректно с современными кодировками.
**Где взять:** В проекте уже есть актуальная сборка в каталоге: `c:\Oburec\OburecGH\sharedUtils\utils\locTools\`.

---

## 2. Процесс локализации

Процесс состоит из трёх шагов: **Сбор (Extract) -> Перевод -> Компиляция**.

### Шаг 1: Создание/Обновление ресурсов (Сбор строк)
Сбор выполняется из командной строки в корневой папке проекта.
```cmd
"C:\Program Files (x86)\dxgettext\dxgettext.exe" --delphi -b . -o locale\en\LC_MESSAGES\ --nonascii
```
- `--nonascii` — **обязателен** для поддержки русского языка.
- Сгенерированный файл: `locale\en\LC_MESSAGES\default.po`.

### Шаг 2: Перевод ресурсов
Откройте `default.po` в текстовом редакторе. Найдите `msgid` с русским текстом и впишите перевод в `msgstr`:
```po
msgid "Привет"
msgstr "Hello"
```

### Шаг 3: Компиляция ресурсов (.po -> .mo)
```cmd
"c:\Oburec\OburecGH\sharedUtils\utils\locTools\msgfmt.exe" -o locale\en\LC_MESSAGES\default.mo locale\en\LC_MESSAGES\default.po
```
Приложение читает только файл `.mo`.

### Шаг 4: Консолидация (опционально, при сборе из разных источников)
Если у вас есть два файла (например, `main.po` и `dfm.po`), их можно слить в один:
```cmd
"c:\Oburec\OburecGH\sharedUtils\utils\locTools\msgcat.exe" --use-first main.po dfm.po -o result.po
```
Флаг `--use-first` означает, что при дубликатах будет взят перевод из первого файла.

---

## 3. Размещение файлов (Структура)

Программа ищет переводы по пути:
`<папка_exe>\locale\<код_языка>\LC_MESSAGES\<домен>.mo`

Пример:
`...\TestDAC\locale\en\LC_MESSAGES\default.mo`

---

## 4. Настройка проекта Delphi

### В главном файле проекта (.dpr)
```pascal
begin
  Application.Initialize;
  
  // Указываем имя файла .mo (без расширения)
  textdomain('default'); 
  // Включаем поддержку домена для ResourceStrings
  AddDomainForResourceString('default'); 
  // Выбираем язык (имя папки в locale\)
  UseLanguage('en');
  
  Application.CreateForm(TDACFrm, DACFrm);
  Application.Run;
end.
```

### Архитектурная рекомендация (Авто-перевод форм)
Чтобы не писать `TranslateComponent(Self)` в каждой форме, используйте базовый класс:

```pascal
type
  TBaseTranslatedForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  end;

procedure TBaseTranslatedForm.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self);
end;
```
Наследуйте все формы проекта от `TBaseTranslatedForm`.

---

## 5. Вспомогательные скрипты (батники)

### extract_po.bat (Сбор)
```batch
@echo off
set DXGETTEXT="C:\Program Files (x86)\dxgettext\dxgettext.exe"
set OUT_DIR=locale\en\LC_MESSAGES
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
%DXGETTEXT% --delphi -b . -o "%OUT_DIR%"\ --nonascii
pause
```

### compile_mo.bat (Компиляция)
```batch
@echo off
set MSGFMT="c:\Oburec\OburecGH\sharedUtils\utils\locTools\msgfmt.exe"
set PO_FILE=locale\en\LC_MESSAGES\default.po
set MO_FILE=locale\en\LC_MESSAGES\default.mo
echo Compiling %PO_FILE%...
%MSGFMT% -o "%MO_FILE%" "%PO_FILE%"
pause
```
