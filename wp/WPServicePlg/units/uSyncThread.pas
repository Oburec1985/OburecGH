unit uSyncThread;

interface

uses
  Classes;

type
  cSyncThread = class(TThread)
  private
    fproc:TThreadMethod;
  protected
    procedure Execute; override;
  public
    constructor create(p:TThreadMethod);
    destructor destroy;override;
  end;

  procedure synchronise(proc:TThreadMethod);

implementation

procedure synchronise(proc:TThreadMethod);
var
  t:cSyncThread;
begin
  t:=cSyncThread.Create(proc);
end;

constructor cSyncThread.create(p:TThreadMethod);
begin
  // false - автозапуск потока
  inherited create(false);
  fproc:=p;
  FreeOnTerminate:=true;
end;

destructor cSyncThread.destroy;
begin
  inherited;
end;


procedure cSyncThread.Execute;
begin
  Synchronize(fproc);
  Terminate;
end;

end.
