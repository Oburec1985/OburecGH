unit uOscDataAdapter;

{ Привязка тега осциллографа и повторно используемые снимки истории.
  Через ABI передаётся только плоская таблица сервисов SDK. Подготовка может
  выделять память, Refresh не увеличивает буферы; работа в потоке интерфейса.
  Указатели снимка действительны до следующего успешного Refresh или Prepare. }
{$mode objfpc}{$H+}{$codepage UTF8}

interface

uses SysUtils, Math, uRecorderVisualComponentApiV2, uSharedStatistics,
  uPluginTagServices;

type
  { Переходные имена для существующего кода осциллографа. }
  TOscTagMeta = TPluginTagMeta;
  TOscTagCatalog = TPluginTagCatalog;
  TOscHistoryStatus = (ohReady, ohEmpty, ohMissing, ohCapacityRequired,
    ohUnavailable, ohError);
  TOscHistorySnapshot = record
    Times, Values: PDouble;
    Count: LongWord;
    Revision: QWord;
    WindowStartSec, LatestTimeSec: Double;
  end;
  TOscDoubleBuf = array of Double;

  TOscTagBinding = class
  private
    fServices: PRecorderVisualHostServicesV2;
    fMeta: TOscTagMeta;
    fTimes, fValues: array[0..1] of TOscDoubleBuf;
    fActive: Integer;
    fCapacity, fRequiredCapacity: LongWord;
    fSnapshot: TOscHistorySnapshot;
    fStatus: TOscHistoryStatus;
    fStatisticsCached, fStatisticsValid: Boolean;
    fSummary: TStatisticsSummary;
    fRms: Double;
  public
    constructor Create(AServices: PRecorderVisualHostServicesV2;
      const AMeta: TOscTagMeta);
    procedure Prepare(ACapacity: LongWord);
    function Refresh(AWindowSeconds: Double): TOscHistoryStatus;
    function TryLatest(out AValue: Double): Boolean;
    function TryStatistics(out ASummary: TStatisticsSummary;
      out ARms: Double): Boolean;
    property Meta: TOscTagMeta read fMeta;
    property Snapshot: TOscHistorySnapshot read fSnapshot;
    property Status: TOscHistoryStatus read fStatus;
    property RequiredCapacity: LongWord read fRequiredCapacity;
  end;

function OscServicesAvailable(AServices: PRecorderVisualHostServicesV2): Boolean;
function LoadOscTagCatalog(AServices: PRecorderVisualHostServicesV2;
  out ACatalog: TOscTagCatalog): LongInt;
function ResolveOscTag(AServices: PRecorderVisualHostServicesV2;
  const ACatalog: TOscTagCatalog; ATagId: QWord): TOscTagBinding;

implementation

function OscServicesAvailable(AServices: PRecorderVisualHostServicesV2): Boolean;
begin
  Result := PluginTagServicesAvailable(AServices);
end;

function LoadOscTagCatalog(AServices: PRecorderVisualHostServicesV2;
  out ACatalog: TOscTagCatalog): LongInt;
begin
  Result := LoadPluginTagCatalog(AServices, ACatalog);
end;

function ResolveOscTag(AServices: PRecorderVisualHostServicesV2;
  const ACatalog: TOscTagCatalog; ATagId: QWord): TOscTagBinding;
var lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to High(ACatalog) do
    if ACatalog[lIndex].Id = ATagId then
      Exit(TOscTagBinding.Create(AServices, ACatalog[lIndex]));
end;

constructor TOscTagBinding.Create(AServices: PRecorderVisualHostServicesV2;
  const AMeta: TOscTagMeta);
begin
  inherited Create; fServices := AServices; fMeta := AMeta;
  fStatus := ohEmpty;
end;

procedure TOscTagBinding.Prepare(ACapacity: LongWord);
var lIndex: Integer;
begin
  if ACapacity > LongWord(High(Integer)) then
    raise ERangeError.Create('Oscillogram history capacity exceeds index limit');
  for lIndex := 0 to 1 do begin
    SetLength(fTimes[lIndex], ACapacity); SetLength(fValues[lIndex], ACapacity);
  end;
  fCapacity := ACapacity; fRequiredCapacity := 0;
  fSnapshot := Default(TOscHistorySnapshot); fStatus := ohEmpty;
  fStatisticsCached := False;
end;

function TOscTagBinding.Refresh(AWindowSeconds: Double): TOscHistoryStatus;
var lNext: Integer; lCandidate: TOscHistorySnapshot; lResult: LongInt;
begin
  if not OscServicesAvailable(fServices) then begin
    fStatus := ohUnavailable; Exit(fStatus);
  end;
  if IsNan(AWindowSeconds) or IsInfinite(AWindowSeconds) or
    (AWindowSeconds < 0) then begin fStatus := ohError; Exit(fStatus); end;
  lNext := 1 - fActive; lCandidate := Default(TOscHistorySnapshot);
  if fCapacity > 0 then begin
    lCandidate.Times := @fTimes[lNext][0];
    lCandidate.Values := @fValues[lNext][0];
  end;
  lResult := fServices^.CopyLatestHistory(fServices^.Context, fMeta.Id,
    AWindowSeconds, lCandidate.Times, lCandidate.Values, fCapacity,
    lCandidate.Count, lCandidate.Revision, lCandidate.WindowStartSec,
    lCandidate.LatestTimeSec);
  case lResult of
    REC_VISUAL_OK: begin
      if lCandidate.Count > fCapacity then begin fStatus := ohError; Exit(fStatus); end;
      if (lCandidate.Revision <> fSnapshot.Revision) or
        (lCandidate.Count <> fSnapshot.Count) or
        (lCandidate.WindowStartSec <> fSnapshot.WindowStartSec) then
        fStatisticsCached := False;
      fActive := lNext; fSnapshot := lCandidate; fRequiredCapacity := 0;
      if lCandidate.Count = 0 then fStatus := ohEmpty else fStatus := ohReady;
    end;
    REC_VISUAL_BUFFER_TOO_SMALL: begin
      fRequiredCapacity := lCandidate.Count; fStatus := ohCapacityRequired;
    end;
    REC_VISUAL_NOT_FOUND: begin
      fSnapshot := Default(TOscHistorySnapshot); fStatus := ohMissing;
      fStatisticsCached := False;
    end;
    REC_VISUAL_NOT_HANDLED: fStatus := ohUnavailable;
    else fStatus := ohError;
  end;
  Result := fStatus;
end;

function TOscTagBinding.TryLatest(out AValue: Double): Boolean;
begin
  AValue := 0;
  Result := (fSnapshot.Count > 0) and (fSnapshot.Values <> nil);
  if Result then begin
    AValue := fSnapshot.Values[fSnapshot.Count - 1];
    Result := not IsNan(AValue) and not IsInfinite(AValue);
  end;
end;

function TOscTagBinding.TryStatistics(out ASummary: TStatisticsSummary;
  out ARms: Double): Boolean;
begin
  ARms := 0; ASummary := Default(TStatisticsSummary);
  Result := (fSnapshot.Count > 0) and (fSnapshot.Values <> nil);
  if not Result then Exit;
  if not fStatisticsCached then begin
    fStatisticsValid := TrySummary(
      Slice(fValues[fActive], Integer(fSnapshot.Count)), fSummary);
    fRms := 0;
    if fStatisticsValid then
      fRms := Hypot(fSummary.Mean, Sqrt(fSummary.PopulationVariance));
    fStatisticsCached := True;
  end;
  Result := fStatisticsValid;
  if Result then begin ASummary := fSummary; ARms := fRms; end;
end;

end.
