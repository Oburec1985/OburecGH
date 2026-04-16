import os

def debug_uts_po():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file): return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    blocks = content.split('\n\n')
    uts_blocks = [b for b in blocks if 'uCorrectUTS.dfm' in b]
    
    with open('uts_debug_info.txt', 'w', encoding='utf-8') as f:
        for b in uts_blocks:
            f.write(b + '\n' + '='*40 + '\n')
            
    print(f"Debug complete. Found {len(uts_blocks)} blocks for UTS form.")

if __name__ == "__main__":
    debug_uts_po()
