/*  ZipMsg.h - (master) message identifiers

  TZipMaster19 VCL by Chris Vleghert and Eric W. Engler
  v1.9
  Copyright (C) 2009, 2010  Russell Peters

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License (licence.txt) for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

  contact: problems AT delphizip DOT org
  updates: http://www.delphizip.org

  modified 2010-01-26
---------------------------------------------------------------------------*/
// note special comments //! shared, //- not used, //= moved
#ifndef ZipMsgH
#define ZipMsgH

  #define DT_Language			  10096
  #define DT_Author				  10097
  #define DT_Desc				  10098
  #define GE_FatalZip             10101
  #define GE_NoZipSpecified       10102     //!
  #define GE_NoMem                10103
  #define GE_WrongPassword        10104
  #define GE_CopyFile             10105	//-
  #define GE_Except               10106
  #define GE_Reentered            10107	//-
  #define GE_Busy                 10108	//-
  #define GE_Inactive             10109
  #define GE_RangeError           10110	
  #define GE_TempZip              10111
  #define GE_WasBusy              10112
  #define GE_EventEx              10113
  #define GE_DLLAbort             10118	//-
  #define GE_DLLBusy              10119	//-
  #define GE_DLLCancel            10120	//-
  #define GE_DLLMem               10121	//-
  #define GE_DLLStruct            10122	//-
  #define GE_DLLEvent             10123	//-
  #define GE_DLLCritical          10124	
  #define GE_Unknown              10125
  #define GE_Skipped              10126
  #define GE_Copying			  10127
  #define GE_Abort                10128 
  #define GE_NotPermitted         10129	//-
  #define GE_ExceptErr			  10130
  #define GE_NoSkipping			  10131
  #define GE_FileChanged		  10132 // * new 1.90

  #define RN_ZipSFXData           10140	//-
  #define RN_NoRenOnSpan          10141		// - xnot used
  #define RN_ProcessFile          10142		// - xnot used
  #define RN_RenameTo             10143		// - xnot used
  #define RN_InvalidDateTime      10144

  #define PW_UnatAddPWMiss        10150
  #define PW_UnatExtPWMiss        10151
  #define PW_Ok                   10152     //- moved ZB_
  #define PW_Cancel               10153     //- moved ZB_
  #define PW_Caption              10154
  #define PW_MessageEnter         10155
  #define PW_MessageConfirm       10156
  #define PW_CancelAll            10157     //- moved ZB_
  #define PW_Abort                10158     //- moved ZB_
  #define PW_ForFile              10159	//-

  #define CF_SourceIsDest         10180
  #define CF_OverwriteYN          10181
  #define CF_CopyFailed           10182
  #define CF_SourceNotFound       10183	//-
  #define CF_SFXCopyError         10184
  #define CF_DestFileNoOpen       10185	//-
  #define CF_NoCopyOnSpan         10186		// - xnot used
  #define CF_NoDest 			  10187

  #define LI_ReadZipError         10201
  #define LI_ErrorUnknown         10202
  #define LI_WrongZipStruct       10203
  #define LI_GarbageAtEOF         10204	//-
  #define LI_FileTooBig           10205     //-
  #define LI_MethodUnknown        10206	//-

  #define ZB_Yes                  10220
  #define ZB_No                   10221
  #define ZB_OK                   10222     // =PW_Ok
  #define ZB_Cancel               10223     // =PW_Cancel
  #define ZB_Abort                10224     // =PW_Abort
  #define ZB_Retry                10225
  #define ZB_Ignore               10226
  #define ZB_CancelAll            10227     // =PW_CancelAll
  #define ZB_NoToAll              10228
  #define ZB_YesToAll             10229
  #define ZB_Help                 10230     //- not used

  #define AD_NothingToZip         10301
  #define AD_UnattPassword        10302
  #define AD_NoFreshenUpdate      10303	//-
  #define AD_AutoSFXWrong         10304
  #define AD_NoStreamDLL          10305     //- not used
  #define AD_InIsOutStream        10306
  #define AD_InvalidName          10307
  #define AD_NoDestDir            10308
  #define AD_BadFileName          10309
  #define AD_InvalidEncode		  10310
  #define AD_InvalidZip			  10311
  
  #define AZ_NothingToDo 		  10320
  #define AZ_SameAsSource         10321
  #define AZ_InternalError        10322

  #define DL_NothingToDel         10401
  #define DL_NoDelOnSpan          10402		// - xnot used

  #define EX_FatalUnZip           10501		// - xnot used
  #define EX_UnAttPassword        10502
  #define EX_NoStreamDLL          10503     //- not used
  #define EX_NoExtrDir            10504

  #define LZ_ZipDllLoaded         10601     //- not used
  #define LZ_NoZipDllExec         10602     //- not used
  #define LZ_NoZipDllVers         10603     //- not used
  #define LZ_NoZipDll             10604     //- not used
  #define LZ_OldZipDll            10605     //- not used
  #define LZ_ZipDllUnloaded       10606     //- not used

  #define LD_NoDll                10650
  #define LD_BadDll               10651	//-
  #define LD_DllLoaded            10652
  #define LD_DllUnloaded          10653
  #define LD_LoadErr              10654

  #define LU_UnzDllLoaded         10701     //- not used
  #define LU_NoUnzDllExec         10702     //- not used
  #define LU_NoUnzDllVers         10703     //- not used
  #define LU_NoUnzDll             10704     //- not used
  #define LU_OldUnzDll            10705     //- not used
  #define LU_UnzDllUnloaded       10706     //- not used

  #define SF_StringToLong         10801     //-! alternate spelling
  #define SF_StringTooLong        10801     //*
  #define SF_NoZipSFXBin          10802     //!
  #define SF_InputIsNoZip         10803	//-     //!
  #define SF_NoSFXSupport         10804     //-
  #define SF_MsgTooLong           10805 //-    //*
  #define SF_DefPathTooLong       10806 //-    //*
  #define SF_DlgTitleTooLong      10807 //-    //*
  #define SF_CmdLineTooLong       10808 //-    //*
  #define SF_FBkPathTooLong       10809 //-    //*
  #define SF_DetachedHeaderTooBig 10810		//  new 1.80
  #define SF_DetachedErr          10811 //-    // new+
  #define SF_NameNeeded           10812 //-    // new+

  #define CZ_NoExeSpecified       10901 //-    //!
  #define CZ_InputNotExe          10902     //!
  #define CZ_SFXTypeUnknown       10903 //-    //!
  #define CZ_WrongConvert         10904 //-    //* new 1.79
  #define CZ_UnknownHeader        10905 //-    //* new 1.79
  #define CZ_BrowseError          10906     //* new 1.79
  #define CZ_NoExeResource        10907     //* new 1.79
  #define CZ_ExeSections          10908     //* new 1.79
  #define CZ_NoExeIcon            10909     //* new 1.79
  #define CZ_NoIcon               10910     //* new 1.79
  #define CZ_NoCopyIcon           10911     //* new 1.79
  #define CZ_NoIconFound          10912     //* new 1.79
  #define CZ_NoComp               10913     //-*

  #define DS_NoInFile             11001
  #define DS_FileOpen             11002
  #define DS_NotaDrive            11003
  #define DS_DriveNoMount         11004
  #define DS_NoVolume             11005
  #define DS_NoMem                11006
  #define DS_Canceled             11007
  #define DS_FailedSeek           11008
  #define DS_NoOutFile            11009
  #define DS_NoWrite              11010
  #define DS_EOCBadRead           11011     //!
  #define DS_LOHBadRead           11012     //!
  #define DS_CEHBadRead           11013     //!
  #define DS_LOHWrongSig          11014 //-    //!
  #define DS_CEHWrongSig          11015
  #define DS_LONameLen            11016  //-
  #define DS_CENameLen            11017  
  #define DS_LOExtraLen           11018  //-
  #define DS_CEExtraLen           11019     //!
  #define DS_DataDesc             11020
  #define DS_ZipData              11021  //-
  #define DS_CECommentLen         11022     //!
  #define DS_EOArchComLen         11023  //-   //!
  #define DS_ErrorUnknown         11024
  #define DS_NoUnattSpan          11025
  #define DS_EntryLost            11026  //-
  #define DS_NoTempFile           11027
  #define DS_LOHBadWrite          11028     //!
  #define DS_CEHBadWrite          11029     //!
  #define DS_EOCBadWrite          11030     //!
  #define DS_ExtWrongSig          11031  //-
  #define DS_NoDiskSpace          11032
  #define DS_InsertDisk           11033
  #define DS_InsertVolume         11034
  #define DS_InDrive              11035
  #define DS_NoValidZip           11036     //!
  #define DS_FirstInSet           11037  //-
  #define DS_NotLastInSet         11038  //-
  #define DS_AskDeleteFile        11039
  #define DS_AskPrevFile          11040
  #define DS_NoSFXSpan            11041  //-
  #define DS_CEHBadCopy           11042  //-
  #define DS_EOCBadSeek           11043  //-
  #define DS_EOCBadCopy           11044  //-   //!
  #define DS_FirstFileOnHD        11045  //-
  #define DS_InsertAVolume        11046
  #define DS_CopyCentral          11047
  #define DS_NoDiskSpan           11048     //
  #define DS_UnknownError         11049     //!
  #define DS_NoRenamePart         11050
  #define DS_NotChangeable        11051
  #define DS_Zip64FieldError 	  11052		// new
  #define DS_Unsupported 		  11053		// new
  #define DS_ReadError 			  11054		// new
  #define DS_WriteError 		  11055		// new
  #define DS_FileError 			  11056		// new
  #define DS_FileChanged 		  11057		// new
  #define DS_SFXBadRead  		  11058		// new
  #define DS_BadDrive 			  11059		// new
  #define DS_LOHWrongName		  11060		// new
  #define DS_BadCRC		          11061		// new
  #define DS_NoEncrypt		      11062		// new
  #define DS_NoInStream		      11063		// new
  #define DS_NoOutStream	      11064		// new
  #define DS_SeekError            11065     // new+
  #define DS_DataCopy             11066     // new+
  #define DS_CopyError            11067     // new+
  #define DS_TooManyParts         11068     // new++
  #define DS_AnotherDisk          11069		// new+++
  
  #define FM_Erase                11101
  #define FM_Confirm              11102

  #define ED_SizeToLarge          11201 //-    //- alternate spelling
  #define ED_SizeTooLarge         11201     //-
  
  #define SS_StreamError		  11250	//-	// new  

  #define CD_NoCDOnSpan           11301		//-
  #define CD_NoEventHndlr         11302  //-
  #define CD_LOExtraLen           11303  //-
  #define CD_CEExtraLen           11304  //-
  #define CD_CEComLen             11305  //-
  #define CD_FileName             11306
  #define CD_CEHDataSize          11307
  #define CD_Changing             11308  //-
  #define CD_DuplFileName         11309
  #define CD_NoProtected          11310
  #define CD_InvalidFileName      11311  //-
  #define CD_NoChangeDir          11312
  #define CD_FileSpecSkip         11313  //-

  #define DU_InvalidName          11350  //-		//-
  #define DU_WrongMethod          11351  //-

  #define PR_Progress             11400
  #define PR_Archive              11401
  #define PR_CopyZipFile          11402
  #define PR_SFX                  11403
  #define PR_Header               11404
  #define PR_Finish               11405
  #define PR_Copying              11406
  #define PR_CentrlDir            11407
  #define PR_Checking             11408
  #define PR_Loading              11409
  #define PR_Joining              11410
  #define PR_Splitting            11411
  #define PR_Writing 			  11412		// new
  #define PR_PreCalc			  11413

  #define DZ_Skipped              11450
  #define DZ_InUse                11451
  #define DZ_Refused              11452
  #define DZ_NoOpen               11453
  #define DZ_NoFiles              11454
  #define DZ_SizeChanged          11455
  #define DZ_InvalidName          11456		//-
  #define DZ_TooBig               11457		//-

  #define WZ_DropDirOnly          11500  //-
  #define WZ_NothingToWrite       11501  //-

  #define TM_Erasing              11600
  #define TM_Deleting             11601
  #define TM_GetNewDisk           11602
  #define TM_SystemError          11603
  #define TM_Trace 				  11604		// new
  #define TM_Verbose 			  11605		// new
  #define TM_Opened 			  11606	//-	// new
  #define TM_Closed 			  11607	//-	// new
  #define TM_Created 			  11608	//-	// new

  #define DZ_RES_GOOD           11648  // ZEN_OK
  #define DZ_RES_CANCELLED      11649
  #define DZ_RES_ABORT          11650
  #define DZ_RES_CALLBACK       11651
  #define DZ_RES_MEMORY         11652
  #define DZ_RES_STRUCT         11653
  #define DZ_RES_ERROR          11654
  #define DZ_RES_PASSWORD_FAIL  11655
  #define DZ_RES_PASSWORD_CANCEL 11656
  #define DZ_RES_INVAL_ZIP      11657  // ZEN_FORM
  #define DZ_RES_NO_CENTRAL     11658  // UEN_EOF01
  #define DZ_RES_ZIP_EOF        11659  // ZEN_EOF 
  #define DZ_RES_ZIP_END        11660  // UEN_EOF02
  #define DZ_RES_ZIP_NOOPEN     11661 
  #define DZ_RES_ZIP_MULTI      11662 
  #define DZ_RES_NOT_FOUND      11663
  #define DZ_RES_LOGIC_ERROR    11664  // ZEN_LOGIC
  #define DZ_RES_NOTHING_TO_DO  11665  // ZEN_NONE
  #define DZ_RES_BAD_OPTIONS    11666  // ZEN_PARM
  #define DZ_RES_TEMP_FAILED    11667  // ZEN_TEMP
  #define DZ_RES_NO_FILE_OPEN   11668  // ZEN_OPEN
  #define DZ_RES_ERROR_READ     11669  // ZEN_READ
  #define DZ_RES_ERROR_CREATE   11670  // ZEN_CREAT
  #define DZ_RES_ERROR_WRITE    11671  // ZEN_WRITE
  #define DZ_RES_ERROR_SEEK     11672 
  #define DZ_RES_EMPTY_ZIP      11673
  #define DZ_RES_INVAL_NAME     11674
  #define DZ_RES_GENERAL        11675
  #define DZ_RES_MISS           11676  // ZEN_MISS UEN_MISC03
  #define DZ_RES_WARNING        11677  // PK_WARN

  #define DZ_ERR_ERROR_DELETE   11678  // PK_NODEL
  #define DZ_ERR_FATAL_IMPORT   11679
  #define DZ_ERR_SKIPPING       11680
  #define DZ_ERR_LOCKED         11681
  #define DZ_ERR_DENIED         11682
  #define DZ_ERR_DUPNAME        11683
  
  #define DT_Last				11699

#endif

