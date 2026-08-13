unit uRecorderHardwareTree;

{
  Абстракции дерева устройств в диалоге настроек.
  UI знает только sourceId и зарегистрированные generic link probes.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, ComCtrls, uRecorderTags, uMeraFile;

type
  TRecorderHardwareSourceLinkProbe = function(
    const ASourceId: string): Boolean;
  TRecorderHardwareTreeEntry = record
    SourceId: string;
    NodeCaption: string;
    Enabled: Boolean;
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

function RecorderHardwareTreeNodeCaption(ARegistry: TRecorderTagRegistry; const ASourceId: string): string;
function RecorderHardwareSourceLinkOk(const ASourceId: string): Boolean;
function RecorderHardwareSourceLinkOk(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Boolean;
procedure RecorderRegisterHardwareSourceLinkProbe(
  AProbe: TRecorderHardwareSourceLinkProbe);
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
  uRecorderHardwareLiveDevices, uRecorderConfiguredDataSources,
  uRecorderDeviceInterfaces, uRecorderMic140DeviceConfig, uRecorderMic140Utils;

const
  CRecorderHardwareSourceLinkProbeMax = 32;

var
  g_HardwareSourceLinkProbes: array[0..CRecorderHardwareSourceLinkProbeMax - 1]
    of TRecorderHardwareSourceLinkProbe;
  g_HardwareSourceLinkProbeCount: Integer = 0;

procedure RecorderRegisterHardwareSourceLinkProbe(
  AProbe: TRecorderHardwareSourceLinkProbe);
begin
  if not Assigned(AProbe) then
    Exit;
  if g_HardwareSourceLinkProbeCount >= CRecorderHardwareSourceLinkProbeMax then
    raise Exception.Create('Too many hardware source link probes');
  g_HardwareSourceLinkProbes[g_HardwareSourceLinkProbeCount] := AProbe;
  Inc(g_HardwareSourceLinkProbeCount);
end;

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

function RecorderHardwareTreeNodeCaption(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): string;
var
  lNorm: string;
  lPath: string;
  lConfig: TRecorderMic140SourceConfig;
begin
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  if RecorderIsVirtualTagSource(lNorm) then
  begin
    lPath := RecorderMeraFileTagSourcePath(lNorm);
    if lPath <> '' then
      Exit('Mera File - ' + ExtractFileName(lPath));
    Exit('Mera File');
  end;
  
  if RecorderIsHardwareMic140TagSource(lNorm) then
  begin
    lConfig := FindRecorderMic140DeviceConfig(ARegistry, lNorm);
    if lConfig <> nil then
      Exit(Format('MIC-140 (%s:%d)', [lConfig.Host, lConfig.Port]));
  end;
  
  Result := lNorm;
end;

function RecorderHardwareSourceLinkOk(const ASourceId: string): Boolean;
var
  I: Integer;
  lDevice: IRecorderDevice;
  lNorm: string;
begin
  Result := False;
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  if lNorm = '' then
    Exit;
  if RecorderIsVirtualTagSource(lNorm) then
    Exit(RecorderMeraFilePathExists(lNorm));
  lDevice := RecorderHardwareFindLiveDevice(lNorm);
  if (lDevice <> nil) and RecorderHardwareIsSourceLinkOk(lNorm) then
  begin
    RecorderHardwareClearSourceOffline(lNorm);
    Exit(True);
  end;
  { После ошибки рабочего протокола простой TCP probe не подтверждает
    исправность прибора. Снять ошибку может только живая сессия или reset. }
  if RecorderHardwareIsSourceOffline(lNorm) then
    Exit(False);
  if RecorderHardwareIsSourceLinkOk(lNorm) then
  begin
    RecorderHardwareClearSourceOffline(lNorm);
    Exit(True);
  end;
  for I := 0 to g_HardwareSourceLinkProbeCount - 1 do
    if g_HardwareSourceLinkProbes[I](lNorm) then
    begin
      RecorderHardwareClearSourceOffline(lNorm);
      Exit(True);
    end;
end;

function RecorderHardwareSourceLinkOk(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Boolean;
var
  lHost: string;
  lPort: Word;
begin
  { MIC-140: probe по mic140.host, не по IP внутри SourceId. }
  if RecorderIsHardwareMic140TagSource(ASourceId) and
    RecorderMic140ResolveEndpoint(ARegistry, ASourceId, lHost, lPort) then
  begin
    if RecorderHardwareIsSourceLinkOk(RecorderNormalizeTagSourceId(ASourceId)) then
    begin
      RecorderHardwareClearSourceOffline(ASourceId);
      Exit(True);
    end;
    Result := RecorderMic140TcpProbe(lHost, lPort, 1000);
    if Result then
      RecorderHardwareClearSourceOffline(ASourceId);
    Exit;
  end;
  Result := RecorderHardwareSourceLinkOk(ASourceId);
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
      lEntry.NodeCaption := RecorderHardwareTreeNodeCaption(ATagRegistry, lEntry.SourceId);
      lEntry.Enabled := RecorderConfiguredDataSourceEnabled(ATagRegistry,
        lEntry.SourceId);
      { Tree rebuilding is a GUI operation and must not synchronously probe
        every configured endpoint. Runtime/probe actions maintain the offline
        cache; a newly discovered source is considered available until an
        actual connection attempt reports otherwise. }
      if not lEntry.Enabled then
        lEntry.LinkOk := False
      else if RecorderIsVirtualTagSource(lEntry.SourceId) then
        lEntry.LinkOk := RecorderMeraFilePathExists(lEntry.SourceId)
      else
        lEntry.LinkOk := not RecorderHardwareIsSourceOffline(lEntry.SourceId);
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
