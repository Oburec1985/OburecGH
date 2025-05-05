unit uBinFile;

interface
uses
  Messages, classes, SysUtils, windows;

  // —читать анси строку (первый байт длина строки)
  function ReadAnsiString(const f:file):string;
  function ReadAnsiLString(const f:file):string;
  // —читать строку ќЅ  (лишний символ на конце ничего не означающий)
  function ReadTypedAnsiString(const f:file):string;
  // —читать терминированную нулем строку
  function ReadString(const f:file):string;overload;
  function ReadString(const f:file; terminator:char):string;overload;
  function ReadString(const f:file;len:integer):string;overload;
  // записать терминированную символом '#0' строку
  procedure WriteCString(const f:file;str:string);
  // зачитать терминированную символом '#0' строку
  function ReadCString(const f:file):ansistring;
  // записать строку с константным числом букв (по длине строки)
  procedure WriteString(const f:file;str:string);
  // записать строку первым символом которой €вл€етс€ число букв в строке
  procedure WriteAnsiString(const f:file;str:string);
  // записать тип строки и потом строку в зависимости от типа
  procedure writeTypedString(const f:file; str:string; t:byte);
  // —читать integer
  function ReadTypedInt(const f:file):integer;
  procedure writetypedint(const f:file;i:integer; t:byte);
  // —читать integer
  function ReadInt(const f:file):integer;
  procedure WriteInt(const f:file; i:integer);
  // —читать cardinal
  function ReadCard(const f:file):cardinal;
  procedure WriteCard(const f:file; c:cardinal);
  // —читать 2 байта
  function ReadWord(const f:file):word;
  procedure WriteWord(const f:file; w:word);
  function ReadUShort(const f:file):ushort;
  // прочитать байт
  function ReadByte(const f:file):byte;
  // записать байт
  procedure writeByte(const f:file; b:byte);
  // —читать single
  function ReadTypedSingle(const f:file):single;
  procedure writeTypedSingle(const f:file; s:single; t:byte);
  // —читать single
  function ReadSingle(const f:file):single;
  procedure WriteSingle(const f:file; s:single);
  procedure WriteDouble(const f:file; s:double);
  function ReadDouble(const f:file):double;
  // —читать boolean
  function ReadTypedBool(const f:file):boolean;
  procedure WriteTypedBool(const f:file;b:boolean);
  // —читать boolean
  function ReadBool(const f:file):boolean;
  // —читать char
  function ReadChar(const f:file):char;
  // —читать ShortInt
  function ReadShortInt(const f:file):shortInt;
  procedure writeShortInt(const f:file; i:shortint);
  // записать перевод каретки
  procedure WriteCarret(const f:file);

implementation
const vaString = 6;
      vaLString = 12;
      vaInt8 = 2;
      vaInt16 = 3;
      vaInt32 = 4;
      vaSingle = 15;
      vaFalse = 8;
      vaTrue = 9;

function ReadAnsiString(const f:file):string;
var len:byte;
    lreaded:cardinal;
    str:ansistring;
begin
  BlockRead(f,len,1,lReaded);
  SetLength(str,len);
  BlockRead(f,str[1],len,lReaded);
  result:=str;
end;

function ReadAnsiLString(const f:file):string;
var len:integer;
    lreaded:cardinal;
    str:string;
begin
  BlockRead(f,len,4,lReaded);
  SetLength(str,len);
  BlockRead(f,str[1],len,lReaded);
  result:=str;
end;

function ReadTypedAnsiString(const f:file):string;
var len, strtype:byte;
    lreaded:cardinal;
    str:string;
begin
  BlockRead(f,strtype,1,lReaded);
  if strType=vaString then
  begin
    str:=ReadAnsiString(f);
  end
  else
  begin
    str:=ReadAnsiLString(f);
  end;
  result:=str;
end;

function ReadString(const f:file; terminator:char):string;
var
  len:byte;
  lreaded:cardinal;
  str:string;
  ch:char;
begin
  str:='';
  ch:=' ';
  while ch<>terminator do
  begin
    BlockRead(f,ch,1,lReaded);
    if ch<>terminator then
      str:=str+ch;
  end;
  result:=str;
end;


function ReadString(const f:file):string;
var len:byte;
    lreaded:cardinal;
    ch:char;
    str:string;
    b:boolean;
begin
  ch:=' ';
  str:='';
  b:=true;
  while b and (not eof(f)) do
  begin
    BlockRead(f,ch,1,lReaded);
    if (ch<>'#0') and (ch<>char(0)) then
      str:=str+ch;
    b:=(ch<>'#0') and (ch<>char(0));
  end;
  result:=str;
end;

procedure WriteCarret(const f:file);
var
  ch:char;
begin
  ch:=char(0);
  BlockWrite(f,ch,1);
end;


procedure WriteCString(const f:file;str:string);
var
  ch:char;
  len:integer;
begin
  len:=length(str);
  if len<>0 then
    BlockWrite(f,str[1],len);
  ch:=char(0);
  BlockWrite(f,ch,1);
end;

function ReadCString(const f:file):ansistring;
var
  r:integer;
  ch:ansichar;
begin
  ch:='1';
  result:='';
  while ch<>ansichar(0) do
  begin
    BlockRead(f, ch, 1,r);
    result:=result+ch;
  end;
end;

function ReadString(const f:file;len:integer):string;
var
  lreaded:cardinal;
  str: ansistring;
begin
  setlength(str,len);
  BlockRead(f,str[1],len,lreaded);
  result:=str;
end;

procedure WriteString(const f:file;str:string);overload;
begin
  BlockWrite(f,str[1],length(str));
end;

procedure WriteAnsiString(const f:file;str:string);
var
  len:byte;
begin
  len:=length(str);
  BlockWrite(f,len,1);
  BlockWrite(f,str[1],len);
end;

procedure writeTypedString(const f:file;str:string; t:byte);
begin
  BlockWrite(f,t,1);
  if t=vaString then
  begin
    writeAnsiString(f, str);
  end
  else
  begin
    //ReadAnsiLString(f, str);
  end;
end;

function ReadChar(const f:file):char;
var
  ch:char;
  lreaded:cardinal;
begin
  BlockRead(f,ch,1,lreaded);
  result:=ch;
end;

function ReadInt(const f:file):integer;
var len:byte;
    lreaded:cardinal;
    int:integer;
begin
  BlockRead(f,int,sizeof(integer),lReaded);
  result:=int;
end;

procedure WriteInt(const f:file; i:integer);
begin
  BlockWrite(f,i,sizeof(integer));
end;

function ReadShortInt(const f:file):shortInt;
var len:byte;
    lreaded:cardinal;
    int:shortint;
begin
  BlockRead(f,int,sizeof(shortInt),lReaded);
  result:=int;
end;

procedure writeShortInt(const f:file; i:shortint);
begin
  BlockRead(f,i,sizeof(shortInt));
end;

function ReadCard(const f:file):cardinal;
var len:byte;
    lreaded:cardinal;
    val:cardinal;
begin
  BlockRead(f,val,sizeof(cardinal),lReaded);
  result:=val;
end;

procedure WriteCard(const f:file; c:cardinal);
begin
  BlockWrite(f,c,sizeof(cardinal));
end;

function ReadUShort(const f:file):ushort;
var len:byte;
    lreaded:cardinal;
    val:ushort;
begin
  BlockRead(f,val,sizeof(val),lReaded);
  result:=val;
end;

function ReadWord(const f:file):word;
var len:byte;
    lreaded:cardinal;
    val:word;
begin
  BlockRead(f,val,sizeof(word),lReaded);
  result:=val;
end;

procedure WriteWord(const f:file; w:word);
begin
  BlockWrite(f,w,sizeof(word));
end;

function ReadByte(const f:file):byte;
var len:byte;
    lreaded:cardinal;
    val:byte;
begin
  BlockRead(f,val,sizeof(byte),lReaded);
  result:=val;
end;

procedure writeByte(const f:file; b:byte);
begin
  BlockWrite(f,b,1);
end;

function ReadTypedInt(const f:file):integer;
var
  valType:byte;
begin
  valtype:=ReadByte(f);
  case valtype of
    vaint8: result:=ReadByte(f);
    vaint16: result:=ReadShortInt(f);
    vaint32: result:=ReadInt(f);
  end;
end;

procedure WriteTypedInt(const f:file; i:integer; t:byte);
begin
  writeByte(f, t);
  case t of
    vaint8: writeByte(f, i);
    vaint16: writeShortInt(f, i);
    vaint32: writeInt(f, i);
  end;
end;

function ReadTypedSingle(const f:file):single;
var
  valType:byte;
begin
  valtype:=ReadByte(f);
  case valtype of
    vaSingle: result:=ReadSingle(f);
    vaint8: result:=ReadByte(f);
    vaint16: result:=ReadShortInt(f);
    vaint32: result:=ReadInt(f);
  end;
end;

procedure writeTypedSingle(const f:file; s:single; t:byte);
begin
  WriteByte(f, t);
  case t of
    vaSingle: WriteSingle(f, s);
    vaint8: writeByte(f, trunc(s));
    vaint16: writeShortInt(f, trunc(s));
    vaint32: writeInt(f, trunc(s));
  end;
end;

function ReadSingle(const f:file):single;
var len:byte;
    lreaded:cardinal;
    val:single;
begin
  BlockRead(f,val,sizeof(single),lReaded);
  result:=val;
end;

procedure WriteSingle(const f:file; s:single);
begin
  BlockWrite(f,s,sizeof(single));
end;

procedure WriteDouble(const f:file; s:double);
begin
  BlockWrite(f,s,sizeof(double));
end;

function ReadDouble(const f:file):double;
var
  len:byte;
  lreaded:cardinal;
  val:double;
begin
  BlockRead(f,val,sizeof(double),lReaded);
  result:=val;
end;

function ReadTypedBool(const f:file):boolean;
var len:byte;
    lreaded:cardinal;
    typedval:byte;
begin
  typedval:=ReadByte(f);
  result:=typedval = vatrue;
end;

procedure WriteTypedBool(const f:file;b:boolean);
begin
  if b then
    WriteByte(f,byte(vatrue))
  else
    WriteByte(f,byte(vafalse));
end;

function ReadBool(const f:file):boolean;
var len:byte;
    lreaded:cardinal;
    val:boolean;
begin
  BlockRead(f,val,sizeof(boolean),lReaded);
  result:=val;
end;

end.
