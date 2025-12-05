{ --------------------------------------------------------------------- }
{ модуль для функций работы с измерительным ПО Recorder                 }
{ описания ошибки типа HRESULT - подключить модуль uMyRecorderErrors    }
{ --------------------------------------------------------------------- }

unit uMyRecorderUtils;

interface

uses
  Windows, SysUtils, Classes, ActiveX, Variants, Forms, shellapi, Dialogs, SyncObjs,

  uMyDataAndConvert,
  uMyErrorMessages,
  uMyFileUtils,

  PluginClass, recorder, tags, sdb, meconsts, scales, transf, transformers,
  iprcmsgr, iuisrv, iwaitwnd, propaccess, blaccess, modules, I_DataSource;

type
  TDoubleAsByteArr = array[0..7] of byte; // переводим Double в массив Byte для записи в файл BlockWrite(fdat, TDoubleAsByteArr(doub)[0], 8);

  BDGH_Interpolate_Nodes = array of array of double; // ГХ - Таблица интеполяции полиномом первой степени

type
  VectorData_type = record  // канал чтения блоками
    TagName        : String;          // имя тега канала компенсации
    Tag            : ITag;            // тег канала
    FDataIBA       : IBlockAccess;    // ссылка на интерфейс для получения данных тега
    FDataBuffer    : array of Double; // массив блока данных для чтения
    ReadBlockCount : DWORD;           // считанный блок по счетчику обработанных Recorder`ом блоков
    ReadBlockIndex : DWORD;           // индекс блока в буфере тега
    TimeStart      : Double;          // время начала блока
    TimeEnd        : Double;          // время окончания блока
    TimeStep       : Double;          // шаг одного замера
end;

type
  VectorData_array = array of VectorData_type;

  // создание и очистка массивов
  procedure CreateMyArrays;
  procedure ClearMyArrays;

  // задержка без зависания
  procedure Delay(dwMilliseconds: Cardinal); // точность ~15.6 мс
  // задержка с зависанием
  procedure DelayMS(Milliseconds: Cardinal); // точность ~15.6 мс, но можно уменьшить в системных настройках timeBeginPeriod()
  procedure DelayMicro(Microseconds: Int64); // точность несколько микросекунд

  // работа с тегами
  procedure GetRecorderTags;
  procedure DeleteNilTagsFromArray(var fTags_out : DynTagsArray; fTags_in : DynTagsArray = nil);
  procedure CopyTagsArray(var fTags_source : DynTagsArray; var fTags_destination : DynTagsArray; NeedClear : Boolean = True; fTags_in : DynTagsArray = nil);

  function CreateNewVirtualTag(NewName : AnsiString; var tag_itag : ITAG;
                   tag_type : Integer = TTAG_SCALAR or TTAG_INPUT; tag_freq : Integer = 1000; tag_datatype : Integer = VT_R8;
                   tag_save : boolean = true) : integer;
  function CreateNewVirtualTagQuick(NewName : AnsiString; var tag_itag : ITAG;
                   tag_type : Integer = TTAG_SCALAR or TTAG_INPUT; tag_freq : Integer = 1000; tag_datatype : Integer = VT_R8;
                   tag_save : boolean = true) : integer;

  function GetTagIndexByName(tag_name : string; fTags_in : DynTagsArray = nil) : integer;
  function GetTagIndexByTag(tag : ITag; fTags_in : DynTagsArray = nil) : integer;

  function GetTagByName(tag_name : string; fTags_in : DynTagsArray = nil) : ITag;
  function GetTagByID(tag_ID : Int64; fTags_in : DynTagsArray = nil) : ITag;

  function GetTagIDByName(tag_name : string; fTags_in : DynTagsArray = nil) : Int64;
  function GetTagNameByID(tag_ID : Int64; fTags_in : DynTagsArray = nil) : string;

  function GetTagIPropAccess(a_pTag : ITag; a_pPropAc : IPropertyAccess) : boolean;
  function SetTagProperty(tag : ITag; nPropertyID : DWORD; Value : OleVariant; nIndex : Integer = 0) : integer; overload;
  function SetTagProperty(a_pPropAc : IPropertyAccess; nPropertyID : DWORD; Value : OleVariant; nIndex : Integer = 0) : integer; overload;
  function SetTagUserProperty(tag : ITag; a_pPropId : String; a_varValue : OleVariant; a_nFlags : ULONG = UPROPFLAG_PERMANENT) : integer;
  function GetTagProperty(tag : ITag; nPropertyID : DWORD; var Value : OleVariant; nIndex : Integer = 0) : integer; overload;
  function GetTagProperty(a_pPropAc : IPropertyAccess; nPropertyID : DWORD; var Value : OleVariant; nIndex : Integer = 0) : integer; overload;
  function GetTagUserProperty(tag : ITag; a_pPropId : String; var a_varValue : OleVariant; a_nFlags : ULONG = UPROPFLAG_PERMANENT) : integer;

  procedure ConvertPropertyTag(tag : Itag; property_str : string);
  function GetTagGHList(tag : Itag) : String;
  procedure SetTagPolynomialGH(tag : Itag; gh_str : string; Name : ANSIString = ''; Erase_TX : boolean = true);
  function GetTagPolynomialGH(tag : Itag) : String;

  function isTagVector(tag : Itag): boolean;
  function isTagScalar(tag : Itag): boolean;
  function isTagIrregular(tag : Itag): boolean;
  function isTagModuleInitialized(tag : Itag): boolean; overload;
  function isTagModuleInitialized(name : String): boolean; overload;

  procedure VectorDataPrepare;
  function VectorDataRead(index : integer; mode : integer; tare : Boolean = false) : boolean;

  procedure SetTagValue(tag : Itag; value : Double; nEstimator : ULONG = ESTIMATOR_MEAN; dXValue : Double = -1); overload;
  procedure SetTagValue(name : String; value : Double; nEstimator : ULONG = ESTIMATOR_MEAN; dXValue : Double = -1); overload;
  procedure SetTagValueWithCheck(tag : Itag; value : Double; nEstimator : ULONG = ESTIMATOR_MEAN; dXValue : Double = -1); overload;
  procedure SetTagValueWithCheck(name : String; value : Double; nEstimator : ULONG = ESTIMATOR_MEAN; dXValue : Double = -1); overload;
  function GetTagValueWithCheck(tag : Itag; var value : Double; nEstimator : ULONG = ESTIMATOR_MEAN) : Boolean; overload;
  function GetTagValueWithCheck(name : String; var value : Double; nEstimator : ULONG = ESTIMATOR_MEAN) : Boolean; overload;
  function GetTagValueWithCheck_(tag : Itag; nEstimator : ULONG = ESTIMATOR_MEAN) : Double; overload;
  function GetTagValueWithCheck_(name : String; nEstimator : ULONG = ESTIMATOR_MEAN) : Double; overload;

  // работа с окном прогресса Recorder
  procedure RcPM_Create;
  function RcPM_Progress(a_nPos: Integer) : HRESULT;
  function RcPM_Show(const a_pchTitle: AnsiString;    // заголовок
                            a_pchMessage: AnsiString; // сообщение
                            a_dwPictureID: DWORD;     // картинка
                            a_dwOptions: DWORD = 0;   // опции окна
                            hTopWnd: HWND = 0;        // Handle окна
                            Check_error: boolean = false) : HRESULT; // выход по ошибке
  function RcPM_Hide : HRESULT;
  function RcPM_GetCancelState(var a_pfCanceled: VARIANT_BOOL) : HRESULT;

  // вход-выход рекордера в настройку
  function Rc_EnterConfigMode(Check_error: boolean = false) : HRESULT;
  function Rc_LeaveConfigMode(Check_error: boolean = false) : HRESULT;
  function Rc_EnterLeaveConfigMode(dwMilliseconds: DWORD = 1000; Check_error: boolean = false) : HRESULT;

  function GetRecorderLastError(UseWinGetLastError : Boolean = True) : String;

  // управляем рекордером с обработкой ответа
  procedure RcSetState(State : Integer; Check_error : boolean = false; Error_mes : String = '');
  function  RcCheckState(State : Integer; Check_error : boolean = false; Error_mes : String = '') : boolean;

  // папка сохранения данных
  function GetRecorderBaseWriteFolder(var BaseWriteFolder : String) : boolean;
  function SetRecorderBaseWriteFolder(BaseWriteFolder : String) : boolean;
  function GetRecorderLastDataFile(var LastDataFile : String) : boolean;

  // удаляем все свойства и ГХ тега (для БД ГХ)
  procedure BDGH_ClearTagPropertyTare(tag : Itag; num_tarelist, num_propertylist : Integer);

  // работа БД ГХ
  procedure BDGH_GHListsCreate; // создаем StringList для БД ГХ
  procedure BDGH_GHListsFree;   // удаляем StringList для БД ГХ

  procedure BDGH_GetGHList(const in_szName : string;         // корневой каталог, с которого начинаем искать
                           in_pFolder : IMeSDBFolder = nil); // для внутренней рекурсии

  procedure BDGH_GetFolderList;

  procedure BDGH_SetTagInterpolate(tag_in : ITag;                  // тег для привязки ГХ
                                   Nodes : BDGH_Interpolate_Nodes; // массив точек графика
                                   Name : ANSIString = '';         // под каким именем создавать
                                   Erase_TX : boolean = true);     // удалить все существующие ГХ

  procedure BDGH_SetTagTare(tag : Itag;                 // тег для привязки ГХ
                            tare_str : string);         // название ГХ (одна ГХ)
  procedure BDGH_ConvertTareTag(tag : Itag;             // тег для привязки ГХ
                            tare_str : string);         // название ГХ (список ГХ)

  procedure BDGH_ExportTagGH2BD(const tag : ITag;          // тег у которого экспортируем ГХ
                                szKey : LPWSTR;            // в какую подпапку экспортируем
                                szName : ANSIString = ''); // под каким именем экспортировать

  function RunWinPOSMeraFile(Handle : Cardinal; MeraFilePathName : String; ShowError : Boolean = true) : boolean; // запуск .mera в WinPOS

  procedure Write_Log(str2log : String); // пишем в лог

const
  c_ReadLastBlock = 40; // прочитать последний блок из буфера
  c_ReadNextBlock = 41; // прочитать следующий непрочитанный блок

var
  fTags : DynTagsArray;
  fTags_pAccess : array of IUserProperties;
  fTags_adress : array of string;
  pProgressMessager : IProgressMessager; // ссылка на прогрессбар рекордера

  NeedSaveConfig : Boolean;

  VectorData : VectorData_array; // канал чтения блоками

  list_BDGH_path : TStringList;    // список каталогов
  list_BDGH_name : TStringList;    // список ГХ
  list_BDGH_Folders : TStringList; // список ГХ, найденых по папкам

  CS_Write_Log: TCriticalSection; // критическая секция для записи лога
  PluginPath_Write_Log : String;  // путь для записи лога

implementation

// --- создание и очистка массивов ---------------------------------------------
procedure CreateMyArrays;
begin
  SetLength(fTags, 0);
  SetLength(fTags_pAccess, 0);
  SetLength(fTags_adress, 0);
  SetLength(VectorData, 0);

  list_BDGH_path := TStringList.Create;
  list_BDGH_name := TStringList.Create;
  list_BDGH_Folders := TStringList.Create;
end;

procedure ClearMyArrays;
begin
  SetLength(fTags, 0);
  SetLength(fTags_pAccess, 0);
  SetLength(fTags_adress, 0);
  SetLength(VectorData, 0);

  if Assigned(list_BDGH_path) then
    begin
      list_BDGH_path.Free;
      list_BDGH_path := nil;
    end;
  if Assigned(list_BDGH_name) then
    begin
      list_BDGH_name.Free;
      list_BDGH_name := nil;
    end;
  if Assigned(list_BDGH_Folders) then
    begin
      list_BDGH_Folders.Free;
      list_BDGH_Folders := nil;
    end;
end;

// -----------------------------------------------------------------------------
// задержка без зависания
procedure Delay(dwMilliseconds: DWORD); // точность ~15.6 мс
var EndTime : TDateTime;
begin
  EndTime := Now + dwMilliseconds*MsSecondTime;
  repeat
    Sleep(10);
    Application.ProcessMessages;

    if Application.Terminated then Exit;
  until (Now >= EndTime);
end;

// задержка с зависанием
procedure DelayMS(Milliseconds: Cardinal); // точность ~15.6 мс, но можно уменьшить в системных настройках timeBeginPeriod()
var EventHandle: THandle;
begin
  EventHandle := CreateEvent(nil, False, False, nil); // создаём событие
  try
    WaitForSingleObject(EventHandle, Milliseconds); // ждём указанное количество миллисекунд
  finally
    CloseHandle(EventHandle); // закрываем объект события
  end;
end;

procedure DelayMicro(Microseconds: Int64); // точность несколько микросекунд
var StartTime, EndTime, NowTime, Freq50ms, Freq500ms, Frequency: Int64;
begin
  QueryPerformanceFrequency(Frequency); // получаем частоту счётчика производительности
  QueryPerformanceCounter(StartTime);   // фиксируем начальное значение счётчика

  // Целевое время в счётчиках
  EndTime := StartTime + Round(Microseconds * (Frequency / 1000000));

  Freq50ms  := Frequency div 20; // 50 мс в счетчиках
  Freq500ms := Frequency div 2;  // 500 мс в счетчиках

  repeat
    //Application.ProcessMessages;
    if Application.Terminated then Exit;

    QueryPerformanceCounter(NowTime); // проверяем текущее значение счётчика

    // Если осталось больше 500 мс — спим, иначе крутим цикл
    if (EndTime - NowTime) > Freq500ms then
      begin
        Sleep(100);
        Continue;
      end;

    // Если осталось больше 50 мс — спим, иначе крутим цикл
    if (EndTime - NowTime) > Freq50ms then
      begin
        Sleep(10);
        Continue;
      end;
  until (NowTime >= EndTime); // ждем заданное число микросекунд
end;

//=== работаем с тегами и индексами ============================================

//-- читаем теги из рекордера --------------------------------------------------
procedure GetRecorderTags;
var
  i, Count : integer;
  a_varValue : OleVariant;
begin
  SetLength(fTags, 0); // ----- очищаем список тэгов
  SetLength(fTags_pAccess, 0);
  SetLength(fTags_adress, 0);

  // ----- получаем список тегов
  Count := TExtRecorderPack(GPluginInstance).FIRecorder.GetTagsCount; // получить кол-во тегов
  SetLength(fTags, Count);   // Установить соответсвующий размер динамического массива
  SetLength(fTags_pAccess, Count);
  SetLength(fTags_adress, Count);
  for i := 0 to Count - 1 do // Последовательно получить ссылки на интерфейсы тегов
  begin
    // получаем ссылки на теги
    fTags[i] := ITag(TExtRecorderPack(GPluginInstance).FIRecorder.GetTagByIndex(i));
    // получаем интерфейс для пользовательских свойств тегов
    fTags[i].QueryInterface(IID_IUserProperties, fTags_pAccess[i]);

    fTags[i].GetProperty(TAGPROP_HARDWAREADRESS, a_varValue); // Адрес канала
    fTags_adress[i] := StringReplace(String(a_varValue), ' ', '', [rfReplaceAll, rfIgnoreCase]); // удаляем все пробелы
  end;
end;

//-- удаляем пустые теги из массива --------------------------------------------
procedure DeleteNilTagsFromArray(var fTags_out : DynTagsArray; fTags_in : DynTagsArray = nil);
var i, j, len : Integer;
  fTags_clear : DynTagsArray;
begin
  if fTags_in = nil then fTags_in := fTags; // если массив пустой - берем по-умолчанию

  // обнуляем теги, которых нет
  for i := 0 to Length(fTags_out) - 1 do
    begin
      len := 0;

      for j := 0 to Length(fTags_in) - 1 do
        if fTags_out[i] = fTags_in[j] then
          begin
            len := 1;
            Break;
          end;

      if len = 0 then fTags_out[i] := nil;
    end;

  // подсчет ненулевых тегов
  len := 0;
  for i := 0 to Length(fTags_out) - 1 do
    if fTags_out[i] <> nil then
      len := len + 1;

  if Length(fTags_out) = len then Exit; // нет пустых тегов

  // создаем массив без пустых тегов
  SetLength(fTags_clear, len);
  len := 0;
  for i := 0 to Length(fTags_out) - 1 do
    if fTags_out[i] <> nil then
      begin
        fTags_clear[len] := fTags_out[i];
        len := len + 1;
      end;

  // копируем в выходной массив
  SetLength(fTags_out, 0);
  SetLength(fTags_out, len);
  for i := 0 to len - 1 do
    fTags_out[i] := fTags_clear[i];

  SetLength(fTags_clear, 0);
end;

//-- копируем массив тегов с удалением пустых тегов ----------------------------
procedure CopyTagsArray(var fTags_source : DynTagsArray; var fTags_destination : DynTagsArray; NeedClear : Boolean = True; fTags_in : DynTagsArray = nil);
var i : Integer;
begin
  if NeedClear then DeleteNilTagsFromArray(fTags_source, fTags_in); // удаляем пустые теги из массива

  SetLength(fTags_destination, 0);
  SetLength(fTags_destination, Length(fTags_source));
  for i := 0 to Length(fTags_source) - 1 do
    fTags_destination[i] := fTags_source[i];
end;

function CreateNewVirtualTag(NewName : AnsiString; var tag_itag : ITAG;
                   tag_type : Integer = TTAG_SCALAR or TTAG_INPUT; tag_freq : Integer = 1000; tag_datatype : Integer = VT_R8;
                   tag_save : boolean = true) : integer;
var
  temp_tag : ITag;
  er_dwr : DWORD;
  er_str : AnsiString;
  v : OleVariant;
begin
  GetRecorderTags; // читаем теги из рекордера
  NeedSaveConfig := False;

  if NewName = '' then // пустое имя
    begin
      tag_itag := nil;
      Result := E_INVALIDARG;
      Exit;
    end;

  temp_tag := GetTagByName(String(NewName));
  if temp_tag <> nil then // есть уже такой тег
    begin
      tag_itag := temp_tag;
      Result := S_OK;
      Exit;
    end;

  // входим в режим настройки Recorder
  if Succeeded(Rc_EnterConfigMode) then
    begin
      // создаем виртуальный тег
      temp_tag := ITag(TExtRecorderPack(GPluginInstance).FIRecorder.CreateTag(PAnsiChar(NewName), LS_VIRTUAL, nil));

      er_str := '';
      if temp_tag = nil then // ошибка создания виртуального тега
        begin
          er_dwr := TExtRecorderPack(GPluginInstance).FIRecorder.GetLastError;
          //Result := er_dwr;
          er_str := TExtRecorderPack(GPluginInstance).FIRecorder.ConvertErrorCodeToString(er_dwr);

          if er_str = '' then er_str := 'Unknown error';

          ExitOnError(String('Ошибка создания виртуального тега Recorder ' + NewName + ' !' + #13#10 +
                       er_str));
          //Exit;
        end;

      if er_str <> '' then
        begin
          // установка типа тега : вектор, прием и передача
          VariantInit(v);
          VariantClear(v);
          TPropVariant(v).vt := VT_UI4;
          v := tag_type; //TTAG_SCALAR or TTAG_INPUT; //v := TTAG_VECTOR or TTAG_INPUT;
          temp_tag.SetProperty(TAGPROP_TYPE, v);

          // частота опроса
          temp_tag.SetProperty(TAGPROP_ENABLEFREQCORRECTION, true);
          VariantClear(v);
          v := tag_freq; //1000; // частота опроса датчика
          temp_tag.SetFreq(v);

          // тип передаваемых данных
          VariantClear(v);
          TPropVariant(v).vt := tag_datatype; //VT_R8;
          //v := VarAsType(v, varDouble);
          temp_tag.SetProperty(TAGPROP_DATATYPE, v);

          // минимальное и максимальное значение диапазона
          {VariantClear(v);
          temp_tag.GetProperty(TAGPROP_MINVALUE, v);
          temp_tag.SetProperty(TAGPROP_MINVALUE, v);
          VariantClear(v);
          temp_tag.GetProperty(TAGPROP_MAXVALUE, v);
          temp_tag.SetProperty(TAGPROP_MAXVALUE, v);}

          //задаём владельца канала
          //GPluginInstance._AddRef;
          //temp_tag.SetProperty(TAGPROP_OWNER, IUnknown(GPluginInstance));

          //сохранять теги вместе с настройками Recorder`a
          temp_tag.CfgWritable(tag_save);
          if tag_save then NeedSaveConfig := True;

          tag_itag := temp_tag;
        end;

      // выходим из режима настройки Recorder
      if Failed(Rc_LeaveConfigMode) then
        begin
          MessageBox(0, PChar('Ошибка выхода из режима настройки Recorder!'), 'Ошибка', MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);
          Result := S_FALSE;
          Exit;
        end;
    end
  else // не получилось
    begin
      MessageBox(0, PChar('Ошибка входа в режим настройки Recorder!'), 'Ошибка', MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);
      Result := S_FALSE;
      Exit;
    end;

  if NeedSaveConfig then // немедленное сохранение настроек
    TExtRecorderPack(GPluginInstance).FIRecorder.Notify(RCN_SAVECONFIG, 0);
  NeedSaveConfig := False;

  GetRecorderTags; // читаем теги из рекордера

  Result := S_OK;
end;

// -- вариант скоростной, без чтения тегов и входа/выхода конфигурации ---------
function CreateNewVirtualTagQuick(NewName : AnsiString; var tag_itag : ITAG;
                   tag_type : Integer = TTAG_SCALAR or TTAG_INPUT; tag_freq : Integer = 1000; tag_datatype : Integer = VT_R8;
                   tag_save : boolean = true) : integer;
var
  temp_tag : ITag;
  er_dwr : DWORD;
  er_str : AnsiString;
  v : OleVariant;
begin
  if NewName = '' then // пустое имя
    begin
      tag_itag := nil;
      Result := E_INVALIDARG;
      Exit;
    end;

  temp_tag := GetTagByName(String(NewName));
  if temp_tag <> nil then // есть уже такой тег
    begin
      tag_itag := temp_tag;
      Result := S_OK;
      Exit;
    end;

      // создаем виртуальный тег
      temp_tag := ITag(TExtRecorderPack(GPluginInstance).FIRecorder.CreateTag(PAnsiChar(NewName), LS_VIRTUAL, nil));

      if temp_tag = nil then // ошибка создания виртуального тега
        begin
          er_dwr := TExtRecorderPack(GPluginInstance).FIRecorder.GetLastError;
          Result := er_dwr;
          er_str := TExtRecorderPack(GPluginInstance).FIRecorder.ConvertErrorCodeToString(er_dwr);

          //if er_str = 'Объект уже существует' then Exit;

          ExitOnError(String('Ошибка создания виртуального тега Recorder ' + NewName + ' !' + #13#10 +
                       er_str));
          Exit;
        end;

      // установка типа тега : вектор, прием и передача
      VariantInit(v);
      VariantClear(v);
      TPropVariant(v).vt := VT_UI4;
      v := tag_type; //TTAG_SCALAR or TTAG_INPUT; //v := TTAG_VECTOR or TTAG_INPUT;
      temp_tag.SetProperty(TAGPROP_TYPE, v);

      // частота опроса
      temp_tag.SetProperty(TAGPROP_ENABLEFREQCORRECTION, true);
      VariantClear(v);
      v := tag_freq; //1000; // частота опроса датчика
      temp_tag.SetFreq(v);

      // тип передаваемых данных
      VariantClear(v);
      TPropVariant(v).vt := tag_datatype; //VT_R8;
      //v := VarAsType(v, varDouble);
      temp_tag.SetProperty(TAGPROP_DATATYPE, v);

      // минимальное и максимальное значение диапазона
      {VariantClear(v);
      temp_tag.GetProperty(TAGPROP_MINVALUE, v);
      temp_tag.SetProperty(TAGPROP_MINVALUE, v);
      VariantClear(v);
      temp_tag.GetProperty(TAGPROP_MAXVALUE, v);
      temp_tag.SetProperty(TAGPROP_MAXVALUE, v);}

      //задаём владельца канала
      //GPluginInstance._AddRef;
      //temp_tag.SetProperty(TAGPROP_OWNER, IUnknown(GPluginInstance));

      //сохранять теги вместе с настройками Recorder`a
      temp_tag.CfgWritable(tag_save);
      if tag_save then NeedSaveConfig := True;
      //if tag_save then //TExtRecorderPack(GPluginInstance).FIRecorder.PushState(RS_CONFIGCHANGED); // уведомление рекордеру - нужно сохраняться
      //  TExtRecorderPack(GPluginInstance).FIRecorder.Notify(RCN_SAVECONFIG, 0); // немедленное сохранение настроек

      tag_itag := temp_tag;

  Result := S_OK;
end;

//-- получаем индекс тега из массива тегов рекордера ---------------------------
function GetTagIndexByName(tag_name : string; fTags_in : DynTagsArray = nil) : integer;
var
  i : integer;
begin
  Result := -1;

  if fTags_in = nil then fTags_in := fTags; // если массив пустой - берем по-умолчанию

  for i := 0 to Length(fTags_in) - 1 do // по количеству тегов
    begin
      if tag_name = String(fTags_in[i].GetName) then
        begin
          Result := i;
          Break;
        end;
    end;
end;

function GetTagIndexByTag(tag : ITag; fTags_in : DynTagsArray = nil) : integer;
var
  i : integer;
begin
  Result := -1;

  if fTags_in = nil then fTags_in := fTags; // если массив пустой - берем по-умолчанию

  for i := 0 to Length(fTags_in) - 1 do // по количеству тегов
    begin
      if tag = fTags_in[i] then
        begin
          Result := i;
          Break;
        end;
    end;
end;

//-- получаем тег из массива тегов рекордера -----------------------------------
function GetTagByName(tag_name : string; fTags_in : DynTagsArray = nil) : ITag;
var
  i : integer;
begin
  Result := nil;

  if fTags_in = nil then fTags_in := fTags; // если массив пустой - берем по-умолчанию

  for i := 0 to Length(fTags_in) - 1 do // по количеству тегов
    begin
      if tag_name = String(fTags_in[i].GetName) then
        begin
          Result := fTags_in[i];
          Break;
        end;
    end;
end;

function GetTagById(tag_ID : Int64; fTags_in : DynTagsArray = nil) : ITag;
begin
  TExtRecorderPack(GPluginInstance).FIRecorder.GetTagByTagId(tag_ID, Result);
end;

// -- постоянный идентификатор канала ------------------------------------------
function GetTagIDByName(tag_name : string; fTags_in : DynTagsArray = nil) : Int64;
var
  ind : integer;
begin
  Result := -1;

  if fTags_in = nil then fTags_in := fTags; // если массив пустой - берем по-умолчанию

  ind := GetTagIndexByName(tag_name, fTags_in);
  if ind <> -1 then
    fTags_in[ind].GetTagId(Result);
end;

function GetTagNameByID(tag_ID : Int64; fTags_in : DynTagsArray = nil) : string;
var
  i : Integer;
  tag_ID_cur : Int64;
begin
  Result := '';

  if tag_ID = -1 then Exit;

  if fTags_in = nil then fTags_in := fTags; // если массив пустой - берем по-умолчанию

  for i := 0 to Length(fTags_in) - 1 do // по количеству тегов
    begin
      if fTags_in[i].GetTagId(tag_ID_cur) = 0 then
        if tag_ID_cur = tag_ID then
          begin
            Result := String(fTags_in[i].GetName);
            Break;
          end;
    end;
end;

// -----------------------------------------------------------------------------
function GetTagIPropAccess(a_pTag : ITag; a_pPropAc : IPropertyAccess) : boolean;
var
  a_varValue : OleVariant;
  punk : IUnknown;
begin
  Result := false;
  a_pPropAc := nil;

  if (a_pTag = nil) then Exit;

  VariantInit(a_varValue);

  //получение интерфейса свойств канала
  if not a_pTag.GetProperty(TAGPROP_HWCH_PROPS, a_varValue) then
    begin
      VariantClear(a_varValue);
      Exit;
    end;

  punk := a_varValue; // получение из интерфейса IUnknown необходимого IPropertyAccess
  if FAILED(punk.QueryInterface(IID_IPropertyAccess, a_pPropAc)) then
    begin
      VariantClear(a_varValue);
      Exit;
    end;

  VariantClear(a_varValue);
  Result := true;
end;

//-- присваиваем свойство тегу -------------------------------------------------
function SetTagProperty(tag : ITag; nPropertyID : DWORD; Value : OleVariant; nIndex : Integer = 0) : integer;
var
  pPropAc : IPropertyAccess;
begin
  try
    //преобразование к IPropertyAccess
    if (not GetTagIPropAccess(tag, pPropAc)) then
      begin
        Result := 1;
        Exit;
      end;

    //устанавливаем св-ва
    if (FAILED(pPropAc.GetProperty(nPropertyID, Value, nIndex))) then
      begin
        Result := 2;
        Exit;
      end;

    Result := S_OK;
  finally
  end;
end;

function SetTagProperty(a_pPropAc : IPropertyAccess; nPropertyID : DWORD; Value : OleVariant; nIndex : Integer = 0) : integer;
var
  pPropAc : IPropertyAccess;
begin
  Result := -1;

  if a_pPropAc = nil then Exit;

  try
    //устанавливаем св-ва
    if (FAILED(pPropAc.GetProperty(nPropertyID, Value, nIndex))) then
      begin
        Result := 2;
        Exit;
      end;

    Result := S_OK;
  finally
  end;
end;

function SetTagUserProperty(tag : ITag; a_pPropId : String; a_varValue : OleVariant; a_nFlags : ULONG = UPROPFLAG_PERMANENT) : integer; overload;
var
  TagProperty : IUserProperties;
begin
  Result := -1;

  if (tag = nil) then Exit;

  tag.QueryInterface(IID_IUserProperties, TagProperty);

  TagProperty.SetUserProperty(a_pPropId, a_varValue, a_nFlags);

  Result := S_OK;
end;

//-- читаем свойство тега ------------------------------------------------------
function GetTagProperty(tag : ITag; nPropertyID : DWORD; var Value : OleVariant; nIndex : Integer = 0) : integer;
var
  vData : OleVariant;
  pPropAc : IPropertyAccess;
begin
  Result := -1;

  if (tag = nil) then Exit;

  try
    VariantInit(vData);
    //преобразование к IPropertyAccess
    if (not GetTagIPropAccess(tag, pPropAc)) then
      begin
        Result := 1;
        Exit;
      end;

    //читаем св-ва
    if (FAILED(pPropAc.GetProperty(nPropertyID, vData, nIndex))) then
      begin
        Result := 2;
        Exit;
      end;

    Value := vData;

    Result := S_OK;
  finally
    VariantClear(vData);
  end;
end;

function GetTagProperty(a_pPropAc : IPropertyAccess; nPropertyID : DWORD; var Value : OleVariant; nIndex : Integer = 0) : integer;
var
  vData : OleVariant;
begin
  Result := -1;

  if (a_pPropAc = nil) then Exit;

  try
    VariantInit(vData);

    //читаем св-ва
    if (FAILED(a_pPropAc.GetProperty(nPropertyID, vData, nIndex))) then
      begin
        Result := 2;
        Exit;
      end;

    Value := vData;

    Result := S_OK;
  finally
    VariantClear(vData);
  end;
end;

function GetTagUserProperty(tag : ITag; a_pPropId : String; var a_varValue : OleVariant; a_nFlags : ULONG = UPROPFLAG_PERMANENT) : integer;
var
  TagProperty : IUserProperties;
begin
  tag.QueryInterface(IID_IUserProperties, TagProperty);

  TagProperty.SetUserProperty(a_pPropId, a_varValue, a_nFlags);

  Result := S_OK;
end;

//-- разбираем список пользовательских свойств и привязываем их к тегам --------
procedure ConvertPropertyTag(tag : Itag; property_str : string);
var
  prop_list, delim_list : TStringList;
  i, j, tag_id : Integer;
  a_pPropId : TBStr;
  a_varValue : OleVariant;
begin
  if tag = nil then Exit;

  tag_id := GetTagIndexByTag(tag); // получаем индекс тега в массиве
  if tag_id = -1 then
    Exit;

  prop_list := TStringList.Create; // список свойств
  prop_list.Text := StringReplace(property_str, ';', #10, [rfReplaceAll, rfIgnoreCase]);

  delim_list := TStringList.Create; // для разбивки на имя и значение

  // присваиваем свойства
  for i := 0 to prop_list.Count-1 do
    begin
      delim_list.Clear; // разбивка на имя и значение
      delim_list.Text := StringReplace(prop_list[i], '=', #10, [rfReplaceAll, rfIgnoreCase]);

      a_pPropId := '';

      j := delim_list.Count;
      if j = 0 then // пусто, пропускаем
        Continue;
      if j > 0 then // есть имя
        a_pPropId := TBStr(Trim(delim_list[0]));
      if j > 1 then // есть значение
        a_varValue := Trim(delim_list[1])
      else
        a_varValue := '';

      fTags_pAccess[tag_id].SetUserProperty(a_pPropId, a_varValue, UPROPFLAG_PERMANENT); // добавляем свойство
    end;

  prop_list.Free;
  delim_list.Free;
end;

//-- получаем список ГХ, строка с разделением - ';' + #10
function GetTagGHList(tag : Itag) : String;
var
  a_varValue : OleVariant;
  i, Count : integer;
  nstring : String;
  punk : IUnknown;
  pclb : ITransformer; //переменная для получения ссылки на КФ/ГФ
  buffer : array [byte] of AnsiChar; {Буфер для получения строк}
begin
  if tag = nil then Exit;

  GetTagGHList := '';

  tag.GetProperty(TAGPROP_TARES_COUNT, a_varValue);
  Count := a_varValue; // количество ГХ у канала
  nstring := ''; // IntToStr(Count) + '. ';
  for i := 0 to Count-1 do
    begin
      tag.GetPropertyEx(TAGPROPEX_TARE_BY_INDEX, a_varValue, i);

      punk := a_varValue; // получение из интерфейса IUnknown необходимого ITransformer
      if FAILED(punk.QueryInterface(ITransformer, pclb)) then
        Continue;

      if i > 0 then
        nstring := nstring + ';' + #10;//#13;
      pclb.GetName(@buffer);
      nstring := nstring + String(PAnsiChar(@buffer));

     {case pclb.GetTXType of //ветвление по типу КФ/ГФ
      TXT_NULL:            nstring := nstring + ' (TXT_NULL)';
      TXT_SCALE:           nstring := nstring + ' (TXT_SCALE)';
      TXT_LINE:            nstring := nstring + ' (TXT_LINE)';
      TXT_INTEPOLATETABLE: nstring := nstring + ' (TXT_INTEPOLATETABLE)';
      TXT_POLYNOME:        nstring := nstring + ' (TXT_POLYNOME)';
      TXT_MULTI:           nstring := nstring + ' (TXT_MULTI)';
      else //неизвестный тип КФ/ГФ - фрейм деактивировать
        nstring := nstring + ' (неизвестный тип КФ/ГФ)';
     end;}
    end;

  GetTagGHList := nstring;
end;

//-- привязываем к тегу Polynomial Градуировочная функция - полином n-го порядка
procedure SetTagPolynomialGH(tag : Itag; gh_str : string; Name : ANSIString = ''; Erase_TX : boolean = true);
var
  polynome_list : TStringList;
  pPolynomial : IPolynomial;
  pclb : ITransformer;
  a_varValue : OleVariant;
  i, Count : Integer;
  dblCoefficient : double;
begin
  if tag = nil then Exit;

  polynome_list := TStringList.Create; // список свойств
  polynome_list.Text := StringReplace(gh_str, ';', #10, [rfReplaceAll, rfIgnoreCase]);

  pPolynomial := nil;

  try // Создание/изменение объекта ГФ
    ExitIfError(CoCreateInstance(CLSID_PolynomialTransformer, nil, CLSCTX_ALL, IPolynomial, pPolynomial),
        tag.GetName + #13#10 + 'Ошибка создания объекта ГФ - CoCreateInstance Error');

    Count := polynome_list.Count;

    if Count > 0 then
      begin
        ExitIfError(pPolynomial.SetPower(Count-1),
          tag.GetName + #13#10 + 'Ошибка создания параметра pPolynomial.SetPower (' + IntToStr(Count) + ')');

        // устанавливаем точки
        for i := 0 to Count - 1 do
          begin
            polynome_list[i] := StringReplace(polynome_list[i], '.', ',', [rfReplaceAll, rfIgnoreCase]); // меняем . на ,

            if TryStrToFloat(polynome_list[i], dblCoefficient) Then
              begin
                ExitIfError(pPolynomial.PutCoefficient(dblCoefficient, i),
                  tag.GetName + #13#10 + 'Ошибка создания параметра графика ГФ - PutCoefficient (' + FloatToStr(dblCoefficient) + ')');
              end;
          end;

          // получение общего интерфейса
          ExitIfError(pPolynomial.QueryInterface(ITransformer, pclb),
              tag.GetName + #13#10 + 'Ошибка получения общего интерфейса - pInterpolate.QueryInterface Error');

          if Name = '' then // имя пустое, по-умолчанию
            begin
              ExitIfError(pclb.SetName(PANSIChar('ГХ ' + AnsiString(tag.GetName))),
                  tag.GetName + #13#10 + 'Ошибка присвоения имени ГХ - pclb.SetName Error');
            end
          else
            begin
              ExitIfError(pclb.SetName(PANSIChar(Name)),
                  tag.GetName + #13#10 + 'Ошибка присвоения имени ГХ - pclb.SetName Error');
            end;

          // подготовка к установке ГФ
          a_varValue := pclb;
          if Erase_TX then // если надо все удалить
          ExitIfError(tag.Notify(TN_ERASETAGTX, 0),
                      tag.GetName + #13#10 + 'Ошибка подготовки к установке ГФ - TN_ERASETAGTX Error');

          // установить ГФ (канальную функцию)
          ExitIfError(tag.SetProperty(TAGPROP_TARE, a_varValue),
                      tag.GetName + #13#10 + 'Ошибка установки ГФ (канальной функции) - TAGPROP_TARE Error');

          //tag.SetProperty(TAGPROP_TARE_ENABLED, true); // галочка, применить ГХ
          //tag.Notify(TN_RECALCRANGES, 0); // пересчитать диапазоны

          tag.Notify(TN_UPDATETAGTX, 0); // Обновить ТХ
      end;
  finally
    pPolynomial := nil;
    polynome_list.Free
  end;
end;

//-- читаем из тега Polynomial Градуировочная функция - полином n-го порядка
function GetTagPolynomialGH(tag : Itag) : String;
var
  pPolynomial : IPolynomial;
  punk : IUnknown;
  a_varValue : OleVariant;
  i, Count : Integer;
  dblCoefficient : double;
  str : String;
begin
  if tag = nil then Exit;

  str := '';
  GetTagPolynomialGH := '';

  pPolynomial := nil;

  tag.GetProperty(TAGPROP_TARES_COUNT, a_varValue);
  Count := a_varValue; // количество ГХ у канала

  for i := 0 to Count-1 do
    begin
      tag.GetPropertyEx(TAGPROPEX_TARE_BY_INDEX, a_varValue, i);

      punk := a_varValue; // получение из интерфейса IUnknown необходимого IPolynomial
      if FAILED(punk.QueryInterface(IPolynomial, pPolynomial)) then
        Continue;

      if pPolynomial <> nil then Break;
    end;

  if pPolynomial <> nil then
    begin
      Count := pPolynomial.GetPower;

      for i := 0 to Count do
        begin
          pPolynomial.GetCoefficient(dblCoefficient, i);
          str := str + FormatFloat('00.################E+0#', dblCoefficient);

          if i <> Count then str := str + ';';
        end;
    end;

  GetTagPolynomialGH := str;
end;

//-- Типы тегов
function isTagVector(tag : Itag): boolean;
var v: OleVariant;
begin
  if tag = nil then
    begin
      result := false;
      Exit;
    end;
  tag.getProperty(TAGPROP_TYPE, v);
  result := TTAG_VECTOR and v;
end;

function isTagScalar(tag : Itag): boolean;
var v: OleVariant;
begin
  if tag = nil then
    begin
      result := false;
      Exit;
    end;
  tag.getProperty(TAGPROP_TYPE, v);
  result := TTAG_SCALAR and v;
end;

function isTagIrregular(tag : Itag): boolean;
var v: OleVariant;
begin
    if tag = nil then
    begin
      result := false;
      Exit;
    end;
  tag.getProperty(TAGPROP_TYPE, v);
  result := TTAG_IRREGULAR and v;
end;

function isTagModuleInitialized(tag : Itag): boolean; overload;
var
  a_varValue : OleVariant;
  punk : IUnknown;
  pModule : IModule;
begin
  Result := False;

  if tag = nil then Exit;

  VarClear(a_varValue);
  if tag.GetProperty(TAGPROP_MODULE, a_varValue) = False then Exit;

  punk := a_varValue; // получение из интерфейса IUnknown необходимого IPropertyAccess
  if punk.QueryInterface(IModule, pModule) <> 0 then Exit;

  VarClear(a_varValue); // Состояние модуля "проинициализирован"
  if pModule._GetProperty(MDPROP_INITIALIZED, a_varValue) <> 0 then Exit;

  if a_varValue <> DefaultTrueBoolStr then Exit;

  Result := True;
end;

function isTagModuleInitialized(name : String): boolean; overload;
begin
  Result := False;

  if name = '' then Exit;

  Result := isTagModuleInitialized( GetTagByName(name) );
end;

//-- подготовка к чтению блока данных тега
procedure VectorDataPrepare;
var
  i : Integer;
  v : OleVariant;
begin
  for i := 0 to Length(VectorData) - 1 do
    begin
      if VectorData[i].Tag = nil then
        begin
          VectorData[i].tagName  := '';
          VectorData[i].FDataIBA := nil;
          Continue;
        end;

      // получение размера буфера данных
      VariantClear(v);
      VectorData[i].Tag.GetProperty(TAGPROP_BUFFSIZE, v);
      SetLength(VectorData[i].FDataBuffer, Integer(v));

      // ссылка на интерфейс для получения данных тега
      if (FAILED(VectorData[i].Tag.QueryInterface(IBlockAccess, VectorData[i].FDataIBA))) then
        VectorData[i].FDataIBA := nil;

      // последний считанный блок
      VectorData[i].ReadBlockCount := 0;
    end;
end;

//-- читаем блок данных тега
// index - индекс в массиве тегов для чтения
// mode - режим чтения
//        c_ReadLastBlock = 40; // прочитать последний блок из буфера
//        c_ReadNextBlock = 41; // прочитать следующий непрочитанный блок
// tare - применять ГХ, по умолчанию - нет
function VectorDataRead(index : integer; mode : integer; tare : Boolean = false) : boolean;
var
  ReadyCount: DWORD;  // счетчик обработанных Recorder`ом блоков
  BlockCount : ULONG; // счетчик блоков в буфере тега
  BlockFirst : ULONG; // самый первый блок в буфере тега
  NextBlock : ULONG;  // следующий номер блока (глобальный счетчик)
  ReadBlock : ULONG;  // следующий блок в буфере тега для чтения
  Size  : DWORD;      // размер блока
begin
  result := false;
  if VectorData[index].Tag = nil then Exit;
  if VectorData[index].FDataIBA = nil then Exit;

  ReadyCount := VectorData[index].FDataIBA.GetReadyBlocksCount; // получение обработанных Recorder`ом блоков
  BlockCount := VectorData[index].FDataIBA.GetBlocksCount;      // получения кол-ва блоков в буфере тега

  Size := VectorData[index].FDataIBA.GetBlocksSize;    // получение размера блока
  if SmallInt(Size) <> Length(VectorData[index].FDataBuffer) then //отладочная проверка размера блока
    SetLength(VectorData[index].FDataBuffer, Size);

  //Определение наличия новых данных в буфере тега
  if (ReadyCount <> VectorData[index].ReadBlockCount) and (BlockCount > 0)then
    begin
      if VectorData[index].ReadBlockCount > ReadyCount then // текущий счетчик больше максимума
        VectorData[index].ReadBlockCount := ReadyCount - 1; // обрезаем

      if mode = c_ReadLastBlock then // прочитать последний блок из буфера
        begin
          if SUCCEEDED(VectorData[index].FDataIBA.GetVectorR8(
             pointer(VectorData[index].FDataBuffer)^,
             BlockCount - 1, Size, tare)) then
              begin
                VectorData[index].ReadBlockCount := ReadyCount;     // считанный блок по счетчику обработанных Recorder`ом блоков
                VectorData[index].ReadBlockIndex := BlockCount - 1; // индекс блока в буфере тега
                result := true;
              end;
        end;

      if mode = c_ReadNextBlock then // прочитать следующий непрочитанный блок
        begin
          // определяем следующий блок для чтения
          NextBlock := VectorData[index].ReadBlockCount + 1;

          if ReadyCount <= BlockCount then // буфер еще наполняется
            begin
              BlockFirst := 0;         // самый первый блок в буфере тега
              ReadBlock  := NextBlock; // номер блока для чтения в буфере
            end
          else // ReadyCount > BlockCount // буфер перезаписывается
            begin
              BlockFirst := ReadyCount - BlockCount + 1; // самый первый блок в буфере тега
              ReadBlock  := NextBlock - BlockFirst + 1;  // номер блока для чтения в буфере
            end;

          if NextBlock < BlockFirst then // поздняк, читаем самый старый из буфера
            begin
              NextBlock := BlockFirst;
              ReadBlock := 1;
            end;

          if SUCCEEDED(VectorData[index].FDataIBA.GetVectorR8(
             pointer(VectorData[index].FDataBuffer)^,
             ReadBlock - 1, Size, tare)) then
              begin
                VectorData[index].ReadBlockCount := NextBlock;     // считанный блок по счетчику обработанных Recorder`ом блоков
                VectorData[index].ReadBlockIndex := ReadBlock - 1; // индекс блока в буфере тега
                result := true;
              end;
        end;
    end;

  if result then // успешно прочитали, считаем времена замеров
    begin
      VectorData[index].TimeEnd   := VectorData[index].FDataIBA.GetBlockDeviceTime(VectorData[index].ReadBlockIndex);

      if VectorData[index].ReadBlockIndex = 0 then
        VectorData[index].TimeStart := 0
      else
        VectorData[index].TimeStart := VectorData[index].FDataIBA.GetBlockDeviceTime(VectorData[index].ReadBlockIndex - 1);

      VectorData[index].TimeStep := (VectorData[index].TimeEnd - VectorData[index].TimeStart) / Length(VectorData[index].FDataBuffer);
    end;
end;

//-- устанавливаем значение тега
procedure SetTagValue(tag : Itag; value : Double; nEstimator : ULONG = ESTIMATOR_MEAN; dXValue : Double = -1);
begin
  if tag <> nil then
    tag.PushValue(value, dXValue);
end;

procedure SetTagValue(name : String; value : Double; nEstimator : ULONG = ESTIMATOR_MEAN; dXValue : Double = -1);
var tag : ITag;
begin
  tag := GetTagByName(name);

  SetTagValue(tag, value, nEstimator, dXValue);
end;

//-- устанавливаем значение тега с предварительным чтением
procedure SetTagValueWithCheck(tag : Itag; value : Double; nEstimator : ULONG = ESTIMATOR_MEAN; dXValue : Double = -1);
begin
  if tag <> nil then
    if tag.GetEstimate(nEstimator) <> value then
      tag.PushValue(value, dXValue);
end;

procedure SetTagValueWithCheck(name : String; value : Double; nEstimator : ULONG = ESTIMATOR_MEAN; dXValue : Double = -1);
var tag : ITag;
begin
  tag := GetTagByName(name);

  SetTagValueWithCheck(tag, value, nEstimator, dXValue);
end;

//-- читаем значение тега с предварительной проверкой
function GetTagValueWithCheck(tag : Itag; var value : Double; nEstimator : ULONG = ESTIMATOR_MEAN) : Boolean;
begin
  if tag = nil then
    begin
      value := 0;
      Result := false;
      Exit;
    end;

  value := tag.GetEstimate(nEstimator);
  Result := true;
end;

function GetTagValueWithCheck(name : String; var value : Double; nEstimator : ULONG = ESTIMATOR_MEAN) : Boolean;
var tag : ITag;
begin
  tag := GetTagByName(name);

  Result := GetTagValueWithCheck(tag, value, nEstimator);
end;

function GetTagValueWithCheck_(tag : Itag; nEstimator : ULONG = ESTIMATOR_MEAN) : Double; overload;
begin
  if tag = nil then
    begin
      Result := 0;
      Exit;
    end;

  Result := tag.GetEstimate(nEstimator);
end;

function GetTagValueWithCheck_(name : String; nEstimator : ULONG = ESTIMATOR_MEAN) : Double; overload;
var tag : ITag;
begin
  tag := GetTagByName(name);

  Result := GetTagValueWithCheck_(tag, nEstimator);
end;

// ----- РАБОТАЕМ С RECORDER ---------------------------------------------------
// -----------------------------------------------------------------------------
// работа с окном прогресса Recorder
procedure RcPM_Create;
var
  a_varValue : OleVariant;
  punk : IUnknown;
  m_pUIServerLink : IUIServer;
begin
  // получаем интерфейс прогрессбара
  pProgressMessager := nil;
  VarClear(a_varValue);
  ExitIfError(TExtRecorderPack(GPluginInstance).FIRecorder.GetProperty(RCPROP_UISERVERLINK, a_varValue),
            'Прогрессбар - Неверное свойство Recorder (RCPROP_UISERVERLINK)!');

  punk := a_varValue; // получение из интерфейса IUnknown необходимого IUIServer
  ExitIfError(punk.QueryInterface(IUIServer, m_pUIServerLink),
              'Прогрессбар - Неверное свойство Recorder QueryInterface IUIServer!');

  ExitIfError(m_pUIServerLink.QueryInterface(IProgressMessager, pProgressMessager),
              'Прогрессбар - Неверное свойство Recorder QueryInterface IProgressMessager!');
end;

function RcPM_Progress(a_nPos: Integer) : HRESULT;
begin
  Result := S_False;
  if pProgressMessager = nil then Exit;
  Result := pProgressMessager.wm_SetProgressPos(a_nPos); // устанавливаем прогресс
end;

function RcPM_Show(const a_pchTitle: AnsiString; a_pchMessage: AnsiString; a_dwPictureID: DWORD;
                   a_dwOptions: DWORD = 0; hTopWnd: HWND = 0; Check_error: boolean = false) : HRESULT;
begin
  Result := S_False;
  if pProgressMessager = nil then Exit;

  // показываем окно прогресса
  Result := pProgressMessager.wm_Show(PAnsiChar(a_pchTitle),   // заголовок
                                      PAnsiChar(a_pchMessage), // сообщение
                                      a_dwPictureID,           // картинка
                                      a_dwOptions,             // опции окна
                                      hTopWnd);                // Handle окна

  if Check_error then // выход по ошибке
    ExitIfError(Result, 'Неверный вызов функции ProgressMessager.wm_Show!');
end;

function RcPM_Hide : HRESULT;
begin
  Result := S_False;
  if pProgressMessager = nil then Exit;
  Result := pProgressMessager.wm_Hide; // скрываем прогрессбар
end;

function RcPM_GetCancelState(var a_pfCanceled: VARIANT_BOOL) : HRESULT;
begin
  Result := S_False;
  if pProgressMessager = nil then Exit;
  Result := pProgressMessager.wm_GetCancelState(a_pfCanceled);
end;

// -----------------------------------------------------------------------------
// вход-выход рекордера в настройку
function Rc_EnterConfigMode(Check_error: boolean = false) : HRESULT;
begin
  NeedSaveConfig := False;

  Result := TExtRecorderPack(GPluginInstance).FIRecorder.EnterConfigMode(TExtRecorderPack(GPluginInstance).FIRecorder, 0);

  if Check_error then // выход по ошибке
    ExitIfError(Result, 'Ошибка входа в режим настройки Recorder!');
end;

function Rc_LeaveConfigMode(Check_error: boolean = false) : HRESULT;
begin
  Result := TExtRecorderPack(GPluginInstance).FIRecorder.LeaveConfigMode(TExtRecorderPack(GPluginInstance).FIRecorder, 0);

  if Check_error then // выход по ошибке
    ExitIfError(Result, 'Ошибка выхода из режима настройки Recorder!');

  if NeedSaveConfig then // немедленное сохранение настроек
    TExtRecorderPack(GPluginInstance).FIRecorder.Notify(RCN_SAVECONFIG, 0);
end;

function Rc_EnterLeaveConfigMode(dwMilliseconds: DWORD = 1000; Check_error: boolean = false) : HRESULT;
var TStart : TDateTime;
begin
  Result := S_FALSE;
  Rc_EnterConfigMode(Check_error);

  //Delay(dwMilliseconds);
  TStart := Now;
  repeat
    Sleep(10);
    Application.ProcessMessages;

    if Application.Terminated then Exit;
  until (Now - TStart) >= dwMilliseconds*MsSecondTime;

  Rc_LeaveConfigMode(Check_error);
  Result := S_OK;
end;

function GetRecorderLastError(UseWinGetLastError : Boolean = True) : String;
var
  er_dwr : DWORD;
  er_str : String;
begin
  er_dwr := TExtRecorderPack(GPluginInstance).FIRecorder.GetLastError;
  er_str := string(TExtRecorderPack(GPluginInstance).FIRecorder.ConvertErrorCodeToString(er_dwr));

  if er_str = '' then
    if UseWinGetLastError then
      er_str := SysErrorMessage(GetLastError);

  Result := er_str;
end;

// -----------------------------------------------------------------------------
// управляем рекордером с обработкой ответа
procedure RcSetState(State : Integer; Check_error : boolean = false; Error_mes : String = '');
begin
  if not TExtRecorderPack(GPluginInstance).FIRecorder.Notify(State, 0) then // ответ нештатный
    if Check_error then // нужно прекратить дальнейшую работу
      ExitOnError(Error_mes);
end;

function RcCheckState(State : Integer; Check_error : boolean = false; Error_mes : String = '') : boolean;
begin
  //Result := TExtRecorderPack(GPluginInstance).FIRecorder.CheckState(State);
  Result := False;

  case State of
    RS_STOP:
      begin
        if rcStateChange in [RSt_ViewToStop, RSt_RecToStop, RSt_initToStop, RSt_Init] then Result := True;
      end;
    RS_VIEW:
      begin
        if rcStateChange in [RSt_StopToView, RSt_RecToView, RSt_initToView] then Result := True;
      end;
    RS_REC:
      begin
        if rcStateChange in [RSt_StopToRec, RSt_ViewToRec, RSt_initToRec] then Result := True;
      end;
  end;

  if Check_error then // нужно обработать с остановом
    ExitIfError(Result, Error_mes); // ответ отрицательный
end;

function GetRecorderBaseWriteFolder(var BaseWriteFolder : String) : boolean;
var v : OleVariant;
begin
  VariantInit(v);
  Result := TExtRecorderPack(GPluginInstance).FIRecorder.GetProperty(RCPROP_DATAFOLDER, v) = S_OK;
  BaseWriteFolder := v;
end;

function SetRecorderBaseWriteFolder(BaseWriteFolder : String) : boolean;
var v : OleVariant;
begin
  Result := false;

  VariantInit(v);
  TExtRecorderPack(GPluginInstance).FIRecorder.GetProperty(RCPROP_DATAFOLDER, v);
  if v = BaseWriteFolder then
    begin
      Result := True;
      Exit;
    end;

  if BaseWriteFolder = '' then
    ExitOnError('Путь базового каталога Recorder для записи не может быть пустым!');

  // проверяем и создаем root директорию
  if not CheckCreateFolder(BaseWriteFolder) then Exit;

  VariantInit(v);
  v := BaseWriteFolder; // базовая папка

  // входим в режим настройки Recorder
  TExtRecorderPack(GPluginInstance).FIRecorder.Notify(RCN_STOP, 0);
  Application.ProcessMessages;

  if not Succeeded(Rc_EnterConfigMode(True)) then Exit;

  TExtRecorderPack(GPluginInstance).FIRecorder.SetProperty(RCPROP_DATAFOLDER, v);

  if not Succeeded(Rc_LeaveConfigMode(True)) then Exit;

  Result := True;
end;

function GetRecorderLastDataFile(var LastDataFile : String) : boolean;
var v : OleVariant;
begin
  VariantInit(v);
  Result := TExtRecorderPack(GPluginInstance).FIRecorder.GetProperty(RCPROP_LAST_DATA_LOCATION, v) = S_OK;
  LastDataFile := v;
end;

// -----------------------------------------------------------------------------
// удаляем все свойства и ГХ тега (для БД ГХ)
procedure BDGH_ClearTagPropertyTare(tag : Itag; num_tarelist, num_propertylist : Integer);
var
  a_pnCount : ULONG;
  a_pPropId : TBStr;
  a_varValue : OleVariant;
  i, tag_id : Integer;
begin
  if tag = nil then Exit;

  // удаляем все ГХ
  if num_tarelist <> -1 then // если был такой столбец в файле
    begin
      if not tag.Notify(TN_ERASETAGTX, 0) then
        ExitOnError(tag.GetName + #13#10 + 'Ошибка удаления всех ГХ канала - TN_ERASETAGTX Error');

      tag.Notify(TN_RECALCRANGES, 0); // Обновить ТХ
    end;

  // удаляем все свойства
  if num_propertylist <> -1 then // если был такой столбец в файле
    begin
      tag_id := GetTagIndexByTag(tag);
      if tag_id = -1 then
        Exit;
      fTags_pAccess[tag_id].GetUserPropertiesCount(a_pnCount); // по количеству свойств
      for i := 0 to a_pnCount - 1 do
        begin
          fTags_pAccess[tag_id].GetUserPropertyByIndex(i, a_pPropId, a_varValue); // читаем свойство
          fTags_pAccess[tag_id].SetUserProperty(a_pPropId, a_varValue, 0);        // помечаем свойство к удалению
        end;
    end;
end;

// ----- РАБОТАЕМ С БД ГХ ------------------------------------------------------
// -----------------------------------------------------------------------------

procedure BDGH_GHListsCreate;
begin
  list_BDGH_path    := TStringList.Create;
  list_BDGH_name    := TStringList.Create;
  list_BDGH_Folders := TStringList.Create;
end;

procedure BDGH_GHListsFree;
begin
  list_BDGH_path.Free;
  list_BDGH_name.Free;
  list_BDGH_Folders.Free;
end;

// -- заполняем список папок и имен из БД ГХ -----------------------------------
  { если поиск ведется через API - нет выхода на корневую директорию
  csGostPath := 'ГОСТ\Термопары\';
  csGostPath := 'ГОСТ\';
  csGostPath := '\\'; - не работает
  BDGH_GetGHList('ГОСТ\', nil); // заполняем список ГХ из БД
  list_BDGH_path - список каталогов, list_BDGH_name - список ГХ }
procedure BDGH_GetGHList(const in_szName : string; in_pFolder : IMeSDBFolder = nil);
var
  pSDB : IMeSDBBase;
  pManager : IMeSDBObjectMgr;
  pFolder : IMeSDBFolder;
  pFolderManager : IMeSDBObjectMgr;
  pUnkEnum : IEnumUnknown;
  pSDBScale : IMeSDBScale;
  pszName, pPath : LPWSTR;
  punk : IUnknown;
	dwFetched : DWORD;
begin
  if in_pFolder = nil then // первое вхождение
    begin
      if list_BDGH_path <> nil then list_BDGH_path.Clear;
      if list_BDGH_name <> nil then list_BDGH_name.Clear;

      ExitIfError(CoCreateInstance(CLSID_MeSDBBase, nil, CLSCTX_ALL, IMeSDBBase, pSDB),
                  'Ошибка БД создания объекта pSDB');

      ExitIfError(pSDB.Open(DEFAULT_SDB_PATH, MEF_OPEN_ALWAYS),
                  'Ошибка БД pSDB.Open');

      ExitIfError(pSDB.QueryInterface(IMeSDBObjectMgr, pManager),
                  'Ошибка БД pSDB.QueryInterface pManager');

      ExitIfError(pManager.GetObjectByName(PWideChar(in_szName), IID_IMeSDBFolder, pFolder),
                  'Ошибка БД pManager.GetObjectByName');

      if pFolder = nil then
        ExitOnError('Ошибка БД pFolder = nil, in_szName = ' + in_szName);
    end
  else
    begin
      pFolder := in_pFolder;
    end;

  pFolder.GetName(pPath);
  ExitIfError(pFolder.QueryInterface(IMeSDBObjectMgr, pFolderManager),
              'Ошибка БД pFolder.QueryInterface');

	ExitIfError(pFolderManager.CreateEnumerator(IID_IEnumUnknown, pUnkEnum),
              'Ошибка БД pFolderManager.CreateEnumerator');

  punk := nil;
  ExitIfError(pUnkEnum.Next(1, punk, @dwFetched),
              'Ошибка БД pUnkEnum.Next in_szName=' + in_szName);

  while (dwFetched <> 0) do
    begin
			if (S_OK = punk.QueryInterface(IID_IMeSDBScale, pSDBScale)) then // это ГХ
        begin
				  pSDBScale.GetName(pszName);
          if list_BDGH_name <> nil then list_BDGH_name.Add(pszName);                           // имя ГХ
          if list_BDGH_path <> nil then list_BDGH_path.Add(in_szName + pPath + '\' + pszName); // полный путь к ГХ
			  end;

      if (S_OK = punk.QueryInterface(IID_IMeSDBFolder, pFolder)) then // это папка
        begin
          if pFolder <> nil then
            begin
              if in_szName=(pPath + '\') then
                BDGH_GetGHList(in_szName, pFolder) // первое вхождение, корневая папка
              else
                BDGH_GetGHList(in_szName + pPath + '\', pFolder);
            end;
			  end;
			punk := nil;
			pUnkEnum.Next(1, punk, @dwFetched);
		end;

  if pSDB <> nil then
    pSDB.Close;
end;

// поиск по папкам БД ГХ на диске (не совсем правильно, но иначе никак)
procedure BDGH_GetFolderList;
var
  pSDB : IMeSDBBase;
  pPath : LPWSTR;
  pszPath : AnsiString;
  procedure FoundFolder(const aPath: AnsiString; const aLenDBPath : Integer);
    var
      SR : TSearchRec;
      tPath, tempstr : String;
    begin // поиск по папкам на диске
      tPath := IncludeTrailingPathDelimiter(String(aPath));
      if FindFirst(tPath + '*.*', faAnyFile, SR) = 0 then
      begin
        try
          repeat
            if (SR.Name = '.') or (SR.Name = '..') then Continue;
            if (SR.Attr and faDirectory) = 0 then
              Continue
            else
              begin
                tempstr := tPath + SR.Name + '\';
                Delete(tempstr, 1, aLenDBPath);

                list_BDGH_Folders.Add(tempstr);

                FoundFolder(AnsiString(tPath + SR.Name), aLenDBPath);
                Continue;
              end;
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
      end;
    end;
begin
  ExitIfError(CoCreateInstance(CLSID_MeSDBBase, nil, CLSCTX_ALL, IMeSDBBase, pSDB),
              'Ошибка БД создания объекта pSDB (список ГХ)');

  ExitIfError(pSDB.Open(DEFAULT_SDB_PATH, MEF_OPEN_ALWAYS),
              'Ошибка pSDB.Open (список ГХ)');

  pSDB.GetPath(pPath);
  pSDB.Close;
  pszPath := AnsiString(IncludeTrailingPathDelimiter(pPath));

  if list_BDGH_Folders = nil then Exit;

  list_BDGH_Folders.Clear;
  list_BDGH_Folders.Add(''); // пустая корневая папка
  FoundFolder(pszPath, Length(pszPath)); // получаем список всех подпапок
end;

// добавляем ГХ к тегу - Таблица интеполяции полиномом первой степени
{Nodes : BDGH_Interpolate_Nodes;
  SetLength(Nodes, 3, 2);
  Nodes[0,0] :=  0; Nodes[0,1] :=  0;
  Nodes[1,0] := 10; Nodes[1,1] := 10;
  Nodes[2,0] := 90; Nodes[2,1] := 40;
  BDGH_SetTagInterpolate(test_tag, Nodes);
  Nodes := NIL;}
procedure BDGH_SetTagInterpolate(tag_in : ITag; Nodes : BDGH_Interpolate_Nodes; Name : ANSIString = ''; Erase_TX : boolean = true);
var
  pInterpolate : IInterpolate;
  pclb : ITransformer;
  a_varValue : OleVariant;
  i, Count : Integer;
begin
  pInterpolate := nil;
  try // Создание/изменение объекта ГФ
    ExitIfError(CoCreateInstance(CLSID_InterpolateTransformer, nil, CLSCTX_ALL, IInterpolate, pInterpolate),
        tag_in.GetName + #13#10 + 'Ошибка создания объекта ГФ - CoCreateInstance Error');

    // устанавливаем точки графика
    Count := Length(Nodes[0]); // ширина
    if Count < 2 then // точка из 2 значений
      ExitOnError(tag_in.GetName + #13#10 + 'Ошибка подготовки к установке ГФ - неверный размер массива (' + IntToStr(Count) + ')');
    Count := Length(Nodes); // высота
    for i := 0 to Count - 1 do
      ExitIfError(pInterpolate.SetNode(Nodes[i,0], Nodes[i,1], i),
        tag_in.GetName + #13#10 + 'Ошибка создания параметра графика ГФ - SetNode (' + IntToStr(i) + ')');

    // получение общего интерфейса
    ExitIfError(pInterpolate.QueryInterface(ITransformer, pclb),
        tag_in.GetName + #13#10 + 'Ошибка получения общего интерфейса - pInterpolate.QueryInterface Error');

    if Name = '' then // имя пустое, по-умолчанию
      begin
        ExitIfError(pclb.SetName(PANSIChar('ГХ ' + AnsiString(tag_in.GetName))),
            tag_in.GetName + #13#10 + 'Ошибка присвоения имени ГХ - pclb.SetName Error');
      end
    else
      begin
        ExitIfError(pclb.SetName(PANSIChar(Name)),
            tag_in.GetName + #13#10 + 'Ошибка присвоения имени ГХ - pclb.SetName Error');
      end;

    // подготовка к установке ГФ
    a_varValue := pclb;
    if Erase_TX then // если надо все удалить
    ExitIfError(tag_in.Notify(TN_ERASETAGTX, 0),
                tag_in.GetName + #13#10 + 'Ошибка подготовки к установке ГФ - TN_ERASETAGTX Error');

    // установить ГФ (канальную функцию)
    ExitIfError(tag_in.SetProperty(TAGPROP_TARE, a_varValue),
                tag_in.GetName + #13#10 + 'Ошибка установки ГФ (канальной функции) - TAGPROP_TARE Error');

    //tag_in.SetProperty(TAGPROP_TARE_ENABLED, true); // галочка, применить ГХ
    //tag_in.Notify(TN_RECALCRANGES, 0); // пересчитать диапазоны

    tag_in.Notify(TN_UPDATETAGTX, 0); // Обновить ТХ
  finally
    pInterpolate := nil;
  end;
end;

// привязываем ГХ к тегам
procedure BDGH_SetTagTare(tag : Itag; tare_str : string);
var
  a_varValue : OleVariant;
  pscale : IMeScaleEdit;
  pTrasformer : ITransformer;
  pSDB : IMeSDBBase;
  pManager : IMeSDBObjectMgr;
  pSDBScale : IMeSDBScale;
  i, Count : Integer;
begin
  if tag = nil then Exit;
  if tare_str = '' then Exit;

  {// Вызов окна БД ГХ
  hr := CoCreateInstance(CLSID_MeSDBViewer, nil, CLSCTX_ALL, IMeSDBViewer, pViewer);
  if (SUCCEEDED(hr)) then ShowMessage('1 - OK');

  // Поработать с окном БД
  hr := pViewer.Execute(Handle, DEFAULT_SDB_PATH, $2 + $10, true);
  if(hr = S_OK) then ShowMessage('2 - OK');

  // получаем выбранную ГХ
  pViewer.GetSelected(temp_LPCWSTR);}

  if FAILED(CoCreateInstance(CLSID_MeSDBBase, nil, CLSCTX_ALL, IMeSDBBase, pSDB)) then
    ExitOnError(tag.GetName + ' - ' + tare_str + #13#10 + 'Ошибка создания объекта pSDB');

  if FAILED(pSDB.Open(DEFAULT_SDB_PATH, MEF_OPEN_ALWAYS)) then
    ExitOnError(tag.GetName + ' - ' + tare_str + #13#10 + 'Ошибка pSDB.Open');

  if FAILED(pSDB.QueryInterface(IMeSDBObjectMgr, pManager)) then
    ExitOnError(tag.GetName + ' - ' + tare_str + #13#10 + 'Ошибка pSDB.QueryInterface pManager');

  // ищем подпапку с файлом ГХ
  // ----- по папкам на диске ---------------------------
  for i := 0 to list_BDGH_Folders.Count-1 do
    begin
      pSDBScale := nil;

      if FAILED(pManager.GetObjectByName(LPCWSTR(list_BDGH_Folders[i] + tare_str), IID_IMeSDBScale, pSDBScale)) then
        ExitOnError(tag.GetName + ' - ' + tare_str + #13#10 + 'Ошибка pManager.GetObjectByName');

      if pSDBScale = nil then // не нашли ГХ с таким именем
        Continue
      else  // нашли ГХ с таким именем
        Break;
    end;
  // ----------------------------------------------------

  // ----- через API ------------------------------------
  {Index := list_BDGH_name.IndexOf(tare_str); // ищем ГХ по имени, или -1, если поиск неудачен
  if Index = -1 then Exit;                 // не нашли ГХ с таким именем

  pSDBScale := nil;
  if FAILED(pManager.GetObjectByName(LPCWSTR(list_BDGH_path[Index]), IID_IMeSDBScale, pSDBScale)) then
    ExitOnError('Ошибка pManager.GetObjectByName');}
  // ----------------------------------------------------

  if pSDBScale = nil then Exit; // не нашли ГХ с таким именем

  if FAILED(pSDBScale.GetScaleObject(pScale)) then
    ExitOnError(tag.GetName + ' - ' + tare_str + #13#10 + 'Ошибка pSDBScale.GetScaleObject');

  if FAILED(ScaleToTransformer(pScale, pTrasformer)) then
    ExitOnError(tag.GetName + ' - ' + tare_str + #13#10 + 'Ошибка ScaleToTransformer');

  if not (tag.GetProperty(TAGPROP_TARES_COUNT, a_varValue)) then
    ExitOnError(tag.GetName + ' - ' + tare_str + #13#10 + 'Ошибка Get TAGPROP_TARES_COUNT');
  Count := a_varValue; // количество ГХ у канала

  a_varValue := pTrasformer; // подготовка параметра для установки ГФ

  // добавляем ГФ, если a_varValue пустое, то ГХ удаляется
  if FAILED(tag.SetPropertyEx(TAGPROPEX_TARE_BY_INDEX, a_varValue, Count)) then
    ExitOnError(tag.GetName + #13#10 + 'Ошибка добавления ГХ - SetPropertyEx Error');

  // установить ГФ (канальную функцию) - только для одиночных ГХ, перезапись существующих
  if not tag.SetProperty(TAGPROP_TARE, a_varValue) then
    begin
      ExitOnError(tag.GetName + #13#10 + 'Ошибка установки ГФ (канальной функции) - TAGPROP_TARE Error');
    end;

  //tag.Notify(TN_UPDATETAGTX, 0); // Обновить ТХ
  tag.Notify(TN_RECALCRANGES, 0);

  pSDB.Close;
end;

// разбираем список ГХ и привязываем их к тегам
procedure BDGH_ConvertTareTag(tag : Itag; tare_str : string);
var
  prop_list : TStringList;
  i : Integer;
begin
  if tag = nil then Exit;
  if tare_str = '' then Exit; // если ГХ пустое - пропускаем

  prop_list := TStringList.Create; // список ГХ
  prop_list.Text := StringReplace(tare_str, ';', #10, [rfReplaceAll, rfIgnoreCase]);

  for i := 0 to prop_list.Count-1 do
    BDGH_SetTagTare(tag, Trim(prop_list[i])); // здесь привязываем ГХ

  prop_list.Free;
end;

// экспортируем ГХ в БД
procedure BDGH_ExportTagGH2BD(const tag : ITag; szKey : LPWSTR; szName : ANSIString = '');
var
  pSDB : IMeSDBBase;
  pManager : IMeSDBObjectMgr;
  pScale : IMeScaleProp;
  pManagerFolder : IMeSDBObjectMgr;
  pFolder : IMeSDBFolder;
  pclb : ITransformer; //переменная для получения ссылки на КФ/ГФ
  buffer : array [byte] of AnsiChar; {Буфер для получения строк}
  chName : ANSIString;
  punk : IUnknown;
  varTaresCount, varTare : OleVariant;
  i : Integer;
begin
  ExitIfError(CoCreateInstance(CLSID_MeSDBBase, nil, CLSCTX_ALL, IMeSDBBase, pSDB),
              'Ошибка БД создания объекта pSDB (экспорт ГХ в БД)');

  ExitIfError(pSDB.Open(DEFAULT_SDB_PATH, MEF_OPEN_ALWAYS), // открываем БД
              'Ошибка pSDB.Open (экспорт ГХ в БД)');

  ExitIfError(pSDB.QueryInterface(IMeSDBObjectMgr, pManager), // менеджер БД
              'Ошибка БД pSDB.QueryInterface pManager');

  ExitIfError(pManager.GetObjectByName(szKey, IID_IMeSDBFolder, pFolder), // открываем папку
              'Ошибка БД pManager.GetObjectByName pFolder');
  if pFolder = nil then // нет такой папки, создаем
    begin
      ExitIfError(pManager.AddObject(LPWSTR(ExcludeTrailingPathDelimiter(szKey)), '', true, IID_IMeSDBFolder, pFolder),
                  'Ошибка БД pManager.AddObject Folder ' + szKey);
      if pFolder = nil then // не смогли создать папку, выходим
        ExitOnError('Ошибка БД. Не создалась папка ' + szKey);
    end;

  ExitIfError(pFolder.QueryInterface(IMeSDBObjectMgr, pManagerFolder), // менеджер папки
              'Ошибка БД pFolder.QueryInterface pManagerFolder');

  ExitIfError(tag.GetProperty(TAGPROP_TARES_COUNT, varTaresCount), // количество ГХ
              'Ошибка БД ' + tag.GetName + ' GetProperty TAGPROP_TARES_COUNT');

  for i := 0 to Integer(varTaresCount) - 1 do // по всем ГХ тега
    begin
      ExitIfError(tag.GetPropertyEx(TAGPROPEX_TARE_BY_INDEX, varTare, i), // ссылка на ГХ
                  'Ошибка БД ' + tag.GetName + ' GetPropertyEx TAGPROPEX_TARE_BY_INDEX');

      punk := varTare; // получение из интерфейса IUnknown необходимого ITransformer
      if FAILED(punk.QueryInterface(ITransformer, pclb)) then
        Continue;

      // меняем имя
      pclb.GetName(@buffer);
      chName := ANSIString(PAnsiChar(@buffer));
      if chName = '' then // название ГХ пустое - берем название тега + индекс
        chName := ANSIString(tag.GetName + ' (' + IntToStr(i) + ')');
      if szName <> '' then // название не пустое - устанавливаем его
        chName := szName;

      FillChar(buffer, SizeOf(buffer), 0);        // обнуляем буфер
      Move(chName[1], buffer[0], Length(chName)); // забиваем в буфер новое название
      pclb.SetName(@buffer);                      // новое название

      ExitIfError(pclb.QueryInterface(IMeScaleProp, pScale), // получаем pScale для добавления в БД
                  'Ошибка pclb.QueryInterface pScale (экспорт ГХ в БД)');

      pManagerFolder.RemoveObject(LPCWSTR(WideString(chName))); // убиваем существующую

      punk := nil; // добавляем ГХ в БД
      ExitIfError(pManagerFolder.AddScale(pScale, punk),
                  'Ошибка pManagerFolder.AddScale pScale (экспорт ГХ в БД)');

      if szName <> '' then Break; // сохранили первую ГХ под новым именем
    end;

  pSDB.Close;
end;

// запуск .mera в WinPOS
function RunWinPOSMeraFile(Handle : Cardinal; MeraFilePathName : String; ShowError : Boolean = true) : boolean;
var
  res : Cardinal;
begin
  if Handle = 0 then // нет Handle
    begin
      ShowMessage('WinPOS open file - Handle не может быть нулевым' + sLineBreak + MeraFilePathName);
      Result := False;
      Exit;
    end;

  res := ShellExecute(0,//SettingsFrm.Handle,
         'open',
         PWideChar(MeraFilePathName),
         '',
         '',
         SW_SHOW);

  Result := res > 31;

  if Result then Exit;// все успешно

  if not ShowError then Exit;

  case res of
    SE_ERR_FNF:             ShowMessage('WinPOS open file - Файл не найден' + sLineBreak + MeraFilePathName);
    SE_ERR_PNF:             ShowMessage('WinPOS open file - Путь не найден' + sLineBreak + MeraFilePathName);
    SE_ERR_ACCESSDENIED:    ShowMessage('WinPOS open file - Доступ к файлу запрещен' + sLineBreak + MeraFilePathName);
    SE_ERR_OOM:             ShowMessage('WinPOS open file - He хватает памяти' + sLineBreak + MeraFilePathName);
    SE_ERR_DLLNOTFOUND:     ShowMessage('WinPOS open file - Не найдена необходимая DLL' + sLineBreak + MeraFilePathName);
    SE_ERR_SHARE:           ShowMessage('WinPOS open file - Файл захвачен другим пользователем' + sLineBreak + MeraFilePathName);
    SE_ERR_ASSOCINCOMPLETE: ShowMessage('WinPOS open file - Не полная информация о связанном с файлом приложении' + sLineBreak + MeraFilePathName);
    SE_ERR_DDETIMEOUT:      ShowMessage('WinPOS open file - Истекло время на выполнение операции DDE' + sLineBreak + MeraFilePathName);
    SE_ERR_DDEFAIL:         ShowMessage('WinPOS open file - Ошибочная операция DDE' + sLineBreak + MeraFilePathName);
    SE_ERR_DDEBUSY:         ShowMessage('WinPOS open file - Операция DDE занята' + sLineBreak + MeraFilePathName);
    SE_ERR_NOASSOC:         ShowMessage('WinPOS open file - Нет приложения, связанного с файлом' + sLineBreak + MeraFilePathName);
    else                    ShowMessage('WinPOS open file - Неизвестная ошибка - ' + IntToStr(res) + sLineBreak + MeraFilePathName);
  end;
end;

// -----------------------------------------------------------------------------
// пишем в лог
procedure Write_Log(str2log : String);
var
  f : TextFile;
  a_varValue : OleVariant;
begin
  CS_Write_Log.Enter;

    if PluginPath_Write_Log = '' then // путь еще не определен, создаем
      begin
        TExtRecorderPack(GPluginInstance).FIRecorder.GetProperty(RCPROP_CONFIGNAME, a_varValue);
        if VarIsEmpty(a_varValue) or VarIsNull(a_varValue) then
          PluginPath_Write_Log := ''
        else
          PluginPath_Write_Log := VarToStr(a_varValue) + '.test.log'; // по-умолчанию
      end;

    if PluginPath_Write_Log <> '' then // путь определен
      begin
        AssignFile(f, PluginPath_Write_Log);
        if (not FileExists(PluginPath_Write_Log)) or
           (str2log = 'Create new log ...') then
          begin
            Rewrite(f);
            CloseFile(f);
          end;

        try
          Append(f);
          Write(f, FormatDateTime('dd.mm.yy hh:mm:ss.zzz - ', Now) + str2log);
          Flush(f);
        finally
          CloseFile(f);
        end;
      end;

  CS_Write_Log.Leave;
end;

// -------------------------------------------------------------------------
// создаем и удаляем критическую секцию
initialization

  CS_Write_Log        := TCriticalSection.Create;

finalization

  CS_Write_Log.Free;

end.
