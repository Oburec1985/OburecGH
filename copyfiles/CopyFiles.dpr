program CopyFiles;

uses
  Forms,
  uCopyFiles in 'uCopyFiles.pas' {CopyFilesFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TCopyFilesFrm, CopyFilesFrm);
  Application.Run;
end.
