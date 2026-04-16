import os
import re

def final_translate():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file):
        print(f"Error: {po_file} not found")
        return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # THE MEGA DICTIONARY (Consolidated and expanded)
    # Mapping of Russian technical terms to context-aware English
    d = {
        # Form: Batch Processing (Плагин пакетной обработки)
        'Плагин пакетной обработки': 'Batch Processing Plugin',
        'Дополнения': 'Add-ons',
        'Графика': 'Graphics',
        'Триггеры': 'Triggers',
        'Журнал': 'Log',
        'Список обработок': 'Processings List',
        'Источники сигналов': 'Signal Sources',
        'Обрабатываемые сигналы': 'Processed Signals',
        'Источники операторов': 'Operator Sources',
        'Оператор': 'Operator',
        'Загрузить': 'Load',
        'Свой...': 'Custom...',
        
        # Form: Time Correction (Коррекция времени)
        'Коррекция времени': 'Time Correction',
        'Добавить': 'Add',
        'Удалить': 'Delete',
        'Перечень замеров': 'Measurements list',
        'Корректируемые UTS сигналы:': 'Adjustable UTS signals:',
        'Определить сдвиг в каждом замере по имени канала': 'Determine offset in each measurement by channel name',
        'Сигнал \"Начало отсчета\":': 'Signal \"Start point\":',
        'Распаковка СИКОН': 'SIKON Unpacking',
        'Пороговое значение': 'Threshold',
        'Время испытания': 'Test time',
        'Обнулить': 'Reset',
        'Фронт': 'Rising',
        'Спад': 'Falling',
        'Сдвигать сигналы без UTS': 'Shift signals without UTS',
        'Поправка времени, с': 'Time offset, s',
        'Номер срабатывания': 'Trigger number',
        'Вычислить': 'Calculate',
        'Учитывать время старта испытания': 'Use test start time',
        'Применить': 'Apply',
        'Отмена': 'Cancel',
        
        # Form: Hilbert Filter (Настройка фильтра)
        'Настройка фильтра': 'Filter Settings',
        'Число точек': 'Number of points',
        'Число блоков': 'Number of blocks',
        'Размер порции, с': 'Portion size, s',
        'Имя расширения': 'Extension name',
        
        # General Technical / Units
        'Замер': 'Measurement',
        'Замеры': 'Measurements',
        'Сигнал': 'Signal',
        'Сигналы': 'Signals',
        'Канал': 'Channel',
        'Частота': 'Frequency',
        'Амплитуда': 'Amplitude',
        'Чувствительность': 'Sensitivity',
        'Смещение': 'Offset',
        'Фаза': 'Phase',
        'Период': 'Period',
        'Время': 'Time',
        'секунд': 'seconds',
        'Гц': 'Hz',
        'м/с': 'm/s',
        'об/мин': 'rpm',
        'мс': 'msec',
        'мин': 'min',
        'час': 'hour',
        
        # Math & Processing
        'БПФ': 'FFT',
        'МНК': 'LSM',
        'Среднее': 'Average',
        'Максимум': 'Maximum',
        'Минимум': 'Minimum',
        'Пик': 'Peak',
        'Спектр': 'Spectrum',
        'Тренд': 'Trend',
        'Шум': 'Noise',
        'Полином': 'Polynomial',
        'Аппроксимация': 'Approximation',
        'Коэффициент': 'Coefficient',
        
        # Common UI & Buttons
        'Ок': 'OK',
        'Закрыть': 'Close',
        'Настройка': 'Settings',
        'Свойства': 'Properties',
        'Параметры': 'Parameters',
        'Путь': 'Path',
        'Открыть': 'Open',
        'Сохранить': 'Save',
        'Выход': 'Exit',
        'Инфо': 'Info',
        'Информация': 'Information',
        'Ошибка': 'Error',
        'Предупреждение': 'Warning',
        'Готово': 'Done',
        'Старт': 'Start',
        'Стоп': 'Stop',
        'Пазуа': 'Pause',
        
        # Context-specific terms from the strings list
        '1-й проход.': '1st pass.',
        '2-й проход.': '2nd pass.',
        'setup ': 'Setup ',
        'Поправка времени': 'Time offset',
        'Начало отсчета': 'Start point',
        'Имя': 'Name',
        'Значение': 'Value',
        'Тип': 'Type',
        'Группа': 'Group'
    }

    # Internal helper for complex replacements
    def translate_text(text):
        if text in d: return d[text]
        # Partial match for common prefixes
        for ru, en in d.items():
            if text.startswith(ru + ' '):
                return text.replace(ru, en, 1)
        return text

    def replace_match(match):
        mid = match.group(1)
        mstr = match.group(2)
        
        # If already translated, just return as is
        if mstr.strip():
            return match.group(0)
            
        trans = translate_text(mid)
        if trans != mid:
            return f'msgid "{mid}"\nmsgstr "{trans}"'
        else:
            # If no direct match, try a very basic word-by-word if important
            return match.group(0)

    # Use a safe iteration over all msgid blocks
    pattern = re.compile(r'msgid\s+"((?:[^"]|\\")*)"\s*msgstr\s+"((?:[^"]|\\")*)"', re.DOTALL)
    new_content = pattern.sub(replace_match, content)
    
    with open(po_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
        
    print(f"Finalized global translation in {po_file}")

if __name__ == "__main__":
    final_translate()
