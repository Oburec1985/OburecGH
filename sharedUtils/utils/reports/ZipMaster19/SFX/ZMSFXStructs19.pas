(******************************************************************)
(* Structures for DelZip v1.7                                     *)
(* Copyright (C)1997-2004 E. W. Engler, C. Vleghert, M. Stephany  *)
(*                                                                *)
(* written by Markus Stephany                                     *)
(* mailto:delphizip@mirkes.de                                     *)
(* http://delphizip.mirkes.de                                     *)
(*                                                                *)
(* last changed: 12/21/2003                                       *)
(*                                                                *)
(******************************************************************)
(************************************************************************
 Copyright (C) 2009, 2010  by Russell J. Peters, Roger Aelbrecht,
      Eric W. Engler and Chris Vleghert.

   This file is part of TZipMaster Version 1.9.

    TZipMaster is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    TZipMaster is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with TZipMaster.  If not, see <http://www.gnu.org/licenses/>.

    contact: problems@delphizip.org (include ZipMaster in the subject).
    updates: http://www.delphizip.org
    DelphiZip maillist subscribe at http://www.freelists.org/list/delphizip 
************************************************************************)
unit ZMSFXStructs19;

{
this unit contains definitions of records and signatures used
in zipfiles.

}

interface

uses
  Windows;
{$I '..\ZipVers19.inc'}

const
  FS_FAT: Integer = 0;
  FS_HPFS: Integer = 6;
  FS_NTFS: Integer = 11;
  FLAG_UTF8_BIT = $0800;
                         
  Zip64_data_tag = $0001;     // Zip64 extra field tag
  NTFS_STAMP_TAG = $000A;     // NTFS time stamps
  UPath_Data_Tag = $7075;     // Info-Zip UTF8 path field
  UCmnt_Data_Tag = $6375;     // Info-Zip UTF8 comment field
// Tag - 2 byte
// total size - 2 byte
// version - 1 byte = 1
// crc -4 bytes = crc of orig field
// utf8 string - total size - 9

type
  XNTFSData = packed record
    MTime: Int64;
    ATime: Int64;
    CTime: Int64;
  end;
  PXNTFData = ^XNTFSData;

type
  PUString_Data_Header = ^UString_Data_Header;
  UString_Data_Header = packed record
    tag: word;
    totsiz: word;
    version: byte;
    origcrc: DWORD;
  end;

type 
  // local file header entry
  PZipLocalHeader = ^TZipLocalHeader;
  TZipLocalHeader = packed record
    HeaderSig: LongWord;
    VersionNeed: Word;
    Flag: Word;
    ComprMethod: Word;
    ModifTime: Word;
    ModifDate: Word;
    CRC32: LongWord;
    ComprSize: LongWord;
    UnComprSize: LongWord;
    FileNameLen: Word;
    ExtraLen: Word;
  end;
//  ZipLocalHeader = TZipLocalHeader;


  // central directory entry
  PZipCentralHeader = ^TZipCentralHeader;
  TZipCentralHeader = packed record //fixed part size : 42 bytes
    HeaderSig: LongWord; // hex: 02014B50(4)
    VersionMadeBy0: Byte; //version made by(1)
    VersionMadeBy1: Byte; //host number(1)
    VersionNeed: Word; // version needed to extract(2)
    Flag: Word; //generalPurpose bitflag(2)
    ComprMethod: Word; //compression method(2)
    ModifTime: Word; // modification time(2)
    ModifDate: Word; // modification date(2)
    CRC32: LongWord; //Cycling redundancy check (4)
    ComprSize: LongWord; //compressed file size  (4)
    UnComprSize: LongWord; //uncompressed file size (4)
    FileNameLen: Word; //(2)
    ExtraLen: Word; //(2)
    FileComLen: Word; //(2)
    DiskStart: Word; //starts on disk number xx(2)
    IntFileAtt: Word; //internal file attributes(2)
    ExtFileAtt: LongWord; //external file attributes(4)
    RelOffLocal: LongWord; //relative offset of local file header(4)
    // not used as part of this record structure:
    // filename, extra data, file comment
  end;
//  ZipCentralHeader = TZipCentralHeader;

  pZ64CentralEntry = ^TZ64CentralEntry;
  TZ64CentralEntry = packed record // used internally  
    HeaderSig: LongWord; // hex: 02014B50(4)
    VersionMadeBy0: Byte; //version made by(1)
    VersionMadeBy1: Byte; //host number(1)
    VersionNeed: Word; // version needed to extract(2)
    Flag: Word; //generalPurpose bitflag(2)
    ComprMethod: Word; //compression method(2)
    ModifTime: Word; // modification time(2)
    ModifDate: Word; // modification date(2)
    CRC32: LongWord; //Cycling redundancy check (4)
    ComprSize: Int64; //compressed file size  (4)
    UnComprSize: Int64; //uncompressed file size (4)
    FileNameLen: Word; //(2)
    ExtraLen: Word; //(2)
    FileComLen: Word; //(2)
    DiskStart: Word; //starts on disk number xx(2)
    IntFileAtt: Word; //internal file attributes(2)
    ExtFileAtt: LongWord; //external file attributes(4)
    RelOffLocal: Int64; //relative offset of local file header(4)
    MTime: Int64; // ntfs modified time - only if data available
    ATime: Int64; // ntfs accessed time - only if data available
    CTime: Int64; // ntfs created time - only if data available
    // not used as part of this record structure:
    // filename, extra data, file comment
  end;

  // end of central directory record
  PZipEndOfCentral = ^TZipEndOfCentral;
  TZipEndOfCentral = packed record //Fixed part size : 22 bytes
    HeaderSig: LongWord; //(4)  hex=06054B50
    ThisDiskNo: Word; //(2)This disk's number
    CentralDiskNo: Word; //(2)Disk number central directory start
    CentralEntries: Word; //(2)Number of central directory entries on this disk
    TotalEntries: Word; //(2)Number of entries in central dir
    CentralSize: LongWord; //(4)Size of central directory
    CentralOffSet: LongWord; //(4)offsett of central directory on 1st disk
    ZipCommentLen: Word; //(2)
    // not used as part of this record structure:
    // ZipComment
  end;
//  ZipEndOfCentral = TZipEndOfCentral;

  // ext local header (for spanning ?)
  PZipExtLocalHeader = ^TZipExtLocalHeader;
  TZipExtLocalHeader = packed record
    DataDescSig: LongWord; // Should be 0x08074B50
    CRC32: LongWord;
    ComprSize: LongWord;
    UnComprSize: LongWord;
  end;
//  ZipExtLocalHeader = TZipExtLocalHeader;
//  ZipDataDescriptor = TZipExtLocalHeader;

type
  // must be same disk as EOC
  pZip64EOCLocator = ^TZip64EOCLocator;
  TZip64EOCLocator = packed record
    LocSig: Longword;             // (4) Should be 0x07064B50
    EOC64DiskStt: Longword;       // (4)
    EOC64RelOfs: Int64;          // (8) relative to start of it's disk
    NumberDisks: Longword;        // (4) total disks
  end;
//  pZip64EOCLocator = ^TZip64EOCLocator;

type
  pZipEOC64 = ^TZipEOC64;
  TZipEOC64 = packed record
    EOC64Sig: LongWord;           // (4) should be 0x06064b50
    vsize: Int64;                // (8)    size of variable part
    // variable part   - fields as needed? (old field = 0XFFFF or 0XFF)
    VersionMade: Word;            // (2)
    VersionNeed: Word;            // (2)
    ThisDiskNo: LongWord;         // (4)
    CentralDiskNo: LongWord;      // (4)
    CentralEntries: Int64;       // (8) Number of central dir entries on this disk
    TotalEntries: Int64;         // (8) Number of entries in central dir
    CentralSize: Int64;          // (8) Size of central directory
    CentralOffSet: Int64;        // (8) offsett of central dir on 1st disk
//  zip64 extensible data sector    (variable size)
  end;

type
  TZipCentralDigitSignature = packed record
    CenDigSig: LongWord;          // (4) should be 0x05054b50
    vsize: Word;                  // (2)
//    data[vsize]
  end;

var { these are stored in reverse order }
  // xyz-1: avoid zip structure signatures in the sfx code
  //        zipdll.dll doesn't like them...
  ZipLocalHeaderSig: DWORD = $04034B50-1; { 'PK'34  (in file: 504b0304) }
  ZipCentralHeaderSig: DWORD = $02014B50-1; { 'PK'12 }
  ZipEndOfCentralSig: DWORD = $06054B50-1; { 'PK'56 }
  ZipExtLocalHeaderSig: DWORD = $08074B50-1; { 'PK'78 }
  ZipEndCentral64Sig: DWORD = $06064B50-1;       { 'PK'66 }
  ZipEOC64LocatorSig: DWORD = $07064B50-1;       { 'PK'67 }


// buffer stuff (not anymore public in zipmstr.pas)
const
  SFXBufSize = 8192;
                 
//  Zip64_data_tag = $0001;   // zip64 extra field tag

  MAX_UNSIGNED:DWORD   = $FFFFFFFF;
  MAX_WORD:WORD = $FFFF;
  MAX_BYTE:BYTE  = $FF;

type
  PSFXBuffer = ^TSFXBuffer;
  TSFXBuffer = array[0..SFXBufSize - 1] of Byte;

implementation

initialization
  // adjust the signatures
  Inc(ZipLocalHeaderSig);
  Inc(ZipCentralHeaderSig);
  Inc(ZipEndOfCentralSig);
  Inc(ZipExtLocalHeaderSig);
  Inc(ZipEndCentral64Sig);
  Inc(ZipEOC64LocatorSig);

end.
