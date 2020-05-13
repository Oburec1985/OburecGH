// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fqbsynmemo.pas' rev: 21.00

#ifndef FqbsynmemoHPP
#define FqbsynmemoHPP

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
#include <Stdctrls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fqbsynmemo
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TSyntaxType { stPascal, stCpp, stSQL, stText };
#pragma option pop

#pragma option push -b-
enum TCharAttr { caNone, caText, caBlock, caComment, caKeyword, caString };
#pragma option pop

typedef Set<TCharAttr, caNone, caString>  TCharAttributes;

class DELPHICLASS TfqbSyntaxMemo;
class PASCALIMPLEMENTATION TfqbSyntaxMemo : public Controls::TCustomControl
{
	typedef Controls::TCustomControl inherited;
	
private:
	typedef DynamicArray<int> _TfqbSyntaxMemo__1;
	
	
private:
	bool FAllowLinesChange;
	int FCharHeight;
	int FCharWidth;
	bool FDoubleClicked;
	bool FDown;
	int FGutterWidth;
	int FFooterHeight;
	bool FIsMonoType;
	System::UnicodeString FKeywords;
	int FMaxLength;
	System::UnicodeString FMessage;
	bool FModified;
	bool FMoved;
	Types::TPoint FOffset;
	Types::TPoint FPos;
	bool FReadOnly;
	Types::TPoint FSelEnd;
	Types::TPoint FSelStart;
	Classes::TStrings* FSynStrings;
	TSyntaxType FSyntaxType;
	Types::TPoint FTempPos;
	Classes::TStringList* FText;
	Graphics::TFont* FKeywordAttr;
	Graphics::TFont* FStringAttr;
	Graphics::TFont* FTextAttr;
	Graphics::TFont* FCommentAttr;
	Graphics::TColor FBlockColor;
	Graphics::TColor FBlockFontColor;
	Classes::TStringList* FUndo;
	bool FUpdating;
	bool FUpdatingSyntax;
	Stdctrls::TScrollBar* FVScroll;
	Types::TPoint FWindowSize;
	Menus::TPopupMenu* FPopupMenu;
	int KWheel;
	System::UnicodeString LastSearch;
	bool FShowGutter;
	bool FShowFooter;
	_TfqbSyntaxMemo__1 Bookmarks;
	int FActiveLine;
	HIDESBASE Classes::TStrings* __fastcall GetText(void);
	HIDESBASE void __fastcall SetText(Classes::TStrings* Value);
	void __fastcall SetSyntaxType(TSyntaxType Value);
	void __fastcall SetShowGutter(bool Value);
	void __fastcall SetShowFooter(bool Value);
	bool __fastcall FMemoFind(System::UnicodeString Text, Types::TPoint &Position);
	TCharAttributes __fastcall GetCharAttr(const Types::TPoint &Pos);
	int __fastcall GetLineBegin(int Index);
	int __fastcall GetPlainTextPos(const Types::TPoint &Pos);
	Types::TPoint __fastcall GetPosPlainText(int Pos);
	System::UnicodeString __fastcall GetSelText(void);
	System::UnicodeString __fastcall LineAt(int Index);
	int __fastcall LineLength(int Index);
	System::UnicodeString __fastcall Pad(int n);
	void __fastcall AddSel(void);
	void __fastcall AddUndo(void);
	void __fastcall ClearSel(void);
	void __fastcall CreateSynArray(void);
	void __fastcall DoChange(void);
	void __fastcall EnterIndent(void);
	void __fastcall SetSelText(System::UnicodeString Value);
	void __fastcall ShiftSelected(bool ShiftRight);
	void __fastcall ShowCaretPos(void);
	void __fastcall TabIndent(void);
	void __fastcall UnIndent(void);
	void __fastcall UpdateScrollBar(void);
	void __fastcall UpdateSyntax(void);
	void __fastcall DoLeft(void);
	void __fastcall DoRight(void);
	void __fastcall DoUp(void);
	void __fastcall DoDown(void);
	void __fastcall DoHome(bool Ctrl);
	void __fastcall DoEnd(bool Ctrl);
	void __fastcall DoPgUp(void);
	void __fastcall DoPgDn(void);
	void __fastcall DoChar(System::WideChar Ch);
	void __fastcall DoReturn(void);
	void __fastcall DoDel(void);
	void __fastcall DoBackspace(void);
	void __fastcall DoCtrlI(void);
	void __fastcall DoCtrlU(void);
	void __fastcall DoCtrlR(void);
	void __fastcall DoCtrlL(void);
	void __fastcall ScrollClick(System::TObject* Sender);
	void __fastcall ScrollEnter(System::TObject* Sender);
	void __fastcall LinesChange(System::TObject* Sender);
	void __fastcall ShowPos(void);
	void __fastcall BookmarkDraw(int Y, int line);
	void __fastcall ActiveLineDraw(int Y, int line);
	void __fastcall CorrectBookmark(int Line, int delta);
	void __fastcall SetKeywordAttr(Graphics::TFont* Value);
	void __fastcall SetStringAttr(Graphics::TFont* Value);
	void __fastcall SetTextAttr(Graphics::TFont* Value);
	void __fastcall SetCommentAttr(Graphics::TFont* Value);
	
protected:
	MESSAGE void __fastcall WMGetDlgCode(Messages::TWMNoParams &Message);
	HIDESBASE MESSAGE void __fastcall WMKillFocus(Messages::TWMKillFocus &Msg);
	HIDESBASE MESSAGE void __fastcall WMSetFocus(Messages::TWMSetFocus &Msg);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	virtual void __fastcall SetParent(Controls::TWinControl* Value);
	virtual Types::TRect __fastcall GetClientRect(void);
	DYNAMIC void __fastcall DblClick(void);
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall KeyDown(System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
	void __fastcall CopyPopup(System::TObject* Sender);
	void __fastcall PastePopup(System::TObject* Sender);
	void __fastcall CutPopup(System::TObject* Sender);
	void __fastcall MouseWheelUp(System::TObject* Sender, Classes::TShiftState Shift, const Types::TPoint &MousePos, bool &Handled);
	void __fastcall MouseWheelDown(System::TObject* Sender, Classes::TShiftState Shift, const Types::TPoint &MousePos, bool &Handled);
	void __fastcall DOver(System::TObject* Sender, System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	void __fastcall DDrop(System::TObject* Sender, System::TObject* Source, int X, int Y);
	
public:
	__fastcall virtual TfqbSyntaxMemo(Classes::TComponent* AOwner);
	__fastcall virtual ~TfqbSyntaxMemo(void);
	virtual void __fastcall SetBounds(int ALeft, int ATop, int AWidth, int AHeight);
	virtual void __fastcall Paint(void);
	void __fastcall CopyToClipboard(void);
	void __fastcall CutToClipboard(void);
	void __fastcall PasteFromClipboard(void);
	void __fastcall SetPos(int x, int y);
	void __fastcall ShowMessage(System::UnicodeString s);
	void __fastcall Undo(void);
	void __fastcall UpdateView(void);
	Types::TPoint __fastcall GetPos(void);
	bool __fastcall Find(System::UnicodeString Text);
	__property bool Modified = {read=FModified, write=FModified, nodefault};
	__property System::UnicodeString SelText = {read=GetSelText, write=SetSelText};
	int __fastcall IsBookmark(int Line);
	void __fastcall AddBookmark(int Line, int Number);
	void __fastcall DeleteBookmark(int Number);
	void __fastcall GotoBookmark(int Number);
	void __fastcall SetActiveLine(int Line);
	int __fastcall GetActiveLine(void);
	
__published:
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property BiDiMode;
	__property Constraints;
	__property DragKind = {default=0};
	__property ParentBiDiMode = {default=1};
	__property Color = {default=-16777211};
	__property DragCursor = {default=-12};
	__property DragMode = {default=0};
	__property Enabled = {default=1};
	__property Font;
	__property ParentColor = {default=1};
	__property ParentCtl3D = {default=1};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property ShowHint;
	__property TabOrder = {default=-1};
	__property TabStop = {default=0};
	__property Width;
	__property Height;
	__property Visible = {default=1};
	__property Graphics::TColor BlockColor = {read=FBlockColor, write=FBlockColor, nodefault};
	__property Graphics::TColor BlockFontColor = {read=FBlockFontColor, write=FBlockFontColor, nodefault};
	__property Graphics::TFont* CommentAttr = {read=FCommentAttr, write=SetCommentAttr};
	__property Graphics::TFont* KeywordAttr = {read=FKeywordAttr, write=SetKeywordAttr};
	__property Graphics::TFont* StringAttr = {read=FStringAttr, write=SetStringAttr};
	__property Graphics::TFont* TextAttr = {read=FTextAttr, write=SetTextAttr};
	__property Classes::TStrings* Lines = {read=GetText, write=SetText};
	__property bool ReadOnly = {read=FReadOnly, write=FReadOnly, nodefault};
	__property TSyntaxType SyntaxType = {read=FSyntaxType, write=SetSyntaxType, nodefault};
	__property bool ShowFooter = {read=FShowFooter, write=SetShowFooter, nodefault};
	__property bool ShowGutter = {read=FShowGutter, write=SetShowGutter, nodefault};
	__property OnClick;
	__property OnDblClick;
	__property OnDragDrop;
	__property OnDragOver;
	__property OnEndDrag;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
	__property OnStartDrag;
public:
	/* TWinControl.CreateParented */ inline __fastcall TfqbSyntaxMemo(HWND ParentWindow) : Controls::TCustomControl(ParentWindow) { }
	
};


class DELPHICLASS TfqbSynMemoSearch;
class PASCALIMPLEMENTATION TfqbSynMemoSearch : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* Search;
	Stdctrls::TButton* Button1;
	Stdctrls::TLabel* Label1;
	Stdctrls::TEdit* Edit1;
	void __fastcall FormKeyPress(System::TObject* Sender, System::WideChar &Key);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfqbSynMemoSearch(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfqbSynMemoSearch(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfqbSynMemoSearch(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfqbSynMemoSearch(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfqbSynMemoSearch* fqbSynMemoSearch;
extern PACKAGE void __fastcall Register(void);

}	/* namespace Fqbsynmemo */
using namespace Fqbsynmemo;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FqbsynmemoHPP
