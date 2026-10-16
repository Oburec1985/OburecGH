unit uRecorderPxiMx248Types;

{
  Назначение: единый typed snapshot и состояния PXI MX-248. Его создаёт
  property adapter, а device/transport читают после validation.

  Контракт: unit не знает о DevAPI, Windows, IPC, datasource и UI. Индексы
  каналов в массиве zero-based, публичные строковые ключи one-based. Snapshot
  после Configure не меняется в runtime; следующий commit только помечает
  устройство dirty. Парная модель AIn/amplifier и общий источник калибровки
  обязаны сохраняться явно, без догадок в transport. Records копируются по
  значению, не владеют ресурсами и не содержат синхронизации. Запрещено
  добавлять сюда ABI-records, handles, runtime buffers и счётчики.

  Архитектура и первоисточники:
  Device/PXI/MX248/Docs/README.md
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

const
  CPxiMx248DeviceType = $614D;
  CPxiMx248ChannelCount = 8;
  CPxiMx248RangeCount = 3;
  CPxiMx248SampleRateCount = 11;
  { The bridge response contains eight Float32 channel arrays plus framing.
    32760 leaves headroom inside the 1 MiB IPC payload. Keep the property
    schema, runtime buffer and bridge validation on this single limit. }
  CPxiMx248MaxBlockSamples = 32760;
  { DevAPI's original Recorder configures roughly one refresh portion per
    block. The bridge cannot carry a full 100 ms block at 512 kHz in its
    1 MiB frame, and the legacy 256-sample placeholder caused hundreds of IPC
    calls per UI tick. }
  { Keep the bridge comfortably below the legacy DevAPI/FIFO edge. 16384
    samples is a 32 ms block at 512 kHz and only about 0.5 MiB for all eight
    Float32 channels, so IPC needs about 31 calls/s without exposing a tuning
    knob that the original Recorder kept internal. }
  CPxiMx248DefaultBlockSamples = 16384;
  CPxiMx248DefaultSampleRateHz = 512000;
  CPxiMx248SampleRates: array[0..CPxiMx248SampleRateCount - 1] of Integer =
    (422, 844, 1688, 3375, 6750, 13500, 27000, 54000, 108000, 216000,
     512000);

type
  TPxiMx248State = (pmsCreated, pmsConnected, pmsInitialized,
    pmsConfigured, pmsRunning, pmsOffline);
  TPxiMx248InputMode = (pimDifferential, pimSingleEnded);
  TPxiMx248CalibrationMode = (pcmOff, pcmReference, pcmPxi);
  TPxiMx248IcpCurrent = (picOff, pic4mA, pic10mA);

  TPxiMx248DiscoveredDevice = record
    DeviceIndex: Integer;
    SerialNumber: LongWord;
    Revision: LongWord;
    DeviceName: string;
    ChassisType: Integer;
    Chassis: Integer;
    Slot: Integer;
  end;
  TPxiMx248DiscoveredDevices = array of TPxiMx248DiscoveredDevice;

  TPxiMx248ChannelConfiguration = record
    Enabled: Boolean;
    AmplifierEnabled: Boolean;
    InputMode: TPxiMx248InputMode;
    RangeIndex: Integer;
    LowPassFilterIndex: Integer;
    IcpCurrent: TPxiMx248IcpCurrent;
    CalibrationEnabled: Boolean;
    InputFloating: Boolean;
  end;

  TPxiMx248Configuration = record
    SampleRateHz: Double;
    BlockSamples: Integer;
    CalibrationMode: TPxiMx248CalibrationMode;
    Channels: array[0..CPxiMx248ChannelCount - 1] of
      TPxiMx248ChannelConfiguration;
  end;

procedure PxiMx248DefaultConfiguration(out AConfiguration:
  TPxiMx248Configuration);
function PxiMx248InputModeName(AValue: TPxiMx248InputMode): string;
function PxiMx248CalibrationModeName(
  AValue: TPxiMx248CalibrationMode): string;
function PxiMx248IsSupportedSampleRate(AValue: Double): Boolean;

implementation

procedure PxiMx248DefaultConfiguration(out AConfiguration:
  TPxiMx248Configuration);
var
  I: Integer;
begin
  AConfiguration.SampleRateHz := CPxiMx248DefaultSampleRateHz;
  { Preserve the vendor/original default. Runtime drains multiple blocks per
    scheduler tick, so a small hardware block no longer throttles throughput. }
  AConfiguration.BlockSamples := CPxiMx248DefaultBlockSamples;
  AConfiguration.CalibrationMode := pcmReference;
  for I := 0 to CPxiMx248ChannelCount - 1 do
  begin
    AConfiguration.Channels[I].Enabled := True;
    AConfiguration.Channels[I].AmplifierEnabled := True;
    AConfiguration.Channels[I].InputMode := pimDifferential;
    AConfiguration.Channels[I].RangeIndex := 0;
    AConfiguration.Channels[I].LowPassFilterIndex := 0;
    AConfiguration.Channels[I].IcpCurrent := picOff;
    AConfiguration.Channels[I].CalibrationEnabled := False;
    AConfiguration.Channels[I].InputFloating := False;
  end;
end;

function PxiMx248IsSupportedSampleRate(AValue: Double): Boolean;
var
  I: Integer;
begin
  for I := Low(CPxiMx248SampleRates) to High(CPxiMx248SampleRates) do
    if Abs(AValue - CPxiMx248SampleRates[I]) < 0.001 then Exit(True);
  Result := False;
end;

function PxiMx248InputModeName(AValue: TPxiMx248InputMode): string;
begin
  case AValue of
    pimDifferential: Result := 'differential';
    pimSingleEnded: Result := 'single-ended';
  end;
end;

function PxiMx248CalibrationModeName(
  AValue: TPxiMx248CalibrationMode): string;
begin
  case AValue of
    pcmOff: Result := 'off';
    pcmReference: Result := 'reference';
    pcmPxi: Result := 'pxi';
  end;
end;

end.
