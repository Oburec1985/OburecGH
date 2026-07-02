unit uMic140AcceptanceLog;

{
  Лог приёмки и критерии PASS/FAIL для стенда.

  Файл: mic140_protocol_debug.log (рядом с exe).
  Формат строк stream stop совместим с Tools/mic140_preview_eval.ps1 в RecorderLnx.

  Счётчики TMic140AcceptanceStats:
    Read          — все успешно декоммутированные блоки из TCP
    Published     — блоки, прошедшие проверку кодов (строгий счётчик)
    CorruptPublish — число отклонённых sample-кодов при CheckPublishedCodes
    ReadGaps / PublishGaps / corruptRead / mdpResync — целостность потока

  EvaluatePass: нет corrupt/gaps, Published в диапазоне ~90..125% от ожидания,
    ratio Published/Read >= 85%.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Math,
  uRecorderDeviceInterfaces,
  uRecorderAcquisitionTypes,
  uRecorderMic140v2WireTypes,
  uMic140DebugConfig,
  uMic140DebugReference;

type
  TMic140AcceptanceStats = record
    Published: Integer;
    Read: Integer;
    ReadGaps: Integer;
    PublishGaps: Integer;
    CorruptRead: Integer;
    CorruptPublish: Integer;
    CodeViolations: Integer;
    SoftRestart: Integer;
    MdpResync: Int64;
    StartTick: QWord;
    ElapsedSec: Double;
  end;

procedure Mic140AcceptanceStatsClear(var AStats: TMic140AcceptanceStats);

const
  CMic140DebugLogFileName = 'mic140_protocol_debug.log';

type
  TMic140AcceptanceLog = class
  private
    fPath: string;
    fLines: TStringList;
    procedure AppendLine(const ALine: string);
  public
    constructor Create(const ABaseDir: string);
    destructor Destroy; override;
    property Path: string read fPath;
    procedure LogInfo(const ALine: string);
    procedure LogAdcTable(const ABlock: TRecorderDeviceSampleBlock;
      const AAux: TMic140AuxTemperatureBlock; ABlockNo: Integer;
      ACheckTin: Boolean = True);
    function CheckPublishedTinCodes(const AAux: TMic140AuxTemperatureBlock;
      var AStats: TMic140AcceptanceStats): Boolean;
    function CheckPublishedCodes(const ABlock: TRecorderDeviceSampleBlock;
      const AAux: TMic140AuxTemperatureBlock; var AStats: TMic140AcceptanceStats;
      ACheckTin: Boolean = True): Boolean;
    procedure LogStreamStop(const ASourceId: string; var AStats: TMic140AcceptanceStats);
    function EvaluatePass(const AStats: TMic140AcceptanceStats;
      ADurationSec: Integer): string;
    procedure Flush;
  end;

implementation

uses
  uMic140AdcTable;

procedure Mic140AcceptanceStatsClear(var AStats: TMic140AcceptanceStats);
begin
  FillChar(AStats, SizeOf(AStats), 0);
end;

constructor TMic140AcceptanceLog.Create(const ABaseDir: string);
var
  lDir: string;
begin
  inherited Create;
  fLines := TStringList.Create;
  lDir := IncludeTrailingPathDelimiter(ABaseDir);
  if not DirectoryExists(lDir) then
    ForceDirectories(lDir);
  fPath := lDir + CMic140DebugLogFileName;
  AppendLine(Format('=== MIC140 protocol debug log %s ===', [DateTimeToStr(Now)]));
  Flush;
end;

destructor TMic140AcceptanceLog.Destroy;
begin
  Flush;
  fLines.Free;
  inherited Destroy;
end;

procedure TMic140AcceptanceLog.AppendLine(const ALine: string);
begin
  fLines.Add(ALine);
end;

procedure TMic140AcceptanceLog.LogInfo(const ALine: string);
begin
  AppendLine(ALine);
  Flush;
end;

function TMic140AcceptanceLog.CheckPublishedTinCodes(const AAux: TMic140AuxTemperatureBlock;
  var AStats: TMic140AcceptanceStats): Boolean;
var
  lTin, lSample: Integer;
  lCode, lExpected: Integer;
  lBad: Integer;
begin
  Result := True;
  lBad := 0;
  for lTin := 0 to CMic140StandTinCount - 1 do
  begin
    if lTin >= AAux.ChannelCount then
      Break;
    if lTin >= Length(AAux.Values) then
      Break;
    for lSample := 0 to AAux.SampleCount - 1 do
    begin
      if lSample >= Length(AAux.Values[lTin]) then
        Break;
      lCode := Round(AAux.Values[lTin][lSample]);
      if not Mic140StandTinCodeOk(lCode, lTin) then
      begin
        Inc(lBad);
        if lBad = 1 then
        begin
          if Mic140StandTinReference(lTin, lExpected) then
            AppendLine(Format(
              'MIC-140 TIn code quality violation: publish=%d bad>=1 first=T%d sample=%d raw=%d expected=%d +/-%d',
              [AStats.Published, lTin + 1, lSample, lCode, lExpected,
               CMic140StandTolTin]))
          else
            AppendLine(Format(
              'MIC-140 TIn code quality violation: publish=%d first=T%d sample=%d raw=%d',
              [AStats.Published, lTin + 1, lSample, lCode]));
        end;
      end;
    end;
  end;
  if lBad > 0 then
  begin
    Inc(AStats.CorruptPublish, lBad);
    Inc(AStats.CodeViolations);
    Result := False;
  end;
end;

function TMic140AcceptanceLog.CheckPublishedCodes(const ABlock: TRecorderDeviceSampleBlock;
  const AAux: TMic140AuxTemperatureBlock; var AStats: TMic140AcceptanceStats;
  ACheckTin: Boolean): Boolean;
var
  lCh, lSample, lCode, lExpected, lTol: Integer;
  lBad: Integer;
begin
  Result := True;
  lBad := 0;
  for lCh := 0 to Min(ABlock.ChannelCount, CMic140StandAinCount) - 1 do
  begin
    if lCh >= Length(ABlock.Values) then
      Break;
    for lSample := 0 to ABlock.SampleCount - 1 do
    begin
      if lSample >= Length(ABlock.Values[lCh]) then
        Break;
      lCode := Trunc(ABlock.Values[lCh][lSample]);
      if not Mic140StandAinCodeOk(lCode, lCh) then
      begin
        Inc(lBad);
        if lBad = 1 then
        begin
          if Mic140StandAinReference(lCh, lExpected) then
          begin
            lTol := Mic140StandAinTolerance(lCh);
            AppendLine(Format(
              'MIC-140 code quality violation: publish=%d bad>=1 first=ch%d sample=%d raw=%d expected=%d +/-%d',
              [AStats.Published, lCh + 1, lSample, lCode, lExpected, lTol]));
          end
          else
            AppendLine(Format(
              'MIC-140 code quality violation: publish=%d first=ch%d sample=%d raw=%d',
              [AStats.Published, lCh + 1, lSample, lCode]));
        end;
      end;
    end;
  end;
  if lBad > 0 then
  begin
    Inc(AStats.CorruptPublish, lBad);
    Inc(AStats.CodeViolations);
    Result := False;
  end;
  if ACheckTin and not CheckPublishedTinCodes(AAux, AStats) then
    Result := False;
end;

procedure TMic140AcceptanceLog.LogAdcTable(const ABlock: TRecorderDeviceSampleBlock;
  const AAux: TMic140AuxTemperatureBlock; ABlockNo: Integer; ACheckTin: Boolean);
var
  lGood, lTotal: Integer;
begin
  if ABlock.SampleCount <= 0 then
    Exit;
  lGood := Mic140AdcTableCountGood(ABlock, AAux, ACheckTin);
  lTotal := CMic140StandAinCount;
  if ACheckTin then
    Inc(lTotal, CMic140StandTinCount);
  AppendLine(Format('[DataSource] MIC-140 block%d stand-good=%d/%d',
    [ABlockNo, lGood, lTotal]));
  Mic140AdcTableAppendLog(fLines, ABlock, AAux, ABlockNo, ACheckTin);
  Flush;
end;

procedure TMic140AcceptanceLog.LogStreamStop(const ASourceId: string;
  var AStats: TMic140AcceptanceStats);
begin
  if AStats.StartTick > 0 then
    AStats.ElapsedSec := (GetTickCount64 - AStats.StartTick) / 1000.0
  else
    AStats.ElapsedSec := 0;
  AppendLine(Format(
    '[DataSource:%s] MIC-140 stream stop: published=%d read=%d readGaps=%d dupRead=0 corruptRead=%d publishGaps=%d corruptPublish=%d ringDropped=0 mdpResync=%d',
    [ASourceId, AStats.Published, AStats.Read, AStats.ReadGaps,
     AStats.CorruptRead, AStats.PublishGaps, AStats.CorruptPublish, AStats.MdpResync]));
  AppendLine(Format('freq=%.3f Hz', [CMic140DebugPollHz]));
  Flush;
end;

function TMic140AcceptanceLog.EvaluatePass(const AStats: TMic140AcceptanceStats;
  ADurationSec: Integer): string;
var
  lExpected, lMin, lMax: Integer;
  lRatio: Integer;
  lPass: Boolean;
begin
  lExpected := Round(ADurationSec * CMic140DebugBlocksPerSec);
  lMin := Max(1, Trunc(lExpected * 0.90));
  lMax := Ceil(lExpected * 1.25) + 1;
  if AStats.Read > 0 then
    lRatio := Trunc(AStats.Published * 100 / AStats.Read)
  else
    lRatio := 0;
  lPass := (AStats.CorruptRead = 0) and (AStats.ReadGaps = 0) and
    (AStats.PublishGaps = 0) and (AStats.CorruptPublish = 0) and
    (AStats.CodeViolations = 0) and (AStats.SoftRestart = 0) and
    (AStats.Published >= lMin) and (AStats.Published <= lMax) and
    (lRatio >= 85);
  if lPass then
    Result := Format(
      'PASS pub=%d read=%d ratio=%d%% corrupt=%d corruptPublish=%d codeBad=%d pubGaps=%d readGaps=%d softRestart=%d expected=%d range=%d..%d bps=%.0f elapsed=%.2fs',
      [AStats.Published, AStats.Read, lRatio, AStats.CorruptRead,
       AStats.CorruptPublish, AStats.CodeViolations, AStats.PublishGaps,
       AStats.ReadGaps, AStats.SoftRestart, lExpected, lMin, lMax,
       CMic140DebugBlocksPerSec, AStats.ElapsedSec])
  else
    Result := Format(
      'FAIL pub=%d read=%d ratio=%d%% corrupt=%d corruptPublish=%d codeBad=%d pubGaps=%d readGaps=%d softRestart=%d expected=%d range=%d..%d bps=%.0f elapsed=%.2fs',
      [AStats.Published, AStats.Read, lRatio, AStats.CorruptRead,
       AStats.CorruptPublish, AStats.CodeViolations, AStats.PublishGaps,
       AStats.ReadGaps, AStats.SoftRestart, lExpected, lMin, lMax,
       CMic140DebugBlocksPerSec, AStats.ElapsedSec]);
end;

procedure TMic140AcceptanceLog.Flush;
begin
  if fPath = '' then
    Exit;
  try
    fLines.SaveToFile(fPath);
  except
  end;
end;

end.
