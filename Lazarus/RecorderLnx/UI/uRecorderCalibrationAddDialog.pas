unit uRecorderCalibrationAddDialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Buttons,
  uRecorderTags;

type
  TRecorderCalibrationAddAction = (rcaaCreate, rcaaLoadFromSdb);

  TRecorderCalibrationAddDialog = class(TForm)
    btnAdd: TButton;
    btnCancel: TButton;
    lbTypes: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure lbTypesDblClick(Sender: TObject);
  public
    function SelectedKind: TRecorderCalibrationKind;
    function SelectedAction: TRecorderCalibrationAddAction;
  end;

function ShowRecorderCalibrationAddDialog(AOwner: TComponent;
  out AKind: TRecorderCalibrationKind;
  out AAction: TRecorderCalibrationAddAction): Boolean;

implementation

{$R *.lfm}

procedure TRecorderCalibrationAddDialog.FormCreate(Sender: TObject);
begin
  lbTypes.Items.Clear;
  lbTypes.Items.AddObject('Загрузить из БД ГХ', TObject(PtrInt(-1)));
  lbTypes.Items.AddObject('Импорт из файла', TObject(PtrInt(-1)));
  lbTypes.Items.AddObject('Масштабный множитель (чувствительность)', TObject(PtrInt(Ord(rckScale))));
  lbTypes.Items.AddObject('Таблица линейной интерполяции первого порядка', TObject(PtrInt(Ord(rckPiecewiseLinear))));
  lbTypes.Items.AddObject('A(x-B)', TObject(PtrInt(-1)));
  lbTypes.Items.AddObject('Полином', TObject(PtrInt(-1)));
  lbTypes.ItemIndex := 3;
end;

procedure TRecorderCalibrationAddDialog.lbTypesDblClick(Sender: TObject);
var
  lValue: PtrInt;
begin
  if lbTypes.ItemIndex < 0 then
    Exit;
  lValue := PtrInt(lbTypes.Items.Objects[lbTypes.ItemIndex]);
  if (lValue >= 0) or (lbTypes.ItemIndex = 0) then
    ModalResult := mrOk;
end;

function TRecorderCalibrationAddDialog.SelectedKind: TRecorderCalibrationKind;
var
  lValue: PtrInt;
begin
  Result := rckPiecewiseLinear;
  if lbTypes.ItemIndex < 0 then
    Exit;
  lValue := PtrInt(lbTypes.Items.Objects[lbTypes.ItemIndex]);
  if lValue = Ord(rckScale) then
    Result := rckScale;
end;

function TRecorderCalibrationAddDialog.SelectedAction: TRecorderCalibrationAddAction;
begin
  Result := rcaaCreate;
  if lbTypes.ItemIndex = 0 then
    Result := rcaaLoadFromSdb;
end;

function ShowRecorderCalibrationAddDialog(AOwner: TComponent;
  out AKind: TRecorderCalibrationKind;
  out AAction: TRecorderCalibrationAddAction): Boolean;
var
  lDialog: TRecorderCalibrationAddDialog;
begin
  lDialog := TRecorderCalibrationAddDialog.Create(AOwner);
  try
    Result := lDialog.ShowModal = mrOk;
    if Result then
    begin
      AKind := lDialog.SelectedKind;
      AAction := lDialog.SelectedAction;
    end;
  finally
    lDialog.Free;
  end;
end;

end.
