unit uRecorderDeviceManager;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, uRecorderDeviceInterfaces;

type
  TRecorderDeviceSearchResult = record
    DeviceType: string;
    Host: string;
    Port: Integer;
  end;

  TRecorderDeviceFactory = function: IRecorderDevice;
  TRecorderDeviceSearch = function(out AResult: TRecorderDeviceSearchResult): Boolean;

  TRecorderDeviceRegistration = record
    DeviceType: string;
    DeviceName: string;
    Description: string;
    Creator: TRecorderDeviceFactory;
    Search: TRecorderDeviceSearch;
  end;

  TRecorderDeviceManager = class
  private
    fDevices: array of TRecorderDeviceRegistration;
  public
    procedure RegisterDeviceClass(const ADeviceType, ADeviceName,
      ADescription: string; ACreator: TRecorderDeviceFactory;
      ASearch: TRecorderDeviceSearch = nil);
    procedure RegisterDevice(const AInfo: TRecorderDeviceRegistration);
    function Search(const ADeviceType: string = ''): IRecorderDevice;
  end;

function RecorderDeviceManager: TRecorderDeviceManager;

implementation

var
  gRecorderDeviceManager: TRecorderDeviceManager = nil;

function RecorderDeviceManager: TRecorderDeviceManager;
begin
  if gRecorderDeviceManager = nil then
    gRecorderDeviceManager := TRecorderDeviceManager.Create;
  Result := gRecorderDeviceManager;
end;

procedure TRecorderDeviceManager.RegisterDeviceClass(const ADeviceType,
  ADeviceName, ADescription: string; ACreator: TRecorderDeviceFactory;
  ASearch: TRecorderDeviceSearch);
var
  lInfo: TRecorderDeviceRegistration;
begin
  lInfo.DeviceType := ADeviceType;
  lInfo.DeviceName := ADeviceName;
  lInfo.Description := ADescription;
  lInfo.Creator := ACreator;
  lInfo.Search := ASearch;
  RegisterDevice(lInfo);
end;

procedure TRecorderDeviceManager.RegisterDevice(
  const AInfo: TRecorderDeviceRegistration);
var
  lIndex: Integer;
begin
  for lIndex := 0 to High(fDevices) do
    if SameText(fDevices[lIndex].DeviceType, AInfo.DeviceType) then
    begin
      fDevices[lIndex] := AInfo;
      Exit;
    end;

  lIndex := Length(fDevices);
  SetLength(fDevices, lIndex + 1);
  fDevices[lIndex] := AInfo;
end;

function TRecorderDeviceManager.Search(const ADeviceType: string): IRecorderDevice;
var
  lIndex: Integer;
  lFound: TRecorderDeviceSearchResult;
begin
  Result := nil;
  for lIndex := 0 to High(fDevices) do
  begin
    if ((ADeviceType = '') or SameText(fDevices[lIndex].DeviceType, ADeviceType)) and
      Assigned(fDevices[lIndex].Creator) then
    begin
      lFound.DeviceType := '';
      lFound.Host := '';
      lFound.Port := 0;
      if Assigned(fDevices[lIndex].Search) then
      begin
        if not fDevices[lIndex].Search(lFound) then
          Exit(nil);
      end;
      Result := fDevices[lIndex].Creator();
      if lFound.Host <> '' then
        Result.TrySetDeviceProperty(rdpHost, lFound.Host);
      if lFound.Port > 0 then
        Result.TrySetDeviceProperty(rdpPort, lFound.Port);
      Exit;
    end;
  end;
end;

finalization
  FreeAndNil(gRecorderDeviceManager);

end.
