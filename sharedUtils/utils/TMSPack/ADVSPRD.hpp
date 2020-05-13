// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advsprd.pas' rev: 21.00

#ifndef AdvsprdHPP
#define AdvsprdHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Grids.hpp>	// Pascal unit
#include <Basegrid.hpp>	// Pascal unit
#include <Advgrid.hpp>	// Pascal unit
#include <Advpars.hpp>	// Pascal unit
#include <Advutil.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Advobj.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advsprd
{
//-- type declarations -------------------------------------------------------
typedef void __fastcall (__closure *TFormulaErrorEvent)(System::TObject* Sender, int ACol, int ARow, System::UnicodeString S);

typedef void __fastcall (__closure *TFormulaErrorInfoEvent)(System::TObject* Sender, int ACol, int ARow, int ErrType, int ErrPos, int ErrParam, System::UnicodeString ErrStr);

typedef void __fastcall (__closure *TCellFormatEvent)(System::TObject* Sender, int ACol, int Arow, System::UnicodeString &Format, bool &DateType);

struct TCellRef;
typedef TCellRef *PCellRef;

class DELPHICLASS TAdvSpreadGrid;
struct TCellRef
{
	
public:
	Grids::TGridCoord Src;
	Grids::TGridCoord Dst;
	TAdvSpreadGrid* SrcGrd;
	TAdvSpreadGrid* DstGrd;
	bool Dirty;
};


class DELPHICLASS TCellRefList;
class PASCALIMPLEMENTATION TCellRefList : public Classes::TList
{
	typedef Classes::TList inherited;
	
public:
	TCellRef operator[](int index) { return CellRefs[index]; }
	
private:
	TCellRef __fastcall GetCellRef(int Index);
	void __fastcall ShowCellRefs(void);
	
public:
	__fastcall TCellRefList(void);
	__fastcall virtual ~TCellRefList(void);
	__property TCellRef CellRefs[int index] = {read=GetCellRef/*, default*/};
	HIDESBASE void __fastcall Add(const TCellRef &Value);
	HIDESBASE void __fastcall Delete(int Index);
	void __fastcall DeleteRef(TAdvSpreadGrid* AGrid, const Grids::TGridCoord &gc);
	void __fastcall DeleteAll(void);
	void __fastcall ClearAll(void);
	void __fastcall ClearCell(int ACol, int ARow);
};


#pragma option push -b-
enum TCellNameMode { nmA1, nmRC };
#pragma option pop

#pragma option push -b-
enum TCellCalcState { csNoCalc, csCalcOk, csCalcErr };
#pragma option pop

#pragma option push -b-
enum TErrorDisplay { edFormula, edErrorText };
#pragma option pop

class PASCALIMPLEMENTATION TAdvSpreadGrid : public Advgrid::TAdvStringGrid
{
	typedef Advgrid::TAdvStringGrid inherited;
	
private:
	Advpars::TGridFormula* FGridFormula;
	bool FCalcBusy;
	bool FShowFormula;
	bool FAutoRecalc;
	bool FEditHint;
	System::UnicodeString FCellFormat;
	TCellFormatEvent FOnCellFormat;
	TFormulaErrorEvent FOnFormulaError;
	TCellRefList* FCellRefList;
	System::UnicodeString FErrorText;
	TCellNameMode FCellNameMode;
	bool FAutoHeaders;
	Advpars::TLibBinder* FMathLib;
	Advpars::TGridBinder* FBinder;
	TFormulaErrorInfoEvent FOnFormulaErrorInfo;
	bool FPrintFormula;
	TErrorDisplay FErrorDisplay;
	bool FFormulaCellClick;
	bool FSetCV;
	Classes::TNotifyEvent FOnBeforeRecalc;
	Classes::TNotifyEvent FOnAfterRecalc;
	HIDESBASE MESSAGE void __fastcall WMLButtonDown(Messages::TWMMouse &Msg);
	void __fastcall SetShowFormula(const bool Value);
	void __fastcall SetCellFormat(const System::UnicodeString Value);
	void __fastcall CalcFormula(int ACol, int ARow);
	void __fastcall DelCellRef(int ACol, int ARow);
	void __fastcall AddCellRef(int ACol, int ARow, System::UnicodeString s);
	void __fastcall CalcCellRef(int ACol, int ARow);
	void __fastcall ClearCellRefs(void);
	void __fastcall UpdCellRef(void);
	bool __fastcall HasCellRef(int ACol, int ARow);
	Advpars::TIsCustomFunction __fastcall GetIsCustomFunction(void);
	void __fastcall SetIsCustomFunction(Advpars::TIsCustomFunction value);
	Advpars::TCalcCustomFunction __fastcall GetCalcCustomFunction(void);
	void __fastcall SetCalcCustomFunction(Advpars::TCalcCustomFunction value);
	System::Variant __fastcall GetCellValue(int c, int r);
	System::UnicodeString __fastcall GetCellName(int c, int r);
	void __fastcall SetCellName(int c, int r, const System::UnicodeString Value);
	void __fastcall SetCellNameMode(const TCellNameMode Value);
	void __fastcall SetAutoHeaders(const bool Value);
	int __fastcall GetFixedCols(void);
	int __fastcall GetFixedRows(void);
	HIDESBASE void __fastcall SetFixedCols(const int Value);
	HIDESBASE void __fastcall SetFixedRows(const int Value);
	HIDESBASE System::UnicodeString __fastcall GetCellsEx(int c, int r);
	HIDESBASE void __fastcall SetCellEx(int c, int r, const System::UnicodeString Value);
	HIDESBASE int __fastcall GetColCountEx(void);
	HIDESBASE int __fastcall GetRowCountEx(void);
	HIDESBASE void __fastcall SetColCountEx(const int Value);
	HIDESBASE void __fastcall SetRowCountEx(const int Value);
	void __fastcall SetCellVal(int ACol, int ARow, const System::Variant &r);
	void __fastcall SetCellError(int ACol, int ARow, int ErrPos, int ErrLen);
	System::Variant __fastcall GetCellVal(int ACol, int ARow);
	void __fastcall ClearCellVal(int ACol, int ARow);
	TCellCalcState __fastcall GetCellState(int ACol, int ARow);
	System::Variant __fastcall GetCalculatedValue(int c, int r);
	
protected:
	virtual void __fastcall DoBeforeRecalc(void);
	virtual void __fastcall DoAfterRecalc(void);
	virtual Classes::TStringList* __fastcall CellNameList(void);
	System::UnicodeString __fastcall GetCellText(int ACol, int ARow, bool Formula);
	virtual System::UnicodeString __fastcall CalcCell(int ACol, int ARow);
	virtual void __fastcall GetCellAlign(int ACol, int ARow, Classes::TAlignment &HAlign, Advobj::TVAlignment &VAlign);
	virtual void __fastcall UpdateCell(int ACol, int ARow);
	virtual void __fastcall PasteStart(void);
	virtual void __fastcall PasteDone(void);
	virtual void __fastcall PasteNotify(const Types::TPoint &Orig, const Grids::TGridRect &gr, Advgrid::TClipOperation lastop);
	DYNAMIC void __fastcall SetEditText(int ACol, int ARow, const System::UnicodeString Value);
	bool __fastcall CheckRange(int c1, int r1, int c2, int r2);
	System::UnicodeString __fastcall ModifyRange(System::UnicodeString s, System::UnicodeString absc1, System::UnicodeString absr1, System::UnicodeString absc2, System::UnicodeString absr2, int ptx, int pty, int ofsx, int ofsy, int rngx, int rngy);
	System::UnicodeString __fastcall ModifyName(System::UnicodeString s, System::UnicodeString absc, System::UnicodeString absr, int ptx, int pty, int ofsx, int ofsy);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	void __fastcall ErrorHandler(System::TObject* Sender, int ACol, int ARow, int ErrType, int ErrPos, int ErrParam, System::UnicodeString ErrStr);
	virtual void __fastcall EditProgress(System::UnicodeString Value, const Types::TPoint &pt, int SelPos);
	System::UnicodeString __fastcall GetEditHint(System::UnicodeString Func, int ParamNr);
	virtual void __fastcall Loaded(void);
	virtual void __fastcall CellsLoaded(void);
	virtual void __fastcall RemoveRowsInternal(int RowIndex, int RCount);
	void __fastcall CellToNameEx(int Col, int Row, System::UnicodeString &ColName, System::UnicodeString &RowName);
	void __fastcall RangeToNameEx(const Grids::TGridRect &gr, System::UnicodeString &ColName1, System::UnicodeString &RowName1, System::UnicodeString &ColName2, System::UnicodeString &RowName2);
	virtual void __fastcall CellSelect(int c, int r);
	virtual void __fastcall SetCellSelectMode(const bool Value);
	System::UnicodeString __fastcall ModifyFormula(System::UnicodeString s, int ptx, int pty, int ofsx, int ofsy, int rngx, int rngy);
	
public:
	__fastcall virtual TAdvSpreadGrid(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvSpreadGrid(void);
	virtual int __fastcall GetVersionNr(void);
	virtual System::UnicodeString __fastcall GetVersionString(void);
	virtual bool __fastcall ValidateCell(const System::UnicodeString NewValue);
	virtual void __fastcall ClearRect(int ACol1, int ARow1, int ACol2, int ARow2);
	void __fastcall ShowCellRefs(void);
	void __fastcall AutoSpreadHeaders(void);
	void __fastcall RecalcCell(int ACol, int ARow);
	void __fastcall Recalc(void);
	System::UnicodeString __fastcall CellToName(int Col, int Row);
	virtual System::UnicodeString __fastcall SaveCell(int ACol, int ARow);
	virtual System::UnicodeString __fastcall ExportCell(int ACol, int ARow);
	Grids::TGridCoord __fastcall FindCellName(System::UnicodeString value);
	Grids::TGridCoord __fastcall NameToCell(System::UnicodeString s);
	System::UnicodeString __fastcall RangeToName(const Grids::TGridRect &gr);
	Grids::TGridRect __fastcall NameToRange(System::UnicodeString s);
	virtual void __fastcall Group(int Colindex);
	virtual void __fastcall UnGroup(void);
	virtual void __fastcall InsertRows(int RowIndex, int RCount, bool UpdateCellControls = true);
	virtual void __fastcall RemoveRows(int RowIndex, int RCount);
	virtual void __fastcall RemoveCols(int ColIndex, int CCount);
	virtual void __fastcall InsertCols(int ColIndex, int CCount);
	void __fastcall MoveFormula(const Grids::TGridCoord &FromCell, const Grids::TGridCoord &ToCell);
	bool __fastcall HasFormula(int ACol, int ARow);
	bool __fastcall HasError(int ACol, int ARow);
	virtual void __fastcall HandleError(int ACol, int ARow, int ErrType, int ErrPos, int ErrParam);
	virtual System::UnicodeString __fastcall ErrorToString(int ErrType);
	__property System::Variant CellValue[int c][int r] = {read=GetCellValue};
	__property System::UnicodeString CellName[int c][int r] = {read=GetCellName, write=SetCellName};
	__property System::UnicodeString Cells[int c][int r] = {read=GetCellsEx, write=SetCellEx};
	__property bool PrintFormula = {read=FPrintFormula, write=FPrintFormula, nodefault};
	__property System::Variant CalculatedValue[int c][int r] = {read=GetCalculatedValue};
	__property SaveFormula;
	
__published:
	__property Advpars::TGridBinder* Binder = {read=FBinder, write=FBinder};
	__property bool EditHint = {read=FEditHint, write=FEditHint, nodefault};
	__property Advpars::TLibBinder* Libs = {read=FMathLib, write=FMathLib};
	__property bool ShowFormula = {read=FShowFormula, write=SetShowFormula, nodefault};
	__property bool FormulaCellClick = {read=FFormulaCellClick, write=FFormulaCellClick, default=1};
	__property bool AutoRecalc = {read=FAutoRecalc, write=FAutoRecalc, nodefault};
	__property bool AutoHeaders = {read=FAutoHeaders, write=SetAutoHeaders, default=1};
	__property System::UnicodeString ErrorText = {read=FErrorText, write=FErrorText};
	__property TErrorDisplay ErrorDisplay = {read=FErrorDisplay, write=FErrorDisplay, nodefault};
	__property int FixedCols = {read=GetFixedCols, write=SetFixedCols, nodefault};
	__property int FixedRows = {read=GetFixedRows, write=SetFixedRows, nodefault};
	__property System::UnicodeString CellFormat = {read=FCellFormat, write=SetCellFormat};
	__property TCellNameMode CellNameMode = {read=FCellNameMode, write=SetCellNameMode, default=0};
	__property int ColCount = {read=GetColCountEx, write=SetColCountEx, nodefault};
	__property int RowCount = {read=GetRowCountEx, write=SetRowCountEx, nodefault};
	__property Classes::TNotifyEvent OnAfterRecalc = {read=FOnAfterRecalc, write=FOnAfterRecalc};
	__property Classes::TNotifyEvent OnBeforeRecalc = {read=FOnBeforeRecalc, write=FOnBeforeRecalc};
	__property TCellFormatEvent OnCellFormat = {read=FOnCellFormat, write=FOnCellFormat};
	__property TFormulaErrorEvent OnFormulaError = {read=FOnFormulaError, write=FOnFormulaError};
	__property TFormulaErrorInfoEvent OnFormulaErrorInfo = {read=FOnFormulaErrorInfo, write=FOnFormulaErrorInfo};
	__property Advpars::TIsCustomFunction OnIsCustomFunction = {read=GetIsCustomFunction, write=SetIsCustomFunction};
	__property Advpars::TCalcCustomFunction OnCalcCustomFunction = {read=GetCalcCustomFunction, write=SetCalcCustomFunction};
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvSpreadGrid(HWND ParentWindow) : Advgrid::TAdvStringGrid(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x2;
static const ShortInt MIN_VER = 0x3;
static const ShortInt REL_VER = 0x2;
static const ShortInt BLD_VER = 0x0;
#define DATE_VER L"Aug, 2015"
extern PACKAGE Grids::TGridCoord __fastcall GridCoord(int x, int y);

}	/* namespace Advsprd */
using namespace Advsprd;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvsprdHPP
