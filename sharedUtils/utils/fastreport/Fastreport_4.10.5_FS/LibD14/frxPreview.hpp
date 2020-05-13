// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxpreview.pas' rev: 21.00

#ifndef FrxpreviewHPP
#define FrxpreviewHPP

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
#include <Extctrls.hpp>	// Pascal unit
#include <Buttons.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Imglist.hpp>	// Pascal unit
#include <Frxctrls.hpp>	// Pascal unit
#include <Frxdock.hpp>	// Pascal unit
#include <Toolwin.hpp>	// Pascal unit
#include <Frxpreviewpages.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxpreview
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxPreviewTool { ptHand, ptZoom };
#pragma option pop

class DELPHICLASS TfrxPreview;
typedef void __fastcall (__closure *TfrxPageChangedEvent)(TfrxPreview* Sender, int PageNo);

class DELPHICLASS TfrxPreviewWorkspace;
class PASCALIMPLEMENTATION TfrxPreview : public Frxclass::TfrxCustomPreview
{
	typedef Frxclass::TfrxCustomPreview inherited;
	
private:
	bool FAllowF3;
	Forms::TFormBorderStyle FBorderStyle;
	Stdctrls::TButton* FCancelButton;
	bool FLocked;
	Stdctrls::TLabel* FMessageLabel;
	Extctrls::TPanel* FMessagePanel;
	TfrxPageChangedEvent FOnPageChanged;
	Comctrls::TTreeView* FOutline;
	Graphics::TColor FOutlineColor;
	Menus::TPopupMenu* FOutlinePopup;
	int FPageNo;
	bool FRefreshing;
	bool FRunning;
	Stdctrls::TScrollStyle FScrollBars;
	Extctrls::TSplitter* FSplitter;
	TfrxPreviewWorkspace* FThumbnail;
	unsigned FTick;
	TfrxPreviewTool FTool;
	TfrxPreviewWorkspace* FWorkspace;
	System::Extended FZoom;
	Frxclass::TfrxZoomMode FZoomMode;
	Graphics::TColor __fastcall GetActiveFrameColor(void);
	Graphics::TColor __fastcall GetBackColor(void);
	Graphics::TColor __fastcall GetFrameColor(void);
	bool __fastcall GetOutlineVisible(void);
	int __fastcall GetOutlineWidth(void);
	int __fastcall GetPageCount(void);
	bool __fastcall GetThumbnailVisible(void);
	Controls::TMouseEvent __fastcall GetOnMouseDown(void);
	void __fastcall EditTemplate(void);
	void __fastcall OnCancel(System::TObject* Sender);
	void __fastcall OnCollapseClick(System::TObject* Sender);
	void __fastcall OnExpandClick(System::TObject* Sender);
	void __fastcall OnMoveSplitter(System::TObject* Sender);
	void __fastcall OnOutlineClick(System::TObject* Sender);
	void __fastcall SetActiveFrameColor(const Graphics::TColor Value);
	void __fastcall SetBackColor(const Graphics::TColor Value);
	void __fastcall SetBorderStyle(Forms::TBorderStyle Value);
	void __fastcall SetFrameColor(const Graphics::TColor Value);
	void __fastcall SetOutlineColor(const Graphics::TColor Value);
	void __fastcall SetOutlineWidth(const int Value);
	void __fastcall SetOutlineVisible(const bool Value);
	void __fastcall SetPageNo(int Value);
	void __fastcall SetThumbnailVisible(const bool Value);
	void __fastcall SetZoom(const System::Extended Value);
	void __fastcall SetZoomMode(const Frxclass::TfrxZoomMode Value);
	void __fastcall SetOnMouseDown(const Controls::TMouseEvent Value);
	void __fastcall UpdateOutline(void);
	void __fastcall UpdatePages(void);
	void __fastcall UpdatePageNumbers(void);
	MESSAGE void __fastcall WMEraseBackground(Messages::TMessage &Message);
	MESSAGE void __fastcall WMGetDlgCode(Messages::TWMNoParams &Message);
	
protected:
	virtual void __fastcall CreateParams(Controls::TCreateParams &Params);
	DYNAMIC void __fastcall Resize(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	DYNAMIC void __fastcall KeyDown(System::Word &Key, Classes::TShiftState Shift);
	
public:
	__fastcall virtual TfrxPreview(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxPreview(void);
	virtual void __fastcall Init(void);
	virtual void __fastcall Lock(void);
	virtual void __fastcall Unlock(void);
	virtual void __fastcall RefreshReport(void);
	virtual void __fastcall InternalOnProgressStart(Frxclass::TfrxReport* Sender, Frxclass::TfrxProgressType ProgressType, int Progress);
	virtual void __fastcall InternalOnProgress(Frxclass::TfrxReport* Sender, Frxclass::TfrxProgressType ProgressType, int Progress);
	virtual void __fastcall InternalOnProgressStop(Frxclass::TfrxReport* Sender, Frxclass::TfrxProgressType ProgressType, int Progress);
	void __fastcall AddPage(void);
	void __fastcall DeletePage(void);
	void __fastcall Print(void);
	void __fastcall Edit(void);
	void __fastcall First(void);
	void __fastcall Next(void);
	void __fastcall Prior(void);
	void __fastcall Last(void);
	void __fastcall PageSetupDlg(void);
	void __fastcall Find(void);
	void __fastcall FindNext(void);
	void __fastcall Cancel(void);
	void __fastcall Clear(void);
	void __fastcall SetPosition(int PageN, int Top);
	void __fastcall ShowMessage(const System::UnicodeString s);
	void __fastcall HideMessage(void);
	void __fastcall MouseWheelScroll(int Delta, bool Horz = false, bool Zoom = false);
	int __fastcall GetTopPosition(void);
	void __fastcall LoadFromFile(void)/* overload */;
	void __fastcall LoadFromFile(System::UnicodeString FileName)/* overload */;
	void __fastcall SaveToFile(void)/* overload */;
	void __fastcall SaveToFile(System::UnicodeString FileName)/* overload */;
	void __fastcall Export(Frxclass::TfrxCustomExportFilter* Filter);
	bool __fastcall FindText(System::UnicodeString SearchString, bool FromTop, bool IsCaseSensitive);
	bool __fastcall FindTextFound(void);
	void __fastcall FindTextClear(void);
	__property int PageCount = {read=GetPageCount, nodefault};
	__property int PageNo = {read=FPageNo, write=SetPageNo, nodefault};
	__property TfrxPreviewTool Tool = {read=FTool, write=FTool, nodefault};
	__property System::Extended Zoom = {read=FZoom, write=SetZoom};
	__property Frxclass::TfrxZoomMode ZoomMode = {read=FZoomMode, write=SetZoomMode, nodefault};
	__property bool Locked = {read=FLocked, nodefault};
	__property Comctrls::TTreeView* OutlineTree = {read=FOutline};
	__property Extctrls::TSplitter* Splitter = {read=FSplitter};
	__property TfrxPreviewWorkspace* Thumbnail = {read=FThumbnail};
	__property TfrxPreviewWorkspace* Workspace = {read=FWorkspace};
	
__published:
	__property Align = {default=0};
	__property Graphics::TColor ActiveFrameColor = {read=GetActiveFrameColor, write=SetActiveFrameColor, default=8405024};
	__property Graphics::TColor BackColor = {read=GetBackColor, write=SetBackColor, default=8421504};
	__property BevelEdges = {default=15};
	__property BevelInner = {index=0, default=2};
	__property BevelKind = {default=0};
	__property BevelOuter = {index=1, default=1};
	__property Forms::TBorderStyle BorderStyle = {read=FBorderStyle, write=SetBorderStyle, default=1};
	__property BorderWidth = {default=0};
	__property Graphics::TColor FrameColor = {read=GetFrameColor, write=SetFrameColor, default=0};
	__property Graphics::TColor OutlineColor = {read=FOutlineColor, write=SetOutlineColor, default=-16777211};
	__property bool OutlineVisible = {read=GetOutlineVisible, write=SetOutlineVisible, nodefault};
	__property int OutlineWidth = {read=GetOutlineWidth, write=SetOutlineWidth, nodefault};
	__property PopupMenu;
	__property bool ThumbnailVisible = {read=GetThumbnailVisible, write=SetThumbnailVisible, nodefault};
	__property OnClick;
	__property OnDblClick;
	__property TfrxPageChangedEvent OnPageChanged = {read=FOnPageChanged, write=FOnPageChanged};
	__property Controls::TMouseEvent OnMouseDown = {read=GetOnMouseDown, write=SetOnMouseDown};
	__property Anchors = {default=3};
	__property UseReportHints;
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxPreview(HWND ParentWindow) : Frxclass::TfrxCustomPreview(ParentWindow) { }
	
};


class DELPHICLASS TfrxPreviewForm;
class PASCALIMPLEMENTATION TfrxPreviewForm : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Comctrls::TToolBar* ToolBar;
	Comctrls::TToolButton* OpenB;
	Comctrls::TToolButton* SaveB;
	Comctrls::TToolButton* PrintB;
	Comctrls::TToolButton* ExportB;
	Comctrls::TToolButton* FindB;
	Comctrls::TToolButton* PageSettingsB;
	Frxdock::TfrxTBPanel* Sep3;
	Frxctrls::TfrxComboBox* ZoomCB;
	Comctrls::TToolButton* Sep1;
	Comctrls::TToolButton* Sep2;
	Comctrls::TToolButton* FirstB;
	Comctrls::TToolButton* PriorB;
	Frxdock::TfrxTBPanel* Sep4;
	Stdctrls::TEdit* PageE;
	Comctrls::TToolButton* NextB;
	Comctrls::TToolButton* LastB;
	Comctrls::TStatusBar* StatusBar;
	Comctrls::TToolButton* ZoomMinusB;
	Comctrls::TToolButton* Sep5;
	Comctrls::TToolButton* ZoomPlusB;
	Comctrls::TToolButton* DesignerB;
	Frxdock::TfrxTBPanel* frTBPanel1;
	Buttons::TSpeedButton* CancelB;
	Menus::TPopupMenu* ExportPopup;
	Menus::TPopupMenu* HiddenMenu;
	Menus::TMenuItem* Showtemplate1;
	Menus::TPopupMenu* RightMenu;
	Comctrls::TToolButton* FullScreenBtn;
	Comctrls::TToolButton* EmailB;
	Comctrls::TToolButton* PdfB;
	Comctrls::TToolButton* OutlineB;
	Comctrls::TToolButton* ThumbB;
	Menus::TMenuItem* N1;
	Menus::TMenuItem* ExpandMI;
	Menus::TMenuItem* CollapseMI;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall ZoomMinusBClick(System::TObject* Sender);
	void __fastcall ZoomCBClick(System::TObject* Sender);
	void __fastcall FormKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FirstBClick(System::TObject* Sender);
	void __fastcall PriorBClick(System::TObject* Sender);
	void __fastcall NextBClick(System::TObject* Sender);
	void __fastcall LastBClick(System::TObject* Sender);
	void __fastcall PageEClick(System::TObject* Sender);
	void __fastcall PrintBClick(System::TObject* Sender);
	void __fastcall OpenBClick(System::TObject* Sender);
	void __fastcall SaveBClick(System::TObject* Sender);
	void __fastcall FindBClick(System::TObject* Sender);
	void __fastcall FormClose(System::TObject* Sender, Forms::TCloseAction &Action);
	void __fastcall DesignerBClick(System::TObject* Sender);
	void __fastcall NewPageBClick(System::TObject* Sender);
	void __fastcall DelPageBClick(System::TObject* Sender);
	void __fastcall CancelBClick(System::TObject* Sender);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
	void __fastcall PageSettingsBClick(System::TObject* Sender);
	void __fastcall FormMouseWheel(System::TObject* Sender, Classes::TShiftState Shift, int WheelDelta, const Types::TPoint &MousePos, bool &Handled);
	void __fastcall DesignerBMouseUp(System::TObject* Sender, Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	void __fastcall Showtemplate1Click(System::TObject* Sender);
	void __fastcall FormCloseQuery(System::TObject* Sender, bool &CanClose);
	void __fastcall FullScreenBtnClick(System::TObject* Sender);
	void __fastcall PdfBClick(System::TObject* Sender);
	void __fastcall EmailBClick(System::TObject* Sender);
	void __fastcall ZoomPlusBClick(System::TObject* Sender);
	void __fastcall OutlineBClick(System::TObject* Sender);
	void __fastcall ThumbBClick(System::TObject* Sender);
	void __fastcall CollapseAllClick(System::TObject* Sender);
	void __fastcall ExpandAllClick(System::TObject* Sender);
	void __fastcall FormResize(System::TObject* Sender);
	
private:
	bool FFreeOnClose;
	TfrxPreview* FPreview;
	Forms::TFormBorderStyle FOldBS;
	Forms::TWindowState FOldState;
	bool FFullScreen;
	Frxclass::TfrxCustomExportFilter* FPDFExport;
	Frxclass::TfrxCustomExportFilter* FEmailExport;
	Classes::TWndMethod FStatusBarOldWindowProc;
	void __fastcall ExportMIClick(System::TObject* Sender);
	void __fastcall OnPageChanged(TfrxPreview* Sender, int PageNo);
	void __fastcall OnPreviewDblClick(System::TObject* Sender);
	void __fastcall UpdateControls(void);
	void __fastcall UpdateZoom(void);
	MESSAGE void __fastcall WMUpdateZoom(Messages::TMessage &Message);
	MESSAGE void __fastcall WMActivateApp(Messages::TWMActivateApp &Msg);
	HIDESBASE MESSAGE void __fastcall WMSysCommand(Messages::TWMSysCommand &Msg);
	void __fastcall StatusBarWndProc(Messages::TMessage &Message);
	Frxclass::TfrxReport* __fastcall GetReport(void);
	
public:
	void __fastcall Init(void);
	void __fastcall SetMessageText(const System::UnicodeString Value, bool IsHint = false);
	void __fastcall SwitchToFullScreen(void);
	__property bool FreeOnClose = {read=FFreeOnClose, write=FFreeOnClose, nodefault};
	__property TfrxPreview* Preview = {read=FPreview};
	__property Frxclass::TfrxReport* Report = {read=GetReport};
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxPreviewForm(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxPreviewForm(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxPreviewForm(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxPreviewForm(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TfrxPageList;
class PASCALIMPLEMENTATION TfrxPreviewWorkspace : public Frxctrls::TfrxScrollWin
{
	typedef Frxctrls::TfrxScrollWin inherited;
	
private:
	Graphics::TColor FActiveFrameColor;
	Graphics::TColor FBackColor;
	Controls::TCursor FDefaultCursor;
	bool FDisableUpdate;
	bool FDown;
	Graphics::TMetafile* FEMFImage;
	int FEMFImagePage;
	Graphics::TColor FFrameColor;
	bool FIsThumbnail;
	int FLastFoundPage;
	Types::TPoint FLastPoint;
	bool FLocked;
	Types::TPoint FOffset;
	unsigned FTimeOffset;
	TfrxPageList* FPageList;
	int FPageNo;
	TfrxPreview* FPreview;
	Frxclass::TfrxCustomPreviewPages* FPreviewPages;
	System::Extended FZoom;
	bool FRTLLanguage;
	void __fastcall DrawPages(bool BorderOnly);
	void __fastcall FindText(void);
	void __fastcall SetToPageNo(int PageNo);
	void __fastcall UpdateScrollBars(void);
	
protected:
	void __fastcall PrevDblClick(System::TObject* Sender);
	DYNAMIC void __fastcall MouseDown(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseMove(Classes::TShiftState Shift, int X, int Y);
	DYNAMIC void __fastcall MouseUp(Controls::TMouseButton Button, Classes::TShiftState Shift, int X, int Y);
	virtual void __fastcall OnHScrollChange(System::TObject* Sender);
	DYNAMIC void __fastcall Resize(void);
	virtual void __fastcall OnVScrollChange(System::TObject* Sender);
	
public:
	__fastcall virtual TfrxPreviewWorkspace(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxPreviewWorkspace(void);
	virtual void __fastcall Paint(void);
	HIDESBASE void __fastcall SetPosition(int PageN, int Top);
	int __fastcall GetTopPosition(void);
	void __fastcall AddPage(int AWidth, int AHeight);
	void __fastcall ClearPageList(void);
	void __fastcall CalcPageBounds(int ClientWidth);
	__property Graphics::TColor ActiveFrameColor = {read=FActiveFrameColor, write=FActiveFrameColor, default=8405024};
	__property Graphics::TColor BackColor = {read=FBackColor, write=FBackColor, default=8421504};
	__property Graphics::TColor FrameColor = {read=FFrameColor, write=FFrameColor, default=0};
	__property bool IsThumbnail = {read=FIsThumbnail, write=FIsThumbnail, nodefault};
	__property bool Locked = {read=FLocked, write=FLocked, nodefault};
	__property int PageNo = {read=FPageNo, write=FPageNo, nodefault};
	__property TfrxPreview* Preview = {read=FPreview, write=FPreview};
	__property Frxclass::TfrxCustomPreviewPages* PreviewPages = {read=FPreviewPages, write=FPreviewPages};
	__property System::Extended Zoom = {read=FZoom, write=FZoom};
	__property bool RTLLanguage = {read=FRTLLanguage, write=FRTLLanguage, nodefault};
	__property OnDblClick;
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxPreviewWorkspace(HWND ParentWindow) : Frxctrls::TfrxScrollWin(ParentWindow) { }
	
};


class DELPHICLASS TfrxPageItem;
class PASCALIMPLEMENTATION TfrxPageItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
public:
	int Height;
	int Width;
	int OffsetX;
	int OffsetY;
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxPageItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxPageItem(void) { }
	
};


class PASCALIMPLEMENTATION TfrxPageList : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxPageItem* operator[](int Index) { return Items[Index]; }
	
private:
	int FMaxWidth;
	TfrxPageItem* __fastcall GetItems(int Index);
	
public:
	__fastcall TfrxPageList(void);
	__property TfrxPageItem* Items[int Index] = {read=GetItems/*, default*/};
	void __fastcall AddPage(int AWidth, int AHeight, System::Extended Zoom);
	void __fastcall CalcBounds(int ClientWidth);
	int __fastcall FindPage(int OffsetY, int OffsetX = 0x0);
	Types::TRect __fastcall GetPageBounds(int Index, int ClientWidth, System::Extended Scale, bool RTL);
	Types::TPoint __fastcall GetMaxBounds(void);
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxPageList(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const Word WM_UPDATEZOOM = 0x401;

}	/* namespace Frxpreview */
using namespace Frxpreview;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxpreviewHPP
