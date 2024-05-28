unit u3dSceneEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, uVTServices, ImgList, ExtCtrls,
  uBaseObjService,
  uSceneMng;

type
  TGlSceneEditFrame = class(TFrame)
    SceneTV: TVTree;
    Panel1: TPanel;
    ImageList_16: TImageList;
  private
    m_sc:cScene;
  public
    Procedure LincScene(sc:cscene);
    Procedure ShowScene;
  end;

implementation

{$R *.dfm}

{ TGlSceneEditFrame }
procedure TGlSceneEditFrame.LincScene(sc: cscene);
begin
  m_sc:=sc;
end;

procedure TGlSceneEditFrame.ShowScene;
begin
  showInVTreeView(SceneTV,m_sc.World);
end;

end.
