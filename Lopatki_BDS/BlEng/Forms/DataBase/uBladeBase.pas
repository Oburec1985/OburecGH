unit uBladeBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, ExtCtrls;

type
  TBladeFrm = class(TForm)
    GroupBox1: TGroupBox;
    DBGrid1: TDBGrid;
    GroupBox2: TGroupBox;
    PathE: TEdit;
    PathLabel: TLabel;
    Button1: TButton;
    GroupBox3: TGroupBox;
    DBGrid2: TDBGrid;
    Splitter1: TSplitter;
    GroupBox4: TGroupBox;
    DBGrid3: TDBGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BladeFrm: TBladeFrm;

implementation

{$R *.dfm}

end.
