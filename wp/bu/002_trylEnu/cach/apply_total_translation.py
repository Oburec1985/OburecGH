import os
import re

def translate_project():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file):
        print(f"Error: {po_file} not found")
        return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Dictionary of technical translations
    dictionary = {
        # Common UI
        'Добавить': 'Add',
        'Удалить': 'Delete',
        'Применить': 'Apply',
        'Отмена': 'Cancel',
        'Ок': 'OK',
        'Закрыть': 'Close',
        'Справка': 'Help',
        'Настройка': 'Settings',
        'Обнулить': 'Reset',
        'Вычислить': 'Calculate',
        'Помощь': 'Help',
        'Открыть': 'Open',
        'Сохранить': 'Save',
        'Имя': 'Name',
        'Значение': 'Value',
        'Статус': 'Status',
        'Информация': 'Information',
        'Путь': 'Path',
        'Файл': 'File',
        'Папка': 'Folder',
        'Выбор': 'Selection',
        'Все': 'All',
        'Тип': 'Type',
        'Параметры': 'Parameters',
        'Свойства': 'Properties',
        'Готово': 'Done',
        
        # Measurements & Signals
        'Замер': 'Measurement',
        'Замеры': 'Measurements',
        'Сигнал': 'Signal',
        'Сигналы': 'Signals',
        'Канал': 'Channel',
        'Каналы': 'Channels',
        'Датчик': 'Sensor',
        'Частота': 'Frequency',
        'Амплитуда': 'Amplitude',
        'Чувствительность': 'Sensitivity',
        'Смещение': 'Offset',
        'Коэффициент': 'Coefficient',
        'Фаза': 'Phase',
        'Период': 'Period',
        'Время': 'Time',
        'Длительность': 'Duration',
        'Длина': 'Length',
        'Шаг': 'Step',
        'Номер': 'Number',
        'Количество': 'Count',
        'Счетчик': 'Counter',
        'Порция': 'Portion',
        'Размер': 'Size',
        'Предел': 'Limit',
        'Порог': 'Threshold',
        'Диапазон': 'Range',
        'Масштаб': 'Scale',
        'Единицы': 'Units',
        'Разрядность': 'Bit depth',
        'Частота дискретизации': 'Sampling rate',
        
        # Math & Data Processing
        'БПФ': 'FFT',
        'МНК': 'LSM',
        'Среднее': 'Average',
        'Максимум': 'Maximum',
        'Минимум': 'Minimum',
        'Пик': 'Peak',
        'Спектр': 'Spectrum',
        'Интеграл': 'Integral',
        'Производная': 'Derivative',
        'Тренд': 'Trend',
        'Шум': 'Noise',
        'Фильтр': 'Filter',
        'Фильтрация': 'Filtering',
        'Полином': 'Polynomial',
        'Степень': 'Degree',
        'Порядок': 'Order',
        'Аппроксимация': 'Approximation',
        'Отклонение': 'Deviation',
        'Погрешность': 'Error',
        'Корреляция': 'Correlation',
        'Регрессия': 'Regression',
        'Гармоника': 'Harmonic',
        'Фронт': 'Rising edge',
        'Спад': 'Falling edge',
        
        # Graphs & UI Elements
        'График': 'Graph',
        'Диаграмма': 'Chart',
        'Легенда': 'Legend',
        'Ось': 'Axis',
        'Сетка': 'Grid',
        'Курсор': 'Cursor',
        'Курсоры': 'Cursors',
        'Метки': 'Tags',
        'Цвет': 'Color',
        'Линия': 'Line',
        'Точка': 'Point',
        'Вид': 'View',
        'Окно': 'Window',
        'Панель': 'Panel',
        'Вкладка': 'Tab',
        
        # Reports
        'Отчет': 'Report',
        'Шаблон': 'Template',
        'Экспорт': 'Export',
        'Импорт': 'Import',
        'Печать': 'Print',
        'Лист': 'Sheet',
        'Ячейка': 'Cell',
        'Таблица': 'Table',
        
        # States & Logic
        'Включено': 'Enabled',
        'Выключено': 'Disabled',
        'Ошибка': 'Error',
        'Предупреждение': 'Warning',
        'Внимание': 'Caution',
        'Успешно': 'Success',
        'Выполняется': 'Processing',
        'Остановка': 'Stop',
        'Старт': 'Start',
        'Пауза': 'Pause',
        'Продолжить': 'Continue',
        
        # Specific phrases found in extraction
        '1-й проход': '1st pass',
        '2-й проход': '2nd pass',
        'setup ': 'Setup ',
        'Настройка фильтра': 'Filter settings',
        'Коррекция времени': 'Time correction',
        'Перечень замеров': 'Measurement list',
        'Результат': 'Result',
        'Плагин пакетной обработки': 'Batch Processing Plugin',
        'Дополнения': 'Add-ons',
        'Графика': 'Graphics',
        'Триггеры': 'Triggers',
        'Журнал': 'Log',
        'Загрузить': 'Load',
        'Список обработок': 'Processings List',
        'Источники сигналов': 'Signal Sources',
        'Обрабатываемые сигналы': 'Processed Signals',
        'Источники операторов': 'Operator Sources',
        'Свой...': 'Custom...',
        'Оператор': 'Operator',
        'Параметры': 'Parameters'
    }

    # Helper function to translate technical text fragments
    def technical_translate(text):
        if text in dictionary:
            return dictionary[text]
        
        # Try some heuristics
        res = text
        for ru, en in dictionary.items():
            # Whole word replacement for common terms
            res = re.sub(r'\b' + ru + r'\b', en, res)
            
        return res

    # Final replacement logic
    def replace_func(match):
        mid = match.group(1)
        mstr = match.group(2)
        
        # If already translated, keep it
        if mstr.strip():
            return match.group(0)
            
        trans = technical_translate(mid)
        # Handle cases where multiple lines might be present (simplified for now)
        if trans != mid:
            return f'msgid "{mid}"\nmsgstr "{trans}"'
        else:
            return match.group(0)

    # Improved regex to capture both msgid and msgstr
    pattern = re.compile(r'msgid\s+"((?:[^"]|\\")*)"\s*msgstr\s+"((?:[^"]|\\")*)"', re.DOTALL)
    new_content = pattern.sub(replace_func, content)
    
    with open(po_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
        
    print(f"Translation finalized in {po_file}")

if __name__ == "__main__":
    translate_project()
