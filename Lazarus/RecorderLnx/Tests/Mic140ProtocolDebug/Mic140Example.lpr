program Mic140Example;

{
  Автономный стенд MIC-140 (Tests/Mic140ProtocolDebug, только локальные модули).

  Паттерн API (см. uMic140Api.pas):
    MIC140 := DevMng.Search;
    MIC140.Connect;
    MIC140.Setup(Cfg);
    MIC140.Start;           { поток вызывает MIC140.OnGetBlock }
    MIC140.Stop;

  Mic140Example.exe [--seconds N]
}

{$mode objfpc}{$H+}

uses
  SysUtils,
  uMic140Api, uMic140Acceptance;

var
  DevMng: TMic140DevMng;
  MIC140: TMic140Device;
  Cfg: TMic140Config;
  lSec: Integer;

begin
  lSec := 10;
  if (ParamCount >= 2) and SameText(ParamStr(1), '--seconds') then
    lSec := StrToIntDef(ParamStr(2), lSec);

  DevMng := TMic140DevMng.Create;
  try
    Cfg := Mic140DefaultConfig;
    MIC140 := DevMng.Search(Cfg.Host, Cfg.Port);
    try
      MIC140.Connect;
      MIC140.Setup(Cfg);
      MIC140.Start;

      ExitCode := Mic140RunAcceptance(MIC140, lSec);
    finally
      MIC140.Stop;
      MIC140.Free;
    end;
  finally
    DevMng.Free;
  end;
end.
