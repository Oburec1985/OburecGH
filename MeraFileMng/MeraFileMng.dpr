program MeraFileMng;

uses
  Forms,
  uMainFrm in 'uMainFrm.pas' {MeraFileMngFrm},
  uSpin in '..\sharedUtils\компоненты\dcl_dpk\uSpin.pas',
  uMeraFile in '..\sharedUtils\mera\uMeraFile.pas',
  ubuffsignal in '..\sharedUtils\mera\ubuffsignal.pas',
  umeraSignal in '..\sharedUtils\mera\umeraSignal.pas',
  uSignalsUtils in '..\sharedUtils\mera\uSignalsUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMeraFileMngFrm, MeraFileMngFrm);
  Application.Run;
end.
