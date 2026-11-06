unit uCoordinatorBackupDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes;

type
  TCoordinatorBackupHost = record
    InstanceId: string;
    DisplayName: string;
    Address: string;
    Prepared: Boolean;
  end;

  TCoordinatorBackupHostArray = array of TCoordinatorBackupHost;

  TCoordinatorBackupOptions = record
    Destination: string;
    IncludeConfigs: Boolean;
    IncludeCalibrations: Boolean;
  end;

{ Selected IDs are written only when the operator confirms the dialog. }
function ShowCoordinatorBackupDialog(AOwner: TComponent;
  const AHosts: TCoordinatorBackupHostArray;
  out AOptions: TCoordinatorBackupOptions; ASelectedIds: TStrings): Boolean;

implementation

uses SysUtils, Forms, Controls, StdCtrls, ExtCtrls, CheckLst, Dialogs;

type
  TCoordinatorBackupDialog = class(TForm)
  private
    fDestination: TEdit;
    fCalibrations: TCheckBox;
    fHosts: TCheckListBox;
    fHostIds: TStringList;
    procedure BrowseClick(Sender: TObject);
    procedure AcceptClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetHosts(const AHosts: TCoordinatorBackupHostArray);
    procedure GetSelection(out AOptions: TCoordinatorBackupOptions;
      ASelectedIds: TStrings);
  end;

constructor TCoordinatorBackupDialog.Create(AOwner: TComponent);
var
  lTop, lPathRow, lContent, lBottom: TPanel;
  lTitle: TLabel;
  lBrowse, lAccept, lCancel: TButton;
begin
  inherited CreateNew(AOwner, 1);
  fHostIds := TStringList.Create;
  Caption := 'Резервное копирование RecorderLnx';
  Position := poScreenCenter;
  BorderStyle := bsSizeable;
  ClientWidth := 610;
  ClientHeight := 500;
  Constraints.MinWidth := 500;
  Constraints.MinHeight := 410;

  lTop := TPanel.Create(Self);
  lTop.Parent := Self;
  lTop.Align := alTop;
  lTop.Height := 145;
  lTop.BevelOuter := bvNone;

  lTitle := TLabel.Create(Self);
  lTitle.Parent := lTop;
  lTitle.SetBounds(12, 10, 480, 20);
  lTitle.Caption := 'Каталог для резервных копий:';

  { The row and its children are aligned to the actual parent client area.
    Right anchors assigned before LCL sizes an aligned panel can otherwise
    place the controls outside the window at high DPI. }
  lPathRow := TPanel.Create(Self);
  lPathRow.Parent := lTop;
  lPathRow.Align := alTop;
  lPathRow.BorderSpacing.Top := 33;
  lPathRow.BorderSpacing.Left := 12;
  lPathRow.BorderSpacing.Right := 12;
  lPathRow.Height := 27;
  lPathRow.BevelOuter := bvNone;

  lBrowse := TButton.Create(Self);
  lBrowse.Parent := lPathRow;
  lBrowse.Align := alRight;
  lBrowse.Width := 90;
  lBrowse.BorderSpacing.Left := 8;
  lBrowse.Caption := 'Обзор...';
  lBrowse.TabOrder := 1;
  lBrowse.OnClick := @BrowseClick;

  fDestination := TEdit.Create(Self);
  fDestination.Parent := lPathRow;
  fDestination.Align := alClient;
  fDestination.TabOrder := 0;

  lTitle := TLabel.Create(Self);
  lTitle.Parent := lTop;
  lTitle.SetBounds(12, 70, 480, 20);
  lTitle.Caption := 'Активный проект и app.ini сохраняются всегда.';

  fCalibrations := TCheckBox.Create(Self);
  fCalibrations.Parent := lTop;
  fCalibrations.SetBounds(16, 95, 360, 22);
  fCalibrations.Caption := 'Сохранить ГХ';
  fCalibrations.TabOrder := 2;

  lBottom := TPanel.Create(Self);
  lBottom.Parent := Self;
  lBottom.Align := alBottom;
  lBottom.Height := 52;
  lBottom.BevelOuter := bvNone;

  lCancel := TButton.Create(Self);
  lCancel.Parent := lBottom;
  lCancel.Align := alRight;
  lCancel.Width := 100;
  lCancel.BorderSpacing.Top := 8;
  lCancel.BorderSpacing.Bottom := 8;
  lCancel.BorderSpacing.Right := 12;
  lCancel.Caption := 'Отмена';
  lCancel.ModalResult := mrCancel;
  lCancel.Cancel := True;
  lCancel.TabOrder := 1;

  lAccept := TButton.Create(Self);
  lAccept.Parent := lBottom;
  lAccept.Align := alRight;
  lAccept.Width := 104;
  lAccept.BorderSpacing.Top := 8;
  lAccept.BorderSpacing.Bottom := 8;
  lAccept.BorderSpacing.Right := 8;
  lAccept.Caption := 'Сохранить';
  lAccept.Default := True;
  lAccept.TabOrder := 0;
  lAccept.OnClick := @AcceptClick;

  lContent := TPanel.Create(Self);
  lContent.Parent := Self;
  lContent.Align := alClient;
  lContent.BevelOuter := bvNone;
  lContent.BorderSpacing.Left := 12;
  lContent.BorderSpacing.Right := 12;

  lTitle := TLabel.Create(Self);
  lTitle.Parent := lContent;
  lTitle.Align := alTop;
  lTitle.Caption := 'Рабочие места:';
  lTitle.BorderSpacing.Bottom := 4;

  fHosts := TCheckListBox.Create(Self);
  fHosts.Parent := lContent;
  fHosts.Align := alClient;
  fHosts.ItemHeight := 23;
  fHosts.TabOrder := 0;
end;

destructor TCoordinatorBackupDialog.Destroy;
begin
  fHostIds.Free;
  inherited Destroy;
end;

procedure TCoordinatorBackupDialog.SetHosts(
  const AHosts: TCoordinatorBackupHostArray);
var
  lIndex: Integer;
  lName: string;
begin
  fHosts.Clear;
  fHostIds.Clear;
  for lIndex := 0 to High(AHosts) do
  begin
    lName := Trim(AHosts[lIndex].DisplayName);
    if lName = '' then lName := Trim(AHosts[lIndex].Address);
    if lName = '' then lName := AHosts[lIndex].InstanceId;
    if (Trim(AHosts[lIndex].Address) <> '') and
      not SameText(lName, Trim(AHosts[lIndex].Address)) then
      lName := lName + ' (' + Trim(AHosts[lIndex].Address) + ')';
    if not AHosts[lIndex].Prepared then
      lName := lName + ' (источник не настроен)';
    fHosts.Items.Add(lName);
    fHostIds.Add(AHosts[lIndex].InstanceId);
    fHosts.Checked[lIndex] := AHosts[lIndex].Prepared;
  end;
end;

procedure TCoordinatorBackupDialog.BrowseClick(Sender: TObject);
var
  lDialog: TSelectDirectoryDialog;
begin
  lDialog := TSelectDirectoryDialog.Create(Self);
  try
    lDialog.Title := 'Каталог для резервных копий';
    if DirectoryExists(Trim(fDestination.Text)) then
      lDialog.InitialDir := Trim(fDestination.Text);
    if lDialog.Execute then fDestination.Text := lDialog.FileName;
  finally
    lDialog.Free;
  end;
end;

procedure TCoordinatorBackupDialog.AcceptClick(Sender: TObject);
var
  lIndex: Integer;
  lHasHost: Boolean;
begin
  if not DirectoryExists(Trim(fDestination.Text)) then
  begin
    MessageDlg('Укажите существующий каталог для резервных копий.', mtWarning,
      [mbOK], 0);
    fDestination.SetFocus;
    Exit;
  end;
  lHasHost := False;
  for lIndex := 0 to fHosts.Count - 1 do
    if fHosts.Checked[lIndex] then
    begin
      lHasHost := True;
      Break;
    end;
  if not lHasHost then
  begin
    MessageDlg('Выберите хотя бы одно рабочее место.', mtWarning, [mbOK], 0);
    fHosts.SetFocus;
    Exit;
  end;
  ModalResult := mrOK;
end;

procedure TCoordinatorBackupDialog.GetSelection(
  out AOptions: TCoordinatorBackupOptions; ASelectedIds: TStrings);
var
  lIndex: Integer;
begin
  AOptions.Destination := ExpandFileName(Trim(fDestination.Text));
  AOptions.IncludeConfigs := True;
  AOptions.IncludeCalibrations := fCalibrations.Checked;
  ASelectedIds.Clear;
  for lIndex := 0 to fHosts.Count - 1 do
    if fHosts.Checked[lIndex] then ASelectedIds.Add(fHostIds[lIndex]);
end;

function ShowCoordinatorBackupDialog(AOwner: TComponent;
  const AHosts: TCoordinatorBackupHostArray;
  out AOptions: TCoordinatorBackupOptions; ASelectedIds: TStrings): Boolean;
var
  lDialog: TCoordinatorBackupDialog;
begin
  if ASelectedIds = nil then
    raise Exception.Create('Backup destination host list is not assigned');
  AOptions := Default(TCoordinatorBackupOptions);
  lDialog := TCoordinatorBackupDialog.Create(AOwner);
  try
    lDialog.SetHosts(AHosts);
    Result := lDialog.ShowModal = mrOK;
    if Result then lDialog.GetSelection(AOptions, ASelectedIds);
  finally
    lDialog.Free;
  end;
end;

end.
