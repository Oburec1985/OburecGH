unit FreeFrmSignal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, DCL_MYOWN, uchart, upage, utrend, upoint;

type
  TFreeFrmSignalFrame = class(TFrame)
    LengthLabel: TLabel;
    LengthFE: TFloatEdit;
    FreqPeriodLabel: TLabel;
    PhasePeriodLabel: TLabel;
    xfe: TFloatEdit;
    yfe: TFloatEdit;
    procedure LengthFEChange(Sender: TObject);
  private
    m_chart:cchart;
  public
    procedure linc(p_chart:cchart);
  end;

implementation

{$R *.dfm}

{ TFreeFrmSignalFrame }

procedure TFreeFrmSignalFrame.LengthFEChange(Sender: TObject);
var
  tr:ctrend;
  p:cBeziePoint;
begin
  tr:=m_chart.activetrend;
  p:=tr.getPoint(tr.count-1);
  p.x:=LengthFE.FloatNum;
  tr.NeedRecompile:=true;
  m_chart.Invalidate;
end;

procedure TFreeFrmSignalFrame.linc(p_chart: cchart);
begin
  m_chart:=p_chart;
end;

end.
