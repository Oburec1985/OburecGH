library SniffDll;

uses
  WinTypes, WinProcs, dialogs, inifiles, sysutils;

const
  //KeyEvent=WM_USER+1;
  //MouseEvent=KeyEvent+1;
  //WinTitle='TSnfwin';
  MMFName: PChar = 'KeyMMF'; // ��� ������� ��������� �����������

{���������, ���� ������� ����� ���������� � ���� ��������}
type
  PGlobalDLLData = ^TGlobalDLLData;

  TGlobalDLLData = packed record
    MouseHookHandle: HWND; // ���������� ������������� �������
    KeyHookHandle:array [0..100] of HWND; // ���������� ������������� �������
    hookCount:integer;
    MyAppWnd: HWND; // ���������� ������ ����������
    Tag:integer;
  end;


var
  GlobalData: PGlobalDLLData;
  // ������ �� ���� �����������
  MMFHandle: THandle;
  WM_KeyHOOK:cardinal;
  wm_MouseHook:cardinal;

  lastDll:TDLLProc;




//0-15	������� ��������. ���� ������ ������� � ������� �� � ������� ���������, ��������� ��������� WM_KEYDOWN � WM_SYSKEYDOWN ����� ����� � ����. ���������� ������������ ����� ������� ���������
//16-23	OEM ����-��� �������. ������������ ���������� (OEM - Original Equipment Manufacturer) ����� �������� � ����� ���������� ��������� ������������ ����-����� � ����������� ������. ����-��� ������������ ������������ ������������. ��� ��� ����� ���, ������� �������� � �������� AH ��������� MS-DOS, ������� ���������� INT16h
//24	���� ����������� ����������. ���� ��� ���������� � 1, ���� ��������� ������������� �������, ��������� ������ �� ����������� 101- ��� 102-��������� ����������. ��� ����� ���� ���� �� ��������� ������: <Home>, <End>, <PgUp>, <PgDn>, <Insert>, <Delete>, ������� �������������� ����������.
//25-26	�� ������������
//27-28	��������������� ��� ������������� Windows
//29	��� ���������. ���� ��� ����� 1, ���� ��������� ������������� ���������� ������� <Alt> � ����� ������, � 0 � ��������� ������
//30	���������� ��������� �������. ���� ����� �������� ��������� �������, ��������������� ���������, ���� � ������� ���������, ���� ��� ����� 1. � ��������� ������ ��� ����� 0
//31	���� ��������� ��������� ������� (transition state). ���� ������� ���� ������, ��� ����� 0, ���� �������� - 1

function StrToAnsi(s: string): lpcstr;
var
  astr: ansistring;
  i: integer;
begin
  for i := 1 to length(s) do
  begin
    astr := astr + s[i];
  end;
  result := lpcstr(astr);
end;


procedure logstr(str:lpcstr);
var
  f:TextFile;
const
  c_path = 'c:\Program Files (x86)\Mera\WinPOS\PlugIns\WPExtPack\logSniff.txt';
begin
  if FileExists(c_path) then
  begin
    Assign(f, c_path);
    // ��������� ��� ������
    append(f);
  end
  else
  begin
    AssignFile(f, c_path);
    ReWrite(f);
  end;
  // ������ ������ �� ������ ����
  writeln(f, str);
  CloseFile(f);
end;

function KeyHookProc(code: integer; WParam: word; lParam: Longint): Longint; stdcall;
var
  wnd:hwnd;
  str:string;
  I: Integer;
begin
  if code < 0 then
  begin
    for I := 0 to GlobalData^.hookCount - 1 do
    begin
      Result:= CallNextHookEx(GlobalData^.KeyHookHandle[i], Code, wParam, lParam);
      Exit;
    end;
  end;
  //CallNextHookEx(GlobalData^.KeyHookHandle, Code, wParam, lParam);
  if ((code = HC_ACTION) and (lParam <> lParam or $8000 shl 16)
     and (lParam <> lParam or $8000 shl 15))
     or(wParam=VK_SPACE)
     or(wParam=VK_return)
     or(wParam=VK_escape)
     or(wParam=VK_LSHIFT)
     or(wParam=VK_RSHIFT)
     or(wParam=VK_DELETE)
     or(wParam=VK_LEFT)
     or(wParam=VK_Right)
     or(wParam=VK_HOME)
     or(wParam=VK_END)
     // caps
     or(wParam=VK_CAPITAL)
  then
  begin
    //str:=StrToAnsi('SniffKeyHook_enter');
    //logstr(StrToAnsi(str));

  //if (  ((lParam and KF_UP)=0) and (wParam>=65) and (wParam<=90)  ) OR (  ((lParam and KF_UP)=0) and (wParam=VK_SPACE)  ) then
  // begin
     wnd:= GetForegroundWindow();
     if wnd<>0 then
     begin
       //CallNextHookEx(GlobalData^.KeyHookHandle, Code, wParam, lParam);
       ///showmessage('WM_KeyHOOK');
       str:='Sniff '+inttostr(WM_KeyHOOK)+ ' '+ inttostr(wParam);
       logstr(StrToAnsi(str));
       SendMessage(GlobalData^.MyAppWnd, WM_KeyHOOK, wParam, wnd)
     end
     else
     begin

     end;
  end;
  Result:= 0;
  for I := 0 to GlobalData^.hookCount - 1 do
  begin
    Result:= CallNextHookEx(GlobalData^.KeyHookHandle[i], Code, wParam, lParam);
    Exit;
  end;
end;

function SetHook(switch : Boolean; hMainProg: HWND):integer export;  stdcall;
var
  str:string;
  hookHandle:hwnd;
  I: Integer;
begin
  result:=0;
  if switch=true then
  begin
    if GlobalData^.MyAppWnd=0 then
    begin
      //������������ HOOK, ���� �� �� ���������� (switch=true)
      GlobalData^.MyAppWnd:= hMainProg;
      str:='HookMainWnd '+ inttostr(hMainProg); logstr(StrToAnsi(str));
      // 0 - id ������, ��� ���������� ����� =0           d
      hookHandle:=SetWindowsHookEx(WH_KEYBOARD, @KeyHookProc, HInstance, 0);
      GlobalData^.KeyHookHandle[GlobalData^.hookCount] := hookHandle;
      inc(GlobalData^.hookCount);
    end;
    result:=hookHandle;
    str:='HookCount '+ inttostr(GlobalData^.hookCount); logstr(StrToAnsi(str));
  end
  else
  begin
    //������ �������-������, ���� ��� ����������� (�.�. switch=false)
    for I := 0 to GlobalData^.hookCount - 1 do
    begin
      UnhookWindowsHookEx(GlobalData^.KeyHookHandle[i]);
    end;
  end;
end;

function SetTag(p_tag: integer):integer export;  stdcall;
begin
  result:=GlobalData^.tag;
  GlobalData^.tag:= p_tag;
end;


procedure OpenGlobalData();
begin
  {������������ ���� ��� ��������� � �������}
  WM_KeyHOOK:= RegisterWindowMessage('WM_OburecKeyHook');
  WM_MouseHOOK:= RegisterWindowMessage('WM_OburecMouseHook');
  {�������� ������ ��������� �����������}
  // MMFHandle:= CreateFileMapping(DWord(-1), nil, PAGE_READWRITE, 0, SizeOf(TGlobalDLLData), MMFName); // ����� ���, �� �����: ��. ����. ������
  MMFHandle:= CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(TGlobalDLLData), MMFName);
  if MMFHandle = 0 then
  begin
    MessageBox(0, 'Can''t create FileMapping', 'Message from keyhook.dll', 0);
    Exit;
  end;
  // ���������� ���������� ������ �� �� ����������� �������� � �������� ���������
  // �� ������ ����������� ������������
  GlobalData:= MapViewOfFile(MMFHandle, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(TGlobalDLLData));
  GlobalData^.MyAppWnd:=0;
  GlobalData^.hookCount:=0;
  logstr('OpenData');
  if GlobalData = nil then
  begin
    CloseHandle(MMFHandle);
    MessageBox(0, 'Can''t make MapViewOfFile', 'Message from keyhook.dll', 0);
    Exit;
  end
  else
    GlobalData.Tag:=0;
end;

procedure CloseGlobalData();
begin
  UnmapViewOfFile(GlobalData);
  CloseHandle(MMFHandle);
end;

procedure DLLEntryPoint(dwReason: DWord); stdcall;
begin
  case dwReason of
    DLL_PROCESS_ATTACH: OpenGlobalData;
    DLL_PROCESS_DETACH: CloseGlobalData;
  end;
end;

exports
  SetHook, SetTag;

begin
  GlobalData:=nil;
  //MessageBox(0, PChar(Application.ExeName), 'Message from keyhook.dll', 0);
  {�������� �������� ���������� DLLProc}
  // ���������� ���� �� ������������� � xnet
  //lastDll:=DLLProc;
  //DLLProc:= @DLLEntryPoint;
  // ����������� ��������� ��� ��������� ����� ������������� ������
  // ���������� � ��������
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.
