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

implementation

procedure PxiMx248DefaultConfiguration(out AConfiguration:
  TPxiMx248Configuration);
var
  I: Integer;
begin
  AConfiguration.SampleRateHz := 1000.0;
  AConfiguration.BlockSamples := 256;
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
