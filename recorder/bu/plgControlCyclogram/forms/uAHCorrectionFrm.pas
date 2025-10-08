unit uAHCorrectionFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uTagsListFrame, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons, uBaseAlg,
  uRCFunc, uCommontypes, DCL_MYOWN, uCommonMath, uRcCtrls, Grids, tags, uComponentServises,
  uStringGridExt, VirtualTrees, uVTServices, ImgList, activex, ulogfile, mathfunction;

type
  TAHCorrectionFrm = class(TForm)
    Panel1: TPanel;
    TagsListFrame1: TTagsListFrame;
    PropSG: TStringGridExt;
    Panel2: TPanel;
    NameLabel: TLabel;
    UpdateBandBtn: TSpeedButton;
    NameEdit: TComboBox;
    Label1: TLabel;
    UnitsCB: TComboBox;
    ImageList1: TImageList;
    procedure PropSGDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PropSGDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure PropSGKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PropSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure UpdateBandBtnClick(Sender: TObject);
    procedure UpdateImages;
    procedure FormShow(Sender: TObject);
  private
    init:boolean;
    m_val:string;
    m_col:integer;
    m_row:integer;
  private
    function getAH:cahgrad;
    // обновить список градуировок
    procedure initCB;
    procedure PropSGEditCell(r,c:integer; v:string);
    procedure initSG;
  public
    { Public declarations }
  end;

var
  AHCorrectionFrm: TAHCorrectionFrm;

const
  c_col_N = 0;
  c_col_freq = 1;
  c_col_scale = 2;
  c_col_res = 3;

  c_im_place = 0;
  c_im_band = 1;
  c_im_TagPair = 2;

implementation

{$R *.dfm}

procedure TAHCorrectionFrm.FormShow(Sender: TObject);
begin
  UpdateImages;
end;

function TAHCorrectionFrm.getAH: cahgrad;
begin
  result:=nil;
  if NameEdit.ItemIndex<>-1 then
  begin
    result:=cahgrad(NameEdit.Items.Objects[NameEdit.ItemIndex]);
  end;
end;

procedure TAHCorrectionFrm.initCB;
var
  I: Integer;
  a:cahgrad;
begin
  nameedit.Clear;
  for I := 0 to g_algMng.m_AHList.Count - 1 do
  begin
    a:=g_algmng.getAH(i);
    nameedit.AddItem(a.m_name,a);
  end;
  nameedit.ItemIndex:=-1;
  nameedit.Text:='';
end;

procedure TAHCorrectionFrm.initSG;
begin
  PropSG.RowCount := 2;
  PropSG.ColCount := 4;

  PropSG.Cells[c_col_N, 0] := '№';
  PropSG.Cells[c_col_freq, 0] := 'Частота';
  PropSG.Cells[c_Col_scale, 0] := 'Значение';
  PropSG.Cells[c_Col_res, 0] := 'Результат';
end;

procedure TAHCorrectionFrm.PropSGDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  r,c:integer;
  t:itag;
  li:tlistitem;
  str:string;
begin
  propsg.MouseToCell(x,y,c, r);
  str:='';
  if Source is  tlistview then
  begin
    if r>0 then
    begin
      li:=tbtnlistview(Source).selected; //tbtnlistview(source).GetItemAt(x,y);
      t:=itag(li.data);
      str:=t.GetName;
      propsg.Cells[c,r]:=str;
      if propsg.Cells[c_col_freq,r]='' then
      begin
        propsg.Cells[c_col_freq,r]:='1';
      end;
      if r=propsg.RowCount-1 then
      begin
        propsg.RowCount:=propsg.RowCount+1;
      end;
    end;
    SGChange(propsg);
  end;
end;

procedure TAHCorrectionFrm.PropSGDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept:=false;
  if source=TagsListFrame1.tagslv then
  begin
    Accept:=true;
  end;
end;

procedure TAHCorrectionFrm.PropSGEditCell(r, c: integer; v: string);
begin
  case c of
    c_col_freq:;
    c_col_scale:
    begin

    end;
    c_col_res:
    begin

    end;
  end;
end;

procedure TAHCorrectionFrm.PropSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  sg: TStringGridExt;
begin
  sg := TStringGridExt(Sender);
  if key=VK_RETURN then
  begin
    PropSGEditCell(m_row, m_col, m_val);
  end;
  if Key = VK_DELETE then
  begin
    if sg.rowcount = 1 then
      sg.rowcount := 2;
  end;
end;

procedure TAHCorrectionFrm.PropSGSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  m_val:=value;
  m_col:=acol;
  m_row:=arow;
  PropSGEditCell(m_row, m_col, m_val);
end;

procedure TAHCorrectionFrm.UpdateBandBtnClick(Sender: TObject);
var
  i:integer;
  a:cahgrad;
  li:tlistitem;
  str:string;
begin
  if propsg.RowCount<4 then exit;
  a:=getAH;
  if a=nil then
  begin
    a:=g_algMng.newAH(NameEdit.Text);
  end;
  a.size:=propsg.RowCount-2;
  a.m_units:=IntToAHUn(UnitsCB.ItemIndex);
  for I:=1 to propsg.RowCount - 1 do
  begin
    a.m_points[i-1].x:=strtofloatext(propsg.Cells[c_col_freq, i]);
    a.m_points[i-1].y:=strtofloatext(propsg.Cells[c_col_scale, i]);
  end;
  for I := 0 to TagsListFrame1.TagsLV.SelCount - 1 do
  begin
    if i=0 then
    begin
      li:=TagsListFrame1.TagsLV.Selected
    end
    else
    begin
      li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isselected]);
    end;
    str:=itag(li.Data).GetName;
    g_algMng.AddAHName(str, a);
  end;
  UpdateImages;
end;

procedure TAHCorrectionFrm.UpdateImages;
var
  I, ind: Integer;
  li:tlistitem;
  t:itag;
  a:cAHgrad;
  str:string;
begin
  for I := 0 to TagsListFrame1.TagsLV.Items.Count - 1 do
  begin
    li:=TagsListFrame1.TagsLV.Items[i];
    t:=itag(li.data);
    str:=t.GetName;
    if g_algMng.m_AHNames.find(str, ind) then
    begin
      li.ImageIndex:=0;
    end
    else
    begin
      li.ImageIndex:=1;
    end;
  end;
end;

end.
