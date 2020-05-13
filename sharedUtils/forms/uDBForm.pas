unit uDBForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ImgList, ComCtrls, ToolWin, Grids, DBGrids, Menus;

type
  TDBForm = class(TForm)
    GroupBox1: TGroupBox;
    PathE: TEdit;
    PathLabel: TLabel;
    GroupBox2: TGroupBox;
    ListBox1: TListBox;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ImageList_32: TImageList;
    GroupBox3: TGroupBox;
    DBGrid1: TDBGrid;
    GroupBox4: TGroupBox;
    MainMenu: TMainMenu;
    ConnectMenu: TMenuItem;
    CreateMenu: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DBForm: TDBForm;

implementation

{$R *.dfm}

end.
