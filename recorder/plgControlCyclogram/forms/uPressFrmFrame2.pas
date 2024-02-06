unit uPressFrmFrame2;

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

  TPressFrmFrame2 = class(TFrame)
    FreqEdit: TEdit;
    AmpE: TEdit;
    ProgrBar: TProgressBar;
    ALabel: TLabel;
    FLabel: TLabel;
  private
    m_s:cSpm; // спектр по которому идет расчет
    finit:boolean;
  public
    // средн амп, главные амплитуда и частота в полосе
    m_A,m_Max, m_f:double;
  public
    m_frm:TForm;
  protected
    procedure setspm(s:cspm);
    function bnum:integer;
    function i1:integer;
    function i2:integer;

    function f1:double;
    function f2:double;
    function hh:double;
    function h:double;
  public
    procedure Prepare;
    procedure updateView;
    procedure Eval;
  public
    property spm:cspm read m_s write setspm;
    constructor create(aowner:tcomponent);override;
  end;

  const
    c_digs = 2;

implementation
uses
  uPressFrm2;

{$R *.dfm}

{ TPressFrmFrame }
function TPressFrmFrame2.bnum: integer;
begin
  result:=TPressFrm2(m_frm).m_bnum;
end;

constructor TPressFrmFrame2.create(aowner: tcomponent);
begin
  inherited;
end;

procedure TPressFrmFrame2.Eval;
var
  I, imax: Integer;
  v, max, sum:double;
begin
  max:=0;
  sum:=0;
  for I := g_PressCamFactory2.m_bands[bnum].i1 to g_PressCamFactory2.m_bands[bnum].i2 do
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
  m_A:=sum/(g_PressCamFactory2.m_bands[bnum].i2-g_PressCamFactory2.m_bands[bnum].i1);
end;

function TPressFrmFrame2.f1: double;
begin
  result:=TPressFrm2(m_frm).f1;
end;

function TPressFrmFrame2.f2: double;
begin
  result:=TPressFrm2(m_frm).f2;
end;

function TPressFrmFrame2.h: double;
begin
  result:=TPressFrm2(m_frm).m_h;
end;

function TPressFrmFrame2.hh: double;
begin
  result:=TPressFrm2(m_frm).m_hh;
end;

function TPressFrmFrame2.i1: integer;
begin
  result:=g_PressCamFactory2.m_bands[bnum].i1;
end;

function TPressFrmFrame2.i2: integer;
begin
  result:=g_PressCamFactory2.m_bands[bnum].i2;
end;

procedure TPressFrmFrame2.Prepare;
begin
  finit:=false;
  if m_s<>nil then
  begin
    if m_s.m_tag<>nil then
    begin
      if m_s.m_tag.tag<>nil then
      begin
        if i2<>0 then
        begin
          finit:=true;
        end;
      end;
    end;
  end;
end;


procedure TPressFrmFrame2.setspm(s: cspm);
begin
  m_s:=s;
end;

procedure TPressFrmFrame2.updateView;
var
  r:double;
begin
  if finit then
  begin
    FreqEdit.Text:=formatstrnoe(m_Max, c_digs);
    AmpE.Text:=formatstrnoe(m_f, c_digs);
    // используем реф первого датчика
    r:=g_PressCamFactory2.GetRef(0);
    ProgrBar.Position:=round(100*m_Max/r);
    if m_Max>r*hh then
    begin
      ProgrBar.Brush.Color := clred;
      // CommCtrl
      SendMessage (ProgrBar.Handle, PBM_SETBARCOLOR, 0, clred);
    end
    else
    begin
      if m_Max>h*r then
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
