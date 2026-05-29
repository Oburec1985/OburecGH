unit uOglChartTextLabelTests;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, fpjson,
  uOglChartTypes, uOglChartBaseObj, uOglChartDrawObj, uOglChartPage,
  uOglChartAxis, uOglChartTrend, uOglChartTextLabel, uOglChartSerializer;

type
  { TChartTextLabelTest }
  TChartTextLabelTest = class(TTestCase)
  published
    // Тест создания и инициализации свойств TChartTextLabel
    procedure TestTextLabelInitialization;
    // Тест интерполяции TChartFlagLabel на линии тренда cTrend
    procedure TestFlagLabelTrendInterpolation;
    // Тест сериализации и десериализации меток и флагов в JSON
    procedure TestSerialization;
  end;

implementation

{ TChartTextLabelTest }

procedure TChartTextLabelTest.TestTextLabelInitialization;
var
  lLabel: TChartTextLabel;
begin
  lLabel := TChartTextLabel.Create;
  try
    lLabel.Text := 'Тестовая метка' + #13#10 + 'Вторая строка';
    lLabel.Width := 150;
    lLabel.Height := 50;
    lLabel.IsWorldX := True;
    lLabel.WorldX := 12.34;
    lLabel.IsWorldY := False;
    lLabel.SetFloatRect(0.1, 0.2, 0.3, 0.4);

    AssertEquals('Текст метки', 'Тестовая метка' + #13#10 + 'Вторая строка', lLabel.Text);
    AssertEquals('Ширина', 150, lLabel.Width);
    AssertEquals('Высота', 50, lLabel.Height);
    AssertTrue('IsWorldX', lLabel.IsWorldX);
    AssertEquals('WorldX', 12.34, lLabel.WorldX);
    AssertFalse('IsWorldY', lLabel.IsWorldY);
  finally
    lLabel.Free;
  end;
end;

procedure TChartTextLabelTest.TestFlagLabelTrendInterpolation;
var
  lTrend: cTrend;
  lFlag: TChartFlagLabel;
  lVal: Double;
begin
  lTrend := cTrend.Create;
  lFlag := TChartFlagLabel.Create;
  try
    lTrend.AssignDefaultProperties;
    lTrend.Smooth := False; // Линейный тренд
    lTrend.AddBeziePoint(0.0, 10.0);
    lTrend.AddBeziePoint(10.0, 20.0);
    lTrend.GenerateSplinePoints;

    lFlag.Trend := lTrend;
    lFlag.WorldX := 5.0;

    // В X = 5.0 значение Y должно быть ровно 15.0
    if GetTrendValueAtX(lTrend, 5.0, lVal) then
      AssertEquals('Интерполированное значение Y на X=5.0', 15.0, lVal)
    else
      Fail('Не удалось получить значение Y на тренде для X=5.0');
  finally
    lFlag.Free;
    lTrend.Free;
  end;
end;

procedure TChartTextLabelTest.TestSerialization;
var
  lSerializer: TJsonChartSerializer;
  lLabel, lLoadedLabel: TChartTextLabel;
  lJson: TJSONObject;
  lJsonStr: string;
begin
  lSerializer := TJsonChartSerializer.Create;
  lLabel := TChartTextLabel.Create;
  lJson := TJSONObject.Create;
  try
    lLabel.Text := 'Сохраняемый текст';
    lLabel.Width := 200;
    lLabel.Height := 80;
    lLabel.IsWorldX := True;
    lLabel.WorldX := 45.67;
    lLabel.IsWorldY := True;
    lLabel.WorldY := -1.23;

    // Сохраняем в JSON
    lLabel.SaveJsonAttributes(lJson);

    // Создаем новую метку и загружаем
    lLoadedLabel := TChartTextLabel.Create;
    try
      lLoadedLabel.LoadJsonAttributes(lJson);
      AssertEquals('Десериализованный текст', 'Сохраняемый текст', lLoadedLabel.Text);
      AssertEquals('Десериализованная ширина', 200, lLoadedLabel.Width);
      AssertEquals('Десериализованная высота', 80, lLoadedLabel.Height);
      AssertTrue('IsWorldX после загрузки', lLoadedLabel.IsWorldX);
      AssertEquals('WorldX после загрузки', 45.67, lLoadedLabel.WorldX);
      AssertTrue('IsWorldY после загрузки', lLoadedLabel.IsWorldY);
      AssertEquals('WorldY после загрузки', -1.23, lLoadedLabel.WorldY);
    finally
      lLoadedLabel.Free;
    end;
  finally
    lJson.Free;
    lLabel.Free;
    lSerializer.Free;
  end;
end;

initialization
  RegisterTest(TChartTextLabelTest);
end.
