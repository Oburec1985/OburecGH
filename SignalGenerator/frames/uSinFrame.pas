unit uSinFrame;

interface

uses
  Windows, Forms,  StdCtrls, DCL_MYOWN, Controls, Classes, math,
  uCommonMath,
  umeraSignal, uBuffSignal, mathfunction;

type
  TSinFrame = class(TFrame)
    FreqLabel: TLabel;
    FreqFE: TFloatEdit;
    EndFreqLabel: TLabel;
    EndFreqFE: TFloatEdit;
    ChangeFreqCB: TCheckBox;
    PhaseLabel: TLabel;
    PhaseEdit: TFloatEdit;
    EndPhaseLabel: TLabel;
    EndPhaseEdit: TFloatEdit;
    ChangePhaseCB: TCheckBox;
    DscEdit: TEdit;
    DscLabel: TLabel;
    ChangePeriodFreqCB: TCheckBox;
    FreqPeriodLabel: TLabel;
    FreqPeriodFE: TFloatEdit;
    ChangePeriodPhaseCB: TCheckBox;
    PhasePeriodLabel: TLabel;
    PhasePeriodFE: TFloatEdit;
    ALabel: TLabel;
    EndALabel: TLabel;
    PeriodALabel: TLabel;
    AFE: TFloatEdit;
    EndAFE: TFloatEdit;
    ChangeACB: TCheckBox;
    ChangePeriodACB: TCheckBox;
    PeriodAFE: TFloatEdit;
    Label1: TLabel;
    TimeLengthFE: TFloatEdit;
    procedure ChangePeriodFreqCBClick(Sender: TObject);
    procedure ChangePhaseCBClick(Sender: TObject);
    procedure ChangeACBClick(Sender: TObject);
  private
    m_s:cBuffSignal;
  private
    function createFreqDsc:string;
    function createPhaseDsc:string;
    function createADsc:string;
    function createDsc:string;
    function GetPhase(t:single):single;
    function GetA(t:single):single;
    function GetF(t:single):single;
    Procedure SetVisiBleFreq(b:boolean);
    Procedure SetVisiBlePhase(b:boolean);
    Procedure SetVisiBleA(b:boolean);
  public
    constructor create(aOwner:TComponent);override;
    procedure CreateSignal(s:cBuffSignal);
  end;
  // ChangeV - ������ �������� �� ��������� ������ ��� �������
  // ChangePeriod - ������ �������� �������� � �������� period
  // V0, V1 - ��������� � �������� ��������
  // t - ������� �����
  function ChangeValue(V0,V1,period,t,timelength:single;ChangeV,ChangePeriod:boolean):single;

implementation

{$R *.dfm}

function TSinFrame.createFreqDsc:string;
begin
  result:='F='+formatstr(FreqFE.FloatNum,3);
  if ChangeFreqCB.Checked then
  begin
    result:=result+'..'+formatstr(EndFreqFE.FloatNum,3);
    if ChangePeriodFreqCB.Checked then
    begin
      result:=result+' P='+formatstr(FreqPeriodFE.FloatNum,2);
    end;
  end;
  result:=result+'/ ';
end;

function TSinFrame.createPhaseDsc:string;
begin
  result:='Phase='+formatstr(PhaseEdit.FloatNum,3);
  if ChangePhaseCB.Checked then
  begin
    result:=result+'..'+formatstr(EndPhaseEdit.FloatNum,3);
    if ChangePeriodPhaseCB.Checked then
    begin
      result:=result+' P='+formatstr(PhasePeriodFE.FloatNum,2);
    end;
  end;
  result:=result+'/ ';
end;

function TSinFrame.createADsc:string;
begin
  result:='A='+formatstr(AFE.FloatNum,3);
  if ChangeACB.Checked then
  begin
    result:=result+'..'+formatstr(EndAFE.FloatNum,3);
    if ChangePeriodACB.Checked then
    begin
      result:=result+' P='+formatstr(PeriodAFE.FloatNum,2);
    end;
  end;
  result:=result+'/ ' + createPhaseDsc;
end;

function TSinFrame.createDsc:string;
begin
  result:='Sin '+createFreqDsc + createPhaseDsc + createADsc;
end;

function ChangeValue(V0,V1,period,t, timelength:single;ChangeV,ChangePeriod:boolean):single;
var
  // ����� �������� ������� ������ ������
  pCount:integer;
  dPhase:single;
begin
  if ChangeV then
  begin
    // ���� ������ ���� ��������
    if ChangePeriod then
    begin
      pCount:=trunc(t/period);
      dPhase:=(v1 - v0)/Timelength;
      result:=dPhase*pCount+v0;
    end
    // ���� ������ ���� ����������
    else
    begin
      result:=((v1 - v0)*t/Timelength)
              +v0;
    end;
  end
  else
    result:=v0;
end;

function TSinFrame.GetPhase(t:single):single;
begin
  result:=ChangeValue(PhaseEdit.FloatNum,
                      EndPhaseEdit.FloatNum,
                      PhasePeriodFE.FloatNum,
                      t,
                      m_s.GetTEnd,
                      ChangePhaseCB.Checked,
                      ChangePeriodPhaseCB.Checked);
end;

function TSinFrame.GetA(t:single):single;
begin
  result:=ChangeValue(AFE.FloatNum,
                      EndAFE.FloatNum,
                      PeriodAFE.FloatNum,
                      t,
                      m_s.GetTEnd,
                      ChangeACB.Checked,
                      ChangePeriodACB.Checked);
end;

function TSinFrame.GetF(t:single):single;
begin
  result:=ChangeValue(freqFE.FloatNum,
                      EndFreqFE.FloatNum,
                      FreqPeriodFE.FloatNum,
                      t,
                      m_s.GetTEnd,
                      ChangeFreqCB.Checked,
                      ChangePeriodFreqCB.Checked);
end;

procedure TSinFrame.CreateSignal(s:cBuffSignal);
var
  i:integer;
  // ������� ���������
  Amplitude,
  // ������� �����
  t,
  // ���������� ������� ��� ������ ������� �������������
  dt,dt2,
  // �������� ���� ���������� �������
  phaseShift,
  // ������� ������� ���������� �������
  freq,
  // ������� �������� � ��������
  W1,W2, A,
  phase,
  pi2
  :single;
begin
  //s.SignalLength:=trunc(s.fs*TimeLengthFE.FloatNum);
  m_s:=s;
  m_s.dsc:=s.dsc+createDsc;
  // ��������� ����� pi
  pi2:=2*pi;
  dt:=1/m_s.freqx;
  dt2:=dt*dt/2;
  phase:=0;
  w1:=getF(0)*pi2;
  for I := 0 to m_s.Count - 1 do
  begin
    t:=i*dt;
    Amplitude:=getA(t);
    // ������� �������
    freq:=getF(t);
    // ������� �������� � ��������
    w2:=pi2*freq;
    // ��������� � ��������
    A:=(w2-w1)/dt;
    // �������� ����
    phaseShift:=getphase(t);
    // ������� ����
    phase:=phase+w1*dt+dt2*a+phaseshift;
    s.points1d[i]:=Amplitude*sin(phase);
    w1:=w2;
  end;
end;

Procedure TSinFrame.SetVisiBleFreq(b:boolean);
begin
  if b then
  begin
    EndFreqLabel.visible:=true;
    EndFreqFE.visible:=true;
    ChangePeriodFreqCB.visible:=true;
    if ChangePeriodFreqCB.Checked then
    begin
      FreqPeriodLabel.Visible:=true;
      FreqPeriodFE.Visible:=true;
    end
    else
    begin
      FreqPeriodLabel.Visible:=false;
      FreqPeriodFE.Visible:=false;
    end;
  end
  else
  begin
    EndFreqLabel.visible:=false;
    EndFreqFE.visible:=false;
    ChangePeriodFreqCB.visible:=false;
    FreqPeriodLabel.Visible:=false;
    FreqPeriodFE.Visible:=false;
  end;
end;

Procedure TSinFrame.SetVisiBleA(b:boolean);
begin
  if b then
  begin
    EndALabel.visible:=true;
    EndAFE.visible:=true;
    ChangePeriodACB.visible:=true;
    if ChangePeriodACB.Checked then
    begin
      PeriodALabel.Visible:=true;
      PeriodAFE.Visible:=true;
    end
    else
    begin
      PeriodALabel.Visible:=false;
      PeriodAFE.Visible:=false;
    end;
  end
  else
  begin
    EndALabel.visible:=false;
    EndAFE.visible:=false;
    ChangePeriodACB.visible:=false;
    PeriodALabel.Visible:=false;
    PeriodAFE.Visible:=false;
  end;
end;

Procedure TSinFrame.SetVisiBlePhase(b:boolean);
begin
  if b then
  begin
    EndPhaseLabel.visible:=true;
    EndPhaseEdit.visible:=true;
    ChangePeriodPhaseCB.visible:=true;
    if ChangePeriodPhaseCB.Checked then
    begin
      PhasePeriodLabel.Visible:=true;
      PhasePeriodFE.Visible:=true;
    end
    else
    begin
      PhasePeriodLabel.Visible:=false;
      PhasePeriodFE.Visible:=false;
    end;
  end
  else
  begin
    EndPhaseLabel.visible:=false;
    EndPhaseEdit.visible:=false;
    ChangePeriodPhaseCB.visible:=false;
    PhasePeriodLabel.Visible:=false;
    PhasePeriodFE.Visible:=false;
  end;
end;

procedure TSinFrame.ChangeACBClick(Sender: TObject);
begin
  SetVisiBleA(ChangeACB.Checked);
end;

procedure TSinFrame.ChangePeriodFreqCBClick(Sender: TObject);
begin
  SetVisiBleFreq(ChangeFreqCB.Checked);
end;

procedure TSinFrame.ChangePhaseCBClick(Sender: TObject);
begin
  SetVisiBlePhase(ChangePhaseCB.Checked);
end;

constructor TSinFrame.create(aOwner:TComponent);
begin
  inherited;
  SetVisiBlePhase(ChangePhaseCB.Checked);
  SetVisiBleA(ChangeACB.Checked);
  SetVisiBleFreq(ChangeFreqCB.Checked);
end;


end.
