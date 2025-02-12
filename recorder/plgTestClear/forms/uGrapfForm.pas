unit uGrapfForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uRecBasicFactory, inifiles,
  uEventList, //udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, MathFunction, uMyMath,
  uRecorderEvents, ubaseObj, uCommonTypes, uRCFunc,
  //uBuffTrend1d,
  tags,
  PluginClass, ImgList, Menus, uChart;

type
  TGraphFrm = class(TRecFrm)
    RightGB: TGroupBox;
    cChart1: cChart;
    RightSplitter: TSplitter;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    //constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

 IGraphFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cGraphFrmFactory = class(cRecBasicFactory)
  private
    m_counter: integer;
  protected
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doStart;
    procedure CreateEvents;
    procedure DestroyEvents;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

const
  // ctrl+shift+G
  //['{E7EA803D-BE61-4A10-A3FB-36CAE2571FD3}']
  IID_GRAPH: TGuid = (D1: $E7EA803D; D2: $BE61; D3: $4A10;
    D4: ($A3, $FB, $36, $CA, $E2, $57, $1F, $D3));

  c_Pic = 'GRAPHPIC';
  c_Name = 'Тест графики';
  c_defXSize = 370;
  c_defYSize = 90;


var
  g_GraphFrmFactory: cGraphFrmFactory;
  GraphFrm: TGraphFrm;

implementation

{$R *.dfm}

{ TGraphFrm }

destructor TGraphFrm.destroy;
begin

  inherited;
end;

procedure TGraphFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

procedure TGraphFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

{ IGraphFrm }

procedure IGraphFrm.doClose;
begin
  inherited;

end;

function IGraphFrm.doCreateFrm: TRecFrm;
begin
  result := TGraphFrm.create(nil);
end;

function IGraphFrm.doGetName: LPCSTR;
begin

end;

function IGraphFrm.doRepaint: boolean;
begin

end;

{ cGraphFrmFactory }

constructor cGraphFrmFactory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_GRAPH;
end;

procedure cGraphFrmFactory.CreateEvents;
begin

end;

destructor cGraphFrmFactory.destroy;
begin

  inherited;
end;

procedure cGraphFrmFactory.DestroyEvents;
begin

end;

procedure cGraphFrmFactory.doChangeRState(Sender: TObject);
begin

end;

function cGraphFrmFactory.doCreateForm: cRecBasicIFrm;
begin
  result := IGraphFrm.create();
end;

procedure cGraphFrmFactory.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

procedure cGraphFrmFactory.doStart;
begin

end;

procedure cGraphFrmFactory.doUpdateData(Sender: TObject);
begin

end;

end.
