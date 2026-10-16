program ThreeDWidgetRotationTest;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, Controls, Classes, SysUtils, Math,
  u3dLclWidget, u3dCoreTypes, u3dGeometryMath, u3dInteractionTypes,
  u3dCameraInteraction, u3dSceneMath, u3dInteractionMath;

type
  TTestWidget = class(T3dLclWidget)
    procedure Press(X,Y:Integer);
    procedure MovePointer(X,Y:Integer);
    procedure ReleasePointer(X,Y:Integer);
  end;

procedure TTestWidget.Press(X,Y:Integer);
begin
  MouseDown(mbLeft,[],X,Y);
end;

procedure TTestWidget.MovePointer(X,Y:Integer);
begin
  MouseMove([ssLeft],X,Y);
end;

procedure TTestWidget.ReleasePointer(X,Y:Integer);
begin
  MouseUp(mbLeft,[],X,Y);
end;

procedure CheckNear(A,B:Single; const Msg:string);
begin
  if Abs(A-B)>0.0001 then
    raise Exception.CreateFmt('%s: %.7f <> %.7f',[Msg,A,B]);
end;

procedure CheckPose(const Actual,Expected:T3dOrbitCamera; const Caption:string);
begin
  CheckNear(Dot(Actual.Forward,Expected.Forward),1,Caption+' forward');
  CheckNear(Dot(Actual.Right,Expected.Right),1,Caption+' right');
  CheckNear(Dot(Actual.Up,Expected.Up),1,Caption+' up');
  CheckNear(Actual.Target.X,Expected.Target.X,Caption+' panned pivot X');
  CheckNear(Actual.Target.Y,Expected.Target.Y,Caption+' panned pivot Y');
  CheckNear(Actual.Target.Z,Expected.Target.Z,Caption+' panned pivot Z');
end;

procedure ExerciseAxis(W:TTestWidget; Vertical:Boolean);
var
  Initial:T3dCamera;
  Start,Expected,Actual:T3dOrbitCamera;
  Forward,Right,Up,Axis:T3dVector;
  X,Y,I,Delta:Integer;
  Angle:Single;
begin
  FillChar(Initial,SizeOf(Initial),0);
  Initial.Target:=Vector3d(8,-3,2);
  Initial.Forward:=Vector3d(0,0,-1);
  Initial.Right:=Vector3d(1,0,0);
  Initial.Up:=Vector3d(0,1,0);
  Initial.Distance:=12;
  Initial.VerticalFovDegrees:=45;
  W.SetCameraState(Initial);
  W.SetInputMode(imRotate);
  W.SetFocus;
  Application.ProcessMessages;
  Start:=W.CurrentOrbitCamera;
  { Start with an already tilted camera, so local axes cannot accidentally be
    replaced by the global XYZ axes. Keep the translated pivot untouched. }
  RotateCamera(Start,Point3d(71,33),0.5);
  Initial.Forward:=Start.Forward;
  Initial.Right:=Start.Right;
  Initial.Up:=Start.Up;
  W.SetCameraState(Initial);
  Start:=W.CurrentOrbitCamera;
  CameraBasis(Start,Forward,Right,Up);
  X:=W.ClientWidth div 2;
  Y:=W.ClientHeight div 2;
  if Vertical then begin Inc(Y,40); Axis:=Right; end
  else begin Inc(X,40); Axis:=Up; end;
  W.Press(X,Y);
  if not W.MouseCapture then raise Exception.Create('axis does not capture mouse');
  for I:=1 to 100 do
  begin
    Delta:=I*8;
    if Vertical then begin W.MovePointer(X,Y+Delta); Angle:=-Delta*0.5; end
    else begin W.MovePointer(X+Delta,Y); Angle:=Delta*0.5; end;
    Expected:=Start;
    RotateCameraAroundAxis(Expected,Axis,Angle);
    Actual:=W.CurrentOrbitCamera;
    CheckNear(Dot(Actual.Forward,Start.Forward),Cos(DegToRad(Angle)),
      'independent trigonometric angular response');
    if Vertical then CheckNear(Dot(Actual.Right,Axis),1,'captured right invariant')
    else CheckNear(Dot(Actual.Up,Axis),1,'captured up invariant');
    CheckNear(Actual.Distance,Start.Distance,'orbit radius invariant');
    CheckPose(Actual,Expected,Format('axis vertical=%s event=%d angle=%.1f',
      [BoolToStr(Vertical,True),I,Angle]));
  end;
  { Reversing back to the start must restore the captured pose exactly. }
  W.MovePointer(X,Y);
  CheckPose(W.CurrentOrbitCamera,Start,'reversed drag');
  W.ReleasePointer(X,Y);
  if W.MouseCapture then raise Exception.Create('release leaves mouse captured');
end;

var
  Host:TForm;
  Widget:TTestWidget;
begin
  try
    Application.Initialize;
    Application.ShowMainForm:=False;
    Host:=TForm.CreateNew(nil);
    try
      Host.SetBounds(50,50,640,480);
      Widget:=TTestWidget.Create(Host);
      Widget.Parent:=Host;
      Widget.Align:=alClient;
      Host.Show;
      Application.ProcessMessages;
      ExerciseAxis(Widget,False);
      ExerciseAxis(Widget,True);
    finally
      Host.Free;
    end;
    WriteLn('RESULT ThreeDWidgetRotationTest passed: real LCL red/green drag +/-400 degrees, local start basis, panned pivot, reversal');
  except
    on E:Exception do begin WriteLn('RESULT failed: ',E.ClassName,': ',E.Message); Halt(1); end;
  end;
end.
