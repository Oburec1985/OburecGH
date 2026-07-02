unit uMic140Api;

{
  Публичный API автономного стенда MIC-140 (Tests/Mic140ProtocolDebug).

  Точка входа (Mic140Example.lpr):
    MIC140 := DevMng.Search;
    MIC140.Connect;
    MIC140.Setup(Cfg);
    MIC140.Start;
    { поток: MIC140.OnGetBlock }
    MIC140.Stop;
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs,
  uRecorderDeviceInterfaces, uRecorderMic140DeviceApi;

type
  { Все настраиваемые параметры стенда — в одном месте. }
  TMic140Config = record
    Host: string;
    Port: Word;
    ChannelCount: Integer;
    PollFrequencyHz: Double;
    DataUpdateMs: Cardinal;
    RangeIndex: Integer;       { 0 = 80 mV, для всех AIn }
    CommutIndex: Integer;      { ME048 «Вход», calibr }
    BoardCommutIndex: Integer; { MUX платы, calibr2 }
    TinSlots: Integer;         { 0..3 TIn в BIOS }
    FifoStride: Integer;       { -1=авто, 48 или 51 слов/строка FIFO }
    Bank2DelayMul: Integer;    { множитель decay CH25..48 (0 = по умолчанию) }
    Bank2RangeIndex: Integer;  { -1 = как RangeIndex }
    Bank2CommutIndex: Integer; { -1 = как BoardCommutIndex }
    ChanDumpCount: Integer;    { -1 = 48 AIn в BIOS }
    GroundEnabled: Boolean;
  end;

  TMic140SampleBlockEvent = procedure(Sender: TObject;
    const ABlock: TRecorderDeviceSampleBlock) of object;

  TMic140Device = class
  private
    fCfg: TMic140Config;
    fInner: IMic140Device;
    fAcquire: TThread;
    fStopEv: TEvent;
    fOnBlock: TMic140SampleBlockEvent;
    procedure AcquireLoop;
    procedure ApplyDebugHooks;
    procedure ApplyPerChannelProps;
  public
    constructor Create(const AConfig: TMic140Config);
    destructor Destroy; override;

    procedure Connect;
    procedure Setup(const AConfig: TMic140Config);
    procedure Start;
    procedure Stop;
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderDeviceSampleBlock): Boolean;

    property OnGetBlock: TMic140SampleBlockEvent read fOnBlock write fOnBlock;
    function StreamStopLine: string;
    property Inner: IMic140Device read fInner;
  end;

  TMic140DevMng = class
  public
    function Search(const AHost: string = ''; APort: Word = 0): TMic140Device;
  end;

  TMic140ApiReadThread = class(TThread)
  private
    fOwner: TMic140Device;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TMic140Device);
  end;

function Mic140DefaultConfig: TMic140Config;

implementation

uses
  uRecorderMic140v2Device, uRecorderMic140v2Scan;

function Mic140DefaultConfig: TMic140Config;
begin
  Result.Host := '192.168.14.155';
  Result.Port := 4000;
  Result.ChannelCount := 48;
  Result.PollFrequencyHz := 10;
  Result.DataUpdateMs := 200;
  Result.RangeIndex := 0;
  Result.CommutIndex := 0;
  Result.BoardCommutIndex := 0;
  Result.TinSlots := 3;
  Result.FifoStride := -1;
  Result.Bank2DelayMul := 1;
  Result.Bank2RangeIndex := -1;
  Result.Bank2CommutIndex := -1;
  Result.ChanDumpCount := -1;
  Result.GroundEnabled := False;
end;

constructor TMic140Device.Create(const AConfig: TMic140Config);
begin
  inherited Create;
  fCfg := AConfig;
  fStopEv := TEvent.Create(nil, True, False, '');
  fInner := TRecorderMic140v2Device.Create('MIC140', fCfg.Host, fCfg.Port,
    fCfg.ChannelCount, fCfg.PollFrequencyHz, fCfg.DataUpdateMs);
end;

destructor TMic140Device.Destroy;
begin
  Stop;
  fInner := nil;
  fStopEv.Free;
  inherited Destroy;
end;

procedure TMic140Device.ApplyDebugHooks;
begin
  Mic140v2SetDebugTinSlotCount(fCfg.TinSlots);
  Mic140v2SetDebugFifoStride(fCfg.FifoStride);
  if fCfg.Bank2DelayMul > 0 then
    Mic140v2SetDebugBank2DelayMul(fCfg.Bank2DelayMul)
  else
    Mic140v2SetDebugBank2DelayMul(-1);
  Mic140v2SetDebugChanDumpCount(fCfg.ChanDumpCount);
  Mic140v2SetDebugGroundPointers(fCfg.GroundEnabled);
end;

procedure TMic140Device.ApplyPerChannelProps;
var
  I, lRange, lUserCommut, lBoardCommut: Integer;
begin
  fInner.TrySetDeviceProperty(rdpHost, fCfg.Host, 0);
  fInner.TrySetDeviceProperty(rdpPort, Integer(fCfg.Port), 0);
  fInner.TrySetDeviceProperty(rdpPollFrequencyHz, fCfg.PollFrequencyHz, 0);
  fInner.TrySetDeviceProperty(rdpUpdateTimeMs, Integer(fCfg.DataUpdateMs), 0);
  fInner.TrySetDeviceProperty(rdpChannelCount, fCfg.ChannelCount, 0);
  for I := 0 to fCfg.ChannelCount - 1 do
  begin
    lRange := fCfg.RangeIndex;
    if (I >= 24) and (fCfg.Bank2RangeIndex >= 0) then
      lRange := fCfg.Bank2RangeIndex;
    lUserCommut := fCfg.CommutIndex;
    lBoardCommut := fCfg.BoardCommutIndex;
    if (I >= 24) and (fCfg.Bank2CommutIndex >= 0) then
      lBoardCommut := fCfg.Bank2CommutIndex;
    fInner.TrySetDeviceProperty(rdpMic140RangeIndex, lRange, I);
    fInner.TrySetDeviceProperty(rdpMic140CommutIndex, lUserCommut, I);
    fInner.TrySetDeviceProperty(rdpMic140BoardCommutIndex, lBoardCommut, I);
  end;
end;

procedure TMic140Device.Connect;
begin
  fInner.Connect;
end;

procedure TMic140Device.Setup(const AConfig: TMic140Config);
begin
  fCfg := AConfig;
  ApplyDebugHooks;
  ApplyPerChannelProps;
  fInner.ProgramDevice;
end;

procedure TMic140Device.Start;
begin
  fStopEv.ResetEvent;
  fInner.Start;
  fAcquire := TMic140ApiReadThread.Create(Self);
  fAcquire.FreeOnTerminate := False;
  fAcquire.Start;
end;

function TMic140Device.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
begin
  Result := fInner.ReadBlock(ATimeoutMs, ABlock);
end;

procedure TMic140Device.Stop;
begin
  fStopEv.SetEvent;
  if Assigned(fAcquire) then
  begin
    fAcquire.WaitFor;
    fAcquire.Free;
    fAcquire := nil;
  end;
  if fInner <> nil then
    fInner.Stop;
end;

procedure TMic140Device.AcquireLoop;
var
  lBlock: TRecorderDeviceSampleBlock;
begin
  while fStopEv.WaitFor(fCfg.DataUpdateMs) = wrTimeout do
  begin
    if fInner.ReadBlock(fCfg.DataUpdateMs + 500, lBlock) then
      if Assigned(fOnBlock) then
        fOnBlock(Self, lBlock);
  end;
end;

function TMic140Device.StreamStopLine: string;
begin
  Result := Format(
    'MIC-140 stream stop: published=%d read=%d readGaps=%d corruptRead=%d mdpResync=%d',
    [0, fInner.LegacyStreamReadCount, fInner.LegacyNumBuffGapCount,
     fInner.LegacyCorruptReadCount, fInner.LegacyMdpResyncByteCount]);
end;

function TMic140DevMng.Search(const AHost: string; APort: Word): TMic140Device;
var
  lCfg: TMic140Config;
begin
  lCfg := Mic140DefaultConfig;
  if AHost <> '' then
    lCfg.Host := AHost;
  if APort <> 0 then
    lCfg.Port := APort;
  Result := TMic140Device.Create(lCfg);
end;

constructor TMic140ApiReadThread.Create(AOwner: TMic140Device);
begin
  inherited Create(True);
  fOwner := AOwner;
  FreeOnTerminate := False;
end;

procedure TMic140ApiReadThread.Execute;
begin
  fOwner.AcquireLoop;
end;

end.
