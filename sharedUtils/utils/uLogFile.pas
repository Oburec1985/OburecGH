unit uLogFile;

interface
uses
  sysutils, classes, Grids, uSetList, types, graphics, uComponentServises,
  windows;

type

  cLogRecord = class
  public
    date:tdatetime;
    mes:string;
    mesType:cardinal;
  end;

  cLogRecords = class(cSetList)
  public
  public
    constructor create;override;
    procedure add(rec:cLogRecord);
    function getRecord(i:integer):cLogRecord;
    function GetLoRecord(rec:cLogRecord; var index:integer):cLogRecord;
    function GetHiRecord(rec:cLogRecord; var index:integer):cLogRecord;
  public
  protected
    procedure deletechild(node:pointer);override;
  end;

  cLogFile = class
  public
    records:cLogRecords;
    filename:string;
  protected
    cs: TRTLCriticalSection;
    f:textfile;
    separator:char;
  public
    fOnAddRecord:tNotifyEvent;
  protected
    // Записать строку в конец файла
    procedure addstring(Mes:string;mesType:string);
    // добавить строку в оперативу
    procedure addRecord(date:tDateTime;Mes:string;mesT:cardinal);
    procedure LogSGDrawCell(Sender: TObject; ACol, ARow: Integer;
              Rect: TRect; State: TGridDrawState);
    procedure InitCS;
    procedure DeleteCS;
  public
    procedure EnterCS;
    procedure ExitCS;
    // -1 секция не занята. 1 - секция занята другим потоком; 0 - занята текущим потоком
    function CheckCS: integer;
    // Записать строку с ошибкой в лог
    procedure addErrorMes(Mes:string);
    // Записать строку с информацией в лог
    procedure addInfoMes(Mes:string);
    constructor create(name:string; separator:char);
    // добавить строчку в конец журнала
    destructor destroy;
  end;

  procedure InitSG(sg:tStringGrid;log:cLogFile);  
  procedure ShowInSG(sg:tStringGrid; log:cLogFile);
  procedure logMessage(str: string);


  const
    c_RecType_ErrorMes = 0;
    c_RecType_InfoMes = 1;

    c_ErrorMes = 'Error';
    c_InfoMes = 'Info';

    colNumber = '№';
    colDsc = 'Описание';
    colType = 'Тип';
    colDate = 'Время';
  var
    g_logFile:cLogFile;

implementation


procedure logMessage(str: string);
begin
  if g_logFile <> nil then
    g_logFile.addInfoMes(str);
end;

function proccomparator(p1,p2:pointer):integer;
begin
  if cLogRecord(p1).date>cLogRecord(p2).date then
    result:=1
  else
  begin
    if cLogRecord(p1).date<cLogRecord(p2).date then
      result:=-1
    else
      result:=0;
  end;
end;

constructor cLogRecords.create;
begin
  inherited;
  destroydata:=true;
  comparator:=proccomparator;
end;

procedure cLogRecords.deletechild(node:pointer);
begin
  cLogRecord(node).destroy;
end;

procedure cLogRecords.add(rec:cLogRecord);
begin
  AddObj(rec);
end;

function cLogRecords.getRecord(i:integer):cLogRecord;
begin
  if i<=count-1 then
  begin
    result:=cLogRecord(getnode(i));
  end;
end;

function cLogRecords.GetLoRecord(rec:cLogRecord; var index:integer):cLogRecord;
begin
  result:=cLogRecord(GetLow(rec,index));
end;

function cLogRecords.GetHiRecord(rec:cLogRecord; var index:integer):cLogRecord;
begin
  result:=cLogRecord(GetHight(rec,index));
end;

constructor cLogFile.create(name:string; separator:char);
begin
  InitCS;
  records:=cLogRecords.create;
  filename:=name;
  entercs;
  Assign(f, filename);
  // открываем для записи
  Rewrite(f);
  // запись строки во второй файл
  //writeln(f, str);
  CloseFile(f);
  exitcs;
end;

destructor cLogFile.destroy;
begin
  deletecs;
  records.destroy;
  //if assigned(@f) then
  //  closefile(f);
end;

procedure cLogFile.addRecord(date:tDateTime;Mes:string;mesT:cardinal);
var
  rec:cLogRecord;
begin
  rec:=cLogRecord.Create;
  rec.date:=date;
  rec.mes:=mes;
  rec.mesType:=mesT;
  Records.add(rec);
  if assigned(fOnAddRecord) then
    fOnAddRecord(rec);
end;

procedure cLogFile.addstring(Mes:string;mesType:string);
var
  date:tdatetime;
  datestr:string;
  str:string;
  t:cardinal;
begin
  date:=now;
  datestr:=DateToStr(date)+' '+TimeToStr(date)+ 'tid: '+inttostr(GetCurrentThreadId);
  str:=datestr+separator+mes+separator+mesType;
  EnterCS;
  Assign(f, filename);
  // открываем для записи
  append(f);
  // запись строки во второй файл
  writeln(f, str);
  CloseFile(f);
  exitcs;
  if mesType=c_ErrorMes then
    t:=c_RecType_ErrorMes;
  if mesType=c_InfoMes then
    t:=c_RecType_InfoMes;
  // добавление строки в оперативку
  addRecord(date,mes,t);
end;

procedure cLogFile.addErrorMes(Mes:string);
begin
  addstring(Mes, c_ErrorMes);
end;

procedure cLogFile.addInfoMes(Mes:string);
begin
  addstring(Mes, c_InfoMes);
end;

procedure cLogFile.LogSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  rec:cLogRecord;
begin
  EnterCS;
  if tStringGrid(sender).Objects[0,arow]<>nil then
  begin
    rec:=cLogRecord(tStringGrid(sender).Objects[0,arow]);
    if rec.mesType=c_RecType_ErrorMes then
      tStringGrid(sender).Canvas.Brush.color:=clRed;
    if rec.mesType=c_RecType_InfoMes then
      tStringGrid(sender).Canvas.Brush.color:=clWhite;
  end;
  tStringGrid(sender).Canvas.FillRect(Rect);
  if ARow<>0 then
    tStringGrid(sender).Canvas.TextOut(Rect.Left, Rect.Top,tStringGrid(sender).Cells[ACol,ARow]);
  exitcs;
end;

procedure cLogFile.InitCS;
begin
  InitializeCriticalSection(cs);
end;

procedure cLogFile.DeleteCS;
begin
  DeleteCriticalSection(cs);
end;

procedure cLogFile.EnterCS;
begin
  EnterCriticalSection(cs);
end;

procedure cLogFile.ExitCS;
begin
  LeaveCriticalSection(cs);
end;

function cLogFile.CheckCS: integer;
begin
  result := -1;
  GetCurrentThreadId;
  if cs.LockCount <> 0 then
  begin
    if cs.OwningThread <> GetCurrentThreadId then
    begin
      result := 1;
    end
    else
      result := 0;
  end;
end;

procedure InitSG(sg:tStringGrid;log:cLogFile);
begin
  sg.OnDrawCell:=log.LogSGDrawCell;
  sg.ColCount:=4;
  sg.Cells[0,0]:=colNumber;
  sg.Cells[1,0]:=colDate;
  sg.Cells[2,0]:=colDsc;
  sg.Cells[3,0]:=colType;    
end;

procedure AddRow(SG:TStringGrid; rec:cLogRecord; row:integer);
var
  col:integer;
  datestr:string;
begin
  // номер строки
  col:=getcolumn(sg,colNumber);
  sg.Cells[col,row]:=inttostr(row);
  // дата
  col:=getcolumn(sg,colDate);
  datestr:=DateToStr(rec.date)+' '+TimeToStr(rec.date);
  sg.Cells[col,row]:=datestr;
  // строковое сообщение
  col:=getcolumn(sg,colDsc);
  sg.Cells[col,row]:=rec.mes;
  // строковое сообщение
  col:=getcolumn(sg,colType);
  if rec.mesType=c_RecType_ErrorMes then
    sg.Cells[col,row]:=c_ErrorMes;
  if rec.mesType=c_RecType_InfoMes then
    sg.Cells[col,row]:=c_InfoMes;
  sg.objects[0,row]:=rec;
end;

procedure ShowInSG(sg:tStringGrid; log:cLogFile);
var
  i:integer;
  rec:cLogRecord;
begin
  log.EnterCS;
  sg.RowCount:=log.records.Count+1;
  for I := 1 to sg.rowcount - 1 do
  begin
    rec:=log.records.getRecord(i-1);
    addrow(sg,rec,i);
  end;
  log.ExitCS;
end;





end.
