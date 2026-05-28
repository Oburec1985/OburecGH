unit uOglChartFrameListener;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, LCLType, Math,
  uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj, uOglChartAxis, uOglChartPage,
  uOglChartTrend, uOglChartRenderer, uOglChartChart;

type
  { TChartFrameListener
    Р‘Р°Р·РѕРІС‹Р№ РєР»Р°СЃСЃ СЃР»СѓС€Р°С‚РµР»СЏ СЃРѕР±С‹С‚РёР№ РєР°РґСЂР° Рё РјС‹С€Рё РґР»СЏ OglChart. }
  TChartFrameListener = class(TObject)
  private
    fEnabled: Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure FrameStarted(ASender: TObject); virtual;
    procedure FrameEnded(ASender: TObject); virtual;

    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    procedure MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean); virtual;

    procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); virtual;
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); virtual;

    property Enabled: Boolean read fEnabled write fEnabled;
  end;

  { TChartSelectListener
    РЎР»СѓС€Р°С‚РµР»СЊ РґР»СЏ РІС‹РґРµР»РµРЅРёСЏ Рё РїРѕРґСЃРІРµС‚РєРё РѕР±СЉРµРєС‚РѕРІ РіСЂР°С„РёРєР° (СЃС‚СЂР°РЅРёС†, РѕСЃРµР№) РїСЂРё РЅР°РІРµРґРµРЅРёРё РјС‹С€Рё Рё РєР»РёРєР°С…. }
  TChartSelectListener = class(TChartFrameListener)
  public
    constructor Create; override;
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
  end;

  { TChartPanZoomListener
    РЎР»СѓС€Р°С‚РµР»СЊ РґР»СЏ РїР°РЅРѕСЂР°РјРёСЂРѕРІР°РЅРёСЏ (РїРµСЂРµС‚Р°СЃРєРёРІР°РЅРёСЏ РїСЂР°РІРѕР№ РєРЅРѕРїРєРѕР№ РјС‹С€Рё) Рё РјР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёСЏ (РєРѕР»РµСЃРёРєРѕРј РјС‹С€Рё). }
  TChartPanZoomListener = class(TChartFrameListener)
  private
    fIsPanning: Boolean;
    fLastX: Integer;
    fLastY: Integer;
    fActivePage: TChartPage;
    fResizingBorder: Integer;
    fMovingPage: Boolean;
    fIsResizing: Boolean;
    fSnapSensitivity: Integer;
    fIsZoomSelecting: Boolean;
    fZoomStartX: Integer;
    fZoomStartY: Integer;
  public
    constructor Create; override;
    property SnapSensitivity: Integer read fSnapSensitivity write fSnapSensitivity;
    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    procedure MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean); override;
  end;

implementation

{ TChartFrameListener }

constructor TChartFrameListener.Create;
begin
  inherited Create;
  fEnabled := True;
end;

destructor TChartFrameListener.Destroy;
begin
  inherited Destroy;
end;

procedure TChartFrameListener.FrameStarted(ASender: TObject);
begin
end;

procedure TChartFrameListener.FrameEnded(ASender: TObject);
begin
end;

procedure TChartFrameListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean);
begin
end;

{ TChartSelectListener }

constructor TChartSelectListener.Create;
begin
  inherited Create;
end;

procedure TChartSelectListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
begin
  if not Enabled then Exit;

  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    // 1. РџСЂРѕРІРµСЂСЏРµРј РїРѕРїР°РґР°РЅРёРµ РІ С‚РµРєСЃС‚РѕРІС‹Рµ РјРµС‚РєРё (РѕСЃРё, Р·РЅР°С‡РµРЅРёСЏ)
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) then
        lRenderer.SelectedObject := lHit.Axis
      else if Assigned(lHit.Page) then
        lRenderer.SelectedObject := lHit.Page;
      lControl.Redraw;
      // РќРµ РїРѕРјРµС‡Р°РµРј РєР°Рє Handled, С‡С‚РѕР±С‹ СЃСЂР°Р±РѕС‚Р°Р» СЃС‚Р°РЅРґР°СЂС‚РЅС‹Р№ С‚РµРєСЃС‚РѕРІС‹Р№ СЂРµРґР°РєС‚РѕСЂ СЂРµРЅРґРµСЂР°!
      Exit;
    end;

    // 2. РџСЂРѕРІРµСЂСЏРµРј РїРѕРїР°РґР°РЅРёРµ РІ СЃР°РјСѓ СЃС‚СЂР°РЅРёС†Сѓ
    lModel := TChartModel(lControl.GetModel);
    if Assigned(lModel) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          lPageRect := lRenderer.GetPageRect(lPage);
          if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
             (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          begin
            lRenderer.SelectedObject := lPage;
            lControl.Redraw;
            Handled := True;
            Exit;
          end;
        end;
    end;

    // РЎРЅРёРјР°РµРј РІС‹РґРµР»РµРЅРёРµ, РµСЃР»Рё РєР»РёРєРЅСѓР»Рё РїРѕ РїСѓСЃС‚РѕРјСѓ РјРµСЃС‚Сѓ
    if Assigned(lRenderer.SelectedObject) then
    begin
      lRenderer.SelectedObject := nil;
      lControl.Redraw;
    end;
  end;
end;

procedure TChartSelectListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lHit: TChartTextHit;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lIndex: Integer;
  lNewHover: TChartBaseObject;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;

    lNewHover := nil;

    // 1. РџСЂРѕРІРµСЂСЏРµРј РїРѕРїР°РґР°РЅРёРµ РІ С‚РµРєСЃС‚РѕРІС‹Рµ РјРµС‚РєРё
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) then
        lNewHover := lHit.Axis
      else if Assigned(lHit.Page) then
        lNewHover := lHit.Page;
    end;

    // 2. Р•СЃР»Рё РјРµС‚РєР° РЅРµ РЅР°Р№РґРµРЅР°, РїСЂРѕРІРµСЂСЏРµРј СЃР°РјСѓ СЃС‚СЂР°РЅРёС†Сѓ
    if not Assigned(lNewHover) then
    begin
      lModel := TChartModel(lControl.GetModel);
      if Assigned(lModel) then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              lNewHover := lPage;
              Break;
            end;
          end;
      end;
    end;

    if lRenderer.HoveredObject <> lNewHover then
    begin
      lRenderer.HoveredObject := lNewHover;
      lControl.Redraw;
    end;
  end;
end;

procedure FitPageZoom(APage: TChartPage);
var
  lPageMinX, lPageMaxX: Double;
  lHasPageX: Boolean;

  procedure ProcessObject(AObject: TChartBaseObject; ACurrentAxis: TChartAxis);
  var
    lIndex, lPtIdx: Integer;
    lLine: TChartLineSeries;
    lBuff1d: cBuffTrend1d;
    lAxis: TChartAxis;
    lAxisMinY, lAxisMaxY: Double;
    lAxisMinX, lAxisMaxX: Double;
    lHasAxisY, lHasAxisX: Boolean;
  begin
    if not Assigned(AObject) then Exit;

    lAxis := ACurrentAxis;
    if AObject is TChartAxis then
    begin
      lAxis := TChartAxis(AObject);
      lAxisMinY := 1E30;
      lAxisMaxY := -1E30;
      lAxisMinX := 1E30;
      lAxisMaxX := -1E30;
      lHasAxisY := False;
      lHasAxisX := False;

      for lIndex := 0 to lAxis.ChildCount - 1 do
      begin
        if lAxis.Children[lIndex] is TChartLineSeries then
        begin
          lLine := TChartLineSeries(lAxis.Children[lIndex]);
          for lPtIdx := 0 to lLine.PointCount - 1 do
          begin
            lAxisMinY := Min(lAxisMinY, lLine.Points[lPtIdx].Y);
            lAxisMaxY := Max(lAxisMaxY, lLine.Points[lPtIdx].Y);
            lHasAxisY := True;

            if lAxis.UseOwnX then
            begin
              lAxisMinX := Min(lAxisMinX, lLine.Points[lPtIdx].X);
              lAxisMaxX := Max(lAxisMaxX, lLine.Points[lPtIdx].X);
              lHasAxisX := True;
            end
            else
            begin
              lPageMinX := Min(lPageMinX, lLine.Points[lPtIdx].X);
              lPageMaxX := Max(lPageMaxX, lLine.Points[lPtIdx].X);
              lHasPageX := True;
            end;
          end;
        end
        else if lAxis.Children[lIndex] is cBuffTrend1d then
        begin
          lBuff1d := cBuffTrend1d(lAxis.Children[lIndex]);
          for lPtIdx := 0 to lBuff1d.Count - 1 do
          begin
            lAxisMinY := Min(lAxisMinY, lBuff1d.Values[lPtIdx]);
            lAxisMaxY := Max(lAxisMaxY, lBuff1d.Values[lPtIdx]);
            lHasAxisY := True;

            if lAxis.UseOwnX then
            begin
              lAxisMinX := Min(lAxisMinX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
              lAxisMaxX := Max(lAxisMaxX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
              lHasAxisX := True;
            end
            else
            begin
              lPageMinX := Min(lPageMinX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
              lPageMaxX := Max(lPageMaxX, lBuff1d.X0 + lPtIdx * lBuff1d.DX);
              lHasPageX := True;
            end;
          end;
        end;
      end;

      if lHasAxisY then
      begin
        if Abs(lAxisMaxY - lAxisMinY) < 1E-9 then
        begin
          lAxisMinY := lAxisMinY - 1.0;
          lAxisMaxY := lAxisMaxY + 1.0;
        end;
        lAxis.MinValue := lAxisMinY;
        lAxis.MaxValue := lAxisMaxY;
      end;

      if lAxis.UseOwnX and lHasAxisX then
      begin
        if Abs(lAxisMaxX - lAxisMinX) < 1E-9 then
        begin
          lAxisMinX := lAxisMinX - 1.0;
          lAxisMaxX := lAxisMaxX + 1.0;
        end;
        lAxis.XMinValue := lAxisMinX;
        lAxis.XMaxValue := lAxisMaxX;
      end;
    end;

    for lIndex := 0 to AObject.ChildCount - 1 do
      if not (AObject is TChartAxis) or not (AObject.Children[lIndex] is TChartSeries) then
        ProcessObject(AObject.Children[lIndex], lAxis);
  end;

var
  lIdx: Integer;
begin
  lPageMinX := 1E30;
  lPageMaxX := -1E30;
  lHasPageX := False;

  for lIdx := 0 to APage.ChildCount - 1 do
    ProcessObject(APage.Children[lIdx], nil);

  if lHasPageX then
  begin
    if Abs(lPageMaxX - lPageMinX) < 1E-9 then
    begin
      lPageMinX := lPageMinX - 1.0;
      lPageMaxX := lPageMaxX + 1.0;
    end;
    APage.XMinValue := lPageMinX;
    APage.XMaxValue := lPageMaxX;
  end;
end;

{ TChartPanZoomListener }

constructor TChartPanZoomListener.Create;
begin
  inherited Create;
  fIsPanning := False;
  fActivePage := nil;
  fResizingBorder := 0;
  fMovingPage := False;
  fIsResizing := False;
  fSnapSensitivity := 5;
  fIsZoomSelecting := False;
  fZoomStartX := 0;
  fZoomStartY := 0;
end;

procedure TChartPanZoomListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect, lContentRect: TChartPixelRect;
  lIndex: Integer;
  lInnerIndex: Integer;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    if Button = mbLeft then
    begin
      // 1. Изменение размеров выделенной страницы
      if (fResizingBorder > 0) and Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
      begin
        fIsResizing := True;
        fActivePage := TChartPage(lRenderer.SelectedObject);

        for lInnerIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lInnerIndex] is TChartPage then
            TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;

        fLastX := X;
        fLastY := Y;
        Handled := True;
        Exit;
      end;

      // 2. Если зажат Ctrl, проверяем клик: внутри plot area (зум) или снаружи (перетаскивание страницы)
      if ssCtrl in Shift then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            lPageRect := lRenderer.GetPageRect(lPage);
            if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
               (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
            begin
              lContentRect := lRenderer.GetPageContentRect(lPage);
              if (X >= lContentRect.Left) and (X <= lContentRect.Right) and
                 (Y >= lContentRect.Top) and (Y <= lContentRect.Bottom) then
              begin
                // Клик внутри области построения - начинаем выделение зума
                fIsZoomSelecting := True;
                fZoomStartX := X;
                fZoomStartY := Y;
                fActivePage := lPage;
                Handled := True;
                Exit;
              end
              else
              begin
                // Клик вне области построения - перемещаем страницу
                fMovingPage := True;
                fActivePage := lPage;

                for lInnerIndex := 0 to lModel.ChildCount - 1 do
                  if lModel.Children[lInnerIndex] is TChartPage then
                    TChartPage(lModel.Children[lInnerIndex]).Align := cpaNone;

                fLastX := X;
                fLastY := Y;
                TControl(ASender).Cursor := crSizeAll;
                Handled := True;
                Exit;
              end;
            end;
          end;
      end;
    end;

    if (Button = mbRight) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          lPageRect := lRenderer.GetPageRect(lPage);
          if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
             (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          begin
            fIsPanning := True;
            fLastX := X;
            fLastY := Y;
            fActivePage := lPage;
            Handled := True;
            Exit;
          end;
        end;
    end;
  end;
end;

procedure TChartPanZoomListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPageRect: TChartPixelRect;
  lWidth, lHeight: Single;
  lXRange, lYRange: Double;
  dX, dY: Integer;
  dValX, dValY: Double;
  lIndex: Integer;
  lAxis: TChartAxis;
  lPage, lTempPage: TChartPage;
  lRect: TChartFloatRect;
  lTargetVal: Integer;
  lTargetLeft, lTargetTop, lTargetRight, lTargetBottom: Integer;
  lSnappedLeft, lSnappedRight, lSnappedTop, lSnappedBottom: Integer;
  lPageWidth, lPageHeight: Integer;
  lSelRect: TChartPixelRect;
  lContentRect: TChartPixelRect;

  function SnapX(APixelX: Integer; AExcludePage: TChartPage; AMaxDiff: Integer): Integer;
  var
    lIdx: Integer;
    lOtherPage: TChartPage;
    lOtherRect: TChartPixelRect;
  begin
    Result := APixelX;
    for lIdx := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIdx] is TChartPage then
      begin
        lOtherPage := TChartPage(lModel.Children[lIdx]);
        if lOtherPage <> AExcludePage then
        begin
          lOtherRect := lRenderer.GetPageRect(lOtherPage);
          if Abs(APixelX - lOtherRect.Left) <= AMaxDiff then
          begin
            Result := lOtherRect.Left;
            Exit;
          end;
          if Abs(APixelX - lOtherRect.Right) <= AMaxDiff then
          begin
            Result := lOtherRect.Right;
            Exit;
          end;
        end;
      end;
    if Abs(APixelX - Round(lModel.PageArea.Left * lWidth)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Left * lWidth)
    else if Abs(APixelX - Round(lModel.PageArea.Right * lWidth)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Right * lWidth);
  end;

  function SnapY(APixelY: Integer; AExcludePage: TChartPage; AMaxDiff: Integer): Integer;
  var
    lIdx: Integer;
    lOtherPage: TChartPage;
    lOtherRect: TChartPixelRect;
  begin
    Result := APixelY;
    for lIdx := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIdx] is TChartPage then
      begin
        lOtherPage := TChartPage(lModel.Children[lIdx]);
        if lOtherPage <> AExcludePage then
        begin
          lOtherRect := lRenderer.GetPageRect(lOtherPage);
          if Abs(APixelY - lOtherRect.Top) <= AMaxDiff then
          begin
            Result := lOtherRect.Top;
            Exit;
          end;
          if Abs(APixelY - lOtherRect.Bottom) <= AMaxDiff then
          begin
            Result := lOtherRect.Bottom;
            Exit;
          end;
        end;
      end;
    if Abs(APixelY - Round(lModel.PageArea.Top * lHeight)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Top * lHeight)
    else if Abs(APixelY - Round(lModel.PageArea.Bottom * lHeight)) <= AMaxDiff then
      Result := Round(lModel.PageArea.Bottom * lHeight);
  end;

begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    lWidth := Max(1.0, TControl(ASender).Width);
    lHeight := Max(1.0, TControl(ASender).Height);

    // 0. Состояние выделения области зумирования (Ctrl + Drag)
    if fIsZoomSelecting and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lSelRect.Left := Max(lContentRect.Left, Min(fZoomStartX, X));
      lSelRect.Right := Min(lContentRect.Right, Max(fZoomStartX, X));
      lSelRect.Top := Max(lContentRect.Top, Min(fZoomStartY, Y));
      lSelRect.Bottom := Min(lContentRect.Bottom, Max(fZoomStartY, Y));

      lRenderer.SelectionRectActive := True;
      lRenderer.SelectionRect := lSelRect;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 1. Состояние перетаскивания изменения размеров границы страницы
    if fIsResizing and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;

      lPageRect := lRenderer.GetPageRect(fActivePage);
      lRect := fActivePage.FloatRect;

      case fResizingBorder of
        1: // Левая граница
          begin
            lTargetVal := SnapX(lPageRect.Left + dX, fActivePage, fSnapSensitivity);
            lRect.Left := Min(lRect.Right - 0.05, lTargetVal / lWidth);
          end;
        2: // Правая граница
          begin
            lTargetVal := SnapX(lPageRect.Right + dX, fActivePage, fSnapSensitivity);
            lRect.Right := Max(lRect.Left + 0.05, lTargetVal / lWidth);
          end;
        3: // Верхняя граница
          begin
            lTargetVal := SnapY(lPageRect.Top + dY, fActivePage, fSnapSensitivity);
            lRect.Top := Min(lRect.Bottom - 0.05, lTargetVal / lHeight);
          end;
        4: // Нижняя граница
          begin
            lTargetVal := SnapY(lPageRect.Bottom + dY, fActivePage, fSnapSensitivity);
            lRect.Bottom := Max(lRect.Top + 0.05, lTargetVal / lHeight);
          end;
      end;
      fActivePage.FloatRect := lRect;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 2. Состояние перемещения страницы (с зажатым Ctrl)
    if fMovingPage and Assigned(fActivePage) then
    begin
      dX := X - fLastX;
      dY := Y - fLastY;

      lPageRect := lRenderer.GetPageRect(fActivePage);
      lTargetLeft := lPageRect.Left + dX;
      lTargetTop := lPageRect.Top + dY;

      // Примагничивание по X (левая или правая граница)
      lSnappedLeft := SnapX(lTargetLeft, fActivePage, fSnapSensitivity);
      if lSnappedLeft <> lTargetLeft then
        lTargetLeft := lSnappedLeft
      else
      begin
        lTargetRight := lPageRect.Right + dX;
        lSnappedRight := SnapX(lTargetRight, fActivePage, fSnapSensitivity);
        if lSnappedRight <> lTargetRight then
          lTargetLeft := lSnappedRight - (lPageRect.Right - lPageRect.Left);
      end;

      // Примагничивание по Y (верхняя или нижняя граница)
      lSnappedTop := SnapY(lTargetTop, fActivePage, fSnapSensitivity);
      if lSnappedTop <> lTargetTop then
        lTargetTop := lSnappedTop
      else
      begin
        lTargetBottom := lPageRect.Bottom + dY;
        lSnappedBottom := SnapY(lTargetBottom, fActivePage, fSnapSensitivity);
        if lSnappedBottom <> lTargetBottom then
          lTargetTop := lSnappedBottom - (lPageRect.Bottom - lPageRect.Top);
      end;

      lPageWidth := lPageRect.Right - lPageRect.Left;
      lPageHeight := lPageRect.Bottom - lPageRect.Top;

      lRect.Left := lTargetLeft / lWidth;
      lRect.Right := (lTargetLeft + lPageWidth) / lWidth;
      lRect.Top := lTargetTop / lHeight;
      lRect.Bottom := (lTargetTop + lPageHeight) / lHeight;

      fActivePage.FloatRect := lRect;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 3. Состояние обычного панорамирования графика правой кнопкой мыши
    if fIsPanning and Assigned(fActivePage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(fActivePage);
      lWidth := Max(1.0, lContentRect.Right - lContentRect.Left);
      lHeight := Max(1.0, lContentRect.Bottom - lContentRect.Top);

      dX := X - fLastX;
      dY := Y - fLastY;

      lXRange := fActivePage.XMaxValue - fActivePage.XMinValue;
      dValX := (dX / lWidth) * lXRange;
      fActivePage.XMinValue := fActivePage.XMinValue - dValX;
      fActivePage.XMaxValue := fActivePage.XMaxValue - dValX;

      for lIndex := 0 to fActivePage.ChildCount - 1 do
        if fActivePage.Children[lIndex] is TChartAxis then
        begin
          lAxis := TChartAxis(fActivePage.Children[lIndex]);
          lYRange := lAxis.MaxValue - lAxis.MinValue;
          dValY := (dY / lHeight) * lYRange;
          lAxis.MinValue := lAxis.MinValue + dValY;
          lAxis.MaxValue := lAxis.MaxValue + dValY;
        end;

      fLastX := X;
      fLastY := Y;
      lControl.Redraw;
      Handled := True;
      Exit;
    end;

    // 4. Обычное движение мыши: меняем курсор при наведении на границы выделенной страницы
    if Assigned(lRenderer.SelectedObject) and (lRenderer.SelectedObject is TChartPage) then
    begin
      lPage := TChartPage(lRenderer.SelectedObject);
      lPageRect := lRenderer.GetPageRect(lPage);

      fResizingBorder := 0;
      if (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
      begin
        if Abs(X - lPageRect.Left) <= 6 then
          fResizingBorder := 1
        else if Abs(X - lPageRect.Right) <= 6 then
          fResizingBorder := 2;
      end;
      
      if (fResizingBorder = 0) and (X >= lPageRect.Left) and (X <= lPageRect.Right) then
      begin
        if Abs(Y - lPageRect.Top) <= 6 then
          fResizingBorder := 3
        else if Abs(Y - lPageRect.Bottom) <= 6 then
          fResizingBorder := 4;
      end;

      if fResizingBorder in [1, 2] then
        TControl(ASender).Cursor := crSizeWE
      else if fResizingBorder in [3, 4] then
        TControl(ASender).Cursor := crSizeNS
      else if ssCtrl in Shift then
      begin
        // Если курсор внутри выделенной страницы с зажатым Ctrl
        if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          TControl(ASender).Cursor := crSizeAll
        else
          TControl(ASender).Cursor := crDefault;
      end
      else
        TControl(ASender).Cursor := crDefault;
    end
    else
    begin
      // Если выделенной страницы нет, но зажат Ctrl, меняем курсор над любой страницей
      lPage := nil;
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lTempPage := TChartPage(lModel.Children[lIndex]);
          lPageRect := lRenderer.GetPageRect(lTempPage);
          if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
             (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
          begin
            lPage := lTempPage;
            Break;
          end;
        end;

      if Assigned(lPage) and (ssCtrl in Shift) then
        TControl(ASender).Cursor := crSizeAll
      else
        TControl(ASender).Cursor := crDefault;
    end;
  end;
end;

procedure TChartPanZoomListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lContentRect: TChartPixelRect;
  lIndex: Integer;
  lAxis: TChartAxis;
  NewXMin, NewXMax, NewYMin, NewYMax: Double;
  lSelRect: TChartPixelRect;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    if fIsZoomSelecting and Assigned(fActivePage) then
    begin
      lRenderer.SelectionRectActive := False;
      fIsZoomSelecting := False;

      // 1. Полный масштаб при движении влево и вверх
      if (X < fZoomStartX) and (Y < fZoomStartY) then
      begin
        FitPageZoom(fActivePage);
        lControl.Redraw;
        Handled := True;
      end
      // 2. Приближение при движении вправо и вниз (размер рамки должен быть больше 2 пикселей во избежание случайных зумов при кликах)
      else if (X > fZoomStartX + 2) and (Y > fZoomStartY + 2) then
      begin
        lContentRect := lRenderer.GetPageContentRect(fActivePage);
        
        lSelRect.Left := Max(lContentRect.Left, fZoomStartX);
        lSelRect.Right := Min(lContentRect.Right, X);
        lSelRect.Top := Max(lContentRect.Top, fZoomStartY);
        lSelRect.Bottom := Min(lContentRect.Bottom, Y);

        if (lSelRect.Right > lSelRect.Left) and (lSelRect.Bottom > lSelRect.Top) then
        begin
          // Зум по X
          NewXMin := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Left, lContentRect.Left, lContentRect.Right);
          NewXMax := lRenderer.PixelToXValue(fActivePage, nil, lSelRect.Right, lContentRect.Left, lContentRect.Right);
          fActivePage.XMinValue := NewXMin;
          fActivePage.XMaxValue := NewXMax;

          // Зум по осям Y
          for lIndex := 0 to fActivePage.ChildCount - 1 do
            if fActivePage.Children[lIndex] is TChartAxis then
            begin
              lAxis := TChartAxis(fActivePage.Children[lIndex]);
              
              if lAxis.UseOwnX then
              begin
                NewXMin := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Left, lContentRect.Left, lContentRect.Right);
                NewXMax := lRenderer.PixelToXValue(fActivePage, lAxis, lSelRect.Right, lContentRect.Left, lContentRect.Right);
                lAxis.XMinValue := NewXMin;
                lAxis.XMaxValue := NewXMax;
              end;

              NewYMin := lRenderer.PixelToAxisValue(lAxis, lSelRect.Bottom, lContentRect.Bottom, lContentRect.Top);
              NewYMax := lRenderer.PixelToAxisValue(lAxis, lSelRect.Top, lContentRect.Bottom, lContentRect.Top);
              lAxis.MinValue := NewYMin;
              lAxis.MaxValue := NewYMax;
            end;

          lControl.Redraw;
          Handled := True;
        end;
      end
      else
      begin
        lControl.Redraw;
        Handled := True;
      end;
      
      fActivePage := nil;
      Exit;
    end;

    if Button = mbLeft then
    begin
      if fIsResizing or fMovingPage then
      begin
        fIsResizing := False;
        fMovingPage := False;
        fActivePage := nil;
        fResizingBorder := 0;
        TControl(ASender).Cursor := crDefault;
        Handled := True;
      end;
    end;

    if Button = mbRight then
    begin
      if fIsPanning then
      begin
        fIsPanning := False;
        fActivePage := nil;
        Handled := True;
      end;
    end;
  end;
end;

procedure TChartPanZoomListener.MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean);
var
  lRenderer: TOpenGLChartRenderer;
  lControl: IChartControl;
  lModel: TChartModel;
  lPage: TChartPage;
  lPageRect: TChartPixelRect;
  lContentRect: TChartPixelRect;
  lZoomFactor: Double;
  lMouseValX: Double;
  lMouseValY: Double;
  lIndex: Integer;
  lAxis: TChartAxis;
begin
  if not Enabled then Exit;

  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    lModel := TChartModel(lControl.GetModel);
    if not Assigned(lRenderer) or not Assigned(lModel) then Exit;

    // РќР°С…РѕРґРёРј СЃС‚СЂР°РЅРёС†Сѓ РїРѕРґ РјС‹С€РєРѕР№ РґР»СЏ РјР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёСЏ
    lPage := nil;
    for lIndex := 0 to lModel.ChildCount - 1 do
      if lModel.Children[lIndex] is TChartPage then
      begin
        lPageRect := lRenderer.GetPageRect(TChartPage(lModel.Children[lIndex]));
        if (X >= lPageRect.Left) and (X <= lPageRect.Right) and
           (Y >= lPageRect.Top) and (Y <= lPageRect.Bottom) then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          Break;
        end;
      end;

    if Assigned(lPage) then
    begin
      lContentRect := lRenderer.GetPageContentRect(lPage);
      if WheelDelta < 0 then
        lZoomFactor := 1.1
      else
        lZoomFactor := 1.0 / 1.1;

      // РњР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёРµ РїРѕ РѕСЃРё X РѕС‚РЅРѕСЃРёС‚РµР»СЊРЅРѕ РєСѓСЂСЃРѕСЂР° РјС‹С€Рё
      lMouseValX := lRenderer.PixelToXValue(lPage, nil, X, lContentRect.Left, lContentRect.Right);
      lPage.XMinValue := lMouseValX - (lMouseValX - lPage.XMinValue) * lZoomFactor;
      lPage.XMaxValue := lMouseValX + (lPage.XMaxValue - lMouseValX) * lZoomFactor;

      // РњР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёРµ РїРѕ РѕСЃСЏРј Y РѕС‚РЅРѕСЃРёС‚РµР»СЊРЅРѕ РєСѓСЂСЃРѕСЂР° РјС‹С€Рё
      for lIndex := 0 to lPage.ChildCount - 1 do
        if lPage.Children[lIndex] is TChartAxis then
        begin
          lAxis := TChartAxis(lPage.Children[lIndex]);
          lMouseValY := lRenderer.PixelToAxisValue(lAxis, Y, lContentRect.Bottom, lContentRect.Top);
          lAxis.MinValue := lMouseValY - (lMouseValY - lAxis.MinValue) * lZoomFactor;
          lAxis.MaxValue := lMouseValY + (lAxis.MaxValue - lMouseValY) * lZoomFactor;
        end;

      lControl.Redraw;
      Handled := True;
    end;
  end;
end;

end.
