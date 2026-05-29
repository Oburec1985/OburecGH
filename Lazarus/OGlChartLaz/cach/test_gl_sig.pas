program test_gl_sig;
{$mode objfpc}{$H+}
uses
  gl, glext;

var
  b: Boolean;
begin
  b := Load_GL_version_2_0;
end.
