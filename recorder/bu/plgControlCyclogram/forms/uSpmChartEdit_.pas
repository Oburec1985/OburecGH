unit uSpmChartEdit_;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons,
  uControlEditFrame, uModeFrame, uRecorderEvents, uControlObj,
  uComponentServises,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService,
  tags, recorder, uBaseObjService, uModesTabsForm, activex, uRTrig,
  DCL_MYOWN, uRcCtrls, uTrigsFrm, uEventTypes, uBaseAlg, uspmchart
  //, uBaseAlg
  ;

type
  TSpmChartEditFrm_ = class(TForm)
    ChannelsPanel: TPanel;
    TagsGB: TGroupBox;
    TagsLB: TListBox;
    PropPanel: TPanel;
    MinXLabel: TLabel;
    MaxXLabel: TLabel;
    MinYLabel: TLabel;
    MaxYLabel: TLabel;
    UpdateBtn: TSpeedButton;
    MinXfe: TFloatEdit;
    MaxXfe: TFloatEdit;
    MinYfe: TFloatEdit;
    MaxYfe: TFloatEdit;
    LgYcb: TCheckBox;
    LgXcb: TCheckBox;
    TubesGB: TGroupBox;
    TubeWarningCB: TCheckBox;
    TubeProfileCB: TCheckBox;
    TubeAlarmCB: TCheckBox;
    Panel1: TPanel;
    FormChannelsGB: TGroupBox;
    ChanNamesPanel: TPanel;
    FrmTagPropLabel: TLabel;
    FrmTagPropValue: TLabel;
    FilterEdit: TEdit;
    FrmTagPropValueEdit: TEdit;
    FrmTagPropNameCB: TComboBox;
    TagsLV: TBtnListView;
    procedure UpdateBtnClick(Sender: TObject);
  public
    curChart:TSpmChart;
  public
    procedure TagsLBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TagsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
  private
    // ОТОБРАЗИТЬ СПИСОК ДОСТУПНЫХ ТЕГОВ
    procedure ShowSpmTags;
  public
    procedure EditChart(chart:TspmChart);
  end;

var
  SpmChartEditFrm_: TSpmChartEditFrm_;

implementation

{$R *.dfm}

{ TSpmChartEditFrm }

procedure TSpmChartEditFrm_.EditChart(chart: TspmChart);
begin
  curChart:=chart;
  if chart<>nil then
  begin
    MinXfe.FloatNum:=chart.aX.x;
    MaxXfe.FloatNum:=chart.aX.y;
    MinYfe.FloatNum:=chart.aY.x;
    MaxYfe.FloatNum:=chart.aY.y;
    lgXcb.Checked:=chart.lgX;
    lgYcb.Checked:=chart.lgY;
    TubeProfileCB.Checked:=chart.m_ShowProfile;
    TubeWarningCB.Checked:=chart.m_ShowProfile;
    TubeAlarmCB.Checked:=chart.m_ShowAlarms;
    showmodal;
  end;
end;

procedure TSpmChartEditFrm_.UpdateBtnClick(Sender: TObject);
var
  I: Integer;
  spm:cSpm;
begin
  if curchart<>nil then
  begin
    curchart.aX.x:=MinXfe.FloatNum;
    curchart.aX.y:=MaxXfe.FloatNum;
    curchart.aY.x:=MinYfe.FloatNum;
    curchart.aY.y:=MaxYfe.FloatNum;
    curchart.lgX:=lgXcb.Checked;
    curchart.lgY:=lgYcb.Checked;
    curchart.m_ShowProfile:=TubeProfileCB.Checked;
    curchart.m_ShowProfile:=TubeWarningCB.Checked;
    curchart.m_ShowAlarms:=TubeAlarmCB.Checked;
    curchart.clearTagsInfo;
    for I := 0 to tagsLB.Count - 1 do
    begin
      spm:=cSpm(TagsLB.Items.Objects[i]);
      curchart.addspm(spm);
    end;
  end;
end;

procedure TSpmChartEditFrm_.ShowSpmTags;
var
  I, ind: Integer;
  ir: IRecorder;
  t: iTag;
  tname: string;
  li: TListItem;
  a:cBaseAlgContainer;
begin
  ir := getIR;
  // обновляем список каналов
  {TagsLV.Clear;
  for I := 0 to g_algMng.count - 1 do
  begin
    a := g_algMng.getalg(i);
    if a is cspm then
    begin
      tname := cspm(a).resname;
      if ((pos(lowercase(FilterEdit.text), lowercase(tname)) > 0) or
          (FilterEdit.text = '')) then
      begin
        li := TagsLV.Items.Add;
        li.Data := pointer(a);
        TagsLV.SetSubItemByColumnName('Имя', tname, li);
      end;
    end;
  end;
  LVChange(TagsLV);}
end;

procedure TSpmChartEditFrm_.TagsLBDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  s:string;
  spm:cspm;
  li, next, newli:tlistitem;
  b:boolean;
begin
  li:=tbtnlistview(source).selected;
  while li<>nil do
  begin
    b:=true;
    spm:=cspm(li.data);
    next:=tbtnlistview(source).GetNextItem(li, sdBelow, [isSelected]);
    // отрисовка свойств тега
    tagsLB.items.AddObject(spm.resname,spm);
    if li=next then break;
    li:=next;
  end;
end;

procedure TSpmChartEditFrm_.TagsLBDragOver(Sender, Source: TObject; X,
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
      if li.Data <>nil then
      begin
        //Accept:= Supports(itag(li.Data),IID_ITAG);
        Accept:= tobject(li.data) is cspm;
      end;
    end;
  end;
end;

end.
