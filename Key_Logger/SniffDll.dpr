library SniffDll;

uses
  WinTypes, WinProcs, dialogs, inifiles, sysutils;

const
  //KeyEvent=WM_USER+1;
  //MouseEvent=KeyEvent+1;
  //WinTitle='TSnfwin';
  MMFName: PChar = 'KeyMMF'; // имя объекта файлового отображения

{структура, поля которой будут отображены в файл подкачки}
type
  PGlobalDLLData = ^TGlobalDLLData;

  TGlobalDLLData = packed record
    MouseHookHandle: HWND; // дескриптор установленной ловушки
    KeyHookHandle:array [0..100] of HWND; // дескриптор установленной ловушки
    hookCount:integer;
    MyAppWnd: HWND; // дескриптор нашего приложения
    Tag:integer;
  end;


var
  GlobalData: PGlobalDLLData;
  // ссылка на файл отображения
  MMFHandle: THandle;
  WM_KeyHOOK:cardinal;
  wm_MouseHook:cardinal;

  lastDll:TDLLProc;




//0-15	Счетчик повторов. Если нажать клавишу и держать ее в нажатом состоянии, несколько сообщений WM_KEYDOWN и WM_SYSKEYDOWN будут слиты в одно. Количество объединенных таким образом сообщений
//16-23	OEM скан-код клавиши. Изготовители аппаратуры (OEM - Original Equipment Manufacturer) могут заложить в своей клавиатуре различное соответствие скан-кодов и обозначений клавиш. Скан-код генерируется клавиатурным контроллером. Это тот самый код, который получают в регистре AH программы MS-DOS, вызывая прерывание INT16h
//24	Флаг расширенной клавиатуры. Этот бит установлен в 1, если сообщение соответствует клавише, имеющейся только на расширенной 101- или 102-клавишной клавиатуре. Это может быть одна из следующих клавиш: <Home>, <End>, <PgUp>, <PgDn>, <Insert>, <Delete>, клавиши дополнительной клавиатуры.
//25-26	Не используются
//27-28	Зарезервированы для использования Windows
//29	Код контекста. Этот бит равен 1, если сообщение соответствует комбинации клавиши <Alt> с любой другой, и 0 в противном случае
//30	Предыдущее состояние клавиши. Если перед приходом сообщения клавиша, соответствующая сообщению, была в нажатом состоянии, этот бит равен 1. В противном случае бит равен 0
//31	Флаг изменения состояния клавиши (transition state). Если клавиша была нажата, бит равен 0, если отпущена - 1

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
    // открываем для записи
    append(f);
  end
  else
  begin
    AssignFile(f, c_path);
    ReWrite(f);
  end;
  // запись строки во второй файл
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
      //Устанавливаю HOOK, если он не установлен (switch=true)
      GlobalData^.MyAppWnd:= hMainProg;
      str:='HookMainWnd '+ inttostr(hMainProg); logstr(StrToAnsi(str));
      // 0 - id потока, для глобальных зуков =0           d
      hookHandle:=SetWindowsHookEx(WH_KEYBOARD, @KeyHookProc, HInstance, 0);
      GlobalData^.KeyHookHandle[GlobalData^.hookCount] := hookHandle;
      inc(GlobalData^.hookCount);
    end;
    result:=hookHandle;
    str:='HookCount '+ inttostr(GlobalData^.hookCount); logstr(StrToAnsi(str));
  end
  else
  begin
    //Удаляю функцию-фильтр, если она установлена (т.е. switch=false)
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
  {регестрируем свой тип сообщения в системе}
  WM_KeyHOOK:= RegisterWindowMessage('WM_OburecKeyHook');
  WM_MouseHOOK:= RegisterWindowMessage('WM_OburecMouseHook');
  {получаем объект файлового отображения}
  // MMFHandle:= CreateFileMapping(DWord(-1), nil, PAGE_READWRITE, 0, SizeOf(TGlobalDLLData), MMFName); // можно так, но лучше: см. след. строку
  MMFHandle:= CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(TGlobalDLLData), MMFName);
  if MMFHandle = 0 then
  begin
    MessageBox(0, 'Can''t create FileMapping', 'Message from keyhook.dll', 0);
    Exit;
  end;
  // отображаем глобальные данные на АП вызывающего процесса и получаем указатель
  // на начало выделенного пространства
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
  {назначим поцедуру переменной DLLProc}
  // закоментил чтоб не конфликтовало с xnet
  //lastDll:=DLLProc;
  //DLLProc:= @DLLEntryPoint;
  // назначенную процедуру для отражения факта присоединения данной
  // библиотеки к процессу
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.
