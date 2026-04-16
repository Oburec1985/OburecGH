import struct
import argparse
import os
import re

def parse_po(po_path):
    """Extremely basic PO parser."""
    with open(po_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Match msgid and msgstr pairs
    # Handles simple single-line strings. For multi-line, it needs more logic.
    entries = []
    
    # Regex to handle single and multi-line strings in PO
    # msgid "parts" "more parts"
    def extract_po_str(block):
        # Find all quoted parts and join them
        parts = re.findall(r'"(.*?)"', block)
        # Unescape common sequences
        s = "".join(parts)
        s = s.replace('\\n', '\n').replace('\\r', '\r').replace('\\"', '"').replace('\\\\', '\\')
        return s

    # Split by empty lines to find entries
    raw_entries = re.split(r'\n\s*\n', content)
    for raw in raw_entries:
        msgid_match = re.search(r'msgid\s+((?:".*?"\s*)+)', raw, re.DOTALL)
        msgstr_match = re.search(r'msgstr\s+((?:".*?"\s*)+)', raw, re.DOTALL)
        
        if msgid_match and msgstr_match:
            mid = extract_po_str(msgid_match.group(1))
            mstr = extract_po_str(msgstr_match.group(1))
            # Include everything including header (msgid "")
            entries.append((mid, mstr))
                
    return entries

def compile_mo(entries, mo_path):
    """Compiles list of (msgid, msgstr) to binary .mo format."""
    # Sort entries by msgid as required by .mo format
    entries.sort()
    
    count = len(entries)
    
    # Build string pools
    ids = []
    strs = []
    for mid, mstr in entries:
        ids.append(mid.encode('utf-8'))
        strs.append(mstr.encode('utf-8'))
    
    header_size = 7 * 4 # magic, version, count, id_table_offset, str_table_offset, hash_size, hash_offset
    table_entry_size = 8 # length, offset
    
    id_table_offset = header_size
    str_table_offset = id_table_offset + (count * table_entry_size)
    pool_offset = str_table_offset + (count * table_entry_size)
    
    id_table = []
    str_table = []
    
    current_pool_pos = pool_offset
    
    # Calculate offsets for IDs
    for b in ids:
        id_table.append((len(b), current_pool_pos))
        current_pool_pos += len(b) + 1 # +1 for null terminator
        
    # Calculate offsets for translations
    for b in strs:
        str_table.append((len(b), current_pool_pos))
        current_pool_pos += len(b) + 1
        
    # Write file
    with open(mo_path, 'wb') as f:
        # Header
        f.write(struct.pack('<I', 0x950412de)) # Magic
        f.write(struct.pack('<I', 0))          # Version
        f.write(struct.pack('<I', count))      # Count
        f.write(struct.pack('<I', id_table_offset))
        f.write(struct.pack('<I', str_table_offset))
        f.write(struct.pack('<I', 0))          # Hash size (0 = none)
        f.write(struct.pack('<I', 0))          # Hash offset
        
        # ID Table
        for length, offset in id_table:
            f.write(struct.pack('<II', length, offset))
            
        # String Table
        for length, offset in str_table:
            f.write(struct.pack('<II', length, offset))
            
        # ID Pool
        for b in ids:
            f.write(b + b'\x00')
            
        # String Pool
        for b in strs:
            f.write(b + b'\x00')

def main():
    parser = argparse.ArgumentParser(description="Compile .po to .mo binary format.")
    parser.add_argument("po", help="Input .po file")
    parser.add_argument("-o", "--output", help="Output .mo file")
    args = parser.parse_args()
    
    if not args.output:
        args.output = os.path.splitext(args.po)[0] + ".mo"
        
    entries = parse_po(args.po)
    # Filter only translated entries
    translated = [e for e in entries if e[1].strip()]
    
    print(f"Read {len(entries)} entries. Found {len(translated)} translated strings.")
    compile_mo(translated, args.output)
    print(f"Successfully compiled {args.output}")

if __name__ == "__main__":
    main()
