unit uPressFrmFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls,
  uRecBasicFactory,
  uRecorderEvents,
  extctrls,
  CommCtrl,
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
  MathFunction,
  uHardwareMath,
  uSpm;

type
  TPressFrmFrame = class(TFrame)
    BandLabel: TLabel;
    FreqEdit: TEdit;
    AmpE: TEdit;
    ProgrBar: TProgressBar;
    ALabel: TLabel;
    FLabel: TLabel;
  private
    // TPressfrm2
    m_frm:tform;
    m_s:cSpm; // спектр по которому идет расчет
    finit:boolean;
    // цвет PBar
    defaultcolor:tcolor;
  public
    // начало и конец полосы
    m_f1, m_f2:double;
    m_if1, m_if2:integer;
    // средн амп, главные амплитуда и частота в полосе
    m_A,m_Max, m_f:double;
    m_RefAmp, m_hh, m_h:double;
    m_RefAmpManual:double;
  protected
    procedure setspm(s:cspm);
  public
    procedure Prepare;
    procedure Stop;
    procedure updateView;
    procedure Eval;
  public
    property spm:cspm read m_s write setspm;
    constructor create(aowner:tcomponent);override;
  end;

  const
    c_digs = 2;

implementation

{$R *.dfm}

{ TPressFrmFrame }

constructor TPressFrmFrame.create(aowner: tcomponent);
begin
  inherited;
  defaultcolor:=ProgrBar.Brush.Color;
end;

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
    if m_RefAmpManual=0 then
    begin
      m_RefAmp:=m_s.m_tag.GetMaxYValue;
    end
    else
    begin
      m_RefAmp:=m_RefAmpManual;
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
    FreqEdit.Text:=formatstrnoe(m_Max, c_digs);
    AmpE.Text:=formatstrnoe(m_f, c_digs);
    ProgrBar.Position:=round(100*m_Max/m_RefAmp);
    if m_Max>m_RefAmp*m_hh then
    begin
      ProgrBar.Brush.Color := clred;
      // CommCtrl
      SendMessage (ProgrBar.Handle, PBM_SETBARCOLOR, 0, clred);
    end
    else
    begin
      if m_Max>m_h*m_RefAmp then
      begin
        SendMessage (ProgrBar.Handle, PBM_SETBARCOLOR, 0, clYellow);
      end
      else
      begin
        SendMessage (ProgrBar.Handle, PBM_SETBARCOLOR, 0, clBlue);
      end;
    end;
  end;
end;

end.
