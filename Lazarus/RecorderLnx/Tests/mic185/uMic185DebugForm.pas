unit uMic185DebugForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Grids, StdCtrls, ExtCtrls, Dialogs,
  Variants,
  uRecorderDeviceInterfaces, uRecorderDeviceManager, uRecorderAcquisitionTypes,
  uMic185Device, uMic185MebiusTypes, uMic185Constants, uMic185DebugLog, uMic185CodeVerify;

type
  TMic185DebugForm = class(TForm)
    btnConnect: TButton;
    btnDisconnect: TButton;
    btnProgram: TButton;
    btnStart: TButton;
    btnStop: TButton;
    edtHost: TEdit;
    edtPort: TEdit;
    lblHost: TLabel;
    lblInfo: TLabel;
    lblLog: TLabel;
    lblPort: TLabel;
    lblState: TLabel;
    lblPktStats: TLabel;
    lblVerify: TLabel;
    lblWorkTime: TLabel;
    memLog: TMemo;
    sgChannels: TStringGrid;
    tmrAcquire: TTimer;
    tmrAuto: TTimer;
    tmrLog: TTimer;
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnProgramClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmrAcquireTimer(Sender: TObject);
    procedure tmrAutoTimer(Sender: TObject);
    procedure tmrLogTimer(Sender: TObject);
    procedure sgChannelsPrepareCanvas(Sender: TObject; aColumn, aRow: Integer;
      aState: TGridDrawState);
  private
    fDevice: IRecorderDevice;
    fDev: TRecorderMic185Device;
    fBlockCount: Int64;
    fMismatchCount: Integer;
    fLastValues: array of Double;
    fChannelMatch: array of Boolean;
    fAutoStarted: Boolean;
    fAcquireStartTime: TDateTime;
    fAcquireBusy: Boolean;
    procedure EnsureDevice;
    procedure ReleaseDevice;
    procedure ApplyConnectionSettings;
    procedure ConfigureDevice;
    procedure UpdateUiState;
    procedure InitChannelGrid;
    procedure UpdateChannelGridFromBlock(const ABlock: TRecorderAcquisitionBlock);
    procedure UpdateChannelRefColumns(AChannelIndex: Integer; ACode: Double);
    procedure UpdatePktStatsLabel;
    procedure UpdateWorkTimeLabel;
    procedure UpdateVerifySummary;
    procedure RecountMismatches;
    procedure UpdateAuxChannelGrid;
    procedure UpdateChannelGridStatic;
    procedure SetStateLabel(const AText: string; AColor: TColor);
    function StateText: string;
    function HostText: string;
    function PortValue: Integer;
    procedure RunAutoTest;
    procedure RunStressTest;
    procedure RunConnectOnly;
    procedure RunVerifyCodes;
  public
    AutoRun: Boolean;
    ConnectOnly: Boolean;
    VerifyCodes: Boolean;
    StressRun: Boolean;
  end;

var
  Mic185DebugForm: TMic185DebugForm;

implementation

uses
  uMic185Registration;

{$R *.lfm}

procedure TMic185DebugForm.ReleaseDevice;
begin
  fDev := nil;
  SetLength(fLastValues, 0);
  SetLength(fChannelMatch, 0);
  fDevice := nil;
end;

procedure TMic185DebugForm.EnsureDevice;
var
  lObj: TObject;
begin
  if fDevice = nil then
  begin
    fDev := nil;
    fDevice := CreateRecorderMic185Device;
    if fDevice = nil then
      raise ERecorderDeviceError.Create('CreateRecorderMic185Device returned nil');
  end;

  lObj := fDevice.GetNativeObject;
  if (lObj = nil) or not (lObj is TRecorderMic185Device) then
  begin
    ReleaseDevice;
    raise ERecorderDeviceError.Create('Неверный тип устройства');
  end;
  fDev := TRecorderMic185Device(lObj);
end;

procedure TMic185DebugForm.ApplyConnectionSettings;
begin
  EnsureDevice;
  if fDevice = nil then
    raise ERecorderDeviceError.Create('Устройство не создано');
  fDevice.TrySetDeviceProperty(rdpHost, HostText);
  fDevice.TrySetDeviceProperty(rdpPort, PortValue);
  fDevice.TrySetDeviceProperty(rdpChannelCount, CMic185TotalLogicalChannelCount);
  fDevice.TrySetDeviceProperty(rdpPollFrequencyHz, CMic185DefaultMeasFrequencyHz);
end;

function TMic185DebugForm.HostText: string;
begin
  Result := '192.168.9.142';
  if (edtHost <> nil) and (Trim(edtHost.Text) <> '') then
    Result := Trim(edtHost.Text);
end;

function TMic185DebugForm.PortValue: Integer;
begin
  Result := 4000;
  if edtPort <> nil then
    Result := StrToIntDef(Trim(edtPort.Text), Result);
end;

procedure TMic185DebugForm.ConfigureDevice;
begin
  if fDev = nil then
    Exit;
  lblInfo.Caption := Format(
    'MIC183/185  s/n=%d  ver=%s  meas=%d  temp=%d  uts=%s  Fs=%.1f Hz',
    [fDev.DeviceSerial, Mic185FormatSoftVersion(fDev.SoftVersion),
     fDev.MeasChannelCount, fDev.TempChannelCount,
     BoolToStr(fDev.UtsEnabled, True), CMic185DefaultMeasFrequencyHz]);
end;

function TMic185DebugForm.StateText: string;
begin
  if fDev = nil then
    Exit('No device');
  case fDev.State of
    rdsDisconnected: Result := 'Disconnected';
    rdsConnected:    Result := 'Connected';
    rdsProgrammed:   Result := 'Programmed';
    rdsStarted:      Result := 'Started (acquiring)';
  else
    Result := 'Unknown';
  end;
end;

procedure TMic185DebugForm.SetStateLabel(const AText: string; AColor: TColor);
begin
  lblState.Caption := AText;
  lblState.Font.Color := AColor;
end;

procedure TMic185DebugForm.UpdateUiState;
var
  lSt: TRecorderDeviceState;
begin
  if fDev = nil then
    lSt := rdsDisconnected
  else
    lSt := fDev.State;

  case lSt of
    rdsDisconnected:
      begin
        SetStateLabel('Disconnected', clMaroon);
        btnConnect.Enabled := True;
        btnProgram.Enabled := False;
        btnStart.Enabled := False;
        btnStop.Enabled := False;
        btnDisconnect.Enabled := False;
        tmrAcquire.Enabled := False;
      end;
    rdsConnected:
      begin
        SetStateLabel('Connected', clGreen);
        btnConnect.Enabled := False;
        btnProgram.Enabled := False;
        btnStart.Enabled := True;
        btnStop.Enabled := False;
        btnDisconnect.Enabled := True;
        tmrAcquire.Enabled := False;
      end;
    rdsProgrammed:
      begin
        SetStateLabel('Programmed', clNavy);
        btnConnect.Enabled := False;
        btnProgram.Enabled := False;
        btnStart.Enabled := True;
        btnStop.Enabled := False;
        btnDisconnect.Enabled := True;
        tmrAcquire.Enabled := False;
      end;
    rdsStarted:
      begin
        SetStateLabel('Started', clPurple);
        btnConnect.Enabled := False;
        btnProgram.Enabled := False;
        btnStart.Enabled := False;
        btnStop.Enabled := True;
        btnDisconnect.Enabled := False;
        tmrAcquire.Enabled := True;
      end;
  end;
end;

procedure TMic185DebugForm.InitChannelGrid;
var
  I: Integer;
  lCh: TRecorderDeviceChannelArray;
begin
  sgChannels.BeginUpdate;
  try
    sgChannels.ColCount := 9;
    sgChannels.RowCount := 1;
    sgChannels.Cells[0, 0] := '#';
    sgChannels.Cells[1, 0] := 'Name';
    sgChannels.Cells[2, 0] := 'Unit';
    sgChannels.Cells[3, 0] := 'Fs';
    sgChannels.Cells[4, 0] := 'Code';
    sgChannels.Cells[5, 0] := 'Ref';
    sgChannels.Cells[6, 0] := 'd';  { delta, без Unicode в заголовке }
    sgChannels.Cells[7, 0] := 'Match';
    sgChannels.Cells[8, 0] := 'Updated';
    sgChannels.ColWidths[0] := 40;
    sgChannels.ColWidths[1] := 200;
    sgChannels.ColWidths[2] := 36;
    sgChannels.ColWidths[3] := 48;
    sgChannels.ColWidths[4] := 72;
    sgChannels.ColWidths[5] := 72;
    sgChannels.ColWidths[6] := 56;
    sgChannels.ColWidths[7] := 52;
    sgChannels.ColWidths[8] := 88;

    if fDev = nil then
      Exit;

    lCh := fDev.GetChannels;
    sgChannels.RowCount := Length(lCh) + 1;
    SetLength(fLastValues, Length(lCh));
    SetLength(fChannelMatch, Length(lCh));
    for I := 0 to High(lCh) do
    begin
      fChannelMatch[I] := False;
      sgChannels.Cells[0, I + 1] := IntToStr(I + 1);
      sgChannels.Cells[1, I + 1] := lCh[I].Name;
      sgChannels.Cells[2, I + 1] := lCh[I].UnitName;
      sgChannels.Cells[3, I + 1] := FormatFloat('0.###', lCh[I].PollFrequencyHz);
      sgChannels.Cells[4, I + 1] := '-';
      sgChannels.Cells[5, I + 1] := '-';
      sgChannels.Cells[6, I + 1] := '-';
      sgChannels.Cells[7, I + 1] := '-';
      sgChannels.Cells[8, I + 1] := '-';
      fLastValues[I] := 0;
    end;
  finally
    sgChannels.EndUpdate;
  end;
end;

procedure TMic185DebugForm.UpdateChannelGridStatic;
var
  I: Integer;
  lCh: TRecorderDeviceChannelArray;
begin
  if fDev = nil then
    Exit;
  lCh := fDev.GetChannels;
  for I := 0 to High(lCh) do
  begin
    if I + 1 >= sgChannels.RowCount then
      Break;
    if (I < Length(fLastValues)) and (fLastValues[I] <> 0) then
      sgChannels.Cells[4, I + 1] := FormatFloat('0', fLastValues[I])
    else if I >= fDev.MeasChannelCount then
      sgChannels.Cells[4, I + 1] := '(n/a)';
  end;
end;

procedure TMic185DebugForm.UpdateAuxChannelGrid;
var
  I: Integer;
  lBase: Integer;
  lTimeStr: string;
begin
  if fDev = nil then
    Exit;
  lTimeStr := FormatDateTime('hh:nn:ss.zzz', Now);
  lBase := fDev.MeasChannelCount;

  if fDev.HasTempData then
  begin
    for I := 0 to fDev.TempChannelCount - 1 do
    begin
      if lBase + I + 1 >= sgChannels.RowCount then
        Break;
      if lBase + I < Length(fLastValues) then
        fLastValues[lBase + I] := fDev.LastTempValue(I);
      sgChannels.Cells[4, lBase + I + 1] :=
        FormatFloat('0.00', fDev.LastTempValue(I));
      sgChannels.Cells[8, lBase + I + 1] := lTimeStr;
    end;
  end;

  if fDev.HasUtsData then
  begin
    I := lBase + fDev.TempChannelCount;
    if I + 1 < sgChannels.RowCount then
    begin
      if I < Length(fLastValues) then
        fLastValues[I] := fDev.LastUts;
      sgChannels.Cells[4, I + 1] := FormatFloat('0.######', fDev.LastUts);
      sgChannels.Cells[8, I + 1] := lTimeStr;
    end;
  end;
end;

procedure TMic185DebugForm.UpdatePktStatsLabel;
var
  lPkts: Int64;
begin
  lPkts := 0;
  if fDev <> nil then
    lPkts := fDev.RxDataPacketCount;
  lblPktStats.Caption := Format('Packets: %d  Blocks: %d', [lPkts, fBlockCount]);
  UpdateWorkTimeLabel;
end;

procedure TMic185DebugForm.UpdateWorkTimeLabel;
var
  lUptimeSec: Double;
  lPeriodSec: Double;
  lDataSec: Double;
  lDeltaSec: Double;
begin
  if fAcquireStartTime <= 0 then
  begin
    lblWorkTime.Caption := 'Uptime: —';
    lblWorkTime.Font.Color := clGray;
    Exit;
  end;

  lPeriodSec := tmrAcquire.Interval / 1000.0;
  lUptimeSec := (Now - fAcquireStartTime) * SecsPerDay;
  lDataSec := fBlockCount * lPeriodSec;
  lDeltaSec := Abs(lUptimeSec - lDataSec);

  lblWorkTime.Caption := Format(
    'Uptime: %.2f s   blocks×period: %d×%.3f s = %.2f s',
    [lUptimeSec, fBlockCount, lPeriodSec, lDataSec]);

  if (fBlockCount > 0) and (lDeltaSec > Max(0.5, lUptimeSec * 0.25)) then
    lblWorkTime.Font.Color := clMaroon
  else if fBlockCount > 0 then
    lblWorkTime.Font.Color := clGreen
  else
    lblWorkTime.Font.Color := clGray;
end;

procedure TMic185DebugForm.UpdateVerifySummary;
begin
  if fDev = nil then
  begin
    lblVerify.Caption := 'Recorder ref: —';
    lblVerify.Font.Color := clGray;
    Exit;
  end;
  if fBlockCount = 0 then
  begin
    lblVerify.Caption := 'Recorder ref: —';
    lblVerify.Font.Color := clGray;
    Exit;
  end;
  if fMismatchCount = 0 then
  begin
    lblVerify.Caption := Format('Recorder ref: OK (tol %d)', [Mic185CodeTolerance]);
    lblVerify.Font.Color := clGreen;
  end
  else
  begin
    lblVerify.Caption := Format('Recorder ref: %d mismatch', [fMismatchCount]);
    lblVerify.Font.Color := clMaroon;
  end;
end;

procedure TMic185DebugForm.RecountMismatches;
var
  I: Integer;
  lRef, lDelta: Integer;
begin
  fMismatchCount := 0;
  if fDev = nil then
    Exit;
  for I := 0 to fDev.MeasChannelCount - 1 do
  begin
    if not Mic185HasRecorderRefCode(I) then
      Continue;
    if (I < Length(fLastValues)) and
      not Mic185ChannelCodeMatch(I, fLastValues[I], lRef, lDelta) then
      Inc(fMismatchCount);
  end;
  UpdateVerifySummary;
end;

procedure TMic185DebugForm.UpdateChannelRefColumns(AChannelIndex: Integer;
  ACode: Double);
var
  lRef, lDelta: Integer;
  lRow: Integer;
  lMatch: Boolean;
begin
  if fDev = nil then
    Exit;
  if AChannelIndex >= fDev.MeasChannelCount then
    Exit;
  lRow := AChannelIndex + 1;
  if lRow >= sgChannels.RowCount then
    Exit;

  if Mic185HasRecorderRefCode(AChannelIndex) then
  begin
    lMatch := Mic185ChannelCodeMatch(AChannelIndex, ACode, lRef, lDelta);
    if AChannelIndex < Length(fChannelMatch) then
      fChannelMatch[AChannelIndex] := lMatch;
    sgChannels.Cells[5, lRow] := IntToStr(lRef);
    if lDelta = 0 then
      sgChannels.Cells[6, lRow] := '0'
    else
      sgChannels.Cells[6, lRow] := IntToStr(lDelta);
    if lMatch then
      sgChannels.Cells[7, lRow] := 'OK'
    else
      sgChannels.Cells[7, lRow] := 'DIFF';
  end
  else
  begin
    if AChannelIndex < Length(fChannelMatch) then
      fChannelMatch[AChannelIndex] := False;
    sgChannels.Cells[5, lRow] := '-';
    sgChannels.Cells[6, lRow] := '-';
    sgChannels.Cells[7, lRow] := '-';
  end;
end;

procedure TMic185DebugForm.UpdateChannelGridFromBlock(
  const ABlock: TRecorderAcquisitionBlock);
var
  I: Integer;
  lLastSample: Integer;
  lTimeStr: string;
begin
  if fDev = nil then
    Exit;
  if (ABlock.ChannelCount <= 0) or (ABlock.SampleCount <= 0) then
    Exit;

  lLastSample := ABlock.SampleCount - 1;
  lTimeStr := FormatDateTime('hh:nn:ss.zzz', Now);

  sgChannels.BeginUpdate;
  try
    for I := 0 to Min(ABlock.ChannelCount - 1, fDev.MeasChannelCount - 1) do
    begin
      if I >= Length(fLastValues) then
        Break;
      fLastValues[I] := ABlock.Values[I][lLastSample];
      if I + 1 < sgChannels.RowCount then
      begin
        sgChannels.Cells[4, I + 1] := FormatFloat('0', fLastValues[I]);
        UpdateChannelRefColumns(I, fLastValues[I]);
        sgChannels.Cells[8, I + 1] := lTimeStr;
      end;
    end;
    UpdateAuxChannelGrid;
  finally
    sgChannels.EndUpdate;
  end;

  if (fBlockCount <= 3) or ((fBlockCount mod 10) = 0) then
    RecountMismatches
  else
    UpdatePktStatsLabel;
end;

procedure TMic185DebugForm.sgChannelsPrepareCanvas(Sender: TObject;
  aColumn, aRow: Integer; aState: TGridDrawState);
var
  lChIdx: Integer;
  lGrid: TStringGrid;
begin
  if (aRow < 1) or (fDev = nil) then
    Exit;
  lChIdx := aRow - 1;
  if (aColumn < 4) or (aColumn > 7) then
    Exit;
  if (lChIdx < 0) or (lChIdx >= Length(fChannelMatch)) then
    Exit;
  if not fChannelMatch[lChIdx] then
    Exit;
  if not (gdSelected in aState) then
  begin
    lGrid := TStringGrid(Sender);
    lGrid.Canvas.Brush.Color := $E0FFE0;
  end;
end;

procedure TMic185DebugForm.FormCreate(Sender: TObject);
begin
  AutoRun := (ParamCount > 0) and SameText(ParamStr(1), '--auto');
  ConnectOnly := (ParamCount > 0) and SameText(ParamStr(1), '--connect');
  VerifyCodes := (ParamCount > 0) and SameText(ParamStr(1), '--verify');
  StressRun := (ParamCount > 0) and SameText(ParamStr(1), '--stress');
  fAutoStarted := False;
  fAcquireBusy := False;
  fBlockCount := 0;
  fMismatchCount := 0;
  fAcquireStartTime := 0;
  Mic185LogInit('');
  Mic185Log('MIC183/185 debug form started');
  Mic185Log('Log file: ' + Mic185LogFilePath);
  tmrLog.Enabled := True;
  tmrAuto.Enabled := False;
  btnProgram.Visible := False;
  InitChannelGrid;
  UpdateUiState;
  UpdatePktStatsLabel;
  UpdateWorkTimeLabel;
  UpdateVerifySummary;
end;

procedure TMic185DebugForm.tmrLogTimer(Sender: TObject);
begin
  if not Assigned(memLog) then
    Exit;
  Mic185LogPumpTo(memLog.Lines);
end;

procedure TMic185DebugForm.FormShow(Sender: TObject);
begin
  if (AutoRun or ConnectOnly or VerifyCodes or StressRun) and not fAutoStarted then
  begin
    fAutoStarted := True;
    tmrAuto.Enabled := True;
  end;
end;

procedure TMic185DebugForm.tmrAutoTimer(Sender: TObject);
begin
  tmrAuto.Enabled := False;
  if ConnectOnly then
    RunConnectOnly
  else if VerifyCodes then
    RunVerifyCodes
  else if StressRun then
    RunStressTest
  else
    RunAutoTest;
end;

procedure TMic185DebugForm.RunConnectOnly;
begin
  try
    btnConnectClick(nil);
    Mic185LogPumpTo(memLog.Lines);
    if (fDevice <> nil) and (fDevice.State >= rdsConnected) then
      Mic185Log('CONNECT-TEST: OK')
    else
      Mic185Log('CONNECT-TEST: FAILED (not connected)');
  except
    on E: Exception do
      Mic185Log('CONNECT-TEST error: ' + E.Message);
  end;
  Mic185LogPumpTo(memLog.Lines);
  Close;
end;

procedure TMic185DebugForm.RunVerifyCodes;
var
  lBlock: TRecorderAcquisitionBlock;
  lB: Integer;
  lReport: string;
  lOk: Boolean;
begin
  try
    EnsureDevice;
    ApplyConnectionSettings;
    fDevice.Connect;
    ConfigureDevice;
    InitChannelGrid;
    Mic185Log('VERIFY: Program (Recorder defaults)...');
    fDevice.ProgramDevice;
    fAcquireStartTime := Now;
    fDevice.Start;
    UpdateUiState;
    lOk := False;
    for lB := 1 to 15 do
    begin
      if fDevice.ReadBlock(2000, lBlock) then
      begin
        UpdateChannelGridFromBlock(lBlock);
        if lBlock.SampleCount > 0 then
        begin
          Inc(fBlockCount);
          UpdateChannelGridFromBlock(lBlock);
          lOk := Mic185VerifyBlockCodes(lBlock, lBlock.SampleCount - 1, lReport);
          Mic185Log('VERIFY: ' + lReport);
          UpdatePktStatsLabel;
          Break;
        end;
      end;
    end;
    if fDevice.State = rdsStarted then
      fDevice.Stop;
    if fDevice.State <> rdsDisconnected then
      fDevice.Disconnect;
    ReleaseDevice;
    if not lOk then
      Mic185Log('VERIFY: FAILED');
  except
    on E: Exception do
      Mic185Log('VERIFY error: ' + E.Message);
  end;
  Mic185LogPumpTo(memLog.Lines);
  Close;
end;

procedure TMic185DebugForm.RunAutoTest;
var
  lBlock: TRecorderAcquisitionBlock;
  lB: Integer;
  lGot: Integer;
begin
  try
    Mic185Log('AUTO: Connect ' + HostText + ':' + IntToStr(PortValue) + ' ...');
    EnsureDevice;
    Mic185Log('AUTO: device ensured');
    ApplyConnectionSettings;
    Mic185Log('AUTO: properties set');
    fDevice.Connect;
    ConfigureDevice;
    InitChannelGrid;
    Mic185Log('AUTO: Program...');
    fDevice.ProgramDevice;
    Mic185Log('AUTO: Start...');
    fBlockCount := 0;
    fAcquireStartTime := Now;
    fDevice.Start;
    UpdateUiState;
    lGot := 0;
    for lB := 1 to 10 do
    begin
      if fDevice.ReadBlock(2000, lBlock) then
      begin
        Inc(lGot);
        UpdateChannelGridFromBlock(lBlock);
        Mic185Log(Format('AUTO block %d: samples=%d ch=%d ch1=%d ch6=%d',
          [lGot, lBlock.SampleCount, lBlock.ChannelCount,
           Round(lBlock.Values[0][lBlock.SampleCount - 1]),
           Round(lBlock.Values[5][lBlock.SampleCount - 1])]));
      end;
    end;
    Mic185Log(Format('AUTO: got %d blocks', [lGot]));
    if fDevice.State = rdsStarted then
      fDevice.Stop;
    if fDevice.State <> rdsDisconnected then
      fDevice.Disconnect;
    ReleaseDevice;
    Mic185LogPumpTo(memLog.Lines);
  except
    on E: Exception do
      Mic185Log('AUTO error: ' + E.Message);
  end;
  Close;
end;

procedure TMic185DebugForm.RunStressTest;
var
  lBlock: TRecorderAcquisitionBlock;
  lEnd: TDateTime;
  lSecs: Double;
begin
  try
    Mic185Log('STRESS: Connect+Start 120s ...');
    btnConnectClick(nil);
    if (fDevice = nil) or (fDevice.State < rdsProgrammed) then
      raise Exception.Create('STRESS: connect/program failed');
    btnStartClick(nil);
    if (fDevice = nil) or (fDevice.State <> rdsStarted) then
      raise Exception.Create('STRESS: start failed');
    lEnd := Now + (120 / SecsPerDay);
    while Now < lEnd do
    begin
      Application.ProcessMessages;
      if (fDevice = nil) or (fDevice.State <> rdsStarted) then
        Break;
      if fDevice.ReadBlock(200, lBlock) then
      begin
        Inc(fBlockCount);
        UpdateChannelGridFromBlock(lBlock);
      end;
      if (fBlockCount > 0) and ((fBlockCount mod 50) = 0) then
        Mic185Log(Format('STRESS block %d pkts=%d uptime=%.1fs',
          [fBlockCount, IfThen(fDev <> nil, fDev.RxDataPacketCount, 0),
           (Now - fAcquireStartTime) * SecsPerDay]));
      Sleep(200);
    end;
    lSecs := (Now - fAcquireStartTime) * SecsPerDay;
    btnStopClick(nil);
    Mic185Log(Format('STRESS OK: blocks=%d pkts=%d uptime=%.1fs',
      [fBlockCount, IfThen(fDev <> nil, fDev.RxDataPacketCount, 0), lSecs]));
  except
    on E: Exception do
      Mic185Log('STRESS error: ' + E.Message);
  end;
  Close;
end;

procedure TMic185DebugForm.FormDestroy(Sender: TObject);
begin
  tmrAcquire.Enabled := False;
  tmrLog.Enabled := False;
  tmrAuto.Enabled := False;
  if fDevice <> nil then
  begin
    if fDevice.State = rdsStarted then
    begin
      try
        fDevice.Stop;
        Mic185Log('Stop on form destroy');
      except
      end;
    end;
    if fDevice.State <> rdsDisconnected then
    begin
      try
        fDevice.Disconnect;
        Mic185Log('Disconnect on form destroy');
      except
      end;
    end;
  end;
  ReleaseDevice;
end;

procedure TMic185DebugForm.btnConnectClick(Sender: TObject);
begin
  try
    EnsureDevice;
    ApplyConnectionSettings;
    Mic185Log(Format('Connect+Program %s:%s ...', [HostText, IntToStr(PortValue)]));
    fDevice.Connect;
    EnsureDevice;
    ConfigureDevice;
    InitChannelGrid;
    Mic185Log('ProgramDevice (Recorder defaults)...');
    fDevice.ProgramDevice;
    Mic185Log(Format('Connect+Program OK, state=%s', [StateText]));
  except
    on E: Exception do
    begin
      Mic185Log('Connect FAILED: ' + E.Message);
      if fDevice <> nil then
      begin
        try
          if fDevice.State = rdsStarted then
            fDevice.Stop;
          if fDevice.State <> rdsDisconnected then
            fDevice.Disconnect;
        except
        end;
      end;
      fDev := nil;
      ShowMessage(E.Message);
    end;
  end;
  UpdateUiState;
  UpdatePktStatsLabel;
  UpdateVerifySummary;
end;

procedure TMic185DebugForm.btnProgramClick(Sender: TObject);
begin
  try
    EnsureDevice;
    ApplyConnectionSettings;
    if fDevice.State = rdsDisconnected then
      fDevice.Connect;
    Mic185Log('ProgramDevice ...');
    fDevice.ProgramDevice;
    Mic185Log('ProgramDevice OK');
  except
    on E: Exception do
    begin
      Mic185Log('Program FAILED: ' + E.Message);
      ShowMessage(E.Message);
    end;
  end;
  UpdateUiState;
end;

procedure TMic185DebugForm.btnStartClick(Sender: TObject);
begin
  try
    EnsureDevice;
    if fDevice.State = rdsDisconnected then
    begin
      ApplyConnectionSettings;
      fDevice.Connect;
      fDevice.ProgramDevice;
    end
    else if fDevice.State = rdsConnected then
      fDevice.ProgramDevice;
    Mic185Log('Start acquisition ...');
    fBlockCount := 0;
    fMismatchCount := 0;
    fAcquireStartTime := Now;
    fDevice.Start;
    Mic185Log('Start OK');
  except
    on E: Exception do
    begin
      fAcquireStartTime := 0;
      Mic185Log('Start FAILED: ' + E.Message);
      ShowMessage(E.Message);
    end;
  end;
  UpdateUiState;
  UpdatePktStatsLabel;
end;

procedure TMic185DebugForm.btnStopClick(Sender: TObject);
begin
  try
    tmrAcquire.Enabled := False;
    if (fDevice <> nil) and (fDevice.State = rdsStarted) then
    begin
      fDevice.Stop;
      if fAcquireStartTime > 0 then
        Mic185Log(Format('Stop OK, blocks=%d packets=%d uptime=%.2fs',
          [fBlockCount, IfThen(fDev <> nil, fDev.RxDataPacketCount, 0),
           (Now - fAcquireStartTime) * SecsPerDay]))
      else
        Mic185Log(Format('Stop OK, blocks=%d packets=%d',
          [fBlockCount, IfThen(fDev <> nil, fDev.RxDataPacketCount, 0)]));
    end;
  except
    on E: Exception do
      Mic185Log('Stop error: ' + E.Message);
  end;
  UpdateUiState;
  UpdatePktStatsLabel;
end;

procedure TMic185DebugForm.btnDisconnectClick(Sender: TObject);
begin
  try
    tmrAcquire.Enabled := False;
    if fDevice <> nil then
    begin
      if fDevice.State = rdsStarted then
        fDevice.Stop;
      fDevice.Disconnect;
    end;
    Mic185Log('Disconnected');
    fAcquireStartTime := 0;
  except
    on E: Exception do
      Mic185Log('Disconnect error: ' + E.Message);
  end;
  UpdateUiState;
  UpdatePktStatsLabel;
end;

procedure TMic185DebugForm.tmrAcquireTimer(Sender: TObject);
var
  lBlock: TRecorderAcquisitionBlock;
begin
  if fAcquireBusy then
    Exit;
  if (fDevice = nil) or (fDevice.State <> rdsStarted) then
  begin
    tmrAcquire.Enabled := False;
    Exit;
  end;

  fAcquireBusy := True;
  try
    try
      if fDevice.ReadBlock(200, lBlock) then
      begin
        Inc(fBlockCount);
        UpdateChannelGridFromBlock(lBlock);
        if (fBlockCount <= 3) or ((fBlockCount mod 25) = 0) then
          Mic185Log(Format('Block %d: samples=%d ch=%d pkts=%d mismatch=%d',
            [fBlockCount, lBlock.SampleCount, lBlock.ChannelCount,
             IfThen(fDev <> nil, fDev.RxDataPacketCount, 0), fMismatchCount]));
      end;
      UpdatePktStatsLabel;
    except
      on E: Exception do
      begin
        Mic185Log('ReadBlock error: ' + E.Message);
        tmrAcquire.Enabled := False;
        try
          if (fDevice <> nil) and (fDevice.State = rdsStarted) then
            fDevice.Stop;
        except
        end;
        UpdateUiState;
      end;
    end;
  finally
    fAcquireBusy := False;
  end;
end;

end.
