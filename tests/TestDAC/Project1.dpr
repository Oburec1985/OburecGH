program Project1;

uses
  Forms,
  gnugettext,
  uDacDevice in 'uDacDevice.pas',
  uSoundCardDac in 'uSoundCardDac.pas',
  uCommonMath in '..\..\sharedUtils\math\uCommonMath.pas',
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  MathFunction in '..\..\sharedUtils\math\MathFunction.pas',
  Unit1 in 'Unit1.pas' {DACFrm},
  uLogFile in '..\..\sharedUtils\utils\uLogFile.pas',
  uDacProgram in 'uDacProgram.pas',
  uAccuracyStepSin in 'uAccuracyStepSin.pas';

{$R *.res}

begin
  Application.Initialize;
  //textdomain('default');
  //AddDomainForResourceString('default');
  UseLanguage('en');
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDACFrm, DACFrm);
  Application.Run;
end.
