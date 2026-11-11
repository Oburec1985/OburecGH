unit uRecorderSqlTrendView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Buttons, Grids, Graphics,
  Menus,
  Math, DateUtils, Dialogs,
  uOglChart, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uRecorderSqlDbTypes, uRecorderSqlTrendModel;

type
  TRecorderSqlTrendView = class;
  TRecorderSqlTrendZoomMode = (stzmNone, stzmX, stzmY, stzmXY);

  TRecorderSqlTrendLineSegment = record
    LineIndex: Integer;
    StartPoint: TPoint;
    EndPoint: TPoint;
  end;

  TRecorderSqlTrendLineMarker = record
    LineIndex: Integer;
    Point: TPoint;
  end;

  TRecorderSqlTrendLoadThread = class(TThread)
  private
    fConfigFileName: string;
    fErrorText: string;
    fFromUtc, fToUtc: Double;
    fMaxPoints: Integer;
    fAppendLoad: Boolean;
    fFallbackToAvailableData: Boolean;
    fIncludeRecordingEvents: Boolean;
    fIncludeTagAlarmEvents: Boolean;
    fIncludeTagRangeEvents: Boolean;
    fOwner: TRecorderSqlTrendView;
    fPoints: TRecorderSqlTrendPoints;
    fEvents: TRecorderSqlDbMeraEvents;
    fSignalNames: TStringList;
    fWakeEvent: PRTLEvent;
    fRequestLock: TRTLCriticalSection;
    fRequestPending: Boolean;
    fBusy: Boolean;
    fDatabaseMaxUtc: Double;
    fHasDatabaseRange: Boolean;
    procedure Deliver;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderSqlTrendView);
    destructor Destroy; override;
    function RequestLoad(const AConfigFileName: string; ASignalNames: TStrings;
      AFromUtc, AToUtc: Double; AMaxPoints: Integer;
      AAppendLoad, AFallbackToAvailableData, AIncludeRecordingEvents,
      AIncludeTagAlarmEvents,
      AIncludeTagRangeEvents: Boolean): Boolean;
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
    fExportButton: TButton;
    fOpenMeraEventButton: TButton;
    fDisplayCombo: TComboBox;
    fDisplayLabel: TLabel;
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
    fEventPopup: TPopupMenu;
    fRecordingEventsMenuItem: TMenuItem;
    fTagAlarmEventsMenuItem: TMenuItem;
    fTagRangeEventsMenuItem: TMenuItem;
    fUnresolvedEventsMenuItem: TMenuItem;
    fAllEventsMenuItem: TMenuItem;
    fForceFullReload: Boolean;
    fFullAxisMax: array of Double;
    fFullAxisMin: array of Double;
    fFullFromUtc, fFullToUtc: Double;
    fFromUtc, fToUtc: Double;
    fAutoZoomYOnLoad: Boolean;
    fLoadPending: Boolean;
    fLegendColors: array of TColor;
    fLegendGrid: TStringGrid;
    fLegendPanel: TPanel;
    fLegendSplitter: TSplitter;
    fLineGeometryDirty: Boolean;
    fLineMarkers: array of TRecorderSqlTrendLineMarker;
    fLineSegments: array of TRecorderSqlTrendLineSegment;
    fMouseAnchor: TPoint;
    fMouseCurrent: TPoint;
    fMouseRepaintPending: Boolean;
    fMouseRepaintTimer: TTimer;
    fLastInteractiveReloadAt: QWord;
    fManualXRange: Boolean;
    fFollowCurrentDateRightEdge: Boolean;
    fZoomMode: TRecorderSqlTrendZoomMode;
    fPanAxisMax: array of Double;
    fPanAxisMin: array of Double;
    fPanFromUtc, fPanToUtc: Double;
    fPanning: Boolean;
    fPoints: TRecorderSqlTrendPoints;
    fEvents: TRecorderSqlDbMeraEvents;
    fHoveredEventIndex: Integer;
    fPinnedEventIndex: Integer;
    fPinnedEventId: string;
    fReloadTimer: TTimer;
    fLiveReloadTimer: TTimer;
    fResetViewOnLoad: Boolean;
    fResetZoomButton: TButton;
    fSaveAxesButton: TButton;
    fWorker: TRecorderSqlTrendLoadThread;
    fLoadSignalNames: TStringList;
    fMergeCombined: TRecorderSqlTrendPoints;
    fMergeOutput: TRecorderSqlTrendPoints;
    fMergeRowIds: TStringList;
    fZoomSelecting: Boolean;
    fDatabaseMaxUtc: Double;
    fDataAxisHasValue: array of Boolean;
    fDataAxisMax: array of Double;
    fDataAxisMin: array of Double;
    procedure AxisRangeEditChange({%H-}Sender: TObject);
    procedure AxisComboChange({%H-}Sender: TObject);
    procedure CursorButtonClick({%H-}Sender: TObject);
    procedure CursorModeChange({%H-}Sender: TObject);
    procedure DeleteIntervalButtonClick({%H-}Sender: TObject);
    procedure ExportButtonClick({%H-}Sender: TObject);
    procedure EventFilterClick(Sender: TObject);
    procedure UpdateEventFilterMenu;
    procedure RequestEventReload;
    procedure PinEvent(AIndex: Integer);
    function IndexOfEventId(const AEventId: string): Integer;
    procedure OpenMeraEventButtonClick({%H-}Sender: TObject);
    procedure DisplayComboChange({%H-}Sender: TObject);
    procedure DisplayNextClick({%H-}Sender: TObject);
    procedure DisplayPrevClick({%H-}Sender: TObject);
    procedure FillDisplayControls;
    function BuildAxisSignature: string;
    function AxisCaption(AIndex: Integer): string;
    procedure GetAxisHeaderLayout(ARight: Integer; out AColumnWidth,
      AColumnCount, ARowCount: Integer);
    function CursorUtc(APoint: TPoint): Double;
    function UtcDisplayTime(AUtc: TDateTime): TDateTime;
    function DoubleCursorMode: Boolean;
    function DoubleCursorReady: Boolean;
    procedure EnsureCursorDefaults;
    function GetPlotRect: TRect;
    procedure LegendGridDrawCell({%H-}Sender: TObject; ACol, ARow: Integer;
      ARect: TRect; AState: TGridDrawState);
    procedure LegendGridSelectCell({%H-}Sender: TObject; {%H-}ACol,
      ARow: Integer; var {%H-}CanSelect: Boolean);
    procedure LegendGridDblClick({%H-}Sender: TObject);
    function LegendLineIndex(ARow: Integer): Integer;
    procedure LoadAxisControls;
    procedure LayoutAxisControls;
    procedure MarkLineGeometryDirty;
    procedure RebuildLineGeometry(const APlot: TRect);
    procedure UpdateDataAxisBounds;
    procedure RequestMouseRepaint;
    procedure MouseRepaintTimerTimer({%H-}Sender: TObject);
    procedure ClampAntiZoomXRange;
    procedure ClampAntiZoomYRange;
    procedure AutoZoomYAxis;
    procedure RestoreConfiguredAxisRanges;
    procedure SaveAxesClick({%H-}Sender: TObject);
    procedure ResetZoomClick({%H-}Sender: TObject);
    procedure ReloadTimerTimer({%H-}Sender: TObject);
    procedure LiveReloadTimerTimer({%H-}Sender: TObject);
    procedure ConfigureLiveReload;
    procedure StartLoad;
    procedure ClampCurrentDateXRange;
    function CurrentDateRightEdgeVisible: Boolean;
    procedure RequestInteractiveLiveReload;
    procedure ApplyHorizontalZoom(ALeft, ARight: Integer; AZoomIn: Boolean;
      const APlot: TRect);
    procedure ApplyVerticalZoom(ATop, ABottom: Integer; AZoomIn: Boolean;
      const APlot: TRect);
    procedure MergeLivePoints(const ANewPoints: TRecorderSqlTrendPoints);
    procedure MergeLiveEvents(const ANewEvents: TRecorderSqlDbMeraEvents;
      AFromUtc: Double);
    function SyncAxisRangesFromComponent(AForce: Boolean): Boolean;
    procedure UpdateDeleteIntervalButton;
    procedure UpdateLegend;
    procedure AcceptLoad(AWorker: TRecorderSqlTrendLoadThread);
    function LoadMatchesActiveDisplay(
      AWorker: TRecorderSqlTrendLoadThread): Boolean;
    function LineIndex(const ASignalName: string): Integer;
    function EventIndexAtX(AX: Integer; const APlot: TRect): Integer;
    function IsRecordingEvent(AIndex: Integer): Boolean;
    function MatchesTagSignalFilter(
      const AEvent: TRecorderSqlDbMeraEvent): Boolean;
    function EventMatchesTagFilter(AIndex: Integer): Boolean;
    function EventVisible(AIndex: Integer): Boolean;
    function IsUnresolvedEvent(AIndex: Integer): Boolean;
    function EventCaption(AIndex: Integer): string;
    procedure UpdateMeraEventButton;
  protected
    procedure Paint; override;
    procedure Resize; override;
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
      {%H-}ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl({%H-}ATagRegistry: TRecorderTagRegistry;
      {%H-}ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

implementation

uses
  uRecorderSqlDbRepository, uRecorderSqlDbRuntime,
  uRecorderMeraEventDialog, uRecorderSqlTrendExportDialog,
  uSharedFileLogger;

function SqlTrendConnectionIdentity(const AConfigFileName: string;
  AConfig: TRecorderSqlDbConfig): string;
var
  lHost: string;
begin
  lHost := Trim(AConfig.Host);
  if lHost = '' then lHost := 'local';
  if AConfig.Port <> 0 then lHost := lHost + ':' + IntToStr(AConfig.Port);
  Result := Format('config=%s; backend=%s; server=%s; database=%s',
    [ExpandFileName(AConfigFileName),
     RecorderSqlDbBackendToString(AConfig.Backend), lHost,
     AConfig.DatabaseFileName]);
end;

const
  CSqlTrendCursorGrabPixels = 6;
  { Короткая подпись под иконкой у маркера события. Только ASCII, чтобы
    подпись не зависела от кодировки исходника. }
  CUnresolvedEventCaption = 'WinPOS: izmerenie ne naideno';
  CEventIconSize = 14;

{ Неразрешимое событие записи: в SQL нет файлов пакета, WinПОС открыть нечего. }
function UnresolvedEventStatusText: string;
begin
  Result := UTF8Encode(UnicodeString(
    'Данные записи не найдены в WinПОС: в базе нет файлов пакета.'));
end;

{ Иконка «нет данных»: жёлтый квадрат с крестом — маркер события, для
  которого WinПОС не сможет открыть замер. Рисуется без глифов и ресурсов,
  чтобы одинаково выглядеть на Windows и Linux. }
procedure PaintNoDataBadge(ACanvas: TCanvas; ALeft, ATop: Integer);
var
  lRect: TRect;
begin
  lRect := Rect(ALeft, ATop, ALeft + CEventIconSize, ATop + CEventIconSize);
  ACanvas.Brush.Color := clYellow;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Pen.Color := clMaroon;
  ACanvas.Pen.Width := 1;
  ACanvas.Rectangle(lRect);
  ACanvas.Line(lRect.Left + 3, lRect.Top + 3, lRect.Right - 3,
    lRect.Bottom - 3);
  ACanvas.Line(lRect.Right - 3, lRect.Top + 3, lRect.Left + 3,
    lRect.Bottom - 3);
  ACanvas.Brush.Style := bsClear;
end;

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

constructor TRecorderSqlTrendLoadThread.Create(AOwner: TRecorderSqlTrendView);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fSignalNames := TStringList.Create;
  InitCriticalSection(fRequestLock);
  fWakeEvent := RTLEventCreate;
end;

destructor TRecorderSqlTrendLoadThread.Destroy;
begin
  RTLEventDestroy(fWakeEvent);
  DoneCriticalSection(fRequestLock);
  fSignalNames.Free;
  inherited Destroy;
end;

function TRecorderSqlTrendLoadThread.RequestLoad(
  const AConfigFileName: string; ASignalNames: TStrings; AFromUtc,
  AToUtc: Double; AMaxPoints: Integer; AAppendLoad,
  AFallbackToAvailableData, AIncludeRecordingEvents, AIncludeTagAlarmEvents,
  AIncludeTagRangeEvents: Boolean): Boolean;
begin
  Result := False;
  EnterCriticalSection(fRequestLock);
  try
    if fBusy or fRequestPending or Terminated then Exit;
    fConfigFileName := AConfigFileName;
    fSignalNames.Assign(ASignalNames);
    fFromUtc := AFromUtc;
    fToUtc := AToUtc;
    fMaxPoints := AMaxPoints;
    fAppendLoad := AAppendLoad;
    fFallbackToAvailableData := AFallbackToAvailableData;
    fIncludeRecordingEvents := AIncludeRecordingEvents;
    fIncludeTagAlarmEvents := AIncludeTagAlarmEvents;
    fIncludeTagRangeEvents := AIncludeTagRangeEvents;
    fRequestPending := True;
    Result := True;
  finally
    LeaveCriticalSection(fRequestLock);
  end;
  RTLEventSetEvent(fWakeEvent);
end;

procedure TRecorderSqlTrendLoadThread.Execute;
var
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
  lLoadedConfigFileName: string;
  lCredentialsError: string;
  lConnectionError: string;
  lFallbackFromUtc, lFallbackToUtc: Double;
  lFallbackPointCount: Int64;
  lPointIndex: Integer;
  lLoadedConfigAge, lConfigAge: LongInt;
begin
  lConfig := nil;
  lRepository := nil;
  lLoadedConfigFileName := '';
  lLoadedConfigAge := 0;
  try
    while not Terminated do
    begin
      RTLEventWaitFor(fWakeEvent);
      RTLEventResetEvent(fWakeEvent);
      if Terminated then Break;
      EnterCriticalSection(fRequestLock);
      try
        if not fRequestPending then Continue;
        fRequestPending := False;
        fBusy := True;
      finally
        LeaveCriticalSection(fRequestLock);
      end;
      fErrorText := '';
      fHasDatabaseRange := False;
      SetLength(fPoints, 0);
      try
        lConfigAge := FileAge(fConfigFileName);
        if (lRepository = nil) or
          (not SameFileName(lLoadedConfigFileName, fConfigFileName)) or
          (lLoadedConfigAge <> lConfigAge) then
        begin
          FreeAndNil(lRepository);
          FreeAndNil(lConfig);
          lConfig := TRecorderSqlDbConfig.Create;
          lConfig.LoadFromFile(fConfigFileName);
          if lConfig.ConnectionConfigurationReady(lCredentialsError) then
          begin
            lLoadedConfigFileName := fConfigFileName;
            lLoadedConfigAge := lConfigAge;
          end
          else
            fErrorText := lCredentialsError;
        end;
        if (lConfig <> nil) and (fErrorText = '') then
        begin
          if RecorderSqlServerAvailable(lConfig, lConnectionError) then
          begin
            if lRepository = nil then
              lRepository := TRecorderSqlDbRepository.Create(lConfig);
            if (not fAppendLoad) and
              lRepository.GetTrendTimeRange(lFallbackFromUtc,
                lFallbackToUtc, lFallbackPointCount) and
              (lFallbackPointCount > 0) then
            begin
              fHasDatabaseRange := True;
              fDatabaseMaxUtc := lFallbackToUtc;
            end;
            lRepository.ReadTrendPoints(fSignalNames, fFromUtc, fToUtc,
              fMaxPoints, fPoints, False);
            if fFallbackToAvailableData and (Length(fPoints) = 0) and
              fHasDatabaseRange then
            begin
              { A selected display may have no points in a moving "latest"
                window.  For an explicit display switch, fall back once to the
                database domain; the view later narrows X to the actual points
                of the selected visible lines. }
              fFromUtc := lFallbackFromUtc;
              fToUtc := lFallbackToUtc;
              lRepository.ReadTrendPoints(fSignalNames, fFromUtc, fToUtc,
                fMaxPoints, fPoints, False);
              if Length(fPoints) > 0 then
              begin
                { Events follow the actual selected-line domain, not the
                  global database domain.  Otherwise one fallback request can
                  load years of event rows and make mouse hit-testing stall. }
                fFromUtc := fPoints[0].TimestampUtc;
                fToUtc := fFromUtc;
                for lPointIndex := 1 to High(fPoints) do
                begin
                  fFromUtc := Min(fFromUtc,
                    fPoints[lPointIndex].TimestampUtc);
                  fToUtc := Max(fToUtc,
                    fPoints[lPointIndex].TimestampUtc);
                end;
              end;
            end;
            lRepository.ListTimelineEvents(fFromUtc, fToUtc,
              fIncludeRecordingEvents, fIncludeTagAlarmEvents,
              fIncludeTagRangeEvents, fEvents);
          end
          else
          begin
            fErrorText := 'Сервер SQL выключен или недоступен';
            SharedLogger.Error('SQL trend server unavailable: ' +
              lConnectionError + ' [' +
              SqlTrendConnectionIdentity(fConfigFileName, lConfig) + ']');
            FreeAndNil(lRepository);
          end;
        end;
      except
        on E: Exception do
        begin
          if lConfig <> nil then
            fErrorText := E.Message + ' [' +
              SqlTrendConnectionIdentity(fConfigFileName, lConfig) + ']'
          else
            fErrorText := E.Message + ' [config=' +
              ExpandFileName(fConfigFileName) + ']';
          SharedLogger.Error('SQL trend load error: ' + fErrorText);
          { A broken connection must be recreated on the retry, while a
            healthy live session keeps its repository and SQL connection. }
          FreeAndNil(lRepository);
          FreeAndNil(lConfig);
          lLoadedConfigFileName := '';
          lLoadedConfigAge := 0;
        end;
      end;
      { Keep the request/result slot busy until the UI has consumed this
        exact snapshot.  Releasing it before Synchronize allowed the live
        timer to overwrite fFromUtc/fToUtc/fAppendLoad/fSignalNames while
        fPoints still belonged to the previous request. }
      if not Terminated then Synchronize(@Deliver);
      EnterCriticalSection(fRequestLock);
      try
        fBusy := False;
      finally
        LeaveCriticalSection(fRequestLock);
      end;
    end;
  finally
    lRepository.Free;
    lConfig.Free;
  end;
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
  fLegendGrid.Cursor := crDefault;
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
  fLoadSignalNames := TStringList.Create;
  fMergeRowIds := TStringList.Create;
  fMergeRowIds.Sorted := True;
  fMergeRowIds.Duplicates := dupIgnore;
  fWorker := TRecorderSqlTrendLoadThread.Create(Self);
  fWorker.Start;
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
  fSaveAxesButton := TButton.Create(fAxisPanel);
  fSaveAxesButton.Parent := fAxisPanel;
  fSaveAxesButton.SetBounds(322, 3, 112, 26);
  fSaveAxesButton.Caption := 'Сохранить оси';
  fSaveAxesButton.Hint :=
    'Запомнить текущий масштаб осей для активного отображения';
  fSaveAxesButton.ShowHint := True;
  fSaveAxesButton.OnClick := @SaveAxesClick;
  fResetZoomButton := TButton.Create(fAxisPanel);
  fResetZoomButton.Parent := fAxisPanel;
  fResetZoomButton.SetBounds(440, 3, 100, 26);
  fResetZoomButton.Caption := 'Весь график';
  fResetZoomButton.OnClick := @ResetZoomClick;
  fCursorButton := TSpeedButton.Create(fAxisPanel);
  fCursorButton.Parent := fAxisPanel;
  fCursorButton.SetBounds(546, 3, 112, 26);
  fCursorButton.Caption := 'Показать курсор';
  fCursorButton.AllowAllUp := True;
  fCursorButton.GroupIndex := 91;
  fCursorButton.Down := False;
  fCursorButton.OnClick := @CursorButtonClick;
  fCursorModeCombo := TComboBox.Create(fAxisPanel);
  fCursorModeCombo.Parent := fAxisPanel;
  fCursorModeCombo.SetBounds(664, 3, 92, 26);
  fCursorModeCombo.Style := csDropDownList;
  fCursorModeCombo.Items.Add('Один');
  fCursorModeCombo.Items.Add('Два');
  fCursorModeCombo.ItemIndex := 0;
  fCursorModeCombo.OnChange := @CursorModeChange;
  fDeleteIntervalButton := TButton.Create(fAxisPanel);
  fDeleteIntervalButton.Parent := fAxisPanel;
  fDeleteIntervalButton.SetBounds(762, 3, 138, 26);
  fDeleteIntervalButton.Caption := 'Удалить интервал';
  fDeleteIntervalButton.Enabled := False;
  fDeleteIntervalButton.OnClick := @DeleteIntervalButtonClick;
  fOpenMeraEventButton := TButton.Create(fAxisPanel);
  fOpenMeraEventButton.Parent := fAxisPanel;
  fOpenMeraEventButton.SetBounds(906, 3, 154, 26);
  fOpenMeraEventButton.Caption := 'Открыть в WinПОС';
  fOpenMeraEventButton.Enabled := False;
  fOpenMeraEventButton.OnClick := @OpenMeraEventButtonClick;
  fDisplayLabel := TLabel.Create(fAxisPanel);
  fDisplayLabel.Parent := fAxisPanel;
  fDisplayLabel.SetBounds(6, 39, 92, 18);
  fDisplayLabel.Caption := 'Отображение:';
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
  fExportButton := TButton.Create(fAxisPanel);
  fExportButton.Parent := fAxisPanel;
  fExportButton.SetBounds(424, 34, 110, 24);
  fExportButton.Caption := 'Экспорт';
  fExportButton.OnClick := @ExportButtonClick;
  LayoutAxisControls;
  fReloadTimer := TTimer.Create(Self);
  fReloadTimer.Enabled := False;
  fReloadTimer.Interval := 50;
  fReloadTimer.OnTimer := @ReloadTimerTimer;
  fLiveReloadTimer := TTimer.Create(Self);
  fLiveReloadTimer.Enabled := False;
  fLiveReloadTimer.Interval := 1000;
  fLiveReloadTimer.OnTimer := @LiveReloadTimerTimer;
  fMouseRepaintTimer := TTimer.Create(Self);
  fMouseRepaintTimer.Enabled := False;
  { A SQL trend may contain tens of thousands of points.  Rebuilding its
    cached geometry at 30 FPS while the right mouse button is held can starve
    the UI thread.  Ten frames per second still gives smooth pan feedback and
    coalesces a burst of mouse events into one geometry rebuild. }
  fMouseRepaintTimer.Interval := 100;
  fMouseRepaintTimer.OnTimer := @MouseRepaintTimerTimer;
  fLineGeometryDirty := True;
  fHoveredEventIndex := -1;
  fPinnedEventIndex := -1;
  fEventPopup := TPopupMenu.Create(Self);
  fRecordingEventsMenuItem := TMenuItem.Create(fEventPopup);
  fRecordingEventsMenuItem.Caption := 'Записи (события WinПОС)';
  fRecordingEventsMenuItem.AutoCheck := False;
  fRecordingEventsMenuItem.OnClick := @EventFilterClick;
  fEventPopup.Items.Add(fRecordingEventsMenuItem);
  fTagAlarmEventsMenuItem := TMenuItem.Create(fEventPopup);
  fTagAlarmEventsMenuItem.Caption := 'Аварии по тегам';
  fTagAlarmEventsMenuItem.AutoCheck := False;
  fTagAlarmEventsMenuItem.OnClick := @EventFilterClick;
  fEventPopup.Items.Add(fTagAlarmEventsMenuItem);
  fTagRangeEventsMenuItem := TMenuItem.Create(fEventPopup);
  fTagRangeEventsMenuItem.Caption := 'Уставки по тегам';
  fTagRangeEventsMenuItem.AutoCheck := False;
  fTagRangeEventsMenuItem.OnClick := @EventFilterClick;
  fEventPopup.Items.Add(fTagRangeEventsMenuItem);
  fUnresolvedEventsMenuItem := TMenuItem.Create(fEventPopup);
  fUnresolvedEventsMenuItem.Caption := 'Только события без замера в WinПОС';
  fUnresolvedEventsMenuItem.AutoCheck := False;
  fUnresolvedEventsMenuItem.OnClick := @EventFilterClick;
  fEventPopup.Items.Add(fUnresolvedEventsMenuItem);
  fAllEventsMenuItem := TMenuItem.Create(fEventPopup);
  fAllEventsMenuItem.Caption := 'Показать все события';
  fAllEventsMenuItem.OnClick := @EventFilterClick;
  fEventPopup.Items.Add(fAllEventsMenuItem);
end;

procedure TRecorderSqlTrendView.LayoutAxisControls;
const
  CGap = 6;
  CFirstRowTop = 3;
  CSecondRowTop = 34;
  CThirdRowTop = 64;
var
  lDeleteLeft, lOpenLeft, lButtonPadding, lDesiredHeight: Integer;
  lUseThirdRow: Boolean;
  lBitmap: TBitmap;
begin
  if (fAxisPanel = nil) or (fExportButton = nil) then Exit;
  lBitmap := TBitmap.Create;
  try
  lBitmap.Canvas.Font.Assign(Font);
  lButtonPadding := lBitmap.Canvas.TextWidth('MM');
  fResetZoomButton.Width := Max(100,
    lBitmap.Canvas.TextWidth(fResetZoomButton.Caption) + lButtonPadding);
  fSaveAxesButton.Width := Max(112,
    lBitmap.Canvas.TextWidth(fSaveAxesButton.Caption) + lButtonPadding);
  fCursorButton.Width := Max(112,
    lBitmap.Canvas.TextWidth(fCursorButton.Caption) + lButtonPadding);
  fDeleteIntervalButton.Width := Max(138,
    lBitmap.Canvas.TextWidth(fDeleteIntervalButton.Caption) + lButtonPadding);
  fOpenMeraEventButton.Width := Max(154,
    lBitmap.Canvas.TextWidth(fOpenMeraEventButton.Caption) + lButtonPadding);
  fExportButton.Width := Max(110,
    lBitmap.Canvas.TextWidth(fExportButton.Caption) + lButtonPadding);
  finally
    lBitmap.Free;
  end;

  fResetZoomButton.Left := fSaveAxesButton.Left + fSaveAxesButton.Width + CGap;
  fCursorButton.Left := fResetZoomButton.Left + fResetZoomButton.Width + CGap;
  fCursorModeCombo.Left := fCursorButton.Left + fCursorButton.Width + CGap;
  lDeleteLeft := fCursorModeCombo.Left + fCursorModeCombo.Width + CGap;
  lOpenLeft := lDeleteLeft + fDeleteIntervalButton.Width + CGap;
  lUseThirdRow := lOpenLeft + fOpenMeraEventButton.Width + CGap >
    fAxisPanel.ClientWidth;
  if lUseThirdRow then
  begin
    fDeleteIntervalButton.SetBounds(6, CSecondRowTop,
      fDeleteIntervalButton.Width, 26);
    fOpenMeraEventButton.SetBounds(
      fDeleteIntervalButton.Left + fDeleteIntervalButton.Width + CGap,
      CSecondRowTop, fOpenMeraEventButton.Width, 26);
    fDisplayLabel.Top := CThirdRowTop + 5;
    fDisplayPrevButton.Top := CThirdRowTop;
    fDisplayCombo.Top := CThirdRowTop;
    fDisplayNextButton.Top := CThirdRowTop;
    fExportButton.Top := CThirdRowTop;
    lDesiredHeight := 94;
  end
  else
  begin
    fDeleteIntervalButton.SetBounds(lDeleteLeft, CFirstRowTop,
      fDeleteIntervalButton.Width, 26);
    fOpenMeraEventButton.SetBounds(lOpenLeft, CFirstRowTop,
      fOpenMeraEventButton.Width, 26);
    fDisplayLabel.Top := CSecondRowTop + 5;
    fDisplayPrevButton.Top := CSecondRowTop;
    fDisplayCombo.Top := CSecondRowTop;
    fDisplayNextButton.Top := CSecondRowTop;
    fExportButton.Top := CSecondRowTop;
    lDesiredHeight := 64;
  end;
  fExportButton.Left := fDisplayNextButton.Left +
    fDisplayNextButton.Width + CGap;
  if fAxisPanel.Height <> lDesiredHeight then
    fAxisPanel.Height := lDesiredHeight;
end;

procedure TRecorderSqlTrendView.MarkLineGeometryDirty;
begin
  fLineGeometryDirty := True;
end;

procedure TRecorderSqlTrendView.RebuildLineGeometry(const APlot: TRect);
var
  I, lAxisIndex, lLineIndex, lMarkerCount,
    lSegmentCount: Integer;
  lLine: TRecorderTrendLine;
  lRange, lPointX, lPointY,
    lClipX0, lClipY0, lClipX1, lClipY1: Double;
  lHasPrevious: array of Boolean;
  lPreviousX, lPreviousY: array of Double;
begin
  SetLength(fLineSegments, Length(fPoints));
  SetLength(fLineMarkers, Length(fPoints));
  lSegmentCount := 0;
  lMarkerCount := 0;
  if (fComponent = nil) or (fComponent.ActiveDisplay = nil) or
    (fToUtc <= fFromUtc) then
  begin
    SetLength(fLineSegments, 0);
    SetLength(fLineMarkers, 0);
    fLineGeometryDirty := False;
    Exit;
  end;
  SetLength(lHasPrevious, fComponent.ActiveDisplay.LineCount);
  SetLength(lPreviousX, fComponent.ActiveDisplay.LineCount);
  SetLength(lPreviousY, fComponent.ActiveDisplay.LineCount);

  for I := 0 to High(fPoints) do
  begin
    lLineIndex := LineIndex(fPoints[I].SignalName);
    if (lLineIndex < 0) or
      (not fComponent.ActiveDisplay.Lines[lLineIndex].Visible) then Continue;
    lLine := fComponent.ActiveDisplay.Lines[lLineIndex];
    lAxisIndex := EnsureRange(lLine.AxisIndex, 0,
      fComponent.ActiveDisplay.AxisCount - 1);
    lRange := fAxisMax[lAxisIndex] - fAxisMin[lAxisIndex];
    if (lRange <= 0) or IsNan(lRange) or IsInfinite(lRange) then Continue;
    lPointX := APlot.Left + (fPoints[I].TimestampUtc - fFromUtc) /
      (fToUtc - fFromUtc) * (APlot.Width - 1);
    lPointY := APlot.Bottom - (fPoints[I].Value - fAxisMin[lAxisIndex]) /
      lRange * (APlot.Height - 1);
    if IsNan(lPointX) or IsInfinite(lPointX) or IsNan(lPointY) or
      IsInfinite(lPointY) then Continue;

    { SQL returns points from all requested signals in one time-ordered array.
      Keep the previous point separately for every line; adjacent array items
      normally belong to different signals and must not break their polylines. }
    if lHasPrevious[lLineIndex] then
    begin
      lClipX0 := lPreviousX[lLineIndex];
      lClipY0 := lPreviousY[lLineIndex];
      lClipX1 := lPointX;
      lClipY1 := lPointY;
      if ClipLineToRect(lClipX0, lClipY0, lClipX1, lClipY1, APlot) then
      begin
        fLineSegments[lSegmentCount].LineIndex := lLineIndex;
        fLineSegments[lSegmentCount].StartPoint :=
          Point(Round(lClipX0), Round(lClipY0));
        fLineSegments[lSegmentCount].EndPoint :=
          Point(Round(lClipX1), Round(lClipY1));
        Inc(lSegmentCount);
      end;
    end;
    if (lPointX >= APlot.Left) and (lPointX <= APlot.Right) and
      (lPointY >= APlot.Top) and (lPointY <= APlot.Bottom) then
    begin
      fLineMarkers[lMarkerCount].LineIndex := lLineIndex;
      fLineMarkers[lMarkerCount].Point := Point(Round(lPointX), Round(lPointY));
      Inc(lMarkerCount);
    end;
    lPreviousX[lLineIndex] := lPointX;
    lPreviousY[lLineIndex] := lPointY;
    lHasPrevious[lLineIndex] := True;
  end;
  SetLength(fLineSegments, lSegmentCount);
  SetLength(fLineMarkers, lMarkerCount);
  fLineGeometryDirty := False;
end;

procedure TRecorderSqlTrendView.UpdateDataAxisBounds;
var
  I, lAxisIndex, lLineIndex: Integer;
begin
  SetLength(fDataAxisHasValue, Length(fAxisMin));
  SetLength(fDataAxisMin, Length(fAxisMin));
  SetLength(fDataAxisMax, Length(fAxisMin));
  for I := 0 to High(fPoints) do
  begin
    lLineIndex := LineIndex(fPoints[I].SignalName);
    if (lLineIndex < 0) or
      (not fComponent.ActiveDisplay.Lines[lLineIndex].Visible) then Continue;
    lAxisIndex := EnsureRange(
      fComponent.ActiveDisplay.Lines[lLineIndex].AxisIndex, 0,
      High(fAxisMin));
    if not fDataAxisHasValue[lAxisIndex] then
    begin
      fDataAxisMin[lAxisIndex] := fPoints[I].Value;
      fDataAxisMax[lAxisIndex] := fPoints[I].Value;
      fDataAxisHasValue[lAxisIndex] := True;
    end
    else
    begin
      fDataAxisMin[lAxisIndex] := Min(fDataAxisMin[lAxisIndex],
        fPoints[I].Value);
      fDataAxisMax[lAxisIndex] := Max(fDataAxisMax[lAxisIndex],
        fPoints[I].Value);
    end;
  end;
end;

procedure TRecorderSqlTrendView.RequestMouseRepaint;
begin
  fMouseRepaintPending := True;
  if not fMouseRepaintTimer.Enabled then
    fMouseRepaintTimer.Enabled := True;
end;

procedure TRecorderSqlTrendView.MouseRepaintTimerTimer(Sender: TObject);
begin
  fMouseRepaintTimer.Enabled := False;
  if not fMouseRepaintPending then Exit;
  fMouseRepaintPending := False;
  Invalidate;
end;

procedure TRecorderSqlTrendView.ClampAntiZoomXRange;
const
  CMinZoomDateYear = 2026;
  CMinZoomDateMonth = 10;
  CMinZoomDateDay = 1;
var
  lLeftBound, lRightBound: Double;
begin
  lLeftBound := EncodeDate(CMinZoomDateYear, CMinZoomDateMonth,
    CMinZoomDateDay);
  lRightBound := fDatabaseMaxUtc;
  if lRightBound <= lLeftBound then
    lRightBound := Max(lLeftBound + 1.0 / SecsPerDay, fFullToUtc);
  if IsNan(fFromUtc) or IsInfinite(fFromUtc) or IsNan(fToUtc) or
    IsInfinite(fToUtc) or (fToUtc - fFromUtc >= lRightBound - lLeftBound) then
  begin
    fFromUtc := lLeftBound;
    fToUtc := lRightBound;
    Exit;
  end;
  fFromUtc := Max(fFromUtc, lLeftBound);
  fToUtc := Min(fToUtc, lRightBound);
  if fToUtc <= fFromUtc then
  begin
    fFromUtc := lLeftBound;
    fToUtc := lRightBound;
  end;
end;

procedure TRecorderSqlTrendView.ClampAntiZoomYRange;
var
  I: Integer;
  lAllowedMin, lAllowedMax, lDataRange, lPadding: Double;
begin
  for I := 0 to High(fAxisMin) do
  begin
    if (I > High(fDataAxisHasValue)) or
      (not fDataAxisHasValue[I]) then Continue;
    lDataRange := fDataAxisMax[I] - fDataAxisMin[I];
    if lDataRange > 0 then
      lPadding := lDataRange * 0.20
    else
      lPadding := Max(1.0, Abs(fDataAxisMin[I]) * 0.20);
    lAllowedMin := fDataAxisMin[I] - lPadding;
    lAllowedMax := fDataAxisMax[I] + lPadding;
    if IsNan(fAxisMin[I]) or IsInfinite(fAxisMin[I]) or
      IsNan(fAxisMax[I]) or IsInfinite(fAxisMax[I]) or
      (fAxisMax[I] - fAxisMin[I] >= lAllowedMax - lAllowedMin) then
    begin
      fAxisMin[I] := lAllowedMin;
      fAxisMax[I] := lAllowedMax;
    end
    else
    begin
      fAxisMin[I] := Max(fAxisMin[I], lAllowedMin);
      fAxisMax[I] := Min(fAxisMax[I], lAllowedMax);
    end;
  end;
end;

procedure TRecorderSqlTrendView.Resize;
begin
  inherited Resize;
  MarkLineGeometryDirty;
  LayoutAxisControls;
end;

procedure TRecorderSqlTrendView.EventFilterClick(Sender: TObject);
var
  lWasResolvedOnly: Boolean;
  lChanged: Boolean;
begin
  if fComponent = nil then Exit;
  lWasResolvedOnly := fComponent.ShowOnlyUnresolvedEventPoints;
  if Sender = fRecordingEventsMenuItem then
    fComponent.ShowRecordingEvents := not fComponent.ShowRecordingEvents
  else if Sender = fTagAlarmEventsMenuItem then
    fComponent.ShowTagAlarmEvents := not fComponent.ShowTagAlarmEvents
  else if Sender = fTagRangeEventsMenuItem then
    fComponent.ShowTagRangeEvents := not fComponent.ShowTagRangeEvents
  else if Sender = fUnresolvedEventsMenuItem then
    fComponent.ShowOnlyUnresolvedEventPoints :=
      not fComponent.ShowOnlyUnresolvedEventPoints
  else if Sender = fAllEventsMenuItem then
  begin
    fComponent.ShowRecordingEvents := True;
    fComponent.ShowTagAlarmEvents := True;
    fComponent.ShowTagRangeEvents := True;
    fComponent.ShowOnlyUnresolvedEventPoints := False;
  end
  else
    Exit;
  { Соседние галочки не должны приводить к пустому тренду: если пользователь
    снял последнюю, запрос к SQL был бы пустым. Возвращаем уставки — это
    ближайшее к событиям «аварийное» семейство, и пользователь видит результат
    своего щелчка. }
  if (not fComponent.ShowRecordingEvents) and
    (not fComponent.ShowTagAlarmEvents) and
    (not fComponent.ShowTagRangeEvents) then
  begin
    if Sender <> fTagAlarmEventsMenuItem then
      fComponent.ShowTagAlarmEvents := True
    else
      fComponent.ShowTagRangeEvents := True;
  end;
  UpdateEventFilterMenu;
  lChanged := lWasResolvedOnly <> fComponent.ShowOnlyUnresolvedEventPoints;
  if lChanged then
  begin
    { Фильтр «без замера» применяется к уже загруженному списку, без SQL. }
    fPinnedEventId := '';
    fPinnedEventIndex := -1;
    fHoveredEventIndex := -1;
    UpdateMeraEventButton;
    Invalidate;
  end
  else
    RequestEventReload;
end;

procedure TRecorderSqlTrendView.UpdateEventFilterMenu;
begin
  if fComponent = nil then Exit;
  fRecordingEventsMenuItem.Checked := fComponent.ShowRecordingEvents;
  fTagAlarmEventsMenuItem.Checked := fComponent.ShowTagAlarmEvents;
  fTagRangeEventsMenuItem.Checked := fComponent.ShowTagRangeEvents;
  fUnresolvedEventsMenuItem.Checked :=
    fComponent.ShowOnlyUnresolvedEventPoints;
end;

procedure TRecorderSqlTrendView.RequestEventReload;
begin
  fHoveredEventIndex := -1;
  fPinnedEventIndex := -1;
  fPinnedEventId := '';
  fForceFullReload := True;
  fLoadPending := True;
  fReloadTimer.Enabled := True;
  UpdateMeraEventButton;
  Invalidate;
end;

procedure TRecorderSqlTrendView.ExportButtonClick(Sender: TObject);
var
  lFromUtc, lToUtc: TDateTime;
begin
  if fComponent = nil then Exit;
  lFromUtc := fFromUtc;
  lToUtc := fToUtc;
  if lToUtc <= lFromUtc then
  begin
    lFromUtc := fComponent.FromUtc;
    lToUtc := fComponent.ToUtc;
  end;
  if lToUtc <= lFromUtc then
  begin
    lToUtc := LocalTimeToUniversal(Now);
    lFromUtc := lToUtc - 1.0;
  end;
  ShowRecorderSqlTrendExportDialog(GetParentForm(Self), fComponent,
    lFromUtc, lToUtc);
end;

{
  Обновление выбора события. Щелчок по маркеру немедленно открывает карточку
  замера в WinПОС. Если данные записи в SQL не найдены (иконка «нет данных»),
  пользователь получает объяснение в заголовке и подсказке, а не тихий отказ.
}
procedure TRecorderSqlTrendView.PinEvent(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex > High(fEvents)) then Exit;
  fPinnedEventIndex := AIndex;
  fPinnedEventId := fEvents[AIndex].EventId;
  fHoveredEventIndex := AIndex;
  if (fComponent <> nil) and fComponent.ShowEvents then
    OpenMeraEventButtonClick(nil);
  UpdateMeraEventButton;
  Invalidate;
end;

function TRecorderSqlTrendView.IndexOfEventId(const AEventId: string): Integer;
begin
  Result := -1;
  if Trim(AEventId) = '' then Exit;
  for Result := 0 to High(fEvents) do
    if SameText(fEvents[Result].EventId, AEventId) then
      Exit;
  Result := -1;
end;

procedure TRecorderSqlTrendView.OpenMeraEventButtonClick(Sender: TObject);
var
  lIndex: Integer;
  lEventId: string;
  lResult: TRecorderMeraEventDialogResult;
begin
  lIndex := fPinnedEventIndex;
  if lIndex < 0 then lIndex := fHoveredEventIndex;
  if (lIndex < 0) or (lIndex > High(fEvents)) or (fComponent = nil) or
    (not IsRecordingEvent(lIndex)) then Exit;
  lEventId := fEvents[lIndex].EventId;
  lResult := ShowRecorderMeraEventDialog(GetParentForm(Self),
    fComponent.ConfigFileName, fEvents[lIndex]);
  if lResult <> medrUnchanged then
  begin
    { Правка выполняется по только что открытой записи; держим её видимой и
      выбранной по устойчивому EventId после перезагрузки списка. }
    if lResult = medrDeleted then
    begin
      fPinnedEventId := '';
      fPinnedEventIndex := -1;
    end
    else
    begin
      if fComponent.ShowOnlyUnresolvedEventPoints then
      begin
        fComponent.ShowOnlyUnresolvedEventPoints := False;
        UpdateEventFilterMenu;
      end;
      fPinnedEventId := lEventId;
      fPinnedEventIndex := -1;
    end;
    fHoveredEventIndex := -1;
    { Editing or deleting must reconcile against the complete interval.  An
      overlap merge cannot discover a deletion outside its short window. }
    fForceFullReload := True;
    fLoadPending := True;
    fReloadTimer.Enabled := True;
    UpdateMeraEventButton;
    Invalidate;
  end;
end;

procedure TRecorderSqlTrendView.UpdateMeraEventButton;
var
  lIndex: Integer;
begin
  lIndex := fPinnedEventIndex;
  if lIndex < 0 then lIndex := fHoveredEventIndex;
  if fOpenMeraEventButton <> nil then
  begin
    { Для события без данных замера открывать нечего: кнопка остаётся
      недоступной, а подсказка объясняет причину. }
    fOpenMeraEventButton.Enabled := (fComponent <> nil) and
      fComponent.ShowEvents and IsRecordingEvent(lIndex) and
      (not IsUnresolvedEvent(lIndex));
    if (lIndex >= 0) and (lIndex <= High(fEvents)) and
      IsUnresolvedEvent(lIndex) then
      fOpenMeraEventButton.Hint := UnresolvedEventStatusText
    else
      fOpenMeraEventButton.Hint := '';
    fOpenMeraEventButton.ShowHint := fOpenMeraEventButton.Hint <> '';
  end;
end;

function TRecorderSqlTrendView.IsRecordingEvent(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex <= High(fEvents)) and
    SameText(fEvents[AIndex].EventType, 'mera.recording');
end;

function TRecorderSqlTrendView.MatchesTagSignalFilter(
  const AEvent: TRecorderSqlDbMeraEvent): Boolean;
var
  lSignalName: string;
begin
  { Аварийные события показываются либо когда сигнал вообще не опубликован в
    таблицу signals, либо когда его линия есть в текущем отображении тренда.
    Иначе шум со всех записанных тегов забивает маркер. }
  lSignalName := Trim(AEvent.SignalName);
  if (lSignalName = '') or (fComponent = nil) or
    (fComponent.ActiveDisplay = nil) then
    Exit(True);
  Result := LineIndex(lSignalName) >= 0;
end;

function TRecorderSqlTrendView.EventMatchesTagFilter(
  AIndex: Integer): Boolean;
begin
  Result := False;
  if (AIndex < 0) or (AIndex > High(fEvents)) then Exit;
  if SameText(fEvents[AIndex].EventType, 'tag.range') then
    Exit((fComponent = nil) or (not fComponent.ShowEvents) or
      (fComponent.ShowTagRangeEvents and MatchesTagSignalFilter(fEvents[AIndex])));
  if SameText(fEvents[AIndex].EventType, 'tag.alarm') then
    Exit((fComponent = nil) or (not fComponent.ShowEvents) or
      (fComponent.ShowTagAlarmEvents and MatchesTagSignalFilter(fEvents[AIndex])));
  Result := True;
end;

function TRecorderSqlTrendView.EventVisible(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex <= High(fEvents));
  if not Result then Exit;
  if (fComponent <> nil) and (not fComponent.ShowEvents) then Exit(False);
  if IsRecordingEvent(AIndex) then
    Result := (fComponent = nil) or fComponent.ShowRecordingEvents
  else
    Result := EventMatchesTagFilter(AIndex);
  if Result and (fComponent <> nil) and
    fComponent.ShowOnlyUnresolvedEventPoints then
    Result := IsUnresolvedEvent(AIndex);
end;

function TRecorderSqlTrendView.IsUnresolvedEvent(AIndex: Integer): Boolean;
begin
  { Замера нет в SQL: mera_recdrding_files пуст, поэтому диалог WinПОС не
    найдёт ни одного .mera. }
  Result := IsRecordingEvent(AIndex) and (fEvents[AIndex].MeraFileCount = 0);
end;

function TRecorderSqlTrendView.EventCaption(AIndex: Integer): string;
var
  lText: string;
begin
  Result := '';
  if (AIndex < 0) or (AIndex > High(fEvents)) then Exit;
  if IsRecordingEvent(AIndex) then
  begin
    { Пометка о неразрешимом замере: по щелчку пользователь сразу видит, что в
      WinПОС открывать нечего. }
    lText := '';
    if IsUnresolvedEvent(AIndex) then
      lText := '  [' + UTF8Encode(CUnresolvedEventCaption) + ']';
    Result := Format('%s  %s  ПК/пакетов: %d  %s', [
      FormatDateTime('dd.mm.yyyy hh:nn:ss',
        UtcDisplayTime(fEvents[AIndex].StartedAtUtc)),
      fEvents[AIndex].DisplayName,
      fEvents[AIndex].PackageCount,
      fEvents[AIndex].State]) + lText;
  end
  else
  begin
    Result := Trim(fEvents[AIndex].Description);
    if Result = '' then
      Result := UTF8Encode(UnicodeString('Сработала уставка: ') +
        UnicodeString(fEvents[AIndex].DisplayName));
    Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
    Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
    if Length(Result) > 180 then
      Result := Copy(Result, 1, 177) + '...';
    Result := Format('%s  %s', [
      FormatDateTime('dd.mm.yyyy hh:nn:ss',
        UtcDisplayTime(fEvents[AIndex].StartedAtUtc)), Result]);
  end;
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
  UpdateDataAxisBounds;
  MarkLineGeometryDirty;
  Result := True;
end;

procedure TRecorderSqlTrendView.DisplayComboChange(Sender: TObject);
begin
  if (fComponent = nil) or (fDisplayCombo.ItemIndex < 0) or
    (fDisplayCombo.ItemIndex = fComponent.ActiveDisplayIndex) then Exit;
  fComponent.ActiveDisplayIndex := fDisplayCombo.ItemIndex;
  { The new display can contain another set of signals.  Calculate its Y
    ranges only after the matching SQL data has arrived. }
  fAutoZoomYOnLoad := True;
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
  MarkLineGeometryDirty;
  Invalidate;
end;

destructor TRecorderSqlTrendView.Destroy;
begin
  if fReloadTimer <> nil then fReloadTimer.Enabled := False;
  if fLiveReloadTimer <> nil then fLiveReloadTimer.Enabled := False;
  if fMouseRepaintTimer <> nil then fMouseRepaintTimer.Enabled := False;
  if fWorker <> nil then
  begin
    fWorker.fOwner := nil;
    fWorker.Terminate;
    RTLEventSetEvent(fWorker.fWakeEvent);
    fWorker.WaitFor;
    FreeAndNil(fWorker);
  end;
  fMergeRowIds.Free;
  fLoadSignalNames.Free;
  inherited Destroy;
end;

procedure TRecorderSqlTrendView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  if not (AComponent is TRecorderSqlTrendComponent) then Exit;
  fComponent := TRecorderSqlTrendComponent(AComponent);
  fDatabaseMaxUtc := 0;
  MarkLineGeometryDirty;
  UpdateEventFilterMenu;
  if not fComponent.ShowEvents then
  begin
    fHoveredEventIndex := -1;
    fPinnedEventIndex := -1;
    fPinnedEventId := '';
  end;
  FillDisplayControls;
  fAxisCombo.ItemIndex := 0;
  SyncAxisRangesFromComponent(True);
  UpdateLegend;
  UpdateDeleteIntervalButton;
  ConfigureLiveReload;
  fManualXRange := False;
  fFollowCurrentDateRightEdge := False;
  fResetViewOnLoad := True;
  fLoadPending := True;
  fReloadTimer.Enabled := True;
  Invalidate;
end;

function TRecorderSqlTrendView.GetPlotRect: TRect;
var
  lColumnWidth, lColumnCount, lRowCount, lXAxisCaptionHeight: Integer;
begin
  Result.Right := Max(65, fLegendSplitter.Left - 8);
  Result.Left := 112;
  GetAxisHeaderLayout(Result.Right, lColumnWidth, lColumnCount, lRowCount);
  Result.Top := 8 + lRowCount * (Canvas.TextHeight('Ag') + 2);
  { The time axis uses one row for the interval ends and a second row for
    intermediate ticks. Reserve their real font height instead of fixed pixels. }
  lXAxisCaptionHeight := 2 * Canvas.TextHeight('Ag') + 14;
  Result.Bottom := Max(Result.Top + 1,
    ClientHeight - fAxisPanel.Height - lXAxisCaptionHeight);
end;

function TRecorderSqlTrendView.AxisCaption(AIndex: Integer): string;
begin
  Result := fComponent.ActiveDisplay.Axes[AIndex].Name + ' [' +
    FloatToStrF(fAxisMin[AIndex], ffGeneral, 7, 3) + '..' +
    FloatToStrF(fAxisMax[AIndex], ffGeneral, 7, 3) + ']';
  if AIndex = fAxisCombo.ItemIndex then
    Result := Result + ' dY=' +
      FloatToStrF(fAxisMax[AIndex] - fAxisMin[AIndex], ffGeneral, 7, 3);
end;

procedure TRecorderSqlTrendView.GetAxisHeaderLayout(ARight: Integer;
  out AColumnWidth, AColumnCount, ARowCount: Integer);
var
  I, lCaptionWidth: Integer;
begin
  AColumnWidth := 1;
  AColumnCount := 1;
  ARowCount := 0;
  if (fComponent = nil) or (fComponent.ActiveDisplay.AxisCount = 0) then Exit;
  for I := 0 to fComponent.ActiveDisplay.AxisCount - 1 do
  begin
    lCaptionWidth := Canvas.TextWidth(AxisCaption(I)) + 12;
    if lCaptionWidth > AColumnWidth then
      AColumnWidth := lCaptionWidth;
  end;
  AColumnWidth := Max(1, Min(AColumnWidth, ARight - 8));
  AColumnCount := Max(1, (ARight - 8) div AColumnWidth);
  ARowCount := (fComponent.ActiveDisplay.AxisCount + AColumnCount - 1) div
    AColumnCount;
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
  MarkLineGeometryDirty;
  Invalidate;
end;

procedure TRecorderSqlTrendView.SaveAxesClick(Sender: TObject);
var
  I: Integer;
begin
  if (fComponent = nil) or (fComponent.ActiveDisplay = nil) then Exit;
  for I := 0 to Min(High(fAxisMin),
    fComponent.ActiveDisplay.AxisCount - 1) do
  begin
    fComponent.ActiveDisplay.Axes[I].RangeMin := fAxisMin[I];
    fComponent.ActiveDisplay.Axes[I].RangeMax := fAxisMax[I];
    fFullAxisMin[I] := fAxisMin[I];
    fFullAxisMax[I] := fAxisMax[I];
  end;
  fAxisSignature := BuildAxisSignature;
end;

procedure TRecorderSqlTrendView.AutoZoomYAxis;
var
  I, lLineIndex, lAxisIndex: Integer;
  lHasAxis: array of Boolean;
  lHasX: Boolean;
  lRange, lPadding, lMinX, lMaxX: Double;
begin
  if (fComponent = nil) or (fComponent.ActiveDisplay = nil) or
    (Length(fAxisMin) = 0) then Exit;
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
      lMinX := fPoints[I].TimestampUtc;
      lMaxX := lMinX;
      lHasX := True;
    end
    else
    begin
      lMinX := Min(lMinX, fPoints[I].TimestampUtc);
      lMaxX := Max(lMaxX, fPoints[I].TimestampUtc);
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
  for I := 0 to High(fAxisMin) do
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
  { Display switching must fit the visible lines on both axes.  Keeping the
    previous display's X viewport can stretch the chart across years and make
    otherwise correctly loaded points appear missing.  Events are deliberately
    excluded: they do not define the data domain of the selected lines. }
  if lHasX then
  begin
    if lMaxX <= lMinX then
      lMaxX := lMinX + 1.0 / SecsPerDay;
    fFromUtc := lMinX;
    fToUtc := lMaxX;
    fFullFromUtc := lMinX;
    fFullToUtc := lMaxX;
    { This range was selected automatically while loading/switching a display.
      Live modes must keep following the newest SQL point.  Only a genuinely
      fixed historical interval may treat the automatic fit as a fixed view;
      mouse zoom/pan still set fManualXRange explicitly elsewhere. }
    fManualXRange := not (fComponent.TimeMode in [sttmLatestWindow,
      sttmFixedFromToCurrentUtc]);
    fFollowCurrentDateRightEdge :=
      fComponent.TimeMode = sttmFixedFromToCurrentUtc;
  end;
  UpdateDataAxisBounds;
  MarkLineGeometryDirty;
  LoadAxisControls;
  Invalidate;
end;

procedure TRecorderSqlTrendView.RestoreConfiguredAxisRanges;
begin
  { A chart double click means "return to the preset scale".  The preset is
    stored in the active display axes and is intentionally not overwritten by
    automatic or mouse zoom. }
  SyncAxisRangesFromComponent(True);
  Invalidate;
end;

procedure TRecorderSqlTrendView.ResetZoomClick(Sender: TObject);
var
  I, lLineIndex, lAxisIndex: Integer;
  lHasX: Boolean;
  lHasAxis: array of Boolean;
  lRange, lPadding: Double;
begin
  lHasAxis := nil;
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
  { Event markers are part of the horizontal data domain.  Ignoring them here
    made Reset zoom collapse to old signal points and hide newer recordings. }
  if fComponent.ShowEvents then
  for I := 0 to High(fEvents) do
  begin
    if not lHasX then
    begin
      fFullFromUtc := fEvents[I].StartedAtUtc;
      fFullToUtc := fEvents[I].StartedAtUtc;
      lHasX := True;
    end
    else
    begin
      fFullFromUtc := Min(fFullFromUtc, fEvents[I].StartedAtUtc);
      fFullToUtc := Max(fFullToUtc, fEvents[I].StartedAtUtc);
    end;
    if fEvents[I].FinishedAtUtc > fEvents[I].StartedAtUtc then
      fFullToUtc := Max(fFullToUtc, fEvents[I].FinishedAtUtc);
  end;
  if lHasX then
  begin
    fFromUtc := fFullFromUtc;
    fToUtc := fFullToUtc;
    if fToUtc <= fFromUtc then
      fToUtc := fFromUtc + 1.0 / SecsPerDay;
    { Reset zoom is an explicit user viewport too.  Keep it across live SQL
      reloads just like rectangle zoom and X pan. }
    fManualXRange := True;
    fFollowCurrentDateRightEdge :=
      fComponent.TimeMode = sttmFixedFromToCurrentUtc;
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
  UpdateDataAxisBounds;
  MarkLineGeometryDirty;
  LoadAxisControls;
  Invalidate;
end;

procedure TRecorderSqlTrendView.DblClick;
begin
  inherited DblClick;
  RestoreConfiguredAxisRanges;
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
    (not (fComponent.TimeMode in [sttmLatestWindow,
      sttmFixedFromToCurrentUtc])) or
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
    (not (fComponent.TimeMode in [sttmLatestWindow,
      sttmFixedFromToCurrentUtc])) or (not Showing) then
    Exit;
  fLoadPending := True;
  { Do not run/accept another SQL window while the user is changing the
    viewport.  Besides wasting a query, that result dirties the full line
    geometry in the middle of a drag and was able to make the UI appear hung
    after rapid right-button panning.  MouseUp schedules the pending load. }
  if fZoomSelecting or fCursorDragging or fPanning then Exit;
  StartLoad;
end;

procedure TRecorderSqlTrendView.StartLoad;
var
  I: Integer;
  lFromUtc, lToUtc, lOverlapMs: Double;
  lAppendLoad: Boolean;
begin
  if (not fLoadPending) or (fComponent = nil) or (fWorker = nil) then Exit;
  if fZoomSelecting or fCursorDragging or fPanning then Exit;
  fLoadPending := False;
  fErrorText := '';
  if not FileExists(fComponent.ConfigFileName) then
  begin
    fErrorText := UTF8Encode(UnicodeString(
      'Не найден файл настроек SQL БД: ') +
      UnicodeString(fComponent.ConfigFileName));
    Invalidate;
    Exit;
  end;
  fLoadSignalNames.Clear;
    for I := 0 to fComponent.ActiveDisplay.LineCount - 1 do
      if fComponent.ActiveDisplay.Lines[I].Visible and
        (Trim(fComponent.ActiveDisplay.Lines[I].TagName) <> '') then
        if fLoadSignalNames.IndexOf(fComponent.ActiveDisplay.Lines[I].TagName) < 0 then
          fLoadSignalNames.Add(fComponent.ActiveDisplay.Lines[I].TagName);
    lAppendLoad := (not fForceFullReload) and
      (fComponent.TimeMode = sttmFixedFromToCurrentUtc) and
      (not fResetViewOnLoad) and (fFullToUtc > fFullFromUtc);
    if fComponent.TimeMode = sttmLatestWindow then
    begin
      if fManualXRange then
      begin
        { A zoomed short interval must be read at its own resolution.  Reading
          and bucketing the whole multi-day window leaves only a few points in
          a minute even though the database contains one point per second. }
        lFromUtc := fFromUtc;
        lToUtc := fToUtc;
      end
      else
      begin
        lToUtc := LocalTimeToUniversal(Now);
        lFromUtc := lToUtc - Max(1.0, fComponent.DurationSec) / SecsPerDay;
      end;
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
  if fWorker.RequestLoad(fComponent.ConfigFileName, fLoadSignalNames,
    lFromUtc, lToUtc, fComponent.MaxPointsPerLine, lAppendLoad,
    fAutoZoomYOnLoad,
    fComponent.ShowEvents and fComponent.ShowRecordingEvents,
    fComponent.ShowEvents and fComponent.ShowTagAlarmEvents,
    fComponent.ShowEvents and fComponent.ShowTagRangeEvents) then
    fForceFullReload := False
  else
    fLoadPending := True;
end;

procedure TRecorderSqlTrendView.AcceptLoad(AWorker: TRecorderSqlTrendLoadThread);
var
  I: Integer;
  lOldPoints: TRecorderSqlTrendPoints;
  lOldEvents: TRecorderSqlDbMeraEvents;
  lPinnedEventId: string;
begin
  if AWorker <> fWorker then Exit;
  if not LoadMatchesActiveDisplay(AWorker) then
  begin
    { The user switched displays while the previous SQL request was running.
      Never apply or auto-scale that stale result against another line set. }
    fLoadPending := True;
    fReloadTimer.Enabled := True;
    Exit;
  end;
  fErrorText := AWorker.fErrorText;
  if fErrorText = '' then
  begin
    if AWorker.fAppendLoad then
      MergeLivePoints(AWorker.fPoints)
    else if (Length(AWorker.fPoints) = 0) and (Length(fPoints) > 0) and
      (not fResetViewOnLoad) and
      (fComponent.TimeMode in [sttmLatestWindow,
        sttmFixedFromToCurrentUtc]) then
    begin
      { A momentary empty live read (transaction turnover or writer lag)
        must not blank the chart between two valid refreshes.  Initial loads
        and explicit display changes still accept an empty result. }
    end
    else
    begin
      { Transfer ownership instead of copying a complete historical result.
        The worker receives the previous buffer and can reuse it later. }
      lOldPoints := fPoints;
      fPoints := AWorker.fPoints;
      AWorker.fPoints := lOldPoints;
    end;
    lPinnedEventId := '';
    if (fPinnedEventIndex >= 0) and (fPinnedEventIndex <= High(fEvents)) then
      lPinnedEventId := fEvents[fPinnedEventIndex].EventId
    else
      lPinnedEventId := fPinnedEventId;
    if AWorker.fAppendLoad then
      MergeLiveEvents(AWorker.fEvents, fComponent.FromUtc)
    else
    begin
      lOldEvents := fEvents;
      fEvents := AWorker.fEvents;
      AWorker.fEvents := lOldEvents;
    end;
    fHoveredEventIndex := -1;
    fPinnedEventIndex := -1;
    { Выбор привязывается по устойчивому EventId: после перезагрузки или
      слияния старый номер строки указывает на другое событие (или ни на что). }
    if lPinnedEventId <> '' then
      fPinnedEventIndex := IndexOfEventId(lPinnedEventId);
    if fPinnedEventIndex >= 0 then
      fHoveredEventIndex := fPinnedEventIndex;
    { A failed load must not advance this watermark: the next live tick has
      to retry the same interval instead of permanently skipping its data. }
    if fResetViewOnLoad then
    begin
      fFromUtc := AWorker.fFromUtc;
      fToUtc := AWorker.fToUtc;
      fResetViewOnLoad := False;
    end
    else if (fComponent.TimeMode = sttmFixedFromToCurrentUtc) and
      (not fManualXRange) then
    begin
      { "По текущую дату" means one growing interval from the configured
        start, not a sliding window with the previously visible width. }
      fFromUtc := fComponent.FromUtc;
      fToUtc := AWorker.fToUtc;
    end;
    if (fComponent.TimeMode = sttmFixedFromToCurrentUtc) and
      fManualXRange and fFollowCurrentDateRightEdge then
    begin
      { Follow only the live right edge.  The left edge is the user's zoomed
        boundary and must never jump back to the configured full interval. }
      fToUtc := AWorker.fToUtc;
      if fToUtc <= fFromUtc then
        fToUtc := fFromUtc + 1.0 / SecsPerDay;
    end;
    if (fComponent.TimeMode = sttmLatestWindow) and
      (not fManualXRange) then
    begin
      { Keep the live window moving with the newest committed SQL point. }
      fFromUtc := AWorker.fFromUtc;
      fToUtc := AWorker.fToUtc;
    end;
    if not AWorker.fAppendLoad then
      fFullFromUtc := AWorker.fFromUtc;
    fFullToUtc := AWorker.fToUtc;
    ClampCurrentDateXRange;
    if fAutoZoomYOnLoad then
    begin
      fAutoZoomYOnLoad := False;
      AutoZoomYAxis;
    end;
    if AWorker.fHasDatabaseRange then
      fDatabaseMaxUtc := AWorker.fDatabaseMaxUtc;
    for I := 0 to High(fPoints) do
      fDatabaseMaxUtc := Max(fDatabaseMaxUtc,
        fPoints[I].TimestampUtc);
    UpdateDataAxisBounds;
    MarkLineGeometryDirty;
  end;
  if fLoadPending then fReloadTimer.Enabled := True;
  UpdateDeleteIntervalButton;
  UpdateMeraEventButton;
  Invalidate;
end;

function TRecorderSqlTrendView.LoadMatchesActiveDisplay(
  AWorker: TRecorderSqlTrendLoadThread): Boolean;
var
  I: Integer;
  lNames: TStringList;
  lName: string;
begin
  Result := False;
  if (AWorker = nil) or (fComponent = nil) or
    (fComponent.ActiveDisplay = nil) then Exit;
  lNames := TStringList.Create;
  try
    lNames.CaseSensitive := False;
    lNames.Sorted := True;
    lNames.Duplicates := dupIgnore;
    for I := 0 to fComponent.ActiveDisplay.LineCount - 1 do
      if fComponent.ActiveDisplay.Lines[I].Visible then
      begin
        lName := Trim(fComponent.ActiveDisplay.Lines[I].TagName);
        if lName <> '' then lNames.Add(lName);
      end;
    if lNames.Count <> AWorker.fSignalNames.Count then Exit;
    for I := 0 to lNames.Count - 1 do
      if AWorker.fSignalNames.IndexOf(lNames[I]) < 0 then Exit;
    Result := True;
  finally
    lNames.Free;
  end;
end;

procedure TRecorderSqlTrendView.MergeLiveEvents(
  const ANewEvents: TRecorderSqlDbMeraEvents; AFromUtc: Double);
var
  I, J, lCount: Integer;
  lFound: Boolean;
  lMerged: TRecorderSqlDbMeraEvents;
begin
  lMerged := nil;
  SetLength(lMerged, Length(fEvents) + Length(ANewEvents));
  lCount := 0;
  for I := 0 to High(fEvents) do
    if fEvents[I].StartedAtUtc >= AFromUtc then
    begin
      lMerged[lCount] := fEvents[I];
      Inc(lCount);
    end;
  for I := 0 to High(ANewEvents) do
  begin
    lFound := False;
    for J := 0 to lCount - 1 do
      if SameText(lMerged[J].EventId, ANewEvents[I].EventId) then
      begin
        { The overlap query returns the newest lifecycle state and file count. }
        lMerged[J] := ANewEvents[I];
        lFound := True;
        Break;
      end;
    if not lFound then
    begin
      lMerged[lCount] := ANewEvents[I];
      Inc(lCount);
    end;
  end;
  SetLength(lMerged, lCount);
  fEvents := lMerged;
end;

procedure TRecorderSqlTrendView.MergeLivePoints(
  const ANewPoints: TRecorderSqlTrendPoints);
var
  I, J, K, lCombinedCount, lKeepFrom, lOutputStart: Integer;
  lSignalName: string;
  lDuplicate: Boolean;
  lOldPoints: TRecorderSqlTrendPoints;

  procedure SortCombinedByTime(ALeft, ARight: Integer);
  var
    lLeft, lRight: Integer;
    lPivot: Double;
    lSwap: TRecorderSqlTrendPoint;
  begin
    lLeft := ALeft;
    lRight := ARight;
    lPivot := fMergeCombined[(ALeft + ARight) div 2].TimestampUtc;
    repeat
      while fMergeCombined[lLeft].TimestampUtc < lPivot do Inc(lLeft);
      while fMergeCombined[lRight].TimestampUtc > lPivot do Dec(lRight);
      if lLeft <= lRight then
      begin
        lSwap := fMergeCombined[lLeft];
        fMergeCombined[lLeft] := fMergeCombined[lRight];
        fMergeCombined[lRight] := lSwap;
        Inc(lLeft);
        Dec(lRight);
      end;
    until lLeft > lRight;
    if ALeft < lRight then SortCombinedByTime(ALeft, lRight);
    if lLeft < ARight then SortCombinedByTime(lLeft, ARight);
  end;
begin
  if Length(fMergeCombined) < 2 * fComponent.MaxPointsPerLine then
    SetLength(fMergeCombined, 2 * fComponent.MaxPointsPerLine);
  lOutputStart := 0;
  try
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
      fMergeRowIds.Clear;
      for J := 0 to High(fPoints) do
        if SameText(fPoints[J].SignalName, lSignalName) then
        begin
          fMergeCombined[lCombinedCount] := fPoints[J];
          Inc(lCombinedCount);
          fMergeRowIds.Add(fPoints[J].RowId);
        end;
      for J := 0 to High(ANewPoints) do
        if SameText(ANewPoints[J].SignalName, lSignalName) and
          (fMergeRowIds.IndexOf(ANewPoints[J].RowId) < 0) then
        begin
          fMergeCombined[lCombinedCount] := ANewPoints[J];
          Inc(lCombinedCount);
          fMergeRowIds.Add(ANewPoints[J].RowId);
        end;
      if lCombinedCount > 1 then
        SortCombinedByTime(0, lCombinedCount - 1);
      lKeepFrom := Max(0,
        lCombinedCount - fComponent.MaxPointsPerLine);
      if Length(fMergeOutput) < lOutputStart + lCombinedCount - lKeepFrom then
        SetLength(fMergeOutput, lOutputStart + lCombinedCount - lKeepFrom);
      for J := lKeepFrom to lCombinedCount - 1 do
        fMergeOutput[lOutputStart + J - lKeepFrom] := fMergeCombined[J];
      Inc(lOutputStart, lCombinedCount - lKeepFrom);
    end;
  finally
    { Keep capacities for the next live tick. }
  end;
  SetLength(fMergeOutput, lOutputStart);
  lOldPoints := fPoints;
  fPoints := fMergeOutput;
  fMergeOutput := lOldPoints;
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

function TRecorderSqlTrendView.CurrentDateRightEdgeVisible: Boolean;
var
  lReferenceRight, lTolerance: Double;
begin
  Result := False;
  if (fComponent = nil) or
    (fComponent.TimeMode <> sttmFixedFromToCurrentUtc) or
    (fToUtc <= fFromUtc) then Exit;
  { Prefer the last real SQL point.  Before the first completed read, fall
    back to the loaded/requested right boundary. }
  lReferenceRight := fDatabaseMaxUtc;
  if lReferenceRight <= 0 then lReferenceRight := fFullToUtc;
  if lReferenceRight <= 0 then Exit;
  lTolerance := Max((fToUtc - fFromUtc) * 0.03,
    Max(1, fLiveReloadTimer.Interval) * 2.0 / MSecsPerDay);
  Result := fToUtc >= lReferenceRight - lTolerance;
end;

procedure TRecorderSqlTrendView.RequestInteractiveLiveReload;
const
  CInteractiveReloadThrottleMs = 500;
var
  lNow: QWord;
begin
  if (fComponent = nil) or
    (fComponent.TimeMode <> sttmFixedFromToCurrentUtc) or
    (not Showing) then Exit;
  lNow := GetTickCount64;
  if (fLastInteractiveReloadAt <> 0) and
    (lNow - fLastInteractiveReloadAt < CInteractiveReloadThrottleMs) then Exit;
  fLastInteractiveReloadAt := lNow;
  { Mouse movement is only a wake-up hint.  The existing single worker and
    fLoadPending coalesce repeated hints, so rapid movement cannot create a
    queue of SQL requests. }
  fLoadPending := True;
  if not (fZoomSelecting or fCursorDragging or fPanning) then
  begin
    fReloadTimer.Enabled := False;
    fReloadTimer.Enabled := True;
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
    lSelectedPart := Max(lSelectedPart, 0.10);
    fFromUtc := lOldFrom - lLeftPart / lSelectedPart * lRange;
    fToUtc := lOldTo + (1.0 - lRightPart) / lSelectedPart * lRange;
    ClampAntiZoomXRange;
  end;
  fManualXRange := True;
  ClampCurrentDateXRange;
  { Anti-zoom also establishes a user viewport.  In current-date mode the
    right edge may continue following new SQL points, but the expanded left
    edge must remain exactly where the user placed it. }
  fFollowCurrentDateRightEdge := CurrentDateRightEdgeVisible;
  MarkLineGeometryDirty;
  if (fComponent <> nil) and
    (fComponent.TimeMode = sttmLatestWindow) then
  begin
    { Re-query the selected viewport instead of enlarging the already
      downsampled geometry.  This preserves the recorder's one-second points
      in a short zoomed interval. }
    fForceFullReload := True;
    fLoadPending := True;
    fReloadTimer.Enabled := True;
  end;
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
  if not AZoomIn then
    lSelectedPart := Max(lSelectedPart, 0.10);
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
  if not AZoomIn then
    ClampAntiZoomYRange;
  MarkLineGeometryDirty;
end;

procedure TRecorderSqlTrendView.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var I, lEventIndex: Integer; lPlot: TRect;
begin
  inherited MouseDown(Button, Shift, X, Y);
  lPlot := GetPlotRect;
  fMouseAnchor := Point(X, Y);
  fMouseCurrent := fMouseAnchor;
  if Button = mbLeft then
  begin
    lEventIndex := EventIndexAtX(X, lPlot);
    if (lEventIndex >= 0) and (Y >= lPlot.Top) and (Y <= lPlot.Bottom) then
    begin
      PinEvent(lEventIndex);
      Exit;
    end;
    if fPinnedEventIndex >= 0 then
    begin
      fPinnedEventIndex := -1;
      fPinnedEventId := '';
      UpdateMeraEventButton;
      Invalidate;
    end;
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
var I, lDx, lDy, lOldHover: Integer; lPlot: TRect; lShift, lRange: Double;
begin
  inherited MouseMove(Shift, X, Y);
  if not (fZoomSelecting or fCursorDragging or fPanning) then
  begin
    if CurrentDateRightEdgeVisible then
      fFollowCurrentDateRightEdge := True;
    RequestInteractiveLiveReload;
  end;
  lPlot := GetPlotRect;
  lOldHover := fHoveredEventIndex;
  if (not fZoomSelecting) and (not fCursorDragging) and (not fPanning) and
    (Y >= lPlot.Top) and (Y <= lPlot.Bottom) then
    fHoveredEventIndex := EventIndexAtX(X, lPlot)
  else
    fHoveredEventIndex := -1;
  { Подсказка над маркером: для неразрешимого события сразу видно, что данные
    замера не найдены, а не только после щелчка. }
  if (fHoveredEventIndex >= 0) and IsUnresolvedEvent(fHoveredEventIndex) then
  begin
    Hint := UnresolvedEventStatusText;
    ShowHint := True;
  end
  else
  begin
    Hint := '';
    ShowHint := False;
  end;
  if lOldHover <> fHoveredEventIndex then
  begin
    UpdateMeraEventButton;
    RequestMouseRepaint;
  end;
  if fPanning then
    Cursor := crSizeAll
  else if fCursorEnabled and (Y >= lPlot.Top) and (Y <= lPlot.Bottom) and
    (((fCursorVisible) and
      (Abs(X - fCursorPoint.X) <= CSqlTrendCursorGrabPixels)) or
     (DoubleCursorMode and fCursor2Visible and
      (Abs(X - fCursor2Point.X) <= CSqlTrendCursorGrabPixels))) then
    Cursor := crSizeWE
  else if fHoveredEventIndex >= 0 then
    Cursor := crHandPoint
  else
    Cursor := crDefault;
  if fZoomSelecting then
  begin
    if fZoomMode in [stzmX, stzmXY] then
      fMouseCurrent.X := EnsureRange(X, lPlot.Left, lPlot.Right);
    if fZoomMode in [stzmY, stzmXY] then
      fMouseCurrent.Y := EnsureRange(Y, lPlot.Top, lPlot.Bottom);
    RequestMouseRepaint;
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
    RequestMouseRepaint;
  end
  else if fPanning then
  begin
    lDx := X - fMouseAnchor.X;
    lDy := Y - fMouseAnchor.Y;
    if lDx <> 0 then
      fManualXRange := True;
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
    MarkLineGeometryDirty;
    RequestMouseRepaint;
  end;
end;

procedure TRecorderSqlTrendView.MouseLeave;
begin
  inherited MouseLeave;
  if fZoomSelecting or fPanning or fCursorDragging then Exit;
  Cursor := crDefault;
  fHoveredEventIndex := -1;
  Hint := '';
  ShowHint := False;
  UpdateMeraEventButton;
  if not fCursorEnabled then
    fCursorVisible := False;
  Invalidate;
end;

procedure TRecorderSqlTrendView.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  lLeft, lRight, lTop, lBottom: Integer;
  lPlot: TRect;
  lHorizontalZoomIn, lVerticalZoomIn, lHorizontalReady,
    lVerticalReady: Boolean;
  lShowEventPopup: Boolean;
  lPopupPoint: TPoint;
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
    lHorizontalZoomIn := fMouseCurrent.X > fMouseAnchor.X;
    lVerticalZoomIn := fMouseCurrent.Y > fMouseAnchor.Y;
    if lHorizontalReady then
      ApplyHorizontalZoom(lLeft, lRight, lHorizontalZoomIn, lPlot);
    if lVerticalReady then
      ApplyVerticalZoom(lTop, lBottom, lVerticalZoomIn, lPlot);
    if lHorizontalReady or lVerticalReady then
      LoadAxisControls;
    fZoomMode := stzmNone;
    fFollowCurrentDateRightEdge := CurrentDateRightEdgeVisible;
    RequestInteractiveLiveReload;
    Invalidate;
  end
  else if (Button = mbRight) and fPanning then
  begin
    lShowEventPopup := (Abs(X - fMouseAnchor.X) <= 3) and
      (Abs(Y - fMouseAnchor.Y) <= 3) and
      (X >= lPlot.Left) and (X <= lPlot.Right) and
      (Y >= lPlot.Top) and (Y <= lPlot.Bottom);
    fPanning := False;
    MouseCapture := False;
    Cursor := crDefault;
    fFollowCurrentDateRightEdge := CurrentDateRightEdgeVisible;
    RequestInteractiveLiveReload;
    LoadAxisControls;
    Invalidate;
    if fLoadPending then fReloadTimer.Enabled := True;
    if lShowEventPopup then
    begin
      UpdateEventFilterMenu;
      lPopupPoint := ClientToScreen(Point(X, Y));
      fEventPopup.PopUp(lPopupPoint.X, lPopupPoint.Y);
    end;
  end;
  if (not fZoomSelecting) and (not fCursorDragging) and (not fPanning) then
  begin
    if (X >= lPlot.Left) and (X <= lPlot.Right) and
      (Y >= lPlot.Top) and (Y <= lPlot.Bottom) then
      fHoveredEventIndex := EventIndexAtX(X, lPlot)
    else
      fHoveredEventIndex := -1;
    if fHoveredEventIndex >= 0 then
      Cursor := crHandPoint
    else
      Cursor := crDefault;
    UpdateMeraEventButton;
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

function TRecorderSqlTrendView.EventIndexAtX(AX: Integer;
  const APlot: TRect): Integer;
var
  I, lEventX, lDistance, lBestDistance: Integer;
begin
  Result := -1;
  if (fComponent = nil) or (not fComponent.ShowEvents) then Exit;
  if (fToUtc <= fFromUtc) or (AX < APlot.Left - CSqlTrendCursorGrabPixels) or
    (AX > APlot.Right + CSqlTrendCursorGrabPixels) then Exit;
  lBestDistance := CSqlTrendCursorGrabPixels + 1;
  for I := 0 to High(fEvents) do
  begin
    if not EventVisible(I) then Continue;
    lEventX := APlot.Left + Round((fEvents[I].StartedAtUtc - fFromUtc) /
      (fToUtc - fFromUtc) * (APlot.Width - 1));
    lDistance := Abs(AX - lEventX);
    if lDistance < lBestDistance then
    begin
      Result := I;
      lBestDistance := lDistance;
    end;
  end;
end;

procedure TRecorderSqlTrendView.Paint;
var
  I, J, lBoxHeight,
    lBoxTop, lBoxLeft, lIntervalLeft, lIntervalRight, lAxisColumnWidth,
    lAxisColumnCount, lAxisRowCount: Integer;
  lAxis: TRecorderTrendAxis;
  lLine: TRecorderTrendLine;
  lPlot: TRect;
  lX, lY: Integer;
  lCursorUtc, lCursor2Utc, lDistance, lGridValue: Double;
  lGridIndex, lGridX, lGridY: Integer;
  lGridText: string;
  lCaption: string;
  lEventIndex, lEventX, lEventEndX, lEventBoxLeft, lEventBoxTop: Integer;
  lNearestDistance, lNearestValue: array of Double;
  lNearestFound: array of Boolean;
begin
  lNearestDistance := nil;
  lNearestValue := nil;
  lNearestFound := nil;
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
  if fComponent.ShowEvents and (fToUtc > fFromUtc) then
    for I := 0 to High(fEvents) do
    begin
      if not EventVisible(I) then Continue;
      lEventX := lPlot.Left + Round((fEvents[I].StartedAtUtc - fFromUtc) /
        (fToUtc - fFromUtc) * (lPlot.Width - 1));
      if fEvents[I].FinishedAtUtc > fEvents[I].StartedAtUtc then
        lEventEndX := lPlot.Left + Round((fEvents[I].FinishedAtUtc - fFromUtc) /
          (fToUtc - fFromUtc) * (lPlot.Width - 1))
      else
        lEventEndX := lEventX;
      if (lEventEndX < lPlot.Left) or (lEventX > lPlot.Right) then Continue;
      Canvas.Pen.Width := 1;
      Canvas.Pen.Style := psDash;
      if (I = fPinnedEventIndex) or (I = fHoveredEventIndex) then
        Canvas.Pen.Color := clBlue
      else if IsRecordingEvent(I) then
        Canvas.Pen.Color := $008080FF
      else
        Canvas.Pen.Color := clRed;
      Canvas.Line(EnsureRange(lEventX, lPlot.Left, lPlot.Right), lPlot.Top,
        EnsureRange(lEventX, lPlot.Left, lPlot.Right), lPlot.Bottom);
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Width := 3;
      Canvas.Line(EnsureRange(lEventX, lPlot.Left, lPlot.Right), lPlot.Top + 3,
        EnsureRange(Max(lEventX + 2, lEventEndX), lPlot.Left, lPlot.Right),
        lPlot.Top + 3);
    end;
  { Значок неразрешимого замера рисуется поверх линий, сдвинутый от маркера,
    чтобы не перекрывать полосу длительности события. }
  if fComponent.ShowEvents and (fToUtc > fFromUtc) then
    for I := 0 to High(fEvents) do
    begin
      if (not IsUnresolvedEvent(I)) or (not EventVisible(I)) then Continue;
      lEventX := lPlot.Left + Round((fEvents[I].StartedAtUtc - fFromUtc) /
        (fToUtc - fFromUtc) * (lPlot.Width - 1));
      if (lEventX < lPlot.Left) or (lEventX > lPlot.Right) then Continue;
      lEventBoxTop := Max(lPlot.Top + 5,
        Min(lPlot.Bottom - CEventIconSize - 4, lPlot.Top + 9));
      PaintNoDataBadge(Canvas, EnsureRange(lEventX + 4, lPlot.Left,
        Max(lPlot.Left, lPlot.Right - CEventIconSize - 1)), lEventBoxTop);
    end;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  GetAxisHeaderLayout(lPlot.Right, lAxisColumnWidth, lAxisColumnCount,
    lAxisRowCount);
  for I := 0 to fComponent.ActiveDisplay.AxisCount - 1 do
  begin
    lAxis := fComponent.ActiveDisplay.Axes[I];
    Canvas.Font.Color := TColor(lAxis.Color);
    Canvas.TextOut(8 + (I mod lAxisColumnCount) * lAxisColumnWidth,
      6 + (I div lAxisColumnCount) * (Canvas.TextHeight('Ag') + 2),
      AxisCaption(I));
  end;
  if fLineGeometryDirty then
    RebuildLineGeometry(lPlot);
  for I := 0 to High(fLineSegments) do
  begin
    lLine := fComponent.ActiveDisplay.Lines[fLineSegments[I].LineIndex];
    Canvas.Pen.Color := TColor(lLine.Color);
    Canvas.Pen.Width := Max(1, lLine.Width);
    Canvas.Line(fLineSegments[I].StartPoint.X,
      fLineSegments[I].StartPoint.Y, fLineSegments[I].EndPoint.X,
      fLineSegments[I].EndPoint.Y);
  end;
  for I := 0 to High(fLineMarkers) do
  begin
    lLine := fComponent.ActiveDisplay.Lines[fLineMarkers[I].LineIndex];
    Canvas.Brush.Color := TColor(lLine.Color);
    Canvas.Brush.Style := bsSolid;
    lX := fLineMarkers[I].Point.X;
    lY := fLineMarkers[I].Point.Y;
    Canvas.Ellipse(lX - 2, lY - 2, lX + 3, lY + 3);
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
  { Подпись показывается только для явно выбранного щелчком события.
    Наведение подсвечивает пунктир, но не загромождает график подписями. }
  if fComponent.ShowEvents then
    lEventIndex := fPinnedEventIndex
  else
    lEventIndex := -1;
  if (lEventIndex >= 0) and (lEventIndex <= High(fEvents)) and
    EventVisible(lEventIndex) then
  begin
    lEventX := lPlot.Left + Round((fEvents[lEventIndex].StartedAtUtc - fFromUtc) /
      Max(1E-12, fToUtc - fFromUtc) * (lPlot.Width - 1));
    lCaption := EventCaption(lEventIndex);
    { Жёлтый фон у подписи — визуальное подтверждение иконки: замера в WinПОС
      нет, кнопка «Открыть в WinПОС» для этого события недоступна. }
    if IsUnresolvedEvent(lEventIndex) then
    begin
      lEventBoxLeft := EnsureRange(lEventX + CEventIconSize + 10, lPlot.Left,
        Max(lPlot.Left, lPlot.Right - Canvas.TextWidth(lCaption) - 12));
      lEventBoxTop := lPlot.Top + 10;
      Canvas.Brush.Color := $00C0FFFF;
      Canvas.Brush.Style := bsSolid;
      Canvas.Pen.Color := clMaroon;
      Canvas.Rectangle(lEventBoxLeft, lEventBoxTop,
        lEventBoxLeft + Canvas.TextWidth(lCaption) + 10,
        lEventBoxTop + Canvas.TextHeight(lCaption) + 8);
      PaintNoDataBadge(Canvas, lEventBoxLeft - CEventIconSize - 4,
        lEventBoxTop + 4);
    end
    else
    begin
      lEventBoxLeft := EnsureRange(lEventX + 8, lPlot.Left,
        Max(lPlot.Left, lPlot.Right - Canvas.TextWidth(lCaption) - 12));
      lEventBoxTop := lPlot.Top + 10;
      Canvas.Brush.Color := $00FFFFE8;
      Canvas.Brush.Style := bsSolid;
      Canvas.Pen.Color := clGray;
      Canvas.Rectangle(lEventBoxLeft, lEventBoxTop,
        lEventBoxLeft + Canvas.TextWidth(lCaption) + 10,
        lEventBoxTop + Canvas.TextHeight(lCaption) + 8);
    end;
    Canvas.Font.Color := clBlack;
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(lEventBoxLeft + 5, lEventBoxTop + 4, lCaption);
  end;
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(TRecorderSqlTrendComponent,
    TRecorderSqlTrendView);

end.
