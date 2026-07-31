unit uRecorderSqlDbSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Spin, CheckLst,
  uRecorderSqlDbTypes, uRecorderTags;

type
  TRecorderSqlDbSettingsDialog = class(TForm)
    btnBrowse: TButton;
    btnCancel: TButton;
    btnOk: TButton;
    btnTest: TButton;
    btnSelectAll: TButton;
    btnSelectNone: TButton;
    cbBackend: TComboBox;
    cbEnabled: TCheckBox;
    cbTls: TCheckBox;
    edDatabase: TEdit;
    edHost: TEdit;
    edObjectName: TEdit;
    edObjectType: TEdit;
    edPasswordEnvironment: TEdit;
    edRoot: TEdit;
    edSerial: TEdit;
    edUser: TEdit;
    gbConnection: TGroupBox;
    gbObject: TGroupBox;
    gbSignals: TGroupBox;
    clbSignals: TCheckListBox;
    lblBackend: TLabel;
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
    lblUser: TLabel;
    sePeriod: TSpinEdit;
    sePort: TSpinEdit;
    seQueue: TSpinEdit;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnSelectNoneClick(Sender: TObject);
    procedure cbBackendChange(Sender: TObject);
  private
    fConfig: TRecorderSqlDbConfig;
    fFileName: string;
    fRegistry: TRecorderTagRegistry;
    procedure LoadControls;
    procedure StoreControls;
    procedure UpdateControls;
  public
    procedure LoadConfig(const AFileName: string;
      ARegistry: TRecorderTagRegistry);
  end;

function ShowRecorderSqlDbSettings(AOwner: TComponent;
  const AFileName: string; ARegistry: TRecorderTagRegistry): Boolean;

implementation

uses
  uRecorderSqlDbRepository;

{$R *.lfm}

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
  I, lIndex: Integer;
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
  clbSignals.Clear;
  if fRegistry <> nil then
    for I := 0 to fRegistry.TagCount - 1 do
    begin
      lIndex := clbSignals.Items.Add(fRegistry.Tags[I].Name);
      clbSignals.Checked[lIndex] := not fConfig.SignalSelectionConfigured or
        (fConfig.SignalNames.IndexOf(fRegistry.Tags[I].Name) >= 0);
    end;
  UpdateControls;
end;

procedure TRecorderSqlDbSettingsDialog.StoreControls;
var
  I: Integer;
begin
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
  fConfig.SignalNames.Clear;
  fConfig.SignalSelectionConfigured := True;
  for I := 0 to clbSignals.Items.Count - 1 do
    if clbSignals.Checked[I] then
      fConfig.SignalNames.Add(clbSignals.Items[I]);
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
  for I := 0 to clbSignals.Items.Count - 1 do clbSignals.Checked[I] := True;
end;

procedure TRecorderSqlDbSettingsDialog.btnSelectNoneClick(Sender: TObject);
var I: Integer;
begin
  for I := 0 to clbSignals.Items.Count - 1 do clbSignals.Checked[I] := False;
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
