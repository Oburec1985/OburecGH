unit uSharedStringEncoding;

{
  Общие преобразования строк для Lazarus-проектов (RecorderLnx и др.).

  2026-06: вынесено из UI/uTagSettingsDialog.pas (Mic140Cp1251BytesToUtf8).
  Для cp1251-литералов в {$codepage cp1251} модулях по-прежнему используйте
  CP1251ToUTF8(...) напрямую или LclText() из uComponentServices.
  SharedCp1251BytesToUtf8 нужен для RawByteString/hex-констант CP1251, где
  конкатенация AnsiString иначе ломает кодовую страницу в FPC 3.x.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, LConvEncoding;

function SharedCp1251BytesToUtf8(const AValue: RawByteString): String;

implementation

function SharedCp1251BytesToUtf8(const AValue: RawByteString): String;
var
  lRaw: RawByteString;
begin
  lRaw := AValue;
  SetCodePage(lRaw, 1251);
  Result := CP1251ToUTF8(lRaw);
end;

end.
