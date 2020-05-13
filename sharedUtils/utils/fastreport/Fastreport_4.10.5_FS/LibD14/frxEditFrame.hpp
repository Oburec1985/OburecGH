// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditframe.pas' rev: 21.00

#ifndef FrxeditframeHPP
#define FrxeditframeHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Frxctrls.hpp>	// Pascal unit
#include <Frxdock.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Toolwin.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditframe
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxFrameEditorForm;
class PASCALIMPLEMENTATION TfrxFrameEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TLabel* FrameL;
	Stdctrls::TLabel* LineL;
	Stdctrls::TLabel* ShadowL;
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Comctrls::TToolBar* ToolBar1;
	Comctrls::TToolButton* FrameTopB;
	Comctrls::TToolButton* FrameBottomB;
	Comctrls::TToolButton* FrameLeftB;
	Comctrls::TToolButton* FrameRightB;
	Comctrls::TToolButton* Sep1;
	Comctrls::TToolButton* FrameAllB;
	Comctrls::TToolButton* FrameNoB;
	Comctrls::TToolBar* ToolBar2;
	Comctrls::TToolButton* FrameColorB;
	Comctrls::TToolButton* FrameStyleB;
	Frxdock::TfrxTBPanel* Sep2;
	Frxctrls::TfrxComboBox* FrameWidthCB;
	Comctrls::TToolBar* ToolBar3;
	Comctrls::TToolButton* ShadowB;
	Comctrls::TToolButton* ShadowColorB;
	Frxdock::TfrxTBPanel* Sep3;
	Frxctrls::TfrxComboBox* ShadowWidthCB;
	Extctrls::TBevel* Bevel1;
	Frxctrls::TfrxComboBox* FrameLineCB;
	Stdctrls::TLabel* FLineL;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall BClick(System::TObject* Sender);
	void __fastcall FormDestroy(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	
private:
	Frxclass::TfrxFrame* FFrame;
	Controls::TImageList* FImageList;
	void __fastcall UpdateControls(void);
	Frxclass::TfrxFrameLine* __fastcall GetFrameLine(void);
	
public:
	__property Frxclass::TfrxFrame* Frame = {read=FFrame};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxFrameEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxFrameEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxFrameEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxFrameEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditframe */
using namespace Frxeditframe;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditframeHPP
