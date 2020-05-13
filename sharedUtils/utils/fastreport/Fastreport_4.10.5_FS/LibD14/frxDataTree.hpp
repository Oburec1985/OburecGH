// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxdatatree.pas' rev: 21.00

#ifndef FrxdatatreeHPP
#define FrxdatatreeHPP

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
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Fs_xml.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Tabs.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxdatatree
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxDataTreeForm;
class PASCALIMPLEMENTATION TfrxDataTreeForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Extctrls::TPanel* DataPn;
	Comctrls::TTreeView* DataTree;
	Extctrls::TPanel* CBPanel;
	Stdctrls::TCheckBox* InsFieldCB;
	Stdctrls::TCheckBox* InsCaptionCB;
	Extctrls::TPanel* VariablesPn;
	Comctrls::TTreeView* VariablesTree;
	Extctrls::TPanel* FunctionsPn;
	Extctrls::TSplitter* Splitter1;
	Forms::TScrollBox* HintPanel;
	Stdctrls::TLabel* FunctionDescL;
	Stdctrls::TLabel* FunctionNameL;
	Comctrls::TTreeView* FunctionsTree;
	Extctrls::TPanel* ClassesPn;
	Comctrls::TTreeView* ClassesTree;
	Forms::TScrollBox* NoDataPn;
	Stdctrls::TLabel* NoDataL;
	Stdctrls::TCheckBox* SortCB;
	void __fastcall FormResize(System::TObject* Sender);
	void __fastcall DataTreeCustomDrawItem(Comctrls::TCustomTreeView* Sender, Comctrls::TTreeNode* Node, Comctrls::TCustomDrawState State, bool &DefaultDraw);
	void __fastcall FunctionsTreeChange(System::TObject* Sender, Comctrls::TTreeNode* Node);
	void __fastcall DataTreeDblClick(System::TObject* Sender);
	void __fastcall ClassesTreeExpanding(System::TObject* Sender, Comctrls::TTreeNode* Node, bool &AllowExpansion);
	void __fastcall ClassesTreeCustomDrawItem(Comctrls::TCustomTreeView* Sender, Comctrls::TTreeNode* Node, Comctrls::TCustomDrawState State, bool &DefaultDraw);
	void __fastcall SortCBClick(System::TObject* Sender);
	
private:
	Fs_xml::TfsXMLDocument* FXML;
	Controls::TImageList* FImages;
	Frxclass::TfrxReport* FReport;
	bool FUpdating;
	bool FFirstTime;
	Tabs::TTabSet* FTabs;
	void __fastcall FillClassesTree(void);
	void __fastcall FillDataTree(void);
	void __fastcall FillFunctionsTree(void);
	void __fastcall FillVariablesTree(void);
	void __fastcall TabsChange(System::TObject* Sender);
	System::UnicodeString __fastcall GetCollapsedNodes(void);
	
public:
	__fastcall virtual TfrxDataTreeForm(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDataTreeForm(void);
	HIDESBASE void __fastcall SetColor(Graphics::TColor Color);
	void __fastcall SetControlsParent(Controls::TWinControl* AParent);
	void __fastcall SetLastPosition(const Types::TPoint &p);
	void __fastcall ShowTab(int Index);
	void __fastcall UpdateItems(void);
	void __fastcall UpdateSelection(void);
	void __fastcall UpdateSize(void);
	int __fastcall GetActivePage(void);
	System::UnicodeString __fastcall GetFieldName(void);
	Types::TPoint __fastcall GetLastPosition(void);
	bool __fastcall IsDataField(void);
	__property Frxclass::TfrxReport* Report = {read=FReport, write=FReport};
public:
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxDataTreeForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxDataTreeForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxdatatree */
using namespace Frxdatatree;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxdatatreeHPP
