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
    m_frm:TForm;
  protected
    procedure setspm(s:cspm);
    function f1:double;
    function f2:double;
    function hh:double;
    function h:double;
  public
    procedure Prepare;
    procedure updateView;
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
constructor TPressFrmFrame2.create(aowner: tcomponent);
begin
  inherited;
end;

function TPressFrmFrame2.f1: double;
begin
  result:=TPressFrm2(m_frm).m_f1;
end;

function TPressFrmFrame2.f2: double;
begin
  result:=TPressFrm2(m_frm).m_f2;
end;

function TPressFrmFrame2.h: double;
begin
  result:=TPressFrm2(m_frm).m_h;
end;

function TPressFrmFrame2.hh: double;
begin
  result:=TPressFrm2(m_frm).m_hh;
end;

procedure TPressFrmFrame2.Prepare;
begin

end;

procedure TPressFrmFrame2.setspm(s: cspm);
begin
  m_s:=s;
end;

procedure TPressFrmFrame2.updateView;
begin

end;

end.
