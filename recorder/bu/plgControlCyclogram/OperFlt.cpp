// OperFlt.cpp: implementation of the OperIIRFilter class.
//
//////////////////////////////////////////////////////////////////////
#include "stdafx.h"
#include <math.h>
#include <malloc.h>                    
#include <memory.h>  
#include<string>
using namespace std;

#include "..\resource.h"
#include "OperFlt.h"
#include "operators.h"
#include "WinPosTypes.h"
#include "ProtectInst.h"

#include "ISignal.h"
using namespace Signals;

extern HINSTANCE hInst;


/////////////////////////
// Функции класса COptionsIIRFilter
/////////////////////////

COleVariant COptionsIIRFilter::GetProperty(LPCTSTR name)
{
	if (!lstrcmp(name, "flag"))    return (COleVariant)(double) flag;
	if (!lstrcmp(name, "nRipple")) return (COleVariant)(double) nRipple;
	if (!lstrcmp(name, "nOrder"))  return (COleVariant)(double) nOrder;
	if (!lstrcmp(name, "iType"))   return (COleVariant)(double) iType;
	if (!lstrcmp(name, "iKind"))   return (COleVariant)(double) iKind;
	if (!lstrcmp(name, "fsr"))     return (COleVariant)         fsr;
	if (!lstrcmp(name, "fn"))      return (COleVariant)         fn;
	if (!lstrcmp(name, "fv"))      return (COleVariant)         fv;
	if (!lstrcmp(name, "fs"))      return (COleVariant)         fs;
	if (!lstrcmp(name, "HO"))      return (COleVariant)         HO;
	if (!lstrcmp(name, "fn_c"))    return (COleVariant)         fn_c;
	if (!lstrcmp(name, "fv_c"))    return (COleVariant)         fv_c;
	if (!lstrcmp(name, "3dB"))     return (COleVariant)(double) b3dB;

	return double(0);
}

void COptionsIIRFilter::SetProperty(LPCTSTR name, COleVariant val)
{
	if (!lstrcmp(name, "flag"))    flag    = prop2int(val);
	if (!lstrcmp(name, "nRipple")) nRipple = prop2int(val);
	if (!lstrcmp(name, "nOrder"))  nOrder  = prop2int(val);
	if (!lstrcmp(name, "iType"))   iType   = prop2int(val);
	if (!lstrcmp(name, "iKind"))   iKind   = prop2int(val);
	if (!lstrcmp(name, "fsr"))     fsr     =       val.dblVal;
	if (!lstrcmp(name, "fn"))      fn      =       val.dblVal;
	if (!lstrcmp(name, "fv"))      fv      =       val.dblVal;
	if (!lstrcmp(name, "fs"))      fs      =       val.dblVal;
	if (!lstrcmp(name, "HO"))      HO      =       val.dblVal;
	if (!lstrcmp(name, "fn_c"))    fn_c    =       val.dblVal;
	if (!lstrcmp(name, "fv_c"))    fv_c    =       val.dblVal;
	if (!lstrcmp(name, "3dB"))     b3dB    = (prop2int(val) != 0);
}

LPCTSTR COptionsIIRFilter::GetPropertySet()
{
	return "flag,nRipple,nOrder,iType,iKind,fsr,fn,fv,fs,HO,fn_c,fv_c,3dB";
};


/////////////////////////
// Функции операторов
/////////////////////////

COperIIRFilter::COperIIRFilter()
{
  m_OptionsIIRFilter=cOptIIRFilterDef;
}

COperIIRFilter::~COperIIRFilter()
{
}

string COperIIRFilter::Name()
{
  return "IIRFilter"; 
}

string COperIIRFilter::FullName()
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());

  return (LPCTSTR)CString((LPCTSTR)IDS_ALGNAME_IIRFILTER);
}

void COperIIRFilter::Info(int kindInfo, string& s)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());

	switch (kindInfo)
	{
		case 0:
		{
			CString str;
			s = FullName() + " / ";
			// s += (LPCTSTR)CString((LPCTSTR)IDS_ALGINFO_FLT_TYPE0);
			switch (m_OptionsIIRFilter.iType)
			{
				case 1: s += (LPCTSTR)CString((LPCTSTR)IDS_ALGINFO_FLT_TYPE1); break; // Баттерворт
				case 2: s += (LPCTSTR)CString((LPCTSTR)IDS_ALGINFO_FLT_TYPE2); break; // Чебышев
				case 3: s += (LPCTSTR)CString((LPCTSTR)IDS_ALGINFO_FLT_TYPE3); break; // Эллиптический
			}
			s += ", "; //s += (LPCTSTR)CString((LPCTSTR)IDS_ALGINFO_FLT_KIND0);
			switch (m_OptionsIIRFilter.iKind)
			{
				case 1: s += (LPCTSTR)CString((LPCTSTR)IDS_ALGINFO_FLT_KIND1); break; // ФНЧ
				case 2: s += (LPCTSTR)CString((LPCTSTR)IDS_ALGINFO_FLT_KIND2); break; // Полосовой
				case 3: s += (LPCTSTR)CString((LPCTSTR)IDS_ALGINFO_FLT_KIND3); break; // ФВЧ
			}
			s += ", "; s += (LPCTSTR)CString((LPCTSTR)IDS_ALGINFO_FLT_ORDER);
			str.Format("%d", m_OptionsIIRFilter.nOrder); s += (LPCTSTR)str;
			s += ", "; s += (LPCTSTR)CString((LPCTSTR)IDS_ALGINFO_FLT_FS);
			if (m_OptionsIIRFilter.iKind != 2)
				str.Format("%.6f", m_OptionsIIRFilter.fsr);
			else
				str.Format("%.6f/%.6f", m_OptionsIIRFilter.fn, m_OptionsIIRFilter.fv);
			s += (LPCTSTR)str;
			break;
		}
		case 1:
			s=Name();
			break;
		case 2: 
			s="pro";
			break;
	}; 
}

void COperIIRFilter::GetVarInfo(int* nSrc, int* nDest)  
{
   *nSrc=1; *nDest=1;
}

string COperIIRFilter::GetMsgError(int iError)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());

	CString str;
	switch ((iError!=0)?iError:m_iError)
	{
		case ERR_NOERR:     str.LoadString(IDS_ALGSTR_NOERR);     break;
		case ERR_INVFUNC:   str.LoadString(IDS_ALGSTR_INVFUNC);   break;
		case ERR_NOSIG:     str.LoadString(IDS_ALGSTR_NOSIG);     break;
		case ERR_NOMEM:	    str.LoadString(IDS_ALGSTR_NOMEM); break;
		case ERR_INVFLTPAR: str.LoadString(IDS_ALGSTR_INVFLTPAR); break;
		case ERR_FLOATX:    str.LoadString(IDS_ALGSTR_FLOATX);    break;
		case ERR_LOFREQ_GT_HIFREQ: str.LoadString(IDS_LOFREQ_GT_HIFREQ); break;
		case ERR_CANCEL:    str.LoadString(IDS_ALGSTR_CANCEL); break;
		default:            str.LoadString(IDS_ALGSTR_CALC);
	}

	return string(str, lstrlen(str));
}

BOOL COperIIRFilter::Valid(PSignal pSrc, PSignal pSrc1, PSignal* pDest, PSignal* pDest1, BOOL bSaveDest)
{
	if ((m_OptionsIIRFilter.iKind==2)&&
			(m_OptionsIIRFilter.fn>m_OptionsIIRFilter.fv))
			{ m_iError=ERR_LOFREQ_GT_HIFREQ; return false; }
	m_iError=ValidOptionsIIRFilter(m_OptionsIIRFilter);
	if (m_iError!=0) { m_iError = ERR_INVFLTPAR; return false; }
	if ((pSrc==0) || (pDest==0)) { m_iError=ERR_NOSIG; return false; }
	if (pSrc->IsVarStep())       { m_iError=ERR_FLOATX; return false; }

	// Оцениваем требуемое пространство на диске, если оно действительно требуется
	if (bSaveDest)
	{
		__int64 SpaceReq = pSrc->GetSize() * VTsizeof( GetDstItemTypeSmart( pSrc ) );
		if (!CheckDiskSpace( SpaceReq ))
			{ m_iError = ERR_NOMEM; return false; }
	}

	m_iError=0;
	return true;
}

int COperIIRFilter::Exec(PSignal pSrc, PSignal pSrc1, PSignal* pDest,PSignal*  pDest1, BOOL bSaveDest)
{
	AFX_MANAGE_STATE(AfxGetStaticModuleState());
	if (!ValidCall()) return ERR_INVALIDCALL;

	COptionsIIRFilter optionsBAK( m_OptionsIIRFilter );

	__int64 indexBeg,numPoints;
	double tBeg,dX;
	m_iError=0; 
	try
	{
		indexBeg=0;
		numPoints=pSrc->GetSize();
		dX=pSrc->GetDeltaX();
		tBeg=pSrc->GetStartX();

		*pDest = 0;
		BOOL isUseTransf = TRUE;
		CreateInstanceSmart(pSrc, pDest, isUseTransf, bSaveDest);

		(*pDest)->SetStartX(tBeg);
		(*pDest)->SetDeltaX(dX);
		(*pDest)->Resize(numPoints);
		double dbltime, dbltcor;
		pSrc->GetStartTime(&dbltime, &dbltcor); (*pDest)->SetStartTime(dbltime, dbltcor);

		if ((1/dX)!=m_OptionsIIRFilter.fs) { ResetKf(); m_OptionsIIRFilter.fs=1/dX; }
		RunKf();

		if (isUseTransf)
			_FiltringVect<PSignal,AccessSignal>(pSrc, *pDest, m_OptionsIIRFilter.nOrder,numPoints,
											indexBeg,m_OptionsIIRFilter.HO,
											m_OptionsIIRFilter.aA0,m_OptionsIIRFilter.aA1,m_OptionsIIRFilter.aA2, 
											m_OptionsIIRFilter.aB0,m_OptionsIIRFilter.aB1,m_OptionsIIRFilter.aB2,
											m_OptionsIIRFilter.Y,0,m_pNotifyFunc);
		else
			_FiltringVect<PSignal,AccessSignalDir>(pSrc, *pDest, m_OptionsIIRFilter.nOrder,numPoints,
											indexBeg,m_OptionsIIRFilter.HO,
											m_OptionsIIRFilter.aA0,m_OptionsIIRFilter.aA1,m_OptionsIIRFilter.aA2, 
											m_OptionsIIRFilter.aB0,m_OptionsIIRFilter.aB1,m_OptionsIIRFilter.aB2,
											m_OptionsIIRFilter.Y,0,m_pNotifyFunc);

		(*pDest)->SetNameX(pSrc->GetNameX());
		(*pDest)->SetNameY(pSrc->GetNameY() );
		(*pDest)->SetCharacteristic(ISignal::SC_NORMAL);

	}
	catch(int err)
	{
	   err=err;
		m_iError = ERR_CANCEL;
		if (*pDest) delete (*pDest);
	}
	catch(...)
	{
		m_iError = ERR_EXEC;
		if (*pDest) delete (*pDest);
	}

	m_OptionsIIRFilter = optionsBAK;

	return m_iError;
}

COperOptions* COperIIRFilter::GetOptions()
{
	return &m_OptionsIIRFilter;
}

void COperIIRFilter::SetOptions(COperOptions* Options)
{
	COptionsIIRFilter* pOptionsIIRFilter = dynamic_cast<COptionsIIRFilter*>(Options);
	if (pOptionsIIRFilter)
		m_OptionsIIRFilter= *pOptionsIIRFilter ;
    ResetKf();
}

void COperIIRFilter::RunKf()
{
	if (m_OptionsIIRFilter.flag == 0) {
		double fn = (m_OptionsIIRFilter.b3dB) ? m_OptionsIIRFilter.fn_c : m_OptionsIIRFilter.fn;
		double fv = (m_OptionsIIRFilter.b3dB) ? m_OptionsIIRFilter.fv_c : m_OptionsIIRFilter.fv;
		double fsr = (m_OptionsIIRFilter.iKind == LowPass) ? fv : ((m_OptionsIIRFilter.iKind == HighPass) ? fn : m_OptionsIIRFilter.fsr);

		Run_KF( m_OptionsIIRFilter.fs, fsr, m_OptionsIIRFilter.nRipple, m_OptionsIIRFilter.iType, m_OptionsIIRFilter.iKind,
		       &m_OptionsIIRFilter.nOrder, &m_OptionsIIRFilter.HO, fn, fv, m_OptionsIIRFilter.aA0, m_OptionsIIRFilter.aA1, m_OptionsIIRFilter.aA2, 
		        m_OptionsIIRFilter.aB0, m_OptionsIIRFilter.aB1, m_OptionsIIRFilter.aB2);
		m_OptionsIIRFilter.flag = 1;
	}
}

void COperIIRFilter::RunAFX(double* mag, double* fase,
                            double* F_BEGIN, double* F_END, double* DeltaF,
                            int KT, int ScaleMag)
{
	COptionsIIRFilter optionsBAK( m_OptionsIIRFilter );

	double fn = (m_OptionsIIRFilter.b3dB) ? m_OptionsIIRFilter.fn_c : m_OptionsIIRFilter.fn;
	double fv = (m_OptionsIIRFilter.b3dB) ? m_OptionsIIRFilter.fv_c : m_OptionsIIRFilter.fv;
	double fsr = (m_OptionsIIRFilter.iKind == LowPass) ? fv : ((m_OptionsIIRFilter.iKind == HighPass) ? fn : m_OptionsIIRFilter.fsr);

	RunKf(); 
	Run_AFX(m_OptionsIIRFilter.fs, fsr, fn, fv, m_OptionsIIRFilter.nOrder, m_OptionsIIRFilter.iKind,
	        m_OptionsIIRFilter.aA0, m_OptionsIIRFilter.aA1, m_OptionsIIRFilter.aA2, 
	        m_OptionsIIRFilter.aB0, m_OptionsIIRFilter.aB1, m_OptionsIIRFilter.aB2,
	        m_OptionsIIRFilter.HO, mag, fase, F_BEGIN, F_END, DeltaF, KT, ScaleMag);

	m_OptionsIIRFilter = optionsBAK;
}

void COperIIRFilter::ResetKf()
{
	m_OptionsIIRFilter.flag = 0; 
};

// Пересчитывает частоты среза так, чтобы они приходились на уровень -3 дБ
void COperIIRFilter::RecalcCutFreqs()
{
	const double DB3 = -3.0;
	const double e = 0.01;

	// Для удобства запоминаем заданные частоты среза в локальные переменные
	double fn_orig = ((m_OptionsIIRFilter.iKind == LowPass) || (m_OptionsIIRFilter.iKind == HighPass)) ? m_OptionsIIRFilter.fsr : m_OptionsIIRFilter.fn;
	double fv_orig = ((m_OptionsIIRFilter.iKind == LowPass) || (m_OptionsIIRFilter.iKind == HighPass)) ? m_OptionsIIRFilter.fsr : m_OptionsIIRFilter.fv;

	// Для типа аппроксимации "Баттерворт", частота среза уже приходится на -3 дБ, ничего делать не требуется
	if (m_OptionsIIRFilter.iType == Butterworth) {
		m_OptionsIIRFilter.fn_c = fn_orig;
		m_OptionsIIRFilter.fv_c = fv_orig;
		m_OptionsIIRFilter.fsr = fn_orig;
		return;
	}

	int iKind = m_OptionsIIRFilter.iKind; // для удобства
	int nOrder = m_OptionsIIRFilter.nOrder;
	double HO = m_OptionsIIRFilter.HO; // Не понятно, где инициализируется, при расчете коэф. может изменяться
	double fsr = ((iKind == LowPass) || (iKind == HighPass)) ? fn_orig : 0;
	double fn = fn_orig;
	double fv = fv_orig;
	BOOL bOk = FALSE;
	BOOL bErr_fn = FALSE, bErr_fv = FALSE;

	int bufSize = 1000;
	double F_BEGIN = 0, F_END = 0, DeltaF = 0;
	double* mag = new double[bufSize * 2];
	double* fase = new double[bufSize * 2];

	for (int c = 10; (c > 0) && !bOk; c--) {
		bOk = TRUE;

		m_OptionsIIRFilter.nOrder = nOrder; // В Run_KF для полосового фильтра nOrder умножается на 2
		m_OptionsIIRFilter.HO = HO;
		Run_KF(m_OptionsIIRFilter.fs, fsr, m_OptionsIIRFilter.nRipple,
		       m_OptionsIIRFilter.iType, m_OptionsIIRFilter.iKind, &m_OptionsIIRFilter.nOrder,
		       &m_OptionsIIRFilter.HO, fn, fv, 
		       m_OptionsIIRFilter.aA0, m_OptionsIIRFilter.aA1, m_OptionsIIRFilter.aA2, 
		       m_OptionsIIRFilter.aB0, m_OptionsIIRFilter.aB1, m_OptionsIIRFilter.aB2);

		Run_AFX(m_OptionsIIRFilter.fs, fsr, fn, fv, 
		        m_OptionsIIRFilter.nOrder, m_OptionsIIRFilter.iKind,
		        m_OptionsIIRFilter.aA0, m_OptionsIIRFilter.aA1, m_OptionsIIRFilter.aA2, 
		        m_OptionsIIRFilter.aB0, m_OptionsIIRFilter.aB1, m_OptionsIIRFilter.aB2,
		        m_OptionsIIRFilter.HO,
		        mag, fase, &F_BEGIN, &F_END, &DeltaF, bufSize, 1);

		if ((iKind == HighPass) || (iKind == BandPass)) {
			double val = GetMagByFreq(fn, mag, bufSize, F_BEGIN, DeltaF);
			if (fabs(val - DB3) > e) {
				int dir = (val > DB3) ? -1 : 1;
				double fn_db3 = GetFreqByMag(fn, DB3, mag, bufSize, F_BEGIN, DeltaF, dir);
				if (fn_db3 >= 0) {
					fn = fn + (fn_orig - fn_db3);
					if (iKind == HighPass)
						fsr = fn;
					bOk = FALSE;
				} else
					bErr_fn = TRUE;
			}
		}

		if ((iKind == LowPass) || (iKind == BandPass)) {
			double val = GetMagByFreq(fv, mag, bufSize, F_BEGIN, DeltaF);
			if (fabs(val - DB3) > e) {
				int dir = (val > DB3) ? 1 : -1; // Для заднего фронта наоборот
				double fv_db3 = GetFreqByMag(fv, DB3, mag, bufSize, F_BEGIN, DeltaF, dir);
				if (fv_db3 >= 0) {
					fv = fv + (fv_orig - fv_db3);
					if (iKind == LowPass)
						fsr = fv;
					bOk = FALSE;
				} else
					bErr_fv = TRUE;
			}
		}
	}

	delete mag;
	delete fase;

	m_OptionsIIRFilter.nOrder = nOrder;
	m_OptionsIIRFilter.HO = HO;
	m_OptionsIIRFilter.fn_c = (!bErr_fn) ? fn : fn_orig;
	m_OptionsIIRFilter.fv_c = (!bErr_fv) ? fv : fv_orig;
}

// Возвращает значение на АЧХ фильтра, соотв. заданной частоте (линейная интерполяция)
double COperIIRFilter::GetMagByFreq(double freq, double* mag, int size, double f0, double df)
{
	if (!mag || (size < 2) || (df <= 0))
		return 0;

	int idx = int((freq - f0) / df);
	return ((idx >= 0) && (idx < size-1)) ? mag[idx] + (mag[idx] - mag[idx+1]) / (-df) * (freq - (f0 + df * double(idx))) : ((idx < 0) ? mag[0] : mag[size-1]);
}

// Возвращает частоту, соотв. заданному значению на АЧХ фильтра, от частоты f0 в направлении dir (линейная интерполяция)
double COperIIRFilter::GetFreqByMag(double f_beg, double amp, double* mag, int size, double f0, double df, int dir)
{
	if (!mag || (size < 2) || (df <= 0))
		return 0;

	int idx = max(0, min(size-1, int((f_beg - f0) / df) + ((dir < 0) ? 1 : 0)));
	int end = (dir < 0) ? 0 : size-1;
	if (idx == end)
		return f0 + df * double(idx);

	BOOL bDown = (mag[idx] >= amp);
	double freq = -1;
	for (int i = idx, di = (dir < 0) ? -1 : 1; (i != end); i += di) {
		if ((bDown && (mag[i] >= amp) && (mag[i+di] <= amp)) || (!bDown && (mag[i] <= amp) && (mag[i+di] >= amp))) {
			freq = (f0 + df * double(i)) + (-df)*double(di) / (mag[i] - mag[i+di]) * (amp - mag[i]);
			break;
		}
	}

	return freq;
}


//---- direct API Filter functions from OperFlt.cpp --------------------------------

OPER_API_DLL void __stdcall SetOptionsIIRFilter(HANDLE hOpt,
  							double fs,   // частота опроса
							double fsr,  // частота среза ДЛЯ ФНЧ,ФВЧ
							int nRipple, // ПРОЦЕНТ В ПОЛОСЕ ПРОПУСКАНИЯ  1..5
							int iType,   // Тип аппроксимации  : 1--БАТ,2--ЧЕБ,3--ЭЛЛИПТ
							int iKind,   // Тип фильтра        : 1--ФНЧ,2--ПОЛС,3--ФВЧ  
                            int nOrder,  // КОЛ-ВО  ДВУХПОЛЮСНИКОВ (порядок)
                            double fn, double fv) // частота среза нижняя ДЛЯ ПОЛС.
{
  COptionsIIRFilter* options = (COptionsIIRFilter*) hOpt;

  options->flag=0;
  options->nRipple=nRipple; // ПРОЦЕНТ В ПОЛОСЕ ПРОПУСКАНИЯ  1..5
  options->nOrder=nOrder;   // КОЛ-ВО  ДВУХПОЛЮСНИКОВ (порядок)
  options->iType=iType;   // Тип аппроксимации  : 1--БАТ,2--ЧЕБ,3--ЭЛЛИПТ
  options->iKind=iKind;   // Тип фильтра        : 1--ФНЧ,2--ПОЛС,3--ФВЧ  
  options->fsr=fsr;   // частота среза ДЛЯ ФНЧ,ФВЧ
  options->fn=fn;    // частота среза нижняя ДЛЯ ПОЛС.
  options->fv=fv;    // частота среза верхняя ДЛЯ ПОЛС.
  options->fs=fs;    // частота опроса
};

//  расчет  коэф-ов двухполюсников рекурсивного фильтра
// AP    int  nRipple; // ПРОЦЕНТ В ПОЛОСЕ ПРОПУСКАНИЯ  1..5
// KP    int  nOrder;  // КОЛ-ВО  ДВУХПОЛЮСНИКОВ (порядок)
// TIP   int  iType;   // Тип аппроксимации  : 1--БАТ,2--ЧЕБ,3--ЭЛЛИПТ
// VID   int  iKind;   // Тип фильтра        : 1--ФНЧ,2--ПОЛС,3--ФВЧ  

OPER_API_DLL void __stdcall Run_KFOpt(HANDLE hOpt)
{
  COptionsIIRFilter* options = (COptionsIIRFilter*) hOpt;
  Run_KF(options->fs,options->fsr,options->nRipple,options->iType,options->iKind,
	     &options->nOrder,&options->HO,options->fn,options->fv, 
         options->aA0,options->aA1,options->aA2,options->aB0,options->aB1,options->aB2);
  options->flag=1;
};

OPER_API_DLL void __stdcall Run_KF(double fs, double fsr, int nRipple, int iType, int iKind,
                                   int* nOrder,
                                   double* HO, double fn, double fv, 
                                   ArrayKf& A0, ArrayKf& A1, ArrayKf& A2, 
                                   ArrayKf& B0, ArrayKf& B1, ArrayKf& B2)
{
  double HOO,Q,UKO,KO,L,A,X,ARSH,X1,SH,CH,SS;
  int i;
  double S11,NP1,NP2,S9;
  ArrayKf RN,IMN,R,IM,A01,A11,A21,B01,B11,B21,A02,A12,A22,B02,B12,B22;

  S11=1.;
  X=6.5526;  HOO=0.988553;
  switch (nRipple) {
   case 1: X=6.5526;  HOO=0.988553; break;
   case 2: X=4.6063;  HOO=0.977237; break;
   case 3: X=3.73926; HOO=0.966051; break;
   case 4: X=3.219448;HOO=0.954893; break;
   case 5: X=2.86278; HOO=0.944061; break;
  } 
  A=2*fs;
//  *HO=1.0;
  if ((*nOrder)>(MaxOrderFilter/2)) *nOrder=MaxOrderFilter/2;
  switch (iType) {
   case 1: for (i=1; i<=*nOrder; i++) {
             R[i]=-cos((2*i-1)*M_PI/(4*(*nOrder))+M_PI/2);
             IM[i]=sin((2*i-1)*M_PI/(4*(*nOrder))+M_PI/2);
           }; 
           break;
   case 2: ARSH=log(X+sqrt(pow(X,2)+1));
           X1=ARSH/(2**nOrder);
           SH=(exp(X1)-exp(-X1))/2.;
           CH=(exp(X1)+exp(-X1))/2.;
           for (i=1; i<=*nOrder; i++) {
              R[i]=SH*sin((2*i-1)*M_PI/(*nOrder*4));
              IM[i]=CH*cos((2*i-1)*M_PI/(*nOrder*4));
              SS=pow(R[i],2)+pow(IM[i],2);
              *HO=*HO*SS;
           };
           *HO=*HO*HOO;
           break;
   case 3: R[1]=0.104449;  IM[1]=1.05562;
           R[2]=0.326637;  IM[2]=0.80018;
           R[3]=0.536016;  IM[3]=0.29037;
           *HO=1/110.324;
           RN[1]=0.;         RN[2]=0.;        RN[3]=0.;
           IMN[1]=2.06813;   IMN[2]=2.83849;  IMN[3]=0;
           break;
  }; // switch (iType)

  for (i=1; i<=*nOrder; i++) {
   A01[i]=1;   A11[i]=0.;     A21[i]=0.;
   B01[i]=pow(IM[i],2)+pow(R[i],2);   B11[i]=2*R[i];    B21[i]=1;
  };
  if (iType==3) 
    for (i=1; i<=2; i++) {
     A01[i]=pow(RN[i],2)+pow(IMN[i],2);
     A21[i]=1;   A11[i]=-2*RN[i];
    };
  switch  (iKind) {
   case 1: UKO=M_PI*fsr/fs;
           KO=sin(UKO)/cos(UKO);  L=S11/(2*fs*KO);
           for (i=1; i<=*nOrder; i++) {
              A02[i]=A01[i]/pow(L,2);    A12[i]=0.;        A22[i]=A21[i];
              B02[i]=B01[i]/pow(L,2);    B12[i]=B11[i]/L;  B22[i]=1;
           };
           break;
   case 2: NP1=fs/fv;    UKO=M_PI/NP1;
           KO=sin(UKO)/cos(UKO);
           L=S11/(2*fs*KO);
           S9=*HO;
           for (i=1; i<=*nOrder; i++) {
             A02[i]=A01[i]/pow(L,2);   A12[i]=0.;       A22[i]=A21[i];
             B02[i]=B01[i]/pow(L,2);   B12[i]=B11[i]/L; B22[i]=1;
           };
           NP2=fs/fn;  UKO=M_PI/NP2;
           KO=sin(UKO)/cos(UKO);
           L=2*fs*KO/S11;
           for (i=(*nOrder+1); i<=(*nOrder*2); i++) {
             *HO=*HO/B01[i-(*nOrder)];
             A02[i]=A21[i-(*nOrder)]*pow(L,2);
             A12[i]=0.0;
             A22[i]=A01[i-(*nOrder)];
             B02[i]=B21[i-(*nOrder)]*pow(L,2)/B01[i-(*nOrder)];
             B12[i]=B11[i-(*nOrder)]*L/B01[i-(*nOrder)];
             B22[i]=0.0;
           };
           *HO=*HO*S9;  
           *nOrder=*nOrder*2; //Интересная, хотя и математически понятная, строчка: без неё полосовой фильтр превращается в ФНЧ, с ней искажаются опции (поэтому у нас есть BAK для опций!)
           break;
   case 3: UKO=M_PI*fsr/fs;  KO=sin(UKO)/cos(UKO);
           L=KO*fs*2/S11;
           for (i=1; i<=*nOrder; i++) {
             *HO=*HO/B01[i];
             A02[i]=A21[i]*pow(L,2);
             A12[i]=0.;
             A22[i]=A01[i];
             B02[i]=B21[i]*pow(L,2)/B01[i];
             B12[i]=B11[i]*L/B01[i];
             B22[i]=1.;   
           };
           break;
  }; // switch  (iKind) 
  for (i=1; i<=*nOrder; i++) {
     Q=pow(A,2)+A*B12[i]+B02[i];
     A0[i]=(A02[i]-A12[i]*A+A22[i]*pow(A,2))/Q;
     A1[i]=2*(A02[i]-pow(A,2)*A22[i])/Q;
     A2[i]=(A02[i]+A12[i]*A+pow(A,2)*A22[i])/Q;
     B0[i]=(pow(A,2)+B02[i]-B12[i]*A)/Q;
     B1[i]=2*(B02[i]-pow(A,2))/Q;   
     B2[i]=1.;
  };
}; // end Run_KF

//------------------------------------------------------------------------------

// Важно: F_BEGIN, F_END д.б. = 0 для автоматических границ
OPER_API_DLL void __stdcall Run_AFX(double fs, double FSR, double FN, double FV, 
                                    int nOrder,int iKind,
                                    const ArrayKf& A0,const ArrayKf& A1,const ArrayKf& A2, 
                                    const ArrayKf& B0,const ArrayKf& B1,const ArrayKf& B2,
                                    double HO,
                                    double* mag, double* fase,
                                    double* F_BEGIN, double* F_END, double* DeltaF,
                                    int KT, int ScaleMag)
{
  ArrayKf HA,FA,FB,HB;
  double ARGN,ARGO,ARG,WW,CC2,CC4,SS2,SS4,SAM,SF;
  double SS,PFB,AMPLG,RA,IA,RB,IB,QS,IARA;
  int i,j,np;
  int    INP[100];
  double SSP[100];

  np=2;
  for (i=1; i<=nOrder; i++) { INP[i]=0;  SSP[i]=0.; }

	// SERG: Этот вариант придуман для задания границ (*F_BEGIN,*F_END) извне
	if ((*F_END>*F_BEGIN)&&(*F_END>0))
	{
		*DeltaF= (*F_END-*F_BEGIN)/(KT-1);
		ARGO=*DeltaF;
		ARGN=*F_BEGIN;
		ARG=ARGN-ARGO;
	}
	else
	{
	//-- расчет границ интервалов частот для АФЧХ --
		switch (iKind) {
		case 1:  ARGO=FSR/(KT/KF_AFX);      ARGN=0;  break;
		case 2:  ARGO=(2*FV-FN/KF_AFX)/(KT-1);  ARGN=FN/KF_AFX;  break;  // SERG: тут везде раньше было "/KT", "/(KT-1)" правильнее!
		case 3:  ARGN=FSR/KF_AFX;   ARGO=(FSR-FSR/2)/((KT-1)/KF_AFX);  break;
		};

		*DeltaF=ARGO;
		ARG=ARGN-ARGO;
		*F_BEGIN=ARGN;   // +ARGO
		*F_END=ARGN+(KT-1)*ARGO;
	}

  for (j=0; j<KT; j++) {
   ARG=ARGO+ARG;
   WW=2*M_PI*ARG;
   CC2=cos(2*M_PI*ARG/fs);
   CC4=cos(4*M_PI*ARG/fs);
   SS2=sin(2*M_PI*ARG/fs);
   SS4=sin(4*M_PI*ARG/fs);
   SAM=HO;   SF=0.;
   
   for (i=1; i<=nOrder; i++) {
     RA=A0[i]+A1[i]*CC2+A2[i]*CC4;
     IA=A1[i]*SS2+A2[i]*SS4;
     RB=B0[i]+B1[i]*CC2+B2[i]*CC4;
     IB=B1[i]*SS2+B2[i]*SS4;

     QS=pow(RB,2)+pow(IB,2);
     HA[i]=sqrt((pow(RA,2)+pow(IA,2))/(pow(RB,2)+pow(IB,2)));

     if (RA==0) IARA=1000;
       else IARA=IA/RA;

     if (ARG>(fs/4.0)) FA[i]=atan(IARA)+ M_PI;
       else   FA[i]=atan(IARA);

     if (RB==0)  PFB=atan(1000.0);
        else  PFB=atan(IB/RB);

     SS=fabs(PFB-SSP[i]);
     if (SS>2) INP[i]=INP[i]+1;
     FB[i]=M_PI*INP[i]+PFB;
     HB[i]=FA[i]-FB[i];
     SF=SF+HB[i];
     SSP[i]=PFB;
     SAM=SAM*HA[i];
   };
   mag[j]=SAM;
   if (mag[j]==0) AMPLG=-200;
      else AMPLG=20*log(mag[j])/log(10.0);
   if (ScaleMag==1) mag[j]=AMPLG;
   fase[j]=SF;
  };
}; // end Run_AFX 

// пр-ра рекурсивной фильтрации для векторов=float                      
OPER_API_DLL void __stdcall IIRFiltringOpt(PArrayFloat pSrc, PArrayFloat pDest, 
				  int NumPoints, int indexBeg,
				  COptionsIIRFilter& OptionsIIRFilter,
                  int FlagVxod,
				  PNotifyFunc pNotifyFunc)
{
 	if (!ValidCall()) return;

	_FiltringVect<PArrayFloat ,AccessArrayFloat>(pSrc, pDest, OptionsIIRFilter.nOrder,NumPoints,indexBeg,
                  OptionsIIRFilter.HO,
                  OptionsIIRFilter.aA0,OptionsIIRFilter.aA1,OptionsIIRFilter.aA2, 
                  OptionsIIRFilter.aB0,OptionsIIRFilter.aB1,OptionsIIRFilter.aB2,
                  OptionsIIRFilter.Y,FlagVxod,pNotifyFunc);
};

// пр-ра рекурсивной фильтрации для векторов=double                      
OPER_API_DLL void __stdcall IIRFiltringOptDbl(PArrayDouble pSrc, PArrayDouble pDest, 
				  int NumPoints, int indexBeg, COptionsIIRFilter& OptionsIIRFilter, int FlagVxod, PNotifyFunc pNotifyFunc)
{
 	if (!ValidCall()) return;

	_FiltringVect<PArrayDouble ,AccessArrayDouble>(pSrc, pDest, OptionsIIRFilter.nOrder,NumPoints,indexBeg,
                  OptionsIIRFilter.HO,
                  OptionsIIRFilter.aA0,OptionsIIRFilter.aA1,OptionsIIRFilter.aA2, 
                  OptionsIIRFilter.aB0,OptionsIIRFilter.aB1,OptionsIIRFilter.aB2,
                  OptionsIIRFilter.Y,FlagVxod,pNotifyFunc);
};

OPER_API_DLL void __stdcall IIRFiltring(PArrayFloat pSrc, PArrayFloat pDest, 
                                        int NumPoints, int indexBeg,
                                        HANDLE hOpt,
                                        int FlagVxod, PNotifyFunc pNotifyFunc)
{
	COptionsIIRFilter* options = reinterpret_cast<COptionsIIRFilter*> (hOpt);

	if (options)
		IIRFiltringOpt(pSrc, pDest, NumPoints, indexBeg, *options, FlagVxod, pNotifyFunc);
}

// пр-ра рекурсивной фильтрации для векторов=short int                      
void IIRFiltringInt16(PArray pSrc, PArray pDest, 
				  int NumPoints, int indexBeg,
				  COptionsIIRFilter& OptionsIIRFilter,
                  int FlagVxod,
				  PNotifyFunc pNotifyFunc)
{
 _FiltringVect<PArray ,AccessArrayShortInt>(pSrc, pDest, OptionsIIRFilter.nOrder,NumPoints,indexBeg,
            	  OptionsIIRFilter.HO,
                  OptionsIIRFilter.aA0,OptionsIIRFilter.aA1,OptionsIIRFilter.aA2, 
                  OptionsIIRFilter.aB0,OptionsIIRFilter.aB1,OptionsIIRFilter.aB2,
                  OptionsIIRFilter.Y,FlagVxod,pNotifyFunc);
};

OPER_API_DLL void __stdcall IIRFiltringInt16(PArray pSrc, PArray pDest, 
                                             int NumPoints, int indexBeg,
                                             HANDLE hOpt,
                                             int FlagVxod,
                                             PNotifyFunc pNotifyFunc)
{
 	if (!ValidCall()) return;

	COptionsIIRFilter* options = reinterpret_cast<COptionsIIRFilter*> (hOpt);

	if (options)
		IIRFiltringInt16(pSrc, pDest, NumPoints, indexBeg, *options, FlagVxod, pNotifyFunc);
}

//--------------------------------------------------------------------------
// прoверяет корректность заданных параметров фильтра 

int ValidOptionsIIRFilter(COptionsIIRFilter& OptionsIIRFilter)
{
   if ((OptionsIIRFilter.nRipple<1) || (OptionsIIRFilter.nRipple>5)) return 1;
   if ((OptionsIIRFilter.iType<1) || (OptionsIIRFilter.iType>3)) return 2;
   if ((OptionsIIRFilter.iKind<1) || (OptionsIIRFilter.iKind>3)) return 3;
   if ((OptionsIIRFilter.nOrder<1) || (OptionsIIRFilter.nOrder>MaxOrderFilter)) return 4;

   if (OptionsIIRFilter.iType==3) OptionsIIRFilter.nOrder=3;

   if ((OptionsIIRFilter.fs==0) || (OptionsIIRFilter.nOrder==0)) return 5;
   switch (OptionsIIRFilter.iKind) { 
     case 1 : 
     case 3	: if ((OptionsIIRFilter.fs<2*OptionsIIRFilter.fsr) /*|| 
				  (0.0001*OptionsIIRFilter.fs>OptionsIIRFilter.fsr)*/) return 6;
					break;
     case 2: if ((OptionsIIRFilter.fs<(2*OptionsIIRFilter.fn)) || 
				 (OptionsIIRFilter.fs<2*OptionsIIRFilter.fv)   ||
				 (OptionsIIRFilter.fv<OptionsIIRFilter.fn)     /*||
				 (0.0001*OptionsIIRFilter.fs>OptionsIIRFilter.fn)*/) return 7;
					break;
   };
   return 0;
}; // CorrectParamFilter 

OPER_API_DLL int __stdcall ValidOptionsIIRFilter(HANDLE hOpt)
{
	COptionsIIRFilter* options = reinterpret_cast<COptionsIIRFilter*> (hOpt);

	if (options)
		return ValidOptionsIIRFilter(*options);
	else
		return -1;
}

//------------------------- Filtring ----------------------------
// пр-ра рекурсивной фильтрации для векторов                      
// pSrc - вектор входных данных 
// pDest - вектор выходных ( отфильтрованных)  данных  
// KP       - кол-во звеньев второго порядка                      
// size_data_for_filtring - кол-во данных для фильтрации          
// HO,A0,A1,A2,B0,B1,B2 - к-ты звеньев второго порядка            
// FlagVxod=0 если это первая порция и в ней будет присутствовать 
//            переходной процесс                                  
//          1 вторая и более порция и переходной процесс исключен 
//            за счет учета информации с предыдущей порции        
//    которая передается в WorkMas                                
//----------------------------------------------------------------

template <class TypeSrc,class Access>
void _FiltringVect(TypeSrc pSrc, TypeSrc pDest, 
                   int nOrder , __int64 NumPoints, __int64 indexBeg,
                   double HO,
                   const ArrayKf& A0,const ArrayKf& A1,const ArrayKf& A2, 
                   const ArrayKf& B0,const ArrayKf& B1,const ArrayKf& B2,
                   TypeWorkMas& Y,int FlagVxod,
                   PNotifyFunc pNotifyFunc, Access* pAcc)
{
  __int64 i,j;
  double Xi2,Xi1,Xi0,Y02,Y01;
  double dpercent;

 // сохранение (для случая pSrc=pDest) информации для определения на следующем шаге Н.У. }
  Y02=Access::GetY(pSrc,NumPoints-2+indexBeg);
  Y01=Access::GetY(pSrc,NumPoints-1+indexBeg);
 // -- 
  Xi2=Access::GetY(pSrc,0+indexBeg);
  Xi1=Access::GetY(pSrc,1+indexBeg);

  if (FlagVxod==0) { // первый вход 
		for (i=1; i<=nOrder; i++) { for (j=0; j<=2; j++) Y[i][j]=0;}

		Y[1][2]=HO*(A2[1]*Xi2);
		Y[1][1]=-B1[1]*Y[1][2]+HO*(A1[1]*Xi2+A2[1]*Xi1);

		for (i=2; i<=nOrder; i++) {
				 Y[i][2]=A2[i]*Y[i-1][2];
				 Y[i][1]=-B1[i]*Y[i][2]+A1[i]*Y[i-1][2]+A2[i]*Y[i-1][1];
		};
		Access::PutY(pDest,0,(double)Y[nOrder][2]);
		Access::PutY(pDest,1,(double)Y[nOrder][1]);
  }
  else {  // FlagVxod=1 и переходной процесс исключен за счет учета информации с предыдущей порции        
    Y[0][0]=Xi2;
    for (i=0; i<2; i++) { 
      Y[1][0]=-B1[1]*Y[1][1]-B0[1]*Y[1][2]+HO*(A0[1]*Y[0][2]+A1[1]*Y[0][1]+A2[1]*Y[0][0]);
      Y[0][2]=Y[0][1];
      Y[0][1]=Y[0][0];
      for (j=2; j<=nOrder; j++) {
       Y[j][0]=-B1[j]*Y[j][1]-B0[j]*Y[j][2]+
                  A0[j]*Y[j-1][2]+A1[j]*Y[j-1][1]+A2[j]*Y[j-1][0];
       Y[j-1][2]=Y[j-1][1];
       Y[j-1][1]=Y[j-1][0];
      };
      Y[nOrder][2]=Y[nOrder][1];   Y[nOrder][1]=Y[nOrder][0];
	  Y[0][0]=Access::GetY(pSrc,i+1+indexBeg);
      Access::PutY(pDest,i,(double)Y[nOrder][0]);
	};
  };

  //-- основной цикл фильтрации --//
	__int64 ns = (NumPoints <= 50) ? 1 : __int64(double(NumPoints) / 20.0 + 0.5);
	for (i=2; i<NumPoints; i++)
	{ 
		Xi0=Access::GetY(pSrc,i+indexBeg);
		Y[1][0]=-B1[1]*Y[1][1]-B0[1]*Y[1][2]+HO*(A0[1]*Xi2+A1[1]*Xi1+A2[1]*Xi0);

		for (j=2; j<=nOrder; j++)
		{
			Y[j][0]=-B1[j]*Y[j][1]-B0[j]*Y[j][2]+
			A0[j]*Y[j-1][2]+A1[j]*Y[j-1][1]+A2[j]*Y[j-1][0];
			Y[j-1][2]=Y[j-1][1];
			Y[j-1][1]=Y[j-1][0];
		};
   // shift back //
	Y[nOrder][2]=Y[nOrder][1];   Y[nOrder][1]=Y[nOrder][0];
	Xi2=Xi1;  Xi1=Xi0;

	Access::PutY(pDest,i,(double)Y[nOrder][0]);

  //    посылка сообщения наверх о том сколько мы сделали 
		if ((!(i % ns)) && (pNotifyFunc))
		{
			dpercent=double(i)/double(NumPoints)*100.0;
			if (-1 == (*pNotifyFunc)(dpercent))
				throw((int)0);
		};
  };
// запись информации для определения на следующем шаге Н.У. }
   Y[0][2]=Y02;
   Y[0][1]=Y01;
}; // FiltringVect  

//--------------------------------------------------------------------------
