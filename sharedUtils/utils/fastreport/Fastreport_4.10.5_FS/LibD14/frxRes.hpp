// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxres.pas' rev: 21.00

#ifndef FrxresHPP
#define FrxresHPP

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
#include <Controls.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Typinfo.hpp>	// Pascal unit
#include <Frxunicodeutils.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Widestrings.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxres
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxResources;
class PASCALIMPLEMENTATION TfrxResources : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Controls::TImageList* FDisabledButtonImages;
	Controls::TImageList* FMainButtonImages;
	Classes::TStringList* FNames;
	Controls::TImageList* FObjectImages;
	Controls::TImageList* FPreviewButtonImages;
	Widestrings::TWideStrings* FValues;
	Controls::TImageList* FWizardImages;
	Classes::TStringList* FLanguages;
	System::UnicodeString FHelpFile;
	unsigned FCP;
	void __fastcall BuildLanguagesList(void);
	Controls::TImageList* __fastcall GetMainButtonImages(void);
	Controls::TImageList* __fastcall GetObjectImages(void);
	Controls::TImageList* __fastcall GetPreviewButtonImages(void);
	Controls::TImageList* __fastcall GetWizardImages(void);
	
public:
	__fastcall TfrxResources(void);
	__fastcall virtual ~TfrxResources(void);
	System::UnicodeString __fastcall Get(const System::UnicodeString StrName);
	void __fastcall Add(const System::UnicodeString Ref, const System::UnicodeString Str);
	void __fastcall AddW(const System::UnicodeString Ref, System::WideString Str);
	void __fastcall AddStrings(const System::UnicodeString Str);
	void __fastcall AddXML(const System::AnsiString Str);
	void __fastcall Clear(void);
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	void __fastcall LoadFromStream(Classes::TStream* Stream);
	void __fastcall SetButtonImages(Graphics::TBitmap* Images, bool Clear = false);
	void __fastcall SetObjectImages(Graphics::TBitmap* Images, bool Clear = false);
	void __fastcall SetPreviewButtonImages(Graphics::TBitmap* Images, bool Clear = false);
	void __fastcall SetWizardImages(Graphics::TBitmap* Images, bool Clear = false);
	void __fastcall UpdateFSResources(void);
	void __fastcall Help(System::TObject* Sender)/* overload */;
	__property Controls::TImageList* DisabledButtonImages = {read=FDisabledButtonImages};
	__property Controls::TImageList* MainButtonImages = {read=GetMainButtonImages};
	__property Controls::TImageList* PreviewButtonImages = {read=GetPreviewButtonImages};
	__property Controls::TImageList* ObjectImages = {read=GetObjectImages};
	__property Controls::TImageList* WizardImages = {read=GetWizardImages};
	__property Classes::TStringList* Languages = {read=FLanguages};
	__property System::UnicodeString HelpFile = {read=FHelpFile, write=FHelpFile};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxResources* __fastcall frxResources(void);
extern PACKAGE System::UnicodeString __fastcall frxGet(int ID);

}	/* namespace Frxres */
using namespace Frxres;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxresHPP
