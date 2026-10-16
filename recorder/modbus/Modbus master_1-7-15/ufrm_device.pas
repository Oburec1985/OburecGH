unit ufrm_device;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  FrameSettings, ModbusDevice, UCommon, resstr, uUpdatable;

type

  { TFrm_Device }

  TFrm_Device = class(TFrameSettings)
    chbInterchange: TCheckBox;
    chbActive: TCheckBox;
    chbTries: TCheckBox;
    edAdr: TEdit;
    edTries: TEdit;
    edTimer: TEdit;
    edName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    memDescr: TMemo;
    procedure edAdrKeyPress(Sender: TObject; var Key: char);
  private
    { Private declarations }
    fDevice: TModbusDevice;
    fNameChanged: TNameChangeEvent;
    fEnabledChanged: TNotifyEvent;
    procedure DigitButtonKeyPressed(Sender: TObject; var Key: Char);
    function GetDevice: TModbusDevice;
    procedure SetDevice(const Value: TModbusDevice);
    procedure DoNameChanged(oldname, newname: string);
    procedure DoEnabledChanged;
    procedure UpdateFrm(obj: TModbusDevice);
    procedure DeviceEnabledChanged(Sender: TObject);
  public
    { Public declarations }
    procedure Clear;
    procedure UpdateHmi; override;
    procedure ApplySettings; override;
    property ModbusDevice: TModbusDevice read GetDevice write SetDevice;
    property OnNameChanged: TNameChangeEvent read fNameChanged write fNameChanged;
    property OnEnabledChanged: TNotifyEvent read fEnabledChanged write fEnabledChanged;
  end;

var
  frm_device: Tfrm_device;

implementation

{$R *.lfm}

{ TFrameSettings3 }

procedure TFrm_Device.DoEnabledChanged;
begin
if Assigned(fEnabledChanged) then
  fEnabledChanged(self);
end;

procedure TFrm_Device.DoNameChanged(oldname, newname: string);
begin
  if Assigned(fNameChanged) then
     fNameChanged(self, oldname, newname);
end;

function TFrm_Device.GetDevice: TModbusDevice;
begin
  result := fDevice;
end;

procedure TFrm_Device.Clear;
begin
  edName.Text := '';
  memDescr.Text := '';
  edAdr.Text := '1';
  edTries.Text := '3';
  edTimer.Text :='500';
  chbTries.Checked := false;
end;

procedure TFrm_Device.UpdateHmi;
begin
  UpdateFrm(self.fDevice);
end;

procedure TFrm_Device.UpdateFrm(obj: TModbusDevice);
begin
if Assigned(obj) then
  begin
  edName.Text := obj.Name;
  memDescr.Text := obj.Description;
  edAdr.Text := inttostr(obj.Address);
  chbInterchange.Checked := obj.InterchangeFlag;
  edTries.Text := inttostr(obj.Tries);
  edTimer.Text := inttostr(obj.TimerTimeout);
  chbActive.Checked := obj.Enabled;
  chbTries.Checked := obj.BreakOnTimeout;
  end else
  Clear;
end;

procedure TFrm_Device.edAdrKeyPress(Sender: TObject; var Key: char);
begin
  //Распознание ввода hex

  //Если нажатая клавиша не цифра
  if not (key in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', #8]) and
  //Проверяем ноль ли первый символ строки 0, разрешаем ввод "x"
  not ((length(edAdr.Text) = 1) and (edAdr.Text[1] = '0') and (Key = 'x')) and
  //Если строка начинается с 0x то можно вводить буквы шестнадцатиричного числа
  not ((pos('0x', edAdr.Text) = 1) and (Key in ['a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 'e', 'E', 'f', 'F'])) then
     Key := Char(0);
end;

procedure TFrm_Device.DigitButtonKeyPressed(Sender: TObject; var Key: Char);
begin
  inherited;
  if not isDigit(Key) then
     key := char(0);
end;

procedure TFrm_Device.DeviceEnabledChanged(Sender: TObject);
begin
  inherited;
  DoEnabledChanged;
end;

procedure TFrm_Device.SetDevice(const Value: TModbusDevice);
begin
  fDevice := Value;
  fDevice.OnEnbledChanged := @DeviceEnabledChanged;
  UpdateFrm(fDevice);
end;



procedure TFrm_Device.ApplySettings;
var
  oldname: string;
  Different: boolean;
begin
if edAdr.Text = '' then
  begin
    ShowMessage(rsEmptyAdress);
    exit;
  end;


if edTries.Text = '' then
  begin
    ShowMessage(rsTriesNumber);
    exit;
  end;

if edTimer.Text = '' then
  begin
    ShowMessage(rsEmptyTimer);
    exit;
  end;

if not Assigned(fDevice) then Exit;

  oldname := fDevice.Name;
  Different := edName.Text <> fDevice.Name;
  fDevice.Name := edName.Text;

  if Different then DoNameChanged(oldname, fDevice.Name);

  fDevice.Description := memDescr.Text;
  fDevice.Address := strtoint(edAdr.Text);
  EdAdr.Text := inttostr(fDevice.Address);
  fDevice.InterchangeFlag := chbInterchange.Checked;


  fDevice.Enabled := chbActive.Checked;
  //DoEnabledChanged;

  fDevice.BreakOnTimeout := chbTries.Checked;
  fDevice.Tries := StrToInt(edTries.Text);
  fDevice.TimerTimeout := StrToInt(edTimer.Text);
end;

end.

