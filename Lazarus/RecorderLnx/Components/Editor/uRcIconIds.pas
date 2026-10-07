unit uRcIconIds;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

function RcIconIndex(const AIconId: string): Integer;

const
  CIconIdTextLabel = 'text-label';
  CIconIdDigitalIndicator = 'digital-indicator';
  CIconIdOscillogram = 'oscillogram';
  CIconIdTrend = 'trend';
  CIconIdSqlTrend = 'sql-trend';
  CIconIdFrequencyResponse = 'frequency-response';
  CIconId3dView = '3d-view';
  CIconIdLissajous = 'lissajous';
  CIconIdPluginOscillogram = 'plugin-oscillogram';
  CIconIdDonut = 'donut';
  CIconIdSpectrum = 'spectrum';
  CIconIdImage = 'image';
  CIconIdButton = 'button';
  CIconIdInputField = 'input-field';
  CIconIdMeasurementSection = 'measurement-section';

  CIconSettings = 0;
  CIconRecord = 1;
  CIconView = 2;
  CIconStop = 3;
  CIconTrends = 5;
  CIconTextLabel = 6;
  CIconSpectrum = 7;
  CIconDigitalIndicator = 8;
  CIconButton = 10;
  CIconComboBox = 11;
  CIconAddress = 15;
  CIconEditForm = 15;
  CIconTagTable = 20;
  CIconDeviceRoot = 23;
  CIconDeviceController = 24;
  CIconDeviceModule = 25;
  CIconAdd = 27;
  CIconRemove = 28;
  CIconEdit = 29;
  CIconProperty = 30;
  CIconHardwareCurve = 31;
  CIconChannelCurve = 32;
  CIconSearch = 33;
  CIconFolderOpen = 34;
  CIconLeft = 35;
  CIconRight = 36;
  CIconRunWp = 37;
  CIconDeviceDisabled = 41;
  CIconDeviceControllerState = 42;
  CIconSaveConfigAs = 48;
  CIconOscillogram = 49;
  CIconZeroBalance = 51;
  CIconInactiveTag = 54;
  CIconHardwareCurveRead = 57;
  CIconSaveConfig = 58;
  CIconImageComponent = 59;
  CIconMeasurementSection = 60;
  CIconDonut = 61;
  CIconInputField = 62;
  CIconSqlTrend = 63;
  CIconFrequencyResponse = 64;
  CIconLissajous = 65;
  CIconPluginOscillogram = 66;
  CIcon3dScene = 67;
  CIcon3dSelect = 68;
  CIcon3dPan = 69;
  CIcon3dCameraRotate = 70;
  CIcon3dZoom = 71;
  CIcon3dFitScene = 72;
  CIcon3dRotateFree = 73;
  CIcon3dRotateX = 74;
  CIcon3dRotateY = 75;
  CIcon3dRotateZ = 76;

  CRecorderOriginalImageCount = 15;
  CRecorderCommandImageCount = 77;
  CIconHardwareSource = CIconDeviceControllerState;
  CIconVirtualTag = CIconTagTable;

implementation

function RcIconIndex(const AIconId: string): Integer;
begin
  if SameText(AIconId, CIconIdTextLabel) then Result := CIconTextLabel
  else if SameText(AIconId, CIconIdDigitalIndicator) then Result := CIconDigitalIndicator
  else if SameText(AIconId, CIconIdOscillogram) then Result := CIconOscillogram
  else if SameText(AIconId, CIconIdTrend) then Result := CIconTrends
  else if SameText(AIconId, CIconIdSqlTrend) then Result := CIconSqlTrend
  else if SameText(AIconId, CIconIdFrequencyResponse) then Result := CIconFrequencyResponse
  else if SameText(AIconId, CIconId3dView) then Result := CIcon3dScene
  else if SameText(AIconId, CIconIdLissajous) then Result := CIconLissajous
  else if SameText(AIconId, CIconIdPluginOscillogram) then Result := CIconPluginOscillogram
  else if SameText(AIconId, CIconIdDonut) then Result := CIconDonut
  else if SameText(AIconId, CIconIdSpectrum) then Result := CIconSpectrum
  else if SameText(AIconId, CIconIdImage) then Result := CIconImageComponent
  else if SameText(AIconId, CIconIdButton) then Result := CIconButton
  else if SameText(AIconId, CIconIdInputField) then Result := CIconInputField
  else if SameText(AIconId, CIconIdMeasurementSection) then Result := CIconMeasurementSection
  else Result := -1;
end;

end.
