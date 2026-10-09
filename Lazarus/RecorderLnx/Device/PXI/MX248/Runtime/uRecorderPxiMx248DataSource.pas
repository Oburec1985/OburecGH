unit uRecorderPxiMx248DataSource;

{
  RecorderLnx datasource for one production MX-248 adapter. ConfigureTags
  creates or reuses exactly eight stable tags. PrepareHardware owns the
  Connect -> Initialize -> Configure path; Start/Stop only control acquisition.

  DoTick reads and publishes complete blocks. Tag references and the time array
  are prepared before Start; the hot path performs no string lookup or resize.
  The device and transport remain connected across ordinary Start/Stop cycles.
  See Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Math, uRecorderDataSources, uRecorderTags,
  uRecorderDeviceInterfaces, uRecorderAcquisitionTypes;

type
  TRecorderPxiMx248DataSource = class(TRecorderDataSourceBase)
  private
    fDevice: IRecorderDevice;
    fEnabled: array[0..7] of Boolean;
    fTags: array[0..7] of TRecorderTag;
    fTimes: array of Double;
    function FindChannelTag(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    procedure PublishBlock(const ABlock: TRecorderAcquisitionBlock);
    function TagName(AChannel: Integer): string;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId: string; const ADevice: IRecorderDevice;
      AUpdateTimeMs: Cardinal);
    destructor Destroy; override;
    procedure PrepareHardware; override;
    procedure Start; override;
    procedure Stop; override;
  end;

implementation

constructor TRecorderPxiMx248DataSource.Create(const ASourceId: string;
  const ADevice: IRecorderDevice; AUpdateTimeMs: Cardinal);
begin
  if ADevice = nil then
    raise EArgumentNilException.Create('MX-248 device is required');
  inherited Create(ASourceId, 'PXI MX-248', AUpdateTimeMs);
  fDevice := ADevice;
end;

destructor TRecorderPxiMx248DataSource.Destroy;
begin
  if fDevice <> nil then fDevice.Disconnect;
  fDevice := nil;
  inherited Destroy;
end;

function TRecorderPxiMx248DataSource.TagName(AChannel: Integer): string;
begin
  Result := Format('%s AIn%d', [SourceId, AChannel + 1]);
end;

function TRecorderPxiMx248DataSource.FindChannelTag(
  ARegistry: TRecorderTagRegistry; const AAddress: string): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
      RecorderNormalizeTagSourceId(SourceId)) and
      SameText(Trim(lTag.Address), Trim(AAddress)) then
      Exit(lTag);
  end;
end;

procedure TRecorderPxiMx248DataSource.DoCreateTags(
  ARegistry: TRecorderTagRegistry);
var
  I, lCapacity: Integer;
  lChannels: TRecorderDeviceChannelArray;
begin
  lChannels := fDevice.GetChannels;
  if Length(lChannels) <> Length(fTags) then
    raise ERecorderDataSourceError.Create('MX-248 must expose eight channels');
  lCapacity := Max(4096, Ceil(lChannels[0].PollFrequencyHz * 4));
  for I := 0 to High(fTags) do
  begin
    fTags[I] := FindChannelTag(ARegistry, lChannels[I].Address);
    if fTags[I] = nil then fTags[I] := ARegistry.CreateTag(TagName(I), lCapacity);
    fTags[I].SourceId := SourceId;
    fTags[I].Address := lChannels[I].Address;
    fTags[I].UnitName := lChannels[I].UnitName;
    fTags[I].PollFrequencyHz := lChannels[I].PollFrequencyHz;
    fEnabled[I] := lChannels[I].Enabled;
  end;
end;

procedure TRecorderPxiMx248DataSource.PrepareHardware;
var
  lBlockSamples: Integer;
  lText: string;
begin
  inherited PrepareHardware;
  if fDevice.State = rdsProgrammed then Exit;
  fDevice.Connect;
  fDevice.InitializeDevice;
  fDevice.ConfigureDevice;
  lText := fDevice.GetProp('block-samples');
  if not TryStrToInt(Copy(lText, Pos('=', lText) + 1, MaxInt), lBlockSamples) then
    lBlockSamples := Max(1, Round(UpdateTimeMs *
      Double(fDevice.GetDeviceProperty(rdpPollFrequencyHz)) / 1000.0));
  SetLength(fTimes, lBlockSamples);
end;

procedure TRecorderPxiMx248DataSource.Start;
begin
  inherited Start;
  if fDevice.State <> rdsProgrammed then
    raise ERecorderDataSourceError.Create('MX-248 hardware is not prepared');
  fDevice.Start;
end;

procedure TRecorderPxiMx248DataSource.Stop;
begin
  if (fDevice <> nil) and (fDevice.State = rdsStarted) then fDevice.Stop;
  inherited Stop;
end;

procedure TRecorderPxiMx248DataSource.PublishBlock(
  const ABlock: TRecorderAcquisitionBlock);
var
  I, J, lCount: Integer;
  lFirstTime, lRate: Double;
begin
  for I := 0 to High(fTags) do
    if (fTags[I] <> nil) and fEnabled[I] and (I <= High(ABlock.Values)) then
    begin
      lCount := RecorderBlockChannelSampleCount(ABlock, I);
      lRate := RecorderBlockChannelSampleRate(ABlock, I);
      lFirstTime := RecorderBlockChannelFirstTime(ABlock, I);
      if (lCount <= 0) or (lRate <= 0) or
        (lCount > Length(fTimes)) or (lCount > Length(ABlock.Values[I])) then
        raise ERecorderDataSourceError.Create('MX-248 block exceeds prepared buffers');
      for J := 0 to lCount - 1 do fTimes[J] := lFirstTime + J / lRate;
      Registry.PublishBlock(fTags[I], fTimes, ABlock.Values[I], lCount, False);
    end;
end;

procedure TRecorderPxiMx248DataSource.DoTick;
var
  lBlock: TRecorderAcquisitionBlock;
begin
  if fDevice.State <> rdsStarted then Exit;
  if fDevice.ReadBlock(Max(Cardinal(1000), UpdateTimeMs * 4), lBlock) then
    PublishBlock(lBlock);
end;

end.
