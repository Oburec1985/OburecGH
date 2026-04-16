import os
import re

def analyze_uses(filepath):
    with open(filepath, 'r', encoding='cp1251', errors='ignore') as f:
        content = f.read()
    
    # Logic to find "uLocalizationHelper" and check if it's in a proper uses clause
    # A proper uses clause is 'uses' keyword followed by unit names, ending with ';'
    
    # Find implementation section
    impl_match = re.search(r'implementation', content, re.IGNORECASE)
    if not impl_match:
        return None
    
    impl_content = content[impl_match.start():]
    
    # Find all occurrences of uLocalizationHelper in implementation
    for match in re.finditer(r'uLocalizationHelper', impl_content, re.IGNORECASE):
        # Look back from this position to find 'uses'
        lookback = impl_content[:match.start()]
        # Find the last 'uses' and last ';' before this match
        last_uses = lookback.rfind('uses')
        last_semicolon = lookback.rfind(';')
        
        # If 'uses' is further than 1000 characters or there is a ';' between 'uses' and the match, it's likely broken
        # OR if there is a 'procedure', 'function', 'constructor', 'destructor' between 'uses' and the match
        block_between = impl_content[max(0, last_uses):match.start()]
        if last_uses == -1 or last_semicolon > last_uses:
             return "Broken: uLocalizationHelper outside of uses clause"
        
        if re.search(r'\b(procedure|function|constructor|destructor|var|type|const)\b', block_between, re.IGNORECASE):
             return "Broken: keyword between uses and uLocalizationHelper"
             
        # Check if {$R *.dfm} is between uses and uLocalizationHelper
        if re.search(r'\{\$R\s+\*\.dfm\}', block_between, re.IGNORECASE):
             return "Warning: {$R *.dfm} interleaved in uses"

    return None

def main():
    forms_dir = r"c:\Oburec\OburecGH\wp\WPExtPack\forms"
    broken = []
    for filename in os.listdir(forms_dir):
        if filename.endswith(".pas"):
            filepath = os.path.join(forms_dir, filename)
            error = analyze_uses(filepath)
            if error:
                broken.append((filename, error))
    
    for f, err in broken:
        print(f"{f}: {err}")

if __name__ == "__main__":
    main()
