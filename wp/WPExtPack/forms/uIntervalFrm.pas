unit uIntervalFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uIntervalFrame, StdCtrls, ExtCtrls, uWpProc;

type
  TIntervalFrm = class(TForm)
    IntervalFrame1: TIntervalFrame;
    Panel2: TPanel;
    CancelBtn: TButton;
    ApplyBtn: TButton;
  private
    procedure EditOper(o:coperobj);
  public
    procedure linc(m:cWpObjMng);
  end;

var
  IntervalFrm: TIntervalFrm;

implementation

{$R *.dfm}

procedure TIntervalFrm.linc(m:cWpObjMng);
begin
  IntervalFrame1.LincMNG(m);
end;

procedure TIntervalFrm.EditOper(o:coperobj);
var
  res:integer;
begin
  IntervalFrame1.ShowInterval(o.Interval);
  res:=showmodal;
  if res=mrok then
  begin
    o.Interval:=IntervalFrame1.GetInterval;
  end;
end;

end.
