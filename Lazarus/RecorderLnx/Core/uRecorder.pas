unit uRecorder;



{
  Корневой объект RecorderLnx — аналог IRecorder в оригинальном Recorder.
  Владеет реестром тегов, менеджером источников данных и прочими подсистемами ядра.
  UI ссылается на TRecorder, а не на отдельные менеджеры.
}
{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses

  Classes, SysUtils,
  uRecorderCoreServices, uRecorderTags, uRecorderDataSources,
  uRecorderStateMachine, uRecorderRunControlSettings,
  uRecorderEventQueue, uRecorderTimeSystem,
  uRecorderSpectrumRuntime, uRecorderAlarms;

type

  TRecorder = class
  private
    fEventBus: TRecorderEventBus;
    fTagRegistry: TRecorderTagRegistry;
    fDataSourceManager: TRecorderDataSourceManager;
    fStateMachine: TRecorderStateMachine;
    fRunSettings: TRecorderRunControlSettings;
    fEventQueue: TRecorderEventSnapshotQueue;
    fTimeSystem: TRecorderTimeSystem;
    fSpectrumManager: TRecorderSpectrumRuntimeManager;
    fAlarmEngine: IRecorderAlarmEngine;
  public
    constructor Create;
    destructor Destroy; override;
    property EventBus: TRecorderEventBus read fEventBus;
    property TagRegistry: TRecorderTagRegistry read fTagRegistry;
    property Tags: TRecorderTagRegistry read fTagRegistry;
    property DataSources: TRecorderDataSourceManager read fDataSourceManager;
    property StateMachine: TRecorderStateMachine read fStateMachine;
    property RunSettings: TRecorderRunControlSettings read fRunSettings;
    property EventQueue: TRecorderEventSnapshotQueue read fEventQueue;
    property TimeSystem: TRecorderTimeSystem read fTimeSystem;
    property SpectrumManager: TRecorderSpectrumRuntimeManager read fSpectrumManager;
    property AlarmEngine: IRecorderAlarmEngine read fAlarmEngine;
  end;



implementation



{ TRecorder.Create
  Назначение:
    Конструктор класса TRecorder. Инициализирует все ключевые компоненты ядра регистратора (шину событий EventBus, реестр тегов TagRegistry, менеджер источников данных DataSourceManager, автомат состояний StateMachine, настройки запуска RunSettings, очередь событий EventQueue, систему времени TimeSystem, менеджер спектров SpectrumManager и движок тревог AlarmEngine).
  Вызывается из:
    Вызывается один раз при запуске приложения в файле проекта RecorderLnx.lpr для инициализации фасада управления.
  Аналог в оригинальном Recorder:
    Аналогичен конструктору TRecorder.Create в оригинальном recorder.pas. }
constructor TRecorder.Create;
begin
  inherited Create;
  fEventBus := TRecorderEventBus.Create;
  fTagRegistry := TRecorderTagRegistry.Create(fEventBus);
  fDataSourceManager := TRecorderDataSourceManager.Create;
  fStateMachine := TRecorderStateMachine.Create;
  fRunSettings := TRecorderRunControlSettings.Create;
  fEventQueue := TRecorderEventSnapshotQueue.Create(fEventBus);
  fTimeSystem := TRecorderTimeSystem.Create;
  fSpectrumManager := TRecorderSpectrumRuntimeManager.Create(fEventBus, fTagRegistry);
  fAlarmEngine := TRecorderAlarmEngine.Create(fEventBus) as IRecorderAlarmEngine;
end;



{ TRecorder.Destroy
  Назначение:
    Деструктор класса TRecorder. Безопасно уничтожает все подсистемы ядра регистратора в порядке, обратном их созданию, и освобождает память.
  Вызывается из:
    Вызывается при закрытии приложения для предотвращения утечек памяти.
  Аналог в оригинальном Recorder:
    Аналогичен деструктору TRecorder.Destroy в оригинальном recorder.pas. }
destructor TRecorder.Destroy;
begin
  fAlarmEngine := nil;
  FreeAndNil(fSpectrumManager);
  FreeAndNil(fEventQueue);
  FreeAndNil(fDataSourceManager);
  FreeAndNil(fTimeSystem);
  FreeAndNil(fTagRegistry);
  FreeAndNil(fRunSettings);
  FreeAndNil(fStateMachine);
  FreeAndNil(fEventBus);
  inherited Destroy;
end;



end.