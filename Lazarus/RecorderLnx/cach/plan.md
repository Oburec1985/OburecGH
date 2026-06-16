# План доработок: исправление диалогов и логирование

- [x] Исправление диалогов (вопросики) и параметров настройки тегов
  - [x] Обернуть пункт меню 'Настроить выделенные каналы...' в uMainForm.pas в CP1251ToUTF8
  - [x] Переформатировать uRecorderSettingsDialog.pas в CP1251, прописать codepage и перекодировать текст в CP1251ToUTF8
  - [x] Переформатировать uTagSettingsDialog.pas в CP1251, прописать codepage и перекодировать текст в CP1251ToUTF8
  - [x] Переформатировать uComponentSettingsDialog.pas в CP1251, прописать codepage и перекодировать текст в CP1251ToUTF8

- [x] Расчет размера блока/порции оценок в порции отсчетов (как в оригинальном Recorder)
  - [x] Передавать ADataUpdateMs в параметр ShowTagSettingsDialog и поле fDataUpdateMs в TTagSettingsDialog
  - [x] Пересчитывать в соответствии расчетный размер порции в LoadFromTags (если PortionLength = 17280)
  - [x] Возвращать значение 17280 в StoreToTags, если контролируемое значение для авто совпадает расчетному
  - [x] Передать fRunSettings.DataUpdateMs при вызове ShowTagSettingsDialog из uMainForm.pas
  - [x] Исправить баг инициализации fDataUpdateMs (передача в конструктор CreateDialog и считывание с формы настроек в uRecorderSettingsDialog.pas)

- [x] Кроссплатформенный логгер производительности (Windows / Linux)
  - [x] Включить глобальное логирование в uRecorderDebugLog.pas
  - [x] Настроить динамический путь к файлу лога (LogWindows.log / LogLinux.log) в каталоге ParamStr(0)
  - [x] Очищать лог-файл при запуске программы

- [ ] Анализ логов производительности после 10-секундного запуска под Windows и Linux
