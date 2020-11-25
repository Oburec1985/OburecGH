unit uCreateComponents;
// ����� ������������� ������������ ��������� �����������

interface

uses
  //fastmm4,
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
  iplgmngr,
  recorder,
  plugin,
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
    //LogRecorderMessage('�� ������� �������� ������ ����������������� ����������.');
  end;
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomFormsRegistrator, FormRegistrator);
  if FAILED(rep) or (FormRegistrator = niL) then
  begin
    //LogRecorderMessage('�� ������� �������� ��������� ���������� ������� ������������������ ������.');
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
    //LogRecorderMessage('�� ������� �������� ������ ����������������� ����������.');
  end;
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomFormsRegistrator, FormRegistrator);
  if FAILED(rep) or (FormRegistrator = niL) then
  begin
    //LogRecorderMessage('�� ������� �������� ��������� ���������� ������� ������������������ ������.');
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
begin
  g_delFrms:=false;
  //FullDebugModeScanMemoryPoolBeforeEveryOperation:=true;

  // GetCurrentThreadId;
  ControlCyclogramEditFrm := TControlCyclogramEditFrm.create(nil);
  ControlCyclogramEditFrm.HandleNeeded;
  ControlCyclogramEditFrm.show;
  ControlCyclogramEditFrm.close;
  ControlCyclogramEditFrm.LinkPlg(g_conmng);

  CyclogramReportFrm := TCyclogramReportFrm.create(nil);
  CyclogramReportFrm.HandleNeeded;
  CyclogramReportFrm.show;
  CyclogramReportFrm.close;

  TrigsFrm := TTrigsFrm.create(nil);
  TrigsFrm.HandleNeeded;
  TrigsFrm.show;
  TrigsFrm.close;
  TrigsFrm.LinkPlg(g_conmng);

  ModesTabForm := TModesTabForm.create(nil);
  ModesTabForm.HandleNeeded;
  ModesTabForm.LinkMng(g_conmng);

  DownloadRegsFrm := TDownloadRegsFrm.create(nil);
  DownloadRegsFrm.Show;
  DownloadRegsFrm.close;

  MDBFrm := TMDBFrm.create(nil);
  MDBFrm.Show;
  MDBFrm.close;

  RcClientFrm := TRcClientFrm.create(nil);
  RcClientFrm.Show;
  RcClientFrm.close;


  SpmChartEditFrm:=TSpmChartEditFrm.Create(nil);
  SpmChartEditFrm.Show;
  SpmChartEditFrm.close;

  EditCntlWrnFrm:=TEditCntlWrnFrm.Create(nil);
  EditCntlWrnFrm.Show;
  EditCntlWrnFrm.close;

  EditProfileFrm:=TEditProfileFrm.Create(nil);
  EditProfileFrm.Show;
  EditProfileFrm.close;

  EditPolarFrm:=TEditPolarFrm.Create(nil);
  EditPolarFrm.Show;
  EditPolarFrm.close;

  GenSignalsEditFrm:=tGenSignalsEditFrm.create(nil);
  GenSignalsEditFrm.Show;
  GenSignalsEditFrm.close;


  BandsFrm:=TBandsFrm.Create(nil);
  BandsFrm.Show;
  BandsFrm.close;
  if g_algMng<>nil then
    BandsFrm.LinkBands(g_algMng.m_bands, g_algMng.m_places, g_algMng.m_TagBandPairList);

  if g_algMng<>NIL then
  begin
    AlgFrm:=TAlgFrm.Create(nil);
    AlgFrm.Show;
    AlgFrm.close;

    addAlgFrm:=TAddAlgFrm.Create(nil);
    addAlgFrm.init(g_algMng);
    addAlgFrm.Show;
    addAlgFrm.close;

  end;
end;

procedure destroyFormsRecorderUIThread(compMng: cCompMng);
begin
{$IfDef DEBUG}
  LogRecorderMessage('destroyFormsRecorderUIThread_enter');
  // �������� ���� � UIThread
  // �����!!! ������ ��������� ������� ����� ����� ����� ����������� ������ � UIThread
  // ���� ���������� � MainThread (�������� ������ ����� ��� �������� �������� ���������),
  // �� ����� ������ ��� �������� ����� Code Error 5 (� HandleAllocated �� �������!)

  TExtRecorderPack(GPluginInstance).EList.active := false;

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
  LogRecorderMessage('destroyFormsRecorderUIThread_exit');
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
  LogRecorderMessage('destroyForms_enter');
  if GetCurrentThreadId = MainThreadID then
  begin
    if TagInfoEditFrm<>nil then
    begin
      TagInfoEditFrm.destroy;
      TagInfoEditFrm:=nil;
    end;
  end;
  LogRecorderMessage('destroyForms_exit');
end;

procedure createComponents(compMng: cCompMng);
var
  fact: cControlFactory;
  Basefact: cMBaseFactory;
  cfg:string;

  np:cNonifyProcessor;
begin
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

  g_GenSignalsFactory:=cGenSignalsFactory.create;
  compMng.Add(g_GenSignalsFactory);


  cfg := extractfiledir(getRConfig);
  if DirectoryExists(cfg) then
    g_logFile := cLogFile.Create(cfg+'\' +'ControlCyclogramLog'+ '.log', ';');

  // �������� �������� ������
  g_conmng := cControlMng.create;
  uControlsNP.createNP;

  np:=cMBaseAlgNP.create;
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(np);
end;

procedure destroyEngine;
var
  b:boolean;
begin
// ������� � ������ �������
{$IfDef DEBUG}
  LogRecorderMessage('destroyEngine_enter');
  if g_conmng <> nil then
  begin
    //logRCInfo('c:\RCInfo1.txt');
    g_conmng.clear;
    //logRCInfo('c:\RCInfo3.txt');
    g_conmng.destroy;
    g_conmng := nil;
  end;
  if g_algMng<>nil then
  begin
    g_algMng.destroy;
    g_algMng:=nil;
  end;
  LogRecorderMessage('destroyEngine_exit');
{$EndIf}
end;

function ProcessShowVersionInfo(pMsgInfo: PCB_MESSAGE): boolean;
var
  str: string;
begin
  str := GPluginInfo.Name + #13#10 + #13#10 + GPluginInfo.Dsc + #13#10 +
    '������ ' + IntToStr(GPluginInfo.Version) + '.' + IntToStr
    (GPluginInfo.SubVertion) + #13#10 + #13#10 + GPluginInfo.Vendor + ', 2017';
  MessageBox(0, PChar(str), '���������� � ������',
    MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_TOPMOST);

  result := true;
end;

end.

