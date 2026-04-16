import os
import re

def get_untranslated():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file): return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    blocks = content.split('\n\n')
    untranslated = []
    for b in blocks:
        if 'msgid "' in b and 'msgstr ""' in b:
            match = re.search(r'msgid "(.*?)"', b, re.DOTALL)
            if match:
                untranslated.append(match.group(1))
    
    with open('untranslated_strings.txt', 'w', encoding='utf-8') as f:
        for u in sorted(untranslated):
            f.write(f"ID: {repr(u)}\n")
            
    print(f"Total untranslated: {len(untranslated)}")

if __name__ == "__main__":
    get_untranslated()
