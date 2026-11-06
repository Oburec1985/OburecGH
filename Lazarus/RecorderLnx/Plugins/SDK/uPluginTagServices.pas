unit uPluginTagServices;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Общий каталог метаданных тегов для плагинов RLNX. Сведения получаются
  через сервисы хоста; модуль не зависит от классов RecorderLnx и конкретного
  компонента. Он не является полной реализацией cTag оригинального Recorder:
  буферизация, привязка и обработка сигналов остаются у потребителя. }
interface

uses uRecorderVisualComponentApiV2;

type
  TPluginTagMeta = record
    Id, Flags: QWord;
    Name, UnitName, Address, Description: UTF8String;
    PollFrequencyHz, RangeMin, RangeMax: Double;
  end;
  TPluginTagCatalog = array of TPluginTagMeta;

function PluginTagServicesAvailable(AServices: PRecorderVisualHostServicesV2): Boolean;
function LoadPluginTagCatalog(AServices: PRecorderVisualHostServicesV2;
  out ACatalog: TPluginTagCatalog): LongInt;

implementation

function PluginTagServicesAvailable(AServices: PRecorderVisualHostServicesV2): Boolean;
begin
  Result := (AServices <> nil);
  if not Result then Exit;
  Result := (AServices^.Header.Size >= PtrUInt(@AServices^.CopyLatestHistory) -
    PtrUInt(AServices) + SizeOf(AServices^.CopyLatestHistory))
    and (AServices^.Header.AbiMajor = REC_VISUAL_ABI_V2_MAJOR);
  if not Result then Exit;
  Result := Assigned(AServices^.EnumerateTags) and
    Assigned(AServices^.CopyLatestHistory);
end;

function FixedUtf8(AText: PAnsiChar; ACapacity: SizeInt): UTF8String;
var lLength: SizeInt;
begin
  lLength := 0;
  while (lLength < ACapacity) and (AText[lLength] <> #0) do Inc(lLength);
  SetString(Result, AText, lLength);
end;

function LoadPluginTagCatalog(AServices: PRecorderVisualHostServicesV2;
  out ACatalog: TPluginTagCatalog): LongInt;
var lInfo: TRecorderVisualTagInfoV2; lIndex: LongWord; lMeta: TPluginTagMeta;
begin
  ACatalog := nil;
  if not PluginTagServicesAvailable(AServices) then Exit(REC_VISUAL_NOT_HANDLED);
  lIndex := 0;
  repeat
    lInfo := Default(TRecorderVisualTagInfoV2);
    lInfo.Header.Size := SizeOf(lInfo);
    lInfo.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
    lInfo.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
    Result := AServices^.EnumerateTags(AServices^.Context, lIndex, @lInfo);
    if Result = REC_VISUAL_END_OF_ENUMERATION then Exit(REC_VISUAL_OK);
    if Result <> REC_VISUAL_OK then begin ACatalog := nil; Exit; end;
    if (lInfo.Header.Size < SizeOf(lInfo)) or
      (lInfo.Header.AbiMajor <> REC_VISUAL_ABI_V2_MAJOR) or (lInfo.TagId = 0) then
    begin ACatalog := nil; Exit(REC_VISUAL_ERROR); end;
    lMeta.Id := lInfo.TagId; lMeta.Flags := lInfo.Flags;
    lMeta.PollFrequencyHz := lInfo.PollFrequencyHz;
    lMeta.RangeMin := lInfo.RangeMin; lMeta.RangeMax := lInfo.RangeMax;
    lMeta.Name := FixedUtf8(@lInfo.Name[0], SizeOf(lInfo.Name));
    lMeta.UnitName := FixedUtf8(@lInfo.UnitName[0], SizeOf(lInfo.UnitName));
    lMeta.Address := FixedUtf8(@lInfo.Address[0], SizeOf(lInfo.Address));
    lMeta.Description := FixedUtf8(@lInfo.Description[0], SizeOf(lInfo.Description));
    SetLength(ACatalog, lIndex + 1); ACatalog[lIndex] := lMeta;
    Inc(lIndex);
  until lIndex = 65536;
  ACatalog := nil; Result := REC_VISUAL_ERROR;
end;

end.
