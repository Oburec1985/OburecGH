import os

def check_and_convert(filename):
    print(f"Analyzing {os.path.basename(filename)}...")
    with open(filename, 'rb') as f:
        raw = f.read()
    
    # Try UTF-8 first
    try:
        utf8_text = raw.decode('utf-8')
        # Check if it contains Russian characters decoded properly
        if "Проверяем" in utf8_text or "попадание" in utf8_text or "Снимаем" in utf8_text or "осей" in utf8_text:
            print("  Detected UTF-8 with Russian comments!")
            # Convert to CP1251
            with open(filename, 'w', encoding='cp1251', newline='') as f:
                f.write(utf8_text)
            print("  Successfully converted to CP1251.")
            return True
    except Exception as e:
        print(f"  Failed to decode as UTF-8: {e}")
        
    try:
        cp1251_text = raw.decode('cp1251')
        if "Проверяем" in cp1251_text or "попадание" in cp1251_text or "Снимаем" in cp1251_text or "осей" in cp1251_text:
            print("  Detected CP1251 with Russian comments!")
            return True
    except Exception as e:
        print(f"  Failed to decode as CP1251: {e}")
        
    print("  Unknown or mixed encoding, or no Russian keywords found.")
    return False

COMP_DIR = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr"
check_and_convert(os.path.join(COMP_DIR, "uOglChartFrameListener.pas"))
check_and_convert(os.path.join(COMP_DIR, "uOglChartRenderer.pas"))
