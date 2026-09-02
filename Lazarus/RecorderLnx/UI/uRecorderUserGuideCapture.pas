unit uRecorderUserGuideCapture;

{
  Developer-only screenshot mode for the user guide. It creates designer-backed
  forms, annotates interactive controls on the bitmap and writes a manifest.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms;

procedure StartRecorderUserGuideCapture(AMainForm: TForm;
  const AOutputDir: string);

implementation

uses
  Controls, Graphics, StdCtrls, ExtCtrls, ComCtrls, Grids, Spin, Dialogs, Math,
  FPImage, IntfGraphics,
  uTagSettingsDialog, uRecorderVirtualTagDialog, uRecorderSettingsDialog,
  uRecorderMeasurementSectionSettingsDialog, uRecorderImageSettingsDialog,
  uRecorderDeviceSearchDialog, uRecorderCalibrationPropertiesDialog,
  uRecorderCalibrationListDialog, uRecorderCalibrationAddDialog,
  uRecorderButtonSettingsDialog, uRecorderSqlDbSettingsDialog,
  uRecorderSqlTrendSettingsDialog, uRecorderMc201SlotSettingsDialog,
  uRecorderMic185SettingsDialog, uRecorderMic185ChannelDialog,
  uRecorderMic185AdditionalDialog, uRecorderMic140ChannelDialog,
  uRecorderMic140SettingsDialog, uRecorderStrainCalibrationDialog,
  uRecorderSdbSelectDialog;

type
  TGuideFormSpec = record
    FileName: string;
    FormClass: TFormClass;
  end;

  TRecorderUserGuideCapture = class
  private
    fMainForm: TForm;
    fOutputDir: string;
    fTimer: TTimer;
    fIndex: TStringList;
    procedure TimerTick(Sender: TObject);
    procedure CaptureAll;
    procedure CaptureForm(AForm: TForm; const AFileName: string);
    procedure CaptureClass(AClass: TFormClass; const AFileName: string);
    procedure CaptureCreatedForm(AForm: TForm; const AFileName: string);
    procedure SaveIndex;
  public
    constructor Create(AMainForm: TForm; const AOutputDir: string);
    destructor Destroy; override;
  end;

var
  gGuideCapture: TRecorderUserGuideCapture;

function SafeText(const AText: string): string;
begin
  Result := StringReplace(Trim(AText), '|', '\|', [rfReplaceAll]);
  Result := StringReplace(Result, LineEnding, ' ', [rfReplaceAll]);
end;

function ControlCaption(AControl: TControl): string;
begin
  Result := '';
  if AControl is TButton then
    Result := TButton(AControl).Caption
  else if AControl is TCheckBox then
    Result := TCheckBox(AControl).Caption
  else if AControl is TRadioButton then
    Result := TRadioButton(AControl).Caption
  else if AControl is TLabel then
    Result := TLabel(AControl).Caption
  else if AControl is TTabSheet then
    Result := TTabSheet(AControl).Caption;
end;

function ControlKeys(AControl: TControl): string;
begin
  Result := '';
  if AControl is TButton then
  begin
    if TButton(AControl).Default then Result := 'Enter';
    if TButton(AControl).Cancel then Result := 'Esc';
  end
  else if AControl is TCustomEdit then
    Result := 'Tab; Ctrl+C/V/X/A'
  else if AControl is TCustomComboBox then
    Result := 'Tab; Alt+Down; стрелки; Enter'
  else if (AControl is TCustomListBox) or (AControl is TStringGrid) or
    (AControl is TTreeView) then
    Result := 'Tab; стрелки; Enter'
  else if AControl is TPageControl then
    Result := 'Ctrl+Tab';
end;

function IsInteractive(AControl: TControl): Boolean;
begin
  Result := (AControl is TButton) or (AControl is TCustomEdit) or
    (AControl is TCustomComboBox) or (AControl is TCheckBox) or
    (AControl is TRadioButton) or (AControl is TCustomListBox) or
    (AControl is TStringGrid) or (AControl is TTreeView) or
    (AControl is TPageControl) or (AControl is TSpinEdit);
end;

function IsActuallyVisible(AControl: TControl): Boolean;
var
  lControl: TControl;
begin
  Result := False;
  lControl := AControl;
  while lControl <> nil do
  begin
    if not lControl.Visible then Exit;
    lControl := lControl.Parent;
  end;
  Result := True;
end;

procedure DrawMarker(ACanvas: TCanvas; X, Y, ANumber: Integer);
const
  CRadius = 10;
var
  lText: string;
  lTextX, lTextY: Integer;
begin
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := clYellow;
  ACanvas.Pen.Color := clRed;
  ACanvas.Pen.Width := 2;
  ACanvas.Ellipse(X, Y, X + CRadius * 2, Y + CRadius * 2);
  lText := IntToStr(ANumber);
  ACanvas.Font.Color := clBlack;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Size := 8;
  lTextX := X + CRadius - ACanvas.TextWidth(lText) div 2;
  lTextY := Y + CRadius - ACanvas.TextHeight(lText) div 2;
  ACanvas.TextOut(lTextX, lTextY, lText);
end;

procedure AnnotateControls(AForm: TForm; ABitmap: TBitmap;
  ALines: TStrings);
var
  lNumber: Integer;

  procedure Visit(AParent: TWinControl);
  var
    I: Integer;
    lControl: TControl;
    lPoint: TPoint;
  begin
    for I := 0 to AParent.ControlCount - 1 do
    begin
      lControl := AParent.Controls[I];
      if IsInteractive(lControl) and IsActuallyVisible(lControl) then
      begin
        Inc(lNumber);
        lPoint := lControl.ClientToScreen(Point(0, 0));
        lPoint := AForm.ScreenToClient(lPoint);
        DrawMarker(ABitmap.Canvas, Max(0, lPoint.X - 6),
          Max(0, lPoint.Y - 6), lNumber);
        ALines.Add(Format('| %d | `%s` | %s | %s | %s |', [lNumber,
          SafeText(lControl.Name), SafeText(lControl.ClassName),
          SafeText(ControlCaption(lControl)), SafeText(ControlKeys(lControl))]));
      end;
      if lControl is TWinControl then
        Visit(TWinControl(lControl));
    end;
  end;

begin
  lNumber := 0;
  Visit(AForm);
end;

constructor TRecorderUserGuideCapture.Create(AMainForm: TForm;
  const AOutputDir: string);
begin
  inherited Create;
  fMainForm := AMainForm;
  fOutputDir := IncludeTrailingPathDelimiter(ExpandFileName(AOutputDir));
  ForceDirectories(fOutputDir);
  fIndex := TStringList.Create;
  fTimer := TTimer.Create(nil);
  fTimer.Interval := 700;
  fTimer.OnTimer := @TimerTick;
  fTimer.Enabled := True;
end;

destructor TRecorderUserGuideCapture.Destroy;
begin
  fTimer.Free;
  fIndex.Free;
  inherited Destroy;
end;

procedure TRecorderUserGuideCapture.TimerTick(Sender: TObject);
begin
  fTimer.Enabled := False;
  try
    try
      CaptureAll;
    except
      on E: Exception do
      begin
        fIndex.Add('| Генератор | — | критическая ошибка: ' +
          SafeText(E.Message) + ' |');
        SaveIndex;
      end;
    end;
  finally
    Application.Terminate;
  end;
end;

procedure TRecorderUserGuideCapture.CaptureForm(AForm: TForm;
  const AFileName: string);
var
  lBitmap: TBitmap;
  lPng: TPortableNetworkGraphic;
  lElements: TStringList;
  lPngFile, lElementsFile: string;
begin
  if AForm = nil then Exit;
  AForm.Show;
  AForm.BringToFront;
  Application.ProcessMessages;
  lBitmap := TBitmap.Create;
  lPng := TPortableNetworkGraphic.Create;
  lElements := TStringList.Create;
  try
    lBitmap.SetSize(Max(1, AForm.ClientWidth), Max(1, AForm.ClientHeight));
    AForm.PaintTo(lBitmap.Canvas, 0, 0);
    lElements.Add('# ' + AForm.Caption);
    lElements.Add('');
    lElements.Add('| № | Имя | Класс | Надпись | Клавиши |');
    lElements.Add('|---:|---|---|---|---|');
    AnnotateControls(AForm, lBitmap, lElements);
    lPng.Assign(lBitmap);
    lPngFile := fOutputDir + AFileName + '.png';
    lElementsFile := fOutputDir + AFileName + '.elements.md';
    lPng.SaveToFile(lPngFile);
    lElements.SaveToFile(lElementsFile);
    fIndex.Add(Format('| %s | [%s.png](%s.png) | [%s](%s) |',
      [SafeText(AForm.Caption), AFileName, AFileName, AFileName + '.elements.md',
       AFileName + '.elements.md']));
    SaveIndex;
  finally
    lElements.Free;
    lPng.Free;
    lBitmap.Free;
  end;
end;

procedure TRecorderUserGuideCapture.CaptureClass(AClass: TFormClass;
  const AFileName: string);
var
  lForm: TForm;
begin
  lForm := nil;
  try
    lForm := AClass.Create(Application);
    CaptureForm(lForm, AFileName);
  except
    on E: Exception do
      fIndex.Add(Format('| `%s` | — | ошибка создания: %s |',
        [AClass.ClassName, SafeText(E.Message)]));
  end;
  try
    lForm.Free;
  except
    on E: Exception do
      fIndex.Add(Format('| `%s` | — | ошибка освобождения: %s |',
        [AClass.ClassName, SafeText(E.Message)]));
  end;
  SaveIndex;
  Application.ProcessMessages;
end;

procedure TRecorderUserGuideCapture.CaptureCreatedForm(AForm: TForm;
  const AFileName: string);
begin
  try
    try
      CaptureForm(AForm, AFileName);
    except
      on E: Exception do
        fIndex.Add(Format('| `%s` | — | ошибка снимка: %s |',
          [AFileName, SafeText(E.Message)]));
    end;
  finally
    try
      AForm.Free;
    except
      on E: Exception do
        fIndex.Add(Format('| `%s` | — | ошибка освобождения: %s |',
          [AFileName, SafeText(E.Message)]));
    end;
  end;
  SaveIndex;
  Application.ProcessMessages;
end;

procedure TRecorderUserGuideCapture.SaveIndex;
begin
  fIndex.SaveToFile(fOutputDir + 'index.md');
end;

procedure TRecorderUserGuideCapture.CaptureAll;
const
  CForms: array[0..13] of TGuideFormSpec = (
    (FileName: '02-recorder-settings'; FormClass: TRecorderSettingsDialog),
    (FileName: '03-tag-settings'; FormClass: TTagSettingsDialog),
    (FileName: '04-virtual-tag'; FormClass: TRecorderVirtualTagDialog),
    (FileName: '05-device-search'; FormClass: TRecorderDeviceSearchDialog),
    (FileName: '06-calibration-list'; FormClass: TRecorderCalibrationListDialog),
    (FileName: '07-calibration-add'; FormClass: TRecorderCalibrationAddDialog),
    (FileName: '08-calibration-properties'; FormClass: TRecorderCalibrationPropertiesDialog),
    (FileName: '09-button-settings'; FormClass: TRecorderButtonSettingsDialog),
    (FileName: '11-measurement-section'; FormClass: TRecorderMeasurementSectionSettingsDialog),
    (FileName: '12-sql-db-settings'; FormClass: TRecorderSqlDbSettingsDialog),
    (FileName: '13-sql-trend-settings'; FormClass: TRecorderSqlTrendSettingsDialog),
    (FileName: '19-mc201-slot-settings'; FormClass: TRecorderMc201SlotSettingsDialog),
    (FileName: '20-strain-calibration'; FormClass: TRecorderStrainCalibrationDialog),
    (FileName: ''; FormClass: nil)
  );
var
  I: Integer;
  lForm: TForm;
begin
  fIndex.Add('# Автоматические снимки форм RecorderLnx');
  fIndex.Add('');
  fIndex.Add('| Форма | Снимок | Элементы |');
  fIndex.Add('|---|---|---|');
  CaptureForm(fMainForm, '01-main-form');
  for I := Low(CForms) to High(CForms) do
    if CForms[I].FormClass <> nil then
      CaptureClass(CForms[I].FormClass, CForms[I].FileName);
  lForm := CreateRecorderImageSettingsGuideForm(Application);
  CaptureCreatedForm(lForm, '10-image-settings');
  lForm := CreateRecorderMic185SettingsGuideForm(Application);
  CaptureCreatedForm(lForm, '16-mic185-settings');
  lForm := CreateRecorderMic185ChannelGuideForm(Application);
  CaptureCreatedForm(lForm, '17-mic185-channel');
  lForm := CreateRecorderMic185AdditionalGuideForm(Application);
  CaptureCreatedForm(lForm, '18-mic185-additional');
  lForm := CreateRecorderMic140SettingsGuideForm(Application);
  CaptureCreatedForm(lForm, '14-mic140-settings');
  lForm := CreateRecorderMic140ChannelGuideForm(Application);
  CaptureCreatedForm(lForm, '15-mic140-channel');
  lForm := CreateRecorderSdbSelectGuideForm(Application);
  CaptureCreatedForm(lForm, '21-sdb-select');
  SaveIndex;
end;

procedure StartRecorderUserGuideCapture(AMainForm: TForm;
  const AOutputDir: string);
begin
  FreeAndNil(gGuideCapture);
  gGuideCapture := TRecorderUserGuideCapture.Create(AMainForm, AOutputDir);
end;

finalization
  FreeAndNil(gGuideCapture);

end.
