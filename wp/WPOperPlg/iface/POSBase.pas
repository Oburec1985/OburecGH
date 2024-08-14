//**************************************************
// WinПОС: Библиотека вызова стандартных алгоритмов
// Совместимость: WinПОС professional, WinПОС expert
// Изменения: 20.10.03
//**************************************************
unit POSBase;

interface

uses Winpos_ole_TLB;

procedure RunWPOperator(const OpName : String; const Src1, Src2 : OleVariant; var Rez1, Rez2, Opt, Err : OleVariant);
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

function refvar(var v : Olevariant) : OleVariant;

var WP : TWinPOS;
var WINPOS : IWinPOS;

// Константы для задания типа данных сигнала (VarType)
const VT_I1	  : Integer = 16;
const VT_UI1  : Integer = 17;
const VT_I2   : Integer = 2;
const VT_UI2  : Integer = 18;
const VT_I4   : Integer = 3;
const VT_R4   : Integer = 4;
const VT_R8   : Integer = 5;

// Константы для задания свойств страницы
const PGOPT_SHOWNAME	: Integer = $0001;	// Отображение названия страницы
const PGOPT_SINGLEX		: Integer = $0002;	// Флаг одной оси X на страницу
const PGOPT_SINGLEY		: Integer = $0004;	// Флаг одной оси Y на страницу
const PGOPT_SYNCCURS	: Integer = $0008;	// Синхронизация курсоров

// Константы для задания свойств графика
const GROPT_SHOWNAME	: Integer = $0001; // Флаг отрисовки названия
const GROPT_YINDENT		: Integer = $0002; // 10% отступ для линий сверху и снизу
const GROPT_SUBGRID		: Integer = $0004; // Флаг отрисовки пунктирных линий на сетке
const GROPT_GRIDLABS	: Integer = $0008; // Значения линий в узлах сетки
const GROPT_LINENUMS	: Integer = $0010; // Показывать номера линий
const GROPT_AUTONORM	: Integer = $0020; // Автоматически нормализововать график при добавлении новых линий
const GROPT_POLAR			: Integer = $0040; // Полярные координаты
const GROPT_AXCOLUMN	: Integer = $0080; // Флаг размещения осей Y друг над другом
const GROPT_AXROW			: Integer = $0100; // Флаг размещения осей Y друг за другом

// Константы для задания свойств линии
const LNOPT_LINE2BASE		: Integer = $0001;	// Флаг рисования линий от точек на базу
const LNOPT_ONLYPOINTS	: Integer = $0002;  // Флаг соединения точек линиями
const LNOPT_VISIBLE			: Integer = $0004;  // Флаг отображения линии
const LNOPT_HIST				: Integer = $0008;  // В виде гистограммы
const LNOPT_COLOR				: Integer = $0010;  // цвет
const LNOPT_WIDTH				: Integer = $0020;  // Ширина линии
const LNOPT_HISTTRANSP	: Integer = $0040;	// "прозрачная" гистограмма
const LNOPT_PARAM				: Integer = $0080;	// В виде Y(idx), с реальными значениями на шкале оси X
const LNOPT_INTERP			: Integer = $0300;	// Порядок интерполяции (два бита!)

// Константы для задания свойств оси
const AXOPT_LOG			        : Integer = $0001;	// Log-масштаб
const AXOPT_FZERO			: Integer = $0002;	// сохраняются ли нули в конце числа ("1.300" а не "1.3")
const AXOPT_TIME			: Integer = $0004;	// Вторая оцифровка вкл/выкл (Для оси Х)
const AXOPT_RANGE			: Integer = $0010;	// Установить полный диапазон
const AXOPT_NAME			: Integer = $0020;	// Установить имя или размерность оси
const AXOPT_FORMAT		        : Integer = $0040;	// Установить формат оцифровки в виде "%.3f"

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
const FT_MERA 	  : Byte	= 0;
const FT_USML 	  : Byte	= 1;
const FT_TextWiz  : Byte	= 2;
const FT_UChar 	  : Byte	= 3;
const FT_INT16 	  : Byte	= 4;
const FT_WORD 	  : Byte	= 5;
const FT_INT32 	  : Byte	= 6;
const FT_Float 	  : Byte	= 7;
const FT_Double   : Byte	= 8;
const FT_XLS   		: Byte	= 9;
const FT_EDI 	    : Byte	= 10;

// Константы характеристик
const SC_NORMAL   : Integer = 0;
const SC_SPECTR   : Integer = 1;
const SC_OKTAV  	: Integer = 2;
const SC_LOGY     : Integer = 4;
const SC_LOGX     : Integer = 8;
const SC_RESERVED1 : Integer = $010;
const SC_FASE 		: Integer = $020;
const SC_RMS 			: Integer = $040; 
const SC_AMP 			: Integer = $060; 
const SC_2AMP 		: Integer = $080; 
const SC_VAL_MASK : Integer = $0E0;
const SC_SEMIPAR 	: Integer = $100; 
const SC_PARAM 		: Integer = $200; 
const SC_POLAR 		: Integer = $300; 
const SC_PAR_MASK : Integer = $300;

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
const Oktav12     : Integer = 12;
const Oktav24     : Integer = 13;
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
  oper:= WP.GetObject(OpName) as IWPOperator;
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
  RunWPOperator( '/Operators/Взаимный спектр', Src1, Src2, Rez1, Rez2, OptFFT, Err );
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
  oper:= WP.GetObject('/Operators/Дифференцирование') as IWPOperator;
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
  oper:= WP.GetObject('/Operators/Плотность вероятности') as IWPOperator;
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
  oper:= WP.GetObject('/Operators/Функция автокорреляции') as IWPOperator;
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
  oper:= WP.GetObject('/Operators/Функция взаимной корреляции') as IWPOperator;
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
  oper:= WP.GetObject('/Operators/Огибающая методом пик-детектора') as IWPOperator;
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
  oper:= WP.GetObject('/Operators/Интегрирование (Первообразная)') as IWPOperator;
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
  oper:= WP.GetObject('/Operators/Передискретизация') as IWPOperator;
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
  api:= WP.GraphAPI as IWPGraphs;      // получаем доступ к графической подсистеме Winpos
  hPage:= api.CreatePage;           // создаем новую страницу для графиков
  hGraph:= api.GetGraph(hPage,0);   // страница всегда создается с одной областью для рисования, поэтому возьмем ее
  hYAxis:= api.GetYAxis(hGraph,0);  // получаем ось Y
  api.CreateLine(hGraph, hYAxis, signal.Instance); // создаем  новую линию в графике
  api.NormalizeGraph(hGraph);       // нормализуем график
end;

begin
  WINPOS:= nil;
  WP:= TWinPOS.Create(nil);
end.
