// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advreplacedialogform.pas' rev: 21.00

#ifndef AdvreplacedialogformHPP
#define AdvreplacedialogformHPP

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
#include <Menus.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advreplacedialogform
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TAdvReplaceDialogOption { fdoCurrentFile, fdoSelection, fdoAllOpenFiles, fdoCaseSensitive, fdoExpression, fdoWholeWordOnly, fdoWrapAtEndOfFile, fdoMoreEnabled, fdoFindEnabled, fdoReplaceAllEnabled, fdoReplaceEnabled, fdoCloseEnabled, fdoFindList, fdoMoreExpanded, fdoReplaceList, fdoDown };
#pragma option pop

#pragma option push -b-
enum TAdvFindDialogVisibleOption { fdovCaseSensitive, fdovExpression, fdovWholeWordOnly, fdovWrapAtEndOfFile, fdovMore, fdovReplace, fdovReplaceAll, fdovFind, fdovClose, fdovFindCombo, fdovFindMemo, fdovReplaceCombo, fdovReplaceMemo, fdovReplaceAllRange, fdovCurrentFile, fdovSelection, fdovAllOpenFiles, fdovDirection };
#pragma option pop

typedef Set<TAdvReplaceDialogOption, fdoCurrentFile, fdoDown>  TAdvReplaceDialogOptions;

typedef Set<TAdvFindDialogVisibleOption, fdovCaseSensitive, fdovDirection>  TAdvReplaceDialogVisibleOptions;

typedef void __fastcall (__closure *TEditChangeEvent)(System::TObject* Sender, System::UnicodeString &AText);

class DELPHICLASS TReplaceDialogForm;
class DELPHICLASS TAdvReplaceDialog;
class PASCALIMPLEMENTATION TReplaceDialogForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TLabel* Label1;
	Stdctrls::TComboBox* ComboBox1;
	Buttons::TSpeedButton* SpeedButton1;
	Menus::TPopupMenu* PopupMenu1;
	Menus::TMenuItem* abCharacter1;
	Menus::TMenuItem* NewLine1;
	Menus::TMenuItem* AnyCharacter1;
	Menus::TMenuItem* CharacterinRange1;
	Menus::TMenuItem* CharacternotinRange1;
	Menus::TMenuItem* BeginningofLine1;
	Menus::TMenuItem* EndofLine1;
	Menus::TMenuItem* aggedExpression1;
	Menus::TMenuItem* Or1;
	Menus::TMenuItem* N0or1matches1;
	Menus::TMenuItem* N1orMoreMatches1;
	Menus::TMenuItem* N0or1Matches2;
	Menus::TMenuItem* N1;
	Stdctrls::TButton* FindBtn;
	Stdctrls::TButton* ReplaceBtn;
	Stdctrls::TButton* ReplaceAllBtn;
	Stdctrls::TButton* CloseBtn;
	Stdctrls::TButton* MoreBtn;
	Stdctrls::TCheckBox* CheckBox1;
	Stdctrls::TCheckBox* CheckBox2;
	Stdctrls::TCheckBox* CheckBox4;
	Stdctrls::TCheckBox* CheckBox5;
	Stdctrls::TLabel* Label2;
	Stdctrls::TLabel* Label3;
	Stdctrls::TMemo* Memo1;
	Stdctrls::TMemo* Memo2;
	Stdctrls::TComboBox* ComboBox2;
	Extctrls::TRadioGroup* RangeGroup;
	Stdctrls::TLabel* Label4;
	Extctrls::TRadioGroup* DirGroup;
	void __fastcall SpeedButton1Click(System::TObject* Sender);
	void __fastcall abCharacter1Click(System::TObject* Sender);
	void __fastcall NewLine1Click(System::TObject* Sender);
	void __fastcall AnyCharacter1Click(System::TObject* Sender);
	void __fastcall CharacterinRange1Click(System::TObject* Sender);
	void __fastcall CharacternotinRange1Click(System::TObject* Sender);
	void __fastcall BeginningofLine1Click(System::TObject* Sender);
	void __fastcall EndofLine1Click(System::TObject* Sender);
	void __fastcall aggedExpression1Click(System::TObject* Sender);
	void __fastcall Or1Click(System::TObject* Sender);
	void __fastcall N0or1matches1Click(System::TObject* Sender);
	void __fastcall N1orMoreMatches1Click(System::TObject* Sender);
	void __fastcall N0or1Matches2Click(System::TObject* Sender);
	void __fastcall CloseBtnClick(System::TObject* Sender);
	void __fastcall FindBtnClick(System::TObject* Sender);
	void __fastcall ReplaceBtnClick(System::TObject* Sender);
	void __fastcall ReplaceAllBtnClick(System::TObject* Sender);
	void __fastcall MoreBtnClick(System::TObject* Sender);
	void __fastcall FormClose(System::TObject* Sender, Forms::TCloseAction &Action);
	void __fastcall CheckBox1Click(System::TObject* Sender);
	void __fastcall CheckBox2Click(System::TObject* Sender);
	void __fastcall CheckBox4Click(System::TObject* Sender);
	void __fastcall CheckBox5Click(System::TObject* Sender);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall RangeGroupClick(System::TObject* Sender);
	void __fastcall ComboBox1Change(System::TObject* Sender);
	void __fastcall ComboBox2Change(System::TObject* Sender);
	void __fastcall Memo1Change(System::TObject* Sender);
	
private:
	Classes::TNotifyEvent FOnReplace;
	Classes::TNotifyEvent FOnFind;
	Classes::TNotifyEvent FOnReplaceAll;
	Classes::TNotifyEvent FOnClose;
	TAdvReplaceDialog* FDialog;
	TEditChangeEvent FOnFindEditChange;
	TEditChangeEvent FOnReplaceEditChange;
	System::UnicodeString __fastcall GetReplaceText(void);
	void __fastcall SetReplaceText(const System::UnicodeString Value);
	System::UnicodeString __fastcall GetFindText(void);
	void __fastcall SetFindText(const System::UnicodeString Value);
	
protected:
	virtual void __fastcall DoFindEditChange(System::UnicodeString &AText);
	virtual void __fastcall DoReplaceEditChange(System::UnicodeString &AText);
	virtual void __fastcall EnableButtons(void);
	
public:
	__property TAdvReplaceDialog* Dialog = {read=FDialog, write=FDialog};
	__property Classes::TNotifyEvent OnReplace = {read=FOnReplace, write=FOnReplace};
	__property Classes::TNotifyEvent OnClose = {read=FOnClose, write=FOnClose};
	__property Classes::TNotifyEvent OnReplaceAll = {read=FOnReplaceAll, write=FOnReplaceAll};
	__property Classes::TNotifyEvent OnFind = {read=FOnFind, write=FOnFind};
	__property TEditChangeEvent OnFindEditChange = {read=FOnFindEditChange, write=FOnFindEditChange};
	__property TEditChangeEvent OnReplaceEditChange = {read=FOnReplaceEditChange, write=FOnReplaceEditChange};
	__property System::UnicodeString ReplaceText = {read=GetReplaceText, write=SetReplaceText};
	__property System::UnicodeString FindText = {read=GetFindText, write=SetFindText};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TReplaceDialogForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TReplaceDialogForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TReplaceDialogForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TReplaceDialogForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TReplaceUILanguage;
class PASCALIMPLEMENTATION TReplaceUILanguage : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::UnicodeString FFindWhat;
	System::UnicodeString FCaseSensitive;
	System::UnicodeString FWrapAtEndOfFile;
	System::UnicodeString FExpression;
	System::UnicodeString FMore;
	System::UnicodeString FWholeWordOnly;
	System::UnicodeString FClose;
	System::UnicodeString FFind;
	System::UnicodeString FCurrentFile;
	System::UnicodeString FReplace;
	System::UnicodeString FSelection;
	System::UnicodeString FReplaceAll;
	System::UnicodeString FAllOpenFiles;
	System::UnicodeString FReplaceWith;
	System::UnicodeString FLess;
	System::UnicodeString FReplaceAllRange;
	System::UnicodeString FDirection;
	System::UnicodeString FDown;
	System::UnicodeString FUp;
	System::UnicodeString FReplaceCaption;
	
public:
	__fastcall TReplaceUILanguage(Classes::TComponent* AOwner);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property System::UnicodeString ReplaceCaption = {read=FReplaceCaption, write=FReplaceCaption};
	__property System::UnicodeString FindWhat = {read=FFindWhat, write=FFindWhat};
	__property System::UnicodeString ReplaceWith = {read=FReplaceWith, write=FReplaceWith};
	__property System::UnicodeString CaseSensitive = {read=FCaseSensitive, write=FCaseSensitive};
	__property System::UnicodeString Expression = {read=FExpression, write=FExpression};
	__property System::UnicodeString WholeWordOnly = {read=FWholeWordOnly, write=FWholeWordOnly};
	__property System::UnicodeString WrapAtEndOfFile = {read=FWrapAtEndOfFile, write=FWrapAtEndOfFile};
	__property System::UnicodeString Find = {read=FFind, write=FFind};
	__property System::UnicodeString Replace = {read=FReplace, write=FReplace};
	__property System::UnicodeString ReplaceAll = {read=FReplaceAll, write=FReplaceAll};
	__property System::UnicodeString ReplaceAllRange = {read=FReplaceAllRange, write=FReplaceAllRange};
	__property System::UnicodeString Close = {read=FClose, write=FClose};
	__property System::UnicodeString More = {read=FMore, write=FMore};
	__property System::UnicodeString Less = {read=FLess, write=FLess};
	__property System::UnicodeString CurrentFile = {read=FCurrentFile, write=FCurrentFile};
	__property System::UnicodeString Selection = {read=FSelection, write=FSelection};
	__property System::UnicodeString AllOpenFiles = {read=FAllOpenFiles, write=FAllOpenFiles};
	__property System::UnicodeString Direction = {read=FDirection, write=FDirection};
	__property System::UnicodeString Up = {read=FUp, write=FUp};
	__property System::UnicodeString Down = {read=FDown, write=FDown};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TReplaceUILanguage(void) { }
	
};


class PASCALIMPLEMENTATION TAdvReplaceDialog : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	System::UnicodeString FReplaceText;
	Classes::TNotifyEvent FOnReplace;
	Classes::TNotifyEvent FOnShow;
	Classes::TNotifyEvent FOnReplacePrevious;
	Classes::TNotifyEvent FOnClose;
	TAdvReplaceDialogOptions FOptions;
	Classes::TStringList* FReplaceList;
	Classes::TNotifyEvent FOnFind;
	System::UnicodeString FFindText;
	Classes::TStringList* FFindList;
	TReplaceUILanguage* FUILanguage;
	TAdvReplaceDialogVisibleOptions FVisibleOptions;
	TEditChangeEvent FOnFindEditChange;
	TEditChangeEvent FOnReplaceEditChange;
	bool FAutoHistory;
	Forms::TFormBorderStyle FBorderStyle;
	TReplaceDialogForm* Frm;
	void __fastcall SetUILanguage(const TReplaceUILanguage* Value);
	void __fastcall SetOptions(const TAdvReplaceDialogOptions Value);
	
protected:
	void __fastcall DoShow(System::TObject* Sender);
	void __fastcall DoClose(System::TObject* Sender);
	void __fastcall DoReplace(System::TObject* Sender);
	void __fastcall DoReplaceAll(System::TObject* Sender);
	void __fastcall DoFind(System::TObject* Sender);
	void __fastcall DoFindEditChange(System::TObject* Sender, System::UnicodeString &AText);
	void __fastcall DoReplaceEditChange(System::TObject* Sender, System::UnicodeString &AText);
	virtual TReplaceDialogForm* __fastcall CreateDialogForm(Classes::TComponent* AOwner);
	virtual Forms::TCustomForm* __fastcall InitDialog(void);
	
public:
	virtual void __fastcall Execute(void);
	__fastcall virtual TAdvReplaceDialog(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdvReplaceDialog(void);
	__property TReplaceDialogForm* Form = {read=Frm};
	
__published:
	__property bool AutoHistory = {read=FAutoHistory, write=FAutoHistory, default=1};
	__property Forms::TFormBorderStyle BorderStyle = {read=FBorderStyle, write=FBorderStyle, default=3};
	__property System::UnicodeString ReplaceText = {read=FReplaceText, write=FReplaceText};
	__property System::UnicodeString FindText = {read=FFindText, write=FFindText};
	__property Classes::TStringList* ReplaceList = {read=FReplaceList, write=FReplaceList};
	__property Classes::TStringList* FindList = {read=FFindList, write=FFindList};
	__property Classes::TNotifyEvent OnFind = {read=FOnFind, write=FOnFind};
	__property TEditChangeEvent OnFindEditChange = {read=FOnFindEditChange, write=FOnFindEditChange};
	__property Classes::TNotifyEvent OnReplace = {read=FOnReplace, write=FOnReplace};
	__property TEditChangeEvent OnReplaceEditChange = {read=FOnReplaceEditChange, write=FOnReplaceEditChange};
	__property Classes::TNotifyEvent OnClose = {read=FOnClose, write=FOnClose};
	__property Classes::TNotifyEvent OnShow = {read=FOnShow, write=FOnShow};
	__property Classes::TNotifyEvent OnReplaceAll = {read=FOnReplacePrevious, write=FOnReplacePrevious};
	__property TAdvReplaceDialogOptions Options = {read=FOptions, write=SetOptions, default=36736};
	__property TAdvReplaceDialogVisibleOptions VisibleOptions = {read=FVisibleOptions, write=FVisibleOptions, default=196607};
	__property TReplaceUILanguage* UILanguage = {read=FUILanguage, write=SetUILanguage};
};


//-- var, const, procedure ---------------------------------------------------
#define DefaultOptions (Set<TAdvReplaceDialogOption, fdoCurrentFile, fdoDown> () << fdoMoreEnabled << fdoFindEnabled << fdoReplaceAllEnabled << fdoReplaceEnabled << fdoCloseEnabled << fdoDown )
#define DefaultVisibleOptions (Set<TAdvFindDialogVisibleOption, fdovCaseSensitive, fdovDirection> () << fdovCaseSensitive << fdovExpression << fdovWholeWordOnly << fdovWrapAtEndOfFile << fdovMore << fdovReplace << fdovReplaceAll << fdovFind << fdovClose << fdovFindCombo << fdovFindMemo << fdovReplaceCombo << fdovReplaceMemo << fdovReplaceAllRange << fdovCurrentFile << fdovSelection << fdovDirection )
extern PACKAGE TReplaceDialogForm* ReplaceDialogForm;
extern PACKAGE bool More;
extern PACKAGE System::UnicodeString FPrevCap;

}	/* namespace Advreplacedialogform */
using namespace Advreplacedialogform;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvreplacedialogformHPP
