unit uMainFrmChart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,
  uChart, u2dmath,
  ucommontypes, uPoint, MathFunction, uCommonMath,
  upage, uAxis, ubasictrend, uBuffTrend2d,
  StdCtrls;

type
  TForm1 = class(TForm)

    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
  public
    grahem:TPointArray;
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
  p:point2;
begin
  chart:=cChart.Create(nil);
  chart.Parent:=self;
  //chart.debugLB:=ListBox1;
  chart.Align:=alClient;
  chart.OnInit:=DoInit;
  r.BottomLeft:=p2(-10,-10);
  r.TopRight:=p2(10,10);
  t:=cBuffTrend2d.create;
  cpage(chart.activePage).ZoomfRect(r);
  cpage(chart.activePage).activeAxis.AddChild(t);
  t.drawpoint:=true;
  for I := 0 to 9 do
  begin
    // ύλθορ X:=A*cos(w*t+ph) Y:=B*cos(w*t+ph)
    p.x:=2*cos(pi/2+i*c_2pi/9);
    p.y:=-1*sin(pi/2+i*c_2pi/9);
    t.addpoint(p);
  end;
  t.addpoint(p2(0,0));
  t.addpoint(p2(0.5,0.5));
  t.visible:=false;
  setlength(grahem, 12);
  grahem:=GrahamScanWithDiameter(tpointarray(@t.data[0]),12 ,m_diam);

  t:=cBuffTrend2d.create;
  cpage(chart.activePage).activeAxis.AddChild(t);
  t.drawpoint:=true;
  t.addpoints(grahem, length(grahem));
end;

end.
