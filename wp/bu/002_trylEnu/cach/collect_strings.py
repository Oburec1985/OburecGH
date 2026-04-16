import re
import os

def extract():
    path = 'WPExtPack.po'
    if not os.path.exists(path):
        print(f"File {path} not found")
        return

    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Regex to find untranslated blocks
    # Looking for msgid "..." followed by msgstr ""
    pattern = re.compile(r'msgid\s+"((?:[^"]|\\")*)"\s*msgstr\s+""', re.DOTALL)
    matches = pattern.findall(content)
    
    untranslated = [m for m in matches if m.strip()]
    
    with open('untranslated_strings.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(untranslated))
    
    print(f"Extracted {len(untranslated)} untranslated strings to untranslated_strings.txt")

if __name__ == "__main__":
    extract()
