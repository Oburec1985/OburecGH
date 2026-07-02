unit uMic140AcquireThread;

{
  Поток сбора данных MIC-140 (аналог read loop в uRecorderMic140DataSource).

  Execute:
    PrepareHardware → цикл ReadLegacyRawBlock + LegacyDecommutateRawBlock
    до истечения fDurationSec → Stop/Disconnect → EvaluatePass в лог.

  PublishBlock — ключевая логика UI-стенда:
    1) LogAdcTable — полная таблица в лог один раз (первый блок)
    2) NotifyAdcBlock — обновление grid на КАЖДОМ блоке (даже если коды не совпали)
    3) CheckPublishedCodes — строгая приёмка; при FAIL Published не растёт
    4) NotifyCh29 — отдельная строка для контрольного канала

  AQuiet=True (auto runner): без Synchronize в UI, только лог.
}

{$mode objfpc}{$H+}

interface

uses

  Classes, SysUtils,

  uRecorderDeviceInterfaces,

  uRecorderAcquisitionTypes,

  uRecorderMic140DeviceApi,

  uRecorderMic140v2WireTypes,

  uMic140DebugConfig, uMic140AcceptanceLog;



type

  TMic140Ch29Event = procedure(Sender: TObject; ACode: Integer; ABlockNo: Integer) of object;

  TMic140AdcBlockEvent = procedure(Sender: TObject;
    const ABlock: TRecorderDeviceSampleBlock;
    const AAux: TMic140AuxTemperatureBlock; ABlockNo: Integer) of object;

  TMic140StatusEvent = procedure(Sender: TObject; const AText: string) of object;

  TMic140FinishedEvent = procedure(Sender: TObject; const AResult: string) of object;



  TMic140AcquireThread = class(TThread)

  private

    fMic: IMic140Device;

    fConfig: TMic140DebugConfig;

    fLog: TMic140AcceptanceLog;

    fStats: TMic140AcceptanceStats;

    fDurationSec: Integer;

    fAutoClose: Boolean;

    fQuiet: Boolean;

    fSourceId: string;

    fOnCh29: TMic140Ch29Event;

    fOnAdcBlock: TMic140AdcBlockEvent;

    fOnStatus: TMic140StatusEvent;

    fOnFinished: TMic140FinishedEvent;

    fPendingCh29Code: Integer;

    fPendingCh29Block: Integer;

    fFirstAdcLogged: Boolean;

    fPendingAdcBlock: TRecorderDeviceSampleBlock;

    fPendingAux: TMic140AuxTemperatureBlock;

    fPendingAdcBlockNo: Integer;

    fPendingStatus: string;

    fPendingResult: string;

    procedure SyncCh29;

    procedure SyncAdcBlock;

    procedure SyncStatus;

    procedure SyncFinished;

    procedure NotifyCh29(ACode, ABlockNo: Integer);

    procedure NotifyAdcBlock(const ABlock: TRecorderDeviceSampleBlock;
      const AAux: TMic140AuxTemperatureBlock; ABlockNo: Integer);

    procedure NotifyStatus(const AText: string);

    procedure NotifyFinished(const AResult: string);

    procedure PublishBlock(const ABlock: TRecorderDeviceSampleBlock;

      const AAux: TMic140AuxTemperatureBlock);

    procedure LogPhase(const AText: string);
    procedure LogLine(const ALine: string);

  protected

    procedure Execute; override;

  public

    constructor Create(AMic: IMic140Device; ALog: TMic140AcceptanceLog;

      const AConfig: TMic140DebugConfig; ADurationSec: Integer;

      AAutoClose: Boolean = False; AQuiet: Boolean = False);

    property Stats: TMic140AcceptanceStats read fStats;

    property OnCh29: TMic140Ch29Event read fOnCh29 write fOnCh29;

    property OnAdcBlock: TMic140AdcBlockEvent read fOnAdcBlock write fOnAdcBlock;

    property OnStatus: TMic140StatusEvent read fOnStatus write fOnStatus;

    property OnFinished: TMic140FinishedEvent read fOnFinished write fOnFinished;

  end;



implementation



uses

  Math;



procedure TMic140AcquireThread.LogPhase(const AText: string);

begin

  fLog.LogInfo(Format('phase: %s', [AText]));

end;



procedure TMic140AcquireThread.LogLine(const ALine: string);

begin

  fLog.LogInfo(ALine);

end;



procedure TMic140AcquireThread.SyncCh29;

begin

  if Assigned(fOnCh29) then

    fOnCh29(Self, fPendingCh29Code, fPendingCh29Block);

end;



procedure TMic140AcquireThread.SyncStatus;

begin

  if Assigned(fOnStatus) then

    fOnStatus(Self, fPendingStatus);

end;



procedure TMic140AcquireThread.SyncFinished;

begin

  if Assigned(fOnFinished) then

    fOnFinished(Self, fPendingResult);

end;



procedure TMic140AcquireThread.NotifyCh29(ACode, ABlockNo: Integer);

begin

  if fQuiet then

    Exit;

  fPendingCh29Code := ACode;

  fPendingCh29Block := ABlockNo;

  if Assigned(fOnCh29) then

    Synchronize(@SyncCh29);

end;



procedure TMic140AcquireThread.NotifyStatus(const AText: string);

begin

  if fQuiet then

    Exit;

  fPendingStatus := AText;

  if Assigned(fOnStatus) then

    Synchronize(@SyncStatus);

end;



procedure TMic140AcquireThread.NotifyFinished(const AResult: string);

begin

  if fQuiet then

    Exit;

  fPendingResult := AResult;

  if Assigned(fOnFinished) then

    Synchronize(@SyncFinished);

end;



constructor TMic140AcquireThread.Create(AMic: IMic140Device; ALog: TMic140AcceptanceLog;

  const AConfig: TMic140DebugConfig; ADurationSec: Integer; AAutoClose: Boolean;

  AQuiet: Boolean);

begin

  inherited Create(True);

  FreeOnTerminate := not AAutoClose and not AQuiet;

  fMic := AMic;

  fLog := ALog;

  fConfig := AConfig;

  fDurationSec := ADurationSec;

  fAutoClose := AAutoClose;

  fQuiet := AQuiet;

  fSourceId := Format('MIC-140: %s:%d', [fConfig.Host, fConfig.Port]);

  fFirstAdcLogged := False;

  Mic140AcceptanceStatsClear(fStats);

end;



procedure TMic140AcquireThread.SyncAdcBlock;

begin

  if Assigned(fOnAdcBlock) then

    fOnAdcBlock(Self, fPendingAdcBlock, fPendingAux, fPendingAdcBlockNo);

end;



procedure TMic140AcquireThread.NotifyAdcBlock(const ABlock: TRecorderDeviceSampleBlock;

  const AAux: TMic140AuxTemperatureBlock; ABlockNo: Integer);

begin

  if fQuiet then

    Exit;

  fPendingAdcBlock := ABlock;

  fPendingAux := AAux;

  fPendingAdcBlockNo := ABlockNo;

  if Assigned(fOnAdcBlock) then

    Synchronize(@SyncAdcBlock);

end;



procedure TMic140AcquireThread.PublishBlock(const ABlock: TRecorderDeviceSampleBlock;

  const AAux: TMic140AuxTemperatureBlock);

var

  lCh29Idx: Integer;

  lCode: Integer;
  lCodesOk: Boolean;

begin

  if not fFirstAdcLogged then
  begin
    if (fConfig.SettleSec <= 0) or
       (GetTickCount64 - fStats.StartTick >= Cardinal(fConfig.SettleSec) * 1000) then
    begin
      fFirstAdcLogged := True;
      fLog.LogAdcTable(ABlock, AAux, fStats.Read, fConfig.TinSlots > 0);
    end;
  end;

  NotifyAdcBlock(ABlock, AAux, fStats.Read);

  lCh29Idx := fConfig.WatchChannel1 - 1;

  if (lCh29Idx >= 0) and (lCh29Idx < Length(ABlock.Values)) and

     (Length(ABlock.Values[lCh29Idx]) > 0) then

  begin

    lCode := Trunc(ABlock.Values[lCh29Idx][0]);

    NotifyCh29(lCode, fStats.Read);

  end;

  if (fConfig.SettleSec > 0) and
     (GetTickCount64 - fStats.StartTick < Cardinal(fConfig.SettleSec) * 1000) then
    Exit;

  lCodesOk := fLog.CheckPublishedCodes(ABlock, AAux, fStats, fConfig.TinSlots > 0);
  if lCodesOk then
    Inc(fStats.Published);

end;



procedure TMic140AcquireThread.Execute;

var

  lBlock: TRecorderDeviceSampleBlock;

  lRaw: TMic140LegacyRawBlock;

  lAux: TMic140AuxTemperatureBlock;

  lTimeout: Cardinal;

  lEndTick: QWord;

  lResult: string;

  lEvalSec: Integer;

  lNeedEval: Boolean;

  lPrep: string;

begin

  lNeedEval := True;

  lResult := 'FAIL unknown';

  fStats.StartTick := GetTickCount64;

  if fDurationSec > 0 then

    lEndTick := fStats.StartTick + Cardinal(fDurationSec) * 1000

  else

    lEndTick := 0;



  try

    LogPhase(Format('run %d s, %s', [fDurationSec, fSourceId]));

    LogPhase(Mic140DebugConfigSummary(fConfig));



    NotifyStatus('connecting...');

    lPrep := Mic140DebugPrepareHardware(fMic, fConfig, @LogLine);

    if lPrep <> '' then

    begin

      lResult := lPrep;

      lNeedEval := False;

      Exit;

    end;



    lTimeout := Mic140DebugMainReadTimeoutMs(fConfig);

    LogPhase(Format('acquire loop timeout=%d ms', [lTimeout]));

    while not Terminated do

    begin

      if (lEndTick > 0) and (GetTickCount64 >= lEndTick) then

      begin

        LogPhase('duration elapsed');

        Break;

      end;



      if fMic.ReadLegacyRawBlock(lTimeout, lRaw) then

      begin

        Inc(fStats.Read);

        if fMic.LegacyDecommutateRawBlock(lRaw, lBlock) then

        begin

          lAux := fMic.LastAuxTemperatureBlock;

          PublishBlock(lBlock, lAux);

        end;



        while not Terminated and fMic.ReadLegacyRawBlock(0, lRaw) do

        begin

          Inc(fStats.Read);

          if fMic.LegacyDecommutateRawBlock(lRaw, lBlock) then

          begin

            lAux := fMic.LastAuxTemperatureBlock;

            PublishBlock(lBlock, lAux);

          end;

        end;



        fStats.ReadGaps := fMic.LegacyNumBuffGapCount;

        fStats.CorruptRead := fMic.LegacyCorruptReadCount;

        fStats.MdpResync := fMic.LegacyMdpResyncByteCount;

        if (fStats.Read > 0) and ((fStats.Read mod 5) = 0) then

          NotifyStatus(Format('accepted=%d read=%d bad=%d', [
            fStats.Published, fStats.Read, fStats.CodeViolations]));

      end

      else if fMic.LegacyTryRestartStreamAfterReadStall then

        Inc(fStats.SoftRestart);

    end;

  finally

    LogPhase('stop scan');

    try

      fMic.Stop;

    except

      on E: Exception do

        fLog.LogInfo('stop exception: ' + E.Message);

    end;

    try

      fMic.Disconnect;

    except

    end;

    fStats.ReadGaps := fMic.LegacyNumBuffGapCount;

    fStats.CorruptRead := fMic.LegacyCorruptReadCount;

    fStats.MdpResync := fMic.LegacyMdpResyncByteCount;

    fLog.LogStreamStop(fSourceId, fStats);

    if lNeedEval then

    begin

      lEvalSec := fDurationSec - fConfig.SettleSec;
      if lEvalSec < 1 then
        lEvalSec := fDurationSec;

      if lEvalSec <= 0 then

        lEvalSec := Max(1, Round(fStats.ElapsedSec));

      lResult := fLog.EvaluatePass(fStats, lEvalSec);

    end;

    fLog.LogInfo(lResult);

    fLog.Flush;

  end;

  if fAutoClose then
  begin
    if Copy(lResult, 1, 4) = 'PASS' then
      ExitCode := 0
    else
      ExitCode := 1;
  end;
  NotifyFinished(lResult);

end;



end.


