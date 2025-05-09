unit uPairShapeFrame;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  ExtCtrls, CommonOptsFrame, StdCtrls,
  ubldeng, uBaseBldAlg, uDensityAlg, uMultiSensor, uPairShape,
  uRestoreVibrationAlg, uTrendAlg,  Spin, usensorlist, usensor, ustage, uBldCompProc,
  ueventlist, uEventTypes, ubldEngEventTypes;

type
  TpairShapeFrame = class(TFrame)
    Label1: TLabel;
    PortionSE: TSpinEdit;
    SkipBladeLabel: TLabel;
    SkipBladeSE: TSpinEdit;
    EvalPortionCB: TCheckBox;
    procedure EvalPortionCBClick(Sender: TObject);
  private
    eng:cbldeng;
    slist:cAlgSensorList;
    fevents:ceventlist;
  private
    procedure EvalSkipBlades;
    procedure SetEventList(e:ceventlist);
    // ���������� ����� ����������� � CommonOptsFrame ������ ������������ ��������
    Procedure DoOnUpdateSList(sender:tobject);
  public
    procedure setopts(t:csensor;sensorlist:calgsensorlist;opts:cPairShapeOpts);
    procedure getopts(o:cPairShapeOpts);
    property events:ceventlist read fevents write SetEventList;
  end;

implementation

{$R *.dfm}
procedure ShowNames(sensors:calgSensorList; cb:TComboBox);
var
  i:integer;
begin
  cb.Clear;
  for I := 0 to sensors.Count - 1 do
  begin
    cb.Items.Add(sensors.GetSensor(i).name);
  end;
  if sensors.Count>0 then
    cb.ItemIndex:=0;
end;

procedure TpairShapeFrame.EvalSkipBlades;
var
  s1,s2:csensor;
begin
  s1:=slist.GetSensor(0);
  if s1=nil then exit;
  //s1.EvalSkipBlades;
  s2:=slist.GetSensor(1);
  //s2.EvalSkipBlades;
  SkipBladeSE.Value:=abs(s2.skipBlade - s1.skipBlade);
end;

procedure TpairShapeFrame.setopts(t:csensor;sensorlist:calgsensorlist;opts:cPairShapeOpts);
var
  s:csensor;
  stage:cstage;
begin
  s:=nil;
  stage:=nil;
  slist:=sensorlist;
  s:=sensorlist.GetSensor(0);
  if s<>nil then
  begin
    EvalSkipBlades;
    stage:=cstage(s.stage);
  end;
  eng:=opts.eng;
  PortionSE.Value:=opts.PointForEvalCount;
  EvalPortionCB.Checked:=opts.EvalPointCount;
end;

procedure TpairShapeFrame.getopts(o:cPairShapeOpts);
begin
  o.skipblade:=SkipBladeSE.Value;
  o.PointForEvalCount:=PortionSE.Value;
  o.EvalPointCount:=EvalPortionCB.Checked;
end;

procedure TpairShapeFrame.SetEventList(e:ceventlist);
begin
  fevents:=e;
  events.AddEvent('TpairShapeFrame_OnUpdateSlist',e_OnChangeAlgList,DoOnUpdateSList);
end;

procedure TpairShapeFrame.EvalPortionCBClick(Sender: TObject);
begin
  PortionSE.Enabled:=not EvalPortionCB.Checked;
end;

Procedure TpairShapeFrame.DoOnUpdateSList(sender:tobject);
var
  I: Integer;
begin
  if slist<>nil then
  begin
    if slist.Count>2 then
    begin
      eng.getmessage('� ������ ������ 2-� ��������',c_errorMessage);
      // ���������� ������ ������� �� ������
      for I := slist.count-1 downto 1 do
      begin
        slist.Delete(i);
      end;
    end;
    EvalSkipBlades;
  end;
end;

end.
