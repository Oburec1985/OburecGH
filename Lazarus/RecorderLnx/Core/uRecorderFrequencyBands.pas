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
    property BandCount: Integer read GetBandCount;
    property Bands[AIndex: Integer]: TRecorderFrequencyBand read GetBand;
  end;

implementation

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

end.
