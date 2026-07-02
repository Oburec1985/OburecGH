unit uTrendFrame;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uBasicTrend, ucommonMath,
  Dialogs, uDrawObjFrame, StdCtrls, ExtCtrls, Spin, DCL_MYOWN, uSpin, opengl,
  uTrend;

type
  TTrendFrame = class(TFrame)
    PointGB: TGroupBox;
    ColorPointLabel: TLabel;
    ColorBox: TPanel;
    DrawPoints: TCheckBox;
    BackGroundColorDialog: TColorDialog;
    GroupBox1: TGroupBox;
    VectorLineColor: TPanel;
    VectorLineColorLabel: TLabel;
    VectorPointColor: TPanel;
    VectorPointColorLabel: TLabel;
    SelectVectorPointColor: TPanel;
    SelectVectorPointColorLabel: TLabel;
    ColorSelectPoint: TPanel;
    ColorSelectPointLabel: TLabel;
    DrawLines: TCheckBox;
    WidthLabel: TLabel;
    WidthSE: TFloatSpinEdit;
    procedure ColorBoxClick(Sender: TObject);
  private
    curobj:cBasicTrend;
  public
    procedure SetObj(obj:cBasicTrend);
    function GetObj:cBasicTrend;
  end;

implementation

{$R *.dfm}
procedure TTrendFrame.ColorBoxClick(Sender: TObject);
begin
  if BackGroundColorDialog.Execute then
    tpanel(sender).color:=BackGroundColorDialog.Color;
end;

procedure TTrendFrame.SetObj(obj:cBasicTrend);
var
  v:double;
begin
  curobj:=obj;
  ColorBox.color:=rgbtoint(obj.pointcolor);
  if obj IS CTREND then
  begin
    ColorSelectPoint.Color:=rgbtoint(ctrend(obj).SelectPointColor);
    VectorLineColor.Color:=rgbtoint(ctrend(obj).VectorColor);
    VectorPointColor.Color:=rgbtoint(ctrend(obj).VectorPointColor);
    SelectVectorPointColor.Color:=rgbtoint(ctrend(obj).SelectVectorPointColor);
  end
  else
  begin
    GroupBox1.Visible:=false;
  end;
  drawPoints.Checked:=obj.drawpoint;
  drawLines.Checked:=obj.drawLines;
  // устанавливаем толщину линии
  WidthSE.Value:=obj.weight;
  glGetDoublev(GL_LINE_WIDTH_GRANULARITY,@v);
  WidthSE.Increment:=v;
  //refresh;
end;

function TTrendFrame.GetObj:cBasicTrend;
begin
  curobj.pointcolor:=inttorgb(ColorBox.color);
  if curobj is ctrend then
  begin
    ctrend(curobj).SelectPointColor:=inttorgb(ColorSelectPoint.color);
    ctrend(curobj).VectorColor:=inttorgb(VectorLineColor.color);
    ctrend(curobj).VectorPointColor:=inttorgb(VectorPointColor.color);
    ctrend(curobj).SelectVectorPointColor:=inttorgb(SelectVectorPointColor.color);
  end;
  curobj.drawpoint:=drawPoints.Checked;
  curobj.drawLines:=drawLines.Checked;
  curobj.weight:=WidthSE.Value;
  result:=curobj;
end;

end.
