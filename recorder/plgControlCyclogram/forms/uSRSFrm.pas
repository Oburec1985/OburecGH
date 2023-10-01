unit uSRSFrm;

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
  Dialogs, ExtCtrls;

type
  cSRSres = class;
 // ������������ ������� �������
  cSpmCfg = class
  public
    // FFTplan
    FFTProp:TFFTProp;
    // ����� ����� fft, ����� ������ �� ������� ���� ������ ��������,
    m_fftCount,fHalfFft,
    m_blockcount:integer;

    // ��������� ����
    m_addNulls: boolean;
  private
    // ���������� �������
    fspmdx: double;
    // ������ ������ �� ������� ���� ������ (length*fs*blockCount) � ���.
    fportionsize: double;
    // ������ ������ �� ������� ���� ������ � ��������
    fportionsizei:integer;
    // ������ ����� �� �������� ���� ������ fft. ���� �� ��������� ������ �� ����� m_fftCount*m_blockcount
    // ����� �������� ������ � ����� ����� m_fftCount*m_blockcount-fNullsPoints
    fOutSize,
    // ���������� �������� ����������� ������
    fNullsPoints:integer;
  public
    taho:tobject;
    // ������ �������� � ���������
    m_SRSList:Tlist;
  public
    procedure addSRS(s:pointer);
    function GetSrs(i:integer):cSRSres;
    function SRSCount:integer;
    function name:string;
    constructor create;
    destructor destroy;
  end;

  cSRSres = class
  public
    m_tag:ctag;
  public
    cfg:cSpmCfg;
    m_SpmDx:double;
    m_freq:double;
    // ������ ����� ��� ������� ������� = freq*Numpoints
    blSize:double;
    // ���� ������ �� �������� ���� ������.
    m_T1data: TAlignDarray;
    fDataCount:integer; // ���������� ������ � m_T1data
    // ������ re_im
    m_T1ClxData:TAlignDCmpx;
    // ������ ��������
    m_rms: TAlignDarray;
    line, lineSpm:cBuffTrend1d;
  private
    fComInt:point2d;
    // ������ ����� �������� � ���������� ������
    //fComInterval:boolean;
    fComIntervalLen:double;
  public
    function name:string;
    constructor create;
    destructor destroy;
  end;
  // ��������/ ������/ ��������
  TtrigStates = (TrOff, TrOn, TrEnd);

  cSRSTaho = class
  public
    // ���������� ��� ����������� �������
    m_treshold:double;
    // ������ ����� � ������������
    m_ShiftLeft, m_Length:double;
    m_tag:ctag;
    // ���� ������ �� �������� ���� ������. ������ fportionsizei = length*ShockCount
    m_T1data: TAlignDarray;
    fDataCount:integer; // ���������� ������ � m_T1data
    // ������ re_im
    m_T1ClxData:TAlignDCmpx;
    // ��� �� ������, �� ���������
    m_rms: TAlignDarray;
    line, lineSpm:cBuffTrend1d;
  private // ���������� ��� ������� � ��������� ���������
    v_min, v_max:double;
    f_imin, f_imax:integer; // ������� �������� ���������� �������� � ������� � ������� �����
    fTrigState:TtrigStates;
    // ����� ����� � �����
    fShockInd:integer;
    // ������ � ����� ���������� ��� ��������� �����
    TrigInterval:point2d;
  private
    fSpmCfgList:TList;
  protected
    procedure setCfg(c:cSpmCfg);
    function getCfg(i:integer):cSpmCfg;overload;
    function GetCfg:cSpmCfg;overload;
    // ����� ������ ����� �������, ������ ���� ��������:
    // �������� �������� ����� �������
    procedure resetTrig;
  public
    property Cfg:cSpmCfg read getcfg write setcfg;
    function CfgCount:integer;

    function name:string;
    constructor create;
    destructor destroy;
  end;

  TSRSFrm = class(TRecFrm)
    SpmChart: cChart;
    procedure FormCreate(Sender: TObject);
  public
    ready:boolean;
    pageT, pageSpm:cpage;
    // ������ �������� ����
    m_TahoList:TList;
  public
    procedure BuildSpm(s:tobject);
    procedure UpdateView;
    procedure updatedata;
    // ��������� ������. ���������� ��� �������� ��� ����� �������
    procedure UpdateBlocks;
    procedure UpdateChart;
    procedure doStart;
    procedure addTaho(t:csrstaho);
    function getTaho:csrstaho;
    procedure RBtnClick(sender: tobject);
  public
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent);override;
    destructor destroy;override;
  end;

 ISRSFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cSRSFactory = class(cRecBasicFactory)
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
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;
  // �������� ������ �� ���� �� ��������� ������� time � buf. ���������� ����� ���������
  function copyData(t:ctag; time:point2d; buf:TAlignDarray):integer;


var
  SRSFrm: TSRSFrm;
  g_SRSFactory: cSRSFactory;

const
  c_Pic = 'SRSFRM';
  c_Name = '������ ������';
  c_defXSize = 400;
  c_defYSize = 400;

  // ctrl+shift+G
  // ['{54C462CD-E137-4BA6-9FB5-EFD92D159DE5}']
  IID_SRS: TGuid = (D1: $54C462CD; D2: $E137; D3: $4BA6;
    D4: ($9F, $B5, $EF, $D9, $2D, $15, $9D, $E5));


implementation
uses
  uEditSrsFrm;

{$R *.dfm}

function copyData(t:ctag; time:point2d; buf:TAlignDarray):integer;
var
  int:tpoint;
begin
  int:=t.getIntervalInd(time);
  if int.x<0 then // ���� ����������� �� ������ ����������
  begin
    int.x:=0;
  end;
  result:=int.Y-int.x;
  move(t.m_ReadData[int.x], buf.p^, result*sizeof(double));
end;

{ TSRSFrm }

procedure TSRSFrm.addTaho(t: csrstaho);
begin
  m_tahoList.Add(t);
end;

procedure TSRSFrm.BuildSpm(s: tobject);
var
  k:double;
  c:cSpmCfg;
  i, halfNP:integer;
begin
  if s is cSRSTaho then
  begin
    c:=cSRSTaho(s).Cfg;
    fft_al_d_sse(TDoubleArray(cSRSTaho(s).m_T1data.p),
                tCmxArray_d(cSRSTaho(s).m_T1ClxData.p),
                cSpmCfg(c).FFTProp);
    // ������ ������� �������
    k := 2 / c.m_fftCount;
    halfNP:=c.m_fftCount shr 1;
    MULT_SSE_al_cmpx_d(tCmxArray_d(cSRSTaho(s).m_T1ClxData.p), k);
    EvalSpmMag(tCmxArray_d(cSRSTaho(s).m_T1ClxData.p),
               TDoubleArray(cSRSTaho(s).m_rms.p));
  end;
  if s is cSRSres then
  begin
    fft_al_d_sse(TDoubleArray(cSRSres(s).m_T1data.p),
                tCmxArray_d(cSRSres(s).m_T1ClxData.p),
                cSpmCfg(c).FFTProp);
    // ������ ������� �������
    k := 2 / c.m_fftCount;
    halfNP:=c.m_fftCount shr 1;
    MULT_SSE_al_cmpx_d(tCmxArray_d(cSRSres(s).m_T1ClxData.p), k);
    EvalSpmMag(tCmxArray_d(cSRSres(s).m_T1ClxData.p),
               TDoubleArray(cSRSres(s).m_rms.p));
  end;
end;

constructor TSRSFrm.create(Aowner: tcomponent);
begin
  m_TahoList:=TList.Create;
  inherited;
end;

destructor TSRSFrm.destroy;
begin
  m_TahoList.Destroy;
end;

procedure TSRSFrm.doStart;
var
  t:cSRSTaho;
  I: Integer;
  s:cSRSres;
begin
  ready:=false;
  t:=getTaho;
  if t.m_tag <> nil then
  begin
    t.m_tag.doOnStart;
    ZeroMemory(t.m_T1data.p,  t.cfg.fportionsizei* sizeof(double));
    if t.cfg<>nil then
    begin
      for I := 0 to t.Cfg.SRSCount - 1 do
      begin
        s:=t.Cfg.GetSrs(i);
        s.m_tag.doOnStart;
        ZeroMemory(s.m_T1data.p,  t.cfg.fportionsizei* sizeof(double));
      end;
    end
    else
      exit;
  end
  else
  begin
    exit;
  end;
  ready:=true;
end;

procedure TSRSFrm.FormCreate(Sender: TObject);
var
  p:cpage;
  r:frect;
begin
  spmchart.OnRBtnClick := RBtnClick;
  spmchart.tabs.activeTab.addPage(true);

  p:=SpmChart.tabs.activeTab.GetPage(0);
  r.BottomLeft.x:=0;
  r.BottomLeft.y:=0;
  r.TopRight.x:=10;
  r.TopRight.y:=10;
  p.ZoomfRect(r);
  p.Caption:='Oscillogram';
  pageT:=p;
  p:=SpmChart.tabs.activeTab.GetPage(1);
  r.BottomLeft.x:=0;
  r.BottomLeft.y:=0;
  r.TopRight.x:=10;
  r.TopRight.y:=10;
  p.ZoomfRect(r);
  p.Caption:='Freq Dom.';
  pageSpm:=p;
end;

procedure TSRSFrm.UpdateBlocks;
var
  refresh:double;
  lt:csrstaho;
  c:cSpmCfg;
  s:cSRSres;
  I: Integer;
begin
  refresh:=GetREFRESHPERIOD;
  lt:=getTaho;
  c:=lt.cfg;
  c.fHalfFft:= c.m_fftCount shr 1;
  // ������ ����� ��� ������� � ��������
  c.fportionsize:= lt.m_Length*c.m_blockcount;
  c.fportionsizei:=round(c.fportionsize*lt.m_tag.freq);
  c.fOutSize := c.m_fftCount * c.m_blockcount;
  c.fspmdx:=lt.m_tag.freq/c.m_fftCount;
  c.FFTProp:=GetFFTPlan(c.m_fftCount);
  c.FFTProp.StartInd:=0;
  GetMemAlignedArray_d(c.fportionsizei, lt.m_T1data);
  GetMemAlignedArray_cmpx_d(c.m_fftCount, lt.m_T1ClxData);
  GetMemAlignedArray_d(c.m_fftCount, lt.m_rms);
  lt.lineSpm.dx:=c.fspmdx;

  for I := 0 to c.SRSCount - 1 do
  begin
    s:=c.GetSrs(i);
    GetMemAlignedArray_d(c.fportionsizei, s.m_T1data);
    GetMemAlignedArray_cmpx_d(c.m_fftCount, s.m_T1ClxData);
    GetMemAlignedArray_d(c.m_fftCount, s.m_rms);
    s.lineSpm.dx:=c.fspmdx;
  end;
end;


procedure TSRSFrm.UpdateChart;
var
  l:cBuffTrend1d;
  t:csrstaho;
  c:cSpmCfg;
  s:cSRSres;
  I: Integer;
  fr:frect;
begin
  pageT.activeAxis.clear;
  pageSpm.activeAxis.clear;
  t:=getTaho;
  if t<>nil then
  begin
    l:= cBuffTrend1d.create;
    pageT.activeAxis.AddChild(l);
    l.color := ColorArray[0];
    t.line:=l;
    t.line.name:=t.name;
    l.dx:=1/t.m_tag.freq;

    l:= cBuffTrend1d.create;
    l.color := ColorArray[0];
    pageSpm.activeAxis.AddChild(l);
    t.lineSpm:=l;
    t.lineSpm.name:=t.name+'_spm';

    c:=t.Cfg;
    for I := 0 to c.SRSCount - 1 do
    begin
      s:=c.GetSrs(i);
      l:= cBuffTrend1d.create;
      pageT.activeAxis.AddChild(l);
      l.color := ColorArray[i+1];
      s.line:=l;
      s.line.name:=s.name;
      l.dx:=1/t.m_tag.freq;

      l:= cBuffTrend1d.create;
      l.color := ColorArray[i+1];
      pageSpm.activeAxis.AddChild(l);
      s.lineSpm:=l;
      s.lineSpm.name:=s.name+'_spm';
    end;
    fr.BottomLeft:=p2(0,-2*t.m_treshold);
    fr.TopRight:=p2(t.m_Length,t.m_treshold*2);
    pageT.ZoomfRect(fr);

    fr.BottomLeft:=p2(0,0);
    fr.TopRight:=p2(t.m_tag.freq/2,t.m_treshold*2);
    pageSpm.ZoomfRect(fr);
  end;
end;

procedure TSRSFrm.updatedata;
var
  t:csrstaho;
  c:cSpmCfg;
  s:cSRSres;
  i, pcount ,dropCount:integer;
  sig_interval, common_interval:point2d;
  v, comIntervalLen, blocklen, refresh:double;
begin
  if not ready then exit;
  t:=getTaho;
  c:=t.cfg;
  dropCount:=round(t.m_Length*t.m_tag.freq);
  blocklen:=t.m_Length;
  refresh:=t.m_tag.BlockSize/t.m_tag.freq;
  if blocklen<refresh then
    blocklen:=refresh;
  if t.m_tag.UpdateTagData(true) then
  begin
    if t.m_tag.getPortionLen>2*blocklen then
    begin
      t.m_tag.ResetTagDataTimeInd(dropCount);
    end;
    t.v_min := t.m_tag.m_ReadData[0];
    t.v_max := t.m_tag.m_ReadData[0];
    for i := 1 to t.m_tag.lastindex - 1 do
    begin
      v := t.m_tag.m_ReadData[i];
      if v > t.m_treshold then
      begin
        if v>t.v_max then
        begin
          t.fTrigState:=TrOn;
          t.v_max := v;
          t.f_imax := i;
        end;
      end
      else
      begin
        if t.fTrigState=TrOn then
        begin
          t.fTrigState:=TrEnd;
          t.ResetTrig;
          inc(t.fShockInd);
          t.TrigInterval.x:=t.m_tag.getReadTime(t.f_imax)-t.m_ShiftLeft;
          t.TrigInterval.y:=t.TrigInterval.x+t.m_Length;
          pcount:=copyData(t.m_tag, t.TrigInterval, t.m_T1data);
          t.fDataCount:=pcount;
          t.line.AddPoints(TDoubleArray(t.m_T1data.p), pcount);
          BuildSpm(t);
          t.lineSpm.AddPoints(TDoubleArray(t.m_rms.p), c.fHalfFft);
          break; // �� ���������� ������ � ������ (�����) ���� ��������
        end;
      end;
    end;
    for i := 0 to c.SRSCount - 1 do
    begin
      s := c.GetSrs(i);
      if s.m_tag.UpdateTagData(true) then
      begin
        sig_interval := s.m_tag.getPortionTime;
        if s.m_tag.getPortionLen>2*blocklen then
        begin
          s.m_tag.ResetTagDataTimeInd(dropCount);
        end;
      end;
      common_interval:=getCommonInterval(sig_interval, t.TrigInterval);
      ComIntervalLen:=common_interval.y-common_interval.x;
      if ComIntervalLen>0 then
      begin
        //s.fComInterval:=true;
        if ComIntervalLen>s.fComIntervalLen then
        begin
          s.fComIntervalLen:=ComIntervalLen;
          s.fComInt:=common_interval;
          pcount:=copyData(s.m_tag, common_interval, s.m_T1data);
          s.fDataCount:=pcount;
          s.line.AddPoints(TDoubleArray(s.m_T1data.p), pcount);
          BuildSpm(s);
          s.lineSpm.AddPoints(TDoubleArray(s.m_rms.p), c.fHalfFft);
        end;
      end;
    end;
  end;
end;

procedure TSRSFrm.UpdateView;
var
  i: integer;
begin
  if RStatePlay then
  begin

  end;
  SpmChart.redraw;
end;

function TSRSFrm.getTaho: csrstaho;
begin
  if m_taholist.count>0 then
    result:=csrstaho(m_tahoList.Items[0])
  else
    result:=nil;
end;


procedure TSRSFrm.RBtnClick(sender: tobject);
begin
  if EditSrsFrm <> nil then
  begin
    EditSrsFrm.Edit(self);
  end;
end;


procedure TSRSFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, count: integer;
  t:cSRSTaho;
  c:cSpmCfg;
  s:cSRSres;
  tag:itag;
  ltag:ctag;
begin
  inherited;
  ltag:=LoadTagIni(a_pIni,str,'Taho_Tag');
  if ltag<>nil then
  begin
    t:=cSRSTaho.create;
    t.m_tag.tag:=ltag.tag;
    ltag.destroy;
    c:=cSpmCfg.Create;
    t.Cfg:=c;
    addTaho(t);
  end
  else
    exit;
  t.m_ShiftLeft:=strtoFloatExt(a_pIni.ReadString(str, 'ShiftLeft', '0.05'));
  t.m_treshold:=strtoFloatExt(a_pIni.ReadString(str, 'Threshold', '0.05'));
  t.m_Length:=strtoFloatExt(a_pIni.ReadString(str, 'Length', '0.05'));
  if c<>nil then
  begin
    c.m_fftCount:=a_pIni.ReadInteger(str, 'FFtnum', 32);
    c.m_blockcount:=a_pIni.ReadInteger(str, 'BlockCount', 1);
    c.m_addNulls:=a_pIni.ReadBool(str, 'AddNulls', false);
    count:=a_pIni.ReadInteger(str, 'SigCount', 0);
    for I := 0 to count - 1 do
    begin
      tag:=LoadITagIni(a_pIni,str,'Tag_'+inttostr(i));
      if tag<>nil then
      begin
        c.addSRS(pointer(tag));
      end;
    end;
  end;
  UpdateChart;
  UpdateBlocks;
end;

procedure TSRSFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  t:cSRSTaho;
  c:cSpmCfg;
  s:cSRSres;
begin
  inherited;
  t:=getTaho;
  if t<>nil then
  begin
    saveTagToIni(a_pIni,t.m_tag,str,'Taho_Tag');
    WriteFloatToIniMera(a_pIni, str, 'ShiftLeft', t.m_ShiftLeft);
    WriteFloatToIniMera(a_pIni, str, 'Threshold', t.m_treshold);
    WriteFloatToIniMera(a_pIni, str, 'Length', t.m_Length);
    c:=t.Cfg;
    if c<>nil then
    begin
      a_pIni.WriteInteger(str, 'FFtnum', c.m_fftCount);
      a_pIni.WriteInteger(str, 'BlockCount', c.m_blockcount);
      a_pIni.WriteBool(str, 'AddNulls', c.m_addNulls);
      a_pIni.WriteInteger(str, 'SigCount', c.SRSCount);
      for I := 0 to c.SRSCount - 1 do
      begin
        s:=c.GetSrs(i);
        saveTagToIni(a_pIni,s.m_tag,str,'Tag_'+inttostr(i));
      end;
    end;
  end;
end;

{ cSRSTaho }
procedure cSRSTaho.setCfg(c: cSpmCfg);
var
  lc:cSpmCfg;
begin
 if fSpmCfgList.Count>0 then
 begin
   lc:=cSpmCfg(fSpmCfgList.Items[0]);
   lc.Destroy;
   fSpmCfgList.Clear;
 end;
 c.taho:=self;
 fSpmCfgList.Add(c);
end;

function cSRSTaho.GetCfg: cSpmCfg;
begin
  result:=cSpmCfg(fSpmCfgList.items[0]);
end;

function cSRSTaho.GetCfg(i: integer): cSpmCfg;
begin
  result:=cSpmCfg(fSpmCfgList.items[i]);
end;

function cSRSTaho.CfgCount: integer;
begin
  result:=fSpmCfgList.Count;
end;

constructor cSRSTaho.create;
begin
  inherited;
  m_treshold:=1;
  // ������ ����� � ������������
  m_ShiftLeft:=0.05;
  m_Length:=1;
  m_tag:=cTag.create;
  fSpmCfgList:=TList.Create;
end;

destructor cSRSTaho.destroy;
begin
  m_tag.destroy;
  fSpmCfgList.Destroy;
  inherited;
end;

procedure cSRSTaho.ResetTrig;
var
  c:cSpmCfg;
  I: Integer;
  s:cSRSres;
begin
  c:=Cfg;
  ZeroMemory(m_T1data.p,  c.m_fftCount* sizeof(double));
  for I := 0 to c.SRSCount - 1 do
  begin
    s:=c.GetSrs(i);
    s.fComIntervalLen:=0;
    ZeroMemory(s.m_T1data.p,  c.m_fftCount* sizeof(double));
  end;
end;

function cSRSTaho.name: string;
begin
  result:=m_tag.tagname;
end;

{ �SpmCfg }
procedure cSpmCfg.addSRS(s: pointer);
var
  I: Integer;
  ls:cSRSres;
  t:itag;
begin
  if GetObjectClass(s) = nil then
  begin
    if Supports(itag(pointer(s)),IID_ITAG) then
    begin
      t:=itag(pointer(s));
      for I := 0 to m_SRSList.Count - 1 do
      begin
        ls:=cSRSres(m_SRSList.Items[i]);
        if t=ls.m_tag.tag then
          exit;
      end;
      ls:=cSRSres.create;
      ls.m_tag.tag:=t;
      m_SRSList.Add(ls);
    end
  end
  else
  begin
    if tobject(s) is cSRSres then
    begin
      for I := 0 to m_SRSList.Count - 1 do
      begin
        ls:=cSRSres(m_SRSList.Items[i]);
        if s=ls then
          exit;
      end;
    end;
    m_SRSList.Add(s);
  end;
end;

constructor cSpmCfg.create;
begin
  m_SRSList:=TList.Create;
  m_fftCount:=32;
  m_blockcount:=1;
  m_addNulls:=false;
end;

destructor cSpmCfg.destroy;
begin
  m_SRSList.Destroy;
end;

function cSpmCfg.GetSrs(i: integer): cSRSres;
begin
  result:=cSRSres(m_SRSList.Items[i]);
end;

function cSpmCfg.name: string;
begin
  result:= cSRSTaho(taho).name+'_FFTp='+inttostr(FFTProp.PCount);
end;

function cSpmCfg.SRSCount: integer;
begin
  result:=m_SRSList.Count;
end;

{ cSRSres }
constructor cSRSres.create;
begin
  m_tag:=cTag.create;
end;

destructor cSRSres.destroy;
begin
  m_tag.destroy;
end;

function cSRSres.name: string;
begin
  result:=m_tag.tagname;
end;

{ cSRSFactory }

procedure cSRSFactory.createevents;
begin
  addplgevent('cSRSFactory_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('cSRSFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
end;

constructor cSRSFactory.create;
begin
  inherited;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_SRS;
  createevents;
end;

destructor cSRSFactory.destroy;
begin
  destroyevents;
  inherited;
end;

procedure cSRSFactory.destroyevents;
begin

end;

procedure cSRSFactory.doAfterLoad;
begin
  inherited;

end;

procedure cSRSFactory.doChangeRState(sender: tobject);
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

function cSRSFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := ISRSFrm.create();
  end;
end;

procedure cSRSFactory.doDestroyForms;
begin
  inherited;

end;

procedure cSRSFactory.doSetDefSize(var PSize: SIZE);
begin
  inherited;
end;

procedure cSRSFactory.doStart;
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TSRSFrm(Frm).doStart;
  end;
end;

procedure cSRSFactory.doUpdateData(sender: tobject);
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TSRSFrm(Frm).updateData;
  end;
end;

{ ISRSFrm }

procedure ISRSFrm.doClose;
begin
  m_lRefCount := 1;
end;

function ISRSFrm.doCreateFrm: TRecFrm;
begin
  result := TSRSFrm.create(nil);
end;

function ISRSFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function ISRSFrm.doRepaint: boolean;
begin
  inherited;
  TSRSFrm(m_pMasterWnd).UpdateView;
end;

end.
