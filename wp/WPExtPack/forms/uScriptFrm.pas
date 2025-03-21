unit uScriptFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, ToolWin, ImgList, Menus, Buttons,
  OleCtrls, MSScriptControl_TLB, ActiveX, uWPproc, uBtnListView, comobj,
  uComponentServises, math, DCL_MYOWN, uCommonMath, inifiles, nativexml,
  UWPEvents, Winpos_ole_TLB, POSBase, uBaseObj, VirtualTrees, uVTServices,
  pathUtils, uWPServices;

type

  // � ����� ����������� ���� � ��������� ������ ���������� �������,
  // ���������� � �������� ���� (����������) ���������
  // ������ ���������� - ���� ������� ���������� �������, � ���� �������� ����������� ������
  // ������� �������� ����. ����� ���������� ������� �������� ���� ����������� ����� ������� ����� ������� �� �������
  // �� ��� ��������� �������� � ���������. (�.�. �������� ������� ���������� ������� ���������� ������������ �������
  // �������� ����� � ����� ����������)

  ErrorStruct = record
    // ������ � �������, ����� ������� � �������
    Row, num: integer;
    // �������� ������
    dsc: string;
  end;

  TimeStruct = record
    // ����������� ��� �� ������� ����� �������������� �����
    min_dT,
    // ����������� ����� ����� �������������� �����
    minT,
    // �arc�������� ����� ����� �������������� �����
    maxT: double;
    valid: boolean;
  end;

  TScriptItem = class(TInterfacedObject, idispatch)
  private
    fname: string;
    fOnDestroy:TNotifyEvent;
  public
    m_pitem: pointer; // ������ �� ������
    ffreq: double;
    // ���������� ��� ������������ ������ � ���. �������� ����� ��������� ������ � �����
    LastValueTime: double;
    ScriptChannel: boolean;
    funits: tpoint;
  public
    procedure setvalue(t: double; v: double); virtual;
    function getvalue(t: double): double; virtual;
    function GetScriptName: string;
    function GetName: string;
    procedure SetName(s: string);
  public
    procedure initSignal(p_s: cwpsignal);
    function signal: cwpsignal;
    function GetTypeInfoCount(out Count: integer): integer; stdcall;
    // ������ ��������� �������� ����
    function GetTypeInfo(Index, LocaleID: integer; out TypeInfo): integer;
      stdcall;
    // ����� ������������ ���������� ���� ������� � ������� ������� ������������� � ������������� ��������������
    function GetIDsOfNames(const IID: TGUID; Names: pointer;
      NameCount, LocaleID: integer; DispIDs: pointer): integer; stdcall;
    // ������ ��������� ������� �������
    function Invoke(DispID: integer; // ������������� ����������� ������ ��� ��������, ���������� �� GetIdsOfNames
      const IID: TGUID; // ������������ �������� (��� ��, ��� � � GetIdsOfNames)
      LocaleID: integer; Flags: Word; // ������� �����, ��������� �� ��������� ������
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
      ArgErr: pointer): integer; stdcall;
    // IUnknown
    // ����������������� ����� ��������� ������� ������� ������ ������������� � ����, ���� ������ ��� ��� vbscript ��
    // ��������� ������� ������
  public
    function _Release: integer; stdcall;
  public
    constructor Create;
    procedure doDestroy;
    destructor destroy; override;
  protected
    procedure doDestroyEvent(sender:tobject);
    procedure setfreq(f: double);
    procedure setUnits(u: string);
    function getUnits: string;
    procedure setDsc(u: string);
    function getDsc: string;
  public
    property OnDestroy: TNotifyEvent read fOnDestroy write fOnDestroy;
    property Units: string read getUnits write setUnits;
    property Name: string read GetName write SetName;
    property dsc: string read getDsc write setDsc;
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
    ToolButton1: TToolButton;
    BaseTV: TVTree;
    PathEdit: TEdit;
    PathLabel: TLabel;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
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
    procedure ToolButton1Click(Sender: TObject);
    procedure DelTagBtnClick(Sender: TObject);
    procedure ListViewItemsDblClickProcess(item: TListItem; lv: TListView);
    procedure Button1Click(Sender: TObject);
    procedure PathEditChange(Sender: TObject);
  private
    mng: cWPObjMng;
    fcursrc,
    // ����� � ������������
    resSrc: csrc;
    // ������ tScriptItem-�� �� ��������� ������
    srclist,
    // ������ ���� ����� � ������� ������� �������� ����������
    ScriptNames: tstringlist;
    // ������ ���������� �������
    pPar: psafearray;
    SA: TSafeArrayBound;
    init: boolean;
  private
    // ���������� ������� � VTV
    procedure ShowSRCSignalsinTV;
    procedure ShowTagsNames;
    procedure AddSI(si: TScriptItem);
    procedure AddSItoLV(si: TScriptItem);
    // ������� ���� �������
    procedure InitTags(src: csrc);
    // ��������������� ������� ��� �������� ����� ������� (������� ����� � ������)
    procedure updateScriptNames;
    procedure OnDestroyItem(sender:tobject);
    // ������� ������ �� �������� �����
    procedure ClearTags;
    procedure ClearScriptTags;
    // �������� ������������ ������� ������������� �� ���� �����
    function getMaxFs: double;
    function GetSI(name: string): TScriptItem; overload;
    function GetSI(i: integer): TScriptItem; overload;
    procedure CreateEvents;
    procedure ShowRefCount;
    procedure destroyEvents;
    procedure DoDelSignal(o: TObject);
    procedure DoDelSrc(o: TObject);
    procedure DelSignalFromLV(s: TScriptItem);
  public
    function GetLen: double;
    procedure doAddChannel(Sender: TObject);
  protected
    // ������ � �������� ����������
    procedure SetParam(index: integer; value: variant);
    procedure CreateParams;
    // ������� �������� ������ ����� � ���� ������� � ������� ������� ������
    // ����� �������� �������������� ����� � ������������� ���������
    function GetChangedScriptNames(str: string; list: tstringlist): integer;
    // function CreateTag(str:string; list:tstringlist):integer;
    // �������� ����� ���� ����� � �������
    function GetScriptNames(str: string; list: tstringlist): integer;
    function GetALLNames(list: tstringlist): integer;
    // list ������������ ������ ��� ������ ��������� ����. �� ������ ������ ������� � ������ srcList
    function GetTimeStruct(list: tstringlist): TimeStruct; overload;
    function GetTimeStruct: TimeStruct; overload;
    function GetminDT: double;
    // ������������ ����� � �������� VBScript-�
    // ������� �� ������ ������� ��������� ������� {}
    function GetScriptText(code: string; var err: ErrorStruct): string;
    procedure SaveText(code: string);
    procedure SaveChannels(fname: string);
    procedure LoadChannels(fname: string);
    procedure LoadText; overload;
    procedure LoadText(path: string); overload;

    procedure SetCurSrc(s: csrc);
  public
    property cursrc: csrc read fcursrc write SetCurSrc;
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
  // ������ ������������ � ������
  u_chars =
    '����������������������������������������������������������������()[]{}-+=&#$`\;,.\"*|:<>~/!@�%^?"';
  // \n �� ���������

implementation

uses
  uWpExtPack, uAddScriptItemFrm;
{$R *.dfm}

function StringToDigCodeStr(str: string): string;
var
  ch: char;
  i, index: integer;
begin
  result := '';
  for i := 1 to length(str) do
  begin
    ch := str[i];
    index := pos(ch, u_chars);
    if index > 0 then
    begin
      if result = '' then
      begin
        // ��� ���������� �� ����� ���������� � '_' ������� � �������� ������ ������ ��������� A_A
        result := 'A_A_' + inttostr(index) + '_';
      end
      else
      begin
        result := result + '_' + inttostr(index) + '_';
      end;
    end
    else
    begin
      result := result + ch;
    end;
  end;
end;

function DigCodeStrToString(str: string): string;
var
  ch: char;
  i, startbracketIndex: integer;
  // ������ ������
  bracket, inbracket, newSubNum: boolean;
  substr: string;
begin
  result := '';
  bracket := false;
  newSubNum := false;
  startbracketIndex := 0;
  for i := 1 to length(str) do
  begin
    ch := str[i];
    if bracket = false then
    begin
      // ������ � ������
      if ch = '_' then
      begin
        bracket := true;
        substr := '';
        startbracketIndex := i;
      end;
    end;
    if bracket and (i <> startbracketIndex) then
    begin
      // ������� �� ������
      if ch = '_' then
      begin
        bracket := false;
        newSubNum := true;
      end;
    end;
    // ���� �� � �������
    if not bracket then
    begin
      // ���� ������ ������ ��� �����������
      if newSubNum then
      begin
        result := result + u_chars[strtoint(substr)];
        newSubNum := false;
      end
      else
      begin
        result := result + ch;
      end;
    end
    else
    begin
      if startbracketIndex = i then
      begin

      end
      else
        substr := substr + ch;
    end;
  end;
  if pos('A_A', result) = 1 then
  begin
    result := Copy(result, 4, length(result));
  end;
end;

procedure cScriptSignal.setvalue(t: double; v: double);
var
  i: integer;
begin
  i := s.signal.IndexOf(t);
  s.signal.SetY(i, v);
end;

function cScriptSignal.getvalue(t: double): double;
var
  i: integer;
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
  if (signal <> nil) then
  begin
    result := signal.Name;
  end
  else
    result := fname;
end;

function TScriptItem.GetScriptName: string;
var
  code: string;
begin
  if (m_pitem <> nil) then
  begin
    code := StringToDigCodeStr(cScriptSignal(m_pitem).s.Name);
    // result := '{' + code + '}';
    result := code;
  end
  else
  begin
    code := StringToDigCodeStr(fname);
    // result := '{' + code + '}';
    result := code;
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
function GetScriptName(str: string; start: integer; var index: tpoint): string;
var
  i, deep: integer;
  buf: string;
  findname: boolean;
begin
  findname := false;
  i := start;
  while i < length(str) do
  begin
    // ���� �� ���
    if not findname then
    begin
      // ���� ����� ������ ����� ����
      if str[i] = '{' then
      begin
        index.X := i;
        deep := 0;
        buf := '';
        inc(i);
        findname := true;
        while not((str[i] = '}') and (deep = 0)) do
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
        index.Y := i;
        result := buf;
        exit;
      end;
    end; // ����� �� ������ �����
  end;
end;

procedure TScriptItem.initSignal(p_s: cwpsignal);
begin
  cScriptSignal(m_pitem).s := p_s;
  fname := p_s.Name;
  ffreq := p_s.fs;
end;

function TScriptItem.signal: cwpsignal;
begin
  if m_pitem <> nil then
  begin
    result := cScriptSignal(m_pitem).s;
  end
  else
    result := nil;
end;

function TScriptItem.GetTypeInfoCount(out Count: integer): integer;
begin
  Count := 0;
  result := s_ok;
end;

function TScriptItem.GetTypeInfo(Index, LocaleID: integer;
  out TypeInfo): integer;
begin
  pointer(TypeInfo) := nil;
  result := E_FAIL;
end;

function TScriptItem._Release: integer;
begin
  result := InterlockedDecrement(&FRefCount);
  if (result <= 0) then
  begin
    self.destroy;
  end;
end;

constructor TScriptItem.Create;
begin
  m_pitem := cScriptSignal.Create;
end;

procedure TScriptItem.doDestroy;
begin
  doDestroyEvent(self);
  FRefCount:=0;
  Destroy;
end;

destructor TScriptItem.destroy;
begin
  if m_pitem <> nil then
  begin
    cScriptSignal(m_pitem).s := nil;
    cScriptSignal(m_pitem).destroy;
    m_pitem := nil;
  end;
  inherited;
end;

function TScriptItem.GetIDsOfNames(const IID: TGUID; Names: pointer;
  NameCount, LocaleID: integer; DispIDs: pointer): integer;
var
  name: widestring;
  i, id: integer;
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

procedure TScriptItem.doDestroyEvent(sender:tobject);
begin
  if assigned(fOnDestroy) then
  begin
    fOnDestroy(self);
  end;
end;

procedure TScriptFrm.OnDestroyItem(sender:tobject);
var
  li:tlistitem;
  I: Integer;
begin
  for I := 0 to ListViewItems.items.Count - 1 do
  begin
    li:=ListViewItems.items[i];
    if tscriptitem(li.data)=sender then
    begin
      li.Destroy;
      exit;
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
  if cScriptSignal(m_pitem).s <> nil then
  begin
    result := cScriptSignal(m_pitem).s.signal.NameY;
  end;
end;

procedure TScriptItem.setDsc(u: string);
begin
  cScriptSignal(m_pitem).s.signal.comment := u;
end;

function TScriptItem.getDsc: string;
begin
  result := cScriptSignal(m_pitem).s.signal.comment;
end;

function TScriptItem.Invoke(DispID: integer; const IID: TGUID;
  LocaleID: integer; Flags: Word; var Params;
  VarResult, ExcepInfo, ArgErr: pointer): integer;
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
          VariantChangeType(olevariant(v),
            olevariant(DISPPARAMS(Params).rgvarg[0]), 0, VT_R8);
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
  i, ind: integer;
  s: cwpsignal;
  scriptitem: TScriptItem;
begin
  for i := 0 to src.childCount - 1 do
  begin
    s := src.getSignalObj(i);
    // ������ �� ���������� ���������� �������
    if not srclist.Find(s.name, ind) then
    begin
      scriptitem := TScriptItem.Create;
      scriptitem.OnDestroy:=OnDestroyItem;
      scriptitem.initSignal(s);
      // ��� �� ���������� ADDREF!!!!
      srclist.AddObject(s.Name, scriptitem);
      scriptitem._AddRef;
    end;
  end;
  updateScriptNames;
end;

procedure TScriptFrm.FormDestroy(Sender: TObject);
begin
  destroyEvents;
  srclist.destroy;
  ScriptNames.destroy;
end;

procedure TScriptFrm.FormShow(Sender: TObject);
var
  ts: TimeStruct;
  linit: boolean;
begin
  linit := false;
  // ��������� ������ ����� ������ ��������
  cursrc := mng.GetCurSrcInMainWnd;
  if resSrc = nil then
  begin
    resSrc := mng.addsrc('ScriptResults');
    AddScriptItemFrm.resSrc := resSrc;
    CreateEvents;
  end;
  if cursrc <> nil then
  begin
    InitTags(cursrc);
  end;
  if not init then
  begin
    AddScriptItemFrm.LinkMng(cWPObjMng(mng), resSrc, doAddChannel);
    linit := true;
    init := true;
  end;
  // �������� ������ �� ����� � ����
  GetALLNames(ScriptNames);
  //ts := GetTimeStruct(ScriptNames);
  ts := GetTimeStruct(srclist);
  if ts.valid then
  begin
    ScriptDT.FloatNum := ts.min_dT;
    T1FE.FloatNum := ts.minT;
    T2FE.FloatNum := ts.maxT;
  end;
  if linit then
  begin
    LoadBtnClick(nil);
  end;
  ShowTagsNames;
end;

procedure TScriptFrm.linc(p_mng: TObject);
begin
  mng := cWPObjMng(p_mng);
end;

procedure TScriptFrm.N4Click(Sender: TObject);
begin
  AddScriptItemFrm.ShowModal;
end;

procedure TScriptFrm.PathEditChange(Sender: TObject);
var
  str: string;
begin
  str := RelativePathToAbsolute(startdir, PathEdit.text);
  CheckFolderComponent(PathEdit, str, false);
end;

procedure TScriptFrm.CreateParams;
begin
  SA.cElements := 0;
  pPar := SafeArrayCreate(varVariant, 1, SA);
end;

procedure TScriptFrm.DelTagBtnClick(Sender: TObject);
var
  li: TListItem;
  si: TScriptItem;
  index:integer;
begin
  ScriptControl1.Reset;
  li := ListViewItems.Selected;
  si := TScriptItem(li.data);
  if srclist.Find(si.name, index) then
  begin
    srclist.Delete(index);
  end;
  //si._Release;
  si.doDestroy;
end;

function TScriptFrm.GetALLNames(list: tstringlist): integer;
var
  i, deep: integer;
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
function TScriptFrm.GetScriptNames(str: string; list: tstringlist): integer;
var
  i, deep: integer;
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

function TScriptFrm.GetChangedScriptNames(str: string;
  list: tstringlist): integer;
var
  i, deep: integer;
  buf, lname: string;
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
        while not((str[i] = '}') and (deep = 0)) do
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
          lname := StringToDigCodeStr(buf);
          // ����� ��������� ����� ������
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
  i: integer;
  s: cwpsignal;
  dt: double;
begin
  if cursrc = nil then
    exit;
  if cursrc.childCount = 0 then
    exit;
  s := cursrc.getSignalObj(0);
  dt := 1 / s.fs;
  result := dt;
  for i := 0 to cursrc.childCount - 1 do
  begin
    s := cursrc.getSignalObj(i);
    dt := 1 / s.fs;
    result := Min(dt, result);
  end;
end;

function TScriptFrm.GetTimeStruct: TimeStruct;
begin
  result.min_dT := ScriptDT.FloatNum;
  result.minT := T1FE.FloatNum;
  result.maxT := T2FE.FloatNum;
end;

function TScriptFrm.GetTimeStruct(list: tstringlist): TimeStruct;
var
  i: integer;
  str: string;
  v: double;
  s: TScriptItem;
begin
  if list.Count = 0 then
  begin
    result.valid := false;
    exit;
  end;
  result.valid := true;
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

procedure TScriptFrm.SetParam(index: integer; value: variant);
var
  idx: array [0 .. 0] of integer;
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
  init := false;
  AddScriptItemFrm := TAddScriptItemFrm.Create(nil);
  CreateParams;
  inherited;
end;

function TScriptFrm.getMaxFs: double;
var
  fmax, f: double;
  s: cwpsignal;
  i: integer;
begin
  fmax := 0;
  for i := 0 to cursrc.childCount - 1 do
  begin
    s := cursrc.getSignalObj(i);
    f := 1 / s.signal.DeltaX;
    if fmax < f then
      fmax := f;
  end;
  result := fmax;
end;

function TScriptFrm.GetSI(name: string): TScriptItem;
var
  i: integer;
  si: TScriptItem;
begin
  result := nil;
  if srclist.Find(name, i) then
    result := TScriptItem(srclist.Objects[i]);
end;

function TScriptFrm.GetSI(i: integer): TScriptItem;
begin
  result := TScriptItem(srclist.Objects[i]);
end;

procedure TScriptFrm.CreateEvents;
begin
  mng.Events.AddEvent('TScriptFrm_delSignal', e_onDestroySignal, DoDelSignal);
  mng.Events.AddEvent('TScriptFrm_delSignal', E_OnDestroySrc, DoDelSrc);
end;

procedure TScriptFrm.destroyEvents;
begin
  mng.Events.RemoveEvent(DoDelSignal, e_onDestroySignal);
  mng.Events.RemoveEvent(DoDelSrc, E_OnDestroySrc);
end;

procedure TScriptFrm.DoDelSignal(o: TObject);
var
  s: TScriptItem;
  i: integer;
  li: TListItem;
begin
  // o - cwpsignal
  for i := 0 to srclist.Count - 1 do
  begin
    // TScriptItem(srclist.Objects[i]);
    s := GetSI(i);
    if cScriptSignal(s.m_pitem).s = o then
    begin
      cScriptSignal(s.m_pitem).s := nil;
      cScriptSignal(s.m_pitem).destroy;
      s.m_pitem := nil;
      DelSignalFromLV(s);
      srclist.Delete(i);
      exit;
      // s._Release;
      // li:=ListViewItems.Items[i];
      // li.Destroy;
    end;
  end;
end;

procedure TScriptFrm.DoDelSrc(o: TObject);
begin
  if o = cursrc then
  begin
    cursrc := nil;
  end;
  if o = resSrc then
  begin
    resSrc := nil;
  end;
end;

procedure TScriptFrm.DelSignalFromLV(s: TScriptItem);
var
  li: TListItem;
  i: integer;
begin
  for i := 0 to ListViewItems.Items.Count - 1 do
  begin
    li := ListViewItems.Items[i];
    if li.data = s then
    begin
      li.data := nil;
      li.destroy;
      break;
    end;
  end;
end;

procedure TScriptFrm.AddTagBtnClick(Sender: TObject);
begin
  AddScriptItemFrm.ShowModal;
  ShowTagsNames;
  if AddScriptItemFrm.outSI<>nil then
  begin
    AddScriptItemFrm.outSI.OnDestroy:=OnDestroyItem;
  end;
end;

procedure TScriptFrm.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute(0) then
  begin
    PathEdit.text := OpenDialog1.FileName;
  end;
end;

procedure TScriptFrm.ClearTags;
var
  i: integer;
  s: TScriptItem;
begin
  // for i := 0 to srclist.Count - 1 do
  // begin
  // s := TScriptItem(srclist.Objects[i]);
  // s.Free;
  // end;
  srclist.Clear;
  ScriptControl1.Reset;
  ListViewItems.Clear;
end;

procedure TScriptFrm.ClearScriptTags;
var
  j, i: integer;
  s: TScriptItem;
  li: TListItem;
begin
  i := 0;
  while i < srclist.Count do
  begin
    s := TScriptItem(srclist.Objects[i]);
    if s.ScriptChannel then
    begin
      srclist.Delete(i);
      for j := 0 to ListViewItems.Items.Count - 1 do
      begin
        li := ListViewItems.Items[j];
        if li.data = s then
        begin
          li.destroy;
          break;
        end;
      end;
      continue;
    end;
    inc(i);
  end;
  ScriptControl1.Reset;
end;

procedure TScriptFrm.AddSI(si: TScriptItem);
begin
  srclist.AddObject(si.name, si);
  AddSItoLV(si);
  si._AddRef;
end;

procedure TScriptFrm.doAddChannel(Sender: TObject);
begin
  // RefCount �� ����������� ���� ������
  AddSI(TScriptItem(Sender));
end;

function TScriptFrm.GetLen: double;
begin
  result := T2FE.FloatNum - T1FE.FloatNum;
end;

procedure TScriptFrm.AddSItoLV(si: TScriptItem);
var
  li: TListItem;
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
      ListViewItems.SetSubItemByColumnName('fs',
        floattostr(1 / ScriptDT.FloatNum), li);
      ListViewItems.SetSubItemByColumnName('���', '�����������', li);
    end;
  end;
  ListViewItems.SetSubItemByColumnName('��.', si.Units, li);
end;

procedure TScriptFrm.ShowTagsNames;
var
  i: integer;
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

procedure TScriptFrm.ToolButton1Click(Sender: TObject);
begin
  ScriptControl1.Reset;
  ShowRefCount;
end;

procedure TScriptFrm.SaveBtnClick(Sender: TObject);
begin
  SaveText(RichEdit1.text);
end;

procedure TScriptFrm.SaveText(code: string);
var
  f: tinifile;
  doc: TNativeXml;
  node: txmlnode;
  i: integer;
  dir: string;
begin
  f := tinifile.Create(startdir + 'wpproc.ini');
  f.WriteString('Script', 'ScriptFile', PathEdit.text);
  f.destroy;

  doc := TNativeXml.CreateName('Root');
  doc.XmlFormat := xfReadable;
  node := doc.Root;
  node.WriteAttributeString('Code', code, '');
  dir := RelativePathToAbsolute(startdir, PathEdit.text);
  doc.SaveToFile(dir);
  doc.destroy;
  SaveChannels(dir);
end;

procedure TScriptFrm.ListViewItemsDblClickProcess(item: TListItem;
  lv: TListView);
begin
  RichEdit1.SelText := '{' + TScriptItem(item.data).Name + '}';
end;

procedure TScriptFrm.LoadBtnClick(Sender: TObject);
var
  fname: string;
  f: tinifile;
begin
  // ���� ������� �� ���� � �� �� ����� �� ������
  if sender=nil then
  begin
    f := tinifile.Create(startdir + '\wpproc.ini');
    fname := f.ReadString('Script', 'ScriptFile', 'ScriptFile.xml');
    f.destroy;
    PathEdit.text := fname;
  end;
  fname := RelativePathToAbsolute(startdir, PathEdit.text);
  LoadText(fname);
  LoadChannels(fname);
end;

procedure TScriptFrm.LoadText;
begin
  LoadText(RelativePathToAbsolute(startdir, PathEdit.text));
end;

procedure TScriptFrm.LoadText(path: string);
var
  doc: TNativeXml;
  node: txmlnode;
  str: string;
begin
  doc := TNativeXml.Create(nil);
  doc.LoadFromFile(path);
  node := doc.Root;
  str := node.ReadAttributeString('Code', '');
  RichEdit1.text := str;
  doc.destroy;
  Caption := 'VBScriptFrm: ' + path;
end;

procedure TScriptFrm.SetCurSrc(s: csrc);
begin
  if s <> fcursrc then
  begin
    fcursrc := s;
  end;
end;

procedure TScriptFrm.LoadChannels(fname: string);
var
  doc: TNativeXml;
  node, child: txmlnode;
  i, Count: integer;
  str: string;
  si: TScriptItem;
  isig: iwpsignal;
  sig: cwpsignal;
  f: double;
  Units: tpoint;
begin
  if fileexists(fname) then
  begin
    ClearScriptTags;
    doc := TNativeXml.Create(nil);
    // Doc.XmlFormat := xfReadable;
    doc.LoadFromFile(fname);
    node := doc.Root;
    node := node.NodeByName('Channels');
    if node = nil then
      exit;
    for i := 0 to node.NodeCount - 1 do
    begin
      child := node.Nodes[i];
      str := child.ReadAttributeString('Type', '');
      if str = 'Sensor' then
      begin
        si := TScriptItem.Create;
        si.ondestroy:=ondestroyItem;
        si.ScriptChannel := true;
        isig := wp.CreateSignal(VT_R4) as iwpsignal;
        f := child.ReadAttributeFloat('Freq', 0);
        isig.size := trunc(GetLen * f);
        isig.StartX := T1FE.FloatNum;
        isig.sname := child.ReadAttributeString('Name', ''); ;
        Units := point(child.ReadAttributeInteger('UnitsX', 0),
          child.ReadAttributeInteger('UnitsY', 0));
        si.funits := Units;
        setSignalUnits(isig, Units.X, Units.Y);
        // ��������� ���������� ��� �� ����������� �������
        sig := resSrc.CreateSignal(isig);
        si.initSignal(sig);
        si.freq := f;
        doAddChannel(si);
      end;
    end;
    winpos.Refresh;
  end;
end;

procedure TScriptFrm.SaveChannels(fname: string);
var
  doc: TNativeXml;
  node, child: txmlnode;
  i, Count: integer;
  dir: string;
  si: TScriptItem;
begin
  if fileexists(fname) then
  begin
    doc := TNativeXml.Create(nil);
    doc.XmlFormat := xfReadable;
    doc.LoadFromFile(fname);
    node := doc.Root;
    child := node.NodeByName('Channels');
    if child = nil then
    begin
      child := node.NodeNew('Channels');
    end;
    node := child;
  end
  else
  begin
    doc := TNativeXml.CreateName('Root');
    doc.XmlFormat := xfReadable;
    node := doc.Root;
    node := node.NodeNew('Channels');
  end;
  Count := 0;
  for i := 0 to srclist.Count - 1 do
  begin
    si := GetSI(i);
    if si.ScriptChannel then
    begin
      inc(Count);
      child := node.NodeNew('SI_' + inttostr(Count));
      child.WriteAttributeString('Name', si.name, inttostr(Count));
      child.WriteAttributeString('Type', 'Sensor', '');
      child.WriteAttributeFloat('Freq', si.freq, 0);
      child.WriteAttributeInteger('UnitsY', si.funits.Y, 0);
      child.WriteAttributeInteger('UnitsX', si.funits.X, 0);
    end;
  end;
  node.WriteAttributeInteger('Count', Count);
  doc.SaveToFile(fname);
end;

// ������� �� ������ ������� ��������� ������� {}
function TScriptFrm.GetScriptText(code: string; var err: ErrorStruct): string;
var
  // ������� ������
  Row, deep, i: integer;
  ind: tpoint;
  buf, lcode: string;
  findname: boolean;
begin
  i := 0;
  while i <= length(code) - 1 do
  begin
    inc(i);
    // ������� �������
    if code[i] = char(0) then
    begin
      inc(Row);
      continue;
    end;
    // ������� ������ ���� �� ����
    if code[i] = '{' then
    begin
      // �������� ����� � ���������
      buf := GetScriptName(code, i, ind);
      lcode := StringToDigCodeStr(buf);
      code := ReplaceSubstr(code, '{' + buf + '}', lcode, i);
      // code:=ReplaceSubstr('ABCDEF','CD', 'AA', 2);
      i := i + length(buf) - 1;
    end;
  end;
  result := code;
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
  i: integer;
  si: TScriptItem;
  li: TListItem;
  t: double;
  ts: TimeStruct;
  err: ErrorStruct;
  Count: integer;
begin

  // str:='';
  str := 'Sub Main( )' + #10#13;
  str := str + RichEdit1.text;
  str := str + #10#13 + 'End Sub';
  ScriptNames.Clear;
  try
    // --------------------������� � ��������� ��������� �� �������������-------
    // �������� ������ ����� ������� ������ ���� ��������������� ��������
    Count := GetChangedScriptNames(str, ScriptNames);
    if Count = 0 then
      exit;
    updateScriptNames;
    str := GetScriptText(str, err);
    ScriptControl1.AddCode(str);

    t := T1FE.FloatNum;
    // --------------------������� � ��������� ��������� �� �������������-------
    while t < T2FE.FloatNum do
    begin
      script_time := t;
      SetParam(0, t);
      res := ScriptControl1.Run('Main', pPar);
      t := t + ScriptDT.FloatNum;
    end;
    // res := ScriptControl1.Eval(str);
    // Memo1.text := 'a:' + inttostr(pvar[0]);
    // Memo1.text := Memo1.text + 'b:' + inttostr(pvar[1]);
  finally

  end;
  ShowRefCount;
end;

procedure TScriptFrm.ShowRefCount;
var
  i: integer;
  si: TScriptItem;
  li: TListItem;
begin
  for i := 0 to ListViewItems.Items.Count - 1 do
  begin
    si := GetSI(i);
    li := ListViewItems.Items[i];
    ListViewItems.SetSubItemByColumnName('RefCount', inttostr(si.RefCount), li);
  end;
end;

procedure TScriptFrm.updateScriptNames;
var
  i: integer;
  si: TScriptItem;
  li:tlistitem;
begin
  // ���������� ����������� ������� � ���
  ScriptControl1.Reset;
  for i := 0 to ListViewItems.items.Count - 1 do
  begin
    li:=ListViewItems.items[i];
    //si := TScriptItem(srclist.Objects[i]);
    si := TScriptItem(li.data);
    ScriptControl1.AddObject(si.GetScriptName, si, false);
  end;
end;

procedure TScriptFrm.ShowSRCSignalsinTV;
var
  i: integer;
  s: csrc;
  j: integer;
begin
  for i := 0 to mng.SrcCount - 1 do
  begin
    s := mng.GetSrc(i);
    BaseTV.AddChild(nil);
    for j := 0 to s.childCount - 1 do
    begin

    end;
  end;
end;

procedure ShowBaseObjectInVTreeView(tv: TVTree; obj: cBaseObj;
  Root: pvirtualnode);
var
  i: integer;
  child, world: cBaseObj;
  node: pvirtualnode;
  d: pnodedata;
begin
  if obj.ShowInGraphs then
  begin
    node := tv.AddChild(Root);
    d := tv.GetNodeData(node);
    d.color := tv.normalcolor;
    d.Caption := obj.name;
    d.data := obj;
    d.ImageIndex := obj.ImageIndex;
  end;
  for i := 0 to obj.childCount - 1 do
  begin
    child := cBaseObj(obj.getChild(i));
    if obj.ShowInGraphs then
    begin
      ShowBaseObjectInVTreeView(tv, child, node)
    end
    else
    begin
      ShowBaseObjectInVTreeView(tv, child, Root);
    end;
  end;
end;

end.
