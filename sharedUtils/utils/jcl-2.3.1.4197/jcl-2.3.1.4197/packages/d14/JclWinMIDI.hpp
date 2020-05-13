// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclwinmidi.pas' rev: 21.00

#ifndef JclwinmidiHPP
#define JclwinmidiHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Mmsystem.hpp>	// Pascal unit
#include <Jclmidi.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclwinmidi
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TStereoChannel { scLeft, scRight };
#pragma option pop

__interface IJclWinMidiOut;
typedef System::DelphiInterface<IJclWinMidiOut> _di_IJclWinMidiOut;
__interface  INTERFACE_UUID("{F3FCE71C-B924-462C-BA0D-8C2DC118DADB}") IJclWinMidiOut  : public Jclmidi::IJclMIDIOut 
{
	
public:
	virtual System::Word __fastcall GetChannelVolume(TStereoChannel Channel) = 0 ;
	virtual void __fastcall SetChannelVolume(TStereoChannel Channel, const System::Word Value) = 0 ;
	virtual System::Word __fastcall GetVolume(void) = 0 ;
	virtual void __fastcall SetVolume(const System::Word Value) = 0 ;
	__property System::Word ChannelVolume[TStereoChannel Channel] = {read=GetChannelVolume, write=SetChannelVolume};
	__property System::Word Volume = {read=GetVolume, write=SetVolume};
};

class DELPHICLASS TJclWinMidiOut;
class PASCALIMPLEMENTATION TJclWinMidiOut : public Jclmidi::TJclMIDIOut
{
	typedef Jclmidi::TJclMIDIOut inherited;
	
private:
	int FHandle;
	unsigned FDeviceID;
	tagMIDIOUTCAPSW FDeviceCaps;
	unsigned FVolume;
	void __fastcall SetLRVolume(const System::Word LeftValue, const System::Word RightValue);
	
protected:
	void __fastcall LongMessage(System::Byte const *Data, const int Data_Size);
	virtual void __fastcall DoSendMessage(System::Byte const *Data, const int Data_Size);
	
public:
	__fastcall TJclWinMidiOut(unsigned ADeviceID);
	__fastcall virtual ~TJclWinMidiOut(void);
	__property unsigned DeviceID = {read=FDeviceID, nodefault};
	virtual System::UnicodeString __fastcall GetName(void);
	__property System::UnicodeString Name = {read=GetName};
	System::Word __fastcall GetChannelVolume(TStereoChannel Channel);
	void __fastcall SetChannelVolume(TStereoChannel Channel, const System::Word Value);
	System::Word __fastcall GetVolume(void);
	void __fastcall SetVolume(const System::Word Value);
	__property System::Word ChannelVolume[TStereoChannel Channel] = {read=GetChannelVolume, write=SetChannelVolume};
	__property System::Word Volume = {read=GetVolume, write=SetVolume, nodefault};
private:
	void *__IJclWinMidiOut;	/* IJclWinMidiOut */
	
public:
	#if defined(MANAGED_INTERFACE_OPERATORS)
	operator _di_IJclWinMidiOut()
	{
		_di_IJclWinMidiOut intf;
		GetInterface(intf);
		return intf;
	}
	#else
	operator IJclWinMidiOut*(void) { return (IJclWinMidiOut*)&__IJclWinMidiOut; }
	#endif
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE void __fastcall GetMidiOutputs(const Classes::TStrings* List);
extern PACKAGE void __fastcall MidiInCheck(unsigned Code);
extern PACKAGE void __fastcall MidiOutCheck(unsigned Code);
extern PACKAGE _di_IJclWinMidiOut __fastcall MidiOut(unsigned DeviceID);

}	/* namespace Jclwinmidi */
using namespace Jclwinmidi;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclwinmidiHPP
