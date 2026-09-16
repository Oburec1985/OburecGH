unit uLinuxSetupManagerSystemDialogs;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, StrUtils, Forms, Process, ExtCtrls;

procedure ShowNetworkDialog(AOwner: TComponent);
procedure ShowProxyDialog(AOwner: TComponent);
procedure ShowAccessDialog(AOwner: TComponent);
procedure ShowTimeDialog(AOwner: TComponent);
procedure ShowSshDialog(AOwner: TComponent);
procedure ShowProfileDialog(AOwner: TComponent);
procedure ShowDiskDialog(AOwner: TComponent);

implementation

uses
  Controls, StdCtrls, Dialogs, ComCtrls,
  fpjson, jsonparser
  {$IFDEF LCLGTK2}, Gtk2, Gtk2Def, Gtk2Proc, Gtk2WSComCtrls{$ENDIF};

const
  CHelperRoot = '/usr/local/sbin/';
  CNetworkHelper = CHelperRoot + 'recorderlnx-configure-network';
  CProxyHelper = CHelperRoot + 'recorderlnx-configure-proxy';
  CAccessHelper = CHelperRoot + 'recorderlnx-manage-access';
  CTimeHelper = CHelperRoot + 'recorderlnx-configure-time';
  CSshHelper = CHelperRoot + 'recorderlnx-manage-ssh';
  CProfileHelper = CHelperRoot + 'recorderlnx-manage-profile';
  CDiskHelper = CHelperRoot + 'recorderlnx-manage-disks';

type
  TSetupKind = (skNetwork, skProxy, skAccess, skTime, skSsh, skProfile, skDisk);

  TSetupDialog = class(TForm)
  private
    fKind: TSetupKind;
    fFields: array of TEdit;
    fChecks: array of TCheckBox;
    fInputMemo: TMemo;
    fOutputMemo: TMemo;
    fPage: TScrollBox;
    fButtons: TPanel;
    fPhysicalPanel: TPanel;
    fPartitionPanel: TPanel;
    fPhysicalList: TListView;
    fDiskList: TListView;
    fDiskJson: TJSONData;
    fDiskDetails: TMemo;
    fDetailsHandle: TPanel;
    fOutputHandle: TPanel;
    fActiveDiskHandle: TPanel;
    fDragStartY: Integer;
    fDragStartHeight: Integer;
    fDiskFsCombo: TComboBox;
    fDiskProcess: TProcess;
    fDiskTimer: TTimer;
    fDiskOutput: UTF8String;
    fDiskStarted: QWord;
    fDiskPhase: Integer;
    fNextY: Integer;
    function AddField(const ACaption, ADefault: string;
      APassword: Boolean = False): TEdit;
    function AddCheck(const ACaption: string; AChecked: Boolean): TCheckBox;
    function AddMemo(const ACaption: string): TMemo;
    procedure AddButton(const ACaption: string; ALeft: Integer;
      AClick: TNotifyEvent);
    procedure BuildNetwork;
    procedure BuildProxy;
    procedure BuildAccess;
    procedure BuildTime;
    procedure BuildSsh;
    procedure BuildProfile;
    procedure BuildDisk;
    procedure DiskListClick(Sender: TObject);
    procedure DiskItemSelect(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure PhysicalDiskClick(Sender: TObject);
    procedure PhysicalDiskSelect(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ShowPhysicalDisk(const APath: string);
    procedure FillPhysicalDisks;
    procedure DiskFormShow(Sender: TObject);
    procedure PaintDiskSplitter(Sender: TObject);
    procedure PaintDiskHandle(Sender: TObject);
    procedure DiskHandleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DiskHandleMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure DiskHandleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DiskFormatClick(Sender: TObject);
    procedure DiskUnmountClick(Sender: TObject);
    procedure DiskRemoveClick(Sender: TObject);
    procedure DiskToolClick(Sender: TObject);
    procedure DiskPreviewClick(Sender: TObject);
    procedure DiskMountClick(Sender: TObject);
    procedure DiskRepairClick(Sender: TObject);
    procedure RepairSelectedNtfs;
    procedure DiskRefreshClick(Sender: TObject);
    procedure RefreshDiskInventory;
    procedure StartDiskInventory(AWithUsage: Boolean);
    procedure DiskTimerTick(Sender: TObject);
    procedure FillDiskInventory(const AOutput, AWarning: string);
    procedure StopDiskInventory;
    procedure AccessUsersClick(Sender: TObject);
    procedure AccessUserExit(Sender: TObject);
    procedure RefreshAccessState;
    function SelectedDisk: string;
    function DiskIsProtected: Boolean;
    function DiskHasFilesystem: Boolean;
    procedure AddDiskNodes(ANode: TJSONData; ADepth: Integer = 0);
    procedure ShowClick(Sender: TObject);
    procedure PlanClick(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure RemoveClick(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
    function HelperName: string;
    function FieldValue(AIndex: Integer): string;
    function Checked(AIndex: Integer): string;
    function InputConfig: string;
    function ActionArgs(const AAction, AConfig: string): TStringList;
    procedure ExecuteAction(const AAction: string);
  public
    constructor CreateFor(AOwner: TComponent; AKind: TSetupKind);
    destructor Destroy; override;
  end;

function RunHelper(const AHelper: string; AArguments: TStrings;
  AElevated: Boolean; const AStdin: string; out AOutput: string): Boolean;
var
  lProcess: TProcess;
  lBuffer: array[0..4095] of Byte;
  lCount, lIndex: Integer;
  lText: UTF8String;
  lInput: UTF8String;
  lSection: string;
  lEmbeddedExecutable: string;
begin
  Result := False;
  AOutput := '';
  if AHelper = CNetworkHelper then lSection := 'network'
  else if AHelper = CProxyHelper then lSection := 'proxy'
  else if AHelper = CAccessHelper then lSection := 'access'
  else if AHelper = CTimeHelper then lSection := 'time'
  else if AHelper = CSshHelper then lSection := 'ssh'
  else if AHelper = CProfileHelper then lSection := 'profile'
  else if AHelper = CDiskHelper then lSection := 'disks'
  else begin AOutput := 'Неизвестный раздел настройки.'; Exit; end;
  lEmbeddedExecutable := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'LinuxSetupManagerCli' + ExtractFileExt(ParamStr(0));
  if not FileExists(lEmbeddedExecutable) then
  begin AOutput := 'Не найден встроенный CLI-режим: ' + lEmbeddedExecutable; Exit; end;
  lProcess := TProcess.Create(nil);
  try
    if AElevated then
    begin
      lProcess.Executable := 'pkexec';
      lProcess.Parameters.Add(lEmbeddedExecutable);
    end
    else
      lProcess.Executable := lEmbeddedExecutable;
    lProcess.Parameters.Add('--internal');
    lProcess.Parameters.Add(lSection);
    for lIndex := 0 to AArguments.Count - 1 do
      lProcess.Parameters.Add(AArguments[lIndex]);
    lProcess.Options := [poUsePipes, poStderrToOutput];
    try
      lProcess.Execute;
      if AStdin <> '' then
      begin
        lInput := UTF8String(AStdin + LineEnding);
        lProcess.Input.WriteBuffer(lInput[1], Length(lInput));
      end;
      lProcess.CloseInput;
      lText := '';
      repeat
        lCount := lProcess.Output.Read(lBuffer, SizeOf(lBuffer));
        if lCount > 0 then
          for lIndex := 0 to lCount - 1 do
            lText := lText + AnsiChar(lBuffer[lIndex]);
      until lCount = 0;
      lProcess.WaitOnExit;
      AOutput := string(lText);
      Result := lProcess.ExitStatus = 0;
      if not Result then
        AOutput := 'Код ' + IntToStr(lProcess.ExitStatus) + LineEnding + AOutput;
    except
      on E: Exception do AOutput := E.Message;
    end;
  finally
    lProcess.Free;
  end;
end;

constructor TSetupDialog.CreateFor(AOwner: TComponent; AKind: TSetupKind);
begin
  inherited CreateNew(AOwner, 1);
  fKind := AKind;
  Width := 800;
  if fKind = skDisk then
  begin
    Width := 1100;
    Constraints.MinWidth := 1030;
  end;
  Height := 680;
  if fKind = skDisk then Height := 760;
  Position := poScreenCenter;
  OnShow := @DiskFormShow;
  Caption := 'Настройка Linux';
  if fKind = skDisk then
  begin
    fOutputHandle := TPanel.Create(Self);
    fOutputHandle.Parent := Self;
    fOutputHandle.Align := alTop;
    fOutputHandle.Height := 12;
    fOutputHandle.BevelOuter := bvNone;
    fOutputHandle.ParentColor := False;
    fOutputHandle.Color := $00E0AD5B;
    fOutputHandle.Cursor := crVSplit;
    fOutputHandle.OnPaint := @PaintDiskHandle;
    fOutputHandle.OnMouseDown := @DiskHandleMouseDown;
    fOutputHandle.OnMouseMove := @DiskHandleMouseMove;
    fOutputHandle.OnMouseUp := @DiskHandleMouseUp;
  end;
  fPage := TScrollBox.Create(Self);
  fPage.Parent := Self;
  fPage.Align := alTop;
  fPage.Height := 350;
  if fKind = skDisk then
  begin
    fPage.Height := 495;
    fPage.Constraints.MinHeight := 300;
  end;
  fNextY := 12;
  case fKind of
    skNetwork: BuildNetwork;
    skProxy: BuildProxy;
    skAccess: BuildAccess;
    skTime: BuildTime;
    skSsh: BuildSsh;
    skProfile: BuildProfile;
    skDisk: BuildDisk;
  end;
  fButtons := TPanel.Create(Self);
  fButtons.Parent := Self;
  fButtons.Align := alTop;
  fButtons.Height := 48;
  if fKind = skDisk then
  begin
    AddButton('Обновить', 8, @DiskRefreshClick);
    AddButton('Подключить', 120, @DiskMountClick);
    AddButton('Диски GUI', 232, @DiskToolClick);
    AddButton('Исправить NTFS', 344, @DiskRepairClick);
  end
  else
  begin
    AddButton('Показать', 8, @ShowClick);
    AddButton('Предпросмотр', 120, @PlanClick);
    fButtons.Controls[fButtons.ControlCount - 1].Hint :=
      'Показать предполагаемые изменения без записи в системные файлы.';
    fButtons.Controls[fButtons.ControlCount - 1].ShowHint := True;
    AddButton('Применить', 232, @ApplyClick);
    if fKind = skProxy then AddButton('Удалить', 344, @RemoveClick);
    if (fKind = skProfile) or (fKind = skSsh) then
      AddButton('Обзор…', 456, @BrowseClick);
    if fKind = skAccess then AddButton('Пользователи…', 344, @AccessUsersClick);
  end;
  fOutputMemo := TMemo.Create(Self);
  fOutputMemo.Parent := Self;
  fOutputMemo.Align := alClient;
  fOutputMemo.ReadOnly := True;
  if fKind = skDisk then fOutputMemo.Constraints.MinHeight := 80;
  fOutputMemo.ScrollBars := ssAutoBoth;
  fOutputMemo.WordWrap := True;
  fOutputMemo.Text := '«Предпросмотр» показывает, что будет изменено. ' +
    'Настройки системы меняет только «Применить».';
  if fKind = skAccess then RefreshAccessState;
  if fKind = skDisk then RefreshDiskInventory;
end;

destructor TSetupDialog.Destroy;
begin
  StopDiskInventory;
  fDiskJson.Free;
  inherited Destroy;
end;

procedure TSetupDialog.AddButton(const ACaption: string; ALeft: Integer;
  AClick: TNotifyEvent);
var
  lButton: TButton;
begin
  lButton := TButton.Create(Self);
  lButton.Parent := fButtons;
  lButton.SetBounds(ALeft, 8, 105, 30);
  lButton.Caption := ACaption;
  lButton.OnClick := AClick;
end;

function TSetupDialog.AddField(const ACaption, ADefault: string;
  APassword: Boolean): TEdit;
var
  lLabel: TLabel;
begin
  lLabel := TLabel.Create(Self);
  lLabel.Parent := fPage;
  lLabel.SetBounds(12, fNextY + 4, 200, 24);
  lLabel.Caption := ACaption;
  Result := TEdit.Create(Self);
  Result.Parent := fPage;
  Result.SetBounds(220, fNextY, 535, 26);
  Result.Text := ADefault;
  if APassword then Result.PasswordChar := '*';
  SetLength(fFields, Length(fFields) + 1);
  fFields[High(fFields)] := Result;
  Inc(fNextY, 34);
end;

function TSetupDialog.AddCheck(const ACaption: string;
  AChecked: Boolean): TCheckBox;
begin
  Result := TCheckBox.Create(Self);
  Result.Parent := fPage;
  Result.SetBounds(14, fNextY, 740, 26);
  Result.Caption := ACaption;
  Result.Checked := AChecked;
  SetLength(fChecks, Length(fChecks) + 1);
  fChecks[High(fChecks)] := Result;
  Inc(fNextY, 30);
end;

function TSetupDialog.AddMemo(const ACaption: string): TMemo;
var
  lLabel: TLabel;
begin
  lLabel := TLabel.Create(Self);
  lLabel.Parent := fPage;
  lLabel.SetBounds(12, fNextY, fPage.ClientWidth - 24, 20);
  lLabel.Anchors := [akLeft, akTop, akRight];
  lLabel.Caption := ACaption;
  Inc(fNextY, 22);
  Result := TMemo.Create(Self);
  Result.Parent := fPage;
  Result.SetBounds(12, fNextY, 743, 84);
  Result.ScrollBars := ssVertical;
  Inc(fNextY, 92);
end;

procedure TSetupDialog.BuildNetwork;
begin
  Caption := 'Сеть и постоянные маршруты';
  AddField('Интерфейс', '');
  AddCheck('DHCP (снять для статического адреса)', True);
  AddField('Адрес/CIDR', '');
  AddField('Шлюз', '');
  AddField('DNS (через пробел)', '');
  fInputMemo := AddMemo('Постоянные маршруты: по одной сети/CIDR и шлюзу в строке');
end;

procedure TSetupDialog.BuildProxy;
begin
  Caption := 'Прокси';
  AddField('Область (user/apt/system)', 'user');
  AddField('Пользователь', GetEnvironmentVariable('USER'));
  AddField('Хост', '');
  AddField('Порт', '3128');
  AddField('Логин', '');
  AddField('Пароль (через stdin)', '', True);
end;

procedure TSetupDialog.BuildAccess;
begin
  Caption := 'Пользователи и права';
  AddField('Пользователь', GetEnvironmentVariable('USER'));
  fFields[0].OnExit := @AccessUserExit;
  AddCheck('sudo', False);
  AddCheck('dialout (последовательные порты)', False);
  AddCheck('plugdev (USB)', False);
  AddCheck('sambashare', False);
  fInputMemo := AddMemo('Каталоги: rw:/путь или ro:/путь, по одному на строку');
end;

procedure TSetupDialog.AccessUsersClick(Sender: TObject);
var
  lArgs, lLines: TStringList;
  lDialog: TForm;
  lList: TListBox;
  lButton: TButton;
  lOutput, lName: string;
  lIndex, lTab: Integer;
begin
  lArgs := TStringList.Create;
  lLines := TStringList.Create;
  try
    lArgs.Add('list-users');
    if not RunHelper(CAccessHelper, lArgs, False, '', lOutput) then
    begin fOutputMemo.Text := lOutput; Exit; end;
    lLines.Text := lOutput;
    lDialog := TForm.CreateNew(Self, 1);
    try
      lDialog.Caption := 'Выберите пользователя';
      lDialog.Position := poScreenCenter;
      lDialog.SetBounds(0, 0, 600, 360);
      lList := TListBox.Create(lDialog);
      lList.Parent := lDialog;
      lList.SetBounds(12, 12, 560, 265);
      for lIndex := 0 to lLines.Count - 1 do
        if Trim(lLines[lIndex]) <> '' then lList.Items.Add(lLines[lIndex]);
      lButton := TButton.Create(lDialog);
      lButton.Parent := lDialog;
      lButton.SetBounds(475, 286, 96, 30);
      lButton.Caption := 'Выбрать';
      lButton.ModalResult := mrOK;
      if (lDialog.ShowModal = mrOK) and (lList.ItemIndex >= 0) then
      begin
        lName := lList.Items[lList.ItemIndex];
        lTab := Pos(#9, lName);
        if lTab > 0 then lName := Copy(lName, 1, lTab - 1);
        fFields[0].Text := lName;
        RefreshAccessState;
      end;
    finally
      lDialog.Free;
    end;
  finally
    lLines.Free;
    lArgs.Free;
  end;
end;

procedure TSetupDialog.AccessUserExit(Sender: TObject);
begin
  RefreshAccessState;
end;

procedure TSetupDialog.RefreshAccessState;
const
  CAccessGroups: array[0..3] of string =
    ('sudo', 'dialout', 'plugdev', 'sambashare');
var
  lArgs, lGroups: TStringList;
  lOutput: string;
  lIndex: Integer;
begin
  if Trim(FieldValue(0)) = '' then Exit;
  lArgs := TStringList.Create;
  lGroups := TStringList.Create;
  try
    lArgs.Add('show-state');
    lArgs.Add('--user');
    lArgs.Add(FieldValue(0));
    if not RunHelper(CAccessHelper, lArgs, False, '', lOutput) then
    begin
      fOutputMemo.Text := lOutput;
      Exit;
    end;
    if Copy(lOutput, 1, 7) <> 'groups=' then Exit;
    lGroups.StrictDelimiter := True;
    lGroups.Delimiter := ' ';
    lGroups.DelimitedText := Trim(Copy(lOutput, 8, MaxInt));
    for lIndex := 0 to 3 do
      fChecks[lIndex].Checked := lGroups.IndexOf(CAccessGroups[lIndex]) >= 0;
  finally
    lGroups.Free;
    lArgs.Free;
  end;
end;

procedure TSetupDialog.BuildTime;
var
  lExample: TLabel;
begin
  Caption := 'Время и NTP';
  AddField('Часовой пояс', 'Europe/Moscow');
  AddCheck('Включить синхронизацию NTP', True);
  AddField('NTP-серверы (через пробел)', '');
  lExample := TLabel.Create(Self);
  lExample.Parent := fPage;
  lExample.SetBounds(220, fNextY, 535, 22);
  lExample.Caption := 'Например: pool.ntp.org 192.168.9.92';
  Inc(fNextY, 24);
end;

procedure TSetupDialog.BuildSsh;
begin
  Caption := 'Удалённый доступ SSH';
  AddField('Пользователь', GetEnvironmentVariable('USER'));
  AddField('Файл открытого ключа', '');
  AddField('Хост/IP для готовой команды', '');
  AddField('Порт SSH', '22');
  AddField('Действие: status/start/stop/enable/disable/firewall allow/delete/install-key/command', 'status');
  AddCheck('Включить службу при загрузке', True);
  AddCheck('Запустить службу сейчас', True);
  AddCheck('Разрешить SSH в ufw', False);
end;

procedure TSetupDialog.BuildProfile;
begin
  Caption := 'Импорт и экспорт профиля ПК';
  AddField('Каталог профиля', '');
  AddField('Режим (export/import)', 'export');
  AddCheck('Имя ПК', True);
  AddCheck('Сеть и маршруты (импорт пока недоступен)', False);
  fChecks[1].Enabled := False;
  AddCheck('Прокси (импорт пока недоступен)', False);
  fChecks[2].Enabled := False;
  AddCheck('Группы пользователей', False);
  AddCheck('Время/NTP', True);
  AddCheck('SSH', True);
  AddCheck('Ресурсы и автозапуск (импорт пока недоступен)', False);
  fChecks[6].Enabled := False;
end;

procedure TSetupDialog.BuildDisk;
var
  lLabel: TLabel;
  lColumn: TListColumn;
  lArea: TPanel;
  lSplitter: TSplitter;
begin
  Caption := 'Диски: обнаружение и безопасное подключение';
  lLabel := TLabel.Create(Self);
  lLabel.Parent := fPage;
  lLabel.SetBounds(12, fNextY, fPage.ClientWidth - 24, 20);
  lLabel.Anchors := [akLeft, akTop, akRight];
  lLabel.Caption := 'Выберите физический накопитель, затем его раздел. В Linux том подключается в каталог, например /mnt/Data.';
  Inc(fNextY, 24);
  lArea := TPanel.Create(Self);
  lArea.Parent := fPage;
  lArea.SetBounds(12, fNextY, fPage.ClientWidth - 24, 350);
  lArea.Anchors := [akLeft, akTop, akRight];
  lArea.BevelOuter := bvNone;
  fPhysicalPanel := TPanel.Create(Self);
  fPhysicalPanel.Parent := lArea;
  fPhysicalPanel.Align := alTop;
  fPhysicalPanel.Height := 125;
  fPhysicalPanel.BevelOuter := bvNone;
  lLabel := TLabel.Create(Self);
  lLabel.Parent := fPhysicalPanel;
  lLabel.Align := alTop;
  lLabel.Height := 20;
  lLabel.Caption := 'Физические накопители';
  fPhysicalList := TListView.Create(Self);
  fPhysicalList.Parent := fPhysicalPanel;
  fPhysicalList.Align := alClient;
  fPhysicalList.ViewStyle := vsReport;
  fPhysicalList.ScrollBars := ssAutoVertical;
  fPhysicalList.RowSelect := True;
  fPhysicalList.ReadOnly := True;
  lColumn := fPhysicalList.Columns.Add; lColumn.Caption := 'Физический накопитель'; lColumn.Width := 230;
  lColumn := fPhysicalList.Columns.Add; lColumn.Caption := 'Модель'; lColumn.Width := 350;
  lColumn := fPhysicalList.Columns.Add; lColumn.Caption := 'Объём'; lColumn.Width := 110;
  lColumn := fPhysicalList.Columns.Add; lColumn.Caption := 'Серийный номер'; lColumn.Width := 240;
  fPhysicalList.OnSelectItem := @PhysicalDiskSelect;
  lSplitter := TSplitter.Create(Self);
  lSplitter.Parent := lArea;
  lSplitter.Align := alTop;
  lSplitter.Height := 10;
  lSplitter.MinSize := 65;
  lSplitter.ResizeControl := fPhysicalPanel;
  lSplitter.OnPaint := @PaintDiskSplitter;
  fPartitionPanel := TPanel.Create(Self);
  fPartitionPanel.Parent := lArea;
  fPartitionPanel.Align := alClient;
  fPartitionPanel.BevelOuter := bvNone;
  lLabel := TLabel.Create(Self);
  lLabel.Parent := fPartitionPanel;
  lLabel.Align := alTop;
  lLabel.Height := 20;
  lLabel.Caption := 'Разделы и логические тома выбранного накопителя';
  fDiskDetails := TMemo.Create(Self);
  fDiskDetails.Parent := fPartitionPanel;
  fDiskDetails.Align := alBottom;
  fDiskDetails.Height := 52;
  fDiskDetails.ReadOnly := True;
  fDiskDetails.ScrollBars := ssAutoBoth;
  fDetailsHandle := TPanel.Create(Self);
  fDetailsHandle.Parent := fPartitionPanel;
  fDetailsHandle.Align := alBottom;
  fDetailsHandle.Height := 12;
  fDetailsHandle.BevelOuter := bvNone;
  fDetailsHandle.ParentColor := False;
  fDetailsHandle.Color := $00E0AD5B;
  fDetailsHandle.Cursor := crVSplit;
  fDetailsHandle.OnPaint := @PaintDiskHandle;
  fDetailsHandle.OnMouseDown := @DiskHandleMouseDown;
  fDetailsHandle.OnMouseMove := @DiskHandleMouseMove;
  fDetailsHandle.OnMouseUp := @DiskHandleMouseUp;
  fDetailsHandle.Hint := 'Потяните, чтобы изменить высоту списка разделов и сведений';
  fDetailsHandle.ShowHint := True;
  fDiskList := TListView.Create(Self);
  fDiskList.Parent := fPartitionPanel;
  fDiskList.Align := alClient;
  fDiskList.ViewStyle := vsReport;
  fDiskList.ScrollBars := ssAutoVertical;
  fDiskList.RowSelect := True;
  fDiskList.ReadOnly := True;
  lColumn := fDiskList.Columns.Add; lColumn.Caption := 'Устройство'; lColumn.Width := 310;
  lColumn := fDiskList.Columns.Add; lColumn.Caption := 'Тип'; lColumn.Width := 55;
  lColumn := fDiskList.Columns.Add; lColumn.Caption := 'Объём'; lColumn.Width := 85;
  lColumn := fDiskList.Columns.Add; lColumn.Caption := 'Занято'; lColumn.Width := 85;
  lColumn := fDiskList.Columns.Add; lColumn.Caption := 'Свободно'; lColumn.Width := 85;
  lColumn := fDiskList.Columns.Add; lColumn.Caption := 'ФС'; lColumn.Width := 75;
  lColumn := fDiskList.Columns.Add; lColumn.Caption := 'Подключён в'; lColumn.Width := 240;
  fDiskList.OnSelectItem := @DiskItemSelect;
  Inc(fNextY, 358);
  lLabel := TLabel.Create(Self);
  lLabel.Parent := fPage;
  lLabel.SetBounds(12, fNextY + 4, 200, 24);
  lLabel.Caption := 'ФС раздела';
  fDiskFsCombo := TComboBox.Create(Self);
  fDiskFsCombo.Parent := fPage;
  fDiskFsCombo.SetBounds(220, fNextY, fPage.ClientWidth - 232, 26);
  fDiskFsCombo.Anchors := [akLeft, akTop, akRight];
  fDiskFsCombo.Style := csDropDownList;
  fDiskFsCombo.Items.Add('Авто (определить по разделу)');
  fDiskFsCombo.Items.Add('NTFS');
  fDiskFsCombo.Items.Add('FAT32');
  fDiskFsCombo.Items.Add('exFAT');
  fDiskFsCombo.Items.Add('ext4');
  fDiskFsCombo.Items.Add('xfs');
  fDiskFsCombo.ItemIndex := 0;
  fDiskFsCombo.Hint := 'Выбор ФС не форматирует раздел. Для изменения ФС используйте «Диски GUI».';
  fDiskFsCombo.ShowHint := True;
  Inc(fNextY, 34);
  AddField('Подключить в', '');
  fFields[0].Hint := 'Например /Data или /home/user/Data. Не выбирайте /home целиком.';
  fFields[0].ShowHint := True;
  AddCheck('Подключить только для чтения', False);
end;

procedure TSetupDialog.PaintDiskSplitter(Sender: TObject);
var
  lSplitter: TSplitter;
begin
  lSplitter := TSplitter(Sender);
  lSplitter.Canvas.Brush.Color := $00E0AD5B;
  lSplitter.Canvas.FillRect(lSplitter.ClientRect);
  lSplitter.Canvas.Pen.Color := $00FFFFFF;
  lSplitter.Canvas.MoveTo((lSplitter.Width - 36) div 2, lSplitter.Height div 2 - 2);
  lSplitter.Canvas.LineTo((lSplitter.Width + 36) div 2, lSplitter.Height div 2 - 2);
  lSplitter.Canvas.MoveTo((lSplitter.Width - 36) div 2, lSplitter.Height div 2 + 1);
  lSplitter.Canvas.LineTo((lSplitter.Width + 36) div 2, lSplitter.Height div 2 + 1);
end;

procedure TSetupDialog.PaintDiskHandle(Sender: TObject);
var
  lHandle: TPanel;
begin
  lHandle := TPanel(Sender);
  lHandle.Canvas.Brush.Color := $00E0AD5B;
  lHandle.Canvas.FillRect(lHandle.ClientRect);
  lHandle.Canvas.Pen.Color := $00FFFFFF;
  lHandle.Canvas.MoveTo((lHandle.Width - 36) div 2, 4);
  lHandle.Canvas.LineTo((lHandle.Width + 36) div 2, 4);
  lHandle.Canvas.MoveTo((lHandle.Width - 36) div 2, 7);
  lHandle.Canvas.LineTo((lHandle.Width + 36) div 2, 7);
end;

procedure TSetupDialog.DiskHandleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then Exit;
  fActiveDiskHandle := TPanel(Sender);
  fDragStartY := Mouse.CursorPos.Y;
  if fActiveDiskHandle = fDetailsHandle then
    fDragStartHeight := fDiskDetails.Height
  else
    fDragStartHeight := fPage.Height;
  SetCaptureControl(fActiveDiskHandle);
end;

procedure TSetupDialog.DiskHandleMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  lHeight, lMaximum: Integer;
begin
  if (fActiveDiskHandle = nil) or (Sender <> fActiveDiskHandle) or
    not (ssLeft in Shift) then Exit;
  if fActiveDiskHandle = fDetailsHandle then
  begin
    lHeight := fDragStartHeight - (Mouse.CursorPos.Y - fDragStartY);
    lMaximum := fPartitionPanel.ClientHeight - fDetailsHandle.Height - 95;
    if lMaximum < 40 then lMaximum := 40;
    if lHeight < 40 then lHeight := 40;
    if lHeight > lMaximum then lHeight := lMaximum;
    fDiskDetails.Height := lHeight;
  end
  else
  begin
    lHeight := fDragStartHeight + Mouse.CursorPos.Y - fDragStartY;
    lMaximum := ClientHeight - fButtons.Height - fOutputHandle.Height - 80;
    if lMaximum < 300 then lMaximum := 300;
    if lHeight < 300 then lHeight := 300;
    if lHeight > lMaximum then lHeight := lMaximum;
    fPage.Height := lHeight;
  end;
end;

procedure TSetupDialog.DiskHandleMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button <> mbLeft) or (fActiveDiskHandle = nil) then Exit;
  SetCaptureControl(TControl(nil));
  fActiveDiskHandle := nil;
end;

procedure TSetupDialog.DiskFormShow(Sender: TObject);
{$IFDEF LCLGTK2}
var
  lInfo: PWidgetInfo;
  lWidgets: PTVWidgets;
  lColumn: PGtkTreeViewColumn;
  lIndex: Integer;
  lList: TListView;
  lListIndex: Integer;
{$ENDIF}
begin
  if (fKind <> skDisk) or (fDiskList = nil) then Exit;
  {$IFDEF LCLGTK2}
  for lListIndex := 0 to 1 do
  begin
    if lListIndex = 0 then lList := fPhysicalList else lList := fDiskList;
    lInfo := GetWidgetInfo(PGtkWidget(lList.Handle));
    if lInfo = nil then Continue;
    lWidgets := PTVWidgets(lInfo^.UserData);
    if (lWidgets = nil) or (lWidgets^.MainView = nil) then Continue;
    for lIndex := 0 to lList.Columns.Count - 1 do
    begin
      lColumn := gtk_tree_view_get_column(PGtkTreeView(lWidgets^.MainView), lIndex);
      if lColumn <> nil then gtk_tree_view_column_set_reorderable(lColumn, True);
    end;
  end;
  {$ENDIF}
end;

function TSetupDialog.SelectedDisk: string;
begin
  Result := '';
  if (fDiskList = nil) or (fDiskList.Selected = nil) then Exit;
  Result := Trim(fDiskList.Selected.Caption);
  if Pos('/dev/', Result) <> 1 then Result := '';
end;

function TSetupDialog.DiskIsProtected: Boolean;
var
  lDetails: string;
begin
  lDetails := LowerCase(fDiskDetails.Text);
  Result := (SelectedDisk = '') or (Trim(lDetails) = '') or
    (Pos('protected=true', lDetails) > 0) or
    (Pos('"protected": true', lDetails) > 0) or
    (Pos('system=true', lDetails) > 0) or
    (Pos('"system": true', lDetails) > 0) or
    (Pos('root=true', lDetails) > 0) or
    (Pos('"root": true', lDetails) > 0) or
    (Pos('used=true', lDetails) > 0) or
    (Pos('"used": true', lDetails) > 0) or
    (Pos('mountpoints=[/', lDetails) > 0) or
    (Pos('mountpoint=/', lDetails) > 0) or
    (Pos('"mountpoint": "/"', lDetails) > 0);
end;

function TSetupDialog.DiskHasFilesystem: Boolean;
var
  lDetails: string;
begin
  lDetails := LowerCase(fDiskDetails.Text);
  Result := (Pos('fstype=', lDetails) > 0) or
    (Pos('"fstype":', lDetails) > 0) or
    (Pos('filesystem:', lDetails) > 0);
end;

function JsonText(ANode: TJSONData; const APath: string): string;
var
  lValue: TJSONData;
begin
  Result := '';
  if ANode = nil then Exit;
  lValue := ANode.FindPath(APath);
  if (lValue <> nil) and (lValue.JSONType <> jtNull) then
    Result := lValue.AsString;
end;

function SizeText(const ABytes: string): string;
var
  lValue: Int64;
begin
  if ABytes = '' then Exit('—');
  lValue := StrToInt64Def(ABytes, -1);
  if lValue < 0 then Exit('—');
  if lValue >= Int64(1024) * 1024 * 1024 * 1024 then
    Exit(FormatFloat('0.0', lValue / (Int64(1024) * 1024 * 1024 * 1024)) + ' ТБ');
  if lValue >= Int64(1024) * 1024 * 1024 then
    Exit(FormatFloat('0.0', lValue / (Int64(1024) * 1024 * 1024)) + ' ГБ');
  if lValue >= Int64(1024) * 1024 then
    Exit(FormatFloat('0.0', lValue / (Int64(1024) * 1024)) + ' МБ');
  Result := IntToStr(lValue) + ' Б';
end;

procedure TSetupDialog.AddDiskNodes(ANode: TJSONData; ADepth: Integer);
var
  lIndex: Integer;
  lPath, lType, lFs, lUsed, lFree, lMount: string;
  lValue: TJSONData;
  lItem: TListItem;
begin
  if ANode = nil then Exit;
  if ANode.JSONType = jtArray then
  begin
    for lIndex := 0 to ANode.Count - 1 do AddDiskNodes(ANode.Items[lIndex], ADepth);
    Exit;
  end;
  if ANode.JSONType <> jtObject then Exit;
  lPath := JsonText(ANode, 'path');
  if (Pos('/dev/', lPath) = 1) and (JsonText(ANode, 'type') <> 'disk') then
  begin
    lType := JsonText(ANode, 'type');
    lFs := JsonText(ANode, 'fstype');
    lMount := JsonText(ANode, 'mountpoint');
    lUsed := JsonText(ANode, 'fsused');
    lFree := JsonText(ANode, 'fsavail');
    if lFs = '' then lFs := '—';
    if lMount = '' then lMount := 'не подключён';
    if lUsed = '' then
      if lFs = '—' then lUsed := '—' else lUsed := 'неизвестно'
    else lUsed := SizeText(lUsed);
    if lFree = '' then
      if lFs = '—' then lFree := '—' else lFree := 'неизвестно'
    else lFree := SizeText(lFree);
    lItem := fDiskList.Items.Add;
    lItem.Caption := StringOfChar(' ', ADepth * 2) + lPath;
    lItem.SubItems.Add(lType);
    lItem.SubItems.Add(SizeText(JsonText(ANode, 'size')));
    lItem.SubItems.Add(lUsed);
    lItem.SubItems.Add(lFree);
    lItem.SubItems.Add(lFs);
    lItem.SubItems.Add(lMount);
    lItem.SubItems.Add(JsonText(ANode, 'uuid'));
    lItem.SubItems.Add(JsonText(ANode, 'usage_status'));
    lItem.SubItems.Add(JsonText(ANode, 'model'));
    lItem.SubItems.Add(JsonText(ANode, 'serial'));
    lItem.SubItems.Add(JsonText(ANode, 'usage_error'));
    Inc(ADepth);
  end;
  lValue := ANode.FindPath('blockdevices');
  if lValue <> nil then AddDiskNodes(lValue, ADepth);
  lValue := ANode.FindPath('children');
  if lValue <> nil then AddDiskNodes(lValue, ADepth);
end;

procedure TSetupDialog.FillPhysicalDisks;
var
  lDevices, lNode: TJSONData;
  lIndex: Integer;
  lItem: TListItem;
begin
  fPhysicalList.Items.Clear;
  if fDiskJson = nil then Exit;
  lDevices := fDiskJson.FindPath('blockdevices');
  if (lDevices = nil) or (lDevices.JSONType <> jtArray) then Exit;
  for lIndex := 0 to lDevices.Count - 1 do
  begin
    lNode := lDevices.Items[lIndex];
    if JsonText(lNode, 'type') <> 'disk' then Continue;
    lItem := fPhysicalList.Items.Add;
    lItem.Caption := JsonText(lNode, 'path');
    lItem.SubItems.Add(JsonText(lNode, 'model'));
    lItem.SubItems.Add(SizeText(JsonText(lNode, 'size')));
    lItem.SubItems.Add(JsonText(lNode, 'serial'));
  end;
end;

procedure TSetupDialog.PhysicalDiskClick(Sender: TObject);
begin
  if fPhysicalList.Selected <> nil then
    ShowPhysicalDisk(fPhysicalList.Selected.Caption);
end;

procedure TSetupDialog.PhysicalDiskSelect(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected and (Item <> nil) then ShowPhysicalDisk(Item.Caption);
end;

procedure TSetupDialog.ShowPhysicalDisk(const APath: string);
var
  lDevices, lNode, lChildren: TJSONData;
  lIndex: Integer;
begin
  fDiskList.Items.Clear;
  fDiskDetails.Clear;
  fFields[0].Clear;
  if fDiskJson = nil then Exit;
  lDevices := fDiskJson.FindPath('blockdevices');
  if (lDevices = nil) or (lDevices.JSONType <> jtArray) then Exit;
  for lIndex := 0 to lDevices.Count - 1 do
  begin
    lNode := lDevices.Items[lIndex];
    if JsonText(lNode, 'path') <> APath then Continue;
    lChildren := lNode.FindPath('children');
    AddDiskNodes(lChildren);
    Break;
  end;
  for lIndex := 0 to fDiskList.Items.Count - 1 do
    if (fDiskList.Items[lIndex].SubItems.Count > 4) and
      (fDiskList.Items[lIndex].SubItems[0] = 'part') and
      (fDiskList.Items[lIndex].SubItems[4] <> '—') then
    begin
      fDiskList.Items[lIndex].Selected := True;
      DiskListClick(nil);
      Break;
    end;
end;

procedure TSetupDialog.DiskListClick(Sender: TObject);
var
  lItem: TListItem;
  lFs, lMount: string;
begin
  fDiskDetails.Clear;
  lItem := fDiskList.Selected;
  if (lItem = nil) or (lItem.SubItems.Count < 11) then Exit;
  lFs := lItem.SubItems[4];
  lMount := lItem.SubItems[5];
  fDiskDetails.Text := 'Модель: ' + lItem.SubItems[8] +
    '   Серийный номер: ' + lItem.SubItems[9] + LineEnding +
    'UUID: ' + lItem.SubItems[6] + '   Статус: ' + lItem.SubItems[7];
  if lItem.SubItems[10] <> '' then
    fDiskDetails.Text := fDiskDetails.Text + LineEnding + lItem.SubItems[10];
  fDiskFsCombo.ItemIndex := 0;
  if SameText(lFs, 'ntfs') or SameText(lFs, 'ntfs3') then
    fDiskFsCombo.ItemIndex := 1
  else if SameText(lFs, 'vfat') or SameText(lFs, 'fat') then
    fDiskFsCombo.ItemIndex := 2
  else if SameText(lFs, 'exfat') then fDiskFsCombo.ItemIndex := 3
  else if SameText(lFs, 'ext4') then fDiskFsCombo.ItemIndex := 4
  else if SameText(lFs, 'xfs') then fDiskFsCombo.ItemIndex := 5;
  if (lMount <> 'не подключён') and
    not StartsText('/run/linuxsetupmanager-', lMount) then
    fFields[0].Text := lMount
  else fFields[0].Text := '/mnt/' + ExtractFileName(SelectedDisk);
end;

procedure TSetupDialog.DiskItemSelect(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then DiskListClick(Sender);
end;

procedure TSetupDialog.RefreshDiskInventory;
begin
  StopDiskInventory;
  FreeAndNil(fDiskJson);
  fPhysicalList.Items.Clear;
  fDiskList.Items.Clear;
  fDiskDetails.Clear;
  fOutputMemo.Text := 'Загрузка списка дисков…';
  StartDiskInventory(False);
end;

procedure TSetupDialog.StartDiskInventory(AWithUsage: Boolean);
var
  lExecutable: string;
begin
  lExecutable := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'LinuxSetupManagerCli' + ExtractFileExt(ParamStr(0));
  if not FileExists(lExecutable) then
  begin
    fOutputMemo.Text := 'Не найден встроенный CLI-режим: ' + lExecutable;
    Exit;
  end;
  fDiskPhase := Ord(AWithUsage);
  fDiskProcess := TProcess.Create(nil);
  try
    if AWithUsage then
    begin
      fDiskProcess.Executable := 'pkexec';
      fDiskProcess.Parameters.Add(lExecutable);
    end
    else
      fDiskProcess.Executable := lExecutable;
    fDiskProcess.Parameters.Add('--internal');
    fDiskProcess.Parameters.Add('disks');
    if AWithUsage then fDiskProcess.Parameters.Add('list-with-usage')
    else fDiskProcess.Parameters.Add('list');
    fDiskProcess.Options := [poUsePipes, poStderrToOutput];
    fDiskProcess.Execute;
    fDiskProcess.CloseInput;
    fDiskOutput := '';
    fDiskStarted := GetTickCount64;
    if fDiskTimer = nil then
    begin
      fDiskTimer := TTimer.Create(Self);
      fDiskTimer.Interval := 100;
      fDiskTimer.OnTimer := @DiskTimerTick;
    end;
    fDiskTimer.Enabled := True;
  except
    on E: Exception do
    begin
      FreeAndNil(fDiskProcess);
      fOutputMemo.Text := 'Не удалось начать опрос дисков: ' + E.Message;
    end;
  end;
end;

procedure TSetupDialog.StopDiskInventory;
begin
  if fDiskTimer <> nil then fDiskTimer.Enabled := False;
  if fDiskProcess <> nil then
  begin
    if fDiskProcess.Running then fDiskProcess.Terminate(0);
    FreeAndNil(fDiskProcess);
  end;
end;

procedure TSetupDialog.DiskTimerTick(Sender: TObject);
var
  lBuffer: array[0..4095] of Byte;
  lCount, lAvailable: LongInt;
  lOutput: string;
  lSuccess, lWithUsage: Boolean;
begin
  if fDiskProcess = nil then Exit;
  lAvailable := fDiskProcess.Output.NumBytesAvailable;
  while lAvailable > 0 do
  begin
    if lAvailable > SizeOf(lBuffer) then lAvailable := SizeOf(lBuffer);
    lCount := fDiskProcess.Output.Read(lBuffer, lAvailable);
    if lCount <= 0 then Break;
    SetLength(fDiskOutput, Length(fDiskOutput) + lCount);
    Move(lBuffer[0], fDiskOutput[Length(fDiskOutput) - lCount + 1], lCount);
    lAvailable := fDiskProcess.Output.NumBytesAvailable;
  end;
  if fDiskProcess.Running and (GetTickCount64 - fDiskStarted < 90000) then Exit;
  lWithUsage := fDiskPhase = 1;
  lSuccess := not fDiskProcess.Running and (fDiskProcess.ExitStatus = 0);
  lOutput := string(fDiskOutput);
  if not lSuccess and (GetTickCount64 - fDiskStarted >= 90000) then
    lOutput := 'Превышено время ожидания опроса дисков (90 с).';
  StopDiskInventory;
  if lSuccess then
  begin
    if lWithUsage then FillDiskInventory(lOutput, '')
    else
    begin
      FillDiskInventory(lOutput, 'Проверяется занятое место несмонтированных разделов…' + LineEnding);
      StartDiskInventory(True);
    end;
  end
  else if lWithUsage then
    fOutputMemo.Text := 'Занятое место несмонтированных разделов не проверено: ' +
      Trim(lOutput) + LineEnding + fOutputMemo.Text
  else
    fOutputMemo.Text := 'Не удалось получить список дисков: ' + Trim(lOutput);
end;

procedure TSetupDialog.FillDiskInventory(const AOutput, AWarning: string);
var
  lIndex: Integer;
  lPhysicalPath, lPartitionPath: string;
begin
  try
    lPhysicalPath := '';
    if fPhysicalList.Selected <> nil then
      lPhysicalPath := fPhysicalList.Selected.Caption;
    lPartitionPath := SelectedDisk;
    FreeAndNil(fDiskJson);
    fDiskJson := GetJSON(AOutput);
    FillPhysicalDisks;
    if fPhysicalList.Items.Count > 0 then
    begin
      fPhysicalList.Items[0].Selected := True;
      for lIndex := 0 to fPhysicalList.Items.Count - 1 do
        if fPhysicalList.Items[lIndex].Caption = lPhysicalPath then
        begin
          fPhysicalList.Items[lIndex].Selected := True;
          Break;
        end;
      PhysicalDiskClick(nil);
      for lIndex := 0 to fDiskList.Items.Count - 1 do
        if Trim(fDiskList.Items[lIndex].Caption) = lPartitionPath then
        begin
          fDiskList.Items[lIndex].Selected := True;
          DiskListClick(nil);
          Break;
        end;
    end;
    fOutputMemo.Text := AWarning + 'Физических накопителей: ' +
      IntToStr(fPhysicalList.Items.Count) + '. Разделов выбранного накопителя: ' +
      IntToStr(fDiskList.Items.Count) + '. Неизвестное занятое место не означает пустой диск.';
  except
    on E: Exception do fOutputMemo.Text :=
      'Не удалось разобрать список дисков: ' + E.Message;
  end;
end;

procedure TSetupDialog.DiskRefreshClick(Sender: TObject);
begin
  RefreshDiskInventory;
end;

procedure TSetupDialog.DiskPreviewClick(Sender: TObject);
var
  lArgs: TStringList;
  lOutput: string;
begin
  if SelectedDisk = '' then Exit;
  lArgs := TStringList.Create;
  try
    lArgs.Add('preview');
    lArgs.Add(SelectedDisk);
    RunHelper(CDiskHelper, lArgs, True, '', lOutput);
    fOutputMemo.Text := lOutput;
  finally
    lArgs.Free;
  end;
end;

procedure TSetupDialog.DiskMountClick(Sender: TObject);
var
  lArgs: TStringList;
  lOutput, lDevice, lUuid, lFs, lMount, lOwner: string;
  lItem: TListItem;
  lSuccess: Boolean;
begin
  lDevice := SelectedDisk;
  if lDevice = '' then Exit;
  lItem := fDiskList.Selected;
  if (lItem = nil) or (lItem.SubItems.Count < 7) or
    (lItem.SubItems[0] <> 'part') then
  begin
    MessageDlg('Выберите раздел с файловой системой, а не целый диск.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lUuid := lItem.SubItems[6];
  lFs := lItem.SubItems[4];
  lMount := FieldValue(0);
  lOwner := GetEnvironmentVariable('USER');
  if lOwner = '' then lOwner := GetEnvironmentVariable('LOGNAME');
  if (lUuid = '') or (lFs = '—') then
  begin
    MessageDlg('У раздела не определены файловая система и UUID. ' +
      'Сначала подготовьте его в «Диски GUI».', mtWarning, [mbOK], 0);
    Exit;
  end;
  if (fDiskFsCombo.ItemIndex > 0) and
    not ((fDiskFsCombo.ItemIndex = 1) and
      (SameText(lFs, 'ntfs') or SameText(lFs, 'ntfs3'))) and
    not ((fDiskFsCombo.ItemIndex = 2) and
      (SameText(lFs, 'vfat') or SameText(lFs, 'fat'))) and
    not ((fDiskFsCombo.ItemIndex = 3) and SameText(lFs, 'exfat')) and
    not ((fDiskFsCombo.ItemIndex = 4) and SameText(lFs, 'ext4')) and
    not ((fDiskFsCombo.ItemIndex = 5) and SameText(lFs, 'xfs')) then
  begin
    MessageDlg('Выбор в списке не меняет файловую систему раздела. ' +
      'Сейчас обнаружена ' + lFs + '. Для изменения используйте «Диски GUI».',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  if (not fChecks[0].Checked) and
    (SameText(lFs, 'ntfs') or SameText(lFs, 'ntfs3')) and (lOwner = '') then
  begin
    MessageDlg('Не удалось определить пользователя для записи на NTFS.',
      mtError, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Подключить или перемонтировать ' + lDevice +
    ' (' + lFs + ', UUID ' + lUuid + ') в ' + lMount + '?' + LineEnding +
    'Прежняя управляемая точка будет снята автоматически. ' +
    'Форматирование и перенос файлов не выполняются.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  lArgs := TStringList.Create;
  try
    lArgs.Add('mount-existing');
    lArgs.Add(lDevice);
    lArgs.Add('--mount-point'); lArgs.Add(lMount);
    lArgs.Add('--read-only');
    if fChecks[0].Checked then lArgs.Add('yes') else lArgs.Add('no');
    lArgs.Add('--owner-user'); lArgs.Add(lOwner);
    lArgs.Add('--confirm-device'); lArgs.Add(lDevice);
    lArgs.Add('--confirm-uuid'); lArgs.Add(lUuid);
    lSuccess := RunHelper(CDiskHelper, lArgs, True, '', lOutput);
    if Pos('NTFS_REPAIR_AVAILABLE:', lOutput) > 0 then
    begin
      fOutputMemo.Text := lOutput;
      RepairSelectedNtfs;
    end
    else
    begin
      if lSuccess then RefreshDiskInventory;
      fOutputMemo.Text := lOutput;
    end;
  finally
    lArgs.Free;
  end;
end;

procedure TSetupDialog.DiskRepairClick(Sender: TObject);
begin
  RepairSelectedNtfs;
end;

procedure TSetupDialog.RepairSelectedNtfs;
var
  lArgs: TStringList;
  lItem: TListItem;
  lDevice, lUuid, lFs, lOutput: string;
begin
  lDevice := SelectedDisk;
  lItem := fDiskList.Selected;
  if (lDevice = '') or (lItem = nil) or (lItem.SubItems.Count < 7) or
    (lItem.SubItems[0] <> 'part') then
  begin
    MessageDlg('Выберите раздел NTFS, а не целый диск.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lFs := lItem.SubItems[4];
  lUuid := lItem.SubItems[6];
  if (not SameText(lFs, 'ntfs')) and (not SameText(lFs, 'ntfs3')) then
  begin
    MessageDlg('Восстановление доступно только для раздела NTFS.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  if lUuid = '' then
  begin
    MessageDlg('Не удалось определить UUID раздела. Обновите список дисков.',
      mtError, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Исправить ' + lDevice + ' (UUID ' + lUuid + ')?' +
    LineEnding + LineEnding +
    'NTFS подключена только для чтения; возможна незавершённая работа Windows ' +
    'или ошибка файловой системы. ' +
    'Утилита отключит раздел, запустит ntfsfix и подключит его снова. ' +
    'ntfsfix сбрасывает журнал NTFS: часть несохранённых данных может быть ' +
    'потеряна. Закройте программы, использующие этот диск. Продолжить?',
    mtWarning, [mbYes, mbNo], 0) <> mrYes then Exit;
  lArgs := TStringList.Create;
  try
    lArgs.Add('repair-ntfs');
    lArgs.Add(lDevice);
    lArgs.Add('--confirm-device'); lArgs.Add(lDevice);
    lArgs.Add('--confirm-uuid'); lArgs.Add(lUuid);
    lArgs.Add('--accept-data-risk'); lArgs.Add('yes');
    if RunHelper(CDiskHelper, lArgs, True, '', lOutput) then
    begin
      MessageDlg('Восстановление завершено:' + LineEnding + lOutput,
        mtInformation, [mbOK], 0);
      RefreshDiskInventory;
    end
    else
    begin
      fOutputMemo.Text := lOutput;
      MessageDlg('Восстановление не выполнено:' + LineEnding + lOutput,
        mtError, [mbOK], 0);
    end;
  finally
    lArgs.Free;
  end;
end;

function TSetupDialog.HelperName: string;
begin
  case fKind of
    skNetwork: Result := CNetworkHelper;
    skProxy: Result := CProxyHelper;
    skAccess: Result := CAccessHelper;
    skTime: Result := CTimeHelper;
    skSsh: Result := CSshHelper;
    skDisk: Result := CDiskHelper;
  else Result := CProfileHelper;
  end;
end;

function TSetupDialog.FieldValue(AIndex: Integer): string;
begin
  Result := Trim(fFields[AIndex].Text);
end;

function TSetupDialog.Checked(AIndex: Integer): string;
begin
  if fChecks[AIndex].Checked then Result := '1' else Result := '0';
end;

function TSetupDialog.InputConfig: string;
var
  lLines: TStringList;
  lIndex: Integer;
begin
  Result := GetTempFileName(GetTempDir(False), 'rls');
  lLines := TStringList.Create;
  try
    if fKind = skAccess then
    begin
      lLines.Add('USER=' + FieldValue(0));
      lLines.Add('GROUPS=' +
        IfThen(fChecks[0].Checked, 'sudo,', '') +
        IfThen(fChecks[1].Checked, 'dialout,', '') +
        IfThen(fChecks[2].Checked, 'plugdev,', '') +
        IfThen(fChecks[3].Checked, 'sambashare', ''));
      for lIndex := 0 to fInputMemo.Lines.Count - 1 do
      begin
        if Pos('rw:', Trim(fInputMemo.Lines[lIndex])) = 1 then
          lLines.Add('ACL_RW=' + Copy(Trim(fInputMemo.Lines[lIndex]), 4, MaxInt))
        else if Pos('ro:', Trim(fInputMemo.Lines[lIndex])) = 1 then
          lLines.Add('ACL_READ=' + Copy(Trim(fInputMemo.Lines[lIndex]), 4, MaxInt));
      end;
      lLines.SaveToFile(Result);
      Exit;
    end;
    for lIndex := 0 to High(fFields) do
      if not ((fKind = skProxy) and (lIndex = 5)) then
        lLines.Add('field' + IntToStr(lIndex) + '=' + FieldValue(lIndex));
    for lIndex := 0 to High(fChecks) do
      lLines.Add('check' + IntToStr(lIndex) + '=' + Checked(lIndex));
    if Assigned(fInputMemo) then
      for lIndex := 0 to fInputMemo.Lines.Count - 1 do
        lLines.Add('item=' + fInputMemo.Lines[lIndex]);
    lLines.SaveToFile(Result);
  finally
    lLines.Free;
  end;
end;

function TSetupDialog.ActionArgs(const AAction, AConfig: string): TStringList;
begin
  Result := TStringList.Create;
  Result.Add(AAction);
  if AConfig <> '' then Result.Add(AConfig);
end;

procedure TSetupDialog.ExecuteAction(const AAction: string);
var
  lArgs: TStringList;
  lConfig, lOutput, lPassword, lSections, lAction, lItem, lExtra: string;
  lIndex: Integer;
  lElevated, lSuccess: Boolean;
begin
  lConfig := '';
  lPassword := '';
  lElevated := (AAction = 'apply') or (AAction = 'remove');
  if (fKind = skAccess) and (AAction <> 'show') then
    lConfig := InputConfig;
  if (fKind = skProxy) and (AAction = 'apply') then
    lPassword := FieldValue(5);
  lArgs := ActionArgs(AAction, lConfig);
  try
    if fKind = skNetwork then
    begin
      lArgs.Clear;
      lArgs.Add(AAction);
      if FieldValue(0) <> '' then
      begin lArgs.Add('--interface'); lArgs.Add(FieldValue(0)); end;
      if AAction <> 'show' then
      begin
        if fChecks[0].Checked then lArgs.Add('--dhcp')
        else
        begin lArgs.Add('--address'); lArgs.Add(FieldValue(1)); end;
        if FieldValue(2) <> '' then
        begin lArgs.Add('--gateway'); lArgs.Add(FieldValue(2)); end;
        if FieldValue(3) <> '' then
        begin lArgs.Add('--dns');
          lArgs.Add(StringReplace(FieldValue(3), ' ', ',', [rfReplaceAll])); end;
        for lIndex := 0 to fInputMemo.Lines.Count - 1 do
          if Trim(fInputMemo.Lines[lIndex]) <> '' then
          begin
            lArgs.Add('--route');
            lArgs.Add(StringReplace(Trim(fInputMemo.Lines[lIndex]),
              ' ', '=', [rfReplaceAll]));
          end;
      end;
    end
    else if fKind = skProxy then
    begin
      lArgs.Clear;
      if AAction = 'plan' then
      begin
        fOutputMemo.Text := 'Прокси ' + FieldValue(2) + ':' + FieldValue(3) +
          ' для ' + FieldValue(0) + '/' + FieldValue(1) + LineEnding +
          'Пароль будет передан помощнику через stdin только при применении.';
        Exit;
      end;
      lArgs.Add(AAction);
      lArgs.Add('--scope');
      if SameText(FieldValue(0), 'apt') then lArgs.Add('system')
      else lArgs.Add(FieldValue(0));
      lArgs.Add('--user'); lArgs.Add(FieldValue(1));
      if AAction = 'apply' then
      begin
        lArgs.Add('--host'); lArgs.Add(FieldValue(2));
        lArgs.Add('--port'); lArgs.Add(FieldValue(3));
        if FieldValue(4) <> '' then
        begin lArgs.Add('--login'); lArgs.Add(FieldValue(4)); end;
        if lPassword <> '' then lArgs.Add('--password-stdin');
      end;
    end
    else if fKind = skTime then
    begin
      lArgs.Clear;
      if AAction = 'plan' then
      begin
        fOutputMemo.Text := 'Часовой пояс: ' + FieldValue(0) + LineEnding +
          'NTP: ' + Checked(0) + LineEnding +
          'Серверы: ' + FieldValue(1);
        Exit;
      end;
      if AAction = 'show' then lArgs.Add('show')
      else
      begin
        lArgs.Add('set-timezone'); lArgs.Add(FieldValue(0));
        if not RunHelper(CTimeHelper, lArgs, True, '', lExtra) then
        begin fOutputMemo.Text := lExtra; Exit; end;
        lArgs.Clear;
        lArgs.Add('ntp');
        if fChecks[0].Checked then lArgs.Add('enable')
        else lArgs.Add('disable');
        if not RunHelper(CTimeHelper, lArgs, True, '', lExtra) then
        begin fOutputMemo.Text := lExtra; Exit; end;
        if FieldValue(1) <> '' then
        begin
          lArgs.Clear;
          lArgs.Add('ntp-servers');
          lArgs.Add(StringReplace(FieldValue(1), ' ', ',', [rfReplaceAll]));
        end
        else
        begin fOutputMemo.Text := lExtra; Exit; end;
      end;
    end
    else if fKind = skAccess then
    begin
      lArgs.Clear;
      if AAction = 'show' then
      begin
        lArgs.Add('show');
        lArgs.Add('--user');
        lArgs.Add(FieldValue(0));
      end
      else
      begin
        if AAction = 'plan' then lArgs.Add('plan') else lArgs.Add('apply');
        lArgs.Add('--config');
        lArgs.Add(lConfig);
      end;
    end
    else if fKind = skProfile then
    begin
      lArgs.Clear;
      lSections := '';
      for lIndex := 0 to High(fChecks) do
        if fChecks[lIndex].Checked then
        begin
          case lIndex of
            0: lItem := 'hostname';
            1: lItem := 'network,routes';
            2: lItem := 'proxy';
            3: lItem := 'users';
            4: lItem := 'time';
            5: lItem := 'ssh';
          else lItem := 'shares,autostart';
          end;
          if lSections <> '' then lSections := lSections + ',';
          lSections := lSections + lItem;
        end;
      if AAction = 'show' then lArgs.Add('validate')
      else if AAction = 'plan' then lArgs.Add('plan')
      else if SameText(FieldValue(1), 'export') then lArgs.Add('export')
      else lArgs.Add('apply');
      if lArgs[0] = 'export' then lArgs.Add('--output')
      else lArgs.Add('--profile');
      lArgs.Add(FieldValue(0));
      if (lArgs[0] = 'plan') or (lArgs[0] = 'apply') then
      begin
        lArgs.Add('--sections');
        lArgs.Add(lSections);
      end;
      lElevated := lArgs[0] = 'apply';
    end
    else if fKind = skSsh then
    begin
      lArgs.Clear;
      lAction := FieldValue(4);
      if AAction = 'show' then lAction := 'status';
      if lAction = 'firewall allow' then
      begin lArgs.Add('firewall'); lArgs.Add('allow'); end
      else if lAction = 'firewall delete' then
      begin lArgs.Add('firewall'); lArgs.Add('delete'); end
      else if lAction = 'install-key' then
      begin
        lArgs.Add('install-key');
        lArgs.Add('--user'); lArgs.Add(FieldValue(0));
        lArgs.Add('--key-file'); lArgs.Add(FieldValue(1));
      end
      else if lAction = 'command' then
      begin
        lArgs.Add('command');
        lArgs.Add('--user'); lArgs.Add(FieldValue(0));
        if FieldValue(2) <> '' then
        begin lArgs.Add('--host'); lArgs.Add(FieldValue(2)); end;
        lArgs.Add('--port'); lArgs.Add(FieldValue(3));
      end
      else lArgs.Add(lAction);
      lElevated := not ((lAction = 'status') or (lAction = 'command'));
      if AAction = 'plan' then
      begin
        fOutputMemo.Text := 'SSH: ' + lArgs.Text + LineEnding +
          'Изменения выполняются только после «Применить».';
        Exit;
      end;
    end;
    lSuccess := RunHelper(HelperName, lArgs, lElevated, lPassword, lOutput);
    fOutputMemo.Text := lOutput;
    if lSuccess and (fKind = skAccess) and (AAction = 'apply') then
      RefreshAccessState;
    if not lSuccess then
      MessageDlg('Операция не выполнена. Подробности в нижнем поле.',
        mtError, [mbOK], 0);
  finally
    lArgs.Free;
    if lConfig <> '' then DeleteFile(lConfig);
  end;
end;

procedure TSetupDialog.ShowClick(Sender: TObject);
begin
  ExecuteAction('show');
end;

procedure TSetupDialog.PlanClick(Sender: TObject);
begin
  ExecuteAction('plan');
end;

procedure TSetupDialog.ApplyClick(Sender: TObject);
begin
  if fKind = skDisk then
  begin
    DiskToolClick(Sender);
    Exit;
  end;
  if fKind = skNetwork then
    if MessageDlg('Изменение сети может немедленно оборвать SSH и доступ к этому ПК. ' +
      'Проверьте адрес, маршруты и локальный доступ. Продолжить?',
      mtWarning, [mbYes, mbNo], 0) <> mrYes then Exit;
  if MessageDlg('Применить системные настройки?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then ExecuteAction('apply');
end;

procedure TSetupDialog.DiskFormatClick(Sender: TObject);
var
  lDevice, lTyped, lOutput: string;
  lArgs: TStringList;
begin
  if DiskIsProtected then
  begin
    MessageDlg('Форматирование системного, используемого или не проверенного диска недоступно.',
      mtError, [mbOK], 0);
    Exit;
  end;
  lDevice := SelectedDisk;
  if MessageDlg('ФОРМАТИРОВАНИЕ уничтожит данные на ' + lDevice +
    '. Продолжить?', mtWarning, [mbYes, mbNo], 0) <> mrYes then Exit;
  if not InputQuery('Подтверждение устройства',
    'Введите точно ' + lDevice + ':', lTyped) then Exit;
  if lTyped <> lDevice then
  begin
    MessageDlg('Имя устройства не совпало.', mtError, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Последнее подтверждение: стереть ' + lDevice +
    ' и смонтировать в ' + FieldValue(1) + '?',
    mtWarning, [mbYes, mbNo], 0) <> mrYes then Exit;
  if DiskHasFilesystem then
    if MessageDlg('На устройстве уже есть файловая система. Её данные будут потеряны. Подтвердить?',
      mtWarning, [mbYes, mbNo], 0) <> mrYes then Exit;
  lArgs := TStringList.Create;
  try
    lArgs.Add('format-and-mount');
    lArgs.Add(lDevice);
    lArgs.Add('--filesystem'); lArgs.Add(FieldValue(0));
    lArgs.Add('--mount-point'); lArgs.Add(FieldValue(1));
    if FieldValue(2) <> '' then
    begin lArgs.Add('--label'); lArgs.Add(FieldValue(2)); end;
    lArgs.Add('--confirm-device'); lArgs.Add(lDevice);
    lArgs.Add('--confirm-erase'); lArgs.Add('ERASE-ALL-DATA');
    if DiskHasFilesystem then
    begin
      lArgs.Add('--confirm-existing-data');
      lArgs.Add('DESTROY-EXISTING-FILESYSTEM');
    end;
    if not RunHelper(CDiskHelper, lArgs, True, '', lOutput) then
      MessageDlg('Форматирование не выполнено: ' + lOutput,
        mtError, [mbOK], 0);
    fOutputMemo.Text := lOutput;
  finally
    lArgs.Free;
  end;
end;

procedure TSetupDialog.DiskUnmountClick(Sender: TObject);
var
  lArgs: TStringList;
  lOutput: string;
begin
  if SelectedDisk = '' then Exit;
  if MessageDlg('Отключить ' + SelectedDisk + '?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  lArgs := TStringList.Create;
  try
    lArgs.Add('unmount');
    lArgs.Add(SelectedDisk);
    RunHelper(CDiskHelper, lArgs, True, '', lOutput);
    fOutputMemo.Text := lOutput;
  finally
    lArgs.Free;
  end;
end;

procedure TSetupDialog.DiskRemoveClick(Sender: TObject);
var
  lArgs: TStringList;
  lOutput: string;
begin
  if SelectedDisk = '' then Exit;
  if MessageDlg('Удалить постоянную запись монтирования ' + SelectedDisk +
    ' из /etc/fstab?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  lArgs := TStringList.Create;
  try
    lArgs.Add('remove-fstab');
    lArgs.Add(SelectedDisk);
    RunHelper(CDiskHelper, lArgs, True, '', lOutput);
    fOutputMemo.Text := lOutput;
  finally
    lArgs.Free;
  end;
end;

procedure TSetupDialog.DiskToolClick(Sender: TObject);
var
  lArgs, lLines: TStringList;
  lOutput, lTool: string;
  lProcess: TProcess;
begin
  lArgs := TStringList.Create;
  lLines := TStringList.Create;
  try
    lArgs.Add('detect-tools');
    if not RunHelper(CDiskHelper, lArgs, False, '', lOutput) then
    begin
      fOutputMemo.Text := lOutput;
      Exit;
    end;
    lLines.Text := lOutput;
    lTool := '';
    if Pos('gnome-disks', lOutput) > 0 then lTool := 'gnome-disks'
    else if Pos('partitionmanager', lOutput) > 0 then lTool := 'partitionmanager'
    else if Pos('gparted', lOutput) > 0 then lTool := 'gparted';
    if lTool = '' then
    begin
      fOutputMemo.Text := 'Графический инструмент не найден.' + LineEnding + lOutput;
      Exit;
    end;
    lProcess := TProcess.Create(nil);
    try
      lProcess.Executable := lTool;
      lProcess.Execute;
    finally
      lProcess.Free;
    end;
  finally
    lLines.Free;
    lArgs.Free;
  end;
end;

procedure TSetupDialog.RemoveClick(Sender: TObject);
begin
  if MessageDlg('Удалить выбранные настройки прокси?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then ExecuteAction('remove');
end;

procedure TSetupDialog.BrowseClick(Sender: TObject);
var
  lDirectory: string;
  lFileDialog: TOpenDialog;
begin
  if fKind = skProfile then
  begin
    lDirectory := FieldValue(0);
    if SelectDirectory('Каталог профиля', '', lDirectory) then
      fFields[0].Text := lDirectory;
    Exit;
  end;
  lFileDialog := TOpenDialog.Create(Self);
  try
    lFileDialog.Title := 'Открытый ключ SSH';
    if lFileDialog.Execute then fFields[1].Text := lFileDialog.FileName;
  finally
    lFileDialog.Free;
  end;
end;

procedure ShowDialog(AOwner: TComponent; AKind: TSetupKind);
var
  lDialog: TSetupDialog;
begin
  lDialog := TSetupDialog.CreateFor(AOwner, AKind);
  try
    lDialog.ShowModal;
  finally
    lDialog.Free;
  end;
end;

procedure ShowNetworkDialog(AOwner: TComponent);
begin ShowDialog(AOwner, skNetwork); end;
procedure ShowProxyDialog(AOwner: TComponent);
begin ShowDialog(AOwner, skProxy); end;
procedure ShowAccessDialog(AOwner: TComponent);
begin ShowDialog(AOwner, skAccess); end;
procedure ShowTimeDialog(AOwner: TComponent);
begin ShowDialog(AOwner, skTime); end;
procedure ShowSshDialog(AOwner: TComponent);
begin ShowDialog(AOwner, skSsh); end;
procedure ShowProfileDialog(AOwner: TComponent);
begin ShowDialog(AOwner, skProfile); end;
procedure ShowDiskDialog(AOwner: TComponent);
begin ShowDialog(AOwner, skDisk); end;

end.
