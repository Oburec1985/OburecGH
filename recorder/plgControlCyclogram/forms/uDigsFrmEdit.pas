unit uDigsFrmEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uTagsListFrame, ExtCtrls, StdCtrls, Spin, DCL_MYOWN, Grids;

type
  TDigsFrmEdit = class(TForm)
    Panel3: TPanel;
    TagsListFrame1: TTagsListFrame;
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    IntEdit1: TIntEdit;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    IntEdit2: TIntEdit;
    Label2: TLabel;
    Button1: TButton;
    Label3: TLabel;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    ColumnSE: TSpinEdit;
    Label5: TLabel;
    Edit2: TEdit;
    CheckBox2: TCheckBox;
    Label6: TLabel;
    StringGrid1: TStringGrid;
    ComboBox1: TComboBox;
    Button2: TButton;
    Label7: TLabel;
    Edit3: TEdit;
    SignalsSG: TStringGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DigsFrmEdit: TDigsFrmEdit;

implementation

{$R *.dfm}

end.
