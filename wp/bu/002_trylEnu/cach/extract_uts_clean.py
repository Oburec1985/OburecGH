import os
from scripts.extract_dx_v2 import extract_from_dfm

def get_clean_uts_strings():
    dfm = 'forms/uCorrectUTS.dfm'
    if not os.path.exists(dfm):
        print(f"Error: {dfm} not found")
        return
        
    s = extract_from_dfm(dfm)
    with open('uts_strings_clean.txt', 'w', encoding='utf-8') as f:
        for string in sorted(list(s)):
            # Representation to see hidden chars
            f.write(f"RAW: {repr(string)}\n")
            f.write(f"TEXT: {string}\n")
            f.write("-" * 20 + "\n")
    print(f"Extracted {len(s)} strings for UTS analysis.")

if __name__ == "__main__":
    get_clean_uts_strings()
