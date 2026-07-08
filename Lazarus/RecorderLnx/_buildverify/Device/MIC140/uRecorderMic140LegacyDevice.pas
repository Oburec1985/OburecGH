unit uRecorderMic140LegacyDevice;

{
  MIC-140 v1: наследник общего ядра, двухслотовый буфер между потоками (UsesRawRing=False).
}

{$mode objfpc}{$H+}

interface

uses
  uRecorderMic140DeviceCore, uRecorderMic140DeviceApi;

type
  TRecorderMic140LegacyDevice = class(TRecorderMic140DeviceCore);
  TRecorderMic140Device = TRecorderMic140LegacyDevice;

implementation

end.
