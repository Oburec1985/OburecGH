program RecorderAudioDacSelectionTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses Classes, SysUtils, uRecorderAudioDacSelection;

var
  gLog: TStringList;

procedure Check(ACondition: Boolean; const AText: string);
begin
  if not ACondition then raise Exception.Create(AText);
  gLog.Add('PASS ' + AText);
end;

function Output(AIndex, AHost: Integer; const AName: string;
  AChannels: Integer = 2): TRecorderAudioOutputInfo;
begin
  Result.NativeIndex := AIndex;
  Result.HostApi := AHost;
  Result.Name := AName;
  Result.OutputChannels := AChannels;
  Result.SampleRateHz := 44100;
  Result.Available := True;
end;

procedure TestUnionAcrossHosts;
var
  lDevices: TRecorderAudioOutputInfos;
  lSelected: TRecorderAudioOutputSelections;
begin
  SetLength(lDevices, 7);
  lDevices[0] := Output(0, 0, 'HD Audio 1');
  lDevices[1] := Output(1, 0, 'HD Audio 2');
  lDevices[2] := Output(2, 0, 'Microsoft Sound Mapper - Output');
  lDevices[3] := Output(3, 1, 'HD Audio 1');
  lDevices[4] := Output(8, 1, 'Sound Blaster PLAY! 3');
  lDevices[5] := Output(10, 1, 'Capture only', 0);
  lDevices[6] := Output(20, 3, 'Unavailable');
  lDevices[6].Available := False;
  SelectRecorderAudioOutputs(lDevices, 0, True, lSelected);
  Check(lSelected[0].Selected and lSelected[1].Selected, 'Both default-host HD outputs retained');
  Check(lSelected[4].Selected and (lSelected[4].Reason = rasrFallbackHost),
    'USB output found only on another host remains visible');
  Check(not lSelected[3].Selected and (lSelected[3].Reason = rasrOtherHostDuplicate),
    'Cross-host duplicate uses default-host representation');
  Check(not lSelected[2].Selected and (lSelected[2].Reason = rasrSoundMapper),
    'Windows Sound Mapper alias excluded');
  Check(not lSelected[5].Selected and (lSelected[5].Reason = rasrInputOnly),
    'Input-only device is not a DAC endpoint');
  Check(not lSelected[6].Selected and (lSelected[6].Reason = rasrUnavailable),
    'Missing native device-info entry diagnosed');
  Check(lDevices[4].NativeIndex = 8, 'Selection never rewrites explicit native endpoint identity');
end;

procedure TestEqualNamesInsideHost;
var
  lDevices: TRecorderAudioOutputInfos;
  lSelected: TRecorderAudioOutputSelections;
begin
  SetLength(lDevices, 4);
  lDevices[0] := Output(1, 0, 'HDMI');
  lDevices[1] := Output(2, 0, 'HDMI');
  lDevices[2] := Output(4, 1, 'HDMI');
  lDevices[3] := Output(5, 1, 'HDMI');
  SelectRecorderAudioOutputs(lDevices, 0, True, lSelected);
  Check(lSelected[0].Selected and lSelected[1].Selected,
    'Two equal-name ports inside preferred host are both retained');
  Check(not lSelected[2].Selected and not lSelected[3].Selected,
    'Only duplicates across different hosts are suppressed');
end;

procedure TestNoDefaultHost;
var
  lDevices: TRecorderAudioOutputInfos;
  lSelected: TRecorderAudioOutputSelections;
begin
  SetLength(lDevices, 5);
  lDevices[0] := Output(8, 2, 'Speakers');
  lDevices[1] := Output(1, 1, 'Speakers');
  lDevices[2] := Output(2, 1, 'Speakers');
  lDevices[3] := Output(9, 2, 'USB only');
  lDevices[4] := Output(12, 3, 'USB only');
  SelectRecorderAudioOutputs(lDevices, -1, True, lSelected);
  Check(not lSelected[0].Selected and lSelected[1].Selected and lSelected[2].Selected,
    'Unavailable default chooses lowest-native-index host and retains its ports');
  Check(lSelected[3].Selected and not lSelected[4].Selected,
    'No-default fallback is selected independently for each device-name group');
  Check(lSelected[1].Reason = rasrNoDefaultHost, 'No-default selection reason is explicit');
end;

procedure TestUnknownAndExactNames;
var
  lDevices: TRecorderAudioOutputInfos;
  lSelected: TRecorderAudioOutputSelections;
begin
  SetLength(lDevices, 6);
  lDevices[0] := Output(0, 0, '');
  lDevices[1] := Output(1, 1, '');
  lDevices[2] := Output(2, 0, 'Speakers');
  lDevices[3] := Output(3, 1, 'speakers');
  lDevices[4] := Output(4, 0, 'USB', 0);
  lDevices[5] := Output(5, 1, 'USB');
  SelectRecorderAudioOutputs(lDevices, 0, True, lSelected);
  Check(lSelected[0].Selected and lSelected[1].Selected,
    'Unnamed outputs are not merged by an unproven physical identity');
  Check(lSelected[2].Selected and lSelected[3].Selected,
    'Only exact names are considered cross-host duplicates');
  Check(lSelected[5].Selected, 'Input-only default-host name cannot hide usable output on another host');
end;

procedure TestMaximumPortCountBeforeDefault;
var
  lDevices: TRecorderAudioOutputInfos;
  lSelected: TRecorderAudioOutputSelections;
begin
  SetLength(lDevices, 4);
  lDevices[0] := Output(1, 0, 'HDMI');
  lDevices[1] := Output(3, 1, 'HDMI');
  lDevices[2] := Output(4, 1, 'HDMI');
  lDevices[3] := Output(8, 2, 'Unrelated USB');
  SelectRecorderAudioOutputs(lDevices, 0, True, lSelected);
  Check(not lSelected[0].Selected and lSelected[1].Selected and lSelected[2].Selected,
    'One default-host name cannot hide two equal-name ports exposed by another host');
  Check(lSelected[3].Selected, 'Maximum-cardinality selection still preserves other devices');
  lDevices[3] := Output(2, 0, 'HDMI');
  SelectRecorderAudioOutputs(lDevices, 0, True, lSelected);
  Check(lSelected[0].Selected and lSelected[3].Selected and
    not lSelected[1].Selected and not lSelected[2].Selected,
    'Equal two-port representations prefer the default host without mixing duplicates');
end;

procedure TestTruncatedNamesAndAliases;
var
  lDevices: TRecorderAudioOutputInfos;
  lSelected: TRecorderAudioOutputSelections;
  lName, lPrefix: string;
begin
  SetLength(lDevices, 7);
  lName := 'Динамики (Sound Blaster Play! 3) extended';
  lPrefix := UTF8Encode(Copy(UTF8Decode(lName), 1, 31));
  lDevices[0] := Output(6, 0, lPrefix);
  lDevices[1] := Output(15, 1, lName);
  lDevices[2] := Output(20, 2, lName);
  lDevices[3] := Output(21, 3, 'USB only on KS');
  lDevices[4] := Output(22, 0, 'Первичный звуковой драйвер');
  lDevices[5] := Output(23, 0, 'Primary Sound Driver');
  lDevices[6] := Output(24, 0, 'Переназначение звуковых устр. - Output');
  SelectRecorderAudioOutputs(lDevices, 0, True, lSelected);
  Check(lSelected[0].Selected and not lSelected[1].Selected and
    not lSelected[2].Selected, 'Unique 31 Unicode-character truncation retains native default endpoint 6');
  Check(lSelected[3].Selected, 'Unrelated KS-only USB remains visible after truncated-name deduplication');
  Check(not lSelected[4].Selected and not lSelected[5].Selected and
    not lSelected[6].Selected, 'English and Russian virtual mapper aliases excluded');
  lDevices[2].Name := UTF8Encode(UTF8Decode(lName) + UnicodeString(' different port'));
  SelectRecorderAudioOutputs(lDevices, 0, True, lSelected);
  Check(lSelected[0].Selected and lSelected[1].Selected and lSelected[2].Selected,
    Format('Ambiguous 31-character prefix never hides distinct full-name ports (%s,%s,%s)',
      [BoolToStr(lSelected[0].Selected, True), BoolToStr(lSelected[1].Selected, True),
       BoolToStr(lSelected[2].Selected, True)]));
  lDevices[0].Name := Copy(lPrefix, 1, 12);
  SelectRecorderAudioOutputs(lDevices, 0, True, lSelected);
  Check(lSelected[0].Selected and lSelected[1].Selected,
    'Arbitrary short prefix is not treated as a truncated device identity');
  lDevices[0].Name := 'Speakers (Sound Blaster Play! 3';
  lDevices[1].Name := 'Speakers (Sound Blaster Play! 3)';
  lDevices[2].Name := lDevices[1].Name;
  SelectRecorderAudioOutputs(lDevices, 0, True, lSelected);
  Check(lSelected[0].Selected and not lSelected[1].Selected and
    not lSelected[2].Selected, 'Actual MIC315 MME/DS/WASAPI names retain only saved native endpoint 6');
  SelectRecorderAudioOutputs(lDevices, 0, False, lSelected);
  Check(lSelected[0].Selected and lSelected[1].Selected,
    'Non-Windows policy does not merge a legitimate 31-character prefix');
end;

begin
  gLog := TStringList.Create;
  try
    try
      TestUnionAcrossHosts;
      TestEqualNamesInsideHost;
      TestNoDefaultHost;
      TestUnknownAndExactNames;
      TestMaximumPortCountBeforeDefault;
      TestTruncatedNamesAndAliases;
      gLog.Add('RESULT RecorderAudioDacSelectionTest passed');
    except
      on E: Exception do
      begin
        gLog.Add('RESULT RecorderAudioDacSelectionTest FAILED: ' + E.Message);
        ExitCode := 1;
      end;
    end;
    WriteLn(gLog.Text);
    gLog.SaveToFile(ChangeFileExt(ParamStr(0), '.log'));
  finally
    gLog.Free;
  end;
end.
