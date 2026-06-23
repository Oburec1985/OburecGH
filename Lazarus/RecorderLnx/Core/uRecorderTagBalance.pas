unit uRecorderTagBalance;

{
  Виртуальная балансировка нуля для аппаратных тегов.
  Запускает служебный сбор данных по алгоритму узла источника (без режима просмотра).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Dialogs, uRecorderTags, uRecorderDataSources,
  uRecorderMic140DataSource, uRecorderMic140Utils;

function RecorderTryZeroBalanceTags(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATags: TList;
  ADataSources: TRecorderDataSourceManager): Boolean;

implementation

function RecorderTryZeroBalanceTags(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATags: TList;
  ADataSources: TRecorderDataSourceManager): Boolean;
var
  lSourceIds: TStringList;
  lMessages: TStringList;
  lBalance: IRecorderZeroBalanceSupport;
  lBalanceTags: TList;
  lHost: string;
  lPort: Word;
  lSource: IRecorderDataSource;
  I, J: Integer;
  lTag: TRecorderTag;
  lSourceId: string;
  lHandledAny: Boolean;
  lUnsupported: Integer;
begin
  Result := False;
  if (ATags = nil) or (ATags.Count = 0) then
    Exit;

  lSourceIds := TStringList.Create;
  lMessages := TStringList.Create;
  lBalanceTags := TList.Create;
  try
    lSourceIds.Sorted := True;
    lSourceIds.Duplicates := dupIgnore;
    for I := 0 to ATags.Count - 1 do
    begin
      lTag := TRecorderTag(ATags[I]);
      if Pos('Detached:', lTag.SourceId) = 1 then
        Continue;
      lSourceIds.Add(lTag.SourceId);
    end;

    if lSourceIds.Count = 0 then
    begin
      MessageDlg('Балансировка нуля', 'Нет аппаратных тегов для балансировки.',
        mtInformation, [mbOK], 0);
      Exit;
    end;

    lHandledAny := False;
    lUnsupported := 0;
    for I := 0 to lSourceIds.Count - 1 do
    begin
      lSourceId := lSourceIds[I];
      lBalanceTags.Clear;
      for J := 0 to ATags.Count - 1 do
      begin
        lTag := TRecorderTag(ATags[J]);
        if SameText(lTag.SourceId, lSourceId) then
          lBalanceTags.Add(lTag);
      end;
      if lBalanceTags.Count = 0 then
        Continue;

      if TryParseRecorderMic140SourceId(lSourceId, lHost, lPort) then
      begin
        if RecorderMic140ZeroBalanceTags(AOwner, ARegistry, lBalanceTags,
          ADataSources, lMessages) then
          lHandledAny := True;
        Continue;
      end;

      lSource := nil;
      if (ADataSources <> nil) then
        lSource := ADataSources.FindSource(lSourceId);
      if (lSource = nil) or (not Supports(lSource, IRecorderZeroBalanceSupport, lBalance)) then
      begin
        Inc(lUnsupported, lBalanceTags.Count);
        Continue;
      end;

      if lBalance.ZeroBalanceTags(AOwner, lBalanceTags, lMessages) then
        lHandledAny := True;
    end;

    if lMessages.Count > 0 then
      MessageDlg('Балансировка нуля', lMessages.Text, mtInformation, [mbOK], 0);

    if lHandledAny then
      Result := True
    else if lUnsupported > 0 then
      MessageDlg('Балансировка нуля',
        'Выбранные каналы не поддерживают балансировку нуля на аппаратном уровне.',
        mtInformation, [mbOK], 0)
    else
      MessageDlg('Балансировка нуля', 'Не удалось выполнить балансировку нуля.',
        mtInformation, [mbOK], 0);
  finally
    lBalanceTags.Free;
    lMessages.Free;
    lSourceIds.Free;
  end;
end;

end.
