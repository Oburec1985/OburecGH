
(******************************************************************)
(* SFX for DelZip v1.8                                            *)
(* ZipSFX                                                         *)
(* Copyright 1997, Carl Bunton  Twojags@cris.com                  *)
(*                                                                *)
(* 1998-1901 maintained by Chris Vleghert                         *)
(*                                                                *)
(* 2002-? maintained again by Markus Stephany                     *)
(* mailto:delphizip@mirkes.de                                     *)
(* http://delphizip.mirkes.de                                     *)
(*                                                                *)
(* Credits: see CREDITS.TXT                                       *)
(*                                                                *)
(* last changed: 09/19/2005                                       *)
(*                                                                *)
(* In memory of Chris Vleghert                                    *)
(*                                                                *)
(* modified by Russell Peters, Roger Aelbrecht
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

  modified 22-Nov-2008
---------------------------------------------------------------------------*)

// Changes RCV:
// Jan. 10, 1999  Adapted for D4 beta v0.99f=now v1.60
// Feb. 10, 1999  Changed the Initialization and Finalization sections
//                to include file close and CRC table.
//                ( The Crc table was not freed after an Halt. )
// Jun. 15, 2000  Added code to Dialog.pas to free a pidl, bug found by
//                Lucjan Lukasik
// Sep. 01, 2000  Added version Checked for Delphi 5 and BCB 4 and 5
// Oct. 09, 2000  Added DirExists to the function FileExists because
//                FindFirstFile does not work when there is no file on
//                a drive (e.g. an empty 'A' drive) extract to that drive
//                would not work, found by Clyde England clyde@conres.com.au

// changes mst:
// apr 2002       almost completely rewritten (or better re-cut'n'pasted...)
//                - moved routines/types/variables to appropriate units
//                - added progress bar, ability to (initially) hide the files listview
//                - removed "new directory" handling (this is handled by newer windows' themselves)
//                - added the ability to expand environment variables
//                - uses a new sfxheader instead of the MPV header; it's now a pascal record
//                - added the ability to interrupt extraction (by pressing the "X" in the caption bar)
// may 01, 2002   added the GetExeSize function from Angus Johnson's TZip-SFX to get rid of
//                caring about the executable's size
// further changes: see history.txt in the ..\doc\ directory

{ Notes:

the initial release of zipsfx comes from Carl Bunton (see above).

the first modifications came from Eric W. Engler, the author of the great freeware
delphi-vcl delzip that can handle zip-archives and -sfx's. (EEngler@zcsterling.com)

original zip-code comes from the infozip-group, they developped a free implementation
of the zip/unzip-code for unix and later for other platforms.
  Info-Zip home page:
  http://freesoftware.com/pub/infozip/Info-ZIP.html

regards, Markus Stephany
saarbrücken, saarland, germany, january 2004/september 2005

please read SFXInterface.pas for further details.


}

  (* the structure of a zipsfx-file :

  - zipsfx-executable code (0-xxxxx)
  - TSFXFileHeader record (see above)
  - possibly one or more strings (depending on the headers' properties) (not #0 terminated)
  Caption                             sfx dialog caption
  Path                                sfx default extraction path
  CmdLine                             command line to execute after extraction
  RegFailPath                         default extract path if Path could not be read from registry
  StartMsg                            startup message

  NOTE: the complete header (including the strings) must be DWORD-aligned!

  if not detached from the archive:
  - the zip archive

  if detached from the archive:
  - TSFXDetachedHeader + filename + TSFXDetachedHeader
  - centraldirectories[] + endofcentraldir of the zip archive


  *)

program ZMSFX19;
{$IFDEF UNICODE}
  cannot use Delphi 2009 or later
{$ENDIF}

{$R 'ZMSFXDLG19.res' 'ZMSFXDLG19.rc'}
{$R 'ZMSFX19.res' 'ZMSFX19.rc'}

uses
  Windows,
  ZMSFXDialogs19 in 'ZMSFXDialogs19.pas',
  ZMSFXProcs19 in 'ZMSFXProcs19.pas',
  ZMSFXInflate19 in 'ZMSFXInflate19.pas',
  ZMSFXDefs19 in 'ZMSFXDefs19.pas',
  ZMSFXInt19 in '..\ZMSFXInt19.pas',
  ZMSFXStructs19 in 'ZMSFXStructs19.pas',
  ZMSFXVars19 in 'ZMSFXVars19.pas',
  ZMSFXStrings19 in 'ZMSFXStrings19.pas',
  nvWinTrust in 'nvWinTrust.pas';

begin
  Run;
end.
