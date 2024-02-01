unit uPressFrmFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls,
  uRecBasicFactory,
  uRecorderEvents,
  uComponentServises,
  uChart,
  inifiles,
  upage,
  tags,
  complex,
  uBuffTrend1d,
  uCommonMath,
  uCommonTypes,
  pluginClass,
  uMeasureBase,
  uMBaseControl,
  shellapi,
  uPathMng,
  uBaseAlg,
  uHardwareMath,
  uSpm;

type
  TPressFrmFrame = class(TFrame)
    BandLabel: TLabel;
    FreqEdit: TEdit;
    AmpE: TEdit;
    ProgrBar: TProgressBar;
  private
    m_s:cSpm; // спектр по которому идет расчет
    finit:boolean;
  public
    // начало и конец полосы
    m_f1, m_f2:double;
    m_if1, m_if2:integer;
    // средн амп, главные амплитуда и частота в полосе
    m_A,m_Max, m_f:double;
    m_RefAmp:double;
  protected
    procedure setspm(s:cspm);
  public
    procedure Prepare;
    procedure Stop;
    procedure updateView;
    procedure Eval;
  public
    property spm:cspm read m_s write setspm;
  end;

implementation

{$R *.dfm}

{ TPressFrmFrame }

procedure TPressFrmFrame.Eval;
var
  I, imax: Integer;
  v, max, sum:double;
begin
  max:=0;
  sum:=0;
  for I := m_if1 to m_if2 do
  begin
    v:=tdoubleArray(m_s.m_rms.p)[i];
    sum:=sum+v;
    if v>max then
    begin
      max:=v;
      imax:=i;
    end;
  end;
  m_Max:=max;
  m_f:=m_s.SpmDx*imax;
  m_A:=sum/(m_if2-m_if1);
end;

procedure TPressFrmFrame.Prepare;
begin
  if m_s<>nil then
  begin
    finit:=true;
    if m_RefAmp=0 then
    begin
      m_RefAmp:=m_s.m_tag.tag.GetYRange;
    end;
    m_if1:=m_s.getIndByX(m_f1);
    m_if2:=m_s.getIndByX(m_f2);
  end;
end;

procedure TPressFrmFrame.setspm(s: cspm);
begin
  m_s:=s;
end;

procedure TPressFrmFrame.Stop;
begin
  finit:=false;
end;

procedure TPressFrmFrame.updateView;
begin
  if finit then
  begin
    FreqEdit.Text:=floattostr(m_Max);
    AmpE.Text:=floattostr(m_f);
    ProgrBar.Position:=round(100*m_Max/m_RefAmp);
  end;
end;

end.
