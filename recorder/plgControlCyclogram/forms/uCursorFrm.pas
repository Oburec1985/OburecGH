unit uCursorFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, uDoubleCursor, uEditProfileFrm, u2dmath,
  uRecorderEvents, ubaseObj, uCommonTypes, uPathMng, NativeXML, tags,
  uRTrig, uRCFunc, ubasealg, uBuffTrend1d, upage, utextlabel, uaxis, utrend,
  PluginClass, ImgList, uChart, uGrmsSrcAlg, uPhaseAlg, usetlist, uBasicTrend,
  uSpmChart, uControlWarnFrm;

type
  TCursorFrm = class(TRecFrm)
    LV: TBtnListView;
    Panel1: TPanel;
    procedure LVClick(Sender: TObject);
    procedure LVEnter(Sender: TObject);
  protected
    // реальный X курсора с поправкой на логарифм по осис X
    realX:double;
    m_Init:boolean;
    activChart:cChart;
  protected
  protected
    procedure AddToLegend(tr:cbasictrend; x:double);
    procedure SetX(p:cpage; x:double);
    procedure doMoveCursor(sender:tobject);
    procedure DoCreate; override;
    procedure createevents;
    procedure destroyevents;
  public
    procedure doSetActChart(sender:tobject);
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    destructor destroy; override;
  public
  end;

  ICursorFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cCursorFactory = class(cRecBasicFactory)
  private
    m_counter: integer;
    procedure AddEvents;
  protected
    procedure doDestroyForms; override;
    procedure CreateEvents;
    procedure DestroyEvents;
    procedure doChangeRState(Sender: TObject);
    procedure doStart;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

const
  c_Pic = 'CURSORFRM';
  c_Name = 'Курсор+легенда';

  c__defXSize = 400;
  c__defYSize = 400;

  // ctrl+shift+G
  //['{AFD1E769-17DD-4E41-A0C0-9B8770C77448}']
  IID_CURSORFRM: TGuid = (D1: $AFD1E769; D2: $17DD; D3: $4E41;
    D4: ($A0, $C0, $9B, $87, $70, $C7, $74, $48));

  c_col_name = 'Название';
  c_col_val = 'Значение';
  c_col_No = '№';

var
  g_CursorFrm: TCursorFrm;
  g_CursorFactory: cCursorFactory;


implementation


{$R *.dfm}

{ TCursorFrm }

function getpage(s:tobject):cpage;
begin
  result:=nil;
  if s is TSpmChart then
  begin
    result:=cpage(TSpmChart(s).spmChart.activePage);
  end;
  if s is TCntrlWrnChart then
  begin
    result:=cpage(TCntrlWrnChart(s).Chart.activePage);
  end;
end;


procedure TCursorFrm.AddToLegend(tr: cbasictrend; x:double);
var
  i:integer;
  li:tlistitem;
  v:double;
begin
  li:=nil;
  for I := 0 to lv.Items.Count - 1 do
  begin
    if lv.Items[i].data=tr then
    begin
      li:=lv.Items[i];
      break;
    end;
  end;
  if li=nil then
  begin
    if not tr.fHelper then
    begin
      li:=lv.Items.add;
      li.data:=tr;
    end
    else
      exit;
  end;
  v:=tr.GetY(x);
  LV.SetSubItemByColumnName(c_col_No,inttostr(li.index),li);
  LV.SetSubItemByColumnName(c_col_val, floattostr(v),li);
  LV.SetSubItemByColumnName(c_col_name, tr.name,li);
  //lv.addColorItem(li.index, rgbtoint(tr.color));
end;

procedure TCursorFrm.createevents;
begin
  if g_spmfactory<>nil then
  begin
    m_Init:=true;
    g_spmfactory.EList.AddEvent('cSpmFactory_CursorMove_'+inttostr(g_CursorFactory.count),
                                  E_CURSMOVE, doMoveCursor);
    g_spmfactory.EList.AddEvent('cSpmFactory_SetActChart_'+inttostr(g_CursorFactory.count),
                                  E_SETACTSPMCHART, doSetActChart);
  end;
end;

procedure TCursorFrm.destroyevents;
begin
  if g_spmfactory<>nil then
  begin
    g_spmfactory.EList.removeEvent(doSetActChart, E_SETACTSPMCHART);
    g_spmfactory.EList.removeEvent(doMoveCursor, E_CURSMOVE);
  end;
end;

destructor TCursorFrm.destroy;
begin
  LogRecorderMessage('TCursorFrm.destroy_enter', false);
  destroyevents;
  inherited;
  LogRecorderMessage('TCursorFrm.destroy_exit', false);
end;

function GetColor(li:tlistitem):integer;
begin
  result:=clblack;
  if li.Data<>nil then
  begin
    result:=RGBtoInt(cBasicTrend(li.data).color);
  end;
end;

procedure  TCursorFrm.docreate;
begin
  inherited;
  lv.getcolor:=GetColor;
  lv.ChangeTextColor:=true;
  m_Init:=false;
  createevents;
  g_CursorFrm:=self;
end;

procedure TCursorFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;
  if not m_Init then
  begin
    createevents;
  end;
end;

procedure TCursorFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;
end;

procedure TCursorFrm.LVClick(Sender: TObject);
var
  p:cpage;
  li:tlistitem;
  str:string;
  tr:cbasictrend;
  c:cDoubleCursor;
begin
  li:=LV.Selected;
  if li<>nil then
  begin
    p:=getpage(g_SpmFactory.actchart);
    lv.GetSubItemByColumnName(c_col_name,li, str);
    if p<>nil then
    begin
      tr:=cbasictrend(p.getChildrenByName(str));
      c:=p.cursor;
      if tr<>nil then
      begin
        c.magniteObj:=tr;
      end;
    end;
  end;
end;


procedure TCursorFrm.LVEnter(Sender: TObject);
begin
  LV.clear;
end;

procedure TCursorFrm.SetX(p:cpage; x: double);
var
  c:cDoubleCursor;
  chart:cchart;
  li:tlistitem;
  I, j: Integer;
  ax:caxis;
  obj:cbaseobj;
  tr:cbasictrend;
begin
  if p=nil then exit;
  c:=p.cursor;
  if p.LgX then
    realX:=c.LinearToLgPos(x)
  else
    realx:=x;
  if LV.Items.count=0 then
    li:=LV.Items.add
  else
    li:=LV.Items[0];
  LV.SetSubItemByColumnName(c_col_val, floattostr(realX),li);
  LV.SetSubItemByColumnName(c_col_name, 'X:',li);
  LV.SetSubItemByColumnName(c_col_No,'0',li);
end;

procedure TCursorFrm.doSetActChart(sender: tobject);
var
  c:cDoubleCursor;
  chart:cchart;
  p:cPage;
  li:tlistitem;
  I, j: Integer;
  ax:caxis;
  obj:cbaseobj;
  tr:cbasictrend;
  x:double;
begin
  activChart:=cchart(sender);
  p:=getpage(sender);
  if p=nil then exit;
  lv.Clear;

  c:=p.cursor;
  x:=c.getx1;
  SetX(p, x);

  for I := 0 to p.getAxisCount- 1 do
  begin
    ax:=p.getaxis(i);
    for j := 0 to ax.ChildCount - 1 do
    begin
      obj:=ax.getChild(j);
      if obj is cbasictrend then
      begin
        tr:=cBasicTrend(obj);
        AddToLegend(tr, realx);
      end;
    end;
  end;
  LVChange(lv);
end;

procedure TCursorFrm.doMoveCursor(sender: tobject);
var
  c:cDoubleCursor;
  p:cPage;
  li:tlistitem;
  I, j: Integer;
  ax:caxis;
  obj:cbaseobj;
  tr:cbasictrend;
  x:double;
begin
  p:=getpage(sender);
  if p=nil then exit;

  c:=p.cursor;
  x:=c.getx1;
  SetX(p,x);

  for I := 0 to p.getAxisCount- 1 do
  begin
    ax:=p.getaxis(i);
    for j := 0 to ax.ChildCount - 1 do
    begin
      obj:=ax.getChild(j);
      if obj is cbasictrend then
      begin
        tr:=cBasicTrend(obj);
        AddToLegend(tr, realx);
      end;
    end;
  end;
  LVChange(lv);
end;

{ ICursorFrm }
procedure ICursorFrm.doClose;
begin
  m_lRefCount := 1;
end;

function ICursorFrm.doCreateFrm: TRecFrm;
begin
  result := TCursorFrm.create(nil);
end;

function ICursorFrm.doGetName: LPCSTR;
begin
  result:=c_Name;
end;

function ICursorFrm.doRepaint: boolean;
begin

end;

{ cCursorFactory }

procedure cCursorFactory.AddEvents;
begin

end;

constructor cCursorFactory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_CURSORFRM;
  CreateEvents;
end;

procedure cCursorFactory.CreateEvents;
begin

end;

destructor cCursorFactory.destroy;
begin
  inherited;
end;

procedure cCursorFactory.DestroyEvents;
begin

end;

procedure cCursorFactory.doChangeRState(Sender: TObject);
begin

end;

function cCursorFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := ICursorFrm.create();
  end;
end;

procedure cCursorFactory.doDestroyForms;
begin

end;

procedure cCursorFactory.doSetDefSize(var pSize: SIZE);
begin
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

procedure cCursorFactory.doStart;
begin

end;

end.
