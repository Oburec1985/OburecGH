import os

def main():
    files = [
        r"d:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas",
        r"d:\works\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartRenderer.pas"
    ]
    
    for target_file in files:
        with open(target_file, 'rb') as f:
            content = f.read()
            
        # Ищем {$mode ...} и добавляем после него {$codepage cp1251}
        mode_marker = b"{$mode objfpc}{$H+}"
        if mode_marker in content:
            replacement = mode_marker + b"\r\n{$codepage cp1251}"
            content = content.replace(mode_marker, replacement)
            with open(target_file, 'wb') as f:
                f.write(content)
            print(f"Added codepage to {os.path.basename(target_file)}")
        else:
            # Попробуем delphi режим
            mode_marker_delphi = b"{$mode delphi}"
            if mode_marker_delphi in content:
                replacement = mode_marker_delphi + b"\r\n{$codepage cp1251}"
                content = content.replace(mode_marker_delphi, replacement)
                with open(target_file, 'wb') as f:
                    f.write(content)
                print(f"Added codepage to {os.path.basename(target_file)} (delphi)")
            else:
                print(f"Mode marker not found in {os.path.basename(target_file)}")

if __name__ == '__main__':
    main()
