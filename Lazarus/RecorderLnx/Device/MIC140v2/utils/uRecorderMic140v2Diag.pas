unit uRecorderMic140v2Diag;

{
  Лог и проверка corrupt raw-блока.

  [LNX] пороги misalign/saturation — эвристика TCP-ридера, нет в windev BIOS.
}

{$mode objfpc}{$H+}

interface

uses
  uRecorderMic140v2WireTypes;

const
  CMic140v2ScanDetailLogBlocks = 15;     { LNX: подробный лог первых N блоков }
  CMic140v2NumBuffDesyncMissed = 32;    { LNX: порог num_buff → stream restart }
  CMic140v2ReadTimeoutWarnAfter = 3;     { LNX }

procedure Mic140v2Log(const AMsg: string);
function Mic140v2RawRowCorrupt(const ARaw: TMic140LegacyRawBlock;
  AOffset, AUserCh: Integer): Boolean;
function Mic140v2RawRowHeadNominal(const ARaw: TMic140LegacyRawBlock;
  AOffset, AUserCh: Integer): Boolean;
function Mic140v2RawRowRecorderProfile(const ARaw: TMic140LegacyRawBlock;
  AOffset, AUserCh: Integer): Boolean;
function Mic140v2RawCorrupt(const ARaw: TMic140LegacyRawBlock;
  AUserCh: Integer; AStride: Integer = 0): Boolean;
function Mic140v2RawQualityText(const ARaw: TMic140LegacyRawBlock;
  AUserCh: Integer; AStride: Integer = 0): string;

implementation

uses
  SysUtils, Math, uSharedFileLogger, uRecorderDebugLog;

const
  CPosThr = 500.0;
  CMinSat = 32;
  CMinPos = 20;
  CStrainMin = -15000;
  CStrainMax = 500;
  CStrainWindow = 12;
  CMinBadStrain = 4;
  CHeadWindow = 8;
  CMinBadHead = 2;
  CHeadNominalMin = -8200;
  CHeadNominalMax = -6300;
  CHeadNominalWindow = 12;
  CMinHeadNominal = 8;
  CHeadStartWindow = 4;

procedure Mic140v2Log(const AMsg: string);
begin
  if CMic140StreamLogOnly and not Mic140StreamLogAllowed(AMsg) then
    Exit;
  SharedLogger.Enabled := True;
  SharedLogger.Warning(AMsg);
end;

function Mic140v2RawRowCorrupt(const ARaw: TMic140LegacyRawBlock;
  AOffset, AUserCh: Integer): Boolean;
var
  lI, lLast, lCode, lSat, lPos, lBadStrain, lBadHead, lHeadSat,
  lHeadPos, lHeadNominal: Integer;
begin
  Result := False;
  if (AOffset < 0) or (AOffset >= ARaw.DataWordCount) or (AUserCh <= 0) then
    Exit;
  lSat := 0;
  lPos := 0;
  lBadStrain := 0;
  lBadHead := 0;
  lHeadSat := 0;
  lHeadPos := 0;
  lHeadNominal := 0;
  lLast := Min(AUserCh - 1, 47);
  for lI := 0 to lLast do
  begin
    if AOffset + lI >= ARaw.DataWordCount then
      Break;
    lCode := SmallInt(ARaw.Data[AOffset + lI]);
    if (lCode >= 32767) or (lCode <= -32768) then
      Inc(lSat)
    else if lCode > CPosThr then
      Inc(lPos);
    if (lI < CStrainWindow) and
       ((lCode < CStrainMin) or (lCode > CStrainMax)) then
      Inc(lBadStrain);
    if (lI < CHeadWindow) and
       ((lCode < CStrainMin) or (lCode > CStrainMax)) then
      Inc(lBadHead);
    if lI < CHeadNominalWindow then
    begin
      if (lCode >= 32767) or (lCode <= -32768) then
        Inc(lHeadSat)
      else if lCode > CStrainMax then
        Inc(lHeadPos);
      if (lCode >= CHeadNominalMin) and (lCode <= CHeadNominalMax) then
        Inc(lHeadNominal);
    end;
  end;
  Result := (lSat >= CMinSat) or (lPos >= CMinPos) or
    (lBadStrain >= CMinBadStrain) or (lBadHead >= CMinBadHead) or
    (lHeadSat > 0) or (lHeadPos > 0) or
    (lHeadNominal < CMinHeadNominal);
end;

function Mic140v2RawRowHeadNominal(const ARaw: TMic140LegacyRawBlock;
  AOffset, AUserCh: Integer): Boolean;
var
  lI, lLast, lCode, lNominal, lStartNominal: Integer;
begin
  Result := False;
  if (AOffset < 0) or (AOffset >= ARaw.DataWordCount) or (AUserCh <= 0) then
    Exit;
  lNominal := 0;
  lStartNominal := 0;
  lLast := Min(Min(AUserCh - 1, CHeadNominalWindow - 1), 47);
  for lI := 0 to lLast do
  begin
    if AOffset + lI >= ARaw.DataWordCount then
      Break;
    lCode := SmallInt(ARaw.Data[AOffset + lI]);
    if (lCode >= CHeadNominalMin) and (lCode <= CHeadNominalMax) then
    begin
      Inc(lNominal);
      if lI < CHeadStartWindow then
        Inc(lStartNominal);
    end;
  end;
  Result := (lStartNominal >= CHeadStartWindow) and
    (lNominal >= CMinHeadNominal);
end;

function Mic140v2RawRowRecorderProfile(const ARaw: TMic140LegacyRawBlock;
  AOffset, AUserCh: Integer): Boolean;
var
  lI, lLast, lCode, lMin, lMax: Integer;
begin
  Result := False;
  if (AOffset < 0) or (AUserCh < 48) or
     (AOffset + 48 > ARaw.DataWordCount) then
    Exit;
  lLast := Min(AUserCh - 1, 47);
  for lI := 0 to lLast do
  begin
    lCode := SmallInt(ARaw.Data[AOffset + lI]);
    if (lCode >= 32760) or (lCode <= -32760) or (lCode = 0) or
       (lCode > 0) then
      Exit;
    if lI < 24 then
    begin
      lMin := -8200;
      lMax := -6300;
    end
    else
    begin
      lMin := -24000;
      lMax := -13000;
    end;
    if (lCode < lMin) or (lCode > lMax) then
      Exit;
  end;
  Result := True;
end;

function Mic140v2RawCorrupt(const ARaw: TMic140LegacyRawBlock;
  AUserCh: Integer; AStride: Integer = 0): Boolean;
var
  i, j, n, stride, code, sat, pos: Integer;
begin
  sat := 0;
  pos := 0;
  if (ARaw.DataWordCount = 0) or (AUserCh <= 0) then
    Exit(False);
  stride := AStride;
  if stride <= 0 then
    stride := AUserCh + MIC140TemperatureChannelCount;
  if (stride <= 0) or ((ARaw.DataWordCount mod stride) <> 0) then
    Exit(False);
  n := ARaw.DataWordCount div stride;
  if n <= 0 then
    Exit(False);
  for j := 0 to n - 1 do
    for i := 0 to Min(AUserCh - 1, 47) do
    begin
      code := SmallInt(ARaw.Data[j * stride + i]);
      if (code >= 32767) or (code <= -32768) then
        Inc(sat)
      else if code > CPosThr then
        Inc(pos);
    end;
  Result := (sat >= CMinSat) or (pos >= CMinPos);
end;

function Mic140v2RawQualityText(const ARaw: TMic140LegacyRawBlock;
  AUserCh: Integer; AStride: Integer = 0): string;
var
  lStride, lWindow, lOfs, lBestOfs, lBad, lBestBad, lPos, lSat: Integer;
  lI, lCode: Integer;
begin
  Result := '';
  if (ARaw.DataWordCount = 0) or (AUserCh <= 0) then
    Exit;

  lStride := AStride;
  if lStride <= 0 then
    lStride := AUserCh;
  lWindow := Min(AUserCh, 48);
  if (lStride <= 0) or (lWindow <= 0) then
    Exit;

  lBestOfs := 0;
  lBestBad := MaxInt;
  lOfs := 0;
  while lOfs + lWindow <= ARaw.DataWordCount do
  begin
    lBad := 0;
    for lI := 0 to lWindow - 1 do
    begin
      lCode := SmallInt(ARaw.Data[lOfs + lI]);
      if (lCode >= 32767) or (lCode <= -32768) or (lCode > CPosThr) then
        Inc(lBad);
    end;
    if lBad < lBestBad then
    begin
      lBestBad := lBad;
      lBestOfs := lOfs;
    end;
    Inc(lOfs);
  end;

  lPos := 0;
  lSat := 0;
  for lI := 0 to Min(ARaw.DataWordCount - 1, lWindow - 1) do
  begin
    lCode := SmallInt(ARaw.Data[lI]);
    if (lCode >= 32767) or (lCode <= -32768) then
      Inc(lSat)
    else if lCode > CPosThr then
      Inc(lPos);
  end;

  Result := Format('quality ofs0(pos=%d sat=%d) bestOfs=%d bestBad=%d window=%d stride=%d words=%d',
    [lPos, lSat, lBestOfs, lBestBad, lWindow, lStride, ARaw.DataWordCount]);
end;

end.
