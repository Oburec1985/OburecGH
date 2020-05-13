// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclmapi.pas' rev: 21.00

#ifndef JclmapiHPP
#define JclmapiHPP

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
#include <Contnrs.hpp>	// Pascal unit
#include <Mapi.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclansistrings.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclmapi
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EJclMapiError;
class PASCALIMPLEMENTATION EJclMapiError : public Jclbase::EJclError
{
	typedef Jclbase::EJclError inherited;
	
private:
	unsigned FErrorCode;
	
public:
	__property unsigned ErrorCode = {read=FErrorCode, nodefault};
public:
	/* Exception.Create */ inline __fastcall EJclMapiError(const System::UnicodeString Msg) : Jclbase::EJclError(Msg) { }
	/* Exception.CreateFmt */ inline __fastcall EJclMapiError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size) : Jclbase::EJclError(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ inline __fastcall EJclMapiError(int Ident)/* overload */ : Jclbase::EJclError(Ident) { }
	/* Exception.CreateResFmt */ inline __fastcall EJclMapiError(int Ident, System::TVarRec const *Args, const int Args_Size)/* overload */ : Jclbase::EJclError(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ inline __fastcall EJclMapiError(const System::UnicodeString Msg, int AHelpContext) : Jclbase::EJclError(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ inline __fastcall EJclMapiError(const System::UnicodeString Msg, System::TVarRec const *Args, const int Args_Size, int AHelpContext) : Jclbase::EJclError(Msg, Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ inline __fastcall EJclMapiError(int Ident, int AHelpContext)/* overload */ : Jclbase::EJclError(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ inline __fastcall EJclMapiError(System::PResStringRec ResStringRec, System::TVarRec const *Args, const int Args_Size, int AHelpContext)/* overload */ : Jclbase::EJclError(ResStringRec, Args, Args_Size, AHelpContext) { }
	/* Exception.Destroy */ inline __fastcall virtual ~EJclMapiError(void) { }
	
};


struct TJclMapiClient
{
	
public:
	System::UnicodeString ClientName;
	System::UnicodeString ClientPath;
	System::UnicodeString RegKeyName;
	bool Valid;
};


#pragma option push -b-
enum TJclMapiClientConnect { ctAutomatic, ctMapi, ctDirect };
#pragma option pop

class DELPHICLASS TJclSimpleMapi;
class PASCALIMPLEMENTATION TJclSimpleMapi : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	typedef DynamicArray<TJclMapiClient> _TJclSimpleMapi__1;
	
	typedef DynamicArray<System::AnsiString> _TJclSimpleMapi__2;
	
	
public:
	TJclMapiClient operator[](int Index) { return Clients[Index]; }
	
private:
	bool FAnyClientInstalled;
	Classes::TNotifyEvent FBeforeUnloadClient;
	_TJclSimpleMapi__1 FClients;
	TJclMapiClientConnect FClientConnectKind;
	unsigned FClientLibHandle;
	int FDefaultClientIndex;
	System::AnsiString FDefaultProfileName;
	StaticArray<void *, 12> FFunctions;
	bool FMapiInstalled;
	System::UnicodeString FMapiVersion;
	_TJclSimpleMapi__2 FProfiles;
	int FSelectedClientIndex;
	bool FSimpleMapiInstalled;
	Mapi::TFNMapiAddress FMapiAddress;
	Mapi::TFNMapiDeleteMail FMapiDeleteMail;
	Mapi::TFNMapiDetails FMapiDetails;
	Mapi::TFNMapiFindNext FMapiFindNext;
	Mapi::TFNMapiFreeBuffer FMapiFreeBuffer;
	Mapi::TFNMapiLogOff FMapiLogOff;
	Mapi::TFNMapiLogOn FMapiLogOn;
	Mapi::TFNMapiReadMail FMapiReadMail;
	Mapi::TFNMapiResolveName FMapiResolveName;
	Mapi::TFNMapiSaveMail FMapiSaveMail;
	Mapi::TFNMapiSendDocuments FMapiSendDocuments;
	Mapi::TFNMapiSendMail FMapiSendMail;
	int __fastcall GetClientCount(void);
	TJclMapiClient __fastcall GetClients(int Index);
	System::UnicodeString __fastcall GetCurrentClientName(void);
	int __fastcall GetProfileCount(void);
	System::AnsiString __fastcall GetProfiles(int Index);
	void __fastcall SetSelectedClientIndex(const int Value);
	void __fastcall SetClientConnectKind(const TJclMapiClientConnect Value);
	bool __fastcall UseMapi(void);
	
protected:
	DYNAMIC void __fastcall BeforeUnloadClientLib(void);
	void __fastcall CheckListIndex(int I, int ArrayLength);
	System::UnicodeString __fastcall GetClientLibName(void);
	__classmethod System::UnicodeString __fastcall ProfilesRegKey();
	void __fastcall ReadMapiSettings(void);
	
public:
	__fastcall TJclSimpleMapi(void);
	__fastcall virtual ~TJclSimpleMapi(void);
	bool __fastcall ClientLibLoaded(void);
	void __fastcall LoadClientLib(void);
	void __fastcall UnloadClientLib(void);
	__property bool AnyClientInstalled = {read=FAnyClientInstalled, nodefault};
	__property TJclMapiClientConnect ClientConnectKind = {read=FClientConnectKind, write=SetClientConnectKind, nodefault};
	__property int ClientCount = {read=GetClientCount, nodefault};
	__property TJclMapiClient Clients[int Index] = {read=GetClients/*, default*/};
	__property System::UnicodeString CurrentClientName = {read=GetCurrentClientName};
	__property int DefaultClientIndex = {read=FDefaultClientIndex, nodefault};
	__property System::AnsiString DefaultProfileName = {read=FDefaultProfileName};
	__property bool MapiInstalled = {read=FMapiInstalled, nodefault};
	__property System::UnicodeString MapiVersion = {read=FMapiVersion};
	__property int ProfileCount = {read=GetProfileCount, nodefault};
	__property System::AnsiString Profiles[int Index] = {read=GetProfiles};
	__property int SelectedClientIndex = {read=FSelectedClientIndex, write=SetSelectedClientIndex, nodefault};
	__property bool SimpleMapiInstalled = {read=FSimpleMapiInstalled, nodefault};
	__property Classes::TNotifyEvent BeforeUnloadClient = {read=FBeforeUnloadClient, write=FBeforeUnloadClient};
	__property Mapi::TFNMapiAddress MapiAddress = {read=FMapiAddress};
	__property Mapi::TFNMapiDeleteMail MapiDeleteMail = {read=FMapiDeleteMail};
	__property Mapi::TFNMapiDetails MapiDetails = {read=FMapiDetails};
	__property Mapi::TFNMapiFindNext MapiFindNext = {read=FMapiFindNext};
	__property Mapi::TFNMapiFreeBuffer MapiFreeBuffer = {read=FMapiFreeBuffer};
	__property Mapi::TFNMapiLogOff MapiLogOff = {read=FMapiLogOff};
	__property Mapi::TFNMapiLogOn MapiLogOn = {read=FMapiLogOn};
	__property Mapi::TFNMapiReadMail MapiReadMail = {read=FMapiReadMail};
	__property Mapi::TFNMapiResolveName MapiResolveName = {read=FMapiResolveName};
	__property Mapi::TFNMapiSaveMail MapiSaveMail = {read=FMapiSaveMail};
	__property Mapi::TFNMapiSendDocuments MapiSendDocuments = {read=FMapiSendDocuments};
	__property Mapi::TFNMapiSendMail MapiSendMail = {read=FMapiSendMail};
};


#pragma option push -b-
enum TJclEmailRecipKind { rkOriginator, rkTO, rkCC, rkBCC };
#pragma option pop

class DELPHICLASS TJclEmailRecip;
class PASCALIMPLEMENTATION TJclEmailRecip : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::AnsiString FAddress;
	System::AnsiString FAddressType;
	TJclEmailRecipKind FKind;
	System::AnsiString FName;
	void __fastcall SetAddress(System::AnsiString Value);
	
protected:
	System::AnsiString __fastcall SortingName(void);
	
public:
	System::AnsiString __fastcall AddressAndName(void);
	__classmethod System::AnsiString __fastcall RecipKindToString(const TJclEmailRecipKind AKind);
	__property System::AnsiString AddressType = {read=FAddressType, write=FAddressType};
	__property System::AnsiString Address = {read=FAddress, write=SetAddress};
	__property TJclEmailRecipKind Kind = {read=FKind, write=FKind, nodefault};
	__property System::AnsiString Name = {read=FName, write=FName};
public:
	/* TObject.Create */ inline __fastcall TJclEmailRecip(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclEmailRecip(void) { }
	
};


class DELPHICLASS TJclEmailRecips;
class PASCALIMPLEMENTATION TJclEmailRecips : public Contnrs::TObjectList
{
	typedef Contnrs::TObjectList inherited;
	
public:
	TJclEmailRecip* operator[](int Index) { return Items[Index]; }
	
private:
	System::AnsiString FAddressesType;
	TJclEmailRecip* __fastcall GetItems(int Index);
	TJclEmailRecip* __fastcall GetOriginator(void);
	
public:
	HIDESBASE int __fastcall Add(const System::AnsiString Address, const System::AnsiString Name = "", const TJclEmailRecipKind Kind = (TJclEmailRecipKind)(0x1), const System::AnsiString AddressType = "");
	void __fastcall SortRecips(void);
	__property System::AnsiString AddressesType = {read=FAddressesType, write=FAddressesType};
	__property TJclEmailRecip* Items[int Index] = {read=GetItems/*, default*/};
	__property TJclEmailRecip* Originator = {read=GetOriginator};
public:
	/* TObjectList.Create */ inline __fastcall TJclEmailRecips(void)/* overload */ : Contnrs::TObjectList() { }
	
public:
	/* TList.Destroy */ inline __fastcall virtual ~TJclEmailRecips(void) { }
	
};


#pragma option push -b-
enum TJclEmailFindOption { foFifo, foUnreadOnly };
#pragma option pop

#pragma option push -b-
enum TJclEmailLogonOption { loLogonUI, loNewSession, loForceDownload };
#pragma option pop

#pragma option push -b-
enum TJclEmailReadOption { roAttachments, roHeaderOnly, roMarkAsRead };
#pragma option pop

typedef Set<TJclEmailFindOption, foFifo, foUnreadOnly>  TJclEmailFindOptions;

typedef Set<TJclEmailLogonOption, loLogonUI, loForceDownload>  TJclEmailLogonOptions;

typedef Set<TJclEmailReadOption, roAttachments, roMarkAsRead>  TJclEmailReadOptions;

struct TJclEmailReadMsg
{
	
public:
	System::AnsiString ConversationID;
	System::TDateTime DateReceived;
	System::AnsiString MessageType;
	unsigned Flags;
};


typedef DynamicArray<unsigned> TJclTaskWindowsList;

class DELPHICLASS TJclEmail;
class PASCALIMPLEMENTATION TJclEmail : public TJclSimpleMapi
{
	typedef TJclSimpleMapi inherited;
	
private:
	Jclansistrings::TJclAnsiStringList* FAttachments;
	System::AnsiString FBody;
	TJclEmailFindOptions FFindOptions;
	bool FHtmlBody;
	TJclEmailLogonOptions FLogonOptions;
	unsigned FParentWnd;
	bool FParentWndValid;
	TJclEmailReadMsg FReadMsg;
	TJclEmailRecips* FRecipients;
	System::AnsiString FSeedMessageID;
	unsigned FSessionHandle;
	System::AnsiString FSubject;
	TJclTaskWindowsList FTaskWindowList;
	Classes::TStringList* FAttachmentFiles;
	Jclansistrings::TJclAnsiStrings* __fastcall GetAttachments(void);
	Classes::TStrings* __fastcall GetAttachmentFiles(void);
	unsigned __fastcall GetParentWnd(void);
	bool __fastcall GetUserLogged(void);
	void __fastcall SetBody(const System::AnsiString Value);
	void __fastcall SetParentWnd(const unsigned Value);
	
protected:
	DYNAMIC void __fastcall BeforeUnloadClientLib(void);
	void __fastcall DecodeRecips(Mapi::PMapiRecipDesc RecipDesc, int Count);
	bool __fastcall InternalSendOrSave(bool Save, bool ShowDialog);
	unsigned __fastcall LogonOptionsToFlags(bool ShowDialog);
	
public:
	__fastcall TJclEmail(void);
	__fastcall virtual ~TJclEmail(void);
	bool __fastcall Address(const System::AnsiString Caption = "", int EditFields = 0x3);
	void __fastcall Clear(void);
	bool __fastcall Delete(const System::AnsiString MessageID);
	bool __fastcall FindFirstMessage(void);
	bool __fastcall FindNextMessage(void);
	void __fastcall LogOff(void);
	void __fastcall LogOn(const System::AnsiString ProfileName = "", const System::AnsiString Password = "");
	int __fastcall MessageReport(Classes::TStrings* Strings, int MaxWidth = 0x50, bool IncludeAddresses = false);
	bool __fastcall Read(const TJclEmailReadOptions Options = TJclEmailReadOptions() );
	bool __fastcall ResolveName(System::AnsiString &Name, System::AnsiString &Address, bool ShowDialog = false);
	void __fastcall RestoreTaskWindows(void);
	bool __fastcall Save(void);
	void __fastcall SaveTaskWindows(void);
	bool __fastcall Send(bool ShowDialog = true);
	void __fastcall SortAttachments(void);
	__property Jclansistrings::TJclAnsiStrings* Attachments = {read=GetAttachments};
	__property Classes::TStrings* AttachmentFiles = {read=GetAttachmentFiles};
	__property System::AnsiString Body = {read=FBody, write=SetBody};
	__property TJclEmailFindOptions FindOptions = {read=FFindOptions, write=FFindOptions, nodefault};
	__property bool HtmlBody = {read=FHtmlBody, write=FHtmlBody, nodefault};
	__property TJclEmailLogonOptions LogonOptions = {read=FLogonOptions, write=FLogonOptions, nodefault};
	__property unsigned ParentWnd = {read=GetParentWnd, write=SetParentWnd, nodefault};
	__property TJclEmailReadMsg ReadMsg = {read=FReadMsg};
	__property TJclEmailRecips* Recipients = {read=FRecipients};
	__property System::AnsiString SeedMessageID = {read=FSeedMessageID, write=FSeedMessageID};
	__property unsigned SessionHandle = {read=FSessionHandle, nodefault};
	__property System::AnsiString Subject = {read=FSubject, write=FSubject};
	__property bool UserLogged = {read=GetUserLogged, nodefault};
};


//-- var, const, procedure ---------------------------------------------------
#define MapiAddressTypeSMTP L"SMTP"
#define MapiAddressTypeFAX L"FAX"
#define MapiAddressTypeTLX L"TLX"
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE unsigned __fastcall MapiCheck(const unsigned Res, bool IgnoreUserAbort = true);
extern PACKAGE System::UnicodeString __fastcall MapiErrorMessage(const unsigned ErrorCode);
extern PACKAGE bool __fastcall JclSimpleSendMail(const System::AnsiString Recipient, const System::AnsiString Name, const System::AnsiString Subject, const System::AnsiString Body, const Sysutils::TFileName Attachment = L"", bool ShowDialog = true, unsigned ParentWND = (unsigned)(0x0), const System::AnsiString ProfileName = "", const System::AnsiString Password = "");
extern PACKAGE bool __fastcall JclSimpleSendFax(const System::AnsiString Recipient, const System::AnsiString Name, const System::AnsiString Subject, const System::AnsiString Body, const Sysutils::TFileName Attachment = L"", bool ShowDialog = true, unsigned ParentWND = (unsigned)(0x0), const System::AnsiString ProfileName = "", const System::AnsiString Password = "");
extern PACKAGE bool __fastcall JclSimpleBringUpSendMailDialog(const System::AnsiString Subject, const System::AnsiString Body, const Sysutils::TFileName Attachment = L"", unsigned ParentWND = (unsigned)(0x0), const System::AnsiString ProfileName = "", const System::AnsiString Password = "");

}	/* namespace Jclmapi */
using namespace Jclmapi;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclmapiHPP
