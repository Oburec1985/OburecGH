unit uRecorderSqlTrendModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, DateUtils, uRecorderFormModel;

type
  TRecorderSqlTrendTimeMode = (sttmFixedUtc, sttmLatestWindow);

  { Исторический тренд SQL. Оси и линии унаследованы от обычного Trend;
    TagName линии содержит имя сигнала из таблицы signals, а не тег Recorder. }
  TRecorderSqlTrendComponent = class(TRecorderTrendComponent)
  private
    fConfigFileName: string;
    fFromUtc: Double;
    fMaxPointsPerLine: Integer;
    fTimeMode: TRecorderSqlTrendTimeMode;
    fToUtc: Double;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    procedure AssignSqlTrend(ASource: TRecorderSqlTrendComponent);
    property ConfigFileName: string read fConfigFileName write fConfigFileName;
    property FromUtc: Double read fFromUtc write fFromUtc;
    property ToUtc: Double read fToUtc write fToUtc;
    property TimeMode: TRecorderSqlTrendTimeMode read fTimeMode write fTimeMode;
    property MaxPointsPerLine: Integer read fMaxPointsPerLine
      write fMaxPointsPerLine;
  end;

  TRecorderSqlTrendFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create;
  end;

procedure RegisterRecorderSqlTrendFactory(AFactory: TRecorderComponentFactory);

implementation

class function TRecorderSqlTrendComponent.GetTypeId: string;
begin
  Result := 'sql-trend';
end;

constructor TRecorderSqlTrendComponent.Create;
var
  lAxis: TRecorderTrendAxis;
begin
  inherited Create;
  Name := 'SQL trend';
  DurationSec := 24 * 60 * 60;
  fTimeMode := sttmLatestWindow;
  fToUtc := LocalTimeToUniversal(Now);
  fFromUtc := fToUtc - 1.0;
  fMaxPointsPerLine := 4000;
  if AxisCount = 0 then
  begin
    lAxis := AddAxis;
    lAxis.Name := 'Y';
    lAxis.RangeMin := 0;
    lAxis.RangeMax := 100;
  end;
end;

procedure TRecorderSqlTrendComponent.AssignSqlTrend(
  ASource: TRecorderSqlTrendComponent);
begin
  if ASource = nil then Exit;
  AssignTrend(ASource);
  fConfigFileName := ASource.fConfigFileName;
  fFromUtc := ASource.fFromUtc;
  fToUtc := ASource.fToUtc;
  fTimeMode := ASource.fTimeMode;
  fMaxPointsPerLine := ASource.fMaxPointsPerLine;
end;

constructor TRecorderSqlTrendFactory.Create;
begin
  inherited Create(TRecorderSqlTrendComponent.TypeId, 'SQL trend',
    TRecorderSqlTrendComponent, 520, 320, False);
end;

procedure RegisterRecorderSqlTrendFactory(AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and
    (not AFactory.IsComponentRegistered(TRecorderSqlTrendComponent.TypeId)) then
    AFactory.RegisterFactory(TRecorderSqlTrendFactory.Create);
end;

end.
