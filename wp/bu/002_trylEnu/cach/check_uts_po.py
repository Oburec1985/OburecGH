import os
import re

def check_uts_po():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file): return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Search for anything starting with " Модуль" or " Если сигнал"
    pattern = re.compile(r'msgid \"\s*((?:Модуль|Если сигнал).*?)\"', re.DOTALL)
    matches = pattern.findall(content)
    
    with open('uts_po_check.txt', 'w', encoding='utf-8') as f:
        for m in matches:
            f.write(f"MSGID: {repr(m)}\n")
            
    print(f"Found {len(matches)} potential UTS memo segments.")

if __name__ == "__main__":
    check_uts_po()
