// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxzip.pas' rev: 21.00

#ifndef FrxzipHPP
#define FrxzipHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Frxzlib.hpp>	// Pascal unit
#include <Frxgzip.hpp>	// Pascal unit
#include <Frxutils.hpp>	// Pascal unit
#include <Frxfileutils.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxzip
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TfrxZipArchive;
class PASCALIMPLEMENTATION TfrxZipArchive : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	System::AnsiString FRootFolder;
	Classes::TStringList* FErrors;
	Classes::TStringList* FFileList;
	System::AnsiString FComment;
	Classes::TNotifyEvent FProgress;
	int __fastcall GetCount(void);
	
public:
	__fastcall TfrxZipArchive(void);
	__fastcall virtual ~TfrxZipArchive(void);
	void __fastcall Clear(void);
	void __fastcall AddFile(const System::AnsiString FileName);
	void __fastcall AddDir(const System::AnsiString DirName);
	void __fastcall SaveToFile(const System::AnsiString Filename);
	void __fastcall SaveToStream(const Classes::TStream* Stream);
	__property Classes::TStringList* Errors = {read=FErrors};
	__property System::AnsiString Comment = {read=FComment, write=FComment};
	__property System::AnsiString RootFolder = {read=FRootFolder, write=FRootFolder};
	__property int FileCount = {read=GetCount, nodefault};
	__property Classes::TNotifyEvent OnProgress = {read=FProgress, write=FProgress};
};


class DELPHICLASS TfrxZipLocalFileHeader;
class PASCALIMPLEMENTATION TfrxZipLocalFileHeader : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	unsigned FLocalFileHeaderSignature;
	System::Word FVersion;
	System::Word FGeneralPurpose;
	System::Word FCompressionMethod;
	unsigned FCrc32;
	System::Word FLastModFileDate;
	System::Word FLastModFileTime;
	unsigned FCompressedSize;
	unsigned FUnCompressedSize;
	System::AnsiString FExtraField;
	System::AnsiString FFileName;
	System::Word FFileNameLength;
	System::Word FExtraFieldLength;
	void __fastcall SetExtraField(const System::AnsiString Value);
	void __fastcall SetFileName(const System::AnsiString Value);
	
public:
	__fastcall TfrxZipLocalFileHeader(void);
	void __fastcall SaveToStream(const Classes::TStream* Stream);
	__property unsigned LocalFileHeaderSignature = {read=FLocalFileHeaderSignature, nodefault};
	__property System::Word Version = {read=FVersion, write=FVersion, nodefault};
	__property System::Word GeneralPurpose = {read=FGeneralPurpose, write=FGeneralPurpose, nodefault};
	__property System::Word CompressionMethod = {read=FCompressionMethod, write=FCompressionMethod, nodefault};
	__property System::Word LastModFileTime = {read=FLastModFileTime, write=FLastModFileTime, nodefault};
	__property System::Word LastModFileDate = {read=FLastModFileDate, write=FLastModFileDate, nodefault};
	__property unsigned Crc32 = {read=FCrc32, write=FCrc32, nodefault};
	__property unsigned CompressedSize = {read=FCompressedSize, write=FCompressedSize, nodefault};
	__property unsigned UnCompressedSize = {read=FUnCompressedSize, write=FUnCompressedSize, nodefault};
	__property System::Word FileNameLength = {read=FFileNameLength, write=FFileNameLength, nodefault};
	__property System::Word ExtraFieldLength = {read=FExtraFieldLength, write=FExtraFieldLength, nodefault};
	__property System::AnsiString FileName = {read=FFileName, write=SetFileName};
	__property System::AnsiString ExtraField = {read=FExtraField, write=SetExtraField};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxZipLocalFileHeader(void) { }
	
};


class DELPHICLASS TfrxZipCentralDirectory;
class PASCALIMPLEMENTATION TfrxZipCentralDirectory : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	unsigned FEndOfChentralDirSignature;
	System::Word FNumberOfTheDisk;
	System::Word FTotalOfEntriesCentralDirOnDisk;
	System::Word FNumberOfTheDiskStartCentralDir;
	System::Word FTotalOfEntriesCentralDir;
	unsigned FSizeOfCentralDir;
	unsigned FOffsetStartingDiskDir;
	System::AnsiString FComment;
	System::Word FCommentLength;
	void __fastcall SetComment(const System::AnsiString Value);
	
public:
	__fastcall TfrxZipCentralDirectory(void);
	void __fastcall SaveToStream(const Classes::TStream* Stream);
	__property unsigned EndOfChentralDirSignature = {read=FEndOfChentralDirSignature, nodefault};
	__property System::Word NumberOfTheDisk = {read=FNumberOfTheDisk, write=FNumberOfTheDisk, nodefault};
	__property System::Word NumberOfTheDiskStartCentralDir = {read=FNumberOfTheDiskStartCentralDir, write=FNumberOfTheDiskStartCentralDir, nodefault};
	__property System::Word TotalOfEntriesCentralDirOnDisk = {read=FTotalOfEntriesCentralDirOnDisk, write=FTotalOfEntriesCentralDirOnDisk, nodefault};
	__property System::Word TotalOfEntriesCentralDir = {read=FTotalOfEntriesCentralDir, write=FTotalOfEntriesCentralDir, nodefault};
	__property unsigned SizeOfCentralDir = {read=FSizeOfCentralDir, write=FSizeOfCentralDir, nodefault};
	__property unsigned OffsetStartingDiskDir = {read=FOffsetStartingDiskDir, write=FOffsetStartingDiskDir, nodefault};
	__property System::Word CommentLength = {read=FCommentLength, write=FCommentLength, nodefault};
	__property System::AnsiString Comment = {read=FComment, write=SetComment};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxZipCentralDirectory(void) { }
	
};


class DELPHICLASS TfrxZipFileHeader;
class PASCALIMPLEMENTATION TfrxZipFileHeader : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	unsigned FCentralFileHeaderSignature;
	unsigned FRelativeOffsetLocalHeader;
	unsigned FUnCompressedSize;
	unsigned FCompressedSize;
	unsigned FCrc32;
	unsigned FExternalFileAttribute;
	System::AnsiString FExtraField;
	System::AnsiString FFileComment;
	System::AnsiString FFileName;
	System::Word FCompressionMethod;
	System::Word FDiskNumberStart;
	System::Word FLastModFileDate;
	System::Word FLastModFileTime;
	System::Word FVersionMadeBy;
	System::Word FGeneralPurpose;
	System::Word FFileNameLength;
	System::Word FInternalFileAttribute;
	System::Word FExtraFieldLength;
	System::Word FVersionNeeded;
	System::Word FFileCommentLength;
	void __fastcall SetExtraField(const System::AnsiString Value);
	void __fastcall SetFileComment(const System::AnsiString Value);
	void __fastcall SetFileName(const System::AnsiString Value);
	
public:
	__fastcall TfrxZipFileHeader(void);
	void __fastcall SaveToStream(const Classes::TStream* Stream);
	__property unsigned CentralFileHeaderSignature = {read=FCentralFileHeaderSignature, nodefault};
	__property System::Word VersionMadeBy = {read=FVersionMadeBy, nodefault};
	__property System::Word VersionNeeded = {read=FVersionNeeded, nodefault};
	__property System::Word GeneralPurpose = {read=FGeneralPurpose, write=FGeneralPurpose, nodefault};
	__property System::Word CompressionMethod = {read=FCompressionMethod, write=FCompressionMethod, nodefault};
	__property System::Word LastModFileTime = {read=FLastModFileTime, write=FLastModFileTime, nodefault};
	__property System::Word LastModFileDate = {read=FLastModFileDate, write=FLastModFileDate, nodefault};
	__property unsigned Crc32 = {read=FCrc32, write=FCrc32, nodefault};
	__property unsigned CompressedSize = {read=FCompressedSize, write=FCompressedSize, nodefault};
	__property unsigned UnCompressedSize = {read=FUnCompressedSize, write=FUnCompressedSize, nodefault};
	__property System::Word FileNameLength = {read=FFileNameLength, write=FFileNameLength, nodefault};
	__property System::Word ExtraFieldLength = {read=FExtraFieldLength, write=FExtraFieldLength, nodefault};
	__property System::Word FileCommentLength = {read=FFileCommentLength, write=FFileCommentLength, nodefault};
	__property System::Word DiskNumberStart = {read=FDiskNumberStart, write=FDiskNumberStart, nodefault};
	__property System::Word InternalFileAttribute = {read=FInternalFileAttribute, write=FInternalFileAttribute, nodefault};
	__property unsigned ExternalFileAttribute = {read=FExternalFileAttribute, write=FExternalFileAttribute, nodefault};
	__property unsigned RelativeOffsetLocalHeader = {read=FRelativeOffsetLocalHeader, write=FRelativeOffsetLocalHeader, nodefault};
	__property System::AnsiString FileName = {read=FFileName, write=SetFileName};
	__property System::AnsiString ExtraField = {read=FExtraField, write=SetExtraField};
	__property System::AnsiString FileComment = {read=FFileComment, write=SetFileComment};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxZipFileHeader(void) { }
	
};


class DELPHICLASS TfrxZipLocalFile;
class PASCALIMPLEMENTATION TfrxZipLocalFile : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TfrxZipLocalFileHeader* FLocalFileHeader;
	Classes::TMemoryStream* FFileData;
	unsigned FOffset;
	
public:
	__fastcall TfrxZipLocalFile(void);
	__fastcall virtual ~TfrxZipLocalFile(void);
	void __fastcall SaveToStream(const Classes::TStream* Stream);
	__property TfrxZipLocalFileHeader* LocalFileHeader = {read=FLocalFileHeader};
	__property Classes::TMemoryStream* FileData = {read=FFileData, write=FFileData};
	__property unsigned Offset = {read=FOffset, write=FOffset, nodefault};
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxzip */
using namespace Frxzip;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxzipHPP
