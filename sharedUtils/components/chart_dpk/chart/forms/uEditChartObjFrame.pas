unit uEditChartObjFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, uDrawObjFrame, uTrendFrame, uGistFrame, uDrawObj,
  uGistogram, utrend, uBasicTrend, uaxis;

type
  TEditDrawObjFrame = class(TFrame)
    DrawObjGB: TGroupBox;
    DrawObjFrame1: TDrawObjFrame;
    TrendGB: TGroupBox;
    TrendFrame1: TTrendFrame;
    GistGB: TGroupBox;
    GistFrame1: TGistFrame;
  private
    curobj:cdrawobj;
  private
    procedure setVisible;
  public
    procedure SetObj(obj:cdrawobj);
    function getObj:cdrawobj;
  end;

implementation

{$R *.dfm}
procedure TEditDrawObjFrame.setVisible;
begin
  if curobj=nil then
  begin
    TrendGB.visible:=false;
    GistGB.Visible:=false;
    GistGB.Visible:=false;
    exit;
  end;
  if curobj is cBasicTrend then
  begin
    TrendGB.visible:=true;
    GistGB.Visible:=false;
    exit;
  end;
  if curobj is cgistogram then
  begin
    TrendGB.visible:=false;
    GistGB.Visible:=true;
    exit;
  end;
  if curobj is caxis then
  begin
    TrendGB.visible:=false;
    GistGB.Visible:=false;
    exit;
  end;
  TrendGB.visible:=false;
  GistGB.Visible:=false;
end;

procedure TEditDrawObjFrame.SetObj(obj:cdrawobj);
begin
  curobj:=obj;
  setVisible;
  DrawObjFrame1.setObj(obj);
  if obj is cbasictrend then
  begin
    TrendFrame1.SetObj(ctrend(obj));
  end;
  if obj is cgistogram then
  begin
    GistFrame1.SetObj(cgistogram(obj));
  end;
end;

function TEditDrawObjFrame.getObj:cdrawobj;
begin
  DrawObjFrame1.getObj(curobj);
  if curobj is cbasictrend then
  begin
    TrendFrame1.GetObj;
  end;
  if curobj is cgistogram then
  begin
    GistFrame1.GetObj;
  end;
end;

end.
