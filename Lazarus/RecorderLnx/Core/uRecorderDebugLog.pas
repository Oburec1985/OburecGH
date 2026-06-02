unit uRecorderDebugLog;

{$mode objfpc}{$H+}

interface

procedure RecorderDebugLog(const AMessage: string);

implementation

uses
  uSharedFileLogger;

const
  CRecorderLogFile = 'D:\works\log\RecorderLnx.log';

procedure RecorderDebugLog(const AMessage: string);
begin
  SharedLogger.Debug(AMessage);
end;

initialization
  SharedLogger.Configure(CRecorderLogFile);

end.
