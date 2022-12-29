unit uEvalStepCfgFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uTagsListFrame, ExtCtrls, DCL_MYOWN, Spin, uSpin;

type
  TEvalStepCfgFrm = class(TForm)
    BottomPanel: TPanel;
    RightPanel: TPanel;
    TagsListFrame1: TTagsListFrame;
    AlgsLB: TListBox;
    MainPanel: TPanel;
    InChanCB: TComboBox;
    InChanLabel: TLabel;
    OutChanE: TEdit;
    OutChanLabel: TLabel;
    FFTCb: TCheckBox;
    FFTSizeSB: TSpinButton;
    FFTBlockSizeIE: TIntEdit;
    FFTBlockSizeLabel: TLabel;
    FFTShiftSB: TSpinButton;
    FFTShiftIE: TIntEdit;
    FFTShiftLabel: TLabel;
    TrigGB: TGroupBox;
    ThresholdSE: TFloatSpinEdit;
    ThresholdLabel: TLabel;
    OffsetSE: TFloatSpinEdit;
    OffsetLabel: TLabel;
    FsSE: TFloatSpinEdit;
    FsLabel: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EvalStepCfgFrm: TEvalStepCfgFrm;

implementation

{$R *.dfm}

end.
