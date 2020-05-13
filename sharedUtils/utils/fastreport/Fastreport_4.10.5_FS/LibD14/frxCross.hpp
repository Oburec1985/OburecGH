// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxcross.pas' rev: 21.00

#ifndef FrxcrossHPP
#define FrxcrossHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxcross
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxCrossObject;
class PASCALIMPLEMENTATION TfrxCrossObject : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	/* TComponent.Create */ inline __fastcall virtual TfrxCrossObject(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxCrossObject(void) { }
	
};


typedef System::UnicodeString TfrxPrintCellEvent;

typedef System::UnicodeString TfrxPrintHeaderEvent;

typedef System::UnicodeString TfrxCalcWidthEvent;

typedef System::UnicodeString TfrxCalcHeightEvent;

typedef void __fastcall (__closure *TfrxOnPrintCellEvent)(Frxclass::TfrxCustomMemoView* Memo, int RowIndex, int ColumnIndex, int CellIndex, const System::Variant &RowValues, const System::Variant &ColumnValues, const System::Variant &Value);

typedef void __fastcall (__closure *TfrxOnPrintHeaderEvent)(Frxclass::TfrxCustomMemoView* Memo, const System::Variant &HeaderIndexes, const System::Variant &HeaderValues, const System::Variant &Value);

typedef void __fastcall (__closure *TfrxOnCalcWidthEvent)(int ColumnIndex, const System::Variant &ColumnValues, System::Extended &Width);

typedef void __fastcall (__closure *TfrxOnCalcHeightEvent)(int RowIndex, const System::Variant &RowValues, System::Extended &Height);

struct TfrxCrossCell;
typedef TfrxCrossCell *PfrCrossCell;

#pragma pack(push,1)
struct TfrxCrossCell
{
	
public:
	System::Variant Value;
	int Count;
	TfrxCrossCell *Next;
};
#pragma pack(pop)


#pragma option push -b-
enum TfrxCrossSortOrder { soAscending, soDescending, soNone, soGrouping };
#pragma option pop

#pragma option push -b-
enum TfrxCrossFunction { cfNone, cfSum, cfMin, cfMax, cfAvg, cfCount };
#pragma option pop

typedef DynamicArray<System::Variant> TfrxVariantArray;

typedef StaticArray<TfrxCrossSortOrder, 32> TfrxSortArray;

class DELPHICLASS TfrxIndexItem;
class PASCALIMPLEMENTATION TfrxIndexItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	TfrxVariantArray FIndexes;
	
public:
	__fastcall virtual ~TfrxIndexItem(void);
	__property TfrxVariantArray Indexes = {read=FIndexes, write=FIndexes};
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxIndexItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	
};


class DELPHICLASS TfrxIndexCollection;
class PASCALIMPLEMENTATION TfrxIndexCollection : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxIndexItem* operator[](int Index) { return Items[Index]; }
	
private:
	int FIndexesCount;
	TfrxSortArray FSortOrder;
	TfrxIndexItem* __fastcall GetItems(int Index);
	
public:
	bool __fastcall Find(System::Variant const *Indexes, const int Indexes_Size, int &Index);
	HIDESBASE virtual TfrxIndexItem* __fastcall InsertItem(int Index, System::Variant const *Indexes, const int Indexes_Size);
	__property TfrxIndexItem* Items[int Index] = {read=GetItems/*, default*/};
public:
	/* TCollection.Create */ inline __fastcall TfrxIndexCollection(Classes::TCollectionItemClass ItemClass) : Classes::TCollection(ItemClass) { }
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxIndexCollection(void) { }
	
};


class DELPHICLASS TfrxCrossRow;
class PASCALIMPLEMENTATION TfrxCrossRow : public TfrxIndexItem
{
	typedef TfrxIndexItem inherited;
	
private:
	int FCellLevels;
	Classes::TList* FCells;
	void __fastcall CreateCell(int Index);
	
public:
	__fastcall virtual TfrxCrossRow(Classes::TCollection* Collection);
	__fastcall virtual ~TfrxCrossRow(void);
	PfrCrossCell __fastcall GetCell(int Index);
	System::Variant __fastcall GetCellValue(int Index1, int Index2);
	void __fastcall SetCellValue(int Index1, int Index2, const System::Variant &Value);
};


class DELPHICLASS TfrxCrossRows;
class PASCALIMPLEMENTATION TfrxCrossRows : public TfrxIndexCollection
{
	typedef TfrxIndexCollection inherited;
	
public:
	TfrxCrossRow* operator[](int Index) { return Items[Index]; }
	
private:
	int FCellLevels;
	HIDESBASE TfrxCrossRow* __fastcall GetItems(int Index);
	
public:
	__fastcall TfrxCrossRows(void);
	virtual TfrxIndexItem* __fastcall InsertItem(int Index, System::Variant const *Indexes, const int Indexes_Size);
	TfrxCrossRow* __fastcall Row(System::Variant const *Indexes, const int Indexes_Size);
	__property TfrxCrossRow* Items[int Index] = {read=GetItems/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxCrossRows(void) { }
	
};


class DELPHICLASS TfrxCrossColumn;
class PASCALIMPLEMENTATION TfrxCrossColumn : public TfrxIndexItem
{
	typedef TfrxIndexItem inherited;
	
private:
	int FCellIndex;
	
public:
	__property int CellIndex = {read=FCellIndex, write=FCellIndex, nodefault};
public:
	/* TfrxIndexItem.Destroy */ inline __fastcall virtual ~TfrxCrossColumn(void) { }
	
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxCrossColumn(Classes::TCollection* Collection) : TfrxIndexItem(Collection) { }
	
};


class DELPHICLASS TfrxCrossColumns;
class PASCALIMPLEMENTATION TfrxCrossColumns : public TfrxIndexCollection
{
	typedef TfrxIndexCollection inherited;
	
public:
	TfrxCrossColumn* operator[](int Index) { return Items[Index]; }
	
private:
	HIDESBASE TfrxCrossColumn* __fastcall GetItems(int Index);
	
public:
	__fastcall TfrxCrossColumns(void);
	TfrxCrossColumn* __fastcall Column(System::Variant const *Indexes, const int Indexes_Size);
	virtual TfrxIndexItem* __fastcall InsertItem(int Index, System::Variant const *Indexes, const int Indexes_Size);
	__property TfrxCrossColumn* Items[int Index] = {read=GetItems/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxCrossColumns(void) { }
	
};


class DELPHICLASS TfrxCrossHeader;
class PASCALIMPLEMENTATION TfrxCrossHeader : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TfrxCrossHeader* operator[](int Index) { return Items[Index]; }
	
private:
	Frxclass::TfrxRect FBounds;
	Classes::TList* FMemos;
	Classes::TList* FTotalMemos;
	TfrxVariantArray FCounts;
	int FCellIndex;
	int FCellLevels;
	TfrxVariantArray FFuncValues;
	bool FHasCellHeaders;
	int FIndex;
	bool FIsCellHeader;
	bool FIsIndex;
	bool FIsTotal;
	Classes::TList* FItems;
	int FLevelsCount;
	Frxclass::TfrxCustomMemoView* FMemo;
	bool FNoLevels;
	TfrxCrossHeader* FParent;
	Frxclass::TfrxPoint FSize;
	int FTotalIndex;
	System::Variant FValue;
	bool FVisible;
	TfrxCrossHeader* __fastcall AddCellHeader(Classes::TList* Memos, int Index, int CellIndex);
	TfrxCrossHeader* __fastcall AddChild(Frxclass::TfrxCustomMemoView* Memo);
	void __fastcall AddFuncValues(System::Variant const *Values, const int Values_Size, System::Variant const *Counts, const int Counts_Size, TfrxCrossFunction const *CellFunctions, const int CellFunctions_Size);
	void __fastcall AddValues(System::Variant const *Values, const int Values_Size, bool Unsorted);
	void __fastcall Reset(TfrxCrossFunction const *CellFunctions, const int CellFunctions_Size);
	int __fastcall GetCount(void);
	TfrxCrossHeader* __fastcall GetItems(int Index);
	int __fastcall GetLevel(void);
	System::Extended __fastcall GetHeight(void);
	System::Extended __fastcall GetWidth(void);
	
public:
	__fastcall TfrxCrossHeader(int CellLevels);
	__fastcall virtual ~TfrxCrossHeader(void);
	virtual void __fastcall CalcBounds(void) = 0 ;
	virtual void __fastcall CalcSizes(int MaxWidth, int MinWidth, bool AutoSize) = 0 ;
	Classes::TList* __fastcall AllItems(void);
	int __fastcall Find(const System::Variant &Value);
	System::Variant __fastcall GetIndexes(void);
	System::Variant __fastcall GetValues(void);
	Classes::TList* __fastcall TerminalItems(void);
	Classes::TList* __fastcall IndexItems(void);
	__property Frxclass::TfrxRect Bounds = {read=FBounds, write=FBounds};
	__property int Count = {read=GetCount, nodefault};
	__property bool HasCellHeaders = {read=FHasCellHeaders, write=FHasCellHeaders, nodefault};
	__property System::Extended Height = {read=GetHeight};
	__property bool IsTotal = {read=FIsTotal, nodefault};
	__property TfrxCrossHeader* Items[int Index] = {read=GetItems/*, default*/};
	__property int Level = {read=GetLevel, nodefault};
	__property Frxclass::TfrxCustomMemoView* Memo = {read=FMemo};
	__property TfrxCrossHeader* Parent = {read=FParent};
	__property System::Variant Value = {read=FValue, write=FValue};
	__property bool Visible = {read=FVisible, write=FVisible, nodefault};
	__property System::Extended Width = {read=GetWidth};
};


class DELPHICLASS TfrxCrossColumnHeader;
class PASCALIMPLEMENTATION TfrxCrossColumnHeader : public TfrxCrossHeader
{
	typedef TfrxCrossHeader inherited;
	
private:
	TfrxCrossHeader* FCorner;
	
public:
	virtual void __fastcall CalcBounds(void);
	virtual void __fastcall CalcSizes(int MaxWidth, int MinWidth, bool AutoSize);
public:
	/* TfrxCrossHeader.Create */ inline __fastcall TfrxCrossColumnHeader(int CellLevels) : TfrxCrossHeader(CellLevels) { }
	/* TfrxCrossHeader.Destroy */ inline __fastcall virtual ~TfrxCrossColumnHeader(void) { }
	
};


class DELPHICLASS TfrxCrossRowHeader;
class PASCALIMPLEMENTATION TfrxCrossRowHeader : public TfrxCrossHeader
{
	typedef TfrxCrossHeader inherited;
	
private:
	TfrxCrossHeader* FCorner;
	
public:
	virtual void __fastcall CalcBounds(void);
	virtual void __fastcall CalcSizes(int MaxWidth, int MinWidth, bool AutoSize);
public:
	/* TfrxCrossHeader.Create */ inline __fastcall TfrxCrossRowHeader(int CellLevels) : TfrxCrossHeader(CellLevels) { }
	/* TfrxCrossHeader.Destroy */ inline __fastcall virtual ~TfrxCrossRowHeader(void) { }
	
};


class DELPHICLASS TfrxCrossCorner;
class PASCALIMPLEMENTATION TfrxCrossCorner : public TfrxCrossColumnHeader
{
	typedef TfrxCrossColumnHeader inherited;
	
public:
	/* TfrxCrossHeader.Create */ inline __fastcall TfrxCrossCorner(int CellLevels) : TfrxCrossColumnHeader(CellLevels) { }
	/* TfrxCrossHeader.Destroy */ inline __fastcall virtual ~TfrxCrossCorner(void) { }
	
};


class DELPHICLASS TfrxCutBandItem;
class PASCALIMPLEMENTATION TfrxCutBandItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
public:
	Frxclass::TfrxBand* Band;
	int FromIndex;
	int ToIndex;
	__fastcall virtual ~TfrxCutBandItem(void);
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxCutBandItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	
};


class DELPHICLASS TfrxCutBands;
class PASCALIMPLEMENTATION TfrxCutBands : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxCutBandItem* operator[](int Index) { return Items[Index]; }
	
private:
	TfrxCutBandItem* __fastcall GetItems(int Index);
	
public:
	__fastcall TfrxCutBands(void);
	HIDESBASE void __fastcall Add(Frxclass::TfrxBand* ABand, int AFromIndex, int AToIndex);
	__property TfrxCutBandItem* Items[int Index] = {read=GetItems/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxCutBands(void) { }
	
};


class DELPHICLASS TfrxGridLineItem;
class PASCALIMPLEMENTATION TfrxGridLineItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
public:
	System::Extended Coord;
	Classes::TList* Objects;
	__fastcall virtual TfrxGridLineItem(Classes::TCollection* Collection);
	__fastcall virtual ~TfrxGridLineItem(void);
};


class DELPHICLASS TfrxGridLines;
class PASCALIMPLEMENTATION TfrxGridLines : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxGridLineItem* operator[](int Index) { return Items[Index]; }
	
private:
	TfrxGridLineItem* __fastcall GetItems(int Index);
	
public:
	__fastcall TfrxGridLines(void);
	HIDESBASE void __fastcall Add(System::TObject* AObj, System::Extended ACoord);
	__property TfrxGridLineItem* Items[int Index] = {read=GetItems/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxGridLines(void) { }
	
};


class DELPHICLASS TfrxCustomCrossView;
class PASCALIMPLEMENTATION TfrxCustomCrossView : public Frxclass::TfrxView
{
	typedef Frxclass::TfrxView inherited;
	
private:
	System::Extended FAddHeight;
	System::Extended FAddWidth;
	bool FAllowDuplicates;
	bool FAutoSize;
	bool FBorder;
	Classes::TStrings* FCellFields;
	StaticArray<TfrxCrossFunction, 32> FCellFunctions;
	int FCellLevels;
	bool FClearBeforePrint;
	TfrxCutBands* FColumnBands;
	Classes::TStrings* FColumnFields;
	TfrxCrossColumnHeader* FColumnHeader;
	int FColumnLevels;
	TfrxCrossColumns* FColumns;
	TfrxSortArray FColumnSort;
	TfrxCrossCorner* FCorner;
	int FDefHeight;
	bool FDotMatrix;
	bool FDownThenAcross;
	Types::TPoint FFirstMousePos;
	int FGapX;
	int FGapY;
	TfrxGridLines* FGridUsed;
	TfrxGridLines* FGridX;
	TfrxGridLines* FGridY;
	bool FJoinEqualCells;
	bool FKeepTogether;
	Types::TPoint FLastMousePos;
	int FMaxWidth;
	int FMinWidth;
	bool FMouseDown;
	int FMovingObjects;
	TfrxCustomCrossView* FNextCross;
	System::Extended FNextCrossGap;
	bool FNoColumns;
	bool FNoRows;
	bool FPlainCells;
	bool FRepeatHeaders;
	TfrxCutBands* FRowBands;
	Classes::TStrings* FRowFields;
	TfrxCrossRowHeader* FRowHeader;
	int FRowLevels;
	TfrxCrossRows* FRows;
	TfrxSortArray FRowSort;
	bool FShowColumnHeader;
	bool FShowColumnTotal;
	bool FShowCorner;
	bool FShowRowHeader;
	bool FShowRowTotal;
	bool FShowTitle;
	bool FSuppressNullRecords;
	Classes::TList* FAllMemos;
	Classes::TList* FCellMemos;
	Classes::TList* FCellHeaderMemos;
	Classes::TList* FColumnMemos;
	Classes::TList* FColumnTotalMemos;
	Classes::TList* FCornerMemos;
	Classes::TList* FRowMemos;
	Classes::TList* FRowTotalMemos;
	TfrxCalcHeightEvent FOnCalcHeight;
	TfrxCalcWidthEvent FOnCalcWidth;
	TfrxPrintCellEvent FOnPrintCell;
	TfrxPrintHeaderEvent FOnPrintColumnHeader;
	TfrxPrintHeaderEvent FOnPrintRowHeader;
	TfrxOnCalcHeightEvent FOnBeforeCalcHeight;
	TfrxOnCalcWidthEvent FOnBeforeCalcWidth;
	TfrxOnPrintCellEvent FOnBeforePrintCell;
	TfrxOnPrintHeaderEvent FOnBeforePrintColumnHeader;
	TfrxOnPrintHeaderEvent FOnBeforePrintRowHeader;
	void __fastcall CalcBounds(System::Extended addWidth, System::Extended addHeight);
	void __fastcall CalcTotal(TfrxCrossHeader* Header, TfrxIndexCollection* Source);
	void __fastcall CalcTotals(void);
	void __fastcall CreateHeader(TfrxCrossHeader* Header, TfrxIndexCollection* Source, Classes::TList* Totals, bool TotalVisible);
	void __fastcall CreateHeaders(void);
	void __fastcall BuildColumnBands(void);
	void __fastcall BuildRowBands(void);
	void __fastcall ClearMatrix(void);
	void __fastcall ClearMemos(void);
	void __fastcall CreateCellHeaderMemos(int NewCount);
	void __fastcall CreateCellMemos(int NewCount);
	void __fastcall CreateColumnMemos(int NewCount);
	void __fastcall CreateCornerMemos(int NewCount);
	void __fastcall CreateRowMemos(int NewCount);
	void __fastcall CorrectDMPBounds(Frxclass::TfrxCustomMemoView* Memo);
	void __fastcall DoCalcHeight(int Row, System::Extended &Height);
	void __fastcall DoCalcWidth(int Column, System::Extended &Width);
	void __fastcall DoOnCell(Frxclass::TfrxCustomMemoView* Memo, int Row, int Column, int Cell, const System::Variant &Value);
	void __fastcall DoOnColumnHeader(Frxclass::TfrxCustomMemoView* Memo, TfrxCrossHeader* Header);
	void __fastcall DoOnRowHeader(Frxclass::TfrxCustomMemoView* Memo, TfrxCrossHeader* Header);
	void __fastcall InitMatrix(void);
	void __fastcall InitMemos(bool AddToScript);
	void __fastcall ReadMemos(Classes::TStream* Stream);
	void __fastcall RenderMatrix(void);
	void __fastcall SetCellFields(const Classes::TStrings* Value);
	void __fastcall SetCellFunctions(int Index, const TfrxCrossFunction Value);
	void __fastcall SetColumnFields(const Classes::TStrings* Value);
	void __fastcall SetColumnSort(int Index, TfrxCrossSortOrder Value);
	void __fastcall SetDotMatrix(const bool Value);
	void __fastcall SetRowFields(const Classes::TStrings* Value);
	void __fastcall SetRowSort(int Index, TfrxCrossSortOrder Value);
	void __fastcall SetupOriginalComponent(Frxclass::TfrxComponent* Obj1, Frxclass::TfrxComponent* Obj2);
	void __fastcall UpdateVisibility(void);
	void __fastcall WriteMemos(Classes::TStream* Stream);
	Frxclass::TfrxCustomMemoView* __fastcall CreateMemo(Frxclass::TfrxComponent* Parent);
	TfrxCrossFunction __fastcall GetCellFunctions(int Index);
	Frxclass::TfrxCustomMemoView* __fastcall GetCellHeaderMemos(int Index);
	Frxclass::TfrxCustomMemoView* __fastcall GetCellMemos(int Index);
	Frxclass::TfrxCustomMemoView* __fastcall GetColumnMemos(int Index);
	TfrxCrossSortOrder __fastcall GetColumnSort(int Index);
	Frxclass::TfrxCustomMemoView* __fastcall GetColumnTotalMemos(int Index);
	Frxclass::TfrxCustomMemoView* __fastcall GetCornerMemos(int Index);
	Classes::TList* __fastcall GetNestedObjects(void);
	Frxclass::TfrxCustomMemoView* __fastcall GetRowMemos(int Index);
	TfrxCrossSortOrder __fastcall GetRowSort(int Index);
	Frxclass::TfrxCustomMemoView* __fastcall GetRowTotalMemos(int Index);
	
protected:
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetCellLevels(const int Value);
	virtual void __fastcall SetColumnLevels(const int Value);
	virtual void __fastcall SetRowLevels(const int Value);
	virtual Classes::TList* __fastcall GetContainerObjects(void);
	
public:
	__fastcall virtual TfrxCustomCrossView(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxCustomCrossView(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall BeforePrint(void);
	virtual void __fastcall BeforeStartReport(void);
	virtual void __fastcall GetData(void);
	virtual void __fastcall AddSourceObjects(void);
	virtual bool __fastcall ContainerAdd(Frxclass::TfrxComponent* Obj);
	virtual bool __fastcall ContainerMouseDown(System::TObject* Sender, int X, int Y);
	virtual void __fastcall ContainerMouseMove(System::TObject* Sender, int X, int Y);
	virtual void __fastcall ContainerMouseUp(System::TObject* Sender, int X, int Y);
	void __fastcall AddValue(System::Variant const *Rows, const int Rows_Size, System::Variant const *Columns, const int Columns_Size, System::Variant const *Cells, const int Cells_Size);
	void __fastcall ApplyStyle(Frxclass::TfrxStyles* Style);
	void __fastcall BeginMatrix(void);
	void __fastcall EndMatrix(void);
	virtual void __fastcall FillMatrix(void);
	void __fastcall GetStyle(Frxclass::TfrxStyles* Style);
	int __fastcall ColCount(void);
	Frxclass::TfrxPoint __fastcall DrawCross(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	System::Variant __fastcall GetColumnIndexes(int AColumn);
	System::Variant __fastcall GetRowIndexes(int ARow);
	System::Variant __fastcall GetValue(int ARow, int AColumn, int ACell);
	virtual bool __fastcall IsCrossValid(void);
	bool __fastcall IsGrandTotalColumn(int Index);
	bool __fastcall IsGrandTotalRow(int Index);
	bool __fastcall IsTotalColumn(int Index);
	bool __fastcall IsTotalRow(int Index);
	int __fastcall RowCount(void);
	System::Extended __fastcall RowHeaderWidth(void);
	System::Extended __fastcall ColumnHeaderHeight(void);
	__property TfrxCrossColumnHeader* ColumnHeader = {read=FColumnHeader};
	__property TfrxCrossRowHeader* RowHeader = {read=FRowHeader};
	__property TfrxCrossCorner* Corner = {read=FCorner};
	__property bool NoColumns = {read=FNoColumns, nodefault};
	__property bool NoRows = {read=FNoRows, nodefault};
	__property Classes::TStrings* CellFields = {read=FCellFields, write=SetCellFields};
	__property TfrxCrossFunction CellFunctions[int Index] = {read=GetCellFunctions, write=SetCellFunctions};
	__property Frxclass::TfrxCustomMemoView* CellMemos[int Index] = {read=GetCellMemos};
	__property Frxclass::TfrxCustomMemoView* CellHeaderMemos[int Index] = {read=GetCellHeaderMemos};
	__property bool ClearBeforePrint = {read=FClearBeforePrint, write=FClearBeforePrint, nodefault};
	__property Classes::TStrings* ColumnFields = {read=FColumnFields, write=SetColumnFields};
	__property Frxclass::TfrxCustomMemoView* ColumnMemos[int Index] = {read=GetColumnMemos};
	__property TfrxCrossSortOrder ColumnSort[int Index] = {read=GetColumnSort, write=SetColumnSort};
	__property Frxclass::TfrxCustomMemoView* ColumnTotalMemos[int Index] = {read=GetColumnTotalMemos};
	__property Frxclass::TfrxCustomMemoView* CornerMemos[int Index] = {read=GetCornerMemos};
	__property bool DotMatrix = {read=FDotMatrix, nodefault};
	__property Classes::TStrings* RowFields = {read=FRowFields, write=SetRowFields};
	__property Frxclass::TfrxCustomMemoView* RowMemos[int Index] = {read=GetRowMemos};
	__property TfrxCrossSortOrder RowSort[int Index] = {read=GetRowSort, write=SetRowSort};
	__property Frxclass::TfrxCustomMemoView* RowTotalMemos[int Index] = {read=GetRowTotalMemos};
	__property TfrxOnCalcHeightEvent OnBeforeCalcHeight = {read=FOnBeforeCalcHeight, write=FOnBeforeCalcHeight};
	__property TfrxOnCalcWidthEvent OnBeforeCalcWidth = {read=FOnBeforeCalcWidth, write=FOnBeforeCalcWidth};
	__property TfrxOnPrintCellEvent OnBeforePrintCell = {read=FOnBeforePrintCell, write=FOnBeforePrintCell};
	__property TfrxOnPrintHeaderEvent OnBeforePrintColumnHeader = {read=FOnBeforePrintColumnHeader, write=FOnBeforePrintColumnHeader};
	__property TfrxOnPrintHeaderEvent OnBeforePrintRowHeader = {read=FOnBeforePrintRowHeader, write=FOnBeforePrintRowHeader};
	
__published:
	__property System::Extended AddHeight = {read=FAddHeight, write=FAddHeight};
	__property System::Extended AddWidth = {read=FAddWidth, write=FAddWidth};
	__property bool AllowDuplicates = {read=FAllowDuplicates, write=FAllowDuplicates, default=1};
	__property bool AutoSize = {read=FAutoSize, write=FAutoSize, default=1};
	__property bool Border = {read=FBorder, write=FBorder, default=1};
	__property int CellLevels = {read=FCellLevels, write=SetCellLevels, default=1};
	__property int ColumnLevels = {read=FColumnLevels, write=SetColumnLevels, default=1};
	__property int DefHeight = {read=FDefHeight, write=FDefHeight, default=0};
	__property bool DownThenAcross = {read=FDownThenAcross, write=FDownThenAcross, nodefault};
	__property int GapX = {read=FGapX, write=FGapX, default=3};
	__property int GapY = {read=FGapY, write=FGapY, default=3};
	__property bool JoinEqualCells = {read=FJoinEqualCells, write=FJoinEqualCells, default=0};
	__property bool KeepTogether = {read=FKeepTogether, write=FKeepTogether, default=0};
	__property int MaxWidth = {read=FMaxWidth, write=FMaxWidth, default=200};
	__property int MinWidth = {read=FMinWidth, write=FMinWidth, default=0};
	__property TfrxCustomCrossView* NextCross = {read=FNextCross, write=FNextCross};
	__property System::Extended NextCrossGap = {read=FNextCrossGap, write=FNextCrossGap};
	__property bool PlainCells = {read=FPlainCells, write=FPlainCells, default=0};
	__property bool RepeatHeaders = {read=FRepeatHeaders, write=FRepeatHeaders, default=1};
	__property int RowLevels = {read=FRowLevels, write=SetRowLevels, default=1};
	__property bool ShowColumnHeader = {read=FShowColumnHeader, write=FShowColumnHeader, default=1};
	__property bool ShowColumnTotal = {read=FShowColumnTotal, write=FShowColumnTotal, default=1};
	__property bool ShowCorner = {read=FShowCorner, write=FShowCorner, default=1};
	__property bool ShowRowHeader = {read=FShowRowHeader, write=FShowRowHeader, default=1};
	__property bool ShowRowTotal = {read=FShowRowTotal, write=FShowRowTotal, default=1};
	__property bool ShowTitle = {read=FShowTitle, write=FShowTitle, default=1};
	__property bool SuppressNullRecords = {read=FSuppressNullRecords, write=FSuppressNullRecords, default=1};
	__property TfrxCalcHeightEvent OnCalcHeight = {read=FOnCalcHeight, write=FOnCalcHeight};
	__property TfrxCalcWidthEvent OnCalcWidth = {read=FOnCalcWidth, write=FOnCalcWidth};
	__property TfrxPrintCellEvent OnPrintCell = {read=FOnPrintCell, write=FOnPrintCell};
	__property TfrxPrintHeaderEvent OnPrintColumnHeader = {read=FOnPrintColumnHeader, write=FOnPrintColumnHeader};
	__property TfrxPrintHeaderEvent OnPrintRowHeader = {read=FOnPrintRowHeader, write=FOnPrintRowHeader};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCustomCrossView(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxView(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxCrossView;
class PASCALIMPLEMENTATION TfrxCrossView : public TfrxCustomCrossView
{
	typedef TfrxCustomCrossView inherited;
	
protected:
	virtual void __fastcall SetCellLevels(const int Value);
	virtual void __fastcall SetColumnLevels(const int Value);
	virtual void __fastcall SetRowLevels(const int Value);
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual bool __fastcall IsCrossValid(void);
public:
	/* TfrxCustomCrossView.Create */ inline __fastcall virtual TfrxCrossView(Classes::TComponent* AOwner) : TfrxCustomCrossView(AOwner) { }
	/* TfrxCustomCrossView.Destroy */ inline __fastcall virtual ~TfrxCrossView(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCrossView(Classes::TComponent* AOwner, System::Word Flags) : TfrxCustomCrossView(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDBCrossView;
class PASCALIMPLEMENTATION TfrxDBCrossView : public TfrxCustomCrossView
{
	typedef TfrxCustomCrossView inherited;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual bool __fastcall IsCrossValid(void);
	virtual void __fastcall FillMatrix(void);
	
__published:
	__property CellFields;
	__property ColumnFields;
	__property DataSet;
	__property DataSetName;
	__property RowFields;
public:
	/* TfrxCustomCrossView.Create */ inline __fastcall virtual TfrxDBCrossView(Classes::TComponent* AOwner) : TfrxCustomCrossView(AOwner) { }
	/* TfrxCustomCrossView.Destroy */ inline __fastcall virtual ~TfrxDBCrossView(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDBCrossView(Classes::TComponent* AOwner, System::Word Flags) : TfrxCustomCrossView(AOwner, Flags) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxcross */
using namespace Frxcross;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxcrossHPP
