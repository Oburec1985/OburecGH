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
}
//---------------------------------------------------------------------------

void __fastcall TForm1::frxReport1GetValue(const AnsiString VarName,
      Variant &Value)
{

  if(CompareText(VarName, "file") == 0)
  {
    TStringList * sl = new TStringList;
    sl->LoadFromFile("Unit1.cpp");
    Value = sl->Text;
    delete sl;
  }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button1Click(TObject *Sender)
{
        frxReport1->ShowReport(true);        
}
//---------------------------------------------------------------------------
