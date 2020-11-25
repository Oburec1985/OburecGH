unit uCreateComponents;
// здесь прописываются конструкторы кастомных компонентов

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

  // Тип для хранения информации о plug-in`е
  // Этот тип удобнее использовать в Delphi, чем PLUGININFO
  TInternalPluginInfo = record
    Name: AnsiString; // наименование
    Dsc: AnsiString; // описание
    Vendor: AnsiString; // описание разработчика
    Version: integer; // версия
    SubVertion: integer; // под-версия
  end;

procedure createComponents(compMng: cCompMng);
// Thread окна Recorder. Здесь надо создавать виджеты для формуляров
procedure createFormsRecorderUIThread(compMng: cCompMng);
procedure destroyFormsRecorderUIThread(compMng: cCompMng);
// MainThead. Здесь создавать формы для настройки плагина в режиме стопа
procedure createForms(compMng: cCompMng);
// MainThead
procedure destroyForms(compMng: cCompMng);
function ProcessShowVersionInfo(pMsgInfo: PCB_MESSAGE): boolean;
// удаление объектов движка в потоке создания плагина. Здесь должно удалиться все, что было создано
// и загружено до createFormsRecorderUIThread
procedure destroyEngine;

// отправить плагину MBaseControl нотификацию для редактирования свойств объекта
//  TMBaseNotify = record
//    идентификатор объекта которому надо добавит/ удалшить свойство
//    ObjID: String;
//    тип операции 0 - добавить/изменить свойство 1 - удалить
//    OperType: integer;
//     строка свойств и значение
//     Если добавляем меняем свойство через разделитель ";" идут <имя свойства>,<значение свойства>
//     Если удаляем то через разделитель ";" идут имена свойств
//    Operation: string;
//  end;
procedure sendMDBNotifyMessage(notify: TMBaseNotify);
// получить путь к текущему испытанию
function getMDBTestPath:lpcstr;
function getMDBRegPath:lpcstr;

const
  // Глобальная переменная для храения описания plug-in`а.
  GPluginInfo: TInternalPluginInfo = (Name: 'Plugin Циклограмма';
    Dsc: 'Циклограмма работы регуляторов'; Vendor: 'НПП Мера'; Version: 1;
    SubVertion: 12; );

var
  // флаг для запрета удаления frmSync пока не удалим все формы в потоке формы FrmSync
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
    //LogRecorderMessage('Не удалось получить сервер пользовательского интерфейса.');
  end;
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomFormsRegistrator, FormRegistrator);
  if FAILED(rep) or (FormRegistrator = niL) then
  begin
    //LogRecorderMessage('Не удалось получить интерфейс управления списком зарегистрированных фабрик.');
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
  		// вернуть произвольное свойство tag - id того что хотим получить
      // 0: путь к испытанию 1: путь к регистрации
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
    //LogRecorderMessage('Не удалось получить сервер пользовательского интерфейса.');
  end;
  rep := iunknown(UISrv.pUnkVal).QueryInterface(IID_ICustomFormsRegistrator, FormRegistrator);
  if FAILED(rep) or (FormRegistrator = niL) then
  begin
    //LogRecorderMessage('Не удалось получить интерфейс управления списком зарегистрированных фабрик.');
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
  		// вернуть произвольное свойство tag - id того что хотим получить
      // 0: путь к испытанию 1: путь к регистрации
      //mdb:=(cf as ICustomFactInterface).getChild(int);
      lstr:='привет';
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
  // удаление форм в UIThread
  // ВАЖНО!!! Первое изменение свойств формы имеет право происходить только в UIThread
  // Если произойдет в MainThread (например менять форму при загрузке объектов программы),
  // то будет ошибка при удалении формы Code Error 5 (с HandleAllocated не связано!)

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
  // создание в MainThread
  if GetCurrentThreadId = MainThreadID then
  begin
    // СОЗДАНЫЕ ЗДЕСЬ ФОРМЫ НЕЛЬЗЯ ДЕЛАТЬ SHOWMODAL В UITHREAD
    // необходимо быть осторожным, т.к. создание формы и создание хендлоа разные события
    // если форма первый раз показана не в том же потоке где создана то будут проблеммыс удалением формы
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
  // Управление базой данных
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

  // создание объектов движка
  g_conmng := cControlMng.create;
  uControlsNP.createNP;

  np:=cMBaseAlgNP.create;
  TExtRecorderPack(GPluginInstance).m_nplist.AddNP(np);
end;

procedure destroyEngine;
var
  b:boolean;
begin
// обьявле в начале проекта
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
    'Версия ' + IntToStr(GPluginInfo.Version) + '.' + IntToStr
    (GPluginInfo.SubVertion) + #13#10 + #13#10 + GPluginInfo.Vendor + ', 2017';
  MessageBox(0, PChar(str), 'Информация о модуле',
    MB_OK + MB_ICONINFORMATION + MB_APPLMODAL + MB_TOPMOST);

  result := true;
end;

end.

