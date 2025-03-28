unit CommonOptsFrame;

interface

uses
  Windows, SysUtils, Forms,ubldEngEventTypes, uTickData, uBldObj,
  StdCtrls, ExtCtrls, Spin, ubldtimeproc, uDoubleCursor, uchan,
  uturbina, ustage, uBaseBldAlg, uBldCompProc, usensor, Controls, Classes, uSpin,
  DCL_MYOWN, uBldMath, uCommonMath, uSensorList, uGetSensorsForm, uBldeng,
  uErrorProc, uEventList, uEventTypes, uAlgTagListFrame, uPair, uSaveSignalForm;

type
  TBaseAlgOptsFrame = class(TFrame)
    StageGB: TGroupBox;
    StageCB: TComboBox;
    ValidBladeGB: TGroupBox;
    UseThresholdCB: TCheckBox;
    ThresholdLabel: TLabel;
    ThresholdSE: TFloatSpinEdit;
    CommonGB: TGroupBox;
    SensorNameLabel: TLabel;
    TahoNameLabel: TLabel;
    SkipBladeLabel: TLabel;
    TahoCB: TComboBox;
    SkipBladeIE: TIntEdit;
    SensorsNameCB: TComboBox;
    UseStageInfoCheckBox: TCheckBox;
    SelectSensorsBtn: TButton;
    TagsGB: TGroupBox;
    AlgTagList1: TAlgTagListFrame;
    UseEvalSkipBlades: TCheckBox;
    UseBadTickProcCheckBox: TCheckBox;
    StartTimeLabel: TLabel;
    StartTimeFE: TFloatSpinEdit;
    EndTimeFE: TFloatSpinEdit;
    EndTimeLabel: TLabel;
    ImpulseCountIE: TIntEdit;
    ImpulseCountLabel: TLabel;
    SyncCB: TCheckBox;
    UseBladesPos: TRadioGroup;
    MeraFileCB: TCheckBox;
    UseUTSCB: TCheckBox;
    procedure SensorsNameCBChange(Sender: TObject);
    procedure UseStageInfoCheckBoxClick(Sender: TObject);
    procedure SelectSensorsBtnClick(Sender: TObject);
    procedure SyncCBClick(Sender: TObject);
    procedure StartTimeFEChange(Sender: TObject);
    procedure TagsGBClick(Sender: TObject);
    procedure MeraFileCBClick(Sender: TObject);
  private
    sensor_t1,sensor_t2,cursor_t1, cursor_t2:single;
    eng:cbldeng;
    slist:cAlgsensorList;
    // ������� ������� TAlgEditFrame
    fevents:ceventlist;
  public
    curopts:cbaseopts;
  private
    procedure setUseStageInfo(b:boolean);
    procedure setDisables;
    procedure SetDisableTurnValidGb(i:cardinal);
    procedure updateSList(list:cAlgsensorList);
    procedure UpdateStage(st:cstage);
    procedure SetEventList(e:ceventlist);
    // �������� ���������� �������
    procedure UpdateTimes;
    // ������������������� ���������� �������
    procedure Gettimes(c:cdoublecursor);
    // ��������� ������� ��������
    procedure EvalTimes(o:cBaseOpts);
  public
    procedure SetOpts(t:csensor;sensors:cAlgsensorList; o:cBaseOpts);
    procedure GetOpts(o:cBaseOpts);
  public
    property events:ceventlist read fevents write SetEventList;
  end;

  const
    c_initBladePos = $00000001;
    c_initOffsets = $00000002;

implementation
uses
  upage;
{$R *.dfm}


procedure TBaseAlgOptsFrame.GetOpts(o:cBaseOpts);
begin
  if StageCB.ItemIndex<>-1 then
    o.stage:=cstage(StageCB.Items.Objects[StageCB.ItemIndex]);
  o.useNearest:=UseThresholdCB.Checked;
  o.offset:=ThresholdSE.Value;
  o.useBladesPos:=(UseBladesPos.ItemIndex=1);
  o.callBadTicksProc:=UseBadTickProcCheckBox.Checked;
  o.evalSkipBladesInTurn:=UseEvalSkipBlades.Checked;
  o.usedist:=UseEvalSkipBlades.Checked;
  o.useStageInfo:=UseStageInfoCheckBox.Checked;
  o.taho:=csensor(tahocb.Items.Objects[0]);
  o.useUTS:=UseUTSCB.Checked;
  if o.tags<>nil then
  begin
    AlgTagList1.setAlg;
  end;
  o.startind:=GetT1(o.taho, StartTimeFE.Value);
  o.endind:=GetT1(o.taho, EndTimeFE.Value);
end;

function checkStage(stage:cstage):cardinal;
begin
  result:=0;
  if stage<>nil then
  begin
    if stage.Shape<>nil then
    begin
      if GetOffsetsInit(stage.Shape.blades) then
      begin
        setflag(result,c_initBladePos);
      end;
      if GetOffsetsInit(stage.Shape.offset) then
      begin
        setflag(result,c_initBladePos);
      end;
    end
  end;
end;

procedure TBaseAlgOptsFrame.SetDisableTurnValidGb(i:cardinal);
begin
  if i=0 then
  begin
    StageGB.Enabled:=false;
    UseThresholdCB.Enabled:=false;
    UseBladesPos.ItemIndex:=-1;
  end
  else
  begin
    StageGB.Enabled:=true;
    if not checkflag(i,c_initBladePos) then
    begin
      UseBladesPos.ItemIndex:=0;
      UseBladesPos.Enabled:=false;
    end;
    if not checkflag(i,c_initOffsets) then
    begin
      UseBladesPos.ItemIndex:=1;
      UseBladesPos.Enabled:=false;
    end;
  end;
end;

procedure ShowNames(sensors:calgSensorList; cb:TComboBox);
var
  i:integer;
  s:csensor;
begin
  cb.Clear;
  for I := 0 to sensors.Count - 1 do
  begin
    s:=sensors.GetSensor(i);
    cb.Items.AddObject(s.name,s);
  end;
  if sensors.Count>0 then
    cb.ItemIndex:=0;
end;

procedure TBaseAlgOptsFrame.setUseStageInfo(b:boolean);
begin
  stagegb.Enabled:=b;
  UseStageInfoCheckBox.Checked:=b;
  UseBladesPos.Enabled:=b;
  ValidBladeGB.Enabled:=b;
  UseThresholdCB.Enabled:=b;
  ThresholdSE.Enabled:=b;
  stagecb.Enabled:=b;
end;


procedure TBaseAlgOptsFrame.UpdateTimes;
begin
  if synccb.checked then
  begin
    StartTimeFe.Value:=cursor_t1;
    EndTimeFe.Value:=cursor_t2;
    StartTimeFe.Enabled:=false;
    EndTimeFe.Enabled:=false;
  end
  else
  begin
    StartTimeFe.Value:=sensor_t1;
    EndTimeFe.Value:=sensor_t2;
    StartTimeFe.Enabled:=true;
    EndTimeFe.Enabled:=true;
  end;
end;

procedure TBaseAlgOptsFrame.EvalTimes;
var
  t:csensor;
begin
  t:=csensor(tahocb.Items.Objects[0]);
  o.startind:=GetT1(t, StartTimeFE.Value);
  o.endind:=GetT1(t, EndTimeFE.Value);
  if o.endind=t.tickscount-1 then
    o.endind:=o.endind-2;
  ImpulseCountIE.IntNum:=o.endind-o.startind;
end;

procedure TBaseAlgOptsFrame.StartTimeFEChange(Sender: TObject);
begin
  EvalTimes(curopts);
end;

procedure TBaseAlgOptsFrame.SyncCBClick(Sender: TObject);
begin
  UpdateTimes;
end;

procedure TBaseAlgOptsFrame.TagsGBClick(Sender: TObject);
begin

end;

// ����� ������ ������ �� t
function GetT2(s:csensor;t:single):integer;
var
  tick:stickdata;
begin
  if s.tickscount<>0 then
  begin
    tick:=SecToTick(t);
    s.chan.ticks.GetHiTick(tick,result);
  end
  else
    result:=-1;
end;

procedure TBaseAlgOptsFrame.SetOpts(t:csensor;sensors:cAlgsensorList; o:cBaseOpts);
var
  s:csensor;
  obj:cbldobj;
  stage:cstage;
  I: Integer;
begin
  stage:=o.stage;
  s:=nil;
  if o<>nil then
    eng:=o.eng;
  AlgTagList1.Linc(nil,cbldtimeproc(eng.timeProc));
  slist:=sensors;
  s:=sensors.GetSensor(0);
  setUseStageInfo(o.useStageInfo);
  updatestage(stage);
  updateSList(sensors);
  // ������������ UTS
  UseUTSCB.Checked:=o.useUTS;
  if eng.UTS=nil then
  begin
    UseUTSCB.Checked:=false;
    UseUTSCB.Enabled:=false;
  end;
  // ���������� �����������
  ShowTahoInCB(o.eng, TahoCB);
  if s<>nil then
  begin
    SkipBladeIE.IntNum:=s.skipBlade;
  end;
  if t<>nil then
  begin
    TahoCB.Text:=t.name;
  end;
  UseBadTickProcCheckBox.Checked:=o.callBadTicksProc;
  // ���������� ��������� ���������
  // ������������ ��������� ��������
  UseThresholdCB.Checked:=o.useNearest;
  // ������ �� ���������� ������� ������� �� ��������� ����������
  ThresholdSE.Value:=o.offset;
  if o.useBladesPos then
    UseBladesPos.ItemIndex:=1
  else
    UseBladesPos.ItemIndex:=0;
  // �������� ���������� ����� �������
  SetDisableTurnValidGb(checkStage(stage));
  UseEvalSkipBlades.Checked:=o.evalSkipBladesInTurn;
  if o.tags<>nil then
  begin
    AlgTagList1.getAlg(o.tags);
  end;
  curopts:=o;
  if o.taho=nil then
  begin
    obj:=sensors.GetSensor(0);
    if o.chart<>nil then
    begin
      Gettimes(cpage(o.chart.activePage).cursor);
    end
    else
    begin
      if t<>nil then
      begin
        sensor_t1:=t.getTStart;
        sensor_t2:=t.getTEnd;

        SyncCB.Enabled:=false;
        StartTimeFE.MinValue:=sensor_t1;
        StartTimeFE.MaxValue:=sensor_t2;
        StartTimeFE.Value:=sensor_t1;
        EndTimeFE.MinValue:=sensor_t1;
        EndTimeFE.MaxValue:=sensor_t2;
        EndTimeFE.Value:=sensor_t2;

        o.startind:=0;
        o.endind:=t.tickscount-1;
        ImpulseCountIE.IntNum:=o.endind-o.startind;
      end;
    end;
  end;
end;

procedure TBaseAlgOptsFrame.UseStageInfoCheckBoxClick(Sender: TObject);
begin
  setUseStageInfo(UseStageInfoCheckBox.Checked);
end;

procedure TBaseAlgOptsFrame.SelectSensorsBtnClick(Sender: TObject);
begin
  if (slist<>nil) and (eng<>nil) then
  begin
    SelectSensorsForm.ShowModal(slist, eng);
    updateSList(slist);
  end
end;

procedure TBaseAlgOptsFrame.updateSList(list:cAlgsensorList);
var
  I: Integer;
begin
  i:=0;
  // ���������� ���������� �������
  while I < slist.Count - 1 do
  begin
    if slist.GetSensor(i).sensortype=c_rot then
    begin
      slist.Delete(i);
    end;
    inc(i);
  end;
  ShowNames(slist,SensorsNameCB);
  //if events<>nil then
  //  events.CallAllEventsWithSender(e_OnChangeAlgList,slist);
end;

procedure TBaseAlgOptsFrame.SensorsNameCBChange(Sender: TObject);
var
  s:csensor;
begin
  if sensorsnamecb.ItemIndex>=0 then
  begin
    s:=csensor(sensorsnamecb.Items.Objects[sensorsnamecb.ItemIndex]);
    SkipBladeIE.IntNum:=s.skipBlade;
  end;
end;

procedure TBaseAlgOptsFrame.setDisables;
var
  obj:cstage;
begin
  obj:=cstage(StageCB.Items.Objects[StageCB.itemindex]);
  setUseStageInfo(obj<>nil);
end;

procedure TBaseAlgOptsFrame.UpdateStage(st:cstage);
begin
  ShowStageInCB(eng,stagecb);
  stagecb.ItemIndex:=-1;
  if st=nil then
  begin
    setUseStageInfo(false);
  end
  else
  begin
    if stagecb.items.IndexOfName(st.name)<0 then
    begin
      stagecb.AddItem(st.name,st);
      Stagecb.Text:=st.name;
      stagecb.ItemIndex:=0;
    end;
  end;
  if events<>nil then
    events.CallAllEventsWithSender(e_OnChangeStageAlg, self);
end;

procedure TBaseAlgOptsFrame.SetEventList(e:ceventlist);
begin
  fevents:=e;
end;

procedure TBaseAlgOptsFrame.Gettimes(c:cdoublecursor);
var
  t:csensor;
begin
  t:=csensor(tahocb.Items.Objects[0]);
  sensor_t1:=t.getTStart;
  sensor_t2:=t.getTEnd;
  cursor_t1:=c.getx1;
  cursor_t2:=c.getx2;
  if cursor_t1>sensor_t2 then
  begin
    cursor_t1:=sensor_t1;
    cursor_t2:=sensor_t2;
  end
  else
  begin
    if cursor_t1<sensor_t1 then
    begin
      cursor_t1:=sensor_t1;
    end;
  end;
  if cursor_t2>sensor_t2 then
  begin
    cursor_t2:=sensor_t2;
  end
  else
  begin
    if cursor_t2<cursor_t1 then
      cursor_t2:=sensor_t2
  end;
  StartTimeFE.MinValue:=sensor_t1;
  StartTimeFE.MaxValue:=sensor_t2;
  StartTimeFE.Value:=sensor_t1;

  EndTimeFE.MinValue:=sensor_t1;
  EndTimeFE.MaxValue:=sensor_t2;
  EndTimeFE.Value:=sensor_t2;

  UpdateTimes;
end;

procedure TBaseAlgOptsFrame.MeraFileCBClick(Sender: TObject);
begin
  if MeraFileCB.Checked then
  begin
    if SaveSignalsForm.ShowModal(curopts) =mrok then
    begin
    end
    else
      MeraFileCB.Checked:=false;
  end;
  cBaseOpts(curopts).SaveSignals:=MeraFileCB.Checked;
end;

end.
