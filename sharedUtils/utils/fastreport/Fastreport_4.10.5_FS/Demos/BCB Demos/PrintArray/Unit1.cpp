//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "frxClass"
#pragma resource "*.dfm"
TForm1 *Form1;
int ar[10] = {0,1,2,3,4,5,6,7,8,9};
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
  ArrayDS->RangeEnd = reCount;
  ArrayDS->RangeEndCount = 10;
  frxReport1->ShowReport(true);
}
//---------------------------------------------------------------------------

void __fastcall TForm1::frxReport1GetValue(const AnsiString VarName,
      Variant &Value)
{
  if(CompareText(VarName, "element") == 0)
    Value = ar[ArrayDS->RecNo];
}
//---------------------------------------------------------------------------
