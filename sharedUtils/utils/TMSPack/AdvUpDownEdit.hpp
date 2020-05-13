// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Advupdownedit.pas' rev: 21.00

#ifndef AdvupdowneditHPP
#define AdvupdowneditHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Advmultibuttonedit.hpp>	// Pascal unit
#include <Advedit.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Advupdownedit
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TUpDownType { udInteger, udFloat };
#pragma option pop

class DELPHICLASS TAdvUpDownEdit;
class PASCALIMPLEMENTATION TAdvUpDownEdit : public Advmultibuttonedit::TAdvCustomMultiButtonEdit
{
	typedef Advmultibuttonedit::TAdvCustomMultiButtonEdit inherited;
	
private:
	double FIncrementFloat;
	int FIncrement;
	TUpDownType FUpDownType;
	int FPrecision;
	double __fastcall GetMaxFloatValue(void);
	void __fastcall SetMaxFloatValue(const double Value);
	void __fastcall SetMaxValue(const int Value);
	void __fastcall SetMinValue(const int Value);
	int __fastcall GetMaxValue(void);
	double __fastcall GetMinFloatValue(void);
	int __fastcall GetMinValue(void);
	void __fastcall SetMinFloatValue(const double Value);
	int __fastcall GetPrecision(void);
	void __fastcall SetPrecision(const int Value);
	void __fastcall SetUpDownType(const TUpDownType Value);
	Advedit::TEditAlign __fastcall GetEditAlign(void);
	void __fastcall SetEditAlign(const Advedit::TEditAlign Value);
	bool __fastcall UseMinMax(void);
	bool __fastcall UseMinMaxFloat(void);
	Advmultibuttonedit::TEditButton* __fastcall GetButtonAdd(void);
	Advmultibuttonedit::TEditButton* __fastcall GetButtonSub(void);
	bool __fastcall GetEditorEnabled(void);
	void __fastcall SetEditorEnabled(const bool Value);
	
protected:
	virtual void __fastcall DoClickAdd(void);
	virtual void __fastcall DoClickSub(void);
	
public:
	__fastcall virtual TAdvUpDownEdit(Classes::TComponent* AOwner);
	__property Advmultibuttonedit::TEditButton* ButtonAdd = {read=GetButtonAdd};
	__property Advmultibuttonedit::TEditButton* ButtonSub = {read=GetButtonSub};
	
__published:
	__property Advedit::TEditAlign EditAlign = {read=GetEditAlign, write=SetEditAlign, default=3};
	__property bool EditorEnabled = {read=GetEditorEnabled, write=SetEditorEnabled, default=1};
	__property double MaxFloatValue = {read=GetMaxFloatValue, write=SetMaxFloatValue};
	__property double MinFloatValue = {read=GetMinFloatValue, write=SetMinFloatValue};
	__property int MaxValue = {read=GetMaxValue, write=SetMaxValue, default=0};
	__property int MinValue = {read=GetMinValue, write=SetMinValue, default=0};
	__property int Increment = {read=FIncrement, write=FIncrement, default=1};
	__property double IncrementFloat = {read=FIncrementFloat, write=FIncrementFloat};
	__property int Precision = {read=GetPrecision, write=SetPrecision, default=0};
	__property TUpDownType UpdownType = {read=FUpDownType, write=SetUpDownType, default=0};
	__property OnClickAdd;
	__property OnClickSub;
public:
	/* TAdvCustomMultiButtonEdit.Destroy */ inline __fastcall virtual ~TAdvUpDownEdit(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TAdvUpDownEdit(HWND ParentWindow) : Advmultibuttonedit::TAdvCustomMultiButtonEdit(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Advupdownedit */
using namespace Advupdownedit;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// AdvupdowneditHPP
