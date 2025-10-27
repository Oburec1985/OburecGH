unit uCreateComponents;
// здесь прописываются конструкторы кастомных компонентов

interface

uses
  // stmm4,
  Windows,
  forms,
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
  uProcNotify,
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
  // uPressFrm, uPressFrmEdit,
  uPressFrm2, uPressFrmEdit2, uSpmThresholdProfile,
  uDigsFrm, uDigsFrmEdit,
  uLissajousCurve,
  ulissajousCurveEdit,
  uDACFrm,
  uMBaseControl;

type

  // Тип для хранения информации о plug-in`е
  // Этот тип удобнее использовать в Delphi, чем PLUGININFO
  TInternalPluginInfo = record
    Name: AnsiString; // наименование
    Dsc: AnsiString; // описание
    Vendor: AnsiString; // описание разработчика
    wstr: String;
    Version: integer; // версия
    SubVertion: integer; // под-версия
  end;

procedure createComponents(compMng: cCompMng);
// Thread окна Recorder. Здесь надо создавать виджеты для формуляров
// Нельзя делать ecm!!!!
procedure createFormsRecorderUIThread(compMng: cCompMng);
procedure destroyFormsRecorderUIThread(compMng: cCompMng);
// MainThead. Здесь создавать формы для настройки плагина в режиме стопа
procedure createForms();
// MainThead
procedure destroyForms();
function ProcessShowVersionInfo(pMsgInfo: PCB_MESSAGE): boolean;
// удаление объектов движка в потоке создания плагина. Здесь должно удалиться все, что было создано
// и загружено до createFormsRecorderUIThread
procedure destroyEngine;
// когда все плагины загружены
procedure RecorderInit;

// отправить плагину MBaseControl нотификацию для редактирования свойств объекта
// TMBaseNotify = record
// идентификатор объекта которому надо добавит/ удалшить свойство
// ObjID: String;
// тип операции 0 - добавить/изменить свойство 1 - удалить
// OperType: integer;
// строка свойств и значение
// Если добавляем меняем свойство через разделитель ";" идут <имя свойства>,<значение свойства>
// Если удаляем то через разделитель ";" идут имена свойств
// Operation: string;
// end;
// допустимые значения 'curobj'; 'curtest';'curreg'
procedure sendMDBNotifyMessage(notify: TMBaseNotify);
// получить путь к текущему испытанию
function getMDBTestPath: lpcstr;
function getMDBRegPath: lpcstr;

var
  GPlgDSC: array [0..255] of ansichar;

  // Глобальная переменная для храения описания plug-in`а.
  GPluginInfo: TInternalPluginInfo = (Name: 'PlgСontrolCyclogram';
    Dsc: 'Циклограмма, БДИ, расчетные каналы'; Vendor: 'НПП Мера'; Version: 1;
    SubVertion: 12; );

var
  // флаг для запрета удаления frmSync пока не удалим все формы в потоке формы FrmSync
  g_CreateFrms, g_delFrms: boolean;

const
  c_MBaseName = 'Plugin Циклограмма';

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
      int := 0; (cf as ICustomFactInterface)
      .getChild(int, ifrm);
      // (cf as ICustomFactInterface).getChild(int, mdb);
      // вернуть произвольное свойство tag - id того что хотим получить
      // 0: путь к испытанию 1: путь к регистрации
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
      // вернуть произвольное свойство tag - id того что хотим получить
      // 0: путь к испытанию 1: путь к регистрации
      // mdb:=(cf as ICustomFactInterface).getChild(int);
      lstr := 'привет'; (cf as ICustomFactInterface)
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
  fr: tForm;
begin
  // exit;
  g_delFrms := false;
  if g_CreateFrms then
    exit;
  show := false;
  EditPropertiesFrm := TEditPropertiesFrm.Create(nil);
  ConfirmFmr := TConfirmFmr.Create(nil);

  EditGLObjFrm := TEditGLObjFrm.Create(nil);
  g_ObjFrm3dEdit := TObjFrm3dEdit.Create(nil);
  if TestUDPSenderFrm = nil then
    TestUDPSenderFrm := TTestUDPSenderFrm.Create(nil);

  TagInfoEditFrm := TTagInfoEditFrm.Create(nil);
  TagInfoEditFrm.show;
  TagInfoEditFrm.close;

  if ThresholdFrm = nil then
  begin
    ThresholdFrm := tThresholdFrm.Create(nil);
  end;
  if g_conmng <> nil then
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

  SpmThresholdProfileFrm := TSpmThresholdProfileFrm.Create(nil);
  SpmThresholdProfileFrm.show;
  SpmThresholdProfileFrm.close;

  DownloadRegsFrm := TDownloadRegsFrm.Create(nil);
  if show then
    DownloadRegsFrm.show;
  DownloadRegsFrm.close;

  MDBFrm := TMDBFrm.Create(nil);
  if show then
    MDBFrm.show;
  MDBFrm.close;
  if g_MBaseControl <> nil then
  begin
    RcClientFrm := TRcClientFrm.Create(nil);
    if show then
      RcClientFrm.show;
    RcClientFrm.close;
  end;
  if g_algMng <> nil then
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

  g_LisEditFrm := TLisEditFrm.Create(nil);
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
  exit;
  // удаление форм в UIThread
  // ВАЖНО!!! Первое изменение свойств формы имеет право происходить только в UIThread
  // Если произойдет в MainThread (например менять форму при загрузке объектов программы),
  // то будет ошибка при удалении формы Code Error 5 (с HandleAllocated не связано!)
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

  if EditGLObjFrm <> nil then
    EditGLObjFrm.destroy;

  if g_ObjFrm3dEdit <> nil then
    g_ObjFrm3dEdit.destroy;

  if TestUDPSenderFrm <> nil then
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
  if RcClientFrm <> nil then
  begin
    RcClientFrm.destroy;
    RcClientFrm := nil;
  end;

  if MDBFrm <> nil then
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
    /// /SpmChartEditFrm.destroy;
    SpmChartEditFrm := nil;
  end;

  if EditSRSFrm <> nil then
  begin
    /// /EditSrsFrm.destroy;
    EditSRSFrm := nil;
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

  if SpmThresholdProfileFrm <> nil then
  begin
    SpmThresholdProfileFrm.destroy;
    SpmThresholdProfileFrm := nil;
  end;

  if BandsFrm <> nil then
  begin
    BandsFrm.destroy;
    BandsFrm := nil;
  end;

  g_delFrms := true;
{$ENDIF}
end;

procedure createForms();
begin
  // создание в MainThread
  { if GetCurrentThreadId = MainThreadID then
    begin
    // СОЗДАНЫЕ ЗДЕСЬ ФОРМЫ НЕЛЬЗЯ ДЕЛАТЬ SHOWMODAL В UITHREAD
    // необходимо быть осторожным, т.к. создание формы и создание хендлоа разные события
    // если форма первый раз показана не в том же потоке где создана то будут проблеммыс удалением формы
    TagInfoEditFrm := TTagInfoEditFrm.Create(nil);
    TagInfoEditFrm.show;
    TagInfoEditFrm.close;

    TestUDPSenderFrm:=TTestUDPSenderFrm.Create(nil);
    end; }
end;

procedure destroyForms();
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
  // Управление базой данных
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

  // создание объектов движка
  g_conmng := cControlMng.Create;
  uControlsNp.createNP;
  np := cMBaseAlgNP.Create;
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(np);

  // g_PressCamFactory := cPressCamFactory.Create;
  // compMng.Add(g_PressCamFactory);
  // PressFrmEdit := TPressFrmEdit.Create(nil);

  g_PressCamFactory2 := cPressCamFactory2.Create;
  compMng.Add(g_PressCamFactory2);
  PressFrmEdit2 := TPressFrmEdit2.Create(nil);

  g_DigsFrmFactory := cDigsFrmFactory.Create;
  compMng.Add(g_DigsFrmFactory);
  DigsFrmEdit := TDigsFrmEdit.Create(nil);

  g_GenSignalsFactory := cGenSignalsFactory.Create;
  compMng.Add(g_GenSignalsFactory);

  DacFrm:=TDACFrm.Create(nil);
  DacFrm.show;
  DacFrm.close;
end;

procedure RecorderInit;
begin
  if g_algMng <> nil then
    g_algMng.doRCinit;
  if ThresholdFrm <> nil then
    ThresholdFrm.AttachAlarms;
end;

procedure destroyEngine;
begin
  // обьявле в начале проекта
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
  str: string;
begin
  str := GPluginInfo.Name + char(0) + char(0) + char(0) + GPluginInfo.Dsc + char
    (0) + 'Версия ' + inttostr(GPluginInfo.Version) + '.' + inttostr
    (GPluginInfo.SubVertion) + char(0) + char(0)
    + GPluginInfo.Vendor + ', 2017';
  GPluginInfo.wstr := StrToAnsi(str);
  MessageBox(0, PChar(GPluginInfo.wstr), 'Информация о модуле',
    MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_TOPMOST);
  result := true;
end;

end.
