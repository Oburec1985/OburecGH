unit uGrapfForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uRecBasicFactory, inifiles,
  uEventList, //udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, MathFunction, uMyMath, //uTag,
  uaxis, upage, uBuffTrend1d,
  uRecorderEvents, ubaseObj, uCommonTypes, uRCFunc,
  //uBuffTrend1d,
  tags,
  shellapi,
  uPathMng,
  uHardwareMath,
  PluginClass, ImgList, Menus, uSpin, uRcCtrls, Buttons;

type

  TGraphFrm = class(TRecFrm)
    RightSplitter: TSplitter;
  public

  protected

  protected
    // происходит когда все плагины загружены
    procedure OnRecorderInit;
    procedure doStart;override;
    procedure updatedata;override;
    procedure updateView;

    procedure InitCS;
    procedure DeleteCS;
    procedure EnterCS;
    procedure ExitCS;

  public
    // очистить список сигналов в осциле
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
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
    m_meraFile:string;
    m_counter: integer;
  protected
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doStart;override;
    procedure CreateEvents;
    procedure DestroyEvents;
    // когда Recorder загрузил конфиги;
    procedure doRecorderInit;override;
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
  c_Name = '“ест графики';
  c_defXSize = 370;
  c_defYSize = 90;


var
  g_GraphFrmFactory: cGraphFrmFactory;
  GraphFrm: TGraphFrm;

implementation

{$R *.dfm}

{ TGraphFrm }


constructor TGraphFrm.create(Aowner: tcomponent);
begin
  inherited;
end;

destructor TGraphFrm.destroy;
begin
  DeleteCS;
  inherited;
end;

procedure TGraphFrm.doStart;
var
  i:integer;
begin
  //for I := 0 to m_slist.Count - 1 do
  begin
    //t:=getSignal(i);
    //t.m_t.doOnStart;
  end;
end;

procedure TGraphFrm.InitCS;
begin
  //InitializeCriticalSection(cs);
end;

procedure TGraphFrm.DeleteCS;
begin
  //DeleteCriticalSection(cs);
end;

procedure TGraphFrm.EnterCS;
begin
  //EnterCriticalSection(cs);
end;

procedure TGraphFrm.ExitCS;
begin
  //LeaveCriticalSection(cs);
end;


procedure TGraphFrm.OnRecorderInit;
begin

end;

procedure TGraphFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  s1:string;
begin
  inherited;
  //a_pIni.WriteInteger(str, 'lvWidth', RightGB.Width);
end;

procedure TGraphFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  // загрузка осей
  //exit;
  //RightGB.Width:=a_pIni.rEADInteger(str, 'lvWidth', RightGB.Width);
end;
procedure TGraphFrm.updatedata;
var
  v: double;
begin
  v:=GetRCTime;
  // обновление данных
end;

procedure TGraphFrm.updateView;
begin
  if RStatePlay then
  begin
  end;
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
  TGraphFrm(m_pMasterWnd).updateView;
end;

{ cGraphFrmFactory }

constructor cGraphFrmFactory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_GRAPH;
  createevents;
end;

procedure cGraphFrmFactory.CreateEvents;
var
  I: Integer;
begin
  addplgevent('cGraphFrmFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
end;

destructor cGraphFrmFactory.destroy;
begin
  DestroyEvents;
  inherited;
end;

procedure cGraphFrmFactory.DestroyEvents;
begin
  RemovePlgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cGraphFrmFactory.doChangeRState(Sender: TObject);
begin
 case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
        //doStop;
      end;
    RSt_StopToView:
      begin
        m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_StopToRec:
      begin
        m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_ViewToStop:
      begin
        //doStop;
      end;
    RSt_ViewToRec:
      begin
        m_meraFile := GetMeraFile;
      end;
    RSt_initToRec:
      begin
        m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_initToView:
      begin
        m_meraFile := GetMeraFile;
        doStart;
      end;
    RSt_RecToStop:
      begin
        //doStop;
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

function cGraphFrmFactory.doCreateForm: cRecBasicIFrm;
begin
  result := IGraphFrm.create();
end;

procedure cGraphFrmFactory.doRecorderInit;
var
  i, j: integer;
  Frm: TRecFrm;
begin
  //exit;
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TGraphFrm(Frm).OnRecorderInit;
    //TGraphFrm(frm).TestConfig;
  end;
end;

procedure cGraphFrmFactory.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

procedure cGraphFrmFactory.doStart;
begin
  inherited;
end;

procedure cGraphFrmFactory.doUpdateData(Sender: TObject);
begin

end;


end.
