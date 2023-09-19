unit uSRSFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath,
  Forms,
  Dialogs;

type
 // конфигуратор расчета спектра
  m_SpmCfg = class
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
    // список настроек Тахо
    m_TahoList:TStringlist;
  public
    { Public declarations }
  end;

var
  SRSFrm: TSRSFrm;

implementation

{$R *.dfm}

end.
