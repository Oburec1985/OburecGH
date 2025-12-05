unit uMyDataAndConvert;

interface

uses
  Windows, SysUtils, StrUtils, Classes, Math,

  uMyErrorMessages;

type
  TInt64To8BytesArray = record case byte of
      0: (UInt64 : UInt64);
      1: (Bytes  : packed array[0..7] of Byte);
  end;

  TInt64To4WordsArray = record case byte of
      0: (UInt64 : UInt64);
      1: (Words  : packed array[0..3] of Word);
  end;

  TLongWordTo2WordsArray = record case byte of
      0: (LongWord : LongWord);
      1: (Words    : packed array[0..1] of Word);
  end;

  ArrayOfByte_type = array of Byte;

Const
  Bit0 = 1;
  Bit1 = 2;
  Bit2 = 4;
  Bit3 = 8;
  Bit4 = 16;
  Bit5 = 32;
  Bit6 = 64;
  Bit7 = 128;

  Bit8 = 256;
  Bit9 = 512;
  Bit10 = 1024;
  Bit11 = 2048;
  Bit12 = 4096;
  Bit13 = 8192;
  Bit14 = 16384;
  Bit15 = 32768;
  Bit_array : array [0..15] of DWORD = (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768);

  Integer_ByteMax     = 255;                  // 8 bit
  Integer_WordMax     = 65535;                // 16 bit
  Integer_LongWordMax = 4294967295;           // 32 bit
  Integer_Int64Max    = 9223372036854775807;  // 64 bit, -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
  Integer_UInt64Max   = 18446744073709551615; // 64 bit, unsigned

  SecondTime : TDateTime = 1 / (24 * 60 * 60); // Значение 1 секунды в формате TDateTime
  SecondDouble : Double  = 1 / (24 * 60 * 60); // Значение 1 секунды в формате Double
  SecondsInDay = 24 * 60 * 60;                 // секунд в дне
  MsSecondDouble : Double = 1 / (24 * 60 * 60 * 1000);    // Значение 1 миллисекунды в формате Double
  MsSecondTime   : TDateTime = 1 / (24 * 60 * 60 * 1000); // Значение 1 миллисекунды в формате TDateTime

  // ---------------------------------------------------------------------------
  // работа с битами
  function IsBitSet(Value : Int64; TheBit: byte): boolean;  overload;
  function IsBitSet(Value : Double; TheBit: byte): boolean; overload;

  procedure SetBitOn(var Value : byte;    const TheBit: byte); overload; // 8 bit, 0 to 255
  procedure SetBitOn(var Value : Word;    const TheBit: byte); overload; // 16 bit, 0 to 65,535
  procedure SetBitOn(var Value : DWORD;   const TheBit: byte); overload; // 32 bit, LongWord, 0 to 4,294,967,295
  procedure SetBitOn(var Value : Integer; const TheBit: byte); overload; // 32 bit, -2,147,483,648 to 2,147,483,647
  procedure SetBitOn(var Value : Int64;   const TheBit: byte); overload; // 64 bit, -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
  function SetBitOn_(const Value : byte;    const TheBit: byte): byte;    overload; // 8 bit, 0 to 255
  function SetBitOn_(const Value : Word;    const TheBit: byte): Word;    overload; // 16 bit, 0 to 65,535
  function SetBitOn_(const Value : DWORD;   const TheBit: byte): DWORD;   overload; // 32 bit, LongWord, 0 to 4,294,967,295
  function SetBitOn_(const Value : Integer; const TheBit: byte): Integer; overload; // 32 bit, -2,147,483,648 to 2,147,483,647
  function SetBitOn_(const Value : Int64;   const TheBit: byte): Int64;   overload; // 64 bit, -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807

  procedure SetBitOff(var Value : byte;    const TheBit: byte); overload; // 8 bit, 0 to 255
  procedure SetBitOff(var Value : Word;    const TheBit: byte); overload; // 16 bit, 0 to 65,535
  procedure SetBitOff(var Value : DWORD;   const TheBit: byte); overload; // 32 bit, LongWord, 0 to 4,294,967,295
  procedure SetBitOff(var Value : Integer; const TheBit: byte); overload; // 32 bit, -2,147,483,648 to 2,147,483,647
  procedure SetBitOff(var Value : Int64;   const TheBit: byte); overload; // 64 bit, -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
  function SetBitOff_(const Value : byte;    const TheBit: byte): byte;    overload; // 8 bit, 0 to 255
  function SetBitOff_(const Value : Word;    const TheBit: byte): Word;    overload; // 16 bit, 0 to 65,535
  function SetBitOff_(const Value : DWORD;   const TheBit: byte): DWORD;   overload; // 32 bit, LongWord, 0 to 4,294,967,295
  function SetBitOff_(const Value : Integer; const TheBit: byte): Integer; overload; // 32 bit, -2,147,483,648 to 2,147,483,647
  function SetBitOff_(const Value : Int64;   const TheBit: byte): Int64;   overload; // 64 bit, -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807

  procedure SetBitToggle(var Value : byte;    const TheBit: byte); overload; // 8 bit, 0 to 255
  procedure SetBitToggle(var Value : Word;    const TheBit: byte); overload; // 16 bit, 0 to 65,535
  procedure SetBitToggle(var Value : DWORD;   const TheBit: byte); overload; // 32 bit, LongWord, 0 to 4,294,967,295
  procedure SetBitToggle(var Value : Integer; const TheBit: byte); overload; // 32 bit, -2,147,483,648 to 2,147,483,647
  procedure SetBitToggle(var Value : Int64;   const TheBit: byte); overload; // 64 bit, -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
  function SetBitToggle_(const Value : byte;    const TheBit: byte): byte;    overload; // 8 bit, 0 to 255
  function SetBitToggle_(const Value : Word;    const TheBit: byte): Word;    overload; // 16 bit, 0 to 65,535
  function SetBitToggle_(const Value : DWORD;   const TheBit: byte): DWORD;   overload; // 32 bit, LongWord, 0 to 4,294,967,295
  function SetBitToggle_(const Value : Integer; const TheBit: byte): Integer; overload; // 32 bit, -2,147,483,648 to 2,147,483,647
  function SetBitToggle_(const Value : Int64;   const TheBit: byte): Int64;   overload; // 64 bit, -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807

  function IntegerToBitStr(Value : Int64; Bits: byte = 16; UseSpace4 : Boolean = True; UseSpace8 : Boolean = True; SeniorBitFirst : Boolean = True): String;

  // ---------------------------------------------------------------------------
  // проверка на число
  function CheckKeyForFloat(Key : Char; minus : boolean = true; Separator : Char = '_') : Char;
  function CheckKeyForFloatStr(text : String; var key : Char; minus : boolean = false) : string;
  function CheckStrForFloat(Str : String) : Extended;
  function SetStrForFloat(ParamValueStr : String; out ParamValueOut : Double) : Boolean; overload;
  function SetStrForFloat(ParamValueStr : String; out ParamValueOut : Extended) : Boolean; overload;

  // ---------------------------------------------------------------------------
  // время, даты
  procedure SplitMilliseconds2Words(const TotalMS: Int64; out Days, Hours, Minutes, Seconds, Milliseconds: Word); // миллисекунды в дни, часы, минуты, секунды, миллисекунды
  function SplitMilliseconds2String(const TotalMS: Int64; const FormattedStr : string = '') : String; // миллисекунды в форматированную строку (дни, часы, минуты, секунды, миллисекунды)
  function SplitMilliseconds2SecString(const TotalMS: Int64) : String; // миллисекунды в секунды с округлением вверх
  function ConvertStringTimeToMilliseconds(const FormattedStr : string = '') : Int64; // перевести строку со временем с миллисекундами в миллисекунды (дни, часы, минуты, секунды, миллисекунды)
  function ConvertStringToDateTime(const S: string; out Value: TDateTime; ShowError : Boolean = true; CheckZero : Boolean = true): Boolean; // перевести строку со временем в TDateTime с проверкой и выдачей ошибки

  // общие функции, строки
  function StrToFloatDecimalSeparator(str_in : String) : Double; // строку в Double с заменой . и ,
  function StrToFloatDotCommaSeparator(str_in : String; out dValue : Double) : Boolean; overload; // строку в Double с . и ,
  function StrToFloatDotCommaSeparator(str_in : String): Double; overload;                        // строку в Double с . и ,
  function DoubleToString(Value: Double; LengthIndex, DecimalIndex : Integer; UseWhiteSpace : Boolean = False; Separator : Char = ',') : string;
  function StrToAnsi(s : string): AnsiString; // string to AnsiString
  function StrToBytes(const Value: String) : ArrayOfByte_type; // string to array of Byte
  procedure SplitStringToStrings(const value : string; const delimiter : string; var sl : TStringList; AlloyEwptyStrings : Boolean = False); // разбить строку на массив строк по разделителю
  procedure SplitStringToNameValue(const value : string; const delimiter : string; var sName : String; var sValue : String); // разбить строку на имя и значение разделителю
  function GetSubstringAfterSubstr(const Source, SubStr: string): string; // извлечь подстроку, находящуюся после определенной подстроки в строке
  function GetSubstringBeforeSubstr(const Source, Substr: string): string; // извлечь подстроку, находящуюся перед определенной подстрокой в строке
  function SetParamToStr(const ParamStr : String; const delimiter : string; const sName : String; const sValue : String) : String;
  function SetParamsToStr(const ParamStr : String; const delimiter : string; const AddParamStr : String) : String;
  function GetParamFromStr(const ParamStr : String; const delimiter : string; const sName : String; out sValue : String) : HRESULT;

  function StrToHex(const Str: string; Prefix: Char = #0; Delimiter: Char = #0; Use16Bits : Boolean = False): string;    // Преобразуем строку в HEX-представление с указанным разделителем
  function HexToStr(const HexStr: string; UsePrefix: Boolean = False; UseDelimiter: Boolean = False; Use16Bits : Boolean = False): string; // Преобразуем HEX в строку

  function CompareStringWithNumberForCustomSort(List: TStringList; Index1, Index2: Integer): Integer;

implementation

// ----- РАБОТАЕМ С БИТАМИ -----------------------------------------------------
// -----------------------------------------------------------------------------

function IsBitSet(Value : Int64; TheBit: byte): boolean;
begin
  Result := (Value and Int64(Int64(1) shl TheBit)) <> 0;
end;

function IsBitSet(Value : Double; TheBit: byte): boolean;
begin
  Result := IsBitSet(Trunc(Value), TheBit);
end;

procedure SetBitOn(var Value : byte; const TheBit: byte);
begin
  Value := Value or Byte(Byte(1) shl TheBit);
end;
procedure SetBitOn(var Value : Word; const TheBit: byte);
begin
  Value := Value or Word(Word(1) shl TheBit);
end;
procedure SetBitOn(var Value : DWORD; const TheBit: byte);
begin
  Value := Value or DWORD(DWORD(1) shl TheBit);
end;
procedure SetBitOn(var Value : Integer; const TheBit: byte);
begin
  Value := Value or Integer(Integer(1) shl TheBit);
end;
procedure SetBitOn(var Value : Int64; const TheBit: byte);
begin
  Value := Value or Int64(Int64(1) shl TheBit);
end;

function SetBitOn_(const Value : byte; const TheBit: byte): byte;
begin
  Result := Value or Byte(Byte(1) shl TheBit);
end;
function SetBitOn_(const Value : Word; const TheBit: byte): Word;
begin
  Result := Value or Word(Word(1) shl TheBit);
end;
function SetBitOn_(const Value : DWORD; const TheBit: byte): DWORD;
begin
  Result := Value or DWORD(DWORD(1) shl TheBit);
end;
function SetBitOn_(const Value : Integer; const TheBit: byte): Integer;
begin
  Result := Value or Integer(Integer(1) shl TheBit);
end;
function SetBitOn_(const Value : Int64; const TheBit: byte): Int64;
begin
  Result := Value or Int64(Int64(1) shl TheBit);
end;


procedure SetBitOff(var Value : byte;  const TheBit: byte);
begin
  Value := Value and not byte(byte(1) shl TheBit);
end;
procedure SetBitOff(var Value : Word;  const TheBit: byte);
begin
  Value := Value and not Word(Word(1) shl TheBit);
end;
procedure SetBitOff(var Value : DWORD; const TheBit: byte);
begin
  Value := Value and not DWORD(DWORD(1) shl TheBit);
end;
procedure SetBitOff(var Value : Integer; const TheBit: byte);
begin
  Value := Value and not Integer(Integer(1) shl TheBit);
end;
procedure SetBitOff(var Value : Int64; const TheBit: byte);
begin
  Value := Value and not Int64(Int64(1) shl TheBit);
end;

function SetBitOff_(const Value : byte;  const TheBit: byte): byte;
begin
  Result := Value and not byte(byte(1) shl TheBit);
end;
function SetBitOff_(const Value : Word;  const TheBit: byte): Word;
begin
  Result := Value and not Word(Word(1) shl TheBit);
end;
function SetBitOff_(const Value : DWORD; const TheBit: byte): DWORD;
begin
  Result := Value and not DWORD(DWORD(1) shl TheBit);
end;
function SetBitOff_(const Value : Integer; const TheBit: byte): Integer;
begin
  Result := Value and not Integer(Integer(1) shl TheBit);
end;
function SetBitOff_(const Value : Int64; const TheBit: byte): Int64;
begin
  Result := Value and not Int64(Int64(1) shl TheBit);
end;

procedure SetBitToggle(var Value : byte;  const TheBit: byte);
begin
  Value := Value xor byte(byte(1) shl TheBit);
end;
procedure SetBitToggle(var Value : Word;  const TheBit: byte);
begin
  Value := Value xor Word(Word(1) shl TheBit);
end;
procedure SetBitToggle(var Value : DWORD; const TheBit: byte);
begin
  Value := Value xor DWORD(DWORD(1) shl TheBit);
end;
procedure SetBitToggle(var Value : Integer; const TheBit: byte);
begin
  Value := Value xor Integer(Integer(1) shl TheBit);
end;
procedure SetBitToggle(var Value : Int64; const TheBit: byte);
begin
  Value := Value xor Int64(Int64(1) shl TheBit);
end;

function SetBitToggle_(const Value : byte;  const TheBit: byte): byte;
begin
  Result := Value xor byte(byte(1) shl TheBit);
end;
function SetBitToggle_(const Value : Word;  const TheBit: byte): Word;
begin
  Result := Value xor Word(Word(1) shl TheBit);
end;
function SetBitToggle_(const Value : DWORD; const TheBit: byte): DWORD;
begin
  Result := Value xor DWORD(DWORD(1) shl TheBit);
end;
function SetBitToggle_(const Value : Integer; const TheBit: byte): Integer;
begin
  Result := Value xor Integer(Integer(1) shl TheBit);
end;
function SetBitToggle_(const Value : Int64; const TheBit: byte): Int64;
begin
  Result := Value xor Int64(Int64(1) shl TheBit);
end;

function IntegerToBitStr(Value : Int64; Bits: byte = 16; UseSpace4 : Boolean = True; UseSpace8 : Boolean = True; SeniorBitFirst : Boolean = True): String;
var
  i: Integer;
  str1 : string;
begin
  if Bits = 0 then
    begin
      Result := '';
      Exit;
    end;

  str1 := '';
  for i := 0 to Bits-1 do
    begin
      if i > 63 then Continue;

      if IsBitSet(Value, i) then str1 := str1 + '1'
      else str1 := str1 + '0';

      if UseSpace4 then
        if (i mod 4) = 3 then str1 := str1 + ' ';

      if UseSpace8 then
        if (i mod 8) = 7 then str1 := str1 + ' ';
    end;

  str1 := Trim(str1);
  str1 := StringReplace(str1, '  ', ' ', [rfReplaceAll, rfIgnoreCase]);
  if SeniorBitFirst then str1 := ReverseString(str1);

  Result := str1;
end;

//------------------------------------------------------------------------------
// --- проверяем символ на принадлежность к числу ------------------------------
function CheckKeyForFloat(Key : Char; minus : boolean = true; Separator : Char = '_') : Char;
var Separator_temp : Char;
begin
  if Separator = '_' then
    Separator_temp := DecimalSeparator
  else
    Separator_temp := Separator;

  Result := Key;
  if CharInSet(Key, [',', '.']) then Result := Separator_temp;

  if minus then
    begin // с минусом
      if Not CharInSet(Result, ['0'..'9', '-', Separator_temp, Char(VK_BACK), Char(VK_DELETE), Char(VK_LEFT), Char(VK_RIGHT)]) then
        Result := #0;
    end
  else
    begin // без минуса
      if Not CharInSet(Result, ['0'..'9', Separator_temp, Char(VK_BACK), Char(VK_DELETE), Char(VK_LEFT), Char(VK_RIGHT)]) then
        Result := #0;
    end;
end;

function CheckKeyForFloatStr(text : String; var key : Char; minus : boolean = false) : string;
begin
  Result := StringReplace(text,   '.', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, ',', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);

  if CharInSet(Key, [',', '.']) then Key := DecimalSeparator;

  case key of //key - передаваемый символ
    '0'..'9', #8, #13, #$16, #$17, #$18 : key := key; //Разрешаем вводить цифры, бэкспэйс, энтер...и т.д
    //Если знаки не встречается, то вводим их, если уже есть, то присваиваем key - chr(0);
    ',' : if pos(',', text) = 0 then key := key else key := #0;
    '.' : if pos('.', text) = 0 then key := key else key := #0;
    '-' : if pos('-', text) = 0 then
            begin // нет еще минуса
              if minus then
                Result := '-' + Result;

              key := #0;
            end
          else // минус уже есть
            key := #0;
    else key := #0; //В остальных случаях ничего не делаем
  end;
end;

function CheckStrForFloat(Str : String) : Extended;
begin
  if Str <> '' then // если есть текст
    begin
      if not TryStrToFloat(Str, Result) then  // проверка на число
        begin
          Result := 0;
          ExitOnError('Некорректное значение' + #13#10 + Str);
        end
      else
        begin
          Result := StrToFloat(Str);
        end;
    end
  else // str = ''
    begin
      Result := 0;
    end;
end;

function SetStrForFloat(ParamValueStr : String; out ParamValueOut : Double) : Boolean;
var value : Double;
  ParamValueStrTemp : String;
  rez : Boolean;
begin
  if ParamValueStr = '' then // если нет текста
    begin
      ParamValueOut := 0;
      Result := False;
      Exit;
    end;

  ParamValueStrTemp := StringReplace(ParamValueStr, ' ', '', [rfReplaceAll, rfIgnoreCase]); // удаляем пробелы
  ParamValueStrTemp := StringReplace(ParamValueStrTemp, '.', ',', [rfReplaceAll, rfIgnoreCase]);
  rez := TryStrToFloat(ParamValueStrTemp, value);

  if not rez then
    begin
      ParamValueStrTemp := StringReplace(ParamValueStr, ',', '.', [rfReplaceAll, rfIgnoreCase]);
      rez := TryStrToFloat(ParamValueStrTemp, value);
    end;

  if rez then
    begin // число
      ParamValueOut := value;
      Result := True;
    end
  else
    begin // не число
      ParamValueOut := 0;
      Result := False;
    end;
end;

function SetStrForFloat(ParamValueStr : String; out ParamValueOut : Extended) : Boolean;
var value : Extended;
  ParamValueStrTemp : String;
  rez : Boolean;
begin
  if ParamValueStr = '' then // если нет текста
    begin
      ParamValueOut := 0;
      Result := False;
      Exit;
    end;

  ParamValueStrTemp := StringReplace(ParamValueStr, ' ', '', [rfReplaceAll, rfIgnoreCase]); // удаляем пробелы
  ParamValueStrTemp := StringReplace(ParamValueStrTemp, '.', ',', [rfReplaceAll, rfIgnoreCase]);
  rez := TryStrToFloat(ParamValueStrTemp, value);

  if not rez then
    begin
      ParamValueStrTemp := StringReplace(ParamValueStr, ',', '.', [rfReplaceAll, rfIgnoreCase]);
      rez := TryStrToFloat(ParamValueStrTemp, value);
    end;

  if rez then
    begin // число
      ParamValueOut := value;
      Result := True;
    end
  else
    begin // не число
      ParamValueOut := 0;
      Result := False;
    end;
end;

// ----- ОБЩИЕ ФУНКЦИИ ---------------------------------------------------------
// -----------------------------------------------------------------------------

// миллисекунды в дни, часы, минуты, секунды, миллисекунды
// https://www.convert-me.com/ru/convert/time/millisecond/millisecond-to-dhms.html?u=dhms&v=6250d%2013%3A55%3A09.123
procedure SplitMilliseconds2Words(const TotalMS: Int64; out Days, Hours, Minutes, Seconds, Milliseconds: Word);
var
  TotalSeconds: Int64;
begin
  // Миллисекунды -> секунды
  TotalSeconds := TotalMS div 1000;

  // Дни
  Days := TotalSeconds div (24 * 3600); // 24 часа в сутках, 3600 секунд в часе
  TotalSeconds := TotalSeconds mod (24 * 3600);

  // Часы
  Hours := TotalSeconds div 3600; // 3600 секунд в часе
  TotalSeconds := TotalSeconds mod 3600;

  // Минуты
  Minutes := TotalSeconds div 60; // 60 секунд в минуте
  TotalSeconds := TotalSeconds mod 60;

  // Секунды
  Seconds := TotalSeconds;

  // Оставшиеся миллисекунды
  Milliseconds := TotalMS mod 1000;
end;

// миллисекунды в форматированную строку (дни, часы, минуты, секунды, миллисекунды)
function SplitMilliseconds2String(const TotalMS: Int64; const FormattedStr : string = '') : String;
var
  Days, Hours, Minutes, Seconds, Milliseconds: Word;
begin
  try
    SplitMilliseconds2Words(TotalMS, Days, Hours, Minutes, Seconds, Milliseconds);

    if FormattedStr = '' then
      {6250 13:55:09.123     '%.2d %.2d:%.2d:%.2d.%.3d'}
      Result := Format('%.2d %.2d:%.2d:%.2d.%.3d', [Days, Hours, Minutes, Seconds, Milliseconds])
    else
      {"%" [index ":"] ["-"] [width] ["." prec] type
      13:55:09.123 '%1:.2d:%2:.2d:%3:.2d.%4:.3d'
         55:09.123        '%2:.2d:%3:.2d.%4:.3d'}
      Result := Format(FormattedStr, [Days, Hours, Minutes, Seconds, Milliseconds]);
  except
    Result := '';
  end;
end;

// миллисекунды в секунды с округлением вверх
function SplitMilliseconds2SecString(const TotalMS: Int64) : String;
begin
  try
    Result := IntToStr( Ceil(TotalMS/1000) );
  except
    Result := '';
  end;
end;

// перевести строку со временем с миллисекундами в миллисекунды (дни, часы, минуты, секунды, миллисекунды)
function ConvertStringTimeToMilliseconds(const FormattedStr : string = '') : Int64;
var
  Day, Hour, Minute, Second, Millisecond, dk, hk, mk, sk, msk: Word;
  WorkingStr : string;
  TimeParts: TStringList;
begin
  Result := 0;
  // Разделяем строку на части 6250 13:55:09.123 - 540 050 109 123
  WorkingStr := FormattedStr;
  if Length(WorkingStr) >= 13 then // есть дни
    begin
      WorkingStr[Length(WorkingStr)-12] := ':';
    end;
  WorkingStr := StringReplace(WorkingStr, '  ', ' ', [rfReplaceAll, rfIgnoreCase]);
  WorkingStr := StringReplace(WorkingStr, ' ', '0', [rfReplaceAll, rfIgnoreCase]);

  TimeParts := TStringList.Create;
  try
    try
      ExtractStrings(['.',',',':'], [' ','#'], PwideChar(WorkingStr), TimeParts);

      // определяем каких полей нет (если нет - 1, если есть - 0)
      dk  := IfThen(TimeParts.Count > 4, 0, 1);
      hk  := IfThen(TimeParts.Count > 3, 0, 1);
      mk  := IfThen(TimeParts.Count > 2, 0, 1);
      sk  := IfThen(TimeParts.Count > 1, 0, 1);
      msk := IfThen(TimeParts.Count > 0, 0, 1);

      // Преобразование частей строки в числа
      Day         := IfThen(dk = 0,  StrToInt(TimeParts[0]), 0);
      Hour        := IfThen(hk = 0,  StrToInt(TimeParts[1-dk]), 0);
      Minute      := IfThen(mk = 0,  StrToInt(TimeParts[2-dk-hk]), 0);
      Second      := IfThen(sk = 0,  StrToInt(TimeParts[3-dk-hk-mk]), 0);
      Millisecond := IfThen(msk = 0, StrToInt(TimeParts[4-dk-hk-mk-sk]), 0);

      // Вычисление общего количества миллисекунд
      Result := Int64(Day) * 86400000 + // Дни в миллисекундах
                Int64(Hour) * 3600000 + // Часы в миллисекундах
                Int64(Minute) * 60000 + // Минуты в миллисекундах
                Int64(Second) * 1000 +  // Секунды в миллисекундах
                Int64(Millisecond);     // Миллисекунды
    except
      MessageBox(0, PChar('Ошибка преобразования строки "' + FormattedStr + '" в миллисекунды'), PChar('Ошибка преобразования строки'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);
    end;
  finally
    TimeParts.Free;
  end;
end;

 // перевести строку со временем в TDateTime с проверкой и выдачей ошибки
function ConvertStringToDateTime(const S: string; out Value: TDateTime; ShowError : Boolean = true; CheckZero : Boolean = true): Boolean;
begin
  if TryStrToDateTime(S, Value) then
    begin
      Result := True; // Присваиваем правильно распознанное время

      if Value = 0 then // нулевое значение
      if ShowError then // Сообщаем об ошибке ввода
      if CheckZero then // надо проверять на 0
        begin
          raise Exception.CreateFmt('Значение времени не может быть нулевым "%s"', [S]);
        end;
    end
  else
    begin
      Value  := 0; // нулевое значение
      Result := False;

      if ShowError then // Сообщаем об ошибке ввода
        raise Exception.CreateFmt('Неверный формат времени "%s"', [S]);
    end;
end;

// строку в Double с заменой . и ,
function StrToFloatDecimalSeparator(str_in : String) : Double;
var fstr : String;
begin
  fstr := str_in;
  fstr  := StringReplace(fstr, ',', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);
  fstr  := StringReplace(fstr, '.', DecimalSeparator, [rfReplaceAll, rfIgnoreCase]);

  TryStrToFloat(fstr, Result);
end;

// строку в Double с . и ,
function StrToFloatDotCommaSeparator(str_in : String; out dValue : Double) : Boolean; overload;
var fstr : String;
begin
  // проверка с точкой
  fstr  := StringReplace(str_in, ',', '.', [rfReplaceAll, rfIgnoreCase]);
  if TryStrToFloat(fstr, dValue) then
    begin
      Result := True;
      Exit;
    end;

  // проверка с запятой
  fstr  := StringReplace(str_in, '.', ',', [rfReplaceAll, rfIgnoreCase]);
  if TryStrToFloat(fstr, dValue) then
    begin
      Result := True;
      Exit;
    end;

  dValue := 0;
  Result := False;
end;

function StrToFloatDotCommaSeparator(str_in : String): Double; overload;
begin
  StrToFloatDotCommaSeparator(str_in, Result);
end;

// Double в строку с количеством знаков после запятой
function DoubleToString(Value: Double; LengthIndex, DecimalIndex : Integer; UseWhiteSpace : Boolean = False; Separator : Char = ',') : string;
var
  position, i : Integer;
  Shorttemp : ShortString;
begin
  Result := '';

  try
    Str(Value:LengthIndex:DecimalIndex, Shorttemp);
    Result := string(Shorttemp);
    Result := Trim(Result); // убираем пробелы в начале строки

    Result := StringReplace(Result, '.', Separator, [rfReplaceAll, rfIgnoreCase]); // замена . на Separator
    Result := StringReplace(Result, ',', Separator, [rfReplaceAll, rfIgnoreCase]); // замена , на Separator

    position := Pos(Separator, Result);

    // деление на разряды
    if UseWhiteSpace then
      begin
        if position = 0 then
          i := Length(Result) - 2
        else
          i := position - 3;

        while i > 1 do
          begin
            Insert(' ', Result, i);
            i := i-3;
          end;
      end;
  except
    Result := 'ошибка';
  end;
end;

// string to AnsiString
function StrToAnsi(s : string): AnsiString;
var
  astr: ansistring;
  i: integer;
begin
  for i := 1 to length(s) do
    begin
      astr := astr + AnsiString(s[i]);
    end;
  result := lpcstr(astr);
end;

// string to array of Byte
function StrToBytes(const Value: String) : ArrayOfByte_type;
var i : integer;
begin
  SetLength(Result, Length(Value));
  for i := 0 to Length(Value) - 1 do
    Result[i] := ord(Value[i + 1]);
end;

// разбить строку на массив строк по разделителю
procedure SplitStringToStrings(const value : string; const delimiter : string; var sl : TStringList; AlloyEwptyStrings : Boolean = False);
var
  dx : integer;
  ns : string;
  txt : string;
  delta : integer;
begin
  delta := Length(delimiter);
  txt := value;// + delimiter;
  sl.BeginUpdate;
  sl.Clear;
  try
    while Length(txt) > 0 do
      begin
        dx := AnsiPos(delimiter, txt);

        if dx > 0 then
          begin
            ns := Copy(txt,0,dx-1);
            txt := Copy(txt,dx+delta,MaxInt);
          end
        else // последняя часть без разделителя в конце
          begin
            ns := txt;
            txt := '';
          end;

        if (ns = '') and (not AlloyEwptyStrings) then Continue;

        sl.Add(ns);
      end;
  finally
    sl.EndUpdate;
  end;
end;

// разбить строку на имя и значение разделителю
procedure SplitStringToNameValue(const value : string; const delimiter : string; var sName : String; var sValue : String);
var
  dx : integer;
  txt : string;
  delta : integer;
begin
  sName  := '';
  sValue := '';
  txt := value;
  delta := Length(delimiter);

  dx := AnsiPos(delimiter, txt);
  if dx = 0 then
    begin
      sName  := txt;
      Exit;
    end;

  sName := Copy(txt,0,dx-1);
  txt := Copy(txt,dx+delta,MaxInt);

  dx := AnsiPos(delimiter, txt);
  if dx = 0 then
    begin
      sValue  := txt;
      Exit;
    end;

  sValue := Copy(txt,0,dx-1);
end;

// извлечь подстроку, находящуюся после определенной подстроки в строке
function GetSubstringAfterSubstr(const Source, SubStr: string): string;
var
  Index: Integer;
begin
  Index := Pos(SubStr, Source);
  if Index > 0 then
    Result := Copy(Source, Index + Length(SubStr), MaxInt)
  else
    Result := '';
end;

// извлечь подстроку, находящуюся перед определенной подстрокой в строке
function GetSubstringBeforeSubstr(const Source, Substr: string): string;
var
  Position: Integer;
begin
  Position := Pos(Substr, Source);
  if Position = 0 then
    Result := ''
  else
    Result := Copy(Source, 1, Position - 1);
end;

// добавить/обновить имя и значение
function SetParamToStr(const ParamStr : String; const delimiter : string; const sName : String; const sValue : String) : String;
var
  Params : TStringList;
  str_out : String;
  FoundIndex : Integer;
begin
  str_out := ParamStr;
  Params := TStringList.Create;
  try
    Params.Delimiter := delimiter[1]; // Устанавливаем разделитель между параметрами
    //Params.DelimitedText := str_in;       // 'Key1=Value1;Key2=Value2';

    SplitStringToStrings(ParamStr, delimiter, Params); // разбить строку на массив строк по разделителю

    FoundIndex := Params.IndexOfName(sName);

    if FoundIndex <> -1 then
      begin // Обновить существующее значение
        Params[FoundIndex] := sName + '=' + sValue;
      end
    else
      begin // Добавить новую пару имя-значение
        Params.Add(sName + '=' + sValue);
      end;

    str_out := Params.DelimitedText;
    str_out := StringReplace(str_out, '"', '', [rfReplaceAll, rfIgnoreCase]); // убираем ", если есть пробелы
  finally
    Params.Free;
    Result := str_out;
  end;
end;

// добавить/обновить имя и значение пакетом из строки
function SetParamsToStr(const ParamStr : String; const delimiter : string; const AddParamStr : String) : String;
var
  AddParams : TStringList;
  str_out, sName, sValue : String;
  i : Integer;
begin
  Result  := ParamStr;
  str_out := ParamStr;

  AddParams := TStringList.Create;
  try
    AddParams.Delimiter := delimiter[1]; // Устанавливаем разделитель между параметрами
    //Params.DelimitedText := str_in;       // 'Key1=Value1;Key2=Value2';

    SplitStringToStrings(AddParamStr, delimiter, AddParams); // разбить строку на массив строк по разделителю

    for i := 0 to AddParams.Count - 1 do
      begin
        // разбить строку на имя и значение разделителю
        SplitStringToNameValue(AddParams[i], '=', sName, sValue);

        // добавить/обновить имя и значение
        str_out := SetParamToStr(str_out, delimiter, sName, sValue);
      end;
  finally
    AddParams.Free;
    Result := str_out;
  end;
end;

// получить значение по имени
function GetParamFromStr(const ParamStr : String; const delimiter : string; const sName : String; out sValue : String) : HRESULT;
var
  Params : TStringList;
  FoundIndex : Integer;
begin
  sValue := '';

  Params := TStringList.Create;
  try
    Params.Delimiter := delimiter[1]; // Устанавливаем разделитель между параметрами
    //Params.DelimitedText := str_in;       // 'Key1=Value1;Key2=Value2';

    SplitStringToStrings(ParamStr, delimiter, Params); // разбить строку на массив строк по разделителю

    FoundIndex := Params.IndexOfName(sName);

    if FoundIndex <> -1 then
      begin // нашли параметр
        sValue := GetSubstringAfterSubstr(Params[FoundIndex], '=');
        //sValue := Params.DelimitedText; // для проверки

        Result := S_OK;
      end
    else
      begin // не нашли параметр
        Result := S_FALSE;
      end;
  finally
    Params.Free;
  end;
end;

// Преобразуем строку в HEX-представление с указанным разделителем
function StrToHex(const Str: string; Prefix: Char = #0; Delimiter: Char = #0; Use16Bits : Boolean = False): string;
var i : Integer;
  astr: AnsiString;
begin
  Result := '';

  if Use16Bits then
    begin // 16 bit

      for i := 1 to Length(Str) do
        begin
          if Prefix <> #0 then
            Result := Result + Prefix;

          Result := Result + IntToHex(Integer(Str[i]), 4);

          if Delimiter <> #0 then
          if i < Length(Str) then
            Result := Result + Delimiter;
        end;
    end
  else // 8 bit
    begin
      astr := StrToAnsi(str);

      for i := 1 to Length(astr) do
        begin
          if Prefix <> #0 then
            Result := Result + Prefix;

          Result := Result + IntToHex(Integer(astr[i]), 2);

          if Delimiter <> #0 then
          if i < Length(astr) then
            Result := Result + Delimiter;
        end;
    end;
end;

// Преобразуем HEX в строку
function HexToStr(const HexStr: string; UsePrefix: Boolean = False; UseDelimiter: Boolean = False; Use16Bits : Boolean = False): string;
var
  i : Integer;
  ByteValue : Word;
begin
  Result := '';
  i := 1;

  while i < Length(HexStr) do
    begin
      if UsePrefix then i := i + 1;

      if Use16Bits then
        begin // 16 bit
          if (i + 3) > Length(HexStr) then Exit;

          ByteValue := StrToInt('$' + Copy(HexStr, i, 4));
          Result := Result + Char(ByteValue);

          i := i + 4;
        end
      else // 8 bit
        begin
          if (i + 1) > Length(HexStr) then Exit;

          ByteValue := StrToInt('$' + Copy(HexStr, i, 2));
          Result := Result + string(AnsiChar(ByteValue));

          i := i + 2;
        end;

      if UseDelimiter then i := i + 1;
    end;
end;

function CompareStringWithNumberForCustomSort(List: TStringList; Index1, Index2: Integer): Integer;
var
  S1, S2: string;
  Num1, Num2: Integer;
  Pos1, Pos2: Integer;
begin
  S1 := List[Index1];
  S2 := List[Index2];

  // Находим позицию первой цифры в конце строки 1
  Pos1 := Length(S1);
  while (Pos1 > 0) and (CharInSet(S1[Pos1], ['0'..'9'])) do
    Dec(Pos1);
  // Если нашли цифры, извлекаем их и конвертируем в число
  if Pos1 < Length(S1) then
    Num1 := StrToIntDef(Copy(S1, Pos1 + 1, Length(S1) - Pos1), 0)
  else
    Num1 := 0;

  // Находим позицию первой цифры в конце строки 2
  Pos2 := Length(S2);
  while (Pos2 > 0) and (CharInSet(S2[Pos2], ['0'..'9'])) do
    Dec(Pos2);
  // Если нашли цифры, извлекаем их и конвертируем в число
  if Pos2 < Length(S2) then
    Num2 := StrToIntDef(Copy(S2, Pos2 + 1, Length(S2) - Pos2), 0)
  else
    Num2 := 0;

  // Сравниваем числовые части
  if Num1 < Num2 then
    Result := -1
  else
    if Num1 > Num2 then
      Result := 1
    else
      begin
        // Если числовые части равны, сравниваем как строки
        if S1 < S2 then
          Result := -1
        else
          if S1 > S2 then
            Result := 1
          else
            Result := 0;
      end;
end;

end.
