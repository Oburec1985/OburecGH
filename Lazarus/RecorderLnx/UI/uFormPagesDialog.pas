unit uFormPagesDialog;

{
  Модуль uFormPagesDialog

  Назначение:
    Модальный редактор/диалог для управления страницами (мнемосхемами) RecorderLnx.
    Диалог работает с доменной моделью форм (TRecorderFormManager) и позволяет
    создавать пустые мнемосхемы, переименовывать их, удалять и менять порядок.

  Архитектура:
    Слой пользовательского интерфейса (UI layer). Доменные операции осуществляются
    через TRecorderFormManager и TRecorderFormFactory.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids,
  uRecorderFormModel;

type
  { TFormPagesDialog
    Диалоговое окно для работы со страницами формуляров. }
  TFormPagesDialog = class(TForm)
  private
    fActivating: Boolean;                  { Флаг процесса активации страницы }
    fFactory: TRecorderFormFactory;        { Фабрика создания форм }
    fGrid: TStringGrid;                    { Таблица со списком страниц }
    fManager: TRecorderFormManager;        { Менеджер форм }
    fNameEdit: TEdit;                      { Поле редактирования имени выбранной страницы }
    fNextPageNo: Integer;                  { Счетчик номера следующей создаваемой страницы }
    fUpdating: Boolean;                    { Флаг внутренней синхронизации и обновления UI }
    
    procedure ActivateSelectedPage;
    procedure AddMnemonicClick(Sender: TObject);
    procedure ActivateClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure MoveDownClick(Sender: TObject);
    procedure MoveUpClick(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure RefreshGrid;
    procedure SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    function GetSelectedPage: TRecorderFormPage;
    function GetSelectedPageIndex: Integer;
    function PageDescription(APage: TRecorderFormPage): string;
    function UniquePageId: string;
  public
    { Конструктор диалогового окна
      AManager   - ссылка на менеджер форм.
      AFactory   - ссылка на фабрику форм.
      ANextPageNo - начальный номер для генерации новых страниц. }
    constructor CreateDialog(AOwner: TComponent; AManager: TRecorderFormManager;
      AFactory: TRecorderFormFactory; ANextPageNo: Integer);
    property NextPageNo: Integer read fNextPageNo;
  end;

implementation

const
  CDialogWidth = 568;
  CDialogHeight = 338;

constructor TFormPagesDialog.CreateDialog(AOwner: TComponent;
  AManager: TRecorderFormManager; AFactory: TRecorderFormFactory;
  ANextPageNo: Integer);
var
  lNameLabel: TLabel;
  lAddMnemonic: TButton;
  lActivate: TButton;
  lOk: TButton;
  lCancel: TButton;
  lDelete: TButton;
  lMoveUp: TButton;
  lMoveDown: TButton;
  lImport: TButton;
  lExport: TButton;
begin
  inherited CreateNew(AOwner);

  fManager := AManager;
  fFactory := AFactory;
  fNextPageNo := ANextPageNo;

  Caption := 'Formulars';
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  ClientWidth := CDialogWidth;
  ClientHeight := CDialogHeight;

  lNameLabel := TLabel.Create(Self);
  lNameLabel.Parent := Self;
  lNameLabel.Left := 18;
  lNameLabel.Top := 14;
  lNameLabel.Caption := 'Page name';

  fNameEdit := TEdit.Create(Self);
  fNameEdit.Parent := Self;
  fNameEdit.Left := 18;
  fNameEdit.Top := 34;
  fNameEdit.Width := 452;
  fNameEdit.OnChange := @NameEditChange;

  fGrid := TStringGrid.Create(Self);
  fGrid.Parent := Self;
  fGrid.Left := 10;
  fGrid.Top := 74;
  fGrid.Width := 462;
  fGrid.Height := 168;
  fGrid.ColCount := 2;
  fGrid.FixedRows := 1;
  fGrid.RowCount := 1;
  fGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
    goRangeSelect, goRowSelect];
  fGrid.ColWidths[0] := 170;
  fGrid.ColWidths[1] := 280;
  fGrid.OnSelectCell := @SelectCell;

  lDelete := TButton.Create(Self);
  lDelete.Parent := Self;
  lDelete.Left := 482;
  lDelete.Top := 74;
  lDelete.Width := 76;
  lDelete.Height := 24;
  lDelete.Caption := 'Delete';
  lDelete.OnClick := @DeleteClick;

  lMoveUp := TButton.Create(Self);
  lMoveUp.Parent := Self;
  lMoveUp.Left := 482;
  lMoveUp.Top := 104;
  lMoveUp.Width := 76;
  lMoveUp.Height := 24;
  lMoveUp.Caption := 'Up';
  lMoveUp.OnClick := @MoveUpClick;

  lMoveDown := TButton.Create(Self);
  lMoveDown.Parent := Self;
  lMoveDown.Left := 482;
  lMoveDown.Top := 134;
  lMoveDown.Width := 76;
  lMoveDown.Height := 24;
  lMoveDown.Caption := 'Down';
  lMoveDown.OnClick := @MoveDownClick;

  lImport := TButton.Create(Self);
  lImport.Parent := Self;
  lImport.Left := 482;
  lImport.Top := 176;
  lImport.Width := 76;
  lImport.Height := 24;
  lImport.Caption := 'Import';
  lImport.Enabled := False;

  lExport := TButton.Create(Self);
  lExport.Parent := Self;
  lExport.Left := 482;
  lExport.Top := 206;
  lExport.Width := 76;
  lExport.Height := 24;
  lExport.Caption := 'Export';
  lExport.Enabled := False;

  lAddMnemonic := TButton.Create(Self);
  lAddMnemonic.Parent := Self;
  lAddMnemonic.Left := 10;
  lAddMnemonic.Top := 252;
  lAddMnemonic.Width := 142;
  lAddMnemonic.Height := 24;
  lAddMnemonic.Caption := 'Add mnemonic';
  lAddMnemonic.OnClick := @AddMnemonicClick;

  lActivate := TButton.Create(Self);
  lActivate.Parent := Self;
  lActivate.Left := 268;
  lActivate.Top := 296;
  lActivate.Width := 86;
  lActivate.Height := 26;
  lActivate.Caption := 'Activate';
  lActivate.OnClick := @ActivateClick;

  lOk := TButton.Create(Self);
  lOk.Parent := Self;
  lOk.Left := 360;
  lOk.Top := 296;
  lOk.Width := 86;
  lOk.Height := 26;
  lOk.Caption := 'OK';
  lOk.ModalResult := mrOk;
  lOk.Default := True;

  lCancel := TButton.Create(Self);
  lCancel.Parent := Self;
  lCancel.Left := 452;
  lCancel.Top := 296;
  lCancel.Width := 86;
  lCancel.Height := 26;
  lCancel.Caption := 'Cancel';
  lCancel.ModalResult := mrCancel;
  lCancel.Cancel := True;

  RefreshGrid;
end;

function TFormPagesDialog.UniquePageId: string;
begin
  repeat
    Inc(fNextPageNo);
    Result := Format('Mnemonic%d', [fNextPageNo]);
  until fManager.FindPageById(Result) = nil;
end;

function TFormPagesDialog.PageDescription(APage: TRecorderFormPage): string;
begin
  if (APage.Id = 'DigitalForm') or (APage.Id = 'BasePage') then
    Result := 'Built-in page'
  else
    Result := 'Mnemonic page';
end;

function TFormPagesDialog.GetSelectedPageIndex: Integer;
begin
  Result := fGrid.Row - 1;
  if (Result < 0) or (Result >= fManager.PageCount) then
    Result := -1;
end;

function TFormPagesDialog.GetSelectedPage: TRecorderFormPage;
var
  lIndex: Integer;
begin
  lIndex := GetSelectedPageIndex;
  if lIndex < 0 then
    Result := nil
  else
    Result := fManager.Pages[lIndex];
end;

procedure TFormPagesDialog.RefreshGrid;
var
  I: Integer;
  lPage: TRecorderFormPage;
  lActiveIndex: Integer;
begin
  fUpdating := True;
  try
    fGrid.Cells[0, 0] := 'Name';
    fGrid.Cells[1, 0] := 'Description';
    fGrid.RowCount := fManager.PageCount + 1;
    lActiveIndex := -1;

    for I := 0 to fManager.PageCount - 1 do
    begin
      lPage := fManager.Pages[I];
      fGrid.Cells[0, I + 1] := lPage.Title;
      fGrid.Cells[1, I + 1] := PageDescription(lPage);
      if lPage = fManager.ActivePage then
        lActiveIndex := I + 1;
    end;

    if lActiveIndex > 0 then
      fGrid.Row := lActiveIndex
    else if fManager.PageCount > 0 then
      fGrid.Row := 1;

    if GetSelectedPage <> nil then
      fNameEdit.Text := GetSelectedPage.Title
    else
      fNameEdit.Text := '';
  finally
    fUpdating := False;
  end;
end;

procedure TFormPagesDialog.SelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if fUpdating then
    Exit;

  fUpdating := True;
  try
    if GetSelectedPage <> nil then
      fNameEdit.Text := GetSelectedPage.Title
    else
      fNameEdit.Text := '';
  finally
    fUpdating := False;
  end;
end;

procedure TFormPagesDialog.NameEditChange(Sender: TObject);
var
  lPage: TRecorderFormPage;
begin
  if fUpdating then
    Exit;

  lPage := GetSelectedPage;
  if lPage = nil then
    Exit;

  lPage.Title := fNameEdit.Text;
  fGrid.Cells[0, fGrid.Row] := lPage.Title;
end;

procedure TFormPagesDialog.AddMnemonicClick(Sender: TObject);
var
  lId: string;
  lPage: TRecorderFormPage;
begin
  lId := UniquePageId;
  lPage := fFactory.CreateBlankPage(lId, lId, 'New mnemonic');
  try
    fManager.AddPage(lPage);
  except
    lPage.Free;
    raise;
  end;
  fManager.SetActivePageById(lPage.Id);
  RefreshGrid;
end;

procedure TFormPagesDialog.DeleteClick(Sender: TObject);
var
  lPage: TRecorderFormPage;
begin
  lPage := GetSelectedPage;
  if lPage = nil then
    Exit;

  fManager.RemovePageById(lPage.Id);
  RefreshGrid;
end;

procedure TFormPagesDialog.MoveUpClick(Sender: TObject);
var
  lIndex: Integer;
begin
  lIndex := GetSelectedPageIndex;
  if lIndex > 0 then
  begin
    fManager.MovePage(lIndex, lIndex - 1);
    RefreshGrid;
    fGrid.Row := lIndex;
  end;
end;

procedure TFormPagesDialog.MoveDownClick(Sender: TObject);
var
  lIndex: Integer;
begin
  lIndex := GetSelectedPageIndex;
  if (lIndex >= 0) and (lIndex < fManager.PageCount - 1) then
  begin
    fManager.MovePage(lIndex, lIndex + 1);
    RefreshGrid;
    fGrid.Row := lIndex + 2;
  end;
end;

procedure TFormPagesDialog.ActivateSelectedPage;
var
  lPage: TRecorderFormPage;
begin
  lPage := GetSelectedPage;
  if lPage <> nil then
    fManager.SetActivePageById(lPage.Id);
end;

procedure TFormPagesDialog.ActivateClick(Sender: TObject);
begin
  fActivating := True;
  try
    ActivateSelectedPage;
    RefreshGrid;
  finally
    fActivating := False;
  end;
end;

end.
