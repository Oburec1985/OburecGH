unit uRecorderAlgorithmManager;

{ Универсальный менеджер алгоритмов RecorderLnx.
  Связи с Recorder и реестром тегов выполняются явными вызовами. EventBus здесь
  не используется: по исходному коду видны подготовка, lifecycle и путь данных. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderTags, uRecorderStateMachine,
  uRecorderSpectrumRuntime;

type
  TRecorderAlgorithmBinding = class(TObject)
  public
    TagId: TRecorderTagId;
    TagName: string;
    Properties: string;
  end;

  TRecorderAlgorithmSettingsFrame = class(TComponent)
  public
    procedure SetProperties(const AProperties: string); virtual; abstract;
    function GetProperties: string; virtual; abstract;
    procedure SetTagProperties(const AProperties: string); virtual; abstract;
    function GetTagProperties: string; virtual; abstract;
  end;

  TRecorderAlgorithm = class(TObject)
  private
    fId: string;
    fDisplayName: string;
    fProperties: string;
    fTagProperties: string;
    fBindings: TList;
    fReady: Boolean;
    fNotReadyReason: string;
  protected
    procedure SetReady(AReady: Boolean; const AReason: string = '');
  public
    constructor Create; virtual;
    destructor Destroy; override;
    class function AlgorithmTypeName: string; virtual; abstract;
    procedure PrepareConfiguration; virtual;
    procedure LinkTags(ATagRegistry: TRecorderTagRegistry); virtual;
    procedure DoStart; virtual;
    procedure DoStop; virtual;
    procedure DoStopRecord; virtual;
    function AcceptsTag(ATag: TRecorderTag): Boolean; virtual;
    procedure DoEvalValue(ATag: TRecorderTag; ATimeSec, AValue: Double); virtual;
    procedure DoEvalBlock(ATag: TRecorderTag; const ATimes, AValues: array of Double;
      ACount: Integer); virtual;
    function Serialize: string; virtual;
    procedure Deserialize(const ASerialized: string); virtual;
    function AddBinding(ATag: TRecorderTag;
      const AProperties: string = ''): TRecorderAlgorithmBinding;
    function BindingCount: Integer;
    function Binding(AIndex: Integer): TRecorderAlgorithmBinding;
    procedure ClearBindings;
    property Properties: string read fProperties write fProperties;
    property TagProperties: string read fTagProperties write fTagProperties;
    property Id: string read fId write fId;
    property DisplayName: string read fDisplayName write fDisplayName;
    property Ready: Boolean read fReady;
    property NotReadyReason: string read fNotReadyReason;
  end;

  TRecorderUnsupportedAlgorithm = class(TRecorderAlgorithm)
  private
    fSerialized: string;
    fUnsupportedTypeName: string;
  public
    constructor CreateUnsupported(const ATypeName, ASerialized: string);
    class function AlgorithmTypeName: string; override;
    function Serialize: string; override;
    property UnsupportedTypeName: string read fUnsupportedTypeName;
  end;

  TRecorderAlgorithmClass = class of TRecorderAlgorithm;
  TRecorderAlgorithmSettingsFrameClass = class of TRecorderAlgorithmSettingsFrame;

  TRecorderAlgorithmTypeRegistration = class(TObject)
  public
    TypeName: string;
    AlgorithmClass: TRecorderAlgorithmClass;
    SettingsFrameClass: TRecorderAlgorithmSettingsFrameClass;
  end;

  { Специфичный для Spectrum фрейм-модель. Визуальный редактор может унаследовать
    его и связать эти строки с LCL-контролами, не меняя контракт менеджера. }
  TRecorderSpectrumAlgorithmSettingsFrame = class(TRecorderAlgorithmSettingsFrame)
  private
    fProperties: string;
    fTagProperties: string;
  public
    procedure SetProperties(const AProperties: string); override;
    function GetProperties: string; override;
    procedure SetTagProperties(const AProperties: string); override;
    function GetTagProperties: string; override;
  end;

  TRecorderSpectrumAlgorithm = class(TRecorderAlgorithm)
  private
    fRuntime: TRecorderSpectrumRuntimeManager;
  public
    constructor CreateWithRuntime(ARuntime: TRecorderSpectrumRuntimeManager);
    class function AlgorithmTypeName: string; override;
    procedure PrepareConfiguration; override;
    procedure DoStart; override;
    function AcceptsTag(ATag: TRecorderTag): Boolean; override;
    procedure DoEvalValue(ATag: TRecorderTag; ATimeSec, AValue: Double); override;
    procedure DoEvalBlock(ATag: TRecorderTag; const ATimes, AValues: array of Double;
      ACount: Integer); override;
    property Runtime: TRecorderSpectrumRuntimeManager read fRuntime;
  end;

  TRecorderAlgorithmManager = class(TObject)
  private
    fTagRegistry: TRecorderTagRegistry;
    fAlgorithms: TList;
    fTypes: TStringList;
    fSpectrumAlgorithm: TRecorderSpectrumAlgorithm;
    procedure HandleValuePublished(Sender: TObject; ATag: TRecorderTag;
      ATimeSec, AValue: Double);
    procedure HandleBlockPublished(Sender: TObject; const ATagName: string;
      const ATimes, AValues: array of Double; ACount: Integer);
    function GetAlgorithm(AIndex: Integer): TRecorderAlgorithm;
    function GetAlgorithmCount: Integer;
  public
    constructor Create(ATagRegistry: TRecorderTagRegistry;
      ASpectrumRuntime: TRecorderSpectrumRuntimeManager);
    destructor Destroy; override;
    procedure RegisterType(const ATypeName: string;
      AAlgorithmClass: TRecorderAlgorithmClass;
      ASettingsFrameClass: TRecorderAlgorithmSettingsFrameClass = nil);
    function IsTypeRegistered(const ATypeName: string): Boolean;
    function CreateAlgorithm(const ATypeName: string): TRecorderAlgorithm;
    function CreateAlgorithmFromString(const ASerialized: string): TRecorderAlgorithm;
    function CreateSettingsFrame(const ATypeName: string;
      AOwner: TComponent): TRecorderAlgorithmSettingsFrame;
    procedure AddAlgorithm(AAlgorithm: TRecorderAlgorithm);
    procedure PrepareConfiguration;
    procedure ValidateStateTransition(ATransition: TRecorderStateTransition);
    procedure HandleStateTransition(ATransition: TRecorderStateTransition);
    property AlgorithmCount: Integer read GetAlgorithmCount;
    property Algorithms[AIndex: Integer]: TRecorderAlgorithm read GetAlgorithm;
    property SpectrumAlgorithm: TRecorderSpectrumAlgorithm read fSpectrumAlgorithm;
  end;

implementation

procedure TRecorderSpectrumAlgorithmSettingsFrame.SetProperties(
  const AProperties: string);
begin
  fProperties := AProperties;
end;

function TRecorderSpectrumAlgorithmSettingsFrame.GetProperties: string;
begin
  Result := fProperties;
end;

procedure TRecorderSpectrumAlgorithmSettingsFrame.SetTagProperties(
  const AProperties: string);
begin
  fTagProperties := AProperties;
end;

function TRecorderSpectrumAlgorithmSettingsFrame.GetTagProperties: string;
begin
  Result := fTagProperties;
end;

procedure TRecorderAlgorithm.SetReady(AReady: Boolean; const AReason: string);
begin
  fReady := AReady;
  if AReady then
    fNotReadyReason := ''
  else
    fNotReadyReason := AReason;
end;

constructor TRecorderAlgorithm.Create;
begin
  inherited Create;
  fBindings := TList.Create;
  fId := IntToHex(PtrUInt(Self), SizeOf(Pointer) * 2);
  fDisplayName := AlgorithmTypeName;
  SetReady(False, 'Алгоритм не подготовлен');
end;

destructor TRecorderAlgorithm.Destroy;
begin
  ClearBindings;
  fBindings.Free;
  inherited Destroy;
end;

procedure TRecorderAlgorithm.PrepareConfiguration;
begin
  SetReady(True);
end;

procedure TRecorderAlgorithm.LinkTags(ATagRegistry: TRecorderTagRegistry);
var
  I: Integer;
  lBinding: TRecorderAlgorithmBinding;
  lTag: TRecorderTag;
begin
  if ATagRegistry = nil then
  begin
    SetReady(False, 'Не создан реестр тегов');
    Exit;
  end;
  for I := 0 to BindingCount - 1 do
  begin
    lBinding := Binding(I);
    lTag := ATagRegistry.FindById(lBinding.TagId);
    if (lTag = nil) and (lBinding.TagName <> '') then
      lTag := ATagRegistry.FindByName(lBinding.TagName);
    if lTag = nil then
    begin
      SetReady(False, 'Не найден входной тег: ' + lBinding.TagName);
      Exit;
    end;
    lBinding.TagId := lTag.Id;
    lBinding.TagName := lTag.Name;
  end;
end;

procedure TRecorderAlgorithm.DoStart;
begin
end;

procedure TRecorderAlgorithm.DoStop;
begin
end;

procedure TRecorderAlgorithm.DoStopRecord;
begin
end;

function TRecorderAlgorithm.AcceptsTag(ATag: TRecorderTag): Boolean;
begin
  Result := ATag <> nil;
end;

procedure TRecorderAlgorithm.DoEvalValue(ATag: TRecorderTag; ATimeSec,
  AValue: Double);
begin
end;

procedure TRecorderAlgorithm.DoEvalBlock(ATag: TRecorderTag; const ATimes,
  AValues: array of Double; ACount: Integer);
begin
end;

function TRecorderAlgorithm.Serialize: string;
var
  lValues: TStringList;
  I: Integer;
  lBinding: TRecorderAlgorithmBinding;
begin
  lValues := TStringList.Create;
  try
    lValues.Values['Type'] := AlgorithmTypeName;
    lValues.Values['Id'] := Id;
    lValues.Values['Name'] := DisplayName;
    lValues.Values['Properties'] := Properties;
    lValues.Values['TagProperties'] := TagProperties;
    lValues.Values['Binding.Count'] := IntToStr(BindingCount);
    for I := 0 to BindingCount - 1 do
    begin
      lBinding := Binding(I);
      lValues.Values[Format('Binding.%d.TagId', [I])] := IntToStr(lBinding.TagId);
      lValues.Values[Format('Binding.%d.TagName', [I])] := lBinding.TagName;
      lValues.Values[Format('Binding.%d.Properties', [I])] := lBinding.Properties;
    end;
    Result := lValues.Text;
  finally
    lValues.Free;
  end;
end;

procedure TRecorderAlgorithm.Deserialize(const ASerialized: string);
var
  lValues: TStringList;
  I, lCount: Integer;
  lBinding: TRecorderAlgorithmBinding;
begin
  lValues := TStringList.Create;
  try
    lValues.Text := ASerialized;
    Properties := lValues.Values['Properties'];
    TagProperties := lValues.Values['TagProperties'];
    if lValues.Values['Id'] <> '' then
      Id := lValues.Values['Id'];
    if lValues.Values['Name'] <> '' then
      DisplayName := lValues.Values['Name'];
    ClearBindings;
    lCount := StrToIntDef(lValues.Values['Binding.Count'], 0);
    for I := 0 to lCount - 1 do
    begin
      lBinding := TRecorderAlgorithmBinding.Create;
      lBinding.TagId := StrToQWordDef(
        lValues.Values[Format('Binding.%d.TagId', [I])], 0);
      lBinding.TagName := lValues.Values[Format('Binding.%d.TagName', [I])];
      lBinding.Properties := lValues.Values[
        Format('Binding.%d.Properties', [I])];
      fBindings.Add(lBinding);
    end;
  finally
    lValues.Free;
  end;
end;

function TRecorderAlgorithm.AddBinding(ATag: TRecorderTag;
  const AProperties: string): TRecorderAlgorithmBinding;
begin
  Result := TRecorderAlgorithmBinding.Create;
  if ATag <> nil then
  begin
    Result.TagId := ATag.Id;
    Result.TagName := ATag.Name;
  end;
  Result.Properties := AProperties;
  fBindings.Add(Result);
end;

function TRecorderAlgorithm.BindingCount: Integer;
begin
  Result := fBindings.Count;
end;

function TRecorderAlgorithm.Binding(AIndex: Integer): TRecorderAlgorithmBinding;
begin
  Result := TRecorderAlgorithmBinding(fBindings[AIndex]);
end;

procedure TRecorderAlgorithm.ClearBindings;
var
  I: Integer;
begin
  for I := 0 to fBindings.Count - 1 do
    TObject(fBindings[I]).Free;
  fBindings.Clear;
end;

constructor TRecorderUnsupportedAlgorithm.CreateUnsupported(const ATypeName,
  ASerialized: string);
begin
  inherited Create;
  fUnsupportedTypeName := ATypeName;
  fSerialized := ASerialized;
  SetReady(False, 'Тип алгоритма не зарегистрирован: ' + ATypeName);
end;

class function TRecorderUnsupportedAlgorithm.AlgorithmTypeName: string;
begin
  Result := 'Unsupported';
end;

function TRecorderUnsupportedAlgorithm.Serialize: string;
begin
  Result := fSerialized;
end;

constructor TRecorderSpectrumAlgorithm.CreateWithRuntime(
  ARuntime: TRecorderSpectrumRuntimeManager);
begin
  inherited Create;
  fRuntime := ARuntime;
end;

class function TRecorderSpectrumAlgorithm.AlgorithmTypeName: string;
begin
  Result := 'Spectrum';
end;

procedure TRecorderSpectrumAlgorithm.PrepareConfiguration;
begin
  if fRuntime = nil then
  begin
    SetReady(False, 'Не создан spectrum runtime');
    Exit;
  end;
  fRuntime.PrepareConfiguration;
  SetReady(fRuntime.IsPrepared, 'Spectrum runtime не подготовлен');
end;

procedure TRecorderSpectrumAlgorithm.DoStart;
begin
  if fRuntime <> nil then
    fRuntime.ResetForNextRun;
end;

function TRecorderSpectrumAlgorithm.AcceptsTag(ATag: TRecorderTag): Boolean;
begin
  Result := (fRuntime <> nil) and (ATag <> nil) and
    fRuntime.HasInputTag(ATag.Name);
end;

procedure TRecorderSpectrumAlgorithm.DoEvalValue(ATag: TRecorderTag;
  ATimeSec, AValue: Double);
begin
  if (fRuntime <> nil) and (ATag <> nil) then
    fRuntime.FeedTagSamples(ATag.Name, [ATimeSec], [AValue], 1);
end;

procedure TRecorderSpectrumAlgorithm.DoEvalBlock(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer);
begin
  if (fRuntime <> nil) and (ATag <> nil) then
    fRuntime.FeedTagSamples(ATag.Name, ATimes, AValues, ACount);
end;

constructor TRecorderAlgorithmManager.Create(ATagRegistry: TRecorderTagRegistry;
  ASpectrumRuntime: TRecorderSpectrumRuntimeManager);
begin
  inherited Create;
  fTagRegistry := ATagRegistry;
  fAlgorithms := TList.Create;
  fTypes := TStringList.Create;
  fTypes.CaseSensitive := False;
  fTypes.Sorted := True;
  fTypes.Duplicates := dupError;
  RegisterType(TRecorderSpectrumAlgorithm.AlgorithmTypeName,
    TRecorderSpectrumAlgorithm, TRecorderSpectrumAlgorithmSettingsFrame);
  fSpectrumAlgorithm := TRecorderSpectrumAlgorithm.CreateWithRuntime(ASpectrumRuntime);
  AddAlgorithm(fSpectrumAlgorithm);
  if fTagRegistry <> nil then
  begin
    fTagRegistry.SetValuePublishedHandler(Self, @HandleValuePublished);
    fTagRegistry.SetBlockPublishedHandler(Self, @HandleBlockPublished);
  end;
end;

destructor TRecorderAlgorithmManager.Destroy;
var
  I: Integer;
begin
  if fTagRegistry <> nil then
  begin
    fTagRegistry.SetValuePublishedHandler(nil, nil);
    fTagRegistry.SetBlockPublishedHandler(nil, nil);
  end;
  for I := 0 to fAlgorithms.Count - 1 do
    TObject(fAlgorithms[I]).Free;
  for I := 0 to fTypes.Count - 1 do
    fTypes.Objects[I].Free;
  fAlgorithms.Free;
  fTypes.Free;
  inherited Destroy;
end;

procedure TRecorderAlgorithmManager.RegisterType(const ATypeName: string;
  AAlgorithmClass: TRecorderAlgorithmClass;
  ASettingsFrameClass: TRecorderAlgorithmSettingsFrameClass);
var
  lRegistration: TRecorderAlgorithmTypeRegistration;
begin
  if Trim(ATypeName) = '' then
    raise Exception.Create('Algorithm type name is empty');
  if AAlgorithmClass = nil then
    raise Exception.CreateFmt('Algorithm class is nil: %s', [ATypeName]);
  if IsTypeRegistered(ATypeName) then
    raise Exception.CreateFmt('Algorithm type already registered: %s', [ATypeName]);
  lRegistration := TRecorderAlgorithmTypeRegistration.Create;
  lRegistration.TypeName := ATypeName;
  lRegistration.AlgorithmClass := AAlgorithmClass;
  lRegistration.SettingsFrameClass := ASettingsFrameClass;
  fTypes.AddObject(ATypeName, lRegistration);
end;

function TRecorderAlgorithmManager.IsTypeRegistered(const ATypeName: string): Boolean;
begin
  Result := fTypes.IndexOf(ATypeName) >= 0;
end;

function TRecorderAlgorithmManager.CreateAlgorithm(const ATypeName: string): TRecorderAlgorithm;
var
  lIndex: Integer;
  lRegistration: TRecorderAlgorithmTypeRegistration;
begin
  lIndex := fTypes.IndexOf(ATypeName);
  if lIndex < 0 then
    raise Exception.CreateFmt('Unknown algorithm type: %s', [ATypeName]);
  lRegistration := TRecorderAlgorithmTypeRegistration(fTypes.Objects[lIndex]);
  Result := lRegistration.AlgorithmClass.Create;
end;

function TRecorderAlgorithmManager.CreateAlgorithmFromString(
  const ASerialized: string): TRecorderAlgorithm;
var
  lValues: TStringList;
begin
  lValues := TStringList.Create;
  try
    lValues.Text := ASerialized;
    if not IsTypeRegistered(lValues.Values['Type']) then
      Exit(TRecorderUnsupportedAlgorithm.CreateUnsupported(
        lValues.Values['Type'], ASerialized));
    Result := CreateAlgorithm(lValues.Values['Type']);
    try
      Result.Deserialize(ASerialized);
    except
      Result.Free;
      raise;
    end;
  finally
    lValues.Free;
  end;
end;

function TRecorderAlgorithmManager.CreateSettingsFrame(const ATypeName: string;
  AOwner: TComponent): TRecorderAlgorithmSettingsFrame;
var
  lIndex: Integer;
  lRegistration: TRecorderAlgorithmTypeRegistration;
begin
  lIndex := fTypes.IndexOf(ATypeName);
  if lIndex < 0 then
    raise Exception.CreateFmt('Unknown algorithm type: %s', [ATypeName]);
  lRegistration := TRecorderAlgorithmTypeRegistration(fTypes.Objects[lIndex]);
  if lRegistration.SettingsFrameClass = nil then
    Exit(nil);
  Result := lRegistration.SettingsFrameClass.Create(AOwner);
end;

procedure TRecorderAlgorithmManager.AddAlgorithm(AAlgorithm: TRecorderAlgorithm);
begin
  if AAlgorithm = nil then
    Exit;
  fAlgorithms.Add(AAlgorithm);
end;

procedure TRecorderAlgorithmManager.PrepareConfiguration;
var
  I: Integer;
begin
  for I := 0 to fAlgorithms.Count - 1 do
  begin
    Algorithms[I].PrepareConfiguration;
    Algorithms[I].LinkTags(fTagRegistry);
  end;
end;

procedure TRecorderAlgorithmManager.ValidateStateTransition(
  ATransition: TRecorderStateTransition);
begin
  { Неготовый алгоритм не должен запрещать запуск остальных каналов Recorder.
    Его исключает проверка Ready в lifecycle и расчётном пути. }
end;

procedure TRecorderAlgorithmManager.HandleStateTransition(
  ATransition: TRecorderStateTransition);
var
  I: Integer;
begin
  case ATransition of
    rstStopToView, rstStopToRecord:
      for I := 0 to fAlgorithms.Count - 1 do
        if Algorithms[I].Ready then
          Algorithms[I].DoStart;
    rstViewToStop:
      for I := 0 to fAlgorithms.Count - 1 do
        if Algorithms[I].Ready then
          Algorithms[I].DoStop;
    rstRecordToStop:
      for I := 0 to fAlgorithms.Count - 1 do
        if Algorithms[I].Ready then
        begin
          Algorithms[I].DoStopRecord;
          Algorithms[I].DoStop;
        end;
    rstRecordToView:
      for I := 0 to fAlgorithms.Count - 1 do
        if Algorithms[I].Ready then
          Algorithms[I].DoStopRecord;
  end;
end;

procedure TRecorderAlgorithmManager.HandleValuePublished(Sender: TObject;
  ATag: TRecorderTag; ATimeSec, AValue: Double);
var
  I: Integer;
begin
  for I := 0 to fAlgorithms.Count - 1 do
    if Algorithms[I].Ready and Algorithms[I].AcceptsTag(ATag) then
      Algorithms[I].DoEvalValue(ATag, ATimeSec, AValue);
end;

procedure TRecorderAlgorithmManager.HandleBlockPublished(Sender: TObject;
  const ATagName: string; const ATimes, AValues: array of Double; ACount: Integer);
var
  I: Integer;
  lTag: TRecorderTag;
begin
  if fTagRegistry = nil then
    Exit;
  lTag := fTagRegistry.FindByName(ATagName);
  if lTag = nil then
    Exit;
  for I := 0 to fAlgorithms.Count - 1 do
    if Algorithms[I].Ready and Algorithms[I].AcceptsTag(lTag) then
      Algorithms[I].DoEvalBlock(lTag, ATimes, AValues, ACount);
end;

function TRecorderAlgorithmManager.GetAlgorithm(AIndex: Integer): TRecorderAlgorithm;
begin
  Result := TRecorderAlgorithm(fAlgorithms[AIndex]);
end;

function TRecorderAlgorithmManager.GetAlgorithmCount: Integer;
begin
  Result := fAlgorithms.Count;
end;

end.
