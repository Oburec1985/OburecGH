// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Gdipicture.pas' rev: 21.00

#ifndef GdipictureHPP
#define GdipictureHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Advgdip.hpp>	// Pascal unit
#include <Comobj.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Gdipicture
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TPictureFormat { pfBMP, pfGIF, pfJPG, pfPNG, pfICO, pfTiff, pfMetaFile, pfNone };
#pragma option pop

class DELPHICLASS TGDIPPicture;
class PASCALIMPLEMENTATION TGDIPPicture : public Graphics::TGraphic
{
	typedef Graphics::TGraphic inherited;
	
private:
	System::UnicodeString FFileName;
	Classes::TMemoryStream* FDatastream;
	bool FIsEmpty;
	int FWidth;
	int FHeight;
	bool FDoubleBuffered;
	Graphics::TColor FBackgroundColor;
	bool FTransparentBitmap;
	Classes::TNotifyEvent FOnClear;
	int FAngle;
	
protected:
	virtual bool __fastcall GetEmpty(void);
	virtual int __fastcall GetHeight(void);
	virtual int __fastcall GetWidth(void);
	virtual void __fastcall SetHeight(int Value);
	virtual void __fastcall SetWidth(int Value);
	virtual void __fastcall ReadData(Classes::TStream* Stream);
	virtual void __fastcall WriteData(Classes::TStream* Stream);
	TPictureFormat __fastcall GetPictureFormat(void);
	void __fastcall DoChange(void);
	
public:
	System::UnicodeString __fastcall GetFileName(void);
	__fastcall virtual TGDIPPicture(void);
	__fastcall virtual ~TGDIPPicture(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall DrawImage(Advgdip::TGPGraphics* Graphics, int X, int Y);
	void __fastcall DrawImageRect(Advgdip::TGPGraphics* Graphics, int X, int Y, int W, int H);
	virtual void __fastcall Draw(Graphics::TCanvas* ACanvas, const Types::TRect &Rect);
	virtual void __fastcall LoadFromFile(const System::UnicodeString FileName);
	virtual void __fastcall LoadFromStream(Classes::TStream* Stream);
	virtual void __fastcall SaveToStream(Classes::TStream* Stream);
	void __fastcall LoadFromResourceName(unsigned Instance, const System::UnicodeString ResName);
	void __fastcall LoadFromResourceID(unsigned Instance, int ResID);
	void __fastcall LoadFromURL(System::UnicodeString URL);
	virtual void __fastcall LoadFromClipboardFormat(System::Word AFormat, unsigned AData, HPALETTE APalette);
	virtual void __fastcall SaveToClipboardFormat(System::Word &AFormat, unsigned &AData, HPALETTE &APalette);
	__property bool DoubleBuffered = {read=FDoubleBuffered, write=FDoubleBuffered, nodefault};
	__property Graphics::TColor BackgroundColor = {read=FBackgroundColor, write=FBackgroundColor, nodefault};
	__property int Angle = {read=FAngle, write=FAngle, nodefault};
	bool __fastcall GetImageSizes(void);
	__property bool TransparentBitmap = {read=FTransparentBitmap, write=FTransparentBitmap, nodefault};
	__property TPictureFormat PictureFormat = {read=GetPictureFormat, nodefault};
	
__published:
	__property Classes::TNotifyEvent OnClear = {read=FOnClear, write=FOnClear};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE System::ResourceString _GDIPERRMSG;
#define Gdipicture_GDIPERRMSG System::LoadResourceString(&Gdipicture::_GDIPERRMSG)

}	/* namespace Gdipicture */
using namespace Gdipicture;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// GdipictureHPP
