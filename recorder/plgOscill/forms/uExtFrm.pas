unit uExtFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, inifiles, StdCtrls, recorder, uRecBasicFactory, uCommonMath;

type
  TExtFrm = class(TRecFrm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  public
  private
    { Private declarations }
  public
    procedure SaveSettings(a_pIni:TIniFile; str:LPCSTR);
  	procedure LoadSettings(a_pIni:TIniFile; str:LPCSTR);
  end;

var
  ExtFrm: TExtFrm;

implementation

{$R *.dfm}

procedure TExtFrm.SaveSettings(a_pIni:TIniFile; str:LPCSTR);
begin

end;

procedure TExtFrm.FormCreate(Sender: TObject);
var
  FormRgn: hRgn;
begin
  Brush.Style := bsSolid; //bsclear;
  GetWindowRgn(Handle, FormRgn);
  DeleteObject(FormRgn);
  FormRgn := CreateRoundRectRgn(0, 0, Width, height, width, height);
  // для дочерних окон
  setwindowlong(Handle, GWL_STYLE, WS_CLIPSIBLINGS + WS_CLIPCHILDREN);
  SetWindowRgn(Handle, FormRgn, TRUE);
end;

procedure TExtFrm.FormPaint(Sender: TObject);
var
  i:integer;
begin
  {if isDigit(Button1.Caption) then
  begin
    i:=strtoint(Button1.Caption);
  end
  else
  begin
    i:=0;
  end;
  inc(i);
  Button1.Caption:=inttostr(i);}
end;

procedure TExtFrm.LoadSettings(a_pIni:TIniFile; str:LPCSTR);
begin

end;

end.
