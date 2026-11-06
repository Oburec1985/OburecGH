program ImpactHammerUiSmoke;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Forms, Classes, SysUtils, Math, Controls, Graphics, StdCtrls, ExtCtrls, IniFiles,
  Buttons, LMessages, LCLType, uRecorderMeraBaseModel, uRecorderMdbRepository,
  uRecorderProjectFiles,
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
  uRecorder3dImpactBindingController, uRecorderImpactGeometryBindingDialog,
  uRecorderFrfRouteDialog, uRecorderFrfRoute, uRecorderFrfPointStore,
  uRecorderFrfIntensityAdapter, uRecorderFrfRepository,
  uRecorderFrfContracts, u3dScene, u3dCoreTypes,
  uOglChartPanZoomListener, GL, IntfGraphics, FPImage, GraphType;

type
  TGraphWindowTestForm = class(TForm)
  public
    FinishRequested: Boolean;
    constructor Create(AOwner: TComponent); override;
    procedure NativeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

  THeadlessSessionCommands = class(TInterfacedObject,
    IRecorderImpactSessionCommandPort)
  private
    fFolder: string;
  public
    constructor Create(const AFolder: string);
    procedure Execute(ACommand: TRecorderImpactSessionCommand);
  end;

constructor TGraphWindowTestForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
end;

procedure TGraphWindowTestForm.NativeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then FinishRequested := True;
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
forward;

function NativeGraphMode: Boolean;
begin
  Result := ((ParamCount > 0) and (ParamStr(1) = '--graph-native-interactive')) or
    SameText(ExtractFileName(ParamStr(0)), 'ImpactHammerNativeSmoke.exe');
end;

procedure CheckGraphWindows;
var
  lForm: TForm;
  lView: TRecorderImpactHammerView;
  lModel: TRecorderImpactHammerComponent;
  lRegistry: TRecorderTagRegistry;
  lBus: TRecorderEventBus;
  lAxisState: TImpactResultAxisState;
  lChart: TOglChart;
  lRenderer: TOpenGLChartRenderer;
  lPage: TChartPage;
  lRect: TChartPixelRect;
  lWindow: TRecorderImpactFilterWindow;
  lSnapshot: TRecorderImpactHammerSnapshot;
  lStale: TRecorderImpactHammerSnapshot;
  lTimes, lExc, lResp: array[0..99] of Double;
  lRawExcValues, lRectExcitation, lRectResponse: array of Double;
  lBeforeTime, lBeforeFrf, lVerticalFrf, lEndTime: Double;
  lBeforeChartTime, lBeforeChartFrf: Double;
  lRawTimeSum, lRawExcSum, lRawFrfSum: Double;
  lRectFrfSum, lRectExcSpectrum: Double;
  lRectResponseSum, lRectResponseSpectrum: Double;
  lSample: Integer;
  lError: string;
  lX, lY: Integer;
  lKey: Word;
  lBitmap: TBitmap;
  lImage: TLazIntfImage;
  lPixels: array of Byte;
  lColor: TFPColor;
  lRow, lColumn, lOffset, lOrange: Integer;
  lNativeUntil, lNativeRevision: QWord;
  lNativeLog: TextFile;

  function Pixel(ATime: Double): Integer;
  begin
    Result := Round(lRenderer.XValueToPixel(lPage, nil, ATime,
      lRect.Left, lRect.Right));
  end;

  procedure ReadWindow;
  begin
    lView.ApplicationService.FillSnapshot(lSnapshot);
    lWindow := lSnapshot.FilterWindow;
  end;

  procedure MouseEvent(AMessage: Cardinal; AX, AY: Integer; AKeys: PtrUInt);
  begin
    lChart.Perform(AMessage, AKeys, (AX and $FFFF) or ((AY and $FFFF) shl 16));
  end;

  procedure Pump(AMilliseconds: Integer; ARefresh: Boolean = True);
  var lUntil: QWord;
  begin
    lUntil := GetTickCount64 + AMilliseconds;
    repeat
      Application.ProcessMessages;
      if ARefresh then lView.RefreshControl(nil, 0);
      Sleep(5);
    until GetTickCount64 >= lUntil;
  end;

  function CurveSum(AResult: TRecorderImpactResultType; ACurve: Integer): Double;
  var lIndex: Integer;
  begin
    Result := 0;
    Check(Length(lSnapshot.Results[AResult].Curves) > ACurve,
      'captured curve missing');
    Check(Length(lSnapshot.Results[AResult].Curves[ACurve].Y) > 0,
      'captured samples missing');
    for lIndex := 0 to High(lSnapshot.Results[AResult].Curves[ACurve].Y) do
      Result := Result + Abs(lSnapshot.Results[AResult].Curves[ACurve].Y[lIndex]);
  end;

  function ChartSum(AResult: TRecorderImpactResultType; ACurve: Integer): Double;
  var lSeries: cBuffTrend1d; lIndex: Integer;
  begin
    lSeries := cBuffTrend1d(Pointer(lView.ResultSeriesIdentity(AResult, ACurve)));
    Check(lSeries <> nil, 'visible chart series missing');
    Result := 0;
    for lIndex := 0 to lSeries.Count - 1 do Result := Result + Abs(lSeries.Values[lIndex]);
  end;

  procedure DragRectHandle(AFrom, ATo: Double);
  var lHandleOffset: Integer;
  begin
    lChart.Repaint;
    lRect := lRenderer.GetPageContentRect(lPage);
    if SameValue(AFrom, lWindow.StartSeconds) then lHandleOffset := 14
    else lHandleOffset := -14;
    MouseEvent(LM_LBUTTONDOWN, Pixel(AFrom) + lHandleOffset, lRect.Bottom - 8, MK_LBUTTON);
    Check(not lChart.MouseInputEnabled, 'blue bottom rectangle handle was not captured');
    { The real LCL release path is tested synchronously. Worker delivery is
      pumped only after release, not with synthetic native button state held. }
    MouseEvent(LM_LBUTTONUP, Pixel(ATo) + lHandleOffset, lRect.Bottom - 8, 0);
    Pump(200, False);
    ReadWindow;
    Check(lChart.MouseInputEnabled, 'rectangle release did not restore chart input');
  end;

  procedure CheckRectSignals;
  var lIndex: Integer; lExpected: Double;
  begin
    Check(Length(lSnapshot.Results[irtTime].Curves[0].Y) = Length(lRawExcValues),
      'rectangle changed excitation sample count');
    for lIndex := 0 to High(lRawExcValues) do
    begin
      { Existing display baseline removal is independent of rectangle bounds. }
      lExpected := lRectExcitation[lIndex];
      if (lSnapshot.Results[irtTime].Curves[0].X[lIndex] < lWindow.StartSeconds) or
         (lSnapshot.Results[irtTime].Curves[0].X[lIndex] >= lWindow.EndSeconds) then
        lExpected := 0;
      Check(Abs(lSnapshot.Results[irtTime].Curves[0].Y[lIndex] - lExpected) < 1E-8,
        Format('rectangle cut mismatch i=%d t=%.8f y=%.8g expected=%.8g bounds=%.8f..%.8f',
          [lIndex, lSnapshot.Results[irtTime].Curves[0].X[lIndex],
           lSnapshot.Results[irtTime].Curves[0].Y[lIndex], lExpected,
           lWindow.StartSeconds, lWindow.EndSeconds]));
      Check(Abs(lSnapshot.Results[irtTime].Curves[1].Y[lIndex] - lRectResponse[lIndex]) < 1E-8,
        'rectangle incorrectly modified response exponential window');
    end;
  end;

  procedure SaveRectImage;
  var lBlueRows, lLeftX, lRightX, lScanY, lRow, lColumn: Integer;

    function IsBlue(AX, AY: Integer; AEdgeLimit: Integer = 180): Boolean;
    var lPixel: Integer;
    begin
      lPixel := ((lChart.Height - AY - 1) * lChart.Width + AX) * 4;
      Result := (lPixels[lPixel] < AEdgeLimit) and (lPixels[lPixel + 1] < AEdgeLimit) and
        (lPixels[lPixel + 2] > 180);
    end;

  begin
    lChart.Repaint;
    Application.ProcessMessages;
    lRect := lRenderer.GetPageContentRect(lPage);
    lChart.MakeCurrent;
    SetLength(lPixels, lChart.Width * lChart.Height * 4);
    glReadBuffer(GL_FRONT);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(0, 0, lChart.Width, lChart.Height, GL_RGBA, GL_UNSIGNED_BYTE, @lPixels[0]);
    lLeftX := Pixel(lWindow.StartSeconds);
    lRightX := Pixel(lWindow.EndSeconds);
    lBlueRows := 0;
    for lScanY := lRect.Top + 25 to lRect.Bottom - 25 do
      if IsBlue(lLeftX - 1, lScanY) and IsBlue(lLeftX, lScanY) and
         IsBlue(lLeftX + 1, lScanY, 245) and IsBlue(lRightX - 1, lScanY) and
         IsBlue(lRightX, lScanY) and IsBlue(lRightX + 1, lScanY, 245) then Inc(lBlueRows);
    lImage := TLazIntfImage.Create(lChart.Width, lChart.Height, [riqfRGB, riqfAlpha]);
    lBitmap := TBitmap.Create;
    try
      for lRow := 0 to lChart.Height - 1 do
        for lColumn := 0 to lChart.Width - 1 do
        begin
          lOffset := ((lChart.Height - lRow - 1) * lChart.Width + lColumn) * 4;
          lColor.Red := lPixels[lOffset] * 257;
          lColor.Green := lPixels[lOffset + 1] * 257;
          lColor.Blue := lPixels[lOffset + 2] * 257;
          lColor.Alpha := 65535;
          lImage.Colors[lColumn, lRow] := lColor;
        end;
      lBitmap.LoadFromIntfImage(lImage);
      lBitmap.SaveToFile(IncludeTrailingPathDelimiter(GetTempDir) + 'impact-rect-windows.bmp');
    finally lBitmap.Free; lImage.Free end;
    Check(lBlueRows > (lRect.Bottom - lRect.Top - 50) * 0.75,
      Format('rectangle solid-blue 3px coverage rows=%d height=%d x=%d,%d',
        [lBlueRows, lRect.Bottom - lRect.Top, lLeftX, lRightX]));
    Check(IsBlue(lLeftX + 14 - 5, lRect.Bottom - 8) and
      IsBlue(lLeftX + 14 + 5, lRect.Bottom - 8) and
      IsBlue(lRightX - 14 - 5, lRect.Bottom - 8) and
      IsBlue(lRightX - 14 + 5, lRect.Bottom - 8), 'blue bottom square handles missing');
  end;

begin
  lForm := nil;
  if NativeGraphMode then
  begin
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TGraphWindowTestForm, lForm);
  end
  else lForm := TGraphWindowTestForm.CreateNew(nil);
  lModel := TRecorderImpactHammerComponent.Create;
  lBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  try
    lForm.SetBounds(50, 50, 1050, 720);
    lForm.Caption := 'FRF native window test';
    lForm.KeyPreview := True;
    lForm.OnKeyDown := @TGraphWindowTestForm(lForm).NativeKeyDown;
    lModel.Id := 'window-ui-smoke';
    lRegistry.CreateTag('window-exc', 100);
    lRegistry.CreateTag('window-response', 100);
    lRegistry.FindByName('window-exc').PollFrequencyHz := 100;
    lRegistry.FindByName('window-response').PollFrequencyHz := 100;
    lModel.HammerTagId := lRegistry.FindByName('window-exc').Id;
    lModel.HammerTagName := 'window-exc';
    lModel.CaptureSamples := 100;
    lModel.SampleRateHz := 100;
    lModel.FftSize := 64;
    { Rectangle regression covers the complete one-second capture, so both
      late right-boundary motion and early left-boundary motion affect FFT. }
    if (ParamCount > 0) and (ParamStr(1) = '--rect-window-only') then
      lModel.FftSize := 128;
    lModel.WelchSegmentSize := 64;
    lModel.PretriggerSamples := 0;
    lAxisState := lModel.AxisStates[irtFrfMagnitude];
    lAxisState.XMin := 1;
    lAxisState.XMax := 50;
    lAxisState.YMin := 0;
    lAxisState.YMax := 5;
    lAxisState.LogX := False;
    lAxisState.LogY := False;
    lAxisState.AutoScale := False;
    lModel.AxisStates[irtFrfMagnitude] := lAxisState;
    with lModel.AddResponse do
    begin
      TagId := lRegistry.FindByName('window-response').Id;
      TagName := 'window-response';
      CurveId := 1;
    end;
    lView := TRecorderImpactHammerView.Create(lForm);
    lView.Parent := lForm;
    lView.Align := alClient;
    lView.Configure(lModel, lRegistry);
    lForm.Show;
    Application.ProcessMessages;
    Check(lView.FindComponent('tbWindowStart') = nil, 'native window slider remains');
    Check(lView.FindComponent('tbWindowEnd') = nil, 'native window-end slider remains');
    Check(lView.FindComponent('tbExponentialStart') = nil, 'native exponential slider remains');
    Check(lView.FindComponent('tbExponentialLevel') = nil, 'native level slider remains');
    lBus.Publish(TRecorderEventBus.MakeEvent(rceRunTransitionAfter, nil,
      '', '', 0, nil, rstStopToView));
    lView.ApplicationService.SetTriggerEnabled(False);
    for lSample := 0 to 99 do
    begin
      lTimes[lSample] := lSample / 100;
      lExc[lSample] := Sin(2 * Pi * 7 * lTimes[lSample]) + 0.3 * Cos(2 * Pi * 13 * lTimes[lSample]);
      lResp[lSample] := 2 * Sin(2 * Pi * 7 * lTimes[lSample] + 0.2) + 0.7 * Cos(2 * Pi * 13 * lTimes[lSample]);
    end;
    lRegistry.PublishBlock('window-exc', lTimes, lExc, 100, True);
    lRegistry.PublishBlock('window-response', lTimes, lResp, 100, True);
    Check(lView.ApplicationService.TryCaptureRingPortion(lError), lError);
    Pump(200);
    ReadWindow;
    lRawExcSum := CurveSum(irtTime, 0);
    lRawTimeSum := CurveSum(irtTime, 1);
    lRawFrfSum := CurveSum(irtFrfMagnitude, 0);
    lRawExcValues := Copy(lSnapshot.Results[irtTime].Curves[0].Y);
    lWindow := Default(TRecorderImpactFilterWindow);
    lWindow.Enabled := True;
    lWindow.StartSeconds := 0.1;
    lWindow.EndSeconds := 0.9;
    lWindow.ExponentialStartSeconds := 0.3;
    lWindow.ExponentialEndSeconds := 0.7;
    lWindow.ExponentialEndLevel := 0.2;
    Check(lView.ApplicationService.TrySetFilterWindow(lWindow, lError), lError);
    lView.ApplicationService.FillSnapshot(lSnapshot);
    lView.ApplySnapshot(lSnapshot);
    Pump(150);
    ReadWindow;
    lStale := lSnapshot;
    lBeforeTime := CurveSum(irtTime, 1);
    lBeforeFrf := CurveSum(irtFrfMagnitude, 0);
    lBeforeChartTime := ChartSum(irtTime, 1);
    lBeforeChartFrf := ChartSum(irtFrfMagnitude, 0);
    lChart := lView.GetChartControl;
    lChart.Redraw;
    Application.ProcessMessages;
    lRenderer := TOpenGLChartRenderer(lChart.GetRenderer);
    lPage := TChartPage(TChartModel(lChart.Model).Children[0]);
    lRect := lRenderer.GetPageContentRect(lPage);
    if (ParamCount > 0) and (ParamStr(1) = '--rect-window-only') then
    begin
      lRectExcitation := Copy(lSnapshot.Results[irtTime].Curves[0].Y);
      lRectResponse := Copy(lSnapshot.Results[irtTime].Curves[1].Y);
      lRectFrfSum := CurveSum(irtFrfMagnitude, 0);
      lRectExcSpectrum := CurveSum(irtSpectrum, 0);
      DragRectHandle(0.1, 0.2);
      Check(Abs(lWindow.StartSeconds - 0.2) < 0.005, 'left rectangle cursor did not move');
      CheckRectSignals;
      Check(Abs(CurveSum(irtFrfMagnitude, 0) - lRectFrfSum) > 1E-5,
        'rectangular window did not recalculate FRF');
      Check(Abs(CurveSum(irtSpectrum, 0) - lRectExcSpectrum) > 1E-5,
        'rectangular window did not recalculate excitation spectrum');
      Check(Abs(ChartSum(irtFrfMagnitude, 0) - lRectFrfSum) > 1E-5,
        'recalculated rectangular-window FRF was not presented');
      lRectFrfSum := CurveSum(irtFrfMagnitude, 0);
      lRectExcSpectrum := CurveSum(irtSpectrum, 0);
      DragRectHandle(0.9, 0.8);
      Check(Abs(lWindow.EndSeconds - 0.8) < 0.005, 'right rectangle cursor did not move');
      CheckRectSignals;
      Check(Abs(CurveSum(irtFrfMagnitude, 0) - lRectFrfSum) > 1E-5,
        'right rectangle cursor did not recalculate FRF');
      Check(Abs(CurveSum(irtSpectrum, 0) - lRectExcSpectrum) > 1E-5,
        'right rectangle cursor did not recalculate excitation spectrum');
      Check(Abs(ChartSum(irtFrfMagnitude, 0) - lRectFrfSum) > 1E-5,
        'right rectangle cursor frequency result was not presented');
      lPage.XMinValue := 0.1;
      lPage.XMaxValue := 0.9;
      lPage.ZoomedX := True;
      DragRectHandle(lWindow.StartSeconds, 0.25);
      Check(Abs(lWindow.StartSeconds - 0.25) < 0.005,
        'zoomed rectangle cursor used viewport-relative instead of physical time');
      Check(SameValue(lPage.XMinValue, 0.1) and SameValue(lPage.XMaxValue, 0.9),
        'rectangle edit changed selected X zoom');
      CheckRectSignals;
      lRectFrfSum := CurveSum(irtFrfMagnitude, 0);
      lRectExcSpectrum := CurveSum(irtSpectrum, 0);
      lRectResponseSum := CurveSum(irtTime, 1);
      lRectResponseSpectrum := CurveSum(irtSpectrum, 1);
      lRectExcitation := Copy(lSnapshot.Results[irtTime].Curves[0].Y);
      lRect := lRenderer.GetPageContentRect(lPage);
      lY := Round(lRect.Top + 8 + (1 - lWindow.ExponentialEndLevel) *
        (lRect.Bottom - lRect.Top - 16));
      MouseEvent(LM_LBUTTONDOWN, Pixel(lWindow.ExponentialEndSeconds), lY, MK_LBUTTON);
      Check(not lChart.MouseInputEnabled, 'exponential XY handle was not captured');
      lY := Round(lRect.Top + 8 + 0.55 * (lRect.Bottom - lRect.Top - 16));
      MouseEvent(LM_LBUTTONUP, Pixel(0.65), lY, 0);
      Pump(200, False);
      ReadWindow;
      Check(Abs(lWindow.ExponentialEndSeconds - 0.65) < 0.005,
        'exponential handle physical end time was not applied');
      Check(Abs(lWindow.ExponentialEndLevel - 0.45) < 0.02,
        'exponential handle end level was not applied');
      Check(Abs(CurveSum(irtFrfMagnitude, 0) - lRectFrfSum) > 1E-5,
        'exponential window did not recalculate FRF');
      Check(Abs(ChartSum(irtFrfMagnitude, 0) - lRectFrfSum) > 1E-5,
        'exponential frequency result was not presented');
      Check(Abs(CurveSum(irtTime, 1) - lRectResponseSum) > 1E-5,
        'exponential window did not update response time signal');
      Check(Abs(CurveSum(irtSpectrum, 1) - lRectResponseSpectrum) > 1E-5,
        'exponential window did not update response spectrum');
      Check(Abs(CurveSum(irtSpectrum, 0) - lRectExcSpectrum) < 1E-8,
        'exponential window incorrectly changed excitation spectrum');
      for lSample := 0 to High(lRectExcitation) do
        Check(Abs(lSnapshot.Results[irtTime].Curves[0].Y[lSample] - lRectExcitation[lSample]) < 1E-8,
          'exponential window incorrectly changed excitation time signal');
      SaveRectImage;
      lView.chkFilterWindow.Checked := False;
      Pump(200, False);
      ReadWindow;
      Check(not lWindow.Enabled and not GetOrCreatePageCursor(lPage).Visible,
        'disabled rectangular window still active');
      Check(Abs(ChartSum(irtTime, 0) - lRawExcSum) < 1E-6,
        'disable did not present raw excitation');
      Check(Abs(ChartSum(irtTime, 1) - lRawTimeSum) < 1E-6,
        'disable did not present raw response');
      Check(Abs(ChartSum(irtFrfMagnitude, 0) - lRawFrfSum) < 1E-6,
        'disable did not present baseline FRF');
      WriteLn('RESULT blue rectangle cursors passed');
      Exit;
    end;
    if NativeGraphMode then
    begin
      lNativeUntil := GetTickCount64 + 120000;
      lNativeRevision := High(QWord);
      AssignFile(lNativeLog, IncludeTrailingPathDelimiter(GetTempDir) + 'ImpactHammerNativeSmoke.log');
      Rewrite(lNativeLog);
      try
      repeat
        Application.ProcessMessages;
        if lView.ApplicationService.Revision <> lNativeRevision then
        begin
          lNativeRevision := lView.ApplicationService.Revision;
          ReadWindow;
          WriteLn(lNativeLog, 'NATIVE tick=', GetTickCount64,
            ' input=', lChart.MouseInputEnabled, ' enabled=', lWindow.Enabled,
            ' rebuild=', lSnapshot.FilterRebuildPending,
            ' rect=', lWindow.StartSeconds:0:5,
            ':', lWindow.EndSeconds:0:5, ' exp=', lWindow.ExponentialStartSeconds:0:5,
            ':', lWindow.ExponentialEndSeconds:0:5, ' level=', lWindow.ExponentialEndLevel:0:5,
            ' time=', CurveSum(irtTime, 1):0:5, ' frf=', CurveSum(irtFrfMagnitude, 0):0:5);
          Flush(lNativeLog);
        end;
        Sleep(5);
      until TGraphWindowTestForm(lForm).FinishRequested or not lForm.Visible or
        (GetTickCount64 >= lNativeUntil);
      finally CloseFile(lNativeLog) end;
      Exit;
    end;
    if (ParamCount > 0) and (ParamStr(1) = '--graph-capture-only') then
    begin
      SetCaptureControl(lChart);
      Pump(600, False);
      WriteLn('CAPTURECONTROL survived=', GetCaptureControl = lChart);
      SetCaptureControl(nil);
      Exit;
    end;
    lX := Pixel(0.7);
    lY := Round(lRect.Top + 8 + 0.8 * (lRect.Bottom - lRect.Top - 16));
    MouseEvent(LM_LBUTTONDOWN, lX, lY, MK_LBUTTON);
    Check(not lChart.MouseInputEnabled, 'exponential handle did not capture gesture');
    lY := Round(lRect.Top + 8 + 0.5 * (lRect.Bottom - lRect.Top - 16));
    MouseEvent(LM_MOUSEMOVE, Pixel(0.75), lY, MK_LBUTTON);
    Pump(150, False);
    ReadWindow;
    Check(Abs(lWindow.ExponentialEndSeconds - 0.75) < 0.005,
      'live handle X was not queued while mouse held: ' + FloatToStr(lWindow.ExponentialEndSeconds) +
      ' input=' + BoolToStr(lChart.MouseInputEnabled, True) + ' status=' + lSnapshot.StatusText);
    Check(Abs(CurveSum(irtTime, 1) - lBeforeTime) > 0.01,
      'time signal did not change while mouse held');
    Check(Abs(CurveSum(irtFrfMagnitude, 0) - lBeforeFrf) > 0.01,
      'FRF did not change while mouse held');
    Check(not lChart.MouseInputEnabled, 'live repaint lost active drag');
    Check(Abs(ChartSum(irtTime, 1) - lBeforeChartTime) > 0.01,
      'production timer did not present live time signal');
    Check(Abs(ChartSum(irtFrfMagnitude, 0) - lBeforeChartFrf) > 0.01,
      'production timer did not present live FRF');
    MouseEvent(LM_LBUTTONUP, Pixel(0.75), lY, 0);
    ReadWindow;
    Check(lChart.MouseInputEnabled, 'chart input not restored on release');
    Check(Abs(lWindow.ExponentialEndSeconds - 0.75) < 0.005, 'end handle X not committed');
    Check(Abs(lWindow.ExponentialEndLevel - 0.5) < 0.02, 'end handle level not committed');
    Check(SameValue(lWindow.EndSeconds, 0.9), 'exponential handle changed rectangle end');
    lView.ApplySnapshot(lStale);
    MouseEvent(LM_LBUTTONDOWN, Pixel(0.75), lY, MK_LBUTTON);
    Check(not lChart.MouseInputEnabled, 'stale snapshot moved exponential handle');
    MouseEvent(LM_LBUTTONUP, Pixel(0.75), lY, 0);
    Check(Abs(GetOrCreatePageCursor(lPage).X2 - 0.9) < 0.005,
      'stale snapshot moved rectangle');
    Pump(150);
    ReadWindow;
    Check(Abs(lWindow.ExponentialEndSeconds - 0.75) < 0.005,
      'release/timer snapped end handle back');
    { Vertical-only motion changes steepness without changing end time. }
    lRect := lRenderer.GetPageContentRect(lPage);
    lEndTime := lWindow.ExponentialEndSeconds;
    lVerticalFrf := CurveSum(irtFrfMagnitude, 0);
    lY := Round(lRect.Top + 8 + (1 - lWindow.ExponentialEndLevel) *
      (lRect.Bottom - lRect.Top - 16));
    MouseEvent(LM_LBUTTONDOWN, Pixel(lEndTime), lY, MK_LBUTTON);
    lY := Round(lRect.Top + 8 + 0.25 * (lRect.Bottom - lRect.Top - 16));
    MouseEvent(LM_MOUSEMOVE, Pixel(lEndTime), lY, MK_LBUTTON);
    Pump(150, False);
    ReadWindow;
    Check(Abs(lWindow.ExponentialEndSeconds - lEndTime) < 0.005,
      'vertical drag changed end time');
    Check(Abs(lWindow.ExponentialEndLevel - 0.75) < 0.02,
      'vertical drag did not change end level');
    Check(Abs(CurveSum(irtFrfMagnitude, 0) - lVerticalFrf) > 0.01,
      'vertical drag did not recompute FRF while held');
    { Two rapid moves must flush the last one even with no further mouse event. }
    lRect := lRenderer.GetPageContentRect(lPage);
    lY := Round(lRect.Top + 8 + 0.2 * (lRect.Bottom - lRect.Top - 16));
    MouseEvent(LM_MOUSEMOVE, Pixel(lEndTime), lY, MK_LBUTTON);
    lY := Round(lRect.Top + 8 + 0.4 * (lRect.Bottom - lRect.Top - 16));
    MouseEvent(LM_MOUSEMOVE, Pixel(lEndTime), lY, MK_LBUTTON);
    Pump(120, False);
    ReadWindow;
    Check(Abs(lWindow.ExponentialEndLevel - 0.6) < 0.02,
      'coalescing timer did not flush latest vertical position: ' + FloatToStr(lWindow.ExponentialEndLevel));
    MouseEvent(LM_LBUTTONUP, Pixel(lEndTime), lY, 0);
    Pump(100);
    MouseEvent(LM_LBUTTONDOWN, Pixel(0.3), lRect.Top + 8, MK_LBUTTON);
    MouseEvent(LM_MOUSEMOVE, Pixel(0.4), lRect.Top + 8, MK_LBUTTON);
    Pump(100);
    lKey := VK_ESCAPE;
    lChart.OnKeyDown(lChart, lKey, []);
    Pump(100);
    ReadWindow;
    Check(lChart.MouseInputEnabled and (lKey = 0), 'Escape did not cancel handle drag');
    Check(SameValue(lWindow.ExponentialStartSeconds, 0.3), 'Escape committed preview');
    lY := (lRect.Top + lRect.Bottom) div 2;
    MouseEvent(LM_LBUTTONDOWN, Pixel(0.1), lY, MK_LBUTTON);
    MouseEvent(LM_MOUSEMOVE, Pixel(0.2), lY, MK_LBUTTON);
    MouseEvent(LM_LBUTTONUP, Pixel(0.2), lY, 0);
    ReadWindow;
    Check(Abs(lWindow.StartSeconds - 0.2) < 0.005, 'rectangle start cursor not committed');
    Check(SameValue(lWindow.ExponentialStartSeconds, 0.3), 'rectangle cursor changed exponential start');
    Pump(100);
    Check(SameValue(lPage.XMinValue, 0) and SameValue(lPage.XMaxValue, 1),
      'window gesture changed X viewport');
    { Default rectangle boundaries must work before exponential handles move. }
    lWindow.StartSeconds := 0;
    lWindow.EndSeconds := 1;
    lWindow.ExponentialStartSeconds := 0;
    lWindow.ExponentialEndSeconds := 1;
    Check(lView.ApplicationService.TrySetFilterWindow(lWindow, lError), lError);
    ReadWindow;
    lSnapshot.CaptureDurationSeconds := 0.5;
    lView.ApplySnapshot(lSnapshot);
    lChart.Repaint;
    Application.ProcessMessages;
    lRect := lRenderer.GetPageContentRect(lPage);
    lY := (lRect.Top + lRect.Bottom) div 2;
    lView.chartMouseDown(lChart, mbLeft, [], Pixel(0), lY);
    lView.chartMouseUp(lChart, mbLeft, [], Pixel(0.1), lY);
    ReadWindow;
    Check(Abs(lWindow.StartSeconds - 0.1) < 0.005,
      'default rectangle start is frozen by exponential start');
    { Do not pick the orange endpoint that shares X with this green cursor. }
    lY := lRect.Top + 25;
    lView.chartMouseDown(lChart, mbLeft, [], Pixel(1), lY);
    Check(not lChart.MouseInputEnabled, 'default end cursor did not capture gesture');
    lView.chartMouseUp(lChart, mbLeft, [], Pixel(0.8), lY);
    ReadWindow;
    Check(Abs(lWindow.EndSeconds - 0.8) < 0.005,
      'rectangle end incorrectly clamps to partial capture length: ' + FloatToStr(lWindow.EndSeconds));
    Check(SameValue(lWindow.ExponentialEndSeconds, 1),
      'rectangle incorrectly clipped independent response window');
    lView.chartMouseDown(lChart, mbLeft, [], Pixel(lWindow.StartSeconds), lRect.Top + 8);
    Check(not lChart.MouseInputEnabled, 'start handle did not capture gesture');
    lView.chartMouseMove(lChart, [ssLeft], Pixel(0.2), lRect.Top + 8);
    SetCaptureControl(nil);
    Check(lChart.MouseInputEnabled, 'lost capture left chart input disabled');
    ReadWindow;
    Check(lWindow.ExponentialStartSeconds < 0.11, 'lost capture committed draft');
    Pump(150);
    lChart.Redraw;
    lChart.Repaint;
    Application.ProcessMessages;
    { WM_PRINT/GetFormImage cannot capture an OpenGL child. Read its front
      buffer and assert actual envelope pixels, not merely model geometry. }
    lChart.MakeCurrent;
    SetLength(lPixels, lChart.Width * lChart.Height * 4);
    glReadBuffer(GL_FRONT);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(0, 0, lChart.Width, lChart.Height, GL_RGBA,
      GL_UNSIGNED_BYTE, @lPixels[0]);
    lImage := TLazIntfImage.Create(lChart.Width, lChart.Height,
      [riqfRGB, riqfAlpha]);
    lBitmap := TBitmap.Create;
    try
      lOrange := 0;
      for lRow := 0 to lChart.Height - 1 do
        for lColumn := 0 to lChart.Width - 1 do
        begin
          lOffset := ((lChart.Height - lRow - 1) * lChart.Width + lColumn) * 4;
          lColor.Red := lPixels[lOffset] * 257;
          lColor.Green := lPixels[lOffset + 1] * 257;
          lColor.Blue := lPixels[lOffset + 2] * 257;
          lColor.Alpha := 65535;
          lImage.Colors[lColumn, lRow] := lColor;
          if (lPixels[lOffset] > 220) and (lPixels[lOffset + 1] > 70) and
             (lPixels[lOffset + 1] < 190) and (lPixels[lOffset + 2] < 50) then
            Inc(lOrange);
        end;
      Check(lOrange > 100, 'exponential curve/handles not rendered in GL frame');
      lBitmap.LoadFromIntfImage(lImage);
      lBitmap.SaveToFile(IncludeTrailingPathDelimiter(GetTempDir) + 'impact-graph-windows.bmp');
    finally lBitmap.Free; lImage.Free end;
    { Disable also works during an active preview: cancellation must not
      overwrite the desired checkbox value with the drag-start enabled flag. }
    lRect := lRenderer.GetPageContentRect(lPage);
    MouseEvent(LM_LBUTTONDOWN, Pixel(lWindow.ExponentialStartSeconds), lRect.Top + 8, MK_LBUTTON);
    MouseEvent(LM_MOUSEMOVE, Pixel(0.05), lRect.Top + 8, MK_LBUTTON);
    lView.chkFilterWindow.Checked := False;
    Pump(200, False);
    ReadWindow;
    Check(not lWindow.Enabled and not lView.chkFilterWindow.Checked,
      'disabling checkbox during drag was lost');
    Check(lChart.MouseInputEnabled, 'disable left gesture captured');
    Check(not GetOrCreatePageCursor(lPage).Visible, 'disabled rectangle cursor still visible');
    Check(Abs(CurveSum(irtTime, 0) - lRawExcSum) < 1E-6,
      'disabling did not restore unwindowed excitation');
    Check(Abs(CurveSum(irtTime, 1) - lRawTimeSum) < 1E-6,
      'disabling did not restore unwindowed response');
    Check(Abs(CurveSum(irtFrfMagnitude, 0) - lRawFrfSum) < 1E-6,
      'disabling did not restore baseline FRF');
    Check(Abs(ChartSum(irtTime, 0) - lRawExcSum) < 1E-6,
      'disable completion did not present unwindowed excitation');
    Check(Abs(ChartSum(irtTime, 1) - lRawTimeSum) < 1E-6,
      'disable completion did not present unwindowed response');
    Check(Abs(ChartSum(irtFrfMagnitude, 0) - lRawFrfSum) < 1E-6,
      'disable completion did not present baseline FRF');
  finally
    lForm.Free;
    lModel.Free;
    lRegistry.Free;
    lBus.Free;
  end;
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

procedure CheckNumericVertexSort;
var Model: TRecorder3dComponent; Dlg: TRecorder3dSettingsDialog; I, Comparison: Integer;
begin
  Model := TRecorder3dComponent.Create;
  Dlg := nil;
  try
    Dlg := TRecorder3dSettingsDialog.CreateDialog(nil, Model, nil, 0);
    Dlg.sgVertices.RowCount := 4;
    for I := 1 to 3 do Dlg.sgVertices.Cells[0,I] := IntToStr(I);
    Dlg.sgVertices.Cells[7,1] := '10';
    Dlg.sgVertices.Cells[7,2] := '2';
    Dlg.sgVertices.Cells[7,3] := '1';
    Dlg.VerticesHeaderClick(nil, True, 7);
    Check((Dlg.sgVertices.Cells[7,1]='1') and (Dlg.sgVertices.Cells[7,2]='2') and
      (Dlg.sgVertices.Cells[7,3]='10'), 'Vertex labels sort numerically');
    Check(Dlg.sgVertices.Cells[0,1]='3', 'Sorting keeps vertex row identity');
    Dlg.sgVertices.Cells[7,1] := '2 point';
    Dlg.sgVertices.Cells[7,2] := '10 point';
    Dlg.VerticesCompareCells(nil,7,1,7,2,Comparison);
    Check(Comparison<0, 'Leading numeric prefix is compared before suffix');
    Dlg.sgVertices.Cells[7,1] := '999999999999999999999999999999';
    Dlg.sgVertices.Cells[7,2] := '1000000000000000000000000000000';
    Dlg.VerticesCompareCells(nil,7,1,7,2,Comparison);
    Check(Comparison<0, 'Long numeric labels do not overflow');
  finally
    Dlg.Free;
    Model.Free;
  end;
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
    for I:=0 to 1 do
    begin
      SetLength(Curves[I].FrequencyHz,2);
      SetLength(Curves[I].Magnitude,2);
      SetLength(Curves[I].PhaseRadians,2);
      SetLength(Curves[I].Coherence,2);
      Curves[I].FrequencyHz[1]:=200;
      Curves[I].Magnitude[1]:=8-4*I;
      Curves[I].Coherence[1]:=1;
      Bindings[I].BandRms:=False;
      Bindings[I].IntensitySource:=risFrf;
    end;
    Check(Repo.Publish(Curves),'Publish frequency-varying intensity curves');
    SetRecorderFrfDisplayRange(100,200);
    Adapter.Configure(Provider,Scene,[Bindings[0]]);
    Adapter.Update(100);
    Check(SameValue(Adapter.Marker(0).SizePixels,5),'Single point normalized to preset interval peak');
    Adapter.Update(200);
    Check(SameValue(Adapter.Marker(0).SizePixels,20),'Single point changes size with frequency');
    RegisterRecorderFrfProvider(Adapter,Provider);
    try
      Adapter.Configure(RecorderAggregateFrfProvider,Scene,Bindings);
      Adapter.Update(100);
      Check(SameValue(Adapter.Marker(0).SizePixels,5) and
        SameValue(Adapter.Marker(1).SizePixels,10),'Aggregate normalizes to preset interval');
      Adapter.Update(200);
      Check(SameValue(Adapter.Marker(0).SizePixels,20) and
        SameValue(Adapter.Marker(1).SizePixels,10),'Normalized relative sizes follow FRF cursor');
      for I:=0 to 1 do
      begin
        SetLength(Curves[I].FrequencyHz,3);
        SetLength(Curves[I].Magnitude,3);
        SetLength(Curves[I].PhaseRadians,3);
        SetLength(Curves[I].Coherence,3);
        Curves[I].FrequencyHz[2]:=300;
        Curves[I].Magnitude[2]:=1E9;
        Curves[I].Coherence[2]:=1;
      end;
      Check(Repo.Publish(Curves),'Republish changed spectrum peak');
      NotifyRecorderFrfProviderChanged(Provider);
      Adapter.Update(100);
      Check(SameValue(Adapter.Marker(1).SizePixels,10),
        'Huge peak outside preset must not make current circle disappear');
      SetRecorderFrfDisplayRange(100,150);
      Adapter.Update(100);
      Check(SameValue(Adapter.Marker(0).SizePixels,8),
        'Changing preset invalidates interpolation-bound reference');
    finally
      UnregisterRecorderFrfProvider(Adapter);
    end;
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

procedure CheckLogIntensityMarkers;
const
  lAmplitudes: array[0..4] of Double = (0.1, 1, 10, 100, 0);
  lOtherAmplitudes: array[0..4] of Double = (0.1, 1, 100, 1000, 0);
var
  lScene: T3dScene;
  lNode: T3dNode;
  lRepository: TRecorderFrfRepository;
  lProvider: IRecorderFrfProvider;
  lAdapter: TRecorderFrfIntensityAdapter;
  lCurves: array[0..4] of TRecorderFrfCurveData;
  lBindings: array[0..4] of TRecorderFrfIntensityBinding;
  lIndex, lIteration: Integer;
  lStarted, lLinearMs, lLogMs: QWord;

  procedure PublishScaled(AScale: Double);
  var lPoint: Integer;
  begin
    for lPoint:=0 to High(lAmplitudes) do
    begin
      lCurves[lPoint].Magnitude[0]:=lAmplitudes[lPoint]*AScale;
      lCurves[lPoint].Magnitude[1]:=lOtherAmplitudes[lPoint]*AScale;
    end;
    Check(lRepository.Publish(lCurves),'Publish logarithmic radius fixture');
  end;

  procedure CheckRadius(APoint: Integer; AFrequency, AExpected: Double;
    const AName: string);
  var lMarker: TRecorderIntensityMarker;
  begin
    Check(lAdapter.Update(AFrequency),'Update '+AName);
    lMarker:=lAdapter.Marker(APoint);
    Check(not IsNan(lMarker.SizePixels) and not IsInfinite(lMarker.SizePixels),
      AName+' radius must be finite');
    Check(SameValue(lMarker.SizePixels,AExpected,1E-9),AName+
      ': expected '+FloatToStr(AExpected)+', actual '+FloatToStr(lMarker.SizePixels));
    Check(lMarker.Color=clRed,'Log radius does not alter configured color');
  end;

begin
  lScene:=T3dScene.Create;
  lAdapter:=TRecorderFrfIntensityAdapter.Create;
  lRepository:=TRecorderFrfRepository.Create;
  lProvider:=lRepository;
  try
    lNode:=T3dNode.Create;
    lNode.Id:=9701;
    lScene.AddNode(lNode);
    for lIndex:=0 to High(lCurves) do
    begin
      lCurves[lIndex]:=Default(TRecorderFrfCurveData);
      lCurves[lIndex].Id:=9702+lIndex;
      lCurves[lIndex].FrequencyHz:=[100.0,200.0];
      lCurves[lIndex].Magnitude:=[0.0,0.0];
      lCurves[lIndex].PhaseRadians:=[0.0,0.0];
      lCurves[lIndex].Coherence:=[1.0,1.0];
      lBindings[lIndex]:=Default(TRecorderFrfIntensityBinding);
      lBindings[lIndex].CurveId:=lCurves[lIndex].Id;
      lBindings[lIndex].TargetNodeId:=lNode.Id;
      lBindings[lIndex].Enabled:=True;
      lBindings[lIndex].Gain:=1;
      lBindings[lIndex].MarkerSizePixels:=10;
      lBindings[lIndex].Color:=clRed;
    end;
    PublishScaled(1);
    SetRecorderFrfDisplayRange(100,200);
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(2,100,0.2,'Legacy linear retains preset peak 1000');
    CheckRadius(0,100,0.002,'Legacy linear small amplitude');
    for lIndex:=0 to High(lBindings) do lBindings[lIndex].IntensityLogScale:=True;
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(0,100,0,'Current-frequency minimum .1');
    CheckRadius(1,100,20/3,'Current-frequency 1 is one-third');
    CheckRadius(2,100,40/3,'Current-frequency 10 is two-thirds');
    CheckRadius(3,100,20,'Current-frequency maximum 100');
    CheckRadius(4,100,0,'Zero is excluded from positive logarithmic minimum');
    CheckRadius(2,200,15,'Frequency movement recomputes positive endpoints');
    SetRecorderFrfDisplayRange(199,201);
    CheckRadius(2,100,40/3,'Log radius ignores preset-band peak');
    SetRecorderFrfDisplayRange(100,200);
    lBindings[0].IntensityLogScale:=False;
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(0,100,0.002,'Mixed linear binding keeps preset normalization');
    CheckRadius(2,100,40/3,'Mixed log binding uses current point extrema');
    lBindings[0].IntensityLogScale:=True;
    lBindings[3].Enabled:=False;
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(1,100,10,'Disabled maximum is excluded');
    CheckRadius(3,100,0,'Disabled binding has zero radius');
    lBindings[3].Enabled:=True;
    lBindings[3].Gain:=Infinity;
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(1,100,10,'Nonfinite maximum is excluded');
    CheckRadius(3,100,0,'Nonfinite amplitude is not rendered');
    lBindings[3].Gain:=NaN;
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(1,100,10,'NaN amplitude does not define log maximum');
    CheckRadius(3,100,0,'NaN amplitude is not rendered');
    lBindings[3].Gain:=1;
    lBindings[3].TargetNodeId:=999999;
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(1,100,10,'Unresolved geometry does not define log maximum');
    Check(not lAdapter.Marker(3).Visible,'Unresolved geometry is not rendered');
    lBindings[3].TargetNodeId:=lNode.Id;
    lBindings[0].CurveId:=999999;
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(1,100,0,'Missing minimum is excluded');
    CheckRadius(2,100,10,'Missing minimum changes logarithmic span');
    lBindings[0].CurveId:=lCurves[0].Id;
    for lIndex:=0 to High(lBindings) do lBindings[lIndex].Gain:=-3;
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(2,100,40/3,'Negative gain preserves magnitude scaling');
    PublishScaled(1E-100);
    CheckRadius(2,100,40/3,'Tiny physical units preserve logarithmic radius');
    CheckRadius(3,100,20,'Tiny reference maximum');
    PublishScaled(1);
    for lIndex:=0 to High(lBindings) do lBindings[lIndex].Gain:=1;
    lAdapter.Configure(lProvider,lScene,[lBindings[2]]);
    CheckRadius(0,100,20,'One measured positive point has full radius');
    for lIndex:=0 to High(lCurves) do lCurves[lIndex].Magnitude[0]:=2;
    Check(lRepository.Publish(lCurves),'Publish equal positive values');
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(0,100,20,'Equal positive set has full radius');
    CheckRadius(3,100,20,'Equal positive maximum does not divide by zero');
    for lIndex:=0 to High(lCurves) do lCurves[lIndex].Magnitude[0]:=1E300;
    lCurves[3].Magnitude[0]:=1E300*(1+1E-15);
    Check(lRepository.Publish(lCurves),'Publish nearly equal large values');
    Check(lAdapter.Update(100),'Update nearly equal logarithmic endpoints');
    for lIndex:=0 to High(lBindings) do
      Check(not IsNan(lAdapter.Marker(lIndex).SizePixels) and
        not IsInfinite(lAdapter.Marker(lIndex).SizePixels) and
        (lAdapter.Marker(lIndex).SizePixels>=0) and
        (lAdapter.Marker(lIndex).SizePixels<=20),
        'Nearly equal logarithms never divide by zero or exceed radius range');
    for lIndex:=0 to High(lBindings) do lBindings[lIndex].Gain:=0;
    lAdapter.Configure(lProvider,lScene,lBindings);
    CheckRadius(2,100,0,'All-zero measured points');
    PublishScaled(1);
    for lIndex:=0 to High(lBindings) do lBindings[lIndex].Gain:=1;
    lAdapter.Configure(lProvider,lScene,lBindings);
    Check(lAdapter.Update(100,0,True),'Animated logarithmic marker');
    Check(SameValue(lAdapter.Marker(2).SizePixels,0,1E-9),
      'Animation remains multiplicative after logarithmic radius');
    Check(lAdapter.Update(100,Pi/2,True),'Animated logarithmic peak');
    Check(SameValue(lAdapter.Marker(2).SizePixels,40/3,1E-9),
      'Animation peak retains logarithmic radius');
    { Bounded wall-time comparison on the same warmed five-point provider.
      No FFT, chart repaint, setup allocations or unstable timing assertion. }
    for lIndex:=0 to High(lBindings) do lBindings[lIndex].IntensityLogScale:=False;
    lAdapter.Configure(lProvider,lScene,lBindings);
    lAdapter.Update(100);
    lStarted:=GetTickCount64;
    for lIteration:=1 to 1000000 do lAdapter.Update(100);
    lLinearMs:=GetTickCount64-lStarted;
    for lIndex:=0 to High(lBindings) do lBindings[lIndex].IntensityLogScale:=True;
    lAdapter.Configure(lProvider,lScene,lBindings);
    lAdapter.Update(100);
    lStarted:=GetTickCount64;
    for lIteration:=1 to 1000000 do lAdapter.Update(100);
    lLogMs:=GetTickCount64-lStarted;
    WriteLn('PERF radius_updates=1000000 points=5 linear_ms=',lLinearMs,' log_ms=',lLogMs);
  finally
    SetRecorderFrfDisplayRange(5,1000);
    lAdapter.Free;
    lScene.Free;
    lProvider:=nil;
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

procedure CheckLiveGeometryBinding;
var
  Scene: T3dScene;
  SceneModel: TRecorder3dComponent;
  Model: TRecorderImpactHammerComponent;
  Controller: TRecorder3dImpactBindingController;
  Catalog: IRecorderModelPointCatalog;
  Sink: IRecorderModelPointBindingSink;
  Dialog: TRecorderImpactGeometryBindingDialog;
  RouteDialog: TRecorderFrfRouteDialog;
  Route: TRecorderFrfRoute;
  Node: T3dNode;
  Selection: TRecorderModelPointSelection;
  I: Integer;
  CanSelect: Boolean;
  Key: Word;
  NewPointText: string;
  OldStepHeight, OldBindingTop: Integer;
  LabelMode: IRecorderModelVertexLabelMode;
  StepMarkers: array[0..2] of TRecorderModelPointBinding;
  lDialogBitmap: TBitmap;
  lDialogPng: TPortableNetworkGraphic;
begin
  Scene := T3dScene.Create;
  SceneModel := TRecorder3dComponent.Create;
  SceneModel.Id := 'live-bind-scene';
  Model := TRecorderImpactHammerComponent.Create;
  Dialog := nil;
  try
    for I := 0 to 1 do
    begin
      Node := T3dNode.Create;
      Node.Id := 77 + I;
      Node.Name := 'Object ' + IntToStr(I + 1);
      Node.Mesh := T3dMeshData.Create;
      SetLength(Node.Mesh.Positions, 2);
      Node.Mesh.Positions[0] := Vector3d(0,0,0);
      Node.Mesh.Positions[1] := Vector3d(1,0,0);
      Scene.AddNode(Node);
    end;
    Controller := TRecorder3dImpactBindingController.Create(SceneModel, Scene);
    Catalog := Controller;
    Sink := Controller;
    RegisterRecorderModelPointTarget('live-bind-scene', Catalog, Sink);
    Check(Supports(Sink,IRecorderModelVertexLabelMode,LabelMode), 'Current-step marker API');
    StepMarkers[0] := Default(TRecorderModelPointBinding);
    StepMarkers[0].TargetNodeId := 77;
    StepMarkers[0].PointNumber := 1;
    StepMarkers[1] := StepMarkers[0];
    StepMarkers[2] := StepMarkers[0];
    StepMarkers[2].PointNumber := 2;
    SceneModel.ShowVertexLabels := False;
    LabelMode.SetCurrentStepPoints(StepMarkers);
    Check(SceneModel.CurrentStepPointCount=2, 'Green frames deduplicate vertices and do not require labels/data');
    LabelMode.SetCurrentStepPoints([]);
    Check(SceneModel.CurrentStepPointCount=0, 'Empty step clears green frames');
    StepMarkers[0].CurveId:=9703;
    StepMarkers[0].ModifierTargetNodeId:=77;
    StepMarkers[0].Gain:=1;
    StepMarkers[0].Mode:=rgbmIntensity;
    StepMarkers[0].IntensityLogScale:=True;
    Sink.PublishBindings('log-radius-test','live-bind-scene',[StepMarkers[0]]);
    Check((SceneModel.FrfBindingCount=1) and
      SceneModel.FrfBindings[0].IntensityLogScale,
      'Logarithmic radius reaches persistent 3D binding through controller');
    Sink.RemoveBindings('log-radius-test');
    SceneModel.ShowVertexLabels := True;
    Model.Target3dComponentId := 'live-bind-scene';
    Model.Target3dNodeId := 77;
    Model.AddResponse.TagName := 'X';
    Model.AddResponse.TagName := 'Y';
    Dialog := TRecorderImpactGeometryBindingDialog.ShowBinding(nil, Model);
    Check(Dialog.FormStyle = fsStayOnTop, 'Binding editor stays on top');
    Check(Dialog.Visible and not (fsModal in Dialog.FormState), 'Binding editor is nonmodal');
    Check(Dialog.chkResultValues <> nil, 'Value labels belong to FRF display settings');
    Dialog.chkResultValues.Checked := True;
    Dialog.ResultValuesChange(nil);
    Check(Model.ResultValuesVisible, 'Display settings update persistent value-label preference');
    Check((Dialog.chkLogRadius<>nil) and (Dialog.FindComponent('edLogRange')=nil) and
      (Dialog.FindComponent('lblLogRange')=nil),
      'Logarithmic radius has no manual range controls');
    Check(not Dialog.chkLogRadius.Checked,
      'Legacy linear radius is the display default');
    Dialog.chkLogRadius.Checked:=True;
    Dialog.EditorChange(Dialog.chkLogRadius);
    Check(Model.IntensityLogScale,
      'Checkbox enables persistent logarithmic radius');
    Dialog.cbObject.ItemIndex := 1;
    Dialog.EditorChange(Dialog.cbObject);
    Model.Responses[1].PointNumber:=42;
    Model.Responses[1].PointLabel:='route label';
    Model.Responses[1].Target3dNodeId:=78;
    Check((Dialog.FindComponent('grdChannels')=nil) and
      (Dialog.FindComponent('cbPointLabel')=nil),'Display form has no obsolete channel/point mapping controls');
    Selection.SceneComponentId := 'live-bind-scene';
    Selection.NodeId := 77;
    Selection.PointNumber := 2;
    PublishRecorderModelPointSelection(Selection);
    Check(Dialog.cbObject.ItemIndex = 0, 'Scene selection updates object combo');
    Check(Model.Responses[1].PointNumber = 42, 'Scene selection does not edit route-owned points');
    Dialog.edSize.Text := '24';
    Key := VK_RETURN;
    Dialog.FormKeyDown(Dialog.edSize, Key, []);
    Check((Key = 0) and Dialog.Visible and SameValue(Model.MarkerSizePixels,24),
      'Enter applies without closing binding editor');
    Check((Model.Responses[1].PointNumber=42) and
      (Model.Responses[1].PointLabel='route label') and
      (Model.Responses[1].Target3dNodeId=78),'Display changes preserve geometry mappings');
    Application.ProcessMessages;
    Dialog.Update;
    lDialogBitmap:=Dialog.GetFormImage;
    lDialogPng:=TPortableNetworkGraphic.Create;
    try
      lDialogPng.Assign(lDialogBitmap);
      lDialogPng.SaveToFile(IncludeTrailingPathDelimiter(GetTempDir)+
        'frf-log-radius-dialog.png');
    finally
      lDialogPng.Free;
      lDialogBitmap.Free;
    end;
    Dialog.Close;
    Check(not Dialog.Visible, 'Close hides retained binding editor');
    Route := TRecorderFrfRoute.Create;
    RouteDialog := nil;
    try
      RouteDialog := TRecorderFrfRouteDialog.ShowRoute(nil, Model, Route, nil, nil, nil);
      Check(RouteDialog.FormStyle = fsStayOnTop, 'Route editor stays on top');
      Application.ProcessMessages;
      OldStepHeight := RouteDialog.gridRoute.Height;
      OldBindingTop := RouteDialog.pnlBindings.Top + RouteDialog.gridBindings.Top;
      RouteDialog.splitSteps.MoveSplitter(50);
      Check(RouteDialog.gridRoute.Height > OldStepHeight, 'Splitter expands step table');
      Check(RouteDialog.pnlBindings.Top + RouteDialog.gridBindings.Top > OldBindingTop,
        'Binding area follows splitter');
      Check(RouteDialog.gridBindings.Height >= 90, 'Binding table remains usable');
      RouteDialog.AddClick(nil);
      RouteDialog.cbObject.ItemIndex := 1;
      RouteDialog.ObjectChange(nil);
      RouteDialog.cbChannel.ItemIndex := 0;
      Selection.NodeId := 78;
      Selection.PointNumber := 1;
      PublishRecorderModelPointSelection(Selection);
      RouteDialog.AddBindingClick(nil);
      Check(RouteDialog.cbObject.ItemIndex = 1, 'Adding route mapping preserves focused object');
      RouteDialog.cbChannel.ItemIndex := 1;
      Selection.PointNumber := 2;
      PublishRecorderModelPointSelection(Selection);
      RouteDialog.AddBindingClick(nil);
      Check(Length(Route.Entries[Route.CurrentIndex].Bindings) = 2,
        'One route step holds multiple channel-point mappings');
      Selection.NodeId := 77;
      PublishRecorderModelPointSelection(Selection);
      Check((RouteDialog.cbObject.ItemIndex = 0) and (Pos('2',RouteDialog.lblSelectedVertex.Caption)>0),
        'Route editor follows scene object and vertex selection');
      Check(RouteDialog.FindComponent('cbPoint') = nil, 'No top vertex combo in route editor');
      Check(RouteDialog.gridRoute.ColCount = 4, 'No redundant point-count column');
      CanSelect := True;
      RouteDialog.BindingSelect(RouteDialog.gridBindings, 2, 1, CanSelect);
      Check(RouteDialog.gridBindings.Columns[2].PickList.Count = 2, 'Point cell has object vertex choices');
      NewPointText := '2';
      RouteDialog.BindingValidate(RouteDialog.gridBindings, 2, 1, '1', NewPointText);
      Check(Route[Route.CurrentIndex].Bindings[0].PointNumber = 2, 'Typed point updates actual vertex identity');
      NewPointText := 'missing';
      RouteDialog.BindingValidate(RouteDialog.gridBindings, 2, 1, '2', NewPointText);
      Check(NewPointText = '2', 'Unknown point must not corrupt mapping');
      RouteDialog.rgVertexLabels.ItemIndex := 1;
      RouteDialog.VertexLabelsChange(nil);
      Check(Model.OnlySensors, 'Current-step label mode');
      Check(SceneModel.VertexLabelsOnlyBound, 'Scene filters labels to current step');
      Sink.PublishBindings('test-empty-step', 'live-bind-scene', []);
      Check(SceneModel.VertexLabelsOnlyBound, 'Empty step keeps current-step label mode');
      RouteDialog.rgVertexLabels.ItemIndex := 0;
      RouteDialog.VertexLabelsChange(nil);
      Check(not Model.OnlySensors, 'All-vertex label mode');
      Check(not SceneModel.VertexLabelsOnlyBound, 'All mode clears the old FRF-only label filter');
      RouteDialog.CopyStepClick(nil);
      Check((Route.Count = 2) and (Length(Route[1].Bindings) = 2), 'Copy step preserves mappings');
      Check(Route[1].PointLabel = '2', 'Copied step defaults to its new ordinal number');
      Check((Route[0].CurveId <> Route[1].CurveId) and not Route[1].Captured and
        (Route[1].StorageFolder = ''), 'Copied step has independent identity and no captured data');
    finally
      RouteDialog.Free;
      Route.Free;
    end;
  finally
    Dialog.Free;
    UnregisterRecorderModelPointTarget('live-bind-scene');
    Catalog := nil;
    Sink := nil;
    LabelMode := nil;
    Model.Free;
    Scene.Free;
    SceneModel.Free;
  end;
end;

procedure CheckVertexLabelPersistence;
var
  Forms, Loaded: TRecorderFormManager;
  Factory: TRecorderComponentFactory;
  Page: TRecorderFormPage;
  Model, Clone, CopyModel: TRecorder3dComponent;
  lValues: TMemIniFile;
  FileName: string;

  procedure CheckCodecFallback(ADeleteFields: Boolean);
  var lOldForms: TRecorderFormManager; lBinding: TRecorder3dFrfBinding;
  begin
    lValues:=TMemIniFile.Create(FileName);
    try
      if ADeleteFields then
      begin
        lValues.DeleteKey('Page.0.Component.0','Frf0IntensityLogScale');
        lValues.DeleteKey('Page.0.Component.0','Frf0IntensityLogRangeDb');
      end
      else
        lValues.WriteString('Page.0.Component.0','Frf0IntensityLogRangeDb','NaN');
      lValues.UpdateFile;
    finally lValues.Free end;
    lOldForms:=TRecorderFormManager.Create;
    try
      LoadRecorderGuiConfig(FileName,lOldForms,Factory);
      lBinding:=TRecorder3dComponent(lOldForms.Pages[0].Components[0]).FrfBindings[0];
      if ADeleteFields then Check(not lBinding.IntensityLogScale,
        'Legacy project without logarithmic radius keys remains linear')
      else Check(lBinding.IntensityLogScale,
        'Obsolete logarithmic range key is ignored');
    finally lOldForms.Free end;
  end;
begin
  Forms := TRecorderFormManager.Create;
  Loaded := TRecorderFormManager.Create;
  Factory := TRecorderComponentFactory.Create;
  FileName := IncludeTrailingPathDelimiter(GetTempDir) + 'vertex-labels-' +
    IntToStr(GetTickCount64) + '.ini';
  try
    RegisterRecorder3dFactory(Factory);
    Page := Forms.AddPage(TRecorderFormPage.Create('labels', 'labels', 'Labels'));
    Model := TRecorder3dComponent.Create;
    Model.Id := 'labels-scene';
    Model.ShowVertexLabels := False;
    with Model.AddFrfBinding do
    begin
      CurveId:=9704;
      IntensityLogScale:=True;
    end;
    CopyModel:=TRecorder3dComponent.Create;
    try
      CopyModel.Assign(Model);
      Check(CopyModel.FrfBindings[0].IntensityLogScale,
        'Deep copy preserves logarithmic 3D radius configuration');
    finally CopyModel.Free end;
    Page.AddComponent(Model);
    Model.SetPointLabel(42, 7, 9, '1');
    Check(Model.PointLabel(42, 7) = '1', 'Edited vertex receives requested label');
    Check(Model.PointLabel(42, 1) = '', 'Duplicate vertex label is explicitly cleared');
    Model.SetPointLabel(42, 8, 9, '1');
    Check(Model.PointLabel(42, 7) = '', 'Reassigning label clears former owner');
    Check(Model.PointLabel(43, 1) = '1', 'Label uniqueness is local to one object');
    with Model.AddNodeRenderOverride do
    begin
      NodeId := 77;
      VertexLabels.Add('1=');
      VertexLabels.Add('7=Датчик 1');
    end;
    SaveRecorderGuiConfig(FileName, Forms);
    lValues:=TMemIniFile.Create(FileName);
    try
      Check(not lValues.ValueExists('Page.0.Component.0','Frf0IntensityLogRangeDb'),
        'Obsolete logarithmic radius range is not saved');
    finally lValues.Free end;
    LoadRecorderGuiConfig(FileName, Loaded, Factory);
    Clone := TRecorder3dComponent(Loaded.Pages[0].Components[0]);
    Check(Clone.FrfBindings[0].IntensityLogScale,
      '3D project codec preserves logarithmic radius configuration');
    Check(not Clone.ShowVertexLabels, 'Vertex label visibility must survive saving');
    Check(Clone.FindNodeRenderOverride(77) <> nil, 'Label override persisted');
    Check((Clone.PointLabel(42, 7) = '') and (Clone.PointLabel(42, 8) = '1'),
      'Renumbered and explicitly cleared labels must survive saving');
    Check(Clone.FindNodeRenderOverride(77).VertexLabels.IndexOfName('1') >= 0,
      'Explicitly cleared vertex label must survive saving');
    Check(Clone.FindNodeRenderOverride(77).VertexLabels.Values['7'] = 'Датчик 1',
      'Vertex label text must survive saving');
    CheckCodecFallback(False);
    CheckCodecFallback(True);
  finally
    DeleteFile(FileName);
    Loaded.Free;
    Forms.Free;
    Factory.Free;
  end;
end;

procedure CheckMdbModelPath;
var
  Page: TRecorderFormPage;
  Model, OtherModel: TRecorderMeraBaseComponent;
  Repository: TRecorderMdbRepository;
  Root, Id, Id2, Expected, Expected2: string;
  Bus:TRecorderEventBus;
  Registry:TRecorderTagRegistry;
  Impact:TRecorderImpactHammerComponent;
  View:TRecorderImpactHammerView;
  Port:IRecorderFrfRouteService;
  Revision:QWord;
  RouteDialog:TRecorderFrfRouteDialog;
begin
  Root := IncludeTrailingPathDelimiter(GetTempDir) + 'mdb-model-path-' + IntToStr(GetTickCount64);
  Repository := TRecorderMdbRepository.Create(Root);
  try
    Repository.Open;
    Id := Repository.CreateObject('Object on another page', '', '');
    Expected := IncludeTrailingPathDelimiter(Repository.BasePath + Repository.FindNode(Id).RelativePath);
    Id2:=Repository.CreateObject('Second object','','');
    Expected2:=IncludeTrailingPathDelimiter(Repository.BasePath+Repository.FindNode(Id2).RelativePath);
  finally
    Repository.Free;
  end;
  Page := TRecorderFormPage.Create('other-mdb-page', 'mdb', 'MDB');
  try
    Model := TRecorderMeraBaseComponent.Create;
    Page.AddComponent(Model);
    Model.BasePath := Root;
    Model.ObjectId := Id;
    OtherModel := TRecorderMeraBaseComponent.Create;
    Page.AddComponent(OtherModel);
    OtherModel.BasePath := Root;
    OtherModel.ObjectId := Id2;
    OtherModel.ActivateContext;
    Check(RecorderMeraObjectDirectory = Expected2,
      'Last applied MDB component wins over first component on another page');
    Model.ActivateContext;
    Check(RecorderMeraObjectDirectory = Expected,
      'Resolve database component on inactive page without constructing its view');
    Bus:=TRecorderEventBus.Create;
    Registry:=TRecorderTagRegistry.Create(Bus);
    Impact:=TRecorderImpactHammerComponent.Create;
    View:=TRecorderImpactHammerView.Create(nil);
    try
      Registry.CreateTag('hammer',64).PollFrequencyHz:=1000;
      Registry.CreateTag('response',64).PollFrequencyHz:=1000;
      Impact.HammerTagId:=Registry.FindByName('hammer').Id;
      Impact.HammerTagName:='hammer';
      Impact.SampleRateHz:=1000;
      Impact.AddResponse.TagId:=Registry.FindByName('response').Id;
      Impact.Responses[0].TagName:='response';
      View.Configure(Impact,Registry);
      Check(Supports(View.ApplicationService,IRecorderFrfRouteService,Port),'MDB route service');
      Check(SameFileName(Port.Route.Directory,ExcludeTrailingPathDelimiter(Expected+'frf'+PathDelim+'track')),
        'Initial route uses selected database object');
      View.btnRouteClick(nil);
      RouteDialog:=TRecorderFrfRouteDialog(View.FindComponent('RecorderFrfRouteDialog'));
      Check((RouteDialog<>nil) and RouteDialog.chkMdb.Checked,
        'Auto database route opens with MDB enabled');
      Revision:=RecorderMeraContextRevision;
      Model.ObjectId:=Id2;
      Check(RecorderMeraContextRevision<>Revision,'MDB object setter changes context revision');
      Application.ProcessMessages;
      Check(SameFileName(Port.Route.Directory,ExcludeTrailingPathDelimiter(Expected2+'frf'+PathDelim+'track')),
        'FRF widget follows object change on another page');
      Check(not Port.Route.Entries[0].Captured,'New object must not inherit saved state');
      Check(SameFileName(RouteDialog.edFolder.Text,Port.Route.Directory),
        'Open route editor follows database object folder');
      Check(not View.chkResultReview.Checked,'Object change exits old saved result');
      RouteDialog.chkMdb.Checked := False;
      RouteDialog.MdbChange(nil);
      Impact.ExportPath := Root + PathDelim + 'manual-frf';
      Port.Route.SetDirectory(Impact.ExportPath + PathDelim + 'track');
      RouteDialog.RefreshStorage;
      RouteDialog.chkMdb.Checked := True;
      RouteDialog.MdbChange(nil);
      Check((Impact.ExportPath = '') and
        SameFileName(Port.Route.Directory,
          ExcludeTrailingPathDelimiter(Expected2 + 'frf' + PathDelim + 'track')),
        'Enabling MDB overrides stale manual export path immediately');
      Model.ObjectId := Id;
      Model.ActivateContext;
      Application.ProcessMessages;
      Check(SameFileName(RouteDialog.edFolder.Text,
        ExcludeTrailingPathDelimiter(Expected + 'frf' + PathDelim + 'track')),
        'Database notification updates an already open route editor without manual refresh');
    finally
      Port:=nil;
      View.Free;
      Impact.Free;
      Registry.Free;
      Bus.Free;
    end;
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
  Values: TStringList;
  LoadedImpact: TRecorderImpactHammerComponent;
  ErrorText: string;
  TimePage: TChartPage;
  Snapshot: TRecorderImpactHammerSnapshot;
  FrfCursor: TChartCursor;
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
    Check((View.btnCapturePortion<>nil) and not View.btnCapturePortion.Enabled,
      'Manual portion button loads and waits for acquisition');
    Check((View.FindComponent('btnStart')=nil) and
      (View.FindComponent('btnArm')=nil) and (View.FindComponent('btnStop')=nil),
      'Acquisition uses trigger checkbox or manual portion, without old commands');
    Check((View.btnCapturePortion.Left>=View.chkTrigger.Left+View.chkTrigger.Width) and
      (View.btnCapturePortion.Left+View.btnCapturePortion.Width<=View.btnGeometryBindings.Left),
      'Manual portion button fits measurement command row');
    Check(View.clbCurves.ItemCount>0,
      'Configured channels are visible before the first portion');
    View.rgFrequencyResult.ItemIndex:=1;
    View.frequencyResultChange(nil);
    Check((View.clbCurves.ItemCount=1) and
      (View.clbCurves.ItemCaption[0]='response'),
      'FRF table shows configured response before first portion');
    View.rgFrequencyResult.ItemIndex:=0;
    View.frequencyResultChange(nil);
    Check((View.clbCurves.ItemCount=2) and
      (View.clbCurves.ItemCaption[0]='hammer') and
      (View.clbCurves.ItemCaption[1]='response'),
      'Spectrum table shows configured excitation and response before first portion');
    Check(View.lblCaptureStatus.Top>=View.chkResultReview.Top+View.chkResultReview.Height,
      'Capture status has its own nonoverlapping row');
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    View.RefreshControl(nil,0);
    Check(View.btnCapturePortion.Enabled,'Manual portion enabled for running acquisition');
    View.chkTrigger.Checked:=True;
    View.TriggerChange(nil);
    View.ApplicationService.FillSnapshot(Snapshot);
    Check(Snapshot.TriggerEnabled,'Trigger checkbox delegates enable command');
    Check(View.ApplicationService.TryCapturePortion(ErrorText), ErrorText);
    View.RefreshControl(nil,0);
    Check(not View.btnCapturePortion.Enabled,'Future capture API disables busy action');
    Check(not View.chkTrigger.Checked,'Manual portion disables trigger checkbox');
    Check(View.lblCaptureStatus.Caption<>'','Pending manual portion status is visible');
    View.ApplicationService.StopMeasurement;
    View.RefreshControl(nil,0);
    Check(View.btnCapturePortion.Enabled,'Service stop cancels pending portion and enables new request');
    Check(Port.Route.Count = 1, 'Stationary object starts with one route step');
    Values := TStringList.Create;
    LoadedImpact := TRecorderImpactHammerComponent.Create;
    try
      // Selecting a new empty step intentionally leaves channels unmapped.
      Model.Responses[0].PointNumber := 0;
      Model.Responses[0].Target3dNodeId := 0;
      Model.Responses[0].PointLabel := '';
      Model.SaveToStrings(Values, 'Impact.');
      Check(LoadedImpact.LoadFromStrings(Values, 'Impact.', ErrorText),
        'Empty-step FRF configuration must reload at startup: ' + ErrorText);
      Check(LoadedImpact.Responses[0].PointNumber = 0,
        'Unassigned geometry point must not acquire an invented vertex');
      Check(LoadedImpact.Responses[0].PointLabel = '', 'Unassigned point must keep an empty label');
      LoadedImpact.Responses[0].PointNumber := -1;
      Check(not LoadedImpact.Validate(ErrorText), 'Negative vertex numbers must remain invalid');
    finally
      LoadedImpact.Free;
      Values.Free;
    end;
    Check((View.btnSaveSession.Parent = View.seRoutePoint.Parent) and
      (View.btnSaveSession.Left >= View.seRoutePoint.Left + View.seRoutePoint.Width) and
      (Abs(View.btnSaveSession.Top - View.seRoutePoint.Top) < 8),
      'Save action must be beside step spinner');
    Port.Route.Clear;
    Entry := Default(TRecorderFrfRouteEntry);
    Entry.PointNumber := 1;
    Entry.PointLabel := 'A';
    Port.Route.Add(Entry);
    Entry.PointNumber := 2;
    Entry.PointLabel := 'B';
    Port.Route.Add(Entry);
    View.RefreshControl(nil, 0);
    Check(not View.chkScenario.Visible, 'Unified step workflow has no separate scenario mode');
    Check(View.seRoutePoint.Enabled, 'Step spinner enabled for configured steps');
    View.seRoutePoint.Value := 2;
    Check(Port.Route.CurrentIndex = 1, 'Spinner selects second route point');
    Check(Pos('B', View.lblRoutePoint.Caption) > 0, 'Spinner displays point label');
    TimePage := TChartPage(View.GetChartControl.Model.Children[0]);
    Snapshot := Default(TRecorderImpactHammerSnapshot);
    Snapshot.ImpactCount := 1;
    Snapshot.CaptureDurationSeconds := 0.35;
    View.ApplySnapshot(Snapshot);
    TimePage.XMinValue := 0.005;
    TimePage.XMaxValue := 0.017;
    TimePage.ZoomedX := True;
    Snapshot.ImpactCount := 2;
    Snapshot.ImpactIndex := 1;
    View.ApplySnapshot(Snapshot);
    Check(SameValue(TimePage.XMinValue,0.005) and SameValue(TimePage.XMaxValue,0.017) and
      TimePage.ZoomedX, 'Changing impact preserves manual 5..17 ms X viewport');
    TimePage.ZoomedX := False;
    Snapshot.ImpactIndex := 0;
    View.ApplySnapshot(Snapshot);
    Check(SameValue(TimePage.XMinValue,0.005) and SameValue(TimePage.XMaxValue,0.017),
      'Impact navigation must preserve actual X bounds, not depend on the zoom flag');
    Snapshot.ImpactCount := 0;
    View.ApplySnapshot(Snapshot);
    Snapshot.ImpactCount := 5;
    Snapshot.ImpactIndex := 3;
    View.ApplySnapshot(Snapshot);
    Check(SameValue(TimePage.XMinValue,0.005) and SameValue(TimePage.XMaxValue,0.017),
      'Empty presentation and returning to impacts must preserve time X');
    TimePage.XMinValue := TimePage.PresetMinXValue;
    TimePage.XMaxValue := TimePage.PresetMaxXValue;
    TimePage.ZoomedX := False;
    Snapshot.ImpactIndex := 4;
    View.ApplySnapshot(Snapshot);
    Check(SameValue(TimePage.XMinValue,TimePage.PresetMinXValue) and
      SameValue(TimePage.XMaxValue,TimePage.PresetMaxXValue),
      'Explicitly restored full X range must remain full on next impact');
    Check((View.chkResultReview <> nil) and (View.chkResultValues <> nil), 'Result review controls load');
    TimePage.XMinValue := 0.005;
    TimePage.XMaxValue := 0.017;
    TChartAxis(TimePage.Children[0]).MinValue := -7;
    TChartAxis(TimePage.Children[0]).MaxValue := 13;
    with TChartPage(View.GetChartControl.Model.Children[1]) do
    begin
      XMinValue := 50;
      XMaxValue := 170;
      ZoomedX := True;
      TChartAxis(Children[0]).MinValue := 0.002;
      TChartAxis(Children[0]).MaxValue := 0.2;
    end;
    SetRecorderSelectedFrfFrequency(123.5);
    View.seRoutePoint.Value := 1;
    Check(SameValue(RecorderSelectedFrfFrequency,123.5), 'Step change preserves selected FRF frequency');
    Check(SameValue(TimePage.XMinValue,0.005) and SameValue(TimePage.XMaxValue,0.017) and
      SameValue(TChartAxis(TimePage.Children[0]).MinValue,-7) and
      SameValue(TChartAxis(TimePage.Children[0]).MaxValue,13), 'Step change preserves time X/Y');
    with TChartPage(View.GetChartControl.Model.Children[1]) do
      Check(SameValue(XMinValue,50) and SameValue(XMaxValue,170) and
        SameValue(TChartAxis(Children[0]).MinValue,0.002) and
        SameValue(TChartAxis(Children[0]).MaxValue,0.2), 'Step change preserves frequency X/Y');
    FrfCursor:=TChartCursor.Create;
    try
      TChartPage(View.GetChartControl.Model.Children[1]).AddChild(FrfCursor);
      FrfCursor.Visible:=True;
      FrfCursor.CursorType:=cctDouble;
      FrfCursor.X1:=100;
      FrfCursor.X2:=200;
      View.chartCursorChanged(nil,FrfCursor);
      FrfCursor.X1:=120;
      View.chartCursorChanged(nil,FrfCursor);
      Check(SameValue(RecorderSelectedFrfFrequency,120),'Dragging first frequency cursor updates intensity');
      FrfCursor.X2:=220;
      View.chartCursorChanged(nil,FrfCursor);
      Check(SameValue(RecorderSelectedFrfFrequency,220),'Dragging second frequency cursor updates intensity');
    finally
      FrfCursor.Free;
    end;
  finally
    Port := nil;
    View.Free;
    Model.Free;
    Registry.Free;
    Bus.Free;
  end;
end;

procedure CheckEmptyStepLegend;
var
  Scene: T3dScene;
  SceneModel: TRecorder3dComponent;
  Controller: TRecorder3dImpactBindingController;
  Catalog: IRecorderModelPointCatalog;
  Sink: IRecorderModelPointBindingSink;
  Node: T3dNode;
  Selection: TRecorderModelPointSelection;
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  View: TRecorderImpactHammerView;
  Port: IRecorderFrfRouteService;
  Entry: TRecorderFrfRouteEntry;
  I: Integer;
  OriginalService: IRecorderImpactHammerApplicationService;
  CaptureSnapshot: TRecorderImpactHammerSnapshot;

  procedure PublishManualWave(ABaseTime: Double);
  var
    J: Integer;
    T: Double;
  begin
    for J := 0 to 16 do
    begin
      T := ABaseTime + J / 8;
      Registry.PublishValue('response', T, 2 * (1 + Sin(T)));
      Registry.PublishValue('hammer', T, 1 + Sin(T));
    end;
  end;
begin
  Scene := T3dScene.Create;
  SceneModel := TRecorder3dComponent.Create;
  SceneModel.Id := 'review-selection-scene';
  Node := T3dNode.Create;
  Node.Id := 77;
  Node.Mesh := T3dMeshData.Create;
  SetLength(Node.Mesh.Positions, 2);
  Scene.AddNode(Node);
  Controller := TRecorder3dImpactBindingController.Create(SceneModel, Scene);
  Catalog := Controller;
  Sink := Controller;
  RegisterRecorderModelPointTarget(SceneModel.Id, Catalog, Sink);
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  View := TRecorderImpactHammerView.Create(nil);
  try
    Registry.CreateTag('hammer', 64).PollFrequencyHz := 8;
    Registry.CreateTag('response', 64).PollFrequencyHz := 8;
    Model.HammerTagId := Registry.FindByName('hammer').Id;
    Model.HammerTagName := 'hammer';
    Model.SampleRateHz := 8;
    Model.TriggerThreshold := 5;
    Model.WindowKind := iwRectangular;
    Model.PretriggerSamples := 1;
    Model.CaptureSamples := 8;
    Model.FftSize := 8;
    Model.WelchSegmentSize := 8;
    Model.WelchOverlapPercent := 0;
    Model.AddResponse.TagId := Registry.FindByName('response').Id;
    Model.Responses[0].TagName := 'response';
    Model.Target3dComponentId := SceneModel.Id;
    Model.Target3dNodeId := 77;
    Model.Responses[0].Target3dNodeId := 77;
    Model.Responses[0].PointNumber := 1;
    Model.Responses[0].PointLabel := 'A';
    Model.ExportPath := IncludeTrailingPathDelimiter(GetTempDir) +
      'empty-step-legend-' + IntToStr(GetTickCount64);
    View.Configure(Model, Registry);
    Check(Supports(View.ApplicationService, IRecorderFrfRouteService, Port),
      'Empty-step test has route service');
    OriginalService := View.ApplicationService;
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    View.RefreshControl(nil, 0);
    Check(View.btnCapturePortion.Enabled, 'First manual portion is available');
    PublishManualWave(10);
    View.btnCapturePortion.Click;
    for I := 0 to 100 do
    begin
      View.RefreshControl(nil, 0);
      if (View.ResultSampleCount(irtTime, 0) > 0) and
        View.btnCapturePortion.Enabled then Break;
      CheckSynchronize(10);
      Sleep(5);
    end;
    View.ApplicationService.FillSnapshot(CaptureSnapshot);
    Check(View.ResultSampleCount(irtTime, 0) > 0,
      'Old step has captured time samples: ' + CaptureSnapshot.StatusText +
      ' impacts=' + IntToStr(CaptureSnapshot.ImpactCount));
    Model.RouteAutoEnabled := not Model.RouteAutoEnabled;
    Model.RouteTagSyncEnabled := not Model.RouteTagSyncEnabled;
    View.Configure(Model, Registry);
    Check(View.ApplicationService = OriginalService,
      'Runtime automation flags must not recreate the acquisition service');
    Check(View.ResultSampleCount(irtTime, 0) > 0,
      'Runtime automation flags retain unsaved raw samples');
    Model.RouteAutoEnabled := False;
    Model.RouteTagSyncEnabled := False;
    View.btnSaveSession.Click;
    Check(Port.RoutePointHasData, 'UI save stores current manual portion');
    View.Configure(Model, Registry);
    Check(View.ApplicationService = OriginalService, 'Saving must not recreate the acquisition service');
    Entry := Default(TRecorderFrfRouteEntry);
    Entry.PointLabel := 'Empty';
    SetLength(Entry.Bindings, 1);
    Entry.Bindings[0].ChannelIndex := 0;
    Entry.Bindings[0].TargetNodeId := 77;
    Entry.Bindings[0].SceneComponentId := SceneModel.Id;
    Entry.Bindings[0].PointNumber := 2;
    Entry.Bindings[0].PointLabel := 'B';
    Port.Route.Add(Entry);
    View.RefreshControl(nil, 0);
    View.seRoutePoint.Value := Port.Route.Count;
    View.RefreshControl(nil, 0);
    View.Configure(Model, Registry);
    Check(View.ApplicationService = OriginalService, 'Step navigation must not recreate the acquisition service');
    Check(View.btnCapturePortion.Enabled, 'Next empty step still permits manual capture');
    Check((View.chkRouteTagSync.Left = View.chkRouteAuto.Left) and
      (View.chkRouteAuto.Top > View.chkRouteTagSync.Top),
      'Automatic mode is directly below route-tag synchronization');
    Check(not View.chkResultValues.Visible,
      'Value-label preference is absent from main widget');
    View.chkResultReview.Checked := True;
    View.ResultReviewChange(nil);
    Selection.SceneComponentId := SceneModel.Id;
    Selection.NodeId := 77;
    Selection.PointNumber := 1;
    PublishRecorderModelPointSelection(Selection);
    Check(View.seRoutePoint.Value = 1, 'Review scene point selects its saved route step');
    Check(Pos('Точка: A', View.lblRoutePoint.Caption) > 0,
      'Review shows selected geometry point label');
    Check(View.ResultSampleCount(irtTime, 0) > 0,
      'Review scene selection loads saved time realization');
    Selection.PointNumber := 2;
    PublishRecorderModelPointSelection(Selection);
    Check((View.seRoutePoint.Value = 2) and
      (Pos('Точка: B', View.lblRoutePoint.Caption) > 0),
      'Review scene point selects empty step and displays its point label');
    View.chkResultReview.Checked := False;
    View.ResultReviewChange(nil);
    Check((View.ResultSampleCount(irtTime, 0) = 0) and
      (View.ResultSampleCount(irtFrfMagnitude, 0) = 0),
      'Empty selected step must not display old step samples');
    View.rgFrequencyResult.ItemIndex := 1;
    View.frequencyResultChange(nil);
    Check((View.clbCurves.ItemCount = 1) and
      (View.clbCurves.ItemCaption[0] = 'response'),
      'Empty selected step retains configured channel legend');
    View.seRoutePoint.Value := 1;
    View.RefreshControl(nil, 0);
    Check(View.ResultSampleCount(irtTime, 0) > 0,
      'Returning to saved old step restores its time samples');
    View.seRoutePoint.Value := Port.Route.Count;
    PublishManualWave(20);
    View.btnCapturePortion.Click;
    for I := 0 to 100 do
    begin
      View.RefreshControl(nil, 0);
      if View.btnCapturePortion.Enabled then Break;
      CheckSynchronize(10);
      Sleep(5);
    end;
    Check(View.btnCapturePortion.Enabled and
      (View.ResultSampleCount(irtTime, 0) > 0),
      'Second step completes manual capture without restarting acquisition');
  finally
    OriginalService := nil;
    Port := nil;
    View.Free;
    Model.Free;
    Registry.Free;
    Bus.Free;
    UnregisterRecorderModelPointTarget(SceneModel.Id);
    Catalog := nil;
    Sink := nil;
    SceneModel.Free;
    Scene.Free;
  end;
end;

procedure CheckRouteTagSync;
var
  Bus: TRecorderEventBus;
  Registry: TRecorderTagRegistry;
  Model: TRecorderImpactHammerComponent;
  View: TRecorderImpactHammerView;
  Port: IRecorderFrfRouteService;
  OriginalService: IRecorderImpactHammerApplicationService;
  Entry: TRecorderFrfRouteEntry;
  Dlg: TRecorderFrfRouteDialog;
  Image: TBitmap;
  AtPoint, NextStep: TRecorderTag;
  I: Integer;
  ComboKey: Word;
  procedure TypeSearch(ACombo: TComboBox; const AText: string);
  begin
    ACombo.ItemIndex := -1;
    ACombo.Text := AText;
    Dlg.AutomationSearchChange(ACombo);
  end;
begin
  Bus := TRecorderEventBus.Create;
  Registry := TRecorderTagRegistry.Create(Bus);
  Model := TRecorderImpactHammerComponent.Create;
  View := TRecorderImpactHammerView.Create(nil);
  try
    Registry.CreateTag('hammer', 64).PollFrequencyHz := 1000;
    Registry.CreateTag('response', 64).PollFrequencyHz := 1000;
    Registry.CreateTag('route-step', 64);
    AtPoint := Registry.CreateTag('station-ready', 64);
    AtPoint.Address := 'Input.Station.Ready';
    AtPoint.Description := 'Arrival permissive';
    NextStep := Registry.CreateTag('station-next', 64);
    NextStep.Address := 'Output.Next';
    NextStep.Description := 'Advance carriage';
    NextStep.ExternalWriteAllowed := True;
    Model.HammerTagId := Registry.FindByName('hammer').Id;
    Model.HammerTagName := 'hammer';
    Model.SampleRateHz := 1000;
    Model.AddResponse.TagId := Registry.FindByName('response').Id;
    Model.Responses[0].TagName := 'response';
    Model.RoutePointTagId := Registry.FindByName('route-step').Id;
    Model.RoutePointTagName := 'route-step';
    Model.RouteAtPointTagId := AtPoint.Id;
    Model.RouteAtPointTagName := AtPoint.Name;
    Model.RouteNextStepTagId := NextStep.Id;
    Model.RouteNextStepTagName := NextStep.Name;
    Model.ExportPath := IncludeTrailingPathDelimiter(GetTempDir) +
      'route-tag-sync-' + IntToStr(GetTickCount64);
    View.Configure(Model, Registry);
    Check(Supports(View.ApplicationService, IRecorderFrfRouteService, Port),
      'Tag sync exposes route service');
    OriginalService := View.ApplicationService;
    Port.Route.Clear;
    for I := 1 to 3 do
    begin
      Entry := Default(TRecorderFrfRouteEntry);
      Entry.PointLabel := IntToStr(I);
      SetLength(Entry.Bindings, 1);
      Entry.Bindings[0].ChannelIndex := 0;
      Entry.Bindings[0].PointNumber := I;
      Entry.Bindings[0].PointLabel := IntToStr(I);
      Port.Route.Add(Entry);
    end;
    View.RefreshControl(nil, 0);
    Dlg := TRecorderFrfRouteDialog.ShowRoute(nil, Model, Port.Route, nil, nil, nil, Registry);
    try
      Check(Dlg.cbAtPointTag.Items.Objects[Dlg.cbAtPointTag.ItemIndex] = AtPoint,
        'At-point combo restores stable identity');
      Check((Dlg.FindComponent('edAtPointSearch') = nil) and
        (Dlg.FindComponent('edNextStepSearch') = nil) and
        (Dlg.FindComponent('edPointTagSearch') = nil), 'Tag search uses combo edit only');
      Check(Dlg.cbAtPointTag.Style = csDropDown, 'At-point combo is editable');
      TypeSearch(Dlg.cbAtPointTag, 'RiVaL');
      Check((Dlg.cbAtPointTag.Items.Count = 2) and
        (Dlg.cbAtPointTag.Items.Objects[1] = AtPoint) and
        (Dlg.cbAtPointTag.Text = 'RiVaL') and (Model.RouteAtPointTagId = AtPoint.Id),
        'Inline search finds middle description without changing text or bound identity');
      TypeSearch(Dlg.cbAtPointTag, 'pUt.StAt');
      Check(Dlg.cbAtPointTag.Items.Count = 2, 'At-point search matches address substring');
      TypeSearch(Dlg.cbAtPointTag, 'tion-rea');
      Check(Dlg.cbAtPointTag.Items.Count = 2, 'At-point search matches name substring');
      TypeSearch(Dlg.cbAtPointTag, 'no-such-tag');
      ComboKey := VK_RETURN;
      Dlg.AutomationTagKeyDown(Dlg.cbAtPointTag, ComboKey, []);
      Check((Dlg.cbAtPointTag.Items.Count = 1) and
        (Model.RouteAtPointTagId = AtPoint.Id), 'Unmatched Enter never clears configured tag');
      TypeSearch(Dlg.cbAtPointTag, 'response');
      Check(Model.RouteAtPointTagId = AtPoint.Id, 'Typing exact tag never commits implicitly');
      ComboKey := VK_RETURN;
      Dlg.AutomationTagKeyDown(Dlg.cbAtPointTag, ComboKey, []);
      Check((Model.RouteAtPointTagId = Registry.FindByName('response').Id) and
        (Model.RouteAtPointTagName = 'response'), 'Enter commits stable tag ID and name');
      TypeSearch(Dlg.cbAtPointTag, 'RiVaL');
      Dlg.cbAtPointTag.ItemIndex := 1;
      Dlg.AutomationTagSelect(Dlg.cbAtPointTag);
      Check(Model.RouteAtPointTagId = AtPoint.Id, 'Explicit suggestion selection commits tag');
      TypeSearch(Dlg.cbAtPointTag, '');
      Check(Dlg.cbAtPointTag.Items.Count = Registry.TagCount + 1, 'Clear search restores allowed tags');
      Check((Dlg.cbNextStepTag.Items.Count = 2) and
        (Dlg.cbNextStepTag.Items.Objects[1] = NextStep),
        'Command combo excludes read-only tags');
      TypeSearch(Dlg.cbNextStepTag, 'CaRr');
      Check(Dlg.cbNextStepTag.Items.Count = 2, 'Command search matches description case-insensitively');
      TypeSearch(Dlg.cbPointTag, 'TE-ST');
      Check((Dlg.cbPointTag.Items.Count = 2) and
        (TRecorderTag(Dlg.cbPointTag.Items.Objects[1]).Id = Model.RoutePointTagId),
        'Point-tag combo filters without changing bound identity');
      Dlg.chkRouteAuto.Checked := True;
      Dlg.chkAutoOverwrite.Checked := True;
      Dlg.AutomationChange(nil);
      Dlg.edNextStepPulse.Text := '350';
      Dlg.PulseEditingDone(nil);
      Check(Model.RouteAutoEnabled and Model.RouteAutoOverwrite and
        (Model.RouteNextStepPulseMs = 350), 'Route automation controls update model');
      TypeSearch(Dlg.cbAtPointTag, '');
      TypeSearch(Dlg.cbNextStepTag, '');
      TypeSearch(Dlg.cbPointTag, '');
      ComboKey := VK_ESCAPE;
      Dlg.AutomationTagKeyDown(Dlg.cbAtPointTag, ComboKey, []);
      Check((Dlg.cbAtPointTag.Text = AtPoint.Name) and
        (Dlg.cbAtPointTag.Items.Count = Registry.TagCount + 1),
        'Escape restores committed tag and full suggestion list');
      Application.ProcessMessages;
      Image := Dlg.GetFormImage;
      try Image.SaveToFile(IncludeTrailingPathDelimiter(GetTempDir) + 'recorder-route-auto-ui.bmp');
      finally Image.Free end;
      Model.RouteAutoEnabled := False;
    finally Dlg.Free end;
    Dlg := TRecorderFrfRouteDialog.ShowRoute(nil, Model, Port.Route, nil, nil, nil, Registry);
    try
      Check((Dlg.cbAtPointTag.Text = AtPoint.Name) and
        (Dlg.cbAtPointTag.Items.Objects[Dlg.cbAtPointTag.ItemIndex] = AtPoint),
        'Reopening restores committed tag rather than search fragment');
    finally Dlg.Free end;
    Check(not View.chkRouteTagSync.Enabled, 'Tag sync is unavailable outside Play');
    Check((View.chkRouteTagSync.Left >= View.btnSaveSession.Left + View.btnSaveSession.Width) and
      (View.lblRoutePoint.Left >= View.chkRouteTagSync.Left + View.chkRouteTagSync.Width),
      'Tag sync fits beside step/save controls without label overlap');
    Registry.PublishValue('route-step', 0, 1);
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStarted));
    View.RefreshControl(nil, 0);
    Check(View.chkRouteTagSync.Enabled, 'Play enables configured tag synchronization');
    View.chkRouteAuto.Checked := True;
    View.RouteAutoChange(nil);
    Check(View.chkRouteAuto.Checked, 'Play permits automatic route mode');
    View.chkRouteTagSync.Checked := True;
    View.RouteTagSyncChange(nil);
    Registry.PublishValue('route-step', 0.5, 3);
    for I := 0 to 100 do
    begin
      View.RefreshControl(nil, 0);
      if View.seRoutePoint.Value = 3 then Break;
      CheckSynchronize(5);
      Sleep(5);
    end;
    Check(View.seRoutePoint.Value = 3, 'Worker-selected automatic step is presented');
    View.Configure(Model, Registry);
    Check(View.ApplicationService = OriginalService,
      'Automatic step binding presentation does not recreate acquisition service');
    View.seRoutePoint.Value := 2;
    Check(not View.chkRouteAuto.Checked, 'Manual neighboring point cancels automatic route mode');
    View.chkRouteAuto.Checked := True;
    View.RouteAutoChange(nil);
    Check(View.chkRouteAuto.Checked, 'Automatic route mode can be enabled again');
    Registry.PublishValue('hammer', 0, 0);
    Registry.PublishValue('response', 0, 0);
    Registry.PublishValue('hammer', 0.001, 1);
    Registry.PublishValue('response', 0.001, 1);
    View.btnCapturePortionClick(nil);
    Check(not View.chkRouteAuto.Checked, 'Manual capture cancels automatic route mode');
    View.seRoutePoint.Value := 1;
    View.chkRouteTagSync.Checked := True;
    View.RouteTagSyncChange(nil);
    Check(View.chkRouteTagSync.Checked, 'User can enable tag synchronization');
    Registry.PublishValue('route-step', 1, 3);
    View.RefreshControl(nil, 0);
    Check((View.seRoutePoint.Value = 3) and (Port.Route.CurrentIndex = 2),
      'Tag update selects route step and updates spinner');
    Check(View.chkRouteTagSync.Checked, 'Programmatic spinner update preserves synchronization');
    View.Configure(Model, Registry);
    Check(View.ApplicationService = OriginalService,
      'Automatic geometry mapping update does not recreate acquisition service');
    View.seRoutePoint.Value := 2;
    Check(not View.chkRouteTagSync.Checked, 'Manual neighboring step disables tag synchronization');
    Registry.PublishValue('route-step', 2, 1);
    View.RefreshControl(nil, 0);
    Check(View.seRoutePoint.Value = 2, 'Tag no longer overrides manual step selection');
    View.chkRouteTagSync.Checked := True;
    View.RouteTagSyncChange(nil);
    Check(View.seRoutePoint.Value = 1, 'Re-enabled synchronization follows latest tag value');
    Bus.Publish(TRecorderEventBus.MakeEvent(rceStopped));
    View.RefreshControl(nil, 0);
    Check(not View.chkRouteTagSync.Enabled and not View.chkRouteTagSync.Checked,
      'Stopping Play clears and disables tag synchronization');
    Registry.PublishValue('route-step', 3, 3);
    View.RefreshControl(nil, 0);
    Check(View.seRoutePoint.Value = 1, 'Stopped source cannot change selected route step');
  finally
    OriginalService := nil;
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
  SavedRouteSnapshot:TRecorderImpactSessionSnapshot;
  SearchRoute: TRecorderFrfRoute;
begin
  DeleteFile(IncludeTrailingPathDelimiter(GetTempDir) +
    'ImpactHammerUiSmoke.stage.log');
  Stage('initialize');
  Application.Initialize;
  if NativeGraphMode or ((ParamCount > 0) and ((ParamStr(1) = '--graph-windows-only') or
     (ParamStr(1) = '--rect-window-only') or
     (ParamStr(1) = '--graph-capture-only') or
     (ParamStr(1) = '--graph-native-interactive'))) then
  begin
    try
      CheckGraphWindows;
      if not NativeGraphMode then WriteLn('RESULT graph windows passed');
      Halt(0);
    except on E: Exception do
      begin WriteLn('FAIL graph windows: ' + E.Message); DumpExceptionBackTrace(Output); Halt(1) end;
    end;
  end;
  if (ParamCount > 0) and (ParamStr(1) = '--intensity-markers-only') then
  begin
    try CheckIntensityMarkers; CheckLogIntensityMarkers;
      WriteLn('RESULT intensity markers passed');
    except on E:Exception do begin WriteLn('FAIL intensity markers: '+E.Message); Halt(1) end end;
    Halt(0);
  end;
  if (ParamCount > 0) and (ParamStr(1) = '--numeric-vertex-sort-only') then
  begin
    try CheckNumericVertexSort; WriteLn('RESULT numeric vertex sort passed'); Halt(0);
    except on E: Exception do begin WriteLn('FAIL numeric sort: '+E.Message); DumpExceptionBackTrace(Output); Halt(1) end end;
  end;
  if (ParamCount > 0) and (ParamStr(1) = '--live-geometry-binding-only') then
  begin
    try
      CheckLiveGeometryBinding;
      WriteLn('RESULT live geometry binding passed');
      Halt(0);
    except
      on E: Exception do begin WriteLn('FAIL live binding: '+E.Message); DumpExceptionBackTrace(Output); Halt(1); end;
    end;
  end;
  if (ParamCount > 0) and (ParamStr(1) = '--vertex-label-persistence-only') then
  begin
    try
      CheckVertexLabelPersistence;
    except
      on E: Exception do begin WriteLn('FAIL vertex labels: ' + E.Message); DumpExceptionBackTrace(Output); Halt(1); end;
    end;
    WriteLn('RESULT vertex label persistence passed');
    Halt(0);
  end;
  if (ParamCount > 0) and (ParamStr(1) = '--route-spinner-only') then
  begin
    try CheckRouteSpinner; CheckEmptyStepLegend; CheckRouteTagSync;
    except on E: Exception do begin WriteLn('FAIL route spinner: '+E.Message); Halt(1) end end;
    WriteLn('RESULT route spinner passed');
    Halt(0);
  end;
  if (ParamCount > 0) and (ParamStr(1) = '--route-tag-sync-only') then
  begin
    try CheckRouteTagSync;
    except on E: Exception do begin WriteLn('FAIL route tag sync: ' + E.Message); Halt(1) end end;
    WriteLn('RESULT route tag sync passed');
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
  CheckLogIntensityMarkers;
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
    Check(RoutePort.Route.AllComplete,'Both route MERA realizations saved');
    for I:=0 to RoutePort.Route.Count-1 do
    begin
      Check(TRecorderFrfPointStore.Load(RoutePort.Route.PointDirectory(I),
        SavedRouteSnapshot, RouteError),'Reload route MERA from disk: '+RouteError);
      Check(Length(SavedRouteSnapshot.Curves)>0,'Saved route MERA contains FRF');
      Check(not FileExists(IncludeTrailingPathDelimiter(
        RoutePort.Route.PointDirectory(I))+'curve.frf'),
        'Duplicate legacy curve must not be written');
    end;
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
