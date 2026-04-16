unit uScriptFrm_;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, ToolWin, ImgList, Menus, Buttons,
  OleCtrls, MSScriptControl_TLB, ActiveX, uWPproc, uBtnListView, comobj,
  uComponentServises, math, DCL_MYOWN, uCommonMath, inifiles, nativexml;

type
  // В целях оптимизации кода и ускорения работы выполнения скрипта,
  // записывать в исходные теги (аппаратные) запрещено
  // логика выполнения - есть частота выполнения скрипта, с этой частотой выполняется скрипт
  // данными выходные теги. После завершения скрипта выходные теги усредняются таким образом чтобы частота по каждому
  // из них равнялась заданной в настройке. (т.е. параметр частота выполнения скрипта определеет максимальную частоту
  // выходных тегов и объем вычислений)

  ErrorStruct = record
    // строка с ошибкой, номер символа с ошибкой
    Row, num:integer;
    // описание ошибки
    dsc:string;
  end;

  TimeStruct = record
    // минимальный шаг по времени среди обрабатываемых тегов
    min_dT,
    // минимальное время среди обрабатываемых тегов
    minT,
    // мarcимальное время среди обрабатываемых тегов
    maxT: double;
  end;

  TScriptItem = class(TInterfacedObject, idispatch)
  public
    m_pitem: pointer; // ссылка на данные
    fname: string;
    ffreq: double;
    // переменная для прореживания записи в тег. Записано время последней записи в канал
    LastValueTime: double;
    ScriptChannel: boolean;
  public
    procedure setvalue(t: double; v: double); virtual;
    function getvalue(t: double): double; virtual;
    function GetScriptName: string;
    function GetName: string;
    procedure SetName(s: string);
  public
    procedure initSignal(p_s: cwpsignal);
    function signal: cwpsignal;
    function GetTypeInfoCount(out Count: Integer): Integer; stdcall;
    // методо получения описания типа
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): Integer;
      stdcall;
    // метод осуществляет трансляцию имен методов и свойств объекта автоматизации в целочисленные идентификаторы
    function GetIDsOfNames(const IID: TGUID; Names: pointer;
      NameCount, LocaleID: Integer; DispIDs: pointer): Integer; stdcall;
    // методо установки свойств объекта
    function Invoke(DispID: Integer; // Идентификатор вызываемого метода или свойства, полученный от GetIdsOfNames
      const IID: TGUID; // Региональный контекст (тот же, что и в GetIdsOfNames)
      LocaleID: Integer; Flags: Word; // Битовая маска, состоящая из следующих флагов
      // Значение Комментарий
      // DISPATCH_METHOD Вызывается метод. Если у объекта есть свойство с таким же именем, то будет установлен также флаг DISPATCH_PROPERTYGET
      // DISPATCH_PROPERTYGET Запрашивается значение свойства
      // DISPATCH_PROPERTYPUT Устанавливается значение свойства
      // DISPATCH_PROPERTYPUTREF Параметр передается по ссылке. Если флаг не установлен – по значению
      // Структура DISPPARAMS, содержащая массив параметров, массив идентификаторов для именованных параметров,
      // и количества элементов в этих массивах. Параметры передаются в порядке, обратном их порядку следования в функции, как
      // принято в Visual Basic
      var Params; VarResult, // Адрес переменной типа OleVariant, в которую должен быть помещен результат вызова метода или значение свойства или NIL, если возвращаемое значение не требуется.
      ExcepInfo, // Адрес структуры EXCEPTINFO, которую метод должен заполнить информацией об ошибке, если она возникнет.
      // Адрес массива, в который должны быть помещены индексы неверных параметров, в случае, если такая ситуация будет обнаружена.
      // При вызове Invoke не осуществляется никаких проверок, поэтому при его самостоятельной реализации необходимо соблюдать аккуратность при работе с переданными адресами массивов и переменных.
      ArgErr: pointer): Integer; stdcall;
  //IUnknown
  // переопределленный релиз запрещает удалять скрипту объект прикрепленный к тегу, надо делать так как vbscript не
  // правильно считает ссылки
  public
    //function _Release: Integer; stdcall;
  public
    constructor Create;
    destructor destroy;
  protected
    procedure setfreq(f: double);
    procedure setUnits(u: string);
    function getUnits: string;
    procedure setDsc(u: string);
    function getDsc: string;
  public
    property Units: string read getUnits write setUnits;
    property Name: string read GetName write SetName;
    property DSC: string read getDsc write setDsc;
    property freq: double read ffreq write setfreq;
  end;

  TScriptFrm = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N19: TMenuItem;
    N4: TMenuItem;
    N6: TMenuItem;
    N25: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    N24: TMenuItem;
    N13: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N27: TMenuItem;
    ImageListEditor: TImageList;
    ImageListItems: TImageList;
    ImageListFunc: TImageList;
    ToolBar1: TToolBar;
    SaveBtn: TToolButton;
    CutBtn: TToolButton;
    LoadBtn: TToolButton;
    CopyBtn: TToolButton;
    PasteBtn: TToolButton;
    DelBtn: TToolButton;
    UpdateBtn: TToolButton;
    Splitter1: TSplitter;
    PanelTools: TPanel;
    ScriptControl1: TScriptControl;
    Memo1: TMemo;
    ListViewItems: TBtnListView;
    Panel1: TPanel;
    Label1: TLabel;
    ScriptDT: TFloatEdit;
    ImageList_32: TImageList;
    ToolBar2: TToolBar;
    AddTagBtn: TToolButton;
    DelTagBtn: TToolButton;
    T1Label: TLabel;
    T1FE: TFloatEdit;
    T2FE: TFloatEdit;
    T2Label: TLabel;
    RichEdit1: TRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure UpdateBtnClick(Sender: TObject);
    procedure ScriptControl1Error(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure AddTagBtnClick(Sender: TObject);
    procedure ScriptDTChange(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
  private
    mng: cWPObjMng;
    cursrc,
    // папка с результатами
    resSrc: csrc;
    // список tScriptItem-ов из источника данных
    srclist,
    // список имен тегов в скрипте которые подлежат изменениям
    ScriptNames: tstringlist;
    // массив параметров скрипта
    pPar: psafearray;
    SA: TSafeArrayBound;
  private
    procedure ShowTagsNames;
    procedure AddSI(si: TScriptItem);
    procedure AddSItoLV(si: TScriptItem);
    // создает теги скрипта
    procedure InitTags(src: csrc);
    // вспомогательная функция для создания тегов скрипта (перенос тегов в движок)
    procedure updateScriptNames;
    // очистка движка от созданых тегов
    procedure ClearTags;
    // получаем максимальную частоту дискретизации по всем тегам
    function getMaxFs: double;
    function GetSI(name: string): TScriptItem;
  public
    function GetLen: double;
    procedure doAddChannel(Sender: TObject);
  protected
    // работа с массивом параметров
    procedure SetParam(index: Integer; value: variant);
    procedure CreateParams;
    // функция получает список тегов в коде скрипта в которые пишутся данные
    function GetChangedScriptNames(str: string; list: tstringlist): Integer;
    // function CreateTag(str:string; list:tstringlist):integer;
    // получить имена всех тегов в скрипте
    function GetScriptNames(str: string; list: tstringlist): Integer;
    function GetALLNames(list: tstringlist): Integer;
    function GetTimeStruct(list: tstringlist): TimeStruct;overload;
    function GetTimeStruct: TimeStruct;overload;
    function GetminDT: double;
    // перекодирует текст в понятный VBScript-у
    function GetScriptText(code:string; var err:ErrorStruct):string;
    procedure SaveText(code:string);
    procedure LoadText;
  public
    procedure linc(p_mng: TObject);
    constructor Create(AOwner: TComponent); override;
  end;

  cScriptSignal = class
  public
    s: cwpsignal;
  public
    procedure setvalue(t: double; v: double);
    function getvalue(t: double): double;
  end;

var
  script_time: double;
  ScriptFrm: TScriptFrm;

const
  //Сиволы недопустимые в тексте
  u_chars = 'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюя()[]{}-+=&#$`\;,. _\"\n*|:<>~/!@№%^?"';

implementation

uses
  uWpExtPack, uAddScriptItemFrm;
{$R *.dfm}

procedure cScriptSignal.setvalue(t: double; v: double);
var
  i: Integer;
begin
  i := s.signal.IndexOf(t);
  s.signal.SetY(i, v);
end;

function cScriptSignal.getvalue(t: double): double;
var
  i: Integer;
begin
  // i := s.Signal.IndexOf(t);
  // result:=s.Signal.GetY(i);
  // 1 - порядок интерполяции
  result := s.signal.GetYX(t, 1);
end;

procedure TScriptItem.setvalue(t: double; v: double);
begin
  cScriptSignal(m_pitem).setvalue(t, v);
end;

function TScriptItem.getvalue(t: double): double;
begin
  result := cScriptSignal(m_pitem).getvalue(t);
end;

function TScriptItem.GetName: string;
begin
  if (m_pitem <> nil) then
  begin
    result := cScriptSignal(m_pitem).s.Name;
  end
  else
  begin
    result := fname;
  end;
end;


function TScriptItem.GetScriptName: string;
begin
  if (m_pitem <> nil) then
  begin
    result := '{' + cScriptSignal(m_pitem).s.Name + '}';
  end
  else
  begin
    result := '{' + fname + '}';
  end;
end;

procedure TScriptItem.SetName(s: string);
begin
  fname := s;
  if m_pitem <> nil then
  begin
    cScriptSignal(m_pitem).s.Name := fname;
  end
end;

// Найти первое попавшееся имя в скрипте ограниченное символами "{}"
function GetScriptName(str:string; start:integer;var index:tpoint):string;
var
  i,deep:integer;
  buf:string;
  findname:boolean;
begin
  findname := false;
  i:=start;
  while i < length(str) do
  begin
    // если не имя
    if not findname then
    begin
      // если нашли начало имени тега
      if str[i] = '{' then
      begin
        index.X:=i;
        deep := 0;
        buf := '';
        inc(i);
        findname := true;
        while not ((str[i] = '}') and (deep=0)) do
        begin
          // если новые скобки внутри имени тега
          if str[i] = '{' then
            inc(deep)
          else
          begin
            if str[i] = '}' then
              dec(deep)
            else
            begin
              buf := buf + str[i];
            end;
          end;
          inc(i);
        end; // WhileEnd Если нашли конец имени
        index.Y:=i;
        result:=buf;
        exit;
      end;
    end; // выход из поиска имени
  end;
end;


procedure TScriptItem.initSignal(p_s: cwpsignal);
begin
  cScriptSignal(m_pitem).s := p_s;
  ffreq := p_s.fs;
end;

function TScriptItem.signal: cwpsignal;
begin
  result := cScriptSignal(m_pitem).s;
end;

function TScriptItem.GetTypeInfoCount(out Count: Integer): Integer;
begin
  Count := 0;
  result := s_ok;
end;

function TScriptItem.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo)
  : Integer;
begin
  pointer(TypeInfo) := nil;
  result := E_FAIL;
end;

{function TScriptItem._Release: Integer;
begin
  result:= InterlockedDecrement( &FRefCount);
  if (m_pitem=nil) and (result<0) then
  begin
    self.destroy;
  end;
end;}

constructor TScriptItem.Create;
begin
  m_pitem := cScriptSignal.Create;
end;

destructor TScriptItem.destroy;
begin
  cScriptSignal(m_pitem).s := nil;
  cScriptSignal(m_pitem).destroy;
  m_pitem := nil;
end;

function TScriptItem.GetIDsOfNames(const IID: TGUID; Names: pointer;
  NameCount, LocaleID: Integer; DispIDs: pointer): Integer;
var
  name: widestring;
  i, id: Integer;
begin
  result := s_ok;
  // Не поддерживаем именованные аргументы
  if NameCount > 1 then
    result := DISP_E_UNKNOWNNAME
  else
  begin
    if NameCount < 1 then
      result := E_INVALIDARG
    else
      result := s_ok;
    for i := 0 to NameCount - 1 do
      id := DISPID_UNKNOWN;
    if NameCount = 1 then
    begin
      Name := PWideChar(Names^);
      id := 0;
      if UpperCase(Name) = '1' then
        id := 1;
      if UpperCase(Name) = '2' then
        id := 2;
      if id = 0 then
        result := DISP_E_UNKNOWNNAME;
    end;
  end;
end;

procedure TScriptItem.setfreq(f: double);
begin
  cScriptSignal(m_pitem).s.setFs(f);
  ffreq := f;
end;

procedure TScriptItem.setUnits(u: string);
begin
  cScriptSignal(m_pitem).s.signal.NameY := u;
end;

function TScriptItem.getUnits: string;
begin
  result := cScriptSignal(m_pitem).s.signal.NameY;
end;

procedure TScriptItem.setDsc(u: string);
begin
  cScriptSignal(m_pitem).s.signal.comment := u;
end;

function TScriptItem.getDsc: string;
begin
  result := cScriptSignal(m_pitem).s.signal.comment;
end;

function TScriptItem.Invoke(DispID: Integer;
                            const IID: TGUID;
                            LocaleID: Integer;
                            Flags: Word;
                            var Params;
                            VarResult,
                            ExcepInfo,
                            ArgErr: pointer): Integer;
var
  v: tagvariant;
  h: hresult;
  si: TScriptItem;
  name: string;
begin
  name := GetName;
  // если данный proxy объект не подключен ни к чему, то...
  if (m_pitem = nil) then
  begin
    result := E_FAIL;
    exit;
  end;
  // если требуется установить значение свойства, то...
  if ((Flags and DISPATCH_PROPERTYPUT) = DISPATCH_PROPERTYPUT) then
  begin
    // если указано в аргументе новое значение, то...
    if (DISPPARAMS(Params).cArgs <> 0) then
    begin
      // получение значения, проверка и при
      // необходимости смена типа значения
      v := DISPPARAMS(Params).rgvarg[0];
      if (v.vt <> VT_R8) then
      begin
        if (v.vt = VT_i2) then
        begin
          v.vt := VT_R8;
          v.dblVal := v.iVal;
        end;
        if (v.vt = VT_i4) then
        begin
          v.vt := VT_R8;
          v.dblVal := v.intVal;
        end;
        if (v.vt = VT_DISPATCH) then
        begin
          VariantChangeType(olevariant(v), olevariant(DISPPARAMS(Params).rgvarg[0]), 0, VT_R8);
          // SA:=pSafeArray(v.pdispVal);
          // index:=1;
          // SafeArrayGetElement(SA, index, si);
        end;
      end;
      // result := setvalue(script_time,v.dblVal);
      // setvalue(script_time,p.rgvarg^[0].pdblVal^);
      setvalue(script_time, v.dblVal);
      // setvalue(script_time,DISPPARAMS(Params).rgvarg^[0].dblVal^);
      result := s_ok;
      exit;
    end;
  end
  // если требуется получить значение свойства, то...
  else
  begin
    if ((Flags and DISPATCH_PROPERTYGET) = DISPATCH_PROPERTYGET) and
      (VarResult <> nil) then
    begin
      // v := DISPPARAMS(Params).rgvarg[0];
      // if (v.vt <> VT_R8) then
      // begin
      // if (v.vt = VT_i2) then
      // begin
      // v.vt := VT_R8;
      // v.dblVal:=v.iVal;
      // end;
      // if (v.vt = VT_i4) then
      // begin
      // v.vt := VT_R8;
      // v.dblVal:=v.intVal;
      // end;
      // end;
      // получение значения парметра
      // VariantInit(olevariant(VarResult));
      // OleVariant(VarResult^).vt:=VT_R8;
      // OleVariant(VarResult^).dblVal:=GetValue(script_time);
      olevariant(VarResult^) := getvalue(script_time);
      result := s_ok;
    end
    else
    begin
      result := s_ok;
    end;
  end;
end;

procedure TScriptFrm.InitTags(src: csrc);
var
  i: Integer;
  s: cwpsignal;
  scriptitem: TScriptItem;
begin
  for i := 0 to src.Count - 1 do
  begin
    scriptitem := TScriptItem.Create;
    s := src.GetWPSignal(i);
    scriptitem.initSignal(s);
    srclist.AddObject(s.Name, scriptitem);
  end;
  updateScriptNames;
end;

procedure TScriptFrm.FormDestroy(Sender: TObject);
begin
  srclist.destroy;
  ScriptNames.destroy;
end;

procedure TScriptFrm.FormShow(Sender: TObject);
var
  ts: TimeStruct;
begin
  // обновляем список тегов движка скриптов
  cursrc := mng.GetCurSrcInMainWnd;
  if resSrc = nil then
  begin
    resSrc := mng.addsrc('ScriptResults');
    AddScriptItemFrm.resSrc := resSrc;
  end;
  AddScriptItemFrm.LinkMng(cWPObjMng(mng), srclist, resSrc, doAddChannel);
  if cursrc <> nil then

  begin
    InitTags(cursrc);
    ShowTagsNames;
  end;
  GetALLNames(ScriptNames);
  ts := GetTimeStruct(ScriptNames);
  ScriptDT.FloatNum := ts.min_dT;
  T1FE.FloatNum := ts.minT;
  T2FE.FloatNum := ts.maxT;
end;

procedure TScriptFrm.linc(p_mng: TObject);
begin
  mng := cWPObjMng(p_mng);
end;

procedure TScriptFrm.N4Click(Sender: TObject);
begin
  AddScriptItemFrm.ShowModal;
end;

procedure TScriptFrm.CreateParams;
begin
  SA.cElements := 0;
  pPar := SafeArrayCreate(varVariant, 1, SA);
end;

function TScriptFrm.GetALLNames(list: tstringlist): Integer;
var
  i, deep: Integer;
  buf: string;
  findname: boolean;
  si: TScriptItem;
begin
  list.Clear;
  for i := 0 to ListViewItems.Items.Count - 1 do
  begin
    si := TScriptItem(ListViewItems.Items[i].data);
    list.Add(si.name);
  end;
  result := list.Count;
end;

// Лист должен запрещать повторы и быть отсортированным
function TScriptFrm.GetScriptNames(str: string; list: tstringlist): Integer;
var
  i, deep: Integer;
  buf: string;
  findname: boolean;
begin
  i := 1;
  findname := false;
  result := list.Count;
  while i < length(str) do
  begin
    // если не имя
    if not findname then
    begin
      // если нашли начало имени тега
      if str[i] = '{' then
      begin
        deep := 0;
        buf := '';
        inc(i);
        findname := true;
        while str[i] <> '}' do
        begin
          // если новые скобки внутри имени тега
          if str[i] = '{' then
            inc(deep)
          else
          begin
            if str[i] = '}' then
              dec(deep)
            else
            begin
              buf := buf + str[i];
            end;
          end;
          inc(i);
        end; // WhileEnd Если нашли конец имени
      end;
    end; // выход из поиска имени
    list.Add(buf);
  end;
  result := list.Count - result;
end;

function TScriptFrm.GetChangedScriptNames(str: string; list: tstringlist)
  : Integer;
var
  i, deep: Integer;
  buf: string;
  findname: boolean;
begin
  i := 0;
  findname := false;
  result := list.Count;
  while i < length(str) do
  begin
    inc(i);
    // если не имя
    if not findname then
    begin
      // если нашли начало имени тега
      if str[i] = '{' then
      begin
        deep := 0;
        buf := '';
        inc(i);
        findname := true;
        while not ((str[i] = '}') and (deep=0)) do
        begin
          // если новые скобки внутри имени тега
          if str[i] = '{' then
            inc(deep)
          else
          begin
            if str[i] = '}' then
              dec(deep)
            else
            begin
              buf := buf + str[i];
            end;
          end;
          inc(i);
        end; // WhileEnd Если нашли конец имени
        inc(i);
      end;
    end; // выход из поиска имени
    // ищем знак равно или другие операторы
    if findname then
    begin
      while findname do
      begin
        while str[i] = ' ' do
        begin
          inc(i);
        end;
        // добавляем меняемый тег
        if str[i] = '=' then
        begin
          list.Add(buf);
        end;
        findname := false;
      end;
    end; // завершение поиска знака равно
  end;
  result := list.Count - result;
end;

function TScriptFrm.GetminDT: double;
var
  i: Integer;
  s: cwpsignal;
  dt: double;
begin
  if cursrc = nil then
    exit;
  if cursrc.Count = 0 then
    exit;
  s := cursrc.GetWPSignal(0);
  dt := 1 / s.fs;
  result := dt;
  for i := 0 to cursrc.Count - 1 do
  begin
    s := cursrc.GetWPSignal(i);
    dt := 1 / s.fs;
    result := Min(dt, result);
  end;
end;

function TScriptFrm.GetTimeStruct: TimeStruct;
begin
  result.min_dT := scriptdt.FloatNum;
  result.minT := t1fe.FloatNum;
  result.maxT := t2fe.FloatNum;
end;

function TScriptFrm.GetTimeStruct(list: tstringlist): TimeStruct;
var
  i: Integer;
  str: string;
  v: double;
  s: TScriptItem;
begin
  str := list.Strings[0];
  s := GetSI(str);
  if not s.ScriptChannel then
  begin
    result.min_dT := 1 / s.freq;
    result.minT := s.signal.signal.MinX;
    result.maxT := s.signal.signal.MaxX;
  end;
  for i := 1 to list.Count - 1 do
  begin
    str := list.Strings[i];
    s := GetSI(str);
    if not s.ScriptChannel then
    begin
      // если переменная привязана к тегу
      if s <> nil then
      begin
        v := 1 / s.freq;
        result.min_dT := Min(result.min_dT, v);
        v := s.signal.signal.MinX;
        result.minT := Min(result.minT, v);
        v := s.signal.signal.MaxX;
        result.maxT := max(result.maxT, v);
      end;
    end;
  end;
end;

procedure TScriptFrm.SetParam(index: Integer; value: variant);
var
  idx: array [0 .. 0] of Integer;
  v, varr: variant;
begin
  // varr := VarArrayCreate([0, 1], varVariant);
  // varr[0] := 1;
  // varr[1] := 5;
  // pPar := psafearray(TVarData(varr).VArray);
  // SafeArrayGetElement(PSA, idx, V);
  idx[0] := 0;
  v := 91;
  SafeArrayPutElement(pPar, idx, v);
end;

constructor TScriptFrm.Create(AOwner: TComponent);
begin
  AddScriptItemFrm := TAddScriptItemFrm.Create(nil);
  CreateParams;
  inherited;
end;

function TScriptFrm.getMaxFs: double;
var
  fmax, f: double;
  s: cwpsignal;
  i: Integer;
begin
  fmax := 0;
  for i := 0 to cursrc.Count - 1 do
  begin
    s := cursrc.GetWPSignal(i);
    f := 1 / s.signal.DeltaX;
    if fmax < f then
      fmax := f;
  end;
  result := fmax;
end;

function TScriptFrm.GetSI(name: string): TScriptItem;
var
  i: Integer;
  si: TScriptItem;
begin
  result := nil;
  if srclist.find(name, i) then
    result := TScriptItem(srclist.Objects[i]);
end;

procedure TScriptFrm.AddTagBtnClick(Sender: TObject);
begin
  AddScriptItemFrm.ShowModal;
  ShowTagsNames;
end;

procedure TScriptFrm.ClearTags;
var
  i: Integer;
  s: TScriptItem;
begin
  for i := 0 to srclist.Count - 1 do
  begin
    s := TScriptItem(srclist.Objects[i]);
    s.destroy;
  end;
  srclist.Clear;
  ScriptControl1.Reset;
end;

procedure TScriptFrm.AddSI(si: TScriptItem);
begin
  srclist.AddObject(si.name, si);
  AddSItoLV(si);
end;

procedure TScriptFrm.doAddChannel(Sender: TObject);
begin
  AddSI(TScriptItem(Sender));
end;

function TScriptFrm.GetLen: double;
begin
  result := T2FE.FloatNum - T1FE.FloatNum;
end;

procedure TScriptFrm.AddSItoLV(si: TScriptItem);
var
  li: tlistitem;
begin
  li := ListViewItems.Items.Add;
  li.data := si;
  ListViewItems.SetSubItemByColumnName('Имя', si.Name, li);
  if si.ScriptChannel then
  begin
    ListViewItems.SetSubItemByColumnName('fs', floattostr(si.freq), li);
    ListViewItems.SetSubItemByColumnName('Тип', 'Результирующий', li);
  end
  else
  begin
    if si.m_pitem <> nil then
    begin
      ListViewItems.SetSubItemByColumnName('fs', floattostr(si.freq), li);
      ListViewItems.SetSubItemByColumnName('Тип', 'Замер', li);
    end
    else
    begin
      ListViewItems.SetSubItemByColumnName
        ('fs', floattostr(1 / ScriptDT.FloatNum), li);
      ListViewItems.SetSubItemByColumnName('Тип', 'Виртуальный', li);
    end;
  end;
end;

procedure TScriptFrm.ShowTagsNames;
var
  i: Integer;
  s: TScriptItem;
  src: csrc;
begin
  ListViewItems.Clear;
  for i := 0 to srclist.Count - 1 do
  begin
    s := TScriptItem(srclist.Objects[i]);
    AddSItoLV(s);
  end;
  LVChange(ListViewItems);
end;

procedure TScriptFrm.SaveBtnClick(Sender: TObject);
begin
  SaveText(RichEdit1.text);
end;

procedure TScriptFrm.SaveText(code:string);
var
  f:tinifile;
  doc:TNativeXml;
  node:txmlnode;
  I: Integer;
  dir:string;
begin
  f:=tinifile.Create(startdir+'wpproc.ini');
  f.WriteString('Script','ScriptFile','\ScriptFile.xml');
  f.Destroy;

  doc:=TNativeXml.CreateName('Root');
  Doc.XmlFormat := xfReadable;
  node:=doc.Root;
  node.WriteAttributeString('Code',code,'');
  doc.SaveToFile(startdir+'ScriptFile.xml');
end;

procedure TScriptFrm.LoadBtnClick(Sender: TObject);
begin
  loadtext;
end;

procedure TScriptFrm.LoadText;
var
  doc:TNativeXml;
  node:txmlnode;
  f:tinifile;
  str:string;
begin
  f:=tinifile.Create(startdir+'\wpproc.ini');
  str:=f.ReadString('Script','ScriptFile','ScriptFile.xml');
  f.Destroy;

  doc:=TNativeXml.Create(nil);
  doc.LoadFromFile(startdir+str);
  node:=doc.Root;
  str:=node.ReadAttributeString('Code','');
  RichEdit1.Text:=str;
  doc.Destroy;
end;

function TScriptFrm.GetScriptText(code:string; var err:ErrorStruct):string;
var
  // позиция ошибки
  row,
  deep,
  i:integer;
  ind:tpoint;
  buf:string;
  findname:boolean;
begin
  i:=0;
  while I <= length(code) - 1 do
  begin
    inc(i);
    // перевод каретки
    if code[i]=char(0) then
    begin
      inc(row);
      continue;
    end;
    // удаляем скобки имен из кода
    if code[i]='{' then
    begin
      // получаем текст в скобочках
      buf:=GetScriptName(code,i,ind);
      code:=ReplaceSubstr(code,'{'+buf+'}', buf, i);
      //code:=ReplaceSubstr('ABCDEF','CD', 'AA', 2);
      i:=i+length(buf)-1;
    end;
  end;
  result:=code;
end;

procedure TScriptFrm.FormCreate(Sender: TObject);
begin
  srclist := tstringlist.Create;
  srclist.sorted := true;

  ScriptNames := tstringlist.Create;
  ScriptNames.sorted := true;
  ScriptNames.Duplicates := dupIgnore;

  ScriptControl1.Language := 'VBScript';
  ScriptControl1.UseSafeSubset := false;
  ScriptControl1.AllowUI := true;

  // задержка после которой генерится ошибка - 5 секунд
  ScriptControl1.Timeout := 5000;
end;

procedure TScriptFrm.ScriptControl1Error(Sender: TObject);
begin
  Memo1.Clear;
  Memo1.text := 'dsc: ' + ScriptControl1.Error.Description;
  Memo1.text := Memo1.text + 'Number: ' + inttostr(ScriptControl1.Error.Number);
  Memo1.text := Memo1.text + 'Line: ' + inttostr(ScriptControl1.Error.Line);
  Memo1.text := Memo1.text + 'HelpContext: ' + inttostr
    (ScriptControl1.Error.HelpContext);
end;

procedure TScriptFrm.ScriptDTChange(Sender: TObject);
begin
  AddScriptItemFrm.minFS := ScriptDT.FloatNum;
end;

procedure TScriptFrm.UpdateBtnClick(Sender: TObject);
var
  v
  // ,varr
    , res: variant;
  str: widestring;
  i: Integer;
  si: TScriptItem;
  li: tlistitem;
  t: double;
  ts: TimeStruct;
  err:ErrorStruct;
  count:integer;
begin
  // str:='';
  str := 'Sub Main( )' + #10#13;
  str := str + RichEdit1.text;
  str := str + #10#13 + 'End Sub';
  ScriptNames.Clear;
  try
    //--------------------вынести в отдельную процедуру по инициализации-------
    // получаем список тегов которые должны быть отредактированы скриптом
    count:=GetChangedScriptNames(str, ScriptNames);
    if count=0 then exit;
    updateScriptNames;

    t := t + ScriptDT.FloatNum;
    script_time:=t;
    SetParam(0, t);
    res := ScriptControl1.Run('Main', pPar);
    //--------------------вынести в отдельную процедуру по инициализации-------
    {while t < ts.maxT do
    begin
      script_time:=t;
      SetParam(0, t);
      res := ScriptControl1.Run('Main', pPar);
      t := t + ScriptDT.FloatNum;
    end;}

    // res := ScriptControl1.Eval(str);
    // Memo1.text := 'a:' + inttostr(pvar[0]);
    // Memo1.text := Memo1.text + 'b:' + inttostr(pvar[1]);
  finally

  end;
  // memo1.text:=IntToStr(res);
end;

procedure TScriptFrm.updateScriptNames;
var
  i: Integer;
  si: TScriptItem;
begin
  // сбрасывает добавленные объекты и код
  ScriptControl1.Reset;
  for i := 0 to srclist.Count - 1 do
  begin
    si := TScriptItem(srclist.Objects[i]);
    ScriptControl1.AddObject(si.GetName, si, true);
  end;
end;

end.
