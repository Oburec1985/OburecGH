unit uRecorderSqlDbSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Spin, ComCtrls,
  LazUTF8, Math, uRecorderSqlDbTypes, uRecorderTags;

type
  TRecorderSqlDbSettingsDialog = class(TForm)
    btnBrowse: TButton;
    btnCancel: TButton;
    btnOk: TButton;
    btnRenameDbSignals: TButton;
    btnStartFirebird: TButton;
    btnTest: TButton;
    btnTestFirebird: TButton;
    btnSelectAll: TButton;
    btnSelectNone: TButton;
    btnAssignEstimate: TButton;
    cbBackend: TComboBox;
    cbControlTag: TComboBox;
    cbEnabled: TCheckBox;
    cbTls: TCheckBox;
    cbSignalEstimate: TComboBox;
    edDatabase: TEdit;
    edHost: TEdit;
    edObjectName: TEdit;
    edObjectType: TEdit;
    edPasswordEnvironment: TEdit;
    edRoot: TEdit;
    edSignalSearch: TEdit;
    edSerial: TEdit;
    edUser: TEdit;
    gbConnection: TGroupBox;
    gbObject: TGroupBox;
    gbSignals: TGroupBox;
    lvSignals: TListView;
    lblBackend: TLabel;
    lblControlTag: TLabel;
    lblDatabase: TLabel;
    lblHost: TLabel;
    lblObjectName: TLabel;
    lblObjectType: TLabel;
    lblPasswordEnvironment: TLabel;
    lblPeriod: TLabel;
    lblPort: TLabel;
    lblQueue: TLabel;
    lblRoot: TLabel;
    lblSerial: TLabel;
    lblSignalSearch: TLabel;
    lblSignalEstimate: TLabel;
    lblUser: TLabel;
    sePeriod: TSpinEdit;
    sePort: TSpinEdit;
    seQueue: TSpinEdit;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnRenameDbSignalsClick(Sender: TObject);
    procedure btnStartFirebirdClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure btnTestFirebirdClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnSelectNoneClick(Sender: TObject);
    procedure btnAssignEstimateClick(Sender: TObject);
    procedure cbBackendChange(Sender: TObject);
    procedure edSignalSearchChange(Sender: TObject);
  private
    fAllSignals: TStringList;
    fCheckedSignals: TStringList;
    fConfig: TRecorderSqlDbConfig;
    fFileName: string;
    fRegistry: TRecorderTagRegistry;
    procedure LoadControls;
    procedure ApplySignalFilter;
    procedure SyncVisibleSignalChecks;
    procedure StoreControls;
    procedure UpdateControls;
    function TryOpenCurrentDatabase(out AMessage: string): Boolean;
    function TryEnsureCurrentDatabase(out AMessage: string): Boolean;
    function TagIsScalar(ATag: TRecorderTag): Boolean;
    function EstimateText(ATag: TRecorderTag;
      AKind: TRecorderTagEstimateKind): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadConfig(const AFileName: string;
      ARegistry: TRecorderTagRegistry);
  end;

function ShowRecorderSqlDbSettings(AOwner: TComponent;
  const AFileName: string; ARegistry: TRecorderTagRegistry): Boolean;

implementation

uses
  uRecorderSqlDbRepository, uRecorderSqlDbFirebirdTools;

{$R *.lfm}

constructor TRecorderSqlDbSettingsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fAllSignals := TStringList.Create;
  fAllSignals.CaseSensitive := False;
  fCheckedSignals := TStringList.Create;
  fCheckedSignals.CaseSensitive := False;
  fCheckedSignals.Sorted := True;
  fCheckedSignals.Duplicates := dupIgnore;
end;

destructor TRecorderSqlDbSettingsDialog.Destroy;
begin
  fCheckedSignals.Free;
  fAllSignals.Free;
  fConfig.Free;
  inherited Destroy;
end;

procedure TRecorderSqlDbSettingsDialog.LoadConfig(const AFileName: string;
  ARegistry: TRecorderTagRegistry);
begin
  fFileName := AFileName;
  fRegistry := ARegistry;
  FreeAndNil(fConfig);
  fConfig := TRecorderSqlDbConfig.Create;
  fConfig.LoadFromFile(AFileName);
  LoadControls;
end;

procedure TRecorderSqlDbSettingsDialog.LoadControls;
var
  I: Integer;
begin
  cbEnabled.Checked := fConfig.Enabled;
  cbBackend.ItemIndex := Ord(fConfig.Backend);
  if Trim(fConfig.RootDirectory) <> '' then
    edRoot.Text := fConfig.RootDirectory
  else
    edRoot.Text := RecorderSqlDbDefaultRootDirectory;
  edDatabase.Text := fConfig.Database;
  edHost.Text := fConfig.Host;
  sePort.Value := fConfig.Port;
  edUser.Text := fConfig.UserName;
  edPasswordEnvironment.Text := fConfig.PasswordEnvironment;
  cbTls.Checked := fConfig.TlsRequired;
  seQueue.Value := fConfig.QueueCapacity;
  sePeriod.Value := Max(1, (fConfig.RecordPeriodMs + 999) div 1000);
  edObjectName.Text := fConfig.ObjectName;
  edObjectType.Text := fConfig.ObjectType;
  edSerial.Text := fConfig.SerialNumber;
  cbControlTag.Items.BeginUpdate;
  try
    cbControlTag.Items.Clear;
    cbControlTag.Items.Add('(нет)');
    if fRegistry <> nil then
      for I := 0 to fRegistry.TagCount - 1 do
        cbControlTag.Items.Add(fRegistry.Tags[I].Name);
    cbControlTag.ItemIndex := cbControlTag.Items.IndexOf(fConfig.ControlTagName);
    if cbControlTag.ItemIndex < 0 then cbControlTag.ItemIndex := 0;
  finally
    cbControlTag.Items.EndUpdate;
  end;
  edSignalSearch.Clear;
  cbSignalEstimate.Items.Clear;
  for I := Ord(Low(TRecorderTagEstimateKind)) to
    Ord(High(TRecorderTagEstimateKind)) do
    cbSignalEstimate.Items.Add(RecorderTagEstimateKindToName(
      TRecorderTagEstimateKind(I)));
  cbSignalEstimate.ItemIndex := Ord(tekMean);
  fAllSignals.Clear;
  fCheckedSignals.Clear;
  lvSignals.Clear;
  if fRegistry <> nil then
    for I := 0 to fRegistry.TagCount - 1 do
    begin
      fAllSignals.AddObject(fRegistry.Tags[I].Name, fRegistry.Tags[I]);
      if not fConfig.SignalSelectionConfigured or
         (fConfig.SignalNames.IndexOf(fRegistry.Tags[I].Name) >= 0) then
        fCheckedSignals.Add(fRegistry.Tags[I].Name);
    end;
  ApplySignalFilter;
  UpdateControls;
end;

procedure TRecorderSqlDbSettingsDialog.SyncVisibleSignalChecks;
var
  I, lCheckedIndex: Integer;
begin
  for I := 0 to lvSignals.Items.Count - 1 do
    if lvSignals.Items[I].Checked then
    begin
      if fCheckedSignals.IndexOf(lvSignals.Items[I].Caption) < 0 then
        fCheckedSignals.Add(lvSignals.Items[I].Caption);
    end
    else
    begin
      lCheckedIndex := fCheckedSignals.IndexOf(lvSignals.Items[I].Caption);
      if lCheckedIndex >= 0 then
        fCheckedSignals.Delete(lCheckedIndex);
    end;
end;

procedure TRecorderSqlDbSettingsDialog.ApplySignalFilter;
var
  I: Integer;
  lFilter, lName: string;
  lItem: TListItem;
  lTag: TRecorderTag;
  lKind: TRecorderTagEstimateKind;
begin
  lFilter := UTF8LowerCase(Trim(edSignalSearch.Text));
  lvSignals.Items.BeginUpdate;
  try
    lvSignals.Clear;
    for I := 0 to fAllSignals.Count - 1 do
    begin
      lName := fAllSignals[I];
      if (lFilter <> '') and
         (Pos(lFilter, UTF8LowerCase(lName)) = 0) then
        Continue;
      lTag := TRecorderTag(fAllSignals.Objects[I]);
      lKind := fConfig.SignalEstimate(lName);
      if TagIsScalar(lTag) then lKind := tekMean;
      lItem := lvSignals.Items.Add;
      lItem.Caption := lName;
      lItem.Data := lTag;
      lItem.Checked := fCheckedSignals.IndexOf(lName) >= 0;
      lItem.SubItems.Add(EstimateText(lTag, lKind));
    end;
  finally
    lvSignals.Items.EndUpdate;
  end;
end;

procedure TRecorderSqlDbSettingsDialog.edSignalSearchChange(Sender: TObject);
begin
  SyncVisibleSignalChecks;
  ApplySignalFilter;
end;

procedure TRecorderSqlDbSettingsDialog.StoreControls;
var
  I: Integer;
begin
  SyncVisibleSignalChecks;
  fConfig.Enabled := cbEnabled.Checked;
  if cbBackend.ItemIndex >= 0 then
    fConfig.Backend := TRecorderSqlDbBackend(cbBackend.ItemIndex);
  fConfig.RootDirectory := Trim(edRoot.Text);
  fConfig.Database := Trim(edDatabase.Text);
  fConfig.Host := Trim(edHost.Text);
  fConfig.Port := sePort.Value;
  fConfig.UserName := Trim(edUser.Text);
  fConfig.PasswordEnvironment := Trim(edPasswordEnvironment.Text);
  fConfig.TlsRequired := cbTls.Checked;
  fConfig.QueueCapacity := seQueue.Value;
  fConfig.RecordPeriodMs := sePeriod.Value * 1000;
  fConfig.ObjectName := Trim(edObjectName.Text);
  fConfig.ObjectType := Trim(edObjectType.Text);
  fConfig.SerialNumber := Trim(edSerial.Text);
  if cbControlTag.ItemIndex > 0 then
    fConfig.ControlTagName := cbControlTag.Text
  else
    fConfig.ControlTagName := '';
  fConfig.SignalNames.Clear;
  fConfig.SignalSelectionConfigured := True;
  for I := 0 to fCheckedSignals.Count - 1 do
    fConfig.SignalNames.Add(fCheckedSignals[I]);
  fConfig.RequireValid;
end;

procedure TRecorderSqlDbSettingsDialog.UpdateControls;
var
  lFirebird, lRemote: Boolean;
begin
  lFirebird := cbBackend.ItemIndex = Ord(rsbFirebird);
  lRemote := (cbBackend.ItemIndex <> Ord(rsbSQLite)) and
    (Trim(edHost.Text) <> '');
  edHost.Enabled := cbBackend.ItemIndex <> Ord(rsbSQLite);
  sePort.Enabled := edHost.Enabled;
  edUser.Enabled := edHost.Enabled;
  edPasswordEnvironment.Enabled := edHost.Enabled;
  cbTls.Enabled := lRemote;
  btnTestFirebird.Enabled := lFirebird;
  btnStartFirebird.Enabled := lFirebird and
    RecorderSqlDbFirebirdHostIsLocal(edHost.Text);
  if edHost.Enabled then
    lblHost.Caption := 'Хост БД (пусто = локально)'
  else
    lblHost.Caption := 'Хост БД';
end;

function TRecorderSqlDbSettingsDialog.TryOpenCurrentDatabase(
  out AMessage: string): Boolean;
var
  R: TRecorderSqlDbRepository;
begin
  Result := False;
  try
    StoreControls;
    R := TRecorderSqlDbRepository.Create(fConfig);
    try
      R.Open;
      AMessage := 'Подключение к SQL БД успешно открыто.';
      Result := True;
    finally
      R.Free;
    end;
  except
    on E: Exception do
      AMessage := E.Message;
  end;
end;

function TRecorderSqlDbSettingsDialog.TryEnsureCurrentDatabase(
  out AMessage: string): Boolean;
var
  R: TRecorderSqlDbRepository;
begin
  Result := False;
  try
    StoreControls;
    R := TRecorderSqlDbRepository.Create(fConfig);
    try
      R.EnsureDatabase;
      AMessage := 'Подключение успешно. Схема создана/проверена.';
      Result := True;
    finally
      R.Free;
    end;
  except
    on E: Exception do
      AMessage := E.Message;
  end;
end;

procedure TRecorderSqlDbSettingsDialog.cbBackendChange(Sender: TObject);
begin
  if cbBackend.ItemIndex = Ord(rsbFirebird) then
  begin
    if edDatabase.Text = CRecorderSqlDbDefaultFileName then
      edDatabase.Text := CRecorderFirebirdDefaultFileName;
    if sePort.Value = 0 then sePort.Value := 3050;
  end;
  UpdateControls;
end;

procedure TRecorderSqlDbSettingsDialog.btnTestFirebirdClick(Sender: TObject);
var
  lPort: Word;
  lDetails, lMessage: string;
begin
  if (cbBackend.ItemIndex = Ord(rsbFirebird)) and
    (Trim(edHost.Text) = '') then
  begin
    if TryOpenCurrentDatabase(lMessage) then
      MessageDlg('Firebird',
        'Firebird доступен через локальное подключение к БД.' + LineEnding +
        lMessage,
        mtInformation, [mbOK], 0)
    else
      MessageDlg('Firebird',
        'Не удалось открыть локальное подключение Firebird.' + LineEnding +
        lMessage,
        mtWarning, [mbOK], 0);
    Exit;
  end;
  lPort := sePort.Value;
  if lPort = 0 then
    lPort := 3050;
  if RecorderSqlDbFirebirdTcpAvailable(edHost.Text, lPort, 1200,
    lMessage) then
    MessageDlg('Firebird', lMessage, mtInformation, [mbOK], 0)
  else
  begin
    if RecorderSqlDbFirebirdHostIsLocal(edHost.Text) then
      lDetails := LineEnding + LineEnding +
        RecorderSqlDbDescribeLocalFirebird(lPort)
    else
      lDetails := '';
    MessageDlg('Firebird',
      lMessage + LineEnding +
      'Для локального сервера можно попробовать кнопку "Запустить Firebird".' +
      lDetails,
      mtWarning, [mbOK], 0);
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnStartFirebirdClick(Sender: TObject);
var
  I: Integer;
  lPort: Word;
  lMessage, lProbeMessage: string;
  lUseDbOpenCheck: Boolean;
begin
  if not RecorderSqlDbFirebirdHostIsLocal(edHost.Text) then
  begin
    MessageDlg('Firebird',
      'Запуск поддержан только для локального Firebird. Для удаленного host ' +
      'службу нужно запускать на сервере БД.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lPort := sePort.Value;
  if lPort = 0 then
    lPort := 3050;
  lUseDbOpenCheck := Trim(edHost.Text) = '';
  if RecorderSqlDbStartLocalFirebird(lMessage) then
  begin
    for I := 0 to 9 do
    begin
      if lUseDbOpenCheck then
      begin
        if TryOpenCurrentDatabase(lProbeMessage) then
        begin
          MessageDlg('Firebird', 'Firebird запущен, локальная БД доступна.',
            mtInformation, [mbOK], 0);
          Exit;
        end;
      end
      else if RecorderSqlDbFirebirdTcpAvailable(edHost.Text, lPort, 700,
        lProbeMessage) then
      begin
        MessageDlg('Firebird', lProbeMessage, mtInformation, [mbOK], 0);
        Exit;
      end;
      Sleep(500);
      Application.ProcessMessages;
    end;
  end;
  if lUseDbOpenCheck and TryOpenCurrentDatabase(lProbeMessage) then
    MessageDlg('Firebird', 'Локальная БД Firebird доступна.',
      mtInformation, [mbOK], 0)
  else if RecorderSqlDbFirebirdTcpAvailable(edHost.Text, lPort, 1500,
    lProbeMessage) then
    MessageDlg('Firebird', lProbeMessage, mtInformation, [mbOK], 0)
  else
    MessageDlg('Firebird', lMessage + LineEnding + LineEnding +
      RecorderSqlDbDescribeLocalFirebird(lPort),
      mtWarning, [mbOK], 0);
end;

procedure TRecorderSqlDbSettingsDialog.btnBrowseClick(Sender: TObject);
var D: string;
begin
  D := edRoot.Text;
  if Trim(D) = '' then
    D := RecorderSqlDbDefaultRootDirectory;
  if SelectDirectory('Каталог SQL БД и файлов данных', '', D) then edRoot.Text := D;
end;

procedure TRecorderSqlDbSettingsDialog.btnTestClick(Sender: TObject);
var
  I: Integer;
  lFirstError, lMessage: string;
  lPort: Word;
begin
  if TryEnsureCurrentDatabase(lMessage) then
  begin
    MessageDlg('SQL БД', lMessage, mtInformation, [mbOK], 0);
    Exit;
  end;
  lFirstError := lMessage;
  if (fConfig.Backend = rsbFirebird) and
    RecorderSqlDbFirebirdHostIsLocal(fConfig.Host) then
  begin
    lPort := fConfig.Port;
    if lPort = 0 then
      lPort := 3050;
    if Trim(fConfig.Host) <> '' then
    begin
      if not RecorderSqlDbFirebirdTcpAvailable(fConfig.Host, lPort, 500,
        lMessage) then
        RecorderSqlDbStartLocalFirebird(lMessage);
    end
    else
      RecorderSqlDbStartLocalFirebird(lMessage);
    for I := 0 to 9 do
    begin
      if TryEnsureCurrentDatabase(lMessage) then
      begin
        MessageDlg('SQL БД', lMessage, mtInformation, [mbOK], 0);
        Exit;
      end;
      Sleep(500);
      Application.ProcessMessages;
    end;
  end;
  MessageDlg('Ошибка SQL БД',
    lFirstError + LineEnding + LineEnding + 'После попытки запуска Firebird:' +
    LineEnding + lMessage,
    mtError, [mbOK], 0);
end;

procedure TRecorderSqlDbSettingsDialog.btnRenameDbSignalsClick(Sender: TObject);
var
  I, lRenamed: Integer;
  lObjectId: string;
  lRepository: TRecorderSqlDbRepository;
  lTag: TRecorderTag;
begin
  if fRegistry = nil then Exit;
  try
    StoreControls;
    lRenamed := 0;
    lRepository := TRecorderSqlDbRepository.Create(fConfig);
    try
      lRepository.EnsureDatabase;
      lObjectId := lRepository.EnsureObject(fConfig.ObjectName,
        fConfig.ObjectType, fConfig.SerialNumber);
      for I := 0 to fRegistry.TagCount - 1 do
      begin
        lTag := fRegistry.Tags[I];
        if (lTag = nil) or (Trim(lTag.Address) = '') then Continue;
        if lRepository.RenameSignalByRecorderAddress(lObjectId,
          lTag.SourceId, lTag.Address, lTag.Name, lTag.UnitName) then
          Inc(lRenamed);
      end;
    finally
      lRepository.Free;
    end;
    MessageDlg('SQL БД',
      Format('Имена каналов в БД синхронизированы: %d.', [lRenamed]),
      mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Ошибка SQL БД', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnSelectAllClick(Sender: TObject);
var I: Integer;
begin
  for I := 0 to lvSignals.Items.Count - 1 do
  begin
    lvSignals.Items[I].Checked := True;
    if fCheckedSignals.IndexOf(lvSignals.Items[I].Caption) < 0 then
      fCheckedSignals.Add(lvSignals.Items[I].Caption);
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnSelectNoneClick(Sender: TObject);
var
  I: Integer;
  lCheckedIndex: Integer;
  lFirstSelected: TListItem;
  lItem: TListItem;
  lSelectedNames: TStringList;
  lTargetChecked: Boolean;
begin
  lSelectedNames := TStringList.Create;
  try
    lSelectedNames.CaseSensitive := False;
    lSelectedNames.Sorted := True;
    lSelectedNames.Duplicates := dupIgnore;
    lTargetChecked := False;
    for I := 0 to lvSignals.Items.Count - 1 do
    begin
      lItem := lvSignals.Items[I];
      if not lItem.Selected then Continue;
      lSelectedNames.Add(lItem.Caption);
      if not lItem.Checked then
        lTargetChecked := True;
    end;
    if lSelectedNames.Count = 0 then Exit;
    lvSignals.Items.BeginUpdate;
    try
      for I := 0 to lvSignals.Items.Count - 1 do
      begin
        lItem := lvSignals.Items[I];
        if lSelectedNames.IndexOf(lItem.Caption) < 0 then Continue;
        lItem.Checked := lTargetChecked;
        lCheckedIndex := fCheckedSignals.IndexOf(lItem.Caption);
        if lTargetChecked then
        begin
          if lCheckedIndex < 0 then
            fCheckedSignals.Add(lItem.Caption);
        end
        else if lCheckedIndex >= 0 then
          fCheckedSignals.Delete(lCheckedIndex);
      end;
      lFirstSelected := nil;
      for I := 0 to lvSignals.Items.Count - 1 do
      begin
        lItem := lvSignals.Items[I];
        lItem.Selected := lSelectedNames.IndexOf(lItem.Caption) >= 0;
        if lItem.Selected and (lFirstSelected = nil) then
          lFirstSelected := lItem;
      end;
    finally
      lvSignals.Items.EndUpdate;
    end;
    if lFirstSelected <> nil then
    begin
      if lvSignals.CanFocus then
        lvSignals.SetFocus;
      lFirstSelected.Focused := True;
      lFirstSelected.MakeVisible(False);
    end;
  finally
    lSelectedNames.Free;
  end;
end;

function TRecorderSqlDbSettingsDialog.TagIsScalar(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag = nil) or (ATag.PollFrequencyHz <= 0) or
    (ATag.IsVirtual and (not ATag.IsVector));
end;

function TRecorderSqlDbSettingsDialog.EstimateText(ATag: TRecorderTag;
  AKind: TRecorderTagEstimateKind): string;
begin
  if TagIsScalar(ATag) then
    Result := RecorderTagEstimateKindToName(tekMean) + ' (scalar)'
  else
    Result := RecorderTagEstimateKindToName(AKind);
end;

procedure TRecorderSqlDbSettingsDialog.btnAssignEstimateClick(Sender: TObject);
var
  I: Integer;
  lItem: TListItem;
  lTag: TRecorderTag;
  lKind: TRecorderTagEstimateKind;
begin
  if cbSignalEstimate.ItemIndex < 0 then Exit;
  lKind := TRecorderTagEstimateKind(cbSignalEstimate.ItemIndex);
  for I := 0 to lvSignals.Items.Count - 1 do
  begin
    lItem := lvSignals.Items[I];
    if not lItem.Selected then Continue;
    lTag := TRecorderTag(lItem.Data);
    if TagIsScalar(lTag) then
      fConfig.SetSignalEstimate(lItem.Caption, tekMean)
    else
      fConfig.SetSignalEstimate(lItem.Caption, lKind);
    lItem.SubItems[0] := EstimateText(lTag,
      fConfig.SignalEstimate(lItem.Caption));
  end;
end;

procedure TRecorderSqlDbSettingsDialog.btnOkClick(Sender: TObject);
begin
  StoreControls;
  fConfig.SaveToFile(fFileName);
  ModalResult := mrOk;
end;

function ShowRecorderSqlDbSettings(AOwner: TComponent;
  const AFileName: string; ARegistry: TRecorderTagRegistry): Boolean;
var D: TRecorderSqlDbSettingsDialog;
begin
  D := TRecorderSqlDbSettingsDialog.Create(AOwner);
  try
    D.LoadConfig(AFileName, ARegistry);
    Result := D.ShowModal = mrOk;
  finally D.Free; end;
end;

end.
