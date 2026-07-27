unit uRecorderMic140Thermocouple;

{
  CJC / термопары MIC-140. Per-channel temper_offset — настройка канала
  (SetTemperOffset в оригинале), не глобальный массив под один прибор.
}

{$mode objfpc}{$H+}

interface

uses
  uRecorderMic140StreamTypes;

const
  CMic140CjcNotAvailable = -1.0E300;
  CMic140JunctionTempMinC = -80.0;
  CMic140JunctionTempMaxC = 120.0;
  CMic140InverseCalibrationMinMv = -20.0;
  CMic140InverseCalibrationMaxMv = 100.0;
  CMic140InverseCalibrationIterations = 48;
  { У MIC-140-48v3 наружу выведены физические TIn6..TIn12. Первые пять
    из них (T6..T10) являются датчиками холодного спая входных групп. }
  CMic140V3FirstVisibleTInNumber = MIC140v3FirstVisibleTemperatureNumber;

function Mic140JunctionTemperatureLooksValid(AValue: Double): Boolean;
function Mic140DefaultCjcTChannelNumber(AChannelIndex: Integer): Integer;
function Mic140DefaultCjcIndex(AChannelIndex: Integer): Integer;

implementation

function Mic140JunctionTemperatureLooksValid(AValue: Double): Boolean;
begin
  Result := (AValue > CMic140JunctionTempMinC) and
    (AValue < CMic140JunctionTempMaxC);
end;

function Mic140DefaultCjcTChannelNumber(AChannelIndex: Integer): Integer;
const
  { Точная таблица CModuleMIC140_48v3::TINCOR_AIN_INDEX_48V3.
    Значения здесь — внутренние индексы видимого списка T6..T12 (1..7). }
  CV3CorrectorByAIn: array[0..MIC140DefaultChannelCount - 1] of Byte = (
    5,5,5,5,5, 4,4,4,4,4, 3,3,3,3,3, 2,2,2,2,2,
    1,1,1,1,1,1,1,1,1, 2,2,2,2,2, 3,3,3,3,3,
    4,4,4,4,4, 5,5,5,5
  );
begin
  if (AChannelIndex < 0) or (AChannelIndex >= MIC140DefaultChannelCount) then
    Exit(0);
  Result := CV3CorrectorByAIn[AChannelIndex];
end;

function Mic140DefaultCjcIndex(AChannelIndex: Integer): Integer;
begin
  Result := Mic140DefaultCjcTChannelNumber(AChannelIndex) - 1;
end;

end.
