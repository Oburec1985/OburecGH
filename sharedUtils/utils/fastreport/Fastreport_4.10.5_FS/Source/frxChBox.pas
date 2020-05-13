
{******************************************}
{                                          }
{             FastReport v4.0              }
{         Checkbox Add-In Object           }
{                                          }
{         Copyright (c) 1998-2008          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxChBox;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Menus, frxClass
{$IFDEF FR_COM}
, FastReport_TLB
{$ENDIF}
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxCheckStyle = (csCross, csCheck, csLineCross, csPlus);
  TfrxUncheckStyle = (usEmpty, usCross, usLineCross, usMinus);

  TfrxCheckBoxObject = class(TComponent)  // fake component
  end;

{$IFDEF FR_COM}
  TfrxCheckBoxView = class(TfrxView, IfrxCheckBoxView)
{$ELSE}  
  TfrxCheckBoxView = class(TfrxView)
{$ENDIF}
  private
    FCheckColor: TColor;
    FChecked: Boolean;
    FCheckStyle: TfrxCheckStyle;
    FUncheckStyle: TfrxUncheckStyle;
    FExpression: String;
    procedure DrawCheck(ARect: TRect);
{$IFDEF FR_COM}
    function Get_Checked(out Value: WordBool): HResult; stdcall;
    function Set_Checked(Value: WordBool): HResult; stdcall;
    function Set_CheckStyle(Value: frxCheckStyle): HResult; stdcall;
    function Set_UncheckStyle(Value: frxUnCheckStyle): HResult; stdcall;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure GetData; override;
    class function GetDescription: String; override;
  published
    property BrushStyle;
    property CheckColor: TColor read FCheckColor write FCheckColor;
    property Checked: Boolean read FChecked write FChecked default True;
    property CheckStyle: TfrxCheckStyle read FCheckStyle write FCheckStyle;
    property Color;
    property Cursor;
    property DataField;
    property DataSet;
    property DataSetName;
    property Expression: String read FExpression write FExpression;
    property Frame;
    property TagStr;
    property UncheckStyle: TfrxUncheckStyle read FUncheckStyle write FUncheckStyle default usEmpty;
    property URL;
  end;


implementation

uses frxChBoxRTTI, frxDsgnIntf, frxRes;


constructor TfrxCheckBoxView.Create(AOwner: TComponent);
begin
  inherited;
  FChecked := True;
  Height := fr01cm * 5;
  Width := fr01cm * 5;
end;

class function TfrxCheckBoxView.GetDescription: String;
begin
  Result := frxResources.Get('obChBox');
end;

procedure TfrxCheckBoxView.DrawCheck(ARect: TRect);
var
{$IFDEF Delphi12}
  Sz: TSize;
  s: AnsiString;
{$ELSE}
  s: String;
{$ENDIF}
begin
  with FCanvas, ARect do
    if FChecked then
    begin
      if FCheckStyle in [csCross, csCheck] then
      begin
        Font.Name := 'Wingdings';
        Font.Color := FCheckColor;
        Font.Style := [];
        Font.Height := - (Bottom - Top);
        Font.CharSet :=  SYMBOL_CHARSET;
        if FCheckStyle = csCross then
          s := #251 else
          s := #252;
        SetBkMode(Handle, Transparent);
{$IFDEF Delphi12}
        GetTextExtentPoint32A(Handle, PAnsiChar(s), Length(s), Sz);
        ExtTextOutA(Handle, Left + (Right - Left - Sz.cx) div 2,
          Top, ETO_CLIPPED, @ARect, PAnsiChar(s), 1, nil);
{$ELSE}
        ExtTextOut(Handle, Left + (Right - Left - TextWidth(s)) div 2,
          Top, ETO_CLIPPED, @ARect, PChar(s), 1, nil);
{$ENDIF}
      end
      else if FCheckStyle = csLineCross then
      begin
        Pen.Style := psSolid;
        Pen.Color := FCheckColor;
        DrawLine(Left, Top, Right, Bottom, FFrameWidth);
        DrawLine(Left, Bottom, Right, Top, FFrameWidth);
      end
      else if FCheckStyle = csPlus then
      begin
        Pen.Style := psSolid;
        Pen.Color := FCheckColor;
        DrawLine(Left + 3, Top + (Bottom - Top) div 2, Right - 2, Top + (Bottom - Top) div 2, FFrameWidth);
        DrawLine(Left + (Right - Left) div 2, Top + 3, Left + (Right - Left) div 2, Bottom - 2, FFrameWidth);
      end
    end
    else
    begin
      if FUncheckStyle = usCross then
      begin
        Font.Name := 'Wingdings';
        Font.Color := FCheckColor;
        Font.Style := [];
        Font.Height := - (Bottom - Top);
        Font.CharSet := SYMBOL_CHARSET;
        s := #251;
        SetBkMode(Handle, Transparent);
{$IFDEF Delphi12}
        GetTextExtentPoint32A(Handle, PAnsiChar(s), Length(s), Sz);
        ExtTextOutA(Handle, Left + (Right - Left - Sz.cx) div 2,
          Top, ETO_CLIPPED, @ARect, PAnsiChar(s), 1, nil);
{$ELSE}
        ExtTextOut(Handle, Left + (Right - Left - TextWidth(s)) div 2,
          Top, ETO_CLIPPED, @ARect, PChar(s), 1, nil);
{$ENDIF}
      end
      else if FUncheckStyle = usLineCross then
      begin
        Pen.Style := psSolid;
        Pen.Color := FCheckColor;
        DrawLine(Left, Top, Right, Bottom, FFrameWidth);
        DrawLine(Left, Bottom, Right, Top, FFrameWidth);
      end
      else if FUncheckStyle = usMinus then
      begin
        Pen.Style := psSolid;
        Pen.Color := FCheckColor;
        DrawLine(Left + 3, Top + (Bottom - Top) div 2, Right - 2, Top + (Bottom - Top) div 2, FFrameWidth);
      end
    end;
end;

procedure TfrxCheckBoxView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);

  DrawBackground;
  DrawCheck(Rect(FX, FY, FX1, FY1));
  DrawFrame;
end;

procedure TfrxCheckBoxView.GetData;
var
  v: Variant;
begin
  inherited;
  if IsDataField then
  begin
    v := DataSet.Value[DataField];
    if v = Null then
      v := False;
    FChecked := v;
  end
  else if FExpression <> '' then
    FChecked := Report.Calc(FExpression);
end;

{$IFDEF FR_COM}
function TfrxCheckBoxView.Get_Checked(out Value: WordBool): HResult; stdcall;
begin
  Value := Checked;
  Result := S_OK;
end;

function TfrxCheckBoxView.Set_Checked(Value: WordBool): HResult; stdcall;
begin
  Checked := Value;
  Result := S_OK;
end;

function TfrxCheckBoxView.Set_CheckStyle(Value: frxCheckStyle): HResult; stdcall;
begin
  FCheckStyle := TfrxCheckStyle(Value);
  Result := S_OK;
end;

function TfrxCheckBoxView.Set_UncheckStyle(Value: frxUnCheckStyle): HResult; stdcall;
begin
  FUncheckStyle := TfrxUnCheckStyle(Value);
  Result := S_OK;
end;
{$ENDIF}

initialization
  frxObjects.RegisterObject1(TfrxCheckBoxView, nil, '', '', 0, 24);

finalization
  frxObjects.UnRegister(TfrxCheckBoxView);


end.


