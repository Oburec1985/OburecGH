�
 TFORM1 0�I  TPF0TForm1Form1Left� ToprWidth� Height� CaptionForm1Color	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrderPixelsPerInch`
TextHeight TButtonButton1Left(Top WidthKHeightCaptionPrintTabOrder OnClickButton1Click  TTable	CustomersDatabaseNameBCDEMOS	IndexName	ByCompany	TableNamecustomer.dbLeftTop   TQueryDetailQueryDatabaseNameBCDEMOSSQL.Strings4select * from customer a, orders b, items c, parts dwhere a.custno = b.custno  and b.orderno = c.orderno  and c.partno = d.partno  and a.custno = :custnoorder by a.company, orderno LeftxTop 	ParamDataDataType	ftUnknownNamecustno	ParamType	ptUnknown   TFloatFieldDetailQueryCustNo2	FieldNameCustNo  TStringFieldDetailQueryCompany2	FieldNameCompanySize  TStringFieldDetailQueryAddr12	FieldNameAddr1Size  TStringFieldDetailQueryAddr22	FieldNameAddr2Size  TStringFieldDetailQueryCity2	FieldNameCitySize  TStringFieldDetailQueryState2	FieldNameState  TStringFieldDetailQueryZip2	FieldNameZipSize
  TStringFieldDetailQueryCountry2	FieldNameCountry  TStringFieldDetailQueryPhone2	FieldNamePhoneSize  TStringFieldDetailQueryFAX2	FieldNameFAXSize  TFloatFieldDetailQueryTaxRate2	FieldNameTaxRate  TStringFieldDetailQueryContact2	FieldNameContact  TDateTimeFieldDetailQueryLastInvoiceDate2	FieldNameLastInvoiceDate  TFloatFieldDetailQueryOrderNo2	FieldNameOrderNo  TFloatFieldDetailQueryCustNo_12	FieldNameCustNo_1  TDateTimeFieldDetailQuerySaleDate2	FieldNameSaleDate  TDateTimeFieldDetailQueryShipDate2	FieldNameShipDate  TIntegerFieldDetailQueryEmpNo2	FieldNameEmpNo  TStringFieldDetailQueryShipToContact2	FieldNameShipToContact  TStringFieldDetailQueryShipToAddr12	FieldNameShipToAddr1Size  TStringFieldDetailQueryShipToAddr22	FieldNameShipToAddr2Size  TStringFieldDetailQueryShipToCity2	FieldName
ShipToCitySize  TStringFieldDetailQueryShipToState2	FieldNameShipToState  TStringFieldDetailQueryShipToZip2	FieldName	ShipToZipSize
  TStringFieldDetailQueryShipToCountry2	FieldNameShipToCountry  TStringFieldDetailQueryShipToPhone2	FieldNameShipToPhoneSize  TStringFieldDetailQueryShipVIA2	FieldNameShipVIASize  TStringFieldDetailQueryPO2	FieldNamePOSize  TStringFieldDetailQueryTerms2	FieldNameTermsSize  TStringFieldDetailQueryPaymentMethod2	FieldNamePaymentMethodSize  TCurrencyFieldDetailQueryItemsTotal2	FieldName
ItemsTotal  TFloatFieldDetailQueryTaxRate_12	FieldName	TaxRate_1  TCurrencyFieldDetailQueryFreight2	FieldNameFreight  TCurrencyFieldDetailQueryAmountPaid2	FieldName
AmountPaid  TFloatFieldDetailQueryOrderNo_12	FieldName	OrderNo_1  TFloatFieldDetailQueryItemNo2	FieldNameItemNo  TFloatFieldDetailQueryPartNo2	FieldNamePartNo  TIntegerFieldDetailQueryQty2	FieldNameQty  TFloatFieldDetailQueryDiscount2	FieldNameDiscount  TFloatFieldDetailQueryPartNo_12	FieldNamePartNo_1  TFloatFieldDetailQueryVendorNo2	FieldNameVendorNo  TStringFieldDetailQueryDescription2	FieldNameDescriptionSize  TFloatFieldDetailQueryOnHand2	FieldNameOnHand  TFloatFieldDetailQueryOnOrder2	FieldNameOnOrder  TCurrencyFieldDetailQueryCost2	FieldNameCost  TCurrencyFieldDetailQueryListPrice2	FieldName	ListPrice   
TfrxReport
MainReportVersion4.6DotMatrixReportEngineOptions.DoublePass	IniFile\Software\Fast ReportsPreviewOptions.ButtonspbPrintpbLoadpbSavepbExportpbZoompbFind	pbOutlinepbPageSetuppbToolspbEditpbNavigatorpbExportQuick PreviewOptions.OutlineWidth� PreviewOptions.Zoom       ��?PrintOptions.PrinterDefaultPrintOptions.PrintOnSheet ReportOptions.CreateDate �r���@!ReportOptions.Description.Strings.Demonstrates how to create simple list report. ReportOptions.LastChange �8~Y೚@ScriptLanguagePascalScriptScriptText.Stringsbegin end. OnClickObjectMainReportClickObjectLeftDatasetsDataSetCustomersDSDataSetName	Customers  	Variables Style  TfrxDataPageDataHeight       �@Width       �@  TfrxReportPagePage1
PaperWidth       �@PaperHeight      ��@	PaperSize	
LeftMargin       �@RightMargin       �@	TopMargin       �@BottomMargin       �@ColumnsColumnWidth       �@ColumnPositions.Strings0 PrintOnPreviousPage	 TfrxReportTitleBand1Height       �@Top       �@Width�C�l����@ TfrxMemoViewMemo1AlignbaWidthTop       �@Width�C�l����@Height       �@ShowHintColorclGrayFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameArial
Font.StylefsBold HAlignhaCenter	Memo.UTF8	Customers 
ParentFontVAlignvaBottom   TfrxPageHeaderBand2Height       �@Top       �@Width�C�l����@ TfrxMemoViewMemo3Left       �@Top       �@Width       �@Height       �@ShowHintColorclWhiteFont.CharsetDEFAULT_CHARSET
Font.ColorclMaroonFont.Height�	Font.NameArial
Font.StylefsBold 	Frame.TypftBottom 	Memo.UTF8Company 
ParentFont  TfrxMemoViewMemo4Left       �@Top       �@Width       �@Height       �@ShowHintColorclWhiteFont.CharsetDEFAULT_CHARSET
Font.ColorclMaroonFont.Height�	Font.NameArial
Font.StylefsBold 	Frame.TypftBottom 	Memo.UTF8Address 
ParentFont  TfrxMemoViewMemo5Left       �@Top       �@Width       �@Height       �@ShowHintColorclWhiteFont.CharsetDEFAULT_CHARSET
Font.ColorclMaroonFont.Height�	Font.NameArial
Font.StylefsBold 	Frame.TypftBottom 	Memo.UTF8Contact 
ParentFont  TfrxMemoViewMemo6Left       �@Top       �@Width       �@Height       �@ShowHintColorclWhiteFont.CharsetDEFAULT_CHARSET
Font.ColorclMaroonFont.Height�	Font.NameArial
Font.StylefsBold 	Frame.TypftBottom 	Memo.UTF8Phone 
ParentFont  TfrxMemoViewMemo7Left      @�@Top       �@Width       �@Height       �@ShowHintColorclWhiteFont.CharsetDEFAULT_CHARSET
Font.ColorclMaroonFont.Height�	Font.NameArial
Font.StylefsBold 	Frame.TypftBottom 	Memo.UTF8Fax 
ParentFont   TfrxPageFooterBand3Height       �@Top       �@Width�C�l����@ TfrxMemoViewMemo2Left       �@Top       �@Width       �@Height       �@ShowHintColorclWhiteFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style 	Frame.TypftTop Frame.Width       � @HAlignhaRight	Memo.UTF8Page [Page] of [TotalPages] 
ParentFont   TfrxMasterDataBand4Height       �@Top       �@Width�C�l����@ColumnsColumnWidth       �@	ColumnGap       �@DataSetCustomersDSDataSetName	CustomersRowCount  TfrxMemoViewMemo13Left       �@Width       �@Height       �@ShowHintDataSetCustomersDSDataSetName	CustomersHighlight.Font.CharsetDEFAULT_CHARSETHighlight.Font.Color  ��Highlight.Font.Height�Highlight.Font.NameArialHighlight.Font.Style Highlight.Color��� Highlight.Condition<Line#> mod 2WordWrap  TfrxMemoViewMemo8Left       �@Width       �@Height       �@ShowHintCursorcrHandPointTagStr[Customers."Cust No"]	DataFieldCompanyDataSetCustomersDSDataSetName	Customers	Memo.UTF8[Customers."Company"]   TfrxMemoViewMemo9Left       �@Width       �@Height       �@ShowHint	DataFieldAddr1DataSetCustomersDSDataSetName	Customers	Memo.UTF8[Customers."Addr1"]   TfrxMemoViewMemo10Left       �@Width       �@Height       �@ShowHint	DataFieldContactDataSetCustomersDSDataSetName	Customers	Memo.UTF8[Customers."Contact"]   TfrxMemoViewMemo11Left       �@Width       �@Height       �@ShowHint	DataFieldPhoneDataSetCustomersDSDataSetName	Customers	Memo.UTF8[Customers."Phone"]   TfrxMemoViewMemo12Left      @�@Width       �@Height       �@ShowHint	DataFieldFAXDataSetCustomersDSDataSetName	Customers	Memo.UTF8[Customers."FAX"]      TfrxDBDatasetCustomersDSUserName	CustomersCloseDataSourceFieldAliases.StringsCustNo=Cust NoCompany=CompanyAddr1=Addr1Addr2=Addr2	City=CityState=StateZip=ZipCountry=CountryPhone=PhoneFAX=FAXTaxRate=Tax RateContact=Contact!LastInvoiceDate=Last Invoice Date DataSet	CustomersLeftTop@  TfrxDBDatasetDetailQueryDSUserNameSalesCloseDataSourceFieldAliases.StringsCustNo=Cust NoCompany=CompanyAddr1=Addr1Addr2=Addr2	City=CityState=StateZip=ZipCountry=CountryPhone=PhoneFAX=FAXTaxRate=Tax RateContact=Contact!LastInvoiceDate=Last Invoice DateOrderNo=Order NoCustNo_1=Cust No 1SaleDate=Sale DateShipDate=Ship DateEmpNo=Emp NoShipToContact=Ship To ContactShipToAddr1=Ship To Addr1ShipToAddr2=Ship To Addr2ShipToCity=Ship To CityShipToState=Ship To StateShipToZip=Ship To ZipShipToCountry=Ship To CountryShipToPhone=Ship To PhoneShipVIA=Ship VIAPO=POTerms=TermsPaymentMethod=Payment MethodItemsTotal=Items TotalTaxRate_1=Tax Rate 1Freight=FreightAmountPaid=Amount PaidOrderNo_1=Order No 1ItemNo=Item NoPartNo=Part NoQty=QtyDiscount=DiscountPartNo_1=Part No 1VendorNo=Vendor NoDescription=DescriptionOnHand=On HandOnOrder=On Order	Cost=CostListPrice=List Price DataSetDetailQueryLeftxTop@  
TfrxReportDetailReportVersion4.6DotMatrixReportIniFile\Software\Fast ReportsPreviewOptions.ButtonspbPrintpbLoadpbSavepbExportpbZoompbFind	pbOutlinepbPageSetuppbToolspbEditpbNavigatorpbExportQuick PreviewOptions.Zoom       ��?PrintOptions.PrinterDefaultPrintOptions.PrintOnSheet ReportOptions.CreateDate �����@!ReportOptions.Description.Strings-This report shows how to use multiple groups. ReportOptions.LastChange   x೚@ScriptLanguagePascalScriptScriptText.Stringsbegin end. LeftxDatasetsDataSetDetailQueryDSDataSetNameSales  	VariablesName	 CustomerValue  NameCompanyValueCustomerData.RepQuery."Company" NameAddressValueCustomerData.RepQuery."Addr1" NameContactValueCustomerData.RepQuery."Contact" NamePhoneValueCustomerData.RepQuery."Phone" NameFaxValueCustomerData.RepQuery."FAX" Name OrderValue  NameOrder noValueCustomerData.RepQuery."OrderNo" Name
Order dateValue CustomerData.RepQuery."SaleDate" Name PartValue  NamePart noValueCustomerData.RepQuery."PartNo" NamePart descriptionValue#CustomerData.RepQuery."Description" Name
Part priceValue!CustomerData.RepQuery."ListPrice" NamePart qtyValueCustomerData.RepQuery."Qty" Name
Part totalValue[Part price]*[Part qty] Name DescriptionValue  NameDescriptionValue-This report shows how to use multiple groups.  Style  TfrxDataPageDataHeight       �@Width       �@  TfrxReportPagePage1
PaperWidth       �@PaperHeight      ��@	PaperSize	
LeftMargin       �@RightMargin       �@	TopMargin       �@BottomMargin       �@ColumnsColumnWidth       �@ColumnPositions.Strings0 PrintOnPreviousPage	 TfrxReportTitleBand2Height       �@Top       �@Width�C�l����@ TfrxMemoViewMemo6Left       � @Top       �@Width       �@Height       �@ShowHintColorclGrayFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameArial
Font.StylefsBold HAlignhaCenter	Memo.UTF8	Customers 
ParentFontVAlignvaBottom   TfrxGroupHeaderBand4Height       �@Top       �@Width�C�l����@	ConditionSales."Cust No" TfrxMemoViewMemo7Left       � @Width       �@Height       �@ShowHintColorclMaroonFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameArial
Font.StylefsBoldfsItalic Frame.ColorclGray	Frame.TypftLeftftRightftTop 
ParentFontVAlignvaBottom  TfrxMemoViewMemo17Left       �@Width       �@Height       �@ShowHintColorclMaroonFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameArial
Font.Style Frame.ColorclGray	Frame.TypftTop 	Memo.UTF8Company 
ParentFont  TfrxMemoViewMemo18Left       �@Top       �@Width       �@Height       �@ShowHintColorclMaroonFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameArial
Font.StylefsItalic Frame.ColorclGray	Memo.UTF8[Sales."Company"] 
ParentFont  TfrxMemoViewMemo19Left       �@Width       �@Height       �@ShowHintColorclMaroonFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameArial
Font.Style Frame.ColorclGray	Frame.TypftTop 	Memo.UTF8Phone 
ParentFont  TfrxMemoViewMemo20Left       �@Width       �@Height       �@ShowHintColorclMaroonFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameArial
Font.Style Frame.ColorclGray	Frame.TypftTop 	Memo.UTF8Fax 
ParentFont  TfrxMemoViewMemo21Left       �@Top       �@Width       �@Height       �@ShowHintColorclMaroonFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameArial
Font.StylefsItalic Frame.ColorclGray	Memo.UTF8[Sales."Phone"] 
ParentFont  TfrxMemoViewMemo22Left       �@Top       �@Width       �@Height       �@ShowHintColorclMaroonFont.CharsetDEFAULT_CHARSET
Font.ColorclWhiteFont.Height�	Font.NameArial
Font.StylefsItalic Frame.ColorclGray	Memo.UTF8[Sales."FAX"] 
ParentFont   TfrxGroupHeaderBand5Height       �@Top       �@Width�C�l����@	ConditionSales."Order No" TfrxMemoViewMemo3Left       � @Top       �@Width       �@Height       �@ShowHintFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.StylefsBold Frame.ColorclGray	Frame.TypftLeftftRight 
ParentFont  TfrxMemoViewMemo4Left       � @Width       �@Height       �@ShowHintColorclSilverFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.StylefsBold Frame.ColorclGray	Frame.TypftLeftftRight 
ParentFont  TfrxMemoViewMemo8Left       �@Width       �@Height       �@ShowHintColorclSilverFrame.ColorclGray	Memo.UTF8Order No [Sales."Order No"]   TfrxMemoViewMemo9Left       �@Width       �@Height       �@ShowHintColorclSilverFrame.ColorclGray	Memo.UTF8Date [Sales."Sale Date"]   TfrxMemoViewMemo10Left       �@Top       �@Width       �@Height       �@ShowHintFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style Frame.ColorclGrayHAlignhaCenter	Memo.UTF8Part 
ParentFont  TfrxMemoViewMemo11Left       �@Top       �@Width       �@Height       �@ShowHintFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style Frame.ColorclGrayHAlignhaCenter	Memo.UTF8Description 
ParentFont  TfrxMemoViewMemo12Left       �@Top       �@Width       �@Height       �@ShowHintFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style Frame.ColorclGrayHAlignhaCenter	Memo.UTF8Price 
ParentFont  TfrxMemoViewMemo13Left       �@Top       �@Width       �@Height       �@ShowHintFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style Frame.ColorclGrayHAlignhaCenter	Memo.UTF8Qty 
ParentFont  TfrxMemoViewMemo14Left       �@Top       �@Width       �@Height       �@ShowHintFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style Frame.ColorclGrayHAlignhaCenter	Memo.UTF8Total 
ParentFont   TfrxMasterDataBand6Height       �@Top       �@Width�C�l����@ColumnsColumnWidth       �@	ColumnGap       �@DataSetDetailQueryDSDataSetNameSalesRowCount  TfrxMemoViewMemo2Left       � @Width       �@Height       �@ShowHintFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.StylefsBold Frame.ColorclGray	Frame.TypftLeftftRight 
ParentFont  TfrxMemoViewMemo23Left       �@Width       �@Height       �@ShowHint	DataFieldPart NoDataSetDetailQueryDSDataSetNameSalesFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style Frame.ColorclGrayHAlignhaCenter	Memo.UTF8[Sales."Part No"] 
ParentFont  TfrxMemoViewMemo24Left       �@Width       �@Height       �@ShowHint	DataFieldDescriptionDataSetDetailQueryDSDataSetNameSalesFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style Frame.ColorclGray	Memo.UTF8[Sales."Description"] 
ParentFont  TfrxMemoViewMemo25Left       �@Width       �@Height       �@ShowHint	DataField
List PriceDataSetDetailQueryDSDataSetNameSalesDisplayFormat.FormatStr%2.2mFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style Frame.ColorclGrayHAlignhaRight	Memo.UTF8[Sales."List Price"] 
ParentFont  TfrxMemoViewMemo26Left       �@Width       �@Height       �@ShowHint	DataFieldQtyDataSetDetailQueryDSDataSetNameSalesFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style Frame.ColorclGrayHAlignhaCenter	Memo.UTF8[Sales."Qty"] 
ParentFont  TfrxMemoViewMemo27Left       �@Width       �@Height       �@ShowHintDisplayFormat.DecimalSeparator,DisplayFormat.FormatStr%2.2mDisplayFormat.Kind	fkNumericFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.Style Frame.ColorclGrayHAlignhaRight	Memo.UTF8$[<Sales."Qty">*<Sales."List Price">] 
ParentFont   TfrxGroupFooterBand7Height       �@Top       �@Width�C�l����@ TfrxMemoViewMemo28Left       � @Width       �@Height       �@ShowHintColorclSilverDisplayFormat.DecimalSeparator,DisplayFormat.FormatStr%2.2mDisplayFormat.Kind	fkNumericFrame.ColorclGray	Frame.TypftLeftftRightftBottom 	Memo.UTF8DTotal sales this customer: [Sum(<Sales."Qty">*<Sales."List Price">)]    TfrxGroupFooterBand8Height       �@Top       �@Width�C�l����@ TfrxMemoViewMemo1Left       � @Width       �@Height       �@ShowHintFont.CharsetDEFAULT_CHARSET
Font.ColorclBlackFont.Height�	Font.NameArial
Font.StylefsBold Frame.ColorclGray	Frame.TypftLeftftRight 
ParentFont  TfrxMemoViewMemo15Left       �@Width       �@Height       �@ShowHintDisplayFormat.DecimalSeparator,DisplayFormat.FormatStr%2.2mDisplayFormat.Kind	fkNumericFont.CharsetDEFAULT_CHARSET
Font.ColorclMaroonFont.Height�	Font.NameArial
Font.Style Frame.ColorclGray	Frame.TypftTop HAlignhaRight	Memo.UTF8;Total this order: [Sum(<Sales."Qty">*<Sales."List Price">)] 
ParentFont      