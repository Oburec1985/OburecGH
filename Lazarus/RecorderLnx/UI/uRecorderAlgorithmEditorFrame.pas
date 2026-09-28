unit uRecorderAlgorithmEditorFrame;

{ Общий контракт визуальных редакторов runtime-алгоритмов.
  Расчётные классы не зависят от LCL: соответствие Type -> frame хранится
  только в UI-регистре этого модуля. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, StdCtrls, uRecorderTags,
  uRecorderAlgorithmManager;

type
  TRecorderAlgorithmEditorFrame = class(TFrame)
  private
    fAlgorithm: TRecorderAlgorithm;
    fTagRegistry: TRecorderTagRegistry;
  protected
    procedure FillTagCombo(ACombo: TComboBox);
    function BindingName(AIndex: Integer): string;
    procedure SetBindingName(AIndex: Integer; const ATagName: string;
      const AProperties: string = '');
    procedure LoadFromAlgorithm; virtual; abstract;
    procedure SaveToAlgorithm; virtual; abstract;
    property Algorithm: TRecorderAlgorithm read fAlgorithm;
    property TagRegistry: TRecorderTagRegistry read fTagRegistry;
  public
    procedure SetContext(AAlgorithm: TRecorderAlgorithm;
      ATagRegistry: TRecorderTagRegistry); virtual;
    procedure Apply; virtual;
  end;

  TRecorderAlgorithmEditorFrameClass = class of TRecorderAlgorithmEditorFrame;

procedure RegisterRecorderAlgorithmEditor(const ATypeName: string;
  AFrameClass: TRecorderAlgorithmEditorFrameClass);
function CreateRecorderAlgorithmEditor(const ATypeName: string;
  AOwner: TComponent): TRecorderAlgorithmEditorFrame;
function RecorderAlgorithmProperty(const AProperties, AName,
  ADefault: string): string;
function RecorderSetAlgorithmProperty(const AProperties, AName,
  AValue: string): string;
function RecorderAlgorithmFloat(const AProperties, AName: string;
  ADefault: Double): Double;
function RecorderInvariantFloat(AValue: Double): string;

implementation

var
  g_EditorClasses: TStringList;

function NormalizeProperties(const AProperties: string): string;
begin
  Result := StringReplace(AProperties, ';', LineEnding, [rfReplaceAll]);
end;

function RecorderAlgorithmProperty(const AProperties, AName,
  ADefault: string): string;
var
  lItems: TStringList;
begin
  lItems := TStringList.Create;
  try
    lItems.Text := NormalizeProperties(AProperties);
    Result := lItems.Values[AName];
    if Result = '' then
      Result := ADefault;
  finally
    lItems.Free;
  end;
end;

function RecorderSetAlgorithmProperty(const AProperties, AName,
  AValue: string): string;
var
  lItems: TStringList;
  I: Integer;
begin
  lItems := TStringList.Create;
  try
    lItems.Text := NormalizeProperties(AProperties);
    lItems.Values[AName] := AValue;
    Result := '';
    for I := 0 to lItems.Count - 1 do
      if Trim(lItems[I]) <> '' then
      begin
        if Result <> '' then
          Result := Result + ';';
        Result := Result + Trim(lItems[I]);
      end;
  finally
    lItems.Free;
  end;
end;

function RecorderAlgorithmFloat(const AProperties, AName: string;
  ADefault: Double): Double;
var
  lText: string;
begin
  lText := RecorderAlgorithmProperty(AProperties, AName, '');
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  if not TryStrToFloat(lText, Result) then
    Result := ADefault;
end;

function RecorderInvariantFloat(AValue: Double): string;
begin
  Result := StringReplace(FloatToStr(AValue),
    DefaultFormatSettings.DecimalSeparator, '.', [rfReplaceAll]);
end;

procedure RegisterRecorderAlgorithmEditor(const ATypeName: string;
  AFrameClass: TRecorderAlgorithmEditorFrameClass);
var
  lIndex: Integer;
begin
  if (Trim(ATypeName) = '') or (AFrameClass = nil) then
    Exit;
  lIndex := g_EditorClasses.IndexOf(ATypeName);
  if lIndex < 0 then
    g_EditorClasses.AddObject(ATypeName, TObject(AFrameClass))
  else
    g_EditorClasses.Objects[lIndex] := TObject(AFrameClass);
end;

function CreateRecorderAlgorithmEditor(const ATypeName: string;
  AOwner: TComponent): TRecorderAlgorithmEditorFrame;
var
  lIndex: Integer;
  lClass: TRecorderAlgorithmEditorFrameClass;
begin
  Result := nil;
  lIndex := g_EditorClasses.IndexOf(ATypeName);
  if lIndex < 0 then
    Exit;
  lClass := TRecorderAlgorithmEditorFrameClass(g_EditorClasses.Objects[lIndex]);
  Result := lClass.Create(AOwner);
end;

procedure TRecorderAlgorithmEditorFrame.FillTagCombo(ACombo: TComboBox);
var
  I: Integer;
begin
  if ACombo = nil then
    Exit;
  ACombo.Items.BeginUpdate;
  try
    ACombo.Items.Clear;
    if fTagRegistry <> nil then
      for I := 0 to fTagRegistry.TagCount - 1 do
        ACombo.Items.Add(fTagRegistry.Tags[I].Name);
  finally
    ACombo.Items.EndUpdate;
  end;
end;

function TRecorderAlgorithmEditorFrame.BindingName(AIndex: Integer): string;
begin
  Result := '';
  if (fAlgorithm <> nil) and (AIndex >= 0) and
    (AIndex < fAlgorithm.BindingCount) then
    Result := fAlgorithm.Binding(AIndex).TagName;
end;

procedure TRecorderAlgorithmEditorFrame.SetBindingName(AIndex: Integer;
  const ATagName: string; const AProperties: string);
var
  lBinding: TRecorderAlgorithmBinding;
  lTag: TRecorderTag;
begin
  if fAlgorithm = nil then
    Exit;
  while fAlgorithm.BindingCount <= AIndex do
    fAlgorithm.AddBinding(nil);
  lBinding := fAlgorithm.Binding(AIndex);
  lBinding.TagName := Trim(ATagName);
  lBinding.TagId := 0;
  lBinding.Properties := AProperties;
  if (fTagRegistry <> nil) and (lBinding.TagName <> '') then
  begin
    lTag := fTagRegistry.FindByName(lBinding.TagName);
    if lTag <> nil then
      lBinding.TagId := lTag.Id;
  end;
end;

procedure TRecorderAlgorithmEditorFrame.SetContext(
  AAlgorithm: TRecorderAlgorithm; ATagRegistry: TRecorderTagRegistry);
begin
  fAlgorithm := AAlgorithm;
  fTagRegistry := ATagRegistry;
  LoadFromAlgorithm;
end;

procedure TRecorderAlgorithmEditorFrame.Apply;
begin
  SaveToAlgorithm;
end;

initialization
  g_EditorClasses := TStringList.Create;
  g_EditorClasses.CaseSensitive := False;
  g_EditorClasses.Sorted := True;
  g_EditorClasses.Duplicates := dupIgnore;

finalization
  g_EditorClasses.Free;

end.
