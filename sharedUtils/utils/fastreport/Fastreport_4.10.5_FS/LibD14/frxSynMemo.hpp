// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxsynmemo.pas' rev: 21.00

#ifndef FrxsynmemoHPP
#define FrxsynmemoHPP

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
#include <Controls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Frxctrls.hpp>	// Pascal unit
#include <Fs_iparser.hpp>	// Pascal unit
#include <Frxpopupform.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxsynmemo
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TCharAttr { caNo, caText, caBlock, caComment, caKeyword, caString, caNumber };
#pragma option pop

typedef Set<TCharAttr, caNo, caNumber>  TCharAttributes;

typedef void __fastcall (__closure *TfrxCodeCompletionEvent)(const System::UnicodeString Name, Classes::TStrings* List);

class DELPHICLASS TfrxSyntaxMemo;
class PASCALIMPLEMENTATION TfrxSyntaxMemo : public Frxctrls::TfrxScrollWin
{
	typedef Frxctrls::TfrxScrollWin inherited;
	
private:
	int FActiveLine;
	bool FAllowLinesChange;
	Graphics::TColor FBlockColor;
	Graphics::TColor FBlockFontColor;
	StaticArray<int, 10> FBookmarks;
	int FCharHeight;
	int FCharWidth;
	Graphics::TFont* FCommentAttr;
	Frxpopupform::TfrxPopupForm* FCompletionForm;
	Stdctrls::TListBox* FCompletionLB;
	bool FDoubleClicked;
	bool FDown;
	bool FToggleBreakPointDown;
	int FGutterWidth;
	bool FIsMonoType;
	Graphics::TFont* FKeywordAttr;
	int FMaxLength;
	System::UnicodeString FMessage;
	bool FModified;
	bool FMoved;
	Graphics::TFont* FNumberAttr;
	Types::TPoint FOffset;
	Classes::TNotifyEvent FOnChangePos;
	Classes::TNotifyEvent FOnChangeText;
	TfrxCodeCompletionEvent FOnCodeCompletion;
	Fs_iparser::TfsParser* FParser;
	Types::TPoint FPos;
	Graphics::TFont* FStringAttr;
	Types::TPoint FSelEnd;
	Types::TPoint FSelStart;
	bool FShowGutter;
	Classes::TStrings* FSynStrings;
	System::UnicodeString FSyntax;
	Types::TPoint FTempPos;
	Classes::TStringList* FText;
	Graphics::TFont* FTextAttr;
	Classes::TStringList* FUndo;
	bool FUpdatingSyntax;
	Types::TPoint FWindowSize;
	Classes::TStringList* FBreakPoints;
	TCharAttributes __fastcall GetCharAttr(const Types::TPoint &Pos);
	int __fastcall GetLineBegin(int Index);
	int __fastcall GetPlainTextPos(const Types::TPoint &Pos);
	Types::TPoint __fastcall GetPosPlainText(int Pos);
	bool __fastcall GetRunLine(int Index);
	System::UnicodeString __fastcall GetSelText(void);
	HIDESBASE Classes::TStrings* __fastcall GetText(void);
	System::UnicodeString __fastcall LineAt(int Index);
	int __fastcall LineLength(int Index);
	System::UnicodeString __fastcall Pad(int n);
	void __fastcall AddSel(void);
	void __fastcall AddUndo(void);
	void __fastcall ClearSel(void);
	void __fastcall ClearSyntax(int ClearFrom);
	void __fastcall CompletionLBDblClick(System::TObject* Sender);
	void __fastcall CompletionLBDrawItem(Controls::TWinControl* Control, int Index, const Types::TRect &ARect, Windows::TOwnerDrawState State);
	void __fastcall CompletionLBKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall CorrectBookmark(int Line, int Delta);
	void __fastcall CorrectBreakPoints(int Line, int Delta);
	void __fastcall CreateSynArray(int EndLine);
	void __fastcall DoBackspace(void);
	void __fastcall DoChange(void);
	void __fastcall DoChar(System::WideChar Ch);
	void __fastcall DoCodeCompletion(void);
	void __fastcall DoCtrlI(void);
	void __fastcall DoCtrlU(void);
	void __fastcall DoCtrlR(void);
	void __fastcall DoCtrlL(void);
	void __fastcall DoDel(void);
	void __fastcall DoDown(void);
	void __fastcall DoEnd(bool Ctrl);
	void __fastcall DoHome(bool Ctrl);
	void __fastcall DoLeft(void);
	void __fastcall DoPgUp(void);
	void __fastcall DoPgDn(void);
	void __fastcall DoReturn(void);
	void __fastcall DoRight(void);
	void __fastcall DoUp(void);
	void __fastcall EnterIndent(void);
	void __fastcall LinesChange(System::TObject* Sender);
	void __fastcall SetActiveLine(int Line);
	void __fastcall SetCommentAttr(Graphics::TFont* Value);
	void __fastcall SetKeywordAttr(Graphics::TFont* Value);
	void __fastcall SetNumberAttr(const Graphics::TFont* Value);
	void __fastcall SetRunLine(int Index, const bool Value);
	void __fastcall SetSelText(const System::UnicodeString Value);
	void __fastcall SetShowGutter(bool Value);
	void __fastcall SetStringAttr(Graphics::TFont* Value);
	void __fastcall SetSyntax(const System::UnicodeString Value);
	HIDESBASE void __fastcall SetText(Classes::TStrings* Value);
	void __fastcall SetTextAttr(Graphics::TFont* Value);
	void __fastcall ShiftSelected(bool ShiftRight);
	void __fastcall ShowCaretPos(void);
	void __fastcall TabIndent(void);
	void __fastcall UnIndent(void);
	HIDESBASE void __fastcall UpdateScrollBar(void);
	HIDESBASE MESSAGE void __fastcall WMKillFocus(Messages::TWMKillFocus &Msg);
	HIDESBASE MESSAGE void __fastcall WMSetFocus(Messages::TWMSetFocus &Msg);
	HIDESBASE MESSAGE void __fastcall CMFontChanged(Messages::TMessage &Message);
	bool __fastcall GetTextSelected(void);
	
protected:
	DYNAMIC void __fastcall DblClick(void);
	DYNAMIC void __fastcall KeyDown(System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall MouseWheelDown(System::TObject* Sender, Classes::TShiftState Shift, const Types::TPoint &MousePos, bool &Handled);
	void __fastcall MouseWheelUp(System::TObject* Sender, Classes::TShiftState Shift, const Types::TPoint &MousePos, bool &Handled);
	virtual void __fastcall OnHScrollChange(System::TObject* Sender);
	virtual void __fastcall OnVScrollChange(System::TObject* Sender);
	DYNAMIC void __fastcall Resize(void);
	
public:
	__fastcall virtual TfrxSyntaxMemo(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxSyntaxMemo(void);
	virtual void __fastcall Paint(void);
	void __fastcall CopyToClipboard(void);
	void __fastcall CutToClipboard(void);
	void __fastcall PasteFromClipboard(void);
	void __fastcall SelectAll(void);
	void __fastcall SetPos(int x, int y);
	void __fastcall ShowMessage(const System::UnicodeString s);
	void __fastcall Undo(void);
	void __fastcall UpdateView(void);
	bool __fastcall Find(const System::UnicodeString SearchText, bool CaseSensitive, int &SearchFrom);
	int __fastcall GetPlainPos(void);
	Types::TPoint __fastcall GetPos(void);
	int __fastcall IsBookmark(int Line);
	void __fastcall AddBookmark(int Line, int Number);
	void __fastcall DeleteBookmark(int Number);
	void __fastcall GotoBookmark(int Number);
	void __fastcall AddBreakPoint(int Number, const System::UnicodeString Condition);
	void __fastcall ToggleBreakPoint(int Number, const System::UnicodeString Condition);
	void __fastcall DeleteBreakPoint(int Number);
	void __fastcall DeleteF4BreakPoints(void);
	bool __fastcall IsBreakPoint(int Number);
	System::UnicodeString __fastcall GetBreakPointCondition(int Number);
	__property int ActiveLine = {read=FActiveLine, write=SetActiveLine, nodefault};
	__property Graphics::TColor BlockColor = {read=FBlockColor, write=FBlockColor, nodefault};
	__property Graphics::TColor BlockFontColor = {read=FBlockFontColor, write=FBlockFontColor, nodefault};
	__property Classes::TStringList* BreakPoints = {read=FBreakPoints};
	__property Color = {default=-16777211};
	__property Graphics::TFont* CommentAttr = {read=FCommentAttr, write=SetCommentAttr};
	__property Font;
	__property int GutterWidth = {read=FGutterWidth, write=FGutterWidth, nodefault};
	__property Graphics::TFont* KeywordAttr = {read=FKeywordAttr, write=SetKeywordAttr};
	__property bool Modified = {read=FModified, write=FModified, nodefault};
	__property Graphics::TFont* NumberAttr = {read=FNumberAttr, write=SetNumberAttr};
	__property bool RunLine[int Index] = {read=GetRunLine, write=SetRunLine};
	__property System::UnicodeString SelText = {read=GetSelText, write=SetSelText};
	__property Graphics::TFont* StringAttr = {read=FStringAttr, write=SetStringAttr};
	__property Graphics::TFont* TextAttr = {read=FTextAttr, write=SetTextAttr};
	__property Classes::TStrings* Lines = {read=GetText, write=SetText};
	__property System::UnicodeString Syntax = {read=FSyntax, write=SetSyntax};
	__property bool ShowGutter = {read=FShowGutter, write=SetShowGutter, nodefault};
	__property bool TextSelected = {read=GetTextSelected, nodefault};
	__property Classes::TNotifyEvent OnChangePos = {read=FOnChangePos, write=FOnChangePos};
	__property Classes::TNotifyEvent OnChangeText = {read=FOnChangeText, write=FOnChangeText};
	__property TfrxCodeCompletionEvent OnCodeCompletion = {read=FOnCodeCompletion, write=FOnCodeCompletion};
	__property OnDragDrop;
	__property OnDragOver;
	__property OnKeyDown;
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxSyntaxMemo(HWND ParentWindow) : Frxctrls::TfrxScrollWin(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxsynmemo */
using namespace Frxsynmemo;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxsynmemoHPP
