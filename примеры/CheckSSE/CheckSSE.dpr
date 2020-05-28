program CheckSSE;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  //Iterative_fft in '..\..\tests\delphi\Iterative_fft.pas',
  complex in '..\..\tests\delphi\complex.pas',
  uQueue in '..\..\sharedUtils\utils\lists\uQueue.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
