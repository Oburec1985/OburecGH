unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  // stmm4,
  Windows,
  SysUtils,
  activex,
  cfreg,
  dialogs,
  uCompMng,
  uControlObj,
  uModesTabsForm,
  uControlDeskFrm,
  uMdbFrm,
  uControlCyclogramEditFrm,
  uDownloadRegsFrm,
  uRcClientFrm,
  uControlsNp,
  uTrigsFrm,
  uBaseAlgNP,
  uSpmChart,
  uSpmChartEdit,
  uAlgFrm,
  uAlgAddFrm,
  ubasealg,
  uLogFile,
  uControlWarnFrm,
  uCursorFrm,
  uEditControlWrnFrm,
  uBandsFrm,
  uEditProfileFrm,
  uEditPolarFrm,
  uPolarGraph,
  uTagInfoFrm,
  uTagInfoEditFrm,
  uCyclogramReportFrm,
  uIRDiagram,
  uGenSignalsEditFrm,
  uGenSignalsFrm,
  uRCFunc,
  uRecBasicFactory,
  uSyncOscillogram,
  u3dObj,
  iplgmngr,
  recorder,
  plugin,
  uConfirmDlg,
  uEditPropertiesFrm,
  uAlgsSaveFrm,
  uSyncOscillogramEditFrm,
  uIRDiagramEditFrm,
  uEditSRSFrm,
  uSRSFrm,
  uGLFrmEdit, uEditGlObjFrm,
  TestUDPSender, uThresholdsFrm,
  //uPressFrm, uPressFrmEdit,
  uPressFrm2, uPressFrmEdit2,
  uDigsFrm,uDigsFrmEdit,
  uLissajousCurve,
  ulissajousCurveEdit,
  uMBaseControl;

type

  // ��� ��� �������� ���������� � plug-in`�
  // ���� ��� ������� ������������ � Delphi, ��� PLUGININFO
  TInternalPluginInfo = record
    Name: AnsiString; // ������������
    Dsc: AnsiString; // ��������
    Vendor: AnsiString; // �������� ������������
    wstr:String;
    Version: integer; // ������
    SubVertion: integer; // ���-������
  end;

procedure createComponents(compMng: cCompMng);
// Thread ���� Recorder. ����� ���� ��������� ������� ��� ����������
// ������ ������ ecm!!!!
procedure createFormsRecorderUIThread(compMng: cCompMng);
procedure destroyFormsRecorderUIThread(compMng: cCompMng);
// MainThead. ����� ��������� ����� ��� ��������� ������� � ������ �����
procedure createForms(compMng: cCompMng);
// MainThead
procedure destroyForms(compMng: cCompMng);
function ProcessShowVersionInfo(pMsgInfo: PCB_MESSAGE): boolean;
// �������� �������� ������ � ������ �������� �������. ����� ������ ��������� ���, ��� ���� �������
// � ��������� �� createFormsRecorderUIThread
procedure destroyEngine;
// ����� ��� ������� ���������
procedure RecorderInit;

// ��������� ������� MBaseControl ����������� ��� �������������� ������� �������
// TMBaseNotify = record
// ������������� ������� �������� ���� �������/ �������� ��������
// ObjID: String;
// ��� �������� 0 - ��������/�������� �������� 1 - �������
// OperType: integer;
// ������ ������� � ��������
// ���� ��������� ������ �������� ����� ����������� ";" ���� <��� ��������>,<�������� ��������>
// ���� ������� �� ����� ����������� ";" ���� ����� �������
// Operation: string;
// end;
// ���������� �������� 'curobj'; 'curtest';'curreg'
procedure sendMDBNotifyMessage(notify: TMBaseNotify);
// �������� ���� � �������� ���������
function getMDBTestPath: lpcstr;
function getMDBRegPath: lpcstr;

var
  // ���������� ���������� ��� ������� �������� plug-in`�.
  GPluginInfo: TInternalPluginInfo = (Name: 'Plugin �����������';
    Dsc: '����������� ������ �����������'; Vendor: '��� ����'; Version: 1;
    SubVertion: 12; );

var
  // ���� ��� ������� �������� frmSync ���� �� ������ ��� ����� � ������ ����� FrmSync
  g_CreateFrms, g_delFrms: boolean;

implementation

uses
  PluginClass;

function getMDBTestPath: lpcstr;
var
  rep: hresult;
  val: OleVariant;
  UISrv: tagVARIANT;
  FormRegistrator: ICustomFormsRegistrator;
  f: ICustomFormFactory;
  cf: ICustomFactInterface;

  ifrm: IVForm;

  count: cardinal;
  i: ULONG;
  int: integer;
  ws: widestring;
  g: TGUID;
begin
  result := '';
  rep := g_ir.GetProperty(RCPROP_UISERVERLINK, val);
  UISrv := tagVARIANT(val);
  if (FAILED(rep) or (UISrv.VT <> VT_UNKNOWN)) then
  begin
  end;
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomFormsRegistrator,
    FormRegistrator);
  if FAILED(rep) or (FormRegistrator = niL) then
  begin
  end;
  FormRegistrator.GetFactoriesCount(@count);
  for i := 0 to count - 1 do
  begin
    FormRegistrator.GetFactoryByIndex(f, i);
    f.GetFormTypeName(ws);
    // f._Release;
    if ws = c_MDBFormName then
    begin
      cf := f as ICustomFactInterface;
      int := 0; (cf as ICustomFactInterface).getChild(int, ifrm);
      // (cf as ICustomFactInterface).getChild(int, mdb);
      // ������� ������������ �������� tag - id ���� ��� ����� ��������
      // 0: ���� � ��������� 1: ���� � �����������
      result := (ifrm as ICustomVFormInterface).GetCustomProperty(0);
    end;
  end;
end;

function getMDBRegPath: lpcstr;
var
  rep: hresult;
  val: OleVariant;
  UISrv: tagVARIANT;
  FormRegistrator: ICustomFormsRegistrator;
  f: ICustomFormFactory;
  cf: ICustomFactInterface;

  mdb: IVForm;
  lstr: lpcstr;

  count: cardinal;
  i: ULONG;
  int: integer;
  ws: widestring;
  g: TGUID;
begin
  result := '';
  rep := g_ir.GetProperty(RCPROP_UISERVERLINK, val);
  UISrv := tagVARIANT(val);
  if (FAILED(rep) or (UISrv.VT <> VT_UNKNOWN)) then
  begin
  end;
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomFormsRegistrator,
    FormRegistrator);
  if FAILED(rep) or (FormRegistrator = niL) then
  begin
  end;
  FormRegistrator.GetFactoriesCount(@count);
  for i := 0 to count - 1 do
  begin
    FormRegistrator.GetFactoryByIndex(f, i);
    f.GetFormTypeName(ws);
    // f._Release;
    if ws = c_MDBFormName then
    begin
      cf := f as ICustomFactInterface;
      int := 0;
      // ������� ������������ �������� tag - id ���� ��� ����� ��������
      // 0: ���� � ��������� 1: ���� � �����������
      // mdb:=(cf as ICustomFactInterface).getChild(int);
      lstr := '������'; (cf as ICustomFactInterface)
      .getChild(int, mdb);
      result := (mdb as ICustomVFormInterface).GetCustomProperty(1);
    end;
  end;
end;

procedure sendMDBNotifyMessage(notify: TMBaseNotify);
var
  plgmngr: IPluginsControl;
  i: integer;
  point: pointer;
  p: iRecorderPlugin;
  plgname: lpcstr;
begin
  // g_ir.Notify(v_NotifyMBaseSetProperties, cardinal(@notify));
  g_ir.GetPluginsControlClassObject(plgmngr);
  for i := 0 to plgmngr.GetPluginsCount - 1 do
  begin
    point := plgmngr.GetPlugin(i);
    p := iRecorderPlugin(point);
    plgname := p.Getname;
    if p.Getname = c_MBaseName then
    begin
      p.notify(v_NotifyMBaseSetProperties, cardinal(@(notify)));
      p._Release;
      break;
    end;
  end;
  // plgmngr._Release;
end;

procedure createFormsRecorderUIThread(compMng: cCompMng);
var
  h: thandle;
  str, str1: string;
  show: boolean;
begin
  g_delFrms := false;
  // FullDebugModeScanMemoryPoolBeforeEveryOperation:=true;
  // GetCurrentThreadId;
  show := false;
  sleep(1000);
  EditPropertiesFrm := TEditPropertiesFrm.Create(nil);
  ConfirmFmr := TConfirmFmr.Create(nil);

  EditGLObjFrm := TEditGLObjFrm.Create(nil);
  g_ObjFrm3dEdit := TObjFrm3dEdit.Create(nil);
  if TestUDPSenderFrm=nil then
    TestUDPSenderFrm:=TTestUDPSenderFrm.Create(nil);

  if ThresholdFrm=nil then
  begin
    ThresholdFrm:=tThresholdFrm.Create(nil);
  end;
  if g_conmng<>nil then
  begin
    ControlCyclogramEditFrm := TControlCyclogramEditFrm.Create(nil);
    ControlCyclogramEditFrm.HandleNeeded;
    if show then
      ControlCyclogramEditFrm.show;
    ControlCyclogramEditFrm.close;
    ControlCyclogramEditFrm.LinkPlg(g_conmng);

    CyclogramReportFrm := TCyclogramReportFrm.Create(nil);
    CyclogramReportFrm.HandleNeeded;
    if show then
      CyclogramReportFrm.show;
    CyclogramReportFrm.close;

    TrigsFrm := TTrigsFrm.Create(nil);
    TrigsFrm.HandleNeeded;
    if show then
      TrigsFrm.show;
    TrigsFrm.close;
    TrigsFrm.LinkPlg(g_conmng);

    ModesTabForm := TModesTabForm.Create(nil);
    ModesTabForm.HandleNeeded;
    ModesTabForm.LinkMng(g_conmng);
  end;

  DownloadRegsFrm := TDownloadRegsFrm.Create(nil);
  if show then
    DownloadRegsFrm.show;
  DownloadRegsFrm.close;

    MDBFrm := TMDBFrm.Create(nil);
    if show then
      MDBFrm.show;
    MDBFrm.close;
  if g_MBaseControl<>nil then
  begin
    RcClientFrm := TRcClientFrm.Create(nil);
    if show then
      RcClientFrm.show;
    RcClientFrm.close;
  end;
  if g_algMng<>nil then
  begin
    SpmChartEditFrm := TSpmChartEditFrm.Create(nil);
    if show then
      SpmChartEditFrm.show;
    SpmChartEditFrm.close;

    EditCntlWrnFrm := TEditCntlWrnFrm.Create(nil);
    if show then
      EditCntlWrnFrm.show;
    EditCntlWrnFrm.close;

    EditProfileFrm := TEditProfileFrm.Create(nil);
    if show then
      EditProfileFrm.show;
    EditProfileFrm.close;

    EditPolarFrm := TEditPolarFrm.Create(nil);
    if show then
      EditPolarFrm.show;
    EditPolarFrm.close;

    IRDiagrEditFrm := TIRDiagrEditFrm.Create(nil);
    if show then
      IRDiagrEditFrm.show;
    IRDiagrEditFrm.close;
  end;

  GenSignalsEditFrm := tGenSignalsEditFrm.Create(nil);
  if show then
    GenSignalsEditFrm.show;
  GenSignalsEditFrm.close;

  g_LisEditFrm:=TLisEditFrm.Create(nil);
  if show then
    g_LisEditFrm.show;
  g_LisEditFrm.close;


  EditSRSFrm := TEditSRSFrm.Create(nil);
  if show then
  begin
    EditSRSFrm.show;
    EditSRSFrm.close;
  end;

  BandsFrm := TBandsFrm.Create(nil);
  if show then
    BandsFrm.show;
  BandsFrm.close;
  if g_algMng <> nil then
    BandsFrm.LinkBands(g_algMng.m_bands, g_algMng.m_places,
      g_algMng.m_TagBandPairList);

  if g_algMng <> nil then
  begin
    g_EditSyncOscFrm := TEditSyncOscFrm.Create(nil);
    if show then
      g_EditSyncOscFrm.show;
    g_EditSyncOscFrm.close;
  end;

  if g_algMng <> NIL then
  begin
    AlgFrm := TAlgFrm.Create(nil);
    if show then
      AlgFrm.show;
    AlgFrm.close;

    addAlgFrm := TAddAlgFrm.Create(nil);
    addAlgFrm.init(g_algMng);
    if show then
      addAlgFrm.show;
    addAlgFrm.close;
    g_SaveAlgsFrm := TSaveAlgsFrm.Create(nil);
  end;
  g_CreateFrms := true;
end;

procedure destroyFormsRecorderUIThread(compMng: cCompMng);
begin
{$IFDEF DEBUG}
  // �������� ���� � UIThread
  // �����!!! ������ ��������� ������� ����� ����� ����� ����������� ������ � UIThread
  // ���� ���������� � MainThread (�������� ������ ����� ��� �������� �������� ���������),
  // �� ����� ������ ��� �������� ����� Code Error 5 (� HandleAllocated �� �������!)
  TExtRecorderPack(GPluginInstance).EList.active := false;

  if ConfirmFmr <> nil then
  begin
    ConfirmFmr.free;
    ConfirmFmr := nil;
  end;

  if EditPropertiesFrm <> nil then
  begin
    EditPropertiesFrm.free;
    EditPropertiesFrm := nil;
  end;

  if IRDiagrEditFrm <> nil then
  begin
    IRDiagrEditFrm.free;
    IRDiagrEditFrm := nil;
  end;

  if ThresholdFrm <> nil then
  begin
    ThresholdFrm.free;
    ThresholdFrm := nil;
  end;

  if EditPolarFrm <> nil then
  begin
    EditPolarFrm.destroy;
    EditPolarFrm := nil;
  end;

  if EditGLObjFrm<>nil then
    EditGLObjFrm.destroy;

  if g_ObjFrm3dEdit<>nil then
    g_ObjFrm3dEdit.destroy;

  if TestUDPSenderFrm<>nil then
    TestUDPSenderFrm.destroy;


  if ControlCyclogramEditFrm <> nil then
  begin
    ControlCyclogramEditFrm.UnLinkPlg;
    ControlCyclogramEditFrm.free;
    ControlCyclogramEditFrm := nil;
  end;

  if CyclogramReportFrm <> nil then
  begin
    CyclogramReportFrm.free;
    CyclogramReportFrm := nil;
  end;

  if TrigsFrm <> nil then
  begin
    TrigsFrm.free;
    TrigsFrm := nil;
  end;

  if ModesTabForm <> nil then
  begin
    ModesTabForm.free;
    ModesTabForm := nil;
  end;

  if DownloadRegsFrm <> nil then
  begin
    DownloadRegsFrm.destroy;
    DownloadRegsFrm := nil;
  end;
  if RcClientFrm<>nil then
  begin
    RcClientFrm.destroy;
    RcClientFrm := nil;
  end;

  if MDBFrm<>nil then
  begin
    MDBFrm.destroy;
    MDBFrm := nil;
  end;

  if AlgFrm <> nil then
  begin
    AlgFrm.destroy;
    AlgFrm := nil;
    addAlgFrm.destroy;
    addAlgFrm := nil;
    g_SaveAlgsFrm.destroy;
    g_SaveAlgsFrm := nil;
  end;

  if SpmChartEditFrm <> nil then
  begin
    ////SpmChartEditFrm.destroy;
    SpmChartEditFrm := nil;
  end;

  if EditSrsFrm<> nil then
  begin
    ////EditSrsFrm.destroy;
    EditSrsFrm:= nil;
  end;

  if EditCntlWrnFrm <> nil then
  begin
    EditCntlWrnFrm.destroy;
    EditCntlWrnFrm := nil;
  end;

  if EditProfileFrm <> nil then
  begin
    EditProfileFrm.destroy;
    EditProfileFrm := nil;
  end;

  if BandsFrm <> nil then
  begin
    BandsFrm.destroy;
    BandsFrm := nil;
  end;

  g_delFrms := true;
{$ENDIF}
end;

procedure createForms(compMng: cCompMng);
begin
  // �������� � MainThread
  {if GetCurrentThreadId = MainThreadID then
  begin
    // �������� ����� ����� ������ ������ SHOWMODAL � UITHREAD
    // ���������� ���� ����������, �.�. �������� ����� � �������� ������� ������ �������
    // ���� ����� ������ ��� �������� �� � ��� �� ������ ��� ������� �� ����� ���������� ��������� �����
    TagInfoEditFrm := TTagInfoEditFrm.Create(nil);
    TagInfoEditFrm.show;
    TagInfoEditFrm.close;

    TestUDPSenderFrm:=TTestUDPSenderFrm.Create(nil);
  end;}
end;

procedure destroyForms(compMng: cCompMng);
begin
  if GetCurrentThreadId = MainThreadID then
  begin
    if TagInfoEditFrm <> nil then
    begin
      TagInfoEditFrm.destroy;
      TagInfoEditFrm := nil;
    end;
  end;
end;

procedure createComponents(compMng: cCompMng);
var
  fact: cControlFactory;
  Basefact: cMBaseFactory;
  cfg, dir, fname: string;
  astr: AnsiString;
  np: cNonifyProcessor;
  i: integer;
begin
  g_OscFactory := TOscilFact.Create;
  compMng.Add(g_OscFactory);

  fact := cControlFactory.Create;
  compMng.Add(fact);
  // ���������� ����� ������
  Basefact := cMBaseFactory.Create;
  compMng.Add(Basefact);

  g_PolarFactory := cPolarFactory.Create;
  compMng.Add(g_PolarFactory);

  g_TagInfoFactory := cTagInfoFactory.Create;
  compMng.Add(g_TagInfoFactory);

  g_IRDiagramFactory := cIRDiagramFactory.Create;
  compMng.Add(g_IRDiagramFactory);

  g_LissajousFactory := TLissajousFact.Create;
  compMng.Add(g_LissajousFactory);

  g_SRSFactory := cSRSFactory.Create;
  compMng.Add(g_SRSFactory);

  g_ObjFrm3dFactory := cObjFrm3dFactory.Create;
  compMng.Add(g_ObjFrm3dFactory);
  cfg := extractfiledir(getRConfig);
  i := 0;
  if DirectoryExists(cfg) then
  begin
    dir := cfg + '\logs\';
    if not DirectoryExists(dir) then
    begin
      ForceDirectories(dir);
    end;
    fname := dir + 'ControlCyclogramLog_' + inttostr(i) + '.log';
    while FileExists(fname) do
    begin
      inc(i);
      fname := dir + 'ControlCyclogramLog_' + inttostr(i) + '.log';
    end;
    g_logFile := cLogFile.Create(fname, ';');
    g_logFile.m_Rewrite := false;
  end;

  g_SpmFactory := cSpmFactory.Create;
  compMng.Add(g_SpmFactory);

  g_CtrlWrnFactory := cCtrlWrnFactory.Create;
  compMng.Add(g_CtrlWrnFactory);

  g_CursorFactory := cCursorFactory.Create;
  compMng.Add(g_CursorFactory);

  //g_PressCamFactory := cPressCamFactory.Create;
  //compMng.Add(g_PressCamFactory);
  //PressFrmEdit := TPressFrmEdit.Create(nil);
  g_PressCamFactory2 := cPressCamFactory2.Create;
  compMng.Add(g_PressCamFactory2);
  PressFrmEdit2 := TPressFrmEdit2.Create(nil);

  g_DigsFrmFactory := cDigsFrmFactory.Create;
  compMng.Add(g_DigsFrmFactory);
  DigsFrmEdit:=TDigsFrmEdit.create(nil);

  g_GenSignalsFactory := cGenSignalsFactory.Create;
  compMng.Add(g_GenSignalsFactory);

  // �������� �������� ������
  g_conmng := cControlMng.Create;
  uControlsNp.createNP;
  np := cMBaseAlgNP.Create;
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(np);
end;

procedure RecorderInit;
begin
  if ThresholdFrm<>nil then
    ThresholdFrm.AttachAlarms;
end;

procedure destroyEngine;
begin
  // ������� � ������ �������
{$IFDEF DEBUG}
  if g_conmng <> nil then
  begin
    g_conmng.clear;
    g_conmng.destroy;
    g_conmng := nil;
  end;
  if g_algMng <> nil then
  begin
    g_algMng.destroy;
    g_algMng := nil;
  end;
{$ENDIF}
end;

function ProcessShowVersionInfo(pMsgInfo: PCB_MESSAGE): boolean;
var
  str:string;
begin
  str := GPluginInfo.Name + char(0) + char(0) + char(0) + GPluginInfo.Dsc + char
    (0) + '������ ' + inttostr(GPluginInfo.Version) + '.' + inttostr
    (GPluginInfo.SubVertion)+char(0)+char(0)+ GPluginInfo.Vendor + ', 2017';
  GPluginInfo.wstr:=StrToAnsi(str);
  MessageBox(0, PChar(GPluginInfo.wstr), '���������� � ������', MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_TOPMOST);
  result := true;
end;

end.
