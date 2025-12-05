{ --------------------------------------------------------------------- }
{ модуль для обработки ошибок                                           }
{ описания ошибки типа HRESULT - подключить модуль uMyRecorderErrors    }
{ --------------------------------------------------------------------- }

unit uMyErrorMessages;

interface

uses
  Windows, SysUtils, Classes;

  procedure ExitOnError(Error_str : String; Err_number : Integer = 0; Caption_str : String = 'Ошибка'); // выход с сообщением об ошибке
  procedure ExitIfError(res : HRESULT; Error_str : String; Caption_str : String = 'Ошибка'); overload;  // выход с описанием ошибки типа HRESULT
  procedure ExitIfError(res : Boolean; Error_str : String; Caption_str : String = 'Ошибка'); overload;  // выход с описанием ошибки типа HRESULT
  function HResultToString(Error : HRESULT) : String;       // описание ошибки типа HRESULT

implementation

// --- прекращаем работу с сообщением об ошибке --------------------------------
procedure ExitOnError(Error_str : String; Err_number : Integer = 0; Caption_str : String = 'Ошибка');
begin
  if Err_number = 0 then
    MessageBox(0, PChar(Error_str), PChar(Caption_str), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST)
  else
    MessageBox(0, PChar(Error_str + #13#10 + HResultToString(Err_number)), PChar(Caption_str), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

  Abort;
end;

procedure ExitIfError(res : HRESULT; Error_str : String; Caption_str : String = 'Ошибка');
begin
  if res = 0 then Exit; // нет ошибок, S_OK = 0; // Успех

  if (res < $80000000) or // произошла ошибка со значением меньше $80000000
      Failed(res) then    // произошла ошибка со значением больше $80000000
    ExitOnError(Error_str, res, Caption_str);
end;

procedure ExitIfError(res : Boolean; Error_str : String; Caption_str : String = 'Ошибка');
begin
  if not res then // произошла ошибка
    ExitOnError(Error_str, 0, Caption_str);
end;

// -- описание ошибки типа HRESULT ---------------------------------------------
function HResultToString(Error : HRESULT) : String;
var
  Rs : TResourceStream;
  ErrorList : TStringList;
  ind : Integer;
begin
  Result := SysErrorMessage(HResultCode(Error));

  if Result <> '' then // если подошел старый формат ошибки
    begin
      Result := 'Error: ' + IntToStr(Error) + ' (0x' + IntToHex(Error, 8) + ') ' + Result;
      Exit;
    end;

  // Загрузка описания ошибок (для добавления ресурса подключить модуль uMyRecorderErrors)
  if FindResource(HInstance, 'HResultErrors', RT_RCDATA) = 0 then Exit; // не нашли ресурс, пропускаем

  Rs := TResourceStream.Create(HInstance, 'HResultErrors', RT_RCDATA);
  ErrorList := TStringList.Create;
  ErrorList.LoadFromStream(Rs);
  FreeAndNil(Rs);

  ind := ErrorList.IndexOf('0x' + IntToHex(Error, 8));	// Возвращает индекс строки с заданным текстом Text, или -1, если поиск неудачен
  if ind = -1 then // не нашли ничего
    Result := 'Error: ' + IntToStr(Error) + ' - Неизвестная ошибка'
  else
    Result := 'Error: ' + ErrorList[ind] + ' (' + IntToStr(Error) + ') ' + ErrorList[ind+1] + #13#10 + ErrorList[ind+2];

  ErrorList.Free;
end;

// -------------------------------------------------------------------------

initialization

finalization

end.
