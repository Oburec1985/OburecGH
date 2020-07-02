unit uExtOperMng;

interface
uses
  ComObj, ActiveX, WPExtPack_TLB, Winpos_ole_TLB,
  StdVcl, PosBase, uMNK, variants,
  uWPProc, uCommonTypes, uWPservices,
  ComServ, uCommonMath, sysutils, classes,
  uwpOpers,
  uWPExtOperHilbFilter,
  uFindMaxOper,
  uWPExtOperRpt,
  uFrmHibFltFrm,
  uExtFFTInverse,
  uFFTInverseFrm,
  uExtBalanceSignals,
  uExtBalanceSignalsFrm,
  uFFTFlt,
  uFFTFltFrm,
  Windows
  ;

type
  TExtOperMng = class
  public
    eoBalanceZero:TExtBalanceSignals;
    eoFFTInverse:TExtFFTInverse;
    eoAmpFind: TExtOperAmpFind;
    eoRpt: TExtOperRpt;
    eoHilbFlt: TExtOperHilbertFlt;
    eoFFTFlt: TExtFFTflt;
    m_mng:cWPObjMng;
  public
    procedure NotifyPlugin(what:integer);
    constructor create(p_mng:cWPObjMng);
    destructor destroy;
  end;

var
  // указатель на тулбар винпоса
  bar_ID: Integer;
  // id ком excel
  ID_ExcelReport: Integer = 2;
  ID_ExcelReportBand: Integer = 8;
  ID_FFTInverse: Integer = 9;


implementation
uses
  urptfrm;


destructor TExtOperMng.destroy;
begin
  eoAmpFind.destroy;
  eoRpt.destroy;
  eoHilbFlt.destroy;
  eoFFTInverse.destroy;
  eoBalanceZero.destroy;
  FFTInverseFrm.Destroy;

  eoFFTFlt.destroy;
  FFTFltFrm.destroy;
end;


constructor TExtOperMng.create(p_mng:cWPObjMng);
var
  hbmp:cardinal;
  b:boolean;
begin
  m_mng:=p_mng;
  bar_ID := WINPOS.CreateToolbar();

  eoHilbFlt:= TExtOperHilbertFlt.create();
  eoHilbFlt.linc(m_mng);
  b:=WINPOS.RegisterExtOper(eoHilbFlt, 1, 1, HilbFltRegName, 'Hilb', true);
  HilbFltFrm:=THilbFltFrm.Create(nil);
  HilbFltFrm.linc(m_mng, eoHilbFlt);


  eoAmpFind := TExtOperAmpFind.create();
  eoAmpFind.linc(m_mng);

  eoFFTInverse:=TExtFFTInverse.create;
  eoFFTInverse.link(m_mng);
  FFTInverseFrm:=TFFTInverseFrm.Create(nil);
  FFTInverseFrm.link(eoFFTInverse);
  FFTInverseFrm.m_createThread:=GetCurrentThreadId;
  b:=WINPOS.RegisterExtOper(eoFFTInverse, 1, 1, 'FFTInverse', 'FFTInverse', true);

  eoBalanceZero:=TExtBalanceSignals.create;
  eoBalanceZero.link(m_mng);
  BalanceZeroFrm:=TBalanceZeroFrm.Create(nil);
  BalanceZeroFrm.link(eoBalanceZero);
  b:=WINPOS.RegisterExtOper(eoBalanceZero, 1, 1, 'BalanceZero', 'BalanceZero', true);

  // последний параметр определеяет будет ли вызван диалог настройки оператора
  // по умолчанию(диапазон обработки)
  b:=WINPOS.RegisterExtOper(eoAmpFind, 1, 1, FindMaxRegName, 'AmpFind', true);

  eoRpt := TExtOperRpt.create();
  eoRpt.linc(m_mng);

  eoFFTFlt:=TExtFFTflt.create();
  eoFFTFlt.link(m_mng);
  b:=WINPOS.RegisterExtOper(eoFFTFlt, 1, 1, 'FFT фильтр', 'FFT фильтр', true);
  FFTFltFrm:=TFFTFltFrm.Create(nil);
  FFTFltFrm.link(eoFFTFlt);


  ID_ExcelReport := WINPOS.RegisterCommand();
  ID_FFTInverse:=WINPOS.RegisterCommand();

  // последний параметр определеяет будет ли вызван диалог настройки оператора
  // по умолчанию(диапазон обработки)
  b:=WINPOS.RegisterExtOper(eoRpt, 1, 1, RptRegName, 'Rpt', true);
  hbmp := LoadBitmap(HInstance, 'ExcRep');
  WINPOS.CreatetoolbarButton(bar_ID, ID_ExcelReport, hbmp,
    'Отчет Excel'#10'Отчет Excel');

  ID_ExcelReportBand := WINPOS.RegisterCommand();
  hbmp := LoadBitmap(HInstance, 'RPTBAND');
  WINPOS.CreatetoolbarButton(bar_ID, ID_ExcelReportBand, hbmp,
    'Отчет Excel'#10'Добавить полосу');
end;

procedure TExtOperMng.NotifyPlugin(what:integer);
begin
  // запуск плагина
  if HIWORD(what) = ID_ExcelReport then
  begin
    eoRpt.Setup;
  end;
  if HIWORD(what) = ID_FFTInverse then
  begin
    eoFFTInverse.Setup;
  end;
  if HIWORD(what) = ID_ExcelReportBand then
  begin
    if RptFrm<>nil then
      RptFrm.addcursorband;
  end;
end;

end.
