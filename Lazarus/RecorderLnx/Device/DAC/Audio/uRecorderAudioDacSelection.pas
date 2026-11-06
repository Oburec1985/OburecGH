unit uRecorderAudioDacSelection;

{ Pure discovery policy. Native indices remain identities; names only select
  one host-API representation of a name group. Prefer the host exposing the
  most ports, then the default host on a tie; equal names inside the chosen
  host are retained because they can identify separate physical HDMI ports. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  TRecorderAudioOutputInfo = record
    NativeIndex, HostApi, OutputChannels: Integer;
    Name: string;
    SampleRateHz: Double;
    Available: Boolean;
  end;
  TRecorderAudioOutputInfos = array of TRecorderAudioOutputInfo;

  TRecorderAudioSelectionReason = (rasrDefaultHost, rasrFallbackHost,
    rasrNoDefaultHost, rasrOtherHostDuplicate, rasrInputOnly, rasrUnavailable,
    rasrSoundMapper);

  TRecorderAudioOutputSelection = record
    Selected: Boolean;
    PreferredHost: Integer;
    Reason: TRecorderAudioSelectionReason;
  end;
  TRecorderAudioOutputSelections = array of TRecorderAudioOutputSelection;

procedure SelectRecorderAudioOutputs(const ADevices: TRecorderAudioOutputInfos;
  ADefaultHost: Integer; AWindowsDeviceNames: Boolean;
  out ASelections: TRecorderAudioOutputSelections);
function RecorderAudioSelectionReasonText(AReason: TRecorderAudioSelectionReason): string;

implementation

uses SysUtils;

function IsSoundMapper(const AName: string): Boolean;
begin
  Result := SameText(AName, 'Microsoft Sound Mapper - Output') or
    SameText(AName, 'Primary Sound Driver') or
    (UTF8Decode(AName) = UnicodeString('Первичный звуковой драйвер')) or
    (UTF8Decode(AName) = UnicodeString('Переназначение звуковых устр. - Output'));
end;

function CanonicalName(const ADevices: TRecorderAudioOutputInfos;
  AIndex: Integer; AExcludeSoundMapper: Boolean): string;
var
  I: Integer;
  lShort, lLong: UnicodeString;
  lMatch: string;
begin
  Result := ADevices[AIndex].Name;
  lShort := UTF8Decode(Result);
  { Windows MME returns at most 31 UTF-16 characters. A unique extension
    on another API is a conservative alias heuristic, not hardware identity. }
  if Length(lShort) <> 31 then Exit;
  lMatch := '';
  for I := 0 to High(ADevices) do
  begin
    if not ADevices[I].Available or (ADevices[I].OutputChannels <= 0) or
      (ADevices[I].HostApi = ADevices[AIndex].HostApi) or
      (AExcludeSoundMapper and IsSoundMapper(ADevices[I].Name)) then Continue;
    lLong := UTF8Decode(ADevices[I].Name);
    if (Length(lLong) <= 31) or (Copy(lLong, 1, 31) <> lShort) then Continue;
    if (lMatch <> '') and (lMatch <> ADevices[I].Name) then
    begin
      Result := ADevices[AIndex].Name;
      Exit;
    end;
    lMatch := ADevices[I].Name;
  end;
  if lMatch <> '' then Result := lMatch;
end;

function Eligible(const ADevice: TRecorderAudioOutputInfo;
  AExcludeSoundMapper: Boolean): Boolean;
begin
  Result := ADevice.Available and (ADevice.OutputChannels > 0) and
    not (AExcludeSoundMapper and IsSoundMapper(ADevice.Name));
end;

function CountNamePorts(const ADevices: TRecorderAudioOutputInfos;
  AIndex: Integer; AExcludeSoundMapper: Boolean): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(ADevices) do
    if Eligible(ADevices[I], AExcludeSoundMapper) and
      (ADevices[I].HostApi = ADevices[AIndex].HostApi) and
      (ADevices[I].Name = ADevices[AIndex].Name) then Inc(Result);
end;

function PreferredHost(const ADevices: TRecorderAudioOutputInfos;
  const APortCounts: array of Integer; AIndex, ADefaultHost: Integer;
  AExcludeSoundMapper: Boolean): Integer;
var
  I, lFirstNativeIndex, lBestCount: Integer;
  lCandidateDefault, lCurrentDefault: Boolean;
begin
  Result := ADevices[AIndex].HostApi;
  { Unknown names do not prove shared physical identity. }
  if ADevices[AIndex].Name = '' then Exit;
  lFirstNativeIndex := High(Integer);
  lBestCount := 0;
  for I := 0 to High(ADevices) do
    if Eligible(ADevices[I], AExcludeSoundMapper) and
      (ADevices[I].Name = ADevices[AIndex].Name) then
    begin
      lCandidateDefault := (ADefaultHost >= 0) and
        (ADevices[I].HostApi = ADefaultHost);
      lCurrentDefault := (ADefaultHost >= 0) and (Result = ADefaultHost);
      if (APortCounts[I] > lBestCount) or
        ((APortCounts[I] = lBestCount) and
          ((lCandidateDefault and not lCurrentDefault) or
           ((lCandidateDefault = lCurrentDefault) and
            (ADevices[I].NativeIndex < lFirstNativeIndex)))) then
      begin
        lBestCount := APortCounts[I];
        lFirstNativeIndex := ADevices[I].NativeIndex;
        Result := ADevices[I].HostApi;
      end;
    end;
end;

procedure SelectRecorderAudioOutputs(const ADevices: TRecorderAudioOutputInfos;
  ADefaultHost: Integer; AWindowsDeviceNames: Boolean;
  out ASelections: TRecorderAudioOutputSelections);
var
  I: Integer;
  lPortCounts: array of Integer;
  lCanonicalDevices: TRecorderAudioOutputInfos;
begin
  SetLength(lCanonicalDevices, Length(ADevices));
  for I := 0 to High(ADevices) do
  begin
    lCanonicalDevices[I] := ADevices[I];
    { The caller enables Windows name conventions only on Windows. Other
      platforms may have legitimate 31-character names which are not aliases. }
    if AWindowsDeviceNames then
      lCanonicalDevices[I].Name := CanonicalName(ADevices, I, True);
  end;
  SetLength(ASelections, Length(ADevices));
  SetLength(lPortCounts, Length(ADevices));
  for I := 0 to High(ADevices) do
    lPortCounts[I] := CountNamePorts(lCanonicalDevices, I, AWindowsDeviceNames);
  for I := 0 to High(ADevices) do
  begin
    ASelections[I].Selected := False;
    ASelections[I].PreferredHost := -1;
    if not ADevices[I].Available then
      ASelections[I].Reason := rasrUnavailable
    else if ADevices[I].OutputChannels <= 0 then
      ASelections[I].Reason := rasrInputOnly
    else if AWindowsDeviceNames and IsSoundMapper(ADevices[I].Name) then
      ASelections[I].Reason := rasrSoundMapper
    else
    begin
      ASelections[I].PreferredHost := PreferredHost(lCanonicalDevices, lPortCounts, I,
        ADefaultHost, AWindowsDeviceNames);
      ASelections[I].Selected := ADevices[I].HostApi = ASelections[I].PreferredHost;
      if not ASelections[I].Selected then
        ASelections[I].Reason := rasrOtherHostDuplicate
      else if ADefaultHost < 0 then
        ASelections[I].Reason := rasrNoDefaultHost
      else if ADevices[I].HostApi = ADefaultHost then
        ASelections[I].Reason := rasrDefaultHost
      else
        ASelections[I].Reason := rasrFallbackHost;
    end;
  end;
end;

function RecorderAudioSelectionReasonText(AReason: TRecorderAudioSelectionReason): string;
const
  lNames: array[TRecorderAudioSelectionReason] of string =
    ('selected-default-host', 'selected-fallback-host', 'selected-no-default-host',
     'skipped-other-host-duplicate', 'skipped-input-only', 'skipped-unavailable',
     'skipped-sound-mapper');
begin
  Result := lNames[AReason];
end;

end.
