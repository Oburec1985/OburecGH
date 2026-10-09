program ImpactHammerUiSmoke;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Forms, Classes, SysUtils, Math, Controls, Graphics, StdCtrls, ExtCtrls,
  Buttons,
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
    View.btnPreviousImpactClick(nil);
    Check(TLabel(View.FindComponent('lblImpactPosition')).Caption = '1 из 2',
      'previous impact did not refresh the view immediately');
    View.btnNextImpactClick(nil);
    Check(TLabel(View.FindComponent('lblImpactPosition')).Caption = '2 из 2',
      'next impact did not refresh the view immediately');
    View.ApplicationService.FillSnapshot(Snapshot);
    ChangedSnapshot := Snapshot;
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
