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
 Classes, SysUtils,
 Windows;

  Type
    TPerformanceTime=class
    private
      FDelay :Real; //���������� ����� � ��������
      StartTime :Real; //����� ������ ����� � ��������
    public      constructor Create;      property Delay:Real read FDelay;
      procedure Start;
      function Stop:double;    end;
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
    Result:=GetTickCount/1000; //1000, �.� GetTickCount ������ �����������
end;

// TPerformanceTime
//------------------------------------------------------------------//
constructor TPerformanceTime.Create;
var
  TempValue:Real;
begin
  TempValue :=GetTimeInSec; //������ ��� ��������, ����� ���������� ������ ��������� dll
  TempValue :=GetTimeInSec; //�� �� ������ ������ :)
end;
//------------------------------------------------------------------//
procedure TPerformanceTime.Start;
begin
  StartTime:=GetTimeInSec;
end;
//------------------------------------------------------------------//
function TPerformanceTime.Stop;
begin
  FDelay:=GetTimeInSec-StartTime;
  result:=FDelay;
end;

end.
