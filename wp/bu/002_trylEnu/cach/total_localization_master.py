import os
import re

def total_translate():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file): return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # MASTER DICTIONARY (Expanded for 100% coverage)
    m = {
        # Form: Zero Balancing / Балансировка нуля
        'Балансировка нуля': 'Zero Balancing',
        'Начало': 'Start',
        'Конец': 'End',
        'Список сигналов': 'Signals list',
        ',сек': ',s',
        ', сек': ',s',
        'Параметры': 'Parameters',
        'Загрузить': 'Load',
        'Сохранить': 'Save',
        'Применить': 'Apply',
        
        # Batch Processing / Пакетная обработка
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
        'Свой...': 'Custom...',
        
        # Time Correction / Коррекция времени
        'Коррекция времени': 'Time Correction',
        'Поправка времени': 'Time offset',
        'Начало отсчета': 'Start point',
        'UTS': 'UTS',
        'Сигнал \"Начало отсчета\":': 'Signal \"Start point\":',
        'Распаковка СИКОН': 'SIKON Decoding',
        'Пороговое значение': 'Threshold',
        'Время испытания': 'Test time',
        'Обнулить': 'Reset',
        'Фронт': 'Rising edge',
        'Спад': 'Falling edge',
        'Сдвигать сигналы без UTS': 'Shift signals without UTS',
        'Поправка времени, с': 'Time offset, s',
        'Номер срабатывания': 'Trigger number',
        'Вычислить': 'Calculate',
        'Учитывать время старта испытания': 'Use test start time',
        
        # Grid & Columns
        'Имя': 'Name',
        'Значение': 'Value',
        'Тип': 'Type',
        'Путь': 'Path',
        'Группа': 'Group',
        'Дата': 'Date',
        'Статус': 'Status',
        'Источник': 'Source',
        'Назначение': 'Destination',
        'Результат': 'Result',
        
        # Math & Data
        'БПФ': 'FFT',
        'МНК': 'LSM',
        'Среднее': 'Average',
        'Максимум': 'Maximum',
        'Минимум': 'Minimum',
        'Пик': 'Peak',
        'Спектр': 'Spectrum',
        'Тренд': 'Trend',
        'Шум': 'Noise',
        'Шум \"+\"': 'Noise \"+\"',
        'Шум \"-\"': 'Noise \"-\"',
        'Уровень \"+\"': 'Level \"+\"',
        'Уровень \"-\"': 'Level \"-\"',
        'Полином': 'Polynomial',
        'Аппроксимация': 'Approximation',
        'Коэффициент': 'Coefficient',
        'Частота': 'Frequency',
        'Амплитуда': 'Amplitude',
        'Чувствительность': 'Sensitivity',
        'Смещение': 'Offset',
        
        # Common UI
        'Добавить': 'Add',
        'Удалить': 'Delete',
        'Ок': 'OK',
        'Отмена': 'Cancel',
        'Закрыть': 'Close',
        'Выход': 'Exit',
        'Настройка': 'Settings',
        'Свойства': 'Properties',
        'Информация': 'Information',
        'Ошибка': 'Error',
        'Предупреждение': 'Warning',
        'Включено': 'Enabled',
        'Выключено': 'Disabled',
        'Продолжить': 'Continue',
        'Да': 'Yes',
        'Нет': 'No',
        
        # Units
        'Гц': 'Hz',
        'Гц ': 'Hz ',
        'кГц': 'kHz',
        'м/с': 'm/s',
        'об/мин': 'rpm',
        'мс': 'msec',
        'мин': 'min',
        'час': 'hour',
        'сек': 's',
        'сек ': 's ',
        
        # Long Descriptions
        'Модуль выполняет коррекцию времени UTS сигналов на время старта нуля. Корректирующее\\nзначение пишется в индикатор \"Поправка времени\".\\nЕсли сигнал UTS отсутствует для замера, то для него будет найден канал с аналогичным именем как\\nу канала начало отсчета, и будут скорректированы старты по всем каналам (без учета UTS)':
        'The module performs UTS signals time correction to the zero start time. The correction\\nvalue is written to the \"Time offset\" indicator.\\nIf the UTS signal is missing for a measurement, a channel with the same name as\\nthe start point channel will be found, and starts for all channels will be corrected (excluding UTS)',
        
        '1-й проход.': '1st pass.',
        '2-й проход.': '2nd pass.',
        'setup ': 'Setup ',
        'Балансировка': 'Balancing',
        'Блокировка': 'Locking',
        'Очистить': 'Clear',
        'Обновить': 'Refresh',
        'Имя файла': 'Filename'
    }

    untranslated_count = 0
    filled_count = 0

    def get_smart_translation(mid):
        # 1. Direct match
        if mid in m: return m[mid]
        
        # 2. Heuristics for common patterns
        res = mid
        
        # Strip trailing colon
        has_colon = mid.endswith(':')
        base = mid[:-1] if has_colon else mid
        
        if base in m:
            return m[base] + (':' if has_colon else '')
            
        # 3. Simple replacements in fragments
        for ru, en in m.items():
            if len(ru) > 3: # avoid single char replacements
                res = res.replace(ru, en)
        
        # If anything changed, return it
        if res != mid: return res
        
        # 4. Fallback for common Delphi terms if not in dict
        delphi_map = {
            'Button': 'Button', 'Label': 'Label', 'CheckBox': 'CheckBox',
            'Edit': 'Edit', 'ComboBox': 'ComboBox', 'Memo': 'Memo',
            'ListBox': 'ListBox', 'TabSheet': 'TabSheet', 'PageControl': 'PageControl'
        }
        for k, v in delphi_map.items():
            if k in mid: return mid # Keep technical names as is
            
        return mid

    def replace_func(match):
        nonlocal untranslated_count, filled_count
        mid = match.group(1)
        mstr = match.group(2)
        
        if not mstr.strip():
            untranslated_count += 1
            trans = get_smart_translation(mid)
            if trans != mid:
                filled_count += 1
                return f'msgid "{mid}"\nmsgstr "{trans}"'
        
        return match.group(0)

    pattern = re.compile(r'msgid\s+"((?:[^"]|\\")*)"\s*msgstr\s+"((?:[^"]|\\")*)"', re.DOTALL)
    new_content = pattern.sub(replace_func, content)
    
    with open(po_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
        
    print(f"Total untranslated blocks found: {untranslated_count}")
    print(f"Successfully filled: {filled_count}")
    print(f"Remaining: {untranslated_count - filled_count}")

if __name__ == "__main__":
    total_translate()
