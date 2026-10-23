program OscModelSmoke;
{$mode objfpc}{$H+}{$codepage UTF8}
uses SysUtils, uOscModel;
procedure Check(AValue: Boolean; const AMessage: string);
begin if not AValue then raise Exception.Create(AMessage); end;
procedure CheckUnusedAxes;
var
  lModel, lReload: TOscModel;
  lFirst, lLast: TOscAxis;
  lBlob: UTF8String;
  lError: string;
begin
  lModel := TOscModel.Create; lReload := TOscModel.Create;
  try
    lFirst := lModel.Axes[0]; lFirst.YScale := 3;
    lModel.TagName := 'Primary'; lModel.TagId := 1;
    lModel.TriggerTagName := 'Independent trigger';
    lModel.AddAxis.YOffset := 12;
    lLast := lModel.AddAxis; lLast.RangeMax := 123;
    with lModel.AddLine do begin TagName := 'A'; TagId := 2; AxisIndex := 1; end;
    with lModel.AddLine do begin TagName := 'B'; TagId := 3; AxisIndex := 2; end;
    lModel.DeleteLine(0); lModel.RemoveUnusedAxes;
    Check((lModel.AxisCount = 2) and (lModel.Axes[0] = lFirst) and
      (lModel.Axes[1] = lLast) and (lModel.Lines[0].AxisIndex = 1),
      'Delete line must prune only unused axis and remap later lines');
    Check((lModel.Axes[1].RangeMax = 123) and (lModel.Axes[0].YScale = 3),
      'Populated axis settings/identity lost');
    lModel.PrimaryAxisIndex := 1; lModel.RemoveUnusedAxes;
    Check((lModel.AxisCount = 1) and (lModel.Axes[0] = lLast) and
      (lModel.PrimaryAxisIndex = 0) and (lModel.Lines[0].AxisIndex = 0),
      'Reassignment to shared axis must remap primary and line');
    Check(lModel.TriggerTagName = 'Independent trigger', 'Trigger source changed');
    lBlob := lModel.SaveUtf8;
    Check(lReload.LoadUtf8(lBlob, lError), lError);
    Check(lReload.SaveUtf8 = lBlob, 'Pruned axes persistence roundtrip');
    lModel.DeleteLine(0); lModel.RemoveUnusedAxes;
    Check((lModel.AxisCount = 1) and (lModel.Axes[0] = lLast),
      'Last additional line must preserve primary populated axis');
    lModel.TagId := 0; lModel.TagName := ''; lModel.RemoveUnusedAxes;
    Check((lModel.AxisCount = 1) and (lModel.PrimaryAxisIndex = 0),
      'Empty model requires one valid default axis');
  finally lReload.Free; lModel.Free; end;
end;
var lModel, lCopy, lLoaded: TOscModel; lBlob, lBefore: UTF8String; lError: string;
begin
  CheckUnusedAxes;
  lModel := TOscModel.Create; lCopy := nil; lLoaded := TOscModel.Create;
  try
    Check(lModel.LegendVisible and (lModel.AxisCount = 1) and
      (lModel.TriggerPreRollPercent = 25), 'defaults');
    lModel.TagName := 'Датчик'; lModel.TagId := 9223372036854775806;
    lModel.TriggerEdge := oeFalling; lModel.TriggerEnabled := True;
    lModel.XCursorCount := 2; lModel.XScale := 0.3;
    lModel.AddAxis.RangeMax := 100;
    lModel.PrimaryAxisIndex := 1;
    with lModel.AddLine do begin TagName := 'Канал'; TagId := 77; AxisIndex := 1; end;
    lBlob := lModel.SaveUtf8;
    Check(lLoaded.LoadUtf8(lBlob, lError), lError);
    Check(lLoaded.SaveUtf8 = lBlob, 'full roundtrip');
    lCopy := lModel.Clone; lCopy.Axes[1].RangeMax := 200;
    lCopy.Lines[0].TagName := 'Other';
    Check((lModel.Axes[1].RangeMax = 100) and
      (lModel.Lines[0].TagName = 'Канал'), 'deep clone');
    lBefore := lLoaded.SaveUtf8;
    Check(not lLoaded.LoadUtf8('{"Version":99}', lError), 'bad version');
    Check(lLoaded.SaveUtf8 = lBefore, 'atomic rejected version');
    Check(not lLoaded.LoadUtf8(StringReplace(lBlob, '"AxisIndex" : 1',
      '"AxisIndex" : 999', []), lError), 'bad line axis');
    Check(lLoaded.SaveUtf8 = lBefore, 'atomic rejected axis');
    WriteLn('RESULT OscModelSmoke passed');
  finally lCopy.Free; lLoaded.Free; lModel.Free; end;
end.
