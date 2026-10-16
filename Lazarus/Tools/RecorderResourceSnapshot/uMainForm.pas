unit uMainForm;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  uResourceSnapshot;

type
  TMainForm = class(TForm)
  private
    fProcesses: TProcessChoices;
    fProcessBox: TComboBox;
    fLogEdit: TEdit;
    fPreview: TMemo;
    fCaptureButton: TButton;
    procedure BuildInterface;
    procedure BrowseLog(Sender: TObject);
    procedure CaptureSnapshot(Sender: TObject);
    procedure RefreshProcesses(Sender: TObject);
    function SelectedProcessId: Cardinal;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainForm: TMainForm;

implementation

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Снимок ресурсов Recorder';
  Width := 720;
  Height := 520;
  Constraints.MinWidth := 620;
  Constraints.MinHeight := 420;
  Position := poScreenCenter;
  BuildInterface;
  RefreshProcesses(nil);
end;

procedure TMainForm.BuildInterface;
var
  lTop: TPanel;
  lRefresh, lBrowse: TButton;
begin
  lTop := TPanel.Create(Self);
  lTop.Parent := Self;
  lTop.Align := alTop;
  lTop.Height := 112;
  lTop.BevelOuter := bvNone;

  fProcessBox := TComboBox.Create(Self);
  fProcessBox.Parent := lTop;
  fProcessBox.SetBounds(12, 12, 460, 28);
  fProcessBox.Style := csDropDownList;
  fProcessBox.Anchors := [akLeft, akTop, akRight];

  lRefresh := TButton.Create(Self);
  lRefresh.Parent := lTop;
  lRefresh.Caption := 'Обновить процессы';
  lRefresh.SetBounds(484, 10, 216, 30);
  lRefresh.Anchors := [akTop, akRight];
  lRefresh.OnClick := @RefreshProcesses;

  fLogEdit := TEdit.Create(Self);
  fLogEdit.Parent := lTop;
  fLogEdit.SetBounds(12, 48, 552, 28);
  fLogEdit.Anchors := [akLeft, akTop, akRight];
  fLogEdit.Text := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
    'RecorderResourceSnapshots.log';

  lBrowse := TButton.Create(Self);
  lBrowse.Parent := lTop;
  lBrowse.Caption := 'Лог...';
  lBrowse.SetBounds(576, 46, 124, 30);
  lBrowse.Anchors := [akTop, akRight];
  lBrowse.OnClick := @BrowseLog;

  fCaptureButton := TButton.Create(Self);
  fCaptureButton.Parent := lTop;
  fCaptureButton.Caption := 'Снять слепок';
  fCaptureButton.SetBounds(12, 80, 688, 30);
  fCaptureButton.Anchors := [akLeft, akTop, akRight];
  fCaptureButton.Default := True;
  fCaptureButton.OnClick := @CaptureSnapshot;

  fPreview := TMemo.Create(Self);
  fPreview.Parent := Self;
  fPreview.Align := alClient;
  fPreview.ReadOnly := True;
  fPreview.ScrollBars := ssAutoBoth;
  fPreview.WordWrap := False;
end;

procedure TMainForm.RefreshProcesses(Sender: TObject);
var
  lIndex: Integer;
begin
  fProcesses := TResourceSnapshotService.FindRecorderProcesses;
  fProcessBox.Items.BeginUpdate;
  try
    fProcessBox.Clear;
    for lIndex := 0 to High(fProcesses) do
      fProcessBox.Items.Add(Format('%s (PID %d)',
        [fProcesses[lIndex].Name, fProcesses[lIndex].ProcessId]));
    if fProcessBox.Items.Count > 0 then fProcessBox.ItemIndex := 0;
  finally
    fProcessBox.Items.EndUpdate;
  end;
  fCaptureButton.Enabled := fProcessBox.ItemIndex >= 0;
  if not fCaptureButton.Enabled then
    fPreview.Text := 'Recorder или RecorderLnx сейчас не запущен.';
end;

function TMainForm.SelectedProcessId: Cardinal;
begin
  if (fProcessBox.ItemIndex < 0) or
    (fProcessBox.ItemIndex > High(fProcesses)) then
    raise Exception.Create('Выберите процесс Recorder или RecorderLnx.');
  Result := fProcesses[fProcessBox.ItemIndex].ProcessId;
end;

procedure TMainForm.BrowseLog(Sender: TObject);
var
  lDialog: TSaveDialog;
begin
  lDialog := TSaveDialog.Create(Self);
  try
    lDialog.Title := 'Выберите лог снимков';
    lDialog.Filter := 'Файлы журнала (*.log)|*.log|Все файлы (*.*)|*.*';
    lDialog.FileName := fLogEdit.Text;
    lDialog.Options := lDialog.Options + [ofPathMustExist];
    if lDialog.Execute then fLogEdit.Text := lDialog.FileName;
  finally
    lDialog.Free;
  end;
end;

procedure TMainForm.CaptureSnapshot(Sender: TObject);
var
  lSnapshot: string;
begin
  fCaptureButton.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    lSnapshot := TResourceSnapshotService.Capture(SelectedProcessId);
    TResourceSnapshotService.AppendToLog(fLogEdit.Text, lSnapshot);
    fPreview.Text := lSnapshot;
    ShowMessage('Слепок добавлен в лог:'#13#10 + fLogEdit.Text);
  except
    on E: Exception do
    begin
      ShowMessage('Не удалось снять слепок: ' + E.Message);
      RefreshProcesses(nil);
    end;
  end;
  Screen.Cursor := crDefault;
  fCaptureButton.Enabled := fProcessBox.ItemIndex >= 0;
end;

end.
