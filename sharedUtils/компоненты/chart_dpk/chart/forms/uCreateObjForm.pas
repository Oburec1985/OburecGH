unit uCreateObjForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, uCreateTrendFrame, ExtCtrls, StdCtrls,
  uchart, udrawobj, uBasicTrend;

type
  TCreateObjForm = class(TForm)
    ChartGB: TGroupBox;
    EditChartCfgFrame1: TEditChartCfgFrame;
    ActionGB: TGroupBox;
    Splitter1: TSplitter;
    ApplyBtn: TButton;
    CancelBtn: TButton;
    procedure EditChartCfgFrame1addLineBtnClick(Sender: TObject);
  private
  public
    procedure linc(p_chart:cchart);
    function GetObj:cdrawobj;
  end;

var
  CreateObjForm: TCreateObjForm;

implementation
uses
  utrend, ugistogram, umarkers;

{$R *.dfm}
procedure TCreateObjForm.linc(p_chart:cchart);
begin
  EditChartCfgFrame1.linc(p_chart);
end;

procedure TCreateObjForm.EditChartCfgFrame1addLineBtnClick(Sender: TObject);
begin
  EditChartCfgFrame1.addLineBtnClick(Sender);
end;

function TCreateObjForm.GetObj:cdrawobj;
begin
  result:=nil;
  EditChartCfgFrame1.UpdateTV;
  if showmodal=mrok then
  begin
    // установить свойства выбранного объекта
    EditChartCfgFrame1.ApplyBtnClick(nil);
    result:=cdrawobj(EditChartCfgFrame1.getselected);
    if not (result is cbasictrend ) and
    not (result is cGistogram) and
    not (result is cMarkerList) then
    begin
      result:=nil;
    end;
  end;
end;

end.
