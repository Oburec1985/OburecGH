unit uCompaundFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uSensorFrame, uPairFrame, uTurbineFrame, uStageFrame, uBldObj, uTurbina,
  uStage, uPair, uBaseObjPropertyFrame, uEventList, uChanFrame, uchart,
  uUTSFrame, ExtCtrls, uPlatFrame;

type
  TCompaundFrame = class(TFrame)
    MainObjSB: TScrollBox;
    BaseObjPropertyFrame1: TBaseObjPropertyFrame;
    ChanFrame1: TChanFrame;
    SensorFrame1: TSensorFrame;
    StageFrame1: TStageFrame;
    TurbineFrame1: TTurbineFrame;
    PairFrame1: TPairFrame;
    UTSFrame1: TUTSFrame;
    Splitter1: TSplitter;
    Platframe1: TPlatframe;
  public
    chart:cchart;
    curobj:cbldobj;
  private
    init:boolean;
  private
    procedure hideframes(excludeframe:tframe);
  public
    procedure setObj;
    procedure getObj(obj:cbldobj);
    procedure UpdateState;
  end;

implementation

{$R *.dfm}

procedure TCompaundFrame.hideframes(excludeframe:tframe);
begin
  if StageFrame1<>excludeframe then
    UTSFrame1.Visible:=false;
  if StageFrame1<>excludeframe then
    StageFrame1.Visible:=false;
  if TurbineFrame1<>excludeframe then
    TurbineFrame1.Visible:=false;
  if PairFrame1<>excludeframe then
    PairFrame1.Visible:=false;
  if SensorFrame1<>excludeframe then
    SensorFrame1.Visible:=false;
  if PlatFrame1<>excludeframe then
    PlatFrame1.Visible:=false;
  if excludeframe<>nil then
  begin
    excludeframe.visible:=true;
    BaseObjPropertyFrame1.Visible:=true;
  end
  else
    BaseObjPropertyFrame1.Visible:=false;
end;

procedure TCompaundFrame.setObj;
begin
  if curobj=nil then exit;
  BaseObjPropertyFrame1.SetObj(curobj);
  case curobj.objtype of
    c_turbine:
    begin
      TurbineFrame1.setobj(curobj);
    end;
    c_stage:
    begin
      StageFrame1.chart:=chart;
      StageFrame1.setobj(curobj);
    end;
    c_pair:
    begin
      PairFrame1.setobj(curobj);
    end;
    c_sensor:
    begin
      SensorFrame1.setobj(curobj);
    end;
    c_UTS:
    begin
      UTSFrame1.setobj(curobj);
    end;
    c_2070:
    begin
      hideframes(Platframe1);
      Platframe1.Setobj(curobj);
    end;
  end;
end;

procedure TCompaundFrame.UpdateState;
begin
  getobj(curobj);
end;

procedure TCompaundFrame.getObj(obj:cbldobj);
begin
  curobj:=obj;
  if obj<>nil then
  begin
    BaseObjPropertyFrame1.GetObj(obj);
    case obj.objtype of
      c_turbine:
      begin
        hideframes(TurbineFrame1);
        TurbineFrame1.getobj(obj);
      end;
      c_stage:
      begin
        hideframes(StageFrame1);
        StageFrame1.chart:=chart;
        StageFrame1.getobj(obj);
      end;
      c_pair:
      begin
        hideframes(PairFrame1);
        PairFrame1.getobj(obj);
      end;
      c_sensor:
      begin
        hideframes(SensorFrame1);
        SensorFrame1.getobj(obj);
      end;
      c_chan:
      begin
        hideframes(ChanFrame1);
        ChanFrame1.getObj(obj);
      end;
      c_UTS:
      begin
        hideframes(UTSFrame1);
        UTSFrame1.getobj(curobj);
      end;
      c_2070:
      begin
        hideframes(Platframe1);
        Platframe1.getobj(curobj);
      end;
      c_2081:
      begin
        hideframes(Platframe1);
        Platframe1.getobj(curobj);
      end;
    end;
  end
  else
    hideframes(nil);
end;


end.
