// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxcrypt.pas' rev: 21.00

#ifndef FrxcryptHPP
#define FrxcryptHPP

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
#include <Forms.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxcrypt
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxCrypt;
class PASCALIMPLEMENTATION TfrxCrypt : public Frxclass::TfrxCustomCrypter
{
	typedef Frxclass::TfrxCustomCrypter inherited;
	
private:
	System::AnsiString __fastcall AskKey(const System::AnsiString Key);
	
public:
	virtual void __fastcall Crypt(Classes::TStream* Dest, const System::AnsiString Key);
	virtual bool __fastcall Decrypt(Classes::TStream* Source, const System::AnsiString Key);
public:
	/* TfrxCustomCrypter.Create */ inline __fastcall virtual TfrxCrypt(Classes::TComponent* AOwner) : Frxclass::TfrxCustomCrypter(AOwner) { }
	/* TfrxCustomCrypter.Destroy */ inline __fastcall virtual ~TfrxCrypt(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall frxCryptStream(Classes::TStream* Source, Classes::TStream* Dest, const System::AnsiString Key);
extern PACKAGE void __fastcall frxDecryptStream(Classes::TStream* Source, Classes::TStream* Dest, const System::AnsiString Key);

}	/* namespace Frxcrypt */
using namespace Frxcrypt;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxcryptHPP
