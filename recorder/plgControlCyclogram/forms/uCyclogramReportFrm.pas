unit uCyclogramReportFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, VirtualTrees,  StdCtrls, ExtCtrls,
  ubaseobj, uComponentServises, uVTServices,
  uCommonMath, ComCtrls, uBtnListView, uPage, uCommonTypes,
  uControlObj, uBaseObjService, uEventTypes,
  PluginClass, recorder, uRcCtrls, uRCFunc, uRvclService, tags,
  uRTrig, uTagsListFrame, utrend, uaxis, uPoint, uListMath,
  uChart, usetlist;

type
  TCyclogramReportFrm = class(TForm)
    LeftPan: TPanel;
    CyclogramGB: TGroupBox;
    TrigsGB: TGroupBox;
    ProgramTV: TVTree;
    TrigTV: TVTree;
    ImageList16: TImageList;
    TrigsImages16: TImageList;
    ImageList_16: TImageList;
    alPanel: TPanel;
    GroupBox1: TGroupBox;
    cChart1: cChart;
    ControlsLV: TBtnListView;
    ApplyBtn: TButton;
    CustomViewCB: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ControlsLVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ControlsLVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ApplyBtnClick(Sender: TObject);
  private
    eventsCreated:boolean;
    CfgChanged:boolean;
    frm:tform;
    m_p:cprogramobj;

    notSelItems, selitems:tlist;
  private
    procedure createEvents;
    procedure destroyEvents;
    procedure OnChangeConfig(sender:tobject);
    procedure ShowProgram(p:cprogramobj);
    function showControlInChart(con:ccontrolobj; p:cprogramObj):ctrend;
    procedure addpoint(tr:ctrend;t:ctask);
  private
    procedure ShowTrigs;
    procedure ShowControls(p:cprogramobj);
    function getControl(i:integer):cControlObj;
  public
    procedure setfrm(f:tform);
    procedure ShowConfig;
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

var
  CyclogramReportFrm: TCyclogramReportFrm;

implementation
uses
  uControlDeskFrm;

{$R *.dfm}

{ TCyclogramReportFrm }

procedure TCyclogramReportFrm.addpoint(tr: ctrend; t: ctask);
var
  prev:cTask;
  prevval:double;
  bp:cBeziePoint;
begin
  case t.TaskType of
    ptNullPoly:
    begin
      bp:=cBeziePoint.create;
      case t.TaskType of
        ptNullPoly: bp.PType:=ptNullPoly;
        ptLinePoly: bp.PType:=ptLinePoly;
        ptCubePoly: bp.PType:=ptCubePoly;
      end;
      bp.point:=p2(t.mode.gettimeinterval.x,t.task);
      tr.AddPoint(bp);
    end;
    ptLinePoly:
    begin
      bp:=cBeziePoint.create;
      case t.TaskType of
        ptNullPoly: bp.PType:=ptNullPoly;
        ptLinePoly: bp.PType:=ptLinePoly;
        ptCubePoly: bp.PType:=ptCubePoly;
      end;
      bp.point:=p2(t.mode.gettimeinterval.x,t.task);
      bp.left:=t.leftTang;
      bp.right:=t.rightTang;
      tr.AddPoint(bp);
    end;
    ptCubePoly:
    begin
      bp:=cBeziePoint.create;
      case t.TaskType of
        ptNullPoly: bp.PType:=ptNullPoly;
        ptLinePoly: bp.PType:=ptLinePoly;
        ptCubePoly: bp.PType:=ptCubePoly;
      end;
      bp.point:=p2(t.mode.gettimeinterval.x,t.task);
      bp.left:=t.leftTang;
      bp.right:=t.rightTang;
      tr.AddPoint(bp);
    end;
  end;
end;

function TCyclogramReportFrm.showControlInChart(con:ccontrolobj; p:cprogramObj):ctrend;
var
  I, ind: Integer;
  m:cmodeobj;
  t:ctask;
  tr:ctrend;
  page:cpage;
  ax:caxis;
begin
  tr:=nil;
  ax:=nil;
  if p=nil then
    exit;
  page:=cpage(cChart1.activePage);
  if page<>nil then
  begin
    page.Caption:=p.name;
  end
  else
  begin
    exit;
  end;
  for I := 0 to p.ModeCount - 1 do
  begin
    if i>32 then
      break;
    m:=p.getMode(i);
    t:=m.gettask(con.name);
    if t<>nil then
    begin
      if tr=nil then
      begin
        page:=cpage(cChart1.activePage);
        if page<>nil then
        begin
          ax:=page.getaxis(con.units);
          if ax=nil then
          begin
            ax:=page.Newaxis;
            ax.name:=con.units;
            ax.m_YUnits:=ax.name;
            //page.addaxis(ax);
          end;
          tr:=ax.AddTrend;
          // �������� �������� ����������� ������� ������ �� ����� ������
          tr.enabled:=true;
          ind:=ax.childcount;
          if ind>length(ColorArray)-1 then
          begin
            ind:=length(ColorArray)-1;
          end;
          tr.color:= ColorArray[ind];
          tr.name:=con.name;
          tr.m_userdata:=con;
          tr.locked:=true;
          tr.selectable:=false;
        end
        else
        begin
          exit;
        end;
      end;
      addpoint(tr,t);
    end;
  end;
  if ax<>nil then
    page.Normalise(ax);
end;

procedure TCyclogramReportFrm.ShowProgram(p: cprogramobj);
var
  I: Integer;
  con:ccontrolobj;
begin
  if cchart1.initGl then
  begin
    cpage(cchart1.activePage).clear;
    for I := 0 to p.ControlCount - 1 do
    begin
      con:=getControl(i);
      showControlInChart(con, p);
    end;
    ShowControls(p);
  end;
end;

procedure TCyclogramReportFrm.ShowControls(p:cprogramobj);
var
  I: Integer;
  con:ccontrolobj;
  li:tlistitem;
begin
  ControlsLV.Clear;
  for I := 0 to p.ControlCount - 1 do
  begin
    con:=getControl(i);
    li:=ControlsLV.Items.Add;
    li.Data:=con;
    ControlsLV.SetSubItemByColumnName('�', inttostr(i), li);
    ControlsLV.SetSubItemByColumnName('���������', con.name, li);
  end;
end;

procedure TCyclogramReportFrm.ShowTrigs;
var
  I: Integer;
  t: cBaseTrig;
begin
  TrigTV.Clear;
  for I := 0 to g_conmng.TrigCount - 1 do
  begin
    t := g_conmng.getTrig(I);
    if t.Parent = nil then
    begin
      if t.m_actions <> nil then
      begin
        ShowBaseObjectInVTreeView(TrigTV, t, nil);
      end;
    end;
  end;
end;

procedure TCyclogramReportFrm.ApplyBtnClick(Sender: TObject);
var
  I: Integer;
begin
  TControlDeskFrm(frm).m_CustSort:=CustomViewCB.Checked;
  TControlDeskFrm(frm).m_ViewControls.clear;
  for I := 0 to ControlsLV.Items.Count - 1 do
  begin
    TControlDeskFrm(frm).m_ViewControls.add(ControlsLV.Items[i].Data);
  end;
  TControlDeskFrm(frm).ShowModeTable;
end;

procedure TCyclogramReportFrm.ControlsLVDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  sli,li:tlistitem;
  con:cControlObj;
  r:TRect;
  newpos, shift, j:integer;

  NodeList:array of pointer;
  I: Integer;
begin
  // �������������� ������ item �� drag drop-�
  li:=ControlsLV.GetItemAt(x,y); // ���������� ���� �������
  sli:=ControlsLV.Selected; // ���������� ������ �������
  // ��������� ����� ���� �������, ���� ����� �� ������� ����������
  r:=ControlsLV.Items[ControlsLV.Items.Count - 1].DisplayRect(drBounds);
  if li<>nil then
  begin
    newpos:=li.index;
  end
  else
  begin
    // ����� ���������� � ������������ ���������, ������� ������� 0
    if y>r.Bottom then
      newpos:=ControlsLV.Items.Count
    else
    begin
      newpos:=0;
    end;
  end;
  if newpos=sli.index then
    exit;
  // NodeList - ������ ��� ����� ����������
  setlength(NodeList, ControlsLV.items.count);
  selitems.Clear;
  notSelItems.Clear;
  j:=0;
  for I := 0 to ControlsLV.Items.Count-1 do
  begin
    if (j<newpos) and (not ControlsLV.Items[i].Selected) then
    begin
      NodeList[j]:=ControlsLV.Items[i].data;
      inc(j);
    end
    else
    begin
      li:=ControlsLV.Items[i];
      if li.Selected then
        selitems.Add(li.Data)
      else
        notSelItems.Add(li.Data);
    end;
  end;

  for I := 0 to selitems.Count-1 do
  begin
    j:=i+newpos;
    NodeList[j]:=selitems.items[i];
  end;
  inc(j);
  for I := 0 to notSelItems.Count-1 do
  begin
    NodeList[j+i]:=notSelItems.items[i];
  end;
  // ������������� �������� LV
  ControlsLV.Clear;
  for I := 0 to length(NodeList) - 1 do
  begin
    con:=ccontrolobj(NodeList[i]);
    li:=ControlsLV.Items.Add;
    li.Data:=con;
    ControlsLV.SetSubItemByColumnName('�', inttostr(i), li);
    ControlsLV.SetSubItemByColumnName('���������', con.name, li);
  end;
end;

procedure TCyclogramReportFrm.ControlsLVDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if source=ControlsLV then
  begin
     Accept:=true;
  end;
end;

constructor TCyclogramReportFrm.create(aowner: tcomponent);
begin
  inherited;
  notSelItems:=tlist.Create;
  SelItems:=tlist.Create;
end;

destructor TCyclogramReportFrm.destroy;
begin
  notSelItems.Destroy;
  SelItems.Destroy;
  inherited;
end;

procedure TCyclogramReportFrm.createEvents;
begin
  if g_conmng<>nil then
  begin
    if not eventsCreated then
    begin
      eventsCreated:=true;
      g_conmng.Events.AddEvent('TCyclogramReportFrm_UpdateCfg',
                      E_OnEngUpdateList+E_OnChangeCfg,
                      OnChangeConfig);
    end;
  end;
end;



procedure TCyclogramReportFrm.destroyEvents;
begin
  if g_conmng<>nil then
    g_conmng.Events.removeEvent(OnChangeConfig, E_OnEngUpdateList+E_OnChangeCfg);
end;

procedure TCyclogramReportFrm.FormCreate(Sender: TObject);
begin
  eventsCreated:=false;
  CfgChanged:=true;
  if g_conmng.configChanged then
    CfgChanged:=true;
end;

procedure TCyclogramReportFrm.FormShow(Sender: TObject);
begin
  ShowConfig;
  CfgChanged:=false;
end;

procedure TCyclogramReportFrm.OnChangeConfig(sender: tobject);
begin

end;

procedure TCyclogramReportFrm.setfrm(f:tform);
begin
  frm:=f;
end;

function TCyclogramReportFrm.getControl(i:integer):cControlObj;
begin
  result:=TControlDeskFrm(frm).getProgControl(m_p, i);
end;

procedure TCyclogramReportFrm.ShowConfig;
var
  p:cprogramobj;
begin
  showInVTreeView(ProgramTV, g_conmng.programs, ImageList16);
  ShowTrigs;
  p:=g_conmng.getProgram(0);
  m_p:=p;
  CustomViewCB.Checked:=TControlDeskFrm(frm).m_CustSort;
  if p<>nil then
  begin
    ShowProgram(p);
  end;
  CfgChanged:=false;
end;



end.
