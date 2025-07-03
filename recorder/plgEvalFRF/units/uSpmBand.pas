unit uSpmBand;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, uDoubleCursor, uChartEvents, uLabel,
  uRecorderEvents, ubaseObj, uCommonTypes,
  uRCFunc, uBuffTrend1d, upage, utextlabel, uaxis, utrend,
  PluginClass, ImgList, uChart, usetlist, ufreqband,
  tags;



type
  tSpmBand = class
  public
    owner:tlist;
    // в абсолютных координатах
    m_f1,m_f2:double;
    // компонент котрый отображает полосу
    m_freqband:cFreqBand;
    // список объектов для которых подписываем значение
    m_trends:tstringlist;
    m_thresh:double;
    m_chart:cChart;
  protected
    function getname:string;
  public
    procedure setchart(c:cchart);
    function getObj(s:string):tobject;
    property name:string read getname;
    constructor create;
    destructor destroy;
  end;
  // список полос
  bList = class(tlist)
  public
    m_c:cchart;
  public
    procedure UpdateBands;
    function addband(f1,f2, threshold:double; chart:cchart):tspmBand;
    function getband(i:integer):tSpmBand;
    procedure cleardata;
  end;

implementation

function correctPosX(page: cpage; x: double; var error:boolean): double;
var
  min, max: double;
begin
  error:=false;
  if page.lgX then
  begin
    min:=page.MinX;
    max:=page.MaxX;
    if (min < x) and (x < max) then
    begin
      result := LogValToLinearScale(x, p2d(min, max));
    end
    else
      error:=true;
  end
  else
  begin
    result := x;
  end;
end;

{ tSpmBand }

constructor tSpmBand.create;
begin
  m_trends:=TStringList.create;
  m_freqband:=cFreqBand.create;
end;

destructor tSpmBand.destroy;
begin
  if m_freqband<>nil then
  begin
    m_freqband.destroy;
  end;
  m_trends.Destroy;
end;

function tSpmBand.getname: string;
begin
  //if m_b<>nil then
  //  result:=m_b.name
  //else
  //  result:='';
end;

function tSpmBand.getObj(s: string): tobject;
var
  I: Integer;
begin
  result:=nil;
  for I := 0 to m_trends.count - 1 do
  begin
    if m_trends.Strings[i]=s then
    begin
      result:=m_trends.Objects[i];
      exit;
    end;
  end;
end;

procedure tSpmBand.setchart(c: cchart);
var
  page:cpage;
begin
  m_chart:=c;
  m_freqband.m_fullname:=true;
  m_freqband.m_LineLabel.Visible:=true;
  m_freqband.layer:=2;
  m_freqband.m_LineLabel.layer:=0;
  m_freqband.m_LineLabel.m_addscaleX:=1.1;
  m_freqband.name:='FreqBand';
  m_freqband.m_names:=m_trends;
  //m_freqband.x1:=
  page:=cpage(c.activeTab.GetPage(1));
  page.AddChild(m_freqband);
end;

{ bList }


function bList.addband(f1, f2, threshold:double; chart:cchart): tspmBand;

begin
  result:=tSpmBand.create;
  result.owner:=self;
  result.m_f1:=f1;
  result.m_f2:=f2;
  m_c:=chart;
  result.m_thresh:=threshold;
  result.setchart(chart);
  Add(result);
end;

procedure bList.cleardata;
var
  I: Integer;
  b:tSpmBand;
begin
  for I := 0 to Count - 1 do
  begin
    b:=getband(i);
    b.destroy;
  end;
  inherited clear;
end;

function bList.getband(i: integer): tSpmBand;
begin
  result:=tSpmBand(items[i]);
end;

procedure bList.UpdateBands;
var
  lx1, lx2, lx,r, min, max:double;
  er:boolean;
  page:cpage;
  I: Integer;
  b:tspmband;
begin
  if m_c=nil then exit;
  page:=cpage(m_c.activeTab.GetPage(1));
  min:=page.MinX;
  max:=page.MaxX;
  r:=max-min;
  for I := 0 to Count - 1 do
  begin
    b:=getband(i);
    lx1:=correctPosX(page,b.m_f1,er);
    lx2:=correctPosX(page,b.m_f2,er);
    lx1:=(2*(lx1-min)/r)-1;
    lx2:=(2*(lx2-min)/r)-1;
    lx:=0.5*(lx1+lx2);

    b.m_freqband.x1:=lx-lx1;
    b.m_freqband.x2:=lx2-lx;
    b.m_freqband.x:=lx;
  end;
end;

end.
