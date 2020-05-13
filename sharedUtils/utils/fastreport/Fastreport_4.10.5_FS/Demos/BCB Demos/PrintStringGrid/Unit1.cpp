//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "frxClass"
#pragma link "frxCross"
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
  int idx1,idx2;

  for(idx1 = 1; idx1 < 17; idx1++)
    for(idx2 = 1; idx2 < 17; idx2++)
        StringGrid1->Cells[idx1 - 1][idx2 - 1] = IntToStr(idx1 * idx2);

}
//---------------------------------------------------------------------------

void __fastcall TForm1::frxReport1BeforePrint(TfrxReportComponent *Sender)
{
    TfrxCrossView * Cross = NULL;
    int idx1,idx2;
    Variant Row,Col,Text;
    if(strcmp(Sender->Name.c_str(),"Cross1\0") == 0)
        if(Cross = dynamic_cast <TfrxCrossView *> (Sender))
        {
              for(idx1 = 0; idx1 < StringGrid1->RowCount; idx1++)
                for(idx2 = 0; idx2 < StringGrid1->ColCount; idx2++)
                {
                    Row = idx1;
                    Col = idx2;
                    Text = StringGrid1->Cells[idx1][idx2];
                    Cross->AddValue(&Row,1,&Col,1,&Text,1);
                }
        }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
    frxReport1->ShowReport(true);
}
//---------------------------------------------------------------------------
