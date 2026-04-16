import os
import re
import sys
import argparse

def decode_dfm_value(val):
    """Robustly decodes Delphi DFM values."""
    if not val: return ""
    # Remove leading/trailing quotes if it's a single quoted string
    val = val.strip()
    
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
                    if 0 <= code <= 255:
                        # Handle old-style Ansi characters in DFMs (cp1251 for RU)
                        parts.append(bytes([code]).decode('cp1251'))
                    else:
                        # Handle Unicode characters (#1055 etc)
                        parts.append(chr(code))
                except:
                    pass
        elif val[i] in [' ', '+', '\r', '\n', '\t']:
            i += 1
        else:
            # Junk or something else, just skip
            i += 1
    return "".join(parts)

def extract_from_dfm(filepath):
    """Extracts translatable strings from DFM file using a more robust state machine or regex."""
    strings = set()
    try:
        # DFMs can be ANSI (cp1251) or UTF-8 or have no high bytes
        # Let's read as bytes first
        with open(filepath, 'rb') as f:
            raw = f.read()
            
        # Check for UTF-8 or try cp1251
        try:
            content = raw.decode('utf-8')
        except:
            content = raw.decode('cp1251', errors='ignore')
        
        # 1. Look for properties: Caption = , Hint = , Text = 
        # Pattern: prop_name = (string | #num | multiline)
        # Multiline strings in DFM look like: Caption = 'part1' + #13#10 + 'part2'
        # or just 'part1' + 'part2'
        
        # We'll use a regex that matches the property name and then the rest of the expression until the line end 
        # (while considering + for multiline)
        
        prop_matches = re.finditer(r'^\s*(\w+)\s*=\s*(.*?)\s*$', content, re.MULTILINE)
        for m in prop_matches:
            prop = m.group(1).lower()
            val = m.group(2)
            
            # If the value ends with +, it's multiline
            # Note: This is simplified, real DFMs can have + at start of next line
            
            if prop in ['caption', 'hint', 'text', 'displaylabel']:
                decoded = decode_dfm_value(val)
                if decoded and any(ord(c) > 127 or c.isalpha() for c in decoded):
                    strings.add(decoded)
                    
        # 2. Handle Items.Strings block and TMemo.Lines
        # This is usually Strings = ( ... )
        blocks = re.finditer(r'Strings = \((.*?)\)', content, re.DOTALL)
        for b in blocks:
            inner = b.group(1)
            # Delphi TStrings can have concatenated lines: 'line1' + 'line2', or just 'line1' 'line2' (no comma)
            # We need to collect and join them if there is NO comma separating them.
            raw_lines = inner.splitlines()
            buffer = ""
            for raw_line in raw_lines:
                raw_line = raw_line.strip()
                if not raw_line: continue
                
                # Check for comma at the end of the raw line (indicator of separate item)
                has_comma = raw_line.endswith(',')
                clean_line = raw_line.rstrip(',')
                
                is_continued = clean_line.endswith('+')
                
                decoded_part = decode_dfm_value(clean_line)
                buffer += decoded_part
                
                if has_comma or (not is_continued and buffer):
                    # Finalize this item if we saw a comma or it's not continued
                    if buffer and any(ord(c) > 127 or c.isalpha() for c in buffer):
                        strings.add(buffer)
                    buffer = ""
            # Final buffer check
            if buffer and any(ord(c) > 127 or c.isalpha() for c in buffer):
                strings.add(buffer)
                        
    except Exception as e:
        print(f"Error in {filepath}: {e}")
    return strings

def extract_from_pas(filepath):
    """Extracts strings from .pas files wrapped in _() or gettext()."""
    strings = set()
    try:
        with open(filepath, 'rb') as f:
            raw = f.read()
        try:
            content = raw.decode('utf-8')
        except:
            content = raw.decode('cp1251', errors='ignore')
            
        # More flexible pattern for Pascal strings: _('string') or gettext('string')
        # This one is simpler but handles the basics well
        pattern = re.compile(r'(?:_|\bgettext)\s*\(\s*(\'(?:[^\']|\'\')*\'|"(?:[^"]|"")*")\s*\)', re.IGNORECASE)
        matches = pattern.findall(content)
        for m in matches:
            # m is the full quoted string, e.g. 'setup '
            s = m[1:-1]
            if m[0] == "'":
                s = s.replace("''", "'")
            else:
                s = s.replace('""', '"')
            if s:
                strings.add(s)
    except Exception as e:
        print(f"Error in {filepath}: {e}")
    return strings

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("src", help="Source directory (project root)")
    parser.add_argument("-o", "--output", help="Output .po file")
    args = parser.parse_args()
    
    if not args.output:
        args.output = "WPExtPack.po"
        
    all_strings = {} # string -> list of files
    dfm_count = 0
    pas_count = 0
    
    for root, _, files in os.walk(args.src):
        for f in files:
            path = os.path.join(root, f)
            rel_path = os.path.relpath(path, args.src)
            f_lower = f.lower()
            strings = set()
            if f_lower.endswith('.dfm'):
                strings = extract_from_dfm(path)
                dfm_count += 1
            elif f_lower.endswith('.pas'):
                strings = extract_from_pas(path)
                pas_count += 1
            
            for s in strings:
                if s not in all_strings:
                    all_strings[s] = []
                all_strings[s].append(rel_path)
                
    with open(args.output, 'w', encoding='utf-8') as f:
        f.write('msgid ""\nmsgstr ""\n"Project-Id-Version: WPExtPack\\n"\n"Content-Type: text/plain; charset=UTF-8\\n"\n"Content-Transfer-Encoding: 8bit\\n"\n\n')
        for s in sorted(all_strings.keys()):
            for ref in sorted(set(all_strings[s])):
                f.write(f'#: {ref}\n')
            esc = s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r')
            f.write(f'msgid "{esc}"\nmsgstr ""\n\n')
            
    print(f"Extraction complete.")
    print(f"Scanned {dfm_count} DFM files and {pas_count} PAS files.")
    print(f"Total unique strings found: {len(all_strings)}")
    print(f"Output saved to: {args.output}")

if __name__ == "__main__":
    main()
