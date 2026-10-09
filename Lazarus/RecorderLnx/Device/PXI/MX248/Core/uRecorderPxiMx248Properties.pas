unit uRecorderPxiMx248Properties;

{
  Назначение: строгая строковая граница MX-248 для UI, scripts и будущего IPC.
  Внешний вход — GetProperties/CalcProperties/SetProperties; после успешного
  atomic commit callback передаёт владельцу полный typed snapshot.

  Контракт: Get и Calc не выполняют I/O, Set сначала проверяет весь пакет и не
  допускает частичной мутации. Числа locale-independent с точкой. Этот unit не
  вызывает lifecycle и не знает DevAPI/IPC/UI. Строковый поиск разрешён только
  при настройке; runtime обязан использовать TPxiMx248Configuration. Store не
  thread-safe: владелец сериализует Get/Calc/Set, callback и destruction; из
  data callback и горячего acquisition loop обращаться к нему запрещено.
  Device владеет store, callback target заимствован и живёт дольше store.

  Архитектура, ключи и первоисточники:
  Device/PXI/MX248/Docs/README.md
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderDriverContractsV2,
  uRecorderDriverPropertiesV2, uRecorderPxiMx248Types;

type
  TPxiMx248ConfigurationCommitted = procedure(
    const AConfiguration: TPxiMx248Configuration) of object;

  TPxiMx248PropertyStore = class(TRecorderTransactionalPropertyStore)
  private
    fOnCommitted: TPxiMx248ConfigurationCommitted;
    function SnapshotConfiguration(AValues: TStrings;
      out AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
  protected
    function ValidateCandidate(AValues: TStrings):
      TRecorderOperationResult; override;
    procedure AfterCommit(const APreviousValues: string); override;
  public
    constructor Create(AOnCommitted: TPxiMx248ConfigurationCommitted);
    function CurrentConfiguration(out AConfiguration:
      TPxiMx248Configuration): TRecorderOperationResult;
  end;

implementation

function BoolValue(const AText: string): Boolean;
begin
  Result := SameText(AText, 'true');
end;

function ChannelKey(AChannel: Integer; const AName: string): string;
begin
  Result := Format('channel.%d.%s', [AChannel + 1, AName]);
end;

constructor TPxiMx248PropertyStore.Create(
  AOnCommitted: TPxiMx248ConfigurationCommitted);
var
  I: Integer;
  lDescriptors: array of TRecorderPropertyDescriptor;

  procedure Add(const ADescriptor: TRecorderPropertyDescriptor);
  begin
    SetLength(lDescriptors, Length(lDescriptors) + 1);
    lDescriptors[High(lDescriptors)] := ADescriptor;
  end;

begin
  fOnCommitted := AOnCommitted;
  Add(RecorderPropertyDescriptor('device.type', rpkInteger, rpaReadOnly,
    IntToStr(CPxiMx248DeviceType)));
  Add(RecorderPropertyDescriptor('sample-rate-hz', rpkFloat, rpaReadWrite,
    '1000', rpsDevice, 'Hz', '1', '200000'));
  Add(RecorderPropertyDescriptor('block-samples', rpkInteger, rpaReadWrite,
    '256', rpsDevice, 'samples', '1', '1048576'));
  Add(RecorderPropertyDescriptor('calibration-mode', rpkEnum, rpaReadWrite,
    'reference', rpsDevice, '', '', '', '1', 'reference|pxi'));
  for I := 0 to CPxiMx248ChannelCount - 1 do
  begin
    Add(RecorderPropertyDescriptor(ChannelKey(I, 'enabled'), rpkBoolean,
      rpaReadWrite, 'True', rpsChannel));
    Add(RecorderPropertyDescriptor(ChannelKey(I, 'amplifier-enabled'),
      rpkBoolean, rpaReadWrite, 'True', rpsChannel));
    Add(RecorderPropertyDescriptor(ChannelKey(I, 'input-mode'), rpkEnum,
      rpaReadWrite, 'differential', rpsChannel, '', '', '', '1',
      'differential|single-ended'));
    Add(RecorderPropertyDescriptor(ChannelKey(I, 'range-index'), rpkInteger,
      rpaReadWrite, '0', rpsChannel, '', '0', '2'));
    Add(RecorderPropertyDescriptor(ChannelKey(I, 'lpf-index'), rpkInteger,
      rpaReadWrite, '0', rpsChannel, '', '0', '1'));
    Add(RecorderPropertyDescriptor(ChannelKey(I, 'icp-current'), rpkEnum,
      rpaReadWrite, 'off', rpsChannel, 'mA', '', '', '1', 'off|4|10'));
    Add(RecorderPropertyDescriptor(ChannelKey(I, 'calibration-enabled'),
      rpkBoolean, rpaReadWrite, 'False', rpsChannel));
    Add(RecorderPropertyDescriptor(ChannelKey(I, 'input-floating'), rpkBoolean,
      rpaReadWrite, 'False', rpsChannel));
  end;
  inherited Create(lDescriptors);
end;

function TPxiMx248PropertyStore.SnapshotConfiguration(AValues: TStrings;
  out AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
var
  I: Integer;
  lFormat: TFormatSettings;
begin
  PxiMx248DefaultConfiguration(AConfiguration);
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  lFormat.ThousandSeparator := #0;
  if not TryStrToFloat(AValues.Values['sample-rate-hz'],
    AConfiguration.SampleRateHz, lFormat) then
    Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
      'mx248.properties', 'Invalid sample rate'));
  if not TryStrToInt(AValues.Values['block-samples'],
    AConfiguration.BlockSamples) then
    Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
      'mx248.properties', 'Invalid block size'));
  for I := 0 to CPxiMx248ChannelCount - 1 do
  begin
    AConfiguration.Channels[I].Enabled := BoolValue(
      AValues.Values[ChannelKey(I, 'enabled')]);
    AConfiguration.Channels[I].AmplifierEnabled := BoolValue(
      AValues.Values[ChannelKey(I, 'amplifier-enabled')]);
    if SameText(AValues.Values[ChannelKey(I, 'input-mode')],
      'single-ended') then
      AConfiguration.Channels[I].InputMode := pimSingleEnded
    else
      AConfiguration.Channels[I].InputMode := pimDifferential;
    AConfiguration.Channels[I].RangeIndex := StrToInt(
      AValues.Values[ChannelKey(I, 'range-index')]);
    AConfiguration.Channels[I].LowPassFilterIndex := StrToInt(
      AValues.Values[ChannelKey(I, 'lpf-index')]);
    if AValues.Values[ChannelKey(I, 'icp-current')] = '10' then
      AConfiguration.Channels[I].IcpCurrent := pic10mA
    else if AValues.Values[ChannelKey(I, 'icp-current')] = '4' then
      AConfiguration.Channels[I].IcpCurrent := pic4mA
    else
      AConfiguration.Channels[I].IcpCurrent := picOff;
    AConfiguration.Channels[I].CalibrationEnabled := BoolValue(
      AValues.Values[ChannelKey(I, 'calibration-enabled')]);
    AConfiguration.Channels[I].InputFloating := BoolValue(
      AValues.Values[ChannelKey(I, 'input-floating')]);
  end;
  if SameText(AValues.Values['calibration-mode'], 'pxi') then
    AConfiguration.CalibrationMode := pcmPxi
  else
    AConfiguration.CalibrationMode := pcmReference;
  Result := TRecorderOperationResult.Success;
end;

function TPxiMx248PropertyStore.ValidateCandidate(AValues: TStrings):
  TRecorderOperationResult;
var
  I: Integer;
  lConfiguration: TPxiMx248Configuration;
  lEnabled: Boolean;
begin
  Result := SnapshotConfiguration(AValues, lConfiguration);
  if not Result.IsSuccess then Exit;
  lEnabled := False;
  for I := 0 to CPxiMx248ChannelCount - 1 do
    lEnabled := lEnabled or lConfiguration.Channels[I].Enabled;
  if not lEnabled then
    Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
      'mx248.properties', 'At least one channel must be enabled'));
end;

procedure TPxiMx248PropertyStore.AfterCommit(const APreviousValues: string);
var
  lConfiguration: TPxiMx248Configuration;
  lResult: TRecorderOperationResult;
begin
  if not Assigned(fOnCommitted) then Exit;
  lResult := CurrentConfiguration(lConfiguration);
  if lResult.IsSuccess then fOnCommitted(lConfiguration);
end;

function TPxiMx248PropertyStore.CurrentConfiguration(
  out AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
var
  lText: string;
  lValues: TStringList;
begin
  Result := GetProperties('*', lText);
  if not Result.IsSuccess then Exit;
  lValues := TStringList.Create;
  try
    lValues.StrictDelimiter := True;
    lValues.Delimiter := ';';
    lValues.DelimitedText := lText;
    lValues.NameValueSeparator := '=';
    Result := SnapshotConfiguration(lValues, AConfiguration);
  finally
    lValues.Free;
  end;
end;

end.
