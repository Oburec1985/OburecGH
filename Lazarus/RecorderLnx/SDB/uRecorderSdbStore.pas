unit uRecorderSdbStore;

{
  Native, cross-platform reader for the Mera Scales DataBase (SDB).

  Original Recorder accesses SDB through Windows COM interfaces. The on-disk
  contract is portable: a root descriptor (sdb.xml), folder descriptors and a
  pair of XML metadata plus CSV points per scale. This unit is read-only.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uBaseObjLaz, uRecorderSdbTypes, uRecorderTags;

type
  { One native SDB tree node. Folders have children; scale nodes carry the
    metadata that identifies their CSV point table. }
  TRecorderSdbNode = class(TBaseObj)
  private
    fItemKind: TSdbItemKind;
    fScaleInfo: TSdbScaleInfo;
    fFolderInfo: TSdbFolderInfo;
  public
    property ItemKind: TSdbItemKind read fItemKind write fItemKind;
    property ScaleInfo: TSdbScaleInfo read fScaleInfo write fScaleInfo;
    property FolderInfo: TSdbFolderInfo read fFolderInfo write fFolderInfo;
  end;

  { Read-only in-memory view of the disk SDB. It uses the shared hierarchy
    object, so future picker/tree UI can bind to the same model. }
  TRecorderSdbTree = class
  private
    fRoot: TRecorderSdbNode;
    function EnsureFolder(AParent: TRecorderSdbNode;
      const AName, AKey: string): TRecorderSdbNode;
    procedure LoadDirectory(AParent: TRecorderSdbNode;
      const ADiskDir, AKey: string);
    procedure LoadScalePairs(AParent: TRecorderSdbNode;
      const ADiskDir, AKey: string);
    procedure CollectScaleKeys(ANode: TRecorderSdbNode;
      const AFolderKey: string; AKeys: TStrings);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load;
    procedure ListScaleKeys(const AFolderKey: string; AKeys: TStrings);
    property Root: TRecorderSdbNode read fRoot;
  end;

function RecorderSdbRootDir: string;
function RecorderSdbNormalizeKey(const AKey: string): string;
function RecorderSdbScaleXmlPath(const AKey: string): string;
function RecorderSdbScaleCsvPath(const AKey: string): string;
function RecorderSdbScaleJsonPath(const AKey: string): string;
procedure RecorderSdbListScaleKeys(const AFolderKey: string; AKeys: TStrings);
function RecorderSdbTryLoadScale(const AKey: string; out AInfo: TSdbScaleInfo): Boolean;
function RecorderSdbLoadScaleCalibrationFromInfo(const AInfo: TSdbScaleInfo;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderSdbLoadScaleCalibration(const AKey: string;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderSdbLoadScaleCalibrationFromCsv(const ACsvPath, AKey: string;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderSdbImportCalibration(AList: TRecorderCalibrationList;
  const AKey: string; out ACalibrationName: string): Boolean;
function RecorderSdbExportCalibration(const AFolderKey: string;
  ACalibration: TRecorderCalibration; AOverwrite: Boolean;
  out ACreatedKey, AError: string): Boolean;
function RecorderSdbUpdateCalibration(const AKey: string;
  ACalibration: TRecorderCalibration; out AError: string): Boolean;
function RecorderSdbCreateFolder(const AParentKey, AName: string;
  out ACreatedKey, AError: string): Boolean;

function RecorderSdbNodeDisplayName(ANode: TRecorderSdbNode): string;
function RecorderSdbNodeDisplayDescription(ANode: TRecorderSdbNode): string;
procedure RecorderSdbReloadNodeMetadata(ANode: TRecorderSdbNode);

implementation

uses
  FileUtil, LazFileUtils, StrUtils, Math, fpjson, jsonparser,
  uRecorderMeraPaths, uRecorderSdbPropBag, uSharedStringEncoding;

function RecorderSdbTryLoadScaleFromPaths(const AKey, AXmlPath, ACsvPath: string;
  out AInfo: TSdbScaleInfo): Boolean; forward;

function RecorderSdbRootDir: string;
var
  lBase: string;
begin
  lBase := IncludeTrailingPathDelimiter(RecorderMeraFilesPath);
  if DirectoryExists(lBase + 'SDB') then
    Result := lBase + 'SDB' + PathDelim
  else
    Result := lBase + 'sdb' + PathDelim;
end;

function SdbSafeFileName(const AName: string): string;
var
  I: Integer;
begin
  Result := Trim(AName);
  for I := 1 to Length(Result) do
    if Result[I] in ['<', '>', ':', '"', '/', '\', '|', '?', '*'] then
      Result[I] := '_';
  while (Length(Result) > 0) and (Result[Length(Result)] in [' ', '.']) do
    Delete(Result, Length(Result), 1);
end;

function SdbInvariantFloat(AValue: Double): string;
var
  lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  Result := FloatToStr(AValue, lFormat);
end;

function SdbChildNameExists(const AParentDir, AName: string): Boolean;
var
  lCode: Integer;
  lInfo: TSearchRec;
begin
  Result := False;
  lCode := FindFirstUTF8(IncludeTrailingPathDelimiter(AParentDir) + '*',
    faDirectory, lInfo);
  if lCode <> 0 then
    Exit;
  try
    while lCode = 0 do
    begin
      if ((lInfo.Attr and faDirectory) <> 0) and
        (lInfo.Name <> '.') and (lInfo.Name <> '..') and
        SameText(lInfo.Name, AName) then
      begin
        Result := True;
        Exit;
      end;
      lCode := FindNextUTF8(lInfo);
    end;
  finally
    FindCloseUTF8(lInfo);
  end;
end;

function RecorderSdbCreateFolder(const AParentKey, AName: string;
  out ACreatedKey, AError: string): Boolean;
var
  lDir: string;
  lName: string;
  lParentDir: string;
  lParentKey: string;
  lProps: TSdbPropBag;
  lXmlPath: string;
  lXmlTemp: string;
begin
  Result := False;
  ACreatedKey := '';
  AError := '';
  lParentKey := RecorderSdbNormalizeKey(AParentKey);
  if (Pos('..', lParentKey) > 0) or (Pos(':', lParentKey) > 0) then
  begin
    AError := 'Недопустимый путь родительского каталога.';
    Exit;
  end;
  lName := SdbSafeFileName(AName);
  if (lName = '') or (lName = '.') or (Pos('..', lName) > 0) or
    SameText(ExtractFileExt(lName), '.xml') or
    SameText(ExtractFileExt(lName), '.csv') or
    not SameText(lName, Trim(AName)) then
  begin
    AError := 'Имя каталога содержит недопустимые символы.';
    Exit;
  end;
  lParentDir := IncludeTrailingPathDelimiter(RecorderSdbRootDir);
  if lParentKey <> '' then
    lParentDir := lParentDir +
      StringReplace(lParentKey, '\', PathDelim, [rfReplaceAll]) + PathDelim;
  if not DirectoryExistsUTF8(lParentDir) then
  begin
    AError := 'Родительский каталог БДГХ не найден.';
    Exit;
  end;
  lDir := lParentDir + lName;
  if SdbChildNameExists(lParentDir, lName) or FileExistsUTF8(lDir) then
  begin
    AError := 'Каталог с таким именем уже существует.';
    Exit;
  end;
  if not CreateDirUTF8(lDir) then
  begin
    AError := 'Не удалось создать каталог БДГХ.';
    Exit;
  end;
  lXmlPath := IncludeTrailingPathDelimiter(lDir) + lName + '.xml';
  lXmlTemp := lXmlPath + '.tmp';
  lProps := TSdbPropBag.Create;
  try
    try
      lProps.SetProp('name', lName);
      lProps.SetProp('dsc', '');
      lProps.SaveToFile(lXmlTemp);
      if not FileExistsUTF8(lXmlTemp) then
        raise Exception.Create('Не удалось создать описание каталога БДГХ.');
      if not RenameFileUTF8(lXmlTemp, lXmlPath) then
        raise Exception.Create('Не удалось сохранить описание каталога БДГХ.');
      if lParentKey <> '' then
        ACreatedKey := lParentKey + '\' + lName
      else
        ACreatedKey := lName;
      Result := True;
    except
      on E: Exception do
      begin
        AError := E.Message;
        DeleteFileUTF8(lXmlTemp);
        DeleteFileUTF8(lXmlPath);
        RemoveDirUTF8(lDir);
      end;
    end;
  finally
    lProps.Free;
  end;
end;

function SdbCalibrationKindName(AKind: TRecorderCalibrationKind): string;
begin
  case AKind of
    rckScale: Result := 'scale';
    rckStrain: Result := 'strain';
  else
    Result := 'piecewiseLinear';
  end;
end;

function SdbCalibrationKind(const AName: string;
  out AKind: TRecorderCalibrationKind): Boolean;
begin
  Result := True;
  if SameText(AName, 'scale') then
    AKind := rckScale
  else if SameText(AName, 'strain') then
    AKind := rckStrain
  else if SameText(AName, 'piecewiseLinear') then
    AKind := rckPiecewiseLinear
  else
    Result := False;
end;

function SdbCalibrationJson(ACalibration: TRecorderCalibration): string;
var
  I: Integer;
  lJson: TJSONObject;
  lPoint: TJSONObject;
  lPoints: TJSONArray;
begin
  lJson := TJSONObject.Create;
  try
    lJson.Add('format', 'RecorderLnxCalibration');
    lJson.Add('version', 1);
    lJson.Add('type', SdbCalibrationKindName(ACalibration.Kind));
    lJson.Add('name', ACalibration.Name);
    lJson.Add('description', ACalibration.Description);
    lJson.Add('unitIn', ACalibration.UnitIn);
    lJson.Add('unitOut', ACalibration.UnitOut);
    lJson.Add('extrapolation', ACalibration.Extrapolation);
    lJson.Add('scale', ACalibration.Scale);
    lJson.Add('offset', ACalibration.Offset);
    lJson.Add('k1', ACalibration.K1);
    lJson.Add('k2', ACalibration.K2);
    lJson.Add('moduleData', ACalibration.ModuleData);
    lPoints := TJSONArray.Create;
    lJson.Add('points', lPoints);
    for I := 0 to ACalibration.PointCount - 1 do
    begin
      lPoint := TJSONObject.Create;
      lPoint.Add('x', ACalibration.PointAt(I).X);
      lPoint.Add('y', ACalibration.PointAt(I).Y);
      lPoints.Add(lPoint);
    end;
    Result := lJson.FormatJSON;
  finally
    lJson.Free;
  end;
end;

function SdbReadJsonCalibration(const APath: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  I: Integer;
  lData: TJSONData;
  lJson: TJSONObject;
  lKind: TRecorderCalibrationKind;
  lLines: TStringList;
  lPoint: TJSONObject;
  lPoints: TJSONArray;
begin
  Result := False;
  if (ACalibration = nil) or not FileExistsUTF8(APath) then
    Exit;
  lLines := TStringList.Create;
  lData := nil;
  try
    lLines.LoadFromFile(APath);
    lData := GetJSON(lLines.Text);
    if not (lData is TJSONObject) then
      Exit;
    lJson := TJSONObject(lData);
    if not SameText(lJson.Get('format', ''), 'RecorderLnxCalibration') or
      (lJson.Get('version', 0) <> 1) or
      not SdbCalibrationKind(lJson.Get('type', ''), lKind) then
      Exit;
    ACalibration.ClearPoints;
    ACalibration.Kind := lKind;
    ACalibration.Name := lJson.Get('name', '');
    ACalibration.Description := lJson.Get('description', '');
    ACalibration.UnitIn := lJson.Get('unitIn', '');
    ACalibration.UnitOut := lJson.Get('unitOut', '');
    ACalibration.Extrapolation := lJson.Get('extrapolation', True);
    ACalibration.Scale := lJson.Get('scale', 1.0);
    ACalibration.Offset := lJson.Get('offset', 0.0);
    ACalibration.K1 := lJson.Get('k1', 1.0);
    ACalibration.K2 := lJson.Get('k2', 0.0);
    ACalibration.ModuleData := lJson.Get('moduleData', '');
    lPoints := lJson.Arrays['points'];
    if lPoints <> nil then
      for I := 0 to lPoints.Count - 1 do
        if lPoints.Items[I] is TJSONObject then
        begin
          lPoint := TJSONObject(lPoints.Items[I]);
          ACalibration.AddPoint(lPoint.Get('x', 0.0), lPoint.Get('y', 0.0));
        end;
    Result := True;
  except
    Result := False;
  end;
  lData.Free;
  lLines.Free;
end;

function SdbLoadJsonCalibration(const APath: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  lLoaded: TRecorderCalibration;
begin
  Result := False;
  if ACalibration = nil then
    Exit;
  lLoaded := TRecorderCalibration.Create(rckScale);
  try
    if not SdbReadJsonCalibration(APath, lLoaded) then
      Exit;
    ACalibration.Assign(lLoaded);
    Result := True;
  finally
    lLoaded.Free;
  end;
end;

function SdbTryLoadJsonInfo(const AKey, APath: string;
  out AInfo: TSdbScaleInfo): Boolean;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lPoint: TRecorderCalibrationPoint;
begin
  AInfo := Default(TSdbScaleInfo);
  lCalibration := TRecorderCalibration.Create(rckScale);
  try
    Result := SdbLoadJsonCalibration(APath, lCalibration);
    if not Result then
      Exit;
    AInfo.Key := RecorderSdbNormalizeKey(AKey);
    AInfo.Name := lCalibration.Name;
    AInfo.Description := lCalibration.Description;
    AInfo.SrcUnits := lCalibration.UnitIn;
    AInfo.DstUnits := lCalibration.UnitOut;
    AInfo.JsonPath := APath;
    if lCalibration.PointCount > 0 then
    begin
      lPoint := lCalibration.PointAt(0);
      AInfo.SrcFrom := lPoint.X;
      AInfo.SrcTo := lPoint.X;
      AInfo.DstFrom := lPoint.Y;
      AInfo.DstTo := lPoint.Y;
      for I := 1 to lCalibration.PointCount - 1 do
      begin
        lPoint := lCalibration.PointAt(I);
        AInfo.SrcFrom := Min(AInfo.SrcFrom, lPoint.X);
        AInfo.SrcTo := Max(AInfo.SrcTo, lPoint.X);
        AInfo.DstFrom := Min(AInfo.DstFrom, lPoint.Y);
        AInfo.DstTo := Max(AInfo.DstTo, lPoint.Y);
      end;
    end;
  finally
    lCalibration.Free;
  end;
end;

function SdbSameCalibration(AExpected, AActual: TRecorderCalibration): Boolean;
var
  I: Integer;
begin
  Result := (AExpected <> nil) and (AActual <> nil) and
    (AExpected.Kind = AActual.Kind) and
    (AExpected.Name = AActual.Name) and
    (AExpected.Description = AActual.Description) and
    (AExpected.UnitIn = AActual.UnitIn) and
    (AExpected.UnitOut = AActual.UnitOut) and
    (AExpected.Extrapolation = AActual.Extrapolation) and
    SameValue(AExpected.Scale, AActual.Scale) and
    SameValue(AExpected.Offset, AActual.Offset) and
    SameValue(AExpected.K1, AActual.K1) and SameValue(AExpected.K2, AActual.K2) and
    (AExpected.ModuleData = AActual.ModuleData) and
    (AExpected.PointCount = AActual.PointCount);
  if not Result then
    Exit;
  for I := 0 to AExpected.PointCount - 1 do
    if not SameValue(AExpected.PointAt(I).X, AActual.PointAt(I).X) or
      not SameValue(AExpected.PointAt(I).Y, AActual.PointAt(I).Y) then
      Exit(False);
end;

function SdbExportJsonCalibration(const AKey: string;
  ACalibration: TRecorderCalibration; AOverwrite: Boolean;
  out AError: string): Boolean;
var
  lBackup: string;
  lBackupMade: Boolean;
  lCheck: TRecorderCalibration;
  lJsonPath: string;
  lLines: TStringList;
  lNewInstalled: Boolean;
  lTemp: string;
begin
  Result := False;
  AError := '';
  lJsonPath := RecorderSdbScaleJsonPath(AKey);
  if FileExistsUTF8(lJsonPath) and not AOverwrite then
  begin
    AError := 'EXISTS';
    Exit;
  end;
  lTemp := lJsonPath + '.tmp.' + IntToStr(GetTickCount64);
  lBackup := lJsonPath + '.bak.' + IntToStr(GetTickCount64);
  lBackupMade := False;
  lNewInstalled := False;
  lLines := TStringList.Create;
  lCheck := TRecorderCalibration.Create(rckScale);
  try
    lLines.Text := SdbCalibrationJson(ACalibration);
    lLines.SaveToFile(lTemp);
    if FileExistsUTF8(lJsonPath) and
      not RenameFileUTF8(lJsonPath, lBackup) then
      raise Exception.Create('Не удалось подготовить замену JSON БДГХ.');
    lBackupMade := FileExistsUTF8(lBackup);
    if not RenameFileUTF8(lTemp, lJsonPath) then
      raise Exception.Create('Не удалось записать JSON БДГХ.');
    lNewInstalled := True;
    if not SdbLoadJsonCalibration(lJsonPath, lCheck) or
      not SdbSameCalibration(ACalibration, lCheck) then
      raise Exception.Create('Записанная ГХ не прошла проверку чтением.');
    DeleteFileUTF8(lBackup);
    Result := True;
  except
    on E: Exception do
    begin
      AError := E.Message;
      if lNewInstalled then
        DeleteFileUTF8(lJsonPath);
      if lBackupMade and FileExistsUTF8(lBackup) then
        RenameFileUTF8(lBackup, lJsonPath);
    end;
  end;
  DeleteFileUTF8(lTemp);
  lCheck.Free;
  lLines.Free;
end;

function RecorderSdbUpdateCalibration(const AKey: string;
  ACalibration: TRecorderCalibration; out AError: string): Boolean;
begin
  Result := False;
  AError := '';
  if (ACalibration = nil) or (ACalibration.Kind <> rckStrain) then
  begin
    AError := 'Встроенное редактирование поддерживается только для тензокалькуляторной ГХ.';
    Exit;
  end;
  if not FileExistsUTF8(RecorderSdbScaleJsonPath(AKey)) then
  begin
    AError := 'JSON-файл выбранной ГХ не найден.';
    Exit;
  end;
  Result := SdbExportJsonCalibration(RecorderSdbNormalizeKey(AKey),
    ACalibration, True, AError);
end;

function RecorderSdbExportCalibration(const AFolderKey: string;
  ACalibration: TRecorderCalibration; AOverwrite: Boolean;
  out ACreatedKey, AError: string): Boolean;
var
  I: Integer;
  lBackupSuffix: string;
  lBaseName: string;
  lCsv: TStringList;
  lCsvBackup: string;
  lCsvPath: string;
  lCsvTemp: string;
  lFolder: string;
  lInfo: TSdbScaleInfo;
  lCsvInstalled: Boolean;
  lKey: string;
  lJsonBackup: string;
  lJsonPath: string;
  lMaxX: Double;
  lMaxY: Double;
  lMinX: Double;
  lMinY: Double;
  lPoint: TRecorderCalibrationPoint;
  lProps: TSdbPropBag;
  lXmlBackup: string;
  lXmlInstalled: Boolean;
  lXmlPath: string;
  lXmlTemp: string;
begin
  Result := False;
  ACreatedKey := '';
  AError := '';
  if ACalibration = nil then
  begin
    AError := 'ГХ не выбрана.';
    Exit;
  end;
  if (ACalibration.Kind = rckPiecewiseLinear) and
    (ACalibration.PointCount = 0) then
  begin
    AError := 'В ГХ нет точек для экспорта.';
    Exit;
  end;

  lBaseName := SdbSafeFileName(ACalibration.Name);
  if lBaseName = '' then
  begin
    AError := 'Имя ГХ не может использоваться как имя шкалы БДГХ.';
    Exit;
  end;
  lKey := RecorderSdbNormalizeKey(AFolderKey);
  if (Pos('..', lKey) > 0) or (Pos(':', lKey) > 0) then
  begin
    AError := 'Недопустимый путь папки БДГХ.';
    Exit;
  end;
  if lKey <> '' then
    lKey := lKey + '\' + lBaseName
  else
    lKey := lBaseName;
  lXmlPath := RecorderSdbScaleXmlPath(lKey);
  lCsvPath := RecorderSdbScaleCsvPath(lKey);
  lJsonPath := RecorderSdbScaleJsonPath(lKey);
  if (lXmlPath = '') or (lCsvPath = '') or (lJsonPath = '') then
  begin
    AError := 'Не удалось разрешить путь БДГХ.';
    Exit;
  end;
  if (FileExistsUTF8(lXmlPath) or FileExistsUTF8(lCsvPath) or
    FileExistsUTF8(lJsonPath)) and
    (not AOverwrite) then
  begin
    AError := 'EXISTS';
    ACreatedKey := lKey;
    Exit;
  end;

  lFolder := ExtractFileDir(lXmlPath);
  if not ForceDirectoriesUTF8(lFolder) then
  begin
    AError := 'Не удалось создать папку БДГХ: ' + lFolder;
    Exit;
  end;
  if ACalibration.Kind = rckStrain then
  begin
    Result := SdbExportJsonCalibration(lKey, ACalibration, AOverwrite, AError);
    if Result then
    begin
      DeleteFileUTF8(lXmlPath);
      DeleteFileUTF8(lCsvPath);
      ACreatedKey := lKey;
    end;
    Exit;
  end;
  lBackupSuffix := '.bak.' + IntToStr(GetTickCount64);
  lXmlTemp := lXmlPath + '.tmp.' + IntToStr(GetTickCount64);
  lCsvTemp := lCsvPath + '.tmp.' + IntToStr(GetTickCount64);
  lXmlBackup := lXmlPath + lBackupSuffix;
  lCsvBackup := lCsvPath + lBackupSuffix;
  lJsonBackup := lJsonPath + lBackupSuffix;
  lXmlInstalled := False;
  lCsvInstalled := False;

  lCsv := TStringList.Create;
  lProps := TSdbPropBag.Create;
  try
    if AOverwrite and FileExistsUTF8(lXmlPath) then
      lProps.LoadFromFile(lXmlPath);
    if ACalibration.Kind = rckScale then
    begin
      lCsv.Add('0;0');
      lCsv.Add('1;' + SdbInvariantFloat(ACalibration.Scale));
      lMinX := 0;
      lMaxX := 1;
      lMinY := Min(0, ACalibration.Scale);
      lMaxY := Max(0, ACalibration.Scale);
    end
    else
    begin
      lPoint := ACalibration.PointAt(0);
      lMinX := lPoint.X;
      lMaxX := lPoint.X;
      lMinY := lPoint.Y;
      lMaxY := lPoint.Y;
      for I := 0 to ACalibration.PointCount - 1 do
      begin
        lPoint := ACalibration.PointAt(I);
        lCsv.Add(SdbInvariantFloat(lPoint.X) + ';' + SdbInvariantFloat(lPoint.Y));
        lMinX := Min(lMinX, lPoint.X);
        lMaxX := Max(lMaxX, lPoint.X);
        lMinY := Min(lMinY, lPoint.Y);
        lMaxY := Max(lMaxY, lPoint.Y);
      end;
    end;
    lProps.SetProp('name', ACalibration.Name);
    lProps.SetProp('dsc', ACalibration.Description);
    lProps.SetPropFloat('src from', lMinX);
    lProps.SetPropFloat('src to', lMaxX);
    lProps.SetPropFloat('dst from', lMinY);
    lProps.SetPropFloat('dst to', lMaxY);
    lProps.SetProp('src units', ACalibration.UnitIn);
    lProps.SetProp('dst units', ACalibration.UnitOut);
    lProps.SetProp('module id', CSdbInterpolateModuleId);
    lProps.SetProp('state', '0');
    lProps.SetProp('mod time', DateTimeToStr(Now));
    lProps.SaveToFile(lXmlTemp);
    lCsv.SaveToFile(lCsvTemp);

    if FileExistsUTF8(lXmlPath) and not RenameFileUTF8(lXmlPath, lXmlBackup) then
      raise Exception.Create('Не удалось подготовить замену XML БДГХ.');
    if FileExistsUTF8(lCsvPath) and not RenameFileUTF8(lCsvPath, lCsvBackup) then
      raise Exception.Create('Не удалось подготовить замену CSV БДГХ.');
    if FileExistsUTF8(lJsonPath) and
      not RenameFileUTF8(lJsonPath, lJsonBackup) then
      raise Exception.Create('Не удалось подготовить замену JSON БДГХ.');
    if not RenameFileUTF8(lXmlTemp, lXmlPath) then
      raise Exception.Create('Не удалось записать XML БДГХ.');
    lXmlInstalled := True;
    if not RenameFileUTF8(lCsvTemp, lCsvPath) then
      raise Exception.Create('Не удалось записать CSV БДГХ.');
    lCsvInstalled := True;
    if not RecorderSdbTryLoadScaleFromPaths(lKey, lXmlPath, lCsvPath, lInfo) then
      raise Exception.Create('Записанная ГХ не прошла проверку чтением.');
    DeleteFileUTF8(lXmlBackup);
    DeleteFileUTF8(lCsvBackup);
    DeleteFileUTF8(lJsonBackup);
    ACreatedKey := lKey;
    Result := True;
  except
    on E: Exception do
    begin
      AError := E.Message;
      if lXmlInstalled then
        DeleteFileUTF8(lXmlPath);
      if lCsvInstalled then
        DeleteFileUTF8(lCsvPath);
      if FileExistsUTF8(lXmlBackup) then
        RenameFileUTF8(lXmlBackup, lXmlPath);
      if FileExistsUTF8(lCsvBackup) then
        RenameFileUTF8(lCsvBackup, lCsvPath);
      if FileExistsUTF8(lJsonBackup) then
        RenameFileUTF8(lJsonBackup, lJsonPath);
    end;
  end;
  DeleteFileUTF8(lXmlTemp);
  DeleteFileUTF8(lCsvTemp);
  lProps.Free;
  lCsv.Free;
end;

function RecorderSdbNormalizeKey(const AKey: string): string;
var
  lExt: string;
begin
  Result := Trim(AKey);
  Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  while (Length(Result) > 0) and (Result[1] = '\') do
    Delete(Result, 1, 1);
  { Имена шкал вроде K_ГОСТ Р 8.585-2001 содержат точку, но это не .csv/.xml. }
  lExt := LowerCase(ExtractFileExt(Result));
  if (lExt = '.xml') or (lExt = '.csv') or (lExt = '.json') then
    Result := ChangeFileExt(Result, '');
end;

function SdbKeyFileName(const AKey, AExtension: string): string;
var
  lRoot: string;
  lKey: string;
  lRel: string;
begin
  Result := '';
  lKey := RecorderSdbNormalizeKey(AKey);
  if lKey = '' then
    Exit;
  lRoot := ExcludeTrailingPathDelimiter(ExpandFileName(RecorderSdbRootDir));
  lRel := StringReplace(lKey, '\', PathDelim, [rfReplaceAll]) + AExtension;
  Result := IncludeTrailingPathDelimiter(lRoot) + lRel;
  // SDB keys are relative paths. Reject traversal outside the SDB root.
  if not StartsText(IncludeTrailingPathDelimiter(lRoot),
    IncludeTrailingPathDelimiter(ExtractFileDir(Result))) then
    Result := '';
end;

procedure SdbCollectFileBasenames(const ADiskDir, AExtension: string;
  ABasenames: TStrings);
var
  SR: TSearchRec;
  lDiskDir: string;
begin
  if ABasenames = nil then
    Exit;
  lDiskDir := IncludeTrailingPathDelimiter(ADiskDir);
  if FindFirst(lDiskDir + '*' + AExtension, faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Attr and faDirectory) <> 0 then
        Continue;
      ABasenames.Add(ChangeFileExt(SR.Name, ''));
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

function RecorderSdbScaleXmlPath(const AKey: string): string;
begin
  Result := SdbKeyFileName(AKey, '.xml');
end;

function RecorderSdbScaleCsvPath(const AKey: string): string;
begin
  Result := SdbKeyFileName(AKey, '.csv');
end;

function RecorderSdbScaleJsonPath(const AKey: string): string;
begin
  Result := SdbKeyFileName(AKey, '.json');
end;

function RecorderSdbTryLoadScaleFromPaths(const AKey, AXmlPath, ACsvPath: string;
  out AInfo: TSdbScaleInfo): Boolean;
var
  lBag: TSdbPropBag;
begin
  AInfo := Default(TSdbScaleInfo);
  Result := False;
  if (AXmlPath = '') or (ACsvPath = '') then
    Exit;
  if not FileExistsUTF8(AXmlPath) or not FileExistsUTF8(ACsvPath) then
    Exit;
  lBag := TSdbPropBag.Create;
  try
    lBag.LoadFromFile(AXmlPath);
    AInfo.Key := RecorderSdbNormalizeKey(AKey);
    AInfo.Name := lBag.GetProp('name');
    AInfo.Description := lBag.GetProp('dsc');
    AInfo.SrcFrom := lBag.GetPropFloat('src from', 0);
    AInfo.SrcTo := lBag.GetPropFloat('src to', 0);
    AInfo.DstFrom := lBag.GetPropFloat('dst from', 0);
    AInfo.DstTo := lBag.GetPropFloat('dst to', 0);
    AInfo.SrcUnits := lBag.GetProp('src units');
    AInfo.DstUnits := lBag.GetProp('dst units');
    AInfo.ModuleId := lBag.GetProp('module id');
    AInfo.State := Round(lBag.GetPropFloat('state', 0));
    AInfo.ModTime := lBag.GetProp('mod time');
    AInfo.XmlPath := AXmlPath;
    AInfo.CsvPath := ACsvPath;
    if Trim(AInfo.ModuleId) = '' then
      AInfo.ModuleId := CSdbInterpolateModuleId;
    Result := True;
  finally
    lBag.Free;
  end;
end;

function RecorderSdbTryLoadFolder(const AKey: string;
  out AInfo: TSdbFolderInfo): Boolean;
var
  lBag: TSdbPropBag;
  lFolderPath: string;
  lXmlPath: string;
begin
  AInfo := Default(TSdbFolderInfo);
  Result := False;
  if RecorderSdbNormalizeKey(AKey) = '' then
  begin
    lFolderPath := ExpandFileName(RecorderSdbRootDir);
    lXmlPath := IncludeTrailingPathDelimiter(lFolderPath) + CSdbDescriptorFile;
  end
  else
  begin
    lFolderPath := ExpandFileName(IncludeTrailingPathDelimiter(RecorderSdbRootDir) +
      StringReplace(RecorderSdbNormalizeKey(AKey), '\', PathDelim, [rfReplaceAll]));
    lXmlPath := IncludeTrailingPathDelimiter(lFolderPath) +
      ExtractFileName(lFolderPath) + '.xml';
  end;
  if not FileExistsUTF8(lXmlPath) then
    Exit;
  lBag := TSdbPropBag.Create;
  try
    lBag.LoadFromFile(lXmlPath);
    AInfo.Key := RecorderSdbNormalizeKey(AKey);
    AInfo.Name := lBag.GetProp('name');
    AInfo.Description := lBag.GetProp('dsc');
    AInfo.XmlPath := lXmlPath;
    Result := True;
  finally
    lBag.Free;
  end;
end;

function RecorderSdbTryLoadScale(const AKey: string; out AInfo: TSdbScaleInfo): Boolean;
var
  lJsonPath: string;
begin
  lJsonPath := RecorderSdbScaleJsonPath(AKey);
  if FileExistsUTF8(lJsonPath) and
    SdbTryLoadJsonInfo(AKey, lJsonPath, AInfo) then
    Exit(True);
  Result := RecorderSdbTryLoadScaleFromPaths(AKey,
    RecorderSdbScaleXmlPath(AKey), RecorderSdbScaleCsvPath(AKey), AInfo);
end;

constructor TRecorderSdbTree.Create;
begin
  inherited Create;
  fRoot := TRecorderSdbNode.Create;
  fRoot.Name := 'sdb';
  fRoot.Caption := 'SDB';
  fRoot.ItemKind := sikRoot;
end;

destructor TRecorderSdbTree.Destroy;
begin
  fRoot.Free;
  inherited Destroy;
end;

function TRecorderSdbTree.EnsureFolder(AParent: TRecorderSdbNode;
  const AName, AKey: string): TRecorderSdbNode;
var
  I: Integer;
  lFolderInfo: TSdbFolderInfo;
begin
  for I := 0 to AParent.GetChildCount - 1 do
    if (AParent.GetChild(I) is TRecorderSdbNode) and
      SameText(AParent.GetChild(I).Name, AName) then
      Exit(TRecorderSdbNode(AParent.GetChild(I)));
  Result := TRecorderSdbNode.Create;
  Result.Name := AName;
  Result.Caption := AName;
  Result.ItemKind := sikFolder;
  if RecorderSdbTryLoadFolder(AKey, lFolderInfo) then
    Result.FolderInfo := lFolderInfo;
  // Caption = имя каталога на диске (как в оригинальном SDB viewer).
  AParent.AddChild(Result);
end;

procedure TRecorderSdbTree.LoadScalePairs(AParent: TRecorderSdbNode;
  const ADiskDir, AKey: string);
var
  I: Integer;
  lBasenames: TStringList;
  lBase: string;
  lChildKey: string;
  lCsvPath: string;
  lDirName: string;
  lDiskDir: string;
  lScaleInfo: TSdbScaleInfo;
  lScaleNode: TRecorderSdbNode;
  lXmlPath: string;
begin
  lDiskDir := IncludeTrailingPathDelimiter(ADiskDir);
  lDirName := ExtractFileName(ExcludeTrailingPathDelimiter(lDiskDir));
  lBasenames := TStringList.Create;
  try
    lBasenames.Sorted := True;
    lBasenames.Duplicates := dupIgnore;
    SdbCollectFileBasenames(lDiskDir, '.xml', lBasenames);
    SdbCollectFileBasenames(lDiskDir, '.csv', lBasenames);
    SdbCollectFileBasenames(lDiskDir, '.json', lBasenames);
    for I := 0 to lBasenames.Count - 1 do
    begin
      lBase := lBasenames[I];
      if SameText(lBase, ChangeFileExt(CSdbDescriptorFile, '')) then
        Continue;
      if SameText(lBase, lDirName) then
        Continue;
      lXmlPath := lDiskDir + lBase + '.xml';
      lCsvPath := lDiskDir + lBase + '.csv';
      if AKey <> '' then
        lChildKey := AKey + '\' + lBase
      else
        lChildKey := lBase;
      if not RecorderSdbTryLoadScale(lChildKey, lScaleInfo) then
        Continue;
      lScaleNode := TRecorderSdbNode.Create;
      lScaleNode.Name := lBase;
      lScaleNode.Caption := SharedPreferredDisplayText(lScaleInfo.Name, lBase);
      lScaleNode.ItemKind := sikScale;
      lScaleNode.ScaleInfo := lScaleInfo;
      AParent.AddChild(lScaleNode);
    end;
  finally
    lBasenames.Free;
  end;
end;

procedure TRecorderSdbTree.LoadDirectory(AParent: TRecorderSdbNode;
  const ADiskDir, AKey: string);
var
  SR: TSearchRec;
  lDiskDir: string;
  lChildKey: string;
  lFolderNode: TRecorderSdbNode;
  lSubDir: string;
  lXmlPath: string;
begin
  lDiskDir := IncludeTrailingPathDelimiter(ADiskDir);
  LoadScalePairs(AParent, ADiskDir, AKey);

  if FindFirst(lDiskDir + '*', faDirectory, SR) = 0 then
  try
    repeat
      if (SR.Name = '.') or (SR.Name = '..') then
        Continue;
      if (SR.Attr and faDirectory) = 0 then
        Continue;
      lSubDir := lDiskDir + SR.Name;
      lXmlPath := IncludeTrailingPathDelimiter(lSubDir) + SR.Name + '.xml';
      if not FileExistsUTF8(lXmlPath) then
        Continue;
      if AKey <> '' then
        lChildKey := AKey + '\' + SR.Name
      else
        lChildKey := SR.Name;
      lFolderNode := EnsureFolder(AParent, SR.Name, lChildKey);
      LoadDirectory(lFolderNode, lSubDir, lChildKey);
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

procedure TRecorderSdbTree.Load;
var
  lRoot: string;
  lFolderInfo: TSdbFolderInfo;
begin
  fRoot.ClearChildren;
  lRoot := IncludeTrailingPathDelimiter(ExpandFileName(RecorderSdbRootDir));
  if not DirectoryExists(lRoot) then
    Exit;
  fRoot.FolderInfo := Default(TSdbFolderInfo);
  fRoot.Caption := 'SDB';
  if RecorderSdbTryLoadFolder('', lFolderInfo) then
  begin
    fRoot.FolderInfo := lFolderInfo;
    fRoot.Caption := SharedPreferredDisplayText(lFolderInfo.Name, fRoot.Caption);
  end;
  LoadDirectory(fRoot, lRoot, '');
end;

procedure TRecorderSdbTree.CollectScaleKeys(ANode: TRecorderSdbNode;
  const AFolderKey: string; AKeys: TStrings);
var
  I: Integer;
  lChild: TRecorderSdbNode;
  lPrefix: string;
begin
  if ANode = nil then
    Exit;
  lPrefix := RecorderSdbNormalizeKey(AFolderKey);
  if lPrefix <> '' then
    lPrefix := lPrefix + '\';
  for I := 0 to ANode.GetChildCount - 1 do
  begin
    if not (ANode.GetChild(I) is TRecorderSdbNode) then
      Continue;
    lChild := TRecorderSdbNode(ANode.GetChild(I));
    if lChild.ItemKind = sikScale then
    begin
      if (lPrefix = '') or StartsText(lPrefix, lChild.ScaleInfo.Key) then
        AKeys.Add(lChild.ScaleInfo.Key);
    end
    else
      CollectScaleKeys(lChild, AFolderKey, AKeys);
  end;
end;

procedure TRecorderSdbTree.ListScaleKeys(const AFolderKey: string;
  AKeys: TStrings);
begin
  if AKeys = nil then
    Exit;
  AKeys.Clear;
  CollectScaleKeys(fRoot, AFolderKey, AKeys);
  if AKeys is TStringList then
    TStringList(AKeys).Sort;
end;

procedure RecorderSdbListScaleKeys(const AFolderKey: string; AKeys: TStrings);
var
  lTree: TRecorderSdbTree;
begin
  if AKeys = nil then
    Exit;
  lTree := TRecorderSdbTree.Create;
  try
    lTree.Load;
    lTree.ListScaleKeys(AFolderKey, AKeys);
  finally
    lTree.Free;
  end;
end;

function SdbTryParseNumber(const AText: string; out AValue: Double): Boolean;
var
  lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  Result := TryStrToFloat(StringReplace(Trim(AText), ',', '.', [rfReplaceAll]),
    AValue, lFormat);
end;

function SdbTryParseCsvLine(const ALine: string; out AX, AY: Double): Boolean;
var
  lLeft: string;
  lLine: string;
  lPos: Integer;
  lRight: string;

  function TrySplit(ADelim: Char): Boolean;
  begin
    lPos := Pos(ADelim, lLine);
    if lPos <= 0 then
      Exit(False);
    lLeft := Trim(Copy(lLine, 1, lPos - 1));
    lRight := Trim(Copy(lLine, lPos + 1, MaxInt));
    Result := SdbTryParseNumber(lLeft, AX) and SdbTryParseNumber(lRight, AY);
  end;

begin
  lLine := Trim(ALine);
  if lLine = '' then
    Exit(False);
  if Pos(';', lLine) > 0 then
    Result := TrySplit(';')
  else
    Result := TrySplit(',') or TrySplit(#9);
end;

function RecorderSdbLoadScaleCalibrationFromInfo(const AInfo: TSdbScaleInfo;
  ACalibration: TRecorderCalibration): Boolean;
var
  I: Integer;
  lLines: TStringList;
  lX: Double;
  lY: Double;
begin
  Result := False;
  if ACalibration = nil then
    Exit;
  if Trim(AInfo.JsonPath) <> '' then
    Exit(SdbLoadJsonCalibration(AInfo.JsonPath, ACalibration));
  if (Trim(AInfo.CsvPath) = '') or
    not FileExistsUTF8(AInfo.CsvPath) then
    Exit;
  lLines := TStringList.Create;
  try
    SharedLoadLegacyTextLines(lLines, AInfo.CsvPath);
    ACalibration.ClearPoints;
    for I := 0 to lLines.Count - 1 do
    begin
      if not SdbTryParseCsvLine(lLines[I], lX, lY) then
        Continue;
      ACalibration.AddPoint(lX, lY);
    end;
    if ACalibration.PointCount = 0 then
      Exit;
    ACalibration.Kind := rckPiecewiseLinear;
    ACalibration.Description := AInfo.Key;
    ACalibration.UnitIn := AInfo.SrcUnits;
    ACalibration.UnitOut := AInfo.DstUnits;
    ACalibration.Extrapolation := True;
    Result := True;
  finally
    lLines.Free;
  end;
end;

function RecorderSdbLoadScaleCalibration(const AKey: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  lInfo: TSdbScaleInfo;
begin
  Result := False;
  if (ACalibration = nil) or not RecorderSdbTryLoadScale(AKey, lInfo) then
    Exit;
  Result := RecorderSdbLoadScaleCalibrationFromInfo(lInfo, ACalibration);
end;

function RecorderSdbLoadScaleCalibrationFromCsv(const ACsvPath, AKey: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  lInfo: TSdbScaleInfo;
begin
  Result := False;
  if (ACalibration = nil) or (Trim(ACsvPath) = '') or not FileExistsUTF8(ACsvPath) then
    Exit;
  lInfo.Key := RecorderSdbNormalizeKey(AKey);
  lInfo.CsvPath := ACsvPath;
  if Trim(lInfo.SrcUnits) = '' then
    lInfo.SrcUnits := 'mV';
  if Trim(lInfo.DstUnits) = '' then
    lInfo.DstUnits := 'degC';
  Result := RecorderSdbLoadScaleCalibrationFromInfo(lInfo, ACalibration);
end;

function RecorderSdbImportCalibration(AList: TRecorderCalibrationList;
  const AKey: string; out ACalibrationName: string): Boolean;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lKeyName: string;
  lName: string;
begin
  Result := False;
  ACalibrationName := '';
  if AList = nil then
    Exit;
  lKeyName := RecorderSdbNormalizeKey(AKey);
  if lKeyName = '' then
    Exit;
  lKeyName := ExtractFileName(StringReplace(lKeyName, '\', PathDelim,
    [rfReplaceAll]));
  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderSdbLoadScaleCalibration(AKey, lCalibration) then
      Exit;
    lName := Trim(lCalibration.Name);
    if lName = '' then
      lName := lKeyName;
    lCalibration.Name := lName;
    for I := 0 to AList.Count - 1 do
      if SameText(AList[I].Name, lName) then
      begin
        AList[I].Assign(lCalibration);
        AList[I].Name := lName;
        ACalibrationName := lName;
        Exit(True);
      end;
    AList.Add(lCalibration);
    lCalibration := nil;
    ACalibrationName := lName;
    Result := True;
  finally
    lCalibration.Free;
  end;
end;

function RecorderSdbNodeDisplayName(ANode: TRecorderSdbNode): string;
begin
  Result := '';
  if ANode = nil then
    Exit;
  case ANode.ItemKind of
    sikScale:
      Result := SharedPreferredDisplayText(ANode.ScaleInfo.Name, ANode.Caption);
    sikFolder, sikRoot:
      Result := SharedPreferredDisplayText(ANode.FolderInfo.Name, ANode.Caption);
  end;
end;

function RecorderSdbNodeDisplayDescription(ANode: TRecorderSdbNode): string;
begin
  Result := '';
  if ANode = nil then
    Exit;
  case ANode.ItemKind of
    sikScale:
      Result := ANode.ScaleInfo.Description;
    sikFolder, sikRoot:
      Result := ANode.FolderInfo.Description;
  end;
  if not SharedIsGoodDisplayText(Result) then
    Result := '';
end;

procedure RecorderSdbReloadNodeMetadata(ANode: TRecorderSdbNode);
var
  lFolder: TSdbFolderInfo;
  lScale: TSdbScaleInfo;
begin
  if ANode = nil then
    Exit;
  case ANode.ItemKind of
    sikScale:
      if RecorderSdbTryLoadScale(ANode.ScaleInfo.Key, lScale) then
        ANode.ScaleInfo := lScale;
    sikFolder, sikRoot:
      if RecorderSdbTryLoadFolder(ANode.FolderInfo.Key, lFolder) then
        ANode.FolderInfo := lFolder;
  end;
end;

end.
