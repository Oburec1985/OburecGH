unit uCommonMath;

interface

uses
  uCommonTypes, windows, sysutils, math,
  dialogs,
  graphics, strUtils, inifiles, classes;

type
  cString =Class
  public
    str:string;
  End;

// �������� ����� opt - ����������� �����. flag - ����� ��� ���������
function CheckFlag(opt: cardinal; flag: cardinal): boolean;
procedure setflag(var opt: cardinal; flag: cardinal);
procedure dropflag(var opt: cardinal; flag: cardinal);
procedure setflag_int(var opt: integer; flag: integer);
procedure dropflag_int(var opt: integer; flag: integer);
function CheckFlag_int(opt: integer; flag: integer): boolean;
function generatecolorp3(i: integer): point3;
// ----------------- ����������� ������� � ���
function inttoRGB(color: integer): point3;
function RGBtoInt(color: point3): integer;
function RGBtoBGR(color: integer): integer;
// ���������� ������� �� ���� �����
function max(x, y: double; var b: boolean): double; overload;
function max(x, y: single; var b: boolean): single; overload;
// ���������� ������� �� ���� �����
function max(x, y: integer): integer; overload;
// ���������� �������
function min(x, y: double; var b: boolean): double;overload;
function min(x, y: single; var b: boolean): single; overload;
// ���������� �������
function min(x, y: integer): integer; overload;
// ������� ���������� ������ ����� �� ������
function SubP(p1, p2_: point2): point2;overload;
function SubP(p1, p2: point3): point3;overload;
// �������� ������ �� ������
function ScaleP2(v: single; p: point2): point2;
function SummP2(p0, p1: point2): point2;
function DecP2(p0, p1: point2): point2;
function DecP2d(p0, p1: point2d): point2d;
// ������������ ���. (����������� �� ����� ��� ������� ��������� _xxx � ������� �������)
function ModName(name: string; incrementStart:boolean): string;overload;
function ModName(name: string; incrementStart:boolean; var numstr:string): string;overload;
// ����� ��������� ������ � ������� fromPos
function TailPos(const S, SubStr: AnsiString; fromPos: integer): integer;
// �������� ���������. ������������� ������� ������� � ������� p ���� �� ���������
// �� ���� �� ������������ �������� � ������ tabs. index - ����� ������� ��� ������ �����������
function GetSubString(src: string; tabs: string; p: integer; var index: integer)
  : string;
// �� ��, ��� � ����������, �� �� ��������� ����������, ���� ��� ������ ������� "aaa;bbb"
// ��� ���� ������ ��������� ��������� ���� ����� ������� bracketchar ���� �������������� ������ ��� ����� ������
function GetSubStringExt(src: string; tabs: string; p: integer;  bracketChar: char; var index: integer): string;
// index - ����� ��������
function getSubStrByIndex(src:string; tabs:char; p_start, index:integer):string;
function deleteOuterBracket(str:string; bracket:char):string;
// ������� �� ����� ������ ������� �� ���������� �������
Function trimChars(str:string):string;
// ����������� ���� � ����� �� ���� �������
function TrimPath(path: string): string;
// �������� ��� � ������ ������ �����
function isValue(Str: string): boolean;
// �������� ��� � ������ ������ �����
function isDigit(Str: string): boolean;
// �������������� ������ � ����� ��� ����� ����������� . ��� ,
function strtoFloatExt(Str: string): double;
function FloatToStrEx(f:double; sep:char):string;
function strtoIntExt(Str: string): integer;
// � ������ �����������
function readFloatFromIni(ifile:tinifile; sec,ident:string):double;
// �������� ��� ����� ��� ����������
function TrimExt(Str: string): string;
// �������� ����� ������ �� ������ substr �� Ch
function ReplaseChars(src, SubStr: string; ch: char): string;
// ������� �� ������ src ��������� substr ������ ������ ���������
function DeleteSubstr(src, SubStr: string; index: integer): string;
// ������ ������� � �������� ������������� ������
function ReplaceSubstr(src, SubStr, newtext: string; index: integer): string;
function DeleteChars(src: string; ch: char): string;
// �������� ������ �� � ������
function replaceChar(Str: string; ch, newchar: char): string;
function replaceSpace(Str: string; newchar: char): string;
function isdig(ch:ansichar):boolean;overload;
function isdig(ch:char):boolean;overload;
// �������� ��������� ���������� �����
function GetBaseNum(str:string):string;
// �������� ��������� ���������� ����� � ����� ����� _
function getendnum(str:string):string;
// �������� �� ������ �������� (Abc123def, 23) = 123
function getSubNum(str:string; sub:integer):integer;
function DelNullCharsInNumStr(str:string):string;
// �������� ��������� ���������� ��������� ������ ��� ������
function GetLastStr(str:string):string;
// ���������� 2 ������ � ������ ������ ������� ������. ������ � ������� ������� �� ��������� ������
function NameComparatorStrBaseNum(p1,p2:string):integer;
function CheckPosSubstr(substr, str:string):boolean;

// ������� ������� �� ������
function DeleteSpace(src:string):string;
// �������� �� ��������� ��������. ����������� ����� ������ ��������� �
// ��������� '='. ����������� ����� ����������� ;
function FindInPars(pars:tstringlist; key:string; var ind:integer):boolean;
function ParsStrParamNoSort(src:string; separator:string):tstringlist;
function ParsStrParam(src:string):tstringlist;overload;
function ParsStrParam(src:string; separator:string):tstringlist;overload;
function ParsStrParamExt(src:string; separator:string; bracketChar:char):tstringlist;overload;
function ParsToStr(pars:tstringlist):string;
function delParams(str, delparams:string; separator:string):string;
// ������� ������ ���������, ���������� ������ � �������� ��������� � pars
function  updateParams(src:string; newparams:string):string;overload;
function updateParams(src:string; newparams:string; ignorekey, ignoreVals:string):string;overload;
procedure updateParams(pars:tstringlist; opts:string; separator:string);overload;

procedure ChangeParam(pars:tstringlist; key:string; v:string);
function ChangeParamF(str:string; key:string; v:string):string;
procedure addParam(pars:tstringlist; key:string;v:string);
function addParamF(str:string; key:string;v:string):string;
function GetParam(str:string; key:string):string;
function GetParamExt(str:string; key:string; tab:char):string;
// �������� ������ �� ������ �����
function GetParsObj(pars:tstringlist;i:integer):cstring;overload;
function GetParsObj(pars:tstringlist;key:string):cstring;overload;
function GetParsValue(pars:tstringlist;i:integer):string;overload;
function GetParsValue(pars:tstringlist;key:string):string;overload;
// ������� �������
procedure ClearParsResult(parsres:tstringlist);
// ������� � �������� �������
procedure delPars(slist:tstringlist);
// ��������� ����� � v ����������� ����������� 2 � �������
Function NearestOrd2(v:double):integer;
Function IniReadFloatEx(ifile:tinifile;section, key:string;default:double):double;

function GetObjectClass(APointer: Pointer): TClass;
function CheckStr(str:string):boolean;
function StrtoBoolExt(str:string):boolean;
function decI64(i1,i2:int64):int64;
function LowCase(str: string): string;

function toSec(t: double; ind:integer): double;
function SecToTime(t: double; ind:integer): double;


// ������ � ������
function bytetoBinStr(b:byte):string;
function ReverseBits(b:byte):byte;
Function CheckHex(str:string):boolean;

 // ������� ��� ������ ������������ � ������������� �������� � ������� Double.
 // ���������:
 //   Data: ������� ������������ ������ �������� Double.
 //   MinVal: �������� ��������. ����� ����� �������� ����������� ��������, ��������� � �������.  //   MaxVal: �������� ��������. ����� ����� �������� ������������ ��������, ��������� � �������.  // ���������� True, ���� ������ �� ���� � ����� ������� ��������, ����� False.
 function FindMinMaxDouble(const Data: array of double; var MinVal, MaxVal: Double): Boolean;
 // ������� ��� ������ ������������� �������� � ��� ������� � ������� Double.
  // ���������:
  //   Data: ������� ������������ ������ �������� Double.
  //   MaxVal: �������� ��������. ����� ����� �������� ������������ ��������, ��������� � �������.
  //   MaxIndex: �������� ��������. ����� ����� ������� ������ ��������, ����������� MaxVal.
  //             ���� ������ ����, MaxIndex ����� ����� -1.
  // ���������� True, ���� ������ �� ���� � ����� ������� ��������, ����� False.
 function FindMaxAndIndex(const Data: array of double; var MaxVal: Double; var MaxIndex: Integer): Boolean;

const

  c_max_i64 = 9223372036854775807;
  chars = '0123456789,.';
  sqrt3 = 1.7320508075688772935274463415059;
  tan30 = 0.57735026918962576450914878050196;
  sin60 = 1.7320508075688772935274463415059/2;
  c_pi = 3.1415926535;
  c_2pi = 3.1415926535*2;
  c_radtodeg = 57.295779513;
  c_degtorad = 0.01745329251994329576923690768489;
  c_asin60 = 1.0471975511965977461542144610932;
  c_Threshold = 0.15;
  c_degThreshold = 0.1;
  tan80 = 5.67139010260751;


const
  colors: array [0 .. 51] of integer = (clBlack, clMaroon, clGreen, clOlive,
    clNavy, clPurple, clTeal, clGray, clSilver, clRed, clLime, clYellow,
    clBlue, clFuchsia, clAqua, clWhite, clMoneyGreen, clSkyBlue, clCream,
    clMedGray, clActiveBorder, clActiveCaption, clAppWorkSpace, clBackground,
    clBtnFace, clBtnHighlight, clBtnShadow, clBtnText, clCaptionText,
    clDefault, clGrayText, clGradientActiveCaption, clGradientInactiveCaption,
    clHighlight, clHighlightText, clHotLight, clInactiveBorder,
    clInactiveCaption, clInactiveCaptionText, clInfoBk, clInfoText, clMenu,
    clMenuBar, clMenuHighlight, clMenuText, clNone, clScrollBar, cl3DDkShadow,
    cl3DLight, clWindow, clWindowFrame, clWindowText);

implementation


function bytetoBinStr(b:byte):string;
var
  i:integer;
begin
  result:='';
  for I := 7 downto 0 do
  begin
    if (b and (1 shl i))<>0 then
      result:=result+'1'
    else
      result:=result+'0';
  end;
end;

function ReverseBits(b:byte):byte;
var
  i:integer;
  r:byte;
begin
  r:=0;
  for I := 0 to 7 do
  begin
    r:=(r shl 1) or (b and 1);
    b:=b shr 1;
  end;
  result:=r
end;

Function CheckHex(str:string):boolean;
var
  I: Integer;
const
  c_str ='0123456789abcdefABCDEF';
begin
  result:=true;
  for I := 1 to length(str) do
  begin
    if pos(str[i], c_str)<1 then
    begin
      result:=false;
      exit;
    end;
  end;
end;



function toSec(t: double; ind:integer): double;
begin
  case ind of
    0: result:=t; //sec
    1: result:=t*60; //min
    2: result:=t*3600; //hour
  end;
end;

function SecToTime(t: double; ind:integer): double;
begin
  case ind of
    0: result:=t; //sec
    1: result:=t/60;           //min
    2: result:=t/3600;           //hour
  end;
end;


function LowCase(str: string): string;
var
  ch:char;
  I: Integer;
begin
  result:='';
  for I := 1 to length(str) do
  begin
    ch:=str[i];
    case ch of
      'A'..'Z': ch := CHR(ORD(ch) + 32);
      '�'..'�': ch := CHR(ORD(ch) + 32);
      else
      begin

      end;
    end;
    result:=result+ch;
  end;
end;

function decI64(i1,i2:int64):int64;
begin
  result:=i2-i1;
  if result<0 then
  begin
    result:=c_max_i64+result;
  end;
end;

function CheckStr(str:string):boolean;
begin
  result:= (str <> '') and (str <> '_');
end;

function StrToBoolExt(str:string):boolean;
begin
  if (str = '') or (str = '_') then
    result:=false
  else
  begin
    str:=LowCase(str);
    if str='���' then
    begin
      result:=true;
    end
    else
    begin
      if str='����' then
      begin
        result:=false;
      end
      else
      begin
        result:=StrToBool(str);
      end;
    end;
  end;
end;


function DeleteSpace(src:string):string;
var
  I: Integer;
begin
  result:='';
  for I := 1 to length(src) do
  begin
    if src[i]<>' ' then
      result:=result+src[i];
  end;
end;


function GetParamExt(str:string; key:string; tab:char):string;
var
  p:tstringlist;
  ind:integer;
  cstr:cstring;
begin
  result:='';
  p:=ParsStrParamNoSort(str, tab);
  if FindInPars(p,key,ind) then
  begin
    cstr:=cstring(p.Objects[ind]);
    result:=cstr.str;
  end;
  delpars(p);
  p.Destroy;
end;


function GetParam(str:string; key:string):string;
var
  p:tstringlist;
  ind:integer;
  cstr:cstring;
begin
  result:='';
  p:=ParsStrParamNoSort(str, ',');
  if FindInPars(p,key,ind) then
  begin
    cstr:=cstring(p.Objects[ind]);
    result:=cstr.str;
  end;
  delpars(p);
  p.Destroy;
end;

function ChangeParamF(str:string; key:string; v:string):string;
var
  p:tstringlist;
  ind:integer;
  cstr:cstring;
begin
  p:=ParsStrParamNoSort(str, ',');
  if FindInPars(p,key,ind) then
  begin
    cstr:=cstring(p.Objects[ind]);
    cstr.str:=v;
  end;
  str:=ParsToStr(p);
  result:=str;
  delpars(p);
  p.Destroy;
end;



procedure ChangeParam(pars:tstringlist; key:string; v:string);
var
  ind:integer;
  cstr:cstring;
begin
  if FindInPars(pars,key,ind) then
  begin
    cstr:=cstring(pars.Objects[ind]);
    cstr.str:=v;
  end;
end;


procedure addParam(pars:tstringlist; key:string;v:string);
var
  ind:integer;
  cstr:cstring;
begin
  if FindInPars(pars,key,ind) then
  begin
    cstr:=cstring(pars.Objects[ind]);
    cstr.str:=v;
  end
  else
  begin
    cstr:=cString.Create;
    cstr.str:=v;
    pars.AddObject(key,cstr);
  end;
end;

function addParamF(str:string; key:string;v:string):string;
var
  p:tstringlist;
  ind:integer;
  cstr:cstring;
begin
  p:=ParsStrParamNoSort(str, ',');
  addParam(p, key, v);
  result:=ParsToStr(p);
  delpars(p);
  p.Destroy;
end;

function ParsToStr(pars:tstringlist):string;
var
  v:cstring;
  I: Integer;
begin
  result:='';
  for I := 0 to pars.Count - 1 do
  begin
    v:=cstring(pars.Objects[i]);
    if i<>pars.Count - 1 then
      result:=result+pars.Strings[i]+'='+v.str+','
    else
      result:=result+pars.Strings[i]+'='+v.str;
  end;
end;

function ParsStrParamExt(src:string; separator:string; bracketChar:char):tstringlist;
var
  i,j,p:integer;
  str, param:string;
  Value:cString;
begin
  i:=0;
  result:=tstringlist.Create;
  result.Sorted:=true;
  while i<=length(src) do
  begin
    str:=GetSubStringExt(src,separator,i, bracketChar,i);
    if str<>'' then
    begin
      p:=pos('=',str);
      if p>0 then
      begin
        param:=DeleteSpace(GetSubStringExt(str,'=',1,bracketChar,j));
        value:=cString.Create;
        value.str:=deleteOuterBracket(GetSubStringExt(str,separator,j+1,bracketChar,j),'"');
        Result.addobject(param, value);
      end;
    end;
    if i=-1 then
      break;
    i:=i+1;
  end;
end;

function delParams(str, delparams:string; separator:string):string;
var
  p, p1:tstringlist;
  I, j: Integer;
  k, k1:string;
  cstr, cstr1:cstring;
  b:boolean;
begin
  p:=ParsStrParamNoSort(str, separator);
  p1:=ParsStrParamNoSort(delparams, separator);
  for i := 0 to p1.Count - 1 do
  begin
    k1:=p1.strings[i];
    b:=false;
    j:=p.Count-1;
    for j := p.Count - 1 downto 0 do
    begin
      k:=p.strings[j];
      if k1=k then
      begin
        b:=true;
        break;
      end;
    end;
    if b then
    begin
      p.Delete(j);
    end;
  end;
  result:=ParsToStr(p);
  ClearParsResult(p);
  ClearParsResult(p1);
  p.Destroy;
  p1.Destroy;
end;

function  updateParams(src:string; newparams:string):string;
var
  p, p1:tstringlist;
  I, j: Integer;
  key:string;
  cstr, cstr1:cstring;
begin
  p:=ParsStrParamNoSort(newparams, ',');
  p1:=ParsStrParamNoSort(src, ',');
  for I := 0 to p.Count - 1 do
  begin
    key:=p.Strings[i];
    cstr:=cstring(p.Objects[i]);
    if FindInPars(p1,key, j) then
    begin
      cstr1:=cstring(p1.Objects[j]);
      cstr1.str:=cstr.str;
    end
    else
    begin
      cstr1:=cString.Create;
      cstr1.str:=cstr.str;
      p1.AddObject(key,cstr1);
    end;
  end;
  result:=ParsToStr(p1);
  ClearParsResult(p);
  ClearParsResult(p1);
  p.Destroy;
  p1.Destroy;
end;


function updateParams(src:string; newparams:string; ignorekey, ignoreVals:string):string;
var
  p, p1:tstringlist;
  I, j: Integer;
  key:string;
  cstr, cstr1:cstring;
begin
  p:=ParsStrParamNoSort(newparams, ',');
  p1:=ParsStrParamNoSort(src, ',');
  for I := 0 to p.Count - 1 do
  begin
    key:=p.Strings[i];
    cstr:=cstring(p.Objects[i]);
    if pos(key,ignorekey)=0 then // ���� �� ������������ ����
    begin
      if pos(cstr.str, ignoreVals)=0 then // ���� �� ������������ ��������
      begin
        if (ignoreVals=' ') or (ignoreVals='_') then // ���� �� ������������ ������ ��������
        begin
          if cstr.str='' then
            continue;
        end;
        if FindInPars(p1,key, j) then
        begin
          cstr1:=cstring(p1.Objects[j]);
          cstr1.str:=cstr.str;
        end
        else
        begin
          cstr1:=cString.Create;
          cstr1.str:=cstr.str;
          p1.AddObject(key,cstr1);
        end;
      end;
    end;
  end;
  result:=ParsToStr(p1);
  ClearParsResult(p);
  ClearParsResult(p1);
  p.Destroy;
  p1.Destroy;
end;

procedure updateParams(pars:tstringlist; opts:string; separator:string);
var
  newpars:tstringlist;
  I: Integer;
  cstr
  //, cstr1
  :cstring;
  key:string;
begin
  clearParsResult(pars);
  newpars:=ParsStrParamNoSort(opts, separator);
  for I := 0 to newpars.Count - 1 do
  begin
    key:=newpars.Strings[i];
    cstr:=cstring(newpars.Objects[i]);
    //cstr1:=cstring.create;
    //cstr1.str:=cstr.str;
    pars.AddObject(key,cstr);
  end;
  //delpars(newpars);
  newpars.Destroy;
end;

function FindInPars(pars:tstringlist; key:string; var ind:integer):boolean;
var
  I: Integer;
begin
  ind:=-1;
  result:=false;
  for I := 0 to pars.Count - 1 do
  begin
    if pars.strings[i]=key then
    begin
      result:=true;
      ind:=i;
      exit;
    end;
  end;
end;

function ParsStrParamNoSort(src:string; separator:string):tstringlist;
var
  i,j,p:integer;
  str,
  lstr, param:string;
  Value:cString;
begin
  i:=0;
  result:=tstringlist.Create;
  while i<=length(src) do
  begin
    str:=GetSubString(src,separator,i, i);
    if str<>'' then
    begin
      p:=pos('=',str);
      if p>0 then
      begin
        param:=DeleteSpace(GetSubString(str,'=',1,j));
        value:=cString.Create;
        lstr:=GetSubString(str,separator,j+1,j);
        value.str:=deletechars(lstr,'"');
        Result.addobject(param, value);
      end;
    end;
    if i=-1 then
      break;
    i:=i+1;
  end;
end;


function ParsStrParam(src:string; separator:string):tstringlist;overload;
var
  i,j,p:integer;
  str, param:string;
  Value:cString;
begin
  i:=0;
  result:=tstringlist.Create;
  result.Sorted:=true;
  while i<=length(src) do
  begin
    str:=GetSubString(src,separator,i, i);
    if str<>'' then
    begin
      p:=pos('=',str);
      if p>0 then
      begin
        param:=DeleteSpace(GetSubString(str,'=',1,j));
        value:=cString.Create;
        value.str:=deletechars(GetSubString(str,separator,j+1,j),'"');
        Result.addobject(param, value);
      end;
    end;
    if i=-1 then
      break;
    i:=i+1;
  end;
end;

function ParsStrParam(src:string):tstringlist;
var
  i,j,p:integer;
  str, param:string;
  Value:cString;
begin
  i:=1;
  result:=tstringlist.Create;
  result.Sorted:=true;
  while i<=length(src) do
  begin
    if src[i]='p' then
    begin
      if src[i+1]='=' then
      begin
        str:=GetSubString(src,'"',i+3, i);
        str:='p="'+str+'"';
        inc(i);
      end;
    end
    else
    begin
      str:=GetSubString(src,';',i, i);  // i �������� �� ����� �����������
      if i=-1 then
        i:=length(src)+1;
    end;
    if str<>'' then
    begin
      p:=pos('=',str);
      if p>0 then
      begin
        param:=DeleteSpace(GetSubString(str,'=',1,j));
        value:=cString.Create;
        // ���� ����� ��� ��� � ������� �� "____"
        //value.str:=deletechars(GetSubString(str,';',j+1,j),'"');
        value.str:=deletechars(GetSubStringExt(str,';',j+1,'"',j),'"');
        Result.addobject(param, value);
        if i=-1 then
          break;
      end;
    end;
    i:=i+1;
  end;
end;


function GetParsValue(pars:tstringlist;i:integer):string;
var
  res:cString;
begin
  res:=cstring(pars.objects[i]);
  result:=res.str;
end;

function GetParsValue(pars:tstringlist;key:string):string;
var
  i:integer;
  cstr:cstring;
begin
  if findinpars(pars, key, i) then
  begin
    cstr:=cstring(cstring(pars.objects[i]));
    result:=cstr.str;
  end
  else
    result:='_';
end;

function GetParsObj(pars:tstringlist;i:integer):cstring;
var
  res:cString;
begin
  res:=cstring(pars.objects[i]);
  result:=res;
end;

function GetParsObj(pars:tstringlist;key:string):cstring;
var
  i:integer;
  cstr:cstring;
begin
  if findinpars(pars, key, i) then
  begin
    cstr:=cstring(cstring(pars.objects[i]));
    result:=cstr;
  end
  else
    result:=nil;
end;

procedure ClearParsResult(parsres:tstringlist);
var
  I: Integer;
  obj:cString;
begin
  for I := 0 to parsres.Count - 1 do
  begin
    obj:=cString(parsres.Objects[i]);
    obj.Destroy;
  end;
  parsres.clear;
end;

procedure delPars(slist:tstringlist);
var
  Value:cString;
  i:integer;
begin
  for I := 0 to sList.Count - 1 do
  begin
    value:=cString(slist.Objects[i]);
    Value.Destroy;
  end;
  slist.Clear;
end;

function GetObjectClass(APointer: Pointer): TClass;
var
  LMemInfo: TMemoryBasicInformation;

  {Checks whether the given address is a valid address for a VMT entry.}
  function IsValidVMTAddress(APAddress: PCardinal): Boolean;
  begin
    {Do some basic pointer checks: Must be dword aligned and beyond 64K}
    if (Cardinal(APAddress) > 65535)
      and (Cardinal(APAddress) and 3 = 0) then
    begin
      {Do we need to recheck the virtual memory?}
      if (Cardinal(LMemInfo.BaseAddress) > Cardinal(APAddress))
        or ((Cardinal(LMemInfo.BaseAddress) + Cardinal(LMemInfo.RegionSize)) < (Cardinal(APAddress) + 4)) then
      begin
        {Get the VM status for the pointer}
        LMemInfo.RegionSize := 0;
        VirtualQuery(APAddress,  LMemInfo, SizeOf(LMemInfo));
      end;
      {Check the readability of the memory address}
      Result := (Cardinal(LMemInfo.RegionSize) >= 4)
        and (LMemInfo.State = MEM_COMMIT)
        and (LMemInfo.Protect and (PAGE_READONLY or PAGE_READWRITE
          or PAGE_EXECUTE or PAGE_EXECUTE_READ or PAGE_EXECUTE_READWRITE or PAGE_EXECUTE_WRITECOPY) <> 0)
        and (LMemInfo.Protect and PAGE_GUARD = 0);
    end
    else
      Result := False;
  end;

  {Returns true if AClassPointer points to a class VMT}
  function InternalIsValidClass(AClassPointer: Pointer; ADepth: Integer = 0): Boolean;
  var
    LParentClassSelfPointer: PCardinal;
  begin
    {Check that the self pointer as well as parent class self pointer addresses
     are valid}
    if (ADepth < 1000)
      and IsValidVMTAddress(Pointer(Integer(AClassPointer) + vmtSelfPtr))
      and IsValidVMTAddress(Pointer(Integer(AClassPointer) + vmtParent)) then
    begin
      {Get a pointer to the parent class' self pointer}
      LParentClassSelfPointer := PPointer(Integer(AClassPointer) + vmtParent)^;
      {Check that the self pointer as well as the parent class is valid}
      Result := (PPointer(Integer(AClassPointer) + vmtSelfPtr)^ = AClassPointer)
        and ((LParentClassSelfPointer = nil)
          or (IsValidVMTAddress(LParentClassSelfPointer)
            and InternalIsValidClass(PCardinal(LParentClassSelfPointer^), ADepth + 1)));
    end
    else
      Result := False;
  end;

var
  SystemInfo: TSystemInfo;
begin
  GetSystemInfo(SystemInfo);
  if (DWORD(APointer) <= DWORD(SystemInfo.lpMinimumApplicationAddress)) or
    (DWORD(APointer) >= DWORD(SystemInfo.lpMaximumApplicationAddress)) or
    IsBadReadPtr(APointer, 4) then
  begin
    Result := nil;
    Exit;
  end;
  {Get the class pointer from the (suspected) object}
  Result := TClass(PCardinal(APointer)^);
  {No VM info yet}
  LMemInfo.RegionSize := 0;
  {Check the block}
  if not InternalIsValidClass(Pointer(Result), 0) then
    Result := nil;
end;

Function IniReadFloatEx(ifile:tinifile;section, key:string;default:double):double;
var
  str:string;
begin
  str:=ifile.readstring(section, key, floattostr(default));
  result:=strtoFloatExt(str);
end;

Function NearestOrd2(v:double):integer;
var
  nump:integer;
begin
  numP:=4;
  while numP<v do
  begin
    numP:=numP shl 1;
  end;
  result:=nump shr 1;
end;

function CheckPosSubstr(substr, str:string):boolean;
begin
  substr:=LowerCase(substr);
  str:=LowerCase(str);
  if pos(substr,str)>0 then
    result:=true
  else
    result:=false;
end;

function NameComparatorStrBaseNum(p1,p2:string):integer;
var
  s1,s2, str1, str2, base1, base2:ansistring;
  i, n1, n2:integer;
begin
  s1:=p1;
  s2:=p2;
  base1:=GetBaseNum(s1);
  base2:=GetBaseNum(s2);
  str1:=GetLastStr(s1);
  str2:=GetLastStr(s2);

  if base1<>'' then
  begin
    n1:=strtoint(base1);
    if base2<>'' then
    begin
      // ��������� �� ������ �����
      n2:=strtoint(base2);
      if n1>n2 then
      begin
        result:=1;
      end
      else
      begin
        if n1=n2 then
        begin
          result:=AnsiCompareText(str1,str2);
        end
        else
        begin
          if n1>n2 then
            result:=1
          else
          begin
            if n1<n2 then
              result:=-1
            else
              result:=0;
          end;
        end;
      end;
    end
    else
    begin
      // ������ � ������� ������� �� ��������� ������
      result:=1;
    end;
  end
  else
  begin
    if base2<>'' then
    begin
      // ������ � ������� ������� �� ��������� ������. S1<S2=-1
      result:=-1;
    end
    else
    begin
      result:=AnsiCompareText(s1,s2);
    end;
  end;
end;

function generatecolor(i: integer): integer;
begin
  result := colors[i];
end;

function generatecolorp3(i: integer): point3;
begin
  result := inttoRGB(generatecolor(i));
end;

function CheckFlag(opt: cardinal; flag: cardinal): boolean;
begin
  if opt and flag <> 0 then
    result := true
  else
    result := false;
end;

procedure setflag(var opt: cardinal; flag: cardinal);
begin
  opt := opt or flag;
end;

procedure dropflag(var opt: cardinal; flag: cardinal);
begin
  if CheckFlag(opt, flag) then
    opt := opt - flag;
end;

function CheckFlag_int(opt: integer; flag: integer): boolean;
begin
  if opt and flag <> 0 then
    result := true
  else
    result := false;
end;

procedure setflag_int(var opt: integer; flag: integer);
begin
  opt := opt or flag;
end;

procedure dropflag_int(var opt: integer; flag: integer);
begin
  if CheckFlag_int(opt, flag) then
    opt := opt - flag;
end;

function inttoRGB(color: integer): point3;
begin
  result.x := getRvalue(color) / 255;
  result.y := getGvalue(color) / 255;
  result.z := getBvalue(color) / 255;
end;

function RGBtoInt(color: point3): integer;
var
  r, g, b: integer;
begin
  r := trunc(color.x * 255);
  g := trunc(color.y * 255);
  b := trunc(color.z * 255);
  result := RGB(r, g, b);
end;

function RGBtoBGR(color: integer): integer;
var
  r, g, b: byte;
begin
  b := (color shr 16) and 255;
  g := (color shr 8) and 255;
  r := (color) and 255;
  result := b + (g shl 8) + (r shl 16);
end;

function max(x, y: double; var b: boolean): double;
begin
  if x > y then
  begin
    result := x;
    b := true;
  end
  else
  begin
    result := y;
    b := false;
  end;
end;

function max(x, y: single; var b: boolean): single;
begin
  if x > y then
  begin
    result := x;
    b := true;
  end
  else
  begin
    result := y;
    b := false;
  end;
end;

function max(x, y: integer): integer;
begin
  if x > y then
    result := x
  else
    result := y;
end;

function min(x, y: single; var b: boolean): single;
begin
  if x < y then
  begin
    result := x;
    b := true;
  end
  else
  begin
    result := y;
    b := false;
  end;
end;

function min(x, y: double; var b: boolean): double;
begin
  if x < y then
  begin
    result := x;
    b := true;
  end
  else
  begin
    result := y;
    b := false;
  end;
end;


function min(x, y: integer): integer;
begin
  if x < y then
    result := x
  else
    result := y;
end;

function SubP(p1, p2_: point2): point2;
begin
  result := p2((p1.x - p2_.x), (p1.y - p2_.y));
end;

function SubP(p1, p2: point3): point3;
begin
  result.x:=p2.x-p1.x;
  result.y:=p2.y-p1.y;
  result.z:=p2.z-p1.z;
end;

function SummP2(p0, p1: point2): point2;
begin
  result := p2((p1.x + p0.x), (p1.y + p0.y));
end;

function DecP2(p0, p1: point2): point2;
begin
  result := p2((p0.x - p1.x), (p0.y - p1.y));
end;

function DecP2d(p0, p1: point2d): point2d;
begin
  result := p2d((p0.x - p1.x), (p0.y - p1.y));
end;

function ScaleP2(v: single; p: point2): point2;
begin
  result := p2(v * p.x, v * p.y);
end;

function findCharPosFromEnd(ch: char; Str: string): integer;
var
  i: integer;
begin
  i := length(Str);
  result := -1;
  while i >= 1 do
  begin
    if Str[i] = ch then
    begin
      result := i;
      exit;
    end;
    dec(i);
  end;
end;

function ModStrToNum(Str: string): integer;
var
  i: integer;
begin
  if TryStrToInt(Str, i) then
    result := i
  else
    result := -1;
end;


function isdig(ch:ansichar):boolean;
begin
  result:=pos(ch,chars)>0;
end;

function isdig(ch:char):boolean;
begin
  result:=pos(ch,chars)>0;
end;

function getendnum(str:string):string;
var
  I: Integer;
begin
  result:=str;
  for I:= length(str) downto 1 do
  begin
    //if str[i]='_' then
    //begin
    //  result:=copy(str,i+1,length(str)-i);
    //  exit;
    //end;
    if not isdigit(str[i]) then
    begin
      result:=copy(str,i+1,length(str)-i);
      exit;
    end;
  end;
end;

function getSubNum(str:string; sub:integer):integer;
var
  substr:string;
  ch:char;
  ind, i:integer;
  interval:tpoint;
begin
  substr:=inttostr(sub);
  ind:=pos(substr, str);
  i:=ind;
  if i<1 then
  begin
    result:=0;
  end
  else
  begin
    interval.x:=1;
    while i-1>0 do
    begin
      ch:=str[i-1];
      if not isdigit(ch) then
      begin
        interval.x:=i;
        break;
      end;
      dec(i);
    end;
    i:=ind;
    interval.y:=length(str);
    while i+1<=length(str) do
    begin
      ch:=str[i+1];
      if not isdigit(ch) then
      begin
        interval.y:=i;
        break;
      end;
      inc(i);
    end;
    result:=strtoint(Copy(str,interval.x, interval.y-interval.x+1));
  end;
end;

function DelNullCharsInNumStr(str:string):string;
var
  I: Integer;
begin
  result:=str;
  for I := 1 to length(str) do
  begin
    if str[i]<>'0' then
    begin
      result:=copy(str,i,length(str)-i+1);
    end;
  end;
end;

// �������� ��������� ���������� �����
function GetBaseNum(str:string):string;
var
  i, l:integer;
begin
  result:='';
  l:=length(str);
  // ���� ������ ��� ���������� �� �����
  for I := 1 to l do
  begin
    if isdig(str[i]) then
    begin
    end
    else
    begin
      if i<>1 then
      begin
        result:=Copy(str,1,i-1);
        exit;
      end
      else
      begin
        exit;
      end;
    end;
  end;
end;

// �������� ��������� ���������� ��������� ������ ��� ������
function GetLastStr(str:string):string;
var
  i, l:integer;
begin
  result:=str;
  l:=length(str);
  // ���� ������ ��� ���������� �� �����
  for I := 1 to l do
  begin
    if isdig(str[i]) then
    begin

    end
    else
    begin
      result:=Copy(str,i,l-i+1);
      exit;
    end;
  end;
end;

function ModName(name: string; incrementStart:boolean): string;
var
  numstr: string;
begin
  result:=ModName(name, incrementStart, numstr);
end;

function ModName(name: string; incrementStart:boolean; var numstr:string): string;overload;
var
  i, num, numlen: integer;
  S, base, last: string;
  j: Integer;
begin
  numstr:='';
  if not incrementStart then
  begin
    i := findCharPosFromEnd('_', name);
    if i <> -1 then
    begin
      numlen := (length(name) - i);
      // �������� ����� ������� �� ������ �� ����� _xxx
      S := Copy(name, i + 1, numlen);
      num := ModStrToNum(S);
      // ���� �� ����� ������ �����
      if (num <> -1) then
      begin
        delete(name, i + 1, numlen);
        inc(num);
        last:=inttostr(num);
        s:='';
        for j := 0 to (4-length(last)-1) do
        begin
          s:=s+'0';
        end;
        result := name +s+ last;
        numstr:=s+last;
      end
      else
      // ���� �� ����� ������ �� �����
      begin
        result := name + '_001';
        numstr:='_001';
      end;
    end
    else
    // ���� ��� �� �������� "_"
    begin
      result := name + '_001';
      numstr:='_001';
    end;
  end
  else
  begin
    base:=GetBaseNum(name);
    if base='' then
    begin
      result := '001_'+name;
      numstr:='_001';
    end
    else
    begin
      last:=GetLastStr(name);
      num:=strtoint(base)+1;
      s:=inttostr(num);
      numlen:=length(base)-length(s);
      if numlen>0 then
      begin
        for I := 0 to numlen - 1 do
        begin
          s:='0'+s;
        end;
      end;
      result:=s+last;
      numstr:=s+last;
    end;
  end;
end;

function TailPos(const S, SubStr: AnsiString; fromPos: integer): integer;
asm
        PUSH EDI
        PUSH ESI
        PUSH EBX
        PUSH EAX
        OR EAX,EAX
        JE @@2
        OR EDX,EDX
        JE @@2
        DEC ECX
        JS @@2

        MOV EBX,[EAX-4]
        SUB EBX,ECX
        JLE @@2
        SUB EBX,[EDX-4]
        JL @@2
        INC EBX

        ADD EAX,ECX
        MOV ECX,EBX
        MOV EBX,[EDX-4]
        DEC EBX
        MOV EDI,EAX
@@1: MOV ESI,EDX
        LODSB
        REPNE SCASB
        JNE @@2
        MOV EAX,ECX
        PUSH EDI
        MOV ECX,EBX
        REPE CMPSB
        POP EDI
        MOV ECX,EAX
        JNE @@1
        LEA EAX,[EDI-1]
        POP EDX
        SUB EAX,EDX
        INC EAX
        JMP @@3
@@2: POP EAX
        XOR EAX,EAX
@@3: POP EBX
        POP ESI
        POP EDI
end
;

Function trimChars(str:string):string;
var
  i:integer;
  b:boolean;
begin
  if str='' then
  begin
    result:='';
    exit;
  end;
  b:=true;
  while b do
  begin
    i:=Length(str);
    if pos(str[i],'0123456789')=0 then
    begin
      setlength(str, i-1);
    end
    else
    begin
      result:=str;
      exit;
    end;
  end;
end;

function TrimPath(path: string): string;
var
  i: integer;
begin
  result := '';
  for i := length(path) - 1 downto 1 do
  begin
    if (path[i] = '\') or (path[i] = '/') then
    begin
      setlength(path, i);
      result := path;
      exit;
    end;
  end;
end;

function deleteOuterBracket(str:string; bracket:char):string;
var
  l:integer;
begin
  result:=str;
  if str='' then
    exit;
  if str[1]=bracket then
  begin
    l:=length(str);
    if str[l]=bracket then
    begin
      result:=Copy(str,2,l-2);
      exit;
    end
  end;
  result:=str;
end;

function getSubStrByIndex(src:string; tabs:char; p_start, index:integer):string;
var
  start, ind, i, c:integer;
  b:boolean;
begin
  ind:=0; // ����� ��������
  start:=p_start;
  result:='';
  for I := p_start to length(src) do
  begin
    b:=i=length(src);
    if (src[i]=tabs) or (b) then
    begin
      if ind=index then
      begin
        c:=i-start;
        if b then
        begin
          if not (src[i]=tabs) then
            inc(c);
        end;
        result:=Copy(src, start, c);
        exit;
      end
      else
      begin
        start:=i+1;
        inc(ind);
      end;
    end;
  end;
end;

function GetSubStringExt(src: string; tabs: string; p: integer;
  bracketChar: char; var index: integer): string;
var
  buf: string;
  ind: integer;
  startbracket,endbracket:boolean;
  i, len, chCount: integer;
begin
  buf := '';
  startbracket:=false;
  endbracket:=false;
  len := length(src);
  ind := -1;
  if p = 0 then
  begin
    p := 1;
  end;
  i := p;
  chCount := 0;
  while (i <= len) do
  begin
    if src[i] = bracketChar then
    begin
      inc(chCount);
      if chCount=1 then
        startbracket:=true;
      if chCount>1 then
      begin
        if (i=length(src)) then
          endbracket:=true
        else
        begin
          if pos(src[i+1],tabs)>0 then
            endbracket:=true;
        end;
      end;
    end;
    index := pos(src[i], tabs);
    if index <> 0 then
    begin
      if not startbracket then
      begin
        ind := i;
        index := i;
        break;
      end;
      if endbracket then
      begin
        ind := i;
        index := i;
        break;
      end;
    end;
    buf := buf + src[i];
    inc(i);
  end;
  index := ind;
  result := buf;
end;

function GetSubStringExt_(src: string; tabs: string; p: integer;
  bracketChar: char; var index: integer): string;
var
  buf: string;
  ind: integer;
  i, len, chCount: integer;
begin
  buf := '';
  len := length(src);
  ind := -1;
  if p = 0 then
  begin
    p := 1;
  end;
  i := p;
  chCount := 0;
  while (i <= len) do
  begin
    if src[i] = bracketChar then
    begin
      inc(chCount);
    end;
    index := pos(src[i], tabs);
    if index <> 0 then
    begin
      // ���� ��������� �����������, �� �� ������ ������
      if ((chCount and 1 = 1)) then
      begin

      end
      else
      begin
        ind := i;
        index := i;
        break;
      end;
    end;
    buf := buf + src[i];
    inc(i);
  end;
  index := ind;
  result := buf;
end;

function GetSubString(src: string; tabs: string; p: integer;
  var index: integer): string;
var
  buf: string;
  ind: integer;
  i, len: integer;
begin
  buf := '';
  len := length(src);
  if len=0 then
  begin
    index:=-1;
    result:='';
    exit;
  end;
  ind := -1;
  if p = 0 then
  begin
    p := 1;
  end;
  i := p;
  while (i <= len) do
  begin
    index := pos(src[i], tabs);
    if index <> 0 then
    begin
      ind := i;
      index := i;
      break;
    end;
    buf := buf + src[i];
    inc(i);
  end;
  index := ind;
  result := buf;
end;

function isDigit(Str: string): boolean;
var
  i: integer;
const
  DigStr = '0123456789';
begin
  result := false;
  if str='' then exit;

  for i := 1 to length(Str) do
  begin
    if pos(Str[i], DigStr) < 1 then
    begin
      result := false;
      exit;
    end;
  end;
  result := true;
end;

function isValue(Str: string): boolean;
var
  i: integer;
const
  DigStr = '0123456789,.';
begin
  result := false;
  for i := 1 to length(Str) do
  begin
    result := true;
    if i=1 then
    begin
      if str[1]='-' then
      begin
        if length(str)=1 then
          result:=false
        else
          continue;
      end;
    end;
    if pos(Str[i], DigStr) < 1 then
    begin
      result := false;
      exit;
    end;
  end;
end;

function readFloatFromIni(ifile:tinifile; sec,ident:string):double;
var
  str:string;
begin
  str:=ifile.readstring(sec,ident,'');
  if str<>'' then
    result:=StrToFloatExt(str)
  else
    result:=0;
end;

function strtointext(Str: string): integer;
begin
  if isvalue(str) then
   result:=strtoInt(str)
  else
    result:=-1;
end;

function FloatToStrEx(f:double; sep:char):string;
var
  p:integer;
begin
  result:=floattostr(f);
  p:=pos(',',result);
  if p=0 then
  begin
    p:=pos('.', result);
  end;
  if p<>0 then
  begin
    result[p]:=sep;
  end;
end;

function strtoFloatExt(Str: string): double;
var
  i, sepPos: integer;
  ch:char;
  resstr:string;
begin
  if str='' then
  begin
    result:=0;
    exit;
  end;
  i := pos('.', Str);
  if i=0 then
  begin
    i := pos(',', Str);
    sepPos:=i;
  end
  else
  begin
    sepPos:=i;
  end;
  if sepPos=0 then
  begin
    result := strtofloat(Str);
    exit;
  end;
  if sepPos > 0 then
  begin
    ch:=Str[sepPos];
    if decimalseparator <> ch then
    begin
      Str[i] := decimalseparator;
    end;
  end;
  resstr:='';
  for I := 1 to length(str) do
  begin
    if (str[i]='.') or (str[i]=',')  then
    begin
      if i=seppos then
        resstr:=resstr+str[i];
    end
    else
    begin
      if isdigit(str[i]) then
      begin
        resstr:=resstr+str[i];
      end
      else
      begin
        if (str[i]='E') or (str[i]='-') then
        begin
          resstr:=resstr+str[i];
        end;
      end;
    end;
  end;
  result := strtofloat(resstr);
end;

function TrimExt(Str: string): string;
var
  k: integer;
begin
  for k := length(Str) downto 1 do
  begin
    if Str[k] = '.' then
    begin
      result := Str;
      setlength(result, k - 1);
      exit;
    end;
  end;
  result := Str;
end;

function DeleteChars(src: string; ch: char): string;
var
  i: integer;
begin
  result := '';
  for i := 1 to length(src) do
  begin
    if src[i] <> ch then
      result := result + src[i];
  end;
end;

function ReplaceSubstr(src, SubStr, newtext: string; index: integer): string;
var
  i, count, position, endLen: integer;
  endstr:string;
  // s:pstring;
begin
  // s:=@src[index];
  // position:=pos(substr,string(s));
  // if position>0 then
  position := PosEx(SubStr, src, index);
  if position > 0 then
  begin
    setlength(result, (position-1));
    endLen:=length(src) - position+1-length(SubStr);
    setLength(endstr, endlen);
    move(src[1], result[1], (position-1)*(sizeof(widechar)));
    move(src[position+length(SubStr)], endstr[1], endlen*(sizeof(widechar)));

    result := result + newtext + endstr;
  end
  else
    result := src;
end;

function DeleteSubstr(src, SubStr: string; index: integer): string;
var
  i, count, position: integer;
  S: pstring;
begin
  S := @src[index];
  position := pos(SubStr, string(S));
  if position > 0 then
  begin
    // setlength(result,count);
    result := Copy(src, 1, position + index);
    SubStr := Copy(src, position, length(src) - position - index);
    result := result + SubStr;
  end;
  result := src;
end;

function ReplaseChars(src, SubStr: string; ch: char): string;
var
  i, j: integer;
begin
  for i := 1 to length(SubStr) do
  begin
    for j := 1 to length(src) do
    begin
      if src[j] = SubStr[i] then
      begin
        src[j] := ch;
      end;
    end;
  end;
  result := src;
end;

function replaceChar(Str: string; ch, newchar: char): string;
var
  i: integer;
begin
  for i := 1 to length(Str) do
  begin
    if Str[i] = ch then
    begin
      Str[i] := newchar;
    end;
  end;
  result := Str;
end;

function replaceSpace(Str: string; newchar: char): string;
var
  i: integer;
begin
  for i := 1 to length(Str) do
  begin
    if Str[i] = ' ' then
    begin
      Str[i] := newchar;
    end;
  end;
  result := Str;
end;


function FindMinMaxDouble(const Data: array of double;
                          var MinVal, MaxVal: Double): Boolean;
var
  i, mini, maxi: Integer;
begin
  // ���������� ������������, ��� ������ ���� ��� �����������
  Result := False;
  MinVal := MaxDouble; // �������������� ����������� �������� ����������� ���������
  MaxVal := -MaxDouble; // �������������� ������������ �������� ���������� ���������

  // ���������, �� ���� �� ������� ������
  if Length(Data) = 0 then
  begin
    Exit; // ���� ������ ����, �������, ��������� False
  end;

  // �������������� MinVal � MaxVal ������ ��������� �������.
  // ��� �����, ����� ��������� ���������� ������� �� ������ ��������
  // � �������� �������, ���� ��� �������� �����, ��������, ��������������.
  MinVal := Data[Low(Data)];
  MaxVal := Data[Low(Data)];

  // ���������� ��������� �������� �������, ������� �� �������
  for i := Low(Data) + 1 to High(Data) do
  begin
    // ���� ������� ������� ������ �������� ��������, ��������� �������
    if Data[i] < MinVal then
    begin
      MinVal := Data[i];
      mini:=i;
    end;
    // ���� ������� ������� ������ �������� ���������, ��������� ��������
    if Data[i] > MaxVal then
    begin
      MaxVal := Data[i];
      maxi:=i;
    end;
  end;
  //showmessage(inttostr(mini)+' '+inttostr(maxi));
  Result := True; // ���� �� ����� �� ����, ������, ������ �� ���� � �������� �������
end;

function FindMaxAndIndex(const Data: array of double;
                         var MaxVal: Double;
                         var MaxIndex: Integer): Boolean;
var
  i: Integer;
begin
  // ���������� ������������, ��� ������ ���� ��� �����������
  Result := False;
  MaxVal := -MaxDouble; // �������������� ������������ �������� ���������� ��������� double
  MaxIndex := -1;       // �������������� ������ ��������� ��� -1 (��� ������� �������)

  // ���������, �� ���� �� ������� ������
  if Length(Data) = 0 then
  begin
    Exit; // ���� ������ ����, �������, ��������� False
  end;

  // �������������� MaxVal � MaxIndex ������ ��������� �������.
  // ��� �����, ����� ��������� ���������� ������� �� ������ ��������
  // � �������� �������, ���� ��� �������� �����, ��������, ��������������.
  MaxVal := Data[Low(Data)];
  MaxIndex := Low(Data);

  // ���������� ��������� �������� �������, ������� �� �������
  for i := Low(Data) + 1 to High(Data) do
  begin
    // ���� ������� ������� ������ �������� ���������, ��������� �������� � ��� ������
    if Data[i] > MaxVal then
    begin
      MaxVal := Data[i];
      MaxIndex := i;
    end;
  end;
  Result := True; // ���� �� ����� �� ����, ������, ������ �� ���� � �������� ������
end;

end.
