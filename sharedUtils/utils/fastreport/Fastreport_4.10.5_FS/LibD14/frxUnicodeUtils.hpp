// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxunicodeutils.pas' rev: 21.00

#ifndef FrxunicodeutilsHPP
#define FrxunicodeutilsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Widestrings.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxunicodeutils
{
//-- type declarations -------------------------------------------------------
struct TWString
{
	
public:
	System::WideString WString;
	System::TObject* Obj;
};


class DELPHICLASS TfrxWideStrings;
class PASCALIMPLEMENTATION TfrxWideStrings : public Widestrings::TWideStrings
{
	typedef Widestrings::TWideStrings inherited;
	
public:
	System::WideString operator[](int Index) { return Strings[Index]; }
	
private:
	Classes::TList* FWideStringList;
	HIDESBASE void __fastcall ReadData(Classes::TReader* Reader);
	void __fastcall ReadDataWOld(Classes::TReader* Reader);
	void __fastcall ReadDataW(Classes::TReader* Reader);
	void __fastcall WriteDataW(Classes::TWriter* Writer);
	
protected:
	virtual System::WideString __fastcall Get(int Index);
	virtual void __fastcall Put(int Index, const System::WideString S);
	virtual System::TObject* __fastcall GetObject(int Index);
	virtual void __fastcall PutObject(int Index, System::TObject* Value);
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	virtual System::WideString __fastcall GetTextStr(void);
	virtual void __fastcall SetTextStr(const System::WideString Value);
	virtual int __fastcall GetCount(void);
	
public:
	__fastcall TfrxWideStrings(void);
	__fastcall virtual ~TfrxWideStrings(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	virtual void __fastcall Clear(void);
	virtual void __fastcall Delete(int Index);
	virtual int __fastcall Add(const System::WideString S);
	virtual void __fastcall AddStrings(Widestrings::TWideStrings* Strings)/* overload */;
	virtual int __fastcall AddObject(const System::WideString S, System::TObject* AObject);
	virtual int __fastcall IndexOf(const System::WideString S);
	virtual void __fastcall Insert(int Index, const System::WideString S);
	virtual void __fastcall LoadFromFile(const System::WideString FileName);
	virtual void __fastcall LoadFromStream(Classes::TStream* Stream);
	void __fastcall LoadFromWStream(Classes::TStream* Stream);
	virtual void __fastcall SaveToFile(const System::WideString FileName);
	virtual void __fastcall SaveToStream(Classes::TStream* Stream);
	__property System::TObject* Objects[int Index] = {read=GetObject, write=PutObject};
	__property System::WideString Strings[int Index] = {read=Get, write=Put/*, default*/};
	__property System::WideString Text = {read=GetTextStr, write=SetTextStr};
	
/* Hoisted overloads: */
	
public:
	inline void __fastcall  AddStrings(Classes::TStrings* Strings){ Widestrings::TWideStrings::AddStrings(Strings); }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE System::AnsiString __fastcall OemToStr(const System::AnsiString AnsiStr);
extern PACKAGE unsigned __fastcall CharSetToCodePage(unsigned ciCharset);
extern PACKAGE System::WideString __fastcall AnsiToUnicode(const System::AnsiString s, unsigned Charset, int CodePage = 0x0);
extern PACKAGE System::AnsiString __fastcall _UnicodeToAnsi(const System::WideString WS, unsigned Charset, int CodePage = 0x0);
extern PACKAGE unsigned __fastcall GetLocalByCharSet(unsigned Charset);

}	/* namespace Frxunicodeutils */
using namespace Frxunicodeutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxunicodeutilsHPP
