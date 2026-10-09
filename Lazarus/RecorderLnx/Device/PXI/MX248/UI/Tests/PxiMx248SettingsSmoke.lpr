program PxiMx248SettingsSmoke;

{
  Headless-friendly construction smoke for the MX-248 LCL settings editor.
  It verifies LFM loading, default schema validation and the single apply
  callback boundary. See Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, SysUtils,
  uRecorderDriverContractsV2, uRecorderPxiMx248SettingsService,
  uRecorderPxiMx248SettingsDialog, uRecorderPxiMx248Types;

type
  TApplyProbe = class(TInterfacedObject, IPxiMx248SettingsService)
  public
    CallCount: Integer;
    LastSourceId: string;
    LastChassis: Integer;
    LastSlot: Integer;
    LastProperties: string;
    function ApplyDraft(const ASourceId: string; AChassis, ASlot: Integer;
      const AProperties: string): TRecorderOperationResult;
    function Discover(out ADevices: TPxiMx248DiscoveredDevices):
      TRecorderOperationResult;
  end;

function TApplyProbe.ApplyDraft(const ASourceId: string; AChassis,
  ASlot: Integer; const AProperties: string): TRecorderOperationResult;
begin
  Inc(CallCount);
  LastSourceId := ASourceId;
  LastChassis := AChassis;
  LastSlot := ASlot;
  LastProperties := AProperties;
  Result := TRecorderOperationResult.Success;
end;

function TApplyProbe.Discover(out ADevices: TPxiMx248DiscoveredDevices):
  TRecorderOperationResult;
begin
  SetLength(ADevices, 1);
  ADevices[0].DeviceIndex := 0;
  ADevices[0].DeviceName := 'MX-248 PXI Card';
  ADevices[0].SerialNumber := 3253;
  ADevices[0].Revision := 524;
  ADevices[0].ChassisType := 1;
  ADevices[0].Chassis := 2;
  ADevices[0].Slot := 14;
  Result := TRecorderOperationResult.Success;
end;

procedure Require(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

var
  lDialog: TPxiMx248SettingsDialog;
  lError, lProperties: string;
  lProbe: TApplyProbe;
  lService: IPxiMx248SettingsService;
begin
  Application.Initialize;
  lProbe := TApplyProbe.Create;
  lService := lProbe;
  lDialog := TPxiMx248SettingsDialog.Create(nil);
  try
    lDialog.LoadDraft('', '', 2, 5, lService);
    Require(lDialog.ValidateDraft(lProperties, lError), lError);
    Require(Pos('sample-rate-hz=1000', lProperties) > 0,
      'Canonical default sample rate is missing');
    Require(Pos('device.type=', lProperties) = 0,
      'Read-only properties must not enter persisted apply packet');
    Require(lDialog.ApplyDraft(lError), lError);
    Require(lProbe.CallCount = 1, 'Apply callback count mismatch');
    Require(lProbe.LastSourceId = 'pxi-mx248:2:5', 'SourceId mismatch');
    Require((lProbe.LastChassis = 2) and (lProbe.LastSlot = 5),
      'PXI location mismatch');
    Require(Pos('channel.8.enabled=True', lProbe.LastProperties) > 0,
      'Eighth channel is missing');
    lDialog.DiscoverClick(nil);
    Require(lDialog.ApplyDraft(lError), lError);
    Require(lProbe.LastSourceId = 'pxi-mx248:2:14',
      'Discovered board must be proposed for linking');
    Require((lProbe.LastChassis = 2) and (lProbe.LastSlot = 14),
      'Discovered PXI route mismatch');
    WriteLn('RESULT PxiMx248SettingsSmoke passed');
  finally
    lDialog.Free;
    lService := nil;
  end;
end.
