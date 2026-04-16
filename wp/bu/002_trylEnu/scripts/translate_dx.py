import re
import argparse

# Common translations dictionary
COMMON_TRANS = {
    "Добавить": "Add",
    "Удалить": "Delete",
    "Применить": "Apply",
    "Отмена": "Cancel",
    "ОК": "OK",
    "Вычислить": "Calculate",
    "Обнулить": "Reset",
    "Коррекция времени": "Time correction",
    "Сигнал \"Начало отсчета\":": "Signal \"Start of countdown\":",
    "Пороговое значение": "Threshold value",
    "Время испытания": "Test time",
    "Сдвигать сигналы без UTS": "Shift signals without UTS",
    "Поправка времени, с": "Time correction, s",
    "Номер срабатывания": "Trigger number",
    "Учитывать время старта испытания": "Take into account the start time of the test",
    "Определить сдвиг в каждом замере по имени канала": "Determine the shift in each measurement by channel name",
    "Распаковка СИКОН": "SICON Unpacking",
    "Перечень замеров": "List of measurements",
    "Корректируемые UTS сигналы:": "Corrected UTS signals:",
    "Фронт": "Rise",
    "Спад": "Fall",
    " Tahoma": "Tahoma",
}

def translate_po(po_path, output_path, mapping):
    with open(po_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith('msgid "'):
            # Extract msgid
            msgid_match = re.search(r'msgid "(.*)"', line)
            if msgid_match:
                msgid = msgid_match.group(1)
                new_lines.append(line)
                i += 1
                # Next line should be msgstr ""
                if i < len(lines) and lines[i].startswith('msgstr ""'):
                    # Check if we have a translation
                    # Unescape msgid for matching
                    unescaped_id = msgid.replace('\\"', '"').replace('\\\\', '\\')
                    trans = mapping.get(unescaped_id.strip())
                    if trans:
                        new_lines.append(f'msgstr "{trans}"\n')
                    else:
                        new_lines.append(lines[i])
                    i += 1
                else:
                    # Not an empty msgstr, just keep going
                    pass
            else:
                new_lines.append(line)
                i += 1
        else:
            new_lines.append(line)
            i += 1
            
    with open(output_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

def main():
    parser = argparse.ArgumentParser(description="Apply translations to a PO file.")
    parser.add_argument("po", help="Input PO file")
    parser.add_argument("-o", "--output", help="Output PO file")
    args = parser.parse_args()
    
    if not args.output:
        args.output = args.po
        
    translate_po(args.po, args.output, COMMON_TRANS)
    print(f"Applied translation mapping to {args.output}")

if __name__ == "__main__":
    main()
