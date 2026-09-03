unit uRecorderDeviceConfigSignature;

{
  Снимок только тех настроек источника, которые требуют пересоздания или
  программирования аппаратуры. Универсальные диалоги сравнивают снимки и не
  разбирают особенности конкретных устройств.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderTags;

function RecorderSourceProgrammingSignature(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag): string;
function RecorderSourceProgrammingSignatureById(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): string;
function RecorderProgrammingSignatureDifference(const ABefore,
  AAfter: string): string;
procedure RecorderMarkSourceProgrammingApplied(ARegistry: TRecorderTagRegistry;
  const ASourceId: string);
function RecorderSourceProgrammingAlreadyApplied(ARegistry: TRecorderTagRegistry;
  const ASourceId, ASignature: string): Boolean;

implementation

uses
  Classes, SysUtils,
  uRecorderConfiguredDataSources,
  uRecorderMic140Utils, uRecorderMic140DeviceConfig,
  uRecorderMic140StreamTypes;

var
  gAppliedSourceSignatures: TStringList;
  gAppliedSignatureLock: TRTLCriticalSection;

function FloatSignature(AValue: Double): string;
begin
  Result := FloatToStr(AValue, DefaultFormatSettings);
end;

function AppliedSignatureKey(const ASourceId: string): string;
begin
  Result := RecorderNormalizeTagSourceId(ASourceId);
end;

procedure EnsureAppliedSignatureCache;
begin
  if gAppliedSourceSignatures <> nil then
    Exit;
  gAppliedSourceSignatures := TStringList.Create;
  gAppliedSourceSignatures.CaseSensitive := False;
  gAppliedSourceSignatures.NameValueSeparator := '=';
end;

function CacheSignatureValue(const ASignature: string): string;
begin
  Result := StringReplace(ASignature, LineEnding, #1, [rfReplaceAll]);
end;

procedure RecorderMarkSourceProgrammingApplied(ARegistry: TRecorderTagRegistry;
  const ASourceId: string);
var
  lKey: string;
  lSignature: string;
begin
  if ARegistry = nil then
    Exit;
  lKey := AppliedSignatureKey(ASourceId);
  if lKey = '' then
    Exit;
  lSignature := CacheSignatureValue(
    RecorderSourceProgrammingSignatureById(ARegistry, ASourceId));
  if lSignature = '' then
    Exit;
  EnterCriticalSection(gAppliedSignatureLock);
  try
    EnsureAppliedSignatureCache;
    gAppliedSourceSignatures.Values[lKey] := lSignature;
  finally
    LeaveCriticalSection(gAppliedSignatureLock);
  end;
end;

function RecorderSourceProgrammingAlreadyApplied(ARegistry: TRecorderTagRegistry;
  const ASourceId, ASignature: string): Boolean;
var
  lKey: string;
begin
  Result := False;
  lKey := AppliedSignatureKey(ASourceId);
  if lKey = '' then
    Exit;
  EnterCriticalSection(gAppliedSignatureLock);
  try
    if gAppliedSourceSignatures = nil then
      Exit;
    Result := gAppliedSourceSignatures.Values[lKey] =
      CacheSignatureValue(ASignature);
  finally
    LeaveCriticalSection(gAppliedSignatureLock);
  end;
end;

function RecorderProgrammingSignatureDifference(const ABefore,
  AAfter: string): string;
var
  I: Integer;
  lAfter: TStringList;
  lBefore: TStringList;
  lCount: Integer;
  lNewValue: string;
  lOldValue: string;
begin
  Result := '';
  if ABefore = AAfter then
    Exit;
  lBefore := TStringList.Create;
  lAfter := TStringList.Create;
  try
    lBefore.Text := ABefore;
    lAfter.Text := AAfter;
    lCount := lBefore.Count;
    if lAfter.Count > lCount then
      lCount := lAfter.Count;
    for I := 0 to lCount - 1 do
    begin
      if I < lBefore.Count then
        lOldValue := lBefore[I]
      else
        lOldValue := '<отсутствует>';
      if I < lAfter.Count then
        lNewValue := lAfter[I]
      else
        lNewValue := '<отсутствует>';
      if lOldValue <> lNewValue then
        Exit(Format('строка %d: "%s" -> "%s"',
          [I + 1, lOldValue, lNewValue]));
    end;
    Result := 'содержимое изменилось';
  finally
    lAfter.Free;
    lBefore.Free;
  end;
end;

function RecorderSourceProgrammingSignature(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag): string;
begin
  if ATag = nil then
    Exit('');
  Result := RecorderSourceProgrammingSignatureById(ARegistry, ATag.SourceId);
end;

function RecorderSourceProgrammingSignatureById(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): string;
var
  I: Integer;
  lConfig: TRecorderMic140SourceConfig;
  lEntry: TRecorderConfiguredDataSource;
  lHost: string;
  lLines: TStringList;
  lPort: Word;
  lSettings: TRecorderMic140ChannelSettings;
  lSourceId: string;
  lSourceTags: TStringList;
  lTag: TRecorderTag;
begin
  Result := '';
  if (ARegistry = nil) or (Trim(ASourceId) = '') then
    Exit;

  lSourceId := RecorderNormalizeTagSourceId(ASourceId);
  lLines := TStringList.Create;
  lSourceTags := TStringList.Create;
  try
    lSourceTags.Sorted := True;
    lSourceTags.Duplicates := dupAccept;
    lLines.Add('source=' + lSourceId);

    lEntry := RecorderConfiguredDataSourcesFind(ARegistry, lSourceId);
    if lEntry <> nil then
    begin
      lLines.Add('module=' + lEntry.ModuleType);
      lLines.Add('defaultFrequency=' +
        FloatSignature(lEntry.DefaultPollFrequencyHz));
    end;

    if TryParseRecorderMic140SourceId(lSourceId, lHost, lPort) then
    begin
      lConfig := FindRecorderMic140DeviceConfig(ARegistry, lSourceId);
      if lConfig <> nil then
      begin
        lLines.Add('type=MIC-140');
        lLines.Add('host=' + lConfig.Host);
        lLines.Add('port=' + IntToStr(lConfig.Port));
        lLines.Add('channelCount=' + IntToStr(lConfig.ChannelCount));
        lLines.Add('thermo=' +
          BoolToStr(lConfig.ThermoCompensationEnabled, True));
        lLines.Add('boardCommut=' + IntToStr(lConfig.BoardCommutIndex));
        for I := 0 to lConfig.SelectedChannels.Count - 1 do
          lLines.Add('selected=' + lConfig.SelectedChannels[I]);

        for I := 0 to lConfig.ChannelCount - 1 do
        begin
          if I <= High(lConfig.ChannelSettings) then
            lSettings := lConfig.ChannelSettings[I]
          else
            RecorderMic140InitChannelSettings(lSettings, I,
              CMic140Mic140SubRev1);
          { Только параметры, передаваемые коммутатору/АЦП. Программные ГХ,
            единицы, КХС и оценки не требуют программирования прибора. }
          lLines.Add(Format('channel=%d;range=%d;commut=%d',
            [I + 1, lSettings.RangeIndex, lSettings.CommutIndex]));
        end;
      end;
    end
    else if lEntry <> nil then
    begin
      { Для MIC183/185 и MC-032 аппаратная конфигурация хранится целиком
        в записи узла источника. Length исключает неоднозначную склейку строк. }
      lLines.Add('configLength=' + IntToStr(Length(lEntry.SpecificConfigText)));
      lLines.Add(lEntry.SpecificConfigText);
    end;

    { Состав каналов, их аппаратные адреса и частоты также определяют
      создаваемый runtime-источник. Имена и прочие свойства тегов исключены. }
    for I := 0 to ARegistry.TagCount - 1 do
    begin
      lTag := ARegistry.Tags[I];
      if (lTag <> nil) and
        SameText(RecorderNormalizeTagSourceId(lTag.SourceId), lSourceId) then
        lSourceTags.Add(lTag.Address + '=' +
          FloatSignature(lTag.PollFrequencyHz));
    end;
    lLines.AddStrings(lSourceTags);
    Result := lLines.Text;
  finally
    lSourceTags.Free;
    lLines.Free;
  end;
end;

initialization
  InitCriticalSection(gAppliedSignatureLock);

finalization
  EnterCriticalSection(gAppliedSignatureLock);
  try
    FreeAndNil(gAppliedSourceSignatures);
  finally
    LeaveCriticalSection(gAppliedSignatureLock);
    DoneCriticalSection(gAppliedSignatureLock);
  end;

end.
