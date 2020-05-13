// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxchart.pas' rev: 21.00

#ifndef FrxchartHPP
#define FrxchartHPP

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
#include <Frxclass.hpp>	// Pascal unit
#include <Teeprocs.hpp>	// Pascal unit
#include <Teengine.hpp>	// Pascal unit
#include <Chart.hpp>	// Pascal unit
#include <Series.hpp>	// Pascal unit
#include <Tecanvas.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxchart
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxChartObject;
class PASCALIMPLEMENTATION TfrxChartObject : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	/* TComponent.Create */ inline __fastcall virtual TfrxChartObject(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxChartObject(void) { }
	
};


typedef TMetaClass* TChartClass;

#pragma option push -b-
enum TfrxSeriesDataType { dtDBData, dtBandData, dtFixedData };
#pragma option pop

#pragma option push -b-
enum TfrxSeriesSortOrder { soNone, soAscending, soDescending };
#pragma option pop

#pragma option push -b-
enum TfrxSeriesXType { xtText, xtNumber, xtDate };
#pragma option pop

typedef TMetaClass* TSeriesClass;

#pragma option push -b-
enum TfrxChartSeries { csLine, csArea, csPoint, csBar, csHorizBar, csPie, csGantt, csFastLine, csArrow, csBubble, csChartShape, csHorizArea, csHorizLine, csPolar, csRadar, csPolarBar, csGauge, csSmith, csPyramid, csDonut, csBezier, csCandle, csVolume, csPointFigure, csHistogram, csHorizHistogram, csErrorBar, csError, csHighLow, csFunnel, csBox, csHorizBox, csSurface, csContour, csWaterFall, csColorGrid, csVector3D, csTower, csTriSurface, csPoint3D, csBubble3D, csMyPoint, csBarJoin, csBar3D };
#pragma option pop

class DELPHICLASS TfrxSeriesItem;
class PASCALIMPLEMENTATION TfrxSeriesItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	Frxclass::TfrxDataBand* FDataBand;
	Frxclass::TfrxDataSet* FDataSet;
	System::UnicodeString FDataSetName;
	TfrxSeriesDataType FDataType;
	TfrxSeriesSortOrder FSortOrder;
	int FTopN;
	System::UnicodeString FTopNCaption;
	System::UnicodeString FSource1;
	System::UnicodeString FSource2;
	System::UnicodeString FSource3;
	System::UnicodeString FSource4;
	System::UnicodeString FSource5;
	System::UnicodeString FSource6;
	TfrxSeriesXType FXType;
	System::UnicodeString FValues1;
	System::UnicodeString FValues2;
	System::UnicodeString FValues3;
	System::UnicodeString FValues4;
	System::UnicodeString FValues5;
	System::UnicodeString FValues6;
	void __fastcall FillSeries(Teengine::TChartSeries* Series);
	void __fastcall SetDataSet(const Frxclass::TfrxDataSet* Value);
	void __fastcall SetDataSetName(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetDataSetName(void);
	
__published:
	__property TfrxSeriesDataType DataType = {read=FDataType, write=FDataType, nodefault};
	__property Frxclass::TfrxDataBand* DataBand = {read=FDataBand, write=FDataBand};
	__property Frxclass::TfrxDataSet* DataSet = {read=FDataSet, write=SetDataSet};
	__property System::UnicodeString DataSetName = {read=GetDataSetName, write=SetDataSetName};
	__property TfrxSeriesSortOrder SortOrder = {read=FSortOrder, write=FSortOrder, nodefault};
	__property int TopN = {read=FTopN, write=FTopN, nodefault};
	__property System::UnicodeString TopNCaption = {read=FTopNCaption, write=FTopNCaption};
	__property TfrxSeriesXType XType = {read=FXType, write=FXType, nodefault};
	__property System::UnicodeString Source1 = {read=FSource1, write=FSource1};
	__property System::UnicodeString Source2 = {read=FSource2, write=FSource2};
	__property System::UnicodeString Source3 = {read=FSource3, write=FSource3};
	__property System::UnicodeString Source4 = {read=FSource4, write=FSource4};
	__property System::UnicodeString Source5 = {read=FSource5, write=FSource5};
	__property System::UnicodeString Source6 = {read=FSource6, write=FSource6};
	__property System::UnicodeString Values1 = {read=FValues1, write=FValues1};
	__property System::UnicodeString Values2 = {read=FValues2, write=FValues2};
	__property System::UnicodeString Values3 = {read=FValues3, write=FValues3};
	__property System::UnicodeString Values4 = {read=FValues4, write=FValues4};
	__property System::UnicodeString Values5 = {read=FValues5, write=FValues5};
	__property System::UnicodeString Values6 = {read=FValues6, write=FValues6};
	__property System::UnicodeString XSource = {read=FSource1, write=FSource1};
	__property System::UnicodeString YSource = {read=FSource2, write=FSource2};
	__property System::UnicodeString XValues = {read=FValues1, write=FValues1};
	__property System::UnicodeString YValues = {read=FValues2, write=FValues2};
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxSeriesItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxSeriesItem(void) { }
	
};


class DELPHICLASS TfrxSeriesData;
class PASCALIMPLEMENTATION TfrxSeriesData : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxSeriesItem* operator[](int Index) { return Items[Index]; }
	
private:
	Frxclass::TfrxReport* FReport;
	TfrxSeriesItem* __fastcall GetSeries(int Index);
	
public:
	__fastcall TfrxSeriesData(Frxclass::TfrxReport* Report);
	HIDESBASE TfrxSeriesItem* __fastcall Add(void);
	__property TfrxSeriesItem* Items[int Index] = {read=GetSeries/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxSeriesData(void) { }
	
};


class DELPHICLASS TfrxChartView;
class PASCALIMPLEMENTATION TfrxChartView : public Frxclass::TfrxView
{
	typedef Frxclass::TfrxView inherited;
	
private:
	Chart::TCustomChart* FChart;
	TfrxSeriesData* FSeriesData;
	bool FIgnoreNulls;
	void __fastcall FillChart(void);
	void __fastcall ReadData(Classes::TStream* Stream);
	void __fastcall ReadData1(Classes::TReader* Reader);
	void __fastcall ReadData2(Classes::TReader* Reader);
	void __fastcall WriteData(Classes::TStream* Stream);
	void __fastcall WriteData1(Classes::TWriter* Writer);
	void __fastcall WriteData2(Classes::TWriter* Writer);
	
protected:
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall CreateChart(void);
	__classmethod virtual TChartClass __fastcall GetChartClass();
	
public:
	__fastcall virtual TfrxChartView(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxChartView(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall AfterPrint(void);
	virtual void __fastcall GetData(void);
	virtual void __fastcall BeforeStartReport(void);
	virtual void __fastcall OnNotify(System::TObject* Sender);
	void __fastcall ClearSeries(void);
	void __fastcall AddSeries(TfrxChartSeries Series);
	__property Chart::TCustomChart* Chart = {read=FChart};
	__property TfrxSeriesData* SeriesData = {read=FSeriesData};
	
__published:
	__property bool IgnoreNulls = {read=FIgnoreNulls, write=FIgnoreNulls, default=0};
	__property BrushStyle = {default=0};
	__property Color = {default=536870911};
	__property Cursor = {default=0};
	__property Frame;
	__property TagStr;
	__property URL;
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxChartView(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxView(AOwner, Flags) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxchart */
using namespace Frxchart;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxchartHPP
