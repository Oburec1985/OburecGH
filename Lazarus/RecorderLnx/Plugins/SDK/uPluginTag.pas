unit uPluginTag;

{$mode objfpc}{$H+}{$codepage UTF8}

{ Общая чтительная часть тега плагина. Имена и назначение класса соотносятся
  с cTag исходного Recorder, но здесь реализовано только копирование снимка
  диапазона или последнего временного окна через плоские сервисы RLNX.
  Это не блочное чтение с независимым курсором: ABI пока не сообщает номера
  отсчётов и не позволяет надёжно обнаруживать потерю данных или новую эпоху.
  Уведомление о новых данных само по себе не копирует историю: компонент
  сначала проверяет собственные триггеры и критерии и сам решает, когда и
  какой диапазон запросить. Массивы заранее готовит вызывающий; методы их
  не растят. }
interface

uses SysUtils, Math, uRecorderVisualComponentApiV2;

type
  TPluginDoubleArray = array of Double;
  EPluginDataRead = class(Exception);
  cTag = class
  private
    procedure AcceptRead(AStatus: LongInt; ARequired, ACapacity: LongWord;
      out ACount: Integer);
  protected
    fServices: PRecorderVisualHostServicesV2;
  public
    Id: QWord;
    constructor Create(AServices: PRecorderVisualHostServicesV2; AId: QWord);
    procedure CopyLatestInto(AWindowSeconds: Double;
      var ATimes, AValues: TPluginDoubleArray; out ACount: Integer;
      out ADisplayStart: Double); overload;
    procedure CopyLatestInto(AWindowSeconds: Double;
      var ATimes, AValues: TPluginDoubleArray; out ACount: Integer;
      out ADisplayStart: Double; out ARevision: QWord); overload;
    procedure SnapshotRangeInto(AFromTimeSec: Double; AIncludePrevious: Boolean;
      var ATimes, AValues: TPluginDoubleArray; out ACount: Integer;
      AToTimeSec: Double = MaxDouble);
  end;

implementation

uses uPluginTagServices;

constructor cTag.Create(AServices: PRecorderVisualHostServicesV2; AId: QWord);
begin
  inherited Create;
  fServices := AServices;
  Id := AId;
end;

procedure cTag.AcceptRead(AStatus: LongInt; ARequired, ACapacity: LongWord;
  out ACount: Integer);
begin
  ACount := 0;
  if AStatus = REC_VISUAL_NOT_FOUND then Exit;
  if AStatus = REC_VISUAL_BUFFER_TOO_SMALL then
    raise EPluginDataRead.CreateFmt('History capacity %d required; prepared %d',
      [ARequired, ACapacity]);
  if (AStatus <> REC_VISUAL_OK) or (ARequired > ACapacity) then
    raise EPluginDataRead.CreateFmt('History callback status %d', [AStatus]);
  ACount := ARequired;
end;

procedure cTag.CopyLatestInto(AWindowSeconds: Double;
  var ATimes, AValues: TPluginDoubleArray; out ACount: Integer;
  out ADisplayStart: Double);
var lRevision: QWord;
begin
  CopyLatestInto(AWindowSeconds, ATimes, AValues, ACount, ADisplayStart, lRevision);
end;

procedure cTag.CopyLatestInto(AWindowSeconds: Double;
  var ATimes, AValues: TPluginDoubleArray; out ACount: Integer;
  out ADisplayStart: Double; out ARevision: QWord);
var lTimes, lValues: PDouble; lCapacity, lCount: LongWord;
  lLatest: Double; lStatus: LongInt;
begin
  if not PluginTagServicesAvailable(fServices) then
    raise EPluginDataRead.Create('Latest history service unavailable');
  lTimes := nil; lValues := nil; lCapacity := Min(Length(ATimes), Length(AValues));
  if lCapacity > 0 then begin lTimes := @ATimes[0]; lValues := @AValues[0]; end;
  lStatus := fServices^.CopyLatestHistory(fServices^.Context, Id, AWindowSeconds,
    lTimes, lValues, lCapacity, lCount, ARevision, ADisplayStart, lLatest);
  AcceptRead(lStatus, lCount, lCapacity, ACount);
end;

procedure cTag.SnapshotRangeInto(AFromTimeSec: Double; AIncludePrevious: Boolean;
  var ATimes, AValues: TPluginDoubleArray; out ACount: Integer; AToTimeSec: Double);
var lTimes, lValues: PDouble; lCapacity, lCount: LongWord;
  lLatest, lStart: Double; lRevision: QWord; lStatus: LongInt;
begin
  if not PluginTagServicesAvailable(fServices) or
    (fServices^.Header.Size < SizeOf(TRecorderVisualHostServicesV2)) or
    not Assigned(fServices^.CopyRangeHistory) then
    raise EPluginDataRead.Create('Range history service unavailable');
  lTimes := nil; lValues := nil; lCapacity := Min(Length(ATimes), Length(AValues));
  if lCapacity > 0 then begin lTimes := @ATimes[0]; lValues := @AValues[0]; end;
  lStatus := fServices^.CopyRangeHistory(fServices^.Context, Id, AFromTimeSec,
    AToTimeSec, Ord(AIncludePrevious), lTimes, lValues, lCapacity, lCount,
    lRevision, lStart, lLatest);
  AcceptRead(lStatus, lCount, lCapacity, ACount);
end;

end.
