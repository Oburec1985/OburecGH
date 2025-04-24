unit uMainFrmChart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,
  uChart, u2dmath,
  ucommontypes, uPoint, MathFunction, uCommonMath, uGrahamScan,
  uGrahamScan2,
  upage, uAxis, ubasictrend, uBuffTrend2d,
  StdCtrls;

type
  TForm1 = class(TForm)

    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
  public
    grahem:pointsarray;
    m_diam:TDiameterResult;
  private
    procedure DoInit(sender:tobject);
  public
    chart:cChart;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.DoInit(sender: tobject);
begin
  chart.logstr('OnInitscene');
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  r:fRect;
  t:cBuffTrend2d;
  I: Integer;
  p,p1:point2;
  dist:double;
begin
  chart:=cChart.Create(nil);
  chart.Parent:=self;
  //chart.debugLB:=ListBox1;
  chart.Align:=alClient;
  chart.OnInit:=DoInit;
  r.BottomLeft:=p2(-10,-10);
  //r.TopRight:=p2(10,10);

  cpage(chart.activePage).ZoomfRect(r);

  t:=cBuffTrend2d.create;
  t.drawLines:=true;
  cpage(chart.activePage).activeAxis.AddChild(t);
  t.drawpoint:=true;
  // ύλθορ X:=A*cos(w*t+ph) Y:=B*cos(w*t+ph)
  p.x:=1;
  p.y:=0;
  t.addpoint(p);
  p.x:=1;
  p.y:=1;
  t.addpoint(p);
  p.x:=0;
  p.y:=0;

  t.addpoint(p);
  p.x:=0;
  p.y:=1;
  t.addpoint(p);
  p.x:=-0.1;
  p.y:=0.2;
  t.addpoint(p);
  p.x:=0.5;
  p.y:=0.6;
  t.addpoint(p);
  p.x:=0.52;
  p.y:=0.6;
  t.addpoint(p);
  //t.addpoints(tpointarray(@t.data[0]),9);

  t.visible:=true;
  setlength(grahem, 7);
  //grahem:=GrahamScanWithDiameter(tpointarray(@t.data[0]),9,m_diam);
  grahem:=GrahamScan(pointsarray(@t.data[0]), 7);
  FindDiameter(grahem, p,p1 ,dist);

  t:=cBuffTrend2d.create;
  cpage(chart.activePage).activeAxis.AddChild(t);
  t.drawpoint:=true;
  t.addpoints(grahem, length(grahem));
  t.color:=red;

  t:=cBuffTrend2d.create;
  cpage(chart.activePage).activeAxis.AddChild(t);
  t.drawpoint:=true;
  t.addpoint(p);
  t.addpoint(p1);
  t.color:=green;


end;

end.
