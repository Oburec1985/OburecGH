program TestSpectrumMath;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  SysUtils,
  uSpectrumMathBench,
  uBestSpectrumPipeline,
  uRecorderSpectrumEngineTests,
  uRecorderGeneralAlgorithmTests;

begin
  try
    RunRecorderSpectrumEngineTests;
    RunRecorderGeneralAlgorithmTests;
    RunSpectrumMathBench;
  except
    on E: Exception do
    begin
      Writeln('ERROR: ', E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
