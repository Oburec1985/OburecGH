{ *************************************************************************** }
{                                                                             }
{                                                                             }
{                                                                             }
{ ������ fbTypes - �������� ���������� ����� � �������� ��� ���������� fbUtils}
{ (c) 2012 ������� ������� ���������                                          }
{ ��������� ����������: 30.04.2012                                            }
{ �������������� �� D7, D2007, D2010, D-XE2                                   }
{ ����� �����: http://loginovprojects.ru/                                     }
{ e-mail: loginov_d@inbox.ru                                                  }
{                                                                             }
{ *************************************************************************** }

unit fbTypes;

interface

uses
  SysUtils, Classes, IBDatabase;

type
  PIBTransaction = ^TIBTransaction;

  { ���� ����������. ����������� ������ �������� ����� ������������ ����
    ����������. ���� ����� ������� ������������ trDef (������������� trRCRW).
    ��� ���������� ������� ������������� ������������ trSSRW, ��������� �������������,
    ��� � ����� �� ������� ������� ����� ������, ������� ����� ��������� � ��
    ����� ������ ����������. ��� ������������� �� ������ �������� ��������������
    ���� ����������. }
  TTransactionType = (
    trNone,  // ���������� �����������
    trDef,   // "�������" ����������, �� ��, ��� � trRCRW
    trRCRO,  // READ COMMITED READ ONLY
    trRCRW,  // READ COMMITED READ WRITE (NO WAIT)
    trRCRWW, // READ COMMITED READ WRITE, WAIT
    trSSRW); // SNAP SHOT READ WRITE

  {callback-��������� ��� ���������� ��������� ��������������/�������������� ��}
  TBackupRestoreProgressProc = procedure(ALastMsg: string; var Stop: Boolean) of object;

  {����� �������������� �� Firebird}
  TFBBackupOption = (IgnoreChecksums, IgnoreLimbo, MetadataOnly, NoGarbageCollection,
    OldMetadataDesc, NonTransportable, ConvertExtTables);
  TFBBackupOptions = set of TFBBackupOption;

  {����� �������������� �� Firebird}
  TFBRestoreOption = (DeactivateIndexes, NoShadow, NoValidityCheck, OneRelationAtATime,
    Replace, CreateNewDB, UseAllSpace, ValidationCheck);
  TFBRestoreOptions = set of TFBRestoreOption;

  TFBConnectionParams = record
    cpServerName: string; // ��� �������, �� ������� �������� ���� Firebird (��� ��� IP-�����)
    cpPort: Integer;      // ����, �� ������� ��������� ���� Firebird. �� ��������� = 3050
    cpDataBase: string;   // ������ ��� ����� �� (������������ ���������� ����������) ��� ��� �����
    cpUserName: string;   // ��� ������������ ��� ����������� � ��. �� ��������� =  SYSDBA
    cpPassword: string;   // ������ ��� ����������� � ��. �� ��������� =  masterkey
    cpCharSet: string;    // ������� ��������, ������������ ��� ����������� � ��.
                          // ������������� ��������� �� �� ����� ��������, � �������
                          // ������� ���� ������� ���� ������. ������: WIN1251
  end;

  {��������� ��� ������ fbUtilsDBStruct.pas}
  TFBNotNull = (CanNull, NotNull);                     // ���������, ������������, �������� �� NOT NULL ��� ���
  TFBSorting = (Ascending, Descending);                // ���������� ��� ��������: �� �����������, �� ��������
  TFBTriggerEventTime = (trBefore, trAfter);           // ������ ������������ ��������: �� ����������� / ����� �����������
  TFBTriggerEvent = (trInsert, trUpdate, trDelete);    // �������, �� ������� ����������� �������
  TFBTriggerEvents = set of TFBTriggerEvent;           // ��������� �������, �� ������� ������ ����������� �������
  TFBTriggerState = (trsNone, trsActive, trsInactive); // ��������� ��������: ����������� / �������� / ����������

  { ������� ��� ������ � ���. ���������� � TLDSLogger }
  TFBLogEvent = (tlpNone, tlpInformation, tlpError, tlpCriticalError,
                 tlpWarning, tlpEvent, tlpDebug, tlpOther);

  { callback-��������� ��� ������������ ������� }
  TFBLogEventsProc = procedure(Msg: string; LogEvent: TFBLogEvent);

const
  FBDefDB  = 'Default Database Profile'; // ��� ������� ��� ���� ������ �� ���������
  FBDefServer   = 'LOCALHOST'; // ������ �� ���������
  FBLocalServer = '';          // ��� LOCAL-����������� ��� ������� �� �����������
  FBDefPort     =  3050;       // ���� �� ���������
  FBLocalPort   = 0;           // ��� LOCAL-����������� ���� �� �����������
  FBDefUser     = 'SYSDBA';    // ��� ������������ Firebird �� ���������
  FBDefPassword = 'masterkey'; // ������ ������������ Firebird �� ���������

  FBTrustUser   = '';          // ��� ������������ ��� ������������� ���������� Windows
  FBTrustPassword = '';

  FBDefCharSet  = '';          // ��������� �� ��������� (�� ��������� - �� ������)
  FBRusCharSet  = 'WIN1251';   // ��������� ��� ������� ������� ��������
  FBDefPageSize = 8192;        // ������ �������� �� �� ���������

  FBDefParamCheck = True;      // �� ��������� �������� ���������� - �������� (��� ���������� ����� �� ��������)

  FBPoolConnectionMaxTime = 60; // ������������ ����� ����� �������������� ����������� � ����, ���

  FBDefBackupOptions: TFBBackupOptions = [];              // ����� �������������� �� �� ���������
  FBDefRestoreOptions: TFBRestoreOptions = [CreateNewDB]; // ����� �������������� �� �� ���������

  {��������� ��� ������ fbUtilsIniFiles}
  FBIniTableConfigParams = 'CONFIGPARAMS'; // ������� � ���������������� �����������
  FBIniFieldFileName     = 'FILENAME';     // ��� INI-����� ����� (�� ��������� - CONF)
  FBIniDefFileName       = 'CONF';         // ��� ����� �� ���������
  FBIniFieldComputerName = 'COMPUTERNAME'; // ��� ����������, �� ������� ������ ���������� ��������
  FBIniFieldUserName     = 'USERNAME';     // ��� ������������, ��� �������� ������������ ������ ��������
  FBIniFieldSectionName  = 'SECTIONNAME';  // ������������ ������ (���������� ���-������)
  FBIniDefSection        = 'PARAMS';       // �������� ��� ���� "������������ ������" �� ���������

  FBIniFieldParamName    = 'PARAMNAME';    // ������������ ���������
  FBIniFieldParamValue   = 'PARAMVALUE';   // �������� ���������
  FBIniFieldParamBlob    = 'PARAMBLOB';    // BLOB-�������� ��������� (��� ������� �������� ��������)
  FBIniFieldParamBlobHash = 'PARAMBLOBHASH'; // ��������� ���� ��� �������� ���� ��������� ������� (hash1$hash2)
  FBIniFieldModifyDate   = 'MODIFYDATE';   // ���� � ����� ��������� ������
  FBIniFieldModifyUser   = 'MODIFYUSER';   // ��� ������������, ������� ���� ���������
  FBIniCheckBlobHash     = True;           // ����������, ������� �� ��������� ��� ��� BLOB-�����



var
  { ��������� �������������� ����/������� � ������������ ����� }
  FBFormatSettings: TFormatSettings;
  TransactionParams: array[TTransactionType] of string =
    ('',
     'read_committed'#13#10'rec_version'#13#10'nowait',  // READ COMMITED READ WRITE (NO WAIT)
     'read_committed'#13#10'rec_version'#13#10'nowait'#13#10'read', // READ COMMITED READ ONLY
     'read_committed'#13#10'rec_version'#13#10'nowait',  // READ COMMITED READ WRITE (NO WAIT)
     'read_committed'#13#10'rec_version'#13#10'wait',    // READ COMMITED READ WRITE, WAIT
     'concurrency'#13#10'nowait');                       // SNAP SHOT READ WRITE

implementation

procedure FBUpdateFormatSettings;
begin
  GetLocaleFormatSettings(0, FBFormatSettings);
  FBFormatSettings.LongDateFormat := 'yyyy/mm/dd';
  FBFormatSettings.ShortDateFormat := 'yyyy/mm/dd';
  FBFormatSettings.LongTimeFormat := 'hh:nn:ss.zzz';
  FBFormatSettings.ShortTimeFormat := 'hh:nn:ss.zzz';
  FBFormatSettings.DateSeparator := '-';
  FBFormatSettings.TimeSeparator := ':';
  FBFormatSettings.DecimalSeparator := '.';
end;

initialization
  FBUpdateFormatSettings;
finalization

end.
