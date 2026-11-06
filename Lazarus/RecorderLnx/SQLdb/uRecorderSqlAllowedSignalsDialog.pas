unit uRecorderSqlAllowedSignalsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, CheckLst, Dialogs,
  uRecorderSqlDbTypes, uRecorderTagTableExchange;

function EditRecorderSqlAllowedSignals(AOwner: TComponent;
  const ACandidates: TRecorderSqlDbSignalInfos; ASelected: TStrings): Boolean;

implementation

type
  TRecorderSqlAllowedSignalsDialog = class(TForm)
  private
    fCandidates: TRecorderSqlDbSignalInfos;
    fSelected: TStringList;
    fSearch: TEdit;
    fList: TCheckListBox;
    procedure SearchChange(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure SelectNoneClick(Sender: TObject);
    procedure ImportClick(Sender: TObject);
    procedure SyncVisibleChecks;
    procedure RebuildList;
    function CandidateMatches(AIndex: Integer; const AFilter: string): Boolean;
  public
    constructor CreateDialog(AOwner: TComponent;
      const ACandidates: TRecorderSqlDbSignalInfos; ASelected: TStrings);
    destructor Destroy; override;
    procedure CopySelectionTo(ATarget: TStrings);
  end;

constructor TRecorderSqlAllowedSignalsDialog.CreateDialog(AOwner: TComponent;
  const ACandidates: TRecorderSqlDbSignalInfos; ASelected: TStrings);
var
  lButton: TButton;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Разрешённые каналы SQL';
  Position := poOwnerFormCenter;
  BorderStyle := bsSizeable;
  SetBounds(0, 0, 760, 620);
  Constraints.MinWidth := 560;
  Constraints.MinHeight := 420;
  fCandidates := Copy(ACandidates);
  fSelected := TStringList.Create;
  fSelected.CaseSensitive := False;
  fSelected.Sorted := True;
  fSelected.Duplicates := dupIgnore;
  if ASelected <> nil then fSelected.Assign(ASelected);

  with TLabel.Create(Self) do
  begin
    Parent := Self;
    Left := 12;
    Top := 15;
    Caption := 'Поиск:';
  end;
  fSearch := TEdit.Create(Self);
  fSearch.Parent := Self;
  fSearch.SetBounds(70, 10, 676, 26);
  fSearch.Anchors := [akTop, akLeft, akRight];
  fSearch.OnChange := @SearchChange;

  fList := TCheckListBox.Create(Self);
  fList.Parent := Self;
  fList.SetBounds(12, 46, 734, 500);
  fList.Anchors := [akTop, akLeft, akRight, akBottom];

  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(12, 558, 190, 30);
  lButton.Anchors := [akLeft, akBottom];
  lButton.Caption := 'Импортировать из ODS...';
  lButton.OnClick := @ImportClick;

  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(210, 558, 110, 30);
  lButton.Anchors := [akLeft, akBottom];
  lButton.Caption := 'Выбрать все';
  lButton.OnClick := @SelectAllClick;

  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(328, 558, 110, 30);
  lButton.Anchors := [akLeft, akBottom];
  lButton.Caption := 'Снять все';
  lButton.OnClick := @SelectNoneClick;

  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(554, 558, 90, 30);
  lButton.Anchors := [akRight, akBottom];
  lButton.Caption := 'OK';
  lButton.Default := True;
  lButton.ModalResult := mrOk;

  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(652, 558, 94, 30);
  lButton.Anchors := [akRight, akBottom];
  lButton.Caption := 'Отмена';
  lButton.Cancel := True;
  lButton.ModalResult := mrCancel;
  RebuildList;
end;

destructor TRecorderSqlAllowedSignalsDialog.Destroy;
begin
  fSelected.Free;
  inherited Destroy;
end;

function TRecorderSqlAllowedSignalsDialog.CandidateMatches(AIndex: Integer;
  const AFilter: string): Boolean;
var
  lText: string;
begin
  if AFilter = '' then Exit(True);
  lText := LowerCase(fCandidates[AIndex].Name + ' ' +
    fCandidates[AIndex].RecorderAddress + ' ' +
    fCandidates[AIndex].UnitName);
  Result := Pos(AFilter, lText) > 0;
end;

procedure TRecorderSqlAllowedSignalsDialog.SyncVisibleChecks;
var
  lIndex, lCandidateIndex: Integer;
  lName: string;
begin
  for lIndex := 0 to fList.Count - 1 do
  begin
    lCandidateIndex := PtrInt(fList.Items.Objects[lIndex]) - 1;
    if (lCandidateIndex < 0) or
       (lCandidateIndex > High(fCandidates)) then Continue;
    lName := fCandidates[lCandidateIndex].Name;
    if fList.Checked[lIndex] then
    begin
      if fSelected.IndexOf(lName) < 0 then fSelected.Add(lName);
    end
    else if fSelected.IndexOf(lName) >= 0 then
      fSelected.Delete(fSelected.IndexOf(lName));
  end;
end;

procedure TRecorderSqlAllowedSignalsDialog.RebuildList;
var
  lFilter, lCaption: string;
  lIndex, lItemIndex: Integer;
begin
  lFilter := LowerCase(Trim(fSearch.Text));
  fList.Items.BeginUpdate;
  try
    fList.Clear;
    for lIndex := 0 to High(fCandidates) do
    begin
      if not CandidateMatches(lIndex, lFilter) then Continue;
      lCaption := fCandidates[lIndex].Name;
      if Trim(fCandidates[lIndex].RecorderAddress) <> '' then
        lCaption := lCaption + ' | ' + fCandidates[lIndex].RecorderAddress;
      if Trim(fCandidates[lIndex].UnitName) <> '' then
        lCaption := lCaption + ' | ' + fCandidates[lIndex].UnitName;
      lItemIndex := fList.Items.AddObject(lCaption,
        TObject(PtrInt(lIndex + 1)));
      fList.Checked[lItemIndex] :=
        fSelected.IndexOf(fCandidates[lIndex].Name) >= 0;
    end;
  finally
    fList.Items.EndUpdate;
  end;
end;

procedure TRecorderSqlAllowedSignalsDialog.SearchChange(Sender: TObject);
begin
  SyncVisibleChecks;
  RebuildList;
end;

procedure TRecorderSqlAllowedSignalsDialog.SelectAllClick(Sender: TObject);
var
  lIndex: Integer;
begin
  for lIndex := 0 to High(fCandidates) do
    if fSelected.IndexOf(fCandidates[lIndex].Name) < 0 then
      fSelected.Add(fCandidates[lIndex].Name);
  RebuildList;
end;

procedure TRecorderSqlAllowedSignalsDialog.SelectNoneClick(Sender: TObject);
begin
  fSelected.Clear;
  RebuildList;
end;

procedure TRecorderSqlAllowedSignalsDialog.ImportClick(Sender: TObject);
var
  I, lMatched: Integer;
  lFileName, lMessage: string;
  lTableSelected, lTablePresent, lMissing: TStringList;
  lResult: TRecorderSqlSelectionTableResult;
begin
  with TOpenDialog.Create(Self) do
  try
    Title := 'Выберите таблицу каналов';
    Filter := 'Таблицы каналов (*.ods;*.xlsx;*.csv)|*.ods;*.xlsx;*.csv|' +
      'OpenDocument (*.ods)|*.ods|Все файлы|*.*';
    FilterIndex := 1;
    DefaultExt := 'ods';
    if not Execute then Exit;
    lFileName := FileName;
  finally
    Free;
  end;

  lTableSelected := TStringList.Create;
  lTablePresent := TStringList.Create;
  lMissing := TStringList.Create;
  try
    lTableSelected.CaseSensitive := False;
    lTableSelected.Sorted := True;
    lTableSelected.Duplicates := dupIgnore;
    lTablePresent.CaseSensitive := False;
    lTablePresent.Sorted := True;
    lTablePresent.Duplicates := dupIgnore;
    lMissing.CaseSensitive := False;
    lMissing.Sorted := True;
    lMissing.Duplicates := dupIgnore;

    ReadRecorderSqlSignalNamesFromTable(lFileName, lTableSelected,
      lTablePresent, lResult);
    SyncVisibleChecks;
    fSelected.Clear;
    lMatched := 0;
    for I := 0 to High(fCandidates) do
      if lTableSelected.IndexOf(fCandidates[I].Name) >= 0 then
      begin
        fSelected.Add(fCandidates[I].Name);
        Inc(lMatched);
      end;
    for I := 0 to lTableSelected.Count - 1 do
      if fSelected.IndexOf(lTableSelected[I]) < 0 then
        lMissing.Add(lTableSelected[I]);
    RebuildList;

    lMessage := Format(
      'Прочитано строк: %d.%sОтмечено для SQL: %d.%s' +
      'Найдено в базе: %d.%sНет в базе: %d.',
      [lResult.TotalRows, LineEnding, lResult.MarkedRows, LineEnding,
       lMatched, LineEnding, lMissing.Count]);
    if lMissing.Count > 0 then
      lMessage := lMessage + LineEnding + LineEnding +
        'Отсутствуют в signals:' + LineEnding + lMissing.Text;
    MessageDlg('Импорт разрешённых каналов SQL', lMessage,
      mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Ошибка импорта каналов SQL', E.Message,
        mtError, [mbOK], 0);
  end;
  lMissing.Free;
  lTablePresent.Free;
  lTableSelected.Free;
end;

procedure TRecorderSqlAllowedSignalsDialog.CopySelectionTo(ATarget: TStrings);
begin
  SyncVisibleChecks;
  ATarget.Assign(fSelected);
end;

function EditRecorderSqlAllowedSignals(AOwner: TComponent;
  const ACandidates: TRecorderSqlDbSignalInfos; ASelected: TStrings): Boolean;
var
  lDialog: TRecorderSqlAllowedSignalsDialog;
begin
  lDialog := TRecorderSqlAllowedSignalsDialog.CreateDialog(AOwner,
    ACandidates, ASelected);
  try
    Result := lDialog.ShowModal = mrOk;
    if Result then lDialog.CopySelectionTo(ASelected);
  finally
    lDialog.Free;
  end;
end;

end.
