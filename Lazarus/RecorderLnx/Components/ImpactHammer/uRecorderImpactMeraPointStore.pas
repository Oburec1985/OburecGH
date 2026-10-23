unit uRecorderImpactMeraPointStore;

{ Кодирует снимок шага маршрута в каналы MERA R8 .dat/.x. Вызывающий код
  подготавливает и атомарно устанавливает каталог; codec не удаляет файлы.
  Метаданные сохраняют ID сессии и каналов независимо от имён payload. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses SysUtils, uRecorderImpactSessionContracts;

type
  TRecorderImpactMeraPointStore = class
  public
    class function SessionFileName(const ADirectory: string): string; static;
    class function Save(const ADirectory: string;
      const ASnapshot: TRecorderImpactSessionSnapshot;
      out AError: string): Boolean; static;
    class function Load(const ADirectory: string;
      out ASnapshot: TRecorderImpactSessionSnapshot;
      out AError: string): Boolean; static;
  end;

implementation

uses Classes, IniFiles, LConvEncoding, Base64, uRecorderImpactSessionValidation;

type
  TDoubles = array of Double;
  TPointCodec = class
  private
    fDirectory: string;
    fIni: TMemIniFile;
    fTotalValues: Int64;
    fChannelNames: TStringList;
    fExcitationName: string;
    { Формирует допустимое имя канала MERA из тега и ANumber. }
    function ChannelName(const ATagName: string; ANumber: Integer;
      const ALineType: string): string;
    { Строит ключ канала, используя ALegacySuffix для старого формата. }
    function CurveChannel(const ASection, AKey, ALegacySuffix: string): string;
    { Записывает AValue в секцию ASection по ключу AKey. }
    procedure Number(const ASection, AKey: string; AValue: Double);
    { Читает число из секции ASection по ключу AKey. }
    function ReadNumber(const ASection, AKey: string): Double;
    { Сохраняет массив отсчётов в отдельный двоичный файл AName. }
    procedure WriteValues(const AName: string; const AValues: array of Double);
    { Загружает массив отсчётов из двоичного файла AName. }
    function ReadValues(const AName: string): TDoubles;
    { Читает значения кривой и сопоставляет их с частотами AFrequency. }
    function ReadCurveValues(const AName: string; const AFrequency: array of Double): TDoubles;
    { Записывает метаданные и ряды одного канала в MERA. }
    procedure WriteChannel(const AName, ALabel, AUnit, AXUnit: string;
      const AX, AY: array of Double);
    { Сериализует ряд с номером ANumber в секцию ASection. }
    procedure WriteSeries(const ASection: string; ANumber: Integer;
      const ALineType: string;
      const ASeries: TRecorderImpactSessionSeries);
    { Восстанавливает временной ряд из секции ASection. }
    function ReadSeries(const ASection: string): TRecorderImpactSessionSeries;
    { Сохраняет метаданные и массивы кривой с номером ANumber. }
    procedure WriteCurve(const ASection: string; ANumber: Integer;
      const ACurve: TRecorderImpactSessionCurve);
    { Восстанавливает FRF-кривую из секции ASection. }
    function ReadCurve(const ASection: string): TRecorderImpactSessionCurve;
    { Читает количество из секции и ограничивает его AMaximum. }
    function Count(const ASection, AKey: string; AMaximum: Integer): Integer;
  public
    { Инициализирует кодек и открывает каталог ADirectory для чтения или записи MERA. }
    constructor Create(const ADirectory: string);
    { Освобождает ресурсы кодека и закрывает открытый каталог. }
    destructor Destroy; override;
    { Сериализует сессию в MERA: манифест, ряды и кривые. }
    procedure WriteSnapshot(const ASnapshot: TRecorderImpactSessionSnapshot);
    { Восстанавливает снимок из манифеста и файлов MERA. }
    function ReadSnapshot: TRecorderImpactSessionSnapshot;
  end;

{ Инициализирует кодек и открывает каталог ADirectory для чтения или записи MERA. }
constructor TPointCodec.Create(const ADirectory: string);
begin
  inherited Create;
  fDirectory := IncludeTrailingPathDelimiter(ADirectory);
  fIni := TMemIniFile.Create('');
  fChannelNames := TStringList.Create;
  fChannelNames.CaseSensitive := False;
  fChannelNames.Sorted := True;
end;

{ Освобождает ресурсы кодека и закрывает открытый каталог. }
destructor TPointCodec.Destroy;
begin
  fIni.Free;
  fChannelNames.Free;
  inherited Destroy;
end;

{ Формирует допустимое имя канала MERA из тега и ANumber. }
function TPointCodec.ChannelName(const ATagName: string; ANumber: Integer;
  const ALineType: string): string;
var lStem: string; I, lDuplicate: Integer;
begin
  lStem := Trim(ATagName);
  for I := 1 to Length(lStem) do
    if (Ord(lStem[I]) < 32) or (Pos(lStem[I], '\/:*?"<>|[]=') > 0) then
      lStem[I] := '_';
  lStem := StringReplace(lStem, '..', '__', [rfReplaceAll]);
  if lStem = '' then lStem := 'tag';
  lStem := lStem + '_' + IntToStr(ANumber) + '_' + ALineType;
  Result := lStem;
  lDuplicate := 1;
  while fChannelNames.IndexOf(Result) >= 0 do
  begin
    Inc(lDuplicate);
    Result := lStem + '_' + IntToStr(lDuplicate);
  end;
  fChannelNames.Add(Result);
end;

{ Строит ключ канала, используя ALegacySuffix для старого формата. }
function TPointCodec.CurveChannel(const ASection, AKey,
  ALegacySuffix: string): string;
begin
  { Стабильные ID хранятся в метаданных; имена каналов можно строить по
    подписям тегов. Отсутствующая запись означает дескриптор старого формата. }
  Result := fIni.ReadString(ASection, AKey, ASection + ALegacySuffix);
end;

{ Записывает AValue в секцию ASection по ключу AKey. }
procedure TPointCodec.Number(const ASection, AKey: string; AValue: Double);
var lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  fIni.WriteString(ASection, AKey, FloatToStrF(AValue, ffGeneral, 17, 0, lFormat));
end;

{ Читает число из секции ASection по ключу AKey. }
function TPointCodec.ReadNumber(const ASection, AKey: string): Double;
var lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  Result := StrToFloat(fIni.ReadString(ASection, AKey, ''), lFormat);
end;

{ Сохраняет массив отсчётов в отдельный двоичный файл AName. }
procedure TPointCodec.WriteValues(const AName: string;
  const AValues: array of Double);
var lStream: TFileStream;
{$IFDEF ENDIAN_BIG}
  lValues: TDoubles; I: Integer; lBits: QWord;
{$ENDIF}
begin
  lStream := TFileStream.Create(fDirectory + AName, fmCreate);
  try
    if Length(AValues) > 0 then
{$IFDEF ENDIAN_BIG}
    begin
      SetLength(lValues, Length(AValues));
      for I := 0 to High(AValues) do
      begin
        Move(AValues[I], lBits, SizeOf(lBits));
        lBits := SwapEndian(lBits);
        Move(lBits, lValues[I], SizeOf(lBits));
      end;
      lStream.WriteBuffer(lValues[0], Length(lValues) * SizeOf(Double));
    end;
{$ELSE}
      lStream.WriteBuffer(AValues[0], Length(AValues) * SizeOf(Double));
{$ENDIF}
  finally
    lStream.Free;
  end;
end;

{ Загружает массив отсчётов из двоичного файла AName. }
function TPointCodec.ReadValues(const AName: string): TDoubles;
var lStream: TFileStream; lCount: Int64;
{$IFDEF ENDIAN_BIG}
  I: Integer; lBits: QWord;
{$ENDIF}
begin
  Result := nil;
  if (AName = '') or (ExtractFileName(AName) <> AName) or
    (Pos('..', AName) > 0) or (Pos(':', AName) > 0) then
    raise EReadError.Create('Unsafe MERA payload name');
  lStream := TFileStream.Create(fDirectory + AName, fmOpenRead or fmShareDenyWrite);
  try
    if (lStream.Size mod SizeOf(Double)) <> 0 then
      raise EReadError.Create('Truncated MERA R8 payload');
    lCount := lStream.Size div SizeOf(Double);
    if (lCount > RECORDER_IMPACT_MAX_TOTAL_SAMPLES) or
      (fTotalValues + lCount > RECORDER_IMPACT_MAX_FILE_BYTES div SizeOf(Double)) then
      raise EReadError.Create('MERA payload exceeds supported limit');
    Inc(fTotalValues, lCount);
    SetLength(Result, lCount);
    if lCount > 0 then lStream.ReadBuffer(Result[0], lCount * SizeOf(Double));
{$IFDEF ENDIAN_BIG}
    for I := 0 to High(Result) do
    begin
      Move(Result[I], lBits, SizeOf(lBits));
      lBits := SwapEndian(lBits);
      Move(lBits, Result[I], SizeOf(lBits));
    end;
{$ENDIF}
  finally
    lStream.Free;
  end;
end;

{ Читает значения кривой и сопоставляет их с частотами AFrequency. }
function TPointCodec.ReadCurveValues(const AName: string;
  const AFrequency: array of Double): TDoubles;
var lX: TDoubles; I: Integer;
begin
  if (fIni.ReadString(AName, 'XFormat', '') <> 'R8') or
    (fIni.ReadString(AName, 'YFormat', '') <> 'R8') then
    raise EReadError.Create('Unsupported MERA channel format');
  lX := ReadValues(fIni.ReadString(AName, 'XFile', ''));
  Result := ReadValues(fIni.ReadString(AName, 'YFile', ''));
  if Length(Result) = 0 then
  begin
    if Length(lX) <> 0 then raise EReadError.Create('Empty spectrum has nonempty frequency');
    Exit;
  end;
  if (Length(Result) <> Length(AFrequency)) or
    (Length(lX) <> Length(AFrequency)) then
    raise EReadError.Create('MERA spectral lengths differ');
  for I := 0 to High(lX) do
    if lX[I] <> AFrequency[I] then raise EReadError.Create('MERA frequency grids differ');
end;

{ Записывает метаданные и ряды одного канала в MERA. }
procedure TPointCodec.WriteChannel(const AName, ALabel, AUnit, AXUnit: string;
  const AX, AY: array of Double);
begin
  WriteValues(AName + '.dat', AY);
  if Length(AY) = 0 then WriteValues(AName + '.x', [])
  else WriteValues(AName + '.x', AX);
  fIni.WriteString(AName, 'Name', StringReplace(StringReplace(ALabel, #13, ' ',
    [rfReplaceAll]), #10, ' ', [rfReplaceAll]));
  fIni.WriteString(AName, 'NameUtf8Base64', EncodeStringBase64(ALabel));
  fIni.WriteString(AName, 'UnitUtf8Base64', EncodeStringBase64(AUnit));
  fIni.WriteString(AName, 'Address', AName);
  fIni.WriteString(AName, 'YFormat', 'R8');
  fIni.WriteString(AName, 'YFile', AName + '.dat');
  fIni.WriteString(AName, 'XFormat', 'R8');
  fIni.WriteString(AName, 'XFile', AName + '.x');
  fIni.WriteString(AName, 'YUnits', StringReplace(StringReplace(AUnit, #13, ' ',
    [rfReplaceAll]), #10, ' ', [rfReplaceAll]));
  fIni.WriteString(AName, 'XUnits', AXUnit);
  Number(AName, 'Freq', 0);
  Number(AName, 'Start', 0);
  Number(AName, 'k0', 0);
  Number(AName, 'k1', 1);
end;

{ Сериализует ряд с номером ANumber в секцию ASection. }
procedure TPointCodec.WriteSeries(const ASection: string; ANumber: Integer;
  const ALineType: string;
  const ASeries: TRecorderImpactSessionSeries);
var lX, lY: TDoubles; I: Integer; lChannel: string;
begin
  SetLength(lX, Length(ASeries.Samples));
  SetLength(lY, Length(ASeries.Samples));
  for I := 0 to High(lX) do
  begin
    lX[I] := ASeries.Samples[I].TimeSeconds;
    lY[I] := ASeries.Samples[I].Value;
  end;
  lChannel := ChannelName(ASeries.Name, ANumber, ALineType);
  WriteChannel(lChannel, lChannel, ASeries.UnitName, 's', lX, lY);
  fIni.WriteString(ASection, 'Channel', lChannel);
  fIni.WriteString(ASection, 'NameUtf8Base64', EncodeStringBase64(ASeries.Name));
  fIni.WriteString(ASection, 'UnitUtf8Base64', EncodeStringBase64(ASeries.UnitName));
  fIni.WriteString(ASection, 'TagId', UIntToStr(ASeries.TagId));
  fIni.WriteString(ASection, 'CurveId', UIntToStr(ASeries.CurveId));
end;

{ Восстанавливает временной ряд из секции ASection. }
function TPointCodec.ReadSeries(const ASection: string): TRecorderImpactSessionSeries;
var lX, lY: TDoubles; I: Integer; lChannel: string;
begin
  Result := Default(TRecorderImpactSessionSeries);
  lChannel := fIni.ReadString(ASection, 'Channel', ASection);
  if (fIni.ReadString(lChannel, 'XFormat', '') <> 'R8') or
    (fIni.ReadString(lChannel, 'YFormat', '') <> 'R8') then
    raise EReadError.Create('Unsupported MERA channel format');
  Result.TagId := StrToQWord(fIni.ReadString(ASection, 'TagId', ''));
  Result.CurveId := StrToQWord(fIni.ReadString(ASection, 'CurveId', ''));
  Result.Name := DecodeStringBase64(fIni.ReadString(ASection, 'NameUtf8Base64', ''));
  Result.UnitName := DecodeStringBase64(fIni.ReadString(ASection, 'UnitUtf8Base64', ''));
  lX := ReadValues(fIni.ReadString(lChannel, 'XFile', ''));
  lY := ReadValues(fIni.ReadString(lChannel, 'YFile', ''));
  if Length(lX) <> Length(lY) then raise EReadError.Create('MERA sample lengths differ');
  SetLength(Result.Samples, Length(lX));
  for I := 0 to High(lX) do
  begin
    Result.Samples[I].TimeSeconds := lX[I];
    Result.Samples[I].Value := lY[I];
  end;
end;

{ Сохраняет метаданные и массивы кривой с номером ANumber. }
procedure TPointCodec.WriteCurve(const ASection: string; ANumber: Integer;
  const ACurve: TRecorderImpactSessionCurve);
var lChannel: string;

  { Записывает один канал кривой с указанными ключом, тегом, типом и единицами. }
  procedure StoreChannel(const AKey, ATagName, AType, AUnit: string;
    const AValues: array of Double);
  begin
    lChannel := ChannelName(ATagName, ANumber, AType);
    fIni.WriteString(ASection, AKey, lChannel);
    WriteChannel(lChannel, lChannel, AUnit, 'Hz', ACurve.FrequencyHz, AValues);
  end;
begin
  fIni.WriteString(ASection, 'CurveId', UIntToStr(ACurve.CurveId));
  fIni.WriteString(ASection, 'TagId', UIntToStr(ACurve.TagId));
  fIni.WriteString(ASection, 'NameUtf8Base64', EncodeStringBase64(ACurve.Name));
  fIni.WriteString(ASection, 'ExcitationUnitUtf8Base64', EncodeStringBase64(ACurve.ExcitationUnitName));
  fIni.WriteString(ASection, 'ResponseUnitUtf8Base64', EncodeStringBase64(ACurve.ResponseUnitName));
  StoreChannel('FrfChannel', ACurve.Name, 'frf', ACurve.ResponseUnitName + '/' +
    ACurve.ExcitationUnitName, ACurve.Magnitude);
  StoreChannel('PhaseChannel', ACurve.Name, 'ph', 'rad', ACurve.PhaseRadians);
  StoreChannel('CoherenceChannel', ACurve.Name, 'coh', '', ACurve.Coherence);
  if Length(ACurve.ExcitationSpectrum) > 0 then
    StoreChannel('ExcitationChannel', fExcitationName, 'exc_spm',
      ACurve.ExcitationUnitName, ACurve.ExcitationSpectrum);
  if Length(ACurve.ResponseSpectrum) > 0 then
    StoreChannel('ResponseChannel', ACurve.Name, 'spm',
      ACurve.ResponseUnitName, ACurve.ResponseSpectrum);
end;

{ Восстанавливает FRF-кривую из секции ASection. }
function TPointCodec.ReadCurve(const ASection: string): TRecorderImpactSessionCurve;
begin
  Result := Default(TRecorderImpactSessionCurve);
  Result.CurveId := StrToQWord(fIni.ReadString(ASection, 'CurveId', ''));
  Result.TagId := StrToQWord(fIni.ReadString(ASection, 'TagId', ''));
  Result.Name := DecodeStringBase64(fIni.ReadString(ASection, 'NameUtf8Base64', ''));
  Result.ExcitationUnitName := DecodeStringBase64(fIni.ReadString(ASection, 'ExcitationUnitUtf8Base64', ''));
  Result.ResponseUnitName := DecodeStringBase64(fIni.ReadString(ASection, 'ResponseUnitUtf8Base64', ''));
  Result.FrequencyHz := ReadValues(fIni.ReadString(
    CurveChannel(ASection, 'FrfChannel', '_frf'), 'XFile', ''));
  Result.Magnitude := ReadCurveValues(CurveChannel(ASection, 'FrfChannel', '_frf'), Result.FrequencyHz);
  Result.PhaseRadians := ReadCurveValues(CurveChannel(ASection, 'PhaseChannel', '_phase'), Result.FrequencyHz);
  Result.Coherence := ReadCurveValues(CurveChannel(ASection, 'CoherenceChannel', '_coherence'), Result.FrequencyHz);
  if fIni.SectionExists(CurveChannel(ASection, 'ExcitationChannel', '_excitation')) then
    Result.ExcitationSpectrum := ReadCurveValues(CurveChannel(ASection, 'ExcitationChannel', '_excitation'), Result.FrequencyHz);
  if fIni.SectionExists(CurveChannel(ASection, 'ResponseChannel', '_response')) then
    Result.ResponseSpectrum := ReadCurveValues(CurveChannel(ASection, 'ResponseChannel', '_response'), Result.FrequencyHz);
end;

{ Читает количество из секции и ограничивает его AMaximum. }
function TPointCodec.Count(const ASection, AKey: string; AMaximum: Integer): Integer;
begin
  Result := fIni.ReadInteger(ASection, AKey, -1);
  if (Result < 0) or (Result > AMaximum) then
    raise EReadError.Create('Invalid MERA ' + AKey);
end;

{ Сериализует сессию в MERA: манифест, ряды и кривые. }
procedure TPointCodec.WriteSnapshot(const ASnapshot: TRecorderImpactSessionSnapshot);
var I, J: Integer; lSection: string; lLines: TStringList;
begin
  fIni.WriteString('MERA', 'Format', 'RecorderLnx.Impact');
  fIni.WriteInteger('MERA', 'Version', 1);
  fIni.WriteString('Session', 'IdUtf8Base64', EncodeStringBase64(ASnapshot.SessionId));
  Number('Session', 'CreatedUtc', ASnapshot.CreatedUtc);
  Number('Session', 'SampleRateHz', ASnapshot.SampleRateHz);
  fIni.WriteInteger('Session', 'ImpactCount', Length(ASnapshot.Impacts));
  fIni.WriteInteger('Session', 'CurveCount', Length(ASnapshot.Curves));
  if Length(ASnapshot.Impacts) > 0 then
    fExcitationName := ASnapshot.Impacts[0].Excitation.Name
  else fExcitationName := 'exc';
  for I := 0 to High(ASnapshot.Impacts) do
  begin
    lSection := 'Impact_' + IntToStr(I);
    fIni.WriteString(lSection, 'Sequence', UIntToStr(ASnapshot.Impacts[I].Sequence));
    Number(lSection, 'TriggerTime', ASnapshot.Impacts[I].TriggerTimeSeconds);
    fIni.WriteBool(lSection, 'Accepted', ASnapshot.Impacts[I].Accepted);
    fIni.WriteBool(lSection, 'Hidden', ASnapshot.Impacts[I].Hidden);
    fIni.WriteInteger(lSection, 'ResponseCount', Length(ASnapshot.Impacts[I].Responses));
    WriteSeries(lSection + '_excitation', I + 1, 'exc', ASnapshot.Impacts[I].Excitation);
    for J := 0 to High(ASnapshot.Impacts[I].Responses) do
      WriteSeries(lSection + '_response_' + IntToStr(J), I + 1, 'time', ASnapshot.Impacts[I].Responses[J]);
  end;
  for I := 0 to High(ASnapshot.Curves) do
    WriteCurve('Curve_' + IntToStr(I), I + 1, ASnapshot.Curves[I]);
  lLines := TStringList.Create;
  try
    fIni.GetStrings(lLines);
    { Дескрипторы MERA используют CP1251; бинарные отсчёты R8 не перекодируются. }
    lLines.Text := UTF8ToCP1251(lLines.Text);
    lLines.SaveToFile(TRecorderImpactMeraPointStore.SessionFileName(fDirectory));
  finally
    lLines.Free;
  end;
end;

{ Восстанавливает снимок из манифеста и файлов MERA. }
function TPointCodec.ReadSnapshot: TRecorderImpactSessionSnapshot;
var I, J: Integer; lSection: string; lLines: TStringList; lStream: TFileStream;
begin
  Result := Default(TRecorderImpactSessionSnapshot);
  lStream := TFileStream.Create(TRecorderImpactMeraPointStore.SessionFileName(fDirectory),
    fmOpenRead or fmShareDenyWrite);
  try
    if lStream.Size > 1024 * 1024 then raise EReadError.Create('MERA descriptor too large');
    lLines := TStringList.Create;
    try
      lLines.LoadFromStream(lStream);
      lLines.Text := CP1251ToUTF8(lLines.Text);
      fIni.SetStrings(lLines);
    finally
      lLines.Free;
    end;
  finally
    lStream.Free;
  end;
  if (fIni.ReadString('MERA', 'Format', '') <> 'RecorderLnx.Impact') or
    (fIni.ReadInteger('MERA', 'Version', 0) <> 1) then
    raise EReadError.Create('Unsupported impact MERA descriptor');
  Result.FormatVersion := RECORDER_IMPACT_SESSION_VERSION;
  Result.SessionId := DecodeStringBase64(fIni.ReadString('Session', 'IdUtf8Base64', ''));
  Result.CreatedUtc := ReadNumber('Session', 'CreatedUtc');
  Result.SampleRateHz := ReadNumber('Session', 'SampleRateHz');
  SetLength(Result.Impacts, Count('Session', 'ImpactCount', RECORDER_IMPACT_MAX_IMPACTS));
  for I := 0 to High(Result.Impacts) do
  begin
    lSection := 'Impact_' + IntToStr(I);
    Result.Impacts[I].Sequence := StrToQWord(fIni.ReadString(lSection, 'Sequence', ''));
    Result.Impacts[I].TriggerTimeSeconds := ReadNumber(lSection, 'TriggerTime');
    Result.Impacts[I].Accepted := fIni.ReadBool(lSection, 'Accepted', False);
    Result.Impacts[I].Hidden := fIni.ReadBool(lSection, 'Hidden', False);
    Result.Impacts[I].Excitation := ReadSeries(lSection + '_excitation');
    SetLength(Result.Impacts[I].Responses,
      Count(lSection, 'ResponseCount', RECORDER_IMPACT_MAX_RESPONSES));
    for J := 0 to High(Result.Impacts[I].Responses) do
      Result.Impacts[I].Responses[J] := ReadSeries(lSection + '_response_' + IntToStr(J));
  end;
  SetLength(Result.Curves, Count('Session', 'CurveCount', RECORDER_IMPACT_MAX_CURVES));
  for I := 0 to High(Result.Curves) do Result.Curves[I] := ReadCurve('Curve_' + IntToStr(I));
end;

{ Строит путь к session.mera в ADirectory. }
class function TRecorderImpactMeraPointStore.SessionFileName(const ADirectory: string): string;
begin
  Result := IncludeTrailingPathDelimiter(ADirectory) + 'session.mera';
end;

{ Сохраняет снимок сессии в MERA-каталог; AError получает причину отказа. }
class function TRecorderImpactMeraPointStore.Save(const ADirectory: string;
  const ASnapshot: TRecorderImpactSessionSnapshot; out AError: string): Boolean;
var lCodec: TPointCodec;
begin
  Result := False;
  AError := '';
  if not ValidateImpactSession(ASnapshot, AError) then Exit;
  try
    if not ForceDirectories(ADirectory) then raise EWriteError.Create('Cannot create MERA directory');
    lCodec := TPointCodec.Create(ADirectory);
    try
      lCodec.WriteSnapshot(ASnapshot);
      Result := True;
    finally
      lCodec.Free;
    end;
  except on E: Exception do AError := E.Message; end;
end;

{ Загружает снимок из MERA-каталога; AError получает причину отказа. }
class function TRecorderImpactMeraPointStore.Load(const ADirectory: string;
  out ASnapshot: TRecorderImpactSessionSnapshot; out AError: string): Boolean;
var lCodec: TPointCodec;
begin
  Result := False;
  AError := '';
  ASnapshot := Default(TRecorderImpactSessionSnapshot);
  try
    lCodec := TPointCodec.Create(ADirectory);
    try
      ASnapshot := lCodec.ReadSnapshot;
      Result := ValidateImpactSession(ASnapshot, AError);
    finally
      lCodec.Free;
    end;
  except on E: Exception do AError := E.Message; end;
  if not Result then ASnapshot := Default(TRecorderImpactSessionSnapshot);
end;

end.
