unit uRecorderMic140DeviceApi;

{
  Контракт IMic140Device для v1/v2. Wire-типы — uRecorderMic140v2WireTypes.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants,
  uRecorderDeviceInterfaces,
  uRecorderMic140v2WireTypes,
  uRecorderTags;

type
  TRecorderMic140LegacyFirmware = uRecorderMic140v2WireTypes.TRecorderMic140LegacyFirmware;
  TMic140LegacyRawBlock = uRecorderMic140v2WireTypes.TMic140LegacyRawBlock;
  TMic140AuxTemperatureBlock = uRecorderMic140v2WireTypes.TMic140AuxTemperatureBlock;

  IMic140Device = interface(IRecorderDevice)
    ['{A8E4F1C2-3B5D-4E9A-9F0C-1D2E3F4A5B6C}']
    function GetDeviceSerial: Integer;
    function GetLegacyFirmware(out AFirmware: TRecorderMic140LegacyFirmware): Boolean;
    function GetNodeNumber: Integer;
    procedure RequestStopAcquisition;
    function ReadLegacyRawBlock(ATimeoutMs: Cardinal;
      out ARaw: TMic140LegacyRawBlock): Boolean;
    function LegacyDecommutateRawBlock(const ARaw: TMic140LegacyRawBlock;
      out ABlock: TRecorderDeviceSampleBlock): Boolean;
    function LastAuxTemperatureBlock: TMic140AuxTemperatureBlock;
    function LegacyStreamReadCount: Int64;
    function LegacyNumBuffGapCount: Integer;
    function LegacyDuplicateNumBuffCount: Integer;
    function LegacyCorruptReadCount: Integer;
    function LegacyMdpResyncByteCount: Int64;
    function LegacyTryRestartStreamAfterReadStall: Boolean;
    function LegacyConsumeStreamSequenceReset: Boolean;
    function ChannelCount: Integer;
    function RunServiceZeroBalance(const AChannelNumbers: array of Integer;
      APollFrequencyHz: Double; out AMeans: TRecorderDoubleArray;
      out AErrorMessage: string): Boolean;
    function UsesRawRing: Boolean;
  end;

implementation

end.
