unit uOglChartModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

{
  Модуль uOglChartModel
  Описание: Фасад объектной модели чарта. Объединяет все составные модули объектной модели:
            - uOglChartBaseObj: базовое дерево объектов и сериализация;
            - uOglChartDrawObj: координаты и визуальные свойства;
            - uOglChartPage: страницы разметки и выравнивание;
            - uOglChartAxis: оси и масштабирование;
            - uOglChartTrend: графики и буферы данных;
            - uOglChartTextLabel: текстовые метки и выноски;
            - uOglChartChart/uOglChartMng: корень модели и менеджер.

  Этот модуль оставлен для обратной совместимости со старыми вызовами 'uses uOglChartModel',
  но новые модули рекомендуется подключать индивидуально.
}

interface

uses
  uOglChartBaseObj,
  uOglChartDrawObj,
  uOglChartPage,
  uOglChartAxis,
  uOglChartTrend,
  uOglChartTextLabel,
  uOglChartChart,
  uOglChartMng;

implementation

end.
