// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fs_iparser.pas' rev: 21.00

#ifndef Fs_iparserHPP
#define Fs_iparserHPP

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
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fs_iparser
{
//-- type declarations -------------------------------------------------------
typedef Set<char, 0, 255>  TfsIdentifierCharset;

class DELPHICLASS TfsParser;
class PASCALIMPLEMENTATION TfsParser : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	bool FCaseSensitive;
	System::UnicodeString FCommentBlock1;
	System::UnicodeString FCommentBlock11;
	System::UnicodeString FCommentBlock12;
	System::UnicodeString FCommentBlock2;
	System::UnicodeString FCommentBlock21;
	System::UnicodeString FCommentBlock22;
	System::UnicodeString FCommentLine1;
	System::UnicodeString FCommentLine2;
	System::UnicodeString FHexSequence;
	TfsIdentifierCharset FIdentifierCharset;
	Classes::TStrings* FKeywords;
	int FLastPosition;
	int FPosition;
	int FSize;
	System::UnicodeString FSkiPChar;
	bool FSkipEOL;
	bool FSkipSpace;
	System::UnicodeString FStringQuotes;
	System::UnicodeString FText;
	bool FUseY;
	Classes::TList* FYList;
	bool FSpecStrChar;
	bool __fastcall DoDigitSequence(void);
	bool __fastcall DoHexDigitSequence(void);
	bool __fastcall DoScaleFactor(void);
	bool __fastcall DoUnsignedInteger(void);
	bool __fastcall DoUnsignedReal(void);
	void __fastcall SetPosition(const int Value);
	void __fastcall SetText(const System::UnicodeString Value);
	System::UnicodeString __fastcall Ident(void);
	void __fastcall SetCommentBlock1(const System::UnicodeString Value);
	void __fastcall SetCommentBlock2(const System::UnicodeString Value);
	
public:
	__fastcall TfsParser(void);
	__fastcall virtual ~TfsParser(void);
	void __fastcall Clear(void);
	void __fastcall ConstructCharset(const System::UnicodeString s);
	void __fastcall SkipSpaces(void);
	bool __fastcall GetEOL(void);
	System::UnicodeString __fastcall GetIdent(void);
	System::UnicodeString __fastcall GetChar(void);
	System::UnicodeString __fastcall GetWord(void);
	System::UnicodeString __fastcall GetNumber(void);
	System::UnicodeString __fastcall GetString(void);
	System::UnicodeString __fastcall GetFRString(void);
	System::UnicodeString __fastcall GetXYPosition(void);
	int __fastcall GetPlainPosition(const Types::TPoint &pt);
	bool __fastcall IsKeyWord(const System::UnicodeString s);
	__property bool CaseSensitive = {read=FCaseSensitive, write=FCaseSensitive, nodefault};
	__property System::UnicodeString CommentBlock1 = {read=FCommentBlock1, write=SetCommentBlock1};
	__property System::UnicodeString CommentBlock2 = {read=FCommentBlock2, write=SetCommentBlock2};
	__property System::UnicodeString CommentLine1 = {read=FCommentLine1, write=FCommentLine1};
	__property System::UnicodeString CommentLine2 = {read=FCommentLine2, write=FCommentLine2};
	__property System::UnicodeString HexSequence = {read=FHexSequence, write=FHexSequence};
	__property TfsIdentifierCharset IdentifierCharset = {read=FIdentifierCharset, write=FIdentifierCharset};
	__property Classes::TStrings* Keywords = {read=FKeywords};
	__property System::UnicodeString SkiPChar = {read=FSkiPChar, write=FSkiPChar};
	__property bool SkipEOL = {read=FSkipEOL, write=FSkipEOL, nodefault};
	__property bool SkipSpace = {read=FSkipSpace, write=FSkipSpace, nodefault};
	__property System::UnicodeString StringQuotes = {read=FStringQuotes, write=FStringQuotes};
	__property bool SpecStrChar = {read=FSpecStrChar, write=FSpecStrChar, nodefault};
	__property bool UseY = {read=FUseY, write=FUseY, nodefault};
	__property int Position = {read=FPosition, write=SetPosition, nodefault};
	__property System::UnicodeString Text = {read=FText, write=SetText};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Fs_iparser */
using namespace Fs_iparser;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Fs_iparserHPP
