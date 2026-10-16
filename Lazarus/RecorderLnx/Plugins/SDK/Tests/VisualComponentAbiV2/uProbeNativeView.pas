unit uProbeNativeView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, uRecorderVisualComponentApiV2;

type
  TProbeNativeView = class(TForm)
    TitleLabel: TLabel;
    procedure ViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    fMouseCount, fKeyCount: PLongWord;
  public
    Instance: Pointer;
    ViewId: QWord;
    procedure BindCounters(var AMouseCount, AKeyCount: LongWord);
  end;

function ProbeNativeViewDispatch(AInstance: Pointer; AKind: LongWord;
  const ASurface: TRecorderVisualSurfaceV2;
  var AMouseCount, AKeyCount: LongWord): LongInt;
procedure CloseProbeNativeViews(AInstance: Pointer);
function ProbeNativeViewCount: LongWord; cdecl;

implementation

{$R *.lfm}

var
  g_Views: TList;

procedure TProbeNativeView.BindCounters(var AMouseCount, AKeyCount: LongWord);
begin
  fMouseCount := @AMouseCount;
  fKeyCount := @AKeyCount;
end;

procedure TProbeNativeView.ViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if fMouseCount <> nil then Inc(fMouseCount^);
end;

procedure TProbeNativeView.ViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if fKeyCount <> nil then Inc(fKeyCount^);
end;

function FindView(AInstance: Pointer; AViewId: QWord): TProbeNativeView;
var
  I: Integer;
begin
  for I := 0 to g_Views.Count - 1 do
  begin
    Result := TProbeNativeView(g_Views[I]);
    if (Result.Instance = AInstance) and (Result.ViewId = AViewId) then Exit;
  end;
  Result := nil;
end;

function ProbeNativeViewCount: LongWord; cdecl;
begin
  Result := g_Views.Count;
end;

procedure CloseProbeNativeViews(AInstance: Pointer);
var
  I: Integer;
  lView: TProbeNativeView;
begin
  for I := g_Views.Count - 1 downto 0 do
  begin
    lView := TProbeNativeView(g_Views[I]);
    if lView.Instance <> AInstance then Continue;
    g_Views.Delete(I);
    lView.Free;
  end;
end;

function ProbeNativeViewDispatch(AInstance: Pointer; AKind: LongWord;
  const ASurface: TRecorderVisualSurfaceV2;
  var AMouseCount, AKeyCount: LongWord): LongInt;
var
  lView: TProbeNativeView;
  lBackend: LongWord;
begin
  if ASurface.NativeBackend = REC_VISUAL_NATIVE_NONE then Exit(REC_VISUAL_OK);
  lBackend := REC_VISUAL_NATIVE_NONE;
  {$IFDEF LCLwin32} lBackend := REC_VISUAL_NATIVE_WIN32; {$ENDIF}
  {$IFDEF LCLgtk2} lBackend := REC_VISUAL_NATIVE_GTK2; {$ENDIF}
  if (lBackend = REC_VISUAL_NATIVE_NONE) or
    (ASurface.NativeBackend <> lBackend) then Exit(REC_VISUAL_NOT_HANDLED);
  lView := FindView(AInstance, ASurface.ViewId);
  case AKind of
    REC_VISUAL_DISPATCH_ATTACH_VIEW:
      begin
        if (lView <> nil) or (ASurface.ParentWindow = 0) then
          Exit(REC_VISUAL_ERROR);
        lView := TProbeNativeView.Create(nil);
        try
          lView.Instance := AInstance;
          lView.ViewId := ASurface.ViewId;
          lView.BindCounters(AMouseCount, AKeyCount);
          lView.ParentWindow := ASurface.ParentWindow;
          lView.SetBounds(0, 0, ASurface.Width, ASurface.Height);
          lView.Enabled := (ASurface.Flags and REC_VISUAL_VIEW_INTERACTIVE) <> 0;
          lView.Show;
          g_Views.Add(lView);
        except
          lView.Free;
          Exit(REC_VISUAL_ERROR);
        end;
      end;
    REC_VISUAL_DISPATCH_DETACH_VIEW:
      begin
        if lView = nil then Exit(REC_VISUAL_ERROR);
        g_Views.Remove(lView);
        lView.Free;
      end;
    REC_VISUAL_DISPATCH_RESIZE_VIEW:
      begin
        if lView = nil then Exit(REC_VISUAL_ERROR);
        lView.SetBounds(0, 0, ASurface.Width, ASurface.Height);
      end;
    REC_VISUAL_DISPATCH_VIEW_MODE:
      begin
        if lView = nil then Exit(REC_VISUAL_ERROR);
        lView.Enabled := (ASurface.Flags and REC_VISUAL_VIEW_INTERACTIVE) <> 0;
      end;
    else Exit(REC_VISUAL_NOT_HANDLED);
  end;
  Result := REC_VISUAL_OK;
end;

initialization
  g_Views := TList.Create;
finalization
  while g_Views.Count > 0 do
  begin
    TObject(g_Views[g_Views.Count - 1]).Free;
    g_Views.Delete(g_Views.Count - 1);
  end;
  g_Views.Free;
end.
