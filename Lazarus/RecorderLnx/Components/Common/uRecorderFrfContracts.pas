unit uRecorderFrfContracts;

{ Общие контракты чтения FRF для расчётов, отображения и 3D-компонентов.
  Реализация владеет данными, потребитель получает неизменяемый снимок. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  { Максимум в настроенном диапазоне частот, не зависящий от курсора. Кэш
    учитывает версию снимка и параметры диапазона. }
  IRecorderFrfRangeScale = interface
    ['{38035904-B997-4DCE-AE63-1864E4A83B78}']
    function TryGetRangeMaximum(ACurveId: QWord; AMinHz, AMaxHz: Double;
      AAmplitude, ABand: Boolean; ATolerancePercent: Double;
      out AMaximum: Double): Boolean;
  end;

  { Спектральные отсчёты уже выражены в RMS. Амплитуда полосы — корень суммы
    квадратов без деления на число бинов; фаза берётся в центре полосы. False
    означает, что источник или требуемые бины недоступны. }
  IRecorderFrfBandSampler = interface
    ['{A5E77E7B-7D64-4CF6-9E83-B3C2C99B4F22}']
    function TrySampleBand(ACurveId: QWord; ACenterHz,
      ATolerancePercent: Double; AAmplitude: Boolean;
      out AMagnitude, APhaseRadians: Double): Boolean;
  end;

  IRecorderAmplitudeSampler = interface
    ['{B205F4C3-2AF7-45C9-8395-08C9F53F5B38}']
    function TrySampleAmplitude(ACurveId: QWord; AFrequencyHz: Double;
      out AMagnitude, APhaseRadians: Double): Boolean;
  end;

  IRecorderFrfSampler = interface
    ['{B491A68B-C7E3-4B03-B598-F7D88C4129C6}']
    function TrySample(ACurveId: QWord; AFrequencyHz: Double;
      out AMagnitude, APhaseRadians: Double): Boolean;
    function Version: QWord;
  end;

  { Потокобезопасный поставщик возвращает удерживаемый неизменяемый снимок.
    Потребитель хранит интерфейс на всё время чтения. }
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
function RecorderSelectedFrfFrequency: Double;
procedure SetRecorderSelectedFrfFrequency(AFrequencyHz: Double);
procedure SetRecorderFrfDisplayRange(AMinHz, AMaxHz: Double);
function GetRecorderFrfDisplayRange(out AMinHz, AMaxHz: Double): Boolean;

implementation

uses Math;

type
  TRecorderFrfProviderEntry = record
    Owner: TObject;
    Provider: IRecorderFrfProvider;
    LastVersion: QWord;
  end;

  { Удерживаемый агрегированный снимок задаёт атомарный состав реестра; снимки
    дочерних поставщиков не меняются во время чтения. }
  TRecorderAggregateFrfSnapshot = class(TInterfacedObject,
    IRecorderFrfSampler, IRecorderAmplitudeSampler, IRecorderFrfBandSampler,
    IRecorderFrfRangeScale)
  private
    fVersion: QWord;
    fSnapshots: array of IRecorderFrfSampler;
  public
    constructor Create(AVersion: QWord;
      const ASnapshots: array of IRecorderFrfSampler);
    function TrySample(ACurveId: QWord; AFrequencyHz: Double;
      out AMagnitude, APhaseRadians: Double): Boolean;
    function Version: QWord;
    function TryGetRangeMaximum(ACurveId: QWord; AMinHz, AMaxHz: Double;
      AAmplitude, ABand: Boolean; ATolerancePercent: Double;
      out AMaximum: Double): Boolean;
    function TrySampleAmplitude(ACurveId: QWord; AFrequencyHz: Double;
      out AMagnitude, APhaseRadians: Double): Boolean;
    function TrySampleBand(ACurveId: QWord; ACenterHz,
      ATolerancePercent: Double; AAmplitude: Boolean;
      out AMagnitude, APhaseRadians: Double): Boolean;
  end;

  { Запись реестра определяется компонентом-владельцем. Замена или удаление
    одного владельца не затрагивает поставщиков остальных компонентов. }
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
  GSelectedFrequency: Double = 1;
  GDisplayMinHz, GDisplayMaxHz: Double;
  GDisplayRangeSet: Boolean = False;
  GAggregate: TRecorderAggregateFrfProvider;
  GAggregateProvider: IRecorderFrfProvider;

{ Создаёт неизменяемый снимок-агрегат с версией и удерживает снимки всех поставщиков. }
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

{ Ищет максимум кривой в диапазоне через поставщиков, поддерживающих запрос диапазона. }
function TRecorderAggregateFrfSnapshot.TryGetRangeMaximum(ACurveId: QWord;
  AMinHz, AMaxHz: Double; AAmplitude, ABand: Boolean;
  ATolerancePercent: Double; out AMaximum: Double): Boolean;
var lSnapshot: IRecorderFrfSampler; lScale: IRecorderFrfRangeScale;
begin
  AMaximum:=0;
  for lSnapshot in fSnapshots do
    if lSnapshot.QueryInterface(IRecorderFrfRangeScale,lScale)=0 then
      if lScale.TryGetRangeMaximum(ACurveId,AMinHz,AMaxHz,AAmplitude,
        ABand,ATolerancePercent,AMaximum) then Exit(True);
  Result:=False;
end;

{ Сохраняет конечный диапазон отображения при 0 ≤ AMinHz < AMaxHz. }
procedure SetRecorderFrfDisplayRange(AMinHz, AMaxHz: Double);
begin
  if IsNan(AMinHz) or IsNan(AMaxHz) or IsInfinite(AMinHz) or
    IsInfinite(AMaxHz) or (AMinHz<0) or (AMaxHz<=AMinHz) then Exit;
  EnterCriticalSection(GProviderLock);
  try
    GDisplayMinHz:=AMinHz;
    GDisplayMaxHz:=AMaxHz;
    GDisplayRangeSet:=True;
  finally LeaveCriticalSection(GProviderLock); end;
end;

{ Возвращает сохранённые границы диапазона и признак, что они были заданы. }
function GetRecorderFrfDisplayRange(out AMinHz, AMaxHz: Double): Boolean;
begin
  EnterCriticalSection(GProviderLock);
  try
    AMinHz:=GDisplayMinHz;
    AMaxHz:=GDisplayMaxHz;
    Result:=GDisplayRangeSet;
  finally LeaveCriticalSection(GProviderLock); end;
end;

{ Ищет значение кривой в полосе через снимки, поддерживающие полосовой запрос. }
function TRecorderAggregateFrfSnapshot.TrySampleBand(ACurveId: QWord;
  ACenterHz, ATolerancePercent: Double; AAmplitude: Boolean;
  out AMagnitude, APhaseRadians: Double): Boolean;
var
  lSnapshot: IRecorderFrfSampler;
  lBand: IRecorderFrfBandSampler;
begin
  for lSnapshot in fSnapshots do
    if lSnapshot.QueryInterface(IRecorderFrfBandSampler, lBand) = 0 then
      if lBand.TrySampleBand(ACurveId, ACenterHz, ATolerancePercent,
        AAmplitude, AMagnitude, APhaseRadians) then Exit(True);
  Result := False;
end;

{ Ищет амплитуду и фазу на частоте через снимки с поддержкой амплитудного запроса. }
function TRecorderAggregateFrfSnapshot.TrySampleAmplitude(ACurveId: QWord;
  AFrequencyHz: Double; out AMagnitude, APhaseRadians: Double): Boolean;
var
  Snapshot: IRecorderFrfSampler;
  Amplitude: IRecorderAmplitudeSampler;
begin
  for Snapshot in fSnapshots do
    if Snapshot.QueryInterface(IRecorderAmplitudeSampler, Amplitude) = 0 then
      if Amplitude.TrySampleAmplitude(ACurveId, AFrequencyHz,
        AMagnitude, APhaseRadians) then Exit(True);
  Result := False;
end;

{ Возвращает выбранную частоту под общей блокировкой. }
function RecorderSelectedFrfFrequency: Double;
begin
  EnterCriticalSection(GProviderLock);
  try Result := GSelectedFrequency;
  finally LeaveCriticalSection(GProviderLock); end;
end;

{ Сохраняет неотрицательную выбранную частоту под общей блокировкой. }
procedure SetRecorderSelectedFrfFrequency(AFrequencyHz: Double);
begin
  if AFrequencyHz < 0 then Exit;
  EnterCriticalSection(GProviderLock);
  try GSelectedFrequency := AFrequencyHz;
  finally LeaveCriticalSection(GProviderLock); end;
end;

{ Ищет значение кривой на частоте по снимкам поставщиков в порядке регистрации. }
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

{ Возвращает версию, зафиксированную при создании снимка. }
function TRecorderAggregateFrfSnapshot.Version: QWord;
begin
  Result := fVersion;
end;

{ Создаёт реестр поставщиков и блокировки; начальный снимок помечен устаревшим. }
constructor TRecorderAggregateFrfProvider.Create;
begin
  inherited Create;
  InitCriticalSection(fLock);
  InitCriticalSection(fAcquireLock);
  fMembershipChanged := True;
end;

{ Очищает записи поставщиков и освобождает блокировки агрегатора. }
destructor TRecorderAggregateFrfProvider.Destroy;
begin
  SetLength(fEntries, 0);
  DoneCriticalSection(fAcquireLock);
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

{ Находит индекс записи владельца; -1 означает отсутствие регистрации. }
function TRecorderAggregateFrfProvider.FindOwner(AOwner: TObject): Integer;
begin
  for Result := 0 to High(fEntries) do
    if fEntries[Result].Owner = AOwner then
      Exit;
  Result := -1;
end;

{ Добавляет или обновляет поставщика владельца; nil удаляет регистрацию, затем пересобирается снимок. }
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

{ Удаляет поставщика владельца и публикует агрегат без него. }
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
     { При совпадении ID кривой выигрывает поставщик, зарегистрированный первым. }
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

{ Согласует версии поставщиков и публикует единый неизменяемый снимок; повторяет сбор при изменении состава. }
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

{ Помечает зарегистрированный поставщик изменённым и обновляет опубликованный снимок. }
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

{ Возвращает текущий кэшированный снимок под блокировкой. }
function TRecorderAggregateFrfProvider.AcquireSnapshot: IRecorderFrfSampler;
begin
  EnterCriticalSection(fLock);
  try
    Result := fCachedSnapshot;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ Устанавливает явный глобальный FRF-поставщик; nil разрешает использовать агрегатный. }
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

{ Возвращает явного поставщика, а при его отсутствии — агрегатный. }
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

{ Регистрирует владельца и его FRF-поставщика в общем агрегаторе. }
procedure RegisterRecorderFrfProvider(AOwner: TObject;
  const AProvider: IRecorderFrfProvider);
begin
  GAggregate.RegisterProvider(AOwner, AProvider);
end;

{ Удаляет владельца и его FRF-поставщика из общего агрегатора. }
procedure UnregisterRecorderFrfProvider(AOwner: TObject);
begin
  GAggregate.UnregisterProvider(AOwner);
end;

{ Сообщает агрегатору об изменении поставщика для публикации нового снимка. }
procedure NotifyRecorderFrfProviderChanged(
  const AProvider: IRecorderFrfProvider);
begin
  GAggregate.ProviderChanged(AProvider);
end;

{ Возвращает общий агрегатный интерфейс поставщика FRF. }
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
