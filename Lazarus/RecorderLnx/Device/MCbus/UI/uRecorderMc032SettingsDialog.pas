unit uRecorderMc032SettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs, Spin,
  uMc032Device, uMc201ProtocolTypes;

function RecorderMc032SourceId(const AHost: string; APort: Word): string;
function TryParseRecorderMc032SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
procedure RecorderMc032ModuleCaptions(const AModulesText: string;
  ACaptions: TStrings);
function ShowRecorderMc032SettingsDialog(AOwner: TComponent;
  const ASourceId, AInitialConfigText: string; out ANewSourceId: string;
  out AModulesText: string): Boolean;

implementation

uses
  StrUtils;

const
  CMc032SourcePrefix = 'MC-032: ';
  CMc032DiscoverySubnet = '192.169.13.';

type
  TRecorderMc032SettingsForm = class(TForm)
  private
    fHostEdit: TEdit;
    fPortEdit: TSpinEdit;
    fModulesMemo: TMemo;
    procedure AutoSearchClick(Sender: TObject);
    procedure TestClick(Sender: TObject);
    procedure ModulesClick(Sender: TObject);
    function ConfigureDevice(ADevice: TMc032Device): Boolean;
    procedure ShowModules(const AModules: TMc201SlotInfoArray);
  public
    constructor Create(AOwner: TComponent); override;
    property HostEdit: TEdit read fHostEdit;
    property PortEdit: TSpinEdit read fPortEdit;
    property ModulesMemo: TMemo read fModulesMemo;
  end;

function RecorderMc032SourceId(const AHost: string; APort: Word): string;
begin
  Result := CMc032SourcePrefix + Trim(AHost) + ':' + IntToStr(APort);
end;

function TryParseRecorderMc032SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
var
  lPos: SizeInt;
  lText: string;
  lPort: Integer;
begin
  Result := False;
  AHost := '';
  APort := CMc201DefaultPort;
  if Pos(CMc032SourcePrefix, ASourceId) <> 1 then
    Exit;
  lText := Trim(Copy(ASourceId, Length(CMc032SourcePrefix) + 1, MaxInt));
  lPos := RPos(':', lText);
  if lPos > 0 then
  begin
    if not TryStrToInt(Copy(lText, lPos + 1, MaxInt), lPort) or
      (lPort < 1) or (lPort > 65535) then
      Exit;
    APort := Word(lPort);
    AHost := Trim(Copy(lText, 1, lPos - 1));
  end
  else
    AHost := lText;
  Result := AHost <> '';
end;

procedure RecorderMc032ModuleCaptions(const AModulesText: string;
  ACaptions: TStrings);
var
  I: Integer;
  lLines: TStringList;
begin
  if ACaptions = nil then
    Exit;
  ACaptions.Clear;
  lLines := TStringList.Create;
  try
    lLines.Text := AModulesText;
    for I := 0 to lLines.Count - 1 do
      if Pos('Слот ', Trim(lLines[I])) = 1 then
        ACaptions.Add(Trim(lLines[I]));
  finally
    lLines.Free;
  end;
end;

constructor TRecorderMc032SettingsForm.Create(AOwner: TComponent);
var
  lButton: TButton;
  lLabel: TLabel;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Контроллер MC-032';
  BorderStyle := bsDialog;
  Position := poOwnerFormCenter;
  ClientWidth := 540;
  ClientHeight := 330;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(16, 18, 80, 20);
  lLabel.Caption := 'IP-адрес:';
  fHostEdit := TEdit.Create(Self);
  fHostEdit.Parent := Self;
  fHostEdit.SetBounds(96, 14, 180, 26);
  fHostEdit.Text := CMc201DefaultHost;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(292, 18, 42, 20);
  lLabel.Caption := 'Порт:';
  fPortEdit := TSpinEdit.Create(Self);
  fPortEdit.Parent := Self;
  fPortEdit.SetBounds(338, 14, 90, 26);
  fPortEdit.MinValue := 1;
  fPortEdit.MaxValue := 65535;
  fPortEdit.Value := CMc201DefaultPort;

  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(16, 52, 150, 30);
  lButton.Caption := 'Автопоиск';
  lButton.OnClick := @AutoSearchClick;
  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(176, 52, 150, 30);
  lButton.Caption := 'Проверить TEST';
  lButton.OnClick := @TestClick;
  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(336, 52, 188, 30);
  lButton.Caption := 'Найти модули по слотам';
  lButton.OnClick := @ModulesClick;

  fModulesMemo := TMemo.Create(Self);
  fModulesMemo.Parent := Self;
  fModulesMemo.SetBounds(16, 94, 508, 180);
  fModulesMemo.ReadOnly := True;
  fModulesMemo.ScrollBars := ssAutoVertical;
  fModulesMemo.Lines.Add('Сначала выполните TEST или поиск модулей.');

  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(350, 286, 82, 30);
  lButton.Caption := 'OK';
  lButton.Default := True;
  lButton.ModalResult := mrOk;
  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(442, 286, 82, 30);
  lButton.Caption := 'Отмена';
  lButton.Cancel := True;
  lButton.ModalResult := mrCancel;
end;

function TRecorderMc032SettingsForm.ConfigureDevice(
  ADevice: TMc032Device): Boolean;
begin
  Result := Trim(fHostEdit.Text) <> '';
  if not Result then
  begin
    MessageDlg('MC-032', 'Укажите IP-адрес контроллера.', mtWarning, [mbOK], 0);
    Exit;
  end;
  ADevice.Host := Trim(fHostEdit.Text);
  ADevice.Port := Word(fPortEdit.Value);
  ADevice.TimeoutMs := 250;
end;

procedure TRecorderMc032SettingsForm.AutoSearchClick(Sender: TObject);
var
  I: Integer;
  lDevice: TMc032Device;
  lError: string;
begin
  Screen.Cursor := crHourGlass;
  try
    lDevice := TMc032Device.Create;
    try
      lDevice.Port := Word(fPortEdit.Value);
      lDevice.TimeoutMs := 35;
      for I := 1 to 254 do
      begin
        lDevice.Host := CMc032DiscoverySubnet + IntToStr(I);
        if lDevice.TestConnection(lError) then
        begin
          fHostEdit.Text := lDevice.Host;
          fModulesMemo.Lines.Text := 'Найден MC-032: ' + lDevice.Host +
            LineEnding + 'Протокольный TEST_LOAD: OK';
          Exit;
        end;
        Application.ProcessMessages;
      end;
      MessageDlg('MC-032', 'Контроллер с поддерживаемым протоколом не найден в ' +
        CMc032DiscoverySubnet + '0/24.', mtWarning, [mbOK], 0);
    finally
      lDevice.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TRecorderMc032SettingsForm.TestClick(Sender: TObject);
var
  lDevice: TMc032Device;
  lError: string;
begin
  lDevice := TMc032Device.Create;
  try
    if not ConfigureDevice(lDevice) then Exit;
    Screen.Cursor := crHourGlass;
    if lDevice.TestConnection(lError) then
      fModulesMemo.Lines.Text := 'Протокольный TEST_LOAD: OK'
    else
      MessageDlg('MC-032', 'Устройство не подтвердило протокол: ' + lError,
        mtError, [mbOK], 0);
  finally
    Screen.Cursor := crDefault;
    lDevice.Free;
  end;
end;

procedure TRecorderMc032SettingsForm.ShowModules(
  const AModules: TMc201SlotInfoArray);
var
  I: Integer;
  lKind: string;
  lSlotSettings: TStringList;
begin
  lSlotSettings := TStringList.Create;
  try
    for I := 0 to fModulesMemo.Lines.Count - 1 do
      if Pos('CFG slot=', Trim(fModulesMemo.Lines[I])) = 1 then
        lSlotSettings.Add(Trim(fModulesMemo.Lines[I]));
    fModulesMemo.Clear;
    if Length(AModules) = 0 then
      fModulesMemo.Lines.Add('Установленные модули не найдены.')
    else
      for I := 0 to High(AModules) do
      begin
        if AModules[I].IsMc201 then lKind := 'MC-201' else lKind := 'не поддерживается';
        fModulesMemo.Lines.Add(Format('Слот %d: %s, type=$%.4x, version=$%.4x, SN=%d',
          [AModules[I].Slot + 1, lKind, AModules[I].TypeId,
           AModules[I].VersionCode, AModules[I].Serial]));
      end;
    fModulesMemo.Lines.AddStrings(lSlotSettings);
  finally
    lSlotSettings.Free;
  end;
end;

procedure TRecorderMc032SettingsForm.ModulesClick(Sender: TObject);
var
  lDevice: TMc032Device;
  lError: string;
  lModules: TMc201SlotInfoArray;
begin
  lDevice := TMc032Device.Create;
  try
    if not ConfigureDevice(lDevice) then Exit;
    Screen.Cursor := crHourGlass;
    if not lDevice.TestConnection(lError) then
    begin
      MessageDlg('MC-032', 'Устройство не подтвердило протокол: ' + lError,
        mtError, [mbOK], 0);
      Exit;
    end;
    if not lDevice.TryConnect(lError) then
    begin
      MessageDlg('MC-032', lError, mtError, [mbOK], 0);
      Exit;
    end;
    if not lDevice.SearchModules(CMc201DefaultMaxSlots, lModules, lError) then
      MessageDlg('MC-032', 'Ошибка поиска модулей: ' + lError, mtError, [mbOK], 0)
    else
      ShowModules(lModules);
  finally
    Screen.Cursor := crDefault;
    lDevice.Free;
  end;
end;

function ShowRecorderMc032SettingsDialog(AOwner: TComponent;
  const ASourceId, AInitialConfigText: string; out ANewSourceId: string;
  out AModulesText: string): Boolean;
var
  lForm: TRecorderMc032SettingsForm;
  lHost: string;
  lPort: Word;
  lDevice: TMc032Device;
  lError: string;
begin
  Result := False;
  ANewSourceId := '';
  AModulesText := '';
  lForm := TRecorderMc032SettingsForm.Create(AOwner);
  try
    if TryParseRecorderMc032SourceId(ASourceId, lHost, lPort) then
    begin
      lForm.HostEdit.Text := lHost;
      lForm.PortEdit.Value := lPort;
    end;
    if Trim(AInitialConfigText) <> '' then
      lForm.ModulesMemo.Lines.Text := AInitialConfigText;
    if lForm.ShowModal <> mrOk then Exit;
    lDevice := TMc032Device.Create;
    try
      if not lForm.ConfigureDevice(lDevice) then Exit;
      if not lDevice.TestConnection(lError) then
      begin
        MessageDlg('MC-032', 'Источник не добавлен: устройство не подтвердило ' +
          'поддерживаемый протокол. ' + lError, mtError, [mbOK], 0);
        Exit;
      end;
    finally
      lDevice.Free;
    end;
    ANewSourceId := RecorderMc032SourceId(lForm.HostEdit.Text,
      Word(lForm.PortEdit.Value));
    AModulesText := lForm.ModulesMemo.Lines.Text;
    Result := True;
  finally
    lForm.Free;
  end;
end;

end.
