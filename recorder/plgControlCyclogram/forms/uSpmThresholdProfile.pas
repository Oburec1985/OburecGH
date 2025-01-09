unit uSpmThresholdProfile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uProfile, StdCtrls, ExtCtrls, Grids,
  uComponentServises, uStringGridExt;

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
    constructor create(aowner:twincontrol);
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

constructor TSpmThresholdProfileFrm.create(aowner: twincontrol);
begin
  inherited;
  init;
end;

procedure TSpmThresholdProfileFrm.init;
begin
  ProfileSG.RowCount:=2;
  ProfileSG.ColCount:=3;
  ProfileSG.Cells[c_Col_N, 0] :=  '№';
  ProfileSG.Cells[c_Col_X, 0] :=  'X';
  ProfileSG.Cells[c_Col_P, 0] :=  'Задание';
  SGChange(ProfileSG);
end;


end.
