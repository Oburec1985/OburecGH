{ --------------------------------------------------------------------- }
{ ������ (������) ���������� plug-in`� ��� �������������� �� Recorder }
{ ������ ������ ��������� plug-in`�, �������� � ���������� }
{ ����������: Rad Studio 2010 }
{ ��� "��� ����" 2016�. }
{ --------------------------------------------------------------------- }

unit PluginClass;

interface

uses
  Windows,
  recorder,
  tags,
  plugin,
  ActiveX,
  SysUtils,
  Forms,
  uFrmSync,
  journal,
  SyncObjs,
  Classes,
  ExtCtrls,
  blaccess,
  ulogfile,
  uCompMng,
  uEventList,
  uRecorderEvents,
  dialogs,
  variants,
  uRCFunc,
  cfreg;

type

  TRCstateChange = (RSt_Init, RSt_StopToView, RSt_StopToRec, RSt_ViewToStop,
    RSt_ViewToRec, RSt_RecToStop, RSt_RecToView, RSt_initToStop,
    RSt_initToView, RSt_initToRec);

  DynTagsArray = array of ITag;

  cNotifyProcessorList = class;

  cNonifyProcessor = class
  protected
    // ������ �� cNotifyProcessorList
    list: cNotifyProcessorList;
    fname: string;
  protected
    procedure setName(s: string);
    // ������� ���������� ��� ���������� cNotifyProcessorList
    procedure doAddParentList; virtual;
    procedure doSave(path: string); virtual;
    procedure doLoad(path: string); virtual;
  public
    function ProcessNotify(a_dwCommand: dword; a_dwData: dword): boolean;
      virtual;
    // function ProcessShowVersionInfo(pMsgInfo:PCB_MESSAGE): boolean;virtual;
    function ProcessBtnClick(pMsgInfo: PCB_MESSAGE): boolean; virtual;
    property name: string read fname write setName;
  end;

  cNotifyProcessorList = class(TStringList)
  public
    function GetNP(i: integer): cNonifyProcessor; overload;
    function GetNP(str: string): cNonifyProcessor; overload;
    Procedure AddNP(np: cNonifyProcessor);
    procedure DelNP(i: integer); overload;
    procedure DelNP(str: string); overload;
    procedure CallAllProcessNotify(a_dwCommand: dword; a_dwData: dword);
    destructor destroy;
    constructor Create;
  end;

  // ������������ ������� ctrl+shift+C
  { ����� ��������� plug-in`�. ��������� ������ TInterfacedObject,
    ��� ���� ����������� ���������� IUnknown � �������� ��������
    ������ �������������. ����� ��������� ��������� IRecorderPlugin -
    ��������� plug-in`�. ��� ����������� ������ ����� ����������
    ����������� �����}
  TExtRecorderPack = class(TInterfacedObject, IRecorderPlugin)
  public
    delplg: boolean;
    rcStateChange: TRCstateChange;
    // �������� ������ ��� ��������� �������� ���������
    // ������� ��� ������� ��������� ������� SwitchOnUI �� �������� ��� �����
    m_loadDefCfg: boolean;
    FIRecorder: IRecorder;
    // ����������� ������ �����������
    m_CompMng: cCompMng;
    // ����� ��� ����������� ������� ���������
    m_FrmSync: TFrmSync;
  protected
    m_rstate: dword;
    m_UIThreadID: integer;

    m_journal: IJournal;

    // ������� ������� �����������
    // m_ExtensionFactory,
    // m_GLFactory:ICustomFormFactory;

    // ������ ���������� �� �������� ��������� �����
    m_BtnTagPropPageID: ULONG;
    // ������ �� ������� ������� ����������
    m_PictBtnMainFramePtr: ipicture; // ��������
    m_btnMainFrameID: ULONG;
    fConfigName: string;
  public
    EList: cEventList;
    m_nplist: cNotifyProcessorList;
  public
    { ����������� }
    constructor Create;
    destructor destroy; override;
    procedure destroyLog;
  public
    function CreateGUI: integer;
    function DestroyGUI: integer;
  protected
    { ���������� }
    function _AddRef: integer; stdcall;
    function _release: integer; stdcall;
    procedure GetJournal;
    // destructor Destroy; override;
  public // IRecorderPlugin
    procedure destroyForms;
    // ������� ������� ShowModal � MainThread
    procedure ShowModalForm(frm: tform);
    function ProcessNotify(a_dwCommand: dword; a_dwData: dword): boolean;
    // �������� �������
    function _Create(pOwner: IRecorder): boolean; stdcall;
    // ����������������
    function Config: boolean; stdcall;
    // ����� ���� ���������
    function Edit: boolean; stdcall;
    // ������ - ����������� ������ plug-in`�
    function Execute: boolean; stdcall;
    // ������������ ������
    function Suspend: boolean; stdcall;
    // ������������� ������
    function Resume: boolean; stdcall;
    // ����������� � ������� ��������
    function Notify(const dwCommand: dword; const dwData: dword): boolean;
      stdcall;
    // ��������� �����
    function GetName: LPCSTR; stdcall;
    // �������� ��������
    function GetProperty(const dwPropertyID: dword;
      var Value: OleVariant): boolean; stdcall;
    // ������ ��������
    function SetProperty(const dwPropertyID: dword;
      Value: OleVariant): boolean; stdcall;
    // ������ ����� �� ��������� ������ �������
    function CanClose: boolean; stdcall;
    // ��������� ������ �������
    function Close: boolean; stdcall;
  private
    function getConfigName: string;
    procedure setConfigName(const Value: string);
    procedure LoadConfName;
    procedure doChangeRCState(Sender: TObject);
  public
    { ����� ������� � �������� ��������� }
    function StartMeasure: boolean;
    function StopMeasure: boolean;
    property ConfigName: string read getConfigName write setConfigName;
  protected
  end;

  // �������� ������ �� ���������� ��������� notifyProcessor
function GetNP(name: string): cNonifyProcessor;
procedure AddPlgEvent(ename: string; etype: cardinal; e: tNotifyEvent);
procedure RemovePlgEvent(e: tNotifyEvent; etype: cardinal);
procedure CallPlgEvents(etype: cardinal); overload;
procedure CallPlgEvents(etype: cardinal; Sender: TObject); overload;
function GetRCStateChange: TRCstateChange;
procedure logMessage(str: string);
procedure LogRecorderMessage(str: string);


var
  { � ���������� ��������� ����� ���� ���������� ��������� plug-in`�,
    � ������������� ���� ���������� ������ �� ��������� ����� plug-in`�.
    ��������� plug-in`� ��������� �� �������� ����������, � ������ ���������,
    ����� ������� ������ ������ ����� ����, ��� ������ ����������� �����
    ��������� ���������� (���� ������� ������ ���������� ���������). }
  GPluginInstance: IRecorderPlugin = nil;
  // ������� Recorder-�
  g_startdir: string;
  // ��������� ����� �������� ���������� ������������
  g_createGUI: boolean = false;
  // ��������� ���� ��������� ������� �������� ���  ������� ���������.
  // �� ���� ��������� ����� ���������������� ������ ����� ���������� �������� ������
  g_LoadEngine: boolean = false;

const
  c_TagProp_nullpoly = 'nullpoly';

implementation

uses
  uCreateComponents;

procedure logMessage(str: string);
begin
  if g_logFile <> nil then
    g_logFile.addInfoMes(str);
end;


function GetNP(name: string): cNonifyProcessor;
begin
  result := TExtRecorderPack(GPluginInstance).m_nplist.GetNP(name);
end;

function GetRCStateChange: TRCstateChange;
begin
  result := TExtRecorderPack(GPluginInstance).rcStateChange;
end;

procedure AddPlgEvent(ename: string; etype: cardinal; e: tNotifyEvent);
begin
  TExtRecorderPack(GPluginInstance).EList.AddEvent(ename, etype, e);
end;

procedure CallPlgEvents(etype: cardinal);
begin
  TExtRecorderPack(GPluginInstance).EList.CallAllEvents(etype);
end;

procedure CallPlgEvents(etype: cardinal; Sender: TObject);
begin
  TExtRecorderPack(GPluginInstance).EList.CallAllEventsWithSender(etype,
    Sender);
end;

procedure RemovePlgEvent(e: tNotifyEvent; etype: cardinal);
begin
  TExtRecorderPack(GPluginInstance).EList.removeEvent(e, etype);
end;

procedure cNonifyProcessor.setName(s: string);
var
  i: integer;
begin
  if list <> nil then
  begin
    if list.Find(fname, i) then
    begin
      list.Delete(i);
    end;
    list.AddObject(s, self);
  end;
  fname := s;
end;

procedure cNonifyProcessor.doAddParentList;
begin

end;

procedure cNonifyProcessor.doLoad(path: string);
begin

end;

procedure cNonifyProcessor.doSave(path: string);
begin

end;

function cNonifyProcessor.ProcessBtnClick(pMsgInfo: PCB_MESSAGE): boolean;
begin

end;

function cNonifyProcessor.ProcessNotify(a_dwCommand: dword;
  a_dwData: dword): boolean;
var
  pMsgInfo: PCB_MESSAGE;
  path: string;
begin
  case a_dwCommand of
    PN_SHOWINFO:
      begin
        pMsgInfo := pointer(a_dwData);
        ProcessShowVersionInfo(pMsgInfo);
      end;
    PN_RCLOADCONFIG:
      begin
        path := getRConfig;
        doLoad(path);
      end;
    PN_RCSAVECONFIG:
      begin
        path := getRConfig;
        doSave(path);
      end;
    PN_CUSTOM_BUTTON_CLICK:
      begin
        if a_dwData = 0 then
        begin

        end
        else
        begin
          pMsgInfo := pointer(a_dwData);
          ProcessBtnClick(pMsgInfo);
        end;
      end;
  end;
end;

function cNotifyProcessorList.GetNP(i: integer): cNonifyProcessor;
begin
  result := NIL;
  if i < count then
    result := cNonifyProcessor(objects[i]);
end;

function cNotifyProcessorList.GetNP(str: string): cNonifyProcessor;
var
  i: integer;
begin
  result := nil;
  if Find(str, i) then
    result := cNonifyProcessor(objects[i]);
end;

procedure cNotifyProcessorList.CallAllProcessNotify(a_dwCommand: dword;
  a_dwData: dword);
var
  i: integer;
  np: cNonifyProcessor;
begin
  for i := 0 to count - 1 do
  begin
    np := GetNP(i);
    np.ProcessNotify(a_dwCommand, a_dwData);
  end;
end;

Procedure cNotifyProcessorList.AddNP(np: cNonifyProcessor);
begin
  np.list := self;
  if np.name = '' then
  begin
    np.name := np.ClassName;
  end;
  AddObject(np.name, np);
  np.doAddParentList;
end;

procedure cNotifyProcessorList.DelNP(i: integer);
var
  np: cNonifyProcessor;
begin
  np := cNonifyProcessor(objects[i]);
  np.destroy;
  Delete(i);
end;

procedure cNotifyProcessorList.DelNP(str: string);
var
  i: integer;
begin
  if Find(str, i) then
    DelNP(i);
end;

destructor cNotifyProcessorList.destroy;
var
  np: cNonifyProcessor;
  i: integer;
begin
  for i := 0 to count - 1 do
  begin
    np := cNonifyProcessor(objects[i]);
    np.destroy;
  end;
  clear;
  inherited;
end;

constructor cNotifyProcessorList.Create;
begin
  sorted := true;
  inherited;
end;

procedure TExtRecorderPack.destroyLog;
begin
  g_logFile.destroy;
  g_logFile := nil;
end;

procedure TExtRecorderPack.doChangeRCState(Sender: TObject);
var
  newstate, statechange: dword;
begin
  newstate := RState;
  case m_rstate of
    RS_STOP:
      begin
        case newstate of
          RS_VIEW:
            rcStateChange := RSt_StopToView;
          RS_REC:
          begin
            g_merafile:=GetMeraFile;
            rcStateChange := RSt_StopToRec;
          end;
        end;
      end;
    RS_VIEW:
      begin
        case newstate of
          RS_VIEW:
            rcStateChange := RSt_ViewToStop;
          RS_REC:
          begin
            rcStateChange := RSt_ViewToRec;
            g_merafile:=GetMeraFile;
          end;
          RS_STOP:
            rcStateChange := RSt_ViewToStop;
        end;
      end;
    RS_REC:
      begin
        case newstate of
          RS_VIEW:
            rcStateChange := RSt_RecToView;
          RS_STOP:
            rcStateChange := RSt_RecToStop;
        end;
      end;
    0:
      begin
        case newstate of
          RS_VIEW:
            rcStateChange := RSt_initToView;
          RS_STOP:
            rcStateChange := RSt_initToStop;
          RS_REC:
          begin
            g_merafile:=GetMeraFile;
            rcStateChange := RSt_initToRec;
          end;
        end;
      end;
  end;
  if newstate <> m_rstate then
  begin
    m_rstate := newstate;
    EList.CallAllEvents(c_RC_DoChangeRCState);
  end;
end;

procedure LogRecorderMessage(str: string);
begin
  // m_journal.AddEvent(pwidechar(str[1]), 0, 1, 0);
  if g_logFile <> nil then
    g_logFile.addInfoMes(str+' Thread: '+IntToStr(GetCurrentThreadId));
end;

{ ����������� } { �������� ����� ��������� plug-in`� }
constructor TExtRecorderPack.Create;
begin
  g_startdir := extractfiledir(Application.ExeName) + '\plugins\';
  EList := cEventList.Create(nil, true);
  m_nplist := cNotifyProcessorList.Create;
end;

destructor TExtRecorderPack.destroy;
begin
  g_startdir := '';
  EList.destroy;
  EList := nil;
  m_nplist.destroy;
  m_nplist := nil;
  FIRecorder := nil;
  inherited;
end;

function TExtRecorderPack.CreateGUI: integer;
var
  // UISrv: tagVARIANT;
  val: OleVariant;
  // f:icustomformFactory;
begin
  LogRecorderMessage('�������� ����������������� ���������� �������...TExtRecorderPack');
  m_UIThreadID:=GetCurrentThreadId;
  LogRecorderMessage('UIThreadID: '+inttostr(m_UIThreadID)+'; MainThreadID:' + inttostr(MainThreadID));

  FIRecorder.GetProperty(RCPROP_CONFIGNAME, val);
  fConfigName := ExtractFileName(val);

  SendMessage(m_FrmSync.Handle, WM_CreateFrms, 0, 0);
  result := 0;
end;

function TExtRecorderPack.ProcessNotify(a_dwCommand: dword;
  a_dwData: dword): boolean;
var
  pMsgInfo: PCB_MESSAGE;
  I: Integer;
begin
  result := false;
  m_nplist.CallAllProcessNotify(a_dwCommand, a_dwData);

  case a_dwCommand of
    PN_RCLOADCONFIG:
      begin
        for I := 0 to m_CompMng.Count - 1 do
        begin
          m_CompMng.doafterload;
        end;
        CallPlgEvents(c_RC_LoadCfg);
      end;
    PN_RCSAVECONFIG:
      begin
        CallPlgEvents(c_RC_SaveCfg);
      end;
    PN_SHOWINFO:
      begin
        pMsgInfo := pointer(a_dwData);
        ProcessShowVersionInfo(pMsgInfo);
      end;
    PN_CUSTOM_BUTTON_CLICK:
      begin
        if a_dwData = 0 then
        begin

        end
        else
        begin
          pMsgInfo := pointer(a_dwData);
          if pMsgInfo.uID = m_btnMainFrameID then
          begin

          end
          else
          begin
            if pMsgInfo.uID = m_BtnTagPropPageID then
              LogRecorderMessage(
                '�� ������� �������� ����������� ������ �������������� ������ ���������.');

          end;
        end;
      end;
  end;
end;

procedure TExtRecorderPack.destroyForms;
begin
{$ifdef DEBUG}
  if m_FrmSync <> nil then
  begin
    if m_FrmSync.createThreadId = GetCurrentThreadId then
    begin
      try
        m_FrmSync.Free;
        m_FrmSync := nil;
      except
        g_logFile.addErrorMes('FrmSync - �� ������� �������');
      end;
    end
    else
    begin
      g_logFile.addErrorMes(
        'FrmSync �������� ��������� � ������ ������ ������ ��� ������');
    end;
  end;
{$endif}
end;

procedure TExtRecorderPack.ShowModalForm(frm: tform);
begin
  PostMessage(m_FrmSync.Handle, WM_ShowModalSettingsFrm, integer(frm), 0);
end;

function TExtRecorderPack.DestroyGUI: integer;
begin
  delplg := true;


  // m_pProcessFormPtr.reset(nil);
  // ������� ������ �� �������
  if m_CompMng.m_BtnMainFrame <> nil then
  begin
    if m_btnMainFrameID <> 0 then
    begin
      m_CompMng.m_BtnMainFrame.RemoveButton(m_btnMainFrameID);
      m_btnMainFrameID := 0;
    end;
  end;
  if m_CompMng.m_BtnTagPropPage <> nil then
  begin
    if m_BtnTagPropPageID <> 0 then
    begin
      m_CompMng.m_BtnTagPropPage.RemoveButton(m_BtnTagPropPageID);
      m_BtnTagPropPageID := 0;
    end;
  end;
  m_CompMng.destroy;
  m_CompMng := nil;

  result := 0;
end;

procedure TExtRecorderPack.GetJournal;
var
  val: OleVariant;
  tV: tagVariant;
  rep: integer;
  str: widestring;
begin
  str := '';
  val := str;
  rep := FIRecorder.GetProperty(RCPROP_USER_LOG, val);
  if not failed(rep) then
  begin
    tV := tagVariant(val);
    rep := iunknown(tV.pUnkVal).QueryInterface(CLSID_Journal, m_journal);
  end;
end;

procedure TExtRecorderPack.LoadConfName;
var
  val: OleVariant;
  Ext: string;
  p: integer;
begin
  fConfigName := ExtractFileName(getConfigName);
  Ext := ExtractFileExt(fConfigName);
  p := Pos(Ext, fConfigName);
  Delete(fConfigName, p, length(fConfigName) - p + 1);
end;

function getConfigName: string;
var
  val: OleVariant;
begin
  TExtRecorderPack(GPluginInstance).FIRecorder.GetProperty(RCPROP_CONFIGNAME,
    val);
  result := val;
end;

// IRecorderPlugin
// �������� (������������� ���������� �����) �������
// ���������� ����������� ����� ����������
function TExtRecorderPack._AddRef: integer;
begin
  inherited;
end;

function TExtRecorderPack._release: integer;
begin
  inherited;
end;


function TExtRecorderPack._Create(pOwner: IRecorder): boolean; stdcall;
var
  cfg: string;
begin
  delplg := false;
  FIRecorder := pOwner; // ���������� ���������� ������ �� ��������� Recorder`�
  GlobInit(GPluginInstance, FIRecorder);

  // GetJournal;
  m_CompMng := cCompMng.Create(FIRecorder);

  m_FrmSync := TFrmSync.Create(nil);
  m_FrmSync.createThreadId := GetCurrentThreadId;
  m_FrmSync.Show;
  m_FrmSync.Close;
  m_FrmSync.HandleNeeded;
  createComponents(m_CompMng);

  // LoadConfName;
  result := true; // ��������� �������

end;


// ����������������
function TExtRecorderPack.Config: boolean; stdcall;
begin
  { ��������� plug-in`� ������ ����������� }
  result := true; // ��������� �������
end;

// ����� ���� ���������
function TExtRecorderPack.Edit: boolean; stdcall;
begin
  // frmTestSettings.Show; {�������� plug-in ����� ����� ���� ����}
  result := true; // ��������� �������
  EList.CallAllEvents(c_RC_PlgEdit);
end;

// ������ - ����������� ������ plug-in`�
function TExtRecorderPack.Execute: boolean; stdcall;
begin
  // frmTestSettings.Show;    // ����������� �����
  result := true; // ��������� �������
end;

function TExtRecorderPack.getConfigName: string;
begin
  result := fConfigName;
end;

// ������������ ������
function TExtRecorderPack.Suspend: boolean; stdcall;
begin
  result := true; // ��������� �������
end;

// ������������� ������
function TExtRecorderPack.Resume: boolean; stdcall;
begin
  result := true; // ��������� �������
end;

procedure TExtRecorderPack.setConfigName(const Value: string);
begin
  fConfigName := Value;
end;

// ����������� � ������� ��������
function TExtRecorderPack.Notify(const dwCommand: dword;
  const dwData: dword): boolean; stdcall;
var
  tags: DynTagsArray;
begin
  result := ProcessNotify(dwCommand, dwData);
  case dwCommand of

    PN_RCLOADCONFIG:
      begin
        m_loadDefCfg := true;
        // LoadConfName;
      end;
    PN_ON_SWITCH_TO_UI_THREAD:
      begin
        result := (CreateGUI = 0);

        createFormsRecorderUIThread(m_CompMng);
        g_createGUI := true;
      end;
    PN_ON_DESTROY_UI_SRV:
      begin
        result := (DestroyGUI = 0);
        destroyFormsRecorderUIThread(m_CompMng);
      end;
    PN_ENTERRCCONFIG:
      begin
        // �������� ������� � ����� ���������
        // � �� ����� ���� ������������ ��������� ���������,
        // ���� ���������� (������, ��� ��� ����� ���������)
        // �������� ���� � ������ ��������� ���������
        // frmTestSettings.BeginConfigure;
        result := true;
      end;
    PN_LEAVERCCONFIG:
      begin
        // ���������� ����� � ���������� ��������� ������������ �
        // �������� �� ����� ������ ������ �� ���������� �����
        // frmTestSettings.EndConfigure(Tags);
        result := true;
        CallPlgEvents(c_RC_LeaveCfg);
      end;
    PN_RCSTOP:
      begin
        // frmTestSettings.Started := false;
        //EList.CallAllEvents(c_RC_ChangeState);
        doChangeRCState(self);
        result := true;
      end;
    PN_RCSTART:
      begin
        // frmTestSettings.Started := true;
        doChangeRCState(self);
        result := true;
      end;
    PN_SYNCHRO_READ_DATA_BLOCK:
      begin
        EList.CallAllEvents(c_RC_SynchroRead);
      end;
    PN_UPDATEDATA:
      begin
        // frmTestSettings.RecorderGotData;
        EList.CallAllEvents(c_RUpdateData);
        result := true;
      end
    else
    begin
      if (m_FrmSync <> nil) then
      begin
        if dwCommand <> PN_RCSAVECONFIG then
        begin
          result := SendMessage(m_FrmSync.Handle, WM_PROCNOTIFY, dwCommand,
            dwData) = 0;
        end;
      end;
    end;
  end;
  result := false; // ������ ��������� �� ������������
end;

// ��������� �����
function TExtRecorderPack.GetName: LPCSTR; stdcall;
begin
  result := LPCSTR(GPluginInfo.Name);
  { �� ���������� ��������� �������� plug-in`� }
end;

// �������� ��������
function TExtRecorderPack.GetProperty(const dwPropertyID: dword;
  var Value: OleVariant): boolean; stdcall;
begin
  case dwPropertyID of
    PLGPROP_INFOSTRING:
      begin { �������� ������ �������� plug-in`� }
        Value := GPluginInfo.Dsc; { �� ���������� ��������� �������� plug-in`� }
        result := true;
      end;
  else
    result := false;
  end;
end;

// ������ ��������
function TExtRecorderPack.SetProperty(const dwPropertyID: dword;
  { const } Value: OleVariant): boolean; stdcall;
begin
  result := false; { ������� ��� � ������������� ������ }
end;

// ������ ����� �� ��������� ������ �������
function TExtRecorderPack.CanClose: boolean; stdcall;
begin
  // ������ ����� ������� plug-in
  result := true;
end;

// ��������� ������ �������
function TExtRecorderPack.Close: boolean; stdcall;
begin
  // TfrmModbusSettings(FSettingsForm).Hide;  //�������� plug-in`� - �������� �����
  // frmTestSettings.Close;
  // FreeAndNil(frmTestSettings);
  destroyEngine;
  result := true;
end;

{ ������ ������� � �������� ��������� }
function TExtRecorderPack.StartMeasure: boolean;
begin
  { ��� ������� ���������� �������� ��������� Recorder`� }
  result := FIRecorder.Notify(RCN_VIEW, 0);
end;

function TExtRecorderPack.StopMeasure: boolean;
begin
  { ��� �������� ���������� �������� ��������� Recorder`� }
  result := FIRecorder.Notify(RCN_STOP, 0);
end;


end.
