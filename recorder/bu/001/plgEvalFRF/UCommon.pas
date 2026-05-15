unit UCommon;

interface
uses Windows, SysUtils, Classes, blaccess, tags;

type
TDataEvent = procedure(Sender: TObject; data: TBytes) of object;

DynTagsArray = array of ITag;

function GetWindowsFolder: string;
function GetLastValue(Tag: ITag): double;
function GetValue(Tag: ITag): double;

implementation

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
  result := n;
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
  n: double;
  cnt: integer;
  rez: integer;
begin
  Tag.QueryInterface(IBlockAccess, block);
  n := 0;
  result := n;
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
              if length(buf) > 0 then
                 n := buf[high(buf)];
            end;
            result := n;
         finally
            block.UnlockVector;
            block := nil;
         end;
     end;
end;

end.
