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
  private
    m_phase0:double;
  public
    m_name:string;
    m_type:integer;
    m_freq:double;
    m_fs:double;
    m_t:ctag;
    m_dPhase:double;
    m_offset:double;
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
    // в градусах
    function getphase0:double;
    procedure setphase0(p:double);

    function getOffset:double;
    procedure setOffset(p:double);

    function getphase:double;
    procedure setphase(p:double);
    function getA:double;
    procedure setA(a:double);
    function getF:double;
    procedure setF(f:double);
    function getcfgStr:string;
    procedure SetCfgStr(s:string);
  public
    property cfgStr:string read getcfgstr write setcfgstr;
    property Freq:double read getF write setF;
    property Amp:double read getA write setA;
    property Phase:double read getPhase write setPhase;
    property Phase0:double read getPhase0 write setPhase0;
    // p_freq - частота дикретизации
    constructor create(sname:string; p_Fs:double);
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
    FormTimerLabel: TLabel;
    SysTimerLabel: TLabel;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    OffsetFE: TFloatSpinEdit;
    Label1: TLabel;
    procedure AmpSEChange(Sender: TObject);
    procedure PhaseSEChange(Sender: TObject);
    procedure SignalsLBClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure FreqSEChange(Sender: TObject);
    procedure OffsetFEChange(Sender: TObject);
  private
    signals:tlist;
  public
  private
    procedure dostop;
  protected
    function ActivSignal:cGenSig;
    procedure RBtnClick(Sender: TObject);
    procedure UpdateData(sender:tobject);
    function genVal(p:double;s:cGenSig):double;
    procedure dostart;
    procedure clearsignals;
    procedure showsignals;
    procedure Createtestsignals;
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
    time:double;
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
uses
  uGenSignalsEditFrm;


const
  c_sin = 0;
  c_saw = 1;
  c_random = 2;


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
  Timer1.Enabled:=false;
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
  time:=0;
  Timer1.Interval:=round(getrefreshperiod*1000);
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
  time:=time+(g_GenSignalsFactory.Timer1.Interval/1000);
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
  if ampse.text<>'' then
    s.Amp:=ampse.Value;
end;

procedure TGenSignalsFrm.PhaseSEChange(Sender: TObject);
var
  s:cgensig;
begin
  s:=ActivSignal;
  if PhaseSE.Text<>'' then
    s.phase0:=PhaseSE.Value;
end;


procedure TGenSignalsFrm.clearsignals;
var
  I: Integer;
  s:cGenSig;
begin
  SignalsLB.clear;
  for I := 0 to signals.Count - 1 do
  begin
    s:=cGenSig(signals.items[i]);
    s.destroy;
  end;
  signals.clear;
end;

constructor TGenSignalsFrm.create(Aowner: tcomponent);
var
  s:cGenSig;
begin
  inherited;
  signals:=tlist.create;
  //Createtestsignals;
end;

procedure TGenSignalsFrm.Createtestsignals;
var
  s:cGenSig;
begin
  s:=cGenSig.create('TestSin', 1000);
  s.Phase0:=0;
  s.Amp:=1;
  s.m_freq:=10;
  signals.Add(s);
  s:=cGenSig.create('TestSin_30', 1000);
  s.Phase0:=30;
  s.m_freq:=10;
  s.Amp:=1;
  signals.Add(s);
  showsignals;
end;

destructor TGenSignalsFrm.destroy;
begin
  clearsignals;
  signals.Destroy;
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
    s.Phase:=0;
    // частота процесса на частоту дискретизации
    s.m_dPhase:=c_2pi*(s.freq/s.m_t.freq);
  end;
end;

procedure TGenSignalsFrm.dostop;
begin

end;

procedure TGenSignalsFrm.FreqSEChange(Sender: TObject);
var
  s:cGenSig;
begin
  s:=ActivSignal;
  if Freqse.text<>'' then
    s.Freq:=Freqse.Value;
end;

function TGenSignalsFrm.genVal(p: double; s: cGenSig): double;
begin
  case s.m_type of
    c_sin:
    begin
      result:=s.m_amp*sin(p)+s.m_offset;
    end;
    c_random:
    begin
      result:=s.m_amp*Random+s.m_offset;
    end;
    c_saw:
    begin
      result:=s.m_amp*p/c_2pi+s.m_offset;
    end;
  end;
end;



procedure TGenSignalsFrm.RBtnClick(Sender: TObject);
begin

end;

procedure TGenSignalsFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  c:integer;
  I: Integer;
  s:cGenSig;
  f:double;
  lname, lstr, sfreq:string;
begin
  inherited;
  c:=a_pIni.ReadInteger(str, 'SCount', 0);
  signals.clear;
  for I := 0 to c - 1 do
  begin
    lstr:=a_pIni.ReadString(str, 'sig_' + inttostr(i), '');
    lname := GetParam(lstr, 'sname');
    sfreq:=GetParam(lstr, 'fs');
    s:=cGenSig.create(lname,strtofloatext(sfreq));
    s.cfgStr:=lstr;
    signals.Add(s);
  end;
  showsignals;
end;


procedure TGenSignalsFrm.N1Click(Sender: TObject);
begin
  GenSignalsEditFrm.NewSignal(signals);
  showsignals;
end;

procedure TGenSignalsFrm.OffsetFEChange(Sender: TObject);
var
  s:cGenSig;
begin
  s:=ActivSignal;
  if OffsetFE.text<>'' then
    s.m_offset:=OffsetFE.Value;
end;

procedure TGenSignalsFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i:integer;
  s:cGenSig;
begin
  inherited;
  a_pIni.WriteInteger(str, 'SCount', signals.Count);
  for i := 0 to signals.Count - 1 do
  begin
    s := cGenSig(signals.items[i]);
    a_pIni.WriteString(str, 'sig_' + inttostr(i), s.cfgstr);
  end;
end;

procedure TGenSignalsFrm.showsignals;
var
  I: Integer;
  s:cgensig;
begin
  signalslb.Clear;
  for I := 0 to signals.Count - 1 do
  begin
    s:=cgensig(signals[i]);
    signalslb.AddItem(s.m_name,s);
  end;
end;

procedure TGenSignalsFrm.SignalsLBClick(Sender: TObject);
var
  s:cGenSig;
begin
  s:=ActivSignal;
  if s=nil then
    exit;
  AmpSE.Value:=s.Amp;
  FreqSE.Value:=s.Freq;
  PhaseSE.Value:=s.Phase0;
  STypeRG.ItemIndex:=s.m_type;
end;

procedure TGenSignalsFrm.UpdateData(sender:tobject);
var
  I: Integer;
  s:cGenSig;
  j, blsize: Integer;
  p:pointer;
begin
  FormTimerLabel.Caption:='Tформ: '+floattostr(g_GenSignalsFactory.time);
  //SysTimerLabel.Caption:='Trec: '+floattostr(RecorderSysTime);
  for I := 0 to signals.Count - 1 do
  begin
    s:=cGenSig(signals.items[i]);
    blsize:=length(s.m_t.m_TagData);
    s.m_t.m_TagData[0]:=genVal(s.phase+s.m_phase0,s);
    for j := 1 to blsize - 1 do
    begin
      s.phase:=s.phase+s.m_dphase;
      if s.phase>c_2pi then
        s.phase:=s.phase-c_2pi;
      s.m_t.m_TagData[j]:=genVal(s.phase+s.m_phase0,s);
    end;
    p:=@s.m_t.m_TagData[0];
    //s.m_t.tag.PushDataEx(p^, BlSize, 0, -1);
    s.m_t.tag.PushData(p^, BlSize);
  end;
end;

{ cGenSig }

function cGenSig.getcfgStr: string;
var
  pars:tstringlist;
  str:string;
begin
  pars:=tstringlist.create;
  addParam(pars, 'sname', m_name);
  addParam(pars, 'type', inttostr(m_type));

  str:=FloatToStrEx(m_freq,'.');
  addParam(pars, 'freq', str);

  str:=FloatToStrEx(m_fs,'.');
  addParam(pars, 'fs', str);

  str:=FloatToStrEx(m_amp,'.');
  addParam(pars, 'amp', str);

  str:=FloatToStrEx(m_offset,'.');
  addParam(pars, 'offset', str);

  str:=FloatToStrEx(phase0,'.');
  addParam(pars, 'phase0', str);
  result:= ParsToStr(pars);
  delpars(pars);
  pars.destroy;
end;


procedure cGenSig.SetCfgStr(s: string);
var
  str:string;
begin
  str := GetParam(s, 'sname');
  m_name:=str;
  str := GetParam(s, 'type');
  m_type:=strtoint(str);
  str := GetParam(s, 'fs');
  m_fs:=strtoFloatExt(str);
  str := GetParam(s, 'phase0');
  phase0:=strtoFloatExt(str);
  str := GetParam(s, 'freq');
  m_freq:=strtoFloatExt(str);
  str := GetParam(s, 'amp');
  m_amp:=strtoFloatExt(str);
  str := GetParam(s, 'offset');
  m_offset:=strtoFloatExt(str);
end;

constructor cGenSig.create(sname: string; p_Fs: double);
var
  bl: IBlockAccess;
  t:itag;
begin
  InitCS;
  m_name:=sname;
  m_fs:=p_Fs;
  m_t:=cTag.create;
  ecm;
  t:=getTagByName(sname);
  if t<>nil then
    m_t.tag:=t
  else
  begin
    m_t.tag:=createVectorTagR8(sname, p_Fs, false, false, false);

  end;
  if not FAILED(m_t.tag.QueryInterface(IBlockAccess, bl)) then
  begin
    m_t.block := bl;
    bl := nil;
  end;
  lcm;
end;

destructor cGenSig.destroy;
begin
  m_t.destroy;
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

function cGenSig.getOffset: double;
begin
  entercs;
  result:=m_offset;
  exitcs;
end;

procedure cGenSig.setOffset(p: double);
begin
  entercs;
  m_offset:=p;
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

function cGenSig.getphase0: double;
begin
  result:=c_radtodeg*m_phase0;
end;

procedure cGenSig.setphase0(p: double);
begin
  m_phase0:=c_degtorad*p;
end;

end.
