{**************************************************************************************************}
{                                                                                                  }
{ Project JEDI Code Library (JCL)                                                                  }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is JclContainerKnownMaps.pas.                                                  }
{                                                                                                  }
{ The Initial Developer of the Original Code is Florent Ouchet                                     }
{         <outchy att users dott sourceforge dott net>                                             }
{ Portions created by Florent Ouchet are Copyright (C) of Florent Ouchet. All rights reserved.     }
{                                                                                                  }
{ Contributors:                                                                                    }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date:: 2010-08-09 17:10:10 +0200 (lun., 09 août 2010)                         $ }
{ Revision:      $Rev:: 3291                                                                     $ }
{ Author:        $Author:: outchy                                                                $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclContainerKnownMaps;

interface

{$I jcl.inc}

uses
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  JclContainerTypes,
  JclContainerKnownTypes;

const
  IInterfaceIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfIntfMap',
        {maMapInterfaceGUID} '{01D05399-4A05-4F3E-92F4-0C236BE77019}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclIntfIntfSortedMap',
        {maSortedMapInterfaceGUID} '{265A6EB2-4BB3-459F-8813-360FD32A4971}',
        {maMapAncestorClassName} 'TJclIntfAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfIntfBucket',
        {maHashMapClassName} 'TJclIntfIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfIntfSortedEntry',
        {maSortedMapClassName} 'TJclIntfIntfSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @IInterfaceKnownType);

  AnsiStringIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclAnsiStrIntfMap',
        {maMapInterfaceGUID} '{A4788A96-281A-4924-AA24-03776DDAAD8A}',
        {maMapInterfaceAncestorName} 'IJclAnsiStrContainer',
        {maSortedMapInterfaceName} 'IJclAnsiStrIntfSortedMap',
        {maSortedMapInterfaceGUID} '{706D1C91-5416-4FDC-B6B1-F4C1E8CFCD38}',
        {maMapAncestorClassName} 'TJclAnsiStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclAnsiStrIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclAnsiStrIntfBucket',
        {maHashMapClassName} 'TJclAnsiStrIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclAnsiStrIntfSortedEntry',
        {maSortedMapClassName} 'TJclAnsiStrIntfSortedMap' );
      KeyAttributes: @AnsiStringKnownType;
      ValueAttributes: @IInterfaceKnownType);

  WideStringIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclWideStrIntfMap',
        {maMapInterfaceGUID} '{C959AB76-9CF0-4C2C-A2C6-8A1846563FAF}',
        {maMapInterfaceAncestorName} 'IJclWideStrContainer',
        {maSortedMapInterfaceName} 'IJclWideStrIntfSortedMap',
        {maSortedMapInterfaceGUID} '{299FDCFD-2DB7-4D64-BF18-EE3668316430}',
        {maMapAncestorClassName} 'TJclWideStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclWideStrIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclWideStrIntfBucket',
        {maHashMapClassName} 'TJclWideStrIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclWideStrIntfSortedEntry',
        {maSortedMapClassName} 'TJclWideStrIntfSortedMap' );
      KeyAttributes: @WideStringKnownType;
      ValueAttributes: @IInterfaceKnownType);

  UnicodeStringIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclUnicodeStrIntfMap',
        {maMapInterfaceGUID} '{C83D4F5E-8E66-41E9-83F6-338B44F24BE6}',
        {maMapInterfaceAncestorName} 'IJclUnicodeStrContainer',
        {maSortedMapInterfaceName} 'IJclUnicodeStrIntfSortedMap',
        {maSortedMapInterfaceGUID} '{25FDE916-730D-449A-BA29-852D8A0470B6}',
        {maMapAncestorClassName} 'TJclUnicodeStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclUnicodeStrIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclUnicodeStrIntfBucket',
        {maHashMapClassName} 'TJclUnicodeStrIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclUnicodeStrIntfSortedEntry',
        {maSortedMapClassName} 'TJclUnicodeStrIntfSortedMap' );
      KeyAttributes: @UnicodeStringKnownType;
      ValueAttributes: @IInterfaceKnownType);

  StringIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclStrIntfMap',
        {maMapInterfaceGUID} '',
        {maMapInterfaceAncestorName} 'IJclStrContainer',
        {maSortedMapInterfaceName} 'IJclStrIntfSortedMap',
        {maSortedMapInterfaceGUID} '',
        {maMapAncestorClassName} 'TJclStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclStrIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclStrIntfBucket',
        {maHashMapClassName} 'TJclStrIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclStrIntfSortedEntry',
        {maSortedMapClassName} 'TJclStrIntfSortedMap' );
      KeyAttributes: @StringKnownType;
      ValueAttributes: @IInterfaceKnownType);

  IInterfaceAnsiStringKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfAnsiStrMap',
        {maMapInterfaceGUID} '{B10E324A-1D98-42FF-B9B4-7F99044591B2}',
        {maMapInterfaceAncestorName} 'IJclAnsiStrContainer',
        {maSortedMapInterfaceName} 'IJclIntfAnsiStrSortedMap',
        {maSortedMapInterfaceGUID} '{96E6AC5E-8C40-4795-9C8A-CFD098B58680}',
        {maMapAncestorClassName} 'TJclAnsiStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfAnsiStrHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfAnsiStrBucket',
        {maHashMapClassName} 'TJclIntfAnsiStrHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfAnsiStrSortedEntry',
        {maSortedMapClassName} 'TJclIntfAnsiStrSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @AnsiStringKnownType);

  IInterfaceWideStringKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfWideStrMap',
        {maMapInterfaceGUID} '{D9FD7887-B840-4636-8A8F-E586663E332C}',
        {maMapInterfaceAncestorName} 'IJclWideStrContainer',
        {maSortedMapInterfaceName} 'IJclIntfWideStrSortedMap',
        {maSortedMapInterfaceGUID} '{FBE3AD2E-2781-4DC0-9E80-027027380E21}',
        {maMapAncestorClassName} 'TJclWideStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfWideStrHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfWideStrBucket',
        {maHashMapClassName} 'TJclIntfWideStrHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfWideStrSortedEntry',
        {maSortedMapClassName} 'TJclIntfWideStrSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @WideStringKnownType);

  IInterfaceUnicodeStringKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfUnicodeStrMap',
        {maMapInterfaceGUID} '{40F8B873-B763-4A3C-8EC4-31DB3404BF73}',
        {maMapInterfaceAncestorName} 'IJclUnicodeStrContainer',
        {maSortedMapInterfaceName} 'IJclIntfUnicodeStrSortedMap',
        {maSortedMapInterfaceGUID} '{B0B0CB9B-268B-40D2-94A8-0B8B5BE2E1AC}',
        {maMapAncestorClassName} 'TJclUnicodeStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfUnicodeStrHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfUnicodeStrBucket',
        {maHashMapClassName} 'TJclIntfUnicodeStrHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfUnicodeStrSortedEntry',
        {maSortedMapClassName} 'TJclIntfUnicodeStrSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @UnicodeStringKnownType);

  IInterfaceStringKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfStrMap',
        {maMapInterfaceGUID} '',
        {maMapInterfaceAncestorName} 'IJclStrContainer',
        {maSortedMapInterfaceName} 'IJclIntfStrSortedMap',
        {maSortedMapInterfaceGUID} '',
        {maMapAncestorClassName} 'TJclStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfStrHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfStrBucket',
        {maHashMapClassName} 'TJclIntfStrHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfStrSortedEntry',
        {maSortedMapClassName} 'TJclIntfStrSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @StringKnownType);

  AnsiStringAnsiStringKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclAnsiStrAnsiStrMap',
        {maMapInterfaceGUID} '{A4788A96-281A-4924-AA24-03776DDAAD8A}',
        {maMapInterfaceAncestorName} 'IJclAnsiStrContainer',
        {maSortedMapInterfaceName} 'IJclAnsiStrAnsiStrSortedMap',
        {maSortedMapInterfaceGUID} '{4F457799-5D03-413D-A46C-067DC4200CC3}',
        {maMapAncestorClassName} 'TJclAnsiStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclAnsiStrAnsiStrHashEntry',
        {maHashMapBucketTypeName} 'TJclAnsiStrAnsiStrBucket',
        {maHashMapClassName} 'TJclAnsiStrAnsiStrHashMap',
        {maSortedMapEntryTypeName} 'TJclAnsiStrAnsiStrSortedEntry',
        {maSortedMapClassName} 'TJclAnsiStrAnsiStrSortedMap' );
      KeyAttributes: @AnsiStringKnownType;
      ValueAttributes: @AnsiStringKnownType);

  WideStringWideStringKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclWideStrWideStrMap',
        {maMapInterfaceGUID} '{8E8D2735-C4FB-4F00-8802-B2102BCE3644}',
        {maMapInterfaceAncestorName} 'IJclWideStrContainer',
        {maSortedMapInterfaceName} 'IJclWideStrWideStrSortedMap',
        {maSortedMapInterfaceGUID} '{3B0757B2-2290-4AFA-880D-F9BA600E501E}',
        {maMapAncestorClassName} 'TJclWideStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclWideStrWideStrHashEntry',
        {maHashMapBucketTypeName} 'TJclWideStrWideStrBucket',
        {maHashMapClassName} 'TJclWideStrWideStrHashMap',
        {maSortedMapEntryTypeName} 'TJclWideStrWideStrSortedEntry',
        {maSortedMapClassName} 'TJclWideStrWideStrSortedMap' );
      KeyAttributes: @WideStringKnownType;
      ValueAttributes: @WideStringKnownType);

  UnicodeStringUnicodeStringKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclUnicodeStrUnicodeStrMap',
        {maMapInterfaceGUID} '{557E1CBD-06AC-41C2-BAED-253709CBD0AE}',
        {maMapInterfaceAncestorName} 'IJclUnicodeStrContainer',
        {maSortedMapInterfaceName} 'IJclUnicodeStrUnicodeStrSortedMap',
        {maSortedMapInterfaceGUID} '{D8EACC5D-B31E-47A8-9CC9-32B15A79CACA}',
        {maMapAncestorClassName} 'TJclUnicodeStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclUnicodeStrUnicodeStrHashEntry',
        {maHashMapBucketTypeName} 'TJclUnicodeStrUnicodeStrBucket',
        {maHashMapClassName} 'TJclUnicodeStrUnicodeStrHashMap',
        {maSortedMapEntryTypeName} 'TJclUnicodeStrUnicodeStrSortedEntry',
        {maSortedMapClassName} 'TJclUnicodeStrUnicodeStrSortedMap' );
      KeyAttributes: @UnicodeStringKnownType;
      ValueAttributes: @UnicodeStringKnownType);

  StringStringKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclStrStrMap',
        {maMapInterfaceGUID} '',
        {maMapInterfaceAncestorName} 'IJclStrContainer',
        {maSortedMapInterfaceName} 'IJclStrStrSortedMap',
        {maSortedMapInterfaceGUID} '',
        {maMapAncestorClassName} 'TJclStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclStrStrHashEntry',
        {maHashMapBucketTypeName} 'TJclStrStrBucket',
        {maHashMapClassName} 'TJclStrStrHashMap',
        {maSortedMapEntryTypeName} 'TJclStrStrSortedEntry',
        {maSortedMapClassName} 'TJclStrStrSortedMap' );
      KeyAttributes: @StringKnownType;
      ValueAttributes: @StringKnownType);

  SingleIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclSingleIntfMap',
        {maMapInterfaceGUID} '{5F5E9E8B-E648-450B-B6C0-0EC65CC2D0BA}',
        {maMapInterfaceAncestorName} 'IJclSingleContainer',
        {maSortedMapInterfaceName} 'IJclSingleIntfSortedMap',
        {maSortedMapInterfaceGUID} '{83D57068-7B8E-453E-B35B-2AB4B594A7A9}',
        {maMapAncestorClassName} 'TJclSingleAbstractContainer',
        {maHashMapEntryTypeName} 'TJclSingleIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclSingleIntfBucket',
        {maHashMapClassName} 'TJclSingleIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclSingleIntfSortedEntry',
        {maSortedMapClassName} 'TJclSingleIntfSortedMap' );
      KeyAttributes: @SingleKnownType;
      ValueAttributes: @IInterfaceKnownType);

  IInterfaceSingleKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfSingleMap',
        {maMapInterfaceGUID} '{234D1618-FB0E-46F5-A70D-5106163A90F7}',
        {maMapInterfaceAncestorName} 'IJclSingleContainer',
        {maSortedMapInterfaceName} 'IJclIntfSingleSortedMap',
        {maSortedMapInterfaceGUID} '{B07FA192-3466-4F2A-BBF0-2DC0100B08A8}',
        {maMapAncestorClassName} 'TJclSingleAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfSingleHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfSingleBucket',
        {maHashMapClassName} 'TJclIntfSingleHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfSingleSortedEntry',
        {maSortedMapClassName} 'TJclIntfSingleSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @SingleKnownType);

  SingleSingleKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclSingleSingleMap',
        {maMapInterfaceGUID} '{AEB0008F-F3CF-4055-A7F3-A330D312F03F}',
        {maMapInterfaceAncestorName} 'IJclSingleContainer',
        {maSortedMapInterfaceName} 'IJclSingleSingleSortedMap',
        {maSortedMapInterfaceGUID} '{7C6EA0B4-959D-44D5-915F-99DFC1753B00}',
        {maMapAncestorClassName} 'TJclSingleAbstractContainer',
        {maHashMapEntryTypeName} 'TJclSingleSingleHashEntry',
        {maHashMapBucketTypeName} 'TJclSingleSingleBucket',
        {maHashMapClassName} 'TJclSingleSingleHashMap',
        {maSortedMapEntryTypeName} 'TJclSingleSingleSortedEntry',
        {maSortedMapClassName} 'TJclSingleSingleSortedMap' );
      KeyAttributes: @SingleKnownType;
      ValueAttributes: @SingleKnownType);

  DoubleIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclDoubleIntfMap',
        {maMapInterfaceGUID} '{08968FFB-36C6-4FBA-BC09-3DCA2B5D7A50}',
        {maMapInterfaceAncestorName} 'IJclDoubleContainer',
        {maSortedMapInterfaceName} 'IJclDoubleIntfSortedMap',
        {maSortedMapInterfaceGUID} '{F36C5F4F-4F8C-4943-AA35-41623D3C21E9}',
        {maMapAncestorClassName} 'TJclDoubleAbstractContainer',
        {maHashMapEntryTypeName} 'TJclDoubleIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclDoubleIntfBucket',
        {maHashMapClassName} 'TJclDoubleIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclDoubleIntfSortedEntry',
        {maSortedMapClassName} 'TJclDoubleIntfSortedMap' );
      KeyAttributes: @DoubleKnownType;
      ValueAttributes: @IInterfaceKnownType);

  IInterfaceDoubleKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfDoubleMap',
        {maMapInterfaceGUID} '{B23DAF6A-6DC5-4DDD-835C-CD4633DDA010}',
        {maMapInterfaceAncestorName} 'IJclDoubleContainer',
        {maSortedMapInterfaceName} 'IJclIntfDoubleSortedMap',
        {maSortedMapInterfaceGUID} '{0F16ADAE-F499-4857-B5EA-6F3CC9009DBA}',
        {maMapAncestorClassName} 'TJclDoubleAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfDoubleHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfDoubleBucket',
        {maHashMapClassName} 'TJclIntfDoubleHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfDoubleSortedEntry',
        {maSortedMapClassName} 'TJclIntfDoubleSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @DoubleKnownType);

  DoubleDoubleKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclDoubleDoubleMap',
        {maMapInterfaceGUID} '{329A03B8-0B6B-4FE3-87C5-4B63447A5FFD}',
        {maMapInterfaceAncestorName} 'IJclDoubleContainer',
        {maSortedMapInterfaceName} 'IJclDoubleDoubleSortedMap',
        {maSortedMapInterfaceGUID} '{855C858B-74CF-4338-872B-AF88A02DB537}',
        {maMapAncestorClassName} 'TJclDoubleAbstractContainer',
        {maHashMapEntryTypeName} 'TJclDoubleDoubleHashEntry',
        {maHashMapBucketTypeName} 'TJclDoubleDoubleBucket',
        {maHashMapClassName} 'TJclDoubleDoubleHashMap',
        {maSortedMapEntryTypeName} 'TJclDoubleDoubleSortedEntry',
        {maSortedMapClassName} 'TJclDoubleDoubleSortedMap' );
      KeyAttributes: @DoubleKnownType;
      ValueAttributes: @DoubleKnownType);

  ExtendedIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclExtendedIntfMap',
        {maMapInterfaceGUID} '{7C0731E0-C9AB-4378-B1B0-8CE3DD60AD41}',
        {maMapInterfaceAncestorName} 'IJclExtendedContainer',
        {maSortedMapInterfaceName} 'IJclExtendedIntfSortedMap',
        {maSortedMapInterfaceGUID} '{A30B8835-A319-4776-9A11-D1EEF60B9C26}',
        {maMapAncestorClassName} 'TJclExtendedAbstractContainer',
        {maHashMapEntryTypeName} 'TJclExtendedIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclExtendedIntfBucket',
        {maHashMapClassName} 'TJclExtendedIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclExtendedIntfSortedEntry',
        {maSortedMapClassName} 'TJclExtendedIntfSortedMap' );
      KeyAttributes: @ExtendedKnownType;
      ValueAttributes: @IInterfaceKnownType);

  IInterfaceExtendedKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfExtendedMap',
        {maMapInterfaceGUID} '{479FCE5A-2D8A-44EE-96BC-E8DA3187DBD8}',
        {maMapInterfaceAncestorName} 'IJclExtendedContainer',
        {maSortedMapInterfaceName} 'IJclIntfExtendedSortedMap',
        {maSortedMapInterfaceGUID} '{3493D6C4-3075-48B6-8E99-CB0000D3978C}',
        {maMapAncestorClassName} 'TJclExtendedAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfExtendedHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfExtendedBucket',
        {maHashMapClassName} 'TJclIntfExtendedHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfExtendedSortedEntry',
        {maSortedMapClassName} 'TJclIntfExtendedSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @ExtendedKnownType);

  ExtendedExtendedKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclExtendedExtendedMap',
        {maMapInterfaceGUID} '{962C2B09-8CF5-44E8-A21A-4A7DAFB72A11}',
        {maMapInterfaceAncestorName} 'IJclExtendedContainer',
        {maSortedMapInterfaceName} 'IJclExtendedExtendedSortedMap',
        {maSortedMapInterfaceGUID} '{8CAA505C-D9BB-47E7-92EC-6043DC4AF42C}',
        {maMapAncestorClassName} 'TJclExtendedAbstractContainer',
        {maHashMapEntryTypeName} 'TJclExtendedExtendedHashEntry',
        {maHashMapBucketTypeName} 'TJclExtendedExtendedBucket',
        {maHashMapClassName} 'TJclExtendedExtendedHashMap',
        {maSortedMapEntryTypeName} 'TJclExtendedExtendedSortedEntry',
        {maSortedMapClassName} 'TJclExtendedExtendedSortedMap' );
      KeyAttributes: @ExtendedKnownType;
      ValueAttributes: @ExtendedKnownType);

  FloatIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclFloatIntfMap',
        {maMapInterfaceGUID} '',
        {maMapInterfaceAncestorName} 'IJclFloatContainer',
        {maSortedMapInterfaceName} 'IJclFloatIntfSortedMap',
        {maSortedMapInterfaceGUID} '',
        {maMapAncestorClassName} 'TJclFloatAbstractContainer',
        {maHashMapEntryTypeName} 'TJclFloatIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclFloatIntfBucket',
        {maHashMapClassName} 'TJclFloatIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclFloatIntfSortedEntry',
        {maSortedMapClassName} 'TJclFloatIntfSortedMap' );
      KeyAttributes: @FloatKnownType;
      ValueAttributes: @IInterfaceKnownType);

  IInterfaceFloatKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfFloatMap',
        {maMapInterfaceGUID} '',
        {maMapInterfaceAncestorName} 'IJclFloatContainer',
        {maSortedMapInterfaceName} 'IJclIntfFloatSortedMap',
        {maSortedMapInterfaceGUID} '',
        {maMapAncestorClassName} 'TJclFloatAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfFloatHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfFloatBucket',
        {maHashMapClassName} 'TJclIntfFloatHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfFloatSortedEntry',
        {maSortedMapClassName} 'TJclIntfFloatSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @FloatKnownType);

  FloatFloatKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclFloatFloatMap',
        {maMapInterfaceGUID} '',
        {maMapInterfaceAncestorName} 'IJclFloatContainer',
        {maSortedMapInterfaceName} 'IJclFloatFloatSortedMap',
        {maSortedMapInterfaceGUID} '{8CAA505C-D9BB-47E7-92EC-6043DC4AF42C}',
        {maMapAncestorClassName} 'TJclFloatAbstractContainer',
        {maHashMapEntryTypeName} 'TJclFloatFloatHashEntry',
        {maHashMapBucketTypeName} 'TJclFloatFloatBucket',
        {maHashMapClassName} 'TJclFloatFloatHashMap',
        {maSortedMapEntryTypeName} 'TJclFloatFloatSortedEntry',
        {maSortedMapClassName} 'TJclFloatFloatSortedMap' );
      KeyAttributes: @FloatKnownType;
      ValueAttributes: @FloatKnownType);

  IntegerIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntegerIntfMap',
        {maMapInterfaceGUID} '{E535FE65-AC88-49D3-BEF2-FB30D92C2FA6}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclIntegerIntfSortedMap',
        {maSortedMapInterfaceGUID} '{8B22802C-61F2-4DA5-B1E9-DBB7840E7996}',
        {maMapAncestorClassName} 'TJclIntegerAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntegerIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclIntegerIntfBucket',
        {maHashMapClassName} 'TJclIntegerIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclIntegerIntfSortedEntry',
        {maSortedMapClassName} 'TJclIntegerIntfSortedMap' );
      KeyAttributes: @IntegerKnownType;
      ValueAttributes: @IInterfaceKnownType);

  IInterfaceIntegerKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfIntegerMap',
        {maMapInterfaceGUID} '{E01DA012-BEE0-4259-8E30-0A7A1A87BED0}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclIntfIntegerSortedMap',
        {maSortedMapInterfaceGUID} '{8D3C9B7E-772D-409B-A58C-0CABFAFDEFF0}',
        {maMapAncestorClassName} 'TJclIntegerAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfIntegerHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfIntegerBucket',
        {maHashMapClassName} 'TJclIntfIntegerHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfIntegerSortedEntry',
        {maSortedMapClassName} 'TJclIntfIntegerSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @IntegerKnownType);

  IntegerIntegerKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntegerIntegerMap',
        {maMapInterfaceGUID} '{23A46BC0-DF8D-4BD2-89D2-4DACF1EC73A1}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclIntegerIntegerSortedMap',
        {maSortedMapInterfaceGUID} '{8A8BA17A-F468-469C-AF99-77D64C802F7A}',
        {maMapAncestorClassName} 'TJclIntegerAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntegerIntegerHashEntry',
        {maHashMapBucketTypeName} 'TJclIntegerIntegerBucket',
        {maHashMapClassName} 'TJclIntegerIntegerHashMap',
        {maSortedMapEntryTypeName} 'TJclIntegerIntegerSortedEntry',
        {maSortedMapClassName} 'TJclIntegerIntegerSortedMap' );
      KeyAttributes: @IntegerKnownType;
      ValueAttributes: @IntegerKnownType);

  CardinalIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclCardinalIntfMap',
        {maMapInterfaceGUID} '{80D39FB1-0D10-49CE-8AF3-1CD98A1D4F6C}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclCardinalIntfSortedMap',
        {maSortedMapInterfaceGUID} '{BAE97425-4F2E-461B-88DD-F83D27657AFA}',
        {maMapAncestorClassName} 'TJclCardinalAbstractContainer',
        {maHashMapEntryTypeName} 'TJclCardinalIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclCardinalIntfBucket',
        {maHashMapClassName} 'TJclCardinalIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclCardinalIntfSortedEntry',
        {maSortedMapClassName} 'TJclCardinalIntfSortedMap' );
      KeyAttributes: @CardinalKnownType;
      ValueAttributes: @IInterfaceKnownType);

  IInterfaceCardinalKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfCardinalMap',
        {maMapInterfaceGUID} '{E1A724AB-6BDA-45F0-AE21-5E7E789A751B}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclIntfCardinalSortedMap',
        {maSortedMapInterfaceGUID} '{BC66BACF-23AE-48C4-9573-EDC3B5110BE7}',
        {maMapAncestorClassName} 'TJclCardinalAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfCardinalHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfCardinalBucket',
        {maHashMapClassName} 'TJclIntfCardinalHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfCardinalSortedEntry',
        {maSortedMapClassName} 'TJclIntfCardinalSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @CardinalKnownType);

  CardinalCardinalKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclCardinalCardinalMap',
        {maMapInterfaceGUID} '{1CD3F54C-F92F-4AF4-82B2-0829C08AA83B}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclCardinalCardinalSortedMap',
        {maSortedMapInterfaceGUID} '{182ACDA4-7D74-4D29-BB5C-4C8189DA774E}',
        {maMapAncestorClassName} 'TJclCardinalAbstractContainer',
        {maHashMapEntryTypeName} 'TJclCardinalCardinalHashEntry',
        {maHashMapBucketTypeName} 'TJclCardinalCardinalBucket',
        {maHashMapClassName} 'TJclCardinalCardinalHashMap',
        {maSortedMapEntryTypeName} 'TJclCardinalCardinalSortedEntry',
        {maSortedMapClassName} 'TJclCardinalCardinalSortedMap' );
      KeyAttributes: @CardinalKnownType;
      ValueAttributes: @CardinalKnownType);

  Int64IInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclInt64IntfMap',
        {maMapInterfaceGUID} '{B64FB2D1-8D45-4367-B950-98D3D05AC6A0}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclInt64IntfSortedMap',
        {maSortedMapInterfaceGUID} '{24391756-FB02-4901-81E3-A37738B73DAD}',
        {maMapAncestorClassName} 'TJclInt64AbstractContainer',
        {maHashMapEntryTypeName} 'TJclInt64IntfHashEntry',
        {maHashMapBucketTypeName} 'TJclInt64IntfBucket',
        {maHashMapClassName} 'TJclInt64IntfHashMap',
        {maSortedMapEntryTypeName} 'TJclInt64IntfSortedEntry',
        {maSortedMapClassName} 'TJclInt64IntfSortedMap' );
      KeyAttributes: @Int64KnownType;
      ValueAttributes: @IInterfaceKnownType);

  IInterfaceInt64KnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfInt64Map',
        {maMapInterfaceGUID} '{9886BEE3-D15B-45D2-A3FB-4D3A0ADEC8AC}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclIntfInt64SortedMap',
        {maSortedMapInterfaceGUID} '{6E2AB647-59CC-4609-82E8-6AE75AED80CA}',
        {maMapAncestorClassName} 'TJclInt64AbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfInt64HashEntry',
        {maHashMapBucketTypeName} 'TJclIntfInt64Bucket',
        {maHashMapClassName} 'TJclIntfInt64HashMap',
        {maSortedMapEntryTypeName} 'TJclIntfInt64SortedEntry',
        {maSortedMapClassName} 'TJclIntfInt64SortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @Int64KnownType);

  Int64Int64KnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclInt64Int64Map',
        {maMapInterfaceGUID} '{EF2A2726-408A-4984-9971-DDC1B6EFC9F5}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclInt64Int64SortedMap',
        {maSortedMapInterfaceGUID} '{168581D2-9DD3-46D0-934E-EA0CCE5E3C0C}',
        {maMapAncestorClassName} 'TJclInt64AbstractContainer',
        {maHashMapEntryTypeName} 'TJclInt64Int64HashEntry',
        {maHashMapBucketTypeName} 'TJclInt64Int64Bucket',
        {maHashMapClassName} 'TJclInt64Int64HashMap',
        {maSortedMapEntryTypeName} 'TJclInt64Int64SortedEntry',
        {maSortedMapClassName} 'TJclInt64Int64SortedMap' );
      KeyAttributes: @Int64KnownType;
      ValueAttributes: @Int64KnownType);

  PointerIInterfaceKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclPtrIntfMap',
        {maMapInterfaceGUID} '{B7C48542-39A0-453F-8F03-8C8CFAB0DCCF}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclPtrIntfSortedMap',
        {maSortedMapInterfaceGUID} '{6D7B8042-3CBC-4C8F-98B5-69AFAA104532}',
        {maMapAncestorClassName} 'TJclPtrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclPtrIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclPtrIntfBucket',
        {maHashMapClassName} 'TJclPtrIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclPtrIntfSortedEntry',
        {maSortedMapClassName} 'TJclPtrIntfSortedMap' );
      KeyAttributes: @PointerKnownType;
      ValueAttributes: @IInterfaceKnownType);

  IInterfacePointerKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfPtrMap',
        {maMapInterfaceGUID} '{DA51D823-58DB-4D7C-9B8E-07E0FD560B57}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclIntfPtrSortedMap',
        {maSortedMapInterfaceGUID} '{B054BDA2-536F-4C16-B6BB-BB64FA0818B3}',
        {maMapAncestorClassName} 'TJclPtrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfPtrHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfPtrBucket',
        {maHashMapClassName} 'TJclIntfPtrHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfPtrSortedEntry',
        {maSortedMapClassName} 'TJclIntfPtrSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @PointerKnownType);

  PointerPointerKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclPtrPtrMap',
        {maMapInterfaceGUID} '{1200CB0F-A766-443F-9030-5A804C11B798}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclPtrPtrSortedMap',
        {maSortedMapInterfaceGUID} '{F1FAE922-0212-41D0-BB4E-76A8AB2CAB86}',
        {maMapAncestorClassName} 'TJclPtrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclPtrPtrHashEntry',
        {maHashMapBucketTypeName} 'TJclPtrPtrBucket',
        {maHashMapClassName} 'TJclPtrPtrHashMap',
        {maSortedMapEntryTypeName} 'TJclPtrPtrSortedEntry',
        {maSortedMapClassName} 'TJclPtrPtrSortedMap' );
      KeyAttributes: @PointerKnownType;
      ValueAttributes: @PointerKnownType);

  IInterfaceTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntfMap',
        {maMapInterfaceGUID} '{C70570C6-EDDB-47B4-9003-C637B486731D}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclIntfSortedMap',
        {maSortedMapInterfaceGUID} '{3CED1477-B958-4109-9BDA-7C84B9E063B2}',
        {maMapAncestorClassName} 'TJclIntfAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntfHashEntry',
        {maHashMapBucketTypeName} 'TJclIntfBucket',
        {maHashMapClassName} 'TJclIntfHashMap',
        {maSortedMapEntryTypeName} 'TJclIntfSortedEntry',
        {maSortedMapClassName} 'TJclIntfSortedMap' );
      KeyAttributes: @IInterfaceKnownType;
      ValueAttributes: @TObjectKnownType);

  AnsiStringTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclAnsiStrMap',
        {maMapInterfaceGUID} '{A7D0A882-6952-496D-A258-23D47DDCCBC4}',
        {maMapInterfaceAncestorName} 'IJclAnsiStrContainer',
        {maSortedMapInterfaceName} 'IJclAnsiStrSortedMap',
        {maSortedMapInterfaceGUID} '{573F98E3-EBCD-4F28-8F35-96A7366CBF47}',
        {maMapAncestorClassName} 'TJclAnsiStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclAnsiStrHashEntry',
        {maHashMapBucketTypeName} 'TJclAnsiStrBucket',
        {maHashMapClassName} 'TJclAnsiStrHashMap',
        {maSortedMapEntryTypeName} 'TJclAnsiStrSortedEntry',
        {maSortedMapClassName} 'TJclAnsiStrSortedMap' );
      KeyAttributes: @AnsiStringKnownType;
      ValueAttributes: @TObjectKnownType);

  WideStringTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclWideStrMap',
        {maMapInterfaceGUID} '{ACE8E6B4-5A56-4753-A2C6-BAE195A56B63}',
        {maMapInterfaceAncestorName} 'IJclWideStrContainer',
        {maSortedMapInterfaceName} 'IJclWideStrSortedMap',
        {maSortedMapInterfaceGUID} '{B3021EFC-DE25-4B4B-A896-ACE823CD5C01}',
        {maMapAncestorClassName} 'TJclWideStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclWideStrHashEntry',
        {maHashMapBucketTypeName} 'TJclWideStrBucket',
        {maHashMapClassName} 'TJclWideStrHashMap',
        {maSortedMapEntryTypeName} 'TJclWideStrSortedEntry',
        {maSortedMapClassName} 'TJclWideStrSortedMap' );
      KeyAttributes: @WideStringKnownType;
      ValueAttributes: @TObjectKnownType);

  UnicodeStringTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclUnicodeStrMap',
        {maMapInterfaceGUID} '{4328E033-9B92-40C6-873D-A6982CFC2B95}',
        {maMapInterfaceAncestorName} 'IJclUnicodeStrContainer',
        {maSortedMapInterfaceName} 'IJclUnicodeStrSortedMap',
        {maSortedMapInterfaceGUID} '{5510B8FC-3439-4211-8D1F-5EDD9A56D3E3}',
        {maMapAncestorClassName} 'TJclUnicodeStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclUnicodeStrHashEntry',
        {maHashMapBucketTypeName} 'TJclUnicodeStrBucket',
        {maHashMapClassName} 'TJclUnicodeStrHashMap',
        {maSortedMapEntryTypeName} 'TJclUnicodeStrSortedEntry',
        {maSortedMapClassName} 'TJclUnicodeStrSortedMap' );
      KeyAttributes: @UnicodeStringKnownType;
      ValueAttributes: @TObjectKnownType);

  StringTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclStrMap',
        {maMapInterfaceGUID} '',
        {maMapInterfaceAncestorName} 'IJclStrContainer',
        {maSortedMapInterfaceName} 'IJclStrSortedMap',
        {maSortedMapInterfaceGUID} '',
        {maMapAncestorClassName} 'TJclStrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclStrHashEntry',
        {maHashMapBucketTypeName} 'TJclStrBucket',
        {maHashMapClassName} 'TJclStrHashMap',
        {maSortedMapEntryTypeName} 'TJclStrSortedEntry',
        {maSortedMapClassName} 'TJclStrSortedMap' );
      KeyAttributes: @StringKnownType;
      ValueAttributes: @TObjectKnownType);

  SingleTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclSingleMap',
        {maMapInterfaceGUID} '{C501920A-F252-4F94-B142-1F05AE06C3D2}',
        {maMapInterfaceAncestorName} 'IJclSingleContainer',
        {maSortedMapInterfaceName} 'IJclSingleSortedMap',
        {maSortedMapInterfaceGUID} '{8C1A12BE-A7F2-4351-90B7-25DB0AAF5F94}',
        {maMapAncestorClassName} 'TJclSingleAbstractContainer',
        {maHashMapEntryTypeName} 'TJclSingleHashEntry',
        {maHashMapBucketTypeName} 'TJclSingleBucket',
        {maHashMapClassName} 'TJclSingleHashMap',
        {maSortedMapEntryTypeName} 'TJclSingleSortedEntry',
        {maSortedMapClassName} 'TJclSingleSortedMap' );
      KeyAttributes: @SingleKnownType;
      ValueAttributes: @TObjectKnownType);

  DoubleTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclDoubleMap',
        {maMapInterfaceGUID} '{B1B994AC-49C9-418B-814B-43BAD706F355}',
        {maMapInterfaceAncestorName} 'IJclDoubleContainer',
        {maSortedMapInterfaceName} 'IJclDoubleSortedMap',
        {maSortedMapInterfaceGUID} '{8018D66B-AA54-4016-84FC-3E780FFCC38B}',
        {maMapAncestorClassName} 'TJclDoubleAbstractContainer',
        {maHashMapEntryTypeName} 'TJclDoubleHashEntry',
        {maHashMapBucketTypeName} 'TJclDoubleBucket',
        {maHashMapClassName} 'TJclDoubleHashMap',
        {maSortedMapEntryTypeName} 'TJclDoubleSortedEntry',
        {maSortedMapClassName} 'TJclDoubleSortedMap' );
      KeyAttributes: @DoubleKnownType;
      ValueAttributes: @TObjectKnownType);

  ExtendedTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclExtendedMap',
        {maMapInterfaceGUID} '{3BCC8C87-A186-45E8-9B37-0B8E85120434}',
        {maMapInterfaceAncestorName} 'IJclExtendedContainer',
        {maSortedMapInterfaceName} 'IJclExtendedSortedMap',
        {maSortedMapInterfaceGUID} '{2B82C65A-B3EF-477D-BEC0-3D8620A226B1}',
        {maMapAncestorClassName} 'TJclExtendedAbstractContainer',
        {maHashMapEntryTypeName} 'TJclExtendedHashEntry',
        {maHashMapBucketTypeName} 'TJclExtendedBucket',
        {maHashMapClassName} 'TJclExtendedHashMap',
        {maSortedMapEntryTypeName} 'TJclExtendedSortedEntry',
        {maSortedMapClassName} 'TJclExtendedSortedMap' );
      KeyAttributes: @ExtendedKnownType;
      ValueAttributes: @TObjectKnownType);

  FloatTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclFloatMap',
        {maMapInterfaceGUID} '',
        {maMapInterfaceAncestorName} 'IJclFloatContainer',
        {maSortedMapInterfaceName} 'IJclFloatSortedMap',
        {maSortedMapInterfaceGUID} '',
        {maMapAncestorClassName} 'TJclFloatAbstractContainer',
        {maHashMapEntryTypeName} 'TJclFloatHashEntry',
        {maHashMapBucketTypeName} 'TJclFloatBucket',
        {maHashMapClassName} 'TJclFloatHashMap',
        {maSortedMapEntryTypeName} 'TJclFloatSortedEntry',
        {maSortedMapClassName} 'TJclFloatSortedMap' );
      KeyAttributes: @FloatKnownType;
      ValueAttributes: @TObjectKnownType);

  IntegerTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclIntegerMap',
        {maMapInterfaceGUID} '{D6FA5D64-A4AF-4419-9981-56BA79BF8770}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclIntegerSortedMap',
        {maSortedMapInterfaceGUID} '{DD7B4C5E-6D51-44CC-9328-B38396A7E1C9}',
        {maMapAncestorClassName} 'TJclIntegerAbstractContainer',
        {maHashMapEntryTypeName} 'TJclIntegerHashEntry',
        {maHashMapBucketTypeName} 'TJclIntegerBucket',
        {maHashMapClassName} 'TJclIntegerHashMap',
        {maSortedMapEntryTypeName} 'TJclIntegerSortedEntry',
        {maSortedMapClassName} 'TJclIntegerSortedMap' );
      KeyAttributes: @IntegerKnownType;
      ValueAttributes: @TObjectKnownType);

  CardinalTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclCardinalMap',
        {maMapInterfaceGUID} '{A2F92F4F-11CB-4DB2-932F-F10A14237126}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclCardinalSortedMap',
        {maSortedMapInterfaceGUID} '{4AEAF81F-D72E-4499-B10E-3D017F39915E}',
        {maMapAncestorClassName} 'TJclCardinalAbstractContainer',
        {maHashMapEntryTypeName} 'TJclCardinalHashEntry',
        {maHashMapBucketTypeName} 'TJclCardinalBucket',
        {maHashMapClassName} 'TJclCardinalHashMap',
        {maSortedMapEntryTypeName} 'TJclCardinalSortedEntry',
        {maSortedMapClassName} 'TJclCardinalSortedMap' );
      KeyAttributes: @CardinalKnownType;
      ValueAttributes: @TObjectKnownType);

  Int64TObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclInt64Map',
        {maMapInterfaceGUID} '{4C720CE0-7A7C-41D5-BFC1-8D58A47E648F}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclInt64SortedMap',
        {maSortedMapInterfaceGUID} '{06C03F90-7DE9-4043-AA56-AAE071D8BD50}',
        {maMapAncestorClassName} 'TJclInt64AbstractContainer',
        {maHashMapEntryTypeName} 'TJclInt64HashEntry',
        {maHashMapBucketTypeName} 'TJclInt64Bucket',
        {maHashMapClassName} 'TJclInt64HashMap',
        {maSortedMapEntryTypeName} 'TJclInt64SortedEntry',
        {maSortedMapClassName} 'TJclInt64SortedMap' );
      KeyAttributes: @Int64KnownType;
      ValueAttributes: @TObjectKnownType);

  PointerTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclPtrMap',
        {maMapInterfaceGUID} '{2FE029A9-026C-487D-8204-AD3A28BD2FA2}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclPtrSortedMap',
        {maSortedMapInterfaceGUID} '{578918DB-6A4A-4A9D-B44E-AE3E8FF70818}',
        {maMapAncestorClassName} 'TJclPtrAbstractContainer',
        {maHashMapEntryTypeName} 'TJclPtrHashEntry',
        {maHashMapBucketTypeName} 'TJclPtrBucket',
        {maHashMapClassName} 'TJclPtrHashMap',
        {maSortedMapEntryTypeName} 'TJclPtrSortedEntry',
        {maSortedMapClassName} 'TJclPtrSortedMap' );
      KeyAttributes: @PointerKnownType;
      ValueAttributes: @TObjectKnownType);

  TObjectTObjectKnownMap: TKnownMapAttributes =
    (MapAttributes:
      ( {maMapInterfaceName} 'IJclMap',
        {maMapInterfaceGUID} '{A7D0A882-6952-496D-A258-23D47DDCCBC4}',
        {maMapInterfaceAncestorName} 'IJclContainer',
        {maSortedMapInterfaceName} 'IJclSortedMap',
        {maSortedMapInterfaceGUID} '{F317A70F-7851-49C2-9DCF-092D8F4D4F98}',
        {maMapAncestorClassName} 'TJclAbstractContainerBase',
        {maHashMapEntryTypeName} 'TJclHashEntry',
        {maHashMapBucketTypeName} 'TJclBucket',
        {maHashMapClassName} 'TJclHashMap',
        {maSortedMapEntryTypeName} 'TJclSortedEntry',
        {maSortedMapClassName} 'TJclSortedMap' );
      KeyAttributes: @TObjectKnownType;
      ValueAttributes: @TObjectKnownType);

  KnownAllMaps: array[0..50] of PKnownMapAttributes =
    ( @IInterfaceIInterfaceKnownMap,
      @AnsiStringIInterfaceKnownMap,
      @IInterfaceAnsiStringKnownMap,
      @AnsiStringAnsiStringKnownMap,
      @WideStringIInterfaceKnownMap,
      @IInterfaceWideStringKnownMap,
      @WideStringWideStringKnownMap,
      @UnicodeStringIInterfaceKnownMap,
      @IInterfaceUnicodeStringKnownMap,
      @UnicodeStringUnicodeStringKnownMap,
      @StringIInterfaceKnownMap,
      @IInterfaceStringKnownMap,
      @StringStringKnownMap,
      @SingleIInterfaceKnownMap,
      @IInterfaceSingleKnownMap,
      @SingleSingleKnownMap,
      @DoubleIInterfaceKnownMap,
      @IInterfaceDoubleKnownMap,
      @DoubleDoubleKnownMap,
      @ExtendedIInterfaceKnownMap,
      @IInterfaceExtendedKnownMap,
      @ExtendedExtendedKnownMap,
      @FloatIInterfaceKnownMap,
      @IInterfaceFloatKnownMap,
      @FloatFloatKnownMap,
      @IntegerIInterfaceKnownMap,
      @IInterfaceIntegerKnownMap,
      @IntegerIntegerKnownMap,
      @CardinalIInterfaceKnownMap,
      @IInterfaceCardinalKnownMap,
      @CardinalCardinalKnownMap,
      @Int64IInterfaceKnownMap,
      @IInterfaceInt64KnownMap,
      @Int64Int64KnownMap,
      @PointerIInterfaceKnownMap,
      @IInterfacePointerKnownMap,
      @PointerPointerKnownMap,
      @IInterfaceTObjectKnownMap,
      @AnsiStringTObjectKnownMap,
      @WideStringTObjectKnownMap,
      @UnicodeStringTObjectKnownMap,
      @StringTObjectKnownMap,
      @SingleTObjectKnownMap,
      @DoubleTObjectKnownMap,
      @ExtendedTObjectKnownMap,
      @FloatTObjectKnownMap,
      @IntegerTObjectKnownMap,
      @CardinalTObjectKnownMap,
      @Int64TObjectKnownMap,
      @PointerTObjectKnownMap,
      @TObjectTObjectKnownMap );

  // same as previous, except without compiler magic types (string) and type aliases (float)
  KnownTrueMaps: array[0..42] of PKnownMapAttributes =
    ( @IInterfaceIInterfaceKnownMap,
      @AnsiStringIInterfaceKnownMap,
      @IInterfaceAnsiStringKnownMap,
      @AnsiStringAnsiStringKnownMap,
      @WideStringIInterfaceKnownMap,
      @IInterfaceWideStringKnownMap,
      @WideStringWideStringKnownMap,
      @UnicodeStringIInterfaceKnownMap,
      @IInterfaceUnicodeStringKnownMap,
      @UnicodeStringUnicodeStringKnownMap,
      @SingleIInterfaceKnownMap,
      @IInterfaceSingleKnownMap,
      @SingleSingleKnownMap,
      @DoubleIInterfaceKnownMap,
      @IInterfaceDoubleKnownMap,
      @DoubleDoubleKnownMap,
      @ExtendedIInterfaceKnownMap,
      @IInterfaceExtendedKnownMap,
      @ExtendedExtendedKnownMap,
      @IntegerIInterfaceKnownMap,
      @IInterfaceIntegerKnownMap,
      @IntegerIntegerKnownMap,
      @CardinalIInterfaceKnownMap,
      @IInterfaceCardinalKnownMap,
      @CardinalCardinalKnownMap,
      @Int64IInterfaceKnownMap,
      @IInterfaceInt64KnownMap,
      @Int64Int64KnownMap,
      @PointerIInterfaceKnownMap,
      @IInterfacePointerKnownMap,
      @PointerPointerKnownMap,
      @IInterfaceTObjectKnownMap,
      @AnsiStringTObjectKnownMap,
      @WideStringTObjectKnownMap,
      @UnicodeStringTObjectKnownMap,
      @SingleTObjectKnownMap,
      @DoubleTObjectKnownMap,
      @ExtendedTObjectKnownMap,
      @IntegerTObjectKnownMap,
      @CardinalTObjectKnownMap,
      @Int64TObjectKnownMap,
      @PointerTObjectKnownMap,
      @TObjectTObjectKnownMap );

function IsKnownMap(const KeyName, ValueName: string): PKnownMapAttributes;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL: https://jcl.svn.sourceforge.net:443/svnroot/jcl/tags/JCL-2.2-Build3970/jcl/devtools/jpp/Templates/JclContainerKnownMaps.pas $';
    Revision: '$Revision: 3291 $';
    Date: '$Date: 2010-08-09 17:10:10 +0200 (lun., 09 août 2010) $';
    LogPath: 'JCL\devtools\jpp\Templates';
    Extra: '';
    Data: nil
    );
{$ENDIF UNITVERSIONING}

implementation

uses
  SysUtils;

function IsKnownMap(const KeyName, ValueName: string): PKnownMapAttributes;
var
  I: Integer;
begin
  Result := nil;
  for I := Low(KnownAllMaps) to High(KnownAllMaps) do
    if SameText(KeyName, KnownAllMaps[I]^.KeyAttributes[taTypeName]) and
       SameText(ValueName, KnownAllMaps[I]^.ValueAttributes[taTypeName]) then
  begin
    Result := KnownAllMaps[I];
    Break;
  end;
end;

{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);

finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.
