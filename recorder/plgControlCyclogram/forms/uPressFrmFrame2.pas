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
  uSpm, rkVistaProBar, Gauges;

type

  TPressFrmFrame2 = class(TFrame)
    FreqEdit: TEdit;
    AmpE: TEdit;
    ALabel: TLabel;
    FLabel: TLabel;
    ProgrBar: TGauge;
  private
    m_s:cSpm; // спектр по которому идет расчет
    finit:boolean;
  public
    // средн амп, главные амплитуда и частота в полосе
    // в m_Max всегда амплитуда?  см. updatedata формы
    m_A, m_Max, m_f:double;
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
    function getEst:double; // возврат отображаемой оценки
    function getA:double; // возврат A с учетом окна
    procedure Prepare;
    procedure updateView;
    //procedure Eval;
  public
    property spm:cspm read m_s write setspm;
    constructor create(aowner:tcomponent);override;
  end;

  const
    c_digs = 3;
    sqrt2 = 1.4142135623730950488016887242097;

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

function TPressFrmFrame2.getA: double;
begin
  result:=m_Max;
end;

function TPressFrmFrame2.getEst:double; // возврат отображаемой оценки
var
  w:PWndFunc;
  v:double;
begin
  if g_PressCamFactory2.m_typeRes=0 then // СКО
  begin
    v:=m_Max/sqrt2;
  end
  else  // p-p
  begin
    v:=m_Max*2;
  end;
  result:=v;
end;


procedure TPressFrmFrame2.updateView;
var
  w:PWndFunc;
  r, v:double;
  i:integer;
begin
  if finit then
  begin
    // rms
    if g_PressCamFactory2.m_typeRes=0 then // СКО
    begin
      // используем реф первого датчика
      r:=g_PressCamFactory2.GetRef(0)/sqrt2;
    end
    else  // p-p
    begin
      r:=g_PressCamFactory2.GetRef(0)*2;
    end;
    v:=getEst;
    FreqEdit.Text:=formatstrnoe(m_f, c_digs);
    AmpE.Text:=formatstrnoe(v, c_digs);

    if v<10000 then
    begin
      if abs(r)>0.000001 then
      begin
        i:=round(ProgrBar.MaxValue*v/r);
        if i<ProgrBar.MaxValue then
          ProgrBar.Progress:=i
        else
          ProgrBar.Progress:=ProgrBar.MaxValue;
      end;
    end;
    ProgrBar.ShowHint:=true;
    ProgrBar.Hint:='max='+floattostr(ProgrBar.MaxValue)+' v=' +floattostr(v)+' r='+floattostr(r);
    if m_Max>r*hh then
    begin
      ProgrBar.Color:=clred;
    end
    else
    begin
      if m_Max>h*r then
      begin
        ProgrBar.Color:=clYellow;
      end
      else
      begin
        ProgrBar.Color:=clBlue;
      end;
    end;
  end;
end;


end.
