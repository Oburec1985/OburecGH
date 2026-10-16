unit uOscBehavior;
{$mode objfpc}{$H+}{$codepage UTF8}

{ Internal Oscillogram behavior. No host runtime/model/UI object is accepted;
  these records are plugin-local implementation details, not SDK extensions. }
interface
uses SysUtils, Math, uOscModel, uOscTags, uSharedStatistics;
const
  OSC_CAP_TOOLBAR = QWord(1) shl 0;
  OSC_CAP_CONTROL_PANEL = QWord(1) shl 1;
  OSC_CAP_LEGEND = QWord(1) shl 2;
  OSC_CAP_X_CURSOR = QWord(1) shl 3;
  OSC_CAP_LEVEL_CURSOR = QWord(1) shl 4;
  OSC_CAP_AUTO_RANGE = QWord(1) shl 5;
  OSC_CAP_MULTI_AXIS = QWord(1) shl 6;
  OSC_CAP_TRIGGER = QWord(1) shl 7;
  OSC_CAP_EXTREMA = QWord(1) shl 8;
  OSC_CAP_SIGNAL_GRID = QWord(1) shl 9;
  OSC_CAP_INTERACTIVE_CHART = QWord(1) shl 10;
  OSC_ALL_CAPABILITIES = (QWord(1) shl 11) - 1;
type
  POscFrame = ^TOscFrame;
  TOscFrame = record
    Size, SampleCount: LongInt;
    Values: PDouble;
    DisplaySeconds, MinValue, MaxValue, RmsValue: Double;
  end;
  POscControlEvent = ^TOscControlEvent;
  TOscControlEvent = record
    Size: LongInt;
    Name, ControlId: array[0..63] of AnsiChar;
    Value1, Value2: Double;
    IntValue: Int64;
    Flags: QWord;
  end;
  POscControlResult = ^TOscControlResult;
  TOscControlResult = record
    Size: LongInt;
    Handled: LongBool;
    Actions: QWord;
    Text: array[0..255] of AnsiChar;
    Value1, Value2: Double;
    IntValue: Int64;
  end;
  TOscSignalSnapshot = record
    Count: Integer;
    Times, Values: TOscDoubleArray;
  end;

function OscProcessFrame(AFrame: POscFrame): Boolean;
function OscProcessControl(AModel: TOscModel; AEvent: POscControlEvent;
  AResult: POscControlResult): Boolean;
function OscResolveTag(ARegistry: TOscTagRegistry; AId: QWord;
  const AName: string): TOscTag;
function OscSignalCrossesTriggerLevel(APrevious, ACurrent, ALevel: Double;
  AEdge: TOscSignalEdge): Boolean;
function OscTagSourceIsVisible(ARegistry: TOscTagRegistry; ATag: TOscTag): Boolean;

implementation
type TDoubleSamples = array[0..MaxInt div SizeOf(Double)-1] of Double;
  PDoubleSamples = ^TDoubleSamples;

function OscProcessFrame(AFrame: POscFrame): Boolean;
var lSummary: TStatisticsSummary;
begin
  Result := False;
  if (AFrame = nil) or (AFrame^.Size < SizeOf(AFrame^)) then Exit;
  AFrame^.MinValue := 0; AFrame^.MaxValue := 0; AFrame^.RmsValue := 0;
  if (AFrame^.SampleCount <= 0) or (AFrame^.Values = nil) then Exit(True);
  Result := TrySummary(Slice(PDoubleSamples(AFrame^.Values)^,
    AFrame^.SampleCount), lSummary);
  if not Result then Exit;
  AFrame^.MinValue := lSummary.Minimum;
  AFrame^.MaxValue := lSummary.Maximum;
  AFrame^.RmsValue := Sqrt(Max(0, lSummary.PopulationVariance + Sqr(lSummary.Mean)));
end;

function OscProcessControl(AModel: TOscModel; AEvent: POscControlEvent;
  AResult: POscControlResult): Boolean;
var lName: string; lDelta: Double; lCaption: UTF8String;
begin
  Result := False;
  if (AEvent = nil) or (AResult = nil) or
    (AEvent^.Size < SizeOf(AEvent^)) or (AResult^.Size < SizeOf(AResult^)) then Exit;
  lName := StrPas(@AEvent^.Name[0]);
  if lName = 'component.describe' then AResult^.Actions := OSC_ALL_CAPABILITIES
  else if lName = 'cursor.measure' then
  begin
    lDelta := Abs(AEvent^.Value2 - AEvent^.Value1);
    AResult^.Value1 := lDelta; AResult^.Value2 := 0;
    lCaption := UTF8String('dX=' + FormatFloat('0.####', lDelta) + ' с');
    if lDelta > 0 then
    begin
      AResult^.Value2 := 1/lDelta;
      lCaption := lCaption + UTF8String(' (f=' + FormatFloat('0.####',1/lDelta)+' Гц)');
    end;
    StrPLCopy(@AResult^.Text[0], lCaption, High(AResult^.Text));
  end;
  AResult^.Handled := True;
  Result := True;
end;

function OscResolveTag(ARegistry: TOscTagRegistry; AId: QWord;
  const AName: string): TOscTag;
begin
  Result := nil;
  if ARegistry = nil then Exit;
  if AId <> 0 then Result := ARegistry.FindById(AId);
  if (Result = nil) and (AName <> '') then Result := ARegistry.FindByName(AName);
end;

function OscSignalCrossesTriggerLevel(APrevious, ACurrent, ALevel: Double;
  AEdge: TOscSignalEdge): Boolean;
begin
  if AEdge = oeFalling then Result := (APrevious > ALevel) and (ACurrent <= ALevel)
  else Result := (APrevious < ALevel) and (ACurrent >= ALevel);
end;
function OscTagSourceIsVisible(ARegistry: TOscTagRegistry; ATag: TOscTag): Boolean;
begin
  Result := (ATag <> nil) and ATag.SourceVisible;
end;
end.
