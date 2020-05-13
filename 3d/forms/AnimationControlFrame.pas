unit AnimationControlFrame;

interface

uses
  Windows, Messages, SysUtils, Forms,
  Buttons, StdCtrls, uTimeController, Controls, Classes, uUI, ExtCtrls,
  unodeobject, Mathfunction,umatrix, uquat;

type
  TAnimationCtrlFrame = class(TFrame)
    AnimationControlGroupBox: TGroupBox;
    AnimationTimer: TTimer;
    GroupBox1: TGroupBox;
    TimeScrollBar: TScrollBar;
    RewndBtn: TSpeedButton;
    PausePlayBtn: TSpeedButton;
    FrwBtn: TSpeedButton;
    procedure AnimationTimerTimer(Sender: TObject);
    procedure PausePlayBtnClick(Sender: TObject);
    procedure TimeScrollBarChange(Sender: TObject);
  private
    ui:cUI;
    timecntrl:ctimeController;
  private
    procedure OnTimeCtrlChange(sender:tobject);
    function GetTime:cardinal;
  public
    procedure linc(p_ui:cUI);
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TAnimationCtrlFrame.linc(p_ui:cUI);
begin
  ui:=p_ui;
  timecntrl:=ui.TimeCntrl;
  timecntrl.TimeEvents.AddEvent('TAnimationCtrlFrame onTimeChanged',
                       ChangeOptsEvent+ChangeTimeEvent,OnTimeCtrlChange);
  OnTimeCtrlChange(nil);
end;

procedure TAnimationCtrlFrame.OnTimeCtrlChange(sender:tobject);
begin
  TimeScrollBar.Max:=timecntrl.maxtime;
  TimeScrollBar.Position:=timecntrl.ticks;
end;

function TAnimationCtrlFrame.GetTime:cardinal;
begin
  result:=TimeScrollBar.Position;
end;


procedure TAnimationCtrlFrame.PausePlayBtnClick(Sender: TObject);
begin
  AnimationTimer.Enabled:=PausePlayBtn.down;
end;

procedure TAnimationCtrlFrame.TimeScrollBarChange(Sender: TObject);
begin
  timecntrl.ticks:=gettime;
  ui.m_RenderScene.invalidaterect;
end;

procedure TAnimationCtrlFrame.AnimationTimerTimer(Sender: TObject);
begin
  ui.TimeCntrl.time:=ui.TimeCntrl.time+AnimationTimer.Interval;
  ui.m_RenderScene.invalidaterect;
end;

end.
