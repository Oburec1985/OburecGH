
{******************************************}
{                                          }
{             FastReport v4.0              }
{          Barcode Add-in object           }
{                                          }
{         Copyright (c) 1998-2008          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxBarcode;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, frxBarcod, frxClass, ExtCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF FR_COM}
, FastReport_TLB
{$ENDIF};
  

type
  TfrxBarCodeObject = class(TComponent);  // fake component

{$IFDEF FR_COM}
  TfrxBarCodeView = class(TfrxView, IfrxBarCodeView)
{$ELSE}
  TfrxBarCodeView = class(TfrxView)
{$ENDIF}
  private
    FBarCode: TfrxBarCode;
    FBarType: TfrxBarcodeType;
    FCalcCheckSum: Boolean;
    FExpression: String;
    FHAlign: TfrxHAlign;
    FRotation: Integer;
    FShowText: Boolean;
    FText: String;
    FWideBarRatio: Extended;
    FZoom: Extended;
    procedure BcFontChanged(Sender: TObject);
 {$IFDEF FR_COM}
  protected
    function Get_BarType(out Value: frxBarcodeType): HResult; stdcall;
    function Set_BarType(Value: frxBarcodeType): HResult; stdcall;
    function Get_CalcCheckSum(out Value: WordBool): HResult; stdcall;
    function Set_CalcCheckSum(Value: WordBool): HResult; stdcall;
    function Get_Expression(out Value: WideString): HResult; stdcall;
    function Set_Expression(const Value: WideString): HResult; stdcall;
    function Get_Rotation(out Value: Integer): HResult; stdcall;
    function Set_Rotation(Value: Integer): HResult; stdcall;
    function Get_ShowText(out Value: WordBool): HResult; stdcall;
    function Set_ShowText(Value: WordBool): HResult; stdcall;
    function Get_Text(out Value: WideString): HResult; stdcall;
    function Set_Text(const Value: WideString): HResult; stdcall;
    function Get_WideBarRatio(out Value: Double): HResult; stdcall;
    function Set_WideBarRatio(Value: Double): HResult; stdcall;
    function Get_Zoom(out Value: Double): HResult; stdcall;
    function Set_Zoom(Value: Double): HResult; stdcall;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure GetData; override;
    class function GetDescription: String; override;
    function GetRealBounds: TfrxRect; override;
    property BarCode: TfrxBarCode read FBarCode;
  published
    property BarType: TfrxBarcodeType read FBarType write FBarType;
    property BrushStyle;
    property CalcCheckSum: Boolean read FCalcCheckSum write FCalcCheckSum default False;
    property Color;
    property Cursor;
    property DataField;
    property DataSet;
    property DataSetName;
    property Expression: String read FExpression write FExpression;
    property Frame;
    property HAlign: TfrxHAlign read FHAlign write FHAlign default haLeft;
    property Rotation: Integer read FRotation write FRotation;
    property ShowText: Boolean read FShowText write FShowText default True;
    property TagStr;
    property Text: String read FText write FText;
    property URL;
    property WideBarRatio: Extended read FWideBarRatio write FWideBarRatio;
    property Zoom: Extended read FZoom write FZoom;
    property Font;
  end;


implementation

uses
{$IFNDEF NO_EDITORS}
  frxBarcodeEditor, 
{$ENDIF}
  frxBarcodeRTTI, frxDsgnIntf, frxRes, frxUtils;

const
  cbDefaultText = '12345678';


{ TfrxBarCodeView }

constructor TfrxBarCodeView.Create(AOwner: TComponent);
begin
  inherited;
  FBarCode := TfrxBarCode.Create(nil);
  FBarType := bcCode39;
  FShowText := True;
  FZoom := 1;
  FText := cbDefaultText;
  FWideBarRatio := 2;
  Font.Name := 'Arial';
  Font.Size := 9;
  Font.OnChange := BcFontChanged;
end;

destructor TfrxBarCodeView.Destroy;
begin
  FBarCode.Free;
  inherited Destroy;
end;

class function TfrxBarCodeView.GetDescription: String;
begin
  Result := frxResources.Get('obBarC');
end;

procedure TfrxBarCodeView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
var
  SaveWidth: Extended;
  ErrorText: String;
  DrawRect: TRect;
begin
  FBarCode.Angle := FRotation;
  FBarCode.Font.Assign(Font);
  FBarCode.Checksum := FCalcCheckSum;
  FBarCode.Typ := FBarType;
  FBarCode.Ratio := FWideBarRatio;
  if Color = clNone then
    FBarCode.Color := clWhite else
    FBarCode.Color := Color;

  SaveWidth := Width;

  FBarCode.Text := AnsiString(FText);
  ErrorText := '';
  if FZoom < 0.0001 then
    FZoom := 1;

  try
    if (FRotation = 0) or (FRotation = 180) then
      Width := FBarCode.Width * FZoom
    else
      Height := FBarCode.Width * FZoom;
  except
    on e: Exception do
    begin
      FBarCode.Text := '12345678';
      ErrorText := e.Message;
    end;
  end;

  if FHAlign = haRight then
    Left := Left + SaveWidth - Width
  else if FHAlign = haCenter then
    Left := Left + (SaveWidth - Width) / 2;

  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);

  DrawBackground;
  if ErrorText = '' then
    FBarCode.DrawBarcode(Canvas, Rect(FX, FY, FX1, FY1), FShowText)
  else
    with Canvas do
    begin
      Font.Name := 'Arial';
      Font.Size := Round(8 * ScaleY);
      Font.Color := clRed;
      DrawRect := Rect(FX + 2, FY + 2, FX1, FY1);
      DrawText(Handle, PChar(ErrorText), Length(ErrorText),
        DrawRect, DT_WORDBREAK);
    end;
  DrawFrame;
end;

procedure TfrxBarCodeView.GetData;
begin
  inherited;
  if IsDataField then
    FText := VarToStr(DataSet.Value[DataField])
  else if FExpression <> '' then
    FText := VarToStr(Report.Calc(FExpression));
end;

function TfrxBarCodeView.GetRealBounds: TfrxRect;
var
  extra1, extra2, txtWidth: Integer;
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  Draw(bmp.Canvas, 1, 1, 0, 0);

  Result := inherited GetRealBounds;
  extra1 := 0;
  extra2 := 0;

  if (FRotation = 0) or (FRotation = 180) then
  begin
    with bmp.Canvas do
    begin
      {Font.Name := 'Arial';
      Font.Size := 9;
      Font.Style := []; }
      Font.Assign(Self.Font);
      txtWidth := TextWidth(String(FBarcode.Text));
      if Width < txtWidth then
      begin
        extra1 := Round((txtWidth - Width) / 2) + 2;
        extra2 := extra1;
      end;
    end;
  end;

  if FBarType in [bcCodeEAN13, bcCodeUPC_A] then
    extra1 := 8;
  if FBarType in [bcCodeUPC_A, bcCodeUPC_E0, bcCodeUPC_E1] then
    extra2 := 8;
  case FRotation of
    0:
      begin
        Result.Left := Result.Left - extra1;
        Result.Right := Result.Right + extra2;
      end;
    90:
      begin
        Result.Bottom := Result.Bottom + extra1;
        Result.Top := Result.Top - extra2;
      end;
    180:
      begin
        Result.Left := Result.Left - extra2;
        Result.Right := Result.Right + extra1;
      end;
    270:
      begin
        Result.Bottom := Result.Bottom + extra2;
        Result.Top := Result.Top - extra1;
      end;
  end;

  bmp.Free;
end;

procedure TfrxBarCodeView.BcFontChanged(Sender: TObject);
begin
  if Font.Size > 9 then Font.Size := 9;
end;

{$IFDEF FR_COM}
function TfrxBarCodeView.Get_BarType(out Value: frxBarcodeType): HResult; stdcall;
begin
  Value := frxBarcodeType(BarType);
  Result := S_OK; 
end;

function TfrxBarCodeView.Set_BarType(Value: frxBarcodeType): HResult; stdcall;
begin
  BarType := TfrxBarcodeType(Value);
  Result := S_OK; 
end;

function TfrxBarCodeView.Get_CalcCheckSum(out Value: WordBool): HResult; stdcall;
begin
  Value := CalcCheckSum;
  Result := S_OK; 
end;

function TfrxBarCodeView.Set_CalcCheckSum(Value: WordBool): HResult; stdcall;
begin
  CalcCheckSum := Value;
  Result := S_OK; 
end;

function TfrxBarCodeView.Get_Expression(out Value: WideString): HResult; stdcall;
begin
  Value := Expression;
  Result := S_OK; 
end;

function TfrxBarCodeView.Set_Expression(const Value: WideString): HResult; stdcall;
begin
  Expression := Value;
  Result := S_OK; 
end;

function TfrxBarCodeView.Get_Rotation(out Value: Integer): HResult; stdcall;
begin
  Value := Rotation;
  Result := S_OK; 
end;

function TfrxBarCodeView.Set_Rotation(Value: Integer): HResult; stdcall;
begin
  Rotation := Value;
  Result := S_OK; 
end;

function TfrxBarCodeView.Get_ShowText(out Value: WordBool): HResult; stdcall;
begin
  Value := ShowText;
  Result := S_OK; 
end;

function TfrxBarCodeView.Set_ShowText(Value: WordBool): HResult; stdcall;
begin
  ShowText := Value;
  Result := S_OK; 
end;

function TfrxBarCodeView.Get_Text(out Value: WideString): HResult; stdcall;
begin
  Value := Text;
  Result := S_OK; 
end;

function TfrxBarCodeView.Set_Text(const Value: WideString): HResult; stdcall;
begin
  Text := Value;
  Result := S_OK; 
end;

function TfrxBarCodeView.Get_WideBarRatio(out Value: Double): HResult; stdcall;
begin
  Value := WideBarRatio;
  Result := S_OK; 
end;

function TfrxBarCodeView.Set_WideBarRatio(Value: Double): HResult; stdcall;
begin
  WideBarRatio := Value;
  Result := S_OK; 
end;

function TfrxBarCodeView.Get_Zoom(out Value: Double): HResult; stdcall;
begin
  Value := Zoom;
  Result := S_OK; 
end;

function TfrxBarCodeView.Set_Zoom(Value: Double): HResult; stdcall;
begin
  Zoom := Value;
  Result := S_OK;
end;
{$ENDIF}

initialization
  frxObjects.RegisterObject1(TfrxBarCodeView, nil, '', '', 0, 23);

finalization
  frxObjects.UnRegister(TfrxBarCodeView);



end.


