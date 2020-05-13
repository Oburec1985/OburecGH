unit uGenShockForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN;

type
  TGenShockForm = class(TForm)
    LengthLabel: TLabel;
    LengthFE: TFloatEdit;
    ALabel: TLabel;
    AFE: TFloatEdit;
    FreqLabel: TLabel;
    FreqFE: TFloatEdit;
    BeforeShockLabel: TLabel;
    BeforeShockFE: TFloatEdit;
    AfterShockLabel: TLabel;
    AfterShockFE: TFloatEdit;
    DscLabel: TLabel;
    DscEdit: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GenShockForm: TGenShockForm;

implementation

{$R *.dfm}

end.
