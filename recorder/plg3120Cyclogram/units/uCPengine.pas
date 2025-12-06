unit uCPengine;
// механизм измерения контрольных точек

interface
uses
  Windows, SysUtils, Variants, classes, dialogs,
  inifiles,
  recorder, tags,  urcfunc, cfreg,
  uexcel,
  uEventTypes, uRecorderEvents,
  uControlObj, uModeObj, uProgramObj,
  MathFunction, uCommonMath, uPathMng,
  pluginclass, u3120Db, u3120ControlObj, uGenReport,
  activex;

type


  // класс для измерения контрольных точек. Сперва инициализируется для привязки CallBack
  // Там же читает шаблон Excel для вычитки имен тегов с которыми надо работать
  // в событии UpdateTagsEvent если в состоянии работа для каждой записи TcpTag
  // считываем значение tag в m_val и суммируется, инкрементируется число замеров.
  // по завершению измерения через m_avrTime заданное в секундах делается деление m_val/num
  // процедура Start засекает время усреднения/ Stop - останавливает
  TCPengine = class
  public
    // события старта отбивания контрольной точки и останова
    fNewModeCp,
    fstartCp,
    fStopCp
    :tnotifyEvent;
    curmode, curmodeNotAutoCP:cmodeobj;
    // список TcpTag
    m_tagslist:tstringlist;
    m_needreadtags:boolean;
    m_testDir, m_repName:string;
    // время усреднения на CP
    m_avrTime,
    // время до старта CP
    m_Time:double;

  protected
    m_SelTmplt:integer;
    m_xlsTmplt:tstringlist; // шаблон excel
    // время старта измерений
    m_iT0:int64;
    // 0 - стоп; 1 - работа; 2 пошел новый режим и пока не считали
    m_state:integer;
  protected
    procedure setSelTmplt(i:integer);
    procedure OnExecMode(m:tobject);
    procedure clearTags;
    // событие обновления тегов
    //procedure updateTagsEvent(sender:tobject);
    // считать теги из шаблона отчета Excel
    procedure readTags(fname:string);
  public
    function checkRepPath:boolean;
    procedure resettags;
    procedure setTmplt(s:string);
    function getTmplt:string;overload;
    function getTmplt(i:integer):string;overload;
    function TmpltCount:integer;
    // инициация событий. plg после добавления события updateTagsEvent будет вызывать
    // его у себя как callBack
    procedure Init(plg:TExtRecorderPack);
    procedure doCP;
    procedure Prepare();
    procedure Start;
    procedure Stop;
    procedure OpenReport;
    // 0 - стоп; 1 - работа; 2 пошел новый режим и пока не считали
    property state:integer read m_state write m_state;
    property Tmplt:string read getTmplt write setTmplt;
    property SelTmpltIndex:integer read m_SelTmplt write setSelTmplt;
    constructor create;
    destructor destroy;
  end;

var g_CpEngine:TCPengine;

implementation
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
{ ************  Реализация TCPengine  ************* }


procedure TCPengine.clearTags;
var
  i: Integer;
  t:TcpTag;
begin
  for i := 0 to m_tagsList.Count - 1 do
  begin
    t:=TcpTag(m_tagsList.Objects[i]);
    t.Destroy;
  end;
  m_tagsList.Clear;
end;

constructor TCPengine.Create;
begin
  inherited;
  m_needreadtags:=true;
  m_xlsTmplt:= TStringList.Create;
  m_tagsList := TStringList.Create;
  m_state := 0;
  m_avrTime := 1.0;
end;

destructor TCPengine.Destroy;
begin
  clearTags;
  m_tagsList.Free;
  m_xlsTmplt.Free;
  inherited;
end;


procedure TCPengine.doCP;
var
  p:cProgramObj;
  t:double;
  i:integer;
  tagObj:TcpTag;
  d:TDataReport;
  first:boolean;
begin
  p:=cProgramObj(curmode.mainParent);
  // выжидаем время до старта
  t:=p.getModeTime;
  // старт точки
  if t>m_Time then
  begin
    first:=false;
    if (m_state=0) or (m_state=2) then
    begin
      m_state := 1; // вкл. отбитие точки
      first:=true;
      if assigned(fstartCp) then
        fstartCp(curmode);
    end;
    // собираем выборки
    if first or (m_avrtime>0) then
    begin
      for i := 0 to m_tagsList.Count - 1 do
      begin
        tagObj := TcpTag(m_tagsList.Objects[i]);
        tagObj.AddSample;
      end;
    end;
  end;
  if t>m_Time+m_avrTime then
  begin
    // собираем выборки
    // время истекло → останавливаем измерение
    m_state := 0;
    if assigned(fstopCp) then
      fstopCp(curmode);
    // усредняем
    for i := 0 to m_tagsList.Count - 1 do
    begin
      tagObj := TcpTag(m_tagsList.Objects[i]);
      tagObj.avr;
    end;
    d.m:=curmode;
    // TestPath + '\' + 'Report.xlsx'
    genreport(TestPath, 'Report.xlsx', tmplt,
              true, // закрыть Excel
              d,
              m_tagsList);
    for i := 0 to m_tagsList.Count - 1 do
    begin
      tagObj := TcpTag(m_tagsList.Objects[i]);
      tagObj.reset;
    end;
    // финализируем КТ
    curmode.ProcCP:=true;
  end;
end;

procedure TCPengine.Init(plg: TExtRecorderPack);
var
  ltmplt,objpath, mdb, dir:string;
begin
  // подключаем callback обновления тегов
  //AddPlgEvent('TCPengine_UpdateTagsEvent',c_RUpdateData, UpdateTagsEvent);

  m_xlsTmplt.Clear;
  mdb := BasePath;
  FindFileExt('tmpl', mdb, 2, m_xlsTmplt);
  //dir:='c:\Mera Files\mdb\3120\template\tmplt_report.xlsx';
  //if fileexists(dir) then
  //  m_tagslist.Add(dir);
end;

procedure TCPengine.OnExecMode(m: tobject);
begin
  if cmodeobj(m).AutoCp then
  begin
    if not cmodeobj(m).ProcCP then
    begin
      // если отбой точки после входа в допуск
      if cmodeobj(m).StartTimeOnTolerance then
      begin
        if cmodeobj(m).TrigInTolerance then
        begin
          if curmode<>cmodeobj(m) then
          begin
            m_state:=2; // старт нового режима
            if assigned(fNewModeCp) then
              fNewModeCp(m);
          end;
          curmode:=cmodeobj(m);
          doCP;
        end;
      end
      else
      begin
        if curmode<>cmodeobj(m) then
        begin
          m_state:=2; // старт нового режима
          if assigned(fNewModeCp) then
            fNewModeCp(m);
        end;
        curmode:=cmodeobj(m);
        doCP;
      end;
    end;

  end
  else
  begin
    if curmodeNotAutoCP<>m then
    begin
      fNewModeCp(m);
    end;
  end;
  curmodeNotAutoCP:=cmodeobj(m);
end;

function TCPengine.checkRepPath: boolean;
var
  rep:string;
begin
  rep:=TestPath + '\' + 'Report.xlsx';
  result:= fileexists(rep);
end;

procedure TCPengine.OpenReport;
var
  rep:string;
begin
  rep:=TestPath + '\' + 'Report.xlsx';
  if not fileexists(rep) then
    exit;
  KillAllExcelProcesses;
  InitExcel;
  OpenWorkBook(rep);
end;

procedure TCPengine.Prepare();
var
  i:integer;
  p:cProgramObj;
begin
  if m_needreadtags then
  begin
    // читаем теги из Excel шаблона
    ReadTags(Tmplt);
    m_testDir:=TestPath;
    for i:=0 to g_conmng.ProgramCount-1 do
    begin
      p:=g_conmng.getProgram(i);
      p.fOnExecMode:=OnExecMode;
    end;
  end;
  m_needReadTags:=false;
end;



procedure TCPengine.ReadTags(fname: string);
var
  r0, c0, c: Integer;
  ws, rngDate: OleVariant;
  tagName: string;
  it:itag;
  tagObj: TcpTag;
begin
  // очистить список от предыдущих данных
  clearTags;

  KillAllExcelProcesses;
  InitExcel;
  if not FileExists(fname) then
    Exit;
  OpenWorkBook(fname);
  // получаем именованный диапазон c_data — как в примере
  rngDate := GetRange(1, 'c_data');
  // верхняя строка с именами тегов
  r0 := rngDate.Row;
  c0 := rngDate.Column + 1;

  ws := E.ActiveWorkbook.Sheets[1];
  c := c0;
  tagName := ws.Cells[r0, c];

  // идём вправо по строке, пока ячейка не пустая
  while (Trim(tagName) <> '') do
  begin
    // ищем тег в системе
    it:=getTagByName(tagname);
    if it<>nil then
    begin
      tagObj:=TcpTag.Create;
      tagObj.name:=tagName;
      // создаём TcpTag и кладём в m_tagsList
      m_tagsList.AddObject(tagName, tagObj);
    end;
    Inc(c);
    tagName := ws.Cells[r0, c];
  end;
  // закрываем Excel
  CloseWorkBook;
  CloseExcel;
end;

procedure TCPengine.Start;
var
  i: Integer;
begin
  m_state := 1;

  // Сбросить накопленные значения
  for i := 0 to m_tagsList.Count - 1 do
    (m_tagsList.Objects[i] as TcpTag).Reset;
  QueryPerformanceCounter(m_iT0);
end;

procedure TCPengine.resettags;
var
  i: Integer;
begin
  // Сбросить накопленные значения
  for i := 0 to m_tagsList.Count - 1 do
    (m_tagsList.Objects[i] as TcpTag).Reset;
end;

procedure TCPengine.setSelTmplt(i: integer);
begin
  m_SelTmplt:=i;
end;

procedure TCPengine.setTmplt(s: string);
var
  I: Integer;
begin
  for I := 0 to m_xlsTmplt.Count - 1 do
  begin
    if m_xlsTmplt.Strings[i]=s then
    begin
      SelTmpltIndex:=i;
      break;
    end;
  end;
end;

procedure TCPengine.Stop;
begin
  m_state := 0;
end;


function TCPengine.getTmplt: string;
begin
  if m_SelTmplt<m_xlsTmplt.Count
   then
    result:=m_xlsTmplt.Strings[m_SelTmplt]
  else
    result:='';
end;

function TCPengine.getTmplt(i: integer): string;
begin
  result:=m_xlsTmplt.Strings[i];
end;

function TCPengine.TmpltCount: integer;
begin
  result:=m_xlsTmplt.Count;
end;

end.
