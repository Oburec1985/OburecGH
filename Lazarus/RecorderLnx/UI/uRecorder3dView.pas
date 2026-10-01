unit uRecorder3dView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Controls, ExtCtrls, Buttons, Menus, Forms, ComCtrls, ImgList,
  uOglChart, u3dContracts, u3dScene, u3dSceneMath, u3dInteractionTypes,
  u3dGizmo, u3dLclWidget,
  uRecorderFormModel, uRecorderTags,
  uRecorderVisualControl, uRecorder3dModel, uRecorder3dBindingAdapter,
  uRecorderCommandImages, u3dMotionContracts, u3dSceneMotionEngine,
  uRecorderFrfSnapshot, uRecorderFrfMotionAdapter;

type
  TRecorder3dView = class(T3dLclWidget, IVForm)
  private
    fComponent: TRecorder3dComponent;
    fRegistry: TRecorderTagRegistry;
    fBindings: TRecorder3dBindingAdapter;
    fFrfSampler: IRecorderFrfSampler;
    fFrfSink: I3dMotionSink;
    fFrfAdapter: TRecorderFrfMotionAdapter;
    fFrfFrequencyTag, fFrfAnimationPhaseTag: TRecorderTag;
    fLoadedFileName: string;
    fToolbar: TPanel;
    fAxisButtons: array[0..3] of TSpeedButton;
    fCurrentMode: T3dInputMode;
    fPopup: TPopupMenu;
    procedure ApplyModel;
    procedure ViewChanged(Sender: TObject);
    procedure ToolClick(Sender: TObject);
    procedure AxisClick(Sender: TObject);
    procedure UpdateAxisButtons;
    procedure FitClick(Sender: TObject);
    procedure SceneTreeClick(Sender: TObject);
    procedure BuildToolbar;
    procedure LoadConfiguredScene;
    procedure ApplyNodeRenderOverrides;
    procedure ConfigureFrf;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

implementation

type
  TRecorderTagFrfSampler=class(TInterfacedObject,IRecorderFrfSampler)
  private
    fAmplitude,fPhase:array of TRecorderTag;
    fVersion:QWord;
  public
    procedure Configure(AComponent:TRecorder3dComponent; ARegistry:TRecorderTagRegistry);
    function TrySample(ACurveId:QWord; AFrequencyHz:Double;
      out AMagnitude,APhaseRadians:Double):Boolean;
    function Version:QWord;
  end;

function ResolveTag(ARegistry:TRecorderTagRegistry; AId:TRecorderTagId;
  const AName:string):TRecorderTag;
begin Result:=nil; if ARegistry=nil then Exit;
  if AId<>0 then Result:=ARegistry.FindById(AId);
  if (Result=nil) and (AName<>'') then Result:=ARegistry.FindByName(AName);
end;

procedure TRecorderTagFrfSampler.Configure(AComponent:TRecorder3dComponent;
  ARegistry:TRecorderTagRegistry);
var I:Integer; F:TRecorder3dFrfBinding;
begin SetLength(fAmplitude,AComponent.FrfBindingCount); SetLength(fPhase,AComponent.FrfBindingCount);
  for I:=0 to AComponent.FrfBindingCount-1 do begin F:=AComponent.FrfBindings[I];
    fAmplitude[I]:=ResolveTag(ARegistry,F.AmplitudeTagId,F.AmplitudeTagName);
    fPhase[I]:=ResolveTag(ARegistry,F.PhaseTagId,F.PhaseTagName); end;
  Inc(fVersion);
end;

function TRecorderTagFrfSampler.TrySample(ACurveId:QWord; AFrequencyHz:Double;
  out AMagnitude,APhaseRadians:Double):Boolean;
var I:Integer;
begin Result:=False; if (ACurveId=0) or (ACurveId>QWord(Length(fAmplitude))) then Exit;
  I:=ACurveId-1; if fAmplitude[I]=nil then Exit;
  AMagnitude:=fAmplitude[I].SignalBuffer.LatestValue;
  if IsNan(AMagnitude) or IsInfinite(AMagnitude) then Exit;
  APhaseRadians:=0; if fPhase[I]<>nil then APhaseRadians:=fPhase[I].SignalBuffer.LatestValue;
  Result:=not IsNan(APhaseRadians) and not IsInfinite(APhaseRadians);
end;

function TRecorderTagFrfSampler.Version:QWord;
begin Result:=fVersion; end;

constructor TRecorder3dView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fBindings := TRecorder3dBindingAdapter.Create;
  fFrfAdapter := TRecorderFrfMotionAdapter.Create;
  OnViewChanged := @ViewChanged;
  BuildToolbar;
end;

destructor TRecorder3dView.Destroy;
begin
  fBindings.Free;
  fFrfAdapter.Free; fFrfSampler:=nil; fFrfSink:=nil;
  inherited Destroy;
end;

procedure TRecorder3dView.BuildToolbar;
const CImageIndex:array[0..8] of Integer=(CIcon3dSelect,CIcon3dPan,
        CIcon3dCameraRotate,CIcon3dZoom,CIcon3dFitScene,CIcon3dRotateFree,
        CIcon3dRotateX,CIcon3dRotateY,CIcon3dRotateZ);
      CHint:array[0..4] of string=('Выбор и перемещение','Панорама',
        'Вращение камеры (Ctrl — временно)','Масштаб','Показать всю сцену');
var I:Integer; B:TSpeedButton; Item:TMenuItem; Images:TCustomImageList; C:TComponent;
begin
  Images:=nil;
  if Application.MainForm<>nil then begin
    C:=Application.MainForm.FindComponent('ilCommandButtons');
    if C is TCustomImageList then Images:=TCustomImageList(C);
  end;
  fToolbar:=TPanel.Create(Self); fToolbar.Parent:=Self; fToolbar.Align:=alBottom;
  fToolbar.Height:=48; fToolbar.BevelOuter:=bvNone;
  for I:=0 to 8 do begin
    B:=TSpeedButton.Create(fToolbar); B.Parent:=fToolbar; B.SetBounds(4+I*46,3,44,42);
    B.Images:=Images; B.ImageIndex:=CImageIndex[I]; B.Tag:=I;
    B.ShowHint:=True;
    if I<4 then begin
      B.Hint:=CHint[I]; B.GroupIndex:=17; B.AllowAllUp:=False; B.OnClick:=@ToolClick;
    end else if I=4 then begin B.Hint:=CHint[I]; B.OnClick:=@FitClick; end
    else begin
      B.Tag:=I-5; B.GroupIndex:=18; B.AllowAllUp:=False;
      B.OnClick:=@AxisClick; fAxisButtons[I-5]:=B;
    end;
    if I=0 then B.Down:=True;
  end;
  fCurrentMode:=imSelect;
  UpdateAxisButtons;
  fPopup:=TPopupMenu.Create(Self); Item:=TMenuItem.Create(fPopup);
  Item.Caption:='Дерево сцены...'; Item.OnClick:=@SceneTreeClick; fPopup.Items.Add(Item);
  PopupMenu:=fPopup;
end;

procedure TRecorder3dView.ToolClick(Sender:TObject);
begin
  fCurrentMode:=T3dInputMode(TSpeedButton(Sender).Tag);
  SetInputMode(fCurrentMode);
  UpdateAxisButtons;
end;

procedure TRecorder3dView.AxisClick(Sender:TObject);
var lIndex:Integer;
begin
  lIndex:=TSpeedButton(Sender).Tag;
  case fCurrentMode of
    imSelect: if lIndex>0 then SelectObjectAxis(T3dGizmoAxis(lIndex));
    imRotate: SetCameraRotationConstraint(T3dCameraRotationConstraint(lIndex));
  end;
  UpdateAxisButtons;
end;

procedure TRecorder3dView.UpdateAxisButtons;
const CAxisName:array[0..3] of string=('Свободно','X','Y','Z');
var I,Selected:Integer;
begin
  Selected:=-1;
  case fCurrentMode of
    imSelect: begin
      Selected:=Ord(SelectedObjectAxis);
      for I:=0 to 3 do begin
        fAxisButtons[I].Enabled:=I>0;
        if I=0 then fAxisButtons[I].Hint:='Ось выбирается на манипуляторе'
          else fAxisButtons[I].Hint:='Перемещать объект вдоль оси '+CAxisName[I];
      end;
    end;
    imRotate: begin
      Selected:=Ord(CameraRotationConstraint);
      for I:=0 to 3 do begin
        fAxisButtons[I].Enabled:=True;
        fAxisButtons[I].Hint:='Вращать камеру: '+CAxisName[I];
      end;
    end;
  else
    for I:=0 to 3 do begin
      fAxisButtons[I].Enabled:=False;
      fAxisButtons[I].Hint:='Ограничение доступно в режиме выбора или вращения';
    end;
  end;
  for I:=0 to 3 do fAxisButtons[I].Down:=I=Selected;
end;
procedure TRecorder3dView.FitClick(Sender:TObject);
begin FitScene; end;

procedure TRecorder3dView.SceneTreeClick(Sender:TObject);
var F:TForm; T:TTreeView; I,J:Integer; ParentNode,Node:TTreeNode;
begin
  F:=TForm.CreateNew(Self); try
    F.Caption:='Дерево 3D-сцены'; F.Position:=poOwnerFormCenter;
    F.SetBounds(0,0,420,520); T:=TTreeView.Create(F); T.Parent:=F; T.Align:=alClient;
    if Scene<>nil then for I:=0 to High(Scene.Nodes) do begin
      ParentNode:=nil;
      if Scene.Nodes[I].ParentId<>0 then for J:=0 to T.Items.Count-1 do
        if PtrUInt(T.Items[J].Data)=Scene.Nodes[I].ParentId then begin ParentNode:=T.Items[J]; Break; end;
      Node:=T.Items.AddChild(ParentNode,Scene.Nodes[I].Name); Node.Data:=Pointer(PtrUInt(Scene.Nodes[I].Id));
      if Scene.Nodes[I].Id=SelectedNodeId then T.Selected:=Node;
    end;
    F.ShowModal;
    if T.Selected<>nil then SelectNode(QWord(PtrUInt(T.Selected.Data)));
  finally F.Free; end;
end;

procedure TRecorder3dView.ViewChanged(Sender: TObject);
begin
  if fComponent = nil then Exit;
  fComponent.CameraYaw := Camera.YawDegrees;
  fComponent.CameraPitch := Camera.PitchDegrees;
  fComponent.CameraDistance := Camera.Distance;
end;

procedure TRecorder3dView.ApplyModel;
var O:T3dRenderOptions;
begin
  if fComponent = nil then Exit;
  SetView(fComponent.CameraYaw, fComponent.CameraPitch,
    fComponent.CameraDistance, fComponent.ShowAxes,
    LongWord(fComponent.BackgroundColor));
  FillChar(O,SizeOf(O),0); O.ShowAxes:=fComponent.ShowAxes;
  O.DrawFill:=fComponent.DrawFill; O.DrawWireframe:=fComponent.DrawWireframe;
  O.DrawPoints:=fComponent.DrawPoints; O.DrawNormals:=fComponent.DrawNormals;
  O.NormalLength:=fComponent.NormalLength; O.BackgroundColor:=LongWord(fComponent.BackgroundColor);
  SetRenderOptions(O);
  LoadConfiguredScene;
end;

procedure TRecorder3dView.LoadConfiguredScene;
var N:string;
begin
  N:=ExpandFileName(fComponent.SceneFileName);
  if SameFileName(N,fLoadedFileName) then Exit;
  if (N='') or not FileExists(N) then begin
    ClearScene; fBindings.AttachScene(nil); ConfigureFrf; fLoadedFileName:=''; Exit;
  end;
  try
    LoadScene(N); ApplyNodeRenderOverrides; fBindings.AttachScene(Scene);
    ConfigureFrf; fLoadedFileName:=N;
  except on E:Exception do begin
    { Transactional loader keeps the previous live scene on failure. }
    Exit;
  end; end;
end;

procedure TRecorder3dView.ApplyNodeRenderOverrides;
var I:Integer; R:TRecorder3dNodeRenderOverride; N:T3dNode;
begin
  if (Scene=nil) or (fComponent=nil) then Exit;
  for I:=0 to High(Scene.Nodes) do Scene.Nodes[I].HasRenderOverride:=False;
  for I:=0 to fComponent.NodeRenderOverrideCount-1 do begin
    R:=fComponent.NodeRenderOverrides[I]; N:=Scene.FindNode(R.NodeId);
    if N=nil then Continue;
    N.HasRenderOverride:=True; N.DrawFillOverride:=R.DrawFill;
    N.DrawWireframeOverride:=R.DrawWireframe; N.DrawPointsOverride:=R.DrawPoints;
    N.DrawNormalsOverride:=R.DrawNormals;
  end;
end;

procedure TRecorder3dView.ConfigureFrf;
var Sampler:TRecorderTagFrfSampler; Engine:T3dSceneMotionEngine;
  Bindings:array of TRecorderFrfMotionBinding; Targets:array of QWord;
  I:Integer; F:TRecorder3dFrfBinding;
begin
  fFrfAdapter.Configure(nil,nil,[]);
  fFrfSampler:=nil; fFrfSink:=nil;
  fFrfFrequencyTag:=ResolveTag(fRegistry,fComponent.FrfFrequencyTagId,fComponent.FrfFrequencyTagName);
  fFrfAnimationPhaseTag:=ResolveTag(fRegistry,fComponent.FrfAnimationPhaseTagId,fComponent.FrfAnimationPhaseTagName);
  if (Scene=nil) or (fComponent.FrfBindingCount=0) then Exit;
  Sampler:=TRecorderTagFrfSampler.Create; Sampler.Configure(fComponent,fRegistry); fFrfSampler:=Sampler;
  Engine:=T3dSceneMotionEngine.Create; SetLength(Targets,fComponent.FrfBindingCount);
  SetLength(Bindings,fComponent.FrfBindingCount);
  for I:=0 to fComponent.FrfBindingCount-1 do begin F:=fComponent.FrfBindings[I];
    Targets[I]:=F.TargetNodeId; Bindings[I].CurveId:=I+1;
    Bindings[I].TargetNodeId:=F.TargetNodeId; Bindings[I].Axis:=F.Axis;
    Bindings[I].Space:=F.Space; Bindings[I].Gain:=F.Gain; Bindings[I].Enabled:=F.Enabled; end;
  Engine.Configure(Scene,Targets); fFrfSink:=Engine;
  fFrfAdapter.Configure(fFrfSampler,fFrfSink,Bindings);
end;

procedure TRecorder3dView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  if not (AComponent is TRecorder3dComponent) then Exit;
  fComponent := TRecorder3dComponent(AComponent);
  fRegistry := ATagRegistry;
  fBindings.Configure(fComponent, fRegistry);
  ApplyModel;
  ApplyNodeRenderOverrides;
  fBindings.AttachScene(Scene);
  ConfigureFrf;
end;

procedure TRecorder3dView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  lBatch: TRecorder3dUpdateBatch;
  lMask: T3dPositionComponents;
  lFrequency,lPhase:Double;
  lHasBatch:Boolean;
begin
  if ATagRegistry<>fRegistry then begin Configure(fComponent,ATagRegistry); Exit; end;
  lHasBatch:=fBindings.Collect(lBatch);
  if lHasBatch and (lBatch.TranslationMask <> []) then
  begin
    lMask := [];
    if r3aX in lBatch.TranslationMask then Include(lMask, pcX);
    if r3aY in lBatch.TranslationMask then Include(lMask, pcY);
    if r3aZ in lBatch.TranslationMask then Include(lMask, pcZ);
    SetNodeTranslation(lBatch.TargetNodeId, lBatch.Translation, lMask);
  end;
  if lHasBatch and lBatch.HasColor and (fBindings.TargetNode <> nil) then
  begin
    fBindings.TargetNode.HasColorOverride := True;
    fBindings.TargetNode.ColorOverride := lBatch.Color;
    MarkDirty;
  end;
  if lHasBatch and lBatch.HasNormalLength then SetRuntimeNormalLength(lBatch.NormalLength);
  if fFrfSampler<>nil then begin lFrequency:=fComponent.FrfFrequencyHz;
    lPhase:=fComponent.FrfAnimationPhaseRadians;
    if fFrfFrequencyTag<>nil then lFrequency:=fFrfFrequencyTag.SignalBuffer.LatestValue;
    if fFrfAnimationPhaseTag<>nil then lPhase:=fFrfAnimationPhaseTag.SignalBuffer.LatestValue;
    if not IsNan(lFrequency) and not IsInfinite(lFrequency) and
      not IsNan(lPhase) and not IsInfinite(lPhase) and
      fFrfAdapter.Update(lFrequency,lPhase) then MarkDirty;
  end;
end;

function TRecorder3dView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(TRecorder3dComponent,
    TRecorder3dView);

end.
