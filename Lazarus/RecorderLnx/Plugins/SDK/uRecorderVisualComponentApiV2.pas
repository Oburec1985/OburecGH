unit uRecorderVisualComponentApiV2;

{ Общий контракт ABI v2 визуальных компонентов для хоста и плагинов.
  Модуль дополняет старый ABI плагинов Recorder, не изменяя его. Через границу
  допускаются записи с размещением C, байтовые массивы AnsiChar фиксированной
  длины, целые числа, непрозрачные указатели, пары буфер/размер и функции cdecl.
  В пределах основной версии ABI 2 поля записей только добавляются в конец;
  перед чтением нового поля получатель проверяет Size доступной части записи. }

{$mode objfpc}{$H+}{$codepage UTF8}
{$PACKRECORDS C}

interface

const
  REC_VISUAL_ABI_V2_MAJOR = 2;
  REC_VISUAL_ABI_V2_MINOR = 8;
  REC_VISUAL_STATE_INI_SECTION_V1 = 'recorder.ini.section-v1';
  REC_VISUAL_STATE_UNKNOWN_ENVELOPE_V1 = 'recorder.unknown-envelope-v1';

  REC_VISUAL_OK = 0;
  REC_VISUAL_ERROR = -1;
  REC_VISUAL_BUFFER_TOO_SMALL = 1;
  REC_VISUAL_NOT_HANDLED = 2;
  REC_VISUAL_END_OF_ENUMERATION = 3;
  REC_VISUAL_NOT_FOUND = 4;
  REC_VISUAL_CANCELLED = 5;
  REC_VISUAL_MAX_DESCRIPTORS = 1024;
  REC_VISUAL_MAX_STATE_BYTES = 16 * 1024 * 1024;

  { Общие события жизненного цикла ViewDispatch без привязки к компоненту;
    доставляются в потоке интерфейса. }
  REC_VISUAL_DISPATCH_START = 1;
  REC_VISUAL_DISPATCH_STOP = 2;
  REC_VISUAL_DISPATCH_DATA_UPDATED = 3;
  REC_VISUAL_DISPATCH_CONFIGURE = 4;
  REC_VISUAL_DISPATCH_ATTACH_VIEW = 5;
  REC_VISUAL_DISPATCH_DETACH_VIEW = 6;
  REC_VISUAL_DISPATCH_RESIZE_VIEW = 7;
  REC_VISUAL_DISPATCH_VIEW_MODE = 8;
  { Редкое уведомление об изменении метаданных, настроек или единиц: здесь
    перечитать каталоги и подготовить буферы, не сбрасывая выбор. Не делать
    это при DATA_UPDATED. }
  REC_VISUAL_DISPATCH_CATALOG_CHANGED = 9;
  { Редкое изменение контекста представления; старые плагины вернут NOT_HANDLED. }
  REC_VISUAL_DISPATCH_VIEW_CONTEXT = 10;

  REC_VISUAL_TYPE_ID_CAPACITY = 128;
  REC_VISUAL_DISPLAY_NAME_CAPACITY = 128;
  REC_VISUAL_CATEGORY_CAPACITY = 64;
  REC_VISUAL_TAG_NAME_CAPACITY = 128;
  REC_VISUAL_TAG_UNIT_CAPACITY = 64;
  REC_VISUAL_TAG_ADDRESS_CAPACITY = 128;
  REC_VISUAL_TAG_DESCRIPTION_CAPACITY = 256;

  REC_VISUAL_TAG_FLAG_VIRTUAL = QWord(1) shl 0;
  REC_VISUAL_TAG_FLAG_VECTOR = QWord(1) shl 1;
  REC_VISUAL_TAG_FLAG_AUTO_RANGE = QWord(1) shl 2;
  REC_VISUAL_TAG_FLAG_SOURCE_VISIBLE = QWord(1) shl 3;

  { Постоянные числовые коды видов оценки в протоколе, не перечисление Pascal. }
  REC_VISUAL_ESTIMATE_MEAN = 0;
  REC_VISUAL_ESTIMATE_RMS = 1;
  REC_VISUAL_ESTIMATE_RMS_DEVIATION = 2;
  REC_VISUAL_ESTIMATE_PEAK = 3;
  REC_VISUAL_ESTIMATE_PEAK_TO_PEAK = 4;
  REC_VISUAL_ESTIMATE_MINIMUM = 5;
  REC_VISUAL_ESTIMATE_MAXIMUM = 6;
  REC_VISUAL_ESTIMATE_PEAK_TO_PEAK_BY_RMS = 7;
  REC_VISUAL_ESTIMATE_LAST = 8;

  REC_VISUAL_NATIVE_NONE = 0;
  REC_VISUAL_NATIVE_WIN32 = 1;
  REC_VISUAL_NATIVE_GTK2 = 2;
  REC_VISUAL_NATIVE_GTK3 = 3;
  REC_VISUAL_NATIVE_QT5 = 4;
  REC_VISUAL_NATIVE_QT6 = 5;
  REC_VISUAL_NATIVE_COCOA = 6;
  REC_VISUAL_VIEW_INTERACTIVE = LongWord(1) shl 0;

type
  PRecorderVisualAbiHeaderV2 = ^TRecorderVisualAbiHeaderV2;
  TRecorderVisualAbiHeaderV2 = record
    Size: LongWord;
    AbiMajor: Word;
    AbiMinor: Word;
  end;

  PRecorderVisualViewContextV2 = ^TRecorderVisualViewContextV2;
  TRecorderVisualViewContextV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    ViewId: QWord;
    DisplayWindowSeconds: Double;
  end;

  { Контекст START для плагинов общего фреймворка: 0 — просмотр, 1 — запись.
    Доступен только на время синхронного ViewDispatch; старые получатели
    могут игнорировать входные данные. Заголовок проверяется перед чтением. }
  PRecorderVisualRunContextV2 = ^TRecorderVisualRunContextV2;
  TRecorderVisualRunContextV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    Recording: LongWord;
  end;

  { В ABI 2.1 AHostContext указывает на предоставленную хостом таблицу
    TRecorderVisualHostServicesV2. Плагины ABI 2.0 могут её игнорировать.
    Данные edit/view содержат собственные заголовки размера и версии. }
  TRecorderVisualCreateInstanceV2 = function(AHostContext: Pointer;
    AConfigData: Pointer; AConfigSize: SizeUInt;
    out AInstance: Pointer): LongInt; cdecl;
  TRecorderVisualDestroyInstanceV2 = procedure(AInstance: Pointer); cdecl;
  TRecorderVisualSaveStateV2 = function(AInstance: Pointer;
    ABuffer: Pointer; ACapacity: SizeUInt;
    out ARequiredSize: SizeUInt): LongInt; cdecl;
  TRecorderVisualLoadStateV2 = function(AInstance: Pointer;
    AStateData: Pointer; AStateSize: SizeUInt): LongInt; cdecl;
  TRecorderVisualEditV2 = function(AInstance: Pointer;
    AHostContext: Pointer; AEditRequest: Pointer;
    AEditRequestSize: SizeUInt): LongInt; cdecl;
  TRecorderVisualViewDispatchV2 = function(AInstance: Pointer;
    ADispatchKind: LongWord; AInput: Pointer; AInputSize: SizeUInt;
    AOutput: Pointer; AOutputCapacity: SizeUInt;
    out AOutputSize: SizeUInt): LongInt; cdecl;

  { Предоставленный вызывающим кодом JSON в UTF-8 со всей секцией INI; все
    значения строковые. Хост передаёт байты, старые ключи разбирает плагин.
    При ошибке импорта экземпляр не меняется; при успехе вызывается Save. }
  PRecorderVisualImportRequestV2 = ^TRecorderVisualImportRequestV2;
  TRecorderVisualImportRequestV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    FormatId: array[0..63] of AnsiChar;
    OriginalTypeId: array[0..REC_VISUAL_TYPE_ID_CAPACITY - 1] of AnsiChar;
    Data: Pointer;
    DataSize: SizeUInt;
  end;
  TRecorderVisualImportStateV2 = function(AInstance: Pointer;
    ARequest: PRecorderVisualImportRequestV2; ARequestSize: SizeUInt): LongInt; cdecl;
  { Псевдонимы служат для поиска типа и не создают дополнительные фабрики. }
  TRecorderVisualEnumerateAliasesV2 = function(AIndex: LongWord;
    ABuffer: PAnsiChar; ACapacity: SizeUInt): LongInt; cdecl;

  PRecorderVisualTagInfoV2 = ^TRecorderVisualTagInfoV2;
  TRecorderVisualTagInfoV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    TagId: QWord;
    Flags: QWord;
    PollFrequencyHz: Double;
    RangeMin: Double;
    RangeMax: Double;
    Name: array[0..REC_VISUAL_TAG_NAME_CAPACITY - 1] of AnsiChar;
    UnitName: array[0..REC_VISUAL_TAG_UNIT_CAPACITY - 1] of AnsiChar;
    Address: array[0..REC_VISUAL_TAG_ADDRESS_CAPACITY - 1] of AnsiChar;
    Description: array[0..REC_VISUAL_TAG_DESCRIPTION_CAPACITY - 1] of AnsiChar;
  end;

  TRecorderVisualEnumerateTagsV2 = function(AContext: Pointer;
    AIndex: LongWord; AInfo: PRecorderVisualTagInfoV2): LongInt; cdecl;
  TRecorderVisualCopyLatestHistoryV2 = function(AContext: Pointer;
    ATagId: QWord; AWindowSeconds: Double; ATimes, AValues: PDouble;
    ACapacity: LongWord; out ACount: LongWord; out ARevision: QWord;
    out AWindowStartSec, ALatestTimeSec: Double): LongInt; cdecl;

  TRecorderVisualSignalInfoV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    Revision, BlockCounter: QWord;
    Count: LongWord;
    Reserved: LongWord;
    LatestTimeSec: Double;
  end;
  PRecorderVisualSignalInfoV2 = ^TRecorderVisualSignalInfoV2;
  TRecorderVisualEstimateV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    Kind, Valid, Count, Reserved: LongWord;
    Value, StartTimeSec, EndTimeSec: Double;
  end;
  PRecorderVisualEstimateV2 = ^TRecorderVisualEstimateV2;
  TRecorderVisualEstimateSettingsV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    EnabledKinds: QWord;
    DefaultKind, Reserved: LongWord;
  end;
  PRecorderVisualEstimateSettingsV2 = ^TRecorderVisualEstimateSettingsV2;
  TRecorderVisualUnitInfoV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    ScaleToBase: Double;
    Name, BaseUnitName, QuantityId: array[0..63] of AnsiChar;
  end;
  PRecorderVisualUnitInfoV2 = ^TRecorderVisualUnitInfoV2;
  { Границы диапазона включаются. IncludePrevious = 0/1 добавляет не более
    одного отсчёта перед FromTimeSec. Revision и LatestTimeSec соответствуют
    тому же заблокированному буферу, что и копируемые отсчёты. ACount сообщает
    требуемую ёмкость; при BUFFER_TOO_SMALL массивы вызывающего не меняются. }
  TRecorderVisualCopyRangeHistoryV2 = function(AContext: Pointer;
    ATagId: QWord; AFromTimeSec, AToTimeSec: Double;
    AIncludePrevious: LongWord; ATimes, AValues: PDouble;
    ACapacity: LongWord; out ACount: LongWord; out ARevision: QWord;
    out AWindowStartSec, ALatestTimeSec: Double): LongInt; cdecl;
  TRecorderVisualGetSignalInfoV2 = function(AContext: Pointer;
    ATagId: QWord; AInfo: PRecorderVisualSignalInfoV2): LongInt; cdecl;
  TRecorderVisualGetSelectedTagIdV2 = function(AContext: Pointer;
    out ATagId: QWord): LongInt; cdecl;
  TRecorderVisualReadEstimateV2 = function(AContext: Pointer;
    ATagId: QWord; AKind: LongWord;
    AEstimate: PRecorderVisualEstimateV2): LongInt; cdecl;
  TRecorderVisualGetEstimateSettingsV2 = function(AContext: Pointer;
    ATagId: QWord; ASettings: PRecorderVisualEstimateSettingsV2): LongInt; cdecl;
  TRecorderVisualEnumerateUnitsV2 = function(AContext: Pointer;
    AIndex: LongWord; AInfo: PRecorderVisualUnitInfoV2): LongInt; cdecl;
  TRecorderVisualConversionFactorV2 = function(AContext: Pointer;
    AFromUnit, AToUnit: PAnsiChar; out AFactor: Double): LongInt; cdecl;

  { Таблица сервисов принадлежит хосту и существует до уничтожения всех
    экземпляров плагина и их callback. Вызовы выполняются последовательно
    в UI-потоке. Массивы истории принадлежат вызывающему и не сохраняются. }
  PRecorderVisualHostServicesV2 = ^TRecorderVisualHostServicesV2;
  TRecorderVisualHostServicesV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    Context: Pointer;
    EnumerateTags: TRecorderVisualEnumerateTagsV2;
    CopyLatestHistory: TRecorderVisualCopyLatestHistoryV2;
    { Общие функции чтения, добавленные в ABI 2.3. Перед обращением к каждой
      проверяется Header.Size; строки в простых структурах имеют кодировку UTF-8. }
    CopyRangeHistory: TRecorderVisualCopyRangeHistoryV2;
    GetSignalInfo: TRecorderVisualGetSignalInfoV2;
    GetSelectedTagId: TRecorderVisualGetSelectedTagIdV2;
    ReadEstimate: TRecorderVisualReadEstimateV2;
    GetTagEstimateSettings: TRecorderVisualGetEstimateSettingsV2;
    EnumerateUnits: TRecorderVisualEnumerateUnitsV2;
    ConversionFactor: TRecorderVisualConversionFactorV2;
  end;

  { Общий контекст создания из палитры передаётся через
    REC_VISUAL_DISPATCH_CONFIGURE. Имена, размеры и непрозрачное состояние
    компонента остаются во владении соответствующего хоста или плагина. }
  PRecorderVisualCreateContextV2 = ^TRecorderVisualCreateContextV2;
  TRecorderVisualCreateContextV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    ComponentNo: LongWord;
    SelectedTagId: QWord;
    DefaultTagId: QWord;
  end;

  { Модальный редактор и черновик принадлежат плагину. Через границу передаётся
    только дескриптор окна владельца; backend должен поддерживаться плагином.
    При OK хост сохраняет состояние, при CANCELLED/ошибке восстанавливает
    прежний снимок. OwnerWindow предоставляется только на время вызова Edit. }
  PRecorderVisualEditRequestV2 = ^TRecorderVisualEditRequestV2;
  TRecorderVisualEditRequestV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    NativeBackend: LongWord;
    Dpi: LongWord;
    OwnerWindow: PtrUInt;
  end;

  { Дочернее представление плагина прикрепляется к предоставленному нативному
    родителю. Width/Height заданы в пикселях его клиентской области, Dpi —
    масштаб. NativeBackend определяет вид нативного дескриптора, не объект LCL.
    Для неподдерживаемого backend возвращается NOT_HANDLED. Плагин владеет
    дочерними элементами и синхронно удаляет/отсоединяет их при DETACH_VIEW.
    В неинтерактивном режиме жесты указателя обрабатывает редактор форм хоста.
    Представление необходимо отсоединить до уничтожения родителя или экземпляра. }
  PRecorderVisualSurfaceV2 = ^TRecorderVisualSurfaceV2;
  TRecorderVisualSurfaceV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    ViewId: QWord;
    NativeBackend: LongWord;
    Dpi: LongWord;
    ParentWindow: PtrUInt;
    Width: LongInt;
    Height: LongInt;
    Flags: LongWord;
    Reserved: LongWord;
  end;

  { Необязательное уничтожение с кодом результата; исключения не проходят ABI. }
  TRecorderVisualTryDestroyInstanceV2 = function(AInstance: Pointer): LongInt; cdecl;
  PRecorderVisualComponentDescriptorV2 = ^TRecorderVisualComponentDescriptorV2;
  TRecorderVisualComponentDescriptorV2 = record
    Header: TRecorderVisualAbiHeaderV2;
    TypeId: array[0..REC_VISUAL_TYPE_ID_CAPACITY - 1] of AnsiChar;
    DisplayName: array[0..REC_VISUAL_DISPLAY_NAME_CAPACITY - 1] of AnsiChar;
    Category: array[0..REC_VISUAL_CATEGORY_CAPACITY - 1] of AnsiChar;
    Flags: QWord;
    CreateInstance: TRecorderVisualCreateInstanceV2;
    DestroyInstance: TRecorderVisualDestroyInstanceV2;
    SaveState: TRecorderVisualSaveStateV2;
    LoadState: TRecorderVisualLoadStateV2;
    Edit: TRecorderVisualEditV2;
    ViewDispatch: TRecorderVisualViewDispatchV2;
    ImportState: TRecorderVisualImportStateV2;
    EnumerateAliases: TRecorderVisualEnumerateAliasesV2;
    TryDestroyInstance: TRecorderVisualTryDestroyInstanceV2;
  end;

  PRecorderVisualGetDescriptorV2 = ^TRecorderVisualGetDescriptorV2;
  TRecorderVisualGetDescriptorV2 = function(AIndex: LongWord;
    ADescriptor: PRecorderVisualComponentDescriptorV2;
    ADescriptorCapacity: SizeUInt): LongInt; cdecl;

{ Проверяет наличие поля в расширяемой записи без переполнения: поле должно
  целиком находиться в размере, объявленном другой стороной ABI. }
function RecorderVisualFieldPresentV2(ARecordSize, AFieldOffset,
  AFieldSize: SizeUInt): Boolean;

implementation

function RecorderVisualFieldPresentV2(ARecordSize, AFieldOffset,
  AFieldSize: SizeUInt): Boolean;
begin
  Result := (AFieldOffset <= ARecordSize) and
    (AFieldSize <= ARecordSize - AFieldOffset);
end;

end.
