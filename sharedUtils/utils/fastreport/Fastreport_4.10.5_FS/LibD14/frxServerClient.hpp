// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxserverclient.pas' rev: 21.00

#ifndef FrxserverclientHPP
#define FrxserverclientHPP

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
#include <Forms.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Scktcomp.hpp>	// Pascal unit
#include <Frxvariables.hpp>	// Pascal unit
#include <Frxgzip.hpp>	// Pascal unit
#include <Frxhttpclient.hpp>	// Pascal unit
#include <Frxmd5.hpp>	// Pascal unit
#include <Frxserverutils.hpp>	// Pascal unit
#include <Frxnetutils.hpp>	// Pascal unit
#include <Frxunicodeutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxserverclient
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxServerConnection;
class PASCALIMPLEMENTATION TfrxServerConnection : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	System::UnicodeString FHost;
	System::UnicodeString FLogin;
	bool FMIC;
	System::UnicodeString FPassword;
	int FPort;
	int FProxyPort;
	System::UnicodeString FProxyHost;
	int FRetryCount;
	unsigned FRetryTimeout;
	unsigned FTimeout;
	System::UnicodeString FPath;
	bool FCompression;
	void __fastcall SetPath(const System::UnicodeString Value);
	
public:
	__fastcall virtual TfrxServerConnection(Classes::TComponent* AOwner);
	
__published:
	__property bool Compression = {read=FCompression, write=FCompression, nodefault};
	__property System::UnicodeString Host = {read=FHost, write=FHost};
	__property System::UnicodeString Login = {read=FLogin, write=FLogin};
	__property bool MIC = {read=FMIC, write=FMIC, nodefault};
	__property System::UnicodeString Password = {read=FPassword, write=FPassword};
	__property int Port = {read=FPort, write=FPort, nodefault};
	__property System::UnicodeString ProxyHost = {read=FProxyHost, write=FProxyHost};
	__property int ProxyPort = {read=FProxyPort, write=FProxyPort, nodefault};
	__property int RetryCount = {read=FRetryCount, write=FRetryCount, nodefault};
	__property unsigned RetryTimeout = {read=FRetryTimeout, write=FRetryTimeout, nodefault};
	__property unsigned Timeout = {read=FTimeout, write=FTimeout, nodefault};
	__property System::UnicodeString Path = {read=FPath, write=SetPath};
public:
	/* TComponent.Destroy */ inline __fastcall virtual ~TfrxServerConnection(void) { }
	
};


class DELPHICLASS TfrxReportClient;
class PASCALIMPLEMENTATION TfrxReportClient : public Frxclass::TfrxReport
{
	typedef Frxclass::TfrxReport inherited;
	
private:
	Frxhttpclient::TfrxHTTPClient* FClient;
	TfrxServerConnection* FConnection;
	System::UnicodeString FReportName;
	System::UnicodeString FSessionId;
	bool FSecondPass;
	void __fastcall FillPreviewPages(void);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	
public:
	__fastcall virtual TfrxReportClient(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxReportClient(void);
	HIDESBASE bool __fastcall PrepareReport(void);
	HIDESBASE void __fastcall LoadFromFile(System::UnicodeString FileName);
	HIDESBASE void __fastcall ShowReport(void);
	System::UnicodeString __fastcall GetServerVariable(const System::UnicodeString VariableName);
	void __fastcall Close(void);
	__property Frxhttpclient::TfrxHTTPClient* Client = {read=FClient, write=FClient};
	
__published:
	__property TfrxServerConnection* Connection = {read=FConnection, write=FConnection};
	__property System::UnicodeString ReportName = {read=FReportName, write=FReportName};
public:
	/* TfrxComponent.DesignCreate */ inline __fastcall virtual TfrxReportClient(Classes::TComponent* AOwner, System::Word Flags) : Frxclass::TfrxReport(AOwner, Flags) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxserverclient */
using namespace Frxserverclient;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxserverclientHPP
