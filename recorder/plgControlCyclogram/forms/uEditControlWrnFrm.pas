
unit uEditControlWrnFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons,
  uControlEditFrame, uModeFrame, uRecorderEvents, uControlObj,
  uComponentServises, upage,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService, uCommonTypes,uCommonMath,
  tags, recorder, uBaseObjService, uModesTabsForm, activex, uRTrig,
  DCL_MYOWN, uRcCtrls, uTrigsFrm, uEventTypes, uSpin, uControlWarnFrm, uEditProfileFrm, Spin,
  uTagsListFrame, uaxis, uBaseAlg, uGrmsSrcAlg;

type


  TEditCntlWrnFrm = class(TForm)
    PropPanel: TPanel;
    TubesGB: TGroupBox;
    TubeWarningCB: TCheckBox;
    TubeProfileCB: TCheckBox;
    TubeAlarmCB: TCheckBox;
    Panel1: TPanel;
    UpdateBtn: TSpeedButton;
    TagsGB: TGroupBox;
    BottomGB: TGroupBox;
    Pcount: TLabel;
    XChannelGB: TGroupBox;
    ChannelXCB: TRcComboBox;
    PCountSE: TSpinEdit;
    EstXcb: TCheckBox;
    ChannelYGB: TGroupBox;
    ChannelYCB: TRcComboBox;
    WrkPointLine: TEdit;
    AddlineBtn: TSpeedButton;
    Label1: TLabel;
    ProfileBtn: TButton;
    WpPointsCB: TCheckBox;
    PSizeLabel: TLabel;
    PSizeEdit: TFloatEdit;
    WpColor: TPanel;
    BackGroundColorDialog: TColorDialog;
    TagsListFrame1: TTagsListFrame;
    DrawLineCB: TCheckBox;
    GroupBox2: TGroupBox;
    MinYLabel: TLabel;
    MaxYLabel: TLabel;
    MinYfe: TFloatEdit;
    MaxYfe: TFloatEdit;
    LgYcb: TCheckBox;
    ProfileCB: TComboBox;
    GroupBox3: TGroupBox;
    LgXcb: TCheckBox;
    MaxXLabel: TLabel;
    MaxXfe: TFloatEdit;
    MinXLabel: TLabel;
    MinXfe: TFloatEdit;
    AddAxisBtn: TSpeedButton;
    EstYcb: TCheckBox;
    regularXCB: TCheckBox;
    dXfe: TFloatEdit;
    dxLabel: TLabel;
    NameEdit: TEdit;
    NameLabel: TLabel;
    TagsTV: TVTree;
    ImageList_32: TImageList;
    ImageList_16: TImageList;
    NameAxisEdit: TEdit;
    NameAxisLabel: TLabel;
    MaxXgraph: TFloatEdit;
    Label2: TLabel;
    Splitter1: TSplitter;
    procedure UpdateBtnClick(Sender: TObject);
    procedure GraphTypeRGClick(Sender: TObject);
    procedure AddlineBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TagsLBClick(Sender: TObject);
    procedure ProfileBtnClick(Sender: TObject);
    procedure ProfileCBChange(Sender: TObject);
    procedure WpColorClick(Sender: TObject);
    procedure TagsListFrame1FilterEditChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddAxisBtnClick(Sender: TObject);
    procedure TagsTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TagsTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure TagsTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TagsTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure regularXCBClick(Sender: TObject);
  private
  public
    curChart:TCntrlWrnChart;
    fcurWP:TWrkPoint;
    m_updateChannels:boolean;
    // удаленные раб. точки
    m_tempList:tlist;
    m_tempAxis:tlist;
  public
  private
    procedure setcurWp(w:TWrkPoint);
    function getcurWp:TWrkPoint;
    procedure updateopts;

    procedure showChartTags;
    procedure showWp;
    procedure createevents;
    procedure Destroyevents;
    // перенос настроенных графиков в чарт
    procedure SetWpToChart;
    procedure ShowSpmTags;
    procedure ShowAphTags;
    // ќ“ќЅ–ј«»“№ —ѕ»—ќ  ƒќ—“”ѕЌџ’ “≈√ќ¬
    procedure ShowProfiles;
    procedure ClearTempData;
    function selectAxis:cAxis;
    function getWpAxisNode(wp:TWrkPoint):pvirtualnode;
  public
    property curwp:TWrkPoint read getcurWp write setcurWp;
    procedure DoUpdateCfg(sender:tobject);
    procedure updateTagsList;
    procedure EditChart(chart:TCntrlWrnChart);
    destructor destroy;override;
    constructor create(aowner:tcomponent);override;
  end;

var
  EditCntlWrnFrm: TEditCntlWrnFrm;

implementation

{$R *.dfm}

{ TEditCntlWrnFrm }


function TEditCntlWrnFrm.getWpAxisNode(wp:TWrkPoint):pvirtualnode;
var
  i:integer;
  n:pvirtualnode;
  d:pnodedata;
begin
  result:=nil;
  for I := 0 to tagsTV.TotalCount - 1 do
  begin
    if I <> 0 then
      n := tagsTV.GetNext(n)
    else
      n := tagsTV.GetFirst;
    d:=tagsTV.GetNodeData(n);
    if d<>nil then
    begin
      if d.data<>nil then
      begin
        if tobject(d.data) is caxis then
        begin
          if d.data=wp.axis then
          begin
            result:=n;
            exit;
          end;
        end;
      end;
    end;
  end;
end;

function TEditCntlWrnFrm.selectAxis:cAxis;
var
  n:pvirtualnode;
  d:PNodeData;
begin
  n:=GetSelectNode(TagsTV);
  if n<>nil then
  begin
    d:=TagsTV.GetNodeData(n);
    if tobject(d.data) is caxis then
      result:=caxis(d.data)
    else
    begin
      d:=TagsTV.GetNodeData(n.parent);
      result:=caxis(d.data);
    end;
  end
  else
  begin
    if TagsTV.TotalCount>0 then
    begin
      n:=TagsTV.GetFirst();
      d:=TagsTV.GetNodeData(n);
      result:=caxis(d.data);
    end;
  end;
end;


procedure TEditCntlWrnFrm.AddAxisBtnClick(Sender: TObject);
var
  a:caxis;
  p:cpage;
  n:pvirtualnode;
  d:PNodeData;
begin
  p:=cpage(curChart.chart.activePage);
  a:=p.Newaxis;
  a.name:=NameAxisEdit.text;
  a.caption:=NameAxisEdit.text;
  a.min:=p2d(a.min.x,minyfe.FloatNum);
  a.max:=p2d(a.max.x,maxyfe.FloatNum);
  a.Lg:=LgYcb.Checked;
  n:=TagsTV.AddChild(nil);
  d:=TagsTV.GetNodeData(n);
  d.color:=tagstv.normalcolor;
  d.caption:=a.caption;
  d.Data:=a;
  d.ImageIndex:=a.imageindex;

  setlength(curChart.m_axises,length(curChart.m_axises)+1);
  curChart.m_axises[length(curChart.m_axises)-1].name:=a.caption;
  curChart.m_axises[length(curChart.m_axises)-1].min:=a.minY;
  curChart.m_axises[length(curChart.m_axises)-1].max:=a.maxY;
  curChart.m_axises[length(curChart.m_axises)-1].lg:=a.lg;

  TagsTV.Refresh;
end;

procedure TEditCntlWrnFrm.AddlineBtnClick(Sender: TObject);
Var
  wp:TWrkPoint;
begin
  if curChart.getWP(WrkPointLine.Text)=nil then
  begin
    wp:=TWrkPoint.create(curChart.Chart);
    wp.name:=WrkPointLine.text;
    curWP:=wp;
    curChart.addGraph(wp, selectAxis);
    WrkPointLine.text:=wp.name;
    showChartTags;
  end;
end;

procedure TEditCntlWrnFrm.ClearTempData;
var
  I, j: Integer;
  w:TWrkPoint;
  p:cpage;
  a:caxis;
begin
  for I := 0 to m_tempList.Count - 1 do
  begin
    w:=TWrkPoint(m_tempList.Items[i]);
    w.destroy;
  end;
  m_tempList.Clear;
  for I := 0 to m_tempAxis.Count - 1 do
  begin
    a:=caxis(m_tempAxis.Items[i]);
    if a=curChart.ProfileAxis then
    begin
      curChart.delProfile;
    end;
    p:=cpage(a.GetParentByClassName('cPage'));
    p.EnterCS;
    a.destroy;
    p.ExitCS;
  end;
  m_tempAxis.Clear;
end;

constructor TEditCntlWrnFrm.create(aowner: tcomponent);
begin
  inherited;
  m_tempList:=TList.Create;
  m_tempAxis:=TList.Create;
end;

procedure TEditCntlWrnFrm.createevents;
begin
  AddPlgEvent('TEditCntlWrnFrm_UpdateCfg', E_RC_ChangeCfg, DoUpdateCfg);
end;

procedure TEditCntlWrnFrm.Destroyevents;
begin
  RemovePlgEvent(DoUpdateCfg, E_RC_ChangeCfg);
end;


destructor TEditCntlWrnFrm.destroy;
begin
  m_tempList.Destroy;
  m_tempList:=nil;

  m_tempAxis.Destroy;
  m_tempAxis:=nil;

  Destroyevents;
  inherited;
end;

procedure TEditCntlWrnFrm.DoUpdateCfg(sender: tobject);
begin

end;

procedure TEditCntlWrnFrm.EditChart(chart: TCntrlWrnChart);
var
  i:integer;
  p:tprofile;
  page:cpage;
begin
  curChart:=chart;
  m_tempList.clear;
  m_tempAxis.clear;
  if chart<>nil then
  begin
    page:=cpage(chart.chart.activePage);
    NameEdit.text:=chart.name;
    MinXfe.FloatNum:=page.activeAxis.min.x;
    MaxXfe.FloatNum:=page.activeAxis.max.x;
    MinYfe.FloatNum:=page.activeAxis.min.y;
    MaxYfe.FloatNum:=page.activeAxis.max.y;
    lgXcb.Checked:=page.lgX;
    lgYcb.Checked:=page.activeAxis.lg;
    TubeProfileCB.Checked:=chart.ShowProfile;
    TubeWarningCB.Checked:=chart.ShowProfile;
    TubeAlarmCB.Checked:=chart.ShowAlarms;
    if curchart.chart.activePage<>nil then
      PSizeEdit.FloatNum:=cpage(curchart.chart.activePage).GetPointSize;

    ShowProfiles;

    updateTagsList;
    showChartTags;
    showmodal;
  end;
end;

procedure TEditCntlWrnFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  m_tempList.Clear;
  m_tempAxis.clear;
end;

procedure TEditCntlWrnFrm.FormCreate(Sender: TObject);
begin
  m_updateChannels:=true;
  createevents;
end;

function TEditCntlWrnFrm.getcurWp: TWrkPoint;
begin
  result:=fcurWP;
end;

procedure TEditCntlWrnFrm.setcurWp(w: TWrkPoint);
begin
  fcurWP:=w;
end;

procedure TEditCntlWrnFrm.GraphTypeRGClick(Sender: TObject);
begin
  updateTagsList;
end;

procedure TEditCntlWrnFrm.ProfileBtnClick(Sender: TObject);
var
  p:tprofile;
  I: Integer;
begin
  if profilecb.ItemIndex=-1 then
    p:=nil
  else
    p:=tprofile(profilecb.Items.Objects[profilecb.ItemIndex]);

  p:=EditProfileFrm.editProfile(p, cCtrlWrnFactory(curChart.m_f).m_pList);
  ShowProfiles;
  for I := 0 to ProfileCB.items.Count - 1 do
  begin
    if ProfileCB.Items.Objects[i]=p then
    begin
      ProfileCB.ItemIndex:=i;
      break;
    end;
  end;
end;

procedure TEditCntlWrnFrm.ProfileCBChange(Sender: TObject);
var
  p:tprofile;
begin
  //if ProfileCB.ItemIndex<>-1 then
  begin
    //p:=tprofile(profilecb.Items[ProfileCB.ItemIndex]);
    //curchart.Profile:=p;
  end;
end;

procedure TEditCntlWrnFrm.regularXCBClick(Sender: TObject);
begin
  dxfe.Enabled:=regularXCB.Checked;
  if regularXCB.Checked then
  begin
    dxfe.Color:=clWindow;
  end
  else
  begin
    dxfe.Color:=clGray;
  end;
end;

procedure TEditCntlWrnFrm.SetWpToChart;
var
  I: Integer;
  w, graphWp:TWrkPoint;
  j: Integer;
  add:boolean;
  n, parentnode:pVirtualNode;
  d:PNodeData;
begin
  curchart.clearwp;
  for I := 0 to tagsTV.TotalCount - 1 do
  begin
    if I <> 0 then
      n := tagsTV.GetNext(n)
    else
      n := tagsTV.GetFirst;
    d:=tagsTV.GetNodeData(n);
    if d<>nil then
    begin
      if tobject(d.data) is TWrkPoint then
      begin
        w:=TWrkPoint(d.data);
        add:=true;
        for j := 0 to curChart.GraphCount - 1 do
        begin
          graphWp:=curChart.getWP(j);
          if graphWp=w then
          begin
            add:=false;
            break;
          end;
        end;
        if add then
        begin
          d:=tagsTV.GetNodeData(n.Parent);
          curchart.addGraph(w,caxis(d.data));
        end;
      end;
    end;
  end;
end;

procedure TEditCntlWrnFrm.ShowAphTags;
var
  I: Integer;
begin
  for I := 0 to curChart.graphcount - 1 do
  begin

  end;
end;

procedure TEditCntlWrnFrm.showChartTags;
var
  i:integer;
  wp:TWrkPoint;
  p:cpage;
  a:caxis;
  node:pvirtualnode;
  d:pnodedata;
  j: Integer;
begin
  tagstv.clear;
  p:=cpage(curChart.chart.activePage);
  for I := 0 to p.getAxisCount - 1 do
  begin
    a:=p.getaxis(i);
    node:=tagstv.AddChild(nil);
    d:=tagstv.GetNodeData(node);
    d.color:=tagstv.normalcolor;
    d.caption:=a.caption;
    d.Data:=a;
    d.ImageIndex:=a.imageindex;
  end;
  for I := 0 to curChart.GraphCount - 1 do
  begin
    wp:=curChart.getWP(i);
    node:=getWpAxisNode(wp);
    if node<>nil then
    begin
      node:=tagstv.AddChild(node);
      d:=tagstv.GetNodeData(node);
      d.color:=tagstv.normalcolor;
      d.caption:=wp.name;
      d.Data:=wp;
      // лини€
      d.ImageIndex:=22;
      curWP:=wp;
    end;
  end;
end;


procedure TEditCntlWrnFrm.ShowProfiles;
var
  p:tprofile;
  i:integer;
begin
  ProfileCB.Clear;
  p:=nil;
  for I := 0 to cCtrlWrnFactory(curChart.m_f).m_pList.count - 1 do
  begin
    p:=cCtrlWrnFactory(curChart.m_f).m_pList.getprof(i);
    ProfileCB.AddItem(p.name,p);
  end;
  if p<>nil then
    setComboBoxItem(p.name,ProfileCB);
end;

procedure TEditCntlWrnFrm.ShowSpmTags;
begin

end;

procedure TEditCntlWrnFrm.showWp;
begin

end;

procedure TEditCntlWrnFrm.TagsLBClick(Sender: TObject);
begin
  updateopts;
end;

procedure TEditCntlWrnFrm.TagsListFrame1FilterEditChange(Sender: TObject);
begin
  TagsListFrame1.FilterEditChange(Sender);

end;

procedure TEditCntlWrnFrm.TagsTVChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  updateopts;
end;

procedure TEditCntlWrnFrm.TagsTVDragDrop(Sender: TBaseVirtualTree;
                                         Source: TObject;
                                         DataObject: IDataObject;
                                         Formats: TFormatArray;
                                         Shift: TShiftState;
                                         Pt: TPoint;
                                         var Effect:Integer;
                                         Mode: TDropMode);
var
  pSource, pTarget: PVirtualNode;
  attMode: TVTNodeAttachMode;
  dstdata,srcdata:pnodedata;
  w:TWrkPoint;
  a:caxis;
  n:pvirtualnode;
  d:PNodeData;

  li:tlistitem;
  t, taho:itag;
  alg:cBaseAlgcontainer;
begin
  if source=TagsListFrame1.TagsLV then
  begin
    li:=TagsListFrame1.TagsLV.Selected;
    while li<>Nil do
    begin
      t:=itag(li.data);
      w:=TWrkPoint.create(curChart.Chart);
      w.name:=t.GetName;
      w.m_YParam.tag:=t;
      alg:=g_algMng.getAlgByTagName(t.GetName);
      if alg<>nil then
      begin
        if alg is cGrmsSrcAlg then
        begin
          if cGrmsSrcAlg(alg).m_Taho.tag<>nil then
          begin
            taho:=g_algMng.getOutTagByInTagName(cGrmsSrcAlg(alg).m_Taho.tagname);
            if taho<>nil then
              w.m_XParam.tag:=taho;
          end;
        end;
      end;

      curChart.addGraph(w, selectAxis);
      WrkPointLine.text:=w.name;
      li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
    end;
    showChartTags;
    exit;
  end;
  pSource := TVirtualStringTree(Source).FocusedNode;
  pTarget := Sender.DropTargetNode;


  srcdata:=tagstv.GetNodeData(pSource);
  if tobject(srcdata.data) is TWrkPoint then
  begin
    w:=TWrkPoint(srcdata.data);
  end;
  dstdata:=tagstv.GetNodeData(pTarget);
  if tobject(dstdata.data) is caxis then
  begin
    a:=caxis(dstdata.data);
  end
  else
  begin
    if tobject(dstdata.data) is TWrkPoint then
    begin
      ptarget:=ptarget.Parent;
      dstdata:=tagstv.GetNodeData(pTarget);
      if tobject(dstdata.data) is caxis then
      begin
        a:=caxis(dstdata.data);
      end;
    end;
  end;

  if w.axis<>a then
  begin
    w.axis:=a;
    n:=TVirtualStringTree(Source).AddChild(pTarget);
    d:=TagsTV.GetNodeData(n);
    d.color:=tagstv.normalcolor;
    d.caption:=w.name;
    d.Data:=w;
    // лини€
    d.ImageIndex:=22;
    curWP:=w;
    TagsTV.DeleteNode(pSource);
  end;
end;

procedure TEditCntlWrnFrm.TagsTVDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
var
  pSource, pTarget:PVirtualNode;
  dstdata,srcdata:pnodedata;
  w:TWrkPoint;
  a:caxis;
begin
  Accept := false;
  if Source = TagsListFrame1.TagsLV then
  begin
    Accept := true;
    exit;
  end;
  if Source = tagstv then
  begin
    pSource := TVirtualStringTree(Source).FocusedNode;
    pTarget := Sender.DropTargetNode;
    if pTarget=nil then
      exit;
    srcdata:=tagstv.GetNodeData(pSource);
    if tobject(srcdata.data) is TWrkPoint then
    begin
      w:=TWrkPoint(srcdata.data);
    end;
    dstdata:=tagstv.GetNodeData(pTarget);
    if tobject(dstdata.data) is caxis then
    begin
      a:=caxis(dstdata.data);
    end
    else
    begin
      if tobject(dstdata.data) is TWrkPoint then
      begin
        ptarget:=ptarget.Parent;
        dstdata:=tagstv.GetNodeData(pTarget);
        if tobject(dstdata.data) is caxis then
        begin
          a:=caxis(dstdata.data);
        end;
      end;
    end;
    if w.axis<>a then
      Accept := true;
  end;
end;

procedure TEditCntlWrnFrm.TagsTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  next, n: PVirtualNode;
  d, parentdata: PNodeData;
  I, j: Integer;
  obj: cbaseobj;
  a:caxis;
  axInd,
  axisCount:integer;
  axSettings:taxis;
  err:boolean;
  tempAxis:ARRAY of taxis;
begin
  if Key <> VK_DELETE then
    exit;
  // помечаем удаленные линии и оси
  for I := 0 to tagsTV.TotalCount - 1 do
  begin
    if I <> 0 then
      n := tagsTV.GetNext(n)
    else
      n := tagsTV.GetFirst;
    d:=TagsTV.GetNodeData(n);
    if (vsselected in n.states) or childselected(n, tagstv) or parentselected(n, tagstv) then
    begin
      if tobject(d.data) is caxis then
      begin
        m_tempAxis.add(d.data);
      end;
      if tobject(d.data) is TWrkPoint then
      begin
        m_tempList.add(d.data);
      end;
    end;
  end;

  tagsTV.DeleteSelectedNodes;

  axisCount:=length(curChart.m_axises);
  setlength(tempAxis, axisCount);
  move(curChart.m_axises[0], tempAxis[0], axisCount* sizeof(taxis));
  for I := 0 to axisCount - 1 do
  begin
    tempAxis[0].acitive:=false;
  end;
  // помечаем не удаленные оси и считаем сколько осей осталось
  axisCount:=0;
  for I := 0 to tagsTV.TotalCount - 1 do
  begin
    if I <> 0 then
      n := tagsTV.GetNext(n)
    else
      n := tagsTV.GetFirst;
    d:=TagsTV.GetNodeData(n);
    if tobject(d.data) is caxis then
    begin
      inc(axiscount);
      axSettings:=curChart.getDefAxisSettings(caxis(d.data),err,axInd);
      tempAxis[axInd].acitive:=true;
    end;
  end;
  setlength(curChart.m_axises, axiscount);
  // переносим настройки живых осей
  j:=0;
  axInd:=0;
  for I := 0 to length(tempAxis) - 1 do
  begin
    if tempAxis[i].acitive then
    begin
      curChart.m_axises[axInd]:=tempAxis[i];
      inc(axInd);
    end;
  end;


end;

procedure TEditCntlWrnFrm.UpdateBtnClick(Sender: TObject);
var
  I, j: Integer;
  find:boolean;
  w:TWrkPoint;
  n:PVirtualNode;
  d:pnodedata;
  a:caxis;
  AxOpts:Taxis;
  err:boolean;
  ind:integer;
begin
  a:=nil;
  if curchart<>nil then
  begin
    ClearTempData;
    curchart.name:=NameEdit.text;

    curchart.m_XminDefault:=MinXfe.FloatNum;
    curchart.m_XmaxDefault:=MaxXfe.FloatNum;
    curchart.lgX:=LgXcb.Checked;

    curchart.ShowProfile:=TubeProfileCB.Checked;
    curchart.ShowWarnings:=TubeWarningCB.Checked;
    curchart.ShowAlarms:=TubeAlarmCB.Checked;
    curchart.psize:=PSizeEdit.FloatNum;

    if profilecb.ItemIndex<>-1 then
      curchart.profile:=tprofile(profilecb.Items.Objects[profilecb.ItemIndex]);

    for I := 0 to TagsTV.TotalCount - 1 do
    begin
      if I <> 0 then
        n := tagsTV.GetNext(n)
      else
        n := tagsTV.GetFirst;
      d:=tagsTV.GetNodeData(n);
      if tobject(d.data) is caxis then
      begin
        if (vsSelected in n.States) or ChildSelected(n, tagsTV) then
        begin
          a:=caxis(d.data);
          AxOpts:=curChart.getDefAxisSettings(a, err ,ind);
          AxOpts.name:=NameAxisEdit.text;
          AxOpts.Lg:=lgycb.Checked;
          AxOpts.min:=minyfe.FloatNum;
          AxOpts.max:=maxyfe.FloatNum;
          curchart.m_axises[ind]:=axOpts;
          a.name:=NameAxisEdit.text;
          a.caption:=NameAxisEdit.text;
          d.Caption:=NameAxisEdit.text;
        end;
      end;
      if tobject(d.data) is TWrkPoint then
      begin
        if vsSelected in n.States then
        begin
          w:=TWrkPoint(d.data);
          if WrkPointLine.text<>'' then
          begin
            w.name:=WrkPointLine.text;
            d.Caption:=WrkPointLine.text;
          end;
          if ChannelXCB.ItemIndex<>-1 then
          begin
            w.m_XParam.tag:=ChannelXCB.gettag(ChannelXCB.ItemIndex);
          end;
          if ChannelYCB.ItemIndex<>-1 then
          begin
            w.m_YParam.tag:=ChannelXCB.gettag(ChannelYCB.ItemIndex);
          end;
          if EstXcb.State <> cbGrayed then
            w.m_estimateX:=EstXcb.checked;
          if EstYcb.State <> cbGrayed then
            w.m_estimateY:=EstYcb.checked;
          if PCountSE.text<>'' then
            w.PCount:=PCountSE.Value;

          w.PColor:=inttoRGB(WPColor.Color);
          w.DrawPoints:=WpPointsCB.checked;
          w.DrawLine:=DrawLineCB.Checked;

          w.m_regularX:=regularXCB.Checked;
          w.m_dx:=dXfe.FloatNum;
          w.m_maxX:=MaxXgraph.FloatNum;
        end;
      end;
    end;
  end;
  SetWpToChart;
  curchart.UpdateOpts;
  curchart.chart.redraw;
end;

procedure TEditCntlWrnFrm.updateopts;
var
  i,j:integer;
  w:TWrkPoint;
  a:caxis;
  next, Node: PVirtualNode;
  Data, parentdata: PNodeData;
begin
  i:=0;
  j:=0;

  Node := tagsTV.GetFirstSelected(true);
  while Node <> nil do
  begin
    Data := tagsTV.GetNodeData(Node);
    if tobject(Data.Data) is TWrkPoint then
    begin
      w:=TWrkPoint(Data.Data);
      SetMultiSelectComponentString(ChannelXCB, w.m_XParam.tagname);
      SetMultiSelectComponentString(ChannelYCB, w.m_YParam.tagname);
      SetMultiSelectComponentString(WrkPointLine, w.name);
      SetMultiSelectComponentBool(EstXcb, w.m_estimateX);
      SetMultiSelectComponentBool(EstYcb, w.m_estimateY);
      SetMultiSelectComponentString(PCountSE, inttostr(w.PCount));
      SetMultiSelectComponentBool(WpPointsCB, w.DrawPoints);
      SetMultiSelectComponentBool(DrawLineCB, w.DrawLine);
      SetMultiSelectComponentBool(regularXCB, w.m_regularX);
      SetMultiSelectComponentString(dXfe, floattostr(w.m_dx));
      WPColor.Color:=rgbtoint(w.PColor);
      if w.axis<>nil then
      begin
        SetMultiSelectComponentString(NameAxisEdit, w.axis.caption);
        SetMultiSelectComponentString(MinYfe, floattostr(w.axis.min.y));
        SetMultiSelectComponentString(MaxYfe, floattostr(w.axis.max.y));
      end;
    end;
    if tobject(Data.Data) is caxis then
    begin
      a:=caxis(Data.Data);
      SetMultiSelectComponentbool(lgycb, a.lg);
      SetMultiSelectComponentString(NameAxisEdit, a.caption);
      SetMultiSelectComponentString(MinYfe, floattostr(a.min.y));
      SetMultiSelectComponentString(MaxYfe, floattostr(a.max.y));
    end;
    next := tagsTV.GetNextSelected(Node, true);
    Node := next;
    inc(I);
  end;
  endMultiSelect(lgycb);
  endMultiSelect(NameAxisEdit);
  endMultiSelect(dXfe);
  endMultiSelect(regularXCB);
  endMultiSelect(WpPointsCB);
  endMultiSelect(EstXcb);
  endMultiSelect(EstYcb);
  endMultiSelect(PCountSE);
  endMultiSelect(ChannelXCB);
  endMultiSelect(ChannelYCB);
  endMultiSelect(WrkPointLine);
  endMultiSelect(MinYfe);
  endMultiSelect(MaxYfe);
end;

procedure TEditCntlWrnFrm.updateTagsList;
var
  I, ind: Integer;
  ir: IRecorder;
  t: iTag;
  tname: string;
  li: TListItem;
begin
  ir := getIR;
  // обновл€ем список каналов
  TagsListFrame1.ShowChannels;
  ChannelXCB.updateTagsList;
  ChannelYCB.updateTagsList;
  m_updateChannels:=false;
end;

procedure TEditCntlWrnFrm.WpColorClick(Sender: TObject);
begin
  if BackGroundColorDialog.Execute then
    tpanel(sender).color:=BackGroundColorDialog.Color;
end;

end.
