program Mic140ProtocolDebug;

{
  =============================================================================
  Mic140ProtocolDebug — автономный стенд отладки протокола MIC-140 (Lazarus/LCL)
  =============================================================================

  Назначение:
    Подключиться к реальному MIC-140 по TCP, запрограммировать BIOS-скан,
    принять несколько блоков отсчётов и сравнить сырые коды АЦП с эталоном
    Windows Recorder (файл Data/mic140_adc_reference.txt).

  Не является частью RecorderLnx:
    - Собирается отдельным .lpi в Tests/Mic140ProtocolDebug/
    - Экспериментальные оверрайды драйвера — только в подкаталоге Driver/
      (shadow-units с теми же именами, но первыми в unit search path)
    - Основной Device/MIC140v2 не содержит debug-setters

  Структура проекта:
    Mic140ProtocolDebug.lpr      — точка входа (GUI или headless --auto)
    uMic140DebugConfig.pas       — IP, частота, диапазон, CLI-флаги экспериментов
    uMic140DebugReference.pas    — эталонные коды и допуск ±20
    uMic140AcquireThread.pas     — поток: connect → read loop → приёмка
    uMic140AcceptanceLog.pas     — mic140_protocol_debug.log, PASS/FAIL
    uMic140AdcTable.pas          — таблица CH01..48 + T1..T3 для grid/лога
    uMic140AutoRunner.pas        — разбор CLI и запуск без формы
    uMic140DebugForm.pas         — кнопки, grid, memo
    Driver/                      — shadow uRecorderMic140v2Scan/Device
    Data/mic140_adc_reference.txt — снимок кодов с Recorder UI
    errors/                      — журнал гипотез и результатов прогонов

  Режимы запуска:
    GUI:  Mic140ProtocolDebug.exe
    Auto: Mic140ProtocolDebug.exe --auto 3 [флаги экспериментов]
    CLI:  Mic140ProtocolDebugCli.exe 3   (упрощённый, без разбора флагов)

  Лог: mic140_protocol_debug.log рядом с exe.
  Журнал гипотез: errors/2026-06-30-ui-stand-ref-match.md
}

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  {$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}
  {$ENDIF}
  SysUtils,
  uMic140AutoRunner,
  Interfaces,
  Forms,
  uMic140DebugForm in 'uMic140DebugForm.pas' {Mic140DebugForm},
  uMic140DebugConfig in 'uMic140DebugConfig.pas',
  uMic140AcceptanceLog in 'uMic140AcceptanceLog.pas',
  uMic140AcquireThread in 'uMic140AcquireThread.pas';

function HasAutoArg: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if Pos('--auto', LowerCase(ParamStr(I))) > 0 then
      Exit(True);
end;

begin
  if HasAutoArg then
  begin
    ExitCode := Mic140RunAutoTestFromCommandLine;
    Exit;
  end;

  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMic140DebugForm, Mic140DebugForm);
  Application.Run;
end.
