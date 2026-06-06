unit uOglChartFrameListener;

{
  Модуль uOglChartFrameListener
  Описание: Слушатель и диспетчер кадров для синхронизации перерисовки графиков.
}

{ objfpc}{+}

interface

uses
  Classes, SysUtils, Controls, LCLType;

type
  /// <summary>
  /// Базовый класс слушателя событий кадра и интерактивного ввода для компонента TOglChart.
  /// Предоставляет виртуальные методы для обработки событий мыши, клавиатуры и фаз отрисовки.
  /// </summary>
  TChartFrameListener = class(TObject)
  private
    fEnabled: Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure FrameStarted(ASender: TObject); virtual;
    procedure FrameEnded(ASender: TObject); virtual;

    procedure MouseDown(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    procedure MouseMove(ASender: TObject; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    procedure MouseUp(ASender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; var Handled: Boolean); virtual;
    procedure MouseWheel(ASender: TObject; Shift: TShiftState; WheelDelta: Integer; X, Y: Integer; var Handled: Boolean); virtual;

    procedure KeyDown(ASender: TObject; var Key: Word; Shift: TShiftState; var Handled: Boolean); virtual;
    procedure KeyPress(ASender: TObject; var Key: Char; var Handled: Boolean); virtual;

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