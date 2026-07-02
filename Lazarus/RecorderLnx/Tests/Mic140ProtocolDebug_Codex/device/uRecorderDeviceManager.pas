unit uRecorderDeviceManager;

{$mode objfpc}{$H+}

interface
// класс регистратор устройств

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

  // Менеджер не реализует интерфейсы; ниже идут объектные методы регистрации и поиска.
  TRecorderDeviceManager = class
  private
    // список зареганых устройств
    { Поля объекта менеджера.
      Менеджер не реализует интерфейсы устройств; он только хранит регистрации. }
    fDevices: array of TRecorderDeviceRegistration;
  public
    { Объектные методы TRecorderDeviceManager.
      Они не являются методами IRecorderDevice: менеджер создает и возвращает
      интерфейсные ссылки на устройства, но сам устройством не является. }

    // Original Recorder: RegisterDeviceClass(DWORD reg_num, HANDLE hnd).
    procedure RegisterDeviceClass(const ADeviceType, ADeviceName,
      ADescription: string; ACreator: TRecorderDeviceFactory;
      ASearch: TRecorderDeviceSearch = nil);

    // Original Recorder: RegisterDevice(TDeviceEnum* info).
    procedure RegisterDevice(const AInfo: TRecorderDeviceRegistration);

    // Original Recorder search path: register_device_table + Creator.
    function Search(const ADeviceType: string = ''): IRecorderDevice;
  end;

function RecorderDeviceManager: TRecorderDeviceManager;

implementation

var
  // глобальная переменная менеджер устройств
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
        { Original Recorder: RegisterSearchDevice + hardware/interface scan. }
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
