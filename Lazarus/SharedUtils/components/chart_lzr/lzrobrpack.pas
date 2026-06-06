{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit LzrObrPack;

{
  Модуль lzrobrpack
  Описание: Пакет регистрации визуальных компонентов OGlChart для среды Lazarus LCL.
}

{$warn 5023 off : no warning about unused units}
interface

uses
  uOglChart, uOglChartBaseObj, uOglChartDrawObj, uOglChartPage, uOglChartAxis, 
  uOglChartTrend, uOglChartTextLabel, uOglChartTextLabelTests, uOglChartChart, 
  uOglChartMng, uOglChartModel, uOglChartRenderer, uOglChartFontMng, 
  uOglChartLog, uOglChartSerializer, uOglChartTypes, uOglChartFrameListener, 
  uOglChartSelectListener, uOglChartPanZoomListener, 
  uOglChartPageGeometryListener, uOglChartVertexEditListener, 
  uOglChartLabelEditListener, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uOglChart', @uOglChart.Register);
end;

initialization
  RegisterPackage('LzrObrPack', @Register);
end.
