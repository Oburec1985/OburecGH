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
  lLabel: TLabel;
  lOkButton, lCancelButton: TButton;
  lTag: TRecorderTag;
  I, lRowHeight, lEditHeight: Integer;
begin
  Result := False;
  lForm := TForm.CreateNew(AOwner, 1);
  try
    lForm.Caption := 'Настройка поля ввода';
    lForm.Position := poScreenCenter;
    lForm.BorderStyle := bsSizeable;
    lForm.Constraints.MinWidth := 430;
    lRowHeight := lForm.Canvas.TextHeight('Ag') + 14;
    if lRowHeight < 32 then lRowHeight := 32;
    lEditHeight := lForm.Canvas.TextHeight('Ag') + 10;
    if lEditHeight < 27 then lEditHeight := 27;
    lForm.SetBounds(0, 0, 430, 3 * lRowHeight + 64);
    lForm.Constraints.MinHeight := lForm.Height;
    lLabel := TLabel.Create(lForm);
    lLabel.Parent := lForm; lLabel.Caption := 'Тег'; lLabel.AutoSize := True;
    lLabel.SetBounds(12, 12 + (lEditHeight - lLabel.Height) div 2, 80, lLabel.Height);
    lTags := TComboBox.Create(lForm);
    lTags.Parent := lForm; lTags.Style := csDropDownList;
    lTags.SetBounds(95, 12, lForm.ClientWidth - 107, lEditHeight);
    lTags.Anchors := [akLeft, akTop, akRight];
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
    lLabel := TLabel.Create(lForm);
    lLabel.Parent := lForm; lLabel.Caption := 'Формат'; lLabel.AutoSize := True;
    lLabel.SetBounds(12, 12 + lRowHeight + (lEditHeight - lLabel.Height) div 2,
      80, lLabel.Height);
    lFormat := TEdit.Create(lForm); lFormat.Parent := lForm;
    lFormat.SetBounds(95, 12 + lRowHeight, lForm.ClientWidth - 107, lEditHeight);
    lFormat.Anchors := [akLeft, akTop, akRight];
    lFormat.Text := AField.DisplayFormat;
    lCancelButton := TButton.Create(lForm);
    lCancelButton.Parent := lForm; lCancelButton.Caption := 'Отмена';
    lCancelButton.ModalResult := mrCancel; lCancelButton.Cancel := True;
    lCancelButton.SetBounds(lForm.ClientWidth - 100, lForm.ClientHeight - 40, 88, 28);
    lCancelButton.Anchors := [akRight, akBottom];
    lOkButton := TButton.Create(lForm);
    lOkButton.Parent := lForm; lOkButton.Caption := 'OK'; lOkButton.ModalResult := mrOk;
    lOkButton.Default := True;
    lOkButton.SetBounds(lCancelButton.Left - 96, lCancelButton.Top, 88, 28);
    lOkButton.Anchors := [akRight, akBottom];
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
