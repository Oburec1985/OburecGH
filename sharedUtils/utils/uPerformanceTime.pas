unit uPerformanceTime;

interface
uses
 Classes, SysUtils, Windows;

  Type
    TPerformanceTime=class
    private
      fperiod:double;
      // ������� ��� ��������
      fstate,
      // ������� ������� �������
      flevel:boolean;
      FDelay :Real; //���������� ����� � ��������
      StartTime :Real; //����� ������ ����� � ��������
    public      constructor Create;      property Delay:Real read FDelay;
      function Start:double;
      // �������� ����� �� Start
      function CurTime:double;      function checkCycle:boolean;    end;
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

function TPerformanceTime.checkCycle: boolean;
begin
  IF not fstate then
  begin
    Start;
  end
  else
  begin
    if curtime>fperiod then
    begin
      start;
      result:=not flevel;
    end;
  end;
  result:=flevel;
end;

constructor TPerformanceTime.Create;
var
  TempValue:Real;
begin
  fperiod:=1; // �������
  TempValue :=GetTimeInSec; //������ ��� ��������, ����� ���������� ������ ��������� dll
  fstate:=false;
  flevel:=false;
end;

function TPerformanceTime.Start:double;
begin
  StartTime:=GetTimeInSec;
  result:=StartTime;
  fstate:=true;
end;


function TPerformanceTime.CurTime:double;
begin
  FDelay:=GetTimeInSec-StartTime;
  Result:=FDelay;
end;

end.
