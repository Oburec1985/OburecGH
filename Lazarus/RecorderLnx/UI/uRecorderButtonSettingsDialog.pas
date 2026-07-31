unit uRecorderButtonSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs,
  uRecorderFormModel, uRecorderTags;

type
  TRecorderButtonSettingsDialog = class(TForm)
    btnCancel: TButton;
    btnPressedImage: TButton;
    btnReleasedImage: TButton;
    btnOk: TButton;
    cbBehavior: TComboBox;
    cbTag: TComboBox;
    edCaption: TEdit;
    edPressedValue: TEdit;
    edPressedImage: TEdit;
    edPulseDuration: TEdit;
    edReleasedValue: TEdit;
    edReleasedImage: TEdit;
    edTagSearch: TEdit;
    lblBehavior: TLabel;
    lblCaption: TLabel;
    lblPressedValue: TLabel;
    lblPressedImage: TLabel;
    lblPulseDuration: TLabel;
    lblReleasedValue: TLabel;
    lblReleasedImage: TLabel;
    lblTag: TLabel;
    lblTagHint: TLabel;
    lblTagSearch: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure btnPressedImageClick(Sender: TObject);
    procedure btnReleasedImageClick(Sender: TObject);
    procedure cbBehaviorChange(Sender: TObject);
    procedure edTagSearchChange(Sender: TObject);
  private
    fButton: TRecorderButtonComponent;
    fTagRegistry: TRecorderTagRegistry;
    procedure LoadButton;
    procedure PopulateTags(const AFilter: string);
    procedure UpdateBehaviorUi;
    procedure SelectImage(AEdit: TEdit);
  public
    constructor CreateDialog(AOwner: TComponent; AButton: TRecorderButtonComponent;
      ATagRegistry: TRecorderTagRegistry); reintroduce;
  end;

function ShowRecorderButtonSettingsDialog(AOwner: TComponent;
  AButton: TRecorderButtonComponent; ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

{$R *.lfm}

function ShowRecorderButtonSettingsDialog(AOwner: TComponent;
  AButton: TRecorderButtonComponent; ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderButtonSettingsDialog;
begin
  lDialog := TRecorderButtonSettingsDialog.CreateDialog(AOwner, AButton, ATagRegistry);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderButtonSettingsDialog.CreateDialog(AOwner: TComponent;
  AButton: TRecorderButtonComponent; ATagRegistry: TRecorderTagRegistry);
begin
  inherited Create(AOwner);
  fButton := AButton;
  fTagRegistry := ATagRegistry;
  LoadButton;
end;

procedure TRecorderButtonSettingsDialog.PopulateTags(const AFilter: string);
var
  I: Integer;
  lFilter, lSelected, lText: string;
  lTag: TRecorderTag;
begin
  lSelected := cbTag.Text;
  cbTag.Items.BeginUpdate;
  try
    cbTag.Items.Clear;
    lFilter := LowerCase(Trim(AFilter));
    if fTagRegistry <> nil then
      for I := 0 to fTagRegistry.TagCount - 1 do
      begin
        lTag := fTagRegistry.Tags[I];
        if not lTag.IsVirtual then
          Continue;
        lText := LowerCase(lTag.Name + ' ' + lTag.Description + ' ' + lTag.Address);
        if (lFilter = '') or (Pos(lFilter, lText) > 0) then
          cbTag.Items.AddObject(lTag.Name, lTag);
      end;
    cbTag.ItemIndex := cbTag.Items.IndexOf(lSelected);
    if (cbTag.ItemIndex < 0) and (cbTag.Items.Count > 0) then cbTag.ItemIndex := 0;
  finally
    cbTag.Items.EndUpdate;
  end;
end;

procedure TRecorderButtonSettingsDialog.LoadButton;
begin
  edCaption.Text := fButton.Caption;
  cbTag.Text := fButton.TagName;
  PopulateTags('');
  if fButton.TagName <> '' then cbTag.ItemIndex := cbTag.Items.IndexOf(fButton.TagName);
  cbBehavior.ItemIndex := Ord(fButton.Behavior);
  edPressedValue.Text := FloatToStr(fButton.PressedValue);
  edReleasedValue.Text := FloatToStr(fButton.ReleasedValue);
  edPulseDuration.Text := IntToStr(fButton.PulseDurationMs);
  edPressedImage.Text := fButton.PressedImageFileName;
  edReleasedImage.Text := fButton.ReleasedImageFileName;
  UpdateBehaviorUi;
end;

procedure TRecorderButtonSettingsDialog.SelectImage(AEdit: TEdit);
var
  lDialog: TOpenDialog;
begin
  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Filter := 'Изображения|*.png;*.jpg;*.jpeg;*.bmp;*.gif|Все файлы|*.*';
    lDialog.FileName := AEdit.Text;
    if lDialog.Execute then AEdit.Text := lDialog.FileName;
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderButtonSettingsDialog.btnPressedImageClick(Sender: TObject);
begin
  SelectImage(edPressedImage);
end;

procedure TRecorderButtonSettingsDialog.btnReleasedImageClick(Sender: TObject);
begin
  SelectImage(edReleasedImage);
end;

procedure TRecorderButtonSettingsDialog.UpdateBehaviorUi;
begin
  lblPulseDuration.Enabled := cbBehavior.ItemIndex = Ord(rbbPulse);
  edPulseDuration.Enabled := lblPulseDuration.Enabled;
end;

procedure TRecorderButtonSettingsDialog.cbBehaviorChange(Sender: TObject);
begin
  UpdateBehaviorUi;
end;

procedure TRecorderButtonSettingsDialog.edTagSearchChange(Sender: TObject);
begin
  PopulateTags(edTagSearch.Text);
end;

procedure TRecorderButtonSettingsDialog.btnOkClick(Sender: TObject);
var
  lPressed, lReleased: Double;
  lPulseMs: Integer;
  lTag: TRecorderTag;
begin
  if not TryStrToFloat(edPressedValue.Text, lPressed) then
  begin
    MessageDlg('Неверное значение для нажатого состояния.', mtError, [mbOK], 0);
    edPressedValue.SetFocus;
    Exit;
  end;
  if not TryStrToFloat(edReleasedValue.Text, lReleased) then
  begin
    MessageDlg('Неверное значение для отпущенного состояния.', mtError, [mbOK], 0);
    edReleasedValue.SetFocus;
    Exit;
  end;
  if not TryStrToInt(edPulseDuration.Text, lPulseMs) or (lPulseMs < 1) then
  begin
    MessageDlg('Длительность импульса должна быть не меньше 1 мс.', mtError, [mbOK], 0);
    edPulseDuration.SetFocus;
    Exit;
  end;
  if cbTag.ItemIndex < 0 then
  begin
    MessageDlg('Выберите тег, значение которого изменяет кнопка.', mtError, [mbOK], 0);
    cbTag.SetFocus;
    Exit;
  end;
  lTag := TRecorderTag(cbTag.Items.Objects[cbTag.ItemIndex]);
  fButton.Caption := edCaption.Text;
  fButton.TagId := lTag.Id;
  fButton.TagName := lTag.Name;
  fButton.Behavior := TRecorderButtonBehavior(cbBehavior.ItemIndex);
  fButton.PressedValue := lPressed;
  fButton.ReleasedValue := lReleased;
  fButton.PulseDurationMs := lPulseMs;
  fButton.PressedImageFileName := Trim(edPressedImage.Text);
  fButton.ReleasedImageFileName := Trim(edReleasedImage.Text);
  ModalResult := mrOk;
end;

end.
