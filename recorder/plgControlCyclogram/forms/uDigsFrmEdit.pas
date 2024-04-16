unit uDigsFrmEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uTagsListFrame, ExtCtrls, StdCtrls, Spin, DCL_MYOWN, Grids, comctrls,
  ucommonmath, mathfunction, uComponentServises, uRCFunc, tags,
  uDigsFrm, uCommonTypes;

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
    HHColor: TPanel;
    UseThreshold: TCheckBox;
    HHEdit: TFloatEdit;
    DigitFormatCB: TCheckBox;
    procedure ColOkBtnClick(Sender: TObject);
    procedure AddGroupBtnClick(Sender: TObject);
    procedure ColumnSEChange(Sender: TObject);
    procedure UpdateTagsBtnClick(Sender: TObject);
    procedure UpdateTagsBtnClick2(Sender: TObject);
    procedure SignalsSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ApplyBtnClick(Sender: TObject);
    procedure SignalsSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SignalsSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure SignalsSGDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SignalsSGDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DigitFormatCBClick(Sender: TObject);
  protected
    curFrm:TDigsFrm;
    curGr:TGroup;
    m_Col,m_Row:integer;
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
    constructor create(aowner:tcomponent);override;
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

  ColumnSE.MaxValue:=ColCountE.IntNum-1;
  ColumnSE.MinValue:=0;
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
      col.estimate:=EstCB.ItemIndex;
      col.name:=ColNameE.Text;
      col.useThreshold:=UseThreshold.Checked;
      col.color:=HHColor.Color;
      col.HH:=HHEdit.FloatNum;
      SignalsSG.Cells[ColumnSE.Value+1,0]:=col.fullname;
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
    EstCB.ItemIndex:=col.estimate;
    UseThreshold.Checked:=col.useThreshold;
    HHColor.Color :=col.color;
    HHEdit.FloatNum:=col.HH;
  end;
end;

constructor TDigsFrmEdit.create(aowner: tcomponent);
begin
  inherited;
  m_Col:=1;
  m_Row:=1;
end;

procedure TDigsFrmEdit.DigitFormatCBClick(Sender: TObject);
begin
  if DigitFormatCB.Checked then
  begin
    DigitFormatCB.Caption:='Знаков посл. запятой';
  end
  else
  begin
    DigitFormatCB.Caption:='Знач-х цифр';
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
    curfrm.m_digits:=DigitsIE.IntNum;
    curfrm.m_Format:=DigitFormatCB.Checked;
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
  HHColor.Color:=clpink;

  DigitsIE.IntNum:=curfrm.m_digits;
  DigitFormatCB.Checked:=curfrm.m_Format;
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
  ColumnSE.MaxValue:=curFrm.colNames.Count-1;
  ColumnSE.MinValue:=0;
  for I := 0 to curFrm.colNames.Count - 1 do
  begin
    c:=tdigcolumn(curFrm.colNames.Get(i));
    if i=0 then
    begin
      ColumnSE.Value:=0;
      ColNameE.text:=c.name;
      HHColor.Color:=C.color;
      UseThreshold.Checked:=C.useThreshold;
      HHEdit.FloatNum:=C.HH;
    end;
    SignalsSG.Cells[i+1,0]:=c.fullname;
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

procedure TDigsFrmEdit.SignalsSGDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  col, row:integer;
begin
  SignalsSG.MouseToCell(x, y, col, row);
  if (col>0) and (row>0) then
    SignalsSG.Cells[col,row]:=itag(tlistview(Source).Selected.Data).GetName;
end;

procedure TDigsFrmEdit.SignalsSGDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if source=TagsListFrame1.TagsLV then
    Accept:=true
  else
    Accept:=false;
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
  if acol=0 then
  begin
    Color := SignalsSG.Canvas.Brush.Color;
    SignalsSG.Canvas.Brush.Color := clGray;
  end
  else
  begin
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
  end;
  SignalsSG.Canvas.FillRect(Rect);
  SignalsSG.Canvas.TextOut(Rect.Left, Rect.Top, SignalsSG.Cells[ACol, ARow]);
  SignalsSG.Canvas.Brush.Color := Color;
end;

procedure TDigsFrmEdit.SignalsSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  g:TGroup;
begin
  if key=VK_RETURN then
  begin
    if m_col=0 then
    begin
      g:=TGroup(curfrm.glist.get(m_Row-1));
      if g=nil then exit;
      g.name:=SignalsSG.Cells[m_Col,m_Row]+'_'+getendnum(g.name);
      SignalsSG.Cells[m_Col,m_Row]:=g.name;
    end;
  end;
end;

procedure TDigsFrmEdit.SignalsSGSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  m_Col:=acol;
  m_Row:=arow;
end;

procedure TDigsFrmEdit.UpdateHeader;
var
  I: Integer;
  col:TDigColumn;
begin
  for I := 0 to curFrm.colCount - 1 do
  begin
    col:=TDigColumn(curFrm.colNames.Get(i));
    SignalsSG.Cells[i,0]:=col.fullname;
  end;
end;

procedure TDigsFrmEdit.UpdateTagsBtnClick(Sender: TObject);
var
  I: Integer;
  li:tlistitem;
  Col:TDigColumn;
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
        col:=TDigColumn(curFrm.colNames.Get(k-1));
        colname:=col.name;
        //colname:=SignalsSG.Cells[k,0];
        if colname<>'' then
        begin
          b1:=(pos(lowercase(colname), lowercase(s))>0) or
              (pos(colname, s)>0)
        end
        else
          continue;
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
          continue;
        end;
      end;
    end;
  end;
  SGChange(signalsSG);
end;

procedure TDigsFrmEdit.UpdateTagsBtnClick2(Sender: TObject);
var
  I: Integer;
  li:tlistitem;
  t:itag;
  Col:TDigColumn;
  s, subnum, colname:string;
  g:TGroup;
  b1,b2,b3:boolean;
  j, num, num2: Integer;
  k: Integer;
begin
  // цикл по строкам
  for j := 0 to curfrm.glist.Count - 1 do
  begin
    g:=TGroup(curfrm.glist.get(j));
    subnum:=getendnum(g.name);
    // цикл по столбцам
    for k := 1 to SignalsSG.colCount - 1 do
    begin
      col:=TDigColumn(curFrm.colNames.Get(k-1));
      colname:=col.name;
      if colname='' then
        continue;
      for I := 0 to TagsListFrame1.TagsLV.Items.Count - 1 do
      begin
        t:=itag(TagsListFrame1.TagsLV.Items[i].Data);
        s:=t.GetName;
        // поиск по имени колонки
        b1:=(pos(lowercase(colname), lowercase(s))>0) or (pos(colname, s)>0);
        if subnum<>'' then
        begin
          // поиск по точному совпадению subnum
          b2:=pos(lowercase(subnum), lowercase(s))>0;
          if not b2 then
          begin
            num:=strtoint(subnum);
            num2:=getSubNum(s, num);
            if num2=num then
            begin
              b2:=true;
            end;
          end;
        end;
        if TagSubstrE.Text<>'' then
          b3:=pos(lowercase(TagSubstrE.Text), lowercase(s))>0
        else
          b3:=true;
        if b1 and b2 and b3 then
        begin
          signalsSG.Cells[k, j+1]:=s;
          continue;
        end;
      end;
    end;
  end;
  SGChange(signalsSG);
end;

end.
