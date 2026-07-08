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
  { Разделение AIn на две группы CJC (TIn1/TIn2) для 48ch subrev1. }
  CMic140DefaultCjcSplitChannel = 24;

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
begin
  if (AChannelIndex >= 0) and (AChannelIndex < CMic140DefaultCjcSplitChannel) then
    Result := 1
  else if (AChannelIndex >= CMic140DefaultCjcSplitChannel) and
    (AChannelIndex < MIC140DefaultChannelCount) then
    Result := 2
  else
    Result := 0;
end;

function Mic140DefaultCjcIndex(AChannelIndex: Integer): Integer;
begin
  Result := Mic140DefaultCjcTChannelNumber(AChannelIndex) - 1;
end;

end.
