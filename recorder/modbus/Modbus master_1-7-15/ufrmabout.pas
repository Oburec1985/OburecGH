unit uFrmAbout;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, libbinres;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    lAbout: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
  private

  public
    procedure UpdateVersion;
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  UpdateVersion;
end;

procedure TfrmAbout.UpdateVersion;
var
 inf: TAppVersionInfo;
begin
  inf := TAppVersionInfo.Create;
  inf.Reload;
  lAbout.Caption := format(lAbout.Caption, [inf.VersionStr]);
  inf.Free;
end;

end.

