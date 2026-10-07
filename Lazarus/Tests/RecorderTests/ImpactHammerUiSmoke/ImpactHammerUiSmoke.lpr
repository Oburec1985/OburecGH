program ImpactHammerUiSmoke;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Forms, Classes, SysUtils, Math, Controls, Graphics, StdCtrls, ExtCtrls,
  Buttons, CheckLst,
  uRecorderFormModel, uRecorderTags, uRecorderCoreServices,
  uRecorderVisualControl,
  uRecorderStateMachine, uRecorderImpactHammer, uRecorderImpactHammerModel,
  uRecorderImpactHammerContracts, uRecorderImpactSessionContracts,
  uRecorderImpactHammerView, uRecorderImpactHammerSettingsDialog,
  uOglChart, uOglChartChart, uOglChartPage, uOglChartAxis,
  uOglChartRenderer, uOglChartTypes, uOglChartDrawObj,
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

var
  Factory: TRecorderComponentFactory;
  Model: TRecorderImpactHammerComponent;
  Binding: TImpactResponseBinding;
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  View: TRecorderImpactHammerView;
  HostForm: TForm;
  FormInterface: IVForm;
  Commands: IRecorderImpactSessionCommandPort;
  SavedService: IRecorderImpactHammerApplicationService;
  Snapshot: TRecorderImpactHammerSnapshot;
  AxisState: TImpactResultAxisState;
  Folder: string;
  I: Integer;
  SeriesIdentity: array[TRecorderImpactResultType] of PtrUInt;
  TimePage: TChartPage;
  FrequencyPage: TChartPage;
  Renderer: TOpenGLChartRenderer;
  FrequencyRect: TChartPixelRect;
  RespAxis, HammerAxis: TChartAxis;
  CurveList: TCheckListBox;
  CheckRect: TRect;
  CursorRenderer: TOpenGLChartRenderer;
  CursorPage: TChartPage;
  CursorRect: TChartPixelRect;
begin
  DeleteFile(IncludeTrailingPathDelimiter(GetTempDir) +
    'ImpactHammerUiSmoke.stage.log');
  Stage('initialize');
  Application.Initialize;
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
    CurveList := TCheckListBox(View.FindComponent('clbCurves'));
    Check(CurveList.Count = 1,
      'configured FRF response channel missing before first impact');
    TRadioGroup(View.FindComponent('rgFrequencyResult')).ItemIndex := 0;
    View.frequencyResultChange(nil);
    Check(CurveList.Count = 2,
      'configured spectrum channels missing before first impact');
    CurveList.Repaint;
    Application.ProcessMessages;
    CheckRect := CurveList.ItemRect(0);
    Check(ColorToRGB(CurveList.Canvas.Pixels[CheckRect.Left + 2,
      CheckRect.Top + 3]) = ColorToRGB(clWindowText),
      'owner-drawn checkbox border is not painted inside the item');
    Check((View.ResultSampleCount(irtTime, 0) = 0) and
      (View.ResultSampleCount(irtSpectrum, 0) = 0),
      'empty configured curves contain samples before first impact');
    CurveList.ItemIndex := 0;
    CurveList.Checked[0] := False;
    View.curveVisibilityClickCheck(nil);
    Check(not Model.ExcitationVisible,
      'hammer checkbox does not change model before first impact');
    CurveList.Checked[0] := True;
    View.curveVisibilityClickCheck(nil);
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
    CurveList := TCheckListBox(View.FindComponent('clbCurves'));
    Check(CurveList.Count = 2, 'spectrum curve checklist lost both channels');
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
    CurveList.ItemIndex := 0;
    CurveList.Checked[0] := False;
    View.curveVisibilityClickCheck(nil);
    Check((View.ResultVisibleSeriesCount(irtTime) = 1) and
      (View.ResultVisibleSeriesCount(irtSpectrum) = 1),
      'hammer visibility was not applied to both chart pages');
    CurveList.ItemIndex := 1;
    CurveList.Checked[1] := False;
    View.curveVisibilityClickCheck(nil);
    Check((View.ResultVisibleSeriesCount(irtTime) = 0) and
      (View.ResultVisibleSeriesCount(irtSpectrum) = 0),
      'last hidden channel remains visible on a chart page');
    CurveList.ItemIndex := 0;
    CurveList.Checked[0] := True;
    View.curveVisibilityClickCheck(nil);
    CurveList.ItemIndex := 1;
    CurveList.Checked[1] := True;
    View.curveVisibilityClickCheck(nil);
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
    Model.AxisStates[irtSpectrum] := AxisState;
    TRadioGroup(View.FindComponent('rgFrequencyResult')).ItemIndex := 0;
    View.frequencyResultChange(nil);
    FrequencyPage.XMaxValue := 16;
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
    Check(TimePage.HasPresetXRange and
      SameValue(TimePage.PresetMinXValue,
        Snapshot.Results[irtTime].Curves[0].X[0]) and
      SameValue(TimePage.PresetMaxXValue,
        Snapshot.Results[irtTime].Curves[0].X[
          High(Snapshot.Results[irtTime].Curves[0].X)]),
      'reverse time zoom is not bounded by captured signal');
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
    View.btnPreviousImpactClick(nil);
    Check(TLabel(View.FindComponent('lblImpactPosition')).Caption = '1 из 2',
      'previous impact did not refresh the view immediately');
    View.btnNextImpactClick(nil);
    Check(TLabel(View.FindComponent('lblImpactPosition')).Caption = '2 из 2',
      'next impact did not refresh the view immediately');
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
