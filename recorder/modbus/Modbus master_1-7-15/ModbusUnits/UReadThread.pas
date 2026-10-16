unit UReadThread;
//Модуль потока чтения

interface

uses
  SysUtils, WinSock, Classes, UCommon, SyncObjs, blcksock;

const
MAX_BUF_SIZE = 1024;

type
 TTCPReadThread = class(TThread)
  private
  fBuf: TBytes;
  fRx: TDataEvent;
  fCS: TCriticalSection;
  fParent: pointer;
    { Private declarations }
  procedure DoRx(data: TBytes);
  protected
    procedure Execute; override;

  public
    constructor Create(parent: pointer);
    destructor Destroy; override;
    property OnRx: TDataEvent read fRx write fRx;
  end;

implementation

uses uTCPClient;

{ TReadThread }

constructor TTCPReadThread.Create(parent: pointer);
begin
  inherited Create(true);
  //Suspended := true;
  fCS := TCriticalSection.Create;
  SetLength(fBuf, MAX_BUF_SIZE);
  fParent := parent;
  //fSocket.SizeRecvBuffer := MAX_BUF_SIZE;
end;


destructor TTCPReadThread.Destroy;
begin
  FreeAndNil(fCS);
  inherited;
end;

procedure TTCPReadThread.DoRx(data: TBytes);
begin
  if Assigned(fRx) then
     fRx(self, data);
end;

procedure TTCPReadThread.Execute;
var
  rez: integer;
  buf: TBytes;
  wd: integer;
begin
  rez := 0;
  while not Terminated do
    begin
      wd := TTCPClient(fParent).Socket.WaitingData; //Проверяем есть ли данные во входном буфере
      //Если их количество больше 0 считываем
      if wd > 0 then
        begin
        //Даем на это действие 50 мс
        rez := TTCPClient(fParent).Socket.RecvBufferEx(@fBuf[0], wd, 50);
        if TTCPClient(fParent).Socket.LastError = WSAETIMEDOUT then //Произошел таймаут чтения
          begin
          TTCPClient(fParent).Socket.ResetLastError;
          sleep(5);  //Подождать 5 мс и проверить еще раз
          continue;
          end
          else
          //Нет таймаута, данные считались
          if rez > 0 then
          begin
              //Перекладываем их в выходной буфер
              setlength(buf, rez);
              move(fBuf[0], buf[0], rez);
              DoRx(buf);
          end;
      end else
      sleep(5);
    end;
end;




end.
