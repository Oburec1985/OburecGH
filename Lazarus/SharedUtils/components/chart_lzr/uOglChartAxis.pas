unit uOglChartAxis;

{$mode objfpc}{$H+}
{$codepage UTF8}

{
  РњРѕРґСѓР»СЊ uOglChartAxis
  РћРїРёСЃР°РЅРёРµ: Р±Р°Р·РѕРІС‹Р№ РєР»Р°СЃСЃ cAxis (TChartAxis), РёСЃРїРѕР»СЊР·СѓРµРјС‹Р№ РґР»СЏ РѕСЃРµР№ РіСЂР°С„РёРєР° РІ РєРѕРјРїРѕРЅРµРЅС‚Рµ TOglChart.
            РҐСЂР°РЅРёС‚ РґРёР°РїР°Р·РѕРЅС‹ Р·РЅР°С‡РµРЅРёР№, РјР°СЃС€С‚Р°Р± Рё РїСЂРµСЃРµС‚С‹ РґР»СЏ Р·СѓРјР°.
}

interface

uses
  uOglChartDrawObj;

type
  { TChartAxisScale }
  // РўРёРї С€РєР°Р»РёСЂРѕРІР°РЅРёСЏ РѕСЃРё (Р»РёРЅРµР№РЅР°СЏ РёР»Рё Р»РѕРіР°СЂРёС„РјРёС‡РµСЃРєР°СЏ)
  TChartAxisScale = (casLinear, casLog10);

  { cAxis }
  /// <summary>
  /// РљР»Р°СЃСЃ РѕСЃРё РіСЂР°С„РёРєР°. РҐСЂР°РЅРёС‚ РґРёР°РїР°Р·РѕРЅС‹ Р·РЅР°С‡РµРЅРёР№, РјР°СЃС€С‚Р°Р± Рё РїСЂРµСЃРµС‚С‹
  /// РґР»СЏ СЃР±СЂРѕСЃР° РїРѕР»СЊР·РѕРІР°С‚РµР»СЊСЃРєРѕРіРѕ Р·СѓРјР°/РїР°РЅРѕСЂР°РјС‹.
  /// </summary>
  cAxis = class(cMoveObj)
  private
    fScale: TChartAxisScale;             // СЂРµР¶РёРј РјР°СЃС€С‚Р°Р±Р° РѕСЃРё Y (Р»РёРЅРµР№РЅС‹Р№ РёР»Рё Р»РѕРіР°СЂРёС„РјРёС‡РµСЃРєРёР№)
    fMinValue: Double;                   // РјРёРЅРёРјР°Р»СЊРЅРѕРµ Р·РЅР°С‡РµРЅРёРµ РѕСЃРё Y
    fMaxValue: Double;                   // РјР°РєСЃРёРјР°Р»СЊРЅРѕРµ Р·РЅР°С‡РµРЅРёРµ РѕСЃРё Y
    fUseOwnX: Boolean;                  // С„Р»Р°Рі РёСЃРїРѕР»СЊР·РѕРІР°РЅРёСЏ РЅРµР·Р°РІРёСЃРёРјРѕРіРѕ РґРёР°РїР°Р·РѕРЅР° X РґР»СЏ СЌС‚РѕР№ РѕСЃРё
    fXMinValue: Double;                 // РЅРµР·Р°РІРёСЃРёРјС‹Р№ РјРёРЅРёРјСѓРј X
    fXMaxValue: Double;                 // РЅРµР·Р°РІРёСЃРёРјС‹Р№ РјР°РєСЃРёРјСѓРј X
    fXScale: TChartAxisScale;            // РЅРµР·Р°РІРёСЃРёРјС‹Р№ РјР°СЃС€С‚Р°Р± X (Р»РёРЅРµР№РЅС‹Р№ РёР»Рё Р»РѕРіР°СЂРёС„РјРёС‡РµСЃРєРёР№)
    fPresetMinValue: Double;             // СЃРѕС…СЂР°РЅС‘РЅРЅС‹Р№ РјРёРЅРёРјСѓРј РѕСЃРё Y
    fPresetMaxValue: Double;             // СЃРѕС…СЂР°РЅС‘РЅРЅС‹Р№ РјР°РєСЃРёРјСѓРј РѕСЃРё Y
    fHasPresetRange: Boolean;            // РїСЂРёР·РЅР°Рє РЅР°Р»РёС‡РёСЏ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊСЃРєРѕРіРѕ РґРёР°РїР°Р·РѕРЅР° Y
  private
  public
    /// <summary>
    /// РЈСЃС‚Р°РЅР°РІР»РёРІР°РµС‚ СЃРІРѕР№СЃС‚РІР° РѕСЃРё РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ.
    /// </summary>
    procedure AssignDefaultProperties; override;

    /// <summary> РўРёРї С€РєР°Р»С‹ РѕСЃРё Y (Р»РёРЅРµР№РЅР°СЏ/Р»РѕРіР°СЂРёС„РјРёС‡РµСЃРєР°СЏ). </summary>
    property Scale: TChartAxisScale read fScale write fScale;
    /// <summary> РќРёР¶РЅСЏСЏ РіСЂР°РЅСЊ Y. </summary>
    property MinValue: Double read fMinValue write fMinValue;
    /// <summary> Р’РµСЂС…РЅСЏСЏ РіСЂР°РЅСЊ Y. </summary>
    property MaxValue: Double read fMaxValue write fMaxValue;
    /// <summary> Р¤Р»Р°Рі РЅР°Р»РёС‡РёСЏ СЃРѕР±СЃС‚РІРµРЅРЅРѕРіРѕ РґРёР°РїР°Р·РѕРЅР° РїРѕ РѕСЃРё X РґР»СЏ СЌС‚РѕР№ РѕСЃРё. </summary>
    property UseOwnX: Boolean read fUseOwnX write fUseOwnX;
    /// <summary> РњРёРЅРёРјР°Р»СЊРЅРѕРµ Р·РЅР°С‡РµРЅРёРµ РѕСЃРё X. </summary>
    property XMinValue: Double read fXMinValue write fXMinValue;
    /// <summary> РњР°РєСЃРёРјР°Р»СЊРЅРѕРµ Р·РЅР°С‡РµРЅРёРµ РѕСЃРё X. </summary>
    property XMaxValue: Double read fXMaxValue write fXMaxValue;
    /// <summary> РўРёРї РјР°СЃС€С‚Р°Р±РёСЂРѕРІР°РЅРёСЏ РѕСЃРё РїРѕ РѕСЃРё X. </summary>
    property XScale: TChartAxisScale read fXScale write fXScale;
    property PresetMinValue: Double read fPresetMinValue write fPresetMinValue;
    property PresetMaxValue: Double read fPresetMaxValue write fPresetMaxValue;
    property HasPresetRange: Boolean read fHasPresetRange write fHasPresetRange;
  end;

  TChartAxis = cAxis;

procedure ChartAxisApplyUserValue(AAxis: TChartAxis; AIsMin: Boolean; AValue: Double);

implementation

{ cAxis }

/// <summary>
/// Р—Р°РґР°С‘С‚ Р·РЅР°С‡РµРЅРёСЏ РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ РґР»СЏ РѕСЃРё: Р»РёРЅРµР№РЅС‹Р№ РјР°СЃС€С‚Р°Р±, РґРёР°РїР°Р·РѕРЅ [0..1] РґР»СЏ X Рё Y.
/// </summary>
procedure cAxis.AssignDefaultProperties;
begin
  inherited AssignDefaultProperties;
  Name := 'Axis';
  Caption := 'Axis';
  fScale := casLinear;
  fMinValue := 0;
  fMaxValue := 1;
  fUseOwnX := False;
  fXMinValue := 0;
  fXMaxValue := 1;
  fXScale := casLinear;
  fPresetMinValue := fMinValue;
  fPresetMaxValue := fMaxValue;
  fHasPresetRange := False;
end;

procedure ChartAxisApplyUserValue(AAxis: TChartAxis; AIsMin: Boolean; AValue: Double);
begin
  if AAxis = nil then
    Exit;
  if AIsMin then
  begin
    AAxis.MinValue := AValue;
    AAxis.PresetMinValue := AValue;
  end
  else
  begin
    AAxis.MaxValue := AValue;
    AAxis.PresetMaxValue := AValue;
  end;
  if AAxis.PresetMaxValue > AAxis.PresetMinValue then
    AAxis.HasPresetRange := True;
end;

end.
