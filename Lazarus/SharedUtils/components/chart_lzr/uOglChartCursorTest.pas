unit uOglChartCursorTest;

{ objfpc}{+}

interface

uses
  Classes, SysUtils, uOglChartCursor, uOglChartBaseObj, uOglChartPage, uOglChartTrend;

procedure RunCursorTests;

implementation

procedure LogMsg(const AMsg: string);
begin
  if IsConsole then
    WriteLn(AMsg);
end;

procedure RunCursorTests;
var
  lPage: TChartPage;
  lCursor: TChartCursor;
  lTrend: cBuffTrend1d;
begin
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
