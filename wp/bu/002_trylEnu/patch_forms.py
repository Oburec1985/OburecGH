import os
import subprocess
import re

def compile_mo():
    msgfmt_path = r"C:\Program Files (x86)\dxgettext\msgfmt.exe"
    po_path = "WPExtPack.po"
    mo_dir = r"locale\en\LC_MESSAGES"
    mo_path = os.path.join(mo_dir, "WPExtPack.mo")
    
    if not os.path.exists(mo_dir):
        os.makedirs(mo_dir)
    
    print(f"Compiling {po_path} to {mo_path}...")
    try:
        # Use shell=True for Windows path with spaces
        cmd = f'"{msgfmt_path}" -o "{mo_path}" "{po_path}" --statistics'
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
        print(f"STDOUT: {result.stdout}")
        print(f"STDERR: {result.stderr}")
        return result.returncode == 0
    except Exception as e:
        print(f"Error compiling: {e}")
        return False

def patch_pas_file(filepath):
    with open(filepath, 'r', encoding='cp1251', errors='ignore') as f:
        content = f.read()
    
    if 'TranslateForm' in content:
        return False # Already patched
    
    class_match = re.search(r'(\w+)\s*=\s*class\s*\(TForm\)', content, re.IGNORECASE)
    if not class_match:
        return False # Not a form
    
    classname = class_match.group(1)
    
    # 1. Add uLocalizationHelper to uses
    if 'uLocalizationHelper' not in content:
        imp_match = re.search(r'implementation\s+uses\s+', content, re.IGNORECASE)
        if imp_match:
            content = content[:imp_match.end()] + "uLocalizationHelper, " + content[imp_match.end():]
        else:
            int_match = re.search(r'interface\s+uses\s+', content, re.IGNORECASE)
            if int_match:
                content = content[:int_match.end()] + "uLocalizationHelper, " + content[int_match.end():]
            else:
                # No uses in implementation or interface? Unusual but possible
                impl_pos = re.search(r'implementation', content, re.IGNORECASE)
                if impl_pos:
                    content = content[:impl_pos.end()] + "\nuses\n  uLocalizationHelper;\n" + content[impl_pos.end():]

    # 2. Add TranslateForm(Self) to entry points
    patched = False
    for pattern in [fr'procedure\s+{classname}\.FormCreate\(', 
                    fr'procedure\s+{classname}\.FormShow\(',
                    fr'procedure\s+{classname}\.edit\(',
                    fr'function\s+{classname}\.ShowModal\(',
                    fr'procedure\s+{classname}\.execute\(',
                    fr'procedure\s+{classname}\.Execute\(']:
        match = re.search(pattern, content, re.IGNORECASE)
        if match:
            begin_match = re.search(r'\bbegin\b', content[match.end():], re.IGNORECASE)
            if begin_match:
                insert_pos = match.end() + begin_match.end()
                content = content[:insert_pos] + "\n  TranslateForm(Self);" + content[insert_pos:]
                patched = True
                break
    
    if not patched:
        # Inject constructor
        print(f"Injecting constructor into {filepath} ({classname})")
        # Add declaration to public section
        public_match = re.search(r'public\b', content, re.IGNORECASE)
        if public_match:
            content = content[:public_match.end()] + "\n    constructor Create(AOwner: TComponent); override;" + content[public_match.end():]
        else:
            # Create public section before end;
            # Find the end of the class declaration
            # This is naive but works for simple D2010 forms: find 'private' or 'end;' after class declaration
            class_decl_start = class_match.start()
            end_match = re.search(r'\bend;\s*', content[class_decl_start:], re.IGNORECASE)
            if end_match:
                insert_pos = class_decl_start + end_match.start()
                content = content[:insert_pos] + "  public\n    constructor Create(AOwner: TComponent); override;\n  " + content[insert_pos:]
        
        # Add implementation to implementation section
        impl_match = re.search(r'implementation', content, re.IGNORECASE)
        if impl_match:
            # Find $R *.dfm or similar to insert after
            dfm_match = re.search(r'\{\$R\s+\*\.dfm\}', content, re.IGNORECASE)
            insert_pos = dfm_match.end() if dfm_match else impl_match.end()
            ctor_impl = f"\n\nconstructor {classname}.Create(AOwner: TComponent);\nbegin\n  inherited;\n  TranslateForm(Self);\nend;\n"
            content = content[:insert_pos] + ctor_impl + content[insert_pos:]
            patched = True

    if patched:
        with open(filepath, 'w', encoding='cp1251') as f:
            f.write(content)
        return True
    return False

if __name__ == "__main__":
    # compile_mo()
    
    forms_dir = "forms"
    count = 0
    for filename in os.listdir(forms_dir):
        if filename.endswith(".pas"):
            filepath = os.path.join(forms_dir, filename)
            try:
                if patch_pas_file(filepath):
                    print(f"Patched {filepath}")
                    count += 1
            except Exception as e:
                print(f"Error patching {filepath}: {e}")
    print(f"Total patched: {count}")
