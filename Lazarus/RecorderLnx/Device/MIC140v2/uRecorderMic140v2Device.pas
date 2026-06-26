unit uRecorderMic140v2Device;

{
  Драйвер прибора MIC-140 (версия 2) для слоя IRecorderDevice.

  Назначение
  ----------
  Управление жизненным циклом прибора: установка TCP-связи, идентификация,
  запись циклограммы скана в контроллер MC031, запуск/останов опроса, выдача
  блоков отсчётов источнику данных. Не публикует теги и не знает про UI.

  Этапы работы (наружу — TRecorderDeviceState, внутри — TMic140v2DriverPhase):
    отключён → подключён → запрограммирован → идёт опрос.

  Параметры (IP, порт, частота, число каналов) задаются через свойства до
  ProgramDevice / Start, не аргументами Connect.

  Основные правила при разработке этого модуля
  --------------------------------------------
  1. Разбор TCP: при неверном sync или контрольной сумме MDP сдвиг потока на
     один байт до синхрослова 0x12B8 (см. uRecorderMic140LegacyProtocol.ReadPacket).
  2. Верный заголовок кадра и «мусор» в отсчётах АЦП — в первую очередь
     проверять настройку коммутатора/FIFO/циклограммы, а не только resync.
     Такие блоки не отдавать в теги (Mic140LegacyRawBlockLooksCorrupt).
  3. Поток чтения и поток разбора разделяются кольцом заранее выделенных слотов
     TMic140RawBlockRing — без длительной блокировки на копировании payload.
  4. В режиме опроса поток чтения делает один интервал ожидания на итерацию
     (AcquirePacingMs из TRecorderAcquirePhaseFsm / TRecorderMic140AcquireTiming).
     Лишние Sleep в цикле опроса не добавлять.
  5. Connect / Program / Start / Stop вызываются из потока источника данных,
     не из GUI. Блокирующее чтение сокета в UI не выполнять.
  6. TIn и компенсация холодного спая — внутри драйвера MIC-140, не в
     TRecorderAcquisitionBlock (см. TMic140AuxTemperatureBlock в legacy).

  Текущий статус: каркас этапов и свойств; обмен TCP и worker-потоки — TODO.

  Документация:
    Docs/devices/mic140/protocol.md
    Docs/devices/mic140/acquisition_rules.md
    Docs/devices/migration_mic140v2.md
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants,
  uRecorderDeviceInterfaces,
  uRecorderMic140v2Types;

type
  { Ошибка: запрошенная возможность ещё не реализована в v2. }
  EMic140v2NotImplemented = class(ERecorderDeviceError);

  {
    Реализация IRecorderDevice для MIC-140 v2.

    Один экземпляр на источник данных; владеет параметрами связи, списком
    логических каналов и текущим этапом работы с прибором.
  }
  TRecorderMic140v2Device = class(TInterfacedObject, IRecorderDevice)
  private
    fParams: TMic140v2CreateParams;       { IP, порт, частота, период блока UI }
    fChannels: TRecorderDeviceChannelArray; { кэш имён/адресов каналов для GetChannels }
    fPhase: TMic140v2DriverPhase;           { подсостояние внутри этапа (rdpStateWord) }
    fState: TRecorderDeviceState;           { этап, видимый источнику данных }
    fLastError: string;                     { текст последней ошибки для диагностики }

    { Смена внутреннего подсостояния с записью в лог. }
    procedure SetPhase(APhase: TMic140v2DriverPhase);
    { Пересборка fChannels после смены числа каналов или частоты опроса. }
    procedure RebuildChannels;

    { --- реализация IRecorderDevice --- }
    function GetDeviceId: string;
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;
    { Чтение параметра прибора по идентификатору rdp* (аналог GetDeviceProperty оригинала). }
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer): Variant;
    { Запись параметра до старта опроса; во время опроса изменения отклоняются. }
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer): Boolean;
  public
    { Создание из полной структуры параметров. }
    constructor Create(const AParams: TMic140v2CreateParams); overload;
    { Создание с отдельными полями (удобно для источника данных). }
    constructor Create(const ADeviceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double;
      AUpdateTimeMs: Cardinal); overload;

    { Установка TCP и идентификация прибора (CMD_REPLY). → rdsConnected }
    procedure Connect;
    { Останов опроса (если был), закрытие связи. → rdsDisconnected }
    procedure Disconnect;
    { Запись циклограммы и дескрипторов скана в DM контроллера. → rdsProgrammed }
    procedure ProgramDevice;
    { Запуск опроса (CMD_STARTSCANMAIN) и worker-потоков приёма. → rdsStarted }
    procedure Start;
    { Останов опроса (CMD_STOPSCANMAIN), без разрыва TCP. → rdsProgrammed }
    procedure Stop;
    {
      Временный опрос одного блока (наследие legacy).
      В v2 целевой путь — передача готового блока источнику из потока разбора;
      этот метод остаётся заглушкой до переключения источника данных.
    }
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderAcquisitionBlock): Boolean;

    property Phase: TMic140v2DriverPhase read fPhase;
    property LastError: string read fLastError;
  end;

{ Фабрика: возвращает интерфейс IRecorderDevice для подключения в источник данных. }
function CreateRecorderMic140v2Device(const AParams: TMic140v2CreateParams): IRecorderDevice;

implementation

uses
  uRecorderDebugLog,
  uRecorderMic140Utils;

{ Запись строки в общий отладочный лог с префиксом MIC140v2. }
procedure Mic140v2Log(const AMessage: string);
begin
  RecorderDebugLog('[MIC140v2] ' + AMessage);
end;

constructor TRecorderMic140v2Device.Create(const AParams: TMic140v2CreateParams);
begin
  inherited Create;
  fParams := AParams;
  fPhase := mv2Idle;
  fState := rdsDisconnected;
  RebuildChannels;
end;

constructor TRecorderMic140v2Device.Create(const ADeviceId, AHost: string;
  APort: Word; AChannelCount: Integer; APollFrequencyHz: Double;
  AUpdateTimeMs: Cardinal);
var
  lParams: TMic140v2CreateParams;
begin
  lParams := Mic140v2DefaultCreateParams(ADeviceId, AHost);
  lParams.Port := APort;
  lParams.ChannelCount := AChannelCount;
  lParams.PollFrequencyHz := APollFrequencyHz;
  lParams.UpdateTimeMs := AUpdateTimeMs;
  Create(lParams);
end;

procedure TRecorderMic140v2Device.SetPhase(APhase: TMic140v2DriverPhase);
begin
  if fPhase = APhase then
    Exit;
  fPhase := APhase;
  Mic140v2Log(Format('фаза: %s', [Mic140v2PhaseToText(fPhase)]));
end;

procedure TRecorderMic140v2Device.RebuildChannels;
var
  I: Integer;
begin
  SetLength(fChannels, fParams.ChannelCount);
  for I := 0 to fParams.ChannelCount - 1 do
  begin
    fChannels[I].Name := RecorderMic140ChannelTagName(MIC140DefaultNodeNumber, I + 1);
    fChannels[I].Address := Format('%d-%2.2d', [MIC140DefaultNodeNumber, I + 1]);
    fChannels[I].UnitName := '';
    fChannels[I].ModuleType := 'MIC-140';
    fChannels[I].PollFrequencyHz := fParams.PollFrequencyHz;
    fChannels[I].Enabled := True;
  end;
end;

function TRecorderMic140v2Device.GetDeviceId: string;
begin
  Result := fParams.DeviceId;
end;

function TRecorderMic140v2Device.GetName: string;
begin
  Result := Format('MIC-140v2 %s:%d', [fParams.Host, fParams.Port]);
end;

function TRecorderMic140v2Device.GetState: TRecorderDeviceState;
begin
  Result := fState;
end;

function TRecorderMic140v2Device.GetChannels: TRecorderDeviceChannelArray;
begin
  { Копия массива — вызывающий не должен менять внутренний кэш драйвера. }
  Result := Copy(fChannels, 0, Length(fChannels));
end;

function TRecorderMic140v2Device.GetDeviceProperty(AProperty: TRecorderDeviceProperty;
  AIndex: Integer): Variant;
begin
  case AProperty of
    rdpName: Result := GetName;
    rdpHost: Result := fParams.Host;
    rdpPort: Result := Integer(fParams.Port);
    rdpPollFrequencyHz: Result := fParams.PollFrequencyHz;
    rdpUpdateTimeMs: Result := Integer(fParams.UpdateTimeMs);
    rdpChannelCount: Result := fParams.ChannelCount;
    rdpStateWord: Result := Ord(fPhase);
    rdpErrorCode: Result := Ord(fPhase = mv2Error);
    rdpErrorText: Result := fLastError;
  else
    Result := Null;
  end;
end;

function TRecorderMic140v2Device.TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
  const AValue: Variant; AIndex: Integer): Boolean;
var
  lNum: Double;
begin
  Result := False;
  { Во время опроса менять IP/частоту нельзя — нужен Stop и повторная настройка. }
  if fState = rdsStarted then
    Exit;
  case AProperty of
    rdpHost:
      if VarIsStr(AValue) or VarIsType(AValue, varUString) then
      begin
        fParams.Host := string(AValue);
        Exit(True);
      end;
    rdpPort:
      if VarIsNumeric(AValue) then
      begin
        lNum := AValue;
        fParams.Port := Word(Trunc(lNum));
        Exit(True);
      end;
    rdpPollFrequencyHz:
      if VarIsNumeric(AValue) then
      begin
        fParams.PollFrequencyHz := Double(AValue);
        RebuildChannels;
        Exit(True);
      end;
    rdpUpdateTimeMs:
      if VarIsNumeric(AValue) then
      begin
        lNum := AValue;
        fParams.UpdateTimeMs := Cardinal(Trunc(lNum));
        Exit(True);
      end;
    rdpChannelCount:
      if VarIsNumeric(AValue) then
      begin
        lNum := AValue;
        if Trunc(lNum) > 0 then
        begin
          fParams.ChannelCount := Trunc(lNum);
          RebuildChannels;
          Exit(True);
        end;
      end;
  end;
end;

procedure TRecorderMic140v2Device.Connect;
begin
  if fState <> rdsDisconnected then
    Exit;
  fLastError := '';
  SetPhase(mv2TcpConnecting);
  { TODO: TCP :4000, затем CMD_REPLY — uRecorderMic140LegacyProtocol }
  SetPhase(mv2Identifying);
  fState := rdsConnected;
  SetPhase(mv2Idle);
  Mic140v2Log(Format('Connect %s:%d (каркас, без обмена)', [fParams.Host, fParams.Port]));
end;

procedure TRecorderMic140v2Device.Disconnect;
begin
  if fState = rdsStarted then
    Stop;
  { TODO: закрытие сокета transport }
  fState := rdsDisconnected;
  SetPhase(mv2Idle);
  fLastError := '';
  Mic140v2Log('Disconnect');
end;

procedure TRecorderMic140v2Device.ProgramDevice;
begin
  if fState = rdsDisconnected then
    Connect;
  if fState <> rdsConnected then
    raise ERecorderDeviceError.Create(
      'MIC140v2: программирование возможно только после подключения');
  SetPhase(mv2Programming);
  { TODO: CMD_RESETSCANMAIN … CMD_SCAN_SET_CHANS, запись DM — protocol.md §2 }
  fState := rdsProgrammed;
  SetPhase(mv2Idle);
  Mic140v2Log('ProgramDevice (каркас)');
end;

procedure TRecorderMic140v2Device.Start;
begin
  if fState = rdsDisconnected then
  begin
    Connect;
    ProgramDevice;
  end
  else if fState = rdsConnected then
    ProgramDevice;
  if fState <> rdsProgrammed then
    raise ERecorderDeviceError.Create('MIC140v2: опрос возможен только после настройки');
  SetPhase(mv2ScanRunning);
  // TODO: CMD_STARTSCANMAIN, запуск read/publish workers, TMic140RawBlockRing
  fState := rdsStarted;
  Mic140v2Log('Start (каркас)');
end;

procedure TRecorderMic140v2Device.Stop;
begin
  if fState <> rdsStarted then
    Exit;
  // TODO: останов worker-потоков, CMD_STOPSCANMAIN
  fState := rdsProgrammed;
  SetPhase(mv2Idle);
  Mic140v2Log('Stop (каркас)');
end;

function TRecorderMic140v2Device.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderAcquisitionBlock): Boolean;
begin
  ClearRecorderAcquisitionBlock(ABlock);
  if fState <> rdsStarted then
    Exit(False);
  // Целевой v2: блоки из кольца в потоке разбора, не опрос отсюда.
  Result := False;
end;

function CreateRecorderMic140v2Device(const AParams: TMic140v2CreateParams): IRecorderDevice;
begin
  Result := TRecorderMic140v2Device.Create(AParams);
end;

end.
