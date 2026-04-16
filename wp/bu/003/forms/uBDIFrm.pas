unit uBDIFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, VirtualTrees, uVTServices, ComCtrls;

type
  TBDIFrm = class(TForm)
    GroupBox1: TGroupBox;
    BaseTV: TVTree;
    SelObjLB: TListBox;
    TabControl: TPageControl;
    ObjTab: TTabSheet;
    TestTab: TTabSheet;
    UnitsXLabel: TLabel;
    ObjNameEdit: TEdit;
    Label1: TLabel;
    TestNameEdit: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BDIFrm: TBDIFrm;

implementation

{$R *.dfm}

end.
