unit UModbusRTUClient;

interface

uses Windows, Classes, SysUtils, Generics.Collections, UnitPort, tags, UCommon;

type

  TModbusRTUClient = class(TObject)
  private
    fOnRcvData: TDataEvent;
    fResponseSent: TDataEvent;
    fConnect: TNotifyEvent;
    fDisconnect: TNotifyEvent;

    fRcvData: TBytes; // Последние принятые данные
    fSenData: TBytes; // Последние отправленные данные
    fAdr: byte; // ModBus адрес устройства
    fActive: boolean; // Сервер активен/неактивен
    fPortStateChanged: TNotifyEvent;
    fPort: TComPort;
    fCurrentChannel: byte;
    fTagList: TList<ITag>; // Список тэгов рекордера предназначенных для приема

    function CheckAddress(command: TBytes): boolean;
    function CheckCRC(command: TBytes): boolean;
    // Проверка контрольной суммы ответа
    function GetCRC(command: TBytes): word; // Расчет полинома
    procedure DoDataRcv(RcvData: TBytes);
    procedure SetTagList(tags: DynTagsArray);
    function FormatSingle(value: single): TBytes;
    procedure DoResponseSent(data: TBytes);
    procedure DoRcvData(data: TBytes);
    function InverseWord(reg: word; flag: boolean = true): word;
    function GetPort: TComPort;
    procedure PortDataRx(Sender: TObject);
    function GetAddress: byte;
    procedure SetAddress(const value: byte);
    procedure PortStateChanged(Sender: TObject);
    procedure DoPortStateChanged;
    function FormatSingleBack(value: PByte): single;

  public
    procedure SetTags(tags: DynTagsArray);
    constructor Create;
    destructor Destroy; override;
    property ComPort: TComPort read GetPort;
    function PortDataToStr(data: TBytes): string;
    property OnSentData: TDataEvent read fResponseSent write fResponseSent;
    property OnRcvData: TDataEvent read fOnRcvData write fOnRcvData;
    property Address: byte read GetAddress write SetAddress;
    property OnPortStateChanged: TNotifyEvent read fPortStateChanged write fPortStateChanged;
  end;

implementation

{ TModbusRTU Client }

constructor TModbusRTUClient.Create;
begin
  fTagList := TList<ITag>.Create;
  fAdr := 1;

  fPort := TComPort.Create;
  fPort.Speed := 19200;
  fPort.ByteSize := 8;
  fPort.StopBits := ONESTOPBIT;
  fPort.Parity := NOPARITY;
  fPort.Port := 'COM1';
  fPort.OnRecieve := PortDataRx;
  fPort.OnOpen := PortStateChanged;
  fPort.OnClose := PortStateChanged;
end;

destructor TModbusRTUClient.Destroy;
var
  i: integer;
begin
  FreeAndNil(fPort);
  for i := 0 to fTagList.Count - 1 do
    fTagList.Items[i] := nil;
  FreeAndNil(fTagList);
  inherited;
end;

procedure TModbusRTUClient.PortStateChanged(Sender: TObject);
begin
  DoPortStateChanged;
end;

procedure TModbusRTUClient.DoPortStateChanged;
begin
  if Assigned(fPortStateChanged) then
    fPortStateChanged(self);
end;

procedure TModbusRTUClient.SetAddress(const value: byte);
begin
  fAdr := value;
end;

procedure TModbusRTUClient.SetTagList(tags: DynTagsArray);
var
  i: integer;
begin
  for i := 0 to length(tags) - 1 do
  begin
    fTagList.Add(tags[i]);
  end;
end;

procedure TModbusRTUClient.SetTags(tags: DynTagsArray);
var
  i: integer;
begin
  for i := 0 to fTagList.Count - 1 do
    fTagList.Items[i] := nil;
  fTagList.Clear;

  for i := 0 to length(tags) - 1 do
    fTagList.Add(tags[i]);
end;

procedure TModbusRTUClient.DoDataRcv(RcvData: TBytes);
begin
  if Assigned(fOnRcvData) then
    fOnRcvData(self, RcvData);
end;

function TModbusRTUClient.CheckAddress(command: TBytes): boolean;
begin
  if length(command) > 0 then
    result := command[0] = fAdr
  else
    result := false;
end;

// Вычисление контрольной суммы Modbus RTU
function TModbusRTUClient.GetCRC(command: TBytes): word;
var
  n: word;
  i, m: word;
begin
  n := $FFFF;
  for m := 0 to high(command) do
  begin
    n := command[m] xor n;
    for i := 0 to 7 do
    begin
      if (n and $0001) = 1 then
        n := (n shr 1) xor $A001
      else
        n := (n shr 1);
    end;
  end;
  result := n;
end;

function TModbusRTUClient.GetPort: TComPort;
begin
  result := fPort;
end;

procedure TModbusRTUClient.DoRcvData(data: TBytes);
begin
  if Assigned(fRcvData) then
    fResponseSent(self, data);
end;

procedure TModbusRTUClient.DoResponseSent(data: TBytes);
begin
  if Assigned(fResponseSent) then
    fResponseSent(self, data);
end;

function TModbusRTUClient.PortDataToStr(data: TBytes): string;
var
  i: integer;
  out_str: string;
begin
  out_str := '';
  for i := 0 to length(data) - 1 do
    out_str := out_str + ' ' + IntToHex(data[i], 2);
  result := out_str;
end;

procedure TModbusRTUClient.PortDataRx(Sender: TObject);
var
  leng: integer;
begin
  leng := length(fPort.RcvBuf);
  SetLength(fRcvData, leng);
  move(fPort.RcvBuf[0], fRcvData[0], leng);

  DoDataRcv(fRcvData);
end;
// ==============================================================================

// Меняем местами старший и младший байт регистра в случае если flag = true
function TModbusRTUClient.InverseWord(reg: word; flag: boolean = true): word;
var
  b1: byte;
  b2: byte;
  out_v: word;
begin
  if not flag then
  begin
    result := reg;
    exit;
  end;

  b1 := PByte(@reg)^;
  b2 := (PByte(@reg) + 1)^;
  out_v := (b1 shl 8) or b2;
  result := out_v;
end;

function TModbusRTUClient.GetAddress: byte;
begin
  result := fAdr;
end;

function TModbusRTUClient.FormatSingle(value: single): TBytes;
var
  outbuf: TBytes;
begin
  SetLength(outbuf, 4);

  outbuf[0] := PByte(PByte(@value) + 1)^;
  outbuf[1] := PByte(@value)^;
  outbuf[2] := PByte(PByte(@value) + 3)^;
  outbuf[3] := PByte(PByte(@value) + 2)^;

  result := outbuf;
end;

function TModbusRTUClient.FormatSingleBack(value: PByte): single;
var
  outbuf: TBytes;
  output: single;
begin
  SetLength(outbuf, 4);

  outbuf[0] := (value + 1)^;
  outbuf[1] := value^;
  outbuf[2] := (value + 3)^;
  outbuf[3] := (value + 2)^;

  move(value, output, 4);
  result := output;
end;

function TModbusRTUClient.CheckCRC(command: TBytes): boolean;
var
  buf: TBytes;
  crc1, crc2: word;
begin
  if length(command) < 3 then
  begin
    result := false;
    exit;
  end;

  SetLength(buf, length(command) - 2);
  move(command[0], buf[0], length(command) - 2);
  crc1 := GetCRC(buf); // считаем CRC полученной команды

  crc2 := $00;
  crc2 := (command[ high(command)] shl 8) or command[ high(command) - 1];

  result := crc1 = crc2;
end;

end.
