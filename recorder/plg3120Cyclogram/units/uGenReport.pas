unit uGenReport;

interface

uses
  tags,
  uexcel, urcfunc, dialogs;

// генератор отчета. dir - каталог, RepName - имя отчета
// tmplt - шаблон отчета
function genreport(dir, repName: string; tmplt: string;
  closeReport: boolean): boolean;

implementation

uses
  SysUtils, Classes, ComObj, Variants;

procedure InitExcel;
begin
  if not CheckExcelInstall then
  begin
    showmessage('Необходима установка Excel');
    exit;
  end;
  if VarIsEmpty(E) then
  begin
    // if not CheckExcelRun then
    begin
      CreateExcel;
      VisibleExcel(true);
    end;
  end;
end;

function genreport(dir, repName: string; tmplt: string;
  closeReport: boolean): boolean;
var
  r0, r, c, i, j: integer;
  rng, ws: olevariant;
  date: tdatetime;
  t:itag;
  fname, res, val: string;
begin
  result := false;
  InitExcel;
  fname := dir + repName;
  if fileexists(fname) then
  begin
    if not IsExcelFileOpen(fname) then
    begin
      OpenWorkBook(fname);
    end
    else
    begin

    end;
  end
  else
  begin
    AddWorkBook;
    AddSheet('Page_01');
    // DeleteSheet(2);
  end;
  rng := GetRange(1, 'c_data');
  // 1 -sheet, 1 - r0, 2 - col
  r0 := GetEmptyRow(1, rng.Row, rng.Column + 1);
  begin
    i:=0;
    ws := E.ActiveWorkbook.Sheets[1];
    res := ws.cells[r0, rng.column+i];
    // заполняем колонки с тегами
    while res <> '' do
    begin
      t:=getTagByName(res);
      if t<>nil then
      begin
        SetCell(1, r0, rng.column+i, GetMean(t));
      end;
      inc(i);
      res := ws.cells[r0, rng.column+i];
    end;
  end;
  rng := GetRange(1, 'c_Signal');
  // путь к замеру
  SetCell(1, rng.Row, rng.Column, GetMeraFile);
  // SetCell(1, r0, 4, 'Time:');
  date := now;
  SetCell(1, r0, 5, DateToStr(date) + ' ' + TimeToStr(date));
  // ставим сетку всего блока
  rng := GetRangeObj(1, point(r0, rng.column), point(r0, i));
  SetRangeBorder(rng);
  SaveWorkBookAs(fname);
  if closeReport then
  begin
    CloseWorkBook;
    CloseExcel;
  end;
end;

end.
