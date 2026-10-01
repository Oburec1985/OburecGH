unit uRecorderSplashForm;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls;

type
  { Информационное окно показывается после Application.Initialize и остаётся
    видимым во время создания главной формы RecorderLnx. }
  TRecorderSplashForm = class(TForm)
    lbApplication: TLabel;
    lbArticle: TLabel;
    lbVersion: TLabel;
    procedure FormPaint(Sender: TObject);
  public
    procedure LoadApplicationInfo;
    procedure StartupReady(Sender: TObject);
  end;

implementation

{$R *.lfm}

uses
  uRecorderAppVersion;

function BlendChannel(AStartValue, AEndValue, APosition,
  ARange: Integer): Byte;
begin
  if ARange <= 0 then
    Exit(Byte(AStartValue));
  Result := Byte(AStartValue +
    (AEndValue - AStartValue) * APosition div ARange);
end;

procedure TRecorderSplashForm.LoadApplicationInfo;
begin
  lbApplication.Caption := 'RecorderLnx';
  lbVersion.Caption := 'Версия ' + CRecorderLnxVersion;
  lbArticle.Caption := RecorderSoftwareArticle;
end;

procedure TRecorderSplashForm.StartupReady(Sender: TObject);
begin
  Hide;
end;

procedure TRecorderSplashForm.FormPaint(Sender: TObject);
const
  CTopColor: TColor = $00E6F5E7;
  CBottomColor: TColor = $00F8F1DF;
var
  I: Integer;
  lBottomRgb: LongInt;
  lColor: TColor;
  lTopRgb: LongInt;
begin
  lTopRgb := ColorToRGB(CTopColor);
  lBottomRgb := ColorToRGB(CBottomColor);
  for I := 0 to ClientHeight - 1 do
  begin
    lColor := RGBToColor(
      BlendChannel(lTopRgb and $FF, lBottomRgb and $FF,
        I, ClientHeight - 1),
      BlendChannel((lTopRgb shr 8) and $FF, (lBottomRgb shr 8) and $FF,
        I, ClientHeight - 1),
      BlendChannel((lTopRgb shr 16) and $FF, (lBottomRgb shr 16) and $FF,
        I, ClientHeight - 1));
    Canvas.Pen.Color := lColor;
    Canvas.Line(0, I, ClientWidth, I);
  end;
end;

end.
