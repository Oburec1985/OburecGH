unit uEventList;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils, Contnrs, uEventTypes;

type
  { Процедура события с отправителем }
  TEventProcedure = procedure(ASender: TObject) of object;

  { TEvent - Один экземпляр события }
  TEvent = class
  private
    fActive: Boolean;         // Активно ли событие
    fName: string;            // Имя для отладки/идентификации
    fDescription: string;     // Описание
    fEventType: Cardinal;     // Тип или маска события
    fAction: TEventProcedure; // Метод-обработчик
  public
    constructor Create;
    property Active: Boolean read fActive write fActive;
    property Name: string read fName write fName;
    property Description: string read fDescription write fDescription;
    property EventType: Cardinal read fEventType write fEventType;
    property Action: TEventProcedure read fAction write fAction;
  end;

  { TEventList - Список и менеджер событий }
  TEventList = class(TObjectList)
  private
    fActive: Boolean;         // Глобальный флаг активности списка
    fUseMask: Boolean;        // Использовать ли типы как битовые маски
    fOwner: TObject;          // Владелец списка (например, менеджер объектов)
    fOnChange: TNotifyEvent;  // Событие при изменении списка
    
    function GetEvent(AIndex: Integer): TEvent;
    procedure DoOnChange;
  public
    constructor Create(AOwner: TObject; AUseMask: Boolean = False);
    
    // Добавление события
    function AddEvent(const AName: string; AEventType: Cardinal; AAction: TEventProcedure): TEvent;
    
    // Удаление события по методу и типу
    procedure RemoveEvent(AAction: TEventProcedure; AEventType: Cardinal; AOwner: TObject = nil);
    
    // Поиск метода по имени события
    function GetProcByName(const AName: string): TEventProcedure;
    
    // Вызов событий заданного типа (без отправителя, отправитель - fOwner)
    procedure CallAllEvents(AEventType: Cardinal);
    // Вызов событий заданного типа с указанием отправителя
    procedure CallAllEventsWithSender(AEventType: Cardinal; ASender: TObject);

    property Active: Boolean read fActive write fActive;
    property Owner: TObject read fOwner;
    property Items[Index: Integer]: TEvent read GetEvent; default;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

implementation

{ TEvent }

constructor TEvent.Create;
begin
  fActive := True;
end;

{ TEventList }

constructor TEventList.Create(AOwner: TObject; AUseMask: Boolean);
begin
  inherited Create(True); // Владеет объектами TEvent
  fOwner := AOwner;
  fUseMask := AUseMask;
  fActive := True;
end;

procedure TEventList.DoOnChange;
begin
  if Assigned(fOnChange) then
    fOnChange(Self);
end;

function TEventList.GetEvent(AIndex: Integer): TEvent;
begin
  Result := TEvent(inherited Items[AIndex]);
end;

function TEventList.AddEvent(const AName: string; AEventType: Cardinal; AAction: TEventProcedure): TEvent;
begin
  Result := TEvent.Create;
  Result.Name := AName;
  Result.EventType := AEventType;
  Result.Action := AAction;
  
  Add(Result);
  DoOnChange;
end;

procedure TEventList.RemoveEvent(AAction: TEventProcedure; AEventType: Cardinal; AOwner: TObject);
var
  li: Integer;
  lE: TEvent;
  lMethodData: TObject;
begin
  for li := Count - 1 downto 0 do
  begin
    lE := GetEvent(li);
    if (lE.EventType = AEventType) and (TMethod(lE.Action).Code = TMethod(AAction).Code) then
    begin
      lMethodData := TObject(TMethod(lE.Action).Data);
      // Если указан владелец метода, проверяем его
      if Assigned(AOwner) and (lMethodData <> AOwner) then
        Continue;
        
      Delete(li);
    end;
  end;
  DoOnChange;
end;

function TEventList.GetProcByName(const AName: string): TEventProcedure;
var
  li: Integer;
begin
  Result := nil;
  for li := 0 to Count - 1 do
    if SameText(GetEvent(li).Name, AName) then
    begin
      Result := GetEvent(li).Action;
      Exit;
    end;
end;

procedure TEventList.CallAllEvents(AEventType: Cardinal);
begin
  CallAllEventsWithSender(AEventType, fOwner);
end;

procedure TEventList.CallAllEventsWithSender(AEventType: Cardinal; ASender: TObject);
var
  li: Integer;
  lE: TEvent;
  lCall: Boolean;
begin
  if not fActive then
    Exit;
  
  // Копируем список индексов или идем по циклу, 
  // учитывая, что обработчики могут менять список (но лучше так не делать)
  for li := 0 to Count - 1 do
  begin
    lE := GetEvent(li);
    if not Assigned(lE) or not lE.Active then
      Continue;
    if AEventType in [E_CHANGENAME,      E_OnDestroyObject, E_OnAddChild,   E_OnAddObj,
                      E_OnEngUpdateList, E_OnRenameObj,     E_OnLoadObjMng, E_OnAddObjInstance, e_OnTagAlarm] then  //E_AllEvents then
      lCall := True
    else
      if fUseMask then
        lCall := (lE.EventType and AEventType) <> 0
      else
        lCall := lE.EventType = AEventType;
    if lCall and Assigned(lE.Action) then
      lE.Action(ASender);
  end;
end;

end.
