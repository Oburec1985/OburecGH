unit uAxisForm;

interface

uses
  Windows, Forms, uaxis, uCommonTypes,
  StdCtrls, DCL_MYOWN, uDrawObjFrame, Controls, Classes;

type
  TAxisForm = class(TForm)
    ActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    CommonGB: TGroupBox;
    DrawObjFrame1: TDrawObjFrame;
    GroupBox1: TGroupBox;
    MAXFE: TFloatEdit;
    MINFE: TFloatEdit;
    LgCB: TCheckBox;
    MaxLabel: TLabel;
    MinLabel: TLabel;
  private
    { Private declarations }
  public
    function ShowModal(obj:caxis):integer;
  end;

var
  AxisForm: TAxisForm;

implementation

{$R *.dfm}

function TAxisForm.ShowModal(obj:caxis):integer;
begin
  DrawObjFrame1.setobj(obj);
  lgcb.checked:=obj.Lg;
  minfe.FloatNum:=obj.min.y;
  maxfe.FloatNum:=obj.max.y;
  if inherited showmodal=mrok then
  begin
    DrawObjFrame1.getObj(obj);
    obj.Lg:=lgcb.checked;
    obj.min:=p2d(obj.min.x,minfe.FloatNum);
    obj.max:=p2d(obj.max.x,maxfe.FloatNum);
  end;
end;

end.
