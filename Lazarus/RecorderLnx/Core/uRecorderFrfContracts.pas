unit uRecorderFrfContracts;

{ Stable read-only FRF sampling contract shared by analysis producers and
  presentation or 3D consumers. Implementations own their immutable data. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  IRecorderFrfSampler = interface
    ['{B491A68B-C7E3-4B03-B598-F7D88C4129C6}']
    function TrySample(ACurveId: QWord; AFrequencyHz: Double;
      out AMagnitude, APhaseRadians: Double): Boolean;
    function Version: QWord;
  end;

  { Thread-safe providers return a retained immutable snapshot. Consumers keep
    the returned interface for the whole read operation. }
  IRecorderFrfProvider = interface
    ['{3E9C205E-7A84-4AA6-9EAA-2A87DCC6130E}']
    function AcquireSnapshot: IRecorderFrfSampler;
  end;

procedure SetRecorderDefaultFrfProvider(
  const AProvider: IRecorderFrfProvider);
function RecorderDefaultFrfProvider: IRecorderFrfProvider;
procedure RegisterRecorderFrfProvider(AOwner: TObject;
  const AProvider: IRecorderFrfProvider);
procedure UnregisterRecorderFrfProvider(AOwner: TObject);
procedure NotifyRecorderFrfProviderChanged(
  const AProvider: IRecorderFrfProvider);
function RecorderAggregateFrfProvider: IRecorderFrfProvider;

implementation

type
  TRecorderFrfProviderEntry = record
    Owner: TObject;
    Provider: IRecorderFrfProvider;
    LastVersion: QWord;
  end;

  { One retained aggregate snapshot represents one atomic view of registry
    membership. Each child snapshot is immutable for the entire read. }
  TRecorderAggregateFrfSnapshot = class(TInterfacedObject,
    IRecorderFrfSampler)
  private
    fVersion: QWord;
    fSnapshots: array of IRecorderFrfSampler;
  public
    constructor Create(AVersion: QWord;
      const ASnapshots: array of IRecorderFrfSampler);
    function TrySample(ACurveId: QWord; AFrequencyHz: Double;
      out AMagnitude, APhaseRadians: Double): Boolean;
    function Version: QWord;
  end;

  { Registry entries are keyed by the owning component/service. Replacing or
    removing one owner cannot discard providers owned by other components. }
  TRecorderAggregateFrfProvider = class(TInterfacedObject,
    IRecorderFrfProvider)
  private
    fLock: TRTLCriticalSection;
    fAcquireLock: TRTLCriticalSection;
    fEntries: array of TRecorderFrfProviderEntry;
    fVersion: QWord;
    fMembershipVersion: QWord;
    fMembershipChanged: Boolean;
    fCachedSnapshot: IRecorderFrfSampler;
    function FindOwner(AOwner: TObject): Integer;
    procedure RebuildSnapshot;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterProvider(AOwner: TObject;
      const AProvider: IRecorderFrfProvider);
    procedure UnregisterProvider(AOwner: TObject);
    procedure ProviderChanged(const AProvider: IRecorderFrfProvider);
    function AcquireSnapshot: IRecorderFrfSampler;
  end;

var
  GProviderLock: TRTLCriticalSection;
  GProvider: IRecorderFrfProvider;
  GAggregate: TRecorderAggregateFrfProvider;
  GAggregateProvider: IRecorderFrfProvider;

constructor TRecorderAggregateFrfSnapshot.Create(AVersion: QWord;
  const ASnapshots: array of IRecorderFrfSampler);
var
  lIndex: Integer;
begin
  inherited Create;
  fVersion := AVersion;
  SetLength(fSnapshots, Length(ASnapshots));
  for lIndex := 0 to High(ASnapshots) do
    fSnapshots[lIndex] := ASnapshots[lIndex];
end;

function TRecorderAggregateFrfSnapshot.TrySample(ACurveId: QWord;
  AFrequencyHz: Double; out AMagnitude, APhaseRadians: Double): Boolean;
var
  lSnapshot: IRecorderFrfSampler;
begin
  for lSnapshot in fSnapshots do
    if lSnapshot.TrySample(ACurveId, AFrequencyHz, AMagnitude,
      APhaseRadians) then
      Exit(True);
  Result := False;
end;

function TRecorderAggregateFrfSnapshot.Version: QWord;
begin
  Result := fVersion;
end;

constructor TRecorderAggregateFrfProvider.Create;
begin
  inherited Create;
  InitCriticalSection(fLock);
  InitCriticalSection(fAcquireLock);
  fMembershipChanged := True;
end;

destructor TRecorderAggregateFrfProvider.Destroy;
begin
  SetLength(fEntries, 0);
  DoneCriticalSection(fAcquireLock);
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderAggregateFrfProvider.FindOwner(AOwner: TObject): Integer;
begin
  for Result := 0 to High(fEntries) do
    if fEntries[Result].Owner = AOwner then
      Exit;
  Result := -1;
end;

procedure TRecorderAggregateFrfProvider.RegisterProvider(AOwner: TObject;
  const AProvider: IRecorderFrfProvider);
var
  lIndex: Integer;
begin
  if AOwner = nil then
    Exit;
  if AProvider = nil then
  begin
    UnregisterProvider(AOwner);
    Exit;
  end;
  EnterCriticalSection(fLock);
  try
    lIndex := FindOwner(AOwner);
    if lIndex < 0 then
    begin
      lIndex := Length(fEntries);
      SetLength(fEntries, lIndex + 1);
      fEntries[lIndex].Owner := AOwner;
    end
    else if fEntries[lIndex].Provider = AProvider then
      Exit;
    fEntries[lIndex].Provider := AProvider;
    fEntries[lIndex].LastVersion := 0;
    Inc(fMembershipVersion);
    fMembershipChanged := True;
  finally
    LeaveCriticalSection(fLock);
  end;
  RebuildSnapshot;
end;

procedure TRecorderAggregateFrfProvider.UnregisterProvider(AOwner: TObject);
var
  lIndex, lMove: Integer;
begin
  if AOwner = nil then
    Exit;
  EnterCriticalSection(fLock);
  try
    lIndex := FindOwner(AOwner);
    if lIndex < 0 then
      Exit;
    { Preserve registration order: if duplicate curve ids exist, the provider
      registered first remains the deterministic lookup winner. }
    for lMove := lIndex to High(fEntries) - 1 do
      fEntries[lMove] := fEntries[lMove + 1];
    SetLength(fEntries, Length(fEntries) - 1);
    Inc(fMembershipVersion);
    fMembershipChanged := True;
  finally
    LeaveCriticalSection(fLock);
  end;
  RebuildSnapshot;
end;

procedure TRecorderAggregateFrfProvider.RebuildSnapshot;
var
  lChanged: Boolean;
  lIndex, lCount: Integer;
  lSnapshot: IRecorderFrfSampler;
  lSnapshots: array of IRecorderFrfSampler;
  lProviders: array of IRecorderFrfProvider;
  lProviderVersions: array of QWord;
  lMembershipVersion: QWord;
  lVersion: QWord;
begin
  lProviders := nil;
  lSnapshots := nil;
  lProviderVersions := nil;
  EnterCriticalSection(fAcquireLock);
  try
    repeat
      EnterCriticalSection(fLock);
      try
        lMembershipVersion := fMembershipVersion;
        SetLength(lProviders, Length(fEntries));
        for lIndex := 0 to High(fEntries) do
          lProviders[lIndex] := fEntries[lIndex].Provider;
      finally
        LeaveCriticalSection(fLock);
      end;

      lCount := 0;
      SetLength(lSnapshots, Length(lProviders));
      SetLength(lProviderVersions, Length(lProviders));
      for lIndex := 0 to High(lProviders) do
      begin
        lSnapshot := lProviders[lIndex].AcquireSnapshot;
        if lSnapshot = nil then
          lProviderVersions[lIndex] := 0
        else
        begin
          lProviderVersions[lIndex] := lSnapshot.Version;
          lSnapshots[lCount] := lSnapshot;
          Inc(lCount);
        end;
      end;

      EnterCriticalSection(fLock);
      try
        if lMembershipVersion <> fMembershipVersion then
          Continue;
        lChanged := fMembershipChanged;
        for lIndex := 0 to High(fEntries) do
          if fEntries[lIndex].LastVersion <> lProviderVersions[lIndex] then
          begin
            fEntries[lIndex].LastVersion := lProviderVersions[lIndex];
            lChanged := True;
          end;
        if lChanged then
          Inc(fVersion);
        fMembershipChanged := False;
        lVersion := fVersion;
        Break;
      finally
        LeaveCriticalSection(fLock);
      end;
    until False;

    SetLength(lSnapshots, lCount);
    if lCount = 0 then
      lSnapshot := nil
    else
      lSnapshot := TRecorderAggregateFrfSnapshot.Create(lVersion, lSnapshots);
    EnterCriticalSection(fLock);
    try
      fCachedSnapshot := lSnapshot;
    finally
      LeaveCriticalSection(fLock);
    end;
  finally
    LeaveCriticalSection(fAcquireLock);
  end;
end;

procedure TRecorderAggregateFrfProvider.ProviderChanged(
  const AProvider: IRecorderFrfProvider);
var
  Index: Integer;
  Found: Boolean;
begin
  Found := False;
  EnterCriticalSection(fLock);
  try
    for Index := 0 to High(fEntries) do
      if fEntries[Index].Provider = AProvider then
      begin
        fMembershipChanged := True;
        Found := True;
        Break;
      end;
    if not Found then
      Exit;
  finally
    LeaveCriticalSection(fLock);
  end;
  RebuildSnapshot;
end;

function TRecorderAggregateFrfProvider.AcquireSnapshot: IRecorderFrfSampler;
begin
  EnterCriticalSection(fLock);
  try
    Result := fCachedSnapshot;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure SetRecorderDefaultFrfProvider(
  const AProvider: IRecorderFrfProvider);
begin
  EnterCriticalSection(GProviderLock);
  try
    GProvider := AProvider;
  finally
    LeaveCriticalSection(GProviderLock);
  end;
end;

function RecorderDefaultFrfProvider: IRecorderFrfProvider;
begin
  EnterCriticalSection(GProviderLock);
  try
    Result := GProvider;
    if Result = nil then
      Result := GAggregateProvider;
  finally
    LeaveCriticalSection(GProviderLock);
  end;
end;

procedure RegisterRecorderFrfProvider(AOwner: TObject;
  const AProvider: IRecorderFrfProvider);
begin
  GAggregate.RegisterProvider(AOwner, AProvider);
end;

procedure UnregisterRecorderFrfProvider(AOwner: TObject);
begin
  GAggregate.UnregisterProvider(AOwner);
end;

procedure NotifyRecorderFrfProviderChanged(
  const AProvider: IRecorderFrfProvider);
begin
  GAggregate.ProviderChanged(AProvider);
end;

function RecorderAggregateFrfProvider: IRecorderFrfProvider;
begin
  Result := GAggregateProvider;
end;

initialization
  InitCriticalSection(GProviderLock);
  GAggregate := TRecorderAggregateFrfProvider.Create;
  GAggregateProvider := GAggregate;

finalization
  GProvider := nil;
  GAggregateProvider := nil;
  GAggregate := nil;
  DoneCriticalSection(GProviderLock);

end.
