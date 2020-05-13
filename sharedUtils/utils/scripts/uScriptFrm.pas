unit uScriptFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, ToolWin, ImgList, Menus, Buttons,
  OleCtrls, MSScriptControl_TLB, ActiveX, uWPproc, uBtnListView, comobj,
  uComponentServises, math, DCL_MYOWN;

type
  // В целях оптимизации кода и ускорения работы выполнения скрипта,
  // записывать в исходные теги (аппаратные) запрещено
  // логика выполнения - есть частота выполнения скрипта, с этой частотой выполняется скрипт
  // данными выходные теги. После завершения скрипта выходные теги усредняются таким образом чтобы частота по каждому
  // из них равнялась заданной в настройке. (т.е. параметр частота выполнения скрипта определеет максимальную частоту
  // выходных тегов и объем вычислений)

  TimeStruct =record
    // минимальный шаг по времени среди обрабатываемых тегов
    min_dT,
    // минимальное время среди обрабатываемых тегов
    minT,
    // мarcимальное время среди обрабатываемых тегов
    maxT:double;
  end;

  TScriptItem = class(TInterfacedObject, idispatch)
  public
    m_pitem: pointer; // ссылка на данные
    fname: string;
    ffreq:double;
    // переменная для прореживания записи в тег. Записано время последней записи в канал
    LastValueTime:double;
    ScriptChannel:boolean;
  public
    procedure setvalue(t: double; v: double); virtual;
    function getvalue(t: double): double; virtual;
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
    constructor Create;
    destructor destroy;
  protected
    procedure setfreq(f:double);
    procedure setUnits(u:string);
    function getUnits:string;
    procedure setDsc(u:string);
    function getDsc:string;
  public
    property Units:string read getUnits write SetUnits;
    property Name: string read GetName write SetName;
    property DSC: string read GetDSC write SetDSC;
    property freq:double read ffreq write setfreq;
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
    UndoBtn: TToolButton;
    CopyBtn: TToolButton;
    PasteBtn: TToolButton;
    DelBtn: TToolButton;
    UpdateBtn: TToolButton;
    Splitter1: TSplitter;
    PanelTools: TPanel;
    ScriptControl1: TScriptControl;
    Memo1: TMemo;
    Memo2: TMemo;
    ListViewItems: TBtnListView;
    Panel1: TPanel;
    Label1: TLabel;
    ScriptDT: TFloatEdit;
    ImageList_32: TImageList;
    ToolBar2: TToolBar;
    AddTagBtn: TToolButton;
    DelTagBtn: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure UpdateBtnClick(Sender: TObject);
    procedure ScriptControl1Error(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure AddTagBtnClick(Sender: TObject);
    procedure ScriptDTChange(Sender: TObject);
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
    // создает теги скрипта
    procedure InitTags(src: csrc);
    // вспомогательная функция для создания тегов скрипта (перенос тегов в движок)
    procedure updateScriptNames;
    // очистка движка от созданых тегов
    procedure ClearTags;
    // получаем максимальную частоту дискретизации по всем тегам
    function getMaxFs: double;
    function GetSI(name:string):TScriptItem;
  protected
    // работа с массивом параметров
    procedure SetParam(index: Integer; value: variant);
    procedure CreateParams;
    // функция получает список тегов в коде скрипта в которые пишутся данные
    function GetChangedScriptNames(str:string; list:tstringlist):integer;
    // получить имена всех тегов в скрипте
    function GetScriptNames(str:string; list:tstringlist):integer;
    function GetTimeStruct(list:tstringlist):TimeStruct;
    function GetminDT:double;
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

implementation

uses
  uWpExtPack, uAddScriptItemFrm;
{$R *.dfm}

procedure cScriptSignal.setvalue(t: double; v: double);
var
  i: Integer;
begin
  i := s.Signal.IndexOf(t);
  s.Signal.SetY(i, v);
end;

function cScriptSignal.getvalue(t: double): double;
var
  i: Integer;
begin
  // i := s.Signal.IndexOf(t);
  // result:=s.Signal.GetY(i);
  result := s.Signal.GetYX(t, 1)
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
  if m_pitem <> nil then
  begin
    result := cScriptSignal(m_pitem).s.Name;
  end
  else
    result := fname;
end;

procedure TScriptItem.SetName(s: string);
begin
  fname := s;
  if m_pitem <> nil then
  begin
    cScriptSignal(m_pitem).s.Name := fname;
  end
end;

procedure TScriptItem.initSignal(p_s: cwpsignal);
begin
  cScriptSignal(m_pitem).s := p_s;
  ffreq:=p_s.fs;
end;

function TScriptItem.signal: cwpsignal;
begin
  result:=cScriptSignal(m_pitem).s;
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

procedure TScriptItem.setfreq(f:double);
begin
  cScriptSignal(m_pitem).s.setFs(f);
  ffreq:=f;
end;

procedure TScriptItem.setUnits(u:string);
begin
  cScriptSignal(m_pitem).s.Signal.NameY:=u;
end;

function TScriptItem.getUnits:string;
begin
  result:=cScriptSignal(m_pitem).s.Signal.NameY;
end;

procedure TScriptItem.setDsc(u:string);
begin
  cScriptSignal(m_pitem).s.Signal.comment:=u;
end;

function TScriptItem.getDsc:string;
begin
  result:=cScriptSignal(m_pitem).s.Signal.comment;
end;

function TScriptItem.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
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
          VariantChangeType(olevariant(v), olevariant(v), 0, VT_R8);
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
begin
  // обновляем список тегов движка скриптов
  cursrc := mng.GetCurSrcInMainWnd;
  if cursrc <> nil then
  begin
    InitTags(cursrc);
    ShowTagsNames;
  end;
  scriptdt.FloatNum:=GetminDT;
end;

procedure TScriptFrm.linc(p_mng: TObject);
begin
  mng := cWPObjMng(p_mng);
  AddScriptItemFrm.LinkMng(cWPObjMng(p_mng), srclist, ressrc);
end;

procedure TScriptFrm.N4Click(Sender: TObject);
begin
  if ressrc=nil then
  begin
    ressrc:=mng.addsrc('ScriptResults');
    AddScriptItemFrm.ressrc:=ressrc;
  end;
  AddScriptItemFrm.ShowModal;
end;

procedure TScriptFrm.CreateParams;
begin
  SA.cElements := 0;
  pPar := SafeArrayCreate(varVariant, 1, SA);
end;
// Лист должен запрещать повторы и быть отсортированным
function TScriptFrm.GetScriptNames(str:string; list:tstringlist):integer;
var
  I,
  deep: Integer;
  buf:string;
  findname:boolean;
begin
  i:=1;
  findname:=false;
  result:=list.count;
  while I < length(str) do
  begin
    // если не имя
    if not findname then
    begin
      // если нашли начало имени тега
      if str[i]='{' then
      begin
        deep:=0;
        buf:='';
        inc(i);
        findname:=true;
        while str[i]<>'}' do
        begin
          // если новые скобки внутри имени тега
          if str[i]='{' then
            inc(deep)
          else
          begin
            if str[i]='}' then
              dec(deep)
            else
            begin
              buf:=buf+str[i];
            end;
          end;
          inc(i);
        end; // WhileEnd Если нашли конец имени
      end;
    end; // выход из поиска имени
    list.Add(buf);
  end;
  result:=list.Count-result;
end;

function TScriptFrm.GetChangedScriptNames(str:string; list:tstringlist):integer;
var
  I,
  deep: Integer;
  buf:string;
  findname:boolean;
begin
  i:=1;
  findname:=false;
  result:=list.count;
  while I < length(str) do
  begin
    // если не имя
    if not findname then
    begin
      // если нашли начало имени тега
      if str[i]='{' then
      begin
        deep:=0;
        buf:='';
        inc(i);
        findname:=true;
        while str[i]<>'}' do
        begin
          // если новые скобки внутри имени тега
          if str[i]='{' then
            inc(deep)
          else
          begin
            if str[i]='}' then
              dec(deep)
            else
            begin
              buf:=buf+str[i];
            end;
          end;
          inc(i);
        end; // WhileEnd Если нашли конец имени
      end;
    end; // выход из поиска имени
    // ищем знак равно или другие операторы
    if findname then
    begin
      while findname do
      begin
        if str[i]=' ' then
          inc(i)
        else
        begin
          // добавляем меняемый тег
          if str[i]='=' then
          begin
            list.Add(buf);
          end;
          findname:=false;
        end;
      end;
    end;// завершение поиска знака равно
  end;
  result:=list.Count-result;
end;

function TScriptFrm.GetminDT:double;
var
  I: Integer;
  s:cwpsignal;
  dt:double;
begin
  if cursrc=nil then exit;
  if cursrc.Count=0 then exit;
  s:=cursrc.GetWPSignal(0);
  dt:=1/s.fs;
  result:=dt;
  for I := 0 to cursrc.Count - 1 do
  begin
    s:=cursrc.GetWPSignal(i);
    dt:=1/s.fs;
    result:=Min(dt,result);
  end;
end;

function TScriptFrm.GetTimeStruct(list:tstringlist):TimeStruct;
var
  I: Integer;
  str:string;
  v:double;
  s:tscriptitem;
begin
  str:=list.Strings[0];
  s:=GetSI(str);
  Result.min_dT:=1/s.freq;
  Result.minT:=s.signal.Signal.MinX;
  Result.maxT:=s.signal.Signal.MaxX;
  for I := 1 to List.Count - 1 do
  begin
    str:=list.Strings[i];
    s:=GetSI(str);
    // если переменная привязана к тегу
    if s<>nil then
    begin
      v:=1/s.freq;
      Result.min_dT:=min(Result.min_dT, v);
      v:=s.signal.Signal.MinX;
      Result.minT:=min(Result.minT, v);
      v:=s.signal.Signal.MaxX;
      Result.maxT:=max(Result.maxT, v);
    end;
  end;
end;

procedure TScriptFrm.SetParam(index: Integer; value: variant);
var
  idx:array[0..0] of integer;
  v, varr:variant;
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
    f := 1 / s.Signal.DeltaX;
    if fmax < f then
      fmax := f;
  end;
  result := fmax;
end;

function TScriptFrm.GetSI(name:string):TScriptItem;
var
  I: Integer;
  si:TScriptItem;
begin
  result:=nil;
  if srclist.find(name,i) then
    result:=tscriptitem(srclist.Objects[i]);
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
  srclist.clear;
  ScriptControl1.Reset;
end;

procedure TScriptFrm.ShowTagsNames;
var
  li: tlistitem;
  i: Integer;
  s: TScriptItem;
  src: csrc;
begin
  ListViewItems.clear;
  for i := 0 to srclist.Count - 1 do
  begin
    s := TScriptItem(srclist.Objects[i]);
    li := ListViewItems.Items.add;
    li.Data := s;
    ListViewItems.SetSubItemByColumnName('Имя', s.Name, li);
    if s.m_pitem<>nil then
    begin
      ListViewItems.SetSubItemByColumnName('fs', floattostr(s.freq), li);
      ListViewItems.SetSubItemByColumnName('Тип', 'Замер', li);
    end
    else
    begin
      ListViewItems.SetSubItemByColumnName('fs', floattostr(1/scriptDT.FloatNum), li);
      ListViewItems.SetSubItemByColumnName('Тип', 'Виртуальный', li);
    end;
  end;
  LVChange(ListViewItems);
end;

procedure TScriptFrm.FormCreate(Sender: TObject);
begin
  srclist := tstringlist.Create;
  srclist.sorted := true;

  ScriptNames:=tstringlist.Create;
  ScriptNames.Sorted:=true;
  ScriptNames.Duplicates:=dupIgnore;

  ScriptControl1.Language := 'VBScript';
  ScriptControl1.UseSafeSubset := False;
  ScriptControl1.AllowUI := true;

  // задержка после которой генерится ошибка - 1 минута
  ScriptControl1.Timeout := 60000;
end;

procedure TScriptFrm.ScriptControl1Error(Sender: TObject);
begin
  Memo1.clear;
  Memo1.text := 'dsc: ' + ScriptControl1.Error.Description;
  Memo1.text := Memo1.text + 'Number: ' + inttostr(ScriptControl1.Error.Number);
  Memo1.text := Memo1.text + 'Line: ' + inttostr(ScriptControl1.Error.Line);
  Memo1.text := Memo1.text + 'HelpContext: ' + inttostr
    (ScriptControl1.Error.HelpContext);
end;

procedure TScriptFrm.ScriptDTChange(Sender: TObject);
begin
  AddScriptItemFrm.minFS:=ScriptDT.FloatNum;
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
  T:double;
  ts:TimeStruct;
begin
  // str:='';
  str := 'Sub Main( )' + #10#13;
  str := str + Memo2.text;
  str := str + #10#13 + 'End Sub';
  ScriptNames.Clear;
  ScriptControl1.AddCode(str);
  try
    // получаем список тегов которые должны быть отредактированы скриптом
    GetChangedScriptNames(str,ScriptNames);
    ts:=GetTimeStruct(ScriptNames);
    T:=ts.minT;
    while T<ts.maxT do
    begin
      SetParam(0,T);
      res := ScriptControl1.Run('Main', pPar);
      T:=T+scriptdt.FloatNum;
    end;
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
    ScriptControl1.AddObject(si.GetName, si, False);
  end;
end;

end.
