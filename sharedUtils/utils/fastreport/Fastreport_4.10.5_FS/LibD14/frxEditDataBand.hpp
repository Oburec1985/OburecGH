// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxeditdataband.pas' rev: 21.00

#ifndef FrxeditdatabandHPP
#define FrxeditdatabandHPP

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
#include <Extctrls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxeditdataband
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxDataBandEditorForm;
class PASCALIMPLEMENTATION TfrxDataBandEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Stdctrls::TGroupBox* GroupBox1;
	Stdctrls::TListBox* DatasetsLB;
	Stdctrls::TLabel* RecordsL;
	Stdctrls::TEdit* RecordsE;
	Comctrls::TUpDown* RecordsUD;
	void __fastcall DatasetsLBDrawItem(Controls::TWinControl* Control, int Index, const Types::TRect &ARect, Windows::TOwnerDrawState State);
	void __fastcall DatasetsLBDblClick(System::TObject* Sender);
	void __fastcall FormHide(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall DatasetsLBClick(System::TObject* Sender);
	
private:
	Frxclass::TfrxDataBand* FDataBand;
	Frxclass::TfrxCustomDesigner* FDesigner;
	
public:
	__property Frxclass::TfrxDataBand* DataBand = {read=FDataBand, write=FDataBand};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxDataBandEditorForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxDataBandEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxDataBandEditorForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxDataBandEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxeditdataband */
using namespace Frxeditdataband;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxeditdatabandHPP
