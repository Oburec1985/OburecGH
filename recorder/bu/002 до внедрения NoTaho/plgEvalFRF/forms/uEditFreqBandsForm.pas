unit uEditFreqBandsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, Grids, StdCtrls, ExtCtrls;

type
  TFreqBand = record
    F1: Double;
    F2: Double;
    Delta: Double;
  end;

  tbandarray = array of TFreqBand;
  pbandarray =   ^tbandarray;

  TEditFreqBandsForm = class(TForm)
    Panel1: TPanel;
    StringGrid: TStringGrid;
    OKBtn: TButton;
    CancelBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    PEditedBands: pbandarray;
    procedure PopulateGrid( ABands: pbandarray);
    function GetEditedData: pbandarray;
  public
    function Edit (ABands: pbandarray): Boolean;
  end;


var
  EditFreqBandsForm: TEditFreqBandsForm;

implementation

{$R *.dfm}

procedure TEditFreqBandsForm.FormCreate(Sender: TObject);
begin
  StringGrid.ColCount := 3;
  StringGrid.FixedRows := 1;
  StringGrid.Cells[0, 0] := 'F1';
  StringGrid.Cells[1, 0] := 'F2';
  StringGrid.Cells[2, 0] := 'Delta';
  StringGrid.ColWidths[0] := 80;
  StringGrid.ColWidths[1] := 80;
  StringGrid.ColWidths[2] := 100;
end;

procedure TEditFreqBandsForm.OKBtnClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TEditFreqBandsForm.PopulateGrid(ABands: pbandarray);
var
  i: Integer;
begin
  StringGrid.RowCount := Length(ABands^) + StringGrid.FixedRows;
  for i := Low(ABands^) to High(ABands^) do
  begin
    StringGrid.Cells[0, i + StringGrid.FixedRows] := FloatToStr(ABands^[i].F1);
    StringGrid.Cells[1, i + StringGrid.FixedRows] := FloatToStr(ABands^[i].F2);
    StringGrid.Cells[2, i + StringGrid.FixedRows] := FloatToStr(ABands^[i].Delta);
  end;
end;

function TEditFreqBandsForm.GetEditedData: pbandarray;
var
  i: Integer;
begin
  SetLength(PEditedBands^, StringGrid.RowCount - StringGrid.FixedRows);
  for i := 0 to Length(PEditedBands^) - 1 do
  begin
    try
      PEditedBands^[i].F1 := StrToFloat(StringGrid.Cells[0, i + StringGrid.FixedRows]);
      PEditedBands^[i].F2 := StrToFloat(StringGrid.Cells[1, i + StringGrid.FixedRows]);
      PEditedBands^[i].Delta := StrToFloat(StringGrid.Cells[2, i + StringGrid.FixedRows]);
    except
      on E: Exception do
      begin
        // Обработка ошибки преобразования, например, присвоение значения по умолчанию
        PEditedBands^[i].F1 := 0.0;
        PEditedBands^[i].F2 := 0.0;
        PEditedBands^[i].Delta := 0.0;
        // Можно также показать сообщение пользователю о некорректном вводе
        ShowMessageFmt('Ошибка в строке %d: некорректный формат числа.', [i + StringGrid.FixedRows]);
        // Или решить прервать операцию.  В 2010 нет Exit; из блока исключения.
        Break; // Используем Break для выхода из цикла.
      end;
    end;
  end;
end;

function TEditFreqBandsForm.Edit(ABands: pbandarray): Boolean;
begin
  PEditedBands := @ABands;
  PopulateGrid(PEditedBands);
  Result := (ShowModal = mrOK);
  if Result then
  begin
    ABands := GetEditedData;
  end;
end;

end.
