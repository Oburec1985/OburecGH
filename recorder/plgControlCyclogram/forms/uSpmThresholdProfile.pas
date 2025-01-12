unit uSpmThresholdProfile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uProfile, StdCtrls, ExtCtrls, Grids,
  uComponentServises, uStringGridExt, uCommonTypes;

type
  cBmp = class
    bmp:tbitmap;
    t: TPType;
  public
    constructor create;
    destructor destroy;
  end;

  TSpmThresholdProfileFrm = class(TForm)
    PanBottom: TPanel;
    PanAlClient: TPanel;
    GBleft: TGroupBox;
    ProfileSG: TStringGridExt;
    UnitsLabel: TLabel;
    UnitsCB: TComboBox;
    ProfileNameLabel: TLabel;
    ProfileNameEdit: TEdit;
    procedure ProfileSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  public
    // список кнопок с интерполяцией
    SGbuttons:tlist;
    m_r:integer;
    m_c:integer;
  private
    procedure init;
    procedure ClearSGButtons;
    procedure createSGBtn;
  public
    constructor create(AOwner: TComponent); override;
    procedure edit(p:cProfile);
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


procedure TSpmThresholdProfileFrm.ClearSGButtons;
var
  btn: cbmp;
  i: integer;
begin
  for i := 0 to SGbuttons.Count - 1 do
  begin
    btn := cbmp(SGbuttons.Items[i]);
    btn.destroy;
  end;
  SGbuttons.clear;
end;


procedure TSpmThresholdProfileFrm.createSGBtn;
var
  btn: cbmp;
  row, i: integer;
begin
  if curvesg.RowCount < SGbuttons.Count then
  begin
    while curvesg.RowCount <> SGbuttons.Count do
    begin
      i := SGbuttons.Count - 1;
      btn := cbmp(SGbuttons.Items[i]);
      btn.destroy;
      SGbuttons.Delete(i);
    end;
  end;
  while SGbuttons.Count < curvesg.RowCount - 1 do
  begin
    row := SGbuttons.Count + 1;
    btn := cbmp.Create();
    curvesg.Objects[2, row] := btn;
    SGbuttons.Add(btn);
  end;
end;

constructor TSpmThresholdProfileFrm.create(AOwner: TComponent);
begin
  inherited;
  SGbuttons:=TList.Create;
  init;
end;

procedure TSpmThresholdProfileFrm.edit(p: cProfile);
var
  I: Integer;
  tp:TProfPoint;
begin
  profilesg.RowCount:=p.size+1;
  for I := 0 to p.size - 1 do
  begin
    tp:=p.m_data[i];
    profilesg.Cells[c_Col_N,i+1]:=inttostr(i+1);
    profilesg.Cells[c_Col_X,i+1]:=floattostr(tp.p.x);
    profilesg.Cells[c_Col_P,i+1]:=floattostr(tp.p.y);
  end;
  showmodal;
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


procedure TSpmThresholdProfileFrm.ProfileSGSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  m_r:=ARow;
  m_c:=ACol;
end;

end.
