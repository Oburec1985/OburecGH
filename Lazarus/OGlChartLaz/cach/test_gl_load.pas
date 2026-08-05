program test_gl_load;
{$mode objfpc}{$H+}
uses
  gl, glext;

begin
  // Проверим, инициализированы ли указатели по умолчанию, или есть ли функция инициализации
  if Assigned(glCreateShader) then
    WriteLn('glCreateShader pointer is assigned')
  else
    WriteLn('glCreateShader pointer is nil');
end.
