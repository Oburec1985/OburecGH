unit ufrm_Settings;

{$mode ObjFPC}{$H+}{$codepage UTF8}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  Buttons, ExtCtrls, StdCtrls, ComCtrls, Menus,
  recorder in 'interfaces\recorder.pas', strutils, LazUTF8,
  plugin in 'interfaces\plugin.pas', pluginclass,
  tags in 'interfaces\tags.pas', dlgNodeCopy, FrameSettings,
  modbusdevice, uFrmSimple, fgl, ufrm_bus, ufrm_device, ufrm_value, resstr;

const SETTINGS_FNAME = 'c:\Mera Files\modbus.xml';

type

  { TFrm_Settings }

  TBusList = specialize TFPGList<TBus>;

  TRxTxParams = record
  Bus: TBus;
  Device: TModbusDevice;
  data: TBytes;
  end;

  PRxTxParams = ^TRxTxParams;

  TMsgParams = record
  Bus: TBus;
  Msg: string;
  end;

  PMsgParams = ^TMsgParams;

  TFrm_Settings = class(TFrmSimple)
    imlTree: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    btnApply: TSpeedButton;
    Splitter1: TSplitter;
    tvDevices: TTreeView;
    pmTree: TPopupMenu;
    procedure btnApplyClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure tvDevices1Click(Sender: TObject);
    procedure pmTreePopup(Sender: TObject);
    procedure tvDevices1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
    procedure tvDevices1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
    protected
      //procedure CreateWnd; override;

    private
    fBusList: TBusList;
    fCurrentFrame: TFrmSimple; //Ссылка на текущий активный фрейм
    fFrmBus: TFrm_Bus; //Фрейм настройки шины
    fFrmDevice: TFrm_Device; //Фрейм настройки устройства
    fFrmValue: TFrm_Value; //Фрейм настроек значения (тэга)
    fRecorder: IRecorder;
    fParentForm: TForm;

    procedure FrmSettingsTypeChanged(Sender: TObject);
    function FindNodeByName(tv: TTreeView; NodeName: string): TTreeNode;
    function FindNodeByNameAndPointer(tv: TTreeView; NodeName: string; p: Pointer): TTreeNode;
    function FindBusByName(NodeName: string): TBus;
    function FindDeviceByName(bus: TBus; NodeName: string): TModbusDevice;
    function FindTagByName(Device: TModbusDevice; NodeName: string): TModbusTag;
    procedure DeleteAssociation(node: TTreeNode);
    procedure DeleteNodeWithAssociations(node: TTreeNode);
    procedure  ActivateFrame(frame: TFrmSimple);
    function CheckNodeName(treeview: TTreeView; NodeName: string): boolean;
    procedure DeviceNameChanged(Sender: TObject; oldname, newname: AnsiString);
    procedure ValueNameChanged(Sender: TObject; oldname, newname: AnsiString);
    function GenerateNewBusName: AnsiString;
    function GenerateNewDeviceName: AnsiString;
    function GenerateNewTagName: AnsiString;
    function getActiveFrame: TFrmSimple;
    function GetBusList: TBusList;
    procedure SetBusList(const Value: TBusList);
    function getRecorder: IRecorder;
    procedure setRecorder(const Value: IRecorder);
    function getParentFont: TForm;
    procedure setParentForm(const Value: TForm);
    procedure ActivateFrame2(frame: TFrmSimple);
    function CheckNameIsOccupied(checkname: string): boolean;
    function CopyNode(source: TTreeNode): TTreeNode;
    function getNewName(oldName: string): string;
    procedure copynd(parent_: TTreeView; source, target: TTreeNode);
    procedure AddTag(tagname: AnsiString; conf: boolean = true);
    procedure CreateRecorderTag(tagname: AnsiString; describe: AnsiString; conf: boolean = true);
    function getLastPos(substr, str: string): integer;
    function getNameNumber(name_: string): integer;
    function UpdateNameNumber(name_: string; n: integer): string;
    function IsNumber(N : String) : Boolean;
    procedure Copy_Node(source: TTreeNode);
    function AllSelectedAreDevices: boolean;
    function GetMenuItemByName(menu: TPopUpMenu; name_: string): TMenuItem;
    procedure SwitchBus(bus: TBus; enabled_: boolean);

    function GetBusEnabled(bus: TBus): boolean;
    function getNodeByData(parentnode: TTreeNode; data: pointer): TTreeNode;
    procedure TagDescrChanged(Sender: TObject; name_: AnsiString; newdescr: AnsiString);
    procedure TagNameChanged(Sender: TObject; oldname: AnsiString; newname: AnsiString);
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;
    property Recorder: IRecorder read getRecorder write setRecorder;
    property BusList: TBusList read GetBusList write SetBusList;
    procedure AddValue(parentnode: TTreeNode; conf: boolean = true); overload;
    procedure AddValue(parentnode: TTreeNode; tagname: AnsiString; descr: AnsiString; conf: boolean = true); overload;
    procedure TagValueChanged(Sender: TObject);
    procedure ModbusDeviceEnabledChanged(Sender: TObject);
    procedure BusNameChanged(Sender: TObject; oldname: AnsiString; newname: AnsiString);
    procedure Clear;
    //procedure Tfrm_settings.AddValue(parentnode: TTreeNode; tagname: PAnsiChar; descr: AnsiString; conf: boolean = true);
    procedure AddBus;
    procedure AddDevice(parentnode: TTreeNode);
    procedure DeleteBus(bus: TBus);
    procedure DeleteDevice(device: TModbusDevice);
    procedure DeleteTag(tag_: TModbusTag; conf: boolean = true);
    property ParentForm: TForm read getParentFont write setParentForm;
    property FrmBus: TFrm_Bus read fFrmBus;
    property FrmValue: TFrm_Value read fFrmValue;
    property ActiveFrame: TFrmSimple read getActiveFrame;
    { Public declarations }
  end;


var
  Frm_Settings: TFrm_Settings;

implementation

{$R *.lfm}

uses
  UForm_Settings;

{ Tfrm_settings }


//procedure Tfrm_settings.CreateWnd;
//begin
//   inherited;

  {if not Assigned(fFrmBus) then
   begin
   fFrmBus := TFrm_Bus.Create(self);
   fFrmBus.OnTypeChanged := @FrmSettingsTypeChanged;
   fFrmBus.OnNameChanged := @BusNameChanged;
   end;

   if not Assigned(fFrmDevice) then
   fFrmDevice := TFrm_Device.Create(self);
   fFrmDevice.OnTypeChanged := @FrmSettingsTypeChanged;
   fFrmDevice.OnEnabledChanged := @ModbusDeviceEnabledChanged;
   end;

   if not Assigned(fFrmValue) then
   begin
   fFrmValue := TFrm_Value.Create(self);
   fFrmValue.OnTypeChanged := @FrmSettingsTypeChanged;
   end;}

//end;


constructor TFrm_Settings.Create(AOwner: TComponent);
begin
   inherited;
   Name := 'frm_settings';

   fBusList := TBusList.Create;

   if not Assigned(fFrmBus) then
   begin
   fFrmBus := TFrm_Bus.Create(self);
   fFrmBus.OnTypeChanged := @FrmSettingsTypeChanged;
   fFrmBus.OnNameChanged := @BusNameChanged;
   end;

   if not Assigned(fFrmDevice) then
   begin
   fFrmDevice := TFrm_Device.Create(self);
   fFrmDevice.OnTypeChanged := @FrmSettingsTypeChanged;
   fFrmDevice.OnNameChanged := @DeviceNameChanged;
   fFrmDevice.OnEnabledChanged := @ModbusDeviceEnabledChanged;
   end;

   if not Assigned(fFrmValue) then
   begin
   fFrmValue := TFrm_Value.Create(self);
   fFrmValue.OnTypeChanged := @FrmSettingsTypeChanged;
   fFrmDevice.OnNameChanged := @ValueNameChanged;
   end;
end;

procedure TFrm_Settings.ActivateFrame(frame: TFrmSimple);
begin
  if fCurrentFrame = frame then Exit;

  if Assigned(fCurrentFrame) then
     fCurrentFrame.Parent := nil;

  fCurrentFrame := frame;

  if Assigned(fCurrentFrame) then
     begin
      fCurrentFrame.Align := alClient;
      fCurrentFrame.Parent := Panel2;
     end;
end;

procedure TFrm_Settings.ActivateFrame2(frame: TFrmSimple);
begin
  if fCurrentFrame = frame then Exit;

  if Assigned(fCurrentFrame) then
     fCurrentFrame.Visible := false;

  fCurrentFrame := frame;

  if Assigned(fCurrentFrame) then
     begin
      fCurrentFrame.Visible := true;
     end;
end;

function TFrm_Settings.FindBusByName(NodeName: string): TBus;
var
  i: integer;
begin
  for i := 0 to fBusList.Count - 1 do
     begin
       if fBusList.Items[i].Name = NodeName then
          begin
            result := fBusList.Items[i];
            break;
          end;
     end;
end;

function TFrm_Settings.FindDeviceByName(bus: TBus; NodeName: string
  ): TModbusDevice;
var
  i: integer;
begin
result := nil;
  for i := 0 to Bus.Items.Count - 1 do
     begin
       if Bus.Items[i].Name = NodeName then
          begin
            result := Bus.Items[i];
            break;
          end;
     end;
end;

function TFrm_Settings.FindTagByName(Device: TModbusDevice; NodeName: string
  ): TModbusTag;
var
  i: integer;
begin
result := nil;
if not Assigned(device) then exit;

  for i := 0 to Device.Tags.Count - 1 do
     begin
       if Device.Tags[i].Name = NodeName then
          begin
            result := Device.Tags[i];
            break;
          end;
     end;
end;

procedure TFrm_Settings.SwitchBus(bus: TBus; enabled_: boolean);
var
 i: integer;
 device: TModbusDevice;
begin
  for i := 0 to fFrmBus.Bus.Items.Count - 1 do
    begin
    device := fFrmBus.Bus.Items[i];
    //device.Enabled := enabled_;
    //Переключение активного состояния устройства делегировано форме
    //Что-то в этом мне не нравится, по идее не должен интерфейс вертеть логикой
    fFrmDevice.ModbusDevice := device;
    fFrmDevice.chbActive.Checked := enabled_;
    fFrmDevice.ApplySettings;
    end;
end;

function TFrm_Settings.GetBusEnabled(bus: TBus): boolean;
var
  i: integer;
begin
result := false;

  if Assigned(bus) then
    begin
      if bus.Items.Count > 0 then
        begin
        for i := 0 to bus.Items.Count - 1 do
         begin
           result := bus.Items[i].Enabled;
           //Если хоть одно устройство включено, считать, что шина включена
           if result then
           break;
         end;
        end;
    end;
end;

procedure TFrm_Settings.DeleteAssociation(node: TTreeNode);
begin
  case node.Level of
    1: DeleteBus(FindBusByName(node.Text));
    2: DeleteDevice(FindDeviceByName(FindBusByName(node.Parent.Text), node.Text));
    3: DeleteTag(FindTagByName(FindDeviceByName(FindBusByName(node.Parent.Parent.Text),
                    node.Parent.Text), node.Text));
  end;
end;

procedure TFrm_Settings.DeleteNodeWithAssociations(node: TTreeNode);
var
  child: TTreeNode;
begin
  if Assigned(node) then
     begin
     child := node.getFirstChild;
     while Assigned(child) do
        begin
        DeleteNodeWithAssociations(child);
        child := node.getFirstChild;
        end;
     DeleteAssociation(node);
     node := nil;
     end;
end;

procedure TFrm_Settings.Clear;
begin
while tvDevices.Items[0].HasChildren do
 DeleteNodeWithAssociations(tvDevices.Items[0].GetFirstChild);
end;

procedure TFrm_Settings.DeleteBus(bus: TBus);
var
  node: TTreeNode;
  i: integer;
begin
  node := FindNodeByName(tvDevices, bus.Name);
  tvDevices.Items.Delete(node);
  fBusList.Remove(bus);
end;

procedure TFrm_Settings.DeleteDevice(device: TModbusDevice);
var
  bus: TBus;
  node: TTreeNode;
begin
  bus := device.Parent;
  node := FindNodeByName(tvDevices, device.Name);
  tvDevices.Items.Delete(node);
  bus.Items.Remove(device);
end;


function TFrm_Settings.FindNodeByNameAndPointer(tv: TTreeView;
  NodeName: string; p: Pointer): TTreeNode;
var
  i: integer;
begin
  result := nil;
  for i := 0 to tv.Items.Count - 1 do
      begin
        if (tv.Items[i].Text = NodeName) and (tv.Items[i].Data = p) then
           begin
             result := tv.Items[i];
             break;
           end;
      end;
end;

function TFrm_Settings.FindNodeByName(tv: TTreeView; NodeName: string
  ): TTreeNode;
var
  i: integer;
begin
  result := nil;
  for i := 0 to tv.Items.Count - 1 do
      begin
        if tv.Items[i].Text = NodeName then
           begin
             result := tv.Items[i];
             break;
           end;
      end;
end;

procedure TFrm_Settings.DeleteTag(tag_: TModbusTag; conf: boolean);
var
  device: TModbusDevice;
  node: TTreeNode;
  RecorderTag: ITag;
begin
  device := tag_.Parent;
  node := FindNodeByName(tvDevices, tag_.Name);
  tvDevices.Items.Delete(node);

  RecorderTag := ITag(Recorder.GetTagByName(PAnsiChar(UTF8ToWinCP(tag_.Name))));

  if conf then TForm_Settings(Parent).ecm;
  if Assigned(RecorderTag) then
     Recorder.CloseTag(RecorderTag);
  if conf then TForm_Settings(Parent).lcm;

  device.Tags.Remove(tag_);
end;

destructor TFrm_Settings.Destroy;
begin
  FreeAndNil(fFrmBus);
  FreeAndNil(fFrmDevice);
  FreeAndNil(fFrmValue);

  FreeAndNil(fBusList);
  inherited;
end;

procedure TFrm_Settings.TagValueChanged(Sender: TObject);
var
  tag_: TModbusTag;
  rectag: ITag;
  value: double;
  name_: string;
begin

  tag_ := TModbusTag(Sender);

  //if tag.AccessType = atWrite then Exit; //Временный костыль, что бы при записи в тэг не происходили рекурсивные вызовы

  rectag := ITag(Recorder.GetTagByName(PAnsiChar(UTF8ToWinCP(tag_.Name))));

  case tag_.DataType of
  dtBool: if tag_.ValueBool then value := 1 else value := 0;
  dtInt16: value := tag_.ValueInt16;
  dtUInt16: value := tag_.ValueUInt16;
  dtUInt32: value := tag_.ValueUInt32;
  dtInt32: value := tag_.ValueInt32;
  dtSingle: value := tag_.ValueSingle;
  dtDouble: value := tag_.ValueDouble;
  end;

  if Assigned(rectag) then
     //rectag.PushValue(value, now);
     rectag.PushValue(value, -1);
end;

function TFrm_Settings.AllSelectedAreDevices: boolean;
var
  i: integer;
  k: boolean;
begin
  for i := 0 to tvDevices.SelectionCount - 1 do
  begin
  k := tvDevices.Selections[i].Level = 2;
  if not k then break;
  end;

  result := k;
end;

function TFrm_Settings.GetMenuItemByName(menu: TPopUpMenu; name_: string
  ): TMenuItem;
var
  i: integer;
  mi: TMenuItem;
begin
  mi := nil;
  for i:= 0 to menu.Items.Count - 1 do
     begin
       if menu.Items[i].Name = name_ then
        begin
        mi := menu.Items[i];
        break;
        end;
     end;
  result := mi;
end;

procedure TFrm_Settings.pmTreePopup(Sender: TObject);
var
  mi: TMenuItem;
begin
  inherited;
  if tvDevices.SelectionCount = 0 then exit;

  mi := GetMenuItemByName(pmTree, 'MenuItem6');
  if Assigned(mi) then
     begin
     mi.Visible := AllSelectedAreDevices;
     if (fCurrentFrame is Tfrm_device) and Assigned(fFrmDevice.ModbusDevice) and fFrmDevice.ModbusDevice.Enabled then
        mi.Caption := rsDisableDevice else
        mi.Caption := rsEnableDevice;
     end;

  mi := GetMenuItemByName(pmTree, 'MenuItem7');
  if Assigned(mi) then
     begin
     mi.Visible := (tvDevices.Selected.Level = 1); //выбрана шина
     if (fCurrentFrame is Tfrm_bus) and Assigned(fFrmBus.Bus) and GetBusEnabled(fFrmBus.Bus) then
        mi.Caption := rsDisableBus else
        mi.Caption := rsEnableBus;
     end;
end;

procedure TFrm_Settings.AddBus;
var
  parentnode: TTreeNode;
  node: TTreeNode;
  name_: string;
begin
  parentnode := tvDevices.Items.GetFirstNode;
  name_ := GenerateNewBusName;
  node := tvDevices.Items.AddChild(parentnode, name_);
  tvDevices.Select(node);
  tvDevices.Selected.ImageIndex := 4;
  tvDevices.Selected.SelectedIndex := 4;
  tvDevices.Selected.StateIndex := 4;
  fBusList.Add(TBusRTU.Create);
  fBusList.Last.Name := name_;
  if fBusList.Last.ProtocolType = ptRTU then
     begin
     TForm_Settings(Parent).AssignRTUBusEvents(TBusRTU(fBusList.Last));
     end;
end;

procedure TFrm_Settings.AddDevice(parentnode: TTreeNode);
var
  node: TTreeNode;
  name_: string;
begin
  name_ := GenerateNewDeviceName;
  node := tvDevices.Items.AddChild(parentnode, GenerateNewDeviceName);
  tvDevices.Select(node);
  tvDevices.Selected.ImageIndex := 6;
  tvDevices.Selected.SelectedIndex := 6;
  tvDevices.Selected.StateIndex := 6;
  fBusList.Items[parentnode.Index].Items.Add(TModbusDevice.Create(fBusList.Items[parentnode.Index]));
  fBusList.Items[parentnode.Index].Items.Last.Name := name_;
end;

{
procedure Tfrm_settings.PortDataRx(Sender: TObject; Device: TModbusDevice; data: TBytes);
begin
if (TBus(Sender).InterchangeFlag) and (Device.InterchangeFlag) then
 begin
 TForm_Settings(Parent).ProtocolFrame.memProtocol.Lines.Add(format('Шина: %s, Устройство: %s, Ответ: %s', [TBusRtu(Sender).Name, Device.Name, DataToStr(data)]));
 end;
end;

procedure Tfrm_settings.PortDataTx(Sender: TObject; Device: TModbusDevice; data: TBytes);
begin
if (TBus(Sender).InterchangeFlag) and (Device.InterchangeFlag) then
  begin
  TForm_Settings(Parent).ProtocolFrame.memProtocol.Lines.Add(format('Шина: %s, Устройство: %s, Запрос: %s', [TBusRtu(Sender).Name, Device.Name, DataToStr(data)]));
  end;
end;  }

function TFrm_Settings.CheckNameIsOccupied(checkname: string): boolean;
var
  i: integer;
begin
result := false;
  for i := 0 to tvDevices.Items.Count - 1 do
    begin
      if (checkname = tvDevices.Items.Item[i].Text) then
        begin
          result := true;
          break;
        end;
    end;
end;

function TFrm_Settings.getLastPos(substr, str: string): integer;
var
  outp, p: integer;
  offs: integer;
begin
  offs := 1;
  outp := 0;
  p := PosEx(substr, str, offs);
  while p > 0 do
    begin
    outp := p;
    offs := p + 1;
    p := PosEx(substr, str, offs);
    end;
 result := outp;
end;

function TFrm_Settings.IsNumber(N: String): Boolean;
var
I : Integer;
begin
Result := True;
if Trim(N) = '' then
 Exit(False);

if (Length(Trim(N)) > 1) and (Trim(N)[1] = '0') then
Exit(False);

for I := 1 to Length(N) do
begin
 if not (N[I] in ['0'..'9']) then
  begin
   Result := False;
   Break;
 end;
end;
end;

function TFrm_Settings.getNameNumber(name_: string): integer;
var
  strnumber: string;
  delimeterpos: integer;
  n: integer;
begin
  n := 0;
  delimeterpos := getLastPos('(', name_);
  if delimeterpos > 0 then
     begin
      strnumber := copy(name_, delimeterpos + 1, length(name_) - delimeterpos - 1);
      try
      if isnumber(strnumber) then
        n := strtoint(strnumber);
      finally

      end;
     end;
  result := n;
end;

function TFrm_Settings.UpdateNameNumber(name_: string; n: integer): string;
var
  strnumber: string;
  delimeterpos: integer;
  newname: string;
begin
  newname := name_;
  delimeterpos := getLastPos('(', name_);
  if delimeterpos > 0 then
     begin
      delete(newname, delimeterpos, length(newname) - delimeterpos + 1);
      newname := format('%s(%d)',[newname, n])
     end;
  result := newname;
end;


function TFrm_Settings.getNewName(oldName: string): string;
var
  newname: string;
  n: integer;
begin
  newname := oldname;
  n := 0;
  while CheckNameIsOccupied(newname) do
    begin
      n := getNameNumber(newname);
      if n = 0 then
         begin
          n := 1;
          newname := format('%s (%d)',[newname, n]);
         end else
         begin
         inc(n);
         newname := UpdateNameNumber(newname, n);
         end;
    end;
  result := newname;
end;

procedure TFrm_Settings.Copy_Node(source: TTreeNode);
var
  md, newdevice: TModbusDevice;
  mt, newtag: TModbusTag;
  node: TTreeNode;
  i, j: integer;
begin
  node := CopyNode(source);
  if tvDevices.Selected.Level = 1 then //Копирование шины
    begin
    if BusList.Items[tvDevices.Selected.Index].ProtocolType = ptRTU then
      BusList.Add(TBusRTU.Create(TBusRTU(BusList.Items[tvDevices.Selected.Index]), node)) else
      BusList.Add(TBusTCP.Create(TBusTCP(BusList.Items[tvDevices.Selected.Index]), node));

      for i := 0 to BusList.Last.Items.Count - 1 do
          begin
          //BusList.Last.Items.Items[i].Address := BusList.Last.GetMaxAdress + 1;
            for j := 0 to BusList.Last.Items.Items[i].tags.Count - 1 do
               begin
               mt := BusList.Last.Items.Items[i].tags.Items[j];
               CreateRecorderTag(UTF8ToWinCP(mt.Name), mt.Description, true);
               mt.OnValueChanged := @TagValueChanged;
               end;
          end;

    end;

  if tvDevices.Selected.Level = 2 then  //Копирование устройства
    begin
      md := BusList.Items[tvDevices.Selected.Parent.Index].Items[tvDevices.Selected.Index];
      newdevice := TModbusDevice.Create(md, node);
      newdevice.Address := md.Parent.GetMaxAdress + 1;
      md.Parent.Items.Add(newdevice);
      for j := 0 to newdevice.tags.Count - 1 do
         begin
         mt := newdevice.tags.Items[j];
         CreateRecorderTag(UTF8ToWinCP(mt.Name), mt.Description, true);
         mt.OnValueChanged := @TagValueChanged;
         end;
    end;


  if tvDevices.Selected.Level = 3 then //Копирование переменной
    begin
      mt := BusList.Items[tvDevices.Selected.Parent.Parent.Index].Items[tvDevices.Selected.Parent.Index].tags[tvDevices.Selected.Index];
      newtag := TModbusTag.Create(mt, mt.Parent, node);
      newtag.Addres := newtag.Addres + 1;

      //newdevice.Address := md.Parent.A + 1;
      mt.Parent.tags.Add(newtag);
      CreateRecorderTag(UTF8ToWinCP(newtag.Name), newtag.Description, true);
      mt.OnValueChanged := @TagValueChanged;
    end;
end;

procedure TFrm_Settings.copynd(parent_: TTreeView; source, target: TTreeNode);
var
  nd, child: TTreeNode;
  name_: string;
begin
if not source.HasChildren then exit;

child := source.getFirstChild;
while Assigned(child) do
   begin
    name_ := getNewName(Child.Text);
    nd := parent_.Items.AddChild(target, name_);
    nd.ImageIndex := child.ImageIndex;
    nd.SelectedIndex := child.SelectedIndex;
    nd.StateIndex := child.StateIndex;
    copynd(parent_, child, nd);
    child := source.GetNextChild(child);
   end;
end;

function TFrm_Settings.CopyNode(source: TTreeNode): TTreeNode;
var
  node: TTreeNode;
  newname: string;
begin
  newname := getNewName(source.Text);
  node := tvDevices.Items.AddChild(source.Parent, newname);
  node.ImageIndex := source.ImageIndex;
  node.SelectedIndex := source.SelectedIndex;
  node.StateIndex := source.StateIndex;
  copynd(tvDevices, source, node);

  result := node;
end;

function TFrm_Settings.GenerateNewTagName: AnsiString;
var
  tagname: PAnsiChar;
  str: AnsiString;
  tag_: ITag;
  i: integer;
begin
tagname := 'NewValue';
  tag_ := ITag(Recorder.GetTagByName(tagname));
  i := 1;
  while tag_ <> nil do
    begin
     str := format('NewValue (%d)', [i]);
     tagname := PAnsiChar(str);
     inc(i);
     tag_ := nil;
     tag_ := ITag(Recorder.GetTagByName(tagname));
    end;
    result := tagname;
end;

function TFrm_Settings.getActiveFrame: TFrmSimple;
begin
  result := fCurrentFrame;
end;

function TFrm_Settings.GetBusList: TBusList;
begin
  result := fBusList;
end;

function TFrm_Settings.getParentFont: TForm;
begin
  result := fParentForm;
end;

function TFrm_Settings.getRecorder: IRecorder;
begin
  result := fRecorder;
end;

function TFrm_Settings.GenerateNewBusName: AnsiString;
var
  name_: PAnsiChar;
  str: AnsiString;
  i: integer;
begin
  name_ := 'New bus';
  i := 1;
  while CheckNodeName(tvDevices, name_) do
    begin
     str := format('New bus (%d)', [i]);
     name_ := PAnsiChar(str);
     inc(i);
    end;
    result := name_;
end;

function TFrm_Settings.CheckNodeName(treeview: TTreeView; NodeName: string
  ): boolean;
var
  i: integer;
begin
  result := false;
  for i := 0 to treeview.Items.Count - 1 do
    begin
      if treeview.Items[i].Text = NodeName then
        begin
          result := true;
          break;
        end;
    end;
end;


function TFrm_Settings.GenerateNewDeviceName: AnsiString;
var
  name_: PAnsiChar;
  str: AnsiString;
  i: integer;
begin
  name_ := 'New device';
  i := 1;
  while CheckNodeName(tvDevices, name_) do
    begin
     str := format('New device (%d)', [i]);
     name_ := PAnsiChar(str);
     inc(i);
    end;
    result := name_;
end;

procedure TFrm_Settings.AddTag(tagname: AnsiString; conf: boolean);
var
  tag_: ITag;
  var_type: Variant;
begin

  if not Recorder.CheckState(RS_CONFIGMODE) then
     TForm_Settings(Parent).ecm;

  tag_ := ITag(Recorder.GetTagByName(PAnsiChar(UTF8ToWinCP(tagname))));

  if not Assigned(tag_) then
     tag_ := ITag(Recorder.CreateTag(PAnsiChar(tagname), LS_VIRTUAL, nil));

  tag_.SetProperty(TAGPROP_TYPE, TTAG_SCALAR or TTAG_INPUT or TTAG_OUTPUT);
  tag_.SetProperty(TAGPROP_OWNER, IRecorderPlugin(TForm_Settings(Parent).Plugin));
  tag_.SetProperty(TAGPROP_ATTRIB_HIDEN, false);
  tag_.SetProperty(TAGPROP_ENABLEFREQCORRECTION, false);
  TVarData(var_type).VType := varDouble;
  tag_.SetProperty(TAGPROP_DATATYPE, var_type);
  tag_.CfgWritable(true);

  if Recorder.CheckState(RS_CONFIGMODE) then
    TForm_Settings(ParentForm).lcm;
end;

procedure TFrm_Settings.AddValue(parentnode: TTreeNode; conf: boolean);
var
  node: TTreeNode;
  tagname: PAnsiChar;
  device: TModbusDevice;
  bus: TBus;
  var_type: Variant;
begin
  tagname := PAnsiChar(GenerateNewTagName);
  node := tvDevices.Items.AddChild(parentnode, tagname);
  tvDevices.Select(node);

  AddTag(tagname, conf);

  bus := fBusList.Items[parentnode.Parent.Index];
  bus.Items[parentnode.Index].Tags.Add(TModbusTag.Create(bus.Items[parentnode.Index], tagname));
  case bus.Items[parentnode.Index].Tags.Last.AccessType of
       atRead: begin
               node.ImageIndex := 0;
               node.SelectedIndex := 0;
               node.StateIndex := 0;
               end;
       atWrite: begin
               node.ImageIndex := 1;
               node.SelectedIndex := 1;
               node.StateIndex := 1;
               end;
       atReadWrite: begin
               node.ImageIndex := 2;
               node.SelectedIndex := 2;
               node.StateIndex := 2;
               end;
       end;
  bus.Items[parentnode.Index].Tags.Last.OnValueChanged := @TagValueChanged;
end;

procedure TFrm_Settings.CreateRecorderTag(tagname: AnsiString;
  describe: AnsiString; conf: boolean);
var
  tag_: ITag;
  var_type: Variant;
begin
  if conf and (not TForm_Settings(ParentForm).InConfigMode) then
  TForm_Settings(ParentForm).ecm;

  tag_ := ITag(Recorder.GetTagByName(PAnsiChar(UTF8ToWinCP(tagname))));
  if not Assigned(tag_) then
     begin
      tag_ := ITag(Recorder.CreateTag(PAnsiChar(tagname), LS_VIRTUAL, nil));
  //if Assigned(tag_) then
  //   begin
      tag_.SetProperty(TAGPROP_TYPE, TTAG_SCALAR or TTAG_INPUT or TTAG_OUTPUT);
      tag_.SetProperty(TAGPROP_OWNER, IRecorderPlugin(TForm_Settings(ParentForm).Plugin));
      tag_.SetProperty(TAGPROP_ATTRIB_HIDEN, false);
      tag_.SetProperty(TAGPROP_DESCRIBE, describe);
      tag_.SetProperty(TAGPROP_ENABLEFREQCORRECTION, false);
      TVarData(var_type).VType := varDouble;
      tag_.SetProperty(TAGPROP_DATATYPE, var_type);
      tag_.CfgWritable(true);
     end;
  if conf and TForm_Settings(ParentForm).InConfigMode then
  TForm_Settings(ParentForm).lcm;
end;



procedure TFrm_Settings.AddValue(parentnode: TTreeNode; tagname: AnsiString;
  descr: AnsiString; conf: boolean);
var
  node: TTreeNode;
  params: pointer;
  m: Integer;
  tag_: ITag;
  v: variant;
  str: AnsiString;
  i: integer;
  bus: TBus;
  var_type: Variant;
begin
  node := tvDevices.Items.AddChild(parentnode, tagname);

  tvDevices.Select(node);

  tag_ := ITag(Recorder.GetTagByName(PAnsiChar(UTF8ToWinCP(tagname))));

  if not Assigned(tag_) then
  begin
     CreateRecorderTag(UTF8ToWinCP(tagname), descr, conf);
     tag_ := ITag(Recorder.GetTagByName(PAnsiChar(UTF8ToWinCP(tagname))));
  end;



  if Assigned(tag_) then
     begin
      bus := fBusList.Items[parentnode.Parent.Index];
      bus.Items[parentnode.Index].Tags.Last.Name := tagname;
      bus.Items[parentnode.Index].Tags.Last.OnValueChanged := @TagValueChanged;

       case bus.Items[parentnode.Index].Tags.Last.AccessType of
       atRead: node.ImageIndex := 0;
       atWrite: node.ImageIndex := 1;
       atReadWrite: node.ImageIndex := 2;
       end;

      node.SelectedIndex := node.ImageIndex;
      tvDevices.Refresh;
     end;
end;

procedure TFrm_Settings.btnApplyClick(Sender: TObject);
begin
  inherited;
  if fCurrentFrame is TFrameSettings then
     begin
     TFrameSettings(fCurrentFrame).ApplySettings;
     fRecorder.PushState(RS_CONFIGCHANGED);
     end;
end;

procedure TFrm_Settings.MenuItem1Click(Sender: TObject);
begin
  AddBus;
  tvDevices1Click(nil);
end;

procedure TFrm_Settings.MenuItem2Click(Sender: TObject);
var
  node: TTreeNode;
begin
  node := tvDevices.Selected;
  if not Assigned(node) then exit;

  if node.Level < 1 then
     begin
       ShowMessage(rsSelectBus);
       Exit;
     end;

  while node.Level > 1 do
    node := node.Parent;

  AddDevice(node);

  tvDevices1Click(nil);
end;

procedure TFrm_Settings.MenuItem3Click(Sender: TObject);
var
  node: TTreeNode;
begin
  node := tvDevices.Selected;
  if not Assigned(node) then exit;

  if node.Level < 2 then
     begin
       ShowMessage(rsSelectDevice);
       Exit;
     end;

  while node.Level > 2 do
    node := node.Parent;

  AddValue(node);
  tvDevices1Click(nil);
end;

procedure TFrm_Settings.MenuItem4Click(Sender: TObject);
var
  node: TTreeNode;
begin
  node := tvDevices.Selected;
  if not Assigned(node) then exit;

    if tvDevices.Selected.Level = 0 then exit;

    Copy_Node(tvDevices.Selected);
end;

procedure TFrm_Settings.MenuItem5Click(Sender: TObject);
var
  i, n: integer;
  node: TTreeNode;
begin
  inherited;
  node := tvDevices.Selected;
  if not Assigned(node) then exit;

  if tvDevices.Selected.Level = 0 then exit;

  if dlg_NodeCopy.ShowModal = mrOK then
    begin
    if (dlg_NodeCopy.edNumber.Text = '') or (dlg_NodeCopy.edNumber.Text = '0') then Exit;
    n := StrToInt(dlg_NodeCopy.edNumber.Text);
    for i := 0 to n - 1 do
      Copy_Node(tvDevices.Selected);
    end;
end;

procedure TFrm_Settings.MenuItem6Click(Sender: TObject);
begin
  inherited;
  fFrmDevice.ModbusDevice.Enabled := not fFrmDevice.ModbusDevice.Enabled;
  fFrmDevice.chbActive.Checked := fFrmDevice.ModbusDevice.Enabled;
  btnApplyClick(fFrmDevice);
end;

procedure TFrm_Settings.MenuItem7Click(Sender: TObject);
var
  bus: TBus;
begin
  inherited;
  bus := fFrmBus.Bus;

  if not Assigned(bus) then Exit;

  //Переключение состояния шины
  SwitchBus(bus, not GetBusEnabled(bus));
end;

procedure TFrm_Settings.FrmSettingsTypeChanged(Sender: TObject);
begin
  if Sender is TFrm_Bus then
     begin
     //На этот момент указатель на шину в списке показывает на старую копию шины с другим типом
     //его надо заменить на новый, полученный в результате преобразования
     fBusList.Add(TFrm_Bus(Sender).Bus);
     fBusList.Exchange(tvDevices.Selected.Index, fBusList.Count - 1);
     fBusList.Delete(fBusList.Count - 1);

      case TFrm_Bus(Sender).Bus.ProtocolType of
        ptRTU: tvDevices.Selected.ImageIndex := 4;
        ptTCP: tvDevices.Selected.ImageIndex := 3;
      end;
     end;

  if Sender is TFrm_Value then
     begin
      case TFrm_Value(Sender).ModbusTag.AccessType of
        atRead: tvDevices.Selected.ImageIndex := 0;
        atWrite: tvDevices.Selected.ImageIndex := 1;
        atReadWrite: tvDevices.Selected.ImageIndex := 2;
      end;
     end;

     tvDevices.Selected.SelectedIndex := tvDevices.Selected.ImageIndex;
     tvDevices.Refresh;
end;

procedure TFrm_Settings.SetBusList(const Value: TBusList);
begin
  fBusList := Value;
end;

procedure TFrm_Settings.setParentForm(const Value: TForm);
begin
  fParentForm := Value;
end;

procedure TFrm_Settings.setRecorder(const Value: IRecorder);
begin
  fRecorder := Value;
end;

procedure TFrm_Settings.BusNameChanged(Sender: TObject; oldname: AnsiString;
  newname: AnsiString);
begin
  tvDevices.Selected.Text := fBusList.Items[tvDevices.Selected.Index].Name;
end;

procedure TFrm_Settings.DeviceNameChanged(Sender: TObject; oldname,
  newname: AnsiString);
begin
  tvDevices.Selected.Text := newname;
end;

procedure TFrm_Settings.ValueNameChanged(Sender: TObject; oldname,
  newname: AnsiString);
begin
  tvDevices.Selected.Text := newname;
end;

procedure TFrm_Settings.TagDescrChanged(Sender: TObject; name_: AnsiString;
  newdescr: AnsiString);
var
  rectag: ITag;
begin
  tvDevices.Selected.Text := fBusList.Items[tvDevices.Selected.Parent.Parent.Index].Items[tvDevices.Selected.Parent.Index].Tags[tvDevices.Selected.Index].Name;

  if not Recorder.CheckState(RS_CONFIGMODE) then
    TForm_Settings(ParentForm).ecm;

  rectag := ITag(Recorder.GetTagByName(PAnsiChar(UTF8ToWinCP(name_))));
  if Assigned(rectag) then
     rectag.SetProperty(TAGPROP_DESCRIBE, newdescr);

  if Recorder.CheckState(RS_CONFIGMODE) then
    TForm_Settings(ParentForm).lcm;
end;


procedure TFrm_Settings.TagNameChanged(Sender: TObject; oldname: AnsiString;
  newname: AnsiString);
var
  rectag: ITag;
begin
  tvDevices.Selected.Text := fBusList.Items[tvDevices.Selected.Parent.Parent.Index].Items[tvDevices.Selected.Parent.Index].Tags[tvDevices.Selected.Index].Name;

  if not Recorder.CheckState(RS_CONFIGMODE) then
    TForm_Settings(ParentForm).ecm;

  rectag := ITag(Recorder.GetTagByName(PAnsiChar(UTF8ToWinCP(oldname))));
  if Assigned(rectag) then
     rectag.SetName(PAnsiChar(newname));

  if Recorder.CheckState(RS_CONFIGMODE) then
    TForm_Settings(ParentForm).lcm;
end;

{
function Tfrm_settings.getNodeByData(parentnode: TTreeNode; data: pointer): TTreeNode;
var
  i: integer;
  node: TTreeNode;
begin
  if (not Assigned(node)) or
   (not parentnode.HasChildren) then exit;

  node := parentnode.getFirstChild;
  if Assigned(node.Data) and (node.Data = data) then
    begin
    result := node;
    exit;
    end;

  repeat
  node := parentnode.GetNextChild(node);

  if Assigned(node) and Assigned(node.Data) and (node.Data = data) then
    begin
    result := node;
    exit;
    end;

  getNodeByData(node, data);
  until not Assigned(node);

end;
}


function TFrm_Settings.getNodeByData(parentnode: TTreeNode; data: pointer
  ): TTreeNode;
var
  i: integer;
  node: TTreeNode;
  bus: TBus;
  device: TModbusDevice;
  index: integer;
begin
  if (not Assigned(parentnode)) or
   (not parentnode.HasChildren) then
   begin
   result := nil;
   exit;
   end;

  node := nil;
  index := -1;
  bus := fBusList[parentnode.Index];
  for i := 0 to bus.Items.Count - 1 do
    begin
      if bus.Items[i] = TModbusDevice(data) then
        begin
        index := i;
        break;
        end;
    end;

  if index >= 0 then
     node := parentnode.Items[index];
  result := node;
end;


procedure TFrm_Settings.ModbusDeviceEnabledChanged(Sender: TObject);
var
 node: TTreeNode;
begin
  if Sender is Tfrm_device then
     begin
      //if Tfrm_device(Sender).ModbusDevice.Enabled then
      //node := tvDevices.Selected;
        node := nil;
        //Если выбрана шина, то надо провести поиск узла устройства вызвавшего событие
        if tvDevices.Selected.Level = 1 then
           node := getNodeByData(tvDevices.Selected, Tfrm_device(Sender).ModbusDevice) else
        //Если выбрано устройство, то поиск проводить не нужно. Выбранный узел и соответствует устройству
        if tvDevices.Selected.Level = 2 then
           node := tvDevices.Selected;

        if Tfrm_device(Sender).ModbusDevice.Enabled then
        node.ImageIndex := 6 else
        node.ImageIndex := 7;

        node.SelectedIndex := node.ImageIndex;

        tvDevices.Refresh;
     end;
end;


procedure TFrm_Settings.tvDevices1Click(Sender: TObject);
begin
  if not Assigned(tvDevices.Selected) then
  Exit;

  case tvDevices.Selected.Level of
    1: begin
        ActivateFrame(fFrmBus);
        fFrmBus.Bus := fBusList.Items[tvDevices.Selected.Index];
        //fFrmBus.OnNameChanged := BusNameChanged;

       end;
    2: begin
        ActivateFrame(fFrmDevice);
        fFrmDevice.ModbusDevice := fBusList.Items[tvDevices.Selected.Parent.Index].Items[tvDevices.Selected.Index];
        fFrmDevice.OnNameChanged := @DeviceNameChanged;
        //fFrmDevice.OnEnabledChanged := ModbusDeviceEnabledChanged;

       end;
    3: begin
        ActivateFrame(fFrmValue);
        fFrmValue.ModbusTag := fBusList.Items[tvDevices.Selected.Parent.Parent.Index].Items[tvDevices.Selected.Parent.Index].Tags[tvDevices.Selected.Index];
        fFrmValue.OnTagNameChanged := @TagNameChanged;
        fFrmValue.OnDescrChanged := @TagDescrChanged;
       end
    else ActivateFrame(nil);
  end;
end;



procedure TFrm_Settings.tvDevices1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  buf: TTreeNode;
begin
case Key of
//В версии 1.7.10.1 есть ошибка с удалением узлов с неуникальными названиями
VK_DELETE: //Уничтожение выбранных в дереве узлов
          begin
          buf := nil;
          //После того как выбранные узлы будут удалены необходимо встать на узел предшествующий
          //последнему удаленному и активировать его фрейм. Иначе активным может стать фрейм удаленного узла
          if tvDevices.SelectionCount > 0 then
            begin
            if tvDevices.GetLastMultiSelected.Level <> 0 then
              begin
              buf := tvDevices.GetLastMultiSelected.GetPrev;
              while buf.Selected do
                    buf := buf.GetPrev;
              end;

            while tvDevices.SelectionCount > 0 do
             begin
              if tvDevices.Selections[0].Level = 0 then break;
              DeleteNodeWithAssociations(tvDevices.Selections[0]);
             end;
            if Assigned(buf) then tvDevices.Select(buf);
            tvDevices1Click(nil);
            end;

          end;
end;

end;

procedure TFrm_Settings.tvDevices1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    case Key of
    VK_DOWN:
         tvDevices1Click(nil);
    VK_UP:
        tvDevices1Click(nil);
    end;
end;

end.

