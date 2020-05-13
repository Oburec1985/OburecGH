// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxcharthelpers.pas' rev: 21.00

#ifndef FrxcharthelpersHPP
#define FrxcharthelpersHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Frxchart.hpp>	// Pascal unit
#include <Teeprocs.hpp>	// Pascal unit
#include <Teengine.hpp>	// Pascal unit
#include <Chart.hpp>	// Pascal unit
#include <Series.hpp>	// Pascal unit
#include <Tecanvas.hpp>	// Pascal unit
#include <Ganttch.hpp>	// Pascal unit
#include <Teeshape.hpp>	// Pascal unit
#include <Bubblech.hpp>	// Pascal unit
#include <Arrowcha.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxcharthelpers
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxSeriesHelper;
class PASCALIMPLEMENTATION TfrxSeriesHelper : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	virtual System::UnicodeString __fastcall GetParamNames(void) = 0 ;
	virtual void __fastcall AddValues(Teengine::TChartSeries* Series, const System::UnicodeString v1, const System::UnicodeString v2, const System::UnicodeString v3, const System::UnicodeString v4, const System::UnicodeString v5, const System::UnicodeString v6, Frxchart::TfrxSeriesXType XType) = 0 ;
public:
	/* TObject.Create */ inline __fastcall TfrxSeriesHelper(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxSeriesHelper(void) { }
	
};


class DELPHICLASS TfrxStdSeriesHelper;
class PASCALIMPLEMENTATION TfrxStdSeriesHelper : public TfrxSeriesHelper
{
	typedef TfrxSeriesHelper inherited;
	
public:
	virtual System::UnicodeString __fastcall GetParamNames(void);
	virtual void __fastcall AddValues(Teengine::TChartSeries* Series, const System::UnicodeString v1, const System::UnicodeString v2, const System::UnicodeString v3, const System::UnicodeString v4, const System::UnicodeString v5, const System::UnicodeString v6, Frxchart::TfrxSeriesXType XType);
public:
	/* TObject.Create */ inline __fastcall TfrxStdSeriesHelper(void) : TfrxSeriesHelper() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxStdSeriesHelper(void) { }
	
};


class DELPHICLASS TfrxPieSeriesHelper;
class PASCALIMPLEMENTATION TfrxPieSeriesHelper : public TfrxSeriesHelper
{
	typedef TfrxSeriesHelper inherited;
	
public:
	virtual System::UnicodeString __fastcall GetParamNames(void);
	virtual void __fastcall AddValues(Teengine::TChartSeries* Series, const System::UnicodeString v1, const System::UnicodeString v2, const System::UnicodeString v3, const System::UnicodeString v4, const System::UnicodeString v5, const System::UnicodeString v6, Frxchart::TfrxSeriesXType XType);
public:
	/* TObject.Create */ inline __fastcall TfrxPieSeriesHelper(void) : TfrxSeriesHelper() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxPieSeriesHelper(void) { }
	
};


class DELPHICLASS TfrxGanttSeriesHelper;
class PASCALIMPLEMENTATION TfrxGanttSeriesHelper : public TfrxSeriesHelper
{
	typedef TfrxSeriesHelper inherited;
	
public:
	virtual System::UnicodeString __fastcall GetParamNames(void);
	virtual void __fastcall AddValues(Teengine::TChartSeries* Series, const System::UnicodeString v1, const System::UnicodeString v2, const System::UnicodeString v3, const System::UnicodeString v4, const System::UnicodeString v5, const System::UnicodeString v6, Frxchart::TfrxSeriesXType XType);
public:
	/* TObject.Create */ inline __fastcall TfrxGanttSeriesHelper(void) : TfrxSeriesHelper() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxGanttSeriesHelper(void) { }
	
};


class DELPHICLASS TfrxArrowSeriesHelper;
class PASCALIMPLEMENTATION TfrxArrowSeriesHelper : public TfrxSeriesHelper
{
	typedef TfrxSeriesHelper inherited;
	
public:
	virtual System::UnicodeString __fastcall GetParamNames(void);
	virtual void __fastcall AddValues(Teengine::TChartSeries* Series, const System::UnicodeString v1, const System::UnicodeString v2, const System::UnicodeString v3, const System::UnicodeString v4, const System::UnicodeString v5, const System::UnicodeString v6, Frxchart::TfrxSeriesXType XType);
public:
	/* TObject.Create */ inline __fastcall TfrxArrowSeriesHelper(void) : TfrxSeriesHelper() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxArrowSeriesHelper(void) { }
	
};


class DELPHICLASS TfrxBubbleSeriesHelper;
class PASCALIMPLEMENTATION TfrxBubbleSeriesHelper : public TfrxSeriesHelper
{
	typedef TfrxSeriesHelper inherited;
	
public:
	virtual System::UnicodeString __fastcall GetParamNames(void);
	virtual void __fastcall AddValues(Teengine::TChartSeries* Series, const System::UnicodeString v1, const System::UnicodeString v2, const System::UnicodeString v3, const System::UnicodeString v4, const System::UnicodeString v5, const System::UnicodeString v6, Frxchart::TfrxSeriesXType XType);
public:
	/* TObject.Create */ inline __fastcall TfrxBubbleSeriesHelper(void) : TfrxSeriesHelper() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxBubbleSeriesHelper(void) { }
	
};


typedef TMetaClass* TfrxSeriesHelperClass;

//-- var, const, procedure ---------------------------------------------------
static const ShortInt frxNumSeries = 0xb;
extern PACKAGE StaticArray<Frxchart::TSeriesClass, 11> frxChartSeries;
extern PACKAGE StaticArray<TfrxSeriesHelperClass, 11> frxSeriesHelpers;
extern PACKAGE TfrxSeriesHelper* __fastcall frxFindSeriesHelper(Teengine::TChartSeries* Series);

}	/* namespace Frxcharthelpers */
using namespace Frxcharthelpers;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxcharthelpersHPP
