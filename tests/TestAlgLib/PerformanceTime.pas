unit PerformanceTime;
{ ============================================================================
 Модуль PerformanceTime содержит описание класса TPerformanceTime, который
 позволяет измерить время выполнения куска кода. Необходимо инициализировать
 переменную типа TPerformanceTime, выполнить метод Start. проделать работу
(код)
 Выполнить метод Stop, после чего в св-ве Delay будет время выполнения кода
 в секундах.
 Пример:
 T:=TPerformanceTime.Create;
 T.Start;
 Sleep(1000);
 T.Stop;
 Caption:=FloatToStr(T.Delay);//покажет время равное 1 секунде +/-
погрешность
 Примечание: Позволяет измерять время выполнения кода. Если код "быстрый" можно
 использовать for I:=1 to N do (Код), после чего полученное время разделить
 на N, При этом чем выше N тем меньше будет дисперсия.
 Чем выше частота процессора, то по идее точность должна быть выше, по крайней
 мере в Windows.
 Среда разработки: Lazarus v0.9.29 beta и выше
 Компилятор: FPC v 2.4.1 и выше
 Автор: Maxizar
 Дата создания: 03.03.2010
 Дата редактирования: 12.05.2011
 }

interface
uses
 Classes, SysUtils,
 Windows;

  Type
    TPerformanceTime=class
    private
      FDelay :Real; //измеренное время в секундах
      StartTime :Real; //Время начала теста в секундах
    public      constructor Create;      property Delay:Real read FDelay;
      procedure Start;
      function Stop:double;    end;
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
    Result:=GetTickCount/1000; //1000, т.к GetTickCount вернет милиСекунды
end;

// TPerformanceTime
//------------------------------------------------------------------//
constructor TPerformanceTime.Create;
var
  TempValue:Real;
begin
  TempValue :=GetTimeInSec; //Первый раз холостой, чтобы подгрузить нужные системные dll
  TempValue :=GetTimeInSec; //Ну на всякий случай :)
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
