unit uChartCfgForm;

interface

uses
  Windows, SysUtils, Classes, Forms,
  Dialogs, StdCtrls, uChart, Controls, ExtCtrls;

type
  TChartCfgForm = class(TForm)
    MainGB: TGroupBox;
    ShowTVCheckBox: TCheckBox;
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    ShowLegendCB: TCheckBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure showProperty(chart:cchart);
    procedure SetProperty(chart:cchart);
  public
    function showmodal(chart:cchart):integer;
  end;

var
  ChartCfgForm: TChartCfgForm;

implementation

{$R *.dfm}

procedure TChartCfgForm.showProperty(chart:cchart);
begin
  ShowTVCheckBox.checked:=chart.tv.Visible;
  ShowLegendCB.checked:=chart.legend.Visible;
end;

procedure TChartCfgForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

procedure TChartCfgForm.SetProperty(chart:cchart);
begin
  chart.showTV:=ShowTVCheckBox.checked;
  chart.legend.setvisible(ShowLegendCB.checked);
end;

function TChartCfgForm.showmodal(chart:cchart):integer;
begin
  showproperty(chart);
  if inherited showmodal=mrok then
  begin
    SetProperty(chart);
  end;
end;

end.
