unit uRecorderSqlTrendView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, Buttons, Grids, Graphics,
  Math, DateUtils, Dialogs,
  uOglChart, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uRecorderSqlDbTypes, uRecorderSqlTrendModel;

type
  TRecorderSqlTrendView = class;
  TRecorderSqlTrendZoomMode = (stzmNone, stzmX, stzmY, stzmXY);

  TRecorderSqlTrendLoadThread = class(TThread)
  private
    fConfigFileName: string;
    fErrorText: string;
    fFromUtc, fToUtc: Double;
    fMaxPoints: Integer;
    fAppendLoad: Boolean;
    fOwner: TRecorderSqlTrendView;
    fPoints: TRecorderSqlTrendPoints;
    fSignalNames: TStringList;
    procedure Deliver;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderSqlTrendView; const AConfigFileName: string;
      ASignalNames: TStrings; AFromUtc, AToUtc: Double; AMaxPoints: Integer;
      AAppendLoad: Boolean);
    destructor Destroy; override;
  end;

  TRecorderSqlTrendView = class(TPanel, IVForm)
  private
    fAxisCombo: TComboBox;
    fAxisMaxEdit: TEdit;
    fAxisMinEdit: TEdit;
    fAxisPanel: TPanel;
    fAxisMax: array of Double;
    fAxisMin: array of Double;
    fAxisSignature: string;
    fAxisControlsLoading: Boolean;
    fComponent: TRecorderSqlTrendComponent;
    fCursorButton: TSpeedButton;
    fCursorModeCombo: TComboBox;
    fDeleteIntervalButton: TButton;
    fDisplayCombo: TComboBox;
    fDisplayNextButton: TSpeedButton;
    fDisplayPrevButton: TSpeedButton;
    fCursorDragging: Boolean;
    fCursorDragIndex: Integer;
    fCursorEnabled: Boolean;
    fCursor2Point: TPoint;
    fCursor2Visible: Boolean;
    fCursorPoint: TPoint;
    fCursorVisible: Boolean;
    fErrorText: string;
    fFullAxisMax: array of Double;
    fFullAxisMin: array of Double;
    fFullFromUtc, fFullToUtc: Double;
    fFromUtc, fToUtc: Double;
    fLoadPending: Boolean;
    fLegendColors: array of TColor;
    fLegendGrid: TStringGrid;
    fLegendPanel: TPanel;
    fLegendSplitter: TSplitter;
    fMouseAnchor: TPoint;
    fMouseCurrent: TPoint;
    fZoomMode: TRecorderSqlTrendZoomMode;
    fPanAxisMax: array of Double;
    fPanAxisMin: array of Double;
    fPanFromUtc, fPanToUtc: Double;
    fPanning: Boolean;
    fPoints: TRecorderSqlTrendPoints;
    fReloadTimer: TTimer;
    fLiveReloadTimer: TTimer;
    fResetViewOnLoad: Boolean;
    fResetZoomButton: TButton;
    fWorker: TRecorderSqlTrendLoadThread;
    fZoomSelecting: Boolean;
    procedure AxisRangeEditChange(Sender: TObject);
    procedure AxisComboChange(Sender: TObject);
    procedure CursorButtonClick(Sender: TObject);
    procedure CursorModeChange(Sender: TObject);
    procedure DeleteIntervalButtonClick(Sender: TObject);
    procedure DisplayComboChange(Sender: TObject);
    procedure DisplayNextClick(Sender: TObject);
    procedure DisplayPrevClick(Sender: TObject);
    procedure FillDisplayControls;
    function BuildAxisSignature: string;
    function CursorUtc(APoint: TPoint): Double;
    function UtcDisplayTime(AUtc: TDateTime): TDateTime;
    function DoubleCursorMode: Boolean;
    function DoubleCursorReady: Boolean;
    procedure EnsureCursorDefaults;
    function GetPlotRect: TRect;
    procedure LegendGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      ARect: TRect; AState: TGridDrawState);
    procedure LegendGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure LegendGridDblClick(Sender: TObject);
    function LegendLineIndex(ARow: Integer): Integer;
    procedure LoadAxisControls;
    procedure ResetZoomClick(Sender: TObject);
    procedure ReloadTimerTimer(Sender: TObject);
    procedure LiveReloadTimerTimer(Sender: TObject);
    procedure ConfigureLiveReload;
    procedure StartLoad;
    procedure ClampCurrentDateXRange;
    procedure ApplyHorizontalZoom(ALeft, ARight: Integer; AZoomIn: Boolean;
      const APlot: TRect);
    procedure ApplyVerticalZoom(ATop, ABottom: Integer; AZoomIn: Boolean;
      const APlot: TRect);
    procedure MergeLivePoints(const ANewPoints: TRecorderSqlTrendPoints);
    function SyncAxisRangesFromComponent(AForce: Boolean): Boolean;
    procedure UpdateDeleteIntervalButton;
    procedure UpdateLegend;
    procedure AcceptLoad(AWorker: TRecorderSqlTrendLoadThread);
    function LineIndex(const ASignalName: string): Integer;
  protected
    procedure Paint; override;
    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
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

uses
  uRecorderSqlDbRepository;

const
  CSqlTrendCursorGrabPixels = 6;

function ClipLineToRect(var AX0, AY0, AX1, AY1: Double;
  const ARect: TRect): Boolean;
var
  lDx, lDy, lT0, lT1: Double;

  function ClipTest(AP, AQ: Double): Boolean;
  var
    lR: Double;
  begin
    if AP = 0 then Exit(AQ >= 0);
    lR := AQ / AP;
    if AP < 0 then
    begin
      if lR > lT1 then Exit(False);
      if lR > lT0 then lT0 := lR;
    end
    else
    begin
      if lR < lT0 then Exit(False);
      if lR < lT1 then lT1 := lR;
    end;
    Result := True;
  end;

var
  lOldX0, lOldY0: Double;
begin
  lDx := AX1 - AX0;
  lDy := AY1 - AY0;
  lT0 := 0;
  lT1 := 1;
  Result := ClipTest(-lDx, AX0 - ARect.Left) and
    ClipTest(lDx, ARect.Right - AX0) and
    ClipTest(-lDy, AY0 - ARect.Top) and
    ClipTest(lDy, ARect.Bottom - AY0);
  if not Result then Exit;
  lOldX0 := AX0;
  lOldY0 := AY0;
  AX0 := lOldX0 + lT0 * lDx;
  AY0 := lOldY0 + lT0 * lDy;
  AX1 := lOldX0 + lT1 * lDx;
  AY1 := lOldY0 + lT1 * lDy;
end;

constructor TRecorderSqlTrendLoadThread.Create(AOwner: TRecorderSqlTrendView;
  const AConfigFileName: string; ASignalNames: TStrings; AFromUtc,
  AToUtc: Double; AMaxPoints: Integer; AAppendLoad: Boolean);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fConfigFileName := AConfigFileName;
  fSignalNames := TStringList.Create;
  fSignalNames.Assign(ASignalNames);
  fFromUtc := AFromUtc;
  fToUtc := AToUtc;
  fMaxPoints := AMaxPoints;
  fAppendLoad := AAppendLoad;
end;

destructor TRecorderSqlTrendLoadThread.Destroy;
begin
  fSignalNames.Free;
  inherited Destroy;
end;

procedure TRecorderSqlTrendLoadThread.Execute;
var
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
begin
  try
    lConfig := TRecorderSqlDbConfig.Create;
    try
      lConfig.LoadFromFile(fConfigFileName);
      lRepository := TRecorderSqlDbRepository.Create(lConfig);
      try
        lRepository.ReadTrendPoints(fSignalNames, fFromUtc, fToUtc,
          fMaxPoints, fPoints, False);
      finally
        lRepository.Free;
      end;
    finally
      lConfig.Free;
    end;
  except
    on E: Exception do fErrorText := E.Message;
  end;
  if not Terminated then Synchronize(@Deliver);
end;

procedure TRecorderSqlTrendLoadThread.Deliver;
begin
  if (not Terminated) and (fOwner <> nil) then fOwner.AcceptLoad(Self);
end;

constructor TRecorderSqlTrendView.Create(AOwner: TComponent);
var
  lLabel: TLabel;
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  ParentBackground := False;
  Color := clWhite;
  DoubleBuffered := True;
  fLegendPanel := TPanel.Create(Self);
  fLegendPanel.Parent := Self;
  fLegendPanel.Align := alRight;
  fLegendPanel.Width := 220;
  fLegendPanel.BevelOuter := bvNone;
  fLegendPanel.Caption := '';
  fLegendGrid := TStringGrid.Create(fLegendPanel);
  fLegendGrid.Parent := fLegendPanel;
  fLegendGrid.Align := alClient;
  fLegendGrid.BorderStyle := bsNone;
  fLegendGrid.ColCount := 2;
  fLegendGrid.FixedCols := 0;
  fLegendGrid.FixedRows := 1;
  fLegendGrid.RowCount := 2;
  fLegendGrid.DefaultRowHeight := 20;
  fLegendGrid.ColWidths[0] := 48;
  fLegendGrid.ColWidths[1] := 166;
  fLegendGrid.Cells[0, 0] := '#';
  fLegendGrid.Cells[1, 0] := 'Линия';
  fLegendGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine,
    goHorzLine, goRowSelect];
  fLegendGrid.DefaultDrawing := False;
  fLegendGrid.OnDrawCell := @LegendGridDrawCell;
  fLegendGrid.OnSelectCell := @LegendGridSelectCell;
  fLegendGrid.OnDblClick := @LegendGridDblClick;
  fLegendSplitter := TSplitter.Create(Self);
  fLegendSplitter.Parent := Self;
  fLegendSplitter.Align := alRight;
  fLegendSplitter.Width := 5;
  fLegendSplitter.MinSize := 100;
  fAxisPanel := TPanel.Create(Self);
  fAxisPanel.Parent := Self;
  fAxisPanel.Align := alBottom;
  fAxisPanel.Height := 62;
  fAxisPanel.BevelOuter := bvLowered;
  lLabel := TLabel.Create(fAxisPanel);
  lLabel.Parent := fAxisPanel;
  lLabel.Left := 6;
  lLabel.Top := 8;
  lLabel.Caption := 'Ось Y:';
  fAxisCombo := TComboBox.Create(fAxisPanel);
  fAxisCombo.Parent := fAxisPanel;
  fAxisCombo.SetBounds(48, 4, 64, 24);
  fAxisCombo.Style := csDropDownList;
  fAxisCombo.OnChange := @AxisComboChange;
  lLabel := TLabel.Create(fAxisPanel);
  lLabel.Parent := fAxisPanel;
  lLabel.Left := 118;
  lLabel.Top := 8;
  lLabel.Caption := 'Мин:';
  fAxisMinEdit := TEdit.Create(fAxisPanel);
  fAxisMinEdit.Parent := fAxisPanel;
  fAxisMinEdit.SetBounds(150, 4, 60, 24);
  fAxisMinEdit.OnChange := @AxisRangeEditChange;
  lLabel := TLabel.Create(fAxisPanel);
  lLabel.Parent := fAxisPanel;
  lLabel.Left := 216;
  lLabel.Top := 8;
  lLabel.Caption := 'Макс:';
  fAxisMaxEdit := TEdit.Create(fAxisPanel);
  fAxisMaxEdit.Parent := fAxisPanel;
  fAxisMaxEdit.SetBounds(256, 4, 60, 24);
  fAxisMaxEdit.OnChange := @AxisRangeEditChange;
  fResetZoomButton := TButton.Create(fAxisPanel);
  fResetZoomButton.Parent := fAxisPanel;
  fResetZoomButton.SetBounds(322, 3, 100, 26);
  fResetZoomButton.Caption := 'Весь график';
  fResetZoomButton.OnClick := @ResetZoomClick;
  fCursorButton := TSpeedButton.Create(fAxisPanel);
  fCursorButton.Parent := fAxisPanel;
  fCursorButton.SetBounds(428, 3, 112, 26);
  fCursorButton.Caption := 'Показать курсор';
  fCursorButton.AllowAllUp := True;
  fCursorButton.GroupIndex := 91;
  fCursorButton.Down := False;
  fCursorButton.OnClick := @CursorButtonClick;
  fCursorModeCombo := TComboBox.Create(fAxisPanel);
  fCursorModeCombo.Parent := fAxisPanel;
  fCursorModeCombo.SetBounds(546, 3, 92, 26);
  fCursorModeCombo.Style := csDropDownList;
  fCursorModeCombo.Items.Add('Один');
  fCursorModeCombo.Items.Add('Два');
  fCursorModeCombo.ItemIndex := 0;
  fCursorModeCombo.OnChange := @CursorModeChange;
  fDeleteIntervalButton := TButton.Create(fAxisPanel);
  fDeleteIntervalButton.Parent := fAxisPanel;
  fDeleteIntervalButton.SetBounds(644, 3, 138, 26);
  fDeleteIntervalButton.Caption := 'Удалить интервал';
  fDeleteIntervalButton.Enabled := False;
  fDeleteIntervalButton.OnClick := @DeleteIntervalButtonClick;
  lLabel := TLabel.Create(fAxisPanel);
  lLabel.Parent := fAxisPanel;
  lLabel.SetBounds(6, 39, 92, 18);
  lLabel.Caption := 'Отображение:';
  fDisplayPrevButton := TSpeedButton.Create(fAxisPanel);
  fDisplayPrevButton.Parent := fAxisPanel;
  fDisplayPrevButton.SetBounds(100, 34, 28, 24);
  fDisplayPrevButton.Caption := '<';
  fDisplayPrevButton.OnClick := @DisplayPrevClick;
  fDisplayCombo := TComboBox.Create(fAxisPanel);
  fDisplayCombo.Parent := fAxisPanel;
  fDisplayCombo.SetBounds(132, 34, 250, 24);
  fDisplayCombo.Style := csDropDownList;
  fDisplayCombo.OnChange := @DisplayComboChange;
  fDisplayNextButton := TSpeedButton.Create(fAxisPanel);
  fDisplayNextButton.Parent := fAxisPanel;
  fDisplayNextButton.SetBounds(386, 34, 28, 24);
  fDisplayNextButton.Caption := '>';
  fDisplayNextButton.OnClick := @DisplayNextClick;
  fReloadTimer := TTimer.Create(Self);
  fReloadTimer.Enabled := False;
  fReloadTimer.Interval := 50;
  fReloadTimer.OnTimer := @ReloadTimerTimer;
  fLiveReloadTimer := TTimer.Create(Self);
  fLiveReloadTimer.Enabled := False;
  fLiveReloadTimer.Interval := 1000;
  fLiveReloadTimer.OnTimer := @LiveReloadTimerTimer;
end;

procedure TRecorderSqlTrendView.FillDisplayControls;
var I: Integer;
begin
  fDisplayCombo.Items.Clear;
  if fComponent = nil then Exit;
  for I := 0 to fComponent.DisplayCount - 1 do
    fDisplayCombo.Items.Add(fComponent.Displays[I].Name);
  fDisplayCombo.ItemIndex := fComponent.ActiveDisplayIndex;
  fDisplayPrevButton.Enabled := fComponent.ActiveDisplayIndex > 0;
  fDisplayNextButton.Enabled := fComponent.ActiveDisplayIndex < fComponent.DisplayCount - 1;
end;

function TRecorderSqlTrendView.BuildAxisSignature: string;
var
  I: Integer;
  lAxis: TRecorderTrendAxis;
begin
  Result := '';
  if (fComponent = nil) or (fComponent.ActiveDisplay = nil) then
    Exit;
  Result := IntToStr(fComponent.ActiveDisplayIndex) + ':' +
    IntToStr(fComponent.ActiveDisplay.AxisCount) + ':';
  for I := 0 to fComponent.ActiveDisplay.AxisCount - 1 do
  begin
    lAxis := fComponent.ActiveDisplay.Axes[I];
    Result := Result + lAxis.Name + '|' + IntToStr(lAxis.Color) + '|' +
      FloatToStr(lAxis.RangeMin) + '|' + FloatToStr(lAxis.RangeMax) + ';';
  end;
end;

function TRecorderSqlTrendView.SyncAxisRangesFromComponent(
  AForce: Boolean): Boolean;
var
  I: Integer;
  lSignature: string;
begin
  Result := False;
  if (fComponent = nil) or (fComponent.ActiveDisplay = nil) then
    Exit;
  lSignature := BuildAxisSignature;
  if (not AForce) and (lSignature = fAxisSignature) then
    Exit;

  fAxisCombo.Items.BeginUpdate;
  try
    fAxisCombo.Items.Clear;
    SetLength(fAxisMin, fComponent.ActiveDisplay.AxisCount);
    SetLength(fAxisMax, fComponent.ActiveDisplay.AxisCount);
    SetLength(fFullAxisMin, fComponent.ActiveDisplay.AxisCount);
    SetLength(fFullAxisMax, fComponent.ActiveDisplay.AxisCount);
    for I := 0 to fComponent.ActiveDisplay.AxisCount - 1 do
    begin
      fAxisCombo.Items.Add(fComponent.ActiveDisplay.Axes[I].Name);
      fAxisMin[I] := fComponent.ActiveDisplay.Axes[I].RangeMin;
      fAxisMax[I] := fComponent.ActiveDisplay.Axes[I].RangeMax;
      fFullAxisMin[I] := fAxisMin[I];
      fFullAxisMax[I] := fAxisMax[I];
    end;
  finally
    fAxisCombo.Items.EndUpdate;
  end;
  if fAxisCombo.Items.Count > 0 then
    fAxisCombo.ItemIndex := EnsureRange(fAxisCombo.ItemIndex, 0,
      fAxisCombo.Items.Count - 1);
  fAxisSignature := lSignature;
  LoadAxisControls;
  Result := True;
end;

procedure TRecorderSqlTrendView.DisplayComboChange(Sender: TObject);
begin
  if (fComponent = nil) or (fDisplayCombo.ItemIndex < 0) or
    (fDisplayCombo.ItemIndex = fComponent.ActiveDisplayIndex) then Exit;
  fComponent.ActiveDisplayIndex := fDisplayCombo.ItemIndex;
  Configure(fComponent, nil);
end;

procedure TRecorderSqlTrendView.DisplayPrevClick(Sender: TObject);
begin
  if fDisplayCombo.ItemIndex > 0 then
  begin fDisplayCombo.ItemIndex := fDisplayCombo.ItemIndex - 1; DisplayComboChange(nil); end;
end;

procedure TRecorderSqlTrendView.DisplayNextClick(Sender: TObject);
begin
  if fDisplayCombo.ItemIndex < fDisplayCombo.Items.Count - 1 then
  begin fDisplayCombo.ItemIndex := fDisplayCombo.ItemIndex + 1; DisplayComboChange(nil); end;
end;

function TRecorderSqlTrendView.DoubleCursorMode: Boolean;
begin
  Result := (fCursorModeCombo <> nil) and (fCursorModeCombo.ItemIndex = 1);
end;

function TRecorderSqlTrendView.CursorUtc(APoint: TPoint): Double;
var
  lPlot: TRect;
begin
  lPlot := GetPlotRect;
  Result := fFromUtc + (EnsureRange(APoint.X, lPlot.Left, lPlot.Right) -
    lPlot.Left) / Max(1, lPlot.Width) * (fToUtc - fFromUtc);
end;

function TRecorderSqlTrendView.UtcDisplayTime(AUtc: TDateTime): TDateTime;
begin
  Result := UniversalTimeToLocal(AUtc);
end;

function TRecorderSqlTrendView.DoubleCursorReady: Boolean;
begin
  Result := fCursorEnabled and DoubleCursorMode and fCursorVisible and
    fCursor2Visible and (fToUtc > fFromUtc);
end;

procedure TRecorderSqlTrendView.UpdateDeleteIntervalButton;
begin
  if fDeleteIntervalButton <> nil then
    fDeleteIntervalButton.Enabled := DoubleCursorReady;
end;

procedure TRecorderSqlTrendView.EnsureCursorDefaults;
var
  lPlot: TRect;
begin
  lPlot := GetPlotRect;
  if not fCursorVisible then
  begin
    if DoubleCursorMode then
      fCursorPoint := Point(lPlot.Left + Max(1, lPlot.Width) div 3,
        (lPlot.Top + lPlot.Bottom) div 2)
    else
      fCursorPoint := Point((lPlot.Left + lPlot.Right) div 2,
        (lPlot.Top + lPlot.Bottom) div 2);
    fCursorVisible := True;
  end;
  if DoubleCursorMode then
  begin
    if not fCursor2Visible then
    begin
      fCursor2Point := Point(lPlot.Left + 2 * Max(1, lPlot.Width) div 3,
        (lPlot.Top + lPlot.Bottom) div 2);
      fCursor2Visible := True;
    end;
  end
  else
    fCursor2Visible := False;
end;

procedure TRecorderSqlTrendView.CursorModeChange(Sender: TObject);
begin
  if fCursorEnabled then
    EnsureCursorDefaults
  else
    fCursor2Visible := False;
  UpdateDeleteIntervalButton;
  Invalidate;
end;

procedure TRecorderSqlTrendView.CursorButtonClick(Sender: TObject);
begin
  fCursorEnabled := fCursorButton.Down;
  if fCursorEnabled then
  begin
    fCursorButton.Caption := 'Скрыть курсор';
    EnsureCursorDefaults;
  end
  else
  begin
    fCursorButton.Caption := 'Показать курсор';
    fCursorVisible := False;
    fCursor2Visible := False;
    fCursorDragging := False;
    fCursorDragIndex := 0;
    MouseCapture := False;
  end;
  UpdateDeleteIntervalButton;
  Invalidate;
end;

procedure TRecorderSqlTrendView.DeleteIntervalButtonClick(Sender: TObject);
var
  I: Integer;
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
  lNames: TStringList;
  lDeleted: Int64;
  lLine: TRecorderTrendLine;
  lDeleteFromUtc, lDeleteToUtc: Double;
begin
  if (fComponent = nil) or (fComponent.ActiveDisplay = nil) then Exit;
  if not DoubleCursorReady then
  begin
    MessageDlg('SQL БД',
      'Удаление интервала доступно только в режиме двойного курсора.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lDeleteFromUtc := Min(CursorUtc(fCursorPoint), CursorUtc(fCursor2Point));
  lDeleteToUtc := Max(CursorUtc(fCursorPoint), CursorUtc(fCursor2Point));
  if SameValue(lDeleteFromUtc, lDeleteToUtc) then
  begin
    MessageDlg('SQL БД', 'Интервал между курсорами пустой.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lNames := TStringList.Create;
  try
    try
      lNames.CaseSensitive := False;
      lNames.Sorted := True;
      lNames.Duplicates := dupIgnore;
      for I := 0 to fComponent.ActiveDisplay.LineCount - 1 do
      begin
        lLine := fComponent.ActiveDisplay.Lines[I];
        if (lLine <> nil) and lLine.Visible and (Trim(lLine.TagName) <> '') then
          lNames.Add(lLine.TagName);
      end;
      if lNames.Count = 0 then
      begin
        MessageDlg('SQL БД', 'В текущем отображении нет видимых линий.',
          mtWarning, [mbOK], 0);
        Exit;
      end;
      if MessageDlg('SQL БД',
        Format('Удалить из БД интервал UTC %s .. %s для линий: %d?',
          [FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', lDeleteFromUtc),
           FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', lDeleteToUtc),
           lNames.Count]),
        mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        Exit;
      lConfig := TRecorderSqlDbConfig.Create;
      try
        lConfig.LoadFromFile(fComponent.ConfigFileName);
        lRepository := TRecorderSqlDbRepository.Create(lConfig);
        try
          lRepository.DeleteSignalValuesInterval(lNames, lDeleteFromUtc,
            lDeleteToUtc, lDeleted);
        finally
          lRepository.Free;
        end;
      finally
        lConfig.Free;
      end;
      MessageDlg('SQL БД',
        Format('Удалено точек из интервала: %d.', [lDeleted]),
        mtInformation, [mbOK], 0);
      fLoadPending := True;
      StartLoad;
    except
      on E: Exception do
        MessageDlg('SQL БД', E.Message, mtError, [mbOK], 0);
    end;
  finally
    lNames.Free;
  end;
end;

procedure TRecorderSqlTrendView.LegendGridDrawCell(Sender: TObject; ACol,
  ARow: Integer; ARect: TRect; AState: TGridDrawState);
var
  lText: string;
  lColor: TColor;
begin
  if gdFixed in AState then
    fLegendGrid.Canvas.Brush.Color := clBtnFace
  else if gdSelected in AState then
    fLegendGrid.Canvas.Brush.Color := clHighlight
  else
    fLegendGrid.Canvas.Brush.Color := clWindow;
  fLegendGrid.Canvas.Brush.Style := bsSolid;
  fLegendGrid.Canvas.FillRect(ARect);
  if (ARow > 0) and (ACol = 0) and (ARow - 1 < Length(fLegendColors)) then
  begin
    lColor := fLegendColors[ARow - 1];
    fLegendGrid.Canvas.Brush.Color := lColor;
    fLegendGrid.Canvas.Pen.Color := lColor;
    fLegendGrid.Canvas.Rectangle(ARect.Left + 4, ARect.Top + 5,
      ARect.Left + 14, ARect.Bottom - 5);
    lText := fLegendGrid.Cells[ACol, ARow];
    fLegendGrid.Canvas.Brush.Style := bsClear;
    if gdSelected in AState then
      fLegendGrid.Canvas.Font.Color := clHighlightText
    else
      fLegendGrid.Canvas.Font.Color := clWindowText;
    fLegendGrid.Canvas.TextOut(ARect.Left + 20, ARect.Top + 2, lText);
  end
  else
  begin
    fLegendGrid.Canvas.Brush.Style := bsClear;
    if gdSelected in AState then
      fLegendGrid.Canvas.Font.Color := clHighlightText
    else
      fLegendGrid.Canvas.Font.Color := clWindowText;
    fLegendGrid.Canvas.TextOut(ARect.Left + 4, ARect.Top + 2,
      fLegendGrid.Cells[ACol, ARow]);
  end;
end;

function TRecorderSqlTrendView.LegendLineIndex(ARow: Integer): Integer;
var
  I, lVisibleRow: Integer;
begin
  Result := -1;
  if (ARow <= 0) or (fComponent = nil) or
    (fComponent.ActiveDisplay = nil) then Exit;
  lVisibleRow := 0;
  for I := 0 to fComponent.ActiveDisplay.LineCount - 1 do
    if fComponent.ActiveDisplay.Lines[I].Visible then
    begin
      Inc(lVisibleRow);
      if lVisibleRow = ARow then Exit(I);
    end;
end;

procedure TRecorderSqlTrendView.LegendGridSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
var
  lLineIndex, lAxisIndex: Integer;
begin
  lLineIndex := LegendLineIndex(ARow);
  if lLineIndex < 0 then Exit;
  lAxisIndex := fComponent.ActiveDisplay.Lines[lLineIndex].AxisIndex;
  if (lAxisIndex < 0) or (lAxisIndex >= fAxisCombo.Items.Count) then Exit;
  fAxisCombo.ItemIndex := lAxisIndex;
  LoadAxisControls;
end;

procedure TRecorderSqlTrendView.LegendGridDblClick(Sender: TObject);
var
  I, lLineIndex, lAxisIndex: Integer;
  lMin, lMax, lRange, lPadding: Double;
  lFound: Boolean;
  lSignalName: string;
begin
  lLineIndex := LegendLineIndex(fLegendGrid.Row);
  if lLineIndex < 0 then Exit;
  lAxisIndex := fComponent.ActiveDisplay.Lines[lLineIndex].AxisIndex;
  if (lAxisIndex < 0) or (lAxisIndex > High(fAxisMin)) then Exit;
  lSignalName := fComponent.ActiveDisplay.Lines[lLineIndex].TagName;
  lFound := False;
  for I := 0 to High(fPoints) do
    if SameText(fPoints[I].SignalName, lSignalName) and
      (fPoints[I].TimestampUtc >= fFromUtc) and
      (fPoints[I].TimestampUtc <= fToUtc) then
    begin
      if not lFound then
      begin
        lMin := fPoints[I].Value;
        lMax := lMin;
        lFound := True;
      end
      else
      begin
        lMin := Min(lMin, fPoints[I].Value);
        lMax := Max(lMax, fPoints[I].Value);
      end;
    end;
  if not lFound then Exit;
  lRange := lMax - lMin;
  if lRange > 0 then
    lPadding := lRange * 0.10
  else
    lPadding := Max(1.0, Abs(lMin) * 0.10);
  fAxisMin[lAxisIndex] := lMin - lPadding;
  fAxisMax[lAxisIndex] := lMax + lPadding;
  fAxisCombo.ItemIndex := lAxisIndex;
  LoadAxisControls;
  Invalidate;
end;

destructor TRecorderSqlTrendView.Destroy;
begin
  fReloadTimer.Enabled := False;
  fLiveReloadTimer.Enabled := False;
  if fWorker <> nil then
  begin
    fWorker.Terminate;
    fWorker.WaitFor;
    FreeAndNil(fWorker);
  end;
  inherited Destroy;
end;

procedure TRecorderSqlTrendView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  if not (AComponent is TRecorderSqlTrendComponent) then Exit;
  fComponent := TRecorderSqlTrendComponent(AComponent);
  FillDisplayControls;
  fAxisCombo.ItemIndex := 0;
  SyncAxisRangesFromComponent(True);
  UpdateLegend;
  UpdateDeleteIntervalButton;
  ConfigureLiveReload;
  fResetViewOnLoad := True;
  fLoadPending := True;
  fReloadTimer.Enabled := True;
  Invalidate;
end;

function TRecorderSqlTrendView.GetPlotRect: TRect;
begin
  Result := Rect(64, 18, Max(65, fLegendSplitter.Left - 8),
    Max(19, ClientHeight - fAxisPanel.Height - 42));
end;

procedure TRecorderSqlTrendView.UpdateLegend;
var
  I, lRow: Integer;
  lCaption: string;
begin
  if (fLegendGrid = nil) or (fComponent = nil) then Exit;
  lRow := 0;
  for I := 0 to fComponent.ActiveDisplay.LineCount - 1 do
    if fComponent.ActiveDisplay.Lines[I].Visible then Inc(lRow);
  fLegendGrid.RowCount := Max(2, lRow + 1);
  SetLength(fLegendColors, lRow);
  for I := 1 to fLegendGrid.RowCount - 1 do
  begin
    fLegendGrid.Cells[0, I] := '';
    fLegendGrid.Cells[1, I] := '';
  end;
  lRow := 0;
  for I := 0 to fComponent.ActiveDisplay.LineCount - 1 do
    if fComponent.ActiveDisplay.Lines[I].Visible then
    begin
      Inc(lRow);
      fLegendColors[lRow - 1] := TColor(fComponent.ActiveDisplay.Lines[I].Color);
      fLegendGrid.Cells[0, lRow] := IntToStr(I + 1);
      lCaption := fComponent.ActiveDisplay.Lines[I].TagName;
      if lCaption = '' then lCaption := fComponent.ActiveDisplay.Lines[I].Name;
      fLegendGrid.Cells[1, lRow] := lCaption;
    end;
  fLegendGrid.Invalidate;
end;

procedure TRecorderSqlTrendView.LoadAxisControls;
var I: Integer;
begin
  I := fAxisCombo.ItemIndex;
  if (I < 0) or (I >= Length(fAxisMin)) then Exit;
  fAxisControlsLoading := True;
  try
    fAxisMinEdit.Text := FloatToStr(fAxisMin[I]);
    fAxisMaxEdit.Text := FloatToStr(fAxisMax[I]);
  finally
    fAxisControlsLoading := False;
  end;
end;

procedure TRecorderSqlTrendView.AxisComboChange(Sender: TObject);
begin
  LoadAxisControls;
end;

procedure TRecorderSqlTrendView.AxisRangeEditChange(Sender: TObject);
var I: Integer; lMin, lMax: Double;
begin
  if fAxisControlsLoading then
    Exit;
  I := fAxisCombo.ItemIndex;
  if (fComponent = nil) or (I < 0) or (I >= fComponent.ActiveDisplay.AxisCount) then Exit;
  if not TryStrToFloat(Trim(fAxisMinEdit.Text), lMin) then Exit;
  if not TryStrToFloat(Trim(fAxisMaxEdit.Text), lMax) or (lMax <= lMin) then Exit;
  fAxisMin[I] := lMin;
  fAxisMax[I] := lMax;
  fComponent.ActiveDisplay.Axes[I].RangeMin := lMin;
  fComponent.ActiveDisplay.Axes[I].RangeMax := lMax;
  fAxisSignature := BuildAxisSignature;
  Invalidate;
end;

procedure TRecorderSqlTrendView.ResetZoomClick(Sender: TObject);
var
  I, lLineIndex, lAxisIndex: Integer;
  lHasX: Boolean;
  lHasAxis: array of Boolean;
  lRange, lPadding: Double;
begin
  if (fComponent = nil) or (fComponent.ActiveDisplay = nil) then Exit;
  SetLength(lHasAxis, Length(fAxisMin));
  lHasX := False;
  for I := 0 to High(fPoints) do
  begin
    lLineIndex := LineIndex(fPoints[I].SignalName);
    if (lLineIndex < 0) or
      (not fComponent.ActiveDisplay.Lines[lLineIndex].Visible) then Continue;
    lAxisIndex := EnsureRange(
      fComponent.ActiveDisplay.Lines[lLineIndex].AxisIndex, 0,
      High(fAxisMin));
    if not lHasX then
    begin
      fFullFromUtc := fPoints[I].TimestampUtc;
      fFullToUtc := fPoints[I].TimestampUtc;
      lHasX := True;
    end
    else
    begin
      fFullFromUtc := Min(fFullFromUtc, fPoints[I].TimestampUtc);
      fFullToUtc := Max(fFullToUtc, fPoints[I].TimestampUtc);
    end;
    if not lHasAxis[lAxisIndex] then
    begin
      fFullAxisMin[lAxisIndex] := fPoints[I].Value;
      fFullAxisMax[lAxisIndex] := fPoints[I].Value;
      lHasAxis[lAxisIndex] := True;
    end
    else
    begin
      fFullAxisMin[lAxisIndex] := Min(fFullAxisMin[lAxisIndex], fPoints[I].Value);
      fFullAxisMax[lAxisIndex] := Max(fFullAxisMax[lAxisIndex], fPoints[I].Value);
    end;
  end;
  if lHasX then
  begin
    fFromUtc := fFullFromUtc;
    fToUtc := fFullToUtc;
    if fToUtc <= fFromUtc then
      fToUtc := fFromUtc + 1.0 / SecsPerDay;
  end;
  for I := 0 to High(fAxisMin) do
  begin
    if lHasAxis[I] then
    begin
      lRange := fFullAxisMax[I] - fFullAxisMin[I];
      if lRange > 0 then
        lPadding := lRange * 0.10
      else
        lPadding := Max(1.0, Abs(fFullAxisMin[I]) * 0.10);
      fAxisMin[I] := fFullAxisMin[I] - lPadding;
      fAxisMax[I] := fFullAxisMax[I] + lPadding;
    end;
  end;
  ClampCurrentDateXRange;
  LoadAxisControls;
  Invalidate;
end;

procedure TRecorderSqlTrendView.DblClick;
begin
  inherited DblClick;
  ResetZoomClick(Self);
end;

procedure TRecorderSqlTrendView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
begin
  if SyncAxisRangesFromComponent(False) then
    Invalidate;
end;

function TRecorderSqlTrendView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

procedure TRecorderSqlTrendView.ReloadTimerTimer(Sender: TObject);
begin
  fReloadTimer.Enabled := False;
  StartLoad;
end;

procedure TRecorderSqlTrendView.ConfigureLiveReload;
var
  lConfig: TRecorderSqlDbConfig;
begin
  fLiveReloadTimer.Enabled := False;
  if (fComponent = nil) or
    (fComponent.TimeMode <> sttmFixedFromToCurrentUtc) or
    (not FileExists(fComponent.ConfigFileName)) then Exit;
  lConfig := TRecorderSqlDbConfig.Create;
  try
    try
      lConfig.LoadFromFile(fComponent.ConfigFileName);
      fLiveReloadTimer.Interval := Max(1000, lConfig.RecordPeriodMs);
    except
      fLiveReloadTimer.Interval := 1000;
    end;
  finally
    lConfig.Free;
  end;
  fLiveReloadTimer.Enabled := True;
end;

procedure TRecorderSqlTrendView.LiveReloadTimerTimer(Sender: TObject);
begin
  if (fComponent = nil) or
    (fComponent.TimeMode <> sttmFixedFromToCurrentUtc) or (not Showing) then
    Exit;
  if fWorker <> nil then Exit;
  fLoadPending := True;
  StartLoad;
end;

procedure TRecorderSqlTrendView.StartLoad;
var
  I: Integer;
  lSignals: TStringList;
  lFromUtc, lToUtc, lOverlapMs: Double;
  lAppendLoad: Boolean;
begin
  if (not fLoadPending) or (fComponent = nil) or (fWorker <> nil) then Exit;
  fLoadPending := False;
  fErrorText := '';
  if not FileExists(fComponent.ConfigFileName) then
  begin
    fErrorText := 'Не найден файл настроек SQL БД: ' + fComponent.ConfigFileName;
    Invalidate;
    Exit;
  end;
  lSignals := TStringList.Create;
  try
    for I := 0 to fComponent.ActiveDisplay.LineCount - 1 do
      if fComponent.ActiveDisplay.Lines[I].Visible and
        (Trim(fComponent.ActiveDisplay.Lines[I].TagName) <> '') then
        if lSignals.IndexOf(fComponent.ActiveDisplay.Lines[I].TagName) < 0 then
          lSignals.Add(fComponent.ActiveDisplay.Lines[I].TagName);
    lAppendLoad := (fComponent.TimeMode = sttmFixedFromToCurrentUtc) and
      (not fResetViewOnLoad) and (fFullToUtc > fFullFromUtc);
    if fComponent.TimeMode = sttmLatestWindow then
    begin
      lToUtc := LocalTimeToUniversal(Now);
      lFromUtc := lToUtc - Max(1.0, fComponent.DurationSec) / SecsPerDay;
    end
    else if fComponent.TimeMode = sttmFixedFromToCurrentUtc then
    begin
      lToUtc := LocalTimeToUniversal(Now);
      if lAppendLoad then
      begin
        lOverlapMs := Max(30000.0, 3.0 * fLiveReloadTimer.Interval);
        lFromUtc := Max(fComponent.FromUtc,
          fFullToUtc - lOverlapMs / MSecsPerDay);
      end
      else
        lFromUtc := fComponent.FromUtc;
    end
    else
    begin
      lFromUtc := fComponent.FromUtc;
      lToUtc := fComponent.ToUtc;
    end;
    fWorker := TRecorderSqlTrendLoadThread.Create(Self,
      fComponent.ConfigFileName, lSignals, lFromUtc, lToUtc,
      fComponent.MaxPointsPerLine, lAppendLoad);
    fWorker.Start;
  finally
    lSignals.Free;
  end;
end;

procedure TRecorderSqlTrendView.AcceptLoad(AWorker: TRecorderSqlTrendLoadThread);
var
  lWasAtLiveEdge: Boolean;
  lEdgeTolerance: Double;
begin
  if AWorker <> fWorker then Exit;
  if not fLoadPending then
  begin
    fErrorText := AWorker.fErrorText;
    if fErrorText = '' then
    begin
      lEdgeTolerance := Max(1, fLiveReloadTimer.Interval) /
        MSecsPerDay;
      lWasAtLiveEdge := (fFullToUtc <= fFullFromUtc) or
        SameValue(fToUtc, fFullToUtc, lEdgeTolerance);
      if AWorker.fAppendLoad then
        MergeLivePoints(AWorker.fPoints)
      else
        fPoints := Copy(AWorker.fPoints, 0, Length(AWorker.fPoints));
      { A failed load must not advance this watermark: the next live tick has
        to retry the same interval instead of permanently skipping its data. }
      if fResetViewOnLoad then
      begin
        fFromUtc := AWorker.fFromUtc;
        fToUtc := AWorker.fToUtc;
        fResetViewOnLoad := False;
      end
      else if (fComponent.TimeMode = sttmFixedFromToCurrentUtc) and
        lWasAtLiveEdge then
        fToUtc := AWorker.fToUtc;
      if not AWorker.fAppendLoad then
        fFullFromUtc := AWorker.fFromUtc;
      fFullToUtc := AWorker.fToUtc;
      ClampCurrentDateXRange;
    end
  end;
  AWorker.fOwner := nil;
  AWorker.FreeOnTerminate := True;
  fWorker := nil;
  if fLoadPending then fReloadTimer.Enabled := True;
  UpdateDeleteIntervalButton;
  Invalidate;
end;

procedure TRecorderSqlTrendView.MergeLivePoints(
  const ANewPoints: TRecorderSqlTrendPoints);
var
  I, J, K, lCombinedCount, lKeepFrom, lOutputStart: Integer;
  lSignalName: string;
  lMerged, lCombined: TRecorderSqlTrendPoints;
  lDuplicate: Boolean;
  lRowIds: TStringList;

  procedure SortCombinedByTime(ALeft, ARight: Integer);
  var
    lLeft, lRight: Integer;
    lPivot: Double;
    lSwap: TRecorderSqlTrendPoint;
  begin
    lLeft := ALeft;
    lRight := ARight;
    lPivot := lCombined[(ALeft + ARight) div 2].TimestampUtc;
    repeat
      while lCombined[lLeft].TimestampUtc < lPivot do Inc(lLeft);
      while lCombined[lRight].TimestampUtc > lPivot do Dec(lRight);
      if lLeft <= lRight then
      begin
        lSwap := lCombined[lLeft];
        lCombined[lLeft] := lCombined[lRight];
        lCombined[lRight] := lSwap;
        Inc(lLeft);
        Dec(lRight);
      end;
    until lLeft > lRight;
    if ALeft < lRight then SortCombinedByTime(ALeft, lRight);
    if lLeft < ARight then SortCombinedByTime(lLeft, ARight);
  end;
begin
  SetLength(lCombined, 2 * fComponent.MaxPointsPerLine);
  SetLength(lMerged, 0);
  lRowIds := TStringList.Create;
  try
    lRowIds.Sorted := True;
    lRowIds.Duplicates := dupIgnore;
    for I := 0 to fComponent.ActiveDisplay.LineCount - 1 do
    begin
      if not fComponent.ActiveDisplay.Lines[I].Visible then Continue;
      lSignalName := fComponent.ActiveDisplay.Lines[I].TagName;
      if Trim(lSignalName) = '' then Continue;
      lDuplicate := False;
      for K := 0 to I - 1 do
        if fComponent.ActiveDisplay.Lines[K].Visible and
          SameText(fComponent.ActiveDisplay.Lines[K].TagName,
            lSignalName) then
        begin
          lDuplicate := True;
          Break;
        end;
      if lDuplicate then Continue;

      lCombinedCount := 0;
      lRowIds.Clear;
      for J := 0 to High(fPoints) do
        if SameText(fPoints[J].SignalName, lSignalName) then
        begin
          lCombined[lCombinedCount] := fPoints[J];
          Inc(lCombinedCount);
          lRowIds.Add(fPoints[J].RowId);
        end;
      for J := 0 to High(ANewPoints) do
        if SameText(ANewPoints[J].SignalName, lSignalName) and
          (lRowIds.IndexOf(ANewPoints[J].RowId) < 0) then
        begin
          lCombined[lCombinedCount] := ANewPoints[J];
          Inc(lCombinedCount);
          lRowIds.Add(ANewPoints[J].RowId);
        end;
      if lCombinedCount > 1 then
        SortCombinedByTime(0, lCombinedCount - 1);
      lKeepFrom := Max(0,
        lCombinedCount - fComponent.MaxPointsPerLine);
      lOutputStart := Length(lMerged);
      SetLength(lMerged, lOutputStart + lCombinedCount - lKeepFrom);
      for J := lKeepFrom to lCombinedCount - 1 do
        lMerged[lOutputStart + J - lKeepFrom] := lCombined[J];
    end;
  finally
    lRowIds.Free;
  end;
  fPoints := lMerged;
end;

procedure TRecorderSqlTrendView.ClampCurrentDateXRange;
var
  lNowUtc, lMinUtc, lSpan: Double;
begin
  if (fComponent = nil) or
    (fComponent.TimeMode <> sttmFixedFromToCurrentUtc) then Exit;
  lNowUtc := LocalTimeToUniversal(Now);
  lMinUtc := fComponent.FromUtc;
  lSpan := Max(0.0, fToUtc - fFromUtc);
  if fToUtc > lNowUtc then
  begin
    fToUtc := lNowUtc;
    fFromUtc := fToUtc - lSpan;
  end;
  if fFromUtc < lMinUtc then
  begin
    fFromUtc := lMinUtc;
    fToUtc := fFromUtc + lSpan;
    if fToUtc > lNowUtc then
      fToUtc := lNowUtc;
  end;
end;

procedure TRecorderSqlTrendView.ApplyHorizontalZoom(ALeft, ARight: Integer;
  AZoomIn: Boolean; const APlot: TRect);
var
  lOldFrom, lOldTo, lRange, lLeftPart, lRightPart, lSelectedPart: Double;
begin
  lOldFrom := fFromUtc;
  lOldTo := fToUtc;
  lRange := lOldTo - lOldFrom;
  if lRange <= 0 then Exit;
  lLeftPart := (ALeft - APlot.Left) / Max(1, APlot.Width);
  lRightPart := (ARight - APlot.Left) / Max(1, APlot.Width);
  if AZoomIn then
  begin
    fFromUtc := lOldFrom + lLeftPart * lRange;
    fToUtc := lOldFrom + lRightPart * lRange;
  end
  else
  begin
    lSelectedPart := lRightPart - lLeftPart;
    if lSelectedPart <= 0 then Exit;
    fFromUtc := lOldFrom - lLeftPart / lSelectedPart * lRange;
    fToUtc := lOldTo + (1.0 - lRightPart) / lSelectedPart * lRange;
  end;
  ClampCurrentDateXRange;
end;

procedure TRecorderSqlTrendView.ApplyVerticalZoom(ATop, ABottom: Integer;
  AZoomIn: Boolean; const APlot: TRect);
var
  I: Integer;
  lOldMin, lOldMax, lRange, lLowPart, lHighPart, lSelectedPart: Double;
begin
  lLowPart := (APlot.Bottom - ABottom) / Max(1, APlot.Height);
  lHighPart := (APlot.Bottom - ATop) / Max(1, APlot.Height);
  lSelectedPart := lHighPart - lLowPart;
  if lSelectedPart <= 0 then Exit;
  for I := 0 to High(fAxisMin) do
  begin
    lOldMin := fAxisMin[I];
    lOldMax := fAxisMax[I];
    lRange := lOldMax - lOldMin;
    if lRange <= 0 then Continue;
    if AZoomIn then
    begin
      fAxisMin[I] := lOldMin + lLowPart * lRange;
      fAxisMax[I] := lOldMin + lHighPart * lRange;
    end
    else
    begin
      fAxisMin[I] := lOldMin - lLowPart / lSelectedPart * lRange;
      fAxisMax[I] := lOldMax + (1.0 - lHighPart) /
        lSelectedPart * lRange;
    end;
  end;
end;

procedure TRecorderSqlTrendView.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var I: Integer; lPlot: TRect;
begin
  inherited MouseDown(Button, Shift, X, Y);
  lPlot := GetPlotRect;
  fMouseAnchor := Point(X, Y);
  fMouseCurrent := fMouseAnchor;
  if Button = mbLeft then
  begin
    if fCursorEnabled then
    begin
      if (X < lPlot.Left) or (X > lPlot.Right) or
        (Y < lPlot.Top) or (Y > lPlot.Bottom) then Exit;
      fCursorDragIndex := 0;
      if fCursorVisible and
        (Abs(X - fCursorPoint.X) <= CSqlTrendCursorGrabPixels) then
        fCursorDragIndex := 1;
      if DoubleCursorMode and fCursor2Visible and
        (Abs(X - fCursor2Point.X) <= CSqlTrendCursorGrabPixels) and
        ((fCursorDragIndex = 0) or
         (Abs(X - fCursor2Point.X) < Abs(X - fCursorPoint.X))) then
        fCursorDragIndex := 2;
      if fCursorDragIndex = 0 then Exit;
      fCursorDragging := True;
    end
    else
    begin
      if (X >= lPlot.Left) and (X <= lPlot.Right) and
        (Y >= lPlot.Top) and (Y <= lPlot.Bottom) then
        fZoomMode := stzmXY
      else if (X >= lPlot.Left) and (X <= lPlot.Right) and
        (Y > lPlot.Bottom) and (Y < fAxisPanel.Top) then
        fZoomMode := stzmX
      else if (X < lPlot.Left) and (X >= 0) and
        (Y >= lPlot.Top) and (Y <= lPlot.Bottom) then
        fZoomMode := stzmY
      else
        fZoomMode := stzmNone;
      if fZoomMode = stzmNone then Exit;
      fZoomSelecting := True;
    end;
    MouseCapture := True;
    Invalidate;
  end
  else if Button = mbRight then
  begin
    if (X < lPlot.Left) or (X > lPlot.Right) or
      (Y < lPlot.Top) or (Y > lPlot.Bottom) then Exit;
    fPanning := True;
    fPanFromUtc := fFromUtc;
    fPanToUtc := fToUtc;
    SetLength(fPanAxisMin, Length(fAxisMin));
    SetLength(fPanAxisMax, Length(fAxisMax));
    for I := 0 to High(fAxisMin) do
    begin
      fPanAxisMin[I] := fAxisMin[I];
      fPanAxisMax[I] := fAxisMax[I];
    end;
    MouseCapture := True;
    Cursor := crSizeAll;
  end;
end;

procedure TRecorderSqlTrendView.MouseMove(Shift: TShiftState; X, Y: Integer);
var I, lDx, lDy: Integer; lPlot: TRect; lShift, lRange: Double;
begin
  inherited MouseMove(Shift, X, Y);
  lPlot := GetPlotRect;
  if fZoomSelecting then
  begin
    if fZoomMode in [stzmX, stzmXY] then
      fMouseCurrent.X := EnsureRange(X, lPlot.Left, lPlot.Right);
    if fZoomMode in [stzmY, stzmXY] then
      fMouseCurrent.Y := EnsureRange(Y, lPlot.Top, lPlot.Bottom);
    Invalidate;
  end
  else if fCursorDragging then
  begin
    if fCursorDragIndex = 2 then
    begin
      fCursor2Point := Point(EnsureRange(X, lPlot.Left, lPlot.Right),
        EnsureRange(Y, lPlot.Top, lPlot.Bottom));
      fCursor2Visible := True;
    end
    else
    begin
      fCursorPoint := Point(EnsureRange(X, lPlot.Left, lPlot.Right),
        EnsureRange(Y, lPlot.Top, lPlot.Bottom));
      fCursorVisible := True;
    end;
    UpdateDeleteIntervalButton;
    Invalidate;
  end
  else if fPanning then
  begin
    lDx := X - fMouseAnchor.X;
    lDy := Y - fMouseAnchor.Y;
    lShift := -lDx / Max(1, lPlot.Width) * (fPanToUtc - fPanFromUtc);
    fFromUtc := fPanFromUtc + lShift;
    fToUtc := fPanToUtc + lShift;
    if fFromUtc < fFullFromUtc then
    begin
      fToUtc := fToUtc + (fFullFromUtc - fFromUtc);
      fFromUtc := fFullFromUtc;
    end;
    if fToUtc > fFullToUtc then
    begin
      fFromUtc := fFromUtc - (fToUtc - fFullToUtc);
      fToUtc := fFullToUtc;
    end;
    ClampCurrentDateXRange;
    for I := 0 to High(fAxisMin) do
    begin
      lRange := fPanAxisMax[I] - fPanAxisMin[I];
      lShift := lDy / Max(1, lPlot.Height) * lRange;
      fAxisMin[I] := fPanAxisMin[I] + lShift;
      fAxisMax[I] := fPanAxisMax[I] + lShift;
    end;
    LoadAxisControls;
    Invalidate;
  end;
end;

procedure TRecorderSqlTrendView.MouseLeave;
begin
  inherited MouseLeave;
  if fZoomSelecting or fPanning or fCursorEnabled then Exit;
  fCursorVisible := False;
  Invalidate;
end;

procedure TRecorderSqlTrendView.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  lLeft, lRight, lTop, lBottom: Integer;
  lPlot: TRect;
  lZoomIn, lHorizontalReady, lVerticalReady: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  lPlot := GetPlotRect;
  if (Button = mbLeft) and fCursorDragging then
  begin
    fCursorDragging := False;
    fCursorDragIndex := 0;
    MouseCapture := False;
    UpdateDeleteIntervalButton;
    Invalidate;
  end
  else if (Button = mbLeft) and fZoomSelecting then
  begin
    fZoomSelecting := False;
    MouseCapture := False;
    lLeft := Min(fMouseAnchor.X, fMouseCurrent.X);
    lRight := Max(fMouseAnchor.X, fMouseCurrent.X);
    lTop := Min(fMouseAnchor.Y, fMouseCurrent.Y);
    lBottom := Max(fMouseAnchor.Y, fMouseCurrent.Y);
    lHorizontalReady := (fZoomMode in [stzmX, stzmXY]) and
      (lRight - lLeft >= 6);
    lVerticalReady := (fZoomMode in [stzmY, stzmXY]) and
      (lBottom - lTop >= 6);
    case fZoomMode of
      stzmX: lZoomIn := fMouseCurrent.X > fMouseAnchor.X;
      stzmY: lZoomIn := fMouseCurrent.Y > fMouseAnchor.Y;
      stzmXY: lZoomIn := (fMouseCurrent.X > fMouseAnchor.X) and
        (fMouseCurrent.Y > fMouseAnchor.Y);
      else lZoomIn := False;
    end;
    if lHorizontalReady then
      ApplyHorizontalZoom(lLeft, lRight, lZoomIn, lPlot);
    if lVerticalReady then
      ApplyVerticalZoom(lTop, lBottom, lZoomIn, lPlot);
    if lHorizontalReady or lVerticalReady then
      LoadAxisControls;
    fZoomMode := stzmNone;
    Invalidate;
  end
  else if (Button = mbRight) and fPanning then
  begin
    fPanning := False;
    MouseCapture := False;
    Cursor := crDefault;
    LoadAxisControls;
    Invalidate;
  end;
end;

function TRecorderSqlTrendView.LineIndex(const ASignalName: string): Integer;
begin
  Result := -1;
  if fComponent = nil then Exit;
  for Result := 0 to fComponent.ActiveDisplay.LineCount - 1 do
    if SameText(fComponent.ActiveDisplay.Lines[Result].TagName, ASignalName) then Exit;
  Result := -1;
end;

procedure TRecorderSqlTrendView.Paint;
var
  I, J, lAxisIndex, lLineIndex, lPrevLine, lBoxHeight,
    lBoxTop, lBoxLeft, lIntervalLeft, lIntervalRight: Integer;
  lAxis: TRecorderTrendAxis;
  lLine: TRecorderTrendLine;
  lPlot: TRect;
  lX, lY: Integer;
  lPointX, lPointY, lPrevX, lPrevY, lClipX0, lClipY0,
    lClipX1, lClipY1: Double;
  lRange, lCursorUtc, lCursor2Utc, lDistance, lGridValue: Double;
  lGridIndex, lGridX, lGridY: Integer;
  lGridText: string;
  lHasPrev: Boolean;
  lCaption: string;
  lNearestDistance, lNearestValue: array of Double;
  lNearestFound: array of Boolean;
begin
  inherited Paint;
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(ClientRect);
  lPlot := GetPlotRect;
  Canvas.Pen.Color := clGray;
  Canvas.Rectangle(lPlot);
  if fComponent = nil then Exit;
  if fErrorText <> '' then
  begin
    Canvas.Font.Color := clRed;
    Canvas.TextOut(8, 8, fErrorText);
    Exit;
  end;
  if fWorker <> nil then
  begin
    Canvas.Font.Color := clGray;
    Canvas.TextOut(8, 8, 'Загрузка данных из SQL БД...');
  end;
  Canvas.Font.Color := clBlack;
  Canvas.TextOut(lPlot.Left, lPlot.Bottom + 4,
    FormatDateTime('dd.mm.yyyy hh:nn:ss', UtcDisplayTime(fFromUtc)));
  lCaption := FormatDateTime('dd.mm.yyyy hh:nn:ss',
    UtcDisplayTime(fToUtc));
  Canvas.TextOut(lPlot.Right - Canvas.TextWidth(lCaption), lPlot.Bottom + 4, lCaption);
  if Length(fAxisMin) > 0 then
  begin
    Canvas.Pen.Color := $00E0E0E0;
    Canvas.Font.Color := clGray;
    for lGridIndex := 0 to 10 do
    begin
      lGridY := lPlot.Bottom - Round(lGridIndex / 10.0 * lPlot.Height);
      Canvas.Line(lPlot.Left, lGridY, lPlot.Right, lGridY);
      lGridValue := fAxisMin[0] + lGridIndex / 10.0 *
        (fAxisMax[0] - fAxisMin[0]);
      lGridText := FloatToStrF(lGridValue, ffGeneral, 7, 3);
      Canvas.TextOut(Max(1, lPlot.Left - Canvas.TextWidth(lGridText) - 4),
        lGridY - Canvas.TextHeight(lGridText) div 2, lGridText);
    end;
    if fToUtc > fFromUtc then
      for lGridIndex := 1 to 9 do
      begin
        lGridX := lPlot.Left + Round(lGridIndex / 10.0 * lPlot.Width);
        Canvas.Line(lGridX, lPlot.Top, lGridX, lPlot.Bottom);
        lGridValue := fFromUtc + lGridIndex / 10.0 * (fToUtc - fFromUtc);
        if (fToUtc - fFromUtc) >= 1.0 then
          lGridText := FormatDateTime('dd.mm hh:nn',
            UtcDisplayTime(lGridValue))
        else
          lGridText := FormatDateTime('hh:nn:ss',
            UtcDisplayTime(lGridValue));
        Canvas.TextOut(lGridX - Canvas.TextWidth(lGridText) div 2,
          lPlot.Bottom + Canvas.TextHeight(lGridText) + 6, lGridText);
      end;
    Canvas.Pen.Color := clGray;
    Canvas.Rectangle(lPlot);
  end;
  for I := 0 to fComponent.ActiveDisplay.AxisCount - 1 do
  begin
    lAxis := fComponent.ActiveDisplay.Axes[I];
    Canvas.Font.Color := TColor(lAxis.Color);
    Canvas.TextOut(4, 18 + I * Canvas.TextHeight('Ag'), lAxis.Name + ' ['+
      FloatToStr(fAxisMin[I]) + '..' + FloatToStr(fAxisMax[I]) + ']');
  end;
  lPrevLine := -1;
  lPrevX := 0;
  lPrevY := 0;
  lHasPrev := False;
  for I := 0 to High(fPoints) do
  begin
    lLineIndex := LineIndex(fPoints[I].SignalName);
    if (lLineIndex < 0) or (not fComponent.ActiveDisplay.Lines[lLineIndex].Visible) then Continue;
    lLine := fComponent.ActiveDisplay.Lines[lLineIndex];
    lAxisIndex := EnsureRange(lLine.AxisIndex, 0, fComponent.ActiveDisplay.AxisCount - 1);
    lAxis := fComponent.ActiveDisplay.Axes[lAxisIndex];
    lRange := fAxisMax[lAxisIndex] - fAxisMin[lAxisIndex];
    if (lRange <= 0) or (fToUtc <= fFromUtc) then Continue;
    lPointX := lPlot.Left + (fPoints[I].TimestampUtc - fFromUtc) /
      (fToUtc - fFromUtc) * (lPlot.Width - 1);
    lPointY := lPlot.Bottom - (fPoints[I].Value - fAxisMin[lAxisIndex]) /
      lRange * (lPlot.Height - 1);
    Canvas.Pen.Color := TColor(lLine.Color);
    Canvas.Pen.Width := Max(1, lLine.Width);
    if lHasPrev and (lPrevLine = lLineIndex) then
    begin
      lClipX0 := lPrevX;
      lClipY0 := lPrevY;
      lClipX1 := lPointX;
      lClipY1 := lPointY;
      if ClipLineToRect(lClipX0, lClipY0, lClipX1, lClipY1, lPlot) then
        Canvas.Line(Round(lClipX0), Round(lClipY0),
          Round(lClipX1), Round(lClipY1));
    end;
    if (lPointX >= lPlot.Left) and (lPointX <= lPlot.Right) and
      (lPointY >= lPlot.Top) and (lPointY <= lPlot.Bottom) then
    begin
      lX := Round(lPointX);
      lY := Round(lPointY);
      Canvas.Brush.Color := TColor(lLine.Color);
      Canvas.Brush.Style := bsSolid;
      Canvas.Ellipse(lX - 2, lY - 2, lX + 3, lY + 3);
    end;
    lPrevX := lPointX;
    lPrevY := lPointY;
    lPrevLine := lLineIndex;
    lHasPrev := True;
  end;
  Canvas.Pen.Width := 1;
  if fCursorEnabled and fCursorVisible and (fToUtc > fFromUtc) then
  begin
    lCursorUtc := CursorUtc(fCursorPoint);
    SetLength(lNearestDistance, fComponent.ActiveDisplay.LineCount);
    SetLength(lNearestValue, fComponent.ActiveDisplay.LineCount);
    SetLength(lNearestFound, fComponent.ActiveDisplay.LineCount);
    for I := 0 to High(fPoints) do
    begin
      J := LineIndex(fPoints[I].SignalName);
      if (J < 0) or (not fComponent.ActiveDisplay.Lines[J].Visible) then Continue;
      lDistance := Abs(fPoints[I].TimestampUtc - lCursorUtc);
      if (not lNearestFound[J]) or (lDistance < lNearestDistance[J]) then
      begin
        lNearestFound[J] := True;
        lNearestDistance[J] := lDistance;
        lNearestValue[J] := fPoints[I].Value;
      end;
    end;
    Canvas.Pen.Color := clGray;
    Canvas.Pen.Style := psDot;
    Canvas.Line(fCursorPoint.X, lPlot.Top, fCursorPoint.X, lPlot.Bottom);
    if DoubleCursorReady then
    begin
      lCursor2Utc := CursorUtc(fCursor2Point);
      Canvas.Line(fCursor2Point.X, lPlot.Top, fCursor2Point.X, lPlot.Bottom);
      lIntervalLeft := Min(fCursorPoint.X, fCursor2Point.X);
      lIntervalRight := Max(fCursorPoint.X, fCursor2Point.X);
      Canvas.Pen.Color := clRed;
      Canvas.Pen.Style := psDash;
      Canvas.Line(lIntervalLeft, lPlot.Top + 5, lIntervalRight,
        lPlot.Top + 5);
      Canvas.Font.Color := clBlack;
      Canvas.Brush.Style := bsClear;
      lCaption := FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz',
        UtcDisplayTime(lCursor2Utc));
      Canvas.TextOut(EnsureRange(fCursor2Point.X + 8, lPlot.Left,
        Max(lPlot.Left, lPlot.Right - Canvas.TextWidth(lCaption) - 4)),
        lPlot.Top + 10, lCaption);
    end;
    Canvas.Pen.Style := psSolid;
    lBoxHeight := Canvas.TextHeight('Ag') + 8;
    for I := 0 to fComponent.ActiveDisplay.LineCount - 1 do
      if lNearestFound[I] then Inc(lBoxHeight, Canvas.TextHeight('Ag') + 3);
    lBoxLeft := EnsureRange(fCursorPoint.X + 8, lPlot.Left,
      Max(lPlot.Left, lPlot.Right - 230));
    lBoxTop := EnsureRange(fCursorPoint.Y + 8, lPlot.Top,
      Max(lPlot.Top, lPlot.Bottom - lBoxHeight));
    Canvas.Brush.Color := $00F5F5F5;
    Canvas.Brush.Style := bsSolid;
    Canvas.Pen.Color := clGray;
    Canvas.Rectangle(lBoxLeft, lBoxTop, lBoxLeft + 230, lBoxTop + lBoxHeight);
    Canvas.Font.Color := clBlack;
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(lBoxLeft + 5, lBoxTop + 4,
      FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz',
        UtcDisplayTime(lCursorUtc)));
    J := lBoxTop + Canvas.TextHeight('Ag') + 7;
    for I := 0 to fComponent.ActiveDisplay.LineCount - 1 do
      if lNearestFound[I] then
      begin
        Canvas.Brush.Color := TColor(fComponent.ActiveDisplay.Lines[I].Color);
        Canvas.Brush.Style := bsSolid;
        Canvas.FillRect(Rect(lBoxLeft + 5, J + 3, lBoxLeft + 17, J + 11));
        Canvas.Brush.Style := bsClear;
        Canvas.Font.Color := clBlack;
        lCaption := fComponent.ActiveDisplay.Lines[I].TagName;
        if lCaption = '' then lCaption := fComponent.ActiveDisplay.Lines[I].Name;
        Canvas.TextOut(lBoxLeft + 22, J, IntToStr(I + 1) + '. ' + lCaption + ': ' +
          FormatFloat('0.######', lNearestValue[I]));
        Inc(J, Canvas.TextHeight('Ag') + 3);
      end;
  end;
  if fZoomSelecting then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clBlue;
    Canvas.Pen.Style := psDash;
    case fZoomMode of
      stzmX:
        Canvas.Rectangle(Min(fMouseAnchor.X, fMouseCurrent.X), lPlot.Top,
          Max(fMouseAnchor.X, fMouseCurrent.X), lPlot.Bottom);
      stzmY:
        Canvas.Rectangle(lPlot.Left, Min(fMouseAnchor.Y, fMouseCurrent.Y),
          lPlot.Right, Max(fMouseAnchor.Y, fMouseCurrent.Y));
      stzmXY:
        Canvas.Rectangle(Min(fMouseAnchor.X, fMouseCurrent.X),
          Min(fMouseAnchor.Y, fMouseCurrent.Y),
          Max(fMouseAnchor.X, fMouseCurrent.X),
          Max(fMouseAnchor.Y, fMouseCurrent.Y));
    end;
    Canvas.Pen.Style := psSolid;
    Canvas.Brush.Style := bsSolid;
  end;
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(TRecorderSqlTrendComponent,
    TRecorderSqlTrendView);

end.
