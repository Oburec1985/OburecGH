unit uAlgTagListFrame;

interface

uses
  Windows, SysUtils, Classes, Forms, uBldTimeProc,
  uBtnListView, StdCtrls, Controls, ComCtrls, uBaseBldAlg, uTag, uchart,
  udrawobj, uEditTagForm, UComponentServises, uBaseobj;

type
  TAlgTagListFrame = class(TFrame)
    TagListLabel: TLabel;
    TagListLV: TBtnListView;
    procedure TagListLVDblClickProcess(item: TListItem; lv: TListView);
    procedure TagListLVResize(Sender: TObject);
    procedure TagListLVChange;
  private
    chart:cchart;
    tproc:cbldtimeproc;
  private
    Procedure ShowAlgTags(tags:cbaseobjList);
    procedure changeitem(li:tlistitem;t:cbasetag);
  public
    constructor create(aowner:tcomponent);override;
    procedure Linc(p_chart:cchart;tp:cbldtimeproc);
    // записать теги в форму
    procedure getAlg(tags:cbaseobjList);
    // считать форму в теги
    procedure setAlg;
  end;

implementation
{$R *.dfm}

const
  c_Num = '№';
  c_NameCol = 'Имя';
  c_typeCol = 'Тип';
  c_DscCol = 'Описание';
  c_DrawCol = 'Отрисовка';

procedure TAlgTagListFrame.Linc(p_chart:cchart; tp:cbldtimeproc);
begin
  if tproc<>nil then exit;
  chart:=p_chart;
  tproc:=tp;
  EditTagForm.Linc(tp);
end;

Procedure TAlgTagListFrame.ShowAlgTags(tags:cbaseobjList);
var
  I: Integer;
  li:tListItem;
  tag:cbasetag;
begin
  TagListLV.Clear;
  for I := 0 to tags.count - 1 do
  begin
    li:=TagListLV.Items.Add;
    tag:=cBaseTag(tags.getobj(i));
    changeitem(li,tag)
  end;
  TagListLVChange;
end;

procedure TAlgTagListFrame.changeitem(li:tlistitem;t:cbasetag);
begin
  li.Data:=t;
  li.Checked:=t.active;
  taglistlv.SetSubItemByColumnName(c_Num,inttostr(li.Index),li);
  taglistlv.SetSubItemByColumnName(c_NameCol,t.name,li);
  taglistlv.SetSubItemByColumnName(c_TypeCol,t.typestring,li);
  taglistlv.SetSubItemByColumnName(c_DscCol,t.dsc,li);
  if t.DrawObj<>nil then
    taglistlv.SetSubItemByColumnName(c_DrawCol,t.DrawObj.name,li)
end;

procedure TAlgTagListFrame.TagListLVChange;
begin
  LVChange(TagListLV);
end;

procedure TAlgTagListFrame.TagListLVDblClickProcess(item: TListItem;
  lv: TListView);
var
  obj:cdrawobj;
begin
  EditTagForm.EditTag(cbasetag(item.Data));
  changeitem(item,cbasetag(item.data))
end;

procedure TAlgTagListFrame.TagListLVResize(Sender: TObject);
var
  I,w: Integer;
  col:tlistcolumn;

  j:integer;
  colwidth:array of integer;
  li:tlistitem;
begin
  w:=round(TagListLV.Width/(TagListLV.Columns.Count - 1));
  col:=TagListLV.Columns[0];
  col.Width:=35;
  for I := 1 to TagListLV.Columns.Count - 1 do
  begin
    col:=TagListLV.Columns[i];
    col.Width:=w;
  end;
end;

procedure TAlgTagListFrame.getAlg(tags:cbaseobjList);
begin
  ShowAlgTags(tags);
end;

procedure TAlgTagListFrame.setAlg;
var
  i:integer;
  li:tlistitem;
  tag:cbasetag;
begin
  for I := 0 to TagListLV.items.Count - 1 do
  begin
    li:=TagListLV.items[i];
    tag:=cbasetag(li.Data);
    tag.active:=li.Checked;
  end;
end;

constructor TAlgTagListFrame.create(aowner:tcomponent);
var
  col:tListColumn;
begin
  inherited;
  col:=TagListLV.Columns.Add;
  col.Caption:=c_Num;
  col:=TagListLV.Columns.Add;
  col.Caption:=c_NameCol;
  col:=TagListLV.Columns.Add;
  col.Caption:=c_TypeCol;  
  col:=TagListLV.Columns.Add;
  col.Caption:=c_DscCol;
  col:=TagListLV.Columns.Add;
  col.Caption:=c_DrawCol;
end;

end.
