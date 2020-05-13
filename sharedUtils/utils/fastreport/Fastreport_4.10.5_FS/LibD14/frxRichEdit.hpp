// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxrichedit.pas' rev: 21.00

#ifndef FrxricheditHPP
#define FrxricheditHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Comobj.hpp>	// Pascal unit
#include <Commctrl.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Richedit.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxrichedit
{
//-- type declarations -------------------------------------------------------
typedef ShortInt TRichEditVersion;

struct TCharFormat2A
{
	
public:
	unsigned cbSize;
	unsigned dwMask;
	unsigned dwEffects;
	int yHeight;
	int yOffset;
	unsigned crTextColor;
	System::Byte bCharSet;
	System::Byte bPitchAndFamily;
	StaticArray<System::WideChar, 32> szFaceName;
	System::Word wWeight;
	short sSpacing;
	unsigned crBackColor;
	unsigned lid;
	unsigned dwReserved;
	short sStyle;
	System::Word wKerning;
	System::Byte bUnderlineType;
	System::Byte bAnimation;
	System::Byte bRevAuthor;
	System::Byte bReserved1;
};


typedef TCharFormat2A TCharFormat2;

struct TParaFormat2
{
	
public:
	unsigned cbSize;
	unsigned dwMask;
	System::Word wNumbering;
	System::Word wReserved;
	int dxStartIndent;
	int dxRightIndent;
	int dxOffset;
	System::Word wAlignment;
	short cTabCount;
	StaticArray<int, 32> rgxTabs;
	int dySpaceBefore;
	int dySpaceAfter;
	int dyLineSpacing;
	short sStyle;
	System::Byte bLineSpacingRule;
	System::Byte bCRC;
	System::Word wShadingWeight;
	System::Word wShadingStyle;
	System::Word wNumberingStart;
	System::Word wNumberingStyle;
	System::Word wNumberingTab;
	System::Word wBorderSpace;
	System::Word wBorderWidth;
	System::Word wBorders;
};


#pragma option push -b-
enum TRxAttributeType { atDefaultText, atSelected, atWord };
#pragma option pop

#pragma option push -b-
enum TRxConsistentAttribute { caBold, caColor, caFace, caItalic, caSize, caStrikeOut, caUnderline, caProtected, caOffset, caHidden, caLink, caBackColor, caDisabled, caWeight, caSubscript, caRevAuthor };
#pragma option pop

typedef Set<TRxConsistentAttribute, caBold, caRevAuthor>  TRxConsistentAttributes;

#pragma option push -b-
enum TSubscriptStyle { ssNone, ssSubscript, ssSuperscript };
#pragma option pop

#pragma option push -b-
enum TUnderlineType { utNone, utSolid, utWord, utDouble, utDotted, utWave };
#pragma option pop

class DELPHICLASS TRxTextAttributes;
class DELPHICLASS TRxCustomRichEdit;
class PASCALIMPLEMENTATION TRxTextAttributes : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	TRxCustomRichEdit* RichEdit;
	TRxAttributeType FType;
	void __fastcall AssignFont(Graphics::TFont* Font);
	void __fastcall GetAttributes(TCharFormat2A &Format);
	Graphics::TFontCharset __fastcall GetCharset(void);
	void __fastcall SetCharset(Graphics::TFontCharset Value);
	TSubscriptStyle __fastcall GetSubscriptStyle(void);
	void __fastcall SetSubscriptStyle(TSubscriptStyle Value);
	Graphics::TColor __fastcall GetBackColor(void);
	Graphics::TColor __fastcall GetColor(void);
	TRxConsistentAttributes __fastcall GetConsistentAttributes(void);
	int __fastcall GetHeight(void);
	bool __fastcall GetHidden(void);
	bool __fastcall GetDisabled(void);
	bool __fastcall GetLink(void);
	Graphics::TFontName __fastcall GetName(void);
	int __fastcall GetOffset(void);
	Graphics::TFontPitch __fastcall GetPitch(void);
	bool __fastcall GetProtected(void);
	System::Byte __fastcall GetRevAuthorIndex(void);
	int __fastcall GetSize(void);
	Graphics::TFontStyles __fastcall GetStyle(void);
	TUnderlineType __fastcall GetUnderlineType(void);
	void __fastcall SetAttributes(TCharFormat2A &Format);
	void __fastcall SetBackColor(Graphics::TColor Value);
	void __fastcall SetColor(Graphics::TColor Value);
	void __fastcall SetDisabled(bool Value);
	void __fastcall SetHeight(int Value);
	void __fastcall SetHidden(bool Value);
	void __fastcall SetLink(bool Value);
	void __fastcall SetName(Graphics::TFontName Value);
	void __fastcall SetOffset(int Value);
	void __fastcall SetPitch(Graphics::TFontPitch Value);
	void __fastcall SetProtected(bool Value);
	void __fastcall SetRevAuthorIndex(System::Byte Value);
	void __fastcall SetSize(int Value);
	void __fastcall SetStyle(Graphics::TFontStyles Value);
	void __fastcall SetUnderlineType(TUnderlineType Value);
	
protected:
	void __fastcall InitFormat(TCharFormat2A &Format);
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	
public:
	__fastcall TRxTextAttributes(TRxCustomRichEdit* AOwner, TRxAttributeType AttributeType);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property Graphics::TFontCharset Charset = {read=GetCharset, write=SetCharset, nodefault};
	__property Graphics::TColor BackColor = {read=GetBackColor, write=SetBackColor, nodefault};
	__property Graphics::TColor Color = {read=GetColor, write=SetColor, nodefault};
	__property TRxConsistentAttributes ConsistentAttributes = {read=GetConsistentAttributes, nodefault};
	__property bool Disabled = {read=GetDisabled, write=SetDisabled, nodefault};
	__property bool Hidden = {read=GetHidden, write=SetHidden, nodefault};
	__property bool Link = {read=GetLink, write=SetLink, nodefault};
	__property Graphics::TFontName Name = {read=GetName, write=SetName};
	__property int Offset = {read=GetOffset, write=SetOffset, nodefault};
	__property Graphics::TFontPitch Pitch = {read=GetPitch, write=SetPitch, nodefault};
	__property bool Protected = {read=GetProtected, write=SetProtected, nodefault};
	__property System::Byte RevAuthorIndex = {read=GetRevAuthorIndex, write=SetRevAuthorIndex, nodefault};
	__property TSubscriptStyle SubscriptStyle = {read=GetSubscriptStyle, write=SetSubscriptStyle, nodefault};
	__property int Size = {read=GetSize, write=SetSize, nodefault};
	__property Graphics::TFontStyles Style = {read=GetStyle, write=SetStyle, nodefault};
	__property int Height = {read=GetHeight, write=SetHeight, nodefault};
	__property TUnderlineType UnderlineType = {read=GetUnderlineType, write=SetUnderlineType, nodefault};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TRxTextAttributes(void) { }
	
};


#pragma option push -b-
enum TRxNumbering { nsNone, nsBullet, nsArabicNumbers, nsLoCaseLetter, nsUpCaseLetter, nsLoCaseRoman, nsUpCaseRoman };
#pragma option pop

#pragma option push -b-
enum TRxNumberingStyle { nsParenthesis, nsPeriod, nsEnclosed, nsSimple };
#pragma option pop

#pragma option push -b-
enum TParaAlignment { paLeftJustify, paRightJustify, paCenter, paJustify };
#pragma option pop

#pragma option push -b-
enum TLineSpacingRule { lsSingle, lsOneAndHalf, lsDouble, lsSpecifiedOrMore, lsSpecified, lsMultiple };
#pragma option pop

typedef ShortInt THeadingStyle;

#pragma option push -b-
enum TParaTableStyle { tsNone, tsTableRow, tsTableCellEnd, tsTableCell };
#pragma option pop

class DELPHICLASS TRxParaAttributes;
class PASCALIMPLEMENTATION TRxParaAttributes : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	TRxCustomRichEdit* RichEdit;
	void __fastcall GetAttributes(TParaFormat2 &Paragraph);
	TParaAlignment __fastcall GetAlignment(void);
	int __fastcall GetFirstIndent(void);
	THeadingStyle __fastcall GetHeadingStyle(void);
	int __fastcall GetLeftIndent(void);
	int __fastcall GetRightIndent(void);
	int __fastcall GetSpaceAfter(void);
	int __fastcall GetSpaceBefore(void);
	int __fastcall GetLineSpacing(void);
	TLineSpacingRule __fastcall GetLineSpacingRule(void);
	TRxNumbering __fastcall GetNumbering(void);
	TRxNumberingStyle __fastcall GetNumberingStyle(void);
	System::Word __fastcall GetNumberingTab(void);
	int __fastcall GetTab(System::Byte Index);
	int __fastcall GetTabCount(void);
	TParaTableStyle __fastcall GetTableStyle(void);
	void __fastcall SetAlignment(TParaAlignment Value);
	void __fastcall SetAttributes(TParaFormat2 &Paragraph);
	void __fastcall SetFirstIndent(int Value);
	void __fastcall SetHeadingStyle(THeadingStyle Value);
	void __fastcall SetLeftIndent(int Value);
	void __fastcall SetRightIndent(int Value);
	void __fastcall SetSpaceAfter(int Value);
	void __fastcall SetSpaceBefore(int Value);
	void __fastcall SetLineSpacing(int Value);
	void __fastcall SetLineSpacingRule(TLineSpacingRule Value);
	void __fastcall SetNumbering(TRxNumbering Value);
	void __fastcall SetNumberingStyle(TRxNumberingStyle Value);
	void __fastcall SetNumberingTab(System::Word Value);
	void __fastcall SetTab(System::Byte Index, int Value);
	void __fastcall SetTabCount(int Value);
	void __fastcall SetTableStyle(TParaTableStyle Value);
	
protected:
	void __fastcall InitPara(TParaFormat2 &Paragraph);
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	
public:
	__fastcall TRxParaAttributes(TRxCustomRichEdit* AOwner);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property TParaAlignment Alignment = {read=GetAlignment, write=SetAlignment, nodefault};
	__property int FirstIndent = {read=GetFirstIndent, write=SetFirstIndent, nodefault};
	__property THeadingStyle HeadingStyle = {read=GetHeadingStyle, write=SetHeadingStyle, nodefault};
	__property int LeftIndent = {read=GetLeftIndent, write=SetLeftIndent, nodefault};
	__property int LineSpacing = {read=GetLineSpacing, write=SetLineSpacing, nodefault};
	__property TLineSpacingRule LineSpacingRule = {read=GetLineSpacingRule, write=SetLineSpacingRule, nodefault};
	__property TRxNumbering Numbering = {read=GetNumbering, write=SetNumbering, nodefault};
	__property TRxNumberingStyle NumberingStyle = {read=GetNumberingStyle, write=SetNumberingStyle, nodefault};
	__property System::Word NumberingTab = {read=GetNumberingTab, write=SetNumberingTab, nodefault};
	__property int RightIndent = {read=GetRightIndent, write=SetRightIndent, nodefault};
	__property int SpaceAfter = {read=GetSpaceAfter, write=SetSpaceAfter, nodefault};
	__property int SpaceBefore = {read=GetSpaceBefore, write=SetSpaceBefore, nodefault};
	__property int Tab[System::Byte Index] = {read=GetTab, write=SetTab};
	__property int TabCount = {read=GetTabCount, write=SetTabCount, nodefault};
	__property TParaTableStyle TableStyle = {read=GetTableStyle, write=SetTableStyle, nodefault};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TRxParaAttributes(void) { }
	
};


class DELPHICLASS TOEMConversion;
class PASCALIMPLEMENTATION TOEMConversion : public Comctrls::TConversion
{
	typedef Comctrls::TConversion inherited;
	
public:
	virtual int __fastcall ConvertReadStream(Classes::TStream* Stream, Sysutils::TBytes Buffer, int BufSize);
	virtual int __fastcall ConvertWriteStream(Classes::TStream* Stream, Sysutils::TBytes Buffer, int BufSize);
public:
	/* TConversion.Create */ inline __fastcall virtual TOEMConversion(void) : Comctrls::TConversion() { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TOEMConversion(void) { }
	
};


#pragma option push -b-
enum TUndoName { unUnknown, unTyping, unDelete, unDragDrop, unCut, unPaste };
#pragma option pop

#pragma option push -b-
enum TRichSearchType { stWholeWord, stMatchCase, stBackward, stSetSelection };
#pragma option pop

typedef Set<TRichSearchType, stWholeWord, stSetSelection>  TRichSearchTypes;

#pragma option push -b-
enum TRichSelection { stText, stObject, stMultiChar, stMultiObject };
#pragma option pop

typedef Set<TRichSelection, stText, stMultiObject>  TRichSelectionType;

#pragma option push -b-
enum TRichLangOption { rlAutoKeyboard, rlAutoFont, rlImeCancelComplete, rlImeAlwaysSendNotify };
#pragma option pop

typedef Set<TRichLangOption, rlAutoKeyboard, rlImeAlwaysSendNotify>  TRichLangOptions;

#pragma option push -b-
enum TRichStreamFormat { sfDefault, sfRichText, sfPlainText };
#pragma option pop

#pragma option push -b-
enum TRichStreamMode { smSelection, smPlainRtf, smNoObjects, smUnicode };
#pragma option pop

typedef Set<TRichStreamMode, smSelection, smUnicode>  TRichStreamModes;

typedef void __fastcall (__closure *TRichEditURLClickEvent)(System::TObject* Sender, const System::UnicodeString URLText, Controls::TMouseButton Button);

typedef void __fastcall (__closure *TRichEditProtectChangeEx)(System::TObject* Sender, const Messages::TMessage &Message, int StartPos, int EndPos, bool &AllowChange);

typedef void __fastcall (__closure *TRichEditFindErrorEvent)(System::TObject* Sender, const System::UnicodeString FindText);

typedef void __fastcall (__closure *TRichEditFindCloseEvent)(System::TObject* Sender, Dialogs::TFindDialog* Dialog);

struct TRichConversionFormat;
typedef TRichConversionFormat *PRichConversionFormat;

struct TRichConversionFormat
{
	
public:
	Comctrls::TConversionClass ConversionClass;
	System::UnicodeString Extension;
	bool PlainText;
	TRichConversionFormat *Next;
};


class PASCALIMPLEMENTATION TRxCustomRichEdit : public Stdctrls::TCustomMemo
{
	typedef Stdctrls::TCustomMemo inherited;
	
private:
	bool FHideScrollBars;
	bool FSelectionBar;
	bool FAutoURLDetect;
	bool FWordSelection;
	bool FPlainText;
	TRxTextAttributes* FSelAttributes;
	TRxTextAttributes* FDefAttributes;
	TRxTextAttributes* FWordAttributes;
	TRxParaAttributes* FParagraph;
	TParaAlignment FOldParaAlignment;
	int FScreenLogPixels;
	int FUndoLimit;
	Classes::TStrings* FRichEditStrings;
	Classes::TMemoryStream* FMemStream;
	bool FHideSelection;
	TRichLangOptions FLangOptions;
	bool FModified;
	bool FLinesUpdating;
	Types::TRect FPageRect;
	_charrange FClickRange;
	Controls::TMouseButton FClickBtn;
	Dialogs::TFindDialog* FFindDialog;
	Dialogs::TReplaceDialog* FReplaceDialog;
	Dialogs::TFindDialog* FLastFind;
	bool FAllowObjects;
	System::TObject* FCallback;
	System::_di_IInterface FRichEditOle;
	Menus::TPopupMenu* FPopupVerbMenu;
	System::UnicodeString FTitle;
	bool FAutoVerbMenu;
	bool FAllowInPlace;
	Comctrls::TConversionClass FDefaultConverter;
	Classes::TNotifyEvent FOnSelChange;
	Comctrls::TRichEditResizeEvent FOnResizeRequest;
	Comctrls::TRichEditProtectChange FOnProtectChange;
	TRichEditProtectChangeEx FOnProtectChangeEx;
	Comctrls::TRichEditSaveClipboard FOnSaveClipboard;
	TRichEditURLClickEvent FOnURLClick;
	TRichEditFindErrorEvent FOnTextNotFound;
	TRichEditFindCloseEvent FOnCloseFindDialog;
	bool __fastcall GetAutoURLDetect(void);
	bool __fastcall GetWordSelection(void);
	TRichLangOptions __fastcall GetLangOptions(void);
	bool __fastcall GetCanRedo(void);
	bool __fastcall GetCanPaste(void);
	TUndoName __fastcall GetRedoName(void);
	TUndoName __fastcall GetUndoName(void);
	TRichStreamFormat __fastcall GetStreamFormat(void);
	TRichStreamModes __fastcall GetStreamMode(void);
	TRichSelectionType __fastcall GetSelectionType(void);
	void __fastcall PopupVerbClick(System::TObject* Sender);
	void __fastcall ObjectPropsClick(System::TObject* Sender);
	void __fastcall CloseObjects(void);
	void __fastcall UpdateHostNames(void);
	void __fastcall SetAllowObjects(bool Value);
	void __fastcall SetStreamFormat(TRichStreamFormat Value);
	void __fastcall SetStreamMode(TRichStreamModes Value);
	void __fastcall SetAutoURLDetect(bool Value);
	void __fastcall SetWordSelection(bool Value);
	void __fastcall SetHideScrollBars(bool Value);
	HIDESBASE void __fastcall SetHideSelection(bool Value);
	void __fastcall SetTitle(const System::UnicodeString Value);
	void __fastcall SetLangOptions(TRichLangOptions Value);
	void __fastcall SetRichEditStrings(Classes::TStrings* Value);
	void __fastcall SetDefAttributes(TRxTextAttributes* Value);
	void __fastcall SetSelAttributes(TRxTextAttributes* Value);
	void __fastcall SetWordAttributes(TRxTextAttributes* Value);
	void __fastcall SetSelectionBar(bool Value);
	void __fastcall SetUndoLimit(int Value);
	void __fastcall UpdateTextModes(bool Plain);
	void __fastcall AdjustFindDialogPosition(Dialogs::TFindDialog* Dialog);
	void __fastcall SetupFindDialog(Dialogs::TFindDialog* Dialog, const System::UnicodeString SearchStr, const System::UnicodeString ReplaceStr);
	bool __fastcall FindEditText(Dialogs::TFindDialog* Dialog, bool AdjustPos, bool Events);
	bool __fastcall GetCanFindNext(void);
	void __fastcall FindDialogFind(System::TObject* Sender);
	void __fastcall ReplaceDialogReplace(System::TObject* Sender);
	void __fastcall FindDialogClose(System::TObject* Sender);
	void __fastcall SetUIActive(bool Active);
	MESSAGE void __fastcall CMDocWindowActivate(Messages::TMessage &Message);
	MESSAGE void __fastcall CMUIDeactivate(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMBiDiModeChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMColorChanged(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	MESSAGE void __fastcall CNNotify(Messages::TWMNotify &Message);
	MESSAGE void __fastcall EMReplaceSel(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMDestroy(Messages::TWMNoParams &Msg);
	HIDESBASE MESSAGE void __fastcall WMMouseMove(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMPaint(Messages::TWMPaint &Message);
	HIDESBASE MESSAGE void __fastcall WMSetCursor(Messages::TWMSetCursor &Message);
	HIDESBASE MESSAGE void __fastcall WMSetFont(Messages::TWMSetFont &Message);
	HIDESBASE MESSAGE void __fastcall WMRButtonUp(Messages::TMessage &Message);
	
protected:
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	virtual void __fastcall CreateWindowHandle(const Controls::TCreateParams &Params);
	virtual void __fastcall CreateWnd(void);
	virtual void __fastcall DestroyWnd(void);
	DYNAMIC Menus::TPopupMenu* __fastcall GetPopupMenu(void);
	virtual void __fastcall TextNotFound(Dialogs::TFindDialog* Dialog);
	virtual void __fastcall RequestSize(const Types::TRect &Rect);
	DYNAMIC void __fastcall SelectionChange(void);
	DYNAMIC bool __fastcall ProtectChange(const Messages::TMessage &Message, int StartPos, int EndPos);
	DYNAMIC bool __fastcall SaveClipboard(int NumObj, int NumChars);
	DYNAMIC void __fastcall URLClick(const System::UnicodeString URLText, Controls::TMouseButton Button);
	virtual void __fastcall SetPlainText(bool Value);
	virtual void __fastcall CloseFindDialog(Dialogs::TFindDialog* Dialog);
	virtual void __fastcall DoSetMaxLength(int Value);
	virtual int __fastcall GetSelLength(void);
	virtual int __fastcall GetSelStart(void);
	virtual System::UnicodeString __fastcall GetSelText(void);
	virtual void __fastcall SetSelLength(int Value);
	virtual void __fastcall SetSelStart(int Value);
	__property bool AllowInPlace = {read=FAllowInPlace, write=FAllowInPlace, default=1};
	__property bool AllowObjects = {read=FAllowObjects, write=SetAllowObjects, default=1};
	__property bool AutoURLDetect = {read=GetAutoURLDetect, write=SetAutoURLDetect, default=1};
	__property bool AutoVerbMenu = {read=FAutoVerbMenu, write=FAutoVerbMenu, default=1};
	__property bool HideSelection = {read=FHideSelection, write=SetHideSelection, default=1};
	__property bool HideScrollBars = {read=FHideScrollBars, write=SetHideScrollBars, default=1};
	__property System::UnicodeString Title = {read=FTitle, write=SetTitle};
	__property TRichLangOptions LangOptions = {read=GetLangOptions, write=SetLangOptions, default=2};
	__property Classes::TStrings* Lines = {read=FRichEditStrings, write=SetRichEditStrings};
	__property bool PlainText = {read=FPlainText, write=SetPlainText, default=0};
	__property bool SelectionBar = {read=FSelectionBar, write=SetSelectionBar, default=1};
	__property TRichStreamFormat StreamFormat = {read=GetStreamFormat, write=SetStreamFormat, default=0};
	__property TRichStreamModes StreamMode = {read=GetStreamMode, write=SetStreamMode, default=0};
	__property int UndoLimit = {read=FUndoLimit, write=SetUndoLimit, default=100};
	__property bool WordSelection = {read=GetWordSelection, write=SetWordSelection, default=1};
	__property ScrollBars = {default=3};
	__property TabStop = {default=1};
	__property Comctrls::TRichEditSaveClipboard OnSaveClipboard = {read=FOnSaveClipboard, write=FOnSaveClipboard};
	__property Classes::TNotifyEvent OnSelectionChange = {read=FOnSelChange, write=FOnSelChange};
	__property Comctrls::TRichEditProtectChange OnProtectChange = {read=FOnProtectChange, write=FOnProtectChange};
	__property TRichEditProtectChangeEx OnProtectChangeEx = {read=FOnProtectChangeEx, write=FOnProtectChangeEx};
	__property Comctrls::TRichEditResizeEvent OnResizeRequest = {read=FOnResizeRequest, write=FOnResizeRequest};
	__property TRichEditURLClickEvent OnURLClick = {read=FOnURLClick, write=FOnURLClick};
	__property TRichEditFindErrorEvent OnTextNotFound = {read=FOnTextNotFound, write=FOnTextNotFound};
	__property TRichEditFindCloseEvent OnCloseFindDialog = {read=FOnCloseFindDialog, write=FOnCloseFindDialog};
	
public:
	__fastcall virtual TRxCustomRichEdit(Classes::TComponent* AOwner);
	__fastcall virtual ~TRxCustomRichEdit(void);
	virtual void __fastcall Clear(void);
	HIDESBASE int __fastcall GetTextLen(void);
	void __fastcall SetSelection(int StartPos, int EndPos, bool ScrollCaret);
	_charrange __fastcall GetSelection(void);
	System::UnicodeString __fastcall GetTextRange(int StartPos, int EndPos);
	int __fastcall LineFromChar(int CharIndex);
	int __fastcall GetLineIndex(int LineNo);
	int __fastcall GetLineLength(int CharIndex);
	System::UnicodeString __fastcall WordAtCursor(void);
	int __fastcall FindText(const System::UnicodeString SearchStr, int StartPos, int Length, TRichSearchTypes Options);
	virtual int __fastcall GetSelTextBuf(System::WideChar * Buffer, int BufSize);
	virtual Types::TPoint __fastcall GetCaretPos(void);
	Types::TPoint __fastcall GetCharPos(int CharIndex);
	bool __fastcall InsertObjectDialog(void);
	bool __fastcall ObjectPropertiesDialog(void);
	bool __fastcall PasteSpecialDialog(void);
	Dialogs::TFindDialog* __fastcall FindDialog(const System::UnicodeString SearchStr);
	Dialogs::TReplaceDialog* __fastcall ReplaceDialog(const System::UnicodeString SearchStr, const System::UnicodeString ReplaceStr);
	bool __fastcall FindNext(void);
	virtual void __fastcall Print(const System::UnicodeString Caption);
	__classmethod void __fastcall RegisterConversionFormat(const System::UnicodeString AExtension, bool APlainText, Comctrls::TConversionClass AConversionClass);
	HIDESBASE void __fastcall ClearUndo(void);
	void __fastcall Redo(void);
	void __fastcall StopGroupTyping(void);
	__property bool CanFindNext = {read=GetCanFindNext, nodefault};
	__property bool CanRedo = {read=GetCanRedo, nodefault};
	__property bool CanPaste = {read=GetCanPaste, nodefault};
	__property TUndoName RedoName = {read=GetRedoName, nodefault};
	__property TUndoName UndoName = {read=GetUndoName, nodefault};
	__property Comctrls::TConversionClass DefaultConverter = {read=FDefaultConverter, write=FDefaultConverter};
	__property TRxTextAttributes* DefAttributes = {read=FDefAttributes, write=SetDefAttributes};
	__property TRxTextAttributes* SelAttributes = {read=FSelAttributes, write=SetSelAttributes};
	__property TRxTextAttributes* WordAttributes = {read=FWordAttributes, write=SetWordAttributes};
	__property Types::TRect PageRect = {read=FPageRect, write=FPageRect};
	__property TRxParaAttributes* Paragraph = {read=FParagraph};
	__property TRichSelectionType SelectionType = {read=GetSelectionType, nodefault};
public:
	/* TWinControl.CreateParented */ inline __fastcall TRxCustomRichEdit(HWND ParentWindow) : Stdctrls::TCustomMemo(ParentWindow) { }
	
};


class DELPHICLASS TRxRichEdit;
class PASCALIMPLEMENTATION TRxRichEdit : public TRxCustomRichEdit
{
	typedef TRxCustomRichEdit inherited;
	
__published:
	__property Align = {default=0};
	__property Alignment = {default=0};
	__property AutoURLDetect = {default=1};
	__property AutoVerbMenu = {default=1};
	__property AllowObjects = {default=1};
	__property AllowInPlace = {default=1};
	__property Anchors = {default=3};
	__property BiDiMode;
	__property BorderWidth = {default=0};
	__property DragKind = {default=0};
	__property BorderStyle = {default=1};
	__property Color = {default=-16777211};
	__property Ctl3D;
	__property DragCursor = {default=-12};
	__property DragMode = {default=0};
	__property Enabled = {default=1};
	__property Font;
	__property HideSelection = {default=1};
	__property HideScrollBars = {default=1};
	__property Title;
	__property ImeMode = {default=3};
	__property ImeName;
	__property Constraints;
	__property ParentBiDiMode = {default=1};
	__property LangOptions = {default=2};
	__property Lines;
	__property MaxLength = {default=0};
	__property ParentColor = {default=0};
	__property ParentCtl3D = {default=1};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PlainText = {default=0};
	__property PopupMenu;
	__property ReadOnly = {default=0};
	__property ScrollBars = {default=3};
	__property SelectionBar = {default=1};
	__property ShowHint;
	__property StreamFormat = {default=0};
	__property StreamMode = {default=0};
	__property TabOrder = {default=-1};
	__property TabStop = {default=1};
	__property UndoLimit = {default=100};
	__property Visible = {default=1};
	__property WantTabs = {default=0};
	__property WantReturns = {default=1};
	__property WordSelection = {default=1};
	__property WordWrap = {default=1};
	__property OnChange;
	__property OnDblClick;
	__property OnDragDrop;
	__property OnDragOver;
	__property OnContextPopup;
	__property OnEndDock;
	__property OnStartDock;
	__property OnEndDrag;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnKeyPress;
	__property OnKeyUp;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
	__property OnMouseWheel;
	__property OnMouseWheelDown;
	__property OnMouseWheelUp;
	__property OnProtectChange;
	__property OnProtectChangeEx;
	__property OnResizeRequest;
	__property OnSaveClipboard;
	__property OnSelectionChange;
	__property OnStartDrag;
	__property OnTextNotFound;
	__property OnCloseFindDialog;
	__property OnURLClick;
public:
	/* TRxCustomRichEdit.Create */ inline __fastcall virtual TRxRichEdit(Classes::TComponent* AOwner) : TRxCustomRichEdit(AOwner) { }
	/* TRxCustomRichEdit.Destroy */ inline __fastcall virtual ~TRxRichEdit(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TRxRichEdit(HWND ParentWindow) : TRxCustomRichEdit(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TRichEditVersion RichEditVersion;

}	/* namespace Frxrichedit */
using namespace Frxrichedit;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxricheditHPP
