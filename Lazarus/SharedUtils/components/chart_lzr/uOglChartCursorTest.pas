unit uOglChartCursorTest;

{
  Модуль uOglChartCursorTest
  Описание: Модульные тесты для проверки логики и математики интерактивного курсора.
}



{ objfpc}{+}



interface



uses

  Classes, SysUtils, uOglChartTypes, uOglChartCursor, uOglChartBaseObj, uOglChartPage, uOglChartTrend;



procedure RunCursorTests;



implementation



procedure LogMsg(const AMsg: string);
var
  lFile: TextFile;
  lPath: string;
begin
  if IsConsole then
    WriteLn(AMsg);
  lPath := ExtractFilePath(ParamStr(0)) + 'cursor_test.log';
  AssignFile(lFile, lPath);
  if FileExists(lPath) then
    Append(lFile)
  else
    Rewrite(lFile);
  WriteLn(lFile, AMsg);
  CloseFile(lFile);
end;



procedure RunCursorTests;

var

  lPage: TChartPage;

  lCursor: TChartCursor;

  lTrend: cBuffTrend1d;

begin
  DeleteFile(ExtractFilePath(ParamStr(0)) + 'cursor_test.log');
  LogMsg('--- RUNNING CURSOR TESTS ---');

  

  lPage := TChartPage.Create;

  try

    lPage.Name := 'TestPage';

    lCursor := GetOrCreatePageCursor(lPage);

    

    if not Assigned(lCursor) then

      raise Exception.Create('Ошибка: Курсор не был создан.');

    if lCursor.Visible then

      raise Exception.Create('Ошибка: Курсор должен быть скрыт по умолчанию.');

    if lCursor.CursorType <> cctSingle then

      raise Exception.Create('Ошибка: Тип курсора должен быть cctSingle.');
      
    if lCursor.MultiLineMode <> mlDisabled then
      raise Exception.Create('Ошибка: Режим мультилинейности должен быть mlDisabled по умолчанию.');

    lCursor.MultiLineMode := mlEnabled;
    if lCursor.MultiLineMode <> mlEnabled then
      raise Exception.Create('Ошибка: Не удалось переключить MultiLineMode в mlEnabled.');

    lCursor.MultiLineMode := mlShowNames;
    if lCursor.MultiLineMode <> mlShowNames then
      raise Exception.Create('Ошибка: Не удалось переключить MultiLineMode в mlShowNames.');

    lCursor.MultiLineMode := mlDisabled;

      

    lCursor.Visible := True;

    lCursor.X1 := 1.25;

    lCursor.X2 := 3.5;

    lCursor.CursorType := cctDouble;

    lCursor.ShowLabel := True;

    

    if lCursor.X1 <> 1.25 then

      raise Exception.Create('Ошибка: Неверное значение X1.');

    if lCursor.X2 <> 3.5 then

      raise Exception.Create('Ошибка: Неверное значение X2.');

      

    LogMsg('Cursor properties and defaults verification: SUCCESS');

    

    lTrend := cBuffTrend1d.Create;

    try

      lTrend.Name := 'TestTrend';

      lTrend.X0 := 0.0;

      lTrend.DX := 1.0;

      lTrend.AddValue(10.0);

      lTrend.AddValue(12.0);

      lTrend.AddValue(8.0);

      lTrend.AddValue(15.0);

      lTrend.AddValue(9.0);

      lPage.AddChild(lTrend);

      

      LogMsg('Cursor trend creation example: SUCCESS');

    finally

    end;

  finally

    lPage.Free;

  end;

  

  LogMsg('--- ALL CURSOR TESTS COMPLETED SUCCESSFULLY ---');

end;



end.

