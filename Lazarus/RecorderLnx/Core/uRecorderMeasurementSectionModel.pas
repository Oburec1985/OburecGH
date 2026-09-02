unit uRecorderMeasurementSectionModel;

{
  Модель компонента мнемосхемы "Измерительное сечение".

  Компонент хранит только конфигурацию отображения и привязки к тегам. Он не
  публикует расчетные теги и не участвует в сборе данных.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, uRecorderFormModel, uRecorderTags;

type
  TRecorderRosetteType = (rrtTwoComponent, rrtThreeComponent);
  TRecorderRosetteRole = (rrrE1, rrrE2, rrrE3, rrrTemperature);

  TRecorderMeasurementSectionRow = class
  private
    fBalances: array[TRecorderRosetteRole] of Double;
    fPointNo: Integer;
    fRosetteType: TRecorderRosetteType;
    fPositionDeg: Double;
    fTagIds: array[TRecorderRosetteRole] of TRecorderTagId;
    fTagNames: array[TRecorderRosetteRole] of string;
    function GetTagId(ARole: TRecorderRosetteRole): TRecorderTagId;
    function GetTagName(ARole: TRecorderRosetteRole): string;
    function GetBalance(ARole: TRecorderRosetteRole): Double;
    procedure SetBalance(ARole: TRecorderRosetteRole; AValue: Double);
    procedure SetTagId(ARole: TRecorderRosetteRole; AValue: TRecorderTagId);
    procedure SetTagName(ARole: TRecorderRosetteRole; const AValue: string);
  public
    constructor Create;
    procedure Assign(ASource: TRecorderMeasurementSectionRow);
    procedure BindTag(ARole: TRecorderRosetteRole; ATag: TRecorderTag);
    function CaptureBalance(ARegistry: TRecorderTagRegistry;
      ARole: TRecorderRosetteRole): Boolean;
    function ResolveTag(ARegistry: TRecorderTagRegistry;
      ARole: TRecorderRosetteRole): TRecorderTag;
    property PointNo: Integer read fPointNo write fPointNo;
    property RosetteType: TRecorderRosetteType read fRosetteType write fRosetteType;
    property PositionDeg: Double read fPositionDeg write fPositionDeg;
    property Balances[ARole: TRecorderRosetteRole]: Double
      read GetBalance write SetBalance;
    property TagIds[ARole: TRecorderRosetteRole]: TRecorderTagId
      read GetTagId write SetTagId;
    property TagNames[ARole: TRecorderRosetteRole]: string
      read GetTagName write SetTagName;
  end;

  TRecorderMeasurementSectionValues = record
    Valid: Boolean;
    HasE1: Boolean;
    HasE2: Boolean;
    HasE3: Boolean;
    HasTemperature: Boolean;
    E1: Double;
    E2: Double;
    E3: Double;
    Temperature: Double;
    Sigma1: Double;
    Sigma2: Double;
    AngleDeg: Double;
    HasSigma1: Boolean;
    HasSigma2: Boolean;
    HasAngle: Boolean;
    MaxAbsStrain: Double;
  end;

  TRecorderMeasurementSectionComponent = class(TRecorderVisualComponent)
  private
    fBackgroundColor: LongInt;
    fCaption: string;
    fCaptionFont: TRecorderFontSnapshot;
    fSectionId: string;
    fRows: TList;
    fStressFont: TRecorderFontSnapshot;
    fStressNamedFontName: string;
    fTextBackgroundColor: LongInt;
    fYoungModulusMPa: Double;
    fPoissonRatio: Double;
    fTemperatureCoefficient: Double;
    fReferenceTemperatureC: Double;
    function GetRow(AIndex: Integer): TRecorderMeasurementSectionRow;
    function GetRowCount: Integer;
  protected
    class function GetTypeId: string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function AddRow: TRecorderMeasurementSectionRow;
    procedure AssignSection(ASource: TRecorderMeasurementSectionComponent);
    procedure ClearRows;
    procedure CaptureBalance(ARegistry: TRecorderTagRegistry);
    function CaptureRowBalance(ARegistry: TRecorderTagRegistry;
      ARow: TRecorderMeasurementSectionRow;
      ARole: TRecorderRosetteRole): Boolean;
    procedure DeleteRow(AIndex: Integer);
    procedure CalculateRow(ARegistry: TRecorderTagRegistry;
      ARow: TRecorderMeasurementSectionRow;
      out AValues: TRecorderMeasurementSectionValues);
    procedure GetCaptionFont(out AFont: TRecorderFontSnapshot);
    procedure GetStressFont(out AFont: TRecorderFontSnapshot);
    property Caption: string read fCaption write fCaption;
    property BackgroundColor: LongInt read fBackgroundColor
      write fBackgroundColor;
    property CaptionFont: TRecorderFontSnapshot read fCaptionFont
      write fCaptionFont;
    property SectionId: string read fSectionId write fSectionId;
    property RowCount: Integer read GetRowCount;
    property Rows[AIndex: Integer]: TRecorderMeasurementSectionRow read GetRow;
    property YoungModulusMPa: Double read fYoungModulusMPa write fYoungModulusMPa;
    property PoissonRatio: Double read fPoissonRatio write fPoissonRatio;
    property TemperatureCoefficient: Double read fTemperatureCoefficient
      write fTemperatureCoefficient;
    property ReferenceTemperatureC: Double read fReferenceTemperatureC
      write fReferenceTemperatureC;
    property StressFont: TRecorderFontSnapshot read fStressFont
      write fStressFont;
    property StressNamedFontName: string read fStressNamedFontName
      write fStressNamedFontName;
    property TextBackgroundColor: LongInt read fTextBackgroundColor
      write fTextBackgroundColor;
  end;

  TRecorderMeasurementSectionFactory = class(TRecorderComponentFactoryBase)
  public
    constructor Create;
  end;

procedure RegisterRecorderMeasurementSectionFactory(
  AFactory: TRecorderComponentFactory);

function RecorderRosetteTypeToText(AType: TRecorderRosetteType): string;
function RecorderRosetteTypeFromText(const AText: string): TRecorderRosetteType;
function RecorderRosetteRoleToText(ARole: TRecorderRosetteRole): string;
function RecorderRosetteRoleFromText(const AText: string;
  out ARole: TRecorderRosetteRole): Boolean;

implementation

function LatestTagValue(ATag: TRecorderTag; out AValue: Double): Boolean;
begin
  Result := (ATag <> nil) and (ATag.SignalBuffer.Count > 0);
  if Result then
    AValue := ATag.SignalBuffer.LatestValue
  else
    AValue := 0.0;
end;

function RecorderRosetteTypeToText(AType: TRecorderRosetteType): string;
begin
  case AType of
    rrtTwoComponent: Result := '2';
  else
    Result := '3';
  end;
end;

function RecorderRosetteTypeFromText(const AText: string): TRecorderRosetteType;
var
  lText: string;
begin
  lText := LowerCase(Trim(AText));
  if (lText = '2') or (Pos('2', lText) = 1) then
    Result := rrtTwoComponent
  else
    Result := rrtThreeComponent;
end;

function RecorderRosetteRoleToText(ARole: TRecorderRosetteRole): string;
begin
  case ARole of
    rrrE1: Result := 'e1';
    rrrE2: Result := 'e2';
    rrrE3: Result := 'e3';
  else
    Result := 't';
  end;
end;

function RecorderRosetteRoleFromText(const AText: string;
  out ARole: TRecorderRosetteRole): Boolean;
var
  lText: string;
begin
  Result := True;
  lText := LowerCase(Trim(AText));
  if (lText = 'e1') or (lText = 'x') then
    ARole := rrrE1
  else if (lText = 'e2') or (lText = 'y') then
    ARole := rrrE2
  else if (lText = 'e3') or (lText = 'z') then
    ARole := rrrE3
  else if (lText = 't') or (lText = 'temp') or (lText = 'temperature') or
    (lText = 'температура') then
    ARole := rrrTemperature
  else
    Result := False;
end;

{ TRecorderMeasurementSectionRow }

constructor TRecorderMeasurementSectionRow.Create;
var
  lRole: TRecorderRosetteRole;
begin
  inherited Create;
  fPointNo := 1;
  fRosetteType := rrtThreeComponent;
  fPositionDeg := 0.0;
  for lRole := Low(TRecorderRosetteRole) to High(TRecorderRosetteRole) do
  begin
    fBalances[lRole] := 0.0;
    fTagIds[lRole] := 0;
    fTagNames[lRole] := '';
  end;
end;

procedure TRecorderMeasurementSectionRow.Assign(
  ASource: TRecorderMeasurementSectionRow);
var
  lRole: TRecorderRosetteRole;
begin
  if ASource = nil then
    Exit;
  fPointNo := ASource.PointNo;
  fRosetteType := ASource.RosetteType;
  fPositionDeg := ASource.PositionDeg;
  for lRole := Low(TRecorderRosetteRole) to High(TRecorderRosetteRole) do
  begin
    fBalances[lRole] := ASource.Balances[lRole];
    fTagIds[lRole] := ASource.TagIds[lRole];
    fTagNames[lRole] := ASource.TagNames[lRole];
  end;
end;

procedure TRecorderMeasurementSectionRow.BindTag(ARole: TRecorderRosetteRole;
  ATag: TRecorderTag);
begin
  if ATag = nil then
    Exit;
  fTagIds[ARole] := ATag.Id;
  fTagNames[ARole] := ATag.Name;
end;

function TRecorderMeasurementSectionRow.CaptureBalance(
  ARegistry: TRecorderTagRegistry; ARole: TRecorderRosetteRole): Boolean;
var
  lValue: Double;
begin
  Result := (ARole <> rrrTemperature) and
    LatestTagValue(ResolveTag(ARegistry, ARole), lValue);
  if Result then
    fBalances[ARole] := lValue;
end;

function TRecorderMeasurementSectionRow.GetBalance(
  ARole: TRecorderRosetteRole): Double;
begin
  Result := fBalances[ARole];
end;

function TRecorderMeasurementSectionRow.GetTagId(
  ARole: TRecorderRosetteRole): TRecorderTagId;
begin
  Result := fTagIds[ARole];
end;

function TRecorderMeasurementSectionRow.GetTagName(
  ARole: TRecorderRosetteRole): string;
begin
  Result := fTagNames[ARole];
end;

procedure TRecorderMeasurementSectionRow.SetBalance(
  ARole: TRecorderRosetteRole; AValue: Double);
begin
  fBalances[ARole] := AValue;
end;

procedure TRecorderMeasurementSectionRow.SetTagId(
  ARole: TRecorderRosetteRole; AValue: TRecorderTagId);
begin
  fTagIds[ARole] := AValue;
end;

procedure TRecorderMeasurementSectionRow.SetTagName(
  ARole: TRecorderRosetteRole; const AValue: string);
begin
  fTagNames[ARole] := AValue;
end;

function TRecorderMeasurementSectionRow.ResolveTag(ARegistry: TRecorderTagRegistry;
  ARole: TRecorderRosetteRole): TRecorderTag;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  if fTagIds[ARole] <> 0 then
    Result := ARegistry.FindById(fTagIds[ARole]);
  if (Result = nil) and (Trim(fTagNames[ARole]) <> '') then
    Result := ARegistry.FindByName(fTagNames[ARole]);
  if Result <> nil then
    BindTag(ARole, Result);
end;

{ TRecorderMeasurementSectionComponent }

class function TRecorderMeasurementSectionComponent.GetTypeId: string;
begin
  Result := 'measurement-section';
end;

constructor TRecorderMeasurementSectionComponent.Create;
begin
  inherited Create;
  fRows := TList.Create;
  fCaption := 'Измерительное сечение';
  fBackgroundColor := $00FFF4E8;
  fCaptionFont.Name := 'Tahoma';
  fCaptionFont.Size := 10;
  fCaptionFont.Color := 0;
  fCaptionFont.Bold := False;
  fCaptionFont.Italic := False;
  fSectionId := '1';
  fYoungModulusMPa := 2.1E5;
  fPoissonRatio := 0.30;
  fTemperatureCoefficient := 0.0;
  fReferenceTemperatureC := 20.0;
  fStressFont := fCaptionFont;
  fStressNamedFontName := '';
  fTextBackgroundColor := fBackgroundColor;
end;

destructor TRecorderMeasurementSectionComponent.Destroy;
begin
  ClearRows;
  fRows.Free;
  inherited Destroy;
end;

function TRecorderMeasurementSectionComponent.GetRow(
  AIndex: Integer): TRecorderMeasurementSectionRow;
begin
  Result := TRecorderMeasurementSectionRow(fRows[AIndex]);
end;

function TRecorderMeasurementSectionComponent.GetRowCount: Integer;
begin
  Result := fRows.Count;
end;

function TRecorderMeasurementSectionComponent.AddRow:
  TRecorderMeasurementSectionRow;
begin
  Result := TRecorderMeasurementSectionRow.Create;
  Result.PointNo := fRows.Count + 1;
  fRows.Add(Result);
end;

procedure TRecorderMeasurementSectionComponent.AssignSection(
  ASource: TRecorderMeasurementSectionComponent);
var
  I: Integer;
begin
  if ASource = nil then
    Exit;
  fCaption := ASource.Caption;
  fBackgroundColor := ASource.BackgroundColor;
  NamedFontName := ASource.NamedFontName;
  fCaptionFont := ASource.CaptionFont;
  fSectionId := ASource.SectionId;
  fYoungModulusMPa := ASource.YoungModulusMPa;
  fPoissonRatio := ASource.PoissonRatio;
  fTemperatureCoefficient := ASource.TemperatureCoefficient;
  fReferenceTemperatureC := ASource.ReferenceTemperatureC;
  fStressNamedFontName := ASource.StressNamedFontName;
  fStressFont := ASource.StressFont;
  fTextBackgroundColor := ASource.TextBackgroundColor;
  ClearRows;
  for I := 0 to ASource.RowCount - 1 do
    AddRow.Assign(ASource.Rows[I]);
end;

procedure TRecorderMeasurementSectionComponent.GetCaptionFont(
  out AFont: TRecorderFontSnapshot);
begin
  GetEffectiveFont(fCaptionFont, AFont);
end;

procedure TRecorderMeasurementSectionComponent.GetStressFont(
  out AFont: TRecorderFontSnapshot);
var
  lFont: TRecorderNamedFont;
begin
  lFont := nil;
  if (NamedFonts <> nil) and (Trim(fStressNamedFontName) <> '') then
    lFont := NamedFonts.Find(fStressNamedFontName);
  if lFont = nil then
  begin
    AFont := fStressFont;
    Exit;
  end;
  AFont.Name := lFont.FontName;
  AFont.Size := lFont.FontSize;
  AFont.Color := lFont.FontColor;
  AFont.Bold := lFont.Bold;
  AFont.Italic := lFont.Italic;
end;

procedure TRecorderMeasurementSectionComponent.ClearRows;
begin
  while fRows.Count > 0 do
  begin
    TObject(fRows[0]).Free;
    fRows.Delete(0);
  end;
end;

procedure TRecorderMeasurementSectionComponent.CaptureBalance(
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lRole: TRecorderRosetteRole;
begin
  for I := 0 to RowCount - 1 do
    for lRole := rrrE1 to rrrE3 do
      CaptureRowBalance(ARegistry, Rows[I], lRole);
end;

function TRecorderMeasurementSectionComponent.CaptureRowBalance(
  ARegistry: TRecorderTagRegistry; ARow: TRecorderMeasurementSectionRow;
  ARole: TRecorderRosetteRole): Boolean;
begin
  Result := (ARow <> nil) and ARow.CaptureBalance(ARegistry, ARole);
end;

procedure TRecorderMeasurementSectionComponent.DeleteRow(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= fRows.Count) then
    Exit;
  TObject(fRows[AIndex]).Free;
  fRows.Delete(AIndex);
end;

procedure TRecorderMeasurementSectionComponent.CalculateRow(
  ARegistry: TRecorderTagRegistry; ARow: TRecorderMeasurementSectionRow;
  out AValues: TRecorderMeasurementSectionValues);
var
  lE1, lE2, lE3, lTemp: Double;
  lAvg, lDiff, lGamma, lRoot: Double;
  lEps1, lEps2, lFactor, lDen: Double;
begin
  AValues := Default(TRecorderMeasurementSectionValues);
  if ARow = nil then
    Exit;

  AValues.HasE1 := LatestTagValue(ARow.ResolveTag(ARegistry, rrrE1), lE1);
  AValues.HasE2 := LatestTagValue(ARow.ResolveTag(ARegistry, rrrE2), lE2);
  AValues.HasE3 := LatestTagValue(ARow.ResolveTag(ARegistry, rrrE3), lE3);
  AValues.HasTemperature := LatestTagValue(
    ARow.ResolveTag(ARegistry, rrrTemperature), lTemp);
  if AValues.HasE1 then
    lE1 := lE1 - ARow.Balances[rrrE1];
  if AValues.HasE2 then
    lE2 := lE2 - ARow.Balances[rrrE2];
  if AValues.HasE3 then
    lE3 := lE3 - ARow.Balances[rrrE3];
  AValues.Temperature := lTemp;

  if AValues.HasTemperature and (not SameValue(fTemperatureCoefficient, 0.0)) then
  begin
    if AValues.HasE1 then
      lE1 := lE1 - fTemperatureCoefficient * (lTemp - fReferenceTemperatureC);
    if AValues.HasE2 then
      lE2 := lE2 - fTemperatureCoefficient * (lTemp - fReferenceTemperatureC);
    if AValues.HasE3 then
      lE3 := lE3 - fTemperatureCoefficient * (lTemp - fReferenceTemperatureC);
  end;
  AValues.E1 := lE1;
  AValues.E2 := lE2;
  AValues.E3 := lE3;
  if AValues.HasE1 then
    AValues.MaxAbsStrain := Max(AValues.MaxAbsStrain, Abs(lE1));
  if AValues.HasE2 then
    AValues.MaxAbsStrain := Max(AValues.MaxAbsStrain, Abs(lE2));
  if AValues.HasE3 then
    AValues.MaxAbsStrain := Max(AValues.MaxAbsStrain, Abs(lE3));

  lDen := 1.0 - Sqr(fPoissonRatio);
  if ARow.RosetteType = rrtTwoComponent then
  begin
    if Abs(lDen) <= 1E-12 then
      Exit;
    if AValues.HasE1 and AValues.HasE3 then
    begin
      lFactor := fYoungModulusMPa / lDen * 1E-6;
      AValues.Sigma1 := lFactor * (lE1 + fPoissonRatio * lE3);
      AValues.Sigma2 := lFactor * (lE3 + fPoissonRatio * lE1);
      AValues.HasSigma1 := True;
      AValues.HasSigma2 := True;
      AValues.AngleDeg := 0.0;
      AValues.HasAngle := True;
    end
    else if AValues.HasE1 then
    begin
      AValues.Sigma1 := fYoungModulusMPa * lE1 * 1E-6;
      AValues.HasSigma1 := True;
    end
    else if AValues.HasE3 then
    begin
      AValues.Sigma2 := fYoungModulusMPa * lE3 * 1E-6;
      AValues.HasSigma2 := True;
    end;
    AValues.Valid := AValues.HasSigma1 or AValues.HasSigma2;
    Exit;
  end;

  if Abs(lDen) <= 1E-12 then
    Exit;
  if AValues.HasE1 and AValues.HasE2 and AValues.HasE3 then
  begin
    lAvg := (lE1 + lE3) / 2.0;
    lDiff := (lE1 - lE3) / 2.0;
    lGamma := 2.0 * lE2 - lE1 - lE3;
    lRoot := Sqrt(Sqr(lDiff) + Sqr(lGamma / 2.0));
    lEps1 := lAvg + lRoot;
    lEps2 := lAvg - lRoot;
    lFactor := fYoungModulusMPa / lDen * 1E-6;
    AValues.Sigma1 := lFactor * (lEps1 + fPoissonRatio * lEps2);
    AValues.Sigma2 := lFactor * (lEps2 + fPoissonRatio * lEps1);
    AValues.AngleDeg := RadToDeg(0.5 * ArcTan2(lGamma, lE1 - lE3)) +
      ARow.PositionDeg;
    AValues.HasSigma1 := True;
    AValues.HasSigma2 := True;
    AValues.HasAngle := True;
  end
  else if AValues.HasE1 and AValues.HasE3 then
  begin
    lFactor := fYoungModulusMPa / lDen * 1E-6;
    AValues.Sigma1 := lFactor * (lE1 + fPoissonRatio * lE3);
    AValues.Sigma2 := lFactor * (lE3 + fPoissonRatio * lE1);
    AValues.HasSigma1 := True;
    AValues.HasSigma2 := True;
  end
  else if AValues.HasE1 then
  begin
    AValues.Sigma1 := fYoungModulusMPa * lE1 * 1E-6;
    AValues.HasSigma1 := True;
  end
  else if AValues.HasE3 then
  begin
    AValues.Sigma2 := fYoungModulusMPa * lE3 * 1E-6;
    AValues.HasSigma2 := True;
  end;
  AValues.Valid := AValues.HasSigma1 or AValues.HasSigma2;
end;

{ TRecorderMeasurementSectionFactory }

constructor TRecorderMeasurementSectionFactory.Create;
begin
  inherited Create(TRecorderMeasurementSectionComponent.TypeId,
    'Измерительное сечение', TRecorderMeasurementSectionComponent, 220, 80,
    False);
end;

procedure RegisterRecorderMeasurementSectionFactory(
  AFactory: TRecorderComponentFactory);
begin
  if (AFactory <> nil) and
    (not AFactory.IsComponentRegistered(
      TRecorderMeasurementSectionComponent.TypeId)) then
    AFactory.RegisterFactory(TRecorderMeasurementSectionFactory.Create);
end;

end.
