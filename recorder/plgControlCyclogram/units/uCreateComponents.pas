unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  //stmm4,
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
  uGLFrmEdit,
  uMBaseControl;

type

  // ��� ��� �������� ���������� � plug-in`�
  // ���� ��� ������� ������������ � Delphi, ��� PLUGININFO
  TInternalPluginInfo = record
    Name: AnsiString; // ������������
    Dsc: AnsiString; // ��������
    Vendor: AnsiString; // �������� ������������
    Version: integer; // ������
    SubVertion: integer; // ���-������
  end;

procedure createComponents(compMng: cCompMng);
// Thread ���� Recorder. ����� ���� ��������� ������� ��� ����������
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

// ��������� ������� MBaseControl ����������� ��� �������������� ������� �������
//  TMBaseNotify = record
//    ������������� ������� �������� ���� �������/ �������� ��������
//    ObjID: String;
//    ��� �������� 0 - ��������/�������� �������� 1 - �������
//    OperType: integer;
//     ������ ������� � ��������
//     ���� ��������� ������ �������� ����� ����������� ";" ���� <��� ��������>,<�������� ��������>
//     ���� ������� �� ����� ����������� ";" ���� ����� �������
//    Operation: string;
//  end;

procedure sendMDBNotifyMessage(notify: TMBaseNotify);
// �������� ���� � �������� ���������
function getMDBTestPath:lpcstr;
function getMDBRegPath:lpcstr;

const
  // ���������� ���������� ��� ������� �������� plug-in`�.
  GPluginInfo: TInternalPluginInfo = (Name: 'Plugin �����������';
    Dsc: '����������� ������ �����������'; Vendor: '��� ����'; Version: 1;
    SubVertion: 12; );

var
  // ���� ��� ������� �������� frmSync ���� �� ������ ��� ����� � ������ ����� FrmSync
  g_CreateFrms,
  g_delFrms:boolean;

implementation

uses
  PluginClass;

function getMDBTestPath:lpcstr;
var
  rep: hresult;
  val: OleVariant;
  UISrv: tagVARIANT;
  FormRegistrator:ICustomFormsRegistrator;
  f:ICustomFormFactory;
  cf:ICustomFactInterface;

  mdb:IVForm;

  count:cardinal;
  i:ULONG;
  int:integer;
  ws:widestring;
  g:TGUID;
begin
  result:='';
  rep := g_ir.GetProperty(RCPROP_UISERVERLINK, val);
  UISrv := tagVARIANT(val);
  if (FAILED(rep) or (UISrv.VT <> VT_UNKNOWN)) then
  begin
  end;
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomFormsRegistrator, FormRegistrator);
  if FAILED(rep) or (FormRegistrator = niL) then
  begin
  end;
  FormRegistrator.GetFactoriesCount(@count);
  for I := 0 to count - 1 do
  begin
    FormRegistrator.GetFactoryByIndex(f, i);
    f.GetFormTypeName(ws);
    //f._Release;
    if ws=c_MDBFormName then
    begin
      cf:=f as ICustomFactInterface;
      int:=0;
      (cf as ICustomFactInterface).getChild(int, mdb);
      //(cf as ICustomFactInterface).getChild(int, mdb);
  		// ������� ������������ �������� tag - id ���� ��� ����� ��������
      // 0: ���� � ��������� 1: ���� � �����������
      result:=(mdb as ICustomVFormInterface).GetCustomProperty(0);
    end;
  end;
end;

function getMDBRegPath:lpcstr;
var
  rep: hresult;
  val: OleVariant;
  UISrv: tagVARIANT;
  FormRegistrator:ICustomFormsRegistrator;
  f:ICustomFormFactory;
  cf:ICustomFactInterface;

  mdb:IVForm;
  lstr:lpcstr;

  count:cardinal;
  i:ULONG;
  int:integer;
  ws:widestring;
  g:TGUID;
begin
  result:='';
  rep := g_ir.GetProperty(RCPROP_UISERVERLINK, val);
  UISrv := tagVARIANT(val);
  if (FAILED(rep) or (UISrv.VT <> VT_UNKNOWN)) then
  begin
  end;
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomFormsRegistrator, FormRegistrator);
  if FAILED(rep) or (FormRegistrator = niL) then
  begin
  end;
  FormRegistrator.GetFactoriesCount(@count);
  for I := 0 to count - 1 do
  begin
    FormRegistrator.GetFactoryByIndex(f, i);
    f.GetFormTypeName(ws);
    //f._Release;
    if ws=c_MDBFormName then
    begin
      cf:=f as ICustomFactInterface;
      int:=0;
  		// ������� ������������ �������� tag - id ���� ��� ����� ��������
      // 0: ���� � ��������� 1: ���� � �����������
      //mdb:=(cf as ICustomFactInterface).getChild(int);
      lstr:='������';
      (cf as ICustomFactInterface).getChild(int, mdb);
      result:=(mdb as ICustomVFormInterface).GetCustomProperty(1);
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
  str, str1:string;
  show:boolean;
begin
  g_delFrms:=false;
  //FullDebugModeScanMemoryPoolBeforeEveryOperation:=true;
  // GetCurrentThreadId;
  show:=false;
  sleep(1000);
  EditPropertiesFrm:=TEditPropertiesFrm.Create(nil);
  ConfirmFmr:=TConfirmFmr.Create(nil);

  ControlCyclogramEditFrm := TControlCyclogramEditFrm.create(nil);
  ControlCyclogramEditFrm.HandleNeeded;
  if show then
    ControlCyclogramEditFrm.show;
  ControlCyclogramEditFrm.close;
  ControlCyclogramEditFrm.LinkPlg(g_conmng);

  CyclogramReportFrm := TCyclogramReportFrm.create(nil);
  CyclogramReportFrm.HandleNeeded;
  if show then
    CyclogramReportFrm.show;
  CyclogramReportFrm.close;

  TrigsFrm := TTrigsFrm.create(nil);
  TrigsFrm.HandleNeeded;
  if show then
    TrigsFrm.show;
  TrigsFrm.close;
  TrigsFrm.LinkPlg(g_conmng);

  ModesTabForm := TModesTabForm.create(nil);
  ModesTabForm.HandleNeeded;
  ModesTabForm.LinkMng(g_conmng);

  DownloadRegsFrm := TDownloadRegsFrm.create(nil);
  if show then
    DownloadRegsFrm.Show;
  DownloadRegsFrm.close;

  MDBFrm := TMDBFrm.create(nil);
  if show then
    MDBFrm.Show;
  MDBFrm.close;

  RcClientFrm := TRcClientFrm.create(nil);
  if show then
    RcClientFrm.Show;
  RcClientFrm.close;

  SpmChartEditFrm:=TSpmChartEditFrm.Create(nil);
  if show then
    SpmChartEditFrm.Show;
  SpmChartEditFrm.close;

  EditCntlWrnFrm:=TEditCntlWrnFrm.Create(nil);
  if show then
    EditCntlWrnFrm.Show;
  EditCntlWrnFrm.close;

  EditProfileFrm:=TEditProfileFrm.Create(nil);
  if show then
    EditProfileFrm.Show;
  EditProfileFrm.close;

  EditPolarFrm:=TEditPolarFrm.Create(nil);
  if show then
    EditPolarFrm.Show;
  EditPolarFrm.close;

  GenSignalsEditFrm:=tGenSignalsEditFrm.create(nil);
  if show then
    GenSignalsEditFrm.Show;
  GenSignalsEditFrm.close;

  IRDiagrEditFrm:=TIRDiagrEditFrm.Create(nil);
  if show then
    IRDiagrEditFrm.Show;
  IRDiagrEditFrm.close;

  EditSRSFrm:=TEditSRSFrm.Create(nil);
  if show then
    EditSRSFrm.Show;
  EditSRSFrm.close;

  BandsFrm:=TBandsFrm.Create(nil);
  if show then
    BandsFrm.Show;
  BandsFrm.close;
  if g_algMng<>nil then
    BandsFrm.LinkBands(g_algMng.m_bands, g_algMng.m_places, g_algMng.m_TagBandPairList);

  if g_algMng<>nil then
  begin
    g_EditSyncOscFrm:=TEditSyncOscFrm.Create(nil);
    if show then
      g_EditSyncOscFrm.Show;
    g_EditSyncOscFrm.close;
  end;

  if g_algMng<>NIL then
  begin
    AlgFrm:=TAlgFrm.Create(nil);
    if show then
      AlgFrm.Show;
    AlgFrm.close;

    addAlgFrm:=TAddAlgFrm.Create(nil);
    addAlgFrm.init(g_algMng);
    if show then
      addAlgFrm.Show;
    addAlgFrm.close;
    g_SaveAlgsFrm:=TSaveAlgsFrm.Create(nil);
  end;
  g_CreateFrms:=true;
end;

procedure destroyFormsRecorderUIThread(compMng: cCompMng);
begin
  exit;
{$IfDef DEBUG}
  // �������� ���� � UIThread
  // �����!!! ������ ��������� ������� ����� ����� ����� ����������� ������ � UIThread
  // ���� ���������� � MainThread (�������� ������ ����� ��� �������� �������� ���������),
  // �� ����� ������ ��� �������� ����� Code Error 5 (� HandleAllocated �� �������!)

  TExtRecorderPack(GPluginInstance).EList.active := false;

  if ConfirmFmr<>nil then
  begin
    ConfirmFmr.free;
    ConfirmFmr := nil;
  end;

  if EditPropertiesFrm<>nil then
  begin
    EditPropertiesFrm.free;
    EditPropertiesFrm := nil;
  end;

  if IRDiagrEditFrm<>nil then
  begin
    IRDiagrEditFrm.free;
    IRDiagrEditFrm := nil;
  end;

  if ControlCyclogramEditFrm<>nil then
  begin
    ControlCyclogramEditFrm.UnLinkPlg;
    ControlCyclogramEditFrm.free;
    ControlCyclogramEditFrm := nil;
  end;

  if CyclogramReportFrm<>nil then
  begin
    CyclogramReportFrm.free;
    CyclogramReportFrm := nil;
  end;

  if TrigsFrm<>nil then
  begin
    TrigsFrm.free;
    TrigsFrm := nil;
  end;

  if ModesTabForm<>nil then
  begin
    ModesTabForm.free;
    ModesTabForm := nil;
  end;

  if DownloadRegsFrm<>nil then
  begin
    DownloadRegsFrm.destroy;
    DownloadRegsFrm:=nil;

    MDBFrm.destroy;
    MDBFrm:=nil;

    RcClientFrm.destroy;
    RcClientFrm:=nil;
  end;

  if AlgFrm<>nil then
  begin
    AlgFrm.Destroy;
    AlgFrm:=nil;
    addAlgFrm.Destroy;
    addAlgFrm:=nil;
    g_SaveAlgsFrm.Destroy;
    g_SaveAlgsFrm:=nil;
  end;
  if SpmChartEditFrm<>nil then
  begin
    SpmChartEditFrm.Destroy;
    SpmChartEditFrm:=nil;
  end;
  if EditCntlWrnFrm<>nil then
  begin
    EditCntlWrnFrm.Destroy;
    EditCntlWrnFrm:=nil;
  end;

  if EditProfileFrm<>nil then
  begin
    EditProfileFrm.Destroy;
    EditProfileFrm:=nil;
  end;

  if EditPolarFrm<>nil then
  begin
    EditPolarFrm.Destroy;
    EditPolarFrm:=nil;
  end;

  if BandsFrm<>nil then
  begin
    BandsFrm.Destroy;
    BandsFrm:=nil;
  end;

  g_delFrms:=true;
{$EndIf}
end;

procedure createForms(compMng: cCompMng);
begin
  // �������� � MainThread
  if GetCurrentThreadId = MainThreadID then
  begin
    // �������� ����� ����� ������ ������ SHOWMODAL � UITHREAD
    // ���������� ���� ����������, �.�. �������� ����� � �������� ������� ������ �������
    // ���� ����� ������ ��� �������� �� � ��� �� ������ ��� ������� �� ����� ���������� ��������� �����
    TagInfoEditFrm:=TTagInfoEditFrm.Create(nil);
    TagInfoEditFrm.Show;
    TagInfoEditFrm.close;
  end;
end;

procedure destroyForms(compMng: cCompMng);
begin
  exit;
  if GetCurrentThreadId = MainThreadID then
  begin
    if TagInfoEditFrm<>nil then
    begin
      TagInfoEditFrm.destroy;
      TagInfoEditFrm:=nil;
    end;
  end;
end;

procedure createComponents(compMng: cCompMng);
var
  fact: cControlFactory;
  Basefact: cMBaseFactory;
  cfg, dir, fname:string;
  astr:AnsiString;
  np:cNonifyProcessor;
  i:integer;
begin
  g_OscFactory := TOscilFact.create;
  compMng.Add(g_OscFactory);

  fact := cControlFactory.create;
  compMng.Add(fact);
  // ���������� ����� ������
  Basefact := cMBaseFactory.create;
  compMng.Add(Basefact);

  g_SpmFactory := cSpmFactory.create;
  compMng.Add(g_SpmFactory);

  g_CtrlWrnFactory := cCtrlWrnFactory.create;
  compMng.Add(g_CtrlWrnFactory);

  g_CursorFactory := cCursorFactory.create;
  compMng.Add(g_CursorFactory);

  g_PolarFactory:=cPolarFactory.create;
  compMng.Add(g_PolarFactory);

  g_TagInfoFactory:=cTagInfoFactory.create;
  compMng.Add(g_TagInfoFactory);

  g_IRDiagramFactory:=cIRDiagramFactory.create;
  compMng.Add(g_IRDiagramFactory);

  g_SRSFactory:=cSRSFactory.create;
  compMng.Add(g_SRSFactory);


  g_GenSignalsFactory:=cGenSignalsFactory.create;
  compMng.Add(g_GenSignalsFactory);

  g_ObjFrm3dFactory:=cObjFrm3dFactory.create;
  compMng.Add(g_ObjFrm3dFactory);
  g_ObjFrm3dEdit:=TObjFrm3dEdit.Create(nil);


  cfg := extractfiledir(getRConfig);
  i:=0;
  if DirectoryExists(cfg) then
  begin
    dir:=cfg+'\logs\';
    if not DirectoryExists(dir) then
    begin
      ForceDirectories(dir);
    end;
    fname:=dir+'ControlCyclogramLog_'+inttostr(i)+'.log';
    while FileExists(fname) do
    begin
      inc(i);
      fname:=dir+'ControlCyclogramLog_'+inttostr(i)+'.log';
    end;
    g_logFile := cLogFile.Create(fname, ';');
    g_logFile.m_Rewrite:=false;
  end;

  // �������� �������� ������
  g_conmng := cControlMng.create;
  uControlsNP.createNP;

  np:=cMBaseAlgNP.create;
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(np);
end;

procedure destroyEngine;
begin
 if true then exit;
 // ������� � ������ �������
 {$IfDef DEBUG}
  if g_conmng <> nil then
  begin
    g_conmng.clear;
    g_conmng.destroy;
    g_conmng := nil;
  end;
  if g_algMng<>nil then
  begin
    g_algMng.destroy;
    g_algMng:=nil;
  end;
{$EndIf}
end;

function ProcessShowVersionInfo(pMsgInfo: PCB_MESSAGE): boolean;
var
  str: string;
begin
  //str := GPluginInfo.Name + #13#10 + #13#10 + GPluginInfo.Dsc + #13#10 +
  //  '������ ' + IntToStr(GPluginInfo.Version) + '.' + IntToStr
  //  (GPluginInfo.SubVertion) + #13#10 + #13#10 + GPluginInfo.Vendor + ', 2017';
  str := GPluginInfo.Name +char(0) +char(0) + char(0) + GPluginInfo.Dsc + char(0) +
    '������ ' + IntToStr(GPluginInfo.Version) + '.' + IntToStr
    (GPluginInfo.SubVertion) + char(0) + char(0) + GPluginInfo.Vendor + ', 2017';
  MessageBox(0, PChar(str), '���������� � ������', MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_TOPMOST);
  result := true;
end;

end.

