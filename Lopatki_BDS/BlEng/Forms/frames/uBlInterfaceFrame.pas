unit uBlInterfaceFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uBaseObjPropertyFrame, uTurbineFrame, uStageFrame,
  uPairFrame, uCompaundFrame, ubldobj, ueventlist, uEventTypes, ExtCtrls,
  uframeevents, uGlTurbineFrame, uBaseGlComponent, uchart;

type
  TObjInterfaceFrame = class(TFrame)
    ScrollBox1: TScrollBox;
    MainObjGB: TGroupBox;
    MainObjFrame:tcompaundframe;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    procedure ApplyBtnClick(Sender: TObject);
  public
    chart:cchart;
  private
    events:ceventlist;
  private
    procedure update;
  public
    procedure lincevents(e:ceventlist);
    procedure getObj(obj:cbldobj);
    procedure setObj;
    Constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

implementation

{$R *.dfm}

procedure TObjInterfaceFrame.getObj(obj:cbldobj);
begin
  MainObjFrame.chart:=chart;
  MainObjFrame.getobj(obj);
end;

procedure TObjInterfaceFrame.setObj;
begin
  MainObjFrame.setObj;
  update;
end;

procedure TObjInterfaceFrame.update;
begin
  MainObjFrame.getObj(MainObjFrame.curobj);
  events.CallAllEvents(UpdateInterfaceFrame);
end;

procedure TObjInterfaceFrame.ApplyBtnClick(Sender: TObject);
begin
  setobj;
end;

Constructor TObjInterfaceFrame.create(aowner:tcomponent);
begin
  inherited;
end;

destructor TObjInterfaceFrame.destroy;
begin
  inherited;
end;

procedure TObjInterfaceFrame.lincevents(e:ceventlist);
begin
  events:=e;
end;


end.
