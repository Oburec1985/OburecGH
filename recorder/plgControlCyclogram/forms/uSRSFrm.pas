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
  uCommonTypes,
  pluginClass,
  Dialogs, ExtCtrls;

type
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
    // определение размера блока по которому идет расчет
    // период расчета алгоритма
    fdt: double;
    // размер порции по которой идет расчет (dt*fs)
    fportionsize: integer;
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
    procedure addSRS(s:tobject);
    procedure createTahoTag;
    function SRSCount:integer;
    function name:string;
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
    m_T1ClxData, m_TahoClxData:TAlignDCmpx;
  public
    constructor create;
    destructor destroy;
  end;

  cSRSTaho = class(cSRSres)
  public
    // Амплдитуда для обнаружения события
    m_treshold:double;
    // отступ слева и длительность
    m_ShiftLeft, m_Length:double;
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
    // список настроек Тахо
    m_TahoList:TList;
  public
    procedure UpdateView;
    procedure updatedata;
    procedure UpdateBlocks;
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
  p:=SpmChart.tabs.activeTab.GetPage(1);
  r.BottomLeft.x:=0;
  r.BottomLeft.y:=0;
  r.TopRight.x:=10;
  r.TopRight.y:=10;
  p.ZoomfRect(r);
end;

procedure TSRSFrm.UpdateBlocks;
var
  refresh:double;
  lt:csrstaho;
begin
  refresh:=GetREFRESHPERIOD;
  lt:=getTaho;
  //m_Numpoints:=NearestOrd2(m_freq*refresh);
  // размер блока для расчета в секундах
  //blSize:= m_Numpoints / m_freq;
  // fOutSize := m_fftCount * m_blockcount;
  //GetMemAlignedArray_d(m_Numpoints, m_T1data);
  //GetMemAlignedArray_d(m_Numpoints, m_Tahodata);
  //GetMemAlignedArray_cmpx_d(m_Numpoints, m_T1ClxData);
  //GetMemAlignedArray_cmpx_d(m_Numpoints, m_TahoClxData);
  //FFTProp:=GetFFTPlan(m_Numpoints);
  //FFTProp.StartInd:=0;
end;


procedure TSRSFrm.updatedata;
begin

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

procedure TSRSFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, Count: integer;
  lstr, sect: string;
  //gr: IRDiagramTag;
begin
  inherited;
  {GraphMax := readFloatFromIni(a_pIni, str, 'GridMax');
  PSize := readFloatFromIni(a_pIni, str, 'PSize');
  GraphName := a_pIni.ReadString(str, 'ComponentName', 'Гистограмма биений');
  Count := a_pIni.ReadInteger(str, 'GraphCount', 1);
  clearGraphList;
  for i := 0 to Count - 1 do
  begin
    sect:='GraphName_' + inttostr(i);
    gr := addGraph( a_pIni.readString(str, sect+'_Name', ''));
    LoadexTagIni(a_pIni,gr.t1, str, sect+'_Tag');
    LoadexTagIni(a_pIni,gr.taho,str, sect+'_Taho');
    gr.ConfigTag();
    gr.DrawPoints:=a_pIni.readBool(str, sect+'_DrawP', true);
  end;}
end;

procedure TSRSFrm.RBtnClick(sender: tobject);
begin
  if EditSrsFrm <> nil then
  begin
    EditSrsFrm.Edit(self);
  end;
end;

procedure TSRSFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  t:cSRSTaho;
  c:cSpmCfg;
begin
  inherited;
  t:=getTaho;
  saveTagToIni(a_pIni,t.m_tag,'Taho','Taho_Tag');
  WriteFloatToIniMera(a_pIni, 'Taho', 'ShiftLeft', t.m_ShiftLeft);
  WriteFloatToIniMera(a_pIni, 'Taho', 'Threshold', t.m_treshold);
  WriteFloatToIniMera(a_pIni, 'Taho', 'Length', t.m_Length);
  c:=t.Cfg;
  a_pIni.WriteInteger('Cfg', 'FFtnum', c.m_fftCount);
  a_pIni.WriteInteger('Cfg', 'BlockCount', c.m_blockcount);
  a_pIni.WriteBool('Cfg', 'AddNulls', c.m_addNulls);
  for I := 0 to c.SRSCount - 1 do
  begin

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
 c.createTahoTag;
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
  fSpmCfgList:=TList.Create;
end;

destructor cSRSTaho.destroy;
begin
  fSpmCfgList.Destroy;
  inherited;
end;

function cSRSTaho.name: string;
begin
  result:=m_tag.tagname;
end;

{ сSpmCfg }
procedure cSpmCfg.addSRS(s: tobject);
var
  I: Integer;
  ls:cSRSres;
begin
  for I := 0 to m_SRSList.Count - 1 do
  begin
    ls:=cSRSres(m_SRSList.Items[i]);
    if s=ls then
      exit;
  end;
  m_SRSList.Add(s);
end;

procedure cSpmCfg.createTahoTag;
var
  t:cSRSres;
begin
  t:=cSRSres.Create;
  t.cfg:=self;
  addSRS(t);
end;

function cSpmCfg.name: string;
begin
  result:= cSRSTaho(taho).name+'_FFTp='+inttostr(FFTProp.PCount);
end;

function cSpmCfg.SRSCount: integer;
begin

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
