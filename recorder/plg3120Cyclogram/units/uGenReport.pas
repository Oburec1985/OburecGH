unit uGenReport;

interface

uses
  tags,
  uexcel, urcfunc, dialogs,
  uControlObj, uModeObj;

type

  TDataReport = record
    m:cmodeobj;
  end;

// генератор отчета. dir - каталог, RepName - имя отчета
// tmplt - шаблон отчета
function genreport(dir, repName: string; tmplt: string; closeReport: boolean; d:TDataReport): boolean;
function SecToTime(t: double; p_type:integer): double;

implementation

uses
  SysUtils, Classes, ComObj, Variants;

function SecToTime(t: double; p_type:integer): double;
begin
  case p_type of
    0:
      result := t; // sec
    1:
      result := t / 60; // min
    2:
      result := t / 3600; // hour
  end;
end;

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

function genreport(dir, repName: string; tmplt: string; closeReport: boolean; d:TDataReport): boolean;
var
  r0,c0, r, c, i, j: integer;
  rngSig, rngDate,rng, ws: olevariant;
  date: tdatetime;
  t:itag;
  book,fname, res, val: string;
begin
  result := false;
  KillAllExcelProcesses;
  InitExcel;
  if fileexists(dir+'\'+repname) then
  begin
    book:=dir+'\'+repname;
  end
  else
  begin
    if fileexists(tmplt) then
    begin
      book:=tmplt;
    end;
  end;
  OpenWorkBook(book);
  // заполняем шапку

  rngDate := GetRange(1, 'c_data');
  r0:=rngDate.row;
  c0:=rngDate.column+1;
  r:=GetEmptyRow(1, rngDate.Row, rngDate.Column + 1);
  ws := E.ActiveWorkbook.Sheets[1];
  // смещение к сигналу +1
  c:=c0;
  res := ws.cells[r0, c];
  // заполняем колонки с тегами
  while res <> '' do
  begin
    t:=getTagByName(res);
    if t<>nil then
    begin
      SetCell(1, r, c, GetMean(t));
    end;
    inc(c);
    res := ws.cells[r0, c];
  end;
  rngSig := GetRange(1, 'c_Signal');
  // путь к замеру
  SetCell(1, r, rngSig.Column, GetMeraFile);
  // SetCell(1, r0, 4, 'Time:');
  date := now;
  SetCell(1, r, rngDate.column, DateToStr(date) + ' ' + TimeToStr(date));

  rng := GetRange(1, 'c_Mode');
  if d.m<>nil then
  begin
    SetCell(1, r, rng.column, d.m.name);
    SetCell(1, r, rng.column+1, floattostr(SecToTime(d.m.ModeLength, 1)));
  end;
  // ставим сетку всего блока
  rng := GetRangeObj(1, point(r0, rngSig.column), point(r, c));
  SetRangeBorder(rng);
  SaveWorkBookAs(dir+'\'+repname);
  if closeReport then
  begin
    CloseWorkBook;
    CloseExcel;
  end;
end;

end.
