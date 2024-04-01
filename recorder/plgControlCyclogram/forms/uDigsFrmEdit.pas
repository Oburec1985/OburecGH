unit uDigsFrmEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uTagsListFrame, ExtCtrls, StdCtrls, Spin, DCL_MYOWN, Grids,
  uDigsFrm;

type
  TDigsFrmEdit = class(TForm)
    RightPan: TPanel;
    TagsListFrame1: TTagsListFrame;
    Panel2: TPanel;
    AutoGroupCB: TCheckBox;
    GroupNameE: TEdit;
    GroupCountIE: TIntEdit;
    GroupCountLabel: TLabel;
    AddGroupBtn: TButton;
    GroupNameLabel: TLabel;
    ColumnGB: TGroupBox;
    TagSubstrL: TLabel;
    TagSubstrE: TEdit;
    CheckBox2: TCheckBox;
    EstTypeL: TLabel;
    EstCB: TComboBox;
    UpdateTagsBtn: TButton;
    ColNameL: TLabel;
    ColNameE: TEdit;
    SignalsSG: TStringGrid;
    ColNumLabel: TLabel;
    ColumnSE: TSpinEdit;
    ColCountLabel: TLabel;
    ColCountE: TIntEdit;
    FirstL: TLabel;
    FirstIE: TIntEdit;
    OkBtn: TButton;
    procedure OkBtnClick(Sender: TObject);
  protected
    curFrm:TDigsFrm;
  private
    procedure ShowTags;
  public
    procedure Edit(f:TDigsFrm);
  end;

var
  DigsFrmEdit: TDigsFrmEdit;

implementation

{$R *.dfm}

{ TDigsFrmEdit }
procedure TDigsFrmEdit.Edit(f: TDigsFrm);
begin
  curFrm:=f;
  ShowTags;
  Show;
end;

procedure TDigsFrmEdit.OkBtnClick(Sender: TObject);
begin
  curFrm.colCount:=ColCountE.IntNum;
  SignalsSG.ColCount:=ColCountE.IntNum;
end;

procedure TDigsFrmEdit.ShowTags;
begin
  TagsListFrame1.ShowChannels;
end;

end.
