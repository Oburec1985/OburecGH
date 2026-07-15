unit uRecorderMcbusDataSource;

{
  Runtime bridge between the MC-032/MC-201 TRecorderDevice adapter and the
  Recorder data-source manager. Network I/O runs only in the source worker.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Variants,
  uRecorderDataSources, uRecorderTags, uRecorderDeviceInterfaces,
  uRecorderAcquisitionTypes;

type
  TRecorderMcbusDataSource = class(TRecorderDataSourceBase)
  private
    fDevice: IRecorderDevice;
    fHost: string;
    fPort: Word;
    fPollFrequencyHz: Double;
    fTagNames: TStringList;
    fChannelTags: array of TRecorderTag;
    fEmptyReadCount: Cardinal;
    procedure BuildChannelMap;
    procedure PublishBlock(const ABlock: TRecorderAcquisitionBlock);
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      APollFrequencyHz: Double; AUpdateTimeMs: Cardinal; ATagNames: TStrings);
    destructor Destroy; override;
    procedure PrepareHardware; override;
    procedure Start; override;
    procedure Stop; override;
  end;

implementation

uses
  uRecorderMcbusDevice, uRecorderDebugLog, uRecorderHardwareLiveDevices;

function AddressSlotChannel(const AAddress: string; out ASlot,
  AChannel: Integer): Boolean;
var
  lParts: TStringList;
begin
  Result := False;
  ASlot := 0;
  AChannel := 0;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := '-';
    lParts.DelimitedText := Trim(AAddress);
    if lParts.Count < 2 then Exit;
    Result := TryStrToInt(lParts[lParts.Count - 2], ASlot) and
      TryStrToInt(lParts[lParts.Count - 1], AChannel);
  finally
    lParts.Free;
  end;
end;

constructor TRecorderMcbusDataSource.Create(const ASourceId, AHost: string;
  APort: Word; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
  ATagNames: TStrings);
begin
  inherited Create(ASourceId, 'MC-032 / MC-201', AUpdateTimeMs);
  fHost := AHost;
  fPort := APort;
  fPollFrequencyHz := APollFrequencyHz;
  fTagNames := TStringList.Create;
  fTagNames.CaseSensitive := False;
  if ATagNames <> nil then fTagNames.Assign(ATagNames);
  fDevice := CreateRecorderMcbusDevice;
end;

destructor TRecorderMcbusDataSource.Destroy;
begin
  RecorderHardwareUnregisterLiveDevice(Self);
  fDevice := nil;
  fTagNames.Free;
  inherited Destroy;
end;

procedure TRecorderMcbusDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
begin
  { Tags are selected and created by the settings dialog. The runtime source
    only binds them to device channel indices after hardware programming. }
end;

procedure TRecorderMcbusDataSource.PrepareHardware;
begin
  inherited PrepareHardware;
  fDevice.TrySetDeviceProperty(rdpHost, fHost);
  fDevice.TrySetDeviceProperty(rdpPort, Integer(fPort));
  fDevice.TrySetDeviceProperty(rdpPollFrequencyHz, fPollFrequencyHz);
  fDevice.TrySetDeviceProperty(rdpUpdateTimeMs, Integer(UpdateTimeMs));
  RecorderDebugLog(Format('[MCBUS] connect %s:%d fs=%.0f tags=%d',
    [fHost, fPort, fPollFrequencyHz, fTagNames.Count]));
  fDevice.Connect;
  fDevice.ProgramDevice;
  BuildChannelMap;
  RecorderHardwareRegisterLiveDevice(Self, SourceId, fDevice);
end;

procedure TRecorderMcbusDataSource.BuildChannelMap;
var
  I, J, lChannel, lSlot, lTagChannel, lTagSlot: Integer;
  lChannels: TRecorderDeviceChannelArray;
  lTag: TRecorderTag;
begin
  lChannels := fDevice.GetChannels;
  SetLength(fChannelTags, Length(lChannels));
  for I := 0 to High(lChannels) do
  begin
    fChannelTags[I] := nil;
    if not AddressSlotChannel(lChannels[I].Address, lSlot, lChannel) then Continue;
    for J := 0 to Registry.TagCount - 1 do
    begin
      lTag := Registry.Tags[J];
      if not SameText(lTag.SourceId, SourceId) then Continue;
      if not AddressSlotChannel(lTag.Address, lTagSlot, lTagChannel) then Continue;
      if (lTagSlot = lSlot) and (lTagChannel = lChannel) then
      begin
        fChannelTags[I] := lTag;
        Break;
      end;
    end;
  end;
  RecorderDebugLog(Format('[MCBUS] programmed channels=%d', [Length(lChannels)]));
end;

procedure TRecorderMcbusDataSource.Start;
begin
  fDevice.Start;
  fEmptyReadCount := 0;
  inherited Start;
  RecorderDebugLog('[MCBUS] scan started');
end;

procedure TRecorderMcbusDataSource.Stop;
var
  lStopError: string;
begin
  if fDevice <> nil then
  begin
    try
      fDevice.Stop;
      if fDevice.State = rdsDisconnected then
      begin
        lStopError := VarToStr(fDevice.GetDeviceProperty(rdpErrorText));
        RecorderDebugLog('[MCBUS] stop forced disconnect: ' + lStopError);
      end;
    except on E: Exception do
      RecorderDebugLog('[MCBUS] stop error: ' + E.Message); end;
    try fDevice.Disconnect; except end;
  end;
  RecorderHardwareUnregisterLiveDevice(Self);
  RecorderDebugLog('[MCBUS] stopped');
  inherited Stop;
end;

procedure TRecorderMcbusDataSource.PublishBlock(
  const ABlock: TRecorderAcquisitionBlock);
var
  I, J: Integer;
  lTimes: array of Double;
begin
  if (ABlock.SampleCount <= 0) or (ABlock.SampleRateHz <= 0) then Exit;
  SetLength(lTimes, ABlock.SampleCount);
  for J := 0 to ABlock.SampleCount - 1 do
    lTimes[J] := ABlock.FirstTimeSec + J / ABlock.SampleRateHz;
  for I := 0 to Min(High(fChannelTags), High(ABlock.Values)) do
    if (fChannelTags[I] <> nil) and
      (Length(ABlock.Values[I]) >= ABlock.SampleCount) then
    begin
      Registry.PublishBlock(fChannelTags[I].Name, lTimes, ABlock.Values[I],
        ABlock.SampleCount, True);
    end;
end;

procedure TRecorderMcbusDataSource.DoTick;
var
  lBlock: TRecorderAcquisitionBlock;
begin
  if fDevice.State <> rdsStarted then fDevice.Start;
  if fDevice.ReadBlock(Max(Cardinal(1000), UpdateTimeMs * 4), lBlock) then
  begin
    fEmptyReadCount := 0;
    RecorderDebugLog(Format('[MCBUS] block channels=%d samples=%d',
      [lBlock.ChannelCount, lBlock.SampleCount]));
    PublishBlock(lBlock);
  end
  else
  begin
    Inc(fEmptyReadCount);
    if (fEmptyReadCount = 1) or ((fEmptyReadCount mod 20) = 0) then
      RecorderDebugLog(Format('[MCBUS] no complete block reads=%d state=%d',
        [fEmptyReadCount, Ord(fDevice.State)]));
  end;
end;

end.
