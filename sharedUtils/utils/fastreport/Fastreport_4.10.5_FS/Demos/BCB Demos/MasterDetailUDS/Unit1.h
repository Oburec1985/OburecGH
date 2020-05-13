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
        TfrxUserDataSet *MasterDS;
        TfrxUserDataSet *DetailDS;
        TButton *Print;
        void __fastcall PrintClick(TObject *Sender);
        void __fastcall MasterDSFirst(TObject *Sender);
        void __fastcall MasterDSNext(TObject *Sender);
        void __fastcall MasterDSCheckEOF(TObject *Sender, bool &Eof);
        void __fastcall MasterDSGetValue(const AnsiString VarName,
          Variant &Value);
        void __fastcall MasterDSPrior(TObject *Sender);
        void __fastcall DetailDSCheckEOF(TObject *Sender, bool &Eof);
        void __fastcall DetailDSFirst(TObject *Sender);
        void __fastcall DetailDSGetValue(const AnsiString VarName,
          Variant &Value);
        void __fastcall DetailDSNext(TObject *Sender);
        void __fastcall DetailDSPrior(TObject *Sender);
private:	// User declarations
        int MasterNo;
        int DetailNo;
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
