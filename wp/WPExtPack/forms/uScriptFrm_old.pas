unit uScriptFrm_;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, ToolWin, ImgList, Menus, Buttons,
  OleCtrls, MSScriptControl_TLB, ActiveX, uWPproc, uBtnListView, comobj,
  uComponentServises, math, DCL_MYOWN, uCommonMath, inifiles, nativexml;

type
  // � ����� ����������� ���� � ��������� ������ ���������� �������,
  // ���������� � �������� ���� (����������) ���������
  // ������ ���������� - ���� ������� ���������� �������, � ���� �������� ����������� ������
  // ������� �������� ����. ����� ���������� ������� �������� ���� ����������� ����� ������� ����� ������� �� �������
  // �� ��� ��������� �������� � ���������. (�.�. �������� ������� ���������� ������� ���������� ������������ �������
  // �������� ����� � ����� ����������)

  ErrorStruct = record
    // ������ � �������, ����� ������� � �������
    Row, num:integer;
    // �������� ������
    dsc:string;
  end;

  TimeStruct = record
    // ����������� ��� �� ������� ����� �������������� �����
    min_dT,
    // ����������� ����� ����� �������������� �����
    minT,
    // �arc�������� ����� ����� �������������� �����
    maxT: double;
  end;

  TScriptItem = class(TInterfacedObject, idispatch)
  public
    m_pitem: pointer; // ������ �� ������
    fname: string;
    ffreq: double;
    // ���������� ��� ������������ ������ � ���. �������� ����� ��������� ������ � �����
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
    // ������ ��������� �������� ����
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): Integer;
      stdcall;
    // ����� ������������ ���������� ���� ������� � ������� ������� ������������� � ������������� ��������������
    function GetIDsOfNames(const IID: TGUID; Names: pointer;
      NameCount, LocaleID: Integer; DispIDs: pointer): Integer; stdcall;
    // ������ ��������� ������� �������
    function Invoke(DispID: Integer; // ������������� ����������� ������ ��� ��������, ���������� �� GetIdsOfNames
      const IID: TGUID; // ������������ �������� (��� ��, ��� � � GetIdsOfNames)
      LocaleID: Integer; Flags: Word; // ������� �����, ��������� �� ��������� ������
      // �������� �����������
      // DISPATCH_METHOD ���������� �����. ���� � ������� ���� �������� � ����� �� ������, �� ����� ���������� ����� ���� DISPATCH_PROPERTYGET
      // DISPATCH_PROPERTYGET ������������� �������� ��������
      // DISPATCH_PROPERTYPUT ��������������� �������� ��������
      // DISPATCH_PROPERTYPUTREF �������� ���������� �� ������. ���� ���� �� ���������� � �� ��������
      // ��������� DISPPARAMS, ���������� ������ ����������, ������ ��������������� ��� ����������� ����������,
      // � ���������� ��������� � ���� ��������. ��������� ���������� � �������, �������� �� ������� ���������� � �������, ���
      // ������� � Visual Basic
      var Params; VarResult, // ����� ���������� ���� OleVariant, � ������� ������ ���� ������� ��������� ������ ������ ��� �������� �������� ��� NIL, ���� ������������ �������� �� ���������.
      ExcepInfo, // ����� ��������� EXCEPTINFO, ������� ����� ������ ��������� ����������� �� ������, ���� ��� ���������.
      // ����� �������, � ������� ������ ���� �������� ������� �������� ����������, � ������, ���� ����� �������� ����� ����������.
      // ��� ������ Invoke �� �������������� ������� ��������, ������� ��� ��� ��������������� ���������� ���������� ��������� ������������ ��� ������ � ����������� �������� �������� � ����������.
      ArgErr: pointer): Integer; stdcall;
  //IUnknown
  // ����������������� ����� ��������� ������� ������� ������ ������������� � ����, ���� ������ ��� ��� vbscript ��
  // ��������� ������� ������
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
    // ����� � ������������
    resSrc: csrc;
    // ������ tScriptItem-�� �� ��������� ������
    srclist,
    // ������ ���� ����� � ������� ������� �������� ����������
    ScriptNames: tstringlist;
    // ������ ���������� �������
    pPar: psafearray;
    SA: TSafeArrayBound;
  private
    procedure ShowTagsNames;
    procedure AddSI(si: TScriptItem);
    procedure AddSItoLV(si: TScriptItem);
    // ������� ���� �������
    procedure InitTags(src: csrc);
    // ��������������� ������� ��� �������� ����� ������� (������� ����� � ������)
    procedure updateScriptNames;
    // ������� ������ �� �������� �����
    procedure ClearTags;
    // �������� ������������ ������� ������������� �� ���� �����
    function getMaxFs: double;
    function GetSI(name: string): TScriptItem;
  public
    function GetLen: double;
    procedure doAddChannel(Sender: TObject);
  protected
    // ������ � �������� ����������
    procedure SetParam(index: Integer; value: variant);
    procedure CreateParams;
    // ������� �������� ������ ����� � ���� ������� � ������� ������� ������
    function GetChangedScriptNames(str: string; list: tstringlist): Integer;
    // function CreateTag(str:string; list:tstringlist):integer;
    // �������� ����� ���� ����� � �������
    function GetScriptNames(str: string; list: tstringlist): Integer;
    function GetALLNames(list: tstringlist): Integer;
    function GetTimeStruct(list: tstringlist): TimeStruct;overload;
    function GetTimeStruct: TimeStruct;overload;
    function GetminDT: double;
    // ������������ ����� � �������� VBScript-�
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
  //������ ������������ � ������
  u_chars = '����������������������������������������������������������������()[]{}-+=&#$`\;,. _\"\n*|:<>~/!@�%^?"';

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
  // 1 - ������� ������������
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

// ����� ������ ���������� ��� � ������� ������������ ��������� "{}"
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
    // ���� �� ���
    if not findname then
    begin
      // ���� ����� ������ ����� ����
      if str[i] = '{' then
      begin
        index.X:=i;
        deep := 0;
        buf := '';
        inc(i);
        findname := true;
        while not ((str[i] = '}') and (deep=0)) do
        begin
          // ���� ����� ������ ������ ����� ����
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
        end; // WhileEnd ���� ����� ����� �����
        index.Y:=i;
        result:=buf;
        exit;
      end;
    end; // ����� �� ������ �����
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
  // �� ������������ ����������� ���������
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
  // ���� ������ proxy ������ �� ��������� �� � ����, ��...
  if (m_pitem = nil) then
  begin
    result := E_FAIL;
    exit;
  end;
  // ���� ��������� ���������� �������� ��������, ��...
  if ((Flags and DISPATCH_PROPERTYPUT) = DISPATCH_PROPERTYPUT) then
  begin
    // ���� ������� � ��������� ����� ��������, ��...
    if (DISPPARAMS(Params).cArgs <> 0) then
    begin
      // ��������� ��������, �������� � ���
      // ������������� ����� ���� ��������
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
  // ���� ��������� �������� �������� ��������, ��...
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
      // ��������� �������� ��������
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
  // ��������� ������ ����� ������ ��������
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

// ���� ������ ��������� ������� � ���� ���������������
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
    // ���� �� ���
    if not findname then
    begin
      // ���� ����� ������ ����� ����
      if str[i] = '{' then
      begin
        deep := 0;
        buf := '';
        inc(i);
        findname := true;
        while str[i] <> '}' do
        begin
          // ���� ����� ������ ������ ����� ����
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
        end; // WhileEnd ���� ����� ����� �����
      end;
    end; // ����� �� ������ �����
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
    // ���� �� ���
    if not findname then
    begin
      // ���� ����� ������ ����� ����
      if str[i] = '{' then
      begin
        deep := 0;
        buf := '';
        inc(i);
        findname := true;
        while not ((str[i] = '}') and (deep=0)) do
        begin
          // ���� ����� ������ ������ ����� ����
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
        end; // WhileEnd ���� ����� ����� �����
        inc(i);
      end;
    end; // ����� �� ������ �����
    // ���� ���� ����� ��� ������ ���������
    if findname then
    begin
      while findname do
      begin
        while str[i] = ' ' do
        begin
          inc(i);
        end;
        // ��������� �������� ���
        if str[i] = '=' then
        begin
          list.Add(buf);
        end;
        findname := false;
      end;
    end; // ���������� ������ ����� �����
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
      // ���� ���������� ��������� � ����
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
  ListViewItems.SetSubItemByColumnName('���', si.Name, li);
  if si.ScriptChannel then
  begin
    ListViewItems.SetSubItemByColumnName('fs', floattostr(si.freq), li);
    ListViewItems.SetSubItemByColumnName('���', '��������������', li);
  end
  else
  begin
    if si.m_pitem <> nil then
    begin
      ListViewItems.SetSubItemByColumnName('fs', floattostr(si.freq), li);
      ListViewItems.SetSubItemByColumnName('���', '�����', li);
    end
    else
    begin
      ListViewItems.SetSubItemByColumnName
        ('fs', floattostr(1 / ScriptDT.FloatNum), li);
      ListViewItems.SetSubItemByColumnName('���', '�����������', li);
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
  // ������� ������
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
    // ������� �������
    if code[i]=char(0) then
    begin
      inc(row);
      continue;
    end;
    // ������� ������ ���� �� ����
    if code[i]='{' then
    begin
      // �������� ����� � ���������
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

  // �������� ����� ������� ��������� ������ - 5 ������
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
    //--------------------������� � ��������� ��������� �� �������������-------
    // �������� ������ ����� ������� ������ ���� ��������������� ��������
    count:=GetChangedScriptNames(str, ScriptNames);
    if count=0 then exit;
    updateScriptNames;

    t := t + ScriptDT.FloatNum;
    script_time:=t;
    SetParam(0, t);
    res := ScriptControl1.Run('Main', pPar);
    //--------------------������� � ��������� ��������� �� �������������-------
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
  // ���������� ����������� ������� � ���
  ScriptControl1.Reset;
  for i := 0 to srclist.Count - 1 do
  begin
    si := TScriptItem(srclist.Objects[i]);
    ScriptControl1.AddObject(si.GetName, si, true);
  end;
end;

end.
