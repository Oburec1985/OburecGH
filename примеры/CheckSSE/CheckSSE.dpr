program CheckSSE;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Math in 'c:\program files (x86)\embarcadero\rad studio\7.0\source\Win32\rtl\common\Math.pas',
  Iterative_fft in '..\..\tests\delphi\Iterative_fft.pas',
  uHardwareMath in 'uHardwareMath.pas',
  complex in '..\..\tests\delphi\complex.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
