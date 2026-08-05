unit uRecorderFormModel;

{
  Модуль uRecorderFormModel

  Назначение:
    Доменная модель экранных компонентов RecorderLnx. Здесь описаны страницы,
    визуальные компоненты мнемосхем и связанная логика создания/редактирования.

  Роль в архитектуре:
    Core/domain. Модуль не зависит от LCL и не создаёт экземпляры TControl. UI-слой
    берёт отсюда метаданные для связи с оболочкой LCL/Canvas/OpenGL-компонентами.

  Сохранение между сессиями:
    Модель для сохранения/загрузки, зарегистрированные типы, layout engine и фабрики
    на этом уровне. При старте восстанавливаем состояние экрана по файлам проекта.

  Кодировка (2026-06): файл в UTF-8. См. Docs/source-encoding.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderTags, uOglChartColors;

type
  { TRecorderRect
    Описывает положение на странице в координатах пикселей.

    Left   - координата левого края.
    Top    - координата верхнего края.
    Width  - ширина прямоугольника.
    Height - высота прямоугольника. }
  TRecorderRect = record
    Left: Integer;
    Top: Integer;
    Width: Integer;
    Height: Integer;
  end;
{ TRecorderFormPageMode
    Режим страницы мнемосхемы.

    fpmView - обычный просмотр данных; по двойному щелчку — редактирование.
    fpmEdit - редактирование мнемосхемы в режиме перетаскивания/изменения компонентов. }
  TRecorderFormPageMode = (
    fpmView,
    fpmEdit
  );

  { Исключение для ошибок работы формы }
  ERecorderFormError = class(Exception);

  TRecorderComponentFactoryBase = class;
  TRecorderVisualComponent = class;
  TRecorderVisualComponentClass = class of TRecorderVisualComponent;

  { TRecorderTagBindingMode
    Режим привязки тега для компонента, который может опираться на выбранный
    в списке тег в стиле Recorder. }
  TRecorderTagBindingMode = (
    rtbmRelativeSelectedTag,
    rtbmAbsoluteTag
  );

  { TRecorderVisualComponent
    Базовый визуальный компонент мнемосхемы. Содержит общие атрибуты расположения,
    привязку к тегу и имя; конкретные наследники расширяют UI-поведение. }
  TRecorderVisualComponent = class
  private
    fBounds: TRecorderRect;                        { размер и позиция компонента }
    fFactory: TRecorderComponentFactoryBase;       { фабрика, создавшая этот компонент }
    fId: string;                                   { уникальный ID компонента на странице }
    fName: string;                                 { имя компонента }
    fTagName: string;
    fTagId: TRecorderTagId;                        { Id привязанного тега }
  protected
    { Возвращает строковый идентификатор типа для сериализации и палитры
      редактора. }
    class function GetTypeId: string; virtual;
  public
    { Создаёт компонент с нулевыми размерами и пустым именем. }
    constructor Create; virtual;
    { Освобождает ресурсы базового компонента }
    destructor Destroy; override;

    { Устанавливает геопрямоугольник компонента.
      ALeft, ATop - координаты левого верхнего угла.
      AWidth, AHeight - размеры прямоугольника; отрицательные значения запрещены. }
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);

    { Возвращает идентификатор типа для фабрики. }
    class function TypeId: string;

    property Id: string read fId write fId;
    property Name: string read fName write fName;
    property TagName: string read fTagName write fTagName;
    property TagId: TRecorderTagId read fTagId write fTagId;
    property Bounds: TRecorderRect read fBounds write fBounds;
    property Factory: TRecorderComponentFactoryBase read fFactory;
  end;

  TRecorderTagValueNameMode = (tvnmNone, tvnmTop, tvnmLeft);

  TRecorderStaticTextComponent = class(TRecorderVisualComponent)
  private
    fText: string;
    fFontName: string;
    fFontSize: Integer;
    fFontColor: LongInt;
    fFontStyleBold: Boolean;
    fFontStyleItalic: Boolean;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    property Text: string read fText write fText;
    property FontName: string read fFontName write fFontName;
    property FontSize: Integer read fFontSize write fFontSize;
    property FontColor: LongInt read fFontColor write fFontColor;
    property FontStyleBold: Boolean read fFontStyleBold write fFontStyleBold;
    property FontStyleItalic: Boolean read fFontStyleItalic write fFontStyleItalic;
  end;

  TRecorderTagValueComponent = class(TRecorderVisualComponent)
  private
    fDisplayFormat: string;
    fFontName: string;
    fFontSize: Integer;
    fFontColor: LongInt;
    fFontStyleBold: Boolean;
    fFontStyleItalic: Boolean;
    fShowNameMode: TRecorderTagValueNameMode;
    fEstimateKind: TRecorderTagEstimateKind;
    fUseDefaultEstimate: Boolean;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    property DisplayFormat: string read fDisplayFormat write fDisplayFormat;
    property FontName: string read fFontName write fFontName;
    property FontSize: Integer read fFontSize write fFontSize;
    property FontColor: LongInt read fFontColor write fFontColor;
    property FontStyleBold: Boolean read fFontStyleBold write fFontStyleBold;
    property FontStyleItalic: Boolean read fFontStyleItalic write fFontStyleItalic;
    property ShowNameMode: TRecorderTagValueNameMode read fShowNameMode write fShowNameMode;
    property EstimateKind: TRecorderTagEstimateKind read fEstimateKind write fEstimateKind;
    property UseDefaultEstimate: Boolean read fUseDefaultEstimate write fUseDefaultEstimate;
  end;

  TRecorderTrendLine = class
  private
    fAxisIndex: Integer;
    fColor: LongInt;
    fEstimateKind: TRecorderTagEstimateKind;
    fName: string;
    fTagName: string;
    fTagId: TRecorderTagId;
    fVisible: Boolean;
    fWidth: Integer;
  public
    constructor Create;
    procedure Assign(ASource: TRecorderTrendLine);
    property Name: string read fName write fName;
    property TagName: string read fTagName write fTagName;
    property TagId: TRecorderTagId read fTagId write fTagId;
    property EstimateKind: TRecorderTagEstimateKind read fEstimateKind
      write fEstimateKind;
    property AxisIndex: Integer read fAxisIndex write fAxisIndex;
    property Color: LongInt read fColor write fColor;
    property Width: Integer read fWidth write fWidth;
    property Visible: Boolean read fVisible write fVisible;
  end;

  { TRecorderOscillogramComponent
    Компонент осциллограммы на пользовательской мнемосхеме. По умолчанию поддерживает
    синхронизацию: основной привязанный тег и набор дополнительных линий. }
  TRecorderOscillogramComponent = class(TRecorderVisualComponent)
  private
    fBindingMode: TRecorderTagBindingMode;
    fLines: TList;
    fTagOffset: Integer;
    function GetLine(AIndex: Integer): TRecorderTrendLine;
    function GetLineCount: Integer;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function AddLine: TRecorderTrendLine;
    procedure AssignOscillogram(ASource: TRecorderOscillogramComponent);
    procedure ClearLines;
    procedure DeleteLine(AIndex: Integer);
    property BindingMode: TRecorderTagBindingMode read fBindingMode
      write fBindingMode;
    property LineCount: Integer read GetLineCount;
    property Lines[AIndex: Integer]: TRecorderTrendLine read GetLine;
    property TagOffset: Integer read fTagOffset write fTagOffset;
  end;


  TRecorderTrendAxis = class
  private
    fColor: LongInt;
    fName: string;
    fRangeMax: Double;
    fRangeMin: Double;
  public
    constructor Create;
    procedure Assign(ASource: TRecorderTrendAxis);
    property Name: string read fName write fName;
    property Color: LongInt read fColor write fColor;
    property RangeMin: Double read fRangeMin write fRangeMin;
    property RangeMax: Double read fRangeMax write fRangeMax;
  end;

  TRecorderTrendYAxisMode = (
    tyamSimple,
    tyamRow,
    tyamColumn,
    tyamFree
  );

  TRecorderTrendComponent = class(TRecorderVisualComponent)
  private
    fAxes: TList;
    fDurationSec: Double;
    fLegendVisible: Boolean;
    fLines: TList;
    fShowCurrentValues: Boolean;
    fUpdatePeriodSec: Double;
    fYAxisMode: TRecorderTrendYAxisMode;
    function GetAxis(AIndex: Integer): TRecorderTrendAxis;
    function GetAxisCount: Integer;
    function GetLine(AIndex: Integer): TRecorderTrendLine;
    function GetLineCount: Integer;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function AddAxis: TRecorderTrendAxis;
    function AddLine: TRecorderTrendLine;
    procedure AssignTrend(ASource: TRecorderTrendComponent);
    procedure ClearAxes;
    procedure ClearLines;
    procedure DeleteAxis(AIndex: Integer);
    procedure DeleteLine(AIndex: Integer);
    property AxisCount: Integer read GetAxisCount;
    property Axes[AIndex: Integer]: TRecorderTrendAxis read GetAxis;
    property LineCount: Integer read GetLineCount;
    property Lines[AIndex: Integer]: TRecorderTrendLine read GetLine;
    property DurationSec: Double read fDurationSec write fDurationSec;
    property UpdatePeriodSec: Double read fUpdatePeriodSec
      write fUpdatePeriodSec;
    property YAxisMode: TRecorderTrendYAxisMode read fYAxisMode
      write fYAxisMode;
    property LegendVisible: Boolean read fLegendVisible write fLegendVisible;
    property ShowCurrentValues: Boolean read fShowCurrentValues
      write fShowCurrentValues;
  end;

  TRecorderSpectrumComponent = class(TRecorderVisualComponent)
  private
    fRangeMinX, fRangeMaxX: Double;
    fRangeMinY, fRangeMaxY: Double;
    fLgX, fLgY: Boolean;
    fShowAlarms, fShowWarnings, fShowProfile: Boolean;
    fShowLabels: Boolean;
    fLegendVisible: Boolean;
    fZeroY0: Boolean;
    fResultType: Integer;
    fTagNames: TStringList;
    fTagIds: array of TRecorderTagId;
    fTahoTagName: string;
    fTahoTagId: TRecorderTagId;
    fProfileName: string;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(ASource: TRecorderSpectrumComponent);
    procedure EnsureTagIdsCount;
    procedure ClearTagRefs;
    procedure SetTagRefAt(AIndex: Integer; ATag: TRecorderTag);
    function ResolveTagAt(ARegistry: TRecorderTagRegistry; AIndex: Integer): TRecorderTag;
    function ResolveTahoTag(ARegistry: TRecorderTagRegistry): TRecorderTag;
    procedure ResolveTagIdsFromNames(ARegistry: TRecorderTagRegistry);
    function TagIdAt(AIndex: Integer): TRecorderTagId;
    procedure SetTagIdAt(AIndex: Integer; ATagId: TRecorderTagId);
    property RangeMinX: Double read fRangeMinX write fRangeMinX;
    property RangeMaxX: Double read fRangeMaxX write fRangeMaxX;
    property RangeMinY: Double read fRangeMinY write fRangeMinY;
    property RangeMaxY: Double read fRangeMaxY write fRangeMaxY;
    property LgX: Boolean read fLgX write fLgX;
    property LgY: Boolean read fLgY write fLgY;
    property ShowAlarms: Boolean read fShowAlarms write fShowAlarms;
    property ShowWarnings: Boolean read fShowWarnings write fShowWarnings;
    property ShowProfile: Boolean read fShowProfile write fShowProfile;
    property ShowLabels: Boolean read fShowLabels write fShowLabels;
    property LegendVisible: Boolean read fLegendVisible write fLegendVisible;
    property ZeroY0: Boolean read fZeroY0 write fZeroY0;
    property ResultType: Integer read fResultType write fResultType;
    property TagNames: TStringList read fTagNames;
    property TahoTagName: string read fTahoTagName write fTahoTagName;
    property TahoTagId: TRecorderTagId read fTahoTagId write fTahoTagId;
    property ProfileName: string read fProfileName write fProfileName;
  end;

  { TRecorderComponentFactoryBase
    Базовый класс фабрики визуальных компонентов. Для каждого экземпляра и типа
    фабрика хранит ссылки компонентов, чтобы при удалении палитры/редактора не
    оставались в памяти висячие ссылки. }
  TRecorderComponentFactoryBase = class
  private
    fChildren: TList;                              { список созданных компонентов (TRecorderVisualComponent) }
    fComponentClass: TRecorderVisualComponentClass;{ класс по типу компонента }
    fDefaultHeight: Integer;                       { высота компонента по умолчанию }
    fDefaultWidth: Integer;                        { ширина компонента по умолчанию }
    fSingleTag: Boolean;                           { true — компонент с одним тегом }
    fTypeId: string;                               { машинный ID типа }
    fTypeName: string;                             { человекочитаемое имя типа }
    function GetChild(AIndex: Integer): TRecorderVisualComponent;
    function GetChildCount: Integer;
  protected
    { Убирает компонент из списка детей при уничтожении объекта. }
    procedure ExcludeComponent(AComponent: TRecorderVisualComponent);
  public
    { Конструктор базовой фабрики.
      ATypeId - машинный id типа для сериализации.
      ATypeName - человекочитаемое название для UI.
      AComponentClass - класс создаваемого компонента.
      ADefaultWidth/ADefaultHeight - размер нового компонента по умолчанию.
      ASingleTag - признак, что компонент работает с одним тегом. }
    constructor Create(const ATypeId, ATypeName: string;
      AComponentClass: TRecorderVisualComponentClass;
      ADefaultWidth, ADefaultHeight: Integer; ASingleTag: Boolean); virtual;
    { Освобождает компоненты при уничтожении фабрики }
    destructor Destroy; override;

    { Создаёт компонент с размерами и типом по умолчанию. }
    function CreateComponent: TRecorderVisualComponent; virtual;

    { Удаляет компонент, когда уничтожает сам объект. }
    procedure ReleaseComponent(AComponent: TRecorderVisualComponent); virtual;

    { Проверяет, что компонент всё ещё числится среди созданных фабрикой. }
    function ContainsComponent(AComponent: TRecorderVisualComponent): Boolean;

    property TypeId: string read fTypeId;
    property TypeName: string read fTypeName;
    property DefaultWidth: Integer read fDefaultWidth;
    property DefaultHeight: Integer read fDefaultHeight;
    property SingleTag: Boolean read fSingleTag;
    property ChildCount: Integer read GetChildCount;
    property Children[AIndex: Integer]: TRecorderVisualComponent read GetChild;
  end;

  { Фабрика статического текста компонентов }
  TRecorderStaticTextFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create; reintroduce;
  end;

  { Фабрика компонента значения тега }
  TRecorderTagValueFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create; reintroduce;
  end;

  { Фабрика компонента осциллограммы }
  TRecorderOscillogramFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create; reintroduce;
  end;

  TRecorderTrendFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create; reintroduce;
  end;

  TRecorderSpectrumFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create;
  end;

  { TRecorderFormPage
    Одна страница мнемосхемы Recorder: имя, заголовок, режим и набор визуальных
    компонентов. Компоненты принадлежат странице. }
  TRecorderFormPage = class
  private
    fComponents: TList;                            { список компонентов на странице (TRecorderVisualComponent) }
    fBaseOscillogramCount: Integer;                { количество осциллограмм для встроенной BasePage }
    fId: string;                                   { уникальный ID страницы }
    fMode: TRecorderFormPageMode;                  { текущий режим (просмотр/редактирование) }
    fName: string;                                 { внутреннее имя страницы }
    fTitle: string;                                { заголовок страницы }
    procedure ReleaseComponent(AComponent: TRecorderVisualComponent);
    function GetComponent(AIndex: Integer): TRecorderVisualComponent;
    function GetComponentCount: Integer;
  public
    { Создаёт новую страницу.
      AId - уникальный идентификатор страницы.
      AName - внутреннее имя страницы.
      ATitle - заголовок для UI. }
    constructor Create(const AId, AName, ATitle: string);
    { Освобождает ресурсы при уничтожении страницы }
    destructor Destroy; override;

    { Добавляет компонент на страницу и возвращает тот же экземпляр.
      AComponent - компонент, который становится дочерним для страницы. }
    function AddComponent(AComponent: TRecorderVisualComponent): TRecorderVisualComponent;

    { Ищет компонент по Id. Возвращает nil, если компонент не найден. }
    function FindComponentById(const AId: string): TRecorderVisualComponent;

    { Удаляет компонент по Id.
      AId - идентификатор компонента. }
    function RemoveComponentById(const AId: string): Boolean;

    { Удаляет компонент по индексу в списке страницы.
      AIndex - номер компонента от 0 до ComponentCount - 1. }
    procedure DeleteComponent(AIndex: Integer);

    property Id: string read fId write fId;
    property Name: string read fName write fName;
    property Title: string read fTitle write fTitle;
    property Mode: TRecorderFormPageMode read fMode write fMode;
    property BaseOscillogramCount: Integer read fBaseOscillogramCount
      write fBaseOscillogramCount;
    property ComponentCount: Integer read GetComponentCount;
    property Components[AIndex: Integer]: TRecorderVisualComponent read GetComponent;
  end;

  { TRecorderFormManager
    Менеджер страниц мнемосхемы. Держит коллекцию страниц и выбор активной
    страницы, которую отображает UI. }
  TRecorderFormManager = class
  private
    fActivePage: TRecorderFormPage;                { текущая активная страница }
    fPages: TList;                                 { список страниц (TRecorderFormPage) }
    function GetPage(AIndex: Integer): TRecorderFormPage;
    function GetPageCount: Integer;
  public
    { Конструктор менеджера форм }
    constructor Create;
    { Освобождает страницы и список при уничтожении }
    destructor Destroy; override;

    { Добавляет страницу и делает её активной страницей. После добавления
      страница принадлежит менеджеру формы. }
    function AddPage(APage: TRecorderFormPage): TRecorderFormPage;

    { Ищет страницу по Id. Возвращает nil, если страница не найдена. }
    function FindPageById(const AId: string): TRecorderFormPage;

    { Возвращает индекс страницы по Id или -1, если страница не найдена. }
    function IndexOfPageId(const AId: string): Integer;

    { Удаляет страницу по Id.
      AId - идентификатор страницы. }
    function RemovePageById(const AId: string): Boolean;

    { Перемещает страницу внутри списка.
      AFromIndex - исходный индекс страницы.
      AToIndex - новый индекс страницы. }
    procedure MovePage(AFromIndex, AToIndex: Integer);

    { Делает страницу с заданным Id активной.
      AId - идентификатор страницы. }
    procedure SetActivePageById(const AId: string);

    { Пытается сделать страницу с заданным Id активной без исключения.
      AId - идентификатор страницы. }
    function TrySetActivePageById(const AId: string): Boolean;

    { Очищает все страницы и освобождает коллекцию. }
    procedure Clear;

    property ActivePage: TRecorderFormPage read fActivePage;
    property PageCount: Integer read GetPageCount;
    property Pages[AIndex: Integer]: TRecorderFormPage read GetPage;
  end;

  { TRecorderComponentFactory
    Реестр фабрик компонентов. Хранит соответствие TypeId -> class и отдельные
    экземпляры для каждого зарегистрированного типа компонента формы. }
  TRecorderComponentFactory = class
  private
    fRegistry: TStringList;                        { строка зарегистрированных типов }
    function GetFactory(AIndex: Integer): TRecorderComponentFactoryBase;
    function GetFactoryCount: Integer;
  public
    { Конструктор реестра компонентов формы }
    constructor Create;
    { Освобождает зарегистрированные фабрики }
    destructor Destroy; override;

    { Регистрирует класс компонента.
      ATypeId - машинное имя типа, например StaticText или TagValue.
      AComponentClass - класс, наследник TRecorderVisualComponent. }
    procedure RegisterComponent(const ATypeId: string;
      AComponentClass: TRecorderVisualComponentClass);

    { Регистрирует готовую фабрику одного типа.
      AFactory - экземпляр фабрики; владение переходит реестру. }
    procedure RegisterFactory(AFactory: TRecorderComponentFactoryBase);

    { Создаёт компонент зарегистрированного типа.
      ATypeId - машинное имя компонента. }
    function CreateComponent(const ATypeId: string): TRecorderVisualComponent;

    { Проверяет, зарегистрирован ли тип компонента. }
    function IsComponentRegistered(const ATypeId: string): Boolean;

    { Ищет фабрику по TypeId. Возвращает nil, если тип не зарегистрирован. }
    function FindFactory(const ATypeId: string): TRecorderComponentFactoryBase;

    { Регистрирует стандартный набор компонентов формы. }
    procedure RegisterDefaultComponents;

    property FactoryCount: Integer read GetFactoryCount;
    property Factories[AIndex: Integer]: TRecorderComponentFactoryBase read GetFactory;
  end;

  { TRecorderFormFactory
    Фабрика форм. Создаёт по шаблонам, когда нужны готовые наборы страниц,
    например при отладке и начальной загрузке проекта. }
  TRecorderFormFactory = class
  private
    fComponentFactory: TRecorderComponentFactory;  { ссылка на реестр компонентов }
  public
    { AComponentFactory - реестр компонентов; фабрика не владеет им. }
    constructor Create(AComponentFactory: TRecorderComponentFactory);

    { Создать пустую страницу мнемосхемы. }
    function CreateBlankPage(const AId, AName, ATitle: string): TRecorderFormPage;

    { Создать отладочную страницу с одним привязанным тегом. }
    function CreateDebugTagPage(const AId, AName, ATitle,
      ATagName: string): TRecorderFormPage;
  end;

implementation

{ TRecorderVisualComponent }

class function TRecorderVisualComponent.GetTypeId: string;
begin
  Result := 'Base';
end;

constructor TRecorderVisualComponent.Create;
begin
  inherited Create;
  fBounds.Left := 0;
  fBounds.Top := 0;
  fBounds.Width := 0;
  fBounds.Height := 0;
  fTagName := '';
  fTagId := 0;
end;

destructor TRecorderVisualComponent.Destroy;
begin
  if fFactory <> nil then
    fFactory.ExcludeComponent(Self);
  inherited Destroy;
end;

procedure TRecorderVisualComponent.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  if (AWidth < 0) or (AHeight < 0) then
    raise ERecorderFormError.Create('Component size cannot be negative');

  fBounds.Left := ALeft;
  fBounds.Top := ATop;
  fBounds.Width := AWidth;
  fBounds.Height := AHeight;
end;

class function TRecorderVisualComponent.TypeId: string;
begin
  Result := GetTypeId;
end;

{ TRecorderStaticTextComponent }

class function TRecorderStaticTextComponent.GetTypeId: string;
begin
  Result := 'StaticText';
end;

{ TRecorderTagValueComponent }

class function TRecorderTagValueComponent.GetTypeId: string;
begin
  Result := 'TagValue';
end;

constructor TRecorderStaticTextComponent.Create;
begin
  inherited Create;
  fText := 'Text';
  fFontName := 'Tahoma';
  fFontSize := 10;
  fFontColor := 0;
  fFontStyleBold := False;
  fFontStyleItalic := False;
end;

constructor TRecorderTagValueComponent.Create;
begin
  inherited Create;
  fDisplayFormat := '0.###';
  fFontName := 'Tahoma';
  fFontSize := 10;
  fFontColor := 0;
  fFontStyleBold := True;
  fFontStyleItalic := False;
  fShowNameMode := tvnmTop;
  fEstimateKind := tekMean;
  fUseDefaultEstimate := True;
end;

{ TRecorderOscillogramComponent }

class function TRecorderOscillogramComponent.GetTypeId: string;
begin
  Result := 'Oscillogram';
end;

constructor TRecorderOscillogramComponent.Create;
begin
  inherited Create;
  fBindingMode := rtbmRelativeSelectedTag;
  fTagOffset := 0;
  fLines := TList.Create;
end;

destructor TRecorderOscillogramComponent.Destroy;
begin
  ClearLines;
  fLines.Free;
  inherited Destroy;
end;

function TRecorderOscillogramComponent.GetLine(AIndex: Integer): TRecorderTrendLine;
begin
  Result := TRecorderTrendLine(fLines[AIndex]);
end;

function TRecorderOscillogramComponent.GetLineCount: Integer;
begin
  Result := fLines.Count;
end;

function TRecorderOscillogramComponent.AddLine: TRecorderTrendLine;
var
  lName: string;
  lColor: LongInt;
begin
  Result := TRecorderTrendLine.Create;
  lName := Result.Name;
  lColor := Result.Color;
  OglChartLineAppearance(fLines.Count + 1, lName, lColor);
  Result.Name := lName;
  Result.Color := lColor;
  fLines.Add(Result);
end;

procedure TRecorderOscillogramComponent.ClearLines;
var
  I: Integer;
begin
  for I := fLines.Count - 1 downto 0 do
    TObject(fLines[I]).Free;
  fLines.Clear;
end;

procedure TRecorderOscillogramComponent.DeleteLine(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= fLines.Count) then
    Exit;
  TObject(fLines[AIndex]).Free;
  fLines.Delete(AIndex);
end;

procedure TRecorderOscillogramComponent.AssignOscillogram(
  ASource: TRecorderOscillogramComponent);
var
  I: Integer;
  lLine: TRecorderTrendLine;
begin
  if ASource = nil then
    Exit;
  fBindingMode := ASource.BindingMode;
  fTagOffset := ASource.TagOffset;
  fTagName := ASource.TagName;
  fTagId := ASource.TagId;
  ClearLines;
  for I := 0 to ASource.LineCount - 1 do
  begin
    lLine := AddLine;
    lLine.Assign(ASource.Lines[I]);
  end;
end;


{ TRecorderTrendAxis }

constructor TRecorderTrendAxis.Create;
begin
  inherited Create;
  fName := 'Y';
  fColor := $00808080;
  fRangeMin := 0;
  fRangeMax := 1;
end;

procedure TRecorderTrendAxis.Assign(ASource: TRecorderTrendAxis);
begin
  if ASource = nil then
    Exit;
  fName := ASource.Name;
  fColor := ASource.Color;
  fRangeMin := ASource.RangeMin;
  fRangeMax := ASource.RangeMax;
end;

{ TRecorderTrendLine }

constructor TRecorderTrendLine.Create;
begin
  inherited Create;
  fName := 'Line';
  fTagName := '';
  fTagId := 0;
  fEstimateKind := tekMean;
  fAxisIndex := 0;
  fColor := LongInt(OglChartLinePaletteColor(0));
  fWidth := 1;
  fVisible := True;
end;

procedure TRecorderTrendLine.Assign(ASource: TRecorderTrendLine);
begin
  if ASource = nil then
    Exit;
  fName := ASource.Name;
  fTagName := ASource.TagName;
  fTagId := ASource.TagId;
  fEstimateKind := ASource.EstimateKind;
  fAxisIndex := ASource.AxisIndex;
  fColor := ASource.Color;
  fWidth := ASource.Width;
  fVisible := ASource.Visible;
end;

{ TRecorderTrendComponent }

class function TRecorderTrendComponent.GetTypeId: string;
begin
  Result := 'Trend';
end;

constructor TRecorderTrendComponent.Create;
begin
  inherited Create;
  fAxes := TList.Create;
  fLines := TList.Create;
  fDurationSec := 100.0;
  fUpdatePeriodSec := 1.0;
  fYAxisMode := tyamRow;
  fLegendVisible := True;
  fShowCurrentValues := False;
  AddAxis;
end;

destructor TRecorderTrendComponent.Destroy;
begin
  ClearLines;
  ClearAxes;
  fLines.Free;
  fAxes.Free;
  inherited Destroy;
end;

function TRecorderTrendComponent.GetAxis(AIndex: Integer): TRecorderTrendAxis;
begin
  Result := TRecorderTrendAxis(fAxes[AIndex]);
end;

function TRecorderTrendComponent.GetAxisCount: Integer;
begin
  Result := fAxes.Count;
end;

function TRecorderTrendComponent.GetLine(AIndex: Integer): TRecorderTrendLine;
begin
  Result := TRecorderTrendLine(fLines[AIndex]);
end;

function TRecorderTrendComponent.GetLineCount: Integer;
begin
  Result := fLines.Count;
end;

function TRecorderTrendComponent.AddAxis: TRecorderTrendAxis;
begin
  Result := TRecorderTrendAxis.Create;
  fAxes.Add(Result);
end;

function TRecorderTrendComponent.AddLine: TRecorderTrendLine;
var
  lName: string;
  lColor: LongInt;
begin
  Result := TRecorderTrendLine.Create;
  lName := Result.Name;
  lColor := Result.Color;
  OglChartLineAppearance(fLines.Count, lName, lColor);
  Result.Name := lName;
  Result.Color := lColor;
  fLines.Add(Result);
end;

procedure TRecorderTrendComponent.AssignTrend(ASource: TRecorderTrendComponent);
var
  I: Integer;
begin
  if ASource = nil then
    Exit;
  fDurationSec := ASource.DurationSec;
  fUpdatePeriodSec := ASource.UpdatePeriodSec;
  fYAxisMode := ASource.YAxisMode;
  fLegendVisible := ASource.LegendVisible;
  fShowCurrentValues := ASource.ShowCurrentValues;
  ClearAxes;
  for I := 0 to ASource.AxisCount - 1 do
    AddAxis.Assign(ASource.Axes[I]);
  if fAxes.Count = 0 then
    AddAxis;
  ClearLines;
  for I := 0 to ASource.LineCount - 1 do
    AddLine.Assign(ASource.Lines[I]);
end;

procedure TRecorderTrendComponent.ClearAxes;
begin
  while fAxes.Count > 0 do
  begin
    TObject(fAxes[0]).Free;
    fAxes.Delete(0);
  end;
end;

procedure TRecorderTrendComponent.ClearLines;
begin
  while fLines.Count > 0 do
  begin
    TObject(fLines[0]).Free;
    fLines.Delete(0);
  end;
end;

{ TRecorderSpectrumComponent }

class function TRecorderSpectrumComponent.GetTypeId: string;
begin
  Result := 'Spectrum';
end;

constructor TRecorderSpectrumComponent.Create;
begin
  inherited Create;
  fTagNames := TStringList.Create;
  fTagNames.CaseSensitive := False;
  
  fRangeMinX := 0.0;
  fRangeMaxX := 1000.0;
  fRangeMinY := 0.0;
  fRangeMaxY := 10.0;
  fLgX := False;
  fLgY := False;
  fShowAlarms := True;
  fShowWarnings := True;
  fShowProfile := True;
  fShowLabels := True;
  fLegendVisible := True;
  fZeroY0 := True;
  fResultType := 0;
  fTahoTagId := 0;
  SetLength(fTagIds, 0);
end;

destructor TRecorderSpectrumComponent.Destroy;
begin
  fTagNames.Free;
  inherited Destroy;
end;

procedure TRecorderSpectrumComponent.Assign(ASource: TRecorderSpectrumComponent);
begin
  if ASource = nil then Exit;
  fRangeMinX := ASource.RangeMinX;
  fRangeMaxX := ASource.RangeMaxX;
  fRangeMinY := ASource.RangeMinY;
  fRangeMaxY := ASource.RangeMaxY;
  fLgX := ASource.LgX;
  fLgY := ASource.LgY;
  fShowAlarms := ASource.ShowAlarms;
  fShowWarnings := ASource.ShowWarnings;
  fShowProfile := ASource.ShowProfile;
  fShowLabels := ASource.ShowLabels;
  fLegendVisible := ASource.LegendVisible;
  fZeroY0 := ASource.ZeroY0;
  fResultType := ASource.ResultType;
  fTahoTagName := ASource.TahoTagName;
  fTahoTagId := ASource.TahoTagId;
  fProfileName := ASource.ProfileName;
  fTagNames.Assign(ASource.TagNames);
  fTagIds := ASource.fTagIds;
end;

procedure TRecorderSpectrumComponent.EnsureTagIdsCount;
begin
  if Length(fTagIds) <> fTagNames.Count then
    SetLength(fTagIds, fTagNames.Count);
end;

function TRecorderSpectrumComponent.TagIdAt(AIndex: Integer): TRecorderTagId;
begin
  EnsureTagIdsCount;
  if (AIndex < 0) or (AIndex >= Length(fTagIds)) then
    Exit(0);
  Result := fTagIds[AIndex];
end;

procedure TRecorderSpectrumComponent.SetTagIdAt(AIndex: Integer;
  ATagId: TRecorderTagId);
begin
  EnsureTagIdsCount;
  if (AIndex < 0) or (AIndex >= Length(fTagIds)) then
    Exit;
  fTagIds[AIndex] := ATagId;
end;

procedure TRecorderSpectrumComponent.ClearTagRefs;
begin
  SetLength(fTagIds, 0);
  fTahoTagId := 0;
end;

procedure TRecorderSpectrumComponent.SetTagRefAt(AIndex: Integer; ATag: TRecorderTag);
begin
  if ATag = nil then
    Exit;
  if AIndex = fTagNames.Count then
    fTagNames.Add(ATag.Name)
  else if (AIndex < 0) or (AIndex >= fTagNames.Count) then
    Exit;
  EnsureTagIdsCount;
  fTagIds[AIndex] := ATag.Id;
  if not SameText(fTagNames[AIndex], ATag.Name) then
    fTagNames[AIndex] := ATag.Name;
end;

function TRecorderSpectrumComponent.ResolveTagAt(ARegistry: TRecorderTagRegistry;
  AIndex: Integer): TRecorderTag;
begin
  Result := nil;
  if (ARegistry = nil) or (AIndex < 0) or (AIndex >= fTagNames.Count) then
    Exit;
  EnsureTagIdsCount;
  if fTagIds[AIndex] <> 0 then
    Result := ARegistry.FindById(fTagIds[AIndex]);
  if Result = nil then
    Result := ARegistry.FindByName(fTagNames[AIndex]);
  if Result <> nil then
    SetTagRefAt(AIndex, Result);
end;

function TRecorderSpectrumComponent.ResolveTahoTag(
  ARegistry: TRecorderTagRegistry): TRecorderTag;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  if fTahoTagId <> 0 then
    Result := ARegistry.FindById(fTahoTagId);
  if Result = nil then
    Result := ARegistry.FindByName(fTahoTagName);
  if Result <> nil then
  begin
    fTahoTagId := Result.Id;
    fTahoTagName := Result.Name;
  end;
end;

procedure TRecorderSpectrumComponent.ResolveTagIdsFromNames(
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
begin
  if ARegistry = nil then
    Exit;
  EnsureTagIdsCount;
  for I := 0 to fTagNames.Count - 1 do
    ResolveTagAt(ARegistry, I);
  ResolveTahoTag(ARegistry);
end;

{ TRecorderSpectrumFactory }

constructor TRecorderSpectrumFactory.Create;
begin
  inherited Create(TRecorderSpectrumComponent.TypeId, 'Spectrum',
    TRecorderSpectrumComponent, 400, 300, False);
end;

procedure TRecorderTrendComponent.DeleteAxis(AIndex: Integer);
begin
  TObject(fAxes[AIndex]).Free;
  fAxes.Delete(AIndex);
  if fAxes.Count = 0 then
    AddAxis;
end;

procedure TRecorderTrendComponent.DeleteLine(AIndex: Integer);
begin
  TObject(fLines[AIndex]).Free;
  fLines.Delete(AIndex);
end;{ TRecorderComponentFactoryBase }

constructor TRecorderComponentFactoryBase.Create(const ATypeId,
  ATypeName: string; AComponentClass: TRecorderVisualComponentClass;
  ADefaultWidth, ADefaultHeight: Integer; ASingleTag: Boolean);
begin
  inherited Create;
  if ATypeId = '' then
    raise ERecorderFormError.Create('Component type id cannot be empty');
  if AComponentClass = nil then
    raise ERecorderFormError.Create('Component class cannot be nil');
  if (ADefaultWidth < 0) or (ADefaultHeight < 0) then
    raise ERecorderFormError.Create('Default component size cannot be negative');

  fChildren := TList.Create;
  fTypeId := ATypeId;
  fTypeName := ATypeName;
  fComponentClass := AComponentClass;
  fDefaultWidth := ADefaultWidth;
  fDefaultHeight := ADefaultHeight;
  fSingleTag := ASingleTag;
end;

destructor TRecorderComponentFactoryBase.Destroy;
begin
  while fChildren.Count > 0 do
    ReleaseComponent(TRecorderVisualComponent(fChildren[0]));
  fChildren.Free;
  inherited Destroy;
end;

function TRecorderComponentFactoryBase.GetChild(
  AIndex: Integer): TRecorderVisualComponent;
begin
  Result := TRecorderVisualComponent(fChildren[AIndex]);
end;

function TRecorderComponentFactoryBase.GetChildCount: Integer;
begin
  Result := fChildren.Count;
end;

procedure TRecorderComponentFactoryBase.ExcludeComponent(
  AComponent: TRecorderVisualComponent);
begin
  fChildren.Remove(AComponent);
  if (AComponent <> nil) and (AComponent.fFactory = Self) then
    AComponent.fFactory := nil;
end;

function TRecorderComponentFactoryBase.CreateComponent: TRecorderVisualComponent;
begin
  Result := fComponentClass.Create;
  try
    Result.fFactory := Self;
    Result.SetBounds(0, 0, fDefaultWidth, fDefaultHeight);
    fChildren.Add(Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TRecorderComponentFactoryBase.ReleaseComponent(
  AComponent: TRecorderVisualComponent);
begin
  if AComponent = nil then
    Exit;

  if AComponent.fFactory <> Self then
    raise ERecorderFormError.Create('Component belongs to another factory');

  ExcludeComponent(AComponent);
  AComponent.Free;
end;

function TRecorderComponentFactoryBase.ContainsComponent(
  AComponent: TRecorderVisualComponent): Boolean;
begin
  Result := fChildren.IndexOf(AComponent) >= 0;
end;

{ TRecorderStaticTextFactory }

constructor TRecorderStaticTextFactory.Create;
begin
  inherited Create(TRecorderStaticTextComponent.TypeId, 'Static text',
    TRecorderStaticTextComponent, 160, 24, False);
end;

{ TRecorderTagValueFactory }

constructor TRecorderTagValueFactory.Create;
begin
  inherited Create(TRecorderTagValueComponent.TypeId, 'Tag value',
    TRecorderTagValueComponent, 160, 24, True);
end;

{ TRecorderOscillogramFactory }

constructor TRecorderOscillogramFactory.Create;
begin
  inherited Create(TRecorderOscillogramComponent.TypeId, 'Oscillogram',
    TRecorderOscillogramComponent, 360, 220, True);
end;


{ TRecorderTrendFactory }

constructor TRecorderTrendFactory.Create;
begin
  inherited Create(TRecorderTrendComponent.TypeId, 'Trend',
    TRecorderTrendComponent, 400, 300, False);
end;

{ TRecorderFormPage }

constructor TRecorderFormPage.Create(const AId, AName, ATitle: string);
begin
  inherited Create;
  fComponents := TList.Create;
  fId := AId;
  fName := AName;
  fTitle := ATitle;
  fMode := fpmView;
  fBaseOscillogramCount := 2;
end;

destructor TRecorderFormPage.Destroy;
begin
  while fComponents.Count > 0 do
    DeleteComponent(0);
  fComponents.Free;
  inherited Destroy;
end;

procedure TRecorderFormPage.ReleaseComponent(AComponent: TRecorderVisualComponent);
begin
  if AComponent = nil then
    Exit;

  if AComponent.Factory <> nil then
    AComponent.Factory.ReleaseComponent(AComponent)
  else
    AComponent.Free;
end;

function TRecorderFormPage.GetComponent(AIndex: Integer): TRecorderVisualComponent;
begin
  Result := TRecorderVisualComponent(fComponents[AIndex]);
end;

function TRecorderFormPage.GetComponentCount: Integer;
begin
  Result := fComponents.Count;
end;

function TRecorderFormPage.AddComponent(
  AComponent: TRecorderVisualComponent): TRecorderVisualComponent;
begin
  if AComponent = nil then
    raise ERecorderFormError.Create('Cannot add nil component');

  if (AComponent.Id <> '') and (FindComponentById(AComponent.Id) <> nil) then
    raise ERecorderFormError.CreateFmt('Component id already exists: %s',
      [AComponent.Id]);

  fComponents.Add(AComponent);
  Result := AComponent;
end;

function TRecorderFormPage.FindComponentById(
  const AId: string): TRecorderVisualComponent;
var
  I: Integer;
  lComponent: TRecorderVisualComponent;
begin
  Result := nil;
  for I := 0 to fComponents.Count - 1 do
  begin
    lComponent := TRecorderVisualComponent(fComponents[I]);
    if SameText(lComponent.Id, AId) then
      Exit(lComponent);
  end;
end;

function TRecorderFormPage.RemoveComponentById(const AId: string): Boolean;
var
  I: Integer;
  lComponent: TRecorderVisualComponent;
begin
  Result := False;
  for I := 0 to fComponents.Count - 1 do
  begin
    lComponent := TRecorderVisualComponent(fComponents[I]);
    if SameText(lComponent.Id, AId) then
    begin
      fComponents.Delete(I);
      ReleaseComponent(lComponent);
      Exit(True);
    end;
  end;
end;

procedure TRecorderFormPage.DeleteComponent(AIndex: Integer);
var
  lComponent: TRecorderVisualComponent;
begin
  if (AIndex < 0) or (AIndex >= fComponents.Count) then
    raise ERecorderFormError.CreateFmt('Component index out of range: %d',
      [AIndex]);

  lComponent := TRecorderVisualComponent(fComponents[AIndex]);
  fComponents.Delete(AIndex);
  ReleaseComponent(lComponent);
end;

{ TRecorderFormManager }

constructor TRecorderFormManager.Create;
begin
  inherited Create;
  fPages := TList.Create;
end;

destructor TRecorderFormManager.Destroy;
var
  I: Integer;
begin
  for I := 0 to fPages.Count - 1 do
    TObject(fPages[I]).Free;
  fPages.Free;
  inherited Destroy;
end;

function TRecorderFormManager.GetPage(AIndex: Integer): TRecorderFormPage;
begin
  Result := TRecorderFormPage(fPages[AIndex]);
end;

function TRecorderFormManager.GetPageCount: Integer;
begin
  Result := fPages.Count;
end;

function TRecorderFormManager.AddPage(APage: TRecorderFormPage): TRecorderFormPage;
begin
  if APage = nil then
    raise ERecorderFormError.Create('Cannot add nil page');

  if (APage.Id <> '') and (FindPageById(APage.Id) <> nil) then
    raise ERecorderFormError.CreateFmt('Page id already exists: %s', [APage.Id]);

  fPages.Add(APage);
  if fActivePage = nil then
    fActivePage := APage;

  Result := APage;
end;

function TRecorderFormManager.FindPageById(const AId: string): TRecorderFormPage;
var
  I: Integer;
  lPage: TRecorderFormPage;
begin
  Result := nil;
  for I := 0 to fPages.Count - 1 do
  begin
    lPage := TRecorderFormPage(fPages[I]);
    if SameText(lPage.Id, AId) then
      Exit(lPage);
  end;
end;

function TRecorderFormManager.IndexOfPageId(const AId: string): Integer;
var
  I: Integer;
  lPage: TRecorderFormPage;
begin
  Result := -1;
  for I := 0 to fPages.Count - 1 do
  begin
    lPage := TRecorderFormPage(fPages[I]);
    if SameText(lPage.Id, AId) then
      Exit(I);
  end;
end;

function TRecorderFormManager.RemovePageById(const AId: string): Boolean;
var
  I: Integer;
  lPage: TRecorderFormPage;
begin
  Result := False;
  for I := 0 to fPages.Count - 1 do
  begin
    lPage := TRecorderFormPage(fPages[I]);
    if SameText(lPage.Id, AId) then
    begin
      fPages.Delete(I);
      if fActivePage = lPage then
      begin
        if fPages.Count > 0 then
          fActivePage := TRecorderFormPage(fPages[0])
        else
          fActivePage := nil;
      end;
      lPage.Free;
      Exit(True);
    end;
  end;
end;

procedure TRecorderFormManager.MovePage(AFromIndex, AToIndex: Integer);
begin
  if (AFromIndex < 0) or (AFromIndex >= fPages.Count) then
    raise ERecorderFormError.CreateFmt('Page index out of range: %d',
      [AFromIndex]);
  if (AToIndex < 0) or (AToIndex >= fPages.Count) then
    raise ERecorderFormError.CreateFmt('Target page index out of range: %d',
      [AToIndex]);

  if AFromIndex <> AToIndex then
    fPages.Move(AFromIndex, AToIndex);
end;

procedure TRecorderFormManager.SetActivePageById(const AId: string);
var
  lPage: TRecorderFormPage;
begin
  lPage := FindPageById(AId);
  if lPage = nil then
    raise ERecorderFormError.CreateFmt('Page not found: %s', [AId]);

  fActivePage := lPage;
end;

function TRecorderFormManager.TrySetActivePageById(const AId: string): Boolean;
var
  lPage: TRecorderFormPage;
begin
  lPage := FindPageById(AId);
  Result := lPage <> nil;
  if Result then
    fActivePage := lPage;
end;

procedure TRecorderFormManager.Clear;
var
  I: Integer;
begin
  for I := 0 to fPages.Count - 1 do
    TObject(fPages[I]).Free;
  fPages.Clear;
  fActivePage := nil;
end;

{ TRecorderComponentFactory }

constructor TRecorderComponentFactory.Create;
begin
  inherited Create;
  fRegistry := TStringList.Create;
  fRegistry.CaseSensitive := False;
  fRegistry.Sorted := True;
  fRegistry.Duplicates := dupError;
end;

destructor TRecorderComponentFactory.Destroy;
var
  I: Integer;
begin
  for I := 0 to fRegistry.Count - 1 do
    fRegistry.Objects[I].Free;
  fRegistry.Free;
  inherited Destroy;
end;

function TRecorderComponentFactory.GetFactory(
  AIndex: Integer): TRecorderComponentFactoryBase;
begin
  Result := TRecorderComponentFactoryBase(fRegistry.Objects[AIndex]);
end;

function TRecorderComponentFactory.GetFactoryCount: Integer;
begin
  Result := fRegistry.Count;
end;

procedure TRecorderComponentFactory.RegisterComponent(const ATypeId: string;
  AComponentClass: TRecorderVisualComponentClass);
begin
  RegisterFactory(TRecorderComponentFactoryBase.Create(ATypeId, ATypeId,
    AComponentClass, 0, 0, False));
end;

procedure TRecorderComponentFactory.RegisterFactory(
  AFactory: TRecorderComponentFactoryBase);
begin
  if AFactory = nil then
    raise ERecorderFormError.Create('Component factory cannot be nil');

  if fRegistry.IndexOf(AFactory.TypeId) >= 0 then
    raise ERecorderFormError.CreateFmt('Component factory already registered: %s',
      [AFactory.TypeId]);

  fRegistry.AddObject(AFactory.TypeId, AFactory);
end;

function TRecorderComponentFactory.CreateComponent(
  const ATypeId: string): TRecorderVisualComponent;
var
  lFactory: TRecorderComponentFactoryBase;
begin
  lFactory := FindFactory(ATypeId);
  if lFactory = nil then
    raise ERecorderFormError.CreateFmt('Unknown component type: %s', [ATypeId]);

  Result := lFactory.CreateComponent;
end;

function TRecorderComponentFactory.IsComponentRegistered(
  const ATypeId: string): Boolean;
begin
  Result := FindFactory(ATypeId) <> nil;
end;

function TRecorderComponentFactory.FindFactory(
  const ATypeId: string): TRecorderComponentFactoryBase;
var
  lIndex: Integer;
begin
  lIndex := fRegistry.IndexOf(ATypeId);
  if lIndex >= 0 then
    Result := TRecorderComponentFactoryBase(fRegistry.Objects[lIndex])
  else
    Result := nil;
end;

procedure TRecorderComponentFactory.RegisterDefaultComponents;
begin
  RegisterFactory(TRecorderStaticTextFactory.Create);
  RegisterFactory(TRecorderTagValueFactory.Create);
  RegisterFactory(TRecorderOscillogramFactory.Create);
  RegisterFactory(TRecorderTrendFactory.Create);
  RegisterFactory(TRecorderSpectrumFactory.Create);
end;

{ TRecorderFormFactory }

constructor TRecorderFormFactory.Create(AComponentFactory: TRecorderComponentFactory);
begin
  inherited Create;
  if AComponentFactory = nil then
    raise ERecorderFormError.Create('Component factory cannot be nil');

  fComponentFactory := AComponentFactory;
end;

function TRecorderFormFactory.CreateBlankPage(const AId, AName,
  ATitle: string): TRecorderFormPage;
begin
  Result := TRecorderFormPage.Create(AId, AName, ATitle);
end;

function TRecorderFormFactory.CreateDebugTagPage(const AId, AName, ATitle,
  ATagName: string): TRecorderFormPage;
var
  lCaption: TRecorderStaticTextComponent;
  lTagValue: TRecorderTagValueComponent;
begin
  Result := CreateBlankPage(AId, AName, ATitle);
  try
    lCaption := TRecorderStaticTextComponent(
      fComponentFactory.CreateComponent(TRecorderStaticTextComponent.TypeId));
    lCaption.Id := AId + '.caption';
    lCaption.Name := 'Caption';
    lCaption.Text := ATitle;
    lCaption.SetBounds(8, 8, 180, 24);
    Result.AddComponent(lCaption);

    lTagValue := TRecorderTagValueComponent(
      fComponentFactory.CreateComponent(TRecorderTagValueComponent.TypeId));
    lTagValue.Id := AId + '.tag-value';
    lTagValue.Name := 'TagValue';
    lTagValue.TagName := ATagName;
    lTagValue.SetBounds(8, 40, 180, 24);
    Result.AddComponent(lTagValue);
  except
    Result.Free;
    raise;
  end;
end;

end.
