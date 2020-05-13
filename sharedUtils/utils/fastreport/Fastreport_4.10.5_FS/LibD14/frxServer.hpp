// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxserver.pas' rev: 21.00

#ifndef FrxserverHPP
#define FrxserverHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Scktcomp.hpp>	// Pascal unit
#include <Registry.hpp>	// Pascal unit
#include <Winsock.hpp>	// Pascal unit
#include <Frxvariables.hpp>	// Pascal unit
#include <Frxgzip.hpp>	// Pascal unit
#include <Frxserverlog.hpp>	// Pascal unit
#include <Frxserversessionmanager.hpp>	// Pascal unit
#include <Frxserverstat.hpp>	// Pascal unit
#include <Frxserverreports.hpp>	// Pascal unit
#include <Frxservervariables.hpp>	// Pascal unit
#include <Frxserverssi.hpp>	// Pascal unit
#include <Frxserverutils.hpp>	// Pascal unit
#include <Frxnetutils.hpp>	// Pascal unit
#include <Frxmd5.hpp>	// Pascal unit
#include <Frxservercache.hpp>	// Pascal unit
#include <Frxserverreportslist.hpp>	// Pascal unit
#include <Frxunicodeutils.hpp>	// Pascal unit
#include <Frxusers.hpp>	// Pascal unit
#include <Frxserverclient.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Frxserverconfig.hpp>	// Pascal unit
#include <Frxservertemplates.hpp>	// Pascal unit
#include <Frxserverprinter.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxserver
{
//-- type declarations -------------------------------------------------------
typedef void __fastcall (__closure *TfrxServerGetReportEvent)(const System::UnicodeString ReportName, Frxclass::TfrxReport* Report, System::UnicodeString User = L"");

typedef void __fastcall (__closure *TfrxServerGetVariablesEvent)(const System::UnicodeString ReportName, Frxvariables::TfrxVariables* Variables, System::UnicodeString User = L"");

typedef void __fastcall (__closure *TfrxServerAfterBuildReport)(const System::UnicodeString ReportName, Frxvariables::TfrxVariables* Variables, System::UnicodeString User = L"");

struct TSecHandle;
typedef TSecHandle *PSecHandle;

struct TSecHandle
{
	
public:
	unsigned dwLower;
	unsigned dwUpper;
};


typedef TSecHandle TCredHandle;

typedef TSecHandle *PCredHandle;

typedef TSecHandle *PCtxtHandle;

typedef TSecHandle TCtxtHandle;

struct TSecBuffer;
typedef TSecBuffer *PSecBuffer;

struct TSecBuffer
{
	
public:
	unsigned cbBuffer;
	unsigned BufferType;
	void *pvBuffer;
};


struct TSecBufferDesc;
typedef TSecBufferDesc *PSecBufferDesc;

struct TSecBufferDesc
{
	
public:
	unsigned ulVersion;
	unsigned cBuffers;
	TSecBuffer *pBuffers;
};


typedef System::Currency *PTimeStamp;

typedef System::Currency TTimeStamp;

struct TSecPkgInfo;
typedef TSecPkgInfo *PSecPkgInfo;

struct TSecPkgInfo
{
	
public:
	unsigned fCapabilities;
	System::Word wVersion;
	System::Word wRPCID;
	unsigned cbMaxToken;
	System::WideChar *Name;
	System::WideChar *Comment;
};


class DELPHICLASS TfrxReportServer;
class DELPHICLASS TfrxHTTPServer;
class DELPHICLASS TfrxServerGuard;
class DELPHICLASS TfrxServerData;
class PASCALIMPLEMENTATION TfrxReportServer : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	bool FActive;
	Classes::TStrings* FAllow;
	Frxserverconfig::TfrxServerConfig* FConfig;
	Classes::TStrings* FDeny;
	TfrxServerGetReportEvent FGetReport;
	bool FPDFPrint;
	Classes::TStrings* FTotals;
	Frxservervariables::TfrxServerVariables* FVariables;
	TfrxHTTPServer* FWebServer;
	TfrxServerGetVariablesEvent FGetVariables;
	TfrxServerAfterBuildReport FBuildReport;
	bool FSocketOpen;
	System::UnicodeString FConfigFileName;
	TfrxServerGuard* FGuard;
	bool FPrint;
	Classes::TStrings* __fastcall GetTotals(void);
	void __fastcall SetActive(const bool Value);
	void __fastcall SetConfig(const Frxserverconfig::TfrxServerConfig* Value);
	void __fastcall StatToVar(void);
	void __fastcall Initialize(void);
	
public:
	__fastcall virtual TfrxReportServer(Classes::TComponent* AOwner);
	__fastcall TfrxReportServer(const System::UnicodeString Folder, const bool Socket);
	__fastcall virtual ~TfrxReportServer(void);
	void __fastcall Open(void);
	void __fastcall Close(void);
	void __fastcall Get(TfrxServerData* Data);
	void __fastcall LoadConfigs(void);
	__property Classes::TStrings* Totals = {read=GetTotals};
	__property Frxservervariables::TfrxServerVariables* Variables = {read=FVariables};
	
__published:
	__property Frxserverconfig::TfrxServerConfig* Configuration = {read=FConfig, write=SetConfig};
	__property bool Active = {read=FActive, write=SetActive, nodefault};
	__property Classes::TStrings* AllowIP = {read=FAllow, write=FAllow};
	__property Classes::TStrings* DenyIP = {read=FDeny, write=FDeny};
	__property bool PrintPDF = {read=FPDFPrint, write=FPDFPrint, nodefault};
	__property bool Print = {read=FPrint, write=FPrint, nodefault};
	__property TfrxServerGetReportEvent OnGetReport = {read=FGetReport, write=FGetReport};
	__property TfrxServerGetVariablesEvent OnGetVariables = {read=FGetVariables, write=FGetVariables};
	__property TfrxServerAfterBuildReport OnAfterBuildReport = {read=FBuildReport, write=FBuildReport};
	__property bool SocketOpen = {read=FSocketOpen, write=FSocketOpen, nodefault};
	__property TfrxHTTPServer* WebServer = {read=FWebServer};
};


class PASCALIMPLEMENTATION TfrxHTTPServer : public Scktcomp::TServerSocket
{
	typedef Scktcomp::TServerSocket inherited;
	
private:
	System::UnicodeString FBasePath;
	bool FGzip;
	System::UnicodeString FMainDocument;
	bool FNoCacheHeader;
	TfrxReportServer* FParentReportServer;
	System::UnicodeString FReportPath;
	int FSocketTimeOut;
	void __fastcall ClientAccept(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall ClientDisconnect(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket);
	void __fastcall ClientError(System::TObject* Sender, Scktcomp::TCustomWinSocket* Socket, Scktcomp::TErrorEvent ErrorEvent, int &ErrorCode);
	void __fastcall GetThread(System::TObject* Sender, Scktcomp::TServerClientWinSocket* ClientSocket, Scktcomp::TServerClientThread* &SocketThread);
	
public:
	__fastcall virtual TfrxHTTPServer(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxHTTPServer(void);
	
__published:
	__property System::UnicodeString BasePath = {read=FBasePath, write=FBasePath};
	__property bool Gzip = {read=FGzip, write=FGzip, nodefault};
	__property System::UnicodeString MainDocument = {read=FMainDocument, write=FMainDocument};
	__property bool NoCacheHeader = {read=FNoCacheHeader, write=FNoCacheHeader, nodefault};
	__property TfrxReportServer* ParentReportServer = {read=FParentReportServer, write=FParentReportServer};
	__property System::UnicodeString ReportPath = {read=FReportPath, write=FReportPath};
	__property int SocketTimeOut = {read=FSocketTimeOut, write=FSocketTimeOut, nodefault};
};


class DELPHICLASS TfrxServerSession;
class PASCALIMPLEMENTATION TfrxServerSession : public Scktcomp::TServerClientThread
{
	typedef Scktcomp::TServerClientThread inherited;
	
private:
	bool FAuthNeeded;
	bool FDialog;
	System::AnsiString FDialogSessionId;
	int FErrorCode;
	System::AnsiString FErrorText;
	Frxserverutils::TfrxServerFormat FFormat;
	bool FGzip;
	System::AnsiString FHeader;
	System::AnsiString FHost;
	System::AnsiString FHTTPVersion;
	bool FIsReport;
	bool FKeepAlive;
	System::AnsiString FMethod;
	System::AnsiString FMIMEType;
	bool FMultipage;
	System::AnsiString FName;
	System::AnsiString FGroup;
	bool FNoCacheHeader;
	bool FPageNavigator;
	System::UnicodeString FPageRange;
	TfrxHTTPServer* FParentHTTPServer;
	TfrxReportServer* FParentReportServer;
	bool FRedirect;
	System::AnsiString FReferer;
	System::UnicodeString FRemoteIP;
	Classes::TStringList* FReplyBody;
	Classes::TStringList* FReplyHeader;
	Frxserverreports::TfrxReportSession* FRepSession;
	System::UnicodeString FResultPage;
	Classes::TStringList* FServerReplyData;
	System::AnsiString FSessionId;
	Frxserversessionmanager::TfrxSessionItem* FSessionItem;
	int FSize;
	System::AnsiString FUserAgent;
	Frxvariables::TfrxVariables* FVariables;
	Classes::TMemoryStream* FStream;
	System::TDateTime FFileDate;
	System::UnicodeString FCacheId;
	System::UnicodeString FPrn;
	bool FBrowserPrn;
	System::UnicodeString FLogin;
	System::AnsiString FCookie;
	System::UnicodeString FPassword;
	System::UnicodeString FReportMessage;
	System::AnsiString FReturnData;
	Classes::TStringList* FInParams;
	Classes::TStringList* FOutParams;
	TfrxServerData* FData;
	bool FActive;
	bool FAuthInProgress;
	System::AnsiString FAuthResponse;
	bool FAuthFinished;
	bool FAuthNewConv;
	int FMaxTokenSize;
	TSecHandle FCredHandle;
	System::Currency FExpire;
	unsigned FToken;
	TSecHandle FContextHandle;
	System::UnicodeString FAuthType;
	Frxservervariables::TfrxServerVariables* FLocalVariables;
	bool __fastcall InitAuth(const System::UnicodeString SecPackageName);
	bool __fastcall ProcessAuthRequest(System::AnsiString AuthRequest, bool NewConversation, System::AnsiString &AuthResponse, TSecHandle &ContextHandle, bool &AuthFinished);
	void __fastcall FinalAuth(void);
	unsigned __fastcall GetCurrentUserToken(void);
	bool __fastcall CheckBadPath(void);
	bool __fastcall CheckDeflate(System::UnicodeString FileName);
	bool __fastcall CheckSSI(System::UnicodeString FileName);
	System::AnsiString __fastcall ParseHeaderField(System::AnsiString Field);
	System::UnicodeString __fastcall ParseParam(System::UnicodeString S);
	void __fastcall CheckAuth(void);
	void __fastcall CloseSession(void);
	void __fastcall CreateReplyHTTPData(void);
	void __fastcall ErrorLog(void);
	void __fastcall MakeServerReply(void);
	void __fastcall ParseHTTPHeader(void);
	void __fastcall UpdateLocalVariables(void);
	void __fastcall UpdateSessionFName(void);
	void __fastcall WriteLogs(void);
	void __fastcall DoGetVariables(void);
	void __fastcall AddOutData(const System::UnicodeString Name, const System::UnicodeString Value);
	
public:
	__fastcall TfrxServerSession(bool CreateSuspended, Scktcomp::TServerClientWinSocket* ASocket);
	__fastcall virtual ~TfrxServerSession(void);
	virtual void __fastcall ClientExecute(void);
	void __fastcall PrepareReportQuery(void);
	__property bool NoCacheHeader = {read=FNoCacheHeader, write=FNoCacheHeader, nodefault};
	__property TfrxHTTPServer* ParentHTTPServer = {read=FParentHTTPServer, write=FParentHTTPServer};
	__property TfrxReportServer* ParentReportServer = {read=FParentReportServer, write=FParentReportServer};
	__property System::AnsiString SessionId = {read=FSessionId, write=FSessionId};
	__property Frxserversessionmanager::TfrxSessionItem* SessionItem = {read=FSessionItem, write=FSessionItem};
	__property System::UnicodeString Login = {read=FLogin};
	__property System::UnicodeString Password = {read=FPassword};
	__property TfrxServerData* Data = {read=FData, write=FData};
	__property bool Active = {read=FActive, write=FActive, nodefault};
	__property Frxservervariables::TfrxServerVariables* LocalVariables = {read=FLocalVariables};
};


class PASCALIMPLEMENTATION TfrxServerData : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	int FErrorCode;
	Classes::TStringList* FInParams;
	Classes::TStringList* FOutParams;
	Classes::TMemoryStream* FStream;
	System::UnicodeString FFileName;
	System::UnicodeString FHeader;
	System::UnicodeString FRepHeader;
	System::UnicodeString FHTTPVer;
	System::TDateTime FLastMod;
	System::TDateTime FExpires;
	
public:
	__fastcall TfrxServerData(void);
	__fastcall virtual ~TfrxServerData(void);
	void __fastcall Assign(TfrxServerData* Source);
	__property Classes::TStringList* InParams = {read=FInParams};
	__property Classes::TStringList* OutParams = {read=FOutParams};
	__property int ErrorCode = {read=FErrorCode, write=FErrorCode, nodefault};
	__property Classes::TMemoryStream* Stream = {read=FStream};
	__property System::UnicodeString FileName = {read=FFileName, write=FFileName};
	__property System::UnicodeString Header = {read=FHeader, write=FHeader};
	__property System::UnicodeString RepHeader = {read=FRepHeader, write=FRepHeader};
	__property System::UnicodeString HTTPVer = {read=FHTTPVer, write=FHTTPVer};
	__property System::TDateTime Expires = {read=FExpires, write=FExpires};
	__property System::TDateTime LastMod = {read=FLastMod, write=FLastMod};
};


class PASCALIMPLEMENTATION TfrxServerGuard : public Classes::TThread
{
	typedef Classes::TThread inherited;
	
private:
	int FTimeOut;
	TfrxReportServer* FServer;
	int FListTimeOut;
	void __fastcall DoLoadConf(void);
	
protected:
	virtual void __fastcall Execute(void);
	
public:
	__fastcall TfrxServerGuard(TfrxReportServer* Server);
	__fastcall virtual ~TfrxServerGuard(void);
	__property int TimeOut = {read=FTimeOut, write=FTimeOut, nodefault};
	__property int ListTimeOut = {read=FListTimeOut, write=FListTimeOut, nodefault};
};


//-- var, const, procedure ---------------------------------------------------
static const Word MAX_IE_GZIP = 0x1000;
#define SERVER_NAME L"FastReport Server"
#define SERVER_VERSION L"2.2.0"
#define SERVER_DATA L""
#define SID_SIGN L"sid_f"

}	/* namespace Frxserver */
using namespace Frxserver;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxserverHPP
