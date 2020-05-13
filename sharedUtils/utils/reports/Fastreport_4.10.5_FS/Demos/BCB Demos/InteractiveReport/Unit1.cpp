//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "frxClass"
#pragma link "frxDBSet"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button1Click(TObject *Sender)
{
        MainReport->ShowReport(true);        
}
//---------------------------------------------------------------------------
void __fastcall TForm1::MainReportClickObject(TfrxView *Sender,
      TMouseButton Button, TShiftState Shift, bool &Modified)
{
  if(strcmp(Sender->Name.c_str(),"Memo8\0") == 0)
  {
    DetailQuery->Close();
    DetailQuery->ParamByName("custno")->Value = StrToInt(Sender->TagStr);
    DetailReport->ShowReport(true);
  }
}
//---------------------------------------------------------------------------
