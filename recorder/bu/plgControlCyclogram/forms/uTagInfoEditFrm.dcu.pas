unit uTagInfoEditFrm.dcu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, ComCtrls, uBtnListView, ExtCtrls, Buttons,
  uTagsListFrame, uRcCtrls;

type
  TTagInfoEditFrm = class(TForm)
    AllClientPanel: TPanel;
    TextInfoLV: TBtnListView;
    BottomPanel: TPanel;
    Panel1: TPanel;
    FontBtn: TButton;
    LabFontBtn: TButton;
    ColorDialog1: TColorDialog;
    GroupBox1: TGroupBox;
    TextNumIE: TIntEdit;
    TextNumLabel: TLabel;
    TextLabel: TLabel;
    ColorLabel: TLabel;
    ColorPan: TPanel;
    ShowLabelCB: TCheckBox;
    TagCB: TRcComboBox;
    TagsListFrame1: TTagsListFrame;
    Textedit: TEdit;
    TagLabel: TLabel;
    AddRowBtn: TSpeedButton;
    UpdateRowBtn: TSpeedButton;
    SpeedButton2: TSpeedButton;
  private
    { Private declarations }
  public
    procedure EditTextInfo(sender:tobject);
  end;

var
  TagInfoEditFrm: TTagInfoEditFrm;

implementation

{$R *.dfm}

{ TTagInfoEditFrm }

procedure TTagInfoEditFrm.EditTextInfo(sender: tobject);
begin
  if modalresult=mrok then
  begin

  end;
end;

end.
