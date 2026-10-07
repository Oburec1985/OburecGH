unit uRecorderImpactHammerModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Persistent configuration for impact-hammer FRF measurement. This unit owns
  configuration only; acquisition and DSP belong to an application service. }

interface

uses
  Classes, SysUtils, Math, Graphics, uRecorderFormModel, uRecorderTags,
  uRecorderImpactHammerContracts;

const
  RECORDER_IMPACT_HAMMER_CONFIG_VERSION = 6;

type
  TImpactTriggerPolarity = (itpPositive, itpNegative, itpAbsolute);
  TImpactWindowKind = (iwRectangular, iwHann, iwHamming, iwForce, iwExponential);
  TImpactFrfEstimator = (ifeH0, ifeH1, ifeH2);
  TImpactResponseAxis = (iraX, iraY, iraZ);
  TImpactResponseSpace = (irsModel, irsHelperLocal, irsWorld);

  TImpactResponseBinding = class
  public
    TagId: TRecorderTagId;
    TagName: string;
    PointId: string;
    PointGroup: string;
    PointIncrement: Integer;
    CurveId: QWord;
    Axis: TImpactResponseAxis;
    Space: TImpactResponseSpace;
    Gain: Double;
    ResponseUnitName: string;
    Color: TColor;
    Enabled: Boolean;
    Visible: Boolean;
    procedure Assign(ASource: TImpactResponseBinding);
  end;

  TRecorderImpactHammerComponent = class(TRecorderVisualComponent)
  private
    fHammerTagId: TRecorderTagId;
    fHammerTagName: string;
    fTriggerPolarity: TImpactTriggerPolarity;
    fTriggerThreshold: Double;
    fTriggerHysteresis: Double;
    fPretriggerSamples: Integer;
    fCaptureSamples: Integer;
    fImpactCapacity: Integer;
    fFftSize: Integer;
    fWindowKind: TImpactWindowKind;
    fZeroPadFactor: Integer;
    fEstimator: TImpactFrfEstimator;
    fCoherenceThreshold: Double;
    fWelchSegmentSize: Integer;
    fWelchOverlapPercent: Integer;
    fWelchEnabled: Boolean;
    fSampleRateHz: Double;
    fExcitationUnitName: string;
    fForceWindowFraction: Double;
    fExponentialEndFraction: Double;
    fResponses: TList;
    fAxisStates: array[TRecorderImpactResultType] of TImpactResultAxisState;
    fActiveResultType: TRecorderImpactResultType;
    fExcitationVisible: Boolean;
    fExcitationOwnAxis: Boolean;
    fShowExtrema: Boolean;
    fBasePointNumber: Integer;
    fTarget3dComponentId: string;
    fAnimationScale: Double;
    fAnimationFrequencyHz: Double;
    fExportPath: string;
    fEnabled: Boolean;
    function GetResponse(AIndex: Integer): TImpactResponseBinding;
    function GetResponseCount: Integer;
    function GetAxisState(AType: TRecorderImpactResultType): TImpactResultAxisState;
    procedure SetAxisState(AType: TRecorderImpactResultType;
      const AValue: TImpactResultAxisState);
    function LoadFromStringsUnchecked(AValues: TStrings; const APrefix: string;
      out AError: string): Boolean;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(ASource: TRecorderImpactHammerComponent);
    function AddResponse: TImpactResponseBinding;
    procedure ClearResponses;
    function Validate(out AError: string; ARequireTags: Boolean = True): Boolean;
    procedure SaveToStrings(AValues: TStrings; const APrefix: string);
    function LoadFromStrings(AValues: TStrings; const APrefix: string;
      out AError: string): Boolean;
    property HammerTagId: TRecorderTagId read fHammerTagId write fHammerTagId;
    property HammerTagName: string read fHammerTagName write fHammerTagName;
    property TriggerPolarity: TImpactTriggerPolarity read fTriggerPolarity
      write fTriggerPolarity;
    property TriggerThreshold: Double read fTriggerThreshold write fTriggerThreshold;
    property TriggerHysteresis: Double read fTriggerHysteresis write fTriggerHysteresis;
    property PretriggerSamples: Integer read fPretriggerSamples write fPretriggerSamples;
    property CaptureSamples: Integer read fCaptureSamples write fCaptureSamples;
    property ImpactCapacity: Integer read fImpactCapacity write fImpactCapacity;
    property FftSize: Integer read fFftSize write fFftSize;
    property WindowKind: TImpactWindowKind read fWindowKind write fWindowKind;
    property ZeroPadFactor: Integer read fZeroPadFactor write fZeroPadFactor;
    property Estimator: TImpactFrfEstimator read fEstimator write fEstimator;
    property CoherenceThreshold: Double read fCoherenceThreshold
      write fCoherenceThreshold;
    property WelchSegmentSize: Integer read fWelchSegmentSize write fWelchSegmentSize;
    property WelchOverlapPercent: Integer read fWelchOverlapPercent
      write fWelchOverlapPercent;
    property WelchEnabled: Boolean read fWelchEnabled write fWelchEnabled;
    property SampleRateHz: Double read fSampleRateHz write fSampleRateHz;
    property ExcitationUnitName: string read fExcitationUnitName
      write fExcitationUnitName;
    property ForceWindowFraction: Double read fForceWindowFraction
      write fForceWindowFraction;
    property ExponentialEndFraction: Double read fExponentialEndFraction
      write fExponentialEndFraction;
    property ResponseCount: Integer read GetResponseCount;
    property Responses[AIndex: Integer]: TImpactResponseBinding read GetResponse;
    property AxisStates[AType: TRecorderImpactResultType]: TImpactResultAxisState
      read GetAxisState write SetAxisState;
    property ActiveResultType: TRecorderImpactResultType
      read fActiveResultType write fActiveResultType;
    property ExcitationVisible: Boolean read fExcitationVisible
      write fExcitationVisible;
    property ExcitationOwnAxis: Boolean read fExcitationOwnAxis
      write fExcitationOwnAxis;
    property ShowExtrema: Boolean read fShowExtrema write fShowExtrema;
    property BasePointNumber: Integer read fBasePointNumber
      write fBasePointNumber;
    property Target3dComponentId: string read fTarget3dComponentId
      write fTarget3dComponentId;
    property AnimationScale: Double read fAnimationScale
      write fAnimationScale;
    property AnimationFrequencyHz: Double read fAnimationFrequencyHz
      write fAnimationFrequencyHz;
    property ExportPath: string read fExportPath write fExportPath;
    property Enabled: Boolean read fEnabled write fEnabled;
  end;

  TRecorderImpactHammerFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create;
  end;

procedure RegisterRecorderImpactHammerFactory(AFactory: TRecorderComponentFactory);

implementation

function EnumInRange(AValue, AHigh: Integer): Boolean;
begin
  Result := (AValue >= 0) and (AValue <= AHigh);
end;

procedure Put(AValues: TStrings; const AKey, AValue: string);
begin
  AValues.Values[AKey] := AValue;
end;

function ReadInt(AValues: TStrings; const AKey: string; ADefault: Int64): Int64;
begin
  if not TryStrToInt64(AValues.Values[AKey], Result) then
    Result := ADefault;
end;

function ReadQWord(AValues: TStrings; const AKey: string;
  ADefault: QWord): QWord;
begin
  if not TryStrToQWord(AValues.Values[AKey], Result) then
    Result := ADefault;
end;

function ReadFloat(AValues: TStrings; const AKey: string; ADefault: Double): Double;
begin
  if not TryStrToFloat(AValues.Values[AKey], Result, DefaultFormatSettings) then
    Result := ADefault;
end;

procedure TImpactResponseBinding.Assign(ASource: TImpactResponseBinding);
begin
  TagId := ASource.TagId;
  TagName := ASource.TagName;
  PointId := ASource.PointId;
  PointGroup := ASource.PointGroup;
  PointIncrement := ASource.PointIncrement;
  CurveId := ASource.CurveId;
  Axis := ASource.Axis;
  Space := ASource.Space;
  Gain := ASource.Gain;
  ResponseUnitName := ASource.ResponseUnitName;
  Color := ASource.Color;
  Enabled := ASource.Enabled;
  Visible := ASource.Visible;
end;

class function TRecorderImpactHammerComponent.GetTypeId: string;
begin
  Result := 'ImpactHammer';
end;

constructor TRecorderImpactHammerComponent.Create;
var
  ResultType: TRecorderImpactResultType;
begin
  inherited Create;
  fResponses := TList.Create;
  fTriggerPolarity := itpPositive;
  fTriggerThreshold := 1.0;
  fTriggerHysteresis := 0.1;
  fPretriggerSamples := 256;
  fCaptureSamples := 4096;
  fImpactCapacity := 32;
  fFftSize := 4096;
  fWindowKind := iwForce;
  fZeroPadFactor := 1;
  fEstimator := ifeH1;
  fCoherenceThreshold := 0.8;
  fWelchSegmentSize := 1024;
  fWelchOverlapPercent := 50;
  fWelchEnabled := True;
  fSampleRateHz := 1024;
  fExcitationUnitName := 'N';
  fForceWindowFraction := 0.1;
  fExponentialEndFraction := 0.01;
  fActiveResultType := irtTime;
  fExcitationVisible := True;
  fExcitationOwnAxis := False;
  fShowExtrema := False;
  fBasePointNumber := 0;
  fAnimationScale := 10000;
  fAnimationFrequencyHz := 100;
  fEnabled := True;
  for ResultType := Low(TRecorderImpactResultType) to
    High(TRecorderImpactResultType) do
  begin
    fAxisStates[ResultType].AutoScale := True;
    fAxisStates[ResultType].XMin := 0;
    fAxisStates[ResultType].XMax := 1;
    fAxisStates[ResultType].YMin := 0;
    fAxisStates[ResultType].YMax := 1;
  end;
  { The time-domain capture always fits itself to the acquired block. Only
    frequency-domain axes expose persistent display settings. }
  fAxisStates[irtTime].AutoScale := True;
end;

destructor TRecorderImpactHammerComponent.Destroy;
begin
  ClearResponses;
  fResponses.Free;
  inherited Destroy;
end;

procedure TRecorderImpactHammerComponent.Assign(
  ASource: TRecorderImpactHammerComponent);
var
  I: Integer;
  ResultType: TRecorderImpactResultType;
begin
  if ASource = nil then
    Exit;
  fHammerTagId := ASource.fHammerTagId;
  fHammerTagName := ASource.fHammerTagName;
  fTriggerPolarity := ASource.fTriggerPolarity;
  fTriggerThreshold := ASource.fTriggerThreshold;
  fTriggerHysteresis := ASource.fTriggerHysteresis;
  fPretriggerSamples := ASource.fPretriggerSamples;
  fCaptureSamples := ASource.fCaptureSamples;
  fImpactCapacity := ASource.fImpactCapacity;
  fFftSize := ASource.fFftSize;
  fWindowKind := ASource.fWindowKind;
  fZeroPadFactor := ASource.fZeroPadFactor;
  fEstimator := ASource.fEstimator;
  fCoherenceThreshold := ASource.fCoherenceThreshold;
  fWelchSegmentSize := ASource.fWelchSegmentSize;
  fWelchOverlapPercent := ASource.fWelchOverlapPercent;
  fWelchEnabled := ASource.fWelchEnabled;
  fSampleRateHz := ASource.fSampleRateHz;
  fExcitationUnitName := ASource.fExcitationUnitName;
  fForceWindowFraction := ASource.fForceWindowFraction;
  fExponentialEndFraction := ASource.fExponentialEndFraction;
  fActiveResultType := ASource.fActiveResultType;
  fExcitationVisible := ASource.fExcitationVisible;
  fExcitationOwnAxis := ASource.fExcitationOwnAxis;
  fShowExtrema := ASource.fShowExtrema;
  fBasePointNumber := ASource.fBasePointNumber;
  fTarget3dComponentId := ASource.fTarget3dComponentId;
  fAnimationScale := ASource.fAnimationScale;
  fAnimationFrequencyHz := ASource.fAnimationFrequencyHz;
  fExportPath := ASource.fExportPath;
  fEnabled := ASource.fEnabled;
  for ResultType := Low(TRecorderImpactResultType) to
    High(TRecorderImpactResultType) do
    fAxisStates[ResultType] := ASource.fAxisStates[ResultType];
  ClearResponses;
  for I := 0 to ASource.ResponseCount - 1 do
    AddResponse.Assign(ASource.Responses[I]);
end;

function TRecorderImpactHammerComponent.AddResponse: TImpactResponseBinding;
begin
  Result := TImpactResponseBinding.Create;
  Result.CurveId := fResponses.Count + 1;
  Result.Enabled := True;
  Result.Visible := True;
  Result.Axis := iraX;
  Result.Space := irsHelperLocal;
  Result.Gain := 1;
  Result.Color := clRed;
  fResponses.Add(Result);
end;

procedure TRecorderImpactHammerComponent.ClearResponses;
begin
  while fResponses.Count > 0 do
  begin
    TObject(fResponses.Last).Free;
    fResponses.Delete(fResponses.Count - 1);
  end;
end;

function TRecorderImpactHammerComponent.GetResponse(
  AIndex: Integer): TImpactResponseBinding;
begin
  Result := TImpactResponseBinding(fResponses[AIndex]);
end;

function TRecorderImpactHammerComponent.GetResponseCount: Integer;
begin
  Result := fResponses.Count;
end;

function TRecorderImpactHammerComponent.GetAxisState(
  AType: TRecorderImpactResultType): TImpactResultAxisState;
begin
  Result := fAxisStates[AType];
end;

procedure TRecorderImpactHammerComponent.SetAxisState(
  AType: TRecorderImpactResultType; const AValue: TImpactResultAxisState);
begin
  fAxisStates[AType] := AValue;
end;

function TRecorderImpactHammerComponent.Validate(out AError: string;
  ARequireTags: Boolean): Boolean;
var
  I, J: Integer;
  lSegmentSamples: Integer;
  ResultType: TRecorderImpactResultType;
  AxisState: TImpactResultAxisState;
begin
  AError := '';
  lSegmentSamples := 0;
  if fWelchEnabled and (fWelchSegmentSize >= 2) then
    lSegmentSamples := fWelchSegmentSize;
  if ARequireTags and (fHammerTagId = 0) and (Trim(fHammerTagName) = '') then
    AError := 'Не выбран тег ударного молотка.'
  else if ARequireTags and (fResponses.Count = 0) then
    AError := 'Добавьте хотя бы один канал отклика.'
  else if fTriggerThreshold <= 0 then
    AError := 'Порог запуска должен быть больше нуля.'
  else if (fTriggerHysteresis < 0) or (fTriggerHysteresis >= fTriggerThreshold) then
    AError := 'Гистерезис должен быть неотрицательным и меньше порога.'
  else if (fPretriggerSamples < 0) or (fCaptureSamples < 2) or
    (fPretriggerSamples >= fCaptureSamples) then
    AError := 'Предыстория должна быть короче интервала захвата.'
  else if fImpactCapacity < 1 then
    AError := 'Ёмкость серии должна быть не меньше одного удара.'
  else if (fFftSize < 2) or ((fFftSize and (fFftSize - 1)) <> 0) then
    AError := 'Размер FFT должен быть степенью двойки.'
  else if not (fZeroPadFactor in [1, 2, 4, 8]) then
    AError := 'Допустимый zero-pad: 1, 2, 4 или 8.'
  else if fFftSize > High(Integer) div fZeroPadFactor then
    AError := 'Размер FFT с zero-pad слишком велик.'
  else if fWelchEnabled and (Int64(fFftSize) * fZeroPadFactor < lSegmentSamples) then
    AError := 'FFT с zero-pad должен вмещать сегмент Welch.'
  else if (fCoherenceThreshold < 0) or (fCoherenceThreshold > 1) then
    AError := 'Порог когерентности должен быть от 0 до 1.'
  else if fWelchEnabled and ((fWelchSegmentSize < 2) or
    (fWelchSegmentSize > fCaptureSamples)) then
    AError := 'Сегмент Welch должен помещаться в интервал захвата.'
  else if fWelchEnabled and ((fWelchOverlapPercent < 0) or
    (fWelchOverlapPercent > 95)) then
    AError := 'Перекрытие Welch должно быть от 0 до 95 процентов.'
  else if fSampleRateHz <= 0 then
    AError := 'Частота дискретизации должна быть больше нуля.'
  else if (fForceWindowFraction <= 0) or (fForceWindowFraction > 1) then
    AError := 'Доля force window должна быть от 0 до 1.'
  else if (fExponentialEndFraction <= 0) or (fExponentialEndFraction > 1) then
    AError := 'Конечная доля exponential window должна быть от 0 до 1.'
  else if fBasePointNumber < 0 then
    AError := 'Базовый номер точки не может быть отрицательным.'
  else if IsNan(fAnimationScale) or IsInfinite(fAnimationScale) or
    (fAnimationScale <= 0) then
    AError := 'Масштаб анимации должен быть больше нуля.'
  else if IsNan(fAnimationFrequencyHz) or
    IsInfinite(fAnimationFrequencyHz) or (fAnimationFrequencyHz <= 0) then
    AError := 'Частота анимации должна быть больше нуля.';
  if AError = '' then
    for ResultType := Low(TRecorderImpactResultType) to
      High(TRecorderImpactResultType) do
    begin
      AxisState := fAxisStates[ResultType];
      if not AxisState.AutoScale and
        ((AxisState.XMax <= AxisState.XMin) or
         (AxisState.YMax <= AxisState.YMin)) then
        AError := 'Ручные диапазоны результата должны возрастать.'
      else if AxisState.LogX and (AxisState.XMin <= 0) then
        AError := 'Логарифмическая шкала X требует положительного минимума.'
      else if AxisState.LogY and (AxisState.YMin <= 0) then
        AError := 'Логарифмическая шкала Y требует положительного минимума.';
      if AError <> '' then
        Break;
    end;
  if AError = '' then
    for I := 0 to ResponseCount - 1 do
    begin
      if Responses[I].CurveId = 0 then
        AError := 'Идентификатор FRF-кривой должен быть ненулевым.'
      else if IsNan(Responses[I].Gain) or IsInfinite(Responses[I].Gain) then
        AError := 'Коэффициент движения должен быть конечным.'
      else if (Responses[I].PointIncrement < 0) or
        (Responses[I].PointIncrement > 255) then
        AError := 'Приращение номера точки должно быть от 0 до 255.';
      for J := 0 to I - 1 do
        if Responses[J].CurveId = Responses[I].CurveId then
          AError := 'Идентификаторы FRF-кривых должны быть уникальными.';
      if AError <> '' then
        Break;
    end;
  Result := AError = '';
end;

procedure TRecorderImpactHammerComponent.SaveToStrings(AValues: TStrings;
  const APrefix: string);
var
  I: Integer;
  R: TImpactResponseBinding;
  P: string;
  ResultType: TRecorderImpactResultType;
  AxisState: TImpactResultAxisState;
begin
  Put(AValues, APrefix + 'HammerTagId', IntToStr(fHammerTagId));
  Put(AValues, APrefix + 'HammerTagName', fHammerTagName);
  Put(AValues, APrefix + 'TriggerPolarity', IntToStr(Ord(fTriggerPolarity)));
  Put(AValues, APrefix + 'TriggerThreshold', FloatToStr(fTriggerThreshold, DefaultFormatSettings));
  Put(AValues, APrefix + 'TriggerHysteresis', FloatToStr(fTriggerHysteresis, DefaultFormatSettings));
  Put(AValues, APrefix + 'PretriggerSamples', IntToStr(fPretriggerSamples));
  Put(AValues, APrefix + 'CaptureSamples', IntToStr(fCaptureSamples));
  Put(AValues, APrefix + 'ImpactCapacity', IntToStr(fImpactCapacity));
  Put(AValues, APrefix + 'FftSize', IntToStr(fFftSize));
  Put(AValues, APrefix + 'WindowKind', IntToStr(Ord(fWindowKind)));
  Put(AValues, APrefix + 'ZeroPadFactor', IntToStr(fZeroPadFactor));
  Put(AValues, APrefix + 'Estimator', IntToStr(Ord(fEstimator)));
  Put(AValues, APrefix + 'CoherenceThreshold', FloatToStr(fCoherenceThreshold, DefaultFormatSettings));
  Put(AValues, APrefix + 'WelchSegmentSize', IntToStr(fWelchSegmentSize));
  Put(AValues, APrefix + 'WelchOverlapPercent', IntToStr(fWelchOverlapPercent));
  Put(AValues, APrefix + 'WelchEnabled', BoolToStr(fWelchEnabled, True));
  Put(AValues, APrefix + 'Version',
    IntToStr(RECORDER_IMPACT_HAMMER_CONFIG_VERSION));
  Put(AValues, APrefix + 'SampleRateHz', FloatToStr(fSampleRateHz, DefaultFormatSettings));
  Put(AValues, APrefix + 'ExcitationUnitName', fExcitationUnitName);
  Put(AValues, APrefix + 'ForceWindowFraction', FloatToStr(fForceWindowFraction, DefaultFormatSettings));
  Put(AValues, APrefix + 'ExponentialEndFraction', FloatToStr(fExponentialEndFraction, DefaultFormatSettings));
  Put(AValues, APrefix + 'ResponseCount', IntToStr(ResponseCount));
  Put(AValues, APrefix + 'ActiveResultType', IntToStr(Ord(fActiveResultType)));
  Put(AValues, APrefix + 'ExcitationVisible',
    BoolToStr(fExcitationVisible, True));
  Put(AValues, APrefix + 'ExcitationOwnAxis',
    BoolToStr(fExcitationOwnAxis, True));
  Put(AValues, APrefix + 'ShowExtrema', BoolToStr(fShowExtrema, True));
  Put(AValues, APrefix + 'BasePointNumber', IntToStr(fBasePointNumber));
  Put(AValues, APrefix + 'Target3dComponentId', fTarget3dComponentId);
  Put(AValues, APrefix + 'AnimationScale', FloatToStr(fAnimationScale,
    DefaultFormatSettings));
  Put(AValues, APrefix + 'AnimationFrequencyHz',
    FloatToStr(fAnimationFrequencyHz, DefaultFormatSettings));
  Put(AValues, APrefix + 'ExportPath', fExportPath);
  Put(AValues, APrefix + 'Enabled', BoolToStr(fEnabled, True));
  for ResultType := Low(TRecorderImpactResultType) to
    High(TRecorderImpactResultType) do
  begin
    AxisState := fAxisStates[ResultType];
    P := APrefix + 'Axis.' + IntToStr(Ord(ResultType)) + '.';
    Put(AValues, P + 'LogX', BoolToStr(AxisState.LogX, True));
    Put(AValues, P + 'LogY', BoolToStr(AxisState.LogY, True));
    Put(AValues, P + 'AutoScale', BoolToStr(AxisState.AutoScale, True));
    Put(AValues, P + 'XMin', FloatToStr(AxisState.XMin,
      DefaultFormatSettings));
    Put(AValues, P + 'XMax', FloatToStr(AxisState.XMax,
      DefaultFormatSettings));
    Put(AValues, P + 'YMin', FloatToStr(AxisState.YMin,
      DefaultFormatSettings));
    Put(AValues, P + 'YMax', FloatToStr(AxisState.YMax,
      DefaultFormatSettings));
  end;
  for I := 0 to ResponseCount - 1 do
  begin
    R := Responses[I];
    P := APrefix + 'Response.' + IntToStr(I) + '.';
    Put(AValues, P + 'TagId', IntToStr(R.TagId));
    Put(AValues, P + 'TagName', R.TagName);
    Put(AValues, P + 'PointId', R.PointId);
    Put(AValues, P + 'PointGroup', R.PointGroup);
    Put(AValues, P + 'PointIncrement', IntToStr(R.PointIncrement));
    Put(AValues, P + 'CurveId', UIntToStr(R.CurveId));
    Put(AValues, P + 'Axis', IntToStr(Ord(R.Axis)));
    Put(AValues, P + 'Space', IntToStr(Ord(R.Space)));
    Put(AValues, P + 'Gain', FloatToStr(R.Gain, DefaultFormatSettings));
    Put(AValues, P + 'ResponseUnitName', R.ResponseUnitName);
    Put(AValues, P + 'Color', IntToStr(R.Color));
    Put(AValues, P + 'Enabled', BoolToStr(R.Enabled, True));
    Put(AValues, P + 'Visible', BoolToStr(R.Visible, True));
  end;
end;

function TRecorderImpactHammerComponent.LoadFromStringsUnchecked(AValues: TStrings;
  const APrefix: string; out AError: string): Boolean;
var
  I: Integer;
  N: Integer;
  V: Integer;
  R: TImpactResponseBinding;
  P: string;
  ModelVersion: Integer;
  ResultType: TRecorderImpactResultType;
  AxisState: TImpactResultAxisState;
begin
  ModelVersion := ReadInt(AValues, APrefix + 'Version', 1);
  if (ModelVersion < 1) or
    (ModelVersion > RECORDER_IMPACT_HAMMER_CONFIG_VERSION) then
  begin
    AError := Format('Неподдерживаемая версия настроек ударного FRF: %d.',
      [ModelVersion]);
    Exit(False);
  end;
  fHammerTagId := ReadInt(AValues, APrefix + 'HammerTagId', 0);
  fHammerTagName := AValues.Values[APrefix + 'HammerTagName'];
  V := ReadInt(AValues, APrefix + 'TriggerPolarity', Ord(itpPositive));
  if EnumInRange(V, Ord(High(TImpactTriggerPolarity))) then
    fTriggerPolarity := TImpactTriggerPolarity(V);
  fTriggerThreshold := ReadFloat(AValues, APrefix + 'TriggerThreshold', 1);
  fTriggerHysteresis := ReadFloat(AValues, APrefix + 'TriggerHysteresis', 0.1);
  fPretriggerSamples := ReadInt(AValues, APrefix + 'PretriggerSamples', 256);
  fCaptureSamples := ReadInt(AValues, APrefix + 'CaptureSamples', 4096);
  fImpactCapacity := ReadInt(AValues, APrefix + 'ImpactCapacity', 32);
  fFftSize := ReadInt(AValues, APrefix + 'FftSize', 4096);
  V := ReadInt(AValues, APrefix + 'WindowKind', Ord(iwForce));
  if EnumInRange(V, Ord(High(TImpactWindowKind))) then
    fWindowKind := TImpactWindowKind(V);
  fZeroPadFactor := ReadInt(AValues, APrefix + 'ZeroPadFactor', 1);
  V := ReadInt(AValues, APrefix + 'Estimator', 0);
  if ModelVersion < 2 then
    Inc(V);
  if EnumInRange(V, Ord(High(TImpactFrfEstimator))) then
    fEstimator := TImpactFrfEstimator(V);
  fCoherenceThreshold := ReadFloat(AValues, APrefix + 'CoherenceThreshold', 0.8);
  fWelchSegmentSize := ReadInt(AValues, APrefix + 'WelchSegmentSize', 1024);
  fWelchOverlapPercent := ReadInt(AValues, APrefix + 'WelchOverlapPercent', 50);
  fWelchEnabled := StrToBoolDef(AValues.Values[APrefix + 'WelchEnabled'], True);
  fSampleRateHz := ReadFloat(AValues, APrefix + 'SampleRateHz', 1024);
  fExcitationUnitName := AValues.Values[APrefix + 'ExcitationUnitName'];
  if fExcitationUnitName = '' then
    fExcitationUnitName := 'N';
  fForceWindowFraction := ReadFloat(AValues, APrefix + 'ForceWindowFraction', 0.1);
  fExponentialEndFraction := ReadFloat(AValues, APrefix + 'ExponentialEndFraction', 0.01);
  V := ReadInt(AValues, APrefix + 'ActiveResultType', Ord(irtTime));
  if EnumInRange(V, Ord(High(TRecorderImpactResultType))) then
    fActiveResultType := TRecorderImpactResultType(V);
  fExcitationVisible := StrToBoolDef(
    AValues.Values[APrefix + 'ExcitationVisible'], True);
  fExcitationOwnAxis := StrToBoolDef(
    AValues.Values[APrefix + 'ExcitationOwnAxis'], False);
  fShowExtrema := StrToBoolDef(
    AValues.Values[APrefix + 'ShowExtrema'], False);
  fBasePointNumber := ReadInt(AValues, APrefix + 'BasePointNumber', 0);
  fTarget3dComponentId := AValues.Values[APrefix + 'Target3dComponentId'];
  fAnimationScale := ReadFloat(AValues, APrefix + 'AnimationScale', 10000);
  fAnimationFrequencyHz := ReadFloat(AValues,
    APrefix + 'AnimationFrequencyHz', 100);
  fExportPath := AValues.Values[APrefix + 'ExportPath'];
  fEnabled := StrToBoolDef(AValues.Values[APrefix + 'Enabled'], True);
  for ResultType := Low(TRecorderImpactResultType) to
    High(TRecorderImpactResultType) do
  begin
    P := APrefix + 'Axis.' + IntToStr(Ord(ResultType)) + '.';
    AxisState := fAxisStates[ResultType];
    AxisState.LogX := StrToBoolDef(AValues.Values[P + 'LogX'],
      AxisState.LogX);
    AxisState.LogY := StrToBoolDef(AValues.Values[P + 'LogY'],
      AxisState.LogY);
    AxisState.AutoScale := StrToBoolDef(AValues.Values[P + 'AutoScale'],
      AxisState.AutoScale);
    AxisState.XMin := ReadFloat(AValues, P + 'XMin', AxisState.XMin);
    AxisState.XMax := ReadFloat(AValues, P + 'XMax', AxisState.XMax);
    AxisState.YMin := ReadFloat(AValues, P + 'YMin', AxisState.YMin);
    AxisState.YMax := ReadFloat(AValues, P + 'YMax', AxisState.YMax);
    fAxisStates[ResultType] := AxisState;
  end;
  fAxisStates[irtTime].AutoScale := True;
  ClearResponses;
  N := ReadInt(AValues, APrefix + 'ResponseCount', 0);
  if N < 0 then
    N := 0;
  for I := 0 to N - 1 do
  begin
    R := AddResponse;
    P := APrefix + 'Response.' + IntToStr(I) + '.';
    R.TagId := ReadInt(AValues, P + 'TagId', 0);
    R.TagName := AValues.Values[P + 'TagName'];
    R.PointId := AValues.Values[P + 'PointId'];
    R.PointGroup := AValues.Values[P + 'PointGroup'];
    R.PointIncrement := ReadInt(AValues, P + 'PointIncrement', 0);
    R.CurveId := ReadQWord(AValues, P + 'CurveId', I + 1);
    V := ReadInt(AValues, P + 'Axis', Ord(iraX));
    if EnumInRange(V, Ord(High(TImpactResponseAxis))) then
      R.Axis := TImpactResponseAxis(V);
    V := ReadInt(AValues, P + 'Space', Ord(irsHelperLocal));
    if EnumInRange(V, Ord(High(TImpactResponseSpace))) then
      R.Space := TImpactResponseSpace(V);
    R.Gain := ReadFloat(AValues, P + 'Gain', 1);
    R.ResponseUnitName := AValues.Values[P + 'ResponseUnitName'];
    if R.ResponseUnitName = '' then
      R.ResponseUnitName := AValues.Values[P + 'UnitName'];
    R.Color := ReadInt(AValues, P + 'Color', clRed);
    R.Enabled := StrToBoolDef(AValues.Values[P + 'Enabled'], True);
    R.Visible := StrToBoolDef(AValues.Values[P + 'Visible'], True);
  end;
  Result := Validate(AError);
  { A newly placed component is deliberately persisted before its channels are
    selected. Loading must restore that editable draft; runtime Configure and
    the settings dialog still require full validation before measurement. }
  if not Result and (((fHammerTagId = 0) and
    (Trim(fHammerTagName) = '')) or (ResponseCount = 0)) then
  begin
    AError := '';
    Result := True;
  end;
end;

function TRecorderImpactHammerComponent.LoadFromStrings(AValues: TStrings;
  const APrefix: string; out AError: string): Boolean;
var
  Draft: TRecorderImpactHammerComponent;
begin
  Draft := TRecorderImpactHammerComponent.Create;
  try
    Result := Draft.LoadFromStringsUnchecked(AValues, APrefix, AError);
    if Result then
      Assign(Draft);
  finally
    Draft.Free;
  end;
end;

constructor TRecorderImpactHammerFactory.Create;
begin
  inherited Create(TRecorderImpactHammerComponent.TypeId, 'Ударный FRF',
    TRecorderImpactHammerComponent, 640, 420, False);
  ConfigurePalette('Ударный FRF', 'Измерение FRF ударным молотком',
    'impact-hammer', 46, rppGroup, CRecorderPaletteGroupCharts);
end;

procedure TRecorderImpactHammerFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  AComponent.Name := Format('ImpactHammer%d', [AContext.ComponentNo]);
end;

procedure RegisterRecorderImpactHammerFactory(AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and
    (not AFactory.IsComponentRegistered(TRecorderImpactHammerComponent.TypeId)) then
    AFactory.RegisterFactory(TRecorderImpactHammerFactory.Create);
end;

end.
