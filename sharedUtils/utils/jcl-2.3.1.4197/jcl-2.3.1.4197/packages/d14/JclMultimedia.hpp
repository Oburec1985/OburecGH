// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclmultimedia.pas' rev: 21.00

#ifndef JclmultimediaHPP
#define JclmultimediaHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Mmsystem.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclsynch.hpp>	// Pascal unit
#include <Jclstrings.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclmultimedia
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TMmTimerKind { tkOneShot, tkPeriodic };
#pragma option pop

#pragma option push -b-
enum TMmNotificationKind { nkCallback, nkSetEvent, nkPulseEvent };
#pragma option pop

class DELPHICLASS TJclMultimediaTimer;
class PASCALIMPLEMENTATION TJclMultimediaTimer : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Jclsynch::TJclEvent* FEvent;
	TMmTimerKind FKind;
	TMmNotificationKind FNotification;
	Classes::TNotifyEvent FOnTimer;
	unsigned FPeriod;
	unsigned FStartTime;
	timecaps_tag FTimeCaps;
	unsigned FTimerId;
	unsigned __fastcall GetMinMaxPeriod(int Index);
	void __fastcall SetPeriod(unsigned Value);
	
protected:
	virtual void __fastcall Timer(unsigned Id);
	
public:
	__fastcall TJclMultimediaTimer(TMmTimerKind Kind, TMmNotificationKind Notification);
	__fastcall virtual ~TJclMultimediaTimer(void);
	__classmethod unsigned __fastcall GetTime();
	__classmethod bool __fastcall BeginPeriod(const unsigned Period);
	__classmethod bool __fastcall EndPeriod(const unsigned Period);
	void __fastcall BeginTimer(const unsigned Delay, const unsigned Resolution);
	void __fastcall EndTimer(void);
	unsigned __fastcall Elapsed(const bool Update);
	Jclsynch::TJclWaitResult __fastcall WaitFor(const unsigned TimeOut);
	__property Jclsynch::TJclEvent* Event = {read=FEvent};
	__property TMmTimerKind Kind = {read=FKind, nodefault};
	__property unsigned MaxPeriod = {read=GetMinMaxPeriod, index=0, nodefault};
	__property unsigned MinPeriod = {read=GetMinMaxPeriod, index=1, nodefault};
	__property TMmNotificationKind Notification = {read=FNotification, nodefault};
	__property Classes::TNotifyEvent OnTimer = {read=FOnTimer, write=FOnTimer};
	__property unsigned Period = {read=FPeriod, write=SetPeriod, nodefault};
};


class DELPHICLASS EJclMmTimerError;
class PASCALIMPLEMENTATION EJclMmTimerError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclMmTimerError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclMmTimerError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclMmTimerError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclMmTimerError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclMmTimerError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclMmTimerError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclMmTimerError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclMmTimerError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclMmTimerError(void) { }
	
};


class DELPHICLASS EJclMixerError;
class PASCALIMPLEMENTATION EJclMixerError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
public:
	/* Exception.Create */ inline __fastcall EJclMixerError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclMixerError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclMixerError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclMixerError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclMixerError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclMixerError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclMixerError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclMixerError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclMixerError(void) { }
	
};


class DELPHICLASS TJclMixerLineControl;
class DELPHICLASS TJclMixerLine;
class PASCALIMPLEMENTATION TJclMixerLineControl : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	#pragma pack(push,1)
	tagMIXERCONTROLW FControlInfo;
	#pragma pack(pop)
	bool FIsList;
	bool FIsMultiple;
	bool FIsUniform;
	Classes::TStringList* FListText;
	TJclMixerLine* FMixerLine;
	bool __fastcall GetIsDisabled(void);
	unsigned __fastcall GetID(void);
	Classes::TStrings* __fastcall GetListText(void);
	System::UnicodeString __fastcall GetName(void);
	unsigned __fastcall GetUniformValue(void);
	Jclbase::TDynCardinalArray __fastcall GetValue(void);
	System::UnicodeString __fastcall GetValueString(void);
	void __fastcall SetUniformValue(const unsigned Value);
	void __fastcall SetValue(const Jclbase::TDynCardinalArray Value);
	
protected:
	void __fastcall PrepareControlDetailsStruc(/* out */ tMIXERCONTROLDETAILS &ControlDetails, bool AUniform, bool AMultiple);
	
public:
	__fastcall TJclMixerLineControl(TJclMixerLine* AMixerLine, const tagMIXERCONTROLW &AControlInfo);
	__fastcall virtual ~TJclMixerLineControl(void);
	System::UnicodeString __fastcall FormatValue(unsigned AValue);
	__property tagMIXERCONTROLW ControlInfo = {read=FControlInfo};
	__property unsigned ID = {read=GetID, nodefault};
	__property bool IsDisabled = {read=GetIsDisabled, nodefault};
	__property bool IsList = {read=FIsList, nodefault};
	__property bool IsMultiple = {read=FIsMultiple, nodefault};
	__property bool IsUniform = {read=FIsUniform, nodefault};
	__property Classes::TStrings* ListText = {read=GetListText};
	__property TJclMixerLine* MixerLine = {read=FMixerLine};
	__property System::UnicodeString Name = {read=GetName};
	__property unsigned UniformValue = {read=GetUniformValue, write=SetUniformValue, nodefault};
	__property Jclbase::TDynCardinalArray Value = {read=GetValue, write=SetValue};
	__property System::UnicodeString ValueString = {read=GetValueString};
};


class DELPHICLASS TJclMixerDevice;
class PASCALIMPLEMENTATION TJclMixerLine : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclMixerLineControl* operator[](int Index) { return LineControls[Index]; }
	
private:
	Contnrs::TObjectList* FLineControls;
	tagMIXERLINEW FLineInfo;
	TJclMixerDevice* FMixerDevice;
	System::UnicodeString __fastcall GetComponentString(void);
	TJclMixerLineControl* __fastcall GetLineControlByType(unsigned ControlType);
	int __fastcall GetLineControlCount(void);
	TJclMixerLineControl* __fastcall GetLineControls(int Index);
	bool __fastcall GetHasControlType(unsigned ControlType);
	unsigned __fastcall GetID(void);
	System::UnicodeString __fastcall GetName(void);
	
protected:
	void __fastcall BuildLineControls(void);
	
public:
	__fastcall TJclMixerLine(TJclMixerDevice* AMixerDevice);
	__fastcall virtual ~TJclMixerLine(void);
	__classmethod System::UnicodeString __fastcall ComponentTypeToString(const unsigned ComponentType);
	__property System::UnicodeString ComponentString = {read=GetComponentString};
	__property bool HasControlType[unsigned ControlType] = {read=GetHasControlType};
	__property unsigned ID = {read=GetID, nodefault};
	__property TJclMixerLineControl* LineControlByType[unsigned ControlType] = {read=GetLineControlByType};
	__property TJclMixerLineControl* LineControls[int Index] = {read=GetLineControls/*, default*/};
	__property int LineControlCount = {read=GetLineControlCount, nodefault};
	__property tagMIXERLINEW LineInfo = {read=FLineInfo};
	__property System::UnicodeString Name = {read=GetName};
	__property TJclMixerDevice* MixerDevice = {read=FMixerDevice};
};


class DELPHICLASS TJclMixerSource;
class DELPHICLASS TJclMixerDestination;
class PASCALIMPLEMENTATION TJclMixerSource : public TJclMixerLine
{
	typedef TJclMixerLine inherited;
	
private:
	TJclMixerDestination* FMixerDestination;
	
public:
	__fastcall TJclMixerSource(TJclMixerDestination* AMixerDestination, unsigned ASourceIndex);
	__property TJclMixerDestination* MixerDestination = {read=FMixerDestination};
public:
	/* TJclMixerLine.Destroy */ inline __fastcall virtual ~TJclMixerSource(void) { }
	
};


class PASCALIMPLEMENTATION TJclMixerDestination : public TJclMixerLine
{
	typedef TJclMixerLine inherited;
	
public:
	TJclMixerSource* operator[](int Index) { return Sources[Index]; }
	
private:
	Contnrs::TObjectList* FSources;
	int __fastcall GetSourceCount(void);
	TJclMixerSource* __fastcall GetSources(int Index);
	
protected:
	void __fastcall BuildSources(void);
	
public:
	__fastcall TJclMixerDestination(TJclMixerDevice* AMixerDevice, unsigned ADestinationIndex);
	__fastcall virtual ~TJclMixerDestination(void);
	__property TJclMixerSource* Sources[int Index] = {read=GetSources/*, default*/};
	__property int SourceCount = {read=GetSourceCount, nodefault};
};


class PASCALIMPLEMENTATION TJclMixerDevice : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclMixerDestination* operator[](int Index) { return Destinations[Index]; }
	
private:
	tagMIXERCAPSW FCapabilities;
	Contnrs::TObjectList* FDestinations;
	unsigned FDeviceIndex;
	int FHandle;
	Classes::TList* FLines;
	System::UnicodeString __fastcall GetProductName(void);
	int __fastcall GetDestinationCount(void);
	TJclMixerDestination* __fastcall GetDestinations(int Index);
	int __fastcall GetLineCount(void);
	TJclMixerLine* __fastcall GetLines(int Index);
	TJclMixerLine* __fastcall GetLineByComponentType(unsigned ComponentType);
	TJclMixerLine* __fastcall GetLineByID(unsigned LineID);
	TJclMixerLineControl* __fastcall GetLineControlByID(unsigned ControlID);
	unsigned __fastcall GetLineUniformValue(unsigned ComponentType, unsigned ControlType);
	void __fastcall SetLineUniformValue(unsigned ComponentType, unsigned ControlType, const unsigned Value);
	
protected:
	void __fastcall BuildDestinations(void);
	void __fastcall BuildLines(void);
	void __fastcall Close(void);
	void __fastcall Open(unsigned ACallBackWnd);
	
public:
	__fastcall TJclMixerDevice(unsigned ADeviceIndex, unsigned ACallBackWnd);
	__fastcall virtual ~TJclMixerDevice(void);
	TJclMixerLineControl* __fastcall FindLineControl(unsigned ComponentType, unsigned ControlType);
	__property tagMIXERCAPSW Capabilities = {read=FCapabilities};
	__property unsigned DeviceIndex = {read=FDeviceIndex, nodefault};
	__property TJclMixerDestination* Destinations[int Index] = {read=GetDestinations/*, default*/};
	__property int DestinationCount = {read=GetDestinationCount, nodefault};
	__property int Handle = {read=FHandle, nodefault};
	__property TJclMixerLine* LineByID[unsigned LineID] = {read=GetLineByID};
	__property TJclMixerLine* LineByComponentType[unsigned ComponentType] = {read=GetLineByComponentType};
	__property TJclMixerLine* Lines[int Index] = {read=GetLines};
	__property int LineCount = {read=GetLineCount, nodefault};
	__property TJclMixerLineControl* LineControlByID[unsigned ControlID] = {read=GetLineControlByID};
	__property unsigned LineUniformValue[unsigned ComponentType][unsigned ControlType] = {read=GetLineUniformValue, write=SetLineUniformValue};
	__property System::UnicodeString ProductName = {read=GetProductName};
};


class DELPHICLASS TJclMixer;
class PASCALIMPLEMENTATION TJclMixer : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclMixerDevice* operator[](int Index) { return Devices[Index]; }
	
private:
	unsigned FCallbackWnd;
	Contnrs::TObjectList* FDeviceList;
	int __fastcall GetDeviceCount(void);
	TJclMixerDevice* __fastcall GetDevices(int Index);
	TJclMixerDevice* __fastcall GetFirstDevice(void);
	bool __fastcall GetLineMute(int ComponentType);
	unsigned __fastcall GetLineVolume(int ComponentType);
	TJclMixerLine* __fastcall GetLineByID(int MixerHandle, unsigned LineID);
	TJclMixerLineControl* __fastcall GetLineControlByID(int MixerHandle, unsigned LineID);
	void __fastcall SetLineMute(int ComponentType, const bool Value);
	void __fastcall SetLineVolume(int ComponentType, const unsigned Value);
	
protected:
	void __fastcall BuildDevices(void);
	
public:
	__fastcall TJclMixer(unsigned ACallBackWnd);
	__fastcall virtual ~TJclMixer(void);
	__property unsigned CallbackWnd = {read=FCallbackWnd, nodefault};
	__property TJclMixerDevice* Devices[int Index] = {read=GetDevices/*, default*/};
	__property int DeviceCount = {read=GetDeviceCount, nodefault};
	__property TJclMixerDevice* FirstDevice = {read=GetFirstDevice};
	__property TJclMixerLine* LineByID[int MixerHandle][unsigned LineID] = {read=GetLineByID};
	__property TJclMixerLineControl* LineControlByID[int MixerHandle][unsigned LineID] = {read=GetLineControlByID};
	__property bool LineMute[int ComponentType] = {read=GetLineMute, write=SetLineMute};
	__property unsigned LineVolume[int ComponentType] = {read=GetLineVolume, write=SetLineVolume};
	__property bool SpeakersMute = {read=GetLineMute, write=SetLineMute, index=4, nodefault};
	__property unsigned SpeakersVolume = {read=GetLineVolume, write=SetLineVolume, index=4, nodefault};
};


class DELPHICLASS EJclMciError;
class PASCALIMPLEMENTATION EJclMciError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
private:
	unsigned FMciErrorNo;
	System::UnicodeString FMciErrorMsg;
	
public:
	__fastcall EJclMciError(unsigned MciErrNo, const System::UnicodeString Msg);
	__fastcall EJclMciError(unsigned MciErrNo, const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size);
	__fastcall EJclMciError(unsigned MciErrNo, int Ident);
	__property unsigned MciErrorNo = {read=FMciErrorNo, nodefault};
	__property System::UnicodeString MciErrorMsg = {read=FMciErrorMsg};
public:
	/* Exception.CreateResFmt */ inline __fastcall EJclMciError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclMciError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclMciError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclMciError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclMciError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclMciError(void) { }
	
};


#pragma option push -b-
enum TJclCdMediaInfo { miProduct, miIdentity, miUPC };
#pragma option pop

#pragma option push -b-
enum TJclCdTrackType { ttAudio, ttOther };
#pragma option pop

struct TJclCdTrackInfo
{
	
public:
	System::Byte Minute;
	System::Byte Second;
	TJclCdTrackType TrackType;
};


typedef DynamicArray<TJclCdTrackInfo> TJclCdTrackInfoArray;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE int INVALID_MIXER_HANDLE;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE Jclbase::TDynCardinalArray __fastcall MixerLeftRightToArray(unsigned Left, unsigned Right);
extern PACKAGE System::UnicodeString __fastcall GetMciErrorMessage(const unsigned MciErrNo);
extern PACKAGE unsigned __fastcall MMCheck(const unsigned MciError, const System::UnicodeString Msg = L"");
extern PACKAGE unsigned __fastcall OpenCdMciDevice(/* out */ tagMCI_OPEN_PARMSW &OpenParams, System::WideChar Drive = (System::WideChar)(0x0));
extern PACKAGE unsigned __fastcall CloseCdMciDevice(tagMCI_OPEN_PARMSW &OpenParams);
extern PACKAGE void __fastcall OpenCloseCdDrive(bool OpenMode, System::WideChar Drive = (System::WideChar)(0x0));
extern PACKAGE bool __fastcall IsMediaPresentInDrive(System::WideChar Drive = (System::WideChar)(0x0));
extern PACKAGE System::UnicodeString __fastcall GetCdInfo(TJclCdMediaInfo InfoType, System::WideChar Drive = (System::WideChar)(0x0));
extern PACKAGE TJclCdTrackInfo __fastcall GetCDAudioTrackList(/* out */ TJclCdTrackInfoArray &TrackList, System::WideChar Drive = (System::WideChar)(0x0))/* overload */;
extern PACKAGE System::UnicodeString __fastcall GetCDAudioTrackList(Classes::TStrings* TrackList, bool IncludeTrackType = false, System::WideChar Drive = (System::WideChar)(0x0))/* overload */;

}	/* namespace Jclmultimedia */
using namespace Jclmultimedia;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclmultimediaHPP
