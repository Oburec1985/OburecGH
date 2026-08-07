unit uRecorderDeviceSearchDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, CheckLst;

type
  TRecorderDiscoveredDevice = class
  public
    DeviceType: string;
    SourceId: string;
    SerialNumber: LongWord;
    AlreadyConfigured: Boolean;
  end;

  { Показывает общий результат поиска до открытия аппаратных редакторов. }
  TRecorderDeviceSearchDialog = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    lbDevices: TCheckListBox;
    lblHint: TLabel;
  private
    fDevices: TList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddDevice(const ADeviceType, ASourceId, ADisplayText: string;
      AAlreadyConfigured: Boolean; ASerialNumber: LongWord = 0);
    function DeviceCount: Integer;
    function DeviceAt(AIndex: Integer): TRecorderDiscoveredDevice;
    function DeviceChecked(AIndex: Integer): Boolean;
  end;

implementation

{$R *.lfm}

constructor TRecorderDeviceSearchDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fDevices := TList.Create;
end;

destructor TRecorderDeviceSearchDialog.Destroy;
var
  I: Integer;
begin
  for I := 0 to fDevices.Count - 1 do
    TObject(fDevices[I]).Free;
  fDevices.Free;
  inherited Destroy;
end;

procedure TRecorderDeviceSearchDialog.AddDevice(const ADeviceType, ASourceId,
  ADisplayText: string; AAlreadyConfigured: Boolean; ASerialNumber: LongWord);
var
  lDevice: TRecorderDiscoveredDevice;
  lIndex: Integer;
begin
  lDevice := TRecorderDiscoveredDevice.Create;
  lDevice.DeviceType := ADeviceType;
  lDevice.SourceId := ASourceId;
  lDevice.SerialNumber := ASerialNumber;
  lDevice.AlreadyConfigured := AAlreadyConfigured;
  fDevices.Add(lDevice);

  lIndex := lbDevices.Items.Add(ADisplayText);
  lbDevices.Checked[lIndex] := not AAlreadyConfigured;
end;

function TRecorderDeviceSearchDialog.DeviceCount: Integer;
begin
  Result := fDevices.Count;
end;

function TRecorderDeviceSearchDialog.DeviceAt(
  AIndex: Integer): TRecorderDiscoveredDevice;
begin
  Result := TRecorderDiscoveredDevice(fDevices[AIndex]);
end;

function TRecorderDeviceSearchDialog.DeviceChecked(AIndex: Integer): Boolean;
begin
  Result := lbDevices.Checked[AIndex];
end;

end.
