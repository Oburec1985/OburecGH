unit UModbusValue;

interface
uses Windows, Classes, SysUtils, Generics.Collections, UnitPort, tags, UCommon;

type

TModbValueType = (mvtInt32, mvtWord, mvtSingle);
TModbCommand = (mc06, mc03, mc04);

TModbusValue<T> = class(TObject)
  private
  fName: string; //Наименование параметра
  fDescr: string; //Описание параметра
  fType: TModbValueType; //Тип параметра (целое или дробное)
  fCommandRead: TModbCommand;  //Команда для чтения значения из устройства
  fCommandWrite: TModbCommand; //Команда для записи значения в устройство
  fOffs: Word; //Смещение (адрес переменной)
  fParent: Pointer;    //Ссылка на класс клиента которому принадлежит значение
  fMultiplier: Single; //Множитель (в некоторых случаях значение в памяти устройства
                       //храниться в целых числах и для получения окончательного результата его следует домножить на
                       //определенный коэффициент)

  //Типа значения определяется на этапе создания
  fValue: T;

    function GetDescr: string;
    function GetMultiplier: Single;
    function GetName: string;
    function GetOffset: Word;
    function GetParent: Pointer;
    function GetValue: T;
    function GetValueType: TModbValueType;
    procedure SetDescr(const Value: string);
    procedure SetMultiplier(const Value: Single);
    procedure SetName(const Value: string);
    procedure SetOffset(const Value: Word);
    procedure SetParent(const Value: Pointer);
    procedure SetValue(const Value: T);
    procedure SetValueType(const Value: TModbValueType);
    function GetReadCommand: TModbCommand;
    function GetWriteCommand: TModbCommand;
    procedure SetReadCommand(const Value: TModbCommand);
    procedure SetWriteCommand(const Value: TModbCommand);
  public
  constructor Create(Typ: TModbValueType; CommandRead: TModbCommand; CommandWrite: TModbCommand); overload;
  constructor Create(inst: TModbusValue<T>); overload; //Копирующий конструктор, на вход получает ссылку на объект который надо скопировать
  destructor Destroy; override;

  property Name: string read GetName write SetName;
  property Description: string read GetDescr write SetDescr;
  property ValueType: TModbValueType read GetValueType write SetValueType;
  property Value: T read GetValue write SetValue;
  property Offset: Word read GetOffset write SetOffset;
  property Parent: Pointer read GetParent write SetParent;
  property Multiplier:Single read GetMultiplier write SetMultiplier;
  property ReadCommand: TModbCommand read GetReadCommand write SetReadCommand;
  property WriteCommand: TModbCommand read GetWriteCommand write SetWriteCommand;
end;

implementation

{ TModbusValue }

constructor TModbusValue<T>.Create(inst: TModbusValue<T>);
begin
  Create(inst.ValueType, inst.ReadCommand, inst.WriteCommand);

  self.Name := inst.Name;
  self.Description := inst.Description;
  self.Offset := inst.Offset;
  self.Parent := inst.Parent;
  self.Multiplier := inst.Multiplier;
  self.Value := inst.Value;
end;

constructor TModbusValue<T>.Create(Typ: TModbValueType; CommandRead,
  CommandWrite: TModbCommand);
begin
  inherited Create;

  self.Name := 'NewValue';
  self.Description := '';
  self.ValueType := Typ;
  self.ReadCommand := CommandRead;
  self.WriteCommand := CommandWrite;
  self.Multiplier := 1;
  self.Offset := 0;
end;

destructor TModbusValue<T>.Destroy;
begin
  inherited;
end;

function TModbusValue<T>.GetDescr: string;
begin
  result := fDescr;
end;

function TModbusValue<T>.GetMultiplier: Single;
begin
  result := fMultiplier;
end;

function TModbusValue<T>.GetName: string;
begin
  result := fName;
end;

function TModbusValue<T>.GetOffset: Word;
begin
  result := fOffs;
end;

function TModbusValue<T>.GetParent: Pointer;
begin
  result := fParent;
end;

function TModbusValue<T>.GetReadCommand: TModbCommand;
begin
  result := fCommandRead;
end;

function TModbusValue<T>.GetValue: T;
begin
  result := fValue;
end;

function TModbusValue<T>.GetValueType: TModbValueType;
begin
  result := fType;
end;

function TModbusValue<T>.GetWriteCommand: TModbCommand;
begin
  result := fCommandWrite;
end;

procedure TModbusValue<T>.SetDescr(const Value: string);
begin
  fDescr := Value;
end;

procedure TModbusValue<T>.SetMultiplier(const Value: Single);
begin
  fMultiplier := Value;
end;

procedure TModbusValue<T>.SetName(const Value: string);
begin
  fName := Value;
end;

procedure TModbusValue<T>.SetOffset(const Value: Word);
begin
  fOffs := Value;
end;

procedure TModbusValue<T>.SetParent(const Value: Pointer);
begin
  fParent := Value;
end;

procedure TModbusValue<T>.SetReadCommand(const Value: TModbCommand);
begin
  fCommandRead := Value;
end;

procedure TModbusValue<T>.SetValue(const Value: T);
begin
  fValue := Value;
end;

procedure TModbusValue<T>.SetValueType(const Value: TModbValueType);
begin
  fType := Value;
end;

procedure TModbusValue<T>.SetWriteCommand(const Value: TModbCommand);
begin
  fCommandWrite := Value;
end;

end.
