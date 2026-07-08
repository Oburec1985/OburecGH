unit uRecorderConfiguredSourceEditor;

{
  Абстракция настройки сконфигурированного источника данных в UI.
  Диалог настроек вызывает RecorderEditConfiguredDataSource; конкретный
  диалог прибора — в регистрации устройства (MIC-140, MIC183/185, …).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderTags, uRecorderConfiguredDataSources;

type
  IRecorderConfiguredSourceEditor = interface
    ['{A4E8C1F2-6B3D-4F9A-9E2C-1D5A7B8C9E0F}']
    function SupportsSource(const ASourceId, AModuleType: string): Boolean;
    function EditSource(AOwner: TComponent; ARegistry: TRecorderTagRegistry;
      const ASourceId: string; out ANewSourceId: string): Boolean;
  end;

procedure RecorderRegisterConfiguredSourceEditor(
  const AEditor: IRecorderConfiguredSourceEditor);

function RecorderEditConfiguredDataSource(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string; const AModuleTypeHint: string = ''): Boolean;

function RecorderResolveConfiguredSourceModuleType(
  ARegistry: TRecorderTagRegistry; const ASourceId: string): string;

implementation

type
  TRecorderConfiguredSourceEditorList = class
  private
    fItems: array of IRecorderConfiguredSourceEditor;
  public
    procedure Add(const AEditor: IRecorderConfiguredSourceEditor);
    function FindEditor(const ASourceId, AModuleType: string)
      : IRecorderConfiguredSourceEditor;
  end;

var
  GConfiguredSourceEditors: TRecorderConfiguredSourceEditorList = nil;

procedure TRecorderConfiguredSourceEditorList.Add(
  const AEditor: IRecorderConfiguredSourceEditor);
var
  lIndex: Integer;
begin
  if AEditor = nil then
    Exit;
  for lIndex := 0 to High(fItems) do
    if fItems[lIndex] = AEditor then
      Exit;
  lIndex := Length(fItems);
  SetLength(fItems, lIndex + 1);
  fItems[lIndex] := AEditor;
end;

function TRecorderConfiguredSourceEditorList.FindEditor(
  const ASourceId, AModuleType: string): IRecorderConfiguredSourceEditor;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to High(fItems) do
    if fItems[lIndex].SupportsSource(ASourceId, AModuleType) then
      Exit(fItems[lIndex]);
end;

procedure EnsureEditorList;
begin
  if GConfiguredSourceEditors = nil then
    GConfiguredSourceEditors := TRecorderConfiguredSourceEditorList.Create;
end;

procedure RecorderRegisterConfiguredSourceEditor(
  const AEditor: IRecorderConfiguredSourceEditor);
begin
  EnsureEditorList;
  GConfiguredSourceEditors.Add(AEditor);
end;

function RecorderResolveConfiguredSourceModuleType(
  ARegistry: TRecorderTagRegistry; const ASourceId: string): string;
var
  lEntry: TRecorderConfiguredDataSource;
begin
  Result := '';
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  if lEntry <> nil then
    Result := lEntry.ModuleType;
end;

function RecorderEditConfiguredDataSource(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string; const AModuleTypeHint: string): Boolean;
var
  lEditor: IRecorderConfiguredSourceEditor;
  lModuleType: string;
begin
  Result := False;
  ANewSourceId := ASourceId;
  if ARegistry = nil then
    Exit;
  EnsureEditorList;
  lModuleType := AModuleTypeHint;
  if lModuleType = '' then
    lModuleType := RecorderResolveConfiguredSourceModuleType(ARegistry, ASourceId);
  lEditor := GConfiguredSourceEditors.FindEditor(ASourceId, lModuleType);
  if lEditor = nil then
    Exit;
  Result := lEditor.EditSource(AOwner, ARegistry, ASourceId, ANewSourceId);
end;

finalization
  FreeAndNil(GConfiguredSourceEditors);

end.
