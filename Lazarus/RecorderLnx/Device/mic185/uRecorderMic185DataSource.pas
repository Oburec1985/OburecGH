unit uRecorderMic185DataSource;

{
  MIC183/185 data source for RecorderLnx.

  The protocol/device units in this folder are copies of the standalone
  Tests/mic185 implementation. This adapter binds them to RecorderLnx tags and
  data-source lifecycle.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderDataSources, uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
  uRecorderTags, uMic185Device, uMic185Constants;

const
  MIC185DefaultHost = '192.168.9.142';
  MIC185DefaultPort = 4000;
  MIC185DefaultPollFrequencyHz = CMic185DefaultMeasFrequencyHz;

function RecorderMic185SourceId(const AHost: string; APort: Word): string;
function TryParseRecorderMic185SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
function RecorderMic185ReadDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AErrorText: string; ATimeoutMs: Cardinal = 700): Boolean;

type
  TRecorderMic185DataSource = class(TRecorderDataSourceBase)
  private
    fChannelTagNames: TStringList;
    fDevice: IRecorderDevice;
    fHost: string;
    fPort: Word;
    fPollFrequencyHz: Double;
    fSelectedNames: TStringList;
    function ChannelSelected(const AChannel: TRecorderDeviceChannel): Boolean;
    function FindTagBySourceAddress(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    procedure ConfigureDevice;
    procedure PublishMeasurementBlock(const ABlock: TRecorderAcquisitionBlock);
    procedure PublishAuxChannels(ATimeSec: Double);
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
    procedure PrepareHardware; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
      ASelectedNames: TStrings = nil);
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
    procedure RequestStop; override;
  end;

implementation

uses
  Math, StrUtils, Variants,
  uMic185MebiusTcpProtocol, uMic185MebiusTypes;

const
  CMic185SourcePrefix = 'MIC-185: ';
  CMic185ModuleName = 'MIC183/185';

function RecorderMic185SourceId(const AHost: string; APort: Word): string;
begin
  Result := CMic185SourcePrefix + Trim(AHost) + ':' + IntToStr(APort);
end;

function TryParseRecorderMic185SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
var
  lText: string;
  lPos: Integer;
  lPort: Integer;
begin
  Result := False;
  AHost := '';
  APort := 0;
  if Pos(CMic185SourcePrefix, ASourceId) <> 1 then
    Exit;
  lText := Trim(Copy(ASourceId, Length(CMic185SourcePrefix) + 1, MaxInt));
  lPos := RPos(':', lText);
  if lPos <= 1 then
    Exit;
  if not TryStrToInt(Copy(lText, lPos + 1, MaxInt), lPort) then
    Exit;
  if (lPort < 1) or (lPort > 65535) then
    Exit;
  AHost := Trim(Copy(lText, 1, lPos - 1));
  if AHost = '' then
    Exit;
  APort := Word(lPort);
  Result := True;
end;

function RecorderMic185ReadDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AErrorText: string; ATimeoutMs: Cardinal): Boolean;
var
  lClient: TRecorderMebiusTcpClient;
  lOut: TRecorderByteArray;
  lInfo: TMic185HardDeviceInfo;
begin
  Result := False;
  ASerialNumber := 0;
  AVersionText := '';
  AErrorText := '';
  if Trim(AHost) = '' then
  begin
    AErrorText := 'MIC183/185 host is not set';
    Exit;
  end;

  lClient := TRecorderMebiusTcpClient.Create(AHost, APort, ATimeoutMs);
  try
    try
      lClient.Connect;
      if not lClient.TryCallCommand(CMic185IoCtlCmdGetSoftVersion, nil,
        CMic185HardDeviceInfoSize, lOut, AErrorText) then
        Exit;
      if Length(lOut) < CMic185HardDeviceInfoSize then
      begin
        AErrorText := Format('MIC183/185 info response is too short: %d bytes',
          [Length(lOut)]);
        Exit;
      end;

      Move(lOut[0], lInfo, SizeOf(lInfo));
      ASerialNumber := lInfo.SerialNumber;
      AVersionText := Mic185FormatSoftVersion(lInfo.SoftVersion);
      Result := True;
    except
      on E: Exception do
        AErrorText := E.Message;
    end;
  finally
    lClient.Free;
  end;
end;

constructor TRecorderMic185DataSource.Create(const ASourceId, AHost: string;
  APort: Word; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
  ASelectedNames: TStrings);
begin
  inherited Create(ASourceId, 'MIC183/185 data source', AUpdateTimeMs);
  fHost := AHost;
  fPort := APort;
  fPollFrequencyHz := APollFrequencyHz;
  if fPollFrequencyHz <= 0 then
    fPollFrequencyHz := MIC185DefaultPollFrequencyHz;
  fChannelTagNames := TStringList.Create;
  fChannelTagNames.CaseSensitive := False;
  fSelectedNames := TStringList.Create;
  fSelectedNames.CaseSensitive := False;
  if ASelectedNames <> nil then
    fSelectedNames.Assign(ASelectedNames);
end;

destructor TRecorderMic185DataSource.Destroy;
begin
  Stop;
  fSelectedNames.Free;
  fChannelTagNames.Free;
  inherited Destroy;
end;

function TRecorderMic185DataSource.FindTagBySourceAddress(
  ARegistry: TRecorderTagRegistry; const AAddress: string): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.SourceId, SourceId) and SameText(lTag.Address, AAddress) then
      Exit(lTag);
  end;
end;

function TRecorderMic185DataSource.ChannelSelected(
  const AChannel: TRecorderDeviceChannel): Boolean;
begin
  Result := (fSelectedNames.Count = 0) or
    (fSelectedNames.IndexOf(AChannel.Name) >= 0) or
    (fSelectedNames.IndexOf(AChannel.Address) >= 0);
end;

procedure TRecorderMic185DataSource.ConfigureDevice;
begin
  fDevice := CreateRecorderMic185Device;
  fDevice.TrySetDeviceProperty(rdpHost, fHost);
  fDevice.TrySetDeviceProperty(rdpPort, Integer(fPort));
  fDevice.TrySetDeviceProperty(rdpPollFrequencyHz, fPollFrequencyHz);
  fDevice.TrySetDeviceProperty(rdpUpdateTimeMs, Integer(UpdateTimeMs));
end;

procedure TRecorderMic185DataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lCapacity: Integer;
  lChannels: TRecorderDeviceChannelArray;
  lTag: TRecorderTag;
begin
  if fDevice = nil then
    ConfigureDevice;

  ARegistry.RegisterActiveSource(SourceId);
  fChannelTagNames.Clear;
  lChannels := fDevice.GetChannels;
  for I := 0 to High(lChannels) do
  begin
    if not ChannelSelected(lChannels[I]) then
      Continue;

    lTag := FindTagBySourceAddress(ARegistry, lChannels[I].Address);
    if lTag = nil then
      lTag := ARegistry.FindByName(lChannels[I].Name);
    if lTag = nil then
    begin
      lCapacity := Ceil(Max(4096, lChannels[I].PollFrequencyHz * 4));
      lTag := ARegistry.CreateTag(lChannels[I].Name, lCapacity);
    end;

    lTag.SourceId := SourceId;
    lTag.Address := lChannels[I].Address;
    lTag.ModuleType := CMic185ModuleName;
    lTag.UnitName := lChannels[I].UnitName;
    lTag.PollFrequencyHz := lChannels[I].PollFrequencyHz;
    lTag.RangeMin := -5;
    lTag.RangeMax := 5;
    lTag.AutoRange := False;
    lTag.AutoUnit := False;
    lTag.Description := Format('%s channel %s', [CMic185ModuleName, lChannels[I].Address]);
    lTag.EnsureBufferCapacity(Ceil(Max(4096, lChannels[I].PollFrequencyHz * 4)));
    fChannelTagNames.Add(lTag.Name);
  end;
end;

procedure TRecorderMic185DataSource.PrepareHardware;
begin
  inherited PrepareHardware;
  if fDevice = nil then
    ConfigureDevice;
  fDevice.Connect;
  fDevice.ProgramDevice;
end;

procedure TRecorderMic185DataSource.Start;
begin
  inherited Start;
  if fDevice = nil then
    ConfigureDevice;
  if fDevice.State <> rdsStarted then
    fDevice.Start;
end;

procedure TRecorderMic185DataSource.RequestStop;
begin
  inherited RequestStop;
end;

procedure TRecorderMic185DataSource.Stop;
begin
  if fDevice <> nil then
  begin
    try
      fDevice.Stop;
      fDevice.Disconnect;
    except
      on E: Exception do
        ;
    end;
    fDevice := nil;
  end;
  inherited Stop;
end;

procedure TRecorderMic185DataSource.PublishMeasurementBlock(
  const ABlock: TRecorderAcquisitionBlock);
var
  I, J: Integer;
  lCount: Integer;
  lTag: TRecorderTag;
  lTimes: TRecorderDoubleArray;
  lValues: TRecorderDoubleArray;
begin
  if (Registry = nil) or (ABlock.SampleCount <= 0) or (ABlock.SampleRateHz <= 0) then
    Exit;

  SetLength(lTimes, ABlock.SampleCount);
  SetLength(lValues, ABlock.SampleCount);
  for J := 0 to ABlock.SampleCount - 1 do
    lTimes[J] := ABlock.FirstTimeSec + (J / ABlock.SampleRateHz);

  lCount := Min(ABlock.ChannelCount, fChannelTagNames.Count);
  for I := 0 to lCount - 1 do
  begin
    lTag := Registry.FindByName(fChannelTagNames[I]);
    if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
      Continue;
    for J := 0 to ABlock.SampleCount - 1 do
      lValues[J] := ABlock.Values[I][J];
    Registry.AddBlockSamples(lTag.Name, lTimes, lValues, ABlock.SampleCount, True);
  end;

  for I := 0 to lCount - 1 do
  begin
    lTag := Registry.FindByName(fChannelTagNames[I]);
    if (lTag <> nil) and SameText(lTag.SourceId, SourceId) then
      Registry.PublishBlockNotifications(lTag.Name);
  end;

  PublishAuxChannels(lTimes[ABlock.SampleCount - 1]);
end;

procedure TRecorderMic185DataSource.PublishAuxChannels(ATimeSec: Double);
var
  I: Integer;
  lDevice: TRecorderMic185Device;
  lTag: TRecorderTag;
begin
  if (Registry = nil) or (fDevice = nil) or
    (not (fDevice.GetNativeObject is TRecorderMic185Device)) then
    Exit;
  lDevice := TRecorderMic185Device(fDevice.GetNativeObject);

  if lDevice.HasTempData then
    for I := 0 to lDevice.TempChannelCount - 1 do
    begin
      lTag := FindTagBySourceAddress(Registry,
        Format('MIC183_185-{%d-t%d}', [3, I + 1]));
      if lTag <> nil then
        Registry.PublishValue(lTag.Name, ATimeSec, lDevice.LastTempValue(I));
    end;

  if lDevice.HasUtsData then
  begin
    lTag := FindTagBySourceAddress(Registry, Format('MIC183_185-{%d-uts}', [3]));
    if lTag <> nil then
      Registry.PublishValue(lTag.Name, ATimeSec, lDevice.LastUts);
  end;
end;

procedure TRecorderMic185DataSource.DoTick;
var
  lBlock: TRecorderAcquisitionBlock;
  lTimeout: Cardinal;
begin
  if fDevice = nil then
    Exit;
  if fDevice.State <> rdsStarted then
    fDevice.Start;

  lTimeout := Max(Cardinal(1000), UpdateTimeMs * 4);
  if fDevice.ReadBlock(lTimeout, lBlock) then
    PublishMeasurementBlock(lBlock);
end;

end.
