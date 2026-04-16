import os
import re

def research_po():
    po_file = 'WPExtPack.po'
    if not os.path.exists(po_file):
        print("PO file not found")
        return

    with open(po_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern to find blocks with comments, msgid and empty msgstr
    # Example block:
    # #: uFrmHibFltFrm.dfm:159
    # msgid "Настройка фильтра"
    # msgstr ""
    
    entries = []
    # Simplified pattern to capture blocks
    # We want things like:
    # #: file.dfm:line
    # msgid "..."
    # msgstr ""
    
    # Split by double newline to get entry blocks
    blocks = content.split('\n\n')
    
    untranslated_file = 'exhaustive_research.txt'
    with open(untranslated_file, 'w', encoding='utf-8') as f:
        for block in blocks:
            if 'msgstr ""' in block and 'msgid' in block:
                f.write(block + '\n' + '-'*20 + '\n')
                entries.append(block)
                
    print(f"Research complete. Found {len(entries)} untranslated entries.")
    print(f"Details saved to {untranslated_file}")

if __name__ == "__main__":
    research_po()
