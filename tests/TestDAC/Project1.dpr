program Project1;

uses
  Forms,
  uDacDevice in 'uDacDevice.pas',
  uSoundCardDac in 'uSoundCardDac.pas',
  uCommonMath in '..\..\sharedUtils\math\uCommonMath.pas',
  uCommonTypes in '..\..\sharedUtils\uCommonTypes.pas',
  MathFunction in '..\..\sharedUtils\math\MathFunction.pas',
  Unit1 in 'Unit1.pas' {DACFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDACFrm, DACFrm);
  Application.Run;
end.
