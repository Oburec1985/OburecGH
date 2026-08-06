unit uRecorderVirtualTagDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Spin, Dialogs;

type
  TRecorderVirtualTagDialog = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    cbVector: TCheckBox;
    edName: TEdit;
    fsFrequency: TFloatSpinEdit;
    lbFrequency: TLabel;
    lbName: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure cbVectorChange(Sender: TObject);
  private
    procedure UpdateVectorControls;
  public
    constructor Create(AOwner: TComponent); override;
    function GetTagName: string;
    function IsVector: Boolean;
    function FrequencyHz: Double;
    property TagName: string read GetTagName;
  end;

function ShowRecorderVirtualTagDialog(AOwner: TComponent; out AName: string;
  out AIsVector: Boolean; out AFrequencyHz: Double): Boolean;

implementation

{$R *.lfm}

constructor TRecorderVirtualTagDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  edName.Text := 'VirtualTag';
  cbVector.Checked := False;
  fsFrequency.Value := 1000;
  UpdateVectorControls;
end;

procedure TRecorderVirtualTagDialog.UpdateVectorControls;
begin
  lbFrequency.Enabled := cbVector.Checked;
  fsFrequency.Enabled := cbVector.Checked;
end;

procedure TRecorderVirtualTagDialog.cbVectorChange(Sender: TObject);
begin
  UpdateVectorControls;
end;

procedure TRecorderVirtualTagDialog.btnOkClick(Sender: TObject);
begin
  if Trim(edName.Text) = '' then
  begin
    MessageDlg('Создание виртуального тега', 'Имя тега не может быть пустым.',
      mtWarning, [mbOK], 0);
    edName.SetFocus;
    Exit;
  end;
  if cbVector.Checked and (fsFrequency.Value <= 0) then
  begin
    MessageDlg('Создание виртуального тега',
      'Для векторного тега задайте частоту больше нуля.', mtWarning, [mbOK], 0);
    fsFrequency.SetFocus;
    Exit;
  end;
  ModalResult := mrOk;
end;

function TRecorderVirtualTagDialog.GetTagName: string;
begin
  Result := Trim(edName.Text);
end;

function TRecorderVirtualTagDialog.IsVector: Boolean;
begin
  Result := cbVector.Checked;
end;

function TRecorderVirtualTagDialog.FrequencyHz: Double;
begin
  if cbVector.Checked then
    Result := fsFrequency.Value
  else
    Result := 0;
end;

function ShowRecorderVirtualTagDialog(AOwner: TComponent; out AName: string;
  out AIsVector: Boolean; out AFrequencyHz: Double): Boolean;
var
  lDialog: TRecorderVirtualTagDialog;
begin
  lDialog := TRecorderVirtualTagDialog.Create(AOwner);
  try
    Result := lDialog.ShowModal = mrOk;
    if Result then
    begin
      AName := lDialog.GetTagName;
      AIsVector := lDialog.IsVector;
      AFrequencyHz := lDialog.FrequencyHz;
    end;
  finally
    lDialog.Free;
  end;
end;

end.
