unit UCommon;

interface
uses Windows, Messages, WinSock, SysUtils, Classes, blaccess, LazSerial, tags, blcksock, LazUTF8;

//Сообщение от плагина форме настроек
const WM_PLUGIN_MSG = WM_USER + 1050;

type
DynTagsArray = array of ITag;
TDataEvent = procedure (Sender: TObject; Data: TBytes) of object;
TMessageNotify = procedure (Sender: TObject; Msg: string) of object ;
TNameChangeEvent = procedure (Sender: TObject; oldname: AnsiString; newname: AnsiString) of object;
TDescrChangeEvent = procedure (Sender: TObject; name: AnsiString; newdescr: AnsiString) of object;
TConnectEvent = procedure (Sender: TObject; Socket: TTCPBlockSocket) of object;

function GetLastValue(Tag: ITag): double;
function isDigit(key: Char): boolean;
function GetValue(Tag: ITag): double;
function GetWindowsFolder: string;
function FindIndex(lst: TStrings; str: string): integer;
function InverseData(const Source; leng: integer;
  flag_byte: boolean; flag_reg: boolean; flag_dword: boolean): TBytes;
function DataToStr(data: TBytes; data_length: Cardinal): string;
procedure LogMsg(fname: string; msg: string);
function IntToBaudRate(speed: integer): TBaudRate;


implementation


function IntToBaudRate(speed: integer): TBaudRate;
begin
 case speed of
 2400: result := br__2400;
 4800: result := br__4800;
 9600: result := br__9600;
 19200: result := br_19200;
 57600: result := br_57600;
 115200: result := br115200
 else
  result := br__9600;
  end;
end;

function DataToStr(data: TBytes; data_length: Cardinal): string;
var
  i: integer;
  s: string;
begin
  for i := 0 to data_length - 1 do
    begin
      s := s + inttohex(data[i], 2);
    end;
  result := s;
end;

function isDigit(key: Char): boolean;
begin
 result := (key in ['0','1','2','3','4','5','6','7','8', '9', #8]);
end;

function FindIndex(lst: TStrings; str: string): integer;
var
  i: integer;
begin
result := -1;
  for i := 0 to lst.Count - 1 do
     begin
     if (CompareText(lst[i], str) = 0) then
        begin
        result := i;
        break;
        end;
     end;
end;

procedure LogMsg(fname: string; msg: string);
var
  f: TFileStream;
  s: string;
begin
  try
  if not fileExists(fname) then
    f := TFileStream.Create(fname, fmCreate)
  else
    f := TFileStream.Create(fname, fmOpenReadWrite);

  f.Position := f.Size;
  s := UTF8ToWinCP(format('%s: %s', [DateTimeToStr(now), msg]) + #13);
  f.WriteBuffer(s[1], length(s) * sizeOf(char));
  finally
  FreeAndNil(f);
  end;
end;

{procedure TPollThread.WriteLog(s: string);
var
  fs: TFileStream;
  str: string;
begin
if not Write_Log then Exit;

  try
  if not fileexists(fDir + '\log.txt') then
    fs := TFileStream.Create(fDir + '\log.txt', fmCreate) else
    fs := TFileStream.Create(fDir + '\log.txt', fmShareDenyNone or fmOpenWrite);

    fs.Seek(0, soFromEnd);
    str := timetostr(now) + ' ' + s + #13;
    fs.WriteBuffer(str[1], length(str) * sizeof(char));
  finally
    fs.Free;
  end;

end;}


function GetWindowsFolder: string;
var
  WinDirP:PChar;
  Res:Cardinal;
begin
  WinDirP := StrAlloc(MAX_PATH);
  Res := GetWindowsDirectory(WinDirP, MAX_PATH);
  if Res > 0 then
    Result := StrPas(WinDirP)
end;

//Перестановка байт старый вариант
{function InverseData(const Source; leng: integer;
  flag_byte: boolean; flag_reg: boolean; flag_dword: boolean): TBytes;
var
  output: TBytes;
  i: integer;

  buf: Byte;
  buf_reg: TBytes;
  buf_dword: TBytes;
begin
  SetLength(output, leng);
  move(Source, output[0], leng);
  SetLength(buf_reg, 2);
  SetLength(buf_dword, 4);

  //В Insat OPC: 7 6 5 4 3 2 1 0 double word (старшим двойным словом вперед)
  //В Insat OPC: 3 2 1 0 7 6 5 4 word (старшим словом вперед)
  //В Insat OPC: 1 0 3 2 5 4 7 6 (старшим байтом вперед)
  if flag_dword and (leng >= 8) then
    for i := 0 to leng div 8 - 1 do // меняем местами двойные слова
    begin
      move(output[i * 4], buf_dword[0], 4);
      move(output[(i + 1) * 4], output[i * 4], 4);
      move(buf_dword[0], output[(i + 1) * 4], 4);
    end;


  if flag_reg and (leng >= 4) then
    for i := 0 to leng div 4 - 1 do // меняем местами регистры
    begin
      move(output[i * 2], buf_reg[0], 2);
      move(output[(i + 1) * 2], output[i * 2], 2);
      move(buf_reg[0], output[(i + 1) * 2], 2);
    end;

  //В Insat OPC: 1 0 3 2 5 4 7 6
  if flag_byte and (leng >= 2) then
    for i := 0 to leng div 2 - 1 do // меняем местами байты
    begin
      buf := output[i * 2];
      output[i * 2] := output[(i * 2) + 1];
      output[(i * 2) + 1] := buf;
    end;

  result := output;
end;}

//Новая версия функции с 24.06.2025
function InverseData(const Source; leng: integer;
  flag_byte: boolean; flag_reg: boolean; flag_dword: boolean): TBytes;
var
  output: TBytes;
  i: integer;

  buf: Byte;
  buf_reg: array [0 .. 1] of byte;
  buf_dword: array [0 .. 3] of byte;
begin
  SetLength(output, leng);
  move(Source, output[0], leng);

  //Исходный порядок: 0 1 2 3 4 5 6 7
  //В Insat OPC: 7 6 5 4 3 2 1 0 double word (старшим двойным словом вперед)
  //В Insat OPC: 3 2 1 0 7 6 5 4 word (старшим словом вперед)
  //В Insat OPC: 1 0 3 2 5 4 7 6 (старшим байтом вперед)

  i := 0;
  if flag_byte and (leng mod 2 = 0) then
    while i <= leng div 2 - 1 do // меняем местами байты
    begin
      buf := output[i * 2];
      output[i * 2] := output[(i * 2) + 1];
      output[(i * 2) + 1] := buf;
      inc(i);
    end;

  i := 0;
  if flag_reg and (leng mod 4 = 0) then
    while i <= leng div 4 do // меняем местами регистры
    begin
      move(output[i * 2], buf_reg[0], 2);
      move(output[(i + 1) * 2], output[i * 2], 2);
      move(buf_reg[0], output[(i + 1) * 2], 2);
      i := i + 2;
    end;

  i := 0;
    if flag_dword and (leng mod 8 = 0) then
      while i <= leng div 8 do // меняем местами двойные слова
      begin
        move(output[i * 4], buf_dword[0], 4);
        move(output[(i + 1) * 4], output[i * 4], 4);
        move(buf_dword[0], output[(i + 1) * 4], 4);
        i := i + 4;
      end;

  result := output;
end;

function GetValue(Tag: ITag): double;
var
  block: IBlockAccess;
  buf: array of double;
  i: integer;
  n: double;
  cnt: integer;
  rez: integer;
begin
  Tag.QueryInterface(IBlockAccess, block);
  n := 0;
  if block <> nil then
     begin
         try
            block.LockVector;

            //cnt := block.GetBlocksCount;
            cnt := block.GetVectorSize;
            setlength(buf, cnt);
            rez := block.GetVectorR8(buf[0], 0, cnt, true);
            if (rez = S_OK) then
            begin
            if (cnt > 0) then
               begin
                 for i := 0 to high(buf) do
                  begin
                      n := n + buf[i];
                  end;
                  n := n/length(buf);
               end;
            end;
            result := n;
         finally
            block.UnlockVector;
            block := nil;
         end;
     end;
end;

function GetLastValue(Tag: ITag): double;
var
  block: IBlockAccess;
  buf: array of double;
  i: integer;
  n: double;
  cnt: integer;
  rez: integer;
begin
  Tag.QueryInterface(IBlockAccess, block);
  n := 0;
  if block <> nil then
     begin
         try
            block.LockVector;

            cnt := block.GetVectorSize;
            setlength(buf, cnt);
            if cnt > 0 then
               rez := block.GetVectorR8(buf[0], 0, cnt, true);
            if (rez = S_OK) then
            begin
              if length(buf) > 0 then
                 n := buf[high(buf)];
            end;
         finally
            block.UnlockVector;
            block := nil;
            result := n;
         end;
     end;
end;

end.
