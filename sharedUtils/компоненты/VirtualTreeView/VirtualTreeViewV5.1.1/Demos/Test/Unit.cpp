//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "VirtualTrees"
#pragma resource "*.dfm"
TForm9 *Form9;
//---------------------------------------------------------------------------

__fastcall TForm9::TForm9(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall setOptions( TVirtualStringTree *Sender )
{
	Sender->RootNodeCount = 10;
    Sender->TreeOptions->SelectionOptions << toMultiSelect;

}
void __fastcall TForm9::FormCreate(TObject *Sender)
{
	setOptions( vt );
    setOptions( vt2 );
}
//---------------------------------------------------------------------------

void __fastcall TForm9::vtGetText(TBaseVirtualTree *Sender, PVirtualNode Node, TColumnIndex Column, TVSTTextType TextType, UnicodeString &CellText)
{
	CellText = L"OnGetText";
}
//---------------------------------------------------------------------------

void __fastcall TForm9::vtAfterItemErase(TBaseVirtualTree *Sender, TCanvas *TargetCanvas, PVirtualNode Node, TRect &ItemRect)
{
	if ((Node->Index % 2) == 0)
    {
   		TargetCanvas->Brush->Color = clYellow;
   		TargetCanvas->FillRect( ItemRect );
	}
}
//---------------------------------------------------------------------------

void __fastcall TForm9::vtPaintBackground(TBaseVirtualTree *Sender, TCanvas *TargetCanvas, TRect &R, bool &Handled)
{
   TargetCanvas->Brush->Color = clRed;
   TargetCanvas->FillRect( R );
   Handled = false;
}
//---------------------------------------------------------------------------

