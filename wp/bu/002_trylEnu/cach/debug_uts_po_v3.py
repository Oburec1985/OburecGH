import os
import re

def debug_uts_po():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file):
        print("PO file not found")
        return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    blocks = content.split('\n\n')
    uts_blocks = [b for b in blocks if 'uCorrectUTS.dfm' in b]
    
    print(f"Total UTS blocks: {len(uts_blocks)}")
    for b in uts_blocks:
        match = re.search(r'msgid "(.*?)"', b, re.DOTALL)
        if match:
            print(f"MSGID: {repr(match.group(1))}")
            mstr = re.search(r'msgstr "(.*?)"', b, re.DOTALL)
            if mstr:
                print(f"MSGSTR: {repr(mstr.group(1))}")
        print("-" * 20)

if __name__ == "__main__":
    debug_uts_po()
