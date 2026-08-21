unit uRecorderSqlTrendSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DateUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  Graphics, Math, DateTimePicker, EditBtn,
  uRecorderFormModel, uRecorderSqlTrendModel, uRecorderTags;

type
  TRecorderSqlTrendSettingsDialog = class(TForm)
    btnAddAxis: TButton;
    btnAddLine: TButton;
    btnColor: TButton;
    btnDeleteAxis: TButton;
    btnDeleteLine: TButton;
    btnDeleteDbInterval: TButton;
    btnLoadSignals: TButton;
    btnUseDbRange: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    btnAddDisplay: TButton;
    btnAutoAxes: TButton;
    btnAutoDisplays: TButton;
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
    edLineCaption: TEdit;
    edMaxPoints: TEdit;
    edWindowHours: TEdit;
    dtpToDate: TDateTimePicker;
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
    procedure btnDeleteDbIntervalClick(Sender: TObject);
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
    procedure btnAutoAxesClick(Sender: TObject);
    procedure btnAutoDisplaysClick(Sender: TObject);
    procedure btnDeleteDisplayClick(Sender: TObject);
    procedure DisplayChange(Sender: TObject);
    procedure DisplayNameExit(Sender: TObject);
  private
    fComponent: TRecorderSqlTrendComponent;
    fDraft: TRecorderSqlTrendComponent;
    fTagRegistry: TRecorderTagRegistry;
    fLineColor: TColor;
    fUpdatingTime: Boolean;
    fDbFromUtc: Double;
    fDbToUtc: Double;
    fDbPointCount: Int64;
    fFromDateEdit: TDateEdit;
    fToDateEdit: TDateEdit;
    procedure FillAxes;
    procedure FillDisplays;
    procedure FillLines;
    procedure LoadAxis;
    procedure LoadLine;
    procedure StoreAxis;
    procedure StoreLine;
    procedure ConfigureDatePicker(APicker: TDateTimePicker);
    procedure CreateDateEditFallbacks;
    procedure CreateDateEditFallback(APicker: TDateTimePicker;
      var AEdit: TDateEdit);
    procedure ConfigureDateEdit(AEdit: TDateEdit);
    function UseDateEditFallback: Boolean;
    function DateEditValue(AEdit: TDateEdit;
      APicker: TDateTimePicker): TDateTime;
    procedure SetDateEditValue(AEdit: TDateEdit;
      APicker: TDateTimePicker; AValue: TDateTime);
    procedure SetTimeEdits(AFromUtc, AToUtc: TDateTime);
    function FromUtcValue: TDateTime;
    function ToUtcValue: TDateTime;
    function CurrentDisplay: TRecorderSqlTrendDisplay;
    function DisplayNameForGroupPath(const AGroupPath: string): string;
    function FindDisplayByName(const AName: string): TRecorderSqlTrendDisplay;
    function FindLineByTagName(ADisplay: TRecorderSqlTrendDisplay;
      const ATagName: string): TRecorderTrendLine;
    function FindAxisByName(ADisplay: TRecorderSqlTrendDisplay;
      const AName: string): Integer;
    function TagAutoDisplayGroup(ATag: TRecorderTag): string;
    function AxisNameForTag(ATag: TRecorderTag): string;
    function EnsureAxisForTag(ADisplay: TRecorderSqlTrendDisplay;
      ATag: TRecorderTag): Integer;
    procedure AssignDisplayAxesByUnits(ADisplay: TRecorderSqlTrendDisplay);
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderSqlTrendComponent;
      ATagRegistry: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderSqlTrendSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderSqlTrendComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

{$R *.lfm}

uses
  uRecorderSqlDbTypes, uRecorderSqlDbRepository, uOglChartColors;

const
  CSqlTrendMainGroup = 'Основные каналы';
  CSqlTrendDefaultAxis = 'Y';

function ShowRecorderSqlTrendSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderSqlTrendComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderSqlTrendSettingsDialog;
begin
  lDialog := TRecorderSqlTrendSettingsDialog.CreateDialog(AOwner, AComponent,
    ATagRegistry);
  try Result := lDialog.ShowModal = mrOk; finally lDialog.Free; end;
end;

constructor TRecorderSqlTrendSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderSqlTrendComponent; ATagRegistry: TRecorderTagRegistry);
begin
  inherited Create(AOwner);
  fComponent := AComponent;
  fTagRegistry := ATagRegistry;
  fDraft := TRecorderSqlTrendComponent.Create;
  fDraft.AssignSqlTrend(AComponent);
  ConfigureDatePicker(dtpFromDate);
  ConfigureDatePicker(dtpToDate);
  CreateDateEditFallbacks;
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

function TRecorderSqlTrendSettingsDialog.DisplayNameForGroupPath(
  const AGroupPath: string): string;
begin
  Result := Trim(StringReplace(AGroupPath, '\', '-', [rfReplaceAll]));
  if Result = '' then
    Result := CSqlTrendMainGroup;
end;

function TRecorderSqlTrendSettingsDialog.FindDisplayByName(
  const AName: string): TRecorderSqlTrendDisplay;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fDraft.DisplayCount - 1 do
    if SameText(fDraft.Displays[I].Name, AName) then
      Exit(fDraft.Displays[I]);
end;

function TRecorderSqlTrendSettingsDialog.FindLineByTagName(
  ADisplay: TRecorderSqlTrendDisplay; const ATagName: string): TRecorderTrendLine;
var
  I: Integer;
begin
  Result := nil;
  if ADisplay = nil then
    Exit;
  for I := 0 to ADisplay.LineCount - 1 do
    if SameText(ADisplay.Lines[I].TagName, ATagName) then
      Exit(ADisplay.Lines[I]);
end;

function TRecorderSqlTrendSettingsDialog.FindAxisByName(
  ADisplay: TRecorderSqlTrendDisplay; const AName: string): Integer;
begin
  Result := -1;
  if ADisplay = nil then
    Exit;
  for Result := 0 to ADisplay.AxisCount - 1 do
    if SameText(ADisplay.Axes[Result].Name, AName) then
      Exit;
  Result := -1;
end;

function TRecorderSqlTrendSettingsDialog.TagAutoDisplayGroup(
  ATag: TRecorderTag): string;
begin
  Result := '';
  if ATag = nil then
    Exit;
  Result := Trim(ATag.GroupPath);
  Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  while Pos('\\', Result) > 0 do
    Result := StringReplace(Result, '\\', '\', [rfReplaceAll]);
  while (Length(Result) > 0) and (Result[1] = '\') do
    Delete(Result, 1, 1);
  while (Length(Result) > 0) and (Result[Length(Result)] = '\') do
    Delete(Result, Length(Result), 1);
  if SameText(Result, CSqlTrendMainGroup) then
    Result := '';
end;

function TRecorderSqlTrendSettingsDialog.AxisNameForTag(ATag: TRecorderTag): string;
begin
  Result := '';
  if ATag <> nil then
    Result := Trim(ATag.UnitName);
  if (Result = '') or (Result = '-') then
    Result := CSqlTrendDefaultAxis;
end;

function TRecorderSqlTrendSettingsDialog.EnsureAxisForTag(
  ADisplay: TRecorderSqlTrendDisplay; ATag: TRecorderTag): Integer;
var
  lAxis: TRecorderTrendAxis;
  lAxisName: string;
  lNewAxis: Boolean;
begin
  Result := 0;
  if ADisplay = nil then
    Exit;
  lAxisName := AxisNameForTag(ATag);
  Result := FindAxisByName(ADisplay, lAxisName);
  lNewAxis := Result < 0;
  if lNewAxis then
  begin
    lAxis := ADisplay.AddAxis;
    lAxis.Name := lAxisName;
    Result := ADisplay.AxisCount - 1;
  end
  else
    lAxis := ADisplay.Axes[Result];

  if (ATag <> nil) and (ATag.RangeMax > ATag.RangeMin) then
  begin
    if lNewAxis or (lAxis.RangeMax <= lAxis.RangeMin) then
    begin
      lAxis.RangeMin := ATag.RangeMin;
      lAxis.RangeMax := ATag.RangeMax;
    end
    else
    begin
      lAxis.RangeMin := Min(lAxis.RangeMin, ATag.RangeMin);
      lAxis.RangeMax := Max(lAxis.RangeMax, ATag.RangeMax);
    end;
  end;
end;

procedure TRecorderSqlTrendSettingsDialog.AssignDisplayAxesByUnits(
  ADisplay: TRecorderSqlTrendDisplay);
var
  I: Integer;
  lTag: TRecorderTag;
  lLine: TRecorderTrendLine;
begin
  if (ADisplay = nil) or (fTagRegistry = nil) then
    Exit;
  for I := 0 to ADisplay.LineCount - 1 do
  begin
    lLine := ADisplay.Lines[I];
    lTag := fTagRegistry.FindByName(lLine.TagName);
    if lTag <> nil then
      lLine.AxisIndex := EnsureAxisForTag(ADisplay, lTag);
  end;
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

procedure TRecorderSqlTrendSettingsDialog.ConfigureDatePicker(
  APicker: TDateTimePicker);
begin
  if APicker = nil then
    Exit;
  APicker.Enabled := True;
  APicker.ReadOnly := False;
  APicker.TabStop := True;
  APicker.Kind := dtkDate;
  APicker.DateMode := dmComboBox;
  APicker.ShowCheckBox := False;
  APicker.NullInputAllowed := False;
  APicker.UseDefaultSeparators := False;
  APicker.DateSeparator := '.';
  APicker.DateDisplayOrder := ddoDMY;
  APicker.LeadingZeros := True;
  APicker.AutoButtonSize := True;
end;

function TRecorderSqlTrendSettingsDialog.UseDateEditFallback: Boolean;
begin
  {$IFDEF UNIX}
  Result := True;
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

procedure TRecorderSqlTrendSettingsDialog.ConfigureDateEdit(AEdit: TDateEdit);
begin
  if AEdit = nil then
    Exit;
  AEdit.Enabled := True;
  AEdit.ReadOnly := False;
  AEdit.TabStop := True;
  AEdit.DirectInput := True;
  AEdit.DefaultToday := False;
  AEdit.DateOrder := doDMY;
  AEdit.DateFormat := 'dd.mm.yyyy';
  AEdit.ButtonOnlyWhenFocused := False;
  AEdit.OnChange := @TimeFromChange;
  AEdit.OnEditingDone := @TimeFromChange;
end;

procedure TRecorderSqlTrendSettingsDialog.CreateDateEditFallback(
  APicker: TDateTimePicker; var AEdit: TDateEdit);
begin
  if (APicker = nil) or (AEdit <> nil) then
    Exit;
  AEdit := TDateEdit.Create(Self);
  AEdit.Parent := APicker.Parent;
  AEdit.SetBounds(APicker.Left, APicker.Top, APicker.Width, APicker.Height);
  AEdit.Anchors := APicker.Anchors;
  AEdit.TabOrder := APicker.TabOrder;
  ConfigureDateEdit(AEdit);
  APicker.Visible := False;
end;

procedure TRecorderSqlTrendSettingsDialog.CreateDateEditFallbacks;
begin
  if not UseDateEditFallback then
    Exit;
  CreateDateEditFallback(dtpFromDate, fFromDateEdit);
  CreateDateEditFallback(dtpToDate, fToDateEdit);
end;

function TRecorderSqlTrendSettingsDialog.DateEditValue(AEdit: TDateEdit;
  APicker: TDateTimePicker): TDateTime;
begin
  if AEdit <> nil then
    Result := Trunc(AEdit.Date)
  else
    Result := Trunc(APicker.Date);
end;

procedure TRecorderSqlTrendSettingsDialog.SetDateEditValue(AEdit: TDateEdit;
  APicker: TDateTimePicker; AValue: TDateTime);
begin
  if APicker <> nil then
    APicker.Date := AValue;
  if AEdit <> nil then
    AEdit.Date := AValue;
end;

procedure TRecorderSqlTrendSettingsDialog.SetTimeEdits(AFromUtc,
  AToUtc: TDateTime);
begin
  fUpdatingTime := True;
  try
    fDraft.FromUtc := AFromUtc;
    fDraft.ToUtc := AToUtc;
    fDraft.DurationSec := Max(1.0, (AToUtc - AFromUtc) * SecsPerDay);
    SetDateEditValue(fFromDateEdit, dtpFromDate, Trunc(AFromUtc));
    if Frac(AToUtc) = 0 then
      SetDateEditValue(fToDateEdit, dtpToDate, Trunc(AToUtc - 1.0 / SecsPerDay))
    else
      SetDateEditValue(fToDateEdit, dtpToDate, Trunc(AToUtc));
    edWindowHours.Text := FloatToStrF(fDraft.DurationSec / SecsPerDay,
      ffFixed, 12, 6);
  finally
    fUpdatingTime := False;
  end;
end;

function TRecorderSqlTrendSettingsDialog.FromUtcValue: TDateTime;
begin
  Result := DateEditValue(fFromDateEdit, dtpFromDate);
end;

function TRecorderSqlTrendSettingsDialog.ToUtcValue: TDateTime;
begin
  Result := DateEditValue(fToDateEdit, dtpToDate) + 1.0;
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
var
  I: Integer;
  C: TRecorderSqlDbConfig;
  R: TRecorderSqlDbRepository;
  lInfos: TRecorderSqlDbSignalInfos;
begin
  lbDbSignals.Clear;
  try
    C := TRecorderSqlDbConfig.Create;
    try
      C.LoadFromFile(fDraft.ConfigFileName);
      R := TRecorderSqlDbRepository.Create(C);
      try
        R.ListSignalInfos(lInfos, False);
        for I := 0 to High(lInfos) do
          lbDbSignals.Items.Add(lInfos[I].Name);
        fDbPointCount := 0;
        lblDbRange.Caption := 'Каналы прочитаны. Диапазон БД не считался.';
        btnUseDbRange.Enabled := False;
      finally R.Free; end;
    finally C.Free; end;
  except on E: Exception do MessageDlg('SQL БД', E.Message, mtError, [mbOK], 0); end;
end;

procedure TRecorderSqlTrendSettingsDialog.btnDeleteDbIntervalClick(Sender: TObject);
var
  I: Integer;
  C: TRecorderSqlDbConfig;
  R: TRecorderSqlDbRepository;
  lNames: TStringList;
  lDeleted: Int64;
  lLine: TRecorderTrendLine;
begin
  lNames := TStringList.Create;
  try
    try
      lNames.CaseSensitive := False;
      lNames.Sorted := True;
      lNames.Duplicates := dupIgnore;
      for I := 0 to CurrentDisplay.LineCount - 1 do
      begin
        lLine := CurrentDisplay.Lines[I];
        if (lLine <> nil) and lLine.Visible and (Trim(lLine.TagName) <> '') then
          lNames.Add(lLine.TagName);
      end;
      if lNames.Count = 0 then
      begin
        MessageDlg('SQL БД', 'В текущем отображении нет видимых линий.',
          mtWarning, [mbOK], 0);
        Exit;
      end;
      if MessageDlg('SQL БД',
        Format('Удалить точки выбранного интервала UTC для видимых линий: %d?',
          [lNames.Count]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        Exit;
      C := TRecorderSqlDbConfig.Create;
      try
        C.LoadFromFile(fDraft.ConfigFileName);
        R := TRecorderSqlDbRepository.Create(C);
        try
          R.DeleteSignalValuesInterval(lNames, FromUtcValue, ToUtcValue,
            lDeleted);
        finally
          R.Free;
        end;
      finally
        C.Free;
      end;
      MessageDlg('SQL БД',
        Format('Удалено точек из интервала: %d.', [lDeleted]),
        mtInformation, [mbOK], 0);
      btnLoadSignalsClick(nil);
    except
      on E: Exception do
        MessageDlg('SQL БД', E.Message, mtError, [mbOK], 0);
    end;
  finally
    lNames.Free;
  end;
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
  L.TagName := lbDbSignals.Items[lbDbSignals.ItemIndex];
  if Pos(' (', L.TagName) > 0 then
    L.TagName := Copy(L.TagName, 1, Pos(' (', L.TagName) - 1);
  L.Name := L.TagName;
  OglChartLineAppearance(CurrentDisplay.LineCount - 1, lPaletteName, lPaletteColor);
  L.AxisIndex := 0; L.Color := lPaletteColor; L.Visible := True; L.Width := 1;
  FillLines; lbLines.ItemIndex := CurrentDisplay.LineCount - 1; LoadLine;
end;

procedure TRecorderSqlTrendSettingsDialog.btnAutoDisplaysClick(Sender: TObject);
var
  I: Integer;
  lTag: TRecorderTag;
  lGroupPath: string;
  lDisplayName: string;
  lDisplay: TRecorderSqlTrendDisplay;
  lLine: TRecorderTrendLine;
  lPaletteName: string;
  lPaletteColor: LongInt;
  lCreatedDisplays: Integer;
  lCreatedLines: Integer;
begin
  if fTagRegistry = nil then
  begin
    MessageDlg('SQL-тренд', 'Реестр тегов недоступен.', mtError, [mbOK], 0);
    Exit;
  end;
  StoreAxis;
  StoreLine;
  DisplayNameExit(nil);
  lCreatedDisplays := 0;
  lCreatedLines := 0;
  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    lGroupPath := TagAutoDisplayGroup(lTag);
    if lGroupPath = '' then
      Continue;
    lDisplayName := DisplayNameForGroupPath(lGroupPath);
    lDisplay := FindDisplayByName(lDisplayName);
    if lDisplay = nil then
    begin
      lDisplay := fDraft.AddDisplay(lDisplayName);
      Inc(lCreatedDisplays);
    end;
    if FindLineByTagName(lDisplay, lTag.Name) <> nil then
      Continue;
    lLine := lDisplay.AddLine;
    lLine.TagName := lTag.Name;
    lLine.Name := lTag.Name;
    OglChartLineAppearance(lDisplay.LineCount - 1, lPaletteName, lPaletteColor);
    lLine.AxisIndex := EnsureAxisForTag(lDisplay, lTag);
    lLine.Color := lPaletteColor;
    lLine.Visible := True;
    lLine.Width := 1;
    Inc(lCreatedLines);
  end;
  if lCreatedDisplays + lCreatedLines > 0 then
  begin
    FillDisplays;
    FillAxes;
    FillLines;
  end;
  MessageDlg('SQL-тренд',
    Format('Создано отображений: %d. Добавлено линий: %d.',
      [lCreatedDisplays, lCreatedLines]), mtInformation, [mbOK], 0);
end;

procedure TRecorderSqlTrendSettingsDialog.btnAutoAxesClick(Sender: TObject);
var
  I: Integer;
begin
  if fTagRegistry = nil then
  begin
    MessageDlg('SQL-тренд', 'Реестр тегов недоступен.', mtError, [mbOK], 0);
    Exit;
  end;
  StoreAxis;
  StoreLine;
  for I := 0 to fDraft.DisplayCount - 1 do
    AssignDisplayAxesByUnits(fDraft.Displays[I]);
  FillAxes;
  FillLines;
  MessageDlg('SQL-тренд', 'Оси назначены по единицам измерения тегов.',
    mtInformation, [mbOK], 0);
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
  if lToUtc <= lFromUtc then begin MessageDlg('Дата «До» должна быть не раньше даты «От»', mtError, [mbOK], 0); Exit; end;
  fDraft.FromUtc := lFromUtc;
  fDraft.ToUtc := lToUtc;
  fDraft.DurationSec := (lToUtc - lFromUtc) * SecsPerDay;
  if not TryStrToInt(edMaxPoints.Text, N) then N := 4000;
  fDraft.MaxPointsPerLine := EnsureRange(N, 32, 100000);
  fComponent.AssignSqlTrend(fDraft);
  ModalResult := mrOk;
end;

end.
