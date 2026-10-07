program RecorderFormModelTest;

{
  RecorderFormModelTest

  Назначение:
    Тест-пример первого ядра экранных формуляров RecorderLnx. Пример показывает,
    как зарегистрировать модельные компоненты, создать страницы, добавить их в
    менеджер и переключить активную страницу без участия LCL UI.
}

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, IniFiles,
  uRecorderFormModel,
  uRecorderProjectFiles, uRecorderTags, uRecorderLissajousMath,
  uRecorder3dModel, uRecorder3dSkinBindingAdapter,
  uRecorderImpactHammerModel, uRecorderSvgParameters,
  u3dPrimitives, u3dCoreTypes, u3dScene, u3dSkin, u3dVertexColors;

type
  TTestPluginOscillographFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create; reintroduce;
  end;

procedure AssertTrue(ACondition: Boolean; const AStep: string); forward;

constructor TTestPluginOscillographFactory.Create;
begin
  inherited Create('test.oscillograph', 'Test Oscillograph',
    TRecorderOscillogramComponent, 360, 220, True);
end;

procedure TestLissajousShiftedTimestamps;
var
  lXT, lXV, lYT, lYV, lOutX, lOutY: TRecorderDoubleArray;
  I, lCount: Integer;
begin
  SetLength(lXT, 5); SetLength(lXV, 5);
  SetLength(lYT, 5); SetLength(lYV, 5);
  for I := 0 to 4 do
  begin
    lXT[I] := I * 0.1; lXV[I] := I;
    lYT[I] := I * 0.1 + 0.02; lYV[I] := 2 * lYT[I];
  end;
  BuildLissajousPairs(lXT, lXV, lYT, lYV, 5, 5, lOutX, lOutY, lCount);
  AssertTrue(lCount >= 3, 'shifted timestamps produce XY pairs');
  AssertTrue(Abs(lOutY[0] - 2 * 0.1) < 1E-9,
    'Y interpolation follows X timestamp');
  Writeln('Lissajous shifted timestamp test passed.');
end;

procedure AssertEquals(AActual, AExpected: Integer; const AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %d, got %d',
      [AStep, AExpected, AActual]);
end;

procedure AssertEquals(const AActual, AExpected, AStep: string);
begin
  if AActual <> AExpected then
    raise Exception.CreateFmt('%s: expected %s, got %s',
      [AStep, AExpected, AActual]);
end;

procedure AssertTrue(ACondition: Boolean; const AStep: string);
begin
  if not ACondition then
    raise Exception.Create(AStep + ': condition is false');
end;

procedure TestProjectCalibrationKeepsSdbReference;
var
  lCalibration: TRecorderCalibration;
  lFile: TStringList;
  lFileName: string;
  lLoaded: TRecorderTagRegistry;
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
begin
  lFileName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'RecorderCalibrationSdbReference.config.json';
  lRegistry := TRecorderTagRegistry.Create(nil);
  lLoaded := TRecorderTagRegistry.Create(nil);
  lFile := TStringList.Create;
  try
    lCalibration := TRecorderCalibration.Create(rckScale);
    lCalibration.Name := 'Linked scale';
    lCalibration.SdbKey := 'Folder\stable-key';
    lRegistry.Calibrations.Add(lCalibration);
    lTag := lRegistry.CreateTag('linked-tag', 64);
    lTag.HardwareCalibrationName := lCalibration.Name;
    lTag.CalibrationNames.Add(lCalibration.Name);
    SaveRecorderProjectConfig(lFileName, lRegistry);

    lFile.LoadFromFile(lFileName);
    AssertTrue(Pos('"hardwareCalibrationSdbKey" : "Folder\\stable-key"',
      lFile.Text) > 0, 'hardware calibration stores stable SDB key');
    AssertTrue(Pos('"sdbKey" : "Folder\\stable-key"', lFile.Text) > 0,
      'channel calibration step stores stable SDB key');

    LoadRecorderProjectConfig(lFileName, lLoaded);
    AssertTrue(lLoaded.FindCalibrationBySdbKey('Folder\stable-key') <> nil,
      'linked calibration resolves by stable SDB key');
    AssertEquals(lLoaded.Tags[0].CalibrationNames[0], 'Linked scale',
      'channel pipeline remains linked after reload');
  finally
    lFile.Free;
    lLoaded.Free;
    lRegistry.Free;
    DeleteFile(lFileName);
  end;
  Writeln('Calibration stable SDB reference test passed.');
end;

procedure TestComponentFactory;
var
  lFactory: TRecorderComponentFactory;
  lComponent: TRecorderVisualComponent;
begin
  lFactory := TRecorderComponentFactory.Create;
  try
    lFactory.RegisterDefaultComponents;

    lComponent := lFactory.CreateComponent(TRecorderStaticTextComponent.TypeId);
    try
      AssertEquals(lComponent.TypeId, 'StaticText', 'static text component type');
    finally
      lComponent.Free;
    end;

    AssertTrue(lFactory.IsComponentRegistered(TRecorderTagValueComponent.TypeId),
      'tag value component is registered');
    AssertTrue(lFactory.IsComponentRegistered(TRecorderOscillogramComponent.TypeId),
      'oscillogram component is registered');
    AssertTrue(not lFactory.IsComponentRegistered('UnknownType'),
      'unknown component type is not registered');

    Writeln('Component factory test passed.');
  finally
    lFactory.Free;
  end;
end;

procedure TestFormPages;
var
  lComponentFactory: TRecorderComponentFactory;
  lFormFactory: TRecorderFormFactory;
  lManager: TRecorderFormManager;
  lBasePage: TRecorderFormPage;
  lDebugPage: TRecorderFormPage;
  lValueComponent: TRecorderVisualComponent;
begin
  lComponentFactory := TRecorderComponentFactory.Create;
  lManager := TRecorderFormManager.Create;
  try
    lComponentFactory.RegisterDefaultComponents;
    lFormFactory := TRecorderFormFactory.Create(lComponentFactory);
    try
      lBasePage := lFormFactory.CreateBlankPage('base', 'BasePage', 'Base page');
      lManager.AddPage(lBasePage);

      lDebugPage := lFormFactory.CreateDebugTagPage('debug', 'DebugPage',
        'Debug tags', 'MemTag');
      lManager.AddPage(lDebugPage);

      AssertEquals(lManager.PageCount, 2, 'page count');
      AssertTrue(lManager.ActivePage = lBasePage, 'first page becomes active');
      AssertEquals(lDebugPage.ComponentCount, 2, 'debug page component count');

      lValueComponent := lDebugPage.FindComponentById('debug.tag-value');
      AssertTrue(lValueComponent <> nil, 'tag value component exists');
      AssertEquals(lValueComponent.TagName, 'MemTag', 'tag binding');
      AssertEquals(lValueComponent.Bounds.Width, 180, 'tag value width');

      lManager.SetActivePageById('debug');
      AssertTrue(lManager.ActivePage = lDebugPage, 'debug page is active');
      AssertTrue(not lManager.TrySetActivePageById('missing'),
        'missing page is not activated');
      AssertTrue(lManager.ActivePage = lDebugPage,
        'active page is preserved after missing page lookup');

      Writeln('Form pages test passed.');
    finally
      lFormFactory.Free;
    end;
  finally
    lManager.Free;
    lComponentFactory.Free;
  end;
end;

procedure TestGuiConfigSavesBaseOscillogramCount;
var
  lComponentFactory: TRecorderComponentFactory;
  lFileName: string;
  lLoaded: TRecorderFormManager;
  lManager: TRecorderFormManager;
  lPage: TRecorderFormPage;
begin
  lFileName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'RecorderFormModelTest.gui.ini';
  if FileExists(lFileName) then
    DeleteFile(lFileName);

  lComponentFactory := TRecorderComponentFactory.Create;
  lLoaded := TRecorderFormManager.Create;
  lManager := TRecorderFormManager.Create;
  try
    lComponentFactory.RegisterDefaultComponents;
    lPage := TRecorderFormPage.Create('BasePage', 'BasePage', 'Base page');
    lPage.BaseOscillogramCount := 5;
    lPage.Detached := True;
    lPage.DetachedLeft := 1920;
    lPage.DetachedTop := 80;
    lPage.DetachedWidth := 1200;
    lPage.DetachedHeight := 800;
    lPage.DetachedMonitor := 1;
    lPage.DetachedMaximized := True;
    lManager.AddPage(lPage);

    SaveRecorderGuiConfig(lFileName, lManager);
    LoadRecorderGuiConfig(lFileName, lLoaded, lComponentFactory);

    AssertEquals(lLoaded.PageCount, 1, 'loaded gui page count');
    AssertEquals(lLoaded.Pages[0].BaseOscillogramCount, 5,
      'loaded base oscillogram count');
    AssertTrue(lLoaded.Pages[0].Detached, 'loaded detached state');
    AssertEquals(lLoaded.Pages[0].DetachedLeft, 1920, 'loaded detached left');
    AssertEquals(lLoaded.Pages[0].DetachedTop, 80, 'loaded detached top');
    AssertEquals(lLoaded.Pages[0].DetachedWidth, 1200, 'loaded detached width');
    AssertEquals(lLoaded.Pages[0].DetachedHeight, 800, 'loaded detached height');
    AssertEquals(lLoaded.Pages[0].DetachedMonitor, 1, 'loaded detached monitor');
    AssertTrue(lLoaded.Pages[0].DetachedMaximized,
      'loaded detached maximized state');
    Writeln('GUI config base oscillogram count test passed.');
  finally
    lManager.Free;
    lLoaded.Free;
    lComponentFactory.Free;
    if FileExists(lFileName) then
      DeleteFile(lFileName);
  end;
end;

procedure TestGuiConfigSavesOscillogramBinding;
var
  lComponentFactory: TRecorderComponentFactory;
  lFileName: string;
  lLoaded: TRecorderFormManager;
  lLoadedOsc: TRecorderOscillogramComponent;
  lManager: TRecorderFormManager;
  lOsc: TRecorderOscillogramComponent;
  lPage: TRecorderFormPage;
begin
  lFileName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'RecorderFormModelOscTest.gui.ini';
  if FileExists(lFileName) then
    DeleteFile(lFileName);

  lComponentFactory := TRecorderComponentFactory.Create;
  lLoaded := TRecorderFormManager.Create;
  lManager := TRecorderFormManager.Create;
  try
    lComponentFactory.RegisterDefaultComponents;
    lPage := TRecorderFormPage.Create('Page1', 'Page1', 'Mnemonic');
    lManager.AddPage(lPage);

    lOsc := TRecorderOscillogramComponent(
      lComponentFactory.CreateComponent(TRecorderOscillogramComponent.TypeId));
    lOsc.Id := 'Page1.osc1';
    lOsc.Name := 'Osc1';
    lOsc.TagName := 'AbsTag';
    lOsc.BindingMode := rtbmAbsoluteTag;
    lOsc.TagOffset := 3;
    lOsc.ClosedInput := True;
    lOsc.AddAxis.Name := 'Y2';
    lOsc.Axes[1].YScale := 2.5;
    lOsc.Axes[1].YOffset := 4.0;
    lOsc.PrimaryAxisIndex := 1;
    lOsc.AddLine.TagName := 'OtherSourceTag';
    lOsc.Lines[0].AxisIndex := 1;
    lOsc.SetBounds(10, 20, 300, 180);
    lPage.AddComponent(lOsc);

    SaveRecorderGuiConfig(lFileName, lManager);
    LoadRecorderGuiConfig(lFileName, lLoaded, lComponentFactory);

    AssertEquals(lLoaded.PageCount, 1, 'loaded osc page count');
    AssertEquals(lLoaded.Pages[0].ComponentCount, 1, 'loaded osc component count');
    AssertTrue(lLoaded.Pages[0].Components[0] is TRecorderOscillogramComponent,
      'loaded component is oscillogram');
    lLoadedOsc := TRecorderOscillogramComponent(lLoaded.Pages[0].Components[0]);
    AssertEquals(lLoadedOsc.TagName, 'AbsTag', 'loaded osc absolute tag');
    AssertEquals(Ord(lLoadedOsc.BindingMode), Ord(rtbmAbsoluteTag),
      'loaded osc binding mode');
    AssertEquals(lLoadedOsc.TagOffset, 3, 'loaded osc tag offset');
    AssertTrue(not lLoadedOsc.ClosedInput,
      'base osc ignores plugin closed input');
    AssertEquals(lLoadedOsc.AxisCount, 1, 'base osc restores one axis');
    AssertEquals(lLoadedOsc.PrimaryAxisIndex, 0, 'base osc primary axis');
    AssertEquals(lLoadedOsc.LineCount, 1, 'loaded osc line count');
    AssertEquals(lLoadedOsc.Lines[0].AxisIndex, 0,
      'base osc ignores plugin line axis');
    Writeln('GUI config base oscillogram binding test passed.');
  finally
    lManager.Free;
    lLoaded.Free;
    lComponentFactory.Free;
    if FileExists(lFileName) then
      DeleteFile(lFileName);
  end;
end;

procedure TestGuiConfigSavesPluginOscillographState;
var
  lComponentFactory: TRecorderComponentFactory;
  lFileName: string;
  lLoaded: TRecorderFormManager;
  lLoadedOsc: TRecorderOscillogramComponent;
  lManager: TRecorderFormManager;
  lOsc: TRecorderOscillogramComponent;
  lPage: TRecorderFormPage;
begin
  lFileName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'RecorderFormModelPluginOscTest.gui.ini';
  if FileExists(lFileName) then DeleteFile(lFileName);
  lComponentFactory := TRecorderComponentFactory.Create;
  lLoaded := TRecorderFormManager.Create;
  lManager := TRecorderFormManager.Create;
  try
    lComponentFactory.RegisterDefaultComponents;
    lComponentFactory.RegisterFactory(TTestPluginOscillographFactory.Create);
    lPage := TRecorderFormPage.Create('Page1', 'Page1', 'Mnemonic');
    lManager.AddPage(lPage);
    lOsc := TRecorderOscillogramComponent(
      lComponentFactory.CreateComponent('test.oscillograph'));
    lOsc.Id := 'Page1.pluginOsc1';
    lOsc.Name := 'PluginOsc1';
    lOsc.TagName := 'AbsTag';
    lOsc.ClosedInput := True;
    lOsc.XScale := 0.5;
    lOsc.AddAxis.Name := 'Y2';
    lOsc.Axes[1].YScale := 2.5;
    lOsc.Axes[1].YOffset := 4.0;
    lOsc.PrimaryAxisIndex := 1;
    lOsc.AddLine.TagName := 'OtherSourceTag';
    lOsc.Lines[0].AxisIndex := 1;
    lPage.AddComponent(lOsc);

    SaveRecorderGuiConfig(lFileName, lManager);
    LoadRecorderGuiConfig(lFileName, lLoaded, lComponentFactory);
    lLoadedOsc := TRecorderOscillogramComponent(
      lLoaded.Pages[0].Components[0]);
    AssertTrue(RecorderIsPluginOscillograph(lLoadedOsc),
      'loaded plugin oscillograph capability');
    AssertTrue(lLoadedOsc.ClosedInput, 'plugin closed input');
    AssertTrue(Abs(lLoadedOsc.XScale - 0.5) < 1E-9,
      'plugin X scale');
    AssertEquals(lLoadedOsc.AxisCount, 2, 'plugin axis count');
    AssertEquals(lLoadedOsc.PrimaryAxisIndex, 1, 'plugin primary axis');
    AssertTrue(Abs(lLoadedOsc.Axes[1].YScale - 2.5) < 1E-9,
      'plugin second axis scale');
    AssertTrue(Abs(lLoadedOsc.Axes[1].YOffset - 4.0) < 1E-9,
      'plugin second axis offset');
    AssertEquals(lLoadedOsc.Lines[0].AxisIndex, 1,
      'plugin line axis');
    Writeln('GUI config plugin oscillograph state test passed.');
  finally
    lManager.Free;
    lLoaded.Free;
    lComponentFactory.Free;
    if FileExists(lFileName) then DeleteFile(lFileName);
  end;
end;

procedure TestGuiConfigSavesComplete3dCamera;
var
  Factory:TRecorderComponentFactory;
  FileName:string;
  Loaded,Legacy,Manager:TRecorderFormManager;
  Page:TRecorderFormPage;
  Source,Restored:TRecorder3dComponent;
  Frf:TRecorder3dFrfBinding;
  Primitive:T3dPrimitiveSpec;
  OverrideItem:TRecorder3dNodeRenderOverride;
  SkinItem:TRecorder3dSkinBinding;
  SkinBone:TRecorder3dSkinBone;
  Gradient:TRecorder3dGradientStrip;
  Anchor:TRecorder3dVertexColorAnchor;
  Ini:TIniFile;
begin
  FileName:=IncludeTrailingPathDelimiter(GetTempDir(False))+
    'RecorderFormModel3dCameraTest.gui.ini';
  if FileExists(FileName) then DeleteFile(FileName);
  Factory:=TRecorderComponentFactory.Create;
  Loaded:=TRecorderFormManager.Create;
  Legacy:=TRecorderFormManager.Create;
  Manager:=TRecorderFormManager.Create;
  try
    Factory.RegisterDefaultComponents;
    RegisterRecorder3dFactory(Factory);
    Page:=TRecorderFormPage.Create('Page1','Page1','Mnemonic');
    Manager.AddPage(Page);
    Source:=TRecorder3dComponent(
      Factory.CreateComponent(TRecorder3dComponent.TypeId));
    Source.Id:='Page1.3d1';
    Source.CameraYaw:=17; Source.CameraPitch:=-11; Source.CameraDistance:=42;
    Source.CameraTargetX:=1.25; Source.CameraTargetY:=-2.5; Source.CameraTargetZ:=7.75;
    Source.CameraRoll:=23.5; Source.CameraFov:=61;
    Frf:=Source.AddFrfBinding;
    Frf.SourceBindingId:='hammer-main';
    Frf.CurveId:=9001;
    Frf.TargetNodeId:=77;
    Primitive.NodeId:=QWord(1) shl 62;
    Primitive.Kind:=pkBeam;
    Primitive.Name:='Beam saved';
    Primitive.Position:=Vector3d(1.25,-2.5,7.75);
    Primitive.Iterations:=4;
    Primitive.CrossSectionIterations:=3;
    Source.AddPrimitive(Primitive);
    Source.DrawPoints:=True;
    Source.PointColor:=$0000A5FF;
    Source.MarkNodeRemoved(15);
    Source.NextPrimitiveNodeId:=Primitive.NodeId+1;
    OverrideItem:=Source.AddNodeRenderOverride;
    OverrideItem.NodeId:=Primitive.NodeId;
    OverrideItem.HasRenderSettings:=True;
    OverrideItem.HasTransform:=True;
    SetIdentity(OverrideItem.LocalTransform);
    OverrideItem.LocalTransform[12]:=12.5;
    OverrideItem.DrawPoints:=True;
    SkinItem:=Source.AddSkinBinding;
    SkinItem.PointName:='Blade P10';
    SkinItem.MeshNodeId:=Primitive.NodeId;
    SkinItem.LogicalVertexId:=1234;
    SkinItem.VertexIdKind:=svikLogical;
    SkinItem.HelperNodeId:=77;
    SkinItem.Weight:=0.375;
    SkinItem.HelperBindWorld[12]:=8.25;
    SkinBone:=Source.EnsureSkinBone(77,'Blade helper');
    SkinBone.OwnerMeshNodeId:=Primitive.NodeId;
    SkinBone.TagIds[r3sX]:=501;
    SkinBone.TagNames[r3sX]:='virtual.skin.x';
    SkinBone.BindLocalTransform[12]:=4.75;
    Gradient:=Source.AddGradientStrip;
    Gradient.Id:=701;
    Gradient.Name:='Temperature';
    Gradient.LeftColor:=$00112233;
    Gradient.RightColor:=$00A0B0C0;
    Gradient.LeftValue:=-12.5;
    Gradient.RightValue:=87.25;
    Anchor:=Source.AddVertexColorAnchor;
    Anchor.Id:=801;
    Anchor.Name:='Blade anchor';
    Anchor.MeshNodeId:=Primitive.NodeId;
    Anchor.LogicalVertexId:=4321;
    Anchor.VertexIdKind:=svikLegacyCorner;
    Anchor.Radius:=2.75;
    Anchor.Falloff:=vcfExponent;
    Anchor.FalloffExponent:=3.5;
    Anchor.GradientId:=Gradient.Id;
    Anchor.TagId:=902;
    Anchor.TagName:='virtual.temperature';
    Anchor.Enabled:=False;
    Anchor.ApplyColor:=False;
    Anchor.ShowValueLabel:=True;
    Page.AddComponent(Source);
    SaveRecorderGuiConfig(FileName,Manager);
    LoadRecorderGuiConfig(FileName,Loaded,Factory);
    Restored:=TRecorder3dComponent(Loaded.Pages[0].Components[0]);
    AssertTrue(Abs(Restored.CameraTargetX-1.25)<1E-9,'3d camera target X');
    AssertTrue(Abs(Restored.CameraTargetY+2.5)<1E-9,'3d camera target Y');
    AssertTrue(Abs(Restored.CameraTargetZ-7.75)<1E-9,'3d camera target Z');
    AssertTrue(Abs(Restored.CameraRoll-23.5)<1E-9,'3d camera roll');
    AssertTrue(Abs(Restored.CameraFov-61)<1E-9,'3d camera FOV');
    AssertTrue((Restored.FrfBindingCount=1) and
      (Restored.FrfBindings[0].CurveId=9001),'3d stable FRF curve id');
    AssertEquals(Restored.FrfBindings[0].SourceBindingId, 'hammer-main',
      '3d FRF source binding id roundtrip');
    AssertTrue(Restored.PrimitiveCount=1,'3d primitive count roundtrip');
    AssertTrue(Restored.DrawPoints and (Restored.PointColor=$0000A5FF),
      '3d point display settings roundtrip');
    AssertTrue((Restored.Primitives[0].NodeId=Primitive.NodeId) and
      (Restored.Primitives[0].Kind=pkBeam) and
      (Restored.Primitives[0].Name='Beam saved') and
      (Restored.Primitives[0].Iterations=4) and
      (Restored.Primitives[0].CrossSectionIterations=3),
      '3d primitive spec roundtrip');
    AssertTrue(Abs(Restored.Primitives[0].Position.Y+2.5)<1E-9,
      '3d primitive position roundtrip');
    AssertTrue((Restored.RemovedNodeCount=1) and
      (Restored.RemovedNodeIds[0]=15),'3d removed node roundtrip');
    AssertTrue(Restored.NextPrimitiveNodeId=Primitive.NodeId+1,
      '3d primitive high-watermark roundtrip');
    AssertTrue((Restored.NodeRenderOverrideCount=1) and
      Restored.NodeRenderOverrides[0].HasRenderSettings and
      Restored.NodeRenderOverrides[0].HasTransform and
      (Abs(Restored.NodeRenderOverrides[0].LocalTransform[12]-12.5)<1E-9),
      '3d user model matrix roundtrip');
    AssertTrue((Restored.SkinBindingCount=1) and
      (Restored.SkinBindings[0].PointName='Blade P10') and
      (Restored.SkinBindings[0].MeshNodeId=Primitive.NodeId) and
      (Restored.SkinBindings[0].LogicalVertexId=1234) and
      (Restored.SkinBindings[0].VertexIdKind=svikLogical) and
      (Restored.SkinBindings[0].HelperNodeId=77) and
      (Abs(Restored.SkinBindings[0].Weight-0.375)<1E-6) and
      (Abs(Restored.SkinBindings[0].HelperBindWorld[12]-8.25)<1E-6),
      '3d skin binding roundtrip');
    AssertTrue((Restored.SkinBoneCount=1) and
      (Restored.SkinBones[0].HelperNodeId=77) and
      (Restored.SkinBones[0].OwnerMeshNodeId=Primitive.NodeId) and
      (Restored.SkinBones[0].Name='Blade helper') and
      (Restored.SkinBones[0].TagIds[r3sX]=501) and
      (Restored.SkinBones[0].TagNames[r3sX]='virtual.skin.x') and
      (Abs(Restored.SkinBones[0].BindLocalTransform[12]-4.75)<1E-6),
      '3d skin bone and point tag roundtrip');
    AssertTrue((Restored.GradientStripCount=1) and
      (Restored.GradientStrips[0].Id=701) and
      (Restored.GradientStrips[0].Name='Temperature') and
      (Restored.GradientStrips[0].LeftColor=$00112233) and
      (Restored.GradientStrips[0].RightColor=$00A0B0C0) and
      (Abs(Restored.GradientStrips[0].LeftValue+12.5)<1E-9) and
      (Abs(Restored.GradientStrips[0].RightValue-87.25)<1E-9),
      '3d gradient strip roundtrip');
    AssertTrue((Restored.VertexColorAnchorCount=1) and
      (Restored.VertexColorAnchors[0].Id=801) and
      (Restored.VertexColorAnchors[0].Name='Blade anchor') and
      (Restored.VertexColorAnchors[0].MeshNodeId=Primitive.NodeId) and
      (Restored.VertexColorAnchors[0].LogicalVertexId=4321) and
      (Restored.VertexColorAnchors[0].VertexIdKind=svikLegacyCorner) and
      (Abs(Restored.VertexColorAnchors[0].Radius-2.75)<1E-6) and
      (Restored.VertexColorAnchors[0].Falloff=vcfExponent) and
      (Abs(Restored.VertexColorAnchors[0].FalloffExponent-3.5)<1E-6) and
      (Restored.VertexColorAnchors[0].GradientId=701) and
      (Restored.VertexColorAnchors[0].TagId=902) and
      (Restored.VertexColorAnchors[0].TagName='virtual.temperature') and
      not Restored.VertexColorAnchors[0].Enabled and
      not Restored.VertexColorAnchors[0].ApplyColor and
      Restored.VertexColorAnchors[0].ShowValueLabel,
      '3d vertex color anchor roundtrip');

    Ini:=TIniFile.Create(FileName);
    try
      Ini.DeleteKey('Page.0.Component.0','GradientStripCount');
      Ini.DeleteKey('Page.0.Component.0','VertexColorAnchorCount');
    finally
      Ini.Free;
    end;
    LoadRecorderGuiConfig(FileName,Legacy,Factory);
    Restored:=TRecorder3dComponent(Legacy.Pages[0].Components[0]);
    AssertTrue((Restored.GradientStripCount=0) and
      (Restored.VertexColorAnchorCount=0),
      'legacy 3d config without vertex color keys stays empty');
  finally
    Manager.Free; Legacy.Free; Loaded.Free; Factory.Free;
    if FileExists(FileName) then DeleteFile(FileName);
  end;
end;

procedure Test3dEditorSnapshotRestoresDeepState;
var
  Source,Snapshot:TRecorder3dComponent;
  Frf:TRecorder3dFrfBinding;
  OverrideItem:TRecorder3dNodeRenderOverride;
  SkinItem:TRecorder3dSkinBinding;
begin
  Source:=TRecorder3dComponent.Create;
  Snapshot:=TRecorder3dComponent.Create;
  try
    Source.SceneFileName:='before-browse.obr';
    Source.BindingTargetNodeId:=77;
    Source.BindingTagIds[r3bPointX]:=123;
    Source.BindingTagNames[r3bPointX]:='PointX';
    Frf:=Source.AddFrfBinding;
    Frf.CurveId:=12345;
    Frf.TargetNodeId:=9;
    Frf.Gain:=2.5;
    OverrideItem:=Source.AddNodeRenderOverride;
    OverrideItem.NodeId:=9;
    OverrideItem.HasRenderSettings:=True;
    OverrideItem.DrawPoints:=True;
    OverrideItem.HasTransform:=True;
    SetIdentity(OverrideItem.LocalTransform);
    OverrideItem.LocalTransform[13]:=4.5;
    SkinItem:=Source.AddSkinBinding;
    SkinItem.PointName:='P1';
    SkinItem.MeshNodeId:=9;
    SkinItem.LogicalVertexId:=44;
    SkinItem.HelperNodeId:=10;
    SkinItem.Weight:=0.6;
    SkinItem.HelperBindWorld[14]:=3.5;
    Snapshot.Assign(Source);

    Source.SceneFileName:='browsed.obr';
    Source.BindingTargetNodeId:=88;
    Source.BindingTagIds[r3bPointX]:=999;
    Source.FrfBindings[0].Gain:=10;
    Source.NodeRenderOverrides[0].DrawPoints:=False;
    Source.SkinBindings[0].Weight:=0.1;
    Source.Assign(Snapshot);

    AssertEquals(Source.SceneFileName,'before-browse.obr',
      '3d Cancel restores scene file');
    AssertTrue(Source.BindingTargetNodeId=77,
      '3d Cancel restores target node');
    AssertTrue(Source.BindingTagIds[r3bPointX]=123,
      '3d Cancel restores tag binding');
    AssertTrue(Abs(Source.FrfBindings[0].Gain-2.5)<1E-9,
      '3d Cancel restores deep FRF binding');
    AssertTrue(Source.FrfBindings[0].CurveId=12345,
      '3d Cancel restores FRF curve id');
    AssertTrue(Source.NodeRenderOverrides[0].HasRenderSettings and
      Source.NodeRenderOverrides[0].DrawPoints,
      '3d Cancel restores deep node override');
    AssertTrue(Source.NodeRenderOverrides[0].HasTransform and
      (Abs(Source.NodeRenderOverrides[0].LocalTransform[13]-4.5)<1E-9),
      '3d Cancel restores model matrix');
    AssertTrue((Source.SkinBindingCount=1) and
      (Source.SkinBindings[0].PointName='P1') and
      (Source.SkinBindings[0].LogicalVertexId=44) and
      (Abs(Source.SkinBindings[0].Weight-0.6)<1E-6) and
      (Abs(Source.SkinBindings[0].HelperBindWorld[14]-3.5)<1E-6),
      '3d Cancel restores deep skin binding');
  finally
    Snapshot.Free;
    Source.Free;
  end;
end;

procedure Test3dSkinHelperMaterialization;
var
  Component:TRecorder3dComponent;
  Scene:T3dScene;
  Spec:T3dPrimitiveSpec;
  Bone:TRecorder3dSkinBone;
  Node:T3dNode;
begin
  Component:=TRecorder3dComponent.Create;
  Scene:=T3dScene.Create;
  try
    FillChar(Spec,SizeOf(Spec),0);
    Spec.NodeId:=QWord(1) shl 62;
    Spec.Kind:=pkCube;
    Spec.Name:='legacy helper';
    Spec.Iterations:=1;
    Spec.CrossSectionIterations:=1;
    Component.AddPrimitive(Spec);
    Node:=CreatePrimitiveNode(Spec);
    Node.LocalTransform[12]:=4.5;
    Scene.AddNode(Node);
    Bone:=Component.EnsureSkinBone(Spec.NodeId,'P1');
    Bone.BindLocalTransform:=Node.LocalTransform;

    Component.MaterializeSkinHelpers(Scene);

    Node:=Scene.FindNode(Spec.NodeId);
    AssertTrue((Node<>nil) and (Node.Kind=nkDummy) and (Node.Mesh=nil),
      'skin helper materializes as meshless dummy');
    AssertTrue((Component.PrimitiveCount=0) and
      (Abs(Node.LocalTransform[12]-4.5)<1E-6),
      'legacy helper primitive migrates without losing transform');
    AssertEquals(Node.Name,'P1','skin helper name follows durable bone');
  finally
    Scene.Free;
    Component.Free;
  end;
end;

procedure TestImpactHammerProjectRoundTrip;
var
  Factory: TRecorderComponentFactory;
  FileName: string;
  Loaded, Manager: TRecorderFormManager;
  Page: TRecorderFormPage;
  Source, Restored: TRecorderImpactHammerComponent;
  Response: TImpactResponseBinding;
  Values: TStringList;
  Ini: TIniFile;
  ErrorText: string;
begin
  FileName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'RecorderImpactHammerRoundTrip.gui.ini';
  if FileExists(FileName) then
    DeleteFile(FileName);
  Factory := TRecorderComponentFactory.Create;
  Loaded := TRecorderFormManager.Create;
  Manager := TRecorderFormManager.Create;
  Values := TStringList.Create;
  try
    Factory.RegisterDefaultComponents;
    RegisterRecorderImpactHammerFactory(Factory);
    Page := TRecorderFormPage.Create('Page1', 'Page1', 'Mnemonic');
    Manager.AddPage(Page);
    Source := TRecorderImpactHammerComponent(
      Factory.CreateComponent(TRecorderImpactHammerComponent.TypeId));
    Source.Id := 'Page1.hammer1';
    Source.HammerTagId := 101;
    Source.HammerTagName := 'Hammer';
    Source.TriggerPolarity := itpNegative;
    Source.TriggerThreshold := 12.5;
    Source.TriggerHysteresis := 1.5;
    Source.PretriggerSamples := 128;
    Source.CaptureSamples := 2048;
    Source.ImpactCapacity := 17;
    Source.FftSize := 2048;
    Source.ZeroPadFactor := 2;
    Source.WindowKind := iwExponential;
    Source.Estimator := ifeH0;
    Source.CoherenceThreshold := 0.73;
    Source.WelchSegmentSize := 512;
    Source.WelchOverlapPercent := 75;
    Source.SampleRateHz := 5120;
    Source.ExcitationUnitName := 'N';
    Source.ForceWindowFraction := 0.18;
    Source.ExponentialEndFraction := 0.025;
    Source.BasePointNumber := 42;
    Source.Target3dComponentId := 'Page1.scene3d';
    Source.AnimationScale := 123.5;
    Source.AnimationFrequencyHz := 17.25;
    Source.Enabled := False;
    Response := Source.AddResponse;
    Response.TagId := 201;
    Response.TagName := 'R1';
    Response.PointId := 'P10';
    Response.PointGroup := 'BladeA';
    Response.PointIncrement := 10;
    Response.CurveId := 1001;
    Response.Axis := iraY;
    Response.Space := irsWorld;
    Response.Gain := 2.5;
    Response.ResponseUnitName := 'm/s2';
    Response := Source.AddResponse;
    Response.TagId := 202;
    Response.TagName := 'R2';
    Response.PointId := 'P20';
    Response.PointGroup := 'BladeB';
    Response.PointIncrement := 20;
    Response.CurveId := High(QWord) - 10;
    Response.Axis := iraZ;
    Response.Space := irsHelperLocal;
    Response.Gain := -0.75;
    Response.ResponseUnitName := 'mm/s';
    Page.AddComponent(Source);
    SaveRecorderGuiConfig(FileName, Manager);
    Ini := TIniFile.Create(FileName);
    try
      AssertEquals(Ini.ReadInteger('Page.0.Component.0', 'Impact.Version', -1),
        RECORDER_IMPACT_HAMMER_CONFIG_VERSION, 'impact config version');
    finally
      Ini.Free;
    end;
    LoadRecorderGuiConfig(FileName, Loaded, Factory);
    Restored := TRecorderImpactHammerComponent(
      Loaded.Pages[0].Components[0]);
    AssertTrue(Restored.Estimator = ifeH0, 'impact H0 roundtrip');
    AssertTrue(Abs(Restored.SampleRateHz - 5120) < 1E-9,
      'impact sample rate roundtrip');
    AssertEquals(Restored.ExcitationUnitName, 'N', 'impact excitation unit');
    AssertTrue(Restored.ResponseCount = 2, 'impact response count');
    AssertTrue(Restored.BasePointNumber = 42,
      'impact base point roundtrip');
    AssertEquals(Restored.Target3dComponentId, 'Page1.scene3d',
      'impact target 3D component roundtrip');
    AssertTrue(Abs(Restored.AnimationScale - 123.5) < 1E-9,
      'impact animation scale roundtrip');
    AssertTrue(Abs(Restored.AnimationFrequencyHz - 17.25) < 1E-9,
      'impact animation frequency roundtrip');
    AssertTrue(not Restored.Enabled, 'impact enabled policy roundtrip');
    AssertTrue(Restored.Responses[0].CurveId = 1001, 'impact stable curve id');
    AssertEquals(Restored.Responses[0].PointGroup, 'BladeA',
      'impact point group');
    AssertTrue(Restored.Responses[0].PointIncrement = 10,
      'impact D10 point increment');
    AssertTrue(Restored.Responses[0].Space = irsWorld,
      'impact motion space');
    AssertTrue(Abs(Restored.Responses[0].Gain - 2.5) < 1E-9,
      'impact motion gain');
    AssertEquals(Restored.Responses[1].ResponseUnitName, 'mm/s',
      'impact response unit');
    AssertTrue(Restored.Responses[1].CurveId = High(QWord) - 10,
      'impact unsigned stable curve id');
    Restored.SaveToStrings(Values, 'Impact.');
    Values.Values['Impact.TriggerThreshold'] := '-1';
    AssertTrue(not Restored.LoadFromStrings(Values, 'Impact.', ErrorText),
      'invalid impact settings accepted');
    AssertTrue(Abs(Restored.TriggerThreshold - 12.5) < 1E-9,
      'invalid load mutated impact model');
    AssertTrue(Restored.ResponseCount = 2,
      'invalid load mutated impact responses');
  finally
    Values.Free;
    Manager.Free;
    Loaded.Free;
    Factory.Free;
    if FileExists(FileName) then
      DeleteFile(FileName);
  end;
end;

procedure TestSvgBindingRoundTrip;
var
  lFactory: TRecorderComponentFactory;
  lFileName: string;
  lLoaded, lManager: TRecorderFormManager;
  lPage: TRecorderFormPage;
  lSource, lRestored: TRecorderImageComponent;
  lBinding: TRecorderSvgTagBinding;
begin
  lFileName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'RecorderSvgBindingRoundTrip.gui.ini';
  if FileExists(lFileName) then
    DeleteFile(lFileName);
  lFactory := TRecorderComponentFactory.Create;
  lLoaded := TRecorderFormManager.Create;
  lManager := TRecorderFormManager.Create;
  try
    lFactory.RegisterDefaultComponents;
    lPage := TRecorderFormPage.Create('Page1', 'Page1', 'Mnemonic');
    lManager.AddPage(lPage);
    lSource := TRecorderImageComponent(
      lFactory.CreateComponent(TRecorderImageComponent.TypeId));
    lSource.Id := 'Page1.gauge';
    lBinding := lSource.AddSvgBinding;
    lBinding.ParameterName := 'FontFamily';
    lBinding.ValueKind := rsvLiteral;
    lBinding.LiteralValue := 'GOST type B';
    lBinding := lSource.AddSvgBinding;
    lBinding.ParameterName := 'IndicatorVisible';
    lBinding.TagId := 42;
    lBinding.TagName := 'VisibleTag';
    lBinding.ValueKind := rsvVisibleWhenNonZero;
    lPage.AddComponent(lSource);

    SaveRecorderGuiConfig(lFileName, lManager);
    LoadRecorderGuiConfig(lFileName, lLoaded, lFactory);
    lRestored := TRecorderImageComponent(lLoaded.Pages[0].Components[0]);
    AssertEquals(lRestored.SvgBindingCount, 2, 'SVG binding count');
    AssertTrue(lRestored.SvgBindings[0].ValueKind = rsvLiteral,
      'SVG literal kind');
    AssertEquals(lRestored.SvgBindings[0].LiteralValue, 'GOST type B',
      'SVG literal value');
    AssertTrue(lRestored.SvgBindings[1].ValueKind = rsvVisibleWhenNonZero,
      'SVG visibility kind');
    AssertTrue(lRestored.SvgBindings[1].TagId = 42,
      'SVG visibility tag id');
    Writeln('SVG binding roundtrip test passed.');
  finally
    lManager.Free;
    lLoaded.Free;
    lFactory.Free;
    if FileExists(lFileName) then
      DeleteFile(lFileName);
  end;
end;

procedure TestSvgParameterParser;
var
  lError, lFileName, lSource: string;
  lParameters, lFile: TStringList;
begin
  AssertTrue(ValidateSvgParameterTemplate(
    '<svg><text>{{Caption| A &amp; B }}</text></svg>', lError),
    'text SVG parameter accepted');
  AssertTrue(not ValidateSvgParameterTemplate(
    '<svg><path d="M {{X|0}} 0"/></svg>', lError),
    'path data SVG parameter rejected');
  AssertTrue(not ValidateSvgParameterTemplate(
    '<svg><text>{{Broken</text></svg>', lError),
    'malformed SVG parameter rejected');
  AssertTrue(ValidateSvgParameterValue(
    '<svg><path fill="{{Color|#000000}}"/></svg>', 'Color', '#12aBcF',
    lError), 'SVG color accepted');
  AssertTrue(not ValidateSvgParameterValue(
    '<svg><path fill="{{Color|#000000}}"/></svg>', 'Color',
    'url(http://invalid)', lError), 'SVG URL color rejected');
  AssertTrue(not ValidateSvgParameterValue(
    '<svg><g display="{{Visible|inline}}"/></svg>', 'Visible', 'yes',
    lError), 'SVG display enum rejected');
  AssertEquals(EscapeSvgParameterValue('A&B<"'''),
    'A&amp;B&lt;&quot;&apos;', 'SVG XML escaping');
  lSource := ReplaceSvgParameter(
    '<text>{{Caption| unchanged default }}</text>', 'Caption', 'X');
  AssertEquals(lSource, '<text>X</text>', 'SVG default token replacement');

  lFileName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'RecorderSvgParametersTest.svg';
  lParameters := TStringList.Create;
  lFile := TStringList.Create;
  try
    lFile.Text := '<svg><text>{{Caption|  spaced  }}</text>' +
      '<text>{{Caption|ignored duplicate}}</text></svg>';
    lFile.SaveToFile(lFileName);
    ExtractSvgParameters(lFileName, lParameters);
    AssertEquals(lParameters.Count, 1, 'duplicate SVG parameter');
    AssertEquals(lParameters.Names[0], 'Caption', 'SVG parameter name');
    AssertEquals(lParameters.ValueFromIndex[0], '  spaced  ',
      'SVG default whitespace');
  finally
    lFile.Free;
    lParameters.Free;
    DeleteFile(lFileName);
  end;
  Writeln('SVG parameter parser test passed.');
end;

procedure TestParametricGaugeArcConvention;
var
  lFileName, lSource: string;
begin
  lFileName := ExpandFileName('../../../RecorderLnx/Assets/SvgTemplates/' +
    'parametric-dual-gauge.svg');
  lSource := LoadSvgText(lFileName);
  AssertTrue(lSource <> '', 'parametric gauge template loaded');
  AssertTrue(Pos('rotate({{RightGreenStart|0}} 350 235)', lSource) > 0,
    'arc Start=0 parameter');
  AssertTrue(Pos('rotate({{RightWarningStart|120}} 350 235)', lSource) > 0,
    'arc positive clockwise Start parameter');
  AssertTrue(Pos('rotate({{LeftGreenStart|-180}} 350 235)', lSource) > 0,
    'arc negative Start parameter');
  AssertTrue(Pos('transform="rotate(-90 350 235)"', lSource) > 0,
    'circle 3 oclock origin normalized to 12 oclock');
  lSource := '<g transform="rotate({{Start|0}} 350 235)">' +
    '<circle transform="rotate(-90 350 235)"/></g>';
  AssertTrue(Pos('rotate(0 350 235)', ReplaceSvgParameter(lSource,
    'Start', '0')) > 0, 'arc 0 degrees is 12 oclock');
  AssertTrue(Pos('rotate(90 350 235)', ReplaceSvgParameter(lSource,
    'Start', '90')) > 0, 'arc 90 degrees is clockwise');
  AssertTrue(Pos('rotate(-90 350 235)', ReplaceSvgParameter(lSource,
    'Start', '-90')) > 0, 'arc minus 90 degrees is counterclockwise');
  Writeln('Parametric gauge arc convention test passed.');
end;

procedure TestSkinBoneBindDoesNotDriftOnReconfigure;
var
  Component:TRecorder3dComponent;
  Registry:TRecorderTagRegistry;
  Scene:T3dScene;
  Helper:T3dNode;
  Bone:TRecorder3dSkinBone;
  Tag:TRecorderTag;
  Adapter:TRecorder3dSkinBindingAdapter;
begin
  Component:=TRecorder3dComponent.Create;
  Registry:=TRecorderTagRegistry.Create(nil);
  Scene:=T3dScene.Create;
  Adapter:=TRecorder3dSkinBindingAdapter.Create;
  try
    Helper:=T3dNode.Create;
    Helper.Id:=101;
    SetIdentity(Helper.LocalTransform);
    Helper.LocalTransform[12]:=10;
    Scene.AddNode(Helper);
    Bone:=Component.EnsureSkinBone(101,'P1');
    Bone.BindLocalTransform:=Helper.LocalTransform;
    Tag:=Registry.CreateTag('skin-x',64);
    Bone.TagIds[r3sX]:=Tag.Id;
    Bone.TagNames[r3sX]:=Tag.Name;
    Tag.SignalBuffer.AddSample(0,2);
    Adapter.Configure(Component,Registry);
    Adapter.AttachScene(Scene);
    AssertTrue(Adapter.ApplyChanged,'first skin tag apply');
    AssertTrue(Abs(Helper.LocalTransform[12]-12)<1E-6,
      'skin tag uses durable bind translation');
    Adapter.Configure(Component,Registry);
    Adapter.AttachScene(Scene);
    AssertTrue(Adapter.ApplyChanged,'skin tag apply after reconfigure');
    AssertTrue(Abs(Helper.LocalTransform[12]-12)<1E-6,
      'skin bind translation does not accumulate');
  finally
    Adapter.Free;
    Scene.Free;
    Registry.Free;
    Component.Free;
  end;
  Writeln('Skin bone durable bind test passed.');
end;

procedure TestSkinAdapterConfigureAfterSceneReplacement;
var
  Component:TRecorder3dComponent;
  Registry:TRecorderTagRegistry;
  OldScene:T3dScene;
  Helper:T3dNode;
  Adapter:TRecorder3dSkinBindingAdapter;
begin
  Component:=TRecorder3dComponent.Create;
  Registry:=TRecorderTagRegistry.Create(nil);
  OldScene:=T3dScene.Create;
  Adapter:=TRecorder3dSkinBindingAdapter.Create;
  try
    Helper:=T3dNode.Create;
    Helper.Id:=201;
    SetIdentity(Helper.LocalTransform);
    OldScene.AddNode(Helper);
    Component.EnsureSkinBone(201,'replace-test');
    Adapter.Configure(Component,Registry);
    Adapter.AttachScene(OldScene);
    OldScene.Free;
    OldScene:=nil;
    { Reentrant settings Apply used to dereference the freed scene here. }
    Adapter.Configure(Component,Registry);
    Adapter.AttachScene(nil);
    AssertTrue(not Adapter.ApplyChanged,
      'detached skin adapter is inert after scene replacement');
  finally
    Adapter.Free;
    OldScene.Free;
    Registry.Free;
    Component.Free;
  end;
  Writeln('Skin adapter scene replacement test passed.');
end;

begin
  TestProjectCalibrationKeepsSdbReference;
  TestComponentFactory;
  TestFormPages;
  TestGuiConfigSavesBaseOscillogramCount;
  TestGuiConfigSavesOscillogramBinding;
  TestGuiConfigSavesPluginOscillographState;
  TestGuiConfigSavesComplete3dCamera;
  Test3dEditorSnapshotRestoresDeepState;
  Test3dSkinHelperMaterialization;
  TestImpactHammerProjectRoundTrip;
  TestSvgBindingRoundTrip;
  TestSvgParameterParser;
  TestSkinBoneBindDoesNotDriftOnReconfigure;
  TestSkinAdapterConfigureAfterSceneReplacement;
  TestParametricGaugeArcConvention;
  TestLissajousShiftedTimestamps;
end.
