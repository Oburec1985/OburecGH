import os
import re

def verify_uts_po():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file): return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    blocks = content.split('\n\n')
    uts_blocks = [b for b in blocks if 'uCorrectUTS.dfm' in b]
    
    with open('uts_po_hex_dump.txt', 'w', encoding='utf-8') as f:
        for b in uts_blocks:
            mid_match = re.search(r'msgid "(.*?)"', b, re.DOTALL)
            mstr_match = re.search(r'msgstr "(.*?)"', b, re.DOTALL)
            if mid_match:
                mid = mid_match.group(1)
                mstr = mstr_match.group(1) if mstr_match else ""
                f.write(f"MSGID RAW: {repr(mid)}\n")
                f.write(f"MSGSTR: {repr(mstr)}\n")
                f.write("-" * 40 + "\n")
    
    print(f"Verified {len(uts_blocks)} blocks for UTS form.")

if __name__ == "__main__":
    verify_uts_po()
