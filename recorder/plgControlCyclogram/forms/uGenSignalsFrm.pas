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
    // начальный сдвиг фазы
    m_phase0:double;
  public
    m_debug:integer;
    m_name:string;
    m_type:integer;
    // логарифмическа€ развертка по времени
    m_lg:boolean;
    // частота процесса
    m_freq:double;
    // частота 2 дл€ Sweep
    m_freq2,
    // длительность развертки
    m_sweepTime:double;
    // частота опроса
    m_fs:double;
    m_t:ctag;
    // приращение фазы между двум€ соседними отсчетами.
    // ƒл€ sweepsin должно корректроватьс€ с учетом текущего времени
    // фактически определ€ет текущую частоту (приращение фазы за семпл)
    m_dPhase,
    // ускорение фазы дл€ sweep
    m_dPhVel:double;
    // спещение по Y
    m_offset:double;
  private
    // включить sweepsin
    m_sweep:boolean;
    m_amp:double;
    // текуща€ фаза
    m_Phase,
    // текуща€ частота при sweepSin, пересчитываетс€ из m_dPhase
    m_curFreq:double;
    // текуща€ длина нагенерированных данных. »спользуетс€ дл€ расчета фазы при SweepSin
    m_TimeLen:double;
    cs:TRTLCriticalSection;
  private
    procedure InitCS;
    procedure DeleteCS;
    procedure entercs;
    procedure exitcs;
    procedure UpdatePhaseVelocity(p_sweep:boolean);
    // выполн€етс€ в цикле/ приращение фазы
    procedure UpdatePhase;
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
    function getCurF:double;
    function getF:double;
    procedure setF(f:double);
    function getcfgStr:string;
    procedure SetCfgStr(s:string);
  public
    property Sweep:boolean read m_sweep write UpdatePhaseVelocity;
    property cfgStr:string read getcfgstr write setcfgstr;
    property Freq:double read getF write setF;
    property Amp:double read getA write setA;
    property Phase:double read getPhase write setPhase;
    property Phase0:double read getPhase0 write setPhase0;
    // p_freq - частота дикретизации
    constructor create(sname:string; p_Fs:double);
    destructor destroy(inCfg:boolean);
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
    EnabledAlgMngCB: TCheckBox;
    Splitter1: TSplitter;
    GenDataCb: TCheckBox;
    SweepSinCB: TCheckBox;
    Freq2Fe: TFloatSpinEdit;
    F2SweepLabel: TLabel;
    TimeSe: TFloatSpinEdit;
    SweepTimeLabel: TLabel;
    SweepLgCB: TCheckBox;
    procedure AmpSEChange(Sender: TObject);
    procedure PhaseSEChange(Sender: TObject);
    procedure SignalsLBClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure FreqSEChange(Sender: TObject);
    procedure OffsetFEChange(Sender: TObject);
    procedure EnabledAlgMngCBClick(Sender: TObject);
    procedure GenDataCbClick(Sender: TObject);
    procedure SignalsLBKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SweepSinCBClick(Sender: TObject);
    procedure TimeSeChange(Sender: TObject);
    procedure Freq2FeChange(Sender: TObject);
  private
    m_prevTime:double;
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
    // обновить форму по выбранному сигналу
    procedure UpdateFrmBySig(s:cgensig);
  public
    function doRepaint: boolean;
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
    m_init:boolean;
    m_counter: integer;
  protected
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doLeaveCfg(Sender: TObject);
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
  c_Name = '√енератор сигналов';
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
  m_init:=false;
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
  addplgevent('cGenSignalsFactory_doLeaveCfg', c_RC_LeaveCfg, doLeaveCfg);
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

procedure cGenSignalsFactory.doLeaveCfg(Sender: TObject);
var
  i, j: Integer;
  f:TGenSignalsFrm;
  s:cGenSig;
  t:itag;
begin
  if m_init then
  begin
    for I := 0 to count - 1 do
    begin
      f:=TGenSignalsFrm(GetFrm(i));
      for j := f.SignalsLB.Items.Count - 1 downto 0 do
      begin
        //s:=cGenSig(f.SignalsLB.Items.Objects[j]);
        s:=cGenSig(f.signals.Items[j]);
        t:=GetTagByName(s.m_name);
        if (t=nil) then
        begin
          s.destroy(true);
          f.SignalsLB.Items.Delete(j);
          f.signals.Delete(j);
        end;
      end;
    end;
  end;
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
  TGenSignalsFrm(m_pMasterWnd).doRepaint;
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

procedure TGenSignalsFrm.EnabledAlgMngCBClick(Sender: TObject);
begin
  g_algMng.m_enabled:=EnabledAlgMngCB.Checked;
end;

procedure TGenSignalsFrm.GenDataCbClick(Sender: TObject);
begin
  g_GenSignalsFactory.Timer1.enabled:=GenDataCb.Checked;
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
    s.destroy(false);
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

function TGenSignalsFrm.doRepaint: boolean;
begin
  FreqLabel.Caption:='F, √ц '+formatstrNoE(ActivSignal.getCurF, 3);
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
    s.m_dPhase:=c_2pi*(s.freq/s.m_fs);
    s.m_curFreq:=s.m_dphase*s.m_fs/c_2pi;
    s.m_TimeLen:=0;
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
  if FreqSE.text<>'' then
  begin
    s.m_freq:=FreqSE.Value;
    s.UpdatePhaseVelocity(s.sweep);
  end;
end;

procedure TGenSignalsFrm.Freq2FeChange(Sender: TObject);
var
  s:cGenSig;
begin
  s:=ActivSignal;
  if Freq2Fe.text<>'' then
  begin
    s.m_freq2:=Freq2Fe.Value;
    s.UpdatePhaseVelocity(s.sweep);
  end;
end;

procedure TGenSignalsFrm.TimeSeChange(Sender: TObject);
var
  s:cGenSig;
begin
  s:=ActivSignal;
  if TimeSe.text<>'' then
    s.m_sweepTime:=TimeSe.Value
  else
    s.m_sweepTime:=100;
end;
// p -фаза
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
  g_GenSignalsFactory.m_init:=true;
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

procedure TGenSignalsFrm.SweepSinCBClick(Sender: TObject);
var
  s:cGenSig;
begin
  s:=ActivSignal;
  s.sweep:=SweepSinCB.Checked;

  Freq2Fe.Visible:=SweepSinCB.Checked;
  F2SweepLabel.Visible:=SweepSinCB.Checked;
  TimeSe.Visible:=SweepSinCB.Checked;
  SweepTimeLabel.Visible:=SweepSinCB.Checked;
  SweepLgCB.Visible:=SweepSinCB.Checked;
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
  if signals.Count>0 then
  begin
    s:=cgensig(signals[0]);
    signalslb.ItemIndex:=0;
    AmpSE.Value:=s.Amp;
    FreqSE.Value:=s.Freq;
    PhaseSE.Value:=s.Phase0;
    STypeRG.ItemIndex:=s.m_type;
  end;
end;

procedure TGenSignalsFrm.SignalsLBClick(Sender: TObject);
var
  s:cGenSig;
begin
  s:=ActivSignal;
  if s=nil then
    exit;
  UpdateFrmBySig(s);
end;

procedure TGenSignalsFrm.UpdateFrmBySig(s: cgensig);
begin
  AmpSE.Value:=s.Amp;
  FreqSE.Value:=s.Freq;
  PhaseSE.Value:=s.Phase0;
  STypeRG.ItemIndex:=s.m_type;

  Freq2Fe.Value:=s.m_freq2;
  SweepSinCB.Checked:=s.m_sweep;
  SweepLgCB.Checked:=s.m_lg;
  TimeSe.Value:=s.m_sweepTime;
  SweepSinCBClick(nil);
end;

procedure TGenSignalsFrm.SignalsLBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  s:cGenSig;
  i:integer;
begin
  if key=VK_DELETE then
  begin
    s:=ActivSignal;
    if s=nil then
      exit;
    s.destroy(true);
    for I := 0 to signalsLB.Count - 1 do
    begin
      if signalslb.Selected[i] then
      begin
        signalslb.items.Delete(i);
        signals.Delete(i);
        exit;
      end;
    end;
  end;
end;

procedure TGenSignalsFrm.UpdateData(sender:tobject);
var
  I: Integer;
  s:cGenSig;
  j, k,blsize: Integer;
  p:pointer;
  dtstart, dt, curT, TimeLength:double;
begin
  curT:=g_GenSignalsFactory.time;
  dtstart:=curT-m_prevTime;
  FormTimerLabel.Caption:='Tформ: '+floattostr(curT);
  //SysTimerLabel.Caption:='Trec: '+floattostr(RecorderSysTime);
  for I := 0 to signals.Count - 1 do
  begin
    s:=cGenSig(signals.items[i]);
    dt:=dtstart;
    blsize:=s.m_t.BlockSize;
    TimeLength:=blsize/s.m_fs; // размер блока данных тега в секундах
    k:=0; // номер блока сгенеренных данных. дл€ вы€влени€ пропусков. ≈сли пропусков нет то k = 1
    while dt>=TimeLength do
    begin
      inc(k);
      s.m_debug:=k;
      s.m_t.m_TagData[0]:=genVal(s.phase+s.m_phase0,s);
      for j := 1 to blsize - 1 do
      begin
        // обновл€ем фазу
        s.UpdatePhase;
        s.m_t.m_TagData[j]:=genVal(s.phase+s.m_phase0,s);
      end;
      dt:=dt-TimeLength;
      p:=@s.m_t.m_TagData[0];
      s.m_t.tag.PushDataEx(p, BlSize, -1, -1);
      //s.m_t.tag.PushData(p^, BlSize);
      if (i=0) and (k=0) then
      begin
        m_prevTime:=curT;
      end;
    end;
  end;
end;

procedure cGenSig.UpdatePhase;
begin
  if m_sweep then
  begin
    if m_lg then
    begin

    end
    else
    begin
      m_dphase:=m_dphase+m_dPhVel;
      if phase<0 then
      begin
        phase:=0;
        if m_dphase<0 then
          m_dphase:=0;
      end;
      phase:=phase+m_dphase;
      m_curFreq:=m_dPhVel*m_fs/c_2pi;
    end;
  end
  else
  begin
    phase:=phase+m_dphase;
  end;
  if phase>c_2pi then
    phase:=phase-c_2pi;
end;


{ cGenSig }

function cGenSig.getCurF: double;
begin
  entercs;
  result:=m_curFreq;
  exitcs;
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

  str := GetParam(s, 'lg');
  if checkstr(str) then
    m_lg:=strtobool(str)
  else
    m_lg:=false;
  str := GetParam(s, 'F2');
  m_freq2:=strtoFloatExt(str);;
  str := GetParam(s, 'TimeLen');
  m_TimeLen:=strtoFloatExt(str);;
  str := GetParam(s, 'Sweep');
  if checkstr(str) then
    Sweep:=strtobool(str)
  else
    sweep:=false;
end;


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

  str := booltostr(m_lg);
  addParam(pars, 'lg', str);
  str:=FloatToStrEx(m_freq2,'.');
  addParam(pars, 'F2', str);
  str:=FloatToStrEx(m_TimeLen,'.');
  addParam(pars, 'TimeLen', str);
  str := booltostr(Sweep);
  addParam(pars, 'Sweep', str);

  result:= ParsToStr(pars);
  delpars(pars);
  pars.destroy;
end;

constructor cGenSig.create(sname: string; p_Fs: double);
var
  bl: IBlockAccess;
  t:itag;
begin
  m_sweepTime:=100;
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

destructor cGenSig.destroy(inCfg:boolean);
begin
  m_t.destroy(true);
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

procedure cGenSig.UpdatePhaseVelocity(p_sweep: boolean);
begin
  m_sweep:=p_sweep;
  if m_sweep then
  begin
    if m_lg then
    begin

    end
    else
    begin
      if m_t.tag<>nil then
      begin
        // Hz за семпл
        m_dPhVel:=(m_freq2-m_freq)/(m_t.freq*m_sweepTime);
        // –ад за семпл
        m_dPhVel:=c_2pi*m_dPhVel;
      end;
    end;
  end;
end;

end.
