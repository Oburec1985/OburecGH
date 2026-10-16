unit ufrm_comport;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, uFrmSimple;

type

  { Tfrm_port }

  Tfrm_port = class(TFrmSimple)
    cbPort: TComboBox;
    cbParity: TComboBox;
    cbSpeed: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
  private


  public
     procedure Init;
  end;

implementation

{$R *.lfm}

procedure Tfrm_port.Init;
begin
  cbSpeed.Clear;
  cbSpeed.Items.Add('2400');
  cbSpeed.Items.Add('4800');
  cbSpeed.Items.Add('9600');
  cbSpeed.Items.Add('19200');
  cbSpeed.Items.Add('38400');
  cbSpeed.Items.Add('57600');
  cbSpeed.Items.Add('115200');

  cbParity.Clear;
  cbParity.Items.Add('None');
  cbParity.Items.Add('Odd');
  cbParity.Items.Add('Even');

  cbPort.ItemIndex := 0;
  cbParity.ItemIndex := 0;
  cbSpeed.ItemIndex := 3;
end;

end.

