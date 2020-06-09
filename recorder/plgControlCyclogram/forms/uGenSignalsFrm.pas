unit uGenSignalsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  activex,
  blaccess,
  urcfunc,
  ucommonmath, MathFunction, uMyMath,
  uRecorderEvents, ubaseObj, uCommonTypes,
  uRTrig, ubasealg, uBuffTrend1d, tags,
  PluginClass, ImgList, Menus, DCL_MYOWN, uSpin;

type
  cGenSig = class
  public
    m_name:string;
    m_type:integer;
    m_amp:double;
    m_freq:double;
    m_phase:double;
    m_t:ctag;
  public
    // p_freq - частота дикретизации
    constructor create(sname:string; p_freq:double);
    destructor destroy;
  end;

  TGenSignalsFrm = class(TRecFrm)
    PropertyPanel: TPanel;
    SignalsLB: TListBox;
    STypeRG: TRadioGroup;
    AmpLabel: TLabel;
    FreqLabel: TLabel;
    PhaseLabel: TLabel;
    AmpSE: TFloatSpinEdit;
    FreqSE: TFloatSpinEdit;
    PhaseSE: TFloatSpinEdit;
    Timer1: TTimer;
  private
    fcapacity: integer;
    fcount: integer;
  public
    m_tag: ctag;
    lastval: integer;
  private
  protected
    procedure RBtnClick(Sender: TObject);
    procedure UpdateData;
  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  end;

  IGenSignalsFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cGenSignalsFactory = class(cRecBasicFactory)
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
  IID_GENSIGNALS: TGuid = (D1: $027E3774; D2: $0414; D3: $4582;
    D4: ($A9, $16, $DB, $63, $60, $96, $43, $66));

  c_Pic = 'GENSIGNALS';
  c_Name = 'Генератор сигналов';
  c_defXSize = 370;
  c_defYSize = 90;

var
  g_GenSignalsFactory: cGenSignalsFactory;
  GenSignalsFrm: TGenSignalsFrm;


implementation

{$R *.dfm}

{ cGenSignalsFactory }

constructor cGenSignalsFactory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_GENSIGNALS;
  CreateEvents;
end;

destructor cGenSignalsFactory.destroy;
begin
  DestroyEvents;
  inherited;
end;

procedure cGenSignalsFactory.CreateEvents;
begin
  //addplgevent('cPolarFactory_doUpdateData', c_RUpdateData, doUpdateData);
  //addplgevent('cPolarFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
end;


procedure cGenSignalsFactory.DestroyEvents;
begin
  //removeplgEvent(doUpdateData, c_RUpdateData);
  //removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cGenSignalsFactory.doChangeRState(Sender: TObject);
begin
 case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
      end;
    RSt_StopToView:
      begin
        doStart;
      end;
    RSt_StopToRec:
      begin
        doStart;
      end;
    RSt_ViewToStop:
      begin

      end;
    RSt_ViewToRec:
      begin

      end;
    RSt_initToRec:
      begin
        doStart;
      end;
    RSt_initToView:
      begin
        doStart;
      end;
    RSt_RecToStop:
      begin
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

function cGenSignalsFactory.doCreateForm: cRecBasicIFrm;
begin
  result := IGenSignalsFrm.create();
end;

procedure cGenSignalsFactory.doSetDefSize(var pSize: SIZE);
begin
  inherited;
  pSize.cx := c_defXSize;
  pSize.cy := c_defYSize;
end;

procedure cGenSignalsFactory.doStart;
begin
end;

procedure cGenSignalsFactory.doUpdateData(Sender: TObject);
begin

end;

{ IGenSignalsFrm }

procedure IGenSignalsFrm.doClose;
begin
  m_lRefCount := 1;
end;

function IGenSignalsFrm.doCreateFrm: TRecFrm;
begin
  result := TGenSignalsFrm.create(nil);
end;

function IGenSignalsFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function IGenSignalsFrm.doRepaint: boolean;
begin

end;

{ TGenSignalsFrm }

constructor TGenSignalsFrm.create(Aowner: tcomponent);
begin
  inherited;

end;

destructor TGenSignalsFrm.destroy;
begin

  inherited;
end;

procedure TGenSignalsFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

procedure TGenSignalsFrm.RBtnClick(Sender: TObject);
begin

end;

procedure TGenSignalsFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
begin
  inherited;

end;

procedure TGenSignalsFrm.UpdateData;
begin

end;

{ cGenSig }

constructor cGenSig.create(sname: string; p_freq: double);
var
  bl: IBlockAccess;
begin
  m_t:=cTag.create;
  ecm;
  m_t.tag:=createVectorTagR8(sname, p_freq, false, false, false);
  if not FAILED(m_t.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    m_t.block := bl;
    bl := nil;
  end;
  lcm;
end;

destructor cGenSig.destroy;
begin

end;

end.
