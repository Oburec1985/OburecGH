import os
import re

def finalize_ultimate_v8():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file): return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # THE DEFINITIVE DICTIONARY for UTS and core UI
    # These strings are now merged by the updated extractor.
    d = {
        ' Модуль выполняет коррекцию времени UTS сигналов на время старта нуля. Корректирующее значение пишется в индикатор "Поправка времени".':
        'This module performs UTS signal time correction relative to zero start. The correction value is reported in the "Time Offset" indicator.',
        
        ' Если сигнал UTS отсутствует для замера, то для него будет найден канал с аналогичным именем как у канала начало отсчета, и будут скорректированы старты по всем каналам (без учета UTS)':
        'If the UTS signal is missing for a measurement, a channel with a name identical to the reference start channel will be used to correct start times for all channels (excluding UTS).',
        
        'Сигнал "Начало отсчета":': 'Signal "Start point":',
        'Имя': 'Name',
        '№': 'No.',
        
        # Common UI
        'Коррекция времени': 'Time Correction',
        'Пороговое значение': 'Threshold value',
        'Поправка времени, с': 'Time offset, s',
        'Номер срабатывания': 'Trigger number',
        'Время испытания': 'Test duration',
        'Перечень замеров': 'List of measurements',
        'Корректируемые UTS сигналы:': 'Corrected UTS signals:',
        'Не найден канал UTS': 'UTS channel not found',
        'Сдвигать сигналы без UTS': 'Shift signals without UTS',
        'Определить сдвиг в каждом замере по имени канала': 'Determine shift in each measurement by channel name',
        'Распаковка СИКОН': 'SIKON Decoding',
        'Учитывать время старта испытания': 'Account for test start time',
        'Вычислить': 'Evaluate',
        'Обнулить': 'Reset',
        'Фронт': 'Rising',
        'Спад': 'Falling',
        'Применить': 'Apply',
        'Добавить': 'Add',
        'Удалить': 'Delete',
        'Закрыть': 'Close',
        'Отмена': 'Cancel',
        'Ок': 'OK'
    }

    def smart_translate(mid):
        if not mid: return mid
        mid_s = mid.strip()
        
        # Exact match (normalized)
        if mid in d: return d[mid]
        if mid_s in d: return d[mid_s]
        
        # Fuzzy match for technical description (if it contains key phrase)
        if 'Модуль выполняет коррекцию' in mid:
            return d[' Модуль выполняет коррекцию времени UTS сигналов на время старта нуля. Корректирующее значение пишется в индикатор "Поправка времени".']
        if 'Если сигнал UTS отсутствует' in mid:
             return d[' Если сигнал UTS отсутствует для замера, то для него будет найден канал с аналогичным именем как у канала начало отсчета, и будут скорректированы старты по всем каналам (без учета UTS)']

        # If it's ASCII (numbers, names), keep it
        if re.match(r'^[A-Za-z0-9_\s\.,:;\"\'\(\)\!\?\-\+\*/\\#\d%]+$', mid_s):
            return mid
            
        return mid # Fallback to original

    def replace_all(match):
        mid = match.group(1)
        mstr = match.group(2)
        
        has_cyrillic = bool(re.search('[а-яА-Я]', mid))
        
        if has_cyrillic:
            trans = smart_translate(mid)
            return f'msgid "{mid}"\nmsgstr "{trans}"'
        
        return match.group(0)

    pattern = re.compile(r'msgid\s+"((?:[^"]|\\")*)"\s*msgstr\s+"((?:[^"]|\\")*)"', re.DOTALL)
    new_content = pattern.sub(replace_all, content)
    
    with open(po_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
        
    print("Final Localization Ultimate V8 applied.")

if __name__ == "__main__":
    finalize_ultimate_v8()
