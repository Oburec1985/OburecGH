// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Ccedlink.pas' rev: 21.00

#ifndef CcedlinkHPP
#define CcedlinkHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Advgrid.hpp>	// Pascal unit
#include <Colcombo.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Ccedlink
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TColumnComboEditLink;
class PASCALIMPLEMENTATION TColumnComboEditLink : public Advgrid::TEditLink
{
	typedef Advgrid::TEditLink inherited;
	
private:
	int FCellHeight;
	Colcombo::TColumnComboBox* FCombo;
	bool FFlat;
	int FDropDownCount;
	int FDropHeight;
	int FDropWidth;
	bool FEtched;
	Classes::TStrings* FItems;
	int FColumns;
	int FEditColumn;
	bool FGridLines;
	Graphics::TColor FEditColor;
	Graphics::TFont* FEditFont;
	Controls::TImageList* FImages;
	bool FLookupIncr;
	int FLookupColumn;
	bool FDirectDrop;
	bool FDirectClose;
	void __fastcall SetItems(const Classes::TStrings* Value);
	void __fastcall SetImages(const Controls::TImageList* Value);
	
protected:
	HIDESBASE void __fastcall EditExit(System::TObject* Sender);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	void __fastcall ComboCloseup(System::TObject* Sender);
	
public:
	__fastcall virtual TColumnComboEditLink(Classes::TComponent* AOwner);
	__fastcall virtual ~TColumnComboEditLink(void);
	virtual void __fastcall CreateEditor(Controls::TWinControl* AParent);
	virtual System::UnicodeString __fastcall GetEditorValue(void);
	virtual void __fastcall SetEditorValue(System::UnicodeString s);
	virtual Controls::TWinControl* __fastcall GetEditControl(void);
	virtual void __fastcall SetProperties(void);
	virtual void __fastcall SetCellProps(Graphics::TColor AColor, Graphics::TFont* AFont);
	virtual void __fastcall SetRect(const Types::TRect &R);
	__property Colcombo::TColumnComboBox* Combo = {read=FCombo};
	
__published:
	__property int Columns = {read=FColumns, write=FColumns, nodefault};
	__property bool DirectDrop = {read=FDirectDrop, write=FDirectDrop, default=0};
	__property bool DirectClose = {read=FDirectClose, write=FDirectClose, default=0};
	__property int DropDownCount = {read=FDropDownCount, write=FDropDownCount, default=8};
	__property int DropHeight = {read=FDropHeight, write=FDropHeight, default=200};
	__property int DropWidth = {read=FDropWidth, write=FDropWidth, default=150};
	__property int EditColumn = {read=FEditColumn, write=FEditColumn, default=0};
	__property bool Etched = {read=FEtched, write=FEtched, default=0};
	__property bool Flat = {read=FFlat, write=FFlat, default=0};
	__property bool GridLines = {read=FGridLines, write=FGridLines, default=0};
	__property Controls::TImageList* Images = {read=FImages, write=SetImages};
	__property Classes::TStrings* Items = {read=FItems, write=SetItems};
	__property int LookupColumn = {read=FLookupColumn, write=FLookupColumn, default=0};
	__property bool LookupIncr = {read=FLookupIncr, write=FLookupIncr, default=0};
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall Register(void);

}	/* namespace Ccedlink */
using namespace Ccedlink;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// CcedlinkHPP
