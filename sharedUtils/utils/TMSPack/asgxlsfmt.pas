{***************************************************************************}
{ TAdvStringGrid XLS format function                                        }
{ for Delphi & C++Builder                                                   }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright � 2014                                               }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}
unit asgxlsfmt;

interface

  function XlsFormat(const V: variant; const Format: string): string;

implementation

uses
  Classes, Math, StrUtils, Variants, Graphics, SysUtils;

type
  WidestringArray = array of string;
  PFormatSettings = ^TFormatSettings;

  TResultCondition = record
    SupressNeg: Boolean;
    SupressNegComp: Boolean;
    Complement: Boolean;
    Assigned: boolean;
  end;

  TResultConditionArray = Array of TResultCondition;


var
  CachedRegionalCulture: TFormatSettings;  //Cached because it is slow.
  RegionalSet : TFormatSettings; //Must be global so it is not freed when we point to it.

const
       /// <summary>Difference in days between the 1900 and 1904 date systems supported by Excel.</summary>
       Date1904Diff = 4 * 365 + 2;
  TxtTrue='TRUE';
  TxtFalse='FALSE';

//  function TryFormatDateTime1904(const Fmt: string; value: TDateTime; const Dates1904: boolean; const LocalSettings: TFormatSettings): string; overload;
//  function TryFormatDateTime1904(const Fmt: string; value: TDateTime; const Dates1904: boolean): string; overload;


function GetResultCondition(const aSupressNeg: Boolean; const aSupressNegComp: Boolean; const aComplement: Boolean; const aAssigned: Boolean): TResultCondition;
begin
  Result.SupressNeg := aSupressNeg;
  Result.SupressNegComp := aSupressNegComp;
  Result.Complement := aComplement;
  Result.Assigned := aAssigned;
end;

function FindFrom(const wc: Char; const w: string; const p: integer): integer;
begin
  Result := Pos(wc, copy(w, p, Length(w)))
end;

function TryStrToFloatInvariant(const s: string; out i: extended): boolean;
var
  errcode: integer;
begin
  i := 0;
  val(s, i, errcode);
  Result := errCode = 0;
end;

function GetconditionNumber(const Format: string; const p: integer; out HasErrors: Boolean): Extended;
var
  p2: integer;
  number: string;
begin
  HasErrors := true;
  p2 := FindFrom(']', Format, p + 1) - 1;
  if p2 < 0 then
    begin Result := 0; exit; end;

  number := copy(Format, p + 1, p2);
  Result := 0;
  HasErrors := not TryStrToFloatInvariant(number, Result);
end;


function EvalCondition(const Format: string; const position: integer; const V: Double; out ResultValue: Boolean; out SupressNegativeSign: Boolean; out SupressNegativeSignComp: Boolean): Boolean;
var
  HasErrors: Boolean;
  c: Double;
begin
  SupressNegativeSign := false;
  SupressNegativeSignComp := false;
  ResultValue := false;
  if (position + 2) >= Length(Format) then  //We need at least a sign and a bracket.
    begin Result := false; exit; end;

  case Format[1 + position] of
  '=':
    begin
      begin
        c := GetconditionNumber(Format, position + 1, HasErrors);
        if HasErrors then
          begin Result := false; exit; end;

        ResultValue := V = c;
        SupressNegativeSign := true;
        SupressNegativeSignComp := false;
        begin Result := true; exit; end;
      end;
    end;
  '<':
    begin
      begin
        if Format[1 + position + 1] = '=' then
        begin
          c := GetconditionNumber(Format, position + 2, HasErrors);
          if HasErrors then
            begin Result := false; exit; end;

          ResultValue := V <= c;
          if c <= 0 then
            SupressNegativeSign := true else
            SupressNegativeSign := false;

          SupressNegativeSignComp := true;
          begin Result := true; exit; end;
        end;

        if Format[1 + position + 1] = '>' then
        begin
          c := GetconditionNumber(Format, position + 2, HasErrors);
          if HasErrors then
            begin Result := false; exit; end;

          ResultValue := V <> c;
          SupressNegativeSign := false;
          SupressNegativeSignComp := true;
          begin Result := true; exit; end;
        end;

        begin
          c := GetconditionNumber(Format, position + 1, HasErrors);
          if HasErrors then
            begin Result := false; exit; end;

          ResultValue := V < c;
          if c <= 0 then
            SupressNegativeSign := true else
            SupressNegativeSign := false;

          SupressNegativeSignComp := true;
          begin Result := true; exit; end;
        end;
      end;
    end;
  '>':
    begin
      begin
        if Format[1 + position + 1] = '=' then
        begin
          c := GetconditionNumber(Format, position + 2, HasErrors);
          if HasErrors then
            begin Result := false; exit; end;

          ResultValue := V >= c;
          if c <= 0 then
            SupressNegativeSignComp := true else
            SupressNegativeSignComp := false;

          SupressNegativeSign := false;
          begin Result := true; exit; end;
        end;

        begin
          c := GetconditionNumber(Format, position + 1, HasErrors);
          if HasErrors then
            begin Result := false; exit; end;

          ResultValue := V > c;
          if c <= 0 then
            SupressNegativeSignComp := true else
            SupressNegativeSignComp := false;

          SupressNegativeSign := false;
          begin Result := true; exit; end;
        end;
      end;
    end;
  end;
  Result := false;
end;

function GetNegativeSign(const Conditions: TResultConditionArray; const SectionCount: integer; var TargetedSection: integer; const V: Double): Boolean;
var
  NullCount: integer;
  CompCount: integer;
  Comp: TResultCondition;
  i: integer;
begin
  if TargetedSection < 0 then
  begin
    if (not Conditions[0].Assigned) and (((V > 0) or (SectionCount <= 1)) or ((V = 0) and (SectionCount <= 2))) then
    begin
      TargetedSection := 0;
      begin Result := false; exit; end;  //doesn't matter.
    end;

    if (not Conditions[1].Assigned) and ((V < 0) or (SectionCount <= 2)) then
    begin
      TargetedSection := 1;
      if (SectionCount = 2) and (Conditions[0].Assigned) then
        begin Result := Conditions[0].SupressNegComp; exit; end;

      begin Result := true; exit; end;
    end;

    if (not Conditions[2].Assigned) then
      TargetedSection := 2 else
      TargetedSection := 3;

    begin Result := false; exit; end;
  end;

  if Conditions[TargetedSection].Assigned then
  begin
    Result := Conditions[TargetedSection].SupressNeg; exit;
  end;

  NullCount := 0;  //Find Complement, if any
  CompCount := 0;
  Comp := GetResultCondition(false, false, false, false);
  for i := 0 to SectionCount - 1 do
  begin
    if Conditions[i].Assigned then
    begin
      Assert(Conditions[i].Complement);
      Inc(CompCount);
      if CompCount > 1 then
        begin Result := false; exit; end;

      Comp := Conditions[i];
    end
    else
    begin
      Inc(NullCount);
      if NullCount > 1 then
        begin Result := false; exit; end;

    end;

  end;

  if Comp.Assigned then
    begin Result := Comp.SupressNegComp; exit; end;

  Result := false;
end;




function GetSections(const Format: string; const V: Double; out TargetedSection: integer; out SectionCount: integer; out SupressNegativeSign: Boolean): WideStringArray;
var
  InQuote: Boolean;
  Conditions: TResultConditionArray;
  CurrentSection: integer;
  StartSection: integer;
  i: integer;
  TargetsThis: Boolean;
  SupressNegs: Boolean;
  SupressNegsComp: Boolean;
  FormatLength: Integer;
begin
  InQuote := false;
  SetLength (Result, 4);
  for i:= 0 to Length(Result) - 1 do Result[i] := '';
  SetLength (Conditions, 4);
  for i:= 0 to Length(Conditions) - 1 do Conditions[i] := GetResultCondition(false, false, false, false);
  CurrentSection := 0;
  StartSection := 0;
  TargetedSection := -1;
  i := 0;

  FormatLength := Length(Format);
  while i < FormatLength do
  begin
      if Format[1 + i] = '"' then
      begin
        InQuote := not InQuote;
      end;

      if InQuote then
      begin
        Inc(i);
        continue;  //escaped characters inside a quote like \" are not valid.
      end;

      if Format[1 + i] = '\' then
      begin
        i:= i + 2;
        continue;
      end;

      if Format[1 + i] = '[' then
      begin
        if (i + 2) < FormatLength then
        begin
          if EvalCondition(Format, i + 1, V, TargetsThis, SupressNegs, SupressNegsComp) then
          begin
            Conditions[CurrentSection] := GetResultCondition(SupressNegs, SupressNegsComp, not TargetsThis, true);
            if TargetedSection < 0 then
            begin
              if TargetsThis then
              begin
                TargetedSection := CurrentSection;
              end;

            end;

          end;

        end;

         //Quotes inside brackets are not quotes. So we need to process the full bracket.
        while (i < FormatLength) and (Format[1 + i] <> ']') do
        begin
          Inc(i)
        end;
        Inc(i);
        continue;
      end;

      if Format[1 + i] = ';' then
      begin
        if i > StartSection then
          Result[CurrentSection] := copy(Format, StartSection + 1, i - StartSection);

        Inc(CurrentSection);
        SectionCount := CurrentSection;
        if CurrentSection >= Length(Result) then
        begin
          SupressNegativeSign := GetNegativeSign(Conditions, SectionCount, TargetedSection, V);
          exit;
        end;

        StartSection := i + 1;
      end;

      Inc(i);
  end;

  if i > StartSection then
    Result[CurrentSection] := copy(Format, StartSection + 1, i - StartSection + 1);

  Inc(CurrentSection);
  SectionCount := CurrentSection;
  SupressNegativeSign := GetNegativeSign(Conditions, SectionCount, TargetedSection, V);
end;



function GetSection(const Format: string; const V: Double; out SectionMatches: Boolean; out SupressNegativeSign: Boolean): string;
var
  TargetedSection: integer;
  SectionCount: integer;
  Sections: WideStringArray;
begin
  SectionMatches := true;
  Sections := GetSections(Format, V, TargetedSection, SectionCount, SupressNegativeSign);
  if TargetedSection >= SectionCount then
  begin
    SectionMatches := false;  //No section matches condition. This has changed in Excel 2007, older versions would show an empty cell here, and Excel 2007 displays "####". We will use Excel2007 formatting.
    begin Result := ''; exit; end;
  end;

  if Sections[TargetedSection] = null then
    Result := '' else
    Result := Sections[TargetedSection];

end;

function GetDefaultLocaleFormatSettings: PFormatSettings;
begin
    if (CachedRegionalCulture.DecimalSeparator = #0) then
      CachedRegionalCulture := TFormatSettings.Create();

  Result:= @CachedRegionalCulture;
end;

function TryFormatDateTime1904(const Fmt: string; value: TDateTime; const Dates1904: boolean; const LocalSettings: TFormatSettings): string; overload;
begin
  try
    if (Dates1904) then value:= value + Date1904Diff;
    Result :=FormatDateTime(Fmt, value, LocalSettings);
  except
    Result :='##';
  end;
end;

function TryFormatDateTime1904(const Fmt: string; value: TDateTime; const Dates1904: boolean): string; overload;
begin
  try
    if (Dates1904) then value:= value + Date1904Diff;
    Result :=FormatDateTime(Fmt, value);
  except
    Result :='##';
  end;
end;

procedure CheckColor(const Format: string; var Color: integer; out p: integer);
var
  s: string;
  IgnoreIt: boolean;
begin
  p:=1;
  if (Length(Format)>0) and (Format[1]='[') and (pos(']', Format)>0) then
  begin
    IgnoreIt:=false;
    s:=copy(Format,2,pos(']', Format)-2);
    if s = 'Black'  then Color:=clBlack else
    if s = 'Cyan'   then Color:=clAqua else
    if s = 'Blue'   then Color:=clBlue else
    if s = 'Green'  then Color:=clGreen else
    if s = 'Magenta'then Color:=clFuchsia else
    if s = 'Red'    then Color:=clRed else
    if s = 'White'  then Color:=clWhite else
    if s = 'Yellow' then Color:=clYellow

    else IgnoreIt:=true;

    if not IgnoreIt then p:= Pos(']', Format)+1;
  end;
end;

procedure CheckOptional(const V: Variant; const Format: string; var p: integer; var TextOut: string);
var
  p2, p3: integer;
begin
  if p>Length(Format) then exit;
  if Format[p]='[' then
  begin
    p2:=FindFrom(']', Format, p);
    if (p<Length(Format))and(Format[p+1]='$') then //currency
    begin
      p3:=FindFrom('-', Format+'-', p);
      TextOut:=TextOut + copy(Format, p+2, min(p2,p3)-3);
    end;
    Inc(p, p2);
  end;
end;

procedure CheckLiteral(const V: Variant; const Format: string; var p: integer; var TextOut: string);
var
  FormatLength: integer;
begin
  FormatLength := Length(Format);
  if p>FormatLength then exit;
  if (ord(Format[p])<255) and (AnsiChar(Format[p]) in[' ','$','(',')','!','^','&','''',#$B4,'~','{','}','=','<','>']) then
    begin
      TextOut:=TextOut+Format[p];
      inc(p);
      exit;
    end;

  if (Format[p]='\') or (Format[p]='*')then
    begin
      if p<FormatLength then TextOut:=TextOut+Format[p+1];
      inc(p,2);
      exit;
    end;

  if Format[p]='_' then
    begin
      if p<FormatLength then TextOut:=TextOut+' ';
      inc(p,2);
      exit;
    end;

  if Format[p]='"' then
  begin
    inc(p);
    while (p<=FormatLength) and (Format[p]<>'"') do
    begin
      TextOut:=TextOut+Format[p];
      inc(p);
    end;
    if p<=FormatLength then inc(p);
  end;
end;

procedure EnsureAMPM(var FormatSettings: PFormatSettings);
begin
       //Windows uses empty AM/PM designators as empty. Excel uses AM/PM. This happens for example on German locale.
      if (FormatSettings.TimeAMString = '') then
      begin
        FormatSettings.TimeAMString := 'AM';
      end;
      if (FormatSettings.TimePMString = '') then
      begin
        FormatSettings.TimePMString := 'PM';
      end;
end;

procedure CheckDate(var RegionalCulture: PFormatSettings; const V: Variant; const Format: string; const Dates1904: boolean; var p: integer;
var TextOut: string; var LastHour: boolean;var HasDate, HasTime: boolean);
const
  DateTimeChars=['C','D','W','M','Q','Y','H','N','S','T','A','P','/',':','.','\'];
  DChars=['C','D','Y'];
  TChars=['H','N','S'];
var
  Fmt: string;
  FormatLength: integer;
begin
  FormatLength := Length(Format);
  Fmt:='';
  while (p<=FormatLength) and (ord(Format[p])<255) and (Upcase(AnsiChar(Format[p])) in DateTimeChars) do
  begin
    if (Format[p] = '\') then inc(p);
    if p > FormatLength then exit;

    if (p > 2) and (Format[p] = '/') and (p + 2 <= FormatLength)
    and ((Format[p-1] = 'M') or (Format[p-1] = 'm'))
    and ((Format[p-2] = 'A') or (Format[p-2] = 'a'))
    and ((Format[p+1] = 'P')  or (Format[p+1] = 'p'))
    and ((Format[p+2] = 'M')  or (Format[p+2] = 'm')) then
    begin             //AM/PM, must be changed to AMPM
      HasTime := true;
      Fmt:=Fmt + 'PM';
      inc (p, 3);
      continue;
    end;


    if (UpCase(AnsiChar(Format[p])) in DChars)or
       (not LastHour and (UpCase(AnsiChar(Format[p]))='M')) then HasDate:=true;
    if (UpCase(AnsiChar(Format[p])) in TChars)or
       (LastHour and (UpCase(AnsiChar(Format[p]))='M')) then HasTime:=true;

    if (UpCase(AnsiChar(Format[p]))='H') then LastHour:=true;
    if LastHour and (UpCase(AnsiChar(Format[p]))='M') then
    begin
      while (p<=FormatLength) and (UpCase(AnsiChar(Format[p]))='M') do
      begin
        Fmt:=Fmt+'n';
        inc(p);
      end;
      LastHour:=false;
    end else
    begin
      Fmt:=Fmt+Format[p];
      inc(p);
    end;
  end;

  EnsureAMPM(RegionalCulture);

  if Fmt<>'' then TextOut:=TextOut+TryFormatDateTime1904(Fmt,v, Dates1904, RegionalCulture^);
end;

procedure CheckNumber( V: Variant; const NegateValue: Boolean; const wFormat: string; var p: integer; var TextOut: string);
const
  NumberChars=['0','#','.',',','e','E','+','-','%','\','?','*','"', ' '];
var
  Fmt: string;
  Format : string;
  FormatLength: integer;
  p0: integer;
begin
  Format := wFormat;
  FormatLength := Length(Format);
  Fmt:='';
  p0 := p;
  while (p<=FormatLength) and (ord(wFormat[p])<255) and (AnsiChar(Format[p]) in NumberChars) do
  begin
    if (Format[p]='"') and (p > p0) then
    begin
      inc(p);
      while (p <= FormatLength) and (wFormat[p] <> '"') do
      begin
        if (Format[p] <> '\') then Fmt := Fmt + Format[p];
        inc(p);
      end;
      continue;
    end;

    if Format[p]='%' then V:=V*100;
    if (Format[p] = '\') then inc(p);
    if (p <= FormatLength) then
    begin
      if (Format[p] = '?') then Fmt:=Fmt+'#'
      else if (Format[p] = '*') then
      begin
        if (p<Length(Format)) then Fmt := Fmt + Format[p + 1];
        inc(p);
      end
      else Fmt:=Fmt+Format[p];
      inc(p);
    end;
  end;

  if (NegateValue) and (v < 0) then v := -v;
  if Fmt<>'' then TextOut:=TextOut+FormatFloat(Fmt,v);
end;

procedure CheckRegionalSettings(const Format: string; var RegionalCulture: PFormatSettings; var p: integer; var TextOut: string; const Quote: Boolean);
var
  StartCurr: integer;
  v: string;
  StartStr: integer;
  EndStr: integer;
  Len: integer;
  Offset: integer;
  i: integer;
  digit: AnsiChar;
  Result: integer;
  FormatLength: integer;
begin
  FormatLength := Length(Format);
  if p - 1 >= (FormatLength - 3) then
    exit;

  if copy(Format, p, 2) = '[$' then  //format is [$Currency-Locale]
  begin
    p:= p + 2;
    StartCurr := p;  //Currency
    while (Format[p] <> '-') and (Format[p] <> ']') do
    begin
      Inc(p);
      if p - 1 >= FormatLength then  //no tag found.
        exit;
    end;

    if (p - StartCurr) > 0 then
    begin
      if Quote then
        TextOut := TextOut + '"';

      v := copy(Format, StartCurr, p - StartCurr);
      if Quote then
        StringReplace(v, '"', '"\""', [rfReplaceAll]);

      TextOut := TextOut + v;
      if Quote then
        TextOut := TextOut + '"';

    end;

    if Format[p] <> '-' then
    begin
      Inc(p);
      exit;  //no culture info.
    end;

    Inc(p);
    StartStr := p;
    while (p <= FormatLength) and (Format[p] <> ']') do
    begin
      begin
        Inc(p);
      end;
    end;
    if p <= FormatLength then  //We actually found a close tag
    begin
      EndStr := p;
      Inc(p);  //add the ']' char.
      Len := Math.Min(4, EndStr - StartStr);
      Result := 0;  //to avoid issues with non existing tryparse we will convert from hexa directly.
      Offset := 0;
      for i := EndStr - 1 downto EndStr - Len do
      begin
        if (Format[i]) >=#255 then exit; //cannot parse
        digit := UpCase(AnsiChar(Format[i]));
        if (digit >= '0') and (digit <= '9') then
        begin
          Result:= Result + ((integer(digit) - integer('0')) shl Offset);
          Offset:= Offset + 4;
          continue;
        end;

        if (digit >= 'A') and (digit <= 'F') then
        begin
          Result:= Result + (((10 + integer(digit)) - integer('A')) shl Offset);
          Offset:= Offset + 4;
          continue;
        end;

        exit;  //Cannot parse.
      end;

      if Result < 0 then
        exit;

      try
        {$warn SYMBOL_PLATFORM OFF}
        RegionalSet := TFormatSettings.Create(Result);
        {$warn SYMBOL_PLATFORM ON}
      except
      begin
         //We could not create the culture, so we will continue with the existing one.
       end;
      end;
    end;

  end;

end;

procedure CheckEllapsedTime(const value: variant; const UpFormat: string; var p: Int32; var TextOut: string; var HasDate: Boolean; var HasTime: Boolean; out HourPos: Int32);
var
  endP: Int32;
  HCount: Int32;
  MCount: Int32;
  SCount: Int32;
  d: Double;
  Count: Int32;
begin
  HourPos := -1;
  if (p >= Length(UpFormat)) or (UpFormat[p] <> '[') then
    exit;

  endP := p + 1;
  HCount := 0;
  MCount := 0;
  SCount := 0;
  while (endP < Length(UpFormat)) and (UpFormat[endP] <> ']') do
  begin
    begin
      if UpFormat[endP] = 'H' then
        Inc(HCount) else
        if UpFormat[endP] = 'M' then
          Inc(MCount) else
          if UpFormat[endP] = 'S' then
            Inc(SCount) else
            exit;  //only h and m formats here.
      Inc(endP);
    end;
  end;
  if endP >= Length(UpFormat) then
    exit;

  if ((HCount <= 0) and (MCount <= 0)) and (SCount <= 0) then
    exit;

  if (((HCount * MCount) <> 0) or ((HCount * SCount) <> 0)) or ((MCount * SCount) <> 0) then
    exit;

  HasTime := true;

  d := value;


  Count := 0;
  if HCount > 0 then
  begin
    d := d * 24;
    Count := HCount;
  end
  else
    if MCount > 0 then
    begin
      d := (d * 24) * 60;
      Count := MCount;
    end
    else
      if SCount > 0 then
      begin
        d := (d * 24) * 3600;
        Count := SCount;
      end;

  d := Floor(Abs(d)) * Sign(d);
  TextOut := TextOut + FormatFloat(StringOfChar('0', Count), d);
  p := endP + 1;
  if HCount > 0 then
    HourPos := p;
end;



function FormatNumber(const V: Variant; const NegateValue: Boolean; const Format: string; const Dates1904: boolean; var Color: integer;var HasDate, HasTime: boolean): string;
var
  p, p1: integer;
  LastHour: boolean;
  HourPos: integer;
  FormatLength: integer;
  RegionalCulture: PFormatSettings;
  UpFormat: string;
begin
  FormatLength := Length(Format);

  UpFormat := UpperCase(Format);
  RegionalCulture := GetDefaultLocaleFormatSettings;
  CheckColor(Format, Color, p);
  Result:='';  LastHour:=false;
  while p<=FormatLength do
  begin
    p1:=p;
    CheckRegionalSettings(Format, RegionalCulture, p, Result, false);
    CheckEllapsedTime(v, UpFormat, p, Result, HasDate, HasTime, HourPos);
    LastHour := HourPos = p;
    CheckOptional(V, Format, p, Result);
    CheckLiteral (V, Format, p, Result);
    CheckDate    (RegionalCulture, V, Format, Dates1904, p, Result, LastHour, HasDate, HasTime);
    CheckNumber  (V, NegateValue, Format, p, Result);
    if p1=p then //not found
    begin
      if (NegateValue) and (V < 0) then Result := -V  //Format number is always called with a numeric arg
      else Result:=V;
      exit;
    end;
  end;
end;

procedure CheckText(const V: Variant; const Format: string; var p: integer; var TextOut: string);
begin
  if p>Length(Format) then exit;
  if Format[p]='@' then
  begin
    TextOut:=TextOut+v;
    inc(p);
  end;
end;


function FormatText(const V:Variant; Format: string; var Color: integer):string;
var
  SectionCount: integer;
  ts: integer;
  SupressNegativeSign: Boolean;
  Sections: WideStringArray;
  p: integer;
  p1: integer;
  FormatLength: integer;
  NewColor: integer;
begin
  FormatLength := Length(Format);

   //Numbers/dates and text formats can't be on the same format string. It is a number XOR a date XOR a text
  Sections := GetSections(Format, 0, ts, SectionCount, SupressNegativeSign);
  if SectionCount < 4 then
  begin
    Format := Sections[0];
    if (Pos('@', Format) <= 0) then  //everything is ignored here.
      begin
        NewColor:=Color;
        CheckColor(Format, NewColor, p);
        if (p > Length(Format)) or (UpperCase(copy(Format, p, length(Format))) = 'GENERAL')
            then Color := NewColor; //Excel only uses the color if the format is empty or has an "@".
        Result := v;
        exit;
      end;
  end
  else
  begin
    Format := Sections[3];
  end;

  CheckColor(Format, Color, p);
  Result:='';
  while p<=FormatLength do
  begin
    p1:=p;
    CheckOptional(V, Format, p, Result);
    CheckLiteral (V, Format, p, Result);
    CheckText    (V, Format, p, Result);
    if p1=p then //not found
    begin
      Result:=V;
      exit;
    end;
  end;
end;


function XlsFormatValueEx(const V: variant; Format: string; const Dates1904: boolean;
var Color: Integer; out HasDate, HasTime: boolean; const FormatSettings: PFormatSettings): string;
var
  SectionMatches: Boolean;
  SupressNegativeSign: Boolean;
  FormatSection: string;
  FmSet: PFormatSettings;
begin
  if (FormatSettings = nil) then FmSet := GetDefaultLocaleFormatSettings else FmSet := FormatSettings;

  HasDate:=false;
  HasTime:=false;

  if VarIsNull(v) or VarIsClear(v) then begin; Result := ''; exit; end;

  if Format='' then  //General
  begin
    Result:= VarToStr(v);
    exit;
  end;

  //This is slow. We will do it in checkdate.
  //Format:=StringReplaceSkipQuotes(Format,'AM/PM','AMPM'); //Format AMPM is equivalent to AM/PM on delphi

  case VarType(V) of
    varByte,
    varSmallint,
    varInteger,
    varSingle,
    varDouble,
    varInt64,
    varCurrency : begin
                    FormatSection := GetSection(Format, V, SectionMatches, SupressNegativeSign);
                    if not SectionMatches then  //This is Excel2007 way. Older version would show an empty cell.
                    begin Result := '###################'; exit; end;

                    if Pos('[$-F800]', UpperCase(FormatSection)) > 0 then  //This means format with long date from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime1904(FmSet.LongDateFormat, V, Dates1904);
                      HasDate := true;
                      exit;
                    end;
                    if Pos('[$-F400]', UpperCase(FormatSection)) > 0 then  //This means format with long hour from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime1904(FmSet.LongTimeFormat, V, Dates1904);
                      HasTime := true;
                      exit;
                    end;

                    Result := FormatNumber(V, SupressNegativeSign, FormatSection, Dates1904, Color, HasDate, HasTime);
                  end;
    varDate     : begin
                    FormatSection := GetSection(Format, V, SectionMatches, SupressNegativeSign);
                    if not SectionMatches then  //This is Excel2007 way. Older version would show an empty cell.
                    begin Result := '###################'; exit; end;

                    if Pos('[$-F800]', UpperCase(FormatSection)) > 0 then  //This means format with long date from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime1904(FmSet.LongDateFormat, V, Dates1904);
                      HasDate := true;
                      exit;
                    end;
                    if Pos('[$-F400]', UpperCase(FormatSection)) > 0 then  //This means format with long hour from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime1904(FmSet.LongTimeFormat, V, Dates1904);
                      HasTime := true;
                      exit;
                    end;

                    if V<0 then Result:='###################' else //Negative dates are shown this way
                    Result := FormatNumber(V, SupressNegativeSign, FormatSection, Dates1904, Color, HasDate, HasTime);
                  end;
    varOleStr,
    varStrArg,
    varUString,
    varString   : Result := FormatText(V,Format, Color);
    varBoolean	: if V then Result:=TxtTrue else Result:=TxtFalse;
    else Result:= VarToStr(V);
  end; //case
end;


function XlsFormatValue1904(const V: variant; const Format: string; const Dates1904: boolean; var Color: Integer; FormatSettings: PFormatSettings = nil): string;
var
  HasDate, HasTime: boolean;
begin
  Result := XlsFormatValueEx(V, Format, Dates1904, Color, HasDate, HasTime, FormatSettings);
end;

function XlsFormat(const V: variant; const Format: string): string;
var
  clr: integer;
begin
  Result := XlsFormatValue1904(V, Format, false, clr, nil);
end;

end.
