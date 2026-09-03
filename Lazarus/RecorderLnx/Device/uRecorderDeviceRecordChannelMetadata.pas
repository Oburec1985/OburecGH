unit uRecorderDeviceRecordChannelMetadata;

{
  Device-side implementation of record-channel metadata. Legacy address
  conventions are isolated here and never interpreted by forms or writers.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderRecordChannelMetadata;

function RecorderRecordChannelMetadataService:
  IRecorderRecordChannelMetadataService;

implementation

uses
  SysUtils, StrUtils, uRecorderTags;

type
  TRecorderDeviceRecordChannelMetadataService = class(TInterfacedObject,
    IRecorderRecordChannelMetadataService)
  private
    function IsMicSource(const ASourceId: string): Boolean;
    function IsUtsAddress(const AAddress: string): Boolean;
    function FindPairedUtsChannelName(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag): string;
  public
    function Resolve(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag): TRecorderRecordChannelMetadata;
  end;

var
  gService: IRecorderRecordChannelMetadataService;

function TRecorderDeviceRecordChannelMetadataService.IsMicSource(
  const ASourceId: string): Boolean;
var
  lSourceId: string;
begin
  { Project files may contain legacy/manual casing and surrounding spaces.
    Metadata recognition deliberately preserves the former UI semantics. }
  lSourceId := Trim(ASourceId);
  Result := StartsText('MIC-140:', lSourceId) or
    StartsText('MIC-185:', lSourceId);
end;

function TRecorderDeviceRecordChannelMetadataService.IsUtsAddress(
  const AAddress: string): Boolean;
begin
  Result := EndsText('-uts', Trim(AAddress));
end;

function TRecorderDeviceRecordChannelMetadataService.FindPairedUtsChannelName(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag): string;
var
  I: Integer;
  lCandidate: TRecorderTag;
begin
  Result := '';
  if (ARegistry = nil) or (ATag = nil) then
    Exit;

  { Only project-selected tags belong to TagRegistry. Discovered channels that
    are not selected therefore cannot leak into the MERA UTS_Channel link. }
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lCandidate := ARegistry.Tags[I];
    if (lCandidate <> nil) and
      SameText(Trim(lCandidate.SourceId), Trim(ATag.SourceId)) and
      IsUtsAddress(lCandidate.Address) then
      Exit(lCandidate.Name);
  end;
end;

function TRecorderDeviceRecordChannelMetadataService.Resolve(
  ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag): TRecorderRecordChannelMetadata;
begin
  Result.IsUts := False;
  Result.UtsChannelName := '';
  if (ATag = nil) or not IsMicSource(ATag.SourceId) then
    Exit;

  Result.IsUts := IsUtsAddress(ATag.Address);
  if not Result.IsUts then
    Result.UtsChannelName := FindPairedUtsChannelName(ARegistry, ATag);
end;

function RecorderRecordChannelMetadataService:
  IRecorderRecordChannelMetadataService;
begin
  if gService = nil then
    gService := TRecorderDeviceRecordChannelMetadataService.Create;
  Result := gService;
end;

finalization
  gService := nil;

end.
