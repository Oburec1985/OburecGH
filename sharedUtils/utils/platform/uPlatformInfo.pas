unit uPlatformInfo;

interface
uses
  Windows,SysUtils,StrUtils,OpenGl,Classes,ComCtrls, dialogs, psAPI;
  type
  pstring = array of string;

  cPlatform = class
  private
    Extensions:TStringList;// список строк с поддерживаемыми расширениями
  private
    function CheckExtension(name:string):boolean;
  public
    function getLightingState:boolean;
    procedure ShowExtInListView(lv:tlistview);
    function CheckARBShaderExt:boolean;
    function CheckTextureExt:boolean;
    function CheckBGRAExt:boolean;
    // проверка поддержки работы с ARB буферами
    function CheckARBBufferExt:boolean;
    Procedure GetExt;
    procedure contextInit(sender:tobject);    
    constructor create;
    destructor destroy;
  end;

// ------------- Получение информации об операционной системе.
function GetOsVersion:string;
// ------------- Получение информации о OpenGl
function GetGlVersion:string;
// ------------- Получение информации о расширениях OpenGl
function GetGlExtension:string;
// ------------- Строку в массив строк
function GetStrList(s:string;del:string):pstring;
// ------------- Отобразить массив строк в TListView
procedure AddStringsToLV(lv:TListView;s:pstring);
// Получить количество занятой процессом памяти
function GetProcMem:cardinal;


implementation

function GetProcMem:cardinal;
var
  pmc: PPROCESS_MEMORY_COUNTERS;
  cb: Integer;
begin
  cb := SizeOf(_PROCESS_MEMORY_COUNTERS);
  GetMem(pmc, cb);
  pmc^.cb := cb;
  if GetProcessMemoryInfo(GetCurrentProcess, pmc, cb) then
    result:= pmc^.WorkingSetSize;
  FreeMem(pmc);
end;


Constructor cPlatform.Create;
begin
  Extensions:=tstringlist.Create;
end;

destructor cPlatform.destroy;
begin
  extensions.Clear;
  extensions.Destroy;
end;

function cPlatform.getLightingState:boolean;
var b:boolean;
begin
  glgetbooleanv(GL_LIGHTING,@b);
  result:=b;
end;

procedure cPlatform.contextInit(sender:tobject);
begin
  GetExt;
end;

Procedure cPlatform.GetExt;
var str:string;
    pstr:pstring;
    i:integer;
begin
  pstr:=GetStrList(GetGlExtension,' ');
  for i := 0 to length(pstr)-1 do
  begin
    extensions.Add(pstr[i]);
  end;
end;

procedure cPlatform.ShowExtInListView(lv:tlistview);
var s:pstring;
begin
  s:=GetStrList(GetGlExtension,' ');
  AddStringsToLV(lv,s);
end;

// проверка поддержки работы с ARB буферами
function cPlatform.CheckARBBufferExt:boolean;
begin
  result:=CheckExtension('GL_ARB_vertex_buffer_object');
end;

function cPlatform.CheckARBShaderExt:boolean;
begin
  result:=CheckExtension('gl_ARB_shader_objects');
end;

function cPlatform.CheckTextureExt:boolean;
begin
  result:=CheckExtension('gl_ARB_shader_objects');
end;

function cPlatform.CheckBGRAExt:boolean;
begin
  result:=CheckExtension('GL_EXT_bgra');
end;


function cPlatform.CheckExtension(name:string):boolean;
var i:integer;
begin
  result:=extensions.Find(name,i);
  if not result then
  begin
    showmessage('расширение '+ name+ ' не поддерживаетс');
  end;
end;

//Operating system	Version number	dwMajorVersion	dwMinorVersion	Other
//Windows 10	10.0*	10	0	OSVERSIONINFOEX.wProductType == VER_NT_WORKSTATION
//Windows Server 2016	10.0*	10	0	OSVERSIONINFOEX.wProductType != VER_NT_WORKSTATION
//Windows 8.1	6.3*	6	3	OSVERSIONINFOEX.wProductType == VER_NT_WORKSTATION
//Windows Server 2012 R2	6.3*	6	3	OSVERSIONINFOEX.wProductType != VER_NT_WORKSTATION
//Windows 8	6.2	6	2	OSVERSIONINFOEX.wProductType == VER_NT_WORKSTATION
//Windows Server 2012	6.2	6	2	OSVERSIONINFOEX.wProductType != VER_NT_WORKSTATION
//Windows 7	6.1	6	1	OSVERSIONINFOEX.wProductType == VER_NT_WORKSTATION
//Windows Server 2008 R2	6.1	6	1	OSVERSIONINFOEX.wProductType != VER_NT_WORKSTATION
//Windows Server 2008	6.0	6	0	OSVERSIONINFOEX.wProductType != VER_NT_WORKSTATION
//Windows Vista	6.0	6	0	OSVERSIONINFOEX.wProductType == VER_NT_WORKSTATION
//Windows Server 2003 R2	5.2	5	2	GetSystemMetrics(SM_SERVERR2) != 0
//Windows Server 2003	5.2	5	2	GetSystemMetrics(SM_SERVERR2) == 0
//Windows XP	5.1	5	1	Not applicable
//Windows 2000	5.0	5	0	Not applicable

function GetOsVersion:string;
var str:string;
    VersionInformation:OSVERSIONINFO;
begin
  VersionInformation.dwOSVersionInfoSize:=sizeof(VersionInformation);
  GetVersionEx(VersionInformation);
  str:='OS Version '+
  intToStr(VersionInformation.dwMajorVersion)+'.'+
  intToStr(VersionInformation.dwMinorVersion)+' '+VersionInformation.szCSDVersion;
  Result:=str;
end;

function GetGlVersion:string;
var str:string;
begin
  str:='glVendor ' +glGetString(GL_VENDOR)+' GlVersion '+
  glGetString(GL_Version) +' GlRenderer ' +glGetString(GL_RENDERER);
  Result:=str;
end;

function GetGlExtension:string;
var str:string;
begin
  str:='GlExtension '+glGetString(GL_EXTENSIONS);
  Result:=str;
end;

function GetStrList(s:string; del:string):pstring;
var
    count,len,length1,i,start:integer;
    pstr:pstring;
begin
  // ----------- Находим число строк ----------------
  len:=0;
  count:=Length(s);
  for i:=1 to count do
  begin
    if i=count then
    begin
     len:=len+1;
     break;
    end;
    if s[i]=' ' then
      begin
        len:=len+1;
      end;
  end;
  SetLength(pstr,len);

  //------------ Записываем разделленные строчки в массив строк
  start:=1;
  len:=0;
  for i:=1 to count do
  begin
    if i=count then
    begin
     len:=len+1;
     length1:=count+1-start;
     pstr[len-1]:=Copy(S, Start, Length1);
     break;
    end;
    if s[i]=' ' then
    begin
     len:=len+1;
     length1:=i-start;
     pstr[len-1]:=Copy(S, Start, Length1);
     start:=i+1;
    end;
  end;
  Result:=pstr;
end;

procedure AddStringsToLV(lv:TListView;s:pstring);
var i:integer;
begin
  // -------- Отображение расширений OpenGl в TListView
  for i:=0 to Length(s)-1 do
  begin
    lv.Items.Add;
    lv.Items.Item[i].Caption:=s[i];
  end;
end;

end.
