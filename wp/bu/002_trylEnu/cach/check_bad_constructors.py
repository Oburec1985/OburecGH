import os
import re

def check_constructors():
    forms_dir = r'c:\Oburec\OburecGH\wp\WPExtPack\forms'
    bad_forms = []

    for f in os.listdir(forms_dir):
        if f.endswith('.pas'):
            path = os.path.join(forms_dir, f)
            with open(path, 'r', encoding='cp1251', errors='ignore') as file:
                content = file.read()
            
            # Find constructor and check order of TranslateForm vs inherited
            # Simplified regex to find the constructor body
            pattern = re.compile(r'constructor.*?begin(.*?)\s+end;', re.DOTALL | re.IGNORECASE)
            matches = pattern.finditer(content)
            
            for match in matches:
                body = match.group(1)
                t_idx = body.find('TranslateForm')
                i_idx = body.find('inherited')
                
                if t_idx != -1 and i_idx != -1:
                    if t_idx < i_idx:
                        bad_forms.append((f, "TranslateForm before inherited"))
                    # Also check for TranslateComponent
                
                tc_idx = body.find('TranslateComponent')
                if tc_idx != -1 and i_idx != -1:
                    if tc_idx < i_idx:
                        bad_forms.append((f, "TranslateComponent before inherited"))

    for f, msg in bad_forms:
        print(f"{f}: {msg}")

if __name__ == "__main__":
    check_constructors()
