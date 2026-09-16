unit uLinuxSetupManagerMain;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, IniFiles, Forms, Controls, StdCtrls, ExtCtrls, Process, Dialogs,
  Graphics, LCLIntf, ComCtrls;

type
  TLinuxSetupManagerForm = class(TForm)
  private
    fFunctionList: TListBox;
    fDescriptionMemo: TMemo;
    fNamePanel: TPanel;
    fWolPanel: TPanel;
    fSharePanel: TPanel;
    fConnectPanel: TPanel;
    fMeraAssociationPanel: TPanel;
    fFileAssociationPanel: TPanel;
    fDesktopShortcutPanel: TPanel;
    fAdvancedPanel: TPanel;
    fAdvancedOpenButton: TButton;
    fCurrentNameValue: TLabel;
    fNewNameEdit: TEdit;
    fSharePathEdit: TEdit;
    fPublishShareNameEdit: TEdit;
    fPublishedShares: TListView;
    fHostEdit: TEdit;
    fSmbShareEdit: TEdit;
    fLocalNameEdit: TEdit;
    fResourcesList: TListBox;
    fAssociationFileEdit: TEdit;
    fAssociationProgramEdit: TEdit;
    fShortcutExecutableEdit: TEdit;
    fShortcutArgumentsEdit: TEdit;
    fShortcutElevatedCheck: TCheckBox;
    fShortcutDesktopCheck: TCheckBox;
    fShortcutAutostartCheck: TCheckBox;
    fProgramsTree: TTreeView;
    fAutostartCombo: TComboBox;
    fProgramExecs: TStringList;
    fProgramNames: TStringList;
    fShortcutName: string;
    fStatusLabel: TLabel;
    procedure ApplyNameClick(Sender: TObject);
    procedure EnableWolClick(Sender: TObject);
    procedure FunctionSelect(Sender: TObject; User: Boolean);
    procedure BrowseShareClick(Sender: TObject);
    procedure PublishShareClick(Sender: TObject);
    procedure RefreshPublishedClick(Sender: TObject);
    procedure PublishedShareSelect(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure UpdatePublishedClick(Sender: TObject);
    procedure DeletePublishedClick(Sender: TObject);
    procedure ConnectShareClick(Sender: TObject);
    procedure DisconnectShareClick(Sender: TObject);
    procedure OpenShareClick(Sender: TObject);
    procedure RefreshSharesClick(Sender: TObject);
    procedure ResourceSelect(Sender: TObject; User: Boolean);
    procedure RefreshNameClick(Sender: TObject);
    procedure AssociateMeraClick(Sender: TObject);
    procedure BrowseAssociationFileClick(Sender: TObject);
    procedure BrowseAssociationProgramClick(Sender: TObject);
    procedure AssociateFileClick(Sender: TObject);
    procedure BrowseShortcutExecutableClick(Sender: TObject);
    procedure CreateDesktopShortcutClick(Sender: TObject);
    procedure ProgramSelect(Sender: TObject);
    procedure AutostartSelect(Sender: TObject);
    procedure RemoveAutostartClick(Sender: TObject);
    procedure ReconnectShareClick(Sender: TObject);
    procedure OpenAdvancedClick(Sender: TObject);
    procedure BuildUi;
    function ReadComputerName: string;
    function RunHelper(const AExecutable: string;
      const AArgument: string = ''): Boolean;
    function RunHelperArgs(const AExecutable: string;
      const AArguments: array of string): Boolean;
    function RunNetworkHelper(const AAction: string): Boolean;
    procedure RefreshShares;
    procedure RefreshPublishedShares;
    function RunPublishAction(const AArguments: array of string;
      AElevated: Boolean; out AOutput: string): Boolean;
    procedure RefreshCurrentName;
    procedure LoadPrograms;
    procedure LoadProgramsFrom(const ADirectory: string);
    function ProgramCategory(const ACategories: string): string;
    function CategoryNode(const AName: string): TTreeNode;
    procedure RefreshAutostart;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  LinuxSetupManagerForm: TLinuxSetupManagerForm;

implementation

uses
  uLinuxSetupManagerSystemDialogs, fpjson, jsonparser;

const
  CHostnameHelper = '/usr/local/sbin/recorderlnx-set-hostname';
  CWolHelper = '/usr/local/sbin/recorderlnx-configure-wol';
  CShareHelper = '/usr/local/sbin/recorderlnx-share-folder';
  CConnectHelper = '/usr/local/sbin/recorderlnx-connect-share';
  CMeraAssociationHelper = '/usr/local/sbin/recorderlnx-associate-mera-winpos';
  CFileAssociationHelper = '/usr/local/sbin/recorderlnx-associate-file';
  CDesktopShortcutHelper = '/usr/local/sbin/recorderlnx-create-desktop-shortcut';
  CMountRoot = '/home/user/Сеть/MeraFiles';
  CRegistryDir = '/etc/recorderlnx/network-shares.d';

function AddLabel(AOwner: TComponent; AParent: TWinControl; ALeft, ATop,
  AWidth: Integer; const ACaption: string): TLabel;
begin
  Result := TLabel.Create(AOwner);
  Result.Parent := AParent;
  Result.SetBounds(ALeft, ATop, AWidth, 24);
  Result.Caption := ACaption;
end;

function AddButton(AOwner: TComponent; AParent: TWinControl; ALeft, ATop,
  AWidth: Integer; const ACaption: string; AHandler: TNotifyEvent): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Parent := AParent;
  Result.SetBounds(ALeft, ATop, AWidth, 32);
  Result.Caption := ACaption;
  Result.OnClick := AHandler;
end;

function HostnameHelp: string;
begin
  Result :=
    'Что делает:' + LineEnding +
    'Изменяет системное имя этого Linux-ПК. Новое имя используется системой, ' +
    'Samba и средствами диагностики. Допустимы латинские буквы, цифры и дефис.' +
    LineEnding + LineEnding +
    'Команда:' + LineEnding +
    'sudo /usr/local/sbin/recorderlnx-set-hostname KIP-4' +
    LineEnding + LineEnding +
    'Что изменяется в системе:' + LineEnding +
    '• hostnamectl set-hostname сохраняет имя в /etc/hostname;' + LineEnding +
    '• в /etc/hosts старое имя заменяется новым или добавляется строка 127.0.1.1;' + LineEnding +
    '• служба smbd перечитывает имя.' + LineEnding + LineEnding +
    'Проверка: hostnamectl; hostname; cat /etc/hostname; ' +
    'getent hosts KIP-4; systemctl status smbd';
end;

function WolHelp: string;
begin
  Result :=
    'Что делает:' + LineEnding +
    'Включает Wake-on-LAN (magic packet) для интерфейса enp3s0 сразу и после ' +
    'каждой перезагрузки.' + LineEnding + LineEnding +
    'Команда:' + LineEnding +
    'sudo /usr/local/sbin/recorderlnx-configure-wol' + LineEnding + LineEnding +
    'Прямая команда без сохранения после перезагрузки:' + LineEnding +
    'sudo ethtool -s enp3s0 wol g' + LineEnding + LineEnding +
    'Что изменяется в системе:' + LineEnding +
    '• ethtool -s enp3s0 wol g включает WOL в сетевом адаптере;' + LineEnding +
    '• создаётся /etc/systemd/system/recorderlnx-wol.service;' + LineEnding +
    '• systemctl enable добавляет автозапуск службы в multi-user.target.' +
    LineEnding + LineEnding +
    'Проверка: ethtool enp3s0 | grep Wake-on; ' +
    'systemctl status recorderlnx-wol.service; ' +
    'systemctl is-enabled recorderlnx-wol.service.' + LineEnding +
    'Утилита не изменяет настройки WOL в BIOS/UEFI.';
end;

function PublishHelp: string;
begin
  Result :=
    'Что делает:' + LineEnding +
    'Публикует выбранный локальный каталог как SMB-ресурс с заданным сетевым ' +
    'именем. Для Samba используется постоянная точка /srv/recorderlnx/<имя>.' +
    LineEnding + LineEnding +
    'Команда:' + LineEnding +
    'sudo /usr/local/sbin/recorderlnx-share-folder "/путь/к/каталогу" MeraFiles' +
    LineEnding +
    'LinuxSetupManagerCli --internal publish list' + LineEnding +
    'sudo LinuxSetupManagerCli --internal publish update MeraFiles "/новый/каталог"' +
    LineEnding +
    'sudo LinuxSetupManagerCli --internal publish delete MeraFiles' +
    LineEnding + LineEnding +
    'Что изменяется в системе:' + LineEnding +
    '• каталог bind-монтируется в /srv/recorderlnx/<имя>;' + LineEnding +
    '• в /etc/fstab добавляется строка с меткой recorderlnx-share-<имя>-bind;' +
    LineEnding +
    '• в /etc/samba/smb.conf добавляется управляемая секция [<имя>];' + LineEnding +
    '• testparm проверяет smb.conf, затем smbd перечитывает конфигурацию;' +
    LineEnding +
    '• гостевой доступ выключен; пользователю user разрешено только чтение;' +
    LineEnding +
    '• список, изменение пути и удаление затрагивают только публикации с ' +
    'маркерами нашей утилиты; чужие секции Samba не изменяются.' +
    LineEnding + LineEnding +
    'Проверка: findmnt /srv/recorderlnx/MeraFiles; ' +
    'testparm -s; smbclient -L localhost -U user';
end;

function ConnectHelp: string;
begin
  Result :=
    'Что делает:' + LineEnding +
    'Подключает SMB-ресурс другого ПК в /home/user/Сеть/MeraFiles/<имя>. ' +
    'Содержимое читает CIFS при обращении к каталогу; пароль в командной строке ' +
    'не передаётся.' + LineEnding + LineEnding +
    'Команды:' + LineEnding +
    'sudo /usr/local/sbin/recorderlnx-connect-share connect ' +
    '192.168.9.85 MeraFiles KIP-4' + LineEnding +
    'sudo /usr/local/sbin/recorderlnx-connect-share disconnect - - KIP-4' +
    LineEnding + LineEnding +
    'Что изменяется в системе:' + LineEnding +
    '• параметры сохраняются в /etc/recorderlnx/network-shares.d/<имя>.ini;' +
    LineEnding +
    '• учётные данные берутся из /etc/samba/kip-obmen.credentials;' + LineEnding +
    '• mount -t cifs создаёт системное монтирование SMB 3.0, а при отказе — 2.1;' +
    LineEnding +
    '• восстановление выполняет recorderlnx-network-shares.service. В пакете ' +
    '0.1.11 также установлен recorderlnx-network-shares.timer;' + LineEnding +
    '• операции защищены блокировкой ' +
    '/run/lock/recorderlnx-network-shares.lock;' + LineEnding +
    '• при отключении монтирование, INI-запись и пустая локальная папка удаляются.' +
    LineEnding + LineEnding +
    'Ручное восстановление: sudo /usr/local/sbin/recorderlnx-connect-share restore' +
    LineEnding + LineEnding +
    'Проверка: mountpoint "/home/user/Сеть/MeraFiles/KIP-4"; ' +
    'findmnt -t cifs; systemctl status recorderlnx-network-shares.service';
end;

function MeraAssociationHelp: string;
begin
  Result :=
    'Что делает:' + LineEnding +
    'Назначает WinПОС через Wine программой по умолчанию для файлов *.mera. ' +
    'После настройки двойной щелчок по замеру и команда OpenDocument из ' +
    'RecorderLnx передают выбранный файл в WinPOS.' + LineEnding + LineEnding +
    'Команда:' + LineEnding +
    'sudo /usr/local/sbin/recorderlnx-associate-mera-winpos' +
    LineEnding + LineEnding +
    'Что изменяется в системе:' + LineEnding +
    '• MIME-тип application/x-mera-measurement описывается в ' +
    '/usr/share/mime/packages/recorderlnx-mera.xml;' + LineEnding +
    '• обработчик создаётся в /usr/share/applications/recorderlnx-winpos.desktop;' +
    LineEnding +
    '• launcher /usr/local/bin/recorderlnx-open-mera-winpos запускает ' +
    '~/.wine/drive_c/Program Files (x86)/MERA/WinPOS/WinPos.exe;' + LineEnding +
    '• выбор по умолчанию сохраняется для текущего пользователя в ' +
    '~/.config/mimeapps.list.' + LineEnding + LineEnding +
    'Проверка: xdg-mime query default application/x-mera-measurement; ' +
    'xdg-mime query filetype "/путь/к/замеру.mera"';
end;

function FileAssociationHelp: string;
begin
  Result :=
    'Что делает:' + LineEnding +
    'Назначает выбранную Linux-программу обработчиком файлов с тем же ' +
    'расширением, что у файла-примера. Диалоги «...» позволяют выбрать сначала ' +
    'файл, затем исполняемый файл программы.' + LineEnding + LineEnding +
    'Команда:' + LineEnding +
    'sudo /usr/local/sbin/recorderlnx-associate-file ' +
    '"/путь/пример.ext" "/usr/bin/программа"' + LineEnding + LineEnding +
    'Что изменяется в системе:' + LineEnding +
    '• создаётся MIME XML в /usr/share/mime/packages/;' + LineEnding +
    '• создаются launcher в /usr/local/bin/ и desktop-файл в ' +
    '/usr/share/applications/;' + LineEnding +
    '• выбор по умолчанию записывается в ~/.config/mimeapps.list.' +
    LineEnding + LineEnding +
    'Проверка: xdg-mime query filetype "/путь/пример.ext"; ' +
    'xdg-mime query default <полученный-MIME-тип>';
end;

function DesktopShortcutHelp: string;
begin
  Result :=
    'Что делает:' + LineEnding +
    'Показывает программы из /usr/share/applications и ' +
    '~/.local/share/applications с категориями и командой Exec. Создаёт ярлык ' +
    'на рабочем столе и/или запись автозапуска. Список автозапуска можно ' +
    'редактировать. Флажок административного запуска ' +
    'добавляет pkexec: система запрашивает пароль через штатный диалог PolicyKit, ' +
    'пароль в ярлыке не хранится.' + LineEnding + LineEnding +
    'Команды:' + LineEnding +
    'pkexec /opt/mera/RecorderLnx/LinuxSetupManager --internal programs apply ' +
    '"/usr/bin/program" "--параметр значение" true true false "Program"' +
    LineEnding +
    'pkexec /opt/mera/RecorderLnx/LinuxSetupManager --internal programs ' +
    'remove-autostart "Program.desktop"' +
    LineEnding + LineEnding +
    'Что изменяется в системе:' + LineEnding +
    '• ярлык создаётся в каталоге из xdg-user-dir DESKTOP;' + LineEnding +
    '• автозапуск хранится в ~/.config/autostart/<имя>.desktop;' + LineEnding +
    '• файл принадлежит пользователю, получает право на выполнение и, если ' +
    'файловый менеджер поддерживает этот атрибут, помечается metadata::trusted;' +
    LineEnding +
    '• при административном запуске Exec начинается с /usr/bin/pkexec; ' +
    'sudoers, /etc/sudoers и сохранённые пароли не изменяются.' +
    LineEnding + LineEnding +
    'Проверка: xdg-user-dir DESKTOP; ls -l ~/.config/autostart; ' +
    'gio info "$(xdg-user-dir DESKTOP)/<имя>.desktop"';
end;

constructor TLinuxSetupManagerForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner, 1);
  fProgramExecs := TStringList.Create;
  fProgramNames := TStringList.Create;
  BuildUi;
  RefreshCurrentName;
  fFunctionList.ItemIndex := 0;
  FunctionSelect(fFunctionList, False);
end;

procedure TLinuxSetupManagerForm.BuildUi;
var
  lRightPanel, lDescriptionPanel, lContentPanel: TPanel;
  lDescriptionSplitter: TSplitter;
begin
  Caption := 'Настройка Linux';
  SetBounds(180, 120, 840, 610);
  Constraints.MinWidth := 820;
  Constraints.MinHeight := 480;
  Position := poScreenCenter;
  fFunctionList := TListBox.Create(Self);
  fFunctionList.Parent := Self;
  fFunctionList.Align := alLeft;
  fFunctionList.Width := 250;
  fFunctionList.Items.Add('Имя компьютера');
  fFunctionList.Items.Add('Wake-on-LAN');
  fFunctionList.Items.Add('Опубликовать каталог');
  fFunctionList.Items.Add('Подключить сетевой ресурс');
  fFunctionList.Items.Add('Открывать .mera в WinПОС');
  fFunctionList.Items.Add('Ассоциация файла с программой');
  fFunctionList.Items.Add('Программы и автозапуск');
  fFunctionList.Items.Add('Сеть и маршруты');
  fFunctionList.Items.Add('Прокси');
  fFunctionList.Items.Add('Пользователи и права');
  fFunctionList.Items.Add('Дата и время');
  fFunctionList.Items.Add('Удалённый доступ SSH');
  fFunctionList.Items.Add('Импорт и экспорт профиля');
  fFunctionList.Items.Add('Диски и монтирование');
  fFunctionList.OnSelectionChange := @FunctionSelect;
  lRightPanel := TPanel.Create(Self);
  lRightPanel.Parent := Self;
  lRightPanel.Align := alClient;
  lRightPanel.BevelOuter := bvNone;
  lDescriptionPanel := TPanel.Create(Self);
  lDescriptionPanel.Parent := lRightPanel;
  lDescriptionPanel.Align := alBottom;
  lDescriptionPanel.Height := 190;
  lDescriptionPanel.Constraints.MinHeight := 80;
  lDescriptionSplitter := TSplitter.Create(Self);
  lDescriptionSplitter.Parent := lRightPanel;
  lDescriptionSplitter.Align := alBottom;
  lDescriptionSplitter.Height := 6;
  lDescriptionSplitter.Color := $00D9AF78;
  lDescriptionSplitter.ParentColor := False;
  lDescriptionSplitter.ResizeAnchor := akBottom;
  lContentPanel := TPanel.Create(Self);
  lContentPanel.Parent := lRightPanel;
  lContentPanel.Align := alClient;
  lContentPanel.BevelOuter := bvNone;
  lContentPanel.Constraints.MinHeight := 300;
  AddLabel(Self, lDescriptionPanel, 12, 8, 250, 'Что делает эта функция');
  fDescriptionMemo := TMemo.Create(Self);
  fDescriptionMemo.Parent := lDescriptionPanel;
  fDescriptionMemo.SetBounds(12, 32, 500, 145);
  fDescriptionMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  fDescriptionMemo.ReadOnly := True;
  fDescriptionMemo.WordWrap := True;
  fDescriptionMemo.ScrollBars := ssVertical;
  fStatusLabel := AddLabel(Self, lContentPanel, 16, 270, 510, '');
  fStatusLabel.AutoSize := False;
  fStatusLabel.Align := alBottom;
  fStatusLabel.Height := 24;
  fStatusLabel.BorderSpacing.Left := 16;
  fNamePanel := TPanel.Create(Self);
  fNamePanel.Parent := lContentPanel;
  fNamePanel.SetBounds(0, 0, 535, 265);
  fNamePanel.Anchors := [akLeft, akTop, akRight];
  fNamePanel.BevelOuter := bvNone;
  AddLabel(Self, fNamePanel, 16, 28, 170, 'Текущее имя');
  fCurrentNameValue := AddLabel(Self, fNamePanel, 190, 28, 320, '');
  fCurrentNameValue.Font.Style := [fsBold];
  AddLabel(Self, fNamePanel, 16, 76, 170, 'Новое имя');
  fNewNameEdit := TEdit.Create(Self);
  fNewNameEdit.Parent := fNamePanel;
  fNewNameEdit.SetBounds(190, 72, 320, 28);
  fNewNameEdit.Hint := 'Например: KIP-4';
  fNewNameEdit.ShowHint := True;
  AddButton(Self, fNamePanel, 190, 124, 150, 'Переименовать', @ApplyNameClick);
  AddButton(Self, fNamePanel, 350, 124, 160, 'Обновить', @RefreshNameClick);
  fWolPanel := TPanel.Create(Self);
  fWolPanel.Parent := lContentPanel;
  fWolPanel.SetBounds(0, 0, 535, 265);
  fWolPanel.Anchors := [akLeft, akTop, akRight];
  fWolPanel.BevelOuter := bvNone;
  AddLabel(Self, fWolPanel, 16, 28, 490, 'Сетевой интерфейс: enp3s0');
  AddButton(Self, fWolPanel, 190, 72, 180, 'Включить Wake-on-LAN',
    @EnableWolClick);
  fSharePanel := TPanel.Create(Self);
  fSharePanel.Parent := lContentPanel;
  fSharePanel.SetBounds(0, 0, 535, 265);
  fSharePanel.Align := alClient;
  fSharePanel.BevelOuter := bvNone;
  AddLabel(Self, fSharePanel, 16, 28, 490, 'Каталог для публикации');
  fSharePathEdit := TEdit.Create(Self);
  fSharePathEdit.Parent := fSharePanel;
  fSharePathEdit.SetBounds(16, 58, 440, 28);
  AddButton(Self, fSharePanel, 465, 56, 45, '...', @BrowseShareClick);
  AddLabel(Self, fSharePanel, 16, 100, 150, 'Сетевое имя');
  fPublishShareNameEdit := TEdit.Create(Self);
  fPublishShareNameEdit.Parent := fSharePanel;
  fPublishShareNameEdit.SetBounds(170, 96, 340, 28);
  fPublishShareNameEdit.Text := 'MeraFiles';
  AddButton(Self, fSharePanel, 16, 142, 118, 'Опубликовать',
    @PublishShareClick);
  AddButton(Self, fSharePanel, 142, 142, 92, 'Обновить',
    @RefreshPublishedClick);
  AddButton(Self, fSharePanel, 242, 142, 125, 'Изменить путь',
    @UpdatePublishedClick);
  AddButton(Self, fSharePanel, 375, 142, 135, 'Удалить ресурс',
    @DeletePublishedClick);
  AddLabel(Self, fSharePanel, 16, 178, 490, 'Опубликованные ресурсы');
  fPublishedShares := TListView.Create(Self);
  fPublishedShares.Parent := fSharePanel;
  fPublishedShares.SetBounds(16, 200, 494, fSharePanel.ClientHeight - 210);
  fPublishedShares.Anchors := [akLeft, akTop, akRight, akBottom];
  fPublishedShares.ViewStyle := vsReport;
  fPublishedShares.RowSelect := True;
  fPublishedShares.ReadOnly := True;
  fPublishedShares.Columns.Add.Caption := 'Сетевое имя';
  fPublishedShares.Columns[0].Width := 140;
  fPublishedShares.Columns.Add.Caption := 'Локальный каталог';
  fPublishedShares.Columns[1].Width := 340;
  fPublishedShares.OnSelectItem := @PublishedShareSelect;
  fConnectPanel := TPanel.Create(Self);
  fConnectPanel.Parent := lContentPanel;
  fConnectPanel.SetBounds(0, 0, 535, 265);
  fConnectPanel.Anchors := [akLeft, akTop, akRight];
  fConnectPanel.BevelOuter := bvNone;
  AddLabel(Self, fConnectPanel, 16, 12, 150, 'Хост или IP');
  fHostEdit := TEdit.Create(Self); fHostEdit.Parent := fConnectPanel;
  fHostEdit.SetBounds(170, 8, 340, 26);
  AddLabel(Self, fConnectPanel, 16, 48, 150, 'SMB-ресурс');
  fSmbShareEdit := TEdit.Create(Self); fSmbShareEdit.Parent := fConnectPanel;
  fSmbShareEdit.SetBounds(170, 44, 340, 26); fSmbShareEdit.Text := 'MeraFiles';
  AddLabel(Self, fConnectPanel, 16, 84, 150, 'Локальное имя');
  fLocalNameEdit := TEdit.Create(Self); fLocalNameEdit.Parent := fConnectPanel;
  fLocalNameEdit.SetBounds(170, 80, 340, 26);
  AddButton(Self, fConnectPanel, 16, 118, 94, 'Подключить', @ConnectShareClick);
  AddButton(Self, fConnectPanel, 116, 118, 94, 'Отключить', @DisconnectShareClick);
  AddButton(Self, fConnectPanel, 216, 118, 94, 'Переподкл.', @ReconnectShareClick);
  AddButton(Self, fConnectPanel, 316, 118, 94, 'Открыть', @OpenShareClick);
  AddButton(Self, fConnectPanel, 416, 118, 94, 'Обновить', @RefreshSharesClick);
  fResourcesList := TListBox.Create(Self);
  fResourcesList.Parent := fConnectPanel;
  fResourcesList.SetBounds(16, 158, 494, 96);
  fResourcesList.OnSelectionChange := @ResourceSelect;
  fMeraAssociationPanel := TPanel.Create(Self);
  fMeraAssociationPanel.Parent := lContentPanel;
  fMeraAssociationPanel.SetBounds(0, 0, 535, 265);
  fMeraAssociationPanel.Anchors := [akLeft, akTop, akRight];
  fMeraAssociationPanel.BevelOuter := bvNone;
  AddLabel(Self, fMeraAssociationPanel, 16, 28, 490,
    'Программа для файлов *.mera: WinПОС через Wine');
  AddButton(Self, fMeraAssociationPanel, 150, 72, 240,
    'Назначить WinПОС', @AssociateMeraClick);
  fFileAssociationPanel := TPanel.Create(Self);
  fFileAssociationPanel.Parent := lContentPanel;
  fFileAssociationPanel.SetBounds(0, 0, 535, 265);
  fFileAssociationPanel.Anchors := [akLeft, akTop, akRight];
  fFileAssociationPanel.BevelOuter := bvNone;
  AddLabel(Self, fFileAssociationPanel, 16, 24, 150, 'Файл-пример');
  fAssociationFileEdit := TEdit.Create(Self);
  fAssociationFileEdit.Parent := fFileAssociationPanel;
  fAssociationFileEdit.SetBounds(170, 20, 286, 28);
  AddButton(Self, fFileAssociationPanel, 465, 18, 45, '...',
    @BrowseAssociationFileClick);
  AddLabel(Self, fFileAssociationPanel, 16, 68, 150, 'Программа');
  fAssociationProgramEdit := TEdit.Create(Self);
  fAssociationProgramEdit.Parent := fFileAssociationPanel;
  fAssociationProgramEdit.SetBounds(170, 64, 286, 28);
  AddButton(Self, fFileAssociationPanel, 465, 62, 45, '...',
    @BrowseAssociationProgramClick);
  AddButton(Self, fFileAssociationPanel, 170, 112, 220,
    'Назначить программу', @AssociateFileClick);
  fDesktopShortcutPanel := TPanel.Create(Self);
  fDesktopShortcutPanel.Parent := lContentPanel;
  fDesktopShortcutPanel.SetBounds(0, 0, 535, 280);
  fDesktopShortcutPanel.Anchors := [akLeft, akTop, akRight];
  fDesktopShortcutPanel.BevelOuter := bvNone;
  AddLabel(Self, fDesktopShortcutPanel, 16, 8, 225, 'Установленные программы');
  fProgramsTree := TTreeView.Create(Self);
  fProgramsTree.Parent := fDesktopShortcutPanel;
  fProgramsTree.SetBounds(16, 34, 226, 235);
  fProgramsTree.ReadOnly := True;
  fProgramsTree.OnSelectionChanged := @ProgramSelect;
  AddLabel(Self, fDesktopShortcutPanel, 252, 8, 250, 'Исполняемый файл / Exec');
  fShortcutExecutableEdit := TEdit.Create(Self);
  fShortcutExecutableEdit.Parent := fDesktopShortcutPanel;
  fShortcutExecutableEdit.SetBounds(252, 32, 204, 28);
  AddButton(Self, fDesktopShortcutPanel, 465, 30, 45, '...',
    @BrowseShortcutExecutableClick);
  AddLabel(Self, fDesktopShortcutPanel, 252, 64, 250, 'Параметры запуска');
  fShortcutArgumentsEdit := TEdit.Create(Self);
  fShortcutArgumentsEdit.Parent := fDesktopShortcutPanel;
  fShortcutArgumentsEdit.SetBounds(252, 88, 258, 28);
  fShortcutDesktopCheck := TCheckBox.Create(Self);
  fShortcutDesktopCheck.Parent := fDesktopShortcutPanel;
  fShortcutDesktopCheck.SetBounds(252, 120, 258, 24);
  fShortcutDesktopCheck.Caption := 'Создать ярлык на рабочем столе';
  fShortcutDesktopCheck.Checked := True;
  fShortcutAutostartCheck := TCheckBox.Create(Self);
  fShortcutAutostartCheck.Parent := fDesktopShortcutPanel;
  fShortcutAutostartCheck.SetBounds(252, 144, 258, 24);
  fShortcutAutostartCheck.Caption := 'Добавить в автозапуск';
  fShortcutElevatedCheck := TCheckBox.Create(Self);
  fShortcutElevatedCheck.Parent := fDesktopShortcutPanel;
  fShortcutElevatedCheck.SetBounds(252, 168, 258, 24);
  fShortcutElevatedCheck.Caption := 'Запускать с правами администратора';
  AddButton(Self, fDesktopShortcutPanel, 365, 192, 145,
    'Применить', @CreateDesktopShortcutClick);
  AddLabel(Self, fDesktopShortcutPanel, 252, 224, 200, 'Автозапуск');
  fAutostartCombo := TComboBox.Create(Self);
  fAutostartCombo.Parent := fDesktopShortcutPanel;
  fAutostartCombo.SetBounds(252, 246, 200, 28);
  fAutostartCombo.Style := csDropDownList;
  fAutostartCombo.OnChange := @AutostartSelect;
  AddButton(Self, fDesktopShortcutPanel, 460, 244, 66,
    'Удалить', @RemoveAutostartClick);
  LoadPrograms;
  RefreshAutostart;
  fAdvancedPanel := TPanel.Create(Self);
  fAdvancedPanel.Parent := lContentPanel;
  fAdvancedPanel.SetBounds(0, 0, 535, 265);
  fAdvancedPanel.Anchors := [akLeft, akTop, akRight];
  fAdvancedPanel.BevelOuter := bvNone;
  AddLabel(Self, fAdvancedPanel, 16, 36, 495,
    'Откройте диалог настройки выбранного системного раздела.');
  fAdvancedOpenButton := AddButton(Self, fAdvancedPanel, 145, 84, 250,
    'Открыть настройки', @OpenAdvancedClick);
  fStatusLabel.BringToFront;
end;

destructor TLinuxSetupManagerForm.Destroy;
begin
  fProgramNames.Free;
  fProgramExecs.Free;
  inherited Destroy;
end;

procedure TLinuxSetupManagerForm.FunctionSelect(Sender: TObject; User: Boolean);
begin
  fNamePanel.Visible := fFunctionList.ItemIndex = 0;
  fWolPanel.Visible := fFunctionList.ItemIndex = 1;
  fSharePanel.Visible := fFunctionList.ItemIndex = 2;
  fConnectPanel.Visible := fFunctionList.ItemIndex = 3;
  fMeraAssociationPanel.Visible := fFunctionList.ItemIndex = 4;
  fFileAssociationPanel.Visible := fFunctionList.ItemIndex = 5;
  fDesktopShortcutPanel.Visible := fFunctionList.ItemIndex = 6;
  fAdvancedPanel.Visible := fFunctionList.ItemIndex >= 7;
  fStatusLabel.Caption := '';
  case fFunctionList.ItemIndex of
    0: fDescriptionMemo.Text := HostnameHelp;
    1: fDescriptionMemo.Text := WolHelp;
    2: begin
      fDescriptionMemo.Text := PublishHelp;
      RefreshPublishedShares;
    end;
    3: begin
      fDescriptionMemo.Text := ConnectHelp;
      RefreshShares;
    end;
    4: fDescriptionMemo.Text := MeraAssociationHelp;
    5: fDescriptionMemo.Text := FileAssociationHelp;
    6: begin
      fDescriptionMemo.Text := DesktopShortcutHelp;
      RefreshAutostart;
    end;
    7: begin fAdvancedOpenButton.Caption := 'Настроить сеть и маршруты';
      fDescriptionMemo.Text := 'IPv4, DHCP, DNS и постоянные маршруты. Перед применением показывается план, системные файлы резервируются.'; end;
    8: begin fAdvancedOpenButton.Caption := 'Настроить прокси';
      fDescriptionMemo.Text := 'Прокси для APT, системы и пользователя. Пароль не показывается в отчётах и профилях.'; end;
    9: begin fAdvancedOpenButton.Caption := 'Настроить права';
      fDescriptionMemo.Text := 'Группы пользователя и ACL чтения/записи для редактируемого списка каталогов без смены владельца.'; end;
    10: begin fAdvancedOpenButton.Caption := 'Настроить дату и время';
      fDescriptionMemo.Text := 'Часовой пояс, NTP, серверы синхронизации и текущее состояние systemd-timesyncd.'; end;
    11: begin fAdvancedOpenButton.Caption := 'Настроить SSH';
      fDescriptionMemo.Text := 'Служба OpenSSH, автозапуск, firewall и установка только публичного ключа выбранному пользователю.'; end;
    12: begin fAdvancedOpenButton.Caption := 'Открыть менеджер профилей';
      fDescriptionMemo.Text := 'Экспорт и выборочный импорт универсальных настроек ПК. Секреты и приватные ключи не переносятся.'; end;
    13: begin fAdvancedOpenButton.Caption := 'Открыть менеджер дисков';
      fDescriptionMemo.Text :=
        'Диски, разделы, занятое и свободное место; монтаж по UUID. ' +
        'Кнопка «Исправить NTFS» помогает, когда фактически диск подключился ' +
        'только для чтения из-за ошибки файловой системы. Перед сбросом ' +
        'журнала NTFS показывается предупреждение о возможной потере данных. ' +
        'Открытые файлы и занятый диск сначала нужно освободить.' + LineEnding +
        'Консоль: sudo LinuxSetupManagerCli --internal disks repair-ntfs ' +
        '/dev/sda1 --confirm-device /dev/sda1 --confirm-uuid <UUID> ' +
        '--accept-data-risk yes. Устройство и UUID сначала сверить через lsblk.' +
        LineEnding + 'Системные данные: параметры постоянного подключения ' +
        'хранятся в /etc/fstab; фактический режим проверяется через findmnt. ' +
        'После ремонта утилита возвращает автомонтирование и проверяет запись.'; end;
  else
    fDescriptionMemo.Clear;
  end;
end;

procedure TLinuxSetupManagerForm.OpenAdvancedClick(Sender: TObject);
begin
  case fFunctionList.ItemIndex of
    7: ShowNetworkDialog(Self);
    8: ShowProxyDialog(Self);
    9: ShowAccessDialog(Self);
    10: ShowTimeDialog(Self);
    11: ShowSshDialog(Self);
    12: ShowProfileDialog(Self);
    13: ShowDiskDialog(Self);
  end;
end;

procedure TLinuxSetupManagerForm.BrowseShortcutExecutableClick(Sender: TObject);
var
  lDialog: TOpenDialog;
begin
  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Выберите исполняемый файл';
    lDialog.InitialDir := '/usr/bin';
    if lDialog.Execute then
    begin
      fShortcutExecutableEdit.Text := lDialog.FileName;
      fShortcutName := ChangeFileExt(ExtractFileName(lDialog.FileName), '');
      fProgramsTree.Selected := nil;
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TLinuxSetupManagerForm.CreateDesktopShortcutClick(Sender: TObject);
var
  lAutostart, lDesktop, lElevated, lName: string;
begin
  if Trim(fShortcutExecutableEdit.Text) = '' then
  begin
    MessageDlg('Выберите программу или введите исполняемый файл / Exec.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  if not fShortcutDesktopCheck.Checked and not fShortcutAutostartCheck.Checked then
  begin
    MessageDlg('Выберите создание ярлыка и/или добавление в автозапуск.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  if fShortcutElevatedCheck.Checked then
    lElevated := 'true'
  else
    lElevated := 'false';
  if fShortcutDesktopCheck.Checked then lDesktop := 'true' else lDesktop := 'false';
  if fShortcutAutostartCheck.Checked then lAutostart := 'true' else lAutostart := 'false';
  lName := Trim(fShortcutName);
  if lName = '' then
    lName := ChangeFileExt(ExtractFileName(fShortcutExecutableEdit.Text), '');
  if RunHelperArgs(CDesktopShortcutHelper, ['apply', fShortcutExecutableEdit.Text,
    fShortcutArgumentsEdit.Text, lDesktop, lAutostart, lElevated, lName]) then
  begin
    fStatusLabel.Caption := 'Настройки запуска сохранены.';
    RefreshAutostart;
  end
  else
    fStatusLabel.Caption := 'Не удалось сохранить настройки запуска.';
end;

procedure TLinuxSetupManagerForm.ProgramSelect(Sender: TObject);
var
  lExec: string;
  lIndex: PtrInt;
begin
  if (fProgramsTree.Selected = nil) or
    (fProgramsTree.Selected.Data = nil) then Exit;
  lIndex := PtrInt(fProgramsTree.Selected.Data) - 1;
  if (lIndex < 0) or (lIndex >= fProgramExecs.Count) then Exit;
  lExec := fProgramExecs[lIndex];
  lExec := StringReplace(lExec, '%f', '', [rfReplaceAll]);
  lExec := StringReplace(lExec, '%F', '', [rfReplaceAll]);
  lExec := StringReplace(lExec, '%u', '', [rfReplaceAll]);
  lExec := StringReplace(lExec, '%U', '', [rfReplaceAll]);
  lExec := StringReplace(lExec, '%i', '', [rfReplaceAll]);
  lExec := StringReplace(lExec, '%c', '', [rfReplaceAll]);
  lExec := StringReplace(lExec, '%k', '', [rfReplaceAll]);
  fShortcutExecutableEdit.Text := Trim(lExec);
  fShortcutName := fProgramNames[lIndex];
end;

procedure TLinuxSetupManagerForm.AutostartSelect(Sender: TObject);
var
  lConfig: TIniFile;
  lPath: string;
begin
  if fAutostartCombo.ItemIndex < 0 then Exit;
  lPath := IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
    '.config/autostart/' + fAutostartCombo.Items[fAutostartCombo.ItemIndex];
  lConfig := TIniFile.Create(lPath);
  try
    fShortcutExecutableEdit.Text :=
      lConfig.ReadString('Desktop Entry', 'Exec', '');
    fShortcutName := lConfig.ReadString('Desktop Entry', 'Name',
      ChangeFileExt(fAutostartCombo.Items[fAutostartCombo.ItemIndex], ''));
    fShortcutArgumentsEdit.Clear;
    fShortcutAutostartCheck.Checked := True;
    fShortcutDesktopCheck.Checked := False;
    fShortcutElevatedCheck.Checked :=
      Pos('/usr/bin/pkexec ', fShortcutExecutableEdit.Text) = 1;
    if fShortcutElevatedCheck.Checked then
      fShortcutExecutableEdit.Text := Copy(fShortcutExecutableEdit.Text,
        Length('/usr/bin/pkexec ') + 1, MaxInt);
  finally
    lConfig.Free;
  end;
end;

procedure TLinuxSetupManagerForm.RemoveAutostartClick(Sender: TObject);
begin
  if fAutostartCombo.ItemIndex < 0 then Exit;
  if RunHelperArgs(CDesktopShortcutHelper, ['remove-autostart',
    fAutostartCombo.Items[fAutostartCombo.ItemIndex]]) then
  begin
    fStatusLabel.Caption := 'Запись удалена из автозапуска.';
    RefreshAutostart;
  end
  else
    fStatusLabel.Caption := 'Не удалось удалить запись автозапуска.';
end;

function TLinuxSetupManagerForm.ProgramCategory(const ACategories: string): string;
var
  lCategories: string;
begin
  lCategories := ';' + ACategories + ';';
  if Pos(';Office;', lCategories) > 0 then Exit('Офис');
  if Pos(';Network;', lCategories) > 0 then Exit('Интернет');
  if Pos(';Graphics;', lCategories) > 0 then Exit('Графика');
  if (Pos(';AudioVideo;', lCategories) > 0) or
    (Pos(';Audio;', lCategories) > 0) or
    (Pos(';Video;', lCategories) > 0) then Exit('Мультимедиа');
  if Pos(';Education;', lCategories) > 0 then Exit('Образование');
  if Pos(';Science;', lCategories) > 0 then Exit('Научные');
  if Pos(';Development;', lCategories) > 0 then Exit('Разработка');
  if Pos(';System;', lCategories) > 0 then Exit('Система');
  if Pos(';Settings;', lCategories) > 0 then Exit('Настройки');
  if Pos(';Utility;', lCategories) > 0 then Exit('Инструменты');
  if Pos(';Game;', lCategories) > 0 then Exit('Игры');
  Result := 'Прочие программы';
end;

function TLinuxSetupManagerForm.CategoryNode(const AName: string): TTreeNode;
begin
  Result := fProgramsTree.Items.GetFirstNode;
  while Result <> nil do
  begin
    if Result.Text = AName then Exit;
    Result := Result.GetNextSibling;
  end;
  Result := fProgramsTree.Items.Add(nil, AName);
end;

procedure TLinuxSetupManagerForm.LoadProgramsFrom(const ADirectory: string);
var
  lCategories, lExec, lName, lPath: string;
  lNode: TTreeNode;
  lConfig: TIniFile;
  lInfo: TSearchRec;
begin
  if FindFirst(IncludeTrailingPathDelimiter(ADirectory) + '*.desktop', faAnyFile,
    lInfo) <> 0 then Exit;
  try
    repeat
      if (lInfo.Attr and faDirectory) <> 0 then Continue;
      lPath := IncludeTrailingPathDelimiter(ADirectory) + lInfo.Name;
      lConfig := TIniFile.Create(lPath);
      try
        if lConfig.ReadBool('Desktop Entry', 'NoDisplay', False) or
          lConfig.ReadBool('Desktop Entry', 'Hidden', False) or
          (lConfig.ReadString('Desktop Entry', 'Type', 'Application') <>
            'Application') then Continue;
        lExec := Trim(lConfig.ReadString('Desktop Entry', 'Exec', ''));
        lName := Trim(lConfig.ReadString('Desktop Entry', 'Name[ru]', ''));
        if lName = '' then
          lName := Trim(lConfig.ReadString('Desktop Entry', 'Name', ''));
        if (lExec = '') or (lName = '') then Continue;
        lCategories := lConfig.ReadString('Desktop Entry', 'Categories', '');
        lNode := fProgramsTree.Items.AddChild(
          CategoryNode(ProgramCategory(lCategories)), lName);
        lNode.Data := Pointer(PtrInt(fProgramExecs.Count + 1));
        fProgramExecs.Add(lExec);
        fProgramNames.Add(lName);
      finally
        lConfig.Free;
      end;
    until FindNext(lInfo) <> 0;
  finally
    FindClose(lInfo);
  end;
end;

procedure TLinuxSetupManagerForm.LoadPrograms;
var
  lHome: string;
begin
  fProgramsTree.Items.BeginUpdate;
  try
    fProgramsTree.Items.Clear;
    fProgramExecs.Clear;
    fProgramNames.Clear;
    LoadProgramsFrom('/usr/share/applications');
    lHome := GetEnvironmentVariable('HOME');
    if lHome <> '' then
      LoadProgramsFrom(IncludeTrailingPathDelimiter(lHome) +
        '.local/share/applications');
    fProgramsTree.AlphaSort;
  finally
    fProgramsTree.Items.EndUpdate;
  end;
end;

procedure TLinuxSetupManagerForm.RefreshAutostart;
var
  lDirectory: string;
  lInfo: TSearchRec;
begin
  fAutostartCombo.Clear;
  lDirectory := IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
    '.config/autostart';
  if FindFirst(IncludeTrailingPathDelimiter(lDirectory) + '*.desktop', faAnyFile,
    lInfo) <> 0 then Exit;
  try
    repeat
      if (lInfo.Attr and faDirectory) = 0 then
        fAutostartCombo.Items.Add(lInfo.Name);
    until FindNext(lInfo) <> 0;
  finally
    FindClose(lInfo);
  end;
  if fAutostartCombo.Items.Count > 0 then fAutostartCombo.ItemIndex := 0;
end;

procedure TLinuxSetupManagerForm.AssociateMeraClick(Sender: TObject);
begin
  if RunHelper(CMeraAssociationHelper) then
    fStatusLabel.Caption := 'Файлы .mera назначены WinПОС через Wine.'
  else
    fStatusLabel.Caption := 'Не удалось назначить WinПОС для файлов .mera.';
end;

procedure TLinuxSetupManagerForm.BrowseAssociationFileClick(Sender: TObject);
var
  lDialog: TOpenDialog;
begin
  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Выберите файл-пример';
    if lDialog.Execute then
      fAssociationFileEdit.Text := lDialog.FileName;
  finally
    lDialog.Free;
  end;
end;

procedure TLinuxSetupManagerForm.BrowseAssociationProgramClick(Sender: TObject);
var
  lDialog: TOpenDialog;
begin
  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Выберите исполняемый файл программы';
    lDialog.InitialDir := '/usr/bin';
    if lDialog.Execute then
      fAssociationProgramEdit.Text := lDialog.FileName;
  finally
    lDialog.Free;
  end;
end;

procedure TLinuxSetupManagerForm.AssociateFileClick(Sender: TObject);
begin
  if (Trim(fAssociationFileEdit.Text) = '') or
    (Trim(fAssociationProgramEdit.Text) = '') then
  begin
    MessageDlg('Выберите файл-пример и программу.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if RunHelperArgs(CFileAssociationHelper,
    [fAssociationFileEdit.Text, fAssociationProgramEdit.Text]) then
    fStatusLabel.Caption := 'Ассоциация файлов сохранена.'
  else
    fStatusLabel.Caption := 'Не удалось сохранить ассоциацию файлов.';
end;

function TLinuxSetupManagerForm.RunNetworkHelper(const AAction: string): Boolean;
var
  lProcess: TProcess;
  lOutput: TStringList;
begin
  Result := False;
  lProcess := TProcess.Create(nil);
  lOutput := TStringList.Create;
  try
    try
      lProcess.Executable := 'pkexec';
      lProcess.Parameters.Add(IncludeTrailingPathDelimiter(
        ExtractFilePath(ParamStr(0))) + 'LinuxSetupManagerCli' +
        ExtractFileExt(ParamStr(0)));
      lProcess.Parameters.Add('--internal');
      lProcess.Parameters.Add('shares');
      lProcess.Parameters.Add(AAction);
      lProcess.Parameters.Add(Trim(fHostEdit.Text));
      lProcess.Parameters.Add(Trim(fSmbShareEdit.Text));
      lProcess.Parameters.Add(Trim(fLocalNameEdit.Text));
      lProcess.Options := [poUsePipes, poStderrToOutput, poWaitOnExit];
      lProcess.Execute;
      lOutput.LoadFromStream(lProcess.Output);
      Result := lProcess.ExitStatus = 0;
      if not Result then
        MessageDlg('Сетевая операция завершилась с кодом ' +
          IntToStr(lProcess.ExitStatus) + ':' + LineEnding + Trim(lOutput.Text),
          mtError, [mbOK], 0);
    except
      on E: Exception do MessageDlg(
        'Не удалось запустить подключение: ' + E.Message, mtError, [mbOK], 0);
    end;
  finally
    lOutput.Free;
    lProcess.Free;
  end;
end;

procedure TLinuxSetupManagerForm.RefreshShares;
var
  lInfo: TSearchRec;
  lConfig: TIniFile;
  lLocalName: string;
begin
  fResourcesList.Clear;
  if FindFirst(IncludeTrailingPathDelimiter(CRegistryDir) + '*.ini', faAnyFile,
    lInfo) <> 0 then Exit;
  try
    repeat
      if (lInfo.Attr and faDirectory) <> 0 then Continue;
      lConfig := TIniFile.Create(IncludeTrailingPathDelimiter(CRegistryDir) +
        lInfo.Name);
      try
        lLocalName := Trim(lConfig.ReadString('Share', 'LocalName', ''));
        if lLocalName <> '' then fResourcesList.Items.Add(lLocalName);
      finally
        lConfig.Free;
      end;
    until FindNext(lInfo) <> 0;
  finally
    FindClose(lInfo);
  end;
end;

procedure TLinuxSetupManagerForm.ResourceSelect(Sender: TObject; User: Boolean);
var
  lInfo: TSearchRec;
  lConfig: TIniFile;
  lSelected, lLocalName: string;
begin
  if fResourcesList.ItemIndex < 0 then Exit;
  lSelected := fResourcesList.Items[fResourcesList.ItemIndex];
  if FindFirst(IncludeTrailingPathDelimiter(CRegistryDir) + '*.ini', faAnyFile,
    lInfo) <> 0 then Exit;
  try
    repeat
      if (lInfo.Attr and faDirectory) <> 0 then Continue;
      lConfig := TIniFile.Create(IncludeTrailingPathDelimiter(CRegistryDir) +
        lInfo.Name);
      try
        lLocalName := lConfig.ReadString('Share', 'LocalName', '');
        if SameText(lLocalName, lSelected) then
        begin
          fHostEdit.Text := lConfig.ReadString('Share', 'Host', '');
          fSmbShareEdit.Text := lConfig.ReadString('Share', 'Name', '');
          fLocalNameEdit.Text := lLocalName;
          fStatusLabel.Caption := 'Сетевой каталог: //' + fHostEdit.Text + '/' +
            fSmbShareEdit.Text;
          Exit;
        end;
      finally
        lConfig.Free;
      end;
    until FindNext(lInfo) <> 0;
  finally
    FindClose(lInfo);
  end;
end;

procedure TLinuxSetupManagerForm.ConnectShareClick(Sender: TObject);
begin
  if (Trim(fHostEdit.Text) = '') or (Trim(fSmbShareEdit.Text) = '') or
    (Trim(fLocalNameEdit.Text) = '') then
  begin
    MessageDlg('Заполните хост, SMB-ресурс и локальное имя.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  if RunNetworkHelper('connect') then
    fStatusLabel.Caption := 'Сетевой ресурс подключён.'
  else
    fStatusLabel.Caption := 'Не удалось подключить сетевой ресурс.';
  RefreshShares;
end;

procedure TLinuxSetupManagerForm.DisconnectShareClick(Sender: TObject);
begin
  if fResourcesList.ItemIndex < 0 then Exit;
  fLocalNameEdit.Text := fResourcesList.Items[fResourcesList.ItemIndex];
  if RunNetworkHelper('disconnect') then
    fStatusLabel.Caption := 'Сетевой ресурс отключён.'
  else
    fStatusLabel.Caption := 'Не удалось отключить сетевой ресурс.';
  RefreshShares;
end;

procedure TLinuxSetupManagerForm.ReconnectShareClick(Sender: TObject);
begin
  if fResourcesList.ItemIndex < 0 then Exit;
  fLocalNameEdit.Text := fResourcesList.Items[fResourcesList.ItemIndex];
  if RunNetworkHelper('reconnect') then
    fStatusLabel.Caption := 'Сетевой ресурс переподключён.'
  else
    fStatusLabel.Caption := 'Не удалось переподключить сетевой ресурс.';
  RefreshShares;
end;

procedure TLinuxSetupManagerForm.OpenShareClick(Sender: TObject);
begin
  if fResourcesList.ItemIndex < 0 then Exit;
  OpenDocument(IncludeTrailingPathDelimiter(CMountRoot) +
    fResourcesList.Items[fResourcesList.ItemIndex]);
end;

procedure TLinuxSetupManagerForm.RefreshSharesClick(Sender: TObject);
begin
  RefreshShares;
  fStatusLabel.Caption := '';
end;

procedure TLinuxSetupManagerForm.BrowseShareClick(Sender: TObject);
var
  lDirectory: string;
begin
  lDirectory := Trim(fSharePathEdit.Text);
  if SelectDirectory('Выберите каталог для публикации', '', lDirectory) then
    fSharePathEdit.Text := lDirectory;
end;

procedure TLinuxSetupManagerForm.PublishShareClick(Sender: TObject);
var
  lDirectory, lShareName, lOutput: string;
begin
  lDirectory := Trim(fSharePathEdit.Text);
  lShareName := Trim(fPublishShareNameEdit.Text);
  if not DirectoryExists(lDirectory) then
  begin
    MessageDlg('Выбранный каталог не существует.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if lShareName = '' then
  begin
    MessageDlg('Введите сетевое имя ресурса.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if RunPublishAction([lDirectory, lShareName], True, lOutput) then
  begin
    fStatusLabel.Caption := 'Каталог опубликован как ' + lShareName + '.';
    RefreshPublishedShares;
  end
  else
    MessageDlg('Ошибка публикации: ' + lOutput, mtError, [mbOK], 0);
end;

function TLinuxSetupManagerForm.RunPublishAction(
  const AArguments: array of string; AElevated: Boolean;
  out AOutput: string): Boolean;
var
  lProcess: TProcess;
  lLines: TStringList;
  lCli: string;
  lIndex: Integer;
begin
  Result := False;
  AOutput := '';
  lCli := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'LinuxSetupManagerCli' + ExtractFileExt(ParamStr(0));
  lProcess := TProcess.Create(nil);
  lLines := TStringList.Create;
  try
    try
      if AElevated then
      begin
        lProcess.Executable := 'pkexec';
        lProcess.Parameters.Add(lCli);
      end
      else
        lProcess.Executable := lCli;
      lProcess.Parameters.Add('--internal');
      lProcess.Parameters.Add('publish');
      for lIndex := Low(AArguments) to High(AArguments) do
        lProcess.Parameters.Add(AArguments[lIndex]);
      lProcess.Options := [poUsePipes, poStderrToOutput, poWaitOnExit];
      lProcess.Execute;
      lLines.LoadFromStream(lProcess.Output);
      AOutput := Trim(lLines.Text);
      Result := lProcess.ExitStatus = 0;
      if not Result and (AOutput = '') then
        AOutput := 'Код ' + IntToStr(lProcess.ExitStatus);
    except
      on E: Exception do AOutput := E.Message;
    end;
  finally
    lLines.Free;
    lProcess.Free;
  end;
end;

procedure TLinuxSetupManagerForm.RefreshPublishedShares;
var
  lOutput, lName: string;
  lData, lRow: TJSONData;
  lItem: TListItem;
  lIndex: Integer;
begin
  lName := '';
  if fPublishedShares.Selected <> nil then
    lName := fPublishedShares.Selected.Caption;
  fPublishedShares.Items.Clear;
  if not RunPublishAction(['list'], False, lOutput) then
  begin
    fStatusLabel.Caption := 'Не удалось прочитать публикации: ' + lOutput;
    Exit;
  end;
  lData := nil;
  try
    lData := GetJSON(lOutput);
    if lData.JSONType <> jtArray then
      raise Exception.Create('Ожидался список ресурсов.');
    for lIndex := 0 to TJSONArray(lData).Count - 1 do
    begin
      lRow := TJSONArray(lData).Items[lIndex];
      if lRow.JSONType <> jtObject then Continue;
      lItem := fPublishedShares.Items.Add;
      lItem.Caption := TJSONObject(lRow).Get('name', '');
      lItem.SubItems.Add(TJSONObject(lRow).Get('path', ''));
      if lItem.Caption = lName then lItem.Selected := True;
    end;
  except
    on E: Exception do fStatusLabel.Caption :=
      'Ошибка списка публикаций: ' + E.Message;
  end;
  lData.Free;
end;

procedure TLinuxSetupManagerForm.RefreshPublishedClick(Sender: TObject);
begin
  RefreshPublishedShares;
end;

procedure TLinuxSetupManagerForm.PublishedShareSelect(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if not Selected or (Item = nil) or (Item.SubItems.Count = 0) then Exit;
  fPublishShareNameEdit.Text := Item.Caption;
  fSharePathEdit.Text := Item.SubItems[0];
end;

procedure TLinuxSetupManagerForm.UpdatePublishedClick(Sender: TObject);
var
  lName, lPath, lOutput: string;
begin
  if fPublishedShares.Selected = nil then
  begin
    MessageDlg('Выберите опубликованный ресурс в списке.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lName := fPublishedShares.Selected.Caption;
  lPath := Trim(fSharePathEdit.Text);
  if not DirectoryExists(lPath) then
  begin
    MessageDlg('Новый каталог не существует.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Изменить каталог ресурса ' + lName + ' на ' + lPath + '?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  if RunPublishAction(['update', lName, lPath], True, lOutput) then
  begin
    fStatusLabel.Caption := 'Путь ресурса ' + lName + ' изменён.';
    RefreshPublishedShares;
  end
  else
    MessageDlg('Не удалось изменить ресурс: ' + lOutput,
      mtError, [mbOK], 0);
end;

procedure TLinuxSetupManagerForm.DeletePublishedClick(Sender: TObject);
var
  lName, lOutput: string;
begin
  if fPublishedShares.Selected = nil then
  begin
    MessageDlg('Выберите опубликованный ресурс в списке.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  lName := fPublishedShares.Selected.Caption;
  if MessageDlg('Удалить публикацию ' + lName +
    '? Файлы исходного каталога останутся на месте.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  if RunPublishAction(['delete', lName], True, lOutput) then
  begin
    fStatusLabel.Caption := 'Публикация ' + lName + ' удалена.';
    RefreshPublishedShares;
  end
  else
    MessageDlg('Не удалось удалить публикацию: ' + lOutput,
      mtError, [mbOK], 0);
end;

function TLinuxSetupManagerForm.ReadComputerName: string;
var
  lProcess: TProcess;
  lOutput: TStringList;
begin
  Result := GetEnvironmentVariable('HOSTNAME');
  lProcess := TProcess.Create(nil);
  lOutput := TStringList.Create;
  try
    try
      lProcess.Executable := 'hostname';
      lProcess.Options := [poUsePipes, poWaitOnExit];
      lProcess.Execute;
      if lProcess.ExitStatus = 0 then
      begin
        lOutput.LoadFromStream(lProcess.Output);
        if lOutput.Count > 0 then Result := Trim(lOutput[0]);
      end;
    except
      { Environment value remains as a safe fallback. }
    end;
  finally
    lOutput.Free;
    lProcess.Free;
  end;
end;

function TLinuxSetupManagerForm.RunHelper(const AExecutable: string;
  const AArgument: string): Boolean;
begin
  if AArgument = '' then
    Result := RunHelperArgs(AExecutable, [])
  else
    Result := RunHelperArgs(AExecutable, [AArgument]);
end;

function TLinuxSetupManagerForm.RunHelperArgs(const AExecutable: string;
  const AArguments: array of string): Boolean;
var
  lIndex: Integer;
  lProcess: TProcess;
  lSection: string;
begin
  Result := False;
  if AExecutable = CDesktopShortcutHelper then lSection := 'programs'
  else if AExecutable = CHostnameHelper then lSection := 'hostname'
  else if AExecutable = CWolHelper then lSection := 'wol'
  else if AExecutable = CMeraAssociationHelper then lSection := 'associate-mera'
  else if AExecutable = CFileAssociationHelper then lSection := 'associate-file'
  else begin
    MessageDlg('Неизвестная встроенная функция: ' + AExecutable,
      mtError, [mbOK], 0);
    Exit;
  end;
  lProcess := TProcess.Create(nil);
  try
    try
      lProcess.Executable := 'pkexec';
      lProcess.Parameters.Add(IncludeTrailingPathDelimiter(
        ExtractFilePath(ParamStr(0))) + 'LinuxSetupManagerCli' +
        ExtractFileExt(ParamStr(0)));
      lProcess.Parameters.Add('--internal');
      lProcess.Parameters.Add(lSection);
      for lIndex := Low(AArguments) to High(AArguments) do
        lProcess.Parameters.Add(AArguments[lIndex]);
      lProcess.Options := [poWaitOnExit];
      lProcess.Execute;
      Result := lProcess.ExitStatus = 0;
    except
      on E: Exception do MessageDlg(
        'Не удалось запустить системную операцию: ' + E.Message,
        mtError, [mbOK], 0);
    end;
  finally
    lProcess.Free;
  end;
end;

procedure TLinuxSetupManagerForm.RefreshCurrentName;
begin
  fCurrentNameValue.Caption := ReadComputerName;
  if Trim(fNewNameEdit.Text) = '' then
    fNewNameEdit.Text := fCurrentNameValue.Caption;
end;

procedure TLinuxSetupManagerForm.ApplyNameClick(Sender: TObject);
var
  lNewName: string;
begin
  lNewName := Trim(fNewNameEdit.Text);
  if lNewName = '' then
  begin
    MessageDlg('Введите новое имя компьютера.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if not RunHelper(CHostnameHelper, lNewName) then
  begin
    fStatusLabel.Caption := 'Не удалось изменить имя компьютера.';
    Exit;
  end;
  RefreshCurrentName;
  fStatusLabel.Caption :=
    'Имя изменено. Перезайдите в систему или перезагрузите ПК.';
end;

procedure TLinuxSetupManagerForm.RefreshNameClick(Sender: TObject);
begin
  RefreshCurrentName;
  fStatusLabel.Caption := '';
end;

procedure TLinuxSetupManagerForm.EnableWolClick(Sender: TObject);
begin
  if RunHelper(CWolHelper) then
    fStatusLabel.Caption :=
      'Wake-on-LAN включён для enp3s0 и сохранён после перезагрузки.'
  else
    fStatusLabel.Caption := 'Не удалось включить Wake-on-LAN для enp3s0.';
end;

end.
