unit uRecorderFormModel;

{
  Модуль uRecorderFormModel

  Назначение:
    Доменная модель экранных формуляров RecorderLnx. Модуль описывает страницы,
    модельные визуальные компоненты и фабрики создания страниц/компонентов.

  Место в архитектуре:
    Core/domain. Модуль не зависит от LCL и не создает реальные TControl. UI-слой
    позже будет читать эту модель и строить LCL/Canvas/OpenGL-представление.

  Ограничения первой версии:
    Здесь нет сохранения/загрузки, редактирования мышью, layout engine и подписки на
    теги. Эти задачи добавляются следующими слоями после проверки базовой модели.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRecorderTags;

type
  { TRecorderRect
    Прямоугольник компонента на формуляре в логических пикселях страницы.
    
    Left   - координата левого края.
    Top    - координата верхнего края.
    Width  - ширина компонента.
    Height - высота компонента. }
  TRecorderRect = record
    Left: Integer;
    Top: Integer;
    Width: Integer;
    Height: Integer;
  end;
{ TRecorderFormPageMode
    Режим страницы формуляра.
    
    fpmView - страница отображает данные и не меняет состав компонентов.
    fpmEdit - страница находится в режиме настройки состава/положения компонентов. }
  TRecorderFormPageMode = (
    fpmView,
    fpmEdit
  );

  { Исключение при ошибках модели форм }
  ERecorderFormError = class(Exception);

  TRecorderComponentFactoryBase = class;
  TRecorderVisualComponent = class;
  TRecorderVisualComponentClass = class of TRecorderVisualComponent;

  { TRecorderTagBindingMode
    Режим выбора тега для компонентов, которые могут следовать за текущим
    выбором канала в ядре Recorder. }
  TRecorderTagBindingMode = (
    rtbmRelativeSelectedTag,
    rtbmAbsoluteTag
  );

  { TRecorderVisualComponent
    Базовый модельный компонент формуляра. Компонент хранит только идентичность,
    геометрию и привязку к тегу; отрисовка выполняется отдельным UI-адаптером. }
  TRecorderVisualComponent = class
  private
    fBounds: TRecorderRect;                        { Границы и размеры компонента }
    fFactory: TRecorderComponentFactoryBase;       { Фабрика, создавшая этот компонент }
    fId: string;                                   { Уникальный ID компонента на странице }
    fName: string;                                 { Имя компонента }
    fTagName: string;                              { Имя привязанного тега }
  protected
    { Возвращает стабильный строковый тип компонента для фабрики и будущей
      сериализации. }
    class function GetTypeId: string; virtual;
  public
    { Создает компонент с пустой геометрией и без привязки к тегу. }
    constructor Create; virtual;
    { Деструктор извещает фабрику об удалении компонента }
    destructor Destroy; override;

    { Устанавливает прямоугольник компонента.
      ALeft, ATop - позиция компонента на странице.
      AWidth, AHeight - размер компонента; отрицательные значения запрещены. }
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);

    { Возвращает стабильный строковый тип компонента. }
    class function TypeId: string;

    property Id: string read fId write fId;
    property Name: string read fName write fName;
    property TagName: string read fTagName write fTagName;
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

  { TRecorderOscillogramComponent
    Модель осциллограммы на редактируемой мнемосхеме. По умолчанию привязка
    относительная: компонент показывает выбранный в Recorder тег плюс смещение. }
  TRecorderOscillogramComponent = class(TRecorderVisualComponent)
  private
    fBindingMode: TRecorderTagBindingMode;
    fTagOffset: Integer;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    property BindingMode: TRecorderTagBindingMode read fBindingMode
      write fBindingMode;
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

  TRecorderTrendLine = class
  private
    fAxisIndex: Integer;
    fColor: LongInt;
    fEstimateKind: TRecorderTagEstimateKind;
    fName: string;
    fTagName: string;
    fVisible: Boolean;
    fWidth: Integer;
  public
    constructor Create;
    procedure Assign(ASource: TRecorderTrendLine);
    property Name: string read fName write fName;
    property TagName: string read fTagName write fTagName;
    property EstimateKind: TRecorderTagEstimateKind read fEstimateKind
      write fEstimateKind;
    property AxisIndex: Integer read fAxisIndex write fAxisIndex;
    property Color: LongInt read fColor write fColor;
    property Width: Integer read fWidth write fWidth;
    property Visible: Boolean read fVisible write fVisible;
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
    fTahoTagName: string;
    fProfileName: string;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(ASource: TRecorderSpectrumComponent);
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
    property ProfileName: string read fProfileName write fProfileName;
  end;  { TRecorderComponentFactoryBase
    Фабрика одного типа модельных компонентов. Она создает компоненты и ведет
    реестр своих дочерних экземпляров, чтобы удаление формы/компонента не
    оставляло у фабрики устаревшие ссылки. }
  TRecorderComponentFactoryBase = class
  private
    fChildren: TList;                              { Список созданных компонентов (TRecorderVisualComponent) }
    fComponentClass: TRecorderVisualComponentClass;{ Ссылка на класс компонента }
    fDefaultHeight: Integer;                       { Высота компонента по умолчанию }
    fDefaultWidth: Integer;                        { Ширина компонента по умолчанию }
    fSingleTag: Boolean;                           { Флаг привязки к одному тегу }
    fTypeId: string;                               { Уникальный ID типа }
    fTypeName: string;                             { Человекочитаемое имя типа }
    function GetChild(AIndex: Integer): TRecorderVisualComponent;
    function GetChildCount: Integer;
  protected
    { Убирает компонент из реестра детей без освобождения памяти. }
    procedure ExcludeComponent(AComponent: TRecorderVisualComponent);
  public
    { Конструктор фабрики компонентов
      ATypeId - стабильный id типа для конфигов.
      ATypeName - человекочитаемое название для UI.
      AComponentClass - класс модельного компонента.
      ADefaultWidth/ADefaultHeight - размер нового компонента по умолчанию.
      ASingleTag - признак, что компонент обычно привязан к одному тегу. }
    constructor Create(const ATypeId, ATypeName: string;
      AComponentClass: TRecorderVisualComponentClass;
      ADefaultWidth, ADefaultHeight: Integer; ASingleTag: Boolean); virtual;
    { Деструктор освобождает все дочерние компоненты }
    destructor Destroy; override;

    { Создает компонент и добавляет его в реестр детей фабрики. }
    function CreateComponent: TRecorderVisualComponent; virtual;

    { Удаляет компонент, ранее созданный этой фабрикой. }
    procedure ReleaseComponent(AComponent: TRecorderVisualComponent); virtual;

    { Проверяет, что компонент все еще числится дочерним экземпляром фабрики. }
    function ContainsComponent(AComponent: TRecorderVisualComponent): Boolean;

    property TypeId: string read fTypeId;
    property TypeName: string read fTypeName;
    property DefaultWidth: Integer read fDefaultWidth;
    property DefaultHeight: Integer read fDefaultHeight;
    property SingleTag: Boolean read fSingleTag;
    property ChildCount: Integer read GetChildCount;
    property Children[AIndex: Integer]: TRecorderVisualComponent read GetChild;
  end;

  { Фабрика статического текстового компонента }
  TRecorderStaticTextFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create; reintroduce;
  end;

  { Фабрика компонента отображения тега }
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
    Одна экранная страница Recorder: имя, заголовок, режим и список модельных
    компонентов. Страница владеет добавленными компонентами. }
  TRecorderFormPage = class
  private
    fComponents: TList;                            { Список компонентов на странице (TRecorderVisualComponent) }
    fBaseOscillogramCount: Integer;                { Количество графиков для встроенной BasePage }
    fId: string;                                   { Уникальный ID страницы }
    fMode: TRecorderFormPageMode;                  { Текущий режим (просмотр/редактирование) }
    fName: string;                                 { Внутреннее имя страницы }
    fTitle: string;                                { Заголовок страницы }
    procedure ReleaseComponent(AComponent: TRecorderVisualComponent);
    function GetComponent(AIndex: Integer): TRecorderVisualComponent;
    function GetComponentCount: Integer;
  public
    { Создает пустую страницу.
      AId - стабильный идентификатор страницы.
      AName - внутреннее имя страницы.
      ATitle - заголовок для UI. }
    constructor Create(const AId, AName, ATitle: string);
    { Деструктор удаляет все компоненты со страницы }
    destructor Destroy; override;

    { Добавляет компонент на страницу и передает владение странице.
      AComponent - компонент, созданный фабрикой или кодом настройки. }
    function AddComponent(AComponent: TRecorderVisualComponent): TRecorderVisualComponent;

    { Находит компонент по Id. Возвращает nil, если компонент не найден. }
    function FindComponentById(const AId: string): TRecorderVisualComponent;

    { Удаляет компонент по Id.
      AId - идентификатор компонента. }
    function RemoveComponentById(const AId: string): Boolean;

    { Удаляет компонент по индексу в списке страницы.
      AIndex - индекс компонента от 0 до ComponentCount - 1. }
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
    Реестр страниц формуляров. Менеджер владеет страницами и хранит активную
    страницу, которую должен отображать UI. }
  TRecorderFormManager = class
  private
    fActivePage: TRecorderFormPage;                { Текущая активная страница }
    fPages: TList;                                 { Список страниц (TRecorderFormPage) }
    function GetPage(AIndex: Integer): TRecorderFormPage;
    function GetPageCount: Integer;
  public
    { Конструктор менеджера страниц }
    constructor Create;
    { Деструктор очищает и удаляет все страницы }
    destructor Destroy; override;

    { Добавляет страницу и передает владение менеджеру. Первая добавленная
      страница автоматически становится активной. }
    function AddPage(APage: TRecorderFormPage): TRecorderFormPage;

    { Находит страницу по Id. Возвращает nil, если страница не найдена. }
    function FindPageById(const AId: string): TRecorderFormPage;

    { Возвращает индекс страницы по Id или -1, если страница не найдена. }
    function IndexOfPageId(const AId: string): Integer;

    { Удаляет страницу по Id.
      AId - идентификатор страницы. }
    function RemovePageById(const AId: string): Boolean;

    { Перемещает страницу внутри списка.
      AFromIndex - текущий индекс страницы.
      AToIndex - новый индекс страницы. }
    procedure MovePage(AFromIndex, AToIndex: Integer);

    { Делает страницу с заданным Id активной.
      AId - идентификатор страницы. }
    procedure SetActivePageById(const AId: string);

    { Пробует сделать страницу с заданным Id активной без исключения.
      AId - идентификатор страницы. }
    function TrySetActivePageById(const AId: string): Boolean;

    { Удаляет все страницы и сбрасывает активную страницу. }
    procedure Clear;

    property ActivePage: TRecorderFormPage read fActivePage;
    property PageCount: Integer read GetPageCount;
    property Pages[AIndex: Integer]: TRecorderFormPage read GetPage;
  end;

  { TRecorderComponentFactory
    Фабрика модельных компонентов. Хранит соответствие TypeId -> class и создает
    компоненты без знания конкретного класса вызывающим кодом. }
  TRecorderComponentFactory = class
  private
    fRegistry: TStringList;                        { Список зарегистрированных фабрик }
    function GetFactory(AIndex: Integer): TRecorderComponentFactoryBase;
    function GetFactoryCount: Integer;
  public
    { Конструктор инициализирует внутренний реестр }
    constructor Create;
    { Деструктор освобождает все зарегистрированные фабрики }
    destructor Destroy; override;

    { Регистрирует класс компонента.
      ATypeId - стабильное имя типа, например StaticText или TagValue.
      AComponentClass - класс, наследник TRecorderVisualComponent. }
    procedure RegisterComponent(const ATypeId: string;
      AComponentClass: TRecorderVisualComponentClass);

    { Регистрирует фабрику компонентов одного типа.
      AFactory - экземпляр фабрики; менеджер принимает владение. }
    procedure RegisterFactory(AFactory: TRecorderComponentFactoryBase);

    { Создает компонент зарегистрированного типа.
      ATypeId - строковый тип компонента. }
    function CreateComponent(const ATypeId: string): TRecorderVisualComponent;

    { Проверяет, зарегистрирован ли тип компонента. }
    function IsComponentRegistered(const ATypeId: string): Boolean;

    { Находит фабрику по TypeId. Возвращает nil, если тип не зарегистрирован. }
    function FindFactory(const ATypeId: string): TRecorderComponentFactoryBase;

    { Регистрирует базовый набор компонентов первой версии. }
    procedure RegisterDefaultComponents;

    property FactoryCount: Integer read GetFactoryCount;
    property Factories[AIndex: Integer]: TRecorderComponentFactoryBase read GetFactory;
  end;

  { TRecorderFormFactory
    Фабрика страниц. Отделена от менеджера, чтобы позже здесь появились шаблоны,
    загрузка из конфигурации и создание страниц плагинами. }
  TRecorderFormFactory = class
  private
    fComponentFactory: TRecorderComponentFactory;  { Ссылка на фабрику компонентов }
  public
    { AComponentFactory - фабрика компонентов; объект не передается во владение. }
    constructor Create(AComponentFactory: TRecorderComponentFactory);

    { Создает пустую страницу формуляра. }
    function CreateBlankPage(const AId, AName, ATitle: string): TRecorderFormPage;

    { Создает демонстрационную страницу с подписью и компонентом значения тега. }
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
end;


{ TRecorderTrendAxis }

constructor TRecorderTrendAxis.Create;
begin
  inherited Create;
  fName := 'Y';
  fColor := $0000FF;
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
  fEstimateKind := tekMean;
  fAxisIndex := 0;
  fColor := $0000FF;
  fWidth := 1;
  fVisible := True;
end;

procedure TRecorderTrendLine.Assign(ASource: TRecorderTrendLine);
begin
  if ASource = nil then
    Exit;
  fName := ASource.Name;
  fTagName := ASource.TagName;
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
begin
  Result := TRecorderTrendLine.Create;
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
  fTagNames.Sorted := True;
  fTagNames.Duplicates := dupIgnore;
  
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
  fProfileName := ASource.ProfileName;
  fTagNames.Assign(ASource.TagNames);
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
