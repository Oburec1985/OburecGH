(******************************************************************)
(* SFX for DelZip v1.8                                            *)
(* Copyright 2002-2004, 2008                                      *)
(*                                                                *)
(* written by Markus Stephany                                     *)
(* modified by Russell Peters, Roger Aelbrecht
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

  modified 30-Jan-2008
---------------------------------------------------------------------------*)
unit ZMSFXVars19;

{
  contains all global variables used
  by delzip sfx.

}

interface

uses
  Windows, ZMSFXDefs19, ZMSFXInt19, ZMSFXStructs19;

var
  // the sfx file haeder read from InFile
  VRec_SFXHeader: TSFXFileHeader;

  { TSFXFileHeader strings }
  // caption of the main dialog
  VStr_SFX_Caption,

  // message to show before opening the main dialog
  VStr_SFX_StartMsg,

  // command line read from the special header
  VStr_SFX_CmdLine,

  // default extract path used if reading path from registry failed
  VStr_SFX_RegFailPath,

  // the default-directory stored in the special header
  VStr_SFX_Path: string;

  // may 08, 2002: paramstr(0) replacement
  VStr_ExeName: string;

  {zip processing stuff }
  // crc32 table for unzipping
  VArr_CRC32Table: TCRC32Table;

  // Running CRC (32 bit) value
  VDW_CRC32Val: Cardinal;

  // encryption key
  VArr_CryptKey: array[0..2] of longint;

  // archived file packed size
  VInt_BytesToGo: Int64;//longint;

  // protect from bombs
  VInt_MaxWrite: Int64;

  // input file (i myself)
  VH_InFile: THandle = INVALID_HANDLE_VALUE;

  // file to be written
  VH_OutFile: THandle = INVALID_HANDLE_VALUE;

  // central zip file header
  VRec_ZipHeader: TZ64CentralEntry;

  // file being extracted
  VStr_CurrentFile: string;

  // handle of the main window
  VH_MainWnd: hWnd;

  // password from input box
  VStr_Password: AnsiString = '';

  // actual extract path
  VStr_ExtractPath: string = '';

  // current file position
  VDW_CurrentFilePos: Int64;//Cardinal;

  // position of the TSFXFileHeader/ start of zip archive in the file
  VInt_FileBegin: {Int64;//}longint;

  // cancelled by user (WM_CLOSE during Extract)
  VBool_Cancelled: boolean;

  // possibly moved offset is stored here (wrong sfx creation)
  VDW_OffsetDelta: Int64;//cardinal;

  // shell image list handle
  VH_ShellImageList: THandle;

  // check volatile extract directory deletion
  VBool_CheckDeleteVolatilePath: Boolean = False;
  VStr_VolatilePath: string;
  VStr_VolatilePath_Unexpanded: string;

  // currently open file
  VStr_OutFile: string='';

  // detached archive support
  VH_TempFile: THandle = INVALID_HANDLE_VALUE; // temp file for spanning archive data
  VStr_TempFile: string = ''; // dito
  VInt_SpanType: integer = 0; // 0: not spanned, 1 (SFXSpanTypeSpanned): disk spanning, 2 (SFXSpanTypeMultiVol): multiple archives in one directory (xyz001.zip, xyz002.zip ...)
  VStr_DetachName: string; // name of the detached archive the sfx belongs to
  VStr_DetachExt: string; // file ext of the detached archive the sfx belongs to
  VBool_FixedDrive: boolean; // is drive fixed or removable
  VStr_SourceDir: string; // source directory of the spanned archives

  // multi-language support
//  VRec_Strings: PWord = nil;   // pointer to table of strings
  VP_SBuf: pByte = nil;
//  VRec_SHeader: TSFXStringsHeader;
//  VInt_LangOfs: longint = 0;     // offset of Langs header
//  VP_Langs: PSFXStringsHeader = nil;  // pointer to available languages
  VInt_CP: Integer = 0;   // selected codepage
  VInt_CurLang: integer = 0; // selected language entry
//  VRec_Langs: PSFXStringsEntry = nil; // pointer to available languages
//  VStr_Lang: string = '';    // the selected langauge
//  VInt_CmdLineSize: integer = 0;
{$ifdef DEBUG_SFX}
  Test_Stub_Size: Integer = 0;
{$ENDIF}
  VInt_LastSeq: Integer = -1;

implementation

end.
