unit uTestRussianText;

{$mode objfpc}{$H+}
{$codepage cp1251}

interface

// Это тестовый комментарий на русском языке для проверки редактирования.
// Мы проверяем, как кодировка cp1251 сохраняется при прямых правках.
procedure TestPrintMessage;

implementation

procedure TestPrintMessage;
begin
  // Выводим измененное тестовое сообщение на русском
  WriteLn('Привет! Прямое редактирование cp1251 прошло успешно.');
end;

end.
