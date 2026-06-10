unit uPeakFrm;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls, uStringGridExt;
type
  TPeakFrm = class(TForm)
    DebugPanel: TPanel;
    DebugLogBtn: TButton;
    PeakStatusLabel: TLabel;
    RatioStatusLabel: TLabel;
    RatioLimitLabel: TLabel;
    RatioLimitEdit: TEdit;
    ProfileSG: TStringGridExt;
    TrigStatusLabel: TLabel;
    procedure DebugLogBtnClick(Sender: TObject);
    procedure ProfileSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure RatioLimitEditChange(Sender: TObject);
  private
    { Private declarations }
    FBands: TObject;
    FFRFFrm: TObject;
    FBandRatio: double;
    FBandRatioValid: boolean;
    FBandRatioBlocked: boolean;
    FUpdatingRatioLimit: boolean;
    procedure FillGrid(AExtremums: TList);
    procedure UpdateBandStatus(AExtremums: TList);
    procedure SetTrigStatus(const AText: string; AColor: TColor);
    function GetRatioLimit: double;
    function CalcBandValueRatio(AExtremums: TList): boolean;
    procedure UpdateRatioStatus;
    function RatioStatusText: string;
    function IsAllBandsFound(AExtremums: TList): boolean;
    function IsNearBandBoundary(AExtremum: TObject): boolean;
  public
    { Public declarations }
    procedure ShowFRFPeaks(AFRFFrm: TObject);
  end;
function EvalFRFPeaks(AFRFFrm, ASignal: TObject; AShowMessages: Boolean;
  ADebugLog: Boolean = false): Boolean;
var
  PeakFrm: TPeakFrm;
implementation
uses
  MathFunction, u2DMath, uBuffTrend1d, uCommonMath, uCommonTypes,
  uEvalFRFFrm, uBladeDB, uBladeReport, uSpmBand, uLogFile;
{$R *.dfm}
const
  cPeakColFreq = 0;
  cPeakColValue = 1;
  cPeakColDec = 2;
  cPeakColIndex = 3;
  cNearBandTolPercent = 10;
  cPeakDebugLogLimit = 200;
  cDefaultBandRatioLimit = 0.2;
procedure ClearBandExtremums(AList: TList);
var
  i: integer;
begin
  if AList = nil then
    exit;
  for i := 0 to AList.Count - 1 do
    cExtremum(AList.Items[i]).destroy;
  AList.Clear;
end;
function EvalFRFPeaks(AFRFFrm, ASignal: TObject; AShowMessages: Boolean;
  ADebugLog: Boolean = false): Boolean;
var
  f: TFRFFrm;
  s: cSRSres;
  cfg: cSpmCfg;
  bl: cBladeFolder;
  b: tSpmBand;
  BandExtr, prevExtr: cExtremum;
  block: TDataBlock;
  i, k, maxIndex, zoneStart, zoneMaxIndex: integer;
  debugPeakCount, debugLoggedCount: integer;
  debugSource: string;
  d: TDoubleArray;
  line: cBuffTrend1d;
  p1, p2: point2d;
  v, vf, f1, f2, tol, absTol, mainF, trigLevel, lowLevel, dx: double;
  zoneMax: double;
  inZone, armed: boolean;
  function GetXByInd(AIndex: integer): double;
  begin
    result := AIndex * dx;
  end;
  procedure DebugLog(const AText: string);
  begin
    if not ADebugLog then
      exit;
    if g_logFile = nil then
      g_logFile := cLogFile.Create('e:\Oburec\delphi\2011\OburecGH\recorder\plgEvalFRF\log\log.txt', ';');
    logMessage(AText);
  end;
  function PeakExists(AIndex: integer): boolean;
  var
    n: integer;
    e: cExtremum;
  begin
    result := false;
    for n := 0 to s.m_BandExtremums.Count - 1 do
    begin
      e := cExtremum(s.m_BandExtremums.Items[n]);
      if abs(e.Index - AIndex) <= 1 then
      begin
        result := true;
        exit;
      end;
    end;
  end;
  procedure AddPeak(AIndex, AZoneStart, AZoneEnd: integer);
  var
    bandIndex: integer;
  begin
    if (AIndex <= 0) or (AIndex >= length(d)) or PeakExists(AIndex) then
      exit;
    BandExtr := cExtremum.create;
    s.m_BandExtremums.Add(BandExtr);
    BandExtr.Index := AIndex;
    BandExtr.Value := d[AIndex];
    BandExtr.Freq := GetXByInd(AIndex);
    for bandIndex := 0 to f.m_bands.Count - 1 do
    begin
      b := f.m_bands.getband(bandIndex);
      b.m_f1i := trunc(b.m_f1 / dx) + 1;
      b.m_f2i := trunc(b.m_f2 / dx);
      if (BandExtr.Index > b.m_f1i) and (BandExtr.Index < b.m_f2i) then
      begin
        BandExtr.m_b := b;
        BandExtr.BandNum := bandIndex;
        BandExtr.NumInBand := 0;
        if (prevExtr <> nil) and (prevExtr.BandNum = bandIndex) then
          BandExtr.NumInBand := prevExtr.NumInBand + 1;
        break;
      end;
    end;
    prevExtr := BandExtr;
    BandExtr.decrement := -1;
    v := BandExtr.Value * 0.5;
    k := AIndex;
    while (k > 0) and (d[k] > v) do
      dec(k);
    if k > 0 then
    begin
      p1.x := GetXByInd(k);
      p1.y := d[k];
      p2.x := GetXByInd(AIndex);
      p2.y := d[AIndex];
      f1 := EvalLineX(v, p1, p2);
      k := AIndex;
      while (k < high(d)) and (d[k] > v) do
        inc(k);
      if k < length(d) then
      begin
        p1.x := GetXByInd(k);
        p1.y := d[k];
        f2 := EvalLineX(v, p1, p2);
        vf := 2 * p2.x;
        if vf <> 0 then
          BandExtr.decrement := (f2 - f1) / vf;
      end;
    end;
    inc(debugPeakCount);
    if debugLoggedCount < cPeakDebugLogLimit then
    begin
      inc(debugLoggedCount);
      // CODEx DEBUG: временный лог найденного пика, убрать после разбора лишних/пропавших пиков.
      DebugLog('PEAK_DEBUG ADD;src=' + debugSource +
        ';shockIndex=' + inttostr(f.GetShockNum) +
        ';shockNo=' + inttostr(f.GetShockNum + 1) +
        ';i=' + inttostr(BandExtr.Index) +
        ';zoneStart=' + inttostr(AZoneStart) +
        ';zoneEnd=' + inttostr(AZoneEnd) +
        ';f=' + floattostr(BandExtr.Freq) +
        ';v=' + floattostr(BandExtr.Value) +
        ';prev=' + floattostr(d[AIndex - 1]) +
        ';next=' + floattostr(d[AIndex + 1]) +
        ';trig=' + floattostr(trigLevel) +
        ';dec=' + floattostr(BandExtr.decrement) +
        ';band=' + inttostr(BandExtr.BandNum));
    end;
  end;
begin
  result := false;
  f := TFRFFrm(AFRFFrm);
  s := cSRSres(ASignal);
  if (f = nil) or (s = nil) then
    exit;
  cfg := s.cfg;
  if (cfg = nil) or (f.m_bands = nil) or (f.m_bands.Count = 0) then
    exit;
  trigLevel := f.TrigFE.Value;
  if trigLevel <= 0 then
    trigLevel := f.m_spmTrig;
  if trigLevel > 0 then
    f.m_spmTrig := trigLevel;
  if trigLevel <= 0 then
  begin
    if AShowMessages and (PeakFrm <> nil) then
      PeakFrm.SetTrigStatus('Установить уровень Trig >0', RGB(255, 220, 220));
    exit;
  end;
  if AShowMessages and (PeakFrm <> nil) then
    PeakFrm.SetTrigStatus('', clBtnFace);
  dx := cfg.fspmdx;
  if dx <= 0 then
    exit;
  debugPeakCount := 0;
  debugLoggedCount := 0;
  debugSource := 'line';
  d := nil;
  if f.ResTypeRG.ItemIndex = 0 then
  begin
    if f.useAvrCb.Checked then
    begin
      d := s.m_frf;
      debugSource := 'avg_m_frf';
    end
    else
    begin
      block := s.m_shockList.getBlock(f.GetShockNum);
      if block <> nil then
      begin
        d := block.m_frf;
        debugSource := 'shock_block_m_frf';
      end
      else
        debugSource := 'shock_block_nil';
    end;
  end;
  if length(d) = 0 then
  begin
    line := f.getLine(s);
    if line = nil then
      exit;
    d := TDoubleArray(line.data_r);
    debugSource := 'line_data_r';
  end;
  if length(d) < 3 then
    exit;
  if g_mbase <> nil then
    bl := g_mbase.SelectBlade
  else
    bl := nil;
  b := f.m_bands.getband(f.m_bands.Count - 1);
  maxIndex := trunc(b.m_f2 / dx);
  if maxIndex >= high(d) then
    maxIndex := high(d) - 1;
  if maxIndex <= 1 then
    exit;
  // CODEx DEBUG: временный заголовок блока расчета, убрать после разбора лишних/пропавших пиков.
  DebugLog('PEAK_DEBUG BEGIN;time=' + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) +
    ';src=' + debugSource +
    ';shockIndex=' + inttostr(f.GetShockNum) +
    ';shockNo=' + inttostr(f.GetShockNum + 1) +
    ';useAvr=' + inttostr(ord(f.useAvrCb.Checked)) +
    ';resType=' + inttostr(f.ResTypeRG.ItemIndex) +
    ';dx=' + floattostr(dx) +
    ';trig=' + floattostr(trigLevel) +
    ';trigFE=' + floattostr(f.TrigFE.Value) +
    ';m_spmTrig=' + floattostr(f.m_spmTrig) +
    ';len=' + inttostr(length(d)) +
    ';maxIndex=' + inttostr(maxIndex) +
    ';maxFreq=' + floattostr(GetXByInd(maxIndex)));
  lowLevel := 0.95 * trigLevel;
  // CODEx DEBUG: временный лог параметров гистерезиса, убрать после разбора лишних/пропавших пиков.
  DebugLog('PEAK_DEBUG HYST;hi=' + floattostr(trigLevel) +
    ';lo=' + floattostr(lowLevel));
  ClearBandExtremums(s.m_BandExtremums);
  prevExtr := nil;
  inZone := false;
  armed := true;
  zoneStart := -1;
  zoneMaxIndex := -1;
  zoneMax := -1.0E308;
  if d[1] > trigLevel then
  begin
    inZone := true;
    armed := false;
    zoneStart := 1;
    zoneMaxIndex := 1;
    zoneMax := d[1];
    // CODEx DEBUG: временный лог стартовой гистерезисной зоны, убрать после разбора лишних/пропавших пиков.
    DebugLog('PEAK_DEBUG START_OPEN;src=' + debugSource +
      ';shockIndex=' + inttostr(f.GetShockNum) +
      ';shockNo=' + inttostr(f.GetShockNum + 1) +
      ';zoneStart=1' +
      ';y0_as_zero=0' +
      ';y1=' + floattostr(d[1]));
  end;
  for i := 2 to maxIndex do
  begin
    if not inZone then
    begin
      if d[i] < lowLevel then
        armed := true;
      if armed and (d[i] > trigLevel) then
      begin
        inZone := true;
        zoneStart := i;
        zoneMaxIndex := i;
        zoneMax := d[i];
      end;
    end
    else
    begin
      if d[i] > zoneMax then
      begin
        zoneMax := d[i];
        zoneMaxIndex := i;
      end;
      if d[i] < lowLevel then
      begin
        if zoneMaxIndex >= 0 then
          AddPeak(zoneMaxIndex, zoneStart, i);
        inZone := false;
        armed := true;
        zoneStart := -1;
        zoneMaxIndex := -1;
        zoneMax := -1.0E308;
      end;
    end;
  end;
  if inZone then
  begin
    // CODEx DEBUG: временный лог незакрытой гистерезисной зоны, убрать после разбора лишних/пропавших пиков.
    DebugLog('PEAK_DEBUG DROP_OPEN_END;src=' + debugSource +
      ';shockIndex=' + inttostr(f.GetShockNum) +
      ';shockNo=' + inttostr(f.GetShockNum + 1) +
      ';zoneStart=' + inttostr(zoneStart) +
      ';maxI=' + inttostr(zoneMaxIndex) +
      ';maxF=' + floattostr(GetXByInd(zoneMaxIndex)) +
      ';maxV=' + floattostr(zoneMax) +
      ';endI=' + inttostr(maxIndex) +
      ';endV=' + floattostr(d[maxIndex]));
  end;
  if s.m_BandExtremums.Count = 0 then
  begin
    // CODEx DEBUG: временный итог блока расчета, убрать после разбора лишних/пропавших пиков.
    DebugLog('PEAK_DEBUG END;src=' + debugSource +
      ';shockIndex=' + inttostr(f.GetShockNum) +
      ';shockNo=' + inttostr(f.GetShockNum + 1) +
      ';peakCount=' + inttostr(debugPeakCount) +
      ';loggedCount=' + inttostr(debugLoggedCount) +
      ';tableCount=0');
    exit;
  end;
  if bl <> nil then
    tol := bl.GetTolerance(0)
  else
    tol := 0;
  for i := 0 to s.m_BandExtremums.Count - 1 do
  begin
    BandExtr := cExtremum(s.m_BandExtremums.Items[i]);
    if BandExtr.m_b <> nil then
    begin
      mainF := (BandExtr.m_b.m_f2 + BandExtr.m_b.m_f1) * 0.5;
      if mainF <> 0 then
        absTol := 100 * abs(mainF - BandExtr.Freq) / mainF
      else
        absTol := 0;
      BandExtr.error := absTol;
      BandExtr.InTol := (tol > 0) and (absTol < tol);
    end;
  end;
  // CODEx DEBUG: временный итог блока расчета, убрать после разбора лишних/пропавших пиков.
  DebugLog('PEAK_DEBUG END;src=' + debugSource +
    ';shockIndex=' + inttostr(f.GetShockNum) +
    ';shockNo=' + inttostr(f.GetShockNum + 1) +
    ';peakCount=' + inttostr(debugPeakCount) +
    ';loggedCount=' + inttostr(debugLoggedCount) +
    ';tableCount=' + inttostr(s.m_BandExtremums.Count));
  result := true;
end;
function TPeakFrm.GetRatioLimit: double;
var
  s: string;
begin
  result := cDefaultBandRatioLimit;
  if RatioLimitEdit = nil then
    exit;
  s := Trim(RatioLimitEdit.Text);
  if s = '' then
    exit;
  s := StringReplace(s, '.', DecimalSeparator, [rfReplaceAll]);
  s := StringReplace(s, ',', DecimalSeparator, [rfReplaceAll]);
  try
    result := StrToFloat(s);
  except
    result := cDefaultBandRatioLimit;
  end;
  if result < 0 then
    result := 0;
  if result > 1 then
    result := 1;
end;
function TPeakFrm.CalcBandValueRatio(AExtremums: TList): boolean;
var
  i, count, bandIndex: integer;
  bands: bList;
  extr: cExtremum;
  bandValues: array of double;
  minV, maxV, v: double;
begin
  result := false;
  FBandRatioValid := false;
  FBandRatioBlocked := false;
  FBandRatio := 0;
  if (AExtremums = nil) or (FBands = nil) then
    exit;
  bands := bList(FBands);
  if bands.Count < 2 then
    exit;
  SetLength(bandValues, bands.Count);
  for i := 0 to high(bandValues) do
    bandValues[i] := -1;
  for i := 0 to AExtremums.Count - 1 do
  begin
    extr := cExtremum(AExtremums.Items[i]);
    if (extr <> nil) and (extr.BandNum >= 0) and (extr.BandNum < bands.Count) then
    begin
      v := abs(extr.Value);
      if v > bandValues[extr.BandNum] then
        bandValues[extr.BandNum] := v;
    end;
  end;
  minV := 1.0E308;
  maxV := 0;
  count := 0;
  for bandIndex := 0 to high(bandValues) do
  begin
    v := bandValues[bandIndex];
    if v >= 0 then
    begin
      if v < minV then
        minV := v;
      if v > maxV then
        maxV := v;
      inc(count);
    end;
  end;
  if (count < 2) or (maxV <= 0) then
    exit;
  FBandRatio := minV / maxV;
  FBandRatioValid := true;
  FBandRatioBlocked := FBandRatio < GetRatioLimit;
  result := true;
end;
procedure TPeakFrm.UpdateRatioStatus;
var
  limit: double;
begin
  if RatioStatusLabel = nil then
    exit;
  limit := GetRatioLimit;
  if not FBandRatioValid then
  begin
    RatioStatusLabel.Caption := 'Мин/макс: -';
    RatioStatusLabel.Color := clBtnFace;
    RatioStatusLabel.Font.Color := clWindowText;
    exit;
  end;
  RatioStatusLabel.Caption := 'Мин/макс: ' + FloatToStrF(FBandRatio, ffFixed, 5, 3) +
    ' >= ' + FloatToStrF(limit, ffFixed, 5, 3);
  if FBandRatioBlocked then
  begin
    RatioStatusLabel.Color := RGB(255, 180, 180);
    RatioStatusLabel.Font.Color := clMaroon;
  end
  else
  begin
    RatioStatusLabel.Color := RGB(181, 220, 150);
    RatioStatusLabel.Font.Color := clGreen;
  end;
end;
function TPeakFrm.RatioStatusText: string;
begin
  if not FBandRatioValid then
    result := ''
  else
    result := ' мин/макс=' + FloatToStrF(FBandRatio, ffFixed, 5, 3);
end;
procedure TPeakFrm.UpdateBandStatus(AExtremums: TList);
begin
  CalcBandValueRatio(AExtremums);
  UpdateRatioStatus;
  if (AExtremums = nil) or (FBands = nil) then
  begin
    PeakStatusLabel.Caption := 'Полосы не найдены';
    PeakStatusLabel.Color := RGB(255, 180, 180);
    PeakStatusLabel.Font.Color := clMaroon;
    exit;
  end;
  if IsAllBandsFound(AExtremums) and not FBandRatioBlocked then
  begin
    PeakStatusLabel.Caption := 'Все полосы найдены' + RatioStatusText;
    PeakStatusLabel.Color := RGB(181, 220, 150);
    PeakStatusLabel.Font.Color := clGreen;
  end
  else if IsAllBandsFound(AExtremums) and FBandRatioBlocked then
  begin
    PeakStatusLabel.Caption := 'Удар не найден' + RatioStatusText;
    PeakStatusLabel.Color := RGB(255, 180, 180);
    PeakStatusLabel.Font.Color := clMaroon;
  end
  else
  begin
    PeakStatusLabel.Caption := 'Не все полосы найдены' + RatioStatusText;
    PeakStatusLabel.Color := RGB(255, 180, 180);
    PeakStatusLabel.Font.Color := clMaroon;
  end;
end;

procedure TPeakFrm.FillGrid(AExtremums: TList);
var
  i, c: integer;
  extr: cExtremum;
begin
  ProfileSG.ColCount := 4;
  if AExtremums = nil then
    ProfileSG.RowCount := 2
  else
    ProfileSG.RowCount := AExtremums.Count + 1;
  if ProfileSG.RowCount < 2 then
    ProfileSG.RowCount := 2;
  ProfileSG.FixedRows := 1;
  ProfileSG.ColWidths[cPeakColFreq] := 90;
  ProfileSG.ColWidths[cPeakColValue] := 90;
  ProfileSG.ColWidths[cPeakColDec] := 90;
  ProfileSG.ColWidths[cPeakColIndex] := 120;
  ProfileSG.Cells[cPeakColFreq, 0] := 'Частота';
  ProfileSG.Cells[cPeakColValue, 0] := 'Амплитуда';
  ProfileSG.Cells[cPeakColDec, 0] := 'Декремент';
  ProfileSG.Cells[cPeakColIndex, 0] := 'Индекс отсчета';
  for i := 1 to ProfileSG.RowCount - 1 do
  begin
    for c := 0 to ProfileSG.ColCount - 1 do
      ProfileSG.Objects[c, i] := nil;
    ProfileSG.Cells[cPeakColFreq, i] := '';
    ProfileSG.Cells[cPeakColValue, i] := '';
    ProfileSG.Cells[cPeakColDec, i] := '';
    ProfileSG.Cells[cPeakColIndex, i] := '';
  end;
  if AExtremums = nil then
  begin
    UpdateBandStatus(AExtremums);
    exit;
  end;
  for i := 0 to AExtremums.Count - 1 do
  begin
    extr := cExtremum(AExtremums.Items[i]);
    for c := 0 to ProfileSG.ColCount - 1 do
      ProfileSG.Objects[c, i + 1] := extr;
    ProfileSG.Cells[cPeakColFreq, i + 1] := floattostr(extr.Freq);
    ProfileSG.Cells[cPeakColValue, i + 1] := floattostr(extr.Value);
    ProfileSG.Cells[cPeakColDec, i + 1] := floattostr(extr.decrement);
    ProfileSG.Cells[cPeakColIndex, i + 1] := inttostr(extr.Index);
  end;
  UpdateBandStatus(AExtremums);
end;
function TPeakFrm.IsAllBandsFound(AExtremums: TList): boolean;
var
  i, j: integer;
  bands: bList;
  extr: cExtremum;
  found: boolean;
begin
  result := false;
  if (AExtremums = nil) or (FBands = nil) then
    exit;
  bands := bList(FBands);
  for i := 0 to bands.Count - 1 do
  begin
    found := false;
    for j := 0 to AExtremums.Count - 1 do
    begin
      extr := cExtremum(AExtremums.Items[j]);
      if extr.BandNum = i then
      begin
        found := true;
        break;
      end;
    end;
    if not found then
      exit;
  end;
  result := true;
end;
function TPeakFrm.IsNearBandBoundary(AExtremum: TObject): boolean;
var
  i: integer;
  b: tSpmBand;
  bands: bList;
  extr: cExtremum;
  d: double;
begin
  result := false;
  if (AExtremum = nil) or (FBands = nil) then
    exit;
  extr := cExtremum(AExtremum);
  bands := bList(FBands);
  for i := 0 to bands.Count - 1 do
  begin
    b := bands.getband(i);
    if b.m_f1 <> 0 then
    begin
      d := 100 * abs(extr.Freq - b.m_f1) / b.m_f1;
      if d <= cNearBandTolPercent then
      begin
        result := true;
        exit;
      end;
    end;
    if b.m_f2 <> 0 then
    begin
      d := 100 * abs(extr.Freq - b.m_f2) / b.m_f2;
      if d <= cNearBandTolPercent then
      begin
        result := true;
        exit;
      end;
    end;
  end;
end;
procedure TPeakFrm.DebugLogBtnClick(Sender: TObject);
var
  f: TFRFFrm;
  s: cSRSres;
begin
  f := TFRFFrm(FFRFFrm);
  if f = nil then
    exit;
  s := f.ActiveSignal;
  if s = nil then
    exit;
  FBands := f.m_bands;
  EvalFRFPeaks(f, s, true, true);
  FillGrid(s.m_BandExtremums);
end;
procedure TPeakFrm.ProfileSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  extr: cExtremum;
  s: string;
  flags: integer;
begin
  if ARow = 0 then
    exit;
  extr := cExtremum(ProfileSG.Objects[ACol, ARow]);
  if extr = nil then
    exit;
  if extr.BandNum >= 0 then
    ProfileSG.Canvas.Brush.Color := RGB(181, 220, 150)
  else
  begin
    if IsNearBandBoundary(extr) then
      ProfileSG.Canvas.Brush.Color := RGB(255, 250, 205)
    else
      ProfileSG.Canvas.Brush.Color := clWindow;
  end;
  ProfileSG.Canvas.Font.Color := clWindowText;
  ProfileSG.Canvas.FillRect(Rect);
  s := ProfileSG.Cells[ACol, ARow];
  flags := DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS;
  InflateRect(Rect, -2, 0);
  DrawText(ProfileSG.Canvas.Handle, PChar(s), length(s), Rect, flags);
end;
procedure TPeakFrm.RatioLimitEditChange(Sender: TObject);
var
  f: TFRFFrm;
  s: cSRSres;
begin
  if FUpdatingRatioLimit then
    exit;
  f := TFRFFrm(FFRFFrm);
  if f = nil then
    exit;
  f.m_peakRatioLimit := GetRatioLimit;
  s := f.ActiveSignal;
  if s = nil then
    exit;
  FillGrid(s.m_BandExtremums);
end;
procedure TPeakFrm.SetTrigStatus(const AText: string; AColor: TColor);
begin
  TrigStatusLabel.Caption := AText;
  TrigStatusLabel.Visible := AText <> '';
  TrigStatusLabel.Color := AColor;
  if AText <> '' then
    TrigStatusLabel.Font.Color := clMaroon
  else
    TrigStatusLabel.Font.Color := clWindowText;
end;
procedure TPeakFrm.ShowFRFPeaks(AFRFFrm: TObject);
var
  f: TFRFFrm;
  s: cSRSres;
begin
  FFRFFrm := AFRFFrm;
  f := TFRFFrm(AFRFFrm);
  if f = nil then
    exit;
  s := f.ActiveSignal;
  if s = nil then
    exit;
  FBands := f.m_bands;
  FUpdatingRatioLimit := true;
  try
    RatioLimitEdit.Text := FloatToStrF(f.m_peakRatioLimit, ffFixed, 5, 3);
  finally
    FUpdatingRatioLimit := false;
  end;
  EvalFRFPeaks(f, s, true);
  FillGrid(s.m_BandExtremums);
  show;
end;
end.