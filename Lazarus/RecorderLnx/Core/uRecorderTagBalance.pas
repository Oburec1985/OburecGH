unit uRecorderTagBalance;

{
  Виртуальная балансировка нуля для аппаратных тегов.
  Запускает служебный сбор данных по алгоритму узла источника (без режима просмотра).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Dialogs, Controls, StdCtrls, ExtCtrls, Graphics,
  uRecorderTags, uRecorderDataSources, Contnrs;

function RecorderTryZeroBalanceTags(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATags: TList;
  ADataSources: TRecorderDataSourceManager): Boolean;

implementation

type
  { Аппаратная балансировка содержит несколько циклов «ЦАП -> сбор данных».
    Она не должна выполняться в GUI-потоке, иначе LCL перестаёт перерисовывать
    окна и Windows помечает RecorderLnx как зависший. }
  TRecorderZeroBalanceThread = class(TThread)
  private
    // ссылка на интерфейс балансировки конкретного устройства
    fBalance: IRecorderZeroBalanceSupport;
    fDone: LongInt;
    fErrorText: string;
    fMessages: TStringList;
    fResult: Boolean;
    fTags: TList;
    fTrace: TStringList;
    fTraceLock: TRTLCriticalSection;
    procedure Trace(const AText: string);
  protected
    procedure Execute; override;
  public
    constructor Create(const ABalance: IRecorderZeroBalanceSupport;
      ATags: TList);
    destructor Destroy; override;
    function IsDone: Boolean;
    procedure CopyTrace(ADest: TStrings);
    property ErrorText: string read fErrorText;
    property Messages: TStringList read fMessages;
    property Success: Boolean read fResult;
  end;

  TRecorderZeroBalanceProgressForm = class(TForm)
  private
    fLabel: TLabel;
    fLog: TMemo;
    fClose: TButton;
    fTimer: TTimer;
    fWorker: TRecorderZeroBalanceThread;
    procedure TimerTick(Sender: TObject);
  public
    constructor CreateProgress(AOwner: TComponent;      AWorker: TRecorderZeroBalanceThread);
  end;

constructor TRecorderZeroBalanceThread.Create(
  const ABalance: IRecorderZeroBalanceSupport; ATags: TList);
var
  I: Integer;
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fBalance := ABalance;
  fMessages := TStringList.Create;
  fTrace := TStringList.Create;
  InitCriticalSection(fTraceLock);
  fTags := TList.Create;
  if ATags <> nil then
    for I := 0 to ATags.Count - 1 do
      fTags.Add(ATags[I]);
end;

destructor TRecorderZeroBalanceThread.Destroy;
begin
  DoneCriticalSection(fTraceLock);
  fTrace.Free;
  fTags.Free;
  fMessages.Free;
  inherited Destroy;
end;

procedure TRecorderZeroBalanceThread.Trace(const AText: string);
begin
  EnterCriticalSection(fTraceLock);
  try
    fTrace.Add(FormatDateTime('hh:nn:ss.zzz', Now) + '  ' + AText);
  finally
    LeaveCriticalSection(fTraceLock);
  end;
end;

procedure TRecorderZeroBalanceThread.CopyTrace(ADest: TStrings);
begin
  EnterCriticalSection(fTraceLock);
  try
    ADest.Assign(fTrace);
  finally
    LeaveCriticalSection(fTraceLock);
  end;
end;

procedure TRecorderZeroBalanceThread.Execute;
var
  lTraceSupport: IRecorderZeroBalanceTraceSupport;
begin
  try
    { Worker не передаёт LCL-owner устройству: реализация не должна обращаться
      к Screen/Cursor и другим GUI-объектам из фонового потока. }
    if Supports(fBalance, IRecorderZeroBalanceTraceSupport, lTraceSupport) then
      lTraceSupport.SetZeroBalanceTrace(@Trace);
    try
      Trace('Запуск балансировки');
      fResult := fBalance.ZeroBalanceTags(nil, fTags, fMessages);
    finally
      if lTraceSupport <> nil then
        lTraceSupport.SetZeroBalanceTrace(nil);
    end;
  except
    on E: Exception do
    begin
      fResult := False;
      fErrorText := E.Message;
    end;
  end;
  InterlockedExchange(fDone, 1);
end;

function TRecorderZeroBalanceThread.IsDone: Boolean;
begin
  Result := InterlockedCompareExchange(fDone, 0, 0) <> 0;
end;

constructor TRecorderZeroBalanceProgressForm.CreateProgress(AOwner: TComponent;
  AWorker: TRecorderZeroBalanceThread);
begin
  inherited CreateNew(AOwner, 1);
  fWorker := AWorker;
  Caption := 'Балансировка нуля';
  BorderStyle := bsDialog;
  BorderIcons := [];
  Position := poOwnerFormCenter;
  ClientWidth := 390;
  ClientHeight := 260;

  fLabel := TLabel.Create(Self);
  fLabel.Parent := Self;
  fLabel.Align := alTop;
  fLabel.Height := 42;
  fLabel.Alignment := taCenter;
  fLabel.Layout := tlCenter;
  fLabel.Caption := 'Выполняется аппаратная балансировка MC-201...' +
    LineEnding + 'Дождитесь завершения операции.';

  fLog := TMemo.Create(Self);
  fLog.Parent := Self;
  fLog.Align := alClient;
  fLog.ReadOnly := True;
  fLog.ScrollBars := ssAutoVertical;
  fLog.WordWrap := False;

  fClose := TButton.Create(Self);
  fClose.Parent := Self;
  fClose.Align := alBottom;
  fClose.Height := 30;
  fClose.Caption := 'Закрыть';
  fClose.ModalResult := mrOK;
  fClose.Visible := False;

  fTimer := TTimer.Create(Self);
  fTimer.Interval := 50;
  fTimer.OnTimer := @TimerTick;
  fTimer.Enabled := True;
end;

procedure TRecorderZeroBalanceProgressForm.TimerTick(Sender: TObject);
begin
  fWorker.CopyTrace(fLog.Lines);
  fLog.SelStart := Length(fLog.Text);
  if not fWorker.IsDone then
    Exit;
  fTimer.Enabled := False;
  fLabel.Caption := 'Балансировка завершена. Проверьте журнал.';
  fClose.Visible := True;
end;

// запуск балансировки нуля - зависимый от источника данных
function RunZeroBalance(AOwner: TComponent;
  const ABalance: IRecorderZeroBalanceSupport; ATags: TList;
  AMessages: TStrings): Boolean;
var
  lProgress: TRecorderZeroBalanceProgressForm;
  lWorker: TRecorderZeroBalanceThread;
begin
  Result := False;
  lWorker := TRecorderZeroBalanceThread.Create(ABalance, ATags);
  try
    lProgress := TRecorderZeroBalanceProgressForm.CreateProgress(AOwner,
      lWorker);
    try
      lWorker.Start;
      lProgress.ShowModal;
    finally
      lProgress.Free;
    end;
    lWorker.WaitFor;
    if (AMessages <> nil) and (lWorker.Messages.Count > 0) then
      AMessages.AddStrings(lWorker.Messages);
    if (lWorker.ErrorText <> '') and (AMessages <> nil) then
      AMessages.Add(lWorker.ErrorText);
    Result := lWorker.Success;
  finally
    lWorker.Free;
  end;
end;

function RecorderTryZeroBalanceTags(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATags: TList;
  ADataSources: TRecorderDataSourceManager): Boolean;
var
  lSourceIds: TStringList;
  lMessages: TStringList;
  lBalance: IRecorderZeroBalanceSupport;
  lBalanceTags: TList;
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

      lSource := nil;
      if (ADataSources <> nil) then
        lSource := ADataSources.FindSource(lSourceId);
      if (lSource = nil) or (not Supports(lSource, IRecorderZeroBalanceSupport, lBalance)) then
      begin
        Inc(lUnsupported, lBalanceTags.Count);
        Continue;
      end;

      if RunZeroBalance(AOwner, lBalance, lBalanceTags, lMessages) then
        lHandledAny := True;
    end;

    { Успех — без MessageDlg (детали уже в LogWindows). Диалог только при ошибке. }
    if (not lHandledAny) and (lMessages.Count > 0) then
      MessageDlg('Балансировка нуля', lMessages.Text, mtWarning, [mbOK], 0);

    if lHandledAny then
      Result := True
    else if lMessages.Count > 0 then
      Result := False
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
