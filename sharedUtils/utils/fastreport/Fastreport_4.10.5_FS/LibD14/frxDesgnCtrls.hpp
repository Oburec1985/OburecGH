// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxdesgnctrls.pas' rev: 21.00

#ifndef FrxdesgnctrlsHPP
#define FrxdesgnctrlsHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Toolwin.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxpicturecache.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxdesgnctrls
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxRulerUnits { ruCM, ruInches, ruPixels, ruChars };
#pragma option pop

class DELPHICLASS TfrxRuler;
class PASCALIMPLEMENTATION TfrxRuler : public Extctrls::TPanel
{
	typedef Extctrls::TPanel inherited;
	
private:
	int FOffset;
	System::Extended FScale;
	int FStart;
	TfrxRulerUnits FUnits;
	System::Extended FPosition;
	int FSize;
	void __fastcall SetOffset(const int Value);
	void __fastcall SetScale(const System::Extended Value);
	void __fastcall SetStart(const int Value);
	void __fastcall SetUnits(const TfrxRulerUnits Value);
	void __fastcall SetPosition(const System::Extended Value);
	MESSAGE void __fastcall WMEraseBackground(Messages::TMessage &Message);
	void __fastcall SetSize(const int Value);
	
public:
	__fastcall virtual TfrxRuler(Classes::TComponent* AOwner);
	virtual void __fastcall Paint(void);
	
__published:
	__property int Offset = {read=FOffset, write=SetOffset, nodefault};
	__property System::Extended Scale = {read=FScale, write=SetScale};
	__property int Start = {read=FStart, write=SetStart, nodefault};
	__property TfrxRulerUnits Units = {read=FUnits, write=SetUnits, default=2};
	__property System::Extended Position = {read=FPosition, write=SetPosition};
	__property int Size = {read=FSize, write=SetSize, nodefault};
public:
	/* TCustomControl.Destroy */ inline __fastcall virtual ~TfrxRuler(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxRuler(HWND ParentWindow) : Extctrls::TPanel(ParentWindow) { }
	
};


class DELPHICLASS TfrxScrollBox;
class PASCALIMPLEMENTATION TfrxScrollBox : public Forms::TScrollBox
{
	typedef Forms::TScrollBox inherited;
	
protected:
	MESSAGE void __fastcall WMGetDlgCode(Messages::TWMNoParams &Message);
	DYNAMIC void __fastcall KeyDown(System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC void __fastcall KeyUp(System::Word &Key, Classes::TShiftState Shift);
	DYNAMIC void __fastcall KeyPress(System::WideChar &Key);
public:
	/* TScrollBox.Create */ inline __fastcall virtual TfrxScrollBox(Classes::TComponent* AOwner) : Forms::TScrollBox(AOwner) { }
	
public:
	/* TScrollingWinControl.Destroy */ inline __fastcall virtual ~TfrxScrollBox(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxScrollBox(HWND ParentWindow) : Forms::TScrollBox(ParentWindow) { }
	
};


class DELPHICLASS TfrxCustomSelector;
class PASCALIMPLEMENTATION TfrxCustomSelector : public Extctrls::TPanel
{
	typedef Extctrls::TPanel inherited;
	
private:
	int FclWidth;
	int FclHeight;
	MESSAGE void __fastcall WMEraseBackground(Messages::TMessage &Message);
	
protected:
	virtual void __fastcall DrawEdge(int X, int Y, bool IsDown) = 0 ;
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	
public:
	virtual void __fastcall Paint(void);
	__fastcall virtual TfrxCustomSelector(Classes::TComponent* AOwner);
public:
	/* TCustomControl.Destroy */ inline __fastcall virtual ~TfrxCustomSelector(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxCustomSelector(HWND ParentWindow) : Extctrls::TPanel(ParentWindow) { }
	
};


class DELPHICLASS TfrxColorSelector;
class PASCALIMPLEMENTATION TfrxColorSelector : public TfrxCustomSelector
{
	typedef TfrxCustomSelector inherited;
	
private:
	Graphics::TColor FColor;
	Classes::TNotifyEvent FOnColorChanged;
	
protected:
	virtual void __fastcall DrawEdge(int X, int Y, bool IsDown);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	
public:
	__fastcall virtual TfrxColorSelector(Classes::TComponent* AOwner);
	virtual void __fastcall Paint(void);
	__property Graphics::TColor Color = {read=FColor, write=FColor, nodefault};
	__property Classes::TNotifyEvent OnColorChanged = {read=FOnColorChanged, write=FOnColorChanged};
public:
	/* TCustomControl.Destroy */ inline __fastcall virtual ~TfrxColorSelector(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxColorSelector(HWND ParentWindow) : TfrxCustomSelector(ParentWindow) { }
	
};


class DELPHICLASS TfrxLineSelector;
class PASCALIMPLEMENTATION TfrxLineSelector : public TfrxCustomSelector
{
	typedef TfrxCustomSelector inherited;
	
private:
	System::Byte FStyle;
	Classes::TNotifyEvent FOnStyleChanged;
	
protected:
	virtual void __fastcall DrawEdge(int X, int Y, bool IsDown);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	
public:
	__fastcall virtual TfrxLineSelector(Classes::TComponent* AOwner);
	virtual void __fastcall Paint(void);
	__property System::Byte Style = {read=FStyle, nodefault};
	__property Classes::TNotifyEvent OnStyleChanged = {read=FOnStyleChanged, write=FOnStyleChanged};
public:
	/* TCustomControl.Destroy */ inline __fastcall virtual ~TfrxLineSelector(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxLineSelector(HWND ParentWindow) : TfrxCustomSelector(ParentWindow) { }
	
};


class DELPHICLASS TfrxUndoBuffer;
class PASCALIMPLEMENTATION TfrxUndoBuffer : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Frxpicturecache::TfrxPictureCache* FPictureCache;
	Classes::TList* FRedo;
	Classes::TList* FUndo;
	int __fastcall GetRedoCount(void);
	int __fastcall GetUndoCount(void);
	void __fastcall SetPictureFlag(Frxclass::TfrxComponent* ReportComponent, bool Flag);
	void __fastcall SetPictures(Frxclass::TfrxComponent* ReportComponent);
	
public:
	__fastcall TfrxUndoBuffer(void);
	__fastcall virtual ~TfrxUndoBuffer(void);
	void __fastcall AddUndo(Frxclass::TfrxComponent* ReportComponent);
	void __fastcall AddRedo(Frxclass::TfrxComponent* ReportComponent);
	void __fastcall GetUndo(Frxclass::TfrxComponent* ReportComponent);
	void __fastcall GetRedo(Frxclass::TfrxComponent* ReportComponent);
	void __fastcall ClearUndo(void);
	void __fastcall ClearRedo(void);
	__property int UndoCount = {read=GetUndoCount, nodefault};
	__property int RedoCount = {read=GetRedoCount, nodefault};
	__property Frxpicturecache::TfrxPictureCache* PictureCache = {read=FPictureCache, write=FPictureCache};
};


class DELPHICLASS TfrxClipboard;
class PASCALIMPLEMENTATION TfrxClipboard : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Frxclass::TfrxCustomDesigner* FDesigner;
	Frxpicturecache::TfrxPictureCache* FPictureCache;
	bool __fastcall GetPasteAvailable(void);
	
public:
	__fastcall TfrxClipboard(Frxclass::TfrxCustomDesigner* ADesigner);
	void __fastcall Copy(void);
	void __fastcall Paste(void);
	__property bool PasteAvailable = {read=GetPasteAvailable, nodefault};
	__property Frxpicturecache::TfrxPictureCache* PictureCache = {read=FPictureCache, write=FPictureCache};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxClipboard(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxdesgnctrls */
using namespace Frxdesgnctrls;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxdesgnctrlsHPP
