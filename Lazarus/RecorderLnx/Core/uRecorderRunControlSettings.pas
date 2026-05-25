unit uRecorderRunControlSettings;

{
  Модуль uRecorderRunControlSettings

  Назначение:
    Настройки запуска и остановки одного сеанса Preview/Record. Модель описывает
    пользовательские условия из руководства Recorder: ручной старт, старт по
    уровню, внешний trigger/TTL и старт по задержке; остановку вручную, по уровню
    или по длительности. Модуль также умеет сохранять и загружать эти настройки
    в читаемый INI-файл.

  Место в архитектуре:
    Core/domain. Модуль не зависит от UI, устройств, каналов и файловой записи.
    Он хранит только выбранные пользователем параметры и проверяет их полноту.

  Ограничения первой версии:
    Канал задается строковым именем. Проверка существования канала, привязка к
    дереву устройств, фактический анализ уровня и таймеры будут реализованы
    отдельными ядровыми сервисами поверх этой модели.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles,
  uRecorderStateMachine;

type
  { Направление прохождения порога сигнала. }
  TRecorderSignalEdge = (
    rseRising,
    rseFalling
  );

  { Условие остановки записи.

    rstopManual      - остановка по команде пользователя.
    rstopSignalLevel - остановка по прохождению уровня сигнала.
    rstopDuration    - остановка через заданную длительность.
  }
  TRecorderStopCondition = (
    rstopManual,
    rstopSignalLevel,
    rstopDuration
  );

  ERecorderRunControlSettingsError = class(Exception);

  { TRecorderRunControlSettings

    Один объект хранит настройки старта и остановки. Это упрощает дальнейшую
    сериализацию конфигурации и передачу параметров в сервис запуска сеанса.
  }
  TRecorderRunControlSettings = class
  private
    fStartCondition: TRecorderStartCondition;
    fStartChannelName: string;
    fStartLevel: Double;
    fStartEdge: TRecorderSignalEdge;
    fStartDelayMs: Cardinal;
    fStopCondition: TRecorderStopCondition;
    fStopChannelName: string;
    fStopLevel: Double;
    fStopEdge: TRecorderSignalEdge;
    fStopDelayMs: Cardinal;

    function ValidateStart(out AMessage: string): Boolean;
    function ValidateStop(out AMessage: string): Boolean;
    function ReadStartCondition(AIni: TCustomIniFile;
      const ASection, AName: string; ADefault: TRecorderStartCondition): TRecorderStartCondition;
    function ReadStopCondition(AIni: TCustomIniFile;
      const ASection, AName: string; ADefault: TRecorderStopCondition): TRecorderStopCondition;
    function ReadSignalEdge(AIni: TCustomIniFile;
      const ASection, AName: string; ADefault: TRecorderSignalEdge): TRecorderSignalEdge;
  public
    { Создает настройки с ручным стартом и ручной остановкой. }
    constructor Create;

    { Возвращает настройки к безопасному состоянию по умолчанию:
      ручной старт, ручная остановка, пустые имена каналов, нулевые уровни и
      задержки. }
    procedure ResetDefaults;

    { Проверяет полноту настроек старта и остановки.

      AMessage - текст первой найденной ошибки. Если ошибок нет, возвращается
        пустая строка.
    }
    function Validate(out AMessage: string): Boolean;

    { То же, что Validate, но при ошибке выбрасывает
      ERecorderRunControlSettingsError. }
    procedure RequireValid;

    { Сохраняет настройки в INI-файл.

      AFileName - полный путь к файлу конфигурации. Каталог должен существовать.
      Метод сначала проверяет настройки через RequireValid, чтобы не сохранить
      неполную конфигурацию.
    }
    procedure SaveToFile(const AFileName: string);

    { Загружает настройки из INI-файла.

      AFileName - полный путь к файлу конфигурации. Отсутствующие поля получают
      значения по умолчанию. После чтения выполняется RequireValid.
    }
    procedure LoadFromFile(const AFileName: string);

    { Возвращает True, если старт должен перейти в Armed-состояние. }
    function StartNeedsArming: Boolean;

    { Возвращает True, если остановка должна произойти автоматически. }
    function StopIsAutomatic: Boolean;

    { Текстовые имена для логов, тестов и будущего UI. }
    class function SignalEdgeToString(AEdge: TRecorderSignalEdge): string; static;
    class function StringToSignalEdge(const AValue: string;
      ADefault: TRecorderSignalEdge): TRecorderSignalEdge; static;
    class function StopConditionToString(ACondition: TRecorderStopCondition): string; static;
    class function StringToStopCondition(const AValue: string;
      ADefault: TRecorderStopCondition): TRecorderStopCondition; static;
    class function StringToStartCondition(const AValue: string;
      ADefault: TRecorderStartCondition): TRecorderStartCondition; static;

    property StartCondition: TRecorderStartCondition read fStartCondition write fStartCondition;
    property StartChannelName: string read fStartChannelName write fStartChannelName;
    property StartLevel: Double read fStartLevel write fStartLevel;
    property StartEdge: TRecorderSignalEdge read fStartEdge write fStartEdge;
    property StartDelayMs: Cardinal read fStartDelayMs write fStartDelayMs;

    property StopCondition: TRecorderStopCondition read fStopCondition write fStopCondition;
    property StopChannelName: string read fStopChannelName write fStopChannelName;
    property StopLevel: Double read fStopLevel write fStopLevel;
    property StopEdge: TRecorderSignalEdge read fStopEdge write fStopEdge;
    property StopDelayMs: Cardinal read fStopDelayMs write fStopDelayMs;
  end;

implementation

{ TRecorderRunControlSettings }

constructor TRecorderRunControlSettings.Create;
begin
  inherited Create;
  ResetDefaults;
end;

procedure TRecorderRunControlSettings.ResetDefaults;
begin
  fStartCondition := rscManual;
  fStartChannelName := '';
  fStartLevel := 0.0;
  fStartEdge := rseRising;
  fStartDelayMs := 0;

  fStopCondition := rstopManual;
  fStopChannelName := '';
  fStopLevel := 0.0;
  fStopEdge := rseRising;
  fStopDelayMs := 0;
end;

function TRecorderRunControlSettings.ValidateStart(out AMessage: string): Boolean;
begin
  Result := False;
  AMessage := '';

  case fStartCondition of
    rscManual,
    rscExternalTrigger:
      Result := True;

    rscSignalLevel:
      begin
        if Trim(fStartChannelName) = '' then
        begin
          AMessage := 'Start signal level condition requires StartChannelName';
          Exit;
        end;
        Result := True;
      end;

    rscTime:
      begin
        if fStartDelayMs = 0 then
        begin
          AMessage := 'Start time condition requires StartDelayMs > 0';
          Exit;
        end;
        Result := True;
      end;
  else
    AMessage := 'Unknown start condition';
  end;
end;

function TRecorderRunControlSettings.ValidateStop(out AMessage: string): Boolean;
begin
  Result := False;
  AMessage := '';

  case fStopCondition of
    rstopManual:
      Result := True;

    rstopSignalLevel:
      begin
        if Trim(fStopChannelName) = '' then
        begin
          AMessage := 'Stop signal level condition requires StopChannelName';
          Exit;
        end;
        Result := True;
      end;

    rstopDuration:
      begin
        if fStopDelayMs = 0 then
        begin
          AMessage := 'Stop duration condition requires StopDelayMs > 0';
          Exit;
        end;
        Result := True;
      end;
  else
    AMessage := 'Unknown stop condition';
  end;
end;

function TRecorderRunControlSettings.Validate(out AMessage: string): Boolean;
begin
  Result := ValidateStart(AMessage);
  if not Result then
    Exit;

  Result := ValidateStop(AMessage);
end;

function TRecorderRunControlSettings.ReadStartCondition(AIni: TCustomIniFile;
  const ASection, AName: string; ADefault: TRecorderStartCondition): TRecorderStartCondition;
begin
  Result := StringToStartCondition(
    AIni.ReadString(ASection, AName, TRecorderStateMachine.StartConditionToString(ADefault)),
    ADefault);
end;

function TRecorderRunControlSettings.ReadStopCondition(AIni: TCustomIniFile;
  const ASection, AName: string; ADefault: TRecorderStopCondition): TRecorderStopCondition;
begin
  Result := StringToStopCondition(
    AIni.ReadString(ASection, AName, StopConditionToString(ADefault)),
    ADefault);
end;

function TRecorderRunControlSettings.ReadSignalEdge(AIni: TCustomIniFile;
  const ASection, AName: string; ADefault: TRecorderSignalEdge): TRecorderSignalEdge;
begin
  Result := StringToSignalEdge(
    AIni.ReadString(ASection, AName, SignalEdgeToString(ADefault)),
    ADefault);
end;

procedure TRecorderRunControlSettings.RequireValid;
var
  lMessage: string;
begin
  if not Validate(lMessage) then
    raise ERecorderRunControlSettingsError.Create(lMessage);
end;

procedure TRecorderRunControlSettings.SaveToFile(const AFileName: string);
var
  lIni: TIniFile;
begin
  RequireValid;

  lIni := TIniFile.Create(AFileName);
  try
    lIni.WriteString('Start', 'Condition',
      TRecorderStateMachine.StartConditionToString(fStartCondition));
    lIni.WriteString('Start', 'ChannelName', fStartChannelName);
    lIni.WriteFloat('Start', 'Level', fStartLevel);
    lIni.WriteString('Start', 'Edge', SignalEdgeToString(fStartEdge));
    lIni.WriteInteger('Start', 'DelayMs', fStartDelayMs);

    lIni.WriteString('Stop', 'Condition', StopConditionToString(fStopCondition));
    lIni.WriteString('Stop', 'ChannelName', fStopChannelName);
    lIni.WriteFloat('Stop', 'Level', fStopLevel);
    lIni.WriteString('Stop', 'Edge', SignalEdgeToString(fStopEdge));
    lIni.WriteInteger('Stop', 'DelayMs', fStopDelayMs);
  finally
    lIni.Free;
  end;
end;

procedure TRecorderRunControlSettings.LoadFromFile(const AFileName: string);
var
  lIni: TIniFile;
begin
  ResetDefaults;

  lIni := TIniFile.Create(AFileName);
  try
    fStartCondition := ReadStartCondition(lIni, 'Start', 'Condition', fStartCondition);
    fStartChannelName := lIni.ReadString('Start', 'ChannelName', fStartChannelName);
    fStartLevel := lIni.ReadFloat('Start', 'Level', fStartLevel);
    fStartEdge := ReadSignalEdge(lIni, 'Start', 'Edge', fStartEdge);
    fStartDelayMs := lIni.ReadInteger('Start', 'DelayMs', fStartDelayMs);

    fStopCondition := ReadStopCondition(lIni, 'Stop', 'Condition', fStopCondition);
    fStopChannelName := lIni.ReadString('Stop', 'ChannelName', fStopChannelName);
    fStopLevel := lIni.ReadFloat('Stop', 'Level', fStopLevel);
    fStopEdge := ReadSignalEdge(lIni, 'Stop', 'Edge', fStopEdge);
    fStopDelayMs := lIni.ReadInteger('Stop', 'DelayMs', fStopDelayMs);
  finally
    lIni.Free;
  end;

  RequireValid;
end;

function TRecorderRunControlSettings.StartNeedsArming: Boolean;
begin
  Result := fStartCondition <> rscManual;
end;

function TRecorderRunControlSettings.StopIsAutomatic: Boolean;
begin
  Result := fStopCondition <> rstopManual;
end;

class function TRecorderRunControlSettings.SignalEdgeToString(
  AEdge: TRecorderSignalEdge): string;
begin
  case AEdge of
    rseRising:
      Result := 'Rising';
    rseFalling:
      Result := 'Falling';
  else
    Result := 'Unknown';
  end;
end;

class function TRecorderRunControlSettings.StringToSignalEdge(const AValue: string;
  ADefault: TRecorderSignalEdge): TRecorderSignalEdge;
begin
  if SameText(AValue, 'Rising') then
    Result := rseRising
  else if SameText(AValue, 'Falling') then
    Result := rseFalling
  else
    Result := ADefault;
end;

class function TRecorderRunControlSettings.StopConditionToString(
  ACondition: TRecorderStopCondition): string;
begin
  case ACondition of
    rstopManual:
      Result := 'Manual';
    rstopSignalLevel:
      Result := 'SignalLevel';
    rstopDuration:
      Result := 'Duration';
  else
    Result := 'Unknown';
  end;
end;

class function TRecorderRunControlSettings.StringToStopCondition(const AValue: string;
  ADefault: TRecorderStopCondition): TRecorderStopCondition;
begin
  if SameText(AValue, 'Manual') then
    Result := rstopManual
  else if SameText(AValue, 'SignalLevel') then
    Result := rstopSignalLevel
  else if SameText(AValue, 'Duration') then
    Result := rstopDuration
  else
    Result := ADefault;
end;

class function TRecorderRunControlSettings.StringToStartCondition(const AValue: string;
  ADefault: TRecorderStartCondition): TRecorderStartCondition;
begin
  if SameText(AValue, 'Manual') then
    Result := rscManual
  else if SameText(AValue, 'SignalLevel') then
    Result := rscSignalLevel
  else if SameText(AValue, 'ExternalTrigger') then
    Result := rscExternalTrigger
  else if SameText(AValue, 'Time') then
    Result := rscTime
  else
    Result := ADefault;
end;

end.
