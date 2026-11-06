unit uRecorderPluginComponentManager;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Общий менеджер фабрик визуального плагина. Хранит фабрики в порядке
  регистрации, предоставляет их дескрипторы хосту и передаёт им общие
  уведомления. Состояние и представления компонентов принадлежат фабрикам
  и созданным ими экземплярам, а не менеджеру. }

interface

uses
  Classes, uRecorderVisualComponentApiV2, uRecorderPluginApi;

type
  { Наследник определяет ABI-дескриптор своего типа компонента. }
  cRecBasicFactory = class
  private
    fInstances: TList;
    fDescriptor: TRecorderVisualComponentDescriptorV2;
    fRecording: Boolean;
    function DispatchInstances(AKind: LongWord): LongInt;
  public
    procedure SetDescriptor(const ADescriptor: TRecorderVisualComponentDescriptorV2);
    procedure RegisterInstance(AInstance: Pointer);
    procedure UnregisterInstance(AInstance: Pointer);
    function OwnsInstance(AInstance: Pointer): Boolean;
    property Descriptor: TRecorderVisualComponentDescriptorV2 read fDescriptor;
    property Recording: Boolean read fRecording;
    constructor Create;
    destructor Destroy; override;
    function GetDescriptor(ADescriptor: PRecorderVisualComponentDescriptorV2;
      ACapacity: SizeUInt): LongInt; virtual; abstract;
    function doStart: LongInt; virtual;
    function doStop: LongInt; virtual;
    function doUpdateData: LongInt; virtual;
    { Остановить и дождаться собственных потоков до уничтожения и выгрузки.
      Повторный вызов после частичной ошибки должен быть безопасным. }
    function doClose: LongInt; virtual;
    { Событие инициализации Recorder; не выполняет обновление каталога тегов. }
    function doRecorderInit: LongInt; virtual;
    function Notify(AKind: LongWord; AData: Pointer): LongInt; virtual;
    { Фабрика обязана учитывать все ещё живые экземпляры своих компонентов. }
    function HasInstances: Boolean; virtual;
  end;

  { Add передаёт владение фабрикой менеджеру при успешном добавлении. }
  cCompMng = class
  private
    fFactories: TList;
    fHostApi: PRecorderPluginHostApi;
    fClosed: Boolean;
  public
    constructor Create(AHostApi: PRecorderPluginHostApi);
    destructor Destroy; override;
    procedure Add(AFactory: cRecBasicFactory);
    function GetDescriptor(AIndex: LongWord;
      ADescriptor: PRecorderVisualComponentDescriptorV2;
      ACapacity: SizeUInt): LongInt;
    function Notify(AKind: LongWord; AData: Pointer): LongInt;
    function Close: LongInt;
    function HasInstances: Boolean;
    property HostApi: PRecorderPluginHostApi read fHostApi;
  end;

implementation

uses SysUtils;

constructor cRecBasicFactory.Create;
begin
  inherited Create;
  fInstances := TList.Create;
end;

destructor cRecBasicFactory.Destroy;
begin
  fInstances.Free;
  inherited Destroy;
end;

procedure cRecBasicFactory.SetDescriptor(const ADescriptor: TRecorderVisualComponentDescriptorV2);
begin
  fDescriptor := ADescriptor;
end;

procedure cRecBasicFactory.RegisterInstance(AInstance: Pointer);
begin
  if (AInstance = nil) or OwnsInstance(AInstance) then
    raise Exception.Create('Invalid or duplicate plugin instance');
  fInstances.Add(AInstance);
end;

procedure cRecBasicFactory.UnregisterInstance(AInstance: Pointer);
begin
  fInstances.Remove(AInstance);
end;

function cRecBasicFactory.OwnsInstance(AInstance: Pointer): Boolean;
begin
  Result := fInstances.IndexOf(AInstance) >= 0;
end;

function cRecBasicFactory.HasInstances: Boolean;
begin
  Result := fInstances.Count > 0;
end;

function cRecBasicFactory.Notify(AKind: LongWord; AData: Pointer): LongInt;
begin
  case AKind of
    PN_RCSTART:
      begin
        fRecording := PtrUInt(AData) <> 0;
        Result := doStart;
      end;
    PN_RCSTOP:
      begin
        fRecording := False;
        Result := doStop;
      end;
    PN_UPDATEDATA: Result := doUpdateData;
    PN_RCINITIALIZED: Result := doRecorderInit;
  else
    Result := REC_VISUAL_NOT_HANDLED;
  end;
end;

function cRecBasicFactory.doStart: LongInt;
begin
  Result := DispatchInstances(REC_VISUAL_DISPATCH_START);
end;

function cRecBasicFactory.doStop: LongInt;
begin
  Result := DispatchInstances(REC_VISUAL_DISPATCH_STOP);
end;

function cRecBasicFactory.doUpdateData: LongInt;
begin
  Result := DispatchInstances(REC_VISUAL_DISPATCH_DATA_UPDATED);
end;

function cRecBasicFactory.doRecorderInit: LongInt;
begin
  Result := REC_VISUAL_NOT_HANDLED;
end;

function cRecBasicFactory.doClose: LongInt;
begin
  Result := REC_VISUAL_OK;
end;

function cRecBasicFactory.DispatchInstances(AKind: LongWord): LongInt;
var
  lSize: SizeUInt;
  lContext: TRecorderVisualRunContextV2;
  lInput: Pointer;
  lInputSize: SizeUInt;
  I: Integer;
begin
  if not Assigned(fDescriptor.ViewDispatch) then Exit(REC_VISUAL_NOT_HANDLED);
  lInput := nil;
  lInputSize := 0;
  if AKind = REC_VISUAL_DISPATCH_START then
  begin
    lContext := Default(TRecorderVisualRunContextV2);
    lContext.Header.Size := SizeOf(lContext);
    lContext.Header.AbiMajor := REC_VISUAL_ABI_V2_MAJOR;
    lContext.Header.AbiMinor := REC_VISUAL_ABI_V2_MINOR;
    lContext.Recording := Ord(fRecording);
    lInput := @lContext;
    lInputSize := SizeOf(lContext);
  end;
  Result := REC_VISUAL_OK;
  for I := 0 to fInstances.Count - 1 do
  begin
    lSize := 0;
    try
      if fDescriptor.ViewDispatch(fInstances[I], AKind, lInput, lInputSize, nil, 0,
        lSize) <> REC_VISUAL_OK then Result := REC_VISUAL_ERROR;
    except
      Result := REC_VISUAL_ERROR;
    end;
  end;
end;

constructor cCompMng.Create(AHostApi: PRecorderPluginHostApi);
begin
  inherited Create;
  fHostApi := AHostApi;
  fFactories := TList.Create;
end;

destructor cCompMng.Destroy;
var
  I: Integer;
begin
  if fFactories <> nil then
    for I := fFactories.Count - 1 downto 0 do
      TObject(fFactories[I]).Free;
  fFactories.Free;
  inherited Destroy;
end;

procedure cCompMng.Add(AFactory: cRecBasicFactory);
begin
  if fClosed then raise Exception.Create('Plugin manager is closed');
  if (AFactory = nil) or (fFactories.IndexOf(AFactory) >= 0) then
    raise Exception.Create('Invalid or duplicate plugin factory');
  fFactories.Add(AFactory);
end;

function cCompMng.GetDescriptor(AIndex: LongWord;
  ADescriptor: PRecorderVisualComponentDescriptorV2;
  ACapacity: SizeUInt): LongInt;
begin
  if AIndex >= LongWord(fFactories.Count) then
    Exit(REC_VISUAL_END_OF_ENUMERATION);
  Result := cRecBasicFactory(fFactories[AIndex]).GetDescriptor(
    ADescriptor, ACapacity);
end;

function cCompMng.Notify(AKind: LongWord; AData: Pointer): LongInt;
var
  I: Integer;
  lStatus: LongInt;
begin
  if fClosed then Exit(REC_VISUAL_ERROR);
  Result := REC_VISUAL_NOT_HANDLED;
  for I := 0 to fFactories.Count - 1 do
  begin
    try
      lStatus := cRecBasicFactory(fFactories[I]).Notify(AKind, AData);
    except
      lStatus := REC_VISUAL_ERROR;
    end;
    if (lStatus < 0) and (Result >= 0) then Result := lStatus
    else if (lStatus = REC_VISUAL_OK) and (Result > 0) then Result := REC_VISUAL_OK;
  end;
end;

function cCompMng.Close: LongInt;
var I: Integer; lStatus: LongInt;
begin
  if fClosed then Exit(REC_VISUAL_OK);
  Result := REC_VISUAL_OK;
  for I := 0 to fFactories.Count - 1 do
  begin
    try
      lStatus := cRecBasicFactory(fFactories[I]).doClose;
    except
      lStatus := REC_VISUAL_ERROR;
    end;
    if (lStatus < 0) and (Result = REC_VISUAL_OK) then Result := lStatus;
  end;
  fClosed := Result = REC_VISUAL_OK;
end;

function cCompMng.HasInstances: Boolean;
var
  I: Integer;
begin
  for I := 0 to fFactories.Count - 1 do
    if cRecBasicFactory(fFactories[I]).HasInstances then Exit(True);
  Result := False;
end;

end.
