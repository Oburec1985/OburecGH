unit uRecorderInputFieldSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils, Forms, Controls, StdCtrls, Dialogs,
  uRecorderFormModel, uRecorderTags;

function ShowRecorderInputFieldSettingsDialog(AOwner: TComponent;
  AField: TRecorderInputFieldComponent;
  ARegistry: TRecorderTagRegistry): Boolean;

implementation

function ShowRecorderInputFieldSettingsDialog(AOwner: TComponent;
  AField: TRecorderInputFieldComponent;
  ARegistry: TRecorderTagRegistry): Boolean;
var
  lForm: TForm;
  lTags: TComboBox;
  lFormat: TEdit;
  lTag: TRecorderTag;
  I: Integer;
begin
  Result := False;
  lForm := TForm.CreateNew(AOwner, 1);
  try
    lForm.Caption := 'Настройка поля ввода';
    lForm.Position := poScreenCenter;
    lForm.SetBounds(0, 0, 430, 155);
    with TLabel.Create(lForm) do begin Parent := lForm; Caption := 'Тег'; SetBounds(12, 16, 80, 22); end;
    lTags := TComboBox.Create(lForm);
    lTags.Parent := lForm; lTags.Style := csDropDownList;
    lTags.SetBounds(95, 12, 315, 27);
    if ARegistry <> nil then
      for I := 0 to ARegistry.TagCount - 1 do
      begin
        lTag := ARegistry.Tags[I];
        if (lTag <> nil) and lTag.ExternalWriteAllowed then
        begin
          lTags.Items.AddObject(lTag.Name, lTag);
          if (lTag.Id = AField.TagId) or SameText(lTag.Name, AField.TagName) then
            lTags.ItemIndex := lTags.Items.Count - 1;
        end;
      end;
    with TLabel.Create(lForm) do begin Parent := lForm; Caption := 'Формат'; SetBounds(12, 53, 80, 22); end;
    lFormat := TEdit.Create(lForm); lFormat.Parent := lForm;
    lFormat.SetBounds(95, 49, 315, 27); lFormat.Text := AField.DisplayFormat;
    with TButton.Create(lForm) do begin Parent := lForm; Caption := 'OK'; ModalResult := mrOk; Default := True; SetBounds(245, 90, 80, 28); end;
    with TButton.Create(lForm) do begin Parent := lForm; Caption := 'Отмена'; ModalResult := mrCancel; Cancel := True; SetBounds(330, 90, 80, 28); end;
    if lForm.ShowModal <> mrOk then Exit;
    if lTags.ItemIndex < 0 then
    begin
      MessageDlg('Поле ввода', 'Выберите тег, допускающий внешний ввод.',
        mtWarning, [mbOK], 0);
      Exit;
    end;
    lTag := TRecorderTag(lTags.Items.Objects[lTags.ItemIndex]);
    AField.TagId := lTag.Id;
    AField.TagName := lTag.Name;
    AField.DisplayFormat := Trim(lFormat.Text);
    if AField.DisplayFormat = '' then AField.DisplayFormat := '0.###';
    Result := True;
  finally
    lForm.Free;
  end;
end;

end.
