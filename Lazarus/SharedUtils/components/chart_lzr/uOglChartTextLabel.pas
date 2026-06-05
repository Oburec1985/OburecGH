unit uOglChartTextLabel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, fpjson, uOglChartBaseObj, uOglChartDrawObj, uOglChartAxis, uOglChartTrend, uOglChartFontMng;

type
  { TChartTextLabel }
  // Текстовая метка, поддерживающая привязку к мировым или относительным координатам,
  // автоматический перенос строк (Word Wrap) по ширине и интерактивный ресайз/перенос.
  TChartTextLabel = class(cMoveObj)
  private
    fText: string;                       // Текст метки
    fIsWorldX: Boolean;                  // Флаг привязки координаты X к мировым координатам
    fIsWorldY: Boolean;                  // Флаг привязки координаты Y к мировым координатам
    fWorldX: Double;                     // Координата X в координатах мира (оси)
    fWorldY: Double;                     // Координата Y в координатах мира (оси)
    fAxis: TChartAxis;                   // Ссылка на ось Y для пересчета WorldY
    fWidth: Integer;                     // Ширина рамки в пикселях (для мирового режима)
    fHeight: Integer;                    // Высота рамки в пикселях (для мирового режима)
  protected
    function GetAxis: TChartAxis; virtual;
    procedure SetAxis(AValue: TChartAxis); virtual;
  public
    procedure AssignDefaultProperties; override;

    // Разбивает текст на логические строки на основе ширины рамки
    procedure GetWrappedLines(AFont: cOglFont; AMaxWidth: Integer; ALines: TStrings);

    // Поддержка сериализации (хотя сериализатор в проекте упрощенный, реализуем по правилам)
    procedure SaveJsonAttributes(AJson: TJSONObject); override;
    procedure LoadJsonAttributes(AJson: TJSONObject); override;

    property Text: string read fText write fText;
    property IsWorldX: Boolean read fIsWorldX write fIsWorldX;
    property IsWorldY: Boolean read fIsWorldY write fIsWorldY;
    property WorldX: Double read fWorldX write fWorldX;
    property WorldY: Double read fWorldY write fWorldY;
    property Axis: TChartAxis read GetAxis write SetAxis;
    property Width: Integer read fWidth write fWidth;
    property Height: Integer read fHeight write fHeight;
  end;

  TChartFlagLabel = class(TChartTextLabel)
  private
    fTrend: cBaseTrend;                  // Ссылка на тренд/линию графика
    fAttachToAllTrends: Boolean;         // Флаг привязки ко всем трендам на странице в одной X-координате
    fAnchorX: Double;                    // Координата X точки привязки на графике
  protected
    function GetAxis: TChartAxis; override;
  public
    procedure AssignDefaultProperties; override;

    procedure SaveJsonAttributes(AJson: TJSONObject); override;
    procedure LoadJsonAttributes(AJson: TJSONObject); override;

    property Trend: cBaseTrend read fTrend write fTrend;
    property AttachToAllTrends: Boolean read fAttachToAllTrends write fAttachToAllTrends;
    property AnchorX: Double read fAnchorX write fAnchorX;
  end;

// Вспомогательная функция интерполяции значения Y на тренде по X
function GetTrendValueAtX(ATrend: cBaseTrend; AX: Double; out AY: Double): Boolean;

implementation

// Простой парсер слов для Word Wrap
procedure SplitWords(const AText: string; AWords: TStrings);
var
  lWord: string;
  I: Integer;
begin
  AWords.Clear;
  lWord := '';
  for I := 1 to Length(AText) do
  begin
    if AText[I] = ' ' then
    begin
      if lWord <> '' then
      begin
        AWords.Add(lWord);
        lWord := '';
      end;
    end
    else
    begin
      lWord := lWord + AText[I];
    end;
  end;
  if lWord <> '' then
    AWords.Add(lWord);
end;

function GetTrendValueAtX(ATrend: cBaseTrend; AX: Double; out AY: Double): Boolean;
var
  lLine: cLineSeries;
  lBuff: cBuffTrend1d;
  lQueue: cBuffTrendQueue;
  I: Integer;
  lPt1, lPt2: TChartPoint;
  lIdx: Integer;
  lT: Double;
begin
  Result := False;
  AY := 0.0;
  if not Assigned(ATrend) then Exit;

  if ATrend is cLineSeries then
  begin
    lLine := cLineSeries(ATrend);
    if lLine.PointCount = 0 then Exit;
    if lLine.PointCount = 1 then
    begin
      AY := lLine.Points[0].Y;
      Exit(True);
    end;

    for I := 0 to lLine.PointCount - 2 do
    begin
      lPt1 := lLine.Points[I];
      lPt2 := lLine.Points[I + 1];
      if ((lPt1.X <= AX) and (AX <= lPt2.X)) or ((lPt2.X <= AX) and (AX <= lPt1.X)) then
      begin
        if Abs(lPt2.X - lPt1.X) < 1E-9 then
          AY := lPt1.Y
        else
          AY := lPt1.Y + (lPt2.Y - lPt1.Y) * (AX - lPt1.X) / (lPt2.X - lPt1.X);
        Exit(True);
      end;
    end;
    
    // Если вышли за рамки
    if AX < lLine.Points[0].X then
      AY := lLine.Points[0].Y
    else
      AY := lLine.Points[lLine.PointCount - 1].Y;
    Result := True;
  end
  else if ATrend is cBuffTrendQueue then
  begin
    lQueue := cBuffTrendQueue(ATrend);
    if lQueue.Count = 0 then Exit;
    if lQueue.Count = 1 then
    begin
      AY := lQueue.Points[0].Y;
      Exit(True);
    end;

    for I := 0 to lQueue.Count - 2 do
    begin
      lPt1 := lQueue.Points[I];
      lPt2 := lQueue.Points[I + 1];
      if ((lPt1.X <= AX) and (AX <= lPt2.X)) or ((lPt2.X <= AX) and (AX <= lPt1.X)) then
      begin
        if Abs(lPt2.X - lPt1.X) < 1E-9 then
          AY := lPt1.Y
        else
          AY := lPt1.Y + (lPt2.Y - lPt1.Y) * (AX - lPt1.X) / (lPt2.X - lPt1.X);
        Exit(True);
      end;
    end;

    if AX < lQueue.Points[0].X then
      AY := lQueue.Points[0].Y
    else
      AY := lQueue.Points[lQueue.Count - 1].Y;
    Result := True;
  end  else if ATrend is cBuffTrend1d then
  begin
    lBuff := cBuffTrend1d(ATrend);
    if lBuff.Count = 0 then Exit;
    if lBuff.Count = 1 then
    begin
      AY := lBuff.Values[0];
      Exit(True);
    end;

    if Abs(lBuff.DX) < 1E-9 then
    begin
      AY := lBuff.Values[0];
      Exit(True);
    end;

    lT := (AX - lBuff.X0) / lBuff.DX;
    lIdx := Floor(lT);
    if lIdx < 0 then
      lIdx := 0;
    if lIdx >= lBuff.Count - 1 then
      lIdx := lBuff.Count - 2;

    lT := lT - lIdx;
    AY := lBuff.Values[lIdx] + (lBuff.Values[lIdx + 1] - lBuff.Values[lIdx]) * lT;
    Result := True;
  end;
end;

{ TChartTextLabel }

function TChartTextLabel.GetAxis: TChartAxis;
begin
  Result := fAxis;
end;

procedure TChartTextLabel.SetAxis(AValue: TChartAxis);
begin
  fAxis := AValue;
end;

procedure TChartTextLabel.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'TextLabel';
  Caption := 'TextLabel';
  fText := 'Текстовая метка';
  fIsWorldX := False;
  fIsWorldY := False;
  fWorldX := 0.0;
  fWorldY := 0.0;
  fAxis := nil;
  fWidth := 100;
  fHeight := 50;
  // По умолчанию относительные координаты
  SetFloatRect(0.1, 0.1, 0.3, 0.25);
end;

procedure TChartTextLabel.GetWrappedLines(AFont: cOglFont; AMaxWidth: Integer; ALines: TStrings);
var
  lRawLines: TStringList;
  lLineIdx, lWordIdx: Integer;
  lRawLine, lWord, lCurrentLine: string;
  lWords: TStringList;
begin
  ALines.Clear;
  if AMaxWidth <= 0 then
    AMaxWidth := 10;

  lRawLines := TStringList.Create;
  lWords := TStringList.Create;
  try
    lRawLines.Text := fText;

    for lLineIdx := 0 to lRawLines.Count - 1 do
    begin
      lRawLine := lRawLines[lLineIdx];
      if lRawLine = '' then
      begin
        ALines.Add('');
        Continue;
      end;

      if AFont.TextPixelWidth(lRawLine) <= AMaxWidth then
      begin
        ALines.Add(lRawLine);
        Continue;
      end;

      lWords.Clear;
      SplitWords(lRawLine, lWords);

      lCurrentLine := '';
      for lWordIdx := 0 to lWords.Count - 1 do
      begin
        lWord := lWords[lWordIdx];
        if lCurrentLine = '' then
        begin
          lCurrentLine := lWord;
        end
        else
        begin
          if AFont.TextPixelWidth(lCurrentLine + ' ' + lWord) <= AMaxWidth then
          begin
            lCurrentLine := lCurrentLine + ' ' + lWord;
          end
          else
          begin
            ALines.Add(lCurrentLine);
            lCurrentLine := lWord;
          end;
        end;
      end;
      if lCurrentLine <> '' then
        ALines.Add(lCurrentLine);
    end;
  finally
    lRawLines.Free;
    lWords.Free;
  end;
end;

procedure TChartTextLabel.SaveJsonAttributes(AJson: TJSONObject);
begin
  inherited SaveJsonAttributes(AJson);
  AJson.Add('Text', fText);
  AJson.Add('IsWorldX', fIsWorldX);
  AJson.Add('IsWorldY', fIsWorldY);
  AJson.Add('WorldX', fWorldX);
  AJson.Add('WorldY', fWorldY);
  AJson.Add('Width', fWidth);
  AJson.Add('Height', fHeight);
end;

procedure TChartTextLabel.LoadJsonAttributes(AJson: TJSONObject);
begin
  inherited LoadJsonAttributes(AJson);
  if not Assigned(AJson) then Exit;
  if AJson.IndexOfName('Text') <> -1 then fText := AJson.Strings['Text'];
  if AJson.IndexOfName('IsWorldX') <> -1 then fIsWorldX := AJson.Booleans['IsWorldX'];
  if AJson.IndexOfName('IsWorldY') <> -1 then fIsWorldY := AJson.Booleans['IsWorldY'];
  if AJson.IndexOfName('WorldX') <> -1 then fWorldX := AJson.Floats['WorldX'];
  if AJson.IndexOfName('WorldY') <> -1 then fWorldY := AJson.Floats['WorldY'];
  if AJson.IndexOfName('Width') <> -1 then fWidth := AJson.Integers['Width'];
  if AJson.IndexOfName('Height') <> -1 then fHeight := AJson.Integers['Height'];
end;

{ TChartFlagLabel }

function TChartFlagLabel.GetAxis: TChartAxis;
begin
  Result := inherited GetAxis;
  if not Assigned(Result) then
  begin
    if Assigned(fTrend) and (fTrend.Parent is TChartAxis) then
      Result := TChartAxis(fTrend.Parent);
  end;
end;

procedure TChartFlagLabel.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'FlagLabel';
  Caption := 'FlagLabel';
  fText := 'Флаг';
  fIsWorldX := True;  // Координата X рамки метки в мире (при скролле движется вместе с графиком)
  fIsWorldY := True;  // Y рамки метки также в мире (при скролле движется вместе с графиком)
  fWorldX := 0.0;
  fWorldY := 0.0;
  fAnchorX := 0.0;
  fTrend := nil;
  fAttachToAllTrends := False;
  SetFloatRect(0.1, 0.05, 0.25, 0.12);
  fWidth := 100;
  fHeight := 30;
end;

procedure TChartFlagLabel.SaveJsonAttributes(AJson: TJSONObject);
begin
  inherited SaveJsonAttributes(AJson);
  AJson.Add('AttachToAllTrends', fAttachToAllTrends);
  AJson.Add('AnchorX', fAnchorX);
end;

procedure TChartFlagLabel.LoadJsonAttributes(AJson: TJSONObject);
begin
  inherited LoadJsonAttributes(AJson);
  if not Assigned(AJson) then Exit;
  if AJson.IndexOfName('AttachToAllTrends') <> -1 then 
    fAttachToAllTrends := AJson.Booleans['AttachToAllTrends'];
  if AJson.IndexOfName('AnchorX') <> -1 then
    fAnchorX := AJson.Floats['AnchorX'];
end;

end.
