unit UCommonTypes;

interface
uses
classes, SyncObjs, SysUtils;
{������ ������������ ��� ���������� ����� ����� ������, ������������ � ������
�������. (���� �� ���� ������ � ������������� ��������)}
type
TParamAccess = (acReadOnly, acReadWrite, acWriteOnly);
TNodeType = (ntKIP, ntChan, ntDT, ntDP, ntParam);
TDataType = (dtPointer, dtInt, dtDouble, dtString, dtBool);

PParamData = ^RParamData;
PInt = ^integer;
PDouble = ^double;
PBool = ^boolean;

TParametr = (prNone, prAddress, prLevel, prWater,
prTemp, prDens, prExf, prVolume, prWeight,
prTempPoint, prDensPoint, prTempCorrection,
prDensCorrection, prCleanTemp,
prPO, prSerial, prCopyright, prConfig, prDensTemp,
prTempId, prDensId, prHeight);

RParamPointer = record
param: TParametr;
ind: integer;
end;

RParamData = record
name: string;
parent: pointer;
data: pointer;
data_type: TDataType;
node_type: TNodeType;
access: TParamAccess;
param_pointer: RParamPointer;
end;

//��� ��������� ������ �������, � ��������� ������
TNotifyEventChannel = procedure(Sender: TObject; channel: integer) of Object;
//��� ��������� ������ �������, � ��������� ������ � ������ ������������ ���������
//n - ����� ������������ ���������� ��� ����������
TNotifyEventParam = procedure(Sender: TObject; channel: integer; n: integer) of Object;
//��� ��������� ������ �������, ��� �������� � ��������� ������ ����� com-����
//� ������� ������������ - ���������� ������
TNotifyData = procedure(Sender: TObject; datastring: ansistring) of Object;

//�������� ��������� ��������� �������
TSystemStates = (Connected, Disconnected, Transforming, QueringLevel, QueringWater,
QueringTemp, QueringDens, QueringExf, QueringVolume, QueringWeight,
QueringTempPoint, QueringDensPoint, QueringTempCorrection, SettingTempCorrection,
QueringDensCorrection, SettingDensCorrection, QueringCleanTemp,
QueringPO, QueringSerial, QueringCopyright, QueringConfig, QueringDensTemp,
QueringTempId, QueringDensId);




RSystemStateData = record
State: TSystemStates;
numsens: Integer;
numpoint: Integer;
numsubpoint: Integer;
param: Variant;
end;

PSystemStateData = ^RSystemStateData;

RParams = record //��������� ������������ ������
Ht: array [0..7] of integer; //������ ��������� ���������� (������� � �������), ��
Hp: array [0..2] of integer; //������ ��������� ���������� (������� � �������), ��
IdT: array [0..7] of integer; //Id ����������
IdP: array [0..2] of integer; //Id ����������
H0: integer; //�������� ��������� (�������� � ����������)
Ls: integer; //������ ������� � ��������� (��� ��������� 1 ������� 15.625 ��. ��� ��� 32.25 ��)
end;

RStatus = record   //��������� ������� �����������
Err: boolean;      //���� ���������� ���� �� ������  (����/���)
RhoErr: boolean;   //���� ������ � ������ ��������� (����/���)
TempErr: boolean;  //���� ������ � ������ ����������� (����/���)
LevErr: boolean;   //���� ������ � ������ ������ (����/���)
Rejim: boolean;    //����� ������ ����������� (false - ���������� true - ���������������� ����)
NalRho: boolean;   //������� ������ ���������
NalTemp: boolean;  //������� ������ �����������
NalLev: boolean;   //������� ������ ������
end;

procedure sortstrings(lst: TStrings);

implementation

function MyCompareStrings(st1, st2: string): integer;
begin
if length(st1) < length(st2) then result := -1
  else
if length(st1) > length(st2) then result := 1
  else
result := CompareStr(st1, st2);
end;

procedure sortstrings(lst: TStrings);
var
i: integer;
buf: string;
begin
i := 0;
while i < lst.Count - 1 do
  begin
  if MyCompareStrings(lst[i], lst[i + 1]) > 0 then
     begin
     buf := lst[i + 1];
     lst[i + 1] := lst[i];
     lst[i] := buf;
     sortstrings(lst);
     end else
     inc(i);
  end;
end;

end.
