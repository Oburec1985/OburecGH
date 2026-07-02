unit uMic140Acceptance;

{ Сверка с эталоном Data/mic140_adc_reference.txt (±50). }

{$mode objfpc}{$H+}

interface

uses
  uRecorderDeviceInterfaces;

function Mic140CheckBlockAgainstReference(
  const ABlock: TRecorderDeviceSampleBlock; out AMessage: string): Boolean;

function Mic140RunAcceptance(ADevice: TObject; ADurationSec: Integer): Integer;

implementation

uses
  Classes, SysUtils, Math,
  uMic140Api;

const
  CTolerance = 50;

var
  GRef: array of Integer;
  GRefLoaded: Boolean = False;

procedure EnsureReferenceLoaded;
var
  lList: TStringList;
  lLine: string;
  lParts: TStringArray;
  lVal, lCh: Integer;
begin
  if GRefLoaded then
    Exit;
  lList := TStringList.Create;
  try
    lList.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Data\mic140_adc_reference.txt');
    SetLength(GRef, 48);
    for lLine in lList do
    begin
      if (Trim(lLine) = '') or (lLine[1] = '#') then
        Continue;
      lParts := Trim(lLine).Split([' '], TStringSplitOptions.ExcludeEmpty);
      if Length(lParts) < 3 then
        Continue;
      if not SameText(lParts[0], 'AIN') then
        Continue;
      lCh := StrToIntDef(lParts[1], 0);
      lVal := StrToIntDef(lParts[2], 0);
      if (lCh >= 1) and (lCh <= 48) then
        GRef[lCh - 1] := lVal;
    end;
    GRefLoaded := True;
  finally
    lList.Free;
  end;
end;

function Mic140CheckBlockAgainstReference(
  const ABlock: TRecorderDeviceSampleBlock; out AMessage: string): Boolean;
var
  I: Integer;
  lCode: Integer;
  lBad: Integer;
begin
  EnsureReferenceLoaded;
  Result := True;
  lBad := 0;
  if (ABlock.ChannelCount < 48) or (ABlock.SampleCount < 1) then
  begin
    AMessage := 'block too small';
    Exit(False);
  end;
  for I := 0 to 47 do
  begin
    lCode := Round(ABlock.Values[I][0]);
    if (lCode = 0) or (lCode = 32767) or (lCode = -32768) then
      Inc(lBad);
    if Abs(lCode - GRef[I]) > CTolerance then
    begin
      Result := False;
      AMessage := Format('CH%02d ref=%d got=%d', [I + 1, GRef[I], lCode]);
      Exit;
    end;
  end;
  if lBad > 0 then
  begin
    Result := False;
    AMessage := Format('saturation codes=%d', [lBad]);
  end
  else
    AMessage := 'ok';
end;

function Mic140RunAcceptance(ADevice: TObject; ADurationSec: Integer): Integer;
var
  lDev: TMic140Device;
  lCfg: TMic140Config;
  lBlock: TRecorderDeviceSampleBlock;
  lMsg: string;
  lOk, lBlocks, lFail: Integer;
  lStart: QWord;
begin
  lDev := TMic140Device(ADevice);
  lCfg := Mic140DefaultConfig;
  lOk := 0;
  lBlocks := 0;
  lFail := 0;

  WriteLn(Format('MIC-140 acceptance: %d s, tol=±%d codes', [ADurationSec, CTolerance]));

  lStart := GetTickCount64;
  while (GetTickCount64 - lStart) < QWord(ADurationSec) * 1000 do
  begin
    if lDev.ReadBlock(lCfg.DataUpdateMs + 500, lBlock) then
    begin
      Inc(lBlocks);
      if Mic140CheckBlockAgainstReference(lBlock, lMsg) then
        Inc(lOk)
      else
      begin
        Inc(lFail);
        if lFail <= 3 then
          WriteLn('FAIL: ' + lMsg);
      end;
    end;
  end;

  WriteLn(lDev.StreamStopLine);
  WriteLn(Format('blocks=%d ok=%d fail=%d', [lBlocks, lOk, lFail]));

  if (lFail > 0) or (lBlocks < ADurationSec * 4) then
    Result := 1
  else
    Result := 0;
end;

end.
