unit uRecorderSqlTrendView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, Graphics, Math, DateUtils,
  uOglChart, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uRecorderSqlDbTypes, uRecorderSqlTrendModel;

type
  TRecorderSqlTrendView = class;

  TRecorderSqlTrendLoadThread = class(TThread)
  private
    fConfigFileName: string;
    fErrorText: string;
    fFromUtc, fToUtc: Double;
    fMaxPoints: Integer;
    fOwner: TRecorderSqlTrendView;
    fPoints: TRecorderSqlTrendPoints;
    fSignalNames: TStringList;
    procedure Deliver;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderSqlTrendView; const AConfigFileName: string;
      ASignalNames: TStrings; AFromUtc, AToUtc: Double; AMaxPoints: Integer);
    destructor Destroy; override;
  end;

  TRecorderSqlTrendView = class(TPanel, IVForm)
  private
    fApplyAxisButton: TButton;
    fAxisCombo: TComboBox;
    fAxisMaxEdit: TEdit;
    fAxisMinEdit: TEdit;
    fAxisPanel: TPanel;
    fAxisMax: array of Double;
    fAxisMin: array of Double;
    fComponent: TRecorderSqlTrendComponent;
    fErrorText: string;
    fFullAxisMax: array of Double;
    fFullAxisMin: array of Double;
    fFullFromUtc, fFullToUtc: Double;
    fFromUtc, fToUtc: Double;
    fLoadPending: Boolean;
    fMouseAnchor: TPoint;
    fMouseCurrent: TPoint;
    fPanAxisMax: array of Double;
    fPanAxisMin: array of Double;
    fPanFromUtc, fPanToUtc: Double;
    fPanning: Boolean;
    fPoints: TRecorderSqlTrendPoints;
    fReloadTimer: TTimer;
    fResetZoomButton: TButton;
    fWorker: TRecorderSqlTrendLoadThread;
    fZoomSelecting: Boolean;
    procedure ApplyAxisClick(Sender: TObject);
    procedure AxisComboChange(Sender: TObject);
    function GetPlotRect: TRect;
    procedure LoadAxisControls;
    procedure ResetZoomClick(Sender: TObject);
    procedure ReloadTimerTimer(Sender: TObject);
    procedure StartLoad;
    procedure AcceptLoad(AWorker: TRecorderSqlTrendLoadThread);
    function LineIndex(const ASignalName: string): Integer;
  protected
    procedure Paint; override;
    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
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

constructor TRecorderSqlTrendLoadThread.Create(AOwner: TRecorderSqlTrendView;
  const AConfigFileName: string; ASignalNames: TStrings; AFromUtc,
  AToUtc: Double; AMaxPoints: Integer);
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
          fMaxPoints, fPoints);
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
  fAxisPanel := TPanel.Create(Self);
  fAxisPanel.Parent := Self;
  fAxisPanel.Align := alBottom;
  fAxisPanel.Height := 32;
  fAxisPanel.BevelOuter := bvLowered;
  lLabel := TLabel.Create(fAxisPanel);
  lLabel.Parent := fAxisPanel;
  lLabel.Left := 6;
  lLabel.Top := 8;
  lLabel.Caption := 'Ось Y:';
  fAxisCombo := TComboBox.Create(fAxisPanel);
  fAxisCombo.Parent := fAxisPanel;
  fAxisCombo.SetBounds(52, 4, 100, 24);
  fAxisCombo.Style := csDropDownList;
  fAxisCombo.OnChange := @AxisComboChange;
  lLabel := TLabel.Create(fAxisPanel);
  lLabel.Parent := fAxisPanel;
  lLabel.Left := 162;
  lLabel.Top := 8;
  lLabel.Caption := 'Мин:';
  fAxisMinEdit := TEdit.Create(fAxisPanel);
  fAxisMinEdit.Parent := fAxisPanel;
  fAxisMinEdit.SetBounds(196, 4, 76, 24);
  lLabel := TLabel.Create(fAxisPanel);
  lLabel.Parent := fAxisPanel;
  lLabel.Left := 280;
  lLabel.Top := 8;
  lLabel.Caption := 'Макс:';
  fAxisMaxEdit := TEdit.Create(fAxisPanel);
  fAxisMaxEdit.Parent := fAxisPanel;
  fAxisMaxEdit.SetBounds(320, 4, 76, 24);
  fApplyAxisButton := TButton.Create(fAxisPanel);
  fApplyAxisButton.Parent := fAxisPanel;
  fApplyAxisButton.SetBounds(404, 3, 84, 26);
  fApplyAxisButton.Caption := 'Применить';
  fApplyAxisButton.OnClick := @ApplyAxisClick;
  fResetZoomButton := TButton.Create(fAxisPanel);
  fResetZoomButton.Parent := fAxisPanel;
  fResetZoomButton.SetBounds(496, 3, 104, 26);
  fResetZoomButton.Caption := 'Весь график';
  fResetZoomButton.OnClick := @ResetZoomClick;
  fReloadTimer := TTimer.Create(Self);
  fReloadTimer.Enabled := False;
  fReloadTimer.Interval := 50;
  fReloadTimer.OnTimer := @ReloadTimerTimer;
end;

destructor TRecorderSqlTrendView.Destroy;
begin
  fReloadTimer.Enabled := False;
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
var I: Integer;
begin
  if not (AComponent is TRecorderSqlTrendComponent) then Exit;
  fComponent := TRecorderSqlTrendComponent(AComponent);
  fAxisCombo.Items.BeginUpdate;
  try
    fAxisCombo.Items.Clear;
    SetLength(fAxisMin, fComponent.AxisCount);
    SetLength(fAxisMax, fComponent.AxisCount);
    SetLength(fFullAxisMin, fComponent.AxisCount);
    SetLength(fFullAxisMax, fComponent.AxisCount);
    for I := 0 to fComponent.AxisCount - 1 do
    begin
      fAxisCombo.Items.Add(fComponent.Axes[I].Name);
      fAxisMin[I] := fComponent.Axes[I].RangeMin;
      fAxisMax[I] := fComponent.Axes[I].RangeMax;
      fFullAxisMin[I] := fAxisMin[I];
      fFullAxisMax[I] := fAxisMax[I];
    end;
  finally
    fAxisCombo.Items.EndUpdate;
  end;
  if fAxisCombo.Items.Count > 0 then fAxisCombo.ItemIndex := 0;
  LoadAxisControls;
  fLoadPending := True;
  fReloadTimer.Enabled := True;
  Invalidate;
end;

function TRecorderSqlTrendView.GetPlotRect: TRect;
begin
  Result := Rect(64, 18, Max(65, ClientWidth - 12),
    Max(19, ClientHeight - fAxisPanel.Height - 42));
end;

procedure TRecorderSqlTrendView.LoadAxisControls;
var I: Integer;
begin
  I := fAxisCombo.ItemIndex;
  if (I < 0) or (I >= Length(fAxisMin)) then Exit;
  fAxisMinEdit.Text := FloatToStr(fAxisMin[I]);
  fAxisMaxEdit.Text := FloatToStr(fAxisMax[I]);
end;

procedure TRecorderSqlTrendView.AxisComboChange(Sender: TObject);
begin
  LoadAxisControls;
end;

procedure TRecorderSqlTrendView.ApplyAxisClick(Sender: TObject);
var I: Integer; lMin, lMax: Double;
begin
  I := fAxisCombo.ItemIndex;
  if (fComponent = nil) or (I < 0) or (I >= fComponent.AxisCount) then Exit;
  if not TryStrToFloat(Trim(fAxisMinEdit.Text), lMin) then Exit;
  if not TryStrToFloat(Trim(fAxisMaxEdit.Text), lMax) or (lMax <= lMin) then Exit;
  fAxisMin[I] := lMin;
  fAxisMax[I] := lMax;
  fFullAxisMin[I] := lMin;
  fFullAxisMax[I] := lMax;
  fComponent.Axes[I].RangeMin := lMin;
  fComponent.Axes[I].RangeMax := lMax;
  Invalidate;
end;

procedure TRecorderSqlTrendView.ResetZoomClick(Sender: TObject);
var I: Integer;
begin
  fFromUtc := fFullFromUtc;
  fToUtc := fFullToUtc;
  for I := 0 to High(fAxisMin) do
  begin
    fAxisMin[I] := fFullAxisMin[I];
    fAxisMax[I] := fFullAxisMax[I];
  end;
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
  { Исторический тренд не зависит от runtime-тегов Recorder. }
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

procedure TRecorderSqlTrendView.StartLoad;
var
  I: Integer;
  lSignals: TStringList;
  lFromUtc, lToUtc: Double;
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
    for I := 0 to fComponent.LineCount - 1 do
      if fComponent.Lines[I].Visible and
        (Trim(fComponent.Lines[I].TagName) <> '') then
        lSignals.Add(fComponent.Lines[I].TagName);
    if fComponent.TimeMode = sttmLatestWindow then
    begin
      lToUtc := LocalTimeToUniversal(Now);
      lFromUtc := lToUtc - Max(1.0, fComponent.DurationSec) / SecsPerDay;
    end
    else
    begin
      lFromUtc := fComponent.FromUtc;
      lToUtc := fComponent.ToUtc;
    end;
    fFromUtc := lFromUtc;
    fToUtc := lToUtc;
    fWorker := TRecorderSqlTrendLoadThread.Create(Self,
      fComponent.ConfigFileName, lSignals, lFromUtc, lToUtc,
      fComponent.MaxPointsPerLine);
    fWorker.Start;
  finally
    lSignals.Free;
  end;
end;

procedure TRecorderSqlTrendView.AcceptLoad(AWorker: TRecorderSqlTrendLoadThread);
begin
  if AWorker <> fWorker then Exit;
  fPoints := Copy(AWorker.fPoints, 0, Length(AWorker.fPoints));
  fErrorText := AWorker.fErrorText;
  AWorker.fOwner := nil;
  AWorker.FreeOnTerminate := True;
  fWorker := nil;
  Invalidate;
end;

function TRecorderSqlTrendView.LineIndex(const ASignalName: string): Integer;
begin
  Result := -1;
  if fComponent = nil then Exit;
  for Result := 0 to fComponent.LineCount - 1 do
    if SameText(fComponent.Lines[Result].TagName, ASignalName) then Exit;
  Result := -1;
end;

procedure TRecorderSqlTrendView.Paint;
var
  I, lAxisIndex, lLineIndex, lPrevLine: Integer;
  lAxis: TRecorderTrendAxis;
  lLine: TRecorderTrendLine;
  lPlot: TRect;
  lX, lY, lPrevX, lPrevY: Integer;
  lRange: Double;
  lHasPrev: Boolean;
  lCaption: string;
begin
  inherited Paint;
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(ClientRect);
  lPlot := Rect(64, 18, Max(65, ClientWidth - 12), Max(19, ClientHeight - 42));
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
  Canvas.TextOut(lPlot.Left, lPlot.Bottom + 4, FormatDateTime('dd.mm.yyyy hh:nn:ss', fFromUtc));
  lCaption := FormatDateTime('dd.mm.yyyy hh:nn:ss', fToUtc);
  Canvas.TextOut(lPlot.Right - Canvas.TextWidth(lCaption), lPlot.Bottom + 4, lCaption);
  for I := 0 to fComponent.AxisCount - 1 do
  begin
    lAxis := fComponent.Axes[I];
    Canvas.Font.Color := TColor(lAxis.Color);
    Canvas.TextOut(4, 18 + I * Canvas.TextHeight('Ag'), lAxis.Name + ' ['+
      FloatToStr(lAxis.RangeMin) + '..' + FloatToStr(lAxis.RangeMax) + ']');
  end;
  lPrevLine := -1;
  lPrevX := 0;
  lPrevY := 0;
  lHasPrev := False;
  for I := 0 to High(fPoints) do
  begin
    lLineIndex := LineIndex(fPoints[I].SignalName);
    if (lLineIndex < 0) or (not fComponent.Lines[lLineIndex].Visible) then Continue;
    lLine := fComponent.Lines[lLineIndex];
    lAxisIndex := EnsureRange(lLine.AxisIndex, 0, fComponent.AxisCount - 1);
    lAxis := fComponent.Axes[lAxisIndex];
    lRange := lAxis.RangeMax - lAxis.RangeMin;
    if (lRange <= 0) or (fToUtc <= fFromUtc) then Continue;
    lX := lPlot.Left + Round((fPoints[I].TimestampUtc - fFromUtc) /
      (fToUtc - fFromUtc) * (lPlot.Width - 1));
    lY := lPlot.Bottom - Round((fPoints[I].Value - lAxis.RangeMin) /
      lRange * (lPlot.Height - 1));
    lY := EnsureRange(lY, lPlot.Top, lPlot.Bottom);
    Canvas.Pen.Color := TColor(lLine.Color);
    Canvas.Pen.Width := Max(1, lLine.Width);
    if lHasPrev and (lPrevLine = lLineIndex) then
      Canvas.Line(lPrevX, lPrevY, lX, lY);
    Canvas.Brush.Color := TColor(lLine.Color);
    Canvas.Ellipse(lX - 2, lY - 2, lX + 3, lY + 3);
    lPrevX := lX; lPrevY := lY; lPrevLine := lLineIndex; lHasPrev := True;
  end;
  Canvas.Pen.Width := 1;
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(TRecorderSqlTrendComponent,
    TRecorderSqlTrendView);

end.
