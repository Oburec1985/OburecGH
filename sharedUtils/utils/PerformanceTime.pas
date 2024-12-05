unit PerformanceTime;
{ ============================================================================
 ������ PerformanceTime �������� �������� ������ TPerformanceTime, �������
 ��������� �������� ����� ���������� ����� ����. ���������� ����������������
 ���������� ���� TPerformanceTime, ��������� ����� Start. ��������� ������
(���)
 ��������� ����� Stop, ����� ���� � ��-�� Delay ����� ����� ���������� ����
 � ��������.
 ������:
 T:=TPerformanceTime.Create;
 T.Start;
 Sleep(1000);
 T.Stop;
 Caption:=FloatToStr(T.Delay);//������� ����� ������ 1 ������� +/-
�����������
 ����������: ��������� �������� ����� ���������� ����. ���� ��� "�������" �����
 ������������ for I:=1 to N do (���), ����� ���� ���������� ����� ���������
 �� N, ��� ���� ��� ���� N ��� ������ ����� ���������.
 ��� ���� ������� ����������, �� �� ���� �������� ������ ���� ����, �� �������
 ���� � Windows.
 ����� ����������: Lazarus v0.9.29 beta � ����
 ����������: FPC v 2.4.1 � ����
 �����: Maxizar
 ���� ��������: 03.03.2010
 ���� ��������������: 12.05.2011
 }

interface
uses
 Classes, SysUtils, Windows;

Type

  TPerformanceTime=class
  private
    fperiod:double;
    // ������� ��� ��������
    fstate:boolean;
    FDelay :Real; //���������� ����� � ��������
    StartTime :Real; //����� ������ ����� � ��������
  public    constructor Create;    property Delay:Real read FDelay;
    function Start:double;
    // �������� ����� �� Start
    function CurTime:double;    function checkCycle:boolean;  end;
  Function GetTimeInSec:Real; //������ ����� � ��������, � ������ ������ ��


implementation

function GetTimeInSec: Real;
var
  StartCount, Freq: Int64;
begin
  if QueryPerformanceCounter(StartCount) then //���������� ������� �������� ��������
  begin
    QueryPerformanceFrequency(Freq); //���-�� ����� � �������
    Result:=StartCount/Freq; //��������� � ��������
  end
  else
  begin
    Result:=GetTickCount/1000; //1000, �.� GetTickCount ������ �����������
  end;
end;

// TPerformanceTime
function TPerformanceTime.checkCycle: boolean;
begin
  if fstate then
  begin
    Start;
  end
  else
  begin
    if CurTime>fperiod then
    begin

    end;
  end;
end;

constructor TPerformanceTime.Create;
var
  TempValue:Real;
begin
  fperiod:=1; // �������
  TempValue :=GetTimeInSec; //������ ��� ��������, ����� ���������� ������ ��������� dll
  fstate:=false;
end;

function TPerformanceTime.Start:double;
begin
  fstate:=true;
  StartTime:=GetTimeInSec;
  result:=StartTime;
end;


function TPerformanceTime.CurTime:double;
begin
  FDelay:=GetTimeInSec-StartTime;
  Result:=FDelay;
  fstate:=false;
end;

end.
