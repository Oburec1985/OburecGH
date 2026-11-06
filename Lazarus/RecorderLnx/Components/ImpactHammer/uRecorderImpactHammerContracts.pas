unit uRecorderImpactHammerContracts;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Контракты состояния, команд и отображения между сервисом измерений и UI.
  Модуль не зависит от LCL, поэтому его типы доступны тестам и адаптерам. }

interface

uses
  Classes, SysUtils, uRecorderFrfContracts, u3dMotionContracts, uRecorderFrfRoute;

type
  TRecorderGeometryBindingMode = (rgbmIntensity, rgbmOscillation);
  TRecorderPointVisualization = (rpvVector, rpvSphere);
  TRecorderIntensitySource = (risFrf, risAmplitude);

  TRecorderModelObjectInfo = record
    NodeId: QWord;
    Name: string;
  end;

  TRecorderModelPointInfo = record
    PointNumber: Integer;
    LabelText: string;
  end;
  TRecorderModelPointSelection = record
    SceneComponentId: string;
    NodeId: QWord;
    PointNumber: Integer;
  end;
  TRecorderModelPointSelectionEvent = procedure(
    const ASelection:TRecorderModelPointSelection) of object;
  IRecorderModelLabeledPointCatalog = interface
    ['{D4E8EA81-65C1-4D2C-99AC-394A5679EB71}']
    function PointCount(ANodeId:QWord):Integer;
    function PointInfo(ANodeId:QWord; AIndex:Integer;
      out AInfo:TRecorderModelPointInfo):Boolean;
  end;

  TRecorderImpactResultType = (irtTime, irtSpectrum, irtFrfMagnitude,
    irtPhase, irtCoherence);

  { Сохраняемые режимы осей и пределы шкал одной вкладки результата. }
  TImpactResultAxisState = record
    LogX: Boolean;
    LogY: Boolean;
    AutoScale: Boolean;
    XMin: Double;
    XMax: Double;
    YMin: Double;
    YMax: Double;
  end;

  TRecorderImpactCurveQuality = (icqUnknown, icqGood, icqLowCoherence,
    icqRejected);

  TRecorderImpactPresentationCurve = record
    CurveId: QWord;
    Name: string;
    UnitName: string;
    Color: LongInt;
    Visible: Boolean;
    ReadOnly: Boolean;
    Quality: TRecorderImpactCurveQuality;
    X: array of Double;
    Y: array of Double;
  end;

  TRecorderImpactResultCurves = record
    ResultType: TRecorderImpactResultType;
    XUnitName: string;
    Curves: array of TRecorderImpactPresentationCurve;
  end;

  TRecorderImpactCursorReadout = record
    { Values и Values2 соответствуют видимым кривым в порядке Results; NaN
      означает, что кривая не содержит значения на частоте курсора. }
    FrequencyHz: Double;
    FrequencyHz2: Double;
    HasSecond: Boolean;
    Values: array of Double;
    Values2: array of Double;
  end;

  TRecorderImpactHammerState = (
    ihsIdle,
    ihsArmed,
    ihsRunning,
    ihsStopping,
    ihsCompleted,
    ihsFault
  );

  TRecorderImpactProcessingSettings = record
    Estimator: Integer;
    WindowKind: Integer;
    WelchEnabled: Boolean;
    WelchSegmentSize: Integer;
    WelchOverlapPercent: Integer;
  end;

  { Окно обработки задаётся секундами от начала захваченного удара.
    ExponentialEndLevel — конечная амплитуда в долях от начальной. }
  TRecorderImpactFilterWindow = record
    Enabled: Boolean;
    StartSeconds: Double;
    EndSeconds: Double;
    ExponentialStartSeconds: Double;
    ExponentialEndSeconds: Double;
    ExponentialEndLevel: Double;
  end;

  TRecorderModelPointBinding = record
    CurveId: QWord;
    PointGroup: string;
    PointNumber: Integer;
    TargetNodeId: QWord;
    Axis: T3dMotionAxis;
    Space: T3dMotionSpace;
    Gain: Double;
    Enabled: Boolean;
    Mode: TRecorderGeometryBindingMode;
    ModifierTargetNodeId: QWord;
    IntensityOnly: Boolean;
    Visualization: TRecorderPointVisualization;
    Color: LongInt;
    MarkerSizePixels: Double;
    IntensityLogScale: Boolean;
    IntensitySource: TRecorderIntensitySource;
    BandRms,GradientEnabled:Boolean;
    BandTolerancePercent:Double;
    PointLabel:string;
    CreateColorModifier,HideAnchors:Boolean;
    OnlySensors:Boolean;
    ShowIntensityValues:Boolean;
    EnvelopeXEnabled,EnvelopeYEnabled,EnvelopeZEnabled:Boolean;
    EnvelopeX,EnvelopeY,EnvelopeZ:Double;
  end;

  IRecorderModelPointCatalog = interface
    ['{463A8057-041C-46B1-B1C5-DF2E09709E70}']
    function ResolvePoint(const APointGroup: string; APointNumber: Integer;
      out ATargetNodeId: QWord): Boolean;
    function ObjectCount: Integer;
    function ObjectInfo(AIndex: Integer;
      out AInfo: TRecorderModelObjectInfo): Boolean;
  end;

  { Управление подписями сцены независимо от числа связей: позволяет скрыть
    подписи вершин даже на пустом шаге маршрута. }
  IRecorderModelVertexLabelMode = interface
    ['{0D2EB857-302E-4876-985A-B80C45E5A66F}']
    procedure SetVertexLabelMode(AOnlyCurrentStep:Boolean);
    procedure SetCurrentStepPoints(const ABindings:array of TRecorderModelPointBinding);
  end;

  IRecorderModelPointBindingSink = interface
    ['{7961F2E8-85BF-4E43-BEB0-83538857D3EF}']
    procedure PublishBindings(const ASourceBindingId,
      ATargetComponentId: string;
      const ABindings: array of TRecorderModelPointBinding);
    procedure RemoveBindings(const ASourceBindingId: string);
    procedure ConfigureAnimation(const ASourceBindingId: string;
      AScale, AFrequencyHz: Double);
    procedure PlayAnimation(const ASourceBindingId: string);
    procedure StopAnimation(const ASourceBindingId: string);
  end;

  TRecorderImpactHammerSnapshot = record
    // A requested window is visible immediately; frequency curves catch up
    // asynchronously. UI may poll until this acknowledgement becomes False.
    FilterRebuildPending: Boolean;
    State: TRecorderImpactHammerState;
    StatusText: string;
    ProgressPercent: Integer;
    ImpactIndex: Integer;
    ImpactCount: Integer;
    ImpactHidden: Boolean;
    CanNavigatePrevious: Boolean;
    CanNavigateNext: Boolean;
    CanHide: Boolean;
    CanDelete: Boolean;
    CanStart: Boolean;
    CanArm: Boolean;
    CanCapturePortion: Boolean;
    CanStop: Boolean;
    TriggerEnabled: Boolean;
    RecorderRunning: Boolean;
    RouteTagSync: Boolean;
    RouteAutoMode: Boolean;
    Results: array[TRecorderImpactResultType] of TRecorderImpactResultCurves;
    Cursor: TRecorderImpactCursorReadout;
    FilterWindow: TRecorderImpactFilterWindow;
    CaptureDurationSeconds: Double;
  end;

  IRecorderFrfRouteService = interface
    ['{03B792D6-6097-48A5-B3B4-A3E4B9CB34AF}']
    function Route: TRecorderFrfRoute;
    function CaptureRouteStep(out AError: string): Boolean;
    function SelectRoutePoint(AIndex: Integer; out AError: string): Boolean;
    function SaveRoutePoint(out AError: string): Boolean;
    function RoutePointHasData: Boolean;
    function ShowSavedRoute(out AError: string): Boolean;
    function SetResultReview(AEnabled, AShowValues: Boolean; out AError: string): Boolean;
    procedure UseLiveRoute;
  end;

  IRecorderImpactHammerApplicationService = interface
    ['{A788C011-3BC4-479E-A092-0A06BB1F5B13}']
    procedure NavigateToPreviousImpact;
    procedure NavigateToNextImpact;
    procedure SetCurrentImpactHidden(AHidden: Boolean);
    procedure DeleteCurrentImpact;
    procedure StartMeasurement;
    procedure ArmMeasurement;
    procedure SetTriggerEnabled(AEnabled: Boolean);
    procedure SetRouteTagSync(AEnabled: Boolean);
    function PollRouteTagSync: Boolean;
    procedure SetRouteAutoMode(AEnabled: Boolean);
    procedure CancelRouteAutomation;
    procedure PollRouteAutomation;
    { Захватывает одну порцию после вызова, независимо от порога. После неё
      захват останавливается; накопленные измерения и данные маршрута остаются. }
    function TryCapturePortion(out AError: string): Boolean;
    function TryCaptureRingPortion(out AError: string): Boolean;
    procedure StopMeasurement;
    procedure SavePointBindings;
    procedure PlayModelAnimation;
    procedure StopModelAnimation;
    procedure FillSnapshot(out ASnapshot: TRecorderImpactHammerSnapshot);
    function Provider: IRecorderFrfProvider;
    function Revision: QWord;
    function TryUpdateProcessingSettings(
      const ASettings: TRecorderImpactProcessingSettings;
      out AError: string): Boolean;
    function TrySetFilterWindow(const AWindow: TRecorderImpactFilterWindow;
      out AError: string): Boolean;
    function TrySetTriggerThreshold(AValue: Double;
      out AError: string): Boolean;
  end;

procedure RegisterRecorderModelPointTarget(const AComponentId: string;
  const ACatalog: IRecorderModelPointCatalog;
  const ASink: IRecorderModelPointBindingSink);
 { Уведомление для UI-потока; перед уничтожением подписчик должен отписаться. }
procedure SubscribeRecorderModelPointSelection(AEvent:TRecorderModelPointSelectionEvent);
procedure UnsubscribeRecorderModelPointSelection(AEvent:TRecorderModelPointSelectionEvent);
procedure PublishRecorderModelPointSelection(const ASelection:TRecorderModelPointSelection);
function CurrentRecorderModelPointSelection:TRecorderModelPointSelection;
procedure UnregisterRecorderModelPointTarget(const AComponentId: string);
function FindRecorderModelPointTarget(const AComponentId: string;
  out ACatalog: IRecorderModelPointCatalog;
  out ASink: IRecorderModelPointBindingSink): Boolean;
procedure GetRecorderModelPointTargetIds(AIds: TStrings);
procedure SetRecorderGeometryPreview(const AComponentId: string;
  const ABinding: TRecorderModelPointBinding);
procedure ClearRecorderGeometryPreview;
function GetRecorderGeometryPreview(const AComponentId: string;
  out ABinding: TRecorderModelPointBinding; out ARevision: QWord): Boolean;

implementation

type
  TRecorderModelPointTarget = record
    ComponentId: string;
    Catalog: IRecorderModelPointCatalog;
    Sink: IRecorderModelPointBindingSink;
  end;

var
  GPointTargetLock: TRTLCriticalSection;
  GPointTargets: array of TRecorderModelPointTarget;
  GPreviewComponentId: string;
  GPreviewBinding: TRecorderModelPointBinding;
  GPreviewRevision: QWord;
  GSelection:TRecorderModelPointSelection;
  GSelectionEvents:array of TRecorderModelPointSelectionEvent;

{ Добавляет обработчик выбора точки; повторная регистрация той же пары метода и объекта игнорируется. }
procedure SubscribeRecorderModelPointSelection(AEvent:TRecorderModelPointSelectionEvent);
var I:Integer;
begin
  for I:=0 to High(GSelectionEvents) do
    if (TMethod(GSelectionEvents[I]).Code=TMethod(AEvent).Code) and
      (TMethod(GSelectionEvents[I]).Data=TMethod(AEvent).Data) then Exit;
  SetLength(GSelectionEvents,Length(GSelectionEvents)+1);
  GSelectionEvents[High(GSelectionEvents)]:=AEvent;
end;

{ Удаляет все регистрации указанного обработчика выбора точки. }
procedure UnsubscribeRecorderModelPointSelection(AEvent:TRecorderModelPointSelectionEvent);
var I,J:Integer;
begin
  for I:=High(GSelectionEvents) downto 0 do
    if (TMethod(GSelectionEvents[I]).Code=TMethod(AEvent).Code) and
      (TMethod(GSelectionEvents[I]).Data=TMethod(AEvent).Data) then
    begin
      for J:=I to High(GSelectionEvents)-1 do GSelectionEvents[J]:=GSelectionEvents[J+1];
      SetLength(GSelectionEvents,Length(GSelectionEvents)-1);
    end;
end;

{ Сохраняет текущий выбор и рассылает его копии списка подписчиков. }
procedure PublishRecorderModelPointSelection(const ASelection:TRecorderModelPointSelection);
var I:Integer; Events:array of TRecorderModelPointSelectionEvent;
begin
  GSelection:=ASelection;
  Events:=Copy(GSelectionEvents);
  for I:=0 to High(Events) do Events[I](ASelection);
end;

{ Возвращает последнее опубликованное событие выбора точки. }
function CurrentRecorderModelPointSelection:TRecorderModelPointSelection;
begin Result:=GSelection end;

{ Публикует временную привязку геометрии для AComponentId и увеличивает ревизию под блокировкой. }
procedure SetRecorderGeometryPreview(const AComponentId: string;
  const ABinding: TRecorderModelPointBinding);
begin
  EnterCriticalSection(GPointTargetLock);
  try
    GPreviewComponentId := AComponentId;
    GPreviewBinding := ABinding;
    Inc(GPreviewRevision);
  finally LeaveCriticalSection(GPointTargetLock); end;
end;

{ Сбрасывает временную привязку геометрии и увеличивает ревизию. }
procedure ClearRecorderGeometryPreview;
begin
  EnterCriticalSection(GPointTargetLock);
  try
    GPreviewComponentId := '';
    GPreviewBinding := Default(TRecorderModelPointBinding);
    Inc(GPreviewRevision);
  finally LeaveCriticalSection(GPointTargetLock); end;
end;

{ Читает привязку и ревизию; True только если превью принадлежит запрошенному компоненту. }
function GetRecorderGeometryPreview(const AComponentId: string;
  out ABinding: TRecorderModelPointBinding; out ARevision: QWord): Boolean;
begin
  EnterCriticalSection(GPointTargetLock);
  try
    ARevision := GPreviewRevision;
    ABinding := GPreviewBinding;
    Result := (AComponentId <> '') and (AComponentId = GPreviewComponentId);
  finally LeaveCriticalSection(GPointTargetLock); end;
end;

{ Регистрирует каталог и приёмник привязки для компонента; повторная регистрация обновляет пару интерфейсов. }
procedure RegisterRecorderModelPointTarget(const AComponentId: string;
  const ACatalog: IRecorderModelPointCatalog;
  const ASink: IRecorderModelPointBindingSink);
var
  I: Integer;
begin
  if (AComponentId = '') or (ACatalog = nil) or (ASink = nil) then
    Exit;
  EnterCriticalSection(GPointTargetLock);
  try
    for I := 0 to High(GPointTargets) do
      if GPointTargets[I].ComponentId = AComponentId then
      begin
        GPointTargets[I].Catalog := ACatalog;
        GPointTargets[I].Sink := ASink;
        Exit;
      end;
    I := Length(GPointTargets);
    SetLength(GPointTargets, I + 1);
    GPointTargets[I].ComponentId := AComponentId;
    GPointTargets[I].Catalog := ACatalog;
    GPointTargets[I].Sink := ASink;
  finally
    LeaveCriticalSection(GPointTargetLock);
  end;
end;

{ Удаляет цель компонента из реестра синхронизации точек. }
procedure UnregisterRecorderModelPointTarget(const AComponentId: string);
var
  I: Integer;
  J: Integer;
begin
  EnterCriticalSection(GPointTargetLock);
  try
    for I := 0 to High(GPointTargets) do
      if GPointTargets[I].ComponentId = AComponentId then
      begin
        for J := I to High(GPointTargets) - 1 do
          GPointTargets[J] := GPointTargets[J + 1];
        SetLength(GPointTargets, Length(GPointTargets) - 1);
        Exit;
      end;
  finally
    LeaveCriticalSection(GPointTargetLock);
  end;
end;

{ Находит цель по ID и возвращает её каталог и приёмник привязки. }
function FindRecorderModelPointTarget(const AComponentId: string;
  out ACatalog: IRecorderModelPointCatalog;
  out ASink: IRecorderModelPointBindingSink): Boolean;
var
  I: Integer;
begin
  ACatalog := nil;
  ASink := nil;
  EnterCriticalSection(GPointTargetLock);
  try
    for I := 0 to High(GPointTargets) do
      if GPointTargets[I].ComponentId = AComponentId then
      begin
        ACatalog := GPointTargets[I].Catalog;
        ASink := GPointTargets[I].Sink;
        Exit(True);
      end;
  finally
    LeaveCriticalSection(GPointTargetLock);
  end;
  Result := False;
end;

{ Заменяет содержимое AIds списком ID зарегистрированных целей под блокировкой. }
procedure GetRecorderModelPointTargetIds(AIds: TStrings);
var
  I: Integer;
begin
  if AIds = nil then
    Exit;
  AIds.BeginUpdate;
  try
    AIds.Clear;
    EnterCriticalSection(GPointTargetLock);
    try
      for I := 0 to High(GPointTargets) do
        AIds.Add(GPointTargets[I].ComponentId);
    finally
      LeaveCriticalSection(GPointTargetLock);
    end;
  finally
    AIds.EndUpdate;
  end;
end;

initialization
  InitCriticalSection(GPointTargetLock);

finalization
  SetLength(GPointTargets, 0);
  DoneCriticalSection(GPointTargetLock);

end.
