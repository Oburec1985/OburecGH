// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxserverconfig.pas' rev: 21.00

#ifndef FrxserverconfigHPP
#define FrxserverconfigHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Syncobjs.hpp>	// Pascal unit
#include <Frxxml.hpp>	// Pascal unit
#include <Frxutils.hpp>	// Pascal unit
#include <Frxserverutils.hpp>	// Pascal unit
#include <Inifiles.hpp>	// Pascal unit
#include <Frxserverlog.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxserverconfig
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxConfig;
class PASCALIMPLEMENTATION TfrxConfig : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Frxxml::TfrxXMLDocument* FXML;
	Classes::TStrings* FErrors;
	Classes::TStringList* FLines;
	Syncobjs::TCriticalSection* FCS;
	System::UnicodeString FFileName;
	System::UnicodeString FConfigFolder;
	void __fastcall UpdateLines(void);
	void __fastcall AddLine(const System::UnicodeString Name, const System::UnicodeString Value, Frxxml::TfrxXMLItem* XMLItem);
	int __fastcall GetCount(void);
	
public:
	System::UnicodeString ServerMessage;
	__fastcall TfrxConfig(void);
	__fastcall virtual ~TfrxConfig(void);
	HRESULT __fastcall LoadFromStream(Classes::TStream* Stream);
	HRESULT __fastcall SaveToStream(Classes::TStream* Stream);
	HRESULT __fastcall LoadFromFile(const System::UnicodeString FileName);
	HRESULT __fastcall SaveToFile(const System::UnicodeString FileName);
	System::UnicodeString __fastcall GetValue(const System::UnicodeString Name);
	int __fastcall GetNumber(const System::UnicodeString Name);
	bool __fastcall GetBool(const System::UnicodeString Name);
	System::UnicodeString __fastcall CheckValue(const System::UnicodeString Name, const System::UnicodeString Current);
	void __fastcall SetValue(const System::UnicodeString Name, const System::UnicodeString Value);
	void __fastcall SetBool(const System::UnicodeString Name, const bool Value);
	void __fastcall Clear(void);
	void __fastcall ConfigListToFile(const System::UnicodeString FileName);
	void __fastcall Reload(void);
	__property Classes::TStringList* Lines = {read=FLines};
	__property Frxxml::TfrxXMLDocument* XML = {read=FXML};
	__property int Count = {read=GetCount, nodefault};
	__property System::UnicodeString ConfigFolder = {read=FConfigFolder, write=FConfigFolder};
};


class DELPHICLASS TfrxConfigItem;
class PASCALIMPLEMENTATION TfrxConfigItem : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::UnicodeString FValue;
	Frxxml::TfrxXMLItem* FXMLItem;
	
public:
	__property System::UnicodeString Value = {read=FValue, write=FValue};
	__property Frxxml::TfrxXMLItem* XMLItem = {read=FXMLItem, write=FXMLItem};
public:
	/* TObject.Create */ inline __fastcall TfrxConfigItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxConfigItem(void) { }
	
};


class DELPHICLASS TfrxServerConfig;
class PASCALIMPLEMENTATION TfrxServerConfig : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	bool FGzip;
	System::UnicodeString FIndexFileName;
	bool FLogging;
	System::UnicodeString FLogin;
	System::UnicodeString FLogPath;
	bool FMIC;
	bool FNoCacheHeader;
	Frxserverutils::TfrxServerOutputFormats FOutputFormats;
	System::UnicodeString FPassword;
	int FPort;
	System::UnicodeString FReportPath;
	System::UnicodeString FRootPath;
	int FSessionTimeOut;
	int FSocketTimeOut;
	System::UnicodeString FReportCachePath;
	int FDefaultCacheLatency;
	bool FReportCaching;
	int FMaxLogFiles;
	int FMaxLogSize;
	System::UnicodeString FDatabase;
	System::UnicodeString FDatabaseLogin;
	System::UnicodeString FDatabasePassword;
	bool FReportsList;
	System::UnicodeString FConfigFolder;
	
public:
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	void __fastcall SaveToFile(const System::UnicodeString FileName);
	
__published:
	__property bool Compression = {read=FGzip, write=FGzip, nodefault};
	__property System::UnicodeString IndexFileName = {read=FIndexFileName, write=FIndexFileName};
	__property bool Logging = {read=FLogging, write=FLogging, nodefault};
	__property int MaxLogSize = {read=FMaxLogSize, write=FMaxLogSize, nodefault};
	__property int MaxLogFiles = {read=FMaxLogFiles, write=FMaxLogFiles, nodefault};
	__property System::UnicodeString Login = {read=FLogin, write=FLogin};
	__property System::UnicodeString LogPath = {read=FLogPath, write=FLogPath};
	__property bool MIC = {read=FMIC, write=FMIC, nodefault};
	__property bool NoCacheHeader = {read=FNoCacheHeader, write=FNoCacheHeader, nodefault};
	__property Frxserverutils::TfrxServerOutputFormats OutputFormats = {read=FOutputFormats, write=FOutputFormats, nodefault};
	__property System::UnicodeString Password = {read=FPassword, write=FPassword};
	__property int Port = {read=FPort, write=FPort, nodefault};
	__property System::UnicodeString ReportPath = {read=FReportPath, write=FReportPath};
	__property System::UnicodeString ReportCachePath = {read=FReportCachePath, write=FReportCachePath};
	__property bool ReportCaching = {read=FReportCaching, write=FReportCaching, nodefault};
	__property int DefaultCacheLatency = {read=FDefaultCacheLatency, write=FDefaultCacheLatency, nodefault};
	__property System::UnicodeString RootPath = {read=FRootPath, write=FRootPath};
	__property int SessionTimeOut = {read=FSessionTimeOut, write=FSessionTimeOut, nodefault};
	__property int SocketTimeOut = {read=FSocketTimeOut, write=FSocketTimeOut, nodefault};
	__property System::UnicodeString Database = {read=FDatabase, write=FDatabase};
	__property System::UnicodeString DatabaseLogin = {read=FDatabaseLogin, write=FDatabaseLogin};
	__property System::UnicodeString DatabasePassword = {read=FDatabasePassword, write=FDatabasePassword};
	__property bool ReportsList = {read=FReportsList, write=FReportsList, nodefault};
	__property System::UnicodeString ConfigFolder = {read=FConfigFolder, write=FConfigFolder};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TfrxServerConfig(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TfrxServerConfig(void) : Classes::TPersistent() { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TfrxConfig* ServerConfig;
#define FR_SERVER_CONFIG_VERSION L"2.2.0"

}	/* namespace Frxserverconfig */
using namespace Frxserverconfig;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxserverconfigHPP
