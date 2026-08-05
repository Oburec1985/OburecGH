unit uRecorderFrequencyBands;

{
  RecorderLnx frequency band model.

  The unit keeps frequency bands independent from UI and spectrum rendering.
  Bands can be absolute in Hz or formula-based: base frequency is calculated as
  a sum of tag values multiplied by coefficients, then relative limits are
  applied to that base frequency.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  ERecorderFrequencyBandError = class(Exception);

  TRecorderFrequencyBandKind = (
    fbkAbsoluteHz,
    fbkFormula
  );

  TRecorderFrequencyBandTerm = class
  private
    fCoefficient: Double;
    fTagName: string;
  public
    constructor Create(const ATagName: string; ACoefficient: Double);
    property TagName: string read fTagName write fTagName;
    property Coefficient: Double read fCoefficient write fCoefficient;
  end;

  TRecorderFrequencyBand = class
  private
    fKind: TRecorderFrequencyBandKind;
    fName: string;
    fTerms: TList;
    fX1: Double;
    fX2: Double;
    function GetTerm(AIndex: Integer): TRecorderFrequencyBandTerm;
    function GetTermCount: Integer;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
    function AddTerm(const ATagName: string; ACoefficient: Double): TRecorderFrequencyBandTerm;
    procedure DeleteTerm(AIndex: Integer);
    procedure ClearTerms;
    procedure Validate;
    procedure Evaluate(ATagRegistry: TObject; out AF1, AF2: Double);
    property Name: string read fName write fName;
    property Kind: TRecorderFrequencyBandKind read fKind write fKind;
    property X1: Double read fX1 write fX1;
    property X2: Double read fX2 write fX2;
    property TermCount: Integer read GetTermCount;
    property Terms[AIndex: Integer]: TRecorderFrequencyBandTerm read GetTerm;
  end;

  TRecorderFrequencyBandList = class
  private
    fBands: TList;
    function GetBand(AIndex: Integer): TRecorderFrequencyBand;
    function GetBandCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function AddBand(const AName: string): TRecorderFrequencyBand;
    procedure DeleteBand(AIndex: Integer);
    procedure Clear;
    procedure Assign(ASource: TRecorderFrequencyBandList);
    property BandCount: Integer read GetBandCount;
    property Bands[AIndex: Integer]: TRecorderFrequencyBand read GetBand;
  end;

implementation

uses
  uRecorderTags;

constructor TRecorderFrequencyBandTerm.Create(const ATagName: string;
  ACoefficient: Double);
begin
  inherited Create;
  fTagName := ATagName;
  fCoefficient := ACoefficient;
end;

constructor TRecorderFrequencyBand.Create(const AName: string);
begin
  inherited Create;
  fName := AName;
  fKind := fbkAbsoluteHz;
  fX1 := 0.0;
  fX2 := 0.0;
  fTerms := TList.Create;
end;

destructor TRecorderFrequencyBand.Destroy;
begin
  ClearTerms;
  fTerms.Free;
  inherited Destroy;
end;

function TRecorderFrequencyBand.GetTerm(AIndex: Integer): TRecorderFrequencyBandTerm;
begin
  Result := TRecorderFrequencyBandTerm(fTerms[AIndex]);
end;

function TRecorderFrequencyBand.GetTermCount: Integer;
begin
  Result := fTerms.Count;
end;

function TRecorderFrequencyBand.AddTerm(const ATagName: string;
  ACoefficient: Double): TRecorderFrequencyBandTerm;
begin
  Result := TRecorderFrequencyBandTerm.Create(ATagName, ACoefficient);
  fTerms.Add(Result);
end;

procedure TRecorderFrequencyBand.DeleteTerm(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= fTerms.Count) then
    Exit;
  TObject(fTerms[AIndex]).Free;
  fTerms.Delete(AIndex);
end;

procedure TRecorderFrequencyBand.ClearTerms;
var
  I: Integer;
begin
  for I := 0 to fTerms.Count - 1 do
    TObject(fTerms[I]).Free;
  fTerms.Clear;
end;

procedure TRecorderFrequencyBand.Validate;
begin
  if Trim(fName) = '' then
    raise ERecorderFrequencyBandError.Create('Frequency band name cannot be empty');
  if fX2 < fX1 then
    raise ERecorderFrequencyBandError.CreateFmt(
      'Frequency band end must be greater than start: %s', [fName]);
  if (fKind = fbkFormula) and (fTerms.Count = 0) then
    raise ERecorderFrequencyBandError.CreateFmt(
      'Formula frequency band must have at least one term: %s', [fName]);
end;

constructor TRecorderFrequencyBandList.Create;
begin
  inherited Create;
  fBands := TList.Create;
end;

destructor TRecorderFrequencyBandList.Destroy;
begin
  Clear;
  fBands.Free;
  inherited Destroy;
end;

function TRecorderFrequencyBandList.GetBand(AIndex: Integer): TRecorderFrequencyBand;
begin
  Result := TRecorderFrequencyBand(fBands[AIndex]);
end;

function TRecorderFrequencyBandList.GetBandCount: Integer;
begin
  Result := fBands.Count;
end;

function TRecorderFrequencyBandList.AddBand(
  const AName: string): TRecorderFrequencyBand;
begin
  Result := TRecorderFrequencyBand.Create(AName);
  fBands.Add(Result);
end;

procedure TRecorderFrequencyBandList.DeleteBand(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= fBands.Count) then
    Exit;
  TObject(fBands[AIndex]).Free;
  fBands.Delete(AIndex);
end;

procedure TRecorderFrequencyBandList.Clear;
var
  I: Integer;
begin
  for I := 0 to fBands.Count - 1 do
    TObject(fBands[I]).Free;
  fBands.Clear;
end;

procedure TRecorderFrequencyBand.Evaluate(ATagRegistry: TObject; out AF1, AF2: Double);
var
  lRegistry: TRecorderTagRegistry;
  I: Integer;
  lTerm: TRecorderFrequencyBandTerm;
  lTag: TRecorderTag;
  lVal: Double;
  lBase: Double;
begin
  if fKind = fbkAbsoluteHz then
  begin
    AF1 := fX1;
    AF2 := fX2;
    Exit;
  end;

  lBase := 0.0;
  if ATagRegistry <> nil then
  begin
    lRegistry := TRecorderTagRegistry(ATagRegistry);
    for I := 0 to TermCount - 1 do
    begin
      lTerm := Terms[I];
      lTag := lRegistry.FindByName(lTerm.TagName);
      if (lTag <> nil) and (lTag.SignalBuffer <> nil) and (lTag.SignalBuffer.Count > 0) then
        lVal := lTag.SignalBuffer.LatestValue
      else
        lVal := 0.0;
      lBase := lBase + lVal * lTerm.Coefficient;
    end;
  end;

  AF1 := lBase * fX1;
  AF2 := lBase * fX2;
end;

procedure TRecorderFrequencyBandList.Assign(ASource: TRecorderFrequencyBandList);
var
  I, J: Integer;
  lSrcBand, lDestBand: TRecorderFrequencyBand;
begin
  if ASource = nil then Exit;
  Clear;
  for I := 0 to ASource.BandCount - 1 do
  begin
    lSrcBand := ASource.Bands[I];
    lDestBand := AddBand(lSrcBand.Name);
    lDestBand.Kind := lSrcBand.Kind;
    lDestBand.X1 := lSrcBand.X1;
    lDestBand.X2 := lSrcBand.X2;
    lDestBand.ClearTerms;
    for J := 0 to lSrcBand.TermCount - 1 do
    begin
      lDestBand.AddTerm(lSrcBand.Terms[J].TagName, lSrcBand.Terms[J].Coefficient);
    end;
  end;
end;

end.
