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
    curmode:cmodeobj;
    // список TcpTag
    m_tagslist:tstringlist;
    m_selitem:integer;
    m_needreadtags:boolean;
    m_testDir:string;
  protected
    m_xlsTmplt:tstringlist; // шаблон excel
    // время усреднения на CP
    m_avrTime,
    // время до старта CP
    m_Time:double;
    // время старта измерений
    m_iT0:int64;
    // 0 - стоп; 1 - работа
    m_state:integer;
  protected
    procedure OnExecMode(m:tobject);
    procedure clearTags;
    // событие обновления тегов
    //procedure updateTagsEvent(sender:tobject);
    // считать теги из шаблона отчета Excel
    procedure readTags(fname:string);
  public
    procedure resettags;
    function Tmplt:string;
    // инициация событий. plg после добавления события updateTagsEvent будет вызывать
    // его у себя как callBack
    procedure Init(plg:TExtRecorderPack);
    procedure doCP;
    procedure Prepare();
    procedure Start;
    procedure Stop;
    constructor create;
    destructor destroy;
  end;

implementation
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
begin
  p:=cProgramObj(curmode.mainParent);
  // выжидаем время до старта
  t:=p.getModeTime;
  // старт точки
  if t>m_Time then
  begin
    m_state := 1; // вкл. отбитие точки
    // собираем выборки
    for i := 0 to m_tagsList.Count - 1 do
    begin
      tagObj := TcpTag(m_tagsList.Objects[i]);
      tagObj.AddSample;
    end;
  end;
  if t>m_Time+m_avrTime then
  begin
    // собираем выборки
    // время истекло → останавливаем измерение
    m_state := 0;
    // усредняем
    for i := 0 to m_tagsList.Count - 1 do
    begin
      tagObj := TcpTag(m_tagsList.Objects[i]);
      tagObj.avr;
    end;
    d.m:=curmode;
    genreport(TestPath, 'Report.xlsx', tmplt, false, d, m_tagsList);
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
  FindFileExt('tmplt', mdb, 2, m_xlsTmplt);
  ltmplt:=Tmplt;
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
          curmode:=cmodeobj(m);
          doCP;
        end;
      end
      else
      begin
        curmode:=cmodeobj(m);
        doCP;
      end;
    end;
  end;
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

procedure TCPengine.Stop;
begin
  m_state := 0;
end;


function TCPengine.Tmplt: string;
begin
  if m_selitem<m_xlsTmplt.Count
   then
    result:=m_xlsTmplt.Strings[m_selitem]
  else
    result:='';
end;
{
procedure TCPengine.UpdateTagsEvent(Sender: TObject);
var
  i: Integer;
  it, ifreq, di64: Int64;
  dt:double;
  tagObj: TcpTag;
begin
  if m_state = 0 then Exit; // если стоп — ничего не делаем

  QueryPerformanceCounter(it);
  QueryPerformanceFrequency(ifreq);
  di64 := decI64(m_iT0, it);
  dt := di64 / ifreq;

  // усреднять до тех пор, пока не прошло заданное время
  if dt < m_avrTime then
  begin
    // собираем выборки
    for i := 0 to m_tagsList.Count - 1 do
    begin
      tagObj := TcpTag(m_tagsList.Objects[i]);
      tagObj.AddSample;
    end;
  end
  else
  begin
    // время истекло → останавливаем измерение
    m_state := 0;
    // усредняем
    for i := 0 to m_tagsList.Count - 1 do
    begin
      tagObj := TcpTag(m_tagsList.Objects[i]);
      tagObj.m_val:=tagObj.m_val/tagObj.num;
    end;
  end;
end;}

end.
