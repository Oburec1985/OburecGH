//---------------------------------------------------------------------------
#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "frxClass.hpp"
#include "frxCross.hpp"
#include <Db.hpp>
#include <DBTables.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TButton *Button1;
        TfrxReport *frxReport1;
        TfrxCrossObject *frxCrossObject1;
        TTable *Table1;
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall frxReport1BeforePrint(TfrxReportComponent *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
