// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxgml.pas' rev: 21.00

#ifndef FrxgmlHPP
#define FrxgmlHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxgml
{
//-- type declarations -------------------------------------------------------
typedef int TGmlEaResult;

typedef int TGmlElValue;

class DELPHICLASS TGmlList;
class PASCALIMPLEMENTATION TGmlList : public Classes::TList
{
	typedef Classes::TList inherited;
	
public:
	virtual void __fastcall Clear(void);
public:
	/* TList.Destroy */ inline __fastcall virtual ~TGmlList(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TGmlList(void) : Classes::TList() { }
	
};


struct TGmlStr
{
	
public:
	int Pos;
	int Len;
	System::AnsiString Data;
};


class DELPHICLASS TGmlNode;
class PASCALIMPLEMENTATION TGmlNode : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	void __fastcall SetHeader(const System::AnsiString s);
	void __fastcall SetBody(const System::AnsiString s);
	
protected:
	TGmlStr FHeader;
	TGmlStr FBody;
	virtual System::AnsiString __fastcall GetHeader(void) = 0 ;
	virtual System::AnsiString __fastcall GetBody(void) = 0 ;
	
public:
	TGmlNode* FParent;
	Classes::TList* FSubNodes;
	__fastcall virtual ~TGmlNode(void);
	void __fastcall DestroyTree(void);
	bool __fastcall Empty(void);
	void __fastcall UpdateParent(void);
	void __fastcall Remove(bool DestroyItself = true);
	int __fastcall SelfSubIndex(void);
	Classes::TList* __fastcall Select(int First, int Last = 0xffffffff);
	int __fastcall NodesCount(void);
	__property System::AnsiString Header = {read=GetHeader, write=SetHeader};
	__property System::AnsiString Body = {read=GetBody, write=SetBody};
public:
	/* TObject.Create */ inline __fastcall TGmlNode(void) : System::TObject() { }
	
};


class DELPHICLASS TGmlRtfNode;
class DELPHICLASS TGmlRtf;
class PASCALIMPLEMENTATION TGmlRtfNode : public TGmlNode
{
	typedef TGmlNode inherited;
	
protected:
	virtual System::AnsiString __fastcall GetHeader(void);
	virtual System::AnsiString __fastcall GetBody(void);
	
public:
	TGmlRtf* FDoc;
	virtual void __fastcall Serialize(Classes::TStream* Stream);
	void __fastcall SerializeSubNodes(Classes::TStream* Stream, int First, int Last);
	TGmlRtfNode* __fastcall Node(int Index);
	TGmlRtfNode* __fastcall Find(const System::AnsiString Hdr);
	Classes::TList* __fastcall FindAll(const System::AnsiString Hdr, int MaxCount = 0x0);
public:
	/* TGmlNode.Destroy */ inline __fastcall virtual ~TGmlRtfNode(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TGmlRtfNode(void) : TGmlNode() { }
	
};


class DELPHICLASS TGmlRtfGroup;
class PASCALIMPLEMENTATION TGmlRtfGroup : public TGmlRtfNode
{
	typedef TGmlRtfNode inherited;
	
public:
	virtual void __fastcall Serialize(Classes::TStream* Stream);
public:
	/* TGmlNode.Destroy */ inline __fastcall virtual ~TGmlRtfGroup(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TGmlRtfGroup(void) : TGmlRtfNode() { }
	
};


class DELPHICLASS TGmlRtfText;
class PASCALIMPLEMENTATION TGmlRtfText : public TGmlRtfNode
{
	typedef TGmlRtfNode inherited;
	
public:
	virtual void __fastcall Serialize(Classes::TStream* Stream);
public:
	/* TGmlNode.Destroy */ inline __fastcall virtual ~TGmlRtfText(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TGmlRtfText(void) : TGmlRtfNode() { }
	
};


class DELPHICLASS TGmlRtfControl;
class PASCALIMPLEMENTATION TGmlRtfControl : public TGmlRtfNode
{
	typedef TGmlRtfNode inherited;
	
private:
	bool FArg;
	int FArgValue;
	void __fastcall SetValue(int x);
	int __fastcall GetValue(void);
	
public:
	virtual void __fastcall Serialize(Classes::TStream* Stream);
	__property int Value = {read=GetValue, write=SetValue, nodefault};
public:
	/* TGmlNode.Destroy */ inline __fastcall virtual ~TGmlRtfControl(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TGmlRtfControl(void) : TGmlRtfNode() { }
	
};


class DELPHICLASS TGmlRtfNumber;
class PASCALIMPLEMENTATION TGmlRtfNumber : public TGmlRtfNode
{
	typedef TGmlRtfNode inherited;
	
public:
	int FValue;
	virtual void __fastcall Serialize(Classes::TStream* Stream);
public:
	/* TGmlNode.Destroy */ inline __fastcall virtual ~TGmlRtfNumber(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TGmlRtfNumber(void) : TGmlRtfNode() { }
	
};


class DELPHICLASS TGmlRtfSymbol;
class PASCALIMPLEMENTATION TGmlRtfSymbol : public TGmlRtfNode
{
	typedef TGmlRtfNode inherited;
	
public:
	char Symbol;
	virtual void __fastcall Serialize(Classes::TStream* Stream);
public:
	/* TGmlNode.Destroy */ inline __fastcall virtual ~TGmlRtfSymbol(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TGmlRtfSymbol(void) : TGmlRtfNode() { }
	
};


class DELPHICLASS TGmlRtfFont;
class PASCALIMPLEMENTATION TGmlRtfFont : public TGmlRtfNode
{
	typedef TGmlRtfNode inherited;
	
private:
	int __fastcall GetIndex(void);
	int __fastcall GetCharset(void);
	System::AnsiString __fastcall GetName(void);
	
public:
	__property int Index = {read=GetIndex, nodefault};
	__property int Charset = {read=GetCharset, nodefault};
	__property System::AnsiString Name = {read=GetName};
public:
	/* TGmlNode.Destroy */ inline __fastcall virtual ~TGmlRtfFont(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TGmlRtfFont(void) : TGmlRtfNode() { }
	
};


class DELPHICLASS TGmlRtfColor;
class PASCALIMPLEMENTATION TGmlRtfColor : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TGmlRtfControl* R;
	TGmlRtfControl* G;
	TGmlRtfControl* B;
	System::AnsiString __fastcall Serialize(void);
public:
	/* TObject.Create */ inline __fastcall TGmlRtfColor(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TGmlRtfColor(void) { }
	
};


class PASCALIMPLEMENTATION TGmlRtf : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::AnsiString FText;
	TGmlRtfNode* FRoot;
	Classes::TList* FStack;
	int FPos;
	int FLast;
	Classes::TList* FFontList;
	TGmlList* FColorList;
	char __fastcall Current(bool SkipInvisibles = false);
	char __fastcall Get(void);
	char __fastcall Prepare(void);
	void __fastcall Push(void);
	void __fastcall Pop(bool Discard = false);
	bool __cdecl IsVisible(char c);
	char __fastcall Escape(char c);
	bool __cdecl IsSpecChar(char c);
	bool __cdecl IsAlpha(char c);
	bool __cdecl IsDigit(char c);
	System::Byte __cdecl HexDigit(char c);
	bool __fastcall SkipAlpha(void);
	bool __fastcall SkipDigit(void);
	TGmlRtfNode* __fastcall SkipControl(void);
	TGmlRtfNode* __fastcall SkipGroup(void);
	TGmlRtfNode* __fastcall SkipNumber(void);
	TGmlRtfNode* __fastcall SkipText(void);
	TGmlRtfNode* __fastcall SkipControlSymbol(void);
	Classes::TList* __fastcall SkipList(void);
	Classes::TList* __fastcall Parse(int First, int Last);
	void __fastcall LoadFonts(void);
	void __fastcall LoadColors(void);
	
public:
	__fastcall TGmlRtf(const System::AnsiString Text);
	__fastcall virtual ~TGmlRtf(void);
	int __fastcall Length(void);
	int __fastcall Copy(int Pos, int Len, char * Dest)/* overload */;
	System::AnsiString __fastcall Copy(int Pos, int Len)/* overload */;
	System::AnsiString __fastcall Copy(const TGmlStr &Str)/* overload */;
	char __fastcall Char(int Pos);
	void __fastcall Serialize(Classes::TStream* Stream);
	__property TGmlRtfNode* Root = {read=FRoot};
	int __fastcall FontsCount(void);
	TGmlRtfFont* __fastcall Font(int i);
	int __fastcall ColorsCount(void);
	TGmlRtfColor* __fastcall Color(int i);
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt GmlEaFailure = 0x0;
static const ShortInt GmlEaSuccess = 0x1;
static const ShortInt GmlEaIncomplete = 0x2;
static const ShortInt GmlElNone = 0x0;
static const ShortInt GmlElOne = 0x1;
static const ShortInt GmlElAll = -1;
extern PACKAGE char GmlRtfScEscape;
extern PACKAGE char GmlRtfScOpen;
extern PACKAGE char GmlRtfScClose;
static const ShortInt GmlRtfMaxControl = 0x20;
static const ShortInt GmlRtfMaxControlArg = 0xa;

}	/* namespace Frxgml */
using namespace Frxgml;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxgmlHPP
