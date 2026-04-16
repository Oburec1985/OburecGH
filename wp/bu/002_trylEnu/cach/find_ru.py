def find_russian_entries(filepath):
    with open(filepath, 'rb') as f:
        content = f.read().decode('utf-8', 'ignore')
    
    # Simple parser for PO entries
    entries = content.split('\n\n')
    results = []
    for entry in entries:
        if 'msgid' in entry:
            # Check if it contains Russian characters (outside comments)
            # Remove comments
            clean_entry = '\n'.join([line for line in entry.split('\n') if not line.startswith('#')])
            if any('\u0400' <= char <= '\u04FF' for char in clean_entry):
                results.append(entry)
                
    return results

entries = find_russian_entries(r'c:\Oburec\OburecGH\wp\WPExtPack\WPExtPack.po')
print(f"Found {len(entries)} entries with Russian characters.")
for entry in entries[:10]:
    print("-" * 20)
    print(entry)
