unit UProtManager;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, syncobjs, ExtCtrls;

type

{ TProtManager }

TProtManager = class
private
fStrings: TStringList;
fStr: String;
fCS: TCriticalSection;
fTimer: TTimer;
fProtocolReady: TNotifyEvent;
function getStr: String;
function getStrLst: TStringList;
procedure TimerTick(Sender: TObject);
procedure DoProtocolReady;
public
procedure AddLst(s: string);    //Добавляет строку к списку строк
procedure AddStr(s: string); //Добавляет строку к строке
procedure Clear;
constructor Create;
destructor destroy; override;
property StrLst: TStringList read getStrLst;
property Str: String read getStr;
property OnProtocolReady: TNotifyEvent read fProtocolReady write fProtocolReady;
end;

var
  ProtManager: TProtManager;


implementation



{ TProtManager }

function TProtManager.getStrLst: TStringList;
begin
  fCS.Enter;
  result := fStrings;
  fCS.Leave;
end;

procedure TProtManager.AddLst(s: string);
begin
  fCS.Enter;
  fStrings.Append(s);
  fCS.Leave;
end;

function TProtManager.getStr: String;
begin
  fCS.Enter;
  result := fStr;
  fCS.Leave;
end;

procedure TProtManager.AddStr(s: string);
begin
  fCS.Enter;
  fStr := fStr + s + #13#10;
  fCS.Leave;
end;

procedure TProtManager.Clear;
begin
  fCS.Enter;
  fStrings.Clear;
  fStr := '';
  fCS.Leave;
end;

procedure TProtManager.DoProtocolReady;
begin
  if Assigned(fProtocolReady) then
      fProtocolReady(self);
end;

procedure TProtManager.TimerTick(Sender: TObject);
begin
  if (StrLst.Count > 0) or (length(Str) > 0) then
      begin
      DoProtocolReady;
      end;
end;

constructor TProtManager.Create;
begin
  fCS := TCriticalSection.Create;
  fStrings := TStringList.Create;
  fTimer := TTimer.Create(nil);
  fTimer.Interval := 200;
  fTimer.OnTimer := @TimerTick;
  fTimer.Enabled := true;
end;

destructor TProtManager.destroy;
begin
  FreeAndNil(fCS);
  FreeAndNil(fStrings);
  FreeAndNil(fTimer);
  inherited destroy;
end;

initialization
 ProtManager := TProtManager.Create;

finalization
 FreeAndNil(ProtManager);

end.


