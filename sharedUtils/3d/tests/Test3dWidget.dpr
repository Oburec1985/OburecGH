program Test3dWidget;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, Forms,
  u3dCoreTypes in '..\core\u3dCoreTypes.pas',
  u3dContracts in '..\contracts\u3dContracts.pas',
  u3dWidget in '..\vcl\u3dWidget.pas',
  u3dOpenGLRenderer in '..\render\opengl\u3dOpenGLRenderer.pas';

type
  TFakeRenderer = class(TInterfacedObject, I3dRenderer)
  public
    AttachCount: Integer;
    DetachCount: Integer;
    RenderCount: Integer;
    ResizeCount: Integer;
    procedure Attach(const AWindowHandle: NativeUInt;
      const AWidth, AHeight: Integer);
    procedure Resize(const AWidth, AHeight: Integer);
    procedure Render;
    procedure Detach;
  end;

procedure TFakeRenderer.Attach(const AWindowHandle: NativeUInt;
  const AWidth, AHeight: Integer);
begin
  Inc(AttachCount);
end;

procedure TFakeRenderer.Resize(const AWidth, AHeight: Integer);
begin
  Inc(ResizeCount);
end;

procedure TFakeRenderer.Render;
begin
  Inc(RenderCount);
end;

procedure TFakeRenderer.Detach;
begin
  Inc(DetachCount);
end;

procedure Check(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure Run;
var
  lForm: TForm;
  lWidget: T3dWidget;
  lRendererObject: TFakeRenderer;
  lRenderer: I3dRenderer;
  lRendered: Integer;
begin
  lForm := TForm.Create(nil);
  try
    lRendererObject := TFakeRenderer.Create;
    lRenderer := lRendererObject;
    lWidget := T3dWidget.Create(lForm);
    lWidget.Parent := lForm;
    lWidget.SetBounds(0, 0, 320, 200);
    lWidget.SetRenderer(lRenderer);
    Check(lForm.Handle <> 0, 'Form handle was not created');
    Check(lWidget.Handle <> 0, 'Widget handle was not created');
    lForm.Show;
    lWidget.Show;
    lWidget.InvalidateGeometry;
    Application.ProcessMessages;
    Check(lRendererObject.AttachCount = 1, 'Renderer was not attached once');
    Check(lRendererObject.RenderCount = 1, 'Dirty frame was not rendered');
    lRendered := lRendererObject.RenderCount;
    lWidget.Repaint;
    Check(lRendererObject.RenderCount = lRendered, 'Clean frame rendered again');
    lWidget.InvalidateGeometry;
    Application.ProcessMessages;
    Check(lRendererObject.RenderCount = lRendered + 1,
      'Invalidated frame was not rendered');
    lWidget.SetRenderer(nil);
    Check(lRendererObject.DetachCount = 1, 'Renderer was not detached');
  finally
    lForm.Free;
  end;
end;

procedure RunOpenGLReplacementSmoke;
var
  lForm: TForm;
  lRenderer: I3dRenderer;
  lWidget: T3dWidget;
begin
  lForm := TForm.Create(nil);
  try
    lWidget := T3dWidget.Create(lForm);
    lWidget.Parent := lForm;
    lWidget.SetBounds(0, 0, 160, 120);
    lForm.Show;
    lWidget.Show;
    lRenderer := T3dOpenGLRenderer.Create;
    lWidget.SetRenderer(lRenderer);
    Application.ProcessMessages;
    lWidget.SetRenderer(nil);
    lRenderer := T3dOpenGLRenderer.Create;
    lWidget.SetRenderer(lRenderer);
    lWidget.InvalidateGeometry;
    Application.ProcessMessages;
    lWidget.SetRenderer(nil);
    lRenderer := nil;
  finally
    lForm.Free;
  end;
end;

begin
  Application.Initialize;
  try
    Run;
    RunOpenGLReplacementSmoke;
    Writeln('OK');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
