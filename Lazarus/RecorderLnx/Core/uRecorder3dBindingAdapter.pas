unit uRecorder3dBindingAdapter;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Math, u3dCoreTypes, u3dScene, uRecorderTags, uRecorder3dModel;

type
  TRecorder3dAxis = (r3aX, r3aY, r3aZ);
  TRecorder3dAxisMask = set of TRecorder3dAxis;

  { Values prepared by Recorder bindings, independent of the drawing backend. }
  TRecorder3dUpdateBatch = record
    TargetNodeId: QWord;
    Translation: T3dVector;
    TranslationMask: TRecorder3dAxisMask;
    HasColor: Boolean;
    Color: T3dColor;
    HasNormalLength: Boolean;
    NormalLength: Single;
  end;

  TRecorder3dBindingAdapter = class
  private
    fComponent: TRecorder3dComponent;
    fScene: T3dScene;
    fTargetNode: T3dNode;
    fTags: array[TRecorder3dBindingSlot] of TRecorderTag;
    fLastValues: array[TRecorder3dBindingSlot] of Double;
    function ResolveTag(ARegistry: TRecorderTagRegistry;
      ASlot: TRecorder3dBindingSlot): TRecorderTag;
    function ReadChanged(ASlot: TRecorder3dBindingSlot;
      out AValue: Double): Boolean;
  public
    constructor Create;
    procedure Configure(AComponent: TRecorder3dComponent;
      ARegistry: TRecorderTagRegistry);
    procedure AttachScene(AScene: T3dScene);
    function Collect(out ABatch: TRecorder3dUpdateBatch): Boolean;
    property TargetNode: T3dNode read fTargetNode;
  end;

implementation

constructor TRecorder3dBindingAdapter.Create;
var
  lSlot: TRecorder3dBindingSlot;
begin
  inherited Create;
  for lSlot := Low(lSlot) to High(lSlot) do
    fLastValues[lSlot] := NaN;
end;

function TRecorder3dBindingAdapter.ResolveTag(ARegistry: TRecorderTagRegistry;
  ASlot: TRecorder3dBindingSlot): TRecorderTag;
var
  lId: TRecorderTagId;
  lName: string;
begin
  Result := nil;
  if ARegistry = nil then Exit;
  lId := fComponent.BindingTagIds[ASlot];
  lName := fComponent.BindingTagNames[ASlot];
  if (ASlot = r3bNormalLength) and (lId = 0) then
  begin
    lId := fComponent.NormalLengthTagId;
    lName := fComponent.NormalLengthTagName;
  end;
  if lId <> 0 then Result := ARegistry.FindById(lId);
  if (Result = nil) and (lName <> '') then Result := ARegistry.FindByName(lName);
end;

procedure TRecorder3dBindingAdapter.Configure(AComponent: TRecorder3dComponent;
  ARegistry: TRecorderTagRegistry);
var
  lSlot: TRecorder3dBindingSlot;
begin
  fComponent := AComponent;
  for lSlot := Low(lSlot) to High(lSlot) do
  begin
    fTags[lSlot] := ResolveTag(ARegistry, lSlot);
    fLastValues[lSlot] := NaN;
  end;
  AttachScene(fScene);
end;

procedure TRecorder3dBindingAdapter.AttachScene(AScene: T3dScene);
begin
  fScene := AScene;
  fTargetNode := nil;
  if (fScene <> nil) and (fComponent <> nil) then
    fTargetNode := fScene.FindNode(fComponent.BindingTargetNodeId);
end;

function TRecorder3dBindingAdapter.ReadChanged(ASlot: TRecorder3dBindingSlot;
  out AValue: Double): Boolean;
begin
  Result := False;
  if fTags[ASlot] = nil then Exit;
  AValue := fTags[ASlot].SignalBuffer.LatestValue;
  if IsNan(AValue) or IsInfinite(AValue) or
    SameValue(AValue, fLastValues[ASlot]) then Exit;
  fLastValues[ASlot] := AValue;
  Result := True;
end;

function TRecorder3dBindingAdapter.Collect(
  out ABatch: TRecorder3dUpdateBatch): Boolean;
var
  lValue: Double;
begin
  FillChar(ABatch, SizeOf(ABatch), 0);
  if fTargetNode <> nil then
  begin
    ABatch.TargetNodeId := fTargetNode.Id;
    ABatch.Translation := Vector3d(fTargetNode.WorldTransform[12],
      fTargetNode.WorldTransform[13], fTargetNode.WorldTransform[14]);
    if ReadChanged(r3bPointX, lValue) then
    begin
      ABatch.Translation.X := lValue;
      Include(ABatch.TranslationMask, r3aX);
    end;
    if ReadChanged(r3bPointY, lValue) then
    begin
      ABatch.Translation.Y := lValue;
      Include(ABatch.TranslationMask, r3aY);
    end;
    if ReadChanged(r3bPointZ, lValue) then
    begin
      ABatch.Translation.Z := lValue;
      Include(ABatch.TranslationMask, r3aZ);
    end;
    if ReadChanged(r3bColor, lValue) then
    begin
      lValue := EnsureRange(lValue, 0.0, 1.0);
      ABatch.HasColor := True;
      ABatch.Color.R := Round(lValue * 255);
      ABatch.Color.G := Round((1 - lValue) * 255);
      ABatch.Color.B := 64;
    end;
  end;
  if ReadChanged(r3bNormalLength, lValue) then
  begin
    ABatch.HasNormalLength := True;
    ABatch.NormalLength := EnsureRange(Abs(lValue), 0.0001, 1.0e4);
  end;
  Result := (ABatch.TranslationMask <> []) or ABatch.HasColor or
    ABatch.HasNormalLength;
end;

end.
