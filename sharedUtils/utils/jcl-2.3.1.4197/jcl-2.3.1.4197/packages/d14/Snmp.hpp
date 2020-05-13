// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Snmp.pas' rev: 21.00

#ifndef SnmpHPP
#define SnmpHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------
#include <snmp.h>

namespace Snmp
{
//-- type declarations -------------------------------------------------------
struct TAsnOctetString;
typedef TAsnOctetString *PAsnOctetString;

#pragma pack(push,4)
struct TAsnOctetString
{
	
public:
	char *stream;
	unsigned length;
	bool dynamic_;
};
#pragma pack(pop)


struct TAsnObjectIdentifier;
typedef TAsnObjectIdentifier *PAsnObjectIdentifier;

#pragma pack(push,4)
struct TAsnObjectIdentifier
{
	
public:
	unsigned idLength;
	unsigned *ids;
};
#pragma pack(pop)


struct TAsnAny;
typedef TAsnAny *PAsnAny;

#pragma pack(push,4)
struct TAsnAny
{
	
public:
	System::Byte asnType;
	#pragma pack(push,1)
	union
	{
		struct 
		{
			unsigned:24;
			TAsnOctetString arbitrary;
			
		};
		struct 
		{
			unsigned:24;
			unsigned ticks;
			
		};
		struct 
		{
			unsigned:24;
			unsigned gauge;
			
		};
		struct 
		{
			unsigned:24;
			unsigned counter;
			
		};
		struct 
		{
			unsigned:24;
			TAsnOctetString address;
			
		};
		struct 
		{
			unsigned:24;
			TAsnOctetString sequence;
			
		};
		struct 
		{
			unsigned:24;
			TAsnObjectIdentifier object_;
			
		};
		struct 
		{
			unsigned:24;
			TAsnOctetString bits;
			
		};
		struct 
		{
			unsigned:24;
			TAsnOctetString string_;
			
		};
		struct 
		{
			unsigned:24;
			ULARGE_INTEGER counter64;
			
		};
		struct 
		{
			unsigned:24;
			unsigned unsigned32;
			
		};
		struct 
		{
			unsigned:24;
			int number;
			
		};
		
	};
	#pragma pack(pop)
};
#pragma pack(pop)


typedef TAsnObjectIdentifier TAsnObjectName;

typedef TAsnAny TAsnObjectSyntax;

#pragma pack(push,4)
struct TSnmpVarBind
{
	
public:
	TAsnObjectIdentifier name;
	TAsnAny value;
};
#pragma pack(pop)


typedef TSnmpVarBind *PSnmpVarBind;

struct TSnmpVarBindList;
typedef TSnmpVarBindList *PSnmpVarBindList;

#pragma pack(push,4)
struct TSnmpVarBindList
{
	
public:
	TSnmpVarBind *list;
	unsigned len;
};
#pragma pack(pop)


typedef bool __stdcall (*TSnmpExtensionInit)(unsigned dwUptimeReference, unsigned &phSubagentTrapEvent, PAsnObjectIdentifier &pFirstSupportedRegion);

typedef bool __stdcall (*TSnmpExtensionInitEx)(PAsnObjectIdentifier &pNextSupportedRegion);

typedef bool __stdcall (*TSnmpExtensionMonitor)(void * pAgentMgmtData);

typedef bool __stdcall (*TSnmpExtensionQuery)(System::Byte bPduType, TSnmpVarBindList &pVarBindList, int &pErrorStatus, int &pErrorIndex);

typedef bool __stdcall (*TSnmpExtensionQueryEx)(unsigned nRequestType, unsigned nTransactionId, PSnmpVarBindList &pVarBindList, PAsnOctetString &pContextInfo, int &pErrorStatus, int &pErrorIndex);

typedef bool __stdcall (*TSnmpExtensionTrap)(PAsnObjectIdentifier pEnterpriseOid, int &pGenericTrapId, int &pSpecificTrapId, unsigned &pTimeStamp, PSnmpVarBindList &pVarBindList);

typedef void __stdcall (*TSnmpExtensionClose)(void);

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;
extern PACKAGE bool __fastcall SnmpExtensionLoaded(void);
extern PACKAGE bool __fastcall LoadSnmpExtension(const System::UnicodeString LibName);
extern PACKAGE bool __fastcall UnloadSnmpExtension(void);
extern PACKAGE bool __fastcall SnmpLoaded(void);
extern PACKAGE bool __fastcall UnloadSnmp(void);
extern PACKAGE bool __fastcall LoadSnmp(void);

}	/* namespace Snmp */
using namespace Snmp;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// SnmpHPP
