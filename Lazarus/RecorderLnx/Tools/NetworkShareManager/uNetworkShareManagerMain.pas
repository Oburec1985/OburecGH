unit uNetworkShareManagerMain;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Process, Dialogs,
  LCLIntf;

type
  TNetworkShareManagerForm = class(TForm)
  private
    fHostEdit: TEdit;
    fShareEdit: TEdit;
    fLocalNameEdit: TEdit;
    fResourcesList: TListBox;
    fStatusLabel: TLabel;
    procedure ConnectClick(Sender: TObject);
    procedure DisconnectClick(Sender: TObject);
    procedure OpenClick(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    function RunHelper(const AAction: string): Boolean;
    function SelectedLocalName: string;
    procedure BuildUi;
    procedure RefreshResources;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  NetworkShareManagerForm: TNetworkShareManagerForm;

implementation

const
  CHelper = '/usr/local/sbin/recorderlnx-connect-share';
  CMountRoot = '/home/user/Сеть/MeraFiles';

function AddLabel(AOwner: TComponent; AParent: TWinControl; ATop: Integer;
  const ACaption: string): TLabel;
begin
  Result := TLabel.Create(AOwner);
  Result.Parent := AParent;
  Result.SetBounds(12, ATop, 160, 20);
  Result.Caption := ACaption;
end;

function AddButton(AOwner: TComponent; AParent: TWinControl; ALeft: Integer;
  const ACaption: string; AHandler: TNotifyEvent): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Parent := AParent;
  Result.SetBounds(ALeft, 170, 105, 30);
  Result.Caption := ACaption;
  Result.OnClick := AHandler;
end;

constructor TNetworkShareManagerForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner, 1);
  BuildUi;
  RefreshResources;
end;

procedure TNetworkShareManagerForm.BuildUi;
var
  lPanel: TPanel;
begin
  Caption := 'Сетевые ресурсы MERA';
  SetBounds(200, 150, 620, 430);
  Position := poScreenCenter;
  lPanel := TPanel.Create(Self);
  lPanel.Parent := Self;
  lPanel.Align := alTop;
  lPanel.Height := 215;
  AddLabel(Self, lPanel, 14, 'Хост или IP');
  fHostEdit := TEdit.Create(Self); fHostEdit.Parent := lPanel;
  fHostEdit.SetBounds(175, 10, 420, 26);
  AddLabel(Self, lPanel, 54, 'Имя SMB-папки');
  fShareEdit := TEdit.Create(Self); fShareEdit.Parent := lPanel;
  fShareEdit.SetBounds(175, 50, 420, 26); fShareEdit.Text := 'MeraFiles';
  AddLabel(Self, lPanel, 94, 'Локальное название');
  fLocalNameEdit := TEdit.Create(Self); fLocalNameEdit.Parent := lPanel;
  fLocalNameEdit.SetBounds(175, 90, 420, 26);
  AddButton(Self, lPanel, 175, 'Подключить', @ConnectClick);
  AddButton(Self, lPanel, 290, 'Отключить', @DisconnectClick);
  AddButton(Self, lPanel, 405, 'Открыть', @OpenClick);
  AddButton(Self, lPanel, 520, 'Обновить', @RefreshClick).Width := 75;
  fStatusLabel := AddLabel(Self, lPanel, 205, '');
  fStatusLabel.AutoSize := True;
  fResourcesList := TListBox.Create(Self);
  fResourcesList.Parent := Self;
  fResourcesList.Align := alClient;
end;

function TNetworkShareManagerForm.RunHelper(const AAction: string): Boolean;
var
  lProcess: TProcess;
begin
  Result := False;
  if not FileExists(CHelper) then
  begin
    MessageDlg('Не установлена системная утилита ' + CHelper, mtError, [mbOK], 0);
    Exit;
  end;
  lProcess := TProcess.Create(nil);
  try
    lProcess.Executable := 'pkexec';
    lProcess.Parameters.Add(CHelper);
    lProcess.Parameters.Add(AAction);
    lProcess.Parameters.Add(Trim(fHostEdit.Text));
    lProcess.Parameters.Add(Trim(fShareEdit.Text));
    lProcess.Parameters.Add(Trim(fLocalNameEdit.Text));
    lProcess.Options := [poWaitOnExit];
    lProcess.Execute;
    Result := lProcess.ExitStatus = 0;
  finally
    lProcess.Free;
  end;
end;

procedure TNetworkShareManagerForm.ConnectClick(Sender: TObject);
begin
  if (Trim(fHostEdit.Text) = '') or (Trim(fShareEdit.Text) = '') or
    (Trim(fLocalNameEdit.Text) = '') then
  begin
    MessageDlg('Заполните хост, SMB-папку и локальное название.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  if RunHelper('connect') then fStatusLabel.Caption := 'Ресурс подключён'
  else fStatusLabel.Caption := 'Ошибка подключения';
  RefreshResources;
end;

procedure TNetworkShareManagerForm.DisconnectClick(Sender: TObject);
begin
  if fResourcesList.ItemIndex < 0 then Exit;
  fLocalNameEdit.Text := SelectedLocalName;
  if RunHelper('disconnect') then fStatusLabel.Caption := 'Ресурс отключён'
  else fStatusLabel.Caption := 'Ошибка отключения';
  RefreshResources;
end;

function TNetworkShareManagerForm.SelectedLocalName: string;
begin
  Result := fResourcesList.Items[fResourcesList.ItemIndex];
end;

procedure TNetworkShareManagerForm.OpenClick(Sender: TObject);
begin
  if fResourcesList.ItemIndex < 0 then Exit;
  OpenDocument(IncludeTrailingPathDelimiter(CMountRoot) + SelectedLocalName);
end;

procedure TNetworkShareManagerForm.RefreshClick(Sender: TObject);
begin
  RefreshResources;
end;

procedure TNetworkShareManagerForm.RefreshResources;
var
  lInfo: TSearchRec;
begin
  fResourcesList.Clear;
  if FindFirst(IncludeTrailingPathDelimiter(CMountRoot) + '*', faDirectory,
    lInfo) <> 0 then Exit;
  try
    repeat
      if (lInfo.Name <> '.') and (lInfo.Name <> '..') and
        ((lInfo.Attr and faDirectory) <> 0) then fResourcesList.Items.Add(lInfo.Name);
    until FindNext(lInfo) <> 0;
  finally
    FindClose(lInfo);
  end;
end;

end.
