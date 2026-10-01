unit u3dWidget;

interface

uses
  Windows, Messages, Classes, Controls, Graphics,
  u3dContracts;

type
  T3dWidget = class(TCustomControl, I3dInvalidationSink)
  private
    fRenderer: I3dRenderer;
    fAttached: Boolean;
    fDirty: Boolean;
    procedure AttachRenderer;
    procedure DetachRenderer;
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
      message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetRenderer(const ARenderer: I3dRenderer);
    procedure InvalidateGeometry;
    property Renderer: I3dRenderer read fRenderer;
  end;

implementation

constructor T3dWidget.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csOpaque];
  fDirty := True;
end;

procedure T3dWidget.AttachRenderer;
begin
  if fAttached or (fRenderer = nil) or not HandleAllocated then
    Exit;
  fRenderer.Attach(Handle, ClientWidth, ClientHeight);
  fAttached := True;
  fDirty := True;
end;

procedure T3dWidget.DetachRenderer;
begin
  if not fAttached then
    Exit;
  fRenderer.Detach;
  fAttached := False;
end;

procedure T3dWidget.CreateWnd;
begin
  inherited;
  AttachRenderer;
end;

procedure T3dWidget.DestroyWnd;
begin
  DetachRenderer;
  inherited;
end;

procedure T3dWidget.SetRenderer(const ARenderer: I3dRenderer);
begin
  if fRenderer = ARenderer then
    Exit;
  DetachRenderer;
  fRenderer := ARenderer;
  AttachRenderer;
  InvalidateGeometry;
end;

procedure T3dWidget.InvalidateGeometry;
begin
  fDirty := True;
  Invalidate;
end;

procedure T3dWidget.Paint;
begin
  if fRenderer = nil then
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ClientRect);
    Exit;
  end;
  AttachRenderer;
  if not fDirty then
    Exit;
  fRenderer.Render;
  fDirty := False;
end;

procedure T3dWidget.Resize;
begin
  inherited;
  if fAttached then
    fRenderer.Resize(ClientWidth, ClientHeight);
  fDirty := True;
  Invalidate;
end;

procedure T3dWidget.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  if fRenderer <> nil then
    AMessage.Result := 1
  else
    inherited;
end;

end.
