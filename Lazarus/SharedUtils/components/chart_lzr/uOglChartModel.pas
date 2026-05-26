unit uOglChartModel;

{ Фасад объектной модели чарта.
  Реальные классы разнесены по модулям рядом с этим файлом:
  - uOglChartBaseObj: дерево и сериализационные точки расширения;
  - uOglChartDrawObj: координаты и базовое визуальное состояние;
  - uOglChartPage: страницы и их отступы/align;
  - uOglChartAxis: оси и масштабы;
  - uOglChartTrend: графики и буферные тренды;
  - uOglChartChart/uOglChartMng: корень модели и менеджер.

  Этот unit оставлен для совместимости старого кода: `uses uOglChartModel`
  продолжает открывать всю модель, но новая разработка должна подключать
  конкретные модули. }

{$mode objfpc}{$H+}

interface

uses
  uOglChartBaseObj,
  uOglChartDrawObj,
  uOglChartPage,
  uOglChartAxis,
  uOglChartTrend,
  uOglChartChart,
  uOglChartMng;

implementation

end.
