program Project1;

uses
  Forms,
  uMainFrmChart in 'uMainFrmChart.pas' {Form1},
  uGrahamScan in '..\..\sharedUtils\math\uGrahamScan.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
