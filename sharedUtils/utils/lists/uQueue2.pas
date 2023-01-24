unit UQueue2;

interface
uses Classes, Generics.Collections, SyncObjs;

const
PAGE_SIZE = 512;

type
TMyQueue<T> = class(TObject)
private
fArray: array of T;
fLength: integer;

fCS: TCriticalSection;
    function GetItem(index: integer): T;

public
constructor Create;
destructor Destroy; override;

procedure Enqueue(value: T); //Поставить в очередь
function Extract: T;      //Извлечь элмент по очереди
function Count: integer;  //Вернуть число элементов
procedure Clear;          //Очистить
procedure Push(value: T); //Поставить в начало очереди
procedure Remove(n: integer); //Удалить элемент n из очереди

property Items[index: integer]: T read GetItem;
end;

implementation

{ TMyQueue<T> }

procedure TMyQueue<T>.Clear;
begin
  fCS.Enter;
  fLength := 0;
  setlength(fArray, PAGE_SIZE);
  FillChar(fArray[0], PAGE_SIZE, 0);
  fCS.Leave;
end;

function TMyQueue<T>.Count: integer;
begin
  result := fLength;
end;

constructor TMyQueue<T>.Create;
begin
  inherited;
  fCS := TCriticalSection.Create;
  Clear;
end;

destructor TMyQueue<T>.Destroy;
begin
  setlength(fArray, 0);
  fCS.Free;
  inherited;
end;

procedure TMyQueue<T>.Enqueue(value: T);
begin
  fCS.Enter;
  fLength := fLength + 1;
  if fLength > length(fArray) then
     setLength(fArray, length(fArray) + PAGE_SIZE);
  fArray[fLength - 1] := value;
  fCS.Leave;
end;

function TMyQueue<T>.Extract: T;
begin
fCS.Enter;
  if fLength > 0 then
     begin
     result := fArray[0];

     if fLength > 1 then
        move(fArray[1], fArray[0], sizeof(T) * (fLength - 1));

     fLength := fLength - 1;
     end;
fCS.Leave;
end;

function TMyQueue<T>.GetItem(index: integer): T;
begin
fCS.Enter;
   result := fArray[index];
fCS.Leave;
end;

procedure TMyQueue<T>.Push(value: T);
begin
  fCS.Enter;

  fLength := fLength + 1;
  if fLength > length(fArray) then
     setLength(fArray, length(fArray) + PAGE_SIZE);

  if fLength > 1 then
    move(fArray[0], fArray[1], sizeof(T) * (fLength - 1));

  fArray[0] := value;
  fCS.Leave;
end;

procedure TMyQueue<T>.Remove(n: integer);
begin
  fCS.Enter;
  move(fArray[n + 1], fArray[n], sizeof(T) * (fLength - n - 1));
  fLength := fLength - 1;
  fCS.Leave;
end;

end.
