program ImpactHammerUiSmoke;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Forms, Classes, SysUtils, Math, Controls, Graphics, StdCtrls, ExtCtrls,
  Buttons, LMessages, LCLType, uRecorderMeraBaseModel, uRecorderMdbRepository,
  uRecorderFormModel, uRecorderTags, uRecorderCoreServices,
  uRecorderVisualControl,
  uRecorderStateMachine, uRecorderImpactHammer, uRecorderImpactHammerModel,
  uRecorderImpactHammerContracts, uRecorderImpactSessionContracts,
  uRecorderImpactHammerView, uRecorderImpactHammerSettingsDialog,
  uRcFrfPeakForm,
  uRcFrfPeaks,
  uOglChart, uOglChartChart, uOglChartPage, uOglChartAxis,
  uOglChartRenderer, uOglChartTypes, uOglChartDrawObj,
  uOglChartTrend, uOglChartTextLabel, uOglChartCursor,
  uSharedColorCheckTable,
  uRecorder3dFrfModifierFrame,
  uRecorder3dSettingsDialog, uRecorder3dModel,
  uRecorderFrfRouteDialog, uRecorderFrfRoute,
  uRecorderFrfIntensityAdapter, uRecorderFrfRepository,
  uRecorderFrfContracts, u3dScene, u3dCoreTypes,
  uOglChartPanZoomListener;

type
  THeadlessSessionCommands = class(TInterfacedObject,
    IRecorderImpactSessionCommandPort)
  private
    fFolder: string;
  public
    constructor Create(const AFolder: string);
    procedure Execute(ACommand: TRecorderImpactSessionCommand);
  end;

constructor THeadlessSessionCommands.Create(const AFolder: string);
begin
  inherited Create;
  fFolder := AFolder;
end;

procedure THeadlessSessionCommands.Execute(ACommand: TRecorderImpactSessionCommand);
var
  Lines: TStringList;
begin
  if not (ACommand in [iscSavePortable, iscSaveCsv]) then
    Exit;
  Lines := TStringList.Create;
  try
    Lines.Text := IntToStr(Ord(ACommand));
    if ACommand = iscSavePortable then
      Lines.SaveToFile(IncludeTrailingPathDelimiter(fFolder) + 'saved.json')
    else
      Lines.SaveToFile(IncludeTrailingPathDelimiter(fFolder) + 'saved.csv');
  finally
    Lines.Free;
  end;
end;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then
    raise Exception.Create(AMessage);
end;

procedure CheckSceneFontDialog;
var
  Model:TRecorder3dComponent;
  Dlg:TRecorder3dSettingsDialog;
begin
  Model:=TRecorder3dComponent.Create;
  Dlg:=nil;
  try
    Dlg:=TRecorder3dSettingsDialog.CreateDialog(nil,Model,nil,0);
    Check(Dlg.seLabelFontSize<>nil,'Scene font-size editor resource loads');
    Dlg.seLabelFontSize.Value:=14;
    Check(Model.LabelFontSize=14,'Scene font-size edits apply live');
  finally Dlg.Free; Model.Free; end;
end;

procedure CheckIntensityMarkers;
var
  Scene: T3dScene;
  Node: T3dNode;
  Repo: TRecorderFrfRepository;
  Provider: IRecorderFrfProvider;
  Curves: array[0..1] of TRecorderFrfCurveData;
  Bindings: array[0..1] of TRecorderFrfIntensityBinding;
  Adapter: TRecorderFrfIntensityAdapter;
  Demo, Retrieved: TRecorderModelPointBinding;
  PreviewRevision: QWord;
  I: Integer;
begin
  Scene := T3dScene.Create;
  Adapter := TRecorderFrfIntensityAdapter.Create;
  Repo := TRecorderFrfRepository.Create;
  Provider := Repo;
  try
    Node := T3dNode.Create;
    Node.Id := 77;
    FillChar(Node.WorldTransform, SizeOf(Node.WorldTransform), 0);
    for I := 0 to 3 do Node.WorldTransform[I * 5] := 1;
    Node.Mesh := T3dMeshData.Create;
    SetLength(Node.Mesh.Positions, 2);
    Node.Mesh.Positions[0] := Vector3d(1, 2, 3);
    Node.Mesh.Positions[1] := Vector3d(4, 5, 6);
    Scene.AddNode(Node);
    for I := 0 to 1 do
    begin
      Curves[I].Id := I + 1;
      SetLength(Curves[I].FrequencyHz, 1);
      SetLength(Curves[I].Magnitude, 1);
      SetLength(Curves[I].Amplitude, 1);
      SetLength(Curves[I].PhaseRadians, 1);
      SetLength(Curves[I].Coherence, 1);
      Curves[I].FrequencyHz[0] := 100;
      Curves[I].Magnitude[0] := 2 * (I + 1);
      Curves[I].Amplitude[0] := 4 - 2 * I;
      Curves[I].Coherence[0] := 1;
      Bindings[I] := Default(TRecorderFrfIntensityBinding);
      Bindings[I].CurveId := I + 1;
      Bindings[I].TargetNodeId := 77;
      Bindings[I].PointNumber := I + 1;
      Bindings[I].Enabled := True;
      Bindings[I].Gain := 1;
      Bindings[I].MarkerSizePixels := 10;
      Bindings[I].IntensitySource := risFrf;
    end;
    Check(Repo.Publish(Curves), 'Publish intensity test curves');
    Adapter.Configure(Provider, Scene, Bindings);
    Adapter.Update(100);
    Check(SameValue(Adapter.Marker(0).SizePixels, 10), 'Half-range marker is 10px');
    Check(SameValue(Adapter.Marker(1).SizePixels, 20), 'Full-range marker is 20px');
    Check(SameValue(Adapter.Marker(1).Position.X, 4), 'Point number maps mesh vertex');
    Adapter.Update(100, 0, True);
    Check(Adapter.Marker(1).SizePixels < 0.001, 'Animation phase changes marker size');
    for I := 0 to 1 do Bindings[I].IntensitySource := risAmplitude;
    Adapter.Configure(Provider, Scene, Bindings);
    Adapter.Update(100);
    Check(SameValue(Adapter.Marker(0).SizePixels, 20), 'Amplitude source differs from FRF');
    Check(SameValue(Adapter.Marker(1).SizePixels, 10), 'Amplitude source scaling');
    for I:=0 to 1 do
    begin
      Bindings[I].BandRms:=True;
      Bindings[I].BandTolerancePercent:=5;
      Bindings[I].GradientEnabled:=True;
      Bindings[I].Color:=clRed;
    end;
    Adapter.Configure(Provider,Scene,Bindings);
    Adapter.Update(100);
    Check(Adapter.Marker(0).Color=clRed,'Configured sphere color at maximum');
    Check(Adapter.Marker(1).Color=clRed,'Vertex gradient does not change sphere color');
    Check(SameValue(Adapter.Marker(1).SizePixels,10),'Band RMS controls marker size');
    Bindings[0].PointLabel:='Маршрут A';
    Bindings[0].HideAnchors:=True;
    Adapter.Configure(Provider,Scene,Bindings);
    Adapter.Update(100);
    Check(Adapter.Marker(0).PointLabel='Маршрут A','Custom point caption reaches marker');
    Check(Adapter.Marker(0).Visible and Adapter.Marker(0).DrawSymbol,
      'Hidden anchors do not hide the intensity sphere');
    Demo := Default(TRecorderModelPointBinding);
    Demo.ModifierTargetNodeId := 77;
    Demo.PointNumber := 2;
    Demo.MarkerSizePixels := 11;
    Adapter.Demonstrate(Scene, Demo);
    Check(Adapter.Marker(0).Visible, 'Demo is visible without FRF provider');
    Check(SameValue(Adapter.Marker(0).SizePixels, 11), 'Demo uses exact edited pixels');
    SetRecorderGeometryPreview('scene-preview', Demo);
    Check(GetRecorderGeometryPreview('scene-preview', Retrieved, PreviewRevision),
      'Preview is available while editing');
    ClearRecorderGeometryPreview;
    Check(not GetRecorderGeometryPreview('scene-preview', Retrieved, PreviewRevision),
      'Closing editor clears demonstration');
  finally
    Adapter.Free;
    Scene.Free;
    Provider := nil;
  end;
end;

procedure CheckChartLayout(AView: TRecorderImpactHammerView;
  const ASizeName: string);
var
  Chart: TOglChart;
  Model: TChartModel;
  Renderer: TOpenGLChartRenderer;
  TimePage: TChartPage;
  FrequencyPage: TChartPage;
  TimeRect: TChartPixelRect;
  FrequencyRect: TChartPixelRect;

  function Meaningful(const ARect: TChartPixelRect): Boolean;
  begin
    Result := ((ARect.Right - ARect.Left) > 80) and
      ((ARect.Bottom - ARect.Top) > 40);
  end;

  function InsideChart(const ARect: TChartPixelRect): Boolean;
  begin
    Result := (ARect.Left >= 0) and (ARect.Top >= 0) and
      (ARect.Right <= Chart.ClientWidth) and
      (ARect.Bottom <= Chart.ClientHeight);
  end;

begin
  Chart := AView.GetChartControl;
  Check((Chart <> nil) and (Chart.ClientWidth > 0) and
    (Chart.ClientHeight > 0), ASizeName + ': chart host has no area');
  Model := TChartModel(Chart.Model);
  Check((Model <> nil) and (Model.ChildCount = 2),
    ASizeName + ': dual-page chart model missing');
  TimePage := TChartPage(Model.Children[0]);
  FrequencyPage := TChartPage(Model.Children[1]);
  Renderer := TOpenGLChartRenderer(Chart.GetRenderer);
  Check(Renderer <> nil, ASizeName + ': chart renderer missing');
  Renderer.Resize(Chart.ClientWidth, Chart.ClientHeight);
  TimeRect := Renderer.GetPageContentRect(TimePage);
  FrequencyRect := Renderer.GetPageContentRect(FrequencyPage);
  Check(Meaningful(TimeRect) and Meaningful(FrequencyRect),
    ASizeName + ': chart page content is too small');
  Check(InsideChart(TimeRect) and InsideChart(FrequencyRect),
    ASizeName + ': chart page content escaped ChartHostPan');
  Check((TimeRect.Bottom <= FrequencyRect.Top) or
    (FrequencyRect.Bottom <= TimeRect.Top),
    ASizeName + ': time and frequency pages overlap');
end;

procedure Stage(const AText: string);
var
  LogFile: TextFile;
begin
  AssignFile(LogFile, IncludeTrailingPathDelimiter(GetTempDir) +
    'ImpactHammerUiSmoke.stage.log');
  if FileExists(IncludeTrailingPathDelimiter(GetTempDir) +
    'ImpactHammerUiSmoke.stage.log') then
    Append(LogFile)
  else
    Rewrite(LogFile);
  try
    WriteLn(LogFile, AText);
  finally
    CloseFile(LogFile);
  end;
end;

procedure PublishImpact(ARegistry: TRecorderTagRegistry; ABaseTime: Double);
const
  Values: array[0..7] of Double = (0, 8, 3, 1, -1, 2, -2, 0.5);
var
  I: Integer;
  Times: array[0..7] of Double;
  Responses: array[0..7] of Double;
begin
  ARegistry.PublishValue('hammer', ABaseTime - 0.125, Values[0]);
  ARegistry.PublishValue('hammer', ABaseTime, Values[1]);
  for I := 0 to 7 do
  begin
    if I = 7 then
      Times[I] := ABaseTime + 0.875
    else
      Times[I] := ABaseTime - 0.125 + I * 0.125;
    Responses[I] := Values[I] * 2;
  end;
  ARegistry.PublishBlock('response', Times, Responses, Length(Times), True);
  for I := 2 to 7 do
    if I = 7 then
      ARegistry.PublishValue('hammer', ABaseTime + 0.875, Values[I])
    else
      ARegistry.PublishValue('hammer', ABaseTime + (I - 1) * 0.125,
        Values[I]);
end;

procedure CheckMdbModelPath;
var
  Page: TRecorderFormPage;
  Model: TRecorderMeraBaseComponent;
  Repository: TRecorderMdbRepository;
  Root, Id, Expected: string;
begin
  Root := IncludeTrailingPathDelimiter(GetTempDir) + 'mdb-model-path-' + IntToStr(GetTickCount64);
  Repository := TRecorderMdbRepository.Create(Root);
  try
    Repository.Open;
    Id := Repository.CreateObject('Object on another page', '', '');
    Expected := IncludeTrailingPathDelimiter(Repository.BasePath + Repository.FindNode(Id).RelativePath);
  finally
    Repository.Free;
  end;
  Page := TRecorderFormPage.Create('other-mdb-page', 'mdb', 'MDB');
  try
    Model := TRecorderMeraBaseComponent.Create;
    Page.AddComponent(Model);
    Model.BasePath := Root;
    Model.ObjectId := Id;
    Check(RecorderMeraObjectDirectory = Expected,
      'Resolve database component on inactive page without constructing its view');
  finally
    Page.Free;
  end;
  Check(RecorderMeraObjectDirectory = '', 'Destroyed model must not leave stale database context');
end;

procedure CheckRouteSpinner;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  View: TRecorderImpactHammerView;
  Port: IRecorderFrfRouteService;
  Entry: TRecorderFrfRouteEntry;
begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  View := TRecorderImpactHammerView.Create(nil);
  try
    Registry.CreateTag('hammer', 64).PollFrequencyHz := 1000;
    Registry.CreateTag('response', 64).PollFrequencyHz := 1000;
    Model.HammerTagId := Registry.FindByName('hammer').Id;
    Model.HammerTagName := 'hammer';
    Model.SampleRateHz := 1000;
    Model.AddResponse.TagId := Registry.FindByName('response').Id;
    Model.Responses[0].TagName := 'response';
    Model.ExportPath := IncludeTrailingPathDelimiter(GetTempDir) +
      'route-spinner-' + IntToStr(GetTickCount64);
    View.Configure(Model, Registry);
    Check(Supports(View.ApplicationService, IRecorderFrfRouteService, Port), 'Route service');
    Entry := Default(TRecorderFrfRouteEntry);
    Entry.PointNumber := 1;
    Entry.PointLabel := 'A';
    Port.Route.Add(Entry);
    Entry.PointNumber := 2;
    Entry.PointLabel := 'B';
    Port.Route.Add(Entry);
    Check(not View.seRoutePoint.Enabled, 'Route spinner disabled outside scenario');
    View.chkScenario.Checked := True;
    View.ScenarioChange(nil);
    Check(View.seRoutePoint.Enabled, 'Route spinner enabled in scenario');
    View.seRoutePoint.Value := 2;
    Check(Port.Route.CurrentIndex = 1, 'Spinner selects second route point');
    Check(Pos('B', View.lblRoutePoint.Caption) > 0, 'Spinner displays point label');
    View.chkScenario.Checked := False;
    View.ScenarioChange(nil);
    Check(not View.seRoutePoint.Enabled, 'Scenario off disables spinner');
  finally
    Port := nil;
    View.Free;
    Model.Free;
    Registry.Free;
    Bus.Free;
  end;
end;

procedure CheckMultiTagDrag;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  Dialog: TRecorderImpactHammerSettingsDialog;
  I: Integer;
  Rect: TRect;
begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  try
    Registry.CreateTag('hammer', 64).PollFrequencyHz := 1000;
    for I := 1 to 3 do
      Registry.CreateTag('response' + IntToStr(I), 64).PollFrequencyHz := 1000;
    Model.HammerTagId := Registry.FindByName('hammer').Id;
    Model.HammerTagName := 'hammer';
    Dialog := TRecorderImpactHammerSettingsDialog.CreateDialog(nil, Model, Registry);
    try
      Dialog.Show;
      Application.ProcessMessages;
      for I := 0 to Dialog.lbAvailableTags.Count - 1 do
        Dialog.lbAvailableTags.Selected[I] := Dialog.lbAvailableTags.Items[I] <> 'hammer';
      Check(Dialog.lbAvailableTags.SelCount = 3, 'Select three response tags');
      for I := 0 to Dialog.lbAvailableTags.Count - 1 do
        if Dialog.lbAvailableTags.Selected[I] then
        begin
          Rect := Dialog.lbAvailableTags.ItemRect(I);
          Dialog.lbAvailableTags.Perform(LM_LBUTTONDOWN, MK_LBUTTON,
            ((Rect.Top + 2) shl 16) or (Rect.Left + 2));
          Break;
        end;
      Check(Dialog.lbAvailableTags.SelCount = 3, 'Drag start must preserve group selection');
      Dialog.tvChannelsDragDrop(Dialog.tvChannels, Dialog.lbAvailableTags, 0, 0);
      Dialog.lbAvailableTags.EndDrag(False);
      Check(Dialog.tvChannels.Items.Count = 4, 'Group drop must add all three response tags');
    finally
      Dialog.Free;
    end;
  finally
    Model.Free;
    Registry.Free;
    Bus.Free;
  end;
end;

var
  Factory: TRecorderComponentFactory;
  Model: TRecorderImpactHammerComponent;
  Binding: TImpactResponseBinding;
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  View: TRecorderImpactHammerView;
  PeakForm: TRcFrfPeakForm;
  PeakRows: TRcPeaks;
  SelectedPeak: TRcPeak;
  HostForm: TForm;
  FormInterface: IVForm;
  Commands: IRecorderImpactSessionCommandPort;
  SavedService: IRecorderImpactHammerApplicationService;
  Snapshot: TRecorderImpactHammerSnapshot;
  ChangedSnapshot: TRecorderImpactHammerSnapshot;
  AxisState: TImpactResultAxisState;
  Folder: string;
  I, J: Integer;
  SeriesIdentity: array[TRecorderImpactResultType] of PtrUInt;
  TimePage: TChartPage;
  FrequencyPage: TChartPage;
  Renderer: TOpenGLChartRenderer;
  FrequencyRect: TChartPixelRect;
  FreqAxis: TChartAxis;
  FlagTrend: cBuffTrend1d;
  TriggerCursor: TChartHorizontalCursor;
  PeakLine: cLineSeries;
  PeakUpdateBefore: QWord;
  PeakY, MovedPeakY: Integer;
  FlagA, FlagB, FlagC: TChartFlagLabel;
  DenseFlags: array[0..11] of TChartFlagLabel;
  SomeFlagHidden: Boolean;
  FlagRectA, FlagRectB, FlagRectC: TRect;
  RespAxis, HammerAxis: TChartAxis;
  CurveList: TSharedColorCheckTable;
  CheckRect, ColorRect: TRect;
  CursorRenderer: TOpenGLChartRenderer;
  CursorPage: TChartPage;
  CursorRect: TChartPixelRect;
  FrfCursor:TChartCursor;
  RoutePort:IRecorderFrfRouteService;
  RouteEntry:TRecorderFrfRouteEntry;
  RouteError,RouteFolder:string;
  SavedCurves:TRecorderRouteCurveArray;
  SearchRoute: TRecorderFrfRoute;
begin
  DeleteFile(IncludeTrailingPathDelimiter(GetTempDir) +
    'ImpactHammerUiSmoke.stage.log');
  Stage('initialize');
  Application.Initialize;
  if (ParamCount > 0) and (ParamStr(1) = '--route-spinner-only') then
  begin
    CheckRouteSpinner;
    WriteLn('RESULT route spinner passed');
    Halt(0);
  end;
  if (ParamCount > 0) and (ParamStr(1) = '--mdb-model-path-only') then
  begin
    CheckMdbModelPath;
    WriteLn('RESULT MDB model path passed');
    Halt(0);
  end;
  if (ParamCount > 0) and (ParamStr(1) = '--multi-tag-drag-only') then
  begin
    CheckMultiTagDrag;
    WriteLn('RESULT multi tag drag passed');
    Halt(0);
  end;
  try
    CheckSceneFontDialog;
  except
    on E:Exception do
    begin WriteLn('RESULT scene font dialog failed: '+E.Message); Halt(3); end;
  end;
  with TRecorderFrfRouteDialog.Create(nil) do
  try
    Check(FindComponent('gridRoute') <> nil, 'Route dialog resource grid missing');
    Check(FindComponent('btnApply') <> nil, 'Route dialog edit command missing');
    Check(FindComponent('btnStart') = nil, 'Route dialog must not start acquisition');
  finally
    Free;
  end;
  Model := TRecorderImpactHammerComponent.Create;
  SearchRoute := TRecorderFrfRoute.Create;
  try
    Model.AddResponse.TagName := 'sensor_X';
    Model.AddResponse.TagName := 'sensor_Y';
    with TRecorderFrfRouteDialog.ShowRoute(nil, Model, SearchRoute, nil, nil, nil) do
    try
      Check(cbChannel.Items.Count = 2, 'Empty route search must list all channels');
      edSearch.Text := 'sensor_y';
      Check(cbChannel.Items.Count = 1, 'Route search must match substring without case');
      edSearch.Text := '';
      Check(cbChannel.Items.Count = 2, 'Cleared route search must restore all channels');
    finally
      Free;
    end;
  finally
    SearchRoute.Free;
    Model.Free;
  end;
  if (ParamCount > 0) and (ParamStr(1) = '--route-search-only') then
  begin
    WriteLn('RESULT route search passed');
    Halt(0);
  end;
  CheckIntensityMarkers;
  with TRecorder3dFrfModifierFrame.Create(nil) do
    Free;
  Stage('initialized');
  Factory := TRecorderComponentFactory.Create;
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  View := nil;
  try
    RegisterRecorderImpactHammerFactory(Factory);
    Stage('factory registered');
    Model := TRecorderImpactHammerComponent(
      Factory.CreateComponent(TRecorderImpactHammerComponent.TypeId));
    Check(Model <> nil, 'ImpactHammer missing from component factory');
    Stage('model created');
    Model.Id := 'impact-ui-smoke';
    Registry.CreateTag('hammer', 64);
    Registry.CreateTag('response', 64);
    Model.HammerTagId := Registry.FindByName('hammer').Id;
    Model.HammerTagName := 'hammer';
    Model.TriggerThreshold := 5;
    Model.TriggerHysteresis := 1;
    Model.PretriggerSamples := 1;
    Model.CaptureSamples := 8;
    Model.FftSize := 8;
    Model.WelchSegmentSize := 8;
    Model.WelchOverlapPercent := 0;
    Model.SampleRateHz := 8;
    Model.ExcitationOwnAxis := True;
    Binding := Model.AddResponse;
    Binding.TagId := Registry.FindByName('response').Id;
    Binding.TagName := 'response';
    Binding.CurveId := 1;
    Binding.ResponseUnitName := 'm/s2';
    for I := Ord(irtSpectrum) to Ord(High(TRecorderImpactResultType)) do
    begin
      AxisState := Model.AxisStates[TRecorderImpactResultType(I)];
      AxisState.AutoScale := True;
      AxisState.LogX := True;
      AxisState.XMin := 1;
      AxisState.XMax := 3;
      Model.AxisStates[TRecorderImpactResultType(I)] := AxisState;
    end;
    Stage('model configured');
    try
      View := TRecorderImpactHammerView.Create(nil);
    except
      on E: Exception do
      begin
        Stage('view create failed: ' + E.ClassName + ': ' + E.Message);
        Stage(BackTraceStrFunc(ExceptAddr));
        Halt(2);
      end;
    end;
    PeakForm := TRcFrfPeakForm.Create(nil);
    try
      Check(PeakForm.FormStyle = fsStayOnTop,
        'FRF extrema window does not remain on top');
      SetLength(PeakRows, 2);
      PeakRows[0].Curve := 'X';
      PeakRows[0].Index := 10;
      PeakRows[0].Frequency := 100;
      PeakRows[1].Curve := 'Y';
      PeakRows[1].Index := 20;
      PeakRows[1].Frequency := 200;
      PeakForm.SetPeaks(PeakRows);
      PeakForm.grdPeaks.Row := 2;
      Check(PeakForm.TryGetSelectedPeak(SelectedPeak) and
        (SelectedPeak.Curve = 'Y') and (SelectedPeak.Index = 20),
        'peak row selection is not retained by the form');
      PeakForm.SetPeaks(PeakRows);
      Check(PeakForm.TryGetSelectedPeak(SelectedPeak) and
        (SelectedPeak.Index = 20),
        'peak selection was lost on refreshing the same result');
      Check(Pos('f', LowerCase(PeakForm.lblFormula.Caption)) > 0,
        'FRF decrement formula is not shown');
      PeakForm.Show;
      Application.ProcessMessages;
      PeakForm.Height := PeakForm.Height + 150;
      PeakForm.Width := PeakForm.Width + 100;
      Application.ProcessMessages;
      Check(PeakForm.grdPeaks.Height > 450,
        'FRF peak grid does not grow with its window');
      Check(PeakForm.grdPeaks.Width > 700,
        'FRF peak grid does not fill resized window width');
    finally
      PeakForm.Free;
    end;
    HostForm := TForm.Create(nil);
    HostForm.SetBounds(0, 0, 1100, 760);
    View.Parent := HostForm;
    View.Align := alClient;
    HostForm.Show;
    Application.ProcessMessages;
    Stage('view created');
    Check(View.FindComponent('ChartHostPan') <> nil,
      'IDE-visible ChartHostPan missing');
    Check(View.FindComponent('btnSettings') is TBitBtn,
      'IDE-visible FRF settings button missing');
    Check(View.FindComponent('pnlState') = nil,
      'obsolete FRF state panel remains');
    Check(TBitBtn(View.FindComponent('btnSettings')).Parent =
      View.FindComponent('NavigationPan'),
      'FRF settings button is not on navigation row');
    HostForm.ClientWidth := 320;
    Application.ProcessMessages;
    Check(TBitBtn(View.FindComponent('btnSettings')).Left +
      TBitBtn(View.FindComponent('btnSettings')).Width <=
      TBitBtn(View.FindComponent('btnSettings')).Parent.ClientWidth,
      'FRF settings button is clipped in a compact widget');
    Check(View.FindComponent('NavigationPan') is TScrollBox,
      'navigation commands are not protected by a scrollable host');
    Check(View.FindComponent('btnGeometryBindings') is TButton,
      'FRF geometry binding editor button is missing');
    Check(View.FindComponent('btnPlayModel') = nil,
      'legacy model animation button remains');
    Check(View.FindComponent('btnStopModel') = nil,
      'legacy model stop button remains');
    Check(View.FindComponent('RightPan') is TScrollBox,
      'right-side controls are not in a responsive scroll box');
    Check(TControl(View.FindComponent('RightPan')).Width >= 260,
      'signal legend/control panel is too narrow');
    Check(TControl(View.FindComponent('btnHide')).Parent =
      View.FindComponent('RightPan'),
      'hide action is not in the right control panel');
    Check(TControl(View.FindComponent('btnDelete')).Parent =
      View.FindComponent('RightPan'),
      'delete action is not in the right control panel');
    Check(View.FindComponent('lblTriggerLevel') is TLabel,
      'trigger level value is missing');
    Check(View.ChartPageCount = 2,
      'workspace must own exactly time and frequency chart pages');
    Check(View.ChartPagesUseAutoLayout,
      'time/frequency chart pages lost cpaAuto layout');
    Check(View.ChartPagesVisible,
      'time/frequency chart pages are not simultaneously visible');
    HostForm.ClientWidth := 640;
    HostForm.ClientHeight := 420;
    Application.ProcessMessages;
    Check((View.ClientWidth = HostForm.ClientWidth) and
      (View.ClientHeight = HostForm.ClientHeight),
      'compact host resize did not reach aligned impact view');
    Check((View.ChartPageCount = 2) and View.ChartPagesUseAutoLayout and
      View.ChartPagesVisible, 'compact resize damaged dual-page layout');
    CheckChartLayout(View, 'compact');
    HostForm.ClientWidth := 1100;
    HostForm.ClientHeight := 760;
    Application.ProcessMessages;
    Check((View.ClientWidth = HostForm.ClientWidth) and
      (View.ClientHeight = HostForm.ClientHeight),
      'large host resize did not reach aligned impact view');
    Check((View.ChartPageCount = 2) and View.ChartPagesUseAutoLayout and
      View.ChartPagesVisible, 'large resize damaged dual-page layout');
    CheckChartLayout(View, 'large');
    Check(Supports(View, IVForm, FormInterface), 'View does not implement IVForm');
    Stage('ivform acquired');
    try
      FormInterface.Configure(Model, Registry);
    except
      on E: Exception do
      begin
        Stage('configure failed: ' + E.ClassName + ': ' + E.Message);
        Stage(BackTraceStrFunc(ExceptAddr));
        Halt(3);
      end;
    end;
    Stage('configured');
    FormInterface.RefreshControl(Registry, 1);
    CurveList := TSharedColorCheckTable(View.FindComponent('clbCurves'));
    Check(CurveList.ItemCount = 1,
      'configured FRF response channel missing before first impact');
    TRadioGroup(View.FindComponent('rgFrequencyResult')).ItemIndex := 0;
    View.frequencyResultChange(nil);
    Check(CurveList.ItemCount = 2,
      'configured spectrum channels missing before first impact');
    Check((CurveList.Cells[CurveList.CheckColumn, 0] = 'Показ') and
      (CurveList.Cells[CurveList.ColorColumn, 0] = 'Цвет') and
      (CurveList.Cells[CurveList.NameColumn, 0] = 'Канал'),
      'shared curve table column headers are missing');
    CurveList.Repaint;
    Application.ProcessMessages;
    CheckRect := CurveList.CellRect(CurveList.CheckColumn, 1);
    Check(ColorToRGB(CurveList.Canvas.Pixels[
      CheckRect.Left + (CheckRect.Width - 13) div 2,
      CheckRect.Top + (CheckRect.Height - 13) div 2]) = ColorToRGB(clWindowText),
      'shared table checkbox border is not painted inside the cell');
    ColorRect := CurveList.CellRect(CurveList.ColorColumn, 2);
    Check(ColorToRGB(CurveList.Canvas.Pixels[
      (ColorRect.Left + ColorRect.Right) div 2,
      (ColorRect.Top + ColorRect.Bottom) div 2]) =
      ColorToRGB(CurveList.ItemColor[1]),
      'shared table color marker is not painted');
    Check(ColorToRGB(CurveList.Canvas.Pixels[ColorRect.Right - 3,
      (ColorRect.Top + ColorRect.Bottom) div 2]) <>
      ColorToRGB(CurveList.ItemColor[1]),
      'shared table color marker stretches across the cell');
    Check(ColorToRGB(CurveList.Canvas.Pixels[ColorRect.Right - 1,
      ColorRect.Bottom - 2]) = ColorToRGB(clBtnShadow),
      'shared table vertical grid line is missing');
    Check(ColorToRGB(CurveList.Canvas.Pixels[ColorRect.Right - 2,
      ColorRect.Bottom - 1]) = ColorToRGB(clBtnShadow),
      'shared table horizontal grid line is missing');
    Check((View.ResultSampleCount(irtTime, 0) = 0) and
      (View.ResultSampleCount(irtSpectrum, 0) = 0),
      'empty configured curves contain samples before first impact');
    CurveList.SelectedIndex := 0;
    CurveList.Checked[0] := False;
    View.curveVisibilityClickCheck(nil, CurveList.SelectedIndex);
    Check(not Model.ExcitationVisible,
      'hammer checkbox does not change model before first impact');
    View.ApplicationService.FillSnapshot(Snapshot);
    Check(Snapshot.Results[irtTime].Curves[0].Visible,
      'unchecked tacho channel disappeared from time domain');
    Check(not Snapshot.Results[irtSpectrum].Curves[0].Visible,
      'unchecked tacho channel remained visible in frequency domain');
    CurveList.Checked[0] := True;
    View.curveVisibilityClickCheck(nil, CurveList.SelectedIndex);
    Check(TChartPage(TChartModel(View.GetChartControl.Model).Children[0]).ChildCount >= 3,
      'time page did not create separate hammer axis');
    Check(SameValue(TChartPage(TChartModel(View.GetChartControl.Model).
      Children[1]).XMinValue, 1),
      'auto FFT range replaced configured X min');
    Check(SameValue(TChartPage(TChartModel(View.GetChartControl.Model).
      Children[1]).XMaxValue, 3),
      'auto FFT range replaced configured X max');
    FrequencyPage := TChartPage(TChartModel(
      View.GetChartControl.Model).Children[1]);
    Check(not FrequencyPage.ResetZoomOnDoubleClick,
      'generic double-click reset still controls frequency page');
    TComboBox(View.FindComponent('cmbEstimator')).ItemIndex := Ord(ifeH2);
    TComboBox(View.FindComponent('cmbWindow')).ItemIndex := Ord(iwHann);
    View.processingOptionsChange(nil);
    Check(Model.Estimator = ifeH2, 'estimator control did not update model');
    Check(Model.WindowKind = iwHann, 'window control did not update model');
    Check(View.FindComponent('spinWelchSize') = nil,
      'Structural Welch size leaked into runtime view');
    Check(View.FindComponent('spinWelchOverlap') = nil,
      'Structural Welch overlap leaked into runtime view');
    Bus.Publish(TRecorderEventBus.MakeEvent(rceRunTransitionAfter, nil,
      '', '', 0, nil, rstStopToView));
    View.ApplicationService.ArmMeasurement;
    View.ApplicationService.FillSnapshot(Snapshot);
    Stage('armed state=' + IntToStr(Ord(Snapshot.State)));
    PublishImpact(Registry, 10);
    Stage('published');
    for I := 0 to 100 do
    begin
      CheckSynchronize(10);
      FormInterface.RefreshControl(Registry, 1);
      if View.ResultSampleCount(irtFrfMagnitude, 0) > 0 then
        Break;
      Sleep(5);
    end;
    View.ApplicationService.FillSnapshot(Snapshot);
    Stage('after wait state=' + IntToStr(Ord(Snapshot.State)) +
      ', impacts=' + IntToStr(Snapshot.ImpactCount) + ', status=' +
      Snapshot.StatusText);
    Check(View.FindComponent('ClientPan') <> nil,
      'ClientPan missing from streamed layout');
    Check(View.FindComponent('RightPan') <> nil,
      'RightPan missing from streamed layout');
    for I := Ord(irtSpectrum) to Ord(High(TRecorderImpactResultType)) do
    begin
      TRadioGroup(View.FindComponent('rgFrequencyResult')).ItemIndex :=
        I - Ord(irtSpectrum);
      View.frequencyResultChange(nil);
      Check(SameValue(TChartPage(TChartModel(View.GetChartControl.Model).
        Children[1]).XMinValue, 1),
        'result mode lost configured FFT X min: ' + IntToStr(I));
      Check(SameValue(TChartPage(TChartModel(View.GetChartControl.Model).
        Children[1]).XMaxValue, 3),
        'result mode lost configured FFT X max: ' + IntToStr(I));
      Stage('result ' + IntToStr(I) + ': series=' +
        IntToStr(View.ResultSeriesCount(TRecorderImpactResultType(I))) +
        ', samples=' + IntToStr(View.ResultSampleCount(
        TRecorderImpactResultType(I), 0)));
      Check(View.ResultSeriesCount(TRecorderImpactResultType(I)) > 0,
        'Result tab has no reusable series: ' + IntToStr(I));
      Check(View.ResultSampleCount(TRecorderImpactResultType(I), 0) > 0,
        'Result tab has no data: ' + IntToStr(I));
      SeriesIdentity[TRecorderImpactResultType(I)] :=
        View.ResultSeriesIdentity(TRecorderImpactResultType(I), 0);
      View.frequencyResultChange(nil);
      Check(View.ResultSeriesIdentity(TRecorderImpactResultType(I), 0) =
        SeriesIdentity[TRecorderImpactResultType(I)],
        'Result tab replaced reusable series: ' + IntToStr(I));
    end;
    Check(View.ResultSeriesCount(irtTime) > 0,
      'Simultaneous time page has no reusable series');
    Check(View.ResultSampleCount(irtTime, 0) > 0,
      'Simultaneous time page has no data');
    TRadioGroup(View.FindComponent('rgFrequencyResult')).ItemIndex := 0;
    View.frequencyResultChange(nil);
    CurveList := TSharedColorCheckTable(View.FindComponent('clbCurves'));
    CurveList.SelectedIndex := 0;
    CurveList.Checked[0] := False;
    View.curveVisibilityClickCheck(nil, CurveList.SelectedIndex);
    View.ApplicationService.FillSnapshot(Snapshot);
    Check(Snapshot.Results[irtTime].Curves[0].Visible and
      not Snapshot.Results[irtSpectrum].Curves[0].Visible,
      'captured tacho visibility is not split between time and frequency');
    CurveList.Checked[0] := True;
    View.curveVisibilityClickCheck(nil, CurveList.SelectedIndex);
    TimePage := TChartPage(TChartModel(View.GetChartControl.Model).Children[0]);
    TriggerCursor := nil;
    for I := 0 to TimePage.ChildCount - 1 do
      if (TimePage.Children[I] is TChartHorizontalCursor) and
         (TimePage.Children[I].Name = 'TriggerLevel') then
        TriggerCursor := TChartHorizontalCursor(TimePage.Children[I]);
    Check((TriggerCursor <> nil) and TriggerCursor.Visible and
      (TriggerCursor.Axis <> nil),
      'time-domain threshold cursor is missing');
    Check(TimePage.HasPresetXRange and
      SameValue(TimePage.PresetMinXValue, 0) and
      SameValue(TimePage.PresetMaxXValue,
        Model.CaptureSamples / Model.SampleRateHz) and
      SameValue(TimePage.XMinValue, TimePage.PresetMinXValue) and
      SameValue(TimePage.XMaxValue, TimePage.PresetMaxXValue),
      'time-domain viewport does not use configured capture duration');
    TRadioGroup(View.FindComponent('rgFrequencyResult')).ItemIndex := 0;
    View.frequencyResultChange(nil);
    TCheckBox(View.FindComponent('chkExtrema')).Checked := True;
    View.extremaChange(nil);
    PeakForm := TRcFrfPeakForm(View.FindComponent('RcFrfPeakForm'));
    Check(PeakForm <> nil, 'FRF peak table was not created');
    FrequencyPage := TChartPage(TChartModel(View.GetChartControl.Model).Children[1]);
    FreqAxis := TChartAxis(FrequencyPage.Children[0]);
    PeakLine := nil;
    for I := 0 to FreqAxis.ChildCount - 1 do
      if (FreqAxis.Children[I] is cLineSeries) and
         (FreqAxis.Children[I].Name = 'PeakThreshold') then
        PeakLine := cLineSeries(FreqAxis.Children[I]);
    Check((PeakLine <> nil) and (PeakLine.PointCount = 2),
      'FRF threshold line is missing');
    Renderer := TOpenGLChartRenderer(View.GetChartControl.GetRenderer);
    FrequencyRect := Renderer.GetPageContentRect(FrequencyPage);
    PeakY := Round(Renderer.AxisValueToPixel(FreqAxis, PeakLine.Points[0].Y,
      FrequencyRect.Bottom, FrequencyRect.Top));
    if PeakY > (FrequencyRect.Top + FrequencyRect.Bottom) div 2 then
      MovedPeakY := Max(FrequencyRect.Top + 2, PeakY - 20)
    else
      MovedPeakY := Min(FrequencyRect.Bottom - 2, PeakY + 20);
    PeakUpdateBefore := PeakForm.UpdateCount;
    View.chartMouseDown(View.GetChartControl, mbLeft, [],
      (FrequencyRect.Left + FrequencyRect.Right) div 2, PeakY);
    View.chartMouseMove(View.GetChartControl, [ssLeft],
      (FrequencyRect.Left + FrequencyRect.Right) div 2, MovedPeakY);
    Check(PeakForm.UpdateCount > PeakUpdateBefore,
      'FRF extrema table did not update during threshold drag');
    View.chartMouseUp(View.GetChartControl, mbLeft, [],
      (FrequencyRect.Left + FrequencyRect.Right) div 2, MovedPeakY);
    TCheckBox(View.FindComponent('chkExtrema')).Checked := False;
    View.extremaChange(nil);
    CurveList := TSharedColorCheckTable(View.FindComponent('clbCurves'));
    Check(CurveList.ItemCount = 2, 'spectrum curve table lost both channels');
    Check(TLabel(View.FindComponent('lblCursor')).Visible,
      'frequency cursor legend is hidden');
    CursorRenderer := TOpenGLChartRenderer(View.GetChartControl.GetRenderer);
    CursorPage := TChartPage(TChartModel(View.GetChartControl.Model).Children[1]);
    CursorRect := CursorRenderer.GetPageContentRect(CursorPage);
    View.chartMouseMove(View.GetChartControl, [],
      Round((CursorRect.Left + CursorRect.Right) / 2),
      Round((CursorRect.Top + CursorRect.Bottom) / 2));
    Check(Pos('Отсчёт:', TLabel(View.FindComponent('lblCursor')).Caption) > 0,
      'frequency cursor legend omitted the nearest sample index');
    View.chartMouseMove(View.GetChartControl, [ssCtrl],
      Round(CursorRect.Left + (CursorRect.Right - CursorRect.Left) * 0.65),
      Round((CursorRect.Top + CursorRect.Bottom) / 2));
    Check(Pos('X2:', TLabel(View.FindComponent('lblCursor')).Caption) > 0,
      'frequency cursor legend omitted the second cursor');
    CurveList.SelectedIndex := 0;
    CurveList.Checked[0] := False;
    View.curveVisibilityClickCheck(nil, CurveList.SelectedIndex);
    Check((View.ResultVisibleSeriesCount(irtTime) = 2) and
      (View.ResultVisibleSeriesCount(irtSpectrum) = 1),
      'hidden tacho did not remain visible only in time domain');
    CurveList.SelectedIndex := 1;
    CurveList.Checked[1] := False;
    View.curveVisibilityClickCheck(nil, CurveList.SelectedIndex);
    Check((View.ResultVisibleSeriesCount(irtTime) = 1) and
      (View.ResultVisibleSeriesCount(irtSpectrum) = 0),
      'response visibility changed the time-only tacho policy');
    CurveList.SelectedIndex := 0;
    CurveList.Checked[0] := True;
    View.curveVisibilityClickCheck(nil, CurveList.SelectedIndex);
    CurveList.SelectedIndex := 1;
    CurveList.Checked[1] := True;
    View.curveVisibilityClickCheck(nil, CurveList.SelectedIndex);
    TimePage := TChartPage(TChartModel(View.GetChartControl.Model).Children[0]);
    RespAxis := TChartAxis(TimePage.FindChild('ResponsesTimeAxis'));
    HammerAxis := TChartAxis(TimePage.FindChild('HammerTimeAxis'));
    Check((RespAxis <> nil) and (HammerAxis <> nil),
      'time axes not found by identity');
    Check(RespAxis.MaxValue > HammerAxis.MaxValue,
      'time response and hammer axes were not fitted independently');
    RespAxis.MaxValue := 1;
    HammerAxis.MaxValue := 1;
    FitPageZoom(TimePage);
    Check((RespAxis.MaxValue > 1) and (HammerAxis.MaxValue > 1),
      'full-page fit did not update both time axes');
    Check(View.ResultSampleCount(irtFrfMagnitude, 0) > 0,
      'FRF chart received no data');
    Stage('before zoom regression');
    AxisState := Model.AxisStates[irtSpectrum];
    AxisState.XMax := 20000;
    AxisState.YMin := 0.1;
    AxisState.YMax := 2000;
    Model.AxisStates[irtSpectrum] := AxisState;
    TRadioGroup(View.FindComponent('rgFrequencyResult')).ItemIndex := 0;
    View.frequencyResultChange(nil);
    FrequencyPage.XMaxValue := 16;
    TChartAxis(FrequencyPage.Children[0]).MaxValue := 19;
    Renderer := TOpenGLChartRenderer(View.GetChartControl.GetRenderer);
    FrequencyRect := Renderer.GetPageContentRect(FrequencyPage);
    View.chartMouseDown(View.GetChartControl, mbLeft, [ssDouble],
      (FrequencyRect.Left + FrequencyRect.Right) div 2,
      (FrequencyRect.Top + FrequencyRect.Bottom) div 2);
    View.chartDblClick(View.GetChartControl);
    Stage('frequency max after double click=' +
      FloatToStr(FrequencyPage.XMaxValue));
    Check(SameValue(FrequencyPage.XMaxValue, 20000),
      'frequency double-click did not restore configured X max');
    Check(SameValue(TChartAxis(FrequencyPage.Children[0]).MaxValue, 2000),
      'frequency double-click did not restore configured Y max');
    FreqAxis := TChartAxis(FrequencyPage.Children[0]);
    FlagTrend := nil;
    for I := 0 to FreqAxis.ChildCount - 1 do
      if (FreqAxis.Children[I] is cBuffTrend1d) and
         cBuffTrend1d(FreqAxis.Children[I]).Visible then
      begin
        FlagTrend := cBuffTrend1d(FreqAxis.Children[I]);
        Break;
      end;
    Check(FlagTrend <> nil, 'frequency series missing for flag layout');
    FlagA := TChartFlagLabel.Create;
    FlagB := TChartFlagLabel.Create;
    FlagC := TChartFlagLabel.Create;
    FlagA.Text := 'F:2 V:1';
    FlagB.Text := 'F:2 V:2';
    FlagC.Text := 'F:20000 V:1';
    FlagA.Trend := FlagTrend;
    FlagB.Trend := FlagTrend;
    FlagC.Trend := FlagTrend;
    FlagA.AnchorX := 2;
    FlagB.AnchorX := 2;
    FlagC.AnchorX := 20000;
    FlagA.AutoLayout := True;
    FlagB.AutoLayout := True;
    FlagC.AutoLayout := True;
    FlagA.Visible := True;
    FlagB.Visible := True;
    FlagC.Visible := True;
    FrequencyPage.AddChild(FlagA);
    FrequencyPage.AddChild(FlagB);
    FrequencyPage.AddChild(FlagC);
    View.GetChartControl.Redraw;
    View.GetChartControl.Repaint;
    Application.ProcessMessages;
    Check(not FlagA.RenderHidden and not FlagB.RenderHidden and
      not FlagC.RenderHidden,
      'visible peak flags were hidden despite available chart space');
    FrequencyRect := Renderer.GetPageContentRect(FrequencyPage);
    FlagRectA.Left := Round(Renderer.XValueToPixel(FrequencyPage, nil,
      FlagA.WorldX, FrequencyRect.Left, FrequencyRect.Right));
    FlagRectA.Top := Round(Renderer.AxisValueToPixel(FreqAxis,
      FlagA.WorldY, FrequencyRect.Bottom, FrequencyRect.Top));
    FlagRectA.Right := FlagRectA.Left + FlagA.Width;
    FlagRectA.Bottom := FlagRectA.Top + FlagA.Height;
    FlagRectB.Left := Round(Renderer.XValueToPixel(FrequencyPage, nil,
      FlagB.WorldX, FrequencyRect.Left, FrequencyRect.Right));
    FlagRectB.Top := Round(Renderer.AxisValueToPixel(FreqAxis,
      FlagB.WorldY, FrequencyRect.Bottom, FrequencyRect.Top));
    FlagRectB.Right := FlagRectB.Left + FlagB.Width;
    FlagRectB.Bottom := FlagRectB.Top + FlagB.Height;
    FlagRectC.Left := Round(Renderer.XValueToPixel(FrequencyPage, nil,
      FlagC.WorldX, FrequencyRect.Left, FrequencyRect.Right));
    FlagRectC.Top := Round(Renderer.AxisValueToPixel(FreqAxis,
      FlagC.WorldY, FrequencyRect.Bottom, FrequencyRect.Top));
    FlagRectC.Right := FlagRectC.Left + FlagC.Width;
    FlagRectC.Bottom := FlagRectC.Top + FlagC.Height;
    Check((FlagRectA.Left >= FrequencyRect.Left) and
      (FlagRectB.Left >= FrequencyRect.Left) and
      (FlagRectA.Right <= FrequencyRect.Right) and
      (FlagRectB.Right <= FrequencyRect.Right) and
      (FlagRectC.Left >= FrequencyRect.Left) and
      (FlagRectC.Right <= FrequencyRect.Right) and
      (FlagRectA.Top >= FrequencyRect.Top) and
      (FlagRectB.Top >= FrequencyRect.Top) and
      (FlagRectC.Top >= FrequencyRect.Top) and
      (FlagRectA.Bottom <= FrequencyRect.Bottom) and
      (FlagRectB.Bottom <= FrequencyRect.Bottom) and
      (FlagRectC.Bottom <= FrequencyRect.Bottom),
      'peak flag escaped frequency chart content');
    Check((FlagRectA.Right <= FlagRectB.Left) or
      (FlagRectB.Right <= FlagRectA.Left) or
      (FlagRectA.Bottom <= FlagRectB.Top) or
      (FlagRectB.Bottom <= FlagRectA.Top),
      'peak flags overlap');
    for I := Low(DenseFlags) to High(DenseFlags) do
    begin
      DenseFlags[I] := TChartFlagLabel.Create;
      DenseFlags[I].Text := 'F:2 V:1';
      DenseFlags[I].Trend := FlagTrend;
      DenseFlags[I].AnchorX := 2;
      DenseFlags[I].AutoLayout := True;
      DenseFlags[I].Highlighted := I = High(DenseFlags);
      DenseFlags[I].Visible := True;
      FrequencyPage.AddChild(DenseFlags[I]);
    end;
    View.GetChartControl.Redraw;
    View.GetChartControl.Repaint;
    Application.ProcessMessages;
    SomeFlagHidden := False;
    for I := Low(DenseFlags) to High(DenseFlags) do
    begin
      SomeFlagHidden := SomeFlagHidden or DenseFlags[I].RenderHidden;
      DenseFlags[I].Visible := False;
    end;
    Check(SomeFlagHidden, 'dense flags should be suppressed when no room remains');
    Check(not DenseFlags[High(DenseFlags)].RenderHidden,
      'selected peak flag lost its place to unselected flags');
    FlagA.Visible := False;
    FlagB.Visible := False;
    FlagC.Visible := False;
    Check(TimePage.HasPresetXRange and
      SameValue(TimePage.PresetMinXValue, 0) and
      SameValue(TimePage.PresetMaxXValue,
        Model.CaptureSamples / Model.SampleRateHz),
      'time zoom is not bounded by configured capture duration');
    Stage('zoom regression passed');
    PublishImpact(Registry, 20);
    for I := 0 to 100 do
    begin
      CheckSynchronize(10);
      FormInterface.RefreshControl(Registry, 1);
      View.ApplicationService.FillSnapshot(Snapshot);
      if (Snapshot.ImpactCount = 2) and Snapshot.CanNavigatePrevious then
        Break;
      Sleep(5);
    end;
    Check(Snapshot.ImpactCount = 2, 'second impact not captured');
    Check(Supports(View.ApplicationService,IRecorderFrfRouteService,RoutePort),
      'Route service exposed');
    RouteEntry:=Default(TRecorderFrfRouteEntry);
    RouteEntry.TargetNodeId:=77;
    RouteEntry.ChannelIndex:=0;
    RouteEntry.PointNumber:=1;
    RoutePort.Route.Add(RouteEntry);
    RouteEntry.PointNumber:=2;
    RoutePort.Route.Add(RouteEntry);
    RouteFolder:=IncludeTrailingPathDelimiter(GetTempDir)+'frf-route-ui-'+IntToStr(GetTickCount64);
    RoutePort.Route.Save(RouteFolder);
    Check(RoutePort.CaptureRouteStep(RouteError),'Capture single realization: '+RouteError);
    Check(not RoutePort.CaptureRouteStep(RouteError),'Repeated realization rejected');
    View.btnPreviousImpactClick(nil);
    Check(RoutePort.CaptureRouteStep(RouteError),'Capture second route realization: '+RouteError);
    Check(RoutePort.Route.LoadSavedCurves(SavedCurves),'Reload route curves from disk');
    Check(Length(SavedCurves)=2,'Both route point realizations saved');
    for I:=0 to RoutePort.Route.Count-1 do
      DeleteFile(IncludeTrailingPathDelimiter(RouteFolder)+'curve-'+
        UIntToStr(RoutePort.Route.Entries[I].CurveId)+'.frf');
    DeleteFile(IncludeTrailingPathDelimiter(RouteFolder)+'route.ini');
    RemoveDir(RouteFolder);
    RoutePort:=nil;
    Check(TLabel(View.FindComponent('lblImpactPosition')).Caption = '1 из 2',
      'previous impact did not refresh the view immediately');
    View.btnNextImpactClick(nil);
    Check(TLabel(View.FindComponent('lblImpactPosition')).Caption = '2 из 2',
      'next impact did not refresh the view immediately');
    View.ApplicationService.FillSnapshot(Snapshot);
    ChangedSnapshot := Snapshot;
    FrfCursor:=TChartCursor.Create;
    FrequencyPage.AddChild(FrfCursor);
    FrfCursor.Visible:=True;
    FrfCursor.CursorType:=cctDouble;
    FrfCursor.X2:=2.5;
    View.chartCursorChanged(nil,FrfCursor);
    Check(SameValue(RecorderSelectedFrfFrequency,2.5),'Alt3 frequency cursor controls intensity');
    View.chartMouseMove(nil,[],200,200);
    Check(SameValue(RecorderSelectedFrfFrequency,2.5),'Mouse hover preserves pinned frequency');
    FrfCursor.Free;
    ChangedSnapshot.ImpactIndex := Snapshot.ImpactIndex + 1;
    ChangedSnapshot.ImpactCount := Snapshot.ImpactCount + 1;
    for I := 0 to High(ChangedSnapshot.Results[irtTime].Curves) do
    begin
      ChangedSnapshot.Results[irtTime].Curves[I].X :=
        Copy(Snapshot.Results[irtTime].Curves[I].X);
      for J := 0 to High(ChangedSnapshot.Results[irtTime].Curves[I].X) do
        ChangedSnapshot.Results[irtTime].Curves[I].X[J] :=
          Snapshot.Results[irtTime].Curves[I].X[J] * 1.5 - 0.02;
    end;
    View.ApplySnapshot(ChangedSnapshot);
    TimePage := TChartPage(TChartModel(View.GetChartControl.Model).Children[0]);
    Check(SameValue(TimePage.XMinValue, 0) and
      SameValue(TimePage.XMaxValue, Model.CaptureSamples / Model.SampleRateHz),
      'new impact replaced configured time-domain X range');
    View.ApplicationService.FillSnapshot(Snapshot);
    View.ApplySnapshot(Snapshot);
    SavedService := View.ApplicationService;
    FormInterface.Configure(Model, Registry);
    Check(View.ApplicationService = SavedService,
      'unchanged editor render replaced the measurement service');
    View.ApplicationService.FillSnapshot(Snapshot);
    Check((Snapshot.ImpactCount = 2) and
      (TLabel(View.FindComponent('lblImpactPosition')).Caption = '2 из 2') and
      (View.ResultSampleCount(irtTime, 0) > 0),
      'unchanged editor render cleared captured impacts');
    Stage('charts');
    Folder := GetTempDir + 'impact-ui-smoke-' + IntToHex(GetTickCount64, 8);
    ForceDirectories(Folder);
    Commands := THeadlessSessionCommands.Create(Folder);
    View.SessionCommands := Commands;
    TButton(View.FindComponent('btnSaveSession')).Click;
    TButton(View.FindComponent('btnSaveCsv')).Click;
    Check(FileExists(IncludeTrailingPathDelimiter(Folder) + 'saved.json'),
      'headless Save command missing');
    Check(FileExists(IncludeTrailingPathDelimiter(Folder) + 'saved.csv'),
      'headless CSV command missing');
    DeleteFile(IncludeTrailingPathDelimiter(Folder) + 'saved.json');
    DeleteFile(IncludeTrailingPathDelimiter(Folder) + 'saved.csv');
    RemoveDir(Folder);
    Stage('commands');
    WriteLn('RESULT ImpactHammerUiSmoke passed');
  finally
    FormInterface := nil;
    SavedService := nil;
    View.Free;
    HostForm.Free;
    Registry.Free;
    Bus.Free;
    Factory.Free;
  end;
end.
