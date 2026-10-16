unit uOscSettings;
{$mode objfpc}{$H+}{$codepage UTF8}
{ Plugin-owned settings editor. All edits use a deep draft; OK commits and Cancel
  discards. Catalog values come from SDK services. Host domain classes and
  capability-specific dispatch are forbidden. Static controls live in LFM. }
interface
uses Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  ColorBox, Graphics, uOscModel, uOscDataAdapter;
type
  TOscSettings = class(TForm)
  published
    laSearch, laTag, laBind, laedOffset, laedFormat, laAxis, laedY,
      laedShift, laedX, laedLevel, laedPreRoll: TLabel;
    edSearch, edOffset, edFormat, edX, edY, edShift, edLevel, edPreRoll: TEdit;
    cbTag, cbBinding, cbAxis, cbTrigger, cbEdge: TComboBox;
    cbColor: TColorBox;
    ckVisible, ckTrigger, ckClosed: TCheckBox;
    lbLines: TListBox;
    btAdd, btApply, btDelete, btAxis, btOK, btCancel: TButton;
    pnBottom: TPanel;
    procedure SearchChange(Sender: TObject);
    procedure TagChange(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure LineChange(Sender: TObject);
    procedure AxisChange(Sender: TObject);
    procedure BindingChange(Sender: TObject);
    procedure AddClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure NewAxisClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure NativeShown(Sender: TObject);
  private
    fModel, fDraft: TOscModel;
    fCatalog: TOscTagCatalog;
    fTagIndices: array of Integer;
    fSelectedLine, fSelectedAxis: Integer;
    fUpdating: Boolean;
    fNativeOwner: PtrUInt;
    procedure FillTags;
    procedure RefreshLines;
    procedure LoadLine;
    procedure StoreLine;
    procedure LoadAxis(AIndex: Integer);
    procedure StoreAxis;
    procedure RefreshAxes;
    function SelectedTag: Integer;
    function UsedTag(AId: QWord; AExceptLine: Integer): Boolean;
  public
    destructor Destroy; override;
    procedure Initialize(AModel: TOscModel; const ACatalog: TOscTagCatalog);
  end;
function ShowOscSettings(AOwner: TComponent; AModel: TOscModel;
  const ACatalog: TOscTagCatalog; AOwnerWindow: PtrUInt = 0;
  ANativeBackend: LongWord = 0; ADpi: LongWord = 0): Boolean;
implementation
uses LazUTF8, uRecorderVisualComponentApiV2{$IFDEF WINDOWS}, Windows{$ENDIF};
{$R *.lfm}

function ShowOscSettings(AOwner: TComponent; AModel: TOscModel;
  const ACatalog: TOscTagCatalog; AOwnerWindow: PtrUInt;
  ANativeBackend: LongWord; ADpi: LongWord): Boolean;
var lForm: TOscSettings;
  {$IFDEF WINDOWS}
  lWasEnabled: Boolean; lFocus: HWND;
  {$ENDIF}
begin
  Result := False;
  if AModel = nil then Exit;
  if AOwnerWindow <> 0 then
  begin
    {$IFDEF WINDOWS}
    if (ANativeBackend <> REC_VISUAL_NATIVE_WIN32) or
      not Windows.IsWindow(HWND(AOwnerWindow)) then
      raise Exception.Create('Unsupported or invalid native modal owner');
    {$ELSE}
    raise Exception.Create('Native modal owner backend is not supported');
    {$ENDIF}
  end;
  lForm := TOscSettings.Create(AOwner);
  try
    lForm.Initialize(AModel, ACatalog);
    {$IFDEF WINDOWS}
    if AOwnerWindow <> 0 then
    begin
      { Explicit popup mode prevents ShowModal recreating the HWND and losing
        the foreign-process-module native owner. No host TForm crosses ABI. }
      lForm.PopupMode := pmExplicit;
      lForm.Position := poDesigned;
      lForm.fNativeOwner := AOwnerWindow;
      if (ADpi >= 48) and (ADpi <= 768) then
        lForm.AutoAdjustLayout(lapAutoAdjustForDPI, lForm.PixelsPerInch,
          ADpi, lForm.Width, lForm.Width);
      lForm.HandleNeeded;
      Windows.SetLastError(0);
      if (Windows.SetWindowLongPtr(lForm.Handle, GWLP_HWNDPARENT,
        LONG_PTR(AOwnerWindow)) = 0) and (Windows.GetLastError <> 0) then
        raise Exception.Create('Cannot assign native modal owner');
      lWasEnabled := Windows.IsWindowEnabled(HWND(AOwnerWindow));
      lFocus := Windows.GetFocus;
      if lWasEnabled then Windows.EnableWindow(HWND(AOwnerWindow), False);
      try
        Result := lForm.ShowModal = mrOk;
      finally
        if Windows.IsWindow(HWND(AOwnerWindow)) then
        begin
          if lWasEnabled then Windows.EnableWindow(HWND(AOwnerWindow), True);
          Windows.SetActiveWindow(HWND(AOwnerWindow));
          if Windows.IsWindow(lFocus) and
            ((lFocus = HWND(AOwnerWindow)) or
             Windows.IsChild(HWND(AOwnerWindow), lFocus)) then
            Windows.SetFocus(lFocus);
        end;
      end;
    end else
    {$ENDIF}
      Result := lForm.ShowModal = mrOk;
  finally lForm.Free; end;
end;

procedure TOscSettings.NativeShown(Sender: TObject);
{$IFDEF WINDOWS}
var lOwnerRect, lDialogRect: Windows.TRect;
{$ENDIF}
begin
  {$IFDEF WINDOWS}
  { Center after LCL applies final non-client size and modal positioning. }
  if (fNativeOwner <> 0) and
    Windows.GetWindowRect(HWND(fNativeOwner), lOwnerRect) and
    Windows.GetWindowRect(Handle, lDialogRect) then
    Windows.SetWindowPos(Handle, 0,
      lOwnerRect.Left + ((lOwnerRect.Right-lOwnerRect.Left)-
        (lDialogRect.Right-lDialogRect.Left)) div 2,
      lOwnerRect.Top + ((lOwnerRect.Bottom-lOwnerRect.Top)-
        (lDialogRect.Bottom-lDialogRect.Top)) div 2,
      0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
  {$ENDIF}
end;

destructor TOscSettings.Destroy;
begin fDraft.Free; inherited Destroy; end;

procedure TOscSettings.Initialize(AModel: TOscModel; const ACatalog: TOscTagCatalog);
var lIndex: Integer;
begin
  fModel := AModel; fDraft := AModel.Clone; fCatalog := Copy(ACatalog);
  fSelectedLine := -1; fSelectedAxis := 0;
  fUpdating := True;
  try
    cbBinding.ItemIndex := Ord(fDraft.BindingMode);
    edOffset.Text := IntToStr(fDraft.TagOffset); edFormat.Text := fDraft.DisplayFormat;
    edX.Text := FloatToStr(fDraft.XScale); ckClosed.Checked := fDraft.ClosedInput;
    ckTrigger.Checked := fDraft.TriggerEnabled; cbEdge.ItemIndex := Ord(fDraft.TriggerEdge);
    edLevel.Text := FloatToStr(fDraft.TriggerLevel);
    edPreRoll.Text := FloatToStr(fDraft.TriggerPreRollPercent);
    cbTrigger.Items.Clear; cbTrigger.Items.Add('');
    for lIndex := 0 to High(fCatalog) do cbTrigger.Items.Add(fCatalog[lIndex].Name);
    cbTrigger.ItemIndex := cbTrigger.Items.IndexOf(fDraft.TriggerTagName);
    FillTags; RefreshAxes; RefreshLines; BindingChange(nil);
  finally fUpdating := False; end;
end;

procedure TOscSettings.FillTags;
var lIndex, lCount: Integer; lFilter, lText, lSelected: string; lWasUpdating: Boolean;
begin
  lWasUpdating := fUpdating; fUpdating := True;
  try
    lSelected := cbTag.Text; lFilter := UTF8LowerCase(Trim(edSearch.Text));
    cbTag.Items.Clear; SetLength(fTagIndices, Length(fCatalog)); lCount := 0;
    for lIndex := 0 to High(fCatalog) do
    begin
      lText := UTF8LowerCase(fCatalog[lIndex].Name + ' ' +
        fCatalog[lIndex].Address + ' ' + fCatalog[lIndex].Description);
      if (lFilter <> '') and (Pos(lFilter, lText) = 0) then Continue;
      cbTag.Items.Add(fCatalog[lIndex].Name);
      fTagIndices[lCount] := lIndex; Inc(lCount);
    end;
    SetLength(fTagIndices, lCount); cbTag.ItemIndex := cbTag.Items.IndexOf(lSelected);
    TagChange(nil);
  finally fUpdating := lWasUpdating; end;
end;

function TOscSettings.SelectedTag: Integer;
begin
  Result := -1;
  if (cbTag.ItemIndex >= 0) and (cbTag.ItemIndex < Length(fTagIndices)) then
    Result := fTagIndices[cbTag.ItemIndex];
end;

function TOscSettings.UsedTag(AId: QWord; AExceptLine: Integer): Boolean;
var lIndex: Integer;
begin
  Result := (AExceptLine <> 0) and (QWord(fDraft.TagId) = AId);
  if Result then Exit;
  for lIndex := 0 to fDraft.LineCount - 1 do
    if (lIndex + 1 <> AExceptLine) and (QWord(fDraft.Lines[lIndex].TagId) = AId) then Exit(True);
end;

procedure TOscSettings.RefreshAxes;
var lIndex: Integer;
begin
  cbAxis.Items.Clear;
  for lIndex := 0 to fDraft.AxisCount - 1 do
    cbAxis.Items.Add('Y' + IntToStr(lIndex + 1) + ' — ' + fDraft.Axes[lIndex].Name);
end;

procedure TOscSettings.RefreshLines;
var lIndex: Integer; lWasUpdating: Boolean;
begin
  lWasUpdating := fUpdating; fUpdating := True;
  try
    lbLines.Items.Clear;
    if fDraft.TagName <> '' then lbLines.Items.Add('[Y' +
      IntToStr(fDraft.PrimaryAxisIndex + 1) + '] ' + fDraft.TagName);
    for lIndex := 0 to fDraft.LineCount - 1 do
      lbLines.Items.Add('[Y' + IntToStr(fDraft.Lines[lIndex].AxisIndex + 1) +
        '] ' + fDraft.Lines[lIndex].TagName);
    if lbLines.Items.Count = 0 then fSelectedLine := -1
    else if (fSelectedLine < 0) or (fSelectedLine >= lbLines.Items.Count) then fSelectedLine := 0;
    lbLines.ItemIndex := fSelectedLine; LoadLine; TagChange(nil);
  finally fUpdating := lWasUpdating; end;
end;

procedure TOscSettings.LoadAxis(AIndex: Integer);
begin
  fSelectedAxis := EnsureRange(AIndex, 0, fDraft.AxisCount - 1);
  cbAxis.ItemIndex := fSelectedAxis;
  edY.Text := FloatToStr(fDraft.Axes[fSelectedAxis].YScale);
  edShift.Text := FloatToStr(fDraft.Axes[fSelectedAxis].YOffset);
end;

procedure TOscSettings.StoreAxis;
var lScale, lShift: Double;
begin
  if not TryStrToFloat(edY.Text, lScale) or (lScale <= 0) or IsNan(lScale) or
    IsInfinite(lScale) then raise EConvertError.Create('Масштаб Y должен быть больше нуля.');
  if not TryStrToFloat(edShift.Text, lShift) or IsNan(lShift) or IsInfinite(lShift) then
    raise EConvertError.Create('Некорректное смещение Y.');
  fDraft.Axes[fSelectedAxis].YScale := lScale;
  fDraft.Axes[fSelectedAxis].YOffset := lShift;
end;

procedure TOscSettings.LoadLine;
var lName: string; lEnabled: Boolean;
begin
  lEnabled := fSelectedLine >= 0;
  btDelete.Enabled := lEnabled; cbAxis.Enabled := lEnabled;
  btAxis.Enabled := lEnabled and (fDraft.AxisCount < 16);
  cbColor.Enabled := fSelectedLine > 0; ckVisible.Enabled := fSelectedLine > 0;
  if not lEnabled then begin LoadAxis(0); Exit; end;
  if fSelectedLine = 0 then
  begin
    lName := fDraft.TagName; cbColor.Selected := $00FF0000; ckVisible.Checked := True;
    LoadAxis(fDraft.PrimaryAxisIndex);
  end else
  begin
    with fDraft.Lines[fSelectedLine - 1] do
    begin lName := TagName; cbColor.Selected := Color; ckVisible.Checked := Visible; LoadAxis(AxisIndex); end;
  end;
  cbTag.ItemIndex := cbTag.Items.IndexOf(lName);
end;

procedure TOscSettings.StoreLine;
begin
  StoreAxis;
  if fSelectedLine > 0 then
    with fDraft.Lines[fSelectedLine - 1] do
    begin Color := cbColor.Selected; Visible := ckVisible.Checked; end;
end;

procedure TOscSettings.SearchChange(Sender: TObject);
begin if not fUpdating then FillTags; end;
procedure TOscSettings.BindingChange(Sender: TObject);
begin edOffset.Enabled := cbBinding.ItemIndex = 0; end;
procedure TOscSettings.TagChange(Sender: TObject);
begin
  { Selecting an available tag is only selecting a candidate. It must not
    overwrite a line before the user chooses Apply or Add. }
  btApply.Enabled := (fSelectedLine >= 0) and (SelectedTag >= 0);
  btAdd.Enabled := SelectedTag >= 0;
end;
procedure TOscSettings.ApplyClick(Sender: TObject);
var lIndex: Integer;
begin
  if fUpdating or (fSelectedLine < 0) then Exit;
  lIndex := SelectedTag;
  if (lIndex < 0) or UsedTag(fCatalog[lIndex].Id, fSelectedLine) then Exit;
  try StoreLine; except on E: Exception do begin ShowMessage(E.Message); Exit; end; end;
  if fSelectedLine = 0 then begin fDraft.TagId := fCatalog[lIndex].Id; fDraft.TagName := fCatalog[lIndex].Name; end
  else with fDraft.Lines[fSelectedLine - 1] do begin TagId := fCatalog[lIndex].Id; TagName := fCatalog[lIndex].Name; end;
  RefreshLines;
end;
procedure TOscSettings.LineChange(Sender: TObject);
begin
  if fUpdating then Exit;
  try StoreLine; except on E: Exception do begin ShowMessage(E.Message); lbLines.ItemIndex := fSelectedLine; Exit; end; end;
  fSelectedLine := lbLines.ItemIndex; fUpdating := True;
  try LoadLine; finally fUpdating := False; end;
end;
procedure TOscSettings.AxisChange(Sender: TObject);
var lIndex: Integer;
begin
  if fUpdating or (fSelectedLine < 0) then Exit;
  lIndex := cbAxis.ItemIndex;
  try StoreLine; except on E: Exception do begin ShowMessage(E.Message); cbAxis.ItemIndex := fSelectedAxis; Exit; end; end;
  if fSelectedLine = 0 then fDraft.PrimaryAxisIndex := lIndex
  else fDraft.Lines[fSelectedLine - 1].AxisIndex := lIndex;
  RefreshLines;
end;
procedure TOscSettings.AddClick(Sender: TObject);
var lIndex: Integer;
begin
  lIndex := SelectedTag;
  if (lIndex < 0) or UsedTag(fCatalog[lIndex].Id, -1) then Exit;
  try StoreLine; except on E: Exception do begin ShowMessage(E.Message); Exit; end; end;
  if fDraft.TagName = '' then
  begin fDraft.TagId := fCatalog[lIndex].Id; fDraft.TagName := fCatalog[lIndex].Name; fSelectedLine := 0; end
  else begin with fDraft.AddLine do begin TagId := fCatalog[lIndex].Id; TagName := fCatalog[lIndex].Name; end; fSelectedLine := fDraft.LineCount; end;
  RefreshLines;
end;
procedure TOscSettings.DeleteClick(Sender: TObject);
begin
  if fSelectedLine < 0 then Exit;
  if fSelectedLine = 0 then
  begin
    if fDraft.LineCount > 0 then
    begin fDraft.TagId := fDraft.Lines[0].TagId; fDraft.TagName := fDraft.Lines[0].TagName;
      fDraft.PrimaryAxisIndex := fDraft.Lines[0].AxisIndex; fDraft.DeleteLine(0); end
    else begin fDraft.TagId := 0; fDraft.TagName := ''; end;
  end else fDraft.DeleteLine(fSelectedLine - 1);
  RefreshLines;
end;
procedure TOscSettings.NewAxisClick(Sender: TObject);
var lIndex: Integer;
begin
  if (fSelectedLine < 0) or (fDraft.AxisCount >= 16) then Exit;
  try StoreLine; except on E: Exception do begin ShowMessage(E.Message); Exit; end; end;
  lIndex := fDraft.AxisCount; fDraft.AddAxis;
  if fSelectedLine = 0 then fDraft.PrimaryAxisIndex := lIndex
  else fDraft.Lines[fSelectedLine - 1].AxisIndex := lIndex;
  RefreshAxes; RefreshLines;
end;
procedure TOscSettings.OkClick(Sender: TObject);
var lValue: Double; lOffset: Integer; lCheck: TOscModel; lError: string;
begin
  try
    StoreLine;
    if fDraft.TagName = '' then raise EConvertError.Create('Добавьте хотя бы один канал.');
    if not TryStrToInt(edOffset.Text, lOffset) then raise EConvertError.Create('Некорректное смещение тега.');
    fDraft.TagOffset := lOffset; fDraft.BindingMode := TOscBindingMode(cbBinding.ItemIndex);
    fDraft.DisplayFormat := Trim(edFormat.Text);
    if fDraft.DisplayFormat = '' then raise EConvertError.Create('Укажите формат чисел.');
    if not TryStrToFloat(edX.Text, lValue) or (lValue < 0) then raise EConvertError.Create('Окно X должно быть не меньше нуля.');
    fDraft.XScale := lValue;
    if not TryStrToFloat(edLevel.Text, lValue) then raise EConvertError.Create('Некорректный уровень триггера.');
    fDraft.TriggerLevel := lValue;
    if not TryStrToFloat(edPreRoll.Text, lValue) or (lValue < 0) or (lValue > 50) then raise EConvertError.Create('До триггера: от 0 до 50%.');
    fDraft.TriggerPreRollPercent := lValue;
    fDraft.TriggerEnabled := ckTrigger.Checked; fDraft.TriggerTagName := cbTrigger.Text;
    fDraft.TriggerEdge := TOscSignalEdge(cbEdge.ItemIndex); fDraft.ClosedInput := ckClosed.Checked;
    if fDraft.TriggerEnabled and (cbTrigger.ItemIndex <= 0) then raise EConvertError.Create('Выберите тег триггера.');
    lCheck := TOscModel.Create;
    try if not lCheck.LoadUtf8(fDraft.SaveUtf8, lError) then raise EConvertError.Create(lError); finally lCheck.Free; end;
    fModel.Assign(fDraft); ModalResult := mrOk;
  except on E: Exception do ShowMessage(E.Message); end;
end;
end.

