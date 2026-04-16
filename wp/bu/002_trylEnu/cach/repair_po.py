import re

def decode_weird_po(filepath):
    with open(filepath, 'rb') as f:
        content = f.read()
    
    # Extract entries
    entry_pattern = rb'msgid "(.*?)"\nmsgstr "(.*?)"'
    matches = re.findall(entry_pattern, content, re.DOTALL)
    
    for msgid, msgstr in matches:
        if b'\xd0' in msgid or b'\xd1' in msgid:
            try:
                # Try to decode as UTF-8 then encode back to some bytes and decode as cp1251?
                s = msgid.decode('utf-8')
                # If s looks like Latin-1 garbage, maybe it's re-encoded
                # Let's try to see the raw bytes of the content of msgid
                print(f"ID: {msgid}")
                # Try to "repair": if each char in s is actually a byte of cp1251
                try:
                    repaired = s.encode('latin-1').decode('cp1251')
                    print(f"Repaired: {repaired}")
                except:
                    pass
            except:
                pass
            print("-" * 10)

decode_weird_po(r'c:\Oburec\OburecGH\wp\WPExtPack\WPExtPack.po')
