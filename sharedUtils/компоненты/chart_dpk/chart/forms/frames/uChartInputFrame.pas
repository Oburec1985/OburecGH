unit uChartInputFrame;

interface

uses
  Windows, SysUtils, Classes, Forms, ucommonmath, mathfunction,
  StdCtrls, uChart, Controls, opengl, uCommonTypes;

type
  TChartInputFrame = class(TFrame)
    Mouse_ix_iy_Label: TLabel;
    Mouse_xLabel: TLabel;
    TopLeft_ix_iy_width_height_Label: TLabel;
    ReEvalMouseLabel: TLabel;
    TrendMouseX_YLabel: TLabel;
    Label1: TLabel;
    Mouse_ix_iy: TEdit;
    Mouse_x_y: TEdit;
    TopLeft_ix_iy_width_height: TEdit;
    ReEvalMouse: TEdit;
    TrendMouseX_Y: TEdit;
    MouseStrafeEdit: TEdit;
  private
    chart:cchart;
  protected
    procedure cChart1MouseMove(Sender: TObject);    
  public
    procedure lincChart(p_chart:cchart);
  end;

implementation
uses
  upage;

{$R *.dfm}
procedure TChartInputFrame.lincChart(p_chart:cchart);
begin
  chart:=p_chart;
  chart.OnMouseMove:=cChart1MouseMove;
end;

procedure TChartInputFrame.cChart1MouseMove(Sender: TObject);
var
  viewport:array [0..3] of glint;
  p:tpoint;
  pos:point2;
  res:boolean;
begin
  if Visible then
  begin
    glGetIntegerv(GL_VIEWPORT,@viewport); // узнаём параметры viewport-a.
    Mouse_ix_iy.Text:='x:'+inttostr(cchart(sender).mouse.iPos.x)+'; '+
                      'y:'+inttostr(cchart(sender).mouse.iPos.y)+'; '+
                      'y_inv:'+inttostr(cchart(sender).mouse.iPos_inv.Y);
    Mouse_x_y.Text:=  'x:'+formatstr(cchart(sender).mouse.Pos.x,3)+'; '+
                      'y:'+formatstr(cchart(sender).mouse.Pos.y,3);
    TrendMouseX_Y.Text:='x:'+formatstr(cchart(sender).mouse.activeAxisPos.x,3)+'; '+
                      'y:'+formatstr(cchart(sender).mouse.activeAxisPos.y,3);
    MouseStrafeEdit.text:='x:'+formatstr(cchart(sender).mouse.activeaxisstrafe.x,3)+'; '+
                      'y:'+formatstr(cchart(sender).mouse.activeaxisstrafe.y,3);
    TopLeft_ix_iy_width_height.Text:=
      'Left:'+inttostr(viewport[0])+'; '+'Top:'+inttostr(viewport[1])+'; '+
      'Width:'+inttostr(viewport[2])+'; '+'Heigth:'+inttostr(viewport[3]);
    pos:=cchart(sender).mouse.Pos;
    if cchart(sender).activepage is cpage then
    begin
      if cpage(cchart(sender).activepage).activeAxis<>nil then
      begin
        p:=cpage(cchart(sender).activepage).activeAxis.p2ToP2i(cchart(sender).mouse.activeAxisPos,res);
        ReEvalMouse.Text:='x:'+inttostr(p.x)+'; '+
                          'y:'+inttostr(p.y);
      end;
    end;
  end;
end;

end.
