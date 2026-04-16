import re

def analyze_po(filepath):
    with open(filepath, 'rb') as f:
        content = f.read().decode('utf-8', 'ignore')
    
    # Find all msgid/msgstr pairs
    entries = re.findall(r'msgid "(.*?)"\nmsgstr "(.*?)"', content, re.DOTALL)
    
    russian_ids = []
    translated = []
    
    for msgid, msgstr in entries:
        # Check if msgid contains Russian
        if re.search(r'[а-яА-Я]', msgid):
            russian_ids.append(msgid)
            if msgstr.strip():
                translated.append((msgid, msgstr))
                
    print(f"Total entries: {len(entries)}")
    print(f"Russian msgids found: {len(russian_ids)}")
    print(f"Translated Russian entries: {len(translated)}")
    
    if translated:
        print("\nExample translations:")
        for m_id, m_str in translated[:5]:
            print(f"ID: {m_id} -> STR: {m_str}")

analyze_po(r'c:\Oburec\OburecGH\wp\WPExtPack\WPExtPack.po')
