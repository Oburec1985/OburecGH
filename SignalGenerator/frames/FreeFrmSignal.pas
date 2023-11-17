unit FreeFrmSignal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, DCL_MYOWN;

type
  TFreeFrmSignalFrame = class(TFrame)
    FreqLabel: TLabel;
    FreqFE: TFloatEdit;
    LengthLabel: TLabel;
    LengthFE: TFloatEdit;
    FreqPeriodLabel: TLabel;
    PhasePeriodLabel: TLabel;
    xfe: TFloatEdit;
    yfe: TFloatEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
