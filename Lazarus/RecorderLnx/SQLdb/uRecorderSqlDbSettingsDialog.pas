unit uRecorderSqlDbSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Spin, ComCtrls,
  LazUTF8, uRecorderSqlDbTypes, uRecorderTags;

type
  TRecorderSqlDbSettingsDialog = class(TForm)
    btnBrowse: TButton;
    btnCancel: TButton;
    btnOk: TButton;
    btnTest: TButton;
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
    procedure btnTestClick(Sender: TObject);
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
  uRecorderSqlDbRepository;

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
  edRoot.Text := fConfig.RootDirectory;
  edDatabase.Text := fConfig.Database;
  edHost.Text := fConfig.Host;
  sePort.Value := fConfig.Port;
  edUser.Text := fConfig.UserName;
  edPasswordEnvironment.Text := fConfig.PasswordEnvironment;
  cbTls.Checked := fConfig.TlsRequired;
  seQueue.Value := fConfig.QueueCapacity;
  sePeriod.Value := fConfig.RecordPeriodMs;
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
  fConfig.RecordPeriodMs := sePeriod.Value;
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
var lRemote: Boolean;
begin
  lRemote := (cbBackend.ItemIndex <> Ord(rsbSQLite)) and
    (Trim(edHost.Text) <> '');
  edHost.Enabled := cbBackend.ItemIndex <> Ord(rsbSQLite);
  sePort.Enabled := edHost.Enabled;
  edUser.Enabled := edHost.Enabled;
  edPasswordEnvironment.Enabled := edHost.Enabled;
  cbTls.Enabled := lRemote;
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

procedure TRecorderSqlDbSettingsDialog.btnBrowseClick(Sender: TObject);
var D: string;
begin
  D := edRoot.Text;
  if SelectDirectory('Каталог SQL БД и файлов данных', '', D) then edRoot.Text := D;
end;

procedure TRecorderSqlDbSettingsDialog.btnTestClick(Sender: TObject);
var R: TRecorderSqlDbRepository;
begin
  try
    StoreControls;
    R := TRecorderSqlDbRepository.Create(fConfig);
    try
      R.EnsureDatabase;
      MessageDlg('SQL БД', 'Подключение успешно. Схема создана/проверена.',
        mtInformation, [mbOK], 0);
    finally R.Free; end;
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
var I, lCheckedIndex: Integer;
begin
  for I := 0 to lvSignals.Items.Count - 1 do
  begin
    lvSignals.Items[I].Checked := False;
    lCheckedIndex := fCheckedSignals.IndexOf(lvSignals.Items[I].Caption);
    if lCheckedIndex >= 0 then
      fCheckedSignals.Delete(lCheckedIndex);
  end;
end;

function TRecorderSqlDbSettingsDialog.TagIsScalar(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag = nil) or ATag.IsVirtual or (ATag.PollFrequencyHz <= 0);
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
