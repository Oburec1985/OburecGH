unit uSampleOscillogram;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  uRecorderPluginApi;

type
  TSampleOscillogram = class
  private
    fOwner: TObject;
    fRecording: Boolean;
  public
    constructor Create(AOwner: TObject);
    procedure doCreateFrm(ASpec: PRecorderPluginComponentSpec);
    procedure doStart;
    procedure doStop;
    function doRepaint(AFrame: PRecorderPluginOscillogramFrame): LongBool;
    procedure doClose;
  end;

function CreateSampleOscillogram(APluginContext: Pointer;
  ASpec: PRecorderPluginComponentSpec): LongBool; cdecl;

implementation

uses
  SysUtils, Math, PluginClass;

type
  PDoubleSamples = ^TDoubleSamples;
  TDoubleSamples = array[0..MaxInt div SizeOf(Double) - 1] of Double;

constructor TSampleOscillogram.Create(AOwner: TObject);
begin
  inherited Create;
  fOwner := AOwner;
end;

procedure TSampleOscillogram.doCreateFrm(
  ASpec: PRecorderPluginComponentSpec);
begin
  ASpec^.Width := 650;
  ASpec^.Height := 350;
  StrPLCopy(@ASpec^.Name[0], 'Осциллограмма плагина', High(ASpec^.Name));
  ASpec^.ComponentContext := Self;
end;

procedure TSampleOscillogram.doStart;
begin
  fRecording := True;
end;

procedure TSampleOscillogram.doStop;
begin
  fRecording := False;
end;

function TSampleOscillogram.doRepaint(
  AFrame: PRecorderPluginOscillogramFrame): LongBool;
var
  I: LongInt;
  lValue: Double;
  lSquareSum: Double;
begin
  Result := False;
  if (AFrame = nil) or
    (AFrame^.Size < SizeOf(TRecorderPluginOscillogramFrame)) then
    Exit;
  AFrame^.MinValue := 0;
  AFrame^.MaxValue := 0;
  AFrame^.RmsValue := 0;
  if (AFrame^.SampleCount <= 0) or (AFrame^.Values = nil) then
    Exit(True);
  AFrame^.MinValue := AFrame^.Values^;
  AFrame^.MaxValue := AFrame^.Values^;
  lSquareSum := 0;
  for I := 0 to AFrame^.SampleCount - 1 do
  begin
    lValue := PDoubleSamples(AFrame^.Values)^[I];
    AFrame^.MinValue := Min(AFrame^.MinValue, lValue);
    AFrame^.MaxValue := Max(AFrame^.MaxValue, lValue);
    lSquareSum := lSquareSum + Sqr(lValue);
  end;
  AFrame^.RmsValue := Sqrt(lSquareSum / AFrame^.SampleCount);
  Result := True;
end;

procedure TSampleOscillogram.doClose;
begin
  if fOwner <> nil then
    TPluginClass(fOwner).RemoveOscillogram(Self);
  Free;
end;

function RepaintSampleOscillogram(AComponentContext: Pointer;
  AFrame: PRecorderPluginOscillogramFrame): LongBool; cdecl;
begin
  Result := (AComponentContext <> nil) and
    TSampleOscillogram(AComponentContext).doRepaint(AFrame);
end;

procedure CloseSampleOscillogram(AComponentContext: Pointer); cdecl;
begin
  if AComponentContext <> nil then
    TSampleOscillogram(AComponentContext).doClose;
end;

function CreateSampleOscillogram(APluginContext: Pointer;
  ASpec: PRecorderPluginComponentSpec): LongBool; cdecl;
var
  lOscillogram: TSampleOscillogram;
begin
  Result := False;
  if (APluginContext = nil) or (ASpec = nil) or
    (ASpec^.Size < SizeOf(TRecorderPluginComponentSpec)) then
    Exit;
  lOscillogram := TSampleOscillogram.Create(TObject(APluginContext));
  lOscillogram.doCreateFrm(ASpec);
  ASpec^.DoRepaint := @RepaintSampleOscillogram;
  ASpec^.DoClose := @CloseSampleOscillogram;
  TPluginClass(APluginContext).AddOscillogram(lOscillogram);
  Result := True;
end;

end.
