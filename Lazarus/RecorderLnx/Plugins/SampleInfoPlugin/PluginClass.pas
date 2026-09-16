unit PluginClass;

{$mode objfpc}{$H+}

interface

uses
  Classes, uRecorderPluginApi;

type
  TPluginEventHandler = procedure(AEvent: LongInt; AData: Pointer) of object;
  TPluginEventEntry = record
    Name: string;
    EventType: LongInt;
    Handler: TPluginEventHandler;
  end;

  TPluginEventList = class
  private
    fEntries: array of TPluginEventEntry;
  public
    procedure AddEvent(const AName: string; AEventType: LongInt;
      AHandler: TPluginEventHandler);
    procedure RemoveEvent(AHandler: TPluginEventHandler; AEventType: LongInt);
    procedure CallAllEvents(AEvent: LongInt; AData: Pointer);
    procedure Clear;
  end;

  TPluginClass = class
  private
    fEvents: TPluginEventList;
    fLastEvent: LongInt;
    fNotifyCount: LongInt;
    fClosed: Boolean;
    fSuspended: Boolean;
    procedure HandleRecorderEvent(AEvent: LongInt; AData: Pointer);
  public
    constructor Create;
    destructor Destroy; override;
    function _Create(AHostApi: PRecorderPluginHostApi): LongBool;
    function Config: LongBool;
    function Edit: LongBool;
    function Execute: LongBool;
    function Suspend: LongBool;
    function Resume: LongBool;
    function Notify(AEvent: LongInt; AData: Pointer): LongBool;
    function GetName: PAnsiChar;
    function GetProperty(const APropertyId: LongWord;
      var AValue: Variant): LongBool;
    function SetProperty(const APropertyId: LongWord;
      const AValue: Variant): LongBool;
    function CanClose: LongBool;
    function Close: LongBool;
    procedure AddPlgEvent(const AName: string; AEventType: LongInt;
      AHandler: TPluginEventHandler);
    procedure RemovePlgEvent(AHandler: TPluginEventHandler;
      AEventType: LongInt);
    procedure CallPlgEvents(AEventType: LongInt; AData: Pointer = nil);
  end;

implementation

uses
  uCreateComponents;

procedure TPluginEventList.AddEvent(const AName: string; AEventType: LongInt;
  AHandler: TPluginEventHandler);
begin
  SetLength(fEntries, Length(fEntries) + 1);
  fEntries[High(fEntries)].Name := AName;
  fEntries[High(fEntries)].EventType := AEventType;
  fEntries[High(fEntries)].Handler := AHandler;
end;

procedure TPluginEventList.RemoveEvent(AHandler: TPluginEventHandler;
  AEventType: LongInt);
var
  lIndex, lMoveIndex: Integer;
begin
  for lIndex := High(fEntries) downto 0 do
    if (fEntries[lIndex].EventType = AEventType) and
      (TMethod(fEntries[lIndex].Handler).Code = TMethod(AHandler).Code) and
      (TMethod(fEntries[lIndex].Handler).Data = TMethod(AHandler).Data) then
    begin
      for lMoveIndex := lIndex to High(fEntries) - 1 do
        fEntries[lMoveIndex] := fEntries[lMoveIndex + 1];
      SetLength(fEntries, Length(fEntries) - 1);
    end;
end;

procedure TPluginEventList.CallAllEvents(AEvent: LongInt; AData: Pointer);
var
  lIndex: Integer;
begin
  for lIndex := 0 to High(fEntries) do
    if ((fEntries[lIndex].EventType = AEvent) or
      (fEntries[lIndex].EventType = -1)) and
      Assigned(fEntries[lIndex].Handler) then
      fEntries[lIndex].Handler(AEvent, AData);
end;

procedure TPluginEventList.Clear;
begin
  SetLength(fEntries, 0);
end;

constructor TPluginClass.Create;
begin
  inherited Create;
  fEvents := TPluginEventList.Create;
  AddPlgEvent('recorder', -1, @HandleRecorderEvent);
end;

destructor TPluginClass.Destroy;
begin
  fEvents.Free;
  inherited Destroy;
end;

function TPluginClass._Create(AHostApi: PRecorderPluginHostApi): LongBool;
begin
  Result := RegisterOscillogram(AHostApi, Self);
end;

function TPluginClass.Config: LongBool;
begin
  Result := False;
end;

function TPluginClass.Edit: LongBool;
begin
  Result := False;
end;

function TPluginClass.Execute: LongBool;
begin
  Result := False;
end;

function TPluginClass.Suspend: LongBool;
begin
  Result := not fClosed;
  if Result then
    fSuspended := True;
end;

function TPluginClass.Resume: LongBool;
begin
  Result := not fClosed;
  if Result then
    fSuspended := False;
end;

function TPluginClass.Notify(AEvent: LongInt; AData: Pointer): LongBool;
begin
  Result := not (fClosed or fSuspended);
  if Result then
    CallPlgEvents(AEvent, AData);
end;

function TPluginClass.GetName: PAnsiChar;
begin
  Result := 'SampleInfoPlugin';
end;

function TPluginClass.GetProperty(const APropertyId: LongWord;
  var AValue: Variant): LongBool;
begin
  Result := False;
end;

function TPluginClass.SetProperty(const APropertyId: LongWord;
  const AValue: Variant): LongBool;
begin
  Result := False;
end;

function TPluginClass.CanClose: LongBool;
begin
  Result := True;
end;

function TPluginClass.Close: LongBool;
begin
  fEvents.Clear;
  fClosed := True;
  Result := True;
end;

procedure TPluginClass.AddPlgEvent(const AName: string; AEventType: LongInt;
  AHandler: TPluginEventHandler);
begin
  fEvents.AddEvent(AName, AEventType, AHandler);
end;

procedure TPluginClass.RemovePlgEvent(AHandler: TPluginEventHandler;
  AEventType: LongInt);
begin
  fEvents.RemoveEvent(AHandler, AEventType);
end;

procedure TPluginClass.CallPlgEvents(AEventType: LongInt; AData: Pointer);
begin
  fEvents.CallAllEvents(AEventType, AData);
end;

procedure TPluginClass.HandleRecorderEvent(AEvent: LongInt; AData: Pointer);
begin
  fLastEvent := AEvent;
  Inc(fNotifyCount);
end;

end.
