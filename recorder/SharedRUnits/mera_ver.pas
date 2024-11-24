unit mera_ver;

interface

uses Windows, SysUtils;

const
    VERSION_ALPHA   = 0;
    VERSION_BETTA   = 1;
    VERSION_RELEASE = 2;

{type
    VERSION_DWORD = packed record
      w   : BYTE; // unsigned w  :4;
      bn  : WORD; // unsigned bn :8;
      bf  : WORD; // unsigned bf :8;
      min : WORD; // unsigned min:8;
      maj : BYTE; // unsigned maj:4;
    end;}

type
    MERA_VERSION = packed record
      lVersion      : DWORD;
	    lMajorVersion : Byte;
      lMinorVersion : Byte;
      lBugFixNumber : Byte;
      lBuildNumber  : Byte;
      chLetter      : CHAR;
    end;

    function IsBitSet(const val: Longint; const TheBit: Byte): Boolean;

    function MERAVersionToRecord(const Version_DWORD : DWORD) : MERA_VERSION;
    function MERAVersionToDWORD(var Version : MERA_VERSION) : DWORD;

    function MERAVersionDWORD2String(const Version_DWORD : DWORD) : String;


implementation


function IsBitSet(const val: Longint; const TheBit: Byte): Boolean;
begin
  Result := (val and (1 shl TheBit)) <> 0;
end;

function MERAVersionToRecord(const Version_DWORD : DWORD) : MERA_VERSION;
var
  Version : MERA_VERSION;
  temp_byte : Byte;
begin
  Version.lVersion := Version_DWORD;

  temp_byte := 0; // lMajorVersion 4 бита
  if IsBitSet(Version_DWORD, 31) then temp_byte := temp_byte + 8;
  if IsBitSet(Version_DWORD, 30) then temp_byte := temp_byte + 4;
  if IsBitSet(Version_DWORD, 29) then temp_byte := temp_byte + 2;
  if IsBitSet(Version_DWORD, 28) then temp_byte := temp_byte + 1;
  Version.lMajorVersion := temp_byte;

  temp_byte := 0; // lMinorVersion 8 бит
  if IsBitSet(Version_DWORD, 27) then temp_byte := temp_byte + 128;
  if IsBitSet(Version_DWORD, 26) then temp_byte := temp_byte + 64;
  if IsBitSet(Version_DWORD, 25) then temp_byte := temp_byte + 32;
  if IsBitSet(Version_DWORD, 24) then temp_byte := temp_byte + 16;
  if IsBitSet(Version_DWORD, 23) then temp_byte := temp_byte + 8;
  if IsBitSet(Version_DWORD, 22) then temp_byte := temp_byte + 4;
  if IsBitSet(Version_DWORD, 21) then temp_byte := temp_byte + 2;
  if IsBitSet(Version_DWORD, 20) then temp_byte := temp_byte + 1;
  Version.lMinorVersion := temp_byte;

  temp_byte := 0; // lBugFixNumber 8 бит
  if IsBitSet(Version_DWORD, 19) then temp_byte := temp_byte + 128;
  if IsBitSet(Version_DWORD, 18) then temp_byte := temp_byte + 64;
  if IsBitSet(Version_DWORD, 17) then temp_byte := temp_byte + 32;
  if IsBitSet(Version_DWORD, 16) then temp_byte := temp_byte + 16;
  if IsBitSet(Version_DWORD, 15) then temp_byte := temp_byte + 8;
  if IsBitSet(Version_DWORD, 14) then temp_byte := temp_byte + 4;
  if IsBitSet(Version_DWORD, 13) then temp_byte := temp_byte + 2;
  if IsBitSet(Version_DWORD, 12) then temp_byte := temp_byte + 1;
  Version.lBugFixNumber := temp_byte;

  temp_byte := 0; // lBuildNumber 8 бит
  if IsBitSet(Version_DWORD, 11) then temp_byte := temp_byte + 128;
  if IsBitSet(Version_DWORD, 10) then temp_byte := temp_byte + 64;
  if IsBitSet(Version_DWORD, 9)  then temp_byte := temp_byte + 32;
  if IsBitSet(Version_DWORD, 8)  then temp_byte := temp_byte + 16;
  if IsBitSet(Version_DWORD, 7)  then temp_byte := temp_byte + 8;
  if IsBitSet(Version_DWORD, 6)  then temp_byte := temp_byte + 4;
  if IsBitSet(Version_DWORD, 5)  then temp_byte := temp_byte + 2;
  if IsBitSet(Version_DWORD, 4)  then temp_byte := temp_byte + 1;
  Version.lBuildNumber := temp_byte;

  temp_byte := 0; // chLetter 4 бит
  if IsBitSet(Version_DWORD, 3)  then temp_byte := temp_byte + 8;
  if IsBitSet(Version_DWORD, 2)  then temp_byte := temp_byte + 4;
  if IsBitSet(Version_DWORD, 1)  then temp_byte := temp_byte + 2;
  if IsBitSet(Version_DWORD, 0)  then temp_byte := temp_byte + 1;

  Version.chLetter := #0;
  case temp_byte of
    VERSION_ALPHA   : Version.chLetter := 'a'; // 0
    VERSION_BETTA   : Version.chLetter := 'b'; // 1
    VERSION_RELEASE : Version.chLetter := ' '; // 2
  end;

  Result := Version;
end;

function MERAVersionToDWORD(var Version : MERA_VERSION) : DWORD;
begin
  Result := Version.lMajorVersion*$10000000 +
            Version.lMinorVersion*$100000 +
            Version.lBugFixNumber*$1000 +
            Version.lBuildNumber*$10;

  if Version.chLetter = 'a' then Result := Result + VERSION_ALPHA;
  if Version.chLetter = 'b' then Result := Result + VERSION_BETTA;
  if Version.chLetter = ' ' then Result := Result + VERSION_RELEASE;

  Version.lVersion := Result;
end;

function MERAVersionDWORD2String(const Version_DWORD : DWORD) : String;
var
  Version : MERA_VERSION;
begin
  Version := MERAVersionToRecord(Version_DWORD);

  Result := IntToStr(Version.lMajorVersion) + '.' +
            IntToStr(Version.lMinorVersion) + '.' +
            IntToStr(Version.lBugFixNumber) + '.' +
            IntToStr(Version.lBuildNumber) + Version.chLetter;
end;

end.
