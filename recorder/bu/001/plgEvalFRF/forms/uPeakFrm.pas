unit uPeakFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, uStringGridExt;

type
  TPeakFrm = class(TForm)
    ProfileSG: TStringGridExt;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PeakFrm: TPeakFrm;

implementation

{$R *.dfm}

end.
