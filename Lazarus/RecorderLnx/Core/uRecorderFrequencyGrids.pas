unit uRecorderFrequencyGrids;

{
  Универсальный реестр частотных сеток аппаратных источников.

  Конкретный модуль регистрирует свою сетку по префиксу SourceId. Диалоги знают
  только этот контракт и не содержат таблиц MIC/MC и зависимостей от драйверов.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  TRecorderFrequencyGrid = array of Double;

procedure RecorderRegisterFrequencyGrid(const ASourcePrefix: string;
  const AFrequencies: array of Double);
function RecorderFrequencyGridForSource(const ASourceId: string;
  out AGrid: TRecorderFrequencyGrid): Boolean;

implementation

uses
  Classes, SysUtils;

type
  TRecorderFrequencyGridEntry = class
  public
    SourcePrefix: string;
    Frequencies: TRecorderFrequencyGrid;
  end;

var
  gFrequencyGrids: TList;

procedure RecorderRegisterFrequencyGrid(const ASourcePrefix: string;
  const AFrequencies: array of Double);
var
  I, J: Integer;
  lEntry: TRecorderFrequencyGridEntry;
begin
  if Trim(ASourcePrefix) = '' then
    Exit;
  if gFrequencyGrids = nil then
    gFrequencyGrids := TList.Create;
  for I := 0 to gFrequencyGrids.Count - 1 do
  begin
    lEntry := TRecorderFrequencyGridEntry(gFrequencyGrids[I]);
    if SameText(lEntry.SourcePrefix, ASourcePrefix) then
    begin
      SetLength(lEntry.Frequencies, Length(AFrequencies));
      for J := 0 to High(AFrequencies) do
        lEntry.Frequencies[J] := AFrequencies[J];
      Exit;
    end;
  end;
  lEntry := TRecorderFrequencyGridEntry.Create;
  lEntry.SourcePrefix := ASourcePrefix;
  SetLength(lEntry.Frequencies, Length(AFrequencies));
  for I := 0 to High(AFrequencies) do
    lEntry.Frequencies[I] := AFrequencies[I];
  gFrequencyGrids.Add(lEntry);
end;

function RecorderFrequencyGridForSource(const ASourceId: string;
  out AGrid: TRecorderFrequencyGrid): Boolean;
var
  I, J, lBestLength: Integer;
  lEntry: TRecorderFrequencyGridEntry;
  lBestEntry: TRecorderFrequencyGridEntry;
begin
  SetLength(AGrid, 0);
  Result := False;
  if gFrequencyGrids = nil then
    Exit;
  lBestEntry := nil;
  lBestLength := -1;
  for I := 0 to gFrequencyGrids.Count - 1 do
  begin
    lEntry := TRecorderFrequencyGridEntry(gFrequencyGrids[I]);
    if (Pos(lEntry.SourcePrefix, ASourceId) = 1) and
      (Length(lEntry.SourcePrefix) > lBestLength) then
    begin
      lBestEntry := lEntry;
      lBestLength := Length(lEntry.SourcePrefix);
    end;
  end;
  if lBestEntry = nil then
    Exit;
  SetLength(AGrid, Length(lBestEntry.Frequencies));
  for J := 0 to High(lBestEntry.Frequencies) do
    AGrid[J] := lBestEntry.Frequencies[J];
  Result := True;
end;

var
  I: Integer;

finalization
  if gFrequencyGrids <> nil then
  begin
    for I := gFrequencyGrids.Count - 1 downto 0 do
      TObject(gFrequencyGrids[I]).Free;
    FreeAndNil(gFrequencyGrids);
  end;

end.
