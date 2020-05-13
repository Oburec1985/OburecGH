// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclgraphutils.pas' rev: 21.00

#ifndef JclgraphutilsHPP
#define JclgraphutilsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclgraphutils
{
//-- type declarations -------------------------------------------------------
typedef unsigned TColor32;

typedef TColor32 *PColor32;

typedef StaticArray<TColor32, 536870911> TColor32Array;

typedef TColor32Array *PColor32Array;

typedef StaticArray<TColor32, 256> TPalette32;

typedef TPalette32 *PPalette32;

typedef DynamicArray<TColor32> TArrayOfColor32;

typedef TColor32 __fastcall (*TCombineReg)(TColor32 X, TColor32 Y, TColor32 W);

typedef void __fastcall (*TCombineMem)(TColor32 F, TColor32 &B, TColor32 W);

typedef TColor32 __fastcall (*TBlendReg)(TColor32 F, TColor32 B);

typedef void __fastcall (*TBlendMem)(TColor32 F, TColor32 &B);

typedef TColor32 __fastcall (*TBlendRegEx)(TColor32 F, TColor32 B, TColor32 M);

typedef void __fastcall (*TBlendMemEx)(TColor32 F, TColor32 &B, TColor32 M);

typedef void __fastcall (*TBlendLine)(PColor32 Src, PColor32 Dst, int Count);

typedef void __fastcall (*TBlendLineEx)(PColor32 Src, PColor32 Dst, int Count, TColor32 M);

#pragma pack(push,1)
struct TColorRec
{
	
	union
	{
		struct 
		{
			System::Word Index;
			
		};
		struct 
		{
			System::Byte R;
			System::Byte G;
			System::Byte B;
			System::Byte Flag;
			
		};
		struct 
		{
			System::Byte Red;
			System::Byte Green;
			System::Byte Blue;
			
		};
		struct 
		{
			int Value;
			
		};
		
	};
};
#pragma pack(pop)


struct TColorVector
{
	
	#pragma pack(push,1)
	union
	{
		struct 
		{
			float H;
			float L;
			float S;
			
		};
		struct 
		{
			float R;
			float G;
			float B;
			
		};
		struct 
		{
			StaticArray<float, 3> Coord;
			
		};
		
	};
	#pragma pack(pop)
};


typedef Byte THLSValue;

struct THLSVector
{
	
public:
	THLSValue Hue;
	THLSValue Luminance;
	THLSValue Saturation;
};


typedef DynamicArray<Types::TPoint> TPointArray;

typedef TPointArray *PPointArray;

#pragma option push -b-
enum TClipCode { ccLeft, ccRight, ccAbove, ccBelow };
#pragma option pop

typedef Set<TClipCode, ccLeft, ccBelow>  TClipCodes;

typedef TClipCodes *PClipCodes;

class DELPHICLASS EColorConversionError;
class PASCALIMPLEMENTATION EColorConversionError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EColorConversionError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EColorConversionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EColorConversionError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EColorConversionError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EColorConversionError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EColorConversionError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EColorConversionError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EColorConversionError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EColorConversionError(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const TColor32 clBlack32 = 0xff000000;
static const TColor32 clDimGray32 = 0xff3f3f3f;
static const TColor32 clGray32 = 0xff7f7f7f;
static const TColor32 clLightGray32 = 0xffbfbfbf;
static const TColor32 clWhite32 = 0xffffffff;
static const TColor32 clMaroon32 = 0xff7f0000;
static const TColor32 clGreen32 = 0xff007f00;
static const TColor32 clOlive32 = 0xff7f7f00;
static const TColor32 clNavy32 = 0xff00007f;
static const TColor32 clPurple32 = 0xff7f007f;
static const TColor32 clTeal32 = 0xff007f7f;
static const TColor32 clRed32 = 0xffff0000;
static const TColor32 clLime32 = 0xff00ff00;
static const TColor32 clYellow32 = 0xffffff00;
static const TColor32 clBlue32 = 0xff0000ff;
static const TColor32 clFuchsia32 = 0xffff00ff;
static const TColor32 clAqua32 = 0xff00ffff;
static const TColor32 clTrWhite32 = 0x7fffffff;
static const TColor32 clTrBlack32 = 0x7f000000;
static const TColor32 clTrRed32 = 0x7fff0000;
static const TColor32 clTrGreen32 = 0x7f00ff00;
static const TColor32 clTrBlue32 = 0x7f0000ff;
extern PACKAGE TCombineReg CombineReg;
extern PACKAGE TCombineMem CombineMem;
extern PACKAGE TBlendReg BlendReg;
extern PACKAGE TBlendMem BlendMem;
extern PACKAGE TBlendRegEx BlendRegEx;
extern PACKAGE TBlendMemEx BlendMemEx;
extern PACKAGE TBlendLine BlendLine;
extern PACKAGE TBlendLineEx BlendLineEx;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall EMMS(void);
extern PACKAGE System::Word __fastcall DialogUnitsToPixelsX(const System::Word DialogUnits);
extern PACKAGE System::Word __fastcall DialogUnitsToPixelsY(const System::Word DialogUnits);
extern PACKAGE System::Word __fastcall PixelsToDialogUnitsX(const System::Word PixelUnits);
extern PACKAGE System::Word __fastcall PixelsToDialogUnitsY(const System::Word PixelUnits);
extern PACKAGE Types::TPoint __fastcall NullPoint(void);
extern PACKAGE Types::TPoint __fastcall PointAssign(const int X, const int Y);
extern PACKAGE void __fastcall PointCopy(Types::TPoint &Dest, const Types::TPoint &Source);
extern PACKAGE bool __fastcall PointEqual(const Types::TPoint &P1, const Types::TPoint &P2);
extern PACKAGE bool __fastcall PointIsNull(const Types::TPoint &P);
extern PACKAGE void __fastcall PointMove(Types::TPoint &P, const int DeltaX, const int DeltaY);
extern PACKAGE Types::TRect __fastcall NullRect(void);
extern PACKAGE Types::TRect __fastcall RectAssign(const int Left, const int Top, const int Right, const int Bottom);
extern PACKAGE Types::TRect __fastcall RectAssignPoints(const Types::TPoint &TopLeft, const Types::TPoint &BottomRight);
extern PACKAGE Types::TRect __fastcall RectBounds(const int Left, const int Top, const int Width, const int Height);
extern PACKAGE Types::TPoint __fastcall RectCenter(const Types::TRect &R);
extern PACKAGE void __fastcall RectCopy(Types::TRect &Dest, const Types::TRect &Source);
extern PACKAGE void __fastcall RectFitToScreen(Types::TRect &R);
extern PACKAGE void __fastcall RectGrow(Types::TRect &R, const int Delta);
extern PACKAGE void __fastcall RectGrowX(Types::TRect &R, const int Delta);
extern PACKAGE void __fastcall RectGrowY(Types::TRect &R, const int Delta);
extern PACKAGE bool __fastcall RectEqual(const Types::TRect &R1, const Types::TRect &R2);
extern PACKAGE int __fastcall RectHeight(const Types::TRect &R);
extern PACKAGE bool __fastcall RectIncludesPoint(const Types::TRect &R, const Types::TPoint &Pt);
extern PACKAGE bool __fastcall RectIncludesRect(const Types::TRect &R1, const Types::TRect &R2);
extern PACKAGE Types::TRect __fastcall RectIntersection(const Types::TRect &R1, const Types::TRect &R2);
extern PACKAGE bool __fastcall RectIntersectRect(const Types::TRect &R1, const Types::TRect &R2);
extern PACKAGE bool __fastcall RectIsEmpty(const Types::TRect &R);
extern PACKAGE bool __fastcall RectIsNull(const Types::TRect &R);
extern PACKAGE bool __fastcall RectIsSquare(const Types::TRect &R);
extern PACKAGE bool __fastcall RectIsValid(const Types::TRect &R);
extern PACKAGE void __fastcall RectMove(Types::TRect &R, const int DeltaX, const int DeltaY);
extern PACKAGE void __fastcall RectMoveTo(Types::TRect &R, const int X, const int Y);
extern PACKAGE void __fastcall RectNormalize(Types::TRect &R);
extern PACKAGE bool __fastcall RectsAreValid(Types::TRect *R, const int R_Size);
extern PACKAGE Types::TRect __fastcall RectUnion(const Types::TRect &R1, const Types::TRect &R2);
extern PACKAGE int __fastcall RectWidth(const Types::TRect &R);
extern PACKAGE void __fastcall GetRGBValue(const Graphics::TColor Color, /* out */ System::Byte &Red, /* out */ System::Byte &Green, /* out */ System::Byte &Blue);
extern PACKAGE Graphics::TColor __fastcall SetRGBValue(const System::Byte Red, const System::Byte Green, const System::Byte Blue);
extern PACKAGE Graphics::TColor __fastcall SetColorFlag(const Graphics::TColor Color, const System::Byte Flag);
extern PACKAGE System::Byte __fastcall GetColorFlag(const Graphics::TColor Color);
extern PACKAGE Graphics::TColor __fastcall SetColorRed(const Graphics::TColor Color, const System::Byte Red);
extern PACKAGE System::Byte __fastcall GetColorRed(const Graphics::TColor Color);
extern PACKAGE Graphics::TColor __fastcall SetColorGreen(const Graphics::TColor Color, const System::Byte Green);
extern PACKAGE System::Byte __fastcall GetColorGreen(const Graphics::TColor Color);
extern PACKAGE Graphics::TColor __fastcall SetColorBlue(const Graphics::TColor Color, const System::Byte Blue);
extern PACKAGE System::Byte __fastcall GetColorBlue(const Graphics::TColor Color);
extern PACKAGE Graphics::TColor __fastcall BrightColor(const Graphics::TColor Color, const float Pct);
extern PACKAGE System::Byte __fastcall BrightColorChannel(const System::Byte Channel, const float Pct);
extern PACKAGE Graphics::TColor __fastcall DarkColor(const Graphics::TColor Color, const float Pct);
extern PACKAGE System::Byte __fastcall DarkColorChannel(const System::Byte Channel, const float Pct);
extern PACKAGE void __fastcall CIED65ToCIED50(System::Extended &X, System::Extended &Y, System::Extended &Z);
extern PACKAGE void __fastcall CMYKToBGR(const void * Source, const void * Target, const System::Byte BitsPerSample, unsigned Count)/* overload */;
extern PACKAGE void __fastcall CMYKToBGR(const void * C, const void * M, const void * Y, const void * K, const void * Target, const System::Byte BitsPerSample, unsigned Count)/* overload */;
extern PACKAGE void __fastcall CIELABToBGR(const void * Source, const void * Target, const unsigned Count)/* overload */;
extern PACKAGE void __fastcall CIELABToBGR(System::PByte LSource, System::PByte aSource, System::PByte bSource, const void * Target, const unsigned Count)/* overload */;
extern PACKAGE void __fastcall RGBToBGR(const void * Source, const void * Target, const System::Byte BitsPerSample, unsigned Count)/* overload */;
extern PACKAGE void __fastcall RGBToBGR(const void * R, const void * G, const void * B, const void * Target, const System::Byte BitsPerSample, unsigned Count)/* overload */;
extern PACKAGE void __fastcall RGBAToBGRA(const void * Source, const void * Target, const System::Byte BitsPerSample, unsigned Count);
extern PACKAGE void __fastcall WinColorToOpenGLColor(const Graphics::TColor Color, /* out */ System::Extended &Red, /* out */ System::Extended &Green, /* out */ System::Extended &Blue);
extern PACKAGE Graphics::TColor __fastcall OpenGLColorToWinColor(const System::Extended Red, const System::Extended Green, const System::Extended Blue);
extern PACKAGE TColor32 __fastcall Color32(Graphics::TColor WinColor)/* overload */;
extern PACKAGE TColor32 __fastcall Color32(const System::Byte R, const System::Byte G, const System::Byte B, const System::Byte A = (System::Byte)(0xff))/* overload */;
extern PACKAGE TColor32 __fastcall Color32(const System::Byte Index, TColor32 const *Palette)/* overload */;
extern PACKAGE TColor32 __fastcall Gray32(const System::Byte Intensity, const System::Byte Alpha = (System::Byte)(0xff));
extern PACKAGE Graphics::TColor __fastcall WinColor(const TColor32 Color32);
extern PACKAGE int __fastcall RedComponent(const TColor32 Color32);
extern PACKAGE int __fastcall GreenComponent(const TColor32 Color32);
extern PACKAGE int __fastcall BlueComponent(const TColor32 Color32);
extern PACKAGE int __fastcall AlphaComponent(const TColor32 Color32);
extern PACKAGE float __fastcall Intensity(const float R, const float G, const float B)/* overload */;
extern PACKAGE int __fastcall Intensity(const TColor32 Color32)/* overload */;
extern PACKAGE TColor32 __fastcall SetAlpha(const TColor32 Color32, int NewAlpha);
extern PACKAGE void __fastcall HLSToRGB(const float H, const float L, const float S, /* out */ float &R, /* out */ float &G, /* out */ float &B)/* overload */;
extern PACKAGE TColor32 __fastcall HSLToRGB(const float H, const float S, const float L)/* overload */;
extern PACKAGE TColorVector __fastcall HLSToRGB(const TColorVector &HLS)/* overload */;
extern PACKAGE void __fastcall RGBToHLS(const float R, const float G, const float B, /* out */ float &H, /* out */ float &L, /* out */ float &S)/* overload */;
extern PACKAGE void __fastcall RGBToHSL(const TColor32 RGB, /* out */ float &H, /* out */ float &S, /* out */ float &L)/* overload */;
extern PACKAGE TColorVector __fastcall RGBToHLS(const TColorVector &RGB)/* overload */;
extern PACKAGE THLSVector __fastcall RGBToHLS(const unsigned RGBColor)/* overload */;
extern PACKAGE unsigned __fastcall HLSToRGB(const THLSValue Hue, const THLSValue Luminance, const THLSValue Saturation)/* overload */;
extern PACKAGE int __fastcall SetBitmapColors(Graphics::TBitmap* Bmp, Graphics::TColor const *Colors, const int Colors_Size, int StartIndex);
extern PACKAGE System::UnicodeString __fastcall ColorToHTML(const Graphics::TColor Color);
extern PACKAGE bool __fastcall DottedLineTo(const Graphics::TCanvas* Canvas, const int X, const int Y)/* overload */;
extern PACKAGE System::WideString __fastcall ShortenString(const HDC DC, const System::WideString S, const int Width, const bool RTL, int EllipsisWidth = 0x0);
extern PACKAGE TClipCodes __fastcall ClipCodes(const System::Extended X, const System::Extended Y, const System::Extended MinX, const System::Extended MinY, const System::Extended MaxX, const System::Extended MaxY)/* overload */;
extern PACKAGE TClipCodes __fastcall ClipCodes(const System::Extended X, const System::Extended Y, const Types::TRect &ClipRect)/* overload */;
extern PACKAGE bool __fastcall ClipLine(int &X1, int &Y1, int &X2, int &Y2, const Types::TRect &ClipRect)/* overload */;
extern PACKAGE bool __fastcall ClipLine(System::Extended &X1, System::Extended &Y1, System::Extended &X2, System::Extended &Y2, const System::Extended MinX, const System::Extended MinY, const System::Extended MaxX, const System::Extended MaxY, PClipCodes Codes = (void *)(0x0))/* overload */;
extern PACKAGE void __fastcall DrawPolyLine(const Graphics::TCanvas* Canvas, TPointArray &Points, const Types::TRect &ClipRect);

}	/* namespace Jclgraphutils */
using namespace Jclgraphutils;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclgraphutilsHPP
