unit uRecorderSqlTrendModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DateUtils, uRecorderFormModel;

type
  TRecorderSqlTrendTimeMode = (sttmFixedUtc, sttmLatestWindow,
    sttmFixedFromToCurrentUtc);

  TRecorderSqlTrendDisplay = class
  private
    fAxes: TList;
    fLines: TList;
    fName: string;
    function GetAxis(AIndex: Integer): TRecorderTrendAxis;
    function GetAxisCount: Integer;
    function GetLine(AIndex: Integer): TRecorderTrendLine;
    function GetLineCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function AddAxis: TRecorderTrendAxis;
    function AddLine: TRecorderTrendLine;
    procedure Assign(ASource: TRecorderSqlTrendDisplay);
    procedure ClearAxes;
    procedure ClearLines;
    procedure DeleteAxis(AIndex: Integer);
    procedure DeleteLine(AIndex: Integer);
    function RemoveLinesByTagNames(ATagNames: TStrings): Integer;
    property Name: string read fName write fName;
    property AxisCount: Integer read GetAxisCount;
    property Axes[AIndex: Integer]: TRecorderTrendAxis read GetAxis;
    property LineCount: Integer read GetLineCount;
    property Lines[AIndex: Integer]: TRecorderTrendLine read GetLine;
  end;

  { Исторический тренд SQL. Оси и линии унаследованы от обычного Trend;
    TagName линии содержит имя сигнала из таблицы signals, а не тег Recorder. }
  TRecorderSqlTrendComponent = class(TRecorderTrendComponent)
  private
    fConfigFileName: string;
    fFromUtc: Double;
    fDisplays: TList;
    fActiveDisplayIndex: Integer;
    fMaxPointsPerLine: Integer;
    fTimeMode: TRecorderSqlTrendTimeMode;
    fToUtc: Double;
    function GetActiveDisplay: TRecorderSqlTrendDisplay;
    function GetDisplay(AIndex: Integer): TRecorderSqlTrendDisplay;
    function GetDisplayCount: Integer;
    procedure SetActiveDisplayIndex(AValue: Integer);
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function AddDisplay(const AName: string = ''): TRecorderSqlTrendDisplay;
    procedure AssignSqlTrend(ASource: TRecorderSqlTrendComponent);
    procedure ClearDisplays;
    procedure DeleteDisplay(AIndex: Integer);
    procedure ImportLegacyTrend;
    function RemoveLinesByTagNames(ATagNames: TStrings): Integer;
    property ConfigFileName: string read fConfigFileName write fConfigFileName;
    property FromUtc: Double read fFromUtc write fFromUtc;
    property ToUtc: Double read fToUtc write fToUtc;
    property TimeMode: TRecorderSqlTrendTimeMode read fTimeMode write fTimeMode;
    property MaxPointsPerLine: Integer read fMaxPointsPerLine
      write fMaxPointsPerLine;
    property DisplayCount: Integer read GetDisplayCount;
    property Displays[AIndex: Integer]: TRecorderSqlTrendDisplay read GetDisplay;
    property ActiveDisplayIndex: Integer read fActiveDisplayIndex
      write SetActiveDisplayIndex;
    property ActiveDisplay: TRecorderSqlTrendDisplay read GetActiveDisplay;
  end;

  TRecorderSqlTrendFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create;
  end;

procedure RegisterRecorderSqlTrendFactory(AFactory: TRecorderComponentFactory);

implementation

{ TRecorderSqlTrendDisplay }

constructor TRecorderSqlTrendDisplay.Create;
begin
  inherited Create;
  fAxes := TList.Create;
  fLines := TList.Create;
  fName := 'Отображение 1';
  AddAxis;
end;

destructor TRecorderSqlTrendDisplay.Destroy;
begin
  ClearLines;
  ClearAxes;
  fLines.Free;
  fAxes.Free;
  inherited Destroy;
end;

function TRecorderSqlTrendDisplay.GetAxis(AIndex: Integer): TRecorderTrendAxis;
begin Result := TRecorderTrendAxis(fAxes[AIndex]); end;
function TRecorderSqlTrendDisplay.GetAxisCount: Integer;
begin Result := fAxes.Count; end;
function TRecorderSqlTrendDisplay.GetLine(AIndex: Integer): TRecorderTrendLine;
begin Result := TRecorderTrendLine(fLines[AIndex]); end;
function TRecorderSqlTrendDisplay.GetLineCount: Integer;
begin Result := fLines.Count; end;

function TRecorderSqlTrendDisplay.AddAxis: TRecorderTrendAxis;
begin Result := TRecorderTrendAxis.Create; fAxes.Add(Result); end;
function TRecorderSqlTrendDisplay.AddLine: TRecorderTrendLine;
begin Result := TRecorderTrendLine.Create; fLines.Add(Result); end;

procedure TRecorderSqlTrendDisplay.ClearAxes;
begin while fAxes.Count > 0 do begin TObject(fAxes[0]).Free; fAxes.Delete(0); end; end;
procedure TRecorderSqlTrendDisplay.ClearLines;
begin while fLines.Count > 0 do begin TObject(fLines[0]).Free; fLines.Delete(0); end; end;
procedure TRecorderSqlTrendDisplay.DeleteAxis(AIndex: Integer);
begin if (AIndex >= 0) and (AIndex < fAxes.Count) then begin TObject(fAxes[AIndex]).Free; fAxes.Delete(AIndex); end; end;
procedure TRecorderSqlTrendDisplay.DeleteLine(AIndex: Integer);
begin if (AIndex >= 0) and (AIndex < fLines.Count) then begin TObject(fLines[AIndex]).Free; fLines.Delete(AIndex); end; end;

function TRecorderSqlTrendDisplay.RemoveLinesByTagNames(
  ATagNames: TStrings): Integer;
var
  I: Integer;
begin
  Result := 0;
  if ATagNames = nil then Exit;
  for I := LineCount - 1 downto 0 do
    if ATagNames.IndexOf(Lines[I].TagName) >= 0 then
    begin
      DeleteLine(I);
      Inc(Result);
    end;
end;

procedure TRecorderSqlTrendDisplay.Assign(ASource: TRecorderSqlTrendDisplay);
var I: Integer; A: TRecorderTrendAxis; L: TRecorderTrendLine;
begin
  if ASource = nil then Exit;
  fName := ASource.Name; ClearAxes; ClearLines;
  for I := 0 to ASource.AxisCount - 1 do begin A := AddAxis; A.Assign(ASource.Axes[I]); end;
  for I := 0 to ASource.LineCount - 1 do begin L := AddLine; L.Assign(ASource.Lines[I]); end;
  if AxisCount = 0 then AddAxis;
end;

class function TRecorderSqlTrendComponent.GetTypeId: string;
begin
  Result := 'sql-trend';
end;

constructor TRecorderSqlTrendComponent.Create;
var
  lAxis: TRecorderTrendAxis;
begin
  inherited Create;
  fDisplays := TList.Create;
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
  AddDisplay('Отображение 1');
end;

destructor TRecorderSqlTrendComponent.Destroy;
begin
  ClearDisplays;
  fDisplays.Free;
  inherited Destroy;
end;

function TRecorderSqlTrendComponent.GetDisplayCount: Integer;
begin Result := fDisplays.Count; end;
function TRecorderSqlTrendComponent.GetDisplay(AIndex: Integer): TRecorderSqlTrendDisplay;
begin Result := TRecorderSqlTrendDisplay(fDisplays[AIndex]); end;
function TRecorderSqlTrendComponent.GetActiveDisplay: TRecorderSqlTrendDisplay;
begin if DisplayCount = 0 then Result := nil else Result := Displays[fActiveDisplayIndex]; end;
procedure TRecorderSqlTrendComponent.SetActiveDisplayIndex(AValue: Integer);
begin if DisplayCount = 0 then fActiveDisplayIndex := 0 else begin if AValue < 0 then AValue := 0; if AValue >= DisplayCount then AValue := DisplayCount - 1; fActiveDisplayIndex := AValue; end; end;

function TRecorderSqlTrendComponent.AddDisplay(const AName: string): TRecorderSqlTrendDisplay;
begin
  Result := TRecorderSqlTrendDisplay.Create;
  if Trim(AName) <> '' then Result.Name := Trim(AName)
  else Result.Name := 'Отображение ' + IntToStr(DisplayCount + 1);
  fDisplays.Add(Result);
end;

procedure TRecorderSqlTrendComponent.ClearDisplays;
begin while fDisplays.Count > 0 do begin TObject(fDisplays[0]).Free; fDisplays.Delete(0); end; fActiveDisplayIndex := 0; end;
procedure TRecorderSqlTrendComponent.DeleteDisplay(AIndex: Integer);
begin if (DisplayCount <= 1) or (AIndex < 0) or (AIndex >= DisplayCount) then Exit; TObject(fDisplays[AIndex]).Free; fDisplays.Delete(AIndex); SetActiveDisplayIndex(fActiveDisplayIndex); end;

function TRecorderSqlTrendComponent.RemoveLinesByTagNames(
  ATagNames: TStrings): Integer;
var
  I: Integer;
begin
  Result := 0;
  if ATagNames = nil then Exit;
  for I := 0 to DisplayCount - 1 do
    Inc(Result, Displays[I].RemoveLinesByTagNames(ATagNames));
end;

procedure TRecorderSqlTrendComponent.ImportLegacyTrend;
var I: Integer; D: TRecorderSqlTrendDisplay; A: TRecorderTrendAxis; L: TRecorderTrendLine;
begin
  ClearDisplays; D := AddDisplay('Основное'); D.ClearAxes;
  for I := 0 to AxisCount - 1 do begin A := D.AddAxis; A.Assign(Axes[I]); end;
  for I := 0 to LineCount - 1 do begin L := D.AddLine; L.Assign(Lines[I]); end;
  if D.AxisCount = 0 then D.AddAxis;
end;

procedure TRecorderSqlTrendComponent.AssignSqlTrend(
  ASource: TRecorderSqlTrendComponent);
var
  I: Integer;
  D: TRecorderSqlTrendDisplay;
begin
  if ASource = nil then Exit;
  AssignTrend(ASource);
  ClearDisplays;
  for I := 0 to ASource.DisplayCount - 1 do
  begin
    D := AddDisplay;
    D.Assign(ASource.Displays[I]);
  end;
  if DisplayCount = 0 then AddDisplay('Отображение 1');
  ActiveDisplayIndex := ASource.ActiveDisplayIndex;
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
