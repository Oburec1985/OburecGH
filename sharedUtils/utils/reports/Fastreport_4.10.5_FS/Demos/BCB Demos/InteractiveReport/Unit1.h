//---------------------------------------------------------------------------
#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "frxClass.hpp"
#include "frxDBSet.hpp"
#include <Db.hpp>
#include <DBTables.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TButton *Button1;
        TTable *Customers;
        TQuery *DetailQuery;
        TfrxReport *MainReport;
        TfrxDBDataset *CustomersDS;
        TfrxDBDataset *DetailQueryDS;
        TfrxReport *DetailReport;
        TFloatField *DetailQueryCustNo2;
        TStringField *DetailQueryCompany2;
        TStringField *DetailQueryAddr12;
        TStringField *DetailQueryAddr22;
        TStringField *DetailQueryCity2;
        TStringField *DetailQueryState2;
        TStringField *DetailQueryZip2;
        TStringField *DetailQueryCountry2;
        TStringField *DetailQueryPhone2;
        TStringField *DetailQueryFAX2;
        TFloatField *DetailQueryTaxRate2;
        TStringField *DetailQueryContact2;
        TDateTimeField *DetailQueryLastInvoiceDate2;
        TFloatField *DetailQueryOrderNo2;
        TFloatField *DetailQueryCustNo_12;
        TDateTimeField *DetailQuerySaleDate2;
        TDateTimeField *DetailQueryShipDate2;
        TIntegerField *DetailQueryEmpNo2;
        TStringField *DetailQueryShipToContact2;
        TStringField *DetailQueryShipToAddr12;
        TStringField *DetailQueryShipToAddr22;
        TStringField *DetailQueryShipToCity2;
        TStringField *DetailQueryShipToState2;
        TStringField *DetailQueryShipToZip2;
        TStringField *DetailQueryShipToCountry2;
        TStringField *DetailQueryShipToPhone2;
        TStringField *DetailQueryShipVIA2;
        TStringField *DetailQueryPO2;
        TStringField *DetailQueryTerms2;
        TStringField *DetailQueryPaymentMethod2;
        TCurrencyField *DetailQueryItemsTotal2;
        TFloatField *DetailQueryTaxRate_12;
        TCurrencyField *DetailQueryFreight2;
        TCurrencyField *DetailQueryAmountPaid2;
        TFloatField *DetailQueryOrderNo_12;
        TFloatField *DetailQueryItemNo2;
        TFloatField *DetailQueryPartNo2;
        TIntegerField *DetailQueryQty2;
        TFloatField *DetailQueryDiscount2;
        TFloatField *DetailQueryPartNo_12;
        TFloatField *DetailQueryVendorNo2;
        TStringField *DetailQueryDescription2;
        TFloatField *DetailQueryOnHand2;
        TFloatField *DetailQueryOnOrder2;
        TCurrencyField *DetailQueryCost2;
        TCurrencyField *DetailQueryListPrice2;
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall MainReportClickObject(TfrxView *Sender,
          TMouseButton Button, TShiftState Shift, bool &Modified);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
