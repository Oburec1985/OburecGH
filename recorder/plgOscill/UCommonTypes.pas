unit UCommonTypes;

interface
uses
classes, SyncObjs, SysUtils;
{Модуль предназначен для объявления общих типов данных, используемых в разных
модулях. (чтоб не было ошибок с перекрестными ссылками)}
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

//Тип процедуры вызова события, с указанием канала
TNotifyEventChannel = procedure(Sender: TObject; channel: integer) of Object;
//Тип процедуры вызова события, с указанием канала и номера запрошенного параметра
//n - номер запрошенного термометра или плотномера
TNotifyEventParam = procedure(Sender: TObject; channel: integer; n: integer) of Object;
//Тип процедуры вызова события, для отправки и получения данных через com-порт
//с показом отправленных - полученных данных
TNotifyData = procedure(Sender: TObject; datastring: ansistring) of Object;

//Перечень возможных состояний системы
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

RParams = record //Структура конфигурации канала
Ht: array [0..7] of integer; //Высота установки термометра (начиная с нижнего), мм
Hp: array [0..2] of integer; //Высота установки плотномера (начиная с нижнего), мм
IdT: array [0..7] of integer; //Id термометра
IdP: array [0..2] of integer; //Id плотномера
H0: integer; //Параметр подставки (привязка к резервуару)
Ls: integer; //Высота датчика в сегментах (для нефтебазы 1 сегмент 15.625 мм. для АЗС 32.25 мм)
end;

RStatus = record   //Структура статуса контроллера
Err: boolean;      //Флаг показывает есть ли ошибка  (есть/нет)
RhoErr: boolean;   //Флаг ошибки в канале плотности (есть/нет)
TempErr: boolean;  //Флаг ошибки в канале температуры (есть/нет)
LevErr: boolean;   //Флаг ошибки в канале уровня (есть/нет)
Rejim: boolean;    //Режим работы контроллера (false - нормальный true - программирование флэш)
NalRho: boolean;   //Наличие канала плотности
NalTemp: boolean;  //Наличие канала температуры
NalLev: boolean;   //Наличие канала уровня
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
