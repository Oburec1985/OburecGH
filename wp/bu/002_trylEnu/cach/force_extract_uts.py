import os
import re

def force_extract_uts():
    dfm_path = 'forms/uCorrectUTS.dfm'
    if not os.path.exists(dfm_path): return
    
    with open(dfm_path, 'rb') as f:
        content = f.read().decode('cp1251', errors='ignore')
        
    # Find all Captions, Hints and Memo strings
    # Pattern: property = 'value' or value
    memo_strings = []
    blocks = re.finditer(r'Lines.Strings = \((.*?)\)', content, re.DOTALL)
    for b in blocks:
        inner = b.group(1)
        for line in inner.splitlines():
            line = line.strip()
            if line:
                memo_strings.append(line)
                
    captions = re.findall(r'Caption = (.*?)$', content, re.MULTILINE)
    hints = re.findall(r'Hint = (.*?)$', content, re.MULTILINE)
    
    all_raw = sorted(list(set(memo_strings + captions + hints)))
    
    with open('uts_raw_dump.txt', 'w', encoding='utf-8') as f:
        for r in all_raw:
            f.write(f"RAW: {r}\n")
            # We don't decode here to see exact DFM representation
            f.write("-" * 20 + "\n")
            
    print(f"Dumped {len(all_raw)} raw UTS strings for injection plan.")

if __name__ == "__main__":
    force_extract_uts()
