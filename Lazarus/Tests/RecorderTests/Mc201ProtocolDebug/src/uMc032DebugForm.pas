unit uMc032DebugForm;

{
  LCL-форма без .lfm для отладки протокола контроллера MC032.

  Форма использует TMc032Device и получает данные Play через callback. Callback
  складывает сырые слова потока в простой буфер осциллограммы.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids, Spin, uMc032Device, uMc201ProtocolTypes;

type
  TMc032DebugForm = class(TForm)
  private
    fBtnConfig: TButton;
    fBtnConnect: TButton;
    fBtnDisconnect: TButton;
    fBtnModules: TButton;
    fBtnPlay: TButton;
    fBtnReset: TButton;
    fBtnSearch: TButton;
    fBtnStop: TButton;
    fBtnTest: TButton;
    fBusyStartedTick: QWord;
    fBusyTimer: TTimer;
    fDevice: TMc032Device;
    fEdHost: TEdit;
    fEdMaxSlots: TEdit;
    fEdPort: TEdit;
    fEdRate: TEdit;
    fEdTimeout: TEdit;
    fGrid: TStringGrid;
    fLblConfig: TLabel;
    fLblRx: TLabel;
    fLblState: TLabel;
    fLog: TMemo;
    fLogPath: string;
    fLastLogText: string;
    fPaint: TPaintBox;
    fBusy: Boolean;
    fNextRxUpdateTick: QWord;
    fRxBlockCount: Int64;
    fRxWindowHasData: Boolean;
    fLastRawChannel: Word;
    fLastRawSlot: Word;
    fSamples: array of Double;
    fSampleWriteIndex: Integer;
    fSpinChannel: TSpinEdit;
    fSpinSlot: TSpinEdit;
    procedure AppendSamples(const AWords: TMc201WordArray);
    function BuildConfig: TMc032Config;
    procedure BuildUi;
    procedure ButtonConfig(Sender: TObject);
    procedure ButtonConnect(Sender: TObject);
    procedure ButtonDisconnect(Sender: TObject);
    procedure ButtonModules(Sender: TObject);
    procedure ButtonPlay(Sender: TObject);
    procedure ButtonReset(Sender: TObject);
    procedure ButtonSearch(Sender: TObject);
    procedure ButtonStop(Sender: TObject);
    procedure ButtonTest(Sender: TObject);
    procedure BusyTimerTick(Sender: TObject);
    procedure CloseQueryHandler(Sender: TObject; var CanClose: Boolean);
    procedure ConfigFinished(ASuccess: Boolean; const AError: string);
    procedure DeviceData(Sender: TObject; const APacket: TMc032DataPacket);
    procedure DeviceProgress(Sender: TObject; const AText: string);
    procedure LogLine(const AText: string);
    procedure PaintOscilloscope(Sender: TObject);
    procedure ResetOscilloscope;
    procedure ResetRxCounters;
    procedure RunConnectAction;
    procedure SelectionChanged(Sender: TObject);
    procedure SetDeviceOptions;
    procedure UpdateConfigView;
    procedure UpdateRxView(ALastBlockWords: Integer);
    procedure UpdateState;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Mc032DebugForm: TMc032DebugForm;

procedure Mc032EnableConnectOnCreateTest;
function Mc032ConnectOnCreateTestPassed: Boolean;
function Mc032ConnectOnCreateTestMessage: string;

implementation

var
  gConnectOnCreateTest: Boolean = False;
  gConnectOnCreateTestPassed: Boolean = False;
  gConnectOnCreateTestMessage: string = '';

procedure Mc032EnableConnectOnCreateTest;
begin
  gConnectOnCreateTest := True;
  gConnectOnCreateTestPassed := False;
  gConnectOnCreateTestMessage := '';
end;

function Mc032ConnectOnCreateTestPassed: Boolean;
begin
  Result := gConnectOnCreateTestPassed;
end;

function Mc032ConnectOnCreateTestMessage: string;
begin
  Result := gConnectOnCreateTestMessage;
end;

function WordToSigned(AValue: Word): Double;
begin
  if AValue > $7FFF then
    Result := Integer(AValue) - $10000
  else
    Result := AValue;
end;

constructor TMc032DebugForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := 'MC032 protocol debug';
  Width := 1120;
  Height := 760;
  Position := poScreenCenter;
  OnCloseQuery := @CloseQueryHandler;
  fDevice := TMc032Device.Create;
  fDevice.OnProgress := @DeviceProgress;
  fLogPath := ChangeFileExt(ParamStr(0), '.gui.log');
  SetLength(fSamples, 2048);
  BuildUi;
  fBusyTimer := TTimer.Create(Self);
  fBusyTimer.Enabled := False;
  fBusyTimer.Interval := 2000;
  fBusyTimer.OnTimer := @BusyTimerTick;
  LogLine('GUI started');
  UpdateState;
  if gConnectOnCreateTest then
  begin
    RunConnectAction;
    gConnectOnCreateTestMessage := fLastLogText;
    gConnectOnCreateTestPassed := Pos('Connect:', fLastLogText) = 1;
  end;
end;

destructor TMc032DebugForm.Destroy;
begin
  FreeAndNil(fDevice);
  inherited Destroy;
end;

procedure TMc032DebugForm.BuildUi;
var
  lTop: Integer;
  lLeft: Integer;

  function AddLabel(const AText: string; AX, AY, AW: Integer): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := Self;
    Result.Caption := AText;
    Result.SetBounds(AX, AY + 4, AW, 22);
  end;

  function AddEdit(const AText: string; AX, AY, AW: Integer): TEdit;
  begin
    Result := TEdit.Create(Self);
    Result.Parent := Self;
    Result.Text := AText;
    Result.SetBounds(AX, AY, AW, 24);
  end;

  function AddSpin(AValue, AMin, AMax, AX, AY, AW: Integer): TSpinEdit;
  begin
    Result := TSpinEdit.Create(Self);
    Result.Parent := Self;
    Result.MinValue := AMin;
    Result.MaxValue := AMax;
    Result.Value := AValue;
    Result.OnChange := @SelectionChanged;
    Result.SetBounds(AX, AY, AW, 24);
  end;

  function AddButton(const AText: string; AX, AY, AW: Integer;
    AClick: TNotifyEvent): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent := Self;
    Result.Caption := AText;
    Result.OnClick := AClick;
    Result.SetBounds(AX, AY, AW, 28);
  end;

begin
  lTop := 12;
  AddLabel('IP', 12, lTop, 24);
  fEdHost := AddEdit(CMc201DefaultHost, 38, lTop, 126);
  AddLabel('Порт', 174, lTop, 36);
  fEdPort := AddEdit(IntToStr(CMc201DefaultPort), 212, lTop, 58);
  AddLabel('Таймаут, мс', 284, lTop, 80);
  fEdTimeout := AddEdit(IntToStr(CMc201DefaultTimeoutMs), 366, lTop, 62);
  AddLabel('Слоты', 442, lTop, 48);
  fEdMaxSlots := AddEdit(IntToStr(CMc201DefaultMaxSlots), 492, lTop, 44);
  AddLabel('Гц', 552, lTop, 22);
  fEdRate := AddEdit(IntToStr(CMc201DefaultSampleRateHz), 576, lTop, 58);
  AddLabel('Slot', 646, lTop, 28);
  fSpinSlot := AddSpin(1, 1, 4, 678, lTop, 48);
  AddLabel('Ch', 734, lTop, 20);
  fSpinChannel := AddSpin(1, 1, 4, 758, lTop, 48);
  fLblState := AddLabel('', 826, lTop, 220);
  fLblConfig := AddLabel('', 12, 82, 760);
  fLblRx := AddLabel('', 790, 82, 300);

  lTop := 46;
  lLeft := 12;
  fBtnSearch := AddButton('Поиск', lLeft, lTop, 86, @ButtonSearch);
  Inc(lLeft, 92);
  fBtnTest := AddButton('Тест', lLeft, lTop, 86, @ButtonTest);
  Inc(lLeft, 92);
  fBtnConnect := AddButton('Connect', lLeft, lTop, 86, @ButtonConnect);
  Inc(lLeft, 92);
  fBtnDisconnect := AddButton('Disconnect', lLeft, lTop, 96, @ButtonDisconnect);
  Inc(lLeft, 104);
  fBtnModules := AddButton('Модули', lLeft, lTop, 86, @ButtonModules);
  Inc(lLeft, 92);
  fBtnConfig := AddButton('Config', lLeft, lTop, 86, @ButtonConfig);
  Inc(lLeft, 92);
  fBtnPlay := AddButton('Play', lLeft, lTop, 76, @ButtonPlay);
  Inc(lLeft, 82);
  fBtnStop := AddButton('Stop', lLeft, lTop, 76, @ButtonStop);
  Inc(lLeft, 82);
  fBtnReset := AddButton('Reset', lLeft, lTop, 76, @ButtonReset);

  fPaint := TPaintBox.Create(Self);
  fPaint.Parent := Self;
  fPaint.Anchors := [akLeft, akTop, akRight];
  fPaint.SetBounds(12, 108, ClientWidth - 24, 240);
  fPaint.OnPaint := @PaintOscilloscope;

  fGrid := TStringGrid.Create(Self);
  fGrid.Parent := Self;
  fGrid.Anchors := [akLeft, akTop, akRight];
  fGrid.SetBounds(12, 360, ClientWidth - 24, 150);
  fGrid.ColCount := 5;
  fGrid.RowCount := 2;
  fGrid.FixedCols := 0;
  fGrid.Cells[0, 0] := 'Слот';
  fGrid.Cells[1, 0] := 'Тип';
  fGrid.Cells[2, 0] := 'Версия';
  fGrid.Cells[3, 0] := 'Серийный';
  fGrid.Cells[4, 0] := 'MC201';

  fLog := TMemo.Create(Self);
  fLog.Parent := Self;
  fLog.Anchors := [akLeft, akTop, akRight, akBottom];
  fLog.ScrollBars := ssVertical;
  fLog.SetBounds(12, 522, ClientWidth - 24, ClientHeight - 534);
  UpdateConfigView;
  UpdateRxView(0);
end;

procedure TMc032DebugForm.SetDeviceOptions;
var
  lInt: Integer;
begin
  fDevice.Host := Trim(fEdHost.Text);
  if TryStrToInt(fEdPort.Text, lInt) and (lInt > 0) and (lInt <= High(Word)) then
    fDevice.Port := Word(lInt);
  if TryStrToInt(fEdTimeout.Text, lInt) and (lInt > 0) then
    fDevice.TimeoutMs := Cardinal(lInt);
  UpdateConfigView;
end;

function TMc032DebugForm.BuildConfig: TMc032Config;
var
  lInt: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  if TryStrToInt(fEdRate.Text, lInt) and (lInt > 0) and (lInt <= High(Word)) then
    Result.SampleRateHz := Word(lInt)
  else
    Result.SampleRateHz := 1000;
  if TryStrToInt(fEdMaxSlots.Text, lInt) and (lInt > 0) and (lInt <= High(Word)) then
    Result.MaxSlots := Word(lInt)
  else
    Result.MaxSlots := CMc201DefaultMaxSlots;
  if TryStrToInt(fEdTimeout.Text, lInt) and (lInt > 0) and (lInt <= High(Word)) then
    Result.ReadTimeoutMs := Word(lInt)
  else
    Result.ReadTimeoutMs := CMc201DefaultTimeoutMs;
end;

procedure TMc032DebugForm.UpdateConfigView;
var
  lConfig: TMc032Config;
begin
  lConfig := BuildConfig;
  fLblConfig.Caption := Format(
    'Config: host=%s:%d; Fs=%d Hz; slots=%d; timeout=%d ms; module range/input/filter/ICP not ported',
    [fDevice.Host, fDevice.Port, lConfig.SampleRateHz, lConfig.MaxSlots,
     lConfig.ReadTimeoutMs]);
end;

procedure TMc032DebugForm.UpdateRxView(ALastBlockWords: Integer);
begin
  fLblRx.Caption := Format(
    'RX update blocks=%d; last raw packet=%d words; raw slot=%d ch=0x%s',
    [fRxBlockCount, ALastBlockWords, fLastRawSlot,
     IntToHex(fLastRawChannel, 4)]);
end;

procedure TMc032DebugForm.UpdateState;
begin
  UpdateConfigView;
  fLblState.Caption := 'Состояние: ' + Mc032StateToString(fDevice.State);
  fBtnConnect.Enabled := (not fBusy) and (fDevice.State = mcsDisconnected);
  fBtnDisconnect.Enabled := (not fBusy) and (fDevice.State <> mcsDisconnected);
  fBtnConfig.Enabled := (not fBusy) and (fDevice.State = mcsConnected);
  fBtnModules.Enabled := (not fBusy) and (fDevice.State = mcsConnected);
  fBtnPlay.Enabled := (not fBusy) and (fDevice.State <> mcsPlay);
  fBtnStop.Enabled := (not fBusy) and (fDevice.State = mcsPlay);
  fBtnReset.Enabled := (not fBusy) and (fDevice.State = mcsConnected);
end;

procedure TMc032DebugForm.LogLine(const AText: string);
var
  lFile: TextFile;
  lLine: string;
begin
  fLastLogText := AText;
  lLine := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz ', Now) + AText;
  fLog.Lines.Add(lLine);
  if fLogPath <> '' then
  begin
    AssignFile(lFile, fLogPath);
    if FileExists(fLogPath) then
      Append(lFile)
    else
      Rewrite(lFile);
    try
      WriteLn(lFile, lLine);
    finally
      CloseFile(lFile);
    end;
  end;
end;

procedure TMc032DebugForm.ButtonSearch(Sender: TObject);
var
  lError: string;
  lHost: string;
begin
  SetDeviceOptions;
  LogLine(Format('Search request host=%s port=%d timeout=%d',
    [fDevice.Host, fDevice.Port, fDevice.TimeoutMs]));
  if fDevice.Search(lHost, lError) then
    LogLine('Поиск: найден ' + lHost)
  else
    LogLine('Поиск: не найден, ' + lError);
  UpdateState;
end;

procedure TMc032DebugForm.ButtonTest(Sender: TObject);
var
  lError: string;
begin
  SetDeviceOptions;
  LogLine(Format('Test request host=%s port=%d timeout=%d',
    [fDevice.Host, fDevice.Port, fDevice.TimeoutMs]));
  if fDevice.TestConnection(lError) then
    LogLine('Тест соединения: OK')
  else
    LogLine('Тест соединения: ' + lError);
  UpdateState;
end;

procedure TMc032DebugForm.ButtonConnect(Sender: TObject);
begin
  RunConnectAction;
end;

procedure TMc032DebugForm.RunConnectAction;
var
  lError: string;
begin
  SetDeviceOptions;
  LogLine(Format('Connect request host=%s port=%d timeout=%d',
    [fDevice.Host, fDevice.Port, fDevice.TimeoutMs]));
  if fDevice.TryConnect(lError) then
    LogLine('Connect: ' + Mc201FormatBios(fDevice.Bios))
  else
    LogLine('Connect: ' + lError);
  UpdateState;
end;

procedure TMc032DebugForm.ButtonDisconnect(Sender: TObject);
begin
  fDevice.Disconnect;
  LogLine('Disconnect');
  UpdateState;
end;

procedure TMc032DebugForm.ButtonModules(Sender: TObject);
var
  I: Integer;
  lError: string;
  lModules: TMc201SlotInfoArray;
  lMaxSlots: Integer;
begin
  lMaxSlots := CMc201DefaultMaxSlots;
  TryStrToInt(fEdMaxSlots.Text, lMaxSlots);
  LogLine(Format('Modules request host=%s port=%d slots=%d',
    [fDevice.Host, fDevice.Port, lMaxSlots]));
  if not fDevice.SearchModules(Word(lMaxSlots), lModules, lError) then
  begin
    LogLine('Поиск модулей: ' + lError);
    UpdateState;
    Exit;
  end;
  fGrid.RowCount := Max(2, Length(lModules) + 1);
  for I := 1 to fGrid.RowCount - 1 do
    fGrid.Rows[I].Clear;
  for I := 0 to High(lModules) do
  begin
    fGrid.Cells[0, I + 1] := IntToStr(lModules[I].Slot);
    fGrid.Cells[1, I + 1] := IntToStr(lModules[I].TypeId);
    fGrid.Cells[2, I + 1] := IntToStr(lModules[I].VersionCode);
    fGrid.Cells[3, I + 1] := IntToStr(lModules[I].Serial);
    fGrid.Cells[4, I + 1] := BoolToStr(lModules[I].IsMc201, True);
    LogLine(Format('MODULE slot=%d type=%d version=%d serial=%d lo=%d hi=%d mc201=%s',
      [lModules[I].Slot, lModules[I].TypeId, lModules[I].VersionCode,
       lModules[I].Serial, lModules[I].SerialLo, lModules[I].SerialHi,
       BoolToStr(lModules[I].IsMc201, True)]));
  end;
  LogLine(Format('Поиск модулей: найдено %d', [Length(lModules)]));
  UpdateState;
end;

procedure TMc032DebugForm.ButtonConfig(Sender: TObject);
var
  lError: string;
  lSuccess: Boolean;
begin
  if fBusy then
    Exit;
  fBusy := True;
  fBusyStartedTick := GetTickCount64;
  fBusyTimer.Enabled := True;
  LogLine('Config: started, loading MC-201 BIOS and programming scan...');
  UpdateState;
  Application.ProcessMessages;
  lSuccess := fDevice.Config(BuildConfig, lError);
  ConfigFinished(lSuccess, lError);
end;

procedure TMc032DebugForm.ConfigFinished(ASuccess: Boolean; const AError: string);
var
  I: Integer;
begin
  fBusy := False;
  fBusyTimer.Enabled := False;
  if ASuccess then
  begin
    UpdateConfigView;
    LogLine('Config: ' + fLblConfig.Caption + '; OK');
    for I := 0 to High(fDevice.ProgramInfo) do
      LogLine('PROGRAM ' + Mc201FormatProgramInfo(fDevice.ProgramInfo[I]));
  end
  else
    LogLine('Config: ' + AError);
  UpdateState;
end;

procedure TMc032DebugForm.BusyTimerTick(Sender: TObject);
begin
  if not fBusy then
    Exit;
  fLblState.Caption := Format('State: Config running, %d s',
    [(GetTickCount64 - fBusyStartedTick) div 1000]);
end;

procedure TMc032DebugForm.DeviceProgress(Sender: TObject; const AText: string);
begin
  if not fBusy then
    Exit;
  fLblState.Caption := Format('State: Config %s, %d s',
    [AText, (GetTickCount64 - fBusyStartedTick) div 1000]);
  LogLine('Config step: ' + AText);
  Application.ProcessMessages;
end;

procedure TMc032DebugForm.CloseQueryHandler(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not fBusy;
  if not CanClose then
    LogLine('Close ignored: Config is still running');
end;

procedure TMc032DebugForm.ButtonPlay(Sender: TObject);
var
  lError: string;
  lSuccess: Boolean;
begin
  if fBusy then
    Exit;
  SetDeviceOptions;
  if fDevice.State = mcsDisconnected then
  begin
    LogLine(Format('Play auto-connect host=%s port=%d timeout=%d',
      [fDevice.Host, fDevice.Port, fDevice.TimeoutMs]));
    if fDevice.TryConnect(lError) then
      LogLine('Play auto-connect: ' + Mc201FormatBios(fDevice.Bios));
    if fDevice.State = mcsDisconnected then
    begin
      LogLine('Play auto-connect: ' + lError);
      UpdateState;
      Exit;
    end;
  end;
  if Length(fDevice.ProgramInfo) = 0 then
  begin
    fBusy := True;
    fBusyStartedTick := GetTickCount64;
    fBusyTimer.Enabled := True;
    LogLine('Play auto-config: started');
    UpdateState;
    Application.ProcessMessages;
    lSuccess := fDevice.Config(BuildConfig, lError);
    ConfigFinished(lSuccess, lError);
    if not lSuccess then
      Exit;
  end;
  ResetRxCounters;
  ResetOscilloscope;
  UpdateRxView(0);
  if fDevice.Play(@DeviceData, lError) then
    LogLine('Play: STARTSCANMAIN OK')
  else
  begin
    LogLine('Play: ' + lError);
    fDevice.ForceDisconnect(True);
    LogLine('Play: TCP session closed after error');
  end;
  UpdateState;
end;

procedure TMc032DebugForm.ButtonStop(Sender: TObject);
var
  lError: string;
begin
  if fDevice.Stop(lError) then
    LogLine('Stop: STOPSCANMAIN OK')
  else
    LogLine('Stop: ' + lError);
  fDevice.ForceDisconnect(True);
  LogLine('Stop: TCP session closed; next Play will reconfigure');
  UpdateState;
end;

procedure TMc032DebugForm.ButtonReset(Sender: TObject);
var
  lError: string;
begin
  if fDevice.State = mcsPlay then
  begin
    fDevice.ForceDisconnect(False);
    LogLine('Reset: active stream session was closed before reset');
  end;
  if fDevice.Reset(lError) then
    LogLine('Reset: CMD_RESET OK')
  else
    LogLine('Reset: ' + lError);
  fDevice.ForceDisconnect(True);
  LogLine('Reset: TCP session closed; scan program cleared');
  UpdateState;
end;

procedure TMc032DebugForm.DeviceData(Sender: TObject;
  const APacket: TMc032DataPacket);
var
  lTick: QWord;
begin
  lTick := GetTickCount64;
  while (fNextRxUpdateTick <> 0) and (lTick >= fNextRxUpdateTick) do
  begin
    if fRxWindowHasData then
      Inc(fRxBlockCount);
    fRxWindowHasData := False;
    Inc(fNextRxUpdateTick, CMc201DefaultUpdateMs);
  end;
  fRxWindowHasData := True;
  if Length(APacket.Words) >= CMc201BiosMessageHeaderWords then
  begin
    fLastRawSlot := APacket.Words[3];
    fLastRawChannel := APacket.Words[4];
  end;
  UpdateRxView(Max(0, Length(APacket.Words) - CMc201BiosMessageHeaderWords));
  AppendSamples(APacket.Words);
  fPaint.Invalidate;
end;

procedure TMc032DebugForm.AppendSamples(const AWords: TMc201WordArray);
var
  I: Integer;
  lHeaderChan: Word;
  lHeaderSlot: Word;
  lProgramInfo: TMc201ModuleProgramInfoArray;
  lTargetFlag: Word;
  lTargetSlot: Word;
begin
  if (Length(fSamples) = 0) or (Length(AWords) <= CMc201BiosMessageHeaderWords) then
    Exit;

  lHeaderSlot := AWords[3];
  lHeaderChan := AWords[4];
  lTargetSlot := fSpinSlot.Value - 1;
  lTargetFlag := 0;
  lProgramInfo := fDevice.ProgramInfo;
  for I := 0 to High(lProgramInfo) do
    if lProgramInfo[I].Slot = lTargetSlot then
    begin
      lTargetFlag := lProgramInfo[I].FinalFlags[fSpinChannel.Value - 1];
      Break;
    end;
  if (lHeaderSlot <> lTargetSlot) or (lTargetFlag = 0) or
    (lHeaderChan <> lTargetFlag) then
    Exit;

  for I := CMc201BiosMessageHeaderWords to High(AWords) do
  begin
    fSamples[fSampleWriteIndex] := WordToSigned(AWords[I]);
    Inc(fSampleWriteIndex);
    if fSampleWriteIndex >= Length(fSamples) then
      fSampleWriteIndex := 0;
  end;
end;

procedure TMc032DebugForm.ResetOscilloscope;
var
  I: Integer;
begin
  fSampleWriteIndex := 0;
  for I := 0 to High(fSamples) do
    fSamples[I] := 0;
  fPaint.Invalidate;
end;

procedure TMc032DebugForm.ResetRxCounters;
begin
  fRxBlockCount := 0;
  fRxWindowHasData := False;
  fLastRawSlot := 0;
  fLastRawChannel := 0;
  fNextRxUpdateTick := GetTickCount64 + CMc201DefaultUpdateMs;
end;

procedure TMc032DebugForm.SelectionChanged(Sender: TObject);
begin
  ResetOscilloscope;
  UpdateRxView(0);
end;

procedure TMc032DebugForm.PaintOscilloscope(Sender: TObject);
var
  I: Integer;
  lBottom: Integer;
  lHeight: Integer;
  lIndex: Integer;
  lMaxAbs: Double;
  lMidValue: Double;
  lMinValue: Double;
  lPlotLeft: Integer;
  lPlotRight: Integer;
  lPrevX: Integer;
  lPrevY: Integer;
  lScale: Double;
  lSpan: Double;
  lTop: Integer;
  lValue: Double;
  lX: Integer;
  lY: Integer;

  function ValueToY(AValue: Double): Integer;
  begin
    Result := lBottom - Round((AValue - lMinValue) * lScale);
  end;
begin
  fPaint.Canvas.Brush.Color := clBlack;
  fPaint.Canvas.FillRect(0, 0, fPaint.Width, fPaint.Height);
  lPlotLeft := 64;
  lPlotRight := Max(lPlotLeft + 16, fPaint.Width - 6);
  lTop := 18;
  lBottom := Max(lTop + 16, fPaint.Height - 18);
  if Length(fSamples) < 2 then
    Exit;

  lMaxAbs := fSamples[0];
  lMinValue := fSamples[0];
  for I := 0 to High(fSamples) do
  begin
    if fSamples[I] < lMinValue then
      lMinValue := fSamples[I];
    if fSamples[I] > lMaxAbs then
      lMaxAbs := fSamples[I];
  end;
  lSpan := lMaxAbs - lMinValue;
  if lSpan < 1 then
    lSpan := 1;
  lMidValue := (lMaxAbs + lMinValue) / 2.0;
  lHeight := Max(1, lBottom - lTop);
  lScale := lHeight / lSpan;

  fPaint.Canvas.Font.Color := clSilver;
  fPaint.Canvas.Pen.Color := RGBToColor(45, 45, 45);
  lY := ValueToY(lMaxAbs);
  fPaint.Canvas.Line(lPlotLeft, lY, lPlotRight, lY);
  fPaint.Canvas.TextOut(4, Max(0, lY - 7), Format('%.0f', [lMaxAbs]));
  lY := ValueToY(lMidValue);
  fPaint.Canvas.Line(lPlotLeft, lY, lPlotRight, lY);
  fPaint.Canvas.TextOut(4, Max(0, lY - 7), Format('%.0f', [lMidValue]));
  lY := ValueToY(lMinValue);
  fPaint.Canvas.Line(lPlotLeft, lY, lPlotRight, lY);
  fPaint.Canvas.TextOut(4, Max(0, lY - 14), Format('%.0f', [lMinValue]));
  fPaint.Canvas.Pen.Color := RGBToColor(70, 70, 70);
  fPaint.Canvas.Line(lPlotLeft - 3, lTop, lPlotLeft - 3, lBottom);

  fPaint.Canvas.Pen.Color := RGBToColor(0, 220, 120);
  lPrevX := lPlotLeft;
  lPrevY := ValueToY(lMidValue);
  for I := 0 to High(fSamples) do
  begin
    lIndex := (fSampleWriteIndex + I) mod Length(fSamples);
    lValue := fSamples[lIndex];
    lX := lPlotLeft + Round(I * (lPlotRight - lPlotLeft) /
      (Length(fSamples) - 1));
    lY := ValueToY(lValue);
    if I = 0 then
      fPaint.Canvas.MoveTo(lX, lY)
    else
      fPaint.Canvas.LineTo(lX, lY);
    lPrevX := lX;
    lPrevY := lY;
  end;
  fPaint.Canvas.Font.Color := clGray;
  fPaint.Canvas.TextOut(lPlotLeft + 8, 4, Format('slot %d ch %d, min %.0f max %.0f',
    [fSpinSlot.Value, fSpinChannel.Value, lMinValue, lMaxAbs]));
  fPaint.Canvas.MoveTo(lPrevX, lPrevY);
end;

end.
