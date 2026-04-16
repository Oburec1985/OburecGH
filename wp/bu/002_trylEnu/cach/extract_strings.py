import os
import re
import sys

# Ensure UTF-8 output for messages
if sys.version_info >= (3, 7):
    sys.stdout.reconfigure(encoding='utf-8')

def decode_dfm_string(s):
    parts = []
    i = 0
    while i < len(s):
        if s[i] == "'":
            i += 1
            start = i
            while i < len(s) and s[i] != "'":
                i += 1
            parts.append(s[start:i])
            i += 1
        elif s[i] == "#":
            i += 1
            start = i
            while i < len(s) and s[i].isdigit():
                i += 1
            if start < i:
                val = int(s[start:i])
                parts.append(chr(val))
            else:
                # Malformed # without digits?
                pass
        else:
            i += 1
    return "".join(parts)

def extract_from_dfm(filepath):
    # Read as bytes to handle potential encoding issues
    with open(filepath, 'rb') as f:
        content = f.read().decode('utf-8', 'ignore')
    
    found = set()
    # Matches Caption = ..., Hint = ..., Text = ...
    # Also handles multiline with +
    lines = content.split('\n')
    for line in lines:
        match = re.search(r'(\w+)\s*=\s*(.*)', line)
        if match:
            prop, val = match.groups()
            if prop.lower() in ['caption', 'hint', 'text']:
                decoded = decode_dfm_string(val.strip())
                if decoded and any(ord(c) > 127 for c in decoded):
                    found.add(decoded)
    
    # Handle Items.Strings = ( ... )
    items_blocks = re.findall(r'Items\.Strings = \((.*?)\)', content, re.DOTALL)
    for block in items_blocks:
        re_strings = re.findall(r"'(.*?)'", block)
        for s in re_strings:
            decoded = decode_dfm_string("'" + s + "'")
            if any(ord(c) > 127 for c in decoded):
                found.add(decoded)
                
    return found

def main():
    root_dir = r"c:\Oburec\OburecGH\wp\WPExtPack\forms"
    all_strings = set()
    for filename in os.listdir(root_dir):
        if filename.endswith(".dfm"):
            filepath = os.path.join(root_dir, filename)
            try:
                strings = extract_from_dfm(filepath)
                all_strings.update(strings)
            except Exception as e:
                print(f"Error in {filename}: {e}")
    
    po_path = r"c:\Oburec\OburecGH\wp\WPExtPack\WPExtPack_new.po"
    with open(po_path, 'w', encoding='utf-8') as f:
        f.write('msgid ""\nmsgstr ""\n"Content-Type: text/plain; charset=UTF-8\\n"\n"Content-Transfer-Encoding: 8bit\\n"\n\n')
        for s in sorted(all_strings):
            # Escape double quotes for msgid
            escaped = s.replace('"', '\\"')
            f.write(f'msgid "{escaped}"\nmsgstr ""\n\n')
            
    print(f"Extraction complete. Found {len(all_strings)} strings.")
    print(f"Generated {po_path}")

if __name__ == "__main__":
    main()
