unit uRecorderHardwareLiveDevices;

{
  Live hardware devices held by running data sources.
  UI checks link state via IRecorderDevice.TestLink on the existing session only.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderDeviceInterfaces;

procedure RecorderHardwareRegisterLiveDevice(AOwner: TObject;
  const ASourceId: string; ADevice: IRecorderDevice);
procedure RecorderHardwareUnregisterLiveDevice(AOwner: TObject);

function RecorderHardwareFindLiveDevice(const ASourceId: string): IRecorderDevice;
function RecorderHardwareIsSourceLinkOk(const ASourceId: string): Boolean;
function RecorderHardwareTestSourceLink(const ASourceId: string;
  out AErrorText: string): Boolean;

implementation

uses
  SyncObjs;

type
  TRecorderHardwareLiveEntry = class
  public
    SourceId: string;
    Device: IRecorderDevice;
    Owner: TObject;
  end;

var
  gHardwareLiveEntries: TThreadList;

procedure RecorderHardwareEnsureRegistry;
begin
  if gHardwareLiveEntries = nil then
    gHardwareLiveEntries := TThreadList.Create;
end;

function RecorderHardwareFindEntry(const ASourceId: string;
  out AEntry: TRecorderHardwareLiveEntry): Boolean;
var
  I: Integer;
  lEntry: TRecorderHardwareLiveEntry;
  lList: TList;
begin
  Result := False;
  AEntry := nil;
  if (Trim(ASourceId) = '') or (gHardwareLiveEntries = nil) then
    Exit;
  lList := gHardwareLiveEntries.LockList;
  try
    for I := 0 to lList.Count - 1 do
    begin
      lEntry := TRecorderHardwareLiveEntry(lList[I]);
      if SameText(lEntry.SourceId, ASourceId) then
      begin
        AEntry := lEntry;
        Exit(True);
      end;
    end;
  finally
    gHardwareLiveEntries.UnlockList;
  end;
end;

procedure RecorderHardwareRegisterLiveDevice(AOwner: TObject;
  const ASourceId: string; ADevice: IRecorderDevice);
var
  lEntry: TRecorderHardwareLiveEntry;
  lList: TList;
begin
  if (AOwner = nil) or (ADevice = nil) or (Trim(ASourceId) = '') then
    Exit;
  RecorderHardwareEnsureRegistry;
  RecorderHardwareUnregisterLiveDevice(AOwner);
  lEntry := TRecorderHardwareLiveEntry.Create;
  lEntry.SourceId := Trim(ASourceId);
  lEntry.Device := ADevice;
  lEntry.Owner := AOwner;
  lList := gHardwareLiveEntries.LockList;
  try
    lList.Add(lEntry);
  finally
    gHardwareLiveEntries.UnlockList;
  end;
end;

procedure RecorderHardwareUnregisterLiveDevice(AOwner: TObject);
var
  I: Integer;
  lEntry: TRecorderHardwareLiveEntry;
  lList: TList;
begin
  if (AOwner = nil) or (gHardwareLiveEntries = nil) then
    Exit;
  lList := gHardwareLiveEntries.LockList;
  try
    for I := lList.Count - 1 downto 0 do
    begin
      lEntry := TRecorderHardwareLiveEntry(lList[I]);
      if lEntry.Owner = AOwner then
      begin
        lEntry.Free;
        lList.Delete(I);
      end;
    end;
  finally
    gHardwareLiveEntries.UnlockList;
  end;
end;

function RecorderHardwareFindLiveDevice(const ASourceId: string): IRecorderDevice;
var
  lEntry: TRecorderHardwareLiveEntry;
begin
  Result := nil;
  if RecorderHardwareFindEntry(ASourceId, lEntry) then
    Result := lEntry.Device;
end;

function RecorderHardwareTestSourceLink(const ASourceId: string;
  out AErrorText: string): Boolean;
var
  lDevice: IRecorderDevice;
begin
  Result := False;
  AErrorText := '';
  lDevice := RecorderHardwareFindLiveDevice(ASourceId);
  if lDevice = nil then
  begin
    AErrorText := 'No live device session for ' + ASourceId;
    Exit;
  end;
  Result := lDevice.TestLink(AErrorText);
end;

function RecorderHardwareIsSourceLinkOk(const ASourceId: string): Boolean;
var
  lErrorText: string;
begin
  Result := RecorderHardwareTestSourceLink(ASourceId, lErrorText);
end;

finalization
  if gHardwareLiveEntries <> nil then
  begin
    with gHardwareLiveEntries.LockList do
    try
      while Count > 0 do
        TRecorderHardwareLiveEntry(Items[0]).Free;
    finally
      gHardwareLiveEntries.UnlockList;
    end;
    gHardwareLiveEntries.Free;
  end;

end.
