unit uGenReport;

interface

uses
  classes,
  tags,
  uexcel, urcfunc, dialogs, uProgramObj,
  uControlObj, uModeObj;

type

  TcpTag = class
  protected
    tag: ctag;
    num: integer;
    m_val: double;
  private
  protected
    function getName: string;
    procedure setName(s: string);
  public
    function GetVal: double;
    // усреднить
    procedure Avr;
    procedure Reset;
    procedure AddSample;
    constructor Create;
    property Name: string read getName write setName;
  end;

  TDataReport = record
    m: cmodeobj;
  end;

  // генератор отчета. dir - каталог, RepName - имя отчета
  // tmplt - шаблон отчета
function genreport(dir, repName, tmplt: string;
                   closeReport: boolean;
                   d: TDataReport;
                   tlist: tstringlist; var err:integer): boolean;
function SecToTime(t: double; p_type: integer): double;
function GetVal(s: string; list: tstringlist): double;

implementation

uses
  SysUtils, ComObj, Variants;

function GetVal(s: string; list: tstringlist): double;
var
  i: integer;
  t: TcpTag;
  it: itag;
begin
  for i := 0 to list.Count - 1 do
  begin
    t := TcpTag(list.Objects[i]);
    if t.Name = s then
    begin
      if t.num = 0 then
      begin
        result := GetMean(t.tag.tag);
      end
      else
      begin
        result := t.m_val;
      end;
      exit;
    end;
  end;
  it := getTagByName(s);
  if it <> nil then
    result := GetMean(it);
end;

{ ************  Реализация TcpTag  ************* }

procedure TcpTag.Avr;
begin
  m_val := m_val / num;
end;

constructor TcpTag.Create;
begin
  inherited Create;
  tag := ctag.Create;
  num := 0;
  m_val := 0;
end;

function TcpTag.getName: string;
begin
  result := tag.tagname;
end;

procedure TcpTag.setName(s: string);
begin
  tag.tagname := s;
end;

procedure TcpTag.Reset;
begin
  num := 0;
  m_val := 0;
end;

procedure TcpTag.AddSample;
var
  v: double;
begin
  // Чтение значения тега — заменить на вашу функцию!
  v := tag.GetMeanEst;
  m_val := m_val + v;
  Inc(num);
end;

function TcpTag.GetVal: double;
begin
  if num = 0 then
    result := 0
  else
    result := m_val / num;
end;

function SecToTime(t: double; p_type: integer): double;
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
      VisibleExcel(false);
    end;
  end;
end;

function genreport(dir, repName: string; tmplt: string; closeReport: boolean;
  d: TDataReport; tlist: tstringlist; var err:integer): boolean;
var
  r0, c0, r, c, i, j: integer;
  rngSig, rngDate, rng, ws: olevariant;
  date: tdatetime;
  t: itag;
  v: double;
  book, fname, res, val: string;
begin
  result := false;
  err:=1;
  KillAllExcelProcesses;
  InitExcel;
  if fileexists(dir + '\' + repName) then
  begin
    err:=2;
    book := dir + '\' + repName;
  end
  else
  begin
    err:=3;
    if fileexists(tmplt) then
    begin
      book := tmplt;
    end;
  end;
  err:=4;
  OpenWorkBook(book);
  err:=5;
  // заполняем шапку
  rngDate := GetRange(1, 'c_data');
  if not CheckVarObj(rngDate) then
  begin
    exit;
  end;
  r0 := rngDate.row;
  c0 := rngDate.column + 1;
  // поиск пустой строки
  err:=6;
  r := GetEmptyRow(1, rngDate.row, rngDate.column + 1);
  ws := E.ActiveWorkbook.Sheets[1];
  // смещение к сигналу +1
  c := c0;
  res := ws.cells[r0, c];
  err:=7;
  // заполняем колонки с тегами
  while res <> '' do
  begin
    v := GetVal(res, tlist);
    SetCell(1, r, c, v);
    Inc(c);
    res := ws.cells[r0, c];
  end;
  err:=8;
  rngSig := GetRange(1, 'c_Signal');
  // путь к замеру
  err:=9;
  SetCell(1, r, rngSig.column, GetMeraFile);
  // SetCell(1, r0, 4, 'Time:');
  date := now;
  SetCell(1, r, rngDate.column, DateToStr(date) + ' ' + TimeToStr(date));

  rng := GetRange(1, 'c_Mode');
  if d.m <> nil then
  begin
    SetCell(1, r, rng.column, d.m.caption);
    v := cprogramObj(d.m.mainparent).getModeTime;
    SetCell(1, r, rng.column+1, v);
  end;
  err:=10;
  // ставим сетку всего блока
  rng := GetRangeObj(1, point(r0, rngSig.column), point(r, c));
  SetRangeBorder(rng);
  err:=11;
  SaveWorkBookAs(dir + '\' + repName);
  if closeReport then
  begin
    CloseWorkBook;
    CloseExcel;
  end;
  result:=true;
  err:=0;
end;

end.
