unit uOglChartSelectListener;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Controls, Math,
  uOglChartFrameListener, uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj,
  uOglChartAxis, uOglChartPage, uOglChartRenderer, uOglChartChart;

type
  /// <summary>
  /// Слушатель для управления выделением (Selection) и подсветкой (Hover) осей и страниц графика.
  /// Изменяет форму курсора при наведении на интерактивные элементы.
  /// </summary>
  TChartSelectListener = class(TChartFrameListener)
  public
    /// <summary>
    /// Конструктор.
    /// </summary>

    constructor Create; override;
    /// <summary>
    /// Выделяет оси и страницы при левом клике.
    /// Снимает выделение при клике на пустое пространство.
    /// </summary>

    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
    /// <summary>
    /// Подсвечивает элементы при наведении и изменяет форму курсора на руку (crHandPoint) при наведении на оси.
    /// </summary>

    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); override;
  end;

implementation
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
  lSelectedAxis: TChartAxis;
begin
  if not Enabled then Exit;
  // Обрабатываем только левый клик мыши
  if (Button = mbLeft) and Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;
    // 1. Проверяем попадание в текстовые метки (названия осей, подписи значений шкал)
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lRenderer.SelectedObject := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lRenderer.SelectedObject := lHit.Page;
      lControl.Redraw;
      // Не помечаем как Handled (Handled := False), чтобы сработал стандартный текстовый редактор в TOpenGLChartRenderer
      Exit;
    end;

    lModel := TChartModel(lControl.GetModel);
    // 2. Проверяем попадание в физическую вертикальную ось Y
    if lRenderer.GetAxisHitAt(lModel, X, Y, lSelectedAxis) then
    begin
      lRenderer.SelectedObject := lSelectedAxis;
      lControl.Redraw;
      Handled := True; // Прерываем дальнейшую обработку клика
      Exit;
    end;

    // 3. Проверяем попадание в область страницы (подложку)
    if Assigned(lModel) then
    begin
      for lIndex := 0 to lModel.ChildCount - 1 do
        if lModel.Children[lIndex] is TChartPage then
        begin
          lPage := TChartPage(lModel.Children[lIndex]);
          if not lPage.Locked then
          begin
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

    end;

    // Снимаем выделение полностью, если кликнули по пустому фону графика
    if Assigned(lRenderer.SelectedObject) and
       ((lRenderer.SelectedObject is TChartPage) or (lRenderer.SelectedObject is TChartAxis)) then
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
  lSelectedAxis: TChartAxis;
begin
  if not Enabled then Exit;
  if Supports(ASender, IChartControl, lControl) then
  begin
    lRenderer := TOpenGLChartRenderer(lControl.GetRenderer);
    if not Assigned(lRenderer) then Exit;
    lNewHover := nil;
    // 1. Поиск текстовых меток под курсором
    if lRenderer.GetTextHitAt(X, Y, lHit) then
    begin
      if Assigned(lHit.Axis) and not lHit.Axis.Locked then
        lNewHover := lHit.Axis
      else if Assigned(lHit.Page) and not lHit.Page.Locked then
        lNewHover := lHit.Page;
    end;

    // 2. Поиск попадания на физическую линию оси Y
    if not Assigned(lNewHover) then
    begin
      lModel := TChartModel(lControl.GetModel);
      if Assigned(lModel) and lRenderer.GetAxisHitAt(lModel, X, Y, lSelectedAxis) then
        lNewHover := lSelectedAxis;
    end;

    // 3. Поиск страницы под курсором
    if not Assigned(lNewHover) then
    begin
      lModel := TChartModel(lControl.GetModel);
      if Assigned(lModel) then
      begin
        for lIndex := 0 to lModel.ChildCount - 1 do
          if lModel.Children[lIndex] is TChartPage then
          begin
            lPage := TChartPage(lModel.Children[lIndex]);
            if not lPage.Locked then
            begin
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

    end;

    // Если состояние наведенного объекта изменилось, обновляем рендерер и перерисовываем чарт
    if lRenderer.HoveredObject <> lNewHover then
    begin
      lRenderer.HoveredObject := lNewHover;
      lControl.Redraw;
    end;

    // Управление формой курсора для осей
    if lNewHover is TChartAxis then
      TControl(ASender).Cursor := crHandPoint
    else if TControl(ASender).Cursor = crHandPoint then
      TControl(ASender).Cursor := crDefault;
  end;

end;

end.

