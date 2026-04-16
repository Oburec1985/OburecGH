import codecs
import os

path = r'c:\Oburec\OburecGH\wp\WPExtPack\WPExtPack.dpr'
encoding = 'cp1251'

try:
    with codecs.open(path, 'r', encoding) as f:
        content = f.read()
    
    # Регулярное выражение или точный поиск для блока в конце файла
    # Ищем блок begin ... UseLanguage ... end.
    
    import re
    # (?s) включает DOTALL
    pattern = r'begin\s+\{\$IFDEF LANG_EN\}\s+UseLanguage\(\'en\'\);\s+\{\$ENDIF\}\s+end\.'
    replacement = "begin\r\n  textdomain('default');\r\n  AddDomainForResourceString('default');\r\n  UseLanguage('en');\r\nend."
    
    if re.search(pattern, content):
        new_content = re.sub(pattern, replacement, content)
        with codecs.open(path, 'w', encoding) as f:
            f.write(new_content)
        print("SUCCESS: DPR updated with localization activation.")
    else:
        # Попробуем без пробелов если не нашли
        if "UseLanguage('en')" in content:
             print("ERROR: Found UseLanguage but pattern match failed. Check whitespaces.")
             # Fallback simple replace
             new_content = content.replace("{$IFDEF LANG_EN}\r\n  UseLanguage('en');\r\n  {$ENDIF}", "textdomain('default');\r\n  AddDomainForResourceString('default');\r\n  UseLanguage('en');")
             with codecs.open(path, 'w', encoding) as f:
                 f.write(new_content)
             print("SUCCESS: Fallback replacement applied.")
        else:
             print("ERROR: Target block not found in file.")
             print("Content tail:", content[-200:])

except Exception as e:
    print(f"FAILED: {str(e)}")
