unit uRecorderHardwareTree;

{
  Абстракции дерева устройств в диалоге настроек.
  UI не должен знать о MeraFile / MIC140 / MIC185 — только sourceId и эти функции.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, ComCtrls, uRecorderTags, uMeraFile;

type
  TRecorderHardwareTreeEntry = record
    SourceId: string;
    NodeCaption: string;
    LinkOk: Boolean;
    HasLinkedTags: Boolean;
  end;
  TRecorderHardwareTreeEntries = array of TRecorderHardwareTreeEntry;

function RecorderMeraFileTagSourceId(const ADescriptorPath: string): string;
function RecorderMeraFileTagSourcePath(const ASourceId: string): string;
function RecorderMeraFilePathExists(const ASourceId: string): Boolean;
function RecorderMeraSourceIdsEquivalent(const ASourceIdA,
  ASourceIdB: string): Boolean;

function RecorderSignalConfiguredSourceId(ASignal: TMeraSignalInfo;
  const AMeraDescriptorSourceId: string): string;

function RecorderHardwareTreeNodeCaption(const ASourceId: string): string;
function RecorderHardwareSourceLinkOk(const ASourceId: string): Boolean;
function RecorderHardwareSourceHasLinkedTags(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Boolean;

procedure RecorderCollectHardwareTreeEntries(
  ATagRegistry: TRecorderTagRegistry;
  out AEntries: TRecorderHardwareTreeEntries);

procedure RecorderHardwareTreeBindSourceId(ANode: TTreeNode;
  const ASourceId: string);
function RecorderHardwareTreeSourceId(ANode: TTreeNode): string;
procedure RecorderHardwareTreeClearNodes(ATree: TTreeView);

implementation

uses
  uRecorderHardwareLiveDevices, uRecorderMic185DataSource,
  uRecorderConfiguredDataSources, uRecorderMic140Utils;

const
  CDeviceTreeProbeTimeoutMs = 1000;

function RecorderMeraFilePathExists(const ASourceId: string): Boolean;
var
  lPath: string;
begin
  lPath := RecorderMeraFileTagSourcePath(ASourceId);
  if lPath = '' then
    Exit(False);
  if FileExists(lPath) then
    Exit(True);
  Result := FileExists(ExpandFileName(lPath));
end;

function RecorderMeraSourceIdsEquivalent(const ASourceIdA,
  ASourceIdB: string): Boolean;
var
  lNormA: string;
  lNormB: string;
  lPathA: string;
  lPathB: string;
begin
  lNormA := RecorderNormalizeTagSourceId(ASourceIdA);
  lNormB := RecorderNormalizeTagSourceId(ASourceIdB);
  if SameText(lNormA, lNormB) then
    Exit(True);
  if not RecorderIsVirtualTagSource(lNormA) or
    not RecorderIsVirtualTagSource(lNormB) then
    Exit(False);
  lPathA := RecorderMeraFileTagSourcePath(lNormA);
  lPathB := RecorderMeraFileTagSourcePath(lNormB);
  if (lPathA = '') or (lPathB = '') then
    Exit(False);
  Result := SameText(ExpandFileName(lPathA), ExpandFileName(lPathB)) and
    RecorderMeraFilePathExists(lNormA);
end;

function RecorderMeraFileTagSourceId(const ADescriptorPath: string): string;
begin
  Result := CMeraTagSourcePrefix + ADescriptorPath;
end;

function RecorderMeraFileTagSourcePath(const ASourceId: string): string;
var
  lNorm: string;
begin
  Result := '';
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  if Pos(CMeraTagSourcePrefix, lNorm) <> 1 then
    Exit;
  Result := Trim(Copy(lNorm, Length(CMeraTagSourcePrefix) + 1, MaxInt));
end;

function RecorderSignalConfiguredSourceId(ASignal: TMeraSignalInfo;
  const AMeraDescriptorSourceId: string): string;
begin
  Result := '';
  if ASignal = nil then
    Exit;
  if RecorderIsHardwareTagSource(ASignal.FileName) then
    Exit(RecorderNormalizeTagSourceId(ASignal.FileName));
  if AMeraDescriptorSourceId <> '' then
    Exit(AMeraDescriptorSourceId);
end;

function RecorderHardwareTreeNodeCaption(const ASourceId: string): string;
var
  lNorm: string;
  lPath: string;
begin
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  if RecorderIsVirtualTagSource(lNorm) then
  begin
    lPath := RecorderMeraFileTagSourcePath(lNorm);
    if lPath <> '' then
      Exit('Mera File - ' + ExtractFileName(lPath));
    Exit('Mera File');
  end;
  Result := lNorm;
end;

function RecorderHardwareSourceLinkOk(const ASourceId: string): Boolean;
var
  lHost: string;
  lNorm: string;
  lPort: Word;
begin
  Result := False;
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  if lNorm = '' then
    Exit;
  if RecorderIsVirtualTagSource(lNorm) then
    Exit(RecorderMeraFilePathExists(lNorm));
  if RecorderIsHardwareMic185TagSource(lNorm) then
    Exit(RecorderMic185IsSourceLinkOk(lNorm));
  if RecorderIsHardwareMic140TagSource(lNorm) then
  begin
    if RecorderHardwareIsSourceLinkOk(lNorm) then
      Exit(True);
    if TryParseRecorderMic140SourceId(lNorm, lHost, lPort) then
      Exit(RecorderMic140TcpProbe(lHost, lPort, CDeviceTreeProbeTimeoutMs));
    Exit(False);
  end;
end;

function RecorderHardwareSourceHasLinkedTags(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Boolean;
var
  I: Integer;
  lNorm: string;
  lTag: TRecorderTag;
begin
  Result := False;
  if (ARegistry = nil) or (Trim(ASourceId) = '') then
    Exit;
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(RecorderNormalizeTagSourceId(lTag.SourceId), lNorm) then
      Exit(True);
    if RecorderMeraSourceIdsEquivalent(lTag.SourceId, ASourceId) then
      Exit(True);
  end;
end;

procedure RecorderCollectHardwareTreeEntries(
  ATagRegistry: TRecorderTagRegistry;
  out AEntries: TRecorderHardwareTreeEntries);
var
  I: Integer;
  lIds: TStringList;
  lEntry: TRecorderHardwareTreeEntry;
begin
  SetLength(AEntries, 0);
  if ATagRegistry = nil then
    Exit;

  lIds := TStringList.Create;
  try
    lIds.CaseSensitive := False;
    lIds.Sorted := False;
    RecorderEnumerateConfiguredSourceIds(ATagRegistry, lIds, True);

    SetLength(AEntries, lIds.Count);
    for I := 0 to lIds.Count - 1 do
    begin
      lEntry.SourceId := lIds[I];
      lEntry.NodeCaption := RecorderHardwareTreeNodeCaption(lEntry.SourceId);
      lEntry.LinkOk := RecorderHardwareSourceLinkOk(lEntry.SourceId);
      lEntry.HasLinkedTags := RecorderHardwareSourceHasLinkedTags(ATagRegistry,
        lEntry.SourceId);
      AEntries[I] := lEntry;
    end;
  finally
    lIds.Free;
  end;
end;

procedure RecorderHardwareTreeBindSourceId(ANode: TTreeNode;
  const ASourceId: string);
var
  lIdPtr: PString;
begin
  if ANode = nil then
    Exit;
  if ANode.Data <> nil then
  begin
    Dispose(PString(ANode.Data));
    ANode.Data := nil;
  end;
  if Trim(ASourceId) = '' then
    Exit;
  New(lIdPtr);
  lIdPtr^ := ASourceId;
  ANode.Data := lIdPtr;
end;

function RecorderHardwareTreeSourceId(ANode: TTreeNode): string;
begin
  Result := '';
  if (ANode = nil) or (ANode.Data = nil) then
    Exit;
  Result := PString(ANode.Data)^;
end;

procedure RecorderHardwareTreeClearNodeData(ANode: TTreeNode);
begin
  if (ANode = nil) or (ANode.Data = nil) then
    Exit;
  Dispose(PString(ANode.Data));
  ANode.Data := nil;
end;

procedure RecorderHardwareTreeClearNodes(ATree: TTreeView);
var
  I: Integer;
begin
  if (ATree = nil) or (ATree.Items = nil) then
    Exit;
  for I := 0 to ATree.Items.Count - 1 do
    RecorderHardwareTreeClearNodeData(ATree.Items[I]);
end;

end.
