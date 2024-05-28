program GlScene;

uses
  Forms,
  u3dFrm in 'forms\u3dFrm.pas' {GlFrm},
  uSceneMng in 'objects\uSceneMng.pas',
  uCommonTypes in '..\sharedUtils\uCommonTypes.pas',
  uBaseObjMng in '..\sharedUtils\objects\uBaseObjMng.pas',
  uBaseObj in '..\sharedUtils\objects\uBaseObj.pas',
  uRender in 'core\uRender.pas',
  u3dTypes in 'core\u3dTypes.pas',
  uGlEventTypes in 'core\uGlEventTypes.pas',
  uUI in 'core\uUI.pas',
  uUiutils in 'tools\uUiutils.pas',
  uselectools in 'tools\uselectools.pas',
  uCursors in '..\sharedUtils\utils\uCursors.pas',
  uConfigFile3d in 'tools\uConfigFile3d.pas',
  uObjectTypes in 'objects\uObjectTypes.pas',
  uQNode in 'objects\uQNode.pas',
  uMNode in 'objects\uMNode.pas',
  uNode in 'objects\uNode.pas',
  uNodeObject in 'objects\uNodeObject.pas',
  uObject in 'objects\uObject.pas',
  uBaseCamera in 'objects\uBaseCamera.pas',
  uVlist in '..\sharedUtils\utils\lists\uVlist.pas',
  ueventlist in '..\sharedUtils\utils\lists\ueventlist.pas',
  uEventTypes in '..\sharedUtils\utils\lists\uEventTypes.pas',
  uRegClassesList in '..\sharedUtils\utils\lists\uRegClassesList.pas',
  usetlist in '..\sharedUtils\utils\lists\usetlist.pas',
  uSimpleSetList in '..\sharedUtils\utils\lists\uSimpleSetList.pas',
  uvectorlist in '..\sharedUtils\utils\lists\uvectorlist.pas',
  uTestObjects in 'objects\uTestObjects.pas',
  uTVFrm in 'forms\uTVFrm.pas' {SceneTVFrame: TFrame},
  uVTServices in '..\sharedUtils\utils\uVTServices.pas',
  uShape in 'objects\uShape.pas',
  uLight in 'objects\uLight.pas',
  uMesh in 'objects\uMesh.pas',
  uMeshData in 'objects\uMeshData.pas',
  uMeshObr in 'objects\uMeshObr.pas',
  uBaseObjService in '..\sharedUtils\objects\uBaseObjService.pas',
  uObrFile in 'objects\uObrFile.pas',
  uObaFile in 'objects\uObaFile.pas',
  uGroupObjects in 'objects\uGroupObjects.pas',
  uLoadSkin in 'objects\uLoadSkin.pas',
  uModList in 'objects\uModList.pas',
  uSkin in 'objects\uSkin.pas',
  uMoveController in 'core\uMoveController.pas',
  uTimeController in 'core\uTimeController.pas',
  uTickMath in 'math\uTickMath.pas',
  uVBOMesh in 'objects\uVBOMesh.pas',
  TextureGL in 'objects\TextureGL.pas',
  uMaterial in 'objects\uMaterial.pas',
  uSelectLoadedObjects in 'forms\uSelectLoadedObjects.pas' {InfoForm},
  uEditListForm in 'forms\uEditListForm.pas' {EditObjectForm},
  AnimationControlFrame in 'forms\AnimationControlFrame.pas' {AnimationCtrlFrame: TFrame},
  uglFrameListener in 'core\uglFrameListener.pas',
  uClickFrListener in 'core\uClickFrListener.pas',
  MathFunction in '..\sharedUtils\math\MathFunction.pas',
  uBaseDeformer in 'objects\uBaseDeformer.pas',
  uBaseModificator in 'objects\uBaseModificator.pas',
  uModifyFrame in 'forms\uModifyFrame.pas' {ModifyFrame: TFrame},
  CreateModificatorForm in 'forms\CreateModificatorForm.pas' {cCreateModificatorForm},
  uSkinFrame in 'forms\uSkinFrame.pas' {SkinFrame: TFrame},
  uMoveControllerFrame in 'forms\uMoveControllerFrame.pas' {MoveControllerFrame: TFrame},
  uTransformButtons in 'forms\uTransformButtons.pas' {TransformToolsFrame: TFrame},
  SelectObjectsFrame in 'forms\SelectObjectsFrame.pas' {SelectObjectFrame: TFrame},
  uDeformerFrame in 'forms\uDeformerFrame.pas' {DeformerFrame: TFrame},
  uObjCtrFrame in 'forms\uObjCtrFrame.pas' {CtrlViewFrame: TFrame},
  uMatrix in '..\sharedUtils\math\uMatrix.pas',
  u3dSceneEditFrame in '..\sharedUtils\ogl\forms\u3dSceneEditFrame.pas' {GlSceneEditFrame: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGlFrm, GlFrm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.CreateForm(TEditObjectForm, EditObjectForm);
  Application.CreateForm(TcCreateModificatorForm, cCreateModificatorForm);
  Application.Run;
end.
