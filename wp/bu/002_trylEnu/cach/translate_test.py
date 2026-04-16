import os

def translate():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file):
        print(f"Error: {po_file} not found")
        return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    translations = {
        # Hilbert Form (previous)
        'Настройка фильтра': 'Hilbert Filter Setup',
        'Число точек': 'Number of points',
        'Число блоков': 'Number of blocks',
        'Размер порции, с': 'Portion size, s',
        
        # Time Correction Form (CorrectUTS) - based on screenshot
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
        'Отмена': 'Cancel',
        'Применить': 'Apply',
        'Имя': 'Name',
        
        # Long description (partial match or regex would be better, but let's try direct)
        'Модуль выполняет коррекцию времени UTS сигналов на время старта нуля. Корректирующее\\n' \
        'значение пишется в индикатор \"Поправка времени\".\\n' \
        'Если сигнал UTS отсутствует для замера, то для него будет найден канал с аналогичным именем как\\n' \
        'у канала начало отсчета, и будут скорректированы старты по всем каналам (без учета UTS)': 
        'The module performs UTS signals time correction to the zero start time. The correction\\n' \
        'value is written to the \"Time offset\" indicator.\\n' \
        'If the UTS signal is missing for a measurement, a channel with the same name as\\n' \
        'the start point channel will be found, and starts for all channels will be corrected (excluding UTS)'
    }

    found_count = 0
    for ru, en in translations.items():
        # Check both single line and potentially escaped parts
        pattern = f'msgid "{ru}"\nmsgstr ""'
        replacement = f'msgid "{ru}"\nmsgstr "{en}"'
        if pattern in content:
            content = content.replace(pattern, replacement)
            print(f"Translated: {ru[:30]}...")
            found_count += 1
        else:
            # Try to see if it was extracted differently (e.g. without \n at end of lines if it's one block)
            # Actually our extractor handles it exactly as in DFM
            pass

    with open(po_file, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print(f"Done. Applied {found_count} translations to WPExtPack.po")

if __name__ == "__main__":
    translate()
