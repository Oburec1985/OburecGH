unit uRecorderSqlTrendSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DateUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  Graphics, Math, DateTimePicker, EditBtn,
  uRecorderFormModel, uRecorderSqlTrendModel, uRecorderTags,
  uRecorderSqlDbTypes;

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
    btnImportAutoDisplays: TButton;
    btnDeleteDisplay: TButton;
    cbDisplay: TComboBox;
    cbLineAxis: TComboBox;
    cbLineVisible: TCheckBox;
    cbOnlyRecorderTags: TCheckBox;
    cbShowEvents: TCheckBox;
    cbShowRecordingEvents: TCheckBox;
    cbShowTagAlarmEvents: TCheckBox;
    cbShowTagRangeEvents: TCheckBox;
    cbShowOnlyUnresolvedEvents: TCheckBox;
    cbCurrentDate: TCheckBox;
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
    lblDbRange: TLabel;
    lblDisplay: TLabel;
    lblDisplayName: TLabel;
    lbAxes: TListBox;
    lbDbSignals: TListBox;
    lbLines: TListBox;
    pnlLineColor: TPanel;
    procedure AxisSelectionChange({%H-}Sender: TObject; {%H-}User: Boolean);
    procedure btnAddAxisClick({%H-}Sender: TObject);
    procedure btnAddLineClick({%H-}Sender: TObject);
    procedure btnColorClick({%H-}Sender: TObject);
    procedure btnDeleteAxisClick({%H-}Sender: TObject);
    procedure btnDeleteDbIntervalClick({%H-}Sender: TObject);
    procedure btnDeleteLineClick({%H-}Sender: TObject);
    procedure btnLoadSignalsClick({%H-}Sender: TObject);
    procedure btnOkClick({%H-}Sender: TObject);
    procedure LineSelectionChange({%H-}Sender: TObject; {%H-}User: Boolean);
    procedure AxisControlsExit({%H-}Sender: TObject);
    procedure LineControlsExit({%H-}Sender: TObject);
    procedure TimeFromChange({%H-}Sender: TObject);
    procedure CurrentDateChange({%H-}Sender: TObject);
    procedure TimeToChange({%H-}Sender: TObject);
    procedure TimeWindowEditingDone({%H-}Sender: TObject);
    procedure TimeModeChange({%H-}Sender: TObject);
    procedure btnUseDbRangeClick({%H-}Sender: TObject);
    procedure btnAddDisplayClick({%H-}Sender: TObject);
    procedure btnAutoAxesClick({%H-}Sender: TObject);
    procedure btnAutoDisplaysClick({%H-}Sender: TObject);
    procedure btnImportAutoDisplaysClick({%H-}Sender: TObject);
    procedure btnDeleteDisplayClick({%H-}Sender: TObject);
    procedure DisplayChange({%H-}Sender: TObject);
    procedure DisplayNameExit({%H-}Sender: TObject);
    procedure ShowEventsChange({%H-}Sender: TObject);
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
    fBottomPanel: TPanel;
    procedure FormResize(Sender: TObject);
    procedure ConfigureLayout;
    procedure LayoutDialog;
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
    procedure UpdateCurrentDateControls;
    procedure UpdateEventFilterControls;
    function FromUtcValue: TDateTime;
    function ToUtcValue: TDateTime;
    function CurrentDisplay: TRecorderSqlTrendDisplay;
    function DisplayNameForGroupPath(const AGroupPath: string): string;
    function FindDisplayByName(const AName: string): TRecorderSqlTrendDisplay;
    function FindLineByTagName(ADisplay: TRecorderSqlTrendDisplay;
      const ATagName: string): TRecorderTrendLine;
    function FindAxisByName(ADisplay: TRecorderSqlTrendDisplay;
      const AName: string): Integer;
    function FindDbSignalName(const AName: string): string;
    function TagAutoDisplayGroup(ATag: TRecorderTag): string;
    function AxisNameForTag(ATag: TRecorderTag): string;
    function EnsureAxisForTag(ADisplay: TRecorderSqlTrendDisplay;
      ATag: TRecorderTag): Integer;
    procedure AssignDisplayAxesByUnits(ADisplay: TRecorderSqlTrendDisplay);
    function SignalCacheIdentity(AConfig: TRecorderSqlDbConfig): string;
    procedure LoadCachedSignals;
    procedure SaveCachedSignals(AConfig: TRecorderSqlDbConfig;
      ANames: TStrings);
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
  IniFiles, uRecorderSqlDbRepository, uOglChartColors, uRecorderTagTableExchange;

const
  CSqlTrendMainGroup = 'Основные каналы';
  CSqlTrendDefaultAxis = 'Y';
  CSqlTrendSignalCacheSection = 'SqlTrendSignalCache';

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
  ConfigureLayout;
  fComponent := AComponent;
  fTagRegistry := ATagRegistry;
  fDraft := TRecorderSqlTrendComponent.Create;
  fDraft.AssignSqlTrend(AComponent);
  ConfigureDatePicker(dtpFromDate);
  ConfigureDatePicker(dtpToDate);
  CreateDateEditFallbacks;
  cbTimeMode.ItemIndex := Ord(fDraft.TimeMode);
  cbCurrentDate.Checked := fDraft.TimeMode = sttmFixedFromToCurrentUtc;
  if cbCurrentDate.Checked then
  begin
    cbTimeMode.ItemIndex := Ord(sttmFixedUtc);
    fDraft.ToUtc := LocalTimeToUniversal(Now);
  end;
  UpdateCurrentDateControls;
  if fDraft.TimeMode = sttmLatestWindow then
  begin
    fDraft.ToUtc := LocalTimeToUniversal(Now);
    fDraft.FromUtc := fDraft.ToUtc - fDraft.DurationSec / SecsPerDay;
  end;
  SetTimeEdits(fDraft.FromUtc, fDraft.ToUtc);
  edMaxPoints.Text := IntToStr(fDraft.MaxPointsPerLine);
  cbShowEvents.Checked := fDraft.ShowEvents;
  cbShowRecordingEvents.Checked := fDraft.ShowRecordingEvents;
  cbShowTagAlarmEvents.Checked := fDraft.ShowTagAlarmEvents;
  cbShowTagRangeEvents.Checked := fDraft.ShowTagRangeEvents;
  cbShowOnlyUnresolvedEvents.Checked := fDraft.ShowOnlyUnresolvedEventPoints;
  cbOnlyRecorderTags.Checked := fDraft.OnlyRecorderTags;
  UpdateEventFilterControls;
  edWindowHours.Text := FloatToStr(fDraft.DurationSec / SecsPerDay);
  FillAxes;
  FillLines;
  FillDisplays;
  LoadCachedSignals;
end;

procedure TRecorderSqlTrendSettingsDialog.ConfigureLayout;
begin
  AutoScroll := False;
  Constraints.MinHeight := 740;

  fBottomPanel := TPanel.Create(Self);
  fBottomPanel.Parent := Self;
  fBottomPanel.Align := alBottom;
  fBottomPanel.Height := 244;
  fBottomPanel.BevelOuter := bvNone;

  gbTime.Parent := fBottomPanel;
  btnOk.Parent := fBottomPanel;
  btnCancel.Parent := fBottomPanel;

  gbLines.Anchors := [akTop, akLeft, akRight, akBottom];
  gbAxes.Anchors := [akLeft, akRight, akBottom];
  btnImportAutoDisplays.Width := Max(190,
    Canvas.TextWidth(btnImportAutoDisplays.Caption) + 32);
  cbOnlyRecorderTags.Width := Max(180,
    Canvas.TextWidth(cbOnlyRecorderTags.Caption) + 30);

  OnResize := @FormResize;
  LayoutDialog;
end;

procedure TRecorderSqlTrendSettingsDialog.FormResize(Sender: TObject);
begin
  LayoutDialog;
end;

procedure TRecorderSqlTrendSettingsDialog.LayoutDialog;
const
  COuterMargin = 8;
  CSectionGap = 8;
  CAxesHeight = 130;
  CTimeHeight = 198;
  CButtonHeight = 30;
var
  lAxesTop: Integer;
begin
  if fBottomPanel = nil then Exit;

  { Keep the filter checkbox and its native check mark completely separate
    from the import button.  Placing the checkbox to the right left only the
    remaining few pixels at some Linux DPI/font combinations, so the button
    visually covered the check mark. }
  btnImportAutoDisplays.Left := ClientWidth - COuterMargin -
    btnImportAutoDisplays.Width;
  cbOnlyRecorderTags.Left := Max(COuterMargin,
    btnImportAutoDisplays.Left - CSectionGap - cbOnlyRecorderTags.Width);
  cbOnlyRecorderTags.Top := btnImportAutoDisplays.Top +
    (btnImportAutoDisplays.Height - cbOnlyRecorderTags.Height) div 2;

  gbTime.SetBounds(COuterMargin, 0,
    Max(1, fBottomPanel.ClientWidth - 2 * COuterMargin), CTimeHeight);
  btnCancel.SetBounds(fBottomPanel.ClientWidth - COuterMargin -
    btnCancel.Width, CTimeHeight + CSectionGap, btnCancel.Width,
    CButtonHeight);
  btnOk.SetBounds(btnCancel.Left - CSectionGap - btnOk.Width,
    btnCancel.Top, btnOk.Width, CButtonHeight);

  lAxesTop := fBottomPanel.Top - CSectionGap - CAxesHeight;
  gbAxes.SetBounds(COuterMargin, lAxesTop,
    Max(1, ClientWidth - 2 * COuterMargin), CAxesHeight);
  gbLines.SetBounds(COuterMargin, gbLines.Top,
    Max(1, ClientWidth - 2 * COuterMargin),
    Max(1, lAxesTop - CSectionGap - gbLines.Top));
end;

destructor TRecorderSqlTrendSettingsDialog.Destroy;
begin
  fDraft.Free;
  inherited Destroy;
end;

function TRecorderSqlTrendSettingsDialog.SignalCacheIdentity(
  AConfig: TRecorderSqlDbConfig): string;
var
  lHost: string;
begin
  lHost := Trim(AConfig.Host);
  if lHost = '' then
    lHost := 'local';
  Result := Format('%s|%s|%d|%s', [
    RecorderSqlDbBackendToString(AConfig.Backend), lHost, AConfig.Port,
    AConfig.DatabaseFileName]) + '|recorder=' +
    BoolToStr(fDraft.OnlyRecorderTags, True);
end;

procedure TRecorderSqlTrendSettingsDialog.LoadCachedSignals;
var
  I, lCount: Integer;
  lConfig: TRecorderSqlDbConfig;
  lIni: TIniFile;
  lName: string;
begin
  lbDbSignals.Clear;
  if (Trim(fDraft.ConfigFileName) = '') or
    (not FileExists(fDraft.ConfigFileName)) then
    Exit;
  try
    lConfig := TRecorderSqlDbConfig.Create;
    try
      lConfig.LoadFromFile(fDraft.ConfigFileName);
      lIni := TIniFile.Create(fDraft.ConfigFileName);
      try
        if lIni.ReadString(CSqlTrendSignalCacheSection, 'Connection', '') <>
          SignalCacheIdentity(lConfig) then
          Exit;
        lCount := EnsureRange(lIni.ReadInteger(CSqlTrendSignalCacheSection,
          'Count', 0), 0, 100000);
        for I := 0 to lCount - 1 do
        begin
          lName := lIni.ReadString(CSqlTrendSignalCacheSection,
            'Signal' + IntToStr(I), '');
          if lName <> '' then
            lbDbSignals.Items.Add(lName);
        end;
      finally
        lIni.Free;
      end;
    finally
      lConfig.Free;
    end;
    if lbDbSignals.Count > 0 then
      lblDbRange.Caption := Format(
        'Каналы загружены из кэша: %d. Диапазон БД не считывался.',
        [lbDbSignals.Count]);
  except
    on E: Exception do
    begin
      lbDbSignals.Clear;
      lblDbRange.Caption := 'Кэш каналов не загружен: ' + E.Message;
    end;
  end;
end;

procedure TRecorderSqlTrendSettingsDialog.SaveCachedSignals(
  AConfig: TRecorderSqlDbConfig; ANames: TStrings);
var
  I: Integer;
  lDirectory: string;
  lIni: TIniFile;
begin
  if Trim(fDraft.ConfigFileName) = '' then
    Exit;
  lDirectory := ExtractFileDir(ExpandFileName(fDraft.ConfigFileName));
  if (lDirectory <> '') and (not ForceDirectories(lDirectory)) then
    raise ERecorderSqlDbError.CreateFmt(
      'Не удалось создать каталог кэша SQL-тренда: %s', [lDirectory]);
  lIni := TIniFile.Create(fDraft.ConfigFileName);
  try
    lIni.EraseSection(CSqlTrendSignalCacheSection);
    lIni.WriteString(CSqlTrendSignalCacheSection, 'Connection',
      SignalCacheIdentity(AConfig));
    lIni.WriteInteger(CSqlTrendSignalCacheSection, 'Count', ANames.Count);
    for I := 0 to ANames.Count - 1 do
      lIni.WriteString(CSqlTrendSignalCacheSection, 'Signal' + IntToStr(I),
        ANames[I]);
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
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

function TRecorderSqlTrendSettingsDialog.FindDbSignalName(
  const AName: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to lbDbSignals.Items.Count - 1 do
    if SameText(lbDbSignals.Items[I], AName) then
      Exit(lbDbSignals.Items[I]);
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
    lbLines.Items.Add(CurrentDisplay.Lines[I].TagName + UTF8Encode(' — ') +
      CurrentDisplay.Lines[I].Name);
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
    CurrentDisplay.Lines[lbLines.ItemIndex].TagName + UTF8Encode(' — ') +
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
  if fToDateEdit <> nil then
  begin
    fToDateEdit.OnChange := @TimeToChange;
    fToDateEdit.OnEditingDone := @TimeToChange;
  end;
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
var
  lFromLocal, lToLocal: TDateTime;
begin
  fUpdatingTime := True;
  try
    fDraft.FromUtc := AFromUtc;
    fDraft.ToUtc := AToUtc;
    fDraft.DurationSec := Max(1.0, (AToUtc - AFromUtc) * SecsPerDay);
    { The repository contract is UTC, while the date controls are explicitly
      user-facing local calendar dates. Keeping UTC values in these controls
      silently shifted the selected day on hosts in another time zone. }
    lFromLocal := UniversalTimeToLocal(AFromUtc);
    lToLocal := UniversalTimeToLocal(AToUtc);
    SetDateEditValue(fFromDateEdit, dtpFromDate, Trunc(lFromLocal));
    if Frac(lToLocal) = 0 then
      SetDateEditValue(fToDateEdit, dtpToDate,
        Trunc(lToLocal - 1.0 / SecsPerDay))
    else
      SetDateEditValue(fToDateEdit, dtpToDate, Trunc(lToLocal));
    edWindowHours.Text := FloatToStrF(fDraft.DurationSec / SecsPerDay,
      ffFixed, 12, 6);
  finally
    fUpdatingTime := False;
  end;
end;

function TRecorderSqlTrendSettingsDialog.FromUtcValue: TDateTime;
begin
  Result := LocalTimeToUniversal(DateEditValue(fFromDateEdit, dtpFromDate));
end;

function TRecorderSqlTrendSettingsDialog.ToUtcValue: TDateTime;
begin
  Result := LocalTimeToUniversal(
    DateEditValue(fToDateEdit, dtpToDate) + 1.0);
end;

procedure TRecorderSqlTrendSettingsDialog.TimeFromChange(Sender: TObject);
var lFromUtc, lToUtc: TDateTime;
begin
  if fUpdatingTime then Exit;
  lFromUtc := FromUtcValue;
  if cbCurrentDate.Checked then
    lToUtc := LocalTimeToUniversal(Now)
  else
    lToUtc := ToUtcValue;
  if lToUtc > lFromUtc then
  begin
    if cbCurrentDate.Checked then
      fDraft.TimeMode := sttmFixedFromToCurrentUtc
    else
      fDraft.TimeMode := sttmFixedUtc;
    cbTimeMode.ItemIndex := Ord(sttmFixedUtc);
    SetTimeEdits(lFromUtc, lToUtc);
  end;
end;

procedure TRecorderSqlTrendSettingsDialog.TimeToChange(Sender: TObject);
begin
  if not fUpdatingTime then
    cbCurrentDate.Checked := False;
  TimeFromChange(Sender);
end;

procedure TRecorderSqlTrendSettingsDialog.CurrentDateChange(Sender: TObject);
var
  lTodayUtc: TDateTime;
begin
  if fUpdatingTime then Exit;
  if cbCurrentDate.Checked then
  begin
    { The picker displays a local calendar date; stored/query times remain UTC. }
    lTodayUtc := Trunc(Now);
    fUpdatingTime := True;
    try
      cbTimeMode.ItemIndex := Ord(sttmFixedUtc);
      SetDateEditValue(fToDateEdit, dtpToDate, lTodayUtc);
    finally
      fUpdatingTime := False;
    end;
    fDraft.TimeMode := sttmFixedFromToCurrentUtc;
  end
  else
    fDraft.TimeMode := sttmFixedUtc;
  UpdateCurrentDateControls;
end;

procedure TRecorderSqlTrendSettingsDialog.UpdateCurrentDateControls;
begin
  dtpToDate.Enabled := not cbCurrentDate.Checked;
  if fToDateEdit <> nil then
    fToDateEdit.Enabled := not cbCurrentDate.Checked;
end;

{
  Галочки семейств событий дублируют контекстное меню тренда. Верхняя
  «Отображать события» полностью отключает маркеры, остальные три доступны
  только при ней. Имена записи/аварий/уставок совпадают с триггерами SQL.
}
procedure TRecorderSqlTrendSettingsDialog.UpdateEventFilterControls;
var
  lEnabled: Boolean;
begin
  lEnabled := cbShowEvents.Checked;
  cbShowRecordingEvents.Enabled := lEnabled;
  cbShowTagAlarmEvents.Enabled := lEnabled;
  cbShowTagRangeEvents.Enabled := lEnabled;
  cbShowOnlyUnresolvedEvents.Enabled := lEnabled;
end;

procedure TRecorderSqlTrendSettingsDialog.ShowEventsChange(Sender: TObject);
begin
  UpdateEventFilterControls;
end;

procedure TRecorderSqlTrendSettingsDialog.TimeWindowEditingDone(Sender: TObject);
var lDays: Double; lToUtc: TDateTime;
begin
  if fUpdatingTime then Exit;
  if TryStrToFloat(Trim(edWindowHours.Text), lDays) and (lDays > 0) then
  begin
    lToUtc := ToUtcValue;
    fDraft.TimeMode := sttmFixedUtc;
    cbCurrentDate.Checked := False;
    cbTimeMode.ItemIndex := Ord(sttmFixedUtc);
    SetTimeEdits(lToUtc - lDays, lToUtc);
  end
  else
    edWindowHours.Color := $00D0D0FF;
end;

procedure TRecorderSqlTrendSettingsDialog.TimeModeChange(Sender: TObject);
var
  lToUtc: TDateTime;
  lMode: TRecorderSqlTrendTimeMode;
begin
  if fUpdatingTime then Exit;
  lMode := TRecorderSqlTrendTimeMode(Max(0, cbTimeMode.ItemIndex));
  fUpdatingTime := True;
  try
    cbCurrentDate.Checked := False;
  finally
    fUpdatingTime := False;
  end;
  UpdateCurrentDateControls;
  fDraft.TimeMode := lMode;
  if lMode = sttmLatestWindow then
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
  lNames: TStringList;
begin
  lNames := TStringList.Create;
  try
    try
      C := TRecorderSqlDbConfig.Create;
      try
        C.LoadFromFile(fDraft.ConfigFileName);
        R := TRecorderSqlDbRepository.Create(C);
        try
          R.ListSignalInfos(lInfos, False);
          for I := 0 to High(lInfos) do
            if (not cbOnlyRecorderTags.Checked) or
              (not SameText(Trim(lInfos[I].RecorderSourceId), 'SQL database')) then
              lNames.Add(lInfos[I].Name);
        finally
          R.Free;
        end;
        SaveCachedSignals(C, lNames);
      finally
        C.Free;
      end;
      lbDbSignals.Items.Assign(lNames);
      fDbPointCount := 0;
      lblDbRange.Caption := Format(
        'Каналы прочитаны и сохранены в кэш: %d. Диапазон БД не считывался.',
        [lbDbSignals.Count]);
      btnUseDbRange.Enabled := False;
    except
      on E: Exception do
        MessageDlg('SQL БД', E.Message, mtError, [mbOK], 0);
    end;
  finally
    lNames.Free;
  end;
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

procedure TRecorderSqlTrendSettingsDialog.btnImportAutoDisplaysClick(Sender: TObject);
var
  D: TOpenDialog;
  Items: TRecorderTableChannelGroups;
  I, Added, Created, Missing: Integer;
  lName, GroupPath, PaletteName: string;
  Display: TRecorderSqlTrendDisplay;
  Line: TRecorderTrendLine;
  PaletteColor: LongInt;
begin
  D := TOpenDialog.Create(Self);
  try
    D.Title := 'Импорт авто отображений';
    D.Filter := 'Таблицы (*.xlsx;*.ods;*.csv)|*.xlsx;*.ods;*.csv';
    D.Options := D.Options + [ofFileMustExist];
    if not D.Execute then Exit;
    try
      ReadRecorderChannelGroupsFromTable(D.FileName, Items);
    except
      on E: Exception do begin MessageDlg('Импорт', E.Message, mtError, [mbOK], 0); Exit; end;
    end;
  finally
    D.Free;
  end;
  if lbDbSignals.Items.Count = 0 then
  begin
    MessageDlg('Импорт', 'Сначала прочитайте каналы из БД.', mtWarning, [mbOK], 0);
    Exit;
  end;
  StoreAxis; StoreLine; DisplayNameExit(nil);
  Added := 0; Created := 0; Missing := 0;
  for I := 0 to High(Items) do
  begin
    lName := FindDbSignalName(Items[I].Name);
    if lName = '' then begin Inc(Missing); Continue; end;
    GroupPath := Trim(StringReplace(Items[I].GroupPath, '/', '\', [rfReplaceAll]));
    while Pos('\\', GroupPath) > 0 do GroupPath := StringReplace(GroupPath, '\\', '\', [rfReplaceAll]);
    while (Length(GroupPath) > 0) and (GroupPath[1] = '\') do Delete(GroupPath, 1, 1);
    while (Length(GroupPath) > 0) and (GroupPath[Length(GroupPath)] = '\') do Delete(GroupPath, Length(GroupPath), 1);
    if (GroupPath = '') or SameText(GroupPath, CSqlTrendMainGroup) then Continue;
    Display := FindDisplayByName(DisplayNameForGroupPath(GroupPath));
    if Display = nil then begin Display := fDraft.AddDisplay(DisplayNameForGroupPath(GroupPath)); Inc(Created); end;
    if FindLineByTagName(Display, lName) <> nil then Continue;
    Line := Display.AddLine; Line.TagName := lName; Line.Name := lName;
    OglChartLineAppearance(Display.LineCount - 1, PaletteName, PaletteColor);
    Line.AxisIndex := EnsureAxisForTag(Display, nil);
    Line.Color := PaletteColor; Line.Visible := True; Line.Width := 1;
    Inc(Added);
  end;
  FillDisplays; FillAxes; FillLines;
  MessageDlg('Импорт', Format('Создано отображений: %d. Добавлено линий: %d. Не найдено в БД: %d.',
    [Created, Added, Missing]), mtInformation, [mbOK], 0);
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
  if cbCurrentDate.Checked then
    fDraft.TimeMode := sttmFixedFromToCurrentUtc
  else
    fDraft.TimeMode := TRecorderSqlTrendTimeMode(Max(0, cbTimeMode.ItemIndex));
  lFromUtc := FromUtcValue;
  if cbCurrentDate.Checked then
    lToUtc := LocalTimeToUniversal(Now)
  else
    lToUtc := ToUtcValue;
  if lToUtc <= lFromUtc then begin MessageDlg('Дата «До» должна быть не раньше даты «От»', mtError, [mbOK], 0); Exit; end;
  fDraft.FromUtc := lFromUtc;
  fDraft.ToUtc := lToUtc;
  fDraft.DurationSec := (lToUtc - lFromUtc) * SecsPerDay;
  if not TryStrToInt(edMaxPoints.Text, N) then N := 4000;
  fDraft.MaxPointsPerLine := EnsureRange(N, 32, 100000);
  fDraft.ShowEvents := cbShowEvents.Checked;
  fDraft.ShowRecordingEvents := cbShowRecordingEvents.Checked;
  fDraft.ShowTagAlarmEvents := cbShowTagAlarmEvents.Checked;
  fDraft.ShowTagRangeEvents := cbShowTagRangeEvents.Checked;
  fDraft.ShowOnlyUnresolvedEventPoints := cbShowOnlyUnresolvedEvents.Checked;
  fDraft.OnlyRecorderTags := cbOnlyRecorderTags.Checked;
  fComponent.AssignSqlTrend(fDraft);
  ModalResult := mrOk;
end;

end.
