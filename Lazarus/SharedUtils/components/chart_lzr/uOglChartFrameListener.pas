unit uOglChartFrameListener;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Controls;

type
  /// <summary>
  /// Базовый класс слушателя событий кадра и интерактивного ввода для компонента TOglChart.
  /// Предоставляет виртуальные методы для обработки событий мыши, клавиатуры и фаз отрисовки.
  /// </summary>
  TChartFrameListener = class(TObject)
  private
    fEnabled: Boolean;
  public
    /// <summary>
    /// Конструктор по умолчанию. Активирует слушатель событий.
    /// </summary>

    constructor Create; virtual;
    /// <summary>
    /// Деструктор. Освобождает занятые ресурсы.
    /// </summary>

    destructor Destroy; override;
    /// <summary>
    /// Вызывается перед началом отрисовки очередного кадра графика.
    /// </summary>
    /// <param name="ASender">Экземпляр TOglChart, инициировавший событие.</param>

    procedure FrameStarted(ASender: TObject); virtual;
    /// <summary>
    /// Вызывается сразу после завершения отрисовки кадра.
    /// </summary>
    /// <param name="ASender">Экземпляр TOglChart, инициировавший событие.</param>

    procedure FrameEnded(ASender: TObject); virtual;
    /// <summary>
    /// Обработчик нажатия кнопки мыши.
    /// </summary>

    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    /// <summary>
    /// Обработчик перемещения мыши.
    /// </summary>

    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    /// <summary>
    /// Обработчик отпускания кнопки мыши.
    /// </summary>

    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    /// <summary>
    /// Обработчик прокрутки колесика мыши.
    /// </summary>

    procedure MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean); virtual;
    /// <summary>
    /// Обработчик нажатия клавиши клавиатуры (системные коды клавиш).
    /// </summary>

    procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); virtual;
    /// <summary>
    /// Обработчик ввода символа с клавиатуры.
    /// </summary>

    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); virtual;
    /// <summary>
    /// Определяет, активен ли данный слушатель событий.
    /// </summary>
    property Enabled: Boolean read fEnabled write fEnabled;
  end;

procedure LogToFile(const AMsg: string);

implementation

procedure LogToFile(const AMsg: string);

var
  F: TextFile;
  lLogPath: string;
begin
  lLogPath := ExtractFilePath(ParamStr(0)) + 'chart_events.log';
  AssignFile(F, lLogPath);
  try
    if FileExists(lLogPath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ': ' + AMsg);
  finally
    CloseFile(F);
  end;

end;

{ TChartFrameListener }

constructor TChartFrameListener.Create;
begin
  inherited Create;
  fEnabled := True;
end;

destructor TChartFrameListener.Destroy;
begin
  inherited Destroy;
end;

procedure TChartFrameListener.FrameStarted(ASender: TObject);
begin
end;

procedure TChartFrameListener.FrameEnded(ASender: TObject);
begin
end;

procedure TChartFrameListener.MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean);
begin
end;

procedure TChartFrameListener.KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean);
begin
end;

end.

