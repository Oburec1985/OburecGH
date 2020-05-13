unit uTreeStageCfg;

interface

uses
  Windows, SysUtils, ComCtrls, forms, Controls, Classes, StdCtrls,
  uBtnListView, uFormEditListItem, upair,
  ubldfile, uBldMath, ubldservice, DCL_MYOWN, umyTypes_, ubldturnmath, ToolWin,
  ImgList, Dialogs, uLfmFile;

type
  TTreeBldCfgFrame = class(TFrame)
    CfgTreeView: TTreeView;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ImageList1: TImageList;
    GroupBox1: TGroupBox;
    LoadBtn: TToolButton;
    OpenDialog1: TOpenDialog;
  private
    bldfile:cbldfilegen;
  public
    procedure LoadBtnClick(Sender: TObject);
  private
    procedure addStage(stage:cstage; blFile:cBldFileGen);
    procedure addSensor(StageNode:ttreenode; sensor:csensor);
    // Обновить содержимое TreeView если обновился bldFile
    procedure update;
  public
    procedure LincTree(blFile:cBldFileGen);
  end;

implementation
const
  StageImageIndex = 0;
  // индекс картинки корневого датчика
  BaseSensorImageIndex = 2;
  // индекс картинки периферийного датчика
  PeakSensorImageIndex = 3;
  // индекс картинки тахо датчика
  TaxoSensorImageIndex = 4;
  // индекс картинки тахо датчика  
  UTSSensorImageIndex = 5;

{$R *.dfm}
procedure TTreeBldCfgFrame.addSensor(StageNode:ttreenode; sensor:csensor);
var SensorNode:ttreenode;
    i:integer;
begin
  SensorNode:=CfgTreeView.Items.AddChildObject (StageNode, sensor.mChanName, sensor);
  case sensor.mChanType of
    c_rot: i:=TaxoSensorImageIndex;
    c_edge: i:=PeakSensorImageIndex;
    c_root: i:=BaseSensorImageIndex;
    c_UTS: i:=UTSSensorImageIndex;
  end;
  SensorNode.imageIndex:=i;
end;

procedure TTreeBldCfgFrame.update;
begin
  LincTree(bldFile);
end;

procedure TTreeBldCfgFrame.addStage(stage:cstage;blFile:cBldFileGen);
var
  i:integer;
  StageNode:ttreenode;
  sensor:csensor;
begin
  StageNode:=CfgTreeView.Items.AddChildObject (nil, stage.name, stage);
  StageNode.ImageIndex:=StageImageIndex;
  for I := 0 to blFile.sensors.count - 1 do
  begin
    sensor:=blFile.sensors.sensors[i];
    if sensor.stagename=stage.name then
      addsensor(stageNode,sensor);
  end;
end;

procedure TTreeBldCfgFrame.LoadBtnClick(Sender: TObject);
var cfg:cConfiFile_lfm;
begin
  if OpenDialog1.Execute then
  begin
    cfg:=cConfiFile_lfm.create;
    cfg.readFile(OpenDialog1.FileName);
    bldfile.stages:=cfg.stages;
    bldfile.Sensors:=cfg.sensors;
    cfg.Destroy;
    update;
  end;
end;

procedure TTreeBldCfgFrame.LincTree(blFile:cBldFileGen);
var
  i:integer;
  stage:cStage;
begin
  bldfile:=blfile;
  // Очистка списка
  CfgTreeView.Items.Clear;
  for I := 0 to blFile.stages.count - 1 do
  begin
    stage:=blFile.stages.stages[i];
    // добавление ступени
    addStage(stage,blFile);
  end;
end;

end.
