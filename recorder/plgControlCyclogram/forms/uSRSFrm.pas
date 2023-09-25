unit uSRSFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath,
  Forms, ComCtrls,
  uRecBasicFactory,
  uChart,
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
    // добавл€ть нули
    m_addNulls: boolean;
  private
    // разрешение спектра
    fspmdx: double;
    // определение размера блока по которому идет расчет
    // период расчета алгоритма
    fdt: double;
    // размер порции по которой идет расчет (dt*fs)
    fportionsize: integer;
    // размер блока по которому идет расчет fft. ≈сли не дополн€ть нул€ми то равен m_fftCount*m_blockcount
    // иначе полезных данных в блоке будет m_fftCount*m_blockcount-fNullsPoints
    fOutSize,
    // количество отсчетов дополн€емых нул€ми
    fNullsPoints:integer;
  public
    taho:tobject;
    // список сигналов к обработке
    m_SRSList:Tlist;
  public
    procedure addSRS(s:tobject);
    procedure createTahoTag;
    function name:string;
  end;

  cSRSres = class
  public
    m_tag:ctag;
  public
    cfg:cSpmCfg;
    m_SpmDx:double;
    m_freq:double;
    // размер блока дл€ расчета спектра = freq*Numpoints
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
    // јмплдитуда дл€ обнаружени€ событи€
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
    cChart1: cChart;
    cChart2: cChart;
  public
    // список настроек “ахо
    m_TahoList:TList;
  public
    procedure UpdateBlocks;
    procedure addTaho(t:csrstaho);
    function getTaho:csrstaho;
    constructor create;
    destructor destroy;
  end;

var
  SRSFrm: TSRSFrm;

implementation

{$R *.dfm}

{ TSRSFrm }

procedure TSRSFrm.addTaho(t: csrstaho);
begin
  m_tahoList.Add(t);
end;

constructor TSRSFrm.create;
begin
  m_TahoList:=TList.Create;
end;

destructor TSRSFrm.destroy;
begin
  m_TahoList.Destroy;
end;

procedure TSRSFrm.UpdateBlocks;
var
  refresh:double;
  lt:csrstaho;
begin
  refresh:=GetREFRESHPERIOD;
  lt:=getTaho;
  //m_Numpoints:=NearestOrd2(m_freq*refresh);
  // размер блока дл€ расчета в секундах
  //blSize:= m_Numpoints / m_freq;
  // fOutSize := m_fftCount * m_blockcount;
  //GetMemAlignedArray_d(m_Numpoints, m_T1data);
  //GetMemAlignedArray_d(m_Numpoints, m_Tahodata);
  //GetMemAlignedArray_cmpx_d(m_Numpoints, m_T1ClxData);
  //GetMemAlignedArray_cmpx_d(m_Numpoints, m_TahoClxData);
  //FFTProp:=GetFFTPlan(m_Numpoints);
  //FFTProp.StartInd:=0;
end;


function TSRSFrm.getTaho: csrstaho;
begin
  result:=csrstaho(m_tahoList.Items[0]);
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

{ cSRSres }

constructor cSRSres.create;
begin
  m_tag:=cTag.create;
end;

destructor cSRSres.destroy;
begin
  m_tag.destroy;
end;

end.
