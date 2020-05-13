// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Planimagedraw.pas' rev: 21.00

#ifndef PlanimagedrawHPP
#define PlanimagedrawHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Planner.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Plandraw.hpp>	// Pascal unit
#include <Picturecontainer.hpp>	// Pascal unit
#include <Advgdip.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Planimagedraw
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TImageDrawTool;
class PASCALIMPLEMENTATION TImageDrawTool : public Planner::TCustomItemDrawTool
{
	typedef Planner::TCustomItemDrawTool inherited;
	
private:
	Picturecontainer::TPictureContainer* FPictureContainer;
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation AOperation);
	
public:
	virtual void __fastcall DrawItem(Planner::TPlannerItem* PlannerItem, Graphics::TCanvas* Canvas, const Types::TRect &Rect, bool Selected, bool Print);
	
__published:
	__property Picturecontainer::TPictureContainer* PictureContainer = {read=FPictureContainer, write=FPictureContainer};
public:
	/* TComponent.Create */ inline __fastcall virtual TImageDrawTool(Classes::TComponent* AOwner) : Planner::TCustomItemDrawTool(AOwner) { }
	/* TComponent.Destroy */ inline __fastcall virtual ~TImageDrawTool(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall Register(void);

}	/* namespace Planimagedraw */
using namespace Planimagedraw;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// PlanimagedrawHPP
