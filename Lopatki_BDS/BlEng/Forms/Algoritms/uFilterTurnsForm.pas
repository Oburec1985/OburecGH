unit uFilterTurnsForm;

interface

uses
  Windows, SysUtils, Forms,  StdCtrls, DCL_MYOWN, Controls, Classes,
  uMyTypes_,uTickData,uBldMath, uBldFile, ExtCtrls
  ;

type
  TFilterTurnsForm = class(TForm)
    OkBtn: TButton;
    CancelBtn: TButton;
    Memo1: TMemo;
    GroupBox1: TGroupBox;
    LoCheckBox: TCheckBox;
    HiCheckBox: TCheckBox;
    InsertCheckBox: TCheckBox;
  private
    // получить опции алгоритма из формы
    function GetChekOpts:byte;
    { Private declarations }
  public
    { Public declarations }
    function ShowModal(Bladenumber:integer;
                       const taho:array of stickdata;
                       const ticks:array of stickdata;
                       var filteredTicks:cticks;
                       var filteredtaho:cticks;
                       break:pointer):integer;
  end;

var
  FilterTurnsForm: TFilterTurnsForm;

implementation

{$R *.dfm}
// получить опции алгоритма из формы
function TFilterTurnsForm.GetChekOpts:byte;
var i:integer;
begin
  i:=0;
  if LoCheckBox.Checked then
    i:=i+c_lo_filter;
  if HiCheckBox.Checked then
    i:=i+c_hi_filter;
  if InsertCheckBox.Checked then
    i:=i+c_insert_filter;
  result:=i;
end;

function TFilterTurnsForm.ShowModal(bladenumber:integer;
                           const taho:array of stickdata;
                           const ticks:array of stickdata;
                           var filteredTicks:cticks;
                           var filteredtaho:cticks;
                           break:pointer):integer;
begin
  if inherited showmodal = mrok then
end;



end.
