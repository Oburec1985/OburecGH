program SqlTrendEventsShot;

{ Снимок диалога настроек SQL-тренда для визуальной проверки новых галочек
  событий. Запускается без аргументов и сохраняет PNG рядом с exe. }

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Classes, SysUtils, Forms, Controls, StdCtrls, Graphics,
  FPImage, FPWritePNG, IntfGraphics, GraphType,
  uRecorderSqlTrendModel, uRecorderSqlTrendSettingsDialog;

var
  lComponent: TRecorderSqlTrendComponent;
  lDialog: TRecorderSqlTrendSettingsDialog;
  lBitmap: TBitmap;
  lWriter: TFPWriterPNG;
  lImage: TFPMemoryImage;
  lIntf: TLazIntfImage;
  lOutName: string;
  lX, lY: Integer;
  lColor: TFPColor;
  lScreenShot: TBitmap;
begin
  Application.Initialize;
  lOutName := ChangeFileExt(ParamStr(0), '.png');
  lComponent := TRecorderSqlTrendComponent.Create;
  try
    lDialog := TRecorderSqlTrendSettingsDialog.CreateDialog(Application,
      lComponent, nil);
    try
      lDialog.Position := poDesigned;
      lDialog.Left := 40;
      lDialog.Top := 40;
      lDialog.Show;
      Application.ProcessMessages;
      Sleep(700);
      Application.ProcessMessages;
      Sleep(700);
      Application.ProcessMessages;
      { Снимок реального окна: PaintTo не отрисовывает GroupBox вне экрана,
        поэтому читаем то, что виджетсет нарисовал на дисплее. }
      lScreenShot := TBitmap.Create;
      lImage := TFPMemoryImage.Create(lDialog.Width, lDialog.Height);
      lIntf := nil;
      try
        lScreenShot.SetSize(lDialog.Width, lDialog.Height);
        lScreenShot.Canvas.CopyRect(Rect(0, 0, lDialog.Width, lDialog.Height),
          lDialog.Canvas,
          Rect(0, 0, lDialog.Width, lDialog.Height));
        lBitmap := nil;
        lIntf := lScreenShot.CreateIntfImage;
        { Копирование попиксельно: в этой версии FPC у TFPMemoryImage нет
          LoadFromIntfImage, а прямая запись IntfImage нужна для TFPWriterPNG. }
        for lY := 0 to lIntf.Height - 1 do
          for lX := 0 to lIntf.Width - 1 do
          begin
            lColor := lIntf.Colors[lX, lY];
            lImage.Colors[lX, lY] := lColor;
          end;
        lWriter := TFPWriterPNG.Create;
        try
          lImage.SaveToFile(lOutName, lWriter);
        finally
          lWriter.Free;
        end;
        WriteLn('saved ' + lOutName + ' ' + IntToStr(lDialog.Width) + 'x' +
          IntToStr(lDialog.Height));
      finally
        lIntf.Free;
        lImage.Free;
        lScreenShot.Free;
      end;
    finally
      lDialog.Hide;
      lDialog.Free;
    end;
  finally
    lComponent.Free;
  end;
end.
