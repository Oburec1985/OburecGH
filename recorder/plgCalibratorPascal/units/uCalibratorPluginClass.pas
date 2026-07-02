unit uCalibratorPluginClass;

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
  uEventList,
  uRecorderEvents,
  dialogs,
  variants,
  inifiles,
  uRCFunc,
  uProcNotify,
  cfreg,
  uCalibratorThread,
  Controls;

type
  TRCstateChange = (RSt_Init, RSt_StopToView, RSt_StopToRec, RSt_ViewToStop,
    RSt_ViewToRec, RSt_RecToStop, RSt_RecToView, RSt_initToStop,
    RSt_initToView, RSt_initToRec);

  DynTagsArray = array of ITag;

  TInternalPluginInfo = record
    Name: AnsiString;
    Dsc: AnsiString;
    Vendor: AnsiString;
    Version: integer;
    SubVertion: integer;
  end;

const
  GPluginInfo: TInternalPluginInfo = (
    Name: 'plgCalibratorPascal';
    Dsc: 'Плагин для работы с калибратором давления Elmetra Pascal';
    Vendor: 'Mera';
    Version: 1;
    SubVertion: 0;
  );

type
  TCalPascalPlg = class(TInterfacedObject, IRecorderPlugin)
  public
    m_UIThreadID: integer;
    m_loadState,
    m_leavecfgNotify:boolean;
    delplg: boolean;
    m_loadDefCfg: boolean;
    FIRecorder: IRecorder;
    m_FrmSync: TFrmSync;
    beforestop:boolean;
    m_cfgfile:tinifile;
  protected
    m_rstate: dword;
    m_journal: IJournal;
    fConfigName: string;
    FThread: TCalibratorThread;
  private
    procedure OnPlgEdit(Sender: TObject);
    procedure OnLoadCfg(Sender: TObject);
    procedure OnSaveCfg(Sender: TObject);
    procedure CreateVirtualTags;
  public
    EList: cEventList;
    m_nplist: cNotifyProcessorList;
  public
    constructor Create;
    destructor destroy; override;
    procedure destroyLog;
  public
    function CreateGUI: integer;
    function DestroyGUI: integer;
  protected
    function _AddRef: integer; stdcall;
    function _release: integer; stdcall;
    procedure GetJournal;
    procedure doStart;
  public // IRecorderPlugin
    procedure destroyForms;
    procedure ShowModalForm(frm: tform);
    function ProcessNotify(a_dwCommand: dword; a_dwData: dword): boolean;
    function _Create(pOwner: IRecorder): boolean; stdcall;
    function Config: boolean; stdcall;
    // Настройка плагина
    function Edit: boolean; stdcall;
    function Execute: boolean; stdcall;
    // Останов / возобновление
    function Suspend: boolean; stdcall;
    // Возобновление
    function Resume: boolean; stdcall;
    function Notify(const dwCommand: dword; const dwData: dword): boolean; stdcall;
    function GetName: LPCSTR; stdcall;
    function GetProperty(const dwPropertyID: dword;
      var Value: OleVariant): boolean; stdcall;
    // Запись свойства
    function SetProperty(const dwPropertyID: dword;
      Value: OleVariant): boolean; stdcall;
    function CanClose: boolean; stdcall;
    // Закрытие
    function Close: boolean; stdcall;
  private
    function getConfigName: string;
    procedure setConfigName(const Value: string);
    procedure LoadConfName;
    procedure doChangeRCState(Sender: TObject);
  public
    function StartMeasure: boolean;
    // Останов измерения
    function StopMeasure: boolean;
    property ConfigName: string read getConfigName write setConfigName;
  end;

function RStatePlay: boolean;
// Менеджер событий
function GetNP(name: string): cNonifyProcessor;
// Регистрация события
procedure AddPlgEvent(ename: string; etype: cardinal; e: tNotifyEvent);
// Удаление события
procedure RemovePlgEvent(e: tNotifyEvent; etype: cardinal);
// Вызов событий
procedure CallPlgEvents(etype: cardinal); overload;
// Вызов событий
procedure CallPlgEvents(etype: cardinal; Sender: TObject); overload;
// Изменение состояния
function GetRCStateChange: TRCstateChange;
// Лог
procedure logMessage(str: string);
// Лог в Recorder
procedure LogRecorderMessage(str: string; log:boolean);

var
  GPluginInstance: IRecorderPlugin = nil;
  g_startdir: string;
  g_createGUI,
  g_RcInit: boolean;
  g_LoadEngine: boolean = false;
  rcStateChange: TRCstateChange;

implementation

uses
  uFrmSettings;

function RStatePlay: boolean;
begin
  result := not g_IR.CheckState(RS_stop);
  if TCalPascalPlg(GPluginInstance).beforestop then
    result := false;
end;

procedure logMessage(str: string);
begin
  if g_logFile <> nil then
    g_logFile.addInfoMes(str);
end;

function GetNP(name: string): cNonifyProcessor;
begin
  result := TCalPascalPlg(GPluginInstance).m_nplist.GetNP(name);
end;

function GetRCStateChange: TRCstateChange;
begin
  result := rcStateChange;
end;

procedure AddPlgEvent(ename: string; etype: cardinal; e: tNotifyEvent);
begin
  TCalPascalPlg(GPluginInstance).EList.AddEvent(ename, etype, e);
end;

procedure CallPlgEvents(etype: cardinal);
begin
  TCalPascalPlg(GPluginInstance).EList.CallAllEvents(etype);
end;

procedure CallPlgEvents(etype: cardinal; Sender: TObject);
begin
  TCalPascalPlg(GPluginInstance).EList.CallAllEventsWithSender(etype, Sender);
end;

procedure RemovePlgEvent(e: tNotifyEvent; etype: cardinal);
begin
  TCalPascalPlg(GPluginInstance).EList.removeEvent(e, etype);
end;

procedure TCalPascalPlg.destroyLog;
begin
  if g_logFile <> nil then
  begin
    g_logFile.destroy;
    g_logFile := nil;
  end;
end;

procedure TCalPascalPlg.doChangeRCState(Sender: TObject);
var
  newstate: dword;
begin
  if beforestop then
    newstate := rs_stop
  else
    newstate := RState;

  case m_rstate of
    RS_STOP:
      begin
        case newstate of
          RS_VIEW:
          begin
            rcStateChange := RSt_StopToView;
            doStart;
          end;
          RS_REC:
          begin
            g_merafile := GetMeraFile;
            rcStateChange := RSt_StopToRec;
            doStart;
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
            doStart;
            g_merafile := GetMeraFile;
          end;
          RS_STOP:
            rcStateChange := RSt_ViewToStop;
        end;
      end;
    RS_REC:
      begin
        case newstate of
          RS_VIEW:
          begin
            rcStateChange := RSt_RecToView;
            doStart;
          end;
          RS_STOP:
            rcStateChange := RSt_RecToStop;
        end;
      end;
    0:
      begin
        case newstate of
          RS_VIEW:
          begin
            rcStateChange := RSt_initToView;
            doStart;
          end;
          RS_STOP:
            rcStateChange := RSt_initToStop;
          RS_REC:
          begin
            g_merafile := GetMeraFile;
            rcStateChange := RSt_initToRec;
            doStart;
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

procedure TCalPascalPlg.doStart;
begin
  if FThread = nil then
  begin
    FThread := TCalibratorThread.Create(False);
  end;
end;

procedure LogRecorderMessage(str: string; log: boolean);
begin
  if not log then exit;
  if g_logFile <> nil then
    g_logFile.addInfoMes(str);
end;

function GetSystemDir: string;
begin
  SetLength(Result, 256);
  SetLength(Result, GetSystemDirectory(PChar(Result), 256));
end;

constructor TCalPascalPlg.Create;
begin
  m_loadState := false;
  g_startdir := ExtractFileDrive(GetSystemDir) + '\Mera files\Recorder\plugins\';
  if not DirectoryExists(g_startdir) then
    ForceDirectories(g_startdir);
  EList := cEventList.Create(nil, true);
  m_nplist := cNotifyProcessorList.Create;
  FThread := nil;

  EList.AddEvent('CalibratorPascal_Edit', c_RC_PlgEdit, OnPlgEdit);
  EList.AddEvent('CalibratorPascal_LoadCfg', c_RC_LoadCfg, OnLoadCfg);
  EList.AddEvent('CalibratorPascal_SaveCfg', c_RC_SaveCfg, OnSaveCfg);
end;

destructor TCalPascalPlg.destroy;
begin
  RemovePlgEvent(OnPlgEdit, c_RC_PlgEdit);
  RemovePlgEvent(OnLoadCfg, c_RC_LoadCfg);
  RemovePlgEvent(OnSaveCfg, c_RC_SaveCfg);
  inherited;
end;

function TCalPascalPlg.CreateGUI: integer;
var
  val: OleVariant;
begin
  m_UIThreadID := GetCurrentThreadId;
  FIRecorder.GetProperty(RCPROP_CONFIGNAME, val);
  fConfigName := ExtractFileName(val);
  SendMessage(m_FrmSync.Handle, WM_CreateFrms, 0, 0);
  result := 0;
end;

function TCalPascalPlg.ProcessNotify(a_dwCommand: dword; a_dwData: dword): boolean;
var
  b: boolean;
begin
  result := false;
  b := a_dwCommand = PN_LEAVERCCONFIG;
  if b then
    m_leavecfgNotify := true;

  m_nplist.CallAllProcessNotify(a_dwCommand, a_dwData);
  LogRecorderMessage('Enter_' + TranslateNotifyToStr(a_dwCommand), false);
  
  case a_dwCommand of
    PN_RCLOADCONFIG:
    begin
      m_loadState := true;
      CallPlgEvents(c_RC_LoadCfg);
      m_loadState := false;
    end;
    PN_RCSAVECONFIG:
    begin
      CallPlgEvents(c_RC_SaveCfg);
    end;
  end;

  if b then
    m_leavecfgNotify := false;

  LogRecorderMessage('Exit_' + TranslateNotifyToStr(a_dwCommand), false);
end;

procedure TCalPascalPlg.destroyForms;
begin
  exit;
end;

procedure TCalPascalPlg.ShowModalForm(frm: tform);
begin
  PostMessage(m_FrmSync.Handle, WM_ShowModalSettingsFrm, integer(frm), 0);
end;

function TCalPascalPlg.DestroyGUI: integer;
begin
  if FThread <> nil then
  begin
    FThread.Terminate;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
  result := 0;
end;

procedure TCalPascalPlg.GetJournal;
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

procedure TCalPascalPlg.LoadConfName;
var
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
  TCalPascalPlg(GPluginInstance).FIRecorder.GetProperty(RCPROP_CONFIGNAME, val);
  result := val;
end;

function TCalPascalPlg._AddRef: integer;
begin
  inherited;
end;

function TCalPascalPlg._release: integer;
begin
  inherited;
end;

function TCalPascalPlg._Create(pOwner: IRecorder): boolean; stdcall;
begin
  delplg := false;
  FIRecorder := pOwner;
  GlobInit(self, FIRecorder);

  m_FrmSync := TFrmSync.Create(nil);
  m_FrmSync.FPluginInstance := self;
  m_FrmSync.createThreadId := GetCurrentThreadId;
  m_FrmSync.Show;
  m_FrmSync.Close;
  m_FrmSync.HandleNeeded;

  result := true;
end;

function TCalPascalPlg.Config: boolean; stdcall;
begin
  result := true;
end;

function TCalPascalPlg.Edit: boolean; stdcall;
begin
  result := true;
  EList.CallAllEvents(c_RC_PlgEdit);
end;

function TCalPascalPlg.Execute: boolean; stdcall;
begin
  result := true;
end;

function TCalPascalPlg.getConfigName: string;
begin
  result := fConfigName;
end;

function TCalPascalPlg.Suspend: boolean; stdcall;
begin
  result := true;
end;

function TCalPascalPlg.Resume: boolean; stdcall;
begin
  result := true;
end;

procedure TCalPascalPlg.setConfigName(const Value: string);
begin
  fConfigName := Value;
end;

function TCalPascalPlg.Notify(const dwCommand: dword; const dwData: dword): boolean; stdcall;
begin
  result := ProcessNotify(dwCommand, dwData);
  case dwCommand of
    PN_RCLOADCONFIG:
      begin
        m_loadDefCfg := true;
      end;
    PN_ON_SWITCH_TO_UI_THREAD:
      begin
        result := (CreateGUI = 0);
        g_createGUI := true;
      end;
    PN_ON_DESTROY_UI_SRV:
      begin
         result := (DestroyGUI = 0);
      end;
    PN_ENTERRCCONFIG:
      begin
        result := true;
      end;
    PN_LEAVERCCONFIG:
      begin
        result := true;
        if not m_loadState then
          CallPlgEvents(c_RC_LeaveCfg);
      end;
    PN_RCSTOP:
      begin
        beforestop := false;
        doChangeRCState(self);
        result := true;
      end;
    PN_BEFORE_RCSTOP:
      begin
        beforestop := true;
        doChangeRCState(self);
        result := true;
      end;
    PN_RCSTART:
      begin
        beforestop := false;
        doChangeRCState(self);
        result := true;
      end;
    PN_SYNCHRO_READ_DATA_BLOCK:
      begin
        EList.CallAllEvents(c_RC_SynchroRead);
      end;
    PN_RCINITIALIZED:
    begin
      CreateVirtualTags;
      g_RcInit := true;
      EList.CallAllEvents(E_RC_Init);
    end;
    PN_UPDATEDATA:
      begin
        EList.CallAllEvents(c_RUpdateData);
        result := true;
      end
    else
    begin
      if (m_FrmSync <> nil) then
      begin
        if dwCommand <> PN_RCSAVECONFIG then
        begin
          result := SendMessage(m_FrmSync.Handle, WM_PROCNOTIFY, dwCommand, dwData) = 0;
        end;
      end;
    end;
  end;
  result := false;
end;

function TCalPascalPlg.GetName: LPCSTR; stdcall;
begin
  result := LPCSTR(GPluginInfo.Name);
end;

function TCalPascalPlg.GetProperty(const dwPropertyID: dword; var Value: OleVariant): boolean; stdcall;
begin
  case dwPropertyID of
    PLGPROP_INFOSTRING:
      begin
        Value := GPluginInfo.Dsc;
        result := true;
      end;
  else
    result := false;
  end;
end;

function TCalPascalPlg.SetProperty(const dwPropertyID: dword; Value: OleVariant): boolean; stdcall;
begin
  result := false;
end;

function TCalPascalPlg.CanClose: boolean; stdcall;
begin
  result := true;
end;

function TCalPascalPlg.Close: boolean; stdcall;
begin
  exit;
  result := true;
end;

function TCalPascalPlg.StartMeasure: boolean;
begin
  result := FIRecorder.Notify(RCN_VIEW, 0);
end;

function TCalPascalPlg.StopMeasure: boolean;
begin
  result := FIRecorder.Notify(RCN_STOP, 0);
end;

procedure TCalPascalPlg.OnPlgEdit(Sender: TObject);
var
  lFrm: TFrmSettings;
begin
  lFrm := TFrmSettings.Create(nil);
  try
    if lFrm.ShowModal = mrOk then
    begin
      if FThread <> nil then
      begin
        FThread.Terminate;
        FThread.WaitFor;
        FreeAndNil(FThread);
      end;
      CreateVirtualTags;
      if RStatePlay then
        FThread := TCalibratorThread.Create(False);
    end;
  finally
    lFrm.Free;
  end;
end;

procedure TCalPascalPlg.OnLoadCfg(Sender: TObject);
begin
  if FThread <> nil then
    FThread.LoadConfig;
end;

procedure TCalPascalPlg.OnSaveCfg(Sender: TObject);
begin
end;

procedure TCalPascalPlg.CreateVirtualTags;
var
  lIni: TIniFile;
  lCfgPath: string;
  lInputTagName, lOutputTagName: string;
  lTag: ITag;
  lVal: OleVariant;
  ir: IRecorder;
begin
  lCfgPath := ExtractFileDir(string(getRConfig)) + '\plgCalibratorPascal.ini';
  lIni := TIniFile.Create(lCfgPath);
  try
    lInputTagName := lIni.ReadString('Tags', 'InputTag', 'Pascal_Pressure');
    lOutputTagName := lIni.ReadString('Tags', 'OutputTag', 'Pascal_Range');
  finally
    lIni.Free;
  end;

  ir := getIR;
  if ir = nil then Exit;

  if lInputTagName <> '' then
  begin
    lTag := getTagByName(lInputTagName);
    if lTag = nil then
    begin
      lTag := ITag(ir.CreateTag(LPCSTR(AnsiString(lInputTagName)), LS_VIRTUAL, nil));
      if lTag <> nil then
      begin
        VariantInit(lVal);
        TPropVariant(lVal).vt := VT_UI4;
        lVal := TTAG_SCALAR or TTAG_INPUT;
        lTag.SetProperty(TAGPROP_TYPE, lVal);
        lTag.SetProperty(TAGPROP_ENABLEFREQCORRECTION, false);
        lTag.setfreq(0);
        VariantClear(lVal);
        TPropVariant(lVal).vt := VT_R8;
        lTag.SetProperty(TAGPROP_DATATYPE, lVal);
        lTag.CfgWritable(true);
        VariantClear(lVal);
      end;
    end;
  end;

  if lOutputTagName <> '' then
  begin
    lTag := getTagByName(lOutputTagName);
    if lTag = nil then
    begin
      lTag := ITag(ir.CreateTag(LPCSTR(AnsiString(lOutputTagName)), LS_VIRTUAL, nil));
      if lTag <> nil then
      begin
        VariantInit(lVal);
        TPropVariant(lVal).vt := VT_UI4;
        lVal := TTAG_SCALAR or TTAG_INPUT;
        lTag.SetProperty(TAGPROP_TYPE, lVal);
        lTag.SetProperty(TAGPROP_ENABLEFREQCORRECTION, false);
        lTag.setfreq(0);
        VariantClear(lVal);
        TPropVariant(lVal).vt := VT_R8;
        lTag.SetProperty(TAGPROP_DATATYPE, lVal);
        lTag.CfgWritable(true);
        VariantClear(lVal);
      end;
    end;
  end;
end;

end.