import os
import re

def finalize_absolute_v6():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file): return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # THE MASTER DICTIONARY (Line-by-line fragments for UTS Memo)
    d = {
        # UTS Memo Fragments
        ' Модуль выполняет коррекцию времени UTS сигналов на время старта': 'Module performs UTS signal time correction based on zero start',
        ' нуля. Корректирующее значение ': ' time. The correction value ',
        'значение пишется в индикатор "Поправка времени".': 'result is written to the "Time offset" indicator.',
        ' Если сигнал UTS отсутствует для замера, то для него будет найден канал с аналогичным именем как ': 'If the UTS signal is missing for a measurement, a channel with a similar name to the ',
        'у канала начало отсчета, и будут скорректированы старты по всем каналам (без учета UTS)': 'start point channel will be found, and starts for all channels will be corrected (without UTS).',
        
        # UTS Titles and Labels
        'Коррекция времени': 'Time Correction',
        'Сигнал "Начало отсчета":': 'Signal "Start point":',
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
        
        # FFT and common
        'FFT Фильтр': 'FFT Filter',
        'Начало полосы': 'Start of band',
        'Конец полосы': 'End of band',
        'Точек FFT': 'FFT Points',
        'Смещение порции': 'Portion offset',
        'Применить': 'Apply',
        'Добавить': 'Add',
        'Удалить': 'Delete',
        'Ок': 'OK',
        'Отмена': 'Cancel',
        'Закрыть': 'Close'
    }

    def smart_translate(mid):
        if not mid: return mid
        mid_s = mid.strip()
        
        # 1. Exact match (including possible leading/trailing space)
        if mid in d: return d[mid]
        if mid_s in d: return d[mid_s]
        
        # 2. Case insensitive
        for k, v in d.items():
            if k.lower() == mid_s.lower(): return v
            
        # 3. Technical (ASCII only)
        if re.match(r'^[A-Za-z0-9_\s\.,:\"\'\(\)]+$', mid_s):
            return mid
            
        return mid # Return original if no rule matches

    def replace_all(match):
        mid = match.group(1)
        mstr = match.group(2)
        
        # Force translate if Russian detected in msgid
        has_cyrillic = bool(re.search('[а-яА-Я]', mid))
        
        if has_cyrillic:
            trans = smart_translate(mid)
            # If translation is still the same as mid (Russian), keep msgstr empty or use smart guess
            return f'msgid "{mid}"\nmsgstr "{trans}"'
        
        return match.group(0)

    pattern = re.compile(r'msgid\s+"((?:[^"]|\\")*)"\s*msgstr\s+"((?:[^"]|\\")*)"', re.DOTALL)
    new_content = pattern.sub(replace_all, content)
    
    with open(po_file, 'w', encoding='utf-8') as f:
        f.write(new_content)
        
    print("Final Localization V6 applied (UTS Fragment Fix included).")

if __name__ == "__main__":
    finalize_absolute_v6()
