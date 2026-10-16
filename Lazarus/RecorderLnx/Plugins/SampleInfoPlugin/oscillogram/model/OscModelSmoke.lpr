program OscModelSmoke;
{$mode objfpc}{$H+}{$codepage UTF8}
uses SysUtils, uOscModel;
procedure Check(AValue: Boolean; const AMessage: string);
begin if not AValue then raise Exception.Create(AMessage); end;
var lModel, lCopy, lLoaded: TOscModel; lBlob, lBefore: UTF8String; lError: string;
begin
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
