unit uShockFrame;

interface

uses
  Windows, Forms,  StdCtrls, DCL_MYOWN, uMeraSignal, Controls, Classes, math,
  uCommonMath, mathfunction, uBuffSignal;

type
  TShockFrame = class(TFrame)
    LengthLabel: TLabel;
    LengthFE: TFloatEdit;
    ALabel: TLabel;
    AFE: TFloatEdit;
    BeforeShockLabel: TLabel;
    BeforeShockFE: TFloatEdit;
    AfterShockLabel: TLabel;
    AfterShockFE: TFloatEdit;
    DscLabel: TLabel;
    DscEdit: TEdit;
  private
    m_s:csignal;
  private
    function createDsc:string;
  public
    procedure CreateSignal(s:csignal);
  end;

implementation

{$R *.dfm}
function TShockFrame.createDsc:string;
begin
  result:='F='+formatstr(m_s.freqx,3)+'/ ������������=' +formatstr(LengthFE.FloatNum,3)
  +'/ A='+formatstr(AFE.FloatNum,3)+'/ T0='+formatstr(BeforeShockFE.FloatNum,3)+
  '/ T1='+formatstr(AfterShockFE.FloatNum,3);
  dscEdit.text:=result;
end;


procedure TShockFrame.CreateSignal(s:csignal);
var
  i:integer;
  // ������� �����
  t,
  // ���������� ������� ��� ������ ������� �������������
  dt,
  pi2,
  // ������� �������� � ��������
  w,
  phase,
  // ������� ������ � �����
  SinFreq:single;
begin
  m_s:=s;
  s.capacity:=trunc(s.freqX*(lengthfe.FloatNum+BeforeShockFE.FloatNum+AfterShockFE.FloatNum));
  s.dsc:=s.dsc+createDsc;
  dt:=1/s.freqX;
  // ��������� ����� pi
  pi2:=2*pi;
  t:=0;
  i:=0;
  // ������� 0 ����� ������
  while t<BeforeShockFE.FloatNum do
  begin
    cBuffSignal(s).points1d[i]:=0;
    t:=t+dt;
    inc(i);
  end;
  t:=0;
  SinFreq:=1/(LengthFE.FloatNum*2);
  w:=SinFreq*pi2;
  phase:=0;
  // ������� ���� (���������)
  while t<LengthFE.FloatNum do
  begin
    cBuffSignal(s).points1d[i]:=Afe.FloatNum*sin(phase);
    t:=t+dt;
    phase:=w*t;
    inc(i);
  end;
  t:=0;
  // ������� ����� �����
  while (t<AfterShockFE.FloatNum) and (i<cBuffSignal(s).GetTEnd) do
  begin
    cBuffSignal(s).points1d[i]:=0;
    t:=t+dt;
    inc(i);
  end;
end;

end.
