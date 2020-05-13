// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxclass.pas' rev: 21.00

#ifndef FrxclassHPP
#define FrxclassHPP

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
#include <Inifiles.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Printers.hpp>	// Pascal unit
#include <Frxvariables.hpp>	// Pascal unit
#include <Frxxml.hpp>	// Pascal unit
#include <Frxprogress.hpp>	// Pascal unit
#include <Fs_iinterpreter.hpp>	// Pascal unit
#include <Frxunicodeutils.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Syncobjs.hpp>	// Pascal unit
#include <Widestrings.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxclass
{
//-- type declarations -------------------------------------------------------
typedef System::UnicodeString TfrxNotifyEvent;

typedef System::UnicodeString TfrxCloseQueryEvent;

typedef System::UnicodeString TfrxKeyEvent;

typedef System::UnicodeString TfrxKeyPressEvent;

typedef System::UnicodeString TfrxMouseEvent;

typedef System::UnicodeString TfrxMouseMoveEvent;

typedef System::UnicodeString TfrxPreviewClickEvent;

typedef System::UnicodeString TfrxRunDialogsEvent;

typedef int SYSINT;

#pragma option push -b-
enum Frxclass__1 { csContainer, csPreviewVisible, csDefaultDiff };
#pragma option pop

typedef Set<Frxclass__1, csContainer, csDefaultDiff>  TfrxComponentStyle;

#pragma option push -b-
enum TfrxStretchMode { smDontStretch, smActualHeight, smMaxHeight };
#pragma option pop

#pragma option push -b-
enum TfrxShiftMode { smDontShift, smAlways, smWhenOverlapped };
#pragma option pop

#pragma option push -b-
enum TfrxDuplexMode { dmNone, dmVertical, dmHorizontal, dmSimplex };
#pragma option pop

#pragma option push -b-
enum TfrxAlign { baNone, baLeft, baRight, baCenter, baWidth, baBottom, baClient };
#pragma option pop

#pragma option push -b-
enum TfrxFrameStyle { fsSolid, fsDash, fsDot, fsDashDot, fsDashDotDot, fsDouble, fsAltDot, fsSquare };
#pragma option pop

#pragma option push -b-
enum TfrxFrameType { ftLeft, ftRight, ftTop, ftBottom };
#pragma option pop

typedef Set<TfrxFrameType, ftLeft, ftBottom>  TfrxFrameTypes;

#pragma option push -b-
enum TfrxFormatKind { fkText, fkNumeric, fkDateTime, fkBoolean };
#pragma option pop

#pragma option push -b-
enum TfrxHAlign { haLeft, haRight, haCenter, haBlock };
#pragma option pop

#pragma option push -b-
enum TfrxVAlign { vaTop, vaBottom, vaCenter };
#pragma option pop

#pragma option push -b-
enum TfrxSilentMode { simMessageBoxes, simSilent, simReThrow };
#pragma option pop

#pragma option push -b-
enum TfrxRestriction { rfDontModify, rfDontSize, rfDontMove, rfDontDelete, rfDontEdit };
#pragma option pop

typedef Set<TfrxRestriction, rfDontModify, rfDontEdit>  TfrxRestrictions;

#pragma option push -b-
enum TfrxShapeKind { skRectangle, skRoundRectangle, skEllipse, skTriangle, skDiamond, skDiagonal1, skDiagonal2 };
#pragma option pop

#pragma option push -b-
enum TfrxPreviewButton { pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick, pbNoClose, pbNoFullScreen, pbNoEmail };
#pragma option pop

typedef Set<TfrxPreviewButton, pbPrint, pbNoEmail>  TfrxPreviewButtons;

#pragma option push -b-
enum TfrxZoomMode { zmDefault, zmWholePage, zmPageWidth, zmManyPages };
#pragma option pop

#pragma option push -b-
enum TfrxPrintPages { ppAll, ppOdd, ppEven };
#pragma option pop

#pragma option push -b-
enum TfrxAddPageAction { apWriteOver, apAdd };
#pragma option pop

#pragma option push -b-
enum TfrxRangeBegin { rbFirst, rbCurrent };
#pragma option pop

#pragma option push -b-
enum TfrxRangeEnd { reLast, reCurrent, reCount };
#pragma option pop

#pragma option push -b-
enum TfrxFieldType { fftNumeric, fftString, fftBoolean };
#pragma option pop

#pragma option push -b-
enum TfrxProgressType { ptRunning, ptExporting, ptPrinting };
#pragma option pop

#pragma option push -b-
enum TfrxPrintMode { pmDefault, pmSplit, pmJoin, pmScale };
#pragma option pop

#pragma option push -b-
enum TfrxInheriteMode { imDefault, imDelete, imRename };
#pragma option pop

#pragma pack(push,1)
struct TfrxRect
{
	
public:
	System::Extended Left;
	System::Extended Top;
	System::Extended Right;
	System::Extended Bottom;
};
#pragma pack(pop)


#pragma pack(push,1)
struct TfrxPoint
{
	
public:
	System::Extended X;
	System::Extended Y;
};
#pragma pack(pop)


class DELPHICLASS TfrxReport;
typedef void __fastcall (__closure *TfrxProgressEvent)(TfrxReport* Sender, TfrxProgressType ProgressType, int Progress);

class DELPHICLASS TfrxReportComponent;
typedef void __fastcall (__closure *TfrxBeforePrintEvent)(TfrxReportComponent* Sender);

typedef void __fastcall (__closure *TfrxGetValueEvent)(const System::UnicodeString VarName, System::Variant &Value);

typedef void __fastcall (__closure *TfrxNewGetValueEvent)(System::TObject* Sender, const System::UnicodeString VarName, System::Variant &Value);

typedef System::Variant __fastcall (__closure *TfrxUserFunctionEvent)(const System::UnicodeString MethodName, System::Variant &Params);

class DELPHICLASS TfrxPage;
typedef void __fastcall (__closure *TfrxManualBuildEvent)(TfrxPage* Page);

class DELPHICLASS TfrxView;
typedef void __fastcall (__closure *TfrxClickObjectEvent)(TfrxView* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, bool &Modified);

typedef void __fastcall (__closure *TfrxMouseOverObjectEvent)(TfrxView* Sender);

typedef void __fastcall (__closure *TfrxCheckEOFEvent)(System::TObject* Sender, bool &Eof);

class DELPHICLASS TfrxDialogPage;
typedef void __fastcall (__closure *TfrxRunDialogEvent)(TfrxDialogPage* Page);

typedef System::UnicodeString __fastcall (__closure *TfrxEditConnectionEvent)(const System::UnicodeString ConnString);

typedef void __fastcall (__closure *TfrxSetConnectionEvent)(const System::UnicodeString ConnString);

class DELPHICLASS TfrxCustomDatabase;
typedef void __fastcall (__closure *TfrxBeforeConnectEvent)(TfrxCustomDatabase* Sender, bool &Connected);

typedef void __fastcall (__closure *TfrxAfterDisconnectEvent)(TfrxCustomDatabase* Sender);

class DELPHICLASS TfrxReportPage;
typedef void __fastcall (__closure *TfrxPrintPageEvent)(TfrxReportPage* Page, int CopyNo);

typedef void __fastcall (__closure *TfrxLoadTemplateEvent)(TfrxReport* Report, const System::UnicodeString TemplateName);

class DELPHICLASS TfrxComponent;
class DELPHICLASS TfrxDataSet;
class PASCALIMPLEMENTATION TfrxComponent : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	Graphics::TFont* FFont;
	Classes::TList* FObjects;
	Classes::TList* FAllObjects;
	TfrxComponent* FParent;
	System::Extended FLeft;
	System::Extended FTop;
	System::Extended FWidth;
	System::Extended FHeight;
	bool FParentFont;
	int FGroupIndex;
	bool FIsDesigning;
	bool FIsLoading;
	bool FIsPrinting;
	bool FIsWriting;
	TfrxRestrictions FRestrictions;
	bool FVisible;
	System::UnicodeString FDescription;
	bool FAncestor;
	TfrxComponentStyle FComponentStyle;
	System::Extended __fastcall GetAbsTop(void);
	TfrxPage* __fastcall GetPage(void);
	TfrxReport* __fastcall GetReport(void);
	bool __fastcall IsFontStored(void);
	Classes::TList* __fastcall GetAllObjects(void);
	System::Extended __fastcall GetAbsLeft(void);
	bool __fastcall GetIsLoading(void);
	bool __fastcall GetIsAncestor(void);
	
protected:
	System::UnicodeString FAliasName;
	System::UnicodeString FBaseName;
	TfrxComponent* FOriginalComponent;
	TfrxRect FOriginalRect;
	TfrxComponent* FOriginalBand;
	virtual void __fastcall SetParent(TfrxComponent* AParent);
	virtual void __fastcall SetLeft(System::Extended Value);
	virtual void __fastcall SetTop(System::Extended Value);
	virtual void __fastcall SetWidth(System::Extended Value);
	virtual void __fastcall SetHeight(System::Extended Value);
	virtual void __fastcall SetName(const Classes::TComponentName AName);
	virtual void __fastcall SetFont(Graphics::TFont* Value);
	virtual void __fastcall SetParentFont(const bool Value);
	virtual void __fastcall SetVisible(bool Value);
	virtual void __fastcall FontChanged(System::TObject* Sender);
	System::UnicodeString __fastcall DiffFont(Graphics::TFont* f1, Graphics::TFont* f2, const System::UnicodeString Add);
	System::UnicodeString __fastcall InternalDiff(TfrxComponent* AComponent);
	virtual Classes::TList* __fastcall GetContainerObjects(void);
	DYNAMIC void __fastcall GetChildren(Classes::TGetChildProc Proc, Classes::TComponent* Root);
	DYNAMIC Classes::TComponent* __fastcall GetChildOwner(void);
	
public:
	__fastcall virtual TfrxComponent(Classes::TComponent* AOwner);
	__fastcall virtual TfrxComponent(Classes::TComponent* AOwner, System::Word Flags);
	__fastcall virtual ~TfrxComponent(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual void __fastcall AlignChildren(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall AssignAll(TfrxComponent* Source, bool Streaming = false);
	virtual void __fastcall AddSourceObjects(void);
	virtual void __fastcall BeforeStartReport(void);
	virtual void __fastcall Clear(void);
	void __fastcall CreateUniqueName(void);
	virtual void __fastcall LoadFromStream(Classes::TStream* Stream);
	virtual void __fastcall SaveToStream(Classes::TStream* Stream, bool SaveChildren = true, bool SaveDefaultValues = false, bool Streaming = false);
	void __fastcall SetBounds(System::Extended ALeft, System::Extended ATop, System::Extended AWidth, System::Extended AHeight);
	virtual void __fastcall OnNotify(System::TObject* Sender);
	virtual void __fastcall OnPaste(void);
	System::UnicodeString __fastcall AllDiff(TfrxComponent* AComponent);
	virtual System::UnicodeString __fastcall Diff(TfrxComponent* AComponent);
	TfrxComponent* __fastcall FindObject(const System::UnicodeString AName);
	virtual bool __fastcall ContainerAdd(TfrxComponent* Obj);
	virtual bool __fastcall ContainerMouseDown(System::TObject* Sender, int X, int Y);
	virtual void __fastcall ContainerMouseMove(System::TObject* Sender, int X, int Y);
	virtual void __fastcall ContainerMouseUp(System::TObject* Sender, int X, int Y);
	TfrxDataSet* __fastcall FindDataSet(TfrxDataSet* DataSet, const System::UnicodeString DSName);
	__property Classes::TList* Objects = {read=FObjects};
	__property Classes::TList* AllObjects = {read=GetAllObjects};
	__property Classes::TList* ContainerObjects = {read=GetContainerObjects};
	__property TfrxComponent* Parent = {read=FParent, write=SetParent};
	__property TfrxPage* Page = {read=GetPage};
	__property TfrxReport* Report = {read=GetReport};
	__property bool IsAncestor = {read=GetIsAncestor, nodefault};
	__property bool IsDesigning = {read=FIsDesigning, write=FIsDesigning, nodefault};
	__property bool IsLoading = {read=GetIsLoading, write=FIsLoading, nodefault};
	__property bool IsPrinting = {read=FIsPrinting, write=FIsPrinting, nodefault};
	__property bool IsWriting = {read=FIsWriting, write=FIsWriting, nodefault};
	__property System::UnicodeString BaseName = {read=FBaseName};
	__property int GroupIndex = {read=FGroupIndex, write=FGroupIndex, default=0};
	__property TfrxComponentStyle frComponentStyle = {read=FComponentStyle, write=FComponentStyle, nodefault};
	__property System::Extended Left = {read=FLeft, write=SetLeft};
	__property System::Extended Top = {read=FTop, write=SetTop};
	__property System::Extended Width = {read=FWidth, write=SetWidth};
	__property System::Extended Height = {read=FHeight, write=SetHeight};
	__property System::Extended AbsLeft = {read=GetAbsLeft};
	__property System::Extended AbsTop = {read=GetAbsTop};
	__property System::UnicodeString Description = {read=FDescription, write=FDescription};
	__property bool ParentFont = {read=FParentFont, write=SetParentFont, default=1};
	__property TfrxRestrictions Restrictions = {read=FRestrictions, write=FRestrictions, default=0};
	__property bool Visible = {read=FVisible, write=SetVisible, default=1};
	__property Graphics::TFont* Font = {read=FFont, write=SetFont, stored=IsFontStored};
};


class PASCALIMPLEMENTATION TfrxReportComponent : public TfrxComponent
{
	typedef TfrxComponent inherited;
	
private:
	TfrxNotifyEvent FOnAfterData;
	TfrxNotifyEvent FOnAfterPrint;
	TfrxNotifyEvent FOnBeforePrint;
	TfrxPreviewClickEvent FOnPreviewClick;
	TfrxPreviewClickEvent FOnPreviewDblClick;
	
public:
	System::Extended FShiftAmount;
	Classes::TList* FShiftChildren;
	__fastcall virtual TfrxReportComponent(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxReportComponent(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY) = 0 ;
	virtual void __fastcall BeforePrint(void);
	virtual void __fastcall GetData(void);
	virtual void __fastcall AfterPrint(void);
	virtual System::UnicodeString __fastcall GetComponentText(void);
	virtual TfrxRect __fastcall GetRealBounds(void);
	__property TfrxNotifyEvent OnAfterData = {read=FOnAfterData, write=FOnAfterData};
	__property TfrxNotifyEvent OnAfterPrint = {read=FOnAfterPrint, write=FOnAfterPrint};
	__property TfrxNotifyEvent OnBeforePrint = {read=FOnBeforePrint, write=FOnBeforePrint};
	__property TfrxPreviewClickEvent OnPreviewClick = {read=FOnPreviewClick, write=FOnPreviewClick};
	__property TfrxPreviewClickEvent OnPreviewDblClick = {read=FOnPreviewDblClick, write=FOnPreviewDblClick};
	
__published:
	__property Description;
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxReportComponent(Classes::TComponent* AOwner, System::Word Flags) : TfrxComponent(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDialogComponent;
class PASCALIMPLEMENTATION TfrxDialogComponent : public TfrxReportComponent
{
	typedef TfrxReportComponent inherited;
	
private:
	Classes::TComponent* FComponent;
	HIDESBASE void __fastcall ReadLeft(Classes::TReader* Reader);
	HIDESBASE void __fastcall ReadTop(Classes::TReader* Reader);
	HIDESBASE void __fastcall WriteLeft(Classes::TWriter* Writer);
	HIDESBASE void __fastcall WriteTop(Classes::TWriter* Writer);
	
protected:
	int FImageIndex;
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	
public:
	__fastcall virtual TfrxDialogComponent(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDialogComponent(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	__property Classes::TComponent* Component = {read=FComponent, write=FComponent};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDialogComponent(Classes::TComponent* AOwner, System::Word Flags) : TfrxReportComponent(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDialogControl;
class PASCALIMPLEMENTATION TfrxDialogControl : public TfrxReportComponent
{
	typedef TfrxReportComponent inherited;
	
private:
	Controls::TControl* FControl;
	TfrxNotifyEvent FOnClick;
	TfrxNotifyEvent FOnDblClick;
	TfrxNotifyEvent FOnEnter;
	TfrxNotifyEvent FOnExit;
	TfrxKeyEvent FOnKeyDown;
	TfrxKeyPressEvent FOnKeyPress;
	TfrxKeyEvent FOnKeyUp;
	TfrxMouseEvent FOnMouseDown;
	TfrxMouseMoveEvent FOnMouseMove;
	TfrxMouseEvent FOnMouseUp;
	Classes::TNotifyEvent FOnActivate;
	Graphics::TColor __fastcall GetColor(void);
	bool __fastcall GetEnabled(void);
	void __fastcall DoOnClick(System::TObject* Sender);
	void __fastcall DoOnDblClick(System::TObject* Sender);
	void __fastcall DoOnEnter(System::TObject* Sender);
	void __fastcall DoOnExit(System::TObject* Sender);
	void __fastcall DoOnKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall DoOnKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall DoOnKeyUp(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall DoOnMouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall DoOnMouseMove(System::TObject* Sender, Classes::TShiftState Shift, int X, int Y);
	void __fastcall DoOnMouseUp(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall SetColor(const Graphics::TColor Value);
	void __fastcall SetEnabled(const bool Value);
	System::UnicodeString __fastcall GetCaption(void);
	void __fastcall SetCaption(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetHint(void);
	void __fastcall SetHint(const System::UnicodeString Value);
	bool __fastcall GetShowHint(void);
	void __fastcall SetShowHint(const bool Value);
	bool __fastcall GetTabStop(void);
	void __fastcall SetTabStop(const bool Value);
	
protected:
	virtual void __fastcall SetLeft(System::Extended Value);
	virtual void __fastcall SetTop(System::Extended Value);
	virtual void __fastcall SetWidth(System::Extended Value);
	virtual void __fastcall SetHeight(System::Extended Value);
	virtual void __fastcall SetParentFont(const bool Value);
	virtual void __fastcall SetVisible(bool Value);
	virtual void __fastcall SetParent(TfrxComponent* AParent);
	virtual void __fastcall FontChanged(System::TObject* Sender);
	void __fastcall InitControl(Controls::TControl* AControl);
	virtual void __fastcall SetName(const Classes::TComponentName AName);
	
public:
	__fastcall virtual TfrxDialogControl(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDialogControl(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	__property System::UnicodeString Caption = {read=GetCaption, write=SetCaption};
	__property Graphics::TColor Color = {read=GetColor, write=SetColor, nodefault};
	__property Controls::TControl* Control = {read=FControl, write=FControl};
	__property bool TabStop = {read=GetTabStop, write=SetTabStop, default=1};
	__property TfrxNotifyEvent OnClick = {read=FOnClick, write=FOnClick};
	__property TfrxNotifyEvent OnDblClick = {read=FOnDblClick, write=FOnDblClick};
	__property TfrxNotifyEvent OnEnter = {read=FOnEnter, write=FOnEnter};
	__property TfrxNotifyEvent OnExit = {read=FOnExit, write=FOnExit};
	__property TfrxKeyEvent OnKeyDown = {read=FOnKeyDown, write=FOnKeyDown};
	__property TfrxKeyPressEvent OnKeyPress = {read=FOnKeyPress, write=FOnKeyPress};
	__property TfrxKeyEvent OnKeyUp = {read=FOnKeyUp, write=FOnKeyUp};
	__property TfrxMouseEvent OnMouseDown = {read=FOnMouseDown, write=FOnMouseDown};
	__property TfrxMouseMoveEvent OnMouseMove = {read=FOnMouseMove, write=FOnMouseMove};
	__property TfrxMouseEvent OnMouseUp = {read=FOnMouseUp, write=FOnMouseUp};
	__property Classes::TNotifyEvent OnActivate = {read=FOnActivate, write=FOnActivate};
	
__published:
	__property Left;
	__property Top;
	__property Width;
	__property Height;
	__property Font;
	__property GroupIndex = {default=0};
	__property ParentFont = {default=1};
	__property bool Enabled = {read=GetEnabled, write=SetEnabled, default=1};
	__property System::UnicodeString Hint = {read=GetHint, write=SetHint};
	__property bool ShowHint = {read=GetShowHint, write=SetShowHint, nodefault};
	__property Visible = {default=1};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDialogControl(Classes::TComponent* AOwner, System::Word Flags) : TfrxReportComponent(AOwner, Flags) { }
	
};


class PASCALIMPLEMENTATION TfrxDataSet : public TfrxDialogComponent
{
	typedef TfrxDialogComponent inherited;
	
private:
	bool FCloseDataSource;
	bool FEnabled;
	bool FEof;
	bool FOpenDataSource;
	TfrxRangeBegin FRangeBegin;
	TfrxRangeEnd FRangeEnd;
	int FRangeEndCount;
	TfrxReport* FReportRef;
	System::UnicodeString FUserName;
	TfrxCheckEOFEvent FOnCheckEOF;
	Classes::TNotifyEvent FOnFirst;
	Classes::TNotifyEvent FOnNext;
	Classes::TNotifyEvent FOnPrior;
	Classes::TNotifyEvent FOnOpen;
	Classes::TNotifyEvent FOnClose;
	
protected:
	bool FInitialized;
	int FRecNo;
	virtual System::WideString __fastcall GetDisplayText(System::UnicodeString Index);
	virtual int __fastcall GetDisplayWidth(System::UnicodeString Index);
	virtual TfrxFieldType __fastcall GetFieldType(System::UnicodeString Index);
	virtual System::Variant __fastcall GetValue(System::UnicodeString Index);
	virtual void __fastcall SetName(const Classes::TComponentName NewName);
	virtual void __fastcall SetUserName(const System::UnicodeString Value);
	
public:
	__fastcall virtual TfrxDataSet(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDataSet(void);
	virtual void __fastcall Initialize(void);
	virtual void __fastcall Finalize(void);
	virtual void __fastcall Open(void);
	virtual void __fastcall Close(void);
	virtual void __fastcall First(void);
	virtual void __fastcall Next(void);
	virtual void __fastcall Prior(void);
	virtual bool __fastcall Eof(void);
	virtual int __fastcall FieldsCount(void);
	bool __fastcall HasField(const System::UnicodeString fName);
	virtual bool __fastcall IsBlobField(const System::UnicodeString fName);
	virtual int __fastcall RecordCount(void);
	virtual void __fastcall AssignBlobTo(const System::UnicodeString fName, System::TObject* Obj);
	virtual void __fastcall GetFieldList(Classes::TStrings* List);
	__property System::WideString DisplayText[System::UnicodeString Index] = {read=GetDisplayText};
	__property int DisplayWidth[System::UnicodeString Index] = {read=GetDisplayWidth};
	__property TfrxFieldType FieldType[System::UnicodeString Index] = {read=GetFieldType};
	__property System::Variant Value[System::UnicodeString Index] = {read=GetValue};
	__property bool CloseDataSource = {read=FCloseDataSource, write=FCloseDataSource, nodefault};
	__property bool OpenDataSource = {read=FOpenDataSource, write=FOpenDataSource, default=1};
	__property int RecNo = {read=FRecNo, nodefault};
	__property TfrxReport* ReportRef = {read=FReportRef, write=FReportRef};
	__property Classes::TNotifyEvent OnClose = {read=FOnClose, write=FOnClose};
	__property Classes::TNotifyEvent OnOpen = {read=FOnOpen, write=FOnOpen};
	
__published:
	__property bool Enabled = {read=FEnabled, write=FEnabled, default=1};
	__property TfrxRangeBegin RangeBegin = {read=FRangeBegin, write=FRangeBegin, default=0};
	__property TfrxRangeEnd RangeEnd = {read=FRangeEnd, write=FRangeEnd, default=0};
	__property int RangeEndCount = {read=FRangeEndCount, write=FRangeEndCount, default=0};
	__property System::UnicodeString UserName = {read=FUserName, write=SetUserName};
	__property TfrxCheckEOFEvent OnCheckEOF = {read=FOnCheckEOF, write=FOnCheckEOF};
	__property Classes::TNotifyEvent OnFirst = {read=FOnFirst, write=FOnFirst};
	__property Classes::TNotifyEvent OnNext = {read=FOnNext, write=FOnNext};
	__property Classes::TNotifyEvent OnPrior = {read=FOnPrior, write=FOnPrior};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDataSet(Classes::TComponent* AOwner, System::Word Flags) : TfrxDialogComponent(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxUserDataSet;
class PASCALIMPLEMENTATION TfrxUserDataSet : public TfrxDataSet
{
	typedef TfrxDataSet inherited;
	
private:
	Classes::TStrings* FFields;
	TfrxGetValueEvent FOnGetValue;
	TfrxNewGetValueEvent FOnNewGetValue;
	void __fastcall SetFields(const Classes::TStrings* Value);
	
protected:
	virtual System::WideString __fastcall GetDisplayText(System::UnicodeString Index);
	virtual System::Variant __fastcall GetValue(System::UnicodeString Index);
	
public:
	__fastcall virtual TfrxUserDataSet(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxUserDataSet(void);
	virtual int __fastcall FieldsCount(void);
	virtual void __fastcall GetFieldList(Classes::TStrings* List);
	
__published:
	__property Classes::TStrings* Fields = {read=FFields, write=SetFields};
	__property TfrxGetValueEvent OnGetValue = {read=FOnGetValue, write=FOnGetValue};
	__property TfrxNewGetValueEvent OnNewGetValue = {read=FOnNewGetValue, write=FOnNewGetValue};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxUserDataSet(Classes::TComponent* AOwner, System::Word Flags) : TfrxDataSet(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxCustomDBDataSet;
class PASCALIMPLEMENTATION TfrxCustomDBDataSet : public TfrxDataSet
{
	typedef TfrxDataSet inherited;
	
private:
	Classes::TStrings* FAliases;
	Classes::TStringList* FFields;
	void __fastcall SetFieldAliases(const Classes::TStrings* Value);
	
protected:
	__property Classes::TStringList* Fields = {read=FFields};
	
public:
	__fastcall virtual TfrxCustomDBDataSet(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxCustomDBDataSet(void);
	System::UnicodeString __fastcall ConvertAlias(const System::UnicodeString fName);
	System::UnicodeString __fastcall GetAlias(const System::UnicodeString fName);
	virtual int __fastcall FieldsCount(void);
	
__published:
	__property CloseDataSource;
	__property Classes::TStrings* FieldAliases = {read=FAliases, write=SetFieldAliases};
	__property OpenDataSource = {default=1};
	__property OnClose;
	__property OnOpen;
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCustomDBDataSet(Classes::TComponent* AOwner, System::Word Flags) : TfrxDataSet(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDBComponents;
class PASCALIMPLEMENTATION TfrxDBComponents : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
public:
	virtual System::UnicodeString __fastcall GetDescription(void);
public:
	/* TComponent.Create */ inline __fastcall virtual TfrxDBComponents(Classes::TComponent* AOwner) : Classes::TComponent(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxDBComponents(void) { }
	
};


class PASCALIMPLEMENTATION TfrxCustomDatabase : public TfrxDialogComponent
{
	typedef TfrxDialogComponent inherited;
	
protected:
	void __fastcall BeforeConnect(bool &Value);
	void __fastcall AfterDisconnect(void);
	virtual void __fastcall SetConnected(bool Value);
	virtual void __fastcall SetDatabaseName(const System::UnicodeString Value);
	virtual void __fastcall SetLoginPrompt(bool Value);
	virtual void __fastcall SetParams(Classes::TStrings* Value);
	virtual bool __fastcall GetConnected(void);
	virtual System::UnicodeString __fastcall GetDatabaseName(void);
	virtual bool __fastcall GetLoginPrompt(void);
	virtual Classes::TStrings* __fastcall GetParams(void);
	
public:
	HIDESBASE virtual System::WideString __fastcall ToString(void);
	virtual void __fastcall FromString(const System::WideString Connection);
	virtual void __fastcall SetLogin(const System::UnicodeString Login, const System::UnicodeString Password);
	__property bool Connected = {read=GetConnected, write=SetConnected, default=0};
	__property System::UnicodeString DatabaseName = {read=GetDatabaseName, write=SetDatabaseName};
	__property bool LoginPrompt = {read=GetLoginPrompt, write=SetLoginPrompt, default=1};
	__property Classes::TStrings* Params = {read=GetParams, write=SetParams};
public:
	/* TfrxDialogComponent.Create */ inline __fastcall virtual TfrxCustomDatabase(Classes::TComponent* AOwner) : TfrxDialogComponent(AOwner) { }
	/* TfrxDialogComponent.Destroy */ inline __fastcall virtual ~TfrxCustomDatabase(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCustomDatabase(Classes::TComponent* AOwner, System::Word Flags) : TfrxDialogComponent(AOwner, Flags) { }
	
};


typedef TMetaClass* TfrxComponentClass;

class DELPHICLASS TfrxFrameLine;
class DELPHICLASS TfrxFrame;
class PASCALIMPLEMENTATION TfrxFrameLine : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	TfrxFrame* FFrame;
	Graphics::TColor FColor;
	TfrxFrameStyle FStyle;
	System::Extended FWidth;
	bool __fastcall IsColorStored(void);
	bool __fastcall IsStyleStored(void);
	bool __fastcall IsWidthStored(void);
	
public:
	__fastcall TfrxFrameLine(TfrxFrame* AFrame);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	System::UnicodeString __fastcall Diff(TfrxFrameLine* ALine, const System::UnicodeString LineName, bool ColorChanged, bool StyleChanged, bool WidthChanged);
	
__published:
	__property Graphics::TColor Color = {read=FColor, write=FColor, stored=IsColorStored, nodefault};
	__property TfrxFrameStyle Style = {read=FStyle, write=FStyle, stored=IsStyleStored, nodefault};
	__property System::Extended Width = {read=FWidth, write=FWidth, stored=IsWidthStored};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxFrameLine(void) { }
	
};


class PASCALIMPLEMENTATION TfrxFrame : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	TfrxFrameLine* FLeftLine;
	TfrxFrameLine* FTopLine;
	TfrxFrameLine* FRightLine;
	TfrxFrameLine* FBottomLine;
	Graphics::TColor FColor;
	bool FDropShadow;
	System::Extended FShadowWidth;
	Graphics::TColor FShadowColor;
	TfrxFrameStyle FStyle;
	TfrxFrameTypes FTyp;
	System::Extended FWidth;
	bool __fastcall IsShadowWidthStored(void);
	bool __fastcall IsTypStored(void);
	bool __fastcall IsWidthStored(void);
	void __fastcall SetBottomLine(const TfrxFrameLine* Value);
	void __fastcall SetLeftLine(const TfrxFrameLine* Value);
	void __fastcall SetRightLine(const TfrxFrameLine* Value);
	void __fastcall SetTopLine(const TfrxFrameLine* Value);
	void __fastcall SetColor(const Graphics::TColor Value);
	void __fastcall SetStyle(const TfrxFrameStyle Value);
	void __fastcall SetWidth(const System::Extended Value);
	
public:
	__fastcall TfrxFrame(void);
	__fastcall virtual ~TfrxFrame(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	System::UnicodeString __fastcall Diff(TfrxFrame* AFrame);
	
__published:
	__property Graphics::TColor Color = {read=FColor, write=SetColor, default=0};
	__property bool DropShadow = {read=FDropShadow, write=FDropShadow, default=0};
	__property Graphics::TColor ShadowColor = {read=FShadowColor, write=FShadowColor, default=0};
	__property System::Extended ShadowWidth = {read=FShadowWidth, write=FShadowWidth, stored=IsShadowWidthStored};
	__property TfrxFrameStyle Style = {read=FStyle, write=SetStyle, default=0};
	__property TfrxFrameTypes Typ = {read=FTyp, write=FTyp, stored=IsTypStored, nodefault};
	__property System::Extended Width = {read=FWidth, write=SetWidth, stored=IsWidthStored};
	__property TfrxFrameLine* LeftLine = {read=FLeftLine, write=SetLeftLine};
	__property TfrxFrameLine* TopLine = {read=FTopLine, write=SetTopLine};
	__property TfrxFrameLine* RightLine = {read=FRightLine, write=SetRightLine};
	__property TfrxFrameLine* BottomLine = {read=FBottomLine, write=SetBottomLine};
};


class PASCALIMPLEMENTATION TfrxView : public TfrxReportComponent
{
	typedef TfrxReportComponent inherited;
	
private:
	TfrxAlign FAlign;
	Graphics::TBrushStyle FBrushStyle;
	Graphics::TColor FColor;
	Controls::TCursor FCursor;
	System::UnicodeString FDataField;
	TfrxDataSet* FDataSet;
	System::UnicodeString FDataSetName;
	TfrxFrame* FFrame;
	bool FPrintable;
	TfrxShiftMode FShiftMode;
	System::UnicodeString FTagStr;
	System::UnicodeString FTempTag;
	System::UnicodeString FTempURL;
	System::UnicodeString FHint;
	bool FShowHint;
	System::UnicodeString FURL;
	bool FPlainText;
	void __fastcall SetFrame(const TfrxFrame* Value);
	void __fastcall SetDataSet(const TfrxDataSet* Value);
	void __fastcall SetDataSetName(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetDataSetName(void);
	
protected:
	int FX;
	int FY;
	int FX1;
	int FY1;
	int FDX;
	int FDY;
	int FFrameWidth;
	System::Extended FScaleX;
	System::Extended FScaleY;
	System::Extended FOffsetX;
	System::Extended FOffsetY;
	Graphics::TCanvas* FCanvas;
	virtual void __fastcall BeginDraw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall DrawBackground(void);
	virtual void __fastcall DrawFrame(void);
	void __fastcall DrawLine(int x, int y, int x1, int y1, int w);
	void __fastcall ExpandVariables(System::UnicodeString &Expr);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	
public:
	__fastcall virtual TfrxView(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxView(void);
	virtual System::UnicodeString __fastcall Diff(TfrxComponent* AComponent);
	bool __fastcall IsDataField(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall BeforePrint(void);
	virtual void __fastcall GetData(void);
	virtual void __fastcall AfterPrint(void);
	__property Graphics::TBrushStyle BrushStyle = {read=FBrushStyle, write=FBrushStyle, default=0};
	__property Graphics::TColor Color = {read=FColor, write=FColor, default=536870911};
	__property System::UnicodeString DataField = {read=FDataField, write=FDataField};
	__property TfrxDataSet* DataSet = {read=FDataSet, write=SetDataSet};
	__property System::UnicodeString DataSetName = {read=GetDataSetName, write=SetDataSetName};
	__property TfrxFrame* Frame = {read=FFrame, write=SetFrame};
	__property bool PlainText = {read=FPlainText, write=FPlainText, nodefault};
	__property Controls::TCursor Cursor = {read=FCursor, write=FCursor, default=0};
	__property System::UnicodeString TagStr = {read=FTagStr, write=FTagStr};
	__property System::UnicodeString URL = {read=FURL, write=FURL};
	
__published:
	__property TfrxAlign Align = {read=FAlign, write=FAlign, default=0};
	__property bool Printable = {read=FPrintable, write=FPrintable, default=1};
	__property TfrxShiftMode ShiftMode = {read=FShiftMode, write=FShiftMode, default=1};
	__property Left;
	__property Top;
	__property Width;
	__property Height;
	__property GroupIndex = {default=0};
	__property Restrictions = {default=0};
	__property Visible = {default=1};
	__property OnAfterData;
	__property OnAfterPrint;
	__property OnBeforePrint;
	__property OnPreviewClick;
	__property OnPreviewDblClick;
	__property System::UnicodeString Hint = {read=FHint, write=FHint};
	__property bool ShowHint = {read=FShowHint, write=FShowHint, nodefault};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxView(Classes::TComponent* AOwner, System::Word Flags) : TfrxReportComponent(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxStretcheable;
class PASCALIMPLEMENTATION TfrxStretcheable : public TfrxView
{
	typedef TfrxView inherited;
	
private:
	TfrxStretchMode FStretchMode;
	
public:
	System::Extended FSaveHeight;
	System::Extended FSavedTop;
	__fastcall virtual TfrxStretcheable(Classes::TComponent* AOwner);
	virtual System::Extended __fastcall CalcHeight(void);
	virtual System::Extended __fastcall DrawPart(void);
	virtual void __fastcall InitPart(void);
	virtual bool __fastcall HasNextDataPart(void);
	
__published:
	__property TfrxStretchMode StretchMode = {read=FStretchMode, write=FStretchMode, default=0};
public:
	/* TfrxView.Destroy */ inline __fastcall virtual ~TfrxStretcheable(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxStretcheable(Classes::TComponent* AOwner, System::Word Flags) : TfrxView(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxHighlight;
class PASCALIMPLEMENTATION TfrxHighlight : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	bool FActive;
	Graphics::TColor FColor;
	System::UnicodeString FCondition;
	Graphics::TFont* FFont;
	void __fastcall SetFont(const Graphics::TFont* Value);
	
public:
	__fastcall TfrxHighlight(void);
	__fastcall virtual ~TfrxHighlight(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property bool Active = {read=FActive, write=FActive, default=0};
	__property Graphics::TFont* Font = {read=FFont, write=SetFont};
	__property Graphics::TColor Color = {read=FColor, write=FColor, default=536870911};
	__property System::UnicodeString Condition = {read=FCondition, write=FCondition};
};


class DELPHICLASS TfrxFormat;
class PASCALIMPLEMENTATION TfrxFormat : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::UnicodeString FDecimalSeparator;
	System::UnicodeString FThousandSeparator;
	System::UnicodeString FFormatStr;
	TfrxFormatKind FKind;
	
public:
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property System::UnicodeString DecimalSeparator = {read=FDecimalSeparator, write=FDecimalSeparator};
	__property System::UnicodeString ThousandSeparator = {read=FThousandSeparator, write=FThousandSeparator};
	__property System::UnicodeString FormatStr = {read=FFormatStr, write=FFormatStr};
	__property TfrxFormatKind Kind = {read=FKind, write=FKind, default=0};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxFormat(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TfrxFormat(void) : Classes::TPersistent() { }
	
};


class DELPHICLASS TfrxCustomMemoView;
class DELPHICLASS TfrxStyleItem;
class PASCALIMPLEMENTATION TfrxCustomMemoView : public TfrxStretcheable
{
	typedef TfrxStretcheable inherited;
	
private:
	bool FAllowExpressions;
	bool FAllowHTMLTags;
	bool FAutoWidth;
	System::Extended FCharSpacing;
	bool FClipped;
	TfrxFormat* FDisplayFormat;
	System::UnicodeString FExpressionDelimiters;
	TfrxCustomMemoView* FFlowTo;
	bool FFirstParaBreak;
	System::Extended FGapX;
	System::Extended FGapY;
	TfrxHAlign FHAlign;
	bool FHideZeros;
	TfrxHighlight* FHighlight;
	bool FLastParaBreak;
	System::Extended FLineSpacing;
	Widestrings::TWideStrings* FMemo;
	System::Extended FParagraphGap;
	System::WideString FPartMemo;
	int FRotation;
	bool FRTLReading;
	System::UnicodeString FStyle;
	bool FSuppressRepeated;
	System::WideString FTempMemo;
	bool FUnderlines;
	TfrxVAlign FVAlign;
	System::Variant FValue;
	bool FWordBreak;
	bool FWordWrap;
	bool FWysiwyg;
	bool FUseDefaultCharset;
	void __fastcall SetMemo(const Widestrings::TWideStrings* Value);
	void __fastcall SetRotation(int Value);
	void __fastcall SetText(const System::WideString Value);
	void __fastcall SetAnsiText(const System::AnsiString Value);
	System::Extended __fastcall AdjustCalcHeight(void);
	System::Extended __fastcall AdjustCalcWidth(void);
	System::WideString __fastcall GetText(void);
	System::AnsiString __fastcall GetAnsiText(void);
	bool __fastcall IsExprDelimitersStored(void);
	bool __fastcall IsLineSpacingStored(void);
	bool __fastcall IsGapXStored(void);
	bool __fastcall IsGapYStored(void);
	bool __fastcall IsHighlightStored(void);
	bool __fastcall IsParagraphGapStored(void);
	void __fastcall SetHighlight(const TfrxHighlight* Value);
	void __fastcall SetDisplayFormat(const TfrxFormat* Value);
	void __fastcall SetStyle(const System::UnicodeString Value);
	bool __fastcall IsCharSpacingStored(void);
	
protected:
	System::Variant FLastValue;
	int FTotalPages;
	int FCopyNo;
	Types::TRect FTextRect;
	System::Extended FPrintScale;
	System::WideString __fastcall CalcAndFormat(const System::WideString Expr);
	virtual void __fastcall BeginDraw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	void __fastcall SetDrawParams(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	
public:
	__fastcall virtual TfrxCustomMemoView(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxCustomMemoView(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual System::UnicodeString __fastcall Diff(TfrxComponent* AComponent);
	virtual System::Extended __fastcall CalcHeight(void);
	virtual System::Extended __fastcall CalcWidth(void);
	virtual System::Extended __fastcall DrawPart(void);
	virtual System::UnicodeString __fastcall GetComponentText(void);
	System::WideString __fastcall FormatData(const System::Variant &Value, TfrxFormat* AFormat = (TfrxFormat*)(0x0));
	System::WideString __fastcall WrapText(bool WrapWords);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall BeforePrint(void);
	virtual void __fastcall GetData(void);
	virtual void __fastcall AfterPrint(void);
	virtual void __fastcall InitPart(void);
	void __fastcall ApplyStyle(TfrxStyleItem* Style);
	void __fastcall ExtractMacros(void);
	void __fastcall ResetSuppress(void);
	__property System::WideString Text = {read=GetText, write=SetText};
	__property System::AnsiString AnsiText = {read=GetAnsiText, write=SetAnsiText};
	__property System::Variant Value = {read=FValue, write=FValue};
	__property Widestrings::TWideStrings* Lines = {read=FMemo, write=SetMemo};
	__property bool AllowExpressions = {read=FAllowExpressions, write=FAllowExpressions, default=1};
	__property bool AllowHTMLTags = {read=FAllowHTMLTags, write=FAllowHTMLTags, default=0};
	__property bool AutoWidth = {read=FAutoWidth, write=FAutoWidth, default=0};
	__property System::Extended CharSpacing = {read=FCharSpacing, write=FCharSpacing, stored=IsCharSpacingStored};
	__property bool Clipped = {read=FClipped, write=FClipped, default=1};
	__property TfrxFormat* DisplayFormat = {read=FDisplayFormat, write=SetDisplayFormat};
	__property System::UnicodeString ExpressionDelimiters = {read=FExpressionDelimiters, write=FExpressionDelimiters, stored=IsExprDelimitersStored};
	__property TfrxCustomMemoView* FlowTo = {read=FFlowTo, write=FFlowTo};
	__property System::Extended GapX = {read=FGapX, write=FGapX, stored=IsGapXStored};
	__property System::Extended GapY = {read=FGapY, write=FGapY, stored=IsGapYStored};
	__property TfrxHAlign HAlign = {read=FHAlign, write=FHAlign, default=0};
	__property bool HideZeros = {read=FHideZeros, write=FHideZeros, default=0};
	__property TfrxHighlight* Highlight = {read=FHighlight, write=SetHighlight, stored=IsHighlightStored};
	__property System::Extended LineSpacing = {read=FLineSpacing, write=FLineSpacing, stored=IsLineSpacingStored};
	__property Widestrings::TWideStrings* Memo = {read=FMemo, write=SetMemo};
	__property System::Extended ParagraphGap = {read=FParagraphGap, write=FParagraphGap, stored=IsParagraphGapStored};
	__property int Rotation = {read=FRotation, write=SetRotation, default=0};
	__property bool RTLReading = {read=FRTLReading, write=FRTLReading, default=0};
	__property System::UnicodeString Style = {read=FStyle, write=SetStyle};
	__property bool SuppressRepeated = {read=FSuppressRepeated, write=FSuppressRepeated, default=0};
	__property bool Underlines = {read=FUnderlines, write=FUnderlines, default=0};
	__property bool WordBreak = {read=FWordBreak, write=FWordBreak, default=0};
	__property bool WordWrap = {read=FWordWrap, write=FWordWrap, default=1};
	__property bool Wysiwyg = {read=FWysiwyg, write=FWysiwyg, default=1};
	__property TfrxVAlign VAlign = {read=FVAlign, write=FVAlign, default=0};
	__property bool UseDefaultCharset = {read=FUseDefaultCharset, write=FUseDefaultCharset, default=0};
	
__published:
	__property bool FirstParaBreak = {read=FFirstParaBreak, write=FFirstParaBreak, default=0};
	__property bool LastParaBreak = {read=FLastParaBreak, write=FLastParaBreak, default=0};
	__property Cursor = {default=0};
	__property TagStr;
	__property URL;
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxCustomMemoView(Classes::TComponent* AOwner, System::Word Flags) : TfrxStretcheable(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxMemoView;
class PASCALIMPLEMENTATION TfrxMemoView : public TfrxCustomMemoView
{
	typedef TfrxCustomMemoView inherited;
	
__published:
	__property AutoWidth = {default=0};
	__property AllowExpressions = {default=1};
	__property AllowHTMLTags = {default=0};
	__property BrushStyle = {default=0};
	__property CharSpacing;
	__property Clipped = {default=1};
	__property Color = {default=536870911};
	__property DataField;
	__property DataSet;
	__property DataSetName;
	__property DisplayFormat;
	__property ExpressionDelimiters;
	__property FlowTo;
	__property Font;
	__property Frame;
	__property GapX;
	__property GapY;
	__property HAlign = {default=0};
	__property HideZeros = {default=0};
	__property Highlight;
	__property LineSpacing;
	__property Memo;
	__property ParagraphGap;
	__property ParentFont = {default=1};
	__property Rotation = {default=0};
	__property RTLReading = {default=0};
	__property Style;
	__property SuppressRepeated = {default=0};
	__property Underlines = {default=0};
	__property UseDefaultCharset = {default=0};
	__property WordBreak = {default=0};
	__property WordWrap = {default=1};
	__property Wysiwyg = {default=1};
	__property VAlign = {default=0};
public:
	/* TfrxCustomMemoView.Create */ inline __fastcall virtual TfrxMemoView(Classes::TComponent* AOwner) : TfrxCustomMemoView(AOwner) { }
	/* TfrxCustomMemoView.Destroy */ inline __fastcall virtual ~TfrxMemoView(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxMemoView(Classes::TComponent* AOwner, System::Word Flags) : TfrxCustomMemoView(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxSysMemoView;
class PASCALIMPLEMENTATION TfrxSysMemoView : public TfrxCustomMemoView
{
	typedef TfrxCustomMemoView inherited;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property AutoWidth = {default=0};
	__property BrushStyle = {default=0};
	__property CharSpacing;
	__property Color = {default=536870911};
	__property DisplayFormat;
	__property Font;
	__property Frame;
	__property GapX;
	__property GapY;
	__property HAlign = {default=0};
	__property HideZeros = {default=0};
	__property Highlight;
	__property Memo;
	__property ParentFont = {default=1};
	__property Rotation = {default=0};
	__property RTLReading = {default=0};
	__property Style;
	__property SuppressRepeated = {default=0};
	__property VAlign = {default=0};
	__property WordWrap = {default=1};
public:
	/* TfrxCustomMemoView.Create */ inline __fastcall virtual TfrxSysMemoView(Classes::TComponent* AOwner) : TfrxCustomMemoView(AOwner) { }
	/* TfrxCustomMemoView.Destroy */ inline __fastcall virtual ~TfrxSysMemoView(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxSysMemoView(Classes::TComponent* AOwner, System::Word Flags) : TfrxCustomMemoView(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxCustomLineView;
class PASCALIMPLEMENTATION TfrxCustomLineView : public TfrxStretcheable
{
	typedef TfrxStretcheable inherited;
	
private:
	bool FDiagonal;
	bool FArrowEnd;
	int FArrowLength;
	bool FArrowSolid;
	bool FArrowStart;
	int FArrowWidth;
	void __fastcall DrawArrow(System::Extended x1, System::Extended y1, System::Extended x2, System::Extended y2);
	void __fastcall DrawDiagonalLine(void);
	
public:
	__fastcall virtual TfrxCustomLineView(Classes::TComponent* AOwner);
	__fastcall virtual TfrxCustomLineView(Classes::TComponent* AOwner, System::Word Flags);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	__property bool ArrowEnd = {read=FArrowEnd, write=FArrowEnd, default=0};
	__property int ArrowLength = {read=FArrowLength, write=FArrowLength, default=20};
	__property bool ArrowSolid = {read=FArrowSolid, write=FArrowSolid, default=0};
	__property bool ArrowStart = {read=FArrowStart, write=FArrowStart, default=0};
	__property int ArrowWidth = {read=FArrowWidth, write=FArrowWidth, default=5};
	__property bool Diagonal = {read=FDiagonal, write=FDiagonal, default=0};
	
__published:
	__property TagStr;
public:
	/* TfrxView.Destroy */ inline __fastcall virtual ~TfrxCustomLineView(void) { }
	
};


class DELPHICLASS TfrxLineView;
class PASCALIMPLEMENTATION TfrxLineView : public TfrxCustomLineView
{
	typedef TfrxCustomLineView inherited;
	
public:
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property ArrowEnd = {default=0};
	__property ArrowLength = {default=20};
	__property ArrowSolid = {default=0};
	__property ArrowStart = {default=0};
	__property ArrowWidth = {default=5};
	__property Frame;
	__property Diagonal = {default=0};
public:
	/* TfrxCustomLineView.Create */ inline __fastcall virtual TfrxLineView(Classes::TComponent* AOwner) : TfrxCustomLineView(AOwner) { }
	/* TfrxCustomLineView.DesignCreate */ inline __fastcall virtual TfrxLineView(Classes::TComponent* AOwner, System::Word Flags) : TfrxCustomLineView(AOwner, Flags) { }
	
public:
	/* TfrxView.Destroy */ inline __fastcall virtual ~TfrxLineView(void) { }
	
};


class DELPHICLASS TfrxPictureView;
class PASCALIMPLEMENTATION TfrxPictureView : public TfrxView
{
	typedef TfrxView inherited;
	
private:
	bool FAutoSize;
	bool FCenter;
	System::UnicodeString FFileLink;
	int FImageIndex;
	bool FIsImageIndexStored;
	bool FIsPictureStored;
	bool FKeepAspectRatio;
	Graphics::TPicture* FPicture;
	bool FPictureChanged;
	bool FStretched;
	bool FHightQuality;
	bool FTransparent;
	Graphics::TColor FTransparentColor;
	void __fastcall SetPicture(const Graphics::TPicture* Value);
	void __fastcall PictureChanged(System::TObject* Sender);
	void __fastcall SetAutoSize(const bool Value);
	void __fastcall SetTransparent(const bool Value);
	
public:
	__fastcall virtual TfrxPictureView(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxPictureView(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual System::UnicodeString __fastcall Diff(TfrxComponent* AComponent);
	HRESULT __fastcall LoadPictureFromStream(Classes::TStream* s, bool ResetStreamPos = true);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall GetData(void);
	__property bool IsImageIndexStored = {read=FIsImageIndexStored, write=FIsImageIndexStored, nodefault};
	__property bool IsPictureStored = {read=FIsPictureStored, write=FIsPictureStored, nodefault};
	
__published:
	__property Cursor = {default=0};
	__property bool AutoSize = {read=FAutoSize, write=SetAutoSize, default=0};
	__property bool Center = {read=FCenter, write=FCenter, default=0};
	__property DataField;
	__property DataSet;
	__property DataSetName;
	__property Frame;
	__property System::UnicodeString FileLink = {read=FFileLink, write=FFileLink};
	__property int ImageIndex = {read=FImageIndex, write=FImageIndex, stored=FIsImageIndexStored, nodefault};
	__property bool KeepAspectRatio = {read=FKeepAspectRatio, write=FKeepAspectRatio, default=1};
	__property Graphics::TPicture* Picture = {read=FPicture, write=SetPicture, stored=FIsPictureStored};
	__property bool Stretched = {read=FStretched, write=FStretched, default=1};
	__property TagStr;
	__property URL;
	__property bool HightQuality = {read=FHightQuality, write=FHightQuality, nodefault};
	__property bool Transparent = {read=FTransparent, write=SetTransparent, nodefault};
	__property Graphics::TColor TransparentColor = {read=FTransparentColor, write=FTransparentColor, nodefault};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxPictureView(Classes::TComponent* AOwner, System::Word Flags) : TfrxView(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxShapeView;
class PASCALIMPLEMENTATION TfrxShapeView : public TfrxView
{
	typedef TfrxView inherited;
	
private:
	int FCurve;
	TfrxShapeKind FShape;
	
public:
	__fastcall virtual TfrxShapeView(Classes::TComponent* AOwner);
	__fastcall virtual TfrxShapeView(Classes::TComponent* AOwner, System::Word Flags);
	virtual System::UnicodeString __fastcall Diff(TfrxComponent* AComponent);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property BrushStyle = {default=0};
	__property Color = {default=536870911};
	__property Cursor = {default=0};
	__property int Curve = {read=FCurve, write=FCurve, default=0};
	__property Frame;
	__property TfrxShapeKind Shape = {read=FShape, write=FShape, default=0};
	__property TagStr;
	__property URL;
public:
	/* TfrxView.Destroy */ inline __fastcall virtual ~TfrxShapeView(void) { }
	
};


class DELPHICLASS TfrxSubreport;
class PASCALIMPLEMENTATION TfrxSubreport : public TfrxView
{
	typedef TfrxView inherited;
	
private:
	TfrxReportPage* FPage;
	bool FPrintOnParent;
	void __fastcall SetPage(const TfrxReportPage* Value);
	
public:
	__fastcall virtual TfrxSubreport(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxSubreport(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property TfrxReportPage* Page = {read=FPage, write=SetPage};
	__property bool PrintOnParent = {read=FPrintOnParent, write=FPrintOnParent, default=0};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxSubreport(Classes::TComponent* AOwner, System::Word Flags) : TfrxView(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxBand;
class DELPHICLASS TfrxChild;
class PASCALIMPLEMENTATION TfrxBand : public TfrxReportComponent
{
	typedef TfrxReportComponent inherited;
	
private:
	bool FAllowSplit;
	TfrxChild* FChild;
	bool FKeepChild;
	TfrxNotifyEvent FOnAfterCalcHeight;
	System::UnicodeString FOutlineText;
	bool FOverflow;
	bool FStartNewPage;
	bool FStretched;
	bool FPrintChildIfInvisible;
	bool FVertical;
	System::UnicodeString __fastcall GetBandName(void);
	void __fastcall SetChild(TfrxChild* Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetLeft(System::Extended Value);
	virtual void __fastcall SetTop(System::Extended Value);
	virtual void __fastcall SetHeight(System::Extended Value);
	
public:
	Classes::TList* FSubBands;
	TfrxBand* FHeader;
	TfrxBand* FFooter;
	TfrxBand* FGroup;
	int FLineN;
	int FLineThrough;
	int FOriginalObjectsCount;
	bool FHasVBands;
	System::Extended FStretchedHeight;
	__fastcall virtual TfrxBand(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxBand(void);
	int __fastcall BandNumber(void);
	virtual void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property bool AllowSplit = {read=FAllowSplit, write=FAllowSplit, default=0};
	__property System::UnicodeString BandName = {read=GetBandName};
	__property TfrxChild* Child = {read=FChild, write=SetChild};
	__property bool KeepChild = {read=FKeepChild, write=FKeepChild, default=0};
	__property System::UnicodeString OutlineText = {read=FOutlineText, write=FOutlineText};
	__property bool Overflow = {read=FOverflow, write=FOverflow, nodefault};
	__property bool PrintChildIfInvisible = {read=FPrintChildIfInvisible, write=FPrintChildIfInvisible, default=0};
	__property bool StartNewPage = {read=FStartNewPage, write=FStartNewPage, default=0};
	__property bool Stretched = {read=FStretched, write=FStretched, default=0};
	
__published:
	__property Font;
	__property Height;
	__property Left;
	__property ParentFont = {default=1};
	__property Restrictions = {default=0};
	__property Top;
	__property bool Vertical = {read=FVertical, write=FVertical, default=0};
	__property Visible = {default=1};
	__property Width;
	__property TfrxNotifyEvent OnAfterCalcHeight = {read=FOnAfterCalcHeight, write=FOnAfterCalcHeight};
	__property OnAfterPrint;
	__property OnBeforePrint;
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxBand(Classes::TComponent* AOwner, System::Word Flags) : TfrxReportComponent(AOwner, Flags) { }
	
};


typedef TMetaClass* TfrxBandClass;

class DELPHICLASS TfrxDataBand;
class PASCALIMPLEMENTATION TfrxDataBand : public TfrxBand
{
	typedef TfrxBand inherited;
	
private:
	System::Extended FColumnGap;
	System::Extended FColumnWidth;
	int FColumns;
	int FCurColumn;
	TfrxDataSet* FDataSet;
	System::UnicodeString FDataSetName;
	bool FFooterAfterEach;
	bool FKeepFooter;
	bool FKeepHeader;
	bool FKeepTogether;
	bool FPrintIfDetailEmpty;
	int FRowCount;
	TfrxNotifyEvent FOnMasterDetail;
	TfrxUserDataSet* FVirtualDataSet;
	void __fastcall SetCurColumn(int Value);
	void __fastcall SetRowCount(const int Value);
	void __fastcall SetDataSet(const TfrxDataSet* Value);
	void __fastcall SetDataSetName(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetDataSetName(void);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	
public:
	System::Extended FMaxY;
	__fastcall virtual TfrxDataBand(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDataBand(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	__property int CurColumn = {read=FCurColumn, write=SetCurColumn, nodefault};
	__property TfrxUserDataSet* VirtualDataSet = {read=FVirtualDataSet};
	
__published:
	__property AllowSplit = {default=0};
	__property Child;
	__property int Columns = {read=FColumns, write=FColumns, default=0};
	__property System::Extended ColumnWidth = {read=FColumnWidth, write=FColumnWidth};
	__property System::Extended ColumnGap = {read=FColumnGap, write=FColumnGap};
	__property TfrxDataSet* DataSet = {read=FDataSet, write=SetDataSet};
	__property System::UnicodeString DataSetName = {read=GetDataSetName, write=SetDataSetName};
	__property bool FooterAfterEach = {read=FFooterAfterEach, write=FFooterAfterEach, default=0};
	__property KeepChild = {default=0};
	__property bool KeepFooter = {read=FKeepFooter, write=FKeepFooter, default=0};
	__property bool KeepHeader = {read=FKeepHeader, write=FKeepHeader, default=0};
	__property bool KeepTogether = {read=FKeepTogether, write=FKeepTogether, default=0};
	__property OutlineText;
	__property PrintChildIfInvisible = {default=0};
	__property bool PrintIfDetailEmpty = {read=FPrintIfDetailEmpty, write=FPrintIfDetailEmpty, default=0};
	__property int RowCount = {read=FRowCount, write=SetRowCount, nodefault};
	__property StartNewPage = {default=0};
	__property Stretched = {default=0};
	__property TfrxNotifyEvent OnMasterDetail = {read=FOnMasterDetail, write=FOnMasterDetail};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDataBand(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxHeader;
class PASCALIMPLEMENTATION TfrxHeader : public TfrxBand
{
	typedef TfrxBand inherited;
	
private:
	bool FReprintOnNewPage;
	
__published:
	__property AllowSplit = {default=0};
	__property Child;
	__property KeepChild = {default=0};
	__property PrintChildIfInvisible = {default=0};
	__property bool ReprintOnNewPage = {read=FReprintOnNewPage, write=FReprintOnNewPage, default=0};
	__property StartNewPage = {default=0};
	__property Stretched = {default=0};
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxHeader(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxHeader(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxHeader(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxFooter;
class PASCALIMPLEMENTATION TfrxFooter : public TfrxBand
{
	typedef TfrxBand inherited;
	
__published:
	__property AllowSplit = {default=0};
	__property Child;
	__property KeepChild = {default=0};
	__property PrintChildIfInvisible = {default=0};
	__property Stretched = {default=0};
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxFooter(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxFooter(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxFooter(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxMasterData;
class PASCALIMPLEMENTATION TfrxMasterData : public TfrxDataBand
{
	typedef TfrxDataBand inherited;
	
public:
	/* TfrxDataBand.Create */ inline __fastcall virtual TfrxMasterData(Classes::TComponent* AOwner) : TfrxDataBand(AOwner) { }
	/* TfrxDataBand.Destroy */ inline __fastcall virtual ~TfrxMasterData(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxMasterData(Classes::TComponent* AOwner, System::Word Flags) : TfrxDataBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDetailData;
class PASCALIMPLEMENTATION TfrxDetailData : public TfrxDataBand
{
	typedef TfrxDataBand inherited;
	
public:
	/* TfrxDataBand.Create */ inline __fastcall virtual TfrxDetailData(Classes::TComponent* AOwner) : TfrxDataBand(AOwner) { }
	/* TfrxDataBand.Destroy */ inline __fastcall virtual ~TfrxDetailData(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDetailData(Classes::TComponent* AOwner, System::Word Flags) : TfrxDataBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxSubdetailData;
class PASCALIMPLEMENTATION TfrxSubdetailData : public TfrxDataBand
{
	typedef TfrxDataBand inherited;
	
public:
	/* TfrxDataBand.Create */ inline __fastcall virtual TfrxSubdetailData(Classes::TComponent* AOwner) : TfrxDataBand(AOwner) { }
	/* TfrxDataBand.Destroy */ inline __fastcall virtual ~TfrxSubdetailData(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxSubdetailData(Classes::TComponent* AOwner, System::Word Flags) : TfrxDataBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDataBand4;
class PASCALIMPLEMENTATION TfrxDataBand4 : public TfrxDataBand
{
	typedef TfrxDataBand inherited;
	
public:
	/* TfrxDataBand.Create */ inline __fastcall virtual TfrxDataBand4(Classes::TComponent* AOwner) : TfrxDataBand(AOwner) { }
	/* TfrxDataBand.Destroy */ inline __fastcall virtual ~TfrxDataBand4(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDataBand4(Classes::TComponent* AOwner, System::Word Flags) : TfrxDataBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDataBand5;
class PASCALIMPLEMENTATION TfrxDataBand5 : public TfrxDataBand
{
	typedef TfrxDataBand inherited;
	
public:
	/* TfrxDataBand.Create */ inline __fastcall virtual TfrxDataBand5(Classes::TComponent* AOwner) : TfrxDataBand(AOwner) { }
	/* TfrxDataBand.Destroy */ inline __fastcall virtual ~TfrxDataBand5(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDataBand5(Classes::TComponent* AOwner, System::Word Flags) : TfrxDataBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDataBand6;
class PASCALIMPLEMENTATION TfrxDataBand6 : public TfrxDataBand
{
	typedef TfrxDataBand inherited;
	
public:
	/* TfrxDataBand.Create */ inline __fastcall virtual TfrxDataBand6(Classes::TComponent* AOwner) : TfrxDataBand(AOwner) { }
	/* TfrxDataBand.Destroy */ inline __fastcall virtual ~TfrxDataBand6(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDataBand6(Classes::TComponent* AOwner, System::Word Flags) : TfrxDataBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxPageHeader;
class PASCALIMPLEMENTATION TfrxPageHeader : public TfrxBand
{
	typedef TfrxBand inherited;
	
private:
	bool FPrintOnFirstPage;
	
public:
	__fastcall virtual TfrxPageHeader(Classes::TComponent* AOwner);
	
__published:
	__property Child;
	__property PrintChildIfInvisible = {default=0};
	__property bool PrintOnFirstPage = {read=FPrintOnFirstPage, write=FPrintOnFirstPage, default=1};
	__property Stretched = {default=0};
public:
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxPageHeader(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxPageHeader(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxPageFooter;
class PASCALIMPLEMENTATION TfrxPageFooter : public TfrxBand
{
	typedef TfrxBand inherited;
	
private:
	bool FPrintOnFirstPage;
	bool FPrintOnLastPage;
	
public:
	__fastcall virtual TfrxPageFooter(Classes::TComponent* AOwner);
	
__published:
	__property bool PrintOnFirstPage = {read=FPrintOnFirstPage, write=FPrintOnFirstPage, default=1};
	__property bool PrintOnLastPage = {read=FPrintOnLastPage, write=FPrintOnLastPage, default=1};
public:
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxPageFooter(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxPageFooter(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxColumnHeader;
class PASCALIMPLEMENTATION TfrxColumnHeader : public TfrxBand
{
	typedef TfrxBand inherited;
	
__published:
	__property Child;
	__property Stretched = {default=0};
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxColumnHeader(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxColumnHeader(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxColumnHeader(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxColumnFooter;
class PASCALIMPLEMENTATION TfrxColumnFooter : public TfrxBand
{
	typedef TfrxBand inherited;
	
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxColumnFooter(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxColumnFooter(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxColumnFooter(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxGroupHeader;
class PASCALIMPLEMENTATION TfrxGroupHeader : public TfrxBand
{
	typedef TfrxBand inherited;
	
private:
	System::UnicodeString FCondition;
	System::UnicodeString FDrillName;
	bool FDrillDown;
	bool FExpandDrillDown;
	bool FShowFooterIfDrillDown;
	bool FShowChildIfDrillDown;
	bool FKeepTogether;
	bool FReprintOnNewPage;
	bool FResetPageNumbers;
	
public:
	System::Variant FLastValue;
	virtual System::UnicodeString __fastcall Diff(TfrxComponent* AComponent);
	
__published:
	__property AllowSplit = {default=0};
	__property Child;
	__property System::UnicodeString Condition = {read=FCondition, write=FCondition};
	__property bool DrillDown = {read=FDrillDown, write=FDrillDown, default=0};
	__property bool ExpandDrillDown = {read=FExpandDrillDown, write=FExpandDrillDown, default=0};
	__property KeepChild = {default=0};
	__property bool KeepTogether = {read=FKeepTogether, write=FKeepTogether, default=0};
	__property bool ReprintOnNewPage = {read=FReprintOnNewPage, write=FReprintOnNewPage, default=0};
	__property OutlineText;
	__property PrintChildIfInvisible = {default=0};
	__property bool ResetPageNumbers = {read=FResetPageNumbers, write=FResetPageNumbers, default=0};
	__property bool ShowFooterIfDrillDown = {read=FShowFooterIfDrillDown, write=FShowFooterIfDrillDown, default=0};
	__property bool ShowChildIfDrillDown = {read=FShowChildIfDrillDown, write=FShowChildIfDrillDown, default=0};
	__property StartNewPage = {default=0};
	__property Stretched = {default=0};
	__property System::UnicodeString DrillName = {read=FDrillName, write=FDrillName};
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxGroupHeader(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxGroupHeader(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxGroupHeader(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxGroupFooter;
class PASCALIMPLEMENTATION TfrxGroupFooter : public TfrxBand
{
	typedef TfrxBand inherited;
	
private:
	bool FHideIfSingleDataRecord;
	
__published:
	__property AllowSplit = {default=0};
	__property Child;
	__property bool HideIfSingleDataRecord = {read=FHideIfSingleDataRecord, write=FHideIfSingleDataRecord, default=0};
	__property KeepChild = {default=0};
	__property PrintChildIfInvisible = {default=0};
	__property Stretched = {default=0};
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxGroupFooter(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxGroupFooter(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxGroupFooter(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxReportTitle;
class PASCALIMPLEMENTATION TfrxReportTitle : public TfrxBand
{
	typedef TfrxBand inherited;
	
__published:
	__property AllowSplit = {default=0};
	__property Child;
	__property KeepChild = {default=0};
	__property PrintChildIfInvisible = {default=0};
	__property StartNewPage = {default=0};
	__property Stretched = {default=0};
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxReportTitle(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxReportTitle(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxReportTitle(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxReportSummary;
class PASCALIMPLEMENTATION TfrxReportSummary : public TfrxBand
{
	typedef TfrxBand inherited;
	
__published:
	__property AllowSplit = {default=0};
	__property Child;
	__property KeepChild = {default=0};
	__property PrintChildIfInvisible = {default=0};
	__property StartNewPage = {default=0};
	__property Stretched = {default=0};
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxReportSummary(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxReportSummary(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxReportSummary(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class PASCALIMPLEMENTATION TfrxChild : public TfrxBand
{
	typedef TfrxBand inherited;
	
__published:
	__property AllowSplit = {default=0};
	__property Child;
	__property KeepChild = {default=0};
	__property PrintChildIfInvisible = {default=0};
	__property StartNewPage = {default=0};
	__property Stretched = {default=0};
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxChild(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxChild(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxChild(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxOverlay;
class PASCALIMPLEMENTATION TfrxOverlay : public TfrxBand
{
	typedef TfrxBand inherited;
	
private:
	bool FPrintOnTop;
	
__published:
	__property bool PrintOnTop = {read=FPrintOnTop, write=FPrintOnTop, default=0};
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxOverlay(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxOverlay(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxOverlay(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxNullBand;
class PASCALIMPLEMENTATION TfrxNullBand : public TfrxBand
{
	typedef TfrxBand inherited;
	
public:
	/* TfrxBand.Create */ inline __fastcall virtual TfrxNullBand(Classes::TComponent* AOwner) : TfrxBand(AOwner) { }
	/* TfrxBand.Destroy */ inline __fastcall virtual ~TfrxNullBand(void) { }
	
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxNullBand(Classes::TComponent* AOwner, System::Word Flags) : TfrxBand(AOwner, Flags) { }
	
};


class PASCALIMPLEMENTATION TfrxPage : public TfrxComponent
{
	typedef TfrxComponent inherited;
	
__published:
	__property Font;
	__property Visible = {default=1};
public:
	/* TfrxComponent.Create */ inline __fastcall virtual TfrxPage(Classes::TComponent* AOwner) : TfrxComponent(AOwner) { }
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxPage(Classes::TComponent* AOwner, System::Word Flags) : TfrxComponent(AOwner, Flags) { }
	/* TfrxComponent.Destroy */ inline __fastcall virtual ~TfrxPage(void) { }
	
};


class PASCALIMPLEMENTATION TfrxReportPage : public TfrxPage
{
	typedef TfrxPage inherited;
	
private:
	TfrxPictureView* FBackPicture;
	int FBin;
	int FBinOtherPages;
	System::Extended FBottomMargin;
	int FColumns;
	System::Extended FColumnWidth;
	Classes::TStrings* FColumnPositions;
	TfrxDataSet* FDataSet;
	TfrxDuplexMode FDuplex;
	bool FEndlessHeight;
	bool FEndlessWidth;
	Classes::TStrings* FHGuides;
	bool FLargeDesignHeight;
	System::Extended FLeftMargin;
	bool FMirrorMargins;
	Printers::TPrinterOrientation FOrientation;
	System::UnicodeString FOutlineText;
	bool FPrintIfEmpty;
	bool FPrintOnPreviousPage;
	bool FResetPageNumbers;
	System::Extended FRightMargin;
	TfrxSubreport* FSubReport;
	bool FTitleBeforeHeader;
	System::Extended FTopMargin;
	Classes::TStrings* FVGuides;
	TfrxNotifyEvent FOnAfterPrint;
	TfrxNotifyEvent FOnBeforePrint;
	TfrxNotifyEvent FOnManualBuild;
	System::UnicodeString FDataSetName;
	bool FBackPictureVisible;
	bool FBackPicturePrintable;
	int FPageCount;
	void __fastcall SetPageCount(const int Value);
	void __fastcall SetColumns(const int Value);
	void __fastcall SetOrientation(Printers::TPrinterOrientation Value);
	void __fastcall SetHGuides(const Classes::TStrings* Value);
	void __fastcall SetVGuides(const Classes::TStrings* Value);
	void __fastcall SetColumnPositions(const Classes::TStrings* Value);
	void __fastcall SetFrame(const TfrxFrame* Value);
	TfrxFrame* __fastcall GetFrame(void);
	Graphics::TColor __fastcall GetColor(void);
	void __fastcall SetColor(const Graphics::TColor Value);
	Graphics::TPicture* __fastcall GetBackPicture(void);
	void __fastcall SetBackPicture(const Graphics::TPicture* Value);
	void __fastcall SetDataSet(const TfrxDataSet* Value);
	void __fastcall SetDataSetName(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetDataSetName(void);
	
protected:
	System::Extended FPaperHeight;
	int FPaperSize;
	System::Extended FPaperWidth;
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall SetPaperHeight(const System::Extended Value);
	virtual void __fastcall SetPaperWidth(const System::Extended Value);
	virtual void __fastcall SetPaperSize(const int Value);
	void __fastcall UpdateDimensions(void);
	
public:
	Classes::TList* FSubBands;
	Classes::TList* FVSubBands;
	__fastcall virtual TfrxReportPage(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxReportPage(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	TfrxBand* __fastcall FindBand(TfrxBandClass Band);
	bool __fastcall IsSubReport(void);
	virtual void __fastcall AlignChildren(void);
	void __fastcall ClearGuides(void);
	void __fastcall Draw(Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY);
	virtual void __fastcall SetDefaults(void);
	void __fastcall SetSizeAndDimensions(int ASize, System::Extended AWidth, System::Extended AHeight);
	__property TfrxSubreport* SubReport = {read=FSubReport};
	
__published:
	__property Printers::TPrinterOrientation Orientation = {read=FOrientation, write=SetOrientation, default=0};
	__property System::Extended PaperWidth = {read=FPaperWidth, write=SetPaperWidth};
	__property System::Extended PaperHeight = {read=FPaperHeight, write=SetPaperHeight};
	__property int PaperSize = {read=FPaperSize, write=SetPaperSize, nodefault};
	__property System::Extended LeftMargin = {read=FLeftMargin, write=FLeftMargin};
	__property System::Extended RightMargin = {read=FRightMargin, write=FRightMargin};
	__property System::Extended TopMargin = {read=FTopMargin, write=FTopMargin};
	__property System::Extended BottomMargin = {read=FBottomMargin, write=FBottomMargin};
	__property bool MirrorMargins = {read=FMirrorMargins, write=FMirrorMargins, default=0};
	__property int Columns = {read=FColumns, write=SetColumns, default=0};
	__property System::Extended ColumnWidth = {read=FColumnWidth, write=FColumnWidth};
	__property Classes::TStrings* ColumnPositions = {read=FColumnPositions, write=SetColumnPositions};
	__property int Bin = {read=FBin, write=FBin, default=7};
	__property int BinOtherPages = {read=FBinOtherPages, write=FBinOtherPages, default=7};
	__property Graphics::TPicture* BackPicture = {read=GetBackPicture, write=SetBackPicture};
	__property bool BackPictureVisible = {read=FBackPictureVisible, write=FBackPictureVisible, default=1};
	__property bool BackPicturePrintable = {read=FBackPicturePrintable, write=FBackPicturePrintable, default=1};
	__property int PageCount = {read=FPageCount, write=SetPageCount, default=1};
	__property Graphics::TColor Color = {read=GetColor, write=SetColor, default=536870911};
	__property TfrxDataSet* DataSet = {read=FDataSet, write=SetDataSet};
	__property System::UnicodeString DataSetName = {read=GetDataSetName, write=SetDataSetName};
	__property TfrxDuplexMode Duplex = {read=FDuplex, write=FDuplex, default=0};
	__property TfrxFrame* Frame = {read=GetFrame, write=SetFrame};
	__property bool EndlessHeight = {read=FEndlessHeight, write=FEndlessHeight, default=0};
	__property bool EndlessWidth = {read=FEndlessWidth, write=FEndlessWidth, default=0};
	__property bool LargeDesignHeight = {read=FLargeDesignHeight, write=FLargeDesignHeight, default=0};
	__property System::UnicodeString OutlineText = {read=FOutlineText, write=FOutlineText};
	__property bool PrintIfEmpty = {read=FPrintIfEmpty, write=FPrintIfEmpty, default=1};
	__property bool PrintOnPreviousPage = {read=FPrintOnPreviousPage, write=FPrintOnPreviousPage, default=0};
	__property bool ResetPageNumbers = {read=FResetPageNumbers, write=FResetPageNumbers, default=0};
	__property bool TitleBeforeHeader = {read=FTitleBeforeHeader, write=FTitleBeforeHeader, default=1};
	__property Classes::TStrings* HGuides = {read=FHGuides, write=SetHGuides};
	__property Classes::TStrings* VGuides = {read=FVGuides, write=SetVGuides};
	__property TfrxNotifyEvent OnAfterPrint = {read=FOnAfterPrint, write=FOnAfterPrint};
	__property TfrxNotifyEvent OnBeforePrint = {read=FOnBeforePrint, write=FOnBeforePrint};
	__property TfrxNotifyEvent OnManualBuild = {read=FOnManualBuild, write=FOnManualBuild};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxReportPage(Classes::TComponent* AOwner, System::Word Flags) : TfrxPage(AOwner, Flags) { }
	
};


class PASCALIMPLEMENTATION TfrxDialogPage : public TfrxPage
{
	typedef TfrxPage inherited;
	
private:
	Forms::TFormBorderStyle FBorderStyle;
	System::UnicodeString FCaption;
	Graphics::TColor FColor;
	Forms::TForm* FForm;
	TfrxNotifyEvent FOnActivate;
	TfrxNotifyEvent FOnClick;
	TfrxNotifyEvent FOnDeactivate;
	TfrxNotifyEvent FOnHide;
	TfrxKeyEvent FOnKeyDown;
	TfrxKeyPressEvent FOnKeyPress;
	TfrxKeyEvent FOnKeyUp;
	TfrxNotifyEvent FOnResize;
	TfrxNotifyEvent FOnShow;
	TfrxCloseQueryEvent FOnCloseQuery;
	Forms::TPosition FPosition;
	Forms::TWindowState FWindowState;
	System::Extended FClientWidth;
	System::Extended FClientHeight;
	void __fastcall DoInitialize(void);
	void __fastcall DoOnActivate(System::TObject* Sender);
	void __fastcall DoOnClick(System::TObject* Sender);
	void __fastcall DoOnCloseQuery(System::TObject* Sender, bool &CanClose);
	void __fastcall DoOnDeactivate(System::TObject* Sender);
	void __fastcall DoOnHide(System::TObject* Sender);
	void __fastcall DoOnKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall DoOnKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall DoOnKeyUp(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall DoOnShow(System::TObject* Sender);
	void __fastcall DoOnResize(System::TObject* Sender);
	void __fastcall DoModify(System::TObject* Sender);
	void __fastcall DoOnMouseMove(System::TObject* Sender, Classes::TShiftState Shift, int X, int Y);
	void __fastcall SetBorderStyle(const Forms::TFormBorderStyle Value);
	void __fastcall SetCaption(const System::UnicodeString Value);
	void __fastcall SetColor(const Graphics::TColor Value);
	Controls::TModalResult __fastcall GetModalResult(void);
	void __fastcall SetModalResult(const Controls::TModalResult Value);
	
protected:
	virtual void __fastcall SetLeft(System::Extended Value);
	virtual void __fastcall SetTop(System::Extended Value);
	virtual void __fastcall SetWidth(System::Extended Value);
	virtual void __fastcall SetHeight(System::Extended Value);
	void __fastcall SetClientWidth(System::Extended Value);
	void __fastcall SetClientHeight(System::Extended Value);
	System::Extended __fastcall GetClientWidth(void);
	System::Extended __fastcall GetClientHeight(void);
	virtual void __fastcall FontChanged(System::TObject* Sender);
	
public:
	__fastcall virtual TfrxDialogPage(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDialogPage(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	void __fastcall Initialize(void);
	Controls::TModalResult __fastcall ShowModal(void);
	__property Forms::TForm* DialogForm = {read=FForm};
	__property Controls::TModalResult ModalResult = {read=GetModalResult, write=SetModalResult, nodefault};
	
__published:
	__property Forms::TFormBorderStyle BorderStyle = {read=FBorderStyle, write=SetBorderStyle, default=2};
	__property System::UnicodeString Caption = {read=FCaption, write=SetCaption};
	__property Graphics::TColor Color = {read=FColor, write=SetColor, default=-16777201};
	__property Height;
	__property System::Extended ClientHeight = {read=GetClientHeight, write=SetClientHeight};
	__property Left;
	__property Forms::TPosition Position = {read=FPosition, write=FPosition, default=4};
	__property Top;
	__property Width;
	__property System::Extended ClientWidth = {read=GetClientWidth, write=SetClientWidth};
	__property Forms::TWindowState WindowState = {read=FWindowState, write=FWindowState, default=0};
	__property TfrxNotifyEvent OnActivate = {read=FOnActivate, write=FOnActivate};
	__property TfrxNotifyEvent OnClick = {read=FOnClick, write=FOnClick};
	__property TfrxCloseQueryEvent OnCloseQuery = {read=FOnCloseQuery, write=FOnCloseQuery};
	__property TfrxNotifyEvent OnDeactivate = {read=FOnDeactivate, write=FOnDeactivate};
	__property TfrxNotifyEvent OnHide = {read=FOnHide, write=FOnHide};
	__property TfrxKeyEvent OnKeyDown = {read=FOnKeyDown, write=FOnKeyDown};
	__property TfrxKeyPressEvent OnKeyPress = {read=FOnKeyPress, write=FOnKeyPress};
	__property TfrxKeyEvent OnKeyUp = {read=FOnKeyUp, write=FOnKeyUp};
	__property TfrxNotifyEvent OnShow = {read=FOnShow, write=FOnShow};
	__property TfrxNotifyEvent OnResize = {read=FOnResize, write=FOnResize};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDialogPage(Classes::TComponent* AOwner, System::Word Flags) : TfrxPage(AOwner, Flags) { }
	
};


class DELPHICLASS TfrxDataPage;
class PASCALIMPLEMENTATION TfrxDataPage : public TfrxPage
{
	typedef TfrxPage inherited;
	
public:
	__fastcall virtual TfrxDataPage(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	
__published:
	__property Height;
	__property Left;
	__property Top;
	__property Width;
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxDataPage(Classes::TComponent* AOwner, System::Word Flags) : TfrxPage(AOwner, Flags) { }
	/* TfrxComponent.Destroy */ inline __fastcall virtual ~TfrxDataPage(void) { }
	
};


class DELPHICLASS TfrxEngineOptions;
class PASCALIMPLEMENTATION TfrxEngineOptions : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	bool FConvertNulls;
	bool FDestroyForms;
	bool FDoublePass;
	int FMaxMemSize;
	bool FPrintIfEmpty;
	Classes::TThread* FReportThread;
	bool FEnableThreadSafe;
	TfrxSilentMode FSilentMode;
	System::UnicodeString FTempDir;
	bool FUseFileCache;
	bool FUseGlobalDataSetList;
	bool FIgnoreDevByZero;
	void __fastcall SetSilentMode(bool Mode);
	bool __fastcall GetSilentMode(void);
	
public:
	__fastcall TfrxEngineOptions(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall Clear(void);
	__property Classes::TThread* ReportThread = {read=FReportThread, write=FReportThread};
	__property bool DestroyForms = {read=FDestroyForms, write=FDestroyForms, nodefault};
	__property bool EnableThreadSafe = {read=FEnableThreadSafe, write=FEnableThreadSafe, nodefault};
	__property bool UseGlobalDataSetList = {read=FUseGlobalDataSetList, write=FUseGlobalDataSetList, nodefault};
	
__published:
	__property bool ConvertNulls = {read=FConvertNulls, write=FConvertNulls, default=1};
	__property bool DoublePass = {read=FDoublePass, write=FDoublePass, default=0};
	__property int MaxMemSize = {read=FMaxMemSize, write=FMaxMemSize, default=10};
	__property bool PrintIfEmpty = {read=FPrintIfEmpty, write=FPrintIfEmpty, default=1};
	__property bool SilentMode = {read=GetSilentMode, write=SetSilentMode, default=0};
	__property TfrxSilentMode NewSilentMode = {read=FSilentMode, write=FSilentMode, default=0};
	__property System::UnicodeString TempDir = {read=FTempDir, write=FTempDir};
	__property bool UseFileCache = {read=FUseFileCache, write=FUseFileCache, default=0};
	__property bool IgnoreDevByZero = {read=FIgnoreDevByZero, write=FIgnoreDevByZero, default=0};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxEngineOptions(void) { }
	
};


class DELPHICLASS TfrxPrintOptions;
class PASCALIMPLEMENTATION TfrxPrintOptions : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	int FCopies;
	bool FCollate;
	System::UnicodeString FPageNumbers;
	int FPagesOnSheet;
	System::UnicodeString FPrinter;
	TfrxPrintMode FPrintMode;
	int FPrintOnSheet;
	TfrxPrintPages FPrintPages;
	bool FReverse;
	bool FShowDialog;
	bool FSwapPageSize;
	System::UnicodeString FPrnOutFileName;
	TfrxDuplexMode FDuplex;
	int FSplicingLine;
	
public:
	__fastcall TfrxPrintOptions(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall Clear(void);
	__property System::UnicodeString PrnOutFileName = {read=FPrnOutFileName, write=FPrnOutFileName};
	__property TfrxDuplexMode Duplex = {read=FDuplex, write=FDuplex, nodefault};
	__property int SplicingLine = {read=FSplicingLine, write=FSplicingLine, default=3};
	
__published:
	__property int Copies = {read=FCopies, write=FCopies, default=1};
	__property bool Collate = {read=FCollate, write=FCollate, default=1};
	__property System::UnicodeString PageNumbers = {read=FPageNumbers, write=FPageNumbers};
	__property System::UnicodeString Printer = {read=FPrinter, write=FPrinter};
	__property TfrxPrintMode PrintMode = {read=FPrintMode, write=FPrintMode, default=0};
	__property int PrintOnSheet = {read=FPrintOnSheet, write=FPrintOnSheet, nodefault};
	__property TfrxPrintPages PrintPages = {read=FPrintPages, write=FPrintPages, default=0};
	__property bool Reverse = {read=FReverse, write=FReverse, default=0};
	__property bool ShowDialog = {read=FShowDialog, write=FShowDialog, default=1};
	__property bool SwapPageSize = {read=FSwapPageSize, write=FSwapPageSize, stored=false, nodefault};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxPrintOptions(void) { }
	
};


class DELPHICLASS TfrxPreviewOptions;
class PASCALIMPLEMENTATION TfrxPreviewOptions : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	bool FAllowEdit;
	TfrxPreviewButtons FButtons;
	bool FDoubleBuffered;
	bool FMaximized;
	bool FMDIChild;
	bool FModal;
	bool FOutlineExpand;
	bool FOutlineVisible;
	int FOutlineWidth;
	int FPagesInCache;
	bool FShowCaptions;
	bool FThumbnailVisible;
	System::Extended FZoom;
	TfrxZoomMode FZoomMode;
	bool FPictureCacheInFile;
	bool FRTLPreview;
	
public:
	__fastcall TfrxPreviewOptions(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall Clear(void);
	__property bool RTLPreview = {read=FRTLPreview, write=FRTLPreview, nodefault};
	
__published:
	__property bool AllowEdit = {read=FAllowEdit, write=FAllowEdit, default=1};
	__property TfrxPreviewButtons Buttons = {read=FButtons, write=FButtons, nodefault};
	__property bool DoubleBuffered = {read=FDoubleBuffered, write=FDoubleBuffered, default=1};
	__property bool Maximized = {read=FMaximized, write=FMaximized, default=1};
	__property bool MDIChild = {read=FMDIChild, write=FMDIChild, default=0};
	__property bool Modal = {read=FModal, write=FModal, default=1};
	__property bool OutlineExpand = {read=FOutlineExpand, write=FOutlineExpand, default=1};
	__property bool OutlineVisible = {read=FOutlineVisible, write=FOutlineVisible, default=0};
	__property int OutlineWidth = {read=FOutlineWidth, write=FOutlineWidth, default=120};
	__property int PagesInCache = {read=FPagesInCache, write=FPagesInCache, default=50};
	__property bool ThumbnailVisible = {read=FThumbnailVisible, write=FThumbnailVisible, default=0};
	__property bool ShowCaptions = {read=FShowCaptions, write=FShowCaptions, default=0};
	__property System::Extended Zoom = {read=FZoom, write=FZoom};
	__property TfrxZoomMode ZoomMode = {read=FZoomMode, write=FZoomMode, default=0};
	__property bool PictureCacheInFile = {read=FPictureCacheInFile, write=FPictureCacheInFile, default=0};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxPreviewOptions(void) { }
	
};


class DELPHICLASS TfrxReportOptions;
class PASCALIMPLEMENTATION TfrxReportOptions : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::UnicodeString FAuthor;
	bool FCompressed;
	System::UnicodeString FConnectionName;
	System::TDateTime FCreateDate;
	Classes::TStrings* FDescription;
	System::UnicodeString FInitString;
	System::UnicodeString FName;
	System::TDateTime FLastChange;
	System::UnicodeString FPassword;
	Graphics::TPicture* FPicture;
	TfrxReport* FReport;
	System::UnicodeString FVersionBuild;
	System::UnicodeString FVersionMajor;
	System::UnicodeString FVersionMinor;
	System::UnicodeString FVersionRelease;
	System::UnicodeString FPrevPassword;
	System::UnicodeString FHiddenPassword;
	bool FInfo;
	void __fastcall SetDescription(const Classes::TStrings* Value);
	void __fastcall SetPicture(const Graphics::TPicture* Value);
	void __fastcall SetConnectionName(const System::UnicodeString Value);
	
public:
	__fastcall TfrxReportOptions(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxReportOptions(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall Clear(void);
	bool __fastcall CheckPassword(void);
	__property System::UnicodeString PrevPassword = {write=FPrevPassword};
	__property bool Info = {read=FInfo, write=FInfo, nodefault};
	__property System::UnicodeString HiddenPassword = {read=FHiddenPassword, write=FHiddenPassword};
	
__published:
	__property System::UnicodeString Author = {read=FAuthor, write=FAuthor};
	__property bool Compressed = {read=FCompressed, write=FCompressed, default=0};
	__property System::UnicodeString ConnectionName = {read=FConnectionName, write=SetConnectionName};
	__property System::TDateTime CreateDate = {read=FCreateDate, write=FCreateDate};
	__property Classes::TStrings* Description = {read=FDescription, write=SetDescription};
	__property System::UnicodeString InitString = {read=FInitString, write=FInitString};
	__property System::UnicodeString Name = {read=FName, write=FName};
	__property System::TDateTime LastChange = {read=FLastChange, write=FLastChange};
	__property System::UnicodeString Password = {read=FPassword, write=FPassword};
	__property Graphics::TPicture* Picture = {read=FPicture, write=SetPicture};
	__property System::UnicodeString VersionBuild = {read=FVersionBuild, write=FVersionBuild};
	__property System::UnicodeString VersionMajor = {read=FVersionMajor, write=FVersionMajor};
	__property System::UnicodeString VersionMinor = {read=FVersionMinor, write=FVersionMinor};
	__property System::UnicodeString VersionRelease = {read=FVersionRelease, write=FVersionRelease};
};


class DELPHICLASS TfrxExpressionCache;
class PASCALIMPLEMENTATION TfrxExpressionCache : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TStringList* FExpressions;
	Fs_iinterpreter::TfsScript* FMainScript;
	Fs_iinterpreter::TfsScript* FScript;
	System::UnicodeString FScriptLanguage;
	void __fastcall SetCaseSensitive(const bool Value);
	bool __fastcall GetCaseSensitive(void);
	
public:
	__fastcall TfrxExpressionCache(Fs_iinterpreter::TfsScript* AScript);
	__fastcall virtual ~TfrxExpressionCache(void);
	void __fastcall Clear(void);
	System::Variant __fastcall Calc(const System::UnicodeString Expression, System::UnicodeString &ErrorMsg, Fs_iinterpreter::TfsScript* AScript);
	__property bool CaseSensitive = {read=GetCaseSensitive, write=SetCaseSensitive, nodefault};
};


class DELPHICLASS TfrxDataSetItem;
class PASCALIMPLEMENTATION TfrxDataSetItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	TfrxDataSet* FDataSet;
	System::UnicodeString FDataSetName;
	void __fastcall SetDataSet(const TfrxDataSet* Value);
	void __fastcall SetDataSetName(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetDataSetName(void);
	
__published:
	__property TfrxDataSet* DataSet = {read=FDataSet, write=SetDataSet};
	__property System::UnicodeString DataSetName = {read=GetDataSetName, write=SetDataSetName};
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxDataSetItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxDataSetItem(void) { }
	
};


class DELPHICLASS TfrxReportDataSets;
class PASCALIMPLEMENTATION TfrxReportDataSets : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxDataSetItem* operator[](int Index) { return Items[Index]; }
	
private:
	TfrxReport* FReport;
	HIDESBASE TfrxDataSetItem* __fastcall GetItem(int Index);
	
public:
	__fastcall TfrxReportDataSets(TfrxReport* AReport);
	void __fastcall Initialize(void);
	void __fastcall Finalize(void);
	HIDESBASE void __fastcall Add(TfrxDataSet* ds);
	TfrxDataSetItem* __fastcall Find(TfrxDataSet* ds)/* overload */;
	TfrxDataSetItem* __fastcall Find(const System::UnicodeString Name)/* overload */;
	HIDESBASE void __fastcall Delete(const System::UnicodeString Name)/* overload */;
	__property TfrxDataSetItem* Items[int Index] = {read=GetItem/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxReportDataSets(void) { }
	
};


class PASCALIMPLEMENTATION TfrxStyleItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FName;
	Graphics::TColor FColor;
	Graphics::TFont* FFont;
	TfrxFrame* FFrame;
	void __fastcall SetFont(const Graphics::TFont* Value);
	void __fastcall SetFrame(const TfrxFrame* Value);
	void __fastcall SetName(const System::UnicodeString Value);
	
public:
	__fastcall virtual TfrxStyleItem(Classes::TCollection* Collection);
	__fastcall virtual ~TfrxStyleItem(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall CreateUniqueName(void);
	
__published:
	__property System::UnicodeString Name = {read=FName, write=SetName};
	__property Graphics::TColor Color = {read=FColor, write=FColor, nodefault};
	__property Graphics::TFont* Font = {read=FFont, write=SetFont};
	__property TfrxFrame* Frame = {read=FFrame, write=SetFrame};
};


class DELPHICLASS TfrxStyles;
class PASCALIMPLEMENTATION TfrxStyles : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxStyleItem* operator[](int Index) { return Items[Index]; }
	
private:
	System::UnicodeString FName;
	TfrxReport* FReport;
	HIDESBASE TfrxStyleItem* __fastcall GetItem(int Index);
	
public:
	__fastcall TfrxStyles(TfrxReport* AReport);
	HIDESBASE TfrxStyleItem* __fastcall Add(void);
	TfrxStyleItem* __fastcall Find(const System::UnicodeString Name);
	void __fastcall Apply(void);
	void __fastcall GetList(Classes::TStrings* List);
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	void __fastcall LoadFromStream(Classes::TStream* Stream);
	void __fastcall LoadFromXMLItem(Frxxml::TfrxXMLItem* Item, bool OldXMLFormat = true);
	void __fastcall SaveToFile(const System::UnicodeString FileName);
	void __fastcall SaveToStream(Classes::TStream* Stream);
	void __fastcall SaveToXMLItem(Frxxml::TfrxXMLItem* Item);
	__property TfrxStyleItem* Items[int Index] = {read=GetItem/*, default*/};
	__property System::UnicodeString Name = {read=FName, write=FName};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxStyles(void) { }
	
};


class DELPHICLASS TfrxStyleSheet;
class PASCALIMPLEMENTATION TfrxStyleSheet : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TfrxStyles* operator[](int Index) { return Items[Index]; }
	
private:
	Classes::TList* FItems;
	TfrxStyles* __fastcall GetItems(int Index);
	
public:
	__fastcall TfrxStyleSheet(void);
	__fastcall virtual ~TfrxStyleSheet(void);
	void __fastcall Clear(void);
	void __fastcall Delete(int Index);
	void __fastcall GetList(Classes::TStrings* List);
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	void __fastcall LoadFromStream(Classes::TStream* Stream);
	void __fastcall SaveToFile(const System::UnicodeString FileName);
	void __fastcall SaveToStream(Classes::TStream* Stream);
	TfrxStyles* __fastcall Add(void);
	int __fastcall Count(void);
	TfrxStyles* __fastcall Find(const System::UnicodeString Name);
	int __fastcall IndexOf(const System::UnicodeString Name);
	__property TfrxStyles* Items[int Index] = {read=GetItems/*, default*/};
};


class DELPHICLASS TfrxCustomDesigner;
class DELPHICLASS TfrxCustomEngine;
class DELPHICLASS TfrxCustomPreviewPages;
class DELPHICLASS TfrxCustomPreview;
class DELPHICLASS TfrxCustomExportFilter;
class PASCALIMPLEMENTATION TfrxReport : public TfrxComponent
{
	typedef TfrxComponent inherited;
	
private:
	System::UnicodeString FCurObject;
	TfrxDataSet* FDataSet;
	System::UnicodeString FDataSetName;
	TfrxReportDataSets* FDataSets;
	TfrxCustomDesigner* FDesigner;
	bool FDotMatrixReport;
	void *FDrawText;
	Classes::TStrings* FDrillState;
	TfrxReportDataSets* FEnabledDataSets;
	TfrxCustomEngine* FEngine;
	TfrxEngineOptions* FEngineOptions;
	Classes::TStrings* FErrors;
	TfrxExpressionCache* FExpressionCache;
	System::UnicodeString FFileName;
	System::UnicodeString FIniFile;
	Classes::TStream* FLoadStream;
	Fs_iinterpreter::TfsCustomVariable* FLocalValue;
	Fs_iinterpreter::TfsCustomVariable* FSelfValue;
	bool FModified;
	bool FOldStyleProgress;
	Forms::TForm* FParentForm;
	System::UnicodeString FParentReport;
	TfrxReport* FParentReportObject;
	TfrxCustomPreviewPages* FPreviewPages;
	TfrxCustomPreview* FPreview;
	Forms::TForm* FPreviewForm;
	TfrxPreviewOptions* FPreviewOptions;
	TfrxPrintOptions* FPrintOptions;
	Frxprogress::TfrxProgress* FProgress;
	bool FReloading;
	TfrxReportOptions* FReportOptions;
	Fs_iinterpreter::TfsScript* FScript;
	System::UnicodeString FScriptLanguage;
	Classes::TStrings* FScriptText;
	Classes::TStrings* FFakeScriptText;
	bool FShowProgress;
	bool FStoreInDFM;
	TfrxStyles* FStyles;
	Classes::TStrings* FSysVariables;
	bool FTerminated;
	Extctrls::TTimer* FTimer;
	Frxvariables::TfrxVariables* FVariables;
	System::UnicodeString FVersion;
	System::TObject* FXMLSerializer;
	bool FStreamLoaded;
	TfrxBeforePrintEvent FOnAfterPrint;
	Classes::TNotifyEvent FOnAfterPrintReport;
	TfrxBeforeConnectEvent FOnBeforeConnect;
	TfrxAfterDisconnectEvent FOnAfterDisconnect;
	TfrxBeforePrintEvent FOnBeforePrint;
	Classes::TNotifyEvent FOnBeginDoc;
	TfrxClickObjectEvent FOnClickObject;
	TfrxClickObjectEvent FOnDblClickObject;
	TfrxEditConnectionEvent FOnEditConnection;
	Classes::TNotifyEvent FOnEndDoc;
	TfrxGetValueEvent FOnGetValue;
	TfrxNewGetValueEvent FOnNewGetValue;
	TfrxLoadTemplateEvent FOnLoadTemplate;
	TfrxManualBuildEvent FOnManualBuild;
	TfrxMouseOverObjectEvent FOnMouseOverObject;
	Classes::TNotifyEvent FOnPreview;
	TfrxPrintPageEvent FOnPrintPage;
	Classes::TNotifyEvent FOnPrintReport;
	TfrxProgressEvent FOnProgressStart;
	TfrxProgressEvent FOnProgress;
	TfrxProgressEvent FOnProgressStop;
	TfrxRunDialogsEvent FOnRunDialogs;
	TfrxSetConnectionEvent FOnSetConnection;
	TfrxNotifyEvent FOnStartReport;
	TfrxNotifyEvent FOnStopReport;
	TfrxUserFunctionEvent FOnUserFunction;
	Classes::TNotifyEvent FOnClosePreview;
	TfrxNotifyEvent FOnReportPrint;
	Classes::TNotifyEvent FOnAfterScriptCompile;
	System::Variant __fastcall CallMethod(System::TObject* Instance, System::TClass ClassType, const System::UnicodeString MethodName, System::Variant &Params);
	bool __fastcall DoGetValue(const System::UnicodeString Expr, System::Variant &Value);
	System::Variant __fastcall GetScriptValue(System::TObject* Instance, System::TClass ClassType, const System::UnicodeString MethodName, System::Variant &Params);
	System::Variant __fastcall SetScriptValue(System::TObject* Instance, System::TClass ClassType, const System::UnicodeString MethodName, System::Variant &Params);
	System::Variant __fastcall DoUserFunction(System::TObject* Instance, System::TClass ClassType, const System::UnicodeString MethodName, System::Variant &Params);
	System::UnicodeString __fastcall GetDataSetName(void);
	System::Variant __fastcall GetLocalValue(void);
	TfrxView* __fastcall GetSelfValue(void);
	TfrxPage* __fastcall GetPages(int Index);
	int __fastcall GetPagesCount(void);
	bool __fastcall GetCaseSensitive(void);
	Classes::TStrings* __fastcall GetScriptText(void);
	void __fastcall AncestorNotFound(Classes::TReader* Reader, const System::UnicodeString ComponentName, Classes::TPersistentClass ComponentClass, Classes::TComponent* &Component);
	void __fastcall DoClear(void);
	void __fastcall DoGetAncestor(const System::UnicodeString Name, Classes::TPersistent* &Ancestor);
	void __fastcall DoLoadFromStream(void);
	void __fastcall OnTimer(System::TObject* Sender);
	void __fastcall ReadDatasets(Classes::TReader* Reader);
	void __fastcall ReadStyle(Classes::TReader* Reader);
	void __fastcall ReadVariables(Classes::TReader* Reader);
	void __fastcall SetDataSet(const TfrxDataSet* Value);
	void __fastcall SetDataSetName(const System::UnicodeString Value);
	void __fastcall SetEngineOptions(const TfrxEngineOptions* Value);
	void __fastcall SetSelfValue(const TfrxView* Value);
	void __fastcall SetLocalValue(const System::Variant &Value);
	void __fastcall SetParentReport(const System::UnicodeString Value);
	void __fastcall SetPreviewOptions(const TfrxPreviewOptions* Value);
	void __fastcall SetPrintOptions(const TfrxPrintOptions* Value);
	void __fastcall SetReportOptions(const TfrxReportOptions* Value);
	void __fastcall SetScriptText(const Classes::TStrings* Value);
	void __fastcall SetStyles(const TfrxStyles* Value);
	void __fastcall SetTerminated(const bool Value);
	void __fastcall SetCaseSensitive(const bool Value);
	void __fastcall WriteDatasets(Classes::TWriter* Writer);
	void __fastcall WriteStyle(Classes::TWriter* Writer);
	void __fastcall WriteVariables(Classes::TWriter* Writer);
	void __fastcall SetPreview(const TfrxCustomPreview* Value);
	void __fastcall SetVersion(const System::UnicodeString Value);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	
public:
	__fastcall virtual TfrxReport(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxReport(void);
	virtual void __fastcall Clear(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	System::Variant __fastcall Calc(const System::UnicodeString Expr, Fs_iinterpreter::TfsScript* AScript = (Fs_iinterpreter::TfsScript*)(0x0));
	bool __fastcall DesignPreviewPage(void);
	System::UnicodeString __fastcall GetAlias(TfrxDataSet* DataSet);
	TfrxDataSet* __fastcall GetDataset(const System::UnicodeString Alias);
	Inifiles::TCustomIniFile* __fastcall GetIniFile(void);
	System::UnicodeString __fastcall GetApplicationFolder(void);
	bool __fastcall PrepareScript(void);
	bool __fastcall InheritFromTemplate(const System::UnicodeString templName, TfrxInheriteMode InheriteMode = (TfrxInheriteMode)(0x0));
	void __fastcall DesignReport(System::_di_IInterface IDesigner, System::TObject* Editor)/* overload */;
	void __fastcall DoNotifyEvent(System::TObject* Obj, const System::UnicodeString EventName, bool RunAlways = false);
	void __fastcall DoParamEvent(const System::UnicodeString EventName, System::Variant &Params, bool RunAlways = false);
	void __fastcall DoAfterPrint(TfrxReportComponent* c);
	void __fastcall DoBeforePrint(TfrxReportComponent* c);
	void __fastcall DoPreviewClick(TfrxView* v, Controls::TMouseButton Button, Classes::TShiftState Shift, bool &Modified, bool DblClick = false);
	void __fastcall GetDatasetAndField(const System::UnicodeString ComplexName, TfrxDataSet* &Dataset, System::UnicodeString &Field);
	void __fastcall GetDataSetList(Classes::TStrings* List, bool OnlyDB = false);
	void __fastcall GetActiveDataSetList(Classes::TStrings* List);
	virtual void __fastcall InternalOnProgressStart(TfrxProgressType ProgressType);
	virtual void __fastcall InternalOnProgress(TfrxProgressType ProgressType, int Progress);
	virtual void __fastcall InternalOnProgressStop(TfrxProgressType ProgressType);
	void __fastcall SelectPrinter(void);
	void __fastcall SetProgressMessage(const System::UnicodeString Value, bool Ishint = false);
	void __fastcall CheckDataPage(void);
	bool __fastcall LoadFromFile(const System::UnicodeString FileName, bool ExceptionIfNotFound = false);
	virtual void __fastcall LoadFromStream(Classes::TStream* Stream);
	void __fastcall SaveToFile(const System::UnicodeString FileName);
	virtual void __fastcall SaveToStream(Classes::TStream* Stream, bool SaveChildren = true, bool SaveDefaultValues = false, bool UseGetAncestor = false);
	void __stdcall DesignReport(bool Modal = true, bool MDIChild = false)/* overload */;
	bool __fastcall PrepareReport(bool ClearLastReport = true);
	void __stdcall ShowPreparedReport(void);
	void __stdcall ShowReport(bool ClearLastReport = true);
	void __fastcall AddFunction(const System::UnicodeString FuncName, const System::UnicodeString Category = L"", const System::UnicodeString Description = L"");
	void __fastcall DesignReportInPanel(Controls::TWinControl* Panel);
	bool __stdcall Print(void);
	bool __fastcall Export(TfrxCustomExportFilter* Filter);
	__property System::UnicodeString CurObject = {read=FCurObject, write=FCurObject};
	__property Classes::TStrings* DrillState = {read=FDrillState};
	__property System::Variant LocalValue = {read=GetLocalValue, write=SetLocalValue};
	__property TfrxView* SelfValue = {read=GetSelfValue, write=SetSelfValue};
	__property Forms::TForm* PreviewForm = {read=FPreviewForm};
	__property System::TObject* XMLSerializer = {read=FXMLSerializer};
	__property bool Reloading = {read=FReloading, write=FReloading, nodefault};
	__property TfrxReportDataSets* DataSets = {read=FDataSets};
	__property TfrxCustomDesigner* Designer = {read=FDesigner, write=FDesigner};
	__property TfrxReportDataSets* EnabledDataSets = {read=FEnabledDataSets};
	__property TfrxCustomEngine* Engine = {read=FEngine};
	__property Classes::TStrings* Errors = {read=FErrors};
	__property System::UnicodeString FileName = {read=FFileName, write=FFileName};
	__property bool Modified = {read=FModified, write=FModified, nodefault};
	__property TfrxCustomPreviewPages* PreviewPages = {read=FPreviewPages};
	__property TfrxPage* Pages[int Index] = {read=GetPages};
	__property int PagesCount = {read=GetPagesCount, nodefault};
	__property Fs_iinterpreter::TfsScript* Script = {read=FScript};
	__property TfrxStyles* Styles = {read=FStyles, write=SetStyles};
	__property bool Terminated = {read=FTerminated, write=SetTerminated, nodefault};
	__property Frxvariables::TfrxVariables* Variables = {read=FVariables};
	__property bool CaseSensitiveExpressions = {read=GetCaseSensitive, write=SetCaseSensitive, nodefault};
	__property TfrxEditConnectionEvent OnEditConnection = {read=FOnEditConnection, write=FOnEditConnection};
	__property TfrxSetConnectionEvent OnSetConnection = {read=FOnSetConnection, write=FOnSetConnection};
	
__published:
	__property System::UnicodeString Version = {read=FVersion, write=SetVersion};
	__property System::UnicodeString ParentReport = {read=FParentReport, write=SetParentReport};
	__property TfrxDataSet* DataSet = {read=FDataSet, write=SetDataSet};
	__property System::UnicodeString DataSetName = {read=GetDataSetName, write=SetDataSetName};
	__property bool DotMatrixReport = {read=FDotMatrixReport, write=FDotMatrixReport, nodefault};
	__property TfrxEngineOptions* EngineOptions = {read=FEngineOptions, write=SetEngineOptions};
	__property System::UnicodeString IniFile = {read=FIniFile, write=FIniFile};
	__property bool OldStyleProgress = {read=FOldStyleProgress, write=FOldStyleProgress, default=0};
	__property TfrxCustomPreview* Preview = {read=FPreview, write=SetPreview};
	__property TfrxPreviewOptions* PreviewOptions = {read=FPreviewOptions, write=SetPreviewOptions};
	__property TfrxPrintOptions* PrintOptions = {read=FPrintOptions, write=SetPrintOptions};
	__property TfrxReportOptions* ReportOptions = {read=FReportOptions, write=SetReportOptions};
	__property System::UnicodeString ScriptLanguage = {read=FScriptLanguage, write=FScriptLanguage};
	__property Classes::TStrings* ScriptText = {read=GetScriptText, write=SetScriptText};
	__property bool ShowProgress = {read=FShowProgress, write=FShowProgress, default=1};
	__property bool StoreInDFM = {read=FStoreInDFM, write=FStoreInDFM, default=1};
	__property TfrxBeforePrintEvent OnAfterPrint = {read=FOnAfterPrint, write=FOnAfterPrint};
	__property TfrxBeforeConnectEvent OnBeforeConnect = {read=FOnBeforeConnect, write=FOnBeforeConnect};
	__property TfrxAfterDisconnectEvent OnAfterDisconnect = {read=FOnAfterDisconnect, write=FOnAfterDisconnect};
	__property TfrxBeforePrintEvent OnBeforePrint = {read=FOnBeforePrint, write=FOnBeforePrint};
	__property Classes::TNotifyEvent OnBeginDoc = {read=FOnBeginDoc, write=FOnBeginDoc};
	__property TfrxClickObjectEvent OnClickObject = {read=FOnClickObject, write=FOnClickObject};
	__property TfrxClickObjectEvent OnDblClickObject = {read=FOnDblClickObject, write=FOnDblClickObject};
	__property Classes::TNotifyEvent OnEndDoc = {read=FOnEndDoc, write=FOnEndDoc};
	__property TfrxGetValueEvent OnGetValue = {read=FOnGetValue, write=FOnGetValue};
	__property TfrxNewGetValueEvent OnNewGetValue = {read=FOnNewGetValue, write=FOnNewGetValue};
	__property TfrxManualBuildEvent OnManualBuild = {read=FOnManualBuild, write=FOnManualBuild};
	__property TfrxMouseOverObjectEvent OnMouseOverObject = {read=FOnMouseOverObject, write=FOnMouseOverObject};
	__property Classes::TNotifyEvent OnPreview = {read=FOnPreview, write=FOnPreview};
	__property TfrxPrintPageEvent OnPrintPage = {read=FOnPrintPage, write=FOnPrintPage};
	__property Classes::TNotifyEvent OnPrintReport = {read=FOnPrintReport, write=FOnPrintReport};
	__property Classes::TNotifyEvent OnAfterPrintReport = {read=FOnAfterPrintReport, write=FOnAfterPrintReport};
	__property TfrxProgressEvent OnProgressStart = {read=FOnProgressStart, write=FOnProgressStart};
	__property TfrxProgressEvent OnProgress = {read=FOnProgress, write=FOnProgress};
	__property TfrxProgressEvent OnProgressStop = {read=FOnProgressStop, write=FOnProgressStop};
	__property TfrxRunDialogsEvent OnRunDialogs = {read=FOnRunDialogs, write=FOnRunDialogs};
	__property TfrxNotifyEvent OnStartReport = {read=FOnStartReport, write=FOnStartReport};
	__property TfrxNotifyEvent OnStopReport = {read=FOnStopReport, write=FOnStopReport};
	__property TfrxUserFunctionEvent OnUserFunction = {read=FOnUserFunction, write=FOnUserFunction};
	__property TfrxLoadTemplateEvent OnLoadTemplate = {read=FOnLoadTemplate, write=FOnLoadTemplate};
	__property Classes::TNotifyEvent OnClosePreview = {read=FOnClosePreview, write=FOnClosePreview};
	__property TfrxNotifyEvent OnReportPrint = {read=FOnReportPrint, write=FOnReportPrint};
	__property Classes::TNotifyEvent OnAfterScriptCompile = {read=FOnAfterScriptCompile, write=FOnAfterScriptCompile};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxReport(Classes::TComponent* AOwner, System::Word Flags) : TfrxComponent(AOwner, Flags) { }
	
};


class PASCALIMPLEMENTATION TfrxCustomDesigner : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
private:
	TfrxReport* FReport;
	bool FIsPreviewDesigner;
	System::UnicodeString FMemoFontName;
	int FMemoFontSize;
	bool FUseObjectFont;
	Forms::TForm* FParentForm;
	
protected:
	bool FModified;
	Classes::TList* FObjects;
	TfrxPage* FPage;
	Classes::TList* FSelectedObjects;
	virtual void __fastcall SetModified(const bool Value);
	virtual void __fastcall SetPage(const TfrxPage* Value);
	virtual Classes::TStrings* __fastcall GetCode(void) = 0 ;
	
public:
	__fastcall TfrxCustomDesigner(Classes::TComponent* AOwner, TfrxReport* AReport, bool APreviewDesigner);
	__fastcall virtual ~TfrxCustomDesigner(void);
	virtual System::UnicodeString __fastcall InsertExpression(const System::UnicodeString Expr) = 0 ;
	virtual void __fastcall Lock(void) = 0 ;
	virtual void __fastcall ReloadPages(int Index) = 0 ;
	virtual void __fastcall ReloadReport(void) = 0 ;
	virtual void __fastcall UpdateDataTree(void) = 0 ;
	virtual void __fastcall UpdatePage(void) = 0 ;
	__property bool IsPreviewDesigner = {read=FIsPreviewDesigner, nodefault};
	__property bool Modified = {read=FModified, write=SetModified, nodefault};
	__property Classes::TList* Objects = {read=FObjects};
	__property TfrxReport* Report = {read=FReport};
	__property Classes::TList* SelectedObjects = {read=FSelectedObjects};
	__property TfrxPage* Page = {read=FPage, write=SetPage};
	__property Classes::TStrings* Code = {read=GetCode};
	__property bool UseObjectFont = {read=FUseObjectFont, write=FUseObjectFont, nodefault};
	__property System::UnicodeString MemoFontName = {read=FMemoFontName, write=FMemoFontName};
	__property int MemoFontSize = {read=FMemoFontSize, write=FMemoFontSize, nodefault};
	__property Forms::TForm* ParentForm = {read=FParentForm, write=FParentForm};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxCustomDesigner(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxCustomDesigner(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxCustomDesigner(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


typedef TMetaClass* TfrxDesignerClass;

class PASCALIMPLEMENTATION TfrxCustomExportFilter : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	bool FCurPage;
	bool FExportNotPrintable;
	System::UnicodeString FName;
	bool FNoRegister;
	System::UnicodeString FPageNumbers;
	TfrxReport* FReport;
	bool FShowDialog;
	Classes::TStream* FStream;
	bool FUseFileCache;
	System::UnicodeString FDefaultPath;
	bool FSlaveExport;
	bool FShowProgress;
	System::UnicodeString FDefaultExt;
	System::UnicodeString FFilterDesc;
	bool FSuppressPageHeadersFooters;
	System::UnicodeString FTitle;
	bool FOverwritePrompt;
	Classes::TStrings* FFIles;
	Classes::TNotifyEvent FOnBeginExport;
	
public:
	__fastcall virtual TfrxCustomExportFilter(Classes::TComponent* AOwner);
	__fastcall TfrxCustomExportFilter(void);
	__fastcall virtual ~TfrxCustomExportFilter(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	virtual void __fastcall ExportObject(TfrxComponent* Obj) = 0 ;
	virtual void __fastcall Finish(void);
	virtual void __fastcall FinishPage(TfrxReportPage* Page, int Index);
	virtual void __fastcall StartPage(TfrxReportPage* Page, int Index);
	__property bool CurPage = {read=FCurPage, write=FCurPage, nodefault};
	__property System::UnicodeString PageNumbers = {read=FPageNumbers, write=FPageNumbers};
	__property TfrxReport* Report = {read=FReport, write=FReport};
	__property Classes::TStream* Stream = {read=FStream, write=FStream};
	__property bool SlaveExport = {read=FSlaveExport, write=FSlaveExport, nodefault};
	__property System::UnicodeString DefaultExt = {read=FDefaultExt, write=FDefaultExt};
	__property System::UnicodeString FilterDesc = {read=FFilterDesc, write=FFilterDesc};
	__property bool SuppressPageHeadersFooters = {read=FSuppressPageHeadersFooters, write=FSuppressPageHeadersFooters, nodefault};
	__property System::UnicodeString ExportTitle = {read=FTitle, write=FTitle};
	__property Classes::TStrings* Files = {read=FFIles, write=FFIles};
	
__published:
	__property bool ShowDialog = {read=FShowDialog, write=FShowDialog, default=1};
	__property System::UnicodeString FileName = {read=FName, write=FName};
	__property bool ExportNotPrintable = {read=FExportNotPrintable, write=FExportNotPrintable, default=0};
	__property bool UseFileCache = {read=FUseFileCache, write=FUseFileCache, nodefault};
	__property System::UnicodeString DefaultPath = {read=FDefaultPath, write=FDefaultPath};
	__property bool ShowProgress = {read=FShowProgress, write=FShowProgress, nodefault};
	__property bool OverwritePrompt = {read=FOverwritePrompt, write=FOverwritePrompt, nodefault};
	__property Classes::TNotifyEvent OnBeginExport = {read=FOnBeginExport, write=FOnBeginExport};
};


class DELPHICLASS TfrxCustomWizard;
class PASCALIMPLEMENTATION TfrxCustomWizard : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	TfrxCustomDesigner* FDesigner;
	TfrxReport* FReport;
	
public:
	__fastcall virtual TfrxCustomWizard(Classes::TComponent* AOwner);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual bool __fastcall Execute(void) = 0 ;
	__property TfrxCustomDesigner* Designer = {read=FDesigner};
	__property TfrxReport* Report = {read=FReport};
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxCustomWizard(void) { }
	
};


typedef TMetaClass* TfrxWizardClass;

class PASCALIMPLEMENTATION TfrxCustomEngine : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	int FCurColumn;
	int FCurVColumn;
	int FCurLine;
	int FCurLineThrough;
	System::Extended FCurX;
	System::Extended FCurY;
	bool FFinalPass;
	Classes::TList* FNotifyList;
	System::Extended FPageHeight;
	System::Extended FPageWidth;
	TfrxCustomPreviewPages* FPreviewPages;
	TfrxReport* FReport;
	bool FRunning;
	System::TDateTime FStartDate;
	System::TDateTime FStartTime;
	int FTotalPages;
	TfrxRunDialogEvent FOnRunDialog;
	bool FSecondScriptCall;
	bool __fastcall GetDoublePass(void);
	
protected:
	virtual System::Extended __fastcall GetPageHeight(void);
	
public:
	__fastcall virtual TfrxCustomEngine(TfrxReport* AReport);
	__fastcall virtual ~TfrxCustomEngine(void);
	virtual void __fastcall EndPage(void) = 0 ;
	virtual void __fastcall BreakAllKeep(void);
	virtual void __fastcall NewColumn(void) = 0 ;
	virtual void __fastcall NewPage(void) = 0 ;
	virtual void __fastcall ShowBand(TfrxBand* Band) = 0 /* overload */;
	virtual void __fastcall ShowBand(TfrxBandClass Band) = 0 /* overload */;
	void __fastcall ShowBandByName(const System::UnicodeString BandName);
	void __fastcall StopReport(void);
	virtual System::Extended __fastcall HeaderHeight(void) = 0 ;
	virtual System::Extended __fastcall FooterHeight(void) = 0 ;
	virtual System::Extended __fastcall FreeSpace(void) = 0 ;
	virtual System::Variant __fastcall GetAggregateValue(const System::UnicodeString Name, const System::UnicodeString Expression, TfrxBand* Band, int Flags) = 0 ;
	virtual bool __fastcall Run(void) = 0 ;
	__property int CurLine = {read=FCurLine, write=FCurLine, nodefault};
	__property int CurLineThrough = {read=FCurLineThrough, write=FCurLineThrough, nodefault};
	__property Classes::TList* NotifyList = {read=FNotifyList};
	__property TfrxCustomPreviewPages* PreviewPages = {read=FPreviewPages};
	__property TfrxReport* Report = {read=FReport};
	__property bool Running = {read=FRunning, write=FRunning, nodefault};
	__property TfrxRunDialogEvent OnRunDialog = {read=FOnRunDialog, write=FOnRunDialog};
	
__published:
	__property int CurColumn = {read=FCurColumn, write=FCurColumn, nodefault};
	__property int CurVColumn = {read=FCurVColumn, write=FCurVColumn, nodefault};
	__property System::Extended CurX = {read=FCurX, write=FCurX};
	__property System::Extended CurY = {read=FCurY, write=FCurY};
	__property bool DoublePass = {read=GetDoublePass, nodefault};
	__property bool FinalPass = {read=FFinalPass, write=FFinalPass, nodefault};
	__property System::Extended PageHeight = {read=GetPageHeight, write=FPageHeight};
	__property System::Extended PageWidth = {read=FPageWidth, write=FPageWidth};
	__property System::TDateTime StartDate = {read=FStartDate, write=FStartDate};
	__property System::TDateTime StartTime = {read=FStartTime, write=FStartTime};
	__property int TotalPages = {read=FTotalPages, write=FTotalPages, nodefault};
	__property bool SecondScriptCall = {read=FSecondScriptCall, write=FSecondScriptCall, nodefault};
};


class DELPHICLASS TfrxCustomOutline;
class PASCALIMPLEMENTATION TfrxCustomOutline : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	Frxxml::TfrxXMLItem* FCurItem;
	TfrxCustomPreviewPages* FPreviewPages;
	
protected:
	virtual int __fastcall GetCount(void) = 0 ;
	
public:
	__fastcall virtual TfrxCustomOutline(TfrxCustomPreviewPages* APreviewPages);
	virtual void __fastcall AddItem(const System::UnicodeString Text, int Top) = 0 ;
	virtual void __fastcall LevelDown(int Index) = 0 ;
	virtual void __fastcall LevelRoot(void) = 0 ;
	virtual void __fastcall LevelUp(void) = 0 ;
	virtual void __fastcall GetItem(int Index, System::UnicodeString &Text, int &Page, int &Top) = 0 ;
	virtual void __fastcall ShiftItems(Frxxml::TfrxXMLItem* From, int NewTop) = 0 ;
	TfrxCustomEngine* __fastcall Engine(void);
	virtual Frxxml::TfrxXMLItem* __fastcall GetCurPosition(void) = 0 ;
	__property int Count = {read=GetCount, nodefault};
	__property Frxxml::TfrxXMLItem* CurItem = {read=FCurItem, write=FCurItem};
	__property TfrxCustomPreviewPages* PreviewPages = {read=FPreviewPages};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxCustomOutline(void) { }
	
};


class PASCALIMPLEMENTATION TfrxCustomPreviewPages : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TfrxAddPageAction FAddPageAction;
	int FCurPage;
	int FCurPreviewPage;
	TfrxCustomEngine* FEngine;
	int FFirstPage;
	TfrxCustomOutline* FOutline;
	TfrxReport* FReport;
	
protected:
	virtual int __fastcall GetCount(void) = 0 ;
	virtual TfrxReportPage* __fastcall GetPage(int Index) = 0 ;
	virtual Types::TPoint __fastcall GetPageSize(int Index) = 0 ;
	
public:
	__fastcall virtual TfrxCustomPreviewPages(TfrxReport* AReport);
	__fastcall virtual ~TfrxCustomPreviewPages(void);
	virtual void __fastcall Clear(void) = 0 ;
	virtual void __fastcall Initialize(void) = 0 ;
	virtual void __fastcall AddObject(TfrxComponent* Obj) = 0 ;
	virtual void __fastcall AddPage(TfrxReportPage* Page) = 0 ;
	virtual void __fastcall AddSourcePage(TfrxReportPage* Page) = 0 ;
	virtual void __fastcall AddToSourcePage(TfrxComponent* Obj) = 0 ;
	virtual void __fastcall BeginPass(void) = 0 ;
	virtual void __fastcall ClearFirstPassPages(void) = 0 ;
	virtual void __fastcall CutObjects(int APosition) = 0 ;
	virtual void __fastcall Finish(void) = 0 ;
	virtual void __fastcall IncLogicalPageNumber(void) = 0 ;
	virtual void __fastcall ResetLogicalPageNumber(void) = 0 ;
	virtual void __fastcall PasteObjects(System::Extended X, System::Extended Y) = 0 ;
	virtual void __fastcall ShiftAnchors(int From, int NewTop) = 0 ;
	virtual void __fastcall AddPicture(TfrxPictureView* Picture) = 0 ;
	virtual bool __fastcall BandExists(TfrxBand* Band) = 0 ;
	virtual int __fastcall GetCurPosition(void) = 0 ;
	virtual int __fastcall GetAnchorCurPosition(void) = 0 ;
	virtual System::Extended __fastcall GetLastY(System::Extended ColumnPosition = 0.000000E+00) = 0 ;
	virtual int __fastcall GetLogicalPageNo(void) = 0 ;
	virtual int __fastcall GetLogicalTotalPages(void) = 0 ;
	virtual void __fastcall AddEmptyPage(int Index) = 0 ;
	virtual void __fastcall DeletePage(int Index) = 0 ;
	virtual void __fastcall ModifyPage(int Index, TfrxReportPage* Page) = 0 ;
	virtual void __fastcall DrawPage(int Index, Graphics::TCanvas* Canvas, System::Extended ScaleX, System::Extended ScaleY, System::Extended OffsetX, System::Extended OffsetY) = 0 ;
	virtual void __fastcall ObjectOver(int Index, int X, int Y, Controls::TMouseButton Button, Classes::TShiftState Shift, System::Extended Scale, System::Extended OffsetX, System::Extended OffsetY, bool Click, Controls::TCursor &Cursor, bool DBClick = false) = 0 ;
	virtual void __fastcall AddFrom(TfrxReport* Report) = 0 ;
	virtual void __fastcall LoadFromStream(Classes::TStream* Stream, bool AllowPartialLoading = false) = 0 ;
	virtual void __fastcall SaveToStream(Classes::TStream* Stream) = 0 ;
	virtual bool __fastcall LoadFromFile(const System::UnicodeString FileName, bool ExceptionIfNotFound = false) = 0 ;
	virtual void __fastcall SaveToFile(const System::UnicodeString FileName) = 0 ;
	virtual bool __fastcall Print(void) = 0 ;
	virtual bool __fastcall Export(TfrxCustomExportFilter* Filter) = 0 ;
	__property TfrxAddPageAction AddPageAction = {read=FAddPageAction, write=FAddPageAction, nodefault};
	__property int Count = {read=GetCount, nodefault};
	__property int CurPage = {read=FCurPage, write=FCurPage, nodefault};
	__property int CurPreviewPage = {read=FCurPreviewPage, write=FCurPreviewPage, nodefault};
	__property TfrxCustomEngine* Engine = {read=FEngine};
	__property int FirstPage = {read=FFirstPage, write=FFirstPage, nodefault};
	__property TfrxCustomOutline* Outline = {read=FOutline};
	__property TfrxReportPage* Page[int Index] = {read=GetPage};
	__property Types::TPoint PageSize[int Index] = {read=GetPageSize};
	__property TfrxReport* Report = {read=FReport};
};


class PASCALIMPLEMENTATION TfrxCustomPreview : public Controls::TCustomControl
{
	typedef Controls::TCustomControl inherited;
	
private:
	TfrxCustomPreviewPages* FPreviewPages;
	TfrxReport* FReport;
	bool FUseReportHints;
	
public:
	virtual void __fastcall Init(void) = 0 ;
	virtual void __fastcall Lock(void) = 0 ;
	virtual void __fastcall Unlock(void) = 0 ;
	virtual void __fastcall RefreshReport(void) = 0 ;
	virtual void __fastcall InternalOnProgressStart(TfrxReport* Sender, TfrxProgressType ProgressType, int Progress) = 0 ;
	virtual void __fastcall InternalOnProgress(TfrxReport* Sender, TfrxProgressType ProgressType, int Progress) = 0 ;
	virtual void __fastcall InternalOnProgressStop(TfrxReport* Sender, TfrxProgressType ProgressType, int Progress) = 0 ;
	__property TfrxCustomPreviewPages* PreviewPages = {read=FPreviewPages, write=FPreviewPages};
	__property TfrxReport* Report = {read=FReport, write=FReport};
	__property bool UseReportHints = {read=FUseReportHints, write=FUseReportHints, nodefault};
public:
	/* TCustomControl.Create */ inline __fastcall virtual TfrxCustomPreview(Classes::TComponent* AOwner) : Controls::TCustomControl(AOwner) { }
	/* TCustomControl.Destroy */ inline __fastcall virtual ~TfrxCustomPreview(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxCustomPreview(HWND ParentWindow) : Controls::TCustomControl(ParentWindow) { }
	
};


typedef TMetaClass* TfrxCompressorClass;

class DELPHICLASS TfrxCustomCompressor;
class PASCALIMPLEMENTATION TfrxCustomCompressor : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	bool FIsFR3File;
	TfrxCompressorClass FOldCompressor;
	TfrxReport* FReport;
	Classes::TStream* FStream;
	System::UnicodeString FTempFile;
	
public:
	__fastcall virtual TfrxCustomCompressor(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxCustomCompressor(void);
	virtual bool __fastcall Decompress(Classes::TStream* Source) = 0 ;
	virtual void __fastcall Compress(Classes::TStream* Dest) = 0 ;
	void __fastcall CreateStream(void);
	__property bool IsFR3File = {read=FIsFR3File, write=FIsFR3File, nodefault};
	__property TfrxReport* Report = {read=FReport, write=FReport};
	__property Classes::TStream* Stream = {read=FStream, write=FStream};
};


typedef TMetaClass* TfrxCrypterClass;

class DELPHICLASS TfrxCustomCrypter;
class PASCALIMPLEMENTATION TfrxCustomCrypter : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	Classes::TStream* FStream;
	
public:
	__fastcall virtual TfrxCustomCrypter(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxCustomCrypter(void);
	virtual bool __fastcall Decrypt(Classes::TStream* Source, const System::AnsiString Key) = 0 ;
	virtual void __fastcall Crypt(Classes::TStream* Dest, const System::AnsiString Key) = 0 ;
	void __fastcall CreateStream(void);
	__property Classes::TStream* Stream = {read=FStream, write=FStream};
};


typedef bool __fastcall (__closure *TfrxLoadEvent)(TfrxReport* Sender, Classes::TStream* Stream);

typedef System::Variant __fastcall (__closure *TfrxGetScriptValueEvent)(System::Variant &Params);

class DELPHICLASS TfrxFR2Events;
class PASCALIMPLEMENTATION TfrxFR2Events : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TfrxGetValueEvent FOnGetValue;
	Classes::TNotifyEvent FOnPrepareScript;
	TfrxLoadEvent FOnLoad;
	TfrxGetScriptValueEvent FOnGetScriptValue;
	System::UnicodeString FFilter;
	
public:
	__property TfrxGetValueEvent OnGetValue = {read=FOnGetValue, write=FOnGetValue};
	__property Classes::TNotifyEvent OnPrepareScript = {read=FOnPrepareScript, write=FOnPrepareScript};
	__property TfrxLoadEvent OnLoad = {read=FOnLoad, write=FOnLoad};
	__property TfrxGetScriptValueEvent OnGetScriptValue = {read=FOnGetScriptValue, write=FOnGetScriptValue};
	__property System::UnicodeString Filter = {read=FFilter, write=FFilter};
public:
	/* TObject.Create */ inline __fastcall TfrxFR2Events(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxFR2Events(void) { }
	
};


class DELPHICLASS TfrxGlobalDataSetList;
class PASCALIMPLEMENTATION TfrxGlobalDataSetList : public Classes::TList
{
	typedef Classes::TList inherited;
	
public:
	Syncobjs::TCriticalSection* FCriticalSection;
	__fastcall TfrxGlobalDataSetList(void);
	__fastcall virtual ~TfrxGlobalDataSetList(void);
	void __fastcall Lock(void);
	void __fastcall Unlock(void);
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE System::Extended fr01cm;
extern PACKAGE System::Extended fr1cm;
extern PACKAGE System::Extended fr01in;
extern PACKAGE int fr1in;
extern PACKAGE System::Extended fr1CharX;
extern PACKAGE int fr1CharY;
extern PACKAGE Graphics::TColor clTransparent;
extern PACKAGE int crHand;
extern PACKAGE int crZoom;
extern PACKAGE int crFormat;
extern PACKAGE System::UnicodeString DEF_REG_CONNECTIONS;
static const Word WM_CREATEHANDLE = 0x401;
static const Word WM_DESTROYHANDLE = 0x402;
extern PACKAGE TfrxDesignerClass frxDesignerClass;
extern PACKAGE TfrxCustomExportFilter* frxDotMatrixExport;
extern PACKAGE TfrxCompressorClass frxCompressorClass;
extern PACKAGE TfrxCrypterClass frxCrypterClass;
extern PACKAGE int frxCharset;
extern PACKAGE TfrxFR2Events* frxFR2Events;
extern PACKAGE Syncobjs::TCriticalSection* frxCS;
extern PACKAGE Frxvariables::TfrxVariables* frxGlobalVariables;
#define FR_VERSION L"4.10.5"
static const ShortInt BND_COUNT = 0x12;
extern PACKAGE StaticArray<TfrxComponentClass, 18> frxBands;
extern PACKAGE Forms::TForm* __fastcall frxParentForm(void);
extern PACKAGE TfrxDataSet* __fastcall frxFindDataSet(TfrxDataSet* DataSet, const System::UnicodeString Name, Classes::TComponent* Owner);
extern PACKAGE void __fastcall frxGetDataSetList(Classes::TStrings* List);

}	/* namespace Frxclass */
using namespace Frxclass;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxclassHPP
