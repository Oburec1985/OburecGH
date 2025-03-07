unit uChartFrame;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uDoubleCursor,
  ExtCtrls, uChart, ComCtrls, uBtnListView, ImgList, ubldTimeProc,
  uCreateObjForm, uComponentServises, uBldEngEventTypes,
  StdCtrls, uBldCompProc, utag, uCommonMath, uBaseObjService, uBaseBldAlg,
  uGlTurbineFrame, uAlarms, graphics, mathfunction,
  uBuffTrend1d, uBuffTrend2d, uAutoPage, uEditGraphForm, uRegClassesList,
  uCommonTypes, ToolWin, Spin, uEventTypes;

type
  TChartFrame = class(TFrame)
    formulyarsTC: TPageControl;
    ChartTabSheet: TTabSheet;
    DigitFormTabSheet: TTabSheet;
    VisualTabSheet: TTabSheet;
    TurbineGLGB: TGroupBox;
    Splitter1: TSplitter;
    glTurbineFrame1: TglTurbineFrame;
    Splitter2: TSplitter;
    AutoPage: TTabSheet;
    ToolBar1: TToolBar;
    PageCountSE: TSpinEdit;
    DigitsLV: TBtnListView;
    cChart1: cChart;
    cChart2: cChart;
    procedure cChart1Init(Sender: TObject);
    procedure onUpdateTimeProcPlayFunc(sender:tobject);
    procedure glTurbineFrame1ApplyBtnClick(Sender: TObject);
    procedure DigitsLVDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure DigitsLVAdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure cChart2Init(Sender: TObject);
    procedure PageCountSEChange(Sender: TObject);
  private
    tproc:cBldTimeProc;
  private
    procedure lincframes;
    procedure OnChangeEventList(Sender: TObject);
    procedure OnAddTag(Sender: TObject);
    procedure OnLoad(Sender: TObject);
    procedure OnUpdateValue(sender:tobject);
    procedure InitTags;
    procedure AddTag(tag:cbasetag);
    procedure createevents;
    procedure OnTagAlarm(sender:tobject);
    procedure OnEditObj(obj:tobject);
  public
    drawcount, t1, t2:cardinal;
    pagecount:integer;
    fps,framecounter:integer;
  public
    procedure SetTimeLength(t:single);
    procedure OnselectTag(tag:tlistitem);
    procedure linctproc(tp:cbldtimeproc);
    function chart:cchart;
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

  const
    a: array [0..5] of single = (0, 1, 2 , 4, 16 , 64);
    a2: array [0..4] of point2 = ((x:0;y:0), (x:1;y:1) , (x:2;y:4), (x:3;y:8), (x:4;y:16));
implementation


{$R *.dfm}

procedure TChartFrame.AddTag(tag:cbasetag);
var
  i:integer;
  li:tlistitem;
  str:string;
begin
  li:=DigitsLV.Items.Add;
  li.data:=tag;
  DigitsLV.SetSubItemByColumnName(v_ColNum,inttostr(li.index),li);
  DigitsLV.SetSubItemByColumnName(v_ColName,tag.name,li);
  DigitsLV.SetSubItemByColumnName(v_ColType,tag.TypeString,li);
  if tag.source<>nil then
  begin
    if tag.source is cBasebldalg then
    begin
      str:=cBasebldalg(tag.source).name;
    end;
  end
  else
  begin
    str:='';
  end;
  DigitsLV.SetSubItemByColumnName(v_ColAdress,str,li);
  DigitsLV.SetSubItemByColumnName(v_ColValue,'',li);
end;

procedure TChartFrame.InitTags;
var
  i:integer;
  li:tlistitem;
begin
  DigitsLV.clear;
  for I := 0 to tproc.fTagMng.count - 1 do
  begin
    onaddtag(tproc.fTagMng.gettag(i));
  end;
end;

procedure TChartFrame.OnUpdateValue(sender:tobject);
var
  I:Integer;
  li:tlistitem;
  tag:cbasetag;
  val:string;
begin
  for I := 0 to DigitsLV.items.count - 1 do
  begin
    li:=DigitsLV.Items[i];
    tag:=cbasetag(li.data);
    if tag is cscalartag then
    begin
      val:=formatstr(cscalartag(tag).value,tproc.prec);
      DigitsLV.SetSubItemByColumnName(v_ColValue,val,li);
    end;
    if tag is c2scalartag then
    begin
      val:=formatstr(c2scalartag(tag).value.y,tproc.prec);
      DigitsLV.SetSubItemByColumnName(v_ColValue,val,li);
    end;
  end;
  DigitsLV.Invalidate;
end;

constructor TChartFrame.create(aowner:tcomponent);
begin
  inherited;
  pagecount:=1;
  InitDigitsLV(DigitsLV);
end;

destructor TChartFrame.destroy;
begin
  inherited;
end;

procedure TChartFrame.DigitsLVDrawItem(Sender: TCustomListView; Item: TListItem;
  Rect: TRect; State: TOwnerDrawState);
var
  i: integer;
  l: integer;
begin

end;

procedure TChartFrame.DigitsLVAdvancedCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
begin
  if calarmslist(cbasetag(Item.data).alarms).inalarm then
  //if item.Index=0 then
  begin
    sender.Canvas.Brush.Color := clred;
  end;
end;


procedure TChartFrame.lincframes;
begin
  CreateObjForm.linc(cchart1);
end;

procedure TChartFrame.onUpdateTimeProcPlayFunc(sender:tobject);
begin
  if t1=0 then
    framecounter:=0;
  if framecounter=0 then
  begin
    t1:=GetTickCount;
  end;

  inc(framecounter);
  t2:=GetTickCount;
  if ((t2-t1)/1000)>1 then
  begin
    t1:=0;
    fps:=framecounter;
  end;
  // �������� ��������
  OnUpdateValue(sender);
  // ������������
  glturbineframe1.ChangePhase(30);
  glturbineframe1.cBaseGlComponent1.redraw;
end;

procedure TChartFrame.cChart1Init(Sender: TObject);
begin
  drawcount:=0;
  t1:=0;
  framecounter:=0;
  cchart1.objmng.events.fEventListChange:=OnChangeEventList;
  OnChangeEventList(self);
  lincframes;
  // ��������� treeView ����� ��� �������� ��������
  cchart1.tv.dragcursor:=crHandPoint;
  cchart1.tv.dragMode:=dmAutomatic;
end;

procedure TChartFrame.cChart2Init(Sender: TObject);
var
  page:cAutoPage;
  objCreator:cObjCreator;
begin
  cChart2.OnEditObj:=OnEditObj;
  objCreator:=cObjCreator(cRegClassesList(cChart2.OBJmNG.regclasses).GetObj('cAutoPage'));
  objCreator.addInfo.AddObject('Form',EditGraphForm);

  cchart2.activeTab.clear;
  page:=cAutoPage.create;
  page.activeAxis.min:=p2d(page.activeAxis.min.x,-2);
  page.activeAxis.max:=p2d(page.activeAxis.max.x,2);
  cchart2.activeTab.AddChild(page);
  cchart2.activeTab.doalign(page);
end;


procedure TChartFrame.PageCountSEChange(Sender: TObject);
var
  page:cAutoPage;
  I: Integer;
begin
  page:=nil;
  cchart2.activeTab.clear;
  cchart2.activeTab.events.active:=false;
  for I := 0 to PageCountSE.value - 1 do
  begin
    page:=cAutoPage.create;
    page.activeAxis.min:=p2d(page.activeAxis.min.x,-2);
    page.activeAxis.max:=p2d(page.activeAxis.max.x,2);
    page.id:=i;
    if I=PageCountSE.value-1 then
    begin
      cchart2.activeTab.events.active:=true;
    end;
    cchart2.activeTab.AddChild(page);
  end;
  if page<>nil then
  begin
    cchart2.activeTab.doalign(page);
  end;
  pagecount:=PageCountSE.Value;
end;

procedure TChartFrame.OnAddTag(Sender: TObject);
var
  i:integer;
  li:tlistitem;
begin
  if cbasetag(Sender) is cBaseScalarTag then
  begin
    if cbasetag(Sender).active then
    begin
      begin
        addtag(cbasetag(sender));
      end;
    end
    else
    begin
      for I := 0 to digitsLV.items.Count - 1 do
      begin
        li:=digitsLV.Items[i];
        if li.data=sender then
          li.Destroy;
      end;
    end;
  end;
end;

procedure TChartFrame.OnChangeEventList(Sender: TObject);
begin
  //if EventsListView<>nil then
  begin
    //InitLVForEvents(EventsListView);
    //ShowEventsInLV(cChart1.objmng.events,EventsListView);
  end;
end;

function TChartFrame.chart:cchart;
begin
  result:=cchart1;
end;

procedure TChartFrame.linctproc(tp:cbldtimeproc);
begin
  tproc:=tp;
  glTurbineFrame1.initRes(tp.eng.PathMng);
  createevents;
end;

procedure TChartFrame.createevents;
begin
  tproc.eng.Events.AddEvent('OnUpdateTimeProc_TChartFrame', E_OnTimeProc, onUpdateTimeProcPlayFunc);
  tproc.eng.Events.AddEvent('OnAddTag_TChartFrame', e_OnAddRemoveTag, OnAddTag);
  tproc.eng.Events.AddEvent('OnLoad_TChartFrame', E_OnEngLoadCfg, OnLoad);
  tproc.alarms.Events.AddEvent('OnTagAlarm_TChartFrame', e_OnTagAlarm, OnTagAlarm);
end;

procedure TChartFrame.glTurbineFrame1ApplyBtnClick(Sender: TObject);
begin
  glTurbineFrame1.ApplyBtnClick(Sender);
end;

procedure TChartFrame.OnLoad(Sender: TObject);
begin
  InitTags;
end;

procedure TChartFrame.OnTagAlarm(sender:tobject);
begin

end;


procedure TChartFrame.OnEditObj(obj:tobject);
begin
  if obj is cAutoPage then
  begin
    EditGraphForm.showmodal(cAutoPage(obj));
  end;
end;

procedure TChartFrame.OnselectTag(tag:tlistitem);
var
  I, ind: Integer;
  t:cbasetag;
  page:cautopage;
  lv:tlistview;
begin
  ind:=tag.index;
  lv:=tlistview(tag.ListView);
  if cchart2.initgl then
  begin
    for I := 0 to pagecountse.value - 1 do
    begin
      page:=cautopage(cChart2.activeTab.GetPage(i));
      if page.offsetLink then
      begin
        if page.id+ind<lv.items.count then
        begin
          t:=cbasetag(lv.Items[page.id+ind].Data);
          page.src:=t;
          if t is cVectorTag then
          begin
            t.DrawObj:=page.t1d;
            page.t1d.visible:=true;
            page.t2d.visible:=false;
          end;
          if t is c2VectorTag then
          begin
            t.DrawObj:=page.t2d;
            page.t1d.visible:=false;
            page.t2d.visible:=true;
          end;
          page.Caption:=t.name;
        end;
      end;
    end;
  end;
end;


procedure TChartFrame.SetTimeLength(t:single);
var
  I: Integer;
  page:cautopage;
begin
  if cchart2.initgl then
  begin
    for I := 0 to pagecountse.value - 1 do
    begin
      page:=cautopage(cchart2.tabs.activeTab.GetPage(i));
      page.activeAxis.max:=p2d(t,page.activeAxis.max.y);
    end;
  end;
end;


end.
