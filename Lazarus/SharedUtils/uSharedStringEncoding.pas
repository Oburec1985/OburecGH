unit uSharedStringEncoding;

{
  Общие преобразования строк для Lazarus-проектов (RecorderLnx и др.).

  Маркер: SHARED_STRING_ENCODING_2026_06.

  Использовать эти функции для:
  - legacy-файлов MERA/SDB/INI с windows-1251 или смешанной кодировкой;
  - RawByteString / hex-констант CP1251 (FPC 3.x ломает конкатенацию без SetCodePage);
  - XML с декларацией encoding="windows-1251" (FPC XMLRead не принимает cp1251 напрямую);
  - проверки, что текст пригоден для отображения в LCL (нет «?» от битой перекодировки).

  Для литералов в {$codepage UTF8} модулях — обычные UTF-8 строки без обёрток.
  Для cp1251-литералов в {$codepage cp1251} — CP1251ToUTF8 или LclText из uComponentServices.

  Документация: SharedUtils/Docs/string-encoding.md
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DOM, LConvEncoding;

function SharedReadFileBytes(const AFileName: string): RawByteString;
function SharedIsValidUtf8(const AData: RawByteString): Boolean;
function SharedUtf8BytesToString(const AData: RawByteString): String;
function SharedCp1251BytesToUtf8(const AValue: RawByteString): String;
function SharedLegacyBytesToUtf8(const AData: RawByteString): String;
function SharedXmlDeclIsWindows1251(const AData: RawByteString): Boolean;
function SharedNormalizeXmlEncodingDeclaration(const AUtf8Text: string): string;
function SharedIsGoodDisplayText(const AText: string): Boolean;
function SharedPreferredDisplayText(const APrimary, AFallback: string): string;
function SharedLoadLegacyTextFile(const AFileName: string): string;
procedure SharedLoadLegacyTextLines(AList: TStrings; const AFileName: string);
procedure SharedReadLegacyXmlFile(out ADocument: TXMLDocument;
  const AFileName: string);

implementation

uses
  XMLRead;

function SharedReadFileBytes(const AFileName: string): RawByteString;
var
  lFile: TFileStream;
begin
  Result := '';
  lFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, lFile.Size);
    if Result <> '' then
      lFile.ReadBuffer(Result[1], Length(Result));
  finally
    lFile.Free;
  end;
end;

function SharedIsValidUtf8(const AData: RawByteString): Boolean;
var
  I: Integer;
  lLen: Integer;
  lB: Byte;
begin
  Result := True;
  I := 1;
  lLen := Length(AData);
  while I <= lLen do
  begin
    lB := Ord(AData[I]);
    if lB = 0 then
      Exit(False);
    if (lB and $80) = 0 then
      Inc(I)
    else if (lB and $E0) = $C0 then
    begin
      if (I + 1 > lLen) or ((Ord(AData[I + 1]) and $C0) <> $80) then
        Exit(False);
      Inc(I, 2);
    end
    else if (lB and $F0) = $E0 then
    begin
      if (I + 2 > lLen) or ((Ord(AData[I + 1]) and $C0) <> $80) or
        ((Ord(AData[I + 2]) and $C0) <> $80) then
        Exit(False);
      Inc(I, 3);
    end
    else if (lB and $F8) = $F0 then
    begin
      if (I + 3 > lLen) or ((Ord(AData[I + 1]) and $C0) <> $80) or
        ((Ord(AData[I + 2]) and $C0) <> $80) or
        ((Ord(AData[I + 3]) and $C0) <> $80) then
        Exit(False);
      Inc(I, 4);
    end
    else
      Exit(False);
  end;
end;

function SharedUtf8BytesToString(const AData: RawByteString): String;
var
  lRaw: RawByteString;
begin
  lRaw := AData;
  SetCodePage(lRaw, CP_UTF8);
  Result := string(lRaw);
end;

function SharedCp1251BytesToUtf8(const AValue: RawByteString): String;
var
  lRaw: RawByteString;
begin
  lRaw := AValue;
  SetCodePage(lRaw, 1251);
  Result := CP1251ToUTF8(lRaw);
end;

function SharedLegacyBytesToUtf8(const AData: RawByteString): String;
begin
  if SharedXmlDeclIsWindows1251(AData) then
    Result := SharedCp1251BytesToUtf8(AData)
  else if SharedIsValidUtf8(AData) then
    Result := SharedUtf8BytesToString(AData)
  else
    Result := SharedCp1251BytesToUtf8(AData);
end;

function SharedXmlDeclIsWindows1251(const AData: RawByteString): Boolean;
var
  lHeader: AnsiString;
begin
  if Length(AData) > 512 then
    lHeader := Copy(AData, 1, 512)
  else
    lHeader := AData;
  Result := Pos(AnsiString('windows-1251'), LowerCase(lHeader)) > 0;
end;

function SharedNormalizeXmlEncodingDeclaration(const AUtf8Text: string): string;
begin
  Result := StringReplace(AUtf8Text, 'encoding="windows-1251"',
    'encoding="UTF-8"', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'encoding=''windows-1251''',
    'encoding="UTF-8"', [rfReplaceAll, rfIgnoreCase]);
end;

function SharedIsGoodDisplayText(const AText: string): Boolean;
var
  I: Integer;
begin
  Result := Trim(AText) <> '';
  if not Result then
    Exit;
  for I := 1 to Length(AText) do
    if AText[I] = '?' then
      Exit(False);
end;

function SharedPreferredDisplayText(const APrimary, AFallback: string): string;
begin
  if SharedIsGoodDisplayText(APrimary) then
    Result := APrimary
  else
    Result := AFallback;
end;

function SharedLoadLegacyTextFile(const AFileName: string): string;
var
  lBytes: RawByteString;
begin
  lBytes := SharedReadFileBytes(AFileName);
  Result := SharedLegacyBytesToUtf8(lBytes);
end;

procedure SharedLoadLegacyTextLines(AList: TStrings; const AFileName: string);
begin
  if AList = nil then
    Exit;
  AList.Text := SharedLoadLegacyTextFile(AFileName);
end;

procedure SharedReadLegacyXmlFile(out ADocument: TXMLDocument;
  const AFileName: string);
var
  lStream: TStringStream;
  lUtf8Text: string;
  lXmlText: RawByteString;
begin
  ADocument := nil;
  lXmlText := SharedReadFileBytes(AFileName);
  lUtf8Text := SharedNormalizeXmlEncodingDeclaration(
    SharedLegacyBytesToUtf8(lXmlText));
  lStream := TStringStream.Create(lUtf8Text);
  try
    ReadXMLFile(ADocument, lStream);
  finally
    lStream.Free;
  end;
end;

end.
