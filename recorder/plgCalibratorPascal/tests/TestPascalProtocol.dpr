program TestPascalProtocol;

{$APPTYPE CONSOLE}

uses
  SysUtils;

function CalcChecksum(const ACmd: string): string;
var
  lSum, i: Integer;
begin
  lSum := 0;
  for i := 1 to Length(ACmd) do
    Inc(lSum, Ord(ACmd[i]));
  Result := ACmd + '$' + Format('%.2X', [lSum mod 256]) + #13#10;
end;

function ParsePressure(const AResponse: string; var APressure: Double): Boolean;
var
  lCleanStr: string;
  i: Integer;
  fs: TFormatSettings;
begin
  Result := False;
  lCleanStr := '';
  for i := 1 to Length(AResponse) do
  begin
    if AResponse[i] in ['0'..'9', '-', '.', ','] then
      lCleanStr := lCleanStr + AResponse[i]
    else if lCleanStr <> '' then
      Break;
  end;

  if lCleanStr = '' then Exit;

  fs.DecimalSeparator := '.';
  lCleanStr := StringReplace(lCleanStr, ',', '.', [rfReplaceAll]);

  try
    APressure := StrToFloat(lCleanStr, fs);
    Result := True;
  except
    try
      fs.DecimalSeparator := ',';
      APressure := StrToFloat(lCleanStr, fs);
      Result := True;
    except
    end;
  end;
end;

procedure TestCRC;
var
  lCmd, lRes: string;
begin
  Writeln('--- Тест контрольной суммы Elmetra Pascal ---');
  
  lCmd := 'PRESSURE? 2';
  lRes := CalcChecksum(lCmd);
  Writeln('Cmd: "' + lCmd + '" -> "' + Trim(lRes) + '"');
  if Pos('$0A', lRes) > 0 then Writeln('  PASS') else Writeln('  FAIL (expected $0A)');

  lCmd := 'DEVICE? ';
  lRes := CalcChecksum(lCmd);
  Writeln('Cmd: "' + lCmd + '" -> "' + Trim(lRes) + '"');
  if Pos('$0F', lRes) > 0 then Writeln('  PASS') else Writeln('  FAIL (expected $0F)');

  lCmd := 'LOCAL';
  lRes := CalcChecksum(lCmd);
  Writeln('Cmd: "' + lCmd + '" -> "' + Trim(lRes) + '"');
  if Pos('$6B', lRes) > 0 then Writeln('  PASS') else Writeln('  FAIL (expected $6B)');

  lCmd := 'R';
  lRes := CalcChecksum(lCmd);
  Writeln('Cmd: "' + lCmd + '" -> "' + Trim(lRes) + '"');
  if Pos('$52', lRes) > 0 then Writeln('  PASS') else Writeln('  FAIL (expected $52)');
end;

procedure TestParsing;
var
  lInput: string;
  lVal: Double;
begin
  Writeln('--- Тест парсинга ответа калибратора ---');

  lInput := '100.25 kPa$AA'#13#10;
  if ParsePressure(lInput, lVal) and (Abs(lVal - 100.25) < 0.001) then
    Writeln('Input: "' + Trim(lInput) + '" -> ' + FloatToStr(lVal) + ' (PASS)')
  else
    Writeln('Input: "' + Trim(lInput) + '" -> FAIL');

  lInput := '-0.057 ati$B1';
  if ParsePressure(lInput, lVal) and (Abs(lVal - (-0.057)) < 0.001) then
    Writeln('Input: "' + Trim(lInput) + '" -> ' + FloatToStr(lVal) + ' (PASS)')
  else
    Writeln('Input: "' + Trim(lInput) + '" -> FAIL');

  lInput := '100,5';
  if ParsePressure(lInput, lVal) and (Abs(lVal - 100.5) < 0.001) then
    Writeln('Input: "' + Trim(lInput) + '" -> ' + FloatToStr(lVal) + ' (PASS)')
  else
    Writeln('Input: "' + Trim(lInput) + '" -> FAIL');
end;

begin
  try
    TestCRC;
    Writeln;
    TestParsing;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  Writeln('Нажмите Enter для выхода...');
  // В неинтерактивном тесте мы можем обойтись без Readln, но для ручного запуска оставим
end.