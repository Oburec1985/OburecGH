unit uMBaseControl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  inifiles, uCommonMath, uStringGridExt,
  Dialogs, StdCtrls, ExtCtrls, Grids, ComCtrls,
  uBtnListView, uRecBasicFactory, pluginclass, uRecorderEvents,
  uComponentServises,
  uRCFunc, recorder, PathUtils, uDownloadregsfrm, urcclientfrm,
  iplgmngr,
  uMeasureBase, uMdbFrm, DB, DBClient, uRcClient, Sockets, ImgList, Buttons,
  plugin, Menus, ScktComp, ShlObj, uPathMng;

type


  TMBaseControl = class(TRecFrm)
    ActionPanel: TPanel;
    Splitter1: TSplitter;
    BaseFolderEdit: TEdit;
    Label3: TLabel;
    Button1: TButton;
    mdbBtn: TButton;
    TcpClient1: TTcpClient;
    ImageList1: TImageList;
    Timer1: TTimer;
    ViewBtnGl: TSpeedButton;
    RecordBtnGl: TSpeedButton;
    StopBtnGl: TSpeedButton;
    DownloadRegsBtn: TSpeedButton;
    MainMenu1: TMainMenu;
    PropertiesMenu: TMenuItem;
    MdbPathBtn: TButton;
    OpenDialog1: TOpenDialog;
    OpenDialog1vista: TFileOpenDialog;
    CfgSB: TSpeedButton;
    PathLabel: TLabel;
    TestPathLabel: TLabel;
    Panel1: TPanel;
    ObjGB: TGroupBox;
    ObjPanel: TPanel;
    ObjNameLabel: TLabel;
    Label4: TLabel;
    ObjRenameBtn: TButton;
    ObjNameCB: TComboBox;
    ObjTypeCB: TComboBox;
    TestGB: TGroupBox;
    TestPanel: TPanel;
    TestTypeLabel: TLabel;
    Label2: TLabel;
    TestTypeCB: TComboBox;
    TestDateNameCB: TCheckBox;
    TestNameCB: TComboBox;
    RegGB: TGroupBox;
    RegPanel: TPanel;
    Label1: TLabel;
    Splitter7: TSplitter;
    RegistratorsLV: TBtnListView;
    AlarmCB: TCheckBox;
    AlarmPanel: TPanel;
    AlarmDscLabel: TLabel;
    AlarmTypeLabel: TLabel;
    AlarmDsc: TEdit;
    AlarmType: TComboBox;
    RegNameEdit: TComboBox;
    Panel2: TPanel;
    ObjPropSG: TStringGridExt;
    Panel3: TPanel;
    SelObjName: TEdit;
    Label5: TLabel;
    ApplyBtn: TButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label6: TLabel;
    Label7: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure mdbBtnClick(Sender: TObject);
    procedure ObjPropSGEndEdititng(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure ViewBtnClick(Sender: TObject);
    procedure RecordBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DownloadRegsBtnClick(Sender: TObject);
    procedure ObjPropSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ObjNameCBChange(Sender: TObject);
    procedure ObjRenameBtnClick(Sender: TObject);
    procedure RegistratorsLVDblClickProcess(item: TListItem; lv: TListView);
    procedure AlarmCBClick(Sender: TObject);
    procedure TestTypeCBChange(Sender: TObject);
    procedure TestNameCBChange(Sender: TObject);
    procedure RegNameEditChange(Sender: TObject);
    procedure Splitter4Moved(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure MdbPathBtnClick(Sender: TObject);
    procedure CfgSBClick(Sender: TObject);
    procedure ObjPropSGExit(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure ObjNameCBDblClick(Sender: TObject);
    procedure ObjPropSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure TestTypeCBCloseUp(Sender: TObject);
    procedure ObjPropSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private

    m_rstate: dword;
    // форма посчитана фабрикой класса. Нужно для ограничения числа форм
    m_counted: Boolean;
    finit: Boolean;
    fLoaded: Boolean;
    m_base: cMBase;
    // текущая регистрация
    m_reg: cregFolder;
    rc_pan: cRegController;

    selectObj, curObj, curTest, curReg: cXmlFolder;
    selectPropRow, selectPropCol:integer;
    selectProp:string;
  public
    fOnStopRec, fSaveCfg: tnotifyevent;
  protected
    procedure doStopRec(Sender: TObject);
    procedure doAddPropertie(Sender: TObject);
    procedure synchroniseSplitters(Sender: TObject);
    procedure setcurObj(o: cObjFolder);
    procedure setcurTest(t: cTestFolder);
    procedure setcurReg(r: cregFolder);
    // формирует путь к регистрации на основании текущего каталога и настроек формы
    function  createRegName(basepath: string; t: cTestFolder): string;
    procedure CreateEvents;
    procedure DestroyEvents;
    function  EmptyReg: cregFolder;
    procedure doSaveCfg(Sender: TObject);
    procedure doChangeRCState(Sender: TObject);
    procedure doCreateConnection(Sender: TObject);
    procedure doDeleteRConnection(Sender: TObject);
    procedure showRegistrators;
    // происходит при обновленнии данных
    procedure doUpdateData(Sender: TObject);
    procedure doOnRead(connection: TRConnection; msg: tmsgHeader);
    function createReg:cregfolder;
    // создание описателей в базе с ссылками на записи регистраторов
    procedure createSubRegs;
    procedure settestsettings(t: cTestFolder);
    // заполнить список доступных для выбора объектов
    procedure FillObjectsCB;
    procedure FillTestsCB(o: cObjFolder);
    procedure FillRegCB(t: cTestFolder);
    procedure UpdateXmlDescr;
    procedure doChangePathNotify(objtype:DWORD);
    // кеопируем свойства из SG в O
    procedure SaveProperties(o:cXmlFolder);
  public
    procedure ShowObjProps(o:cXmlFolder);

    function GetSelectObj: cObjFolder;
    function GetSelectTest: cTestFolder;
    function GetSelectReg: cregFolder;

    procedure DoGetNotify(data: dword);
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor Create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  IMBaseControl = class(cRecBasicIFrm)
  protected
    // путь к испытанию 0; путь к регистрации 1
    function doGetProperty(tag: Integer): LPCSTR; override;
  public
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cMBaseFactory = class(cRecBasicFactory)
  private
    m_counter: Integer;
  protected
    procedure AddEvents;
    procedure doDestroyForms; override;
    procedure doUpdateTags(Sender: TObject);
    procedure doStatusNONE(Sender: TObject);
  public
    procedure decFrmCounter;
    procedure incFrmCounter;
    constructor Create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

var
  // VSN_USER = 28672
  v_NotifyMBaseSetProperties: Integer = VSN_USER + 101;
  v_NotifyMBaseChangePath: Integer = VSN_USER + 102;

  // Загрузка и запуск плагина
  g_MBaseControl: TMBaseControl;
function mBaseControl: TMBaseControl;
// uCreateCompoment
//function getMDBTestPath:lpcstr;
//function getMDBRegPath:lpcstr;

const
  c_Pic = 'MBASECONTROL';
  c_MDBFormName = 'Управление базой данных';

const
  c_changeObj = 0;
  c_changeTest = 1;
  c_changeReg = 3;

  c_Control_defXSize = 509;
  c_Control_defYSize = 641;
  // ctrl+shift+G
  // ['{78AE7E7B-774B-46CF-8A49-33D352684760}']
  IID_MBaseFactory: TGuid = (D1: $78AE7E7B; D2: $774B; D3: $46CF;
    D4: ($8A, $49, $33, $D3, $52, $68, $47, $60));

  c_img_view = 2;
  c_img_rec = 3;
  c_img_stop = 4;
  c_col_propName = 0;
  c_col_propVal = 1;
  c_col_regname = 'Регистратор';
  c_col_folder = 'Подкаталог';

  // путь к каталогу регистрации
  c_CustProp_Path = 0;
  // путь "объект;тест;регистрация"
  c_CustProp_Obj = 1;

procedure InitPropSG(sg: tstringgrid);

implementation

uses
  uControlsNP, uCreateComponents;
{$R *.dfm}
{ IMBaseControl }

function mBaseControl: TMBaseControl;
begin
  result := g_MBaseControl;
end;

procedure IMBaseControl.doClose;
begin
  m_lRefCount := 1;
end;

function IMBaseControl.doCreateFrm: TRecFrm;
var
  np: cMBaseNP;
begin
  result := TMBaseControl.Create(nil);
  np := cMBaseNP(getNP('MBaseControlNP'));
  if np <> nil then
  begin
    if result = nil then
    begin
    end
    else
      np.init(TMBaseControl(result));
  end;
end;

function IMBaseControl.doGetName: LPCSTR;
begin
  result := 'БДИ';
end;

function IMBaseControl.doGetProperty(tag: Integer): LPCSTR;
var
  str: string;
begin
  result := inherited;
  case tag of
    // путь к испытанию
    0:
      begin
        if TMBaseControl(m_pMasterWnd).GetSelectTest <> nil then
          str := TMBaseControl(m_pMasterWnd).GetSelectTest.Absolutepath;
      end;
    // путь к регистрации
    1:
      begin
        if TMBaseControl(m_pMasterWnd).GetSelectReg <> nil then
          str := TMBaseControl(m_pMasterWnd).GetSelectReg.Path;
      end;
  end;
  result := LPCSTR(StrToAnsi(str));
end;

{ cMBaseFactory }

procedure cMBaseFactory.AddEvents;
begin

end;

constructor cMBaseFactory.Create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_MDBFormName;
  m_picname := c_Pic;
  m_Guid := IID_MBaseFactory;
  AddEvents;
end;

destructor cMBaseFactory.destroy;
begin
  // m_lRefCount:=0; // добавлено от 13.03.18
  inherited;
end;

procedure cMBaseFactory.incFrmCounter;
begin
  inc(m_counter);
end;

procedure cMBaseFactory.decFrmCounter;
begin
  dec(m_counter);
end;

function cMBaseFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := IMBaseControl.Create();
    incFrmCounter;
  end;
end;

procedure cMBaseFactory.doDestroyForms;
begin
  inherited;
  // decFrmCounter;
end;

procedure cMBaseFactory.doSetDefSize(var pSize: SIZE);
begin
  pSize.cx := c_Control_defXSize;
  pSize.cy := c_Control_defYSize;
end;

procedure cMBaseFactory.doStatusNONE(Sender: TObject);
begin

end;

procedure cMBaseFactory.doUpdateTags(Sender: TObject);
begin

end;

{ TMBaseControl } // применить
procedure TMBaseControl.Button1Click(Sender: TObject);
var
  curObj, objFolder, testFolder, regFolder: cXmlFolder;
  objtype:cObjType;
  proplist:tstringlist;
  I: Integer;
begin
  curObj:=selectObj;
  // сохраняем свойтсва SG в O
  SaveProperties(selectObj);
  if BaseFolderEdit.text <> m_base.m_BaseFolder.Absolutepath then
  begin
    m_base.InitBaseFolder(BaseFolderEdit.text);
    FillObjectsCB;
  end;
  // создаем объекты по кнопке применить
  objFolder := GetSelectObj;
  if objFolder = nil then
  begin
    if ObjNameCB.text <> '' then
    begin
      objFolder := cObjFolder.Create;
      // для вновь создаваемых нет смысла что то искать внутри
      objFolder.fscanFolders := false;
      objFolder.fscanFiles := false;
      m_base.m_BaseFolder.AddChild(objFolder);
      objFolder.Path := ObjNameCB.text;
      // создаем описатели и каталог
      objFolder.CreateFiles;
      ObjNameCB.AddItem(objFolder.name, objFolder);
      setComboBoxItem(objFolder.name, ObjNameCB);
    end;
  end;
  if objFolder<>nil then
  begin
    if ObjTypeCB.text<>'' then
    begin
      // присваиваем свойства
      objtype:=cbasemeafolder(m_base.m_BaseFolder).getObjType(ObjTypeCB.text);
      if objtype=nil then
      begin
        objtype:=cobjtype.create(objFolder);
        objtype.name:=ObjTypeCB.text;
        objtype.owner:=cBaseMeaFolder(m_base.m_BaseFolder).m_ObjTypes;
        cBaseMeaFolder(m_base.m_BaseFolder).m_ObjTypes.AddObject(objtype.name, objtype);
        ObjTypeCB.Items.AddObject(objtype.name, objtype);
        cObjFolder(objFolder).ObjType:=objtype.name;
      end
      else
      begin
        cObjFolder(objFolder).setObjType(ObjTypeCB.text, true, objtype.proplist);
      end;
    end
    else
    begin
      if objFolder<>nil then
      begin
        cObjFolder(objFolder).setObjType(ObjTypeCB.text, true, nil);
      end;
    end;
  end;
  if objFolder = nil then
    exit;
  testFolder := GetSelectTest;
  if testFolder = nil then
  begin
    if TestNameCB.text <> '' then
    begin
      testFolder := cTestFolder.Create;
      cTestFolder(testFolder).ObjType:=TestTypeCB.text;
      testFolder.name := TestNameCB.text;
      // для вновь создаваемых нет смысла что то искать внутри
      testFolder.fscanFolders := false;
      testFolder.fscanFiles := false;
      ObjFolder.AddChild(testFolder);
      testFolder.Path := TestNameCB.text;
      testFolder.caption := TestNameCB.text;
      testFolder.CreateFiles;

      TestNameCB.AddItem(testFolder.caption, testFolder);
      setComboBoxItem(testFolder.caption, TestNameCB);
    end;
  end
  else
  begin
    settestsettings(cTestFolder(testFolder));
    cTestFolder(testFolder).CreateXMLDesc;
  end;
  // присваиваем новому объекту стандартный набор свойств
  if TestTypeCB.text<>'' then
  begin
    // присваиваем свойства
    objtype:=cbasemeafolder(m_base.m_BaseFolder).getTestType(TestTypeCB.text);
    if objtype=nil then
    begin
      objtype:=cobjtype.create(testFolder);
      objtype.name:=TestTypeCB.text;
      objtype.owner:=cBaseMeaFolder(m_base.m_BaseFolder).m_TestTypes;
      cBaseMeaFolder(m_base.m_BaseFolder).m_TestTypes.AddObject(objtype.name, objtype);
      TestTypeCB.Items.AddObject(objtype.name, objtype);
      (testFolder).ObjType:=objtype.name;
    end
    else
    begin
      (testFolder).setObjType(TestTypeCB.text, true, objtype.proplist);
    end;
  end
  else
  begin
    if testFolder<>nil then
      ctestFolder(testFolder).ObjType:='';
  end;
  if testFolder = nil then
    exit;
  // добавляем новый тип испытания
  if cTestFolder(testFolder).ObjType <> '' then
    cBaseMeaFolder(m_base.m_BaseFolder).m_TestTypes.Add(cTestFolder(testFolder).ObjType);
  cregFolder(regFolder) := GetSelectReg;
  // для вновь создаваемых нет смысла что то искать внутри
  UpdateXmlDescr;
  if regFolder=nil then
    regfolder:=createreg;
  if regFolder <> nil then
  begin
    if regFolder is cregFolder then
    begin
      // свойства регистрации
      cregFolder(regFolder).m_alarm := AlarmCB.Checked;
      cregFolder(regFolder).m_alarmType := AlarmType.text;
      cregFolder(regFolder).m_alarmDsc := AlarmDsc.text;
      RegNameEdit.AddItem(regFolder.caption, regFolder);
      setComboBoxItem(regFolder.caption, RegNameEdit);
    end;
  end;
  // сохраняем свойства типов объектов
  cBaseMeaFolder(m_base.m_BaseFolder).CreateXMLDesc;
  if curObj is cObjFolder then
    ObjNameCBDblClick(ObjNameCb)
  else
  begin
    if curObj is cTestFolder then
    begin
      ObjNameCBDblClick(testFolder)
    end
    else
    begin
      ObjNameCBDblClick(regFolder)
    end;
  end;
end;

procedure TMBaseControl.UpdateXmlDescr;
var
  o: cObjFolder;
  t: cTestFolder;
  r: cregFolder;
begin
  o := GetSelectObj;
  if o <> nil then
  begin
    o.CreateXMLDesc;
  end;
  t := GetSelectTest;
  if t <> nil then
  begin
    t.CreateXMLDesc;
  end;
  r := GetSelectReg;

  if r <> nil then
  begin
    r.CreateXMLDesc;
  end;
end;

procedure TMBaseControl.AlarmCBClick(Sender: TObject);
begin
  AlarmPanel.Visible := AlarmCB.Checked;
end;

procedure TMBaseControl.CfgSBClick(Sender: TObject);
var
  lastcfg: cXmlFolder;
  cfgpath: string;
  pstr: pansichar;
  ir: irecorder;
begin
  if curTest <> nil then
  begin
    lastcfg := cXmlFolder(curTest.getChildrenByCaption('Lastcfg'));
    if lastcfg <> nil then
    begin
      cfgpath := extractfiledir(lastcfg.Absolutepath);
      cfgpath := FindFile('*.rcfg', cfgpath, 1);
      if not RStateConfig then
      begin
        ecm;
        ir := getIR;
        pstr := LPCSTR(StrToAnsi(cfgpath));
        ir.ImportSettings(pstr, IESF_DEFAULTSETTINGS+IESF_LOCAL_MODE);
        GPluginInstance.Notify(PN_RCLOADCONFIG, 0);
        lcm;
      end;
    end;
  end;
end;

constructor TMBaseControl.Create(Aowner: tcomponent);
var
  c: TRConnection;
begin
  inherited;

  g_MBaseControl := self;
  curObj := nil;
  curTest := nil;
  curReg := nil;

  m_counted := false;
  finit := false;
  fLoaded := false;
  InitPropSG(ObjPropSG);

  m_base := cMBase.Create;

  rc_pan := cRegController.Create;
  rc_pan.OnCreateConnection := doCreateConnection;
  c := rc_pan.createConnection('LocalRC', 'LocalRC', localhost,
    DEF_PORT_RECORDER);
  c.OnDelete := doDeleteRConnection;
  // showRegistrators;
  rc_pan.OnReceive := doOnRead;
  if RcClientFrm <> nil then
  begin
    RcClientFrm.init(rc_pan);
  end;

  CreateEvents;
  CallPlgEvents(E_MDBCreate);

end;

destructor TMBaseControl.destroy;
begin
  g_MBaseControl := nil;

  if m_base <> nil then
  begin
    m_base.destroy;
    m_base := nil;
  end;
  if rc_pan <> nil then
  begin
    rc_pan.destroy;
    rc_pan := nil;
  end;

  cMBaseFactory(m_f).decFrmCounter;
  DestroyEvents;
  inherited;
end;

procedure TMBaseControl.CreateEvents;
begin
  AddPlgEvent('MDBSaveXmlDscFiles', c_RC_SaveCfg, doSaveCfg);
  AddPlgEvent('TMBaseControl_doChangeRState', c_RC_DoChangeRCState, doChangeRCState);
  m_base.Events.AddEvent('TMBaseControl_AddPropertieEvent', E_AddNotifyPropertieEvent + E_ChangePropertieEvent, doAddPropertie);
end;

procedure TMBaseControl.DestroyEvents;
begin
  RemovePlgEvent(doSaveCfg, c_RC_SaveCfg);
  RemovePlgEvent(doChangeRCState, c_RC_DoChangeRCState);
  if m_base <> nil then
    m_base.Events.removeEvent(doAddPropertie,
      E_AddNotifyPropertieEvent + E_ChangePropertieEvent);
end;

procedure TMBaseControl.doAddPropertie(Sender: TObject);
begin
  ShowObjProps(cXmlFolder(Sender));
end;

procedure TMBaseControl.doChangePathNotify (objtype:DWORD);
var
  plgmngr: IPluginsControl;
  i: integer;
  point: pointer;
  p: iRecorderPlugin;
  plgname: lpcstr;
begin
  //ir:=getIR;
  // v_NotifyMBaseChangePath: Integer = VSN_USER + 2;
  //ir.Notify(v_NotifyMBaseChangePath, objtype);

  // VSN_USER = 28672
  // v_NotifyMBaseSetProperties: Integer = VSN_USER + 101;
  // v_NotifyMBaseChangePath: Integer = VSN_USER + 102;

  g_ir.GetPluginsControlClassObject(plgmngr);
  for i := 0 to plgmngr.GetPluginsCount - 1 do
  begin
    point := plgmngr.GetPlugin(i);
    p := iRecorderPlugin(point);
    plgname := p.Getname;
    //if p.Getname = c_MBaseName then
    //begin
    p.notify(v_NotifyMBaseChangePath, objtype);
    p._Release;
    pathlabel.caption:= getMDBRegPath;
    TestPathLabel.caption:= getMDBTestPath;
    //break;
    //end;
  end;
end;

procedure TMBaseControl.doChangeRCState(Sender: TObject);
begin
  case rcStateChange of
    RSt_Init: ;
    RSt_StopToView:
      ;
    RSt_StopToRec:
      createReg;
    RSt_ViewToStop:
      ;
    RSt_ViewToRec:
      createReg;
    RSt_initToRec:
      createReg;
    RSt_RecToStop:
      begin
        createSubRegs;
        setcurReg(m_reg);
        doStopRec(self);
      end;
    RSt_RecToView:
      begin
        createSubRegs;
        setcurReg(m_reg);
      end;
  end;
  rc_pan.Read;
  showRegistrators;
end;

procedure TMBaseControl.doCreateConnection(Sender: TObject);
begin
  showRegistrators;
end;

procedure TMBaseControl.doOnRead(connection: TRConnection; msg: tmsgHeader);
var
  index: Integer;
  li: TListItem;
begin
  index := rc_pan.getConnectionIndex(connection);
  li := RegistratorsLV.Items[index];
  if li = nil then
    exit;
  case msg.code of
    CODE_NOTIFY_STATE:
      begin
        case connection.state of
          CODE_COMMAND_STOP:
            begin
              li.ImageIndex := c_img_stop;
              RegistratorsLV.SetSubItemByColumnName('Путь',
                rc_pan.getConnectionPath(index), li);
              LVChange(RegistratorsLV);
            end;
          CODE_COMMAND_VIEW:
            li.ImageIndex := c_img_view;
          CODE_COMMAND_RECORD:
            li.ImageIndex := c_img_rec;
          CODE_COMMAND_PLAY:
            li.ImageIndex := c_img_view;
        end;
      end;
    CODE_NOTIFY_FILE:
      begin
        RegistratorsLV.SetSubItemByColumnName('Путь',
          rc_pan.getConnectionPath(index), li);
        LVChange(RegistratorsLV);
      end;
  end;
end;

procedure TMBaseControl.doSaveCfg(Sender: TObject);
begin
  m_base.UpdateXMLDescriptors;
  if assigned(fSaveCfg) then
  begin
    fSaveCfg(self);
  end;
end;

procedure TMBaseControl.doStopRec(Sender: TObject);
var
  t, lastcfg: cXmlFolder;
  b: Boolean;
  cfgpath: string;
begin
  if assigned(fOnStopRec) then
  begin
    fOnStopRec(Sender);
  end;
  t := TMBaseControl(Sender).GetSelectTest;
  lastcfg := cXmlFolder(t.getChildrenByCaption('Lastcfg'));
  if lastcfg = nil then
  begin
    lastcfg := cLastCfgFolder.Create;
    // lastcfg.path := path;
    lastcfg.name := 'Lastcfg';
    t.AddChild(lastcfg);
  end;
  cfgpath := lastcfg.getProperty('PrevCfg', b);
  if not b then
  begin
    cfgpath := extractfiledir(getRConfig);
    copydir(cfgpath, lastcfg.Absolutepath, 0);
    lastcfg.addpropertie('PrevCfg', getRConfig);
    lastcfg.CreateFiles;
  end
  else
  begin
    if cfgpath <> getRConfig then
    begin
      cfgpath := extractfiledir(getRConfig);
      if cfgpath <> lastcfg.Absolutepath then
      begin
        copydir(cfgpath, lastcfg.Absolutepath, 0);
        lastcfg.addpropertie('PrevCfg', getRConfig);
      end;
    end;
  end;
end;

procedure TMBaseControl.doUpdateData(Sender: TObject);
begin

end;

procedure TMBaseControl.DownloadRegsBtnClick(Sender: TObject);
begin
  if DownloadRegsFrm <> nil then
    DownloadRegsFrm.ShowDB(m_base);
end;

function TMBaseControl.EmptyReg: cregFolder;
var
  I: Integer;
  r: cregFolder;
begin
  result := nil;
  for I := 0 to RegNameEdit.Items.Count - 1 do
  begin
    r := cregFolder(RegNameEdit.Items.Objects[I]);
    if r.empty then
    begin
      result := r;
      exit;
    end;
  end;
end;

procedure TMBaseControl.FillObjectsCB;
var
  I: Integer;
  o: cXmlFolder;
  p: tnotifyevent;
begin
  ObjNameCB.Clear;
  p := ObjNameCB.OnChange;
  ObjNameCB.OnChange := nil;
  for I := 0 to m_base.Count - 1 do
  begin
    o := cXmlFolder(m_base.getobj(I));
    if o is cObjFolder then
    begin
      ObjNameCB.Items.AddObject(o.caption, o);
    end;
  end;
  ObjNameCB.OnChange := p;
  // заполняем типы объектов
  for I := 0 to cBaseMeaFolder(m_base.m_BaseFolder).m_ObjTypes.Count - 1 do
  begin
    ObjTypeCB.AddItem(cBaseMeaFolder(m_base.m_BaseFolder).m_ObjTypes.Strings[i],cBaseMeaFolder(m_base.m_BaseFolder).m_ObjTypes.Objects[i]);
  end;
end;

procedure TMBaseControl.FillRegCB(t: cTestFolder);
var
  r: TObject;
  I: Integer;
  p: tnotifyevent;
begin
  p := RegNameEdit.OnChange;
  RegNameEdit.OnChange := nil;
  RegNameEdit.Items.Clear;
  if t = nil then
  begin
  end
  else
  begin
    for I := 0 to t.ChildCount - 1 do
    begin
      r := (t.getChild(I));
      if r is cregFolder then
        RegNameEdit.Items.AddObject(cregFolder(r).caption, r);
    end;
  end;
  RegNameEdit.OnChange := p;
  setComboBoxItem(RegNameEdit.text, RegNameEdit);
  if RegNameEdit.itemindex <> -1 then
  begin
    r := cregFolder(RegNameEdit.Items.Objects[RegNameEdit.itemindex]);
    setcurReg(cregFolder(r));
  end;
end;

procedure TMBaseControl.FillTestsCB(o: cObjFolder);
var
  t: cTestFolder;
  I: Integer;
  p: tnotifyevent;
begin
  p := TestNameCB.OnChange;
  TestNameCB.OnChange := nil;
  TestNameCB.Items.Clear;
  if o = nil then
  begin

  end
  else
  begin
    //setComboBoxItem(o.m_ObjType, ObjTypeCB);
    TestNameCB.text:=TestNameCB.text;
    for I := 0 to o.ChildCount - 1 do
    begin
      t := cTestFolder(o.getChild(I));
      TestNameCB.Items.AddObject(t.caption, t);
    end;
  end;
  TestNameCB.OnChange := p;
  setComboBoxItem(TestNameCB.text, TestNameCB);

  // заполняем типы объектов
  TestTypeCB.Clear;
  for I := 0 to cBaseMeaFolder(m_base.m_BaseFolder).m_TestTypes.Count - 1 do
  begin
    TestTypeCB.AddItem(cBaseMeaFolder(m_base.m_BaseFolder).m_TestTypes.Strings[i],cBaseMeaFolder(m_base.m_BaseFolder).m_TestTypes.Objects[i]);
  end;
end;

procedure TMBaseControl.FormPaint(Sender: TObject);
begin
  //showmessage('1');
end;

function TMBaseControl.createReg:cregfolder;
var
  test: cTestFolder;
  date: tdatetime;
  Path: string;
  objFolder: cObjFolder;
begin
  result:=nil;
  test := GetSelectTest;
  if test = nil then
  BEGIN
    test := cTestFolder.Create;
    test.ObjType := TestTypeCB.text;
    test.name := TestNameCB.text;
    // для вновь создаваемых нет смысла что то искать внутри
    test.fscanFolders := false;
    test.fscanFiles := false;
    objFolder := GetSelectObj;
    objFolder.AddChild(test);
    test.Path := TestNameCB.text;
    test.caption := TestNameCB.text;
    test.CreateFiles;

    TestNameCB.AddItem(test.name, test);
    setComboBoxItem(test.caption, TestNameCB);
  END;
  if test <> nil then
  begin
    Path := createRegName(test.Absolutepath, test);
    if m_reg <> nil then
    begin
      if m_reg.Absolutepath <> Path then
      begin
        m_reg := nil
      end
      else
      begin
        // нельзя писать в регистрацию которая уже содержит данные
        if not m_reg.empty then
          m_reg := nil;
      end;
    end;

    if m_reg = nil then
    begin
      m_reg := cregFolder.Create;
      // m_reg.name:=extractfilename(createRegName(test.Absolutepath));

      m_reg.Path := Path;

      test.AddChild(m_reg);
      m_reg.fscanFolders := false;
      m_reg.fscanFiles := false;
      m_reg.CreateFiles;

      RegNameEdit.AddItem(m_reg.caption, m_reg);
      setComboBoxItem(m_reg.caption,RegNameEdit);
      setcurReg(m_reg);
    end;
    result:=m_reg;
  end;
end;

function TMBaseControl.createRegName(basepath: string; t: cTestFolder): string;
var
  fld: string;
  date: tdatetime;
  lmodname: Boolean;
  reg: cregFolder;
begin
  if RegNameEdit.text <> '' then
  begin
    fld := RegNameEdit.text;
  end
  else
  begin
    date := now;
    fld := DateTimeToStr(date);
    fld := replaceChar(fld, ':', '.');
    fld := 'Reg';
  end;
  basepath := AddSlashToPath(basepath);
  result := basepath + fld;
  lmodname := false;
  while DirectoryExists(result) do
  begin
    reg := cregFolder(m_base.getchildbypath(result));
    if reg <> nil then
    begin
      if reg.empty then
      begin
        result := reg.Absolutepath;
        exit;
      end;
    end;
    result := modname(result, false);
    lmodname := true;
  end;
  if lmodname then
  begin
    // RegNameEdit.text := extractDirName(result);
  end;
end;

procedure TMBaseControl.createSubRegs;
var
  I: Integer;
  lname, lpath, lfolder: string;
begin
  if m_reg <> NIL then
  BEGIN
    for I := 0 to rc_pan.Count - 1 do
    begin
      lname := rc_pan.getConnectionName(I);
      lpath := rc_pan.getConnectionPath(I);
      lfolder := rc_pan.getConnectionFolder(I);
      m_reg.AddSignal(lname, lpath, lfolder);
    end;
    m_reg.CreateFiles;
  END;
end;

function TMBaseControl.GetSelectObj: cObjFolder;
begin
  result := cObjFolder(m_base.m_BaseFolder.getChildrenByName(ObjNameCB.text));
end;

function TMBaseControl.GetSelectReg: cregFolder;
var
  t: cTestFolder;
begin
  result := nil;
  t := GetSelectTest;
  if t <> nil then
  begin
    result := cregFolder(t.getChildrenByCaption(RegNameEdit.text));
    if result = nil then
    begin
      //createReg;
      //result := m_reg;
    end;
  end;
end;

function TMBaseControl.GetSelectTest: cTestFolder;
var
  o: cObjFolder;
  t: cXmlFolder;
begin
  result := nil;
  o := GetSelectObj;
  if o <> nil then
  begin
    if (o is cObjFolder) then
    begin
      t := cXmlFolder(o.getChildrenByCaption(TestNameCB.text));
      if t is cTestFolder then
      begin
        result := cTestFolder(t);
      end;
    end;
  end;
end;

procedure TMBaseControl.mdbBtnClick(Sender: TObject);
begin
  if MDBFrm <> nil then
    MDBFrm.ShowMDB(m_base);
end;

function GetOsVersion: Integer;
var
  str: string;
  VersionInformation: OSVERSIONINFO;
begin
  VersionInformation.dwOSVersionInfoSize := sizeof(VersionInformation);
  GetVersionEx(VersionInformation);
  // str:='OS Version '+
  // intToStr(VersionInformation.dwMajorVersion)+'.'+
  // intToStr(VersionInformation.dwMinorVersion)+' '+VersionInformation.szCSDVersion;
  // Result:=str;
  result := VersionInformation.dwMajorVersion;
end;

function SelectDirectoryLoc(const Title: string; var Path: string): Boolean;
var
  lpItemID, start: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array [0 .. MAX_PATH] of char;
  TempPath: array [0 .. MAX_PATH] of char;
begin
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  BrowseInfo.pszDisplayName := @Path[1];
  BrowseInfo.hwndOwner := 0;
  BrowseInfo.lpszTitle := PChar(Title);
  // BrowseInfo.pidlRoot:=start;
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  result := lpItemID <> nil;
  if result then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    Path := TempPath;
    GlobalFreePtr(lpItemID);
  end;
end;

procedure TMBaseControl.MdbPathBtnClick(Sender: TObject);
var
  str: string;
begin
  if GetOsVersion >= 6 then
  begin
    OpenDialog1vista.filename := BaseFolderEdit.text;
    OpenDialog1vista.Options := [fdoPickFolders, fdoForceFileSystem];
    if OpenDialog1vista.Execute() then
    begin
      BaseFolderEdit.text := OpenDialog1vista.filename;
    end;
  end
  else
  begin
    // OpenDialog1.Options := [ofOldStyleDialog, fdoForceFileSystem];
    str := BaseFolderEdit.text;
    // if SelectDirectory('Выбор базового каталога', '',str) then
    if SelectDirectoryLoc('Выбор базового каталога', str) then
    begin
      BaseFolderEdit.text := str;
    end;
  end;
end;

procedure TMBaseControl.ObjPropSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  cb:tcombobox;
  Color, normcolor: integer;
  I: integer;
  str:string;
  t:cObjType;
  p:tprop;
  b:boolean;
begin
  sg := TStringGrid(Sender);
  if selectObj is cObjFolder then
  begin
    cb:=objtypecb;
    if objtypecb.ItemIndex=-1 then
      t:=nil
    else
      t:=cObjType(cb.Items.Objects[cb.ItemIndex]);
  end
  else
  begin
    cb:=testtypecb;
    if testtypecb.ItemIndex=-1 then
      t:=nil
    else
      t:=cObjType(cb.Items.Objects[cb.ItemIndex]);
  end;
  // имя свойства
  str := sg.Cells[0, ARow];
  normcolor := sg.Canvas.Brush.Color;
  color:=normcolor;
  if arow>0 then
  begin
    if t<>nil then
    begin
      if str<>'' then
      begin
        p:=t.getprop(str);
        // у типа нет свойства как в ячейке. к типу надо добавить это свойство
        if p=nil then
          Color := CLgreen
        else
        begin
          selectObj.getProperty(str, b);
          // у типа есть а у объекта нету
          if not b then
            Color := clYellow;
        end;
      end;
    end;
  end;
  sg.Canvas.Brush.Color := Color;
  sg.Canvas.FillRect(Rect);
  sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
  sg.Canvas.Brush.Color := Color;
end;

procedure TMBaseControl.ObjPropSGEndEdititng(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
var
  obj: cXmlFolder;
  sg: TStringGridExt;
  prop, val: string;
  I, ind: Integer;
begin
  obj := nil;
  sg := TStringGridExt(Sender);
  if (ARow = sg.rowcount - 1) then
  begin
    // добавить строку
    if not sg.rowempty(ARow) then
    begin
      sg.rowcount := sg.rowcount + 1;
      sg.eraseRow(sg.rowcount - 1);
    end;
  end;
  if (ARow = sg.rowcount - 2) then
  begin
    // удалить строку
    if sg.rowempty(ARow) then
    begin
      if sg.rowempty(ARow + 1) then
      begin
        sg.rowcount := sg.rowcount - 1;
      end;
    end;
  end;

  if Sender = ObjPropSG then
  begin
    obj := GetSelectObj;
  end;

  prop := '';
  val := '';
  if obj <> nil then
  begin
    prop := sg.Cells[c_col_propName, ARow];
    val := sg.Cells[c_col_propVal, ARow];
    if ACol = c_col_propName then
    begin
      ind := obj.FindPropertie(prop);
      // модифицируем имя только в том случае если вписано свойство с повторившимся именем в новую ячейку
      if ind <> -1 then
      begin
        if ind <> ARow - 1 then
        begin
          while obj.FindPropertie(prop) <> -1 do
          begin
            prop := modname(prop, false);
          end;
          sg.Cells[c_col_propName, ARow] := prop;
        end;
      end;
    end;
    if (prop <> '') and (val <> '') then
    begin
      //obj.addpropertie(prop, val);
    end;
    if (prop = '') and (val = '') then
    begin
      if ind <> -1 then
      begin
        obj.delpropertie(ARow - 1);
        sg.deleteRow(ARow);
      end;
    end;
  end;
  SGChange(sg);
end;

procedure TMBaseControl.ObjPropSGExit(Sender: TObject);
var
  c,r:integer;
  b:boolean;
begin
  r:=TStringGridExt(sender).RowCount-1;
  c:=TStringGridExt(sender).ColCount-1;
  b:=true;
  ObjPropSGEndEdititng(sender, c, r, b);
end;

procedure TMBaseControl.ObjNameCBChange(Sender: TObject);
var
  o: cObjFolder;
  b: Boolean;
begin
  b := CheckCBItemInd(ObjNameCB);
  if b then
  begin
    o := cObjFolder(ObjNameCB.Items.Objects[ObjNameCB.itemindex]);
    setcurObj(o);
  end
  else
  begin
    o := nil;
    FillTestsCB(o);
  end;
  CheckCBItemInd(TestNameCB);
  ObjNameCBDblClick(sender);
end;

procedure TMBaseControl.ObjNameCBDblClick(Sender: TObject);
var
  b:boolean;
begin
  if sender = ObjNameCB then
    selectObj:=GetSelectObj;
  if sender = TestNameCB then
    selectObj:=GetSelectTest;
  if sender = RegNameEdit then
    selectObj:=GetSelectReg;

  if selectObj<>nil then
  begin
    ShowObjProps(selectObj);
    SelObjName.text:=selectObj.caption;
    if selectObj is cObjFolder then
    begin
      ObjNameCB.Color:=clLime;
      if TestNameCB.Color=clLime then
      begin
        TestNameCB.Color:=clWindow;
      end;
      if RegNameEdit.Color=clLime then
      begin
        RegNameEdit.Color:=clWindow;
      end;
    end;
    if selectObj is cTestFolder then
    begin
      TestNameCB.Color:=clLime;
      if ObjNameCB.Color=clLime then
      begin
        ObjNameCB.Color:=clWindow;
      end;
      if RegNameEdit.Color=clLime then
      begin
        RegNameEdit.Color:=clWindow;
      end;
    end;
    if selectObj is cRegFolder then
    begin
      RegNameEdit.Color:=clLime;
      if ObjNameCB.Color=clLime then
      begin
        ObjNameCB.Color:=clWindow;
      end;
      if TestNameCb.Color=clLime then
      begin
        TestNameCb.Color:=clWindow;
      end;
    end;
  end
  else
  begin
    selectObj:=nil;
    SelObjName.Text:='';
    TestNameCb.Color:=clWindow;
    ObjNameCb.Color:=clWindow;
    RegNameEdit.Color:=clWindow;
  end;
  b:=false;
  ObjPropSGSelectCell(ObjPropSG, -1,-1, b);
end;

procedure TMBaseControl.RegNameEditChange(Sender: TObject);
var
  r: cregFolder;
  b: Boolean;
begin
  b := CheckCBItemInd(RegNameEdit);
  if b then
  begin
    r := cregFolder(RegNameEdit.Items.Objects[RegNameEdit.itemindex]);
    setcurReg(r);
  end
  else
  begin
    r := nil;
    setcurReg(r);
  end;
  ObjNameCBDblClick(sender);
end;

procedure TMBaseControl.ObjPropSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  sg: TStringGridExt;
  obj: cXmlFolder;
  prop, val: string;
  ARow, ACol, ind:integer;
begin

  obj := nil;

  sg := TStringGridExt(Sender);
  if sg.row = 0 then
    exit;
  if Key = VK_DELETE then
  begin
    if Sender = ObjPropSG then
    begin
      obj := selectObj;
    end;
    if obj <> Nil then
    begin
      if not sg.EditorMode then
        obj.delpropertie(sg.row - 1);
    end;
    if sg.rowcount = 1 then
      sg.rowcount := 2;
  end;
  if Key = VK_RETURN then
  begin
    obj := selectObj;
    prop := '';
    val := '';
    if obj <> nil then
    begin
      prop := sg.Cells[c_col_propName, sg.Row];
      val := sg.Cells[c_col_propVal, sg.Row];
      if sg.Col = c_col_propName then
      begin
        ind := sg.row-1;
        // модифицируем имя только в том случае если вписано свойство с повторившимся именем в новую ячейку
        if ind <> -1 then
        begin
          if ind <> sg.RowCount - 2 then
          begin
            obj.RenameProp(prop, ind);
            sg.Cells[c_col_propName, sg.Row] := prop;
          end
          else
          begin
            obj.Setpropertie(prop, val);
          end;
        end;
      end
      else
      begin
        if (prop <> '') and (val <> '') then
        begin
          obj.Setpropertie(prop, val);
        end;
      end;
    end;
  end;
end;

procedure TMBaseControl.ObjPropSGSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  //pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
  // Находим позицию нашей ячейки
  selectPropCol := ACol;
  selectPropRow := ARow;
  if (selectPropCol>=0) and (selectPropRow>=0) then
  begin
    selectProp:=TStringGrid(Sender).Cells[0,selectPropRow];
  end
  else
  begin
    selectPropCol := -1;
    selectPropRow := -1;
  end;
end;

procedure TMBaseControl.ObjRenameBtnClick(Sender: TObject);
var
  I: Integer;
  objtype:cobjtype;
  objFolder:cxmlFolder;
  str:string;
begin
  if selectObj <> nil then
  begin
    // сохраняем свойтсва SG в O
    SaveProperties(selectObj);
    objFolder:= cxmlfolder(selectObj);
    // присваиваем свойства
    if objfolder is cObjFolder then
    begin
      str:=ObjTypeCB.text;
      objtype:=cbasemeafolder(m_base.m_BaseFolder).getObjType(ObjTypeCB.text)
    end
    else
    begin
      str:=TestTypeCB.text;
      objtype:=cbasemeafolder(m_base.m_BaseFolder).getTestType(TestTypeCB.text);
    end;
    if str='' then exit;
    if objtype=nil then
    begin
      objtype:=cobjtype.create(objFolder);
      objtype.name:=str;
      if objfolder is cObjFolder then
      begin
        objtype.owner:=cBaseMeaFolder(m_base.m_BaseFolder).m_ObjTypes;
        ObjTypeCB.Items.AddObject(objtype.name, objtype);
      end
      else
      begin
        objtype.owner:=cBaseMeaFolder(m_base.m_BaseFolder).m_testTypes;
        TestTypeCB.Items.AddObject(objtype.name, objtype);
      end;
      objtype.owner.AddObject(objtype.name, objtype);
      (objFolder).ObjType:=objtype.name;
    end
    else
    begin
      objtype.clear;
      for I := 0 to objFolder.PropCount - 1 do
      begin
        objtype.addProp(objFolder.getPropertyName(i),'0');
      end;
      (objFolder).setObjType(ObjType.name, true, objtype.proplist);
      objFolder.CreateXMLDesc;
    end;
    cBaseMeaFolder(m_base.m_BaseFolder).CreateXMLDesc;
  end;
end;

procedure TMBaseControl.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  section: string;
  I: Integer;
  c: TRConnection;
begin
  inherited;
  section := String(str);
  a_pIni.WriteInteger(section, 'MBaseSetPropertiesNotify',
    v_NotifyMBaseSetProperties);
  a_pIni.WriteString(section, 'BaseFolder', BaseFolderEdit.text);
  a_pIni.WriteString(section, 'ObjName', ObjNameCB.text);
  a_pIni.WriteString(section, 'TestType', TestTypeCB.text);
  a_pIni.WriteString(section, 'TestName', TestNameCB.text);
  a_pIni.WriteString(section, 'RegName', RegNameEdit.text);
  if rc_pan.Count > 1 then
  begin
    a_pIni.WriteInteger(section, 'ConnectionCount', rc_pan.Count);
    for I := 0 to rc_pan.Count - 1 do
    begin
      c := rc_pan.getconnection(I);
      a_pIni.WriteString(section, 'ConName' + inttostr(I),
        rc_pan.getConnectionName(I));
      a_pIni.WriteString(section, 'ConFld' + inttostr(I), c.folder);
      a_pIni.WriteString(section, 'ConHost' + inttostr(I), c.Address);
      a_pIni.WriteInteger(section, 'ConPort' + inttostr(I), c.port);
    end;
  end;
end;

procedure TMBaseControl.setcurObj(o: cObjFolder);
begin
  curObj := o;
  if o is cObjFolder then
  begin
    setComboBoxItem(o.ObjType,ObjTypeCB);
  end;
  FillTestsCB(cObjFolder(o));
  doChangePathNotify(c_changeObj);
end;

procedure TMBaseControl.setcurReg(r: cregFolder);
var
  lemptyreg: cregFolder;
  t: cTestFolder;
  emtyname: string;
begin
  m_reg := r;
  if r = nil then
  begin
    t := GetSelectTest;
    if t <> nil then
    begin
      emtyname := extractfilename(createRegName(t.Absolutepath, t));
      RegNameEdit.Hint := 'Следующая регистрация: ' + emtyname;
      RegNameEdit.ShowHint := true;
    end;
    exit;
  end;
  RegNameEdit.text := r.caption;
  setComboBoxItem(r.caption, RegNameEdit);
  AlarmCB.Checked := r.m_alarm;
  AlarmCBClick(nil);
  if r.m_alarm then
  begin
    AlarmDsc.text := r.m_alarmDsc;
    setComboBoxItem(r.m_alarmType, AlarmType);
  end;
  if not r.empty then
  begin
    lemptyreg := EmptyReg;
    RegNameEdit.ShowHint := true;
    if lemptyreg = nil then
    begin
      t := GetSelectTest;
      emtyname := extractfilename(createRegName(t.Absolutepath, t));
    end
    else
      emtyname := lemptyreg.caption;
    RegNameEdit.Hint :=
      'Невозможно записать в завершенную регистрацию. Запись будет произведена в регистрацию: ' + emtyname;
    RegNameEdit.Color := clGray;
  end
  else
  begin
    RegNameEdit.ShowHint := false;
    RegNameEdit.Color := clWindow;
  end;
  doChangePathNotify(c_changeReg);
end;

procedure TMBaseControl.setcurTest(t: cTestFolder);
var
  lastcfg: cXmlFolder;
  b: Boolean;
  cfgpath: string;
begin
  curTest := t;
  if t = nil then
    exit;
  TestTypeCB.text:=t.ObjType;

  FillRegCB(cTestFolder(t));

  lastcfg := cXmlFolder(t.getChildrenByCaption('Lastcfg'));
  if lastcfg <> nil then
  begin
    cfgpath := extractfiledir(lastcfg.Absolutepath);
    cfgpath := FindFile('*.rcfg', cfgpath, 1);
    CfgSB.Hint := 'Конфигурация испытания: ' + cfgpath;
  end
  else
  begin
    CfgSB.Hint := 'Конфигурация испытания:';
  end;
  doChangePathNotify(c_changeTest);
end;

procedure TMBaseControl.settestsettings(t: cTestFolder);
begin

end;

procedure TMBaseControl.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  lstr, section, host, conname, folder: string;
  I, port, ccount: Integer;
  obj, t: cXmlFolder;
  con: TRConnection;
  localR: Boolean;
  c: TRConnection;
begin
  // exit;
  inherited;
  if fLoaded then
    exit;

  section := String(str);
  v_NotifyMBaseSetProperties := a_pIni.ReadInteger(section, 'MBaseSetPropertiesNotify', 101);
  folder := a_pIni.ReadString(section, 'BaseFolder', '');
  if folder<>'' then
  begin
    i:=length(folder);
    if folder[i]='\' then
    begin
      setlength(folder,i-1);
    end;
    BaseFolderEdit.text:=folder;
    m_base.InitBaseFolder(BaseFolderEdit.text);
  end;

  FillObjectsCB;
  lstr := a_pIni.ReadString(section, 'ObjName', '');
  setComboBoxItem(lstr, ObjNameCB);
  obj := cXmlFolder(m_base.m_BaseFolder.getChild(lstr));
  setcurObj(cObjFolder(obj));
  if obj <> nil then
  begin
    ObjNameCBDblClick(ObjNameCB);
    ShowObjProps(obj);
  end;

  FillTestsCB(cObjFolder(obj));
  lstr := a_pIni.ReadString(section, 'TestName', '');
  setComboBoxItem(lstr, TestNameCB);
  TestTypeCB.text := a_pIni.ReadString(section, 'TestType', '');
  t := GetSelectTest;
  if t <> nil then
  begin
    setcurTest(cTestFolder(t));
  end;

  RegNameEdit.text := a_pIni.ReadString(section, 'RegName', '');
  obj := GetSelectTest;

  FillRegCB(cTestFolder(obj));

  ccount := a_pIni.ReadInteger(section, 'ConnectionCount', 0);
  if ccount > 0 then
  begin
    for I := 0 to ccount - 1 do
    begin
      localR := false;
      conname := a_pIni.ReadString(section, 'ConName' + inttostr(I), '');
      folder := a_pIni.ReadString(section, 'ConFld' + inttostr(I), '');
      host := a_pIni.ReadString(section, 'ConHost' + inttostr(I), '');
      port := a_pIni.ReadInteger(section, 'ConPort' + inttostr(I), 0);
      // если прочитали дефолтный регистратор
      if (host = '127.0.0.1') or (lowercase(host) = 'localhost') then
      begin
        if port = DEF_PORT_RECORDER then
        begin
          localR := true;
          con := rc_pan.getconnection(0);
          con.folder := folder;
        end;
      end;
      if not localR then
      begin
        c := rc_pan.createConnection(conname, folder, host, port);
        c.OnDelete := doDeleteRConnection;
      end;
    end;
  end;
  showRegistrators;
  fLoaded := true;
end;
// сколько свойств есть у типа которых нет у объекта
function GetNewPropFromType(obj:cXmlFolder; t:cObjType; strList:TStringList):integer;
var
  I: Integer;
  b:boolean;
  pr:string;
begin
  result:=0;
  for I := 0 to t.proplist.Count - 1 do
  begin
    pr:=t.proplist.Strings[i];
    obj.getProperty(pr, b);
    if not b then
    begin
      inc(result);
      strList.Add(pr);
    end;
  end;
end;


procedure TMBaseControl.ShowObjProps(o: cXmlFolder);
var
  sg: TStringGridExt;
  I, new: Integer;
  t:cObjType;
  j: Integer;
  prList:tstringlist;
  str:string;
begin
  sg := nil;
  if o = nil then
    exit;
  sg := ObjPropSG;
  if sg <> nil then
  begin
    prList:=TStringList.Create;
    if o is cObjFolder then
      t:= cbasemeafolder(m_base.m_BaseFolder).getObjType(ObjTypeCB.text)
    else
    begin
      if o is cTestFolder then
        t:= cbasemeafolder(m_base.m_BaseFolder).getTestType(TestTypeCB.text);
    end;
    new:=0;
    if t<>nil then
      new:=GetNewPropFromType(o, t, prList);
    sg.rowcount := o.PropCount + 2+new;
    for I := 0 to o.PropCount - 1 do
    begin
      sg.Cells[c_col_propName, I + 1] := o.getPropertyName(I);
      sg.Cells[c_col_propVal, I + 1] := o.getProperty(I);
    end;
    for i := 0 to prList.Count - 1 do
    begin
      str:=prList.Strings[i];
      sg.Cells[c_col_propName, o.PropCount+i+1] := str;
      sg.Cells[c_col_propVal, o.PropCount+i+1] := t.getval(str);
    end;
    prList.Destroy;
    sg.Cells[c_col_propName, sg.rowcount - 1] := '';
    sg.Cells[c_col_propVal, sg.rowcount - 1] := '';
  end;
end;

procedure setObjProps(o:cxmlFolder; sg:tstringgrid);
var
  i,j:integer;
  pname, v:string;
  b:boolean;
begin
  if sg <> nil then
  begin
    for I := o.propCount - 1 downto 0 do
    begin
      pname:=o.getPropertyName(i);
      b:=false;
      for j := 1 to sg.RowCount - 1 do
      begin
        v:=sg.Cells[c_col_propName,j];
        if pname=v then
        begin
          b:=true;
          break;
        end;
      end;
      if not b then
        o.delpropertie(i);
    end;
    for I := 1 to sg.RowCount - 1 do
    begin
      pname:=sg.Cells[c_col_propName,i];
      if pname='' then
        exit;
      v:=sg.Cells[c_col_propVal,i];
      o.Setpropertie(pname,v);
    end;
  end;
end;

procedure TMBaseControl.SaveProperties(o:cXmlFolder);
var
  sg:TStringGridExt;
  i:integer;
  pname, v:string;
  obj:cxmlfolder;
begin
  if o<>nil then
  begin
    cMBase(m_base).Events.active:=false;
    setObjProps(o, ObjPropSG);
    cMBase(m_base).Events.active:=false;
  end;
end;

procedure TMBaseControl.doDeleteRConnection(Sender: TObject);
begin
  showRegistrators;
end;

procedure TMBaseControl.DoGetNotify(data: dword);
var
  MBaseNotify: TMBaseNotify;
  pars: TStringList;
  I, j, p, PropCount: Integer;
  str, param: string;

  obj: cXmlFolder;
  callevent: Boolean;
begin
  callevent := false;
  MBaseNotify := TMBaseNotify(pointer(data)^);

  // парсим значения в tstringlist
  I := 0;
  pars := TStringList.Create;
  if MBaseNotify.ObjID = 'curobj' then
  begin
    obj := GetSelectObj;
  end
  else
  begin
    if MBaseNotify.ObjID = 'curtest' then
    begin
      obj := GetSelectTest;
    end
    else
    begin
      if MBaseNotify.ObjID = 'curreg' then
      begin
        obj := GetSelectReg;
      end;
    end;
  end;
  if obj = nil then
    exit;

  while I <= length(MBaseNotify.Operation) do
  begin
    str := GetSubString(MBaseNotify.Operation, ';', I, I);
    pars.Add(str);
    str := GetSubString(MBaseNotify.Operation, ';', I + 1, I);
    pars.Add(str);
    if I = -1 then
      break;
  end;

  if MBaseNotify.OperType = 0 then
  begin
    PropCount := round(pars.Count / 2);
    for I := 0 to PropCount - 1 do
    begin
      obj.addpropertie(pars.Strings[I * 2], pars.Strings[(I * 2 + 1)]);
      callevent := true;
    end;
  end;
  if MBaseNotify.OperType = 1 then
  begin
    for I := 0 to pars.Count - 1 do
    begin
      obj.delpropertie(pars.Strings[I]);
      callevent := true;
    end;
  end;
  if callevent then
    m_base.Events.CallAllEventsWithSender(E_AddNotifyPropertieEvent, obj);
end;

procedure TMBaseControl.showRegistrators;
var
  I: Integer;
  s: string;
  li: TListItem;
begin
  RegistratorsLV.Clear;
  for I := 0 to rc_pan.Count - 1 do
  begin
    li := RegistratorsLV.Items.Add;

    s := rc_pan.getConnectionName(I);
    li.data := rc_pan.getconnection(I);
    RegistratorsLV.SetSubItemByColumnName(c_col_regname, s, li);
    s := rc_pan.getConnectionFolder(I);
    RegistratorsLV.SetSubItemByColumnName(c_col_folder, s, li);
    if rc_pan.Connected(I) then
    begin
      // 1 - connected
      li.ImageIndex := 1;
      case rc_pan.getConnectionState(I) of
        CODE_COMMAND_STOP:
          li.ImageIndex := c_img_stop;
        CODE_COMMAND_VIEW:
          li.ImageIndex := c_img_view;
        CODE_COMMAND_RECORD:
          li.ImageIndex := c_img_rec;
        CODE_COMMAND_PLAY:
          li.ImageIndex := c_img_view;
      end;
    end
    else
    begin
      li.ImageIndex := 0;
    end;
  end;
  LVChange(RegistratorsLV);
end;

procedure TMBaseControl.SpeedButton1Click(Sender: TObject);
var
  n: TMBaseNotify;
begin
  rc_pan.stop;

  n.ObjID := 'curobj';
  // обавление свойств
  n.OperType := 1;
  n.Operation := 'TestNotify';
  sendMDBNotifyMessage(n);
end;

procedure TMBaseControl.Splitter4Moved(Sender: TObject);
begin
  synchroniseSplitters(Sender);
end;

procedure TMBaseControl.StopBtnClick(Sender: TObject);
// var
// n:TMBaseNotify;
begin
  rc_pan.stop;

  // n.ObjID:='curobj';
  // обавление свойств
  // n.OperType:=0;
  // n.Operation:='TestNotify;1';
  // sendNotifyMessage(n);
end;

procedure TMBaseControl.synchroniseSplitters(Sender: TObject);
var
  w: Integer;
begin
  //if Sender = Splitter6 then
  begin
    w := ObjPanel.Width;
  end;
  //if Sender = Splitter5 then
  begin
    w := TestPanel.Width;
  end;
  //if Sender = Splitter4 then
  begin
    w := RegPanel.Width;
  end;
  RegPanel.Width := w;
  ObjPanel.Width := w;
  TestPanel.Width := w;
end;

procedure TMBaseControl.TestNameCBChange(Sender: TObject);
var
  t: cTestFolder;
  b: Boolean;
  r: cregFolder;
begin
  b := CheckCBItemInd(TestNameCB);
  if b then
  begin
    t := cTestFolder(TestNameCB.Items.Objects[TestNameCB.itemindex]);
    setcurTest(t);
    r := EmptyReg;
    setcurReg(r);
  end
  else
  begin
    t := nil;
    FillRegCB(t);
  end;
  CheckCBItemInd(TestNameCB);
  ObjNameCBDblClick(Sender);
end;

procedure TMBaseControl.TestTypeCBChange(Sender: TObject);
var
  t: cTestFolder;
begin
  t:=GetSelectTest;
  FillRegCB(t);
  ObjPropSG.Invalidate;
end;

procedure TMBaseControl.TestTypeCBCloseUp(Sender: TObject);
begin
  ObjNameCBDblClick(TestNameCB);
end;

procedure TMBaseControl.Timer1Timer(Sender: TObject);
begin
  if rc_pan <> nil then
  begin
    rc_pan.connect;
    rc_pan.Read;
  end;
end;

procedure TMBaseControl.ViewBtnClick(Sender: TObject);
begin
  rc_pan.start;
end;

procedure TMBaseControl.RecordBtnClick(Sender: TObject);
begin
  rc_pan.rec;
end;

procedure TMBaseControl.RegistratorsLVDblClickProcess(item: TListItem;
  lv: TListView);
var
  c: TRConnection;
begin
  if RStateStop then
  begin
    if RcClientFrm <> nil then
    begin
      RcClientFrm.editConnection(TRConnection(item.data));
      c := RcClientFrm.m_curConnection;
      c.OnDelete := doDeleteRConnection;
    end;
  end;
  showRegistrators;
end;

procedure InitPropSG(sg: tstringgrid);
begin
  sg.FixedCols := 0;
  sg.FixedRows := 1;
  sg.Options := sg.Options + [goediting] + [gocolsizing];
  sg.rowcount := 2;
  sg.ColCount := 2;
  sg.Cells[c_col_propName, 0] := 'Свойство';
  sg.Cells[c_col_propVal, 0] := 'Значение';
end;

end.
