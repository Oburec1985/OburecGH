unit uRecorderTimeSystem;

{
  Модуль uRecorderTimeSystem

  Назначение:
    Центральная модель времени для проекта RecorderLnx. Оригинальный регистратор (Recorder)
    может отображать несколько временных областей в строке состояния: системное время ПК,
    время, прошедшее с момента старта записи, аппаратное время канала/тега и время UTS.
    Этот модуль инкапсулирует логику выбора и форматирования времени независимо от LCL,
    позволяя UI запрашивать готовый снимок состояния (snapshot) для отрисовки.

  Архитектура:
    Ядро системы (Core/domain), кроссплатформенное и независимое от визуальных компонентов LCL.
    Текущая реализация хранит выбранный источник времени, момент старта, время последнего
    полученного тега и последнее время UTS. В дальнейшем класс может обновляться из
    выделенного потока или метаданных аппаратных источников.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DateUtils;

type
  { TRecorderTimeSourceKind
    Определяет временную область, отображаемую в статусной строке регистратора. }
  TRecorderTimeSourceKind = (
    rtskPcTime,        { Системное время ПК }
    rtskElapsedTime,   { Прошедшее время с момента запуска }
    rtskTagTime,       { Аппаратное время тега/канала }
    rtskUtsTime        { Время UTS }
  );

  { TRecorderTimeSnapshot
    Неизменяемый снимок состояния времени для отображения на форме.
    
    SourceKind       - выбранный источник времени для отображения.
    Running          - True, если процесс записи/сбора данных активен.
    StartLocalTime   - локальное время ПК в момент старта.
    ElapsedSec       - монотонно увеличивающееся прошедшее время в секундах с момента старта.
    LastTagTimeSec   - последнее известное время аппаратного тега в секундах.
    LastUtsTimeSec   - последнее известное время UTS в секундах.
    DisplayText      - готовая отформатированная строка для компактного показа в строке состояния. }
  TRecorderTimeSnapshot = record
    SourceKind: TRecorderTimeSourceKind;
    Running: Boolean;
    StartLocalTime: TDateTime;
    ElapsedSec: Double;
    LastTagTimeSec: Double;
    LastUtsTimeSec: Double;
    DisplayText: string;
  end;

  { TRecorderTimeSystem
    Класс управления политикой отображения времени в RecorderLnx.
    Все открытые методы защищены критической секцией fLock для обеспечения потокобезопасности,
    так как будущие рабочие потоки могут обновлять или читать данные параллельно с основным потоком UI. }
  TRecorderTimeSystem = class
  private
    fDisplayUpdateMs: Integer;       { Интервал обновления дисплея в мс }
    fLastTagTimeSec: Double;         { Время последнего тега }
    fLastUtsTimeSec: Double;         { Время последнего UTS }
    fLastUtsUpdateTickMs: QWord;      { Монотонный тик получения последнего UTS }
    fLock: TRTLCriticalSection;      { Критическая секция для защиты внутренних данных }
    fResetAtStart: Boolean;          { Флаг сброса внешних данных времени при старте }
    fRunning: Boolean;               { Флаг активности записи }
    fSourceKind: TRecorderTimeSourceKind; { Текущий выбранный источник времени }
    fStartLocalTime: TDateTime;      { Системное время старта }
    fStartUtcTime: TDateTime;        { Астрономическое UTC-время старта }
    fStartTickMs: QWord;             { Монотонное время старта в миллисекундах }
    
    function GetDisplayUpdateMs: Integer;
    function GetResetAtStart: Boolean;
    function GetSourceKind: TRecorderTimeSourceKind;
    procedure SetDisplayUpdateMs(AValue: Integer);
    procedure SetResetAtStart(AValue: Boolean);
    procedure SetSourceKind(AValue: TRecorderTimeSourceKind);
    function InternalElapsedSec(ANowTickMs: QWord): Double;
    function CurrentUtsDisplaySec(ANowTickMs: QWord): Double;
  public
    { Конструктор инициализирует критическую секцию и значения по умолчанию }
    constructor Create;
    { Деструктор корректно освобождает критическую секцию }
    destructor Destroy; override;

    { Запускает или перезапускает активный временной интервал.
      Фиксирует системное время ПК и монотонный счетчик тиков.
      Если ResetAtStart установлен в True, сбрасывает также последние внешние значения тега и UTS. }
    procedure Start;

    { Останавливает активный интервал, сохраняя последние измеренные значения времени. }
    procedure Stop;

    { Сбрасывает прошедшее время и внешние временные значения. }
    procedure Reset;

    { Обновляет внешние временные области на основе полученного тега или примера данных канала.
      ATagTimeSec - аппаратное время в секундах.
      AUtsTimeSec - время UTS в секундах; передайте отрицательное значение, если оно недоступно. }
    procedure UpdateFromTagSample(ATagTimeSec: Double; AUtsTimeSec: Double = -1);

    { Возвращает потокобезопасную копию состояния, отформатированную для строки статуса. }
    function Snapshot: TRecorderTimeSnapshot;

    { Переводит время канала в секундах от старта текущего сеанса в
      абсолютное астрономическое время UTC (TDateTime). }
    function ChannelTimeToUtc(AChannelTimeSec: Double): TDateTime;

    { Возвращает текущее UTC-время на монотонной шкале текущего сеанса. }
    function CurrentUtc: TDateTime;

    { Статический метод для форматирования секунд в строку вида ЧЧ:ММ:СС }
    class function FormatDuration(ASeconds: Double): string; static;

    { Свойства класса }
    property SourceKind: TRecorderTimeSourceKind read GetSourceKind write SetSourceKind;
    property ResetAtStart: Boolean read GetResetAtStart write SetResetAtStart;
    property DisplayUpdateMs: Integer read GetDisplayUpdateMs write SetDisplayUpdateMs;
  end;

implementation

const
  CDefaultDisplayUpdateMs = 100;
  CMsecsPerSec = 1000.0;

{ TRecorderTimeSystem }

{ TRecorderTimeSystem.Create
  Назначение:
    Конструктор класса TRecorderTimeSystem. Инициализирует критическую секцию защиты данных и устанавливает параметры обновления по умолчанию.
  Вызывается из:
    Вызывается при создании фасада TRecorder.
  Аналог в оригинальном Recorder:
    Инициализация подсистемы синхронизации времени оригинального Recorder. }
constructor TRecorderTimeSystem.Create;
begin
  inherited Create;
  InitCriticalSection(fLock);
  fDisplayUpdateMs := CDefaultDisplayUpdateMs;
  fResetAtStart := True;
  fSourceKind := rtskElapsedTime;
  Reset;
end;

{ TRecorderTimeSystem.Destroy
  Назначение:
    Деструктор класса TRecorderTimeSystem. Освобождает критическую секцию и ресурсы времени.
  Вызывается из:
    Вызывается при уничтожении фасада TRecorder.
  Аналог в оригинальном Recorder:
    Удаление объектов синхронизации времени в оригинальном Recorder. }
destructor TRecorderTimeSystem.Destroy;
begin
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

{ TRecorderTimeSystem.GetDisplayUpdateMs
  Назначение:
    Потокобезопасный геттер интервала обновления дисплея (в миллисекундах).
  Вызывается из:
    Вызывается UI-таймером обновления формы.
  Аналог в оригинальном Recorder:
    Вспомогательный метод. }
function TRecorderTimeSystem.GetDisplayUpdateMs: Integer;
begin
  EnterCriticalSection(fLock);
  try
    Result := fDisplayUpdateMs;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTimeSystem.GetResetAtStart
  Назначение:
    Потокобезопасный геттер флага сброса времени при запуске записи.
  Вызывается из:
    Вызывается при конфигурации запуска.
  Аналог в оригинальном Recorder:
    Вспомогательный метод. }
function TRecorderTimeSystem.GetResetAtStart: Boolean;
begin
  EnterCriticalSection(fLock);
  try
    Result := fResetAtStart;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTimeSystem.GetSourceKind
  Назначение:
    Потокобезопасный геттер текущего выбранного источника отображаемого времени (ПК, Elapsed, Tag, UTS).
  Вызывается из:
    Вызывается UI-слоем при форматировании времени в статус-баре.
  Аналог в оригинальном Recorder:
    Считывание режима отображения времени в строке состояния оригинального Recorder. }
function TRecorderTimeSystem.GetSourceKind: TRecorderTimeSourceKind;
begin
  EnterCriticalSection(fLock);
  try
    Result := fSourceKind;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTimeSystem.SetDisplayUpdateMs
  Назначение:
    Потокобезопасный сеттер интервала обновления дисплея с защитой от слишком малых значений (< 20 мс).
  Вызывается из:
    Вызывается при настройке частоты обновления UI.
  Аналог в оригинальном Recorder:
    Вспомогательный метод. }
procedure TRecorderTimeSystem.SetDisplayUpdateMs(AValue: Integer);
begin
  if AValue < 20 then
    AValue := 20;

  EnterCriticalSection(fLock);
  try
    fDisplayUpdateMs := AValue;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTimeSystem.SetResetAtStart
  Назначение:
    Потокобезопасный сеттер флага сброса времени при запуске.
  Вызывается из:
    Вызывается при настройке параметров запуска.
  Аналог в оригинальном Recorder:
    Вспомогательный метод. }
procedure TRecorderTimeSystem.SetResetAtStart(AValue: Boolean);
begin
  EnterCriticalSection(fLock);
  try
    fResetAtStart := AValue;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTimeSystem.SetSourceKind
  Назначение:
    Потокобезопасный сеттер текущего выбранного источника отображаемого времени.
  Вызывается из:
    Вызывается UI при переключении кликом по панели строки состояния.
  Аналог в оригинальном Recorder:
    Переключение режима отображения времени по клику в строке состояния оригинального Recorder. }
procedure TRecorderTimeSystem.SetSourceKind(AValue: TRecorderTimeSourceKind);
begin
  EnterCriticalSection(fLock);
  try
    fSourceKind := AValue;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTimeSystem.InternalElapsedSec
  Назначение:
    Вычисляет прошедшее время в секундах между текущим тиком ПК и тиком старта.
  Вызывается из:
    Внутренний вспомогательный метод, вызывается из Snapshot.
  Аналог в оригинальном Recorder:
    Соответствует расчету Elapsed Time в оригинальном Recorder. }
function TRecorderTimeSystem.InternalElapsedSec(ANowTickMs: QWord): Double;
begin
  if (not fRunning) or (fStartTickMs = 0) or (ANowTickMs < fStartTickMs) then
    Exit(0);

  Result := (ANowTickMs - fStartTickMs) / CMsecsPerSec;
end;

function TRecorderTimeSystem.CurrentUtsDisplaySec(ANowTickMs: QWord): Double;
begin
  Result := fLastUtsTimeSec;
  if (not fRunning) or (fLastUtsUpdateTickMs = 0) or
    (ANowTickMs < fLastUtsUpdateTickMs) then
    Exit;
  Result := Result + (ANowTickMs - fLastUtsUpdateTickMs) / CMsecsPerSec;
end;

{ TRecorderTimeSystem.Start
  Назначение:
    Потокобезопасно запускает отсчет времени записи/просмотра, фиксируя начальное время ПК и системные тики.
  Вызывается из:
    Вызывается при переходе автомата состояний в Preview или Record.
  Аналог в оригинальном Recorder:
    Синхронизировано с переходом ядра в активное состояние. }
procedure TRecorderTimeSystem.Start;
var
  lLocalNow: TDateTime;
begin
  lLocalNow := Now;
  EnterCriticalSection(fLock);
  try
    fRunning := True;
    fStartLocalTime := lLocalNow;
    fStartUtcTime := LocalTimeToUniversal(lLocalNow);
    fStartTickMs := GetTickCount64;
    if fResetAtStart then
    begin
      fLastTagTimeSec := 0;
      fLastUtsTimeSec := 0;
      fLastUtsUpdateTickMs := 0;
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTimeSystem.Stop
  Назначение:
    Потокобезопасно останавливает активный временной интервал.
  Вызывается из:
    Вызывается при остановке сбора/записи данных.
  Аналог в оригинальном Recorder:
    Синхронизировано со стопом ядра. }
procedure TRecorderTimeSystem.Stop;
begin
  EnterCriticalSection(fLock);
  try
    fRunning := False;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTimeSystem.Reset
  Назначение:
    Потокобезопасно сбрасывает все накопленные данные о времени, обнуляя счетчики тиков, времени тегов и UTS.
  Вызывается из:
    Вызывается при сбросе состояния ядра.
  Аналог в оригинальном Recorder:
    Аналогичен сбросу таймеров в оригинальном Recorder. }
procedure TRecorderTimeSystem.Reset;
begin
  EnterCriticalSection(fLock);
  try
    fRunning := False;
    fStartLocalTime := Now;
    fStartUtcTime := LocalTimeToUniversal(fStartLocalTime);
    fStartTickMs := 0;
    fLastTagTimeSec := 0;
    fLastUtsTimeSec := 0;
    fLastUtsUpdateTickMs := 0;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderTimeSystem.ChannelTimeToUtc(
  AChannelTimeSec: Double): TDateTime;
begin
  if AChannelTimeSec < 0 then
    AChannelTimeSec := 0;
  EnterCriticalSection(fLock);
  try
    Result := fStartUtcTime + (AChannelTimeSec / SecsPerDay);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderTimeSystem.CurrentUtc: TDateTime;
var
  lNowTickMs: QWord;
begin
  lNowTickMs := GetTickCount64;
  EnterCriticalSection(fLock);
  try
    if fRunning then
      Result := fStartUtcTime + (InternalElapsedSec(lNowTickMs) / SecsPerDay)
    else
      Result := LocalTimeToUniversal(Now);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTimeSystem.UpdateFromTagSample
  Назначение:
    Обновляет внутренние переменные времени тегов и UTS на основе времени последнего обработанного кадра данных.
  Вызывается из:
    Вызывается из обработчика очереди событий при получении пакетов данных от устройств.
  Аналог в оригинальном Recorder:
    Соответствует синхронизации дисплея по аппаратному времени прибора в оригинальном Recorder. }
procedure TRecorderTimeSystem.UpdateFromTagSample(ATagTimeSec: Double;
  AUtsTimeSec: Double);
begin
  EnterCriticalSection(fLock);
  try
    if ATagTimeSec >= 0 then
      fLastTagTimeSec := ATagTimeSec;
    if AUtsTimeSec >= 0 then
    begin
      fLastUtsTimeSec := AUtsTimeSec;
      fLastUtsUpdateTickMs := GetTickCount64;
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTimeSystem.Snapshot
  Назначение:
    Потокобезопасно формирует снимок состояния времени TRecorderTimeSnapshot и готовит строку DisplayText для панели состояния.
  Вызывается из:
    Вызывается по таймеру UI (обычно 5-10 Гц) для обновления времени на экране.
  Аналог в оригинальном Recorder:
    Обновление строки состояния оригинального Recorder. }
function TRecorderTimeSystem.Snapshot: TRecorderTimeSnapshot;
var
  lNowTickMs: QWord;
begin
  lNowTickMs := GetTickCount64;

  EnterCriticalSection(fLock);
  try
    Result.SourceKind := fSourceKind;
    Result.Running := fRunning;
    Result.StartLocalTime := fStartLocalTime;
    Result.ElapsedSec := InternalElapsedSec(lNowTickMs);
    Result.LastTagTimeSec := fLastTagTimeSec;
    Result.LastUtsTimeSec := CurrentUtsDisplaySec(lNowTickMs);

    case fSourceKind of
      rtskPcTime:
        Result.DisplayText := FormatDateTime('hh:nn:ss', Now);
      rtskTagTime:
        Result.DisplayText := FormatDuration(fLastTagTimeSec);
      rtskUtsTime:
        Result.DisplayText := FormatDuration(Result.LastUtsTimeSec);
    else
      Result.DisplayText := FormatDuration(Result.ElapsedSec);
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

class function TRecorderTimeSystem.FormatDuration(ASeconds: Double): string;
var
  lTotalSeconds: Int64;
  lHours: Int64;
  lMinutes: Int64;
  lSeconds: Int64;
begin
  if ASeconds < 0 then
    ASeconds := 0;

  lTotalSeconds := Trunc(ASeconds);
  lHours := lTotalSeconds div 3600;
  lMinutes := (lTotalSeconds div 60) mod 60;
  lSeconds := lTotalSeconds mod 60;

  Result := Format('%.2d:%.2d:%.2d', [lHours, lMinutes, lSeconds]);
end;

end.
