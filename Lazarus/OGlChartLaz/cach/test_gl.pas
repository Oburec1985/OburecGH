program test_gl;
{$mode objfpc}{$H+}
uses
  gl, glext;

var
  p: Pointer;
begin
  // Проверим наличие типов и функций в glext
  p := @glCreateShader;
  WriteLn('glCreateShader is declared');
end.
