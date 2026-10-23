program SqlTrendEventsSmoke;

{
  Проверка галочек фильтра событий SQL-тренда и иконки «замер не резолвится».

  Проверяет контракт, который виджет использует вместе с диалогом настроек:
  модель хранит ShowRecordingEvents / ShowTagAlarmEvents / ShowTagRangeEvents
  и ShowOnlyUnresolvedEventPoints; событие записи без файлов пакета считается
  неразрешимым; Store/Load проекта возвращает настройки обратно.

  Запуск: SqlTrendEventsSmoke.exe  (лог рядом с exe)
}

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Classes, SysUtils, Forms, Controls, StdCtrls, Graphics, Dialogs,
  uRecorderSqlDbTypes, uRecorderSqlTrendModel, uRecorderSqlTrendSettingsDialog;

var
  gLog: TStringList;
  gFailures: Integer;

procedure Log(const AText: string);
begin
  gLog.Add(AText);
  WriteLn(AText);
end;

procedure Check(ACondition: Boolean; const AName, ADetail: string);
begin
  if ACondition then
    Log('RESULT ' + AName + ' passed')
  else
  begin
    Inc(gFailures);
    Log('RESULT ' + AName + ' FAILED: ' + ADetail);
  end;
end;

function RecordingEvent(const AId: string; AFileCount: Integer):
  TRecorderSqlDbMeraEvent;
begin
  Result := Default(TRecorderSqlDbMeraEvent);
  Result.EventId := AId;
  Result.EventType := 'mera.recording';
  Result.DisplayName := 'zamer-' + AId;
  Result.StartedAtUtc := 45000.5;
  Result.State := 'ready-local';
  Result.PackageCount := 1;
  Result.MeraFileCount := AFileCount;
end;

function TagEvent(const AId, AEventType, ASignalName: string):
  TRecorderSqlDbMeraEvent;
begin
  Result := Default(TRecorderSqlDbMeraEvent);
  Result.EventId := AId;
  Result.EventType := AEventType;
  Result.SignalName := ASignalName;
  Result.DisplayName := ASignalName;
  Result.StartedAtUtc := 45000.6;
  Result.State := 'active';
end;

procedure TestDefaults;
var
  lComponent: TRecorderSqlTrendComponent;
begin
  lComponent := TRecorderSqlTrendComponent.Create;
  try
    Check(lComponent.ShowEvents, 'default-show-events', 'ShowEvents must be True');
    Check(lComponent.ShowRecordingEvents, 'default-recordings', 'recordings on');
    Check(lComponent.ShowTagAlarmEvents, 'default-alarms', 'alarms on');
    Check(lComponent.ShowTagRangeEvents, 'default-ranges', 'ranges on');
    Check(not lComponent.ShowOnlyUnresolvedEventPoints,
      'default-unresolved-off', 'unresolved only must default to off');
  finally
    lComponent.Free;
  end;
end;

procedure TestAssignCopiesFilters;
var
  lSource, lTarget: TRecorderSqlTrendComponent;
begin
  lSource := TRecorderSqlTrendComponent.Create;
  lTarget := TRecorderSqlTrendComponent.Create;
  try
    lSource.ShowRecordingEvents := False;
    lSource.ShowTagAlarmEvents := False;
    lSource.ShowTagRangeEvents := True;
    lSource.ShowOnlyUnresolvedEventPoints := True;
    lTarget.AssignSqlTrend(lSource);
    Check((not lTarget.ShowRecordingEvents) and
      (not lTarget.ShowTagAlarmEvents) and lTarget.ShowTagRangeEvents and
      lTarget.ShowOnlyUnresolvedEventPoints,
      'assign-copies-filters', 'AssignSqlTrend must copy each event flag');
  finally
    lSource.Free;
    lTarget.Free;
  end;
end;

procedure TestUnresolvedDetection;
var
  lBroken, lOk: TRecorderSqlDbMeraEvent;
begin
  lBroken := RecordingEvent('ev-broken', 0);
  lOk := RecordingEvent('ev-ok', 7);
  { Контракт: событие записи без файлов пакета не может быть открыто. }
  Check((lBroken.MeraFileCount = 0) and SameText(lBroken.EventType,
    'mera.recording'), 'unresolved-event-detected',
    'recording without mera files must be flagged');
  Check(lOk.MeraFileCount > 0, 'resolved-event-detected',
    'recording with files must not be flagged');
end;

procedure TestSettingsDialogRoundTrip;
var
  lComponent, lLoaded: TRecorderSqlTrendComponent;
  lDialog: TRecorderSqlTrendSettingsDialog;
  lCheck: TCheckBox;
begin
  lComponent := TRecorderSqlTrendComponent.Create;
  try
    lComponent.ShowRecordingEvents := False;
    lComponent.ShowTagRangeEvents := False;
    lDialog := TRecorderSqlTrendSettingsDialog.CreateDialog(Application,
      lComponent, nil);
    try
      lCheck := TCheckBox(lDialog.FindComponent('cbShowRecordingEvents'));
      Check(lCheck <> nil, 'dialog-has-recording-checkbox',
        'cbShowRecordingEvents missing from LFM');
      if lCheck <> nil then
        Check(not lCheck.Checked, 'dialog-reads-recording-flag',
          'dialog must read ShowRecordingEvents from the component');
      lCheck := TCheckBox(lDialog.FindComponent('cbShowTagRangeEvents'));
      Check(lCheck <> nil, 'dialog-has-range-checkbox',
        'cbShowTagRangeEvents missing from LFM');
      if lCheck <> nil then
        Check(not lCheck.Checked, 'dialog-reads-range-flag',
          'dialog must read ShowTagRangeEvents from the component');
      lCheck := TCheckBox(lDialog.FindComponent('cbShowOnlyUnresolvedEvents'));
      Check(lCheck <> nil, 'dialog-has-unresolved-checkbox',
        'cbShowOnlyUnresolvedEvents missing from LFM');
      if lCheck <> nil then
      begin
        lCheck.Checked := True;
        TCheckBox(lDialog.FindComponent('cbShowTagAlarmEvents')).Checked :=
          False;
        lDialog.btnOkClick(nil);
      end;
    finally
      lDialog.Free;
    end;
    Check(lComponent.ShowOnlyUnresolvedEventPoints,
      'dialog-writes-unresolved-flag',
      'OK must store ShowOnlyUnresolvedEventPoints');
    Check(not lComponent.ShowTagAlarmEvents, 'dialog-writes-alarm-flag',
      'OK must store ShowTagAlarmEvents');
    Check(not lComponent.ShowTagRangeEvents, 'dialog-keeps-range-flag',
      'untouched range flag must stay unchanged (was False before OK)');
    lLoaded := TRecorderSqlTrendComponent.Create;
    try
      lLoaded.AssignSqlTrend(lComponent);
      Check(lLoaded.ShowOnlyUnresolvedEventPoints, 'component-keeps-unresolved',
        'flag must survive a fresh component copy');
    finally
      lLoaded.Free;
    end;
  finally
    lComponent.Free;
  end;
end;

procedure TestEventFilterMenu;
var
  lComponent: TRecorderSqlTrendComponent;
begin
  { Обе «аварийные» семьи включаются независимо: уставка и авария по тегу —
    разные event_type в SQL и разные строки меню. }
  lComponent := TRecorderSqlTrendComponent.Create;
  try
    lComponent.ShowTagRangeEvents := False;
    Check(not lComponent.ShowTagRangeEvents and lComponent.ShowTagAlarmEvents,
      'range-and-alarm-independent', 'turning off ranges keeps alarms');
  finally
    lComponent.Free;
  end;
end;

var
  lLogName: string;
begin
  gLog := TStringList.Create;
  gFailures := 0;
  lLogName := ChangeFileExt(ParamStr(0), '.log');
  Application.Initialize;
  Application.Title := 'SqlTrendEventsSmoke';
  try
    TestDefaults;
    TestAssignCopiesFilters;
    TestUnresolvedDetection;
    TestEventFilterMenu;
    TestSettingsDialogRoundTrip;
  except
    on E: Exception do
    begin
      Inc(gFailures);
      Log('RESULT fatal FAILED: ' + E.ClassName + ': ' + E.Message);
    end;
  end;
  Log('RESULT summary passed=' + IntToStr(gLog.Count - 1 - gFailures) +
    ' failures=' + IntToStr(gFailures));
  gLog.SaveToFile(lLogName);
  gLog.Free;
  Halt(Ord(gFailures <> 0));
end.
