unit uEdiSelsinFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Spin, StdCtrls, DCL_MYOWN;

type
  TEditSelsinFrm = class(TForm)
    Label6: TLabel;
    Label7: TLabel;
    Label1: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    L1CB: TComboBox;
    L2CB: TComboBox;
    L3CB: TComboBox;
    ExcFreqEdit: TFloatEdit;
    ExcCB: TComboBox;
    NameEdit: TEdit;
    GroupBox1: TGroupBox;
    SKO1Label: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    SKO2Label: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    SKO3Label: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    SKOMax1: TFloatEdit;
    SKOMin1: TFloatEdit;
    SKOMax2: TFloatEdit;
    SKOMin2: TFloatEdit;
    SKOMax3: TFloatEdit;
    SKOMin3: TFloatEdit;
    AutoCalibrCB: TCheckBox;
    ShiftSectr: TSpinEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditSelsinFrm: TEditSelsinFrm;

implementation

{$R *.dfm}

end.
