unit UnitReadThread;

interface

uses
 Windows, Classes, SysUtils;

type
  pBytes = ^TBytes;

  TReadThread = class(TThread)
  private
    ComStat: TComStat;
    dwRead, dwMask, dwError: DWORD;
    dwRed: Cardinal;
    OverRead: TOverlapped;
    fParentThreadHandle: THandle;
    fRecieve: TNotifyEvent;
    fHandle: THandle;
    fBuff: TBytes;
    fEvHandle: THandle;

    procedure DoRecieve;
    function GetBuf: Tbytes;
    procedure SetBuf(b: Tbytes);
    protected
    procedure Execute; override;
  public
    //constructor Create(ParentThreadHandle: THandle);
    property Event: THandle read fEvHandle write fEvHandle;
    property RcvBuf: TBytes read GetBuf write SetBuf;
    property Port: THandle read fHandle write fHandle;
    property OnRx: TNotifyEvent read fRecieve write fRecieve;
  end;

implementation
uses UnitPort;

procedure TReadThread.SetBuf(b: TBytes);
begin
  fBuff := b;
end;

function TReadThread.GetBuf: TBytes;
begin
  result := fBuff;
end;

procedure TReadThread.DoRecieve;
begin
  if Assigned(fRecieve) then
    fRecieve(Self);
end;

procedure TReadThread.Execute;
begin
  OverRead.hEvent:= CreateEvent(nil, True, False, nil);
  OverRead.Internal:=0;
  OverRead.InternalHigh:=0;
  OverRead.Offset:=0;
  OverRead.OffsetHigh:=0;

  while not Terminated do
      begin
        if not WaitCommEvent(fHandle, dwMask, @OverRead) then
            if GetLastError = ERROR_IO_PENDING then
                WaitForSingleObject(OverRead.hEvent, Infinite);

        if Terminated then break;

        ClearCommError(fHandle, dwError, @ComStat);

        dwRed := 0;
        dwRead := ComStat.cbInQue;

        if dwRead > 0 then
            begin
              setlength(fBuff, dwRead);
              ReadFile(Port, fBuff[0], dwRead, dwRed, @OverRead);
              SetEvent(Event);

             // if fParentThreadHandle <> INVALID_HANDLE_VALUE then
             //   PostMessage(fParentThreadHandle, WM_UPDTHREAD_MESSAGE, self.Handle, 0);
             Synchronize(DoRecieve);
            end;
      end;
end;

end.
