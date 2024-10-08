unit u3dSceneEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, uVTServices, ImgList, ExtCtrls,
  uBaseObjService, uUI,
  //uEditGlObjFrm,
  ubaseobj,unodeobject,
  uSceneMng;

type
  TGlSceneEditFrame = class(TFrame)
    Panel1: TPanel;
    ImageList_16: TImageList;
    SceneTV: TVTree;
    procedure SceneTVDblClick(Sender: TObject);
    procedure SceneTVClick(Sender: TObject);
    procedure SceneTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    m_init:boolean;
    m_ui:cUI;
  public
    Procedure LincScene(ui:cui);
    Procedure ShowScene;
  end;

implementation

{$R *.dfm}

{ TGlSceneEditFrame }
procedure TGlSceneEditFrame.LincScene(ui: cui);
begin
  m_ui:=ui;
  if ui<>nil then
  begin
    m_init:=true;
    ShowScene;
  end;
end;


procedure TGlSceneEditFrame.SceneTVChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  n:PVirtualNode;
  d:PNodeData;
  o:cNodeObject;
begin
  n:=SceneTV.GetFirstSelected(false);
  SceneTV.Repaint;
  if n=nil then exit;
  d:=SceneTV.GetNodeData(n);
  o:=cNodeObject(d.data);
  m_ui.selectobject(o, false);
  m_ui.m_RenderScene.invalidaterect;
end;

procedure TGlSceneEditFrame.SceneTVClick(Sender: TObject);
begin
  SceneTV.Repaint;
end;

procedure TGlSceneEditFrame.SceneTVDblClick(Sender: TObject);
var
  o:cbaseobj;
  n:pvirtualnode;
  d:pnodedata;
begin

end;

procedure TGlSceneEditFrame.ShowScene;
begin
  if m_ui<>nil then
    showInVTreeView(SceneTV,m_ui.scene.World);
end;

end.
