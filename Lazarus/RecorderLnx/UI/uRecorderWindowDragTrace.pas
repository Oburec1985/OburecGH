unit uRecorderWindowDragTrace;

{$mode objfpc}{$H+}

interface

uses
  Forms, LMessages
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

type
  {$IFDEF MSWINDOWS}
  TRecorderWindowDragSample = record
    EventKind: Char;
    Clock: TSystemTime;
    Tick: QWord;
    CursorX, CursorY: LongInt;
    Left, Top, Width, Height: LongInt;
    DeltaX, DeltaY: LongInt;
    IntervalMs: QWord;
  end;
  {$ENDIF}
  TRecorderWindowDragTrace = class
  private
    fWindowName: string;
    fActive: Boolean;
    fCount: Integer;
    fDropped: Integer;
    fLastTick: QWord;
    {$IFDEF MSWINDOWS}
    fSamples: array[0..8191] of TRecorderWindowDragSample;
    {$ENDIF}
    procedure Capture(AForm: TForm; AEventKind: Char);
    procedure Flush;
  public
    constructor Create(const AWindowName: string);
    procedure HandleMessage(AForm: TForm; const AMessage: TLMessage);
  end;

implementation

uses
  SysUtils, uRecorderMeraPaths;

constructor TRecorderWindowDragTrace.Create(const AWindowName: string);
begin
  inherited Create;
  fWindowName := AWindowName;
end;

procedure TRecorderWindowDragTrace.Capture(AForm: TForm; AEventKind: Char);
{$IFDEF MSWINDOWS}
var
  lCursor: TPoint;
  lRect: TRect;
  lSample: ^TRecorderWindowDragSample;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  if not fActive then Exit;
  if fCount >= Length(fSamples) then
  begin
    Inc(fDropped);
    Exit;
  end;
  lSample := @fSamples[fCount];
  lSample^.EventKind := AEventKind;
  GetLocalTime(lSample^.Clock);
  lSample^.Tick := GetTickCount64;
  GetCursorPos(lCursor);
  GetWindowRect(AForm.Handle, lRect);
  lSample^.CursorX := lCursor.X;
  lSample^.CursorY := lCursor.Y;
  lSample^.Left := lRect.Left;
  lSample^.Top := lRect.Top;
  lSample^.Width := lRect.Right - lRect.Left;
  lSample^.Height := lRect.Bottom - lRect.Top;
  lSample^.DeltaX := lCursor.X - lRect.Left;
  lSample^.DeltaY := lCursor.Y - lRect.Top;
  lSample^.IntervalMs := lSample^.Tick - fLastTick;
  fLastTick := lSample^.Tick;
  Inc(fCount);
  {$ENDIF}
end;

procedure TRecorderWindowDragTrace.Flush;
{$IFDEF MSWINDOWS}
var
  lFile: TextFile;
  lPath: string;
  lIndex: Integer;
  lSample: ^TRecorderWindowDragSample;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  if fCount = 0 then Exit;
  try
    lPath := RecorderServiceFileName('WindowDragTrace.csv');
    AssignFile(lFile, lPath);
    if FileExists(lPath) then Append(lFile) else
    begin
      Rewrite(lFile);
      WriteLn(lFile, 'window;event;clock;tick_ms;cursor_x;cursor_y;window_left;window_top;window_width;window_height;cursor_minus_left;cursor_minus_top;interval_ms;dropped');
    end;
    for lIndex := 0 to fCount - 1 do
    begin
      lSample := @fSamples[lIndex];
      WriteLn(lFile, Format('%s;%s;%4.4d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d.%3.3d;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d',
        [fWindowName, lSample^.EventKind, lSample^.Clock.wYear, lSample^.Clock.wMonth,
         lSample^.Clock.wDay, lSample^.Clock.wHour, lSample^.Clock.wMinute,
         lSample^.Clock.wSecond, lSample^.Clock.wMilliseconds,
         lSample^.Tick, lSample^.CursorX, lSample^.CursorY,
         lSample^.Left, lSample^.Top, lSample^.Width, lSample^.Height,
         lSample^.DeltaX, lSample^.DeltaY, lSample^.IntervalMs, fDropped]));
    end;
    CloseFile(lFile);
  except
    on E: Exception do
      ; { Diagnostics must not interrupt movement on a read-only path. }
  end;
  {$ENDIF}
end;

procedure TRecorderWindowDragTrace.HandleMessage(AForm: TForm;
  const AMessage: TLMessage);
begin
  {$IFDEF MSWINDOWS}
  case AMessage.msg of
    WM_ENTERSIZEMOVE:
      begin
        fActive := True;
        fCount := 0;
        fDropped := 0;
        fLastTick := GetTickCount64;
        Capture(AForm, 'I');
      end;
    WM_MOVING, WM_SIZING: Capture(AForm, 'P');
    WM_MOVE, WM_SIZE: Capture(AForm, 'A');
    WM_EXITSIZEMOVE:
      if fActive then
      begin
        Capture(AForm, 'X');
        fActive := False;
        Flush;
      end;
  end;
  {$ENDIF}
end;

end.
