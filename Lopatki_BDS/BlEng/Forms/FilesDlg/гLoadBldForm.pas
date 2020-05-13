unit LoadBldForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, uBtnListView;

type
  TLoadBldDlg = class(TForm)
    CommonGB: TGroupBox;
    RadioGroup1: TRadioGroup;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    SensorsGB: TGroupBox;
    BtnListView1: TBtnListView;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LoadBldDlg: TLoadBldDlg;

implementation

{$R *.dfm}

end.
