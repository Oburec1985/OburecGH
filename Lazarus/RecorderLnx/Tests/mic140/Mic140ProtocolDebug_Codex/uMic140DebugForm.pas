unit uMic140DebugForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Grids, StdCtrls, Dialogs,
  IniFiles, uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
  uRecorderMic140v2Device, uRecorderMic140v2WireTypes,
  uRecorderMic140v2Diag, uRecorderMic140v2Scan;

type
  TMic140DebugForm = class(TForm)
    btnStart3: TButton;
    edtHost: TEdit;
    edtPort: TEdit;
    lblHost: TLabel;
    lblPort: TLabel;
    lblTitle: TLabel;
    sgTags: TStringGrid;
    procedure btnStart3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgTagsPrepareCanvas(Sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
  private
    fDevice: TRecorderMic140v2Device;
    fReference: array[0..47] of Integer;
    fReferenceValid: array[0..47] of Boolean;
    fDelta: array[0..47] of Double;
    fDeltaValid: array[0..47] of Boolean;
    fTinReference: array[0..6] of Integer;
    fTinReferenceValid: array[0..6] of Boolean;
    fTinDelta: array[0..6] of Double;
    fTinDeltaValid: array[0..6] of Boolean;
    fTinSum: array[0..6] of Double;
    fTinCount: array[0..6] of Integer;
    fAinSum: array[0..47] of Double;
    fAinCount: array[0..47] of Integer;
    fStatisticsStartedAt: QWord;
    fFirstSessionNeedsSettle: Boolean;
    fRunning: Boolean;
    fStopRequested: Boolean;
    fAutoSeconds: Integer;
    fConfigured: Boolean;
    function FindAndConnect: Boolean;
    function IniFileName: string;
    procedure LoadConnectionSettings;
    procedure SaveConnectionSettings;
    procedure LoadReferences;
    procedure InitGrid;
    procedure ShowBlock(const ABlock: TRecorderAcquisitionBlock;
      ABlockNumber: Integer);
    procedure ShowTemperatures;
    function StatisticsReady: Boolean;
    procedure LogFinalStatistics;
    procedure AutoRun(AData: PtrInt);
    function CommandLineAutoSeconds: Integer;
    function CommandLineAutoRepeat: Boolean;
    function CommandLineAutoClose: Boolean;
  public
    destructor Destroy; override;
  end;

var
  Mic140DebugForm: TMic140DebugForm;

implementation

{$R *.lfm}

function TMic140DebugForm.IniFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    ChangeFileExt(ExtractFileName(ParamStr(0)), '.ini');
end;

procedure TMic140DebugForm.LoadConnectionSettings;
var lIni: TIniFile;
begin
  lIni := TIniFile.Create(IniFileName);
  try
    edtHost.Text := lIni.ReadString('Connection', 'Host', '192.168.14.48');
    edtPort.Text := lIni.ReadString('Connection', 'Port', '4000');
  finally
    lIni.Free;
  end;
end;

procedure TMic140DebugForm.SaveConnectionSettings;
var lIni: TIniFile;
begin
  if (edtHost = nil) or (edtPort = nil) then Exit;
  lIni := TIniFile.Create(IniFileName);
  try
    lIni.WriteString('Connection', 'Host', Trim(edtHost.Text));
    lIni.WriteString('Connection', 'Port', Trim(edtPort.Text));
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
end;

procedure TMic140DebugForm.LoadReferences;
var
  lLines, lParts: TStringList;
  lPath: string;
  i, lChannel: Integer;
begin
  FillChar(fReferenceValid, SizeOf(fReferenceValid), 0);
  FillChar(fTinReferenceValid, SizeOf(fTinReferenceValid), 0);
  lPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'data' + DirectorySeparator + 'mic140_adc_reference.txt';
  if not FileExists(lPath) then Exit;
  lLines := TStringList.Create;
  lParts := TStringList.Create;
  try
    lLines.LoadFromFile(lPath);
    lParts.Delimiter := ' ';
    lParts.StrictDelimiter := True;
    for i := 0 to lLines.Count - 1 do
    begin
      lParts.DelimitedText := Trim(lLines[i]);
      if lParts.Count < 3 then Continue;
      lChannel := StrToIntDef(lParts[1], 0);
      if UpperCase(lParts[0]) = 'AIN' then
      begin
        if (lChannel < 1) or (lChannel > 48) then Continue;
        fReference[lChannel - 1] := StrToIntDef(lParts[2], 0);
        fReferenceValid[lChannel - 1] := True;
      end
      else if UpperCase(lParts[0]) = 'TIN' then
      begin
        if (lChannel < 6) or (lChannel > 12) then Continue;
        fTinReference[lChannel - 6] := StrToIntDef(lParts[2], 0);
        fTinReferenceValid[lChannel - 6] := True;
      end;
    end;
  finally
    lParts.Free;
    lLines.Free;
  end;
end;

procedure TMic140DebugForm.InitGrid;
var i: Integer;
begin
  sgTags.ColCount := 6;
  sgTags.RowCount := 56;
  sgTags.FixedRows := 1;
  sgTags.ColWidths[0] := 175;
  sgTags.ColWidths[1] := 78;
  sgTags.ColWidths[2] := 88;
  sgTags.ColWidths[3] := 70;
  sgTags.ColWidths[4] := 88;
  sgTags.ColWidths[5] := 82;
  sgTags.Cells[0, 0] := 'Channel';
  sgTags.Cells[1, 0] := 'Last code';
  sgTags.Cells[2, 0] := 'Mean code';
  sgTags.Cells[3, 0] := 'Samples';
  sgTags.Cells[4, 0] := 'Reference';
  sgTags.Cells[5, 0] := 'Delta';
  for i := 0 to 47 do
  begin
    sgTags.Cells[0, i + 1] := Format('MIC140-{0329-%d}', [i + 1]);
    if fReferenceValid[i] then
      sgTags.Cells[4, i + 1] := IntToStr(fReference[i]);
  end;
  for i := 0 to 6 do
  begin
    sgTags.Cells[0, 49 + i] := Format('MIC140-{0329-t%d}', [i + 6]);
    if fTinReferenceValid[i] then
      sgTags.Cells[4, 49 + i] := IntToStr(fTinReference[i]);
  end;
end;

procedure TMic140DebugForm.ShowTemperatures;
var
  lAux: TMic140AuxTemperatureBlock;
  i, j, lCount, lRow: Integer;
  lMean, lLast: Double;
begin
  if fDevice = nil then
    Exit;
  lAux := fDevice.LastAuxTemperatureBlock;
  for i := 0 to Min(6, lAux.ChannelCount - 1) do
  begin
    lRow := 49 + i;
    lCount := 0;
    lMean := 0;
    lLast := 0;
    if i >= Length(lAux.Values) then
      Continue;
    for j := 0 to High(lAux.Values[i]) do
      if (i < Length(lAux.Valid)) and (j < Length(lAux.Valid[i])) and
        lAux.Valid[i][j] then
      begin
        lLast := lAux.Values[i][j];
        lMean := lMean + lLast;
        Inc(lCount);
      end;
    if lCount = 0 then
      Continue;
    if StatisticsReady then
    begin
      fTinSum[i] := fTinSum[i] + lLast;
      Inc(fTinCount[i]);
    end;
    sgTags.Cells[1, lRow] := FormatFloat('0', lLast);
    if fTinCount[i] > 0 then
      sgTags.Cells[2, lRow] := FormatFloat('0.0', fTinSum[i] / fTinCount[i])
    else
      sgTags.Cells[2, lRow] := 'settling';
    sgTags.Cells[3, lRow] := IntToStr(fTinCount[i]);
    if fTinReferenceValid[i] and (fTinCount[i] > 0) then
    begin
      fTinDelta[i] := fTinSum[i] / fTinCount[i] - fTinReference[i];
      fTinDeltaValid[i] := True;
      sgTags.Cells[5, lRow] := FormatFloat('0.0', fTinDelta[i]);
    end;
  end;
end;

function TMic140DebugForm.StatisticsReady: Boolean;
const
  CFirstSessionSettleMs = 5000;
begin
  Result := (not fFirstSessionNeedsSettle) or
    (GetTickCount64 - fStatisticsStartedAt >= CFirstSessionSettleMs);
end;

procedure TMic140DebugForm.LogFinalStatistics;
var
  i: Integer;
begin
  for i := 0 to 47 do
    if fAinCount[i] > 0 then
      Mic140v2Log(Format('[MIC140-CODEX] final AIn%2.2d mean=%.1f samples=%d ref=%d delta=%.1f',
        [i + 1, fAinSum[i] / fAinCount[i], fAinCount[i], fReference[i],
         fAinSum[i] / fAinCount[i] - fReference[i]]));
  for i := 0 to 6 do
    if fTinCount[i] > 0 then
      Mic140v2Log(Format('[MIC140-CODEX] final TIn%d mean=%.1f samples=%d ref=%d delta=%.1f',
        [i + 6, fTinSum[i] / fTinCount[i], fTinCount[i], fTinReference[i],
         fTinSum[i] / fTinCount[i] - fTinReference[i]]));
end;

function TMic140DebugForm.FindAndConnect: Boolean;
var lPort: Integer;
begin
  Result := False;
  lPort := StrToIntDef(Trim(edtPort.Text), 0);
  if (Trim(edtHost.Text) = '') or (lPort < 1) or (lPort > High(Word)) then
  begin
    ShowMessage('Enter a valid MIC-140 IP address and port.');
    Exit;
  end;
  if fDevice = nil then
  begin
    fDevice := TRecorderMic140v2Device.Create('MIC140-debug',
      Trim(edtHost.Text), Word(lPort), 48, 10.0, 200, mppMic14048v3, True);
    fConfigured := False;
  end;
  try
    fDevice.Connect;
    fDevice.InitializeDevice;
    { Config относится к изменению аппаратной конфигурации, а не к каждому
      Start. Повторная загрузка той же циклограммы без Disconnect на MIC-140-v3
      оставляет аппаратный коммутатор в промежуточном состоянии. }
    if not fConfigured then
    begin
      fDevice.ConfigureDevice;
      fConfigured := True;
    end;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Exit;
    end;
  end;
  Result := True;
  SaveConnectionSettings;
end;

procedure TMic140DebugForm.ShowBlock(const ABlock: TRecorderAcquisitionBlock;
  ABlockNumber: Integer);
var
  i, j, lCount: Integer;
  lMean, lLast: Double;
begin
  for i := 0 to Min(47, ABlock.ChannelCount - 1) do
  begin
    lCount := Length(ABlock.Values[i]);
    if lCount = 0 then Continue;
    lMean := 0;
    for j := 0 to lCount - 1 do lMean := lMean + ABlock.Values[i][j];
    lMean := lMean / lCount;
    lLast := ABlock.Values[i][lCount - 1];
    sgTags.Cells[1, i + 1] := FormatFloat('0', lLast);
    if StatisticsReady then
    begin
      fAinSum[i] := fAinSum[i] + lMean * lCount;
      Inc(fAinCount[i], lCount);
    end;
    if fAinCount[i] > 0 then
      sgTags.Cells[2, i + 1] := FormatFloat('0.0', fAinSum[i] / fAinCount[i])
    else
      sgTags.Cells[2, i + 1] := 'settling';
    sgTags.Cells[3, i + 1] := IntToStr(fAinCount[i]);
    if fReferenceValid[i] and (fAinCount[i] > 0) then
    begin
      fDelta[i] := fAinSum[i] / fAinCount[i] - fReference[i];
      fDeltaValid[i] := True;
      sgTags.Cells[5, i + 1] := FormatFloat('0.0', fDelta[i]);
    end;
  end;
  ShowTemperatures;
  lblTitle.Caption := Format(
    'MIC-140 stream: block %d, channels=%d, samples=%d, Fs=%.3f Hz',
    [ABlockNumber, ABlock.ChannelCount, ABlock.SampleCount, ABlock.SampleRateHz]);
  sgTags.Invalidate;
  Application.ProcessMessages;
end;

procedure TMic140DebugForm.btnStart3Click(Sender: TObject);
var
  lBlock: TRecorderAcquisitionBlock;
  lStartedAt, lUntil: QWord;
  lBlockCount: Integer;
begin
  if fRunning then
  begin
    fStopRequested := True;
    Exit;
  end;
  if not FindAndConnect then Exit;
  fRunning := True;
  fStopRequested := False;
  btnStart3.Caption := 'Stop';
  lBlockCount := 0;
  FillChar(fTinSum, SizeOf(fTinSum), 0);
  FillChar(fTinCount, SizeOf(fTinCount), 0);
  FillChar(fAinSum, SizeOf(fAinSum), 0);
  FillChar(fAinCount, SizeOf(fAinCount), 0);
  FillChar(fDeltaValid, SizeOf(fDeltaValid), 0);
  FillChar(fTinDeltaValid, SizeOf(fTinDeltaValid), 0);
  try
    fDevice.Start;
    lStartedAt := GetTickCount64;
    fStatisticsStartedAt := lStartedAt;
    if fAutoSeconds > 0 then
      lUntil := lStartedAt + QWord(fAutoSeconds) * 1000
    else
      lUntil := 0;
    while not fStopRequested and ((lUntil = 0) or (GetTickCount64 < lUntil)) do
    begin
      if fDevice.ReadBlock(500, lBlock) then
      begin
        Inc(lBlockCount);
        ShowBlock(lBlock, lBlockCount);
      end;
      Application.ProcessMessages;
    end;
    fDevice.Stop;
    LogFinalStatistics;
    fFirstSessionNeedsSettle := False;
    lblTitle.Caption := Format('MIC-140: received %d blocks in %.1f s',
      [lBlockCount, (GetTickCount64 - lStartedAt) / 1000.0]);
    if lBlockCount = 0 then ShowMessage('MIC-140: no data blocks received');
  except
    on E: Exception do
    begin
      if fDevice <> nil then fDevice.Stop;
      ShowMessage(E.Message);
    end;
  end;
  fRunning := False;
  fStopRequested := False;
  fAutoSeconds := 0;
  btnStart3.Caption := 'Start';
end;

procedure TMic140DebugForm.sgTagsPrepareCanvas(Sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
begin
  if (aRow >= 1) and (aRow <= 48) and fReferenceValid[aRow - 1] and
    fDeltaValid[aRow - 1] then
  begin
    if Abs(fDelta[aRow - 1]) <= 500.0 then
      sgTags.Canvas.Brush.Color := $00D8F5D8
    else
      sgTags.Canvas.Brush.Color := $00D8D8FF;
  end
  else if (aRow >= 49) and (aRow <= 55) and
    fTinReferenceValid[aRow - 49] and fTinDeltaValid[aRow - 49] then
  begin
    if Abs(fTinDelta[aRow - 49]) <= 500.0 then
      sgTags.Canvas.Brush.Color := $00D8F5D8
    else
      sgTags.Canvas.Brush.Color := $00D8D8FF;
  end
  else
    sgTags.Canvas.Brush.Color := clWindow;
end;

procedure TMic140DebugForm.FormCreate(Sender: TObject);
begin
  LoadConnectionSettings;
  LoadReferences;
  InitGrid;
  fRunning := False;
  fStopRequested := False;
  fConfigured := False;
  fFirstSessionNeedsSettle := True;
  fAutoSeconds := CommandLineAutoSeconds;
  { Автозапуск разрешён только явным CLI-параметром для тестовых прогонов. }
  if fAutoSeconds > 0 then
    Application.QueueAsyncCall(@AutoRun, 0);
end;

function TMic140DebugForm.CommandLineAutoSeconds: Integer;
const
  CPrefix = '--auto-seconds=';
var
  i: Integer;
  lArg: string;
begin
  Result := 0;
  for i := 1 to ParamCount do
  begin
    lArg := ParamStr(i);
    if Pos(CPrefix, LowerCase(lArg)) = 1 then
      Exit(Max(0, StrToIntDef(Copy(lArg, Length(CPrefix) + 1, MaxInt), 0)));
  end;
end;

function TMic140DebugForm.CommandLineAutoRepeat: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to ParamCount do
    if SameText(ParamStr(i), '--auto-repeat') then
      Exit(True);
end;

function TMic140DebugForm.CommandLineAutoClose: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to ParamCount do
    if SameText(ParamStr(i), '--auto-close') then
      Exit(True);
end;

procedure TMic140DebugForm.AutoRun(AData: PtrInt);
var
  lSeconds: Integer;
begin
  lSeconds := fAutoSeconds;
  btnStart3Click(btnStart3);
  if CommandLineAutoRepeat and (lSeconds > 0) then
  begin
    fAutoSeconds := lSeconds;
    btnStart3Click(btnStart3);
  end;
  { CLI-прогон должен штатно завершить форму после Stop/Disconnect,
    чтобы внешний сниффер получил полный жизненный цикл без ручных кликов. }
  if CommandLineAutoClose then
    Application.Terminate;
end;

destructor TMic140DebugForm.Destroy;
begin
  SaveConnectionSettings;
  if fDevice <> nil then
  begin
    fDevice.Stop;
    fDevice.Disconnect;
    fDevice.Free;
  end;
  inherited;
end;

end.
