unit uRecorderSpectrumRuntime;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs, uRecorderCoreServices, uRecorderTags, uRecorderSpectrumEngine;

type
  { TRecorderCachedSpectrumFrame
    Кэш кадра спектра в памяти для предотвращения очистки графиков при переключениях страниц. }
  TRecorderCachedSpectrumFrame = class(TObject)
  public
    SourceTagName: string;
    FrameIndex: Int64;
    StartTimeSec: Double;
    EndTimeSec: Double;
    SampleRateHz: Double;
    FFTSize: Integer;
    Bins: Integer;
    FrequencyStepHz: Double;
    MaxIndex: Integer;
    MaxFrequencyHz: Double;
    MaxRms: Double;
    Rms: array of Double;
    PhaseRad: array of Double;
    constructor Create(const AFrame: TRecorderSpectrumFrame);
    procedure AssignFrom(const AFrame: TRecorderSpectrumFrame);
  end;

  { TRecorderSpectrumFrameEventData
    Контейнер события для передачи кадра спектра через EventBus. }
  TRecorderSpectrumFrameEventData = class(TObject)
  private
    fFrame: TRecorderSpectrumFrame;
  public
    constructor Create(const AFrame: TRecorderSpectrumFrame);
    property Frame: TRecorderSpectrumFrame read fFrame;
  end;

  { TRecorderSpectrumRuntimeManager
    Менеджер рантайм-вычислений спектров. }
  TRecorderSpectrumRuntimeManager = class(TObject)
  private
    fEventBus: TRecorderEventBus;
    fTagRegistry: TRecorderTagRegistry;
    fToken: Integer;
    fChannels: TList; // Список TRecorderSpectrumChannel
    fCache: TList;    // Список кэшированных кадров (TRecorderCachedSpectrumFrame)
    fLock: TCriticalSection;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    procedure HandleChannelFrame(ASender: TObject; const AFrame: TRecorderSpectrumFrame);
    function FindChannel(const ATagName: string): TRecorderSpectrumChannel;
    procedure UpdateCache(const AFrame: TRecorderSpectrumFrame);
    procedure ClearCache;
  public
    class var fInstance: TRecorderSpectrumRuntimeManager;
    class function Instance: TRecorderSpectrumRuntimeManager;
    constructor Create(AEventBus: TRecorderEventBus; ATagRegistry: TRecorderTagRegistry);
    destructor Destroy; override;
    procedure RebuildChannels;
    procedure ClearChannels;
    function GetLastFrame(const ATagName: string; var AFrame: TRecorderSpectrumFrame): Boolean;
  end;

implementation

{ TRecorderCachedSpectrumFrame }

constructor TRecorderCachedSpectrumFrame.Create(const AFrame: TRecorderSpectrumFrame);
begin
  inherited Create;
  AssignFrom(AFrame);
end;

procedure TRecorderCachedSpectrumFrame.AssignFrom(const AFrame: TRecorderSpectrumFrame);
begin
  SourceTagName := AFrame.SourceTagName;
  FrameIndex := AFrame.FrameIndex;
  StartTimeSec := AFrame.StartTimeSec;
  EndTimeSec := AFrame.EndTimeSec;
  SampleRateHz := AFrame.SampleRateHz;
  FFTSize := AFrame.FFTSize;
  Bins := AFrame.Bins;
  FrequencyStepHz := AFrame.FrequencyStepHz;
  MaxIndex := AFrame.MaxIndex;
  MaxFrequencyHz := AFrame.MaxFrequencyHz;
  MaxRms := AFrame.MaxRms;
  
  SetLength(Rms, Length(AFrame.Rms));
  if Length(AFrame.Rms) > 0 then
    Move(AFrame.Rms[0], Rms[0], Length(AFrame.Rms) * SizeOf(Double));
    
  SetLength(PhaseRad, Length(AFrame.PhaseRad));
  if Length(AFrame.PhaseRad) > 0 then
    Move(AFrame.PhaseRad[0], PhaseRad[0], Length(AFrame.PhaseRad) * SizeOf(Double));
end;

{ TRecorderSpectrumFrameEventData }

constructor TRecorderSpectrumFrameEventData.Create(const AFrame: TRecorderSpectrumFrame);
begin
  inherited Create;
  fFrame := AFrame;
end;

{ TRecorderSpectrumRuntimeManager }

class function TRecorderSpectrumRuntimeManager.Instance: TRecorderSpectrumRuntimeManager;
begin
  Result := fInstance;
end;

constructor TRecorderSpectrumRuntimeManager.Create(AEventBus: TRecorderEventBus; ATagRegistry: TRecorderTagRegistry);
begin
  inherited Create;
  fEventBus := AEventBus;
  fTagRegistry := ATagRegistry;
  fChannels := TList.Create;
  fCache := TList.Create;
  fLock := TCriticalSection.Create;
  fInstance := Self;
  if fEventBus <> nil then
    fToken := fEventBus.Subscribe(@HandleEvent);
end;

destructor TRecorderSpectrumRuntimeManager.Destroy;
begin
  if fInstance = Self then
    fInstance := nil;
  if (fEventBus <> nil) and (fToken <> 0) then
  begin
    fEventBus.Unsubscribe(fToken);
    fToken := 0;
  end;
  ClearChannels;
  fChannels.Free;
  ClearCache;
  fCache.Free;
  fLock.Free;
  inherited Destroy;
end;

procedure TRecorderSpectrumRuntimeManager.ClearCache;
var
  I: Integer;
begin
  fLock.Enter;
  try
    for I := 0 to fCache.Count - 1 do
      TObject(fCache[I]).Free;
    fCache.Clear;
  finally
    fLock.Leave;
  end;
end;

procedure TRecorderSpectrumRuntimeManager.UpdateCache(const AFrame: TRecorderSpectrumFrame);
var
  I: Integer;
  lCached: TRecorderCachedSpectrumFrame;
  lFound: Boolean;
begin
  fLock.Enter;
  try
    lFound := False;
    for I := 0 to fCache.Count - 1 do
    begin
      lCached := TRecorderCachedSpectrumFrame(fCache[I]);
      if SameText(lCached.SourceTagName, AFrame.SourceTagName) then
      begin
        lCached.AssignFrom(AFrame);
        lFound := True;
        Break;
      end;
    end;
    if not lFound then
      fCache.Add(TRecorderCachedSpectrumFrame.Create(AFrame));
  finally
    fLock.Leave;
  end;
end;

function TRecorderSpectrumRuntimeManager.GetLastFrame(const ATagName: string; var AFrame: TRecorderSpectrumFrame): Boolean;
var
  I: Integer;
  lCached: TRecorderCachedSpectrumFrame;
begin
  Result := False;
  fLock.Enter;
  try
    for I := 0 to fCache.Count - 1 do
    begin
      lCached := TRecorderCachedSpectrumFrame(fCache[I]);
      if SameText(lCached.SourceTagName, ATagName) then
      begin
        AFrame.SourceTagName := lCached.SourceTagName;
        AFrame.FrameIndex := lCached.FrameIndex;
        AFrame.StartTimeSec := lCached.StartTimeSec;
        AFrame.EndTimeSec := lCached.EndTimeSec;
        AFrame.SampleRateHz := lCached.SampleRateHz;
        AFrame.FFTSize := lCached.FFTSize;
        AFrame.Bins := lCached.Bins;
        AFrame.FrequencyStepHz := lCached.FrequencyStepHz;
        AFrame.MaxIndex := lCached.MaxIndex;
        AFrame.MaxFrequencyHz := lCached.MaxFrequencyHz;
        AFrame.MaxRms := lCached.MaxRms;
        
        SetLength(AFrame.Rms, Length(lCached.Rms));
        if Length(lCached.Rms) > 0 then
          Move(lCached.Rms[0], AFrame.Rms[0], Length(lCached.Rms) * SizeOf(Double));
          
        SetLength(AFrame.PhaseRad, Length(lCached.PhaseRad));
        if Length(lCached.PhaseRad) > 0 then
          Move(lCached.PhaseRad[0], AFrame.PhaseRad[0], Length(lCached.PhaseRad) * SizeOf(Double));
          
        Result := True;
        Break;
      end;
    end;
  finally
    fLock.Leave;
  end;
end;

function TRecorderSpectrumRuntimeManager.FindChannel(const ATagName: string): TRecorderSpectrumChannel;
var
  I: Integer;
  lChan: TRecorderSpectrumChannel;
begin
  Result := nil;
  for I := 0 to fChannels.Count - 1 do
  begin
    lChan := TRecorderSpectrumChannel(fChannels[I]);
    if SameText(lChan.SourceTagName, ATagName) then
      Exit(lChan);
  end;
end;

procedure TRecorderSpectrumRuntimeManager.ClearChannels;
var
  I: Integer;
begin
  for I := 0 to fChannels.Count - 1 do
    TObject(fChannels[I]).Free;
  fChannels.Clear;
end;

procedure TRecorderSpectrumRuntimeManager.RebuildChannels;
var
  I, J: Integer;
  lNode: TRecorderSpectrumConfigNode;
  lBinding: TRecorderSpectrumTagBinding;
  lSettings: TRecorderSpectrumSettings;
  lChannel: TRecorderSpectrumChannel;
  lTagName: string;
begin
  ClearChannels;
  if (fTagRegistry = nil) or (fTagRegistry.SpectrumConfigs = nil) then
    Exit;

  for I := 0 to fTagRegistry.SpectrumConfigs.NodeCount - 1 do
  begin
    lNode := fTagRegistry.SpectrumConfigs.Nodes[I];
    for J := 0 to lNode.BindingCount - 1 do
    begin
      lBinding := lNode.Bindings[J];
      lTagName := lBinding.SourceTagName;
      lSettings := lBinding.ResolveSettings(lNode.Settings);

      // Валидируем настройки
      try
        lSettings.Validate;
      except
        on E: Exception do
          Continue; // Пропускаем невалидные привязки
      end;

      lChannel := TRecorderSpectrumChannel.Create(lTagName, lSettings);
      lChannel.OnFrame := @HandleChannelFrame;
      fChannels.Add(lChannel);
    end;
  end;
end;

procedure TRecorderSpectrumRuntimeManager.HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
var
  lTagData: TRecorderTagUpdateEventData;
  lChannel: TRecorderSpectrumChannel;
begin
  if (AEvent.Kind <> rceDataUpdated) or (not (AEvent.Data is TRecorderTagUpdateEventData)) then
    Exit;

  lTagData := TRecorderTagUpdateEventData(AEvent.Data);
  lChannel := FindChannel(lTagData.Tag.Name);
  if lChannel <> nil then
  begin
    if lTagData.SampleCount = 1 then
      lChannel.FeedSamples([lTagData.TimeSec], [lTagData.Value], 1)
    else if lTagData.SampleCount > 1 then
      lChannel.FeedSamples(lTagData.Times, lTagData.Values, lTagData.SampleCount);
  end;
end;

procedure TRecorderSpectrumRuntimeManager.HandleChannelFrame(ASender: TObject; const AFrame: TRecorderSpectrumFrame);
var
  lEventData: TRecorderSpectrumFrameEventData;
  lEvent: TRecorderEvent;
begin
  UpdateCache(AFrame);
  if fEventBus = nil then Exit;
  lEventData := TRecorderSpectrumFrameEventData.Create(AFrame);
  try
    lEvent := TRecorderEventBus.MakeEvent(rceSpectrumFrame, Self, AFrame.SourceTagName, '', 0, lEventData);
    fEventBus.Publish(lEvent);
  finally
    lEventData.Free;
  end;
end;

end.
