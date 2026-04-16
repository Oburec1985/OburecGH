import os
import re
import sys
import argparse

def decode_dfm_value(val):
    """Decodes Delphi DFM property values like #1050#1086 or 'text'#13#10'more'"""
    parts = []
    i = 0
    while i < len(val):
        if val[i] == "'":
            i += 1
            start = i
            while i < len(val) and val[i] != "'":
                i += 1
            parts.append(val[start:i])
            i += 1
        elif val[i] == "#":
            i += 1
            start = i
            while i < len(val) and val[i].isdigit():
                i += 1
            if start < i:
                try:
                    code = int(val[start:i])
                    parts.append(chr(code))
                except:
                    pass
        else:
            i += 1
    return "".join(parts)

def extract_from_dfm(filepath):
    """Extracts translatable strings from DFM file."""
    strings = set()
    try:
        with open(filepath, 'rb') as f:
            content = f.read().decode('utf-8', 'ignore')
        
        # Properties to extract
        target_props = {'caption', 'hint', 'text', 'displaylabel'}
        
        # 1. Simple properties: Prop = 'val' or Prop = #10xx
        lines = content.splitlines()
        for line in lines:
            line = line.strip()
            if '=' in line:
                parts = line.split('=', 1)
                prop = parts[0].strip().lower()
                # Check if it's a sub-property like Font.Name (usually skip) or just Caption
                base_prop = prop.split('.')[-1]
                if base_prop in target_props:
                    val = parts[1].strip()
                    decoded = decode_dfm_value(val)
                    if decoded:
                        strings.add(decoded)
        
        # 2. String lists like Items.Strings = ( 'val1' 'val2' )
        # Regex for block extraction
        blocks = re.findall(r'Strings = \((.*?)\)', content, re.DOTALL)
        for block in blocks:
            # Lines in blocks are usually 'val' or #10xx
            for line in block.splitlines():
                line = line.strip()
                if line:
                    decoded = decode_dfm_value(line)
                    if decoded:
                        strings.add(decoded)
    except Exception as e:
        print(f"Error processing DFM {filepath}: {e}")
    return strings

def extract_from_pas(filepath):
    """Extracts strings wrapped in _() from PAS file."""
    strings = set()
    try:
        with open(filepath, 'rb') as f:
            content = f.read().decode('cp1251', 'ignore')
        
        # Look for _('text') or gettext('text')
        # This is a simplified regex, doesn't handle escaped quotes within strings well
        found = re.findall(r'_\(\s*\'(.*?)\'\s*\)', content)
        strings.update(found)
        found = re.findall(r'gettext\(\s*\'(.*?)\'\s*\)', content)
        strings.update(found)
    except Exception as e:
        print(f"Error processing PAS {filepath}: {e}")
    return strings

def create_po(strings, output_path):
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('msgid ""\n')
        f.write('msgstr ""\n')
        f.write('"Project-Id-Version: \\n"\n')
        f.write('"POT-Creation-Date: \\n"\n')
        f.write('"PO-Revision-Date: \\n"\n')
        f.write('"Last-Translator: \\n"\n')
        f.write('"Language-Team: \\n"\n')
        f.write('"MIME-Version: 1.0\\n"\n')
        f.write('"Content-Type: text/plain; charset=UTF-8\\n"\n')
        f.write('"Content-Transfer-Encoding: 8bit\\n"\n\n')
        
        for s in sorted(strings):
            if not s: continue
            # Basic escaping for PO format
            escaped = s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r')
            f.write(f'msgid "{escaped}"\n')
            f.write('msgstr ""\n\n')

def main():
    parser = argparse.ArgumentParser(description="Extract translatable strings from Delphi files.")
    parser.add_argument("src", help="Source directory or file")
    parser.add_argument("-o", "--output", default="messages.po", help="Output PO file")
    args = parser.parse_args()
    
    all_strings = set()
    
    if os.path.isfile(args.src):
        files = [args.src]
        base_dir = os.path.dirname(args.src)
    else:
        base_dir = args.src
        files = []
        for root, _, filenames in os.walk(base_dir):
            for f in filenames:
                if f.lower().endswith(('.dfm', '.pas')):
                    files.append(os.path.join(root, f))
                    
    print(f"Scanning {len(files)} files...")
    for f in files:
        if f.lower().endswith('.dfm'):
            all_strings.update(extract_from_dfm(f))
        elif f.lower().endswith('.pas'):
            all_strings.update(extract_from_pas(f))
            
    # Filter strings to ignore pure ASCII numbers or single chars if desired
    # For now, keep everything non-empty and having at least one letter/cyrillic
    filtered = {s for s in all_strings if any(c.isalpha() or ord(c) > 127 for c in s)}
    
    create_po(filtered, args.output)
    print(f"Extraction finished. Extracted {len(filtered)} strings to {args.output}")

if __name__ == "__main__":
    main()
