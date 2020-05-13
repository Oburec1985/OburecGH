// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Fs_tree.pas' rev: 21.00

#ifndef Fs_treeHPP
#define Fs_treeHPP

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
#include <Comctrls.hpp>	// Pascal unit
#include <Fs_synmemo.hpp>	// Pascal unit
#include <Fs_xml.hpp>	// Pascal unit
#include <Fs_iinterpreter.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Fs_tree
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfsTree;
class PASCALIMPLEMENTATION TfsTree : public Extctrls::TPanel
{
	typedef Extctrls::TPanel inherited;
	
private:
	Comctrls::TTreeView* Tree;
	Fs_xml::TfsXMLDocument* FXML;
	Controls::TImageList* FImages;
	Fs_iinterpreter::TfsScript* FScript;
	bool FShowFunctions;
	bool FShowClasses;
	bool FShowTypes;
	bool FShowVariables;
	bool FExpanded;
	int FExpandLevel;
	Fs_synmemo::TfsSyntaxMemo* FMemo;
	bool FUpdating;
	void __fastcall FillTree(void);
	void __fastcall SetMemo(Fs_synmemo::TfsSyntaxMemo* Value);
	void __fastcall SetImageIndex(Comctrls::TTreeNode* Node, int Index);
	void __fastcall SetScript(const Fs_iinterpreter::TfsScript* Value);
	void __fastcall TreeCollapsed(System::TObject* Sender, Comctrls::TTreeNode* Node);
	void __fastcall TreeExpanded(System::TObject* Sender, Comctrls::TTreeNode* Node);
	
protected:
	void __fastcall TreeChange(System::TObject* Sender, Comctrls::TTreeNode* Node);
	void __fastcall TreeDblClick(System::TObject* Sender);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	
public:
	__fastcall virtual TfsTree(Classes::TComponent* AOwner);
	__fastcall virtual ~TfsTree(void);
	HIDESBASE void __fastcall SetColor(Graphics::TColor Color);
	void __fastcall UpdateItems(void);
	System::UnicodeString __fastcall GetFieldName(void);
	
__published:
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property ParentCtl3D = {default=1};
	__property DragCursor = {default=-12};
	__property DragKind = {default=0};
	__property DragMode = {default=0};
	__property BiDiMode;
	__property ParentBiDiMode = {default=1};
	__property Color = {default=-16777201};
	__property Constraints;
	__property Enabled = {default=1};
	__property Font;
	__property ParentColor = {default=0};
	__property ParentFont = {default=1};
	__property ParentShowHint = {default=1};
	__property PopupMenu;
	__property Fs_iinterpreter::TfsScript* Script = {read=FScript, write=SetScript};
	__property ShowHint;
	__property TabOrder = {default=-1};
	__property TabStop = {default=0};
	__property Visible = {default=1};
	__property Fs_synmemo::TfsSyntaxMemo* SyntaxMemo = {read=FMemo, write=SetMemo};
	__property bool ShowClasses = {read=FShowClasses, write=FShowClasses, nodefault};
	__property bool ShowFunctions = {read=FShowFunctions, write=FShowFunctions, nodefault};
	__property bool ShowTypes = {read=FShowTypes, write=FShowTypes, nodefault};
	__property bool ShowVariables = {read=FShowVariables, write=FShowVariables, nodefault};
	__property bool Expanded = {read=FExpanded, write=FExpanded, nodefault};
	__property int ExpandLevel = {read=FExpandLevel, write=FExpandLevel, nodefault};
	__property OnClick;
	__property OnDblClick;
	__property OnDragDrop;
	__property OnDragOver;
	__property OnEndDrag;
	__property OnEnter;
	__property OnExit;
	__property OnKeyDown;
	__property OnMouseDown;
	__property OnMouseMove;
	__property OnMouseUp;
	__property OnStartDrag;
public:
	/* TWinControl.CreateParented */ inline __fastcall TfsTree(HWND ParentWindow) : Extctrls::TPanel(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Fs_tree */
using namespace Fs_tree;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Fs_treeHPP
