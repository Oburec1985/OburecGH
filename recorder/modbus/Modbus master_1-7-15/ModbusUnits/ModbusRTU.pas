unit ModbusRTU;

interface
uses Classes, SysUtils, UnitPort, ModbusDevice;

type
TModbusRTUDevice = class(TModbusDevice)
  private
  fPort: TComport;
  public
  constructor Create(Parent: TBus; Address: Byte = 1); override;
  destructor Destroy; override;
end;

implementation

{ TModbusRTUDevice }

constructor TModbusRTUDevice.Create(Parent: TBus; Address: Byte);
begin
  inherited;
end;

destructor TModbusRTUDevice.Destroy;
begin
  inherited;
end;

end.
