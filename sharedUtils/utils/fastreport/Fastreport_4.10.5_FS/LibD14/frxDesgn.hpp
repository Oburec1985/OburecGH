// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxdesgn.pas' rev: 21.00

#ifndef FrxdesgnHPP
#define FrxdesgnHPP

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
#include <Comctrls.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Toolwin.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Actnlist.hpp>	// Pascal unit
#include <Commctrl.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Frxdock.hpp>	// Pascal unit
#include <Frxctrls.hpp>	// Pascal unit
#include <Frxdesgnctrls.hpp>	// Pascal unit
#include <Frxdesgnworkspace.hpp>	// Pascal unit
#include <Frxinsp.hpp>	// Pascal unit
#include <Frxdialogform.hpp>	// Pascal unit
#include <Frxdatatree.hpp>	// Pascal unit
#include <Frxreporttree.hpp>	// Pascal unit
#include <Frxsynmemo.hpp>	// Pascal unit
#include <Fs_iinterpreter.hpp>	// Pascal unit
#include <Printers.hpp>	// Pascal unit
#include <Frxwatchform.hpp>	// Pascal unit
#include <Frxpicturecache.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Graphutil.hpp>	// Pascal unit
#include <Tabs.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxdesgn
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxDesignerUnits { duCM, duInches, duPixels, duChars };
#pragma option pop

typedef bool __fastcall (__closure *TfrxLoadReportEvent)(Frxclass::TfrxReport* Report);

typedef bool __fastcall (__closure *TfrxLoadRecentReportEvent)(Frxclass::TfrxReport* Report, System::UnicodeString FileName);

typedef bool __fastcall (__closure *TfrxSaveReportEvent)(Frxclass::TfrxReport* Report, bool SaveAs);

typedef void __fastcall (__closure *TfrxGetTemplateListEvent)(Classes::TStrings* List);

#pragma option push -b-
enum TfrxDesignerRestriction { drDontInsertObject, drDontDeletePage, drDontCreatePage, drDontChangePageOptions, drDontCreateReport, drDontLoadReport, drDontSaveReport, drDontPreviewReport, drDontEditVariables, drDontChangeReportOptions, drDontEditReportData, drDontShowRecentFiles, drDontEditReportScript, drDontEditInternalDatasets };
#pragma option pop

typedef Set<TfrxDesignerRestriction, drDontInsertObject, drDontEditInternalDatasets>  TfrxDesignerRestrictions;

class DELPHICLASS TfrxDesigner;
class PASCALIMPLEMENTATION TfrxDesigner : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	bool FCloseQuery;
	System::UnicodeString FDefaultScriptLanguage;
	Graphics::TFont* FDefaultFont;
	System::Extended FDefaultLeftMargin;
	System::Extended FDefaultBottomMargin;
	System::Extended FDefaultRightMargin;
	System::Extended FDefaultTopMargin;
	int FDefaultPaperSize;
	Printers::TPrinterOrientation FDefaultOrientation;
	bool FGradient;
	Graphics::TColor FGradientEnd;
	Graphics::TColor FGradientStart;
	System::UnicodeString FOpenDir;
	System::UnicodeString FSaveDir;
	System::UnicodeString FTemplatesExt;
	System::UnicodeString FTemplateDir;
	bool FStandalone;
	TfrxDesignerRestrictions FRestrictions;
	bool FRTLLanguage;
	bool FMemoParentFont;
	TfrxLoadReportEvent FOnLoadReport;
	TfrxLoadRecentReportEvent FOnLoadRecentReport;
	TfrxSaveReportEvent FOnSaveReport;
	Classes::TNotifyEvent FOnShow;
	Classes::TNotifyEvent FOnInsertObject;
	TfrxGetTemplateListEvent FOnGetTemplateList;
	Classes::TNotifyEvent FOnShowStartupScreen;
	void __fastcall SetDefaultFont(const Graphics::TFont* Value);
	
public:
	__fastcall virtual TfrxDesigner(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxDesigner(void);
	
__published:
	__property bool CloseQuery = {read=FCloseQuery, write=FCloseQuery, default=1};
	__property System::UnicodeString DefaultScriptLanguage = {read=FDefaultScriptLanguage, write=FDefaultScriptLanguage};
	__property Graphics::TFont* DefaultFont = {read=FDefaultFont, write=SetDefaultFont};
	__property System::Extended DefaultLeftMargin = {read=FDefaultLeftMargin, write=FDefaultLeftMargin};
	__property System::Extended DefaultRightMargin = {read=FDefaultRightMargin, write=FDefaultRightMargin};
	__property System::Extended DefaultTopMargin = {read=FDefaultTopMargin, write=FDefaultTopMargin};
	__property System::Extended DefaultBottomMargin = {read=FDefaultBottomMargin, write=FDefaultBottomMargin};
	__property int DefaultPaperSize = {read=FDefaultPaperSize, write=FDefaultPaperSize, nodefault};
	__property Printers::TPrinterOrientation DefaultOrientation = {read=FDefaultOrientation, write=FDefaultOrientation, nodefault};
	__property bool Gradient = {read=FGradient, write=FGradient, default=0};
	__property Graphics::TColor GradientEnd = {read=FGradientEnd, write=FGradientEnd, nodefault};
	__property Graphics::TColor GradientStart = {read=FGradientStart, write=FGradientStart, nodefault};
	__property System::UnicodeString OpenDir = {read=FOpenDir, write=FOpenDir};
	__property System::UnicodeString SaveDir = {read=FSaveDir, write=FSaveDir};
	__property System::UnicodeString TemplatesExt = {read=FTemplatesExt, write=FTemplatesExt};
	__property System::UnicodeString TemplateDir = {read=FTemplateDir, write=FTemplateDir};
	__property bool Standalone = {read=FStandalone, write=FStandalone, default=0};
	__property TfrxDesignerRestrictions Restrictions = {read=FRestrictions, write=FRestrictions, nodefault};
	__property bool RTLLanguage = {read=FRTLLanguage, write=FRTLLanguage, nodefault};
	__property bool MemoParentFont = {read=FMemoParentFont, write=FMemoParentFont, nodefault};
	__property TfrxLoadReportEvent OnLoadReport = {read=FOnLoadReport, write=FOnLoadReport};
	__property TfrxLoadRecentReportEvent OnLoadRecentReport = {read=FOnLoadRecentReport, write=FOnLoadRecentReport};
	__property TfrxSaveReportEvent OnSaveReport = {read=FOnSaveReport, write=FOnSaveReport};
	__property Classes::TNotifyEvent OnShow = {read=FOnShow, write=FOnShow};
	__property Classes::TNotifyEvent OnInsertObject = {read=FOnInsertObject, write=FOnInsertObject};
	__property Classes::TNotifyEvent OnShowStartupScreen = {read=FOnShowStartupScreen, write=FOnShowStartupScreen};
	__property TfrxGetTemplateListEvent OnGetTemplateList = {read=FOnGetTemplateList, write=FOnGetTemplateList};
};


class DELPHICLASS TfrxDesignerForm;
class DELPHICLASS TSampleFormat;
class PASCALIMPLEMENTATION TfrxDesignerForm : public Frxclass::TfrxCustomDesigner
{
	typedef Frxclass::TfrxCustomDesigner inherited;
	
__published:
	Extctrls::TBevel* Bevel1;
	Comctrls::TStatusBar* StatusBar;
	Extctrls::TControlBar* DockBottom;
	Extctrls::TControlBar* DockTop;
	Comctrls::TToolBar* TextTB;
	Frxdock::TfrxTBPanel* PanelTB1;
	Frxctrls::TfrxComboBox* FontSizeCB;
	Frxctrls::TfrxFontComboBox* FontNameCB;
	Comctrls::TToolButton* BoldB;
	Comctrls::TToolButton* ItalicB;
	Comctrls::TToolButton* UnderlineB;
	Comctrls::TToolButton* SepTB8;
	Comctrls::TToolButton* FontColorB;
	Comctrls::TToolButton* HighlightB;
	Comctrls::TToolButton* SepTB9;
	Comctrls::TToolButton* TextAlignLeftB;
	Comctrls::TToolButton* TextAlignCenterB;
	Comctrls::TToolButton* TextAlignRightB;
	Comctrls::TToolButton* TextAlignBlockB;
	Comctrls::TToolButton* SepTB10;
	Comctrls::TToolButton* TextAlignTopB;
	Comctrls::TToolButton* TextAlignMiddleB;
	Comctrls::TToolButton* TextAlignBottomB;
	Comctrls::TToolBar* FrameTB;
	Comctrls::TToolButton* FrameTopB;
	Comctrls::TToolButton* FrameBottomB;
	Comctrls::TToolButton* FrameLeftB;
	Comctrls::TToolButton* FrameRightB;
	Comctrls::TToolButton* SepTB11;
	Comctrls::TToolButton* FrameAllB;
	Comctrls::TToolButton* FrameNoB;
	Comctrls::TToolButton* SepTB12;
	Comctrls::TToolButton* FillColorB;
	Comctrls::TToolButton* FrameColorB;
	Comctrls::TToolButton* FrameStyleB;
	Frxdock::TfrxTBPanel* PanelTB2;
	Frxctrls::TfrxComboBox* FrameWidthCB;
	Comctrls::TToolBar* StandardTB;
	Comctrls::TToolButton* NewB;
	Comctrls::TToolButton* OpenB;
	Comctrls::TToolButton* SaveB;
	Comctrls::TToolButton* PreviewB;
	Comctrls::TToolButton* SepTB1;
	Comctrls::TToolButton* CutB;
	Comctrls::TToolButton* CopyB;
	Comctrls::TToolButton* PasteB;
	Comctrls::TToolButton* SepTB2;
	Comctrls::TToolButton* UndoB;
	Comctrls::TToolButton* RedoB;
	Comctrls::TToolButton* SepTB3;
	Comctrls::TToolButton* SepTB4;
	Comctrls::TToolButton* NewPageB;
	Comctrls::TToolButton* NewDialogB;
	Comctrls::TToolButton* DeletePageB;
	Comctrls::TToolButton* PageSettingsB;
	Comctrls::TToolButton* ShowGridB;
	Comctrls::TToolButton* AlignToGridB;
	Comctrls::TToolBar* ExtraToolsTB;
	Menus::TPopupMenu* PagePopup;
	Menus::TMenuItem* CutMI1;
	Menus::TMenuItem* CopyMI1;
	Menus::TMenuItem* PasteMI1;
	Menus::TMenuItem* DeleteMI1;
	Menus::TMenuItem* SelectAllMI1;
	Menus::TMenuItem* SepMI8;
	Menus::TMenuItem* EditMI1;
	Menus::TMainMenu* MainMenu;
	Menus::TMenuItem* FileMenu;
	Menus::TMenuItem* EditMenu;
	Menus::TMenuItem* ViewMenu;
	Menus::TMenuItem* ToolbarsMI;
	Menus::TMenuItem* StandardMI;
	Menus::TMenuItem* TextMI;
	Menus::TMenuItem* FrameMI;
	Menus::TMenuItem* AlignmentMI;
	Menus::TMenuItem* ToolsMI;
	Menus::TMenuItem* InspectorMI;
	Menus::TMenuItem* DataTreeMI;
	Menus::TMenuItem* OptionsMI;
	Menus::TMenuItem* HelpMenu;
	Menus::TMenuItem* HelpContentsMI;
	Menus::TMenuItem* SepMI7;
	Menus::TMenuItem* AboutMI;
	Dialogs::TOpenDialog* OpenDialog;
	Dialogs::TSaveDialog* SaveDialog;
	Menus::TPopupMenu* TabPopup;
	Menus::TMenuItem* NewPageMI1;
	Menus::TMenuItem* NewDialogMI1;
	Menus::TMenuItem* DeletePageMI1;
	Menus::TMenuItem* PageSettingsMI1;
	Actnlist::TActionList* ActionList;
	Actnlist::TAction* ExitCmd;
	Actnlist::TAction* CutCmd;
	Actnlist::TAction* CopyCmd;
	Actnlist::TAction* PasteCmd;
	Actnlist::TAction* UndoCmd;
	Actnlist::TAction* RedoCmd;
	Actnlist::TAction* DeleteCmd;
	Actnlist::TAction* SelectAllCmd;
	Actnlist::TAction* EditCmd;
	Actnlist::TAction* BringToFrontCmd;
	Actnlist::TAction* SendToBackCmd;
	Actnlist::TAction* DeletePageCmd;
	Actnlist::TAction* NewItemCmd;
	Actnlist::TAction* NewPageCmd;
	Actnlist::TAction* NewDialogCmd;
	Actnlist::TAction* NewReportCmd;
	Actnlist::TAction* OpenCmd;
	Actnlist::TAction* SaveCmd;
	Actnlist::TAction* SaveAsCmd;
	Actnlist::TAction* VariablesCmd;
	Actnlist::TAction* PageSettingsCmd;
	Actnlist::TAction* PreviewCmd;
	Menus::TMenuItem* NewMI;
	Menus::TMenuItem* NewReportMI;
	Menus::TMenuItem* NewPageMI;
	Menus::TMenuItem* NewDialogMI;
	Menus::TMenuItem* SepMI1;
	Menus::TMenuItem* OpenMI;
	Menus::TMenuItem* SaveMI;
	Menus::TMenuItem* SaveAsMI;
	Menus::TMenuItem* VariablesMI;
	Menus::TMenuItem* SepMI3;
	Menus::TMenuItem* PreviewMI;
	Menus::TMenuItem* SepMI4;
	Menus::TMenuItem* ExitMI;
	Menus::TMenuItem* UndoMI;
	Menus::TMenuItem* RedoMI;
	Menus::TMenuItem* SepMI5;
	Menus::TMenuItem* CutMI;
	Menus::TMenuItem* CopyMI;
	Menus::TMenuItem* PasteMI;
	Menus::TMenuItem* DeleteMI;
	Menus::TMenuItem* DeletePageMI;
	Menus::TMenuItem* SelectAllMI;
	Menus::TMenuItem* SepMI6;
	Menus::TMenuItem* BringtoFrontMI;
	Menus::TMenuItem* SendtoBackMI;
	Menus::TMenuItem* EditMI;
	Frxdock::TfrxTBPanel* PanelTB3;
	Frxctrls::TfrxComboBox* ScaleCB;
	Comctrls::TToolBar* ObjectsTB1;
	Menus::TPopupMenu* BandsPopup;
	Menus::TMenuItem* ReportTitleMI;
	Menus::TMenuItem* ReportSummaryMI;
	Menus::TMenuItem* PageHeaderMI;
	Menus::TMenuItem* PageFooterMI;
	Menus::TMenuItem* HeaderMI;
	Menus::TMenuItem* FooterMI;
	Menus::TMenuItem* MasterDataMI;
	Menus::TMenuItem* DetailDataMI;
	Menus::TMenuItem* SubdetailDataMI;
	Menus::TMenuItem* GroupHeaderMI;
	Menus::TMenuItem* GroupFooterMI;
	Menus::TMenuItem* ColumnHeaderMI;
	Menus::TMenuItem* ColumnFooterMI;
	Menus::TMenuItem* ChildMI;
	Frxdock::TfrxDockSite* LeftDockSite1;
	Comctrls::TToolButton* VariablesB;
	Comctrls::TToolButton* SepTB13;
	Menus::TMenuItem* PageSettingsMI;
	Extctrls::TTimer* Timer;
	Menus::TMenuItem* ReportSettingsMI;
	Menus::TMenuItem* Data4levelMI;
	Menus::TMenuItem* Data5levelMI;
	Menus::TMenuItem* Data6levelMI;
	Menus::TMenuItem* SepMI10;
	Menus::TMenuItem* SepMI9;
	Menus::TMenuItem* ShowGuidesMI;
	Menus::TMenuItem* ShowRulersMI;
	Menus::TMenuItem* DeleteGuidesMI;
	Menus::TMenuItem* SepMI11;
	Menus::TMenuItem* N1;
	Menus::TMenuItem* BringtoFrontMI1;
	Menus::TMenuItem* SendtoBackMI1;
	Menus::TMenuItem* SepMI12;
	Comctrls::TToolButton* RotateB;
	Menus::TPopupMenu* RotationPopup;
	Menus::TMenuItem* R0MI;
	Menus::TMenuItem* R45MI;
	Menus::TMenuItem* R90MI;
	Menus::TMenuItem* R180MI;
	Menus::TMenuItem* R270MI;
	Comctrls::TToolButton* SetToGridB;
	Comctrls::TToolButton* ShadowB;
	Menus::TMenuItem* ReportMenu;
	Menus::TMenuItem* ReportDataMI;
	Dialogs::TOpenDialog* OpenScriptDialog;
	Dialogs::TSaveDialog* SaveScriptDialog;
	Menus::TMenuItem* ReportTreeMI;
	Menus::TPopupMenu* ObjectsPopup;
	Comctrls::TToolBar* AlignTB;
	Comctrls::TToolButton* AlignLeftsB;
	Comctrls::TToolButton* AlignHorzCentersB;
	Comctrls::TToolButton* AlignRightsB;
	Comctrls::TToolButton* AlignTopsB;
	Comctrls::TToolButton* AlignVertCentersB;
	Comctrls::TToolButton* AlignBottomsB;
	Comctrls::TToolButton* SpaceHorzB;
	Comctrls::TToolButton* SpaceVertB;
	Comctrls::TToolButton* CenterHorzB;
	Comctrls::TToolButton* CenterVertB;
	Comctrls::TToolButton* SameWidthB;
	Comctrls::TToolButton* SameHeightB;
	Comctrls::TToolButton* SepTB15;
	Comctrls::TToolButton* SepTB16;
	Comctrls::TToolButton* SepTB18;
	Comctrls::TToolButton* SepTB17;
	Menus::TMenuItem* OverlayMI;
	Frxctrls::TfrxComboBox* StyleCB;
	Menus::TMenuItem* ReportStylesMI;
	Menus::TMenuItem* TabOrderMI;
	Menus::TMenuItem* N2;
	Menus::TMenuItem* FindMI;
	Menus::TMenuItem* FindNextMI;
	Menus::TMenuItem* ReplaceMI;
	Menus::TPopupMenu* DMPPopup;
	Menus::TMenuItem* BoldMI;
	Menus::TMenuItem* ItalicMI;
	Menus::TMenuItem* UnderlineMI;
	Menus::TMenuItem* SuperScriptMI;
	Menus::TMenuItem* SubScriptMI;
	Menus::TMenuItem* CondensedMI;
	Menus::TMenuItem* WideMI;
	Menus::TMenuItem* N12cpiMI;
	Menus::TMenuItem* N15cpiMI;
	Comctrls::TToolButton* FontB;
	Menus::TMenuItem* VerticalbandsMI;
	Menus::TMenuItem* HeaderMI1;
	Menus::TMenuItem* FooterMI1;
	Menus::TMenuItem* MasterDataMI1;
	Menus::TMenuItem* DetailDataMI1;
	Menus::TMenuItem* SubdetailDataMI1;
	Menus::TMenuItem* GroupHeaderMI1;
	Menus::TMenuItem* GroupFooterMI1;
	Menus::TMenuItem* ChildMI1;
	Menus::TMenuItem* N3;
	Comctrls::TToolButton* GroupB;
	Comctrls::TToolButton* UngroupB;
	Comctrls::TToolButton* SepTB20;
	Actnlist::TAction* GroupCmd;
	Actnlist::TAction* UngroupCmd;
	Menus::TMenuItem* GroupMI;
	Menus::TMenuItem* UngroupMI;
	Menus::TMenuItem* ConnectionsMI;
	Extctrls::TPanel* BackPanel;
	Extctrls::TPanel* ScrollBoxPanel;
	Frxdesgnctrls::TfrxScrollBox* ScrollBox;
	Frxdesgnctrls::TfrxRuler* LeftRuler;
	Frxdesgnctrls::TfrxRuler* TopRuler;
	Extctrls::TPanel* CodePanel;
	Comctrls::TToolBar* CodeTB;
	Frxdock::TfrxTBPanel* frTBPanel1;
	Stdctrls::TLabel* LangL;
	Frxctrls::TfrxComboBox* LangCB;
	Comctrls::TToolButton* OpenScriptB;
	Comctrls::TToolButton* SaveScriptB;
	Comctrls::TToolButton* SepTB19;
	Comctrls::TToolButton* RunScriptB;
	Comctrls::TToolButton* RunToCursorB;
	Comctrls::TToolButton* StepScriptB;
	Comctrls::TToolButton* StopScriptB;
	Comctrls::TToolButton* EvaluateB;
	Comctrls::TToolButton* BreakPointB;
	Frxdock::TfrxDockSite* CodeDockSite;
	Frxdock::TfrxDockSite* LeftDockSite2;
	Frxdock::TfrxDockSite* RightDockSite;
	Extctrls::TPanel* TabPanel;
	Extctrls::TPanel* Panel1;
	Menus::TMenuItem* AddChildMI;
	Actnlist::TAction* FindCmd;
	Actnlist::TAction* ReplaceCmd;
	Actnlist::TAction* FindNextCmd;
	Actnlist::TAction* ReportDataCmd;
	Actnlist::TAction* ReportStylesCmd;
	Actnlist::TAction* ReportOptionsCmd;
	Actnlist::TAction* ShowRulersCmd;
	Actnlist::TAction* ShowGuidesCmd;
	Actnlist::TAction* DeleteGuidesCmd;
	Actnlist::TAction* OptionsCmd;
	Actnlist::TAction* HelpContentsCmd;
	Actnlist::TAction* AboutCmd;
	Actnlist::TAction* StandardTBCmd;
	Actnlist::TAction* TextTBCmd;
	Actnlist::TAction* FrameTBCmd;
	Actnlist::TAction* AlignTBCmd;
	Actnlist::TAction* ExtraTBCmd;
	Actnlist::TAction* InspectorTBCmd;
	Actnlist::TAction* DataTreeTBCmd;
	Actnlist::TAction* ReportTreeTBCmd;
	Actnlist::TAction* ToolbarsCmd;
	void __fastcall ExitCmdExecute(System::TObject* Sender);
	void __fastcall ObjectsButtonClick(System::TObject* Sender);
	void __fastcall StatusBarDrawPanel(Comctrls::TStatusBar* StatusBar, Comctrls::TStatusPanel* Panel, const Types::TRect &ARect);
	void __fastcall ScrollBoxMouseWheelUp(System::TObject* Sender, Classes::TShiftState Shift, const Types::TPoint &MousePos, bool &Handled);
	void __fastcall ScrollBoxMouseWheelDown(System::TObject* Sender, Classes::TShiftState Shift, const Types::TPoint &MousePos, bool &Handled);
	void __fastcall ScrollBoxResize(System::TObject* Sender);
	void __fastcall ScaleCBClick(System::TObject* Sender);
	void __fastcall ShowGridBClick(System::TObject* Sender);
	void __fastcall AlignToGridBClick(System::TObject* Sender);
	void __fastcall StatusBarDblClick(System::TObject* Sender);
	void __fastcall StatusBarMouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall InsertBandClick(System::TObject* Sender);
	void __fastcall BandsPopupPopup(System::TObject* Sender);
	void __fastcall FormClose(System::TObject* Sender, Forms::TCloseAction &Action);
	void __fastcall NewReportCmdExecute(System::TObject* Sender);
	void __fastcall ToolButtonClick(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall FontColorBClick(System::TObject* Sender);
	void __fastcall FrameStyleBClick(System::TObject* Sender);
	void __fastcall TabChange(System::TObject* Sender);
	void __fastcall UndoCmdExecute(System::TObject* Sender);
	void __fastcall RedoCmdExecute(System::TObject* Sender);
	void __fastcall CutCmdExecute(System::TObject* Sender);
	void __fastcall CopyCmdExecute(System::TObject* Sender);
	void __fastcall PasteCmdExecute(System::TObject* Sender);
	void __fastcall TimerTimer(System::TObject* Sender);
	void __fastcall DeletePageCmdExecute(System::TObject* Sender);
	void __fastcall NewDialogCmdExecute(System::TObject* Sender);
	void __fastcall NewPageCmdExecute(System::TObject* Sender);
	void __fastcall SaveCmdExecute(System::TObject* Sender);
	void __fastcall SaveAsCmdExecute(System::TObject* Sender);
	void __fastcall OpenCmdExecute(System::TObject* Sender);
	void __fastcall FormCloseQuery(System::TObject* Sender, bool &CanClose);
	void __fastcall DeleteCmdExecute(System::TObject* Sender);
	void __fastcall SelectAllCmdExecute(System::TObject* Sender);
	void __fastcall EditCmdExecute(System::TObject* Sender);
	void __fastcall TabChanging(System::TObject* Sender, bool &AllowChange);
	void __fastcall PageSettingsCmdExecute(System::TObject* Sender);
	void __fastcall TopRulerDragOver(System::TObject* Sender, System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	void __fastcall AlignLeftsBClick(System::TObject* Sender);
	void __fastcall AlignRightsBClick(System::TObject* Sender);
	void __fastcall AlignTopsBClick(System::TObject* Sender);
	void __fastcall AlignBottomsBClick(System::TObject* Sender);
	void __fastcall AlignHorzCentersBClick(System::TObject* Sender);
	void __fastcall AlignVertCentersBClick(System::TObject* Sender);
	void __fastcall CenterHorzBClick(System::TObject* Sender);
	void __fastcall CenterVertBClick(System::TObject* Sender);
	void __fastcall SpaceHorzBClick(System::TObject* Sender);
	void __fastcall SpaceVertBClick(System::TObject* Sender);
	void __fastcall SelectToolBClick(System::TObject* Sender);
	void __fastcall PagePopupPopup(System::TObject* Sender);
	void __fastcall BringToFrontCmdExecute(System::TObject* Sender);
	void __fastcall SendToBackCmdExecute(System::TObject* Sender);
	void __fastcall LangCBClick(System::TObject* Sender);
	void __fastcall OpenScriptBClick(System::TObject* Sender);
	void __fastcall SaveScriptBClick(System::TObject* Sender);
	void __fastcall CodeWindowDragOver(System::TObject* Sender, System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	void __fastcall CodeWindowDragDrop(System::TObject* Sender, System::TObject* Source, int X, int Y);
	void __fastcall VariablesCmdExecute(System::TObject* Sender);
	void __fastcall ObjectBandBClick(System::TObject* Sender);
	void __fastcall PreviewCmdExecute(System::TObject* Sender);
	void __fastcall HighlightBClick(System::TObject* Sender);
	void __fastcall TabMouseDown(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall TabMouseMove(System::TObject* Sender, Classes::TShiftState Shift, int X, int Y);
	void __fastcall TabMouseUp(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall TabDragDrop(System::TObject* Sender, System::TObject* Source, int X, int Y);
	void __fastcall TabDragOver(System::TObject* Sender, System::TObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	void __fastcall SameWidthBClick(System::TObject* Sender);
	void __fastcall SameHeightBClick(System::TObject* Sender);
	void __fastcall NewItemCmdExecute(System::TObject* Sender);
	void __fastcall TabOrderMIClick(System::TObject* Sender);
	void __fastcall RunScriptBClick(System::TObject* Sender);
	void __fastcall StopScriptBClick(System::TObject* Sender);
	void __fastcall EvaluateBClick(System::TObject* Sender);
	void __fastcall GroupCmdExecute(System::TObject* Sender);
	void __fastcall UngroupCmdExecute(System::TObject* Sender);
	void __fastcall ConnectionsMIClick(System::TObject* Sender);
	void __fastcall LangSelectClick(System::TObject* Sender);
	void __fastcall BreakPointBClick(System::TObject* Sender);
	void __fastcall RunToCursorBClick(System::TObject* Sender);
	void __fastcall CodeDockSiteDockOver(System::TObject* Sender, Controls::TDragDockObject* Source, int X, int Y, Controls::TDragState State, bool &Accept);
	void __fastcall TabSetChange(System::TObject* Sender, int NewTab, bool &AllowChange);
	void __fastcall FormShow(System::TObject* Sender);
	void __fastcall AddChildMIClick(System::TObject* Sender);
	void __fastcall FindCmdExecute(System::TObject* Sender);
	void __fastcall ReplaceCmdExecute(System::TObject* Sender);
	void __fastcall FindNextCmdExecute(System::TObject* Sender);
	void __fastcall ReportDataCmdExecute(System::TObject* Sender);
	void __fastcall ReportStylesCmdExecute(System::TObject* Sender);
	void __fastcall ReportOptionsCmdExecute(System::TObject* Sender);
	void __fastcall ShowRulersCmdExecute(System::TObject* Sender);
	void __fastcall ShowGuidesCmdExecute(System::TObject* Sender);
	void __fastcall DeleteGuidesCmdExecute(System::TObject* Sender);
	void __fastcall OptionsCmdExecute(System::TObject* Sender);
	void __fastcall HelpContentsCmdExecute(System::TObject* Sender);
	void __fastcall AboutCmdExecute(System::TObject* Sender);
	void __fastcall StandardTBCmdExecute(System::TObject* Sender);
	void __fastcall TextTBCmdExecute(System::TObject* Sender);
	void __fastcall FrameTBCmdExecute(System::TObject* Sender);
	void __fastcall AlignTBCmdExecute(System::TObject* Sender);
	void __fastcall ExtraTBCmdExecute(System::TObject* Sender);
	void __fastcall InspectorTBCmdExecute(System::TObject* Sender);
	void __fastcall DataTreeTBCmdExecute(System::TObject* Sender);
	void __fastcall ReportTreeTBCmdExecute(System::TObject* Sender);
	void __fastcall ToolbarsCmdExecute(System::TObject* Sender);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall FormMouseWheel(System::TObject* Sender, Classes::TShiftState Shift, int WheelDelta, const Types::TPoint &MousePos, bool &Handled);
	
private:
	Comctrls::TToolButton* ObjectSelectB;
	Comctrls::TToolButton* HandToolB;
	Comctrls::TToolButton* ZoomToolB;
	Comctrls::TToolButton* TextToolB;
	Comctrls::TToolButton* FormatToolB;
	Comctrls::TToolButton* ObjectBandB;
	Frxdesgnctrls::TfrxClipboard* FClipboard;
	Frxsynmemo::TfrxSyntaxMemo* FCodeWindow;
	Graphics::TColor FColor;
	System::UnicodeString FCoord1;
	System::UnicodeString FCoord2;
	System::UnicodeString FCoord3;
	Frxdialogform::TfrxDialogForm* FDialogForm;
	bool FEditAfterInsert;
	Frxdatatree::TfrxDataTreeForm* FDataTree;
	bool FDropFields;
	bool FGridAlign;
	System::Extended FGridSize1;
	System::Extended FGridSize2;
	System::Extended FGridSize3;
	System::Extended FGridSize4;
	Frxinsp::TfrxObjectInspector* FInspector;
	Frxclass::TfrxFrameStyle FLineStyle;
	bool FLocalizedOI;
	bool FLockSelectionChanged;
	System::TObject* FModifiedBy;
	bool FMouseDown;
	TfrxDesigner* FOldDesignerComp;
	TfrxDesignerUnits FOldUnits;
	Classes::TStrings* FPagePositions;
	Frxpicturecache::TfrxPictureCache* FPictureCache;
	Classes::TStringList* FRecentFiles;
	int FRecentMenuIndex;
	Frxreporttree::TfrxReportTreeForm* FReportTree;
	TSampleFormat* FSampleFormat;
	System::Extended FScale;
	bool FScriptFirstTime;
	bool FScriptRunning;
	bool FScriptStep;
	bool FScriptStopped;
	bool FSearchCase;
	int FSearchIndex;
	bool FSearchReplace;
	System::UnicodeString FSearchReplaceText;
	System::UnicodeString FSearchText;
	bool FShowGrid;
	bool FShowGuides;
	bool FShowRulers;
	bool FShowStartup;
	Tabs::TTabSet* FTabs;
	Graphics::TColor FToolsColor;
	Frxdesgnctrls::TfrxUndoBuffer* FUndoBuffer;
	TfrxDesignerUnits FUnits;
	bool FUnitsDblClicked;
	bool FUpdatingControls;
	Frxwatchform::TfrxWatchForm* FWatchList;
	Frxdesgnworkspace::TfrxDesignerWorkspace* FWorkspace;
	Graphics::TColor FWorkspaceColor;
	Classes::TWndMethod FStatusBarOldWindowProc;
	System::UnicodeString FTemplatePath;
	System::UnicodeString FTemplateExt;
	void __fastcall AttachDialogFormEvents(bool Attach);
	void __fastcall CreateColorSelector(Comctrls::TToolButton* Sender);
	void __fastcall CreateExtraToolbar(void);
	void __fastcall CreateToolWindows(void);
	void __fastcall CreateObjectsToolbar(void);
	void __fastcall CreateWorkspace(void);
	void __fastcall DialogFormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall DialogFormKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall DialogFormKeyUp(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall DialogFormModify(System::TObject* Sender);
	void __fastcall Done(void);
	void __fastcall DoTopmosts(bool Enable);
	void __fastcall FindOrReplace(bool replace);
	void __fastcall FindText(void);
	void __fastcall Init(void);
	void __fastcall NormalizeTopmosts(void);
	void __fastcall OnCodeChanged(System::TObject* Sender);
	void __fastcall OnCodeCompletion(const System::UnicodeString Name, Classes::TStrings* List);
	void __fastcall OnColorChanged(System::TObject* Sender);
	void __fastcall OnComponentMenuClick(System::TObject* Sender);
	void __fastcall OnChangePosition(System::TObject* Sender);
	void __fastcall OnDataTreeDblClick(System::TObject* Sender);
	void __fastcall OnDisableDock(System::TObject* Sender, Controls::TDragDockObject* &DragObject);
	void __fastcall OnEditObject(System::TObject* Sender);
	void __fastcall OnEnableDock(System::TObject* Sender, System::TObject* Target, int X, int Y);
	void __fastcall OnExtraToolClick(System::TObject* Sender);
	void __fastcall OnInsertObject(System::TObject* Sender);
	void __fastcall OnModify(System::TObject* Sender);
	void __fastcall OnNotifyPosition(const Frxclass::TfrxRect &ARect);
	void __fastcall OnRunLine(Fs_iinterpreter::TfsScript* Sender, const System::UnicodeString UnitName, const System::UnicodeString SourcePos);
	void __fastcall OnSelectionChanged(System::TObject* Sender);
	void __fastcall OnStyleChanged(System::TObject* Sender);
	void __fastcall OpenRecentFile(System::TObject* Sender);
	void __fastcall ReadButtonImages(void);
	void __fastcall ReloadObjects(void);
	void __fastcall RestorePagePosition(void);
	void __fastcall RestoreTopmosts(void);
	void __fastcall SavePagePosition(void);
	void __fastcall SaveState(void);
	void __fastcall SetScale(System::Extended Value);
	void __fastcall SetGridAlign(const bool Value);
	void __fastcall SetShowGrid(const bool Value);
	void __fastcall SetShowRulers(const bool Value);
	void __fastcall SetToolsColor(const Graphics::TColor Value);
	void __fastcall SetUnits(const TfrxDesignerUnits Value);
	void __fastcall SetWorkspaceColor(const Graphics::TColor Value);
	void __fastcall SwitchToolbar(void);
	void __fastcall UpdateCaption(void);
	void __fastcall UpdateControls(void);
	void __fastcall UpdatePageDimensions(void);
	void __fastcall UpdateRecentFiles(System::UnicodeString NewFile);
	void __fastcall UpdateStyles(void);
	void __fastcall UpdateSyntaxType(void);
	void __fastcall UpdateWatches(void);
	System::Word __fastcall AskSave(void);
	int __fastcall GetPageIndex(void);
	System::UnicodeString __fastcall GetReportName(void);
	void __fastcall SetShowGuides(const bool Value);
	void __fastcall Localize(void);
	void __fastcall CreateLangMenu(void);
	MESSAGE void __fastcall CMStartup(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall WMSysCommand(Messages::TWMSysCommand &Message);
	MESSAGE void __fastcall WMEnable(Messages::TMessage &Message);
	MESSAGE void __fastcall WMActivateApp(Messages::TWMActivateApp &Message);
	void __fastcall StatusBarWndProc(Messages::TMessage &Message);
	HIDESBASE MESSAGE void __fastcall CMDialogKey(Messages::TWMKey &Message);
	void __fastcall SetGridSize1(const System::Extended Value);
	void __fastcall SetGridSize2(const System::Extended Value);
	void __fastcall SetGridSize3(const System::Extended Value);
	void __fastcall SetGridSize4(const System::Extended Value);
	
protected:
	virtual void __fastcall SetModified(const bool Value);
	virtual void __fastcall SetPage(const Frxclass::TfrxPage* Value);
	virtual Classes::TStrings* __fastcall GetCode(void);
	
public:
	bool __fastcall CheckOp(TfrxDesignerRestriction Op);
	virtual System::UnicodeString __fastcall InsertExpression(const System::UnicodeString Expr);
	void __fastcall LoadFile(System::UnicodeString FileName, bool UseOnLoadEvent);
	virtual void __fastcall Lock(void);
	virtual void __fastcall ReloadPages(int Index);
	virtual void __fastcall ReloadReport(void);
	void __fastcall RestoreState(bool RestoreDefault = false, bool RestoreMainForm = false);
	bool __fastcall SaveFile(bool SaveAs, bool UseOnSaveEvent);
	void __fastcall SetReportDefaults(void);
	void __fastcall SwitchToCodeWindow(void);
	virtual void __fastcall UpdateDataTree(void);
	virtual void __fastcall UpdatePage(void);
	Frxclass::TfrxPoint __fastcall GetDefaultObjectSize(void);
	System::Extended __fastcall mmToUnits(System::Extended mm, bool X = true);
	System::Extended __fastcall UnitsTomm(System::Extended mm, bool X = true);
	void __fastcall GetTemplateList(Classes::TStrings* List);
	__property Frxsynmemo::TfrxSyntaxMemo* CodeWindow = {read=FCodeWindow};
	__property Frxdatatree::TfrxDataTreeForm* DataTree = {read=FDataTree};
	__property bool DropFields = {read=FDropFields, write=FDropFields, nodefault};
	__property bool EditAfterInsert = {read=FEditAfterInsert, write=FEditAfterInsert, nodefault};
	__property bool GridAlign = {read=FGridAlign, write=SetGridAlign, nodefault};
	__property System::Extended GridSize1 = {read=FGridSize1, write=SetGridSize1};
	__property System::Extended GridSize2 = {read=FGridSize2, write=SetGridSize2};
	__property System::Extended GridSize3 = {read=FGridSize3, write=SetGridSize3};
	__property System::Extended GridSize4 = {read=FGridSize4, write=SetGridSize4};
	__property Frxinsp::TfrxObjectInspector* Inspector = {read=FInspector};
	__property Frxpicturecache::TfrxPictureCache* PictureCache = {read=FPictureCache};
	__property Classes::TStringList* RecentFiles = {read=FRecentFiles};
	__property Frxreporttree::TfrxReportTreeForm* ReportTree = {read=FReportTree};
	__property TSampleFormat* SampleFormat = {read=FSampleFormat};
	__property System::Extended Scale = {read=FScale, write=SetScale};
	__property bool ShowGrid = {read=FShowGrid, write=SetShowGrid, nodefault};
	__property bool ShowGuides = {read=FShowGuides, write=SetShowGuides, nodefault};
	__property bool ShowRulers = {read=FShowRulers, write=SetShowRulers, nodefault};
	__property bool ShowStartup = {read=FShowStartup, write=FShowStartup, nodefault};
	__property Graphics::TColor ToolsColor = {read=FToolsColor, write=SetToolsColor, nodefault};
	__property TfrxDesignerUnits Units = {read=FUnits, write=SetUnits, nodefault};
	__property Frxdesgnworkspace::TfrxDesignerWorkspace* Workspace = {read=FWorkspace};
	__property Graphics::TColor WorkspaceColor = {read=FWorkspaceColor, write=SetWorkspaceColor, nodefault};
	__property System::UnicodeString TemplatePath = {read=FTemplatePath, write=FTemplatePath};
public:
	/* TfrxCustomDesigner.CreateDesigner */ inline __fastcall TfrxDesignerForm(Classes::TComponent* AOwner, Frxclass::TfrxReport* AReport, bool APreviewDesigner) : Frxclass::TfrxCustomDesigner(AOwner, AReport, APreviewDesigner) { }
	/* TfrxCustomDesigner.Destroy */ inline __fastcall virtual ~TfrxDesignerForm(void) { }
	
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxDesignerForm(Classes::TComponent* AOwner) : Frxclass::TfrxCustomDesigner(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxDesignerForm(Classes::TComponent* AOwner, int Dummy) : Frxclass::TfrxCustomDesigner(AOwner, Dummy) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxDesignerForm(HWND ParentWindow) : Frxclass::TfrxCustomDesigner(ParentWindow) { }
	
};


class PASCALIMPLEMENTATION TSampleFormat : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Frxclass::TfrxCustomMemoView* FMemo;
	void __fastcall Clear(void);
	
public:
	__fastcall TSampleFormat(void);
	__fastcall virtual ~TSampleFormat(void);
	void __fastcall ApplySample(Frxclass::TfrxCustomMemoView* Memo);
	void __fastcall SetAsSample(Frxclass::TfrxCustomMemoView* Memo);
	__property Frxclass::TfrxCustomMemoView* Memo = {read=FMemo};
};


class DELPHICLASS TfrxCustomSavePlugin;
class PASCALIMPLEMENTATION TfrxCustomSavePlugin : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	System::UnicodeString FileFilter;
	virtual void __fastcall Save(Frxclass::TfrxReport* Report, const System::UnicodeString FileName) = 0 ;
public:
	/* TObject.Create */ inline __fastcall TfrxCustomSavePlugin(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxCustomSavePlugin(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxDesigner* frxDesignerComp;
extern PACKAGE TfrxCustomSavePlugin* frxSavePlugin;

}	/* namespace Frxdesgn */
using namespace Frxdesgn;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxdesgnHPP
