import os
import re

def check_uts_msgids():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file):
        print("PO file not found")
        return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    blocks = content.split('\n\n')
    uts_blocks = [b for b in blocks if 'uCorrectUTS.dfm' in b]
    
    with open('uts_exact_msgids.txt', 'w', encoding='utf-8') as f:
        f.write(f"Found {len(uts_blocks)} blocks for UTS\n")
        for b in uts_blocks:
            f.write("="*20 + "\n")
            f.write(b + "\n")
            mid_match = re.search(r'msgid \"(.*)\"', b, re.DOTALL)
            if mid_match:
                f.write(f"REPR MSGID: {repr(mid_match.group(1))}\n")

if __name__ == "__main__":
    check_uts_msgids()
