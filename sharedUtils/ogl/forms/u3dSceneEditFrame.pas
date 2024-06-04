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
begin
  SceneTV.Repaint;
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
  {if EditGLObjFrm=nil then
  begin
    //EditGLObjFrm:=TEditGLObjFrm.create(nil);
  end;
  n:=SceneTV.GetFirstSelected(false);
  if n<>nil then
  begin
    d:=SceneTV.GetNodeData(n);
    o:=cbaseobj(d.data);
    EditGLObjFrm.setObj(cnodeobject(o));
    EditGLObjFrm.show;
  end;}
end;

procedure TGlSceneEditFrame.ShowScene;
begin
  if m_ui<>nil then
    showInVTreeView(SceneTV,m_ui.scene.World);
end;

end.
