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
    cbSelectAll: TCheckBox;
    lbDevices: TCheckListBox;
    lblHint: TLabel;
    procedure cbSelectAllChange(Sender: TObject);
    procedure lbDevicesClickCheck(Sender: TObject);
  private
    fDevices: TList;
    fUpdatingSelectAll: Boolean;
    procedure SetEligibleDevicesChecked(AValue: Boolean);
    procedure UpdateSelectAllState;
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
  lbDevices.ItemEnabled[lIndex] := not AAlreadyConfigured;
  UpdateSelectAllState;
end;

procedure TRecorderDeviceSearchDialog.SetEligibleDevicesChecked(AValue: Boolean);
var
  I: Integer;
begin
  for I := 0 to fDevices.Count - 1 do
    if not DeviceAt(I).AlreadyConfigured then
      lbDevices.Checked[I] := AValue;
end;

procedure TRecorderDeviceSearchDialog.UpdateSelectAllState;
var
  I: Integer;
  lCheckedCount: Integer;
  lEligibleCount: Integer;
begin
  lCheckedCount := 0;
  lEligibleCount := 0;
  for I := 0 to fDevices.Count - 1 do
    if not DeviceAt(I).AlreadyConfigured then
    begin
      Inc(lEligibleCount);
      if lbDevices.Checked[I] then
        Inc(lCheckedCount);
    end;

  fUpdatingSelectAll := True;
  try
    if (lEligibleCount = 0) or (lCheckedCount = 0) then
      cbSelectAll.State := cbUnchecked
    else if lCheckedCount = lEligibleCount then
      cbSelectAll.State := cbChecked
    else
      cbSelectAll.State := cbGrayed;
  finally
    fUpdatingSelectAll := False;
  end;
end;

procedure TRecorderDeviceSearchDialog.cbSelectAllChange(Sender: TObject);
begin
  if fUpdatingSelectAll then
    Exit;
  if cbSelectAll.State = cbGrayed then
  begin
    cbSelectAll.State := cbChecked;
    Exit;
  end;
  SetEligibleDevicesChecked(cbSelectAll.Checked);
  UpdateSelectAllState;
end;

procedure TRecorderDeviceSearchDialog.lbDevicesClickCheck(Sender: TObject);
begin
  UpdateSelectAllState;
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
