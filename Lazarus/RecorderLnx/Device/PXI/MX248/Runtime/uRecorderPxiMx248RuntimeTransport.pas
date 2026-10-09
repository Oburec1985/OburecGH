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
      var ABlock: TRecorderAcquisitionBlock): TRecorderOperationResult;
  end;

procedure PreparePxiMx248Block(var ABlock: TRecorderAcquisitionBlock;
  AChannelCount, ASampleCapacity: Integer);

implementation

procedure PreparePxiMx248Block(var ABlock: TRecorderAcquisitionBlock;
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
