program Proilegenerator;

uses
  Forms,
  ProfileGenerator in 'ProfileGenerator.pas' {EditProfileForm},
  uEditForm in 'uEditForm.pas' {EditForm},
  uEditTubeFrm in 'uEditTubeFrm.pas' {EditTubeFrm},
  uMeraFile in '..\sharedUtils\mera\uMeraFile.pas',
  uPolarGraphPage in '..\sharedUtils\компоненты\chart_dpk\chart\items\uPolarGraphPage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TEditProfileForm, EditProfileForm);
  Application.CreateForm(TEditForm, EditForm);
  Application.CreateForm(TEditTubeFrm, EditTubeFrm);
  Application.Run;
end.
