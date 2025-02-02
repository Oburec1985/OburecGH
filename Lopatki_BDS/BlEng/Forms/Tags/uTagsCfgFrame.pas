unit uTagsCfgFrame;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  StdCtrls, ComCtrls, uBtnListView, ExtCtrls, ImgList,
  uTagPropertiesFrame, ubldtimeproc, ToolWin, uComponentServises, utag,
  ubldengEventTypes, uBaseBldAlg, Dialogs, uBaseObj, uBldGlobalStrings;

type
  TTagsCfgFrame = class(TFrame)
    ControlGB: TGroupBox;
    TagsLV: TBtnListView;
    Splitter1: TSplitter;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    TagPropertiesGB: TGroupBox;
    Splitter2: TSplitter;
    TagGB: TGroupBox;
    TagPropertiesFrame1: TTagPropertiesFrame;
    TagsMngGB: TGroupBox;
    LogTagsCheckBox: TCheckBox;
    TagsBaseEdit: TEdit;
    TagNameLabel: TLabel;
    SelectTagsBaseBtn: TButton;
    OpenDialog1: TOpenDialog;
    procedure TagsLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure TagPropertiesFrame1DrawObjSelectBtnClick(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure SelectTagsBaseBtnClick(Sender: TObject);
    procedure TagPropertiesFrame1AddTagBtnClick(Sender: TObject);
  private
    tproc:cbldtimeproc;
    curitem:tlistitem;
  protected
    procedure OnChangeTagList(sender:tobject);
  private
    procedure ShowTags;
    procedure TagListLVChange;
    procedure changeitem(li:tlistitem;t:cbasetag);
  public
    procedure Linc(p_timeproc:cBldTimeProc);
    constructor create(aowner:tcomponent);override;
  end;

implementation

{$R *.dfm}

procedure TTagsCfgFrame.TagListLVChange;
begin
  // ��������� ������ �������
  LVChange(TagsLV);
end;

procedure TTagsCfgFrame.TagPropertiesFrame1AddTagBtnClick(Sender: TObject);
begin
  TagPropertiesFrame1.AddAlarmBtnClick(Sender);

end;

procedure TTagsCfgFrame.TagPropertiesFrame1DrawObjSelectBtnClick(
  Sender: TObject);
begin
  TagPropertiesFrame1.DrawObjSelectBtnClick(Sender);
  changeitem(curitem,cbasetag(curitem.data));
end;

procedure TTagsCfgFrame.TagsLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  b:boolean;
begin
  if item<>nil then
  begin
    curitem:=item;
    b:=(tobject(item.data) is cbasetag);
    if b then
    begin
      tagpropertiesframe1.setTag(cbasetag(item.Data));
    end;
  end;
end;

procedure TTagsCfgFrame.SelectTagsBaseBtnClick(Sender: TObject);
begin
  if opendialog1.Execute then
  begin
    TagsBaseEdit.Text:=opendialog1.FileName;
  end;
end;

procedure TTagsCfgFrame.ShowTags;
var
  I: Integer;
  li:tListItem;
  tag:cbasetag;
begin
  TagsLV.Clear;
  for I := 0 to tproc.fTagMng.count - 1 do
  begin
    li:=TagsLV.Items.Add;
    tag:=tproc.fTagMng.gettag(i);
    changeitem(li,tag)
  end;
  TagListLVChange;
end;

procedure TTagsCfgFrame.ApplyBtnClick(Sender: TObject);
begin
  tproc.fTagMng.TagsFolder:=TagsBaseEdit.Text;
  tproc.fTagMng.logtags:=LogTagsCheckBox.checked;
end;

procedure TTagsCfgFrame.changeitem(li:tlistitem;t:cbasetag);
begin
  li.Data:=t;
  li.Checked:=t.active;
  TagsLV.SetSubItemByColumnName(v_Num,inttostr(li.Index),li);
  TagsLV.SetSubItemByColumnName(v_Name,t.name,li);
  TagsLV.SetSubItemByColumnName(v_Type,t.typestring,li);
  TagsLV.SetSubItemByColumnName(v_Dsc,t.dsc,li);
  if t.source<>nil then
  begin
    if t.source is cBaseObj then
      TagsLV.SetSubItemByColumnName(v_src,cBaseObj(t.source).ClassName,li);
  end;
  if t.DrawObj<>nil then
    TagsLV.SetSubItemByColumnName(v_DrawObj,t.DrawObj.name,li)
end;

procedure TTagsCfgFrame.OnChangeTagList(sender:tobject);
begin
  ShowTags;
  TagsBaseEdit.Text:=tproc.fTagMng.TagsFolder;
  LogTagsCheckBox.checked:=tproc.fTagMng.logtags;
end;

procedure TTagsCfgFrame.Linc(p_timeproc:cBldTimeProc);
begin
  tproc:=p_timeproc;
  TagPropertiesFrame1.linc(tproc);
  tproc.eng.Events.AddEvent('TTagsCfgFrame OnChangeTagList',
                             e_OnAddRemoveTag,OnChangeTagList);
  ShowTags;
end;

constructor TTagsCfgFrame.create(aowner:tcomponent);
var
  col:tListColumn;
begin
  inherited;
  col:=tagsLV.Columns.Add;
  col.Caption:=v_Num;
  col:=tagsLV.Columns.Add;
  col.Caption:=v_Name;
  col:=tagsLV.Columns.Add;
  col.Caption:=v_Type;
  col:=tagsLV.Columns.Add;
  col.Caption:=v_Dsc;
  col:=tagsLV.Columns.Add;
  col.Caption:=v_Src;
  col:=tagsLV.Columns.Add;
  col.Caption:=v_DrawObj;
end;

end.
