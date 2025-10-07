unit uPolarGraph;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, uDoubleCursor,uChartEvents, uLabel,
  uRecorderEvents, ubaseObj, uCommonTypes, uEditProfileFrm, uControlWarnFrm,
  uRTrig, uRCFunc, ubasealg, uBuffTrend1d, utextlabel,
  PluginClass, ImgList, uChart, uGrmsSrcAlg, uPhaseAlg, usetlist, uPolarGraphPage;

type
  TPolarGraph = class(TRecFrm)
  public
    Chart:cchart;
  protected
    procedure ChartInit(Sender: TObject);
  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  IPolarFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cPolarFactory = class(cRecBasicFactory)
  private
    m_counter: integer;
  protected
    procedure doDestroyForms; override;
  public
    procedure doAfterLoad;override;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

var
  g_PolarFactory:cPolarFactory;

const
  c_Pic = 'POLAR_GIST';
  c_Name = 'Круговая гистограмма';

  c_defXSize = 400;
  c_defYSize = 400;

  // ctrl+shift+G
  //['{76272474-3CD7-4F00-82B7-F8D363A8855A}']|
  IID_POLAR: TGuid = (D1: $76272474; D2: $3CD7; D3: $4F00;
    D4: ($82, $B7, $F8, $D3, $63, $A8, $85, $5A));



implementation

uses
  uSpmChartEdit;
{$R *.dfm}
{ TSpmChart }


{ cPolarFactory }

constructor cPolarFactory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_POLAR;
end;

destructor cPolarFactory.destroy;
begin

  inherited;
end;

procedure cPolarFactory.doAfterLoad;
begin
  inherited;

end;

function cPolarFactory.doCreateForm: cRecBasicIFrm;
begin
  result:= nil;
  if m_counter < 1 then
  begin
    result := IPolarFrm.create();
  end;
end;

procedure cPolarFactory.doDestroyForms;
begin
  inherited;

end;

procedure cPolarFactory.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

{ TPolarGraph }

procedure TPolarGraph.ChartInit(Sender: TObject);
var
  polar:cPolarGraphPage;
begin
  polar:=cPolarGraphPage.create;
  Chart.activeTab.AddChild(polar);
  Chart.activePage.destroy;
  Chart.activeTab.Alignpages(1);
end;

constructor TPolarGraph.create(Aowner: tcomponent);
begin
  inherited;
  Chart := cchart.create(self);
  Chart.Align := alClient;
  Chart.showTV := false;
  Chart.showLegend := false;
  Chart.OnInit := ChartInit;
end;

destructor TPolarGraph.destroy;
begin

  inherited;
end;

procedure TPolarGraph.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

procedure TPolarGraph.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;


{ IPolarFrm }

procedure IPolarFrm.doClose;
begin
  m_lRefCount := 1;
end;

function IPolarFrm.doCreateFrm: TRecFrm;
begin
  result := TPolarGraph.create(nil);
end;

function IPolarFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function IPolarFrm.doRepaint: boolean;
begin
  inherited;
  //TSpmChart(m_pMasterWnd).UpdateView;
end;

end.
