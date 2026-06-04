program RecorderMeraBlockStorageTest;

{$mode objfpc}{$H+}

uses
  Classes,
  LConvEncoding,
  SysUtils,
  uRecorderDataStorage;

procedure AssertTrue(ACondition: Boolean; const AStep: string);
begin
  if not ACondition then
    raise Exception.Create(AStep + ': condition is false');
end;

procedure AssertEquals(AActual, AExpected: Int64; const AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %d, got %d',
      [AStep, AExpected, AActual]);
end;

procedure AssertContains(const AText, AExpected, AStep: string);
begin
  if Pos(AExpected, AText) <= 0 then
    raise Exception.CreateFmt('%s: expected text not found: %s',
      [AStep, AExpected]);
end;

procedure AssertNotContains(const AText, AExpected, AStep: string);
begin
  if Pos(AExpected, AText) > 0 then
    raise Exception.CreateFmt('%s: unexpected text found: %s',
      [AStep, AExpected]);
end;

function ReadTextFile(const AFileName: string): string;
var
  lLines: TStringList;
begin
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(AFileName);
    Result := CP1251ToUTF8(lLines.Text);
  finally
    lLines.Free;
  end;
end;

function FileSizeOf(const AFileName: string): Int64;
var
  lStream: TFileStream;
begin
  lStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    Result := lStream.Size;
  finally
    lStream.Free;
  end;
end;

procedure TestMeraBlockWriter;
var
  lFrameDir: string;
  lManager: TRecorderRecordFrameManager;
  lRootDir: string;
  lText: string;
  lTimes1: array[0..2] of Double;
  lTimes2: array[0..1] of Double;
  lTimesRus: array[0..1] of Double;
  lValues1: array[0..2] of Double;
  lValues2: array[0..1] of Double;
  lValuesRus: array[0..1] of Double;
  lWriter: TRecorderMeraTagWriter;
begin
  lRootDir := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'mera-block-test-' + FormatDateTime('yyyymmdd-hhnnss-zzz', Now);
  lManager := TRecorderRecordFrameManager.Create(lRootDir);
  try
    lFrameDir := lManager.OpenNextFrame;
    lManager.WriteFrameInfo('RecorderMeraBlockStorageTest', 'mera block frame');

    lTimes1[0] := 0.00;
    lTimes1[1] := 0.01;
    lTimes1[2] := 0.02;
    lValues1[0] := 1.0;
    lValues1[1] := 2.0;
    lValues1[2] := 3.0;
    lTimes2[0] := 0.10;
    lTimes2[1] := 0.11;
    lValues2[0] := 4.0;
    lValues2[1] := 5.0;
    lTimesRus[0] := 0.0000149536;
    lTimesRus[1] := 0.0000323147;
    lValuesRus[0] := 10.0;
    lValuesRus[1] := 20.0;

    lWriter := TRecorderMeraTagWriter.Create;
    try
      lWriter.Open(lFrameDir);
      lWriter.WriteBlock('BlockTag', 'V', 'block test tag', 'SensorGX',
        'AmplifierGX', lTimes1, lValues1, 3, 100.0);
      lWriter.WriteBlock('BlockTag', 'V', 'block test tag', 'SensorGX',
        'AmplifierGX', lTimes2, lValues2, 2, 100.0);
      lWriter.WriteBlock('1_датчик_X', 'В',
        '1 датчик X; type=R4; freq=57600; file=1 датчик X.dat', '', '',
        lTimesRus, lValuesRus, 2, 57600.0);
      lWriter.Close;
    finally
      lWriter.Free;
    end;

    AssertTrue(FileExists(lFrameDir + 'BlockTag.dat'), 'data file');
    AssertTrue(not FileExists(lFrameDir + 'BlockTag.x'), 'regular block has no x file');
    AssertTrue(FileExists(lFrameDir + 'BlockTag.ptr'), 'ptr file');
    AssertTrue(FileExists(lFrameDir + 'BlockTag.prt'), 'prt file');
    AssertTrue(FileExists(lFrameDir + '0001.mera'), 'descriptor file');
    AssertTrue(FileExists(lFrameDir + '1_датчик_X.dat'), 'russian data file');
    AssertTrue(not FileExists(lFrameDir + '1_датчик_X.x'), 'regular russian signal has no x file');
    AssertEquals(FileSizeOf(lFrameDir + 'BlockTag.dat'), 5 * SizeOf(Double),
      'data size');
    AssertEquals(FileSizeOf(lFrameDir + '1_датчик_X.dat'), 2 * SizeOf(Single),
      'russian R4 data size');

    lText := ReadTextFile(lFrameDir + 'BlockTag.ptr');
    AssertContains(lText, ' 3', 'ptr sample offset');
    lText := ReadTextFile(lFrameDir + '0001.mera');
    AssertContains(lText, 'PtrFile=BlockTag.ptr', 'descriptor ptr');
    AssertContains(lText, 'PrtFile=BlockTag.prt', 'descriptor prt');
    AssertContains(lText, 'tare0="SensorGX"', 'descriptor sensor GX');
    AssertContains(lText, 'tare1="AmplifierGX"', 'descriptor amplifier GX');
    AssertContains(lText, '[1_датчик_X]', 'descriptor russian section');
    AssertContains(lText, 'YFile=1_датчик_X.dat', 'descriptor russian file');
    AssertContains(lText, 'YFormat=R4', 'descriptor R4 format');
    AssertNotContains(lText, 'XFile=1_датчик_X.x', 'regular 1D has no X file');

    lManager.CloseFrame;
    Writeln('Recorder MERA block storage test passed.');
  finally
    lManager.Free;
  end;
end;

begin
  TestMeraBlockWriter;
end.
