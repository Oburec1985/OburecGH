unit uStageReConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CommonOptsFrame, StdCtrls, uSpin, DCL_MYOWN;

type
  TStageReConfigForm = class(TForm)
    BladeCountIE: TIntEdit;
    BladeCountLabel: TLabel;
    NameEdit: TEdit;
    NameLabel: TLabel;
    FirstBladeOffsetGB: TGroupBox;
    FirstBladeOffsetSE: TFloatSpinEdit;
    TahoCB: TComboBox;
    TahoLabel: TLabel;
    SensorCB: TComboBox;
    SensorLabel: TLabel;
    EvalFirstBladeOffsetBtn: TButton;
    ApplyGB: TGroupBox;
    OkBtn: TButton;
    CancelBtn: TButton;
    DscMemo: TMemo;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StageReConfigForm: TStageReConfigForm;

implementation

{$R *.dfm}

procedure TStageReConfigForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

end.
