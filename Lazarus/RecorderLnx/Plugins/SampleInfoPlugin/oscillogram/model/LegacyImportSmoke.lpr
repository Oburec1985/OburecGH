program LegacyImportSmoke;
{$mode objfpc}{$H+}{$codepage UTF8}
uses SysUtils, fpjson, uOscModel, uOscLegacyImport;
procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage); end;
var lModel: TOscModel; lSection: TJSONObject; lError: string; lBefore: UTF8String;
begin
  lModel := TOscModel.Create; lSection := TJSONObject.Create;
  try
    lSection.Add('TagId', '9007199254740993'); lSection.Add('TagName', 'Датчик');
    lSection.Add('DisplayFormat', '0.000'); lSection.Add('BindingMode', '1');
    lSection.Add('TagOffset', '-3'); lSection.Add('OscXScale', '2.5');
    lSection.Add('OscYScale', '3'); lSection.Add('OscYOffset', '-4');
    lSection.Add('OscClosedInput', '1'); lSection.Add('OscAutoRangeEnabled', 'true');
    lSection.Add('OscXCursorEnabled', 'true'); lSection.Add('OscXCursorCount', '2');
    lSection.Add('OscLegendVisible', 'false'); lSection.Add('OscLevelCursorVisible', '1');
    lSection.Add('OscAxisCount', '2'); lSection.Add('OscAxis0Name', 'Левая');
    lSection.Add('OscAxis1Name', 'Правая'); lSection.Add('OscAxis1YScale', '5');
    lSection.Add('OscAxis1YOffset', '6'); lSection.Add('OscPrimaryAxisIndex', '1');
    lSection.Add('OscTriggerTag', 'Молоток'); lSection.Add('OscTriggerEnabled', 'true');
    lSection.Add('OscTriggerEdge', '1'); lSection.Add('OscTriggerLevel', '-0.75');
    lSection.Add('OscTriggerPreRollPercent', '35'); lSection.Add('OscLineCount', '2');
    lSection.Add('OscLine0TagId', '123456789012345'); lSection.Add('OscLine0TagName', 'Отклик');
    lSection.Add('OscLine0Color', '123'); lSection.Add('OscLine0Name', 'Произвольный');
    lSection.Add('OscLine0Visible', 'false'); lSection.Add('OscLine0AxisIndex', '1');
    lSection.Add('OscLine1TagName', 'Второй'); lSection.Add('OscLine1AxisIndex', '999');
    lSection.Add('FutureKey', TJSONObject.Create);
    Check(ImportOscLegacy(lSection.AsJSON, 'sample.oscillogram', lModel, lError), lError);
    Check((lModel.TagId = 9007199254740993) and (lModel.TagName = 'Датчик'), 'Primary ID/UTF8');
    Check((lModel.BindingMode = obAbsoluteTag) and (lModel.TagOffset = -3) and
      (lModel.DisplayFormat = '0.000'), 'Primary settings');
    Check((lModel.XScale = 2.5) and lModel.ClosedInput and lModel.AutoRangeEnabled, 'Range settings');
    Check(lModel.XCursorEnabled and (lModel.XCursorCount = 2) and
      not lModel.LegendVisible and lModel.LevelCursorVisible, 'Cursor/legend settings');
    Check((lModel.AxisCount = 2) and (lModel.PrimaryAxisIndex = 1) and
      (lModel.Axes[0].Name = 'Левая') and (lModel.Axes[0].YScale = 3) and
      (lModel.Axes[0].YOffset = -4) and (lModel.Axes[1].Name = 'Правая') and
      (lModel.Axes[1].YScale = 5) and (lModel.Axes[1].YOffset = 6), 'Axis settings/defaults');
    Check(lModel.TriggerEnabled and (lModel.TriggerTagName = 'Молоток') and
      (lModel.TriggerEdge = oeFalling) and (lModel.TriggerLevel = -0.75) and
      (lModel.TriggerPreRollPercent = 35), 'Trigger settings');
    Check((lModel.LineCount = 2) and (lModel.Lines[0].TagId = 123456789012345) and
      (lModel.Lines[0].TagName = 'Отклик') and (lModel.Lines[0].Color = 123) and
      (lModel.Lines[0].Name = 'Произвольный') and not lModel.Lines[0].Visible and
      (lModel.Lines[0].AxisIndex = 1) and (lModel.Lines[1].AxisIndex = 0), 'Line settings/clamp');
    Check(ImportOscLegacy(lSection.AsJSON, 'Oscillogram', lModel, lError), lError);
    Check((lModel.AxisCount = 1) and (lModel.XScale = 0) and (lModel.YScale = 1) and
      (lModel.YOffset = 0) and not lModel.ClosedInput and not lModel.AutoRangeEnabled and
      not lModel.XCursorEnabled and lModel.LegendVisible and not lModel.LevelCursorVisible and
      not lModel.TriggerEnabled and (lModel.TriggerTagName = '') and
      (lModel.LineCount = 2) and (lModel.Lines[0].AxisIndex = 0), 'Builtin simple legacy semantics');
    Check(ImportOscLegacy('{"oscxscale":"-1","OscYScale":"0","OscAxisCount":"100",'+
      '"OscAxis1YScale":"-2","OscPrimaryAxisIndex":"99","OscXCursorCount":"9",'+
      '"OscTriggerEdge":"9","OscTriggerPreRollPercent":"99"}',
      'sample.oscillogram', lModel, lError), lError);
    Check((lModel.XScale = 0) and (lModel.YScale = 1) and (lModel.AxisCount = 16) and
      (lModel.Axes[1].YScale = 1) and (lModel.PrimaryAxisIndex = 0) and
      (lModel.XCursorCount = 1) and (lModel.TriggerEdge = oeFalling) and
      (lModel.TriggerPreRollPercent = 50), 'All historic clamps/case-insensitive keys');
    Check(ImportOscLegacy('{"OscLineCount":"1","OscLine0Color":"255",'+
      '"OscLine0Name":"ignored"}', 'sample.oscillogram', lModel, lError), lError);
    Check(lModel.Lines[0].Name = 'Красный', 'Known color gives palette name');
    Check(ImportOscLegacy('{"OscLineCount":"1","OscLine0Color":"123"}',
      'sample.oscillogram', lModel, lError), lError);
    Check((lModel.Lines[0].Name = 'Травяной зелёный') and
      (lModel.Lines[0].Color = $00228B22), 'Unnamed custom color falls back like old loader');
    Check(ImportOscLegacy('{}', 'sample.oscillogram', lModel, lError), lError);
    Check((lModel.TagName = '') and (lModel.TagId = 0) and
      (lModel.BindingMode = obRelativeSelectedTag) and (lModel.TagOffset = 0) and
      (lModel.DisplayFormat = '4') and (lModel.AxisCount = 1) and
      (lModel.LineCount = 0) and (lModel.XCursorCount = 1) and
      (lModel.TriggerPreRollPercent = 25), 'Missing fields use old defaults, not previous state');
    lBefore := lModel.SaveUtf8;
    Check(not ImportOscLegacy('{"TagName":"changed","OscLineCount":"2",'+
      '"OscLine1Color":"invalid"}', 'sample.oscillogram', lModel, lError), 'Invalid late field must fail');
    Check(lModel.SaveUtf8 = lBefore, 'Late failure must preserve complete target');
    Check(not ImportOscLegacy('{"OscXScale":"NaN"}', 'sample.oscillogram', lModel, lError), 'Non-finite fails');
    Check(not ImportOscLegacy('{"BindingMode":"3"}', 'sample.oscillogram', lModel, lError), 'Invalid enum fails');
    Check(not ImportOscLegacy('{"TagId":123}', 'sample.oscillogram', lModel, lError), 'Known non-string fails');
    Check(not ImportOscLegacy('[]', 'sample.oscillogram', lModel, lError), 'Non-object fails');
    Check(not ImportOscLegacy('{}', 'other.plugin', lModel, lError), 'Foreign type fails');
    Check(lModel.SaveUtf8 = lBefore, 'All failures atomic');
    WriteLn('RESULT LegacyImportSmoke complete settings/defaults/atomic passed');
  finally lSection.Free; lModel.Free; end;
end.
