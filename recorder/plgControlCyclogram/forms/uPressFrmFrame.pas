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
  uSpm;

type
  TPressFrmFrame = class(TFrame)
    BandLabel: TLabel;
    FreqEdit: TEdit;
    AmpE: TEdit;
    ProgrBar: TProgressBar;
  public
    m_s:cSpm; // спектр по которому идет расчет
    // начало и конец полосы
    m_f1, m_f2:double;
    m_if1, m_if2:integer;
    // главные амплитуда и частота в полосе
    m_A, m_f:double;
    // 100% шкалы
    m_Max:double;
  public
    function CreateSpm(tagname:string):cSpm;
  end;

implementation

{$R *.dfm}

{ TPressFrmFrame }

function TPressFrmFrame.CreateSpm(tagname: string): cSpm;
begin

end;

end.
