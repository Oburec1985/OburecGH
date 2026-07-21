unit uSharedAsync;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  ESharedAsyncError = class(Exception);

  { Задача для запуска метода без параметров в отдельном потоке.
    Владелец обязан вызвать WaitFor перед освобождением задачи. }
  TSharedAsyncTask = class(TThread)
  private
    fProcedure: TThreadMethod;
    fErrorClassName: string;
    fErrorMessage: string;
  protected
    procedure Execute; override;
  public
    constructor Create(AProcedure: TThreadMethod);
    procedure RaiseIfFailed;
    property ErrorClassName: string read fErrorClassName;
    property ErrorMessage: string read fErrorMessage;
  end;

function SharedStartAsync(AProcedure: TThreadMethod): TSharedAsyncTask;
procedure SharedRunParallel(const AProcedures: array of TThreadMethod);

implementation

constructor TSharedAsyncTask.Create(AProcedure: TThreadMethod);
begin
  if not Assigned(AProcedure) then
    raise ESharedAsyncError.Create('Async procedure is not assigned');
  inherited Create(True);
  FreeOnTerminate := False;
  fProcedure := AProcedure;
end;

procedure TSharedAsyncTask.Execute;
begin
  try
    fProcedure;
  except
    on E: Exception do
    begin
      fErrorClassName := E.ClassName;
      fErrorMessage := E.Message;
    end;
  end;
end;

procedure TSharedAsyncTask.RaiseIfFailed;
begin
  if fErrorMessage <> '' then
    raise ESharedAsyncError.CreateFmt('%s: %s',
      [fErrorClassName, fErrorMessage]);
end;

function SharedStartAsync(AProcedure: TThreadMethod): TSharedAsyncTask;
begin
  Result := TSharedAsyncTask.Create(AProcedure);
  Result.Start;
end;

procedure SharedRunParallel(const AProcedures: array of TThreadMethod);
var
  I: Integer;
  lErrors: TStringList;
  lTasks: array of TSharedAsyncTask;
begin
  SetLength(lTasks, Length(AProcedures));
  lErrors := TStringList.Create;
  try
    for I := 0 to High(AProcedures) do
      lTasks[I] := SharedStartAsync(AProcedures[I]);
    for I := 0 to High(lTasks) do
      if lTasks[I] <> nil then
      begin
        lTasks[I].WaitFor;
        if lTasks[I].ErrorMessage <> '' then
          lErrors.Add(Format('task %d: %s: %s', [I,
            lTasks[I].ErrorClassName, lTasks[I].ErrorMessage]));
      end;
    if lErrors.Count > 0 then
      raise ESharedAsyncError.Create(lErrors.Text);
  finally
    for I := 0 to High(lTasks) do
    begin
      if (lTasks[I] <> nil) and (not lTasks[I].Finished) then
        lTasks[I].WaitFor;
      lTasks[I].Free;
    end;
    lErrors.Free;
  end;
end;

end.
