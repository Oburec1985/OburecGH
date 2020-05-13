// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxengine.pas' rev: 21.00

#ifndef FrxengineHPP
#define FrxengineHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxaggregate.hpp>	// Pascal unit
#include <Frxxml.hpp>	// Pascal unit
#include <Frxdmpclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxengine
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxHeaderListItem;
class PASCALIMPLEMENTATION TfrxHeaderListItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	Frxclass::TfrxBand* Band;
	System::Extended Left;
	bool IsInKeepList;
public:
	/* TObject.Create */ inline __fastcall TfrxHeaderListItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxHeaderListItem(void) { }
	
};


class DELPHICLASS TfrxHeaderList;
class PASCALIMPLEMENTATION TfrxHeaderList : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TfrxHeaderListItem* operator[](int Index) { return Items[Index]; }
	
private:
	Classes::TList* FList;
	int __fastcall GetCount(void);
	TfrxHeaderListItem* __fastcall GetItems(int Index);
	
public:
	__fastcall TfrxHeaderList(void);
	__fastcall virtual ~TfrxHeaderList(void);
	void __fastcall Clear(void);
	void __fastcall AddItem(Frxclass::TfrxBand* ABand, System::Extended ALeft, bool AInKeepList);
	void __fastcall RemoveItem(Frxclass::TfrxBand* ABand);
	__property int Count = {read=GetCount, nodefault};
	__property TfrxHeaderListItem* Items[int Index] = {read=GetItems/*, default*/};
};


class DELPHICLASS TfrxEngine;
class PASCALIMPLEMENTATION TfrxEngine : public Frxclass::TfrxCustomEngine
{
	typedef Frxclass::TfrxCustomEngine inherited;
	
private:
	Frxaggregate::TfrxAggregateList* FAggregates;
	bool FCallFromAddPage;
	bool FCallFromEndPage;
	Frxclass::TfrxBand* FCurBand;
	Frxclass::TfrxBand* FLastBandOnPage;
	bool FDontShowHeaders;
	TfrxHeaderList* FHeaderList;
	bool FFirstReportPage;
	System::Extended FFirstColumnY;
	bool FIsFirstBand;
	bool FIsFirstPage;
	bool FIsLastPage;
	Classes::TStrings* FHBandNamesTree;
	Frxclass::TfrxBand* FKeepBand;
	bool FKeepFooter;
	bool FKeeping;
	bool FKeepHeader;
	System::Extended FKeepCurY;
	System::Extended FSaveCurY;
	System::Extended FPrevFooterHeight;
	Frxxml::TfrxXMLItem* FKeepOutline;
	int FKeepPosition;
	int FKeepAnchor;
	bool FCallFromPHeader;
	Frxclass::TfrxNullBand* FOutputTo;
	Frxclass::TfrxReportPage* FPage;
	System::Extended FPageCurX;
	Frxclass::TfrxBand* FStartNewPageBand;
	Classes::TList* FVHeaderList;
	Frxclass::TfrxBand* FVMasterBand;
	Classes::TList* FVPageList;
	void __fastcall AddBandOutline(Frxclass::TfrxBand* Band);
	void __fastcall AddColumn(void);
	void __fastcall AddPage(void);
	void __fastcall AddPageOutline(void);
	void __fastcall AddToHeaderList(Frxclass::TfrxBand* Band);
	void __fastcall AddToVHeaderList(Frxclass::TfrxBand* Band);
	void __fastcall CheckBandColumns(Frxclass::TfrxDataBand* Band, int ColumnKeepPos, System::Extended SaveCurY);
	void __fastcall CheckDrill(Frxclass::TfrxDataBand* Master, Frxclass::TfrxGroupHeader* Band);
	void __fastcall CheckGroups(Frxclass::TfrxDataBand* Master, Frxclass::TfrxGroupHeader* Band, int ColumnKeepPos, System::Extended SaveCurY);
	void __fastcall CheckSubReports(Frxclass::TfrxBand* Band);
	void __fastcall CheckSuppress(Frxclass::TfrxBand* Band);
	void __fastcall DoShow(Frxclass::TfrxBand* Band);
	void __fastcall DrawSplit(Frxclass::TfrxBand* Band);
	void __fastcall EndColumn(void);
	void __fastcall EndKeep(Frxclass::TfrxBand* Band);
	void __fastcall InitGroups(Frxclass::TfrxDataBand* Master, Frxclass::TfrxGroupHeader* Band, int Index, bool ResetLineN = false);
	void __fastcall InitPage(void);
	void __fastcall NotifyObjects(Frxclass::TfrxBand* Band);
	void __fastcall OutlineRoot(void);
	void __fastcall OutlineUp(Frxclass::TfrxBand* Band);
	void __fastcall PreparePage(Classes::TStrings* ErrorList, bool PrepareVBands);
	void __fastcall PrepareShiftTree(Frxclass::TfrxBand* Band);
	void __fastcall RemoveFromHeaderList(Frxclass::TfrxBand* Band);
	void __fastcall RemoveFromVHeaderList(Frxclass::TfrxBand* Band);
	void __fastcall ResetSuppressValues(Frxclass::TfrxBand* Band);
	void __fastcall RunPage(Frxclass::TfrxReportPage* Page);
	void __fastcall RunReportPages(void);
	void __fastcall ShowGroupFooters(Frxclass::TfrxGroupHeader* Band, int Index, Frxclass::TfrxDataBand* Master);
	void __fastcall ShowVBands(Frxclass::TfrxBand* HBand);
	void __fastcall StartKeep(Frxclass::TfrxBand* Band, int Position = 0x0);
	void __fastcall Stretch(Frxclass::TfrxBand* Band);
	void __fastcall UnStretch(Frxclass::TfrxBand* Band);
	bool __fastcall CanShow(System::TObject* Obj, bool PrintIfDetailEmpty);
	Frxclass::TfrxBand* __fastcall FindBand(Frxclass::TfrxBandClass Band);
	bool __fastcall RunDialogs(void);
	
protected:
	virtual System::Extended __fastcall GetPageHeight(void);
	
public:
	__fastcall virtual TfrxEngine(Frxclass::TfrxReport* AReport);
	__fastcall virtual ~TfrxEngine(void);
	virtual void __fastcall EndPage(void);
	virtual void __fastcall NewColumn(void);
	virtual void __fastcall NewPage(void);
	virtual bool __fastcall Run(void);
	virtual void __fastcall ShowBand(Frxclass::TfrxBand* Band)/* overload */;
	virtual void __fastcall ShowBand(Frxclass::TfrxBandClass Band)/* overload */;
	virtual System::Extended __fastcall HeaderHeight(void);
	virtual System::Extended __fastcall FooterHeight(void);
	virtual System::Extended __fastcall FreeSpace(void);
	virtual void __fastcall BreakAllKeep(void);
	virtual System::Variant __fastcall GetAggregateValue(const System::UnicodeString Name, const System::UnicodeString Expression, Frxclass::TfrxBand* Band, int Flags);
	bool __fastcall Initialize(void);
	void __fastcall Finalize(void);
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxengine */
using namespace Frxengine;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxengineHPP
