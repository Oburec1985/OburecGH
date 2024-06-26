unit uComplexDiagram;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, uDoubleCursor,uChartEvents, uLabel,
  uRecorderEvents, ubaseObj, uCommonTypes, uEditProfileFrm, uControlWarnFrm,
  uRTrig, uRCFunc, ubasealg, uBuffTrend1d, upage, utextlabel, uaxis, utrend,
  PluginClass, ImgList, uChart, uGrmsSrcAlg, uPhaseAlg, usetlist, ufreqband,
  uHardwareMath,
  uSpm;


type
  TComplexDiagramFrm = class(TForm)
    SignalsLV: TBtnListView;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

 IComplexDiagramFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cComplexDiagramFact = class(cRecBasicFactory)
  protected
    procedure createEvents;
    procedure destroyEvents;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

var
  g_ComplexDiagramFact:cComplexDiagramFact;

const
  // ���������� ��� ����� ����� �������
  E_CURSMOVE = $00000001;
  E_SETACTSPMCHART = $00000002;

const
  c_Pic = 'CPXFRM';
  c_Name = '����������� ���������';

  c_CPX_defXSize = 400;
  c_CPX_defYSize = 400;

  // ctrl+shift+G
  // ['{1DB5F936-1A2A-4757-8431-AA51B8F3F0C6}']
  IID_CPXDIAG: TGuid = (D1: $1DB5F936; D2: $1A2A; D3: $4757;
                        D4: ($84, $31, $AA, $51, $B8, $F3, $F0, $C6));

implementation

{$R *.dfm}

{ cComplexDiagramFact }

constructor cComplexDiagramFact.create;
begin
  //initevents:=false;
  m_lRefCount := 1;
  //m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_CHARTSPM;
  //elist:=cEventList.create(self, true);
  CreateEvents;
end;

procedure cComplexDiagramFact.createEvents;
begin
  //spmChart.OBJmNG.Events.AddEvent('SpmChart_OnZoom', E_OnZoom, doOnZoom);
end;

procedure cComplexDiagramFact.destroyEvents;
begin
  //spmChart.OBJmNG.Events.removeEvent(doOnZoom, E_OnZoom);
end;

destructor cComplexDiagramFact.destroy;
begin

  inherited;
end;



function cComplexDiagramFact.doCreateForm: cRecBasicIFrm;
begin

end;

procedure cComplexDiagramFact.doSetDefSize(var pSize: SIZE);
begin
  inherited;

end;

{ IComplexDiagramFrm }

procedure IComplexDiagramFrm.doClose;
begin
  inherited;

end;

function IComplexDiagramFrm.doCreateFrm: TRecFrm;
begin

end;

function IComplexDiagramFrm.doGetName: LPCSTR;
begin

end;

function IComplexDiagramFrm.doRepaint: boolean;
begin

end;

end.
