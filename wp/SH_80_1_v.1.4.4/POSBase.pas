//**************************************************
// WinПОС: Библиотека вызова стандартных алгоритмов
// Совместимость: WinПОС профи, WinПОС вибро
// Изменения: 20.10.03
//**************************************************
// Перечень процедур:
// RunFFT, RunCrossFFT, RunComplexFFT, RunCoher,
// RunPRV, RunFuncTransfer, RunOgib, RunIIRFiltering
// RunFIRFiltering, RunDiff, RunIntegral,
// RunAutoCorel, RunCrossCorel, RunOgib
// Подробное описание и пояснения см. в справочной
// системе WinПОС: Вызов из меню: "Помощь"->
// ->"Содержание"->"Сценарии WinПОС"
//**************************************************
unit POSBase;

interface

uses Winpos_ole_TLB;

procedure RunFFT(const Src : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
procedure RunCrossFFT(const Src1, Src2 : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
procedure RunComplexFFT(const Real, Imag : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
procedure RunCoher(const Src1, Src2 : OleVariant; var Rez, OptFFT, Err : OleVariant);
procedure RunFuncTransfer(const Src1, Src2 : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
procedure RunIIRFiltering(const Src : OleVariant; var Rez, Opt, Err : OleVariant);
procedure RunFIRFiltering(const Src : OleVariant; var Rez, Opt, Err : OleVariant);
procedure RunDiff(const Src : OleVariant; var Rez, Method, Err : OleVariant);
procedure RunPRV(const Src : OleVariant; var Rez, NumPoints, TpPrv, Err : OleVariant);
procedure RunAutoCorel(const Src : OleVariant; var Rez, NumPoints, Eps, Err : OleVariant);
procedure RunCrossCorel(const Src1, Src2 : OleVariant; var Rez, NumPoints, Eps, Err : OleVariant);
procedure RunOgib(const Src : OleVariant; var Rez, NumPoints, Err : OleVariant);
procedure RunIntegral(const Src : OleVariant; var Rez, Method, NPoint, TypeRezult, Err : OleVariant);
procedure RunResampling(const Src : OleVariant; var Rez : OleVariant; Freq, Method, FltType : OleVariant; var Err : OleVariant);

procedure Signal2Graph(const signal: IWPSignal);

{ *WinPOS* VBSCRIPT API
procedure RunFFT(const Src : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
procedure RunCrossFFT(const Src1, Src2 : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
procedure RunCoher(const Src1, Src2 : OleVariant; var Rez, OptFFT, Err : OleVariant);
procedure RunFuncTransfer(const Src1, Src2 : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
procedure RunRecursFiltring(const Src : OleVariant; var Rez,Opt,Err : OleVariant);
procedure RunAFFiltr(const Src : OleVariant; var Rez, Opt, Err : OleVariant);
procedure RunDiff(const Src : OleVariant; var Rez, Method, Err : OleVariant);
procedure RunPRV(const Src : OleVariant; var Rez, NumPoints, TpPrv, Err : OleVariant);
procedure RunAutoCorel(const Src : OleVariant; var Rez, NumPoints, Eps, Err : OleVariant);
procedure RunCrossCorel(const Src1, Src2 : OleVariant; var Rez, NumPoints, Eps, Err : OleVariant);
procedure RunOgib(const Src : OleVariant; var Rez, NumPoints, Err : OleVariant);
procedure RunIntegralFunc(const Source : OleVariant; var Rez, Method, NPoint, TypeRezult, Err : OleVariant);
procedure RunIntegral(const Buf : OleVariant; var Method, Integral, Err : OleVariant);
procedure RunComplexFFT(const Real, Imag : OleVariant; var Rez1, Rez2, NumPoints, Inverse, Err : OleVariant);
}

{ *POS* CMD MODE API
Procedure  RunFFT(BuferSrc,BuferRez1,BuferRez2:word; var Error:integer);
Procedure  RunFFTCMD(BuferSrc,BuferRez1,BuferRez2:Word; var OptFFT:ParamFFT; var Error:integer);
Procedure  RunCrossFFTCMD(BuferSrc1,BuferSrc2,BuferRez1,BuferRez2:Word; var OptFFT:ParamFFT; var Error:integer);
Procedure  RunCoherCMD(BuferSrc1,BuferSrc2,BuferRez:Word; var OptFFT:ParamFFT; var Error:integer);
Procedure  RunFuncTransferCMD(BuferSrc1,BuferSrc2,BuferRez1,BuferRez2:Word; var OptFFT:ParamFFT; var Error:integer);
Procedure  RecursFiltring(BuferSrc,BuferRez:word;var Error:integer);
Procedure  RecursFiltringCMD(BuferSrc,BuferRez:word; var Error:integer);
Procedure  RunAFFiltrCMD(BuferAmpl,BuferFase:word;var Error:integer);
Procedure  SetParamFiltr(AP,TIP,VID,KP:Integer; FSR,FN,FV:real; var Error:integer);
Procedure  RunDiff(BuferSrc,BuferRez,Method:word;var Error:Integer );
Procedure  RunPRV(BuferSrc,BuferRez,NumPoints,TpPrv:word; var Error:integer );
Procedure  RunAutoCorel(BuferSrc,BuferRez,NumPoints:Word; var Eps:Real; var Error:integer );
Procedure  RunCrossCorel(BuferSrc1,BuferSrc2,BuferRez,NumPoints:Word; var Eps:Real; var Error:integer );
Procedure  RunOktav3(BuferSrc,BuferRez,NumPoints,NumBlock,TypeXar:Word; var  Error:integer);
Procedure  RunOgib(BuferSrc,BuferRez,NumPoints:word; var Error:Integer );
Procedure  RunIntegralFunc(BuferSource,BuferRez,Method,NPoint:Word; TypeRezult:byte; var Error:Integer );
Procedure  RunIntegral(Bufer,Method:word; var Integral:Real; var Error:Integer );
Procedure  RunStat(Bufer:word; var MinY,MaxY,m_o,disp,A3,A4:real);
Procedure  ComplexFFT(BufReal,BufImag,BuferRez1,BuferRez2,NumPoints:Word; Inverse:boolean; var Error:integer);
}

function refvar(var v : Olevariant) : OleVariant;

var WP: TWinPOS;
var WINPOS : IWinPOS;

// Константы для задания типа данных сигнала (VarType)
const VT_I1	  : Integer = 16;
const VT_UI1  : Integer = 17;
const VT_I2   : Integer = 2;
const VT_UI2  : Integer = 18;
const VT_I4   : Integer = 3;
const VT_R4   : Integer = 4;
const VT_R8   : Integer = 5;

// Константы для задания свойств линии
const LNOPT_SET_LINE2BASE		: Integer = $0001;
const LNOPT_SET_ONLYPOINTS	: Integer = $0002;
const LNOPT_CHANGE_COLOR		: Integer = $0010;
const LNOPT_SET_WIDTH				: Integer = $0020;

// Константы вида страницы графиков
const PAGE_DM_VERT	: Integer = 0;
const PAGE_DM_HORZ 	: Integer = 1;
const PAGE_DM_TABLE	: Integer = 2;

// Константы для вызова диалога выбора файла
const OFN_READONLY             : Integer = $00000001;
const OFN_OVERWRITEPROMPT      : Integer = $00000002;
const OFN_HIDEREADONLY         : Integer = $00000004;
const OFN_NOCHANGEDIR          : Integer = $00000008;
const OFN_SHOWHELP             : Integer = $00000010;
const OFN_ENABLEHOOK           : Integer = $00000020;
const OFN_ENABLETEMPLATE       : Integer = $00000040;
const OFN_ENABLETEMPLATEHANDLE : Integer = $00000080;
const OFN_NOVALIDATE           : Integer = $00000100;
const OFN_ALLOWMULTISELECT     : Integer = $00000200;
const OFN_EXTENSIONDIFFERENT   : Integer = $00000400;
const OFN_PATHMUSTEXIST        : Integer = $00000800;
const OFN_FILEMUSTEXIST        : Integer = $00001000;
const OFN_CREATEPROMPT         : Integer = $00002000;
const OFN_SHAREAWARE           : Integer = $00004000;
const OFN_NOREADONLYRETURN     : Integer = $00008000;
const OFN_NOTESTFILECREATE     : Integer = $00010000;
const OFN_NONETWORKBUTTON      : Integer = $00020000;
const OFN_NOLONGNAMES          : Integer = $00040000; //force no long names for 4.x modules
const OFN_EXPLORER             : Integer = $00080000; //new look commdlg
const OFN_NODEREFERENCELINKS   : Integer = $00100000;
const OFN_LONGNAMES            : Integer = $00200000; //force long names for 3.x modules
const OFN_ENABLEINCLUDENOTIFY  : Integer = $00400000; //send include message to callback
const OFN_ENABLESIZING         : Integer = $00800000;

// Константы типа файла (FT = File Type)
const FT_Text 	  : Byte	= 0;
const FT_TextWiz  : Byte	= 1;
const FT_UChar 	  : Byte	= 2;
const FT_INT16 	  : Byte	= 3;
const FT_WORD 	  : Byte	= 4;
const FT_Float 	  : Byte	= 5;
const FT_Double   : Byte	= 6;
const FT_XLS   		: Byte	= 7;

// Константы характеристик
const SC_NORMAL   : Integer = 0;
const SC_SPECTR   : Integer = 1;
const SC_LOGSPEC  : Integer = 2;
const SC_LOGX     : Integer = 4;

//***FFT***
const MaxSizeArray   : Integer = 1024*256;
const SizeRealForFFT : Integer = 4;
// typeFFT
const AUTOSPECTR  : Integer =  0;
const CROSS       : Integer = 20;
const COHEREN     : Integer = 30;
const TRANS       : Integer = 40;
const COMPLEX     : Integer = 50;
// kindFuncFFT - вид рассчитываемой характеристики
const SPM         : Integer = 1;  // спектр плотности мощности
const SM          : Integer = 2;  // спектр мощности
const SPP         : Integer = 3;  // спектр плотности энергии
const SMAG        : Integer = 4;  // спектр амплитудный
const SRI         : Integer = 5;  // Real & Image
const SMF         : Integer = 6;  // Mod & Fase
const SPM3D       : Integer = 7;  // трехмерный спектр СПМ
const SMAG3D      : Integer = 8;  // трехмерный спектр Ампл
const SCEPSTR     : Integer = 9;
const Oktav3      : Integer = 10;
const Oktav1      : Integer = 11;
// cross spectr analysis
const CrSPM  : Integer = 21; // Cross SPM
const CrRI   : Integer = 22; // Cross Real & Imag
const CrMF   : Integer = 23; // Cross Mod & Fase
const CrSPM3D: Integer = 24;
// coherence
const COHERF : Integer = 31;
const COP    : Integer = 32; // когерентная выходная мощность
const S_N    : Integer = 33; // отношение сигнала к шуму
const NOTCOP : Integer = 34; // некогерентная выходная мощность
const NOTCHR : Integer = 35; // ф-ия некогерентности
// transfer
const H1     : Integer = 41; // передаточная ф-ия H1
const H2     : Integer = 42;
// 1 - эффективные; 2 - амплитудные значения   for typeMagnitude
const MEAD        : Integer = 1;
const PEAK        : Integer = 2;
const MAXPEAK     : Integer = 3;
//-- typeWindowFFT - типы весовых окон
const SINGLEWIN   : Integer = 1;
const TRIANGLEWIN : Integer = 2;
const HANNINGWIN  : Integer = 3;
const BLACKMANWIN : Integer = 4;
const FLATTOP     : Integer = 5;
//-- Типы записей алгоритмов --
const NUMFFTZOOM    : Integer = 1024;
const MAXPOINTSFFT  : Integer = 256*1024;
const cNumNumPntFFT : Integer = 16;

//***IIR Filter***
const MaxOrderFilter : Integer = 50;
const Normalized     : Integer = 1;
const PeriodEvent    : Integer = 10240;
//--- COptionsIIRFilter.flag
const First    : Integer = 1;
const Second   : Integer = 2;
//--- COptionsIIRFilter.ikind
const LowPass  : Integer = 1;
const BandPass : Integer = 2;
const HighPass : Integer = 3;
const BandStop : Integer = 4;
//--- COptionsIIRFilter.itype
const Butterworth : Integer = 1;
const Chebyshev   : Integer = 2;
const Elliptic    : Integer = 3;

//***FIR Filter***
//-- типы весовых окон WindowFFT --
const HANN       : Integer = 2;  // окно Хэнна
const HAMMINGWIN : Integer = 3;  // окно Хэмминга

//**************************************************************************
implementation

function refvar(var v : Olevariant) : OleVariant;
begin
  with TVarData(result) do
  begin
    VType:= varVariant or varByref;
    VPointer:= @v;
  end;
end;

procedure RunWPOperator(const OpName : String; const Src1, Src2 : OleVariant; var Rez1, Rez2, Opt, Err : OleVariant);
var oper : IWPOperator;
begin
  oper:= WINPOS.GetObject(OpName) as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.loadProperties(Opt);
    oper.Exec(Src1,Src2,refvar(Rez1),refvar(Rez2));
  end
  else
    Err:= -1001;
end;

procedure RunFFT(const Src : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
begin
  RunWPOperator( '/Operators/АвтоСпектр', Src, Src, Rez1, Rez2, OptFFT, Err );
end;

procedure RunCrossFFT(const Src1, Src2 : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
begin
  RunWPOperator( '/Operators/Взаимный Спектр', Src1, Src2, Rez1, Rez2, OptFFT, Err );
end;

procedure RunComplexFFT(const Real, Imag : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
begin
  RunWPOperator( '/Operators/Комплексный спектр', Real, Imag, Rez1, Rez2, OptFFT, Err );
end;

procedure RunCoher(const Src1, Src2 : OleVariant; var Rez, OptFFT, Err : OleVariant);
begin
  RunWPOperator( '/Operators/Функция когерентности', Src1, Src2, Rez, Rez, OptFFT, Err );
end;

procedure RunFuncTransfer(const Src1, Src2 : OleVariant; var Rez1, Rez2, OptFFT, Err : OleVariant);
begin
  RunWPOperator( '/Operators/Передаточная функция', Src1, Src2, Rez1, Rez2, OptFFT, Err );
end;

procedure RunIIRFiltering(const Src : OleVariant; var Rez, Opt, Err : OleVariant);
begin
  RunWPOperator( '/Operators/Рекурсивная фильтрация', Src, Src, Rez, Rez, Opt, Err );
end;

procedure RunFIRFiltering(const Src : OleVariant; var Rez, Opt, Err : OleVariant);
begin
  RunWPOperator( '/Operators/Нерекурсивная фильтрация', Src, Src, Rez, Rez, Opt, Err );
end;

procedure RunDiff(const Src : OleVariant; var Rez, Method, Err : OleVariant);
var oper : IWPOperator;
begin
  oper:= WINPOS.GetObject('/Operators/Дифференцирование') as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.setproperty('Method', Method);
    oper.Exec(Src,Src,refvar(Rez),refvar(Rez));
  end
  else
    Err:= -1001;
end;

procedure RunPRV(const Src : OleVariant; var Rez, NumPoints, TpPrv, Err : OleVariant);
var oper : IWPOperator;
begin
  oper:= WINPOS.GetObject('/Operators/Плотность вероятности') as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.setproperty('NumPoints', NumPoints);
    oper.setproperty('TpPrv', TpPrv);
    oper.Exec(Src,Src,refvar(Rez),refvar(Rez));
  end
  else
    Err:= -1001;
end;

procedure RunAutoCorel(const Src : OleVariant; var Rez, NumPoints, Eps, Err : OleVariant);
var oper : IWPOperator;
begin
  oper:= WINPOS.GetObject('/Operators/Функция автокорреляции') as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.setProperty('NumPoints', NumPoints);
    oper.setProperty('Eps', Eps);
    oper.Exec(Src,Src,refvar(Rez),refvar(Rez));
  end
  else
    Err:= -1001;
end;

procedure RunCrossCorel(const Src1, Src2 : OleVariant; var Rez, NumPoints, Eps, Err : OleVariant);
var oper : IWPOperator;
begin
  oper:= WINPOS.GetObject('/Operators/Функция взаимной корреляции') as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.setProperty('NumPoints', NumPoints);
    oper.setProperty('Eps', Eps);
    oper.Exec(Src1,Src2,refvar(Rez),refvar(Rez));
  end
  else
    Err:= -1001;
end;

procedure RunOgib(const Src : OleVariant; var Rez, NumPoints, Err : OleVariant);
var oper : IWPOperator;
begin
  oper:= WINPOS.GetObject('/Operators/Огибающая методом пик-детектора') as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.setProperty('NumPoints', NumPoints);
    oper.Exec(Src,Src,refvar(Rez),refvar(Rez));
  end
  else
    Err:= -1001;
end;

procedure RunIntegral(const Src : OleVariant; var Rez, Method, NPoint, TypeRezult, Err : OleVariant);
var oper : IWPOperator;
begin
  oper:= WINPOS.GetObject('/Operators/Интегрирование(Первообразная)') as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.setProperty('Method', Method);
    oper.setProperty('NPoint', NPoint);
    oper.setProperty('TypeRezult', TypeRezult);
    oper.Exec(Src,Src,refvar(Rez),refvar(Rez));
  end
  else
    Err:= -1001;
end;

procedure RunResampling(const Src : OleVariant; var Rez : OleVariant; Freq, Method, FltType : OleVariant; var Err : OleVariant);
var oper : IWPOperator;
begin
  oper:= WINPOS.GetObject('/Operators/Передискретизация') as IWPOperator;
  if (Assigned(oper)) then
  begin
    oper.setProperty('kind', Method);
    oper.setProperty('type', FltType);
    oper.setProperty('freq', Freq);
    oper.Exec(Src,Src,refvar(Rez),refvar(Rez));
  end
  else
    Err:= -1001;
end;

procedure Signal2Graph(const signal: IWPSignal);
var api    : IWPGraphs;
var hPage, hGraph, hYAxis : Integer;
begin
  api:= WINPOS.GraphAPI as IWPGraphs;      // получаем доступ к графической подсистеме Winpos
  hPage:= api.CreatePage;           // создаем новую страницу для графиков
  hGraph:= api.GetGraph(hPage,0);   // страница всегда создается с одной областью для рисования, поэтому возьмем ее
  hYAxis:= api.GetYAxis(hGraph,0);  // получаем ось Y
  api.CreateLine(hGraph, hYAxis, signal.Instance); // создаем  новую линию в графике
  api.NormalizeGraph(hGraph);       // нормализуем график
end;

begin
  WP:= TWinPOS.Create(nil);
end.
