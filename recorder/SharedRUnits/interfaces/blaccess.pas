{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейса для блочного доступа к измеренным данным }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}

unit blaccess;
interface
   uses Windows;
{$ALIGN 8}
type
   {Структура для описания штампа времени}
   tagUTSPAIR = record
      dblUTSTime: double;      {время СЕВ}
      dblDeviceTime: double;   {время аппаратного счетчика}
   end;
   UTSPAIR = tagUTSPAIR;

   {Структура для хранения измеренного значения со штампом времени}
   tagI2PAIR = record
      dblTime: double;          {штамп времени}
      nValue: word;             {измеренное значение типа WORD - целое}
   end;
   I2PAIR = tagI2PAIR;

   {Структура для хранения измеренного значения со штампом времени}
   tagR8PAIR = record
      dblTime: double;          {штамп времени}
      dblValue: double;         {измеренное значение типа DOUBLE - действительное}
   end;
   R8PAIR = tagR8PAIR;

   {Блочный доступ вектору данных тега}
   {Данный интерфейс должен быть реализован любым тег`ом}
   IBlockAccess = interface
   ['{c2535841-49b1-11d7-9244-00e029288a7f}']

      //Получить число обработанных блоков
      function GetReadyBlocksCount: DWORD; stdcall;
      //Получить длину вектора
      function GetBlocksCount: ULONG; stdcall;
      //Получить размер блока
      function GetBlocksSize: DWORD; stdcall;
      //Получить размер вектора
      function GetVectorSize: DWORD;  stdcall;
      //Получить максимальную емкость вектора
      function GetVectorCapacity: DWORD; stdcall;

      //Залокировать вектор
      function LockVector: DWORD; stdcall;
      //Разлокировать вектор
      function UnlockVector: DWORD; stdcall;
      //Получить число локов
      function GetLockCount: DWORD; stdcall;


      //Получить блоки в виде floaт'ов
      {первый параметр Block - массив числел типа SINGLE}
      function GetVectorR4(var Block; const Index: longint; const Size: longint;
                           const Tare: boolean): HRESULT; stdcall;

      //Получить блоки в виде int'ов
      {первый параметр Block - массив числел типа WORD}
      function GetVectorI2(var Block; const Index: longint; const Size: longint;
                           const Tare: boolean): HRESULT; stdcall;

      //Получить блоки в виде unsigned int'ов
      {первый параметр Block - массив числел типа WORD}
      function GetVectorU2(var Block; const Index: longint; const Size: longint;
                           const Tare: boolean): HRESULT; stdcall;

      //Получить блоки в виде double'ов
      {первый параметр Block - массив числел типа DOUBLE}
      function GetVectorR8(var Block; const Index: longint; const Size: longint;
                           const Tare: boolean): HRESULT; stdcall;


      //Поддерживает ли вектор формат XY
      function isContainTimes: boolean; stdcall;
      //Является ли вектором СЕВ
      function isUTSVector: boolean; stdcall;
      //Получить блоки в виде пар времен СЕВ
      {первый параметр Block - массив структур UTSPAIR}
      function GetVectorUTS(var Block; const Index: longint; const Size: longint;
                            const Tare: boolean): HRESULT; stdcall;

      //Получить блоки в виде пар (времемя, значение)
      {первый параметр Block - массив структур R8PAIR}
      function GetVectorPairR8(var Block; const Index: longint; const Size: longint;
                               const Tare: boolean): HRESULT; stdcall;
      {первый параметр Block - массив структур I2PAIR}
      function GetVectorPairI2(var Block; const Index: longint; const Size: longint;
                               const Tare: boolean): HRESULT; stdcall;
      //Получить вектор времен
      {первый параметр Block - массив числе тиап DOUBLE}
      function GetVectorTimes(var Block; const Index: longint; const Size: longint;
                              const Tare: boolean): HRESULT; stdcall;

      //Получить время прихода блока в секундах СЕВ
      function GetBlockUTSTime(const Index: longint): double; stdcall;

      //Получить время прихода блока в секундах время устройства
      function GetBlockDeviceTime(const Index: longint): double; stdcall;
   end;
implementation
end.
