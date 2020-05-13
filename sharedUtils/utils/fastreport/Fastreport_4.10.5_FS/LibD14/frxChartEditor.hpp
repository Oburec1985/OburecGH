// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxcharteditor.pas' rev: 21.00

#ifndef FrxcharteditorHPP
#define FrxcharteditorHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxchart.hpp>	// Pascal unit
#include <Frxcustomeditors.hpp>	// Pascal unit
#include <Frxctrls.hpp>	// Pascal unit
#include <Frxinsp.hpp>	// Pascal unit
#include <Frxdock.hpp>	// Pascal unit
#include <Teeprocs.hpp>	// Pascal unit
#include <Teengine.hpp>	// Pascal unit
#include <Chart.hpp>	// Pascal unit
#include <Series.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Teegalleryalternate.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Frxdsgnintf.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxcharteditor
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxChartEditor;
class PASCALIMPLEMENTATION TfrxChartEditor : public Frxcustomeditors::TfrxViewEditor
{
	typedef Frxcustomeditors::TfrxViewEditor inherited;
	
public:
	virtual bool __fastcall Edit(void);
	virtual bool __fastcall HasEditor(void);
	virtual void __fastcall GetMenuItems(void);
	virtual bool __fastcall Execute(int Tag, bool Checked);
public:
	/* TfrxComponentEditor.Create */ inline __fastcall TfrxChartEditor(Frxclass::TfrxComponent* Component, Frxclass::TfrxCustomDesigner* Designer, Menus::TMenu* Menu) : Frxcustomeditors::TfrxViewEditor(Component, Designer, Menu) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxChartEditor(void) { }
	
};


class DELPHICLASS TfrxChartEditorForm;
class PASCALIMPLEMENTATION TfrxChartEditorForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Extctrls::TPanel* Panel1;
	Extctrls::TPanel* Panel2;
	Controls::TImageList* ChartImages;
	Stdctrls::TButton* CancelB;
	Extctrls::TPanel* SourcePanel;
	Stdctrls::TGroupBox* DataSourceGB;
	Stdctrls::TRadioButton* DBSourceRB;
	Stdctrls::TRadioButton* BandSourceRB;
	Stdctrls::TRadioButton* FixedDataRB;
	Stdctrls::TComboBox* DatasetsCB;
	Stdctrls::TComboBox* DatabandsCB;
	Stdctrls::TGroupBox* ValuesGB;
	Stdctrls::TComboBox* Values1CB;
	Stdctrls::TLabel* Values1L;
	Stdctrls::TLabel* Values2L;
	Stdctrls::TComboBox* Values2CB;
	Stdctrls::TLabel* Values3L;
	Stdctrls::TComboBox* Values3CB;
	Stdctrls::TLabel* Values4L;
	Stdctrls::TComboBox* Values4CB;
	Stdctrls::TGroupBox* OptionsGB;
	Stdctrls::TLabel* ShowTopLbl;
	Stdctrls::TLabel* CaptionLbl;
	Stdctrls::TLabel* SortLbl;
	Stdctrls::TLabel* XLbl;
	Stdctrls::TEdit* TopNE;
	Stdctrls::TEdit* TopNCaptionE;
	Stdctrls::TComboBox* SortCB;
	Comctrls::TUpDown* UpDown1;
	Stdctrls::TComboBox* XTypeCB;
	Extctrls::TPanel* InspSite;
	Stdctrls::TLabel* Values5L;
	Stdctrls::TComboBox* Values5CB;
	Stdctrls::TLabel* HintL;
	Stdctrls::TLabel* Values6L;
	Stdctrls::TComboBox* Values6CB;
	Extctrls::TPanel* Panel3;
	Comctrls::TTreeView* ChartTree;
	Extctrls::TPanel* TreePanel;
	Buttons::TSpeedButton* AddB;
	Buttons::TSpeedButton* DeleteB;
	Buttons::TSpeedButton* EditB;
	Buttons::TSpeedButton* UPB;
	Buttons::TSpeedButton* DownB;
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall ChartTreeClick(System::TObject* Sender);
	void __fastcall AddBClick(System::TObject* Sender);
	void __fastcall DeleteBClick(System::TObject* Sender);
	void __fastcall DoClick(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall UpDown1Click(System::TObject* Sender, Comctrls::TUDBtnType Button);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall DatasetsCBClick(System::TObject* Sender);
	void __fastcall DatabandsCBClick(System::TObject* Sender);
	void __fastcall DBSourceRBClick(System::TObject* Sender);
	void __fastcall OkBClick(System::TObject* Sender);
	void __fastcall EditBClick(System::TObject* Sender);
	void __fastcall ChartTreeEdited(System::TObject* Sender, Comctrls::TTreeNode* Node, System::UnicodeString &S);
	void __fastcall ChartTreeEditing(System::TObject* Sender, Comctrls::TTreeNode* Node, bool &AllowEdit);
	void __fastcall UPBClick(System::TObject* Sender);
	void __fastcall DownBClick(System::TObject* Sender);
	
private:
	Frxchart::TfrxChartView* FChart;
	Frxchart::TfrxSeriesItem* FCurSeries;
	Frxinsp::TfrxObjectInspector* FInspector;
	bool FModified;
	Frxclass::TfrxReport* FReport;
	bool FUpdating;
	int FValuesGBHeight;
	void __fastcall FillDropDownLists(Frxclass::TfrxDataSet* ds);
	void __fastcall SetCurSeries(const Frxchart::TfrxSeriesItem* Value);
	void __fastcall SetModified(const bool Value);
	void __fastcall ShowSeriesData(void);
	void __fastcall UpdateSeriesData(void);
	__property bool Modified = {read=FModified, write=SetModified, nodefault};
	__property Frxchart::TfrxSeriesItem* CurSeries = {read=FCurSeries, write=SetCurSeries};
	
public:
	__fastcall virtual TfrxChartEditorForm(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxChartEditorForm(void);
	__property Frxchart::TfrxChartView* Chart = {read=FChart, write=FChart};
public:
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxChartEditorForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxChartEditorForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxcharteditor */
using namespace Frxcharteditor;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxcharteditorHPP
