unit uRestoreForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uStageFrame, StdCtrls;

type
  TRestoreForm = class(TForm)
    StageGb: TGroupBox;
    StageFrame1: TStageFrame;
    AlgOptsGB: TGroupBox;
    OkBtn: TButton;
    CancelBtn: TButton;
    UseBladesPos: TCheckBox;
    Edit1: TEdit;
    StageLabel: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RestoreForm: TRestoreForm;

implementation

{$R *.dfm}

end.
