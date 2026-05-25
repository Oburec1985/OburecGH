unit uRecorderStateMachine;

{
  Модуль uRecorderStateMachine

  Назначение:
    Минимальная доменная модель режимов RecorderLnx по рабочей модели Recorder:
    Stop, Preview, Record и промежуточные Armed-состояния ожидания условия старта.

  Место в архитектуре:
    Core/domain. Модуль не зависит от LCL, устройств, каналов, файлов записи и UI.
    Его задача - проверяемая логика переходов между режимами. Настройки условий
    старта/остановки, дерево устройств и запись данных добавляются отдельными
    units поверх этой модели.

  Ограничения первой версии:
    Модуль знает только тип условия старта, но не хранит параметры канала, порога,
    времени или внешнего входа. Эти параметры будут вынесены в отдельную модель
    настроек запуска/остановки.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { Режимы RecorderLnx.

    rsStop          - приложение остановлено; разрешена настройка.
    rsPreviewArmed - просмотр запрошен, но фактический старт ждет условия.
    rsPreview      - просмотр данных без записи на диск.
    rsRecordArmed  - запись запрошена, но фактический старт ждет условия.
    rsRecord       - идет запись данных.
  }
  TRecorderState = (
    rsStop,
    rsPreviewArmed,
    rsPreview,
    rsRecordArmed,
    rsRecord
  );

  { Тип условия старта Preview/Record.

    rscManual          - старт сразу по команде пользователя.
    rscSignalLevel     - старт по прохождению заданного уровня сигнала.
    rscExternalTrigger - старт по внешнему цифровому/TTL сигналу.
    rscTime            - старт по времени или задержке.
  }
  TRecorderStartCondition = (
    rscManual,
    rscSignalLevel,
    rscExternalTrigger,
    rscTime
  );

  ERecorderStateError = class(Exception);

  { Событие изменения состояния.

    ASender   - экземпляр TRecorderStateMachine.
    AOldState - состояние до перехода.
    ANewState - состояние после перехода.
  }
  TRecorderStateChangedEvent = procedure(ASender: TObject;
    AOldState, ANewState: TRecorderState) of object;

  { TRecorderStateMachine }

  TRecorderStateMachine = class
  private
    fState: TRecorderState;
    fOnStateChanged: TRecorderStateChangedEvent;
    procedure SetState(AState: TRecorderState);
    procedure CheckState(ACondition: Boolean; const AMessage: string);
    function NeedsStartTrigger(ACondition: TRecorderStartCondition): Boolean;
  public
    { Создает state machine в состоянии Stop. }
    constructor Create;

    { Запрашивает переход в Preview.

      ACondition - условие фактического старта просмотра. При rscManual переход
        выполняется сразу в rsPreview. При любом другом условии машина переходит
        в rsPreviewArmed и ожидает StartConditionMet.
    }
    procedure StartPreview(ACondition: TRecorderStartCondition);

    { Запрашивает переход в Record.

      ACondition - условие фактического старта записи. При rscManual переход
        выполняется сразу в rsRecord. При любом другом условии машина переходит
        в rsRecordArmed и ожидает StartConditionMet.

      Разрешено вызывать из Stop и Preview. Прямой Stop -> Record сохранен,
      потому что в Recorder запись запускается отдельной командой F2.
    }
    procedure StartRecord(ACondition: TRecorderStartCondition);

    { Сообщает машине, что ожидаемое условие старта наступило.

      Переводит PreviewArmed -> Preview или RecordArmed -> Record.
      В остальных состояниях выбрасывает ERecorderStateError.
    }
    procedure StartConditionMet;

    { Останавливает Preview/Record или отменяет Armed-состояние.

      Если машина уже в Stop, метод ничего не меняет.
    }
    procedure Stop;

    { Возвращает стабильное текстовое имя состояния для логов, тестов и UI. }
    class function StateToString(AState: TRecorderState): string; static;

    { Возвращает стабильное текстовое имя условия старта для логов, тестов и UI. }
    class function StartConditionToString(ACondition: TRecorderStartCondition): string; static;

    property State: TRecorderState read fState;
    property OnStateChanged: TRecorderStateChangedEvent read fOnStateChanged write fOnStateChanged;
  end;

implementation

{ TRecorderStateMachine }

constructor TRecorderStateMachine.Create;
begin
  inherited Create;
  fState := rsStop;
end;

procedure TRecorderStateMachine.SetState(AState: TRecorderState);
var
  lOldState: TRecorderState;
begin
  if fState = AState then
    Exit;

  lOldState := fState;
  fState := AState;

  { Событие вызывается после фиксации нового состояния, чтобы обработчик видел
    актуальное значение свойства State. }
  if Assigned(fOnStateChanged) then
    fOnStateChanged(Self, lOldState, fState);
end;

procedure TRecorderStateMachine.CheckState(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise ERecorderStateError.Create(AMessage);
end;

function TRecorderStateMachine.NeedsStartTrigger(ACondition: TRecorderStartCondition): Boolean;
begin
  Result := ACondition <> rscManual;
end;

procedure TRecorderStateMachine.StartPreview(ACondition: TRecorderStartCondition);
begin
  CheckState(fState in [rsStop, rsRecord],
    Format('Cannot start preview from %s', [StateToString(fState)]));

  { Переход Record -> Preview допустим: верхний слой при этом завершает
    текущий каталог кадра записи и оставляет сбор/просмотр активным. }

  { Неручной старт не запускает просмотр сразу: пользовательская команда только
    переводит систему в готовность, а фактический старт придет отдельным событием. }
  if NeedsStartTrigger(ACondition) then
    SetState(rsPreviewArmed)
  else
    SetState(rsPreview);
end;

procedure TRecorderStateMachine.StartRecord(ACondition: TRecorderStartCondition);
begin
  CheckState(fState in [rsStop, rsPreview],
    Format('Cannot start record from %s', [StateToString(fState)]));

  { Запись может быть запрошена напрямую из Stop или из Preview. Если старт
    зависит от уровня/TTL/времени, запись сначала становится armed. }
  if NeedsStartTrigger(ACondition) then
    SetState(rsRecordArmed)
  else
    SetState(rsRecord);
end;

procedure TRecorderStateMachine.StartConditionMet;
begin
  case fState of
    rsPreviewArmed:
      SetState(rsPreview);
    rsRecordArmed:
      SetState(rsRecord);
  else
    raise ERecorderStateError.CreateFmt('No start condition is expected in %s',
      [StateToString(fState)]);
  end;
end;

procedure TRecorderStateMachine.Stop;
begin
  if fState <> rsStop then
    SetState(rsStop);
end;

class function TRecorderStateMachine.StateToString(AState: TRecorderState): string;
begin
  case AState of
    rsStop:
      Result := 'Stop';
    rsPreviewArmed:
      Result := 'PreviewArmed';
    rsPreview:
      Result := 'Preview';
    rsRecordArmed:
      Result := 'RecordArmed';
    rsRecord:
      Result := 'Record';
  else
    Result := 'Unknown';
  end;
end;

class function TRecorderStateMachine.StartConditionToString(
  ACondition: TRecorderStartCondition): string;
begin
  case ACondition of
    rscManual:
      Result := 'Manual';
    rscSignalLevel:
      Result := 'SignalLevel';
    rscExternalTrigger:
      Result := 'ExternalTrigger';
    rscTime:
      Result := 'Time';
  else
    Result := 'Unknown';
  end;
end;

end.
