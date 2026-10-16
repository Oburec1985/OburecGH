{---------------------------------------------------------------------}
{ Проект (Модуль) реслизации plug-in`а для измерительного ПО Recorder }
{ Модуль описания интерфейса для управления любым объектом            }
{ вычислителем градуировочной функции                                 }
{ Компилятор: Borland Delphi 6.0                                      }
{ НПП "ООО Мера" 2004г.                                               }
{---------------------------------------------------------------------}

unit transf;
interface
uses Windows;
const
   //Уведомления трансформеру
   TXN_UPDATELINKS = 0;  //Произвести перепривязку ссылок
   
   //Команда окну владеющему встраеваемым редактором трансформера
   IDCTF_UPDATEHARDWTARE = $555;
   
type
   TXTYPE =(
      TXT_NULL,
      TXT_SCALE,
      TXT_LINE,
      TXT_INTEPOLATETABLE,
      TXT_POLYNOME
   );

// Базовый интрфейс
   ITransformer = interface
   ['{C1A20401-DC60-11d6-9243-00E029288A7F}']
      function GetEditor: HWND; stdcall;
      function GetEmbeddedEditor(const pParent: HWND): HWND; stdcall;

      //Сохранение трансформера в буфер если передать a_pStream==NULL
      //возвращает размер буфера
      function Save(var pStream): integer; stdcall;
      //Восстановление трансформера из буфера если передать a_pStream==NULL
      //возвращает размер буфера
      function Load(var pStream): integer; stdcall;

      //Получить описание трансформера для записи в файл .mera
      function GetInfoStrings(var pnIndex: integer; var pchBuffer: LPCSTR;
                              const pchPath: LPCSTR;
                              const pchTagName: LPCSTR): integer; stdcall;
      {Активизауия окна встроенного редактора для ГФ}
      function Edit: boolean; stdcall;
      function Eval(const dblValue: double): double; stdcall;
      function GetTXType: TXTYPE; stdcall;
      {Параметры ГФ изменены, необходимо обновить окно встроенного редактора}
      function UpdateEditor: HRESULT; stdcall;
      function Reset: HRESULT; stdcall;

      {Получить/установить наименование ГФ}
      {При получении имени параметром функции адрес приемного буфера,
      буфер должен быть не менее 256 символов}
      function GetName(const pchName: LPCSTR): DWORD; stdcall;
      function SetName(const pchName: LPCSTR): HRESULT; stdcall;

      //Импорт из файла .csv
      function ImportFromFile(const a_pchName: LPCSTR;
                              const pchSeparator: LPCSTR): HRESULT; stdcall;
      //Экспорт в файл .csv
      function ExportToFile(const pchName: LPCSTR;
                            const pchSeparator: LPCSTR): HRESULT; stdcall;

      function GetProgID: LPCSTR; stdcall;

      //Вернуть имя типа
      function GetTypeName(const pchName: LPCSTR): DWORD; stdcall;

      //Произвести проверку корректности параметров
      function Check: HRESULT; stdcall;

      // Получить свойство
      function GetProperty(dwPropertyID: DWORD; var Value: OleVariant): HRESULT; stdcall;
      // Задать свойство
      function SetProperty(const dwPropertyID: DWORD;
                           {const} Value: OleVariant): HRESULT; stdcall;

      // Послать уведомление/комманду
      function Notify(const dwCommand: DWORD; const dwParam: DWORD): boolean; stdcall;

      // Проверить файл на возможность загрузки
      function TestImportFile(const pchName: LPCSTR): boolean; stdcall;

      //Расчитать значение обратной финкции TX
      function EvalInverse(const dblValue: double): double; stdcall;
   end;
implementation
end.

