unit uRecorderSqlTrendSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DateUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  Graphics, Math, DateTimePicker,
  uRecorderSqlTrendModel;

type
  TRecorderSqlTrendSettingsDialog = class(TForm)
    btnAddAxis: TButton;
    btnAddLine: TButton;
    btnColor: TButton;
    btnDeleteAxis: TButton;
    btnDeleteLine: TButton;
    btnLoadSignals: TButton;
    btnUseDbRange: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    btnAddDisplay: TButton;
    btnDeleteDisplay: TButton;
    cbDisplay: TComboBox;
    cbLineAxis: TComboBox;
    cbLineVisible: TCheckBox;
    cbTimeMode: TComboBox;
    ColorDialog1: TColorDialog;
    edAxisMax: TEdit;
    edAxisMin: TEdit;
    edAxisName: TEdit;
    edDisplayName: TEdit;
    dtpFromDate: TDateTimePicker;
    dtpFromTime: TDateTimePicker;
    edLineCaption: TEdit;
    edMaxPoints: TEdit;
    edWindowHours: TEdit;
    dtpToDate: TDateTimePicker;
    dtpToTime: TDateTimePicker;
    gbAxes: TGroupBox;
    gbLines: TGroupBox;
    gbTime: TGroupBox;
    lblAxis: TLabel;
    lblAxisMax: TLabel;
    lblAxisMin: TLabel;
    lblAxisName: TLabel;
    lblFrom: TLabel;
    lblLineCaption: TLabel;
    lblMaxPoints: TLabel;
    lblWindowHours: TLabel;
    lblSignal: TLabel;
    lblTo: TLabel;
    lblDbRange: TLabel;
    lblDisplay: TLabel;
    lblDisplayName: TLabel;
    lbAxes: TListBox;
    lbDbSignals: TListBox;
    lbLines: TListBox;
    pnlLineColor: TPanel;
    procedure AxisSelectionChange(Sender: TObject; User: Boolean);
    procedure btnAddAxisClick(Sender: TObject);
    procedure btnAddLineClick(Sender: TObject);
    procedure btnColorClick(Sender: TObject);
    procedure btnDeleteAxisClick(Sender: TObject);
    procedure btnDeleteLineClick(Sender: TObject);
    procedure btnLoadSignalsClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure LineSelectionChange(Sender: TObject; User: Boolean);
    procedure AxisControlsExit(Sender: TObject);
    procedure LineControlsExit(Sender: TObject);
    procedure TimeFromChange(Sender: TObject);
    procedure TimeToChange(Sender: TObject);
    procedure TimeWindowEditingDone(Sender: TObject);
    procedure TimeModeChange(Sender: TObject);
    procedure btnUseDbRangeClick(Sender: TObject);
    procedure btnAddDisplayClick(Sender: TObject);
    procedure btnDeleteDisplayClick(Sender: TObject);
    procedure DisplayChange(Sender: TObject);
    procedure DisplayNameExit(Sender: TObject);
  private
    fComponent: TRecorderSqlTrendComponent;
    fDraft: TRecorderSqlTrendComponent;
    fLineColor: TColor;
    fUpdatingTime: Boolean;
    fDbFromUtc: Double;
    fDbToUtc: Double;
    fDbPointCount: Int64;
    procedure FillAxes;
    procedure FillDisplays;
    procedure FillLines;
    procedure LoadAxis;
    procedure LoadLine;
    procedure StoreAxis;
    procedure StoreLine;
    procedure SetTimeEdits(AFromUtc, AToUtc: TDateTime);
    function FromUtcValue: TDateTime;
    function ToUtcValue: TDateTime;
    function CurrentDisplay: TRecorderSqlTrendDisplay;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderSqlTrendComponent); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderSqlTrendSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderSqlTrendComponent): Boolean;

implementation

{$R *.lfm}

uses
  uRecorderFormModel, uRecorderSqlDbTypes, uRecorderSqlDbRepository,
  uOglChartColors;

function ShowRecorderSqlTrendSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderSqlTrendComponent): Boolean;
var
  lDialog: TRecorderSqlTrendSettingsDialog;
begin
  lDialog := TRecorderSqlTrendSettingsDialog.CreateDialog(AOwner, AComponent);
  try Result := lDialog.ShowModal = mrOk; finally lDialog.Free; end;
end;

constructor TRecorderSqlTrendSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderSqlTrendComponent);
begin
  inherited Create(AOwner);
  fComponent := AComponent;
  fDraft := TRecorderSqlTrendComponent.Create;
  fDraft.AssignSqlTrend(AComponent);
  cbTimeMode.ItemIndex := Ord(fDraft.TimeMode);
  if fDraft.TimeMode = sttmLatestWindow then
  begin
    fDraft.ToUtc := LocalTimeToUniversal(Now);
    fDraft.FromUtc := fDraft.ToUtc - fDraft.DurationSec / SecsPerDay;
  end;
  SetTimeEdits(fDraft.FromUtc, fDraft.ToUtc);
  edMaxPoints.Text := IntToStr(fDraft.MaxPointsPerLine);
  edWindowHours.Text := FloatToStr(fDraft.DurationSec / SecsPerDay);
  FillAxes;
  FillLines;
  FillDisplays;
end;

destructor TRecorderSqlTrendSettingsDialog.Destroy;
begin
  fDraft.Free;
  inherited Destroy;
end;

function TRecorderSqlTrendSettingsDialog.CurrentDisplay: TRecorderSqlTrendDisplay;
begin
  Result := fDraft.ActiveDisplay;
end;

procedure TRecorderSqlTrendSettingsDialog.FillDisplays;
var I: Integer;
begin
  cbDisplay.Clear;
  for I := 0 to fDraft.DisplayCount - 1 do
    cbDisplay.Items.Add(fDraft.Displays[I].Name);
  cbDisplay.ItemIndex := fDraft.ActiveDisplayIndex;
  if CurrentDisplay <> nil then edDisplayName.Text := CurrentDisplay.Name;
  btnDeleteDisplay.Enabled := fDraft.DisplayCount > 1;
end;

procedure TRecorderSqlTrendSettingsDialog.FillAxes;
var I: Integer;
begin
  lbAxes.Clear; cbLineAxis.Clear;
  for I := 0 to CurrentDisplay.AxisCount - 1 do
  begin
    lbAxes.Items.Add(CurrentDisplay.Axes[I].Name);
    cbLineAxis.Items.Add(CurrentDisplay.Axes[I].Name);
  end;
  if CurrentDisplay.AxisCount > 0 then begin lbAxes.ItemIndex := 0; LoadAxis; end;
end;

procedure TRecorderSqlTrendSettingsDialog.FillLines;
var I: Integer;
begin
  lbLines.Clear;
  for I := 0 to CurrentDisplay.LineCount - 1 do
    lbLines.Items.Add(CurrentDisplay.Lines[I].TagName + ' — ' + CurrentDisplay.Lines[I].Name);
  if CurrentDisplay.LineCount > 0 then begin lbLines.ItemIndex := 0; LoadLine; end;
end;

procedure TRecorderSqlTrendSettingsDialog.LoadAxis;
var A: TRecorderTrendAxis;
begin
  if lbAxes.ItemIndex < 0 then Exit;
  A := CurrentDisplay.Axes[lbAxes.ItemIndex];
  edAxisName.Text := A.Name; edAxisMin.Text := FloatToStr(A.RangeMin);
  edAxisMax.Text := FloatToStr(A.RangeMax);
end;

procedure TRecorderSqlTrendSettingsDialog.StoreAxis;
var A: TRecorderTrendAxis; V: Double;
begin
  if lbAxes.ItemIndex < 0 then Exit;
  A := CurrentDisplay.Axes[lbAxes.ItemIndex]; A.Name := Trim(edAxisName.Text);
  if TryStrToFloat(edAxisMin.Text, V) then A.RangeMin := V;
  if TryStrToFloat(edAxisMax.Text, V) then A.RangeMax := V;
end;

procedure TRecorderSqlTrendSettingsDialog.LoadLine;
var L: TRecorderTrendLine;
begin
  if lbLines.ItemIndex < 0 then Exit;
  L := CurrentDisplay.Lines[lbLines.ItemIndex]; edLineCaption.Text := L.Name;
  cbLineAxis.ItemIndex := L.AxisIndex; cbLineVisible.Checked := L.Visible;
  fLineColor := TColor(L.Color); btnColor.Color := fLineColor;
  pnlLineColor.Color := fLineColor;
end;

procedure TRecorderSqlTrendSettingsDialog.StoreLine;
var L: TRecorderTrendLine;
begin
  if lbLines.ItemIndex < 0 then Exit;
  L := CurrentDisplay.Lines[lbLines.ItemIndex]; L.Name := Trim(edLineCaption.Text);
  L.AxisIndex := Max(0, cbLineAxis.ItemIndex); L.Visible := cbLineVisible.Checked;
  L.Color := fLineColor;
end;

procedure TRecorderSqlTrendSettingsDialog.AxisSelectionChange(Sender: TObject;
  User: Boolean);
begin LoadAxis; end;

procedure TRecorderSqlTrendSettingsDialog.LineSelectionChange(Sender: TObject;
  User: Boolean);
begin LoadLine; end;

procedure TRecorderSqlTrendSettingsDialog.AxisControlsExit(Sender: TObject);
begin
  StoreAxis;
  if lbAxes.ItemIndex >= 0 then lbAxes.Items[lbAxes.ItemIndex] :=
    CurrentDisplay.Axes[lbAxes.ItemIndex].Name;
end;

procedure TRecorderSqlTrendSettingsDialog.LineControlsExit(Sender: TObject);
begin
  StoreLine;
  if lbLines.ItemIndex >= 0 then lbLines.Items[lbLines.ItemIndex] :=
    CurrentDisplay.Lines[lbLines.ItemIndex].TagName + ' — ' +
    CurrentDisplay.Lines[lbLines.ItemIndex].Name;
end;

procedure TRecorderSqlTrendSettingsDialog.SetTimeEdits(AFromUtc,
  AToUtc: TDateTime);
begin
  fUpdatingTime := True;
  try
    fDraft.FromUtc := AFromUtc;
    fDraft.ToUtc := AToUtc;
    fDraft.DurationSec := Max(1.0, (AToUtc - AFromUtc) * SecsPerDay);
    dtpFromDate.Date := Trunc(AFromUtc);
    dtpFromTime.Time := Frac(AFromUtc);
    dtpToDate.Date := Trunc(AToUtc);
    dtpToTime.Time := Frac(AToUtc);
    edWindowHours.Text := FloatToStrF(fDraft.DurationSec / SecsPerDay,
      ffFixed, 12, 6);
  finally
    fUpdatingTime := False;
  end;
end;

function TRecorderSqlTrendSettingsDialog.FromUtcValue: TDateTime;
begin
  Result := Trunc(dtpFromDate.Date) + Frac(dtpFromTime.Time);
end;

function TRecorderSqlTrendSettingsDialog.ToUtcValue: TDateTime;
begin
  Result := Trunc(dtpToDate.Date) + Frac(dtpToTime.Time);
end;

procedure TRecorderSqlTrendSettingsDialog.TimeFromChange(Sender: TObject);
var lFromUtc, lToUtc: TDateTime;
begin
  if fUpdatingTime then Exit;
  lFromUtc := FromUtcValue;
  lToUtc := ToUtcValue;
  if lToUtc > lFromUtc then
  begin
    fDraft.TimeMode := sttmFixedUtc;
    cbTimeMode.ItemIndex := Ord(sttmFixedUtc);
    SetTimeEdits(lFromUtc, lToUtc);
  end;
end;

procedure TRecorderSqlTrendSettingsDialog.TimeToChange(Sender: TObject);
begin
  TimeFromChange(Sender);
end;

procedure TRecorderSqlTrendSettingsDialog.TimeWindowEditingDone(Sender: TObject);
var lDays: Double; lToUtc: TDateTime;
begin
  if fUpdatingTime then Exit;
  if TryStrToFloat(Trim(edWindowHours.Text), lDays) and (lDays > 0) then
  begin
    lToUtc := ToUtcValue;
    fDraft.TimeMode := sttmFixedUtc;
    cbTimeMode.ItemIndex := Ord(sttmFixedUtc);
    SetTimeEdits(lToUtc - lDays, lToUtc);
  end
  else
    edWindowHours.Color := $00D0D0FF;
end;

procedure TRecorderSqlTrendSettingsDialog.TimeModeChange(Sender: TObject);
var lToUtc: TDateTime;
begin
  if fUpdatingTime then Exit;
  fDraft.TimeMode := TRecorderSqlTrendTimeMode(Max(0, cbTimeMode.ItemIndex));
  if fDraft.TimeMode = sttmLatestWindow then
  begin
    lToUtc := LocalTimeToUniversal(Now);
    SetTimeEdits(lToUtc - fDraft.DurationSec / SecsPerDay, lToUtc);
  end;
end;

procedure TRecorderSqlTrendSettingsDialog.btnAddAxisClick(Sender: TObject);
var A: TRecorderTrendAxis;
begin
  StoreAxis; A := CurrentDisplay.AddAxis; A.Name := 'Y' + IntToStr(CurrentDisplay.AxisCount);
  FillAxes; lbAxes.ItemIndex := CurrentDisplay.AxisCount - 1; LoadAxis;
end;

procedure TRecorderSqlTrendSettingsDialog.btnDeleteAxisClick(Sender: TObject);
begin
  if (lbAxes.ItemIndex < 0) or (CurrentDisplay.AxisCount <= 1) then Exit;
  CurrentDisplay.DeleteAxis(lbAxes.ItemIndex); FillAxes;
end;

procedure TRecorderSqlTrendSettingsDialog.btnLoadSignalsClick(Sender: TObject);
var C: TRecorderSqlDbConfig; R: TRecorderSqlDbRepository;
begin
  lbDbSignals.Clear;
  try
    C := TRecorderSqlDbConfig.Create;
    try
      C.LoadFromFile(fDraft.ConfigFileName);
      R := TRecorderSqlDbRepository.Create(C);
      try
        R.ListSignalNames(lbDbSignals.Items);
        if R.GetTrendTimeRange(fDbFromUtc, fDbToUtc, fDbPointCount) then
        begin
          lblDbRange.Caption := Format('В БД: %d точек, UTC %s — %s',
            [fDbPointCount,
             FormatDateTime('dd.mm.yyyy hh:nn:ss', fDbFromUtc),
             FormatDateTime('dd.mm.yyyy hh:nn:ss', fDbToUtc)]);
          btnUseDbRange.Enabled := True;
        end
        else
        begin
          lblDbRange.Caption := 'В БД пока нет значений сигналов';
          btnUseDbRange.Enabled := False;
        end;
      finally R.Free; end;
    finally C.Free; end;
  except on E: Exception do MessageDlg('SQL БД', E.Message, mtError, [mbOK], 0); end;
end;

procedure TRecorderSqlTrendSettingsDialog.btnUseDbRangeClick(Sender: TObject);
begin
  if fDbPointCount <= 0 then Exit;
  fDraft.TimeMode := sttmFixedUtc;
  cbTimeMode.ItemIndex := Ord(sttmFixedUtc);
  SetTimeEdits(fDbFromUtc, fDbToUtc);
end;

procedure TRecorderSqlTrendSettingsDialog.btnAddLineClick(Sender: TObject);
var L: TRecorderTrendLine; lPaletteName: string; lPaletteColor: LongInt;
begin
  if lbDbSignals.ItemIndex < 0 then Exit;
  StoreLine; L := CurrentDisplay.AddLine;
  L.TagName := lbDbSignals.Items[lbDbSignals.ItemIndex]; L.Name := L.TagName;
  OglChartLineAppearance(CurrentDisplay.LineCount - 1, lPaletteName, lPaletteColor);
  L.AxisIndex := 0; L.Color := lPaletteColor; L.Visible := True; L.Width := 1;
  FillLines; lbLines.ItemIndex := CurrentDisplay.LineCount - 1; LoadLine;
end;

procedure TRecorderSqlTrendSettingsDialog.btnDeleteLineClick(Sender: TObject);
begin
  if lbLines.ItemIndex < 0 then Exit;
  CurrentDisplay.DeleteLine(lbLines.ItemIndex); FillLines;
end;

procedure TRecorderSqlTrendSettingsDialog.btnColorClick(Sender: TObject);
begin
  ColorDialog1.Color := fLineColor;
  if ColorDialog1.Execute then
  begin
    fLineColor := ColorDialog1.Color;
    pnlLineColor.Color := fLineColor;
    StoreLine;
  end;
end;

procedure TRecorderSqlTrendSettingsDialog.DisplayNameExit(Sender: TObject);
begin
  if (CurrentDisplay <> nil) and (Trim(edDisplayName.Text) <> '') then
  begin
    CurrentDisplay.Name := Trim(edDisplayName.Text);
    if cbDisplay.ItemIndex >= 0 then
      cbDisplay.Items[cbDisplay.ItemIndex] := CurrentDisplay.Name;
  end;
end;

procedure TRecorderSqlTrendSettingsDialog.DisplayChange(Sender: TObject);
begin
  StoreAxis;
  StoreLine;
  fDraft.ActiveDisplayIndex := cbDisplay.ItemIndex;
  edDisplayName.Text := CurrentDisplay.Name;
  FillAxes;
  FillLines;
end;

procedure TRecorderSqlTrendSettingsDialog.btnAddDisplayClick(Sender: TObject);
begin
  StoreAxis;
  StoreLine;
  fDraft.AddDisplay;
  fDraft.ActiveDisplayIndex := fDraft.DisplayCount - 1;
  FillDisplays;
  FillAxes;
  FillLines;
  edDisplayName.SetFocus;
  edDisplayName.SelectAll;
end;

procedure TRecorderSqlTrendSettingsDialog.btnDeleteDisplayClick(Sender: TObject);
begin
  if fDraft.DisplayCount <= 1 then Exit;
  fDraft.DeleteDisplay(fDraft.ActiveDisplayIndex);
  FillDisplays;
  FillAxes;
  FillLines;
end;

procedure TRecorderSqlTrendSettingsDialog.btnOkClick(Sender: TObject);
var lFromUtc, lToUtc: TDateTime; N: Integer;
begin
  StoreAxis; StoreLine; DisplayNameExit(nil);
  fDraft.TimeMode := TRecorderSqlTrendTimeMode(Max(0, cbTimeMode.ItemIndex));
  lFromUtc := FromUtcValue;
  lToUtc := ToUtcValue;
  if lToUtc <= lFromUtc then begin MessageDlg('Время «До» должно быть позже времени «От»', mtError, [mbOK], 0); Exit; end;
  fDraft.FromUtc := lFromUtc;
  fDraft.ToUtc := lToUtc;
  fDraft.DurationSec := (lToUtc - lFromUtc) * SecsPerDay;
  if not TryStrToInt(edMaxPoints.Text, N) then N := 4000;
  fDraft.MaxPointsPerLine := EnsureRange(N, 32, 100000);
  fComponent.AssignSqlTrend(fDraft);
  ModalResult := mrOk;
end;

end.
