unit uRecorderFrequencyResponseView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Graphics, Math, SyncObjs,
  uOglChart, uRecorderFormModel, uRecorderTags, uRecorderCoreServices,
  uRecorderVisualControl, uRecorderFrequencyResponse,
  uRecorderFrequencyResponseModel;

type
  TRecorderFrequencyResponseRuntimeLine = class
  public
    Model: TRecorderFrequencyResponseLine;
    ValueTag, FrequencyTag: TRecorderTag;
    Buffer: TRecorderFrequencyResponseBuffer;
    FrequencyHz: Double;
    HasFrequency: Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  TRecorderFrequencyResponseView = class(TPanel, IVForm)
  private
    fComponent: TRecorderFrequencyResponseComponent;
    fRegistry: TRecorderTagRegistry;
    fLines: TList;
    fLock: TCriticalSection;
    fToken: Integer;
    fDirty: Boolean;
    procedure ClearLines;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    procedure ResolveLines;
    function AxisByName(const AName: string): TRecorderFrequencyResponseAxis;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

implementation

constructor TRecorderFrequencyResponseRuntimeLine.Create;
begin inherited Create; Buffer := TRecorderFrequencyResponseBuffer.Create; end;
destructor TRecorderFrequencyResponseRuntimeLine.Destroy;
begin Buffer.Free; inherited Destroy; end;

constructor TRecorderFrequencyResponseView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); BevelOuter := bvNone; Color := clWhite;
  DoubleBuffered := True; fLines := TList.Create; fLock := TCriticalSection.Create;
end;

destructor TRecorderFrequencyResponseView.Destroy;
begin
  if (fToken<>0) and (fRegistry<>nil) and (fRegistry.EventBus<>nil) then fRegistry.EventBus.Unsubscribe(fToken);
  ClearLines; fLines.Free; fLock.Free; inherited Destroy;
end;

procedure TRecorderFrequencyResponseView.ClearLines;
begin while fLines.Count>0 do begin TObject(fLines.Last).Free; fLines.Delete(fLines.Count-1); end; end;

function TRecorderFrequencyResponseView.AxisByName(const AName:string):TRecorderFrequencyResponseAxis;
var I:Integer;
begin Result:=nil; if fComponent=nil then Exit; for I:=0 to fComponent.AxisCount-1 do if SameText(fComponent.Axes[I].Name,AName) then Exit(fComponent.Axes[I]); if fComponent.AxisCount>0 then Result:=fComponent.Axes[0]; end;

procedure TRecorderFrequencyResponseView.ResolveLines;
var I:Integer; s:TRecorderFrequencyResponseRuntimeLine;
begin
  ClearLines; if fComponent=nil then Exit;
  for I:=0 to fComponent.LineCount-1 do begin
    s:=TRecorderFrequencyResponseRuntimeLine.Create; s.Model:=fComponent.Lines[I];
    s.ValueTag:=RecorderResolveFrequencyResponseLineValueTag(fRegistry,s.Model);
    s.FrequencyTag:=RecorderResolveFrequencyResponseLineXTag(fRegistry,s.Model,s.ValueTag);
    s.Buffer.Configure(fComponent.MinFrequencyHz,fComponent.MaxFrequencyHz,
      Max(1,s.Model.BufferSize),s.Model.UniformX,s.Model.FrequencyStepHz,s.Model.MergeMode);
    fLines.Add(s);
  end;
end;

procedure TRecorderFrequencyResponseView.Configure(AComponent:TRecorderVisualComponent; ATagRegistry:TRecorderTagRegistry);
begin
  if not (AComponent is TRecorderFrequencyResponseComponent) then Exit;
  if (fToken<>0) and (fRegistry<>nil) and (fRegistry.EventBus<>nil) then begin fRegistry.EventBus.Unsubscribe(fToken); fToken:=0; end;
  fComponent:=TRecorderFrequencyResponseComponent(AComponent); fRegistry:=ATagRegistry;
  ResolveLines; if (fRegistry<>nil) and (fRegistry.EventBus<>nil) then fToken:=fRegistry.EventBus.Subscribe(@HandleEvent);
  fDirty:=True; Invalidate;
end;

procedure TRecorderFrequencyResponseView.HandleEvent(ASender:TObject; const AEvent:TRecorderEvent);
var d:TRecorderTagUpdateEventData; I:Integer; s:TRecorderFrequencyResponseRuntimeLine;
begin
  if (AEvent.Kind<>rceDataUpdated) or not(AEvent.Data is TRecorderTagUpdateEventData) then Exit;
  d:=TRecorderTagUpdateEventData(AEvent.Data); fLock.Enter;
  try for I:=0 to fLines.Count-1 do begin s:=TRecorderFrequencyResponseRuntimeLine(fLines[I]);
    if d.Tag=s.FrequencyTag then begin s.FrequencyHz:=d.Value; s.HasFrequency:=True; end
    else if (d.Tag=s.ValueTag) and s.HasFrequency then if s.Buffer.AddPoint(s.FrequencyHz,d.Value) then fDirty:=True;
  end; finally fLock.Leave; end;
end;

procedure TRecorderFrequencyResponseView.RefreshControl(ATagRegistry:TRecorderTagRegistry; ADisplaySeconds:Double);
begin
  if ATagRegistry<>fRegistry then begin Configure(fComponent,ATagRegistry); Exit; end;
  fLock.Enter; try if not fDirty then Exit; fDirty:=False; finally fLock.Leave; end; Invalidate;
end;

function TRecorderFrequencyResponseView.GetChartControl:TOglChart; begin Result:=nil; end;

procedure TRecorderFrequencyResponseView.Paint;
const CLeft=70; CTop=24; CRight=24; CBottom=38;
var I,J,x,y,px,py,valid,axisNo:Integer; s:TRecorderFrequencyResponseRuntimeLine; a:TRecorderFrequencyResponseAxis; p:TRecorderFrequencyResponsePoint; w,h,xspan,yspan:Double; have:Boolean;
begin
  inherited Paint; Canvas.Brush.Color:=clWhite; Canvas.FillRect(ClientRect);
  if (fComponent=nil) or (Width<CLeft+CRight+20) or (Height<CTop+CBottom+20) then Exit;
  w:=Width-CLeft-CRight; h:=Height-CTop-CBottom; xspan:=fComponent.MaxFrequencyHz-fComponent.MinFrequencyHz; if xspan<=0 then Exit;
  Canvas.Pen.Color:=clGray; Canvas.Line(CLeft,CTop,CLeft,Height-CBottom); Canvas.Line(CLeft,Height-CBottom,Width-CRight,Height-CBottom);
  Canvas.TextOut(CLeft,Height-CBottom+6,FloatToStrF(fComponent.MinFrequencyHz,ffGeneral,6,2));
  Canvas.TextOut(Width-CRight-65,Height-CBottom+6,FloatToStrF(fComponent.MaxFrequencyHz,ffGeneral,6,2)+' Hz');
  axisNo:=0; for I:=0 to fComponent.AxisCount-1 do begin a:=fComponent.Axes[I]; Canvas.Font.Color:=clGray; Canvas.TextOut(4,CTop+axisNo*16,a.Name+' '+FloatToStrF(a.MinValue,ffGeneral,5,2)+'..'+FloatToStrF(a.MaxValue,ffGeneral,5,2)); Inc(axisNo); end;
  valid:=0; px:=0; py:=0; fLock.Enter;
  try for I:=0 to fLines.Count-1 do begin s:=TRecorderFrequencyResponseRuntimeLine(fLines[I]); a:=AxisByName(s.Model.AxisName); if a=nil then Continue; yspan:=a.MaxValue-a.MinValue; if yspan<=0 then Continue;
    Canvas.Pen.Color:=TColor(s.Model.Color); Canvas.Pen.Width:=Max(1,s.Model.Width); Canvas.Brush.Color:=TColor(s.Model.Color); have:=False;
    for J:=0 to s.Buffer.Count-1 do begin p:=s.Buffer.Point(J); if not p.Valid then Continue; Inc(valid); x:=CLeft+Round((p.FrequencyHz-fComponent.MinFrequencyHz)/xspan*w); y:=CTop+Round((a.MaxValue-p.Value)/yspan*h);
      if s.Model.DrawLine and have then Canvas.Line(px,py,x,y); if s.Model.DrawPoints then Canvas.Ellipse(x-2,y-2,x+3,y+3); px:=x; py:=y; have:=True;
    end;
  end; finally fLock.Leave; end; Canvas.Pen.Width:=1; if valid=0 then Canvas.TextOut(CLeft+8,CTop+8,'Ожидание данных');
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(TRecorderFrequencyResponseComponent,TRecorderFrequencyResponseView);

end.
