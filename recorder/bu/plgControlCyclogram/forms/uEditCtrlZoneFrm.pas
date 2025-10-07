unit uEditCtrlZoneFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, ComCtrls, uBtnListView, ExtCtrls,
  uComponentServises,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService,
  uBaseObjService, uModesTabsForm, activex, uRTrig,
  uRcCtrls, uTrigsFrm, uEventTypes,
  recorder,
  TAGS;

type
  TEditCtrlZoneFrm = class(TForm)
    ZoneTypeCB: TCheckBox;
    TolEdit: TFloatEdit;
    TolLabel: TLabel;
    ZoneDscLabel: TLabel;
    ChannelsLV: TBtnListView;
    FormChannelsGB: TGroupBox;
    ChanNamesPanel: TPanel;
    FrmTagPropLabel: TLabel;
    FrmTagPropValue: TLabel;
    FilterEdit: TEdit;
    FrmTagPropValueEdit: TEdit;
    FrmTagPropNameCB: TComboBox;
    TagsLV: TBtnListView;
    procedure ChannelsLVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ChannelsLVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  private
    { Private declarations }
  public
    procedure ShowChannels;
    procedure Show(units:string);
  end;

var
  EditCtrlZoneFrm: TEditCtrlZoneFrm;

implementation

{$R *.dfm}


procedure TEditCtrlZoneFrm.ChannelsLVDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  t:itag;
  s:string;
  li, next, newli:tlistitem;
  b:boolean;
begin
  li:=tbtnlistview(source).selected;//tbtnlistview(source).GetItemAt(x,y);
  while li<>nil do
  begin
    b:=true;
    t:=itag(li.data);
    next:=tbtnlistview(source).GetNextItem(li, sdBelow, [isSelected]);
    // отрисовка свойств тега
    newli:=tbtnlistview(sender).items.Add;
    newli.data:=pointer(t);
    s:=t.getName;
    tbtnlistview(sender).SetSubItemByColumnName('Имя',s,newli);
    tbtnlistview(sender).SetSubItemByColumnName('Значение','1',newli);
    if li=next then break;
    li:=next;
  end;
  lvchange(tbtnlistview(sender));
end;

procedure TEditCtrlZoneFrm.ChannelsLVDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  li:tlistitem;
begin
  if source is tBtnListView then
  begin
    li:=tBtnListView(source).selected;
    if li=nil then exit;
    if li.Data <>nil then
    begin
      if tListitem(source).Data <>nil then
      begin
        Accept:= Supports(itag(li.Data),IID_ITAG);
      end;
    end;
  end;
end;

procedure TEditCtrlZoneFrm.Show(units: string);
begin


end;

procedure TEditCtrlZoneFrm.ShowChannels;
var
  I, ind, tCount: Integer;
  ir: IRecorder;
  t: iTag;
  tname: string;
  li: TListItem;
begin
  ir := getIR;
  // обновляем список каналов
  tCount := ir.GetTagsCount;
  TagsLV.Clear;
  for I := 0 to tCount - 1 do
  begin
    t := GetTagByIndex(I);
    tname := t.GetName;
    if ((pos(lowercase(FilterEdit.text), lowercase(tname)) > 0) or
        (FilterEdit.text = '')) then
    begin
      li := TagsLV.Items.Add;
      li.Data := pointer(t);
      TagsLV.SetSubItemByColumnName('Имя', tname, li);
    end;
  end;
  LVChange(TagsLV);
end;


end.
