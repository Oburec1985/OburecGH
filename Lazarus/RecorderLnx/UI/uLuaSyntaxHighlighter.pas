unit uLuaSyntaxHighlighter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, SynEditTypes, SynEditHighlighter;

type
  TLuaTokenKind = (ltkNull, ltkSpace, ltkComment, ltkKeyword, ltkString,
    ltkNumber, ltkFunction, ltkTag, ltkIdentifier, ltkSymbol);
  TLuaRangeState = (lrsNormal, lrsBlockComment);

  TLuaSyntaxHighlighter = class(TSynCustomHighlighter)
  private
    fLineText: string;
    fTokenPos: Integer;
    fTokenEnd: Integer;
    fTokenKind: TLuaTokenKind;
    fRange: TLuaRangeState;
    fCommentAttr: TSynHighlighterAttributes;
    fKeywordAttr: TSynHighlighterAttributes;
    fStringAttr: TSynHighlighterAttributes;
    fNumberAttr: TSynHighlighterAttributes;
    fFunctionAttr: TSynHighlighterAttributes;
    fTagAttr: TSynHighlighterAttributes;
    fIdentifierAttr: TSynHighlighterAttributes;
    fSymbolAttr: TSynHighlighterAttributes;
    fSpaceAttr: TSynHighlighterAttributes;
    function IsIdentifierChar(AChar: Char): Boolean;
    function IsLuaKeyword(const AText: string): Boolean;
    procedure ScanBlockComment;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetLine(const NewValue: string; LineNumber: Integer); override;
    procedure Next; override;
    function GetEol: Boolean; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: Integer); override;
    function GetToken: string; override;
    function GetTokenPos: Integer; override;
    function GetTokenKind: Integer; override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes; override;
    function GetRange: Pointer; override;
    procedure SetRange(Value: Pointer); override;
    procedure ResetRange; override;
  end;

implementation

constructor TLuaSyntaxHighlighter.Create(AOwner: TComponent);

  function NewAttribute(const AName: string; AColor: TColor;
    AStyle: TFontStyles = []): TSynHighlighterAttributes;
  begin
    Result := TSynHighlighterAttributes.Create(AName, AName);
    Result.Foreground := AColor;
    Result.Style := AStyle;
    AddAttribute(Result);
  end;

begin
  inherited Create(AOwner);
  fCommentAttr := NewAttribute('Comment', clGreen, [fsItalic]);
  fKeywordAttr := NewAttribute('Keyword', clNavy, [fsBold]);
  fStringAttr := NewAttribute('String', clMaroon);
  fNumberAttr := NewAttribute('Number', clBlue);
  fFunctionAttr := NewAttribute('Function', clFuchsia, [fsBold]);
  fTagAttr := NewAttribute('RecorderTag', clPurple, [fsBold]);
  fIdentifierAttr := NewAttribute('Identifier', clTeal);
  fSymbolAttr := NewAttribute('Symbol', clBlack);
  fSpaceAttr := NewAttribute('Space', clBlack);
  SetAttributesOnChange(@DefHighlightChange);
end;

function TLuaSyntaxHighlighter.IsIdentifierChar(AChar: Char): Boolean;
begin
  Result := (AChar in ['A'..'Z', 'a'..'z', '0'..'9', '_']) or
    (Ord(AChar) >= 128);
end;

function TLuaSyntaxHighlighter.IsLuaKeyword(const AText: string): Boolean;
const
  Keywords = '|and|break|do|else|elseif|end|false|for|function|goto|if|in|local|nil|not|or|repeat|return|then|true|until|while|';
begin
  Result := Pos('|' + LowerCase(AText) + '|', Keywords) > 0;
end;

procedure TLuaSyntaxHighlighter.ScanBlockComment;
var
  lLength: Integer;
begin
  lLength := Length(fLineText);
  while fTokenEnd <= lLength do
  begin
    if (fLineText[fTokenEnd] = ']') and (fTokenEnd < lLength) and
      (fLineText[fTokenEnd + 1] = ']') then
    begin
      Inc(fTokenEnd, 2);
      fRange := lrsNormal;
      Exit;
    end;
    Inc(fTokenEnd);
  end;
end;

procedure TLuaSyntaxHighlighter.SetLine(const NewValue: string;
  LineNumber: Integer);
begin
  inherited;
  fLineText := NewValue;
  fTokenEnd := 1;
  Next;
end;

procedure TLuaSyntaxHighlighter.Next;
var
  lLength, lLookAhead: Integer;
  lQuote: Char;
  lWord: string;
begin
  fTokenPos := fTokenEnd;
  lLength := Length(fLineText);
  if fTokenPos > lLength then
  begin
    fTokenKind := ltkNull;
    Exit;
  end;

  if fRange = lrsBlockComment then
  begin
    fTokenKind := ltkComment;
    ScanBlockComment;
    Exit;
  end;

  if fLineText[fTokenEnd] in [#1..#32] then
  begin
    fTokenKind := ltkSpace;
    while (fTokenEnd <= lLength) and
      (fLineText[fTokenEnd] in [#1..#32]) do Inc(fTokenEnd);
    Exit;
  end;

  if (fLineText[fTokenEnd] = '-') and (fTokenEnd < lLength) and
    (fLineText[fTokenEnd + 1] = '-') then
  begin
    fTokenKind := ltkComment;
    Inc(fTokenEnd, 2);
    if (fTokenEnd + 1 <= lLength) and (fLineText[fTokenEnd] = '[') and
      (fLineText[fTokenEnd + 1] = '[') then
    begin
      Inc(fTokenEnd, 2);
      fRange := lrsBlockComment;
      ScanBlockComment;
    end
    else
      fTokenEnd := lLength + 1;
    Exit;
  end;

  if fLineText[fTokenEnd] in ['''', '"'] then
  begin
    fTokenKind := ltkString;
    lQuote := fLineText[fTokenEnd];
    Inc(fTokenEnd);
    while fTokenEnd <= lLength do
    begin
      if fLineText[fTokenEnd] = '\' then
        Inc(fTokenEnd, 2)
      else if fLineText[fTokenEnd] = lQuote then
      begin
        Inc(fTokenEnd);
        Break;
      end
      else
        Inc(fTokenEnd);
    end;
    Exit;
  end;

  if fLineText[fTokenEnd] = '{' then
  begin
    fTokenKind := ltkTag;
    Inc(fTokenEnd);
    while (fTokenEnd <= lLength) and (fLineText[fTokenEnd] <> '}') do
      Inc(fTokenEnd);
    if fTokenEnd <= lLength then Inc(fTokenEnd);
    Exit;
  end;

  if fLineText[fTokenEnd] in ['0'..'9'] then
  begin
    fTokenKind := ltkNumber;
    while (fTokenEnd <= lLength) and
      (fLineText[fTokenEnd] in ['0'..'9', 'a'..'f', 'A'..'F', 'x', 'X',
       '.', '+', '-']) do Inc(fTokenEnd);
    Exit;
  end;

  if IsIdentifierChar(fLineText[fTokenEnd]) and
    not (fLineText[fTokenEnd] in ['0'..'9']) then
  begin
    while (fTokenEnd <= lLength) and IsIdentifierChar(fLineText[fTokenEnd]) do
      Inc(fTokenEnd);
    lWord := Copy(fLineText, fTokenPos, fTokenEnd - fTokenPos);
    if IsLuaKeyword(lWord) then
      fTokenKind := ltkKeyword
    else
    begin
      lLookAhead := fTokenEnd;
      while (lLookAhead <= lLength) and
        (fLineText[lLookAhead] in [' ', #9]) do Inc(lLookAhead);
      if (lLookAhead <= lLength) and (fLineText[lLookAhead] = '(') then
        fTokenKind := ltkFunction
      else
        fTokenKind := ltkIdentifier;
    end;
    Exit;
  end;

  fTokenKind := ltkSymbol;
  Inc(fTokenEnd);
end;

function TLuaSyntaxHighlighter.GetEol: Boolean;
begin
  Result := fTokenPos > Length(fLineText);
end;

procedure TLuaSyntaxHighlighter.GetTokenEx(out TokenStart: PChar;
  out TokenLength: Integer);
begin
  TokenStart := @fLineText[fTokenPos];
  TokenLength := fTokenEnd - fTokenPos;
end;

function TLuaSyntaxHighlighter.GetToken: string;
begin
  Result := Copy(fLineText, fTokenPos, fTokenEnd - fTokenPos);
end;

function TLuaSyntaxHighlighter.GetTokenPos: Integer;
begin
  Result := fTokenPos - 1;
end;

function TLuaSyntaxHighlighter.GetTokenKind: Integer;
begin
  Result := Ord(fTokenKind);
end;

function TLuaSyntaxHighlighter.GetTokenAttribute: TSynHighlighterAttributes;
begin
  case fTokenKind of
    ltkSpace: Result := fSpaceAttr;
    ltkComment: Result := fCommentAttr;
    ltkKeyword: Result := fKeywordAttr;
    ltkString: Result := fStringAttr;
    ltkNumber: Result := fNumberAttr;
    ltkFunction: Result := fFunctionAttr;
    ltkTag: Result := fTagAttr;
    ltkIdentifier: Result := fIdentifierAttr;
    ltkSymbol: Result := fSymbolAttr;
    else Result := nil;
  end;
end;

function TLuaSyntaxHighlighter.GetDefaultAttribute(
  Index: Integer): TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT: Result := fCommentAttr;
    SYN_ATTR_IDENTIFIER: Result := fIdentifierAttr;
    SYN_ATTR_KEYWORD: Result := fKeywordAttr;
    SYN_ATTR_STRING: Result := fStringAttr;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttr;
    else Result := nil;
  end;
end;

function TLuaSyntaxHighlighter.GetRange: Pointer;
begin
  Result := Pointer(PtrUInt(Ord(fRange)));
end;

procedure TLuaSyntaxHighlighter.SetRange(Value: Pointer);
begin
  fRange := TLuaRangeState(PtrUInt(Value));
end;

procedure TLuaSyntaxHighlighter.ResetRange;
begin
  fRange := lrsNormal;
end;

end.
