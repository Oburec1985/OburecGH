unit uRecorderUiTestData;

{
  Модуль uRecorderUiTestData

  Назначение:
    Тестовое наполнение UI RecorderLnx на раннем этапе разработки. Здесь живут
    временные данные для формуляра и списка тегов, чтобы рабочая форма не
    содержала демонстрационную доменную логику.

  Место в архитектуре:
    Tests/UITestData. Модуль можно подключать только для временного UI-скелета и
    тестовых примеров. Настоящие данные формуляры должны получать через теги из
    событий Recorder/notify, устройств и плагинов.

  Ограничения:
    Данные в этом модуле не являются моделью тегов RecorderLnx. Это только
    заглушка до появления core-модели тегов и механизма notify.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Grids;

{ Заполняет таблицу формуляра демонстрационным отладочным тегом.

  AGrid - таблица на активном формуляре UI.
}
procedure FillPlaceholderFormular(AGrid: TStringGrid);

{ Заполняет цифровой формуляр демонстрационными значениями тегов.

  AGrid - таблица цифрового отображения тегов на встроенной странице.
}
procedure FillDigitalFormular(AGrid: TStringGrid);

{ Заполняет список тегов с учетом фильтра.

  AItems  - список UI-компонента, который нужно заполнить.
  AFilter - подстрока поиска; пустая строка показывает все тестовые теги.
}
procedure FillPlaceholderTagList(AItems: TStrings; const AFilter: string);

implementation

procedure FillPlaceholderFormular(AGrid: TStringGrid);
begin
  AGrid.ColCount := 5;
  AGrid.RowCount := 2;
  AGrid.FixedRows := 1;
  AGrid.Cells[0, 0] := 'Name';
  AGrid.Cells[1, 0] := 'Address';
  AGrid.Cells[2, 0] := 'Unit';
  AGrid.Cells[3, 0] := 'Value';
  AGrid.Cells[4, 0] := 'Description';
  AGrid.Cells[0, 1] := 'MemTag';
  AGrid.Cells[1, 1] := 'virtual';
  AGrid.Cells[2, 1] := 'm';
  AGrid.Cells[3, 1] := '-';
  AGrid.Cells[4, 1] := 'Debug tag created by test plugin placeholder';
end;

procedure FillDigitalFormular(AGrid: TStringGrid);
begin
  AGrid.ColCount := 5;
  AGrid.RowCount := 5;
  AGrid.FixedRows := 1;
  AGrid.Cells[0, 0] := 'Tag';
  AGrid.Cells[1, 0] := 'Value';
  AGrid.Cells[2, 0] := 'Unit';
  AGrid.Cells[3, 0] := 'State';
  AGrid.Cells[4, 0] := 'Source';

  AGrid.Cells[0, 1] := 'MemTag';
  AGrid.Cells[1, 1] := '0.0';
  AGrid.Cells[2, 1] := 'm';
  AGrid.Cells[3, 1] := 'Ok';
  AGrid.Cells[4, 1] := 'virtual';

  AGrid.Cells[0, 2] := 'Pressure';
  AGrid.Cells[1, 2] := '0.0';
  AGrid.Cells[2, 2] := 'kPa';
  AGrid.Cells[3, 2] := 'Ok';
  AGrid.Cells[4, 2] := 'virtual';

  AGrid.Cells[0, 3] := 'Temperature';
  AGrid.Cells[1, 3] := '0.0';
  AGrid.Cells[2, 3] := 'C';
  AGrid.Cells[3, 3] := 'Ok';
  AGrid.Cells[4, 3] := 'virtual';

  AGrid.Cells[0, 4] := 'Speed';
  AGrid.Cells[1, 4] := '0.0';
  AGrid.Cells[2, 4] := 'rpm';
  AGrid.Cells[3, 4] := 'Ok';
  AGrid.Cells[4, 4] := 'virtual';
end;

procedure FillPlaceholderTagList(AItems: TStrings; const AFilter: string);
begin
  AItems.Clear;

  if (AFilter = '') or (Pos(LowerCase(AFilter), 'memtag') > 0) then
    AItems.Add('MemTag        0.0');
end;

end.
