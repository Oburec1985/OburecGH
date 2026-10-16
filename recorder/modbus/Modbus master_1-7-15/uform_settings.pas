unit UForm_Settings;

{$mode ObjFPC}{$H+}{$codepage UTF8}

interface

uses
  Windows, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ucommon, recorder, plugin, pluginclass, modbusdevice, ufrm_Settings,
  ufrm_protocol, uFrmSimple, Buttons, ComCtrls, dom, XMLRead, XMLWrite,
  uXMLFunc, LazSerial, uFrmAbout, dlgNodeCopy, dlgConfSelect, uUpdatable, LazUTF8,
  libbinres, resstr, ULogger, UProtManager, LCLTranslator, ufrm_bus, ufrm_device, ufrm_value; //in 'c:\lazarus_x86\lcl\lcltranslator.pas';

const
  WM_TX = WM_USER + $40;
  WM_RX = WM_USER + $41;
  WM_MSG = WM_USER + $42;

  SETTINGS_FNAME = 'c:\Mera Files\modbus.xml';

  //Папка файлов перевода
  //Для отладки, чтобы не копировать файлы
  //LANGFOLDER = 'H:\lazproj\Modbus master\languages';

  //Для работы
  LANGFOLDER = 'C:\Mera Files\Modbus lang';
type

  { TFrm_Settings }

  TRxTxParams = record
  Bus: TBus;
  RecTimeCounter: Double;
  Device: TModbusDevice;
  data: TBytes;
  leng: integer;
  end;

  PRxTxParams = ^TRxTxParams;

  TMsgParams = record
  Bus: TBus;
  Msg: string;
  end;

  PMsgParams = ^TMsgParams;




  { TForm_Settings }

  TForm_Settings = class(TForm)
    btnApply: TBitBtn;
    chbLog: TCheckBox;
    chbStart: TCheckBox;
    cbLang: TComboBox;
    ImageList1: TImageList;
    imlTree: TImageList;
    lAbout: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    MemMsg: TMemo;
    sbtnSettings: TSpeedButton;
    sbtnListing: TSpeedButton;
    btnStart: TSpeedButton;
    btnImport: TSpeedButton;
    Splitter1: TSplitter;
    Timer1: TTimer;
    procedure cbLangChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lAboutClick(Sender: TObject);
    procedure sbtnSettingsClick(Sender: TObject);
    procedure sbtnListingClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnImport_Click(Sender: TObject);
    procedure btnStart_Click(Sender: TObject);

  protected
  procedure CreateWnd; override;

  private
  fSettingsFrame: TFrm_Settings;
  fProtocolFrame: TFrm_Protocol;
  fCurrentFrame: TFrmSimple;
  fStarted: boolean;
  fInConfigMode: boolean;
  fPlugin: TTestPlugin;

  current_lang: string; //Текущий язык для перевода
    { Private declarations }
  procedure PortDataRx(Sender: TObject; Device: TModbusDevice; data: TBytes; leng: integer);
  procedure PortDataTx(Sender: TObject; Device: TModbusDevice; data: TBytes; leng: integer);
  function getStarted: boolean;
  procedure ProtocolReady(Sender: TObject);
  procedure SetStarted(const Value: boolean);
  procedure sLabel1Click(Sender: TObject);
  function getFrmSettings: Tfrm_settings;
  function getProtocolFrame: TFrm_protocol;
    function getPlugin: TTestPlugin;
    procedure setPlugin(const Value: TTestPlugin);
    function getInConfigMode: boolean;


    procedure setInConfigMode(const Value: boolean);
    procedure RxMsg(var M: TMessage); message WM_RX;
    procedure TranslateAll(lang: string);
    procedure TxMsg(var M: TMessage); message WM_TX;
    procedure Process_Message(Sender: TObject; Msg: string);
    procedure ProcMessage(var M: TMessage); message WM_MSG;
    procedure processPluginMessage(var Message: TMessage); message WM_PLUGIN_MSG;
    procedure UpdateVersion;

  public
  procedure ecm;
  procedure lcm;

  procedure AssignRTUBusEvents(bus: TBus);
  procedure SaveSettings;
  procedure LoadSettings(confname: string);
    { Public declarations }
  destructor Destroy; override;
  constructor Create(plugin: TTestPlugin); reintroduce;
  procedure ActivateFrame(frame: TFrmSimple; reactivate: boolean = false);
  property Started: boolean read getStarted write setStarted;
  property Plugin: TTestPlugin read fPlugin write setPlugin;
  property ProtocolFrame: TFrm_Protocol read fProtocolFrame;
  property SettingsFrame: Tfrm_Settings read fSettingsFrame;
  property InConfigMode: boolean read fInConfigMode write setInConfigMode;
  end;

var
  Form_Settings: TForm_Settings;

  buf_str: string;

implementation

{$R *.lfm}


{ TForm_Settings }

procedure TForm_Settings.CreateWnd;
begin
  inherited;
  fSettingsFrame.Recorder := self.Plugin.Recorder;
  {fSettingsFrame := TFrm_Settings.Create(self);
  fSettingsFrame.Recorder := self.Plugin.Recorder;
  fSettingsFrame.ParentForm := self;
  fSettingsFrame.Align := alClient;

  fProtocolFrame := TFrm_Protocol.Create(self);
  fProtocolFrame.Align := alClient;

  ActivateFrame(fSettingsFrame);}
end;

procedure TForm_Settings.TranslateAll(lang: string);
var
  curr_index: integer;
begin
  case lang of
    'ru':  begin
           SetDefaultLang('ru', LANGFOLDER, 'plgModbusMaster');
           cbLang.ItemIndex := 0;
           //SetDefaultLang('', 'C:\Mera Files\Modbus lang');
           end;

    'en':  begin
           SetDefaultLang('en', LANGFOLDER, 'plgModbusMaster');
           cbLang.ItemIndex := 1;
           end;
  end;

  fSettingsFrame.tvDevices.Items.GetFirstNode.Text := rsSystem;

  curr_index := fSettingsFrame.FrmValue.cbByteOrder.ItemIndex;
  fSettingsFrame.FrmValue.cbByteOrder.Items.Clear;

  //Набиваем комбобокс переведенными строками
  //Старшим байтом вперед
  //Старшим словом вперед
  //Старшим двойным словом вперед
  //Без корректировки

  fSettingsFrame.FrmValue.cbByteOrder.AddItem(rsBigEndian, nil);
  fSettingsFrame.FrmValue.cbByteOrder.AddItem(rsGrandWord, nil);
  fSettingsFrame.FrmValue.cbByteOrder.AddItem(rsGrandDoubleWord, nil);
  fSettingsFrame.FrmValue.cbByteOrder.AddItem(rsReverse, nil);
  fSettingsFrame.FrmValue.cbByteOrder.AddItem(rsNoCorrection, nil);
  fSettingsFrame.FrmValue.cbByteOrder.ItemIndex := curr_index;

  //Обновить версию формы
  UpdateVersion;

  frmAbout.UpdateVersion;

end;

procedure TForm_Settings.LoadSettings(confname: string);
var
  doc: TXMLDocument;
  lognode, root, langnode, node, confnode, connode: TDOMNode;
  buslst, devlst, taglst: TDOMNodeList; //Коллекции узлов шин, устройств, тэгов
  writelog: boolean;
  address, pausedelay, i, j, k: integer;
  name_, descr: AnsiString;
  bustype: TProtocolType;
  t_root, t_bus, t_device, t_tag: TTreeNode; //Корневой узел дерева отображения, узел шины, устройства и тэга соответственно (дерево отображения)
  region: TMemRegion; //Область памяти тэга (Input или Holding)
  DataType: TDataType;
  ByteOrder: TByteOrder;
  AccessType: TAccessType;
  AllowGroupWorking, ImidiateWrite, ContiniousWrite: boolean;
  atr_node: TDOMNode;
  bus: TBus;
  tag_: TModbusTag;

  tries: integer;
  enabled_: boolean;
  breakOnTimeout: boolean;
  timeouttimer: integer;
  fs: TFileStream;

  str: string;
begin
t_root := fSettingsFrame.tvDevices.Items.GetFirstNode;
t_root.DeleteChildren;

fSettingsFrame.BusList.Clear;

if not fileexists(SETTINGS_FNAME) then Exit;

doc := TXMLDocument.Create;


fs := TFileStream.Create(SETTINGS_FNAME, fmOpenRead);
ReadXMLFile(doc, fs);
FreeAndNil(fs);


//doc.load(SETTINGS_FNAME);
root := doc.documentElement;
if Assigned(root) then
    begin
    confnode := GetSingleNodeByAttrValue(root, 'Configuration', 'confname', confname);
    //confnode := root.selectSingleNode(format('./Configuration[@confname = "%s"]',[confname]));
    if Assigned(confnode) then
       begin
       lognode := TDOMElement(confnode).FindNode('WriteLog');
       if Assigned(lognode) then
          writelog := StrToBool(lognode.TextContent) else
          writelog := false;
       chbLog.Checked := writelog;

       langnode := TDOMElement(confnode).FindNode('Language');
       if Assigned(langnode) then
          current_lang := langnode.TextContent else
          current_lang := 'ru';

       //case language of
       //  'ru': cbLang.ItemIndex := 0;
       //  'en': cbLang.ItemIndex := 1;
       //end;
       //cbLangChange(nil);
       TranslateAll(current_lang);

       buslst := TDOMElement(confnode).GetElementsByTagName('Bus');

        //buslst := confnode.selectNodes('.//Bus');
        if Assigned(buslst) then
           begin
           ecm;
           for i := 0 to buslst.length - 1 do
               begin
                name_ := buslst.item[i].attributes.getNamedItem('name').nodeValue;
                descr := buslst.item[i].attributes.getNamedItem('description').nodeValue;
                //!!проверить файл настроек!!
                bustype := TProtocolType(StrToInt(buslst.item[i].attributes.getNamedItem('protocol').nodeValue));

                    try
                    pausedelay := StrToInt(buslst.item[i].attributes.getNamedItem('pausedelay').nodeValue);
                    except
                    pausedelay := 50;
                    end;

                case bustype of
                ptRTU: begin
                        fSettingsFrame.BusList.Add(TBusRTU.Create);
                        bus := TBusRTU(fSettingsFrame.BusList.Last);
                        bus.OnMessage := @Process_Message;
                        bus.OnDataSend := @PortDataTx;
                        bus.OnDataRcv := @PortDataRx;
                        bus.WriteLogFlag:= writelog;

                        connode := buslst.item[i].FindNode('connection');
                        if Assigned(connode) then
                           begin
                            //Ищем параметры соединения
                            node := connode.attributes.getNamedItem('portname');
                            if Assigned(node) then TBusRTU(bus).Port.Device := node.nodeValue;

                            node := connode.attributes.getNamedItem('baudrate');
                            if Assigned(node) then
                            begin
                              str := node.nodeValue;
                              if str <> '' then
                              //Необходима конвертация
                              TBusRTU(bus).Port.BaudRate := IntToBaudRate(StrToInt(node.nodeValue))
                              else
                              TBusRTU(bus).Port.BaudRate := TBaudRate.br__9600;
                            end;
                            node := connode.attributes.getNamedItem('parity');
                            if Assigned(node) then TBusRTU(bus).Port.Parity := TParity(StrToInt(node.nodeValue));
                           end;

                       node := buslst.item[i].attributes.getNamedItem('Interchange');
                       if Assigned(node) then TBusRTU(bus).InterchangeFlag := StrToBool(node.nodeValue);
                       end;
                ptTCP: begin //Зарезервировано до появления варианта TCP
                        fSettingsFrame.BusList.Add(TBusTCP.Create);
                        bus := TBusTCP(fSettingsFrame.BusList.Last);
                        bus.OnMessage := @Process_Message;
                        bus.OnDataSend := @PortDataTx;
                        bus.OnDataRcv := @PortDataRx;
                        bus.WriteLogFlag:= writelog;

                        connode := buslst.item[i].FindNode('connection');
                        if Assigned(connode) then
                           begin
                            //Ищем параметры соединения
                            node := connode.attributes.getNamedItem('host');
                            if Assigned(node) then TBusTCP(bus).Connection.Host := node.nodeValue;

                            node := connode.attributes.getNamedItem('port');
                            if Assigned(node) then TBusTCP(bus).Connection.Port := StrToInt(node.nodeValue);
                           end;
                        node := buslst.item[i].attributes.getNamedItem('Interchange');
                        if Assigned(node) then TBusRTU(bus).InterchangeFlag := StrToBool(node.nodeValue);
                       end;
                end;
                fSettingsFrame.BusList.Last.Name := name_;
                fSettingsFrame.BusList.Last.Description := descr;
                fSettingsFrame.BusList.Last.PauseDelay := pausedelay;

                t_bus := fSettingsFrame.tvDevices.Items.AddChild(t_root, name_);

                case fSettingsFrame.BusList.Last.ProtocolType of
                  ptRTU: t_bus.ImageIndex := 4;
                  ptTCP: t_bus.ImageIndex := 3;
                end;
                t_bus.SelectedIndex := t_bus.ImageIndex;

                //Загружаем устройства на шине
                //devlst := buslst.item[i].selectNodes('./ModbusDevice');
                devlst := TDOMElement(buslst.item[i]).GetElementsByTagName('ModbusDevice');
                if Assigned(devlst) then
                begin
                for j := 0 to devlst.length - 1 do
                    begin
                    name_ := devlst.item[j].attributes.getNamedItem('name').nodeValue;
                    descr := devlst.item[j].attributes.getNamedItem('description').nodeValue;
                    address := StrToInt(devlst.item[j].attributes.getNamedItem('address').nodeValue);

                    node := devlst.item[j].attributes.getNamedItem('Tries');
                    if Assigned(node) then tries := StrToInt(node.nodeValue) else tries := 3;

                    node := devlst.item[j].attributes.getNamedItem('Enabled');
                    if Assigned(node) then
                      enabled_ := StrToBool(node.nodeValue)
                    else
                      enabled_ := true;

                    node := devlst.item[j].attributes.getNamedItem('BreakOnTimeout');
                    if Assigned(node) then breakOnTimeout := StrToBool(node.nodeValue) else breakOnTimeout := false;

                    node := devlst.item[j].attributes.getNamedItem('TimerTimeout');
                    if Assigned(node) then timeouttimer := StrToInt(node.nodeValue) else timeouttimer := 500;

                    fSettingsFrame.BusList.Items[i].Items.Add(TModbusDevice.Create(fSettingsFrame.BusList.Items[i], address));
                    fSettingsFrame.BusList.Items[i].Items[j].Name := name_;
                    fSettingsFrame.BusList.Items[i].Items[j].Description := descr;
                    fSettingsFrame.BusList.Items[i].Items[j].Tries := tries;
                    fSettingsFrame.BusList.Items[i].Items[j].Enabled := enabled_;
                    fSettingsFrame.BusList.Items[i].Items[j].BreakOnTimeout := breakOnTimeout;
                    fSettingsFrame.BusList.Items[i].Items[j].TimerTimeout := timeouttimer;

                    t_device := fSettingsFrame.tvDevices.Items.AddChild(t_bus, name_);
                    if fSettingsFrame.BusList.Items[i].Items[j].Enabled then
                       t_device.ImageIndex := 6 else
                       t_device.ImageIndex := 7;
                    t_device.SelectedIndex := t_device.ImageIndex;

                    //Загружаем тэги утройства
                    //taglst := devlst.item[j].selectNodes('./Tag');
                    taglst := TDOMElement(devlst.item[j]).GetElementsByTagName('Tag');
                    if Assigned(taglst) then
                        begin
                        for k := 0 to taglst.length - 1 do
                            begin
                            atr_node := taglst.item[k].attributes.getNamedItem('name');
                            if Assigned(atr_node) then name_ := atr_node.nodeValue;
                            atr_node := taglst.item[k].attributes.getNamedItem('description');
                            if Assigned(atr_node) then descr := atr_node.nodeValue;
                            atr_node := taglst.item[k].attributes.getNamedItem('address');
                            if Assigned(atr_node) then address := StrToInt(atr_node.nodeValue);
                            atr_node := taglst.item[k].attributes.getNamedItem('MemRegion');
                            if Assigned(atr_node) then region := TMemRegion(StrToInt(atr_node.nodeValue));
                            atr_node := taglst.item[k].attributes.getNamedItem('DataType');
                            if Assigned(atr_node) then DataType := TDataType(StrToInt(atr_node.nodeValue));
                            atr_node := taglst.item[k].attributes.getNamedItem('ByteOrder');
                            if Assigned(atr_node) then ByteOrder := TByteOrder(StrToInt(atr_node.nodeValue));
                            atr_node := taglst.item[k].attributes.getNamedItem('AccessType');
                            if Assigned(atr_node) then AccessType := TAccessType(StrToInt(atr_node.nodeValue));
                            atr_node := taglst.item[k].attributes.getNamedItem('ContiniousWrite');
                            if Assigned(atr_node) then ContiniousWrite := StrToBool(atr_node.nodeValue);
                            atr_node := taglst.item[k].attributes.getNamedItem('ImidiateWrite');
                            if Assigned(atr_node) then ImidiateWrite := StrToBool(atr_node.nodeValue);
                            atr_node := taglst.item[k].attributes.getNamedItem('GroupWorking');
                            AllowGroupWorking := false;
                            if Assigned(atr_node) then AllowGroupWorking := StrToBool(atr_node.nodeValue);

                            tag_ := TModbusTag.Create(fSettingsFrame.BusList.Items[i].Items[j], name_, region, address, DataType, ByteOrder, AllowGroupWorking);
                            tag_.AccessType := AccessType;
                            tag_.Description := descr;
                            tag_.ContiniousWrite := ContiniousWrite;
                            tag_.ImidiateWrite := ImidiateWrite;
                            tag_.OnValueChanged := @fSettingsFrame.TagValueChanged;
                            fSettingsFrame.BusList.Items[i].Items[j].Tags.Add(tag_);

                            fSettingsFrame.AddValue(t_device, name_, descr, false);
                            end;
                        end;
                    end;
                end;
               end;
               lcm;
           end;
       end;
    end;
end;

procedure TForm_Settings.ecm;
begin
  if not fInConfigMode then
        fPlugin.Recorder.EnterConfigMode(fPlugin, 0);
    fInConfigMode := true;
end;

procedure TForm_Settings.lcm;
var
  param: integer;
begin
    if fInConfigMode then
      begin
        // говорим рекордеру, чтобы обновил все списки тегов
        //RS_CONFIGCHANGED
        if fPlugin.Recorder.CheckState(RS_CONFIGCHANGED) then
        begin
        param := SCF_TAGSLIST or SCF_TAGSCONTENT;
        fPlugin.Recorder.SetProperty(RCPROP_CHANGEDSETTINGS, param);
        end;
        fPlugin.Recorder.LeaveConfigMode(fPlugin, 0);
     end;
    fInConfigMode := false;
end;

procedure TForm_Settings.AssignRTUBusEvents(bus: TBus);
begin
  bus.OnDataSend := @PortDataTx;
  bus.OnDataRcv := @PortDataRx;
  bus.OnMessage := @Process_Message;
end;


procedure  TForm_Settings.ActivateFrame(frame: TFrmSimple; reactivate: boolean = false);
begin
 { if fCurrentFrame = frame then Exit;

  if Assigned(fCurrentFrame) then
     fCurrentFrame.visible := false;

  fCurrentFrame := frame;

  if Assigned(fCurrentFrame) then
     begin
      fCurrentFrame.Visible := true;
     end;   }

  if (fCurrentFrame = frame) and not reactivate then Exit;

  if Assigned(fCurrentFrame) then
     fCurrentFrame.Parent := nil;

  fCurrentFrame := frame;

  if Assigned(fCurrentFrame) then
     begin
      fCurrentFrame.Align := alClient;
      fCurrentFrame.Parent := self;
     end;
end;

constructor TForm_Settings.Create(plugin: TTestPlugin);
begin
  inherited Create(nil);

  fSettingsFrame := TFrm_Settings.Create(self);
  //fSettingsFrame.Recorder := self.Plugin.Recorder;
  fSettingsFrame.ParentForm := self;
  fSettingsFrame.Align := alClient;

  fProtocolFrame := TFrm_Protocol.Create(self);
  fProtocolFrame.Align := alClient;

  ActivateFrame(fSettingsFrame);

  fInConfigMode := false;
  fPlugin := plugin;
  ProtManager.OnProtocolReady := @ProtocolReady;
end;

destructor TForm_Settings.Destroy;
begin
  FreeAndNil(fSettingsFrame);
  FreeAndNil(fProtocolFrame);
  inherited;
end;

procedure TForm_Settings.ProtocolReady(Sender: TObject);
begin
  fProtocolFrame.memProtocol.Lines.Add(trim(ProtManager.Str));
  ProtManager.Clear;
end;

procedure TForm_Settings.UpdateVersion;
var
 //Стандартные средства не позволяют прочитать версию dll файла
 //пришлось использовать библиотеку libbinres (найден исходник польского автора)
 inf: TAppVersionInfo;
begin
  inf := TAppVersionInfo.Create;
  inf.Reload;
  Caption := Caption + format(rsVers, [inf.VersionStr]);
  screen.HintFont.size := 12;
  inf.Free;
end;

procedure TForm_Settings.FormCreate(Sender: TObject);
begin
  UpdateVersion;
  MemMsg.Clear;
end;


procedure TForm_Settings.cbLangChange(Sender: TObject);
begin

  case cbLang.ItemIndex of
    0: current_lang := 'ru';
    1: current_lang := 'en';
  end;

  TranslateAll(current_lang);
  if Assigned(fCurrentFrame) then
        begin
        if (fCurrentFrame is TFrm_Settings) and Assigned(TFrm_Settings(fCurrentFrame).ActiveFrame) then
           TFrm_Settings(fCurrentFrame).ActiveFrame.UpdateHmi;
        //if (fCurrentFrame is TFrm_Device) then TFrm_Device(fCurrentFrame).UpdateHmi;
        //if (fCurrentFrame is TFrm_Value) then TFrm_Value(fCurrentFrame).UpdateHmi;
        end;
  //case cbLang.ItemIndex of
  //  0: SetDefaultLang('ru', 'C:\Mera Files\Modbus lang', 'ru.mo');
  //  1: SetDefaultLang('en', 'C:\Mera Files\Modbus lang', 'en.mo');
  //end;
end;

procedure TForm_Settings.sbtnSettingsClick(Sender: TObject);
begin
  ActivateFrame(fSettingsFrame);
end;

procedure TForm_Settings.sbtnListingClick(Sender: TObject);
begin
  //ClearMyMessages;
  ActivateFrame(fProtocolFrame);
end;


procedure TForm_Settings.Process_Message(Sender: TObject; Msg: string);
var
p: PMsgParams;
begin
  if Sender is TBus then
     begin
      p := new(PMsgParams);
      //p^.Bus := TBusRtu(Sender);
      p^.Bus := TBus(Sender);
      p^.Msg := Msg;
      PostMessage(Self.Handle, WM_MSG, 0, Integer(p));
       //MemMsg.Lines.Add(TimeToStr(now) + ' Шина: ' + TBus(Sender).Name + '; ' + Msg);
     end;
end;

procedure TForm_Settings.ProcMessage(var M: TMessage);
var
p: PMsgParams;
msg: string;
begin
  p := PMsgParams(M.LParam);
  msg := p^.Msg;
  MemMsg.Lines.Add(TimeToStr(now) + rsBus + p^.Bus.Name + '; ' + msg);
  Dispose(p);
end;

procedure TForm_Settings.PortDataRx(Sender: TObject; Device: TModbusDevice; data: TBytes; leng: integer);
var
p: PRxTxParams;
begin
if (TBus(Sender).InterchangeFlag) and (Device.InterchangeFlag) then
  begin

  p := new(PRxTxParams);
  //p^.Bus := TBusRtu(Sender);
  p^.Bus := TBus(Sender);
  p^.Device := Device;
  p^.RecTimeCounter := fPlugin.Recorder.GetTimeCounter;
  p^.data := data;
  //setlength(p^.data, length(data));
  //move(data[0], p^.data[0], length(data));
  p^.leng := leng;

  PostMessage(Self.Handle, WM_RX, 0, Integer(p));
  //SendNotifyMessage(Self.Handle, WM_RX, 0, Integer(p));
  //SendMessageTimeout(Self.Handle, WM_RX, 0, Integer(p), 0, 1, @rez);
  //fProtocolFrame.memProtocol.Lines.Add(format('Шина: %s, Устройство: %s, Ответ: %s', [TBusRtu(Sender).Name, Device.Name, DataToStr(data)]));
 end;
end;

procedure TForm_Settings.PortDataTx(Sender: TObject; Device: TModbusDevice; data: TBytes; leng: integer);
var
p: PRxTxParams;
begin
if (TBus(Sender).InterchangeFlag) and (Device.InterchangeFlag) then
  begin

  p := new(PRxTxParams);
  //p^.Bus := TBusRtu(Sender);
  p^.Bus := TBus(Sender);
  p^.Device := Device;
  p^.RecTimeCounter := fPlugin.Recorder.GetTimeCounter;
  //setlength(p^.data, length(data));
  //move(data[0], p^.data[0], length(data));
  p^.data := data;
  p^.leng := leng;
  PostMessage(Self.Handle, WM_TX, 0, Integer(p));
  //SendNotifyMessage(Self.Handle, WM_TX, 0, Integer(p));
  //SendMessageTimeout(Self.Handle, WM_TX, 0, Integer(p), 0, 1, @rez);
  //fProtocolFrame.memProtocol.Lines.Add(format('Шина: %s, Устройство: %s, Запрос: %s', [TBusRtu(Sender).Name, Device.Name, DataToStr(data)]));
  end;
end;

procedure TForm_Settings.processPluginMessage(var Message: TMessage);
begin
case Message.WParam of
      PN_ENTERRCCONFIG: begin // Рекордер перешел в режим настройки
         //В то время пока производится изменение настройки,
         // теги недоступны (потому, что они могут удаляться)
          //сообщить форме о начале изменения настройки
      InConfigMode := true;
      end;

      PN_RCSAVECONFIG: begin // Рекордер сохранил конфигурацию
        SaveSettings;
      end;


      PN_LEAVERCCONFIG: begin
         InConfigMode := false;
      end;

      PN_RCLOADCONFIG: begin // Рекордер загрузил конфигурацию
         LoadSettings(fPlugin.ConfigName);
      end;

       PN_RCSTOP: begin
         if not Started then Exit;
         Started := false;
         fPlugin.UninitDataAccess;
      end;

      PN_RCSTART: begin
         if Started then Exit;
         Started := true;

         //UnInitDataAccess;
         ////fPlugin.UninitDataAccess;
         fPlugin.InitDataAccess;
      end;
      end;
end;

procedure TForm_Settings.Timer1Timer(Sender: TObject);
begin
  //CheckKey;
end;

procedure TForm_Settings.TxMsg(var M: TMessage);
var
p: PRxTxParams;
str: string;
logger: TLogger;
begin
  p := PRxTxParams(M.LParam);
 // if Assigned(fProtocolFrame.Parent) then
     begin
     str := format(rsTxMsg,
        [p^.RecTimeCounter, p^.Bus.Name, p^.Device.Name, copy(DataToStr(p^.data, p^.leng), 1, p^.leng * 2)]);
     //if chbLog.Checked then LogMsg('c:\mera files\modbuslog.txt', str);
     if chbLog.Checked then TLogger.getInstance(LOG_PATH).LogMsg(str);
     ProtManager.AddStr(str);
     //fProtocolFrame.memProtocol.Lines.Add(str);
     end;
  Dispose(p);
end;

procedure TForm_Settings.RxMsg(var M: TMessage);
var
p: PRxTxParams;
str: string;
begin
  p := PRxTxParams(M.LParam);
//  if Assigned(fProtocolFrame.Parent) then
    begin
    str := format(rsRxMsg,
       [p^.RecTimeCounter, p^.Bus.Name, p^.Device.Name, DataToStr(p^.data, p^.leng)]);
    //if chbLog.Checked then LogMsg('c:\mera files\modbuslog.txt', str);
    if chbLog.Checked then TLogger.getInstance(LOG_PATH).LogMsg(str);
    //fProtocolFrame.memProtocol.Lines.Add(str);
    ProtManager.AddStr(str);
    end;
  Dispose(p);
end;
procedure TForm_Settings.FormDestroy(Sender: TObject);
begin
  SaveSettings;
end;


procedure TForm_Settings.FormShow(Sender: TObject);
begin
  ActivateFrame(fSettingsFrame);
end;

function TForm_Settings.getFrmSettings: Tfrm_settings;
begin
  result := fSettingsFrame;
end;

function TForm_Settings.getInConfigMode: boolean;
begin
  result := fInConfigMode;
end;

function TForm_Settings.getPlugin: TTestPlugin;
begin
  result := fPlugin;
end;

function TForm_Settings.getProtocolFrame: TFrm_protocol;
begin
  result := fProtocolFrame;
end;

function TForm_Settings.getStarted: boolean;
begin
  result := fStarted;
end;

//---------------------------------------------------------------------------
procedure TForm_Settings.lAboutClick(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TForm_Settings.btnImport_Click(Sender: TObject);
var
  confname: string;
begin
  if not fileexists(SETTINGS_FNAME) then
     begin
       ShowMessage(rsConfNotFound);
       Exit;
     end;

  //Импорт настроек из другой конфигурации
  if dlg_ConfSelect.ShowModal = mrOk then
  begin
    fSettingsFrame.Clear;
    confname := dlg_ConfSelect.grd.Rows[dlg_ConfSelect.grd.Selection.Top][0];
    LoadSettings(confname);
    //if fSettingsFrame.Recorder.GetState then
    //fSettingsFrame.Recorder.PushState(RS_CONFIGCHANGED);
  end;
end;



procedure TForm_Settings.btnStart_Click(Sender: TObject);
begin
   {if fInConfigMode then
   begin
   ShowMessage('Программа в режиме настройки. Запуск невозможен!');
   exit;
   end;  }

   if not Started then
      begin
        fPlugin.StartMeasure;
        //Started := true;
      end else
      begin
        fPlugin.StopMeasure;
        //Started := false;
      end;
end;

procedure TForm_Settings.SaveSettings;
  var
  doc: TXMLDocument;
  root: TDOMNode;
  attr: TDOMNode;
  lognode, langnode, confnode, busnode, devicenode, tagnode, node: TDOMNode;
  i, j, k: integer;
  fs: TFileStream;
  enabled_: boolean;
begin
  doc := TXMLDocument.Create;

  //Проверяем наличие файла настроек
  //Если файл найден, загружаем его содержимое, в противном случае, начинаем с создания корневого узла
  if fileexists(SETTINGS_FNAME) then
      begin
      fs := TFileStream.Create(SETTINGS_FNAME, fmOpenRead);
      ReadXMLFile(doc, fs);
      FreeAndNil(fs);
      end
    else
    //doc.TextContent := '<Settings/>';
  begin
  node := doc.CreateElement('Settings');
  doc.AppendChild(node);
  end;

  root := doc.DocumentElement;

  //Ищем старую настройку и стераем ее если находим
  //confnode := GetNodeByAttrValue(root, 'Configuration', 'confname', fPlugin.ConfigName);
  confnode := GetSingleNodeByAttrValue(root, 'Configuration', 'confname', fPlugin.ConfigName);
  if Assigned(confnode) then
    root.removeChild(confnode);

  //Создаем узел настройки
  confnode := doc.createElement('Configuration');

  //Сохраняем название конфигурации
  attr := doc.createAttribute('confname');
  attr.NodeValue := fPlugin.ConfigName;
  confnode.attributes.setNamedItem(attr);
  //FreeAndNil(attr);

  //Сохраняем язык
  langnode := doc.createElement('Language');
  langnode.AppendChild(doc.CreateTextNode(current_lang));

  confnode.AppendChild(langnode);

  lognode := doc.createElement('WriteLog');
  lognode.AppendChild(doc.CreateTextNode(BoolToStr(chbLog.Checked)));
  confnode.AppendChild(lognode);

  try
  for i := 0 to fSettingsFrame.BusList.Count - 1 do
     begin
     busnode := doc.createElement('Bus');

     //Сохраняем название шины
     attr := doc.createAttribute('name');
     attr.NodeValue := fSettingsFrame.BusList.Items[i].Name;
     busnode.attributes.setNamedItem(attr);
     //FreeAndNil(attr);

     //Сохраняем описание шины
     attr := doc.createAttribute('description');
     attr.NodeValue := fSettingsFrame.BusList.Items[i].Description;
     busnode.attributes.setNamedItem(attr);
     //FreeAndNil(attr);

     //Сохраняем тип соединения (RTU или TCP)
     attr := doc.createAttribute('protocol');
     attr.NodeValue := IntToStr(Integer(fSettingsFrame.BusList.Items[i].ProtocolType));
     busnode.attributes.setNamedItem(attr);
     //FreeAndNil(attr);

     //Сохраняем длительность паузы между запросами на один адрес
     attr := doc.createAttribute('pausedelay');
     attr.NodeValue := IntToStr(fSettingsFrame.BusList.Items[i].PauseDelay);
     busnode.attributes.setNamedItem(attr);
     //FreeAndNil(attr);

     //В зависимости от того какой тип протокола у шины сохраняем данные о соединении.
     //Номер порта, ip-адрес и пр.
     case fSettingsFrame.BusList.Items[i].ProtocolType of
       ptRTU: begin
         node := doc.createElement('connection');

         attr := doc.createAttribute('type');
         attr.NodeValue := 'serial';
         node.attributes.setNamedItem(attr);
         //FreeAndNil(attr);

         attr := doc.createAttribute('portname');
         attr.NodeValue := TBusRTU(fSettingsFrame.BusList.Items[i]).Port.Device;
         node.attributes.setNamedItem(attr);
         //FreeAndNil(attr);

         attr := doc.createAttribute('baudrate');
         case TBusRTU(fSettingsFrame.BusList.Items[i]).Port.BaudRate of
         br__2400: attr.NodeValue := '2400';
         br__4800: attr.NodeValue := '4800';
         br__9600: attr.NodeValue := '9600';
         br_19200: attr.NodeValue := '19200';
         br_38400: attr.NodeValue := '38400';
         br_57600: attr.NodeValue := '57600';
         br115200: attr.NodeValue := '115200';
         end;

         node.attributes.setNamedItem(attr);
         //FreeAndNil(attr);

         attr := doc.createAttribute('parity');
         attr.NodeValue := IntToStr(Integer(TBusRTU(fSettingsFrame.BusList.Items[i]).Port.Parity));
         node.attributes.setNamedItem(attr);
         //FreeAndNil(attr);

         attr := doc.createAttribute('Interchange');
         attr.NodeValue := IntToStr(Integer(TBusRTU(fSettingsFrame.BusList.Items[i]).InterchangeFlag));
         node.attributes.setNamedItem(attr);
         //FreeAndNil(attr);

         busnode.appendChild(node);
       end;

       ptTCP: begin
         node := doc.createElement('connection');

         attr := doc.createAttribute('type');
         attr.NodeValue := 'ethernet';
         node.attributes.setNamedItem(attr);
         //FreeAndNil(attr);

         attr := doc.createAttribute('host');
         attr.NodeValue := TBusTCP(fSettingsFrame.BusList.Items[i]).Connection.Host;
         node.attributes.setNamedItem(attr);
         //FreeAndNil(attr);

         attr := doc.createAttribute('port');
         attr.NodeValue := IntToStr(TBusTCP(fSettingsFrame.BusList.Items[i]).Connection.Port);
         node.attributes.setNamedItem(attr);
         //FreeAndNil(attr);

         attr := doc.createAttribute('Interchange');
         attr.NodeValue := IntToStr(Integer(TBusTCP(fSettingsFrame.BusList.Items[i]).InterchangeFlag));
         node.attributes.setNamedItem(attr);
         //FreeAndNil(attr);

         busnode.appendChild(node);
       end;
     end;

     //Сохраняем параметры устройств сидящих на шине
     for j := 0 to fSettingsFrame.BusList.Items[i].Items.Count - 1 do
        begin
        devicenode := doc.createElement('ModbusDevice');

        attr := doc.createAttribute('name');
        attr.NodeValue := fSettingsFrame.BusList.Items[i].Items[j].Name;
        devicenode.attributes.setNamedItem(attr);
        //FreeAndNil(attr);

        attr := doc.createAttribute('description');
        attr.NodeValue := fSettingsFrame.BusList.Items[i].Items[j].Description;
        devicenode.attributes.setNamedItem(attr);
        //FreeAndNil(attr);

        attr := doc.createAttribute('address');
        attr.NodeValue := IntToStr(fSettingsFrame.BusList.Items[i].Items[j].Address);
        devicenode.attributes.setNamedItem(attr);
        //FreeAndNil(attr);

        attr := doc.createAttribute('Interchange');
        attr.NodeValue := IntToStr(Integer(fSettingsFrame.BusList.Items[i].Items[j].InterchangeFlag));
        devicenode.attributes.setNamedItem(attr);
        //FreeAndNil(attr);

        attr := doc.createAttribute('Enabled');
        enabled_ := fSettingsFrame.BusList.Items[i].Items[j].Enabled;
        attr.NodeValue := BoolToStr(enabled_);
        devicenode.attributes.setNamedItem(attr);
        //FreeAndNil(attr);

        attr := doc.createAttribute('Tries');
        attr.NodeValue := IntToStr(fSettingsFrame.BusList.Items[i].Items[j].Tries);
        devicenode.attributes.setNamedItem(attr);
        //FreeAndNil(attr);

        attr := doc.createAttribute('BreakOnTimeout');
        attr.NodeValue := IntToStr(Integer(fSettingsFrame.BusList.Items[i].Items[j].BreakOnTimeout));
        devicenode.attributes.setNamedItem(attr);
        //FreeAndNil(attr);

        attr := doc.createAttribute('TimerTimeout');
        attr.NodeValue := IntToStr(fSettingsFrame.BusList.Items[i].Items[j].TimerTimeout);
        devicenode.attributes.setNamedItem(attr);
        //FreeAndNil(attr);

        //Сохраняем тэги устройства
        for k := 0 to fSettingsFrame.BusList.Items[i].Items[j].Tags.Count - 1 do
            begin
            tagnode := doc.createElement('Tag');

            attr := doc.createAttribute('name');
            attr.NodeValue := fSettingsFrame.BusList.Items[i].Items[j].Tags[k].Name;
            tagnode.attributes.setNamedItem(attr);
            //FreeAndNil(attr);

            attr := doc.createAttribute('description');
            attr.NodeValue := fSettingsFrame.BusList.Items[i].Items[j].Tags[k].Description;
            tagnode.attributes.setNamedItem(attr);
            //FreeAndNil(attr);

            attr := doc.createAttribute('MemRegion');
            attr.NodeValue := IntToStr(Integer(fSettingsFrame.BusList.Items[i].Items[j].Tags[k].MemRegion));
            tagnode.attributes.setNamedItem(attr);
            //FreeAndNil(attr);

            attr := doc.createAttribute('address');
            attr.NodeValue := IntToStr(fSettingsFrame.BusList.Items[i].Items[j].Tags[k].Addres);
            tagnode.attributes.setNamedItem(attr);
            //FreeAndNil(attr);

            attr := doc.createAttribute('ByteOrder');
            attr.NodeValue :=  IntToStr(Integer(fSettingsFrame.BusList.Items[i].Items[j].Tags[k].ByteOrder));
            tagnode.attributes.setNamedItem(attr);
            //FreeAndNil(attr);

            attr := doc.createAttribute('DataType');
            attr.NodeValue := IntToStr(Integer(fSettingsFrame.BusList.Items[i].Items[j].Tags[k].DataType));
            tagnode.attributes.setNamedItem(attr);
            //FreeAndNil(attr);

            attr := doc.createAttribute('AccessType');
            attr.NodeValue := IntToStr(Integer(fSettingsFrame.BusList.Items[i].Items[j].Tags[k].AccessType));
            tagnode.attributes.setNamedItem(attr);
            //FreeAndNil(attr);

            attr := doc.createAttribute('ContiniousWrite');
            attr.NodeValue := IntToStr(Integer(fSettingsFrame.BusList.Items[i].Items[j].Tags[k].ContiniousWrite));
            tagnode.attributes.setNamedItem(attr);
            //FreeAndNil(attr);

            attr := doc.createAttribute('GroupWorking');
            attr.NodeValue := IntToStr(Integer(fSettingsFrame.BusList.Items[i].Items[j].Tags[k].AllowGroupWorking));
            tagnode.attributes.setNamedItem(attr);
            //FreeAndNil(attr);

            attr := doc.createAttribute('ImidiateWrite');
            attr.NodeValue := IntToStr(Integer(fSettingsFrame.BusList.Items[i].Items[j].Tags[k].ImidiateWrite));
            tagnode.attributes.setNamedItem(attr);
            //FreeAndNil(attr);

            devicenode.appendChild(tagnode);
            end;
        busnode.appendChild(devicenode);
        end;
        confnode.appendChild(busnode);
     end;
  root.appendChild(confnode);
  WriteXMLFile(doc, SETTINGS_FNAME);
  FreeAndNil(confnode);
  FreeAndNil(doc);
  finally

  end;

end;

procedure TForm_Settings.setInConfigMode(const Value: boolean);
begin
  fInConfigMode := Value;
end;

procedure TForm_Settings.setPlugin(const Value: TTestPlugin);
begin
  fPlugin := Value;
end;

procedure TForm_Settings.SetStarted(const Value: boolean);
var
  i: integer;
  image: TBitmap;
begin
  if fStarted = Value then Exit;


  if Value then
      begin
        btnStart.Glyph := nil;
        ImageList1.GetBitmap(0, btnStart.Glyph);

        for i := 0 to fSettingsFrame.BusList.Count - 1 do
           begin
              if not fSettingsFrame.BusList.Items[i].Active then
                begin
                 fSettingsFrame.BusList.Items[i].WriteLogFlag := chbLog.Checked;
                 fSettingsFrame.BusList.Items[i].Active := true;
                end;
           end;

      end else
      begin
        btnStart.Glyph := nil;
        ImageList1.GetBitmap(1, btnStart.Glyph);

        for i := 0 to fSettingsFrame.BusList.Count - 1 do
           begin
           if fSettingsFrame.BusList.Items[i].Active then
             begin
              fSettingsFrame.BusList.Items[i].Active := false;
              fSettingsFrame.BusList.Items[i].WriteLogFlag := chbLog.Checked;
             end;
           end;
      end;

      fStarted := Value;
end;

procedure TForm_Settings.sLabel1Click(Sender: TObject);
begin
  FrmAbout.Show;
end;

end.

