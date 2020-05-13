unit uBladeEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, DCL_MYOWN;

type
  TBladePosFrame = class(TFrame)
    BladePosFE: TFloatEdit;
    PosLabel: TLabel;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
  private
    procedure setBladePos(p:single);
    function GetBladePos:single;
  public
    property BladePos:single read GetBladePos write setBladePos;
  end;

implementation

{$R *.dfm}
procedure TBladePosFrame.setBladePos(p:single);
begin
  bladeposfe.FloatNum:=p;
end;

function TBladePosFrame.getBladePos:single;
begin
  result:=bladeposfe.FloatNum;
end;


end.
