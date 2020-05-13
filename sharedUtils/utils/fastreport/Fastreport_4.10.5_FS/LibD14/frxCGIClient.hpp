// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxcgiclient.pas' rev: 21.00

#ifndef FrxcgiclientHPP
#define FrxcgiclientHPP

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
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxcgiclient
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxCGIClient;
class DELPHICLASS TfrxCGIClientFields;
class DELPHICLASS TfrxCGIServerFields;
class DELPHICLASS TfrxClientThread;
class PASCALIMPLEMENTATION TfrxCGIClient : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	bool FActive;
	Classes::TStrings* FAnswer;
	bool FBreaked;
	TfrxCGIClientFields* FClientFields;
	Classes::TStrings* FErrors;
	Classes::TStrings* FHeader;
	System::UnicodeString FHost;
	int FPort;
	System::UnicodeString FProxyHost;
	int FProxyPort;
	int FRetryCount;
	int FRetryTimeOut;
	TfrxCGIServerFields* FServerFields;
	Classes::TMemoryStream* FStream;
	Classes::TMemoryStream* FTempStream;
	TfrxClientThread* FThread;
	int FTimeOut;
	System::UnicodeString F_REQUEST_METHOD;
	System::UnicodeString F_REMOTE_USER;
	System::UnicodeString F_QUERY_STRING;
	System::UnicodeString F_REMOTE_HOST;
	System::UnicodeString F_SERVER_NAME;
	System::UnicodeString F_SERVER_PORT;
	System::UnicodeString F_HTTP_REFERER;
	System::UnicodeString F_HTTP_USER_AGENT;
	System::UnicodeString F_HTTP_AUTHORIZATION;
	System::UnicodeString F_HTTP_COOKIE;
	System::UnicodeString F_CGI_FILENAME;
	System::UnicodeString F_CONTENT_LENGTH;
	System::UnicodeString F_CONTENT;
	Classes::THandleStream* OutStream;
	bool IsHTML;
	System::UnicodeString FPostData;
	System::UnicodeString __fastcall GetCurrentUserName(void);
	void __fastcall DoConnect(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall DoDisconnect(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall DoError(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket, Scktcomp::TErrorEvent ErrorEvent, int &ErrorCode);
	void __fastcall DoRead(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall SetActive(const bool Value);
	void __fastcall SetClientFields(const TfrxCGIClientFields* Value);
	void __fastcall SetServerFields(const TfrxCGIServerFields* Value);
	void __fastcall PrepareCGIStream(Classes::TStream* IStream, Classes::TStream* OStream);
	void __fastcall ReplaceCGIReps(System::UnicodeString Sign1, System::UnicodeString Sign2, Classes::TStream* IStream, Classes::TStream* OStream);
	void __fastcall DeleteCGIReps(System::UnicodeString Sign, Classes::TStream* IStream, Classes::TStream* OStream);
	void __fastcall InsertCGIHref(System::AnsiString Sign, Classes::TStream* IStream, Classes::TStream* OStream);
	
public:
	Classes::TThread* ParentThread;
	unsigned StreamSize;
	__fastcall TfrxCGIClient(void);
	__fastcall virtual ~TfrxCGIClient(void);
	void __fastcall Connect(void);
	void __fastcall Disconnect(void);
	void __fastcall Open(void);
	void __fastcall Close(void);
	__property Classes::TStrings* Answer = {read=FAnswer, write=FAnswer};
	__property bool Breaked = {read=FBreaked, nodefault};
	__property Classes::TStrings* Errors = {read=FErrors, write=FErrors};
	__property Classes::TStrings* Header = {read=FHeader, write=FHeader};
	__property Classes::TMemoryStream* Stream = {read=FStream, write=FStream};
	__property TfrxCGIClientFields* ClientFields = {read=FClientFields, write=SetClientFields};
	__property TfrxCGIServerFields* ServerFields = {read=FServerFields, write=SetServerFields};
	__property bool Active = {read=FActive, write=SetActive, nodefault};
	__property System::UnicodeString Host = {read=FHost, write=FHost};
	__property int Port = {read=FPort, write=FPort, nodefault};
	__property System::UnicodeString ProxyHost = {read=FProxyHost, write=FProxyHost};
	__property int ProxyPort = {read=FProxyPort, write=FProxyPort, nodefault};
	__property int RetryCount = {read=FRetryCount, write=FRetryCount, nodefault};
	__property int RetryTimeOut = {read=FRetryTimeOut, write=FRetryTimeOut, nodefault};
	__property int TimeOut = {read=FTimeOut, write=FTimeOut, nodefault};
	__property System::UnicodeString PostData = {read=FPostData, write=FPostData};
};


class PASCALIMPLEMENTATION TfrxCGIServerFields : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	int FAnswerCode;
	System::UnicodeString FContentEncoding;
	int FContentLength;
	System::UnicodeString FLocation;
	System::UnicodeString FSessionId;
	
public:
	__fastcall TfrxCGIServerFields(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property int AnswerCode = {read=FAnswerCode, write=FAnswerCode, nodefault};
	__property System::UnicodeString ContentEncoding = {read=FContentEncoding, write=FContentEncoding};
	__property int ContentLength = {read=FContentLength, write=FContentLength, nodefault};
	__property System::UnicodeString Location = {read=FLocation, write=FLocation};
	__property System::UnicodeString SessionId = {read=FSessionId, write=FSessionId};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxCGIServerFields(void) { }
	
};


class PASCALIMPLEMENTATION TfrxCGIClientFields : public Classes::TPersistent
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
	
public:
	__fastcall TfrxCGIClientFields(void);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__property System::UnicodeString AcceptEncoding = {read=FAcceptEncoding, write=FAcceptEncoding};
	__property System::UnicodeString FileName = {read=FName, write=FName};
	__property System::UnicodeString Host = {read=FHost, write=FHost};
	__property System::UnicodeString HTTPVer = {read=FHTTPVer, write=FHTTPVer};
	__property System::UnicodeString Login = {read=FLogin, write=FLogin};
	__property System::UnicodeString Password = {read=FPassword, write=FPassword};
	__property Frxserverutils::TfrxHTTPQueryType QueryType = {read=FQueryType, write=FQueryType, nodefault};
	__property System::UnicodeString Referer = {read=FReferer, write=FReferer};
	__property System::UnicodeString UserAgent = {read=FUserAgent, write=FUserAgent};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxCGIClientFields(void) { }
	
};


class PASCALIMPLEMENTATION TfrxClientThread : public Classes::TThread
{
	typedef Classes::TThread inherited;
	
protected:
	TfrxCGIClient* FClient;
	void __fastcall DoOpen(void);
	virtual void __fastcall Execute(void);
	
public:
	Scktcomp::TClientSocket* FSocket;
	__fastcall TfrxClientThread(TfrxCGIClient* Client);
	__fastcall virtual ~TfrxClientThread(void);
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxcgiclient */
using namespace Frxcgiclient;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxcgiclientHPP
