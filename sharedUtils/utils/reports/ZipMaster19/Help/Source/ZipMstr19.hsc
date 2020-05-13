HelpScribble project file.
16
_hffryy ]rgref-15SP73
112
2
TZipMaster19


2010 R.Peters
FALSE
0x0C09   Australian
d:\code\DelZip\190\vcl\Help\Source
1
BrowseButtons()
0
FALSE

FALSE
TRUE
16777215
0
16711680
8388736
255
TRUE
FALSE
FALSE
FALSE
150
50
600
500
TRUE
TRUE
2
TRUE
FALSE
Contents
%s Contents
Index
%s Index
Previous
Next
FALSE
F:\hlp_raw\zm190.html
713
10
Scribble10
ZipMaster component
ZipMaster;


:000010
Done


TZipMaster;TZipMaster_Object
FALSE
50
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss Arial;}{\f1\fswiss\fcharset0 Arial;}{\f2\froman\fcharset0 Times New Roman;}{\f3\fnil Arial;}{\f4\fnil\fcharset0 Arial;}{\f5\fswiss\fprq2\fcharset0 Arial;}{\f6\fnil\fcharset0 Arial Narrow;}}
{\colortbl ;\red255\green0\blue255;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red128\green0\blue128;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\lang3081\f0\fs20\{bmc ZipMaster.bmp\} \cf2\b\fs28 TZipMaster - Version \f1 1\f0 .\f1 90\cf0\f0\{keepn\} 
\par \f1\fs24 Main Unit\fs28 
\par          \cf3\strike\fs20 ZipMstr19.pas\cf4\strike0\{linkID=330\}\cf0\f0\fs28 
\par \pard\tx355\cf3\ul\b0\fs20 Hierarchy\ulnone\{linkID=100\}\cf2\fs16\tab\cf3\tab\strike\fs20 Properties\strike0\{linkID=380>pme\}\tab\strike Methods\strike0\{linkID=390>pme\}\tab\strike Events\strike0\{linkID=400>pme\}\strike 
\par \pard\sa195\tx355\cf0\strike0 TZipMaster is a control designed to simplify the handling of Zip compressed files.
\par \b\fs24 Description:
\par \pard\tx355\b0\fs20 TZipMaster is a non-visual VCL\lang1033\f1  component for managing zip files with some functions being a wrapper for a combined version of freeware Zip and Unzip dlls.\b\fs24  \lang3081\b0\f0\fs20  
\par At run time\f1  for zip and unzip operations\f0 , \lang1033\f1 DelZip190\lang3081\f0 .dll\lang1033\f1  \lang3081\f0 must be present on the hard disk\lang1033\f1  where the application can find it\lang3081\f0  - in \lang1033\f1 ?\lang3081\f0 :\\WINDOWS\\SYSTEM\lang1033\f1 32\lang3081\f0  or else in your application directory, or a directory in the PATH.
\par 
\par \lang1033\f1 If the \lang3081\f0 DLL\lang1033\f1  is statically linked to the component then the IDE must be able to locate and load the \lang3081\f0 DLL\lang1033\f1  .\lang3081\f0 
\par \lang1033\f1 It is also possible for an application to access a compressed version of the DLL stored in the it's resources (dynamic binding only).
\par The \lang3081\f0 DLL\lang1033\f1  is now fully re-entrant so multiple components (or applications) can share a single \lang3081\f0 DLL\lang1033\f1  .\lang3081\f0 
\par 
\par Th\lang1033\f1 i\lang3081\f0 s DLL\lang1033\f1  i\lang3081\f0 s based on the \cf3\ul InfoZip\ulnone\{linkID=20\}\cf0  Official Freeware Zip/Unzip source code, but they are NOT equivalent to InfoZip\f2 '\f0 s DLL\f2 '\f0 s. \lang1033\f1 We\lang3081\f0  have modified the InfoZip source code to enhance their ease-of-use, power, and flexibility for use with Delphi and C++ Builder.  Please do NOT contact InfoZip for issues regarding this port.
\par 
\par TZipMaster is a component that uses the \cf3\strike Add\strike0\{linkID=2530\}\cf0 , and \cf3\strike Extract\strike0\{linkID=2960\}\cf0  methods to create or add files to, and extract files from Zip archives. The component can create self-extracting archives with the \cf3\strike Convert\f1 To\f0 SFX\strike0\{linkID=2720\}\cf0  method.
\par 
\par TZipMaster can encrypt and decrypt files through the \cf3\strike Password\strike0\{linkID=1530\}\cf0  property.
\par 
\par \f1 Many operations do not require the dll.\f0 
\par 
\par The \cf3\strike OnMessage\strike0\{linkID=\f1 393\f0 0\}\cf0  event fires when the \lang1033\f1  \lang3081\f0 DLL\lang1033\f1  \lang3081\f0 report\lang1033\f1 s\lang3081\f0  status. The \cf3\strike Trace\strike0\{linkID=2080\}\cf0  and \cf3\strike Verbose\strike0\{linkID=2230\}\cf0  properties control the amount of information written to the \cf3\strike\f1 Err\f0 Message\strike0\{linkID=970\}\cf0  property.
\par \pard\cf5\f3 
\par \lang1033\b\f4\fs28 Overview  of changes v1.9 
\par     \cf0\fs20 - for specific changes see \cf3\strike Details\cf4\strike0\{linkID=90\}
\par     \cf0  - for full package file details see \cf3\strike Source files\cf4\lang2057\strike0\f5\{linkID=110\}
\par \cf6\lang1033\b0\f3 
\par \lang3081\f4   Zip extensions version 4.50 can be used.
\par \lang1033\f3 
\par \lang3081\f4   Zip file names - can use UTF8 for storing international file names.
\par 
\par   Most types and constants now are prefixed TZM or TZ
\par   
\par   Pre-D2009 to prevent corruption of international names they can be kept as UTF8.
\par   D2009 (and later) file names are converted to Unicode so no corruption should occur.
\par 
\par   NTFS file stamps can be saved or restored.
\par 
\par   The dll is now Unicode (still supports Win 98).
\par 
\par   Updated \cf3\strike SFX stub\cf4\strike0\{linkID=1925\}\cf6  with \cf3\strike support integrated into the component\cf4\strike0\{linkID=305\}\cf6 .
\par 
\par   Add or Extract with multiple streams.
\par \f3 
\par \f4    Distributed under the \cf3\b\strike\f3 GNU LESSER GENERAL PUBLIC LICENSE\cf4\strike0\{linkID=70\}\f4  \cf0 Version 3 (2007)\cf6\b0\f3 
\par \pard\tx355\cf0\i\f6\fs16 updated 2009-02-03\i0\f0\fs20 
\par 
\par }
20
Scribble20
InfoZip information
InFoZip;



Done


InfoZip
FALSE
4
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 Arial;}{\f1\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\lang3081\f0\fs20 To obtain the official\{bmc infozip.WMF\}source code consult their Website: \cf1\uldb http://freesoftware.com/pub/infozip/Info-ZIP.html\ulnone\v %!EF("http://freesoftware.com/pub/infozip/Info-ZIP.html",`',1)\cf0\v0\f1\fs24 
\par }
30
Scribble30
Bug reports
About;Author;Bugs;


browse0001:000020
Done



FALSE
120
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss Arial;}{\f1\froman\fcharset0 Times New Roman;}{\f2\fswiss\fcharset0 Arial;}{\f3\fnil Courier New;}{\f4\froman Times New Roman;}{\f5\fnil\fcharset0 Arial;}}
{\colortbl ;\red255\green0\blue255;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\lang3081\f0\fs24\{bml ZipMaster.bmp\}\cf2\b\fs28 Bug Reports\cf0\{keepn\} 
\par \cf3\b0\strike\fs20 TZipMaster\strike0\{linkID=10>main\}\cf0 
\par 
\par \b Bug reports for TZipMaster, TZipBuilder, Dll\f1 '\f0 s and the Self Extracting Code:\b0 
\par \pard\fi-845\li845\sb235\sa235\tx845\tx3685\tab\cf2\f2 DelphiZip mailing list:\tab\strike\f3 delphizip@freelists.org\cf4\strike0\{link=*! ExecFile("mailto:delphizip@freelists.org")\}\cf0\f0 
\par \pard\sb115\sa595\tx845\tx3685\cf5\b\f2\tab\cf2\b0 Join the mailing list:\tab\strike\f3 http://www.freelists.org/list/delphizip\cf4\strike0\{link=*! ExecFile("http://www.freelists.org/list/delphizip")\}\cf2\f2  \f0 
\par \cf5\b When reporting bugs please mention: your Delphi or C++Builder version, Your ZipMaster or ZipBuilder version and the operating system you are using.
\par 
\par \pard\tx845\tx3685\cf0 For errors in the translation of ZipMaster and ZipBuilder resource files:
\par \b0 
\par \pard\fi-845\li845\tx845\tab Brazilian (Portuguese) translation found in ZipMsgBR.rc and ZipMsgBR.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Jo\f2\'e3o Alexandre de Toledo:\cf2\f0\fs16\tab\strike\f2\fs20 j.toledo\f0 @\f2 uol.com.br\strike0\f0\{link=*! ExecFile("mailto:j.toledo@uol.com.br",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Chinese (\fs18 People Republic of China)\fs20  translation found in ZipMsgCN.rc and ZipMsgCN.res\b 
\par \b0\tab [ GB(K) - commonly used in China and Singapore for simplified Chinese writing.]\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab wxf.amm:\tab\cf2\strike wxf.amm@usa.net\strike0\{link=*! ExecFile("mailto:wxf.amm@usa.net",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Catalan translation found in ZipMsgCT.rc and ZipMsgCT.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab\f2 Xavier Mor-Mur:\f0\tab\cf2\strike\f2 xmormur\f0 @tele\f2 polis.com\strike0\f0\{link=*! ExecFile("mailto:xmormur@telepolis.com",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Czech translation found in ZipMsgCZ.rc and ZipMsgCZ.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Ivo Eichler:\tab\cf2\strike eichler@sce.cz\strike0\{link=*! ExecFile("mailto:eichler@sce.cz",`',1)\}\cf0 
\par \pard\fi-845\li845\tx845 
\par \tab Danish translation found in ZipMsgDK.rc and ZipMsgDK.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Nicolaj:\tab\cf2\strike nikse@post11.tele.dk\strike0\{link=*! ExecFile("mailto:cvleghrt@worldonline.nl",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Dutch translation found in ZipMsgNL.rc and ZipMsgNL.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Roger Aelbrecht:\tab\cf2\strike\f2 zipbuilder\f0 @\f2 drehoeksw.net\strike0\f0\{link=*! ExecFile("mailto:Zipbuilder@drehoeksw.net",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Finnish translation found in ZipMsgFI.rc and ZipMsgFI.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Jussi Siponen:\tab\cf2\strike JIS@online.tietokone.fi\strike0\{link=*! ExecFile("mailto:JIS@online.tietokone.fi",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab French translation found in ZipMsgFR.rc and ZipMsgFR.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Laurent Hilsz:\tab\cf2\strike hlcd@wanadoo.fr\strike0\{link=*! ExecFile("mailto:hlcd@wanadoo.fr",`',1)\}\cf0  or  \cf2\strike hilsz@piedte.cea.fr\strike0\{link=*! ExecFile("mailto:hilsz@piedte.cea.fr",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab German translation found in ZipMsgDE.rc and ZipMsgDE.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Roland Ruder:\tab\cf2\strike r.ruder@gmx.de\strike0\{link=*! ExecFile("mailto:r.ruder@gmx.de",`',1)\}
\par \f2\tab\cf0  latest update by Winfried Posur: \cf2\strike WPosur@t-online.de\strike0\{link=%!ExecFile("MailTo: WPosur@t-online.de",`',1)\}\cf0\f0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Greek translation found in ZipMsgGR.rc and ZipMsgGR.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab x_gate:\tab\cf2\strike gate7__@hotmail.com\strike0\{link=*! ExecFile("mailto:gate7__@hotmail.com",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Hungarian translation found in ZipMsgHU.rc and ZipMsgHU.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab\f2 S\'f3lya Zolt\'e1n:\f4  \f0\tab 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Italian translation found in ZipMsgIT.rc and ZipMsgIT.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Fabrizio Atza:\tab\cf2\strike faatza@tin.it\strike0\{link=*! ExecFile("mailto:faatza@tin.it",`',1)\}
\par 
\par \f2               \cf0\f0 Japanese translation found in ZipMsgJP.rc and ZipMsgJP.res
\par \cf2 
\par \cf0\f2               \f0 Korean translation found in ZipMsgKO.rc and ZipMsgKO.res\cf2 
\par \tab\cf0 Yun,BokSoo:\cf2  \f2\tab\strike\f0 woodcom@kebi.com\strike0\{link=%!E\f2 xec\f0 F\f2 ile\f0 ("MailTo:woodcom@kebi.com",`',1)\}
\par \pard\tx1125\tx3685\cf0 
\par \pard\fi-845\li845\tx845\tab Malaysia translation found in ZipMsgMY.rc and ZipMsgMY.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Azrin Aris:\tab\cf2\strike azrin@rndtm.net.my\strike0\{link=*! ExecFile("mailto:azrin@rndtm.net.my",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Norwegian translation found in ZipMsgNO.rc and ZipMsgNO.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Vegard Larsen:\tab\cf2\strike veglar@frisurf.no\strike0\{link=*! ExecFile("mailto:veglar@frisurf.no",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Polish translation found in ZipMsgPL.rc and ZipMsgPL.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Marcin Koteras:\tab\cf2\strike bacik@pluton.farm.amwaw.edu.pl\strike0\{link=*! ExecFile("mailto:bacik@pluton.farm.amwaw.edu.pl",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Romanian translation found in ZipMsgRO.rc\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Cristian Musat:\tab\cf2\strike cristianm@bcr.ro\strike0\{link=*! ExecFile("mailto:bacik@pluton.farm.amwaw.edu.pl",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Russian translation found in ZipMsgRU.rc and ZipMsgRU.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Alex Ozerov:\cf2\fs16\tab\strike\fs20 ozerov@aha.ru\strike0\{link=*! ExecFile("mailto:ozerov@aha.ru",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Serbian/Yugoslavia translation found in ZipMsgYU.rc and ZipMsgYU.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Dejan Maksimovic:\cf2\fs16\tab\strike\fs20 dmaksimovic@yahoo.com\strike0\{link=*! ExecFile("mailto:dmaksimovic@yahoo.com",`',1)\}\cf0  or \cf2\strike maksa@cent.co.yu\strike0\{link=*! ExecFile("mailto:maksa@cent.co.yu",`',1)\}
\par 
\par \pard\fi-1100\li1100\tx840\tx1100\tx3660\cf0\f2\tab\f0 Slovenian translation found in ZipMsgSI.rc and ZipMsgSI.res\fs16 
\par \pard\tx1125\tx3685\fs20 
\par \pard\fi-845\li845\tx845\tab Spanish translation found in ZipMsg\f2 ES\f0 .rc and ZipMsg\f2 ES\f0 .res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Xavier Mor-Mur:\cf2\fs16\tab\strike\fs20 xmormur@telepolis.com\strike0\{link=*! ExecFile("mailto:xmormur@telepolis.com",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Swedish translation found in ZipMsgSW.rc and ZipMsgSW.res\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Johan Lindgren:\cf2\fs16\tab\strike\fs20 johan.lindgren@tt.se\strike0\{link=*! ExecFile("mailto:johan.lindgren@tt.se",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Taiwanese (Traditional Chinese) translation found in ZipMsgTW.rc and ZipMsgTW.res\b 
\par \b0\tab [ Big5 - commonly used in Taiwan and Hong Kong for traditional Chinese writing.]\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab HuanlinTsai:\cf2\fs16\tab\strike\fs20 huanlin_tsai@yahoo.com\strike0\{link=*! ExecFile("mailto:huanlin_tsai@yahoo.com",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \b For errors in the translation of the SFX resources and source files:
\par \b0 
\par \pard\fi-845\li845\tx845\tab Brazilian (Portuguese) translation found in SFXstr_BR.txt\b 
\par \pard\tx1125\tx3685\b0 
\par \pard\fi-845\li845\tx845\tab Catalan SFX translation as found in SFXstr_CAT.txt\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab\f2 Xavier Mor-Mur:\f0\tab\cf2\strike xmormur@telepolis.com\strike0\{link=*! ExecFile("mailto:xmormur@telepolis.com",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Danish translation found in SFXstr_DK.txt\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Carsten S. Rasmussen
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Dutch translation found in SFXstr_NL.txt\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Roger Aelbrecht: \f2\tab\cf2\strike\f0 Zipbuilder@drehoeksw.net\strike0\{link=%!E\f2 xec\f0 F\f2 ile\f0 ("MailTo: Zipbuilder@drehoeksw.net",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab French translation found in SFXstr_FR.txt\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Nicolas Mastin
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab German translation found in SFXstr_DE.txt\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Roland Ruder:\tab\cf2\strike r.ruder@gmx.de\strike0\{link=*!ExecFile("mailto: r.ruder@gmx.de",`',1)\}\cf0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Hungarian translation found in SFXstr_HU.txt\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab S\f2\'f3lya Zolt\'e1n\f0 
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Italian translation found in SFXstr_IT.txt\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Matteo Riso
\par \pard\tx1125\tx3685 
\par \pard\fi-845\li845\tx845\tab Korean translation found in SFXstr_KO.txt\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab Yun,BokSoo : \f2\tab\cf2\strike\f0 woodcom@kebi.com\strike0\{link=%!E\f2 xec\f0 F\f2 ile\f0 ("MailTo:woodcom@kebi.com",`',1)\}
\par \pard\tx1125\tx3685\cf0 
\par \pard\fi-845\li845\tx845\tab Polish SFX translation as found in SFXstr_PL.txt\b 
\par \pard\tx1140\tx3640\tx3660\b0\f2\tab\f0 Marcin Koteras:\tab\cf2\strike bacik@pluton.farm.amwaw.edu.pl\strike0\{link=*! ExecFile("mailto:bacik@pluton.farm.amwaw.edu.pl",`',1)\}\cf0 
\par \pard\tx2975 
\par \pard\fi-845\li845\tx845\tab Spanish SFX translation as found in SFXstr_ES.txt\b 
\par \pard\fi-1125\li1125\tx1125\tx3685\b0\tab\f5 Jorge Almaraz\f0 
\par 
\par }
40
TZipMaster_Contact
Contact information
Contact information;


browse0001:000010
Done


TZipMaster_Contact
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red255\green0\blue255;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red0\green0\blue128;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\lang3081\f0\fs24\{bml ZipMaster.bmp\}\cf2\b\fs28 Contact \{keepn\} Information
\par \cf3\b0\strike\fs20 TZipMaster\strike0\{linkID=10>main\}\cf2 
\par \cf0 
\par \b The latest version of TZipMaster, TZipBuilder and additional information such as bug fixes is available from:
\par \cf2\b0\strike\f1 http://www.delphizip.\lang1033\f2 org\cf4\lang3081\strike0\f1\{link=*! ExecFile("http://www.delphizip.\lang1033\f2 org\lang3081\f1 ")\}\cf0\b\f0 
\par \pard\tx1125\cf5\b0\i 
\par \cf0\i0 
\par \pard\tx715\tx1435\tx2155\tx2875\tx3595\tx4315\tx5035\tx5755\tx6475\tx7195\cf5\i Please forward any \cf6 comments or suggestions\cf5  to \f3 support list\f0  at:
\par \pard\fi-1125\li1125\tx1125\tx3685\i0 e-mail:\cf0\tab\cf2\strike\f1 delphizip@freelists.org\cf4\strike0\{link=*! ExecFile("\lang1033\f2 m\lang3081\f1 ail\lang1033\f2 t\lang3081\f1 o:delphizip@freelists.org")\}\cf7\b\f3 
\par \pard\sb115\sa595\tx845\tx3685\cf0\b0 Join the mailing list: \cf2\strike\f1 http://www.freelists.org/list/delphizip\cf4\strike0\{link=*! ExecFile("http://www.freelists.org/list/delphizip")\}\cf2\f3  \f0 
\par \pard\fi-1125\li1125\tx1125\tx3685\cf4\f1 
\par \cf0\lang1033\b\f2 or\cf4\b0 
\par  \tab\cf2\strike problems\f1 @delphizip.\f2 org\cf4\strike0\f1\{link=*! ExecFile("mailto:\f2 problems\f1 @delphizip.\f2 org\f1 ")\}\lang3081\f2   \cf7\b\f3 (include ZipMaster in the subject)
\par \cf5\b0\f0 
\par }
50
Scribble50
Copyright and distribution policy
Copyright;Distribution;


browse0001:000030
Done



FALSE
23
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss Arial;}{\f1\fswiss\fcharset0 Arial;}{\f2\froman\fcharset0 Times New Roman;}{\f3\fnil\fcharset0 Arial;}{\f4\fnil Arial;}}
{\colortbl ;\red255\green0\blue255;\red0\green0\blue255;\red0\green128\blue0;\red0\green0\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\lang3081\f0\fs24\{bml ZipMaster.bmp\}\cf2\b\fs28 Distribution Policy, Guidelines for Legal Re-distribution \{keepn\}
\par \cf3\b0\strike\fs20 TZipMaster\strike0\{linkID=10>main\}\cf2 
\par \cf0\b 
\par \pard\fi-275\li275\tx275 1\b0 .\tab This applies to both end-users and developers.  The meat of this package is the .DLL file\f1  that is\f0  needed by all of your end-users if you use this ZIP package in your program.
\par 
\par \b 2\b0 .\tab You must not charge money for any part of the ZIP package. Warning:  The primary concern here is if you will market a new package that is only slightly more than a verbatim copy of this package, or one of it's demos.  ANY release you sell is OK as long as you charge ONLY for the changes you make.
\par 
\par \b 3\b0 .\tab You MUST either distribute the source code for this ZIP package, or give a WWW site where it can be obtained freely. This can be on a Help...About screen, in printed documentation, or in text files distributed with your package.  Yes, it does seem odd to have this requirement for end-users who aren't programmers, but there is no mistake.  After all, it isn't hard to give them a URL and a few words explaining what it is for.
\par 
\par \b 4\b0 .\tab You must document the \cf3\ul Info-Zip\f2 '\f0 s\ulnone\{linkID=20\}\cf0  WWW home page URL, but don't expect any help from the Info-Zip group, since my release is only a derivative of their work.  They are very busy doing support for their "official" releases. Since much of the DLL source code comes from them, they deserve to be mentioned.
\par 
\par \b 5\b0 .\tab You must handle product support with your own end-users. This is needed because I don't have enough time to do support for end-users.
\par 
\par \b 6\b0 .\tab I will handle support issues with programmers using this package on a time-available basis. Since this is being distributed as freeware, you can't expect the kind of support you'd get from a commercial vendor.  Please limit your questions to those that directly pertain to this ZIP package.
\par 
\par \b 7\b0 .\tab You may NOT distribute executable versions of my demo programs to end-users without my approval.  These are only example applications to teach you how to use this package.
\par 
\par \f1 8.\tab Distributed \cf4\f3 under the \cf3\b\strike\f4 GNU LESSER GENERAL PUBLIC LICENSE\cf5\strike0\{linkID=70\}
\par \cf0\b0\f1  \f0 
\par 
\par }
60
Scribble60
Thanks



browse0001:000050
Done



FALSE
30
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss Arial;}{\f1\fswiss\fcharset0 Arial;}}
{\colortbl ;\red255\green0\blue255;\red0\green0\blue255;\red0\green128\blue0;\red0\green0\blue128;\red0\green0\blue0;}
\viewkind4\uc1\pard\ri2760\sa115\qc\cf1\lang3081\f0\fs24\{bml ZipMaster.bmp\}\cf2\b\fs28\{keepn\} Thanks...
\par \pard\cf3\b0\strike\fs20 TZipMaster\strike0\{linkID=10>main\}\cf2 
\par \pard\tx715\tx1435\tx2155\tx2875\tx3595\tx4315\tx5035\tx5755\tx6475\tx7195\cf0\b 
\par \cf4 A big THANKS to all those who helped me and/or suggested improvements along the way:
\par \pard\tx5665\cf5\b0 
\par \pard\tx275\tx2835\tab\f1 Roger Aelbrecht\f0 
\par \f1     \f0 Raymond Allan
\par \tab J.A. Bijsterbosch
\par \tab Tim Borman
\par \tab Sam Chan
\par \tab Julien Ferraro
\par \tab Sebastian Hildebrandt
\par \tab Alexander Hofmann
\par \tab Jim Hoops
\par \tab Teus de Jong
\par \tab Matthew Kent
\par \tab Greg Lorriman
\par \tab Harald Marschalek
\par \tab Almer.S. Tigelaar
\par \tab Kenan Uzay
\par \tab\f1 Jo\'e3o Lira\f0 
\par \tab Bob Dolan
\par 
\par \f1 In memory of
\par     Chris Vleghert,
\par \tab Eric W. Engler\f0 
\par 
\par }
70
Scribble70
Licence
Copyright;Licence;


browse0001:000040
Done



FALSE
173
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Licence\cf2\b0\f1\fs20 
\par \cf0\f2\fs24 See also: \cf3\strike GNU GENERAL PUBLIC LICENSE\cf4\strike0\{linkID=80\}\cf3\ul 
\par \cf2\ulnone\f1\fs20 
\par \f0\tab    GNU LESSER GENERAL PUBLIC LICENSE
\par                        Version 3, 29 June 2007
\par 
\par  Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
\par  Everyone is permitted to copy and distribute verbatim copies
\par  of this license document, but changing it is not allowed.
\par 
\par 
\par   This version of the GNU Lesser General Public License incorporates
\par the terms and conditions of version 3 of the GNU General Public
\par License, supplemented by the additional permissions listed below.
\par 
\par   0. Additional Definitions.
\par 
\par   As used herein, "this License" refers to version 3 of the GNU Lesser
\par General Public License, and the "GNU GPL" refers to version 3 of the GNU
\par General Public License.
\par 
\par   "The Library" refers to a covered work governed by this License,
\par other than an Application or a Combined Work as defined below.
\par 
\par   An "Application" is any work that makes use of an interface provided
\par by the Library, but which is not otherwise based on the Library.
\par Defining a subclass of a class defined by the Library is deemed a mode
\par of using an interface provided by the Library.
\par 
\par   A "Combined Work" is a work produced by combining or linking an
\par Application with the Library.  The particular version of the Library
\par with which the Combined Work was made is also called the "Linked
\par Version".
\par 
\par   The "Minimal Corresponding Source" for a Combined Work means the
\par Corresponding Source for the Combined Work, excluding any source code
\par for portions of the Combined Work that, considered in isolation, are
\par based on the Application, and not on the Linked Version.
\par 
\par   The "Corresponding Application Code" for a Combined Work means the
\par object code and/or source code for the Application, including any data
\par and utility programs needed for reproducing the Combined Work from the
\par Application, but excluding the System Libraries of the Combined Work.
\par 
\par   1. Exception to Section 3 of the GNU GPL.
\par 
\par   You may convey a covered work under sections 3 and 4 of this License
\par without being bound by section 3 of the GNU GPL.
\par 
\par   2. Conveying Modified Versions.
\par 
\par   If you modify a copy of the Library, and, in your modifications, a
\par facility refers to a function or data to be supplied by an Application
\par that uses the facility (other than as an argument passed when the
\par facility is invoked), then you may convey a copy of the modified
\par version:
\par 
\par    a) under this License, provided that you make a good faith effort to
\par    ensure that, in the event an Application does not supply the
\par    function or data, the facility still operates, and performs
\par    whatever part of its purpose remains meaningful, or
\par 
\par    b) under the GNU GPL, with none of the additional permissions of
\par    this License applicable to that copy.
\par 
\par   3. Object Code Incorporating Material from Library Header Files.
\par 
\par   The object code form of an Application may incorporate material from
\par a header file that is part of the Library.  You may convey such object
\par code under terms of your choice, provided that, if the incorporated
\par material is not limited to numerical parameters, data structure
\par layouts and accessors, or small macros, inline functions and templates
\par (ten or fewer lines in length), you do both of the following:
\par 
\par    a) Give prominent notice with each copy of the object code that the
\par    Library is used in it and that the Library and its use are
\par    covered by this License.
\par 
\par    b) Accompany the object code with a copy of the GNU GPL and this license
\par    document.
\par 
\par   4. Combined Works.
\par 
\par   You may convey a Combined Work under terms of your choice that,
\par taken together, effectively do not restrict modification of the
\par portions of the Library contained in the Combined Work and reverse
\par engineering for debugging such modifications, if you also do each of
\par the following:
\par 
\par    a) Give prominent notice with each copy of the Combined Work that
\par    the Library is used in it and that the Library and its use are
\par    covered by this License.
\par 
\par    b) Accompany the Combined Work with a copy of the GNU GPL and this license
\par    document.
\par 
\par    c) For a Combined Work that displays copyright notices during
\par    execution, include the copyright notice for the Library among
\par    these notices, as well as a reference directing the user to the
\par    copies of the GNU GPL and this license document.
\par 
\par    d) Do one of the following:
\par 
\par        0) Convey the Minimal Corresponding Source under the terms of this
\par        License, and the Corresponding Application Code in a form
\par        suitable for, and under terms that permit, the user to
\par        recombine or relink the Application with a modified version of
\par        the Linked Version to produce a modified Combined Work, in the
\par        manner specified by section 6 of the GNU GPL for conveying
\par        Corresponding Source.
\par 
\par        1) Use a suitable shared library mechanism for linking with the
\par        Library.  A suitable mechanism is one that (a) uses at run time
\par        a copy of the Library already present on the user's computer
\par        system, and (b) will operate properly with a modified version
\par        of the Library that is interface-compatible with the Linked
\par        Version.
\par 
\par    e) Provide Installation Information, but only if you would otherwise
\par    be required to provide such information under section 6 of the
\par    GNU GPL, and only to the extent that such information is
\par    necessary to install and execute a modified version of the
\par    Combined Work produced by recombining or relinking the
\par    Application with a modified version of the Linked Version. (If
\par    you use option 4d0, the Installation Information must accompany
\par    the Minimal Corresponding Source and Corresponding Application
\par    Code. If you use option 4d1, you must provide the Installation
\par    Information in the manner specified by section 6 of the GNU GPL
\par    for conveying Corresponding Source.)
\par 
\par   5. Combined Libraries.
\par 
\par   You may place library facilities that are a work based on the
\par Library side by side in a single library together with other library
\par facilities that are not Applications and are not covered by this
\par License, and convey such a combined library under terms of your
\par choice, if you do both of the following:
\par 
\par    a) Accompany the combined library with a copy of the same work based
\par    on the Library, uncombined with any other library facilities,
\par    conveyed under the terms of this License.
\par 
\par    b) Give prominent notice with the combined library that part of it
\par    is a work based on the Library, and explaining where to find the
\par    accompanying uncombined form of the same work.
\par 
\par   6. Revised Versions of the GNU Lesser General Public License.
\par 
\par   The Free Software Foundation may publish revised and/or new versions
\par of the GNU Lesser General Public License from time to time. Such new
\par versions will be similar in spirit to the present version, but may
\par differ in detail to address new problems or concerns.
\par 
\par   Each version is given a distinguishing version number. If the
\par Library as you received it specifies that a certain numbered version
\par of the GNU Lesser General Public License "or any later version"
\par applies to it, you have the option of following the terms and
\par conditions either of that published version or of any later version
\par published by the Free Software Foundation. If the Library as you
\par received it does not specify a version number of the GNU Lesser
\par General Public License, you may choose any version of the GNU Lesser
\par General Public License ever published by the Free Software Foundation.
\par 
\par   If the Library as you received it specifies that a proxy can decide
\par whether future versions of the GNU Lesser General Public License shall
\par apply, that proxy's public statement of acceptance of any version is
\par permanent authorization for you to choose that version for the
\par Library.
\par 
\par \f1 
\par }
80
Scribble80
GNU General Public License




Done



FALSE
627
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 GNU General Public License
\par \cf2\b0\f1\fs20 
\par \f0                      GNU GENERAL PUBLIC LICENSE
\par                        Version 3, 29 June 2007
\par 
\par  Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
\par  Everyone is permitted to copy and distribute verbatim copies
\par  of this license document, but changing it is not allowed.
\par 
\par                             Preamble
\par 
\par   The GNU General Public License is a free, copyleft license for
\par software and other kinds of works.
\par 
\par   The licenses for most software and other practical works are designed
\par to take away your freedom to share and change the works.  By contrast,
\par the GNU General Public License is intended to guarantee your freedom to
\par share and change all versions of a program--to make sure it remains free
\par software for all its users.  We, the Free Software Foundation, use the
\par GNU General Public License for most of our software; it applies also to
\par any other work released this way by its authors.  You can apply it to
\par your programs, too.
\par 
\par   When we speak of free software, we are referring to freedom, not
\par price.  Our General Public Licenses are designed to make sure that you
\par have the freedom to distribute copies of free software (and charge for
\par them if you wish), that you receive source code or can get it if you
\par want it, that you can change the software or use pieces of it in new
\par free programs, and that you know you can do these things.
\par 
\par   To protect your rights, we need to prevent others from denying you
\par these rights or asking you to surrender the rights.  Therefore, you have
\par certain responsibilities if you distribute copies of the software, or if
\par you modify it: responsibilities to respect the freedom of others.
\par 
\par   For example, if you distribute copies of such a program, whether
\par gratis or for a fee, you must pass on to the recipients the same
\par freedoms that you received.  You must make sure that they, too, receive
\par or can get the source code.  And you must show them these terms so they
\par know their rights.
\par 
\par   Developers that use the GNU GPL protect your rights with two steps:
\par (1) assert copyright on the software, and (2) offer you this License
\par giving you legal permission to copy, distribute and/or modify it.
\par 
\par   For the developers' and authors' protection, the GPL clearly explains
\par that there is no warranty for this free software.  For both users' and
\par authors' sake, the GPL requires that modified versions be marked as
\par changed, so that their problems will not be attributed erroneously to
\par authors of previous versions.
\par 
\par   Some devices are designed to deny users access to install or run
\par modified versions of the software inside them, although the manufacturer
\par can do so.  This is fundamentally incompatible with the aim of
\par protecting users' freedom to change the software.  The systematic
\par pattern of such abuse occurs in the area of products for individuals to
\par use, which is precisely where it is most unacceptable.  Therefore, we
\par have designed this version of the GPL to prohibit the practice for those
\par products.  If such problems arise substantially in other domains, we
\par stand ready to extend this provision to those domains in future versions
\par of the GPL, as needed to protect the freedom of users.
\par 
\par   Finally, every program is threatened constantly by software patents.
\par States should not allow patents to restrict development and use of
\par software on general-purpose computers, but in those that do, we wish to
\par avoid the special danger that patents applied to a free program could
\par make it effectively proprietary.  To prevent this, the GPL assures that
\par patents cannot be used to render the program non-free.
\par 
\par   The precise terms and conditions for copying, distribution and
\par modification follow.
\par 
\par                        TERMS AND CONDITIONS
\par 
\par   0. Definitions.
\par 
\par   "This License" refers to version 3 of the GNU General Public License.
\par 
\par   "Copyright" also means copyright-like laws that apply to other kinds of
\par works, such as semiconductor masks.
\par 
\par   "The Program" refers to any copyrightable work licensed under this
\par License.  Each licensee is addressed as "you".  "Licensees" and
\par "recipients" may be individuals or organizations.
\par 
\par   To "modify" a work means to copy from or adapt all or part of the work
\par in a fashion requiring copyright permission, other than the making of an
\par exact copy.  The resulting work is called a "modified version" of the
\par earlier work or a work "based on" the earlier work.
\par 
\par   A "covered work" means either the unmodified Program or a work based
\par on the Program.
\par 
\par   To "propagate" a work means to do anything with it that, without
\par permission, would make you directly or secondarily liable for
\par infringement under applicable copyright law, except executing it on a
\par computer or modifying a private copy.  Propagation includes copying,
\par distribution (with or without modification), making available to the
\par public, and in some countries other activities as well.
\par 
\par   To "convey" a work means any kind of propagation that enables other
\par parties to make or receive copies.  Mere interaction with a user through
\par a computer network, with no transfer of a copy, is not conveying.
\par 
\par   An interactive user interface displays "Appropriate Legal Notices"
\par to the extent that it includes a convenient and prominently visible
\par feature that (1) displays an appropriate copyright notice, and (2)
\par tells the user that there is no warranty for the work (except to the
\par extent that warranties are provided), that licensees may convey the
\par work under this License, and how to view a copy of this License.  If
\par the interface presents a list of user commands or options, such as a
\par menu, a prominent item in the list meets this criterion.
\par 
\par   1. Source Code.
\par 
\par   The "source code" for a work means the preferred form of the work
\par for making modifications to it.  "Object code" means any non-source
\par form of a work.
\par 
\par   A "Standard Interface" means an interface that either is an official
\par standard defined by a recognized standards body, or, in the case of
\par interfaces specified for a particular programming language, one that
\par is widely used among developers working in that language.
\par 
\par   The "System Libraries" of an executable work include anything, other
\par than the work as a whole, that (a) is included in the normal form of
\par packaging a Major Component, but which is not part of that Major
\par Component, and (b) serves only to enable use of the work with that
\par Major Component, or to implement a Standard Interface for which an
\par implementation is available to the public in source code form.  A
\par "Major Component", in this context, means a major essential component
\par (kernel, window system, and so on) of the specific operating system
\par (if any) on which the executable work runs, or a compiler used to
\par produce the work, or an object code interpreter used to run it.
\par 
\par   The "Corresponding Source" for a work in object code form means all
\par the source code needed to generate, install, and (for an executable
\par work) run the object code and to modify the work, including scripts to
\par control those activities.  However, it does not include the work's
\par System Libraries, or general-purpose tools or generally available free
\par programs which are used unmodified in performing those activities but
\par which are not part of the work.  For example, Corresponding Source
\par includes interface definition files associated with source files for
\par the work, and the source code for shared libraries and dynamically
\par linked subprograms that the work is specifically designed to require,
\par such as by intimate data communication or control flow between those
\par subprograms and other parts of the work.
\par 
\par   The Corresponding Source need not include anything that users
\par can regenerate automatically from other parts of the Corresponding
\par Source.
\par 
\par   The Corresponding Source for a work in source code form is that
\par same work.
\par 
\par   2. Basic Permissions.
\par 
\par   All rights granted under this License are granted for the term of
\par copyright on the Program, and are irrevocable provided the stated
\par conditions are met.  This License explicitly affirms your unlimited
\par permission to run the unmodified Program.  The output from running a
\par covered work is covered by this License only if the output, given its
\par content, constitutes a covered work.  This License acknowledges your
\par rights of fair use or other equivalent, as provided by copyright law.
\par 
\par   You may make, run and propagate covered works that you do not
\par convey, without conditions so long as your license otherwise remains
\par in force.  You may convey covered works to others for the sole purpose
\par of having them make modifications exclusively for you, or provide you
\par with facilities for running those works, provided that you comply with
\par the terms of this License in conveying all material for which you do
\par not control copyright.  Those thus making or running the covered works
\par for you must do so exclusively on your behalf, under your direction
\par and control, on terms that prohibit them from making any copies of
\par your copyrighted material outside their relationship with you.
\par 
\par   Conveying under any other circumstances is permitted solely under
\par the conditions stated below.  Sublicensing is not allowed; section 10
\par makes it unnecessary.
\par 
\par   3. Protecting Users' Legal Rights From Anti-Circumvention Law.
\par 
\par   No covered work shall be deemed part of an effective technological
\par measure under any applicable law fulfilling obligations under article
\par 11 of the WIPO copyright treaty adopted on 20 December 1996, or
\par similar laws prohibiting or restricting circumvention of such
\par measures.
\par 
\par   When you convey a covered work, you waive any legal power to forbid
\par circumvention of technological measures to the extent such circumvention
\par is effected by exercising rights under this License with respect to
\par the covered work, and you disclaim any intention to limit operation or
\par modification of the work as a means of enforcing, against the work's
\par users, your or third parties' legal rights to forbid circumvention of
\par technological measures.
\par 
\par   4. Conveying Verbatim Copies.
\par 
\par   You may convey verbatim copies of the Program's source code as you
\par receive it, in any medium, provided that you conspicuously and
\par appropriately publish on each copy an appropriate copyright notice;
\par keep intact all notices stating that this License and any
\par non-permissive terms added in accord with section 7 apply to the code;
\par keep intact all notices of the absence of any warranty; and give all
\par recipients a copy of this License along with the Program.
\par 
\par   You may charge any price or no price for each copy that you convey,
\par and you may offer support or warranty protection for a fee.
\par 
\par   5. Conveying Modified Source Versions.
\par 
\par   You may convey a work based on the Program, or the modifications to
\par produce it from the Program, in the form of source code under the
\par terms of section 4, provided that you also meet all of these conditions:
\par 
\par     a) The work must carry prominent notices stating that you modified
\par     it, and giving a relevant date.
\par 
\par     b) The work must carry prominent notices stating that it is
\par     released under this License and any conditions added under section
\par     7.  This requirement modifies the requirement in section 4 to
\par     "keep intact all notices".
\par 
\par     c) You must license the entire work, as a whole, under this
\par     License to anyone who comes into possession of a copy.  This
\par     License will therefore apply, along with any applicable section 7
\par     additional terms, to the whole of the work, and all its parts,
\par     regardless of how they are packaged.  This License gives no
\par     permission to license the work in any other way, but it does not
\par     invalidate such permission if you have separately received it.
\par 
\par     d) If the work has interactive user interfaces, each must display
\par     Appropriate Legal Notices; however, if the Program has interactive
\par     interfaces that do not display Appropriate Legal Notices, your
\par     work need not make them do so.
\par 
\par   A compilation of a covered work with other separate and independent
\par works, which are not by their nature extensions of the covered work,
\par and which are not combined with it such as to form a larger program,
\par in or on a volume of a storage or distribution medium, is called an
\par "aggregate" if the compilation and its resulting copyright are not
\par used to limit the access or legal rights of the compilation's users
\par beyond what the individual works permit.  Inclusion of a covered work
\par in an aggregate does not cause this License to apply to the other
\par parts of the aggregate.
\par 
\par   6. Conveying Non-Source Forms.
\par 
\par   You may convey a covered work in object code form under the terms
\par of sections 4 and 5, provided that you also convey the
\par machine-readable Corresponding Source under the terms of this License,
\par in one of these ways:
\par 
\par     a) Convey the object code in, or embodied in, a physical product
\par     (including a physical distribution medium), accompanied by the
\par     Corresponding Source fixed on a durable physical medium
\par     customarily used for software interchange.
\par 
\par     b) Convey the object code in, or embodied in, a physical product
\par     (including a physical distribution medium), accompanied by a
\par     written offer, valid for at least three years and valid for as
\par     long as you offer spare parts or customer support for that product
\par     model, to give anyone who possesses the object code either (1) a
\par     copy of the Corresponding Source for all the software in the
\par     product that is covered by this License, on a durable physical
\par     medium customarily used for software interchange, for a price no
\par     more than your reasonable cost of physically performing this
\par     conveying of source, or (2) access to copy the
\par     Corresponding Source from a network server at no charge.
\par 
\par     c) Convey individual copies of the object code with a copy of the
\par     written offer to provide the Corresponding Source.  This
\par     alternative is allowed only occasionally and noncommercially, and
\par     only if you received the object code with such an offer, in accord
\par     with subsection 6b.
\par 
\par     d) Convey the object code by offering access from a designated
\par     place (gratis or for a charge), and offer equivalent access to the
\par     Corresponding Source in the same way through the same place at no
\par     further charge.  You need not require recipients to copy the
\par     Corresponding Source along with the object code.  If the place to
\par     copy the object code is a network server, the Corresponding Source
\par     may be on a different server (operated by you or a third party)
\par     that supports equivalent copying facilities, provided you maintain
\par     clear directions next to the object code saying where to find the
\par     Corresponding Source.  Regardless of what server hosts the
\par     Corresponding Source, you remain obligated to ensure that it is
\par     available for as long as needed to satisfy these requirements.
\par 
\par     e) Convey the object code using peer-to-peer transmission, provided
\par     you inform other peers where the object code and Corresponding
\par     Source of the work are being offered to the general public at no
\par     charge under subsection 6d.
\par 
\par   A separable portion of the object code, whose source code is excluded
\par from the Corresponding Source as a System Library, need not be
\par included in conveying the object code work.
\par 
\par   A "User Product" is either (1) a "consumer product", which means any
\par tangible personal property which is normally used for personal, family,
\par or household purposes, or (2) anything designed or sold for incorporation
\par into a dwelling.  In determining whether a product is a consumer product,
\par doubtful cases shall be resolved in favor of coverage.  For a particular
\par product received by a particular user, "normally used" refers to a
\par typical or common use of that class of product, regardless of the status
\par of the particular user or of the way in which the particular user
\par actually uses, or expects or is expected to use, the product.  A product
\par is a consumer product regardless of whether the product has substantial
\par commercial, industrial or non-consumer uses, unless such uses represent
\par the only significant mode of use of the product.
\par 
\par   "Installation Information" for a User Product means any methods,
\par procedures, authorization keys, or other information required to install
\par and execute modified versions of a covered work in that User Product from
\par a modified version of its Corresponding Source.  The information must
\par suffice to ensure that the continued functioning of the modified object
\par code is in no case prevented or interfered with solely because
\par modification has been made.
\par 
\par   If you convey an object code work under this section in, or with, or
\par specifically for use in, a User Product, and the conveying occurs as
\par part of a transaction in which the right of possession and use of the
\par User Product is transferred to the recipient in perpetuity or for a
\par fixed term (regardless of how the transaction is characterized), the
\par Corresponding Source conveyed under this section must be accompanied
\par by the Installation Information.  But this requirement does not apply
\par if neither you nor any third party retains the ability to install
\par modified object code on the User Product (for example, the work has
\par been installed in ROM).
\par 
\par   The requirement to provide Installation Information does not include a
\par requirement to continue to provide support service, warranty, or updates
\par for a work that has been modified or installed by the recipient, or for
\par the User Product in which it has been modified or installed.  Access to a
\par network may be denied when the modification itself materially and
\par adversely affects the operation of the network or violates the rules and
\par protocols for communication across the network.
\par 
\par   Corresponding Source conveyed, and Installation Information provided,
\par in accord with this section must be in a format that is publicly
\par documented (and with an implementation available to the public in
\par source code form), and must require no special password or key for
\par unpacking, reading or copying.
\par 
\par   7. Additional Terms.
\par 
\par   "Additional permissions" are terms that supplement the terms of this
\par License by making exceptions from one or more of its conditions.
\par Additional permissions that are applicable to the entire Program shall
\par be treated as though they were included in this License, to the extent
\par that they are valid under applicable law.  If additional permissions
\par apply only to part of the Program, that part may be used separately
\par under those permissions, but the entire Program remains governed by
\par this License without regard to the additional permissions.
\par 
\par   When you convey a copy of a covered work, you may at your option
\par remove any additional permissions from that copy, or from any part of
\par it.  (Additional permissions may be written to require their own
\par removal in certain cases when you modify the work.)  You may place
\par additional permissions on material, added by you to a covered work,
\par for which you have or can give appropriate copyright permission.
\par 
\par   Notwithstanding any other provision of this License, for material you
\par add to a covered work, you may (if authorized by the copyright holders of
\par that material) supplement the terms of this License with terms:
\par 
\par     a) Disclaiming warranty or limiting liability differently from the
\par     terms of sections 15 and 16 of this License; or
\par 
\par     b) Requiring preservation of specified reasonable legal notices or
\par     author attributions in that material or in the Appropriate Legal
\par     Notices displayed by works containing it; or
\par 
\par     c) Prohibiting misrepresentation of the origin of that material, or
\par     requiring that modified versions of such material be marked in
\par     reasonable ways as different from the original version; or
\par 
\par     d) Limiting the use for publicity purposes of names of licensors or
\par     authors of the material; or
\par 
\par     e) Declining to grant rights under trademark law for use of some
\par     trade names, trademarks, or service marks; or
\par 
\par     f) Requiring indemnification of licensors and authors of that
\par     material by anyone who conveys the material (or modified versions of
\par     it) with contractual assumptions of liability to the recipient, for
\par     any liability that these contractual assumptions directly impose on
\par     those licensors and authors.
\par 
\par   All other non-permissive additional terms are considered "further
\par restrictions" within the meaning of section 10.  If the Program as you
\par received it, or any part of it, contains a notice stating that it is
\par governed by this License along with a term that is a further
\par restriction, you may remove that term.  If a license document contains
\par a further restriction but permits relicensing or conveying under this
\par License, you may add to a covered work material governed by the terms
\par of that license document, provided that the further restriction does
\par not survive such relicensing or conveying.
\par 
\par   If you add terms to a covered work in accord with this section, you
\par must place, in the relevant source files, a statement of the
\par additional terms that apply to those files, or a notice indicating
\par where to find the applicable terms.
\par 
\par   Additional terms, permissive or non-permissive, may be stated in the
\par form of a separately written license, or stated as exceptions;
\par the above requirements apply either way.
\par 
\par   8. Termination.
\par 
\par   You may not propagate or modify a covered work except as expressly
\par provided under this License.  Any attempt otherwise to propagate or
\par modify it is void, and will automatically terminate your rights under
\par this License (including any patent licenses granted under the third
\par paragraph of section 11).
\par 
\par   However, if you cease all violation of this License, then your
\par license from a particular copyright holder is reinstated (a)
\par provisionally, unless and until the copyright holder explicitly and
\par finally terminates your license, and (b) permanently, if the copyright
\par holder fails to notify you of the violation by some reasonable means
\par prior to 60 days after the cessation.
\par 
\par   Moreover, your license from a particular copyright holder is
\par reinstated permanently if the copyright holder notifies you of the
\par violation by some reasonable means, this is the first time you have
\par received notice of violation of this License (for any work) from that
\par copyright holder, and you cure the violation prior to 30 days after
\par your receipt of the notice.
\par 
\par   Termination of your rights under this section does not terminate the
\par licenses of parties who have received copies or rights from you under
\par this License.  If your rights have been terminated and not permanently
\par reinstated, you do not qualify to receive new licenses for the same
\par material under section 10.
\par 
\par   9. Acceptance Not Required for Having Copies.
\par 
\par   You are not required to accept this License in order to receive or
\par run a copy of the Program.  Ancillary propagation of a covered work
\par occurring solely as a consequence of using peer-to-peer transmission
\par to receive a copy likewise does not require acceptance.  However,
\par nothing other than this License grants you permission to propagate or
\par modify any covered work.  These actions infringe copyright if you do
\par not accept this License.  Therefore, by modifying or propagating a
\par covered work, you indicate your acceptance of this License to do so.
\par 
\par   10. Automatic Licensing of Downstream Recipients.
\par 
\par   Each time you convey a covered work, the recipient automatically
\par receives a license from the original licensors, to run, modify and
\par propagate that work, subject to this License.  You are not responsible
\par for enforcing compliance by third parties with this License.
\par 
\par   An "entity transaction" is a transaction transferring control of an
\par organization, or substantially all assets of one, or subdividing an
\par organization, or merging organizations.  If propagation of a covered
\par work results from an entity transaction, each party to that
\par transaction who receives a copy of the work also receives whatever
\par licenses to the work the party's predecessor in interest had or could
\par give under the previous paragraph, plus a right to possession of the
\par Corresponding Source of the work from the predecessor in interest, if
\par the predecessor has it or can get it with reasonable efforts.
\par 
\par   You may not impose any further restrictions on the exercise of the
\par rights granted or affirmed under this License.  For example, you may
\par not impose a license fee, royalty, or other charge for exercise of
\par rights granted under this License, and you may not initiate litigation
\par (including a cross-claim or counterclaim in a lawsuit) alleging that
\par any patent claim is infringed by making, using, selling, offering for
\par sale, or importing the Program or any portion of it.
\par 
\par   11. Patents.
\par 
\par   A "contributor" is a copyright holder who authorizes use under this
\par License of the Program or a work on which the Program is based.  The
\par work thus licensed is called the contributor's "contributor version".
\par 
\par   A contributor's "essential patent claims" are all patent claims
\par owned or controlled by the contributor, whether already acquired or
\par hereafter acquired, that would be infringed by some manner, permitted
\par by this License, of making, using, or selling its contributor version,
\par but do not include claims that would be infringed only as a
\par consequence of further modification of the contributor version.  For
\par purposes of this definition, "control" includes the right to grant
\par patent sublicenses in a manner consistent with the requirements of
\par this License.
\par 
\par   Each contributor grants you a non-exclusive, worldwide, royalty-free
\par patent license under the contributor's essential patent claims, to
\par make, use, sell, offer for sale, import and otherwise run, modify and
\par propagate the contents of its contributor version.
\par 
\par   In the following three paragraphs, a "patent license" is any express
\par agreement or commitment, however denominated, not to enforce a patent
\par (such as an express permission to practice a patent or covenant not to
\par sue for patent infringement).  To "grant" such a patent license to a
\par party means to make such an agreement or commitment not to enforce a
\par patent against the party.
\par 
\par   If you convey a covered work, knowingly relying on a patent license,
\par and the Corresponding Source of the work is not available for anyone
\par to copy, free of charge and under the terms of this License, through a
\par publicly available network server or other readily accessible means,
\par then you must either (1) cause the Corresponding Source to be so
\par available, or (2) arrange to deprive yourself of the benefit of the
\par patent license for this particular work, or (3) arrange, in a manner
\par consistent with the requirements of this License, to extend the patent
\par license to downstream recipients.  "Knowingly relying" means you have
\par actual knowledge that, but for the patent license, your conveying the
\par covered work in a country, or your recipient's use of the covered work
\par in a country, would infringe one or more identifiable patents in that
\par country that you have reason to believe are valid.
\par 
\par   If, pursuant to or in connection with a single transaction or
\par arrangement, you convey, or propagate by procuring conveyance of, a
\par covered work, and grant a patent license to some of the parties
\par receiving the covered work authorizing them to use, propagate, modify
\par or convey a specific copy of the covered work, then the patent license
\par you grant is automatically extended to all recipients of the covered
\par work and works based on it.
\par 
\par   A patent license is "discriminatory" if it does not include within
\par the scope of its coverage, prohibits the exercise of, or is
\par conditioned on the non-exercise of one or more of the rights that are
\par specifically granted under this License.  You may not convey a covered
\par work if you are a party to an arrangement with a third party that is
\par in the business of distributing software, under which you make payment
\par to the third party based on the extent of your activity of conveying
\par the work, and under which the third party grants, to any of the
\par parties who would receive the covered work from you, a discriminatory
\par patent license (a) in connection with copies of the covered work
\par conveyed by you (or copies made from those copies), or (b) primarily
\par for and in connection with specific products or compilations that
\par contain the covered work, unless you entered into that arrangement,
\par or that patent license was granted, prior to 28 March 2007.
\par 
\par   Nothing in this License shall be construed as excluding or limiting
\par any implied license or other defenses to infringement that may
\par otherwise be available to you under applicable patent law.
\par 
\par   12. No Surrender of Others' Freedom.
\par 
\par   If conditions are imposed on you (whether by court order, agreement or
\par otherwise) that contradict the conditions of this License, they do not
\par excuse you from the conditions of this License.  If you cannot convey a
\par covered work so as to satisfy simultaneously your obligations under this
\par License and any other pertinent obligations, then as a consequence you may
\par not convey it at all.  For example, if you agree to terms that obligate you
\par to collect a royalty for further conveying from those to whom you convey
\par the Program, the only way you could satisfy both those terms and this
\par License would be to refrain entirely from conveying the Program.
\par 
\par   13. Use with the GNU Affero General Public License.
\par 
\par   Notwithstanding any other provision of this License, you have
\par permission to link or combine any covered work with a work licensed
\par under version 3 of the GNU Affero General Public License into a single
\par combined work, and to convey the resulting work.  The terms of this
\par License will continue to apply to the part which is the covered work,
\par but the special requirements of the GNU Affero General Public License,
\par section 13, concerning interaction through a network will apply to the
\par combination as such.
\par 
\par   14. Revised Versions of this License.
\par 
\par   The Free Software Foundation may publish revised and/or new versions of
\par the GNU General Public License from time to time.  Such new versions will
\par be similar in spirit to the present version, but may differ in detail to
\par address new problems or concerns.
\par 
\par   Each version is given a distinguishing version number.  If the
\par Program specifies that a certain numbered version of the GNU General
\par Public License "or any later version" applies to it, you have the
\par option of following the terms and conditions either of that numbered
\par version or of any later version published by the Free Software
\par Foundation.  If the Program does not specify a version number of the
\par GNU General Public License, you may choose any version ever published
\par by the Free Software Foundation.
\par 
\par   If the Program specifies that a proxy can decide which future
\par versions of the GNU General Public License can be used, that proxy's
\par public statement of acceptance of a version permanently authorizes you
\par to choose that version for the Program.
\par 
\par   Later license versions may give you additional or different
\par permissions.  However, no additional obligations are imposed on any
\par author or copyright holder as a result of your choosing to follow a
\par later version.
\par 
\par   15. Disclaimer of Warranty.
\par 
\par   THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
\par APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
\par HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
\par OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
\par THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
\par PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
\par IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
\par ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
\par 
\par   16. Limitation of Liability.
\par 
\par   IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
\par WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
\par THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
\par GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
\par USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
\par DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
\par PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
\par EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
\par SUCH DAMAGES.
\par 
\par   17. Interpretation of Sections 15 and 16.
\par 
\par   If the disclaimer of warranty and limitation of liability provided
\par above cannot be given local legal effect according to their terms,
\par reviewing courts shall apply local law that most closely approximates
\par an absolute waiver of all civil liability in connection with the
\par Program, unless a warranty or assumption of liability accompanies a
\par copy of the Program in return for a fee.
\par 
\par                      END OF TERMS AND CONDITIONS
\par \f1 
\par }
90
Scribble90
Changes v1.9




Done



FALSE
111
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fswiss Arial;}{\f2\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red0\green0\blue0;\red128\green0\blue128;\red128\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Changes v1.9 \{keepn\} \cf0\f1\fs28 
\par \cf2\b0\strike\fs20 TZipMaster\strike0\{linkID=10>main\}\cf3 
\par \cf4\f2 
\par \cf5\lang1033\b\fs24 New \cf3\b0\fs20 -
\par \pard\tx420\tx740\tx3180\lang3081\f0   Zip extensions version 4.50 -
\par \tab Files larger than 4Gb supported
\par \tab More than 64k files
\par \lang1033\f2 
\par \lang3081\f0   Zip file names - can use UTF8 for storing international file names.
\par \tab When writing zip files the format used is controlled by new WriteOptions
\par \pard\tx420\tx720\tx1980\tx3180\tab\tab zeoAuto,\tab use OEM unless extended characters, otherwise UPath or UTF8
\par       \tab\tab zeoRaw, \tab do not encode file names
\par \tab\tab zeoOEM, \tab convert file names to OEM
\par \tab\tab zeoUTF8, \tab store extended file names as UTF8 (Default)
\par \tab\tab zeoUPATH\tab store extended file names using unique safe name and (Info-Zip) UTF8
\par 
\par \tab When reading zip files the format expected is controlled by the new property Encoded
\par \tab\tab zeoAuto,\tab unless flags/versions say otherwise, or it has UTF8 name in data,
\par \tab\tab\tab   treat it as OEM (FAT) / Ansi (NTFS)
\par \tab\tab zeoNone,\tab assume name is Ansi - convert to Ansi/Unicode
\par \tab\tab zeoOEM,\tab assume name is OEM - convert to Ansi/Unicode
\par \tab\tab zeoUTF,\tab assume name is UTF8 - convert to Ansi/Unicode
\par   \tab\tab zeoUPATH,\tab use UPATH if available
\par \pard\tx420\tx740\tx3180   
\par   Pre-D2009 to prevent corruption of international names they can be kept as UTF8 - see property \cf2\strike UseUTF8\cf5\strike0\{linkID=2200\}\cf3 .
\par   D2009 (and later) file names are converted to Unicode so no corruption should occur.
\par 
\par   NTFS file stamps can be saved or restored - see \cf2\strike AddNTFS\cf5\strike0\{linkID=4490\}\cf3  and \cf2\strike ExtrNTFS\cf5\strike0\{linkID=4490\}\cf3 .
\par 
\par   When adding new files to an existing archive the old file be preserved - see \cf2\strike AddVersion\cf5\strike0\{linkTarget=addversion\}\cf0 .\cf3 
\par \lang1033 
\par \pard\tx420\tx720\tx1180   \b\fs24 Types
\par \tab\cf2\b0\strike\fs20 TZMString\cf5\strike0\{linkID=5280\}\cf3 
\par \tab\tab\tab D2009+ UnicodeString
\par \tab\tab\tab\cf2 Pre D2009 Ansi/UTF8\cf3\b\fs24 
\par \tab\cf2\b0\strike\fs20 TZMWideString\cf5\strike0\{linkID=5310\}
\par \tab\cf3\tab\tab D2009+ UnicodeString
\par \tab\tab\tab\cf2 Pre D2009 WideString\cf3 
\par 
\par \tab\cf2\strike TZMDirEntry\cf5\strike0\{linkID=6340\}
\par \tab\cf3\tab\tab now a class was TZipDirEntry
\par   \tab\cf2\strike TZMDirRec \cf5\strike0\{linkID=7090\}
\par \tab\cf3\tab\tab version of TZMDirEntry allowing limited editing\cf0 
\par \tab\cf2\strike TZMSStats\cf5\strike0\{linkID=5470\}
\par \tab\cf0\tab\tab used to 'identify' streams\cf3 
\par 
\par   \b\fs24 Enumerations
\par   \tab\cf2\b0\strike\fs20 TZMStates\cf5\strike0\{linkID=5200\}
\par \tab\cf3  \tab\tab component operating state - see \cf2\strike TZMStateChange\cf5\strike0\{linkID=5180\}
\par \tab\cf2\strike TZMDeflates\cf5\strike0\{linkID=4644\}\cf0 
\par \tab\tab\tab Deflate methods - see \cf2\strike Deflate\cf5\strike0\{linkID=2870\}\cf0  or \cf2\strike Undeflate\cf5\strike0\{linkID=3440\}\cf3\b\fs24 
\par   \tab\cf2\b0\strike\fs20 TZMEncodingOpts\cf5\strike0\{linkID=4700\}
\par \tab\cf3\tab\tab how names are encoded (reading)\cf6 
\par \tab\cf2\strike TZMStreamOp\cf5\strike0\{linkID=5490\}
\par \tab\cf0\tab\tab used to handle stream event requests
\par \tab\cf2\strike TZMWriteOpts\cf5\strike0\{linkID=5390\}
\par \tab\cf0\tab\tab used when writing a zip file
\par 
\par \tab TZMAddOptsEnum.addSeparateDirs 
\par \tab\tab\tab has been renamed by \cf2\strike addEmptyDirs\cf5\strike0\{linkTarget=addemptydirs\}\cf0 .\cf6 
\par \cf3\tab 
\par   \b\fs24 Functions
\par  \tab\cf2\b0\strike\fs20 AddZippedFiles\cf5\strike0\{linkID=2620\}
\par \tab\cf3\tab\tab add specified files from another zip file\b\fs24 
\par  \tab\cf2\b0\strike\fs20 ChangeFileDetails\cf5\strike0\{linkID=2680\}
\par \tab\cf3\tab\tab apply a function to modify file details for specified zip entries
\par \b\fs24    \tab\cf2\b0\strike\fs20 ForEach\cf5\strike0\{linkID=3080\}
\par \tab\cf3\tab\tab use a function on specified read-only zip entries
\par \tab\cf2\strike Deflate\cf5\strike0\{linkID=2870\}
\par \tab\cf3\tab\tab compress a stream
\par \tab\cf2\strike Undeflate\cf5\strike0\{linkID=3440\}
\par \tab\cf3\tab\tab uncompress compressed stream
\par 
\par \b\fs24   Properties\b0\fs20 
\par \lang3081\tab\cf2\strike UseUTF8\cf5\strike0\{linkID=2200\}
\par \tab\tab\cf2\tab controls string representation (Pre D2009 only)\cf3 
\par     \tab\cf2\strike Encoding\cf5\strike0\{linkID=880\}
\par \tab\cf3\tab\tab Filename and comment character encoding
\par \tab\cf2\strike Encoding_CP\cf5\strike0\{linkID=910\}
\par \tab\cf3  \tab\tab codepage to use to decode filename - 'raw' names only
\par \tab\cf2\strike WriteOptions\cf5\strike0\{linkID=2290\}
\par \tab\cf3\tab\tab controls how zip files will be written
\par \tab\cf2\strike MaxVolumeSizeKb\cf5\strike0\{linkID=1410\}
\par \tab\tab\tab\cf3 maximum volume size in kbytes
\par \tab\cf2\strike NoSkipping\cf5\strike0\{linkID=1470\}
\par \tab\cf3\tab  \tab if true skipping a file is an error\lang1033\f2 
\par 
\par \lang3081\f0   \b\fs24 Events
\par \b0\fs20 
\par   \tab\cf2\strike TZMStreamEvent\cf5\strike0\{linkID=5240\}
\par \tab\tab\cf3\tab Allows using streams in add/extract operations 
\par  \tab\cf2\strike TZMStateChange\cf5\strike0\{linkID=5180\}
\par \tab\tab\cf3  \tab Indicates changes to component busy state\lang1033\f2 
\par \lang3081\f0\tab\cf2\strike TZMCopyZippedOverwriteEvent\cf5\strike0\{linkID=4590\}
\par \tab\tab\cf3\tab from \cf2\strike AddZippedFile\cf5\strike0\{linkID=2620\}\cf3 , \cf2\strike CopyZippedFile\cf5\strike0\{linkID=2840\}\cf3  *changed
\par \tab\cf2\strike TZMSkippedEvent\cf5\strike0\{linkID=5080\}
\par \tab\tab\cf3\tab replaces TExtractSkipped
\par \tab TItemProgressEvent
\par \tab\tab\tab removed - use \cf2\strike TZMProgressEvent\cf5\strike0\{linkID=4940\}\cf3 
\par \tab TProgressEvent
\par \tab\tab\tab removed - use TZMProgressEvent
\par \tab TTotalProgressEvent
\par \tab\tab\tab removed - use TZMProgressEvent
\par \tab\cf2\strike TZMNewNameEvent\cf5\strike0\{linkID=4880\}
\par \tab\tab\tab\cf3 changed signature
\par \tab\cf2\strike TZMSetCompLevelEvent\cf5\strike0\{linkID=5040\}
\par \tab\tab\tab\cf3 new\f2 
\par 
\par }
100
Scribble100
Hierarchy
Hierarchy;



Done



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 Arial;}{\f1\fswiss Arial;}}
{\colortbl ;\red0\green0\blue0;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\nowidctlpar\cf1\lang3081\b\f0\fs20 Hierarchy
\par \b0 
\par \cf0\uldb TObject\ulnone\v 1QH34P>main@DEL4VCL\cf2\v0\fs16 
\par \cf0\fs20    |
\par \uldb TPersistent\ulnone\v 1Y6LKC_>main@DEL4VCL\cf2\v0\fs16 
\par \cf0\fs20    |
\par \uldb TComponent\cf3\ulnone\v 1JIX1J6>main@DEL4VCL\cf2\v0\fs16 
\par \cf0\fs20    |
\par \cf3\strike TZipMaster\cf4\strike0\{linkID=10\}\cf0 
\par \pard\f1\fs24 
\par }
110
Scribble110
Source files
Files;Tools;



Done



FALSE
123
{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue128;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Source files\cf2\b0\f1\fs20 
\par 
\par \f0 The required Delphi source files (files marked with '+' are written by ZipResMaker.exe)
\par     \cf3 <install dir>\cf2\\
\par             ZipMstr19.pas\tab\tab  - main component source
\par             ZipMstr19.res\tab\tab  - components version resource 
\par             ZipVers19.inc\tab\tab  - required defines for Delphi versions (only 4..10 supported)
\par \tab ZMCenDir19.pas\tab  - exposes the zip file central directory to outside world
\par \tab ZMCompat19.pas\tab  - support for earlier Delphi versions
\par             ZMCore19.pas\tab\tab  - basic support functions and event triggering
\par             ZMCtx19.pas\tab\tab  - Dialog box help context values
\par +          ZMDefMsgs19.pas\tab  - default message strings and tables
\par             ZMDelZip19.pas\tab\tab  - dll interface definitions
\par             ZMDlg19.pas\tab\tab  - dialog box support
\par \tab ZMDllLoad19.pas\tab  - handles loading the dll
\par \tab ZMDllOpr19.pas\tab\tab  - performs tasks requiring the dll
\par \tab ZMDrv19.pas\tab\tab  - drive level support for zip files
\par \tab ZMEOC19.pas\tab\tab  - performs operations on the eoc
\par             ZMExtrLZ7719.pas\tab  - extractor for LZ77 compressed streams
\par \tab ZMHash19.pas\tab\tab  - support for hashing directory entries for faster finds
\par \tab ZMIRec19.pas\tab\tab  - performs operations on central directory entries
\par \tab ZMMatch19.pas\tab\tab  - wild compares of file specs
\par +          ZMMsg19.pas\tab\tab  - message values
\par             ZMMsgStr19.pas\tab  - handles message string storage and language selection
\par \tab ZMSFXInt19.pas\tab\tab  - sfx stub interface 
\par             ZMStructs19.pas\tab  - definition of internal zip structures 
\par \tab ZMUTF819.pas\tab\tab  - support for UTF8/16 conversions
\par             ZMUtils19.pas\tab\tab  - some functions to make life easier
\par \tab ZMWAux19.pas\tab\tab  - SFX and span support
\par \tab ZMWorkFile19.pas\tab  - basic in/out for zip files
\par             ZMWrkr19.pas\tab\tab  - does the work
\par \tab ZMWUtils19.pas\tab  - some WideString functions
\par             ZMXcpt19.pas\tab\tab  - EZipMaster definitions
\par \tab ZMZipFile19.pas\tab\tab  - performs operations on a zip file
\par 
\par             ZipFix.pas\tab\tab  - (optional) component to repair damaged zip files
\par             ZipFix.res\tab\tab  - 
\par             ZipFix.hlp\tab\tab  - 
\par  
\par             SortGrid.pas\tab\tab  - (optional) sort grid component (used in Demos)
\par             SortGrid.res\tab\tab  - 
\par             SortGrid.dcr\tab\tab  - 
\par             SortGridreg.pas\tab\tab  - 
\par             SortGridPreview.pas\tab  - 
\par             SortGridPreview.dfm\tab  - 
\par 
\par     \cf3 <install dir>\cf2\\RES\\
\par +          ZMRes.rc\tab\tab  - resource script for compressed languages and dll
\par +          ZMRes.res\tab\tab  - compiled resource for applications using ZipMaster (link to application)
\par +          *.bin\tab\tab\tab  - resource files required by ZMRes.rc\tab 
\par             dzsfx_all.res\tab\tab  - SFX stub resources for all languages
\par             dzsfx*.res\tab\tab  - SFX stub resource for individual language (* is language)
\par \tab ZMSFXU19.exe\tab\tab  - SFX loader stub (Unicode)
\par \tab ZMSFX19.exe\tab\tab  - SFX Loader stub (Ansi)
\par 
\par     \cf3 <install dir>\cf2\\Delphi\\ 
\par             ZipMster19D?.bpk\tab  - design and run-time package (? is compiler version) 
\par             SortGridD?D.bpk\tab  - grid design package
\par             SortGridD?.bpk\tab\tab  - grid run-time package 
\par 
\par     ...\\Design\\  
\par             ZipMstrReg.pas\tab\tab  - register function 
\par             ZipMstr.dcr\tab\tab  - decoration
\par             ZipSFX.dcr\tab\tab  - decoration  
\par             SortGridReg.pas\tab  - register function
\par             SortGrid.dcr\tab\tab  - decoration
\par 
\par     \cf3 <install dir>\cf2\\DLL\\
\par             DelZip190.dll\tab\tab  - required dll
\par             DelZip190.lib\tab\tab  - library file for static binding the dll (CBuilder)
\par 
\par     \cf3 <install dir>\cf2\\DOCS\\
\par             licence.txt\tab\tab  - a copy of the licence
\par \tab ReadMe.txt
\par \tab Install.txt
\par \tab Debug.txt
\par 
\par 
\par     \cf3 <install dir>\cf2\\DLL\\SOURCE\\\tab\tab  - C source files for the dlls (BCB 6)
\par 
\par     \cf3 <install dir>\cf2\\TOOLS\\\tab\tab\tab  - some tools for building/updating
\par     \cf3 <install dir>\cf2\\TOOLS\\RCUPD\\\tab\tab  - language string updater by \cf1\strike\f2 Xavier Mor-Mur\cf4\strike0\{link=*! ExecFile("http://personal.auna.com/xav58806/RcUpd.html")\}\cf0\b\f3  - Now a separate download\cf2\b0\f1 
\par \f0     \cf3 <install dir>\cf2\\TOOLS\\ZIPRESMAKER\\\tab  - resource maker for ZipMaster 
\par 
\par     \cf3 <install dir>\cf2\\LANGS\\
\par             ZipMsg.h\tab\tab  - master message identifier header file
\par             ZipMsgUS.rc\tab\tab  - master message script
\par             ZipMsg??.rc\tab\tab  - resource language script files
\par             ZipMsg??.res\tab\tab  - compiled language resource file
\par             SFX??.txt\tab\tab  - language files for sfx
\par 
\par     \cf3 <install dir>\cf2\\HELP\\
\par             ZipMaster.hlp\tab\tab  - compiled help file (Delphi 7)
\par             ZipMaster.chm\tab\tab  - compile html file
\par             dzsfx.chm\tab\tab  - SFX help file
\par 
\par     \cf3 <install dir>\cf2\\HELP\\SOURCE\\\tab  - source files for help
\par 
\par    \cf3 <install dir>\cf0\\DEMOS\\SortGrid\\\tab  - Sortable column grid component used by some demos
\par \tab\tab\tab\tab  - Does NOT need to be installed
\par \cf2 
\par     \cf3 <install dir>\cf2\\DEMOS\\DEMO1\\\tab  - zip adder/extractor
\par 
\par     \cf3 <install dir>\cf2\\DEMOS\\DEMO2\\\tab  - quick add/extract and dll test
\par 
\par     \cf3 <install dir>\cf2\\DEMOS\\DEMO3\\\tab  - another add/extract example
\par 
\par     \cf3 <install dir>\cf2\\DEMOS\\DEMO4\\\tab  - simple self installer
\par 
\par     \cf3 <install dir>\cf2\\DEMOS\\DEMO5\\\tab  - make exe file (sfx)
\par 
\par     \cf3 <install dir>\cf2\\DEMOS\\DEMO6\\\tab  - span multiple disks
\par 
\par     \cf3 <install dir>\cf2\\DEMOS\\DEMO7\\\tab  - extract from stream
\par 
\par     \cf3 <install dir>\cf2\\DEMOS\\DEMO9\\\tab  - use in thread
\par 
\par  \b\fs24  Note\b0\fs20 
\par     \cf3\b <install dir> \cf0 is the installation directory - will need to be added to the search path\cf2\b0 
\par \f1 
\par }
120
Scribble120
Resources
Language;LanguageInfo;Tools;



Done



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fswiss Arial;}{\f2\fnil\fcharset0 Times New Roman;}{\f3\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green128\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Resources\cf2\{keepn\}\cf0\lang3081\f1\fs28 
\par \cf3\b0\strike\fs20 TZipMaster\strike0\{linkID=10>main\}\cf0\f2\fs24\tab\cf3\ul\f0\fs20 See also:\cf2\ulnone\{linkID=130\}\cf1\lang1033\b\fs32 
\par 
\par \cf0\fs28 Description
\par   \b0\fs20 ZipMaster can use multiple languages for it's messages and can also have a copy of the dll stored in resources.
\par   \cf3\strike ZipResMaker\cf2\strike0\{linkID=320\}\cf0  is used to select which languages are included (US English is the default).
\par \cf1\b\fs32 
\par \cf4\lang3081\b0\fs20   The \cf3\strike SFXStub\cf2\strike0\{linkID=1925\}\cf4  with its required languages can also be included in the resources. 
\par 
\par   A compressed version of the dll may also be included in the resources so that it is always available.\lang1033\f3 
\par 
\par 
\par }
130
Scribble130
Resources see also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\strike\fs20 Resource Format\cf2\strike0\{linkID=140\}\cf0 
\par \cf1\strike ZipResMaker\cf2\strike0\{linkID=320\}\cf0\b0\f1 
\par \cf3 
\par 
\par }
140
Scribble140
Resource Format
Resource Format;Tools;



Done



FALSE
94
{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fswiss Arial;}{\f2\fnil\fcharset0 Times New Roman;}{\f3\fnil Arial;}{\f4\fswiss\fprq2\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Resource Format\cf0\lang3081\f1\fs28 
\par \cf2\b0\strike\fs20 TZipMaster\strike0\{linkID=10\}\cf3\{keepn\}\cf0\f2\fs24\tab\cf4\lang1033\f3\fs20 
\par \pard\tx355\lang2057\f4 
\par \pard\sb35\tx355\cf0 The component can get its required Dll and/or message strings in different languages from a resource integrated in the application.
\par 
\par The easiest way to create this resource with the languages you need is to use the \cf2\b\strike ZipResMaker\cf3\strike0\{linkID=320\}\cf0  \b0 tool.
\par The ZipResMaker has a graphic user interface that let you choose all the elements you want in your resource and with a simple mouse click the resource is build for you.
\par 
\par ZipResMaker creates resource files compiling .rc files to .res files using BRCC32.
\par The possible .rc files that are created :
\par - ZMRES19_dll.rc for the dll resulting in ZMRes19_dll.res
\par - ZMRES19_str.rc for the selected languages resulting in ZMRes19_str.res
\par - ZMRES19_sfx.rc for the SFX stub resulting in ZMRes19_sfx.res
\par - ZMRES19_all.rc a combination of any of the above resulting in ZMRes19_all.res.
\par 
\par \pard\nowidctlpar\sa195\b\fs24 Content of the resource script file
\par \pard\b0\fs20 Essentially the content of the .rc files is
\par 
\par ZMRES19_dll.rc :
\par DZResDLL RCDATA LOADONCALL MOVEABLE DISCARDABLE "DZ_Dll19.bin"
\par 
\par ZMRES19_str.rc:
\par DZResSTR RCDATA LOADONCALL MOVEABLE DISCARDABLE "DZ_STR19.bin"
\par 
\par ZMRES19_sfx.rc:
\par DZResSFX RCDATA LOADONCALL MOVEABLE DISCARDABLE "DZ_SFX19.bin"
\par 
\par ZMRES19_sfx.rc:
\par DZResSFX RCDATA LOADONCALL MOVEABLE DISCARDABLE "DZ_SFXU19.bin"
\par 
\par ZMRES19_All.rc:
\par Can be any combination of the above.
\par 
\par DZResDLL, DZResSTR, DZResSFX are the resource ID strings for DLL, Language strings and SFX.
\par DZ_Dll19.bin is the binary file created from the Dll.
\par DZ_STR19.bin is a binary file created from all selected language resource files ( ZipMsgxx.res files)
\par DZ_SFX19.bin is a binary file created from the SFX stub ( ZMSfx19.exe)
\par DZ_SFXU19.bin is a binary file created from the SFX stub ( ZMSfxU19.exe)
\par 
\par \b\fs24 Format of DZ_Dll19.bin\b0\fs20 
\par 
\par The first 4 bytes of DZ_Dll19.bin are the version values of the DelZip190.dll
\par Example: first 4 bytes of DZ_Dll19.bin are 0x2B 0xFE 0x1C 0x00
\par Representing the version 1900075.
\par The rest of DZ_Dll19.bin is the normal delzip190.dll with or without compression.
\par For usage during debugging inside the IDE we recommend to compress the dll using LZ77 see the ZMCompLZ77 for compression and ZMExtrLZ77 for extraction. Using the \cf2\strike UPX\cf3\strike0\{linkID=150\}\cf0  compression tool can cause loading problems in the IDE
\par For normal usage outside the IDE use compression with the UPX compression tool
\par The loader code for the Dll can handle both formats simultaneously
\par In ZipResMaker this can be indicated by checking/unchecking the "Compress with UPX" option
\par 
\par 
\par \b\fs24 Format of DZ_STR19.bin\b0\fs20 
\par The binary file consists of blocks for all selected languages:
\par Each language is in the file as a single bloc.
\par The format for each languages is
\par \pard\tx560\tx2560\tx3960\tab Language ID\tab 1 word\tab the language code as indicated in the ZipMsgxx.rc file   
\par \tab Compressed size\tab 1 word
\par \tab Size of the name\tab 1 word   
\par \tab Name\tab variable length\tab 1 byte per character
\par \tab Size of data\tab 1 word
\par \tab Data\tab variable length
\par \pard 
\par The data part is the ZipMsgxx.res file compressed with the LZ77 compress method.
\par 
\par \b\fs24 Format of DZ_SFX19.bin and DZ_SFXU19.bin\b0\fs20 
\par 
\par The first 4 bytes of DZ_SFX19.bin and DZ_SFXU19.bin are the version values of the selected ZMSFX19.exe
\par Example: first 4 bytes of ZMSFXU.bin are 0x04 0xFE 0x1C 0x00
\par Representing the version 1900036.
\par The rest of DZ_SFX19.bin and DZ_SFXU19.bin are the normal ZMSFX19.exe with or without compression including the selected languages.
\par For usage during debugging of the SFX stub we recommend not to compress the stub.
\par For normal usage outside the IDE use compression with the UPX compression tool
\par In ZipResMaker this can be indicated by checking/unchecking the "Compress with UPX" option
\par 
\par The selected languages will be included in the ZMSFX19.exe as resources.
\par First the language strings are read from the SFXstr_xx.txt files into a table, that table is compressed using the
\par TZipMaster component and the \cf2\strike AddStreamToStream\cf3\strike0\{linkID=2590\}\cf0  method.
\par The compressed table is then added to the stub as a resource using the UpdateResource API with arguments
\par 
\par \pard\tx1140\tx6360 UpdateResource(hUpdateRes,\tab // update resource handle
\par \tab RT_RCDATA,\tab // change resource
\par \tab PChar(id),\tab // resource name
\par \tab MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL),\tab // neutral language
\par \tab ts.Memory, \tab // ptr to resource info
\par \tab ts.Size))\tab // size of resource info.
\par \pard 
\par Were id is a sequence number starting with 129 for the first language, 130 for the second and so on.
\par We use MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL) because the SFXStub will find the real language indicator in the
\par lanugage strings and use that information (Lang_ID is the first info in the table).
\par 
\par \cf4\lang1033\f3 
\par }
150
Scribble150
UPX




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fswiss\fprq2\fcharset0 Arial;}{\f3\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 UPX\cf2\b0\f1\fs20 
\par 
\par \cf0\lang2057\f2 The Ultimate Packer for eXecutables\tab\tab\tab\tab\tab\tab\tab 
\par Copyright (c) 1996-2002 Markus Oberhumer & Laszlo Molnar\tab\tab\tab\tab\tab\tab\tab\cf1\ul\v <http://upx.sourceforge.net/%!EF("http://upx.sourceforge.net",`',1>\ulnone )\cf0\v0 
\par \cf1\ul\v <http://upx.sourceforge.net/%!EF("http://upx.sourceforge.net",`',1><http://upx.sourceforge.net/%!EF("http://upx.sourceforge.net",`',1><http://upx.sourceforge.net/%!EF("http://upx.sourceforge.net",`',1><http://upx.sourceforge.net/%!EF("http://upx.sourceforge.net",`',1>\cf2\lang1033\ulnone\v0\f0  \cf1\strike\f3 http://upx.sourceforge.net/\cf3\strike0\{link=*! ExecFile("http://upx.sourceforge.net/")\}\cf2\f0 
\par \f1 
\par }
160
Scribble160
Configuration Settings
DLLDirectory;Properties;Tools;



Done



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fswiss\fprq2\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Configuration Settings\cf2\b0\f1\fs20 
\par 
\par \pard\tx355\cf0\lang2057\f2 ZipMaster can be built with compiler conditionals that allow you to leave functions out that you do not need.
\par 
\par These defines are in ZipMaster19.pas (the main component file).
\par 
\par When you want to work with static binding define the \b STATIC_LOAD_DELZIP_DLL\b0  directive.
\par Make sure that the component, and the Delphi IDE, can find DelZip190.dll either in the Windows System directory or in the same directory as your application executable. The IDE may require it to be either in the 'bpl' or the 'bin' directory - depending upon version.
\par \pard\cf2\lang1033\f1                  
\par // undefine\f0  \f1 to use ResourceStrings
\par \{$Define USE_COMPRESSED_STRINGS\}
\par 
\par // define to statically load dll at program startup
\par \{.$DEFINE STATIC_LOAD_DELZIP_DLL\}
\par 
\par 
\par }
170
Scribble170
Scope




Done



FALSE
8
{\rtf1\ansi\deff0{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red255\green0\blue255;}
\viewkind4\uc1\pard\sb75\cf1\lang3081\b\f0\fs20 Scope\cf0\f1\fs22 
\par \pard\sb75\sa115\tx165\tx425\cf2\b0\fs20\{bmc GrnBullet.bmp\}\tab\tab\cf0 Published
\par \pard\tx165\tx425\b\fs22 Accessibility
\par \pard\sb75\sa115\tx165\tx425\cf2\b0\fs20\{bmc BluBullet.bmp\}\tab\tab\cf0 Read-only
\par 
\par }
190
Scribble190
About Codepages




Done



FALSE
12
{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\sa115\cf1\lang3081\b\f0\fs28 General Info About Codepages\cf0 
\par \b0\fs20 Codepages are basically just a character sets. A standard MS-DOS character set used codepage 850, which is called the "OEM" codepage. Windows 3.1 used this codepage also. Most Windows 95 and Windows NT systems use codepage 1252, which is for America and Western Europe. This one is called "ISO 8859-1, Latin 1", which I will call "ISO". There are other OEM and ISO codepages, but I want to limit this discussion to the 850 and 1252 \{keepn\} codepages.
\par Both the ISO and OEM codepages support the common accented characters used in Western Europe. However, the exact codes used for specific characters are different. Each of these also has some unique characters in the range $80 - $FF. We would like to be able to convert the accented character codes in the filenames when we extract them from a zip file.
\par In these two codepages, ISO and OEM, the bottom 128 codes are the same. Only the upper 128 codes are different. These upper codes are used for accented characters. Most ZIP files use only the lower 128 codes in their filenames, so the codepage used is irrelevant. It is only important when the non-English accented characters (or other upper codes) are used in filenames. 
\par Each zip file header includes an indicator of which Operating System (OS) was used when it was created. We assume that the current OS is Win 95/98/NT using codepage 1252. If the zip file layout is based on codepage 850 ( i.e. was made on MS-DOS or Win 3.1 or made by WinZip ), then we can translate it so the extracted filenames will appear correctly. Note that this conversion can not be 100% accurate because each of these character sets has some unique symbols.
\par This is not an ideal world, though, and many zip files do not correctly identify which OS was used to make them. And, even if we know the OS it was made on, they may not have used codepage 850, and we may not be using codepage 1252 right now! So, I allow 3 different settings of the CodePage property so you can have full control over conversions.
\par In this release, you do not have the ability to convert text files made with one codepage to another codepage. At this time only  filenames and zip file comments can be converted.
\par What about the other codepages: Korean, Japanese, Hebrew, etc? I don't know any way of translating those codes to codepage 1252, because most of their characters do not exist in codepage 1252. However, if you are using the Korean codepage, and the people you give your zip files to are also using the Korean codepage, then no translation is necessary! If you want to make a zip file for use by people in other countries, then you should make it using codepage 1252.
\par 
\par }
200
Scribble200
DLL loading and unloading
Dll;DLL_Loaded;DLLDirectory;ZipDLL's;



Done



FALSE
29
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss Arial;}{\f1\fswiss\fcharset0 Arial;}{\f2\froman\fcharset0 Times New Roman;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green128\blue0;\red255\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\lang3081\b\f0\fs24\tab DLL Loading and Unloading\cf0 
\par \pard\tx425\b0\fs20 This table show\lang1033\f1 s\lang3081\f0  you which method\lang1033\f1 s require the DLL\lang3081\f0 :
\par \pard\fi-425\li425\tx425\tx2835\tab Add\tab 
\par \tab AddFileToStream\tab 
\par \tab AddStreamToStream\tab 
\par \tab Delete\tab 
\par \tab Extract\tab 
\par \tab ExtractFileToStream\tab 
\par \tab ExtractStreamToStream\tab 
\par 
\par All other methods do not need the DL\lang1033\f1 L.\lang3081\f0 
\par \pard\tx425\tx2265 
\par \pard\fi-845\li845\tx845\cf2\b NOTE:\cf0\b0   \f2 '\f0 Test\f2 '\f0  is a sub-option of Extract.
\par 
\par \cf3\lang1033\b\f1 NOTE:\cf0\b0  If static binding of the DLL to the component is used then the DLL is always loaded or the application (or the IDE) will not load.\lang3081\f0 
\par \pard\tx425\tx2265 
\par \lang1033\f1 The following properties give you control over loading and unloading the DLL 
\par        \cf4\strike DLLDirectory\cf5\strike0\{linkID=820\}\cf0\tab optionally specify where to look for the DLL.
\par        \cf4\strike DLL_Load\cf5\strike0\{linkID=730\}\cf0\tab Set true to load the DLL, false to unload - returns true if loaded
\par \pard        \cf4\strike DLL_Path\cf5\strike0\{linkID=760\}\cf0\tab returns the path from which the dll was loaded
\par        \cf4\strike\f3 DLL_Build\cf5\strike0\{linkID=710\}\tab\cf0 returns the DLL build\f1 
\par \pard\tx425\tx2265        \cf4\strike DLL_Version\cf5\strike0\{linkID=790\}\cf0\tab returns the DLL version
\par  \lang3081\f0 
\par For compatibility with older programs the loading and unloading will be done automatically if your program does not do it.
\par This can, however, incur performance penalty because it will reload the DLL for each operation.
\par 
\par }
210
Scribble210
DLL binding methods
Dll;DLL_Loaded;DLLDirectory;



Done



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 DLL binding methods
\par  \cf0\b0\fs20 see also: \cf2\strike Configuration Settings\cf3\strike0\{linkID=160\}\cf4\f1 
\par 
\par \b\f0\fs28 Static\b0\fs20 
\par      Windows loads the DLL when the application loads.
\par 
\par \cf5\b\fs24 Note:\cf4\b0\fs20 
\par      If the component is installed in the Delphi IDE then the DLL must load when the IDE loads.
\par 
\par 
\par \b\fs28 Dynamic\b0\fs20 
\par      The component loads the DLL when it is needed (or when told to do so).\f1 
\par }
220
Scribble220
Zip Operating systems
ZipHostSystem;



Done



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss Arial;}{\f1\fswiss\fcharset0 Arial;}{\f2\froman\fcharset0 Times New Roman;}}
\viewkind4\uc1\pard\lang3081\f0\fs24 Type of operating system used to make archive:
\par \pard\tqr\tx275\tqr\tx425\tqr\tx2405\tqr\tx2545\fs20\tab 0\tab - MS-DOS, OS/2 and Win32
\par \tab 1\tab - Amiga\tab 2\tab - VAX / VMS
\par \tab 3\tab - Unix\tab 4\tab - VM / CMS
\par \tab 5\tab - Atari ST\tab 6\tab - OS/2 H.P.F.S.
\par \tab 7\tab - Macintosh\tab 8\tab - Z-System
\par \tab 9\tab - CP/M\tab 10\f1  \f0 - TOPS20
\par \tab 11\f1  \f0 - NTFS\tab 12\f1  \f0 - QDOS
\par \tab 13\f1  \f0 - Acorn\tab 14\f1  \f0 - VFAT W\f2 '\f0 95 and NT
\par \tab 15\f1  \f0 - MVS\tab 16\f1  \f0 - BeOS
\par \tab 17\f1  \f0 - Tandem / NSK\tab 18\f1  \f0 thru 255 \f2 -\f0  unused
\par 
\par }
230
Scribble230
Zip Compression Methods
Compression methods;



Done



FALSE
15
{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Arial;}}
{\colortbl ;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\lang3081\f0\fs24\tab\cf0\fs20 0\tab - The file is stored (no compression)
\par \tab 1\tab - The file is Shrunk
\par \tab 2\tab - The file is Reduced with compression factor 1
\par \tab 3\tab - The file is Reduced with compression factor 2
\par \tab 4\tab - The file is Reduced with compression factor 3
\par \tab 5\tab - The file is Reduced with compression factor 4
\par \tab 6\tab - The file is Imploded
\par \tab 7\tab - Reserved for Tokenizing compression algorithm
\par \tab 8\tab - The file is Deflated
\par \tab 9\tab - Reserved for enhanced Deflating
\par \tab 10\tab - PKWARE Date Compression Library Imploding
\par 
\par }
240
Scribble240
Using relative paths with ZipMaster
Dll;Relative paths with ZipMaster;



Done


Relative_Paths_With_ZipMaster
FALSE
15
{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\lang3081\b\f0\fs28 How to Use and Store Relative Paths\cf0\{keepn\} 
\par \pard\fi-275\li275\tx275\fs20 1)\tab Set the AddOptions to AddRecurseDirs and AddDirNames:
\par \b0\i\tab with ZipMaster1 do
\par \pard\fi-275\li275\sa55\tx275\tx565\tab\tab AddOptions := AddOptions + [AddRecurseDirs, AddDirNames];
\par \pard\fi-275\li275\tx275\b\i0 2)\tab Add a file specification like *.* or *.pas or something like this:
\par \pard\fi-275\li275\sa55\tx275\b0\tab ZipMaster1.FSpecArgs.Append( '*.*' );
\par \pard\fi-275\li275\tx275\b 3)\tab Set the RootDir property to the desired base directory, Drive and Directory where the relative path should start.\b0 
\par \pard\fi-275\li275\sa55\tx275\i\tab ZipMaster1.RootDir :=\i0 '\i C:\\aBaseDir\\AnotherBaseDir\i0 '\i ;
\par \pard\fi-275\li275\tx275\b\i0 4)\tab Now do an Add, and you should have the desired result. The Drive ID and Dirname of your base directory will not be stored in the archive.
\par \b0\i\tab ZipMaster1.Add;
\par \pard\fi-845\li845\sb115\tx845\cf2\b\i0 NOTE:\cf3\tab\cf0\b0 The reason that demo1 saves whole pathnames is because it's GUI design intentionally stores complete pathnames in the FSpecArgs.
\par 
\par }
250
Scribble250
Password Notes
Password Notes;Passwords;



Done



FALSE
20
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss Arial;}{\f1\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\lang3081\b\f0\fs28 TZipMaster Password Notes\cf2\{keepn\} 
\par \cf0\b0\fs20 The "\cf3\strike GetAddPassword\strike0\{linkID=3120\}\cf0  " and "\cf3\strike  GetExtrPassword\strike0\{linkID=3160\}\cf0  " methods are optional. You have 4 different ways of getting a user's password:
\par 
\par \pard\fi-275\li565\sa195\tx565\b 1.\b0\tab Call the "GetAddPassword" and/or the "GetExtrPassword" methods, just before add or extract.
\par \pard\fi-275\li565\tx565\b 2.\b0\tab Use your own code to set the "Password" property.  It's your choice how you obtain the password.
\par \pard\fi-275\li845\tx845 -\tab This is useful if the password comes from a file or table.
\par \pard\fi-275\li845\sa195\tx845 -\tab It's also good for letting you enforce constrains on the password - you can require it to be over 6 chars, require it to have at least one special char, etc.  Of course, you'd only want to enforce constraints on "Add" operations.  A word of caution: many users don't like password constraints, so give them the option to turn them off.
\par \pard\fi-275\li565\sa195\tx565\b 3.\b0\tab Don't set one at all, and let the component prompt the user. It's easy, and it works.
\par \b 4.\b0\tab Set the password in the \cf3\strike OnPasswordError\strike0\{linkID=3990\}\cf0  event. This is also the most flexible way of doing it.
\par \pard\tx565 Passwords can not be longer than 80 characters. A zero-length password is the same as no password at all.
\par 
\par To "zero out" the password, set it's property to an empty string. If it is zeroed out, but the \cf3\strike AddEncrypt\f1  \cf4\strike0\{linkTarget=AddEncrypt\}\cf0\f0 option is set, then the user will be prompted for a new password by the component. So, if you don't want a password used, make sure you turn off "AddEncrypt", and you zero-out the password. 
\par 
\par If you set a password for an Extract, but it is incorrect, then the \cf3\strike OnPasswordError\strike0\{linkID=3990\}\cf0  event will be triggered \cf3\strike PasswordReqCount\strike0\{linkID=1570\}\cf0  times if you still do not supply a correct password Extraction will not take place.
\par 
\par To Force the DLL to AVOID decrypting an encrypted file, you must set the password property to an empty string and set to \cf3\strike PasswordReqCount\strike0\{linkID=1570\}\cf0  to zero.  If Adding, make sure AddEncrypt is NOT set.
\par 
\par }
260
Scribble260
Handling of Multi Volume Zip parts
Multi Volume Zip Parts;



Done



FALSE
23
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss Arial;}{\f1\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red128\green0\blue0;\red0\green0\blue255;\red128\green128\blue0;}
\viewkind4\uc1\pard\lang3081\f0\fs24 A)\tab How to copy each part to diskette afterwards:
\par \pard\fi-275\li275\tx275\b\fs20 1)\tab Make the MV archive on harddisk. Your filenames will be, for example:
\par \b0\i 'Test001.zip', 'Test002.zip', 'Test003.zip'
\par \b\i0 2)\tab Copy each of them to it's own diskette.
\par 3)\tab Rename each file on diskette to 'Test.zip'
\par 4)\tab Set the label of the diskettes to 'PKBACK# 001', 'PKBACK# 002' and 'PKBACK# 003'
\par ( Note the space between # and the first digit! )
\par 5)\tab Start reading from the last diskette.
\par \pard\cf1\b0\fs24\{target=ReasMult\}\cf2 B)\tab How to reassemble the pieces at the client side after sending the files over the internet, without using diskettes.
\par \pard\fi-275\li275\tx275\cf0\b\fs20 1)\tab Start a DOS window and "CD" to the directory with Test???.zip
\par 2)\tab Concatenate them with: 
\par \b0\i "Copy /B Test001.zip+Test002.zip+Test003.zip Test.zip" or shorter:  \f1 "\f0 Copy /B Test???.zip Test.zip\f1 "\f0 
\par \b\i0 (Do not enter the quotes.)
\par 3)\tab Fix the internal directory structure with: PKZipFix Test.zip
\par \cf3 Note:\cf0\b0  PKZipFix.EXE comes with pkzip v2.04g.
\par \b 4)\tab Rename the resulting file 'PKfixed.zip' to 'Test.zip' (This is now a normal zip file and should be 4 bytes smaller than the sum of the parts.
\par \b0 
\par \pard\fi-845\li845\sa55\tx845\cf3\b NOTE1:\cf0\b0\tab There is no time penalty making the archive directly on diskettes because the ZipMaster and ZipBuilder components internally use a temporary file on harddisk.
\par \pard\fi-845\li845\tx845\cf3\b NOTE2:\cf0\b0\tab Harddisk spanning is not supported by PKZip and WinZip, so if you want to use files created this way with these programs you will have to use one of the above mentioned methods.
\par 
\par }
270
Scribble270
Filespecs




Done



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fswiss Arial;}}
{\colortbl ;\red0\green128\blue0;}
\viewkind4\uc1\pard\lang3081\f0\fs20\{keepn\} The file specification is the technical description of files to include in the Zip archive. DOS wild cards may be used in the file specification. 
\par The \cf1\strike FSpecArgs\strike0\{linkID=1090\}\cf0  property stores the file specification for the TZipMaster component.
\par 
\par }
300
Scribble300
Errors and Messages




Done



FALSE
452
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fswiss\fprq2\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue128;\red0\green128\blue0;}
\viewkind4\uc1\pard\tx720\tx3900\cf1\b\fs32 Errors and Messages\cf2\b0\f1\fs20 
\par 
\par \pard\tx180\tx960\tx3900\b\f0\tab Value\tab Identifier\tab Default message\b0\f1 
\par \f0\tab\f1 10096\f0\tab\b\f1 DT_Language\b0 
\par \f0\tab\f1  \tab  'US: default';
\par \f0\tab\f1 10097\f0\tab\b\f1 DT_Author\b0 
\par \f0\tab\f1  \tab  'R.Peters';
\par \f0\tab\f1 10098\f0\tab\b\f1 DT_Desc\b0 
\par \f0\tab\f1  \tab  'Language Neutral';
\par 
\par \f0\tab\tab\cf3 General messages\cf2\f1 
\par \f0\tab\f1 10101\f0\tab\b\f1 GE_FatalZip\b0 
\par \f0\tab\f1  \tab  'Fatal Error in DLL: abort exception';
\par \f0\tab\f1 10102\f0\tab\b\f1 GE_NoZipSpecified\b0 
\par \f0\tab\f1  \tab  'Error - no zip file specified!';\cf0\b\f2 
\par \cf4\b0\strike\tab\tab       ZipFileName\strike0\{linkID=2410\}\cf0  is not specified or the specified file does not exist.\cf2\f1 
\par \f0\tab\f1 10103\f0\tab\b\f1 GE_NoMem\b0 
\par \f0\tab\f1  \tab  'Requested memory not available';
\par \f0\tab\f1 10104\f0\tab\b\f1 GE_WrongPassword\b0 
\par \f0\tab\f1  \tab  'Error - passwords do NOT match'#10'Password ignored';
\par \f0\tab\f1 10106\f0\tab\b\f1 GE_Except\b0 
\par \f0\tab\f1  \tab  'Exception in Event handler ';
\par \f0\tab\f1 10109\f0\tab\b\f1 GE_Inactive\b0 
\par \f0\tab\f1  \tab  'not Active';
\par \f0\tab\f1 10111\f0\tab\b\f1 GE_TempZip\b0 
\par \f0\tab\f1  \tab  'Temporary zipfile: %s';
\par \f0\tab\f1 10112\f0\tab\b\f1 GE_WasBusy\b0 
\par \f0\tab\f1  \tab  'Busy + %s';
\par \f0\tab\f1 10113\f0\tab\b\f1 GE_EventEx\b0 
\par  \tab\f0\tab\f1  'Exception in Event ';
\par \f0\tab\f1 10124\f0\tab\b\f1 GE_DLLCritical\b0 
\par \f0\tab\f1  \tab  'critical DLL Error %d';
\par \f0\tab\f1 10125\f0\tab\b\f1 GE_Unknown\b0 
\par  \tab\f0\tab\f1  ' Unknown error %d';
\par \f0\tab\f1 10126\f0\tab\b\f1 GE_Skipped\b0 
\par \f0\tab\f1\tab  'Skipped %s %d';
\par \f0\tab\f1 10127\f0\tab\b\f1 GE_Copying\b0 
\par  \tab\f0\tab\f1  'Copying: %s';
\par \f0\tab\f1 10128\f0\tab\b\f1 GE_Abort\b0 
\par \f0\tab\f1  \tab  'User Abort';
\par \f0\tab\f1 10130\f0\tab\b\f1 GE_ExceptErr\b0 
\par  \tab\f0\tab\f1  'Error Exception: ';
\par \f0\tab\f1 10131\f0\tab\b\f1 GE_NoSkipping\b0 
\par \f0\tab\f1  \tab  'Skipping not allowed';
\par \f0\tab\f1 1013\f0 2\tab\b\f1 GE_\f0 FileChanged\b0\f1 
\par \f0\tab\f1  \tab  '\f0 Zip file changed\f1 ';
\par \f0\tab\tab      The zip file was altered between setting ZipFileName and processing the file.\f1 
\par 
\par \f0\tab\tab\cf3 Rename messages\cf2\f1 
\par \f0\tab\f1 10144\f0\tab\b\f1 RN_InvalidDateTime\b0 
\par  \tab\f0\tab\f1  'Invalid date/time argument for file: ';
\par 
\par \f0\tab\tab\cf3 Password messages\cf2\f1 
\par \f0\tab\f1 10150\f0\tab\b\f1 PW_UnatAddPWMiss\b0 
\par \f0\tab\f1  \tab  'Error - no add password given';\cf0\b\f2 
\par \b0\tab\tab        You tried to use the function \cf4\strike GetAddPassword\strike0\{linkID=3120\}\cf0  while the property \cf4\strike Unattended\strike0\{linkID=2110\}\cf0  was set to True.\cf2\f1 
\par \f0\tab\f1 10151\f0\tab\b\f1 PW_UnatExtPWMiss\b0 
\par  \tab\f0\tab\f1  'Error - no extract password given';\cf0\f2 
\par \tab\tab        You tried to use the function \cf4\strike GetExtrPassword\strike0\{linkID=3160\}\cf0  while the property \cf4\strike Unattended\strike0\{linkID=2110\}\cf0  was set to True.\cf2\f1 
\par \f0\tab\f1 10154\f0\tab\b\f1 PW_Caption\b0 
\par \f0\tab\f1  \tab  'Password';
\par \f0\tab\f1 10155\f0\tab\b\f1 PW_MessageEnter\b0 
\par  \tab\f0\tab\f1  'Enter Password ';
\par \f0\tab\f1 10156\f0\tab\b\f1 PW_MessageConfirm\b0 
\par \f0\tab\f1  \tab  'Confirm Password ';
\par 
\par \f0\tab\tab\cf3 ChangeFileDetails messages\cf2\f1 
\par \f0\tab\f1 10180\f0\tab\b\f1 CF_SourceIsDest\b0 
\par  \tab\f0\tab\f1  'Source archive is the same as the destination archive!';
\par \f0\tab\f1 10181\f0\tab\b\f1 CF_OverwriteYN\b0 
\par \f0\tab\f1  \tab  'Overwrite file ''%s'' in ''%s'' ?';
\par \f0\tab\f1 10182\f0\tab\b\f1 CF_CopyFailed\b0 
\par  \tab\f0\tab\f1  'Copying a file from ''%s'' to ''%s'' failed';
\par \f0\tab\f1 10184\f0\tab\b\f1 CF_SFXCopyError\b0 
\par \f0\tab\f1  \tab  'Error while copying the SFX data';
\par \f0\tab\f1 10187\f0\tab\b\f1 CF_NoDest\b0 
\par  \tab\f0\tab\f1  'No destination specified';
\par 
\par \f0\tab\tab\cf3 List problems\cf2\f1 
\par \f0\tab\f1 10201\f0\tab\b\f1 LI_ReadZipError\b0 
\par \f0\tab\f1  \tab  'Seek error reading Zip archive!';
\par \f0\tab\f1 10202\f0\tab\b\f1 LI_ErrorUnknown\b0 
\par  \tab\f0\tab\f1  'Unknown error in List() function';
\par \cf0\f2\tab\tab        Internal error while executing code in List function of TZipMaster, this should not occur.\cf2\f1 
\par \f0\tab\f1 10203\f0\tab\b\f1 LI_WrongZipStruct\b0 
\par \f0\tab\f1  \tab  'Warning - Error in zip structure!';
\par \cf0\f2\tab\tab         The start of the central directory in the zip file is not where it should be!
\par \tab\tab         If this archive should be read by other zip programs it is advisable to re-zip the contents.
\par \tab\tab         It has probably to do with a conversion problem (bug) in earlier ZipMaster versions.
\par \cf2\f1 
\par \f0\tab\tab\cf3 DialogBox buttons\cf2\f1 
\par \f0\tab\f1 10220\f0\tab\b\f1 ZB_Yes\b0 
\par  \tab\f0\tab\f1  '&Yes';
\par \f0\tab\f1 10221\f0\tab\b\f1 ZB_No\b0 
\par \f0\tab\f1  \tab  '&No';
\par \f0\tab\f1 10222\f0\tab\b\f1 ZB_OK\b0 
\par  \tab\f0\tab\f1  '&OK';
\par \f0\tab\f1 10223\f0\tab\b\f1 ZB_Cancel\b0 
\par \f0\tab\f1  \tab  '&Cancel';
\par \f0\tab\f1 10224\f0\tab\b\f1 ZB_Abort\b0 
\par  \tab\f0\tab\f1  '&Abort';
\par \f0\tab\f1 10225\f0\tab\b\f1 ZB_Retry\b0 
\par \f0\tab\f1  \tab  '&Retry';
\par \f0\tab\f1 10226\f0\tab\b\f1 ZB_Ignore\b0 
\par  \tab\f0\tab\f1  '&Ignore';
\par \f0\tab\f1 10227\f0\tab\b\f1 ZB_CancelAll\b0 
\par \f0\tab\f1  \tab  'CancelAll';
\par \f0\tab\f1 10228\f0\tab\b\f1 ZB_NoToAll\b0 
\par  \tab\f0\tab\f1  'NoToAll';
\par \f0\tab\f1 10229\f0\tab\b\f1 ZB_YesToAll\b0 
\par \f0\tab\f1  \tab  'YesToAll';
\par 
\par \f0\tab\tab\cf3 General errors\cf2\f1 
\par \f0\tab\f1 10301\f0\tab\b\f1 AD_NothingToZip\b0 
\par  \tab\f0\tab\f1  'Error - no files to zip!';
\par \f0\tab\f1 10302\f0\tab\b\f1 AD_UnattPassword\b0 
\par \f0\tab\f1  \tab  'Unattended action not possible without a password';
\par \cf0\f2\tab\tab         You tried to perform an unattended Add without giving a password first.\cf2\f1 
\par \f0\tab\f1 10304\f0\tab\b\f1 AD_AutoSFXWrong\b0 
\par  \tab\f0\tab\f1  'Error %.1d occurred during Auto SFX creation.';
\par \cf0\f2\tab\tab         This error number is one of the errors as returned by the \cf4\strike ConvertToSFX\strike0\{linkID=2720\}\cf0  method.\cf2\f1 
\par \f0\tab\f1 10306\f0\tab\b\f1 AD_InIsOutStream\b0 
\par \f0\tab\f1  \tab  'Input stream may not be set to the output stream';
\par \f0\tab\tab         \cf0\f2 The input stream is the same as the output stream which is not permitted.\cf2\f1 
\par \f0\tab\f1 10307\f0\tab\b\f1 AD_InvalidName\b0 
\par \f0\tab\f1  \tab  'Wildcards are not allowed in Filename or file specification';
\par \f0\tab\tab         \cf0\f2 You tried to specify a filename with '*' and/or '?' characters in it.\cf2\f1 
\par \f0\tab\f1 10308\f0\tab\b\f1 AD_NoDestDir\b0 
\par  \tab\f0\tab\f1  'Destination directory ''%s'' must exist!';
\par \f0\tab\f1 10309\f0\tab\b\f1 AD_BadFileName\b0 
\par  \tab\f0\tab\f1  'Invalid Filename';
\par \f0\tab\f1 10310\f0\tab\b\f1 AD_InvalidEncode\b0 
\par  \tab\f0\tab\f1  'Invalid encoding options';
\par 
\par \f0\tab\f1 10320\f0\tab\b\f1 AZ_NothingToDo\b0 
\par  \tab\f0\tab\f1  'Nothing to do';
\par \f0\tab\f1 10321\f0\tab\b\f1 AZ_SameAsSource\b0 
\par \f0\tab\f1  \tab  'source and destination on same removable drive';
\par \f0\tab\f1 10322\f0\tab\b\f1 AZ_InternalError\b0 
\par  \tab\f0\tab\f1  'Internal error';
\par 
\par \f0\tab\tab\cf3 Delete messages\cf2\f1 
\par \f0\tab\f1 10401\f0\tab\b\f1 DL_NothingToDel\b0 
\par \f0\tab\f1  \tab  'Error - no files selected for deletion';
\par 
\par \f0\tab\tab\cf3 Extract messages\cf2\f1 
\par \f0\tab\f1 10502\f0\tab\b\f1 EX_UnAttPassword\b0 
\par  \tab\f0\tab\f1  'Warning - Unattended Extract: possible not all files extracted';
\par \f0\tab\f1 10504\f0\tab\b\f1 EX_NoExtrDir\b0 
\par \f0\tab\f1  \tab  'Extract directory ''%s'' must exist';
\par 
\par \f0\tab\tab\cf3 Loading Dll\cf2  \f1 
\par \f0\tab\f1 10650\f0\tab\b\f1 LD_NoDll\b0 
\par  \tab\f0\tab\f1  'Failed to load %s';
\par \f0\tab\tab        \cf0\f2 Windows could not load the named DLL - most likely could not find it or it is already in use\cf2\f1 
\par \f0\tab\f1 10652\f0\tab\b\f1 LD_DllLoaded\b0 
\par \f0\tab\f1  \tab  'Loaded %s';
\par \f0\tab\tab        \cf0\f2 The named DLL was found and loaded into memory\cf2\f1 
\par \f0\tab\f1 10653\f0\tab\b\f1 LD_DllUnloaded\b0 
\par  \tab\f0\tab\f1  'Unloaded %s';
\par \f0\tab\tab        \cf0\f2 The named DLL was unloaded\cf2\f1 
\par \f0\tab\f1 10654\f0\tab\b\f1 LD_LoadErr\b0 
\par \f0\tab\f1  \tab  'Error [%d %s] loading %s';
\par 
\par \f0\tab\tab\cf3 SFX preparation errors\cf2\f1 
\par \f0\tab\f1 10801\f0\tab\b\f1 SF_StringTooLong\b0 
\par  \tab\f0\tab\f1  'Error: Combined SFX strings unreasonably long!';
\par \f0\tab\tab         \cf0\f2 The combined length of the properties \cf4\strike SFXCaption\strike0\{linkID=1660\}\cf0 , \cf4\strike SFXDefaultDir\strike0\{linkID=1720\}\cf0 , \cf4\strike SFXCommandLine\strike0\{linkID=1690\}\cf0  is too large.\cf2\f1 
\par \f0\tab\f1 10802\f0\tab\b\f1 SF_NoZipSFXBin\b0 
\par \f0\tab\f1  \tab  'Error: SFX stub ''%s'' not found!';
\par \cf0\f2\tab\tab         The file binary stub was not found on the search path and thus can not be used to make a self extracting zip archive.
\par \tab\tab         See also: \cf4\strike SFXPath\strike0\{linkID=1900\}\cf2\f1 
\par \f0\tab\f1 10810\f0\tab\b\f1 SF_DetachedHeaderTooBig\b0 
\par  \tab\f0\tab\f1  'Detached SFX Header too large';
\par \f0\tab\tab          The detached stub and header are too large to fit in the available space\f1 
\par \f0\tab\f1 10902\f0\tab\b\f1 CZ_InputNotExe\b0 
\par \f0\tab\f1  \tab  'Error: input file is not an .EXE file';
\par \f0\tab\tab          \cf4\strike\f2 ZipFileName\strike0\{linkID=2090\}\cf0  does not specify a self extracting archive (with .EXE extension).\cf2\f1 
\par \f0\tab\f1 10906\f0\tab\b\f1 CZ_BrowseError\b0 
\par  \tab\f0\tab\f1  'Error while browsing resources.';
\par \f0\tab\f1 10907\f0\tab\b\f1 CZ_NoExeResource\b0 
\par \f0\tab\f1  \tab  'No resources found in executable.';
\par \f0\tab\f1 10908\f0\tab\b\f1 CZ_ExeSections\b0 
\par  \tab\f0\tab\f1  'Error while reading executable sections.';
\par \f0\tab\f1 10909\f0\tab\b\f1 CZ_NoExeIcon\b0 
\par \f0\tab\f1  \tab  'No icon resources found in executable.';
\par \f0\tab\f1 10910\f0\tab\b\f1 CZ_NoIcon\b0 
\par  \tab\f0\tab\f1  'No icon found.';
\par \f0\tab\f1 10911\f0\tab\b\f1 CZ_NoCopyIcon\b0 
\par \f0\tab\f1  \tab  'Cannot copy icon.';
\par \f0\tab\f1 10912\f0\tab\b\f1 CZ_NoIconFound\b0 
\par  \tab\f0\tab\f1  'No matching icon found.';
\par 
\par \f0\tab\tab\cf3 General messages and errors\cf2\f1 
\par \f0\tab\f1 11001\f0\tab\b\f1 DS_NoInFile\b0 
\par \f0\tab\f1  \tab  'Input file does not exist';
\par \f0\tab\f1 11002\f0\tab\b\f1 DS_FileOpen\b0 
\par  \tab\f0\tab\f1  'Zip file could not be opened';
\par \f0\tab\f1 11003\f0\tab\b\f1 DS_NotaDrive\b0 
\par \f0\tab\f1  \tab  'Not a valid drive: %s';
\par \f0\tab\tab         \cf0\f2 The drive letter of the input or output file must be in the range from A to Z.\cf2\f1 
\par \f0\tab\f1 11004\f0\tab\b\f1 DS_DriveNoMount\b0 
\par  \tab\f0\tab\f1  'Drive %s is NOT defined';
\par \f0\tab\tab         \cf0\f2 The drive is not available or drive information could not be obtained.\cf2\f1 
\par \f0\tab\f1 11005\f0\tab\b\f1 DS_NoVolume\b0 
\par \f0\tab\f1  \tab  'Volume label could not be set';
\par \f0\tab\f1 11006\f0\tab\b\f1 DS_NoMem\b0 
\par  \tab\f0\tab\f1  'Not enough memory to display MsgBox';
\par \f0\tab\f1 11007\f0\tab\b\f1 DS_Canceled\b0 
\par \f0\tab\f1  \tab  'User canceled operation';
\par \f0\tab\f1 11008\f0\tab\b\f1 DS_FailedSeek\b0 
\par  \tab\f0\tab\f1  'Seek error in input file';
\par \f0\tab\f1 11009\f0\tab\b\f1 DS_NoOutFile\b0 
\par \f0\tab\f1  \tab  'Creation of output file failed';
\par \f0\tab\tab         \cf0\f2 Your drive could be write protected.\cf2\f1 
\par \f0\tab\f1 11010\f0\tab\b\f1 DS_NoWrite\b0 
\par \f0\tab\f1  \tab  'Write error in output file';
\par \f0\tab\f1 11011\f0\tab\b\f1 DS_EOCBadRead\b0 
\par \f0\tab\f1  \tab  'Error while reading the End Of Central Directory';
\par \f0\tab\f1 11012\f0\tab\b\f1 DS_LOHBadRead\b0 
\par \f0\tab\f1  \tab  'Error while reading a local header';
\par \f0\tab\f1 11013\f0\tab\b\f1 DS_CEHBadRead\b0 
\par \f0\tab\f1  \tab  'Error while reading a central header';
\par \f0\tab\f1 11015\f0\tab\b\f1 DS_CEHWrongSig\b0 
\par \f0\tab\f1  \tab  'A central header signature is wrong';
\par \f0\tab\f1 11017\f0\tab\b\f1 DS_CENameLen\b0 
\par \f0\tab\f1  \tab  'Error while reading a central file name';
\par \f0\tab\f1 11020\f0\tab\b\f1 DS_DataDesc\b0 
\par \f0\tab\f1  \tab  'Error while reading/writing a data descriptor area';
\par \f0\tab\f1 11022\f0\tab\b\f1 DS_CECommentLen\b0 
\par \f0\tab\f1  \tab  'Error while reading a file comment';
\par \f0\tab\f1 11024\f0\tab\b\f1 DS_ErrorUnknown\b0 
\par \f0\tab\f1  \tab  'UnKnown error in function ReadSpan(), WriteSpan(), ChangeFileDetails() or CopyZippedFiles()'#10;
\par \f0\tab\f1 11025\f0\tab\b\f1 DS_NoUnattSpan\b0 
\par \f0\tab\f1  \tab  'Unattended disk spanning not implemented';
\par \cf0\f2\tab\tab         if you want disk spanning the program must ask you for the next disk and continue when it's put into the drive. 
\par \tab\tab         Asking questions is not allowed when you also have set the '\cf4\strike Unattended\strike0\{linkID=2110\}\cf0 ' property to\b  \b0 true.\cf2\f1 
\par \f0\tab\f1 11027\f0\tab\b\f1 DS_NoTempFile\b0 
\par \f0\tab\f1  \tab  'Temporary file could not be created';
\par \f0\tab\f1 11028\f0\tab\b\f1 DS_LOHBadWrite\b0 
\par \f0\tab\f1  \tab  'Error while writing a local header';
\par \f0\tab\f1 11029\f0\tab\b\f1 DS_CEHBadWrite\b0 
\par \f0\tab\f1   \tab  'Error while writing a central header';
\par \f0\tab\f1 11030\f0\tab\b\f1 DS_EOCBadWrite\b0 
\par \f0\tab\f1   \tab  'Error while writing the End Of Central Directory';
\par \f0\tab\f1 11032\f0\tab\b\f1 DS_NoDiskSpace\b0 
\par \f0\tab\f1   \tab  'This disk has not enough free space available';
\par \f0\tab\f1 11033\f0\tab\b\f1 DS_InsertDisk\b0 
\par \f0\tab\f1   \tab  'Please insert last disk';
\par \f0\tab\f1 11034\f0\tab\b\f1 DS_InsertVolume\b0 
\par \f0\tab\f1   \tab  'Please insert disk volume %.1d of %.1d';
\par \f0\tab\f1 11035\f0\tab\b\f1 DS_InDrive\b0 
\par \f0\tab\f1   \tab  ''#10'in drive: %s';
\par \f0\tab\f1 11036\f0\tab\b\f1 DS_NoValidZip\b0 
\par \f0\tab\f1   \tab  'This archive is not a valid Zip archive';
\par \f0\tab\f1 11039\f0\tab\b\f1 DS_AskDeleteFile\b0 
\par \f0\tab\f1   \tab  'There is already a file %s'#10'Do you want to overwrite this file';
\par \f0\tab\f1 11040\f0\tab\b\f1 DS_AskPrevFile\b0 
\par \f0\tab\f1   \tab  'ATTENTION: This is previous disk no %d!!!'#10'Are you sure you want to overwrite the contents';
\par \f0\tab\f1 11046\f0\tab\b\f1 DS_InsertAVolume\b0 
\par \f0\tab\f1   \tab  'Please insert disk volume %.1d';
\par \f0\tab\f1 11047\f0\tab\b\f1 DS_CopyCentral\b0 
\par \f0\tab\f1   \tab  'Central directory';
\par \f0\tab\f1 11048\f0\tab\b\f1 DS_NoDiskSpan\b0 
\par \f0\tab\f1   \tab  'DiskSpanning not supported';
\par \f0\tab\f1 11049\f0\tab\b\f1 DS_UnknownError\b0 
\par \f0\tab\f1   \tab  'Unknown Error';
\par \f0\tab\f1 11050\f0\tab\b\f1 DS_NoRenamePart\b0 
\par \f0\tab\f1   \tab  'Last part left as : %s';
\par \f0\tab\f1 11051\f0\tab\b\f1 DS_NotChangeable\b0 
\par \f0\tab\f1   \tab  'Cannot write to %s';
\par \f0\tab\f1 11052\f0\tab\b\f1 DS_Zip64FieldError\b0 
\par \f0\tab\f1   \tab  'Error reading Zip64 field';
\par \f0\tab\f1 11053\f0\tab\b\f1 DS_Unsupported\b0 
\par \f0\tab\f1   \tab  'Unsupported zip version';
\par \f0\tab\f1 11054\f0\tab\b\f1 DS_ReadError\b0 
\par \f0\tab\f1   \tab  'Error reading file';
\par \f0\tab\f1 11055\f0\tab\b\f1 DS_WriteError\b0 
\par \f0\tab\f1   \tab  'Error writing file';
\par \f0\tab\f1 11056\f0\tab\b\f1 DS_FileError\b0 
\par \f0\tab\f1   \tab  'File Error';
\par \f0\tab\f1 11057\f0\tab\b\f1 DS_FileChanged\b0 
\par \f0\tab\f1   \tab  'File changed';
\par \f0\tab\f1 11058\f0\tab\b\f1 DS_SFXBadRead\b0 
\par \f0\tab\f1   \tab  'Error reading SFX';
\par \f0\tab\f1 11059\f0\tab\b\f1 DS_BadDrive\b0 
\par \f0\tab\f1   \tab  'cannot use drive';
\par \f0\tab\f1 11060\f0\tab\b\f1 DS_LOHWrongName\b0 
\par \f0\tab\f1   \tab  'Local and Central names different : %s';
\par \f0\tab\f1 11061\f0\tab\b\f1 DS_BadCRC\b0 
\par \f0\tab\f1   \tab  'CRC error';
\par \f0\tab\f1 11062\f0\tab\b\f1 DS_NoEncrypt\b0 
\par \f0\tab\f1   \tab  'encryption not supported';
\par \f0\tab\f1 11063\f0\tab\b\f1 DS_NoInStream\b0 
\par \f0\tab\f1   \tab  'No input stream';
\par \f0\tab\f1 11064\f0\tab\b\f1 DS_NoOutStream\b0 
\par \f0\tab\f1   \tab  'No output stream';
\par \f0\tab\f1 11065\f0\tab\b\f1 DS_SeekError\b0 
\par \f0\tab\f1   \tab  'File seek error';
\par \f0\tab\f1 11066\f0\tab\b\f1 DS_DataCopy\b0 
\par \f0\tab\f1   \tab  'Error copying compressed data';
\par \f0\tab\f1 11067\f0\tab\b\f1 DS_CopyError\b0 
\par \f0\tab\f1   \tab  'File copy error';
\par \f0\tab\f1 11068\f0\tab\b\f1 DS_TooManyParts\b0 
\par \f0\tab\f1   \tab  'More than 999 parts in multi volume archive';
\par 
\par \f0\tab\f1 11101\f0\tab\b\f1 FM_Erase\b0 
\par \f0\tab\f1   \tab  'Erase %s';
\par \f0\tab\f1 11102\f0\tab\b\f1 FM_Confirm\b0 
\par \f0\tab\f1   \tab  'Confirm';
\par 
\par \f0\tab\tab\cf3 Change details\cf2\f1 
\par \f0\tab\f1 11307\f0\tab\b\f1 CD_CEHDataSize\b0 
\par \f0\tab\f1   \tab  'The combined length of CEH + FileName + FileComment + ExtraData exceeds 65535';
\par \f0\tab\f1 11309\f0\tab\b\f1 CD_DuplFileName\b0 
\par \f0\tab\f1   \tab  'Duplicate Filename: %s';
\par \f0\tab\f1 11310\f0\tab\b\f1 CD_NoProtected\b0 
\par \f0\tab\f1   \tab  'Cannot change details of E\f0 n\f1 crypted file';
\par \f0\tab\f1 11312\f0\tab\b\f1 CD_NoChangeDir\b0 
\par \f0\tab\f1   \tab  'Cannot change path';
\par 
\par \f0\tab\tab\cf3 Progress Messages\cf2\f1 
\par \f0\tab\f1 11401\f0\tab\b\f1 PR_Archive\b0 
\par \f0\tab\f1   \tab  '*Resetting Archive bit';
\par \f0\tab\f1 11402\f0\tab\b\f1 PR_CopyZipFile\b0 
\par \f0\tab\f1   \tab  '*Copying Zip File';
\par \f0\tab\f1 11403\f0\tab\b\f1 PR_SFX\b0 
\par \f0\tab\f1   \tab  '*SFX';
\par \f0\tab\f1 11404\f0\tab\b\f1 PR_Header\b0 
\par \f0\tab\f1   \tab  '*??';
\par \f0\tab\f1 11405\f0\tab\b\f1 PR_Finish\b0 
\par \f0\tab\f1   \tab  '*Finalising';
\par \f0\tab\f1 11406\f0\tab\b\f1 PR_Copying\b0 
\par \f0\tab\f1   \tab  '*Copying';
\par \f0\tab\f1 11407\f0\tab\b\f1 PR_CentrlDir\b0 
\par \f0\tab\f1   \tab  '*Central Directory';
\par \f0\tab\f1 11408\f0\tab\b\f1 PR_Checking\b0 
\par \f0\tab\f1   \tab  '*Checking';
\par \f0\tab\f1 11409\f0\tab\b\f1 PR_Loading\b0 
\par \f0\tab\f1   \tab  '*Loading Directory';
\par \f0\tab\f1 11410\f0\tab\b\f1 PR_Joining\b0 
\par \f0\tab\f1   \tab  '*Joining split zip file';
\par \f0\tab\f1 11411\f0\tab\b\f1 PR_Splitting\b0 
\par \f0\tab\f1   \tab  '*Splitting zip file';
\par \f0\tab\f1 11412\f0\tab\b\f1 PR_Writing\b0 
\par \f0\tab\f1   \tab  '*Writing zip file';
\par \f0\tab\f1 11413\f0\tab\b\f1 PR_PreCalc\b0 
\par \f0\tab\f1   \tab  '*Precalculating CRC';
\par 
\par \f0\tab\f1 11450\f0\tab\b\f1 DZ_Skipped\b0 
\par \f0\tab\f1   \tab  'Filespec ''%s'' skipped';
\par \f0\tab\f1 11451\f0\tab\b\f1 DZ_InUse\b0 
\par \f0\tab\f1   \tab  'Cannot open in-use file ''%s''';
\par \f0\tab\f1 11452\f0\tab\b\f1 DZ_Refused\b0 
\par \f0\tab\f1   \tab  'not permitted to open ''%s''';
\par \f0\tab\f1 11453\f0\tab\b\f1 DZ_NoOpen\b0 
\par \f0\tab\f1   \tab  'Can not open ''%s''';
\par \f0\tab\f1 11454\f0\tab\b\f1 DZ_NoFiles\b0 
\par \f0\tab\f1   \tab  'no files found';
\par \f0\tab\f1 11455\f0\tab\b\f1 DZ_SizeChanged\b0 
\par \f0\tab\f1   \tab  'size of ''%s'' changed';
\par 
\par \f0\tab\tab\cf3 Trace messages\cf2\f1 
\par \f0\tab\f1 11600\f0\tab\b\f1 TM_Erasing\b0 
\par \f0\tab\f1   \tab  'EraseFloppy - Removing %s';
\par \f0\tab\f1 11601\f0\tab\b\f1 TM_Deleting\b0 
\par \f0\tab\f1   \tab  'EraseFloppy - Deleting %s';
\par \f0\tab\f1 11602\f0\tab\b\f1 TM_GetNewDisk\b0 
\par \f0\tab\f1   \tab  'Trace : GetNewDisk Opening: %s';
\par \f0\tab\f1 11603\f0\tab\b\f1 TM_SystemError\b0 
\par \f0\tab\f1   \tab  'System error: %d';
\par \f0\tab\f1 11604\f0\tab\b\f1 TM_Trace\b0 
\par \f0\tab\f1   \tab  'Trace: ';
\par \f0\tab\f1 11605\f0\tab\b\f1 TM_Verbose\b0 
\par \f0\tab\f1   \tab  'info: ';
\par 
\par \f0\tab\tab\cf3 Dll errors and messages\cf2\f1 
\par \f0\tab\f1 11648\f0\tab\b\f1 DZ_RES_GOOD\b0 
\par \f0\tab\f1   \tab  'Good';
\par \f0\tab\f1 11649\f0\tab\b\f1 DZ_RES_CANCELLED\b0 
\par \f0\tab\f1   \tab  'Cancelled';
\par \f0\tab\f1 11650\f0\tab\b\f1 DZ_RES_ABORT\b0 
\par \f0\tab\f1   \tab  'Aborted by User!';
\par \f0\tab\f1 11651\f0\tab\f1 DZ_RES_CALLBACK
\par \f0\tab\f1   \tab  'Callback exception';
\par \f0\tab\f1 11652\f0\tab\b\f1 DZ_RES_MEMORY\b0 
\par \f0\tab\f1   \tab  'No memory';
\par \f0\tab\f1 11653\f0\tab\b\f1 DZ_RES_STRUCT\b0 
\par \f0\tab\f1   \tab  'Invalid structure';
\par \f0\tab\f1 11654\f0\tab\b\f1 DZ_RES_ERROR\b0 
\par \f0\tab\f1   \tab  'Fatal error';
\par \f0\tab\f1 11655\f0\tab\b\f1 DZ_RES_PASSWORD_FAIL\b0 
\par \f0\tab\f1   \tab  'Password failed!';
\par \f0\tab\f1 11656\f0\tab\b\f1 DZ_RES_PASSWORD_CANCEL\b0 
\par \f0\tab\f1   \tab  'Password cancelled!';
\par \f0\tab\f1 11657\f0\tab\b\f1 DZ_RES_INVAL_ZIP\b0 
\par \f0\tab\f1   \tab  'Invalid zip structure!';
\par \f0\tab\f1 11658\f0\tab\b\f1 DZ_RES_NO_CENTRAL\b0 
\par \f0\tab\f1   \tab  'No Central directory!';
\par \f0\tab\f1 11659\f0\tab\b\f1 DZ_RES_ZIP_EOF\b0 
\par \f0\tab\f1   \tab  'Unexpected end of Zip file!';
\par \f0\tab\f1 11660\f0\tab\b\f1 DZ_RES_ZIP_END\b0 
\par \f0\tab\f1   \tab  'Premature end of file!';
\par \f0\tab\f1 11661\f0\tab\b\f1 DZ_RES_ZIP_NOOPEN\b0 
\par \f0\tab\f1   \tab  'Error opening Zip file!';
\par \f0\tab\f1 11662\f0\tab\b\f1 DZ_RES_ZIP_MULTI\b0 
\par \f0\tab\f1   \tab  'Multi-part Zips not supported!';
\par \f0\tab\f1 11663\f0\tab\b\f1 DZ_RES_NOT_FOUND\b0 
\par \f0\tab\f1   \tab  'File not found!';
\par \f0\tab\f1 11664\f0\tab\b\f1 DZ_RES_LOGIC_ERROR\b0 
\par \f0\tab\f1   \tab  'Internal logic error!';
\par \f0\tab\f1 11665\f0\tab\b\f1 DZ_RES_NOTHING_TO_DO\b0 
\par \f0\tab\f1   \tab  'Nothing to do!';
\par \f0\tab\f1 11666\f0\tab\b\f1 DZ_RES_BAD_OPTIONS\b0 
\par \f0\tab\f1   \tab  'Bad Options specified!';
\par \f0\tab\f1 11667\f0\tab\b\f1 DZ_RES_TEMP_FAILED\b0 
\par \f0\tab\f1   \tab  'Temporary file failure!';
\par \f0\tab\f1 11668\f0\tab\b\f1 DZ_RES_NO_FILE_OPEN\b0 
\par \f0\tab\f1   \tab  'File not found or no permission!';
\par \f0\tab\f1 11669\f0\tab\b\f1 DZ_RES_ERROR_READ\b0 
\par \f0\tab\f1   \tab  'Error reading file!';
\par \f0\tab\f1 11670\f0\tab\b\f1 DZ_RES_ERROR_CREATE\b0 
\par \f0\tab\f1   \tab  'Error creating file!';
\par \f0\tab\f1 11671\f0\tab\b\f1 DZ_RES_ERROR_WRITE\b0 
\par \pard\tx180\tx960\f0\tab\f1   \tab  'Error writing file!';
\par \pard\tx180\tx960\tx3900\f0\tab\f1 11672\f0\tab\b\f1 DZ_RES_ERROR_SEEK\b0 
\par \f0\tab\f1   \tab  'Error seeking in file!';
\par \f0\tab\f1 11673\f0\tab\b\f1 DZ_RES_EMPTY_ZIP\b0 
\par \f0\tab\f1   \tab  'Missing or empty zip file!';
\par \f0\tab\f1 11674\f0\tab\b\f1 DZ_RES_INVAL_NAME\b0 
\par \f0\tab\f1   \tab  'Invalid characters in filename!';
\par \f0\tab\f1 11675\f0\tab\b\f1 DZ_RES_GENERAL\b0 
\par \f0\tab\f1   \tab  'Error ';
\par \f0\tab\f1 11676\f0\tab\b\f1 DZ_RES_MISS\b0 
\par \f0\tab\f1   \tab  'Nothing found';
\par \f0\tab\f1 11677\f0\tab\b\f1 DZ_RES_WARNING\b0 
\par \f0\tab\f1   \tab  'Warning: ';
\par \f0\tab\f1 11678\f0\tab\b\f1 DZ_ERR_ERROR_DELETE\b0 
\par \f0\tab\f1   \tab  'Delete failed';
\par \f0\tab\f1 11679\f0\tab\b\f1 DZ_ERR_FATAL_IMPORT\b0 
\par \f0\tab\f1   \tab  'Fatal Error - could not import symbol!';
\par \f0\tab\f1 11680\f0\tab\b\f1 DZ_ERR_SKIPPING\b0 
\par \f0\tab\f1   \tab  'Skipping: ';
\par \f0\tab\f1 11681\f0\tab\b\f1 DZ_ERR_LOCKED\b0 
\par \f0\tab\f1   \tab  'File locked';
\par \f0\tab\f1 11682\f0\tab\b\f1 DZ_ERR_DENIED\b0 
\par \f0\tab\f1   \tab  'Access denied';
\par \f0\tab\f1 11683\f0\tab\b\f1 DZ_ERR_DUPNAME\b0 
\par \f0\tab\f1   \tab  'Duplicate internal name';
\par }
305
Scribble305
Working with SFX
Resource Format;



Done



FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil\fcharset2 Symbol;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Working with SFX\f1 
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul\f0 Resource Format\cf3\ulnone\f1\{linkID=%\f0 14\f1 0\}\f0\tab\cf2\strike\f1 Example\cf3\strike0\{linkID=%\f0 307\f1\}\cf4\{keepn\}\cf0\b\fs22 
\par \pard\cf1\f0\fs32 
\par \pard\tx200\cf0\b0\fs20 Before doing any of the following operations on a SFX -
\par \pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-200\li200\tx200\cf2\strike Add\cf3\strike0\{linkID=2530\}\cf4\f1 
\par \cf2\strike\f0{\pntext\f2\'B7\tab}AddZippedFiles\cf3\strike0\{linkID=2620\}\cf4\f1 
\par \cf2\strike\f0{\pntext\f2\'B7\tab}ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf4\f1 
\par \cf2\strike\f0{\pntext\f2\'B7\tab}ConvertToSFX\cf3\strike0\{linkID=2720\}\cf4\f1 
\par \cf2\strike\f0{\pntext\f2\'B7\tab}ConvertToSpanSFX\cf3\strike0\{linkID=2750\}\cf4\f1 
\par \cf2\strike\f0{\pntext\f2\'B7\tab}CopyZippedFiles\cf3\strike0\{linkID=2840\}\cf4\f1 
\par \cf2\strike\f0{\pntext\f2\'B7\tab}Delete\cf3\strike0\{linkID=2900\}\cf4\f1 
\par \cf2\strike\f0{\pntext\f2\'B7\tab}Rename\cf3\strike0\{linkID=3380\}\cf4\f1 
\par \pard 
\par \f0 The following properties need to be valid -
\par \pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-200\li200\tx200\cf2\strike SFXCaption\cf3\strike0\{linkID=1660\}\cf4 
\par \cf2\strike{\pntext\f2\'B7\tab}SFXCommandLine\cf3\strike0\{linkID=1690\}\cf4 
\par \cf2\strike{\pntext\f2\'B7\tab}SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf4 
\par \cf2\strike{\pntext\f2\'B7\tab}SFXIcon\cf3\strike0\{linkID=1750\}\cf4 
\par \cf2\strike{\pntext\f2\'B7\tab}SFXMessage\cf3\strike0\{linkID=1780\}\cf4 
\par \cf2\strike{\pntext\f2\'B7\tab}SFXOptions\cf3\strike0\{linkID=1840\}\cf4 
\par \cf2\strike{\pntext\f2\'B7\tab}SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf4 
\par \cf2\strike{\pntext\f2\'B7\tab}SFXPath\cf3\strike0\{linkID=1900\}\cf4 
\par \cf2\strike{\pntext\f2\'B7\tab}SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf4 
\par \pard\f1 
\par 
\par }
307
Scribble307
Working with SFX - Example




Done



FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\fs24 Working with SFX - Example\cf2\{keepn\}\cf3\b0\f1\fs20 
\par \pard\tx4220 
\par \f0\{$R 'Res\\ZMRes19_sfx.res'\}\tab\tab\cf4 // link the stub to our application\cf3 
\par \f1 
\par \f0   zip.ZipFileName := 'Example.EXE';\tab\tab\cf4 // file to work on\cf3 
\par   if zip.ErrCode <> 0 then 
\par       Handle_the_error!
\par   zip.FSpecArgs := '*.pas';\tab\tab\tab 
\par   zip.SFXCaption := 'Sample SFX';
\par   zip.SFXCommandLine := '';\tab\tab\cf4 // no post-extract operation\cf3 
\par   zip.SFXDefaultDir := 'c:\\temp';\tab\tab\cf4 // a default destination\cf3 
\par   zip.SFXIcon := nil;\tab\tab\cf4 // use default\cf3 
\par   zip.SFXMessage := 'This is an example';\tab\tab\cf4 // a MessageBox before the main dialog\cf3 
\par   zip.SFXOptions := [soCanBeCancelled];\tab\tab\cf4 // allow cancelling extraction\cf3 
\par   zip.SFXOverwriteMode := ovrConfrim;\tab\tab\cf4 // ask before overwriting\cf3 
\par   zip.SFXPath := '><';\tab\tab\cf4 // use the stub in the Resources\cf3\f1 
\par \f0   zip.SFXRegFailPath := '';\tab\tab\cf4 // not using registry paths\cf3 
\par 
\par   err := zip.Add;\tab\tab\cf4 // do the operation\cf3 
\par   if err <> 0 then
\par       Handle_the_error!
\par \pard 
\par \cf5\b\fs24 Notes:\cf3\b0\fs20 
\par   \cf5\b 1.\cf3\b0  if the file exists before setting ZipFileName and the SFX properties can be read the SFX?? properties will be loaded from that file.
\par   \cf5\b 2.\cf3\b0  setting any SFX?? property before setting ZipFileName will stop the old properties from being used.
\par   \cf5\b 3.\cf3\b0  unless the stub is linked in the applications resources, SFXPath must be set to a valid stub.\f1 
\par }
310
Scribble310
Tools




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fswiss Arial;}{\f2\fnil\fcharset0 Times New Roman;}{\f3\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green128\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Tools\cf2\{keepn\}\cf0\f1\fs28 
\par \cf3\b0\strike\fs20 TZipMaster\strike0\{linkID=10>main\}\cf0\f2\fs24\tab\cf4\f3\fs20 
\par 
\par 
\par }
320
Scribble320
ZipResMaker
Tools;



Done



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fswiss Arial;}{\f2\fnil\fcharset0 Times New Roman;}{\f3\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green128\blue0;\red0\green128\blue128;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 ZipResMaker\cf2\{keepn\}\cf0\f1\fs28 
\par \cf3\b0\strike\fs20 TZipMaster\strike0\{linkID=10>main\}\cf0\f2\fs24\tab\cf3\ul\f0\fs20 See also: \ulnone\strike Resources\cf2\strike0\{linkID=120\}\cf1\b\fs32 
\par 
\par \cf0\fs24 Description
\par   \b0\fs20 Used to prepare the resources for binding to executable\b\fs24 
\par \cf1\fs32 
\par \cf4\lang1033\fs20 <install dir>\\\cf0 TOOLS\\ZipResMaker\\ZipResMaker.exe\cf4\b0 
\par 
\par \cf5\lang3081 
\par    \f3 
\par 
\par 
\par }
330
Scribble330
ZipMstr19 unit
ZipMstr20;ZipMstr20 unit;


ZipMstr20:001000
Writing



FALSE
95
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ZipMstr19 unit
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\fs20 
\par \f1 Main unit\f0 
\par 
\par \b\fs22 Components\cf2\b0\fs20 
\par \cf3\strike TZipMaster\cf4\strike0\{linkID=350\}\cf2 
\par 
\par \cf0\b\fs22 Classes
\par \cf3\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf4\strike0\{linkID=\f1 595\f0 0\}\cf2 
\par \cf3\strike TZ\f1 M\f0 DirEntry\cf4\strike0\{linkID=6340\}\cf0\b\fs22 
\par \cf3\b0\strike\fs20 TZ\f1 M\f0 DirRec\cf4\strike0\{linkID=7090\}\cf2 
\par \cf3\strike TZipMasterEnumerator\cf4\strike0\{linkID=7330\}
\par \cf3\strike\f1 TZMPipe\cf4\strike0\{linkID=7340\}
\par \cf3\strike TZMPipeList\cf4\strike0\{linkID=7440\}\cf2\f0 
\par 
\par \cf0\b\fs22 Types
\par \cf3\b0\strike\f1\fs20 P\f0 Z\f1 M\f0 RenameRec\cf4\strike0\{linkID=4360\}\cf2 
\par \cf3\strike PZ\f1 M\f0 SStats\cf4\strike0\{linkID=4380\}\cf2 
\par \cf3\strike TSFXOpt\cf4\strike0\{linkID=4390\}\cf2 
\par \cf3\strike TSFXOpts\cf4\strike0\{linkID=4410\}\cf2 
\par \cf3\strike TZ\f1 M\f0 ChangeFunction\cf4\strike0\{linkID=4430\}\cf2 
\par \cf3\strike TZ\f1 M\f0 ForEachFunction\cf4\strike0\{linkID=4450\}\cf2 
\par \cf3\strike TZ\f1 M\f0 RenameRec\cf4\strike0\{linkID=4470\}\cf2 
\par \cf3\strike TZMAddOpts\cf4\strike0\{linkID=4490\}\cf2 
\par \cf3\strike TZMAddOptsEnum\cf4\strike0\{linkID=4510\}\cf2 
\par \cf3\strike TZMAddStoreExts\cf4\strike0\{linkID=4530\}\cf2 
\par \cf3\strike TZMAddStoreSuffixEnum\cf4\strike0\{linkID=4550\}\cf2 
\par \cf3\strike TZMCheckTerminateEvent\cf4\strike0\{linkID=4570\}\cf2 
\par \cf3\strike TZMCopyZippedOverwriteEvent\cf4\strike0\{linkID=4590\}\cf2 
\par \cf3\strike TZMCRC32ErrorEvent\cf4\strike0\{linkID=4610\}\cf2 
\par \cf3\strike TZMDeleteOpts\cf4\strike0\{linkID=4630\}\cf2 
\par \cf3\strike TZMDialogEvent\cf4\strike0\{linkID=4650\}\cf2 
\par \cf3\strike TZMDiskAction\cf4\strike0\{linkID=4680\}\cf2 
\par \cf3\strike TZMEncodingOpts\cf4\strike0\{linkID=4700\}\cf2 
\par \cf3\strike TZMExtractOverwriteEvent\cf4\strike0\{linkID=4720\}\cf2 
\par \cf3\strike TZMExtrOpts\cf4\strike0\{linkID=4740\}\cf2 
\par \cf3\strike TZMExtrOptsEnum\cf4\strike0\{linkID=4760\}\cf2 
\par \cf3\strike TZMFileCommentEvent\cf4\strike0\{linkID=4780\}\cf2 
\par \cf3\strike TZMFileExtraEvent\cf4\strike0\{linkID=4800\}\cf2 
\par \cf3\strike TZMGetNextDiskEvent\cf4\strike0\{linkID=4820\}\cf2 
\par \cf3\strike TZMMergeOpts\cf4\strike0\{linkID=4840\}\cf2 
\par \cf3\strike TZMMessageEvent\cf4\strike0\{linkID=4860\}\cf2 
\par \cf3\strike TZMNewNameEvent\cf4\strike0\{linkID=4880\}\cf2 
\par \cf3\strike TZMOvrOpts\cf4\strike0\{linkID=4900\}\cf2 
\par \cf3\strike TZMPasswordErrorEvent\cf4\strike0\{linkID=4920\}\cf2 
\par \cf3\strike TZMProgressDetailsEvent\cf4\strike0\{linkID=4940\}\cf2 
\par \cf3\strike TZMProgressType\cf4\strike0\{linkID=4960\}\cf2 
\par \cf3\strike TZMRenameOpts\cf4\strike0\{linkID=4980\}\cf2 
\par \cf3\strike TZMReplaceOpts\cf4\strike0\{linkID=5000\}\cf2 
\par \cf3\strike TZMSetAddNameEvent\cf4\strike0\{linkID=5020\}\cf2 
\par \cf3\strike TZMSetCompLevel\cf4\strike0\{linkID=5040\}\cf2 
\par \cf3\strike TZMSetExtNameEvent\cf4\strike0\{linkID=5060\}\cf2 
\par \cf3\strike TZMSkippedEvent\cf4\strike0\{linkID=5080\}
\par \cf3\strike TZMSkipAborts\cf4\strike0\{linkID=5120\}\cf2 
\par \cf3\strike TZMSkipTypes\cf4\strike0\{linkID=5100\}\cf2 
\par \cf3\strike TZMSpanOpts\cf4\strike0\{linkID=5140\}\cf2 
\par \cf3\strike TZMSpanOptsEnum\cf4\strike0\{linkID=5160\}\cf2 
\par \cf3\strike TZMStateChange\cf4\strike0\{linkID=5180\}\cf2 
\par \cf3\strike TZMStates\cf4\strike0\{linkID=5200\}\cf2 
\par \cf3\strike TZMStatusDiskEvent\cf4\strike0\{linkID=5220\}\cf2 
\par \cf3\strike TZMStreamEvent\cf4\strike0\{linkID=5240\}\cf2 
\par \cf3\strike TZMStrEvent\cf4\strike0\{linkID=5260\}\cf2 
\par \cf3\strike TZM\f1 RawBytes\cf4\strike0\f0\{linkID=52\f1 75\f0\}\cf2 
\par \cf3\strike TZMString\cf4\strike0\{linkID=5280\}\cf2 
\par \cf3\strike TZMTickEvent\cf4\strike0\{linkID=5290\}\cf2 
\par \cf3\strike TZMWideString\cf4\strike0\{linkID=5310\}\cf2 
\par \cf3\strike TZMWriteOpts\cf4\strike0\{linkID=5390\}\cf2 
\par \cf3\strike TZMWriteOptsEnum\cf4\strike0\{linkID=5410\}\cf2 
\par \cf3\strike TZMZipDiskStatus\cf4\strike0\{linkID=5430\}\cf2 
\par \cf3\strike TZMZipDiskStatusEnum\cf4\strike0\{linkID=5450\}\cf2 
\par \cf3\strike TZ\f1 M\f0 SStats\cf4\strike0\{linkID=5470\}\cf2 
\par \cf3\strike TZ\f1 M\f0 StreamOp\cf4\strike0\{linkID=5490\}\cf2 
\par 
\par \cf0\b\fs22 Constants
\par \b0\fs20 DELZIPVERSION
\par ZIPBUILDERBUILD = "1.9.\f1 0.\f0 xxxx";  xxxx = build number
\par ZIPBUILDERDATE = "d/m/yyyy"; d/m/yyyy = day/moth/year of last build
\par ZIPBUILDERPRIV = 190xxxx; xxxx = build number
\par 
\par ZMDefAddStoreSuffixes
\par ZMReentry_Error
\par ZMPWLEN
\par zsbDirOnly
\par zsbDirty
\par zsbError
\par zsbIgnore
\par zsbInvalid
\par zsbSelected
\par zsbSkipped
\par 
\par 
\par }
350
Scribble350
TZipMaster component
TZipMaster;



Done



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 TZipMaster component\f1 
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul Properties\cf3\ulnone\{linkID=%380\}\tab\cf2\ul Methods\cf3\ulnone\{linkID=%390\}\tab\cf2\ul Events\cf3\ulnone\{linkID=%400\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Description
\par \b0\f0\fs20 The main component to load or edit a zip file\f1 
\par 
\par \pard\cf4 
\par 
\par 
\par }
360
Scribble360
TZipMaster component - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TZipMaster component >>>
\par \cf2 
\par 
\par }
370
Scribble370
TZipMaster - Types




Done



FALSE
68
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red255\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 TZipMaster - Types
\par \f1\fs20 
\par \pard\tx300\cf2\b0\f2\tab\cf3\strike\f0 PZMRenameRec\cf4\strike0\f1\{linkID=4360\}\cf0 
\par \cf3\f0\tab\strike PZMSStats\cf4\strike0\f1\{linkID=4380\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMSFXOpt\cf4\strike0\f1\{linkID=4390\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMSFXOpts\cf4\strike0\f1\{linkID=4410\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMZipChangeFunction\cf4\strike0\f1\{linkID=4430\}\cf0 
\par \cf3\f0\tab\strike TZMForEachFunctionType\cf4\strike0\f1\{linkID=4450\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMRenameRec\cf4\strike0\f1\{linkID=4470\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMAddOpts\cf4\strike0\f1\{linkID=4490\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMAddOptsEnum\cf4\strike0\f1\{linkID=4510\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMAddStoreExts\cf4\strike0\f1\{linkID=4530\}\cf0 
\par \cf2\f2  \tab\cf3\strike\f0 TZMAddStoreSuffixEnum\cf4\strike0\f1\{linkID=4550\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMCheckTerminateEvent\cf4\strike0\f1\{linkID=4570\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMCopyZippedOverwriteEvent\cf4\strike0\f1\{linkID=4590\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMCRC32ErrorEvent\cf4\strike0\f1\{linkID=4610\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMDeleteOpts\cf4\strike0\f1\{linkID=4630\}\cf0 
\par \cf3\f0\tab\strike TZMDialogEvent\cf4\strike0\f1\{linkID=4650\}\cf0 
\par \cf3\f0\tab\strike TZMDiskAction\cf4\strike0\f1\{linkID=4680\}\cf0 
\par \cf3\f0\tab\strike TZMEncodingOpts\cf4\strike0\f1\{linkID=4700\}\cf0 
\par \cf3\f0\tab\strike TZMExtractOverwriteEvent\cf4\strike0\f1\{linkID=4720\}\cf0 
\par \cf3\f0\tab\strike TZMExtraOpts\cf4\strike0\f1\{linkID=4740\}\cf0 
\par \cf3\f0\tab\strike TZMExtrOptsEnum\cf4\strike0\f1\{linkID=4760\}\cf0 
\par \cf3\f0\tab\strike TZMFileCommentEvent\cf4\strike0\f1\{linkID=4780\}\cf0 
\par \cf3\f0\tab\strike TZMFileExtraEvent\cf4\strike0\f1\{linkID=4800\}\cf0 
\par \cf3\f0\tab\strike TZMGetNextDiskEvent\cf4\strike0\f1\{linkID=4820\}\cf0 
\par \cf3\f0\tab\strike TZMLoadStrEvent\cf4\strike0\f1\{linkID=5260\}\cf0 
\par \cf3\f0\tab\strike TZMMergeOpts\cf4\strike0\f1\{linkID=4840\}\cf0 
\par \cf3\f0\tab\strike TZMMessageEvent\cf4\strike0\f1\{linkID=4860\}\cf0 
\par \cf3\f0\tab\strike TZMNewNameEvent\cf4\strike0\f1\{linkID=4880\}\cf0 
\par \cf3\f0\tab\strike TZMOvrOpts\cf4\strike0\f1\{linkID=4900\}\cf0 
\par \cf3\f0\tab\strike TZMPasswordErrorEvent\cf4\strike0\f1\{linkID=4920\}\cf0 
\par \cf3\f0\tab\strike TZMProgressDetailsEvent\cf4\strike0\f1\{linkID=4940\}\cf0 
\par \cf3\f0\tab\strike TZMProgressType\cf4\strike0\f1\{linkID=4960\}\cf0 
\par \cf3\f0\tab\strike TZMRenameOpts\cf4\strike0\f1\{linkID=4980\}\cf0 
\par \cf3\f0\tab\strike TZMCompLevel\cf4\strike0\f1\{linkID=5040\}\cf0 
\par \cf3\f0\tab\strike TZMReplaceOpts\cf4\strike0\f1\{linkID=5000\}\cf0 
\par \cf3\f0\tab\strike TZMSetExtNameEvent\cf4\strike0\f1\{linkID=5060\}\cf0 
\par \cf3\f0\tab\strike TZMSkippedEvent\cf4\strike0\f1\{linkID=5080\}\cf0 
\par \cf3\f0\tab\strike TZMSkipTypes\cf4\strike0\f1\{linkID=5100\}\cf0 
\par \cf3\f0\tab\strike TZMSkipAborts\cf4\strike0\f1\{linkID=5120\}\cf0 
\par \cf3\f0\tab\strike TZMSpanOpts\cf4\strike0\f1\{linkID=5140\}\cf0 
\par \cf3\f0\tab\strike TZMSpanOptsEnum\cf4\strike0\f1\{linkID=5160\}\cf0 
\par \cf3\f0\tab\strike TZMStateChange\cf4\strike0\f1\{linkID=5180\}\cf0 
\par \cf3\f0\tab\strike TZMStates\cf4\strike0\f1\{linkID=5200\}\cf0 
\par \cf3\f0\tab\strike TZMStatusDiskEvent\cf4\strike0\f1\{linkID=7200\}\cf0 
\par \cf3\f0\tab\strike TZMStreamEvent\cf4\strike0\f1\{linkID=5240\}\cf0 
\par \cf3\f0\tab\strike TZMString\cf4\strike0\f1\{linkID=5280\}\cf0 
\par \cf3\f0\tab\strike TZMWideString\cf4\strike0\f1\{linkID=5310\}\cf0 
\par \cf3\f0\tab\strike TZMWriteOpts\cf4\strike0\f1\{linkID=5390\}\cf0 
\par \cf3\f0\tab\strike TZMWriteOptsEnum\cf4\strike0\f1\{linkID=5410\}\cf0 
\par \cf3\f0\tab\strike TZMZipDiskStatus\cf4\strike0\f1\{linkID=5430\}\cf0 
\par \cf3\f0\tab\strike TZMZipDiskStatusEnum\cf4\strike0\f1\{linkID=5450\}\cf0 
\par \cf3\f0\tab\strike TZMSStats\cf4\strike0\f1\{linkID=5470\}\cf0 
\par \cf3\f0\tab\strike TZMStreamOp\cf4\strike0\f1\{linkID=5490\}\cf0 
\par \cf3\f0\tab\strike TZMProgressDetails\cf4\strike0\f1\{linkID=5950\}\cf0 
\par \cf3\f0\tab\strike TZMDirEntry\cf4\strike0\f1\{linkID=6340\}\cf0 
\par \cf3\f0\tab\strike TZMDirRec\cf4\strike0\f1\{linkID=7090\}\cf0 
\par \cf3\f0\tab\strike TZipMasterEnumerator\cf4\strike0\f1\{linkID=7330\}\cf0 
\par \cf3\f0\tab\strike TZMPipe\cf4\strike0\f1\{linkID=7340\}\cf0 
\par \cf2\f2\tab\cf3\strike\f0 TZMPipeList\cf4\strike0\f1\{linkID=7440\}\cf5 
\par \pard\tx180\tx620\tx1200 
\par \pard 
\par 
\par 
\par }
380
Scribble380
TZipMaster - Properties




Done



FALSE
80
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red255\green0\blue255;\red0\green128\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Properties
\par \pard\tx200\tx640\cf2\b0\{keepn\}\cf0 
\par     \cf3\{bmct \f1 Grn\f0 Bullet.bmp\}\cf0  \f1 Published\f0    \cf3  \{bmct BluBullet.bmp\}\cf0  Read-Only
\par \pard\tx180\tx620\tx1200\cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike A\f1 ctive\cf2\strike0\f0\{linkID=420\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike AddCompLevel\cf2\strike0\{linkID=430\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike AddFrom\cf2\strike0\{linkID=440\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike AddOptions\cf2\strike0\{linkID=470\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike AddStoreSuffixes\cf2\strike0\{linkID=500\}\cf5 
\par \cf3\f2\tab\tab\f3\{bmc \f2 Blu\f3 Bullet.bmp\}\cf2\f0\tab\cf4\strike Build\cf2\strike0\{linkID=530\}\cf5 
\par \f3\tab\f2\tab\cf3\f3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike Busy\cf2\strike0\{linkID=550\}\cf5 
\par \cf3\f2\tab\tab\tab\cf4\strike\f0 Cancel\cf2\strike0\{linkID=580\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike ConfirmErase\cf2\strike0\{linkID=610\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike Count\cf2\strike0\{linkID=630\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike DirEntry\cf2\strike0\{linkID=660\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike DirOnlyCnt\cf2\strike0\{linkID=690\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike DLL_Build\cf2\strike0\{linkID=710\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike DLL_Load\cf2\strike0\{linkID=730\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike DLL_Path\cf2\strike0\{linkID=760\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike DLL_Version\cf2\strike0\{linkID=790\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike DLLDirectory\cf2\strike0\{linkID=820\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike EncodeAs\cf2\strike0\{linkID=850\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike Encoding\cf2\strike0\{linkID=880\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike Encoding_CP\cf2\strike0\{linkID=910\}\cf5 
\par \f2\tab\f3\tab\cf3\f2\tab\cf4\strike\f0 ErrCode\cf2\strike0\{linkID=940\}\cf5 
\par \f2\tab\f3\tab\cf3\f2\tab\cf4\strike\f0 ErrMessage\cf2\strike0\{linkID=970\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike ExtAddStoreSuffixes\cf2\strike0\{linkID=1000\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike ExtrBaseDir\cf2\strike0\{linkID=1030\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike ExtrOptions\cf2\strike0\{linkID=1060\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike FSpecArgs\cf2\strike0\{linkID=1090\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike FSpecArgsExcl\cf2\strike0\{linkID=1130\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike FullErrCode\cf2\strike0\{linkID=1160\}\cf5 
\par \f2\tab\f3\tab\cf3\f2\tab\cf4\strike\f0 Handle\cf2\strike0\{linkID=1190\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike HowToDelete\cf2\strike0\{linkID=1200\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike IsSpanned\cf2\strike0\{linkID=1230\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike KeepFreeOnAllDisks\cf2\strike0\{linkID=1260\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike KeepFreeOnDisk1\cf2\strike0\{linkID=1290\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike Language\cf2\strike0\{linkID=1320\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike LanguageInfo\cf2\strike0\{linkID=1350\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike MaxVolumeSize\cf2\strike0\{linkID=1380\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike MaxVolumeSizeKb\cf2\strike0\{linkID=1410\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike MinFreeVolumeSize\cf2\strike0\{linkID=1440\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike NoSkipping\cf2\strike0\{linkID=1470\}\cf5 
\par \f2\tab\f3\tab\cf3\f2\tab\cf4\strike\f0 NotMainThread\cf2\strike0\{linkID=1500\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike Password\cf2\strike0\{linkID=1530\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike PasswordReqCount\cf2\strike0\{linkID=1570\}\cf5 
\par \cf3\f2\tab\tab\tab\cf4\strike\f0 P\f1 ipes\cf2\strike0\f0\{linkID=1600\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike RootDir\cf2\strike0\{linkID=1630\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike SFXCaption\cf2\strike0\{linkID=1660\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike SFXCommandLine\cf2\strike0\{linkID=1690\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike SFXDefaultDir\cf2\strike0\{linkID=1720\}\cf5 
\par \f2\tab\cf3\f3\{bmc \f2 Grn\f3 Bullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike SFXIcon\cf2\strike0\{linkID=1750\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike SFXMessage\cf2\strike0\{linkID=1780\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike SFXOffset\cf2\strike0\{linkID=1810\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike SFXOptions\cf2\strike0\{linkID=1840\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike SFXOverwriteMode\cf2\strike0\{linkID=1870\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike SFXPath\cf2\strike0\{linkID=1900\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike SFXRegFailPath\cf2\strike0\{linkID=1930\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike SpanOptions\cf2\strike0\{linkID=1960\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike SuccessCnt\cf2\strike0\{linkID=1990\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike TempDir\cf2\strike0\{linkID=2020\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike TotalSizeToProcess\cf2\strike0\{linkID=2050\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike Trace\cf2\strike0\{linkID=2080\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike Unattended\cf2\strike0\{linkID=2110\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike UseDirOnlyEntries\cf2\strike0\{linkID=2170\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike UseUTF8\cf2\strike0\{linkID=2200\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike Verbose\cf2\strike0\{linkID=2230\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike Version\cf2\strike0\{linkID=2260\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike WriteOptions\cf2\strike0\{linkID=2290\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike ZipComment\cf2\strike0\{linkID=2350\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike ZipEOC\cf2\strike0\{linkID=2380\}\cf5 
\par \cf3\f2\tab\f3\{bmc GrnBullet.bmp\}\f2\tab\cf2\f0\tab\cf4\strike ZipFileName\cf2\strike0\{linkID=2410\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike ZipFileSize\cf2\strike0\{linkID=2440\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike ZipSOC\cf2\strike0\{linkID=2470\}\cf5 
\par \f2\tab\f3\tab\cf3\{bmc BluBullet.bmp\}\cf2\f0\tab\cf4\strike ZipStream\cf2\strike0\{linkID=2500\}\cf5 
\par \pard 
\par 
\par 
\par }
390
Scribble390
TZipMaster - Methods




Done



FALSE
47
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green0\blue0;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Methods
\par \cf2\b0\{keepn\}
\par \cf3 
\par \pard\tx200\tx640\f1\tab\cf2\tab\cf4\strike Add\cf2\strike0\{linkID=2530\}\cf3 
\par \tab\cf2\tab\cf4\strike AddStreamToFile\cf2\strike0\{linkID=2560\}\cf3 
\par \tab\cf2\tab\cf4\strike AddStreamToStream\cf2\strike0\{linkID=2590\}\cf3 
\par \tab\cf2\tab\cf4\strike AddZippedFiles\cf2\strike0\{linkID=2620\}\cf3 
\par \tab\cf2\tab\cf4\strike AppendSlash\cf2\strike0\{linkID=2650\}\cf3 
\par \tab\cf2\tab\cf4\strike ChangeFileDetails\cf2\strike0\{linkID=2680\}\cf3 
\par \tab\cf2\tab\cf4\strike ConvertToSFX\cf2\strike0\{linkID=2720\}\cf3 
\par \tab\cf2\tab\cf4\strike ConvertToSpanSFX\cf2\strike0\{linkID=2750\}\cf3 
\par \tab\cf2\tab\cf4\strike ConvertToZIP\cf2\strike0\{linkID=2780\}\cf3 
\par \tab\cf2\tab\cf4\strike Copy_File\cf2\strike0\{linkID=2810\}\cf3 
\par \tab\cf2\tab\cf4\strike CopyZippedFiles\cf2\strike0\{linkID=2840\}\cf3 
\par \tab\cf2\tab\cf4\strike Deflate\cf2\strike0\{linkID=2870\}\cf3 
\par \tab\cf2\tab\cf4\strike Delete\cf2\strike0\{linkID=2900\}\cf3 
\par \tab\cf2\tab\cf4\strike EraseFile\cf2\strike0\{linkID=2930\}\cf3 
\par \tab\cf2\tab\cf4\strike Extract\cf2\strike0\{linkID=2960\}\cf3 
\par \tab\cf2\tab\cf4\strike ExtractFileToStream\cf2\strike0\{linkID=2990\}\cf3 
\par \tab\cf2\tab\cf4\strike ExtractStreamToStream\cf2\strike0\{linkID=3020\}\cf3 
\par \tab\cf2\tab\cf4\strike Find\cf2\strike0\{linkID=3050\}\cf3 
\par \tab\cf2\tab\cf4\strike ForEach\cf2\strike0\{linkID=3080\}\cf3 
\par \tab\cf2\tab\cf4\strike FullVersionString\cf2\strike0\{linkID=3110\}\cf3 
\par \tab\cf2\tab\cf4\strike GetAddPassword\cf2\strike0\{linkID=3120\}\cf3 
\par \tab\cf2\tab\cf4\strike GetEnumerator\cf2\strike0\{linkID=3150\}\cf3 
\par \tab\cf2\tab\cf4\strike GetExtrPassword\cf2\strike0\{linkID=3160\}\cf3 
\par \tab\cf2\tab\cf4\strike GetPassword\cf2\strike0\{linkID=3190\}\cf3 
\par \tab\cf2\tab\cf4\strike IndexOf\cf2\strike0\{linkID=3220\}\cf3 
\par \tab\cf2\tab\cf4\strike IsZipSFX\cf2\strike0\{linkID=3250\}\cf3 
\par \tab\cf2\tab\cf4\strike List\cf2\strike0\{linkID=3280\}\cf3 
\par \tab\cf2\tab\cf4\strike MakeTempFileName\cf2\strike0\{linkID=3310\}\cf3 
\par \tab\cf2\tab\cf4\strike QueryZip\cf2\strike0\{linkID=3320\}\cf3 
\par \tab\cf2\tab\cf4\strike ReadSpan\cf2\strike0\{linkID=3350\}\cf3 
\par \tab\cf2\tab\cf4\strike Rename\cf2\strike0\{linkID=3380\}\cf3 
\par \tab\cf2\tab\cf4\strike TheErrorCode\cf2\strike0\{linkID=3410\}\cf3 
\par \tab\cf2\tab\cf4\strike Undeflate\cf2\strike0\{linkID=3440\}\cf3 
\par \tab\cf2\tab\cf4\strike WriteSpan\cf2\strike0\{linkID=3470\}\cf3 
\par \tab\cf2\tab\cf4\strike ZipLoadStr\cf2\strike0\{linkID=3510\}\cf3 
\par \tab\cf2\tab\cf4\strike AbortDLL\cf2\strike0\{linkID=3540\}\cf3 
\par \tab\cf2\tab\cf4\strike Clear\cf2\strike0\{linkID=3570\}\cf3 
\par \tab\cf2\tab\cf4\strike ShowExceptionError\cf2\strike0\{linkID=3600\}\cf3 
\par \tab\cf2\tab\cf4\strike ShowZipFmtMessage\cf2\strike0\{linkID=3630\}\cf3 
\par \tab\cf2\tab\cf4\strike ShowZipMessage\cf2\strike0\{linkID=3660\}\cf3 
\par \cf0\f0 
\par }
400
Scribble400
TZipMaster - Events




Done



FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss\fcharset0 Arial;}{\f2\fswiss Arial;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red255\green0\blue255;\red0\green128\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Events
\par \pard\tx200\tx640\cf2\b0\{keepn\}\cf0 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnCheckTerminate\cf2\strike0\{linkID=3690\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnCopyZippedOverwrite\cf2\strike0\{linkID=3720\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnCRC32Error\cf2\strike0\{linkID=3750\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnDirUpdate\cf2\strike0\{linkID=5630\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnExtractOverwrite\cf2\strike0\{linkID=3810\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnFileComment\cf2\strike0\{linkID=3840\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnFileExtra\cf2\strike0\{linkID=3870\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnGetNextDisk\cf2\strike0\{linkID=3900\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnMessage\cf2\strike0\{linkID=3930\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnNewName\cf2\strike0\{linkID=3960\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnLoadStr\cf2\strike0\{linkID=4265\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnPasswordError\cf2\strike0\{linkID=3990\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnProgress\cf2\strike0\{linkID=4020\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnSetAddName\cf2\strike0\{linkID=4050\}\cf5\f0 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f0 OnSetCompLevel\cf2\strike0\{linkID=4110\}\cf5\f3 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnSetExtName\cf2\strike0\{linkID=4090\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnSkipped\cf2\strike0\{linkID=4140\}\cf5\f0 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f0 OnStateChange\cf2\strike0\{linkID=4170\}\cf5\f3 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnStatusDisk\cf2\strike0\{linkID=4200\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnStream\cf2\strike0\{linkID=4230\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnTick\cf2\strike0\{linkID=4260\}\cf5 
\par \cf3\f1\tab\f2\{bmc GrnBullet.bmp\}\f1\tab\cf4\strike\f3 OnZipDialog\cf2\strike0\{linkID=4320\}\cf5\f0 
\par \f3 
\par \cf0\f0 
\par }
410
Scribble410
About the TZipMaster component
TZipMaster component;


ZipMstr20:001505
Done



FALSE
12
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 About the TZipMaster component
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\strike TZipMaster reference\cf3\strike0\{linkID=%350\}\cf4\{keepn\}\cf0\b\fs22 
\par Purpose\b0\fs20 
\par <<< purpose of the TZipMaster component >>>
\par 
\par \b\fs22 Tasks
\par \b0\fs20 <<< how to use the TZipMaster component >>>
\par 
\par }
420
Scribble420
Active Property




Done



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}{\f4\fswiss\fcharset0 Arial;}{\f5\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Active Property\cf2\b0\f1\fs20 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\fs16 
\par \{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf3\b0\strike\fs20 TZipMaster\cf4\strike0\{linkID=350\}\cf2  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  A\f3 ctive\f2 : \f3 Boolean\f2 ;\f3  default True;\f2 
\par \f1 
\par \b\fs22 Description
\par \pard\b0\f4\fs20 If not True it prevents processing any changes to property changes\f5 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f1 
\par \pard\cf2 
\par 
\par }
430
Scribble430
AddCompLevel property
AddCompLevel;AddCompLevel,TZipMaster;TZipMaster,AddCompLevel;


zipmstr20:001510
Writing


TZipMaster_AddCompLevel;AddCompLevel_Property;AddCompLevel
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AddCompLevel property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf3\b0\strike\fs20 TZipMaster\cf4\strike0\{linkID=350\}\cf2  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  AddCompLevel: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f2\fs20 Compression Level.  
\par \f3\tab\f2 Range 0 - 9, where 9 is the tightest compression.  2 or 3 is a good trade-off if you need more speed. Level 0 will just store files without compression. 
\par \f3\tab\f2 I recommend leaving this at 9 in most cases.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
440
Scribble440
AddFrom property
AddFrom;AddFrom,TZipMaster;TZipMaster,AddFrom;


zipmstr20:001515
Writing


TZipMaster_AddFrom;AddFrom_Property;AddFrom
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AddFrom property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%450\}\tab\cf2\strike Example\cf3\strike0\{linkID=%460\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  AddFrom: TDateTime;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Add\f3 From \f2 can be used to set the \f3 Date for filtering files to add to a \f2 Zip\f3 .
\par \pard The date used when the \cf2\strike AddOption\cf3\strike0\{linkID=470\}\cf0  - AddFromDate is set, files dated on or after this date can be selected.\f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
450
Scribble450
AddFrom property - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddOptions\cf3\strike0\{linkID=470\}\cf0 
\par \cf2\strike FSpecArgs\cf3\strike0\{linkID=1090\}\cf0\f2\fs24 
\par \f0\fs20 
\par }
460
Scribble460
AddFrom property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 AddFrom property example
\par \cf0\b0 
\par 
\par }
470
Scribble470
AddOptions property
AddOptions;AddOptions,TZipMaster;TZipMaster,AddOptions;


zipmstr20:001520
Writing


TZipMaster_AddOptions;AddOptions_Property;AddOptions
FALSE
79
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss\fprq2\fcharset0 Arial;}{\f3\froman\fprq2\fcharset0 Times New Roman;}{\f4\fnil\fcharset0 Courier New;}{\f5\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AddOptions property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%480\}\tab\cf2\strike Example\cf3\strike0\{linkID=%490\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  AddOptions: \cf2\strike TZMAddOpts\cf3\strike0\{linkID=4490\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f2\fs20 This property is used to modify the default action of the \cf2\strike Add\strike0\{linkID=2530\}\cf0  method. If you want an option to be \b True\b0 , you need to add it to the Set.
\par 
\par \i Example: ZipMaster1.AddOptions:=[AddDirNames,AddRecurseDirs];
\par 
\par \cf3\i0\f1\{target=adddirnames\}\cf0\b\fs24 AddDirNames \b0\fs20 
\par \f2\tab If \b True\b0 , saves the pathname with each filename. Drive ID\f3 '\f2 s are never stored in Zip file directories. 
\par \tab If \cf2\strike AddEmptyDirs\cf3\strike0\{linkTarget=addemptydirs\} or \cf2\strike AddNTFS\cf3\strike0\{linkTarget=addntfs\}\cf0  is also true, empty directories are stored.  
\par \cf5\b\tab NOTE:\cf0\b0  the root directory name is never stored in a pathname; in other words, the first character of a pathname stored in the zip file's directory will never be a slash.
\par \f1 
\par \b\fs24 AddRecurseDirs \b0\fs20 
\par \f4\tab\f2 If True, subdirectories below EACH given file specification will be included in the Zip archive. Defaults to \b False\b0 .  
\par \tab\cf5\b NOTE:\cf0\b0  It is also possible to override this option by setting some special characters at the beginning of a file specification look for this at the \cf2\strike FSpecArgs\strike0\{linkID=1090\}\cf0  property. 
\par \tab\cf6\b WARNING:\cf0\b0  This is potentially dangerous if the user does this from the root directory. The hard drive may fill up with a huge Zip file!\f1 
\par 
\par \b\fs24 AddMove \b0\fs20 
\par \f2\tab If \b True\b0 , after adding to archive, delete original file. 
\par \tab  \cf6\b WARNING:\cf0\b0  This is potentially dangerous. Use with caution! 
\par \f1 
\par \cf3\{target=addFreshen\}\cf0\b\fs24 AddFreshen \b0\fs20 
\par \f4\tab\f2 If \b True\b0 , add newer files to archive (only for files that are already in the archive). \f1 
\par 
\par \cf3\{target=addUpdate\}\cf0\b\fs24 AddUpdate \b0\fs20 
\par \f4\tab\f2 If \b True\b0 , add newer files to archive (but, any file in an file specification that isn't already in the archive will also be added).\f1 
\par \cf5\b\f2\tab NOTE:\cf0\b0  Freshen and Update normally work on pre-existing archives. Freshen can only freshen files in an existing archive
\par \f1 
\par \b\f4\fs24 A\f1 ddHiddenFiles \b0\fs20 
\par \f4\tab\f2 If \b True\b0 , files with their Hidden or System attributes set will be included in the Add operation.\f1 
\par 
\par \b\fs24 AddArchiveOnly \b0\fs20 
\par \f2\tab If \b True\b0  then only files with their archive bit set will be added to the zip file.  
\par \tab\cf5\b NOTE:\cf0\b0  When combined with \cf2\strike AddFreshen\cf3\strike0\{linkTarget=addFreshen\} \cf0 or \cf2\strike AddUpdate\cf3\strike0\{linkTarget=addUpdate\} \cf0 both conditions must be met i.e. the files to add must be newer also.
\par \f1 
\par \b\fs24 AddResetArchive \b0\fs20 
\par \f2\tab Clears the archive bit after a successful Zip Add action. It\f3 '\f2 s not necessary to set AddArchiveOnly too.
\par \f1 
\par \cf3\{target=AddEncrypt\}\cf0\b\fs24 AddEncrypt \b0\fs20 
\par \f4\tab\f5 If \b True\b0 , files will encrypted (standard zip encryption)\f1 
\par 
\par \cf3\{\f4 t\f1 arget=addsepdirs\}\cf0\b\fs24 Add\f4 No\f1 SeparateDirs\f4  \cf6 Replaced by \ul AddEmptyDirs\cf3\ulnone\b0\f2\fs20\{linkTarget=adddirnames\}\cf6\b\f4\fs24  1.9.0.98\b0\f2\fs20 
\par \cf0\tab If \b FALSE\b0  , add separate entries to the zip archive that will hold the name of each directory even if empty (No data is stored for these entries).
\par \tab\cf5\b NOTE:\cf0\b0  - These directory entries are required to be able restore NTFS time details see \cf2\strike AddNTFS\cf3\strike0\{linkTarget=addntfs\}\cf0 . 
\par \cf5\b\tab NOTE:\cf0\b0  - To use this, you must also have \cf2\strike AddDirNames \cf3\strike0\{linkTarget=adddirnames\}\cf0 set. \cf5\b Also see\cf0\b0 : \cf2\strike UseDirOnlyEntries\cf3\strike0\{linkID=2170\}\cf0\f1 
\par 
\par \cf3\{target=addemptydirs\}\cf0\b\fs24 Add\f4 Empty\f1 Dirs\f4   \cf6 New 1.9.0.98\cf0\b0\f2\fs20 
\par \tab If \b TRUE\b0  , add separate entries to the zip archive that will hold the name of each directory even if empty (No data is stored for these entries).
\par \tab\cf5\b NOTE:\cf0\b0  - These directory entries are required to be able restore NTFS time details see \cf2\strike AddNTFS\cf3\strike0\{linkTarget=addntfs\}\cf0 . 
\par \cf5\b\tab NOTE:\cf0\b0  - To use this, you must also have \cf2\strike AddDirNames\cf3\strike0\{linkTarget=adddirnames\} \cf0 set. \cf5\b Also see\cf0\b0 : \cf2\strike UseDirOnlyEntries\cf3\strike0\{linkID=2170\}
\par \cf0\f1 
\par \b\fs24 AddVolume\b0\fs20 
\par \f4\tab\f5 If \b True\b0 , prefix the volume name\f1 
\par 
\par \b\fs24 AddFromDate\b0\fs20 
\par \f4\tab\f2 If \b True\b0 , only add files modified on or after \cf2\strike AddFrom\cf3\strike0\{linkID=440\}\cf0\f1 
\par 
\par \b\fs24 AddSafe\b0\fs20 
\par \f4\tab\f2 If \b True\b0 , forces using a temporary file before replacing the original.\f1 
\par 
\par \cf3\b\fs24\{target=addversion\}\cf0 AddVersion\b0\fs20 
\par \f4\tab\f2 If \b True\b0 , renames the existing file instead of deleting it\f1 
\par 
\par \cf3\{target=addntfs\}\cf0\b\fs24 AddNTFS\b0\fs20 
\par \f4\tab\f2 If \b True\b0 , saves the NTFS time stamps
\par \tab\cf5\b NOTE:\cf0\b0  - This sets \cf2\strike AddEmptyDirs\cf3\strike0\{linkTarget=addemptydirs\}\cf0 . 
\par 
\par \f1 
\par 
\par }
480
Scribble480
AddOptions property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of AddOptions property >>>
\par 
\par }
490
Scribble490
AddOptions property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 AddOptions property example
\par \cf0\b0 
\par 
\par }
500
Scribble500
AddStoreSuffixes property
AddStoreSuffixes;AddStoreSuffixes,TZipMaster;TZipMaster,AddStoreSuffixes;


ZipMstr20:001525
Writing


TZipMaster_AddStoreSuffixes;AddStoreSuffixes_Property;AddStoreSuffixes
FALSE
50
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AddStoreSuffixes property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%510\}\tab\cf2\strike Example\cf3\strike0\{linkID=%520\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  AddStoreSuffixes: \cf2\strike TZMAddStoreExts\cf3\strike0\{linkID=4530\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\sb35\b0\f2\fs20 AddStoreSuffixes is a Set of options to modify the default action of the \cf2\strike Add \cf3\strike0\{linkID=2530\}\cf0 method\f3 , files with these extensions will stored without compression\f2 .
\par \f3 This is because these types of files normally will not compress enough to warrant the time it takes to compress them.
\par 
\par \pard\sb35\tx300\tx1720\tab assGIF\tab\b True\b0 
\par \tab assPNG\tab\b True
\par \b0\tab assZ\tab\b True\b0 
\par \tab assZIP\tab\b True\b0 
\par \tab assZOO\tab\b True\b0 
\par \tab assARC\tab\b True\b0 
\par \tab assLZH\tab\b True\b0 
\par \tab assARJ\tab\b True\b0 
\par \tab assTAZ\tab\b True\b0 
\par \tab assTGZ\tab\b True\b0 
\par \tab assLHA\tab\b True\b0 
\par \tab assRAR\tab\b True\b0 
\par \tab assACE\tab\b True\b0 
\par \tab assCAB\tab\b True\b0 
\par \tab assGZ\tab\b True\b0  
\par \tab assGZIP\tab\b True\b0 
\par \tab assJAR\tab\b True\b0 
\par \tab assEXE\tab False
\par \tab assEXT\tab False
\par \tab assJPG\tab\b True\b0 
\par \tab assJPEG\tab\b True\b0 
\par \tab ass7Zp\tab\b True\b0 
\par \tab assMP3\tab\b True\b0 
\par \tab assWMV\tab\b True\b0 
\par \tab assWMA\tab\b True\b0 
\par \tab assDVR\tab\b True\b0 
\par \tab assAVI\tab\b True\b0 
\par \pard\sb35 
\par // default file extensions that are best 'stored'
\par const
\par   ZMDefAddStoreSuffixes = [assGIF..assJAR, assJPG..ass7Zp, assMP3..assAVI];\f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par \cf5\f4\fs24 Note \cf0\fs20 when any type of \cf2\strike encryption \cf3\strike0\{linkTarget=AddEncrypt\}\cf0 is used it is best to compress all files!\f0 
\par 
\par }
510
Scribble510
AddStoreSuffixes property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of AddStoreSuffixes property >>>
\par 
\par }
520
Scribble520
AddStoreSuffixes property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 AddStoreSuffixes property example
\par \cf0\b0 
\par 
\par }
530
Scribble530
Build property
Build;Build,TZipMaster;TZipMaster,Build;


ZipMstr20:001530
Done


TZipMaster_Build;Build_Property;Build
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Build property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%540\}\tab\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Build: Integer;
\par \f0 
\par \pard\sa195\tx355\b\fs22 Description\f2\fs24 
\par \lang1033\f3  \b0\fs20  returns the build number
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640      := (1.9 * 1000000) + (REVISION * 10000) + (PATCHLEVEL mod 1000);
\par \lang3081\f0 
\par Run-time only
\par Read-only
\par 
\par }
540
Scribble540
Build property - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\lang1033\strike\f1 Version\cf3\strike0\{linkID=2260\}\cf0 
\par \cf2\strike DLL_Build\cf3\strike0\{linkID=710\}\cf0 
\par \cf2\strike DLL_Version\cf3\strike0\{linkID=790\}\cf1\b\fs32 
\par \cf0\lang3081\b0\f0\fs20 
\par }
550
Scribble550
Busy property
Busy;Busy,TZipMaster;TZipMaster,Busy;


zipmstr20:001535
Writing


TZipMaster_Busy;Busy_Property;Busy
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Busy property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%560\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Busy: Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Used to check if an operation is still in progress.\f0 
\par Run-time only
\par Read-only
\par 
\par }
560
Scribble560
Busy property - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike OnStateChange\cf3\strike0\{linkID=4170\}\cf0 
\par 
\par }
580
Scribble580
Cancel property
Cancel;Cancel,TZipMaster;TZipMaster,Cancel;


zipmstr20:001540
Writing


TZipMaster_Cancel;Cancel_Property;Cancel
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Cancel property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf3\b0\strike\fs20 TZipMaster\cf4\strike0\{linkID=350\}\cf2  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Cancel: Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Set True to abort the current operation.
\par 
\par There may be a delay before the abort will happen and aborting an operation may result in a corrupt zip file.
\par \f0 
\par Run-time only
\par 
\par }
610
Scribble610
ConfirmErase property
ConfirmErase;ConfirmErase,TZipMaster;TZipMaster,ConfirmErase;


ZipMstr20:001545
Writing


TZipMaster_ConfirmErase;ConfirmErase_Property;ConfirmErase
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ConfirmErase property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%620\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ConfirmErase: Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 ConfirmErase\f3  can\f2  set ZipMaster to ask for confirmation before each disk will be erased when the \cf2\strike\f3 SpanOption  \cf3\strike0\{linkID=1960\}\cf2\strike spTryFormat \cf3\strike0\{linkID=5140\}\cf0 is set.
\par \pard\sa115\f2 If you set this to \b False\b0 , you will not be asked for confirmation before a disk is erased. If \b True\b0  and the answer is No, the disk in question will be used as it is. If there is not enough space available you will be prompted for a new one.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 Default value = \b True\b0\f0 
\par }
620
Scribble620
ConfirmErase property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ConfirmErase property >>>
\par 
\par }
630
Scribble630
Count property
Count;Count,TZipMaster;TZipMaster,Count;


ZipMstr20:001550
Writing


TZipMaster_Count;Count_Property;Count
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Count property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%640\}\tab\cf2\strike Example\cf3\strike0\{linkID=%650\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Count: Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Returns the number of \cf2\strike TZMDirEntries \cf3\strike0\{linkID=660\}\cf0 in the currently loaded zip file.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
640
Scribble640
Count property - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 DirOnlyCnt\cf3\strike0\{linkID=690\}\cf0\f0 
\par \cf2\strike\f1 UseDirOnlyEntries\cf3\strike0\{linkID=2170\}\cf0\f0 
\par }
650
Scribble650
Count property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Count property example
\par \cf0\b0 
\par 
\par }
660
Scribble660
DirEntry property
DirEntry;DirEntry,TZipMaster;TZipMaster,DirEntry;


zipmstr20:001555
Done


TZipMaster_DirEntry;DirEntry_Property;DirEntry
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DirEntry property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%670\}\tab\cf2\strike Example\cf3\strike0\{linkID=%680\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  DirEntry[idx: Integer]: \cf2\strike T\f2 ZM\f1 DirEntry\cf3\strike0\{linkID=6340\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Returns a read-only copy of the central directory entry
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
670
Scribble670
DirEntry property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of DirEntry property >>>
\par 
\par }
680
Scribble680
DirEntry property - Example




Done



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 DirEntry property example
\par 
\par \cf2\b0\f1\tab\i // read filenames
\par \tab for i:=0 to ZipMaster1.Count-1 do
\par \tab   Memo1.Lines.Add(ZipMaster1.DirEntry[i].Filename);\f0 
\par \cf0\i0 
\par 
\par }
690
Scribble690
DirOnlyCnt property
DirOnlyCnt;DirOnlyCnt,TZipMaster;TZipMaster,DirOnlyCnt;


ZipMstr20:001560
Writing


TZipMaster_DirOnlyCnt;DirOnlyCnt_Property;DirOnlyCnt
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DirOnlyCnt property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%700\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  DirOnlyCnt: Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Returns the number of hidden directory only entries in the current zip file.
\par 
\par Directory only entries are only hidden if \cf2\strike UseDirOnlyEntries \cf3\strike0\{linkID=2170\}\cf0 is False.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
700
Scribble700
DirOnlyCnt property - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 UseDirOnlyEntries \cf3\strike0\{linkID=2170\}
\par \cf2\strike List\cf3\strike0\{linkID=3280\}\cf0\f0 
\par 
\par }
710
Scribble710
DLL_Build property
DLL_Build;DLL_Build,TZipMaster;TZipMaster,DLL_Build;


ZipMstr20:001565
Writing


TZipMaster_DLL_Build;DLL_Build_Property;DLL_Build
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DLL_Build property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%720\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  DLL_Build: Integer;
\par \f0 
\par \pard\sa195\tx355\b\fs22 Description\f2\fs24 
\par \lang1033\b0\f3\fs20   Returns the build number of the loaded DLL.
\par      := ( (1.90 * 100000) + (REVISION * 1000) + PATCHLEVEL )\lang3081\b\f2\fs24 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\b0\f4\fs20 Note: if the dll is not already loaded the result will be 0.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
720
Scribble720
DLL_Build property - See also




Done



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\lang1033\strike\f1 DLLDirectory\cf3\strike0\{linkID=820\}\cf1\b\fs32 
\par \cf2\b0\strike\fs20 DLL loading and unloading\cf3\strike0\{linkID=200\}\cf4 
\par \cf2\strike DLL_Load\cf3\strike0\{linkID=730\}\cf4 
\par \cf2\strike DLL_Path\cf3\strike0\{linkID=760\}\cf4 
\par \cf2\strike DLL_Version\cf3\strike0\{linkID=790\}\cf4 
\par \cf2\strike DLL binding methods\cf3\strike0\{linkID=210\}\cf0\lang3081\f0 
\par 
\par 
\par }
730
Scribble730
DLL_Load property
DLL_Load;DLL_Load,TZipMaster;TZipMaster,DLL_Load;


ZipMstr20:001570
Writing


TZipMaster_DLL_Load;DLL_Load_Property;DLL_Load
FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Times New Roman;}{\f3\fswiss\fcharset0 Arial;}{\f4\fswiss Arial;}{\f5\fnil\fcharset0 Arial;}{\f6\fswiss\fprq2\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DLL_Load property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%740\}\tab\cf2\strike Example\cf3\strike0\{linkID=%750\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  DLL_Load: Boolean;
\par \f0 
\par \pard\b\fs22 Description\b0\f2\fs24 
\par \pard\sb115\sa115\tx355\lang1033\f3\fs20     Controls the loading/unloading of dynamically bound DLL\lang3081\b\f4\fs24 
\par \pard\cf4\lang1033\b0\f5\fs20      Set True to load the DLL or False to unload it.
\par      Read it to check if the DLL is actually loaded.
\par 
\par \cf5\b\fs24 Notes:\cf4\b0\fs20 
\par     Clearing it while an operation is running will unload when finished.
\par     Ignored if compiled with \cf2\lang2057\b\strike\f6 STATIC_LOAD_DELZIP_DLL\cf3\strike0\{linkID=210\}\cf0  \b0 defined.\cf4\lang1033\f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\lang3081 
\par }
740
Scribble740
DLL_Load property - See also




Done



FALSE
12
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\lang1033\strike\f1 DLLDirectory\cf3\strike0\{linkID=820\}\cf1\b\fs32 
\par \cf2\b0\strike\fs20 DLL loading and unloading\cf3\strike0\{linkID=200\}\cf4 
\par \cf2\strike DLL_Build\cf3\strike0\{linkID=710\}\cf4 
\par \cf2\strike DLL_Path\cf3\strike0\{linkID=760\}\cf4 
\par \cf2\strike DLL_Version\cf3\strike0\{linkID=790\}\cf4 
\par \cf2\strike DLL binding methods\cf3\strike0\{linkID=210\}\cf0\lang3081\f0 
\par 
\par }
750
Scribble750
DLL_Load property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 DLL_Load property example
\par \cf0\b0 
\par 
\par }
760
Scribble760
DLL_Path property
DLL_Path;DLL_Path,TZipMaster;TZipMaster,DLL_Path;


ZipMstr20:001575
Writing


TZipMaster_DLL_Path;DLL_Path_Property;DLL_Path
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DLL_Path property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%770\}\tab\cf2\strike Example\cf3\strike0\{linkID=%780\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  DLL_Path: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \lang1033\f2\fs24   \b0\fs20 Returns the path of currently loaded dll.
\par \lang3081\f0 
\par Run-time only
\par Read-only
\par 
\par }
770
Scribble770
DLL_Path property - See also




Done



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\lang1033\strike\f1 DLLDirectory\cf3\strike0\{linkID=820\}\cf1\b\fs32 
\par \cf2\b0\strike\fs20 DLL loading and unloading\cf3\strike0\{linkID=200\}\cf4 
\par \cf2\strike DLL_Build\cf3\strike0\{linkID=710\}\cf4 
\par \cf2\strike DLL_Load\cf3\strike0\{linkID=730\}\cf4 
\par \cf2\strike DLL_Version\cf3\strike0\{linkID=790\}\cf4 
\par \cf2\strike DLL binding methods\cf3\strike0\{linkID=210\}\cf0\lang3081\f0 
\par 
\par 
\par }
780
Scribble780
DLL_Path property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 DLL_Path property example
\par \cf0\b0 
\par 
\par }
790
Scribble790
DLL_Version property
DLL_Version;DLL_Version,TZipMaster;TZipMaster,DLL_Version;


ZipMstr20:001580
Writing


TZipMaster_DLL_Version;DLL_Version_Property;DLL_Version
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DLL_Version property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%800\}\tab\cf2\strike Example\cf3\strike0\{linkID=%810\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  DLL_Version: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\sa195\tx355\lang1033\b0\f2\fs20   Returns the version number of the loaded DLL int the format '1.9.r.bbbb'
\par    r = revision  (1..9)
\par    bbbb = build (0.9999)
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\lang3081\f0 Run-time only
\par Read-only
\par 
\par }
800
Scribble800
DLL_Version property - See also




Done



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\lang1033\strike\f1 DLLDirectory\cf3\strike0\{linkID=820\}\cf1\b\fs32 
\par \cf2\b0\strike\fs20 DLL loading and unloading\cf3\strike0\{linkID=200\}\cf4 
\par \cf2\strike DLL_Build\cf3\strike0\{linkID=710\}
\par \cf2\strike DLL_Load\cf3\strike0\{linkID=730\}\cf4 
\par \cf2\strike DLL_Path\cf3\strike0\{linkID=760\}\cf4 
\par \cf2\strike DLL binding methods\cf3\strike0\{linkID=210\}\cf0\lang3081\f0 
\par 
\par 
\par }
810
Scribble810
DLL_Version property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 DLL_Version property example
\par \cf0\b0 
\par 
\par }
820
Scribble820
DLLDirectory property
DLLDirectory,TZipMaster;TZipMaster,DLLDirectory;


ZipMstr20:001585
Writing


TZipMaster_DLLDirectory;DLLDirectory_Property;DLLDirectory
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\froman\fcharset0 Times New Roman;}{\f5\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DLLDirectory property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%830\}\tab\cf2\strike Example\cf3\strike0\{linkID=%840\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  DLLDirectory: \b String\b0 ;
\par \f0 
\par \pard\sa195\tx355\b\fs22 Description\f2\fs24 
\par \pard\tx355\b0\fs20 The directory used for \lang1033\f3 Del\lang3081\f2 Z\lang1033\f3 ip200\lang3081\f2 .DLL\lang1033\f3  when dynamically bound\lang3081\f2 . \lang1033\f3 Can\lang3081\f2  end in a slash. 
\par This is an optional property if used, it overrides the Windows search path for DLL\f4 '\f2 s.  
\par If you specify a directory here, but the DLL\f4  \f5 is\f2  not actually in that dir, then the standard Windows search path will be consulted, anyway.
\par \lang1033\f3 When dynamically binding is used (the default) a compressed version of the can be stored in the application resources; it is possible to force the use of this dll by specifying '><' (without the quotes).\lang3081\f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
830
Scribble830
DLLDirectory property - See also




Done



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\lang1033\strike\f1 DLL_Load\cf3\strike0\{linkID=730\}\cf1\b\fs32 
\par \cf2\b0\strike\fs20 DLL loading and unloading\cf3\strike0\{linkID=200\}\cf4 
\par \cf2\strike DLL_Build\cf3\strike0\{linkID=710\}\cf4 
\par \cf2\strike DLL_Path\cf3\strike0\{linkID=760\}\cf4 
\par \cf2\strike DLL_Version\cf3\strike0\{linkID=790\}\cf4 
\par \cf2\strike DLL binding methods\cf3\strike0\{linkID=210\}\cf0\lang3081\f0 
\par 
\par 
\par }
840
Scribble840
DLLDirectory property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 DLLDirectory property example
\par \cf0\b0 
\par 
\par }
850
Scribble850
EncodeAs property
EncodeAs;EncodeAs,TZipMaster;TZipMaster,EncodeAs;


ZipMstr20:001590
Writing


TZipMaster_EncodeAs;EncodeAs_Property;EncodeAs
FALSE
25
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 EncodeAs property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%860\}\tab\cf2\strike Example\cf3\strike0\{linkID=%870\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  EncodeAs: \cf2\strike TZMEncodingOpts\cf3\strike0\{linkID=4700\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20  Filename and comment character encoding
\par 
\par  zeoUPATH - convert to Ansi but have UTF8 proper name in data
\par  zeoUTF  - convert to UTF8
\par  zeoOEM  - convert to OEM
\par  zeoNone - store 'as is' (Ansi on Windows)
\par  'default' (zeoAuto) - [in order of preference]
\par \f2       is OEM - use zeoOEM\f0 
\par       is Ansi - use zeoNone
\par       can be converted to Ansi - use zeoUPath (unless comment also extended)
\par       use zeoUTF8
\par 
\par }
860
Scribble860
EncodeAs property - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Encoded\cf3\strike0\{linkID=6520\}\cf0 
\par \cf2\strike Encoding\cf3\strike0\{linkID=880\}\cf0\f0 
\par 
\par }
870
Scribble870
EncodeAs property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 EncodeAs property example
\par \cf0\b0 
\par 
\par }
880
Scribble880
Encoding property
Encoding;Encoding,TZipMaster;TZipMaster,Encoding;


zipmstr20:001595
Writing


TZipMaster_Encoding;Encoding_Property;Encoding
FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Encoding property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%890\}\tab\cf2\strike Example\cf3\strike0\{linkID=%900\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Encoding: \cf2\strike TZMEncodingOpts\cf3\strike0\{linkID=4700\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 the Encod\f2 ing\f0  values (writing) -
\par \f2\tab\f0 zeoUPATH 
\par \f2\tab\tab\f0 - convert to Ansi but have UTF8 proper name in data
\par \f2\tab\f0 zeoUTF 
\par \f2\tab\tab\f0 - convert to UTF8
\par \f2\tab\f0 zeoOEM 
\par \f2\tab\tab\f0 - convert to OEM
\par \f2\tab\f0 zeoNone 
\par \f2\tab\tab\f0 - store 'as is' (Ansi on Windows)
\par \f2\tab\f0 zeoAuto\f2  \f0 'default' 
\par \f2\tab\tab\f0  - [in order of preference]
\par \f2\tab\tab\f0 is Ansi - use zeoNone
\par \f2\tab\tab\f0 can be converted to Ansi - use zeoUPath (unless comment also extended)
\par \f2\tab\tab\f0 use zeoUTF8
\par 
\par 
\par }
890
Scribble890
Encoding property - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Encoded\cf3\strike0\{linkID=6520\}
\par \cf2\strike EncodeAs\cf3\strike0\{linkID=850\}\cf0\f0 
\par 
\par }
900
Scribble900
Encoding property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Encoding property example
\par \cf0\b0 
\par 
\par }
910
Scribble910
Encoding_CP property
Encoding_CP;Encoding_CP,TZipMaster;TZipMaster,Encoding_CP;


ZipMstr20:001600
Writing


TZipMaster_Encoding_CP;Encoding_CP_Property;Encoding_CP
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Encoding_CP property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%920\}\tab\cf2\strike Example\cf3\strike0\{linkID=%930\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Encoding_CP: Cardinal;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 
\par \f2  The Windows Ansi codepage to use for zeoNone encoding or decoding.
\par  
\par  Default 0 = Current Windows default.\f0 
\par }
920
Scribble920
Encoding_CP property - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Encoded\cf3\strike0\{linkID=6520\}\cf0 
\par \cf2\strike EncodeAs\cf3\strike0\{linkID=850\}\cf0 
\par \cf2\strike Encoding\cf3\strike0\{linkID=880\}\cf0\f0 
\par 
\par }
930
Scribble930
Encoding_CP property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Encoding_CP property example
\par \cf0\b0 
\par 
\par }
940
Scribble940
ErrCode property
ErrCode;ErrCode,TZipMaster;TZipMaster,ErrCode;


ZipMstr20:001605
Writing


TZipMaster_ErrCode;ErrCode_Property;ErrCode
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fnil\fcharset0 Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ErrCode property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%950\}\tab\cf2\strike Example\cf3\strike0\{linkID=%960\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ErrCode: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\sb35\b0\f2\fs20 ErrCode is the las\f3 t \cf2 error and\cf0\f2  \cf2\strike resource message ID number\strike0\{linkID=300\}\cf0  if it is from the component.
\par 
\par \pard\tx355 0 = No Error.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 See the \cf2\strike OnMessage\strike0\{linkID=\f4 393\f2 0\}\cf0  event.  
\par \f0 
\par Run-time only
\par 
\par }
950
Scribble950
ErrCode property - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 FullErrCode\cf3\strike0\{linkID=1160\}\cf0 
\par \cf2\strike ErrMessage\cf3\strike0\{linkID=970\}\f2\fs24 
\par \cf0\f0\fs20 
\par 
\par }
960
Scribble960
ErrCode property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ErrCode property example
\par \cf0\b0 
\par 
\par }
970
Scribble970
ErrMessage property
ErrMessage;ErrMessage,TZipMaster;TZipMaster,ErrMessage;


ZipMstr20:001610
Writing


TZipMaster_ErrMessage;ErrMessage_Property;ErrMessage
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ErrMessage property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%980\}\tab\cf2\strike Example\cf3\strike0\{linkID=%990\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ErrMessage: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\b0\f2\fs20 Holds a copy of the last message sent to your program by the DLL or the component. See the \cf2\strike OnMessage\strike0\{linkID=\f3 393\f2 0\}\strike  \cf0\strike0 event.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par Run-time only
\par 
\par 
\par }
980
Scribble980
ErrMessage property - See also




Done



FALSE
11
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ErrCode\cf3\strike0\{linkID=940\}\cf0 
\par \cf2\strike FullErrCode\cf3\strike0\{linkID=1160\} 
\par \cf2\strike LanguageInfo\cf3\strike0\{linkID=1350\}
\par \cf2\strike Language\cf3\strike0\{linkID=1320\}\f2\fs24 
\par \cf0\f0\fs20 
\par 
\par }
990
Scribble990
ErrMessage property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ErrMessage property example
\par \cf0\b0 
\par 
\par }
1000
Scribble1000
ExtAddStoreSuffixes property
ExtAddStoreSuffixes;ExtAddStoreSuffixes,TZipMaster;TZipMaster,ExtAddStoreSuffixes;


ZipMstr20:001615
Writing


TZipMaster_ExtAddStoreSuffixes;ExtAddStoreSuffixes_Property;ExtAddStoreSuffixes
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExtAddStoreSuffixes property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1010\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1020\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ExtAddStoreSuffixes: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\cf4\b0\f2\fs20   Allows excluding extra suffixes from being compressed.
\par    Sets assEXT in \cf2\strike AddStoreSuffixes\cf3\strike0\{linkID=500\}\cf4 
\par 
\par   ie ExtAddStoreSuffixes := '.tar,.gz'
\par \f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0 
\par }
1010
Scribble1010
ExtAddStoreSuffixes property - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddStoreSuffixes\cf3\strike0\{linkID=500\}\cf0\f0 
\par 
\par }
1020
Scribble1020
ExtAddStoreSuffixes property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ExtAddStoreSuffixes property example
\par \cf0\b0 
\par 
\par }
1030
Scribble1030
ExtrBaseDir property
ExtrBaseDir;ExtrBaseDir,TZipMaster;TZipMaster,ExtrBaseDir;


ZipMstr20:001620
Writing


TZipMaster_ExtrBaseDir;ExtrBaseDir_Property;ExtrBaseDir
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExtrBaseDir property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1040\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1050\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ExtrBaseDir: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 ExtraBaseDir is base directory used for extracting a Zip archive.
\par \f0 
\par \pard\tx355\f2 This base directory applies only to \f3 '\f2 Extract\f3 '\f2  operations.   
\par If you don't specify a value for this property, then the directory of the ZipFile itself will be the base directory for extractions.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
1040
Scribble1040
ExtrBaseDir property - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Extract\cf3\strike0\{linkID=2960\}\cf0\f0 
\par 
\par }
1050
Scribble1050
ExtrBaseDir property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ExtrBaseDir property example
\par \cf0\b0 
\par 
\par }
1060
Scribble1060
ExtrOptions property
ExtrOptions;ExtrOptions,TZipMaster;TZipMaster,ExtrOptions;


ZipMstr20:001625
Writing


TZipMaster_ExtrOptions;ExtrOptions_Property;ExtrOptions
FALSE
42
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fswiss\fprq2\fcharset0 Arial;}{\f4\froman\fprq2\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;\red255\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExtrOptions property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1070\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1080\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ExtrOptions: \cf2\strike TZMExtrOpts\cf3\strike0\{linkID=4740\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\tx840\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\b0\f2\fs20\tab\b\f0\fs24 ExtrDirNames
\par \b0\f3\fs20\tab\tab If \b True\b0 , extracts and recreates the relative pathname that may have been stored with each file. 
\par \tab\tab Empty directories stored in the archive (if any) will also be recreated.\b\f0\fs24 
\par \b0\fs20 
\par \f2\tab\b\f0\fs24 ExtrOverWrite
\par \b0\f3\fs20\tab\tab If \b True\b0 , overwrite pre-existing files during Extraction. 
\par \tab\tab\cf5\b NOTE:\cf0\b0  -ReadOnly files will be overwritten too.  
\par \tab\tab If a file will be overwritten also depends on the return value set in the \cf2\strike OnExtractOverwrite\strike0\{linkID=3810\}\cf0  event if present. 
\par \tab\tab\cf6\b IMPORTANT:\cf0\b0  Files opened by other applications (Windows a.o.) with exclusive rights are \b not\b0  overwritten. In this case an \cf2\strike OnSkipped\strike0\{linkID=4140\}\cf0  event will follow.\b\f0\fs24 
\par \b0\fs20 
\par \f2\tab\b\f0\fs24 ExtrFreshen
\par \b0\f3\fs20\tab\tab If \b True\b0 , extract newer files from archive (only for files that already exist).  Won't extract any file that isn't already present.\b\f0\fs24 
\par \b0\fs20 
\par \f2\tab\b\f0\fs24 ExtrUpdate
\par \b0\f3\fs20\tab\tab If \b True\b0 , extract files that don\f4 '\f3 t already exist and if ExtrOverWrite is also set to true, it will extract newer files from the archive.\b\f0\fs24 
\par \b0\fs20 
\par \f2\tab\b\f0\fs24 ExtrTest
\par \b0\f3\fs20\tab\tab If \b True\b0 , only test the archive to see if the files could be successfully extracted. 
\par \tab\tab Testing is done by extracting the files, but NOT writing the extracted data to the disk. 
\par \tab\tab Only the CRC code of the files is used to determine if they are stored correctly. 
\par \tab\tab To use this option, you will also need to define an Event handler for \cf2\strike OnMessage\strike0\{linkID=3930\}\cf0 .\b\f0\fs24 
\par \b0\fs20 
\par \f2\tab\b\f0\fs24 ExtrForceDirs
\par \b0\f3\fs20\tab\tab If \b True\b0 , forces the existence of the destination directory.\b\f0\fs24 
\par \b0\fs20 
\par \f2\tab\b\f0\fs24 ExtrNTFS
\par \b0\f3\fs20\tab\tab If \b True\b0 , restores file NTFS time stamps.\b\f0\fs24 
\par 
\par \b0\fs20 
\par }
1070
Scribble1070
ExtrOptions property - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Extract\cf3\strike0\{linkID=2960\}\cf0 
\par \cf2\strike NoSkipping\cf3\strike0\{linkID=1470\}\cf0\f0 
\par 
\par }
1080
Scribble1080
ExtrOptions property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ExtrOptions property example
\par \cf0\b0 
\par 
\par }
1090
Scribble1090
FSpecArgs property
FSpecArgs;FSpecArgs,TZipMaster;TZipMaster,FSpecArgs;


ZipMstr20:001630
Writing


TZipMaster_FSpecArgs;FSpecArgs_Property;FSpecArgs
FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 FSpecArgs property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1100\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1120\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  FSpecArgs:\f2  TStrings\f1 ;
\par \f0 
\par \b\fs22 Description
\par \pard\tx1735\b0\f3\fs20 Stringlist containing all the file specifications used as arguments for\f4  the following methods
\par \f3  \cf2\strike Add\strike0\{linkID=2530\}\cf0 
\par \f4  \cf2\strike AddZippedFiles\f3  \cf3\strike0\{linkID=2620\}\cf2\f4 
\par  \strike ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf2 
\par  \strike CopyZippedFiles\cf3\strike0\{linkID=2840\}\cf2 
\par  \strike Delete\cf3\strike0\{linkID=2900\}\cf0\f3 
\par \f4  \cf2\strike\f3 Extract\strike0\{linkID=2960\}\cf0   \cf2 
\par \f4  \strike ForEach\cf3\strike0\{linkID=3080\}\cf0\f3 
\par Every entry can contain MS-DOS wildcards\f4  in the name.ext only\f3 .
\par 
\par If you give filenames without pathnames, or if you use with \cf2\strike\f4 relative path\f3 names\cf3\strike0\{linkID=240\}\cf0 , the base drive/directory is assumed to be that of the Zipfile.
\par 
\par You can specify either the MS-DOS backslash path symbol, or the one normally used by PKZip ( the Unix path separator: / ). They are treated exactly the same.
\par \pard\fi-845\li845\sb115\tx845\f4 Add and Extract can also specify special \cf2\strike switches \cf3\strike0\{linkID=1110\}\cf0 to override some default options.
\par 
\par \cf5\fs24 Note:\cf0\fs20  Before D2009,  if \cf2\strike UseUTF8\cf3\strike0\{linkID=2200\}\cf0  is True the strings must be UTF8.\f3 
\par }
1100
Scribble1100
FSpecArgs property - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Switches\cf3\strike0\{linkID=1110\}\cf0 
\par \cf2\strike FSpecArgsExcl\cf3\strike0\{linkID=1130\}\cf0\f0 
\par 
\par }
1110
Scribble1110
Filespec Switches




Writing



FALSE
33
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red128\green128\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\tx840\tx2840\tx6820\cf1\b\fs32 Filespec Switches\cf2\b0\f1\fs20 
\par \cf0\f2 
\par   optional arguments between []
\par   MUST BE in specified order
\par   
\par Add
\par   [\b |\b0  \i OR\i0  \b >\b0 ]\b  filespec\b0  [\b\f3  /switch \b0 [\b  /switch \b0 ...]]\f2  [\b <password\b0 ]
\par \tab | \tab stops recursing folders\f3\tab\cf3 *add only\cf0\f2 
\par \tab >\tab forces recursion\f3\tab\cf3 *add only\cf0\f2 
\par \tab filespec\tab the required filename  
\par \f3\tab /switch\tab optional switch of form /char=value (note / must follow space)
\par \tab c\tab set compression (0..9)\tab\cf3 *add only\cf0 
\par \tab e\tab excludes _ override exclude specs\tab\cf3 *add only\cf0 
\par \tab\tab   if value begins with | they are additional to global excludes
\par \tab\tab   if value\f2  is empty (|x=) no excludes are used\f3 
\par \tab f:\tab folder _ use new add root or extract base
\par \tab s\tab force recursion\tab\cf3 *add only\cf0 
\par \tab s-\tab stops recursion\tab\cf3 *add only\cf0\f2 
\par \tab <password\tab encrypt with password [between < and end of line]
\par 
\par Exc\f3 ludes have the form \f2  filespec [| filespec [| filepec] ...]
\par   
\par It is also possible to override the AddRecurseDirs option of the \cf4\strike AddOptions\cf5\strike0\{linkID=1720\}\cf0  property by adding special characters at the beginning of any entry:
\par \b >\b0\tab will force recursion into subdirectories.
\par \b |\b0\tab will stop recursion into subdirectories.
\par \pard\sb115\tx840\tx2840\tx6820\cf3\b NOTE:\cf0\b0\tab This is \b only\b0  possible while Adding to a zip archive, When using Extract, Delete or CopyZippedFiles \b never\b0  use this!!!
\par Further it is possible to override the default password by appending the file specification with a \f4 '\f2 <\f4 '\f2  and then the new password or leave it empty to cancel an existing password temporarily as set in the \cf4\strike Password\strike0\{linkID=920\}\cf0  property.
\par \cf3\b NOTE:\cf0\b0\tab This is \b only\b0  possible while Adding to\f3  or Extracting from\f2  a zip archive, When using Delete or CopyZippedFiles \b never\b0  use this!!!
\par \pard\tx840\tx2840\tx6820 
\par \pard\cf2\f1 
\par }
1120
Scribble1120
FSpecArgs property - Example




Writing



FALSE
32
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\froman\fcharset0 Times New Roman;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue128;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 FSpecArgs property example
\par \cf0\b0 
\par \pard\tx845\f1 
\par \pard\fi-395\li565\tx565\cf2\b Add entries directly to the FSpecArgs property:
\par \pard\tx1125\cf0\b0\i\tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 C:\\AUTOEXEC.BAT\f2 '\f1  \i );
\par \tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 *.EXE\f2 '\i\f1  );
\par \tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 C:\\WINDOWS\\*.INI\f2 '\f1  \i );
\par \pard\fi-395\li565\tx565\cf2\b\i0 And some special cases which can be used when adding to zip archive:
\par \pard\fi-1125\li1125\tx1125\tx7505\cf0\b0\i\tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 >C:\\Windows\\System\\*.Dll\f2 '\i\f1  );\tab\cf3\i0 // Force recusion\i 
\par \cf0\f3\tab\f1 ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 C:\\Windows\\System\\*.Dll\f3  /R\f2 '\f1  \i );\tab\cf3\i0 // Force recusion\cf0\i 
\par \tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 |C:\\Windows\\*.exe\f2 '\f1  \i );\tab\cf3\i0 // Stop recursion\cf0\i 
\par \tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 C:\\Windows\\*.exe\f3  /r-\f2 '\i\f1  );\tab\cf3\i0 // Stop recursion\cf0\i 
\par \tab ZipMaster1.FSpecArgs.Add( \i0\f2 '\f1 C:\\Bat\\Test.txt\f3 <\f1 MyNewPassword\f2 '\f1  \i );\tab\cf3\i0 // A new password\cf0\i 
\par \tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 C:\\Bat\\Test.txt\f3 <'\f1  \i );\tab\cf3\i0 // Cancel existing password\cf0\i 
\par \tab ZipMaster1.FSpecArgs.Add( \i0\f2 '\f1 C:\\Bat\\Test.txt\f3  /c:2\f2 '\f1  \i );\tab\cf3\i0 // S\f3 et compression level to 2\cf0\i\f1 
\par \tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 C:\\Bat\\Test.txt\f3  /C:0\f2 '\i\f1 );\tab\cf3\i0 // S\f3 et compression level to 0 (store)\cf0\i\f1 
\par \tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 C:\\\f3 *.* /E:*\\.dll\\*\f2 '\i\f1  );\tab\cf3\i0 // \f3 only exclude *\\.dll\\*\cf0\i\f1 
\par \tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f1 C:\\\f3 *.* /E:|*\\asc*\f2 '\f1  \i );\tab\cf3\i0 // \f3 also exclude  *\\asc*\cf0\i\f1 
\par \tab ZipMaster1.FSpecArgs.Add( \i0\f2 '\f3 >*.* /E:|*.dll|*.dcu /f:D:/Sources\f2 '\f1  \i );\tab 
\par \f3\tab     \cf3\i0\f1 // \f3 recursive all files from new root except *.dll or *.dcu or anything in FSpecArgsExcl\cf0\i\f1 
\par \tab ZipMaster1.FSpecArgs.Add(\i0  \f2 '\f3 * /E:*.dll|*.dcu /f:D:\\Sources /s- >MyNewPassword\f2 '\i\f1  );\tab 
\par \f3\tab     \cf3\i0\f1 // \f3 nonrecursive files from new root except *.dll or *.dcu, encrypted with new password\cf0\i\f1 
\par \pard\tx1125\tx7505\i0 
\par \pard\fi-395\li565\tx565\cf2\b Take the filespecs from a StringList, just assign them all over to ZipMaster1.
\par \pard\tx1125\cf0\b0\i\tab ZipMaster1.FSpecArgs.Assign( StringList1 );
\par \i0 
\par \pard\fi-395\li565\tx565\cf2\b Take the filespecs from a ListBox, just assign them all over to ZipMaster1.
\par \pard\tx1125\cf0\b0\i\tab ZipMaster1.FSpecArgs.Assign( ListBox1.Items );
\par \pard\i0\f0 
\par }
1130
Scribble1130
FSpecArgsExcl property
FSpecArgsExcl;FSpecArgsExcl,TZipMaster;TZipMaster,FSpecArgsExcl;


ZipMstr20:001635
Writing


TZipMaster_FSpecArgsExcl;FSpecArgsExcl_Property;FSpecArgsExcl
FALSE
31
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 FSpecArgsExcl property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1140\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1150\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  FSpecArgsExcl: TStrings;
\par \f0 
\par \b\fs22 Description
\par \pard\tx1735\b0\f2\fs20 Stringlist containing all the file specifications\f3  to be excluded\f2  for\f3  the following methods
\par \f2  \cf2\strike Add\strike0\{linkID=2530\}\cf0 
\par \f3  \cf2\strike AddZippedFiles\f2  \cf3\strike0\{linkID=2620\}\cf0 
\par \f3  \cf2\strike\f2 Delete\strike0\{linkID=2900\}\f3 
\par  \strike ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf2 
\par  \strike CopyZippedFiles\cf3\strike0\{linkID=2840\}\cf2 
\par  \strike Delete\cf3\strike0\{linkID=2900\}\cf2\f2 
\par \f3  \strike ForEach\cf3\strike0\{linkID=3080\}\cf0\f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 Every entry can contain MS-DOS wildcards\f3 .
\par 
\par \pard\f2 You can specify either the MS-DOS backslash path symbol, or the Unix path separator: /). They are treated exactly the same.
\par When using full path names in FSpecArgs you must also use full path names in FSpecArgsExcl or appropriate wildcards like \f4 '\f2 *.tmp\f4 '\f2 , \f4 '\f2 *test.*\f4 '\f2 , this is important when the Add option AddRecurseDirs is set.
\par 
\par \f3 Multiple filespecs can be specified by delimiting with |
\par \pard\fi-845\li845\sb115\tx845 
\par \cf5\fs24 Note\cf0\fs20 : Before D2009,  if \cf2\strike UseUTF8\cf3\strike0\{linkID=2200\}\cf0  is True the strings must be UTF8.\f2 
\par \pard 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1140
Scribble1140
FSpecArgsExcl property - See also




Done



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \pard\tx1735\cf2\strike\f1 FSpecArgs\cf3\strike0\{linkID=1090\}\cf0\f2 
\par \cf2\strike\f3 Add\strike0\{linkID=2530\}\cf0 
\par \cf2\strike\f2 AddZippedFiles\f3  \cf3\strike0\{linkID=2620\}\cf0 
\par \cf2\strike Delete\strike0\{linkID=2900\}\f2 
\par \strike ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf2 
\par \strike CopyZippedFiles\cf3\strike0\{linkID=2840\}\cf2 
\par \strike Delete\cf3\strike0\{linkID=2900\}\cf2\f3 
\par \strike\f2 ForEach\cf3\strike0\{linkID=3080\}\cf0\f3 
\par \pard\f0 
\par 
\par }
1150
Scribble1150
FSpecArgsExcl property - Example




Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue128;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 FSpecArgsExcl property example
\par \cf0\b0 
\par \f1 
\par \pard\fi-395\li565\tx565\cf2\b Add entries directly to the FSpecArgsExcl property:
\par \pard\tx1125\cf0\b0\i\tab ZipMaster1.FspecArgsExcl.Add( \f2 '\f1 C:\\Builder\\BIN\\Builder.EXE\f2 '\f1  );
\par \tab ZipMaster1.FspecArgsExcl.Add( \f2 '\f1 C:\\WINDOWS\\*.TMP\f2 '\f1  );
\par \tab ZipMaster1.FspecArgsExcl.Add( \f2 '\f1 *.TMP\f2 '\f1  );
\par \i0 
\par \pard\fi-395\li565\tx565\cf2\b Take the filespecs from a StringList, just assign them all over to ZipMaster1.
\par \pard\tx1125\cf0\b0\i\tab ZipMaster1.FspecArgsExcl.Assign( StringList1 );
\par \i0 
\par \pard\fi-395\li565\tx565\cf2\b Take the filespecs from a ListBox, just assign them all over to ZipMaster1.
\par \pard\tx1125\cf0\b0\i\tab ZipMaster1.FspecArgsExcl.Assign( ListBox1.Items );
\par 
\par \pard\i0\f0 
\par }
1160
Scribble1160
FullErrCode property
FullErrCode;FullErrCode,TZipMaster;TZipMaster,FullErrCode;


ZipMstr20:001640
Writing


TZipMaster_FullErrCode;FullErrCode_Property;FullErrCode
FALSE
33
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 FullErrCode property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1170\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  FullErrCode: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\b0\f2\fs20 Holds a copy of the last error code sent to your program by the DLL.
\par 
\par \pard\sa55\tx355 The difference between ErrCode and FullErrCode is:
\par \pard\fi-275\li275\sa55\tx275 1) FullErrCode is only used by \f3 the\f2  Dll while \cf2\strike ErrCode\cf3\strike0\{linkID=940\}\cf0  is also used for errors originating from the component.
\par \pard\fi-275\li275\tx275 2) There is extra information available in FullErrCode which ErrCode does not have.
\par \tab To interpret this extra information you will have to perform a logical AND as follows.
\par \tab FullErrCode \b and\b0  $00FF gives the same value as ErrCode.
\par 
\par    \f3 Dll error\f2  code format
\par 0FFF FFFF  LLLL LLLL   LLLL MTTT  EEEE EEEE  \{31 .. 0\}
\par F = file number (7 bits)
\par L = line number (12 bits)
\par M = message instead of error string
\par T = type  (3 bits)
\par E = error/string code (8 bits)
\par \pard\tx275 
\par If this property is 0 then there is no error.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 Run-time only
\par 
\par 
\par }
1170
Scribble1170
FullErrCode property - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ErrCode\cf3\strike0\{linkID=940\}
\par \cf2\strike\f2 ErrMessage\cf3\strike0\{linkID=970\}\cf0\f0 
\par \cf2\strike\f3 Errors and Mssages\cf3\strike0\{linkID=300\}\cf0\f0 
\par }
1190
Scribble1190
Handle property
Handle;Handle,TZipMaster;TZipMaster,Handle;


ZipMstr20:001645
Writing


TZipMaster_Handle;Handle_Property;Handle
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Handle property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf3\b0\strike\fs20 TZipMaster\cf4\strike0\{linkID=350\}\cf2  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Handle: HWND;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f2\fs20 Used for some DLL generated dialogs.
\par Default it is set to the form where TZipMaster is created.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 Run-time only
\par 
\par }
1200
Scribble1200
HowToDelete property
HowToDelete;HowToDelete,TZipMaster;TZipMaster,HowToDelete;


ZipMstr20:001650
Writing


TZipMaster_HowToDelete;HowToDelete_Property;HowToDelete
FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 HowToDelete property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf3\b0\strike\fs20 TZipMaster\cf4\strike0\{linkID=350\}\cf2  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  HowToDelete: \cf3\strike TZMDeleteOpts\cf4\strike0\{linkID=4630\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\sb35\b0\f2\fs20 HowToDelete specifies on how \cf3\strike EraseFile\strike0\{linkID=5590\}\cf0  is going to delete a file.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par \pard\f2 HowToDelete can take one of the following values:
\par \pard\sb115\sa115\tx1985\b\fs24 Value\tab Meaning
\par \pard\tx1985\b0\fs20 htdFinal\tab Perform a DeleteFile.
\par htdAllowUndo\tab Move the old file into the recycle bin (The default).
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
1230
Scribble1230
IsSpanned property
IsSpanned;IsSpanned,TZipMaster;TZipMaster,IsSpanned;


ZipMstr20:001655
Writing


TZipMaster_IsSpanned;IsSpanned_Property;IsSpanned
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 IsSpanned property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1240\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1250\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  IsSpanned: Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 IsSpanned returns True if the opened archive is a spanned archive, even if the \f3 '\f2 set\f3 '\f2  consists of only one disk.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
1240
Scribble1240
IsSpanned property - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ReadSpan\cf3\strike0\{linkID=3350\}\cf0 
\par \cf2\strike WriteSpan \cf3\strike0\{linkID=3470\}\cf0\f2\fs24 
\par \f0\fs20 
\par 
\par }
1250
Scribble1250
IsSpanned property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 IsSpanned property example
\par \cf0\b0 
\par 
\par }
1260
Scribble1260
KeepFreeOnAllDisks property
KeepFreeOnAllDisks;KeepFreeOnAllDisks,TZipMaster;TZipMaster,KeepFreeOnAllDisks;


ZipMstr20:001660
Writing


TZipMaster_KeepFreeOnAllDisks;KeepFreeOnAllDisks_Property;KeepFreeOnAllDisks
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 KeepFreeOnAllDisks property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1270\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1280\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  KeepFreeOnAllDisks: Cardinal;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f2\fs20 Holds a value in bytes and will use this value to keep bytes free on \f3 all\f2  disk\f3 s\f2  of a set. 
\par For example to leave \f3 slack \f2 space \f3 CDs\f2 .
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1270
Scribble1270
KeepFreeOnAllDisks property - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 KeepFreeOnDisk1\cf3\strike0\{linkID=1290\}\cf0\f0 
\par 
\par }
1280
Scribble1280
KeepFreeOnAllDisks property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 KeepFreeOnAllDisks property example
\par \cf0\b0 
\par 
\par }
1290
Scribble1290
KeepFreeOnDisk1 property
KeepFreeOnDisk1;KeepFreeOnDisk1,TZipMaster;TZipMaster,KeepFreeOnDisk1;


ZipMstr20:001665
Writing


TZipMaster_KeepFreeOnDisk1;KeepFreeOnDisk1_Property;KeepFreeOnDisk1
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 KeepFreeOnDisk1 property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1300\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1310\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  KeepFreeOnDisk1: Cardinal;
\par \f0 
\par \b\fs22 Description
\par \pard\sb35\b0\f2\fs20 KeepFreeOnDisk1 is used to keep some space available on the first disk of a spanned set.
\par 
\par \pard Holds a value in bytes and will use this value to keep bytes free on the first disk of a set of disks. 
\par For example to leave space for a setup program.
\par By default this is set to zero.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
1300
Scribble1300
KeepFreeOnDisk1 property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 KeepFreeOnAllDisks\cf3\strike0\{linkID=1260\}\cf0\f0 
\par 
\par }
1310
Scribble1310
KeepFreeOnDisk1 property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 KeepFreeOnDisk1 property example
\par \cf0\b0 
\par 
\par }
1320
Scribble1320
Language property
Language,TZipMaster;TZipMaster,Language;


ZipMstr20:001670
Writing


TZipMaster_Language;Language_Property;Language
FALSE
30
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green0\blue128;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Language property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1330\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1340\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Language: \b string\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Controls the language strings used for ErrMessage.\f0 
\par 
\par \pard\cf4\lang1033\f2   Sets and returns the current language.
\par 
\par \b usage\b0 
\par    Language := 'FR';\tab // set to French
\par    Language := '$040C';   // set to French
\par    Language := '1036';     // set to French
\par    Language := '12';        // set to any language it can find that has French as 'primary' language
\par 
\par    Language := '*';          // set to current user language
\par    Language := '1024';    // set to current user language
\par 
\par \cf5\b Notes\cf4\b0 
\par    if a language cannot be found the default 'US: English' will be used.
\par    Languages other than the default US require the resources to be linked to the application\f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\lang3081 
\par }
1330
Scribble1330
Language property - See also




Done



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\lang1033\strike\f1 LanguageInfo\cf3\strike0\{linkID=1350\}\cf0 
\par \cf2\strike ErrMessage\cf3\strike0\{linkID=970\}\cf0 
\par \cf2\strike OnMessage\cf3\strike0\{linkID=3930\}\cf0\f0 
\par \cf2\strike\f1 Resources\cf3\strike0\{linkID=120\}\cf0\lang3081\f0 
\par \cf2\strike\f1 ZipLoadStr\cf3\strike0\{linkID=3510\}\cf0\f0 
\par \cf2\strike\f1 OnLoadStr\cf3\strike0\{linkID=4265\}\cf0\f0 
\par \cf4\lang1033 
\par \cf0\lang3081 
\par 
\par }
1340
Scribble1340
Language property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Language property example
\par \cf0\b0 
\par 
\par }
1350
Scribble1350
LanguageInfo property
LanguageInfo,TZipMaster;TZipMaster,LanguageInfo;


ZipMstr20:001675
Writing


TZipMaster_LanguageInfo;LanguageInfo_Property;LanguageInfo
FALSE
27
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 LanguageInfo property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1360\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1370\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  LanguageInfo[Idx: Integer;info: Cardinal]: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \lang1033\b0\f2\fs20 returns information about a language
\par 
\par \pard\sa195  \b  Index values\b0 
\par       < 0\tab\tab - default US
\par          0\tab\tab - current language
\par       > 0\tab\tab - Available language number (requesting beyond available number of languages returns '><')
\par 
\par  \b  Info values\b0 
\par       $FFFFFFFF - returns language identifier of language
\par       0\tab\tab - returns name of language (i.e. 'SP'  = Spanish)
\par       Windows LOCALE_ prefixed values returns that information from Windows.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\lang3081\f0 Run-time only
\par Read-only
\par 
\par }
1360
Scribble1360
LanguageInfo property - See also




Done



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\lang1033\strike\f1 Language\cf3\strike0\{linkID=1320\}\cf0 
\par \cf2\strike ErrMessage\cf3\strike0\{linkID=970\}\cf0 
\par \cf2\strike OnMessage\cf3\strike0\{linkID=3930\}\cf0\f0 
\par \cf2\strike\f1 Resources\cf3\strike0\{linkID=120\}\cf0\lang3081\f0 
\par \cf2\strike\f1 ZipLoadStr\cf3\strike0\{linkID=3510\}\cf0\f0 
\par \cf2\strike\f1 OnLoadStr\cf3\strike0\{linkID=4265\}\cf0\f0 
\par \cf4\lang1033 
\par \cf0\lang3081 
\par 
\par }
1370
Scribble1370
LanguageInfo property - Example




Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 LanguageInfo property example
\par \cf0\b0 
\par \pard\sa195\lang1033\f1 
\par \b Example\b0  to list all available languages
\par    for i := 0 to 50 do
\par    begin
\par       s := LanguageInfo[ i, LOCALE_SENGLANGUAGE ];
\par       if s = '><' then
\par          break;
\par       Memo1.Lines.Add( s );
\par    end;\cf2\f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\lang3081 
\par \pard 
\par }
1380
Scribble1380
MaxVolumeSize property
MaxVolumeSize;MaxVolumeSize,TZipMaster;TZipMaster,MaxVolumeSize;


ZipMstr20:001680
Writing


TZipMaster_MaxVolumeSize;MaxVolumeSize_Property;MaxVolumeSize
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 MaxVolumeSize property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1390\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1400\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  MaxVolumeSize: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\sb35\b0\f2\fs20 MaxVolumeSize is used to set the maximum size of any archive part of a spanned set.
\par 
\par \pard This property holds a value in bytes to set the maximum size of the destination zipfile on a disk.
\par \pard\sa115 This will be most useful if the destination disk is a harddisk.
\par \pard The default is 0 which means the maximum size of a disk will be used. It is possible to use different sized disks interchangeable (ie. 720Kb or 1,44Mb)  (As long as they fit in the same drive.)
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1390
Scribble1390
MaxVolumeSize property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of MaxVolumeSize property >>>
\par 
\par }
1400
Scribble1400
MaxVolumeSize property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 MaxVolumeSize property example
\par \cf0\b0 
\par 
\par }
1410
Scribble1410
MaxVolumeSizeKb property
MaxVolumeSizeKb;MaxVolumeSizeKb,TZipMaster;TZipMaster,MaxVolumeSizeKb;


ZipMstr20:001685
Writing


TZipMaster_MaxVolumeSizeKb;MaxVolumeSizeKb_Property;MaxVolumeSizeKb
FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 MaxVolumeSizeKb property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1420\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1430\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  MaxVolumeSizeKb: Integer;
\par \f0 
\par \b\fs22 Description
\par 
\par \pard\sb35\b0\f2\fs20 MaxVolumeSize is used to set the maximum size of any archive part of a spanned set.
\par 
\par \pard This property holds a value in \f3 KBytes\f2  to set the maximum size of the destination zipfile on a disk.
\par \pard\sa115 This will be most useful if the destination disk is a harddisk.
\par \pard The default is 0 which means the maximum size of a disk will be used. It is possible to use different sized disks interchangeable (ie. 720Kb or 1,44Mb)  (As long as they fit in the same drive.)
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
1420
Scribble1420
MaxVolumeSizeKb property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of MaxVolumeSizeKb property >>>
\par 
\par }
1430
Scribble1430
MaxVolumeSizeKb property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 MaxVolumeSizeKb property example
\par \cf0\b0 
\par 
\par }
1440
Scribble1440
MinFreeVolumeSize property
MinFreeVolumeSize;MinFreeVolumeSize,TZipMaster;TZipMaster,MinFreeVolumeSize;


ZipMstr20:001690
Writing


TZipMaster_MinFreeVolumeSize;MinFreeVolumeSize_Property;MinFreeVolumeSize
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 MinFreeVolumeSize property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1450\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1460\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  MinFreeVolumeSize: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f2\fs20 This contains a value in bytes of the minimum available size a disk must have before it will be used to write (a part of) the archive.
\par \pard\sa115 The default is 65536 bytes.
\par \pard\fi-845\li845\tx845\cf5\b NOTE:\cf0\b0\tab It is not very practical to set this to a smaller value because you will need a lot of disks or get many files.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1450
Scribble1450
MinFreeVolumeSize property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of MinFreeVolumeSize property >>>
\par 
\par }
1460
Scribble1460
MinFreeVolumeSize property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 MinFreeVolumeSize property example
\par \cf0\b0 
\par 
\par }
1470
Scribble1470
NoSkipping property
NoSkipping;NoSkipping,TZipMaster;TZipMaster,NoSkipping;


ZipMstr20:001695
Writing


TZipMaster_NoSkipping;NoSkipping_Property;NoSkipping
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 NoSkipping property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1480\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1490\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  NoSkipping: \cf2\strike\f2 TZMSkipAborts\cf3\strike0\{linkID=5120\}\cf0\f1 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Sets the default action for various failures to process the requested file. \b\f0\fs22 
\par \b0\f3\fs20 If True, that \cf2\strike skip type\cf3\strike0\{linkID=5100\}\cf0  will fail unless \cf2\strike OnSkipped \cf3\strike0\{linkID=6640\}\cf0 handler sets Err >= 0.\f0 
\par 
\par }
1480
Scribble1480
NoSkipping property - See also




Done



FALSE
11
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\b0 
\par \cf2\strike\f1 TZMSkipAborts\cf3\strike0\{linkID=5120\}\cf0 
\par \cf2\strike TZMSkippedEvents\cf3\strike0\{linkID=5080\}\cf0 .\f0 
\par \pard\cf2\strike\f1 OnSkipped\cf3\strike0\{linkID=6640\}\cf0\f0 
\par 
\par 
\par 
\par }
1490
Scribble1490
NoSkipping property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 NoSkipping property example
\par \cf0\b0 
\par 
\par }
1500
Scribble1500
NotMainThread property
NotMainThread;NotMainThread,TZipMaster;TZipMaster,NotMainThread;


ZipMstr20:001700
Writing


TZipMaster_NotMainThread;NotMainThread_Property;NotMainThread
FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 NotMainThread property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1510\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1520\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  NotMainThread: Boolean;
\par \f0 
\par \b\fs22 Description
\par \pard\cf4\b0\f2\fs20    When true it does not do some things that should not be done when running on separate thread eg. does not call ProcessMessages.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\f0 
\par }
1510
Scribble1510
NotMainThread property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of NotMainThread property >>>
\par 
\par }
1520
Scribble1520
NotMainThread property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 NotMainThread property example
\par \cf0\b0 
\par 
\par }
1530
Scribble1530
Password property
Password;Password,TZipMaster;TZipMaster,Password;


ZipMstr20:001720
Writing


TZipMaster_Password;Password_Property;Password
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Password property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1540\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1550\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Password: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\b0\f2\fs20 The user's encryption/decryption password. Setting a password to this property is not needed if you want to let the DLL prompt the user for a password. This is only used if you want to prompt the user yourself.
\par \pard\sb115\tx355 It is possible to override this default Password by appending the file specification with an \f3 '<'\f2  and then the new Password or leave it empty to cancel an existing password. Look for this at the \cf2\strike FSpecArgs\strike0\{linkID=1090\}\cf0  property.
\par \pard\tx355 
\par \pard\fi-1415\li1415\tx1415\cf5\b WARNING:\tab\cf0\b0 If you set the password in the Object Inspector, and you never change the password property at runtime, then your users will never be able to use any other password.  If you leave it blank, the DLL\f4 '\f2 s will prompt users each time a password is needed.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1540
Scribble1540
Password property - See also




Done



FALSE
11
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Password Notes\cf3\strike0\{linkID=1560\}\cf0 
\par \cf2\strike GetAddPassword\cf3\strike0\{linkID=3120\}\cf0 
\par \cf2\strike GetExtrPassword\cf3\strike0\{linkID=3160\}\cf0 
\par \cf2\strike GetPassword\cf3\strike0\{linkID=3190\}\cf0 
\par \cf2\strike OnZipDialog\cf3\strike0\{linkID=4320\}\cf4\lang1033\f0 
\par \cf0\lang3081 
\par }
1550
Scribble1550
Password property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Password property example
\par \cf0\b0 
\par 
\par }
1560
Scribble1560
Password notes




Done



FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green0\blue0;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Password notes\cf2\{keepn\}\cf3\b0\f1\fs20 
\par \cf0\f2 The "\cf4\strike GetAddPassword\strike0\{linkID=3120\}\cf0  " and "\cf4\strike  GetExtrPassword\strike0\{linkID=3160\}\cf0  " methods are optional. 
\par You have 4 different ways of getting a user's password:
\par 
\par \pard\fi-275\li565\sa195\tx565\b 1.\b0\tab Call the "GetAddPassword" and/or the "GetExtrPassword" methods, just before add or extract.
\par \pard\fi-275\li565\tx565\b 2.\b0\tab Use your own code to set the "Password" property.  It's your choice how you obtain the password.
\par \pard\fi-275\li845\tx845 -\tab This is useful if the password comes from a file or table.
\par \pard\fi-275\li845\sa195\tx845 -\tab It's also good for letting you enforce constrains on the password - you can require it to be over 6 chars, require it to have at least one special char, etc.  Of course, you'd only want to enforce constraints on "Add" operations.  A word of caution: many users don't like password constraints, so give them the option to turn them off.
\par \pard\fi-275\li565\sa195\tx565\b 3.\b0\tab Don't set one at all, and let the component prompt the user. It's easy, and it works.
\par \b 4.\b0\tab Set the password in the \cf4\strike OnPasswordError\strike0\{linkID=3990\}\cf0  event. This is also the most flexible way of doing it.
\par \pard\tx565 Passwords can not be longer than 80 characters. A zero-length password is the same as no password at all.
\par 
\par To "zero out" the password, set it's property to an empty string. If it is zeroed out, but the \cf4\strike AddEncrypt\strike0\{linkID=470\}\cf0  option is set, then the user will be prompted for a new password by the component. So, if you don't want a password used, make sure you turn off "AddEncrypt", and you zero-out the password. 
\par 
\par If you set a password for an Extract, but it is incorrect, then the \cf4\strike OnPasswordError\strike0\{linkID=3990\}\cf0  event will be triggered \cf4\strike PasswordReqCount\strike0\{linkID=1570\}\cf0  times if you still do not supply a correct password Extraction will not take place.
\par 
\par To Force the DLL to AVOID decrypting an encrypted file, you must set the password property to an empty string and set to \cf4\strike PasswordReqCount\strike0\{linkID=1570\}\cf0  to zero.  If Adding, make sure AddEncrypt is NOT set.
\par 
\par \pard\cf3\f1 
\par 
\par }
1570
Scribble1570
PasswordReqCount property
PasswordReqCount;PasswordReqCount,TZipMaster;TZipMaster,PasswordReqCount;


ZipMstr20:001725
Writing


TZipMaster_PasswordReqCount;PasswordReqCount_Property;PasswordReqCount
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 PasswordReqCount property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1580\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1590\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  PasswordReqCount: Longword;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\b0\f2\fs20 Password Request Count is used for setting the total number of times a password is requested per file in the ziparchive (by calling \cf2\strike OnPasswordError\strike0\{linkID=3990\}\cf0 ). The maximum is 15 and the minimum = 0.
\par Setting it to 0 will make sure that a password is never requested, effectively skipping all encrypted files.
\par 
\par \pard\fi-845\li845\tx845\cf5\b NOTE:\cf0\b0\tab Setting this property while extracting is in progress does not have any effect until the next call to Extract.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1580
Scribble1580
PasswordReqCount property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of PasswordReqCount property >>>
\par 
\par }
1590
Scribble1590
PasswordReqCount property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 PasswordReqCount property example
\par \cf0\b0 
\par 
\par }
1600
Scribble1600
Pipes Property
TZipMaster,Pipes;TZMPipe;



Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}{\f4\fswiss\fcharset0 Arial;}{\f5\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Pipes property\f1 
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7350\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7370\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  \f3 Pipes: \cf2\strike TZMPipeList\cf3\strike0\{linkID=7340\}\cf0\f2 ;
\par \f1 
\par \b\fs22 Description
\par \pard\tx355\b0\f4\fs20 A list that allows \cf2\strike Add\cf3\strike0\{linkID=2530\}\cf0  or \cf2\strike Extract\cf3\strike0\{linkID=2960\}\cf0  to use streams instead of files\f5 .
\par 
\par \pard\cf4\f1 
\par 
\par 
\par }
1610
Scribble1610
Pipes property - See also




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Pipes property - See also\cf2\b0\f1\fs20 
\par 
\par 
\par }
1620
Scribble1620
Pipes property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Pipes property - Example\cf2\b0\f1\fs20 
\par 
\par 
\par }
1630
Scribble1630
RootDir property
RootDir;RootDir,TZipMaster;TZipMaster,RootDir;


ZipMstr20:001730
Writing


TZipMaster_RootDir;RootDir_Property;RootDir
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red0\green0\blue128;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 RootDir property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1640\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1650\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  RootDir: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\b0\f2\fs20 The RootDir property determines where zipping will start for any filenames or wildcard entries \f3 selected \f2 in the \cf2\strike FSpecArgs\strike0\{linkID=1090\}\cf0  property\f3 ,
\par  except those excluded by the \cf2\strike FSpecArgExcl\cf3\strike0\{linkID=1130\}\cf0  property.\f2 
\par 
\par \cf5\b 
\par }
1640
Scribble1640
RootDir property - See also




Done



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Add\cf3\strike0\{linkID=2530\}\cf0 
\par \cf2\strike FSpecArgs\cf3\strike0\{linkID=1090\}\cf0 
\par \cf2\strike FSpecArgsExcl\cf3\strike0\{linkID=1130\}\cf0 
\par \cf2\strike AddOptions\cf3\strike0\{linkID=470\}\cf0\f0 
\par \cf2\strike\f1 Using Relative Paths\cf3\strike0\{linkID=240\}\cf0\f0 
\par }
1650
Scribble1650
RootDir property - Example




Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue128;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 RootDir property example
\par 
\par 
\par \pard\fi-395\li565\tx565\cf2\f1 Example:
\par \pard\tx1125\cf0\b0\i\tab ZipMaster1.RootDir := \f2 '\f1 D:\\Program Files\\Start\f2 '\f1 ;
\par \tab ZipMaster1.FSpecArgs.Add( \f2 '\f1 Dir1\\MyFile.html\f2 '\f1  );
\par \tab ZipMaster1.FSpecArgs.Add( \f2 '\f1 *.h\f2 '\f1  );
\par \tab ZipMaster1.Add;
\par \i0 
\par This will add the file \f2 "\f1 D:\\Program Files\\Start\\Dir1\\MyFile.htm\f2 "\f1  as \f2 "\f1 Dir1\\MyFile.html\f2 "\f1 
\par and all files \f2 "\f1 D:\\Program Files\\Start\\*.h\f2 "\f1  as \f2 "\f1 *.h\f2 "\f1  to the ziparchive.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par \pard 
\par 
\par }
1660
Scribble1660
SFXCaption property
SFXCaption;SFXCaption,TZipMaster;TZipMaster,SFXCaption;


ZipMstr20:001735
Writing


TZipMaster_SFXCaption;SFXCaption_Property;SFXCaption
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}{\f5\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SFXCaption property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1670\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  SFXCaption: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f3\fs20 When you start a executable which was buil\f4 t\f3  by \cf2\strike Convert\f4 To\f3 SFX\cf3\strike0\{linkID=2720\}\cf0  then this will be the caption of the dialog box you will see.
\par If you don\f5 '\f3 t set it yourself "Self-extracting Archive" will be used as default.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1670
Scribble1670
SFXCaption property - See also




Done



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par 
\par }
1680
Scribble1680
SFXCaption property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SFXCaption property example
\par \cf0\b0 
\par 
\par }
1690
Scribble1690
SFXCommandLine property
SFXCommandLine;SFXCommandLine,TZipMaster;TZipMaster,SFXCommandLine;


ZipMstr20:001740
Writing


TZipMaster_SFXCommandLine;SFXCommandLine_Property;SFXCommandLine
FALSE
30
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SFXCommandLine property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1700\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1710\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  SFXCommandLine: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f3\fs20 This is the command line that will be executed immediately after extracting the files.  
\par Typically used to view the readme file, but can do anything.
\par There is a predefined symbol that can be used in the command line to tell you which target directory was actually used.
\par 
\par \b Special symbols:
\par |\b0     (Vertical bar) is the command / argument separator.
\par \b ><\b0  Is the actual extraction directory selected by user.
\par 
\par \i Example:\i0  notepad.exe\b |><\b0 Readme.txt
\par This will run notepad to show "Readme.txt" in the actual extraction dir.
\par 
\par You can also install .inf scripts, even with support for different sections depending on the 
\par operating system
\par "><setup.inf" will run the [DefaultInstall] section of "EXTRACTPATH\\setup.inf".
\par "><setup.inf|.ntx86" will run the [DefaultInstall] section if the User's OS is Win95/98,
\par but [DefaultInstall.ntx86] section if it's Windows NT.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1700
Scribble1700
SFXCommandLine property - See also




Done



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par 
\par 
\par }
1710
Scribble1710
SFXCommandLine property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SFXCommandLine property example
\par \cf0\b0 
\par 
\par }
1720
Scribble1720
SFXDefaultDir property
SFXDefaultDir;SFXDefaultDir,TZipMaster;TZipMaster,SFXDefaultDir;


ZipMstr20:001745
Writing


TZipMaster_SFXDefaultDir;SFXDefaultDir_Property;SFXDefaultDir
FALSE
35
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red0\green0\blue128;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SFXDefaultDir property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1730\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1740\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  SFXDefaultDir: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\sb35\b0\f3\fs20 SFXDefaultDir is the directory that will be used by the executable when extracting.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par \pard\f3 The directory can be changed in the SFX dialog box before extracting.
\par If you don't specify this, the user's current directory will be the default.
\par 
\par If you specify the special symbol \b ><\b0  here, then the user\f4 '\f3 s temporary directory will be the default extraction directory.  A Windows API call will be used at runtime to determine the name of this directory.
\par 
\par The path can also be read from the user's registry by typing a registry key.
\par \pard\fi-395\li565\sb235\sa115\tx565\cf5\b Some examples:
\par \pard\li275\tx565\cf0\b0\i HKEY_LOCAL_MACHINE\\
\par HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ProgramFilesDir
\par HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\CommonFilesDir
\par HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WallPaperDir
\par HKEY_CURRENT_USER\\Software\\Borland\\C++Builder\\3.0\\
\par HKEY_CURRENT_USER\\Software\\Borland\\Delphi\\4.0\\
\par HKCU\\Software\\
\par HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\\
\par \i0 HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\\
\par \pard\tx565 
\par Also creating subfolders in these registry-read paths is possible by entering a pipe ( ' | ' ) 
\par and then the name of the new sub directory after the registry key.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1730
Scribble1730
SFXDefaultDir property - See also




Done



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par 
\par 
\par }
1740
Scribble1740
SFXDefaultDir property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SFXDefaultDir property example
\par \cf0\b0 
\par 
\par }
1750
Scribble1750
SFXIcon property
SFXIcon;SFXIcon,TZipMaster;TZipMaster,SFXIcon;


ZipMstr20:001750
Writing


TZipMaster_SFXIcon;SFXIcon_Property;SFXIcon
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}{\f5\froman Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SFXIcon property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1760\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1770\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  SFXIcon: TIcon;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f3\fs20 Used to set a custom icon for the Self Extracting Archive. This is the picture you see in the explorer and on your desktop.
\par 
\par Because the original size of the icon in \cf2\strike\f4 SFX stub\cf3\strike0\{linkID=1925\}\cf0\f3  has a fixed size, the size and number of colors used must be exactly the same this means: 32 x 32 pixels and 16 colors.
\par If you supply an icon which is not exactly the same you will get \cf2\strike error\cf3\strike0\{linkID=940\}\cf0  \cf2\strike\f1 CZ_NoCopyIcon\cf3\strike0\{linkID=300\}\cf0\f3  when using the \cf2\strike Convert\f4 To\f3 SFX\strike0\{linkID=2720\}\cf0  method.
\par 
\par \pard\sb35 This property is automatically set when converting (back) from .Exe to .Zip.\f5 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1760
Scribble1760
SFXIcon property - See also




Done



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par 
\par 
\par }
1770
Scribble1770
SFXIcon property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SFXIcon property example
\par \cf0\b0 
\par 
\par }
1780
Scribble1780
SFXMessage property
SFXMessage;SFXMessage,TZipMaster;TZipMaster,SFXMessage;


ZipMstr20:001755
Writing


TZipMaster_SFXMessage;SFXMessage_Property;SFXMessage
FALSE
24
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SFXMessage property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1790\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1800\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  SFXMessage: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f3\fs20 You can specify a message that will be displayed before the main extraction dialog pops up.
\par 
\par You can also specify the type of the message box:
\par \pard\fi-1415\li1415\tx135\tx1415 -\tab\b Standard\b0 :\tab The messagebox shows an 'OK' button. The User cannot cancel starting the SFX application.
\par -\tab\b Information\b0 :\tab The messagebox shows the buttons 'OK' and 'Cancel'. if the User presses 'Cancel', sfx will stop.
\par \tab Set the first \f4 two \f3 character\f4 s\f3  of the string to: \f4 1|\f3 .
\par -\tab\b Confirmation\b0 :\tab The messagebox shows the buttons 'Yes' and 'No'. if the User presses 'No', sfx will stop.
\par \tab Set the first \f4 two \f3 character\f4 s\f3  of the string to:  \f4 2|\f3 .
\par 
\par \cf5\fs24 NOTE:\cf0\fs20  When the first character of the string = '|' then all following chars will be included in the message. 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1790
Scribble1790
SFXMessage property - See also




Done



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par 
\par 
\par }
1800
Scribble1800
SFXMessage property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SFXMessage property example
\par \cf0\b0 
\par 
\par }
1810
Scribble1810
SFXOffset property
SFXOffset;SFXOffset,TZipMaster;TZipMaster,SFXOffset;


ZipMstr20:001760
Writing


TZipMaster_SFXOffset;SFXOffset_Property;SFXOffset
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SFXOffset property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1820\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1830\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  SFXOffset: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\sb35\b0\f2\fs20 SFXOffset is the size of the self-extracting code at the beginning of the zipfile.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par \pard\f2 SFXOffset is valid after a zip file's contents have been read successfully (which happens when you assign something to \cf2\strike ZipFileName\strike0\{linkID=2410\}\cf0 ). When using non SFX zip files or when using diskspanning this will be zero.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par Run-time only
\par Read-only
\par 
\par }
1820
Scribble1820
SFXOffset property - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of SFXOffset property >>>
\par 
\par }
1830
Scribble1830
SFXOffset property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SFXOffset property example
\par \cf0\b0 
\par 
\par }
1840
Scribble1840
SFXOptions property
SFXOptions;SFXOptions,TZipMaster;TZipMaster,SFXOptions;


ZipMstr20:001765
Writing


TZipMaster_SFXOptions;SFXOptions_Property;SFXOptions
FALSE
32
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SFXOptions property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1850\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1860\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  SFXOptions: \cf2\strike TSFXOpts\cf3\strike0\{linkID=4390\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 SFXOptions is a Set of options used to modify the default actions of the Convert\f4 To\f3 SFX method.
\par 
\par \pard If you want an option to be \b True\b0  or \b False\b0 , you need to add or subtract it to/from the Set.
\par 
\par \pard\tx560\tx3240\f4\tab\b\f3 soAskCmdLine\f4\tab\b0\f3 allow user to prevent execution of the command line
\par \f4\tab\b\f3 soAskFiles\f4\tab\b0\f3 allow user to prevent certain files from extraction
\par \f4\tab\b\f3 soHideOverWriteBox\f4\tab\b0\f3 do not allow user to choose the overwrite mode
\par \f4\tab\b\f3 soAutoRun\f4\tab\b0\f3 start extraction + evtl. command line automatically
\par \f4\tab\tab\f3 only if sfx filename starts with "!" or is "setup.exe"
\par \f4\tab\b\f3 soNoSuccessMsg\b0\f4\tab\f3 don't show success message after extraction
\par \f4\tab\b\f3 soExpandVariables\b0\f4\tab\f3 expand environment variables in path/cmd line...
\par \f4\tab\b\f3 soInitiallyHideFiles\b0\f4\tab\f3 dont show file listview on startup
\par \f4\tab\b\f3 soForceHideFiles\b0\f4\tab\f3 do not allow user to show files list
\par \f4\tab\tab\f3  (no effect if shfInitiallyShowFiles is set)
\par \f4\tab\b\f3 soCheckAutoRunFileName\b0\f4\tab\f3 can only autorun if !... or setup.exe
\par \f4\tab\b\f3 soCanBeCancelled\b0\f4\tab\f3 extraction can be cancelled
\par \f4\tab\b\f3 soCreateEmptyDirs\b0\f4\tab\f3 recreate empty directories
\par \f4\tab\b\f3 soSuccessAlways\b0\f4\tab\f3 always give success message even if soAutoRun or soNoSuccessMsg
\par \f0 
\par }
1850
Scribble1850
SFXOptions property - See also




Done



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par 
\par 
\par }
1860
Scribble1860
SFXOptions property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SFXOptions property example
\par \cf0\b0 
\par 
\par }
1870
Scribble1870
SFXOverwriteMode property
SFXOverwriteMode;SFXOverwriteMode,TZipMaster;TZipMaster,SFXOverwriteMode;


ZipMstr20:001770
Writing


TZipMaster_SFXOverwriteMode;SFXOverwriteMode_Property;SFXOverwriteMode
FALSE
24
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SFXOverwriteMode property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1880\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1890\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  SFXOverwriteMode: \cf2\strike TZMOvrOpts\cf3\strike0\{linkID=4900\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 SFXOverWriteMode sets the the action for what the SFX program is supposed to do if it finds files that already exist.
\par 
\par \pard If the option \f4 '\cf2\strike\f3 SFXHideOverWriteBox\cf3\strike0\{linkID=4410\}\cf0\f4 '\f3  is \b True\b0 , then this option will be used during extraction.
\par 
\par \b SFXOverWriteMode\b0  can take one of the following values:
\par \pard\sb115\sa115\tx1985\b\fs24 Value\tab Meaning
\par \pard\tx1985\b0\fs20 OvrConfirm\tab Ask user when each file is found  (The default).
\par OvrAlways\tab Always overwrite existing files.
\par OvrNever\tab Never overwrite - skip those files.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1880
Scribble1880
SFXOverwriteMode property - See also




Done



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par 
\par 
\par }
1890
Scribble1890
SFXOverwriteMode property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SFXOverwriteMode property example
\par \cf0\b0 
\par 
\par }
1900
Scribble1900
SFXPath property
SFXPath;SFXPath,TZipMaster;TZipMaster,SFXPath;


ZipMstr20:001775
Writing


TZipMaster_SFXPath;SFXPath_Property;SFXPath
FALSE
33
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}{\f5\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SFXPath property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1910\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1920\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  SFXPath: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 SFXPath is the path where \f4 the \cf2\strike binary stub file\cf3\strike0\{linkID=1925\}\cf0\f3  is stored.
\par 
\par \pard Must include the whole pathname, filename, and extension.
\par 
\par This is used by the \cf2\strike Convert\f4 To\f3 SFX\strike0\{linkID=2720\}\cf0  method\f4  or writing/rewriting an SFX file\f3 . 
\par If you don\f5 '\f3 t give the location yourself ZipMaster will try to locate the file as following:
\par \pard\fi-565\li565\tx565\tab\b 1.\b0  Location given by the SFXPath property. (This could be another name too.)
\par \tab\b 2.\b0  The current directory.
\par \tab\b 3.\b0  The application directory. (location of current .EXE file.)
\par \tab\b 4.\b0  The Windows System directory. (where DLL\f5 '\f3 s go.)
\par \tab\b 5.\b0  The Windows directory. (where DLL\f5 '\f3 s go.)
\par \tab\b 6.\b0  Location given by the DLLDirectory property.
\par \tab\b\f4 7\f3 .\b0  \f4 In the application's resources\f3 .
\par \pard\tx565 
\par When searching, the default \f4 stub \f3 name is used, except when given an explicit name by means of this property.
\par 
\par \f4 Set SFXPath to '><' specify that the stub in the resources must be used.\f3 
\par 
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
1910
Scribble1910
SFXPath property - See also




Done



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par 
\par }
1920
Scribble1920
SFXPath property - Example




Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SFXPath property example
\par \cf2\{keepn\}\cf1 
\par 
\par \cf0\b0\f1   \i zip.SFXPath :=\i0  'c:\\myapp\\zmsfu19.bin';\tab\tab\tab // must use the specified file\cf1\b\f0 
\par \cf0\b0\f1   \i zip.SFXPath :=\i0  'zmsfu19.bin';\tab\tab\tab\tab // search for the specified stub in default folders\cf1\b\f0 
\par \cf0\b0\f1   \i zip.SFXPath :=\i0  '.\\bin\\zmsfu19.bin';\tab\tab\tab // search for specified stub in the subfolder 'bin\\'\cf1\b\f0 
\par \cf0\b0\f1  \i  zip.SFXPath :=\i0  '.\\bin\\';\tab\tab\tab\tab\tab // search for default stub in the subfolder 'bin\\'\cf1\b\f0 
\par \cf0\b0\f1   \i zip.SFXPath :=\i0  '><';\tab\tab\tab\tab\tab // use the stub in the attached resources\cf1\b\f0 
\par 
\par 
\par 
\par \cf0\b0 
\par 
\par }
1925
Scribble1925
SFX Stub




Writing



FALSE
26
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 SFX Stub
\par \cf2\{keepn\}\cf1 
\par \cf0\b0\fs20 
\par The SFX stub is the executable self extractor that does the actual extraction of the zip files.
\par 
\par The source code for the raw stub is distributed in the SFX\\  folder.
\par Depending upon which compiler version is used the stub will either be -
\par    D2009 or later - ZMSFXU19.exe, Unicode that will only run on Windows XP or later.
\par    D2007 or earlier - ZMSFX19.exe, Ansi that will run on most versions of Windows but may have trouble with file names with non-US characters.
\par 
\par These raw stubs have to be prepared using the tool ZipResMaker.exe which appends compressed tables of the required strings and messages in various languages.
\par ZipResMaker.exe also prepares the stubs as resources that can be attached to the application so that external files are not required.
\par 
\par Prepared stubs are distributed in the \\Res  folder as -
\par   ZMSFXU19.bin (Unicode).
\par   ZMSFX19.bin (Ansi).
\par   ZMRes19_sfxu.res (Unicode) **.
\par   ZMRes19_sfx.res (Ansi) **.
\par 
\par ** \ul\b either\ulnone\b0  ZMRes19_sfxu.res \b or\b0  ZMRes19_sfx.res may be linked but \ul\b not both\ulnone\b0  at the same time!
\par   \cf3\f1 
\par 
\par 
\par }
1927
Scribble1927
SFX Stub - See also




Done



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\fs20 See also\cf1\b\f1 
\par \cf0\b0 
\par \cf2\strike\f0 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f1 
\par \cf4 
\par 
\par 
\par }
1930
Scribble1930
SFXRegFailPath property
SFXRegFailPath;SFXRegFailPath,TZipMaster;TZipMaster,SFXRegFailPath;


ZipMstr20:001780
Writing


TZipMaster_SFXRegFailPath;SFXRegFailPath_Property;SFXRegFailPath
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SFXRegFailPath property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1940\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1950\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  SFXRegFailPath: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 contains the default extraction path, if reading path from registry failed\f1 .\f0 
\par \f1 W\f0 ill be expanded if it contains % signs and \cf2\strike soExpandEnvStrings\cf3\strike0\{linkID=1840\}\cf0  is set\f1 .\f0 
\par \f1 I\f0 f set to "><", then use  temp-dir
\par }
1940
Scribble1940
SFXRegFailPath property - See also




Done



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par 
\par 
\par }
1950
Scribble1950
SFXRegFailPath property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SFXRegFailPath property example
\par \cf0\b0 
\par 
\par }
1960
Scribble1960
SpanOptions property
SpanOptions;SpanOptions,TZipMaster;TZipMaster,SpanOptions;


ZipMstr20:001785
Writing


TZipMaster_SpanOptions;SpanOptions_Property;SpanOptions
FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\fswiss\fprq2\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SpanOptions property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%1970\}\tab\cf2\strike Example\cf3\strike0\{linkID=%1980\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  SpanOptions: \cf2\strike TZMSpanOpts\cf3\strike0\{linkID=5140\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f2\fs20 This property is used to modify the default action of\f3  the Disk spanning operations\f2 .
\par 
\par If you want an option to be \b True\b0 , you need to add it to the Set.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f3 The options (spNoVolumeName, spCompatName) may need to be the same for writing and reading zips
\par 
\par \pard\tx560\tx2880\b\tab spNoVolumeName\b0\tab\f4 If \b True\b0  then will use numbered files on removable drives \f3 
\par \b\tab spCompatName\b0\tab\f4 If \b True \b0 then uses names of the form name.zip + name.z01 ... \f3 
\par \b\tab spWipeFiles\b0\tab\f4 If \b True\b0 , removes the files from the removable drive before writing.    
\par \tab\tab  \cf5\b WARNING\cf0\b0 : Deletes all files and Directories \f3 
\par \b\tab spTryFormat\b0\tab\f4 If \b True \b0 and spWipeFiles, try to Format removable disk.    
\par \tab\tab\cf5\b WARNING\cf0\b0 : Wipes all files - non-recoverable\f3 
\par \b\tab spAnyTime\b0\tab\f4 If \b True\b0 , it ignores time stamps when locating last part of set\b  
\par \tab\tab  \b0 (normally time stamps must match)\f3 
\par \b\tab spExactName\tab\b0\f4 If \b True\b0 , open the specified file instead of the last part\b 
\par \b0\f0 
\par }
1970
Scribble1970
SpanOptions property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of SpanOptions property >>>
\par 
\par }
1980
Scribble1980
SpanOptions property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SpanOptions property example
\par \cf0\b0 
\par 
\par }
1990
Scribble1990
SuccessCnt property
SuccessCnt;SuccessCnt,TZipMaster;TZipMaster,SuccessCnt;


ZipMstr20:001790
Writing


TZipMaster_SuccessCnt;SuccessCnt_Property;SuccessCnt
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SuccessCnt property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2000\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2010\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  SuccessCnt: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f2\fs20 Number of files that were successfully operated on (within the current Zip file).
\par You can read this after ever\f3 y active\f2  operation.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 Run-time only
\par Read-only
\par 
\par }
2000
Scribble2000
SuccessCnt property - See also




Done



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \pard\tx1735\cf2\strike\f1 Add\strike0\{linkID=2530\}\cf0 
\par \cf2\strike\f2 AddZippedFiles\f1  \cf3\strike0\{linkID=2620\}\cf2\f2 
\par \strike ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf2 
\par \strike CopyZippedFiles\cf3\strike0\{linkID=2840\}\cf2 
\par \strike Delete\cf3\strike0\{linkID=2900\}\cf0\f1 
\par \cf2\strike Extract\strike0\{linkID=2960\}\cf0   \cf2 
\par \strike\f2 ForEach\cf3\strike0\{linkID=3080\}\cf0\f1 
\par \pard\f0 
\par 
\par }
2010
Scribble2010
SuccessCnt property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 SuccessCnt property example
\par \cf0\b0 
\par 
\par }
2020
Scribble2020
TempDir property
TempDir;TempDir,TZipMaster;TZipMaster,TempDir;


ZipMstr20:001795
Writing


TZipMaster_TempDir;TempDir_Property;TempDir
FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TempDir property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2030\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2040\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  TempDir: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f2\fs20 If TempDir is set to a drive/directory then this full path will be used.
\par 
\par While using Diskspanning:
\par \pard\li135 This can be useful when spanning large archives.
\par If this property is not set then the used path is the system default temporary directory. This is either the path set with the TEMPDIR or TMPDIR environment variable or if both are not available the current directory on the current drive.
\par \pard 
\par While using the DLL:
\par \pard\li135 If this property is not set then the used path is the same directory as where the zipfile is located.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
2030
Scribble2030
TempDir property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TempDir property >>>
\par 
\par }
2040
Scribble2040
TempDir property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 TempDir property example
\par \cf0\b0 
\par 
\par }
2050
Scribble2050
TotalSizeToProcess property
TotalSizeToProcess;TotalSizeToProcess,TZipMaster;TZipMaster,TotalSizeToProcess;


ZipMstr20:001800
Writing


TZipMaster_TotalSizeToProcess;TotalSizeToProcess_Property;TotalSizeToProcess
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TotalSizeToProcess property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2060\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2070\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  TotalSizeToProcess: Int64;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f2\fs20 Total uncompressed file size of all files going to be processed while doing an\f3  active\f2\fs16  \fs20 operation.
\par It is set in the \cf2\strike OnProgress\strike0\{linkID=4020\}\cf0  event with event type: TotalSize2Process.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par Run-time only
\par Read-only
\par 
\par }
2060
Scribble2060
TotalSizeToProcess property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TotalSizeToProcess property >>>
\par 
\par }
2070
Scribble2070
TotalSizeToProcess property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 TotalSizeToProcess property example
\par \cf0\b0 
\par 
\par }
2080
Scribble2080
Trace property
Trace;Trace,TZipMaster;TZipMaster,Trace;


ZipMstr20:001805
Writing


TZipMaster_Trace;Trace_Property;Trace
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Trace property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2090\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2100\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Trace: Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Trace is an option to get extended messages \f3 during active operations.
\par 
\par \pard\tx355\f2 Similar to \cf2\strike Verbose\cf3\strike0\{linkID=2230\}\cf0 , except that this one is aimed at developers. 
\par It lets you trace the execution of the code. Helps you locate possible bugs, and helps you understand why something is happening a certain way.
\par 
\par \pard\fi-845\li845\tx845\cf5\b NOTE:\tab\cf0\b0 Text messages for the Trace come to you through the \cf2\strike OnMessage\strike0\{linkID=\f3 3930\f2\}\cf0  event.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
2090
Scribble2090
Trace property - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Verbose\cf3\strike0\{linkID=2230\}\cf0 
\par \cf2\strike Unattended \cf3\strike0\{linkID=2110\}\cf0 
\par \cf2\strike OnMessage\cf3\strike0\{linkID=3930\}\cf0\f0 
\par 
\par }
2100
Scribble2100
Trace property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Trace property example
\par \cf0\b0 
\par 
\par }
2110
Scribble2110
Unattended property
TZipMaster,Unattended;Unattended;Unattended,TZipMaster;


ZipMstr20:001810
Writing


TZipMaster_Unattended;Unattended_Property;Unattended
FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Unattended property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2120\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2130\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Unattended: Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Unattended is an option to make sure you won\f3 '\f2 t get ANY error and/or warning messages from the component or the DLL.
\par 
\par \pard\tx355 Default is that error or warning messages are given by the component/DLL\f3 '\f2 s which need user interaction. 
\par With this property set to \b True \b0 ALL messages are suppressed. This also implies that you will not be visually informed of problems while executing your code.
\par \pard\fi-1125\li1125\tx1125 
\par \cf5\b NOTE:\tab\cf0\b0 All messages are still available in the \cf2\strike OnMessage\strike0\{linkID=\f4 3930\f2\}\cf0  event and the \cf2\strike ErrCode\strike0\{linkID=940\}\cf0  and \f4 Err\cf2\strike\f2 Message\strike0\{linkID=970\}\cf0  properties.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
2120
Scribble2120
Unattended property - See also




Done



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ErrMessage\cf3\strike0\{linkID=970\}\cf0 
\par \cf2\strike Verbose\cf3\strike0\{linkID=2230\}\cf0 
\par \cf2\strike Trace\cf3\strike0\{linkID=2080\}\cf4\lang1033\f0 
\par \cf0\lang3081 
\par 
\par }
2130
Scribble2130
Unattended property - Example




Writing



FALSE
32
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\froman\fcharset0 Times New Roman;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red255\green0\blue0;\red128\green128\blue0;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Unattended property example
\par \pard\tx355\cf0\b0\f1 
\par 
\par If you want to use this property to test for bad zipfiles look at the following code:
\par 
\par \pard\tx275\cf2\i\tab // Set Unattended to avoid technical errors from being displayed.
\par \tab // You can still catch error messages in your OnMessage handler, if you want.
\par \cf0\tab ZipMaster1.Unattended := True;
\par 
\par \cf2\tab // The open occurs when you assign the filename
\par \cf0\tab ZipMaster1.ZipFileName := a_File_Name;
\par 
\par \cf2\tab // If the zipfile is bad, the open fails and the filename is set to an empty string.
\par \cf0\tab If ZipMaster1.ZipFileName = \f2 ''\f1  then
\par \tab begin
\par \pard\tx275\tx565\cf2\tab\tab // Do something: (skip) (check the ErrCode property) (write to a log file)
\par \cf0\tab\tab ShowMessage( \f2 '\f1 Error in Zipfile\f2 '\f1  + IntToStr( ZipMaster1.ErrCode) );
\par \pard\tx275\tab end else
\par \tab begin
\par \pard\tx275\tx565\tab\tab ZipMaster1.Unattended := False;\tab\cf2 // Not needed, depends on the next action\cf0 
\par \cf2\tab\tab // Continue processing.   
\par \pard\tx275\cf0\tab end;
\par \cf2\tab // Turn on Unattended again in case there's another problem that we are not looking for.
\par \cf0\tab ZipMaster1.Unattended := False;
\par \i0 
\par \pard\fi-1125\li1125\tx1125\cf3\b NOTE:\tab\cf0\b0 All messages are still available in the \cf4\strike OnMessage\strike0\{linkID=\f3 3930\f1\}\cf0  event and the \cf4\strike ErrCode\strike0\{linkID=940\}\cf0  and \f3 Err\cf4\strike\f1 Message\strike0\{linkID=970\}\cf0  properties.
\par 
\par \pard\f0 
\par 
\par }
2170
Scribble2170
UseDirOnlyEntries property
TZipMaster,UseDirOnlyEntries;UseDirOnlyEntries;UseDirOnlyEntries,TZipMaster;


ZipMstr20:001820
Writing


TZipMaster_UseDirOnlyEntries;UseDirOnlyEntries_Property;UseDirOnlyEntries
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 UseDirOnlyEntries property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2180\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2190\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  UseDirOnlyEntries: Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 UseDirOnlyEntries can be set to include directories in the \cf2\strike ZipDirEntry\cf3\strike0\{linkID=6340\}\cf0  records.
\par 
\par \pard\sb35\tx355 UseDirOnlyEntries can be set to \b True\b0  to include directories in the ZipDirEntry \f3 array\f2 , default is \b False\b0\f3 .\f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
2180
Scribble2180
UseDirOnlyEntries property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of UseDirOnlyEntries property >>>
\par 
\par }
2190
Scribble2190
UseDirOnlyEntries property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 UseDirOnlyEntries property example
\par \cf0\b0 
\par 
\par }
2200
Scribble2200
UseUTF8 property
TZipMaster,UseUTF8;UseUTF8;UseUTF8,TZipMaster;


ZipMstr20:001825
Writing


TZipMaster_UseUTF8;UseUTF8_Property;UseUTF8
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 UseUTF8 property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2210\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2220\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  UseUTF8: Boolean;
\par \f0 
\par \b\fs22 Description
\par \cf5\b0\f2\fs20 Delphi versions \ul before D2009\ulnone  only\cf0 .
\par \b\f0\fs22 
\par \b0\f2\fs20 Early Delphi versions do not natively support Unicode so to support international zip entry strings UseUTF8 can be set.
\par This means that \cf2\strike TZMString \cf3\strike0\{linkID=5280\}\cf0 will be assumed to be UTF8.\f0 
\par 
\par }
2210
Scribble2210
UseUTF8 property - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 TZMString\cf3\strike0\{linkID=5280\}\cf0\f0 
\par 
\par }
2220
Scribble2220
UseUTF8 property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 UseUTF8 property example
\par \cf0\b0 
\par 
\par }
2230
Scribble2230
Verbose property
TZipMaster,Verbose;Verbose;Verbose,TZipMaster;


ZipMstr20:001830
Writing


TZipMaster_Verbose;Verbose_Property;Verbose
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Verbose property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2240\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2250\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Verbose: Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Verbose is an option to get more messages from \f3 operations.
\par 
\par \pard\tx355\f2 If \b True\b0 , ask for the maximum amount of "possibly important" information from the \f3 operation\f2 .  
\par The informational messages are delivered to your program via the \cf2\strike OnMessage\strike0\{linkID=\f3 393\f2 0\}\cf0  event, and the \cf2\strike ErrCode\strike0\{linkID=940\}\cf0  and\f3  \cf2\strike ErrM\f2 essage\strike0\{linkID=970\}\cf0  properties. 
\par This is primarily used to determine how much info you want to show your "end-users" - developers can use the \cf2\strike Trace\strike0\{linkID=2080\}\cf0  property to get additional information.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
2240
Scribble2240
Verbose property - See also




Done



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Trace\cf3\strike0\{linkID=2080\}\cf0 
\par \cf2\strike Unattended\cf3\strike0\{linkID=2110\}\cf0 
\par \cf2\strike OnMessage\cf3\strike0\{linkID=3930\}\cf4\lang1033\f0 
\par \cf0\lang3081 
\par 
\par }
2250
Scribble2250
Verbose property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Verbose property example
\par \cf0\b0 
\par 
\par }
2260
Scribble2260
Version property
TZipMaster,Version;Version;Version,TZipMaster;


ZipMstr20:001835
Writing


TZipMaster_Version;Version_Property;Version
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Version property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2270\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2280\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Version: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\cf4\lang1033\b0\f2\fs20   returns a formated string of the built ZipMaster version '1.9.r.bbbb'
\par 
\par    r = revision  (1..9)
\par    bbbb = build (0.9999) \f0 
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\lang3081 Run-time only
\par 
\par }
2270
Scribble2270
Version property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of Version property >>>
\par 
\par }
2280
Scribble2280
Version property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Version property example
\par \cf0\b0 
\par 
\par }
2290
Scribble2290
WriteOptions property
TZipMaster,WriteOptions;WriteOptions;WriteOptions,TZipMaster;


ZipMstr20:001845
Writing


TZipMaster_WriteOptions;WriteOptions_Property;WriteOptions
FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 WriteOptions property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2300\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2310\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  WriteOptions: \cf2\strike TZMWriteOpts\cf3\strike0\{linkID=5390\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Controls how a zip file will be written.
\par \pard\tx540\tx2880 
\par \tab\b zwoDiskSpan\b0\tab Write as multi-part zip (using \cf2\strike SpanOptions\cf3\strike0\{linkID=1960\}\cf0 )
\par 
\par \tab\b zwoZipTime\b0\tab Set the zip time stamp to the latest contained file
\par 
\par \tab\b zwoForceDest\b0\tab Try to force that the destination folder exists
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
2300
Scribble2300
WriteOptions property - See also




Done



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SpanOptions\cf3\strike0\{linkID=1960\}\cf0 
\par \cf2\strike AddOptions\cf3\strike0\{linkID=470\}\cf0 
\par \cf2\strike Add\cf3\strike0\{linkID=2530\}\cf0 
\par \cf2\strike AddZippedFiles\cf3\strike0\{linkID=2620\}\cf0 
\par \cf2\strike ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf0 
\par \cf2\strike CopyZippedFiles\cf3\strike0\{linkID=2840\}\cf0 
\par \cf2\strike Delete\cf3\strike0\{linkID=2900\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}
\par \cf2\strike ConvertToSpanSFX\cf3\strike0\{linkID=2750\}
\par \cf2\strike ConvertToZip\cf3\strike0\{linkID=2780\}\cf0\f0 
\par 
\par }
2310
Scribble2310
WriteOptions property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 WriteOptions property example
\par \cf0\b0 
\par 
\par }
2350
Scribble2350
ZipComment property
TZipMaster,ZipComment;ZipComment;ZipComment,TZipMaster;


ZipMstr20:001855
Writing


TZipMaster_ZipComment;ZipComment_Property;ZipComment
FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ZipComment property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2360\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2370\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ZipComment: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Use ZipComment to set and if present get, the comment appended to the zip file.
\par 
\par \pard Setting this property during runtime will change the comment in the ziparchive.
\par Every ziparchive(file) can have a general comment appended to it. 
\par This comment is not zipped and may have a maximum size of 64K. 
\par It is however not desirable to have a comment of this size because it is not packed. 
\par A better solution would be to use and include an ASCII file (i.e. xxx.DIZ) in the zipped archive.
\par 
\par \f3 To build an archive with a comment, set ZipComment after setting the \cf2\strike ZipFilename\cf3\strike0\{linkID=2410\}\cf0\f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
2360
Scribble2360
ZipComment property - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ZipFilename\cf3\strike0\{linkID=2410\}\cf0\f0 
\par 
\par }
2370
Scribble2370
ZipComment property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ZipComment property example
\par \cf0\b0 
\par 
\par }
2380
Scribble2380
ZipEOC property
TZipMaster,ZipEOC;ZipEOC;ZipEOC,TZipMaster;


ZipMstr20:001860
Writing


TZipMaster_ZipEOC;ZipEOC_Property;ZipEOC
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ZipEOC property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2390\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2400\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ZipEOC: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 ZipEOC contains the location measured from the start of the zip file of the End-Of-Central-Dir.
\par 
\par ZipEOC is valid after a zip file's contents have been read successfully (which happens when you assign something to \cf2\strike ZipFileName\strike0\{linkID=2410\}\cf0 ).
\par \f0 Run-time only
\par Read-only
\par 
\par }
2390
Scribble2390
ZipEOC property - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ZipSOC\cf3\strike0\{linkID=2470\}\cf0\f0 
\par 
\par }
2400
Scribble2400
ZipEOC property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ZipEOC property example
\par \cf0\b0 
\par 
\par }
2410
Scribble2410
ZipFileName property
TZipMaster,ZipFileName;ZipFileName;ZipFileName,TZipMaster;


ZipMstr20:001865
Writing


TZipMaster_ZipFileName;ZipFileName_Property;ZipFileName
FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ZipFileName property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2420\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2430\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ZipFileName: \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 ZipFileName contains the Zip archive filename.
\par 
\par \pard\sa235 Pathname of a Zip archive file.  If the file doesn't already exist, you will only be able to use the \cf2\strike Add\strike0\{linkID=\f3 253\f2 0\}\cf0  method.  
\par It is recommended to use a fully qualified pathname in this property, unless your program can always ensure that a known directory will be the "current" directory.
\par \pard\fi-845\li845\tx845\cf5\b NOTE:\cf0\b0\tab Some filenames are illegal (operating system issue) like Con, Com1, Com2, LPT1-LPT9.
\par \pard\tx845 
\par \pard\fi-845\li845\tx845\cf5\b NOTE:\cf0\b0\tab When you assign a value to this property, the contents of the zipfile will be read\f3 .\f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 
\par \f0 
\par }
2420
Scribble2420
ZipFileName property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ZipFileName property >>>
\par 
\par }
2430
Scribble2430
ZipFileName property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ZipFileName property example
\par \cf0\b0 
\par 
\par }
2440
Scribble2440
ZipFileSize property
TZipMaster,ZipFileSize;ZipFileSize;ZipFileSize,TZipMaster;


ZipMstr20:001870
Writing


TZipMaster_ZipFileSize;ZipFileSize_Property;ZipFileSize
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ZipFileSize property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2450\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2460\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ZipFileSize: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 ZipFileSize contains the size of entire Zip file (if it\f3 '\f2 s a spanned set, then size of the last chunk).
\par 
\par \pard\sa115 ZipFileSize is valid after a zip file's contents have been read successfully (which happens when you assign something to \cf2\strike ZipFileName\strike0\{linkID=2410\}\cf0 ).
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par Run-time only
\par Read-only
\par 
\par }
2450
Scribble2450
ZipFileSize property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ZipFileSize property >>>
\par 
\par }
2460
Scribble2460
ZipFileSize property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ZipFileSize property example
\par \cf0\b0 
\par 
\par }
2470
Scribble2470
ZipSOC property
TZipMaster,ZipSOC;ZipSOC;ZipSOC,TZipMaster;


ZipMstr20:001875
Writing


TZipMaster_ZipSOC;ZipSOC_Property;ZipSOC
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ZipSOC property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2480\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2490\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ZipSOC: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 ZipSOC contains the location measured from the start of the zip file of the Start-Of-Central-Dir.
\par 
\par ZipSOC is valid after a zip file's contents have been read successfully (which happens when you assign something to \cf2\strike ZipFileName\strike0\{linkID=2410\}\cf0 ).
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
2480
Scribble2480
ZipSOC property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ZipSOC property >>>
\par 
\par }
2490
Scribble2490
ZipSOC property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ZipSOC property example
\par \cf0\b0 
\par 
\par }
2500
Scribble2500
ZipStream property
TZipMaster,ZipStream;ZipStream;ZipStream,TZipMaster;


ZipMstr20:001880
Writing


TZipMaster_ZipStream;ZipStream_Property;ZipStream
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ZipStream property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2510\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2520\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ZipStream: TMemoryStream;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Contains the result of \cf2\strike\f3 ExtractFileToStream\cf3\strike0\{linkID=2990\}\cf0\f4 , \cf2\strike AddStreamToStream \cf3\strike0\{linkID=2590\}\cf0 and \cf2\strike ExtractStreamToStream\cf3\strike0\{linkID=3020\}\cf0 .
\par \f2 It is the stream to added using \cf2\strike AddStreamToFile\cf3\strike0\{linkID=2560\}
\par \cf0\f0 
\par Run-time only
\par 
\par }
2510
Scribble2510
ZipStream property - See also




Done



FALSE
11
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\b0\strike\f1 AddStreamToFile\cf3\strike0\{linkID=2560>main\}\cf0\f2 
\par \pard\cf2\strike AddStreamToStream \cf3\strike0\{linkID=2590>main\}\cf0\f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\strike\f3 ExtractFileToStream\cf3\strike0\{linkID=2990>main\}\f2 
\par \cf2\strike ExtractStreamToStream\cf3\strike0\{linkID=3020>main\}\cf0 .\cf3\f1 
\par \pard\cf0\f0 
\par 
\par }
2520
Scribble2520
ZipStream property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ZipStream property example
\par \cf0\b0 
\par 
\par }
2530
Scribble2530
Add method
Add;Add,TZipMaster;TZipMaster,Add;


ZipMstr20:001885
Writing


TZipMaster_Add;Add_Method;Add
FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Times New Roman;}{\f4\fswiss Arial;}{\f5\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Add method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2540\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2550\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 function\b0  Add: Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs24 The Add method adds the specified files t\f4\fs20 o the archive.
\par 
\par \pard\tx355 Adds all files specified in the \cf2\strike FSpecArgs\strike0\{linkID=1090\}\cf0  property \f5 and not excluded in the \cf2\strike FSpecArgExcl \cf3\strike0\{linkID=1130\}\cf0 property \f4 into the archive specified by the \cf2\strike ZipFileName\strike0\{linkID=2410\}\cf0  property.
\par 
\par Files specified by the \cf2\strike AddStoreSuffixes\strike0\{linkID=500\}\cf0  set, that are already compressed, will not be compressed again, but will be stored "as is" in the archive. This applies normally to .ARC, .ARJ, .GIF, .LZH, .PNG, .TAZ, .TGZ, .Z, .ZIP and .ZOO files.
\par 
\par It is also possible to use \cf2\strike relative paths\strike0\{linkID=2\f5 4\f4 0\}\cf0  but your own program has to perform a few steps.
\par 
\par \f5 If an operation is already in progress it returns ErrCode or BUSY_ERROR.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 Normally returns \cf2\strike ErrCode \cf3\strike0\{linkID=940\}\cf0 and sets \cf2\strike SuccessCnt \cf3\strike0\{linkID=1990\}\cf0 to the number of files added.\f1 
\par \f0 
\par \f1 Returns 0 on success otherwise an \cf2\strike Error Code\cf3\strike0\{linkID=300\}.
\par \pard\tx355\cf0\f5 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
2540
Scribble2540
Add method - See also




Done



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddOptions\cf3\strike0\{linkID=470>main\}\cf0 
\par \cf2\strike AddStoreSuffixes\cf3\strike0\{linkID=500>main\}\cf0 
\par \cf2\strike Relative paths\strike0\{linkID=240>main\}\cf3 
\par \cf0\f0 
\par 
\par }
2550
Scribble2550
Add method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Add method example
\par \cf0\b0 
\par 
\par }
2560
Scribble2560
AddStreamToFile method
AddStreamToFile;AddStreamToFile,TZipMaster;TZipMaster,AddStreamToFile;


ZipMstr20:001890
Writing


TZipMaster_AddStreamToFile;AddStreamToFile_Method;AddStreamToFile
FALSE
27
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AddStreamToFile method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2570\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2580\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  AddStreamToFile(\b const\b0  FileName: \b String\b0 ; FileDate, FileAttr: Dword): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The AddStreamToFile method adds the specified stream to the zip archive.
\par 
\par \pard Adds stream data, which should be in \cf2\strike ZipStream\strike0\{linkID=2500\}\cf0 , to the zip archive\cf2\strike ZipFileName\strike0\{linkID=2500\}\cf0  under the filename given in the parameter FileName. Also a FileDate (DOS filedate and time) and some FileAttributes can be set.
\par 
\par \pard\fi-135\li135\tx135 -\tab If NO FileName is passed as parameter then the first in the list of \cf2\strike FSpecArgs\strike0\{linkID=1090\}\cf0  will be taken as FileName. Wildcards are not allowed!
\par 
\par -\tab If NO FileDate is passed as parameter, the local system date and time will be used.
\par 
\par -\tab FileAttr can be one or a logical combination of the following types:
\par \tab FILE_ATTRIBUTE_ARCHIVE, FILE_ATTRIBUTE_HIDDEN, FILE_ATTRIBUTE_READONLY, FILE_ATTRIBUTE_SYSTEM.
\par \tab If NO FileAttr is passed as parameter, it will be set to 0.
\par \pard\tx135 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
2570
Scribble2570
AddStreamToFile method - See also




Done



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss\fcharset0 Arial;}{\f2\fnil\fcharset0 Arial;}{\f3\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\b0\f1 
\par \cf3\strike ZipStream\cf2\strike0\{linkID=2500>main\}\cf0 .\cf2\f2 
\par \pard\cf3\strike\f1 AddStreamToStream \cf2\strike0\{linkID=2590>main\}\cf0\f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf3\strike\f3 ExtractFileToStream\cf2\strike0\{linkID=2990>main\}\f1 
\par \cf3\strike ExtractStreamToStream\cf2\strike0\{linkID=3020>main\}\cf0 .\cf2\f2 
\par \pard\cf0\f0 
\par 
\par 
\par 
\par }
2580
Scribble2580
AddStreamToFile method - Example




Writing



FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red255\green0\blue0;\red255\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 AddStreamToFile method example
\par \cf0\b0 
\par \pard\tx135\f1 
\par \pard\fi-1125\li1125\sa115\tx1125\i Example:\cf2\tab // Add something as data to the ZipStream...
\par \pard\fi-565\li565\tx565\cf0\tab ZipMaster1.ZipStream.LoadFromFile( \f2 '\f1 L:\\SomeFile.dat\f2 '\f1  );
\par \cf2\tab // *** Other possibilities ***
\par \pard\fi-565\li565\tx565\tx6235\cf3\tab // ZipMaster1.ZipStream.LoadFromStream( aStream );\cf0\tab\cf2 // Or use data from another stream.\cf3 
\par \tab // ZipMaster1.ZipStream.Write( aTextbuffer, NumberOfBytes );\cf0\tab\cf2 // Or data from a character buffer.\cf3 
\par \pard\fi-565\li565\tx565\cf0\tab ZipMaster1.AddStreamToFile( \f2 '\f1 MyFilenameToAdd.dat\f2 '\f1  );
\par \cf2\tab // *** Another possibility ***
\par \cf3\tab // ZipMaster1.FSpecArgs.Clear;
\par \tab // ZipMaster1.FSpecArgs.Append( \f2 '\f1 MyFilenameToAdd.dat\f2 '\f1  );
\par \tab // ZipMaster1.AddStreamToFile;
\par \cf2\tab // *** Another possibility ***
\par \cf3\tab // ZipMaster1.AddStreamToFile( \f2 '\f1 MyFilenameToAdd.dat\f2 '\f1 , 0, FILE_ATTRIBUTE_ARCHIVE );
\par \cf2\tab // *** Another possibility ***
\par \cf3\tab // ZipMaster1.AddStreamToFile( \f2 '\f1 MyFilenameToAdd.dat\f2 '\f1 , TDateTime( \f2 '\f1 6-4-00 14:32\f2 '\f1  ).FileDate );
\par 
\par \pard\cf0\i0\f0 
\par }
2590
Scribble2590
AddStreamToStream method
AddStreamToStream;AddStreamToStream,TZipMaster;TZipMaster,AddStreamToStream;


ZipMstr20:001895
Writing


TZipMaster_AddStreamToStream;AddStreamToStream_Method;AddStreamToStream
FALSE
32
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AddStreamToStream method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2600\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2610\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  AddStreamToStream(InStream: TMemoryStream): TMemoryStream;
\par \f0 
\par \b\fs22 Description
\par \pard\sa195\b0\f2\fs20 The AddStreamToStream method adds memory stream data to the ZipStream as packed data.\b\fs24 
\par \pard\b0\fs20 Adds the data from a memory stream to the \cf2\strike ZipStream\strike0\{linkID=2500\}\cf0 , so no files are involved in this action.
\par 
\par The size of the output stream is set to 6 bytes more than the actual output size because:
\par \pard\fi-135\li135\tx135 -\tab The first two bytes are used as a flag, STORED = 0 or DEFLATED = 8.
\par \pard\tx135\b\i Type
\par \b0\i0\tab pFlag = ^\i Smallint;
\par \tab pCRC = ^Cardinal;
\par \b Var
\par \b0\tab Flag: SmallInt;
\par \tab CRC: Cardinal;
\par \tab Flag := (pFlag ( ZipMaster1.ZipStream.Memory ))^;
\par \pard\fi-135\li135\tx135\i0 -\tab The next four bytes are set to the calculated CRC value.
\par \i\tab CRC := (pCRC( pChar( ZipMaster1.ZipStream.Memory ) + 2))^;
\par \i0 
\par \tab The start of the stream (Position) is set to the actual data start, i.e. 6 bytes from the start of the stream.
\par \pard\tx135 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
2600
Scribble2600
AddStreamToStream method - See also




Done



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\strike\f1 AddStreamToFile\cf3\strike0\{linkID=2560>main\}\f2 
\par \cf2\strike ZipStream\cf3\strike0\{linkID=2500>main\}\cf0 .\f0 
\par \cf2\strike\f3 ExtractFileToStream\cf3\strike0\{linkID=2990>main\}\f2 
\par \cf2\strike ExtractStreamToStream\cf3\strike0\{linkID=3020>main\}\cf0 .\cf3\f1 
\par \pard\cf0\f0 
\par 
\par 
\par 
\par }
2610
Scribble2610
AddStreamToStream method - Example




Writing



FALSE
25
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red255\green0\blue0;\red255\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 AddStreamToStream method example
\par \pard\tx135\cf0\b0\f1 
\par \pard\fi-565\li565\tx135\i Example:
\par \pard\tx135\b Var
\par \pard\fi-565\li565\tx565\tx845\b0\tab MyData: TMemoryStream;
\par 
\par \pard\fi-845\li845\tx275\tx845\tab\tab MyData.Create;
\par 
\par \cf2\tab\tab // Add some text as data...
\par \cf0\tab\tab MyData.LoadFromFile( \f2 '\f1 L:\\SomeFile.dat\f2 '\f1  );
\par \pard\fi-845\li845\tx275\tx845\tx5525\tab\tab\cf3 // MyData.LoadFromStream( aStream );\cf0\tab\cf2 // Or use data from another stream.\cf0 
\par \tab\tab\cf3 // MyData.Write( aTextbuffer, NumberOfBytes );\cf0\tab\cf2 // Or data from a character buffer.\cf0 
\par \pard\fi-845\li845\tx275\tx845\tab\tab ZipMaster1.AddStreamToStream( MyData );
\par \cf2\tab\tab // *** Another possibility ***
\par \cf3\tab\tab // Var MyOutData: TZipStream;
\par \cf0\tab\tab\cf3 // MyOutData := ZipMaster1.AddStreamToStream( MyData );
\par \pard\fi-565\li565\tx565\tx845\cf0\tab MyData.Free;
\par 
\par \cf2\b\tab // The Output can be found in the ZipMaster1.ZipStream property.
\par 
\par \pard\cf0\b0\i0\f0 
\par 
\par }
2620
Scribble2620
AddZippedFiles method
AddZippedFiles;AddZippedFiles,TZipMaster;CopyZippedFiles;TZipMaster,AddZippedFiles;


ZipMstr20:001900
Writing


TZipMaster_AddZippedFiles;AddZippedFiles_Method;AddZippedFiles
FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AddZippedFiles method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2630\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2640\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 function\b0  AddZippedFiles(SrcZipMaster: TCustomZipMaster; merge: \cf2\strike TZMMergeOpts\cf3\strike0\{linkID=4840\}\cf0 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Adds \cf2\strike selected \cf3\strike0\{linkID=2710\}\cf0 zipped files from another ZipMaster.
\par 
\par merge controls how duplicates will be handled - if zmoConfirm is set \cf2\strike OnCopyZippedOverwrite \cf3\strike0\{linkID=3720\}\cf0 will be fired for each conflict.
\par \f0 
\par \f1 Returns 0 on success otherwise an \cf2\strike Error Code\cf3\strike0\{linkID=300\}.
\par 
\par \cf0\f0 
\par 
\par }
2630
Scribble2630
AddZippedFiles method - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 CopyZippedFiles\cf3\strike0\{linkID=2840>main\}\cf0\f0 
\par 
\par }
2640
Scribble2640
AddZippedFiles method - Example




Writing



FALSE
26
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 AddZippedFiles method example
\par \cf0\b0 
\par \f1 // copy AutoExec.bat and Config.sys to another zip\f0 
\par \f1 Zip1.ZipFileName = 'SourceZip.zip';\tab\tab\tab\tab\cf2 // Open the source
\par \cf0 if Zip1.ErrCode <> 0 then\tab\tab\tab\tab\tab\cf2 // check no error\cf0 
\par    handle_the_error!
\par Zip1.FSpecArgs.Clear;
\par Zip1.FSpecArgs.Add( 'AutoExec.bat' );\tab\tab\tab\tab\cf2 // select required files\cf0 
\par Zip1.FSpecArgs.Add( 'Config.sys' );
\par     
\par Zip2:= TZipMaster19.Create(self);\tab\tab\tab\tab\cf2 // create ZipMaster 2\cf0 
\par Zip2.ZipFileName := 'DestinationZip.zip';\tab\tab\tab\tab\cf2 // set the destination\cf0 
\par if Zip2.ErrCode <> 0 then
\par    handle_the_error!
\par Zip2.HowToDelete := htdAllowUndo;\tab\tab\tab\tab\cf2 // 'safely' replace the destination
\par \cf0 
\par Result := Zip2.CopyZippedFiles( Zip1, true, OvrConfirm );\tab\tab\cf2 // copy files to destination, remove from source\cf0   
\par if Result <> 0 then
\par    handle_the_error!
\par \f0 
\par When the Result is 0 (Ok) then the two files are removed from SourceZip.zip and were copied into DestinationZip.zip. 
\par The Original destination archive (DestinationZip.zip) is placed into the recycle bin. 
\par File(s) that are not copied because you answered NO on the overwrite question, or in case OvrNever was specified, can be found in the FSpecArgs list from the source afterwards. 
\par }
2650
Scribble2650
AppendSlash method
AppendSlash;AppendSlash,TZipMaster;TZipMaster,AppendSlash;


ZipMstr20:001905
Writing


TZipMaster_AppendSlash;AppendSlash_Method;AppendSlash
FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AppendSlash method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2660\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2670\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  AppendSlash(\b const\b0  sDir: \b String\b0 ): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The AppendSlash method adds, if not already present, a slash \f3 '\f2\\\f3 '\f2  to the specified path.\f0 
\par 
\par }
2660
Scribble2660
AppendSlash method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of AppendSlash method >>>
\par 
\par }
2670
Scribble2670
AppendSlash method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 AppendSlash method example
\par \cf0\b0 
\par 
\par }
2680
Scribble2680
ChangeFileDetails method
ChangeFileDetails;ChangeFileDetails,TZipMaster;TZipMaster,ChangeFileDetails;


ZipMstr20:001910
Writing


TZipMaster_ChangeFileDetails;ChangeFileDetails_Method;ChangeFileDetails
FALSE
25
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ChangeFileDetails method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2690\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2700\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 function\b0  ChangeFileDetails(func: \cf2\strike TZ\f3 M\f2 ChangeFunction\cf3\strike0\{linkID=4430\}\cf0 ; \b var\b0  Data): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Allows changing the details of each \cf2\strike selected\cf3\strike0\{linkID=2710\} \cf0 entry.
\par 
\par If \cf2\strike NoSkipping\cf3\strike0\{linkID=1470\}\cf0  is True all selected files must be successfully processed otherwise the operation will fail.
\par If \ul any errors\ulnone  occur then \ul no changes will be written\ulnone .\f0 
\par 
\par \f1 Data is passed to each call of func to allow access to any needed data.
\par \f0 
\par \f1 Returns 0 on success otherwise an \cf2\strike Error Code\cf3\strike0\{linkID=300\}.
\par \cf0 
\par On exit 
\par    \cf2\strike FSpecArgs\cf3\strike0\{linkID=1090\}\cf0  contains processed file names.
\par    \cf2\strike FSpecArgsExcl\cf3\strike0\{linkID=1130\}\cf0  contains skipped files\f0 
\par }
2690
Scribble2690
ChangeFileDetails method - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ForEach\cf3\strike0\{linkID=3080\}\cf0\f0 
\par 
\par }
2700
Scribble2700
ChangeFileDetails method - Example




Writing



FALSE
119
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ChangeFileDetails method example
\par \cf0\b0 
\par // if 'data' = 1 renames with '\f1 6\f0 ' replaced by '_\f1 6\f0 '
\par function CFDfunc1(theRec: TZMDirRec; var Data): Integer;
\par var
\par   iData: integer Absolute Data;
\par begin
\par   if iData = 1 then
\par     Result := theRec.ChangeName(StringReplace(theRec.FileName, '6', '_6', [rfReplaceAll]))
\par   else
\par     Result := 1; // nothing done
\par end;
\par 
\par function TForm1.ChangeName: Integer;
\par var
\par   data: Integer;
\par begin
\par   data := 1;
\par   ZipMaster191.FSpecArgs.Add('*6.txt');
\par   Result := ZipMaster191.ChangeFileDetails(CFDfunc1, data);
\par end;
\par 
\par // Change the file date
\par function CFDfunc2(theRec: TZMDirRec; var Data): Integer;
\par var
\par   iData: Cardinal Absolute Data;
\par begin
\par   Result := theRec.ChangeDate(iData);
\par end;
\par 
\par function TForm1.ChangeDate: Integer;
\par var
\par   data: Cardinal;
\par   testDate: TDateTime;
\par begin
\par   testDate := StrToDateTime('10/04/2003 3:14');
\par   data := DateTimeToFileDate(testDate);
\par   ZipMaster191.FSpecArgsExcl.Clear;
\par   ZipMaster191.FSpecArgs.Clear;
\par   ZipMaster191.FSpecArgs.Add('*d*.txt');
\par   Result := ZipMaster191.ChangeFileDetails(CFDfunc2, data);
\par end;
\par 
\par // Change the file comment
\par function CFDfunc3(theRec: TZMDirRec; var Data): Integer;
\par var
\par   iData: String Absolute Data;
\par begin
\par   Result := theRec.ChangeComment(iData);
\par end;
\par 
\par function TForm1.ChangeComment: Integer;
\par var
\par   Comment: String;
\par begin
\par   Comment := 'some comment';
\par   ZipMaster191.FSpecArgsExcl.Clear;
\par   ZipMaster191.FSpecArgs.Clear;
\par   ZipMaster191.FSpecArgs.Add('*a*.txt');
\par   Result := ZipMaster191.ChangeFileDetails(CFDfunc3, Comment);
\par end;
\par 
\par // Change the file attribute
\par function CFDfunc4(theRec: TZMDirRec; var Data): Integer;
\par var
\par   iData: DWORD Absolute Data;
\par begin
\par   Result := theRec.ChangeAttrs(iData);
\par end;
\par 
\par function TForm1.ChangeAttributes: Integer;
\par var
\par   newAttr: DWORD;
\par begin
\par   newAttr := FILE_ATTRIBUTE_READONLY;
\par   ZipMaster191.FSpecArgsExcl.Clear;
\par   ZipMaster191.FSpecArgs.Clear;
\par   ZipMaster191.FSpecArgs.Add('*l*.txt');
\par   Result := ZipMaster191.ChangeFileDetails(CFDfunc4, newAttr);
\par end;
\par 
\par 
\par procedure TForm1.Button1Click(Sender: TObject);
\par var
\par   err: Integer;
\par begin
\par    ZipMaster191.\f1 Clear;\f0 
\par    ZipMaster191.ZipFileName := 'zTest.zip';
\par    if ZipMaster191.Count > 1 then
\par    begin
\par      err := ChangeName;
\par      Memo1.Lines.Add(Format(' ChangeName returns %d [ %d files ]', [err, ZipMaster191.SuccessCnt]));
\par      if err <> 0 then
\par        Memo1.Lines.Add(' failed ' + ZipMaster191.ErrMessage)
\par      else
\par      begin
\par        Memo1.Lines.Add('Changed files ----');
\par        Memo1.Lines.AddStrings(ZipMaster191.FSpecArgs);
\par        Memo1.Lines.Add('Skipped files ----');
\par        Memo1.Lines.AddStrings(ZipMaster191.FSpecArgsExcl);
\par      end;
\par      err := ChangeDate;
\par      Memo1.Lines.Add(Format(' ChangeDate returns %d [ %d files ]', [err, ZipMaster191.SuccessCnt]));
\par      if err <> 0 then
\par        Memo1.Lines.Add(' failed ' + ZipMaster191.ErrMessage)\f1 ;\f0 
\par      err := ChangeComment;
\par      Memo1.Lines.Add(Format(' ChangeComment returns %d [ %d files ]', [err, ZipMaster191.SuccessCnt]));
\par      if err <> 0 then
\par        Memo1.Lines.Add(' failed ' + ZipMaster191.ErrMessage)\f1 ;\f0 
\par      err := ChangeAttributes;
\par      Memo1.Lines.Add(Format(' ChangeAttributes returns %d [ %d files ]', [err, ZipMaster191.SuccessCnt]));
\par      if err <> 0 then
\par        Memo1.Lines.Add(' failed ' + ZipMaster191.ErrMessage)\f1 ;\f0 
\par    end;
\par end;
\par 
\par }
2710
Scribble2710
Selecting files




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green0\blue0;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Selecting files\cf2\{keepn\}\cf3\b0\f1\fs20 
\par 
\par \f0 Most operations will be done on selected file entries only.
\par 
\par File entries are selected by specs in \cf4\strike FSpecArgs \cf2\strike0\{linkID=1090\}\cf3 if not excluded by specs in \cf4\strike FSpecArgsExcl\cf2\strike0\{linkID=1130\}\cf3 .\f1 
\par 
\par }
2720
Scribble2720
ConvertToSFX method
ConvertToSFX;ConvertToSFX,TZipMaster;ConvertToSpanSFX;TZipMaster,ConvertToSFX;


ZipMstr20:001915
Writing


TZipMaster_ConvertToSFX;ConvertToSFX_Method;ConvertToSFX
FALSE
31
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ConvertToSFX method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2730\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2740\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 function\b0  ConvertToSFX: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\b0\f3\fs20 Convert Zip archive to self-extracting .EXE. The resulting .EXE is a Win32 program. Uses the same base name and path already used by the Zipfile - only the file extension is changed to "EXE". This is accomplished by pre-pending the SFX code in  front of the Zip file, and then changing its extension.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 This function returns\f4  0 on success or a negative error value on failure\f1  \cf2\strike Error Code\cf3\strike0\{linkID=300\}.\cf0\f3 
\par \pard\tqr\tx565\tqr\tx705 
\par \pard\fi-1695\li1695\tx1695\cf5\b IMPORTANT:\tab 
\par \pard\f4          \cf0\b0\f3 Before using ConvertSFX, you may want to first set \cf4\f1 
\par \pard\fi-780\li780\tx180\cf2\tab\tab\strike SFXCaption\cf3\strike0\{linkID=1660\}\cf4 
\par \cf2\tab\tab\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf4 
\par \cf2\tab\tab\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf4 
\par \cf2\tab\tab\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf4 
\par \cf2\tab\tab\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf4 
\par \cf2\tab\tab\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf4 
\par \cf2\tab\tab\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf4 
\par \cf2\tab\tab\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf4 
\par \pard\fi-820\li820\tx1680\cf2\tab\strike SFXPath\cf3\strike0\{linkID=1900\} \cf4 property to the full pathname of the \cf2\strike SFX stub\cf3\strike0\{linkID=1925\}\cf4 . If you don't set this property, ZipBuilder will automatically look for this file in the Current directory, the application directory, the Windows System and Windows directories and if present the directory specified by the \cf2\strike DLLDirectory\cf3\strike0\{linkID=820\}\cf4  property.\cf0\f3 
\par \pard\fi-1695\li1695\tx1695 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
2730
Scribble2730
ConvertToSFX method - See also




Done



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par 
\par \cf2\b0\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}\cf0\f0 
\par \cf2\strike\f1 ConvertToSpanSFX\cf3\strike0\{linkID=2750\}\cf0 
\par \cf2\strike ConvertToZIP\cf3\strike0\{linkID=2780\}\cf0 
\par \f0 
\par 
\par }
2740
Scribble2740
ConvertToSFX method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ConvertToSFX method example
\par \cf0\b0 
\par 
\par }
2750
Scribble2750
ConvertToSpanSFX method
ConvertToSFX;ConvertToSpanSFX;ConvertToSpanSFX,TZipMaster;TZipMaster,ConvertToSpanSFX;


ZipMstr20:001920
Writing


TZipMaster_ConvertToSpanSFX;ConvertToSpanSFX_Method;ConvertToSpanSFX
FALSE
32
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ConvertToSpanSFX method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2760\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2770\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 function\b0  ConvertToSpanSFX(\b const\b0  OutFile: \b String\b0 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Convert Zip archive to self-extracting .EXE\f4  with a detached header (loader) and convert the zip file to a spanned zip.\f0 
\par \pard\tx355\f3 OutFile is the name of the resulting .EXE file and the base name for the spanned volumes.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 This function returns\f4  0 on success or a negative error value on failure\f1  \cf2\strike Error Code\cf3\strike0\{linkID=300\}.\cf0\f3 
\par \pard\tqr\tx565\tqr\tx705 
\par \pard\fi-1695\li1695\tx1695\cf5\b IMPORTANT:\tab 
\par \pard\f4          \cf0\b0\f3 Before using ConvertSFX, you may want to first set \cf4\f1 
\par \pard\fi-780\li780\tx180\cf2\tab\tab\strike SFXCaption\cf3\strike0\{linkID=1660\}\cf4 
\par \cf2\tab\tab\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf4 
\par \cf2\tab\tab\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf4 
\par \cf2\tab\tab\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf4 
\par \cf2\tab\tab\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf4 
\par \cf2\tab\tab\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf4 
\par \cf2\tab\tab\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf4 
\par \cf2\tab\tab\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf4 
\par \pard\fi-820\li820\tx1680\cf2\tab\strike SFXPath\cf3\strike0\{linkID=1900\} \cf4 property to the full pathname of the \cf2\strike SFX stub\cf3\strike0\{linkID=1925\}\cf4 . If you don't set this property, ZipBuilder will automatically look for this file in the Current directory, the application directory, the Windows System and Windows directories and if present the directory specified by the \cf2\strike DLLDirectory\cf3\strike0\{linkID=820\}\cf4  property.\cf0\f3 
\par \pard\fi-1695\li1695\tx1695 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
2760
Scribble2760
ConvertToSpanSFX method - See also




Done



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par \f2\fs24 
\par \f0\fs20 
\par }
2770
Scribble2770
ConvertToSpanSFX method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ConvertToSpanSFX method example
\par \cf0\b0 
\par 
\par }
2780
Scribble2780
ConvertToZIP method
ConvertToSFX;ConvertToSpanSFX;ConvertToZIP;ConvertToZIP,TZipMaster;TZipMaster,ConvertToZIP;


ZipMstr20:001925
Writing


TZipMaster_ConvertToZIP;ConvertToZIP_Method;ConvertToZIP
FALSE
24
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ConvertToZIP method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2790\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2800\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ConvertToZIP: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\b0\f2\fs20 Converts a self-extracting .exe file into a Zip archive. 
\par  This is accomplished by removing the SFX code from the beginning of a file\f3 ,and rewriting the file with new offsets after\f2  changing its extension.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 This function returns\f3  0 on success or a negative error value on failure\f4  \cf2\strike Error Code\cf3\strike0\{linkID=300\}.\cf0\f2 
\par \pard\tqr\tx565\tqr\tx705 
\par \pard\fi-1555\li1555\tx1555\cf5\b WARNING:\tab\cf0\b0 The use of Convert\f3 To\f2 ZIP can NOT be guaranteed to work with all self-extracting archive formats.  It will work on MS-DOS self-extracting zip archives, and on those made by WinZip (product of Nikko Mak Computing), but some self-extracting formats are not even based on Zip compression.
\par \pard\tx1555 
\par For example, the freeware "ASetup" program uses the .LZH  compression format.  In fact, most setup programs use compression formats that aren't Zip compatible. If you try to use Convert\f3 To\f2 ZIP on an archive that doesn't conform to the Zip standard, you will get errors. If fact, you can't even list the contents of an .EXE archive if it's not a standard Zip format.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
2790
Scribble2790
ConvertToZIP method - See also




Done



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXCaption\cf3\strike0\{linkID=1660\}\cf0 
\par \cf2\strike SFXCommandLine\cf3\strike0\{linkID=1690\}\cf0 
\par \cf2\strike SFXDefaultDir\cf3\strike0\{linkID=1720\}\cf0 
\par \cf2\strike SFXIcon\cf3\strike0\{linkID=1750\}\cf0 
\par \cf2\strike SFXMessage\cf3\strike0\{linkID=1780\}\cf0 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike SFXOverwriteMode\cf3\strike0\{linkID=1870\}\cf0 
\par \cf2\strike SFXPath\cf3\strike0\{linkID=1900\}\cf0 
\par \cf2\strike SFXRegFailPath\cf3\strike0\{linkID=1930\}\cf0 
\par \cf2\strike SFXStub\cf3\strike0\{linkID=1925\}
\par \cf2\strike ConvertToSFX\cf3\strike0\{linkID=2720\}\cf0\f0 
\par \cf2\strike\f1 ConvertToSpanSFX\cf3\strike0\{linkID=2750\}\cf0\f2\fs24 
\par \f0\fs20 
\par 
\par }
2800
Scribble2800
ConvertToZIP method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ConvertToZIP method example
\par \cf0\b0 
\par 
\par }
2810
Scribble2810
Copy_File method
Copy_File;Copy_File,TZipMaster;TZipMaster,Copy_File;


ZipMstr20:001930
Writing


TZipMaster_Copy_File;Copy_File_Method;Copy_File
FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Copy_File method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2820\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2830\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  \b Copy_File\b0 (\b const\b0  InFileName, OutFileName: \b String\b0 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\cf4\b0\f2\fs20 This copies any file to any other file. Useful in many application programs, so it was included here as a method. \cf0 
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 This function returns\f3  0 on success or a negative error value on failure\f4  \cf2\strike Error Code\cf3\strike0\{linkID=300\}.\cf4\f2 
\par \pard\tx845\cf0 
\par \pard\fi-1695\li1695\tx1695\cf5\b IMPORTANT:\cf0\b0\tab 
\par \f3     \f2 The destination must include a filename ( You can't copy a file to C:\\ ).  
\par \f3     \f2 Also, wildcards are not allowed in either source or destination.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
2820
Scribble2820
Copy_File method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of Copy_File method >>>
\par 
\par }
2830
Scribble2830
Copy_File method - Example




Writing



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Copy_File method example
\par \cf0\b0 
\par \pard\tx845\cf2\f1 
\par Can be used to make a backup copy of the ZipFile before an Add operation.
\par Example:
\par \pard\li425\tx845 ret := Copy\f2 _\f1 File( ZipFileName, \f3 '\f1 C:\\TMPZIP.TMP\f3 '\f1  );
\par if  ret < 0  then
\par    ShowMessage( \f3 '\f1 Error no. \f3 '\f1  + IntToStr(\f2 -\f1  ret ) + \f3 '\f1  in making backup\f3 '\f1  );
\par \pard\tx845\cf0 
\par \pard\f0 
\par }
2840
Scribble2840
CopyZippedFiles method
AddZippedFiles;CopyZippedFiles;CopyZippedFiles,TZipMaster;TZipMaster,CopyZippedFiles;


ZipMstr20:001935
Done


TZipMaster_CopyZippedFiles;CopyZippedFiles_Method;CopyZippedFiles
FALSE
36
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 CopyZippedFiles method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2850\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2860\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 function\b0  CopyZippedFiles(DestZipMaster: TCustomZipMaster; DeleteFromSource: Boolean; OverwriteDest: \cf2\strike TZMMergeOpts\cf3\strike0\{linkID=4840\}\cf0 ): Integer;\b\f0\fs22 
\par \b0\fs20 
\par \b\fs22 Description
\par \pard\tx6745\cf4\b0\f3\fs20 CopyZippedFiles copies zipped entries from the source zip archive to a destination zip archive\cf0  without, the possibly time consuming need, of extracting and re-zipping again. 
\par \cf4 The file(s) to be copied must be \cf2\strike s\f4 elected\cf3\strike0\f3\{linkID=2710\}\f4  \cf4\f3 in the source archive before calling this function.
\par \cf0 
\par \b DestZipMaster\cf4\b0  is the ZipMaster component you are going to use as the destination zip archive.
\par 
\par (The source zip archive is the one you are calling this function from.\cf0 )
\par 
\par \cf4 With \b DeleteFromSource\b0  you specify if the source file(s) must be deleted after a successful copy.
\par 
\par \cf0\b OverWriteDest\b0  can take one of the following values:
\par \pard\sb115\sa115\tx1985\b\fs24 Value\tab Meaning
\par \pard\fi-1985\li1985\tx1985\b0\fs20 zmoConfirm\f4\tab\f3 Ask the user if the destination may be overwritten when a\f4  \f3 source file is found inside the destination or performs the\f4  \cf2\strike\f3 OnCopyZipOverwrite\strike0\{linkID=3720\}\cf0  event when assigned.
\par zmoAlways\f4\tab\f3 Always overwrite existing files in the destination
\par zmoNewer\f4\tab\f3 Overwrite only when the source file is younger than the\f4  \f3 destination file
\par zmoOlder\f4\tab\f3 Overwrite only when the source file is older than the\f4  \f3 destination file
\par zmoNever\f4\tab\f3 Never overwrite - skip those files, afterwards these files can\f4  \f3 be found in FSpecArgs from the source. 
\par \pard\tx355 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 This function returns\f4  0 on success or an error value on failure\f1  \cf2\strike Error Code\cf3\strike0\{linkID=300\}.\cf4\f3 
\par \pard\tx845\cf0 
\par \f4 Note: \cf4\f3 the destination zip archive\f4  does not have to exist but must be writable.\cf0\f3 
\par \pard\fi-705\li705\tqr\tx565\tqr\tx705\cf4 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\f0 
\par 
\par }
2850
Scribble2850
CopyZippedFiles method - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddZippedFiles\cf3\strike0\{linkID=2620\}\cf0 
\par \cf2\strike OnCopyZipOverwrite\cf3\strike0\{linkID=3720\}\cf0\f0 
\par \cf2\strike\f1 TZMMergeOpts\cf3\strike0\{linkID=4840\}\cf0\f0 
\par }
2860
Scribble2860
CopyZippedFiles method - Example




Done



FALSE
26
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 CopyZippedFiles method example
\par \cf0\b0 
\par \f1 // copy AutoExec.bat and Config.sys to another zip\f0 
\par \f1 Zip1.ZipFileName = 'SourceZip.zip';\tab\tab\tab\tab\cf2 // Open the source
\par \cf0 if Zip1.ErrCode <> 0 then\tab\tab\tab\tab\tab\cf2 // check no error\cf0 
\par    handle_the_error!
\par Zip1.FSpecArgs.Clear;
\par Zip1.FSpecArgs.Add( 'AutoExec.bat' );\tab\tab\tab\tab\cf2 // select required files\cf0 
\par Zip1.FSpecArgs.Add( 'Config.sys' );
\par Zip1.HowToDelete := htdAllowUndo;\tab\tab\tab\tab\cf2 // 'safely' replace the destination\cf0 
\par     
\par Zip2:= TZipMaster19.Create(self);\tab\tab\tab\tab\cf2 // create ZipMaster 2\cf0 
\par Zip2.ZipFileName := 'DestinationZip.zip';\tab\tab\tab\tab\cf2 // set the destination\cf0 
\par if Zip2.ErrCode <> 0 then
\par    handle_the_error!\cf2 
\par \cf0 
\par Result := Zip1.CopyZippedFiles( Zip2, true, zmoConfirm );\tab\tab\cf2 // copy files to destination, remove from source\cf0   
\par if Result <> 0 then
\par    handle_the_error!
\par 
\par When the Result is 0 (Ok) then the two files are removed from SourceZip.zip and were copied into DestinationZip.zip. 
\par The Original destination archive (DestinationZip.zip) is placed into the recycle bin. 
\par File(s) that are not copied because you answered NO on the overwrite question, or in case OvrNever was specified, can be found in the FSpecArgs list from the source afterwards. \f0 
\par }
2870
Scribble2870
Deflate method
Deflate;Deflate,TZipMaster;TZipMaster,Deflate;


ZipMstr20:001940
Done


TZipMaster_Deflate;Deflate_Method;Deflate
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}{\f4\fswiss Arial;}{\f5\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Deflate method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2880\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2890\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  Deflate(OutStream, InStream: TStream; Length: Int64; \b var\b0  Method: \cf2\strike\f2 TZMDeflates\cf3\strike0\{linkID=4644\}\cf0\f1 ; \b var\b0  CRC: Cardinal): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Compress InStream to OutStream, set method and CRC on success.
\par   Length = the size of the data on InStream to be deflated (-1 = full length).
\par   Method = the requested compression method, on exit it will be the method used.
\par \pard\fi-1985\li1985\sa195\tx1985\f4 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 This function returns\f5  0 on success or a negative error value on failure\f3  \cf2\strike Error Code\cf3\strike0\{linkID=300\}.\cf4\f4 
\par \cf0\f0 
\par }
2880
Scribble2880
Deflate method - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Undeflate\cf3\strike0\{linkID=3440\}\cf0\f0 
\par 
\par }
2890
Scribble2890
Deflate method - Example




Done



FALSE
31
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Deflate method example
\par \cf0\b0 
\par 
\par   instream := TFileStream.Create(fn, fmOpenRead);
\par   try
\par     instream.Position := 0;
\par     Orig := instream.Size;
\par     outstream := TFileStream.Create(\f1 'deflated\f0 .bin', fmCreate);
\par     try
\par       method := zmDeflate;
\par       crc := 0;
\par       Result := z\f1 ip\f0 .Deflate(outstream, instream, -1, method, crc);
\par       
\par       Display('orig = ' + IntToStr(Orig) + '  size = ' + IntToStr(outstream.Size)
\par           + '  posn = ' + IntToStr(outstream.Position) + '  method = ' + 
\par            '  crc = ' + IntToHex(crc, 4));
\par       if z.SuccessCnt = 1 then
\par       begin
\par         Display('Deflate success');
\par       end;
\par     finally
\par       outstream.Free;
\par     end;
\par   finally
\par     instream.Free;
\par   end;
\par \f1   if Result <> 0 then
\par      handle_error!\f0 
\par }
2900
Scribble2900
Delete method
Delete;Delete,TZipMaster;TZipMaster,Delete;


zipmstr20:001945
Writing


TZipMaster_Delete;Delete_Method;Delete
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Delete method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2910\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2920\}\tab\cf2\strike\f1 Working with SFX\cf3\strike0\f0\{linkID=%\f1 307\f0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 function\b0  Delete: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\tx6745\cf4\b0\f3\fs20 Deletes \cf2\strike\f4 selected\cf3\strike0\f3\{linkID=2710\}\f4  \cf4\f3 files from the archive specified by the \cf2\strike ZipFileName\strike0\{linkID=2410\}\cf4  property.\cf0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
2910
Scribble2910
Delete method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of Delete method >>>
\par 
\par }
2920
Scribble2920
Delete method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Delete method example
\par \cf0\b0 
\par 
\par }
2930
Scribble2930
EraseFile method
EraseFile,TZipMaster;TZipMaster,EraseFile;


ZipMstr20:001950
Writing


TZipMaster_EraseFile;EraseFile_Method;EraseFile
FALSE
25
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 EraseFile method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2940\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2950\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  EraseFile(\b const\b0  FName: \b String\b0 ; How: \cf2\strike TZMDeleteOpts\cf3\strike0\{linkID=4630\}\cf0 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\tx6745\cf4\b0\f2\fs20 EraseFile is like DeleteFile, but depending on the value of \f3 '\f2 How\f3 '\f2  the specified file will be deleted completely or will be put into the recycle bin. When just a filename is specified the drive and directory will be taken from the current drive and directory.
\par \cf0 
\par How can take one of the following values:
\par \pard\sb115\sa115\tx1985\b\fs24 Value\tab Meaning
\par \pard\tx1985\b0\fs20 htdFinal\tab Perform a DeleteFile. (The default)
\par htdAllowUndo\tab Move the old file into the recycle bin.\cf4 
\par \pard\tx6745 
\par EraseFile is also used internally by the component functions ConvertZip, ConvertSFX, CopyFile, CopyZippedFiles and ReadSpan but then uses the property \cf2\strike HowToDelete\strike0\{linkID=1200\}\cf4  as How value.
\par 
\par The return value will be the return value of SHFileOperation ( 0 if Ok else not zero ) or \f3 -\f2 1 in case of memory error.\cf0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
2940
Scribble2940
EraseFile method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of EraseFile method >>>
\par 
\par }
2950
Scribble2950
EraseFile method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 EraseFile method example
\par \cf0\b0 
\par 
\par }
2960
Scribble2960
Extract method
Extract;Extract,TZipMaster;TZipMaster,Extract;


ZipMstr20:001955
Writing


TZipMaster_Extract;Extract_Method;Extract
FALSE
24
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Extract method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%2970\}\tab\cf2\strike Example\cf3\strike0\{linkID=%2980\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  Extract: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\cf4\b0\f2\fs20 Extracts all files specified in the \cf2\strike FSpecArgs\strike0\{linkID=1090\}\cf4  property from the archive specified by the \cf2\strike ZipFileName\strike0\{linkID=2410\}\cf4  property. 
\par If you don't specify any FSpecArgs, then all files will be extracted\f3  to \cf2\strike ExtrBaseDir\cf3\strike0\{linkID=1030\}\cf4\f2 
\par 
\par The Extract method can also test the integrity of files in an archive.
\par 
\par If you set the ExtrTest option of \cf2\strike ExtrOptions\strike0\{linkID=1060\}\cf4 , then ALL files in the archive will be tested. 
\par This will cause them to be extracted, but not saved to the hard disk. Their CRC will be verified, and results will go to the \cf2\strike SuccessCnt\strike0\{linkID=1990\}\cf4  property, and the \cf2\strike OnMessage\strike0\{linkID=\f3 393\f2 0\}\cf4  event handler.
\par 
\par Returns 0 on success otherwise an \cf2\strike ErrCode\cf3\strike0\{linkID=940\}\cf0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
2970
Scribble2970
Extract method - See also




Done



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red0\green0\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 FSpecArgs\strike0\{linkID=1090\}
\par \strike ZipFileName\strike0\{linkID=2410\}\cf3 
\par \cf2\strike\f2 ExtrBaseDir\cf4\strike0\{linkID=1030\}\cf3\f1  
\par \cf2\strike ExtrOptions\strike0\{linkID=1060\}
\par \strike SuccessCnt\strike0\{linkID=1990\}\cf3  
\par \cf2\strike OnMessage\strike0\{linkID=\f2 3930\f1\}
\par \strike\f2 ErrCode\cf4\strike0\{linkID=940\}\cf3\f1 
\par \cf0\f0 
\par 
\par }
2980
Scribble2980
Extract method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Extract method example
\par \cf0\b0 
\par 
\par }
2990
Scribble2990
ExtractFileToStream method
ExtractFileToStream;ExtractFileToStream,TZipMaster;TZipMaster,ExtractFileToStream;


ZipMstr20:001960
Writing


TZipMaster_ExtractFileToStream;ExtractFileToStream_Method;ExtractFileToStream
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExtractFileToStream method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3000\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3010\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ExtractFileToStream(\b const\b0  FileName: \b String\b0 ): TMemoryStream;
\par \f0 
\par \b\fs22 Description\cf4\b0\f2\fs20 
\par \pard\sa195\tx355\cf0 With the ExtractFileToStream method you can extract a specified file from a Zip archive into a stream.\b\fs24 
\par \pard\tx355\cf4\b0\fs20 Extracts if specified file \f3 '\f2 Filename\f3 '\f2  or else the first file specified in the \cf2\strike FSpecArgs\strike0\{linkID=1090\}\cf4  property from the archive specified by the \cf2\strike ZipFileName\strike0\{linkID=2410\}\cf4  property
\par \cf0 
\par After this method returns the stream position is at the begin of the stream.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
3000
Scribble3000
ExtractFileToStream method - See also




Done



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\b0\strike\f1 AddStreamToFile\cf3\strike0\{linkID=2560>main\}\cf0\f2 
\par \cf2\strike AddStreamToStream \cf3\strike0\{linkID=2590>main\}
\par \cf2\strike ZipStream\cf3\strike0\{linkID=2500>main\}\cf0 .\cf3 
\par \cf2\strike ExtractStreamToStream\cf3\strike0\{linkID=3020>main\}\cf0 .\cf3\f1 
\par \pard\cf0\f0 
\par 
\par 
\par 
\par }
3010
Scribble3010
ExtractFileToStream method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ExtractFileToStream method example
\par \cf0\b0 
\par 
\par }
3020
Scribble3020
ExtractStreamToStream method
ExtractStreamToStream;ExtractStreamToStream,TZipMaster;TZipMaster,ExtractStreamToStream;


ZipMstr20:001965
Done


TZipMaster_ExtractStreamToStream;ExtractStreamToStream_Method;ExtractStreamToStream
FALSE
38
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExtractStreamToStream method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3030\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3040\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ExtractStreamToStream(InStream: TMemoryStream; OutSize: Longword): TMemoryStream;
\par \f0 
\par \b\fs22 Description\cf4\b0\f2\fs20 
\par \pard\tx355\cf0 With the ExtractStreamToStream method you can extract a specified stream from another stream.
\par 
\par \cf4 Extracts the specified InStream into an output stream (\cf2\strike ZipStream\strike0\{linkID=2500\}\cf4 ).
\par Since the uncompressed size is not stored it is possible to specify the output size yourself in OutSize.
\par If OutSize is not given a start size of 32768 bytes is used and increased when needed in steps of 32768 bytes this will take extra time because with each increment the memory already in use need to be copied to a new location.
\par \cf0 
\par The first 6 bytes of the input stream are reserved:
\par \pard\fi-135\li135\tx135 
\par -\tab The first two bytes are used as a flag, STORED = 0 or DEFLATED = 8.
\par \pard\tx135\b\i Type
\par \b0\i0\tab pFlag = ^\i Smallint;
\par \tab pCRC = ^Cardinal;
\par \b Var
\par \b0\tab Flag: SmallInt;
\par \tab CRC: Cardinal;
\par \pard\fi-135\li135\tx135\tab Flag := 8;
\par \tab (pFlag( ZipMaster1.ZipStream.Memory ))^ := Flag;
\par \i0 -\tab The next four bytes should be set to the calculated CRC value, if this value is wrong an \cf2\strike OnCRC32Error\strike0\{linkID=3750\}\cf0  event will follow.
\par \i\tab CRC := xxx;
\par \tab (pCRC( pChar( ZipMaster1.ZipStream.Memory ) + 2))^ := CRC;
\par \i0 
\par \pard\tx135 After this method returns the stream position is at the begin of the stream.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3030
Scribble3030
ExtractStreamToStream method - See also




Done



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\strike\f1 AddStreamToFile\cf3\strike0\{linkID=2560>main\}\cf0\f2 
\par \pard\cf2\strike AddStreamToStream \cf3\strike0\{linkID=2590>main\}\cf0\f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\strike\f3 ExtractFileToStream\cf3\strike0\{linkID=2990>main\}\f2 
\par \cf2\strike ZipStream\cf3\strike0\{linkID=2500>main\}\cf0 .\cf3\f1 
\par \pard\cf0\f0 
\par 
\par 
\par 
\par }
3040
Scribble3040
ExtractStreamToStream method - Example




Done



FALSE
27
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red255\green0\blue0;\red255\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ExtractStreamToStream method example
\par \cf0\b0 
\par \pard\tx135\f1 
\par \pard\fi-565\li565\tx565\tx845\i Example:
\par \b Var
\par \b0\tab MyData: TMemoryStream;
\par \b Begin
\par \b0\tab MyData.Create;
\par 
\par \cf2\tab // Add some text as data...
\par \cf3\tab // MyData.LoadFromFile( \f2 '\f1 SomeTextFile.txt\f2 '\f1  );
\par \cf0\tab MyData.LoadFromStream( ZipMaster1.ZipStream );
\par \cf3\tab // MyData.Write( aTextbuffer, NumberOfBytes );
\par \cf0\tab ZipMaster1.ExtractStreamToStream( MyData );
\par \cf2\tab // *** Another possibility ***
\par \cf3\tab // Var MyOutData: \cf0 TMemoryStream\cf3 ;
\par \tab // MyOutData := ZipMaster1.ExtractStreamToStream( MyData );
\par \cf0\tab MyData.Free;
\par 
\par \cf2\tab // The Output can be found in the ZipMaster1.ZipStream property.
\par \cf0\tab MsgForm.RichEdit1.Lines.LoadFromStream( ZipMaster1.ZipStream );
\par \tab MsgForm.Show;
\par 
\par \pard\i0\f0 
\par }
3050
Scribble3050
Find method
Find;Find,TZipMaster;TZipMaster,Find;


ZipMstr20:001970
Writing


TZipMaster_Find;Find_Method;Find
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Find method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3060\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3070\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  Find(\b const\b0  fspec: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ; \b var\b0  idx: Integer): \cf2\strike TZ\f2 M\f1 DirEntry\cf3\strike0\{linkID=6340\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Finds the first occurance of fspec \b after \b0 idx.
\par If found sets idx to the found index and returns a read-only copy of the entry.\f0 
\par 
\par }
3060
Scribble3060
Find method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of Find method >>>
\par 
\par }
3070
Scribble3070
Find method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Find method example
\par \cf0\b0 
\par 
\par }
3080
Scribble3080
ForEach method
ForEach;ForEach,TZipMaster;TZipMaster,ForEach;


ZipMstr20:001975
Done


TZipMaster_ForEach;ForEach_Method;ForEach
FALSE
27
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ForEach method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3090\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3100\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ForEach(func: \cf2\strike TZMForEachFunction\cf3\strike0\{linkID=4450\}\cf0 ; \b var\b0  Data): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Applies func to each \cf2\strike selected\cf3\strike0\{linkID=2710\} \cf0 entry.
\par func can not modify any entry.
\par \b\f0\fs22 
\par \b0\f2\fs20 If \cf2\strike NoSkipping\cf3\strike0\{linkID=1470\}\cf0  is True all selected files must be successfully processed otherwise the operation will fail.\f0 
\par 
\par \f2 Data is passed to each call of func to allow access to any needed data.
\par \f0 
\par \f2 Returns 0 on success otherwise an \cf2\strike ErrCode\cf3\strike0\{linkID=940\}.
\par \cf0 
\par On exit 
\par    \cf2\strike FSpecArgs\cf3\strike0\{linkID=1090\}\cf0  contains processed file names.
\par    \cf2\strike FSpecArgsExcl\cf3\strike0\{linkID=1130\}\cf0  contains skipped files\f0 
\par 
\par 
\par }
3090
Scribble3090
ForEach method - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf0\f0 
\par 
\par }
3100
Scribble3100
ForEach method - Example




Done



FALSE
39
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ForEach method example\cf0\b0 
\par 
\par // sum the compressed sizes in DATA
\par function FEfunc1(theRec: TZMDirEntry; var Data): Integer;
\par var
\par   iData: Int64 Absolute Data;
\par begin
\par   Result := 0;\f1\tab\tab\tab\tab\tab // success\f0 
\par   iData := iData + theRec.CompressedSize;
\par end;
\par 
\par function TForm1.SumCompressed: Int64;
\par var
\par   total: Int64;
\par begin
\par   total := 0;
\par   if ZipMaster.ForEach(FEfunc1, total) <> 0 then
\par     raise Exception.Create('ForEach failed');
\par   Result := total;
\par end;
\par 
\par procedure TForm1.Button2Click(Sender: TObject);
\par var
\par   total: Int64;
\par begin
\par   ZipMaster.\f1 Clear;\f0 
\par   ZipMaster.ZipFileName := \f1 '\f0 zTest.zip';
\par   if ZipMaster.Count > 1 then
\par   begin
\par     ZipMaster.FSpecArgs.Add('*\f1 k\f0 *.txt');\f1\tab // select some files\f0 
\par     total := SumCompressed;
\par     Memo1.Lines.Add(Format(' Total compressed size %d [ %d files ]', [total, ZipMaster.SuccessCnt]));
\par   end;
\par end;
\par 
\par 
\par }
3110
Scribble3110
FullVersionString method
FullVersionString;FullVersionString,TZipMaster;TZipMaster,FullVersionString;


zipmstr20:001980
Done


TZipMaster_FullVersionString;FullVersionString_Method;FullVersionString
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 FullVersionString method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf3\b0\strike\fs20 TZipMaster\cf4\strike0\{linkID=350\}\cf2  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  FullVersionString: \b String\b0 ;
\par \f0 
\par \pard\sa195\tx355\b\fs22 Description\f2\fs24 
\par \pard\tx355\b0\f3\fs20 Returns the full version information of the ZipMaster component and the dll if it is loaded.
\par This includes the version numbers.\f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
3120
Scribble3120
GetAddPassword method
GetAddPassword;GetAddPassword,TZipMaster;TZipMaster,GetAddPassword;


ZipMstr20:001985
Writing


TZipMaster_GetAddPassword;GetAddPassword_Method;GetAddPassword
FALSE
25
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fswiss Arial;}{\f3\fnil Courier New;}{\f4\fnil\fcharset0 Times New Roman;}{\f5\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 GetAddPassword method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3130\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3140\}\f1         \cf2\ul\f2\fs18 Note on passwords:\ulnone\{linkID=1560\}\cf4\f0\fs16\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f3\fs20 function\b0  GetAddPassword: \b String\b0 ;\b\f0\fs22 
\par \f3\fs20 function\b0  GetAddPassword(\b var\b0  Response: TmsgDlgBtn): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f4\fs24\tab\cf4\f2\fs20 
\par \pard\sa195\tx355\cf0 The GetAddPassword method will ask the user for a password used while adding files.\b\fs24 
\par \pard\tx355\b0\fs20 Prompt user for a password. The password will be asked twice - the second time to verify it.  
\par If both of them match, it will be saved in the \cf2\strike Password\strike0\{linkID=1530\}\cf0  property and it will also be returned as result, or else the Password property will not change and the result is an empty string.
\par 
\par The use of this method is not required. If you want to make your own password prompt dialog box, you can just put the password into the password property yourself. Also, you can take the easiest route by leaving the password property blank, and letting the component prompt the user for the password.
\par 
\par \f5 The overloaded version also gives the user's response.
\par \f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3130
Scribble3130
GetAddPassword method - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike GetExtrPassword\cf3\strike0\{linkID=3160\}\cf0 
\par \cf2\strike GetPassword \cf3\strike0\{linkID=3190\}\cf0 
\par }
3140
Scribble3140
GetAddPassword method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 GetAddPassword method example
\par \cf0\b0 
\par 
\par }
3150
Scribble3150
GetEnumerator method
GetEnumerator;GetEnumerator,TZipMaster;TZipMaster,GetEnumerator;


zipmstr20:001995
Done


TZipMaster_GetEnumerator;GetEnumerator_Method;GetEnumerator
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 GetEnumerator method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf3\b0\strike\fs20 TZipMaster\cf4\strike0\{linkID=350\}\cf2  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  GetEnumerator: \cf3\strike TZipMasterEnumerator\cf4\strike0\{linkID=7330\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 D2007 and up only
\par Returns a copy of the enumerator\f0 
\par 
\par }
3160
Scribble3160
GetExtrPassword method
GetExtrPassword;GetExtrPassword,TZipMaster;TZipMaster,GetExtrPassword;


ZipMstr20:002000
Writing


TZipMaster_GetExtrPassword;GetExtrPassword_Method;GetExtrPassword
FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Times New Roman;}{\f2\fswiss Arial;}{\f3\fnil Courier New;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 GetExtrPassword method
\par \cf0\b0\fs16 
\par \cf2\ul See also\cf3\ulnone\{linkID=%3170\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3180\}\cf0\f1\fs24\tab\cf2\ul\f2\fs18 Note on passwords:\ulnone\{linkID=1560\}\cf4\f0\fs16\{keepn\}\cf0\b\fs22 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f3\fs20 function\b0  GetExtrPassword: \b String\b0 ;\b\f0\fs22 
\par \f3\fs20 function\b0  GetExtrPassword(\b var\b0  Response: TmsgDlgBtn): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\sa195\tx355\b0\f2\fs20 The GetExtrPassword method will ask the user for a password used while extracting files.\b\fs24 
\par \pard\tx355\b0\fs20 Prompt user for a password.  The password will only be asked once. It will be saved in the \cf2\strike Password\strike0\{linkID=1530\}\cf0  property and it will also be returned as result.
\par 
\par The use of this method is not required. If you want to make your own password prompt dialog box, you can just put the password into the password property yourself. Also, you can take the easiest route by leaving the password property blank, and letting the component prompt the user for the password.
\par 
\par \f4 The overloaded version also gives the user's response.
\par \f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
3170
Scribble3170
GetExtrPassword method - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0\f1 
\par \cf2\strike GetAddPassword\cf3\strike0\{linkID=3120\}\cf0 
\par \cf2\strike GetPassword\cf3\strike0\{linkID=3190\}\cf4\lang1033 
\par \cf0\lang3081\f0 
\par 
\par }
3180
Scribble3180
GetExtrPassword method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 GetExtrPassword method example
\par \cf0\b0 
\par 
\par }
3190
Scribble3190
GetPassword method
GetPassword;GetPassword,TZipMaster;TZipMaster,GetPassword;


ZipMstr20:002010
Writing


TZipMaster_GetPassword;GetPassword_Method;GetPassword
FALSE
28
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fnil Courier New;}{\f3\fswiss\fcharset0 Arial;}{\f4\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 GetPassword method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3200\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3210\}\cf2\f1\fs20\tab\ul\fs16 Note on passwords:\ulnone\{linkID=1560\}\cf4\f0\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 function\b0  GetPassword(\b const\b0  DialogCaption, MsgTxt: \b String\b0 ; pwb: TmsgDlgButtons; \b var\b0  ResultStr: \b String\b0 ): TmsgDlgBtn;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\b0\f1\fs20 Prompt the user for a password. The password will only be asked once. It will \b not\b0  automatically be saved in the \cf2\strike Password\strike0\{linkID=1530\}\cf0  property.
\par You can set the caption and message text of this password dialog yourself or get the language dependend text from the resource file like:
\par \pard\li275\sb55\sa55\tx275\i ZipMaster1.GetPassword( \f3 Zip\f1 LoadStr( PW_Caption ), \f3 Zip\f1 LoadStr( PW_MessageEnter ) + \f4 '\f1 : for file \f4 '\f1  + ForFile, NewPassword );
\par \i0 or
\par \i ZipMaster1.GetPassword( \f3 Zip\f1 LoadStr( PW_Caption ), \f3 Zip\f1 LoadStr( PW_MessageVerify ), NewPassword );
\par \pard\tx275\i0 pwButtons is a set of buttons indicating the buttons that will be shown in the password dialog.
\par Possible values are: pwbOk, pwbCancel, pwbCancelAll and pwbAbort. Default and always present is: pwbOk.
\par 
\par The return value of this method is set to the button pressed and ResultStr is set to the password the user entered.
\par The button text on this dialog is taken from the chosen resource file and as such language dependent.
\par 
\par You can use this method in the \cf2\strike OnPasswordError\strike0\{linkID=3990\}\cf0  event to get a new or different password from the user.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3200
Scribble3200
GetPassword method - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 GetExtrPassword\cf3\strike0\{linkID=3160\}\cf0 
\par \cf2\strike GetAddPassword\cf3\strike0\{linkID=3120\}\cf4\lang1033 
\par \cf0\lang3081\f0 
\par 
\par }
3210
Scribble3210
GetPassword method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 GetPassword method example
\par \cf0\b0 
\par 
\par }
3220
Scribble3220
IndexOf method
IndexOf;IndexOf,TZipMaster;TZipMaster,IndexOf;


ZipMstr20:002015
Writing


TZipMaster_IndexOf;IndexOf_Method;IndexOf
FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 IndexOf method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3230\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3240\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  IndexOf(\b const\b0  FName: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 returns the index of the first entry with FName.\f0 
\par 
\par }
3230
Scribble3230
IndexOf method - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Find\cf3\strike0\{linkID=3050\}\cf0\f0 
\par 
\par }
3240
Scribble3240
IndexOf method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 IndexOf method example
\par \cf0\b0 
\par 
\par }
3250
Scribble3250
IsZipSFX method
IsZipSFX;IsZipSFX,TZipMaster;TZipMaster,IsZipSFX;


ZipMstr20:002020
Writing


TZipMaster_IsZipSFX;IsZipSFX_Method;IsZipSFX
FALSE
28
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 IsZipSFX method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3260\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3270\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  IsZipSFX(\b const\b0  SFXExeName: \b String\b0 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Checks if a file is likely to be an SFX archive.
\par 
\par 
\par   Return value:
\par \pard\tx540\tab  0 = The specified file is not a SFX
\par  \tab  1 = might be stub of unknown type
\par   \tab 17 =  found 1.7 SFX headers
\par   \tab 19 =  found 1.9 SFX headers 
\par \tab  >0 on errors
\par \tab  -7  = Open, read or seek error
\par \tab  -8  = memory error
\par \tab  -9  = exception error
\par \tab  -10 = all other exceptions
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3260
Scribble3260
IsZipSFX method - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 QueryZip\cf3\strike0\{linkID=5840\}\cf0 
\par \cf2\strike CheckSFXType\cf3\strike0\{linkID=5550\}\cf0\f0 
\par 
\par }
3270
Scribble3270
IsZipSFX method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 IsZipSFX method example
\par \cf0\b0 
\par 
\par }
3280
Scribble3280
List method
List;List,TZipMaster;TZipMaster,List;


ZipMstr20:002025
Writing


TZipMaster_List;List_Method;List
FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 List method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3290\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3300\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  List: Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\cf4\b0\f2\fs20 
\par \cf0 The List method will read the Zip archive and refresh the contents list.
\par 
\par \cf4  This is a manual "refresh" of the "Table of Contents".  This occurs automatically whenever a filename is assigned to \cf2\strike ZipFileName\cf3\strike0\{linkID=2410\}\cf4 .\cf0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par \f3 Returns 0 on success otherwise an \cf2\strike ErrCode\cf3\strike0\{linkID=940\}.
\par \pard\cf0\f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3290
Scribble3290
List method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of List method >>>
\par 
\par }
3300
Scribble3300
List method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 List method example
\par \cf0\b0 
\par 
\par }
3310
Scribble3310
MakeTempFileName method
MakeTempFileName;MakeTempFileName,TZipMaster;TZipMaster,MakeTempFileName;


ZipMstr20:002030
Writing


TZipMaster_MakeTempFileName;MakeTempFileName_Method;MakeTempFileName
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 MakeTempFileName method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf3\b0\strike\fs20 TZipMaster\cf4\strike0\{linkID=350\}\cf2  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  MakeTempFileName(\b const\b0  Prefix, Extension: \b String\b0 ): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\sa195\b0\f2\fs20 The MakeTempFileName method constructs a filename of the form \f3 '\f2 C:\\....\\zipxxxx.zip\f3 '\f2  where xxxx is a unique number.\b\fs24 
\par \pard\b0\fs20 Prefix is per default: \f3 '\f2 zip\f3 '\f2  = and Extension is \f3 '\f2 .zip\f3 '\f2 .
\par MakeTempFileName constructs a temporarily filename, that on the moment of construction does not have an equivalent on disk. 
\par The actual file created on disk will be removed before returning the filename.
\par If the \cf3\strike TempDir\strike0\{linkID=2020\}\cf0  is defined then this path will be used to construct the filename else the TMP or TEMP environment variable will be used, if both TMP or TEMP are not defined then the current drive and directory will used as path.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
3320
Scribble3320
QueryZip method
QueryZip,TZipMaster;TZipMaster,QueryZip;


ZipMstr20:002035
Writing


TZipMaster_QueryZip;QueryZip_Method;QueryZip
FALSE
33
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 QueryZip method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3330\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3340\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  QueryZip(\b const\b0  FName: \f2 String\f1 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Tests for the existence of various parts of a zip file returning a positive bit mapped integer of values.
\par 
\par const                      // QueryZip return bit values and errors
\par \pard\tx280\tx1920\tx2760\tab zqbStartEXE     \tab = 1;     \tab // is EXE file may be SFX
\par \tab zqbStartLocal   \tab = 2;     \tab // normal zip file start
\par \tab zqbStartSpan    \tab = 4;     \tab // first part of span
\par \tab zqbStartCentral \tab = 8;     \tab // continuing Central Header
\par \tab zqbHasComment\tab = 16;\tab // comment length good (no junk at end)
\par \tab zqbHasLocal     \tab = 32;    \tab // first Central entry points to local header
\par \tab zqbHasCentral   \tab = 64;    \tab // Central entry where it should be
\par \tab zqbHasEOC       \tab = 128;   \tab // End of Central entry
\par \tab zqbHasLoc64     \tab = 256;   \tab // EOC64 locator entry
\par \tab zqbHasEOC64     \tab = 512;   \tab // Zip64 EOC
\par \tab zqbJunkAtEnd    \tab = 1024;  \tab // junk at end of zip
\par \tab zqbIsDiskZero   \tab = 2048;  \tab // is disk 0
\par 
\par \tab zqFieldError   \tab = -5;     \tab // bad field value
\par \tab zqFileError    \tab = -7;     \tab // file handling error
\par \tab zqGeneralError \tab = -9;     \tab // unspecified failure\f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 
\par }
3330
Scribble3330
QueryZip method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of QueryZip method >>>
\par 
\par }
3340
Scribble3340
QueryZip method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 QueryZip method example
\par \cf0\b0 
\par 
\par }
3350
Scribble3350
ReadSpan method
ReadSpan;ReadSpan,TZipMaster;TZipMaster,ReadSpan;


ZipMstr20:002040
Writing


TZipMaster_ReadSpan;ReadSpan_Method;ReadSpan
FALSE
30
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ReadSpan method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3360\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3370\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ReadSpan(\b const\b0  InFileName: \b String\b0 ; \b var\b0  OutFilePath: \b String\b0 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\b0\f2\fs20 The ReadSpan method reads a spanned zip archive file and writes it back as one zip file.
\par 
\par With ReadSpan it is possible to read a spanned archive from disk and reassemble it as one zip file.
\par \pard\sa15\tx355 The \f3 '\f2 InFileName\f3 '\f2  parameter can be either:
\par \pard\tx355 - The name of the zipfile on (floppy) disk.
\par - A file part on harddisk and should look like InFileNameXXX.zip where XXX is a number.
\par \pard\sb115\tx355 if \f3 '\f2 OutFilePath\f3 '\f2  does not contain a filename there will be one created for you in the form: Zipxxxx.zip. The exact name will be
\par \pard\tx355 returned to you in the same parameter.
\par 
\par The return value will be one the following:
\par \pard\fi-565\li565\tqr\tx425\tqr\tx565\tab 0\tab All Ok.
\par \tab -7\tab All known ReadSpan errors. See also: \cf2\strike Error and warning message\f4 s\strike0\f2\{linkID=300\}\cf0 
\par \tab -8\tab Memory allocation error. ( GE_NoMem )
\par \tab -9\tab General unknown ReadSpan error. ( DS_ErrorUnknown )
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3360
Scribble3360
ReadSpan method - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 WriteSpan\cf3\strike0\{linkID=3470\}\cf0\f0 
\par 
\par }
3370
Scribble3370
ReadSpan method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ReadSpan method example
\par \cf0\b0 
\par 
\par }
3380
Scribble3380
Rename method
Rename;Rename,TZipMaster;TZipMaster,Rename;


ZipMstr20:002045
Done


TZipMaster_Rename;Rename_Method;Rename
FALSE
58
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}{\f4\fnil\fcharset0 Times New Roman;}{\f5\fswiss\fcharset0 Arial;}{\f6\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Rename method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3390\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3400\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  Rename(RenameList: TList; DateTime: Integer; How: TZMRenameOpts = htrDefault): Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\cf4\b0\f2\fs20 
\par \cf0 With the Rename method you can rename a filename and/or path to a different one.
\par 
\par With Rename it is possible to change the filename(s) and/or path(\f3 '\f2 s) to other name(s) and/or path(\f3 '\f2 s).
\par -The \f3 '\f2 RenameList\f3 '\f2  parameter is\f4\fs24  a TList\f2\fs20  filled with Z\f5 M\f2 Rename records:
\par \pard\tx275\tab\b Type\b0  \f5 T\f2 Z\f5 M\f2 RenameRec = \b record\b0 
\par \pard\tx565\tx1835\tx2835\tab Source:\tab\b String\b0 ;\tab\cf5 // The Source filename/path as present in the ziparchive.
\par \cf0\tab Dest:\tab\b String\b0 ;\tab\cf5 // The Destination filename/path, this will be the new name.
\par \cf0\f5\tab Comment:\tab\b String\b0 ;\tab\cf5 // A new comment for this entry\cf0\f2 
\par \tab DateTime:\tab Integer;\tab\cf5 // A new Date/Time for this specific destination or 0.\cf0 
\par \pard\tx275\tab\b End\b0 ;
\par \tab\f5 PZM\f2 RenameRec = ^\f5 T\f2 Z\f5 M\f2 RenameRec;
\par 
\par When you specify a new DateTime then this has precedence over the global DateTime parameter.
\par Source and Dest can be a partial filename or path, and as such multiple entries in the archive could be renamed with a single entry in the RenameList.
\par 
\par \pard\fi-1555\li1555\tx1555\cf5\b WARNING:\tab\cf0\b0 There is virtual\f5 ly\f2  no check on the destination specified.
\par \tab This means that if you are not careful you can get multiple names or even wrong names that can\f3 '\f2 t be extracted anymore.
\par \pard\tx1555 
\par -The DateTime parameter can be used to change the Date and Time of every entry in the zip archive.
\par If you do not want to change the Date/Time field set this parameter to 0.
\par \i Example:
\par \pard\fi-565\li565\tx565\tab DateTime := DateTimeToFileDate( StrToDateTime( \f3 '\f2 12-21-\f5 2009\f2  21:05:10\f3 '\f2  ) );
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\i0\f0 
\par \f6 Returns 0 on success otherwise an \cf2\strike Error Code\cf3\strike0\{linkID=300\}.
\par \cf0\f0 
\par  In case of error Rename will return the error value, the meaning of these values can be found in \cf2\strike Error and warning messages\cf3\strike0\{linkID=300\}\cf0 
\par  This returned error values are indicators that there are errors reported, the correct error has to be looked up in the FSpecArgsExcl objects for each file 
\par 
\par \cf6 Path Names\cf0 
\par When during the Rename action the pathnames has to be kept the AddOptions \cf2\strike AddDirNames\cf3\strike0\{linkTarget=adddirnames\}\f6  \cf0\f0 has to be set before starting the Rename action.
\par \i Example:
\par     \f6 zip.\f0 AddOptions = AddOptions \f6 +\f0  \f6 [\f0 AddDirNames\f6 ]\f0 ;
\par \i0     
\par If this option is NOT set Rename will remove the Path names in the archive.
\par 
\par \cf6\f6 Comments\cf0\f0 
\par Setting a file comment:
\par     If no\f6 t\f0  renaming then either set Dest = \f6 '\f0 |\f6 '\f0  or Dest = Source
\par     To add/replace a file comment assign a non-empty string.
\par     To delete a file comment assign the string \f6 #0\f0  (RenRec\f6 .\f0 Comment = \f6 #0\f0 ;)
\par 
\par \cf6 Errors and skipped files during Rename:\cf0 
\par     When a file is skipped in a rename action because some problem is found an \cf2\strike OnSkipped\cf3\strike0\{linkID=4140\}\cf0\f6  \f0 event is fired.
\par 
\par }
3390
Scribble3390
Rename method - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ChangeFileDetails\cf3\strike0\{linkID=2680>main\}\cf0\f0 
\par 
\par }
3400
Scribble3400
Rename method - Example




Done



FALSE
40
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Rename method example
\par \cf0\b0 
\par \pard\tx275\i\f1 Example:
\par \pard\fi-275\li275\tx275\b\tab Var
\par \pard\fi-275\li275\tx275\tx565\tx2545\b0\tab\tab ZipRenameList:\tab TList;
\par \tab\tab RenRec:\tab\f2 PZip\f1 RenameRec;
\par \f2\tab\tab Err:\tab Integer;
\par \tab\tab i:\tab Integer;
\par \tab\tab FileErr:\tab Integer;
\par \tab\tab BadFile:\tab String;
\par \tab\tab FileErrMsg:\tab String;\f1 
\par \pard\fi-275\li275\tx275\b\tab Begin
\par \pard\fi-565\li565\tx565\tx2545\b0\tab ZipRenameList\tab := TList.Create( );
\par \tab New( RenRec );
\par \tab RenRec^.Source\tab := SourceName;
\par \tab RenRec^.Dest\tab := DestName;
\par \tab RenRec^.DateTime\tab := DateTimeToFileDate( StrToDateTime( \f3 '\f1 12-21-1998 21:06:12\f3 '\f1  ) );
\par \pard\fi-565\li565\tx565\tab ZipRenameList.Add( RenRec );
\par 
\par \tab\f2 Err := \f1 ZipMaster1.Rename( ZipRenameList, 0 );
\par \tab Dispose( RenRec );
\par \tab ZipRenameList.Free( );
\par \f2\tab if Err then     \cf2\i0 // there are errors\cf0\i 
\par \tab begin          \cf2\i0 // read them\cf0\i 
\par \tab     For i := 0 to Pred(ZipMaster1.FSpecArgsExcl.Count) do
\par \tab     begin
\par \tab         \cf2\i0 // get the name of the file\cf0\i 
\par \tab         BadFile := ZipMaster1.FSpecArgsExcl[i];
\par \tab         \cf2\i0 // get the error number for that file\cf0\i 
\par \tab         FileErr :=  Integer(Pointer(ZipMaster1.FSpecArgsExcl.Objects[i]));
\par \tab         \cf2\i0 // get the message for that error\cf0\i 
\par \tab         FileErrMsg :=  ZipLoadStr(FileErr);
\par \tab     end;
\par \tab end;\f1 
\par \pard\fi-275\li275\tx275\b\tab End\b0 ;
\par \pard\tx275\i0 
\par \pard\f0 
\par }
3410
Scribble3410
TheErrorCode method
TheErrorCode;TheErrorCode,TZipMaster;TZipMaster,TheErrorCode;


ZipMstr20:002050
Writing


TZipMaster_TheErrorCode;TheErrorCode_Method;TheErrorCode
FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TheErrorCode method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3420\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3430\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  TheErrorCode(errCode: Integer): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Strips off the ZMReentry_Error, returns the actual error\f0 
\par 
\par }
3420
Scribble3420
TheErrorCode method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TheErrorCode method >>>
\par 
\par }
3430
Scribble3430
TheErrorCode method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 TheErrorCode method example
\par \cf0\b0 
\par 
\par }
3440
Scribble3440
Undeflate method
TZipMaster,Undeflate;Undeflate;Undeflate,TZipMaster;


ZipMstr20:002055
Done


TZipMaster_Undeflate;Undeflate_Method;Undeflate
FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Undeflate method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3450\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3460\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  Undeflate(OutStream, InStream: TStream; Length: Int64; \b var\b0  Method: \cf2\strike\f2 TZMDeflates\cf3\strike0\{linkID=4644\}\cf0\f1 ; \b var\b0  CRC: Cardinal): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 De-compress InStream to OutStream, set method and CRC on success.
\par 
\par If encryption was used on Entry CRC must be set to the value given by \cf2\strike Deflate\cf3\strike0\{linkID=2870\}\cf0 
\par \f0 
\par \f3 Returns 0 on success otherwise an \cf2\strike ErrCode\cf3\strike0\{linkID=940\}.\cf0\f0 
\par \f3  \f0 
\par 
\par 
\par }
3450
Scribble3450
Undeflate method - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Deflate\cf3\strike0\{linkID=2870\}\cf0\f0 
\par 
\par }
3460
Scribble3460
Undeflate method - Example




Done



FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Undeflate method example
\par \cf0\b0 
\par 
\par   instream := TFileStream.Create(\f1 'deflated.bin'\f0 , fmOpenRead);
\par   try
\par     outstream := TFileStream.Create('zb.tmp', fmCreate);
\par     try
\par       method := zmStore;
\par       crc := 0;
\par       Result := z\f1 ip\f0 .Undeflate(outstream, instream, -1, method, crc);
\par       
\par       Display('size = ' + IntToStr(outstream.Size) + '  posn = ' + IntToStr
\par           (outstream.Position) + '  method = ' + crc = ' + IntToHex(crc, 4));
\par       if z.SuccessCnt = 1 then
\par       begin
\par         Display('success');
\par       end;
\par     finally
\par       outstream.Free;
\par     end;
\par   finally
\par     instream.Free;
\par   end;
\par \f1   if Result <> 0 then
\par      handle_error!\f0 
\par 
\par }
3470
Scribble3470
WriteSpan method
TZipMaster,WriteSpan;WriteSpan;WriteSpan,TZipMaster;


ZipMstr20:002060
Writing


TZipMaster_WriteSpan;WriteSpan_Method;WriteSpan
FALSE
31
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 WriteSpan method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3480\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3490\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  WriteSpan(\b const\b0  InFileName, OutFileName: \b String\b0 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \pard\tx355\b0\f2\fs20 The WriteSpan method can be used to copy an existing zip archive file to one or more disks as a spanned archive.
\par 
\par With WriteSpan it is possible to make a spanned archive on (floppy) disk from a standard zip file.
\par InFileName is the name of the zipfile that must be converted.
\par OutFileName is the drive, path(optional) and file name of the destination file.
\par \pard\sb115\tx355 
\par \pard\fi-845\li845\tx845\cf5\b NOTE:\cf0\b0\tab If \f3 '\f2 OutFileName\f3 '\f2  is on a fixed disk the input file will be split into parts with size \cf2\strike MaxVolumeSize\strike0\{linkID=1380\}\cf0\fs16  \fs20 A file part on harddisk will look like: OutFileNameXXX.zip where XXX is a number.
\par It is possible to copy the files \cf2\ul to diskette\ulnone\{linkID=260\}\cf0  when the filesize is <= diskette size.
\par or to \cf2\strike reassemble them\cf3\strike0\{linkTarget=ReasMult>main\}\cf0  without diskettes after sending them over the internet for use with pkzip or winzip.
\par \pard\tx845 
\par The return value will be one the following:
\par \pard\fi-565\li565\tqr\tx425\tqr\tx565\tab 0\tab All Ok.
\par \tab  -7\tab All known WriteSpan errors. See also: \cf2\strike Error and warning message\f4 s\strike0\f2\{linkID=300\}\cf0 
\par \tab -8\tab Memory allocation error. ( GE_NoMem )
\par \tab -9\tab General unknown WriteSpan error. ( DS_ErrorUnknown )
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3480
Scribble3480
WriteSpan method - See also




Done



FALSE
12
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ReadSpan\cf3\strike0\{linkID=3350\}\cf0 
\par \cf2\strike MaxVolumeSize\cf3\strike0\{linkID=1380\}\cf0 
\par \cf2\strike KeepFreeOnDisk1\cf3\strike0\{linkID=1290\}\cf0 
\par \cf2\strike MinFreeVolumeSize \cf3\strike0\{linkID=1440\}\cf0 
\par \cf2\strike Handling of Multi Volume Zip parts\cf3\strike0\{linkID=260\}\cf0 
\par \f0 
\par 
\par }
3490
Scribble3490
WriteSpan method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 WriteSpan method example
\par \cf0\b0 
\par 
\par }
3510
Scribble3510
ZipLoadStr method
TZipMaster,ZipLoadStr;ZipLoadStr;ZipLoadStr,TZipMaster;


ZipMstr20:002065
Writing


TZipMaster_ZipLoadStr;ZipLoadStr_Method;ZipLoadStr
FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ZipLoadStr method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3520\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3530\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ZipLoadStr(Id: Integer): \b string\f2 ;\b0\f1 
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Returns the message for the given Id.\f0 
\par 
\par }
3520
Scribble3520
ZipLoadStr method - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnLoadStr\cf3\strike0\{linkID=4265\}\cf0 
\par \cf2\strike Language\cf3\strike0\{linkID=1320\}\cf0 
\par \cf2\strike LanguageInfo\cf3\strike0\{linkID=1350\}\cf0\f0 
\par 
\par }
3530
Scribble3530
ZipLoadStr method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ZipLoadStr method example
\par \cf0\b0 
\par 
\par }
3540
Scribble3540
AbortDLL method
AbortDLL;AbortDLL,TZipMaster;TZipMaster,AbortDLL;


ZipMstr20:002070
Writing


TZipMaster_AbortDLL;AbortDLL_Method;AbortDLL
FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AbortDLL method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3550\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3560\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 procedure\b0  AbortDLL;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Forces the current DLL operation to abort.\f0 
\par 
\par }
3550
Scribble3550
AbortDLL method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of AbortDLL method >>>
\par 
\par }
3560
Scribble3560
AbortDLL method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 AbortDLL method example
\par \cf0\b0 
\par 
\par }
3570
Scribble3570
Clear method
Clear;Clear,TZipMaster;TZipMaster,Clear;


ZipMstr20:002075
Writing


TZipMaster_Clear;Clear_Method;Clear
FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Clear method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3580\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3590\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 procedure\b0  Clear;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Clears internal strings, entries and settings back to default.\f0 
\par 
\par }
3580
Scribble3580
Clear method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of Clear method >>>
\par 
\par }
3590
Scribble3590
Clear method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Clear method example
\par \cf0\b0 
\par 
\par }
3600
Scribble3600
ShowExceptionError method
ShowExceptionError;ShowExceptionError,TZipMaster;TZipMaster,ShowExceptionError;


ZipMstr20:002080
Writing


TZipMaster_ShowExceptionError;ShowExceptionError_Method;ShowExceptionError
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ShowExceptionError method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3610\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3620\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 procedure\b0  ShowExceptionError(\b const\b0  ZMExcept: EZipMaster);
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 If Unattended is True, sends the exception message through the \cf2\strike OnMessage\cf3\strike0\{linkID=3930\}\cf0  event, otherwise it is displayed in a MessageBox.
\par 
\par EZipMaster, derived from Exception, is used for exceptions throughout the component code.\f0 
\par 
\par }
3610
Scribble3610
ShowExceptionError method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ShowExceptionError method >>>
\par 
\par }
3620
Scribble3620
ShowExceptionError method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ShowExceptionError method example
\par \cf0\b0 
\par 
\par }
3630
Scribble3630
ShowZipFmtMessage method
ShowZipFmtMessage;ShowZipFmtMessage,TZipMaster;TZipMaster,ShowZipFmtMessage;


ZipMstr20:002085
Writing


TZipMaster_ShowZipFmtMessage;ShowZipFmtMessage_Method;ShowZipFmtMessage
FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ShowZipFmtMessage method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3640\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3650\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 procedure\b0  ShowZipFmtMessage(Id: Integer; \b const\b0  Args: \b array\b0  \b of\b0  \b const\b0 );
\par \f0 
\par \b\fs22 Description
\par \pard\cf4\b0\f2\fs20 
\par \pard\sa195\tx355\cf0 The ShowZipMessage method reads a message identified by Ident from the program resource table\f3 , formats it\f2  and displays it.\b\fs24 
\par \pard\tx355\b0\fs20 All component messages, errors and warnings are as of version 1.5 contained in a resource message table. 
\par To make it easier to also use them in your own program this function is included.
\par It reads the message with identifier \f4 '\f2 Ident\f4 '\f2  from the resource table, \f3 formats using 'Args'\f2  and displays the message.
\par If the identifier is not present, for example because you did not include the resource file in your project, the message displayed will be: \f4 "\f2 ZipMsg.res probably not linked to the executable. Missing String ID is: xxxx\f4 "\f2 
\par To resolve this you must put the statement \{\-$R YourPath\\ZipMsgxx.res\}; in your main unit file. Where xx is your language ID. (Available at the moment: US English, NL Dutch.)
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3640
Scribble3640
ShowZipFmtMessage method - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ErrMessage\cf3\strike0\{linkID=970\}\cf0 
\par \cf2\strike OnMessage\cf3\strike0\{linkID=3930\}\cf4\lang1033 
\par \cf2\lang3081\strike ShowZipMessage\cf3\strike0\{linkID=3660\}\cf0\f0 
\par 
\par }
3650
Scribble3650
ShowZipFmtMessage method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ShowZipFmtMessage method example
\par \cf0\b0 
\par 
\par }
3660
Scribble3660
ShowZipMessage method
ShowZipMessage;ShowZipMessage,TZipMaster;TZipMaster,ShowZipMessage;


ZipMstr20:002090
Writing


TZipMaster_ShowZipMessage;ShowZipMessage_Method;ShowZipMessage
FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ShowZipMessage method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3670\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3680\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 procedure\b0  ShowZipMessage(Ident: Integer; \b const\b0  UserStr: \b String\b0 );
\par \f0 
\par \b\fs22 Description
\par \pard\cf4\b0\f2\fs20 
\par \pard\tx355\cf0 The ShowZipMessage method reads a message identified by Ident from the program resource table and displays it.
\par 
\par All component messages, errors and warnings are as of version 1.5 contained in a resource message table. To make it easier to also use them in your own program this function is included.
\par It reads the message with identifier \f3 '\f2 Ident\f3 '\f2  from the resource table, appends the optional \f3 '\f2 UserStr\f3 '\f2  to it and displays the message.
\par If the identifier is not present, for example because you did not include the resource file in your project, the message displayed will be: \f3 "\f2 ZipMsg.res probably not linked to the executable. Missing String ID is: xxxx\f3 "\f2 
\par To resolve this you must put the statement \{\-$R YourPath\\ZipMsgxx.res\}; in your main unit file. Where xx is your language ID. (Available at the moment: US English, NL Dutch.)
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3670
Scribble3670
ShowZipMessage method - See also




Done



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ErrMessage\cf3\strike0\{linkID=970\}\cf0 
\par \cf2\strike OnMessage\cf3\strike0\{linkID=3930\}\cf4\lang1033 
\par \cf2\lang3081\strike ShowZipFmtMessage\cf3\strike0\{linkID=3630\}\cf0 
\par \f0 
\par 
\par }
3680
Scribble3680
ShowZipMessage method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ShowZipMessage method example
\par \cf0\b0 
\par 
\par }
3690
Scribble3690
OnCheckTerminate event
OnCheckTerminate;OnCheckTerminate,TZipMaster;TZipMaster,OnCheckTerminate;


ZipMstr20:002095
Writing


TZipMaster_OnCheckTerminate;OnCheckTerminate_Event;OnCheckTerminate
FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnCheckTerminate event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3700\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3710\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  OnCheckTerminate: \cf2\strike TZMCheckTerminateEvent\cf3\strike0\{linkID=4570\}\cf0 ;
\par \pard\cf4\f2 
\par \b Type\b0 
\par     TCheckTerminateEvent = Procedure(Sender: TObject; Var abort: boolean) Of Object;
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\f0 
\par \b\fs22 Description
\par \pard\cf4\b0\f2\fs20  used for Multi-threaded applications
\par 
\par Stops \cf0 message processing \cf4 from calling ProcessMessages (not allowed outside main thread).
\par 
\par Allows checking for Terminate
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\f0 
\par }
3700
Scribble3700
OnCheckTerminate event - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of OnCheckTerminate event >>>
\par 
\par }
3710
Scribble3710
OnCheckTerminate event - Example




Writing



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnCheckTerminate event example
\par \cf0\b0 
\par 
\par 
\par // stops calls to ProcessMessages & checks for Terminated
\par procedure TZipThread.CheckTerminate(Sender: TObject; var stop: boolean);
\par begin
\par \tab if Terminated then
\par \tab\tab stop := true;
\par end;
\par }
3720
Scribble3720
OnCopyZippedOverwrite event
OnCopyZippedOverwrite;OnCopyZippedOverwrite,TZipMaster;TZipMaster,OnCopyZippedOverwrite;


ZipMstr20:002100
Writing


TZipMaster_OnCopyZippedOverwrite;OnCopyZippedOverwrite_Event;OnCopyZippedOverwrite
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnCopyZippedOverwrite event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3730\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3740\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  OnCopyZippedOverwrite: \cf2\strike TZMCopyZippedOverwriteEvent\cf3\strike0\{linkID=4610\}\cf0 ;
\par \f0 
\par \b\f2\fs24 Type\b0\f0\fs20 
\par   TZMCopyZippedOverwriteEvent = procedure(Sender: TObject; src, dst: \cf2\strike TZ\f2 M\f0 DirEntry\cf3\strike0\{linkID=6340\}\cf0 ; var DoOverwrite: Boolean) of object;
\par 
\par \b\fs22 Description
\par \pard\tx165\tx425\b0\f3\fs20 O\f4 ccurs when during the execution of the function \cf2\strike CopyZippedFiles\strike0\{linkID=2840\}\cf0\f3  or \cf2\strike AddZippedFiles\cf3\strike0\f4\{linkID=2620\}\f3  \cf0\f4 it is necessary to know if a file in the destination archive may be overwritten. It is possible that the event does NOT occur because you have let the function CopyZippedFiles know that it is always or never Ok to overwrite.
\par You can choose to overwrite the file \f3 dst.\cf2\strike\f0 FileName\cf3\strike0\{linkID=6760\}\cf0\f4  by setting DoOverwrite to \b True\b0 . The default for DoOverwrite is \b False\b0 .
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3730
Scribble3730
OnCopyZippedOverwrite event - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 CopyZippedFiles\strike0\{linkID=2840\}
\par \strike\f2 AddZippedFiles\f1  \cf3\strike0\{linkID=2620\}\cf0\f0 
\par 
\par }
3740
Scribble3740
OnCopyZippedOverwrite event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnCopyZippedOverwrite event example
\par \cf0\b0 
\par 
\par }
3750
Scribble3750
OnCRC32Error event
OnCRC32Error;OnCRC32Error,TZipMaster;TZipMaster,OnCRC32Error;


ZipMstr20:002105
Writing


TZipMaster_OnCRC32Error;OnCRC32Error_Event;OnCRC32Error
FALSE
25
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnCRC32Error event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6100\}\tab\cf2\strike Example\cf3\strike0\{linkID=%5080\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  OnCRC32Error: \cf2\strike TZMCRC32ErrorEvent\cf3\strike0\{linkID=4610\}\cf0 ;
\par \pard\sb35\tx165\tx425\f2 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\b Type 
\par \f3    \b0\f2 T\f3 ZM\f2 CRC32ErrorEvent = \b Procedure\b0 ( Sender: \f4\fs24 TObject\f2\fs20 ; ForFile: \cf2\b\strike TZMString\cf3\strike0\{linkID=5280\}\cf0\b0 ; FoundCRC, ExpectedCRC: LongWord; \b var\b0  DoExtract: Boolean ) \b of object\b0 ; 
\par \f0 
\par \b\fs22 Description
\par \pard\sb115\b0\f2\fs20 OnCRC32Error event occurs when a CRC error is found while extracting.
\par \pard\sb115\sa115\tx165\tx425\b property\b0  OnCRC32Error: TCRC32ErrorEvent;
\par \pard\sa195\tx165\tx425\b\fs24 Description:
\par \pard\tx165\tx425\b0\fs20 Occurs when during an \cf2\strike Extract\strike0\{linkID=2960\}\cf0  a CRC error is found in the file ForFile.
\par FoundCRC is the calculated CRC and ExpectedCRC is the CRC as stored in the zip archive these two values are for your information only.
\par You can choose to skip the extraction of the file by setting DoExtract to False. The default for DoExtract is True because that was the case in previous versions of ZipMaster where you could not choose.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3760
Scribble3760
OnCRC32Error event - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of OnCRC32Error event >>>
\par 
\par }
3770
Scribble3770
OnCRC32Error event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnCRC32Error event example
\par \cf0\b0 
\par 
\par }
3780
Scribble3780
OnDirUpdate event
OnDirUpdate;OnDirUpdate,TZipMaster;TZipMaster,OnDirUpdate;


ZipMstr20:002110
Writing


TZipMaster_OnDirUpdate;OnDirUpdate_Event;OnDirUpdate
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnDirUpdate event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6100\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7100\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  OnDirUpdate: TNotifyEvent;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f2\fs20 OnDirUpdate event occurs when ZipMaster has refreshed the contents list.
\par 
\par Occurs immediately after ZipMaster re\f3 ads the central directory\f2 . 
\par This is your queue to update the screen with the new contents.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
3790
Scribble3790
OnDirUpdate event - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of OnDirUpdate event >>>
\par 
\par }
3800
Scribble3800
OnDirUpdate event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnDirUpdate event example
\par \cf0\b0 
\par 
\par }
3810
Scribble3810
OnExtractOverwrite event
OnExtractOverwrite;OnExtractOverwrite,TZipMaster;TZipMaster,OnExtractOverwrite;


ZipMstr20:002115
Writing


TZipMaster_OnExtractOverwrite;OnExtractOverwrite_Event;OnExtractOverwrite
FALSE
25
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnExtractOverwrite event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4390\}\tab\cf2\strike Example\cf3\strike0\{linkID=%4490\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  OnExtractOverwrite: \cf2\strike TZMExtractOverwriteEvent\cf3\strike0\{linkID=4720\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\sb35\sa55\tx165\tx425\b0\f2\fs20 OnExtractOverwrite event occurs when during an Extract a file could be overwritten.
\par \pard\sb115\b Type
\par \b0  TZMExtractOverwriteEvent = procedure(Sender: TObject; const ForFile: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ; IsOlder: Boolean; var DoOverwrite: Boolean; DirIndex: Integer) of object;
\par \pard\sa195\tx165\tx425\b\fs24 
\par Description:
\par \pard\tx165\tx425\b0\fs20 ForFile the name of the file that will be overwritten.
\par IsOlder indicates if the existing file, on disk, is older.
\par DoOverwrite can be set to \b True\b0  when you want the file to be overwritten.\cf4 
\par \cf0 DirIndex is the index of ForFile in\f3  the internal\f2  list. With this you have full access to all available archive file information for this file.\cf4 
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\f0 
\par 
\par }
3820
Scribble3820
OnExtractOverwrite event - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of OnExtractOverwrite event >>>
\par 
\par }
3830
Scribble3830
OnExtractOverwrite event - Example




Writing



FALSE
28
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red255\green0\blue0;\red0\green0\blue128;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnExtractOverwrite event example
\par \pard\tx165\tx425\cf2\b0\f1 
\par \i Example:
\par \pard\tx275\cf0\b Var
\par \pard\tx275\tx1125\b0\tab q:\tab String;
\par \tab res:\tab Integer;
\par \tab DefBtn:\tab Cardinal;
\par \pard\tx275\b Begin
\par \b0\tab\b If\b0  \b NOT\b0  IsOlder \b Then\b0   \cf3  // Only when existing file is newer(or equal) we will ask what to do.\cf0 
\par \tab\b Begin
\par \b0\tab q := '\cf4 Do you want to overwrite the file:\cf0 '#13#10 + ForFile;
\par \pard\tx275\tx565\tab\b If\b0  DoOverwrite = True \b Then\b0 
\par \tab\tab DefBtn := MB_DEFBUTTON1
\par \tab\b Else
\par \b0\tab\tab DefBtn := MB_DEFBUTTON2;
\par \pard\tx275\tab res := MessageBox( Self.Handle, pChar( q ), 'Confirm', MB_YESNO \b or\b0  MB_ICONQUESTION \b or\b0  DefBtn );
\par \pard\tx275\tx565\tab\b If\b0  res = ID_YES \b Then\b0 
\par \tab\tab DoOverwrite := True
\par \tab\b Else
\par \b0\tab\tab DoOverwrite := False;
\par \pard\tx275\tab\b End
\par End\b0 ;
\par 
\par \pard\i0\f0 
\par 
\par }
3840
Scribble3840
OnFileComment event
OnFileComment;OnFileComment,TZipMaster;TZipMaster,OnFileComment;


ZipMstr20:002120
Writing


TZipMaster_OnFileComment;OnFileComment_Event;OnFileComment
FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnFileComment event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4700\}\tab\cf2\strike Example\cf3\strike0\{linkID=%4800\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  OnFileComment: \cf2\strike TZMFileCommentEvent\cf3\strike0\{linkID=4780\}\cf0 ;
\par \pard\sb115\b\f2 Type
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f3  \b0\f2  T\f3 ZM\f2 FileCommentEvent = \b procedure\b0 ( Sender:\f4\fs24  TObject; ForFile: \f2\fs20  \cf2\strike\f3 TZMString\cf3\strike0\f2\{linkID=5280\}\cf0 , \b var\b0  FileComment:  \cf2\strike\f3 TZMString\cf3\strike0\f2\{linkID=5280\}\cf0 , \b var\b0  IsChanged: Boolean ) \b of object\b0 ; 
\par \f0 
\par \b\fs22 Description
\par \pard\sb35\sa55\tx165\tx425\b0\f2\fs20 OnFileComment event occurs when writing the central directory of the zip archive for every file in the archive.
\par \pard\tx165\tx425 
\par ForFile is the filename for which the filecomment could be set.
\par FileComment is set to the first 255 characters of the old filecomment when present and can be set to a new comment, with a maximum of 511 characters, for the file, remember filecomments are not zipped and are stored as given.
\par IsChanged must be set to \b True\b0  when you want the filecomment to be really set, default it is \b False\b0 .
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
3850
Scribble3850
OnFileComment event - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of OnFileComment event >>>
\par 
\par }
3860
Scribble3860
OnFileComment event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnFileComment event example
\par \cf0\b0 
\par 
\par }
3870
Scribble3870
OnFileExtra event
OnFileExtra;OnFileExtra,TZipMaster;TZipMaster,OnFileExtra;


ZipMstr20:002125
Writing


TZipMaster_OnFileExtra;OnFileExtra_Event;OnFileExtra
FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnFileExtra event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4980\}\tab\cf2\strike Example\cf3\strike0\{linkID=%5080\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par \f1 Type 
\par   TZMFileExtraEvent = procedure(Sender: TObject; const ForFile: \cf2\strike\f2 TZMString\cf3\strike0\{linkID=5280\}\cf4\f1 ;
\par     \tab var Data: \cf2\strike TZMRawBytes\cf3\strike0\{linkID=5275\}\cf4 ; var IsChanged: Boolean) of object;\f0 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  OnFileExtra: \cf2\strike TZMFileExtraEvent\cf3\strike0\{linkID=4800\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 ForFile is the name of file to formatted extra data.
\par Data is the data to be set.
\par 
\par Note: This is dangerous to do unless you are careful.
\par \f0 
\par 
\par }
3880
Scribble3880
OnFileExtra event - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of OnFileExtra event >>>
\par 
\par }
3890
Scribble3890
OnFileExtra event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnFileExtra event example
\par \cf0\b0 
\par 
\par }
3900
Scribble3900
OnGetNextDisk event
OnGetNextDisk;OnGetNextDisk,TZipMaster;TZipMaster,OnGetNextDisk;


ZipMstr20:002130
Writing


TZipMaster_OnGetNextDisk;OnGetNextDisk_Event;OnGetNextDisk
FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fnil\fcharset0 Times New Roman;}{\f4\fnil Courier New;}{\f5\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnGetNextDisk event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3910\}\tab\cf2\strike Example\cf3\strike0\{linkID=%5310\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par \pard\sb35\sa55\tx165\tx425\cf0\f1 OnGetNextDisk event occurs when a disk is needed during disk spanning.
\par \pard\sb115\b Type\b0  T\f2 ZM\f1 GetNextDiskEvent = \b procedure\b0 ( Sender: \f3\fs24 TObject;\f1\fs20  DiskSeqNo, DiskTotal: Integer; Drive: \b String\b0 , \b var\b0  Cancel: Boolean ) \b of object\b0 ; 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf4\f0 
\par \cf0\b\fs22 Declaration
\par \f4\fs20 property\b0  OnGetNextDisk: \cf2\strike TZMGetNextDiskEvent\cf3\strike0\{linkID=4820\}\cf0 ;
\par \f0 
\par \pard\sa195\tx165\tx425\b\fs22 Description\f1\fs24 
\par \pard\tx165\tx425\b0\fs20 DiskSeqNo the sequence number of the disk needed or is zero when it concerns a diskspan read action.
\par DiskTotal the total number of needed disks. This is an estimate based on some known values or it is zero when the number could not be calculated.
\par Drive the drive name, e.g. \f5 '\f1 A:\f5 '\f1 .
\par Cancel, can be set to \b True\b0  to cancel the spanning operation, default \b False\b0 .
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
3910
Scribble3910
OnGetNextDisk event - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of OnGetNextDisk event >>>
\par 
\par }
3920
Scribble3920
OnGetNextDisk event - Example




Writing



FALSE
24
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnGetNextDisk event example
\par \cf0\b0 
\par \pard\tx165\tx425\i\f1 
\par \pard\tx275\b Var
\par \pard\tx845\b0 MsgStr:\tab String;
\par Res:\tab Integer;
\par \pard\tx275\b Begin
\par \cf2\b0 // Only while reading
\par \cf0\b If\b0  DiskSeqNo = 0 \b Then\b0 
\par \tab MsgStr := LoadStr( DS_InsertDisk );
\par 
\par \pard\tx275\tx1985\b If\b0  DiskTotal = 0 \b Then\b0\tab\cf2 // Total disks is not known\cf0 
\par \pard\tx275\tab MsgStr := Format( LoadStr( DS_InsertAVolume ), [ DiskSeqNo ] )
\par \b Else
\par \b0\tab MsgStr := Format( LoadStr( DS_InsertVolume ), [ DiskSeqNo, DiskTotal ] );
\par MsgStr := MsgStr + Format( LoadStr( DS_InDrive ), [ Drive ] );
\par 
\par Res := MessageBox( ZipMaster1.Handle, pChar( MsgStr ), \f2 '\f1 Confirm\f2 '\f1 , MB_YESNOCANCEL \b or\b0  MB_DEFBUTTON2 \b or\b0  MB_ICONWARNING );
\par \b If\b0  Res <> IDYES \b Then\b0  Cancel := \b True\b0 ;
\par \b End\b0 ;
\par \pard\i0\f0 
\par }
3930
Scribble3930
OnMessage event
OnMessage;OnMessage,TZipMaster;TZipMaster,OnMessage;


ZipMstr20:002135
Writing


TZipMaster_OnMessage;OnMessage_Event;OnMessage
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil\fcharset0 Times New Roman;}{\f3\fswiss Arial;}{\f4\fnil Courier New;}{\f5\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnMessage event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%\f1 394\f0 0\}\tab\cf2\strike Example\cf3\strike0\{linkID=%\f1 395\f0 0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par \pard\cf0\f2\fs24 
\par \pard\sb35 OnMessage event occurs when\f3\fs20  a DLL or the component sends a message to your program.
\par \pard\sb115\b Type\b0  \f4 TZMMessageEvent\f3 = \b procedure\b0 ( Sender: \f2\fs24 TObject; \f3\fs20 ErrCode: Integer; ErrMsg: \cf2\strike\f5 TZMS\f3 tring \cf3\strike0\{linkID=5280\}\cf0 ) \b of object\b0 ; 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf4\f0 
\par \cf0\b\fs22 Declaration
\par \f4\fs20 property\b0  OnMessage: \cf2\strike TZMMessageEvent\cf3\strike0\{linkID=4860\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 The ErrMsg argument passed by this event will contain the message.\f0 
\par \pard\tx355\f3  If an error code accompanies the message, it will be in the \cf2\strike ErrCode\strike0\{linkID=940\}\cf0  property.
\par  The \cf2\strike Verbose\strike0\{linkID=2230\}\cf0  and \cf2\strike Trace\strike0\{linkID=2080\}\cf0  properties have a direct influence on how many OnMessage events you will get.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par }
3940
Scribble3940
OnMessage event - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \pard\tx355\cf2\strike\f1 ErrCode\cf3\strike0\{linkID=940\}\cf0 
\par \pard\cf2\strike Verbose\cf3\strike0\{linkID=2230\}\cf0  
\par \cf2\strike Trace\cf3\strike0\{linkID=2080\}\cf0\f0 
\par 
\par }
3950
Scribble3950
OnMessage event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnMessage event example
\par \cf0\b0 
\par 
\par }
3960
Scribble3960
OnNewName event
OnNewName;OnNewName,TZipMaster;TZipMaster,OnNewName;


ZipMstr20:002140
Writing


TZipMaster_OnNewName;OnNewName_Event;OnNewName
FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnNewName event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%3970\}\tab\cf2\strike Example\cf3\strike0\{linkID=%3980\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \f1 The OnNewName event occurs when reading the zip central directory for each entry
\par \f0 
\par \f1 type
\par   TZMNewNameEvent = procedure(Sender: TObject; SeqNo: Integer) of object;
\par \f0 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  OnNewName: \cf2\strike TZMNewNameEvent\cf3\strike0\{linkID=4880\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f3\fs20 The event OnNewName occurs when reading the Zip's archive directory and gives you the opportunity to fill in for example a \f4\fs24 TListView\f3\fs20 . 
\par In previous versions you had to wait for the \cf2\strike OnDirUpdate\strike0\{linkID=3780\}\cf0  event.
\par SeqNo is a number from 1 to the number of entries in the zipfile and can be used to reset a ListView when the value is 1 and as sequence number in a \f4\fs24 TStringGrid.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0\fs20 
\par 
\par }
3970
Scribble3970
OnNewName event - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 DirEntry\cf3\strike0\{linkID=660\}\cf0 
\par \cf2\strike TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4\lang1033 
\par \cf2\lang3081\strike OnDirUpdate\strike0\{linkID=3780\}\cf0 
\par \cf2\strike UseDirOnlyEntries\cf3\strike0\{linkID=2170\}\cf0\f0 
\par }
3980
Scribble3980
OnNewName event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnNewName event example
\par \cf0\b0 
\par 
\par }
3990
Scribble3990
OnPasswordError event
OnPasswordError;OnPasswordError,TZipMaster;TZipMaster,OnPasswordError;


ZipMstr20:002145
Writing


TZipMaster_OnPasswordError;OnPasswordError_Event;OnPasswordError
FALSE
27
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fnil\fcharset0 Times New Roman;}{\f4\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnPasswordError event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4000\}\tab\cf2\strike Example\cf3\strike0\{linkID=%4010\}\cf4\{keepn\}\cf2\f1\fs20\tab\ul\fs16 Note on passwords:\ulnone\{linkID=250\}\cf0\b\f0\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par \pard\f1 
\par \pard\sb35\tx355\cf0 OnPasswordError event occurs when a DLL needs a password for encryping or decrypting.
\par \pard\sb115\b Type\b0  T\f2 ZM\f1 PasswordErrorEvent = \b Procedure\b0 ( Sender: \f3\fs24 TObject; \f1\fs20 IsZipAction: Boolean; \b var\b0  NewPassword: \b String\b0 ; ForFile: \cf2\strike\f4 TZMString\cf3\strike0\{linkID=5280\}\cf0\f1 ; \b var\b0  RepeatCount: LongWord ; var Action: \f2 TMsgDlgBtn\f1  ) \b of object\b0 ;
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf4\f0 
\par \cf0\b\fs22 Declaration
\par \f4\fs20 property\b0  OnPasswordError: \cf2\strike TZMPasswordErrorEvent\cf3\strike0\{linkID=4920\}\cf0 ;
\par \f0 
\par \pard\sb115\sa195\tx355\b\fs22 Description\f1\fs24 
\par \pard\tx355\b0\fs20 Occurs when adding or extracting and a password is needed but not set by the Password property and also when extracting and the given password is incorrect.
\par IsZipAction is set to \b true\b0  when the error is originating from an \cf2\strike Add\strike0\{linkID=2530\}\cf0  action else it is from an \cf2\strike Extract\strike0\{linkID=2960\}\cf0  action\f2 .\f1 
\par The ForFile parameter will give the path+file for which the password is needed.
\par RepeatCount is at first set to the \cf2\strike PasswordReqCount\strike0\{linkID=1570\}\cf0  number and decremented on each event call.
\par When needed you can modify RepeatCount and set it to value from 0 to 15 this will not influence PasswordReqCount.
\par Action is the action to take when returning from this event, possible actions are: pwbOk, pwbCancel, pwbCancelAll or pwbAbort. Default is pwbOk.
\par 
\par \cf5\b NOTE:\cf0\b0\tab This event will be called at most 15 times per file even when you try to increase RepeatCount multiple times.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
4000
Scribble4000
OnPasswordError event - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 GetExtrPassword\cf3\strike0\{linkID=3190\}\cf0 
\par \cf2\strike GetAddPassword\cf3\strike0\{linkID=3120\}\cf4\lang1033 
\par \cf2\lang3081\strike GetPassword\cf3\strike0\{linkID=3190\}\cf0\f0 
\par 
\par }
4010
Scribble4010
OnPasswordError event - Example




Writing



FALSE
26
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnPasswordError event example
\par 
\par \cf0\b0\i\f1 Procedure \f0 TMainForm\f1 .\f0 ZipBuilder1PasswordError(Sender\f1 : TObject;\f0 
\par       IsZipAction\f1 : Boolean;\f0  \f1 var \f0 NewPassword\f1 : String;\f0  \f1 const \f0 ForFile\f1 : String;\f0 
\par       \f1 var \f0 RepeatCount\f1 : LongWord; var \f0 Action\f1 :\f0  TMsgDlgBtn )
\par \f1 Begin
\par   if IsZipAction then
\par     Action := ZipMaster1.GetPassword(ZipMaster1.Info(PW_Caption),
\par                                       ZipMaster1.Info(PW_MessageEnter),
\par                                         DHC_AddPwrd1,
\par                                       [mbOK << mbCancel],
\par                                       NewPassword);
\par    else
\par     Action := ZipMaster1.GetPassword(ZipMaster1.Info(PW_Caption),
\par                                        ZipMaster1.Info(PW_MessageEnter) +
\par                                        ZipMaster1.Info(PW_ForFile) +
\par                                        ForFile,
\par                                        [mbOK << mbCancel << mbAll],
\par                                        NewPassword );
\par End;
\par \cf1\b\i0\f0 
\par \cf0\b0 
\par 
\par }
4020
Scribble4020
OnProgress event
OnProgressDetails;OnProgressDetails,TZipMaster;TZipMaster,OnProgressDetails;


ZipMstr20:002150
Writing


TZipMaster_OnProgressDetails;OnProgressDetails_Event;OnProgressDetails
FALSE
30
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fnil\fcharset0 Arial;}{\f4\fnil Courier New;}{\f5\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnProgress event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4030\}\tab\cf2\strike Example\cf3\strike0\{linkID=%4040\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \pard\sb35\tx355\cf0\f1 OnProgress event o\cf4 ccurs during compression and decompression of a Zip archive and while \f2 reading, writing or processing.\cf0\f1 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf4\f0 
\par \f3 type\lang1033\f0   T\lang3081\f3 ZM\lang1033\f0 ProgressEvent = procedure(Sender: TObject; details: \cf2\strike T\lang3081\f3 ZM\lang1033\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4 ) of object;
\par \lang3081 
\par \cf0\b\fs22 Declaration
\par \f4\fs20 property\b0  OnProgress: \cf2\strike TZMProgressEvent\cf3\strike0\{linkID=4940\}\cf0 ;
\par \f0 
\par \pard\sb115\sa195\tx355\b\fs22 Description\f1\fs24 
\par \pard\sa195\tx355\cf4\b0\fs20 Intended for "status bar" or "progress bar" updates.  Criteria for this event:\cf0 
\par \pard\sa35\tx355\cf4 ProgressType is defined as one of the types below:\cf0 
\par \pard\fi-2545\li2835\tx565\tx2835 TotalSize2Process\tab At the start of processing a (batch of) file(s) with the Add, Extract or Test method this gives the total uncompressed file size which will be processed by the given method. This can be used to show a progress bar for the entire job. This size is also available in the \cf2\strike TotalSizeToProcess\strike0\{linkID=2050\}\cf0  property.\f2  \f1 
\par TotalFiles2Process\tab At the start of processing a (batch of) file(s) with the Add, Extract or Test method you will get the total number of files which will be processed by the given method.
\par NewFile\tab Starting to process a new file. (gives you  the filename and total uncompressed filesize for the given file.)
\par ProgressUpdate\tab Every xxxK bytes while processing a file. The actual progress \f5 '\f1 xxx\f5 '\f1  is given in FileSize.
\par For Zip compression this will be 64K, n times 32K, and the remaining file bytes.
\par For Unzip uncompression this will be: n times 32K and the remaining file bytes.
\par For Zip (un)spanning actions it will be 8K.
\par EndOfBatch\tab Completed processing on a (batch of) file(s).
\par \pard\sb115\tx565\tx2835 (See Demo1 to learn how to use this event.)
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
4030
Scribble4030
OnProgress event - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of OnProgress event >>>
\par 
\par }
4040
Scribble4040
OnProgress event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnProgress event example
\par \cf0\b0 
\par 
\par }
4050
Scribble4050
OnSetAddName event
OnSetAddName;OnSetAddName,TZipMaster;TZipMaster,OnSetAddName;


ZipMstr20:002155
Writing


TZipMaster_OnSetAddName;OnSetAddName_Event;OnSetAddName
FALSE
26
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fnil Courier New;}{\f4\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnSetAddName event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4060\}\tab\cf2\strike Example\cf3\strike0\{linkID=%4070\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par \pard\tx165\tx425\f1 
\par \pard\sb35\tx165\tx425\cf0 OnSet\f2 Add\f1 Name event occurs when adding files to an archive and gives you a chance to change the path and\f2 /\f1 or file name.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\b Type \b0 T\f2 ZM\f1 Set\f2 Add\f1 NameEvent = \b procedure(Sender: TObject; var FileName: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ;
\par     const ExtName: TZMString; var IsChanged: Boolean) of object;\b0 
\par \cf4\f0 
\par \cf0\b\fs22 Declaration
\par \f3\fs20 property\b0  OnSetAddName: \cf2\strike TZMSetAddNameEvent\cf3\strike0\{linkID=5020\}\cf0 ;
\par \f0 
\par \pard\sb115\sa195\tx165\tx425\b\fs22 Description\f1\fs24 
\par \pard\tx165\tx425\b0\fs20 Occurs\f2  only\f1  when adding files to the archive, the file to be added is FileName and can be changed to any path filename combination of your own choice. when you change \f4 '\f1 FileName\f4 '\f1  you must also set IsChanged to \b True\b0 .
\par \f2 ExtName is the full path and name of file being added.
\par Leaving the FileName empty( empty string) and setting IsChanged set to true; the file will NOT be included in the archive, it will be skipped. \f1 
\par 
\par \pard\fi-1555\li1555\tx1555\cf5\b WARNING:\tab\cf0\b0 There is virtual\f2 ly\f1  no check on the path\\filename you specify.
\par \tab This means that if you are not careful you can get multiple names or even wrong names that can\f4 '\f1 t be extracted anymore.
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
4060
Scribble4060
OnSetAddName event - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of OnSetAddName event >>>
\par 
\par }
4070
Scribble4070
OnSetAddName event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnSetAddName event example
\par \cf0\b0 
\par 
\par }
4080
Scribble4080
OnSetExtName event
OnSetExtName;OnSetExtName,TZipMaster;TZipMaster,OnSetExtName;


ZipMstr20:002160
Writing


TZipMaster_OnSetExtName;OnSetExtName_Event;OnSetExtName
FALSE
24
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fnil\fcharset0 Arial;}{\f4\fnil Courier New;}{\f5\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnSetExtName event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4090\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \pard\tx165\tx425\cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par \f1 
\par \pard\sb35\tx165\tx425\cf0 OnSet\f2 Add\f1 Name event occurs when adding files to an archive and gives you a chance to change the path and\f2 /\f1 or file name.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf4\f0 
\par \f3 Type TZMSetExtNameEvent = procedure(Sender: TObject; var FileName: \cf2\b\strike\f1 TZMString\cf3\strike0\{linkID=5280\}\cf0 ;\cf4\b0\f3 
\par     const BaseDir: TZMString; var IsChanged: Boolean) of object;\f0 
\par 
\par \cf0\b\fs22 Declaration
\par \f4\fs20 property\b0  OnSetExtName: \cf2\strike TZMSetExtNameEvent\cf3\strike0\{linkID=5060\}\cf0 ;
\par \f0 
\par \pard\sb115\sa195\tx165\tx425\b\fs22 Description\f1\fs24 
\par \pard\tx165\tx425\b0\fs20 OnSetExtName event occurs when extracting files from an archive and gives you a chance to change the path and or file name\f2 .
\par W\f1 hen you change \f5 '\f1 FileName\f5 '\f1  you must also set IsChanged to \b True\b0 .\f2  \f1 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 
\par If a new path is used without specifying the Drive then \cf2\strike ExtrBaseDir\cf3\strike0\{linkID=1030\}\cf0  is used as the Root folder
\par If you set Filename = "\\newpath\\Filename.ext" this will be translated to ExtrBaseDir\\newpath\\Filename.ext
\par If you set Filename = "newpath\\Filename.ext" this will also be translated to ExtrBaseDir\\newpath\\Filename.ext \f0 
\par }
4090
Scribble4090
OnSetExtName event - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ExtrBaseDir\cf3\strike0\{linkID=1030\}
\par \cf2\strike\f2 Extract\cf3\strike0\{linkID=2960\}\cf0\f0 
\par 
\par }
4110
Scribble4110
OnSetCompLevel event
OnSetCompLevel;OnSetCompLevel,TZipMaster;TZipMaster,OnSetCompLevel;


ZipMstr20:001705
Writing


TZipMaster_OnSetCompLevel;OnSetCompLevel_Property;OnSetCompLevel
FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnSetCompLevel event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4120\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \f1 Occurs before compressing each file giving you a chance to change its compression level.
\par \cf0\b\f0\fs22 
\par \b0\f2\fs20 type TZMSetCompLevel = procedure(Sender: TObject; const ForFile: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ; var level: Integer; var IsChanged: Boolean) of object;\b\f0\fs22  
\par \cf4\b0\fs20 
\par \cf0\b\fs22 Declaration\b0\f3\fs20 
\par \b property\b0  OnSet\f2 CompLevel\f3 : \cf2\strike TZMSet\f2 CompLevel\cf3\strike0\f3\{linkID=50\f2 4\f3 0\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Occurs only when adding files to the archive, use this when you want to set a compression level other than the value in \cf2\strike AddCompLevel\cf3\strike0\{linkID=430\}\cf0  property to the archive.
\par   Sender: TObject             - the ZipMaster component firing the event
\par   const ForFile: TZMString - the name of the file that will be compressed 
\par   var level: Integer              - the new compression level (0..9)
\par   var IsChanged: Boolean   - set True if level is changed \f0 
\par }
4120
Scribble4120
OnSetCompLevel event - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddCompLevel\cf3\strike0\{linkID=430\}\cf0  
\par \cf2\strike Add\cf3\strike0\{linkID=2530\}\cf0\f0 
\par 
\par }
4140
Scribble4140
OnSkipped event
OnSkipped;OnSkipped,TZipMaster;TZipMaster,OnSkipped;


ZipMstr20:002165
Writing


TZipMaster_OnSkipped;OnSkipped_Event;OnSkipped
FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fswiss Arial;}{\f3\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnSkipped event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4150\}\tab\cf2\strike Example\cf3\strike0\{linkID=%4160\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \f1 Occurs when an operation fails to find or open a file.
\par 
\par Type TZMSkippedEvent = procedure(Sender: TObject; const ForFile: \cf2\b\strike\f2 TZMString\cf3\strike0\{linkID=5280\}\cf0 ;\cf4\b0\f1 
\par     SkipType: TZMSkipTypes; var ExtError: Integer) of object;\f0 
\par 
\par \cf0\b\fs22 Declaration
\par \f3\fs20 property\b0  OnSkipped: \cf2\strike TZMSkippedEvent\cf3\strike0\{linkID=5080\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Fired when an operation fails to process an instruction or file.
\par On entry ExtError will be the >= 0 if \cf2\strike NoSkipping \cf3\strike0\{linkID=1470\}\cf0 for that \cf2\strike type \cf3\strike0\{linkID=5100\}\cf0 is false
\par If ExtError < 0 upon return from a handler the operation will abort.
\par \f0 
\par 
\par }
4150
Scribble4150
OnSkipped event - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\strike\f1 NoSkipping \cf3\strike0\{linkID=1470\}
\par \pard\cf2\strike TZMSkipAborts\cf3\strike0\{linkID=5120\}\cf0 
\par \cf2\strike TZMSkipTypes\cf3\strike0\{linkID=5100\}\cf0\f0 
\par 
\par }
4160
Scribble4160
OnSkipped event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnSkipped event example
\par \cf0\b0 
\par 
\par }
4170
Scribble4170
OnStateChange property
OnStateChange;OnStateChange,TZipMaster;TZipMaster,OnStateChange;


ZipMstr20:001710
Writing


TZipMaster_OnStateChange;OnStateChange_Property;OnStateChange
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnStateChange property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4180\}\tab\cf2\strike Example\cf3\strike0\{linkID=%4190\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par \cf0\b\f1 type\b0  TZMStateChange = \b procedure\b0 (Sender: TObject; state: \cf2\strike TZMStates\cf3\strike0\{linkID=5200\}\cf0 ; \b var\b0  NoCursor: boolean); \b of\b0  \b object\b0 ;
\par \cf4\f0 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  OnStateChange: \cf2\strike TZMStateChange\cf3\strike0\{linkID=5180\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Allows handling changes in the component state eg. to block button clicks when busy.\f0 
\par \f2  state  - indicates the new operational \cf2\strike\f1 State\cf3\strike0\{linkID=5200\}
\par \cf0\f2 When NoCursor is set to true the current cursor will not be changed, if set to false the cursor will be reflecting the Active state.
\par If Active the Waitcursor is started, if not Active the Waitcursor is stopped.\cf3\f1  \cf0\f0 
\par }
4180
Scribble4180
OnStateChange property - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Busy\cf3\strike0\{linkID=550\}\cf0\f0 
\par 
\par }
4190
Scribble4190
OnStateChange property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnStateChange property example
\par \cf0\b0 
\par 
\par }
4200
Scribble4200
OnStatusDisk event
OnStatusDisk;OnStatusDisk,TZipMaster;TZipMaster,OnStatusDisk;TZMDiskAction;


ZipMstr20:002170
Writing


TZipMaster_OnStatusDisk;OnStatusDisk_Event;OnStatusDisk
FALSE
35
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fnil\fcharset0 Times New Roman;}{\f4\fnil Courier New;}{\f5\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnStatusDisk event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4210\}\tab\cf2\strike Example\cf3\strike0\{linkID=%4220\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \pard\tx165\tx425\cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component\f1 
\par \pard\sb35\tx165\tx425\cf0 OnStatusDisk event occurs when spanning disks and trying to overwrite an existing file.
\par \pard\sb115\b Type \b0 T\f2 ZM\f1 StatusDiskEvent = \b Procedure\b0 ( S\f3\fs24 ender: TObject; \f1\fs20 PreviousDisk: Integer; PreviousFile: \b String\b0 ; Status: \cf2\strike TZ\f2 MZip\f1 DiskStatus\cf3\strike0\{linkID=5430\}\cf0 ; \b var\b0  Action: \cf2\strike TZ\f2 M\f1 DiskAction\cf3\strike0\{linkID=4680\}\cf0  ) \b of object\b0 ; 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf4\f0 
\par \cf0\b\fs22 Declaration
\par \f4\fs20 property\b0  OnStatusDisk: TZMStatusDiskEvent;
\par \f0 
\par \pard\sb115\sa195\tx165\tx425\b\fs22 Description\f1\fs24 
\par \pard\tx165\tx425\b0\fs20 PreviousDisk is when applicable the disknumber of the previous disk which could be overwritten.
\par PreviousFile contains the filename of the zip archive.
\par 
\par TZ\f2 M\f1 DiskStatus is a set and can take one or more of the following values:
\par \pard\fi-1985\li1985\sb115\sa115\tx1985\b\fs24 Value\tab Meaning
\par \pard\fi-1985\li1985\tx1985\b0\fs20 zdsEmpty\tab The disk is empty and ready to use.
\par zdsHasFiles\tab The disk is not empty and contains one or more file(s).
\par zdsPreviousDisk\tab It\f5 '\f1 s possibly a previous disk from the backup set.
\par zdsSameFileName\tab The disk contains a file with the same filename as the zip archive.
\par zdsNotEnoughSpace\tab There is not enough space on the disk taken into account \cf2\strike KeepFreeOnDisk1\strike0\{linkID=1290\}\cf0 , \cf2\strike MaxVolumeSize\strike0\{linkID=1380\}\cf0  and \cf2\strike MinFreeVolumeSize\strike0\{linkID=1440\}\cf0 .
\par \pard\tx425\fs18 
\par \fs20 T\f2 ZM\f1 ZipDiskAction should be set to one of the following values:
\par \pard\fi-1985\li1985\sb115\sa115\tx1985\b\fs24 Value\tab Meaning
\par \pard\fi-1985\li1985\tx1985\b0\fs20 zdaOkl\tab Continue diskspanning (the default).
\par zdaErase\tab Erase the disk first.
\par zdaReject\tab Try again.
\par zdaCancel\tab Cancel the diskspanning operation.
\par \f2 zdaYesToAll\tab Continue spanning and do not ask again.\f1 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
4210
Scribble4210
OnStatusDisk event - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \pard\fi-1985\li1985\tx1985\cf0\b0\f1 
\par \cf2\strike KeepFreeOnDisk1\cf3\strike0\{linkID=1290\}\cf0 
\par \cf2\strike MaxVolumeSize\cf3\strike0\{linkID=1380\}\cf0 
\par \cf2\strike MinFreeVolumeSize\cf3\strike0\{linkID=1440\}\cf0 
\par \pard\f0 
\par }
4220
Scribble4220
OnStatusDisk event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnStatusDisk event example
\par \cf0\b0 
\par 
\par }
4230
Scribble4230
OnStream event
OnStream;OnStream,TZipMaster;TZipMaster,OnStream;


ZipMstr20:002175
Writing


TZipMaster_OnStream;OnStream_Event;OnStream
FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnStream event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4240\}\tab\cf2\strike Example\cf3\strike0\{linkID=%4250\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par 
\par \f1 Occurs during Add or Extract operations involving streams.
\par 
\par type TZMStreamEvent = procedure(Sender: TObject; opr: \cf2\strike TZMStreamOp\cf3\strike0\{linkID=5490\}\cf4 ; snumber: integer;
\par     var strm: TStream; var stat: \cf2\strike TZMSStats\cf3\strike0\{linkID=5470\}\cf4 ; var done: Boolean) of object;
\par \f0 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  OnStream: \cf2\strike TZMStreamEvent\cf3\strike0\{linkID=5240\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 It can be used to Create/Open, Destroy/Close or Identify a stream.
\par If done is set it will override the default handling of stream operations.\f0 
\par 
\par }
4240
Scribble4240
OnStream event - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 TZMPipe\cf3\strike0\{linkID=7340\}\cf0 
\par \cf2\strike TZMPipeList\cf3\strike0\{linkID=7440\}\cf0\f0 
\par 
\par }
4250
Scribble4250
OnStream event - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnStream event example
\par \cf0\b0 
\par 
\par }
4260
Scribble4260
OnTick event
OnTick;OnTick,TZipMaster;TZipMaster,OnTick;


ZipMstr20:002180
Writing


TZipMaster_OnTick;OnTick_Event;OnTick
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnTick event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf3\b0\strike\fs20 TZipMaster\cf4\strike0\{linkID=350\}\cf2  component
\par \cf1\b\f1\fs32  \cf0\b0\fs20 activity indicator
\par 
\par Type TZMTickEvent = Procedure(Sender: TObject) Of Object;
\par \cf2\f0 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  OnTick: \cf3\strike TZMTickEvent\cf4\strike0\{linkID=5290\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Use to indicate that something is happening.\f0 
\par 
\par }
4265
Scribble4265
OnLoadStr event




Done



FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 OnLoadStr event\f1 
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%42\f0 67\f1\}\tab\cf2\strike Example\cf3\strike0\{linkID=%42\f0 7\f1 0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par \f0 Allows using message strings from a resource dll or other external source\f1 
\par \cf0\f0 
\par Type TZMLoadStrEvent = procedure(Ident: Integer; var DefStr: String) of object;
\par \cf4\f1 
\par \cf0\b\fs22 Declaration
\par \b0 var
\par   On\f0 Load\f1 Str: \cf2\strike TZ\f0 MLoad\f1 StrEvent\cf3\strike0\{linkID=5260\}\cf0 ;\f2\fs20 
\par \f1 
\par \b\fs22 Description
\par \b0\f0\fs20 OnLoadStr event occurs when any TZipMaster component needs to load a message or error string from its resource file.
\par This gives you the chance to replace this with a string from another external resources such as an language dll.
\par 
\par \b Ident\b0  is the identifier of the message or error string required , the result will be returned in the Str parameter
\par 
\par OnLoadStr is a global event which will handle events from all TZipMaster components.
\par 
\par The message identifiers are declared in ZMMsg19.pas.\f1 
\par 
\par \pard 
\par 
\par 
\par }
4267
Scribble4267
OnLoadStr event - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ZipLoadStr\cf3\strike0\{linkID=3510\}\cf0 
\par \cf2\strike Language\cf3\strike0\{linkID=1320\}\cf0 
\par \cf2\strike LanguageInfo\cf3\strike0\{linkID=1350\}\cf0\f0 
\par 
\par }
4270
Scribble4270
OnLoadStr event - Example




Done



FALSE
26
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\fs24 OnLoadStr event - Example\cf0\f1\fs20 
\par 
\par 
\par \f0 procedure\f1  TForm1\f0 .\f1 Zip\f0 Master\f1 erZipStr(ID\f0 : Integer;\f1  \f0 var Str: \f1 String)\f0 ;\f1 
\par \f0 const
\par   LibName: String = 'C:\\LangDlls\\StrangeLangDll.dll';
\par var
\par   hDll: HINSTANCE;
\par   buff: array [0..255] of char;
\par   s: String;
\par begin
\par   HINSTANCE hDll := LoadLibrary(LibName);
\par   if hDll <> 0 then
\par   begin\-
\par     if LoadString(hDll, ID, buff, 255) > 0 then 
\par        Str = String(buff);
\par     FreeLibrary(hDll);
\par   end;
\par end;
\par \f1 
\par \f0 ...
\par   ZipMaster1.OnLoadStr := ZipMasterZipStr;
\par ...\f1 
\par }
4320
Scribble4320
OnZipDialog event
OnZipDialog;OnZipDialog,TZipMaster;TZipMaster,OnZipDialog;


ZipMstr20:002185
Done


TZipMaster_OnZipDialog;OnZipDialog_Event;OnZipDialog
FALSE
45
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OnZipDialog event
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4340\}\tab\cf2\strike Example\cf3\strike0\{linkID=%4350\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZipMaster\cf3\strike0\{linkID=350\}\cf4  component
\par \pard\tx165\tx425\f1 
\par \pard\cf1\b\f2\fs32  \cf4\b0\fs20    called before displaying message dialogs to allow custom handling of messages\cf0 
\par 
\par \b Type\b0 
\par   TZMDialogEvent = procedure(Sender: TObject; const title: String;
\par          var msg: String; var Result: Integer; btns: TMsgDlgButtons) of object;  
\par 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\b\f0\fs22 Declaration
\par \pard\f3\fs20 property\b0  OnZipDialog: TZMDialogEvent;\f2 
\par 
\par \b\fs28 Arguments\fs32 
\par   \b0\fs20  Sender: TObject; 
\par     const title: String; -  Desired Caption
\par     var msg: String; 
\par \tab\tab  - IN message text, 
\par \tab\tab    OUT (zmtPassword only) password
\par     var Result: Integer; 
\par \tab\tab - IN HighWord=message dialog type (see below) 
\par \tab\tab       LowWord=\cf2\strike Dialog context\cf3\strike0\{linkID=4330\}\cf0 
\par  \tab\tab - OUT ModalResult (unchanged if not handled)
\par     btns: TMsgDlgButtons - required buttons
\par 
\par   Defined in ZipDlg.pas
\par // High word = $10 or TMsgDlgType, low word = context
\par const
\par   zmtWarning  = $100000;
\par   zmtError    = $110000;
\par   zmtInformation = $120000;
\par   zmtConfirmation = $130000;
\par   zmtPassword = $140000;
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f3 
\par \f0 
\par \pard\b\fs22 Description\f2\fs32 
\par   \b0\fs20 used to show messages or request passwords
\par    If \cf2\strike Verbose \cf3\strike0\{linkID=2230\}\cf0 is true the context number will be show in the title.\b\fs32 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\b0\f0\fs20 
\par 
\par }
4330
Scribble4330
DialogContext




Done



FALSE
45
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 DialogContext\cf2\b0\f1\fs20 
\par \lang1033 
\par \lang3081\f0  Defined in ZMCtx.pas
\par 
\par const
\par   DHCBase = 10000;
\par 
\par   DHC_ZipMessage = DHCBase;
\par      Show (error?) message
\par   DHC_ExMessage = DHCBase + 1;
\par      Show Exception message
\par   DHC_Password = DHCBase + 2; // just GetPassword default password
\par      Request password
\par   DHC_ExtrPwrd = DHCBase + 3;
\par      Request Extract password
\par   DHC_AddPwrd1 = DHCBase + 4;
\par      Request first Add password
\par   DHC_AddPwrd2 = DHCBase + 5;
\par      Confirm Add password
\par   DHC_WrtSpnDel = DHCBase + 6;
\par      Confirm delete 
\par   DHC_ExSFX2EXE = DHCBase + 7;
\par      ?
\par   DHC_ExSFX2Zip = DHCBase + 8;
\par      ?
\par   DHC_SpanNxtW = DHCBase + 9;
\par      Request next disk for writing
\par   DHC_SpanNxtR = DHCBase + 10;  
\par      Request next disk for reading
\par   DHC_SpanOvr = DHCBase + 11;
\par      Confirm before overwriting old part
\par   DHC_SpanNoOut = DHCBase + 12;
\par      Complain no output file
\par   DHC_SpanSpace = DHCBase + 13;
\par      Complain not enough space
\par   DHC_CpyZipOvr = DHCBase + 14;
\par      Confirm overwrite in CopyZippedFile
\par   DHC_FormErase = DHCBase + 15;
\par      Confirm format floppy
\par \lang1033\f1 
\par \lang3081 
\par 
\par }
4340
Scribble4340
OnZipDialog event - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of OnZipDialog event >>>
\par 
\par }
4350
Scribble4350
OnZipDialog event - Example




Done



FALSE
27
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 OnZipDialog event example
\par \cf0\b0 
\par This handler expects a class TPasswordDlg, capable of displaying the message, the required buttons and having a TEdit to enter the required passwords
\par 
\par \f1 procedure \f0 TMainForm\f1 .\f0 ZipBuilderZipDialog(\f1 Sender: \f0 TObject\f1 ;\f0 
\par                            const Title\f1 : String;\f0  \f1 var msg: \f0 String\f1 ;\f0 
\par                            \f1 var\f0  Context\f1 : Integer;\f0  \f1 Btns: \f0 TMsgDlgButtons)\f1 ;
\par var
\par   ctx: Integer;\f0 
\par \f1 begin
\par   ctx := Context and $FFFF;
\par   String MyTitle := Title;
\par   if (ctx = DHC_AddPwrd1) or (ctx = DHC_AddPwrd2) then
\par              // values declared in ZMCtx.pas
\par     MyTitle := 'My Password dialog';
\par   TPasswordDlg Pdlg := TPasswordDlg.create(this, 0, Btns);
\par   try
\par       msg := Pdlg.ShowModalPwdDlg(MyTitle, msg);
\par       Context := Pdlg.ModalResult;
\par   finally
\par       Pdlg.Free;
\par   end;
\par end;
\par \f0 
\par }
4360
Scribble4360
PZMRenameRec type
PZMRenameRec;


ZipMstr20:002200
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 PZMRenameRec type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4370\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  \f2 PZM\f1 RenameRec = ^TZMRenameRec;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 structure used to 'identify' streams
\par 
\par }
4370
Scribble4370
PZMRenameRec type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of \f1 PZM\f0 RenameRec type >>>
\par 
\par }
4380
Scribble4380
PZMSStats type
PZMSStats;


zipmstr20:002205
Done



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 PZMSStats type
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\b0\fs16\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZipMstr19\cf4\strike0\{linkID=330\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  PZ\f2 M\f1 SStats = ^\cf3\strike TZ\f2 M\f1 SStats\cf4\strike0\{linkID=5470\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Pointer to structure used to identify streams.\f0 
\par 
\par }
4390
Scribble4390
TSFXOpt type
TSFXOpt;


zipmstr20:002210
Done



FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TSFXOpt type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4400\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TSFXOpt = (soAskCmdLine, soAskFiles, soHideOverWriteBox, soAutoRun, soNoSuccessMsg, soExpandVariables, soInitiallyHideFiles, soForceHideFiles, soCheckAutoRunFileName, soCanBeCancelled, soCreateEmptyDirs, soSuccessAlways);
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 set of TSFXOption
\par     soAskCmdLine,     \f2             \f0 // allow user to prevent execution of the command line
\par     soAskFiles,       \f2                 \f0 // allow user to prevent certain files from extraction
\par     soHideOverWriteBox, \f2         \f0 // do not allow user to choose the overwrite mode
\par     soAutoRun,        \f2                \f0 // start extraction + evtl. command line automatically
\par     \f2                                         \f0 //  \f2  \f0  only if sfx filename starts with "!" or is "setup.exe"
\par     soNoSuccessMsg,   \f2           \f0 // don't show success message after extraction
\par     soExpandVariables, \f2            \f0 // expand environment variables in path/cmd line...
\par     soInitiallyHideFiles, \f2             \f0 // don\f2 '\f0 t show file listview on startup
\par     soForceHideFiles, \f2               \f0 // do not allow user to show files list
\par     \f2                                          \f0 //                (no effect if s\f2 o\f0 InitiallyShowFiles is set)
\par     soCheckAutoRunFileName, // can only autorun if !... or setup.exe
\par     soCanBeCancelled, \f2             \f0 // extraction can be cancelled
\par     soCreateEmptyDirs, \f2            \f0 // recreate empty directories
\par     soSuccessAlways   \f2             \f0 // always give success message even if soAutoRun or soNoSuccessMsg
\par 
\par }
4400
Scribble4400
TSFXOpt type - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0\f1 
\par \cf2\strike SFXOptions\cf3\strike0\{linkID=1840\}\cf0 
\par \cf2\strike TSFXOpts\cf3\strike0\{linkID=4410\}\cf0\f0 
\par 
\par 
\par }
4410
Scribble4410
TSFXOpts type
TSFXOpts;


zipmstr20:002215
Done



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TSFXOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4420\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TSFXOpts = \b set\b0  \b of\b0  \cf2\strike TSFXOpt\cf3\strike0\{linkID=4390\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Set of options for building SFX files\f0 
\par 
\par }
4420
Scribble4420
TSFXOpts type - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXOptions\cf3\strike0\{linkID=1840\}\cf0\f0 
\par \cf2\strike\f1 TSFXOpt\cf3\strike0\{linkID=4390\}\cf0\f0 
\par 
\par }
4430
Scribble4430
TZMChangeFunction type
TZMChangeFunction;


zipmstr20:002220
Done



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMChangeFunction type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4440\}\tab\cf2\strike Example\cf3\strike0\{linkID=%\f1 270\f0 0\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\f1\fs20 T\f0 ZipMstr20\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 type\b0  TZ\f3 M\f2 ChangeFunction = \b function\b0 (rec: \cf2\strike TZ\f3 M\f2 DirRec\cf3\strike0\{linkID=7090\}\cf0 ; \b var\b0  Data): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 This is the definition of the function applied to each selected entry during \cf2\strike ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf0  to make the changes.\f0 
\par 
\par \f1 This function should return 0 on success otherwise an error value.\f0 
\par }
4440
Scribble4440
TZMChangeFunction type - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ChangeFileDetails\cf3\strike0\{linkID=2680\}
\par \cf2\strike Rename\cf3\strike0\{linkID=3380\}\cf0\f0 
\par 
\par }
4450
Scribble4450
TZMForEachFunction type
TZMForEachFunction;


zipmstr20:002225
Done



FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZ\f1 M\f0 ForEachFunction type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4460\}\tab\cf2\strike Example\cf3\strike0\{linkID=%\f1 310\f0 0\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 type\b0  TZMForEachFunction = \b function\b0 (rec: \cf2\strike TZ\f3 M\f2 DirEntry\cf3\strike0\{linkID=6360\}\cf0 ; \b var\b0  Data): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 A user defined function to operate (read-only) on each directory entry.
\par 
\par    rec: the directory entry (read-only)
\par    Data: user defined data passed to the \cf2\strike ForEach\cf3\strike0\{linkID=3080\}\cf0  function.
\par 
\par Return <> 0 on any error.
\par 
\par Set \cf2\strike Cancel\cf3\strike0\{linkID=580\}\cf0  to abort.\f0 
\par 
\par }
4460
Scribble4460
TZMForEachFunction type - See also




Done



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ForEach\cf3\strike0\{linkID=3080\}\cf0\f0 
\par 
\par }
4470
Scribble4470
TZMRenameRec type
TZMRenameRec;


zipmstr20:002230
Done



FALSE
26
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMRenameRec type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4480\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZ\f2 M\f1 RenameRec = \b record\b0  
\par \f2    \f1 Source: \b String\b0 ; 
\par \f2    \f1 Dest: \b String\b0 ; 
\par \f2    \f1 Comment: \b String\b0 ; 
\par \f2    \f1 DateTime: Integer; 
\par \f2   \b\f1 end\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3   Record used in the Rename method to specify what needs to be changed.\b\f0 
\par \b0\f1\fs20 
\par \f2    \f1 Source: \f2 The name of the existing entry\f1  
\par \f2    \f1 Dest: \f2 The replacement name\f1  
\par \f2    \f1 Comment: \f2 A new comment for this entry\f1  \f2 (can be empty if changing name or date)\f1 
\par \f2    \f1 DateTime: \f2 a new DOS Date stamp for this entry (can be empty if changing name or comment)\f1 
\par \f0 
\par 
\par }
4480
Scribble4480
TZMRenameRec type - See also




Done



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Rename\cf3\strike0\{linkID=3380\}\cf0\f0 
\par \cf2\strike\f1 ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf0\f0 
\par 
\par }
4490
Scribble4490
TZMAddOpts type
TZMAddOpts;


zipmstr20:002235
Done



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMAddOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4500\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMAddOpts = \b set\b0  \b of\b0  \cf2\strike TZMAddOptsEnum\cf3\strike0\{linkID=4510\}\cf0 ;
\par \f0 
\par \b\fs22 Description\b0\fs20 
\par Options used when building a zip file, in property \cf2\strike AddOptions\cf3\strike0\{linkID=470\}\cf0 
\par }
4500
Scribble4500
TZMAddOpts type - See also




Done



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike AddOptions\cf3\strike0\{linkID=470\}
\par \cf2\strike\f1 WriteOptions\cf3\strike0\{linkID=2290\}
\par \cf2\strike SpanOptions\cf3\strike0\{linkID=1960\}\cf0\f0 
\par 
\par }
4510
Scribble4510
TZMAddOptsEnum type
TZMAddOptsEnum;


zipmstr20:002240
Done



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMAddOptsEnum type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4520\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMAddOptsEnum = (AddDirNames, AddRecurseDirs, AddMove, AddFreshen, AddUpdate, AddHiddenFiles, AddArchiveOnly, AddResetArchive, AddEncrypt, Add\f2 Empty\f1 Dirs, AddVolume, AddFromDate, AddSafe, AddVersion, AddNTFS);
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Options when building a zip file\f0 
\par 
\par }
4520
Scribble4520
TZMAddOptsEnum type - See also




Done



FALSE
11
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 TZMAddOpts\cf3\strike0\{linkID=4490\}\cf0\f0 
\par \cf2\strike AddOptions\cf3\strike0\{linkID=470\}
\par \cf2\strike\f1 WriteOptions\cf3\strike0\{linkID=2290\}
\par \cf2\strike SpanOptions\cf3\strike0\{linkID=1960\}\cf0\f0 
\par 
\par 
\par }
4530
Scribble4530
TZMAddStoreExts type
TZMAddStoreExts;


ZipMstr20:002245
Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMAddStoreExts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4540\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMAddStoreExts = \b set\b0  \b of\b0  \cf2\strike TZMAddStoreSuffixEnum\cf3\strike0\{linkID=4550\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 A set of predefined suffixes of file types to be stored instead of compressed.
\par Compression of these types is slow and ineffective, in extreme cases may even make the file larger.
\par \f0 
\par 
\par }
4540
Scribble4540
TZMAddStoreExts type - See also




Writing



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddStoreSuffixes\cf3\strike0\{linkID=500\}\cf0 
\par \cf2\strike ExtAddStoreSuffixes\cf3\strike0\{linkID=1000\}\cf0\f0 
\par \cf2\strike\f1 Filespec switches\cf3\strike0\{linkID=1110\}
\par \cf2\strike OnSetCompLevel\cf3\strike0\{linkID=4110\}
\par \cf2\strike AddCompLevel\cf3\strike0\{linkID=430\}\cf0\f0 
\par }
4550
Scribble4550
TZMAddStoreSuffixEnum type
TZMAddStoreSuffixEnum;


ZipMstr20:002250
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMAddStoreSuffixEnum type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4560\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMAddStoreSuffixEnum = (assGIF, assPNG, assZ, assZIP, assZOO, assARC, assLZH, assARJ, assTAZ, assTGZ, assLHA, assRAR, assACE, assCAB, assGZ, assGZIP, assJAR, assEXE, assEXT, assJPG, assJPEG, ass7Zp, assMP3, assWMV, assWMA, assDVR, assAVI);
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Set enumerations of extensions to only be stored instead of attempting to be compressed.\f0 
\par 
\par }
4560
Scribble4560
TZMAddStoreSuffixEnum type - See also




Writing



FALSE
12
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike AddStoreSuffix\f1 es\cf3\strike0\f0\{linkID=500\}\cf0\f1 
\par \cf2\strike ExtAddStoreSuffixes\cf3\strike0\{linkID=1000\}\cf0\f0 
\par \cf2\strike\f1 Filespec switches\cf3\strike0\{linkID=1110\}
\par \cf2\strike OnSetCompLevel\cf3\strike0\{linkID=4110\}
\par \cf2\strike AddCompLevel\cf3\strike0\{linkID=430\}\cf0\f0 
\par 
\par 
\par }
4570
Scribble4570
TZMCheckTerminateEvent type
TZMCheckTerminateEvent;


ZipMstr20:002255
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMCheckTerminateEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4580\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMCheckTerminateEvent = \b procedure\b0 (Sender: TObject; \b var\b0  abort: Boolean); \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Used to check for terminating threads.\f0 
\par 
\par }
4580
Scribble4580
TZMCheckTerminateEvent type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TZMCheckTerminateEvent type >>>
\par 
\par }
4590
Scribble4590
TZMCopyZippedOverwriteEvent type
TZMCopyZippedOverwriteEvent;


ZipMstr20:002260
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}{\f4\fswiss\fcharset0 Arial;}{\f5\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMCopyZippedOverwriteEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4600\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \pard\cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4\f1 
\par \pard\sb35\tx165\tx425\cf0 The OnCopyZipOverwrite event occurs when the function CopyZippedFiles needs to know if a file may be overwritten.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf4\f0 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 type\b0  TZMCopyZippedOverwriteEvent = \b procedure\b0 (Sender: TObject; src, dst: \cf2\strike TZ\f3 M\f2 DirEntry\cf3\strike0\{linkID=6340\}\cf0 ; \b var\b0  DoOverwrite: Boolean); \b of\b0  \b object\b0 ;
\par \f0 
\par \pard\sa195\tx165\tx425\b\fs22 Description\f1\fs24 
\par \pard\tx165\tx425\b0\fs20 Occurs when during the execution of the function\f4 s \cf2\strike AddZippedFiles\cf3\strike0\{linkID=2620\}\cf0  and\f1  \cf2\strike CopyZippedFiles\strike0\{linkID=2840\}\cf0  it is necessary to know if a file in the destination archive may be overwritten. 
\par It is possible that the event does NOT occur because you have let the function know that it is always or never Ok to overwrite.
\par You can choose to overwrite the file \f5 '\f1 ForFile\f5 '\f1  by setting DoOverwrite to \b True\b0 . The default for DoOverwrite is \b False\b0 .
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
4600
Scribble4600
TZMCopyZippedOverwriteEvent type - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss\fcharset0 Arial;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddZippedFiles\cf3\strike0\{linkID=2620\}
\par \cf2\strike\f2 CopyZippedFiles\cf3\strike0\{linkID=2840\}\cf0  \f0 
\par 
\par }
4610
Scribble4610
TZMCRC32ErrorEvent type
TZMCRC32ErrorEvent;


ZipMstr20:002265
Writing



FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMCRC32ErrorEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4620\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \pard\tx165\tx425\cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4\f1 
\par \pard\sb35\tx165\tx425\cf0 OnCRC32Error event occurs when a CRC error is found while extracting.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf4\f0 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 type\b0  TZMCRC32ErrorEvent = \b procedure\b0 (Sender: TObject; \b const\b0  ForFile: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ; FoundCRC, ExpectedCRC: Longword; \b var\b0  DoExtract: Boolean); \b of\b0  \b object\b0 ;
\par \f0 
\par \pard\sa195\tx165\tx425\b\fs22 Description\f1\fs24 
\par \pard\tx165\tx425\b0\fs20 Occurs when during an \cf2\strike Extract\strike0\{linkID=2960\}\cf0  a CRC error is found in the file ForFile.
\par FoundCRC is the calculated CRC and ExpectedCRC is the CRC as stored in the zip archive these two values are for your information only.
\par You can choose to skip the extraction of the file by setting DoExtract to False. 
\par The default for DoExtract is True because that was the case in previous versions of ZipMaster where you could not choose.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
4620
Scribble4620
TZMCRC32ErrorEvent type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TZMCRC32ErrorEvent type >>>
\par 
\par }
4630
Scribble4630
TZMDeleteOpts type
TZMDeleteOpts;


ZipMstr20:002270
Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMDeleteOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4640\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMDeleteOpts = (htdFinal, htdAllowUndo);
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Options for deleting a file, used in the \cf2\strike HowToDelete\cf3\strike0\{linkID=1200\}\cf0  property\f0 
\par \f3    \f1 htdFinal\f3       - deletes the file\f1 
\par \f3   \f1  htdAllowUndo\f3   - moves file to recycle bin\f0 
\par }
4640
Scribble4640
TZMDeleteOpts type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 HowToDelete\cf3\strike0\{linkID=1200\}\cf0\f0 
\par 
\par }
4644
Scribble4644
TZMDeflates type




Writing



FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 TZMDeflates type\cf2\b0\f1\fs20 
\par \cf0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf3\ul See also\cf4\ulnone\{linkID=%464\f0 6\f1\}\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZipMstr19\cf4\strike0\{linkID=330\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 type\b0  TZMDeflates = (zmStore, zmStoreEncrypt, zmDeflate, zmDeflateEncrypt);
\par \f1 
\par \b\fs22 Description
\par \b0\f0\fs20 Options for deflating/undeflating a stream.\f1 
\par \f3    zmStore          - stores the file\f2 
\par \f3   \f2  zmStoreEncrypt\f3    - stores the file encrypted (not recomended)
\par    \f2 zmDeflate\f3         - deflate the file\f2 
\par \f3   \f2  zmDeflateEncrypt\f3  - deflate and encrypt the file.
\par 
\par Used by \cf3\strike Deflate\cf4\strike0\{linkID=2870\}\cf0  and \cf3\strike Undeflate\cf4\strike0\{linkID=3440\}\cf0\f1 
\par \pard\cf2 
\par 
\par }
4646
Scribble4646
TZMDeflates - See also




Writing



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs20 TZMDeflates - See also
\par 
\par \cf2\strike Deflate\cf3\strike0\{linkID=2870\}\cf1 
\par \cf2\strike Undeflate\cf3\strike0\{linkID=3440\}\cf4\b0\f1 
\par 
\par 
\par }
4650
Scribble4650
TZMDialogEvent type
TZMDialogEvent;


ZipMstr20:002275
Writing



FALSE
42
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMDialogEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4670\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \pard\tx165\tx425\cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4\f1 
\par \pard\cf1\b\f2\fs32  \cf4\b0\fs20    called before displaying message dialogs to allow custom handling of messages\cf0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf4\f0 
\par 
\par \cf0\b\fs22 Declaration
\par \pard\f2\fs20 type\b0  TZMDialogEvent = \b procedure\b0 (Sender: TObject; \b const\b0  title: \b String\b0 ; \b var\b0  msg: \b String\b0 ; \b var\b0  Result: Integer; btns: TMsgDlgButtons); \b of\b0  \b object\b0 ;
\par 
\par Property OnZipDialog: TOnZipDialogEvent;
\par 
\par \b\fs22 Arguments\fs32 
\par   \b0\fs20  Sender: TObject; 
\par     const title: String; -  Desired Caption
\par     var msg: String; 
\par \tab\tab  - IN message text, 
\par \tab\tab    OUT (zmtPassword only) password
\par     var Result: Integer; 
\par \tab\tab - IN HighWord=message dialog type (see below) 
\par \tab\tab       LowWord=\cf2\strike Help context\cf3\strike0\{linkID=4660\}\cf0 
\par  \tab\tab - OUT ModalResult (unchanged if not handled)
\par     btns: TMsgDlgButtons - required buttons
\par 
\par   Defined in ZipDlg.pas
\par // High word = $10 or TMsgDlgType, low word = context
\par const
\par   zmtWarning       = $100000;
\par   zmtError            = $110000;
\par   zmtInformation   = $120000;
\par   zmtConfirmation = $130000;
\par   zmtPassword     = $140000;
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par \pard\b\fs22 Description\f2\fs32 
\par   \b0\fs20 used to show messages or request passwords
\par    If \cf2\strike Verbose \cf3\strike0\{linkID=2230>main\}\cf0 is true the context number will be show in the title.\b\fs32 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\b0\f0\fs20 
\par 
\par }
4660
Scribble4660
Dialog Context




Writing



FALSE
45
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Dialog Context\cf2\b0\f1\fs20 
\par \lang1033 
\par \lang3081\f0  Defined in ZMCtx19.pas
\par 
\par const
\par   DHCBase = 10000;
\par 
\par   DHC_ZipMessage = DHCBase;
\par      Show (error?) message
\par   DHC_ExMessage = DHCBase + 1;
\par      Show Exception message
\par   DHC_Password = DHCBase + 2; // just GetPassword default password
\par      Request password
\par   DHC_ExtrPwrd = DHCBase + 3;
\par      Request Extract password
\par   DHC_AddPwrd1 = DHCBase + 4;
\par      Request first Add password
\par   DHC_AddPwrd2 = DHCBase + 5;
\par      Confirm Add password
\par   DHC_WrtSpnDel = DHCBase + 6;
\par      Confirm delete 
\par   DHC_ExSFX2EXE = DHCBase + 7;
\par      ?
\par   DHC_ExSFX2Zip = DHCBase + 8;
\par      ?
\par   DHC_SpanNxtW = DHCBase + 9;
\par      Request next disk for writing
\par   DHC_SpanNxtR = DHCBase + 10;  
\par      Request next disk for reading
\par   DHC_SpanOvr = DHCBase + 11;
\par      Confirm before overwriting old part
\par   DHC_SpanNoOut = DHCBase + 12;
\par      Complain no output file
\par   DHC_SpanSpace = DHCBase + 13;
\par      Complain not enough space
\par   DHC_CpyZipOvr = DHCBase + 14;
\par      Confirm overwrite in CopyZippedFile
\par   DHC_FormErase = DHCBase + 15;
\par      Confirm format floppy
\par \lang1033\f1 
\par \lang3081 
\par 
\par }
4670
Scribble4670
TZMDialogEvent type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TZMDialogEvent type >>>
\par 
\par }
4680
Scribble4680
TZMDiskAction type
TZMDiskAction;


ZipMstr20:002280
Writing



FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMDiskAction type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4690\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMDiskAction = (zdaYesToAll, zdaOk, zdaErase, zdaReject, zdaCancel);
\par \f0 
\par \pard\tx425\b\fs22 Description
\par \b0\f2\fs20 Action values for \cf2\strike TZMStatusDiskEvent\cf3\strike0\{linkID=5220\}\cf0\f3 
\par \pard\fi-1985\li1985\sb115\sa115\tx1985\b\fs24 Value\tab Meaning
\par \pard\fi-1985\li1985\tx1985\b0\f4\fs20 zdaYesToAll              Continue spanning and do not ask again\f3 
\par zdaOk\tab Continue diskspanning (the default).
\par zdaErase\tab Erase the disk first.
\par zdaReject\tab Try again.
\par zdaCancel\tab Cancel the disk\f4  \f3 spanning operation.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
4690
Scribble4690
TZMDiskAction type - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike TZM\f1 Status\f0 Disk\cf3\strike0\{linkID=5220\}\cf0 
\par \cf2\strike\f1 OnStatusDisk\cf3\strike0\{linkID=4200\}\cf0\f0 
\par 
\par }
4700
Scribble4700
TZMEncodingOpts type
TZMEncodingOpts;


ZipMstr20:002285
Writing



FALSE
31
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset2 Symbol;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMEncodingOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4710\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMEncodingOpts = (zeoAuto, zeoNone, zeoOEM, zeoUTF8, zeoUPath);
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 the \cf2\strike EncodeAs\cf3\strike0\{linkID=850\}\cf0  values (writing) -
\par zeoUPATH - convert to Ansi but have UTF8 proper name in data
\par zeoUTF - convert to UTF8
\par zeoOEM - convert to OEM
\par zeoNone - store 'as is' (Ansi on Windows)
\par 'default' (zeoAuto) - [in order of preference]
\par \pard{\pntext\f3\'B7\tab}{\*\pn\pnlvlblt\pnf3\pnindent0{\pntxtb\'B7}}\fi-200\li200\tx200\tx2880\tx4320\tx5760\tx7200\tx8640 is Ansi - use zeoNone
\par {\pntext\f3\'B7\tab}can be converted to Ansi - use zeoUPath (unless comment also extended)
\par {\pntext\f3\'B7\tab}use zeoUTF8
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 
\par \cf2\strike Encoded\cf3\strike0\{linkID=6520\}\cf0  (reading)
\par zeoUPATH- use UPATH if available
\par zeoUTF - assume name is UTF8 - convert to Ansi/Unicode
\par zeoOEM - assume name is OEM - convert to Ansi/Unicode
\par zeoNone - assume name is Ansi - convert to Ansi/Unicode
\par zeoAuto - unless flags/versions say otherwise, or it has UTF8 name in data,\f2  \f0 treat it as OEM (FAT) / Ansi (NTFS)
\par 
\par \f2 This is also the type returned by the \cf2\strike TZMDirEntry\cf3\strike0\{linkID=6340\}\cf0 .\cf2\strike Encoded\cf3\strike0\{linkID=6520\}\cf0  property for that particular entry.\f0 
\par }
4710
Scribble4710
TZMEncodingOpts type - See also




Writing



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par 
\par \cf2\b0\strike\f1 EncodeAs\cf3\strike0\{linkID=850\}\cf0\f0 
\par \cf2\strike\f1 Encoding\cf3\strike0\{linkID=880\}
\par \cf2\strike TZMDirEntry.Encoded\cf3\strike0\{linkID=6520\}\cf0 
\par \f0 
\par }
4720
Scribble4720
TZMExtractOverwriteEvent type
TZMExtractOverwriteEvent;


ZipMstr20:002290
Writing



FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMExtractOverwriteEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4730\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMExtractOverwriteEvent = \b procedure\b0 (Sender: TObject; \b const\b0  ForFile: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ; IsOlder: Boolean; \b var\b0  DoOverwrite: Boolean; DirIndex: Integer); \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Occurs when extracting would overwrite an existing file - allows asking what to do.
\par 
\par   \f3  \f1 Sender: TObject\f3            - reference to the ZipMaster component firing the event\f1 
\par \f3   \b\f1 const\b0  ForFile: TZMString; \f3 - the name of the file\f1 
\par \f3   \f1 IsOlder: Boolean; \f3         - True if it would replace an older file\f1 
\par \f3   \b\f1 var\b0  DoOverwrite: Boolean; \f3 - set True to overwrite the existing file \f1 
\par \f3   \f1 DirIndex: Integer\f3          - the entry sequence number\f0 
\par 
\par }
4730
Scribble4730
TZMExtractOverwriteEvent type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnExtractOverwrite\cf3\strike0\{linkID=3810\}\cf0\f0 
\par \cf2\strike\f1 Extract\cf3\strike0\{linkID=2960\}\cf0\f0 
\par }
4740
Scribble4740
TZMExtrOpts type
TZMExtrOpts;


zipmstr20:002295
Writing



FALSE
25
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMExtrOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4750\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMExtrOpts = \b set\b0  \b of\b0  \cf2\strike TZMExtrOptsEnum\cf3\strike0\{linkID=4760\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 options for when \f2 extracting from\f0  a zip file\f2 .
\par \b\f0\fs22 
\par \f2     \b0\f1\fs20 ExtrDirNames,\f3    True = extract directory names\f1  
\par \f3   \f1 ExtrOverWrite, \f3  True = always overwrite existing files\f1 
\par \f3   \f1 ExtrFreshen, \f3    True = overwrite existing older files\f1 
\par \f3   \f1 ExtrUpdate, \f3     True = extract new files and overwrite older existing files\f1 
\par \f3   \f1 ExtrTest, \f3       True = do not extract only test zip file\f1 
\par \f3   \f1 ExtrForceDirs, \f3  True = force \f1 ExtrBaseDir\f3  to exist (if it can)\f1 
\par \f3   \f1 ExtrNTFS\f3 ,       True = where known restore the saved time stamps\f0 
\par 
\par 
\par 
\par }
4750
Scribble4750
TZMExtrOpts type - See also




Writing



FALSE
11
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Extract\cf3\strike0\{linkID=2960\}
\par \cf2\strike ExtrOptions\cf3\strike0\{linkID=1060\}
\par \cf2\strike Encoded\cf3\strike0\{linkID=6520\}
\par \cf2\strike TZMEncodingOpts\cf3\strike0\{linkID=4700\}\cf0\f0 
\par 
\par 
\par }
4760
Scribble4760
TZMExtrOptsEnum type
TZMExtrOptsEnum;


ZipMstr20:002300
Writing



FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMExtrOptsEnum type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4770\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMExtrOptsEnum = (ExtrDirNames, ExtrOverWrite, ExtrFreshen, ExtrUpdate, ExtrTest, ExtrForceDirs, ExtrNTFS);
\par \f0 
\par \b\fs22 Description
\par \f2     \b0\f1\fs20 ExtrDirNames,\f3    True = extract directory names\f1  
\par \f3   \f1 ExtrOverWrite, \f3  True = always overwrite existing files\f1 
\par \f3   \f1 ExtrFreshen, \f3    True = overwrite existing older files\f1 
\par \f3   \f1 ExtrUpdate, \f3     True = extract new files and overwrite older existing files\f1 
\par \f3   \f1 ExtrTest, \f3       True = do not extract only test zip file\f1 
\par \f3   \f1 ExtrForceDirs, \f3  True = force \f1 ExtrBaseDir\f3  to exist (if it can)\f1 
\par \f3   \f1 ExtrNTFS\f3 ,       True = where known restore the saved time stamps\f0 
\par 
\par }
4770
Scribble4770
TZMExtrOptsEnum type - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Extract\cf3\strike0\{linkID=2960\}\cf0\f0 
\par \cf2\strike\f1 TZMExtrOpts\cf3\strike0\{linkID=4740\}
\par \cf2\strike ExtrOptions\cf3\strike0\{linkID=1060\}\cf0\f0 
\par }
4780
Scribble4780
TZMFileCommentEvent type
TZMFileCommentEvent;


ZipMstr20:002305
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMFileCommentEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4790\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMFileCommentEvent = \b procedure\b0 (Sender: TObject; \b const\b0  ForFile: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ; \b var\b0  FileComment: TZMString; \b var\b0  IsChanged: Boolean); \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \f2  \b0\fs20  Occurs when building a zip file to allow setting a comment for each file\b\f0\fs22 
\par \f2     \b0\f1\fs20 Sender: TObject; \f3           - ZipMaster component firing the event\f1 
\par \f3   \b\f1 const\b0  ForFile: TZMString; \f3  - the name of the file\f1 
\par \f3   \b\f1 var\b0  FileComment: TZMString;\f3 - the comment to change or replace\f1  
\par \f3   \b\f1 var\b0  IsChanged: Boolean\f3      - set True to indicate that it was changed\f0 
\par 
\par }
4790
Scribble4790
TZMFileCommentEvent type - See also




Writing



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Add\cf3\strike0\{linkID=2530\}\cf0 
\par \cf2\strike OnFileComment\cf3\strike0\{linkID=3840\}\cf0 
\par \cf2\strike OnFileExtra\cf3\strike0\{linkID=3870\}\cf0 
\par \cf2\strike TZMFileExtraEvent\cf3\strike0\{linkID=4800\}\cf0\f0 
\par 
\par }
4800
Scribble4800
TZMFileExtraEvent type
TZMFileExtraEvent;


ZipMstr20:002310
Writing



FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMFileExtraEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4810\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMFileExtraEvent = \b procedure\b0 (Sender: TObject; \b const\b0  ForFile: \cf2\strike\f2 TZMString\cf3\strike0\{linkID=5280\}\cf0\f1 ; \b var\b0  Data: \cf2\strike TZMRawBytes\cf3\strike0\{linkID=5275\}\cf0 ; \b var\b0  IsChanged: Boolean); \b of\b0  \b object\b0 ;\f2 
\par \f0 
\par \b\fs22 Description
\par \f1  \b0\fs20  Occurs when building a zip file to allow setting a extra for each file\b\f0\fs22 
\par \f1     \b0\fs20 Sender: TObject;              - ZipMaster component firing the event
\par     \b const\b0  ForFile: TZMString;  - the name of the file
\par     \b var\b0  Data: TZMRawBytes;  - the formatted data to set or replace
\par     \b var\b0  IsChanged: Boolean    - set True to indicate that it was changed
\par \f0 
\par 
\par }
4810
Scribble4810
TZMFileExtraEvent type - See also




Writing



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Add\cf3\strike0\{linkID=2530\}\cf0 
\par \cf2\strike OnFileExtra\cf3\strike0\{linkID=3870\}\cf0 
\par \cf2\strike OnFileComment\cf3\strike0\{linkID=3840\}\cf0 
\par \cf2\strike TZMFileFileCommentEvent\cf3\strike0\{linkID=4780\}\cf0\f0 
\par 
\par }
4820
Scribble4820
TZMGetNextDiskEvent type
TZMGetNextDiskEvent;


ZipMstr20:002315
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMGetNextDiskEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4830\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMGetNextDiskEvent = \b procedure\b0 (Sender: TObject; DiskSeqNo, DiskTotal: Integer; Drive: \b String\b0 ; \b var\b0  AbortAction: Boolean); \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \f2   \b0\fs20 Occurs when a different disk is required when working with multi-disk zip files
\par    \f1 Sender: TObject; \f3         - the ZipMaster component firing the event\f1 
\par \f3   \f1 DiskSeqNo, \f3               - the number of the required disk\f1 
\par \f3   \f1 DiskTotal: Integer; \f3      - the total number of disks (if known)\f1 
\par \f3   \f1 Drive: \b String\b0 ; \f3           - the disk drive\f1 
\par \f3   \b\f1 var\b0  AbortAction: Boolean\f3  - set True to abort\f0 
\par }
4830
Scribble4830
TZMGetNextDiskEvent type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TZMGetNextDiskEvent type >>>
\par 
\par }
4840
Scribble4840
TZMMergeOpts type
TZMMergeOpts;


ZipMstr20:002320
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMMergeOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4850\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMMergeOpts = (zmoConfirm, zmoAlways, zmoNewer, zmoOlder, zmoNever);
\par \f0 
\par \b\fs22 Description
\par \f2   \b0\fs20 Controls merging files with \cf2\strike AddZippedFiles \cf3\strike0\{linkID=2620\}\cf0 and \cf2\strike CopyZippedFiles\cf3\strike0\{linkID=2840\}
\par \cf0\f3   \f1 zmoConfirm, \f3  - Ask via \cf2\strike OnCopyZippedOverwrite \cf3\strike0\{linkID=3720\}\cf0 event on each conflict\f1 
\par \f3   \f1 zmoAlways,\f3    - always replace the existing file\f1  
\par \f3   \f1 zmoNewer, \f3    - replace the existing if the new file is newer\f1 
\par \f3   \f1 zmoOlder, \f3    - replace the existing if the new file is older\f1  
\par \f3   \f1 zmoNever\f3 ,\f1  \f3    - never replace the existing file\f0 
\par }
4850
Scribble4850
TZMMergeOpts type - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\fs22 
\par \cf2\b0\strike\f1\fs20 AddZippedFiles \cf3\strike0\{linkID=2620\}\cf0 
\par \cf2\strike CopyZippedFiles\cf3\strike0\{linkID=2840\}
\par \pard\cf2\strike OnCopyZippedOverwrite\cf3\strike0\{linkID=3720\}\cf0\f0 
\par }
4860
Scribble4860
TZMMessageEvent type
TZMMessageEvent;


ZipMstr20:002325
Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMMessageEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4870\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMMessageEvent = \b procedure\b0 (Sender: TObject; ErrCode: Integer; \b const\b0  ErrMsg: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ); \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20  Occurs for errors or diagnostic messages
\par \f3   \f1 Sender: TObject; \f3        - the ZipMaster component firing the event\f1 
\par \f3   \f1 ErrCode: Integer; \f3       - the error identifier number (or -1)\f1 
\par \f3   \b\f1 const\b0  ErrMsg: TZMString\f3  - the message\f0 
\par 
\par }
4870
Scribble4870
TZMMessageEvent type - See also




Writing



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnMessage\cf3\strike0\{linkID=3930\}\cf0 
\par \cf2\strike Verbose\cf3\strike0\{linkID=2230\}\cf0 
\par \cf2\strike Trace\cf3\strike0\{linkID=2080\}\cf0\f0 
\par 
\par }
4880
Scribble4880
TZMNewNameEvent type
TZMNewNameEvent;


ZipMstr20:002330
Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMNewNameEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4890\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMNewNameEvent = \b procedure\b0 (Sender: TObject; SeqNo: Integer); \b of\b0  \b object\b0 ;\f2 
\par \f0 
\par \b\fs22 Description
\par \pard\b0\f1\fs20   Occurs after reading the central directory to indicate that another entry is available\f3  and gives you the opportunity to fill in for example a \f4\fs24 TListView\f3\fs20 .
\par SeqNo is a number from 1 to the number of entries in the zipfile and can be used to reset a ListView when the value is 1 and as sequence number in a \f4\fs24 TStringGrid.
\par \pard\tx165\tx425\f3\fs20 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
4890
Scribble4890
TZMNewNameEvent type - See also




Writing



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnNewName\cf3\strike0\{linkID=3960\}\cf0 
\par \cf2\strike List\cf3\strike0\{linkID=3280\}\cf0 
\par \cf2\strike OnDirUpdate\cf3\strike0\{linkID=3780\}\cf0\f0 
\par 
\par }
4900
Scribble4900
TZMOvrOpts type
TZMOvrOpts;


zipmstr20:002340
Writing



FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMOvrOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4910\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMOvrOpts = (ovrAlways, ovrNever, ovrConfirm);\f2 
\par \f0 
\par \pard\b\fs22 Description
\par \b0\f1\fs20 Controls overwriting existing files when SFX extracts files.
\par Set by \cf2\strike SFXOverWriteMode\cf3\strike0\{linkID=1870\}\cf0 .\f3 
\par \pard\sb115\sa115\tx1985\b Value\tab Meaning\fs24 
\par \pard\tx1985\b0\fs20 OvrConfirm\tab Ask user when each file is found  (The default).
\par OvrAlways\tab Always overwrite existing files.
\par OvrNever\tab Never overwrite - skip those files.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
4910
Scribble4910
TZMOvrOpts type - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SFXOverWriteMode\cf3\strike0\{linkID=1870\}
\par \cf2\strike Working with SFX\cf3\strike0\{linkID=305\}\cf0\f0 
\par 
\par }
4920
Scribble4920
TZMPasswordErrorEvent type
TZMPasswordErrorEvent;


ZipMstr20:002345
Writing



FALSE
26
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fnil\fcharset0 Courier New;}{\f5\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMPasswordErrorEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4930\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMPasswordErrorEvent = \b procedure\b0 (Sender: TObject; IsZipAction: Boolean; \b var\b0  NewPassword: \b String\b0 ; \b const\b0  ForFile: \cf2\strike\f2 TZMString\cf3\strike0\{linkID=5280\}\cf0\f1 ; \b var\b0  RepeatCount: Longword; \b var\b0  Action: TMsgDlgBtn); \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20  Occurs for when a password is incorrect or required
\par   Sender: TObject;         \tab - the ZipMaster component firing the event
\par   IsZipAction: Boolean      \tab - True if compress
\par   \b var\b0  NewPassword: \b String\b0   \tab - the new password
\par   \b const\b0  ForFile: TZMString  \tab - the name of the file
\par \pard\tx355   \b var\b0  RepeatCount: Longword \tab - number of retries remaining, first set to\f3  the \cf2\strike PasswordReqCount\strike0\{linkID=1570\}\cf0  number and decremented on each event call.
\par When needed you can modify RepeatCount and set it to value from 0 to 15 this will not influence PasswordReqCount.\f2 
\par \f1   \b var\b0  Action: TMsgDlgBtn    \tab\f4 -\f3  is the action to take when returning from this event, possible actions are: \f5 mb\f3 Ok, \f5 mb\f3 Cancel, \f5 mb\f3 CancelAll or \f5 mb\f3 Abort. Default is \f5 mb\f3 Ok.
\par 
\par \cf5\b NOTE:\cf0\b0\tab This event will be called at most 15 times per file even when you try to increase RepeatCount multiple times.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f4  \f0 
\par 
\par 
\par }
4930
Scribble4930
TZMPasswordErrorEvent type - See also




Writing



FALSE
12
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnPasswordError\cf3\strike0\{linkID=3990\}\cf0 
\par \cf2\strike GetExtrPassword\cf3\strike0\{linkID=3160\}\cf0 
\par \cf2\strike GetAddPassword\cf3\strike0\{linkID=3120\}
\par \cf2\strike Password Notes\cf3\strike0\{linkID=250\}
\par \cf2\strike PasswordReqCount\cf3\strike0\{linkID=1570\}\cf4\lang1033\f0 
\par \cf0\lang3081 
\par 
\par }
4940
Scribble4940
TZMProgressDetailsEvent type
TZMProgressEvent;


zipmstr20:002350
Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMProgressEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4950\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMProgressEvent = \b procedure\b0 (Sender: TObject; details: \cf2\strike T\f2 ZM\f1 ProgressDetails\cf3\strike0\{linkID=5950\}\cf0 ) \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20  Occurs during operations to allow updating of "status" or "Progress" bars.
\par \f2   \f1 Sender: TObject; \f2          - the ZipMaster component firing the event
\par \f3     \f1 details: \cf2\strike T\f2 ZM\f1 ProgressDetails\cf3\strike0\{linkID=5950\}\cf0\f0 
\par 
\par }
4950
Scribble4950
TZMProgressEvent type - See also




Writing



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 TZMProgressType\cf3\strike0\{linkID=4960\}\cf0 
\par \cf2\strike TZMProgressDetails\cf3\strike0\{linkID=5950\}\cf0 
\par \cf2\strike OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
4960
Scribble4960
TZMProgressType type
TZMProgressType;


ZipMstr20:002355
Writing



FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMProgressType type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4970\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMProgressType = (NewFile, ProgressUpdate, EndOfBatch, TotalFiles2Process, TotalSize2Process, NewExtra, ExtraUpdate);
\par \f0 
\par \pard\sb115\sa195\tx355\b\fs22 Description\f2\fs24 
\par \pard\sa195\tx355\cf4\b0\fs20 Intended for "status bar" or "progress bar" updates.  Criteria for this event:\cf0 
\par \pard\fi-2545\li2835\tx565\tx2835\cf4 ProgressType is defined as one of the types below:\cf0 
\par NewFile\f3                     - \f2 Starting to process a new file. (gives you  the filename and total uncompressed filesize for the given file.)
\par ProgressUpdate\f3         - \f2 Every xxxK bytes while processing a file. The actual progress \f4 '\f2 xxx\f4 '\f2  is given in FileSize.
\par \pard\sa35\tx355\f3      \f2 EndOfBatch\tab\f3             - \f2 Completed processing on a (batch of) file(s).
\par \f3      \f2 TotalFiles2Process\tab\f3 - \f2 At the start of processing a (batch of) file(s) with the Add, Extract or Test method you will get the total number of files which will be processed by the given method.
\par \pard\fi-2545\li2835\tx565\tx2835\f3 To\f2 talSize2Process\f3     - \f2 At the start of processing a (batch of) file(s) with the Add, Extract or Test method this gives the total uncompressed file size\f3  \f2 which will be processed by the given method. This can be used to show a progress bar for the entire job.
\par \f3                                  \f2  This size is also available in the \cf2\strike TotalSizeToProcess\strike0\{linkID=2050\}\cf0  property.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
4970
Scribble4970
TZMProgressType type - See also




Writing



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0 
\par \cf2\strike TZMProgressDetails\cf3\strike0\{linkID=5970\}\cf0 
\par \cf2\strike TZMProgressDetailsEvent\cf3\strike0\{linkID=4940\}\cf0\f0 
\par 
\par }
4980
Scribble4980
TZMRenameOpts type
TZMRenameOpts;


ZipMstr20:002360
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMRenameOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%4990\}\cf4\{keepn\}
\par \cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMRenameOpts = (htrDefault, htrOnce, htrFull);
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20  Used by \cf2\strike Rename\cf3\strike0\{linkID=3380\}\cf0  to control finding files to rename.
\par     \f1 htrDefault\f3   - renames each exact matching name\f1 
\par \f3  \f1  htrOnce\f3      - rename the first matching name\f1 
\par \f3  \f1  htrFull\f3      - rename the first name matching wildcard search\f0 
\par 
\par }
4990
Scribble4990
TZMRenameOpts type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Rename\cf3\strike0\{linkID=3380\}\cf0\f0 
\par 
\par }
5000
Scribble5000
TZMReplaceOpts type
TZMReplaceOpts;


ZipMstr20:002365
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMReplaceOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5010\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMReplaceOpts = (rplConfirm, rplAlways, rplNewer, rplNever);
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Used by \cf2\strike AddZippedFiles\cf3\strike0\{linkID=2620\}\cf0  and \cf2\strike CopyZippedFiles\cf3\strike0\{linkID=2840\}\cf0  to resolve merging files of the same name.
\par     \f1 rplConfirm\f3   - fire \cf2\strike OnCopyZippedOverwrite\cf3\strike0\{linkID=3720\}\cf0  for user which file to keep\f1 
\par \f3   \f1 rplAlways\f3    - always overwrite the existing file\f1 
\par \f3   \f1 rplNewer\f3     - compare file stamps and use the newer file\f1 
\par \f3  \f1  rplNever\f3     - keep the existing file\f0 
\par 
\par }
5010
Scribble5010
TZMReplaceOpts type - See also




Writing



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\strike\f1 AddZippedFiles\cf3\strike0\{linkID=2620\}\cf0  
\par \pard\cf2\strike CopyZippedFiles\cf3\strike0\{linkID=2840\}\cf0 
\par \cf2\strike OnCopyZippedOverwrite\cf3\strike0\{linkID=3720\}\cf0  \f0 
\par 
\par }
5020
Scribble5020
TZMSetAddNameEvent type
TZMSetAddNameEvent;


ZipMstr20:002370
Writing



FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}{\f5\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMSetAddNameEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5030\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMSetAddNameEvent = \b procedure\b0 (Sender: TObject; \b var\b0  FileName: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ; \b const\b0  ExtName: TZMString; \b var\b0  IsChanged: Boolean) \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20    \f3 Occurs\f4  only\f3  when adding files to the archive\f4 .\f2 
\par \f5   \f1 Sender: TObject \f5          - the ZipMaster component firing the event
\par \f2     \b\f1 var\b0  FileName: TZMString\f5   - the new name\f1  
\par \f5   \b\f1 const\b0  ExtName: TZMString \f5 - the external path/name\f1 
\par \f5   \b\f1 var\b0  IsChanged: Boolean\f5    - set True if the name was changed\f0 
\par 
\par 
\par }
5030
Scribble5030
TZMSetAddNameEvent type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 On\f0 SetAddName\cf3\strike0\{linkID=4050\}\cf0 
\par 
\par }
5040
Scribble5040
TZMSetCompLevel type
TZMSetCompLevel;


ZipMstr20:002375
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}{\f5\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMSetCompLevel type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5050\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMSetCompLevel = \b procedure\b0 (Sender: TObject; \b const\b0  ForFile: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ; \b var\b0  level: Integer; \b var\b0  IsChanged: Boolean) \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20    \f3 Occurs\f4  only\f3  when adding files to the archive\f4 .\f2 
\par \f5   \f1 Sender: TObject \f5          - the ZipMaster component firing the event
\par \f2     \b\f1 const\b0  ForFile: TZMString\f5  - the name of the file\f1 
\par \f5  \f1  \b var\b0  level: Integer\f5        - the new compression level (0..9)\f1 
\par \f5  \f1  \b var\b0  IsChanged: Boolean\f5    - set True if level is changed\f0 
\par 
\par }
5050
Scribble5050
TZMSetCompLevel type - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnSetCompLevel\cf3\strike0\{linkID=4110\}\cf0 
\par \cf2\strike AddCompLevel\cf3\strike0\{linkID=430\}\cf0 
\par \cf2\strike Filespec_Switches\cf3\strike0\{linkID=1110\}\cf0\f0 
\par }
5060
Scribble5060
TZMSetExtNameEvent type
TZMSetExtNameEvent;


ZipMstr20:002380
Writing



FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}{\f5\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMSetExtNameEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5070\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMSetExtNameEvent = \b procedure\b0 (Sender: TObject; \b var\b0  FileName: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ; \b const\b0  BaseDir: TZMString; \b var\b0  IsChanged: Boolean); \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20    \f3 Occurs\f4  only\f3  when \f4 extract\f3 ing files to the archive\f4  to allow changing the filename.\f2 
\par \f5   \f1 Sender: TObject \f5          - the ZipMaster component firing the event
\par \f2     \b\f1 var\b0  FileName: TZMString\f5   - the new name\f1  
\par \f5   \b\f1 const\b0  BaseDir: TZMString \f5 - the destination path\f1 
\par \f5   \b\f1 var\b0  IsChanged: Boolean\f5    - set True if the name was changed\f0 
\par 
\par 
\par }
5070
Scribble5070
TZMSetExtNameEvent type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 On\f0 SetExtName\cf3\strike0\{linkID=4080\}\cf0 
\par 
\par }
5080
Scribble5080
TZMSkippedEvent type
TZMSkippedEvent;


ZipMstr20:002385
Writing



FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMSkippedEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5090\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMSkippedEvent = \b procedure\b0 (Sender: TObject; \b const\b0  ForFile: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ; SkipType: TZMSkipTypes; \b var\b0  ExtError: Integer) \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Fired when an operation fails to process an instruction or file.
\par \f3   \f1 Sender: TObject \f3          - the ZipMaster component firing the event
\par \f2     \b\f3 const\b0\f1  \f3 For\f1 File: TZMString\f3  - the new name\f1  
\par \f3   \f1 SkipType: \cf2\strike\f2 TZMSkipTypes\cf3\strike0\{linkID=5100\} \cf0\f3 - \f1  
\par \f3   \b\f1 var\b0  ExtError: Integer\f3     - o\f2 n entry ExtError will be the >= 0 if \cf2\strike NoSkipping \cf3\strike0\{linkID=1470\}\cf0 for that \cf2\strike SkipType \cf3\strike0\{linkID=5100\}\cf0 is false
\par       If ExtError < 0 upon return from a handler the operation will abort.
\par \f0 
\par }
5090
Scribble5090
TZMSkippedEvent type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 On\f0 Skipped\cf3\strike0\{linkID=4140\}\cf0 
\par 
\par }
5100
Scribble5100
TZMSkipTypes type
TZMSkipTypes;


zipmstr20:002390
Writing



FALSE
40
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMSkipTypes type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5110\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMSkipTypes = (stOnFreshen, stNoOverwrite, stFileExists, stBadPassword, stBadName, stCompressionUnknown, stUnknownZipHost, stZipFileFormatWrong, stGeneralExtractError, stUser, stCannotDo, stNotFound, stNoShare, stNoAccess, stNoOpen\f2 , stDupName, stReadError, stSizeChange\f1 );
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Identifies which skip type is not allowed in the \cf2\strike NoSkipping\cf3\strike0\{linkID=1470\}\cf0  property causing the \cf2\strike OnSkipped\cf3\strike0\{linkID=4140\}\cf0  event to be fired.
\par These are conditions that may under different circumstances be an error or may safely be ignored.\b\f0\fs22 
\par 
\par \pard\tx240\tx3140\tx4200\tx4240\b0\f2\fs20\tab\b\fs22 Value\b0\fs20\tab\b\fs22 Default\b0\fs20\tab\b\fs22 Condition\f0 
\par \pard\tx240\tx3180\tx4240\tx8640\b0\f2\fs20\tab\f1 stOnFreshen\f2\tab false\tab existing file is newer than\f1  \f2 the current file\f1 
\par \f2\tab\f1 stNoOverwrite \f2\tab false\tab did not overwrite existing\f1 
\par \f2\tab\f1 stFileExists \f2\tab false\tab file exists\f1 
\par \f2\tab\f1 stBadPassword \f2\tab false\tab cannot extract because of bad password\f1 
\par \f2\tab\f1 stBadName \f2\tab false\tab skipped file because its name is invalid\f1 
\par \f2\tab\f1 stCompressionUnknown \f2\tab false\tab skipped extract because we cannot handle its method\f1 
\par \f2\tab\f1 stUnknownZipHost \f2\tab false\tab unknown host, cannot handle it\f1 
\par \f2\tab\f1 stZipFileFormatWrong\f2\tab false\tab bad file format\f1 
\par \f2\tab\f1 stGeneralExtractError \f2\tab false\tab something went wrong\f1 
\par \f2\tab\f1 stUser \f2\tab false\tab user command that the file is skipped\f1 
\par \f2\tab\f1 stCannotDo \f2\tab false\tab could not handle the operation\f1 
\par \f2\tab\f1 stNotFound \f2\tab false\tab file or filespec was not found\f1 
\par \f2\tab\f1 stNoShare \f2\tab false\tab file share problem\f1 
\par \f2\tab\f1 stNoAccess \f2\tab false\tab could not access file (already in use)\f1 
\par \f2\tab\f1 stNoOpen\f2  \tab false\tab could not open the file
\par \tab stDupName\tab\b true\b0\tab zip operation caused duplicate internal name
\par \tab\tab\tab  false will only keep the first file producing that name.\f1 
\par \f2\tab\f1 st\f2 ReadError \tab\b true\b0\tab file read error during zip operation  (1.9.0.97)\f1 
\par \f2\tab\f1 st\f2 SizeChange \tab false\tab the file changed during zip operation (1.9.0.97)
\par 
\par 
\par \f0 
\par \pard\tx240\tx3200\tx7200\tx8640 
\par }
5110
Scribble5110
TZMSkipTypes type - See also




Writing



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\strike\f1 NoSkipping \cf3\strike0\{linkID=1470\}
\par \cf2\strike TZMSkipAborts\cf3\strike0\{linkID=5120\}\cf0 
\par \cf2\strike TZMSkippedEvents\cf3\strike0\{linkID=5080\}\cf0 .\f0 
\par \pard\cf2\strike\f1 OnSkipped\cf3\strike0\{linkID=6640\}\cf0\f0 
\par 
\par }
5120
Scribble5120
TZMSkipAborts type




Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMSkipAborts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5130\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMS\f2 kipAborts\f1  = \b set\b0  \b of\b0  \cf2\strike TZMS\f2 kipTypes\cf3\strike0\f1\{linkID=5100\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20 Type for the property \cf2\strike NoSkipping \cf3\strike0\{linkID=1470\}\cf0 which controls default action for \cf2\strike skip events\cf3\strike0\{linkID=5080\}\cf0 .\f0 
\par \pard\cf4 
\par }
5130
Scribble5130
TZMSkipAborts Type - See also




Writing



FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\fs22 
\par \cf2\b0\strike\f1\fs20 TZMSkipTypes\cf3\strike0\{linkID=5100\}\cf0 
\par \cf2\strike NoSkipping \cf3\strike0\{linkID=1470\}\cf0 
\par \cf2\strike TZMSkippedEvents\cf3\strike0\{linkID=5080\}\cf0 .
\par \pard\cf2\strike OnSkipped\cf3\strike0\{linkID=4140\}\cf0\f0 
\par 
\par \cf4 
\par 
\par 
\par }
5140
Scribble5140
TZMSpanOpts type
TZMSpanOpts;


zipmstr20:002395
Done



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMSpanOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5150\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMSpanOpts = \b set\b0  \b of\b0  \cf2\strike TZMSpanOptsEnum\cf3\strike0\{linkID=5160\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 options for when \f2 handling\f0  a \f2 multipart \f0 zip file
\par 
\par }
5150
Scribble5150
TZMSpanOpts type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TZMSpanOpts type >>>
\par 
\par }
5160
Scribble5160
TZMSpanOptsEnum type
TZMSpanOptsEnum;


zipmstr20:002400
Done



FALSE
29
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}{\f4\fswiss\fprq2\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMSpanOptsEnum type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5170\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMSpanOptsEnum = (spNoVolumeName, spCompatName, spWipeFiles, spTryFormat, spAnyTime, spExactName);
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Options when handling a multipart zip file.
\par Set in the \cf2\strike SpanOptions\cf3\strike0\{linkID=1960\}\cf0  property.
\par \f0 
\par \pard\tx260\tx880\tx4320\tx5760\tx7200\tx8640\b\f3\tab\f1 spNoVolumeName
\par \f3\tab\tab\b0\f4 If \b True\b0  then will use numbered files on removable drives\b\f1 
\par \f3\tab\f1 spCompatName
\par \b0\f4\tab\tab If \b True \b0 then uses names of the form name.zip + name.z01 ... \b\f1 
\par \f3\tab\f1 spWipeFiles 
\par \b0\f4\tab\tab If \b True\b0 , removes the files from the \ul removable drive\ulnone  before writing.     \cf5\b WARNING\cf0\b0 : Deletes all files and Directories\b\f1 
\par \f3\tab\f1 spTryFormat
\par \b0\f4\tab\tab If \b True \b0 and spWipeFiles, try to Format removable disk.    \cf5\b WARNING\cf0\b0 : Wipes all files - non-recoverable\b\f1 
\par \f3\tab\f1 spAnyTime 
\par \f3\tab\tab\b0\f2 If \b True\b0 , does not insist that all parts have the same time stamp\b\f1 
\par \f3\tab\f1 spExactName
\par \f3\tab\tab\b0\f2 If \b True\b0 , it attempts to open the specified file, otherwise it trys to locate the last part\b\f1 
\par \f0 
\par }
5170
Scribble5170
TZMSpanOptsEnum type - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 SpanOptions\cf3\strike0\{linkID=1960\}
\par \cf2\strike Handling of MultiVolume Zip parts\cf3\strike0\{linkID=260\}\cf0\f0 
\par 
\par }
5180
Scribble5180
TZMStateChange type
TZMStateChange;


ZipMstr20:002405
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMStateChange type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5190\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMStateChange = \b procedure\b0 (Sender: TObject; state: \cf2\strike TZMStates\cf3\strike0\{linkID=5200\}\cf0 ; \b var\b0  NoCursor: boolean); \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20    Fired when the component state changes to allow updating status indicators or blocking other operations.\f0 
\par 
\par }
5190
Scribble5190
TZMStateChange type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 On\f0 StateChange\cf3\strike0\{linkID=4170\}\cf0 
\par 
\par }
5200
Scribble5200
TZMStates type
TZMStates;


zipmstr20:002410
Writing



FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMStates type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5210\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMStates = (zsDisabled, zsIdle, zsBusy);
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Possible states of the component used in the 'state' parameter in the \cf2\strike OnStateChange\cf3\strike0\{linkID=4170\}\cf0  event.
\par 
\par \pard\tx40\tx300\tx1440\f2\tab zsDisabled\tab the component is not active
\par \tab zsIdle\tab the component is active and not busy
\par \tab zsBusy\tab the component is active and executing an operation
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par 
\par }
5210
Scribble5210
TZMStates type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TZMStates type >>>
\par 
\par }
5220
Scribble5220
TZMStatusDiskEvent type
TZMDiskAction;TZMStatusDiskEvent;


ZipMstr20:002415
Writing



FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fswiss Arial;}{\f4\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMStatusDiskEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5230\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMStatusDiskEvent = \b procedure\b0 (Sender: TObject; PreviousDisk: Integer; PreviousFile: \b String\b0 ; Status: TZMZipDiskStatus; \b var\b0  Action: TZMDiskAction); \b of\b0  \b object\b0 ;
\par \f0 
\par \pard\b\fs22 Description
\par \b0\f2\fs20     Fired \f3 when spanning disks and trying to overwrite an existing file.\f2 
\par \f4   \f1 Sender: TObject \f4          - the ZipMaster component firing the event
\par \pard\tx165\tx425\f2     \f1 PreviousDisk: Integer\f4     -\f3  when applicable the disknumber of the previous disk which could be overwritten.\f1  
\par \f4   \f1 PreviousFile: \b String\f4      - \b0\f3 contains the filename of the zip archive.\f1  
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f4   \f1 Status: \cf2\strike TZMZipDiskStatus\cf3\strike0\{linkID=5430\}\cf0  
\par \f4   \b\f1 var\b0  Action: \cf2\strike TZMDiskAction\cf3\strike0\{linkID=4680\}\cf0  
\par \f0 
\par 
\par }
5230
Scribble5230
TZMStatusDiskEvent type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 On\f0 StatusDisk\cf3\strike0\{linkID=4200\}\cf0 
\par 
\par }
5240
Scribble5240
TZMStreamEvent type
TZMStreamEvent;


ZipMstr20:002420
Writing



FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red128\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMStreamEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5250\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMStreamEvent = \b procedure\b0 (Sender: TObject; opr: TZ\f2 M\f1 StreamOp; snumber: integer; \b var\b0  strm: TStream; \b var\b0  stat: TZ\f2 M\f1 SStats; \b var\b0  done: Boolean) \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20     Fired \f4 during add or extract involving a stream\f3 
\par \f2   \f1 Sender: TObject \f2          - the ZipMaster component firing the event
\par   \f1 opr: \cf2\strike TZ\f2 M\f1 StreamOp\cf3\strike0\{linkID=5490\}\f2      \cf0 - the operation required\f1 
\par \f2  \f1  snumber: integer\f2          - the stream number (also index in \cf2\strike Pipes\cf3\strike0\{linkID=1600\}\cf0 )\f1 
\par \f2  \f1  \b var\b0  strm: TStream\f2         - the stream object\f1 
\par \f2  \f1  \b var\b0  stat: \cf2\strike TZ\f2 M\f1 SStats\cf3\strike0\{linkID=5470\}\cf0\f2        - the details required form some operations\f1 
\par \f2  \f1  \b var\b0  done: Boolean\f2         - Set True if operation was handled
\par 
\par \cf5\b\fs24 Note:\cf0\b0\fs20  This is fired before the default Pipes are acted upon.\f0 
\par 
\par }
5250
Scribble5250
TZMStreamEvent type - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 On\f0 Stream\cf3\strike0\{linkID=4230\}\cf0 
\par \cf2\strike\f1 Pipes\cf3\strike0\{linkID=1600\}\cf0\f0 
\par 
\par }
5260
Scribble5260
TZMLoadStrEvent type
TZMStrEvent;


ZipMstr20:002425
Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMLoadStrEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5270\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\f1\fs20 T\f0 ZipMstr20\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 type\b0  TZM\f3 Load\f2 StrEvent = procedure(Ident: Integer; var DefStr: String) of object;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20   Fired when a string resource is required.
\par 
\par Note: This event is fired from all TZipMaster components - only the last handler set in OnLoadStr will receive it.\f0 
\par 
\par }
5270
Scribble5270
TZMLoadStrEvent type - See also




Writing



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 ZipLoadStr\cf3\strike0\{linkID=3510\}\cf0\f0 
\par \cf2\strike\f1 OnLoadStr\cf3\strike0\{linkID=4265\}\cf0 
\par \cf2\strike Language\cf3\strike0\{linkID=1320\}\cf0 
\par \cf2\strike LanguageInfo\cf3\strike0\{linkID=1350\}\cf0\f0 
\par 
\par }
5275
Scribble5275
TZMRawBytes
TZMRawBytes;TZMWideString;



Writing



FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;\red0\green255\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 TZMRawBytes\cf0\b0\f1\fs20 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\fs16\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZipMstr19\cf4\strike0\{linkID=330\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \cf5\b0\f0\fs18 D2009 or later (Unicode)\cf0\b\f1\fs22 
\par \f2\fs20 type\b0  TZM\f3 RawBytes\f2  = \f3 RawByte\f2 String;
\par \cf5\f0\fs18 D2007 or earlier\cf0\b\f1\fs22 
\par \f2\fs20 type\b0  TZM\f3 RawBytes\f2  = AnsiString;
\par \f1 
\par \b\fs22 Description
\par \f0\fs18 This string type is used for a string of binary bytes.
\par \f1\fs22 
\par \b0\f0\fs20 On Unicode versions (D2009 or later) this is a standard RawByteString.
\par \pard\f1 
\par 
\par }
5280
Scribble5280
TZMString type
TZMRawBytes;TZMString;TZMWideString;


ZipMstr20:002430
Writing



FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;\red0\green255\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMString type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZipMstr19\cf4\strike0\{linkID=330\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \cf5\b0\f1\fs18 D2009 or later (Unicode)\cf0\b\f0\fs22 
\par \f2\fs20 type\b0  TZMString = \f3 Unicode\f2 String;
\par \cf5\f1\fs18 D2007 or earlier\cf0\b\f0\fs22 
\par \f2\fs20 type\b0  TZMString = AnsiString;
\par \f0 
\par \b\fs22 Description
\par \f1\fs18 This string type is used for file entry names to enable handling of international names.
\par \f0\fs22 
\par \b0\f1\fs20 On Unicode versions (D2009 or later) this is a standard String.
\par 
\par On earlier versions its contents will be either AnsiString or, if \cf3\strike UseUTF8 \cf4\strike0\{linkID=2200\}\cf0 is True, UTF8.  \f0 
\par 
\par }
5290
Scribble5290
TZMTickEvent type
TZMTickEvent;


ZipMstr20:002450
Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fswiss\fcharset0 Arial;}{\f4\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMTickEvent type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5300\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMTickEvent = \b procedure\b0 (Sender: TObject); \b of\b0  \b object\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20     Fired \f3 during operations to allow indicating that something is happening.\f2 
\par \f4   \f1 Sender: TObject \f4          - the ZipMaster component firing the event
\par \f0 
\par 
\par }
5300
Scribble5300
TZMTickEvent type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TZMTickEvent type >>>
\par 
\par }
5310
Scribble5310
TZMWideString type
TZMRawBytes;TZMString;TZMWideString;


ZipMstr20:002460
Writing



FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red0\green255\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMWideString type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5320\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \cf5\b0\f1\fs18 D2009 or later (Unicode)\cf0\b\f0\fs22 
\par \f2\fs20 type\b0  TZM\f3 Wide\f2 String = \f3 Unicode\f2 String;
\par \cf5\f1\fs18 D2007 or earlier\cf0\b\f0\fs22 
\par \f2\fs20 type\b0  TZM\f3 Wide\f2 String = \f3 Wide\f2 String;
\par \f0 
\par \f2 
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 A string of Wide characters (Unicode).
\par The actual type depends upon the compiler version.\f0 
\par 
\par }
5320
Scribble5320
TZMWideString type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 TZMString\cf3\strike0\{linkID=5280\}\cf0\f0 
\par 
\par }
5390
Scribble5390
TZMWriteOpts type
TZMWriteOpts;


ZipMstr20:002480
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMWriteOpts type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5400\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMWriteOpts = \b set\b0  \b of\b0  \cf2\strike TZMWriteOptsEnum\cf3\strike0\{linkID=5410\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 other options
\par 
\par }
5400
Scribble5400
TZMWriteOpts type - See also




Writing



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddOptions\cf3\strike0\{linkID=470\}\cf0 
\par \cf2\strike ExtrOptions\cf3\strike0\{linkID=1060\}
\par \cf2\strike MaxVolumeSize\cf3\strike0\{linkID=1380\}\cf0\f0 
\par 
\par }
5410
Scribble5410
TZMWriteOptsEnum type
TZMWriteOptsEnum;


ZipMstr20:002485
Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMWriteOptsEnum type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5420\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMWriteOptsEnum = (zwoDiskSpan, zwoZipTime, zwoForceDest);
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Controls options when writing or rewriting a zip archive\f0 
\par \f1 
\par \f3    \f1 zwoDiskSpan\f3     - split (span) multiple parts\f1 
\par \f3   \f1  zwoZipTime\f3      - set the archive time stamp to the latest entry\f1 
\par \f3   \f1  zwoForceDest\f3    - try to force the destination to exist\f0 
\par }
5420
Scribble5420
TZMWriteOptsEnum type - See also




Writing



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddOptions\cf3\strike0\{linkID=470\}\cf0 
\par \cf2\strike ExtrOptions\cf3\strike0\{linkID=1060\}
\par \cf2\strike MaxVolumeSize\cf3\strike0\{linkID=1380\}\cf0\f0 
\par 
\par 
\par }
5430
Scribble5430
TZMZipDiskStatus type
TZMZipDiskStatus;


ZipMstr20:002490
Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMZipDiskStatus type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5440\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMZipDiskStatus = \b set\b0  \b of\b0  \cf2\strike TZMZipDiskStatusEnum\cf3\strike0\{linkID=5450\}\cf0 ;
\par \f0 
\par \pard\tx165\tx425\b\fs22 Description\b0\f2\fs20 
\par \pard\fi-1985\li1985\tx1985\f3 Disk staus values as reported in the \cf2\strike OnStatusDisk\cf3\strike0\{linkID=4200\}\cf0  event.\f2 
\par \pard\tx425\fs18 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0\fs20 
\par 
\par }
5440
Scribble5440
TZMZipDiskStatus type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnStatusDisk\cf3\strike0\{linkID=4200\}\cf0\f0 
\par 
\par }
5450
Scribble5450
TZMZipDiskStatusEnum type
TZMZipDiskStatusEnum;


ZipMstr20:002495
Writing



FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss Arial;}{\f3\froman\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMZipDiskStatusEnum type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5460\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZMZipDiskStatusEnum = (zdsEmpty, zdsHasFiles, zdsPreviousDisk, zdsSameFileName, zdsNotEnoughSpace);
\par \f0 
\par \b\fs22 Description
\par \pard\tx165\tx425\b0\f2\fs20 TZipDiskStatus is a set and can take one or more of the following values:
\par \pard\fi-1985\li1985\sb115\sa115\tx1985\b\fs24 Value\tab Meaning
\par \pard\fi-1985\li1985\tx1985\b0\fs20 zdsEmpty\tab The disk is empty and ready to use.
\par zdsHasFiles\tab The disk is not empty and contains one or more file(s).
\par zdsPreviousDisk\tab It\f3 '\f2 s possibly a previous disk from the backup set.
\par zdsSameFileName\tab The disk contains a file with the same filename as the zip archive.
\par zdsNotEnoughSpace\tab There is not enough space on the disk taken into account \cf2\strike KeepFreeOnDisk1\strike0\{linkID=1290\}\cf0 , \cf2\strike MaxVolumeSize\strike0\{linkID=1260\}\cf0  and \cf2\strike MinFreeVolumeSize\strike0\{linkID=1440\}\cf0 .
\par \pard\tx425\fs18 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0\fs20 
\par 
\par }
5460
Scribble5460
TZMZipDiskStatusEnum type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike TZMZipDiskStatus\f1 Event\cf3\strike0\{linkID=5430\}\cf0\f0 
\par 
\par }
5470
Scribble5470
TZMSStats type
TZMSStats;


ZipMstr20:002500
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMSStats type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5480\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZ\f2 M\f1 SStats = \b packed\b0  \b record\b0  Size: Int64; Date: Cardinal; Attrs: Cardinal; \b end\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20   Used to identify stream properties for Add or Extract operations.
\par 
\par     \f1 Size: Int64\f2      - the size to be zipped\f1 
\par \f2  \f1  Date: Cardinal\f2   - the entry date\f1 
\par \f2   \f1 Attrs: Cardinal\f2  - DOS attributes for the entry\f0 
\par 
\par }
5480
Scribble5480
TZMSStats type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnStream\cf3\strike0\{linkID=4230\}\cf0\f0 
\par 
\par }
5490
Scribble5490
TZMStreamOp type
TZMStreamOp;


ZipMstr20:002505
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMStreamOp type
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5500\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 type\b0  TZ\f2 M\f1 StreamOp = (zsoIdentify, zsoOpen, zsoClose);
\par \f0 
\par \b\fs22 Description
\par \b0\f3\fs20     Stream operations used by \cf2\strike OnStream\cf3\strike0\{linkID=4230\}\cf0 
\par \f0 
\par \f3     \f0 zsoIdentify  - Identify the stream
\par \f3     \f0 zsoOpen    - Open the stream
\par \f3     \f0 zsoClose    - Close the stream 
\par 
\par }
5500
Scribble5500
TZMStreamOp type - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnStream\cf3\strike0\{linkID=4230\}\cf0\f0 
\par 
\par }
5510
Scribble5510
ZMUtils19 unit
ZMUtils20;ZMUtils20 unit;


ZMUtils20:001000
Writing



FALSE
75
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fnil\fcharset0 Arial;}{\f3\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red0\green0\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ZMUtils19 unit
\par \cf2\b0\strike\f1\fs20 TZipMaster\strike0\{linkID=10\}\cf3\f0\fs16\{keepn\}\cf0\fs20 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f2 Utility functions used by TZipMaster that can also be used by users.\f0 
\par \cf3 
\par \cf0\b\fs22 Routines
\par \cf2\b0\strike\fs20 AbsErr\cf4\strike0\{linkID=5520\}\cf3 
\par \cf2\strike CalcCRC32\cf4\strike0\{linkID=5530\}\cf3 
\par \cf2\strike CanHash\cf4\strike0\{linkID=5540\}\cf3 
\par \cf2\strike CheckSFXType\cf4\strike0\{linkID=5550\}\cf3 
\par \cf2\strike DelimitPath\cf4\strike0\{linkID=5560\}\cf3 
\par \cf2\strike DirExists\cf4\strike0\{linkID=5570\}\cf3 
\par \cf2\strike DiskAvailable\cf4\strike0\{linkID=5580\}\cf3 
\par \cf2\strike EraseFile\cf4\strike0\{linkID=5590\}\cf3 
\par \cf2\strike ExeSize\cf4\strike0\{linkID=5600\}\cf3 
\par \cf2\strike ExeVers\cf4\strike0\{linkID=5610\}\cf3 
\par \cf2\strike ExeVersion\cf4\strike0\{linkID=5620\}\cf3 
\par \cf2\strike ExtractNameOfFile\cf4\strike0\{linkID=5630\}\cf3 
\par \cf2\strike File_Size\cf4\strike0\{linkID=5640\}\cf3 
\par \cf2\strike FileDateToLocalDateTime\cf4\strike0\{linkID=5650\}\cf3 
\par \cf2\strike FileSeek64\cf4\strike0\{linkID=5660\}\cf3 
\par \cf2\strike ForceDirectory\cf4\strike0\{linkID=5670\}\cf3 
\par \cf2\strike GetVolumeLabel\cf4\strike0\{linkID=5680\}\cf3 
\par \cf2\strike HasWild\cf4\strike0\{linkID=5690\}\cf3 
\par \cf2\strike HasWildW\cf4\strike0\{linkID=5690\}\cf3 
\par \cf2\strike Hi64\cf4\strike0\{linkID=5700\}\cf3 
\par \cf2\strike IsFolder\cf4\strike0\{linkID=5710\}\cf3 
\par \cf2\strike IsSameFile\cf4\strike0\{linkID=5720\}\cf3 
\par \cf2\strike IsWild\cf4\strike0\{linkID=5730\}\cf3 
\par \cf2\strike IsWinXP\cf4\strike0\{linkID=5740\}\cf3 
\par \cf2\strike LastPos\cf4\strike0\{linkID=5750\}\cf3 
\par \cf2\strike LastPosW\cf4\strike0\{linkID=5750\}\cf3 
\par \cf2\strike Lo64\cf4\strike0\{linkID=5760\}\cf3 
\par \cf2\strike NameIsBad\cf4\strike0\{linkID=5770\}\cf3 
\par \cf2\strike OEMToStr\cf4\strike0\{linkID=5800\}\cf3 
\par \cf2\strike OpenResStream\cf4\strike0\{linkID=5820\}\cf3 
\par \cf2\strike PathConcat\cf4\strike0\{linkID=5830\}\cf3 
\par \cf2\strike QueryZip\cf4\strike0\{linkID=5840\}\cf3 
\par \cf2\strike SetSlash\cf4\strike0\{linkID=5870\}\cf3 
\par \cf2\strike SetSlashW\cf4\strike0\{linkID=5870\}\cf3 
\par \cf2\strike StrHasExt\cf4\strike0\{linkID=5880\}\cf3 
\par \cf2\strike StrToOEM\cf4\strike0\{linkID=5890\}\cf3 
\par \cf2\strike VersStr\cf4\strike0\{linkID=5910\}\cf3 
\par \cf2\strike WinVersion\cf4\strike0\{linkID=5920\}\cf3 
\par \cf2\strike File_Close\cf4\strike0\{linkID=5930\}\cf3 
\par \cf2\strike File_Delete\cf4\strike0\{linkID=5940\}\cf3 
\par 
\par \cf0\b\fs22 Constants
\par \cf2\b0\strike\f3 CheckSFXType\cf4\strike0\{linkID=5550\} \cf0 values
\par   cstNone = 0;        // not found
\par   cstExe  = 1;        // might be stub of unknown type
\par   cstSFX17 = 17;      // found 1.7 SFX headers
\par   cstSFX19 = 19;      // found 1.9 SFX headers
\par   cstDetached = 2048; // is detached - if name specified ZipName will modified for it\f0\fs20 
\par 
\par \cf2\strike\f3\fs22 QueryZip\cf4\strike0\{linkID=5840\}\cf0  return bit values and errors
\par   zqbStartEXE        = 1;     // is EXE file may be SFX
\par   zqbStartLocal       = 2;     // normal zip file start
\par   zqbStartSpan        = 4;     // first part of span
\par   zqbStartCentral     = 8;     // continuing Central Header
\par   zqbHasComment   = 16;
\par   zqbHasLocal         = 32;    // first Central entry points to local header
\par   zqbHasCentral       = 64;    // Central entry where it should be
\par   zqbHasEOC         = 128;   // End of Central entry
\par   zqbHasLoc64        = 256;   // EOC64 locator entry
\par   zqbHasEOC64      = 512;   // Zip64 EOC
\par   zqbJunkAtEnd       = 1024;  // junk at end of zip
\par   zqbIsDiskZero       = 2048;  // is disk 0
\par 
\par   zqFieldError   = -5;     // bad field value
\par   zqFileError    = -7;     // file handling error
\par   zqGeneralError = -9;     // unspecified failure
\par \f0\fs20 
\par }
5520
Scribble5520
AbsErr function
AbsErr;


ZMUtils20:001100
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AbsErr function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  AbsErr(err: Integer): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Many internal functions return a negative error values, this function converts it to 'normal'.\f0 
\par 
\par }
5530
Scribble5530
CalcCRC32 function
CalcCRC32;


ZMUtils20:001105
Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 CalcCRC32 function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  CalcCRC32(\b const\b0  mem; len: Integer; init: DWORD): DWORD;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Calculates CRC32 of a block of memory.
\par   mem    - pointer to the memory block
\par   len       - length of the memory block
\par   init       - initial CRC value, usually 0 .\f0 
\par 
\par }
5540
Scribble5540
CanHash function
CanHash;


ZMUtils20:001110
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 CanHash function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  CanHash(\b const\b0  FSpec: \b String\b0 ): Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Used internally to detect if a file spec is safe to hash - eg. no wildcards.\f0 
\par 
\par }
5550
Scribble5550
CheckSFXType function
CheckSFXType;


ZMUtils20:001115
Writing



FALSE
26
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 CheckSFXType function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  CheckSFXType(\b const\b0  fileHandle: Integer; \b var\b0  ZipName: \b String\b0 ; \b var\b0  size: Integer): Integer; \b overload\b0 ;\b\f0\fs22 
\par \f1\fs20 function\b0  CheckSFXType(\b const\b0  Name: \b String\b0 ; \b var\b0  ZipName: \b String\b0 ; \b var\b0  size: Integer): Integer; \b overload\b0 ;
\par 
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Tries to identify the type of SFX Stub
\par 
\par    Returns <0 error.
\par   
\par const
\par   cstNone = 0;            // not found
\par   cstExe  = 1;             // might be stub of unknown type
\par   cstSFX17 = 17;         // found 1.7 SFX headers
\par   cstSFX20 = 20;         // found 2.0 SFX headers
\par   cstDetached = 2048; // is detached - if name specified ZipName will modified for it - this is a bit flag added to the version.\f0 
\par 
\par }
5560
Scribble5560
DelimitPath function
DelimitPath;


ZMUtils20:001125
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DelimitPath function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  DelimitPath(\b const\b0  Path: \b String\b0 ; Sep: Boolean): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   If Sep is True return the Path with a trailing path delimiter, otherwise make certain that Path does not have one.\f0 
\par 
\par }
5570
Scribble5570
DirExists function
DirExists;


ZMUtils20:001130
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DirExists function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  DirExists(\b const\b0  FName: \b String\b0 ): Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Returns true if the path FName exists.\f0 
\par 
\par }
5580
Scribble5580
DiskAvailable function
DiskAvailable;


ZMUtils20:001135
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DiskAvailable function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  DiskAvailable(\b const\b0  path: \b String\b0 ): Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Return True if media exists for path.\f0 
\par 
\par }
5590
Scribble5590
EraseFile function
EraseFile;


ZMUtils20:001140
Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 EraseFile function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  EraseFile(\b const\b0  FName: \b String\b0 ; permanent: Boolean): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Delete the file FName.
\par   If permanent is False move it to the recycle bin.\f0 
\par 
\par }
5600
Scribble5600
ExeSize function
ExeSize;


ZMUtils20:001145
Writing



FALSE
22
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExeSize function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ExeSize(\b const\b0  Name: \b String\b0 ): Cardinal; \b overload\b0 ;\b\f0\fs22 
\par \f1\fs20 function\b0  ExeSize(fileHandle: Integer): Cardinal; \b overload\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Return the size of the executable part.
\par   This is meant to find the SFX stub size excluding any extra structures.
\par 
\par   In general SFX files are built
\par      SFX stub (the executable part)
\par      Required Information used to extract
\par      Zipped files.\f0 
\par 
\par }
5610
Scribble5610
ExeVers function
ExeVers;


ZMUtils20:001155
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExeVers function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ExeVers(\b const\b0  FName: \b String\b0 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Returns the version number from a file's version information resource.\f0 
\par 
\par }
5620
Scribble5620
ExeVersion function
ExeVersion;


ZMUtils20:001160
Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExeVersion function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ExeVersion(\b const\b0  FName: \b String\b0 ; \b var\b0  MS, LS: DWORD): Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Reads the Version information from a file's version information resource.\f0 
\par 
\par \f2   \f0 Returns true if found then the file version is in MS and LS\f2 .\f0  
\par }
5630
Scribble5630
ExtractNameOfFile function
ExtractNameOfFile;


ZMUtils20:001165
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExtractNameOfFile function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ExtractNameOfFile(\b const\b0  FileName: \b String\b0 ): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Returns the name part of FileName excluding the extension.\f0 
\par 
\par }
5640
Scribble5640
File_Size function
File_Size;


ZMUtils20:001170
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 File_Size function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  \b File\b0 _Size(\b const\b0  FSpec: TFilename): Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Returns the size of the specified file or -1 if not found.\f0 
\par 
\par }
5650
Scribble5650
FileDateToLocalDateTime function
FileDateToLocalDateTime;


ZMUtils20:001175
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 FileDateToLocalDateTime function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  FileDateToLocalDateTime(stamp: Integer): TDateTime;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20     Converts the DOS date/time stamp to the local time (adjusts for daylight saving).\f0 
\par 
\par }
5660
Scribble5660
FileSeek64 function
FileSeek64;


ZMUtils20:001180
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 FileSeek64 function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  FileSeek64(Handle: Integer; \b const\b0  Offset: Int64; Origin: Integer): Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Allow seeking 64 bit offsets.\f0 
\par 
\par }
5670
Scribble5670
ForceDirectory function
ForceDirectory;


ZMUtils20:001185
Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ForceDirectory function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ForceDirectory(\b const\b0  DirName: \b String\b0 ): Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Attempts to create the named directory if it does not exist.
\par   Returns True if successful.\f0 
\par 
\par }
5680
Scribble5680
GetVolumeLabel function
GetVolumeLabel;


ZMUtils20:001190
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 GetVolumeLabel function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  GetVolumeLabel(\b const\b0  drive: \b String\b0 ): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Return the volume label for the specified drive.\f0 
\par 
\par }
5690
Scribble5690
HasWild function
HasWild;


ZMUtils20:001195
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 HasWild function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  HasWild(\b const\b0  FSpec: \b String\b0 ): Integer;\b\f0\fs22 
\par \f1\fs20 function\b0  HasWildW(\b const\b0  FSpec: WideString): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Returns the index of the first wildcard character found.
\par   Wildcard characters are -
\par     *    match zero or more characters 
\par     ?    match any single character\f0 
\par 
\par }
5700
Scribble5700
Hi64 function
Hi64;


ZMUtils20:001205
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Hi64 function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  Hi64(i: Int64): Cardinal;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Returns the high 32 bits of an Int64.\f0 
\par 
\par }
5710
Scribble5710
IsFolder function
IsFolder;


ZMUtils20:001210
Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 IsFolder function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  IsFolder(\b const\b0  name: \f2  \cf3\strike TZMRawBytes\cf4\strike0\{linkID=5275\}\cf0\f1 ): boolean; \b overload\b0 ;\b\f0\fs22 
\par \f1\fs20 function\b0  IsFolder(\b const\b0  Name: \b String\b0 ): Boolean; \b overload\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Return True if the last character is path delimiter.\f0 
\par 
\par }
5720
Scribble5720
IsSameFile function
IsSameFile;


ZMUtils20:001220
Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fswiss\fprq2\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 IsSameFile function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  IsSameFile(\b const\b0  FName1, FName2: \b String\b0 ): Boolean;
\par \f0 
\par \pard\sa195\tx355\b\fs22 Description\lang2057\f2\fs24 
\par \pard\tx165\tx425\b0\fs20 Returns \b true\b0  if both Fname1 and Fname2 are equal after expanding to full path.
\par If only their filenames are different then we try to find both files, if they are found the file attributes are compared, if these are equal they are assumed to be the same file.
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\lang3081\f0 
\par 
\par }
5730
Scribble5730
IsWild function
IsWild;


ZMUtils20:001225
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 IsWild function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  IsWild(\b const\b0  FSpec: \b String\b0 ): Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Returns True if the string contains a wildcard character.
\par   Wildcard characters are -
\par     *    match zero or more characters 
\par     ?    match any single character\f0 
\par 
\par 
\par }
5740
Scribble5740
IsWinXP function
IsWinXP;


ZMUtils20:001230
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 IsWinXP function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  IsWinXP: Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Return True if running on Windows XP or later.\f0 
\par 
\par }
5750
Scribble5750
LastPos function
LastPos;


ZMUtils20:001235
Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 LastPos function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  LastPos(\b const\b0  s: \b String\b0 ; ch: Char; before: Integer = MAXINT): Integer;\b\f0\fs22 
\par \f1\fs20 function\b0  LastPosW(\b const\b0  s: WideString; wch: Widechar; before: Integer = MAXINT): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Returns the index of the last occurance of the given character before the specified index.\f0 
\par 
\par }
5760
Scribble5760
Lo64 function
Lo64;


ZMUtils20:001245
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Lo64 function
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\b0\fs16 
\par \cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  Lo64(i: Int64): Cardinal;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Returns the low 32 bits of an Int64.\f0 
\par 
\par }
5770
Scribble5770
NameIsBad function
NameIsBad;


ZMUtils20:001250
Writing



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 NameIsBad function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5780\}\tab\cf2\strike Example\cf3\strike0\{linkID=%5790\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUtils19\cf3\strike0\{linkID=5510\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  NameIsBad(\b const\b0  astr: \b String\b0 ): Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Returns \b True \b0 is astr has invalid characters or format for use as a filename.\f0 
\par }
5780
Scribble5780
NameIsBad function - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of NameIsBad function >>>
\par 
\par }
5790
Scribble5790
NameIsBad function - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 NameIsBad function example
\par \cf0\b0 
\par 
\par }
5800
Scribble5800
OEMToStr function
OEMToStr;


ZMUtils20:001255
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OEMToStr function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5810\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUtils19\cf3\strike0\{linkID=5510\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  OEMToStr(\b const\b0  astr: Ansistring): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Converts astr from OEM into a string.\f0 
\par 
\par }
5810
Scribble5810
OEMToStr function - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 StrToOEM\cf3\strike0\{linkID=5890\}\cf0\f0 
\par 
\par }
5820
Scribble5820
OpenResStream function
OpenResStream;


ZMUtils20:001260
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 OpenResStream function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  OpenResStream(\b const\b0  ResName: \b String\b0 ; \b const\b0  rtype: PChar): TResourceStream;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Attempts to open a resource stream first looking in the executable module then, if unfound, trying the package module. \f0 
\par 
\par }
5830
Scribble5830
PathConcat function
PathConcat;


zmutils20:001265
Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 PathConcat function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  PathConcat(\b const\b0  path, extra: \b String\b0 ): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \pard\cf2\b0\f2\fs20  \tab appends second to first ensuring single backslash.
\par \tab ie
\par \tab first + second = first\\second
\par \tab first\\ + \\second = first\\second
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\f0 
\par }
5840
Scribble5840
QueryZip function
QueryZip;


ZMUtils20:001270
Writing



FALSE
36
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 QueryZip function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5850\}\tab\cf2\strike Example\cf3\strike0\{linkID=%5860\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUtils19\cf3\strike0\{linkID=5510\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  QueryZip(\b const\b0  FName: \b String\b0 ): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Tests the named zip file for various fields.
\par Returns < 0 on error otherwise it returns bit mapped values for the located fields.\f0 
\par \f2 It can be used for a relatively quick test to see if it is actually a zip file.\f0 
\par 
\par const                     \f2        \f0  \f2   \f0 // QueryZip return bit values and errors
\par   zqbStartEXE     = 1;    \f2     \f0 // is EXE file may be SFX
\par   zqbStartLocal   = 2;     \f2     \f0 // normal zip file start
\par   zqbStartSpan    = 4;     \f2    \f0 // first part of span
\par   zqbStartCentral = 8;     \f2    \f0 // continuing Central Header
\par   zqbHasComment   = 16;  // comment length good (no junk at end)
\par   zqbHasLocal     = 32;    \f2   \f0 // first Central entry points to local header
\par   zqbHasCentral   = 64;    \f2   \f0 // Central entry where it should be
\par   zqbHasEOC       = 128;   \f2  \f0 // End of Central entry
\par   zqbHasLoc64     = 256;   \f2  \f0 // EOC64 locator entry
\par   zqbHasEOC64     = 512;   // Zip64 EOC
\par   zqbJunkAtEnd    = 1024;  \f2  \f0 // junk at end of zip
\par   zqbIsDiskZero   = 2048;  \f2    \f0 // is disk 0
\par 
\par   zqFieldError   = -5;     // bad field value
\par   zqFileError    = -7;     \f2  \f0 // file handling error
\par   zqGeneralError = -9;   // unspecified failure
\par 
\par 
\par }
5850
Scribble5850
QueryZip function - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of QueryZip function >>>
\par 
\par }
5860
Scribble5860
QueryZip function - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 QueryZip function example
\par \cf0\b0 
\par 
\par }
5870
Scribble5870
SetSlash function
SetSlash;


ZMUtils20:001275
Writing



FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 SetSlash function
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\b0\fs16 
\par \cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  SetSlash(\b const\b0  path: \b String\b0 ; dir: TPathSlashDirection): \b String\b0 ;\b\f0\fs22 
\par \f1\fs20 function\b0  SetSlashW(\b const\b0  path: WideString; dir: TPathSlashDirection): WideString;
\par 
\par \b type\b0  TPathSlashDirection = (psdExternal, psdInternal);
\par 
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20   Sets the path delimiters to either
\par \pard     psdExternal - Windows standard backslash \\
\par     psdInternal  - zip internal format slash /\f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640 
\par }
5880
Scribble5880
StrHasExt function
StrHasExt;


ZMUtils20:001285
Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 StrHasExt function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  StrHasExt(\b const\b0  astr: AnsiString): Boolean; \b overload\b0 ;\b\f0\fs22 
\par \f1\fs20 function\b0  StrHasExt(\b const\b0  astr: \f2  \cf3\strike TZMRawBytes\cf4\strike0\{linkID=5275\}\cf0\f1 ): Boolean; \b overload\b0 ;\b\f0\fs22 
\par \f1\fs20 function\b0  StrHasExt(\b const\b0  astr: \b String\b0 ): Boolean; \b overload\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Returns True is the string contains a character value > #127\f0 
\par 
\par }
5890
Scribble5890
StrToOEM function
StrToOEM;


ZMUtils20:001300
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 StrToOEM function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5900\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUtils19\cf3\strike0\{linkID=5510\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  StrToOEM(\b const\b0  astr: \b String\b0 ): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Converts the string to OEM.\f0 
\par 
\par }
5900
Scribble5900
StrToOEM function - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OEMToStr\cf3\strike0\{linkID=5800\}\cf0\f0 
\par 
\par }
5910
Scribble5910
VersStr function
VersStr;


ZMUtils20:001305
Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 VersStr function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  VersStr(vers: Integer; Comma: Boolean = False): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Converts our version value to a readable string.\f0 
\par 
\par If Comma is true the format is \f2 '\f0 %d,%d,%d,%d\f2 '\f0 
\par if false the format is \f2 '\f0 %d.%d.%d.%4.4d\f2 '\f0 
\par 
\par }
5920
Scribble5920
WinVersion function
WinVersion;


ZMUtils20:001310
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 WinVersion function
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\b0\fs16 
\par \cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  WinVersion: Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Converts the Windows version into an easily usable approximate value (= (Major_version * 100) + Minor_version).\f0 
\par 
\par }
5930
Scribble5930
File_Close procedure
File_Close;


ZMUtils20:001315
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 File_Close procedure
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 procedure\b0  \b File\b0 _Close(\b var\b0  fh: Integer);
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Invalidates the handle variable then closes the handle (if it can).\f0 
\par 
\par }
5940
Scribble5940
File_Delete procedure
File_Delete;


ZMUtils20:001320
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 File_Delete procedure
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\b0\fs16 
\par \cf2\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf3\b0\strike\fs20 ZMUtils19\cf4\strike0\{linkID=5510\}\cf2 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 procedure\b0  \b File\b0 _Delete(\b const\b0  FName: \b String\b0 );
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 If it can locate the file it attempts to delete it.\f0 
\par 
\par }
5950
Scribble5950
TZMProgressDetails class
TZMProgressDetails;


ZipMstr20:001010
Writing


TProgressDetails_Object;TProgressDetails
FALSE
32
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMProgressDetails class
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5960\}\tab\cf2\ul Properties\cf3\ulnone\{linkID=%5970\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\f1\fs20 T\f0 ZipMstr\f1 19\cf3\strike0\f0\{linkID=330\}\cf4 
\par \pard\lang1033 
\par \b type\b0 
\par   TZMProgressDetails= \b class\lang3081\b0\f1 ;\lang1033\f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\lang3081 
\par \cf0\b\fs22 Description
\par \pard\b0\f1\fs20     Provides operation progress read-only details in the \cf2\strike OnProgress \cf3\strike0\{linkID=4020\}\cf0 event 
\par \cf4\lang1033\f0 
\par \b type\b0 
\par   TZMProgressDetails= \b class\b0 (\b TObject\b0 )\lang3081\f1  \lang1033\f0 
\par   public
\par     destructor Destroy; override;
\par \pard\tx200\tx640     property \cf3\lang3081\tab\cf2\strike BytesWritten\cf3\strike0\{linkID=5980\}\f1  \cf0 : Int64;
\par \tab  property\tab\cf2\strike Delta\cf3\strike0\{linkID=6010\}\cf0 : Int64;\cf4\f0 
\par \lang1033     property \cf3\lang3081\tab\cf2\strike ItemName\cf3\strike0\{linkID=6040\}\f1  \cf0 : \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ;\cf4\f0 
\par \lang1033     property \cf3\lang3081\tab\cf2\strike ItemNumber\cf3\strike0\{linkID=6070\}\f1  \cf0 : Integer;\cf4\f0 
\par \lang1033     property \cf3\lang3081\tab\cf2\strike ItemPerCent\cf3\strike0\{linkID=6100\}\f1  \cf0 : Integer;\cf4\f0 
\par \lang1033     property \cf3\lang3081\tab\cf2\strike ItemPosition\cf3\strike0\{linkID=6130\}\f1  \cf0 : Integer;\cf4\f0 
\par \lang1033     property \cf3\lang3081\tab\cf2\strike ItemSize\cf3\strike0\{linkID=6160\}\f1  \cf0 : Integer;\cf4\f0 
\par \lang1033     property \cf3\lang3081\tab\cf2\strike Order\cf3\strike0\{linkID=6190\}\f1  \cf0 : \cf2\strike TZMProgressType\cf3\strike0\{linkID=4960\}\cf0 ;\cf4\f0 
\par \lang1033     property \cf3\lang3081\tab\cf2\strike TotalCount\cf3\strike0\{linkID=6220\}\cf0\f1  : Int64;\cf4\f0 
\par \lang1033     property \cf3\lang3081\tab\cf2\strike TotalPerCent\cf3\strike0\{linkID=6250\}\f1  \cf0 : Integer;\cf4\f0 
\par \lang1033     property \cf3\lang3081\tab\cf2\strike TotalPosition\cf3\strike0\{linkID=6280\}\f1  \cf0 : Integer;\cf4\f0 
\par \lang1033     property \cf3\lang3081\tab\cf2\strike TotalSize\cf3\strike0\{linkID=6310\}\f1  \cf0 : Int64;\cf4\f0 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf0\f1 end;\f0 
\par }
5960
Scribble5960
TZMProgressDetails class - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of TZMProgressDetails\f1  \f0 class >>>
\par 
\par }
5970
Scribble5970
TZMProgressDetails - Properties




Writing



TRUE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fswiss Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red128\green0\blue0;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Properties
\par \cf0\b0 
\par \cf2 Run-time only\tab  Key properties
\par \pard\tx180\tx600\cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\f1\tab\cf4\strike\f0 BytesWritten\cf3\strike0\{linkID=5980\}\cf2 
\par \pard\tx200\tx640\cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike\f1 Delta\cf3\strike0\f0\{linkID=6010\}\cf2 
\par \cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike ItemName\cf3\strike0\{linkID=6040\}\cf2 
\par \cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike ItemNumber\cf3\strike0\{linkID=6070\}\cf2 
\par \cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike ItemPerCent\cf3\strike0\{linkID=6100\}\cf2 
\par \cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike ItemPosition\cf3\strike0\{linkID=6130\}\cf2 
\par \cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike ItemSize\cf3\strike0\{linkID=6160\}\cf2 
\par \cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike Order\cf3\strike0\{linkID=6190\}\cf2 
\par \cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike TotalCount\cf3\strike0\{linkID=6220\}\cf2 
\par \cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike TotalPerCent\cf3\strike0\{linkID=6250\}\cf2 
\par \cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike TotalPosition\cf3\strike0\{linkID=6280\}\cf2 
\par \cf3\f1\tab\f0\{bmct \f2 GrnBullet\f0 .bmp\}\tab\cf4\strike TotalSize\cf3\strike0\{linkID=6310\}\cf2 
\par \cf0 
\par }
5980
Scribble5980
BytesWritten property
BytesWritten;BytesWritten,TProgressDetails;TZMProgressDetails,BytesWritten;


ZipMstr20:001020
Writing


TProgressDetails_BytesWritten;BytesWritten_Property;BytesWritten
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 BytesWritten property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%5990\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  BytesWritten: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Number of bytes written.\f0 
\par Run-time only
\par Read-only
\par 
\par }
5990
Scribble5990
BytesWritten property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6010
Scribble6010
Delta property




Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Delta property\cf2\b0\f1\fs20 
\par \cf0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf3\ul See also\cf4\ulnone\{linkID=%6020\}\cf2\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf3\b0\strike\fs20 T\f0 ZM\f1 ProgressDetails\cf4\strike0\{linkID=5950\}\cf2  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  \f3 Delta\f2 : Int64;
\par \f1 
\par \b\fs22 Description
\par \b0\f0\fs20 Number of bytes processed since last event.\f1 
\par Run-time only
\par Read-only
\par \pard\cf2 
\par 
\par }
6020
Scribble6020
Delta property - See also




Writing



FALSE
9
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par \cf4 
\par 
\par 
\par }
6040
Scribble6040
ItemName property
ItemName;ItemName,TZMProgressDetails;TZMProgressDetails,ItemName;


zipmstr20:001025
Writing


TProgressDetails_ItemName;ItemName_Property;ItemName
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ItemName property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6\f1 05\f0 0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  ItemName: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Name of the current item being processed\f0 
\par Run-time only
\par Read-only
\par 
\par }
6050
Scribble6050
ItemName property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6070
Scribble6070
ItemNumber property
ItemNumber;ItemNumber,TZMProgressDetails;TZMProgressDetails,ItemNumber;


zipmstr20:001030
Writing


TProgressDetails_ItemNumber;ItemNumber_Property;ItemNumber
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ItemNumber property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%\f1 6\f0 080\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  ItemNumber: Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 DirEntry index of current item.\f0 
\par Run-time only
\par Read-only
\par 
\par }
6080
Scribble6080
ItemNumber property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6100
Scribble6100
ItemPerCent property
ItemPerCent;ItemPerCent,TZMProgressDetails;TZMProgressDetails,ItemPerCent;


zipmstr20:001035
Writing


TProgressDetails_ItemPerCent;ItemPerCent_Property;ItemPerCent
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ItemPerCent property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%61\f1 1\f0 0\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  ItemPerCent: Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Percentage of item processed\f0 
\par Run-time only
\par Read-only
\par 
\par }
6110
Scribble6110
ItemPerCent property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6130
Scribble6130
ItemPosition property
ItemPosition;ItemPosition,TZMProgressDetails;TZMProgressDetails,ItemPosition;


ZipMstr20:001040
Writing


TProgressDetails_ItemPosition;ItemPosition_Property;ItemPosition
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ItemPosition property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6140\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  ItemPosition: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Position in current item.\f0 
\par Run-time only
\par Read-only
\par 
\par }
6140
Scribble6140
ItemPosition property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6160
Scribble6160
ItemSize property
ItemSize;ItemSize,TZMProgressDetails;TZMProgressDetails,ItemSize;


ZipMstr20:001045
Writing


TProgressDetails_ItemSize;ItemSize_Property;ItemSize
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ItemSize property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6170\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  ItemSize: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Size of the current item being processed\f0 
\par Run-time only
\par Read-only
\par 
\par }
6170
Scribble6170
ItemSize property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6190
Scribble6190
Order property
Order;Order,TProgressDetails;TZMProgressDetails,Order;


ZipMstr20:001050
Writing


TProgressDetails_Order;Order_Property;Order
FALSE
28
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Times New Roman;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Order property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6200\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  Order: \cf2\strike TZMProgressType\cf3\strike0\{linkID=4960\}\cf0 ;
\par \f0 
\par \pard\b\fs22 Description\cf4\lang1033\b0\fs20 
\par \lang3081\f1    enumerates the types of 'progress'
\par 
\par \cf0\f3\fs24     NewFile, \tab\tab starting on new file
\par     ProgressUpdate, \tab reports progress in file
\par     EndOfBatch, \tab finished all operations
\par     TotalFiles2Process,\tab reports Total files to process
\par     TotalSize2Process, \tab reports Total uncompressed size of files
\par     NewExtra, \tab\tab starting new 'extra' item
\par     ExtraUpdate\tab\tab advancing through 'extra' item
\par 
\par    'extra' items are operations that may take some time eg. reading central directory or resetting archive bits
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0\fs20 
\par Run-time only
\par Read-only
\par 
\par }
6200
Scribble6200
Order property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6220
Scribble6220
TotalCount property
TotalCount;TotalCount,TZMProgressDetails;TZMProgressDetails,TotalCount;


ZipMstr20:001055
Writing


TProgressDetails_TotalCount;TotalCount_Property;TotalCount
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TotalCount property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6230\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  TotalCount: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Total number of items to be processed.\f0 
\par Run-time only
\par Read-only
\par 
\par }
6230
Scribble6230
TotalCount property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6250
Scribble6250
TotalPerCent property
TotalPerCent;TotalPerCent,TZMProgressDetails;TZMProgressDetails,TotalPerCent;


ZipMstr20:001060
Writing


TProgressDetails_TotalPerCent;TotalPerCent_Property;TotalPerCent
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TotalPerCent property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6260\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  TotalPerCent: Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Percentage of items processed\f0 
\par Run-time only
\par Read-only
\par 
\par }
6260
Scribble6260
TotalPerCent property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6280
Scribble6280
TotalPosition property
TotalPosition;TotalPosition,TZMProgressDetails;TZMProgressDetails,TotalPosition;


ZipMstr20:001065
Writing


TProgressDetails_TotalPosition;TotalPosition_Property;TotalPosition
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TotalPosition property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6290\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  TotalPosition: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 position of current item.\f0 
\par Run-time only
\par Read-only
\par 
\par }
6290
Scribble6290
TotalPosition property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6310
Scribble6310
TotalSize property
TotalSize;TotalSize,TZMProgressDetails;TZMProgressDetails,TotalSize;


ZipMstr20:001070
Writing


TProgressDetails_TotalSize;TotalSize_Property;TotalSize
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TotalSize property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6320\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 T\f1 ZM\f0 ProgressDetails\cf3\strike0\{linkID=5950\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  TotalSize: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Total size of all items\f0 
\par Run-time only
\par Read-only
\par 
\par }
6320
Scribble6320
TotalSize property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 OnProgress\cf3\strike0\{linkID=4020\}\cf0\f0 
\par 
\par }
6340
Scribble6340
TZMDirEntry class
TZMDirEntry;


ZipMstr20:001100
Writing


TZipDirEntry_Object;TZipDirEntry
FALSE
12
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZ\f1 M\f0 DirEntry class
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6350\}\tab\cf2\ul Properties\cf3\ulnone\{linkID=%6360\}\cf4\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Description
\par \b0\f1\fs20 A read-only abstract class representing the zip central directory entry\f0 
\par 
\par }
6350
Scribble6350
TZMDirEntry class - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 DirEntry\cf3\strike0\{linkID=660\}\cf0 
\par \cf2\strike TZMDirRec\cf3\strike0\{linkID=7090\}\cf0\f0 
\par 
\par }
6360
Scribble6360
TZMDirEntry - Properties




Writing



TRUE
32
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green128\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Properties
\par \pard\tx200\tx640\cf2\b0\{keepn\}    
\par \f1\tab\f0\{bmct BluBullet.bmp\}\cf0  Read-Only
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike CompressedSize\cf2\strike0\{linkID=6370\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike CompressionMethod\cf2\strike0\{linkID=6400\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike CRC32\cf2\strike0\{linkID=6430\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike DateStamp\cf2\strike0\{linkID=6460\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike DateTime\cf2\strike0\{linkID=6490\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike Encoded\cf2\strike0\{linkID=6520\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike Encrypted\cf2\strike0\{linkID=6550\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike ExtFileAttrib\cf2\strike0\{linkID=6580\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike ExtraData\cf2\strike0\{linkID=6610\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike ExtraField\cf2\strike0\{linkID=6640\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike ExtraFieldLength\cf2\strike0\{linkID=6670\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike FileComment\cf2\strike0\{linkID=6700\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike FileCommentLen\cf2\strike0\{linkID=6730\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike FileName\cf2\strike0\{linkID=6760\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike FileNameLength\cf2\strike0\{linkID=6790\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike Flag\cf2\strike0\{linkID=6820\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike HeaderName\cf2\strike0\{linkID=6850\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike IntFileAttrib\cf2\strike0\{linkID=6880\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike I\f1 sDirOnly\cf2\strike0\f0\{linkID=6\f1 903\f0\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike RelOffLocalHdr\cf2\strike0\{linkID=6910\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike StartOnDisk\cf2\strike0\{linkID=6940\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike StatusBits\cf2\strike0\{linkID=6970\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike UncompressedSize\cf2\strike0\{linkID=7000\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike VersionMadeBy\cf2\strike0\{linkID=7030\}\cf4 
\par \cf2\tab\{bmct \f1 BluBullet\f0 .bmp\}\tab\cf3\strike VersionNeeded\cf2\strike0\{linkID=7060\}\cf4 
\par \cf0 
\par }
6370
Scribble6370
CompressedSize property
CompressedSize;CompressedSize,TZMDirEntry;TZMDirEntry,CompressedSize;


zipmstr20:001110
Writing


TZipDirEntry_CompressedSize;CompressedSize_Property;CompressedSize
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 CompressedSize property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6380\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZ\f1 M\f0 DirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  CompressedSize: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 The compressed size of the compressed file\f0 
\par Run-time only
\par Read-only
\par 
\par }
6380
Scribble6380
CompressedSize property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of CompressedSize property >>>
\par 
\par }
6400
Scribble6400
CompressionMethod property
CompressionMethod;CompressionMethod,TZMDirEntry;TZMDirEntry,CompressionMethod;


zipmstr20:001115
Writing


TZMDirEntry_CompressionMethod;CompressionMethod_Property;CompressionMethod
FALSE
33
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}{\f2\fnil Courier New;}{\f3\fswiss Arial;}{\f4\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;\red255\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 CompressionMethod property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6410\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZ\f1 M\f0 DirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  CompressionMethod: Word;
\par \f0 
\par \b\fs22 Description
\par \b0\f1\fs20 Method used to compress the file\f0 
\par Run-time only
\par Read-only
\par 
\par \pard\b\f1 Valid Values\cf5\b0\f3\fs24\tab 
\par \f4\tab\cf0\f3\fs20 0\tab - The file is stored (no compression)
\par \tab 1\tab - The file is Shrunk
\par \tab 2\tab - The file is Reduced with compression factor 1
\par \tab 3\tab - The file is Reduced with compression factor 2
\par \tab 4\tab - The file is Reduced with compression factor 3
\par \tab 5\tab - The file is Reduced with compression factor 4
\par \tab 6\tab - The file is Imploded
\par \tab 7\tab - Reserved for Tokenizing compression algorithm
\par \tab 8\tab - The file is Deflated
\par \tab 9\tab - Reserved for enhanced Deflating
\par \tab 10\tab - PKWARE Dat\f4 a\f3  Compression Library Imploding
\par          \f4    \f3 11 \f4\tab\f3 - Reserved by PKWARE
\par          \f4    \f3 12 \f4\tab\f3 - File is compressed using BZIP2 algorithm
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f0 
\par \cf1\strike\f2 PKWARE\cf3\strike0\{link=*! ExecFile("http://www.pkware.com")\}\cf0\f1  is the registered trademark. \f0 
\par }
6410
Scribble6410
CompressionMethod property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddCompLevel\cf3\strike0\{linkID=430\}\cf0\f0 
\par 
\par }
6430
Scribble6430
CRC32 property
CRC32;CRC32,TZMDirEntry;TZMDirEntry,CRC32;


zipmstr20:001120
Writing


TZipDirEntry_CRC32;CRC32_Property;CRC32
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 CRC32 property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6440\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  CRC32: Cardinal;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 CyclicRedundancyCode of the original file - used for error checking
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6440
Scribble6440
CRC32 property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of CRC32 property >>>
\par 
\par }
6460
Scribble6460
DateStamp property
DateStamp;DateStamp,TZMDirEntry;TZMDirEntry,DateStamp;


zipmstr20:001125
Writing


TZipDirEntry_DateStamp;DateStamp_Property;DateStamp
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DateStamp property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6470\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  DateStamp: TDateTime;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Last modified time stamp of the file adjusted to local time and converted to TDateTime.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6470
Scribble6470
DateStamp property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 DateTime\cf3\strike0\{linkID=6460\}\cf0\f0 
\par 
\par }
6490
Scribble6490
DateTime property
DateTime;DateTime,TZMDirEntry;TZMDirEntry,DateTime;


zipmstr20:001130
Writing


TZipDirEntry_DateTime;DateTime_Property;DateTime
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 DateTime property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6500\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  DateTime: Cardinal;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The last modified time stamp of the file - unadjusted in DOS format
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6500
Scribble6500
DateTime property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 DateStamp\cf3\strike0\{linkID=6460\}\cf0\f0 
\par 
\par }
6520
Scribble6520
Encoded property
Encoded;Encoded,TZMDirEntry;TZMDirEntry,Encoded;


zipmstr20:001135
Writing


TZMDirEntry_Encoded;Encoded_Property;Encoded
FALSE
23
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Encoded property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6530\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Encoded: \cf2\strike TZMEncodingOpts\cf3\strike0\{linkID=4700\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Returns how the file name and comment were encoded.
\par \f0 
\par    zeoUPATH- \f2 filename and/or comment stored as UTF8 in extra data using Info-Zip UPath or UComment tags - the strings in the header are OEM\f0 
\par    zeoUTF  - \f2 filename and/or comment stored as \f0 UTF8
\par    zeoOEM  - \f2 filename and/or comment stored are \f0 assume\f2 d to be\f0  OEM
\par    zeoNone - \f2 filename and/or comment stored are assumed to be\f0  Ansi\f2  in \cf2\strike Encoding_CP\cf3\strike0\{linkID=910\}\cf0  code page (defaults Windows current Ansi)\f0 
\par 
\par Run-time only
\par Read-only
\par 
\par }
6530
Scribble6530
Encoded property - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\f1 
\par \cf0\f0 
\par 
\par }
6550
Scribble6550
Encrypted property
Encrypted;Encrypted,TZMDirEntry;TZMDirEntry,Encrypted;


zipmstr20:001140
Writing


TZipDirEntry_Encrypted;Encrypted_Property;Encrypted
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Encrypted property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6560\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Encrypted: Boolean;
\par \f0 
\par \b\fs22 Description\b0\fs20 
\par \f2 True if file was encoded.
\par \tab := (Flag and 1) <> 0;
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6560
Scribble6560
Encrypted property - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 AddEncrypt\cf3\strike0\{linkTarget=AddEncrypt\}
\par \cf2\strike Password\cf3\strike0\{linkID=1530\}\cf0\f0 
\par 
\par }
6570
Scribble6570
Encrypted property - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Encrypted property example
\par \cf0\b0 
\par 
\par }
6580
Scribble6580
ExtFileAttrib property
ExtFileAttrib;ExtFileAttrib,TZMDirEntry;TZMDirEntry,ExtFileAttrib;


zipmstr20:001145
Writing


TZipDirEntry_ExtFileAttrib;ExtFileAttrib_Property;ExtFileAttrib
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExtFileAttrib property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6590\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ExtFileAttrib: Longword;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The file attributes - only lower 7 bits are mapped to Windows attributes
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6590
Scribble6590
ExtFileAttrib property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ExtFileAttrib property >>>
\par 
\par }
6610
Scribble6610
ExtraData property
ExtraData;ExtraData,TZMDirEntry;TZMDirEntry,ExtraData;


zipmstr20:001150
Writing


TZMDirEntry_ExtraData;ExtraData_Property;ExtraData
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExtraData property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6620\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ExtraData[Tag: Word]: \f2  \cf2\strike TZMRawBytes\cf3\strike0\{linkID=5275\}\cf0\f1 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Returns the first extra data having the supplied tag.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6620
Scribble6620
ExtraData property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ExtraData property >>>
\par 
\par }
6640
Scribble6640
ExtraField property
ExtraField;ExtraField,TZMDirEntry;TZMDirEntry,ExtraField;


zipmstr20:001155
Writing


TZMDirEntry_ExtraField;ExtraField_Property;ExtraField
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExtraField property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6650\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ExtraField:\f2  \cf2\strike TZMRawBytes\cf3\strike0\{linkID=5275\}\cf0\f1 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Returns a copy of the file extra data.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6650
Scribble6650
ExtraField property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ExtraField property >>>
\par 
\par }
6670
Scribble6670
ExtraFieldLength property
ExtraFieldLength;ExtraFieldLength,TZMDirEntry;TZMDirEntry,ExtraFieldLength;


zipmstr20:001160
Writing


TZMDirEntry_ExtraFieldLength;ExtraFieldLength_Property;ExtraFieldLength
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ExtraFieldLength property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6680\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  ExtraFieldLength: Word;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The length of the extra data field (in bytes).
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6680
Scribble6680
ExtraFieldLength property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ExtraFieldLength property >>>
\par 
\par }
6700
Scribble6700
FileComment property
FileComment;FileComment,TZMDirEntry;TZMDirEntry,FileComment;


zipmstr20:001165
Writing


TZMDirEntry_FileComment;FileComment_Property;FileComment
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 FileComment property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6710\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  FileComment: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Returns a copy of the file comment.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6710
Scribble6710
FileComment property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of FileComment property >>>
\par 
\par }
6730
Scribble6730
FileCommentLen property
FileCommentLen;FileCommentLen,TZMDirEntry;TZMDirEntry,FileCommentLen;


zipmstr20:001170
Writing


TZMDirEntry_FileCommentLen;FileCommentLen_Property;FileCommentLen
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 FileCommentLen property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6740\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  FileCommentLen: Word;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The internal length of the file comment field (in bytes).
\par Note: Because of string translation Length(FileComment) is likely to be different.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6740
Scribble6740
FileCommentLen property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of FileCommentLen property >>>
\par 
\par }
6760
Scribble6760
FileName property
FileName;FileName,TZMDirEntry;TZMDirEntry,FileName;


zipmstr20:001175
Writing


TZMDirEntry_FileName;FileName_Property;FileName
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 FileName property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6770\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  FileName: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The file name converted to external format and encoding.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6770
Scribble6770
FileName property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike\f1 Encoded\cf3\strike0\{linkID=6520\}\cf0\f0 
\par 
\par }
6790
Scribble6790
FileNameLength property
FileNameLength;FileNameLength,TZMDirEntry;TZMDirEntry,FileNameLength;


zipmstr20:001180
Writing


TZMDirEntry_FileNameLength;FileNameLength_Property;FileNameLength
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 FileNameLength property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6800\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  FileNameLength: Word;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The length of the internal file name field (in bytes).
\par Note: Because of string translation Length(FileName) is likely to be different.
\par 
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6800
Scribble6800
FileNameLength property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of FileNameLength property >>>
\par 
\par }
6820
Scribble6820
Flag property
Flag;Flag,TZMDirEntry;TZMDirEntry,Flag;


zipmstr20:001185
Writing


TZMDirEntry_Flag;Flag_Property;Flag
FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 Flag property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6830\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  Flag: Word;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Various bit flags settings indicating aspects of how the file was compressed.
\par 
\par    Bit 0 Set if file is encrypted.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6830
Scribble6830
Flag property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of Flag property >>>
\par 
\par }
6850
Scribble6850
HeaderName property
HeaderName;HeaderName,TZMDirEntry;TZMDirEntry,HeaderName;


zipmstr20:001190
Writing


TZMDirEntry_HeaderName;HeaderName_Property;HeaderName
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 HeaderName property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6860\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  HeaderName:\f2  \cf2\strike TZMRawBytes\cf3\strike0\{linkID=5275\}\cf0\f1 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The internal name as stored in the local header.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6860
Scribble6860
HeaderName property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \f1\fs24 
\par \cf2\b0\strike FileName\cf3\strike0\{linkID=6760\}\cf0 
\par \f0\fs20 
\par }
6880
Scribble6880
IntFileAttrib property
IntFileAttrib;IntFileAttrib,TZMDirEntry;TZMDirEntry,IntFileAttrib;


zipmstr20:001195
Writing


TZMDirEntry_IntFileAttrib;IntFileAttrib_Property;IntFileAttrib
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 IntFileAttrib property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6890\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  IntFileAttrib: Word;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Internal file attributes.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6890
Scribble6890
IntFileAttrib property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of IntFileAttrib property >>>
\par 
\par }
6903
Scribble6903
IsDirOnly property
TZMDirEntry,IsDirOnly;



Writing


TZMDirEntry_IntDirOnly;IsDirOnly_Property;IsDirOnly
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 IsDirOnly property\cf0\b0\f1\fs20 
\par \fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6\f0 906\f1\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property\b0  I\f3 sDirOnly\f2 : \f3 Boolean\f2 ;
\par \f1 
\par \b\fs22 Description
\par \b0\f0\fs20 Returns True if the entry is a path - paths end with a '/'.
\par \f1 
\par Run-time only
\par Read-only
\par \pard 
\par 
\par }
6906
Scribble6906
IsDirOnly - See also




Writing



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\fs24 See also\b 
\par 
\par \cf2\b0\strike\fs20 FileName\cf3\strike0\{linkID=6760\}\cf0 
\par \cf2\strike HeaderName\cf3\strike0\{linkID=6850\}
\par \cf2\strike UseDirOnlyEntries\cf3\strike0\{linkID=2170\}\cf0\f1 
\par 
\par 
\par }
6910
Scribble6910
RelOffLocalHdr property
RelOffLocalHdr;RelOffLocalHdr,TZMDirEntry;TZMDirEntry,RelOffLocalHdr;


zipmstr20:001200
Writing


TZMDirEntry_RelOffLocalHdr;RelOffLocalHdr_Property;RelOffLocalHdr
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 RelOffLocalHdr property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6920\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  RelOffLocalHdr: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Offset of the local zip header on the \cf2\strike StartOnDisk\cf3\strike0\{linkID=6940\}\cf0  part of the zip file.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6920
Scribble6920
RelOffLocalHdr property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of RelOffLocalHdr property >>>
\par 
\par }
6940
Scribble6940
StartOnDisk property
StartOnDisk;StartOnDisk,TZMDirEntry;TZMDirEntry,StartOnDisk;


zipmstr20:001205
Writing


TZMDirEntry_StartOnDisk;StartOnDisk_Property;StartOnDisk
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 StartOnDisk property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6950\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  StartOnDisk: Word;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The first disk of the local header.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
6950
Scribble6950
StartOnDisk property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of StartOnDisk property >>>
\par 
\par }
6970
Scribble6970
StatusBits property
StatusBits;StatusBits,TZMDirEntry;TZMDirEntry,StatusBits;


zipmstr20:001210
Writing


TZMDirEntry_StatusBits;StatusBits_Property;StatusBits
FALSE
28
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 StatusBits property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%6980\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  StatusBits: Cardinal;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Internal status bit flags used internally by ZipMaster.
\par \f0 
\par // Z\f2 M\f0 DirEntry status bit constants
\par const
\par   zsbDirty    = $1;
\par   zsbSelected = $2;
\par   zsbSkipped  = $4;
\par   zsbIgnore   = $8;
\par   zsbDirOnly  = $10;
\par   zsbInvalid  = $20;
\par   zsbError    = $40;  // processing error
\par 
\par Run-time only
\par Read-only
\par 
\par }
6980
Scribble6980
StatusBits property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of StatusBits property >>>
\par 
\par }
7000
Scribble7000
UncompressedSize property
TZMDirEntry,UncompressedSize;UncompressedSize;UncompressedSize,TZipDirEntry;


zipmstr20:001215
Writing


TZMDirEntry_UncompressedSize;UncompressedSize_Property;UncompressedSize
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 UncompressedSize property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7010\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  UncompressedSize: Int64;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 The size of the file before compression.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
7010
Scribble7010
UncompressedSize property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of UncompressedSize property >>>
\par 
\par }
7030
Scribble7030
VersionMadeBy property
TZMDirEntry,VersionMadeBy;VersionMadeBy;VersionMadeBy,TZipDirEntry;


zipmstr20:001220
Writing


TZMDirEntry_VersionMadeBy;VersionMadeBy_Property;VersionMadeBy
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 VersionMadeBy property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7040\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  VersionMadeBy: Word;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Indicates the program version that made the file (low byte) and the \cf2\strike operating system\cf3\strike0\{linkID=220\}\cf0  it was made in (high byte).
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
7040
Scribble7040
VersionMadeBy property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of VersionMadeBy property >>>
\par 
\par }
7060
Scribble7060
VersionNeeded property
TZMDirEntry,VersionNeeded;VersionNeeded;VersionNeeded,TZipDirEntry;


zipmstr20:001225
Writing


TZMDirEntry_VersionNeeded;VersionNeeded_Property;VersionNeeded
FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 VersionNeeded property
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7070\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirEntry\cf3\strike0\{linkID=6340\}\cf4  class
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 property\b0  VersionNeeded: Word;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Specifies what zip version (Low byte) and \cf2\strike operating system\cf3\strike0\{linkID=220\}\cf0  (high byte) is required for extraction.
\par \f0 
\par Run-time only
\par Read-only
\par 
\par }
7070
Scribble7070
VersionNeeded property - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of VersionNeeded property >>>
\par 
\par }
7090
Scribble7090
TZMDirRec class
TZMDirRec;


zipmstr20:001300
Writing


TZMDirRec_Object;TZMDirRec
FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZ\f1 M\f0 DirRec class
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7100\}\tab\cf2\ul Methods\cf3\ulnone\{linkID=%7110\}\cf0\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Description
\par \b0\f1\fs20 A sub-class of \cf2\strike TZMDirEntry\cf3\strike0\{linkID=6340\} \cf0 that allows changing some properties.
\par 
\par This is used via a \cf2\strike TZMChangeFunction\cf3\strike0\{linkID=4430\}\cf0  that is called by \cf2\strike ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf0 .\f0 
\par 
\par }
7100
Scribble7100
TZMDirRec class - See also




Writing



FALSE
8
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par \cf2\strike TZMDir\f1 Entry\cf3\strike0\{linkID=6340\}\cf0 
\par \cf2\strike ChangeFileDetails\cf3\strike0\{linkID=2680\}\cf0\f0 
\par 
\par }
7110
Scribble7110
TZMDirRec - Methods




Writing



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green0\blue0;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 Methods
\par \cf2\b0\{keepn\}\cf0 
\par \cf3 
\par \pard\tx200\tx640\cf2\f1\tab\cf4\strike ChangeAttrs\cf2\strike0\{linkID=7120\}\cf3 
\par \cf2\tab\cf4\strike ChangeComment\cf2\strike0\{linkID=7150\}\cf3 
\par \cf2\tab\cf4\strike ChangeData\cf2\strike0\{linkID=7180\}\cf3 
\par \cf2\tab\cf4\strike ChangeDate\cf2\strike0\{linkID=7210\}\cf3 
\par \cf2\tab\cf4\strike ChangeEncoding\cf2\strike0\{linkID=7240\}\cf3 
\par \cf2\tab\cf4\strike ChangeName\cf2\strike0\{linkID=7270\}\cf3 
\par \cf2\tab\cf4\strike ChangeStamp\cf2\strike0\{linkID=7300\}\cf3 
\par \cf0\f0 
\par }
7120
Scribble7120
ChangeAttrs method
ChangeAttrs;ChangeAttrs,TZMDirRec;TZMDirRec,ChangeAttrs;


zipmstr20:001310
Writing


TZMDirRec_ChangeAttrs;ChangeAttrs_Method;ChangeAttrs
FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ChangeAttrs method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7130\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7140\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirRec\cf3\strike0\{linkID=7090\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ChangeAttrs(nAttr: Cardinal): Integer; \b virtual\b0 ; \b abstract\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Allows changing an entries \cf2\strike external attributes\cf3\strike0\{linkID=6580\}.
\par \cf0 Returns non-zero \cf2\strike error code\cf3\strike0\{linkID=300\}\cf0  or 0 for success.\f0 
\par 
\par }
7130
Scribble7130
ChangeAttrs method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ChangeAttrs method >>>
\par 
\par }
7140
Scribble7140
ChangeAttrs method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ChangeAttrs method example
\par \cf0\b0 
\par 
\par }
7150
Scribble7150
ChangeComment method
ChangeComment;ChangeComment,TZMDirRec;TZMDirRec,ChangeComment;


zipmstr20:001315
Writing


TZMDirRec_ChangeComment;ChangeComment_Method;ChangeComment
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ChangeComment method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7160\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7170\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirRec\cf3\strike0\{linkID=7090\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ChangeComment(\b const\b0  ncomment: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ): Integer; \b virtual\b0 ; \b abstract\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Allows changing an entries \cf2\strike Comment\cf3\strike0\{linkID=6700\}.
\par \cf0 Returns non-zero \cf2\strike error code\cf3\strike0\{linkID=300\}\cf0  or 0 for success.\f0 
\par 
\par 
\par }
7160
Scribble7160
ChangeComment method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ChangeComment method >>>
\par 
\par }
7170
Scribble7170
ChangeComment method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ChangeComment method example
\par \cf0\b0 
\par 
\par }
7180
Scribble7180
ChangeData method
ChangeData;ChangeData,TZMDirRec;TZMDirRec,ChangeData;


zipmstr20:001320
Writing


TZMDirRec_ChangeData;ChangeData_Method;ChangeData
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ChangeData method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7190\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7200\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirRec\cf3\strike0\{linkID=7090\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ChangeData(ndata: \cf2\strike\f2 TZMRawBytes\cf3\strike0\{linkID=5275\}\cf0\f1 ): Integer; \b virtual\b0 ; \b abstract\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Allows changing an entries \cf2\strike Extra Data\cf3\strike0\{linkID=6640\}.
\par \cf0 Returns non-zero \cf2\strike error code\cf3\strike0\{linkID=300\}\cf0  or 0 for success.\f0 
\par 
\par 
\par }
7190
Scribble7190
ChangeData method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ChangeData method >>>
\par 
\par }
7200
Scribble7200
ChangeData method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ChangeData method example
\par \cf0\b0 
\par 
\par }
7210
Scribble7210
ChangeDate method
ChangeDate;ChangeDate,TZMDirRec;TZMDirRec,ChangeDate;


zipmstr20:001325
Writing


TZMDirRec_ChangeDate;ChangeDate_Method;ChangeDate
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ChangeDate method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7220\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7230\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirRec\cf3\strike0\{linkID=7090\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ChangeDate(ndosdate: Cardinal): Integer; \b virtual\b0 ; \b abstract\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Allows changing an entries \cf2\strike Date stamp\cf3\strike0\{linkID=6490\}.
\par \cf0 Returns non-zero \cf2\strike error code\cf3\strike0\{linkID=300\}\cf0  or 0 for success.
\par 
\par ndosdate is date in DOS format.\f0 
\par 
\par 
\par }
7220
Scribble7220
ChangeDate method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ChangeDate method >>>
\par 
\par }
7230
Scribble7230
ChangeDate method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ChangeDate method example
\par \cf0\b0 
\par 
\par }
7240
Scribble7240
ChangeEncoding method
ChangeEncoding;ChangeEncoding,TZMDirRec;TZMDirRec,ChangeEncoding;


zipmstr20:001330
Writing


TZMDirRec_ChangeEncoding;ChangeEncoding_Method;ChangeEncoding
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ChangeEncoding method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7250\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7260\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirRec\cf3\strike0\{linkID=7090\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ChangeEncoding: Integer; \b virtual\b0 ; \b abstract\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Allows changing how an entry is \cf2\strike encoded\cf3\strike0\{linkID=6520\}
\par \cf0 Returns non-zero \cf2\strike error code\cf3\strike0\{linkID=300\}\cf0  or 0 for success.\f0 
\par 
\par 
\par }
7250
Scribble7250
ChangeEncoding method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ChangeEncoding method >>>
\par 
\par }
7260
Scribble7260
ChangeEncoding method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ChangeEncoding method example
\par \cf0\b0 
\par 
\par }
7270
Scribble7270
ChangeName method
ChangeName;ChangeName,TZMDirRec;TZMDirRec,ChangeName;


zipmstr20:001335
Writing


TZMDirRec_ChangeName;ChangeName_Method;ChangeName
FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ChangeName method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7280\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7290\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirRec\cf3\strike0\{linkID=7090\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ChangeName(\b const\b0  nname: \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ): Integer; \b virtual\b0 ; \b abstract\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Allows changing an entries \cf2\strike name\cf3\strike0\{linkID=6760\}.
\par \cf0 Returns non-zero \cf2\strike error code\cf3\strike0\{linkID=300\}\cf0  or 0 for success.
\par 
\par Changes both internal and external names and may cause \cf2\strike Encoded \cf3\strike0\{linkID=6520\}\cf0 to change\f0 
\par 
\par 
\par }
7280
Scribble7280
ChangeName method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ChangeName method >>>
\par 
\par }
7290
Scribble7290
ChangeName method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ChangeName method example
\par \cf0\b0 
\par 
\par }
7300
Scribble7300
ChangeStamp method
ChangeStamp;ChangeStamp,TZMDirRec;TZMDirRec,ChangeStamp;


zipmstr20:001340
Writing


TZMDirRec_ChangeStamp;ChangeStamp_Method;ChangeStamp
FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ChangeStamp method
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7310\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7320\}\cf4\{keepn\}\cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMDirRec\cf3\strike0\{linkID=7090\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ChangeStamp(ndate: TDateTime): Integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Allows changing an entry's \cf2\strike Date stamp\cf3\strike0\{linkID=6460\}.
\par \cf0 Returns non-zero \cf2\strike error code\cf3\strike0\{linkID=300\}\cf0  or 0 for success.\f0 
\par 
\par 
\par }
7310
Scribble7310
ChangeStamp method - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ChangeStamp method >>>
\par 
\par }
7320
Scribble7320
ChangeStamp method - Example




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 ChangeStamp method example
\par \cf0\b0 
\par 
\par }
7330
Scribble7330
TZipMasterEnumerator class
TZipMasterEnumerator;


ZipMstr20:001400
Writing


TZipMasterEnumerator_Object;TZipMasterEnumerator
FALSE
13
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red128\green0\blue0;\red0\green0\blue0;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZipMasterEnumerator class
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\tab\cf3\{keepn\}\cf0\b\fs22 
\par Unit
\par \cf4\b0\strike\fs20 ZipMstr19\cf2\strike0\{linkID=330\}\cf3 
\par 
\par \cf0\b\fs22 Description
\par \b0\f1\fs20 D2007 and later only.
\par Allows using for .. in .. to iterate the \cf4\strike DirEntries\cf2\strike0\{linkID=660\}\cf0\f0 
\par 
\par }
7340
Scribble7340
TZMPipe class
TZMPipe;



Writing



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMPipe class
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7\f1 35\f0 0\}\tab\cf2\ul\f1 Properties\cf3\ulnone\f0\{linkID=%7\f1 36\f0 0\}\f1\{keepn\}\cf0\b\f0\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Description
\par \b0\f1\fs20 A class to enable connecting streams so that they can be added to, or extracted from, a zip file - this can be done while processing other files.
\par \pard\cf4\f0 
\par 
\par 
\par }
7350
Scribble7350
TZMPipe class - See also




Writing



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs20 See also
\par \cf2\b0\f1 
\par \cf3\strike\f0 TZipMaster properties\cf4\strike0\{linkID=380\}\cf2 
\par \cf3\strike Add\cf4\strike0\{linkID=2530\}\cf2 
\par \cf3\strike Extract\cf4\strike0\{linkID=2960\}\cf2 
\par \cf3\strike TZMPipeList\cf4\strike0\{linkID=7440\}\cf2\f1 
\par \cf3\strike\f0 Using streams\cf4\strike0\{linkID=7370\}\cf2\f1 
\par }
7360
Scribble7360
TZMPipe class - Properties




Writing



FALSE
12
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 TZMPipe class - Properties\cf2\b0\f1\fs20 
\par 
\par 
\par \cf3\strike Attributes\cf4\strike0\{linkID=7380\}\cf2 
\par \cf3\strike\f0 DOSDate\cf4\strike0\f1\{linkID=7390\}\cf2 
\par \cf3\strike\f0 FileName\cf4\strike0\f1\{linkID=7400\}\cf2 
\par \cf3\strike\f0 OwnsStream\cf4\strike0\f1\{linkID=7410\}\cf2 
\par \cf3\strike\f0 Size\cf4\strike0\f1\{linkID=7420\}\cf2 
\par \cf3\strike\f0 Stream\cf4\strike0\f1\{linkID=7430\}\cf2 
\par }
7370
Scribble7370
TZMPipe class - Using




Writing



FALSE
6
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs24 TZMPipe class - Using\cf2\b0\f1\fs20 
\par 
\par 
\par }
7380
Scribble7380
Attributes property




Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Attributes\f1  property\cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7360\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7370\}\cf4\{keepn\}
\par \cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMPipe\cf3\strike0\{linkID=7340\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property Attributes: Cardinal\f3 ;\b0\f2 
\par \f1 
\par \b\fs22 Description
\par \pard\cf4\b0\f0\fs20   Standard DOS file attributes.
\par   Only used when writing a stream to the zip.\f1 
\par 
\par 
\par }
7390
Scribble7390
DOSDate property




Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 DOSDate property\cf0\b0\f1\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7360\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7370\}\cf4\{keepn\}
\par \cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMPipe\cf3\strike0\{linkID=7340\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property \f3 DOSDate\f2 : Cardinal\f3 ;\b0\f2 
\par \f1 
\par \b\fs22 Description
\par \pard\cf4\b0\f0\fs20   Standard DOS file stamp.
\par   Only used when writing a stream to the zip.\f1 
\par 
\par }
7400
Scribble7400
FileName property




Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 FileName property\cf0\b0\f1\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7360\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7370\}\cf4\{keepn\}
\par \cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMPipe\cf3\strike0\{linkID=7340\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property \f3 FileName\f2 : \f3 String;\b0\f2 
\par \f1 
\par \b\fs22 Description
\par \pard\cf4\b0\f0\fs20   File name as it is or will be in the zip file.
\par   
\par   \b\fs24 Note\b0\fs20  - No drive or wild cards are allowed.\f1 
\par 
\par }
7410
Scribble7410
OwnsStream property




Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 OwnsStream property\cf0\b0\f1\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7360\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7370\}\cf4\{keepn\}
\par \cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMPipe\cf3\strike0\{linkID=7340\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property \f3 OwnsStream\f2 : \f3 boolean;\b0\f2 
\par \f1 
\par \b\fs22 Description
\par \pard\cf4\b0\f0\fs20   If True the list will destroy the stream when the operation is complete or on failure.\f1 
\par 
\par 
\par 
\par }
7420
Scribble7420
Size property




Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Size property\cf0\b0\f1\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7360\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7370\}\cf4\{keepn\}
\par \cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMPipe\cf3\strike0\{linkID=7340\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property \f3 Size\f2 : \f3 Integer;\b0\f2 
\par \f1 
\par \b\fs22 Description
\par \pard\cf4\b0\f0\fs20   The size of the stream.
\par   This will be set automatically when a stream is assigned
\par   Only used when writing a stream to the zip.\f1 
\par 
\par 
\par 
\par }
7430
Scribble7430
Stream property




Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}{\f3\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Stream property\cf0\b0\f1\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7360\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7370\}\cf4\{keepn\}
\par \cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMPipe\cf3\strike0\{linkID=7340\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 property \f3 Stream\f2 : \f3 TStream;\b0\f2 
\par \f1 
\par \b\fs22 Description
\par \pard\cf4\b0\f0\fs20   The stream to be added to or, extracted from, the zip file.
\par 
\par   \b\fs24 Note \b0\fs20 - Must be created and positioned to the beginning.\f1 
\par 
\par 
\par }
7440
Scribble7440
TZMPipeList class
TZMPipe;



Writing



FALSE
14
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 TZMPipeList class\f1 
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7\f0 45\f1 0\}\tab\cf2\ul\f0 Methods\cf3\ulnone\f1\{linkID=%7\f0 46\f1 0\}\f0\{keepn\}\cf0\b\f1\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZipMstr19\cf3\strike0\{linkID=330\}\cf4 
\par 
\par \cf0\b\fs22 Description
\par \b0\f0\fs20 A list class for holding \cf2\strike TZMPipe\cf3\strike0\{linkID=7340\}\cf0 .
\par \pard\cf4\f1 
\par 
\par 
\par }
7450
Scribble7450
TZMPipeList class - See also




Writing



FALSE
12
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red0\green128\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs20 See also\fs24 
\par \cf2\b0\f1\fs20 
\par \cf3\strike\f0 TZipMaster properties\cf4\strike0\{linkID=380\}\cf2 
\par \cf3\strike Add\cf4\strike0\{linkID=2530\}\cf2 
\par \cf3\strike Extract\cf4\strike0\{linkID=2960\}\cf2 
\par \cf3\strike TZMPipe\cf4\strike0\{linkID=7340\}\cf2\f1 
\par 
\par 
\par 
\par }
7460
Scribble7460
TZMPipeList class - Methods




Writing



FALSE
11
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red255\green0\blue255;\red128\green0\blue0;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\fs28 TZMPipeList class - Methods\cf2\b0\f1\fs20 
\par 
\par 
\par     \cf3\f2\tab\cf4\f1\tab\cf5\strike A\f0 dd\cf4\strike0\f1\{linkID=7470\}\cf2 
\par     \cf3\f2\tab\cf4\f1\tab\cf5\strike\f0 Clear\cf4\strike0\f1\{linkID=7480\}\cf2 
\par 
\par 
\par 
\par }
7470
Scribble7470
Add method




Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Add method\f1 
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7450\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7370\}\cf4\{keepn\}
\par \cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMPipe\f0 List\cf3\strike0\f1\{linkID=7440\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 function\b0  Add(aStream: TStream; const FileName: string; Own: boolean): integer;
\par \f1 
\par \b\fs22 Description
\par \b0\f0\fs20 Adds a stream to the list.
\par Returns the index in the list.\cf3 
\par \pard\cf4\f1 
\par 
\par 
\par }
7480
Scribble7480
Clear method




Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil Arial;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\fs32 Clear method\f1 
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\cf2\ul See also\cf3\ulnone\{linkID=%7450\}\tab\cf2\strike Example\cf3\strike0\{linkID=%7370\}\cf4\{keepn\}
\par \cf0\b\fs22 
\par Applies to
\par \cf2\b0\strike\fs20 TZMPipe\f0 List\cf3\strike0\f1\{linkID=7440\}\cf4  component
\par 
\par \cf0\b\fs22 Declaration
\par \f2\fs20 procedure \b0 Clear\f3 ;
\par \f1 
\par \b\fs22 Description
\par \pard\cf4\b0\f0\fs20 Clears all entries destroying all streams that it \cf2\strike owns\cf3\strike0\{linkID=7410\}\cf4 .\f1 
\par 
\par 
\par }
7490
Scribble7490
TZMPipeList class - Properties




Writing



FALSE
10
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fswiss\fcharset0 Arial;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green0\blue0;\red255\green0\blue255;\red128\green0\blue0;\red0\green128\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 TZMPipeList class - Properties\cf2\b0\fs20 
\par 
\par 
\par     \cf3\f1\{bmc GrnBullet.bmp\}\f2\tab\cf4\f0\tab\cf5\strike\f3 Pipe\cf4\strike0\f0\{linkID=7490\}\cf2 
\par 
\par 
\par 
\par }
7600
Scribble7600
ZMUTF819 unit
ZMUTF819;ZMUTF819 unit;


ZMUTF819:001000
Writing



FALSE
31
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fswiss Arial;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red0\green0\blue0;\red128\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ZMUTF819 unit
\par \cf2\b0\strike\f1\fs20 TZipMaster\strike0\{linkID=10\}\cf3\f0\fs16\{keepn\}\cf0\fs20 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\f2 UTF8 conversion and test functions used by TZipMaster that can also be used by users.\f0 
\par 
\par \b\fs22 Routines
\par \cf2\b0\strike\fs20 AnsiIsSafe\cf4\strike0\{linkID=7620\}\cf3 
\par \cf2\strike AsUTF8Str\cf4\strike0\{linkID=7630\}\cf3 
\par \cf2\strike IsUTF8Trail\cf4\strike0\{linkID=7720\}\cf3 
\par \cf2\strike PUTF8ToSafe\cf4\strike0\{linkID=7640\}\cf3 
\par \cf2\strike PUTF8ToStr\cf4\strike0\{linkID=7650\}\cf3 
\par \cf2\strike PUTF8ToWideStr\cf4\strike0\{linkID=7660\}\cf3 
\par \cf2\strike PWideToUTF8\cf4\strike0\{linkID=7670\}\cf3 
\par \cf2\strike StrToUTF8\cf4\strike0\{linkID=7680\}\cf3 
\par \cf2\strike StrToUTFEx\cf4\strike0\{linkID=7690\}\cf3 
\par \cf2\strike StrToWideEx\cf4\strike0\{linkID=7700\}\cf3 
\par \cf2\strike UTF8IsSafe\cf4\strike0\{linkID=7710\}\cf3 
\par \cf2\strike UTF8SeqLen\cf4\strike0\{linkID=7730\}\cf3 
\par \cf2\strike UTF8ToSafe\cf4\strike0\{linkID=7640\}\cf3 
\par \cf2\strike UTF8ToStr\cf4\strike0\{linkID=7650\}\cf3 
\par \cf2\strike UTF8ToWide\cf4\strike0\{linkID=7660\}\cf3 
\par \cf2\strike ValidUTF8\cf4\strike0\{linkID=7740\}\cf3 
\par \cf2\strike ValidUTF8\cf4\strike0\{linkID=7740\}\cf3 
\par \cf2\strike ValidUTF8\cf4\strike0\{linkID=7740\}\cf3 
\par \cf2\strike WideIsSafe\cf4\strike0\{linkID=7750\}\cf3 
\par \cf2\strike WideToSafe\cf4\strike0\{linkID=7760\}\cf3 
\par \cf2\strike WideToUTF8\cf4\strike0\{linkID=7670\}\cf3 
\par 
\par \cf0 
\par }
7610
Scribble7610
ZMUTF819 unit - See also




Writing



FALSE
7
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}}
{\colortbl ;\red0\green0\blue255;}
\viewkind4\uc1\pard\cf1\b\f0\fs20 See also
\par \cf0\b0 
\par <<< See also of ZMUTF819 unit >>>
\par 
\par }
7620
Scribble7620
AnsiIsSafe function
AnsiIsSafe;


ZMUTF819:001100
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AnsiIsSafe function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  AnsiIsSafe(\b const\b0  ustr: AnsiString; ToOEM: boolean): Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 When ToEOM is True, verify all characters in ustr can safely be converted.\f0 
\par 
\par }
7630
Scribble7630
AsUTF8Str function
AsUTF8Str;


ZMUTF819:001105
Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 AsUTF8Str function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  AsUTF8Str(\b const\b0  zstr: TZMString): UTF8String;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Converts zstr to an UTF8String if \f2 it has extended characters.\f0 
\par 
\par 
\par }
7640
Scribble7640
PUTF8ToSafe function
PUTF8ToSafe;


ZMUTF819:001115
Writing



FALSE
19
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 PUTF8ToSafe function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  PUTF8ToSafe(\b const\b0  raw: PAnsiChar; len: integer): AnsiString;\b\f0\fs22 
\par \f1\fs20 function\b0  UTF8ToSafe(\b const\b0  ustr: AnsiString; ToOEM: boolean): AnsiString;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Converts a string of char or an Ansistring into an AnsiString escaping unsupported characters using
\par code page CP_OEMCP when ToOEM is true,
\par codepage CP_ACP when ToOEM is false.
\par 
\par 
\par }
7650
Scribble7650
PUTF8ToStr function
PUTF8ToStr;


ZMUTF819:001120
Writing



FALSE
20
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 PUTF8ToStr function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  PUTF8ToStr(\b const\b0  raw: PAnsiChar; len: integer): \b\f2 S\f1 tring\b0 ;\b\f0\fs22 
\par \f1\fs20 function\b0  UTF8ToStr(\b const\b0  astr: UTF8String): \b String\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Converts a string of AnsiChar or an UTF8 string into a String:
\par On Unicode versions (CB2009 or later) this is a standard String.
\par On earlier versions String is an AnsiString  
\par 
\par 
\par 
\par }
7660
Scribble7660
PUTF8ToWideStr function
PUTF8ToWideStr;


ZMUTF819:001125
Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 PUTF8ToWideStr function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  PUTF8ToWideStr(\b const\b0  raw: PAnsiChar; len: integer): TZMWideString;\b\f0\fs22 
\par \f1\fs20 function\b0  UTF8ToWide(\b const\b0  astr: UTF8String; len: integer = - 1): TZMWideString;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Converts a string of AnsiChar or an UTF8 string into a\b  \cf2\b0\strike TZMWideString\cf3\strike0\{linkID=5310\}\cf0 .\f1 
\par \f0 
\par 
\par }
7670
Scribble7670
PWideToUTF8 function
PWideToUTF8;


ZMUTF819:001130
Writing



FALSE
17
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 PWideToUTF8 function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  PWideToUTF8(\b const\b0  pwstr: PWideChar; len: integer = -1): UTF8String;\b\f0\fs22 
\par \f1\fs20 function\b0  WideToUTF8(\b const\b0  astr: \cf2\strike TZMWideString\cf3\strike0\{linkID=5310\}\cf0 ; len: integer = -1): UTF8String;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Converts a string of WideChar to UTF8.
\par If len = -1 all of the characters up to the terminating #0 are used.\f0 
\par 
\par }
7680
Scribble7680
StrToUTF8 function
StrToUTF8;


ZMUTF819:001135
Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Courier New;}{\f3\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 StrToUTF8 function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  StrToUTF8(\b const\b0  ustr: \b\f2 S\f1 tring\b0 ): UTF8String;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Converts a String into an UTF8String
\par On Unicode versions (CB2009 or later) String is a standard \f3 Unicode\f0 String.
\par On earlier versions String is an AnsiString
\par }
7690
Scribble7690
StrToUTFEx function
StrToUTFEx;


ZMUTF819:001140
Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 StrToUTFEx function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  StrToUTFEx(\b const\b0  astr: AnsiString; cp: cardinal = 0; len: integer = - 1): \cf2\strike TZMString\cf3\strike0\{linkID=5280\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Converts an AnsiString into a TZ\f2 M\f0 String, using the codepage cp and the length len, if len is -1 the total length of astr is used.
\par 
\par 
\par }
7700
Scribble7700
StrToWideEx function
StrToWideEx;


ZMUTF819:001145
Writing



FALSE
16
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 StrToWideEx function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  StrToWideEx(\b const\b0  astr: AnsiString; cp: cardinal; len: integer): \cf2\strike TZMWideString\cf3\strike0\{linkID=5310\}\cf0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Converts an AnsiString into a TZ\f2 M\f0 WideString, using the codepage cp and the length len, if len is -1 the total length of astr is used.
\par 
\par 
\par }
7710
Scribble7710
UTF8IsSafe function
UTF8IsSafe;


ZMUTF819:001150
Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 UTF8IsSafe function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  UTF8IsSafe(\b const\b0  ustr: AnsiString; ToOEM: boolean): Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Returns true if all characters in ustr are supported using
\par \f2   \f0 code page CP_OEMCP when ToOEM is true,
\par \f2   \f0 codepage CP_ACP when ToOEM is false.
\par 
\par 
\par }
7720
Scribble7720
IsUTF8Trail function
IsUTF8Trail;


ZMUTF819:001110
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 IsUTF8Trail function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  IsUTF8Trail(c: AnsiChar): boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Returns True if c is a trailing character of a multi-character sequence.\f0 
\par 
\par }
7730
Scribble7730
UTF8SeqLen function
UTF8SeqLen;


ZMUTF819:001155
Writing



FALSE
15
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 UTF8SeqLen function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  UTF8SeqLen(c: AnsiChar): integer;
\par \f0 
\par \b\fs22 Description
\par \b0\f2\fs20 Returns the number of bytes in an UTF8 multi-byte code sequence.\f0 
\par 
\par }
7740
Scribble7740
ValidUTF8 function
ValidUTF8;


ZMUTF819:001175
Writing



FALSE
21
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 ValidUTF8 function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  ValidUTF8(\b const\b0  str: AnsiString; len: integer = - 1): integer; \b overload\b0 ;\b\f0\fs22 
\par \f1\fs20 function\b0  ValidUTF8(\b const\b0  str: UTF8String; len: integer = - 1): integer; \b overload\b0 ;\b\f0\fs22 
\par \f1\fs20 function\b0  ValidUTF8(pstr: PAnsiChar; len: integer): integer; \b overload\b0 ;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Test for valid UTF8 character(s) in the string
\par return  > 0 \tab if some valid UTF8 characters are present
\par return 0 \tab if no UTF8 characters are present
\par return < 0 \tab if some characters are invalid UTF8 characters
\par 
\par 
\par }
7750
Scribble7750
WideIsSafe function
WideIsSafe;


ZMUTF819:001190
Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 WideIsSafe function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  WideIsSafe(\b const\b0  wstr: \cf2\strike TZMWideString\cf3\strike0\{linkID=5310\}\cf0 ; ToOEM: boolean): Boolean;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Returns true if all characters in wstr are supported using
\par \f2   \f0 code page CP_OEMCP when ToOEM is true,
\par \f2   \f0 codepage CP_ACP when ToOEM is false.
\par 
\par 
\par }
7760
Scribble7760
WideToSafe function
WideToSafe;


ZMUTF819:001195
Writing



FALSE
18
{\rtf1\ansi\ansicpg1252\deff0\deflang3081{\fonttbl{\f0\fnil Arial;}{\f1\fnil Courier New;}{\f2\fnil\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red0\green128\blue0;\red128\green0\blue0;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\b\f0\fs32 WideToSafe function
\par \cf0\b0\fs16 
\par \pard\tx1440\tx2880\tx4320\tx5760\tx7200\tx8640\{keepn\}\b\fs22 
\par Unit
\par \cf2\b0\strike\fs20 ZMUTF819\cf3\strike0\{linkID=7600\}\cf4 
\par 
\par \cf0\b\fs22 Declaration
\par \f1\fs20 function\b0  WideToSafe(\b const\b0  wstr: \cf2\strike TZMWideString\cf3\strike0\{linkID=5310\}\cf0 ; ToOEM: boolean): AnsiString;
\par \f0 
\par \b\fs22 Description
\par \b0\fs20 Convert a TZ\f2 M\f0 WideString to AnsiString escaping unsupported characters using
\par \f2   \f0 code page CP_OEMCP when ToOEM is true,
\par \f2   \f0 codepage CP_ACP when ToOEM is false.
\par 
\par 
\par }
1
pme="Properties, Methods, Events",(512,0,256,512),0,,,0
0
0
306
1 TZipMaster component
2 TZipMaster component Reference=Scribble350
2 Properties
3 AddCompLevel=Scribble430
3 AddFrom=Scribble440
3 AddOptions=Scribble470
3 AddStoreSuffixes=Scribble500
3 Build=Scribble530
3 Busy=Scribble550
3 Cancel=Scribble580
3 ConfirmErase=Scribble610
3 Count=Scribble630
3 DirEntry=Scribble660
3 DirOnlyCnt=Scribble690
3 DLL_Build=Scribble710
3 DLL_Load=Scribble730
3 DLL_Path=Scribble760
3 DLL_Version=Scribble790
3 DLLDirectory=Scribble820
3 EncodeAs=Scribble850
3 Encoding=Scribble880
3 Encoding_CP=Scribble910
3 ErrCode=Scribble940
3 ErrMessage=Scribble970
3 ExtAddStoreSuffixes=Scribble1000
3 ExtrBaseDir=Scribble1030
3 ExtrOptions=Scribble1060
3 FSpecArgs=Scribble1090
3 FSpecArgsExcl=Scribble1130
3 FullErrCode=Scribble1160
3 Handle=Scribble1190
3 HowToDelete=Scribble1200
3 IsSpanned=Scribble1230
3 KeepFreeOnAllDisks=Scribble1260
3 KeepFreeOnDisk1=Scribble1290
3 Language=Scribble1320
3 LanguageInfo=Scribble1350
3 MaxVolumeSize=Scribble1380
3 MaxVolumeSizeKb=Scribble1410
3 MinFreeVolumeSize=Scribble1440
3 NoSkipping=Scribble1470
3 NotMainThread=Scribble1500
3 OnSetCompLevel=Scribble6140
3 OnStateChange=Scribble6940
3 OnWinError=Scribble4290
3 Password=Scribble1530
3 PasswordReqCount=Scribble1570
3 Pipes=Scribble13515
3 RootDir=Scribble1630
3 SFXCaption=Scribble1660
3 SFXCommandLine=Scribble1690
3 SFXDefaultDir=Scribble1720
3 SFXIcon=Scribble1750
3 SFXMessage=Scribble1780
3 SFXOffset=Scribble1810
3 SFXOptions=Scribble1840
3 SFXOverwriteMode=Scribble1870
3 SFXPath=Scribble1900
3 SFXRegFailPath=Scribble1930
3 SpanOptions=Scribble1960
3 SuccessCnt=Scribble1990
3 TempDir=Scribble2020
3 TotalSizeToProcess=Scribble2050
3 Trace=Scribble2080
3 Unattended=Scribble2110
3 UnzBusy=Scribble2140
3 UseDirOnlyEntries=Scribble2170
3 UseUTF8=Scribble2200
3 Verbose=Scribble2230
3 Version=Scribble2260
3 WriteOptions=Scribble2290
3 ZipBusy=Scribble2320
3 ZipComment=Scribble2350
3 ZipEOC=Scribble2380
3 ZipFileName=Scribble2410
3 ZipFileSize=Scribble2440
3 ZipSOC=Scribble2470
3 ZipStream=Scribble2500
2 Methods
3 Add=Scribble2530
3 AddStreamToFile=Scribble2560
3 AddStreamToStream=Scribble2590
3 AddZippedFiles=Scribble2620
3 AppendSlash=Scribble2650
3 ChangeFileDetails=Scribble2680
3 ConvertToSFX=Scribble2720
3 ConvertToSpanSFX=Scribble2750
3 ConvertToZIP=Scribble2780
3 Copy_File=Scribble2810
3 CopyZippedFiles=Scribble2840
3 Deflate=Scribble2870
3 Delete=Scribble2900
3 EraseFile=Scribble2930
3 Extract=Scribble2960
3 ExtractFileToStream=Scribble2990
3 ExtractStreamToStream=Scribble3020
3 Find=Scribble3050
3 ForEach=Scribble3080
3 FullVersionString=Scribble3110
3 GetAddPassword=Scribble3120
3 GetEnumerator=Scribble3150
3 GetExtrPassword=Scribble3160
3 GetPassword=Scribble3190
3 IndexOf=Scribble3220
3 IsZipSFX=Scribble3250
3 List=Scribble3280
3 MakeTempFileName=Scribble3310
3 QueryZip=Scribble3320
3 ReadSpan=Scribble3350
3 Rename=Scribble3380
3 TheErrorCode=Scribble3410
3 Undeflate=Scribble3440
3 WriteSpan=Scribble3470
3 ZipLoadStr=Scribble3510
3 AbortDLL=Scribble3540
3 Clear=Scribble3570
3 ShowExceptionError=Scribble3600
3 ShowZipFmtMessage=Scribble3630
3 ShowZipMessage=Scribble3660
2 Events
3 OnCheckTerminate=Scribble3690
3 OnCopyZippedOverwrite=Scribble3720
3 OnCRC32Error=Scribble3750
3 OnDirUpdate=Scribble3780
3 OnExtractOverwrite=Scribble3810
3 OnFileComment=Scribble3840
3 OnFileExtra=Scribble3870
3 OnGetNextDisk=Scribble3900
3 OnMessage=Scribble3930
3 OnNewName=Scribble3960
3 OnPasswordError=Scribble3990
3 OnProgressDetails=Scribble4020
3 OnSetAddName=Scribble4050
3 OnSetExtName=Scribble4080
3 OnSkipped=Scribble4140
3 OnStatusDisk=Scribble4170
3 OnStream=Scribble4230
3 OnTick=Scribble4260
3 OnZipDialog=Scribble4320
2 Types
3 PZMSStats type=Scribble4380
3 TSFXOpt type=Scribble4390
3 TSFXOpts type=Scribble4410
3 TZMChangeFunction type=Scribble4430
3 TZMForEachFunction type=Scribble4450
3 TZMRenameRec type=Scribble4470
3 TZMAddOpts type=Scribble4490
3 TZMAddOptsEnum type=Scribble4510
3 TZMAddStoreExts type=Scribble4530
3 TZMAddStoreSuffixEnum type=Scribble4550
3 TZMCheckTerminateEvent type=Scribble4570
3 TZMCopyZippedOverwriteEvent type=Scribble4590
3 TZMCRC32ErrorEvent type=Scribble4610
3 TZMDeleteOpts type=Scribble4630
3 TZMDiskAction type=Scribble4680
3 TZMEncodingOpts type=Scribble4700
3 TZMExtractOverwriteEvent type=Scribble4720
3 TZMExtrOpts type=Scribble4740
3 TZMExtrOptsEnum type=Scribble4760
3 TZMFileCommentEvent type=Scribble4780
3 TZMFileExtraEvent type=Scribble4800
3 TZMGetNextDiskEvent type=Scribble4820
3 TZMMergeOpts type=Scribble4840
3 TZMMessageEvent type=Scribble4860
3 TZMNewNameEvent type=Scribble4880
3 TZMOvrOpts type=Scribble4900
3 TZMPasswordErrorEvent type=Scribble4920
3 TZMPipe=Scribble7340
3 TZMPipeList=Scribble7440
3 TZMProgressType type=Scribble4960
3 TZMRenameOpts type=Scribble4980
3 TZMReplaceOpts type=Scribble5000
3 TZMSetAddNameEvent type=Scribble5020
3 TZMSetCompLevel type=Scribble5040
3 TZMSetExtNameEvent type=Scribble5060
3 TZMSkippedEvent type=Scribble5080
3 TZMSkipTypes type=Scribble5100
3 TZMSkipAborts type=Scribble5120
3 TZMSpanOpts type=Scribble5140
3 TZMSpanOptsEnum type=Scribble5160
3 TZMStateChange type=Scribble5180
3 TZMStates type=Scribble5200
3 TZMStatusDiskEvent type=Scribble5220
3 TZMLoadStrEvent type=Scribble5260
3 TZMRawBytes type=Scribble5275
3 TZMString type=Scribble5280
3 TZMTickEvent type=Scribble5290
3 TZMTickEvent type=Scribble5290
3 TZMTickEvent type=Scribble5290
3 TZMWideString type=Scribble5310
3 TZMWinActions type=Scribble5330
3 TZMWinError type=Scribble5350
3 TZMWinOps type=Scribble5370
3 TZMWriteOpts type=Scribble5390
3 TZMWriteOptsEnum type=Scribble5410
3 TZMZipDiskStatus type=Scribble5430
3 TZMSStats type=Scribble5470
3 TZMStreamOp type=Scribble5490
3 TPathSlashDirection type=Scribble5530
1 TZMProgressDetails class
2 TZMProgressDetails class Reference=@
2 Properties
3 BytesWritten=Scribble5980
3 Delta=Scribble6010
3 ItemName=Scribble6040
3 ItemNumber=Scribble6070
3 ItemPerCent=Scribble6100
3 ItemPosition=Scribble6130
3 ItemSize=Scribble6160
3 Order=Scribble6190
3 TotalCount=Scribble6220
3 TotalPerCent=Scribble6250
3 TotalPosition=Scribble6280
3 TotalSize=Scribble6310
1 TZMDirEntry class
2 TZMDirEntry class Reference=Scribble6340
2 Properties
3 CompressedSize=Scribble6370
3 CompressionMethod=Scribble6400
3 CRC32=Scribble6430
3 DateStamp=Scribble6460
3 DateTime=Scribble6490
3 Encoded=Scribble6520
3 Encrypted=Scribble6550
3 ExtFileAttrib=Scribble6580
3 ExtraData=Scribble6610
3 ExtraField=Scribble6640
3 ExtraFieldLength=Scribble6670
3 FileComment=Scribble6700
3 FileCommentLen=Scribble6730
3 FileName=Scribble6760
3 FileNameLength=Scribble6790
3 Flag=Scribble6820
3 HeaderName=Scribble6850
3 IntFileAttrib=Scribble6880
3 IsDirOnly=Scribble6903
3 RelOffLocalHdr=Scribble6910
3 StartOnDisk=Scribble6940
3 StatusBits=Scribble6970
3 UncompressedSize=Scribble7000
3 VersionMadeBy=Scribble7030
3 VersionNeeded=Scribble7060
1 TZMDirRec component
2 TZipDirRec component Reference=Scribble7090
2 Methods
3 ChangeAttrs=Scribble7120
3 ChangeComment=Scribble7150
3 ChangeData=Scribble7180
3 ChangeDate=Scribble7210
3 ChangeEncoding=Scribble7240
3 ChangeName=Scribble7270
3 ChangeStamp=Scribble7300
1 Additional Units
2 Utility functions
3 AbsErr function=Scribble5520
3 CalcCRC32 function=Scribble5530
3 CanHash function=Scribble5540
3 CheckSFXType function=Scribble5550
3 DelimitPath function=Scribble5560
3 DirExists function=Scribble5570
3 DiskAvailable function=Scribble5580
3 EraseFile function=Scribble5590
3 ExeSize function=Scribble5600
3 ExeVers function=Scribble5610
3 ExeVersion function=Scribble5620
3 ExtractNameOfFile function=Scribble5630
3 File_Size function=Scribble5640
3 FileDateToLocalDateTime function=Scribble5650
3 FileSeek64 function=Scribble5660
3 ForceDirectory function=Scribble5670
3 GetVolumeLabel function=Scribble5680
3 HasWild function=Scribble5690
3 Hi64 function=Scribble5700
3 IsFolder function=Scribble5710
3 IsSameFile function=Scribble5720
3 IsWild function=Scribble5730
3 IsWinXP function=Scribble5740
3 LastPos function=Scribble5750
3 Lo64 function=Scribble5760
3 NameIsBad function=Scribble5770
3 OEMToStr function=Scribble5800
3 OpenResStream function=Scribble5820
3 PathConcat function=Scribble5830
3 QueryZip function=Scribble5840
3 SetSlash function=Scribble5870
3 StrHasExt function=Scribble5880
3 StrToOEM function=Scribble5890
3  VersStr function=Scribble5910
3 WinVersion function=Scribble5920
3 File_Close procedure=Scribble5930
2 UTF8 functions
3 AnsiIsSafe function=Scribble7620
3 AsUTF8Str function=Scribble7630
3 PUTF8ToSafe function=Scribble7640
3 PUTF8ToStr function=Scribble7650
3 PUTF8ToWideStr function=Scribble7660
3 PWideToUTF8 function=Scribble7670
3 StrToUTF8 function=Scribble7680
3 StrToUTFEx function=Scribble7690
3 StrToWideEx function=Scribble7700
3 UTF8IsSafe function=Scribble7710
3 IsUTF8Trail function=Scribble7720
3 UTF8SeqLen function=Scribble7730
3 ValidUTF8 function=Scribble7740
3 WideIsSafe function=Scribble7750
3 WideToSafe function=Scribble7760
7
*InternetLink
16711680
Courier New
0
10
1
....
0
0
0
0
0
0
*ParagraphTitle
-16777208
Arial
0
11
1
B...
0
0
0
0
0
0
*PopupLink
-16777208
Arial
0
8
1
....
0
0
0
0
0
0
*PopupTopicTitle
16711680
Arial
0
10
1
B...
0
0
0
0
0
0
*SourceCode
-16777208
Courier New
0
10
1
....
0
0
0
0
0
0
*TopicText
-16777208
Arial
0
10
1
....
0
0
0
0
0
0
*TopicTitle
16711680
Arial
0
16
1
B...
0
0
0
0
0
0
