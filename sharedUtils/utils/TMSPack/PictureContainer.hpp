// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Picturecontainer.pas' rev: 21.00

#ifndef PicturecontainerHPP
#define PicturecontainerHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Wininet.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Picturecontainer
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TPicturePosition { bpTopLeft, bpTopRight, bpBottomLeft, bpBottomRight, bpCenter, bpTiled, bpStretched };
#pragma option pop

struct TInternetContent;
typedef TInternetContent *PInternetContent;

class DELPHICLASS THTMLPicture;
struct TInternetContent
{
	
public:
	bool Complete;
	THTMLPicture* HTMLPicture;
};


typedef void __fastcall (__closure *TDownloadErrorEvent)(System::TObject* Sender, System::UnicodeString err);

typedef void __fastcall (__closure *TDownloadCompleteEvent)(System::TObject* Sender);

typedef void __fastcall (__closure *TDownloadCancelEvent)(System::TObject* Sender, bool &Cancel);

typedef void __fastcall (__closure *TDownloadProgressEvent)(System::TObject* Sender, unsigned dwSize, unsigned dwTotSize);

class DELPHICLASS TDownLoadThread;
class PASCALIMPLEMENTATION TDownLoadThread : public Classes::TThread
{
	typedef Classes::TThread inherited;
	
private:
	THTMLPicture* HTMLPicture;
	
protected:
	virtual void __fastcall Execute(void);
	
public:
	__fastcall TDownLoadThread(THTMLPicture* aHTMLPicture);
public:
	/* TThread.Destroy */ inline __fastcall virtual ~TDownLoadThread(void) { }
	
};


class PASCALIMPLEMENTATION THTMLPicture : public Graphics::TGraphic
{
	typedef Graphics::TGraphic inherited;
	
private:
	Classes::TMemoryStream* FDatastream;
	bool FIsEmpty;
	bool FStretched;
	_di_IPicture gpPicture;
	int FLogPixX;
	int FLogPixY;
	System::UnicodeString FURL;
	System::UnicodeString FID;
	int FHeight;
	int FWidth;
	bool FIsDB;
	bool FAsynch;
	bool FThreadBusy;
	int FFrame;
	int FFrameCount;
	Classes::TNotifyEvent FOnFrameChange;
	System::Word FFrameXPos;
	System::Word FFrameYPos;
	System::Word FFrameXSize;
	System::Word FFrameYSize;
	bool FFrameTransp;
	System::Word FFrameDisposal;
	System::Word FAnimMaxX;
	System::Word FAnimMaxY;
	int FNextCount;
	int FTimerCount;
	TDownloadProgressEvent FOnDownLoadProgress;
	TDownloadCancelEvent FOnDownLoadCancel;
	TDownloadCompleteEvent FOnDownLoadComplete;
	TDownloadErrorEvent FOnDownLoadError;
	void __fastcall LoadPicture(void);
	int __fastcall GetFrameCount(void);
	bool __fastcall IsGIFFile(void);
	int __fastcall GetFrameTime(int i);
	
protected:
	virtual bool __fastcall GetEmpty(void);
	virtual int __fastcall GetHeight(void);
	virtual int __fastcall GetWidth(void);
	virtual void __fastcall SetHeight(int Value);
	virtual void __fastcall SetWidth(int Value);
	virtual void __fastcall ReadData(Classes::TStream* Stream);
	virtual void __fastcall WriteData(Classes::TStream* Stream);
	virtual void __fastcall Draw(Graphics::TCanvas* ACanvas, const Types::TRect &Rect);
	void __fastcall DownLoadError(System::UnicodeString err);
	void __fastcall DownLoadComplete(void);
	void __fastcall DownLoadCancel(bool &cancel);
	void __fastcall DownLoadProgress(unsigned dwSize, unsigned dwTotSize);
	bool __fastcall GetStretched(void);
	void __fastcall SetStretched(const bool Value);
	
public:
	__fastcall virtual THTMLPicture(void);
	__fastcall virtual ~THTMLPicture(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	virtual void __fastcall LoadFromFile(const System::UnicodeString FileName);
	virtual void __fastcall LoadFromStream(Classes::TStream* Stream);
	virtual void __fastcall SaveToStream(Classes::TStream* Stream);
	void __fastcall LoadFromResourceName(unsigned Instance, const System::UnicodeString ResName);
	void __fastcall LoadFromResourceID(unsigned Instance, int ResID);
	void __fastcall LoadFromURL(System::UnicodeString url);
	virtual void __fastcall LoadFromClipboardFormat(System::Word AFormat, unsigned AData, HPALETTE APalette);
	virtual void __fastcall SaveToClipboardFormat(System::Word &AFormat, unsigned &AData, HPALETTE &APalette);
	__property bool Busy = {read=FThreadBusy, nodefault};
	__property bool Asynch = {read=FAsynch, write=FAsynch, nodefault};
	__property System::UnicodeString ID = {read=FID, write=FID};
	__property bool IsDB = {read=FIsDB, write=FIsDB, nodefault};
	__property bool IsGIF = {read=IsGIFFile, nodefault};
	__property int FrameCount = {read=GetFrameCount, nodefault};
	__property int FrameTime[int i] = {read=GetFrameTime};
	int __fastcall GetMaxHeight(void);
	int __fastcall GetMaxWidth(void);
	void __fastcall SetFrame(const int Value);
	void __fastcall FrameNext(void);
	void __fastcall FramePrev(void);
	bool __fastcall Step(void);
	__property int MaxWidth = {read=GetMaxWidth, nodefault};
	__property int MaxHeight = {read=GetMaxHeight, nodefault};
	__property System::Word FrameXPos = {read=FFrameXPos, nodefault};
	__property System::Word FrameYPos = {read=FFrameYPos, nodefault};
	
__published:
	__property bool Stretch = {read=GetStretched, write=SetStretched, nodefault};
	__property int Frame = {read=FFrame, write=SetFrame, nodefault};
	__property Classes::TNotifyEvent OnFrameChange = {read=FOnFrameChange, write=FOnFrameChange};
	__property TDownloadErrorEvent OnDownLoadError = {read=FOnDownLoadError, write=FOnDownLoadError};
	__property TDownloadCompleteEvent OnDownLoadComplete = {read=FOnDownLoadComplete, write=FOnDownLoadComplete};
	__property TDownloadCancelEvent OnDownLoadCancel = {read=FOnDownLoadCancel, write=FOnDownLoadCancel};
	__property TDownloadProgressEvent OnDownLoadProgress = {read=FOnDownLoadProgress, write=FOnDownLoadProgress};
};


class DELPHICLASS THTMLPictureCache;
class PASCALIMPLEMENTATION THTMLPictureCache : public Classes::TList
{
	typedef Classes::TList inherited;
	
public:
	THTMLPicture* operator[](int index) { return Items[index]; }
	
private:
	void __fastcall SetPicture(int Index, THTMLPicture* Value);
	THTMLPicture* __fastcall GetPicture(int Index);
	
public:
	__fastcall virtual ~THTMLPictureCache(void);
	__property THTMLPicture* Items[int index] = {read=GetPicture, write=SetPicture/*, default*/};
	THTMLPicture* __fastcall AddPicture(void);
	Graphics::TGraphic* __fastcall FindPicture(System::UnicodeString ID);
	void __fastcall ClearPictures(void);
	bool __fastcall Animate(void);
public:
	/* TObject.Create */ inline __fastcall THTMLPictureCache(void) : Classes::TList() { }
	
};


class DELPHICLASS THTMLImage;
class PASCALIMPLEMENTATION THTMLImage : public Controls::TGraphicControl
{
	typedef Controls::TGraphicControl inherited;
	
private:
	THTMLPicture* FHTMLPicture;
	TPicturePosition FPicturePosition;
	TDownloadCancelEvent FOnDownLoadCancel;
	TDownloadCompleteEvent FOnDownLoadComplete;
	TDownloadErrorEvent FOnDownLoadError;
	TDownloadProgressEvent FOnDownLoadProgress;
	void __fastcall SetHTMLPicture(const THTMLPicture* Value);
	void __fastcall PictureChanged(System::TObject* sender);
	void __fastcall SetPicturePosition(const TPicturePosition Value);
	void __fastcall DownLoadError(System::TObject* Sender, System::UnicodeString err);
	void __fastcall DownLoadComplete(System::TObject* Sender);
	void __fastcall DownLoadCancel(System::TObject* Sender, bool &Cancel);
	void __fastcall DownLoadProgress(System::TObject* Sender, unsigned dwSize, unsigned dwTotSize);
	
protected:
	virtual void __fastcall Paint(void);
	virtual void __fastcall Loaded(void);
	
public:
	__fastcall virtual THTMLImage(Classes::TComponent* aOwner);
	__fastcall virtual ~THTMLImage(void);
	
__published:
	__property THTMLPicture* HTMLPicture = {read=FHTMLPicture, write=SetHTMLPicture};
	__property TPicturePosition PicturePosition = {read=FPicturePosition, write=SetPicturePosition, nodefault};
	__property Align = {default=0};
	__property Anchors = {default=3};
	__property Constraints;
	__property DragKind = {default=0};
	__property DragCursor = {default=-12};
	__property DragMode = {default=0};
	__property Hint;
	__property ParentShowHint = {default=1};
	__property ShowHint;
	__property Visible = {default=1};
	__property OnClick;
	__property OnContextPopup;
	__property OnDblClick;
	__property OnDragDrop;
	__property OnDragOver;
	__property OnEndDock;
	__property OnStartDock;
	__property OnEndDrag;
	__property OnMouseDown;
	__property OnMouseUp;
	__property OnMouseMove;
	__property OnStartDrag;
	__property TDownloadErrorEvent OnDownLoadError = {read=FOnDownLoadError, write=FOnDownLoadError};
	__property TDownloadCompleteEvent OnDownLoadComplete = {read=FOnDownLoadComplete, write=FOnDownLoadComplete};
	__property TDownloadCancelEvent OnDownLoadCancel = {read=FOnDownLoadCancel, write=FOnDownLoadCancel};
	__property TDownloadProgressEvent OnDownLoadProgress = {read=FOnDownLoadProgress, write=FOnDownLoadProgress};
};


class DELPHICLASS TPictureItem;
class PASCALIMPLEMENTATION TPictureItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	Graphics::TGraphic* FPicture;
	int FTag;
	System::UnicodeString FName;
	void __fastcall SetPicture(const Graphics::TGraphic* Value);
	
protected:
	virtual Graphics::TGraphic* __fastcall CreatePicture(void);
	
public:
	__fastcall virtual TPictureItem(Classes::TCollection* Collection);
	__fastcall virtual ~TPictureItem(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property Graphics::TGraphic* Picture = {read=FPicture, write=SetPicture};
	__property System::UnicodeString Name = {read=FName, write=FName};
	__property int Tag = {read=FTag, write=FTag, nodefault};
};


class DELPHICLASS TPictureCollection;
class PASCALIMPLEMENTATION TPictureCollection : public Classes::TOwnedCollection
{
	typedef Classes::TOwnedCollection inherited;
	
public:
	TPictureItem* operator[](int Index) { return Items[Index]; }
	
private:
	Classes::TComponent* FOwner;
	HIDESBASE TPictureItem* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, TPictureItem* Value);
	
protected:
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
	virtual Classes::TCollectionItemClass __fastcall GetItemClass(void);
	
public:
	__fastcall TPictureCollection(Classes::TComponent* AOwner);
	HIDESBASE TPictureItem* __fastcall Add(void);
	HIDESBASE TPictureItem* __fastcall Insert(int index);
	__property TPictureItem* Items[int Index] = {read=GetItem, write=SetItem/*, default*/};
	bool __fastcall Animate(void);
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TPictureCollection(void) { }
	
};


class DELPHICLASS TPictureContainer;
class PASCALIMPLEMENTATION TPictureContainer : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	TPictureCollection* FItems;
	void __fastcall SetItems(const TPictureCollection* Value);
	System::UnicodeString __fastcall GetVersion(void);
	void __fastcall SetVersion(const System::UnicodeString Value);
	int __fastcall GetVersionNr(void);
	
protected:
	virtual TPictureCollection* __fastcall CreateItems(void);
	
public:
	__fastcall virtual TPictureContainer(Classes::TComponent* AOwner);
	__fastcall virtual ~TPictureContainer(void);
	virtual Graphics::TGraphic* __fastcall FindPicture(System::UnicodeString s);
	
__published:
	__property TPictureCollection* Items = {read=FItems, write=SetItems};
	__property System::UnicodeString Version = {read=GetVersion, write=SetVersion};
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x2;
static const ShortInt MIN_VER = 0x0;
static const ShortInt REL_VER = 0x0;
static const ShortInt BLD_VER = 0x0;

}	/* namespace Picturecontainer */
using namespace Picturecontainer;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// PicturecontainerHPP
