unit uLinuxSetupManagerSmbDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes;

procedure ShowSmbDialog(AOwner: TComponent);

implementation

uses SysUtils, Forms, Controls, StdCtrls, Dialogs, Process, CheckLst, Math;

type
  TSmbDialog = class(TForm)
  private
    fStatus: TMemo;
    fUser: TEdit;
    fPassword: TEdit;
    fConfirm: TEdit;
    fUsers: TListBox;
    fShares: TCheckListBox;
    fLabels: array[0..5] of TLabel;
    fActionButtons: array[0..3] of TButton;
    fHintLabel: TLabel;
    fCloseButton: TButton;
    function RunCli(const AArgs: array of string; const AInput: UTF8String;
      out AOutput: string): Boolean;
    procedure RefreshClick(Sender: TObject);
    procedure InstallClick(Sender: TObject);
    procedure ConfigureClick(Sender: TObject);
    procedure UserSelect(Sender: TObject);
    procedure ApplyAccessClick(Sender: TObject);
    procedure LoadUsers;
    procedure LoadAccess;
    procedure LayoutControls(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

function AddLabel(AOwner: TComponent; AParent: TWinControl; ATop: Integer;
  const AText: string): TLabel;
begin
  Result := TLabel.Create(AOwner);
  Result.Parent := AParent;
  Result.SetBounds(16, ATop, 185, 24);
  Result.AutoSize := True;
  Result.Caption := AText;
end;

function AddEdit(AOwner: TComponent; AParent: TWinControl; ATop: Integer;
  APassword: Boolean): TEdit;
begin
  Result := TEdit.Create(AOwner);
  Result.Parent := AParent;
  Result.SetBounds(205, ATop, 450, 28);
  if APassword then Result.PasswordChar := '*';
end;

function AddButton(AOwner: TComponent; AParent: TWinControl; ALeft,
  AWidth: Integer; const AText: string; AClick: TNotifyEvent): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Parent := AParent;
  Result.SetBounds(ALeft, 548, AWidth, 32);
  Result.Caption := AText;
  Result.OnClick := AClick;
end;

constructor TSmbDialog.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'SMB-сервер';
  Position := poScreenCenter;
  SetBounds(0, 0, 840, 650);
  BorderStyle := bsSizeable;
  Constraints.MinWidth := 700;
  Constraints.MinHeight := 590;
  AutoScroll := True;
  OnResize := @LayoutControls;
  fLabels[0] := AddLabel(Self, Self, 20, 'Состояние');
  fStatus := TMemo.Create(Self);
  fStatus.Parent := Self;
  fStatus.SetBounds(150, 16, 650, 82);
  fStatus.ReadOnly := True;
  fStatus.ScrollBars := ssAutoVertical;
  fLabels[1] := AddLabel(Self, Self, 112, 'Пользователи Samba');
  fUsers := TListBox.Create(Self);
  fUsers.Parent := Self;
  fUsers.SetBounds(16, 136, 215, 245);
  fUsers.OnClick := @UserSelect;
  fLabels[2] := AddLabel(Self, Self, 112, 'Доступ к опубликованным ресурсам');
  fShares := TCheckListBox.Create(Self);
  fShares.Parent := Self;
  fShares.SetBounds(250, 136, 550, 245);
  fShares.ShowHint := True;
  fShares.Hint := 'Галочка разрешает выбранному пользователю доступ к ресурсу';
  fLabels[3] := AddLabel(Self, Self, 402, 'Выбранный пользователь');
  fUser := AddEdit(Self, Self, 398, False);
  fUser.Text := GetEnvironmentVariable('USER');
  if fUser.Text = '' then fUser.Text := 'user';
  fLabels[4] := AddLabel(Self, Self, 438, 'Новый пароль SMB');
  fPassword := AddEdit(Self, Self, 434, True);
  fLabels[5] := AddLabel(Self, Self, 474, 'Подтверждение');
  fConfirm := AddEdit(Self, Self, 470, True);
  fActionButtons[0] := AddButton(Self, Self, 16, 120, 'Обновить', @RefreshClick);
  fActionButtons[1] := AddButton(Self, Self, 144, 195, 'Установить/исправить', @InstallClick);
  fActionButtons[2] := AddButton(Self, Self, 347, 180, 'Настроить пользователя', @ConfigureClick);
  fActionButtons[3] := AddButton(Self, Self, 535, 125, 'Применить права', @ApplyAccessClick);
  fHintLabel := TLabel.Create(Self);
  with fHintLabel do
  begin
    Parent := Self;
    AutoSize := False;
    WordWrap := True;
    Caption := 'Установка добавляет пакеты samba и smbclient, включает smbd и ' +
      'обнаружение в WORKGROUP через nmbd. Настройка пользователя создаёт ' +
      'отдельный пароль Samba; пароль передаётся только через stdin. ' +
      'Публикации доступны настроенному пользователю.';
  end;
  fCloseButton := TButton.Create(Self);
  with fCloseButton do
  begin
    Parent := Self;
    SetBounds(680, 590, 120, 32);
    Caption := 'Закрыть';
    ModalResult := mrClose;
  end;
  LayoutControls(nil);
  RefreshClick(nil);
end;

procedure TSmbDialog.LayoutControls(Sender: TObject);
const
  GAP = 12;
var
  lButtonHeight, lButtonLeft, lButtonTop, lEditLeft, lEditTop: Integer;
  lIndex, lLabelWidth, lListTop, lListBottom, lStatusTop: Integer;
begin
  lButtonHeight := Max(32, Canvas.TextHeight('Щ') + 14);
  lLabelWidth := 0;
  for lIndex := 3 to 5 do
    lLabelWidth := Max(lLabelWidth, fLabels[lIndex].Width);
  lEditLeft := GAP + lLabelWidth + GAP;

  fLabels[0].SetBounds(GAP, GAP + 5, fLabels[0].Width, fLabels[0].Height);
  lStatusTop := GAP;
  fStatus.SetBounds(lEditLeft, lStatusTop,
    Max(300, ClientWidth - lEditLeft - GAP), Max(82, Canvas.TextHeight('Щ') * 4 + 12));

  lListTop := fStatus.Top + fStatus.Height + 34;
  fLabels[1].SetBounds(GAP, lListTop - 24, fLabels[1].Width, fLabels[1].Height);
  fLabels[2].SetBounds(Max(230, ClientWidth div 3), lListTop - 24,
    fLabels[2].Width, fLabels[2].Height);
  lEditTop := ClientHeight - (3 * (Max(28, Canvas.TextHeight('Щ') + 12) + 8)) -
    2 * lButtonHeight - 88;
  lListBottom := Max(lListTop + 120, lEditTop - GAP);
  fUsers.SetBounds(GAP, lListTop, Max(200, ClientWidth div 3 - 2 * GAP),
    lListBottom - lListTop);
  fShares.SetBounds(fUsers.Left + fUsers.Width + GAP, lListTop,
    Max(300, ClientWidth - fUsers.Left - fUsers.Width - 2 * GAP),
    lListBottom - lListTop);

  for lIndex := 3 to 5 do
  begin
    fLabels[lIndex].SetBounds(GAP, lEditTop + 5, fLabels[lIndex].Width,
      fLabels[lIndex].Height);
    case lIndex of
      3: fUser.SetBounds(lEditLeft, lEditTop, ClientWidth - lEditLeft - GAP,
           Max(28, Canvas.TextHeight('Щ') + 12));
      4: fPassword.SetBounds(lEditLeft, lEditTop, ClientWidth - lEditLeft - GAP,
           Max(28, Canvas.TextHeight('Щ') + 12));
      5: fConfirm.SetBounds(lEditLeft, lEditTop, ClientWidth - lEditLeft - GAP,
           Max(28, Canvas.TextHeight('Щ') + 12));
    end;
    Inc(lEditTop, Max(28, Canvas.TextHeight('Щ') + 12) + 8);
  end;

  fHintLabel.SetBounds(GAP, lEditTop + 2, ClientWidth - 2 * GAP,
    Max(42, Canvas.TextHeight('Щ') * 3 + 6));
  lButtonTop := fHintLabel.Top + fHintLabel.Height + 6;
  lButtonLeft := GAP;
  for lIndex := 0 to 3 do
  begin
    fActionButtons[lIndex].Width := Max(fActionButtons[lIndex].Width,
      Canvas.TextWidth(fActionButtons[lIndex].Caption) + 28);
    if lButtonLeft + fActionButtons[lIndex].Width > ClientWidth - GAP then
    begin
      lButtonLeft := GAP;
      Inc(lButtonTop, lButtonHeight + 6);
    end;
    fActionButtons[lIndex].SetBounds(lButtonLeft, lButtonTop,
      fActionButtons[lIndex].Width, lButtonHeight);
    Inc(lButtonLeft, fActionButtons[lIndex].Width + 8);
  end;
  fCloseButton.SetBounds(ClientWidth - GAP - Max(120,
    Canvas.TextWidth(fCloseButton.Caption) + 28),
    ClientHeight - GAP - lButtonHeight,
    Max(120, Canvas.TextWidth(fCloseButton.Caption) + 28), lButtonHeight);
end;

function TSmbDialog.RunCli(const AArgs: array of string;
  const AInput: UTF8String; out AOutput: string): Boolean;
var
  lBuffer: array[0..4095] of Byte;
  lCount: Integer;
  lCli: string;
  lIndex: Integer;
  lProcess: TProcess;
  lStream: TMemoryStream;
begin
  Result := False;
  AOutput := '';
  lCli := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'LinuxSetupManagerCli' + ExtractFileExt(ParamStr(0));
  lProcess := TProcess.Create(nil);
  lStream := TMemoryStream.Create;
  try
    try
      lProcess.Executable := lCli;
      lProcess.Parameters.Add('smb');
      for lIndex := Low(AArgs) to High(AArgs) do
        lProcess.Parameters.Add(AArgs[lIndex]);
      lProcess.Options := [poUsePipes, poStderrToOutput];
      lProcess.Execute;
      if AInput <> '' then
        lProcess.Input.WriteBuffer(AInput[1], Length(AInput));
      lProcess.CloseInput;
      while lProcess.Running or (lProcess.Output.NumBytesAvailable > 0) do
      begin
        lCount := lProcess.Output.Read(lBuffer, SizeOf(lBuffer));
        if lCount > 0 then lStream.WriteBuffer(lBuffer, lCount);
        Application.ProcessMessages;
      end;
      lProcess.WaitOnExit;
      SetLength(AOutput, lStream.Size);
      if lStream.Size > 0 then
      begin
        lStream.Position := 0;
        lStream.ReadBuffer(AOutput[1], lStream.Size);
      end;
      AOutput := Trim(AOutput);
      Result := lProcess.ExitStatus = 0;
    except on E: Exception do AOutput := E.Message; end;
  finally
    lStream.Free;
    lProcess.Free;
  end;
end;

procedure TSmbDialog.RefreshClick(Sender: TObject);
var lOutput: string;
begin
  RunCli(['status'], '', lOutput);
  fStatus.Text := lOutput;
  LoadUsers;
end;

procedure TSmbDialog.LoadUsers;
var lOutput, lSelected: string; lLines: TStringList; lIndex: Integer;
begin
  lSelected := Trim(fUser.Text);
  if not RunCli(['users'], '', lOutput) then Exit;
  lLines := TStringList.Create;
  try
    lLines.Text := lOutput;
    fUsers.Items.Assign(lLines);
    for lIndex := 0 to fUsers.Items.Count - 1 do
      if SameText(fUsers.Items[lIndex], lSelected) then fUsers.ItemIndex := lIndex;
    if (fUsers.ItemIndex < 0) and (fUsers.Items.Count > 0) then fUsers.ItemIndex := 0;
    if fUsers.ItemIndex >= 0 then begin fUser.Text := fUsers.Items[fUsers.ItemIndex]; LoadAccess; end;
  finally lLines.Free; end;
end;

procedure TSmbDialog.UserSelect(Sender: TObject);
begin
  if fUsers.ItemIndex < 0 then Exit;
  fUser.Text := fUsers.Items[fUsers.ItemIndex];
  LoadAccess;
end;

procedure TSmbDialog.LoadAccess;
var lOutput: string; lLines, lFields: TStringList; lIndex: Integer;
begin
  fShares.Clear;
  if not RunCli(['access', Trim(fUser.Text)], '', lOutput) then Exit;
  lLines := TStringList.Create; lFields := TStringList.Create;
  try
    lLines.Text := lOutput;
    for lIndex := 0 to lLines.Count - 1 do
    begin
      lFields.Clear;
      ExtractStrings([#9], [], PChar(lLines[lIndex]), lFields);
      if lFields.Count < 3 then Continue;
      fShares.Items.Add(lFields[0] + ' — ' + lFields[1]);
      fShares.Checked[fShares.Items.Count - 1] := SameText(lFields[2], 'True');
      fShares.Items.Objects[fShares.Items.Count - 1] := TObject(PtrInt(lIndex + 1));
    end;
  finally lFields.Free; lLines.Free; end;
end;

procedure TSmbDialog.ApplyAccessClick(Sender: TObject);
var lArgs: array of string; lIndex, lCount: Integer; lName, lOutput: string;
begin
  if Trim(fUser.Text) = '' then Exit;
  lCount := 2;
  for lIndex := 0 to fShares.Items.Count - 1 do if fShares.Checked[lIndex] then Inc(lCount);
  SetLength(lArgs, lCount); lArgs[0] := 'access-apply'; lArgs[1] := Trim(fUser.Text); lCount := 2;
  for lIndex := 0 to fShares.Items.Count - 1 do if fShares.Checked[lIndex] then
  begin
    lName := fShares.Items[lIndex]; Delete(lName, Pos(' — ', lName), MaxInt);
    lArgs[lCount] := lName; Inc(lCount);
  end;
  if RunCli(lArgs, '', lOutput) then begin MessageDlg(lOutput, mtInformation, [mbOK], 0); LoadAccess; end
  else MessageDlg(lOutput, mtError, [mbOK], 0);
end;

procedure TSmbDialog.InstallClick(Sender: TObject);
var lOutput: string;
begin
  if RunCli(['install'], '', lOutput) then
  begin MessageDlg(lOutput, mtInformation, [mbOK], 0); RefreshClick(nil); end
  else MessageDlg(lOutput, mtError, [mbOK], 0);
end;

procedure TSmbDialog.ConfigureClick(Sender: TObject);
var lInput: UTF8String; lOutput: string;
begin
  if Trim(fUser.Text) = '' then
  begin MessageDlg('Выберите пользователя.', mtWarning, [mbOK], 0); Exit; end;
  if (fPassword.Text = '') or (fPassword.Text <> fConfirm.Text) then
  begin MessageDlg('Пароль пуст или подтверждение не совпадает.', mtWarning, [mbOK], 0); Exit; end;
  lInput := UTF8String(fPassword.Text + LineEnding + fConfirm.Text + LineEnding);
  if RunCli(['configure', Trim(fUser.Text)], lInput, lOutput) then
  begin
    fPassword.Clear;
    fConfirm.Clear;
    MessageDlg(lOutput, mtInformation, [mbOK], 0);
    RefreshClick(nil);
  end
  else MessageDlg(lOutput, mtError, [mbOK], 0);
  lInput := '';
end;

procedure ShowSmbDialog(AOwner: TComponent);
var lDialog: TSmbDialog;
begin
  lDialog := TSmbDialog.Create(AOwner);
  try lDialog.ShowModal; finally lDialog.Free; end;
end;

end.
