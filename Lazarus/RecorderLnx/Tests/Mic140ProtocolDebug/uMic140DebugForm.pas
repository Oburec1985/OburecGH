unit uMic140DebugForm;

{
  GUI стенда MIC-140.

  Элементы:
    btnStart3/10/40  — запуск сбора на 3/10/40 с
    btnStop          — остановка потока
    cbRange/cbCommut — range и commut для CH01..48 (bank2-флаги — только CLI)
    sgAdc            — живая таблица кодов (uMic140AdcTable)
    memoLog          — хвост mic140_protocol_debug.log
    lblCh29          — контроль CH29 (WatchChannel1 из конфига)
    lblRef           — подсказка по эталону

  ParseCommandLine (FormShow):
    Те же флаги, что в uMic140AutoRunner; при --auto N форма стартует и закрывается.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Grids,
  uRecorderDeviceInterfaces,
  uRecorderMic140DeviceApi,
  uMic140DebugConfig, uMic140AcceptanceLog, uMic140AcquireThread, uMic140Api;

type
  { TMic140DebugForm }
  TMic140DebugForm = class(TForm)
    btnStart3: TButton;
    btnStart10: TButton;
    btnStart40: TButton;
    btnStop: TButton;
    cbCommut: TComboBox;
    cbRange: TComboBox;
    lblCommut: TLabel;
    lblCh29: TLabel;
    lblRange: TLabel;
    lblRef: TLabel;
    lblStatus: TLabel;
    sgAdc: TStringGrid;
    memoLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnStart3Click(Sender: TObject);
    procedure btnStart10Click(Sender: TObject);
    procedure btnStart40Click(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure sgAdcPrepareCanvas(Sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
  private
    fConfig: TMic140DebugConfig;
    fApiDev: TMic140Device;
    fMic: IMic140Device;
    fLog: TMic140AcceptanceLog;
    fThread: TMic140AcquireThread;
    fRunning: Boolean;
    fAutoDurationSec: Integer;
    fArgsDebug: string;
    procedure ParseCommandLine;
    procedure AppendMemo(const ALine: string);
    procedure StartRun(ADurationSec: Integer);
    procedure ThreadCh29(Sender: TObject; ACode, ABlockNo: Integer);
    procedure ThreadAdcBlock(Sender: TObject; const ABlock: TRecorderDeviceSampleBlock;
      const AAux: TMic140AuxTemperatureBlock; ABlockNo: Integer);
    procedure ThreadStatus(Sender: TObject; const AText: string);
    procedure ThreadFinished(Sender: TObject; const AResult: string);
  public
  end;

var
  Mic140DebugForm: TMic140DebugForm;

implementation

{$R *.lfm}

uses
  uRecorderAcquisitionTypes,
  uRecorderMic140v2WireTypes,
  uMic140DebugReference,
  uMic140AdcTable;

procedure TMic140DebugForm.ParseCommandLine;
var
  I: Integer;
  lArg: string;
  lArgs: TStringList;
  lParts: TStringArray;
  lPart: string;
begin
  lArgs := TStringList.Create;
  try
    for I := 1 to ParamCount do
    begin
      lParts := ParamStr(I).Split([' '], TStringSplitOptions.ExcludeEmpty);
      for lPart in lParts do
        lArgs.Add(lPart);
    end;
    fArgsDebug := StringReplace(lArgs.Text, LineEnding, ' ', [rfReplaceAll]);

    I := 0;
    while I < lArgs.Count do
    begin
      lArg := lArgs[I];
      if SameText(lArg, '--auto') then
      begin
        fAutoDurationSec := 3;
        if (I + 1 < lArgs.Count) and (Copy(lArgs[I + 1], 1, 2) <> '--') then
        begin
          fAutoDurationSec := StrToIntDef(lArgs[I + 1], fAutoDurationSec);
          Inc(I);
        end;
      end
      else if (SameText(lArg, '--seconds') or SameText(lArg, '-s')) and
        (I + 1 < lArgs.Count) then
      begin
        fAutoDurationSec := StrToIntDef(lArgs[I + 1], fAutoDurationSec);
        Inc(I);
      end
      else if SameText(lArg, '--range') and (I + 1 < lArgs.Count) then
      begin
        fConfig.RangeIndex := StrToIntDef(lArgs[I + 1], fConfig.RangeIndex);
        Inc(I);
      end
      else if SameText(lArg, '--bank2-range') and (I + 1 < lArgs.Count) then
      begin
        fConfig.Bank2RangeIndex := StrToIntDef(lArgs[I + 1],
          fConfig.Bank2RangeIndex);
        Inc(I);
      end
      else if SameText(lArg, '--commut') and (I + 1 < lArgs.Count) then
      begin
        fConfig.CommutIndex := StrToIntDef(lArgs[I + 1], fConfig.CommutIndex);
        Inc(I);
      end
      else if SameText(lArg, '--bank2-commut') and (I + 1 < lArgs.Count) then
      begin
        fConfig.Bank2CommutIndex := StrToIntDef(lArgs[I + 1],
          fConfig.Bank2CommutIndex);
        Inc(I);
      end
      else if SameText(lArg, '--bank2-delay-mul') and (I + 1 < lArgs.Count) then
      begin
        fConfig.Bank2DelayMul := StrToIntDef(lArgs[I + 1],
          fConfig.Bank2DelayMul);
        Inc(I);
      end
      else if SameText(lArg, '--tin-slots') and (I + 1 < lArgs.Count) then
      begin
        fConfig.TinSlots := StrToIntDef(lArgs[I + 1], fConfig.TinSlots);
        Inc(I);
      end
      else if SameText(lArg, '--chan-dump-count') and (I + 1 < lArgs.Count) then
      begin
        fConfig.ChanDumpCount := StrToIntDef(lArgs[I + 1],
          fConfig.ChanDumpCount);
        Inc(I);
      end;
      Inc(I);
    end;
  finally
    lArgs.Free;
  end;
end;

procedure TMic140DebugForm.FormCreate(Sender: TObject);
var
  lExpected, lTol: Integer;
begin
  fConfig := Mic140DebugDefaultConfig;
  fApiDev := nil;
  fMic := nil;
  fLog := TMic140AcceptanceLog.Create(ExtractFilePath(ParamStr(0)));
  fRunning := False;
  fAutoDurationSec := 0;
  ParseCommandLine;
  fLog.LogInfo(Format('argv parsed: [%s] auto=%d range=%d bank2range=%d commut=%d bank2=%d bank2delay=%d tin=%d dump=%d',
    [Trim(fArgsDebug), fAutoDurationSec, fConfig.RangeIndex,
     fConfig.Bank2RangeIndex, fConfig.CommutIndex, fConfig.Bank2CommutIndex,
     fConfig.Bank2DelayMul, fConfig.TinSlots, fConfig.ChanDumpCount]));
  Caption := 'MIC-140 Protocol Debug';
  lblStatus.Caption := Mic140DebugConfigSummary(fConfig);
  if Mic140StandAinReference(fConfig.WatchChannel1 - 1, lExpected) then
  begin
    lTol := Mic140StandAinTolerance(fConfig.WatchChannel1 - 1);
    lblRef.Caption := Format('Stand ref CH%d = %d +/-%d', [fConfig.WatchChannel1, lExpected, lTol]);
  end
  else
    lblRef.Caption := '';
  lblCh29.Caption := Format('CH%d: ---', [fConfig.WatchChannel1]);
  lblCh29.Font.Size := 18;
  lblCh29.Font.Style := [fsBold];
  btnStop.Enabled := False;
  sgAdc.RowCount := 2;
  sgAdc.ColCount := 5;
  sgAdc.FixedRows := 1;
  sgAdc.Options := sgAdc.Options + [goRowSelect];
  sgAdc.Cells[0, 0] := 'Chan';
  sgAdc.Cells[1, 0] := 'Raw';
  sgAdc.Cells[2, 0] := 'Ref';
  sgAdc.Cells[3, 0] := 'Delta';
  sgAdc.Cells[4, 0] := 'OK';
  sgAdc.OnPrepareCanvas := @sgAdcPrepareCanvas;
  cbRange.Items.Clear;
  cbRange.Items.Add('0: 100 mV');
  cbRange.Items.Add('1: 50 mV');
  cbRange.Items.Add('2: 25 mV');
  cbRange.ItemIndex := fConfig.RangeIndex;
  cbCommut.Items.Clear;
  cbCommut.Items.Add('0: input');
  cbCommut.Items.Add('1: mux in1');
  cbCommut.Items.Add('2: mux in2');
  cbCommut.Items.Add('3: mux in1+in2');
  cbCommut.ItemIndex := fConfig.CommutIndex;
  AppendMemo('Log: ' + fLog.Path);
  AppendMemo('ADC ref: Data/mic140_adc_reference.txt');
end;

procedure TMic140DebugForm.FormShow(Sender: TObject);
begin
  if fAutoDurationSec > 0 then
    StartRun(fAutoDurationSec);
end;

procedure TMic140DebugForm.FormDestroy(Sender: TObject);
begin
  if fRunning and (fThread <> nil) then
  begin
    fThread.Terminate;
    fThread.WaitFor;
  end;
  fLog.Free;
  fApiDev.Free;
end;

procedure TMic140DebugForm.sgAdcPrepareCanvas(Sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
  Mic140AdcTablePrepareCanvas(Sender, aCol, aRow, aState);
end;

procedure TMic140DebugForm.AppendMemo(const ALine: string);
begin
  memoLog.Lines.Add(ALine);
  if memoLog.Lines.Count > 200 then
    memoLog.Lines.Delete(0);
end;

procedure TMic140DebugForm.StartRun(ADurationSec: Integer);
begin
  if fRunning then
    Exit;
  fRunning := True;
  btnStart3.Enabled := False;
  btnStart10.Enabled := False;
  btnStart40.Enabled := False;
  btnStop.Enabled := True;
  if cbRange.ItemIndex >= 0 then
    fConfig.RangeIndex := cbRange.ItemIndex;
  if cbCommut.ItemIndex >= 0 then
    fConfig.CommutIndex := cbCommut.ItemIndex;
  lblCh29.Caption := Format('CH%d: ...', [fConfig.WatchChannel1]);
  AppendMemo(Format('--- run %d s ---', [ADurationSec]));
  AppendMemo(Mic140DebugConfigSummary(fConfig));
  fApiDev.Free;
  fApiDev := TMic140Device.Create(Mic140ConfigFromDebug(fConfig));
  fMic := fApiDev.Inner;
  fThread := TMic140AcquireThread.Create(fMic, fLog, fConfig, ADurationSec,
    fAutoDurationSec > 0, False);
  fThread.OnCh29 := @ThreadCh29;
  fThread.OnAdcBlock := @ThreadAdcBlock;
  fThread.OnStatus := @ThreadStatus;
  fThread.OnFinished := @ThreadFinished;
  fThread.Start;
end;

procedure TMic140DebugForm.btnStart3Click(Sender: TObject);
begin
  StartRun(3);
end;

procedure TMic140DebugForm.btnStart10Click(Sender: TObject);
begin
  StartRun(10);
end;

procedure TMic140DebugForm.btnStart40Click(Sender: TObject);
begin
  StartRun(40);
end;

procedure TMic140DebugForm.btnStopClick(Sender: TObject);
begin
  if fRunning and (fThread <> nil) then
    fThread.Terminate;
end;

procedure TMic140DebugForm.ThreadCh29(Sender: TObject; ACode, ABlockNo: Integer);
var
  lExpected: Integer;
  lOk: Boolean;
begin
  lOk := Mic140StandAinReference(fConfig.WatchChannel1 - 1, lExpected) and
    Mic140StandAinCodeOk(ACode, fConfig.WatchChannel1 - 1);
  if lOk then
    lblCh29.Font.Color := clGreen
  else
    lblCh29.Font.Color := clRed;
  lblCh29.Caption := Format('CH%d: %d  (block %d)', [fConfig.WatchChannel1, ACode, ABlockNo]);
end;

procedure TMic140DebugForm.ThreadAdcBlock(Sender: TObject;
  const ABlock: TRecorderDeviceSampleBlock;
  const AAux: TMic140AuxTemperatureBlock; ABlockNo: Integer);
begin
  Mic140AdcTableFillGrid(sgAdc, ABlock, AAux);
  AppendMemo(Format('ADC table block %d updated', [ABlockNo]));
end;

procedure TMic140DebugForm.ThreadStatus(Sender: TObject; const AText: string);
begin
  lblStatus.Caption := AText;
  AppendMemo(AText);
end;

procedure TMic140DebugForm.ThreadFinished(Sender: TObject; const AResult: string);
begin
  fRunning := False;
  fThread := nil;
  fMic := nil;
  fApiDev.Free;
  fApiDev := nil;
  btnStart3.Enabled := True;
  btnStart10.Enabled := True;
  btnStart40.Enabled := True;
  btnStop.Enabled := False;
  lblStatus.Caption := AResult;
  AppendMemo(AResult);
  AppendMemo('Log saved: ' + fLog.Path);
  if Copy(AResult, 1, 4) = 'PASS' then
    lblStatus.Font.Color := clGreen
  else
    lblStatus.Font.Color := clRed;
  if fAutoDurationSec > 0 then
    Close;
end;

end.
