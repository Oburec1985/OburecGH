unit uRCFunc;

interface

uses
  Windows,
  recorder,
  tags,
  types,
  plugin,
  iplgmngr,
  ActiveX,
  SysUtils,
  SyncObjs,
  Classes,
  ExtCtrls,
  blaccess,
  uEventList,
  uRecorderEvents,
  dialogs,
  nativexml,
  inifiles,
  uCommonTypes,
  ucommonmath,
  umymath,
  u2dmath,
  uPathMng,
  uHardwareMath,
  complex,
  //uAlarms,
  variants;

type

  cTag = class
  private
    ftag: itag;
    ftagname: string;
    //alarmHandler:IAlarmsHandler;

    // индекс последнего актуального значения в массиве m_ReadData/ Точнее адрес
    // в который придет новый буфер данных.
    m_lastindex: integer;
    // отладочная переменная (время последнего вычитанного блока)
    fdevicetime: double;
    // 1/freq
    fdT:double;
    // потеря в очередном updatetagdata
    m_looseData,
    // первый полученный блок. инициализируется в doStart, используется в BuildReadBuff
    m_firstBlock: boolean;
  public
    // делать склейку непрерывного буфера в updateTagData.
    m_useReadBuffer:boolean;
    useEcm:boolean;
    owner:tstringlist;
    m_createOutTag: boolean;
    m_newBlockCount, // кол-о новых (не обработанных) блоков в кольцевом буфере
    // кол-во обработанных блоков исходного тега
    // должно быть приватным. Не в точности равно readyBlock считанному из IBlockAccess
    // т.к. нужна переменная которая хранит число обработанных блоков именно алгоритмом для определения кол-ва новых блоков
    // становится равно readyBlock считанному из IBlockAccess в методе dogetdata после чего новые данные
    // из m_ReadData попадают в обработку
    m_readyBlock: integer;

    // размер блока рекордреа в секндах
    m_blLen,
    // размер всей истории рекордера
    m_TagLen:double;

    ftagid: tagid;

    fBlock: IBlockAccess;
    // определяет размер буфера который сможет вместить m_ReadData
    fBlCount: integer;

    // данные последнего блока. По идее бы сделать его Private
    // считывается из itag
    m_TagData: array of double;
    // function GetVectorPairR8(var Block; const Index: longint; const Size: longint;
    // const Tare: boolean): HRESULT; stdcall;
    m_TagData2d: array of point2d;
    // размер буфера m_ReadData
    m_ReadSize: integer;
    // Несколько сшитых блоков. Можно пропустить событие обновления данных тега
    // тогда на очередном шаге вычитки данных придется вычитать несколько блоков
    // из кольцевого буфера Recorder. данные складываются в m_ReadData
    // m_ReadData не кольцевой!!!
    m_ReadData: array of double;
    // время первого отсчета в m_ReadData
    m_ReadDataTime: double;

    // массив значений который пишется в itag (по идее здесь результаты расчетов алгоритмов)
    // кольцевой буфер
    m_WriteData: array of double;
    m_WriteDataX: array of double;
    // Размер кольцевого буфера
    m_WriteDataSize: integer;
    // индекс последнего актуального значения в массиве m_WriteData/ Точнее адрес
    // в который придет новый буфер данных.
    m_lastIndWriteData: integer;
    // количество посчитанных выходных данных с момента doOnStart
    m_ReadyVals: cardinal;

    // время последнего блока
    m_timeShtamp: double;
    // нгомер последнего блока
    m_timeShtamp_i: cardinal;
  public

  protected
    procedure setBlock(b: IBlockAccess);
    procedure settagname(s: string);
    function Gettagname: string;
    function getfreq: double;
    procedure setfreq(f: double);
    // работа с выходным кольцевым буфером
    function getReadyVals: cardinal;
    procedure setReadyVals(f: cardinal);
    procedure settagid(t: tagid);

    function ConvertIndInLoopBuff(i: integer): integer;
  public
    function GetIsScalar: boolean;
    function readyBlockCount: cardinal;
    // t время
    procedure PutOutValue(v, t: double);
    // получить i-е значение тега. При этом результат ведет себя так будто выходной буфер не кольцевой
    // т.е. посл значение может быть в нулевом индексе, однако посл. значению будет соответствовать i=OutSize-1
    function GetOutValue(i: integer): double;

    procedure settag(t: itag);
    procedure doOnStart;
    function BlockSize: integer;
    // установить массив m_TagData
    // BlCount определяет количество буферов m_TagData которое может вместить m_ReadData
    procedure initTagData(blCount: integer);
    // вызывается в событии doGetData для вычитки данных из тега в m_TagData
    // возвращает true если пришли новые данные
    // сбрасывается в 0 если сброс данных не произошел
    // AutoResetData количество элементов которое пришлось дропнуть
    function UpdateTagData(tare: boolean; var AutoResetData: integer): boolean; overload;
    function UpdateTagData(tare: boolean): boolean; overload;
    // дособрать буфер на основании информации о новых блоках
    procedure BuildReadBuff(tare: boolean; var AutoResetData: integer);
    procedure RebuildReadBuff(tare: boolean); overload;
    procedure RebuildReadBuff(tare: boolean; interval:point2d); overload;
    // необходимо вызывать каждый раз когда расчет по накопленным данным m_ReadData завершен
    // в результате копируются неиспользованные данные в начало буфера и происходит перевод
    // m_lastindex в начало буфера
    // portionSize - период расчета алгоритма использующего m_ReadData. из m_ReadData сбрасывается
    // кратное portionSize количество значений
    procedure ResetTagData(portionSize: integer); overload;
    procedure ResetTagData; overload;
    // резетим буфер по индексу первого нужного элемента в m_readData (забываем все до endTimeInd)
    procedure ResetTagDataTimeInd(endTimeInd: integer);
    procedure InitWriteData(Size: integer);
    function GetValByTime(time: double; interp: boolean;
      var error: boolean): point2d;
    // получить индекс последнего элемента в массиве m_ReadData
    function getlastindex: integer;
    // начало и конец в секундах данных в m_readdata
    function getPortionTime: point2d;
    // длительность накопленных данных
    function getPortionLen: double;
    function getPortionEndTime: double;
    // индексы начала и конца интервала
    function getIntervalInd(interval: point2d): tpoint;
    // TimeInd
    function getIndex(t: double): integer;
  public
    procedure initTag;
    function GetDefaultEst: double;
    function GetMeanEst: double;
    function GetRMSEst: double;
    function GetPeakEst: double;
    function GetMaxYValue: double;
    // возвращает время i-о отсчета в m_readData/ в зависимости от типа тега по разному
    // реализует расчет времени
    function getReadTime(i: integer): double;
    // вычисляем интервал который накоплен в теге
    function EvalTimeInterval:point2d;
    // скопировать из тега накопленные данные по интервалу i
    procedure EvalDataBlock(i:point2d; var d:array of double; var count:integer);
    property tag: itag read ftag write settag;
    property block: IBlockAccess read fBlock write setBlock;
    property blockCount: integer read fBlCount write fBlCount;
    property tagname: string read Gettagname write settagname;
    property tag_id: tagid read ftagid write settagid;
    property freq: double read getfreq write setfreq;
    property readyVals: cardinal read getReadyVals write setReadyVals;
    property lastindex: integer read getlastindex write m_lastindex;
    // tagname; tagid
    Function ToStr:string;
    procedure FromStr(s:string);
    constructor create;
    destructor destroy; overload;
    // удаление в режиме конфига, чтобы не вызывать лишних событий ecm/ lcm
    destructor destroy(InCfgMode: boolean); overload;
  end;

  TMBaseNotify = record
    // идентификатор объекта которому надо добавит/ удалшить свойство
    ObjID: String;
    // тип операции 0 - добавить/изменить свойство 1 - удалить
    OperType: integer;
    // строка свойств и значение
    // Если добавляем меняем свойство через разделитель ";" идут <имя свойства>,<значение свойства>
    // Если удаляем то через разделитель ";" идут имена свойств
    Operation: string;
  end;

  // путь к текущему замеру
function GetMeraFile: string;
procedure saveTag(t: cTag; node: txmlnode);
// сама по себе функция не создает тег!
function LoadTag(node: txmlnode; p_t: cTag): cTag;
procedure saveTagToIni(ifile: tinifile; t: cTag; sect, ident: string);
function LoadTagIni(ifile: tinifile; sect, ident: string): cTag;
function LoadITagIni(ifile: tinifile; sect, ident: string): iTag;
procedure LoadExTagIni(ifile: tinifile; t: cTag; sect, ident: string);

procedure GlobDetach;
procedure GlobInit(p_plg: IRecorderPlugin; p_ir: irecorder);

procedure AddTagProp(t: itag; propname: string; propval: string);
function GetConfigName: string;
function getIR: irecorder;
// увеличивает счетчик ссылок на 1!!!
function GetTagByIndex(i: integer): itag;
function getTagByName(s: string): itag;
function getTagById(id: tagid): itag;
function Check_outputTag(t: itag): boolean;
// путь конфигурации рекордера
function getRConfig: string;
// рекордер в настройке
function RStateConfig: boolean;
function RStateStop: boolean;
// рекордер в состоянии записи
function RStateRec: boolean;
function RState: dword;
function GetTagUnits(t: itag): string;
procedure SetTagUnits(t: itag; s: string);
// старт работы рекордера
function RecorderSysTime0: double;
// системное время рекордера
function RecorderSysTime: double;
// период обновления Recorder
function GetREFRESHPERIOD: double;
// время рекордера
function GetRCTime: double;
procedure SetMeanEval(t: itag; val: boolean);
procedure SetPeakEval(t: itag; val: boolean);
// Работа с тегами
function GetMean(t: itag): double;
function GetAmp(t: itag): double;
function GetPkPk(t: itag): double;
function GetRMSD(t: itag): double;
// получить посл значение
function GetScalar(t: itag): double;
function isVector(t: itag): boolean;
function isScalar(t: itag): boolean;
function IsAlive(t: itag): boolean;
function CloseTag(t: itag): boolean;
function TagUnits(t: itag): string;
// вход рекордера в настройку
function ecm: boolean; overload;
function ecm(var changeState: boolean): boolean; overload;
// выход рекордера из настройки
function lcm: boolean;
function StrToAnsi(s: string): ansistring;
// НЕ работает с FASTMM. Из функции не удается вернуть указатель на строку, строка запарывается
function StrToPAnsi(s: string): pansichar;
function ReadBlockData(dBlock: IBlockAccess; readNextBlock: boolean;
  var data: array of double): boolean;
function createCTag(tagname: string): cTag;
// заменить тег в ct по имени нового тега (обновится tagid и имя)
// возвращает true если были изменения
function ChangeCTag(ct: cTag; tagname: string): boolean;

function CreateStateTag(tagname: string; owner: tobject): itag;

function createVectorTagR8(tagname: string; freq: double; CfgWritable: boolean;
  irregular: boolean; freqcorrection: boolean): itag;

// function createXYVectorR8(tagname: string; freq: double; CfgWritable: boolean): itag;

function createScalar(tagname: string; CfgWritable: boolean): itag;
// получить значение тега по времени t - исходный тег; time - аргумент искомого значения
// interp - если true то при неточном совпопадении времени time с временем значения тега
// значение будет проинтерполировано между двумя соседними значениями, есил false берется
// точное значение ближайшего по времени значения тега
function FuncGetValByTime(t: cTag; time: double; interp: boolean;
  var error: boolean): point2d;
// узнать число ссылок на первый тег в списке рекордера (отладочная функция для поиска места в котором меняются число ссылок по всем тегам рекордера)
function CheckRefCountT0: integer;
function TagRefCount(t: itag): integer;
procedure WriteFloatToIniMera(f: tinifile; sect, key: string; v: double);
procedure logRCInfo(fpath: string);

procedure FreeFFTPlanList;
procedure FreeInverseFFTPlanList;

function GetFFTPlan(fftCount: integer): TFFTProp;
function GetInverseFFTPlan(fftCount: integer): TFFTProp;
function TranslateNotifyToStr(n: integer): string;

var
  g_IR: irecorder = nil;
  G_Plg: IRecorderPlugin = nil;
  g_configmode: boolean;
  g_merafile: string;
  g_configCS: TRTLCriticalSection;
  // настройки FFT прямого и обратного преобразования
  g_FFTPlanList: array of TFFTProp;
  g_inverseFFTPlanList: array of TFFTProp;

const
  // количество порций которое может накопить алгоритм между двумя периодами расчета выходного значения
  c_blockCount = 10;
  c_fftPlan_blockLength = 10;
  c_MBaseName = 'Plugin Циклограмма';

implementation
//uses
//  pluginclass;

// uMBaseControl;

procedure GlobDetach;
begin
  G_Plg := nil;
  g_IR := nil;
  DeleteCriticalSection(g_configCS);
end;

procedure GlobInit(p_plg: IRecorderPlugin; p_ir: irecorder);
begin
  G_Plg := p_plg;
  g_IR := p_ir;
  InitializeCriticalSection(g_configCS);
end;

function FuncGetValByTime(t: cTag; time: double; interp: boolean;
  var error: boolean): point2d;
var
  t1, t2, dt, d1, d2: double;
  i: integer;
begin
  result.x := -1;
  result.y := -1;
  dt := 1 / t.getfreq;
  error := false;
  if time < t.m_ReadDataTime then
  begin
    if time < t.m_ReadDataTime - dt then
    begin
      error := true;
    end
    else
    begin
      result.x := t.m_ReadDataTime;
      result.y := t.m_ReadData[0];
    end;
    exit;
  end;

  if time > t.getReadTime(t.m_lastindex - 1) then
  begin
    if time > t.getReadTime(t.m_lastindex - 1) + dt then
    begin
      error := true;
    end
    else
    begin
      result.y := t.m_ReadData[t.m_lastindex - 1];
      result.x := t.getReadTime(t.m_lastindex - 1);
    end;
    exit;
  end;
  t2 := 0;
  if t.m_lastindex - 2 < 0 then
  begin
    result.x := t.getReadTime(0);
    result.y := t.m_ReadData[0];
    exit;
  end;
  for i := 0 to t.m_lastindex - 2 do
  begin
    t1 := t.getReadTime(i);
    if i < t.m_lastindex - 1 then
      t2 := t.getReadTime(i + 1);
    if (time >= t1) and (time <= t2) then
    begin
      if interp then
      begin
        result.y := EvalLineYd(time, t1, t.m_ReadData[i], t2,
          t.m_ReadData[i + 1]);
        result.x := time;
      end
      else
      begin
        d1 := time - t1;
        d2 := t2 - time;
        if d1 < d2 then
        begin
          result.x := t1;
          result.y := t.m_ReadData[i];
        end
        else
        begin
          result.x := t2;
          result.y := t.m_ReadData[i + 1];
        end;
      end;
      exit;
    end;
  end;
end;

function createVectorTagR8(tagname: string; freq: double; CfgWritable: boolean;
  irregular: boolean; freqcorrection: boolean): itag;
var
  ir: irecorder;
  Name, errMes: string;
  err: cardinal;
  v: OleVariant;
begin
  ir := getIR;
  result := itag(ir.CreateTag(lpcstr(StrToAnsi(tagname)), LS_VIRTUAL, nil));
  if result = nil then // ошибка создания виртуального тега
  begin
    err := ir.GetLastError;
    errMes := ir.ConvertErrorCodeToString(err);
    exit;
    // showmessage(errMes);
  end;
  // установка типа тега : вектор, прием и передача
  VariantInit(v);
  VariantClear(v);
  TPropVariant(v).vt := VT_UI4;

  if irregular then
    v := TTAG_VECTOR or TTAG_INPUT or TTAG_IRREGULAR
  else
    v := TTAG_VECTOR or TTAG_INPUT;

  result.SetProperty(TAGPROP_TYPE, v);
  // частота опроса
  result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, freqcorrection);
  VariantClear(v);
  // v := fintag.tag.GetFreq; // частота опроса датчика
  result.setfreq(freq);
  // тип передаваемых данных
  VariantClear(v);
  TPropVariant(v).vt := VT_R8;
  // v := VarAsType(v, varDouble);
  result.SetProperty(TAGPROP_DATATYPE, v);
  result.CfgWritable(CfgWritable);

  // минимальное и максимальное значение диапазона
  // VariantClear(v);
  // m_TestWriteVTag.getProperty(TAGPROP_MINVALUE, v);
  // m_TestVTag.SetProperty(TAGPROP_MINVALUE, v);
  // VariantClear(v);
  // m_TestWriteVTag.getProperty(TAGPROP_MAXVALUE, v);
  // m_TestWriteVTag.SetProperty(TAGPROP_MAXVALUE, v);
end;

procedure saveTag(t: cTag; node: txmlnode);
begin
  node.WriteAttributeString('TagName', t.tagname);
  node.WriteAttributeInt64('TagID', t.tag_id);
end;

function LoadTag(node: txmlnode; p_t: cTag): cTag;
var
  t: itag;
  ir: irecorder;
  id: tagid;
  refcount: integer;
begin
  if p_t = nil then
  begin
    result := cTag.create;
  end
  else
  begin
    result := p_t;
  end;
  result.tagname := node.ReadAttributeString('TagName', '');
  result.ftagid := node.ReadAttributeInt64('TagID', -1);
  if result.tagname <> '' then
  begin
    t := getTagByName(result.tagname);
    if t <> nil then
    begin
      // t.GetTagId(result.tagid)
      result.tag := t;
    end
    else
    begin
      ir := getIR;
      t := getTagById(result.ftagid);
      if t <> nil then
      begin
        result.tag := t;
      end;
    end;
  end;
end;

procedure saveTagToIni(ifile: tinifile; t: cTag; sect, ident: string);
var
  str: string;
begin
  str := t.tagname + ';' + inttostr(t.tag_id);
  ifile.WriteString(sect, ident, str);
end;

procedure LoadExTagIni(ifile: tinifile; t: cTag; sect, ident: string);
var
  val, str: string;
  index: integer;
begin
  str := ifile.ReadString(sect, ident, '');
  if str <> '' then
  begin
    val := GetSubString(str, ';', 0, index);
    t.tagname := val;
    if t.tag = nil then
    begin
      val := GetSubString(str, ';', index + 1, index);
      t.ftagid := StrToInt64(val);
    end;
  end;
end;

function LoadITagIni(ifile: tinifile; sect, ident: string): iTag;
var
  val, str: string;
  index: integer;
begin
  result := nil;
  str := ifile.ReadString(sect, ident, '');
  if str <> '' then
  begin
    val := GetSubString(str, ';', 0, index);
    result:=getTagByName(val);
    if result = nil then
    begin
      val := GetSubString(str, ';', index + 1, index);
      result:=getTagById(StrToInt64(val));
    end;
  end;
end;

function LoadTagIni(ifile: tinifile; sect, ident: string): cTag;
var
  val, str: string;
  index: integer;
begin
  result := nil;
  str := ifile.ReadString(sect, ident, '');
  if str <> '' then
  begin
    result := cTag.create;
    val := GetSubString(str, ';', 0, index);
    result.tagname := val;
    if result.tag = nil then
    begin
      val := GetSubString(str, ';', index + 1, index);
      result.tag_id := StrToInt64(val);
    end;
  end;
end;

function ReadBlockData(dBlock: IBlockAccess; readNextBlock: boolean;
  var data: array of double): boolean;
begin

end;

function getIR: irecorder;
begin
  result := g_IR;
end;

procedure AddTagProp(t: itag; propname: string; propval: string);
var
  PropI: IUserProperties;
  i, ind: integer;
  a_varValue: OleVariant;
  a_pPropId: TBStr;
begin
  t.QueryInterface(IID_IUserProperties, PropI);
  a_pPropId := TBStr(propname);
  a_varValue := propval;
  PropI.SetUserProperty(a_pPropId, a_varValue, UPROPFLAG_MERA_FILE);
end;

function GetConfigName: string;
var
  val: OleVariant;
begin
  g_IR.GetProperty(RCPROP_CONFIGNAME, val);
  result := val;
end;

function GetTagByIndex(i: integer): itag;
var
  ansi: ansistring;
begin
  result := itag(g_IR.GetTagByIndex(i));
  if result <> nil then
  begin
    result._Release;
  end;
end;

function getTagByName(s: string): itag;
var
  ansi: ansistring;
begin
  ansi := s;
  result := itag(g_IR.getTagByName(pansichar(ansi)));
  if result <> nil then
  begin
    result._Release;
  end;
end;

function getTagById(id: tagid): itag;
var
  t: itag;
begin
  result := nil;
  g_IR.GetTagByTagId(id, t);
  if t <> nil then
  begin
    t._Release;
    result := t;
  end;
end;

function createCTag(tagname: string): cTag;
var
  it: itag;
begin
  it := getTagByName(tagname);
  result := nil;
  if it <> nil then
  begin
    result := cTag.create;
    result.tag := it;
  end;
end;

function ChangeCTag(ct: cTag; tagname: string): boolean;
var
  it: itag;
begin
  result := false;
  it := getTagByName(tagname);
  if it <> nil then
  begin
    if it <> ct.tag then
    begin
      ct.tag := it;
      result := true;
    end;
  end
  else
  begin
    ct.tagname := tagname;
  end;
end;

function CreateStateTag(tagname: string; owner: tobject): itag;
var
  ir: irecorder;
  astr: ansistring;
  var_type: Variant;
  v: OleVariant;
begin
  ir := getIR;
  result := getTagByName(tagname);
  if result = nil then
    result := itag(ir.CreateTag(lpcstr(StrToAnsi(tagname)), LS_VIRTUAL, nil));
  AddTagProp(result, 'NullPoly', '1');

  // сохранять в конфиге
  // установка типа тега : вектор, прием и передача
  VariantInit(v);
  VariantClear(v);
  TPropVariant(v).vt := VT_UI4;
  v := TTAG_SCALAR or TTAG_INPUT;
  result.SetProperty(TAGPROP_TYPE, v);
  // частота опроса
  result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, false);
  VariantClear(v);
  result.setfreq(0);
  // тип передаваемых данных
  VariantClear(v);
  TPropVariant(v).vt := VT_R8;
  result.SetProperty(TAGPROP_DATATYPE, v);
  result.CfgWritable(false);
  // result.SetProperty(TAGPROP_OWNER, G_Plg);

  // сохранять в конфиге
  { result.CfgWritable(false);
    result.SetProperty(TAGPROP_TYPE, TTAG_SCALAR or TTAG_INPUT or TTAG_OUTPUT);
    result.SetProperty(TAGPROP_OWNER, g_IR);
    result.SetProperty(TAGPROP_ATTRIB_HIDEN, false);
    result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, false);
    TVarData(var_type).VType := varDouble;
    // TVarData(var_type).VLongWord := varDouble;
    result.SetProperty(TAGPROP_DATATYPE, var_type); }
end;

function isVector(t: itag): boolean;
var
  var_type: Variant;
  v: OleVariant;
begin
  t.GetProperty(TAGPROP_TYPE, v);
  result := TTAG_SCALAR and v;
end;

function isScalar(t: itag): boolean;
var
  var_type: Variant;
  v: OleVariant;
begin
  t.GetProperty(TAGPROP_TYPE, v);
  result := TTAG_SCALAR and v;
end;

function IsAlive(t: itag): boolean;
var
  var_type: Variant;
  v: OleVariant;
begin
  result := false;
  if t <> nil then
  begin
    t.GetProperty(TAGPROP_DESTROYED_FLAG, v);
    result := not v;
  end;
end;

function CloseTag(t: itag): boolean;
begin
  if IsAlive(t) then
  begin
    result := true;
    getIR.CloseTag(t);
  end
  else
  begin
    result := false;
  end;
end;

function TagUnits(t: itag): string;
var
  v: OleVariant;
begin
  t.GetProperty(TAGPROP_UNITS, v);
  result := v;
end;

function createScalar(tagname: string; CfgWritable: boolean): itag;
var
  ir: irecorder;
  astr: ansistring;
  var_type: Variant;
  v: OleVariant;
begin
  ir := getIR;
  result :=getTagByName(tagname);
  // если тег существует выходим
  if result<>nil then
    exit;
  result := itag(ir.CreateTag(lpcstr(StrToAnsi(tagname)), LS_VIRTUAL, nil));

  // сохранять в конфиге
  // установка типа тега : вектор, прием и передача
  VariantInit(v);
  VariantClear(v);
  TPropVariant(v).vt := VT_UI4;
  v := TTAG_SCALAR or TTAG_INPUT;
  result.SetProperty(TAGPROP_TYPE, v);
  // частота опроса
  result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, false);
  VariantClear(v);
  result.setfreq(0);
  // тип передаваемых данных
  VariantClear(v);
  TPropVariant(v).vt := VT_R8;
  result.SetProperty(TAGPROP_DATATYPE, v);
  result.CfgWritable(CfgWritable);
  // result.SetProperty(TAGPROP_OWNER, G_Plg);

  { result.CfgWritable(CfgWritable);
    result.SetProperty(TAGPROP_TYPE, TTAG_SCALAR or TTAG_INPUT or TTAG_OUTPUT);
    // если раскоментить падает
    //  result.SetProperty(TAGPROP_OWNER, g_IR);
    result.SetProperty(TAGPROP_ATTRIB_HIDEN, false);
    result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, false);
    TVarData(var_type).VType := varDouble;
    result.SetProperty(TAGPROP_DATATYPE, var_type); }
end;

function Check_outputTag(t: itag): boolean;
var
  res: OleVariant;
begin
  t.GetProperty(TTAG_OUTPUT, res);
  if not VarIsNull(res) then
    result := res
  else
    result := false;
end;

function getRConfig: string;
var
  res: OleVariant;
begin
  g_IR.GetProperty(RCPROP_CONFIGNAME, res);
  if not VarIsNull(res) then
    result := res
  else
    result := '';
end;

function RStateStop: boolean;
begin
  result := g_IR.CheckState(RS_stop);
end;

function RStateRec: boolean;
begin
  // RS_STOP  //RS_VIEW  //RS_REC
  result := g_IR.CheckState(RS_REC);
end;

function RState: dword;
begin
  // RS_STOP  //RS_VIEW  //RS_REC
  result := g_IR.getState(RS_BASESTATE);
end;

function GetTagUnits(t: itag): string;
var
  res: OleVariant;
begin
  t.GetProperty(TAGPROP_UNITS, res);
  if not VarIsNull(res) then
    result := res
  else
    result := '';
end;

procedure SetTagUnits(t: itag; s: string);
var
  res: OleVariant;
begin
  res := s;
  t.SetProperty(TAGPROP_UNITS, res);
end;

function RecorderSysTime0: double;
var
  res: OleVariant;
begin
  g_IR.GetProperty(RCPROP_STARTTIME, res);
  if not VarIsNull(res) then
    result := res
  else
    result := 0;
end;

// системное время рекордера
function RecorderSysTime: double;
var
  res: OleVariant;
begin
  g_IR.GetProperty(RCPROP_TIME, res);
  if not VarIsNull(res) then
    result := res
  else
    result := 0;
end;

function GetREFRESHPERIOD: double;
var
  res: OleVariant;
begin
  g_IR.GetProperty(RCPROP_REFRESHPERIOD, res);
  if not VarIsNull(res) then
    result := res
  else
    result := 0;
end;

function GetRCTime: double;
var
  res: OleVariant;
begin
  g_IR.GetProperty(RCPROP_TIME, res);
  if not VarIsNull(res) then
    result := res
  else
    result := 0;
end;



function GetScalar(t: itag): double;
var
  d: double;
begin
  // result:=t.GetEstimate(ESTIMATOR_LAST);
  result := t.GetEstimate(ESTIMATOR_MEAN);
end;

procedure SetMeanEval(t: itag; val: boolean);
var
  v: OleVariant;
begin
  // VariantClear(v);
  // TPropVariant(v).vt := VT_UI4;
  // v := TTAG_VECTOR or TTAG_INPUT;
  // result.SetProperty(TAGPROP_TYPE, v);
  // result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, true);

  VariantInit(v);
  TPropVariant(v).vt := VT_UI4;
  VariantClear(v);
  t.GetProperty(ESTIMATOR_MEAN, v);
  if val then
  begin
    v := v or ESTIMATOR_MEAN;
  end
  else
  begin
    v := v - ESTIMATOR_MEAN;
  end;
  t.SetProperty(ESTIMATOR_MEAN, v);
end;

procedure SetPeakEval(t: itag; val: boolean);
var
  v: OleVariant;
begin
  // VariantClear(v);
  // TPropVariant(v).vt := VT_UI4;
  // v := TTAG_VECTOR or TTAG_INPUT;
  // result.SetProperty(TAGPROP_TYPE, v);
  // result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, true);

  VariantInit(v);
  TPropVariant(v).vt := VT_UI4;
  VariantClear(v);
  t.GetProperty(ESTIMATOR_MEAN, v);
  if val then
  begin
    v := v or ESTIMATOR_PEAK;
  end
  else
  begin
    v := v - ESTIMATOR_PEAK;
  end;
  t.SetProperty(ESTIMATOR_MEAN, v);
end;

function GetMean(t: itag): double;
var
  d: double;
begin
  result := t.GetEstimate(ESTIMATOR_MEAN);
end;

function GetAmp(t: itag): double;
var
  d: double;
begin
  result := t.GetEstimate(ESTIMATOR_PEAK);
end;

function GetPkPk(t: itag): double;
var
  d: double;
begin
  result := t.GetEstimate(ESTIMATOR_P2P);
end;

function GetRMSD(t: itag): double;
var
  d: double;
begin
  result := t.GetEstimate(ESTIMATOR_RMSD);
end;

function RStateConfig: boolean;
begin
  result := g_IR.CheckState(RS_CONFIGMODE);
end;

function ecm(var changeState: boolean): boolean;
begin
  //if TExtRecorderPack(G_Plg).m_leavecfgNotify then
  //begin
  //  showmessage('Повторный вход в конфигурацию! при выходе из конфигурирования (function ecm(var)...)');
  //end;
  //if RStateConfig or TExtRecorderPack(G_Plg).m_leavecfgNotify then
  if RStateConfig then
  begin
    result := false;
    changeState := false;
    exit;
  end
  else
  begin
    result := ecm;
    if result then
    begin
      changeState := true;
    end;
  end;
end;

function ecm: boolean;
var
  ir: irecorder;
begin
  ir := getIR;
  result := false;
  EnterCriticalSection(g_configCS);
  if not g_configmode then
  begin
    result := true;
    ir.EnterConfigMode(G_Plg, 0);
  end;
  g_configmode := true;
  LeaveCriticalSection(g_configCS);
end;

function lcm: boolean;
var
  param: integer;
  ir: irecorder;
begin
  result := false;
  EnterCriticalSection(g_configCS);
  if g_configmode then
  begin
    result := true;
    ir := getIR;
    // говорим рекордеру, чтобы обновил все списки тегов
    param := SCF_TAGSLIST or SCF_TAGSCONTENT;

    ir.SetProperty(RCPROP_CHANGEDSETTINGS, param);
    ir.LeaveConfigMode(G_Plg, 0);
    g_configmode := false;
  end;
  LeaveCriticalSection(g_configCS);
end;

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

function StrToPAnsi(s: string): pansichar;
begin
  result := lpcstr(StrToAnsi(s));
end;

{ cTag }

function cTag.BlockSize: integer;
begin
  result := block.GetBlocksSize;
end;

function cTag.ConvertIndInLoopBuff(i: integer): integer;
begin
  if m_ReadyVals < m_WriteDataSize then
    result := i
  else
  begin
    if true then

    end;
  end;

constructor cTag.create;
begin
  m_useReadBuffer:=true;
  useEcm:=true;
  owner:=nil;
  m_createOutTag := true;
  ftag := nil;
  ftagid := -1;
  ftagname := '';
  fBlCount := c_blockCount;
end;

destructor cTag.destroy;
var
  changeState: boolean;
  i:integer;
begin
  if owner<>nil then
  begin
    if owner.find(tagname, i) then
    begin
      owner.Delete(i);
    end;
  end;
  ftagname := 'freedTag';
  // ecm(changeState);
  ftag := nil;
  // if changeState then
  // lcm;
  inherited;
end;

destructor cTag.destroy(InCfgMode: boolean);
var
  changeState: boolean;
begin
  if InCfgMode then
  begin
    ftagname := 'freedTag';
    ftag := nil;
  end
  else
  begin
    ftagname := 'freedTag';
    // ecm(changeState);
    ftag := nil;
    // if changeState then
    // lcm;
  end;
end;

procedure cTag.doOnStart;
var
  l: integer;
begin
  m_firstBlock:=true;
  m_ReadDataTime := 0;
  m_readyBlock := 0;
  m_lastindex := 0;
  m_lastIndWriteData := 0;
  m_ReadyVals := 0;

  m_timeShtamp := 0;
  m_timeShtamp_i := 0;

  if tag<>nil then
  begin
    fdT:=1/freq;

    m_blLen:=block.GetBlocksSize*fdT;
    m_TagLen:=m_blLen*block.GetBlocksCount;

    // добавлено 07.02.2020
    l := length(m_ReadData);
    if l > 0 then
      ZeroMemory(@m_ReadData[0], l * sizeof(double));
  end;
end;


function cTag.GetDefaultEst: double;
begin
  result := tag.GetEstimate(ESTIMATOR_DEFAULT);
end;

function cTag.GetMaxYValue: double;
var
  v: OleVariant;
begin
  if tag<>nil then
  begin
    tag.GetProperty(TAGPROP_MAXVALUE,   v);
    result := v;
  end
  else
    result:=0;
end;

function cTag.GetMeanEst: double;
begin
  result := tag.GetEstimate(ESTIMATOR_MEAN);
end;

function cTag.GetOutValue(i: integer): double;
begin

end;

function cTag.GetRMSEst: double;
begin
  result := tag.GetEstimate(ESTIMATOR_RMSD);
end;

function cTag.GetPeakEst: double;
begin
  result := tag.GetEstimate(ESTIMATOR_PEAK);
end;

function cTag.GetValByTime(time: double; interp: boolean;
  var error: boolean): point2d;
begin
  result := FuncGetValByTime(self, time, interp, error);
end;

procedure cTag.initTag;
var
  bl:IBlockAccess;
begin
  if ftag=nil then
  begin
    ftag:=getTagByName(ftagname);
    if ftag=nil then
    begin
      ftag:=getTagById(ftagid);
    end;
  end;
  if ftag<>nil then
  begin
    if not FAILED(ftag.QueryInterface(IBlockAccess, bl)) then
    begin
      block := bl;
      bl := nil;
    end;
  end;
end;

procedure cTag.initTagData(blCount: integer);
var
  v: OleVariant;
  Size: integer;
begin
  ftag.GetProperty(TAGPROP_BUFFSIZE, v);
  Size := round(GetREFRESHPERIOD * ftag.getfreq);
  if (v = 1) and (Size > 1) then
  begin
    v := Size shl 2;
  end;
  SetLength(m_TagData, integer(v));
  SetLength(m_TagData2d, integer(v));
  m_ReadSize := integer(v) * blCount;
  SetLength(m_ReadData, m_ReadSize);
end;

procedure cTag.InitWriteData(Size: integer);
begin
  m_WriteDataSize := Size;
  SetLength(m_WriteData, Size);
  SetLength(m_WriteDataX, Size);
end;

function cTag.GetIsScalar: boolean;
begin
  if ftag <> nil then
    result := not isVector(ftag)
  else
    result := false;
end;

procedure cTag.PutOutValue(v, t: double);
begin
  m_WriteData[m_lastIndWriteData] := v;
  m_WriteDataX[m_lastIndWriteData] := t;
  inc(m_lastIndWriteData);
  if m_lastIndWriteData >= m_WriteDataSize then
    m_lastIndWriteData := 0;
end;

function cTag.readyBlockCount: cardinal;
begin
  result := 0;
  if block <> nil then
    result := block.GetReadyBlocksCount;
end;



procedure cTag.ResetTagData;
var
  datacount, blCount, portionSize: integer;
begin
  if m_lastindex <> 0 then
  begin
    portionSize := block.GetBlocksSize;
    blCount := trunc(m_lastindex / portionSize);
    datacount := blCount * portionSize;
    if m_ReadSize - datacount <> 0 then
    begin
      move(m_ReadData[datacount], m_ReadData[0], m_lastindex - datacount);
    end;
    m_lastindex := m_lastindex - datacount;
    m_ReadDataTime := m_ReadDataTime + (1 / getfreq) * datacount;
  end;
end;

procedure cTag.ResetTagData(portionSize: integer);
var
  datacount, blCount: integer;
  dt: double;
begin
  if portionSize = 0 then
    exit;
  if m_lastindex <> 0 then
  begin
    blCount := trunc(m_lastindex / portionSize);
    datacount := blCount * portionSize;
    if m_ReadSize - datacount <> 0 then
      move(m_ReadData[datacount], m_ReadData[0],
        (m_lastindex - datacount) * sizeof(double));
    m_lastindex := m_lastindex - datacount;
    m_ReadDataTime := m_ReadDataTime + (1 / getfreq) * datacount;
    // ZeroMemory(@m_ReadData[lastindex], (m_ReadSize-m_lastindex)*sizeof(double));
  end;
end;

procedure cTag.ResetTagDataTimeInd(endTimeInd: integer);
var
  //ihist,
  datacount: integer; // количество сдвигаемых данных
  dt: double;
begin
  if m_lastindex <> 0 then
  begin
    datacount := m_lastindex - endTimeInd;
    if datacount > 0 then
    begin
      if m_ReadSize - datacount <> 0 then
      begin
        move(m_ReadData[endTimeInd], m_ReadData[0], datacount * sizeof(double));
      end;
    end;
    m_lastindex := datacount;
    m_ReadDataTime := m_ReadDataTime + fdt*endTimeInd;
    if lastindex >= 0 then
    begin
      if lastindex<m_ReadSize-1 then
        ZeroMemory(@m_ReadData[lastindex],(m_ReadSize - m_lastindex) * sizeof(double))
    end
    else
    begin
      m_lastindex:=0;
      // showmessage('lastindex<0: cTag.ResetTagDataTimeInd(endTimeInd:integer) - ZeroMemory(@m_ReadData[lastindex], (m_ReadSize-m_lastindex)*sizeof(double))')
    end;
  end;
end;

procedure cTag.setBlock(b: IBlockAccess);
begin
  fBlock := b;
  initTagData(fBlCount);
end;

procedure cTag.setfreq(f: double);
begin
  ftag.setfreq(f);
end;

procedure cTag.setReadyVals(f: cardinal);
begin
  m_ReadyVals := f;
end;

function cTag.getPortionTime: point2d;
begin
  result.x := m_ReadDataTime;
  result.y := m_ReadDataTime + m_lastindex*fdt;
end;

function cTag.getPortionLen: double;
var
  p2:point2d;
begin
  p2:=getPortionTime;
  result:=p2.y-p2.x;
end;

function cTag.getPortionEndTime: double;
begin
  result := m_ReadDataTime + m_lastindex * fdT;
end;

function cTag.getIntervalInd(interval: point2d): tpoint;
begin
  result.x := round((interval.x - m_ReadDataTime) * freq);
  result.y := round((interval.y - m_ReadDataTime) * freq) - 1;
  if result.y>=m_ReadSize then
  begin
    result.y:=m_ReadSize-1;
  end;
  if result.x<0 then
  begin
    result.x:=0;
  end;
end;

function cTag.getIndex(t: double): integer;
begin
  result := round((t - m_ReadDataTime) * freq);
end;

function cTag.getReadTime(i: integer): double;
begin
  if not isScalar(tag) then
  begin
    result := m_ReadDataTime + i * fdt;
  end;
end;

function cTag.getReadyVals: cardinal;
begin
  result := m_ReadyVals;
end;

function cTag.getfreq: double;
begin
  if ftag <> nil then
    result := ftag.getfreq
  else
  begin
    result := 0;
  end;
end;

function cTag.getlastindex: integer;
begin
  result := m_lastindex;
end;

procedure cTag.settag(t: itag);
var
  bl: IBlockAccess;
begin
  ftag := t;
  if (t <> nil) then
  begin
    t.GetTagId(ftagid);
    ftagname := t.GetName;
    if not isScalar(t) then
    begin
      if not FAILED(t.QueryInterface(IBlockAccess, bl)) then
      begin
        block := bl;
        bl := nil;
      end;
    end;
  end
  else
  begin
    if ftag <> nil then
      ftagname := '';
  end;
end;

procedure cTag.settagid(t: tagid);
var
  it: itag;
begin
  it := getTagById(t);
  if it <> nil then
  begin
    tag := it;
  end;
end;

function cTag.Gettagname: string;
begin
  if ftag <> nil then
    result := ftag.GetName
  else
    result := ftagname;
end;


procedure cTag.settagname(s: string);
var
  b: boolean;
  astr: ansistring;
  i:integer;
begin
  b := false;
  if (Gettagname <> s) or (tag=nil) then
  begin
    if useecm then
    begin
      if tag<>nil then // вход в конфиг нужен только для переименования тега
      begin
        if not RStateConfig then
        begin
          b := true;
          ecm;
        end;
      end;
    end;
    astr := s;
    if tag <> nil then
    begin
      tag.SetName(pansichar(lpcstr(StrToAnsi(s))));
      // tag.SetName(pansichar(astr));
    end
    else
    begin
      tag := getTagByName(s);
    end;
    if owner<>nil then
    begin
      if owner.Find(s,i) then
      begin
        owner.Delete(i);
        owner.AddObject(s, self);
      end;
    end;
    ftagname := s;
    if useEcm then
    begin
      if b then
        lcm;
    end;
  end;
end;
// tagname; tagid
function cTag.ToStr: string;
begin
  result:=ftagname+';'+inttostr(ftagid);
end;

procedure cTag.FromStr(s: string);
var
  s1:string;
begin
  s1:=getSubStrByIndex(s,';',1,0);
  tagname:=s1;
  s1:=getSubStrByIndex(s,';',1,1);
  if tag=nil then
  begin
    tag_id:=strtoint(s1);
  end;
end;

procedure cTag.EvalDataBlock(i: point2d; var d: array of double; var count: integer);
var
  t, offset1,offset2:double;
  // номера первого и последнего блока
  b12:tpoint;
  j: integer;
begin
  t:=block.GetBlockDeviceTime(0);
  if i.x<t then
    offset1:=t
  else
    offset1:=i.x-t;
  if i.y>(t+m_TagLen) then
    offset2:=t+m_TagLen
  else
    offset2:=i.y;

  b12.X:=trunc(offset1/m_blLen);
  b12.y:=trunc(offset2/m_blLen);
  for j:=b12.X to b12.y do
  begin
    if SUCCEEDED(block.GetVectorR8(pointer(m_TagData)^, j, block.GetBlocksSize, true)) then
    begin

    end;
  end;
end;

function cTag.EvalTimeInterval: point2d;
var
  ready, bcount:integer;
begin
  // всего блоков получено
  ready := block.GetReadyBlocksCount;
  // размер буфера
  bCount := block.GetBlocksCount;
  m_looseData:= false;
  if ready < bCount then
  begin
    bCount:=ready;
  end;
  result.x:=block.GetBlockDeviceTime(0);
  //result.y:=block.GetBlockDeviceTime(bcount-1)+bSize/getfreq;
  result.y:=block.GetBlockDeviceTime(bcount-1)+m_blLen;
end;

procedure cTag.RebuildReadBuff(tare: boolean);
var
  ready, bcount:integer;
  I: Integer;
  b:boolean;
begin
  // всего блоков получено
  ready := block.GetReadyBlocksCount;
  // размер буфера
  bCount := block.GetBlocksCount;
  m_looseData:= false;
  if ready < bCount then
  begin
    bCount:=ready;
  end;
  m_ReadDataTime:=block.GetBlockDeviceTime(0);
  m_lastindex:=0;
  for I := 0 to bCount - 1 do
  begin
    block.LockVector;
    b:=SUCCEEDED(block.GetVectorR8(pointer(m_TagData)^, i, block.GetBlocksSize, tare));
    block.unLockVector;
    move(m_TagData[0], m_ReadData[m_lastindex], block.GetBlocksSize * (sizeof(double)));
    m_lastindex:=m_lastindex+block.GetBlocksSize;
  end;
end;

procedure cTag.RebuildReadBuff(tare: boolean; interval:point2d);
var
  t:double;
  ready, bcount, b1, b2:integer;
  I: Integer;
  b:boolean;
begin
  // всего блоков получено
  ready := block.GetReadyBlocksCount;
  // размер буфера
  bCount := block.GetBlocksCount;
  m_looseData:= false;
  if ready < bCount then
  begin
    bCount:=ready;
  end;
  t:=interval.x-block.GetBlockDeviceTime(0);
  b1:=trunc(t/m_blLen);
  t:=interval.y-block.GetBlockDeviceTime(0);
  b2:=trunc(t/m_blLen);
  m_ReadDataTime:=block.GetBlockDeviceTime(b1);
  m_lastindex:=0;
  for I := b1 to b2 do
  begin
    block.LockVector;
    b:=SUCCEEDED(block.GetVectorR8(pointer(m_TagData)^, i, block.GetBlocksSize, tare));
    block.unLockVector;
    move(m_TagData[0], m_ReadData[m_lastindex], block.GetBlocksSize * (sizeof(double)));
    m_lastindex:=m_lastindex+block.GetBlocksSize;
  end;
end;

function cTag.UpdateTagData(tare: boolean): boolean;
var
  i: integer;
begin
  result:=UpdateTagData(tare, i);
end;

function cTag.UpdateTagData(tare: boolean; var AutoResetData: integer)
  : boolean;
var
  // но из за лагов может превысить размер буфера и тогда равно кол-ву блоков выходного буфера
  i,blCount, // кол-о блоков в кольцевом буфере
  readyBlockCount, // кол-о готовых к считыванию блоков
  blInd, writeBlockSize: integer;
  b: boolean;
  endTime:double; // время lastindex
  str:string;
begin
  result := false;
  blCount := block.GetBlocksCount;
  m_looseData:= false;
  if blCount > 0 then
  begin
    // сколько всего
    readyBlockCount := block.GetReadyBlocksCount;
    // если количество блоков больше чем кол-во обработанных блоков (т.е. есть новые данные)
    if readyBlockCount > m_readyBlock then
    begin
      m_newBlockCount := readyBlockCount - m_readyBlock;
      // если готовых блоков больше чем размер буфера (blCount), = потери,
      // но с этим уже ничего не поделать
      if m_newBlockCount > blCount then
      begin
        m_newBlockCount := blCount;
        m_looseData := true;
      end;
      m_readyBlock := readyBlockCount;
      result := true;
      if m_useReadBuffer then
      begin

        //str:='Btime='; // блок отладки
        // кол-о блоков которое кладется в m_ReadData
        // брать надо не все блоки в буфере, а только новые!!!
        //for i := 0 to m_newBlockCount - 1 do
        //begin
        //  blInd:= i + blCount - m_newBlockCount;
        //  endTime:=block.GetBlockDeviceTime(i);
        //  str:=str+floattostr(endTime)+'; ';
        //end;
        //if tagname='молоток' then
        //  logmessage(str);

        BuildReadBuff(tare, AutoResetData);
      end;
    end;
  end;
end;

procedure cTag.BuildReadBuff(tare: boolean; var AutoResetData:integer);
var
  i, blInd:integer;
  b:boolean;
begin
  // кол-о блоков которое кладется в m_ReadData
  for i := 0 to m_newBlockCount - 1 do
  begin
    tare := true;
    // например новых блоков 2. Последний блок в буфере всегда имеет последний тайм штамп.
    // Тогда, в цикле получаем блоки с последнего необработанного
    blInd := i + block.GetBlocksCount - m_newBlockCount;
    block.LockVector;
    b:=SUCCEEDED(block.GetVectorR8(pointer(m_TagData)^, blInd, block.GetBlocksSize,tare));
    block.unLockVector;
    if b then
    begin
      // block.GetVectorPairR8(pointer(m_TagData2d)^, blInd, blSize, tare);
      if m_looseData then
      begin
        fdevicetime := block.GetBlockDeviceTime(blInd);
        // Были потери данных!!!
        if fdevicetime-getPortionEndTime>fdT then
        begin
          m_ReadDataTime := fdevicetime;
          m_lastindex:=0; // сбрасываем все что накопили непосильным трудом
        end;
      end
      else
      begin
        // первый полученный блок
        if m_firstBlock  then
        begin
          fdevicetime := block.GetBlockDeviceTime(blInd);
          m_ReadDataTime := fdevicetime;
          m_firstBlock:=false;
        end;
      end;
    end;
    if m_ReadSize >= m_lastindex + block.GetBlocksSize then
    begin
      if m_lastindex < 0 then
      begin
        // showmessage('uRCFunc cTag.UpdateTagData 1297:m_lastindex<0');
      end
      else
      begin
        // ERROR
        move(m_TagData[0], m_ReadData[m_lastindex], block.GetBlocksSize * (sizeof(double)));
        m_lastindex := m_lastindex + block.GetBlocksSize;
      end;
      AutoResetData := 0;
    end
    else
    begin
      // m_ReadSize не вмещает новые данные!!!
      // break;
      AutoResetData := m_lastindex;
      ResetTagDataTimeInd(m_lastindex);
      //move(m_TagData[0], m_ReadData[m_lastindex], block.GetBlocksSize * (sizeof(double)));
      //fdevicetime := block.GetBlockDeviceTime(blInd);
      //m_ReadDataTime := fdevicetime;
      //m_lastindex := m_lastindex + block.GetBlocksSize;
    end
  end;
end;

function GetMeraFile: string;
var
  fname, folder: string;
begin
  // folder:=g_ir.GetSignalFolderName;
  folder := g_IR.GetSignalFrameName;
  fname := FindFile('*.mera', folder, 1);
  // result:=folder+fname;
  result := fname;
  g_merafile := fname;
end;

procedure WriteFloatToIniMera(f: tinifile; sect, key: string; v: double);
var
  str: string;
begin
  str := floattostr(v);
  str := ReplaseChars(str, ',', '.');
  f.WriteString(sect, key, str);
end;

procedure logRCInfo(fpath: string);
var
  t: itag;
  i, refcount: integer;
  f: tstringlist;
  str: string;
begin
  f := tstringlist.create;
  // проверка тегов
  for i := 0 to g_IR.GetTagsCount - 1 do
  begin
    t := GetTagByIndex(i);
    str := t.GetName;
    refcount := t._AddRef;
    refcount := t._Release;
    // t:=nil; // не влияет на refcount
    f.Add(str + ' isAlive: ' + booltostr(IsAlive(t))
        + ' RefCount: ' + inttostr(refcount));
  end;
  // проверка фабрик
  // проверка компонент
  // проверка плагинов
  f.SaveToFile(fpath);
  f.destroy;
end;

function CheckRefCountT0: integer;
var
  t: itag;
begin
  t := GetTagByIndex(0);
  result := t._AddRef;
  result := t._Release;
end;

function TagRefCount(t: itag): integer;
begin
  result := t._AddRef;
  result := t._Release;
end;

procedure FreeFFTPlanList;
var
  i: integer;
begin
  for i := 0 to length(g_FFTPlanList) - 1 do
  begin
    if g_FFTPlanList[i].PCount <> 0 then
    begin
      FreeMemAligned(g_FFTPlanList[i].TableExp);
      g_FFTPlanList[i].TableExp.p := nil;
      SetLength(g_FFTPlanList[i].TableInd, 0);
      g_FFTPlanList[i].TableInd := nil;
    end;
  end;
  SetLength(g_FFTPlanList, 0);
end;

procedure FreeInverseFFTPlanList;
var
  i: integer;
begin
  for i := 0 to length(g_inverseFFTPlanList) - 1 do
  begin
    if g_inverseFFTPlanList[i].PCount <> 0 then
    begin
      FreeMemAligned(g_inverseFFTPlanList[i].TableExp);
      g_inverseFFTPlanList[i].TableExp.p := nil;
      SetLength(g_inverseFFTPlanList[i].TableInd, 0);
      g_inverseFFTPlanList[i].TableInd := nil;
    end;
  end;
  SetLength(g_inverseFFTPlanList, 0);
end;

function GetFFTPlan(fftCount: integer): TFFTProp;
var
  i, j, l: integer;
  r: TFFTProp;
begin
  j := -1;
  r.PCount := 0;
  for i := 0 to length(g_FFTPlanList) - 1 do
  begin
    r := g_FFTPlanList[i];
    if r.PCount = fftCount then
    begin
      result := g_FFTPlanList[i];
      exit;
    end
    else
    begin
      if j = -1 then
      begin
        if r.PCount = 0 then
        begin
          j := i;
        end;
      end;
    end;
  end;
  if (j = -1) then
  begin
    // длина массива
    j := length(g_FFTPlanList);
    SetLength(g_FFTPlanList, j + c_fftPlan_blockLength);
  end;
  r := g_FFTPlanList[j];
  r.StartInd := 0;
  r.PCount := fftCount;
  r.m_scaleCurve:=nil;
  GetMemAlignedArray_cmpx_d(fftCount, r.TableExp);
  r.TableInd := GetArrayIndex(fftCount, 2);
  GetFFTExpTable(fftCount, false, tcmxArray_d(r.TableExp.p));
  g_FFTPlanList[j] := r;
  result := g_FFTPlanList[j];
end;

function GetInverseFFTPlan(fftCount: integer): TFFTProp;
var
  i, j, l: integer;
  r: TFFTProp;
begin
  j := -1;
  r.PCount := 0;
  for i := 0 to length(g_inverseFFTPlanList) - 1 do
  begin
    r := g_inverseFFTPlanList[i];
    if r.PCount = fftCount then
    begin
      result := g_inverseFFTPlanList[i];
      exit;
    end
    else
    begin
      if j = -1 then
      begin
        if r.PCount = 0 then
        begin
          j := i;
        end;
      end;
    end;
  end;
  if (j = -1) then
  begin
    // длина массива
    j := length(g_inverseFFTPlanList);
    SetLength(g_inverseFFTPlanList, j + c_fftPlan_blockLength);
  end;
  r := g_inverseFFTPlanList[j];
  r.inverse := true;
  r.StartInd := 0;
  r.PCount := fftCount;
  GetMemAlignedArray_cmpx_d(fftCount, r.TableExp);
  r.TableInd := GetArrayIndex(fftCount, 2);
  GetFFTExpTable(fftCount, true, tcmxArray_d(r.TableExp.p));
  g_inverseFFTPlanList[j] := r;
  result := g_inverseFFTPlanList[j];
end;

function TranslateNotifyToStr(n: integer): string;
begin
  case n of
    PN_ENTERRCCONFIG:
      result := 'PN_ENTERRCCONFIG';
    PN_LEAVERCCONFIG:
      result := 'PN_LEAVERCCONFIG';
    PN_CHANGECURTAG:
      result := 'PN_CHANGECURTAG';
    PN_RCSTART:
      result := 'PN_RCSTART';
    PN_RCPLAY:
      result := 'PN_RCPLAY';
    PN_RCSTOP:
      result := 'PN_RCSTOP';
    PN_UPDATEDATA:
      result := 'PN_UPDATEDATA';
    PN_SHOWINFO:
      result := 'PN_SHOWINFO';
    PN_RCSAVECONFIG:
      result := 'PN_RCSAVECONFIG';
    PN_RCLOADCONFIG:
      result := 'PN_RCLOADCONFIG';
    PN_SYNCHRO_READ_DATA_BLOCK:
      result := 'PN_SYNCHRO_READ_DATA_BLOCK';
    PN_EDIT_VIRTUAL_TAG_PROPS:
      result := 'PN_EDIT_VIRTUAL_TAG_PROPS';
    PN_IMPORTSETTINGS:
      result := 'PN_IMPORTSETTINGS';
    PN_EXPORTSETTINGS:
      result := 'PN_EXPORTSETTINGS';
    PN_BEFORE_RCSTART:
      result := 'PN_BEFORE_RCSTART';
    PN_BEFORE_RCSTOP:
      result := 'PN_BEFORE_RCSTOP';
    PN_ABORT_RCSTART:
      result := 'PN_ABORT_RCSTART';
    PN_BROADCAST:
      result := 'PN_BROADCAST';
    PN_CUSTOM_BUTTON_CLICK:
      result := 'PN_CUSTOM_BUTTON_CLICK';
    PN_CUSTOM_BUTTON_QUERY_STATE:
      result := 'PN_CUSTOM_BUTTON_QUERY_STATE';
    PN_ENABLE_VTAG_SETUP_DLG:
      result := 'PN_ENABLE_VTAG_SETUP_DLG';
    PN_EDIT_MULTI_VTAG_PROPS:
      result := 'PN_EDIT_MULTI_VTAG_PROPS';
    PN_QUERY_VTAG_INFO:
      result := 'PN_QUERY_VTAG_INFO';
    PN_REMOVE_VTAGS:
      result := 'PN_REMOVE_VTAGS';
    PN_RCINITIALIZED:
      result := 'PN_RCINITIALIZED';
    PN_ON_CHANGE_DATAPLACEMENT:
      result := 'PN_ON_CHANGE_DATAPLACEMENT';
    PN_ON_BEFORE_FRAME_REMOVING:
      result := 'PN_ON_BEFORE_FRAME_REMOVING';
    PN_ON_AFTER_FRAME_REMOVING:
      result := 'PN_ON_AFTER_FRAME_REMOVING';
    PN_FILE_PROCESSING_COMPLETED:
      result := 'PN_FILE_PROCESSING_COMPLETED';
    PN_ON_DESTROY_UI_SRV:
      result := 'PN_ON_DESTROY_UI_SRV';
    PN_ON_SWITCH_TO_UI_THREAD:
      result := 'PN_ON_SWITCH_TO_UI_THREAD';
    PN_ON_CONFIG_MODE_COMPLETED:
      result := 'PN_ON_CONFIG_MODE_COMPLETED';
    PN_ON_SWITCH_CALIBR_MODE:
      result := 'PN_ON_SWITCH_CALIBR_MODE';
    PN_ON_RC_PROGRAMMING:
      result := 'PN_ON_RC_PROGRAMMING';
    PN_ABORT_RC_PROGRAMMING:
      result := 'PN_ABORT_RC_PROGRAMMING';
    PN_ON_UPDATE_SECURITY_STATE:
      result := 'PN_ON_UPDATE_SECURITY_STATE';
    PN_ON_UPDATE_MF_TITLE:
      result := 'PN_ON_UPDATE_MF_TITLE';
    PN_ON_REC_MODE:
      result := 'PN_ON_REC_MODE';
    PN_ON_PLAY_MODE:
      result := 'PN_ON_PLAY_MODE';
    PN_ON_POPUP_SETUP_DIALOG:
      result := 'PN_ON_POPUP_SETUP_DIALOG';
    PN_ON_POPUP_SEL_FRAME_DIALOG:
      result := 'PN_ON_POPUP_SEL_FRAME_DIALOG';
    PN_ON_ACTION_SAVE_CFG:
      result := 'PN_ON_ACTION_SAVE_CFG';
    PN_ON_ACTION_SAVE_CFG_AS:
      result := 'PN_ON_ACTION_SAVE_CFG_AS';
    PN_ON_ACTION_LOAD_CFG:
      result := 'PN_ON_ACTION_LOAD_CFG';
    PN_ON_CHANGE_FORMS:
      result := 'PN_ON_CHANGE_FORMS';
    PN_ABORT_RCSTOP:
      result := 'PN_ABORT_RCSTOP';
    PN_ON_ACTION_CLOSE_APP:
      result := 'PN_ON_ACTION_CLOSE_APP';
    PN_ON_ZBALANCE_VTAG:
      result := 'PN_ON_ZBALANCE_VTAG';
  end;
end;


end.
