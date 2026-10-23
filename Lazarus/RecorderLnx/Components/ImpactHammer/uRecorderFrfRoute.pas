unit uRecorderFrfRoute;

{ Сохраняет шаги маршрута FRF и их привязки. Отметка Captured означает, что
  снимок MERA уже записан; сами данные сессии хранит отдельный session store.
  Изменения маршрута вызываются явными командами, а не из отрисовки. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils, Math, IniFiles, uRecorderFrfRepository;

type
  TRecorderRouteCurveArray = array of TRecorderFrfCurveData;
  TRecorderFrfRouteBinding = record
    ChannelIndex, PointNumber: Integer;
    TargetNodeId: QWord;
    SceneComponentId, TargetNodeName, PointLabel: string;
  end;
  TRecorderFrfRouteBindings = array of TRecorderFrfRouteBinding;
  TRecorderFrfRouteEntry = record
    ChannelIndex, PointNumber: Integer;
    TargetNodeId, CurveId: QWord;
    TargetNodeName, PointLabel, StorageFolder: string;
    Captured: Boolean;
    Bindings: TRecorderFrfRouteBindings;
  end;

  TRecorderFrfRoute = class
  private
    fEntries: array of TRecorderFrfRouteEntry;
    fDirectory, fConfigFileName: string;
    fCurrentIndex: Integer;
    function GetCount: Integer;
    function GetEntry(AIndex: Integer): TRecorderFrfRouteEntry;
    function HasSavedSession(AIndex: Integer): Boolean;
    procedure RefreshCaptured;
  public
    procedure Add(const AEntry: TRecorderFrfRouteEntry);
    procedure UpdateEntry(AIndex: Integer; const AEntry: TRecorderFrfRouteEntry);
    procedure MoveEntry(AFrom, ATo: Integer);
    procedure SetPointLabel(AIndex: Integer; const ALabel: string);
    procedure AddBinding(AIndex: Integer; const ABinding: TRecorderFrfRouteBinding);
    procedure DeleteBinding(AIndex, ABindingIndex: Integer);
    procedure Delete(AIndex: Integer);
    procedure Clear;
    { Меняет каталог хранения, не создавая манифест и не копируя старые данные. }
    function SetDirectory(const ADirectory: string): Boolean;
    { Этот путь принадлежит конфигурации проекта; Directory задаёт отдельный
      корень результатов. Без пути проекта Save меняет только состояние в памяти. }
    function HasManifest(const ADirectory: string): Boolean;
    procedure Save(const ADirectory: string);
    procedure Load(const ADirectory: string);
    procedure CaptureCurrent(const ACurve: TRecorderFrfCurveData);
    procedure CaptureEntry(AIndex: Integer; const ACurve: TRecorderFrfCurveData);
    function PointDirectory(AIndex: Integer): string;
    procedure ResetProgress;
    function AllComplete: Boolean;
    property Count: Integer read GetCount;
    property Entries[AIndex: Integer]: TRecorderFrfRouteEntry read GetEntry; default;
    property CurrentIndex: Integer read fCurrentIndex write fCurrentIndex;
    property Directory: string read fDirectory;
    property ConfigFileName: string read fConfigFileName write fConfigFileName;
  end;

implementation

{ Возвращает число шагов маршрута. }
function TRecorderFrfRoute.GetCount: Integer;
begin Result := Length(fEntries) end;

{ Возвращает копию шага по AIndex вместе с отдельной копией списка привязок. }
function TRecorderFrfRoute.GetEntry(AIndex: Integer): TRecorderFrfRouteEntry;
begin
  if (AIndex < 0) or (AIndex >= Count) then raise ERangeError.Create('FRF route index');
  Result := fEntries[AIndex];
  Result.Bindings := Copy(fEntries[AIndex].Bindings);
end;

{ Проверяет наличие файлов MERA-сессии для шага AIndex. }
function TRecorderFrfRoute.HasSavedSession(AIndex: Integer): Boolean;
var lPoint: string;
begin
  if fDirectory = '' then Exit(False);
  lPoint := IncludeTrailingPathDelimiter(PointDirectory(AIndex));
  Result := FileExists(lPoint + 'frf' + PathDelim + 'session.mera') or
    FileExists(lPoint + 'aka' + PathDelim + 'session.mera');
end;

{ Строит каталог шага; очищает имя точки и добавляет CurveId при совпадении имён. }
function TRecorderFrfRoute.PointDirectory(AIndex: Integer): string;
var lName, lOther: string; I: Integer;
begin
  GetEntry(AIndex);
  lName := fEntries[AIndex].StorageFolder;
  if lName = '' then
  begin
    lName := Trim(fEntries[AIndex].PointLabel);
    for I := 1 to Length(lName) do
      if (lName[I] in ['<', '>', ':', '"', '/', '\', '|', '?', '*']) or
        (Ord(lName[I]) < 32) then lName[I] := '_';
    while (lName <> '') and (lName[Length(lName)] in [' ', '.']) do
      System.Delete(lName, Length(lName), 1);
    if lName = '' then lName := IntToStr(fEntries[AIndex].PointNumber);
    for I := 0 to Count - 1 do
      if I <> AIndex then
      begin
        lOther := fEntries[I].StorageFolder;
        if lOther = '' then lOther := Trim(fEntries[I].PointLabel);
        if SameText(lName, lOther) then
        begin
          lName := lName + '-' + UIntToStr(fEntries[AIndex].CurveId);
          Break;
        end;
      end;
  end;
  Result := IncludeTrailingPathDelimiter(fDirectory) + lName;
end;

{ Добавляет шаг, копирует привязки и назначает уникальный ненулевой CurveId. }
procedure TRecorderFrfRoute.Add(const AEntry: TRecorderFrfRouteEntry);
var lEntry: TRecorderFrfRouteEntry; lGuid: TGUID; lIndex: Integer; lCollision: Boolean;
begin
  lEntry := AEntry;
  if Trim(lEntry.PointLabel) = '' then lEntry.PointLabel := IntToStr(Count + 1);
  lEntry.Bindings := Copy(AEntry.Bindings);
  repeat
    CreateGUID(lGuid);
    Move(lGuid, lEntry.CurveId, SizeOf(lEntry.CurveId));
    lCollision := lEntry.CurveId = 0;
    for lIndex := 0 to Count - 1 do
      lCollision := lCollision or (fEntries[lIndex].CurveId = lEntry.CurveId);
  until not lCollision;
  lEntry.Captured := False;
  SetLength(fEntries, Count + 1);
  fEntries[High(fEntries)] := lEntry;
end;

{ Добавляет привязку к AIndex, если сочетание канала, узла, точки и компонента ещё не задано. }
procedure TRecorderFrfRoute.AddBinding(AIndex: Integer;
  const ABinding: TRecorderFrfRouteBinding);
var lBindings: TRecorderFrfRouteBindings; I: Integer;
begin
  GetEntry(AIndex);
  lBindings := Copy(fEntries[AIndex].Bindings);
  for I := 0 to High(lBindings) do
    if (lBindings[I].ChannelIndex = ABinding.ChannelIndex) and
      (lBindings[I].TargetNodeId = ABinding.TargetNodeId) and
      (lBindings[I].PointNumber = ABinding.PointNumber) and
      (lBindings[I].SceneComponentId = ABinding.SceneComponentId) then Exit;
  SetLength(lBindings, Length(lBindings) + 1);
  lBindings[High(lBindings)] := ABinding;
  fEntries[AIndex].Bindings := lBindings;
  if fDirectory <> '' then Save(fDirectory);
end;

{ Удаляет привязку ABindingIndex из шага AIndex и сохраняет маршрут. }
procedure TRecorderFrfRoute.DeleteBinding(AIndex, ABindingIndex: Integer);
var lBindings: TRecorderFrfRouteBindings; I: Integer;
begin
  GetEntry(AIndex);
  lBindings := Copy(fEntries[AIndex].Bindings);
  if (ABindingIndex < 0) or (ABindingIndex >= Length(lBindings)) then Exit;
  for I := ABindingIndex to High(lBindings) - 1 do lBindings[I] := lBindings[I + 1];
  SetLength(lBindings, Length(lBindings) - 1);
  fEntries[AIndex].Bindings := lBindings;
  if fDirectory <> '' then Save(fDirectory);
end;

{ Устанавливает подпись точки; пустую заменяет её номером. }
procedure TRecorderFrfRoute.SetPointLabel(AIndex: Integer; const ALabel: string);
begin
  GetEntry(AIndex);
  fEntries[AIndex].PointLabel := Trim(ALabel);
  if fEntries[AIndex].PointLabel = '' then
    fEntries[AIndex].PointLabel := IntToStr(fEntries[AIndex].PointNumber);
  if fDirectory <> '' then Save(fDirectory);
end;

{ Обновляет параметры шага, сохраняя CurveId, каталог и статус сохранённого измерения. }
procedure TRecorderFrfRoute.UpdateEntry(AIndex: Integer;
  const AEntry: TRecorderFrfRouteEntry);
var lPrevious, lEntry: TRecorderFrfRouteEntry;
begin
  lPrevious := GetEntry(AIndex);
  lEntry := AEntry;
  { Изменение привязки не должно отвязывать уже сохранённое измерение шага. }
  lEntry.Bindings := Copy(AEntry.Bindings);
  lEntry.CurveId := lPrevious.CurveId;
  lEntry.Captured := lPrevious.Captured;
  lEntry.StorageFolder := lPrevious.StorageFolder;
  lEntry.PointLabel := Trim(lEntry.PointLabel);
  if lEntry.PointLabel = '' then lEntry.PointLabel := IntToStr(lEntry.PointNumber);
  fEntries[AIndex] := lEntry;
  if fDirectory <> '' then Save(fDirectory);
end;

{ Переставляет шаг из AFrom в ATo и пересчитывает CurrentIndex. }
procedure TRecorderFrfRoute.MoveEntry(AFrom, ATo: Integer);
var lEntry: TRecorderFrfRouteEntry; lIndex: Integer;
begin
  lEntry := GetEntry(AFrom);
  GetEntry(ATo);
  if AFrom = ATo then Exit;
  if AFrom < ATo then
    for lIndex := AFrom to ATo - 1 do fEntries[lIndex] := fEntries[lIndex + 1]
  else
    for lIndex := AFrom downto ATo + 1 do fEntries[lIndex] := fEntries[lIndex - 1];
  fEntries[ATo] := lEntry;
  if fCurrentIndex = AFrom then fCurrentIndex := ATo
  else if (AFrom < fCurrentIndex) and (fCurrentIndex <= ATo) then Dec(fCurrentIndex)
  else if (ATo <= fCurrentIndex) and (fCurrentIndex < AFrom) then Inc(fCurrentIndex);
  if fDirectory <> '' then Save(fDirectory);
end;

{ Удаляет шаг AIndex и корректирует текущую позицию. }
procedure TRecorderFrfRoute.Delete(AIndex: Integer);
var lIndex: Integer;
begin
  GetEntry(AIndex);
  for lIndex := AIndex to Count - 2 do fEntries[lIndex] := fEntries[lIndex + 1];
  SetLength(fEntries, Count - 1);
  if fCurrentIndex > AIndex then Dec(fCurrentIndex);
  if fCurrentIndex > Count then fCurrentIndex := Count;
end;

{ Снимает текущий снимок, увеличивает версию и уведомляет подписчиков. }
procedure TRecorderFrfRoute.Clear;
begin SetLength(fEntries, 0); fCurrentIndex := 0; fDirectory := '' end;

{ Сверяет флаги Captured шагов с наличием файлов сессии. }
procedure TRecorderFrfRoute.RefreshCaptured;
var I: Integer;
begin
  for I := 0 to Count - 1 do
    fEntries[I].Captured := HasSavedSession(I);
end;

{ Нормализует каталог результатов; возвращает True при его изменении. }
function TRecorderFrfRoute.SetDirectory(const ADirectory: string): Boolean;
var lDirectory: string;
begin
  lDirectory := Trim(ADirectory);
  if lDirectory <> '' then
    lDirectory := ExcludeTrailingPathDelimiter(ExpandFileName(lDirectory));
  Result := not SameFileName(fDirectory, lDirectory);
  if not Result then Exit;
  fDirectory := lDirectory;
  RefreshCaptured;
end;

{ Записывает шаги и привязки в конфигурацию проекта; ADirectory задаёт корень результатов. }
procedure TRecorderFrfRoute.Save(const ADirectory: string);
var lIni: TMemIniFile; lIndex, J: Integer; lSection, lBinding: string;
begin
  if Trim(ADirectory) = '' then raise Exception.Create('FRF route directory is empty');
  SetDirectory(ADirectory);
  if Trim(fConfigFileName) = '' then Exit;
  if not ForceDirectories(ExtractFileDir(ExpandFileName(fConfigFileName))) then
    raise Exception.Create('Cannot create FRF route configuration directory');
  lIni := TMemIniFile.Create(fConfigFileName);
  try
    lIni.Clear;
    lIni.WriteInteger('Route', 'Version', 3);
    lIni.WriteInteger('Route', 'Count', Count);
    for lIndex := 0 to Count - 1 do
    begin
      lSection := 'Point' + IntToStr(lIndex);
      lIni.WriteInteger(lSection, 'Channel', fEntries[lIndex].ChannelIndex);
      lIni.WriteInteger(lSection, 'Point', fEntries[lIndex].PointNumber);
      lIni.WriteString(lSection, 'PointLabel', fEntries[lIndex].PointLabel);
      lIni.WriteString(lSection, 'NodeId', UIntToStr(fEntries[lIndex].TargetNodeId));
      lIni.WriteString(lSection, 'NodeName', fEntries[lIndex].TargetNodeName);
      lIni.WriteString(lSection, 'CurveId', UIntToStr(fEntries[lIndex].CurveId));
      lIni.WriteString(lSection, 'StorageFolder', fEntries[lIndex].StorageFolder);
      lIni.WriteInteger(lSection, 'BindingCount', Length(fEntries[lIndex].Bindings));
      for J := 0 to High(fEntries[lIndex].Bindings) do
      begin
        lBinding := lSection + '.Binding' + IntToStr(J);
        with fEntries[lIndex].Bindings[J] do
        begin
          lIni.WriteInteger(lBinding, 'Channel', ChannelIndex);
          lIni.WriteInteger(lBinding, 'Point', PointNumber);
          lIni.WriteString(lBinding, 'Scene', SceneComponentId);
          lIni.WriteString(lBinding, 'NodeId', UIntToStr(TargetNodeId));
          lIni.WriteString(lBinding, 'NodeName', TargetNodeName);
          lIni.WriteString(lBinding, 'Label', PointLabel);
        end;
      end;
    end;
    lIni.UpdateFile;
  finally lIni.Free end;
end;

{ Проверяет наличие файла конфигурации маршрута проекта или route.ini в ADirectory. }
function TRecorderFrfRoute.HasManifest(const ADirectory: string): Boolean;
begin
  Result := ((Trim(fConfigFileName) <> '') and FileExists(fConfigFileName)) or
    ((Trim(ADirectory) <> '') and FileExists(
      IncludeTrailingPathDelimiter(ADirectory) + 'route.ini'));
end;

{ Загружает шаги и привязки маршрута из конфигурации проекта; при её отсутствии читает старый route.ini из ADirectory. }
procedure TRecorderFrfRoute.Load(const ADirectory: string);
var lIni: TMemIniFile; lIndex, lCount, lVersion, J, lBindings: Integer;
  lSection, lBinding, lFileName: string;
begin
  fDirectory := ExpandFileName(ADirectory);
  lFileName := fConfigFileName;
  { Импортирует старую конфигурацию маршрута из папки объекта без её изменения.
    При следующем Save запись выполняется только в путь конфигурации проекта. }
  if (Trim(lFileName) = '') or not FileExists(lFileName) then
    lFileName := IncludeTrailingPathDelimiter(fDirectory) + 'route.ini';
  if not FileExists(lFileName) then
    raise EReadError.Create('FRF route manifest not found');
  lIni := TMemIniFile.Create(lFileName);
  try
    lVersion := lIni.ReadInteger('Route', 'Version', 0);
    if not (lVersion in [1, 2, 3]) then
      raise EReadError.Create('Unsupported FRF route version');
    lCount := lIni.ReadInteger('Route', 'Count', 0);
    if (lCount < 0) or (lCount > 100000) then raise EReadError.Create('Invalid FRF route count');
    SetLength(fEntries, lCount);
    if lVersion < 3 then
      fCurrentIndex := lIni.ReadInteger('Route', 'Current', 0)
    else
      fCurrentIndex := 0;
    if (fCurrentIndex < 0) or (fCurrentIndex > Count) then fCurrentIndex := 0;
    for lIndex := 0 to Count - 1 do
    begin
      lSection := 'Point' + IntToStr(lIndex);
      fEntries[lIndex].ChannelIndex := lIni.ReadInteger(lSection, 'Channel', 0);
      fEntries[lIndex].PointNumber := lIni.ReadInteger(lSection, 'Point', 1);
      fEntries[lIndex].PointLabel := lIni.ReadString(lSection, 'PointLabel',
        IntToStr(fEntries[lIndex].PointNumber));
      if Trim(fEntries[lIndex].PointLabel) = '' then
        fEntries[lIndex].PointLabel := IntToStr(fEntries[lIndex].PointNumber);
      fEntries[lIndex].TargetNodeId := StrToQWord(lIni.ReadString(lSection, 'NodeId', '0'));
      fEntries[lIndex].TargetNodeName := lIni.ReadString(lSection, 'NodeName', '');
      fEntries[lIndex].CurveId := StrToQWord(lIni.ReadString(lSection, 'CurveId', '0'));
      fEntries[lIndex].Captured := False;
      fEntries[lIndex].StorageFolder := lIni.ReadString(lSection, 'StorageFolder', '');
      if (lVersion = 1) and (fEntries[lIndex].StorageFolder = '') then
        fEntries[lIndex].StorageFolder := ExtractFileName(PointDirectory(lIndex));
      lBindings := lIni.ReadInteger(lSection, 'BindingCount', 0);
      if (lBindings < 0) or (lBindings > 100000) then
        raise EReadError.Create('Invalid FRF route binding count');
      if lVersion = 1 then lBindings := 1;
      SetLength(fEntries[lIndex].Bindings, lBindings);
      for J := 0 to lBindings - 1 do
        with fEntries[lIndex].Bindings[J] do
        begin
          lBinding := lSection + '.Binding' + IntToStr(J);
          ChannelIndex := lIni.ReadInteger(lBinding, 'Channel', fEntries[lIndex].ChannelIndex);
          PointNumber := lIni.ReadInteger(lBinding, 'Point', fEntries[lIndex].PointNumber);
          SceneComponentId := lIni.ReadString(lBinding, 'Scene', '');
          TargetNodeId := StrToQWord(lIni.ReadString(lBinding, 'NodeId', UIntToStr(fEntries[lIndex].TargetNodeId)));
          TargetNodeName := lIni.ReadString(lBinding, 'NodeName', fEntries[lIndex].TargetNodeName);
          PointLabel := lIni.ReadString(lBinding, 'Label', fEntries[lIndex].PointLabel);
        end;
    end;
  finally lIni.Free end;
  RefreshCaptured;
end;

{ Фиксирует текущий шаг и переводит указатель на следующий. }
procedure TRecorderFrfRoute.CaptureCurrent(const ACurve: TRecorderFrfCurveData);
begin
  CaptureEntry(fCurrentIndex, ACurve);
  Inc(fCurrentIndex);
  Save(fDirectory);
end;

{ Проверяет массивы и частоты кривой, затем фиксирует шаг AIndex только после записи MERA-сессии. }
procedure TRecorderFrfRoute.CaptureEntry(AIndex: Integer;
  const ACurve: TRecorderFrfCurveData);
var lIndex: Integer;
begin
  GetEntry(AIndex);
  if fDirectory = '' then raise Exception.Create('Save FRF route before capture');
  if (Length(ACurve.FrequencyHz) = 0) or
    (Length(ACurve.Magnitude) <> Length(ACurve.FrequencyHz)) or
    (Length(ACurve.PhaseRadians) <> Length(ACurve.FrequencyHz)) or
    (Length(ACurve.Coherence) <> Length(ACurve.FrequencyHz)) then
    raise Exception.Create('Incomplete FRF realization');
  for lIndex := 0 to High(ACurve.FrequencyHz) do
    if IsNan(ACurve.FrequencyHz[lIndex]) or IsInfinite(ACurve.FrequencyHz[lIndex]) or
      IsNan(ACurve.Magnitude[lIndex]) or IsInfinite(ACurve.Magnitude[lIndex]) or
      IsNan(ACurve.PhaseRadians[lIndex]) or IsInfinite(ACurve.PhaseRadians[lIndex]) or
      IsNan(ACurve.Coherence[lIndex]) or IsInfinite(ACurve.Coherence[lIndex]) or
      (ACurve.Magnitude[lIndex] < 0) or (ACurve.Coherence[lIndex] < 0) or
      (ACurve.Coherence[lIndex] > 1) or ((lIndex > 0) and
      (ACurve.FrequencyHz[lIndex] <= ACurve.FrequencyHz[lIndex - 1])) then
      raise Exception.Create('Invalid FRF realization');
  if fEntries[AIndex].StorageFolder = '' then
    fEntries[AIndex].StorageFolder := ExtractFileName(PointDirectory(AIndex));
  { Сервис сначала фиксирует сырые и рассчитанные каналы MERA. Шаг нельзя
    помечать сохранённым, пока данные существуют только в оперативной памяти. }
  if not HasSavedSession(AIndex) then
    raise Exception.Create('Save MERA realization before marking FRF route capture');
  fEntries[AIndex].Captured := True;
  Save(fDirectory);
end;

{ Находит первый шаг без сохранённой сессии и назначает его текущим. }
procedure TRecorderFrfRoute.ResetProgress;
begin
  fCurrentIndex := 0;
  RefreshCaptured;
  while (fCurrentIndex < Count) and fEntries[fCurrentIndex].Captured do
    Inc(fCurrentIndex);
end;

{ Проверяет, что непустой маршрут полностью записан и файлы каждой сессии существуют. }
function TRecorderFrfRoute.AllComplete: Boolean;
var lIndex: Integer;
begin
  Result := Count > 0;
  for lIndex := 0 to Count - 1 do
    Result := Result and fEntries[lIndex].Captured and HasSavedSession(lIndex);
end;

end.
