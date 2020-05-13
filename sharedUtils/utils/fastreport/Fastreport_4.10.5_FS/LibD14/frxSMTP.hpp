// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxsmtp.pas' rev: 21.00

#ifndef FrxsmtpHPP
#define FrxsmtpHPP

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
#include <Scktcomp.hpp>	// Pascal unit
#include <Frxnetutils.hpp>	// Pascal unit
#include <Frxutils.hpp>	// Pascal unit
#include <Frxprogress.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Frxmd5.hpp>	// Pascal unit
#include <Frxunicodeutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxsmtp
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxSMTPClient;
class DELPHICLASS TfrxSMTPClientThread;
class PASCALIMPLEMENTATION TfrxSMTPClient : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	bool FActive;
	bool FBreaked;
	Classes::TStrings* FErrors;
	System::UnicodeString FHost;
	int FPort;
	TfrxSMTPClientThread* FThread;
	int FTimeOut;
	System::UnicodeString FPassword;
	System::WideString FMailTo;
	System::UnicodeString FUser;
	Classes::TStringList* FMailFiles;
	System::WideString FMailFrom;
	System::WideString FMailSubject;
	System::WideString FMailText;
	System::AnsiString FAnswer;
	bool FAccepted;
	System::UnicodeString FAuth;
	int FCode;
	bool FSending;
	Frxprogress::TfrxProgress* FProgress;
	bool FShowProgress;
	System::UnicodeString FLogFile;
	Classes::TStringList* FLog;
	Classes::TStringList* FAnswerList;
	bool F200Flag;
	bool F210Flag;
	bool F215Flag;
	System::WideString FOrganization;
	System::WideString FMailCc;
	System::WideString FMailBcc;
	Classes::TStringList* FRcptList;
	bool FConfirmReading;
	void __fastcall DoConnect(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall DoDisconnect(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall DoError(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket, Scktcomp::TErrorEvent ErrorEvent, int &ErrorCode);
	void __fastcall DoRead(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall SetActive(const bool Value);
	void __fastcall AddLogIn(const System::UnicodeString s);
	void __fastcall AddLogOut(const System::UnicodeString s);
	System::UnicodeString __fastcall DomainByEmail(const System::UnicodeString addr);
	System::AnsiString __fastcall UnicodeField(const System::WideString Str);
	System::AnsiString __fastcall UnicodeString(const System::WideString Str);
	System::UnicodeString __fastcall GetEmailAddress(const System::UnicodeString Str);
	void __fastcall PrepareRcpt(void);
	
public:
	__fastcall virtual TfrxSMTPClient(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxSMTPClient(void);
	void __fastcall Connect(void);
	void __fastcall Disconnect(void);
	void __fastcall Open(void);
	void __fastcall Close(void);
	__property bool Breaked = {read=FBreaked, nodefault};
	__property Classes::TStrings* Errors = {read=FErrors, write=FErrors};
	__property System::UnicodeString LogFile = {read=FLogFile, write=FLogFile};
	
__published:
	__property bool Active = {read=FActive, write=SetActive, nodefault};
	__property System::UnicodeString Host = {read=FHost, write=FHost};
	__property int Port = {read=FPort, write=FPort, nodefault};
	__property int TimeOut = {read=FTimeOut, write=FTimeOut, nodefault};
	__property System::UnicodeString User = {read=FUser, write=FUser};
	__property System::UnicodeString Password = {read=FPassword, write=FPassword};
	__property System::WideString MailFrom = {read=FMailFrom, write=FMailFrom};
	__property System::WideString MailTo = {read=FMailTo, write=FMailTo};
	__property System::WideString MailCc = {read=FMailCc, write=FMailCc};
	__property System::WideString MailBcc = {read=FMailBcc, write=FMailBcc};
	__property System::WideString MailSubject = {read=FMailSubject, write=FMailSubject};
	__property System::WideString MailText = {read=FMailText, write=FMailText};
	__property Classes::TStringList* MailFiles = {read=FMailFiles, write=FMailFiles};
	__property bool ShowProgress = {read=FShowProgress, write=FShowProgress, nodefault};
	__property System::WideString Organization = {read=FOrganization, write=FOrganization};
	__property bool ConfirmReading = {read=FConfirmReading, write=FConfirmReading, nodefault};
};


class PASCALIMPLEMENTATION TfrxSMTPClientThread : public Classes::TThread
{
	typedef Classes::TThread inherited;
	
protected:
	TfrxSMTPClient* FClient;
	void __fastcall DoOpen(void);
	virtual void __fastcall Execute(void);
	
public:
	Scktcomp::TClientSocket* FSocket;
	__fastcall TfrxSMTPClientThread(TfrxSMTPClient* Client);
	__fastcall virtual ~TfrxSMTPClientThread(void);
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxsmtp */
using namespace Frxsmtp;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxsmtpHPP
