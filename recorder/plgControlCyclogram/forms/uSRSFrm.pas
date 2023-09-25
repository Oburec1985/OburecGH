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
 // ������������ ������� �������
  �SpmCfg = class
  private
    // FFTplan
    FFTProp:TFFTProp;
    // ����� ����� fft, ����� ������ �� ������� ���� ������ ��������,
    m_fftCount,
    m_blockcount,
    // ���������� �������
    m_spmdx: double;
    // ��������� ����
    m_addNulls: boolean;
  private
    // ����������� ������� ����� �� �������� ���� ������
    // ������ ������� ���������
    fdt: double;
    // ������ ������ �� ������� ���� ������ (dt*fs)
    fportionsize: integer;
    // ������ ����� �� �������� ���� ������ fft. ���� �� ��������� ������ �� ����� m_fftCount*m_blockcount
    // ����� �������� ������ � ����� ����� m_fftCount*m_blockcount-fNullsPoints
    fOutSize,
    // ���������� �������� ����������� ������
    fNullsPoints:integer;
  public
    // ������ �������� � ���������
    m_SRSList:Tlist;
  end;

  cSRSTaho = class
  public
    // ��� ���� ������
    m_tag:ctag;
    // ���������� ��� ����������� �������
    m_treshold:double;
    // ������ ����� � ������������
    m_ShiftLeft, m_Length:double;
  private
    fSpmCfgList:TList;
  public
    function CfgCount:integer;
    function Cfg(i:integer):�SpmCfg;
    function name:string;
    constructor create;
    destructor destroy;
  end;

  cSRSres = class
  public
    cfg:�SpmCfg;
    m_SpmDx:double;
    m_freq:double;
    // ������ ����� ��� ������� ������� = freq*Numpoints
    blSize:double;
    // ���� ������ �� �������� ���� ������.
    m_T1data: TAlignDarray;
    // ������ re_im
    m_T1ClxData, m_TahoClxData:TAlignDCmpx;
  end;

  TSRSFrm = class(TRecFrm)
    cChart1: cChart;
    cChart2: cChart;
  public
    // ������ �������� ����
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

function cSRSTaho.Cfg(i: integer): �SpmCfg;
begin
  result:=�SpmCfg(fSpmCfgList.items[i]);
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
