// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fqbdesign.pas' rev: 21.00

#ifndef FqbdesignHPP
#define FqbdesignHPP

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
#include <Toolwin.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Grids.hpp>	// Pascal unit
#include <Dbgrids.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Db.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Fqbsynmemo.hpp>	// Pascal unit
#include <Fqbclass.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fqbdesign
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfqbDesigner;
class PASCALIMPLEMENTATION TfqbDesigner : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Db::TDataSource* DataSource1;
	Dbgrids::TDBGrid* DBGrid1;
	Fqbclass::TfqbGrid* fqbGrid1;
	Fqbsynmemo::TfqbSyntaxMemo* fqbSyntaxMemo1;
	Fqbclass::TfqbTableArea* fqbTableArea1;
	Fqbclass::TfqbTableListBox* fqbTableListBox1;
	Controls::TImageList* ImageList2;
	Dialogs::TOpenDialog* OpenDialog1;
	Comctrls::TPageControl* PageControl1;
	Extctrls::TPanel* Panel1;
	Dialogs::TSaveDialog* SaveDialog1;
	Extctrls::TSplitter* Splitter1;
	Extctrls::TSplitter* Splitter2;
	Comctrls::TTabSheet* TabSheet1;
	Comctrls::TTabSheet* TabSheet2;
	Comctrls::TTabSheet* TabSheet3;
	Comctrls::TToolBar* ToolBar1;
	Comctrls::TToolButton* ToolButton10;
	Comctrls::TToolButton* ToolButton3;
	Comctrls::TToolButton* ToolButton4;
	Comctrls::TToolButton* ToolButton5;
	Comctrls::TToolButton* ToolButton6;
	Comctrls::TToolButton* ToolButton7;
	Comctrls::TToolButton* ToolButton8;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall TabSheet2Show(System::TObject* Sender);
	void __fastcall TabSheet3Hide(System::TObject* Sender);
	void __fastcall TabSheet3Show(System::TObject* Sender);
	void __fastcall ToolButton10Click(System::TObject* Sender);
	void __fastcall ToolButton3Click(System::TObject* Sender);
	void __fastcall ToolButton4Click(System::TObject* Sender);
	void __fastcall ToolButton6Click(System::TObject* Sender);
	void __fastcall ToolButton7Click(System::TObject* Sender);
	void __fastcall FormDestroy(System::TObject* Sender);
	
protected:
	void __fastcall LoadPos(void);
	void __fastcall SavePos(void);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfqbDesigner(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfqbDesigner(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfqbDesigner(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfqbDesigner(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfqbDesigner* fqbDesigner;

}	/* namespace Fqbdesign */
using namespace Fqbdesign;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FqbdesignHPP
