unit uLinuxSetupManagerMain;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Process, Dialogs,
  Graphics;

type
  TLinuxSetupManagerForm = class(TForm)
  private
    fFunctionList: TListBox;
    fDescriptionMemo: TMemo;
    fNamePanel: TPanel;
    fWolPanel: TPanel;
    fSharePanel: TPanel;
    fCurrentNameValue: TLabel;
    fNewNameEdit: TEdit;
    fSharePathEdit: TEdit;
    fStatusLabel: TLabel;
    procedure ApplyNameClick(Sender: TObject);
    procedure EnableWolClick(Sender: TObject);
    procedure FunctionSelect(Sender: TObject; User: Boolean);
    procedure BrowseShareClick(Sender: TObject);
    procedure PublishShareClick(Sender: TObject);
    procedure RefreshNameClick(Sender: TObject);
    procedure BuildUi;
    function ReadComputerName: string;
    function RunHelper(const AExecutable: string;
      const AArgument: string = ''): Boolean;
    procedure RefreshCurrentName;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  LinuxSetupManagerForm: TLinuxSetupManagerForm;

implementation

const
  CHostnameHelper = '/usr/local/sbin/recorderlnx-set-hostname';
  CWolHelper = '/usr/local/sbin/recorderlnx-configure-wol';
  CShareHelper = '/usr/local/sbin/recorderlnx-share-folder';

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

constructor TLinuxSetupManagerForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner, 1);
  BuildUi;
  RefreshCurrentName;
  fFunctionList.ItemIndex := 0;
  FunctionSelect(fFunctionList, False);
end;

procedure TLinuxSetupManagerForm.BuildUi;
var
  lRightPanel, lDescriptionPanel: TPanel;
begin
  Caption := 'Настройка Linux';
  SetBounds(180, 120, 760, 470);
  Position := poScreenCenter;
  fFunctionList := TListBox.Create(Self);
  fFunctionList.Parent := Self;
  fFunctionList.Align := alLeft;
  fFunctionList.Width := 220;
  fFunctionList.Items.Add('Имя компьютера');
  fFunctionList.Items.Add('Wake-on-LAN');
  fFunctionList.Items.Add('Опубликовать каталог');
  fFunctionList.OnSelectionChange := @FunctionSelect;
  lRightPanel := TPanel.Create(Self);
  lRightPanel.Parent := Self;
  lRightPanel.Align := alClient;
  lRightPanel.BevelOuter := bvNone;
  lDescriptionPanel := TPanel.Create(Self);
  lDescriptionPanel.Parent := lRightPanel;
  lDescriptionPanel.Align := alBottom;
  lDescriptionPanel.Height := 155;
  AddLabel(Self, lDescriptionPanel, 12, 8, 250, 'Что делает эта функция');
  fDescriptionMemo := TMemo.Create(Self);
  fDescriptionMemo.Parent := lDescriptionPanel;
  fDescriptionMemo.SetBounds(12, 32, 500, 110);
  fDescriptionMemo.Anchors := [akLeft, akTop, akRight, akBottom];
  fDescriptionMemo.ReadOnly := True;
  fDescriptionMemo.WordWrap := True;
  fDescriptionMemo.ScrollBars := ssAutoVertical;
  fStatusLabel := AddLabel(Self, lRightPanel, 16, 274, 510, '');
  fStatusLabel.AutoSize := True;
  fNamePanel := TPanel.Create(Self);
  fNamePanel.Parent := lRightPanel;
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
  fWolPanel.Parent := lRightPanel;
  fWolPanel.SetBounds(0, 0, 535, 265);
  fWolPanel.Anchors := [akLeft, akTop, akRight];
  fWolPanel.BevelOuter := bvNone;
  AddLabel(Self, fWolPanel, 16, 28, 490, 'Сетевой интерфейс: enp3s0');
  AddButton(Self, fWolPanel, 190, 72, 180, 'Включить Wake-on-LAN',
    @EnableWolClick);
  fSharePanel := TPanel.Create(Self);
  fSharePanel.Parent := lRightPanel;
  fSharePanel.SetBounds(0, 0, 535, 265);
  fSharePanel.Anchors := [akLeft, akTop, akRight];
  fSharePanel.BevelOuter := bvNone;
  AddLabel(Self, fSharePanel, 16, 28, 490, 'Каталог для публикации');
  fSharePathEdit := TEdit.Create(Self);
  fSharePathEdit.Parent := fSharePanel;
  fSharePathEdit.SetBounds(16, 58, 440, 28);
  AddButton(Self, fSharePanel, 465, 56, 45, '...', @BrowseShareClick);
  AddButton(Self, fSharePanel, 190, 112, 180, 'Опубликовать',
    @PublishShareClick);
end;

procedure TLinuxSetupManagerForm.FunctionSelect(Sender: TObject; User: Boolean);
begin
  fNamePanel.Visible := fFunctionList.ItemIndex = 0;
  fWolPanel.Visible := fFunctionList.ItemIndex = 1;
  fSharePanel.Visible := fFunctionList.ItemIndex = 2;
  fStatusLabel.Caption := '';
  case fFunctionList.ItemIndex of
    0: fDescriptionMemo.Text :=
      'Изменяет системное имя этого Linux-ПК через hostnamectl и одновременно ' +
      'обновляет /etc/hosts. Это имя показывается в сети, Samba и диагностике. ' +
      'Допустимы латинские буквы, цифры и дефис, например KIP-4.';
    1: fDescriptionMemo.Text :=
      'Включает Wake-on-LAN в режиме magic packet для интерфейса enp3s0. ' +
      'Также создаёт и включает systemd-сервис, который восстанавливает WOL ' +
      'после каждой перезагрузки компьютера.';
    2: fDescriptionMemo.Text :=
      'Публикует выбранный локальный каталог в Samba под постоянным именем ' +
      'MeraFiles. Другие Linux-ПК подключают этот ресурс через менеджер ' +
      'сетевых ресурсов, после чего SQL-тренды находят внутри него нужный кадр.';
  else
    fDescriptionMemo.Clear;
  end;
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
  lDirectory: string;
begin
  lDirectory := Trim(fSharePathEdit.Text);
  if not DirectoryExists(lDirectory) then
  begin
    MessageDlg('Выбранный каталог не существует.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if RunHelper(CShareHelper, lDirectory) then
    fStatusLabel.Caption := 'Каталог опубликован как сетевой ресурс MeraFiles.'
  else
    fStatusLabel.Caption := 'Не удалось опубликовать каталог.';
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
    lProcess.Executable := 'hostname';
    lProcess.Options := [poUsePipes, poWaitOnExit];
    lProcess.Execute;
    if lProcess.ExitStatus = 0 then
    begin
      lOutput.LoadFromStream(lProcess.Output);
      if lOutput.Count > 0 then Result := Trim(lOutput[0]);
    end;
  finally
    lOutput.Free;
    lProcess.Free;
  end;
end;

function TLinuxSetupManagerForm.RunHelper(const AExecutable: string;
  const AArgument: string): Boolean;
var
  lProcess: TProcess;
begin
  Result := False;
  if not FileExists(AExecutable) then
  begin
    MessageDlg('Не установлена системная утилита ' + AExecutable,
      mtError, [mbOK], 0);
    Exit;
  end;
  lProcess := TProcess.Create(nil);
  try
    lProcess.Executable := 'pkexec';
    lProcess.Parameters.Add(AExecutable);
    if AArgument <> '' then lProcess.Parameters.Add(AArgument);
    lProcess.Options := [poWaitOnExit];
    lProcess.Execute;
    Result := lProcess.ExitStatus = 0;
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
