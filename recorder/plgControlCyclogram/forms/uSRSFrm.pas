unit uSRSFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath,
  Forms,
  uRecBasicFactory,
  uChart,
  Dialogs, ExtCtrls;

type
 // конфигуратор расчета спектра
  сSpmCfg = class
  private
    // FFTplan
    FFTProp:TFFTProp;
    // число точек fft, число блоков по которым идет расчет спектров,
    m_fftCount,
    m_blockcount,
    // разрешение спектра
    m_spmdx: double;
    // добавлять нули
    m_addNulls: boolean;
  private
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
    // список сигналов к обработке
    m_SRSList:Tlist;
  end;

  cSRSTaho = class
  public
    // тег тахо канала
    m_tag:ctag;
    // Амплдитуда для обнаружения события
    m_treshold:double;
    // отступ слева и длительность
    m_ShiftLeft, m_Length:double;
  private
    fSpmCfgList:TList;
  public
    function CfgCount:integer;
    function Cfg(i:integer):сSpmCfg;
    function name:string;
    constructor create;
    destructor destroy;
  end;

  cSRSres = class
  public
    cfg:сSpmCfg;
    m_SpmDx:double;
    m_freq:double;
    // размер блока для расчета спектра = freq*Numpoints
    blSize:double;
    // блок данных по которому идет расчет.
    m_T1data: TAlignDarray;
    // спектр re_im
    m_T1ClxData, m_TahoClxData:TAlignDCmpx;
  end;

  TSRSFrm = class(TRecFrm)
    cChart1: cChart;
    cChart2: cChart;
  public
    // список настроек Тахо
    m_TahoList:TList;
  public
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

function TSRSFrm.getTaho: csrstaho;
begin
  result:=csrstaho(m_tahoList.Items[0]);
end;

{ cSRSTaho }

function cSRSTaho.Cfg(i: integer): сSpmCfg;
begin
  result:=сSpmCfg(fSpmCfgList.items[i]);
end;

function cSRSTaho.CfgCount: integer;
begin
  result:=fSpmCfgList.Count;
end;

constructor cSRSTaho.create;
begin
  m_tag:=cTag.create;
  fSpmCfgList:=TList.Create;
end;

destructor cSRSTaho.destroy;
begin
  fSpmCfgList.Destroy;
  m_tag.destroy;
end;

function cSRSTaho.name: string;
begin
  result:=m_tag.tagname;
end;

end.
