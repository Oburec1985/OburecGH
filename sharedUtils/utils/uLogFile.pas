unit uLogFile;

interface
uses
  sysutils, classes, Grids, uSetList, types, graphics, uComponentServises,
  windows, uBinFile, dialogs;

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
    strNum:integer;

    achars:array [0..500] of ansichar;
  public
    // ������ ������ ������ ���� ������ � ����� ������������
    m_Rewrite:boolean;
    fOnAddRecord:tNotifyEvent;
  protected
    // �������� ������ � ����� �����
    procedure addstring(Mes:string;mesType:string);
    // �������� ������ � ���������
    procedure addRecord(date:tDateTime;Mes:string;mesT:cardinal);
    procedure LogSGDrawCell(Sender: TObject; ACol, ARow: Integer;
              Rect: TRect; State: TGridDrawState);
    procedure InitCS;
    procedure DeleteCS;
  public
    function  TryEnterCS:boolean;
    procedure EnterCS;
    procedure ExitCS;
    // -1 ������ �� ������. 1 - ������ ������ ������ �������; 0 - ������ ������� �������
    function CheckCS: integer;
    // �������� ������ � ������� � ���
    procedure addErrorMes(Mes:string);
    // �������� ������ � ����������� � ���
    procedure addInfoMes(Mes:string);
    constructor create(name:string; p_separator:char);
    // �������� ������� � ����� �������
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

    colNumber = '�';
    colDsc = '��������';
    colType = '���';
    colDate = '�����';
  var
    g_logFile:cLogFile;

function StrToAnsi(s: string): ansistring;

implementation


function StrToAnsi(s: string): ansistring;
var
  astr: ansistring;
  i: integer;
begin
  for i := 1 to length(s) do
  begin
    astr := astr + s[i];
  end;
  result := lpcstr(astr);
end;


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

constructor cLogFile.create(name:string; p_separator:char);
begin
  separator:=p_separator;
  InitCS;
  records:=cLogRecords.create;
  filename:=name;
  entercs;
  Assign(f, filename);
  // ��������� ��� ������
  Rewrite(f);
  // ������ ������ �� ������ ����
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
  astr:ansistring;
  ch:char;
  lf:file;
  fSize, pos:longint;
  readed, t:integer;
  p:pointer;
  I: Integer;
begin
  date:=now;
  t:=GetCurrentThreadId;
  datestr:=DateToStr(date)+' '+TimeToStr(date)+ ' tid: '+inttostr(t);
  str:=datestr+separator+mes+separator+mesType;
  if TryEnterCS then
  begin
    //if t<>cs.OwningThread then
    //begin
      //showmessage('hex');
    //end;
    if m_Rewrite then
    begin
      pos:=0;
      Assign(lf, filename);
      Reset(lf, 1);
      fsize:=FileSize(lf);
      pos:=fsize;
      if fsize=0 then
      begin
        astr:=StrtoAnsi(str);
        BlockWrite(lf, astr[1], length(astr));
      end
      else
      begin
        while pos>0 do
        begin
          dec(pos);
          Seek(lf, pos);
          BlockRead(lf, ch, 1, readed);
          if (ch=char(13)) or (ch=char(10)) or (pos=0) then
          begin
            Seek(lf, pos);
            Truncate(lf);
            for I := 1 to length(str) do
            begin
              achars[i-1]:=ansichar(str[i]);
            end;
            //astr:=StrtoAnsi(str);
            // ������ ������ �� ������ ����
            BlockWrite(lf, achars[0], length(str));
          end;
        end;
      end;
      CloseFile(lf);
    end
    else
    begin
      AssignFile(f, filename);
      // ��������� ��� ������
      append(f);
      // ������ ������ �� ������ ����
      writeln(f, str);
      CloseFile(f);
    end;
    exitcs;
  end;
  if mesType=c_ErrorMes then
    t:=c_RecType_ErrorMes;
  if mesType=c_InfoMes then
    t:=c_RecType_InfoMes;
  // ���������� ������ � ����������
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

function  cLogFile.TryEnterCS:boolean;
begin
  result:=TryEnterCriticalSection(cs);
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
  // ����� ������
  col:=getcolumn(sg,colNumber);
  sg.Cells[col,row]:=inttostr(row);
  // ����
  col:=getcolumn(sg,colDate);
  datestr:=DateToStr(rec.date)+' '+TimeToStr(rec.date);
  sg.Cells[col,row]:=datestr;
  // ��������� ���������
  col:=getcolumn(sg,colDsc);
  sg.Cells[col,row]:=rec.mes;
  // ��������� ���������
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
