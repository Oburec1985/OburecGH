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
    ColOkBtn: TButton;
    procedure OkBtnClick(Sender: TObject);
    procedure ColOkBtnClick(Sender: TObject);
    procedure AddGroupBtnClick(Sender: TObject);
    procedure ColumnSEChange(Sender: TObject);
  protected
    curFrm:TDigsFrm;
    curGr:TGroup;
  private
    procedure ShowTags;
    procedure UpdateHeader;
    procedure ShowGroups;
  public
    procedure Edit(f:TDigsFrm);
  end;

var
  DigsFrmEdit: TDigsFrmEdit;

implementation

{$R *.dfm}

{ TDigsFrmEdit }
procedure TDigsFrmEdit.AddGroupBtnClick(Sender: TObject);
var
  I, num: Integer;
  g:TGroup;
  s:string;
begin
  for I := 0 to GroupCountIE.IntNum - 1 do
  begin
    num:=i+FirstIE.IntNum;
    if num<10 then
      s:=GroupNameE.Text+'_00'+IntToStr(num)
    else
    begin
      if num<100 then
      begin
        s:=GroupNameE.Text+'_0'+IntToStr(num)
      end
      else
      begin
        s:=GroupNameE.Text+'_'+IntToStr(num);
      end;
    end;
    g:=tgroup(curFrm.glist.Add(s));
  end;
  ShowGroups;
end;

procedure TDigsFrmEdit.ColOkBtnClick(Sender: TObject);
var
  col:TDigColumn;
begin
  if ColumnSE.Value<curFrm.colNames.Count then
  begin
    col:=TDigColumn(curFrm.colNames.Get(ColumnSE.Value));
    col.name:=ColNameE.Text;
    col.estimate:=EstCB.ItemIndex;
    SignalsSG.Cells[ColumnSE.Value+1,0]:=ColNameE.Text;
  end;
end;

procedure TDigsFrmEdit.ColumnSEChange(Sender: TObject);
var
  col:TDigColumn;
begin
  if ColumnSE.Value<0 then exit;
  if ColumnSE.Value<curFrm.colNames.Count then
  begin
    col:=TDigColumn(curFrm.colNames.Get(ColumnSE.Value));
    ColNameE.Text:=col.name;
  end;
end;

procedure TDigsFrmEdit.Edit(f: TDigsFrm);
begin
  curFrm:=f;
  ShowTags;
  ShowModal;
end;

procedure TDigsFrmEdit.OkBtnClick(Sender: TObject);
begin
  curFrm.colCount:=ColCountE.IntNum;
  SignalsSG.ColCount:=ColCountE.IntNum+1;
end;

procedure TDigsFrmEdit.ShowGroups;
var
  I: Integer;
  g:tgroup;
begin
  SignalsSG.RowCount:=curFrm.glist.Count+1;
  for I := 0 to curFrm.glist.Count - 1 do
  begin
    g:=tgroup(curFrm.glist.Get(i));
    SignalsSG.Cells[0,i+1]:=g.name;
  end;
end;

procedure TDigsFrmEdit.ShowTags;
begin
  TagsListFrame1.ShowChannels;
end;

procedure TDigsFrmEdit.UpdateHeader;
var
  I: Integer;
  col:TDigColumn;
begin
  for I := 0 to curFrm.colCount - 1 do
  begin
    col:=TDigColumn(curFrm.colNames.Get(i));
    SignalsSG.Cells[i,0]:=col.name;
  end;
end;

end.
