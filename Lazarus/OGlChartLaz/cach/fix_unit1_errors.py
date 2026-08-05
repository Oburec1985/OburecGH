import os

def main():
    target_file = r"d:\works\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"
    
    with open(target_file, 'rb') as f:
        content = f.read()

    # Ищем начало испорченного блока
    start_marker = b"function AddLine(AYAxis: cAxis; const AName, ACaption: string; AColor: Cardinal): cTrend;\r\nbegin\r\n"
    if start_marker not in content:
        start_marker = b"function AddLine(AYAxis: cAxis; const AName, ACaption: string; AColor: Cardinal): cTrend;\nbegin\n"

    end_marker = b"AYAxis.AddChild(Result);\r\nend;"
    if end_marker not in content:
        end_marker = b"AYAxis.AddChild(Result);\nend;"

    if start_marker in content and end_marker in content:
        idx_start = content.index(start_marker) + len(start_marker)
        # Ищем end_marker после idx_start
        idx_end = content.index(end_marker, idx_start) + len(end_marker)
        
        good_body = b"""  Result := cTrend.Create;
  Result.Name := AName;
  Result.Caption := ACaption;
  Result.Color := AColor;
  AYAxis.AddChild(Result);
end;"""
        # Нормализуем переводы строк в соответствии с исходным файлом
        if b"\r\n" in start_marker:
            good_body = good_body.replace(b'\n', b'\r\n').replace(b'\r\r\n', b'\r\n')
        else:
            good_body = good_body.replace(b'\r\n', b'\n')

        new_content = content[:idx_start] + good_body + content[idx_end:]
        with open(target_file, 'wb') as f:
            f.write(new_content)
        print("AddLine successfully fixed via markers!")
    else:
        print("Error: markers not found")

if __name__ == '__main__':
    main()
