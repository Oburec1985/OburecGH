program st1_2;

uses
  Forms,
  platpp,
  myWord in 'myWord.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Tplatpp_, platpp_);
  Application.Run;
end.
