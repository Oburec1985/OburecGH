// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxhttpclient.pas' rev: 21.00

#ifndef FrxhttpclientHPP
#define FrxhttpclientHPP

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
#include <Frxserverutils.hpp>	// Pascal unit
#include <Frxnetutils.hpp>	// Pascal unit
#include <Frxgzip.hpp>	// Pascal unit
#include <Frxmd5.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxhttpclient
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxHTTPClient;
class DELPHICLASS TfrxHTTPClientFields;
class DELPHICLASS TfrxHTTPServerFields;
class DELPHICLASS TfrxClientThread;
class PASCALIMPLEMENTATION TfrxHTTPClient : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	bool FActive;
	Classes::TStrings* FAnswer;
	bool FBreaked;
	TfrxHTTPClientFields* FClientFields;
	Classes::TStrings* FErrors;
	Classes::TStrings* FHeader;
	System::UnicodeString FHost;
	bool FMIC;
	int FPort;
	System::UnicodeString FProxyHost;
	int FProxyPort;
	int FRetryCount;
	int FRetryTimeOut;
	TfrxHTTPServerFields* FServerFields;
	Classes::TMemoryStream* FStream;
	Classes::TMemoryStream* FTempStream;
	TfrxClientThread* FThread;
	int FTimeOut;
	System::UnicodeString FProxyLogin;
	System::UnicodeString FProxyPassword;
	void __fastcall DoConnect(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall DoDisconnect(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall DoError(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket, Scktcomp::TErrorEvent ErrorEvent, int &ErrorCode);
	void __fastcall DoRead(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall SetActive(const bool Value);
	void __fastcall SetClientFields(const TfrxHTTPClientFields* Value);
	void __fastcall SetServerFields(const TfrxHTTPServerFields* Value);
	
public:
	Classes::TThread* ParentThread;
	unsigned StreamSize;
	__fastcall virtual TfrxHTTPClient(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxHTTPClient(void);
	void __fastcall Connect(void);
	void __fastcall Disconnect(void);
	void __fastcall Open(void);
	void __fastcall Close(void);
	__property Classes::TStrings* Answer = {read=FAnswer, write=FAnswer};
	__property bool Breaked = {read=FBreaked, nodefault};
	__property Classes::TStrings* Errors = {read=FErrors, write=FErrors};
	__property Classes::TStrings* Header = {read=FHeader, write=FHeader};
	__property Classes::TMemoryStream* Stream = {read=FStream, write=FStream};
	
__published:
	__property bool Active = {read=FActive, write=SetActive, nodefault};
	__property TfrxHTTPClientFields* ClientFields = {read=FClientFields, write=SetClientFields};
	__property System::UnicodeString Host = {read=FHost, write=FHost};
	__property bool MIC = {read=FMIC, write=FMIC, nodefault};
	__property int Port = {read=FPort, write=FPort, nodefault};
	__property System::UnicodeString ProxyHost = {read=FProxyHost, write=FProxyHost};
	__property int ProxyPort = {read=FProxyPort, write=FProxyPort, nodefault};
	__property System::UnicodeString ProxyLogin = {read=FProxyLogin, write=FProxyLogin};
	__property System::UnicodeString ProxyPassword = {read=FProxyPassword, write=FProxyPassword};
	__property int RetryCount = {read=FRetryCount, write=FRetryCount, nodefault};
	__property int RetryTimeOut = {read=FRetryTimeOut, write=FRetryTimeOut, nodefault};
	__property TfrxHTTPServerFields* ServerFields = {read=FServerFields, write=SetServerFields};
	__property int TimeOut = {read=FTimeOut, write=FTimeOut, nodefault};
};


class PASCALIMPLEMENTATION TfrxHTTPServerFields : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	int FAnswerCode;
	System::UnicodeString FContentEncoding;
	System::UnicodeString FContentMD5;
	int FContentLength;
	System::UnicodeString FLocation;
	System::UnicodeString FSessionId;
	System::UnicodeString FCookie;
	
public:
	__fastcall TfrxHTTPServerFields(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property int AnswerCode = {read=FAnswerCode, write=FAnswerCode, nodefault};
	__property System::UnicodeString ContentEncoding = {read=FContentEncoding, write=FContentEncoding};
	__property System::UnicodeString ContentMD5 = {read=FContentMD5, write=FContentMD5};
	__property int ContentLength = {read=FContentLength, write=FContentLength, nodefault};
	__property System::UnicodeString Location = {read=FLocation, write=FLocation};
	__property System::UnicodeString SessionId = {read=FSessionId, write=FSessionId};
	__property System::UnicodeString Cookie = {read=FCookie, write=FCookie};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxHTTPServerFields(void) { }
	
};


class PASCALIMPLEMENTATION TfrxHTTPClientFields : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	System::UnicodeString FAcceptEncoding;
	System::UnicodeString FHost;
	System::UnicodeString FHTTPVer;
	System::UnicodeString FLogin;
	System::UnicodeString FName;
	System::UnicodeString FPassword;
	Frxserverutils::TfrxHTTPQueryType FQueryType;
	System::UnicodeString FReferer;
	System::UnicodeString FUserAgent;
	System::UnicodeString FVariables;
	System::UnicodeString FAccept;
	System::UnicodeString FAcceptCharset;
	System::UnicodeString FContentType;
	System::UnicodeString FRange;
	
public:
	__fastcall TfrxHTTPClientFields(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property System::UnicodeString AcceptEncoding = {read=FAcceptEncoding, write=FAcceptEncoding};
	__property System::UnicodeString Accept = {read=FAccept, write=FAccept};
	__property System::UnicodeString AcceptCharset = {read=FAcceptCharset, write=FAcceptCharset};
	__property System::UnicodeString FileName = {read=FName, write=FName};
	__property System::UnicodeString Host = {read=FHost, write=FHost};
	__property System::UnicodeString HTTPVer = {read=FHTTPVer, write=FHTTPVer};
	__property System::UnicodeString Login = {read=FLogin, write=FLogin};
	__property System::UnicodeString Password = {read=FPassword, write=FPassword};
	__property Frxserverutils::TfrxHTTPQueryType QueryType = {read=FQueryType, write=FQueryType, nodefault};
	__property System::UnicodeString Referer = {read=FReferer, write=FReferer};
	__property System::UnicodeString UserAgent = {read=FUserAgent, write=FUserAgent};
	__property System::UnicodeString Variables = {read=FVariables, write=FVariables};
	__property System::UnicodeString ContentType = {read=FContentType, write=FContentType};
	__property System::UnicodeString Range = {read=FRange, write=FRange};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxHTTPClientFields(void) { }
	
};


class PASCALIMPLEMENTATION TfrxClientThread : public Classes::TThread
{
	typedef Classes::TThread inherited;
	
protected:
	TfrxHTTPClient* FClient;
	void __fastcall DoOpen(void);
	virtual void __fastcall Execute(void);
	
public:
	Scktcomp::TClientSocket* FSocket;
	__fastcall TfrxClientThread(TfrxHTTPClient* Client);
	__fastcall virtual ~TfrxClientThread(void);
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxhttpclient */
using namespace Frxhttpclient;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxhttpclientHPP
