unit uRecorderSqlDbProjectManager;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderSqlDbTypes, uRecorderFormModel;

type
  TRecorderSqlDbProjectSyncResult = record
    ConfigSignalCount: Integer;
    TrendLineCount: Integer;
  end;

  { Coordinates SQLdb settings with visual components that consume SQLdb data. }
  TRecorderSqlDbProjectManager = class
  public
    class function RemoveSignals(AConfig: TRecorderSqlDbConfig;
      AFormManager: TRecorderFormManager;
      ASignalNames: TStrings): TRecorderSqlDbProjectSyncResult; static;
  end;

implementation

uses
  uRecorderSqlTrendModel;

class function TRecorderSqlDbProjectManager.RemoveSignals(
  AConfig: TRecorderSqlDbConfig; AFormManager: TRecorderFormManager;
  ASignalNames: TStrings): TRecorderSqlDbProjectSyncResult;
var
  I: Integer;
  lIndex: Integer;
  lPageIndex: Integer;
  lComponentIndex: Integer;
  lPage: TRecorderFormPage;
  lComponent: TRecorderVisualComponent;
begin
  Result.ConfigSignalCount := 0;
  Result.TrendLineCount := 0;
  if (ASignalNames = nil) or (ASignalNames.Count = 0) then
    Exit;

  if AConfig <> nil then
  begin
    for I := 0 to ASignalNames.Count - 1 do
    begin
      lIndex := AConfig.SignalNames.IndexOf(ASignalNames[I]);
      if lIndex < 0 then
        Continue;
      AConfig.SignalNames.Delete(lIndex);
      Inc(Result.ConfigSignalCount);
    end;
    if Result.ConfigSignalCount > 0 then
      AConfig.SignalSelectionConfigured := True;
  end;

  if AFormManager = nil then
    Exit;

  for lPageIndex := 0 to AFormManager.PageCount - 1 do
  begin
    lPage := AFormManager.Pages[lPageIndex];
    for lComponentIndex := 0 to lPage.ComponentCount - 1 do
    begin
      lComponent := lPage.Components[lComponentIndex];
      if lComponent is TRecorderSqlTrendComponent then
        Inc(Result.TrendLineCount,
          TRecorderSqlTrendComponent(lComponent).RemoveLinesByTagNames(
            ASignalNames));
    end;
  end;
end;

end.
