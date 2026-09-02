unit uRecorderStrainCalibrationDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  uRecorderTags, uRecorderStrainCalibration, uRecorderStrainCalibrationFrame;

type
  TRecorderStrainCalibrationDialog = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    pnEditor: TPanel;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fCalibration: TRecorderCalibration;
    fEditor: TRecorderStrainCalibrationFrame;
  public
    procedure EditCalibration(ACalibration: TRecorderCalibration;
      const ADeviceExcitation: string = ''; const AInputUnit: string = '');
  end;

function ShowRecorderStrainCalibrationDialog(AOwner: TComponent;
  ACalibration: TRecorderCalibration; const ADeviceExcitation: string = '';
  const AInputUnit: string = ''): Boolean;

implementation

{$R *.lfm}

function OverrideInputUnit(const AText: string;
  out AUnit: TRecorderStrainInputUnit): Boolean;
var
  lText: string;
begin
  Result := True;
  lText := LowerCase(StringReplace(Trim(AText), ' ', '', [rfReplaceAll]));
  if (lText = 'ом') or (lText = 'ohm') then AUnit := rsiOhm
  else if (lText = 'мв/ма') or (lText = 'мв/мa') or
    (lText = 'mv/ma') or (lText = 'mv/мa') then
    AUnit := rsiMilliVoltPerMilliAmp
  else if (lText = 'мв') or (lText = 'mv') then AUnit := rsiMilliVolt
  else if (lText = 'в') or (lText = 'v') then AUnit := rsiVolt
  else if (lText = 'мв/в') or (lText = 'mv/v') then AUnit := rsiMilliVoltPerVolt
  else Result := False;
end;

function OverrideExcitation(const AText: string;
  out AKind: TRecorderStrainExcitationKind; out AValue: Double): Boolean;
var
  I: Integer;
  lNumber: string;
  lText: string;
begin
  lText := LowerCase(StringReplace(Trim(AText), ' ', '', [rfReplaceAll]));
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lNumber := '';
  for I := 1 to Length(lText) do
    if lText[I] in ['0'..'9', '-', '+', DefaultFormatSettings.DecimalSeparator] then
      lNumber := lNumber + lText[I]
    else if lNumber <> '' then Break;
  Result := TryStrToFloat(lNumber, AValue);
  if not Result then Exit;
  if (Pos('ma', lText) > 0) or (Pos('ма', lText) > 0) then
    AKind := rsekCurrent
  else if (Pos('a', lText) > 0) or (Pos('а', lText) > 0) then
  begin
    AKind := rsekCurrent;
    AValue := AValue * 1000;
  end
  else
    AKind := rsekVoltage;
end;

procedure TRecorderStrainCalibrationDialog.FormCreate(Sender: TObject);
begin
  fEditor := TRecorderStrainCalibrationFrame.Create(Self);
  fEditor.Parent := pnEditor;
  fEditor.Align := alClient;
end;

procedure TRecorderStrainCalibrationDialog.EditCalibration(
  ACalibration: TRecorderCalibration; const ADeviceExcitation: string;
  const AInputUnit: string);
var
  lCfg: TRecorderStrainConfig;
  lKind: TRecorderStrainExcitationKind;
  lUnit: TRecorderStrainInputUnit;
  lValue: Double;
  lView: TRecorderCalibration;
begin
  fCalibration := ACalibration;
  if ACalibration <> nil then
  begin
    lCfg := TRecorderStrainConfig.Create;
    lView := ACalibration.Clone;
    try
      lCfg.Load(lView.ModuleData);
      if OverrideExcitation(ADeviceExcitation, lKind, lValue) then
      begin
        lCfg.ExcitationKind := lKind;
        lCfg.ExcitationValue := lValue;
        if (lKind = rsekCurrent) and
          (lCfg.InputUnit in [rsiRatio, rsiMilliVoltPerVolt, rsiVolt]) then
          lCfg.InputUnit := rsiMilliVoltPerMilliAmp
        else if (lKind = rsekVoltage) and
          (lCfg.InputUnit in [rsiMilliVoltPerMilliAmp, rsiOhm]) then
          lCfg.InputUnit := rsiMilliVoltPerVolt;
      end;
      if OverrideInputUnit(AInputUnit, lUnit) then
        lCfg.InputUnit := lUnit;
      lView.ModuleData := lCfg.Save;
      fEditor.LoadCalibration(lView);
    finally
      lView.Free;
      lCfg.Free;
    end;
  end;
end;

procedure TRecorderStrainCalibrationDialog.btnOkClick(Sender: TObject);
var
  lError: string;
begin
  if fEditor.TryApply(fCalibration, lError) then
    ModalResult := mrOk
  else if lError <> '' then
    MessageDlg(lError, mtError, [mbOK], 0);
end;

function ShowRecorderStrainCalibrationDialog(AOwner: TComponent;
  ACalibration: TRecorderCalibration; const ADeviceExcitation: string;
  const AInputUnit: string): Boolean;
var
  D: TRecorderStrainCalibrationDialog;
begin
  D := TRecorderStrainCalibrationDialog.Create(AOwner);
  try
    D.EditCalibration(ACalibration, ADeviceExcitation, AInputUnit);
    Result := D.ShowModal = mrOk;
  finally
    D.Free;
  end;
end;

end.
