unit uRecorderSqlSelectionImportDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Forms, Controls, StdCtrls;

function ShowRecorderSqlSelectionImportDialog(AOwner: TComponent;
  out ADisableUnmarked, ADeleteUnmarkedFromDb: Boolean): Boolean;

implementation

function ShowRecorderSqlSelectionImportDialog(AOwner: TComponent;
  out ADisableUnmarked, ADeleteUnmarkedFromDb: Boolean): Boolean;
var
  lForm: TForm;
  lOkButton, lCancelButton: TButton;
  lDisableCheck, lDeleteCheck: TCheckBox;
begin
  Result := False;
  ADisableUnmarked := False;
  ADeleteUnmarkedFromDb := False;
  lForm := TForm.CreateNew(AOwner);
  try
    lForm.Caption := 'Параметры загрузки SQLdb';
    lForm.BorderStyle := bsDialog;
    lForm.Position := poOwnerFormCenter;
    lForm.ClientWidth := 620;
    lForm.ClientHeight := 130;

    lDisableCheck := TCheckBox.Create(lForm);
    lDisableCheck.Parent := lForm;
    lDisableCheck.SetBounds(12, 14, 590, 24);
    lDisableCheck.Caption :=
      'Отключить запись каналов таблицы, у которых SQLdb не отмечен';
    lDeleteCheck := TCheckBox.Create(lForm);
    lDeleteCheck.Parent := lForm;
    lDeleteCheck.SetBounds(12, 42, 590, 24);
    lDeleteCheck.Caption := 'Удалить эти невыбранные каналы из БД';

    lOkButton := TButton.Create(lForm);
    lOkButton.Parent := lForm;
    lOkButton.SetBounds(420, 88, 90, 30);
    lOkButton.Caption := 'Загрузить';
    lOkButton.Default := True;
    lOkButton.ModalResult := mrOk;
    lCancelButton := TButton.Create(lForm);
    lCancelButton.Parent := lForm;
    lCancelButton.SetBounds(518, 88, 90, 30);
    lCancelButton.Caption := 'Отмена';
    lCancelButton.Cancel := True;
    lCancelButton.ModalResult := mrCancel;

    if lForm.ShowModal <> mrOk then Exit;
    ADisableUnmarked := lDisableCheck.Checked;
    ADeleteUnmarkedFromDb := lDeleteCheck.Checked;
    Result := True;
  finally
    lForm.Free;
  end;
end;

end.
