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
  Classes, SysUtils;

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
    fLock: TRTLCriticalSection;      { Критическая секция для защиты внутренних данных }
    fResetAtStart: Boolean;          { Флаг сброса внешних данных времени при старте }
    fRunning: Boolean;               { Флаг активности записи }
    fSourceKind: TRecorderTimeSourceKind; { Текущий выбранный источник времени }
    fStartLocalTime: TDateTime;      { Системное время старта }
    fStartTickMs: QWord;             { Монотонное время старта в миллисекундах }
    
    function GetDisplayUpdateMs: Integer;
    function GetResetAtStart: Boolean;
    function GetSourceKind: TRecorderTimeSourceKind;
    procedure SetDisplayUpdateMs(AValue: Integer);
    procedure SetResetAtStart(AValue: Boolean);
    procedure SetSourceKind(AValue: TRecorderTimeSourceKind);
    function InternalElapsedSec(ANowTickMs: QWord): Double;
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

constructor TRecorderTimeSystem.Create;
begin
  inherited Create;
  InitCriticalSection(fLock);
  fDisplayUpdateMs := CDefaultDisplayUpdateMs;
  fResetAtStart := True;
  fSourceKind := rtskElapsedTime;
  Reset;
end;

destructor TRecorderTimeSystem.Destroy;
begin
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderTimeSystem.GetDisplayUpdateMs: Integer;
begin
  EnterCriticalSection(fLock);
  try
    Result := fDisplayUpdateMs;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderTimeSystem.GetResetAtStart: Boolean;
begin
  EnterCriticalSection(fLock);
  try
    Result := fResetAtStart;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderTimeSystem.GetSourceKind: TRecorderTimeSourceKind;
begin
  EnterCriticalSection(fLock);
  try
    Result := fSourceKind;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

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

procedure TRecorderTimeSystem.SetResetAtStart(AValue: Boolean);
begin
  EnterCriticalSection(fLock);
  try
    fResetAtStart := AValue;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderTimeSystem.SetSourceKind(AValue: TRecorderTimeSourceKind);
begin
  EnterCriticalSection(fLock);
  try
    fSourceKind := AValue;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderTimeSystem.InternalElapsedSec(ANowTickMs: QWord): Double;
begin
  if (not fRunning) or (fStartTickMs = 0) or (ANowTickMs < fStartTickMs) then
    Exit(0);

  Result := (ANowTickMs - fStartTickMs) / CMsecsPerSec;
end;

procedure TRecorderTimeSystem.Start;
begin
  EnterCriticalSection(fLock);
  try
    fRunning := True;
    fStartLocalTime := Now;
    fStartTickMs := GetTickCount64;
    if fResetAtStart then
    begin
      fLastTagTimeSec := 0;
      fLastUtsTimeSec := 0;
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderTimeSystem.Stop;
begin
  EnterCriticalSection(fLock);
  try
    fRunning := False;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderTimeSystem.Reset;
begin
  EnterCriticalSection(fLock);
  try
    fRunning := False;
    fStartLocalTime := Now;
    fStartTickMs := 0;
    fLastTagTimeSec := 0;
    fLastUtsTimeSec := 0;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderTimeSystem.UpdateFromTagSample(ATagTimeSec: Double;
  AUtsTimeSec: Double);
begin
  EnterCriticalSection(fLock);
  try
    if ATagTimeSec >= 0 then
      fLastTagTimeSec := ATagTimeSec;
    if AUtsTimeSec >= 0 then
      fLastUtsTimeSec := AUtsTimeSec;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

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
    Result.LastUtsTimeSec := fLastUtsTimeSec;

    case fSourceKind of
      rtskPcTime:
        Result.DisplayText := FormatDateTime('hh:nn:ss', Now);
      rtskTagTime:
        Result.DisplayText := FormatDuration(fLastTagTimeSec);
      rtskUtsTime:
        Result.DisplayText := FormatDuration(fLastUtsTimeSec);
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
