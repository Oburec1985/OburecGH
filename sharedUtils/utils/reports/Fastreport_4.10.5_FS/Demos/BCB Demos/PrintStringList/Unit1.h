//---------------------------------------------------------------------------
#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "frxClass.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TfrxReport *frxReport1;
        TfrxUserDataSet *StringDS;
        TButton *Button1;
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall frxReport1GetValue(const AnsiString VarName,
          Variant &Value);
private:	// User declarations
        TStringList * sl;
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
        __fastcall ~TForm1();
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
