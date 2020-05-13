//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "frxClass"
#pragma resource "*.dfm"
#define MAX_MASTER 3
#define MAX_DETAIL 15
TForm1 *Form1;

String Master[MAX_MASTER][2] = { // master Id, master name
    {"1", "master 1"},
    {"2", "master 2"},
    {"3", "master 3"}};

String Detail[MAX_DETAIL][2] = { // master Id, detail name
    {"1", "detail 1.1"}, {"1", "detail 1.2"}, {"1", "detail 1.3"},
    {"1", "detail 1.4"}, {"1", "detail 1.5"}, {"2", "detail 2.1"},
    {"2", "detail 2.2"}, {"2", "detail 2.3"}, {"2", "detail 2.4"},
    {"2", "detail 2.5"}, {"3", "detail 3.1"}, {"3", "detail 3.2"},
    {"3", "detail 3.3"}, {"3", "detail 3.4"}, {"3", "detail 3.5"}};
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::PrintClick(TObject *Sender)
{
        frxReport1->ShowReport(true);        
}
//---------------------------------------------------------------------------
void __fastcall TForm1::MasterDSFirst(TObject *Sender)
{
        MasterNo = 0;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::MasterDSNext(TObject *Sender)
{
        MasterNo++;        
}
//---------------------------------------------------------------------------
void __fastcall TForm1::MasterDSCheckEOF(TObject *Sender, bool &Eof)
{
        Eof = MasterNo > MAX_MASTER - 1;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::MasterDSGetValue(const AnsiString VarName,
      Variant &Value)
{
        Value = Master[MasterNo][1];
}
//---------------------------------------------------------------------------
void __fastcall TForm1::MasterDSPrior(TObject *Sender)
{
        if(MasterNo > 0) MasterNo--;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::DetailDSCheckEOF(TObject *Sender, bool &Eof)
{
         Eof = DetailNo > MAX_DETAIL - 1;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::DetailDSFirst(TObject *Sender)
{
          DetailNo = 0;
          while((!DetailDS->Eof()) && (Detail[DetailNo][0] != Master[MasterNo][0]))
            DetailNo++;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::DetailDSGetValue(const AnsiString VarName,
      Variant &Value)
{
        Value = Detail[DetailNo][1];
}
//---------------------------------------------------------------------------
void __fastcall TForm1::DetailDSNext(TObject *Sender)
{
        DetailNo++;
        while ((!DetailDS->Eof()) && (Detail[DetailNo][0] != Master[MasterNo][0]))
                DetailNo++;

}
//---------------------------------------------------------------------------
void __fastcall TForm1::DetailDSPrior(TObject *Sender)
{
        DetailNo--;
        while ((DetailNo > 0) && (Detail[DetailNo][0] != Master[MasterNo][0]))
                DetailNo--;
}
//---------------------------------------------------------------------------
