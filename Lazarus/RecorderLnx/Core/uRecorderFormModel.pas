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
  TRecorderFontSnapshot = record
    Name: string;
    Size: Integer;
    Color: LongInt;
    Bold: Boolean;
    Italic: Boolean;
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
  TRecorderFormPage = class;
  TRecorderNamedFont = class;
  TRecorderNamedFontManager = class;
  TRecorderVisualComponent = class;
  TRecorderVisualComponentClass = class of TRecorderVisualComponent;

  TRecorderComponentCreateContext = record
    Page: TRecorderFormPage;
    SelectedTag: TRecorderTag;
    DefaultTag: TRecorderTag;
    ProjectConfigDir: string;
    ComponentNo: Integer;
  end;

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
    fNamedFontName: string;
    fNamedFonts: TRecorderNamedFontManager;
    fResolvedNamedFont: TRecorderNamedFont;
    fResolvedFontRevision: QWord;
    procedure SetNamedFontName(const AValue: string);
  protected
    { Возвращает строковый идентификатор типа для сериализации и палитры
      редактора. }
    class function GetTypeId: string; virtual;
    function ResolveNamedFont: TRecorderNamedFont;
  public
    { Создаёт компонент с нулевыми размерами и пустым именем. }
    constructor Create; virtual;
    { Освобождает ресурсы базового компонента }
    destructor Destroy; override;

    { Устанавливает геопрямоугольник компонента.
      ALeft, ATop - координаты левого верхнего угла.
      AWidth, AHeight - размеры прямоугольника; отрицательные значения запрещены. }
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
    procedure GetEffectiveFont(const ALocal: TRecorderFontSnapshot;
      out AResult: TRecorderFontSnapshot);

    { Возвращает идентификатор типа для фабрики. }
    class function TypeId: string;

    property Id: string read fId write fId;
    property Name: string read fName write fName;
    property TagName: string read fTagName write fTagName;
    property TagId: TRecorderTagId read fTagId write fTagId;
    property Bounds: TRecorderRect read fBounds write fBounds;
    property Factory: TRecorderComponentFactoryBase read fFactory;
    property NamedFontName: string read fNamedFontName write SetNamedFontName;
    property NamedFonts: TRecorderNamedFontManager read fNamedFonts;
  end;

  TRecorderNamedFont = class
  public
    Name: string;
    FontName: string;
    FontSize: Integer;
    FontColor: LongInt;
    Bold: Boolean;
    Italic: Boolean;
  end;

  TRecorderNamedFontManager = class
  private
    fItems: TStringList;
    fRevision: QWord;
    function GetCount: Integer;
    function GetItem(AIndex: Integer): TRecorderNamedFont;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Find(const AName: string): TRecorderNamedFont;
    function Define(const AName, AFontName: string; AFontSize: Integer;
      AFontColor: LongInt; ABold, AItalic: Boolean): TRecorderNamedFont;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TRecorderNamedFont read GetItem;
    property Revision: QWord read fRevision;
  end;

  TRecorderTagValueNameMode = (tvnmNone, tvnmTop, tvnmLeft);
  TRecorderButtonBehavior = (rbbToggle, rbbHold, rbbPulse);

  TRecorderStaticTextComponent = class(TRecorderVisualComponent)
  private
    fText: string;
    fFontName: string;
    fFontSize: Integer;
    fFontColor: LongInt;
    fFontStyleBold: Boolean;
    fFontStyleItalic: Boolean;
    function GetFontName: string;
    function GetFontSize: Integer;
    function GetFontColor: LongInt;
    function GetFontStyleBold: Boolean;
    function GetFontStyleItalic: Boolean;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    procedure GetFontSnapshot(out AFont: TRecorderFontSnapshot);
    property Text: string read fText write fText;
    property FontName: string read GetFontName write fFontName;
    property FontSize: Integer read GetFontSize write fFontSize;
    property FontColor: LongInt read GetFontColor write fFontColor;
    property FontStyleBold: Boolean read GetFontStyleBold write fFontStyleBold;
    property FontStyleItalic: Boolean read GetFontStyleItalic write fFontStyleItalic;
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
    function GetFontName: string;
    function GetFontSize: Integer;
    function GetFontColor: LongInt;
    function GetFontStyleBold: Boolean;
    function GetFontStyleItalic: Boolean;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    procedure GetFontSnapshot(out AFont: TRecorderFontSnapshot);
    property DisplayFormat: string read fDisplayFormat write fDisplayFormat;
    property FontName: string read GetFontName write fFontName;
    property FontSize: Integer read GetFontSize write fFontSize;
    property FontColor: LongInt read GetFontColor write fFontColor;
    property FontStyleBold: Boolean read GetFontStyleBold write fFontStyleBold;
    property FontStyleItalic: Boolean read GetFontStyleItalic write fFontStyleItalic;
    property ShowNameMode: TRecorderTagValueNameMode read fShowNameMode write fShowNameMode;
    property EstimateKind: TRecorderTagEstimateKind read fEstimateKind write fEstimateKind;
    property UseDefaultEstimate: Boolean read fUseDefaultEstimate write fUseDefaultEstimate;
  end;

  TRecorderButtonComponent = class(TRecorderVisualComponent)
  private
    fCaption: string;
    fBehavior: TRecorderButtonBehavior;
    fPressedValue: Double;
    fReleasedValue: Double;
    fPulseDurationMs: Integer;
    fPressedImageFileName: string;
    fReleasedImageFileName: string;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    property Caption: string read fCaption write fCaption;
    property Behavior: TRecorderButtonBehavior read fBehavior write fBehavior;
    property PressedValue: Double read fPressedValue write fPressedValue;
    property ReleasedValue: Double read fReleasedValue write fReleasedValue;
    property PulseDurationMs: Integer read fPulseDurationMs write fPulseDurationMs;
    property PressedImageFileName: string read fPressedImageFileName write fPressedImageFileName;
    property ReleasedImageFileName: string read fReleasedImageFileName write fReleasedImageFileName;
  end;

  TRecorderInputFieldComponent = class(TRecorderVisualComponent)
  private
    fDisplayFormat: string;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    property DisplayFormat: string read fDisplayFormat write fDisplayFormat;
  end;

  { Картинка на мнемосхеме. Каждая строка Images хранится как
    "значение тега=имя файла". Если тег не задан, всегда используется
    первая строка списка. }
  TRecorderImageComponent = class(TRecorderVisualComponent)
  private
    fImages: TStringList;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AssignImage(ASource: TRecorderImageComponent);
    property Images: TStringList read fImages;
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
  TRecorderTrendAxis = class;

  TRecorderOscillogramComponent = class(TRecorderVisualComponent)
  private
    fAxes: TList;
    fBindingMode: TRecorderTagBindingMode;
    fClosedInput: Boolean;
    fAutoRangeEnabled: Boolean;
    fXCursorEnabled: Boolean;
    fXCursorCount: Integer;
    fLegendVisible: Boolean;
    fLevelCursorVisible: Boolean;
    fLines: TList;
    fPrimaryAxisIndex: Integer;
    fTagOffset: Integer;
    fXScale: Double;
    fYScale: Double;
    fYOffset: Double;
    fTriggerTagName: string;
    fTriggerEnabled: Boolean;
    fTriggerLevel: Double;
    fTriggerPreRollPercent: Double;
    function GetLine(AIndex: Integer): TRecorderTrendLine;
    function GetLineCount: Integer;
    function GetAxis(AIndex: Integer): TRecorderTrendAxis;
    function GetAxisCount: Integer;
    function GetYScale: Double;
    function GetYOffset: Double;
    procedure SetYScale(AValue: Double);
    procedure SetYOffset(AValue: Double);
    procedure SetTriggerPreRollPercent(AValue: Double);
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function AddLine: TRecorderTrendLine;
    function AddAxis: TRecorderTrendAxis;
    procedure AssignOscillogram(ASource: TRecorderOscillogramComponent);
    procedure ClearAxes;
    procedure ClearLines;
    procedure DeleteLine(AIndex: Integer);
    property BindingMode: TRecorderTagBindingMode read fBindingMode
      write fBindingMode;
    property AxisCount: Integer read GetAxisCount;
    property Axes[AIndex: Integer]: TRecorderTrendAxis read GetAxis;
    property PrimaryAxisIndex: Integer read fPrimaryAxisIndex
      write fPrimaryAxisIndex;
    property ClosedInput: Boolean read fClosedInput write fClosedInput;
    property AutoRangeEnabled: Boolean read fAutoRangeEnabled write fAutoRangeEnabled;
    property XCursorEnabled: Boolean read fXCursorEnabled write fXCursorEnabled;
    property XCursorCount: Integer read fXCursorCount write fXCursorCount;
    property LegendVisible: Boolean read fLegendVisible write fLegendVisible;
    property LevelCursorVisible: Boolean read fLevelCursorVisible write fLevelCursorVisible;
    property LineCount: Integer read GetLineCount;
    property Lines[AIndex: Integer]: TRecorderTrendLine read GetLine;
    property TagOffset: Integer read fTagOffset write fTagOffset;
    property XScale: Double read fXScale write fXScale;
    property YScale: Double read GetYScale write SetYScale;
    property YOffset: Double read GetYOffset write SetYOffset;
    property TriggerTagName: string read fTriggerTagName write fTriggerTagName;
    property TriggerEnabled: Boolean read fTriggerEnabled write fTriggerEnabled;
    property TriggerLevel: Double read fTriggerLevel write fTriggerLevel;
    property TriggerPreRollPercent: Double read fTriggerPreRollPercent
      write SetTriggerPreRollPercent;
  end;


  TRecorderTrendAxis = class
  private
    fColor: LongInt;
    fName: string;
    fRangeMax: Double;
    fRangeMin: Double;
    fYScale: Double;
    fYOffset: Double;
  public
    constructor Create;
    procedure Assign(ASource: TRecorderTrendAxis);
    property Name: string read fName write fName;
    property Color: LongInt read fColor write fColor;
    property RangeMin: Double read fRangeMin write fRangeMin;
    property RangeMax: Double read fRangeMax write fRangeMax;
    property YScale: Double read fYScale write fYScale;
    property YOffset: Double read fYOffset write fYOffset;
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

  TRecorderPalettePlacement = (rppHidden, rppStandalone, rppGroup);

const
  CRecorderPaletteGroupCharts = 'charts';
  CRecorderPaletteGroupIndicators = 'indicators';

type
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
    fPaletteCaption: string;
    fPaletteHint: string;
    fPaletteIconId: string;
    fPaletteOrder: Integer;
    fPalettePlacement: TRecorderPalettePlacement;
    fPaletteGroupId: string;
    function GetChild(AIndex: Integer): TRecorderVisualComponent;
    function GetChildCount: Integer;
  protected
    { Убирает компонент из списка детей при уничтожении объекта. }
    procedure ExcludeComponent(AComponent: TRecorderVisualComponent);
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); virtual;
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
    function CreateComponentForPage(
      const AContext: TRecorderComponentCreateContext): TRecorderVisualComponent; virtual;

    { Удаляет компонент, когда уничтожает сам объект. }
    procedure ReleaseComponent(AComponent: TRecorderVisualComponent); virtual;

    { Проверяет, что компонент всё ещё числится среди созданных фабрикой. }
    function ContainsComponent(AComponent: TRecorderVisualComponent): Boolean;

    { Объявляет, как фабрика представлена в палитре компонентов. Строковый ID
      иконки разрешается UI-слоем и не связывает Core с LCL/ImageList. }
    procedure ConfigurePalette(const ACaption, AHint, AIconId: string;
      AOrder: Integer; APlacement: TRecorderPalettePlacement = rppStandalone;
      const AGroupId: string = '');

    property TypeId: string read fTypeId;
    property TypeName: string read fTypeName;
    property DefaultWidth: Integer read fDefaultWidth;
    property DefaultHeight: Integer read fDefaultHeight;
    property SingleTag: Boolean read fSingleTag;
    property PaletteCaption: string read fPaletteCaption;
    property PaletteHint: string read fPaletteHint;
    property PaletteIconId: string read fPaletteIconId;
    property PaletteOrder: Integer read fPaletteOrder;
    property PalettePlacement: TRecorderPalettePlacement read fPalettePlacement;
    property PaletteGroupId: string read fPaletteGroupId;
    property ChildCount: Integer read GetChildCount;
    property Children[AIndex: Integer]: TRecorderVisualComponent read GetChild;
  end;

  { Фабрика статического текста компонентов }
  TRecorderStaticTextFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create; reintroduce;
  end;

  { Фабрика компонента значения тега }
  TRecorderTagValueFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create; reintroduce;
  end;

  TRecorderDonutComponent = class(TRecorderVisualComponent)
  private
    fTagNames: TStringList;
    fTagIds: array of TRecorderTagId;
    fTitle: string;
    fHolePercent: Integer;
    fSingleValueMode: Boolean;
    fRangeMin: Double;
    fRangeMax: Double;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure AssignDonut(ASource: TRecorderDonutComponent);
    function TagIdAt(AIndex: Integer): TRecorderTagId;
    procedure SetTagIdAt(AIndex: Integer; AId: TRecorderTagId);
    function ResolveTagAt(ARegistry: TRecorderTagRegistry;
      AIndex: Integer): TRecorderTag;
    property TagNames: TStringList read fTagNames;
    property Title: string read fTitle write fTitle;
    property HolePercent: Integer read fHolePercent write fHolePercent;
    property SingleValueMode: Boolean read fSingleValueMode write fSingleValueMode;
    property RangeMin: Double read fRangeMin write fRangeMin;
    property RangeMax: Double read fRangeMax write fRangeMax;
  end;

  TRecorderButtonFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create; reintroduce;
  end;

  TRecorderInputFieldFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create; reintroduce;
  end;

  TRecorderImageFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create;
  end;

  { Фабрика компонента осциллограммы }
  TRecorderOscillogramFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create; reintroduce;
  end;

  TRecorderDonutFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create; reintroduce;
  end;

  TRecorderTrendFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create; reintroduce;
  end;

  TRecorderSpectrumFactory = class(TRecorderComponentFactoryBase)
  protected
    procedure ConfigureNewComponent(AComponent: TRecorderVisualComponent;
      const AContext: TRecorderComponentCreateContext); override;
  public
    constructor Create;
  end;

  { TRecorderFormPage
    Одна страница мнемосхемы Recorder: имя, заголовок, режим и набор визуальных
    компонентов. Компоненты принадлежат странице. }
  TRecorderFormPage = class
  private
    fComponents: TList;                            { список компонентов на странице (TRecorderVisualComponent) }
    fNamedFonts: TRecorderNamedFontManager;
    fBackgroundImageFileName: string;              { файл фонового изображения пользовательской страницы }
    fBackgroundKeepAspect: Boolean;
    fBaseOscillogramCount: Integer;                { количество осциллограмм для встроенной BasePage }
    fDetached: Boolean;                            { страница открыта отдельным окном }
    fDetachedLeft: Integer;                        { экранная координата отдельного окна }
    fDetachedTop: Integer;
    fDetachedWidth: Integer;
    fDetachedHeight: Integer;
    fDetachedMonitor: Integer;                     { индекс монитора для восстановления окна }
    fDetachedMaximized: Boolean;                   { отдельное окно было развёрнуто }
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
    property BackgroundImageFileName: string read fBackgroundImageFileName
      write fBackgroundImageFileName;
    property BackgroundKeepAspect: Boolean read fBackgroundKeepAspect
      write fBackgroundKeepAspect;
    property Mode: TRecorderFormPageMode read fMode write fMode;
    property BaseOscillogramCount: Integer read fBaseOscillogramCount
      write fBaseOscillogramCount;
    property Detached: Boolean read fDetached write fDetached;
    property DetachedLeft: Integer read fDetachedLeft write fDetachedLeft;
    property DetachedTop: Integer read fDetachedTop write fDetachedTop;
    property DetachedWidth: Integer read fDetachedWidth write fDetachedWidth;
    property DetachedHeight: Integer read fDetachedHeight write fDetachedHeight;
    property DetachedMonitor: Integer read fDetachedMonitor write fDetachedMonitor;
    property DetachedMaximized: Boolean read fDetachedMaximized
      write fDetachedMaximized;
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
    fNamedFonts: TRecorderNamedFontManager;
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
    property NamedFonts: TRecorderNamedFontManager read fNamedFonts;
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
  fResolvedFontRevision := High(QWord);
end;

function TRecorderVisualComponent.ResolveNamedFont: TRecorderNamedFont;
begin
  if (fNamedFonts = nil) or (Trim(fNamedFontName) = '') then
    Exit(nil);
  if fResolvedFontRevision <> fNamedFonts.Revision then
  begin
    fResolvedNamedFont := fNamedFonts.Find(fNamedFontName);
    fResolvedFontRevision := fNamedFonts.Revision;
  end;
  Result := fResolvedNamedFont;
end;

procedure TRecorderVisualComponent.SetNamedFontName(const AValue: string);
begin
  if fNamedFontName = Trim(AValue) then
    Exit;
  fNamedFontName := Trim(AValue);
  fResolvedNamedFont := nil;
  fResolvedFontRevision := High(QWord);
end;

procedure TRecorderVisualComponent.GetEffectiveFont(
  const ALocal: TRecorderFontSnapshot; out AResult: TRecorderFontSnapshot);
var
  lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont = nil then
  begin
    AResult := ALocal;
    Exit;
  end;
  AResult.Name := lFont.FontName;
  AResult.Size := lFont.FontSize;
  AResult.Color := lFont.FontColor;
  AResult.Bold := lFont.Bold;
  AResult.Italic := lFont.Italic;
end;

{ TRecorderNamedFontManager }

constructor TRecorderNamedFontManager.Create;
begin
  inherited Create;
  fItems := TStringList.Create;
  fItems.CaseSensitive := False;
  fItems.Sorted := True;
  fItems.Duplicates := dupError;
end;

destructor TRecorderNamedFontManager.Destroy;
begin
  Clear;
  fItems.Free;
  inherited Destroy;
end;

procedure TRecorderNamedFontManager.Clear;
var
  I: Integer;
begin
  for I := 0 to fItems.Count - 1 do
    fItems.Objects[I].Free;
  fItems.Clear;
  Inc(fRevision);
end;

function TRecorderNamedFontManager.GetCount: Integer;
begin
  Result := fItems.Count;
end;

function TRecorderNamedFontManager.GetItem(AIndex: Integer): TRecorderNamedFont;
begin
  Result := TRecorderNamedFont(fItems.Objects[AIndex]);
end;

function TRecorderNamedFontManager.Find(const AName: string): TRecorderNamedFont;
var
  lIndex: Integer;
begin
  lIndex := fItems.IndexOf(Trim(AName));
  if lIndex < 0 then
    Exit(nil);
  Result := TRecorderNamedFont(fItems.Objects[lIndex]);
end;

function TRecorderNamedFontManager.Define(const AName, AFontName: string;
  AFontSize: Integer; AFontColor: LongInt; ABold, AItalic: Boolean): TRecorderNamedFont;
var
  lName: string;
begin
  lName := Trim(AName);
  if lName = '' then
    raise ERecorderFormError.Create('Named font name cannot be empty');
  Result := Find(lName);
  if Result = nil then
  begin
    Result := TRecorderNamedFont.Create;
    Result.Name := lName;
    Result.FontSize := -1;
    fItems.AddObject(lName, Result);
  end;
  if (Result.FontName = AFontName) and (Result.FontSize = AFontSize) and
     (Result.FontColor = AFontColor) and (Result.Bold = ABold) and
     (Result.Italic = AItalic) then
    Exit;
  Result.FontName := AFontName;
  Result.FontSize := AFontSize;
  Result.FontColor := AFontColor;
  Result.Bold := ABold;
  Result.Italic := AItalic;
  Inc(fRevision);
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

procedure TRecorderStaticTextComponent.GetFontSnapshot(
  out AFont: TRecorderFontSnapshot);
var
  lLocal: TRecorderFontSnapshot;
begin
  lLocal.Name := fFontName;
  lLocal.Size := fFontSize;
  lLocal.Color := fFontColor;
  lLocal.Bold := fFontStyleBold;
  lLocal.Italic := fFontStyleItalic;
  GetEffectiveFont(lLocal, AFont);
end;

function TRecorderStaticTextComponent.GetFontName: string;
var lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont <> nil then Result := lFont.FontName else Result := fFontName;
end;

function TRecorderStaticTextComponent.GetFontSize: Integer;
var lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont <> nil then Result := lFont.FontSize else Result := fFontSize;
end;

function TRecorderStaticTextComponent.GetFontColor: LongInt;
var lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont <> nil then Result := lFont.FontColor else Result := fFontColor;
end;

function TRecorderStaticTextComponent.GetFontStyleBold: Boolean;
var lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont <> nil then Result := lFont.Bold else Result := fFontStyleBold;
end;

function TRecorderStaticTextComponent.GetFontStyleItalic: Boolean;
var lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont <> nil then Result := lFont.Italic else Result := fFontStyleItalic;
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

procedure TRecorderTagValueComponent.GetFontSnapshot(
  out AFont: TRecorderFontSnapshot);
var
  lLocal: TRecorderFontSnapshot;
begin
  lLocal.Name := fFontName;
  lLocal.Size := fFontSize;
  lLocal.Color := fFontColor;
  lLocal.Bold := fFontStyleBold;
  lLocal.Italic := fFontStyleItalic;
  GetEffectiveFont(lLocal, AFont);
end;

function TRecorderTagValueComponent.GetFontName: string;
var lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont <> nil then Result := lFont.FontName else Result := fFontName;
end;

function TRecorderTagValueComponent.GetFontSize: Integer;
var lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont <> nil then Result := lFont.FontSize else Result := fFontSize;
end;

function TRecorderTagValueComponent.GetFontColor: LongInt;
var lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont <> nil then Result := lFont.FontColor else Result := fFontColor;
end;

function TRecorderTagValueComponent.GetFontStyleBold: Boolean;
var lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont <> nil then Result := lFont.Bold else Result := fFontStyleBold;
end;

function TRecorderTagValueComponent.GetFontStyleItalic: Boolean;
var lFont: TRecorderNamedFont;
begin
  lFont := ResolveNamedFont;
  if lFont <> nil then Result := lFont.Italic else Result := fFontStyleItalic;
end;

{ TRecorderButtonComponent }

class function TRecorderButtonComponent.GetTypeId: string;
begin
  Result := 'Button';
end;

class function TRecorderInputFieldComponent.GetTypeId: string;
begin
  Result := 'InputField';
end;

constructor TRecorderInputFieldComponent.Create;
begin
  inherited Create;
  fDisplayFormat := '0.###';
end;

constructor TRecorderButtonComponent.Create;
begin
  inherited Create;
  fCaption := 'Button';
  fBehavior := rbbToggle;
  fPressedValue := 1.0;
  fReleasedValue := 0.0;
  fPulseDurationMs := 250;
  fPressedImageFileName := '';
  fReleasedImageFileName := '';
end;

{ TRecorderImageComponent }

class function TRecorderImageComponent.GetTypeId: string;
begin
  Result := 'Image';
end;

constructor TRecorderImageComponent.Create;
begin
  inherited Create;
  fImages := TStringList.Create;
  fImages.NameValueSeparator := '=';
end;

destructor TRecorderImageComponent.Destroy;
begin
  fImages.Free;
  inherited Destroy;
end;

procedure TRecorderImageComponent.AssignImage(ASource: TRecorderImageComponent);
begin
  if ASource = nil then
    Exit;
  TagId := ASource.TagId;
  TagName := ASource.TagName;
  fImages.Assign(ASource.Images);
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
  fClosedInput := False;
  fAutoRangeEnabled := False;
  fXCursorEnabled := False;
  fXCursorCount := 1;
  fLegendVisible := True;
  fLevelCursorVisible := False;
  fPrimaryAxisIndex := 0;
  fTagOffset := 0;
  fXScale := 0.0; { 0 = recorder-wide time window for existing components }
  fYScale := 1.0;
  fYOffset := 0.0;
  fTriggerTagName := '';
  fTriggerEnabled := False;
  fTriggerLevel := 0.0;
  fTriggerPreRollPercent := 25.0;
  fAxes := TList.Create;
  AddAxis;
  fLines := TList.Create;
end;

destructor TRecorderOscillogramComponent.Destroy;
begin
  ClearLines;
  fLines.Free;
  ClearAxes;
  fAxes.Free;
  inherited Destroy;
end;

function TRecorderOscillogramComponent.GetAxis(AIndex: Integer): TRecorderTrendAxis;
begin
  Result := TRecorderTrendAxis(fAxes[AIndex]);
end;

function TRecorderOscillogramComponent.GetAxisCount: Integer;
begin
  Result := fAxes.Count;
end;

function TRecorderOscillogramComponent.AddAxis: TRecorderTrendAxis;
begin
  Result := TRecorderTrendAxis.Create;
  Result.Name := 'Y' + IntToStr(fAxes.Count + 1);
  fAxes.Add(Result);
end;

procedure TRecorderOscillogramComponent.ClearAxes;
var
  I: Integer;
begin
  for I := fAxes.Count - 1 downto 0 do
    TObject(fAxes[I]).Free;
  fAxes.Clear;
end;

function TRecorderOscillogramComponent.GetYScale: Double;
begin
  if fAxes.Count > 0 then
    Result := Axes[0].YScale
  else
    Result := fYScale;
end;

function TRecorderOscillogramComponent.GetYOffset: Double;
begin
  if fAxes.Count > 0 then
    Result := Axes[0].YOffset
  else
    Result := fYOffset;
end;

procedure TRecorderOscillogramComponent.SetYScale(AValue: Double);
begin
  fYScale := AValue;
  if fAxes.Count > 0 then
    Axes[0].YScale := AValue;
end;

procedure TRecorderOscillogramComponent.SetYOffset(AValue: Double);
begin
  fYOffset := AValue;
  if fAxes.Count > 0 then
    Axes[0].YOffset := AValue;
end;

procedure TRecorderOscillogramComponent.SetTriggerPreRollPercent(AValue: Double);
begin
  if AValue < 0.0 then
    AValue := 0.0
  else if AValue > 50.0 then
    AValue := 50.0;
  fTriggerPreRollPercent := AValue;
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
  fClosedInput := ASource.ClosedInput;
  fAutoRangeEnabled := ASource.AutoRangeEnabled;
  fXCursorEnabled := ASource.XCursorEnabled;
  fXCursorCount := ASource.XCursorCount;
  fLegendVisible := ASource.LegendVisible;
  fLevelCursorVisible := ASource.LevelCursorVisible;
  fPrimaryAxisIndex := ASource.PrimaryAxisIndex;
  fTagOffset := ASource.TagOffset;
  fXScale := ASource.XScale;
  ClearAxes;
  for I := 0 to ASource.AxisCount - 1 do
    AddAxis.Assign(ASource.Axes[I]);
  if AxisCount = 0 then
    AddAxis;
  YScale := ASource.YScale;
  YOffset := ASource.YOffset;
  fTriggerTagName := ASource.TriggerTagName;
  fTriggerEnabled := ASource.TriggerEnabled;
  fTriggerLevel := ASource.TriggerLevel;
  TriggerPreRollPercent := ASource.TriggerPreRollPercent;
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
  fYScale := 1;
  fYOffset := 0;
end;

procedure TRecorderTrendAxis.Assign(ASource: TRecorderTrendAxis);
begin
  if ASource = nil then
    Exit;
  fName := ASource.Name;
  fColor := ASource.Color;
  fRangeMin := ASource.RangeMin;
  fRangeMax := ASource.RangeMax;
  fYScale := ASource.YScale;
  fYOffset := ASource.YOffset;
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

{ TRecorderDonutComponent }

class function TRecorderDonutComponent.GetTypeId: string;
begin
  Result := 'donut';
end;

constructor TRecorderDonutComponent.Create;
begin
  inherited Create;
  fTagNames := TStringList.Create;
  fTitle := 'Круговая гистограмма';
  fHolePercent := 55;
  fSingleValueMode := True;
  fRangeMin := 0;
  fRangeMax := 100;
end;

destructor TRecorderDonutComponent.Destroy;
begin
  fTagNames.Free;
  inherited Destroy;
end;

procedure TRecorderDonutComponent.AssignDonut(ASource: TRecorderDonutComponent);
begin
  fTagNames.Assign(ASource.TagNames);
  fTagIds := Copy(ASource.fTagIds, 0, Length(ASource.fTagIds));
  fTitle := ASource.Title;
  fHolePercent := ASource.HolePercent;
  fSingleValueMode := ASource.SingleValueMode;
  fRangeMin := ASource.RangeMin;
  fRangeMax := ASource.RangeMax;
  TagName := ASource.TagName;
  TagId := ASource.TagId;
end;

function TRecorderDonutComponent.TagIdAt(AIndex: Integer): TRecorderTagId;
begin
  Result := 0;
  if (AIndex >= 0) and (AIndex < Length(fTagIds)) then
    Result := fTagIds[AIndex];
end;

procedure TRecorderDonutComponent.SetTagIdAt(AIndex: Integer;
  AId: TRecorderTagId);
begin
  if AIndex < 0 then Exit;
  if AIndex >= Length(fTagIds) then
    SetLength(fTagIds, AIndex + 1);
  fTagIds[AIndex] := AId;
end;

function TRecorderDonutComponent.ResolveTagAt(ARegistry: TRecorderTagRegistry;
  AIndex: Integer): TRecorderTag;
begin
  Result := nil;
  if (ARegistry = nil) or (AIndex < 0) or
    (AIndex >= fTagNames.Count) then Exit;
  if TagIdAt(AIndex) <> 0 then
    Result := ARegistry.FindById(TagIdAt(AIndex));
  if Result = nil then
  begin
    Result := ARegistry.FindByName(fTagNames[AIndex]);
    if Result <> nil then SetTagIdAt(AIndex, Result.Id);
  end;
  if Result <> nil then
    fTagNames[AIndex] := Result.Name;
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
  ConfigurePalette('Спектр', 'Добавить спектр', 'spectrum', 40, rppGroup,
    CRecorderPaletteGroupCharts);
end;

procedure TRecorderSpectrumFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
var
  lSpectrum: TRecorderSpectrumComponent;
  lTag: TRecorderTag;
begin
  lSpectrum := TRecorderSpectrumComponent(AComponent);
  lSpectrum.Name := Format('Spectrum%d', [AContext.ComponentNo]);
  lTag := AContext.SelectedTag;
  if lTag = nil then
    lTag := AContext.DefaultTag;
  if lTag <> nil then
    lSpectrum.SetTagRefAt(lSpectrum.TagNames.Count, lTag);
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
  fPaletteCaption := ATypeName;
  fPaletteHint := ATypeName;
  fPaletteIconId := '';
  fPaletteOrder := 0;
  fPalettePlacement := rppStandalone;
  fPaletteGroupId := '';
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

procedure TRecorderComponentFactoryBase.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  AComponent.Name := Format('%s%d', [TypeName, AContext.ComponentNo]);
end;

function TRecorderComponentFactoryBase.CreateComponentForPage(
  const AContext: TRecorderComponentCreateContext): TRecorderVisualComponent;
begin
  if AContext.Page = nil then
    raise ERecorderFormError.Create('Cannot create component without page');
  Result := CreateComponent;
  try
    Result.Id := Format('%s.component%d',
      [AContext.Page.Id, AContext.ComponentNo]);
    Result.SetBounds(16, 16 + AContext.Page.ComponentCount * 36,
      DefaultWidth, DefaultHeight);
    ConfigureNewComponent(Result, AContext);
  except
    Result.Free;
    raise;
  end;
end;

procedure TRecorderComponentFactoryBase.ConfigurePalette(const ACaption, AHint,
  AIconId: string; AOrder: Integer; APlacement: TRecorderPalettePlacement;
  const AGroupId: string);
begin
  fPaletteCaption := ACaption;
  fPaletteHint := AHint;
  fPaletteIconId := AIconId;
  fPaletteOrder := AOrder;
  fPalettePlacement := APlacement;
  if APlacement = rppGroup then
    fPaletteGroupId := AGroupId
  else
    fPaletteGroupId := '';
end;

{ TRecorderStaticTextFactory }

constructor TRecorderStaticTextFactory.Create;
begin
  inherited Create(TRecorderStaticTextComponent.TypeId, 'Static text',
    TRecorderStaticTextComponent, 160, 24, False);
  ConfigurePalette('Текст', 'Добавить текст', 'text-label', 10);
end;

procedure TRecorderStaticTextFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  AComponent.Name := Format('TextLabel%d', [AContext.ComponentNo]);
  TRecorderStaticTextComponent(AComponent).Text := 'Text label';
  AComponent.SetBounds(AComponent.Bounds.Left, AComponent.Bounds.Top, 180, 28);
end;

{ TRecorderTagValueFactory }

constructor TRecorderButtonFactory.Create;
begin
  inherited Create(TRecorderButtonComponent.TypeId, 'Button',
    TRecorderButtonComponent, 120, 32, False);
  ConfigurePalette('Кнопка', 'Добавить кнопку', 'button', 40);
end;

procedure TRecorderButtonFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  AComponent.Name := Format('Button%d', [AContext.ComponentNo]);
  TRecorderButtonComponent(AComponent).Caption := 'Button';
end;

constructor TRecorderInputFieldFactory.Create;
begin
  inherited Create(TRecorderInputFieldComponent.TypeId, 'Поле ввода',
    TRecorderInputFieldComponent, 120, 28, False);
  ConfigurePalette('Поле ввода', 'Добавить поле ввода', 'input-field', 50);
end;

procedure TRecorderInputFieldFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  AComponent.Name := Format('InputField%d', [AContext.ComponentNo]);
end;

constructor TRecorderTagValueFactory.Create;
begin
  inherited Create(TRecorderTagValueComponent.TypeId, 'Tag value',
    TRecorderTagValueComponent, 160, 24, True);
  ConfigurePalette('Цифровой индикатор', 'Добавить цифровой индикатор',
    'digital-indicator', 20, rppGroup, CRecorderPaletteGroupIndicators);
end;

procedure TRecorderTagValueFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
var
  lValue: TRecorderTagValueComponent;
begin
  lValue := TRecorderTagValueComponent(AComponent);
  lValue.Name := Format('DigitalIndicator%d', [AContext.ComponentNo]);
  lValue.TagName := 'MemTag';
  lValue.DisplayFormat := '0.0';
  lValue.SetBounds(lValue.Bounds.Left, lValue.Bounds.Top, 180, 32);
end;

{ TRecorderImageFactory }

constructor TRecorderImageFactory.Create;
begin
  inherited Create(TRecorderImageComponent.TypeId, 'Картинка',
    TRecorderImageComponent, 200, 140, True);
  ConfigurePalette('Картинка', 'Добавить картинку', 'image', 30);
end;

procedure TRecorderImageFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  AComponent.Name := Format('Image%d', [AContext.ComponentNo]);
end;

{ TRecorderOscillogramFactory }

constructor TRecorderOscillogramFactory.Create;
begin
  inherited Create(TRecorderOscillogramComponent.TypeId, 'Oscillogram',
    TRecorderOscillogramComponent, 360, 220, True);
  ConfigurePalette('Осциллограмма', 'Добавить осциллограмму', 'oscillogram',
    10, rppGroup, CRecorderPaletteGroupCharts);
end;


{ TRecorderDonutFactory }

constructor TRecorderDonutFactory.Create;
begin
  inherited Create(TRecorderDonutComponent.TypeId, 'Круговая гистограмма',
    TRecorderDonutComponent, 300, 260, False);
  ConfigurePalette('Круговая гистограмма',
    'Добавить круговую гистограмму текущего значения', 'donut',
    25, rppGroup, CRecorderPaletteGroupIndicators);
end;

procedure TRecorderDonutFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
begin
  AComponent.Name := Format('Donut%d', [AContext.ComponentNo]);
  if AContext.SelectedTag <> nil then
  begin
    AComponent.TagName := AContext.SelectedTag.Name;
    AComponent.TagId := AContext.SelectedTag.Id;
    TRecorderDonutComponent(AComponent).TagNames.Add(AContext.SelectedTag.Name);
    TRecorderDonutComponent(AComponent).SetTagIdAt(0, AContext.SelectedTag.Id);
  end;
end;

{ TRecorderTrendFactory }

constructor TRecorderTrendFactory.Create;
begin
  inherited Create(TRecorderTrendComponent.TypeId, 'Trend',
    TRecorderTrendComponent, 400, 300, False);
  ConfigurePalette('Тренд', 'Добавить тренд', 'trend', 20, rppGroup,
    CRecorderPaletteGroupCharts);
end;

procedure TRecorderTrendFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
var
  lAxis: TRecorderTrendAxis;
  lLine: TRecorderTrendLine;
  lTag: TRecorderTag;
  lTrend: TRecorderTrendComponent;
begin
  lTrend := TRecorderTrendComponent(AComponent);
  lTrend.Name := Format('Trend%d', [AContext.ComponentNo]);
  lTag := AContext.SelectedTag;
  if lTag = nil then
    lTag := AContext.DefaultTag;
  if lTag = nil then
    Exit;
  lTrend.TagId := lTag.Id;
  lTrend.TagName := lTag.Name;
  if lTrend.AxisCount > 0 then
  begin
    lAxis := lTrend.Axes[0];
    lAxis.Name := lTag.UnitName;
    if lAxis.Name = '' then
      lAxis.Name := 'Y';
    if lTag.RangeMax > lTag.RangeMin then
    begin
      lAxis.RangeMin := lTag.RangeMin;
      lAxis.RangeMax := lTag.RangeMax;
    end;
  end;
  lLine := lTrend.AddLine;
  lLine.TagId := lTag.Id;
  lLine.TagName := lTag.Name;
  lLine.EstimateKind := tekMean;
  lLine.AxisIndex := 0;
end;

{ TRecorderFormPage }

constructor TRecorderFormPage.Create(const AId, AName, ATitle: string);
begin
  inherited Create;
  fComponents := TList.Create;
  fId := AId;
  fName := AName;
  fTitle := ATitle;
  fBackgroundImageFileName := '';
  fBackgroundKeepAspect := False;
  fMode := fpmView;
  fBaseOscillogramCount := 2;
  fDetached := False;
  fDetachedLeft := 100;
  fDetachedTop := 100;
  fDetachedWidth := 900;
  fDetachedHeight := 650;
  fDetachedMonitor := 0;
  fDetachedMaximized := False;
end;

procedure TRecorderOscillogramFactory.ConfigureNewComponent(
  AComponent: TRecorderVisualComponent;
  const AContext: TRecorderComponentCreateContext);
var
  lOscillogram: TRecorderOscillogramComponent;
begin
  lOscillogram := TRecorderOscillogramComponent(AComponent);
  lOscillogram.Name := Format('Oscillogram%d', [AContext.ComponentNo]);
  if AContext.SelectedTag <> nil then
  begin
    lOscillogram.TagId := AContext.SelectedTag.Id;
    lOscillogram.TagName := AContext.SelectedTag.Name;
  end;
  lOscillogram.BindingMode := rtbmRelativeSelectedTag;
  lOscillogram.TagOffset := 0;
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
  AComponent.fNamedFonts := fNamedFonts;
  AComponent.fResolvedFontRevision := High(QWord);
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
  fNamedFonts := TRecorderNamedFontManager.Create;
end;

destructor TRecorderFormManager.Destroy;
var
  I: Integer;
begin
  for I := 0 to fPages.Count - 1 do
    TObject(fPages[I]).Free;
  fPages.Free;
  fNamedFonts.Free;
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
var
  I: Integer;
begin
  if APage = nil then
    raise ERecorderFormError.Create('Cannot add nil page');

  if (APage.Id <> '') and (FindPageById(APage.Id) <> nil) then
    raise ERecorderFormError.CreateFmt('Page id already exists: %s', [APage.Id]);

  APage.fNamedFonts := fNamedFonts;
  for I := 0 to APage.ComponentCount - 1 do
  begin
    APage.Components[I].fNamedFonts := fNamedFonts;
    APage.Components[I].fResolvedFontRevision := High(QWord);
  end;
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
  RegisterFactory(TRecorderButtonFactory.Create);
  RegisterFactory(TRecorderInputFieldFactory.Create);
  RegisterFactory(TRecorderTagValueFactory.Create);
  RegisterFactory(TRecorderImageFactory.Create);
  RegisterFactory(TRecorderOscillogramFactory.Create);
  RegisterFactory(TRecorderTrendFactory.Create);
  RegisterFactory(TRecorderDonutFactory.Create);
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
