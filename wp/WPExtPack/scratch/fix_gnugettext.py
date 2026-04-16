import codecs
import re

path = r'c:\Oburec\OburecGH\sharedUtils\utils\gnugettext.pas'
encoding = 'cp1251'

with codecs.open(path, 'r', encoding) as f:
    content = f.read()

# Список замен для добавления public в объявлении классов
replacements = [
    (r'(TTP_RetranslatorItem\s*=\s*class)\s+(obj:TObject;)', r'\1\n    public\n      \2'),
    (r'(TTP_Retranslator\s*=\s*class\s*\(TExecutable\))\s+(TextDomain:DomainString;)', r'\1\n    public\n      \2'),
    (r'(TEmbeddedFileInfo\s*=\s*class)\s+(offset,size:int64;)', r'\1\n    public\n      \2'),
    (r'(TFileLocator\s*=\s*class)\s+(constructor Create;)', r'\1\n    public\n      \2'),
    (r'(TClassMode\s*=\s*class)\s+(HClass:TClass;)', r'\1\n    public\n      \2'),
    (r'(THook\s*=\s*class)\s+(public)', r'\1\n    public') # THook уже может иметь public, проверим
]

modified = False
new_content = content

for pattern, subst in replacements:
    if re.search(pattern, new_content):
        new_content = re.sub(pattern, subst, new_content)
        modified = True
        print(f"Applied replacement for: {pattern}")
    else:
        print(f"Pattern not found (skipping): {pattern}")

if modified:
    with codecs.open(path, 'w', encoding) as f:
        f.write(new_content)
    print("SUCCESS: gnugettext.pas updated.")
else:
    print("WARNING: No changes made to gnugettext.pas.")
