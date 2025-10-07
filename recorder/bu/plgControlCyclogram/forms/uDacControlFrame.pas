unit uDacControlFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ExtCtrls, uControlFrame, StdCtrls;

type
  TDACControlFrame = class(TFrame)
    FeedbackLabel: TLabel;
    FeedbackCB: TComboBox;
  private
    { Private declarations }
  public
    function GetDsc:string;override;
  end;

  const
    c_DAC = 'Прямое управление с ЦАП';

implementation

{$R *.dfm}

{ TDACControlFrame }

function TDACControlFrame.GetDsc: string;
begin
  result:=c_DAC;
end;

end.
