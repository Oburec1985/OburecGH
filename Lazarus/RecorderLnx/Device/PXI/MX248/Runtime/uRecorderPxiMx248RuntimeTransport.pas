unit uRecorderPxiMx248RuntimeTransport;

{
  Runtime-only extension of the MX-248 control transport. The x86 bridge-side
  implementation fills the caller-owned, preallocated acquisition block.
  Core remains platform-neutral and does not depend on this streaming contract.

  ReadBlock must not resize arrays after Start. A timeout is a normal result
  (rocTimeout), while malformed channel/sample counts are protocol errors.
  See Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderAcquisitionTypes, uRecorderDriverContractsV2,
  uRecorderPxiMx248Device;

type
  IPxiMx248BlockTransport = interface(IPxiMx248Transport)
    ['{45AEB630-08D1-4B70-B144-89521D7D68C7}']
    function ReadBlock(ATimeoutMs: Cardinal;
      var ABlock: TRcAcquisitionBlock): TRcOperationResult;
  end;

  { Slow control-plane operations. Call only from a worker/UI service while
    acquisition is stopped; never from the acquisition callback. }
  IPxiMx248MaintenanceTransport = interface
    ['{FC95C536-16C4-4F23-8EEB-D2114839197D}']
    function ReadLiveProperties(out AProperties: string):
      TRcOperationResult;
    function ZeroBalance(AChannelMask: Cardinal; out AValues: string):
      TRcOperationResult;
    function ConfigurePxi(ARtsiSev, ARtsiClock, ARtsiSync, ATriggerMode,
      ATriggerSource, ATriggerLevel: Integer): TRcOperationResult;
  end;

  IPxiMx248MaintenanceDevice = interface
    ['{07106D1C-36ED-40C2-A6B2-E8A41054FE76}']
    function ZeroBalance(AChannelMask: Cardinal; out AValues: string):
      TRcOperationResult;
  end;

  { UI-neutral access to the already-owned runtime session. Implemented by the
    datasource so settings never open a second bridge for the same board. }
  IPxiMx248RuntimeSettings = interface
    ['{22CA29F4-373A-4983-8730-0B0C87D7E222}']
    function RuntimeReadLiveProperties(out AProperties: string):
      TRcOperationResult;
    function RuntimeApplyLive(const AProperties: string; ARtsiClock,
      ARtsiSync, ATriggerMode, ATriggerSource, ATriggerLevel: Integer;
      out AReadback: string): TRcOperationResult;
    function RuntimeZeroBalance(AChannelMask: Cardinal; out AValues: string):
      TRcOperationResult;
  end;

  IPxiMx248LiveControlDevice = interface
    ['{B1048490-98C3-4C4B-A4D2-9D9B95204A67}']
    function ReadLiveProperties(out AProperties: string):
      TRcOperationResult;
    function ApplyLive(const AProperties: string; ARtsiClock, ARtsiSync,
      ATriggerMode, ATriggerSource, ATriggerLevel: Integer;
      out AReadback: string): TRcOperationResult;
  end;

procedure PreparePxiMx248Block(var ABlock: TRcAcquisitionBlock;
  AChannelCount, ASampleCapacity: Integer);

implementation

procedure PreparePxiMx248Block(var ABlock: TRcAcquisitionBlock;
  AChannelCount, ASampleCapacity: Integer);
var
  I: Integer;
begin
  SetLength(ABlock.Values, AChannelCount);
  { Empty optional metadata arrays mean that every channel uses the common
    SampleCount/FirstTime/SampleRate fields. Do not preallocate them with zero
    values because zero would become an explicit per-channel sample count. }
  SetLength(ABlock.ChannelSampleCounts, 0);
  SetLength(ABlock.ChannelFirstTimesSec, 0);
  SetLength(ABlock.ChannelSampleRatesHz, 0);
  for I := 0 to AChannelCount - 1 do
    SetLength(ABlock.Values[I], ASampleCapacity);
  ABlock.ChannelCount := AChannelCount;
  ABlock.SampleCount := 0;
end;

end.
