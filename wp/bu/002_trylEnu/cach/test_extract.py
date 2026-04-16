import re

def decode_dfm_string(s):
    # Matches patterns like 'text'#1234'text'
    # First, split by '
    parts = []
    current = ""
    i = 0
    while i < len(s):
        if s[i] == "'":
            # Read until next '
            i += 1
            start = i
            while i < len(s) and s[i] != "'":
                i += 1
            parts.append(s[start:i])
            i += 1
        elif s[i] == "#":
            # Read digit
            i += 1
            start = i
            while i < len(s) and s[i].isdigit():
                i += 1
            val = int(s[start:i])
            parts.append(chr(val))
        else:
            i += 1
    return "".join(parts)

def extract_from_dfm(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Simple regex for Caption = ... or Hint = ... etc.
    # Often multiline: Caption = 'long' + 
    # 'string'
    
    # More robust: find lines like Caption = , Hint = , Text = , Items.Strings = (
    # We want to extract Russian literals.
    
    found = set()
    
    # Pattern for properties
    # Caption = #1050#1086
    # Items.Strings = (
    #   'utf8 text'
    #   'translated')
    
    # Let's just find everything after = 
    # For simplicity, look for the #10 pattern
    matches = re.findall(r'(\w+)\s*=\s*(.*)', content)
    for prop, val in matches:
        if '#' in val or "'" in val:
            decoded = decode_dfm_string(val.strip())
            if any('\u0400' <= char <= '\u04FF' for char in decoded):
                found.add(decoded)
                
    # Also handle multiline TMemo strings or TStringList
    blocks = re.findall(r'Strings = \((.*?)\)', content, re.DOTALL)
    for block in blocks:
        lines = re.findall(r"'(.*?)'", block)
        for line in lines:
            decoded = decode_dfm_string("'" + line + "'")
            if any('\u0400' <= char <= '\u04FF' for char in decoded):
                found.add(decoded)
                
    return found

if __name__ == "__main__":
    filepath = r"c:\Oburec\OburecGH\wp\WPExtPack\forms\uCorrectUTS.dfm"
    strings = extract_from_dfm(filepath)
    for s in sorted(strings):
        print(f"FOUND: {s}")
