unit uRecorderSpectrumView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Graphics,
  uOglChart, uOglChartChart, uOglChartPage, uOglChartAxis,
  uOglChartTrend, uOglChartTypes, uOglChartDrawObj,
  uRecorderFormModel, uRecorderTags, uRecorderVisualControl, 
  uRecorderSpectrumEngine, uRecorderSpectrumRuntime, uRecorderCoreServices, SyncObjs;

type
  TBufferedFrame = record
    TagName: string;
    Rms: array of Double;
    PhaseRad: array of Double;
    FrequencyStepHz: Double;
    HasNewData: Boolean;
  end;

  { TRecorderSpectrumView
    Визуальный компонент отображения спектра на базе TOglChart. }
  TRecorderSpectrumView = class(TPanel, IVForm)
  private
    fComponent: TRecorderSpectrumComponent;
    fChart: TOglChart;
    fModel: TChartModel;
    fPage: TChartPage;
    fAxisY: TChartAxis;
    fSeriesList: TList; // Список серий cBuffTrend1d
    fTagRegistry: TRecorderTagRegistry;
    fToken: Integer;
    fBufferedFrames: array of TBufferedFrame;
    fLock: TCriticalSection;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    procedure ClearSeries;
    function GetSpectrumColor(AIndex: Integer): TColor;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    { IVForm }
    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

implementation

constructor TRecorderSpectrumView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  ParentBackground := False;
  Color := clWhite;
  fSeriesList := TList.Create;
  fLock := TCriticalSection.Create;
end;

destructor TRecorderSpectrumView.Destroy;
begin
  if fToken <> 0 then
  begin
    if (fTagRegistry <> nil) and (fTagRegistry.EventBus <> nil) then
      fTagRegistry.EventBus.Unsubscribe(fToken);
    fToken := 0;
  end;
  ClearSeries;
  FreeAndNil(fSeriesList);
  FreeAndNil(fLock);
  inherited Destroy;
end;

procedure TRecorderSpectrumView.ClearSeries;

begin

  if Assigned(fSeriesList) then

    fSeriesList.Clear;

end;



function TRecorderSpectrumView.GetSpectrumColor(AIndex: Integer): TColor;
const
  CColors: array[0..7] of TColor = (
    $FF0000, // Синий
    $00FF00, // Зеленый
    $0000FF, // Красный
    $00FFFF, // Желтый
    $FF00FF, // Маджента
    $FFFF00, // Циан
    $808080, // Серый
    $FF8000  // Оранжевый
  );
begin
  Result := CColors[AIndex mod 8];
end;

procedure TRecorderSpectrumView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
var
  I: Integer;
  lSeries: cBuffTrend1d;
  lPageArea: TChartFloatRect;
  lFrame: TRecorderSpectrumFrame;
begin
  fComponent := TRecorderSpectrumComponent(AComponent);
  fTagRegistry := ATagRegistry;

  if fChart = nil then
  begin
    fChart := TOglChart.Create(Self);
    fChart.Parent := Self;
    fChart.Align := alClient;
    fChart.AutoResizeViewport := True;
    
    fModel := TChartModel.Create;
    fModel.BackgroundColor := $FFFFFFFF;
    lPageArea.Left := 0.002;
    lPageArea.Top := 0.004;
    lPageArea.Right := 0.998;
    lPageArea.Bottom := 0.996;
    fModel.PageArea := lPageArea;
    fModel.PageGapX := 0.004;
    fModel.PageGapY := 0.004;
    fChart.Model := fModel;
  end;

  fModel.ClearChildren;
  ClearSeries;

  fLock.Enter;
  try
    SetLength(fBufferedFrames, fComponent.TagNames.Count);
    for I := 0 to fComponent.TagNames.Count - 1 do
    begin
      fBufferedFrames[I].TagName := fComponent.TagNames[I];
      SetLength(fBufferedFrames[I].Rms, 0);
      SetLength(fBufferedFrames[I].PhaseRad, 0);
      fBufferedFrames[I].FrequencyStepHz := 0.0;
      fBufferedFrames[I].HasNewData := False;

      // Восстанавливаем последний рассчитанный кадр из кэша рантайм менеджера
      if TRecorderSpectrumRuntimeManager.Instance <> nil then
      begin
        lFrame.SourceTagName := '';
        if TRecorderSpectrumRuntimeManager.Instance.GetLastFrame(fComponent.TagNames[I], lFrame) then
        begin
          fBufferedFrames[I].FrequencyStepHz := lFrame.FrequencyStepHz;
          
          SetLength(fBufferedFrames[I].Rms, Length(lFrame.Rms));
          if Length(lFrame.Rms) > 0 then
            Move(lFrame.Rms[0], fBufferedFrames[I].Rms[0], Length(lFrame.Rms) * SizeOf(Double));
            
          SetLength(fBufferedFrames[I].PhaseRad, Length(lFrame.PhaseRad));
          if Length(lFrame.PhaseRad) > 0 then
            Move(lFrame.PhaseRad[0], fBufferedFrames[I].PhaseRad[0], Length(lFrame.PhaseRad) * SizeOf(Double));
            
          fBufferedFrames[I].HasNewData := True;
        end;
      end;
    end;
  finally
    fLock.Leave;
  end;

  fPage := TChartPage.Create;
  fPage.Name := 'SpectrumPage';
  fPage.Align := cpaAuto;
  fPage.FillColor := $FFFFFFFF;
  fPage.BorderColor := $FF808080;
  
  // Настройка горизонтальной оси X на странице
  fPage.XMinValue := fComponent.RangeMinX;
  fPage.XMaxValue := fComponent.RangeMaxX;
  if fComponent.LgX then
    fPage.XScale := casLog10
  else
    fPage.XScale := casLinear;
    
  fModel.AddChild(fPage);
  fModel.AlignPagesAuto;

  // Настройка вертикальной оси Y
  fAxisY := TChartAxis.Create;
  fAxisY.Name := 'Amplitude';
  fAxisY.MinValue := fComponent.RangeMinY;
  fAxisY.MaxValue := fComponent.RangeMaxY;
  fAxisY.PresetMinValue := fComponent.RangeMinY;
  fAxisY.PresetMaxValue := fComponent.RangeMaxY;
  fAxisY.HasPresetRange := True;
  if fComponent.LgY then
    fAxisY.Scale := casLog10
  else
    fAxisY.Scale := casLinear;
  fPage.AddChild(fAxisY);

  // Создаем серии для выбранных каналов спектра
  for I := 0 to fComponent.TagNames.Count - 1 do
  begin
    lSeries := cBuffTrend1d.Create;
    lSeries.Name := fComponent.TagNames[I];
    lSeries.X0 := 0.0;
    lSeries.DX := 1.0;
    lSeries.Color := (GetSpectrumColor(I) and $00FFFFFF) or $FF000000;
    lSeries.Visible := True;
    fAxisY.AddChild(lSeries);
    fSeriesList.Add(lSeries);
  end;

  // Подписка на шину событий
  if fToken = 0 then
  begin
    if (fTagRegistry <> nil) and (fTagRegistry.EventBus <> nil) then
      fToken := fTagRegistry.EventBus.Subscribe(@HandleEvent);
  end;
  
  // Мгновенно выводим восстановленные из кэша данные
  RefreshControl(fTagRegistry, 0.0);

  fChart.Redraw;
  Invalidate;
end;

procedure TRecorderSpectrumView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  I, J: Integer;
  lSeries: cBuffTrend1d;
  lNeedsRedraw: Boolean;
begin
  lNeedsRedraw := False;
  
  fLock.Enter;
  try
    for I := 0 to Length(fBufferedFrames) - 1 do
    begin
      if fBufferedFrames[I].HasNewData then
      begin
        // Находим соответствующую серию по имени
        for J := 0 to fSeriesList.Count - 1 do
        begin
          lSeries := cBuffTrend1d(fSeriesList[J]);
          if SameText(lSeries.Name, fBufferedFrames[I].TagName) then
          begin
            lSeries.X0 := 0.0;
            lSeries.DX := fBufferedFrames[I].FrequencyStepHz;
            lSeries.ClearValues;
            if fComponent.ResultType = 0 then
              lSeries.AddValues(fBufferedFrames[I].Rms)
            else
              lSeries.AddValues(fBufferedFrames[I].PhaseRad);
            lNeedsRedraw := True;
            Break;
          end;
        end;
        fBufferedFrames[I].HasNewData := False;
      end;
    end;
  finally
    fLock.Leave;
  end;

  if lNeedsRedraw and (fChart <> nil) then
  begin
    fChart.Invalidate;
    fChart.Redraw;
  end;
end;

function TRecorderSpectrumView.GetChartControl: TOglChart;
begin
  Result := fChart;
end;

procedure TRecorderSpectrumView.HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
var
  lEventData: TRecorderSpectrumFrameEventData;
  I: Integer;
begin
  if not IsVisible then Exit;
  if (AEvent.Kind <> rceSpectrumFrame) or (not (AEvent.Data is TRecorderSpectrumFrameEventData)) then
    Exit;

  lEventData := TRecorderSpectrumFrameEventData(AEvent.Data);
  
  fLock.Enter;
  try
    for I := 0 to Length(fBufferedFrames) - 1 do
    begin
      if SameText(fBufferedFrames[I].TagName, AEvent.Name) then
      begin
        fBufferedFrames[I].FrequencyStepHz := lEventData.Frame.FrequencyStepHz;
        
        SetLength(fBufferedFrames[I].Rms, Length(lEventData.Frame.Rms));
        if Length(lEventData.Frame.Rms) > 0 then
          Move(lEventData.Frame.Rms[0], fBufferedFrames[I].Rms[0], 
            Length(lEventData.Frame.Rms) * SizeOf(Double));
            
        SetLength(fBufferedFrames[I].PhaseRad, Length(lEventData.Frame.PhaseRad));
        if Length(lEventData.Frame.PhaseRad) > 0 then
          Move(lEventData.Frame.PhaseRad[0], fBufferedFrames[I].PhaseRad[0], 
            Length(lEventData.Frame.PhaseRad) * SizeOf(Double));
            
        fBufferedFrames[I].HasNewData := True;
        Break;
      end;
    end;
  finally
    fLock.Leave;
  end;
end;

end.
