unit uThresholdsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons,
  uControlEditFrame, uModeFrame, uRecorderEvents, uControlObj,
  uComponentServises,
  uAlarms,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService,
  tags, recorder, uBaseObjService, uModesTabsForm, activex, uRTrig,
  DCL_MYOWN, uRcCtrls, uTrigsFrm, uEventTypes, uCommonMath,
  uExcel, Spin, uSpin, uTagsListFrame;

type
  TAlarms = class;

  TThresholdGroup = class
  public
    ControlTag:itag;
    AlarmList:tstringlist;
    name:string;

    normal, HH, h, L, LL:double;
    outRange:double;
    normalCol, outRangeCol, HHCol, hCol, LCol, LLCol:integer;
  public
    function addtag(t:itag; var new:boolean):TAlarms;
    constructor create;
    destructor destroy;
  end;

  TAlarms = class
  public
    owner:TThresholdGroup;
    t:itag;
  end;

  TThresholdFrm = class(TForm)
    BotPan: TPanel;
    AddPObjBtn: TSpeedButton;
    UpdatePObjBtn: TSpeedButton;
    LoadFromExcelBtn: TSpeedButton;
    SaveToExcelBtn: TSpeedButton;
    LeftPan: TPanel;
    TagsTV: TVTree;
    Panel3: TPanel;
    TagsListFrame1: TTagsListFrame;
    AlClPan: TPanel;
    OutRangeSe: TFloatSpinEdit;
    OutRangeLabel: TLabel;
    HHSe: TFloatSpinEdit;
    HHLabel: TLabel;
    HSe: TFloatSpinEdit;
    HLabel: TLabel;
    LSe: TFloatSpinEdit;
    LLabel: TLabel;
    LLSe: TFloatSpinEdit;
    LLLabel: TLabel;
    OutRColor: TPanel;
    HHColor: TPanel;
    HColor: TPanel;
    LColor: TPanel;
    LLColor: TPanel;
    NormalSE: TFloatSpinEdit;
    NormalLabel: TLabel;
    NormalColor: TPanel;
    NumSe: TSpinEdit;
    NumLabel: TLabel;
    GroupNameEdit: TEdit;
    GroupNameLabel: TLabel;
    ControTaglCB: TRcComboBox;
    ControlTagLabel: TLabel;
    ImageList_16: TImageList;
    NotValidCB: TCheckBox;
    procedure TagsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TagsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure TagsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    function AddGroup:pVirtualNode;
  public
    procedure UpdateTagList;
  end;

var
  ThresholdFrm: TThresholdFrm;

implementation

{$R *.dfm}

{ TThresholdFrm }

function TThresholdFrm.AddGroup: pVirtualnode;
var
  d:pnodedata;
  g:TThresholdGroup;
begin
  g:=TThresholdGroup.create;
  result:=TagsTV.AddChild(TagsTV.rootNode, nil);
  d:=TagsTV.getNodeData(result);
  g.name:='Group_'+inttostr(result.Index);
  d.Caption:=g.name;
  d.color:=TagsTV.normalcolor;
  d.ImageIndex:=1;
  D.data:=g;
end;

procedure TThresholdFrm.TagsTVChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  d:pnodedata;
  g:TThresholdGroup;
  a:TAlarms;
begin
  Node := tagsTV.GetFirstSelected(true);
  if Node <> nil then
  begin
    d:=tagsTV.GetNodeData(Node);
    if tobject(d.Data) is TThresholdGroup then
    begin
      g:=TThresholdGroup(d.Data);
    end;
    if tobject(d.Data) is TAlarms then
    begin
      a:=TAlarms(d.Data);
    end;
  end;
end;

procedure TThresholdFrm.TagsTVDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  I: Integer;
  n, new: PVirtualNode;
  d, sd:pnodedata;
  g:TThresholdGroup;
  t:itag;
  a:TAlarms;
  newAlarm:boolean;
  li:tlistitem;
begin
  // создаем узел при необходимости
  n := Sender.DropTargetNode;
  if n<>nil then
  begin
    d:=TagsTV.GetNodeData(n);
  end
  else
  begin
    n:=AddGroup;
    d:=TagsTV.getNodeData(n);
  end;
  g:=TThresholdGroup(d.data);
  // добавляем к узлу новые теги
  if source=TagsListFrame1.TagsLV then
  begin
    li:=TagsListFrame1.TagsLV.Selected;
    t:=itag(li.data);
    while li<>nil do
    begin
      a:=g.addtag(t, newAlarm);
      if newAlarm then
      begin
        new:=TagsTV.AddChild(n, nil);
        sd:=TagsTV.GetNodeData(new);
        sd.data:=a;
        sd.color:=TagsTV.normalcolor;
        sd.ImageIndex:=0;
        sd.Caption:=li.Caption;
        li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
        if li<>nil then
          t:=itag(li.data);
      end
      else
      begin
        li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
        if li<>nil then
          t:=itag(li.data);
      end;
    end;
  end;
end;

procedure TThresholdFrm.TagsTVDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := false;
  if Source = TagsListFrame1.TagsLV then
    Accept := true;
end;

procedure TThresholdFrm.UpdateTagList;
begin
  TagsListFrame1.ShowChannels;
end;

{ TThresholdGroup }
function TThresholdGroup.addtag(t: itag; var new:boolean): TAlarms;
var
  s:string;
  a:TAlarms;
  i:integer;
begin
  s:=t.GetName;
  if not AlarmList.find(s, i) then
  begin
    a:=TAlarms.Create;
    a.t:=t;
    a.owner:=self;
    AlarmList.AddObject(s, a);
    result:=a;
    new:=true;
    if AlarmList.Count=1 then
    begin
      {HH:=;
      h:=;
      L:=;
      LL:=;
      normalCol:=;
      outRangeCol:=;
      HHCol:=;
      hCol:=;
      LCol:=;
      LLCol:=;}
    end;
  end
  else
  begin
    a:=TAlarms(AlarmList.Objects[i]);
    result:=a;
    new:=false;
  end;
end;

constructor TThresholdGroup.create;
begin
  AlarmList:=TStringList.Create;
  AlarmList.Sorted:=true;
end;

destructor TThresholdGroup.destroy;
var
  I: Integer;
  a:TAlarms;
begin
  for I := 0 to AlarmList.Count - 1 do
  begin
    a:=TAlarms(AlarmList.objects[i]);
    a.Destroy;
  end;
  AlarmList.Destroy;
end;

end.
