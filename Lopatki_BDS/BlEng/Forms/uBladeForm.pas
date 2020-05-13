unit uBladeForm;

interface

uses
  Windows, SysUtils, Classes, Forms,
  uBladeEditFrame, Controls;

type
  TBladeForm = class(TForm)
    BladePosFrame1: TBladePosFrame;
  private
    { Private declarations }
  public
    function ShowModal(blPos:single):single;
  end;

var
  BladeForm: TBladeForm;

implementation

{$R *.dfm}
function TBladeForm.ShowModal(blPos:single):single;
begin
  BladePosFrame1.BladePos:=blpos;
  if inherited showmodal=mrok then
  begin
    result:=BladePosFrame1.BladePos;
  end
  else
    result:=blpos;
end;


end.
