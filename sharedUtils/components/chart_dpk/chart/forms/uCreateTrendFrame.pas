unit uCreateTrendFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Buttons, uBaseObj, upage, uaxis, utrend,
  uGistogram, uchart, uBaseObjService, uEditChartObjFrame, udrawobj, uComponentServises,
  ubufftrend1d
  ;

type
  TEditChartCfgFrame = class(TFrame)
    CfgGB: TGroupBox;
    GraphNameLabel: TLabel;
    GraphNameEdit: TEdit;
    CfgTV: TTreeView;
    Splitter1: TSplitter;
    AddAxisBtn: TSpeedButton;
    addLineBtn: TSpeedButton;
    AddGistBtn: TSpeedButton;
    Splitter2: TSplitter;
    ObjGB: TGroupBox;
    EditDrawObjFrame1: TEditDrawObjFrame;
    ApplyBtn: TSpeedButton;
    CancelBtn: TSpeedButton;
    procedure CfgTVChange(Sender: TObject; Node: TTreeNode);
    procedure ApplyBtnClick(Sender: TObject);    
    procedure AddAxisBtnClick(Sender: TObject);
    procedure addLineBtnClick(Sender: TObject);
    procedure AddGistBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  public
    onchangeObj:tnotifyevent;
  private
    curobj:cbaseobj;
    curchart:cchart;
  private
    // дизаблит кнопки в зависимости от того что выбрано в графике
    procedure SetDisables;
  public
    // показать конфигурацию чарта
    procedure UpdateTV;  
    function getselected:cbaseobj;  
    procedure SetSelected(obj:cdrawobj);
    // прилинковать чарт к фрейму
    procedure linc(chart:cchart);
  end;

implementation

{$R *.dfm}


procedure TEditChartCfgFrame.linc(chart:cchart);
begin
  curchart:=chart;
  UpdateTV;
  setdisables;
end;

procedure TEditChartCfgFrame.AddAxisBtnClick(Sender: TObject);
begin
  cPage(curobj).newaxis;
  UpdateTV;
end;

procedure TEditChartCfgFrame.AddGistBtnClick(Sender: TObject);
begin
  caxis(curobj).AddGistogram;
  UpdateTV;
end;

procedure TEditChartCfgFrame.ApplyBtnClick(Sender: TObject);
begin
  EditDrawObjFrame1.getObj;
end;

procedure TEditChartCfgFrame.addLineBtnClick(Sender: TObject);
begin
  caxis(curobj).AddTrend;
  UpdateTV;
end;

procedure TEditChartCfgFrame.CancelBtnClick(Sender: TObject);
begin
  EditDrawObjFrame1.SetObj(cdrawobj(curobj));
end;

procedure TEditChartCfgFrame.CfgTVChange(Sender: TObject; Node: TTreeNode);
begin
  getselected;
  SetDisables;
end;

function TEditChartCfgFrame.getselected:cbaseobj;
begin
  result:=nil;
  if cfgtv=nil then exit;
  if CfgTV.Selected<>nil then
  begin
    result:=cbaseobj(CfgTV.Selected.Data);
    curobj:=result;
    EditDrawObjFrame1.SetObj(cdrawobj(curobj));
    GraphNameEdit.Text:=curobj.name;
  end
  else
  begin
    curobj:=nil;
    EditDrawObjFrame1.SetObj(nil);
  end;
  if assigned(onchangeObj) then
  begin
    onChangeObj(curobj);
  end;
end;

procedure TEditChartCfgFrame.SetDisables;
var
  obj:cbaseobj;
begin
  obj:=getselected;
  if obj=nil then
  begin
    addLineBtn.Enabled:=false;
    addGistBtn.Enabled:=false;
    addAxisBtn.Enabled:=false;
    exit;
  end;
  if obj is cpage then
  begin
    addLineBtn.Enabled:=false;
    addGistBtn.Enabled:=false;
    addAxisBtn.Enabled:=true;
  end
  else
  begin
    if obj is caxis then
    begin
      addLineBtn.Enabled:=true;
      addGistBtn.Enabled:=true;
      addAxisBtn.Enabled:=false;
    end
    else
    begin
      addLineBtn.Enabled:=false;
      addGistBtn.Enabled:=false;
      addAxisBtn.Enabled:=false;
    end;
  end;
end;

procedure TEditChartCfgFrame.UpdateTV;
var
  p:cpage;
  cursel:cdrawobj;
begin
  cursel:=nil;
  if cfgtv.Selected<>nil then
  begin
    cursel:=cfgtv.Selected.Data;
  end;
  // отображаем структуру компонента
  cfgtv.Items.Clear;
  showInTreeView(cfgtv, curchart.activetab);
  if cursel<>nil then
  begin
    SelectNodeInTV(cursel,cfgtv);
  end;
end;

procedure TEditChartCfgFrame.SetSelected(obj:cdrawobj);
var
  node:ttreenode;
begin
  node:=FindNodeInTV(obj, CfgTV);
  if node<>nil then
  begin
    //CfgTV.Select(node,[]);
    node.Selected:=true;
    node.Focused:=true;
    node.Expanded:=true;
  end;
end;


end.
