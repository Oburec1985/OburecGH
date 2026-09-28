unit uRecorderTagCalibrationDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  uRecorderTags, uRecorderUnitManager;

type
  TRecorderTagCalibrationTarget = (rtctLastNode, rtctWholePipeline);

  { TRecorderTagCalibrationDialog }
  TRecorderTagCalibrationDialog = class(TForm)
  published
    lbType: TLabel;
    cbType: TComboBox;
    lbTarget: TLabel;
    cbTarget: TComboBox;
    lbEstimate: TLabel;
    cbEstimate: TComboBox;
    lbReferenceUnit: TLabel;
    cbReferenceUnit: TComboBox;
    gbPoint0: TGroupBox;
    lbReference0: TLabel;
    edReference0: TEdit;
    btnCapture0: TButton;
    lbMeasured0: TLabel;
    gbPoint1: TGroupBox;
    lbReference1: TLabel;
    edReference1: TEdit;
    btnCapture1: TButton;
    lbMeasured1: TLabel;
    lbStatus: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    tmCapture: TTimer;
    { OnChange типа градуировки сбрасывает ранее собранные точки и меняет UI. }
    procedure cbTypeChange(Sender: TObject);
    { OnClick первой кнопки начинает секундный сбор точки 0. }
    procedure btnCapture0Click(Sender: TObject);
    { OnClick второй кнопки начинает секундный сбор точки 1. }
    procedure btnCapture1Click(Sender: TObject);
    { OnTimer ждёт первый отсчёт, затем отсчитывает секунду измерения. }
    procedure tmCaptureTimer(Sender: TObject);
    { OnClick OK строит черновик ГХ из собранных точек. }
    procedure btnOkClick(Sender: TObject);
  private
    fRegistry: TRecorderTagRegistry;
    fTag: TRecorderTag;
    fCapturePoint: Integer;
    fCaptureHasData: Boolean;
    fCaptureTicks: Integer;
    fCaptured: array[0..1] of Boolean;
    fMeasured: array[0..1] of Double;
    fMeasuredUnit: string;
    fDraft: TRecorderCalibration;
    fOriginal: TRecorderCalibration;
    fOwnsCalibrationData: Boolean;
    function CalibrationKind: TRecorderCalibrationKind;
    function CalibrationTarget: TRecorderTagCalibrationTarget;
    function EstimateKind: TRecorderTagEstimateKind;
    function LastEnabledCalibration: TRecorderCalibration;
    function CalibrationOutputUnit: string;
    function ReadReference(AIndex: Integer; out AValue: Double): Boolean;
    function TransformSampleToTargetInput(AValue: Double; out AInput: Double;
      out AUnitName: string): Boolean;
    function CaptureInputUnit: string;
    function CollectEstimate(const ASnapshot: TRecorderSignalSnapshot;
      out AValue: Double; out AUnitName: string; out ACount: Integer): Boolean;
    function UniqueCalibrationName: string;
    procedure BeginCapture(AIndex: Integer);
    procedure EndCapture(ANoData: Boolean = False);
    procedure ResetCapturedPoints;
    procedure UpdateReferenceUnits;
    procedure ReleaseCalibrationData;
    procedure UpdateControls;
    function BuildDraft: Boolean;
  public
    constructor CreateDialog(AOwner: TComponent;
      ARegistry: TRecorderTagRegistry; ATag: TRecorderTag); reintroduce;
    destructor Destroy; override;
    property Draft: TRecorderCalibration read fDraft;
    property Original: TRecorderCalibration read fOriginal;
    property Target: TRecorderTagCalibrationTarget read CalibrationTarget;
  end;

function ShowRecorderTagCalibrationDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out ADraft, AOriginal: TRecorderCalibration;
  out ATarget: TRecorderTagCalibrationTarget): Boolean;

implementation

{$R *.lfm}

function TryReadDialogFloat(const AText: string; out AValue: Double): Boolean;
var
  lText: string;
begin
  lText := Trim(AText);
  Result := TryStrToFloat(lText, AValue);
  if not Result then
  begin
    lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator,
      [rfReplaceAll]);
    lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator,
      [rfReplaceAll]);
    Result := TryStrToFloat(lText, AValue);
  end;
end;

function ShowRecorderTagCalibrationDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out ADraft, AOriginal: TRecorderCalibration;
  out ATarget: TRecorderTagCalibrationTarget): Boolean;
var
  lDialog: TRecorderTagCalibrationDialog;
begin
  ADraft := nil;
  AOriginal := nil;
  ATarget := rtctLastNode;
  lDialog := TRecorderTagCalibrationDialog.CreateDialog(AOwner, ARegistry, ATag);
  try
    Result := lDialog.ShowModal = mrOk;
    if Result then
    begin
      ADraft := lDialog.fDraft;
      lDialog.fDraft := nil;
      AOriginal := lDialog.Original;
      ATarget := lDialog.Target;
    end;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderTagCalibrationDialog.CreateDialog(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag);
begin
  inherited Create(AOwner);
  if (ARegistry = nil) or (ATag = nil) then
    raise ERecorderTagError.Create('Для градуировки должен быть выбран тег.');
  fRegistry := ARegistry;
  fTag := ATag;
  cbType.Items.Add('Масштабный множитель');
  cbType.Items.Add('Прямая по двум точкам');
  cbType.ItemIndex := 0;
  cbTarget.Items.Add('Скорректировать последнюю ГХ');
  cbTarget.Items.Add('Сквозная: заменить весь pipeline одной ГХ');
  if LastEnabledCalibration <> nil then
    cbTarget.ItemIndex := Ord(rtctLastNode)
  else
    cbTarget.ItemIndex := Ord(rtctWholePipeline);
  cbEstimate.Items.Add('Математическое ожидание');
  cbEstimate.Items.Add('Амплитуда');
  cbEstimate.Items.Add('СКО');
  cbEstimate.ItemIndex := 0;
  UpdateReferenceUnits;
  edReference0.Text := '1';
  edReference1.Text := '1';
  ResetCapturedPoints;
end;

destructor TRecorderTagCalibrationDialog.Destroy;
begin
  fRegistry.CancelCalibrationCapture(fTag);
  ReleaseCalibrationData;
  fDraft.Free;
  inherited Destroy;
end;

function TRecorderTagCalibrationDialog.CalibrationKind: TRecorderCalibrationKind;
begin
  if cbType.ItemIndex = 1 then
    Result := rckLinear
  else
    Result := rckScale;
end;

function TRecorderTagCalibrationDialog.CalibrationTarget:
  TRecorderTagCalibrationTarget;
begin
  if cbTarget.ItemIndex = Ord(rtctWholePipeline) then
    Result := rtctWholePipeline
  else
    Result := rtctLastNode;
end;

function TRecorderTagCalibrationDialog.EstimateKind: TRecorderTagEstimateKind;
begin
  case cbEstimate.ItemIndex of
    1: Result := tekPeak;
    2: Result := tekRmsDeviation;
  else
    Result := tekMean;
  end;
end;

function TRecorderTagCalibrationDialog.LastEnabledCalibration:
  TRecorderCalibration;
var
  I: Integer;
begin
  Result := nil;
  if fTag.CalibrationNames = nil then
    Exit;
  for I := fTag.CalibrationNames.Count - 1 downto 0 do
    if RecorderCalibrationStepEnabled(fTag.CalibrationNames, I) then
      Exit(fRegistry.FindCalibrationByName(fTag.CalibrationNames[I]));
end;

function TRecorderTagCalibrationDialog.CalibrationOutputUnit: string;
var
  lCalibration: TRecorderCalibration;
begin
  Result := '';
  if CalibrationTarget = rtctLastNode then
  begin
    lCalibration := LastEnabledCalibration;
    if lCalibration <> nil then
      Result := Trim(lCalibration.UnitOut);
    Exit;
  end;

  Result := Trim(fTag.UnitName);
  if Result = '' then
    fRegistry.TryGetTagAutoUnit(fTag, Result);
  if Result <> '' then
    Exit;
  lCalibration := LastEnabledCalibration;
  if lCalibration = nil then
    lCalibration := fRegistry.FindTagHardwareCalibration(fTag);
  if lCalibration <> nil then
    Result := Trim(lCalibration.UnitOut);
  if Result = '' then
    Result := CaptureInputUnit;
end;

function TRecorderTagCalibrationDialog.ReadReference(AIndex: Integer;
  out AValue: Double): Boolean;
var
  lEdit: TEdit;
  lSourceUnit: string;
  lTargetUnit: string;
begin
  if AIndex = 0 then
    lEdit := edReference0
  else
    lEdit := edReference1;
  Result := TryReadDialogFloat(lEdit.Text, AValue);
  if not Result then
    MessageDlg('Градуировка', 'Введите числовое эталонное значение.',
      mtError, [mbOK], 0);
  if not Result then
    Exit;
  lSourceUnit := Trim(cbReferenceUnit.Text);
  lTargetUnit := CalibrationOutputUnit;
  if SameText(lSourceUnit, lTargetUnit) then
    Exit(True);
  Result := RecorderUnitManager.TryConvert(AValue, lSourceUnit, lTargetUnit,
    AValue);
  if not Result then
    MessageDlg('Градуировка', Format(
      'Единицу "%s" нельзя привести к единице итоговой ГХ "%s".',
      [lSourceUnit, lTargetUnit]), mtError, [mbOK], 0);
end;

function TRecorderTagCalibrationDialog.CaptureInputUnit: string;
var
  lHardware: TRecorderCalibration;
begin
  lHardware := fRegistry.FindTagHardwareCalibration(fTag);
  if (lHardware <> nil) and (Trim(lHardware.UnitOut) <> '') then
    Result := Trim(lHardware.UnitOut)
  else
    Result := Trim(fTag.SourceUnitName);
  if Result = '' then
    Result := Trim(fTag.UnitName);
end;

procedure TRecorderTagCalibrationDialog.UpdateReferenceUnits;
var
  I: Integer;
  lAllUnits: TStringList;
  lCandidate: TRecorderUnitInfo;
  lOutput: TRecorderUnitInfo;
  lOutputUnit: string;
begin
  lOutputUnit := CalibrationOutputUnit;
  lbReferenceUnit.Caption := 'Единицы эталона (пересчёт в ' +
    lOutputUnit + '):';
  cbReferenceUnit.Items.BeginUpdate;
  try
    cbReferenceUnit.Items.Clear;
    if RecorderUnitManager.TryGetUnitInfo(lOutputUnit, lOutput) then
    begin
      lAllUnits := TStringList.Create;
      try
        RecorderUnitManager.FillUnitNames(lAllUnits);
        for I := 0 to lAllUnits.Count - 1 do
          if RecorderUnitManager.TryGetUnitInfo(lAllUnits[I], lCandidate) and
            SameText(lCandidate.QuantityId, lOutput.QuantityId) then
            cbReferenceUnit.Items.Add(lCandidate.Name);
      finally
        lAllUnits.Free;
      end;
    end;
    if (lOutputUnit <> '') and (cbReferenceUnit.Items.IndexOf(lOutputUnit) < 0) then
      cbReferenceUnit.Items.Add(lOutputUnit);
    cbReferenceUnit.ItemIndex := cbReferenceUnit.Items.IndexOf(lOutputUnit);
  finally
    cbReferenceUnit.Items.EndUpdate;
  end;
end;

procedure TRecorderTagCalibrationDialog.ReleaseCalibrationData;
begin
  if not fOwnsCalibrationData then
    Exit;
  fOwnsCalibrationData := False;
  fRegistry.ReleaseCalibrationData(fTag);
end;

function TRecorderTagCalibrationDialog.TransformSampleToTargetInput(AValue: Double;
  out AInput: Double; out AUnitName: string): Boolean;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lFactor: Double;
  lLastIndex: Integer;
begin
  Result := True;
  AInput := AValue;
  AUnitName := CaptureInputUnit;
  if CalibrationTarget = rtctWholePipeline then
    Exit;
  if (not fTag.ChannelCalibrationEnabled) or
    (fTag.CalibrationNames = nil) then
    Exit(False);
  lLastIndex := -1;
  for I := fTag.CalibrationNames.Count - 1 downto 0 do
    if RecorderCalibrationStepEnabled(fTag.CalibrationNames, I) then
    begin
      lLastIndex := I;
      Break;
    end;
  if lLastIndex < 0 then
    Exit(False);

  { До последней ступени воспроизводим существующий pipeline. Саму последнюю
    ступень не применяем: именно её вход нужен для нового коэффициента. }
  for I := 0 to lLastIndex - 1 do
  begin
    if not RecorderCalibrationStepEnabled(fTag.CalibrationNames, I) then
      Continue;
    lCalibration := fRegistry.FindCalibrationByName(fTag.CalibrationNames[I]);
    if lCalibration = nil then
      Exit(False);
    if (AUnitName <> '') and (Trim(lCalibration.UnitIn) <> '') and
      not SameText(AUnitName, Trim(lCalibration.UnitIn)) then
    begin
      if not RecorderUnitManager.TryGetConversionFactor(AUnitName,
        lCalibration.UnitIn, lFactor) then
        Exit(False);
      AInput := AInput * lFactor;
    end;
    AInput := lCalibration.Transform(AInput);
    AUnitName := Trim(lCalibration.UnitOut);
  end;
end;

function TRecorderTagCalibrationDialog.CollectEstimate(
  const ASnapshot: TRecorderSignalSnapshot; out AValue: Double;
  out AUnitName: string; out ACount: Integer): Boolean;
var
  I: Integer;
  lInput: Double;
  lSnapshot: TRecorderSignalSnapshot;
  lUnit: string;
  lEstimate: TRecorderTagEstimate;
begin
  Result := False;
  AValue := 0.0;
  AUnitName := '';
  ACount := 0;
  lSnapshot := ASnapshot;
  if lSnapshot.Count <= 0 then
    Exit;
  for I := 0 to lSnapshot.Count - 1 do
  begin
    if not TransformSampleToTargetInput(lSnapshot.Values[I], lInput, lUnit) then
      Exit;
    lSnapshot.Values[I] := lInput;
    if AUnitName = '' then
      AUnitName := lUnit;
  end;
  lEstimate := CalculateRecorderTagEstimate(lSnapshot, EstimateKind);
  if not lEstimate.Valid then
    Exit;
  AValue := lEstimate.Value;
  ACount := lEstimate.Count;
  Result := True;
end;

function TRecorderTagCalibrationDialog.UniqueCalibrationName: string;
var
  lBase: string;
  lIndex: Integer;
begin
  lBase := 'Градуировка ' + fTag.Name;
  Result := lBase;
  lIndex := 2;
  while fRegistry.FindCalibrationByName(Result) <> nil do
  begin
    Result := lBase + ' ' + IntToStr(lIndex);
    Inc(lIndex);
  end;
end;

procedure TRecorderTagCalibrationDialog.BeginCapture(AIndex: Integer);
var
  lError: string;
  lReference: Double;
  lStartedByCalibration: Boolean;
begin
  if not ReadReference(AIndex, lReference) then
    Exit;
  if (CalibrationTarget = rtctLastNode) and
    ((not fTag.ChannelCalibrationEnabled) or
    (LastEnabledCalibration = nil)) then
  begin
    MessageDlg('Градуировка',
      'Для коррекции последней ГХ включите канальную цепочку и назначьте ГХ.',
      mtInformation, [mbOK], 0);
    Exit;
  end;
  if not fRegistry.EnsureCalibrationData(fTag, lStartedByCalibration, lError) then
  begin
    MessageDlg('Градуировка', lError, mtError, [mbOK], 0);
    Exit;
  end;
  fOwnsCalibrationData := fOwnsCalibrationData or lStartedByCalibration;
  fCapturePoint := AIndex;
  fRegistry.BeginCalibrationCapture(fTag, 1.0);
  fCaptureHasData := False;
  fCaptureTicks := 0;
  lbStatus.Caption := 'Ожидание новых данных...';
  cbType.Enabled := False;
  cbTarget.Enabled := False;
  cbEstimate.Enabled := False;
  btnCapture0.Enabled := False;
  btnCapture1.Enabled := False;
  btnOk.Enabled := False;
  tmCapture.Enabled := True;
end;

procedure TRecorderTagCalibrationDialog.EndCapture(ANoData: Boolean);
var
  lCount: Integer;
  lSnapshot: TRecorderSignalSnapshot;
  lUnit: string;
  lValue: Double;
begin
  tmCapture.Enabled := False;
  if ANoData then
  begin
    fRegistry.CancelCalibrationCapture(fTag);
    lbStatus.Caption := 'Источник не передал новые отсчёты.';
    MessageDlg('Градуировка',
      'Просмотр запущен, но за 5 секунд выбранный тег не получил новых данных.',
      mtError, [mbOK], 0);
    ReleaseCalibrationData;
  end
  else if not fRegistry.FinishCalibrationCapture(fTag, lSnapshot) then
  begin
    lbStatus.Caption := 'Источник не передал новые отсчёты.';
    MessageDlg('Градуировка',
      'Во время измерения выбранный тег не получил новых данных.',
      mtError, [mbOK], 0);
    ReleaseCalibrationData;
  end
  else if CollectEstimate(lSnapshot, lValue, lUnit, lCount) then
  begin
    fCaptured[fCapturePoint] := True;
    fMeasured[fCapturePoint] := lValue;
    fMeasuredUnit := lUnit;
    if fCapturePoint = 0 then
      lbMeasured0.Caption := Format('Измерено: %.9g %s (%d отсч.)',
        [lValue, lUnit, lCount])
    else
      lbMeasured1.Caption := Format('Измерено: %.9g %s (%d отсч.)',
        [lValue, lUnit, lCount]);
    lbStatus.Caption := 'Точка собрана.';
  end
  else
  begin
    lbStatus.Caption := 'Не удалось применить текущий pipeline.';
    MessageDlg('Градуировка',
      'Нельзя привести данные ко входу последней ГХ: проверьте состав цепочки и единицы её ступеней.',
      mtError, [mbOK], 0);
    ReleaseCalibrationData;
  end;
  cbType.Enabled := True;
  cbTarget.Enabled := True;
  cbEstimate.Enabled := True;
  UpdateControls;
end;

procedure TRecorderTagCalibrationDialog.ResetCapturedPoints;
begin
  fCaptured[0] := False;
  fCaptured[1] := False;
  fMeasured[0] := 0.0;
  fMeasured[1] := 0.0;
  fMeasuredUnit := '';
  lbMeasured0.Caption := 'Точка ещё не собрана';
  lbMeasured1.Caption := 'Точка ещё не собрана';
  lbStatus.Caption := 'Задайте эталон и соберите данные.';
  UpdateControls;
end;

procedure TRecorderTagCalibrationDialog.UpdateControls;
var
  lLinear: Boolean;
begin
  lLinear := CalibrationKind = rckLinear;
  gbPoint1.Visible := lLinear;
  if lLinear then
  begin
    gbPoint0.Caption := 'Точка 0';
    gbPoint1.Caption := 'Точка 1';
  end
  else
    gbPoint0.Caption := 'Масштабный множитель';
  btnCapture0.Enabled := not tmCapture.Enabled;
  btnCapture1.Enabled := lLinear and not tmCapture.Enabled;
  btnOk.Enabled := fCaptured[0] and ((not lLinear) or fCaptured[1]) and
    not tmCapture.Enabled;
end;

function TRecorderTagCalibrationDialog.BuildDraft: Boolean;
var
  lOffset: Double;
  lReference0: Double;
  lReference1: Double;
  lScale: Double;
begin
  Result := False;
  if not ReadReference(0, lReference0) then
    Exit;
  if CalibrationKind = rckLinear then
  begin
    if not ReadReference(1, lReference1) then
      Exit;
    if SameValue(fMeasured[0], fMeasured[1]) then
    begin
      MessageDlg('Градуировка',
        'Измеренные значения двух точек совпадают — прямую построить нельзя.',
        mtError, [mbOK], 0);
      Exit;
    end;
    lScale := (lReference1 - lReference0) /
      (fMeasured[1] - fMeasured[0]);
    lOffset := lReference0 - lScale * fMeasured[0];
  end
  else
  begin
    if SameValue(fMeasured[0], 0.0) then
    begin
      MessageDlg('Градуировка',
        'Измеренное значение равно нулю — множитель определить нельзя.',
        mtError, [mbOK], 0);
      Exit;
    end;
    lScale := lReference0 / fMeasured[0];
    lOffset := 0.0;
  end;

  FreeAndNil(fDraft);
  if CalibrationTarget = rtctLastNode then
  begin
    fOriginal := LastEnabledCalibration;
    if fOriginal = nil then
      Exit;
    fDraft := fOriginal.Clone;
  end
  else
  begin
    fOriginal := nil;
    fDraft := TRecorderCalibration.Create(CalibrationKind);
    fDraft.Name := UniqueCalibrationName;
    fDraft.UnitIn := fMeasuredUnit;
    fDraft.UnitOut := CalibrationOutputUnit;
    fDraft.Description := 'Сквозная градуировка тега ' + fTag.Name;
  end;
  fDraft.Kind := CalibrationKind;
  fDraft.Scale := lScale;
  fDraft.Offset := lOffset;
  fDraft.ClearPoints;
  Result := True;
end;

procedure TRecorderTagCalibrationDialog.cbTypeChange(Sender: TObject);
begin
  if Sender = cbType then
    if cbType.ItemIndex = 1 then
    begin
      edReference0.Text := '0';
      edReference1.Text := '1';
    end
    else
      edReference0.Text := '1';
  UpdateReferenceUnits;
  ResetCapturedPoints;
end;

procedure TRecorderTagCalibrationDialog.btnCapture0Click(Sender: TObject);
begin
  BeginCapture(0);
end;

procedure TRecorderTagCalibrationDialog.btnCapture1Click(Sender: TObject);
begin
  BeginCapture(1);
end;

procedure TRecorderTagCalibrationDialog.tmCaptureTimer(Sender: TObject);
begin
  if not fCaptureHasData then
  begin
    if fRegistry.CalibrationCaptureSampleCount(fTag) > 0 then
    begin
      fCaptureHasData := True;
      fCaptureTicks := 0;
      lbStatus.Caption := 'Сбор данных: 1,0 с...';
    end
    else
    begin
      Inc(fCaptureTicks);
      if fCaptureTicks >= 50 then
        EndCapture(True);
    end;
    Exit;
  end;
  Inc(fCaptureTicks);
  if fCaptureTicks >= 10 then
    EndCapture;
end;

procedure TRecorderTagCalibrationDialog.btnOkClick(Sender: TObject);
begin
  if BuildDraft then
    ModalResult := mrOk;
end;

end.
