// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advmjson.pas' rev: 21.00

#ifndef AdvmjsonHPP
#define AdvmjsonHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Advmemo.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advmjson
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TAdvJSONMemoStyler;
class PASCALIMPLEMENTATION TAdvJSONMemoStyler : public Advmemo::TAdvCustomMemoStyler
{
	typedef Advmemo::TAdvCustomMemoStyler inherited;
	
private:
	System::UnicodeString FVersion;
	bool FAutoFormat;
	int FAutoIndent;
	
protected:
	virtual System::UnicodeString __fastcall ForceLineBreakChars(void);
	virtual System::UnicodeString __fastcall Format(System::UnicodeString s);
	virtual bool __fastcall HasFormatting(void);
	
public:
	__fastcall virtual TAdvJSONMemoStyler(Classes::TComponent* AOwner);
	
__published:
	__property System::UnicodeString Version = {read=FVersion};
	__property bool AutoFormat = {read=FAutoFormat, write=FAutoFormat, default=1};
	__property int AutoIndent = {read=FAutoIndent, write=FAutoIndent, default=4};
	__property BlockStart;
	__property BlockEnd;
	__property LineComment;
	__property MultiCommentLeft;
	__property MultiCommentRight;
	__property CommentStyle;
	__property NumberStyle;
	__property HighlightStyle;
	__property AllStyles;
	__property AutoCompletion;
	__property HintParameter;
	__property HexIdentifier;
	__property Description;
	__property Filter;
	__property DefaultExtension;
	__property StylerName;
	__property Extensions;
	__property RegionDefinitions;
public:
	/* TAdvCustomMemoStyler.Destroy */ inline __fastcall virtual ~TAdvJSONMemoStyler(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Advmjson */
using namespace Advmjson;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvmjsonHPP
