unit uRecorderPxiMx248ConfiguredEditor;

{
  Composition adapter between the generic configured-source editor registry
  and the MX-248 offline settings dialog. It persists one validated canonical
  property packet; hardware I/O remains owned by the runtime datasource.

  Source ids use pxi-mx248:<chassis>:<slot>, where chassis is the DevAPI
  CrateSlot.CCSN and slot is CrateSlot.SlotNo. The bridge resolves this stable
  route after each discovery; discovery array order is never persisted.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

const
  CRecorderPxiMx248ModuleType = 'PXI MX-248';

function RecorderPxiMx248SourceId(AChassis, ASlot: Integer): string;
function TryParseRecorderPxiMx248SourceId(const ASourceId: string;
  out AChassis, ASlot: Integer): Boolean;

implementation

uses
  Classes, SysUtils, uRecorderTags, uRecorderDataSources,
  uRecorderConfiguredDataSources, uRecorderConfiguredSourceEditor,
  uRecorderDriverContractsV2, uRecorderPxiMx248SettingsService,
  uRecorderPxiMx248SettingsDialog, uRecorderPxiMx248Types,
  uRecorderPxiMx248WindowsTransport;

type
  TPxiMx248ConfiguredSettingsService = class(TInterfacedObject,
    IPxiMx248SettingsService)
  private
    fAppliedSourceId: string;
    fOldSourceId: string;
    fRegistry: TRecorderTagRegistry;
  public
    constructor Create(ARegistry: TRecorderTagRegistry;
      const AOldSourceId: string);
    function ApplyDraft(const ASourceId: string; AChassis, ASlot: Integer;
      const AProperties: string): TRecorderOperationResult;
    function Discover(out ADevices: TPxiMx248DiscoveredDevices):
      TRecorderOperationResult;
    property AppliedSourceId: string read fAppliedSourceId;
  end;

  TPxiMx248ConfiguredSourceEditor = class(TInterfacedObject,
    IRecorderConfiguredSourceEditor)
  public
    function SupportsSource(const ASourceId, AModuleType: string): Boolean;
    function EditSource(AOwner: TComponent; ARegistry: TRecorderTagRegistry;
      const ASourceId: string; out ANewSourceId: string;
      ADataSources: TRecorderDataSourceManager): Boolean;
  end;

function RecorderPxiMx248SourceId(AChassis, ASlot: Integer): string;
begin
  Result := Format('pxi-mx248:%d:%d', [AChassis, ASlot]);
end;

function TPxiMx248ConfiguredSettingsService.Discover(
  out ADevices: TPxiMx248DiscoveredDevices): TRecorderOperationResult;
begin
  Result := RecorderDiscoverPxiMx248(ADevices);
end;

function TryParseRecorderPxiMx248SourceId(const ASourceId: string;
  out AChassis, ASlot: Integer): Boolean;
var
  lItems: TStringList;
begin
  AChassis := 0;
  ASlot := 0;
  lItems := TStringList.Create;
  try
    lItems.StrictDelimiter := True;
    lItems.Delimiter := ':';
    lItems.DelimitedText := LowerCase(Trim(ASourceId));
    Result := (lItems.Count = 3) and (lItems[0] = 'pxi-mx248') and
      TryStrToInt(lItems[1], AChassis) and (AChassis >= 0) and
      TryStrToInt(lItems[2], ASlot) and (ASlot >= 0);
  finally
    lItems.Free;
  end;
end;

constructor TPxiMx248ConfiguredSettingsService.Create(
  ARegistry: TRecorderTagRegistry; const AOldSourceId: string);
begin
  inherited Create;
  fRegistry := ARegistry;
  fOldSourceId := AOldSourceId;
end;

function TPxiMx248ConfiguredSettingsService.ApplyDraft(const ASourceId: string;
  AChassis, ASlot: Integer; const AProperties: string):
  TRecorderOperationResult;
var
  I: Integer;
  lEntry: TRecorderConfiguredDataSource;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  if fRegistry = nil then
    Exit(TRecorderOperationResult.Failure(rocInvalidState,
      'mx248.settings.persist', 'Tag registry is not available'));
  lSourceId := RecorderPxiMx248SourceId(AChassis, ASlot);
  if not SameText(Trim(ASourceId), lSourceId) then
    Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
      'mx248.settings.source', 'Source ID must match chassis and slot'));
  if (fOldSourceId <> '') and not SameText(fOldSourceId, lSourceId) then
  begin
    { Route changes must preserve published tag objects and their user names,
      calibrations and references. Only the source binding is re-keyed. }
    for I := 0 to fRegistry.TagCount - 1 do
    begin
      lTag := fRegistry.Tags[I];
      if SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
        RecorderNormalizeTagSourceId(fOldSourceId)) then
        lTag.SourceId := lSourceId;
    end;
    RecorderConfiguredDataSourcesRemove(fRegistry, fOldSourceId);
  end;
  lEntry := RecorderConfiguredDataSourcesEnsure(fRegistry, lSourceId,
    CRecorderPxiMx248ModuleType);
  if lEntry = nil then
    Exit(TRecorderOperationResult.Failure(rocInternal,
      'mx248.settings.persist', 'Could not create configured source'));
  lEntry.SpecificConfigText := AProperties;
  lEntry.Enabled := True;
  fAppliedSourceId := lSourceId;
  Result := TRecorderOperationResult.Success;
end;

function TPxiMx248ConfiguredSourceEditor.SupportsSource(const ASourceId,
  AModuleType: string): Boolean;
var
  lChassis, lSlot: Integer;
begin
  Result := SameText(AModuleType, CRecorderPxiMx248ModuleType) or
    TryParseRecorderPxiMx248SourceId(ASourceId, lChassis, lSlot);
end;

function TPxiMx248ConfiguredSourceEditor.EditSource(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string; ADataSources: TRecorderDataSourceManager): Boolean;
var
  lChassis, lSlot: Integer;
  lEntry: TRecorderConfiguredDataSource;
  lProperties: string;
  lServiceObject: TPxiMx248ConfiguredSettingsService;
  lService: IPxiMx248SettingsService;
begin
  ANewSourceId := ASourceId;
  lChassis := 0;
  lSlot := 0;
  TryParseRecorderPxiMx248SourceId(ASourceId, lChassis, lSlot);
  lProperties := '';
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  if lEntry <> nil then lProperties := lEntry.SpecificConfigText;
  lServiceObject := TPxiMx248ConfiguredSettingsService.Create(ARegistry,
    ASourceId);
  lService := lServiceObject;
  Result := ShowPxiMx248SettingsDialog(AOwner, ASourceId, lProperties,
    lChassis, lSlot, lService);
  if Result then ANewSourceId := lServiceObject.AppliedSourceId;
  lService := nil;
end;

initialization
  RecorderRegisterConfiguredSourceEditor(TPxiMx248ConfiguredSourceEditor.Create);

end.
