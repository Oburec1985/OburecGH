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

void __fastcall TForm1::Button1Click(TObject *Sender)
{
        frxReport1->ShowReport(true);

}
//---------------------------------------------------------------------------

void __fastcall TForm1::frxReport1BeforePrint(TfrxReportComponent *Sender)
{
  TfrxCrossView * Cross;
  int i, j;
  Variant Row,Col,Text;

  Cross = dynamic_cast <TfrxCrossView *> (Sender);

  if(Cross != NULL)
  {
    Table1->First();
    i = 0;
    while (!Table1->Eof)
    {
      for(j = 0; j < Table1->Fields->Count; j++)
      {
        Row = i;
        Col = Table1->Fields->Fields[j]->DisplayLabel;
        Text = Table1->Fields->Fields[j]->AsString;
        Cross->AddValue(&Row, 1, &Col, 1, &Text, 1);
      }
      Table1->Next();
      i++;
    }
  }
}
//---------------------------------------------------------------------------
 