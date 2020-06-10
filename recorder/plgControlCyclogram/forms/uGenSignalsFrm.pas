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
    m_freq:double;
    m_phase0:double;
    m_t:ctag;
    m_dPhase:double;
  private
    m_amp:double;
    m_Phase:double;
    cs:TRTLCriticalSection;
  private
    procedure InitCS;
    procedure DeleteCS;
    procedure entercs;
    procedure exitcs;
  protected
    function getphase:double;
    procedure setphase(p:double);
    function getA:double;
    procedure setA(a:double);
    function getF:double;
    procedure setF(f:double);
  public
    property Freq:double read getF write setF;
    property Amp:double read getA write setA;
    property Phase:double read getPhase write setPhase;
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
    procedure AmpSEChange(Sender: TObject);
    procedure PhaseSEChange(Sender: TObject);
  private
    fcapacity: integer;
    fcount: integer;
    signals:tlist;
  public
    m_tag: ctag;
    lastval: integer;
  private
    procedure dostop;
  protected
    function ActivSignal:cGenSig;
    procedure RBtnClick(Sender: TObject);
    procedure UpdateData(sender:tobject);
    function genVal(phase:double;s:cGenSig):double;
    procedure dostart;
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
  public
    Timer1: TTimer;
  private
    m_counter: integer;
  protected
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doStart;
    procedure doStop;
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

const
  c_sin = 0;
  c_random = 1;
  c_saw = 2;

{$R *.dfm}

{ cGenSignalsFactory }

constructor cGenSignalsFactory.create;
begin
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_GENSIGNALS;
  Timer1:=TTimer.Create(nil);
  Timer1.OnTimer:=doUpdateData;
  CreateEvents;
end;

destructor cGenSignalsFactory.destroy;
begin
  Timer1.Enabled:=false;
  Timer1.destroy;
  DestroyEvents;
  inherited;
end;

procedure cGenSignalsFactory.CreateEvents;
begin
  //addplgevent('cPolarFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cGenSignalsFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
end;


procedure cGenSignalsFactory.DestroyEvents;
begin
  //removeplgEvent(doUpdateData, c_RUpdateData);
  removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
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
        doStop;
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
        doStop;
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
var
  I: Integer;
  sigList:TGenSignalsFrm;
begin
  timer1.Enabled:=true;
  for I := 0 to m_CompList.Count- 1 do
  begin
    sigList:=TGenSignalsFrm(GetFrm(i));
    sigList.dostart;
  end;
end;

procedure cGenSignalsFactory.doStop;
begin
  timer1.Enabled:=false;
end;

procedure cGenSignalsFactory.doUpdateData(Sender: TObject);
var
  I: Integer;
  sigList:TGenSignalsFrm;
begin
  for I := 0 to m_CompList.Count- 1 do
  begin
    sigList:=TGenSignalsFrm(GetFrm(i));
    sigList.UpdateData(nil);
  end;;
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

function TGenSignalsFrm.ActivSignal: cGenSig;
var
  I: Integer;
begin
  if signals.Count=0 then
  begin
    result:=nil;
    exit;
  end;
  for I := 0 to signalsLB.Count - 1 do
  begin
    if signalslb.Selected[i] then
    begin
      result:=cGenSig(signals.Items[i]);
      exit;
    end;
  end;

  result:=cGenSig(signals.Items[0]);
end;

procedure TGenSignalsFrm.AmpSEChange(Sender: TObject);
var
  s:cgensig;
begin
  s:=ActivSignal;
  s.Amp:=ampse.Value;
end;

procedure TGenSignalsFrm.PhaseSEChange(Sender: TObject);
var
  s:cgensig;
begin
  s:=ActivSignal;
  s.phase:=PhaseSE.Value;
end;


constructor TGenSignalsFrm.create(Aowner: tcomponent);
begin
  inherited;

end;

destructor TGenSignalsFrm.destroy;
begin

  inherited;
end;

procedure TGenSignalsFrm.dostart;
var
  I: Integer;
  s:cGenSig;
begin
  for I := 0 to signals.Count - 1 do
  begin
    s:=cGenSig(signals.items[i]);
    s.Phase:=s.m_Phase0;
    // частота процесса на частоту дискретизации
    s.m_dPhase:=c_2pi*(s.freq/s.m_t.freq);
  end;
end;

procedure TGenSignalsFrm.dostop;
begin

end;

function TGenSignalsFrm.genVal(phase: double; s: cGenSig): double;
begin
  case s.m_type of
    c_sin:
    begin
      result:=s.m_amp*sin(phase);
    end;
    c_random:
    begin
      result:=s.m_amp*Random;
    end;
    c_saw:
    begin
      result:=s.m_amp*phase/c_2pi;
    end;
  end;
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

procedure TGenSignalsFrm.UpdateData(sender:tobject);
var
  I: Integer;
  s:cGenSig;
  j, blsize: Integer;
  p:pointer;
begin
  for I := 0 to signals.Count - 1 do
  begin
    s:=cGenSig(signals.items[i]);
    blsize:=s.m_t.block.GetBlocksSize;
    for j := 0 to blsize - 1 do
    begin
      s.phase:=s.phase+s.m_dphase;
      if s.phase>c_2pi then
        s.phase:=s.phase-c_2pi;
      s.m_t.m_TagData[j]:=genVal(s.phase,s);
    end;
    p:=@s.m_t.m_TagData[0];
    s.m_t.tag.PushDataEx(p^, BlSize, 0, -1);
  end;
end;

{ cGenSig }

constructor cGenSig.create(sname: string; p_freq: double);
var
  bl: IBlockAccess;
begin
  InitCS;
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
  DeleteCS;
end;

procedure cGenSig.entercs;
begin
  EnterCriticalSection(cs);
end;

procedure cGenSig.InitCS;
begin
  InitializeCriticalSection(cs);
end;

procedure cGenSig.DeleteCS;
begin
  DeleteCriticalSection(cs);
end;


procedure cGenSig.exitcs;
begin
  LeaveCriticalSection(cs);
end;

function cGenSig.getA: double;
begin
  entercs;
  result:=m_amp;
  exitcs;
end;

function cGenSig.getF: double;
begin
  entercs;
  result:=m_freq;
  exitcs;
end;

procedure cGenSig.setF(f: double);
begin
  entercs;
  m_freq:=F;
  // частота процесса/ на частоту дискретизации
  m_dPhase:=c_2pi*(f/m_t.freq);
  exitcs;
end;

procedure cGenSig.setA(a: double);
begin
  entercs;
  m_amp:=a;
  exitcs;
end;


function cGenSig.getphase: double;
begin
  entercs;
  result:=m_phase;
  exitcs;
end;



procedure cGenSig.setphase(p: double);
begin
  entercs;
  m_phase:=p;
  exitcs;
end;

end.
