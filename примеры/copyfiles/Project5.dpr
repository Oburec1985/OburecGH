program Project5;

uses
  Forms,
  Unit5 in 'Unit5.pas' {Form1},
  Unit5_ in 'Unit5_.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
