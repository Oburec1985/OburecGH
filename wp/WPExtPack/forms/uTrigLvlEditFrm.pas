unit uTrigLvlEditFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, DCL_MYOWN;

type
  TTrigLvlFrm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Trig1FE: TFloatEdit;
    Trig2FE: TFloatEdit;
    OkBtn: TButton;
    CancelBtn: TButton;
  private
    { Private declarations }
  public
    procedure EditPair(p:tobject);
  end;

var
  TrigLvlFrm: TTrigLvlFrm;

implementation

{$R *.dfm}
uses
  uCyclogramRepFrm;

procedure TTrigLvlFrm.EditPair(p:tobject);
begin
  Trig1FE.FloatNum:=cpair(p).Lvl1;
  Trig2FE.FloatNum:=cpair(p).Lvl2;
  if showmodal=mrok then
  begin
    cpair(p).Lvl1:=Trig1FE.FloatNum;
    cpair(p).Lvl2:=Trig2FE.FloatNum;
  end;
end;

end.
