program SvgImageSettingsUiSmoke;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Forms, Classes, SysUtils, Math, Controls, Graphics, StdCtrls, Grids,
  ComCtrls, ColorBox, FPImage, IntfGraphics,
  uRecorderFormModel, uRecorderImageSettingsDialog;

const
  CGaugeFile = 'C:\Mera Files\RecorderLnx\screens\parametric-dual-gauge.svg';

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure Stage(const AText: string);
var
  LogFile: TextFile;
  LogName: string;
begin
  LogName := ExtractFilePath(ParamStr(0)) + 'smoke-stage.log';
  AssignFile(LogFile, LogName);
  if FileExists(LogName) then
    Append(LogFile)
  else
    Rewrite(LogFile);
  try
    WriteLn(LogFile, AText);
  finally
    CloseFile(LogFile);
  end;
end;

function FindParameterRow(AGrid: TStringGrid; const AName: string): Integer;
var
  I: Integer;
begin
  for I := 1 to AGrid.RowCount - 1 do
    if SameText(AGrid.Cells[0, I], AName) then
      Exit(I);
  raise Exception.CreateFmt('SVG parameter not found: %s', [AName]);
end;

procedure SelectParameter(ADialog: TRecorderImageSettingsDialog;
  const AName: string);
var
  CanSelect: Boolean;
begin
  Stage('select-' + AName + '-find');
  ADialog.BindingsGrid.Row := FindParameterRow(ADialog.BindingsGrid, AName);
  Stage('select-' + AName + '-row');
  CanSelect := True;
  ADialog.BindingsGridSelectCell(ADialog.BindingsGrid, 0,
    ADialog.BindingsGrid.Row, CanSelect);
  Stage('select-' + AName + '-handler');
  Check(CanSelect, 'Parameter row cannot be selected: ' + AName);
  Application.ProcessMessages;
  Stage('select-' + AName + '-messages');
end;

procedure CaptureForm(AForm: TForm; const AFileName: string);
var
  Bitmap: TBitmap;
  Png: TPortableNetworkGraphic;
begin
  Application.ProcessMessages;
  Bitmap := AForm.GetFormImage;
  Png := TPortableNetworkGraphic.Create;
  try
    Png.Assign(Bitmap);
    Png.SaveToFile(AFileName);
  finally
    Png.Free;
    Bitmap.Free;
  end;
end;

procedure CheckLayout(ADialog: TRecorderImageSettingsDialog;
  const ASizeName: string);
begin
  Check(ADialog.BottomPan.Top + ADialog.BottomPan.Height <=
    ADialog.ClientHeight, ASizeName + ': BottomPan is clipped');
  Check(ADialog.ClientPan.Top + ADialog.ClientPan.Height <=
    ADialog.BottomPan.Top, ASizeName + ': ClientPan overlaps BottomPan');
  Check(ADialog.Pages.Top + ADialog.Pages.Height <=
    ADialog.ClientPan.ClientHeight, ASizeName + ': Pages escapes ClientPan');
  Check(ADialog.OkButton.Top + ADialog.OkButton.Height <=
    ADialog.BottomPan.ClientHeight, ASizeName + ': OK button is clipped');
  Check(ADialog.CancelButton.Top + ADialog.CancelButton.Height <=
    ADialog.BottomPan.ClientHeight, ASizeName + ': Cancel button is clipped');
end;

function BindingValue(AComponent: TRecorderImageComponent;
  const AName: string): string;
var
  Binding: TRecorderSvgTagBinding;
begin
  Binding := AComponent.FindSvgBinding(AName);
  Check(Binding <> nil, 'Live binding missing: ' + AName);
  Result := Binding.LiteralValue;
end;

var
  Component: TRecorderImageComponent;
  Dialog: TRecorderImageSettingsDialog;
  RevisionBefore: QWord;
  OutputFolder: string;
  Handled: Boolean;
  RowBeforeWheel: Integer;
begin
  DeleteFile(ExtractFilePath(ParamStr(0)) + 'smoke-stage.log');
  Stage('initialize');
  Application.Initialize;
  Stage('initialized');
  Check(FileExists(CGaugeFile), 'Gauge SVG is missing: ' + CGaugeFile);
  OutputFolder := ExtractFilePath(ParamStr(0));
  Component := TRecorderImageComponent.Create;
  Dialog := nil;
  try
    Component.Name := 'Параметрический индикатор';
    Component.Images.Add('0=' + CGaugeFile);
    RevisionBefore := Component.ImageRevision;
    Dialog := TRecorderImageSettingsDialog.CreateDialog(nil, Component, nil);
    Stage('dialog-created');
    Dialog.Show;
    Dialog.Pages.ActivePage := Dialog.SvgTab;

    SelectParameter(Dialog, 'TickCount');
    Check(Dialog.IncreaseValueButton.Enabled and
      Dialog.DecreaseValueButton.Enabled,
      'TickCount must use numeric editing controls');
    RowBeforeWheel := Dialog.BindingsGrid.Row;
    Handled := False;
    Dialog.ParametersMouseWheel(Dialog.BindingsGrid, [], -120, Point(0, 0),
      Handled);
    Check(Handled, 'Mouse wheel was not handled by SVG parameters');
    Check(Dialog.BindingsGrid.Row = Min(Dialog.BindingsGrid.RowCount - 1,
      RowBeforeWheel + 1), 'Mouse wheel did not select the next parameter');

    SelectParameter(Dialog, 'LeftValue');
    Stage('number-selected');
    Dialog.BindingValueEdit.Text := '105';
    Application.ProcessMessages;
    Check(BindingValue(Component, 'LeftValue') = '105',
      'Typing a numeric literal did not update the live component');
    Dialog.IncreaseValueButton.Click;
    Stage('number-increased');
    Application.ProcessMessages;
    Check(Dialog.BindingValueEdit.Text = '110',
      'Order-based increment must change 105 by 5');
    Check(BindingValue(Component, 'LeftValue') = '110',
      'Increment did not update the live component');
    Check(Component.ImageRevision > RevisionBefore,
      'Live edit did not invalidate the component renderer');
    Check(Dialog.IncreaseValueButton.Enabled and
      Dialog.DecreaseValueButton.Enabled,
      'Numeric increment controls are not enabled');
    Check(not Dialog.BindingColorBox.Visible,
      'ColorBox must be hidden for numeric parameters');
    Dialog.ClientWidth := 980;
    Dialog.ClientHeight := 720;
    Application.ProcessMessages;
    CheckLayout(Dialog, '980x720');
    CaptureForm(Dialog, OutputFolder + 'svg-settings-980x720-numeric.png');
    Stage('number-captured');

    SelectParameter(Dialog, 'LeftGreenColor');
    Stage('color-selected');
    Check(Dialog.BindingColorBox.Visible,
      'ColorBox is not visible for a color parameter');
    Check(not Dialog.IncreaseValueButton.Enabled and
      not Dialog.DecreaseValueButton.Enabled,
      'Numeric buttons must be disabled for a color parameter');
    Dialog.BindingColorBox.Selected := RGBToColor($24, $9A, $48);
    Dialog.BindingColorBoxSelect(Dialog.BindingColorBox);
    Stage('color-changed');
    Application.ProcessMessages;
    Check(SameText(BindingValue(Component, 'LeftGreenColor'), '#249a48'),
      'ColorBox selection did not update the live component');
    Dialog.ClientWidth := 760;
    Dialog.ClientHeight := 560;
    Application.ProcessMessages;
    CheckLayout(Dialog, '760x560');
    CaptureForm(Dialog, OutputFolder + 'svg-settings-760x560-color.png');
    Stage('color-captured');

    Dialog.Free;
    Stage('dialog-freed');
    Dialog := nil;
    Check(Component.Images.Count = 1,
      'Cancel rollback did not restore the image list');
    Check(Component.SvgBindingCount = 0,
      'Closing without OK did not roll back live SVG bindings');
    WriteLn('RESULT SvgImageSettingsUiSmoke passed');
  finally
    Dialog.Free;
    Component.Free;
  end;
end.
