import re
import os

def list_untranslated():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file): return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find blocks of msgid "..." followed by msgstr ""
    pattern = re.compile(r'msgid\s+"((?:[^"]|\\")*)"\s*msgstr\s+""', re.DOTALL)
    matches = pattern.findall(content)
    
    untranslated = [m for m in matches if m.strip()]
    
    with open('remaining_untranslated.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(untranslated))
    
    print(f"Extraction complete: {len(untranslated)} untranslated unique strings found.")

if __name__ == "__main__":
    list_untranslated()
