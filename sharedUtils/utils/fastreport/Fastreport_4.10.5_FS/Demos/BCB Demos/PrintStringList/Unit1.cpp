//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "frxClass"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
        sl = new TStringList;
        for(int idx = 0; idx < 10; idx++, sl->Add(IntToStr(idx))); 
}
//---------------------------------------------------------------------------
__fastcall TForm1::~TForm1()
{
        delete sl;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button1Click(TObject *Sender)
{
        StringDS->RangeEnd = reCount;
        StringDS->RangeEndCount = sl->Count;
        frxReport1->ShowReport(true);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::frxReport1GetValue(const AnsiString VarName,
      Variant &Value)
{

        if(CompareText(VarName, "element") == 0)
          Value = sl->Strings[StringDS->RecNo];
}
//---------------------------------------------------------------------------
