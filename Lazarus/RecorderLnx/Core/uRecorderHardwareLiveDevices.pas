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
procedure RecorderHardwareMarkSourceOffline(const ASourceId, AReason: string);
procedure RecorderHardwareClearSourceOffline(const ASourceId: string);
procedure RecorderHardwareClearAllOfflineSources;
function RecorderHardwareIsSourceOffline(const ASourceId: string): Boolean;
function RecorderHardwareSourceOfflineReason(const ASourceId: string): string;

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

  TRecorderHardwareOfflineEntry = class
  public
    SourceId: string;
    Reason: string;
  end;

var
  gHardwareLiveEntries: TThreadList;
  gHardwareOfflineEntries: TThreadList;

procedure RecorderHardwareEnsureRegistry;
begin
  if gHardwareLiveEntries = nil then
    gHardwareLiveEntries := TThreadList.Create;
  if gHardwareOfflineEntries = nil then
    gHardwareOfflineEntries := TThreadList.Create;
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

function RecorderHardwareFindOfflineEntry(const ASourceId: string;
  out AEntry: TRecorderHardwareOfflineEntry): Boolean;
var
  I: Integer;
  lEntry: TRecorderHardwareOfflineEntry;
  lList: TList;
begin
  Result := False;
  AEntry := nil;
  if (Trim(ASourceId) = '') or (gHardwareOfflineEntries = nil) then
    Exit;
  lList := gHardwareOfflineEntries.LockList;
  try
    for I := 0 to lList.Count - 1 do
    begin
      lEntry := TRecorderHardwareOfflineEntry(lList[I]);
      if SameText(lEntry.SourceId, ASourceId) then
      begin
        AEntry := lEntry;
        Exit(True);
      end;
    end;
  finally
    gHardwareOfflineEntries.UnlockList;
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
  RecorderHardwareClearSourceOffline(ASourceId);
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

procedure RecorderHardwareMarkSourceOffline(const ASourceId, AReason: string);
var
  lEntry: TRecorderHardwareOfflineEntry;
  lList: TList;
begin
  if Trim(ASourceId) = '' then
    Exit;
  RecorderHardwareEnsureRegistry;
  if RecorderHardwareFindOfflineEntry(ASourceId, lEntry) then
  begin
    lEntry.Reason := AReason;
    Exit;
  end;
  lEntry := TRecorderHardwareOfflineEntry.Create;
  lEntry.SourceId := Trim(ASourceId);
  lEntry.Reason := AReason;
  lList := gHardwareOfflineEntries.LockList;
  try
    lList.Add(lEntry);
  finally
    gHardwareOfflineEntries.UnlockList;
  end;
end;

procedure RecorderHardwareClearSourceOffline(const ASourceId: string);
var
  I: Integer;
  lEntry: TRecorderHardwareOfflineEntry;
  lList: TList;
begin
  if (Trim(ASourceId) = '') or (gHardwareOfflineEntries = nil) then
    Exit;
  lList := gHardwareOfflineEntries.LockList;
  try
    for I := lList.Count - 1 downto 0 do
    begin
      lEntry := TRecorderHardwareOfflineEntry(lList[I]);
      if SameText(lEntry.SourceId, ASourceId) then
      begin
        lEntry.Free;
        lList.Delete(I);
      end;
    end;
  finally
    gHardwareOfflineEntries.UnlockList;
  end;
end;

procedure RecorderHardwareClearAllOfflineSources;
var
  lList: TList;
begin
  if gHardwareOfflineEntries = nil then
    Exit;
  lList := gHardwareOfflineEntries.LockList;
  try
    while lList.Count > 0 do
    begin
      TRecorderHardwareOfflineEntry(lList[0]).Free;
      lList.Delete(0);
    end;
  finally
    gHardwareOfflineEntries.UnlockList;
  end;
end;

function RecorderHardwareIsSourceOffline(const ASourceId: string): Boolean;
var
  lEntry: TRecorderHardwareOfflineEntry;
begin
  Result := RecorderHardwareFindOfflineEntry(ASourceId, lEntry);
end;

function RecorderHardwareSourceOfflineReason(const ASourceId: string): string;
var
  lEntry: TRecorderHardwareOfflineEntry;
begin
  Result := '';
  if RecorderHardwareFindOfflineEntry(ASourceId, lEntry) then
    Result := lEntry.Reason;
end;

initialization
  { Реестры создаются до запуска подготовительных worker-потоков. Ленивое
    создание из нескольких PrepareHardware одновременно даёт гонку. }
  RecorderHardwareEnsureRegistry;

finalization
  if gHardwareLiveEntries <> nil then
  begin
    with gHardwareLiveEntries.LockList do
    try
      while Count > 0 do
      begin
        TRecorderHardwareLiveEntry(Items[0]).Free;
        Delete(0);
      end;
    finally
      gHardwareLiveEntries.UnlockList;
    end;
    FreeAndNil(gHardwareLiveEntries);
  end;
  if gHardwareOfflineEntries <> nil then
  begin
    with gHardwareOfflineEntries.LockList do
    try
      while Count > 0 do
      begin
        TRecorderHardwareOfflineEntry(Items[0]).Free;
        Delete(0);
      end;
    finally
      gHardwareOfflineEntries.UnlockList;
    end;
    FreeAndNil(gHardwareOfflineEntries);
  end;

end.
