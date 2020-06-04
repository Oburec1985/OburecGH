program CheckSSE;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uQueue in '..\..\sharedUtils\utils\lists\uQueue.pas',
  complex in '..\..\sharedUtils\math\FFT_койнов\complex.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
