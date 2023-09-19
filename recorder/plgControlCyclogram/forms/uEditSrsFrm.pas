unit uEditSrsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, uVTServices, uTagsListFrame, StdCtrls, ExtCtrls,
  uRcCtrls, DCL_MYOWN, Spin, ImgList;

type
  TEditSrsFrm = class(TForm)
    SignalsTV: TVTree;
    TagsListFrame1: TTagsListFrame;
    MainPanel: TPanel;
    TahoGB: TGroupBox;
    TrigNameLabel: TLabel;
    RightShiftLabel: TLabel;
    RightShiftEdit: TFloatEdit;
    LeftShiftLabel: TLabel;
    LengthFE: TFloatEdit;
    ThresholdLabel: TLabel;
    ThresholdFE: TFloatEdit;
    SPMGB: TGroupBox;
    FFTBlockSizeLabel: TLabel;
    FFTShiftLabel: TLabel;
    FFTdxLabel: TLabel;
    BlockSizeFLabel: TLabel;
    FFTSizeSB: TSpinButton;
    FFTBlockSizeIE: TIntEdit;
    FFTShiftSB: TSpinButton;
    FFTShiftIE: TIntEdit;
    FFTdxFE: TFloatEdit;
    BlockSizeFE: TFloatEdit;
    Splitter1: TSplitter;
    ResTypeRG: TRadioGroup;
    ShCountLabel: TLabel;
    NullCB: TCheckBox;
    ChartGB: TGroupBox;
    LgXcb: TCheckBox;
    LgYcb: TCheckBox;
    ImageList1: TImageList;
    TrigNameCB: TRcComboBox;
    ShCountIE: TIntEdit;
    Label1: TLabel;
    TahoNameRG: TRcComboBox;
    CheckBox1: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditSrsFrm: TEditSrsFrm;

implementation

{$R *.dfm}

end.
