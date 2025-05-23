unit uGetTimeForm;

interface

uses
  Windows, SysUtils, Forms, uTickData, uBldObj,
  StdCtrls, ExtCtrls, Spin, uDoubleCursor, uchan,
  uBaseBldAlg, uBldCompProc, usensor, Controls, Classes, uSpin,
  DCL_MYOWN, uBldMath, uCommonMath, uSensorList, uBldeng,
  uEventList, uEventTypes;

type
  TGetTimeForm = class(TForm)
    StartTimeLabel: TLabel;
    EndTimeLabel: TLabel;
    ImpulseCountLabel: TLabel;
    StartTimeFE: TFloatSpinEdit;
    EndTimeFE: TFloatSpinEdit;
    ImpulseCountIE: TIntEdit;
    SyncCB: TCheckBox;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    SensorLabel: TLabel;
    SensorsNameCB: TComboBox;
    procedure SensorsNameCBChange(Sender: TObject);
    procedure SyncCBClick(Sender: TObject);
  private
    sensor_t1,sensor_t2,cursor_t1, cursor_t2:single;
  public
    startind,endind:integer;
  private
    // ������������ ����� �������� � ��������
    procedure UpdateTimes;
    // ������������� ������ � ���������
    procedure Gettimes;
    // ���������� �������� �� ������� �� ������ �� ���������
    procedure EvalTimes;
    procedure GetEng(eng:cbldeng;t1,t2:single);
  public
    function Showmodal_(eng:cbldeng; t1, t2:single):integer;
  end;

var
  GetTimeForm: TGetTimeForm;

implementation

{$R *.dfm}

procedure TGetTimeForm.UpdateTimes;
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
  EvalTimes;
end;

procedure TGetTimeForm.EvalTimes;
var
  t:csensor;
begin
  if SensorsNameCB.ItemIndex=-1 then
    SensorsNameCB.ItemIndex:=0;
  t:=csensor(SensorsNameCB.Items.Objects[SensorsNameCB.ItemIndex]);
  startind:=GetT1(t, StartTimeFE.Value);
  endind:=GetT1(t, EndTimeFE.Value);
  ImpulseCountIE.IntNum:=endind-startind;
end;


procedure TGetTimeForm.Gettimes;
var
  t:csensor;
begin
  if SensorsNameCB.ItemIndex=-1 then
    SensorsNameCB.ItemIndex:=0;
  t:=csensor(SensorsNameCB.Items.Objects[SensorsNameCB.ItemIndex]);
  sensor_t1:=t.getTStart;
  sensor_t2:=t.getTEnd;
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

  EndTimeFE.MinValue:=sensor_t1;
  EndTimeFE.MaxValue:=sensor_t2;
  // ������������ ����� �������� � ��������
  UpdateTimes;
end;

procedure TGetTimeForm.GetEng(eng:cbldeng; t1, t2:single);
begin
  cursor_t1:=t1;
  cursor_t2:=t2;
  ShowTahoInCB(eng,SensorsNameCB);
  // ������������� ������ � ���������
  Gettimes;
end;

procedure TGetTimeForm.SensorsNameCBChange(Sender: TObject);
begin
  updatetimes;
end;

function TGetTimeForm.Showmodal_(eng:cbldeng; t1, t2:single):integer;
begin
  GetEng(eng,t1,t2);
  result:=inherited Showmodal;
  if result=mrok then
  begin
    EvalTimes;
  end;
end;


procedure TGetTimeForm.SyncCBClick(Sender: TObject);
begin
  UpdateTimes;
end;

end.
