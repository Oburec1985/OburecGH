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
  uBuffTrend1d,
  uCommonMath,
  uCommonTypes,
  pluginClass,
  Dialogs, ExtCtrls;

type
  cSRSres = class;
 // конфигуратор расчета спектра
  cSpmCfg = class
  public
    // FFTplan
    FFTProp:TFFTProp;
    // число точек fft, число блоков по которым идет расчет спектров,
    m_fftCount,
    m_blockcount:integer;
    // добавлять нули
    m_addNulls: boolean;
  private
    // разрешение спектра
    fspmdx: double;
    // размер порции по которой идет расчет (length*fs*blockCount) в сек.
    fportionsize: double;
    // размер порции по которой идет расчет в отсчетах
    fportionsizei:integer;
    // размер блока по которому идет расчет fft. Если не дополнять нулями то равен m_fftCount*m_blockcount
    // иначе полезных данных в блоке будет m_fftCount*m_blockcount-fNullsPoints
    fOutSize,
    // количество отсчетов дополняемых нулями
    fNullsPoints:integer;
  public
    taho:tobject;
    // список сигналов к обработке
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
    // размер блока для расчета спектра = freq*Numpoints
    blSize:double;
    // блок данных по которому идет расчет.
    m_T1data: TAlignDarray;
    // спектр re_im
    m_T1ClxData:TAlignDCmpx;
    line, lineSpm:cBuffTrend1d;
  public
    function name:string;
    constructor create;
    destructor destroy;
  end;

  cSRSTaho = class
  public
    // Амплдитуда для обнаружения события
    m_treshold:double;
    // отступ слева и длительность
    m_ShiftLeft, m_Length:double;
    m_tag:ctag;
    // блок данных по которому идет расчет.
    m_T1data: TAlignDarray;
    // спектр re_im
    m_T1ClxData:TAlignDCmpx;
    line, lineSpm:cBuffTrend1d;
  private
    fSpmCfgList:TList;
  protected
    procedure setCfg(c:cSpmCfg);
    function getCfg(i:integer):cSpmCfg;overload;
    function GetCfg:cSpmCfg;overload;
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
    pageT, pageSpm:cpage;
    // список настроек Тахо
    m_TahoList:TList;
  public
    procedure UpdateView;
    procedure updatedata;
    // выделение памяти. происходит при загрузке или смене конфига
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


var
  SRSFrm: TSRSFrm;
  g_SRSFactory: cSRSFactory;

const
  c_Pic = 'SRSFRM';
  c_Name = 'Анализ ударов';
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

{ TSRSFrm }

procedure TSRSFrm.addTaho(t: csrstaho);
begin
  m_tahoList.Add(t);
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
begin

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
  // размер блока для расчета в секундах
  c.fportionsize:= lt.m_Length*c.m_blockcount;
  c.fportionsizei:=round(c.fportionsize*lt.m_tag.freq);
  c.fOutSize := c.m_fftCount * c.m_blockcount;
  c.FFTProp:=GetFFTPlan(c.m_fftCount);
  c.FFTProp.StartInd:=0;
  GetMemAlignedArray_d(c.fportionsizei, lt.m_T1data);
  GetMemAlignedArray_cmpx_d(c.m_fftCount, lt.m_T1ClxData);
  for I := 0 to c.SRSCount - 1 do
  begin
    s:=c.GetSrs(i);
    GetMemAlignedArray_d(c.fportionsizei, s.m_T1data);
    GetMemAlignedArray_cmpx_d(c.m_fftCount, s.m_T1ClxData);
  end;
end;


procedure TSRSFrm.UpdateChart;
var
  l:cBuffTrend1d;
  t:csrstaho;
  c:cSpmCfg;
  s:cSRSres;
  I: Integer;
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

    l:= cBuffTrend1d.create;
    l.color := ColorArray[0];
    pageSpm.activeAxis.AddChild(l);
    t.lineSpm:=l;

    c:=t.Cfg;
    for I := 0 to c.SRSCount - 1 do
    begin
      s:=c.GetSrs(i);
      l:= cBuffTrend1d.create;
      pageT.activeAxis.AddChild(l);
      l.color := ColorArray[i+1];
      s.line:=l;

      l:= cBuffTrend1d.create;
      l.color := ColorArray[i+1];
      pageSpm.activeAxis.AddChild(l);
      s.lineSpm:=l;
    end;
  end;
end;

procedure TSRSFrm.updatedata;
begin
    if m_TrigTag.UpdateTagData(true) then
    begin
      v_min := m_TrigTag.m_ReadData[0];
      v_max := m_TrigTag.m_ReadData[0];
      for i := 1 to m_TrigTag.lastindex - 1 do
      begin
        v := m_TrigTag.m_ReadData[i];
        if v > v_max then
        begin
          v_max := v;
          imin := i;
          // rise
          if (v_max - v_min) > m_Threshold then
          begin
            m_TrigTime := m_TrigTag.getReadTime(i);
            m_TrigInterval.x := m_TrigTime + m_Phase0;
            m_TrigInterval.y := m_TrigInterval.x + m_Length;
            m_TrigRes := true;
            break;
          end;
        end
        else
        begin
          if v < v_min then
          begin
            v_min := v;
            imin := i;
            // fall
            if (v_max - v_min) > m_Threshold then
            begin
              m_TrigTime := m_TrigTag.getReadTime(i);
              m_TrigInterval.x := m_TrigTime + m_Phase0;
              m_TrigInterval.y := m_TrigInterval.x + m_Length;
              m_TrigRes := true;
              break;
            end;
          end;
        end;
      end;
      m_TrigTag.ResetTagData();
    end;
    b := false;
    for i := 0 to m_signals.count - 1 do
    begin
      s := GetSignal(i);
      if s.t.UpdateTagData(true, s.m_Resetsize) or b then
      begin
        t := s.GetInterval;
        if (t.y > m_TrigInterval.y) and m_TrigRes then
        begin
          if i = 0 then
            interval := getCommonInterval(m_TrigInterval, t)
          else
            interval := getCommonInterval(interval, t);
          if b or (i=0) then
            b := true;
        end
        else
        begin
          // данные триггера накопились не по всем каналам
          b:=false;
        end;
      end;
    end;
    // отображение триггерных данных
    if b then
    begin
      m_TrigRes := false;
      m_TimeLabel.Text := 'Time: ' + formatstr(interval.x, 3);
      for i := 0 to m_signals.count - 1 do
      begin
        s := GetSignal(i);
        if interval.x > 0 then
        begin
          v := interval.x;
          s.m_histX0:= v;
        end
        else
        begin

        end;
        // возвращает количество элементов в m_outData, ind - посл элемент в m_readData
        j := s.GetOscTrigData(s.m_outdata, interval, ind);
        if j > 0 then
        begin
          s.line.AddPoints(s.m_outdata, j);
          s.resetData(ind);
        end;
      end;
    end;
    exit;
  end;
end;

procedure TSRSFrm.UpdateView;
begin

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
  // отступ слева и длительность
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

function cSRSTaho.name: string;
begin
  result:=m_tag.tagname;
end;

{ сSpmCfg }
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
