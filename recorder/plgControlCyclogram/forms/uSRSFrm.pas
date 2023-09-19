unit uSRSFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath,
  Forms,
  Dialogs;

type
 // ������������ ������� �������
  m_SpmCfg = class
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
  end;


  cSRSTaho = class
  private
    m_tag:ctag;
    m_treshold:double;
    m_ShiftLeft, m_Length:double;
  private
    fSpmCfgList:TList;
  end;

  TSRSFrm = class(TForm)
  private
    // ������ �������� ����
    m_TahoList:TStringlist;
  public
    { Public declarations }
  end;

var
  SRSFrm: TSRSFrm;

implementation

{$R *.dfm}

end.
