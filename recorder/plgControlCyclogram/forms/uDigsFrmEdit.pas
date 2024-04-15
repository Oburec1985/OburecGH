unit uDigsFrmEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uTagsListFrame, ExtCtrls, StdCtrls, Spin, DCL_MYOWN, Grids, comctrls,
  ucommonmath, mathfunction, uComponentServises, uRCFunc,
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
    ColOkBtn: TButton;
    Panel1: TPanel;
    ApplyBtn: TButton;
    Label1: TLabel;
    DigitsIE: TIntEdit;
    Label2: TLabel;
    FontSizeIE: TIntEdit;
    procedure ColOkBtnClick(Sender: TObject);
    procedure AddGroupBtnClick(Sender: TObject);
    procedure ColumnSEChange(Sender: TObject);
    procedure UpdateTagsBtnClick(Sender: TObject);
    procedure SignalsSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ApplyBtnClick(Sender: TObject);
  protected
    curFrm:TDigsFrm;
    curGr:TGroup;
  private
    // отобразить конфигурацию родителя в настроечной форме
    procedure ShowCfg;
    // отобразить доступные теги
    procedure ShowTags;
    // отобразщить имена колонок
    procedure UpdateHeader;
    // отобразщить имена строк
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
  curFrm.colCount:=ColCountE.IntNum;
  SignalsSG.ColCount:=ColCountE.IntNum+1;

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
  GroupCountIE.IntNum:=0;
end;

procedure TDigsFrmEdit.ApplyBtnClick(Sender: TObject);
begin
  Modalresult:=mrok;
end;

procedure TDigsFrmEdit.ColOkBtnClick(Sender: TObject);
var
  col:TDigColumn;
  I: Integer;
  g:tgroup;
  j: Integer;
  s:string;
  t:ctag;
begin
  // обновляем колонку
  if ColumnSE.Value<curFrm.colNames.Count then
  begin
    col:=TDigColumn(curFrm.colNames.Get(ColumnSE.Value));
    if ColNameE.Text<>'' then
    begin
      col.name:=ColNameE.Text;
      col.estimate:=EstCB.ItemIndex;
      SignalsSG.Cells[ColumnSE.Value+1,0]:=ColNameE.Text;
    end;
  end;
  // обновляем теги
  for I := 1 to SignalsSG.RowCount - 1 do
  begin
    g:=tgroup(curFrm.glist.Get(i-1));
    for j := 1 to SignalsSG.ColCount - 1 do
    begin
      s:=SignalsSG.Cells[j,i];
      if s<>'' then
      begin
        t:=g.gettag(j-1);
        if t=nil then
        begin
          t:=cTag.create;
          t.useEcm:=false;
          g.addTag(t);
          t.tagname:=s;
        end
        else
        begin
          if t.tagname<>s then
          begin
            t.tag:=nil;
            t.tagname:=s;
          end;
        end;
      end;
    end;
  end;
  SignalsSG.Invalidate;
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
var
  I: Integer;
begin
  curFrm:=f;
  ShowTags;
  ShowCfg;
  if ShowModal = mrok then
  begin
    curfrm.SignalsSG.Font.Size:=FontSizeIE.IntNum;
    curfrm.m_FontSize:=FontSizeIE.IntNum;
    curfrm.showcfg;
  end;
end;

procedure TDigsFrmEdit.ShowCfg;
var
  I, j: Integer;
  g: tgroup;
  c:tdigcolumn;
  t:ctag;
begin
  DigitsIE.IntNum:=curfrm.m_digits;
  if curfrm.m_FontSize=0 then
    FontSizeIE.IntNum:=SignalsSG.Font.Size
  else
    FontSizeIE.IntNum:=curfrm.m_FontSize;
  if curFrm.glist.Count<1 then
    SignalsSG.RowCount:=2
  else
    SignalsSG.RowCount:=curFrm.glist.Count+1;
  if curFrm.colNames.Count<1 then
    SignalsSG.ColCount:=2
  else
    SignalsSG.ColCount:=curFrm.colNames.Count+1;
  ColCountE.IntNum:=curFrm.colNames.Count;
  for I := 0 to curFrm.colNames.Count - 1 do
  begin
    c:=tdigcolumn(curFrm.colNames.Get(i));
    if i=0 then
    begin
      ColumnSE.Value:=0;
      ColNameE.text:=c.name;
    end;
    SignalsSG.Cells[i+1,0]:=c.name;
  end;
  for I := 0 to curFrm.gList.Count - 1 do
  begin
    g:=tgroup(curFrm.gList.Get(i));
    SignalsSG.Cells[0,i+1]:=g.name;
    for j := 0 to g.m_tags.Count - 1 do
    begin
      t:=g.gettag(j);
      if t<>nil then
      begin
        SignalsSG.Cells[j+1,i+1]:=t.tagname;
      end;
    end;
  end;
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

procedure TDigsFrmEdit.SignalsSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  s:string;
  g:TGroup;
  t:ctag;
  b:boolean;
begin
  s:=SignalsSG.Cells[acol, arow];
  g:=tgroup(curfrm.glist.Get(arow-1));
  t:=nil;
  if (s='') or (arow=0) or (acol=0) then
  begin
    b:=false;
  end
  else
  begin
    b:=true;
  end;
  if g<>nil then
  begin
    t:=g.gettag(acol-1);
    if t<>nil then
    begin
      if t.tagname<>s then
      begin
        b:=true;
      end
      else
        b:=false;
    end;
  end;
  Color := SignalsSG.Canvas.Brush.Color;
  if b then
  begin
    SignalsSG.Canvas.Brush.Color := clYellow;
  end;
  SignalsSG.Canvas.FillRect(Rect);
  SignalsSG.Canvas.TextOut(Rect.Left, Rect.Top, SignalsSG.Cells[ACol, ARow]);
  SignalsSG.Canvas.Brush.Color := Color;
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

procedure TDigsFrmEdit.UpdateTagsBtnClick(Sender: TObject);
var
  I: Integer;
  li:tlistitem;
  s, subnum, colname:string;
  g:TGroup;
  b1,b2,b3:boolean;
  j, num: Integer;
  k: Integer;
begin
  for I := 0 to TagsListFrame1.TagsLV.Items.Count-1 do
  begin
    li:=TagsListFrame1.TagsLV.items[i];
    s:=li.Caption;
    // цикл по строкам
    for j := 0 to curfrm.glist.Count - 1 do
    begin
      g:=TGroup(curfrm.glist.get(j));
      subnum:=getendnum(g.name);
      // цикл по столбцам
      for k := 1 to SignalsSG.colCount - 1 do
      begin
        colname:=SignalsSG.Cells[k,0];

        if colname<>'' then
          b1:=pos(lowercase(colname), lowercase(s))>0
        else
          break;
        if subnum<>'' then
        begin
          b2:=pos(lowercase(subnum), lowercase(s))>0;
          if not b2 then
          begin
            num:=strtoint(subnum);
            b2:=pos(inttostr(num), s)>0;
          end;
        end
        else
          b2:=true;
        if TagSubstrE.Text<>'' then
          b3:=pos(lowercase(TagSubstrE.Text), lowercase(s))>0
        else
          b3:=true;
        if b1 and b2 and b3 then
        begin
          signalsSG.Cells[k, j+1]:=s;
          SGChange(signalsSG);
          break;
        end;
      end;
    end;
  end;
end;

end.
