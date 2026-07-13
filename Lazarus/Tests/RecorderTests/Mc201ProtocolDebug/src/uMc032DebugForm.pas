unit uMc032DebugForm;

{
  Code-only LCL form for MC032 controller protocol debugging.

  The form uses TMc032Device and receives play data through a callback. The
  callback appends raw stream words into a simple oscilloscope buffer.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids, uMc032Device, uMc201ProtocolTypes;

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
    fPaint: TPaintBox;
    fRxBlockCount: Int64;
    fSamples: array of Double;
    fSampleWriteIndex: Integer;
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
    procedure DeviceData(Sender: TObject; const APacket: TMc032DataPacket);
    procedure LogLine(const AText: string);
    procedure PaintOscilloscope(Sender: TObject);
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

implementation

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
  fDevice := TMc032Device.Create;
  fLogPath := ChangeFileExt(ParamStr(0), '.gui.log');
  SetLength(fSamples, 2048);
  BuildUi;
  LogLine('GUI started');
  UpdateState;
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
  fLblState := AddLabel('', 656, lTop, 220);
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
  fLblRx.Caption := Format('RX blocks=%d; last block=%d words',
    [fRxBlockCount, ALastBlockWords]);
end;

procedure TMc032DebugForm.UpdateState;
begin
  UpdateConfigView;
  fLblState.Caption := 'Состояние: ' + Mc032StateToString(fDevice.State);
  fBtnConnect.Enabled := fDevice.State = mcsDisconnected;
  fBtnDisconnect.Enabled := fDevice.State <> mcsDisconnected;
  fBtnConfig.Enabled := fDevice.State = mcsConnected;
  fBtnModules.Enabled := fDevice.State = mcsConnected;
  fBtnPlay.Enabled := fDevice.State = mcsConnected;
  fBtnStop.Enabled := fDevice.State = mcsPlay;
  fBtnReset.Enabled := fDevice.State = mcsConnected;
end;

procedure TMc032DebugForm.LogLine(const AText: string);
var
  lFile: TextFile;
  lLine: string;
begin
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
  SetDeviceOptions;
  LogLine(Format('Connect request host=%s port=%d timeout=%d',
    [fDevice.Host, fDevice.Port, fDevice.TimeoutMs]));
  try
    fDevice.Connect;
    LogLine('Connect: ' + Mc201FormatBios(fDevice.Bios));
  except
    on E: Exception do
      LogLine('Connect: ' + E.Message);
  end;
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
begin
  if fDevice.Config(BuildConfig, lError) then
  begin
    UpdateConfigView;
    LogLine('Config: ' + fLblConfig.Caption + '; RESETSCANMAIN OK');
  end
  else
    LogLine('Config: ' + lError);
  UpdateState;
end;

procedure TMc032DebugForm.ButtonPlay(Sender: TObject);
var
  lError: string;
begin
  fRxBlockCount := 0;
  UpdateRxView(0);
  if fDevice.Play(@DeviceData, lError) then
    LogLine('Play: STARTSCANMAIN OK')
  else
    LogLine('Play: ' + lError);
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
  UpdateState;
end;

procedure TMc032DebugForm.ButtonReset(Sender: TObject);
var
  lError: string;
begin
  if fDevice.Reset(lError) then
    LogLine('Reset: CMD_RESET OK')
  else
    LogLine('Reset: ' + lError);
  UpdateState;
end;

procedure TMc032DebugForm.DeviceData(Sender: TObject;
  const APacket: TMc032DataPacket);
begin
  Inc(fRxBlockCount);
  UpdateRxView(Length(APacket.Words));
  AppendSamples(APacket.Words);
  LogLine(Format('RX stream=%d packet=%d block=%d words=%d',
    [APacket.StreamPort, APacket.PacketIndex, fRxBlockCount,
     Length(APacket.Words)]));
  fPaint.Invalidate;
end;

procedure TMc032DebugForm.AppendSamples(const AWords: TMc201WordArray);
var
  I: Integer;
begin
  if Length(fSamples) = 0 then
    Exit;
  for I := 0 to High(AWords) do
  begin
    fSamples[fSampleWriteIndex] := WordToSigned(AWords[I]);
    Inc(fSampleWriteIndex);
    if fSampleWriteIndex >= Length(fSamples) then
      fSampleWriteIndex := 0;
  end;
end;

procedure TMc032DebugForm.PaintOscilloscope(Sender: TObject);
var
  I: Integer;
  lCenter: Integer;
  lHeight: Integer;
  lIndex: Integer;
  lMaxAbs: Double;
  lMinValue: Double;
  lPrevX: Integer;
  lPrevY: Integer;
  lScale: Double;
  lSpan: Double;
  lValue: Double;
  lX: Integer;
  lY: Integer;
begin
  fPaint.Canvas.Brush.Color := clBlack;
  fPaint.Canvas.FillRect(0, 0, fPaint.Width, fPaint.Height);
  fPaint.Canvas.Pen.Color := RGBToColor(60, 60, 60);
  lCenter := fPaint.Height div 2;
  fPaint.Canvas.Line(0, lCenter, fPaint.Width, lCenter);
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
  lHeight := Max(1, fPaint.Height - 16);
  lScale := lHeight / lSpan;
  fPaint.Canvas.Pen.Color := RGBToColor(0, 220, 120);
  lPrevX := 0;
  lPrevY := lCenter;
  for I := 0 to High(fSamples) do
  begin
    lIndex := (fSampleWriteIndex + I) mod Length(fSamples);
    lValue := fSamples[lIndex];
    lX := Round(I * (fPaint.Width - 1) / (Length(fSamples) - 1));
    lY := fPaint.Height - 8 - Round((lValue - lMinValue) * lScale);
    if I = 0 then
      fPaint.Canvas.MoveTo(lX, lY)
    else
      fPaint.Canvas.LineTo(lX, lY);
    lPrevX := lX;
    lPrevY := lY;
  end;
  fPaint.Canvas.Pen.Color := clGray;
  fPaint.Canvas.TextOut(8, 8, Format('raw words, min %.0f max %.0f',
    [lMinValue, lMaxAbs]));
  fPaint.Canvas.MoveTo(lPrevX, lPrevY);
end;

end.
