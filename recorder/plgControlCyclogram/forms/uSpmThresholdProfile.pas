unit uSpmThresholdProfile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uProfile, StdCtrls, ExtCtrls, Grids, uStringGridExt;

type
  TSpmThresholdProfileFrm = class(TForm)
    PanBottom: TPanel;
    PanAlClient: TPanel;
    GBleft: TGroupBox;
    ProfileSG: TStringGridExt;
    UnitsLabel: TLabel;
    UnitsCB: TComboBox;
    ProfileNameLabel: TLabel;
    ProfileNameEdit: TEdit;
  private
    procedure init;
  public
    { Public declarations }
  end;

var
  SpmThresholdProfileFrm: TSpmThresholdProfileFrm;

const
  c_headerSize = 1;
  c_Col_N = 0;
  c_Col_X = 1;
  c_Col_P = 2;

implementation

{$R *.dfm}

procedure TSpmThresholdProfileFrm.init;
begin
  ProfilePointsSG.RowCount:=2;
  ProfilePointsSG.ColCount:=7;
  ProfilePointsSG.Cells[c_Col_N, 0] :=  '№';
  ProfilePointsSG.Cells[c_Col_X, 0] :=  'X';
  ProfilePointsSG.Cells[c_Col_P, 0] :=  'Задание';
  SGChange(ProfileSG);
end;


end.
