unit uPressFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath,
  Forms, ComCtrls,
  uRecBasicFactory,
  uRecorderEvents,
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
  uSpm,
  opengl, uSimpleObjects,
  math, uAxis, uDrawObj, uDoubleCursor, uBasicTrend,
  Dialogs, ExtCtrls, StdCtrls, DCL_MYOWN, Spin, Buttons;

type
  TPresRec = record
    AvrA:double;
    MaxA:double;
    Fr:double;
    f1,f2:double;
  end;

  TPressCamFrm = class(TRecFrm)
    BarGraphGB: TGroupBox;
    BarPanel: TPanel;
    Panel2: TPanel;
    FreqEdit: TEdit;
    BandLabel: TLabel;
    ProgrBar: TProgressBar;
    Panel1: TPanel;
    MaxLabel: TLabel;
    MaxFreqLabel: TLabel;
    MaxCamLabel: TLabel;
    AvgAmpLabel: TLabel;
    MaxAE: TEdit;
    MaxFE: TEdit;
    MaxCamE: TEdit;
    MaxAvrAE: TEdit;
    UnitMaxALab: TLabel;
    UnitMaxFLab: TLabel;
    UnitMaxAvrALab: TLabel;
    AvrCB: TCheckBox;
  private
    fSensorTag:string;
    fNumCam:integer;
    fSpm:cSpm;
    fBCount:integer;
 public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  IPressCamFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  IPressCamFactory = class(cRecBasicFactory)
  public
    // merafile
    m_meraFile: string;
  private
    m_counter: integer;
  protected
    procedure doDestroyForms; override;
    procedure createevents;
    procedure destroyevents;
  public
    procedure doAfterLoad; override;
    procedure doUpdateData(sender: tobject);
    procedure doChangeRState(sender: tobject);
    procedure doStart;
    procedure doStop;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;

var
  PressCamFrm: TPressCamFrm;

implementation

{$R *.dfm}

{ IPressCamFactory }

constructor IPressCamFactory.create;
begin

end;

procedure IPressCamFactory.createevents;
begin

end;

destructor IPressCamFactory.destroy;
begin

  inherited;
end;

procedure IPressCamFactory.destroyevents;
begin

end;

procedure IPressCamFactory.doAfterLoad;
begin
  inherited;

end;

procedure IPressCamFactory.doChangeRState(sender: tobject);
begin

end;

function IPressCamFactory.doCreateForm: cRecBasicIFrm;
begin

end;

procedure IPressCamFactory.doDestroyForms;
begin
  inherited;

end;

procedure IPressCamFactory.doSetDefSize(var PSize: SIZE);
begin
  inherited;

end;

procedure IPressCamFactory.doStart;
begin

end;

procedure IPressCamFactory.doStop;
begin

end;

procedure IPressCamFactory.doUpdateData(sender: tobject);
begin

end;

{ IPressCamFrm }

procedure IPressCamFrm.doClose;
begin
  inherited;

end;

function IPressCamFrm.doCreateFrm: TRecFrm;
begin

end;

function IPressCamFrm.doGetName: LPCSTR;
begin

end;

function IPressCamFrm.doRepaint: boolean;
begin

end;

{ TPressCamFrm }

constructor TPressCamFrm.create(Aowner: tcomponent);
begin
  inherited;

end;

destructor TPressCamFrm.destroy;
begin

  inherited;
end;

procedure TPressCamFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

procedure TPressCamFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
begin
  inherited;
  a_pIni.WriteString();
  saveTagToIni(a_pIni, t.m_tag, str, 'Taho_Tag');
  WriteFloatToIniMera(a_pIni, str, 'ShiftLeft', t.m_ShiftLeft);
  WriteFloatToIniMera(a_pIni, str, 'Threshold', t.m_treshold);
  WriteFloatToIniMera(a_pIni, str, 'Length', t.m_Length);
  WriteFloatToIniMera(a_pIni, str, 'CohThreshold', t.m_CohTreshold);

  WriteFloatToIniMera(a_pIni, str, 'Spm_minX', m_minX);
  WriteFloatToIniMera(a_pIni, str, 'Spm_maxX', m_maxX);
  WriteFloatToIniMera(a_pIni, str, 'Spm_minY', m_minY);
  WriteFloatToIniMera(a_pIni, str, 'Spm_maxY', m_maxY);
  a_pIni.WriteBool(str, 'Spm_Lg_x', m_lgX);
  a_pIni.WriteBool(str, 'Spm_Lg_y', m_lgY);
  a_pIni.WriteBool(str, 'SaveT0', m_saveT0);
  a_pIni.WriteInteger(str, 'Estimator', m_estimator);
  c := t.cfg;
  if c <> nil then
  begin
    a_pIni.WriteInteger(str, 'FFtnum', c.m_fftCount);
    a_pIni.WriteInteger(str, 'BlockCount', c.m_blockcount);
    a_pIni.WriteBool(str, 'AddNulls', c.m_addNulls);
    a_pIni.WriteInteger(str, 'SigCount', c.SRSCount);
    a_pIni.WriteInteger(str, 'ResType', c.typeres);
    a_pIni.WriteInteger(str, 'ShockCount', c.m_capacity);
    for i := 0 to c.SRSCount - 1 do
    begin
      s := c.GetSrs(i);
      saveTagToIni(a_pIni, s.m_tag, str, 'Tag_' + inttostr(i));
    end;
  end;
  a_pIni.WriteInteger(str, 'WelchBlockCount', m_WelchCount);
  a_pIni.WriteInteger(str, 'WelchShift', m_WelchShift);
  a_pIni.WriteBool(str, 'useWelch', m_UseWelch);
end;

end.
