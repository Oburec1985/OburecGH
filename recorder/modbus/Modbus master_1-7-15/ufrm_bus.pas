unit ufrm_bus;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, LazSerial, uUpdatable,
  FrameSettings, ufrm_adr, ufrm_comport, uFrmSimple, ModbusDevice, uCommon, SynaSer, ResStr;

type

  { TFrm_Bus }

  TFrm_Bus = class(TFrameSettings)
    chbInterchange: TCheckBox;
    edPauseDelay: TEdit;
    edName: TEdit;
    frm_adr1: Tfrm_adr;
    frm_port1: Tfrm_port;
    gbType: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    memDescr: TMemo;
    rbRTU: TRadioButton;
    rbTCP: TRadioButton;
    procedure edPauseDelayKeyPress(Sender: TObject; var Key: char);
    procedure FrameClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure rbClick(Sender: TObject);
  private
    fActiveFrame: TFrmSimple;
    fBus: TBus;
    fNameChanged: TNameChangeEvent;

    procedure UpdateBusPanel;
    procedure ActivateFrame(Frame: TFrmSimple);
    function GetBus: TBus;
    procedure SetBus(const Value: TBus);
    procedure DoNameChanged(oldname: string; newname: string);

    { Private declarations }
  public
    procedure ApplySettings; override;
    procedure UpdateHmi; override;
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;
    property Bus: TBus read GetBus write SetBus;
    property OnNameChanged: TNameChangeEvent read fNameChanged write fNameChanged;
    { Public declarations }
  end;


implementation

{$R *.lfm}


procedure Tfrm_bus.ActivateFrame(Frame: TFrmSimple);
begin
if Assigned(fActiveFrame) then fActiveFrame.Parent := nil;

fActiveFrame := Frame;

if Assigned(fActiveFrame) then
  begin
    fActiveFrame.Parent := self;
  end;
end;

procedure Tfrm_bus.ApplySettings;
var
  Different: boolean;
  oldname: string;
  baud_rate: TBaudRate;
  parity: TParity;
begin
if edPauseDelay.Text = '' then
  begin
    ShowMessage(rsMakePauseDelay);
    Exit;
  end;


if not Assigned(fBus) then Exit;

  oldname := fBus.Name;
  Different := edName.Text <> fBus.Name;

  fBus.Name := edName.Text;
  fBus.PauseDelay := StrToInt(edPauseDelay.Text);

  if Different then DoNameChanged(oldname, fBus.Name);

  fBus.Description := memDescr.Text;

  if (fBus.ProtocolType = ptRTU) then
    Different := not rbRTU.Checked;

  if (fBus.ProtocolType = ptTCP) then
    Different := not rbTCP.Checked;

  fBus.InterchangeFlag := chbInterchange.Checked;

  if rbRTU.Checked then
     begin
     if Different then ConvertBus(fBus, ptRTU);

     TBusRTU(fBus).Port.Device := Frm_Port1.cbPort.Text;
     case Frm_Port1.cbSpeed.ItemIndex of
       0: baud_rate := br__2400;
       1: baud_rate := br__4800;
       2: baud_rate := br__9600;
       3: baud_rate := br_19200;
       4: baud_rate := br_38400;
       5: baud_rate := br_57600;
       6: baud_rate := br115200;
     end;
     TBusRTU(fBus).Port.BaudRate := baud_rate;

     case Frm_Port1.cbParity.ItemIndex of
       0: parity := pNone;
       1: parity := pEven;
       2: parity := pOdd;
     end;
     TBusRTU(fBus).Port.Parity := parity;

     if Different then DoTypeChanged;
     end else
     begin
      if Different then ConvertBus(fBus, ptTCP);
      TBusTCP(fBus).Connection.Host := Frm_Adr1.edAddress.Text;
      TBusTCP(fBus).Connection.Port := StrToInt(Frm_Adr1.edPort.Text);
      if Different then DoTypeChanged;
     end;
     UpdateHmi;
end;

constructor Tfrm_bus.Create(AOwner: TComponent);
begin
  inherited;
  Frm_Port1.Parent := nil;
  Frm_Adr1.Parent := nil;
  Frm_Port1.Init;
  {if not Assigned(fFrmPort) then
     begin
       fFrmPort := TFrmPort.Create(self);
       fFrmPort.Parent := self;
       fFrmPort.Top := gbTyp.Top + 10;
       fFrmPort.Width := gbTyp.Width;
     end;

  if not Assigned(fFrmAdr) then
     begin
       fFrmAdr := TFrmAddress.Create(self);
       fFrmAdr.Parent := self;
       fFrmAdr.Top := gbTyp.Top + 10;
       fFrmAdr.Width := gbTyp.Width;
     end;}

     //UpdateBusPanel;

end;

destructor Tfrm_bus.Destroy;
begin
  //FreeAndNil(fFrmPort);
  //FreeAndNil(fFrmAdr);

  inherited;
end;

procedure Tfrm_bus.DoNameChanged(oldname: string; newname: string);
begin
  if Assigned(fNameChanged) then
     fNameChanged(self, oldname, newname);
end;

procedure Tfrm_bus.FrameResize(Sender: TObject);
begin
  inherited;
  Frm_Port1.Width := gbType.Width;
  Frm_Adr1.Width := gbType.Width;
end;

function Tfrm_bus.GetBus: TBus;
begin
  result := fBus;
end;

procedure Tfrm_bus.rbClick(Sender: TObject);
begin
  inherited;
  UpdateBusPanel;
end;

procedure Tfrm_bus.edPauseDelayKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if not (Key in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', #8]) then
    Key := Char(0);
end;

procedure TFrm_Bus.FrameClick(Sender: TObject);
begin

end;

procedure Tfrm_bus.UpdateHmi;
begin
  edName.Text := fBus.Name;
  edPauseDelay.Text := IntToStr(fBus.PauseDelay);
  memDescr.Text := fBus.Description;
  chbInterchange.Checked := fBus.InterchangeFlag;
  UpdateBusPanel;
end;

procedure Tfrm_bus.SetBus(const Value: TBus);
begin
  fBus := value;

  case fBus.ProtocolType of
    ptRTU: begin
            rbRTU.Checked := true;
           end;

    ptTCP: begin
            rbTCP.Checked := true;
           end;
  end;

  UpdateHmi;
end;

function GetStrListFromStr(str: string): TStrings;
var
  lst: TStrings;
  n: integer;
  s: string;
begin
lst := TStringList.Create;
n := pos(',', str);
while (n > 0) do
  begin
  s := copy(str,1,n - 1);
  lst.Add(s);
  delete(str, 1, n);
  n := pos(',', str);
  end;

//В строке осталась последняя позиция без разделителя
if length(str) > 0 then
   lst.Add(str);

result := lst;
end;

function GetSpeedByBaudRate(br: TBaudRate): integer;
begin
case br of
  br__2400: result := 2400;
  br__4800: result := 4800;
  br__9600: result := 9600;
  br_19200: result := 19200;
  br_38400: result := 38400;
  br_57600: result := 57600;
  br115200: result := 115200;
  else
    result := 0;
end;


end;

procedure Tfrm_bus.UpdateBusPanel;
var
  i: integer;
  pnames: TStrings;
  strofports: string;
  speed: integer;
begin

  if rbRTU.Checked then
    begin
      ActivateFrame(Frm_Port1);
      strofports := GetSerialPortNames;
      pnames := GetStrListFromStr(strofports);
      Frm_Port1.cbPort.Clear;
      for i := 0 to pnames.Count - 1 do
         Frm_Port1.cbPort.Items.Add(pnames[i]);
      FreeAndNil(pnames);

      //FrmPort1.cbPort.Items.Assign(GetPortNames);
      Frm_Port1.cbPort.ItemIndex := 0;
      fBus.PauseDelay := StrToInt(edPauseDelay.Text);
      Frm_Port1.cbSpeed.ItemIndex := 0;

      if Assigned(fBus) and Assigned(Parent) and (Frm_Port1.cbPort.Items.Count > 0) and (fBus is TBusRTU) then
        begin
         Frm_Port1.cbPort.ItemIndex := FindIndex(Frm_Port1.cbPort.Items, TBusRTU(fBus).Port.Device);
         speed := GetSpeedByBaudRate(TBusRTU(fBus).Port.BaudRate);
         Frm_Port1.cbSpeed.ItemIndex := FindIndex(Frm_Port1.cbSpeed.Items, IntToStr(speed));
         case TBusRTU(fBus).Port.Parity of
           pNone: Frm_Port1.cbParity.ItemIndex := 0;
           pEven: Frm_Port1.cbParity.ItemIndex := 1;
           pOdd: Frm_Port1.cbParity.ItemIndex := 2;
         end;


        end;
    end
    else
  if rbTCP.Checked then
    begin
    ActivateFrame(Frm_Adr1);
      if Assigned(fBus) and Assigned(Parent) and (fBus is TBusTCP) then
        begin
        Frm_Adr1.edAddress.Text := TBusTCP(fBus).Connection.Host;
        Frm_Adr1.edPort.Text := inttostr(TBusTCP(fBus).Connection.Port);
        end;
    end;
end;

end.

