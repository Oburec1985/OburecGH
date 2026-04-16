import os
import re

def parse_po(path):
    if not os.path.exists(path):
        return {}
    
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Simple regex for translated entries
    # msgid "..." msgstr "translated"
    entries = {}
    pattern = re.compile(r'msgid\s+"(.*?)"\s*msgstr\s+"(.*?)"', re.DOTALL)
    matches = pattern.findall(content)
    
    for mid, mstr in matches:
        if mid.strip() and mstr.strip():
            entries[mid] = mstr
    return entries

def analyze():
    files = ['WPExtPack_en.po', 'WPExtPack_v2_en.po']
    total_db = {}
    
    for f in files:
        data = parse_po(f)
        print(f"File {f}: found {len(data)} translated entries.")
        total_db.update(data)
    
    print(f"Total entries in DB: {len(total_db)}")
    
    # Check our current PO
    current = parse_po('WPExtPack.po')
    print(f"Current WPExtPack.po has {len(current)} translated entries.")
    
    # How many are missing?
    with open('WPExtPack.po', 'r', encoding='utf-8') as f:
        full_content = f.read()
    
    all_msgids = re.findall(r'msgid\s+"(.*?)"', full_content)
    empty_ids = [m for m in all_msgids if m.strip() and f'msgid "{m}"\nmsgstr ""' in full_content]
    
    print(f"Empty strings remaining in WPExtPack.po: {len(empty_ids)}")
    
    # Try to fill from DB
    filled = 0
    for mid in empty_ids:
        if mid in total_db:
            filled += 1
            
    print(f"Can fill {filled} strings from old PO files.")

if __name__ == "__main__":
    analyze()
