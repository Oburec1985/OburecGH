unit uIntervalFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DCL_MYOWN, uwpproc, uEventTypes, uWpEvents;

type
  TIntervalFrame = class(TFrame)
    Label5: TLabel;
    Label6: TLabel;
    StartCB: TComboBox;
    StopCB: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LengthE: TFloatEdit;
    StartE: TFloatEdit;
    StopE: TFloatEdit;
    ModeRG: TRadioGroup;
  private
    m_mng:cWpObjMng;
  private
    procedure UpdateTrigs;
    procedure CreateEvents;
    procedure destroyEvents;
    procedure UpdateTrigsEvent(sender:tobject);
  public
    procedure LincMNG(p_mng:cwpobjmng);
    procedure ShowInterval(il:TIntervalOpts);
    function GetInterval:TIntervalOpts;
  end;

  const
    c_int_All=3;
    c_int_Trig=2;
    c_int_Cursor=0;
    c_int_User=1;

implementation

{$R *.dfm}
procedure TIntervalFrame.UpdateTrigsEvent(sender:tobject);
begin
  UpdateTrigs;
end;

procedure TIntervalFrame.CreateEvents;
begin
  m_mng.Events.AddEvent('TIntervalFrame_UpdEvents', E_OnUpdateTrigs, UpdateTrigsEvent);
end;

procedure TIntervalFrame.destroyEvents;
begin
  m_mng.Events.removeEvent(UpdateTrigsEvent,E_OnUpdateTrigs);
end;

function TIntervalFrame.GetInterval:TIntervalOpts;
begin
  case moderg.ItemIndex of
    c_int_All: result.intervaltype:=c_IntervalAllTest;
    c_int_Trig: result.intervaltype:=c_IntervalTrigs;
    c_int_Cursor:result.intervaltype:=c_IntervalCursor;
    c_int_User:result.intervaltype:=c_IntervalTime;
  end;
  result.t1:=StartE.FloatNum;
  result.t2:=StopE.FloatNum;
  Result.start:=m_mng.getTrig(StartCB.Text);
  Result.stop:=m_mng.getTrig(StopCB.Text);
end;

procedure TIntervalFrame.ShowInterval(il:TIntervalOpts);
var
  res:integer;
begin
  case il.intervaltype of
    c_IntervalAllTest:modeRG.ItemIndex:=c_int_All;
    c_IntervalTrigs:modeRG.ItemIndex:=c_int_Trig;
    c_IntervalCursor:modeRG.ItemIndex:=c_int_Cursor;
    c_IntervalTime:modeRG.ItemIndex:=c_int_User;
  end;
  if il.start<>nil then
    StartCB.Text:=il.start.name;

  if il.stop<>nil then
    StopCB.Text:=il.stop.name;
  StartE.FloatNum:=il.t1;
  StopE.FloatNum:=il.t2;
  LengthE.FloatNum:=StartE.FloatNum-StopE.FloatNum;
end;

procedure TIntervalFrame.LincMNG(p_mng:cwpobjmng);
begin
  m_mng:=p_mng;
  updatetrigs;
end;

procedure TIntervalFrame.UpdateTrigs;
var
  i:integer;
  t:ctrig;
begin
  StartCB.Clear;
  StopCB.Clear;
  for I := 0 to m_mng.TrigList.Count - 1 do
  begin
    t:=m_mng.getTrig(i);
    StartCB.Items.AddObject(t.name, t);
    StopCB.Items.AddObject(t.name, t);
  end;
  StartCB.ItemIndex:=-1;
  StopCB.ItemIndex:=-1;
end;

end.
