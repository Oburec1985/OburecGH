// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fqbclass.pas' rev: 21.00

#ifndef FqbclassHPP
#define FqbclassHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Grids.hpp>	// Pascal unit
#include <Db.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Checklst.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fqbclass
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EfqbError;
class PASCALIMPLEMENTATION EfqbError : public Sysutils::Exception
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ inline __fastcall EfqbError(const System::UnicodeString Msg) : Sysutils::Exception(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EfqbError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EfqbError(int Ident)/* overload */ : Sysutils::Exception(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EfqbError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EfqbError(const System::UnicodeString Msg, int AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EfqbError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EfqbError(int Ident, int AHelpContext)/* overload */ : Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EfqbError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Sysutils::Exception(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EfqbError(void) { }
	
};


class DELPHICLASS TfqbField;
class PASCALIMPLEMENTATION TfqbField : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FFieldName;
	int FFielType;
	bool FLinked;
	System::UnicodeString __fastcall GetFieldName(void);
	
public:
	__property System::UnicodeString FieldName = {read=GetFieldName, write=FFieldName};
	__property int FieldType = {read=FFielType, write=FFielType, nodefault};
	__property bool Linked = {read=FLinked, write=FLinked, nodefault};
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfqbField(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfqbField(void) { }
	
};


class DELPHICLASS TfqbFieldList;
class PASCALIMPLEMENTATION TfqbFieldList : public Classes::TOwnedCollection
{
	typedef Classes::TOwnedCollection inherited;
	
public:
	TfqbField* operator[](int Index) { return Items[Index]; }
	
private:
	HIDESBASE TfqbField* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, const TfqbField* Value);
	
public:
	HIDESBASE TfqbField* __fastcall Add(void);
	__property TfqbField* Items[int Index] = {read=GetItem, write=SetItem/*, default*/};
public:
	/* TOwnedCollection.Create */ inline __fastcall TfqbFieldList(Classes::TPersistent* AOwner, Classes::TCollectionItemClass ItemClass) : Classes::TOwnedCollection(AOwner, ItemClass) { }
	
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfqbFieldList(void) { }
	
};


class DELPHICLASS TfqbLink;
class DELPHICLASS TfqbTableArea;
class DELPHICLASS TfqbTable;
class PASCALIMPLEMENTATION TfqbLink : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
protected:
	TfqbTableArea* FArea;
	TfqbField* FDestField;
	TfqbTable* FDestTable;
	int FJOp;
	int FJType;
	Menus::TPopupMenu* FMenu;
	bool FSelected;
	TfqbField* FSourceField;
	TfqbTable* FSourceTable;
	void __fastcall DoDelete(System::TObject* Sender);
	void __fastcall DoOptions(System::TObject* Sender);
	void __fastcall Draw(void);
	Types::TPoint __fastcall GetDestCoords(void);
	Types::TPoint __fastcall GetSourceCoords(void);
	void __fastcall SetSelected(const bool Value);
	
public:
	__fastcall virtual TfqbLink(Classes::TCollection* Collection);
	__fastcall virtual ~TfqbLink(void);
	__property Types::TPoint DestCoords = {read=GetDestCoords};
	__property TfqbField* DestField = {read=FDestField};
	__property TfqbTable* DestTable = {read=FDestTable};
	__property int JoinOperator = {read=FJOp, write=FJOp, nodefault};
	__property int JoinType = {read=FJType, write=FJType, nodefault};
	__property bool Selected = {read=FSelected, write=SetSelected, nodefault};
	__property Types::TPoint SourceCoords = {read=GetSourceCoords};
	__property TfqbField* SourceField = {read=FSourceField};
	__property TfqbTable* SourceTable = {read=FSourceTable};
};


class DELPHICLASS TfqbLinkList;
class PASCALIMPLEMENTATION TfqbLinkList : public Classes::TOwnedCollection
{
	typedef Classes::TOwnedCollection inherited;
	
public:
	TfqbLink* operator[](int Index) { return Items[Index]; }
	
private:
	HIDESBASE TfqbLink* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, const TfqbLink* Value);
	
public:
	HIDESBASE TfqbLink* __fastcall Add(void);
	__property TfqbLink* Items[int Index] = {read=GetItem, write=SetItem/*, default*/};
public:
	/* TOwnedCollection.Create */ inline __fastcall TfqbLinkList(Classes::TPersistent* AOwner, Classes::TCollectionItemClass ItemClass) : Classes::TOwnedCollection(AOwner, ItemClass) { }
	
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfqbLinkList(void) { }
	
};


class DELPHICLASS TfqbCheckListBox;
class PASCALIMPLEMENTATION TfqbCheckListBox : public Checklst::TCheckListBox
{
	typedef Checklst::TCheckListBox inherited;
	
protected:
	DYNAMIC void __fastcall ClickCheck(void);
	DYNAMIC void __fastcall DragOver(System::TObject* Sender, int X, int Y, Controls::TDragState State, bool &Accept);
	
public:
	DYNAMIC void __fastcall DragDrop(System::TObject* Sender, int X, int Y);
public:
	/* TCheckListBox.Create */ inline __fastcall virtual TfqbCheckListBox(Classes::TComponent* AOwner) : Checklst::TCheckListBox(AOwner) { }
	/* TCheckListBox.Destroy */ inline __fastcall virtual ~TfqbCheckListBox(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfqbCheckListBox(HWND ParentWindow) : Checklst::TCheckListBox(ParentWindow) { }
	
};


class PASCALIMPLEMENTATION TfqbTable : public Extctrls::TPanel
{
	typedef Extctrls::TPanel inherited;
	
private:
	System::UnicodeString FAliasName;
	Buttons::TSpeedButton* FButtonClose;
	Buttons::TSpeedButton* FButtonMinimize;
	TfqbCheckListBox* FCheckListBox;
	TfqbFieldList* FFieldList;
	Extctrls::TImage* FImage;
	Stdctrls::TLabel* FLabel;
	int FOldHeight;
	System::UnicodeString FTableName;
	TfqbField* __fastcall GetSellectedField(void);
	void __fastcall SetTableName(const System::UnicodeString Value);
	void __fastcall SetXPStyle(const Controls::TControl* AComp);
	
protected:
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	Types::TPoint __fastcall GetLinkPoint(int AIndex, System::WideChar ASide);
	DYNAMIC void __fastcall Resize(void);
	HIDESBASE MESSAGE void __fastcall WMMove(Messages::TWMMove &Message);
	HIDESBASE MESSAGE void __fastcall WMNCHitTest(Messages::TWMNCHitTest &M);
	HIDESBASE MESSAGE void __fastcall WMPaint(Messages::TWMPaint &Message);
	MESSAGE void __fastcall CMRelease(Messages::TMessage &Message);
	void __fastcall _DoExit(System::TObject* Sender);
	void __fastcall _DoMinimize(System::TObject* Sender);
	void __fastcall _DoRestore(System::TObject* Sender);
	__property TfqbCheckListBox* ChBox = {read=FCheckListBox};
	
public:
	__fastcall virtual TfqbTable(Classes::TComponent* AOwner);
	__fastcall virtual ~TfqbTable(void);
	void __fastcall UpdateFieldList(void);
	void __fastcall UpdateLinkList(void);
	__property System::UnicodeString AliasName = {read=FAliasName};
	__property TfqbFieldList* FieldList = {read=FFieldList, write=FFieldList};
	__property TfqbField* SellectedField = {read=GetSellectedField};
	__property System::UnicodeString TableName = {read=FTableName, write=SetTableName};
public:
	/* TWinControl.CreateParented */ inline __fastcall TfqbTable(HWND ParentWindow) : Extctrls::TPanel(ParentWindow) { }
	
};


class PASCALIMPLEMENTATION TfqbTableArea : public Forms::TScrollBox
{
	typedef Forms::TScrollBox inherited;
	
private:
	Graphics::TCanvas* FCanvas;
	int FInstX;
	int FInstY;
	TfqbLinkList* FLinkList;
	
protected:
	DYNAMIC void __fastcall Click(void);
	virtual System::UnicodeString __fastcall GenerateAlias(const System::UnicodeString ATableNAme);
	int __fastcall GetLineAtCursor(void);
	HIDESBASE MESSAGE void __fastcall WMPaint(Messages::TWMPaint &Message);
	
public:
	__fastcall virtual TfqbTableArea(Classes::TComponent* AOwner);
	__fastcall virtual ~TfqbTableArea(void);
	bool __fastcall CompareFields(int TableID1, int FIndex1, int TableID2, int FIndex2);
	DYNAMIC void __fastcall DragDrop(System::TObject* Source, int X, int Y);
	DYNAMIC void __fastcall DragOver(System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	TfqbTable* __fastcall FindTable(const System::UnicodeString AName, const System::UnicodeString AAlias);
	void __fastcall InsertTable(const int X, const int Y, const System::UnicodeString Name)/* overload */;
	void __fastcall InsertTable(const System::UnicodeString Name)/* overload */;
	__property TfqbLinkList* LinkList = {read=FLinkList};
public:
	/* TWinControl.CreateParented */ inline __fastcall TfqbTableArea(HWND ParentWindow) : Forms::TScrollBox(ParentWindow) { }
	
};


class DELPHICLASS TfqbTableListBox;
class PASCALIMPLEMENTATION TfqbTableListBox : public Stdctrls::TListBox
{
	typedef Stdctrls::TListBox inherited;
	
protected:
	DYNAMIC void __fastcall DblClick(void);
	virtual void __fastcall DrawItem(int Index, const Types::TRect &Rect, Windows::TOwnerDrawState State);
	virtual void __fastcall CreateWnd(void);
	
public:
	__fastcall virtual TfqbTableListBox(Classes::TComponent* AOwner);
public:
	/* TCustomListBox.Destroy */ inline __fastcall virtual ~TfqbTableListBox(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfqbTableListBox(HWND ParentWindow) : Stdctrls::TListBox(ParentWindow) { }
	
};


struct TGridColumn;
typedef TGridColumn *PGridColumn;

struct TGridColumn
{
	
public:
	System::UnicodeString Table;
	System::UnicodeString Alias;
	System::UnicodeString Field;
	bool Visibl;
	System::UnicodeString Where;
	int Sort;
	int Func;
	int Group;
};


class DELPHICLASS TfqbEdit;
class PASCALIMPLEMENTATION TfqbEdit : public Stdctrls::TEdit
{
	typedef Stdctrls::TEdit inherited;
	
private:
	Buttons::TSpeedButton* FButton;
	Classes::TNotifyEvent FOnButtonClick;
	Extctrls::TPanel* FPanel;
	bool FShowButton;
	void __fastcall SetShowButton(const bool Value);
	
protected:
	void __fastcall ButtonClick(System::TObject* Sender);
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	virtual void __fastcall CreateWnd(void);
	void __fastcall SetEditRect(void);
	HIDESBASE MESSAGE void __fastcall WMSize(Messages::TWMSize &Message);
	
public:
	__fastcall virtual TfqbEdit(Classes::TComponent* AOwner);
	__property Classes::TNotifyEvent OnButtonClick = {read=FOnButtonClick, write=FOnButtonClick};
	__property bool ShowButton = {read=FShowButton, write=SetShowButton, nodefault};
public:
	/* TWinControl.CreateParented */ inline __fastcall TfqbEdit(HWND ParentWindow) : Stdctrls::TEdit(ParentWindow) { }
	/* TWinControl.Destroy */ inline __fastcall virtual ~TfqbEdit(void) { }
	
};


typedef void __fastcall (__closure *TfqbColumnResizeEvent)(Comctrls::TCustomListView* Sender, int ColumnIndex, int ColumnWidth);

class DELPHICLASS TfqbGrid;
class PASCALIMPLEMENTATION TfqbGrid : public Comctrls::TListView
{
	typedef Comctrls::TListView inherited;
	
private:
	TfqbColumnResizeEvent FEndColumnResizeEvent;
	Stdctrls::TComboBox* FFunctionList;
	Stdctrls::TComboBox* FGroupList;
	Menus::TPopupMenu* FPopupMenu;
	Stdctrls::TComboBox* FSortList;
	Stdctrls::TComboBox* FVisibleList;
	TfqbEdit* FWhereEditor;
	void __fastcall fqbOnChange(System::TObject* Sender);
	void __fastcall fqbOnMenu(System::TObject* Sender);
	void __fastcall fqbOnPopup(System::TObject* Sender);
	void __fastcall fqbOnSelectItem(System::TObject* Sender, Comctrls::TListItem* Item, bool Selected);
	void __fastcall fqbSetBounds(Controls::TControl* &Contr);
	
protected:
	virtual void __fastcall CreateWnd(void);
	virtual void __fastcall DoColumnResize(int ColumnIndex, int ColumnWidth);
	int __fastcall FindColumnIndex(Windows::PNMHdr pHeader);
	int __fastcall FindColumnWidth(Windows::PNMHdr pHeader);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall RecalcColWidth(void);
	DYNAMIC void __fastcall Resize(void);
	HIDESBASE MESSAGE void __fastcall WMNotify(Messages::TWMNotify &Msg);
	HIDESBASE MESSAGE void __fastcall WMVscroll(Messages::TWMNotify &Msg);
	
public:
	__fastcall virtual TfqbGrid(Classes::TComponent* AOwner);
	__fastcall virtual ~TfqbGrid(void);
	int __fastcall AddColumn(void);
	void __fastcall Exchange(const int AItm1, const int AItm2);
	void __fastcall fqbUpdate(void);
	HIDESBASE void __fastcall UpdateColumn(void);
	__property TfqbColumnResizeEvent OnEndColumnResize = {read=FEndColumnResizeEvent, write=FEndColumnResizeEvent};
public:
	/* TWinControl.CreateParented */ inline __fastcall TfqbGrid(HWND ParentWindow) : Comctrls::TListView(ParentWindow) { }
	
};


class DELPHICLASS TfqbEngine;
class PASCALIMPLEMENTATION TfqbEngine : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	bool FShowSystemTables;
	
public:
	virtual void __fastcall ReadFieldList(const System::UnicodeString ATableName, TfqbFieldList* &AFieldList) = 0 ;
	virtual void __fastcall ReadTableList(Classes::TStrings* ATableList) = 0 ;
	virtual Db::TDataSet* __fastcall ResultDataSet(void) = 0 ;
	virtual void __fastcall SetSQL(const System::UnicodeString Value) = 0 ;
	
__published:
	__property bool ShowSystemTables = {read=FShowSystemTables, write=FShowSystemTables, default=0};
public:
	/* TComponent.Create */ inline __fastcall virtual TfqbEngine(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfqbEngine(void) { }
	
};


class DELPHICLASS TfqbDialog;
class PASCALIMPLEMENTATION TfqbDialog : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	TfqbEngine* FEngine;
	bool __fastcall GetSchemaInsideSQL(void);
	System::UnicodeString __fastcall GetSQL(void);
	System::UnicodeString __fastcall GetSQLSchema(void);
	void __fastcall SetEngine(const TfqbEngine* Value);
	void __fastcall SetSchemaInsideSQL(const bool Value);
	void __fastcall SetSQL(System::UnicodeString Value);
	void __fastcall SetSQLSchema(const System::UnicodeString Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	
public:
	__fastcall virtual TfqbDialog(Classes::TComponent* AOwner);
	virtual bool __fastcall Execute(void);
	__property System::UnicodeString SQL = {read=GetSQL, write=SetSQL};
	__property System::UnicodeString SQLSchema = {read=GetSQLSchema, write=SetSQLSchema};
	
__published:
	__property TfqbEngine* Engine = {read=FEngine, write=SetEngine};
	__property bool SchemaInsideSQL = {read=GetSchemaInsideSQL, write=SetSchemaInsideSQL, default=1};
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TfqbDialog(void) { }
	
};


class DELPHICLASS TfqbCore;
class PASCALIMPLEMENTATION TfqbCore : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TfqbEngine* FEngine;
	TfqbGrid* FGrid;
	bool FSchemaInsideSQL;
	System::UnicodeString FSQL;
	System::UnicodeString FSQLSchema;
	TfqbTableArea* FTableArea;
	bool FUseCoding;
	System::UnicodeString FText;
	bool FUsingQuotes;
	System::UnicodeString __fastcall ExtractSchema(const System::UnicodeString Value);
	System::UnicodeString __fastcall ExtractSQL(const System::UnicodeString Str);
	TfqbEngine* __fastcall GetEngine(void);
	TfqbGrid* __fastcall GetGrid(void);
	System::UnicodeString __fastcall GetSQL(void);
	System::UnicodeString __fastcall GetSQLSchema(void);
	TfqbTableArea* __fastcall GetTableArea(void);
	void __fastcall SetSchemaInsideSQL(const bool Value);
	void __fastcall SetSQL(System::UnicodeString Value);
	void __fastcall SetSQLSchema(const System::UnicodeString Value);
	
public:
	__fastcall virtual TfqbCore(void);
	__fastcall virtual ~TfqbCore(void);
	void __fastcall Clear(void);
	System::UnicodeString __fastcall GenerateSQL(void);
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	void __fastcall LoadFromStr(const Classes::TStringList* Str);
	void __fastcall RecognizeModel(const unsigned crc32, const System::UnicodeString FileName);
	void __fastcall SaveToFile(const System::UnicodeString FileName);
	void __fastcall SaveToStr(Classes::TStringList* &Str);
	__property TfqbEngine* Engine = {read=GetEngine, write=FEngine};
	__property TfqbGrid* Grid = {read=GetGrid, write=FGrid};
	__property System::UnicodeString SQL = {read=GetSQL, write=SetSQL};
	__property System::UnicodeString SQLSchema = {read=GetSQLSchema, write=SetSQLSchema};
	__property TfqbTableArea* TableArea = {read=GetTableArea, write=FTableArea};
	__property bool SchemaInsideSQL = {read=FSchemaInsideSQL, write=SetSchemaInsideSQL, default=1};
	__property bool UsingQuotes = {read=FUsingQuotes, write=FUsingQuotes, nodefault};
};


typedef StaticArray<System::UnicodeString, 30> Fqbclass__51;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Fqbclass__51 StrFieldType;
#define _fqbBeginModel L"/*_FQBMODEL"
#define _fqbEndModel L"_FQBEND*/"
extern PACKAGE TfqbCore* __fastcall fqbCore(void);

}	/* namespace Fqbclass */
using namespace Fqbclass;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FqbclassHPP
