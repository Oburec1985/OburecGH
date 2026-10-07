
Unit uRecorderImpactHammerView;

{$mode objfpc}{$H+}
{$codepage UTF8}

Interface

Uses 
Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, ComCtrls,
CheckLst,
Math, uOglChart, uOglChartColors, uOglChartChart, uOglChartPage,
uOglChartAxis, uOglChartTrend, uOglChartRenderer, uOglChartTypes,
uOglChartDrawObj,
uRecorderFormModel, uRecorderTags,
uRecorderVisualControl,
uRecorderFrfContracts,
uRecorderImpactHammerModel, uRecorderImpactHammerContracts,
uRecorderImpactHammerPresenter;

Type 

{ Runtime surface for the impact-hammer workflow. ApplySnapshot is the only
    state input; button handlers only delegate commands to ApplicationService. }
  TRecorderImpactHammerView = Class(TPanel, IVForm)
    btnArm: TButton;
    btnDelete: TButton;
    btnHide: TButton;
    btnNextImpact: TButton;
    btnPreviousImpact: TButton;
    btnStart: TButton;
    btnStop: TButton;
    chkAutoScale: TCheckBox;
    chkLogX: TCheckBox;
    chkLogY: TCheckBox;
    clbCurves: TCheckListBox;
    edtXMax: TEdit;
    edtXMin: TEdit;
    edtYMax: TEdit;
    edtYMin: TEdit;
    lblImpactPosition: TLabel;
    lblCursor: TLabel;
    lblState: TLabel;
    lblStatus: TLabel;
    pageCoherence: TTabSheet;
    pageFrf: TTabSheet;
    pagePhase: TTabSheet;
    pageSpectrum: TTabSheet;
    pageTime: TTabSheet;
    pagesResults: TPageControl;
    pnlCommands: TPanel;
    pnlNavigation: TPanel;
    pnlResultOptions: TPanel;
    pnlState: TPanel;
    progressMeasurement: TProgressBar;
    Procedure btnArmClick(Sender: TObject);
    Procedure btnDeleteClick(Sender: TObject);
    Procedure btnHideClick(Sender: TObject);
    Procedure btnNextImpactClick(Sender: TObject);
    Procedure btnPreviousImpactClick(Sender: TObject);
    Procedure btnStartClick(Sender: TObject);
    Procedure btnStopClick(Sender: TObject);
    Procedure axisOptionsChange(Sender: TObject);
    Procedure axisRangeEditingDone(Sender: TObject);
    Procedure curveVisibilityClickCheck(Sender: TObject);
    Procedure pagesResultsChange(Sender: TObject);
    Procedure chartMouseMove(Sender: TObject; Shift: TShiftState;
                             X, Y: Integer);
    Private 
      fApplicationService: IRecorderImpactHammerApplicationService;
      fSnapshot: TRecorderImpactHammerSnapshot;
      fLastRevision: QWord;
      fComponent: TRecorderImpactHammerComponent;
      fCharts: array[TRecorderImpactResultType] Of TOglChart;
      fChartModels: array[TRecorderImpactResultType] Of TChartModel;
      fChartPages: array[TRecorderImpactResultType] Of TChartPage;
      fChartAxes: array[TRecorderImpactResultType] Of TChartAxis;
      fChartSeries: array[TRecorderImpactResultType] Of array Of cBuffTrend1d;
      fPresenter: TRecorderImpactHammerPresenter;
      fUpdatingOptions: Boolean;
      Procedure BuildCharts;
      Procedure PresentResult(AType: TRecorderImpactResultType);
      Procedure ShowResultOptions(AType: TRecorderImpactResultType);
      Function StateCaption(AState: TRecorderImpactHammerState): string;
      Procedure UpdateCommandAvailability;
      Procedure UpdateImpactPosition;
      Procedure UpdateStatePresentation;
      Procedure UpdateCursorCaption(Const AFrame: TRecorderImpactPresentationFrame);
    Public 
      constructor Create(AOwner: TComponent);
      override;
      destructor Destroy;
      override;
      Procedure ApplySnapshot(Const ASnapshot: TRecorderImpactHammerSnapshot);
      Procedure Configure(AComponent: TRecorderVisualComponent;
                          ATagRegistry: TRecorderTagRegistry);
      Procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
                               ADisplaySeconds: Double);
      Function GetChartControl: TOglChart;
      Function FrfProvider: IRecorderFrfProvider;
      property ApplicationService: IRecorderImpactHammerApplicationService
                                   read fApplicationService write fApplicationService;
  End;

Implementation

Uses 
uRecorderImpactHammerService;

{$R *.lfm}

constructor TRecorderImpactHammerView.Create(AOwner: TComponent);
Begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  fPresenter := TRecorderImpactHammerPresenter.Create;
  BuildCharts;
End;

destructor TRecorderImpactHammerView.Destroy;
Begin
  fPresenter.Free;
  fApplicationService := Nil;
  fLastRevision := 0;
  inherited Destroy;
End;

Procedure TRecorderImpactHammerView.Configure(
                                              AComponent: TRecorderVisualComponent; ATagRegistry:
                                              TRecorderTagRegistry);

Var 
  Service: TRecorderImpactHammerService;
Begin
  If Not (AComponent is TRecorderImpactHammerComponent) Then
    Exit;
  fComponent := TRecorderImpactHammerComponent(AComponent);
  pagesResults.TabIndex := Ord(fComponent.ActiveResultType);
  fApplicationService := Nil;
  fLastRevision := 0;
  Service := TRecorderImpactHammerService.Create;
  If Service.Configure(TRecorderImpactHammerComponent(AComponent),
     ATagRegistry) Then
    fApplicationService := Service
  Else
    Service.Free;
End;

Procedure TRecorderImpactHammerView.RefreshControl(
                                                   ATagRegistry: TRecorderTagRegistry;
                                                   ADisplaySeconds: Double);
Begin
  If fApplicationService <> Nil Then
    Begin
      If fApplicationService.Revision = fLastRevision Then
        Exit;
      fApplicationService.FillSnapshot(fSnapshot);
      fLastRevision := fApplicationService.Revision;
      ApplySnapshot(fSnapshot);
    End;
End;

Function TRecorderImpactHammerView.GetChartControl: TOglChart;
Begin
  Result := fCharts[TRecorderImpactResultType(pagesResults.TabIndex)];
End;

Function TRecorderImpactHammerView.FrfProvider: IRecorderFrfProvider;
Begin
  Result := Nil;
  If fApplicationService <> Nil Then
    Result := fApplicationService.Provider;
End;

Procedure TRecorderImpactHammerView.ApplySnapshot(
                                                  Const ASnapshot: TRecorderImpactHammerSnapshot);
Begin
  fSnapshot := ASnapshot;
  UpdateStatePresentation;
  UpdateImpactPosition;
  UpdateCommandAvailability;
  PresentResult(TRecorderImpactResultType(pagesResults.TabIndex));
End;

Procedure TRecorderImpactHammerView.BuildCharts;

Var 
  ResultType: TRecorderImpactResultType;
  ParentPage: TTabSheet;
Begin
  For ResultType := Low(TRecorderImpactResultType) To
      High(TRecorderImpactResultType) Do
    Begin
      ParentPage := TTabSheet(pagesResults.Pages[Ord(ResultType)]);
      fCharts[ResultType] := TOglChart.Create(Self);
      fCharts[ResultType].Parent := ParentPage;
      fCharts[ResultType].Align := alClient;
      fCharts[ResultType].AutoResizeViewport := True;
      fCharts[ResultType].OnMouseMove := @chartMouseMove;
      fChartModels[ResultType] := TChartModel.Create;
      fChartModels[ResultType].BackgroundColor := $FFFFFFFF;
      fCharts[ResultType].Model := fChartModels[ResultType];
      fChartPages[ResultType] := TChartPage.Create;
      fChartPages[ResultType].Align := cpaAuto;
      fChartModels[ResultType].AddChild(fChartPages[ResultType]);
      fChartAxes[ResultType] := TChartAxis.Create;
      fChartPages[ResultType].AddChild(fChartAxes[ResultType]);
      fChartModels[ResultType].AlignPagesAuto;
    End;
End;

Procedure TRecorderImpactHammerView.PresentResult(
                                                  AType: TRecorderImpactResultType);

Var 
  Frame: TRecorderImpactPresentationFrame;
  AxisState: TImpactResultAxisState;
  Series: cBuffTrend1d;
  I: Integer;
Begin
  If fComponent <> Nil Then
    AxisState := fComponent.AxisStates[AType]
  Else
    Begin
      AxisState := Default(TImpactResultAxisState);
      AxisState.AutoScale := True;
    End;
  fPresenter.Configure(AType, AxisState);
  fPresenter.Build(fSnapshot, Frame);
  ShowResultOptions(AType);
  If Length(fChartSeries[AType]) < Length(Frame.Curves) Then
    Begin
      I := Length(fChartSeries[AType]);
      SetLength(fChartSeries[AType], Length(Frame.Curves));
      While I < Length(fChartSeries[AType]) Do
        Begin
          fChartSeries[AType][I] := cBuffTrend1d.Create;
          fChartAxes[AType].AddChild(fChartSeries[AType][I]);
          Inc(I);
        End;
    End;
  If AxisState.LogX Then
    fChartPages[AType].XScale := casLog10
  Else
    fChartPages[AType].XScale := casLinear;
  If AxisState.LogY Then
    fChartAxes[AType].Scale := casLog10
  Else
    fChartAxes[AType].Scale := casLinear;
  If Not AxisState.AutoScale Then
    Begin
      fChartPages[AType].XMinValue := AxisState.XMin;
      fChartPages[AType].XMaxValue := AxisState.XMax;
      fChartAxes[AType].MinValue := AxisState.YMin;
      fChartAxes[AType].MaxValue := AxisState.YMax;
    End;
  For I := 0 To High(Frame.Curves) Do
    Begin
      Series := fChartSeries[AType][I];
      Series.Visible := True;
      Series.Name := Frame.Curves[I].Name;
      Series.Caption := Frame.Curves[I].Name;
      Series.Color := OglChartColorToGL(TColor(Frame.Curves[I].Color));
      If Length(Frame.Curves[I].X) > 0 Then
        Series.X0 := Frame.Curves[I].X[0];
      If Length(Frame.Curves[I].X) > 1 Then
        Series.DX := Frame.Curves[I].X[1] - Frame.Curves[I].X[0]
      Else
        Series.DX := 1;
      Series.ReplaceValues(Frame.Curves[I].Y, 0,
                           Length(Frame.Curves[I].Y));
    End;
  For I := Length(Frame.Curves) To High(fChartSeries[AType]) Do
    fChartSeries[AType][I].Visible := False;
  UpdateCursorCaption(Frame);
  fCharts[AType].Redraw;
End;

Procedure TRecorderImpactHammerView.chartMouseMove(Sender: TObject;
                                                   Shift: TShiftState; X, Y: Integer);

Var 
  ResultType: TRecorderImpactResultType;
  Renderer: TOpenGLChartRenderer;
  ContentRect: TChartPixelRect;
Begin
  For ResultType := Low(TRecorderImpactResultType) To
      High(TRecorderImpactResultType) Do
    If Sender = fCharts[ResultType] Then
      Begin
        Renderer := TOpenGLChartRenderer(fCharts[ResultType].GetRenderer);
        If Renderer = Nil Then
          Exit;
        ContentRect := Renderer.GetPageContentRect(fChartPages[ResultType]);
        If (X < ContentRect.Left) Or (X > ContentRect.Right) Then
          Exit;
        If ssCtrl In Shift Then
          Begin
            fSnapshot.Cursor.FrequencyHz2 := Renderer.PixelToXValue(
                                             fChartPages[ResultType], Nil, X, ContentRect.Left,
                                             ContentRect.Right);
            fSnapshot.Cursor.HasSecond := True;
          End
        Else
          fSnapshot.Cursor.FrequencyHz := Renderer.PixelToXValue(
                                          fChartPages[ResultType], Nil, X, ContentRect.Left,
                                          ContentRect.Right);
        PresentResult(ResultType);
        Exit;
      End;
End;

Procedure TRecorderImpactHammerView.UpdateCursorCaption(
                                                        Const AFrame:
                                                        TRecorderImpactPresentationFrame);

Var 
  I: Integer;
Begin
  lblCursor.Caption := Format('X1 %.4g', [AFrame.Cursor.FrequencyHz]);
  If AFrame.Cursor.HasSecond Then
    lblCursor.Caption := lblCursor.Caption + Format('  X2 %.4g  Δ %.4g',
                         [AFrame.Cursor.FrequencyHz2,
                         AFrame.Cursor.FrequencyHz2 - AFrame.Cursor.FrequencyHz]);
  For I := 0 To High(AFrame.Curves) Do
    Begin
      lblCursor.Caption := lblCursor.Caption + Format('  %s=%.4g',
                           [AFrame.Curves[I].Name, AFrame.Cursor.Values[I]]);
      If AFrame.Cursor.HasSecond Then
        lblCursor.Caption := lblCursor.Caption + Format('/%.4g',
                             [AFrame.Cursor.Values2[I]]);
    End;
End;

Procedure TRecorderImpactHammerView.ShowResultOptions(
                                                      AType: TRecorderImpactResultType);

Var 
  AxisState: TImpactResultAxisState;
  I: Integer;
Begin
  If fComponent = Nil Then
    Exit;
  fUpdatingOptions := True;
  Try
    AxisState := fComponent.AxisStates[AType];
    chkLogX.Checked := AxisState.LogX;
    chkLogY.Checked := AxisState.LogY;
    chkAutoScale.Checked := AxisState.AutoScale;
    edtXMin.Text := FloatToStr(AxisState.XMin);
    edtXMax.Text := FloatToStr(AxisState.XMax);
    edtYMin.Text := FloatToStr(AxisState.YMin);
    edtYMax.Text := FloatToStr(AxisState.YMax);
    edtXMin.Enabled := Not AxisState.AutoScale;
    edtXMax.Enabled := Not AxisState.AutoScale;
    edtYMin.Enabled := Not AxisState.AutoScale;
    edtYMax.Enabled := Not AxisState.AutoScale;
    clbCurves.Items.BeginUpdate;
    Try
      clbCurves.Clear;
      For I := 0 To High(fSnapshot.Results[AType].Curves) Do
        Begin
          clbCurves.Items.Add(fSnapshot.Results[AType].Curves[I].Name);
          clbCurves.Checked[I] := fSnapshot.Results[AType].Curves[I].Visible;
        End;
    Finally
      clbCurves.Items.EndUpdate;
End;
Finally
  fUpdatingOptions := False;
End;
End;

Procedure TRecorderImpactHammerView.axisOptionsChange(Sender: TObject);

Var 
  ResultType: TRecorderImpactResultType;
  AxisState: TImpactResultAxisState;
Begin
  If fUpdatingOptions Or (fComponent = Nil) Then
    Exit;
  ResultType := TRecorderImpactResultType(pagesResults.TabIndex);
  AxisState := fComponent.AxisStates[ResultType];
  AxisState.LogX := chkLogX.Checked;
  AxisState.LogY := chkLogY.Checked;
  AxisState.AutoScale := chkAutoScale.Checked;
  fComponent.AxisStates[ResultType] := AxisState;
  PresentResult(ResultType);
End;

Procedure TRecorderImpactHammerView.axisRangeEditingDone(Sender: TObject);

Var 
  ResultType: TRecorderImpactResultType;
  AxisState: TImpactResultAxisState;
  XMinValue, XMaxValue, YMinValue, YMaxValue: Double;
Begin
  If fUpdatingOptions Or (fComponent = Nil) Or
     Not TryStrToFloat(edtXMin.Text, XMinValue) Or
     Not TryStrToFloat(edtXMax.Text, XMaxValue) Or
     Not TryStrToFloat(edtYMin.Text, YMinValue) Or
     Not TryStrToFloat(edtYMax.Text, YMaxValue) Or
     (XMaxValue <= XMinValue) Or (YMaxValue <= YMinValue) Then
    Exit;
  ResultType := TRecorderImpactResultType(pagesResults.TabIndex);
  AxisState := fComponent.AxisStates[ResultType];
  AxisState.XMin := XMinValue;
  AxisState.XMax := XMaxValue;
  AxisState.YMin := YMinValue;
  AxisState.YMax := YMaxValue;
  fComponent.AxisStates[ResultType] := AxisState;
  PresentResult(ResultType);
End;

Procedure TRecorderImpactHammerView.curveVisibilityClickCheck(Sender: TObject);

Var 
  ResultType: TRecorderImpactResultType;
  CurveId: QWord;
  I: Integer;
Begin
  If fUpdatingOptions Then
    Exit;
  ResultType := TRecorderImpactResultType(pagesResults.TabIndex);
  If (clbCurves.ItemIndex < 0) Or
     (clbCurves.ItemIndex > High(fSnapshot.Results[ResultType].Curves)) Then
    Exit;
  fSnapshot.Results[ResultType].Curves[clbCurves.ItemIndex].Visible := 
                                                                       clbCurves.Checked[clbCurves.
                                                                       ItemIndex];
  CurveId := fSnapshot.Results[ResultType].Curves[
             clbCurves.ItemIndex].CurveId;
  If fComponent <> Nil Then
    Begin
      If CurveId = 0 Then
        fComponent.ExcitationVisible := clbCurves.Checked[clbCurves.ItemIndex]
      Else
        For I := 0 To fComponent.ResponseCount - 1 Do
          If fComponent.Responses[I].CurveId = CurveId Then
            Begin
              fComponent.Responses[I].Visible := 
                                                 clbCurves.Checked[clbCurves.ItemIndex];
              Break;
            End;
    End;
  PresentResult(ResultType);
End;

Procedure TRecorderImpactHammerView.pagesResultsChange(Sender: TObject);
Begin
  If fComponent <> Nil Then
    fComponent.ActiveResultType := 
                                   TRecorderImpactResultType(pagesResults.TabIndex);
  PresentResult(TRecorderImpactResultType(pagesResults.TabIndex));
End;

Procedure TRecorderImpactHammerView.UpdateStatePresentation;
Begin
  lblState.Caption := StateCaption(fSnapshot.State);
  lblStatus.Caption := fSnapshot.StatusText;
  progressMeasurement.Position := EnsureRange(fSnapshot.ProgressPercent, 0, 100);
End;

Procedure TRecorderImpactHammerView.UpdateImpactPosition;
Begin
  If fSnapshot.ImpactCount <= 0 Then
    lblImpactPosition.Caption := 'Ударов нет'
  Else
    lblImpactPosition.Caption := Format('%d из %d', [
                                 fSnapshot.ImpactIndex + 1,
                                 fSnapshot.ImpactCount
                                 ]);

  If fSnapshot.ImpactHidden Then
    btnHide.Caption := 'Показать'
  Else
    btnHide.Caption := 'Скрыть';
End;

Procedure TRecorderImpactHammerView.UpdateCommandAvailability;
Begin
  btnPreviousImpact.Enabled := fSnapshot.CanNavigatePrevious;
  btnNextImpact.Enabled := fSnapshot.CanNavigateNext;
  btnHide.Enabled := fSnapshot.CanHide;
  btnDelete.Enabled := fSnapshot.CanDelete;
  btnStart.Enabled := fSnapshot.CanStart;
  btnArm.Enabled := fSnapshot.CanArm;
  btnStop.Enabled := fSnapshot.CanStop;
End;

Function TRecorderImpactHammerView.StateCaption(
                                                AState: TRecorderImpactHammerState): string;
Begin
  Case AState Of 
    ihsIdle:
             Result := 'Готов';
    ihsArmed:
              Result := 'Ожидание удара';
    ihsRunning:
                Result := 'Измерение';
    ihsStopping:
                 Result := 'Остановка';
    ihsCompleted:
                  Result := 'Завершено';
    ihsFault:
              Result := 'Ошибка';
  End;
End;

Procedure TRecorderImpactHammerView.btnPreviousImpactClick(Sender: TObject);
Begin
  If Assigned(fApplicationService) Then
    fApplicationService.NavigateToPreviousImpact;
End;

Procedure TRecorderImpactHammerView.btnNextImpactClick(Sender: TObject);
Begin
  If Assigned(fApplicationService) Then
    fApplicationService.NavigateToNextImpact;
End;

Procedure TRecorderImpactHammerView.btnHideClick(Sender: TObject);
Begin
  If Assigned(fApplicationService) Then
    fApplicationService.SetCurrentImpactHidden(Not fSnapshot.ImpactHidden);
End;

Procedure TRecorderImpactHammerView.btnDeleteClick(Sender: TObject);
Begin
  If Assigned(fApplicationService) Then
    fApplicationService.DeleteCurrentImpact;
End;

Procedure TRecorderImpactHammerView.btnStartClick(Sender: TObject);
Begin
  If Assigned(fApplicationService) Then
    fApplicationService.StartMeasurement;
End;

Procedure TRecorderImpactHammerView.btnArmClick(Sender: TObject);
Begin
  If Assigned(fApplicationService) Then
    fApplicationService.ArmMeasurement;
End;

Procedure TRecorderImpactHammerView.btnStopClick(Sender: TObject);
Begin
  If Assigned(fApplicationService) Then
    fApplicationService.StopMeasurement;
End;

initialization
TRecorderVisualControlRegistry.RegisterControl(
                                               TRecorderImpactHammerComponent,
                                               TRecorderImpactHammerView);

End.
