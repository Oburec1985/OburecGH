import os
import re

def mega_translate():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file):
        print(f"Error: {po_file} not found")
        return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # CORE TECHNICAL DICTIONARY
    d = {
        # Form: Zero Balancing (Балансировка нуля)
        'Балансировка нуля': 'Zero Balancing',
        'Начало': 'Start',
        'Конец': 'End',
        'Список сигналов': 'Signals list',
        ',сек': ',s',
        ', сек': ',s',
        
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
        'Информация': 'Information',
        'Ошибка': 'Error',
        'Предупреждение': 'Warning',
        'Готово': 'Done',
        'Старт': 'Start',
        'Стоп': 'Stop',
        'Пауза': 'Pause',
        
        # Technical Terms
        'Замер': 'Measurement',
        'Сигнал': 'Signal',
        'Канал': 'Channel',
        'Частота': 'Frequency',
        'Амплитуда': 'Amplitude',
        'Чувствительность': 'Sensitivity',
        'Смещение': 'Offset',
        'Период': 'Period',
        'БПФ': 'FFT',
        'МНК': 'LSM',
        'Гц': 'Hz',
        'м/с': 'm/s',
        'об/мин': 'rpm',
        'мс': 'msec',
        'мин': 'min',
        'час': 'hour',
        'сек': 's',
        
        # Header/Meta specific phrases
        '1-й проход.': '1st pass.',
        '2-й проход.': '2nd pass.',
        'setup ': 'Setup ',
        'Поправка времени': 'Time offset',
        'Начало отсчета': 'Start point',
        'Имя': 'Name',
        'Значение': 'Value',
        'Тип': 'Type'
    }

    # Advanced heuristic translator
    def get_translation(ru):
        ru_clean = ru.strip()
        if ru_clean in d: return d[ru_clean]
        
        # Check for trailing punctuation
        if ru_clean.endswith(':') and ru_clean[:-1].strip() in d:
             return d[ru_clean[:-1].strip()] + ':'
             
        # Case insensitive check
        for k, v in d.items():
            if k.lower() == ru_clean.lower():
                return v
        
        # Word-by-word fallback for simple labels
        words = ru_clean.split()
        if len(words) <= 3:
            trans_words = []
            for w in words:
                w_strip = w.strip('.,:()\"')
                if w_strip in d:
                    trans_words.append(d[w_strip])
                else:
                    return ru # giving up to avoid garbage
            return ' '.join(trans_words)
            
        return ru

    def replace_match(match):
        mid = match.group(1)
        mstr = match.group(2)
        
        # We always translate if it's empty
        if not mstr.strip():
            trans = get_translation(mid)
            if trans != mid:
                # Return the whole block with new msgstr
                return f'msgid "{mid}"\nmsgstr "{trans}"'
        
        return match.group(0)

    # regex to find PO entries
    pattern = re.compile(r'msgid\s+"((?:[^"]|\\")*)"\s*msgstr\s+"((?:[^"]|\\")*)"', re.DOTALL)
    new_content = pattern.sub(replace_match, content)
    
    with open(po_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
        
    print(f"Mega-translation applied to {po_file}")

if __name__ == "__main__":
    mega_translate()
