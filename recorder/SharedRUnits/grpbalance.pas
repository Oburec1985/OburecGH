unit grpbalance;

interface

uses Windows, tags;

const
  IID_IGroupBalance : TGUID = '{68596AD1-5ECD-4f62-92C2-22BE142DA1F6}';

type
  IGroupBalance = interface
   ['{68596AD1-5ECD-4f62-92C2-22BE142DA1F6}']
      // Инициализировать систему балансировки
      function Init : HRESULT; stdcall;

      // Добавить канал в список
      function Add(a_pTag : ITag) : HRESULT; stdcall;

      // Запустить процедуру балансировки
      function Run : HRESULT; stdcall;

      // Завершение работы очистка внутренних ресурсов
      function Finish : HRESULT; stdcall;
   end;

implementation

end.
