import os
import re

def deep_check_uts():
    dfm_path = 'forms/uCorrectUTS.dfm'
    po_path = 'WPExtPack.po'
    
    if not os.path.exists(dfm_path) or not os.path.exists(po_path):
        print("Required files not found")
        return

    # 1. Read DFM
    with open(dfm_path, 'rb') as f:
        dfm_content = f.read().decode('cp1251', errors='ignore')
    
    # Extract Russian strings from DFM (naive)
    dfm_strings = re.findall(r"'( #[0-9]+|[^']*[а-яА-Я][^']*)'", dfm_content)
    
    # 2. Read PO
    with open(po_path, 'r', encoding='utf-8') as f:
        po_content = f.read()
    
    with open('uts_deep_debug.txt', 'w', encoding='utf-8') as f:
        f.write("--- UTS DFM STRINGS ---\n")
        for s in sorted(list(set(dfm_strings))):
            f.write(f"RAW: {s}\n")
            f.write(f"REPR: {repr(s)}\n")
            f.write("-" * 10 + "\n")
            
        f.write("\n--- UTS PO ENTRIES ---\n")
        blocks = po_content.split('\n\n')
        uts_blocks = [b for b in blocks if 'uCorrectUTS.dfm' in b]
        for b in uts_blocks:
            f.write(b + "\n")
            f.write("-" * 20 + "\n")

if __name__ == "__main__":
    deep_check_uts()
