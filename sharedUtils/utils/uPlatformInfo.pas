unit uPlatformInfo;

interface
uses
  Windows,SysUtils,StrUtils,OpenGl,Classes,ComCtrls, dialogs, psAPI;
  type
  pstring = array of string;

  cPlatform = class
  private
    Extensions:TStringList;// ������ ����� � ��������������� ������������
    pstr:pstring;
  private
    function CheckExtension(name:string):boolean;
  public
    function getLightingState:boolean;
    procedure ShowExtInListView(lv:tlistview);
    function CheckARBShaderExt:boolean;
    function CheckTextureExt:boolean;
    function CheckBGRAExt:boolean;
    // �������� ��������� ������ � ARB ��������
    function CheckARBBufferExt:boolean;
    Procedure GetExt;
    procedure contextInit(sender:tobject);    
    constructor create;
    destructor destroy;
  end;

// ------------- ��������� ���������� �� ������������ �������.
function GetOsVersion:string;
// ------------- ��������� ���������� � OpenGl
function GetGlVersion:string;
// ------------- ��������� ���������� � ����������� OpenGl
function GetGlExtension:string;
// ------------- ������ � ������ �����
function GetStrList(s:string;del:string):pstring;
// ------------- ���������� ������ ����� � TListView
procedure AddStringsToLV(lv:TListView;s:pstring);
// �������� ���������� ������� ��������� ������
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
var
  I: Integer;
begin
  extensions.Clear;
  extensions.Destroy;
  for I := 0 to length(pstr) - 1 do
  begin
    setlength(pstr[i],0);
  end;
  setlength(pstr,0);
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

// �������� ��������� ������ � ARB ��������
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
    showmessage('���������� '+ name+ ' �� �������������');
  end;
end;

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
  // ----------- ������� ����� ����� ----------------
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

  //------------ ���������� ������������ ������� � ������ �����
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
  // -------- ����������� ���������� OpenGl � TListView
  for i:=0 to Length(s)-1 do
  begin
    lv.Items.Add;
    lv.Items.Item[i].Caption:=s[i];
  end;
end;

end.
