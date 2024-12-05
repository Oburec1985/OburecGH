unit uPerformanceTime;

interface
uses
 Classes, SysUtils, Windows;

  Type
    TPerformanceTime=class
    private
      fperiod:double;
      // включен или выключен
      fstate,
      // текущий уровень меандра
      flevel:boolean;
      FDelay :Real; //измеренное время в секундах
      StartTime :Real; //Время начала теста в секундах
    public      constructor Create;      property Delay:Real read FDelay;
      function Start:double;
      // получить время от Start
      function CurTime:double;      function checkCycle:boolean;    end;
  Function GetTimeInSec:Real; //вернет время в секундах, с начало работы ОС


implementation

function GetTimeInSec: Real;
var
  StartCount, Freq: Int64;
begin
  if QueryPerformanceCounter(StartCount) then //возвращает текущее значение счетчика
  begin
    QueryPerformanceFrequency(Freq); //Кол-во тиков в секунду
    Result:=StartCount/Freq; //Результат в секундах
  end
  else
  begin
    Result:=GetTickCount/1000; //1000, т.к GetTickCount вернет милиСекунды
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
  fperiod:=1; // секунда
  TempValue :=GetTimeInSec; //Первый раз холостой, чтобы подгрузить нужные системные dll
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
