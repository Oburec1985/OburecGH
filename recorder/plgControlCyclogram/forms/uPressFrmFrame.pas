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
  private
    m_spm:cSpm;
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
