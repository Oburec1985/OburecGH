unit uGetSkipBladesForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CommonOptsFrame, DCL_MYOWN;

type
  TGetSkipBladesForm = class(TForm)
    BaseAlgOptsFrame1: TBaseAlgOptsFrame;
    EvalSkipBladesGroupBox: TGroupBox;
    SkipBladeIE: TIntEdit;
    SkipBladeLabel: TLabel;
    StepLabel: TLabel;
    StepIntEdit: TIntEdit;
    ApplyGB: TGroupBox;
    OkBtn: TButton;
    CancelBtn: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GetSkipBladesForm: TGetSkipBladesForm;

implementation

{$R *.dfm}

end.
