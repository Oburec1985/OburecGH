// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxgzip.pas' rev: 21.00

#ifndef FrxgzipHPP
#define FrxgzipHPP

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
#include <Frxzlib.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxgzip
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxCompressionLevel { gzNone, gzFastest, gzDefault, gzMax };
#pragma option pop

class DELPHICLASS TfrxGZipCompressor;
class PASCALIMPLEMENTATION TfrxGZipCompressor : public Frxclass::TfrxCustomCompressor
{
	typedef Frxclass::TfrxCustomCompressor inherited;
	
public:
	virtual void __fastcall Compress(Classes::TStream* Dest);
	virtual bool __fastcall Decompress(Classes::TStream* Source);
public:
	/* TfrxCustomCompressor.Create */ inline __fastcall virtual TfrxGZipCompressor(Classes::TComponent* AOwner) : Frxclass::TfrxCustomCompressor(AOwner) { }
	/* TfrxCustomCompressor.Destroy */ inline __fastcall virtual ~TfrxGZipCompressor(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall frxCompressStream(Classes::TStream* Source, Classes::TStream* Dest, TfrxCompressionLevel Compression = (TfrxCompressionLevel)(0x2), System::UnicodeString FileNameW = L"");
extern PACKAGE System::AnsiString __fastcall frxDecompressStream(Classes::TStream* Source, Classes::TStream* Dest);
extern PACKAGE void __fastcall frxDeflateStream(Classes::TStream* Source, Classes::TStream* Dest, TfrxCompressionLevel Compression = (TfrxCompressionLevel)(0x2));
extern PACKAGE void __fastcall frxInflateStream(Classes::TStream* Source, Classes::TStream* Dest);

}	/* namespace Frxgzip */
using namespace Frxgzip;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxgzipHPP
